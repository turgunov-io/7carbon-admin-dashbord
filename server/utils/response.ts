/**
 * Uniform API response envelope + error helpers (doc 09 / 19).
 * Every endpoint returns `{ success, data }` or `{ success, message, errors }`.
 */
import type { H3Event } from 'h3'
import { ZodError, type ZodSchema } from 'zod'

export interface FieldError {
  field: string
  message: string
}

export function ok<T>(data: T, meta?: unknown) {
  return meta ? { success: true as const, data, meta } : { success: true as const, data }
}

/** Throw a structured HTTP error that the global handler renders as our envelope. */
export function fail(statusCode: number, message: string, errors?: FieldError[]): never {
  throw createError({ statusCode, statusMessage: message, data: { message, errors } })
}

/** Validate a payload with Zod, converting failures into a 422 field-error list. */
export function parseOrFail<T>(schema: ZodSchema<T>, payload: unknown): T {
  try {
    return schema.parse(payload)
  } catch (err) {
    if (err instanceof ZodError) {
      const errors: FieldError[] = err.errors.map((e) => ({
        field: e.path.join('.') || '_',
        message: e.message,
      }))
      fail(422, 'Ошибка валидации', errors)
    }
    throw err
  }
}

/** Read + validate the JSON body of a request. */
export async function readValidatedJson<T>(event: H3Event, schema: ZodSchema<T>): Promise<T> {
  const body = await readBody(event).catch(() => ({}))
  return parseOrFail(schema, body)
}
