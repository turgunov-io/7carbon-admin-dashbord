/**
 * Consultation request workflow — the primary conversion path of the business.
 * Public submissions are persisted; the dashboard drives them through the CRM
 * statuses NEW → CONTACTED → IN_PROGRESS → COMPLETED / CANCELLED (doc 07/18).
 */
import type { ConsultationStatus, Prisma } from '@prisma/client'
import { prisma } from '../utils/prisma'
import type { ConsultationSchema } from '@shared/validators'

const include = {
  brand: { select: { id: true, name: true } },
  model: { select: { id: true, name: true } },
  product: { select: { id: true, title: true, slug: true } },
  service: { select: { id: true, title: true } },
  manager: { select: { id: true, fullName: true } },
} satisfies Prisma.ConsultationInclude

type Row = Prisma.ConsultationGetPayload<{ include: typeof include }>

function serialize(c: Row) {
  return {
    id: c.id,
    fullName: c.fullName,
    phone: c.phone,
    telegram: c.telegram,
    email: c.email,
    carBrand: c.carBrand ?? c.brand?.name ?? null,
    carModel: c.carModel ?? c.model?.name ?? null,
    brandId: c.brandId,
    modelId: c.modelId,
    year: c.year,
    productId: c.productId,
    product: c.product,
    serviceId: c.serviceId,
    service: c.service,
    preferredDate: c.preferredDate?.toISOString() ?? null,
    message: c.message,
    attachments: c.attachments,
    status: c.status,
    manager: c.manager,
    managerNotes: c.managerNotes,
    createdAt: c.createdAt.toISOString(),
    updatedAt: c.updatedAt.toISOString(),
  }
}

export async function createConsultation(input: ConsultationSchema) {
  const row = await prisma.consultation.create({
    data: {
      fullName: input.fullName,
      phone: input.phone,
      telegram: input.telegram ?? null,
      email: input.email || null,
      brandId: input.brandId ?? null,
      modelId: input.modelId ?? null,
      carBrand: input.carBrand ?? null,
      carModel: input.carModel ?? null,
      year: input.year ?? null,
      productId: input.productId ?? null,
      serviceId: input.serviceId ?? null,
      preferredDate: input.preferredDate ? new Date(input.preferredDate) : null,
      message: input.message ?? null,
      attachments: input.attachments ?? [],
      status: 'NEW',
    },
    include,
  })
  return serialize(row)
}

export interface ListConsultationsParams {
  page: number
  pageSize: number
  status?: ConsultationStatus
  search?: string
}

export async function listConsultations(params: ListConsultationsParams) {
  const where: Prisma.ConsultationWhereInput = {}
  if (params.status) where.status = params.status
  if (params.search) {
    where.OR = [
      { fullName: { contains: params.search, mode: 'insensitive' } },
      { phone: { contains: params.search } },
      { email: { contains: params.search, mode: 'insensitive' } },
    ]
  }
  const [rows, total] = await Promise.all([
    prisma.consultation.findMany({
      where,
      include,
      orderBy: { createdAt: 'desc' },
      skip: (params.page - 1) * params.pageSize,
      take: params.pageSize,
    }),
    prisma.consultation.count({ where }),
  ])
  return {
    items: rows.map(serialize),
    meta: {
      page: params.page,
      pageSize: params.pageSize,
      total,
      totalPages: Math.max(1, Math.ceil(total / params.pageSize)),
    },
  }
}

export async function getConsultation(id: string) {
  const row = await prisma.consultation.findUnique({ where: { id }, include })
  return row ? serialize(row) : null
}

export async function updateConsultation(
  id: string,
  data: { status?: ConsultationStatus; managerNotes?: string; managerId?: string },
) {
  const row = await prisma.consultation.update({ where: { id }, data, include })
  return serialize(row)
}

export async function consultationStats() {
  const grouped = await prisma.consultation.groupBy({
    by: ['status'],
    _count: { _all: true },
  })
  const byStatus = Object.fromEntries(grouped.map((g) => [g.status, g._count._all]))
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const todayCount = await prisma.consultation.count({ where: { createdAt: { gte: today } } })
  return { byStatus, todayCount, total: grouped.reduce((s, g) => s + g._count._all, 0) }
}
