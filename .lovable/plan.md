## Objetivo
Sustituir el fondo del hero móvil (actualmente gradiente + puntos) por un **collage difuminado con fundas reales del carrusel**, manteniendo la legibilidad del texto y el CTA.

## Cambios (solo `src/routes/index.tsx`, bloque `md:hidden` del `Hero`)

1. **Fondo collage**
   - Rejilla absoluta `grid-cols-3 grid-rows-3` que llena todo el hero móvil (`absolute inset-0 -z-10`).
   - Cada celda muestra una de las 9 imágenes ya importadas (`carousel01`–`carousel09`) con `object-cover`.
   - Aplicar `blur-sm`, `scale-110` y `opacity-70` para que actúen como textura ambiental, no como fotos individuales.
   - Ligera animación `animate-float` desincronizada (delays por celda) para dar vida sutil.

2. **Capa de legibilidad**
   - Overlay superior con degradado en tonos de marca:
     `linear-gradient(180deg, color-mix(primary 55%, bg) 0%, color-mix(primary 25%, bg) 45%, var(--color-background) 100%)`.
   - Halos difuminados (primary/accent) en esquinas para mantener el toque "llamativo".
   - `backdrop-blur-[2px]` sobre el bloque de texto para asegurar contraste sin tapar el collage.

3. **Contenido**
   - Se mantiene tal cual: logo, eyebrow, H1, párrafo, botones (Comprar ahora / Ver colección) y la fila de 3 métricas.
   - Ajuste menor de padding superior para que el collage se aprecie por encima antes del logo.

4. **Desktop**
   - Sin cambios: sigue con la foto `heroImg` a pantalla completa.

## Detalle técnico

```text
<section>
  <div className="md:hidden relative overflow-hidden">
    <div className="absolute inset-0 -z-10 grid grid-cols-3 grid-rows-3">
      {[c01..c09].map(img => <img className="h-full w-full object-cover scale-110 blur-sm opacity-70" />)}
    </div>
    <div className="absolute inset-0 -z-10 bg-[linear-gradient(...)]" />
    <div className="halos ..." />
    <div className="container-luxe pt-10 pb-14 text-center">... contenido actual ...</div>
  </div>
  <div className="hidden md:block">... hero desktop actual ...</div>
</section>
```

Sin dependencias nuevas, sin cambios de datos ni de otras secciones.
