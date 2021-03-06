******************************************************************************
**************Encuesta Nacional de Salud y Nutrici�n 2011-2013****************
*********************Tomo 1***************************************************
*********************Cap�tulo: Consumo****************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboraci�n: Maria Jose Ramirez majoramirez@hotmail.com
  Philippe Belmont Guerr�n, MSP-ENSANUT philippebelmont@gmail.com
  Aprobaci�n: Wilma Freire

Para citar esta sintaxis en una publicaci�n usar:
Freire, W.B., M-J. Ramirez, P. Belmont, M-J. Mendieta, P. Pi�eiros, M.K. Silva,
	N. Romero, K. S�enz, P. Pi�eiros, L.R. G�mez, R. Monge. Encuesta Nacional
	de Salud y Nutrici�n del Ecuador ENSANUT-ECU TOMO I. Salud y Nutrici�n.
	Quito, Ecuador: MSP / INEC, 2013.

A BibTeX entry for LaTeX users is:

@book{freire_encuesta_2013,
	address = {Quito, Ecuador},
	title = {Encuesta Nacional de Salud y Nutrici�n del Ecuador {ENSANUT-ECU}
	{TOMO} I. Salud y Nutrici�n},
	language = {Es},
	publisher = {{MSP} / {INEC}},
	author = {Freire, {W.B.} and Ramirez, M-J. and Belmont, P. and Mendieta,
	M-J. and Silva, {M.K.} and Romero, N. and S�enz, K. and Pi�eiros,
	P. and G�mez, {L.R.} and Monge, R.},
	year = {2013}
}

*/
******************************************************************************
clear all
set more off
*Ingresar el directorio de las bases:
cd ""

*******************************************************************************
**********CONSUMO USUAL Y ADECUACION DE MACRO Y MICRONUTRIENTES****************
*********CONTRIBUCION PORCENTUAL DE LA DIETA PARA MACRONUTRIENTES**************
*Preparaci�n de bases:
use ensanut_f11_consumo_parteb_vector.dta,clear
*Variables de identificadores & svyset
merge m:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 escol edadanio quint nbi pd08b)
drop if _merge==2
drop _merge
*Configuracio de svy
svyset idsector [pweight=pw], strata (area)

*Por Grupos de edad
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


gen edad_cat11=.
replace edad_cat11=1 if edadanio>=1 & edadanio<4
replace edad_cat11=2 if edadanio>=4 & edadanio<9
replace edad_cat11=3 if edadanio>=9 & edadanio<14
replace edad_cat11=4 if edadanio>=14 & edadanio<19
replace edad_cat11=5 if edadanio>=19 & edadanio<31
replace edad_cat11=6 if edadanio>=31 & edadanio<51
replace edad_cat11=7 if edadanio>=51
lab var edad_cat11 "Categorias de edad sin sexo"
lab def edad_cat11 1 "1-3 a�os" 2 "4-8 a�os" 3 "9-13 a�os"  ///
		  4 "14-18 a�os" 5 "19-30 a�os" 6 "31-50 a�os" 7 "mas de 50 a�os",replace
lab val edad_cat11 edad_cat11

*******************************************************************************
*1. CONSUMO USUAL DE MACRO Y MICRONUTRIENTES

*** sexo

local V  kcal_usual prot_usual cho_usual gr_usual grst_usual ///
  fib_usual fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(pd02) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*** Edad
local V  kcal_usual prot_usual cho_usual gr_usual grst_usual ///
  fib_usual fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(edad_cat11) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

***** subregion
local V  kcal_usual prot_usual cho_usual gr_usual grst_usual fib_usual ///
  fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(subreg) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}
**** grupo �tnico
local V  kcal_usual prot_usual cho_usual gr_usual grst_usual fib_usual ///
  fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(gr_etn) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}
**** quintil econ�mico
local V  kcal_usual prot_usual cho_usual gr_usual grst_usual ///
  fib_usual fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(quint) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}
**** zona de planificaci�n
local V  kcal_usual prot_usual cho_usual gr_usual grst_usual ///
  fib_usual fe_usual va_usual vc_usual fol_usual b12_usual zn_usual calc_usual
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(zonas_planificacion) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}


*******************************************************************************
*2. INADECUACI�N DE LA DIETA*
*************************************************
*ENERG�A
*Para mayores de 19
*IMC
gen imc=.
replace imc= pesof/(tallafm*tallafm)
replace imc=. if edadanio <=18.99999

codebook imc
gen zimc=(imc- 26.9705) /6.49486

*Imputaci�n de valor de IMC para indivduos con imc<18.5
replace imc=18.5 if imc<18.5

*Imputaci�n de missing para datos con IMC mayores a 5DE de la media
*de la distribuci�n.
replace imc=. if zimc>4.99 & zimc!=.

gen EER1=.
* EER para ni�os y ni�as menores de un a�o
replace EER1=89*pesof - 100 + 20 if edadanio<=2.9999

*EER para ni�os de 3-8 a�os
replace EER1= 88.5-(edadanio*61.9)+ 1.13*((26.7*pesof)+(903*tallafm))+20 ///
  if edadanio>=3.00000 & edadanio<=8.99999 & pd02==1

*EER para ni�as de 3-8 a�os
replace EER1= 135.3-(edadanio*30.8)+ 1.16*((10*pesof)+(934*tallafm))+20 ///
  if edadanio>=3.00000 & edadanio<=8.99999 & pd02==2

*EER para hombres de 9-18 a�os
replace EER1= 88.5 -(edadanio*61.9)+ 1.13*((26.7*pesof)+(903*tallafm))+ 25 ///
  if edadanio>=9.00000 & edadanio<=18.99999 & pd02==1

*EER para mujeres de 9-18 a�os
replace EER1= 135.3- (edadanio*30.8)+ 1.16*((10*pesof)+(934*tallafm))+ 25 ///
  if edadanio>=9.00000 & edadanio<17.99999 & pd02==2

*EER 18 a�os solamente (mujeres)
replace EER1= 135.3- (edadanio*30.8) + 1*((10*pesof)+(934*tallafm)) + 25 ///
  if edadanio>=18.0000 & edadanio<=18.9999 & pd02==2

*EER hombres >19 a�os con peso normal
replace EER1= 662-(edadanio*9.53) + 1.11*((15.91*pesof)+(539.6*tallafm)) ///
  if edadanio>=19.00000 & pd02==1 & imc<=24.99999 & imc!=.

*EER mujeres >19 a�os con peso normal
replace EER1= 354-(edadanio*6.91) + 1*((9.36*pesof)+(726*tallafm)) ///
  if edadanio>=19.00000 & pd02==2 & imc<=24.99999 & imc!=.

*EER hombres >19 a�os con sobrepeso u obesidad
replace EER1= 1086 -(edadanio*10.1) + 1.12*((13.7*pesof)+(416*tallafm)) ///
  if edadanio>=19.00000 & pd02==1 & imc>=25.00000 & imc!=.

*EER mujeres >19 a�os con sobrepeso u obesidad,
replace EER1= 448 -(edadanio*7.95) + 1*((11.4*pesof)+(619*tallafm)) ///
  if edadanio>=19.00000 & pd02==2 & imc>=25.00000 & imc!=.

*********************************
gen ratio_energia=.
replace ratio_energia=kcal_usual/EER1

gen adec_energia=.
replace adec_energia=1 if ratio_energia>0.99999 & ratio_energia<1.19999 & EER!=.
replace adec_energia=2 if ratio_energia<0.99999 & EER!=.
replace adec_energia=3 if ratio_energia>1.19999 & EER!=.
label variable adec_energia "1: adecuado 2:deficiencia 3:exceso"



*Adecuacion de energia por edad categorica
svy: tabulate edad_cat11 adec_energia, row se ci cv obs format(%17.4f)

*Adecuacion de energia por sexo
svy: tabulate pd02 adec_energia, row se ci cv obs format(%17.4f)

*************************************
*PROTEINA
*Dietary Reference Intakes (DRIs): Estimated Average Requirements
*Food and Nutrition Board, Institute of Medicine, National Academies
*replace pesof=. if imc==. & edadanio>19

gen adec_prot=.
replace adec_prot=1 if prote_kg>=0.87 & edad_cat==1
replace adec_prot=0 if prote_kg<0.87 & edad_cat==1

replace adec_prot=1 if prote_kg>=0.76 & edad_cat==2
replace adec_prot=0 if prote_kg<0.76 & edad_cat==2

replace adec_prot=1 if prote_kg>=0.76 & edad_cat==3
replace adec_prot=0 if prote_kg<0.76 & edad_cat==3

replace adec_prot=1 if prote_kg>=0.73 & edad_cat==4
replace adec_prot=0 if prote_kg<0.73 & edad_cat==4

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==5
replace adec_prot=0 if prote_kg<0.66 & edad_cat==5

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==6
replace adec_prot=0 if prote_kg<0.66 & edad_cat==6

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==7
replace adec_prot=0 if prote_kg<0.66 & edad_cat==7

replace adec_prot=1 if prote_kg>=0.76 & edad_cat==8
replace adec_prot=0 if prote_kg<0.76 & edad_cat==8

replace adec_prot=1 if prote_kg>=0.71 & edad_cat==9
replace adec_prot=0 if prote_kg<0.71 & edad_cat==9

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==10
replace adec_prot=0 if prote_kg<0.66 & edad_cat==10

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==11
replace adec_prot=0 if prote_kg<0.66 & edad_cat==11

replace adec_prot=1 if prote_kg>=0.66 & edad_cat==12
replace adec_prot=0 if prote_kg<0.66 & edad_cat==12


*Adecuacion de proteina por edad categorica
svy: tabulate edad_cat11 adec_prot, row se ci cv obs format(%17.4f)



**********************************
*CHO y GRASA
*Dietary Reference Intakes (DRIs): Estimated Average Requirements
*Food and Nutrition Board, Institute of Medicine, National Academies

gen cal_prot=.
replace cal_prot=prot_usual*4
gen cal_cho=.
replace cal_cho=cho_usual*4
gen cal_grasa=.
replace cal_grasa=gr_usual*9
gen cal_grasasat=.
replace cal_grasasat=grst_usual*9
gen cal_grasamono=.
replace cal_grasamono=gmono_usual*9
gen cal_grasapoli=.
replace cal_grasapoli=gpoli_usual*9

****
gen por_prot=.
replace por_prot=cal_prot*100/kcal_usual
gen por_cho=.
replace por_cho=cal_cho*100/kcal_usual
gen por_grasa=.
replace por_grasa=cal_grasa*100/kcal_usual
gen por_grasasat=.
replace por_grasasat=cal_grasasat*100/kcal_usual
gen por_grasamono=.
replace por_grasamono=cal_grasamono*100/kcal_usual
gen por_grasapoli=.
replace por_grasapoli=cal_grasapoli*100/kcal_usual

****
*Adecuaci�n de carbohidratos segun la IOMS
gen adec_cho=.
replace adec_cho=1 if por_cho>=45 & por_cho<=65
replace adec_cho=2 if por_cho<45
replace adec_cho=3 if por_cho>65
label variable adec_cho "1: adecuado 2:deficiencia 3:exceso"

*Adecuacion de cho por edad categorica
svy: tabulate edad_cat11 adec_cho, row se ci cv obs format(%17.4f)

*Adecuacion de cho por sexo
svy: tabulate pd02 adec_cho, row se ci cv obs format(%17.4f)

************************************
*Adecuaci�n de grasas segun la IOMS
gen adec_grasa=.

** adultos
replace adec_grasa=1 if por_grasa>=20 & por_grasa<=35
replace adec_grasa=2 if por_grasa<20
replace adec_grasa=3 if por_grasa>35

** ni�os de 1 - 3 a�os
replace adec_grasa=1 if por_grasa>=30 & por_grasa<=40 & edad_cat==1
replace adec_grasa=2 if por_grasa<30 & edad_cat==1
replace adec_grasa=3 if por_grasa>40 & edad_cat==1

*** ni�os de 4 - 18 a�os
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


*Adecuacion de grasas totales por edad categorica
svy: tabulate edad_cat11 adec_grasa, row se ci cv obs format(%17.4f)

*Adecuacion de grasas totales por sexo
svy: tabulate pd02 adec_grasa, row se ci cv obs format(%17.4f)



*********************************
*FIBRA

*En base a los Adequate Intake de los DRIs IOMs

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


*Adecuacion de fibra por edad categorica
svy: tabulate edad_cat11 adec_fibra, row se ci cv obs format(%17.4f)

*Adecuacion de fibra por sexo
svy: tabulate pd02 adec_fibra, row se ci cv obs format(%17.4f)

********************************************************************************
*MICRONUTRIENTES

***************************************
*Adecuacion de vitamina A ajustada

gen adec_vitA=.
replace adec_vitA=1 if vitaj_usual>=210 & edad_cat==1
replace adec_vitA=0 if vitaj_usual<210 & edad_cat==1

replace adec_vitA=1 if vitaj_usual>=275 & edad_cat==2
replace adec_vitA=0 if vitaj_usual<275 & edad_cat==2

replace adec_vitA=1 if vitaj_usual>=445 & edad_cat==3
replace adec_vitA=0 if vitaj_usual<445 & edad_cat==3

replace adec_vitA=1 if vitaj_usual>=630 & edad_cat==4
replace adec_vitA=0 if vitaj_usual<630 & edad_cat==4

replace adec_vitA=1 if vitaj_usual>=625 & edad_cat==5
replace adec_vitA=0 if vitaj_usual<625 & edad_cat==5

replace adec_vitA=1 if vitaj_usual>=625 & edad_cat==6
replace adec_vitA=0 if vitaj_usual<625 & edad_cat==6

replace adec_vitA=1 if vitaj_usual>=625 & edad_cat==7
replace adec_vitA=0 if vitaj_usual<625 & edad_cat==7

replace adec_vitA=1 if vitaj_usual>=420 & edad_cat==8
replace adec_vitA=0 if vitaj_usual<420 & edad_cat==8

replace adec_vitA=1 if vitaj_usual>=485 & edad_cat==9
replace adec_vitA=0 if vitaj_usual<485 & edad_cat==9

replace adec_vitA=1 if vitaj_usual>=500 & edad_cat==10
replace adec_vitA=0 if vitaj_usual<500 & edad_cat==10

replace adec_vitA=1 if vitaj_usual>=500 & edad_cat==11
replace adec_vitA=0 if vitaj_usual<500 & edad_cat==11

replace adec_vitA=1 if vitaj_usual>=500 & edad_cat==12
replace adec_vitA=0 if vitaj_usual<500 & edad_cat==12

label variable adec_vitA "1:adecuado 0:inadecuado"


*** adecuacion de vitamina A por edad categorica
svy: tabulate edad_cat11 adec_vitA, row se ci cv obs format(%17.4f)

*** adecuacion de vitamina A por sexo
svy: tabulate pd02 adec_vitA, row se ci cv obs format(%17.4f)

****************************************
*Adecuacion de vitamina A sin ajustar

gen adec_vitASA=.
replace adec_vitASA=1 if va_usual>=210 & edad_cat==1
replace adec_vitASA=0 if va_usual<210 & edad_cat==1

replace adec_vitASA=1 if va_usual>=275 & edad_cat==2
replace adec_vitASA=0 if va_usual<275 & edad_cat==2

replace adec_vitASA=1 if va_usual>=445 & edad_cat==3
replace adec_vitASA=0 if va_usual<445 & edad_cat==3

replace adec_vitASA=1 if va_usual>=630 & edad_cat==4
replace adec_vitASA=0 if va_usual<630 & edad_cat==4

replace adec_vitASA=1 if va_usual>=625 & edad_cat==5
replace adec_vitASA=0 if va_usual<625 & edad_cat==5

replace adec_vitASA=1 if va_usual>=625 & edad_cat==6
replace adec_vitASA=0 if va_usual<625 & edad_cat==6

replace adec_vitASA=1 if va_usual>=625 & edad_cat==7
replace adec_vitASA=0 if va_usual<625 & edad_cat==7

replace adec_vitASA=1 if va_usual>=420 & edad_cat==8
replace adec_vitASA=0 if va_usual<420 & edad_cat==8

replace adec_vitASA=1 if va_usual>=485 & edad_cat==9
replace adec_vitASA=0 if va_usual<485 & edad_cat==9

replace adec_vitASA=1 if va_usual>=500 & edad_cat==10
replace adec_vitASA=0 if va_usual<500 & edad_cat==10

replace adec_vitASA=1 if va_usual>=500 & edad_cat==11
replace adec_vitASA=0 if va_usual<500 & edad_cat==11

replace adec_vitASA=1 if va_usual>=500 & edad_cat==12
replace adec_vitASA=0 if va_usual<500 & edad_cat==12

label variable adec_vitASA "1:adecuado 0:inadecuado"

*** adecuacion de vitamina A por edad categorica
svy: tabulate edad_cat11 adec_vitASA, row se ci cv obs format(%17.4f)

*** adecuacion de vitamina A por sexo
svy: tabulate pd02 adec_vitASA, row se ci cv obs format(%17.4f)

************************************
*Adecuacion de vitamina C

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


*Adecuacion de vitamina c por edad categorica
svy: tabulate edad_cat11 adec_vitC, row se ci cv obs format(%17.4f)
*Adecuacion de vitamina c por sexo
svy: tabulate pd02 adec_vitC, row se ci cv obs format(%17.4f)

************************************
*Adecuaci�n de folato

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

*** adecuacion de folato por edad categorica
svy: tabulate edad_cat11 adec_fol, row se ci cv obs format(%17.4f)
*** adecuacion de folato por sexo
svy: tabulate pd02 adec_fol, row se ci cv obs format(%17.4f)

************************************
*Adecuaci�n de vitamina b12

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


*Adecuacion de vitb12 por edad categorica
svy: tabulate edad_cat11 adec_vitb12, row se ci cv obs format(%17.4f)
*Adecuacion de vitb12 por sexo
svy: tabulate pd02 adec_vitb12, row se ci cv obs format(%17.4f)
*

************************************
*Adecuaci�n de vitamina b12 SIN AJUSTAR

gen adec_vitb12sa=.
replace adec_vitb12sa=1 if b12_usual>=0.7 & edad_cat==1
replace adec_vitb12sa=0 if b12_usual<0.7 & edad_cat==1

replace adec_vitb12sa=1 if b12_usual>=1 & edad_cat==2
replace adec_vitb12sa=0 if b12_usual<1 & edad_cat==2

replace adec_vitb12sa=1 if b12_usual>=1.5 & edad_cat==3
replace adec_vitb12sa=0 if b12_usual<1.5 & edad_cat==3

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==4
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==4

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==5
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==5

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==6
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==6

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==7
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==7

replace adec_vitb12sa=1 if b12_usual>=1.5 & edad_cat==8
replace adec_vitb12sa=0 if b12_usual<1.5 & edad_cat==8

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==9
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==9

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==10
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==10

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==11
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==11

replace adec_vitb12sa=1 if b12_usual>=2 & edad_cat==12
replace adec_vitb12sa=0 if b12_usual<2 & edad_cat==12

label variable adec_vitb12sa "1:adecuado 0:inadecuado"


*Adecuacion de vitb12 por edad categorica
svy: tabulate edad_cat11 adec_vitb12sa, row se ci cv obs format(%17.4f)
*Adecuacion de vitb12 por sexo
svy: tabulate pd02 adec_vitb12sa, row se ci cv obs format(%17.4f)


************************************
*Adecuaci�n de zinc ajustado

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


*Adecuacion de zinc por edad categorica
svy: tabulate edad_cat11 adec_zn, row se ci cv obs format(%17.4f)
*Adecuacion de zinc por sexo
svy: tabulate pd02 adec_zn, row se ci cv obs format(%17.4f)



************************************
*Adecuaci�n de zinc sin ajustar

gen adec_znsa=.
replace adec_znsa=1 if zn_usual>=2.5 & edad_cat==1
replace adec_znsa=0 if zn_usual<2.5 & edad_cat==1

replace adec_znsa=1 if zn_usual>=4 & edad_cat==2
replace adec_znsa=0 if zn_usual<4 & edad_cat==2

replace adec_znsa=1 if zn_usual>=7 & edad_cat==3
replace adec_znsa=0 if zn_usual<7 & edad_cat==3

replace adec_znsa=1 if zn_usual>=8.5 & edad_cat==4
replace adec_znsa=0 if zn_usual<8.5 & edad_cat==4

replace adec_znsa=1 if zn_usual>=9.4 & edad_cat==5
replace adec_znsa=0 if zn_usual<9.4 & edad_cat==5

replace adec_znsa=1 if zn_usual>=9.4 & edad_cat==6
replace adec_znsa=0 if zn_usual<9.4 & edad_cat==6

replace adec_znsa=1 if zn_usual>=9.4 & edad_cat==7
replace adec_znsa=0 if zn_usual<9.4 & edad_cat==7

replace adec_znsa=1 if zn_usual>=7 & edad_cat==8
replace adec_znsa=0 if zn_usual<7 & edad_cat==8

replace adec_znsa=1 if zn_usual>=7.3 & edad_cat==9
replace adec_znsa=0 if zn_usual<7.3 & edad_cat==9

replace adec_znsa=1 if zn_usual>=6.8 & edad_cat==10
replace adec_znsa=0 if zn_usual<6.8 & edad_cat==10

replace adec_znsa=1 if zn_usual>=6.8 & edad_cat==11
replace adec_znsa=0 if zn_usual<6.8 & edad_cat==11

replace adec_znsa=1 if zn_usual>=6.8 & edad_cat==12
replace adec_znsa=0 if zn_usual<6.8 & edad_cat==12

label variable adec_znsa "1:adecuado 0:inadecuado"


*Adecuacion de zinc por edad categorica
svy: tabulate edad_cat11 adec_znsa, row se ci cv obs format(%17.4f)
*Adecuacion de zinc por sexo
svy: tabulate pd02 adec_znsa, row se ci cv obs format(%17.4f)


************************************
*Adecuaci�n de calcio

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


*Adecuacion de calcio por edad categorica
svy: tabulate edad_cat11 adec_calc, row se ci cv obs format(%17.4f)
*Adecuacion de calcio por sexo
svy: tabulate pd02 adec_calc, row se ci cv obs format(%17.4f)


**************************************
*Adecuaci�n de Hierro (Metodo probabil�stico) National Research Council

gen edad_catfe=.
replace edad_catfe=1 if edad_cat==1
replace  edad_catfe=2 if edad_cat==2
replace  edad_catfe=3 if edad_cat==3
replace  edad_catfe=4 if edad_cat==8
replace  edad_catfe=5 if edad_cat==4
replace  edad_catfe=6 if edad_cat==9
replace  edad_catfe=7 if edad_cat==5
replace  edad_catfe=7 if edad_cat==6
replace  edad_catfe=7 if edad_cat==7
replace  edad_catfe=8 if edad_cat==10
replace  edad_catfe=8 if edad_cat==11
replace  edad_catfe=9 if edad_cat==12

*Evlauado con biodisponibilidad de 8
gen biodisp8=(feaj_usual*8)/18

*Hombres 9-13 a�os

gen riesgo=.

replace riesgo= 1 if biodisp8 <9.374 & edad_catfe==3
replace riesgo= 0.96 if biodisp8>=9.374 & biodisp8 <10.166 & edad_catfe==3
replace riesgo= 0.93 if biodisp8>=10.166 & biodisp8 <11.03 & edad_catfe==3
replace riesgo= 0.85 if biodisp8>=11.03 & biodisp8 <12.086 & edad_catfe==3
replace riesgo= 0.75 if biodisp8>=12.086 & biodisp8 <12.878 & edad_catfe==3
replace riesgo= 0.65 if biodisp8>=12.878 & biodisp8 <13.55 & edad_catfe==3
replace riesgo= 0.55 if biodisp8>=13.55 & biodisp8 <14.15 & edad_catfe==3
replace riesgo= 0.45 if biodisp8>=14.15 & biodisp8 <14.774 & edad_catfe==3
replace riesgo= 0.35 if biodisp8>=14.774 & biodisp8 <15.446 & edad_catfe==3
replace riesgo= 0.25 if biodisp8>=15.446 & biodisp8 <16.238 & edad_catfe==3
replace riesgo= 0.15 if biodisp8>=16.238 & biodisp8 <17.318 & edad_catfe==3
replace riesgo= 0.08 if biodisp8>=17.318 & biodisp8 <18.206 & edad_catfe==3
replace riesgo= 0.04 if biodisp8>=18.206 & biodisp8 <18.974 & edad_catfe==3
replace riesgo= 0 if biodisp8>=18.974 & edad_catfe==3


*Mujeres de 9-13 a�os

replace riesgo= 1 if biodisp8 <7.77 & edad_catfe==4
replace riesgo= 0.96 if biodisp8>=7.77 & biodisp8 <8.654 & edad_catfe==4
replace riesgo= 0.93 if biodisp8>=8.654 & biodisp8 <9.71 & edad_catfe==4
replace riesgo= 0.85 if biodisp8>=9.71 & biodisp8 <11.03 & edad_catfe==4
replace riesgo= 0.75 if biodisp8>=11.03 & biodisp8 <11.966 & edad_catfe==4
replace riesgo= 0.65 if biodisp8>=11.966 & biodisp8 <12.806 & edad_catfe==4
replace riesgo= 0.55 if biodisp8>=12.806 & biodisp8 <13.598 & edad_catfe==4
replace riesgo= 0.45 if biodisp8>=13.598 & biodisp8 <14.414 & edad_catfe==4
replace riesgo= 0.35 if biodisp8>=14.414 & biodisp8 <15.278 & edad_catfe==4
replace riesgo= 0.25 if biodisp8>=15.278 & biodisp8 <16.286 & edad_catfe==4
replace riesgo= 0.15 if biodisp8>=16.286 & biodisp8 <17.726 & edad_catfe==4
replace riesgo= 0.08 if biodisp8>=17.726 & biodisp8 <18.926 & edad_catfe==4
replace riesgo= 0.04 if biodisp8>=18.926 & biodisp8 <20.006 & edad_catfe==4
replace riesgo= 0 if biodisp8>=20.006 & edad_catfe==4


*Hombres de 14-18 a�os

replace riesgo= 1 if biodisp8 <12.134 & edad_catfe==5
replace riesgo= 0.96 if biodisp8>=12.134 & biodisp8 <13.022 & edad_catfe==5
replace riesgo= 0.93 if biodisp8>=13.022 & biodisp8 <14.054 & edad_catfe==5
replace riesgo= 0.85 if biodisp8>=14.054 & biodisp8 <15.446 & edad_catfe==5
replace riesgo= 0.75 if biodisp8>=15.446 & biodisp8 <16.55 & edad_catfe==5
replace riesgo= 0.65 if biodisp8>=16.55 & biodisp8 <18.71 & edad_catfe==5
replace riesgo= 0.55 if biodisp8>=18.71 & biodisp8 <18.47 & edad_catfe==5
replace riesgo= 0.45 if biodisp8>=18.47 & biodisp8 <19.406 & edad_catfe==5
replace riesgo= 0.35 if biodisp8>=19.406 & biodisp8 <20.438 & edad_catfe==5
replace riesgo= 0.25 if biodisp8>=20.438 & biodisp8 <21.686 & edad_catfe==5
replace riesgo= 0.15 if biodisp8>=21.686 & biodisp8 <23.39 & edad_catfe==5
replace riesgo= 0.08 if biodisp8>=23.39 & biodisp8 <24.782 & edad_catfe==5
replace riesgo= 0.04 if biodisp8>=24.782 & biodisp8 <25.982 & edad_catfe==5
replace riesgo= 0 if biodisp8>=25.982 & edad_catfe==5

*Mujeres de 14 - 18 a�os

replace riesgo= 1 if biodisp8 <10.766 & edad_catfe==6
replace riesgo= 0.96 if biodisp8>=10.766 & biodisp8 <11.822 & edad_catfe==6
replace riesgo= 0.93 if biodisp8>=11.822 & biodisp8 <13.094 & edad_catfe==6
replace riesgo= 0.85 if biodisp8>=13.094 & biodisp8 <14.75 & edad_catfe==6
replace riesgo= 0.75 if biodisp8>=14.75 & biodisp8 <16.07 & edad_catfe==6
replace riesgo= 0.65 if biodisp8>=16.07 & biodisp8 <17.318 & edad_catfe==6
replace riesgo= 0.55 if biodisp8>=17.318 & biodisp8 <18.518 & edad_catfe==6
replace riesgo= 0.45 if biodisp8>=18.518 & biodisp8 <19.814 & edad_catfe==6
replace riesgo= 0.35 if biodisp8>=19.814 & biodisp8 <21.422 & edad_catfe==6
replace riesgo= 0.25 if biodisp8>=21.422 & biodisp8 <23.462 & edad_catfe==6
replace riesgo= 0.15 if biodisp8>=23.462 & biodisp8 <26.918 & edad_catfe==6
replace riesgo= 0.08 if biodisp8>=26.918 & biodisp8 <30.59 & edad_catfe==6
replace riesgo= 0.04 if biodisp8>=30.59 & biodisp8 <34.526 & edad_catfe==6
replace riesgo= 0 if biodisp8>=34.526 & edad_catfe==6

*Ni�os y ni�as de 1-3 a�os

replace riesgo= 1 if biodisp8 <2.4 & edad_catfe==1
replace riesgo= 0.96 if biodisp8>=2.4 & biodisp8 <2.966 & edad_catfe==1
replace riesgo= 0.93 if biodisp8>=2.966 & biodisp8 <3.686 & edad_catfe==1
replace riesgo= 0.85 if biodisp8>=3.686 & biodisp8 <4.69 & edad_catfe==1
replace riesgo= 0.75 if biodisp8>=4.69 & biodisp8 <5.552 & edad_catfe==1
replace riesgo= 0.65 if biodisp8>=5.552 & biodisp8 <6.37 & edad_catfe==1
replace riesgo= 0.55 if biodisp8>=6.37 & biodisp8 <7.224 & edad_catfe==1
replace riesgo= 0.45 if biodisp8>=7.224 & biodisp8 <8.136 & edad_catfe==1
replace riesgo= 0.35 if biodisp8>=8.136 & biodisp8 <9.152 & edad_catfe==1
replace riesgo= 0.25 if biodisp8>=9.152 & biodisp8 <10.512 & edad_catfe==1
replace riesgo= 0.15 if biodisp8>=10.512 & biodisp8 <12.6 & edad_catfe==1
replace riesgo= 0.08 if biodisp8>=12.6 & biodisp8 <14.53 & edad_catfe==1
replace riesgo= 0.04 if biodisp8>=14.53 & biodisp8 <16.32 & edad_catfe==1
replace riesgo= 0 if biodisp8>=16.32 & edad_catfe==1

* Ni�os y ni�as de 4-8 a�os

replace riesgo= 1 if biodisp8 <3.192 & edad_catfe==2
replace riesgo= 0.96 if biodisp8>=3.192 & biodisp8 <3.936 & edad_catfe==2
replace riesgo= 0.93 if biodisp8>=3.936 & biodisp8 <4.944 & edad_catfe==2
replace riesgo= 0.85 if biodisp8>=4.944 & biodisp8 <6.312 & edad_catfe==2
replace riesgo= 0.75 if biodisp8>=6.312 & biodisp8 <7.512 & edad_catfe==2
replace riesgo= 0.65 if biodisp8>=7.512 & biodisp8 <8.668 & edad_catfe==2
replace riesgo= 0.55 if biodisp8>=8.668 & biodisp8 <9.864 & edad_catfe==2
replace riesgo= 0.45 if biodisp8>=9.864 & biodisp8 <11.136 & edad_catfe==2
replace riesgo= 0.35 if biodisp8>=11.136 & biodisp8 <12.628 & edad_catfe==2
replace riesgo= 0.25 if biodisp8>=12.628 & biodisp8 <14.592 & edad_catfe==2
replace riesgo= 0.15 if biodisp8>=14.592 & biodisp8 <17.544 & edad_catfe==2
replace riesgo= 0.08 if biodisp8>=17.554 & biodisp8 <20.28 & edad_catfe==2
replace riesgo= 0.04 if biodisp8>=20.28 & biodisp8 <23.064 & edad_catfe==2
replace riesgo= 0 if biodisp8>=23.064 & edad_catfe==2

* HOMBRES MAYORES DE 18 A�OS

replace riesgo= 1 if biodisp8 <3.98 & edad_catfe==7
replace riesgo= 0.96 if biodisp8>=3.98 & biodisp8 <4.29 & edad_catfe==7
replace riesgo= 0.93 if biodisp8>=4.29 & biodisp8 <4.64 & edad_catfe==7
replace riesgo= 0.85 if biodisp8>=4.64 & biodisp8 <5.09 & edad_catfe==7
replace riesgo= 0.75 if biodisp8>=5.09 & biodisp8 <5.44 & edad_catfe==7
replace riesgo= 0.65 if biodisp8>=5.44 & biodisp8 <5.74 & edad_catfe==7
replace riesgo= 0.55 if biodisp8>=5.74 & biodisp8 <6.03 & edad_catfe==7
replace riesgo= 0.45 if biodisp8>=6.03 & biodisp8 <6.32 & edad_catfe==7
replace riesgo= 0.35 if biodisp8>=6.32 & biodisp8 <6.65 & edad_catfe==7
replace riesgo= 0.25 if biodisp8>=6.65 & biodisp8 <7.04 & edad_catfe==7
replace riesgo= 0.15 if biodisp8>=7.04 & biodisp8 <7.69 & edad_catfe==7
replace riesgo= 0.08 if biodisp8>=7.69 & biodisp8 <8.06 & edad_catfe==7
replace riesgo= 0.04 if biodisp8>=8.06 & biodisp8 <8.49 & edad_catfe==7
replace riesgo= 0 if biodisp8>=8.49 & edad_catfe==7

* MUJERES MAYORES DE 18 A�OS

replace riesgo= 1 if biodisp8 <4.18 & edad_catfe==8
replace riesgo= 0.96 if biodisp8>=4.18 & biodisp8 <4.63 & edad_catfe==8
replace riesgo= 0.93 if biodisp8>=4.63 & biodisp8 <5.19 & edad_catfe==8
replace riesgo= 0.85 if biodisp8>=5.19 & biodisp8 <5.94 & edad_catfe==8
replace riesgo= 0.75 if biodisp8>=5.94 & biodisp8 <6.55 & edad_catfe==8
replace riesgo= 0.65 if biodisp8>=6.55 & biodisp8 <7.13 & edad_catfe==8
replace riesgo= 0.55 if biodisp8>=7.13 & biodisp8 <7.73 & edad_catfe==8
replace riesgo= 0.45 if biodisp8>=7.73 & biodisp8 <8.39 & edad_catfe==8
replace riesgo= 0.35 if biodisp8>=8.39 & biodisp8 <9.21 & edad_catfe==8
replace riesgo= 0.25 if biodisp8>=9.21 & biodisp8 <10.36 & edad_catfe==8
replace riesgo= 0.15 if biodisp8>=10.36 & biodisp8 <12.49 & edad_catfe==8
replace riesgo= 0.08 if biodisp8>=12.49 & biodisp8 <14.85 & edad_catfe==8
replace riesgo= 0.04 if biodisp8>=14.85 & biodisp8 <17.51 & edad_catfe==8
replace riesgo= 0 if biodisp8>=17.51 & edad_catfe==8

* Mujeres post-menopausicas

replace riesgo= 1 if biodisp8 <2.73 & edad_catfe==9
replace riesgo= 0.96 if biodisp8>=2.73 & biodisp8 <3.04 & edad_catfe==9
replace riesgo= 0.93 if biodisp8>=3.04 & biodisp8 <3.43 & edad_catfe==9
replace riesgo= 0.85 if biodisp8>=3.43 & biodisp8 <3.93 & edad_catfe==9
replace riesgo= 0.75 if biodisp8>=3.93 & biodisp8 <4.30 & edad_catfe==9
replace riesgo= 0.65 if biodisp8>=4.30 & biodisp8 <4.64 & edad_catfe==9
replace riesgo= 0.55 if biodisp8>=4.64 & biodisp8 <4.97 & edad_catfe==9
replace riesgo= 0.45 if biodisp8>=4.97 & biodisp8 <5.30 & edad_catfe==9
replace riesgo= 0.35 if biodisp8>=5.30 & biodisp8 <5.68 & edad_catfe==9
replace riesgo= 0.25 if biodisp8>=5.68 & biodisp8 <6.14 & edad_catfe==9
replace riesgo= 0.15 if biodisp8>=6.14 & biodisp8 <6.80 & edad_catfe==9
replace riesgo= 0.08 if biodisp8>=6.80 & biodisp8 <7.36 & edad_catfe==9
replace riesgo= 0.04 if biodisp8>=7.36 & biodisp8 <7.88 & edad_catfe==9
replace riesgo= 0 if biodisp8>=7.88 & edad_catfe==9

*Total nacional
svy: mean riesgo if riesgo!=.

*Por edad
*Categorias de edad con sexo para ni�os menores de 4 a�os (hierro)

gen edad_cat13=1 if edad_cat==1 & pd02==1
replace edad_cat13=2 if edad_cat==1 & pd02==2
replace edad_cat13=3 if edad_cat==2 & pd02==1
replace edad_cat13=4 if edad_cat==2 & pd02==2
replace edad_cat13=5 if edad_cat==3
replace edad_cat13=6 if edad_cat==4
replace edad_cat13=7 if edad_cat==5
replace edad_cat13=8 if edad_cat==6
replace edad_cat13=9 if edad_cat==7

replace edad_cat13=10 if edad_cat==8
replace edad_cat13=11 if edad_cat==9

replace edad_cat13=12 if edad_cat==10
replace edad_cat13=13 if edad_cat==11
replace edad_cat13=14 if edad_cat==12

**********
svy: mean riesgo if riesgo!=. & edad_cat13==1
svy: mean riesgo if riesgo!=. & edad_cat13==2
svy: mean riesgo if riesgo!=. & edad_cat13==3
svy: mean riesgo if riesgo!=. & edad_cat13==4
svy: mean riesgo if riesgo!=. & edad_cat13==5
svy: mean riesgo if riesgo!=. & edad_cat13==6
svy: mean riesgo if riesgo!=. & edad_cat13==7
svy: mean riesgo if riesgo!=. & edad_cat13==8
svy: mean riesgo if riesgo!=. & edad_cat13==9
svy: mean riesgo if riesgo!=. & edad_cat13==10
svy: mean riesgo if riesgo!=. & edad_cat13==11
svy: mean riesgo if riesgo!=. & edad_cat13==12
svy: mean riesgo if riesgo!=. & edad_cat13==13
svy: mean riesgo if riesgo!=. & edad_cat13==14

* Por sexo

svy: mean riesgo if riesgo!=. & pd02==1
svy: mean riesgo if riesgo!=. & pd02==2


*******************************************************************************
*3. CONTRIBUCION PORCENTUAL DE LA DIETA PARA MACRONUTRIENTES*******************


*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR SEXO

local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(pd02) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR GRUPO �TNICO
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(gr_etn) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR SUBREGION
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(subreg) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR QUINTIL
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(quint) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR GRUPO DE EDAD SEXO
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(edad_cat11) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}

*CONTRIBUCI�N PORCENTUAL DE MACRONUTRIENTES POR zonas de planificacion
local V por_prot por_cho por_grasa por_grasasat
foreach Y in `V' {
	tabstat `Y'  [aw= pw], by(zonas_planificacion) ///
	  stat(n mean p50 p25 p75 p90 p95 sem sd) c(statistics)
}


********************************************************************************
*4.CONSUMO PROMEDIO DE GRUPOS DE ALIMENTOS EN GRAMOS************************

use ensanut_f11_consumo_parteb.dta, clear
*Preparaci�n de base:
*Variables de identificadores & svyset
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

*Grupos de analisis / grupos de edad:
gen edadc=.
replace edadc=1 if edad_cat==1 & pd02==1
replace edadc=2 if edad_cat==1 & pd02==2
replace edadc=3 if edad_cat==2 & pd02==1
replace edadc=4 if edad_cat==2 & pd02==2
replace edadc=5 if edad_cat==3
replace edadc=6 if edad_cat==8
replace edadc=7 if edad_cat==4
replace edadc=8 if edad_cat==9
replace edadc=9 if edad_cat==5
replace edadc=10 if edad_cat==10
replace edadc=11 if edad_cat==6
replace edadc=12 if edad_cat==11
replace edadc=13 if edad_cat==7
replace edadc=14 if edad_cat==12

lab var edadc "Categorias de edad con sexo para todos"
lab def edadc 1 "1 a 3 a�os hombres" 2 "1 a 3 a�os mujeres" ///
  3 "4 a 8 a�os hombres " 4 "4 a 8 a�os mujeres " 5 "9 de 13 a�os hombres" ///
  6 "9 de 13 a�os mujeres" 7 "14 a 18 a�os hombres" 8 "14 a 18 a�os mujeres" ///
  9  "19 a 30 a�os hombres" 10 "19 a 30 a�os mujeres" ///
  11 "31 a 50 a�os hombres" 12 "31 a 50 a�os mujers" ///
  13 "51 a 60 a�os hombres" 14 "51 a 60 a�os mujeres"
lab val edadc edadc

************************************
*CONSUMO PROMEDIO TOTAL
*Collapse
collapse (sum) f11220f (mean) pw provincia ///
  zonas_planificacion gr_etn quint area idsector , by(idpers edadc grupo_ali14)

****** Tabla
svyset idsector [pweight=pw], strata (area)
tabout grupo_ali14 edadc using gralitabledadcatf11220f1.txt, ///
  replace c(mean f11220f lb ub) svy sum f(1.1)

*CONSUMO PROMEDIO DE FRUTAS Y VERDURAS
recode grupo_ali14 (4 6=4)

***** Collapse
collapse (sum) f11220f (mean) pw provincia zonas_planificacion ///
  gr_etn quint area idsector, ///
  by(idpers edadc grupo_ali14)

****** Tabla
svyset idsector [pweight=pw], strata (area)
tabout grupo_ali14 edadc using frutasyverduras.txt, ///
  replace c(mean f11220f lb ub) svy sum f(1.1)

*An�lisis de Consumo  ensanut 2012 termina ah�**********************************

