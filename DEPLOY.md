# Despliegue y configuración — Kasea Store

Esta guía cubre cómo poner en marcha la tienda: variables de entorno, la
pasarela de pago (Stripe) en **modo test** y, más adelante, el paso a producción.

> Estado del proyecto: en construcción por fases. Esta guía se irá ampliando.
> Hoy cubre **entorno + Stripe (modo test)**. El webhook, el correo y el
> despliegue final se documentan en las fases siguientes.

---

## 1. Variables de entorno

Copia `.env.example` a `.env` y rellena los valores. El `.env` **no se sube**
al repositorio (está en `.gitignore`). En producción, estas variables se
configuran en el panel del hosting y en Supabase, no en un archivo.

Distinción importante:

- **Públicas** (prefijo `VITE_`): viajan al navegador. Sin problema.
- **Secretas** (sin `VITE_`): solo en el servidor. **Nunca** en el cliente.

| Variable | Tipo | Para qué |
|---|---|---|
| `VITE_SUPABASE_URL` / `SUPABASE_URL` | pública | URL del proyecto Supabase |
| `VITE_SUPABASE_PUBLISHABLE_KEY` / `SUPABASE_PUBLISHABLE_KEY` | pública | Lectura del catálogo (respeta RLS) |
| `SUPABASE_SERVICE_ROLE_KEY` | **secreta** | Tareas de servidor (webhook, seed). Bypassa RLS |
| `VITE_STRIPE_PUBLISHABLE_KEY` | pública | Clave publicable de Stripe |
| `STRIPE_SECRET_KEY` | **secreta** | Crear la sesión de pago |
| `STRIPE_WEBHOOK_SECRET` | **secreta** | Verificar el webhook (Fase 4) |
| `RESEND_API_KEY` | **secreta** | Correo de confirmación (Fase 4) |
| `SHIPPING_FREE_THRESHOLD_CENTS` | config | Envío gratis desde este importe (5500 = 55 €) |
| `SHIPPING_FLAT_CENTS` | config | Tarifa de envío por debajo del umbral (399 = 3,99 €) |
| `SITE_URL` | config | URL del sitio, para las redirecciones de Stripe |

---

## 2. Stripe en modo TEST (pagos con tarjeta)

> ⚠️ Trabajamos **siempre primero en modo test**. Con las claves de test **no
> se cobra dinero real**: se usan tarjetas de prueba. No pongas claves `live`
> hasta haber validado todo el flujo.

### 2.1. Crear la cuenta de Stripe

1. Entra en <https://dashboard.stripe.com/register> y crea una cuenta con el
   correo del negocio.
2. Como país de la empresa elige **España** (la moneda será EUR).
3. Puedes empezar a probar **sin** completar la activación de la cuenta: el
   **modo test** funciona desde el primer momento. La activación (datos
   fiscales, cuenta bancaria) solo hace falta para cobrar de verdad (modo live).

### 2.2. Obtener las claves de TEST

1. En el dashboard de Stripe, asegúrate de que el interruptor **"Modo test"**
   (arriba a la derecha) está **activado**.
2. Ve a **Desarrolladores → Claves de API**
   (<https://dashboard.stripe.com/test/apikeys>).
3. Copia:
   - **Clave publicable** → empieza por `pk_test_...`
   - **Clave secreta** → empieza por `sk_test_...` (pulsa "Revelar")

### 2.3. Ponerlas en el entorno

En tu `.env` local:

```bash
VITE_STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_SECRET_KEY="sk_test_..."
SITE_URL="http://localhost:8080"   # o el puerto donde corra tu dev server
```

> No hace falta pasarme las claves a mí: las pones tú en tu `.env`, que no se
> sube a ningún sitio. Yo dejé todo cableado para leerlas del entorno.

### 2.4. Probar un pago de prueba

1. Arranca el proyecto (`npm run dev`) con el catálogo ya disponible en la base
   de datos (ver nota de "staging" más abajo).
2. Añade un producto a la bolsa y ve a **Finalizar compra → Pagar con tarjeta**.
3. Se abre Stripe Checkout. Usa una **tarjeta de prueba**:
   - Número: `4242 4242 4242 4242`
   - Caducidad: cualquier fecha futura (ej. `12/34`)
   - CVC: cualquiera (ej. `123`) · Código postal: cualquiera
4. Al confirmar, Stripe te devuelve a `/checkout/exito`.
   - Más tarjetas de prueba: <https://stripe.com/docs/testing>

### 2.5. Webhook de Stripe (confirma el pago → crea el pedido y descuenta stock)

El pago se confirma en el **servidor** mediante un webhook. Cuando Stripe avisa
de que el pago se completó, nuestro endpoint `/api/stripe-webhook`:
crea el pedido, **descuenta el stock de forma atómica (sin sobreventa)** y
envía el correo de confirmación.

Necesita dos secretos de servidor añadidos a tu entorno:

```bash
STRIPE_WEBHOOK_SECRET="whsec_..."        # se obtiene al crear el webhook (abajo)
SUPABASE_SERVICE_ROLE_KEY="sb_secret_..."# Supabase > Settings > API > service_role
```

**Para probar en local** (con la CLI de Stripe, recomendado):

1. Instala la CLI: <https://stripe.com/docs/stripe-cli>
2. `stripe login`
3. Reenvía los eventos a tu servidor local:
   ```bash
   stripe listen --forward-to localhost:8080/api/stripe-webhook
   ```
4. La CLI imprime un `whsec_...`: pégalo en `.env` como `STRIPE_WEBHOOK_SECRET`
   y reinicia `npm run dev`.
5. Haz un pago de prueba: verás en Supabase el pedido creado y el stock
   descontado.

**En producción:** en el dashboard de Stripe → **Desarrolladores → Webhooks →
Add endpoint**, URL `https://TU-DOMINIO/api/stripe-webhook`, evento
`checkout.session.completed`. Copia el **signing secret** (`whsec_...`) a la
variable `STRIPE_WEBHOOK_SECRET` del hosting.

> El webhook es **idempotente**: si Stripe reintenta el aviso, no se duplica el
> pedido ni se descuenta el stock dos veces.

### 2.6. Correo de confirmación (Resend)

1. Crea una cuenta gratis en <https://resend.com>.
2. Para pruebas puedes enviar desde `onboarding@resend.dev`. Para producción,
   **verifica tu dominio** en Resend y usa un remitente propio.
3. Copia tu **API key** y configúrala:
   ```bash
   RESEND_API_KEY="re_..."   # tu API key va SOLO en .env / variables del hosting
   RESEND_FROM_EMAIL="Kasea Store <pedidos@kasea.com>"
   ```

> Si `RESEND_API_KEY` no está configurada, el pago y el pedido **funcionan
> igual**; simplemente no se envía el correo (se registra un aviso).

---

## 3. Supabase (base de datos)

Como el despliegue es **fuera de Lovable** (en Render), conviene usar un proyecto
de **Supabase que controles tú**, y aplicar las migraciones ahí.

1. Crea un proyecto en <https://supabase.com> (el plan gratis sirve para empezar).
2. **Aplica las migraciones** de la carpeta `supabase/migrations/` (crean las
   tablas y siembran los 68 productos). Dos formas:
   - **SQL Editor** del panel de Supabase: abre cada archivo `.sql` en orden por
     nombre y ejecútalo, o
   - **Supabase CLI**: `supabase link` a tu proyecto y `supabase db push`.
3. **Crea el usuario administrador** y dale el rol admin:
   - En Supabase → Authentication → Add user (con tu email y contraseña).
   - En SQL Editor:
     ```sql
     insert into public.user_roles (user_id, role)
     values ('<UUID-del-usuario>', 'admin');
     ```
     (el UUID está en Authentication → Users).
4. Copia a tu `.env` (y luego al hosting):
   - `SUPABASE_URL` / `VITE_SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY` / `VITE_SUPABASE_PUBLISHABLE_KEY` (anon key)
   - `SUPABASE_SERVICE_ROLE_KEY` (secreta, solo servidor)
5. **Storage**: crea (si no existe) un bucket público llamado **`site-images`**
   (se usa para imágenes de productos y diseños personalizados).

> Verifícalo en local con `npm run dev` antes de desplegar.

---

## 4. Despliegue en Render

El proyecto necesita un **servidor Node** (SSR + server functions + webhook), y
**Render lo cubre entero** (no hace falta Netlify aparte).

1. En Render → **New → Web Service**, conecta el repositorio de GitHub.
2. Configura:
   - **Environment**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `node .output/server/index.mjs`
3. **Variables de entorno** del servicio (Render → Environment):
   - `NITRO_PRESET` = `node-server`  ← **imprescindible** (genera el servidor Node).
   - `SITE_URL` = `https://tu-servicio.onrender.com` (o tu dominio).
   - Todas las de Supabase, Stripe y Resend (ver §1). Render define `PORT` solo.
4. Deploy. Render construye y arranca el servidor; la web queda en la URL del
   servicio.

> Nota: sin `NITRO_PRESET=node-server`, el build sale para Cloudflare Workers y el
> "Start Command" de Node no funcionará. También puedes ponerlo en el Build
> Command: `NITRO_PRESET=node-server npm run build`.

### 4.1. Webhook de Stripe en producción

En el dashboard de Stripe → Webhooks → Add endpoint:
`https://tu-servicio.onrender.com/api/stripe-webhook`, evento
`checkout.session.completed`. Copia el `whsec_...` a `STRIPE_WEBHOOK_SECRET` en Render.

### 4.2. Dominio propio

En Render → Settings → Custom Domains, añade tu dominio y sigue los pasos de DNS.
Actualiza `SITE_URL` y el endpoint del webhook al dominio final.

---

## 5. Pasar de TEST a PRODUCCIÓN (cobros reales)

Cuando el flujo completo esté validado en modo test:

1. En Stripe, **activa la cuenta** (datos fiscales + cuenta bancaria).
2. Cambia el interruptor de Stripe a **modo live** y copia las claves `pk_live_…`
   y `sk_live_…`.
3. En Render, sustituye `VITE_STRIPE_PUBLISHABLE_KEY` y `STRIPE_SECRET_KEY` por las
   `live`, y crea un **webhook nuevo en modo live** (nuevo `whsec_…`).
4. Verifica un pedido real pequeño antes de anunciar la tienda.
