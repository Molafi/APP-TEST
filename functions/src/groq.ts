/**
 * Groq request construction and response normalization. Groq exposes an
 * OpenAI-compatible Chat Completions API. The API key is passed in from the
 * caller (read from Secret Manager) and is NEVER logged or returned to the
 * client.
 */

export const GROQ_BASE = "https://api.groq.com/openai/v1";

/**
 * AgentRouter is an OpenAI-compatible relay fronting Claude/GPT/Gemini. We use
 * its Chat Completions path so the exact same request builder works — the
 * Anthropic /v1/messages path is deliberately avoided because it only accepts
 * traffic matching the Claude Code client wire image.
 */
export const AGENTROUTER_BASE = "https://agentrouter.org/v1";

/** An OpenAI-compatible upstream: base URL plus its bearer key. */
export interface ProviderConfig {
  baseUrl: string;
  apiKey: string;
}

export interface ProxyRequest {
  system: string;
  text: string;
  context?: Record<string, string>;
  history?: { role: "user" | "model"; text: string }[];
  image?: { mimeType: string; data: string };
  jsonMode?: boolean;
}

export class GroqError extends Error {
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

export async function callChatCompletions(
  provider: ProviderConfig,
  models: string[],
  req: ProxyRequest,
  timeoutMs = 45000
): Promise<string> {
  const hasImage = !!req.image;
  const candidates = models;

  let lastError: GroqError | null = null;
  for (const model of candidates) {
    try {
      return await callModel(provider, model, req, hasImage, timeoutMs);
    } catch (e) {
      // Fall through only for "model unavailable" style errors.
      if (
        e instanceof GroqError &&
        (e.status === 404 || e.status === 400)
      ) {
        lastError = e;
        continue;
      }
      throw e;
    }
  }
  throw lastError ?? new GroqError(404, "no_model");
}

async function callModel(
  provider: ProviderConfig,
  model: string,
  req: ProxyRequest,
  hasImage: boolean,
  timeoutMs: number
): Promise<string> {

  const messages: unknown[] = [{ role: "system", content: req.system }];
  for (const turn of req.history ?? []) {
    messages.push({
      role: turn.role === "model" ? "assistant" : "user",
      content: turn.text,
    });
  }

  if (hasImage) {
    messages.push({
      role: "user",
      content: [
        { type: "text", text: composeUserText(req) },
        {
          type: "image_url",
          image_url: {
            url: `data:${req.image!.mimeType};base64,${req.image!.data}`,
          },
        },
      ],
    });
  } else {
    messages.push({ role: "user", content: composeUserText(req) });
  }

  const body: Record<string, unknown> = {
    model,
    messages,
    temperature: 0.4,
  };
  // Only request JSON mode for text-only calls; some vision models reject
  // response_format. Diagnosis relies on the strict instruction + tolerant
  // client-side parser instead.
  if (req.jsonMode && !hasImage) {
    body.response_format = { type: "json_object" };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  let res: Response;
  try {
    res = await fetch(`${provider.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${provider.apiKey}`,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
  } catch {
    throw new GroqError(408, "timeout");
  } finally {
    clearTimeout(timer);
  }

  if (!res.ok) {
    // Map upstream status without leaking the response body to the client.
    if (res.status === 429) throw new GroqError(429, "rate_limited");
    throw new GroqError(res.status, `upstream_${res.status}`);
  }

  const json = (await res.json()) as any;
  const choices = json.choices;
  if (!Array.isArray(choices) || choices.length === 0) {
    throw new GroqError(502, "malformed");
  }
  const content = choices[0]?.message?.content;
  if (typeof content !== "string" || content.trim().length === 0) {
    // Empty content is typically a safety/content filter result.
    throw new GroqError(422, "content_blocked");
  }
  return content.trim();
}
