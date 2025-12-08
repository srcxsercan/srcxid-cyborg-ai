import crypto from "crypto";

export function ensureCorrelation(data) {
  return {
    ...data,
    correlation_id: data?.correlation_id || crypto.randomUUID()
  };
}
