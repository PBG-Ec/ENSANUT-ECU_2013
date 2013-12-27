******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
**************Tomo 1**********************************************************
**************Capítulo: Aproximación a enfermedades***************************
**************Crónicas no transmisibles : Hipertensión************************
******************************************************************************
/*
Coordinadora de la Investigación ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboración: Natalia Romero  natalia.romero.15@gmail.com
  Pablo darío Lozano Ruiz,Jaqueline Cevallos
  Philippe Belmont Guerrón, MSP-ENSANUT philippebelmont@gmail.com
  Aprobación: Wilma Freire

Para citar esta sintaxis en una publicación usar:
Freire, W.B., M-J. Ramirez, P. Belmont, M-J. Mendieta, P. Piñeiros, M.K. Silva,
	N. Romero, K. Sáenz, P. Piñeiros, L.R. Gómez, R. Monge. Encuesta Nacional
	de Salud y Nutrición del Ecuador ENSANUT-ECU TOMO I. Salud y Nutrición.
	Quito, Ecuador: MSP / INEC, 2013.

A BibTeX entry for LaTeX users is

@book{freire_encuesta_2013,
	address = {Quito, Ecuador},
	title = {Encuesta Nacional de Salud y Nutrición del Ecuador {ENSANUT-ECU}
	{TOMO} I. Salud y Nutrición},
	language = {Es},
	publisher = {{MSP} / {INEC}},
	author = {Freire, {W.B.} and Ramirez, M-J. and Belmont, P. and Mendieta,
	M-J. and Silva, {M.K.} and Romero, N. and Sáenz, K. and Piñeiros,
	P. and Gómez, {L.R.} and Monge, R.},
	year = {2013}
}

*/

******************************************************************************
*Preparación de base:
*Variables de identificadores & svyset
*Ingresar el directorio de las bases:
cd ""
set more off

*Identificador de personas para merge de datos:

global bases "ensanut_f10_antropometria ensanut_f2_mef ensanut_f7_fact_riesgo_mayores"
foreach x of global bases{
	use `x', clear
	cap drop id*
*Identificador de Hogar - vivienda
	gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
	format idhog %20.0f
	gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
	format idviv %20.0f
	lab var idhog "Identificador de hogar"
	lab var idviv "Identificador de vivienda"
*Identificador de sector :
	gen double idsector = ciudad*10^6+zona*10^3+sector
	lab var idsector "Identificador de sector"
*Identificador de personas
	 cap gen idptemp=hogar*10^2+persona
	 cap egen idpers=concat (idviv idptemp),format(%20.0f)
	 cap drop idptemp idptemp
	 cap lab var idpers "Identificador de persona"
	save `x', replace
	}

********************************************************************************

use ensanut_f10_antropometria.dta,clear

*Variables de cruce:
merge 1:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 edadanio quint nbi pd08b)
drop if _merge==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"

*Variable de embarazada:
merge 1:1 idpers using ensanut_f2_mef.dta,keepusing(f2200)
drop if _merge==2
drop _merge


*Svyset:
svyset idsector [pweight=pw], strata (area)

******************************************************************************
****Analisis descriptivo de Hipertensión Mayores de 18 años

*Promedio de mediciones de antropometría repetidas mas cercanas
****Presion Sistolica pres1a pres2a pres3a
gen presfs=.
*Umbral de inclusion medida 1 y 2 :
replace presfs=(pres1a+pres2a)/2 if pres1a-pres2a<0.5
*Media de los 2 valores mas cercanos
replace presfs=abs(pres1a+pres2a)/2 ///
  if (abs(pres1a-pres2a)<abs(pres1a-pres3a)) & ///
  (abs(pres1a-pres2a)<abs(pres2a-pres3a))
replace presfs=abs(pres1a+pres3a)/2 ///
  if (abs(pres1a-pres3a)<abs(pres1a-pres2a)) & ///
  (abs(pres1a-pres3a)<abs(pres2a-pres3a))
replace presfs=abs(pres2a+pres3a)/2 ///
  if (abs(pres2a-pres3a)<abs(pres1a-pres2a)) & ///
  (abs(pres3a-pres3a)<abs(pres1a-pres3a))
*Coreccion missings
replace presfs=. if presfs==999

****Presion Diastolica pres1b pres2b pres3b
gen presfd=.
*Umbral de inclusion medida 1 y 2 :
replace presfd=(pres1b+pres2b)/2 if pres1b-pres2b<0.5
*Media de los 2 valores mas cercanos
replace presfd=abs(pres1b+pres2b)/2 ///
  if (abs(pres1b-pres2b)<abs(pres1b-pres3b)) & ///
  (abs(pres1b-pres2b)<abs(pres2b-pres3b))
replace presfd=abs(pres1b+pres3b)/2 ///
  if (abs(pres1b-pres3b)<abs(pres1b-pres2b)) & ///
  (abs(pres1b-pres3b)<abs(pres2b-pres3b))
replace presfd=abs(pres2b+pres3b)/2 ///
  if (abs(pres2b-pres3b)<abs(pres1b-pres2b)) & ///
  (abs(pres3b-pres3b)<abs(pres1b-pres3b))
*Coreccion missings
replace presfd=. if presfd==999


*Poner missing a  casos de embarazados f2200==1
replace presfs=. if f2200==1
replace presfd=. if f2200==1

*Hipertensión y valores outliers
replace  presfs=. if (presfs<30 |  presfs>280)
replace  presfd=. if (presfd<30 | presfd>280)
gen  presion =0
replace  presion=1 if ((presfs>30 &  presfs<=280 & presfd>=30 & presfd<=280))
label variable  presion   "Presión"
label define  pre 0 "outlier no medible" 1 "medible"
label values  presion pre

*Hipertensión mayores de 18 años:
gen  hipertension=0
replace hipertension=1 if (presion==1 & (presfs>=140|presfd>=90))
replace hipertension=2 if (presion==1 &((presfd>=80 & presfd<90) | ///
  (presfs >=130 & presfs<140)))
replace hipertension=. if (edadanio==. | presion==0)
replace hipertension=. if (edadanio<18 | edadanio==.)
lab var hipertension "*Hipertensión mayores de 18 años"
label define hip 0 "no" 1 "si" 2 "prehipertenso"
label value hipertension hip
*Poner missing a  casos de embarazados f2200==1
replace hipertension=. if f2200==1

*Dummy >= 18 años
gen d18sup=.
replace d18sup=1 if(edadanio>17 & edadanio!=.)
replace d18sup=. if(edadanio <18)

svy: tabulate d18sup hipertension, obs count  format(%17.4f)  cellwidth(20)
svy: tabulate d18sup hipertension, row ci  format(%17.4f)  cellwidth(20)


*Edad en decenios
gen gruped10=int(edadanio/10)+1
lab var  gruped10 "Grupos de edad en decenios"
lab def gr10 2 "(18 < 20)" 3 "(20 < 30)" 4 "(30 < 40)" 5 "(40 < 50)" ///
  6 "(50 < 60)"
replace gruped10=. if gruped10==7
lab val gruped10 gr10
replace gruped10=.  if(gruped10==1 | edadanio<18)

svy: tabulate gruped10 hipertension,  obs count   format(%17.4f) cellwidth(20)
svy: tabulate gruped10 hipertension,  row ci  format(%17.4f) cellwidth(20)

*Estidisticas  descriptivas TASF TADF por sexo y edad (grued10)
tabout  gruped10 pd02 using Prsis_gr10_sex.txt, ///
  replace c(mean presfs lb ub) f(1.1) svy sum
tabout  gruped10 [aw= pw] using Prsis_gr10_.txt, ///
  append c( min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
tabout  gruped10 [aw= pw] if pd02==1 using Prsis_gr10_sex1.txt, ///
  append c( min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
tabout  gruped10 [aw= pw] if pd02==2 using Prsis_gr10_sex2.txt, ///
  append c( min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
tabout  gruped10 pd02  using Prsis_gr10_sex.txt, ///
  append c(mean presfd lb ub) f(1.1) svy sum
tabout  gruped10 [aw= pw]  using Prsis_gr10_.txt, ///
  append c( min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum
tabout  gruped10 [aw= pw] if pd02==1 using Prsis_gr10_sex1.txt, ///
  append c( min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum
tabout  gruped10 [aw= pw] if pd02==2 using Prsis_gr10_sex2.txt, ///
  append c( min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum


**Tabla Hipertensión  por grued10 y por genero
*total
svy: tabulate gruped10 hipertension, row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate gruped10 hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate gruped10 hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)

**Tabla Hipertensión  por grupo_etnicos y por genero
*total
svy: tabulate  gr_etn hipertension, ///
  row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate  gr_etn hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate  gr_etn hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)

**Tabla Hipertensión  por zonas_planificacion y por genero
*Total
svy: tabulate zonas_planificacion  hipertension, ///
  row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate zonas_planificacion  hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate zonas_planificacion  hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)

**Tabla Hipertension  por mpres y por genero
*total
svy: tabulate  mpres hipertension, row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate  mpres hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate  mpres hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)

**Tabla Hipertension  por Quintil Economico y por genero
*Total
svy: tabulate  quint hipertension, row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate  quint hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate  quint hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)


**Tabla Hipertension  por subreg y por genero
*Total
svy: tabulate  subreg hipertension, row obs ci  format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate  subreg hipertension, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate  subreg hipertension, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)

save ensanut_f10_antropometria_aecnt.dta, replace

******************************************************************************
****Antecedentes de presión alta mayores de 20 años
*Bases antropometria, factores de riesgos hombres mujeres 20_59 años:
*ensanut_f7_fact_riesgo_mayores.dta ensanut_f10_antropometria.dta

use ensanut_f10_antropometria_aecnt.dta, clear
merge 1:1 idpers using  ensanut_f7_fact_riesgo_mayores.dta, ///
  keepusing(f7502 f7501 f75031 f75032 f75033 f75034 f75035 f7504)
drop if _merge==2
drop _merge

gen edrec=.
replace edrec=1 if edadanio >= 18
replace edrec=2 if edadanio >= 40
label variable  edrec   "Edad recodificada (dos grupos)"
label define  edr 1 "18 a 39 años" 2 "40 a 59 años"
label values edrec edr

svyset idsector [pweight=pw], strata (area)

* Hipertension para edad mayor cuadro de Total Hombres Mujeres
*Total
svy: tabulate edrec hipertension, row obs ci format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate edrec hipertension, ///
  subpop(if pd02==1) row obs ci format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate edrec hipertension, ///
  subpop(if pd02==2) row obs ci format(%17.4f) cellwidth(20)

* Para edad mayor hipertension por Diagnostico previo de TA por
*medico por genero
*Total
svy: tabulate edrec f7502, row obs ci format(%17.4f) cellwidth(20)
*Hombre
svy: tabulate edrec f7502, ///
  subpop(if pd02==1) row obs ci format(%17.4f) cellwidth(20)
*Mujer
svy: tabulate edrec f7502, ///
  subpop(if pd02==2) row obs ci format(%17.4f) cellwidth(20)

* Hipertension por hipertension dignostico por subreg
levelsof subreg, local(levels)
foreach i of local levels {
	svy: tabulate hipertension f7502, ///
	  subpop(if (subreg== `i')) row obs ci format(%17.4f) cellwidth(20)
	}


* Hipertension por  dignostico de hipertension por zonas_planificacion
levelsof zonas_planificacion, local(levels)
foreach i of local levels {
	svy: tabulate hipertension f7502, ///
	  subpop(if (zonas_planificacion== `i')) ///
	  row obs ci format(%17.4f) cellwidth(20)
}


* Hipertension por hipertension dignostico por grupo_etnicos
levelsof gr_etn, local(levels)
foreach i of local levels {
	svy: tabulate hipertension f7502, ///
	  subpop(if (gr_etn== `i')) row obs ci format(%17.4f) cellwidth(20)
}

* Hipertension por hipertension dignostico por NBI
levelsof nbi, local(levels)
foreach i of local levels {
	svy: tabulate hipertension f7502, ///
	  subpop(if (nbi== `i')) row obs ci format(%17.4f) cellwidth(20)
}

* Hipertension por hipertension dignostico por Quintil Economico
levelsof quint, local(levels)
foreach i of local levels {
svy: tabulate hipertension f7502, ///
	  subpop(if (quint== `i')) row obs ci format(%17.4f) cellwidth(20)
}


* Tabla de le ha tomado la pression arterial vs variables de cruce
*Le han tomando... vs. Grupos etnicos subregion zonas de planificaciones y
*quintil econ.
global y  gr_etn  subreg zonas_planificacion quint
foreach V of global y {
	svy: tabulate  `V' f7501, row obs ci  format(%17.4f) cellwidth(20)
}

*Le han tomando...f7501 vs. Edrec vs sexo

svy: tabulate edrec f7501, row obs ci  format(%17.4f) cellwidth(20)
svy: tabulate edrec f7501, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
svy: tabulate edrec f7501, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)


*Hipertencion vs. var. en relacion con tratamiento anti hiperten
global y  f75031 f75032 f75033 f75034 f75035 f7504
foreach V of global y {
	svy: tabulate hipertension `V', row obs ci  format(%17.4f) cellwidth(20)
}

*Hipertencion vs. var. en relacion con tratamiento anti hiperten vs. Sexo
global y  f75031
foreach V of global y {
	di "Hipertensión por ""`: var label `V''""Grupo: Total"
	svy: tabulate hipertension `V', row obs ci format(%17.4f) cellwidth(20)
	di "Hipertensión por ""`: var label `V''""Grupo: Hombre"
	svy: tabulate hipertension `V', ///
	  subpop(if pd02==1) row obs ci format(%17.4f) cellwidth(20)
	di "Hipertensión por ""`: var label `V''""Grupo: Mujer"
	svy: tabulate hipertension `V', ///
	  subpop(if pd02==2) row obs ci format(%17.4f) cellwidth(20)
	}

*Hipertension Provincia
global y  provincia
foreach V of global y {
	di "`: var label `V''"" por Hipertensión Grupo: Total"
	svy: tabulate `V' hipertension , row obs ci  format(%17.4f) cellwidth(20)
	di "`: var label `V''"" por Hipertensión Grupo: Hombre"
	svy: tabulate `V' hipertension , ///
	  subpop(if pd02==1) row obs ci format(%17.4f) cellwidth(20)
	di "`: var label `V''"" por Hipertensión Grupo: Mujer"
	svy: tabulate `V' hipertension , ///
	  subpop(if pd02==2) row obs ci format(%17.4f) cellwidth(20)
	}

* Hipertension vs  var. relacionadas a tratamiento anti hipertens.*Solo hipertenso y prehipertenso
global y  f75031 f75032 f75033 f75034 f75035 f7504
*Zonas de Planificacion vs  var. relacionadas a tratamiento anti hipertens.
foreach V of global y {
	di "Zonas de planificación por ""`: var label `V''"":"
	svy: tabulate zonas_planificacion `V', ///
	  subpop(if hipertension==1| hipertension==2) ///
	  row obs ci  format(%17.4f) cellwidth(20)
	}

*Subregiones vs  var. relacionadas a tratamiento anti hipertens.
foreach V of global y {
	di "Subregiones por ""`: var label `V''"":"
	svy: tabulate subreg `V', ///
	  subpop(if hipertension==1| hipertension==2) ///
	  row obs ci  format(%17.4f) cellwidth(20)
	}

*Grupos etnicos vs  var. relacionadas a tratamiento anti hipertens.
foreach V of global y {
	di "Grupos etnicos  por ""`: var label `V''"":"
	svy: tabulate gr_etn `V', ///
	  subpop(if hipertension==1| hipertension==2) ///
	  row obs ci  format(%17.4f) cellwidth(20)
	}
*Quintil Economico  vs  var. relacionadas a tratamiento anti hipertens.
foreach V of global y {
	di "Quintil economico por ""`: var label `V''"":"
	svy: tabulate quint `V', ///
	  subpop(if hipertension==1| hipertension==2) ///
	  row obs ci  format(%17.4f) cellwidth(20)
	}


********************************************************************************
****Hipertensión menores : de 10 a 18 años
use ensanut_f10_antropometria_aecnt.dta, clear

*TA para menores de 18a :TA+ si pres_sis/presd 120/80 (cer. Pediatrics 144,4ta.)

gen pasfrec=.
replace  pasfrec=1 if(presfs< 119 & edadanio <18  & edadanio >9)
replace  pasfrec=2 if(presfs>=120 & presfs<=280 & edadanio <18 & edadanio >9)
label variable pasfrec "presión arterial sistolica recodificada"
label define  psr  1 "lt 120" 2 "ge 120"
label values pasfrec psr

gen padfrec=.
replace  padfrec=1 if(presfd< 79 & edadanio <18 & edadanio >9)
replace  padfrec=2 if(presfd>=80 & presfd<=280 & edadanio <18 & edadanio >9)
label variable padfrec "presión arterial sistolica recodificada"
label define  pdr  1 "lt 80" 2 "ge 80"
label values padfrec pdr

gen palta=.
replace  palta =0 if (pasfrec==1 | padfrec==1)
replace palta=1 if ( (pasfrec==2|padfrec==2) & edadanio <18 & edadanio >9 ///
  & pasfrec!=. & padfrec!=.)
replace palta=. if ( (pasfrec==.|padfrec==.) | (edadanio>17 & edadanio <10))
label variable  palta "presión arterial alta"
label define plt 0 "ni pasfrec ni padfrec altas" 1 "pasfrec y/o pasdfrec altas"
label values palta plt

*Verif Missing a  casos de embarazados f2200==1
replace palta=. if f2200==1

gen edrec2=.
replace edrec2=0 if(edadanio>=10 & edadanio<=13)
replace edrec2=1 if(edadanio>=14 & edadanio<=18)
label variable edrec2 "Edad dicotomica (10 a 17a)"
label define  ed2 0 "10 a 13 años" 1 "14 a 17 años"
label values edrec2 ed2

*Estadisticas  descriptivas TASF TADF por sexo y edad (edrec2)
*Estadisticas  descriptivas TASF vs edrec2
tabout  edrec2 pd02  using Prsis_gr10_sex.txt, ///
  replace c(mean presfs lb ub) f(1.1) svy sum
tabout  edrec2 [aw= pw]  using 1pPrsis_gr10_.txt, ///
  replace c(min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
tabout  edrec2 [aw= pw] if pd02==1 using 2Pprsis_gr10_sex1.txt, ///
  replace c(min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
tabout  edrec2 [aw= pw] if pd02==2 using 3Pprsis_gr10_sex2.txt, ///
  replace c(min presfs max presfs median presfs sd presfs ///
  p90 presfs p95 presfs) f(1.1) sum
*Estadisticas  descriptivas TADF vs edrec2
tabout  edrec2 pd02  using Prsis_gr10_sex.txt, ///
  replace c(mean presfd lb ub) f(1.1) svy sum
tabout  edrec2 [aw= pw]  using 4Pprsis_gr10_.txt, ///
  replace c(min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum
tabout  edrec2 [aw= pw] if pd02==1 using 5Pprsis_gr10_sex1.txt, ///
  replace c(min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum
tabout  edrec2 [aw= pw] if pd02==2 using 6Ppsis_gr10_sex2.txt, ///
  replace c(min presfd max presfd median presfd sd presfd ///
  p90 presfd p95 presfd) f(1.1) sum


*Estadisticas  descriptivas Palta vs edrec2
svy: tabulate  edrec2 palta, row ci obs  format(%17.4f) cellwidth(20)
svy: tabulate  edrec2 palta, ///
  subpop(if pd02==1) row ci obs   format(%17.4f) cellwidth(20)
svy: tabulate  edrec2 palta, ///
  subpop(if pd02==2) row ci obs   format(%17.4f) cellwidth(20)

*Tabla contingencia palta por genero y variables de cruce
*Tabla Hipertension de adolescentes por subreg y por genero
global y  gr_etn  subreg zonas_planificacion nbi quint

foreach V of global y {
	di "Presion Alta por Variable de cruce:""`V'"" Grupo: total"
	svy: tabulate  `V' palta, row ci  format(%17.4f) cellwidth(20)
	di "Presion Alta por Variable de cruce:""`V'"" Grupo: Hombre"
	svy: tabulate  `V' palta, ///
	  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
	di "Presion Alta por Variable de cruce:""`V'"" Grupo: Mujer"
	svy: tabulate  `V' palta, ///
	  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)
	}

svy: tabulate  provincia palta, row obs ci  format(%17.4f) cellwidth(20)
svy: tabulate  provincia palta, ///
  subpop(if pd02==1) row obs ci  format(%17.4f) cellwidth(20)
svy: tabulate  provincia palta, ///
  subpop(if pd02==2) row obs ci  format(%17.4f) cellwidth(20)



*Análisis de Aprox. a Enfermedades Crónicas no tr. ensanut 2012 termina ahí*****
