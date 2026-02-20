# dein.shop – Konzept & Umsetzungsplan

**Erstellt:** 2026-02-20
**Projekt:** Amazon-Alternativen Verzeichnis als moderne Web-App
**Domain:** https://dein.shop
**Quelle:** https://codeberg.org/phranck/Amazon-Alternativen

---

## Ausgangslage

Das Codeberg-Projekt "Amazon-Alternativen" ist eine kuratierte Liste von Online-Shops
für den deutschsprachigen Raum (25+ Kategorien). Die Beitragshuerde (Codeberg-Account +
Pull-Request) schließt viele potenzielle Beitragenden aus. Ziel ist eine moderne Web-App,
die das Projekt auf solide technische Beine stellt und für alle zugänglich macht.

---

## Seitenstruktur

### Öffentlicher Bereich
| Route | Inhalt |
|-------|--------|
| `/` | Homepage: Hero + Suchfeld + Kategorie-Grid |
| `/kategorie/:slug` | Shops einer Kategorie |
| `/suche?q=` | Suchergebnisse |
| `/vorschlagen` | Vorschlagsformular (kein Login) |
| `/ueber-uns` | Projekthintergrund, Transparenz |
| `/impressum` | Pflichtseite |
| `/datenschutz` | DSGVO |

### Admin-Bereich (Route-Guards, lazy loaded)
| Route | Inhalt |
|-------|--------|
| `/admin/setup` | Onboarding: Erster Admin anlegen (nur wenn kein Admin existiert) |
| `/admin/login` | Login |
| `/admin` | Dashboard: Stats, offene Vorschläge |
| `/admin/vorschlaege` | Review: annehmen / ablehnen + Email-Feedback |
| `/admin/shops` | CRUD Shops |
| `/admin/kategorien` | CRUD Kategorien |
| `/admin/benutzer` | Admin-User verwalten (nur Owner) |

---

## UI/UX-Konzept

### Design-Prinzipien
1. **Utility-First:** Suche und Kategorien sofort sichtbar, kein Onboarding-Screen
2. **Niedrige Hürde:** Kein Login, kein Account, alles anonym möglich
3. **Community-Gefühl:** "Von der Community, für die Community" in Sprache + Features
4. **Respektvolle Monetarisierung:** Spenden permanent sichtbar, nie aufdringlich
5. **Mobile-First:** Primäre Nutzung mobil (Link-Sharing, Couch-Nutzung)
6. **Datenschutz:** Kein Google Analytics – Umami oder Plausible (self-hosted)

### Farbkonzept
- Primär: Warmes Grün `#2D6A4F` (Nachhaltigkeit, Alternativen)
- Hintergrund: Creme `#FAF3E0` (einladend, warm)
- Akzent: Sanftes Orange `#E07A5F` (CTAs, Highlights)
- Text: Dunkelgrau `#1A1A2E` (nie reines Schwarz)

### Homepage-Aufbau
```
Header: Logo | Navigation | [Herz] Unterstützen
──────────────────────────────────────────────
Hero: Headline + Subline
      [Suche nach Shops oder Kategorien...]

Kategorien-Grid (4 Spalten Desktop / 2 Mobile)
  [Icon] Bücher (12)   [Icon] Elektronik (15)
  [Icon] Kleidung (18) [Icon] Sport (9)
  ...

CTA: "Shop vorschlagen"

Footer: Links | [PayPal] [Ko-Fi]
```

### Spenden-Platzierung
- **Header:** Kleiner Button "Unterstützen" (Herz-Icon) öffnet Popover mit PayPal + Ko-Fi
- **Footer:** Vollständige Spenden-Sektion mit kurzem Erklärungstext
- **Nach Vorschlag:** Dezenter Hinweis auf der Danke-Seite
- **NICHT:** Als Banner, Modal, Overlay oder zwischen Inhalten

### Vorschlagsformular (kein Login)
Felder: Shop-Name*, URL*, Kategorie* (Dropdown), Beschreibung (optional, max 200 Zeichen),
E-Mail (optional, für Rückmeldung). Max 5 Felder. Captcha: Cloudflare Turnstile
(datenschutzfreundlicher als reCAPTCHA). Duplikat-Check vor Absenden.

### Shop-Karte
Name (Link) | URL | Kurzbeschreibung | Tags (z.B. "Bio", "Made in Germany", "Familienunternehmen")
Kein eigener Detailseite nötig – alles in der Karte. "Zum Shop"-Button öffnet neuen Tab.

### Zusätzliches (User-Wunsch)
- **"Link meldet sich nicht"-Button** an jeder Shop-Karte (meldet toten Link an Admin-Queue)
- **Filter** in Kategorie-Ansicht: Region (DE/AT/CH), kostenloser Versand, etc.
- **Keine Gamification** in v1 (keine Sterne, keine Kommentare)

---

## Frontend-Architektur

### Stack
| Tool | Version | Begründung |
|------|---------|-----------|
| React | 19 | Standard, stabile API |
| Vite | 6 | Schnell, Tree-Shaking |
| TypeScript | 5+ | Type-Safety |
| React Router | v7 | De-facto-Standard |
| TanStack Query | v5 | Server State, Caching |
| Fuse.js | latest | Client-seitige Fuzzy-Suche |
| Tailwind CSS | v4 | Utility-First |
| shadcn/ui | latest | Radix-basiert, a11y, kopierbar |
| React Hook Form + Zod | latest | Formulare + Validation |
| react-helmet-async | latest | SEO Meta-Tags |
| Vitest + Testing Library | latest | Tests |
| MSW | latest | API-Mocking in Tests |

### Projektstruktur (Feature-basiert)
```
src/
├── app/                    # Router, Providers
├── features/
│   ├── categories/         # CategoryGrid, CategoryCard, CategoryDetail
│   ├── shops/              # ShopCard, ShopList
│   ├── search/             # SearchBar, SearchResults, useSearch (Fuse.js)
│   ├── suggest/            # SuggestForm, SuggestSuccess
│   └── admin/              # Dashboard, ShopEditor, CategoryEditor, SuggestionReview
├── components/
│   ├── ui/                 # shadcn/ui Basis-Komponenten
│   ├── layout/             # Header, Footer, PageLayout, AdminLayout
│   └── common/             # DonateButton, Logo, ErrorBoundary
├── lib/                    # api.ts (Fetch-Wrapper), utils.ts, constants.ts
├── hooks/                  # useDebounce, useMediaQuery
└── types/                  # Globale Types (Shop, Category, Submission, AdminUser)
```

### Suche
Client-seitige Suche mit **Fuse.js** (Fuzzy, Tippfehler-tolerant). Alle Shops werden
beim Start als kompaktes JSON geladen (<100KB gzipped). Suche über: Name (Gewicht 0.4),
Beschreibung (0.3), Kategorie (0.2), Tags (0.1). Threshold 0.3.

Wenn die Liste auf >5000 Shops wächst: Migration auf API-seitige Suche (FTS5 bereits im
Backend implementiert – kein Umbau nötig).

### Admin-Integration
Admin-Bereich ist in derselben App mit Route-Guards und lazy loading:
```tsx
const AdminLayout = lazy(() => import("@/features/admin/components/AdminLayout"));
// → Admin-Code landet nicht im Public-Bundle
```

### Keine SSG/SSR (vorerst)
SPA ist für diese Datenmenge ausreichend. TanStack Query cached aggressiv.
SEO via react-helmet-async + vite-plugin-prerender für statische Seiten (/, /ueber-uns).

---

## Backend-Architektur

### Stack
| Tool | Begründung |
|------|-----------|
| Bun | Schnell, eingebauter SQLite-Treiber, All-in-One |
| Hono | Leichtgewichtig, TypeScript-nativ, gute Middleware |
| SQLite + Drizzle ORM | Ein VPS, kein Scaling, Backup = File-Copy |
| SQLite FTS5 | Eingebaut, schnell, kein externer Service |
| Argon2id | Aktueller Passwort-Hash-Standard |
| Server-Side Sessions | Einfacher als JWT, sofortige Invalidierung |
| Resend | Email-Versand, Free-Tier (100/Tag) ausreichend |
| Zod | Validation aller Endpoints |

### Projektstruktur
```
server/
├── src/
│   ├── index.ts            # Entry Point
│   ├── app.ts              # Hono Setup + Middleware
│   ├── routes/
│   │   ├── public.ts       # Öffentliche API
│   │   └── admin.ts        # Admin-geschützte API
│   ├── db/
│   │   ├── schema.ts       # Drizzle Schema
│   │   └── migrations/
│   ├── services/
│   │   ├── auth.ts
│   │   ├── email.ts
│   │   ├── search.ts       # FTS5 Queries
│   │   └── import.ts       # Codeberg-Migration
│   └── middleware/
│       ├── auth.ts         # Session-Check
│       └── rate-limit.ts
```

### Datenmodell (vereinfacht)
```sql
categories (id, name, slug, sort_order)
shops      (id, name, url, category_id, region, pickup, shipping, description, is_active)
submissions(id, shop_name, shop_url, category_id, description, submitter_email,
            status [pending|approved|rejected], admin_note, feedback_sent)
admin_users(id, username, email, password_hash, is_owner)
sessions   (id [token], admin_user_id, expires_at)

-- Volltext-Suche
CREATE VIRTUAL TABLE shops_fts USING fts5(name, description, region, shipping, content='shops')
```

### API-Endpoints (Auswahl)
**Öffentlich:**
- `GET /api/categories` – Alle Kategorien mit Shop-Count
- `GET /api/categories/:slug` – Shops einer Kategorie
- `GET /api/search?q=` – Volltextsuche (FTS5)
- `POST /api/submissions` – Vorschlag einreichen

**Admin (Session erforderlich):**
- `POST /api/admin/setup` – Erster Admin (nur wenn kein Admin existiert)
- `POST /api/admin/login` / `logout`
- `GET /api/admin/submissions?status=pending` – Offene Vorschläge
- `PATCH /api/admin/submissions/:id` – Annehmen / Ablehnen
- `CRUD /api/admin/shops` + `/categories` + `/users`

### Onboarding-Flow (Erster Admin)
`POST /api/admin/setup` prüft via `SELECT COUNT(*) FROM admin_users`. Falls 0: Admin anlegen
mit `is_owner=1`. Falls >0: `403 Forbidden`. Im Frontend: Setup-Seite nur anzeigen wenn
`/api/admin/me` keinen Owner zurückgibt.

### Sicherheit
- Rate-Limiting: 5 Submissions/IP/Stunde, 10 Login-Versuche/IP/15min
- CORS: Nur `https://dein.shop` (prod) / `localhost:5173` (dev)
- Input-Validation: Zod auf allen Endpoints
- SQL-Injection: Drizzle ORM (Prepared Statements)
- Session-Cookie: `HttpOnly, Secure, SameSite=Strict`

---

## Deployment

### zerops.io

Hosting auf **zerops.io** (kein Docker, keine Container-Konfiguration nötig).

**Services:**
- **Frontend:** Zerops Static Service – Vite-Build (`dist/`) direkt deployen
- **Backend:** Zerops Node.js / Bun Service – Hono-App
- **Datenbank:** SQLite-Datei liegt im persistenten Storage des Backend-Service

**zerops.yml (Grundstruktur):**
```yaml
zerops:
  - setup: deinshop-frontend
    build:
      base: nodejs@22
      buildCommands:
        - npm ci
        - npm run build
      deployFiles: dist
    run:
      base: static

  - setup: deinshop-backend
    build:
      base: bun@1
      buildCommands:
        - bun install --frozen-lockfile
      deployFiles:
        - server/src
        - server/package.json
        - server/bun.lock
    run:
      base: bun@1
      start: bun run server/src/index.ts
      envVariables:
        - DATABASE_URL
        - RESEND_API_KEY
        - SESSION_SECRET
```

**HTTPS:** Zerops stellt automatisch HTTPS-Zertifikate bereit.
**Umgebungsvariablen:** Werden im Zerops-Dashboard konfiguriert (nicht in Dateien).
**SQLite-Backup:** Zerops-internes Backup oder periodischer Export via Cron-Job im Backend.

---

## Datenmigration von Codeberg

Das Codeberg-Repo hat Markdown-Tabellen mit 5 Spalten:
`Name (Markdown-Link) | Region | Abholung | Versand | Produktpalette`

**Import-Strategie:**
1. Markdown-Dateien parsen (Kategorie aus Dateinamen)
2. Markdown-Link `[Name](URL)` extrahieren
3. Länder-Flags (`🇩🇪`) in ISO-Codes (`DE`) übersetzen
4. Kategorien anlegen, dann Shops (UPSERT via URL als Key)
5. FTS5-Index rebuild

Aufruf: `bun run import -- --source ./codeberg-data/`

---

## Offene Design-Entscheidung: Suche

**Frontend-Architekt empfiehlt:** Client-seitig (Fuse.js) – einfacher, no Backend-Roundtrip
**Backend-Architekt empfiehlt:** Server-seitig (FTS5) – mächtiger, kein Bulk-Download

**Empfohlene Lösung (Hybrid):**
- v1: Client-seitig mit Fuse.js (schneller Entwicklungsstart)
- Backend implementiert FTS5-Endpoint trotzdem (braucht keinen Mehraufwand, da Drizzle)
- Migration zu API-Suche wenn Liste >3000 Einträge oder Performance-Probleme

---

## Implementierungsreihenfolge

### Phase 1: Fundament
- [ ] Monorepo-Grundstruktur (bun workspaces: apps/backend, apps/frontend, apps/dashboard, packages/shared)
- [ ] Biome (Linting + Formatting, wie musiccloud.io)
- [ ] packages/shared – gemeinsame TypeScript-Types (Shop, Category, Submission, AdminUser)
- [ ] apps/backend – Hono + Bun + Drizzle + SQLite
- [ ] apps/frontend – React + Vite + Tailwind + shadcn/ui + TanStack Query
- [ ] apps/dashboard – React + Vite + Tailwind + shadcn/ui (Admin-SPA)
- [ ] zerops.yml konfigurieren (3 Services: backend/bun, frontend/static, dashboard/static)
- [ ] Codeberg-Daten importieren

### Phase 2: Public MVP
- [ ] Kategorie-Grid (Homepage)
- [ ] Kategorie-Detailseite mit Shop-Karten
- [ ] Suchfeld + Fuse.js-Suche
- [ ] Vorschlagsformular (mit Captcha)
- [ ] Spenden-Buttons (Header + Footer)
- [ ] Impressum / Datenschutz / Über uns

### Phase 3: Admin-Dashboard
- [ ] Admin-Onboarding (Erster Admin)
- [ ] Login / Session
- [ ] Vorschläge-Review (annehmen/ablehnen + Email)
- [ ] Shop-Verwaltung (CRUD)
- [ ] Kategorie-Verwaltung (CRUD)
- [ ] Benutzer-Verwaltung (Owner-only)

### Phase 4: Polish
- [ ] "Toter Link"-Meldung an Shop-Karten
- [ ] Filter in Kategorie-Ansicht (Region, Versand)
- [ ] SEO (Meta-Tags, Sitemap)
- [ ] Analytics (Umami self-hosted)
- [ ] Vitest Tests für kritische Features

---

## Nicht in v1 (bewusste Entscheidung)

- Bewertungen / Sterne / Kommentare (Moderationsaufwand zu hoch)
- Benutzer-Accounts für Endnutzer (widerspricht dem Prinzip der niedrigen Hürde)
- PWA / Offline-Modus
- Mehrsprachigkeit
- Affiliate-Links (zerstört Vertrauen der Zielgruppe)
