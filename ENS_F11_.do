******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
*********************Tomo 1***************************************************
*********************Capítulo: Consumo****************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboración: Maria Jose Ramirez majoramirez@hotmail.com
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
*Preparación de bases:
*Variables de identificadores & svyset
clear all
set more off
*Ingresar el directorio de las bases:
cd ""
use ensanut_f11_consumo_parteb.dta,clear
cap drop id*
*Identificador de personas / Hogar / vivienda
gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
format idhog %20.0f
gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
format idviv %20.0f
gen idptemp=hogar*10^2+persona
egen  idpers=concat (idviv idptemp),format(%20.0f)
drop idptemp idptemp
*Identificador de sector :
gen double idsector = ciudad*10^6+zona*10^3+sector
lab var idviv "Identificador de vivienda"
lab var idpers "Identificador de persona"
lab var idsector "Identificador de sector"
lab var idhog "Identificador de hogar"

merge m:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 escol edadanio quint nbi pd08b)
drop if _merge==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"

*Grupos de edad
gen edad_cat=.
replace edad_cat=1 if edadanio>=1 & edadanio<4
replace edad_cat=2 if edadanio>=4 & edadanio<9
replace edad_cat=3 if edadanio>=9 & edadanio<14 & pd02==1
replace edad_cat=4 if edadanio>=14 & edadanio<19 & pd02==1
replace edad_cat=5 if edadanio>=19 & edadanio<31 & pd02==1
replace edad_cat=6 if edadanio>=31 & edadanio<51 & pd02==1
replace edad_cat=7 if edadanio>=51 & pd02==1
replace edad_cat=8 if edadanio>=9 & edadanio<14 & pd02==2
replace edad_cat=9 if edadanio>=14 & edadanio<19 & pd02==2
replace edad_cat=10 if edadanio>=19 & edadanio<31 & pd02==2
replace edad_cat=11 if edadanio>=31 & edadanio<51 & pd02==2
replace edad_cat=12 if edadanio>=51 & pd02==2

save ensanut_f11_consumo_parteb.dta,replace

*********************************************************************************
*1.1 Tablas por kcal tiempos y lugar
*Consumo promedio de grupos de alimentos en gramos
use ensanut_f11_consumo_parteb.dta,clear
*Collapse
collapse (sum) f11220f (mean) pw provincia zonas_planificacion ///
  gr_etn quint area idsector , by(idpers edad_cat grupo_ali14)
*Tabla
svyset idsector [pweight=pw], strata (area)

tabout grupo_ali14 edad_cat  using gralitabledadcatf11220f.txt, ///
  replace c(mean f11220f lb ub) svy sum f(1.1)

*********************************************************************************
*Tiempo de comida por origen de la comida
use ensanut_f11_consumo_parteb.dta, clear
*Collapse
collapse (sum) f11220f (mean) pw provincia zonas_planificacion ///
  gr_etn  quint area idsector, by(idpers f11203cp f11204cp)
*Tabla
svyset idsector [pweight=pw], strata (area)
svy: tabulate f11203cp f11204cp, row ci  format(%17.4f)  cellwidth(20)
svy: tabulate f11203cp f11204cp, row ci subpop(if area==1) ///
  format(%17.4f)  cellwidth(20)
svy: tabulate f11203cp f11204cp, row ci subpop(if area==2) ///
  format(%17.4f)  cellwidth(20)

**************************************************************************
*Actividad de realiza durante comida vs gredad
use ensanut_f11_consumo_parteb.dta, clear
*Collapse
collapse (sum) f11220f (mean) pw provincia zonas_planificacion ///
  gr_etn  quint area idsector if( pw!=.) , by(idpers edad_cat f11206cp)
*Tabla
svyset idsector [pweight=pw], strata (area)
svy: tabulate edad_cat f11206cp, row ci  format(%17.4f)  cellwidth(20)
svy: tabulate edad_cat f11206cp, row ci subpop(if area==1) ///
  format(%17.4f)  cellwidth(20)
svy: tabulate edad_cat f11206cp, row ci subpop(if area==2) ///
  format(%17.4f)  cellwidth(20)

********************************************************************************
*Numero de veces que se come al dia
use ensanut_f11_consumo_parteb.dta, clear
*Collapse
collapse (count) idhog (mean) edad_cat  pd02 pw provincia zonas_planificacion ///
  gr_etn quint area idsector if( pw!=.) , by(idpers f11203cp)
collapse (count) nvecom=idhog (mean) edad_cat  pd02 pw provincia ///
  zonas_planificacion gr_etn quint area idsector , by(idpers)
*Tabla
svyset idsector [pweight=pw], strata (area)
svy: tabulate  edad_cat nvecom, row col format(%17.4f)  cellwidth(20)


*******************************************************************************
*******************************************************************************
*Analisis por vector nutricional
*Preparacion de la base
use ensanut_f11_consumo_parteb_vector.dta,clear

*Variables generales de cruce:
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 escol edadanio edadmes quint nbi idsector idhog)
drop if _merge==2
drop _merge
*Merge de datos antropometricos talla y peso (variable pesof y tallaf)
*Merge actividad física basada en la variable af_global4
*Media de AF por hogar mafglo4_red

*Grupos de edad
gen edad_cat=.
replace edad_cat=1 if edadanio>=1 & edadanio<4
replace edad_cat=2 if edadanio>=4 & edadanio<9
replace edad_cat=3 if edadanio>=9 & edadanio<14 & pd02==1
replace edad_cat=4 if edadanio>=14 & edadanio<19 & pd02==1
replace edad_cat=5 if edadanio>=19 & edadanio<31 & pd02==1
replace edad_cat=6 if edadanio>=31 & edadanio<51 & pd02==1
replace edad_cat=7 if edadanio>=51 & pd02==1
replace edad_cat=8 if edadanio>=9 & edadanio<14 & pd02==2
replace edad_cat=9 if edadanio>=14 & edadanio<19 & pd02==2
replace edad_cat=10 if edadanio>=19 & edadanio<31 & pd02==2
replace edad_cat=11 if edadanio>=31 & edadanio<51 & pd02==2
replace edad_cat=12 if edadanio>=51 & pd02==2

*Svyset
svyset idsector [pweight=pw], strata (area)
*Estadísticas Descriptivas de la poblacion
gen edad_grupos=.
replace edad_grupos=1 if edadanio>=1 & edadanio<4
replace edad_grupos=2 if edadanio>=4 & edadanio<9
replace edad_grupos=3 if edadanio>=9 & edadanio<14
replace edad_grupos=4 if edadanio>=14 & edadanio<19
replace edad_grupos=5 if edadanio>=19 & edadanio<31
replace edad_grupos=6 if edadanio>=31 & edadanio<51
replace edad_grupos=7 if edadanio>=51

svy: tabulate edad_grupos, ci obs format(%17.4f)
svy: tabulate pd02, ci obs format(%17.4f)
svy: tabulate area, ci obs format(%17.4f)
svy: tabulate gr_etn, ci obs format(%17.4f)


*********************************************************************************
*Características generales de la dieta Tiempo de Comida
*Antes desayuno por sexo y area urbana o rual
svy: tabulate pd02 f11102a, subpop(if (area==1)) row  ci  obs format(%17.4f)
svy: tabulate pd02 f11102a, subpop(if (area==2)) row  ci  obs format(%17.4f)

*Desayuno por sexo y area urbana o rual
tab area
local Z
forvalues i = 1/2 {
	svy: tabulate pd02 f11102b, ///
	  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	}
svy: tabulate  f11102b, ci obs format(%17.4f)


*Media mañana por sexo y area urbana o rural
local i = 1
while `i' <=2 {
	svy: tabulate pd02 f11102c, ///
	  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  f11102c, ci obs format(%17.4f)

*Almuerzo por sexo y area urbana o rural
local i = 1
while `i' <=2 {
	svy: tabulate pd02 f11102d, ///
	  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  f11102d, ci obs format(%17.4f)

*Media tarde por sexo y area urbana o rural
local i = 1
while `i' <=2 {
svy: tabulate pd02 f11102e, ///
  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  f11102e, ci obs format(%17.4f)

*Merienda
local i = 1
while `i' <=2 {
svy: tabulate pd02 f11102f, ///
  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  f11102f, ci obs format(%17.4f)

*Antes de dormir
local i = 1
while `i' <=2 {
svy: tabulate pd02 f11102g, ///
  subpop(if (area== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  f11102g, ci obs format(%17.4f)

*Consumo de suplementos
svy: tabulate pd02 f11103, row se ci cv obs format(%17.4f)

********************************************************************************
*Estadísticas Descriptivas por nutriente y categoría de edad

local V prot grasa_tot cho_diff kcal fibra vit_A_RAE vit_C ///
  vit_E tiam ribo niac vit_b6 folato_t folato_DFE vit_b12 cu fe mg p ca zn k
foreach Y in `V' {
	tabstat `Y'  [aw= pw], ///
	  by(edad_cat) stat(n mean p50 p5 p75 p90 p95 sem sd) c(statistics)
	}

*********************************************************************************
*Contribucion porcentual de la dieta para macronutrientes
gen cal_prot=.
replace cal_prot=prot_usual*4
gen cal_cho=.
replace cal_cho=cho_usual*4
gen cal_grasa=.
replace cal_grasa=gr_usual*9
gen cal_grasasat=.
replace cal_grasasat=grst_usual*9
****
gen por_prot=.
replace por_prot=cal_prot*100/kcal_usual
gen por_cho=.
replace por_cho=cal_cho*100/kcal_usual
gen por_grasa=.
replace por_grasa=cal_grasa*100/kcal_usual
gen por_grasasat=.
replace por_grasasat=cal_grasasat*100/kcal_usual
***
*Por Grupos de edad
gen edad_cat11=.
replace edad_cat11=1 if edadanio>=1 & edadanio<4
replace edad_cat11=2 if edadanio>=4 & edadanio<9
replace edad_cat11=3 if edadanio>=9 & edadanio<14
replace edad_cat11=4 if edadanio>=14 & edadanio<19
replace edad_cat11=5 if edadanio>=19 & edadanio<31
replace edad_cat11=6 if edadanio>=31 & edadanio<51
replace edad_cat11=7 if edadanio>=51
lab var edad_cat11 "Categorias de edad sin sexo"
lab def edad_cat11 1 "1-3 años" 2 "4-8 años" 3 "9-13 años"  ///
		  4 "14-18 años" 5 "19-30 años" 6 "31-50 años" 7 "51-60 años",replace
lab val edad_cat11 edad_cat11

*********************************************************************************
*Contribución porcentual de macronutrientes por area
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(area) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
	}
*Contribución porcentual de macronutrientes por grupo de edad sexo
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(edad_cat11) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
	}

*Contribución porcentual de macronutrientes por quintil
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(quint) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
	}

*Contribución porcentual de macronutrientes por sexo
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(pd02) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
	}

*********************************************************************************
*Consumo usual de macro y micronutrientes
local V	kcal_usual prot_usual cho_usual gr_usual grst_usual ///
  fib_usual fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
*Sexo subregion grupo étnico quintil económico zona de planificacion
local Z pd02 subreg gr_etn nbi quint zonas_planificacion
forval i= 1/7 {
	foreach Y in `V' {
		foreach W in `Z' {
			di "Nutrientes:""`Y'"" Variable de cruce:""`W'"" Grupo de edad:"
			di  "`:label (edad_cat11) `i''"
			tabstat `Y'  [aw= pw], by(`W') ///
			  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics), ///
			  if edad_cat11==`i', format(%9.1f)
			}
		}
	}

*********************************************************************************
*Inadecuación de la dieta
*********************************************************************************
*Requerimiento energetico estimado y adecuación
*EER area urbana niños menores de 3 años
*Ratio de energia:
gen ratio_energia=.
replace ratio_energia=kcal_usual/EER

gen adec_energia=.
replace adec_energia=1 if ratio_energia>1 & ratio_energia<1.2
replace adec_energia=2 if ratio_energia<=1
replace adec_energia=3 if ratio_energia>=1.2
label variable adec_energia "1: adecuado 2:deficiencia 3:exceso"

*Adecuacion de energía por sexo
tab edad_cat11
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_energia, ///
	  subpop(if (edad_cat11== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adecuacion de energía por grupo étnico a nivel nacional
svy: tabulate gr_etn adec_energia, row se ci cv obs format(%17.4f)
*Adecuación de energía por subregión
svy: tabulate subreg adec_energia, row se ci cv obs format(%17.4f)
*Adecuación de energía por quintil económico
svy: tabulate quint adec_energia, row se ci cv obs format(%17.4f)
*Adecuación de energía por zonas de planificación
svy: tabulate zonas_planificacion adec_energia, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación CHO y GRASA
*Adecuación de carbohidratos segun la IOMS
gen adec_cho=.
replace adec_cho=1 if por_cho>=45 & por_cho<=65
replace adec_cho=2 if por_cho<45
replace adec_cho=3 if por_cho>65
label variable adec_cho "1: adecuado 2:deficiencia 3:exceso"

*Adecuacion de carbohidratos por sexo
tab edad_cat11
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_cho, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de cho por edad categorica
svy: tabulate edad_cat11 adec_cho, row se ci cv obs format(%17.4f)
*Adecuacion de cho por sexo
svy: tabulate pd02 adec_cho, row se ci cv obs format(%17.4f)
*Adecuacion de carbohidratos por grupo étnico
svy: tabulate gr_etn adec_cho, row se ci cv obs format(%17.4f)
*Adecuación de carbohidratos por subregión
svy: tabulate subreg adec_cho,  row se ci cv obs format(%17.4f)
*Adecuación de carbohidratos por quintil económico
svy: tabulate quint adec_cho, row se ci cv obs format(%17.4f)
*Adecuación de carbohidratos por zonas de planificación
svy: tabulate zonas_planificacion adec_cho, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de grasas segun la IOMS

gen adec_grasa=.
*Adultos
replace adec_grasa=1 if por_grasa>=20 & por_grasa<=35
replace adec_grasa=2 if por_grasa<20
replace adec_grasa=3 if por_grasa>35
*Niños de 1 - 3 años
replace adec_grasa=1 if por_grasa>=30 & por_grasa<=40 & edad_cat==1
replace adec_grasa=2 if por_grasa<30 & edad_cat==1
replace adec_grasa=3 if por_grasa>40 & edad_cat==1
*Niños de 4 - 18 años
replace adec_grasa=1 if por_grasa>=25 & por_grasa<=35 & edad_cat==2
replace adec_grasa=1 if por_grasa>=25 & por_grasa>=35 & edad_cat==3
replace adec_grasa=1 if por_grasa>=25 & por_grasa>=35 & edad_cat==4

replace adec_grasa=2 if por_grasa<25 & edad_cat==2
replace adec_grasa=2 if por_grasa<25 & edad_cat==3
replace adec_grasa=2 if por_grasa<25 & edad_cat==4

replace adec_grasa=3 if por_grasa>35 & edad_cat==2
replace adec_grasa=3 if por_grasa>35 & edad_cat==3
replace adec_grasa=3 if por_grasa>35 & edad_cat==4
label variable adec_grasa "1: adecuado 2:deficiencia 3:exceso"

*Adecuacion de grasas totales por sexo
tab edad_cat11
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_grasa, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de grasas totales por edad categorica
svy: tabulate edad_cat11 adec_grasa, row se ci cv obs format(%17.4f)
*Adecuacion de grasas totales por sexo
svy: tabulate pd02 adec_grasa, row se ci cv obs format(%17.4f)
*Adecuacion de grasas totales por grupo étnico
svy: tabulate gr_etn adec_grasa, row se ci cv obs format(%17.4f)
*Adecuación de grasas totales por subregión
svy: tabulate subreg adec_grasa,  row se ci cv obs format(%17.4f)
*Adecuación de grasas totales por quintil económico
svy: tabulate quint adec_grasa, row se ci cv obs format(%17.4f)
*Adecuación de grasas totales por zonas de planificación
svy: tabulate zonas_planificacion adec_grasa, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de Fibra
gen adec_fibra=.
replace adec_fibra=1 if fib_usual>=19 & edad_cat==1
replace adec_fibra=0 if fib_usual<19 & edad_cat==1

replace adec_fibra=1 if fib_usual>=25 & edad_cat==2
replace adec_fibra=0 if fib_usual<25 & edad_cat==2

replace adec_fibra=1 if fib_usual>=31 & edad_cat==3
replace adec_fibra=0 if fib_usual<31 & edad_cat==3

replace adec_fibra=1 if fib_usual>=38 & edad_cat==4
replace adec_fibra=0 if fib_usual<38 & edad_cat==4

replace adec_fibra=1 if fib_usual>=38 & edad_cat==5
replace adec_fibra=0 if fib_usual<38 & edad_cat==5

replace adec_fibra=1 if fib_usual>=38 & edad_cat==6
replace adec_fibra=0 if fib_usual<38 & edad_cat==6

replace adec_fibra=1 if fib_usual>=30 & edad_cat==7
replace adec_fibra=0 if fib_usual<30 & edad_cat==7

replace adec_fibra=1 if fib_usual>=26 & edad_cat==8
replace adec_fibra=0 if fib_usual<26 & edad_cat==8

replace adec_fibra=1 if fib_usual>=26 & edad_cat==9
replace adec_fibra=0 if fib_usual<26 & edad_cat==9

replace adec_fibra=1 if fib_usual>=25 & edad_cat==10
replace adec_fibra=0 if fib_usual<25 & edad_cat==10

replace adec_fibra=1 if fib_usual>=25 & edad_cat==11
replace adec_fibra=0 if fib_usual<25 & edad_cat==11

replace adec_fibra=1 if fib_usual>=21 & edad_cat==12
replace adec_fibra=0 if fib_usual<21 & edad_cat==12

label variable adec_fibra "1:por arriba 0:no se interpreta"

*Adecuación de fibra por sexo
tab edad_cat11
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_fibra, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de fibra por edad categorica
svy: tabulate edad_cat11 adec_fibra, row se ci cv obs format(%17.4f)
*Adecuacion de fibra por sexo
svy: tabulate pd02 adec_fibra, row se ci cv obs format(%17.4f)
*Adecuacion de fibra por grupo étnico
svy: tabulate gr_etn adec_fibra, row se ci cv obs format(%17.4f)
*Adecuación de fibra por subregión
svy: tabulate subreg adec_fibra,  row se ci cv obs format(%17.4f)
*Adecuación de fibra por quintil económico
svy: tabulate quint adec_fibra, row se ci cv obs format(%17.4f)
*Adecuación de fibra por zonas de planificación
svy: tabulate zonas_planificacion adec_fibra, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de MICRONUTRIENTES
*********************************************************************************
*Adecuacion de vitamina A

gen adec_vitA=.
replace adec_vitA=1 if vitA_RAE_aj>=210 & edad_cat==1
replace adec_vitA=0 if vitA_RAE_aj<210 & edad_cat==1
replace adec_vitA=1 if vitA_RAE_aj>=275 & edad_cat==2
replace adec_vitA=0 if vitA_RAE_aj<275 & edad_cat==2
replace adec_vitA=1 if vitA_RAE_aj>=445 & edad_cat==3
replace adec_vitA=0 if vitA_RAE_aj<445 & edad_cat==3
replace adec_vitA=1 if vitA_RAE_aj>=630 & edad_cat==4
replace adec_vitA=0 if vitA_RAE_aj<630 & edad_cat==4
replace adec_vitA=1 if vitA_RAE_aj>=625 & edad_cat==5
replace adec_vitA=0 if vitA_RAE_aj<625 & edad_cat==5
replace adec_vitA=1 if vitA_RAE_aj>=625 & edad_cat==6
replace adec_vitA=0 if vitA_RAE_aj<625 & edad_cat==6
replace adec_vitA=1 if vitA_RAE_aj>=625 & edad_cat==7
replace adec_vitA=0 if vitA_RAE_aj<625 & edad_cat==7
replace adec_vitA=1 if vitA_RAE_aj>=420 & edad_cat==8
replace adec_vitA=0 if vitA_RAE_aj<420 & edad_cat==8
replace adec_vitA=1 if vitA_RAE_aj>=485 & edad_cat==9
replace adec_vitA=0 if vitA_RAE_aj<485 & edad_cat==9
replace adec_vitA=1 if vitA_RAE_aj>=500 & edad_cat==10
replace adec_vitA=0 if vitA_RAE_aj<500 & edad_cat==10
replace adec_vitA=1 if vitA_RAE_aj>=500 & edad_cat==11
replace adec_vitA=0 if vitA_RAE_aj<500 & edad_cat==11
replace adec_vitA=1 if vitA_RAE_aj>=500 & edad_cat==12
replace adec_vitA=0 if vitA_RAE_aj<500 & edad_cat==12
label variable adec_vitA "1:adecuado 0:inadecuado"

*Adecuacion de vitamina A por sexo
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_vitA, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de vitamina A por edad categorica
svy: tabulate edad_cat11 adec_vitA, row se ci cv obs format(%17.4f)
*Adecuacion de vitamina A por sexo
svy: tabulate pd02 adec_vitA, row se ci cv obs format(%17.4f)
*Adecuacion de vitamina A por grupo étnico
svy: tabulate gr_etn adec_vitA, row se ci cv obs format(%17.4f)
*Adecuación de vitamina A por subregión
svy: tabulate subreg adec_vitA,  row se ci cv obs format(%17.4f)
*Adecuación de vitamina A por quintil económico
svy: tabulate quint adec_vitA, row se ci cv obs format(%17.4f)
*Adecuación de vitamina A por zonas de planificación
svy: tabulate zonas_planificacion adec_vitA, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de vitamina C
gen adec_vitC=.
replace adec_vitC=1 if vc_usual>=13 & edad_cat==1
replace adec_vitC=0 if vc_usual<13 & edad_cat==1
replace adec_vitC=1 if vc_usual>=22 & edad_cat==2
replace adec_vitC=0 if vc_usual<22 & edad_cat==2
replace adec_vitC=1 if vc_usual>=39 & edad_cat==3
replace adec_vitC=0 if vc_usual<39 & edad_cat==3
replace adec_vitC=1 if vc_usual>=63 & edad_cat==4
replace adec_vitC=0 if vc_usual<63 & edad_cat==4
replace adec_vitC=1 if vc_usual>=75 & edad_cat==5
replace adec_vitC=0 if vc_usual<75 & edad_cat==5
replace adec_vitC=1 if vc_usual>=75 & edad_cat==6
replace adec_vitC=0 if vc_usual<75 & edad_cat==6
replace adec_vitC=1 if vc_usual>=75 & edad_cat==7
replace adec_vitC=0 if vc_usual<75 & edad_cat==7
replace adec_vitC=1 if vc_usual>=39 & edad_cat==8
replace adec_vitC=0 if vc_usual<39 & edad_cat==8
replace adec_vitC=1 if vc_usual>=56 & edad_cat==9
replace adec_vitC=0 if vc_usual<56 & edad_cat==9
replace adec_vitC=1 if vc_usual>=60 & edad_cat==10
replace adec_vitC=0 if vc_usual<60 & edad_cat==10
replace adec_vitC=1 if vc_usual>=60 & edad_cat==11
replace adec_vitC=0 if vc_usual<60 & edad_cat==11
replace adec_vitC=1 if vc_usual>=60 & edad_cat==12
replace adec_vitC=0 if vc_usual<60 & edad_cat==12
label variable adec_vitC "1:adecuado 0:inadecuado"

*Adecuacion de vitamina C por sexo
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_vitC, ///
	  subpop(if (edad_cat11== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de vitamina c por edad categorica
svy: tabulate edad_cat11 adec_vitC, row se ci cv obs format(%17.4f)
*Adecuacion de vitamina c por sexo
svy: tabulate pd02 adec_vitC, row se ci cv obs format(%17.4f)
*Adecuacion de vitamina c por grupo étnico
svy: tabulate gr_etn adec_vitC, row se ci cv obs format(%17.4f)
*Adecuación de vitamina c por subregión
svy: tabulate subreg adec_vitC,  row se ci cv obs format(%17.4f)
*Adecuación de vitamina c por quintil económico
svy: tabulate quint adec_vitC, row se ci cv obs format(%17.4f)
*Adecuación de vitamina c por zonas de planificación
svy: tabulate zonas_planificacion adec_vitC, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de folato
gen adec_fol=.
replace adec_fol=1 if fol_usual>=120 & edad_cat==1
replace adec_fol=0 if fol_usual<120 & edad_cat==1
replace adec_fol=1 if fol_usual>=160 & edad_cat==2
replace adec_fol=0 if fol_usual<160 & edad_cat==2
replace adec_fol=1 if fol_usual>=250 & edad_cat==3
replace adec_fol=0 if fol_usual<250 & edad_cat==3
replace adec_fol=1 if fol_usual>=330 & edad_cat==4
replace adec_fol=0 if fol_usual<330 & edad_cat==4
replace adec_fol=1 if fol_usual>=320 & edad_cat==5
replace adec_fol=0 if fol_usual<320 & edad_cat==5
replace adec_fol=1 if fol_usual>=320 & edad_cat==6
replace adec_fol=0 if fol_usual<320 & edad_cat==6
replace adec_fol=1 if fol_usual>=320 & edad_cat==7
replace adec_fol=0 if fol_usual<320 & edad_cat==7
replace adec_fol=1 if fol_usual>=250 & edad_cat==8
replace adec_fol=0 if fol_usual<250 & edad_cat==8
replace adec_fol=1 if fol_usual>=330 & edad_cat==9
replace adec_fol=0 if fol_usual<330 & edad_cat==9
replace adec_fol=1 if fol_usual>=320 & edad_cat==10
replace adec_fol=0 if fol_usual<320 & edad_cat==10
replace adec_fol=1 if fol_usual>=320 & edad_cat==11
replace adec_fol=0 if fol_usual<320 & edad_cat==11
replace adec_fol=1 if fol_usual>=320 & edad_cat==12
replace adec_fol=0 if fol_usual<320 & edad_cat==12
label variable adec_fol "1:adecuado 0:inadecuado"

*Adecuacion de folato por sexo
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_fol, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de folato por edad categorica
svy: tabulate edad_cat11 adec_fol, row se ci cv obs format(%17.4f)
*Adecuacion de folato por sexo
svy: tabulate pd02 adec_fol, row se ci cv obs format(%17.4f)
*Adecuacion de folato por grupo étnico
svy: tabulate gr_etn adec_fol, row se ci cv obs format(%17.4f)
*Adecuación de folato por subregión
svy: tabulate subreg adec_fol,  row se ci cv obs format(%17.4f)
*Adecuación de folato por quintil económico
svy: tabulate quint adec_fol, row se ci cv obs format(%17.4f)
*Adecuación de folato  por zonas de planificación
svy: tabulate zonas_planificacion adec_fol, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de vitamina b12

gen adec_vitb12=.
replace adec_vitb12=1 if b12aj_usual>=0.7 & edad_cat==1
replace adec_vitb12=0 if b12aj_usual<0.7 & edad_cat==1
replace adec_vitb12=1 if b12aj_usual>=1 & edad_cat==2
replace adec_vitb12=0 if b12aj_usual<1 & edad_cat==2
replace adec_vitb12=1 if b12aj_usual>=1.5 & edad_cat==3
replace adec_vitb12=0 if b12aj_usual<1.5 & edad_cat==3
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==4
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==4
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==5
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==5
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==6
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==6
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==7
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==7
replace adec_vitb12=1 if b12aj_usual>=1.5 & edad_cat==8
replace adec_vitb12=0 if b12aj_usual<1.5 & edad_cat==8
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==9
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==9
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==10
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==10
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==11
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==11
replace adec_vitb12=1 if b12aj_usual>=2 & edad_cat==12
replace adec_vitb12=0 if b12aj_usual<2 & edad_cat==12
label variable adec_vitb12 "1:adecuado 0:inadecuado"

*Adecuacion de vitb12 por sexo
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_vitb12, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de vitb12 por edad categorica
svy: tabulate edad_cat11 adec_vitb12, row se ci cv obs format(%17.4f)
*Adecuacion de vitb12 por sexo
svy: tabulate pd02 adec_vitb12, row se ci cv obs format(%17.4f)
*Adecuacion de vitb12 por grupo étnico
svy: tabulate gr_etn adec_vitb12, row se ci cv obs format(%17.4f)
*Adecuación de vitb12 por subregión
svy: tabulate subreg adec_vitb12,  row se ci cv obs format(%17.4f)
*Adecuación de vitb12 por quintil económico
svy: tabulate quint adec_vitb12, row se ci cv obs format(%17.4f)
*Adecuación de vitb12  por zonas de planificación
svy: tabulate zonas_planificacion adec_vitb12, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de zinc
gen adec_zn=.
replace adec_zn=1 if znaj_usual>=2.5 & edad_cat==1
replace adec_zn=0 if znaj_usual<2.5 & edad_cat==1
replace adec_zn=1 if znaj_usual>=4 & edad_cat==2
replace adec_zn=0 if znaj_usual<4 & edad_cat==2
replace adec_zn=1 if znaj_usual>=7 & edad_cat==3
replace adec_zn=0 if znaj_usual<7 & edad_cat==3
replace adec_zn=1 if znaj_usual>=8.5 & edad_cat==4
replace adec_zn=0 if znaj_usual<8.5 & edad_cat==4
replace adec_zn=1 if znaj_usual>=9.4 & edad_cat==5
replace adec_zn=0 if znaj_usual<9.4 & edad_cat==5
replace adec_zn=1 if znaj_usual>=9.4 & edad_cat==6
replace adec_zn=0 if znaj_usual<9.4 & edad_cat==6
replace adec_zn=1 if znaj_usual>=9.4 & edad_cat==7
replace adec_zn=0 if znaj_usual<9.4 & edad_cat==7
replace adec_zn=1 if znaj_usual>=7 & edad_cat==8
replace adec_zn=0 if znaj_usual<7 & edad_cat==8
replace adec_zn=1 if znaj_usual>=7.3 & edad_cat==9
replace adec_zn=0 if znaj_usual<7.3 & edad_cat==9
replace adec_zn=1 if znaj_usual>=6.8 & edad_cat==10
replace adec_zn=0 if znaj_usual<6.8 & edad_cat==10
replace adec_zn=1 if znaj_usual>=6.8 & edad_cat==11
replace adec_zn=0 if znaj_usual<6.8 & edad_cat==11
replace adec_zn=1 if znaj_usual>=6.8 & edad_cat==12
replace adec_zn=0 if znaj_usual<6.8 & edad_cat==12
label variable adec_zn "1:adecuado 0:inadecuado"

*Adecuacion de zinc por sexo
tab edad_cat11
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_zn, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adecuacion de zinc por edad categorica
svy: tabulate edad_cat11 adec_zn, row se ci cv obs format(%17.4f)
*Adecuacion de zinc por sexo
svy: tabulate pd02 adec_zn, row se ci cv obs format(%17.4f)
*Adecuacion de zinc por grupo étnico
svy: tabulate gr_etn adec_zn, row se ci cv obs format(%17.4f)
*Adecuación de zinc por subregión
svy: tabulate subreg adec_zn,  row se ci cv obs format(%17.4f)
*Adecuación de zinc por quintil económico
svy: tabulate quint adec_zn, row se ci cv obs format(%17.4f)
*Adecuación de zinc  por zonas de planificación
svy: tabulate zonas_planificacion adec_zn, row se ci cv obs format(%17.4f)

*********************************************************************************
*Adecuación de calcio

gen adec_calc=.
replace adec_calc=1 if calc_usual>=500 & edad_cat==1
replace adec_calc=0 if calc_usual<500 & edad_cat==1
replace adec_calc=1 if calc_usual>=800 & edad_cat==2
replace adec_calc=0 if calc_usual<800 & edad_cat==2
replace adec_calc=1 if calc_usual>=1100 & edad_cat==3
replace adec_calc=0 if calc_usual<1100 & edad_cat==3
replace adec_calc=1 if calc_usual>=1100 & edad_cat==4
replace adec_calc=0 if calc_usual<1100 & edad_cat==4
replace adec_calc=1 if calc_usual>=800 & edad_cat==5
replace adec_calc=0 if calc_usual<800 & edad_cat==5
replace adec_calc=1 if calc_usual>=800 & edad_cat==6
replace adec_calc=0 if calc_usual<800 & edad_cat==6
replace adec_calc=1 if calc_usual>=800 & edad_cat==7
replace adec_calc=0 if calc_usual<800 & edad_cat==7
replace adec_calc=1 if calc_usual>=1100 & edad_cat==8
replace adec_calc=0 if calc_usual<1100 & edad_cat==8
replace adec_calc=1 if calc_usual>=1100 & edad_cat==9
replace adec_calc=0 if calc_usual<1100 & edad_cat==9
replace adec_calc=1 if calc_usual>=800 & edad_cat==10
replace adec_calc=0 if calc_usual<800 & edad_cat==10
replace adec_calc=1 if calc_usual>=800 & edad_cat==11
replace adec_calc=0 if calc_usual<800 & edad_cat==11
replace adec_calc=1 if calc_usual>=1000 & edad_cat==12
replace adec_calc=0 if calc_usual<1000 & edad_cat==12
label variable adec_calc "1:adecuado 0:inadecuado"

*Adecuacion de calcio por sexo
local i = 1
while `i' <=7 {
	svy: tabulate pd02 adec_calc, subpop(if (edad_cat11== `i')) ///
	  row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adecuacion de calcio por edad categorica
svy: tabulate edad_cat11 adec_calc, row se ci cv obs format(%17.4f)
*Adecuacion de calcio por sexo
svy: tabulate pd02 adec_calc, row se ci cv obs format(%17.4f)
*Adecuacion de calcio por grupo étnico
svy: tabulate gr_etn adec_calc, row se ci cv obs format(%17.4f)
*Adecuación de calcio por subregión
svy: tabulate subreg adec_calc,  row se ci cv obs format(%17.4f)
*Adecuación de calcio por quintil económico
svy: tabulate quint adec_calc, row se ci cv obs format(%17.4f)
*Adecuación de calcio  por zonas de planificación
svy: tabulate zonas_planificacion adec_calc, row se ci cv obs format(%17.4f)

*Análisis de Consumo  ensanut 2012 termina ahí**********************************
