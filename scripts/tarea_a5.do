* ============================================================
* A5 — Limpieza y descriptivos de CASEN
* Autor: Cristobal Sepulveda      Fecha: 2026-11-17
* Propósito: cargar casen_reducido.csv, crear y etiquetar
*            variables, revisar missing y describir la base.
* ============================================================
* Antes de correr: Stata debe estar parado en la carpeta Semana_12
* (la que tiene data/ y scripts/). Compruébalo con pwd; si no, usa cd.
*   cd "C:/Users/Crist/Downloads/Fundamentos de programación de análisis económico/Semana_12"

* Si Stata quedó parado en scripts/ (pasa al abrir el .do con doble clic),
* sube una carpeta. confirm file falla (_rc distinto de 0) si no ve los datos.
capture confirm file "data/raw/casen_reducido.csv"
if _rc != 0 {
    cd ..
}
confirm file "data/raw/casen_reducido.csv"   // si sigue sin verlos, se detiene con un aviso claro

version 14            // mismas reglas en Stata 14 a 18
clear all            // partir sin datos ni resultados previos
set more off          // que el output no se detenga con --more--
capture mkdir "output"        // crea output/ si no existe (no reclama si ya está)
capture log close             // cierra un log que haya quedado abierto de una corrida anterior
log using "output/tarea_a5.log", replace text


* --- 2. Cargar los datos -------------------------------------
* encoding("utf-8"): sin esto, con version 14, "Ñuble" y "Construcción" se leen mal.
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe
summarize


* --- 3. Crear variables con generate y replace ---------------
* Experiencia potencial de Mincer: años desde que dejó de estudiar (6 = edad de entrada al colegio).
* max(..., 0) evita experiencias negativas.
generate experiencia = max(edad - educ - 6, 0)

* Indicadora de educación superior: 13 o más años de estudio.
* El "if !missing(educ)" evita que un missing en educ se cuente como 1 (el . es mayor que 13).
generate alta_educ = (educ >= 13) if !missing(educ)

* Indicadora de mujer, en dos pasos: generate crea, replace modifica.
generate mujer = 0
replace  mujer = 1 if genero == "F"

* Indicadora de pobreza (umbral del curso: $216.000). Sin ingreso = sin dato, no "no pobre".
generate pobre = (ingreso < 216000) if !missing(ingreso)


* --- 4. Etiquetas ---------------------------------------------
label variable experiencia "Experiencia potencial (años)"
label variable alta_educ   "Educación superior (13+ años)"
label variable mujer       "Mujer"
label variable pobre       "Bajo la línea de pobreza ($216.000)"
label variable ingreso     "Ingreso mensual ($)"

* Etiquetas de valores: el dato sigue siendo 0/1, pero las tablas muestran el nombre.
label define sino_lbl  0 "No" 1 "Sí"
label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values alta_educ sino_lbl
label values pobre     sino_lbl
label values mujer     mujer_lbl

* Categórica numérica desde texto (como factor() en R), para tablas y regresiones.
encode sector, generate(sector_n)

* Niveles educativos agrupados (como case_when() en R).
recode educ (0/8 = 1 "Básica") (9/12 = 2 "Media") (13/max = 3 "Superior"), ///
    generate(nivel_educ)
label variable nivel_educ "Nivel educativo"


* --- 5. Cuidado con los missing -------------------------------
count if missing(ingreso)
count if ingreso > 500000
count if ingreso > 500000 & !missing(ingreso)

* ¿Por qué summarize no se equivoca y count if sí?
*   summarize calcula solo con los valores observados: deja fuera los missing
*   (por eso Obs = 55 y no 60). En cambio, en una comparación como
*   "ingreso > 500000", Stata trata el missing (.) como un número MAYOR que
*   cualquier otro, así que las 5 personas sin ingreso cuentan como "altas"
*   (46 en vez de 41). Toda condición con > o >= sobre una variable con
*   missing debe llevar & !missing(variable).


* --- 6. Descriptivos ------------------------------------------
summarize ingreso educ edad experiencia

* Frecuencias de una categórica
tabulate sector

* Tabla cruzada con porcentajes por fila
tabulate mujer alta_educ, row

* Ingreso medio por nivel educativo y por sector (group_by + summarise en R)
tabstat ingreso, by(nivel_educ) stat(mean sd n)
tabstat ingreso, by(sector) stat(mean sd n)

* summarize ... if por grupo
summarize ingreso if mujer == 1
summarize ingreso if mujer == 0

* Correlación (solo filas completas en las tres variables)
correlate ingreso educ experiencia

* Guardar resultados con scalar ANTES de que r() se sobrescriba con el siguiente comando
summarize ingreso if alta_educ == 1
scalar media_alta = r(mean)
summarize ingreso if alta_educ == 0
scalar media_baja = r(mean)
display "Ingreso medio, 13+ años de educación: " %9.0fc media_alta
display "Ingreso medio, menos de 13 años:      " %9.0fc media_baja
display "Diferencia:                           " %9.0fc media_alta - media_baja

* Guardar la base limpia para la Semana 13
capture mkdir "data/processed"
save "data/processed/casen_limpio.dta", replace


* --- 7. Cerrar la bitácora -------------------------------------
log close

* Interpretación (60 personas; 55 con ingreso informado):
*   El ingreso mensual medio es de $655.291 (de $180.000 a $1.093.000).
*   Más educación se asocia a más ingreso: el promedio pasa de $354.400 (básica)
*   a $576.739 (media) y $777.926 (superior); con 13+ años se gana en promedio
*   $240.890 más que con menos de 13, y la correlación ingreso-educ es 0,68.
*   Educación ($908.857) y Servicios ($788.600) tienen los ingresos medios más altos y
*   Agricultura el más bajo ($447.846). La experiencia casi no se asocia al ingreso
*   (r = -0,09). Son asociaciones descriptivas en una muestra chica, no causas.
