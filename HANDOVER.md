# Guía del panel de administración — Kasea Store

Esta guía es para el **dueño de la tienda**: cómo gestionar productos, stock,
pedidos y ajustes desde el panel. No hace falta saber programar.

---

## 1. Entrar al panel

1. En la web, arriba a la derecha, pulsa el icono de **acceso** (👤).
2. Introduce tu **correo y contraseña** (o "Continuar con Google").
3. Entrarás en el panel: **kasea-store.com/admin** *(cambia el dominio por el tuyo)*.

> Solo tú (administrador) puedes entrar. Los clientes **no** tienen cuenta ni
> pueden acceder al panel: compran como invitados.
>
> Si olvidas la contraseña, se restablece desde Supabase (o pídeselo a quien
> gestione el proyecto).

---

## 2. Productos

**Panel → Productos.**

- **Crear**: botón **"Nuevo producto"**. Rellena nombre, descripción, **precio (€)**,
  **stock**, estado e imagen. Guarda.
- **Editar**: icono del lápiz en cada fila. Cambia precio, stock, texto, imagen…
- **Imagen**: "Subir imagen" (desde tu ordenador) o pega una URL.
- **Stock**: es el número de unidades disponibles. Cuando llega a 0, el producto
  aparece como agotado y **no se puede comprar** (nunca se vende de más).
- **Estado**:
  - *Publicado*: visible en la tienda.
  - *Borrador*: oculto (para prepararlo sin publicarlo).
  - *Archivado*: retirado.
- **Ordenar**: flechas ▲▼ para cambiar el orden en que aparecen en la tienda.
- **Eliminar**: icono de la papelera (pide confirmación).

> **Funda personalizada**: aparece marcada como "Personalizada". No tiene stock
> (se hace bajo pedido). Para cambiar su **precio**, edítala como cualquier producto.

---

## 3. Pedidos

**Panel → Pedidos.**

- Lista de pedidos, del más reciente al más antiguo. Pulsa uno para desplegarlo.
- Verás: **datos del cliente**, si es **envío a domicilio** (con dirección) o
  **recoger en tienda**, los **artículos**, y los **totales**.
- **Estado del pedido**: cámbialo con el desplegable (Pagado → Enviado/Entregado,
  Cancelado, Reembolsado). Sirve para tu organización.
- **Aviso "Revisar"** (naranja): significa que, por una compra casi simultánea, un
  producto se quedó sin stock justo al pagar. Revisa ese pedido (quizá haya que
  reponer o contactar al cliente).
- **Diseño personalizado**: en los pedidos de funda personalizada verás la
  **vista previa del diseño**, el **modelo** de iPhone, el texto, la fuente y el
  color — todo lo necesario para **fabricarla**.

---

## 4. Ajustes de envío

**Panel → Ajustes.**

- **Tarifa de envío (€)**: lo que paga el cliente por el envío a domicilio.
- **Envío gratis a partir de (€)**: importe del pedido desde el cual el envío es
  gratis.
- **Correo para avisos de pedidos**: dirección donde recibirás un aviso con cada
  nueva orden. Si es una **funda personalizada**, el correo incluye el **diseño**
  (modelo, texto, fuente, color y enlace a la imagen) para fabricarla. Déjalo
  vacío si no quieres recibir avisos.
- Los cambios se aplican al instante. (La recogida en tienda es siempre gratis.)

---

## 5. Imágenes de la web

- **Panel → Carrusel**: gestiona las imágenes de la galería de la portada.
- **Panel → Categorías**: cambia la imagen de la categoría destacada de la home.

---

## 6. Cómo compra un cliente (resumen)

1. Explora el catálogo, marca **favoritos** (❤) y añade a la **bolsa**.
2. En **Finalizar compra** elige **envío a domicilio** o **recoger en tienda**.
3. Paga con tarjeta en la pasarela segura de **Stripe**.
4. Al confirmarse el pago: se crea el pedido, se **descuenta el stock** y el
   cliente recibe un **correo de confirmación** automáticamente.

Para fundas personalizadas, el cliente diseña en **/personalizar** y su diseño
llega contigo en el pedido.
