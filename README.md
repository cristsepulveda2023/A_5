# A5 — Do-file de limpieza y descriptivos de CASEN en Stata

**Fundamentos de Programación para Análisis Económico · UdeC-EAN**
Módulo IV · Semana 12 · Actividad formativa A5
Autor: Cristóbal Sepúlveda

## Objetivo

Escribir un do-file que corra de principio a fin sin intervención y deje un `.log`
con la limpieza y los descriptivos de una muestra de la CASEN, trasladando a Stata
lo que ya hice en R.

## Estructura del repositorio

```
├── scripts/
│   └── tarea_a5.do          # el do-file de la tarea
├── output/
│   └── tarea_a5.log         # la bitácora que genera el do-file
├── data/
│   ├── raw/
│   │   └── casen_reducido.csv   # datos de entrada (60 personas)
│   └── processed/
│       └── casen_limpio.dta     # base limpia que sale del do-file (para la Semana 13)
└── Script_1_stata.do        # práctica de la clase (Sesión 1)
```

## Cómo correrlo

1. Abrir Stata (versión 14 o superior).
2. Abrir `scripts/tarea_a5.do` en el Do-file Editor.
3. Ejecutar el archivo completo con **Ctrl + D**, sin nada seleccionado.

Si se abre desde `scripts/`, el do-file sube solo a la carpeta del proyecto antes
de cargar los datos.

## Qué hace el do-file

1. **Encabezado y bitácora:** `clear all`, `set more off`, `log using`.
2. **Carga:** `import delimited` con `encoding("utf-8")` para leer bien las tildes y la ñ.
3. **Variables nuevas:** experiencia potencial de Mincer (`max(edad - educ - 6, 0)`),
   las indicadoras `alta_educ` (13+ años), `mujer` (creada con `generate` + `replace`)
   y `pobre` (ingreso < $216.000).
4. **Etiquetas:** de variables y de valores; `encode` del sector y `recode` del nivel educativo.
5. **Missing:** `ingreso` tiene 5 valores faltantes. Para Stata el missing (`.`) es mayor
   que cualquier número, así que `count if ingreso > 500000` da 46 en vez de 41.
   Se corrige con `& !missing(ingreso)`.
6. **Descriptivos:** `summarize`, `tabulate`, tabla cruzada, `tabstat` por grupo,
   `correlate` y un resultado guardado con `scalar`.

## Principales resultados

| Nivel educativo | Ingreso medio | N |
|---|---:|---:|
| Básica (0–8 años) | $354.400 | 5 |
| Media (9–12 años) | $576.739 | 23 |
| Superior (13+ años) | $777.926 | 27 |
| **Total** | **$655.291** | **55** |

- Más educación se asocia a más ingreso: con 13 años o más, el ingreso medio es
  $240.890 mayor, y la correlación ingreso-educación es 0,68.
- Educación ($908.857) y Servicios ($788.600) son los sectores con mayor ingreso
  medio, y Agricultura ($447.846) el de menor ingreso.
- La experiencia potencial casi no se asocia al ingreso (r = −0,09).
- Son asociaciones descriptivas en una muestra pequeña, no relaciones causales.



