/**
 * Structured logging (doc 13/19). Never logs secrets, passwords or tokens.
 */
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL ?? (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
  redact: {
    paths: ['password', 'passwordHash', 'token', 'refreshToken', 'authorization', '*.password'],
    remove: true,
  },
})
