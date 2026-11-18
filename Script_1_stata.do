* Semana 12 - carga de datos

* Fijar la carpeta de trabajo
cd "C:/Users/Crist/Downloads/Fundamentos de programación de análisis económico/Semana_12"

* Cargar el CSV
import delimited "data/raw/casen_reducido.csv", clear

* Revisar los datos
describe   // variables y tipos
*browse     // ver como planilla
* Ver la estructura de la base
describe

* Guardar en formato Stata
save "data/processed/casen.dta", replace

* ===== Bloque B: keep, drop, rename =====

* Quedarse con algunas columnas (como select en R)
use "data/processed/casen.dta", clear
keep region sector ingreso
list in 1/3

* Botar una columna
use "data/processed/casen.dta", clear
drop genero

* Filtrar filas (como filter en R)
use "data/processed/casen.dta", clear
keep if edad > 30 & !missing(edad)
count

* browse

* Renombrar
use "data/processed/casen.dta", clear
rename *, lower

generate ingreso_miles = ingreso / 1000
generate experiencia = edad - educ - 6
replace experiencia = 0 if experiencia < 0
capture noisily generate experiencia = 1

generate pobre_mal = (ingreso < 216000)
generate pobre = (ingreso < 216000) if !missing(ingreso)

tabulate pobre_mal, missing
tabulate pobre, missing


drop pobre_mal

* Forma 1: en dos pasos
gen mujer = 1
replace mujer = 0 if genero == "M"

* Forma 2: en un paso (la pregunta entre paréntesis da 1 o 0)
* generate mujer = (genero == "F")
generate mujer = (genero == "F)


import delimited "data/raw/casen_sucio.csv", clear
