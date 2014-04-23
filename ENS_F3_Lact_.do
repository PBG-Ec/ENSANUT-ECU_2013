******************************************************************************
**************Encuesta Nacional de Salud y Nutrici�n 2011-2013****************
*********************Tomo 1 **************************************************
*********************Lactancia Materna****************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire
Investigadores y autores del informe: Wilma Freire
  Elaboracion : Wilma Freire freirewi@gmail.com
  Cynthia Mendoza, UISA-UASB
  Philippe Belmont Guerr�n MSP-ENSANUT philippebelmont@gmail.com
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
*Preparaci�n de base:

*Variables de identificadores & svyset
clear all
set more off
*Ingresar el directorio de las bases:
cd ""
use ensanut_f3_lactancia.dta,clear

*Identificador de personas / Hogar / vivienda
gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
format idhog %20.0f
gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
format idviv %20.0f
gen idptemp=hogar*10^2+persona
egen  idpers=concat (idviv idptemp),format(%20.0f)
drop idptemp
*Identificador de sector :
gen double idsector = ciudad*10^6+zona*10^3+sector
lab var idviv "Identificador de vivienda"
lab var idpers "Identificador de persona"
lab var idsector "Identificador de sector"
lab var idhog "Identificador de hogar"

*Identificador de madres
gen idptemp=hogar*10^2+f3cui
egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp


*Variables de cruce:
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(pd02 area gr_etn subreg zonas_planificacion ///
  provincia quint edaddias pps04)
drop if _merge==2
drop _merge

*Variables de cruce : Nivel de instruccion madre /padre
**Nivel de instrucci�n de la madre**
rename idpers idpers1
rename idmadre idpers
merge m:1 idpers using ensanut_f1_personas.dta, keepusing (pd19a edadmes)
rename edadmes edadmesmadre
rename idpers idmadre
rename idpers1 idpers
rename pd19a pd19aMadre
drop if  _merge==2
drop _merge

**Edad de la madre al momento de nacimiento del hijo en a�os
gen edadanmadran=(edadmesmadre - (edaddias/30))/12
gen grupedadmadr=1 if (edadanmadran >=12& edadanmadran < 15)
replace grupedadmadr=2 if (edadanmadran >=15& edadanmadran < 20)
replace grupedadmadr=3 if (edadanmadran >=20& edadanmadran < 35)
replace grupedadmadr=4 if (edadanmadran>=35)

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

******************************************************************************
*1. INICIO DE LACTANCIA MATERNA
*1.1 Amam antes de 24 h
*1.1bis Amam despues de 24 h
gen  dnin12_24inP = 2 if ( edaddias <730)
replace dnin12_24inP = 1 if ( edaddias <365)
label variable dnin12_24inP "Ni�os nacidos 12 24"
gen f31033g = f3103
replace f31033g=1 if f31033g==2
label value f31033g F3013

*Por quintil Economico
local i = 1
while `i' <=5 {
	svy: tabulate  dnin12_24inP f31033g, subpop(if (quint== `i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  dnin12_24inP f31033g , subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate  dnin12_24inP f31033g, row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  dnin12_24inP f31033g, count cv se format(%17.4f) cellwidth(20)

*Por ZONAS DE PLANIFICACION
local i = 1
while `i' <=9 {
	svy: tabulate  dnin12_24inP f31033g,subpop(if(zonas_planificacion==`i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  dnin12_24inP f31033g,subpop(if(zonas_planificacion==`i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate  dnin12_24inP f31033g, row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  dnin12_24inP f31033g , ///
  count cv se   format(%17.4f) cellwidth(20)

********************************************************************************
*2. LACTANCIA MATERNA EXCLUSIVA ANTES DE LOS 6MESES

*Lactantes de cero a 6 mes de edad que recibieron solamente
*leche materna el d�a anterior
generate dnin0a5amayerP = 1 if (edaddias != . & edaddias <=183 ///
  & f3201==1 & f3401==2 & f3403==2)
replace dnin0a5amayerP = 0 if (edaddias != . & edaddias <=183 ///
  & dnin0a5amayerP==.)
label variable dnin0a5amayerP "� Lactantes0-6m solo leche materna"

*Lactantes de cero a 5 mes de edad que recibieron solamente
*leche materna el d�a anterior
generate dnin5amayerP = 1 if ( edaddias <=183 & f3201==1 & ///
  f3401==2 & f3403==2)
replace dnin5amayerP = 0 if (edaddias <=183 & dnin5amayerP==.)
label variable dnin5amayerP "� Lactantes0-5m solo leche materna"

*Lactantes de cero a 3 mes de edad que recibieron solamente
*leche materna el d�a anterior
generate dnin3amayerP = 1 if (edaddias <=122 & f3201==1 &  f3401==2 & f3403==2)
label variable dnin3amayer "� Lactantes0-3m solo leche materna"
replace dnin3amayerP = 0 if (edaddias <=122 & dnin3amayerP==.)

*Grupos de Edad
gen grmayer=edaddias
recode grmayer (min/60=1) (61/121=2) (122/183=3) (184/max=.)

*******************Cuadros
*****Por Quintil Economico :
**Variable de dnin0a5amayerP:
svy: tabulate grmayer dnin0a5amayerP,  ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  grmayer dnin0a5amayerP, ///
  count cv se   format(%17.4f) cellwidth(20)

*Por quintil Economico Lact Exclu 0_1 2_3 4_5
local i = 1
while `i' <=5 {
	svy: tabulate grmayer dnin0a5amayerP, subpop(if (quint== `i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  grmayer dnin0a5amayerP, subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
*Por etnia 1 2_3 4
local i = 1
while `i' <=4 {
	svy: tabulate grmayer dnin0a5amayerP, subpop(if ( gr_etn== `i')) ///
	  row  ci obs format(%17.4f)
	svy: tabulate  grmayer dnin0a5amayerP, subpop(if ( gr_etn== `i')) ///
	  count cv se   format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate grmayer dnin0a5amayerP, row  ci obs format(%17.4f)
svy: tabulate grmayer dnin0a5amayerP, count cv se format(%17.4f)

*Por nivel de instruccion de la Madre
gen pd19aMadrerc=pd19aMadre
replace pd19aMadrerc=3 if  pd19aMadre==2 | pd19aMadre==1
replace pd19aMadrerc=8 if  pd19aMadre>=8
lab def pd19am 3 "Ninguno" 4 "Primaria" 5 "Secudaria" 6 "Educaci�n B�sica" ///
  7 "Bachillierato" 8 "Superior a Bachillierato"
lab val pd19aMadrerc pd19am

local i = 3
while `i' <=8 {
	svy: tabulate grmayer dnin0a5amayerP, subpop(if ( pd19aMadrerc== `i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  grmayer dnin0a5amayerP, subpop(if ( pd19aMadrerc== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate grmayer dnin0a5amayerP, row ci obs format(%17.4f) cellwidth(20)
svy: tabulate grmayer dnin0a5amayerP, count cv se format(%17.4f) cellwidth(20)

*Por quintil Economico Lact Exclu 0_3
gen grmayer03=grmayer
recode   grmayer03 (3/max=.)

svy: tabulate grmayer03 dnin0a5amayerP, ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  grmayer03 dnin0a5amayerP, ///
  count cv se   format(%17.4f) cellwidth(20)

*Por quintil Economico Lact Exclu 0_1 2_3 4_5
local i = 1
while `i' <=5 {
	svy: tabulate grmayer03 dnin0a5amayerP, subpop(if (quint== `i')) ///
	  row  ci obs format(%17.4f)
	svy: tabulate  grmayer03 dnin0a5amayerP, subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f)
	local i = `i' + 1
	}
svy: tabulate  dnin12_24inP f31033g, row  ci obs format(%17.4f)
svy: tabulate  dnin12_24inP f31033g, count cv obs format(%17.4f)

*Por grupo de edad de la madre
svy: mean dnin5amayerP
svy:tabulate grupedadmadr  dnin5amayerP, row ci obs format(%17.4f)

*Por Area
svy: mean dnin5amayerP
svy:tabulate area  dnin5amayerP, row ci obs format(%17.4f)

*Replica del cuadro 2.2 :
gen pd19aMadre2 = pd19aMadre
replace pd19aMadre2=8 if (pd19aMadre==9 | pd19aMadre==10)
svy:tabulate pd19aMadre2  dnin5amayerP, row ci obs format(%17.4f)

********************************************************************************
*3. LACTANCIA MATERNA CONTINUA
*Denominador
generate dnin12a15P = 1 if ( edaddias >365& edaddias <=488)& (f3302<=2)
label variable dnin12a15P "Ni�os de 12 a 15 meses de edad"


generate dnin12a15amayerP = 1 if (( edaddias >365 & edaddias <=488)&(f3302==1))
replace dnin12a15amayerP = 0 if (edaddias >365 & edaddias <=488 & f3302<=2 & ///
  dnin12a15amayerP==.)
label variable dnin12a15amayerP "� 12-15m amamantados el d�a anterior"
gen n=1

svy: mean  dnin12a15amayerP
svy: tab dnin12a15P dnin12a15amayerP , row ci obs format(%17.4f)
svy: tab  dnin12a15amayerP n, obs count format (%17.4f)

*3.3 Lact matern continua consumo

gen gred0_8  = 0 if ( edaddia <=30)
replace  gred0_8 = 1 if (edaddia >30 & edaddia <=61)
replace  gred0_8 = 2 if (edaddia >61 & edaddia <=91)
replace  gred0_8 = 3 if (edaddia >91 & edaddia <=122)
replace  gred0_8 = 4 if (edaddia >122 & edaddia <=152)
replace  gred0_8 = 5 if (edaddia >152 & edaddia <=183)
replace  gred0_8 = 6 if (edaddia >183 & edaddia <=273)
label variable gred0_8  "Ni�os de 0 0a1 2a3 y 4a5 5a6 6a8 mes de edad "
lab def  grep08 0 "menor a 1 mes"1 "de 1 a 2 meses " 2 "de 2 a 3 meses" ///
  3 "de 3 a 4 meses" 4 "de 4 a 5 meses" 5 "de 5 a 6 meses" 6 "de 6 a 8 meses"
lab val gred0_8 grep08
gen gred0_6  = gred0_8
replace gred0_6  = . if ( gred0_8 ==6)
label variable gred0_6  "Ni�os de 0 0a1 2a3 y 4a5 5a6 mes de edad "

global Y f3401 f34021a f34023a f34024a f34025a f34026a f34027a f34028a ///
  f34029a f340210a f3403 f34041 f34042 f34043 f34044 f34045 f34046 f34047 ///
  f34048 f34049 f340410 f340411 f340412 f340413 f340414 f340415 f340416 ///
  f340417 f340418 f340419 f340420
foreach V of global Y {
	svy: tab  gred0_8 `V', subpop(if gred0_8<6) ///
	  row ci cv obs format(%17.4f) cellwidth(20)
	svy: tab  gred0_8 `V', subpop(if gred0_8<6) ///
	  count format(%17.4f) cellwidth(20)
	}
svy: tabulate gred0_6 f3401,  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  gred0_6 f3401,  count cv se   format(%17.4f) cellwidth(20)

*Por quintil Economico Comsumio algun liquido diferente  0_1_2_3_4_5_6
local i = 1
while `i' <=5 {
	svy: tabulate gred0_8 f3401, subpop(if (quint== `i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  gred0_8 f3401, subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}

*Por quintil Economico Comsumio algun liquido diferente  0_1_2_3_4_5_6
local i = 1
while `i' <=5 {
	svy: tabulate  f3401, subpop(if (gred0_6!=. & quint== `i')) ///
	  ci obs  format(%17.4f) cellwidth(20)
	svy: tabulate  f3401, subpop(if (gred0_6>=1 & quint== `i')) ///
	  count obs cv   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate  f3401, subpop(if (gred0_6!=. )) ///
  ci obs  format(%17.4f) cellwidth(20)
svy: tabulate  f3401, subpop(if (gred0_6==1 )) ///
  ci  format(%17.4f) cellwidth(20)
svy: tabulate  f3401, subpop(if (gred0_6==1 )) ///
  count obs ci   format(%17.4f) cellwidth(20)


********************************************************************************
*4. INTRODUCCI�N DE ALIMENTOS S�LIDOS, SEMIS�LIDOS O SUAVES

gen  dnin6a8aliayerP = 1 if (edaddias >183 & edaddias <=273 & f3403==1 )
replace dnin6a8aliayerP = 0 if (edaddias >183 & edaddias <=273 & f3302<=2 ///
	& dnin6a8aliayerP==.)
label variable dnin6a8aliayerP "Lactantes 6-8m ali./sol./semisol./suaves"

svy: tabulate   dnin6a8aliayerP, obs ci   format(%17.4f) cellwidth(20)

*7.17 Sp
generate dnin0a8aliayerP = 1 if (edaddias <=273 & f3403==1)
replace   dnin0a8aliayerP = 0 if (edaddias <=273 & dnin0a8aliayerP==.)
svy: tabulate   dnin0a8aliayerP,  obs ci   format(%17.4f) cellwidth(20)



********************************************************************************
*5. DIVERSIDAD ALIMENTARIA M�NIMA
*Denominador
generate dnin6a23divP = 1 if ( edaddias >183& edaddias <=730) & (f3302<=2)
label variable dnin6a23divP "Ni�os de 6 a 23 meses de edad"
*Grupos de alimentos:
generate dgrup1P = 1 if (f34041==1 | f34042==1 | f34044==1)
replace dgrup1P = 0 if (dnin6a23divP==1 & dgrup1P==.)
label variable dgrup1P "cereales, ra�ces y tub�rculos"
generate dgrup2P = 1 if (f340412==1)
replace dgrup2P = 0 if (dnin6a23divP== 1 & dgrup2P==.)
label variable dgrup2P "legumbres y nueces"
generate dgrup3P = 1 if (f340413==1)
replace dgrup3P = 0 if (dnin6a23divP==1& dgrup3P==.)
label variable dgrup3P "l�cteos (leche, yogurt, queso)"
generate dgrup4P = 1 if (f34048==1 | f34049==1 | f340411==1)
replace dgrup4P = 0 if (dnin6a23divP==1& dgrup4P==.)
label variable dgrup4P "carnes (carne, pescado,aves e h�gado...)"
generate dgrup5P = 1 if (f340410==1)
replace dgrup5P = 0 if (dnin6a23divP==1& dgrup5P==.)
label variable dgrup5P "huevos"
generate dgrup6P = 1 if (f34043==1 | f34045==1 | f34046==1)
replace dgrup6P = 0 if (dnin6a23divP==1& dgrup6P==.)
label variable dgrup6P "frutas y verduras ricas en vitamina A"
generate dgrup7P = 1 if (f34047==1)
replace dgrup7P = 0 if (dnin6a23divP==1& dgrup7P==.)
label variable dgrup7P "otras frutas y verduras"
*Suma de la diversidad de alimentos:
generate dgrupsum =(dgrup1+dgrup2+dgrup3+dgrup4+dgrup5+dgrup6+dgrup7)
label variable dgrupsum "Suma de todos los grupos"

*Grupos de edad Ni�os amamantados de 6 a 23 meses de edad
gen  grdnin6a23divAMP= edaddias if(f3302==1)
recode   grdnin6a23divAMP (min/183=.) (184/365=1) (366/549=2) ///
  (550/730=3) (731/max=.)
lab def grninam 1 "6 a 11 meses" 2 "12 a 17 meses" 3 "18 a 23 meses"
lab val grdnin6a23divAMP grninam
*Ni�os amamantados de 6 a 23 meses de edad que recibieron alimentos
*de >=4 grupos alimentarios durante el d�a anterior
generate dnin6a23divayerAMP = 1 if ( edaddias >183 & edaddias<=730 & ///
  f3302==1 &  dgrupsum>=4)
replace dnin6a23divayerAMP = 0 if (edaddias >183 & edaddias<=730 & ///
  f3302==1 & dnin6a23divayerAMP==.)
label variable dnin6a23divayerAMP ///
  "� amamantados 6-23m que recibieron alimentos de >=4 grupos alimentarios"

*Grupos de edad ninos NO Amamantados
gen  grdnin6a23divNOAMP= edaddias if(f3302==2)
recode   grdnin6a23divNOAMP (min/183=.) (184/365=1) ///
  (366/549=2) (550/730=3) (731/max=.)
lab val grdnin6a23divNOAMP grninam
*Ni�os NO amamantados de 6 a 23 meses de edad que recibieron alimentos
*de >=4 grupos alimentarios durante el d�a anterior
generate dnin6a23divayerNOAMP = 1 if (edaddias >183 & ///
  edaddias<=730 & f3302==2 & dgrupsum>=4)
replace dnin6a23divayerNOAMP = 0 if (edaddias >183 & edaddias <=730 ///
  & f3302==2 & dnin6a23divayerNOAMP==.)
label variable dnin6a23divayerNOAMP ///
  "� amamantados 6-23m que recibieron alimentos de >=4 grupos alimentarios"
*Cuadros
svy: tabulate  grdnin6a23divAMP  dnin6a23divayerAMP , ///
  row obs ci   format(%17.4f) cellwidth(20)
svy: tabulate  grdnin6a23divNOAMP  dnin6a23divayerNOAMP , ///
  row obs ci   format(%17.4f) cellwidth(20)

********************************************************************************
*6. FRECUENCIA DE COMIDAS
*6.1 Primer Indicador (ni�os amamantados)
*Ni�os amamantados de 6 a 23 meses de edad que recibieron alimento s�lidos,
*semis�lidos o suaves el n�mero m�nimo de veces o m�s durante el d�a anterior
generate dnin6a23aliminAMayerP = 1 if (edaddias >183 & edaddias <=730 & ///
  f3302==1 & f3406>=3 & f3406<=16)
replace dnin6a23aliminAMayerP = 0 if ( edaddias >183 & edaddias <=730 & ///
  f3302==1 & f3406<=16 & dnin6a23aliminAMayerP==.)

label variable dnin6a23aliminAMayerP ///
  "Ni�os ama.6-23 n�>=minimo de ali.s�lidos,semis�l./suav."

svy: tabulate  grdnin6a23divAMP  dnin6a23aliminAMayerP , ///
 row  obs ci   format(%17.4f) cellwidth(20)

*6.2 Ni�os NO amamantados
*Ni�os NO amamantados de 6 a 23 meses de edad que recibieron alimento s�lidos,
*semis�lidos o suaves el n�mero m�nimo de veces o m�s durante el d�a anterior
gen dnin6a23aliminNOAMayerP = 1 if (edaddias >183 & edaddias <=730 & ///
  f3302==2 &  f3406<=16 & f3406>=4)
replace dnin6a23aliminNOAMayerP = 0 if (edaddias >183& edaddias <=730 & ///
  f3302==2 & f3406<=16 & dnin6a23aliminNOAMayerP==.)
label variable dnin6a23aliminNOAMayerP ///
  "Ni�os no ama.6-23 recibiendo el n�>=minimo de ali.s�lidos,semis�l./suav."

svy: tabulate  grdnin6a23divNOAMP  dnin6a23aliminNOAMayerP , ///
 row  obs ci   format(%17.4f) cellwidth(20)




********************************************************************************
*7. INDICADOR COMPUESTO SUMARIO DE ALIMENTACI�N DE LACTANTES Y NI�OS PEQUE�OS
*Ni�os amamantados de 6 a 23 meses de edad que tuvieron por lo menos la
*diversidad alimentaria m�nima y la frecuencia m�nima de comidas

generate dnin6a23divfrecAM = 1 if (edaddias >183 & edaddias <=730 &  f3302==1 & ///
  dgrupsum>=4 & dnin6a23aliminAMayerP==1)
replace dnin6a23divfrecAM = 0 if (edaddias >183 & edaddias <=730 & f3302==1 & ///
  f3406<=16 & dnin6a23divfrecAM==.)
label variable dnin6a23divfrecAM ///
  "Ni�os ama.6-23 recibiendo diversidad ali.m�n. y la fre.m�n.comidas"
*Ni�os no amamantados de 6 a 23 meses de edad que recibieron por lo menos
*2 tomas de leche y que recibieron por lo menos la diversidad alimentaria
*m�nima (sin incluir tomas de leche) y la frecuencia m�nima de comidas
*durante el d�a anterior
*Para ni�os NO amamantados excluir la leche en el indicador de diversidad m�nima
generate dgrupsumNOlec =(dgrup1+dgrup2+dgrup4+dgrup5+dgrup6+dgrup7)
label variable dgrupsumNOlec "Suma de todos los grupos excepto leche"
generate dnin6a23divfrecNOAM = 1 if (edaddias >183 & edaddias <=730 &  f3302==2 & ///
  dgrupsumNOlec>=4 & dnin6a23aliminNOAMayer==1 & f3413==1)
replace dnin6a23divfrecNOAM = 0 if (edaddias >183 & edaddias <=730 &  f3302==2 & ///
  f3406<=16 & dnin6a23divfrecNOAM==.)
label variable dnin6a23divfrecNOAM  ///
  "� no ama.6-23 recibiendo min.2 tomas de leche& div.alim.min.& frec.m�n.comidas"

*Prevalencia de ni�os Amamantados que tuvieron la diversidad de alim min.
*y frec min. por grupos de edad
forval x=1/3 {
	di "Grupo de edad:""`:label (grdnin6a23divAMP) `x''"
	svy: mean  	dnin6a23divfrecAM, subpop(if  grdnin6a23divAMP==`x')
	}
*Prevalencia de ni�os No Amamantados que tuvieron la diversidad de alim min.
*y frec min. por grupos de edad
forval x=1/3 {
	di "Grupo de edad:""`:label (grdnin6a23divAMP) `x''"
	svy: mean  	dnin6a23divfrecNOAM, subpop(if  grdnin6a23divNOAMP==`x')
	}
*Cuadros
svy: tabulate  grdnin6a23divAMP dnin6a23divfrecAM  , ///
  row obs ci   format(%17.4f) cellwidth(20)
svy: tabulate  grdnin6a23divNOAMP dnin6a23divfrecNOAM  , ///
  row obs ci   format(%17.4f) cellwidth(20)



********************************************************************************
*8. CONSUMO DE ALIMENTOS RICOS EN HIERRO O FORTIFICADOS CON HIERRO

*Ni�os de 6 a 23 meses de edad que durante el d�a anterior recibieron un
*alimento especialmente dise�ado para lactantes y ni�os peque�os y
*que estaba fortificado con hierro o un alimento que fue fortificado en el
*hogar con un producto que inclu�a hierro

*TOTAL de alimentos
gen dnin6a23alihierTOTayerP = 1 if (edaddias >183 & edaddias <=730 ///
  & (f34048==1 | f34049==1))
replace dnin6a23alihierTOTayerP = 0 if (edaddias >183 & edaddias <=730 & ///
  dnin6a23alihierTOTayerP==.)

label variable dnin6a23alihierTOTayerP "� 6-23m recibiendo ali.rico en hierro"

*Suplementos
gen dnin6a23alihiersuplayerP = 1 if (edaddias >183 & edaddias <=730 & pps04==1)
replace dnin6a23alihiersuplayerP = 0 if (edaddias >183 & edaddias <=730 & ///
  dnin6a23alihiersuplayerP==.)
label variable dnin6a23alihiersuplayerP ///
  "� 6-23m recibiendo ali.rico en hierro y suppl"

*Alimentos ricos en hierro
gen dnin6a23alihieraayerP = 1 if (edaddias >183 & edaddias <=730 & ///
  (f34048==1 | f34049==1))
replace dnin6a23alihieraayerP = 0 if (edaddias >183 & edaddias <=730 & ///
  dnin6a23alihieraayerP==.)
label variable dnin6a23alihieraayerP ///
  "� 6-23m recibiendo ali.rico en hierro y forti"

gen  grdnin6a23y = edaddias
recode grdnin6a23y (min/183=.) (184/365=1) (366/549=2) (550/730=3) (731/max=.)
lab def grdnin6a23y 1 "6 a 11 meses" 2 "12 a 17 meses" 3 "18 a 23 meses"
lab val grdnin6a23y grdnin6a23y

*Alimentos ricos en hierro sin suppl
svy: tabulate  grdnin6a23y dnin6a23alihierTOTayerP, ///
  row obs ci   format(%17.4f) cellwidth(20)
*Solo suppl hierro
svy: tabulate  grdnin6a23y  dnin6a23alihiersuplayerP, ///
  row obs ci   format(%17.4f) cellwidth(20)

********Por quintiles Economicos 6_11 12-17 18-23
***Alimentos ricos en hierro
svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  grdnin6a23y dnin6a23alihierTOTayerP, ///
  count cv se   format(%17.4f) cellwidth(20)
local i = 1
while `i' <=5 {
	svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
	  subpop(if (quint== `i')) row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  grdnin6a23y dnin6a23alihierTOTayerP, ///
	  subpop(if (quint== `i')) count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
  row  ci obs format(%17.4f) cellwidth(20)

*total
local i = 1
while `i' <=5 {
	svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
	  subpop(if (quint== `i')) row  ci  format(%17.4f) cellwidth(20)
	svy: tabulate  grdnin6a23y dnin6a23alihierTOTayerP, ///
	  subpop(if (quint== `i')) obs count  se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
  row  ci  format(%17.4f) cellwidth(20)
svy: tabulate grdnin6a23y dnin6a23alihierTOTayerP, ///
  obs count  se   format(%17.4f) cellwidth(20)

*Solo supplementos de hierro
local i = 1
while `i' <=5 {
	svy: tabulate grdnin6a23y dnin6a23alihiersuplayerP, ///
	  subpop(if (quint== `i')) row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  grdnin6a23y dnin6a23alihiersuplayerP, ///
	  subpop(if (quint== `i')) count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate grdnin6a23y dnin6a23alihiersuplayerP, ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate grdnin6a23y dnin6a23alihiersuplayerP, ///
  count cv se   format(%17.4f) cellwidth(20)

********************************************************************************
*9. NI�OS QUE FUERON AMAMANTADOS ALGUNA VEZ

gen dnin24amalgP = 1 if (edaddias!=. & edaddias < 730 & f3101==1)
replace dnin24amalgP = 0 if (edaddias!=. & edaddias < 730 & dnin24amalgP==.)
label variable dnin24amalgP "� =<24m que fueron amamantados alguna vez"

gen dnin12amalgP = 1 if (edaddias!=. & edaddias < 365 & f3101==1)
replace dnin12amalgP = 0 if (edaddias!=. & edaddias < 365 & dnin12amalgP==.)
label variable dnin12amalgP "� =<12m que fueron amamantados alguna vez"

*12a24
gen dnin12a24amalgP = 1 if (edaddias!=.  & edaddias >365 & ///
  edaddias <730 & f3101==1)
replace dnin12a24amalgP = 0 if (edaddias!=. & edaddias >365 & ///
  edaddias <730 & dnin12a24amalgP==.)
label variable dnin12a24amalgP "� 12a24m que fueron amamantados alguna vez"

****Por quintiles economicos
gen  gramav0_12_24P= edaddias
recode gramav0_12_24P (min/364=1) (365/730=2) (731/max=.)

local i = 1
while `i' <=5 {
	svy: tabulate gramav0_12_24P dnin24amalgP, ///
	  subpop(if (quint== `i')) row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  gramav0_12_24P dnin24amalgP, ///
	  subpop(if (quint== `i')) count cv se format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate gramav0_12_24P dnin24amalgP, ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  gramav0_12_24P dnin24amalgP, ///
  count cv se   format(%17.4f) cellwidth(20)

********************************************************************************
*10. LACTANCIA MATERNA CONTINUA A LOS 2 A�OS
*Denominador
generate dnin20a23amayerP = 1 if (edaddias >610& edaddias <=730 & f3302==1)
replace dnin20a23amayerP = 0 if (edaddias >610& edaddias <=730 & f3302<=2 & ///
  dnin20a23amayerP==.)
label variable dnin20a23amayerP "� 20-23m amamantados durante el d�a anterior"

svy: tab dnin20a23amayerP, obs ci  format(%17.4f)
********************************************************************************
*11. LACTANCIA MATERNA ADECUADA SEG�N LA EDAD

*Denominadores
gen  dnin6a23amaliyerP = 1 if (edaddias >183 & edaddias <=730 & ///
  f3302==1 & f3403==1)
replace dnin6a23amaliyerP = 0 if (edaddias >183 & edaddias <=730 & ///
  f3302<=2 & dnin6a23amaliyerP==.)
label variable dnin6a23amaliyerP ///
  "� 6-23m que recibieron l.materna+alim.s�lid.semis�l/suaves"

svy: tab dnin6a23amaliyer, ci obs

****Por quintiles economicos
gen grladec=edaddias
recode grladec (min/183=1) (184/730=2) (730/max=.)
gen dlamadec=dnin5amayerP
replace  dlamadec=dnin6a23amaliyerP if dnin6a23amaliyerP!=.

local i = 1
while `i' <=5 {
	svy: tabulate grladec dlamadec, subpop(if (quint== `i')) ///
	  row ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  grladec dlamadec, subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate grladec dlamadec, row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  grladec dlamadec,  count cv se   format(%17.4f) cellwidth(20)

********************************************************************************
*12. LACTANCIA MATERNA PREDOMINANTE ANTES DE LOS 6 MESES
*label variable dnin5 "Lactantes de cero a 5 meses de edad"
*Numeradores

gen   dnin5amapredyerP = 1 if (edaddias <=183 & f3302==1 &  f3401==2)
replace   dnin5amapredyerP = 0 if (edaddias <=183 & f3302!=. &  f3401!=. & ///
  dnin5amapredyerP ==. )

label variable dnin5amapredyerP ///
  "Lact 0-5m con leche materna(fuente predom.alim.)"

svy: tab dnin5amapredyerP pd02, row ci obs
********************************************************************************
*13. DURACI�N DE LA LACTANCIA MATERNA

gen  dnin_durlac1_35P= edaddias
recode dnin_durlac1_35P (min/61=1) (62/122=2) (123/183=3) (184/243=4) ///
  (244/304=5) (305/365=6) (366/427=7) (428/488=8) (489/549=9) (550/610=10) ///
  (611/669=11) (670/730=12) (731/791=13) (792/853=14)  (854/914=15) ///
  (915/973=16) (974/1033=17) (1034/1095=18) (1096/max=.)
gen dnin_durlac0_35AMP= 1 if (f3201==1 & dnin_durlac1_35P!=.)
replace  dnin_durlac0_35AMP=0 if (dnin_durlac0_35AMP==.)

svy: tabulate dnin_durlac1_35P dnin_durlac0_35AMP, ///
  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate quint, obs count subpop(if dnin_durlac1_35P >1) format (%14.2f)

****Por quintiles economicos
local i = 1
while `i' <=5 {
	svy: tabulate dnin_durlac1_35P dnin_durlac0_35AMP, ///
	  subpop(if (quint== `i')) row  ci obs format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}

********************************************************************************
*14. ALIMENTACI�N CON BIBER�N
generate dnin23biberP = 1 if ( edaddias <=730)&(f3409==1)
label variable dnin23biberP "� 0-23m alimentados con biber�n"
replace dnin23biberP = 0 if (edaddias <=730 & dnin23biberP==.)
**Grupos de edad :
gen gralb=edaddias
recode gralb (min/183=1) (184/365=2) (366/730=3) (730/max=.)

*Prevalencias:
forval x=1/3 {
	di "Grupo de edad:""`:label (grdnin6a23divAMP) `x''"
	svy: mean  	dnin23biberP, subpop(if  gralb==`x')
	}

***Por quintiles economicos
local i = 1
while `i' <=5 {
	svy: tabulate gralb dnin23biberP, subpop(if (quint== `i')) ///
	  row  ci obs format(%17.4f) cellwidth(20)
	svy: tabulate  gralb dnin23biberP, subpop(if (quint== `i')) ///
	  count cv se   format(%17.4f) cellwidth(20)
	local i = `i' + 1
	}
svy: tabulate gralb dnin23biberP,  row  ci obs format(%17.4f) cellwidth(20)
svy: tabulate  gralb dnin23biberP,  count cv se   format(%17.4f) cellwidth(20)


***********************************************************
*15. FRECUENCIA DE TOMAS DE LECHE PARA NI�OS NO AMAMANTADOS

gen  dnin6a23amayer2tomlecP = 1 if (edaddias >183 & edaddias <=730 ///
  & f3302==2 & f3413==1)
replace dnin6a23amayer2tomlecP = 0 if (edaddias >183 & edaddias <=730 & ///
  f3302==2 & dnin6a23amayer2tomlecP==.)
label variable dnin6a23amayer2tomlecP ///
  "� no amamantados 6-23m recib. al menos 2 tomas de leche d�a anterior"

svy: tabulate 	dnin6a23amayer2tomlec, ci obs
svy: tabulate grdnin6a23y dnin6a23amayer2tomlecP, ci obs

*An�lisis de lactancia materna ensanut 2012 termina ah�*************************
