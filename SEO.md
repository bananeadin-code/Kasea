# SEO y Analítica — Kasea Store

Guía corta de lo añadido en la Fase 2 (SEO, Google Analytics, indexación y legal) y de los pasos que quedan en manos del titular.

## 1. Google Analytics 4 (con consentimiento)

- El Measurement ID va en la variable **`VITE_GA_ID`** (ver `.env.example`). ID actual: `G-QT6L4T9PEK`.
- **En Render:** añade `VITE_GA_ID=G-QT6L4T9PEK` en *Environment* y vuelve a desplegar. Los `VITE_` se inyectan en el **build**, así que hay que redeployar tras añadirlo.
- La analítica **solo se activa si el usuario acepta** el banner de cookies (RGPD). Si rechaza, GA no se carga. Si `VITE_GA_ID` está vacío, no hay GA ni banner.
- El `page_view` se dispara en **cada cambio de ruta** (SPA), no solo al cargar.

## 2. Verificar el dominio en Google Search Console

Ve a [search.google.com/search-console](https://search.google.com/search-console) y añade la propiedad **`https://kasea.es`**. Dos opciones para verificar:

- **Opción A — Google Analytics (la más rápida):** si ya tienes GA4 con el mismo Google, en Search Console elige verificación por *Google Analytics* y detectará la etiqueta.
- **Opción B — Registro DNS (recomendada, propiedad de dominio):** elige "Dominio" en Search Console, copia el registro **TXT** que te da Google y añádelo en el DNS de `kasea.es` (mismo panel donde pusiste los registros A/CNAME). Verifica.
- *(Alternativa)* archivo HTML: Search Console te da un `googleXXXX.html`; colócalo en `public/` y despliega. Menos recomendable que las anteriores.

## 3. Enviar el sitemap

Una vez verificado, en Search Console → **Sitemaps** → envía:

```
https://kasea.es/sitemap.xml
```

El sitemap es dinámico: incluye las páginas fijas **y las fichas de producto activas** (se leen de Supabase), así que se mantiene solo al añadir/quitar productos desde el panel. También está referenciado en `public/robots.txt`.

## 4. Indexación

- Las páginas **públicas** son `index, follow`. Las **privadas** (checkout, carrito, cuenta, favoritos, mis pedidos, panel admin) llevan `noindex` a propósito.
- No hay `noindex` global. Render **no** añade cabecera `X-Robots-Tag` por defecto (ver `DEPLOY.md`); si en el futuro cambiaras de hosting, verifica que no la inyecte.

## 5. Dominio canónico

- Versión canónica única: **`https://kasea.es`** (apex, https, sin www). Se define en `src/lib/seo.ts` (`SITE_URL`) — si el dominio cambiara, se actualiza solo ahí.
- El redirect `www → kasea.es` lo gestiona Render (el dominio `www.kasea.es` está configurado como *redirects to kasea.es*).

## 6. Metadatos

Cada página pública define su `title`, `meta description`, canonical absoluta y Open Graph mediante el helper `seo()` en `src/lib/seo.ts`. Para una página nueva:

```ts
head: () => seo({ title: "…", description: "…", path: "/nueva-ruta" }),
```

La imagen para compartir (`og:image`) por defecto es `/brand/hero-kasea.png`; se puede cambiar por página pasando `image`.

## 7. Legal — datos que Julián rellena desde el panel

Los datos de Términos y Política de Privacidad se editan **desde el panel de administración**, sin tocar código: **Admin → Textos de la web**, campos con prefijo **"Legal ·"**:

- Razón social o nombre y apellidos
- NIF / DNI
- Dirección completa
- Email de contacto
- Empresa de envíos (cuando se cierre)
- Plazo de entrega (días)

Al guardar, las páginas `/terminos` y `/privacidad` se actualizan solas, y la **fecha de "última actualización" se pone automáticamente** (con la última edición legal). Mientras un campo esté vacío, la página muestra un aviso "pendiente de completar".

> Los textos legales son una **base orientativa**, no asesoría jurídica. Conviene una revisión legal antes de considerarlos definitivos.
