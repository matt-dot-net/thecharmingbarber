# The Charming Barber

![The Charming Barber — logo etched on the shop window](site/img/banner-1280w.jpg)

Static marketing website for **The Charming Barber**, a one-chair barbershop in
Mechanicsburg, PA, owned and operated by Hannah Stucky.

The site is plain HTML/CSS/JS (no framework, no build step) served by nginx in a
Docker container, deployed to Azure App Service at
<https://thecharmingbarber.com>.

## Pages

| URL | File | Purpose |
|-----|------|---------|
| `/` | `site/index.html` | Home — hero, new-client notice, key info, Instagram callout |
| `/services` | `site/services.html` | Service menu, durations, and pricing |
| `/about` | `site/about.html` | Hannah's bio and shop photos |
| `/faq` | `site/faq.html` | Frequently asked questions (accordion) |
| `/404` | `site/404.html` | Custom not-found page |

Clean URLs (`/services` rather than `/services.html`) are handled by nginx
`try_files`.

## Project structure

```
.
├── Dockerfile            # nginx:alpine + static files
├── nginx.conf            # server config: clean URLs, caching, gzip, headers
├── README.md
└── site/                 # document root (served at /)
    ├── index.html
    ├── about.html
    ├── faq.html
    ├── services.html
    ├── 404.html
    ├── css/
    │   └── styles.css
    ├── js/
    │   └── main.js       # hamburger nav + FAQ accordion
    ├── fonts/            # self-hosted woff2 (Lato, Playfair Display)
    └── img/              # logos, favicon, and responsive photo sets
```

## Local development

The site is fully static, so any static file server works. Two easy options:

```bash
# From the repo root, using Node's "serve":
npx serve site

# ...or build and run the actual container (see below).
```

Then open the printed URL (e.g. <http://localhost:3000>).

> Note: with a plain file server, the clean URLs (`/services`) won't resolve —
> use the `.html` extension locally, or run the Docker image to test the real
> `try_files` behavior.

## Build & run with Docker

```bash
docker build -t thecharmingbarber .
docker run --rm -p 8080:80 thecharmingbarber
# open http://localhost:8080
```

The image is `nginx:alpine` with `site/` copied to `/usr/share/nginx/html/` and
`nginx.conf` installed as the default server config.

## Deployment

Production runs on **Azure App Service** as a custom container.

- The container listens on port **80**.
- HTTP/2 is enabled at the App Service level (Configuration → General settings →
  HTTP version → 2.0), not in nginx.
- After pushing a new image, App Service may take a minute or two to cycle the
  container before changes appear.

## Conventions & maintenance notes

### Cache-busting (`?v=N`)
CSS and JS are cached for 30 days (`public, immutable`). To force browsers to
pick up a change, bump the version query string in **every** HTML file that
references the changed file:

- Changed `css/styles.css` → bump `styles.css?v=N` everywhere (currently `v=6`).
- Changed `js/main.js` → bump `main.js?v=N` everywhere (currently `v=3`).

HTML itself is served `no-cache` (revalidated every load) so content edits go
live immediately. Images and fonts are cached 30 days by filename — when
replacing a photo, either keep changes infrequent or rename the file.

### Responsive images
Photos ship in multiple widths and are selected via `srcset`:

- **Hero banner**: `banner-{480,640,720,768,1280,1920,2560}w.jpg`, `sizes="100vw"`.
- **Header logo**: `TCB-Logo-1-{54,108,162}w.webp`, density descriptors (`1x/2x/3x`).
- **Gallery / portraits**: `{name}-{400,800,1200}w.JPG`.

When adding a new photo, export the same width ladder and keep the 3:2 (banner)
or source aspect ratio.

### Fonts
Lato (400/700) and Playfair Display (variable) are **self-hosted** under
`site/fonts/` and declared via `@font-face` at the top of `styles.css`. Playfair
is a single variable file covering the 400–700 weight range. The two most-used
faces are preloaded in each page's `<head>`.

### Common content edits
- **Hours / prices / services** — `site/services.html` and the "Key Info" card
  in `site/index.html` (top three prices are mirrored there).
- **New-client waitlist link** — a Google Form URL; search for
  `docs.google.com/forms` across the HTML files to update all occurrences.
- **Booking link** — Resurva URL (`thecharmingbarber.resurva.com/availability`).
- **Open Graph / link-preview** — `og:*` meta tags in each page's `<head>`;
  images point at `img/banner-1280w.jpg`.

### Accessibility
Each page has exactly one `<h1>`, a sequential heading order, and a `<main>`
landmark. Keep these intact when restructuring — visually-hidden headings use
the `.sr-only` utility class.
