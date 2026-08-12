/**
 * PlantSense AI — secure AI proxy (Groq).
 *
 * The Flutter client calls this authenticated endpoint instead of talking to
 * Groq directly, so the Groq API key never ships in the app. The key is read
 * from Secret Manager (set via `firebase functions:secrets:set GROQ_API_KEY`).
 *
 * Responsibilities:
 *  - Verify Firebase Authentication (Bearer ID token).
 *  - Validate content type and payload size.
 *  - Apply a per-user rate limit.
 *  - Read the Groq key from server-side secret storage.
 *  - Return normalized errors and never leak the key or raw upstream bodies.
 *  - Never log private message text or image bytes.
 */

import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

import {
  callChatCompletions,
  GroqError,
  ProxyRequest,
  ProviderConfig,
  GROQ_BASE,
  AGENTROUTER_BASE,
} from "./groq";

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const GROQ_API_KEY = defineSecret("GROQ_API_KEY");

// Optional: enables Claude Opus for image (vision) requests via AgentRouter.
// Create it before deploying with:
//   firebase functions:secrets:set AGENTROUTER_API_KEY
// If you don't want Claude vision, remove this from the `secrets` array below
// and vision falls back to the Groq Llama models automatically.
const AGENTROUTER_API_KEY = defineSecret("AGENTROUTER_API_KEY");

// Groq model names, primary first then fallback. Override if Groq's free
// lineup changes; the proxy automatically falls back when a model is retired.
const GROQ_TEXT_MODELS = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant"];
const GROQ_VISION_MODELS = [
  "meta-llama/llama-4-scout-17b-16e-instruct",
  "meta-llama/llama-4-maverick-17b-128e-instruct",
];

// Claude Opus reads plant photos considerably better than the Llama vision
// models, so image requests prefer it when an AgentRouter key is configured.
// Primary first, then fallback — relay model IDs drift, and callChatCompletions
// retries the next entry on a 404/400.
const AGENTROUTER_VISION_MODELS = ["claude-opus-4-8", "claude-opus-4-6"];

/**
 * Reads the optional AgentRouter secret. Returns "" when the secret has not
 * been created, so deployments that only use Groq keep working.
 */
function agentRouterKey(): string {
  try {
    return AGENTROUTER_API_KEY.value() || "";
  } catch {
    return "";
  }
}

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

export const aiProxy = onRequest(
  {
    secrets: [GROQ_API_KEY, AGENTROUTER_API_KEY],
    cors: false,
    timeoutSeconds: 60,
  },
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
    if (
      !payload ||
      typeof payload.text !== "string" ||
      typeof payload.system !== "string"
    ) {
      res.status(400).json({ error: "invalid_request" });
      return;
    }
    if (payload.text.length > 8000) {
      res.status(400).json({ error: "input_too_long" });
      return;
    }

    try {
      // Route by modality: images prefer Claude Opus via AgentRouter (when a
      // key exists), everything else goes to Groq.
      const arKey = agentRouterKey();
      const useClaudeVision = !!payload.image && arKey.length > 0;

      const provider: ProviderConfig = useClaudeVision
        ? { baseUrl: AGENTROUTER_BASE, apiKey: arKey }
        : { baseUrl: GROQ_BASE, apiKey: GROQ_API_KEY.value() };

      const models = useClaudeVision
        ? AGENTROUTER_VISION_MODELS
        : payload.image
          ? GROQ_VISION_MODELS
          : GROQ_TEXT_MODELS;

      const text = await callChatCompletions(provider, models, payload);
      res.status(200).json({ text });
    } catch (e) {
      if (e instanceof GroqError) {
        // Log only the code + status, never the request content.
        logger.warn("groq_error", { code: e.code, status: e.status, uid });
        res.status(e.status >= 500 ? 502 : e.status).json({ error: e.code });
        return;
      }
      logger.error("unexpected_error", { uid });
      res.status(500).json({ error: "internal" });
    }
  }
);
