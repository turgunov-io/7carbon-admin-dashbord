import { prisma } from '../../../utils/prisma'
import { ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'
import { consultationStats } from '../../../services/consultation.service'

/** GET /api/v1/admin/stats — dashboard home widgets (doc 07/21). */
export default defineEventHandler(async (event) => {
  await requireAuth(event)
  const [products, services, categories, brands, media, gallery, crm, recent] = await Promise.all([
    prisma.product.count({ where: { deletedAt: null } }),
    prisma.service.count({ where: { deletedAt: null } }),
    prisma.category.count({ where: { deletedAt: null } }),
    prisma.brand.count(),
    prisma.media.count(),
    prisma.gallery.count(),
    consultationStats(),
    prisma.consultation.findMany({
      orderBy: { createdAt: 'desc' },
      take: 6,
      select: { id: true, fullName: true, phone: true, status: true, createdAt: true },
    }),
  ])
  return ok({
    totals: { products, services, categories, brands, media, gallery },
    consultations: crm,
    recentConsultations: recent.map((r) => ({ ...r, createdAt: r.createdAt.toISOString() })),
  })
})
