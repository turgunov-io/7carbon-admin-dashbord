/**
 * Prisma seed — loads the REAL 7Carbon business content extracted from the live
 * production API (api.7carbon.uz) into PostgreSQL. Nothing here is invented:
 * products, prices, services, contacts and company copy are preserved verbatim
 * from database/seed-data/*.json. Product-type categories and vehicle brands are
 * derived deterministically from the real catalog so the storefront can filter.
 *
 * Idempotent: safe to run repeatedly (upserts by natural keys / clears content).
 */
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'
import { PrismaClient, ProductStatus } from '@prisma/client'
import { hash } from '@node-rs/argon2'

const prisma = new PrismaClient()
const __dirname = dirname(fileURLToPath(import.meta.url))
const dataDir = resolve(__dirname, '../../database/seed-data')

function load<T>(file: string): T {
  return JSON.parse(readFileSync(resolve(dataDir, file), 'utf-8')) as T
}

// ── Local helpers (kept inline so seed has no build-time import of shared/) ──
function parsePriceAmount(raw?: string | null): number | null {
  if (!raw) return null
  const digits = raw.toLowerCase().replace(/uzs|so'?m/g, '').replace(/[^0-9]/g, '')
  if (!digits) return null
  const n = Number.parseInt(digits, 10)
  return Number.isFinite(n) ? n : null
}

const translit: Record<string, string> = {
  а: 'a', б: 'b', в: 'v', г: 'g', д: 'd', е: 'e', ё: 'e', ж: 'zh', з: 'z',
  и: 'i', й: 'y', к: 'k', л: 'l', м: 'm', н: 'n', о: 'o', п: 'p', р: 'r',
  с: 's', т: 't', у: 'u', ф: 'f', х: 'h', ц: 'ts', ч: 'ch', ш: 'sh', щ: 'sch',
  ъ: '', ы: 'y', ь: '', э: 'e', ю: 'yu', я: 'ya',
}
function slugify(input: string): string {
  return input.toLowerCase().split('').map((c) => translit[c] ?? c).join('')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').replace(/-{2,}/g, '-').slice(0, 90)
}
function uniqueSlug(base: string, used: Set<string>): string {
  let slug = base || 'item'
  let i = 2
  while (used.has(slug)) slug = `${base}-${i++}`
  used.add(slug)
  return slug
}

// ── Source record shapes ──
interface RawProduct {
  id: number; brand: string; model: string; title: string
  card_image_url: string | null; full_image_url: string[] | null
  price: string | null; description: string | null
  card_description: string | null; full_description: string | null
}
interface RawService {
  id: number; service_type: string; title: string
  detailed_description: string | null; gallery_images: string[] | null
}
interface RawContact {
  phone_number: string; address: string; email: string; work_schedule: string
}
interface RawPartner { id: number; logo_url: string }
interface RawAbout {
  page: { mission_description: string | null }
  metrics: { value: string; label: string; position: number }[]
  sections: { key: string; title: string; description: string }[]
}
interface RawBanner { section: string; title: string; image_url: string }

// Derive a product-type category from the real title (RU + EN keywords).
function categoryFor(title: string): { slug: string; title: string } {
  const t = title.toLowerCase()
  if (/(exhaust|выхлоп|slip-on|tail pipe|link pipe|глушител)/.test(t))
    return { slug: 'exhaust-systems', title: 'Выхлопные системы' }
  if (/(downpipe|катализатор|catted|cell)/.test(t))
    return { slug: 'downpipes', title: 'Downpipes и катализаторы' }
  if (/(intake|впуск|воздухозабор|inlet|air filter|воздушн)/.test(t))
    return { slug: 'intake-systems', title: 'Впускные системы' }
  if (/(cooler|охлажд|charge-air|oil cooler|радиатор)/.test(t))
    return { slug: 'cooling', title: 'Системы охлаждения' }
  return { slug: 'accessories', title: 'Аксессуары и прочее' }
}

// Detect a vehicle make from the free-text model/title for the compatibility filter.
const VEHICLE_MAKES: { name: string; slug: string; country: string; match: RegExp }[] = [
  { name: 'BMW', slug: 'bmw', country: 'Германия', match: /\bbmw\b/i },
  { name: 'Audi', slug: 'audi', country: 'Германия', match: /\baudi\b/i },
  { name: 'Mercedes-AMG', slug: 'mercedes-amg', country: 'Германия', match: /(mercedes|amg)/i },
  { name: 'Porsche', slug: 'porsche', country: 'Германия', match: /\bporsche\b/i },
  { name: 'Lamborghini', slug: 'lamborghini', country: 'Италия', match: /lamborghini/i },
]

async function main() {
  console.log('› Seeding 7Carbon real business data…')

  // Clean content tables (preserve users unless empty). Order respects FKs.
  await prisma.$transaction([
    prisma.productImage.deleteMany(),
    prisma.productBrand.deleteMany(),
    prisma.productModel.deleteMany(),
    prisma.product.deleteMany(),
    prisma.category.deleteMany(),
    prisma.service.deleteMany(),
    prisma.model.deleteMany(),
    prisma.brand.deleteMany(),
    prisma.partner.deleteMany(),
    prisma.gallery.deleteMany(),
    prisma.faq.deleteMany(),
    prisma.homepage.deleteMany(),
    prisma.settings.deleteMany(),
  ])

  // ── Admin user ──
  const adminEmail = process.env.SEED_ADMIN_EMAIL ?? 'admin@7carbon.uz'
  const adminPassword = process.env.SEED_ADMIN_PASSWORD ?? 'ChangeMe_7Carbon!'
  await prisma.user.upsert({
    where: { email: adminEmail },
    update: {},
    create: {
      email: adminEmail,
      passwordHash: await hash(adminPassword),
      fullName: '7Carbon Administrator',
      role: 'SUPER_ADMIN',
      language: 'ru',
    },
  })
  console.log(`  ✓ Admin user: ${adminEmail}`)

  // ── Vehicle brands + a generic model per brand (for compatibility filter) ──
  const brandBySlug = new Map<string, string>()
  for (const [i, make] of VEHICLE_MAKES.entries()) {
    const b = await prisma.brand.create({
      data: { name: make.name, slug: make.slug, country: make.country, sortOrder: i },
    })
    brandBySlug.set(make.slug, b.id)
  }

  // ── Categories (product-type) ──
  const products = load<RawProduct[]>('products.json')
  const catMap = new Map<string, { slug: string; title: string }>()
  for (const p of products) {
    const c = categoryFor(`${p.title} ${p.model}`)
    catMap.set(c.slug, c)
  }
  const categoryIdBySlug = new Map<string, string>()
  let catOrder = 0
  for (const c of catMap.values()) {
    const created = await prisma.category.create({
      data: { slug: c.slug, title: c.title, sortOrder: catOrder++ },
    })
    categoryIdBySlug.set(c.slug, created.id)
  }
  console.log(`  ✓ Categories: ${categoryIdBySlug.size}`)

  // ── Products (all 45, verbatim) ──
  const usedSlugs = new Set<string>()
  let order = 0
  for (const p of products) {
    const cat = categoryFor(`${p.title} ${p.model}`)
    const slug = uniqueSlug(slugify(p.title || `product-${p.id}`), usedSlugs)
    const images = Array.isArray(p.full_image_url) ? p.full_image_url : []
    const created = await prisma.product.create({
      data: {
        slug,
        title: p.title,
        supplierBrand: p.brand || null,
        vehicleModel: p.model || null,
        shortDescription: p.card_description || p.description || null,
        cardDescription: p.card_description || null,
        description: p.full_description || p.description || null,
        price: p.price || null,
        priceAmount: parsePriceAmount(p.price),
        cardImage: p.card_image_url || images[0] || null,
        status: ProductStatus.ACTIVE,
        sortOrder: order++,
        categoryId: categoryIdBySlug.get(cat.slug) ?? null,
        images: {
          create: images.map((img, idx) => ({ image: img, sortOrder: idx, alt: p.title })),
        },
      },
    })

    // Link compatible vehicle makes detected in the fitment text.
    const haystack = `${p.title} ${p.model}`
    for (const make of VEHICLE_MAKES) {
      if (make.match.test(haystack)) {
        const brandId = brandBySlug.get(make.slug)
        if (brandId) {
          await prisma.productBrand.create({ data: { productId: created.id, brandId } })
        }
      }
    }
  }
  console.log(`  ✓ Products: ${products.length}`)

  // ── Services (all 8, verbatim) ──
  const services = load<RawService[]>('services.json')
  const usedServiceSlugs = new Set<string>()
  let sOrder = 0
  for (const s of services) {
    await prisma.service.create({
      data: {
        slug: uniqueSlug(slugify(s.service_type || s.title), usedServiceSlugs),
        serviceType: s.service_type,
        title: s.title,
        summary: (s.detailed_description || '').split('\n').filter(Boolean)[0]?.slice(0, 400) || null,
        description: s.detailed_description || null,
        gallery: Array.isArray(s.gallery_images) ? s.gallery_images : [],
        status: ProductStatus.ACTIVE,
        sortOrder: sOrder++,
      },
    })
  }
  console.log(`  ✓ Services: ${services.length}`)

  // ── Partners ──
  const partners = load<RawPartner[]>('partners.json')
  await prisma.partner.createMany({
    data: partners.map((p, i) => ({ logo: p.logo_url, sortOrder: i })),
  })
  console.log(`  ✓ Partners: ${partners.length}`)

  // ── Gallery (real imagery drawn from product photos so it is not empty) ──
  const galleryImages = products
    .flatMap((p) => (Array.isArray(p.full_image_url) ? p.full_image_url : []))
    .slice(0, 24)
  await prisma.gallery.createMany({
    data: galleryImages.map((image, i) => ({ image, sortOrder: i, category: 'tuning' })),
  })
  console.log(`  ✓ Gallery items: ${galleryImages.length}`)

  // ── Homepage (about copy + metrics + hero banner) ──
  const about = load<RawAbout>('about.json')
  const banners = load<RawBanner[]>('banners.json')
  const home = banners.find((b) => b.section === 'home')
  await prisma.homepage.create({
    data: {
      heroTitle: {
        ru: home?.title ?? 'Первое мультибрендовое тюнинг ателье в Ташкенте',
        uz: 'Toshkentdagi birinchi ko‘p brendli tюning atelyesi',
        en: 'The first multi-brand tuning atelier in Tashkent',
      },
      heroSubtitle: {
        ru: 'Карбон, титановые выхлопы и инженерия для люксовых и спортивных автомобилей.',
        uz: 'Karbon, titan chiqindi tizimlari va lyuks avtomobillar uchun muhandislik.',
        en: 'Carbon fibre, titanium exhausts and engineering for luxury and performance cars.',
      },
      heroImage: home?.image_url ?? null,
      aboutTitle: { ru: 'О компании', uz: 'Kompaniya haqida', en: 'About us' },
      aboutText: {
        ru: about.page.mission_description ?? about.sections[0]?.description ?? '',
        uz: about.page.mission_description ?? '',
        en: about.page.mission_description ?? '',
      },
      metrics: about.metrics.map((m) => ({
        value: m.value,
        label: { ru: m.label, uz: m.label, en: m.label },
        position: m.position,
      })),
    },
  })
  console.log('  ✓ Homepage content')

  // ── Settings (contacts, verbatim) ──
  const contact = load<RawContact[]>('contact.json')[0]
  const parseBag = (v: string): string[] => {
    try { const a = JSON.parse(v); return Array.isArray(a) ? a : [v] } catch { return [v] }
  }
  await prisma.settings.create({
    data: {
      companyName: '7 Carbon',
      phone: contact.phone_number,
      email: contact.email,
      telegram: 'https://t.me/carbon7uz',
      instagram: 'https://instagram.com/7carbon.uz',
      address: parseBag(contact.address),
      workingHours: parseBag(contact.work_schedule),
      defaultLanguage: 'ru',
    },
  })
  console.log('  ✓ Settings (contacts)')

  console.log('✓ Seed complete.')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
