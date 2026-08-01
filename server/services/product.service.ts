/**
 * Product business logic (doc 19). Handles listing with pagination/search/filter,
 * single lookups, and admin mutations. Serializes Prisma rows into transport DTOs.
 */
import type { Prisma, Product as PrismaProduct } from '@prisma/client'
import { prisma } from '../utils/prisma'
import { slugify } from '../utils/slug'

const productInclude = {
  images: { orderBy: { sortOrder: 'asc' } },
  category: { select: { id: true, slug: true, title: true } },
  compatibleBrands: { include: { brand: true } },
} satisfies Prisma.ProductInclude

type ProductRow = Prisma.ProductGetPayload<{ include: typeof productInclude }>

export function serializeProduct(p: ProductRow) {
  return {
    id: p.id,
    slug: p.slug,
    title: p.title,
    supplierBrand: p.supplierBrand,
    vehicleModel: p.vehicleModel,
    shortDescription: p.shortDescription,
    cardDescription: p.cardDescription,
    description: p.description,
    price: p.price,
    oldPrice: p.oldPrice,
    priceAmount: p.priceAmount,
    status: p.status,
    categoryId: p.categoryId,
    category: p.category,
    cardImage: p.cardImage,
    images: p.images.map((i) => ({ id: i.id, image: i.image, alt: i.alt, sortOrder: i.sortOrder })),
    compatibleBrands: p.compatibleBrands.map((cb) => ({
      id: cb.brand.id,
      name: cb.brand.name,
      slug: cb.brand.slug,
      logo: cb.brand.logo,
      country: cb.brand.country,
      status: cb.brand.status,
      sortOrder: cb.brand.sortOrder,
    })),
    sortOrder: p.sortOrder,
    createdAt: p.createdAt.toISOString(),
    updatedAt: p.updatedAt.toISOString(),
  }
}

export interface ListProductsParams {
  page: number
  pageSize: number
  search?: string
  categorySlug?: string
  brandSlug?: string
  supplierBrand?: string
  sort?: string
  order: 'asc' | 'desc'
  includeAll?: boolean // admin: include drafts/archived
}

export async function listProducts(params: ListProductsParams) {
  const where: Prisma.ProductWhereInput = { deletedAt: null }
  if (!params.includeAll) where.status = 'ACTIVE'
  if (params.search) {
    where.OR = [
      { title: { contains: params.search, mode: 'insensitive' } },
      { vehicleModel: { contains: params.search, mode: 'insensitive' } },
      { supplierBrand: { contains: params.search, mode: 'insensitive' } },
    ]
  }
  if (params.categorySlug) where.category = { slug: params.categorySlug }
  if (params.supplierBrand) where.supplierBrand = params.supplierBrand
  if (params.brandSlug) {
    where.compatibleBrands = { some: { brand: { slug: params.brandSlug } } }
  }

  const orderBy: Prisma.ProductOrderByWithRelationInput =
    params.sort === 'price'
      ? { priceAmount: params.order }
      : params.sort === 'title'
        ? { title: params.order }
        : { sortOrder: 'asc' }

  const [rows, total] = await Promise.all([
    prisma.product.findMany({
      where,
      include: productInclude,
      orderBy,
      skip: (params.page - 1) * params.pageSize,
      take: params.pageSize,
    }),
    prisma.product.count({ where }),
  ])

  return {
    items: rows.map(serializeProduct),
    meta: {
      page: params.page,
      pageSize: params.pageSize,
      total,
      totalPages: Math.max(1, Math.ceil(total / params.pageSize)),
    },
  }
}

export async function getProductBySlug(slug: string) {
  const row = await prisma.product.findFirst({
    where: { slug, deletedAt: null },
    include: productInclude,
  })
  return row ? serializeProduct(row) : null
}

export async function getProductById(id: string) {
  const row = await prisma.product.findUnique({ where: { id }, include: productInclude })
  return row ? serializeProduct(row) : null
}

export async function createProduct(input: Partial<PrismaProduct> & { title: string }) {
  const slug = input.slug || (await ensureUniqueSlug(slugify(input.title)))
  const row = await prisma.product.create({
    data: {
      title: input.title,
      slug,
      supplierBrand: input.supplierBrand ?? null,
      vehicleModel: input.vehicleModel ?? null,
      shortDescription: input.shortDescription ?? null,
      cardDescription: input.cardDescription ?? null,
      description: input.description ?? null,
      price: input.price ?? null,
      oldPrice: input.oldPrice ?? null,
      status: input.status ?? 'DRAFT',
      categoryId: input.categoryId ?? null,
      sortOrder: input.sortOrder ?? 0,
    },
    include: productInclude,
  })
  return serializeProduct(row)
}

export async function updateProduct(id: string, input: Partial<PrismaProduct>) {
  const row = await prisma.product.update({ where: { id }, data: input, include: productInclude })
  return serializeProduct(row)
}

/** Soft delete (archive-then-remove pattern). */
export async function deleteProduct(id: string) {
  await prisma.product.update({ where: { id }, data: { deletedAt: new Date(), status: 'ARCHIVED' } })
}

async function ensureUniqueSlug(base: string): Promise<string> {
  let slug = base || 'product'
  let i = 2
  while (await prisma.product.findUnique({ where: { slug } })) slug = `${base}-${i++}`
  return slug
}
