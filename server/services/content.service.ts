/**
 * Read models for public content: services, categories, brands, homepage,
 * settings, partners, gallery, reviews and FAQ. These back the Landing SPA.
 */
import { prisma } from '../utils/prisma'

export async function listServices(includeAll = false) {
  const rows = await prisma.service.findMany({
    where: includeAll ? {} : { status: 'ACTIVE', deletedAt: null },
    orderBy: { sortOrder: 'asc' },
  })
  return rows.map((s) => ({
    id: s.id,
    slug: s.slug,
    serviceType: s.serviceType,
    title: s.title,
    summary: s.summary,
    description: s.description,
    price: s.price,
    duration: s.duration,
    gallery: s.gallery,
    status: s.status,
    sortOrder: s.sortOrder,
  }))
}

export async function getServiceBySlug(slug: string) {
  const s = await prisma.service.findFirst({ where: { slug, deletedAt: null } })
  if (!s) return null
  return {
    id: s.id,
    slug: s.slug,
    serviceType: s.serviceType,
    title: s.title,
    summary: s.summary,
    description: s.description,
    price: s.price,
    duration: s.duration,
    gallery: s.gallery,
    status: s.status,
    sortOrder: s.sortOrder,
  }
}

export async function listCategories() {
  const rows = await prisma.category.findMany({
    where: { status: 'ACTIVE', deletedAt: null },
    orderBy: { sortOrder: 'asc' },
    include: { _count: { select: { products: { where: { status: 'ACTIVE', deletedAt: null } } } } },
  })
  return rows.map((c) => ({
    id: c.id,
    parentId: c.parentId,
    slug: c.slug,
    title: c.title,
    description: c.description,
    image: c.image,
    sortOrder: c.sortOrder,
    status: c.status,
    productCount: c._count.products,
  }))
}

export async function listBrands() {
  const rows = await prisma.brand.findMany({
    where: { status: 'ACTIVE' },
    orderBy: { sortOrder: 'asc' },
    include: { models: { where: { status: 'ACTIVE' }, orderBy: { name: 'asc' } } },
  })
  return rows
}

export async function listPartners() {
  return prisma.partner.findMany({ orderBy: { sortOrder: 'asc' } })
}

export async function listGallery() {
  return prisma.gallery.findMany({ where: { published: true }, orderBy: { sortOrder: 'asc' } })
}

export async function listReviews() {
  return prisma.review.findMany({ where: { published: true }, orderBy: { sortOrder: 'asc' } })
}

export async function listFaq() {
  return prisma.faq.findMany({ where: { published: true }, orderBy: { sortOrder: 'asc' } })
}

export async function getHomepage() {
  return prisma.homepage.findFirst()
}

export async function getPublicSettings() {
  const s = await prisma.settings.findFirst()
  if (!s) return null
  return {
    companyName: s.companyName,
    phone: s.phone,
    email: s.email,
    telegram: s.telegram,
    instagram: s.instagram,
    youtube: s.youtube,
    addressLines: s.address as string[],
    workSchedule: s.workingHours as string[],
    defaultLanguage: s.defaultLanguage,
    logo: s.logo,
    favicon: s.favicon,
    analytics: s.analytics,
  }
}
