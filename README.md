# Kasea Store

Tienda online de **fundas premium para iPhone** (precios en euros). Autosuficiente:
catálogo, carrito, pago con tarjeta, control de stock, correo de confirmación y
panel de administración propios. **Sin dependencia de Shopify.**

- **Fundas de catálogo**: producto normal con precio y stock.
- **Funda personalizada**: el cliente sube su imagen, añade texto y elige modelo;
  se fabrica bajo pedido (sin stock).
- **Entrega**: envío a domicilio (tarifa configurable, gratis desde un importe) o
  **recoger en tienda** (sin coste).
- **Compra como invitado** (sin cuentas de cliente).

---

## Tecnología

- **Frontend + servidor**: [TanStack Start](https://tanstack.com/start) (React 19,
  SSR + server functions) sobre **Nitro**. Vite 8. Tailwind 4 + shadcn/ui.
- **Base de datos + auth**: [Supabase](https://supabase.com) (Postgres, RLS, Auth,
  Storage).
- **Pagos**: [Stripe](https://stripe.com) Checkout (hosted). La sesión de pago y el
  webhook se procesan en el servidor (nunca claves secretas en el cliente).
- **Correo**: [Resend](https://resend.com).
- Gestor de paquetes: **bun** (hay `bun.lock`); también funciona con `npm`.

## Estructura

```
src/
  routes/                 páginas (file-based routing)
    _authenticated/       panel de administración (/admin/*), protegido
    api.stripe-webhook.ts webhook de Stripe (servidor)
    checkout.tsx          checkout (envío/recogida + Stripe)
  lib/
    catalog.functions.ts  lectura pública del catálogo (Supabase)
    checkout.functions.ts crea la sesión de pago (Stripe, servidor)
    admin-catalog.functions.ts  CRUD admin (productos, pedidos, ajustes)
    cart.ts / favorites.ts  estado de carrito y favoritos (localStorage)
    email.ts              correo de confirmación (Resend)
  integrations/supabase/  clientes y tipos de Supabase
supabase/migrations/      esquema + seed (SQL)
public/brand/             imágenes de marca (logo, hero, carrusel…)
scripts/                  utilidades (seed desde Shopify, opcional)
```

## Requisitos

- Node 20+ (probado con Node 25).
- Un proyecto de Supabase y cuentas de Stripe y Resend (ver `DEPLOY.md`).

## Puesta en marcha (local)

1. Instala dependencias:
   ```bash
   npm install
   ```
2. Copia el archivo de entorno y rellénalo:
   ```bash
   cp .env.example .env
   ```
   Necesitarás como mínimo las variables de **Supabase**. Para probar el pago,
   añade las claves **test** de Stripe. Ver la tabla completa en `DEPLOY.md`.
3. Aplica las migraciones a tu Supabase (esquema + productos). Ver `DEPLOY.md §3`.
4. Arranca el servidor de desarrollo:
   ```bash
   npm run dev
   ```

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run dev` | Servidor de desarrollo. |
| `npm run build` | Build de producción (Nitro). Para Render: `NITRO_PRESET=node-server npm run build`. |
| `npm run preview` | Previsualiza el build. |
| `npm run lint` | ESLint. |

## Variables de entorno

Todas están documentadas en [`.env.example`](.env.example). Resumen:

- **Públicas** (`VITE_…`): Supabase URL/anon key, Stripe publishable key.
- **Secretas** (servidor): `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`,
  `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`.
- La **tarifa y el umbral de envío** NO son variables: se editan en el panel de
  administración (tabla `shop_settings`).

## Documentación

- **`DEPLOY.md`** — desplegar (Render), configurar Supabase/Stripe/Resend y pasar
  de test a producción.
- **`HANDOVER.md`** — cómo usa el dueño el panel de administración.
