/**
 * Gemini request construction and response normalization. The API key is
 * passed in from the caller (read from Secret Manager) and is NEVER logged or
 * returned to the client.
 */

const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta";

export interface ProxyRequest {
  system: string;
  text: string;
  context?: Record<string, string>;
  history?: { role: "user" | "model"; text: string }[];
  image?: { mimeType: string; data: string };
  jsonMode?: boolean;
}

export class GeminiError extends Error {
  constructor(public status: number, public code: string) {
    super(code);
  }
}

function composeUserText(req: ProxyRequest): string {
  if (!req.context || Object.keys(req.context).length === 0) return req.text;
  const ctx = Object.entries(req.context)
    .map(([k, v]) => `${k}: ${v}`)
    .join(", ");
  // Delimit untrusted context from the instruction.
  return `[context] ${ctx}\n[user] ${req.text}`;
}

export async function callGemini(
  apiKey: string,
  model: string,
  req: ProxyRequest,
  timeoutMs = 45000
): Promise<string> {
  const contents: unknown[] = [];

  for (const turn of req.history ?? []) {
    contents.push({ role: turn.role, parts: [{ text: turn.text }] });
  }

  const userParts: unknown[] = [];
  if (req.image) {
    userParts.push({
      inline_data: { mime_type: req.image.mimeType, data: req.image.data },
    });
  }
  userParts.push({ text: composeUserText(req) });
  contents.push({ role: "user", parts: userParts });

  const body = {
    system_instruction: { parts: [{ text: req.system }] },
    contents,
    generationConfig: {
      temperature: 0.4,
      ...(req.jsonMode ? { responseMimeType: "application/json" } : {}),
    },
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  let res: Response;
  try {
    res = await fetch(
      `${GEMINI_BASE}/models/${model}:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: controller.signal,
      }
    );
  } catch (e) {
    throw new GeminiError(408, "timeout");
  } finally {
    clearTimeout(timer);
  }

  if (!res.ok) {
    // Map upstream status without leaking the response body to the client.
    throw new GeminiError(res.status, `upstream_${res.status}`);
  }

  const json = (await res.json()) as any;

  if (json.promptFeedback?.blockReason) {
    throw new GeminiError(422, "content_blocked");
  }
  const candidates = json.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw new GeminiError(422, "content_blocked");
  }
  const parts = candidates[0]?.content?.parts;
  if (!Array.isArray(parts)) throw new GeminiError(502, "malformed");

  const text = parts
    .map((p: any) => (typeof p.text === "string" ? p.text : ""))
    .join("")
    .trim();
  if (!text) throw new GeminiError(502, "malformed");
  return text;
}
