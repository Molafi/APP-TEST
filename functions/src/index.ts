/**
 * PlantSense AI — secure Gemini proxy.
 *
 * The Flutter client calls this authenticated endpoint instead of talking to
 * Gemini directly, so the Gemini API key never ships in the app. The key is
 * read from Secret Manager (set via `firebase functions:secrets:set GEMINI_API_KEY`).
 *
 * Responsibilities:
 *  - Verify Firebase Authentication (Bearer ID token).
 *  - Validate content type and payload size.
 *  - Apply a per-user rate limit.
 *  - Read the Gemini key from server-side secret storage.
 *  - Return normalized errors and never leak the key or raw upstream bodies.
 *  - Never log private message text or image bytes.
 */

import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

import { callGemini, GeminiError, ProxyRequest } from "./gemini";

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const GEMINI_MODEL = "gemini-2.0-flash";

// Max request body (base64 image + text). ~6 MB to allow a compressed photo.
const MAX_BODY_BYTES = 6 * 1024 * 1024;

// Best-effort in-memory per-user rate limit. For strict, multi-instance limits
// use Firestore or a rate-limiting service — documented in the README.
const RATE_WINDOW_MS = 60_000;
const RATE_MAX = 20;
const hits = new Map<string, number[]>();

function rateLimited(uid: string): boolean {
  const now = Date.now();
  const arr = (hits.get(uid) ?? []).filter((t) => now - t < RATE_WINDOW_MS);
  arr.push(now);
  hits.set(uid, arr);
  return arr.length > RATE_MAX;
}

async function verifyUid(authHeader?: string): Promise<string | null> {
  if (!authHeader?.startsWith("Bearer ")) return null;
  const token = authHeader.substring("Bearer ".length);
  try {
    const decoded = await getAuth().verifyIdToken(token);
    return decoded.uid;
  } catch {
    return null;
  }
}

export const geminiProxy = onRequest(
  { secrets: [GEMINI_API_KEY], cors: false, timeoutSeconds: 60 },
  async (req, res) => {
    // Lock down methods and CORS. Mobile apps do not need permissive CORS.
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Methods", "POST");
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "method_not_allowed" });
      return;
    }
    if (!req.is("application/json")) {
      res.status(415).json({ error: "unsupported_media_type" });
      return;
    }

    const rawLength = Number(req.headers["content-length"] ?? 0);
    if (rawLength > MAX_BODY_BYTES) {
      res.status(413).json({ error: "payload_too_large" });
      return;
    }

    const uid = await verifyUid(req.headers.authorization);
    if (!uid) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }

    if (rateLimited(uid)) {
      res.status(429).json({ error: "rate_limited" });
      return;
    }

    const payload = req.body as ProxyRequest;
    if (!payload || typeof payload.text !== "string" || typeof payload.system !== "string") {
      res.status(400).json({ error: "invalid_request" });
      return;
    }
    if (payload.text.length > 8000) {
      res.status(400).json({ error: "input_too_long" });
      return;
    }

    try {
      const text = await callGemini(
        GEMINI_API_KEY.value(),
        GEMINI_MODEL,
        payload
      );
      res.status(200).json({ text });
    } catch (e) {
      if (e instanceof GeminiError) {
        // Log only the code + status, never the request content.
        logger.warn("gemini_error", { code: e.code, status: e.status, uid });
        res.status(e.status >= 500 ? 502 : e.status).json({ error: e.code });
        return;
      }
      logger.error("unexpected_error", { uid });
      res.status(500).json({ error: "internal" });
    }
  }
);
