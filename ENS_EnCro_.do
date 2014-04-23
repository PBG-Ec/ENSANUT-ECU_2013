******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
**************Tomo 1**********************************************************
**************Capítulo: Aproximación a enfermedades***************************
**************Crónicas no transmisibles **************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
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

A BibTeX entry for LaTeX users is:

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
*Ingresar el directorio de las bases:
cd ""
*Variables de identificadores & svyset
set more off
clear all

*Identificadores para las bases de personas y vivienda:
global bs "ensanut_f2_mef ensanut_f12_bioquimica ensanut_f10_antropometria"

foreach x of global bs{
	use `x', clear
	cap drop id*
*Identificador de Hogar - vivienda
	gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
	format idhog %20.0f
	gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
	gen double idviv=idsector*10^2+vivienda
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

use ensanut_f12_bioquimica, clear
*Logs:
log using Biomarcadores.smcl, replace

*Variables de cruce:
merge 1:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 edadanio quint pd08b)
drop if _merge==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"


*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

*********************************
*Variables de análisis:

*Dummy mayores o igual de 10 años*gen edsup10=.
*replace edsup10=1 if (edadanio >= 10)

*Sin personas embarazada
*Mujeres embarazadas :
gen embrz=strpos(historia,"E")
recode embrz (12 13 = 1)
drop if (embrz==1)
sort idpers

*Merge Variables Cintura PA 130/80, Grupos de edad hipertension
merge 1:1 idpers using ensanut_f10_antropometria.dta, ///
  keepusing(cintu1 cintu2 cintu3 pres1a pres2a pres3a pres1b ///
  pres2b pres3b)
drop if _merge==2
drop _merge

*Variable de embarazada:
merge 1:1 idpers using ensanut_f2_mef.dta,keepusing(f2200)
drop if _merge==2
drop _merge

*Promedio de mediciones de antropometría repetidas mas cercanas
****cintu
gen cintuf=.
*Umbral de inclusion medida 1 y 2 :
replace cintuf=(cintu1+cintu2)/2 if cintu1-cintu2<0.5
*Media de los 2 valores mas cercanos
replace cintuf=abs(cintu1+cintu2)/2 ///
  if (abs(cintu1-cintu2)<abs(cintu1-cintu3)) & ///
  (abs(cintu1-cintu2)<abs(cintu2-cintu3))
replace cintuf=abs(cintu1+cintu3)/2 ///
  if (abs(cintu1-cintu3)<abs(cintu1-cintu2)) & ///
  (abs(cintu1-cintu3)<abs(cintu2-cintu3))
replace cintuf=abs(cintu2+cintu3)/2 ///
  if (abs(cintu2-cintu3)<abs(cintu1-cintu2)) & ///
  (abs(cintu2-cintu3)<abs(cintu1-cintu3))
*Coreccion missings
replace cintuf=. if cintuf==999

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
replace cintuf=. if f2200==1
*Hipertensión y valores outliers
replace  presfs=. if (presfs<30 |  presfs>280)
replace  presfd=. if (presfd<30 | presfd>280)
gen  presion =0
replace  presion=1 if ((presfs>30 &  presfs<=280 & presfd>=30 & presfd<=280))
label variable  presion   "Presión"
label define  pre 0 "outlier no medible" 1 "medible"
label values  presion pre

*Variables para Sindrome metabolico Hiperglucemia e Dislipidemia

gen  tension130_80=0
replace tension130_80 = 1 if (presion==1 &  (presfs >=130 | presfd >=80))
replace  tension130_80 = . if (presion==0 & cintuf)
label define  t130_80 0 "no riesgo" 1 "presión arterial riesgo CM"
label value tension130_80 t130_80
tab tension130_80

*Cintura Riesgo
gen  cinturarisk =0
replace cinturarisk =1 if (edadanio == 10 & genero == 1 & cintuf >=78.0)
replace cinturarisk =1 if (edadanio == 10 & genero == 2 & cintuf >=76.6)
replace cinturarisk =1 if (edadanio == 11 & genero == 1 & cintuf >=81.4)
replace cinturarisk =1 if (edadanio == 11 & genero == 2 & cintuf >=79.7)
replace cinturarisk =1 if (edadanio == 12 & genero == 1 & cintuf >=84.8)
replace cinturarisk =1 if (edadanio == 13 & genero == 1 & cintuf >=88.2)
replace cinturarisk =1 if (genero == 1 & cintuf >=90.0)
replace cinturarisk =1 if (genero == 2 & cintuf >=80.0)
replace cinturarisk =. if (cintuf==.|edadanio ==. )
label define cirsk 0 "no riesgo" 1 "riesgo"
label values cinturarisk cirsk
tab cinturarisk

*Grupos de edad Biomarcadores
gen gedadbiomarcadores=edadanio if(edadanio>=10 & edadanio<=59)
recode gedadbiomarcadores (10/19=1) (20/29=2) (30/39=3) (40/49=4) (50/59=5)
lab var gedadbiomarcadores "Grupos de edad para biomarcadores"
lab def grbmk 1 "(10 < 20)" 2 "(20< 30)" 3 "(30 < 40)" ///
  4 "(40 < 50)" 5 "(50 < 60)"
lab val gedadbiomarcadores grbmk
tab gedadbiomarcadores

*Missing Value Glucemia segun puntos de corte(x<450)
summ glucosa
replace glucosa=. if glucosa>=451

*Glucosa a partir de 126 mg (criterio idf - ada)
gen gluc126=glucosa
recode gluc126 (min/125=0) (126/max=1)
lab var gluc126 "glucemia (recodificada)"
lab def gl126 0 "menor a 125mg/dl" 1 "mayor a 126 mg/dl"
lab val gluc126 gl126
tab gluc126

*Glucemia riesgo cardiometabolico (> 100 mg, criterio idf)
gen gluc100=glucosa
recode gluc100 (min/99=0) (100/max=1)
lab var gluc100 "glucemia riesgo cm"
lab def gluc100 0 "no riesgo" 1 "riesgo"
lab val gluc100 glc1
tab gluc100

*Corte Lipidos segun laboratorio
recode hdlc (121/max=.)
recode trig (1001/max=.)
recode ldlc (min/0=.)

*Corte Colesterol (200 mg, tgc 150 (atpiii - idf))
gen cholrec=chol
recode cholrec (min/199=0) (200/max=1)
lab var cholrec "colesterol (recodificado)"
lab def cholrc 0 "menor a 200mg/dl" 1 "mayor a 200 mg/dl"
lab val cholrec cholrc
tab cholrec
gen trigrec=trig
recode trigrec (min/149=0) (150/max=1)
lab var trigrec "triglicéridos (recodificado)"
lab def trigrc 0 "menor a 150 mg/dl" 1 "mayor a 150 mg/dl"
lab val trigrec trigrc
tab trigrec

*Corte ldl Gr 130 mg para > a 9 años
gen ldlcrec=ldlc
recode ldlcrec (min/129=0) (130/max=1)
lab var ldlcrec "ldl colesterol (recodificado)"
lab def ldlcrec 0 "menor a 130 mg/dl" 1 "mayor a 130 mg/dl"
tab ldlcrec

*Recodificacion hdl por grupos de edad:
*1. 10 a 16 años: el punto de corte es 40 mg para ambos sexos
*2. mayor de 16 años y en funcion del sexo: para hombres el
*punto de corte es 40 mg, para muejres es 50 mg

gen hdlrec2=hdlc
recode hdlrec2 (min/40=1) (41/max=0)
replace hdlrec2=1 if (hdlc<=50 & edadanio >= 17 & f1203 ==2)
replace hdlrec2=0 if (hdlc>50 & edadanio >= 17 & f1203 ==2)
lab var hdlrec2 "hdlcolesterol recodificado (edad y sexo)"
lab def hdlrc2 0 "hdlc no riesgo" 1 "hdlc riesgo"
lab val hdlrec2 hdlrc2
tab hdlrec2

*Dislipemia con criterio de al menos una prueba alterada
*Colesterol (>200), hdl (/edad/sexo), ldl (>130) y (tgc >150)
egen fact_dislip=rowtotal(ldlcrec cholrec trigrec hdlrec2)
lab var fact_dislip "factores de dislipemia"
gen dislipemia=fact_dislip
recode dislipemia (0=0) (1/4=1)
lab def dislipemi 0 "no" 1 "si"
lab val dislipemia dislipemi
lab var dislipemia "Dislipidemia"
tab dislipemia

*Indicador de dislipemia sin colesterol
egen fact_dislip_sinchol=rowtotal(ldlcrec trigrec hdlrec2)
lab var fact_dislip_sinchol "factores de dislipemia sin colesterol"
gen dislipsinchol=fact_dislip_sinchol
recode dislipsinchol (0=0) (1/3 = 1)
lab def dislipsincho 0 "no" 1 "si"
lab val dislipsinchol dislipsincho
tab dislipsinchol

*Sindrome metabolico idf (international diabetes federation)
*Poblacion >16 años: /diametro cintura hombres 90 cm, mujer 80 cm
* 1_tgc (>=150) 2_hdl (<=40 hombres/<=50 en mujeres)
*3 glucosa (>=100)/4 tas(>=130) y/o tad (>=85)
*Poblacion de 10 a 16 años: /diametro cintura hombres 90 cm,
*mujer 80 cm o p90 (nhanesiii) /1 tgc (>150) / 2 hdl (<40 hombres_mujeres)
*3 glucosa (>=100) / 4 tas (>=130) y/o tad (>=85)

*Factores sindrome metablico
egen fact_s_metab= rowtotal(trigrec gluc100 tension130_80 hdlrec2)
lab var fact_s_metab "factores de síndrome metabólico (no incluye cintura)"
tab fact_s_metab

*Factor sindrome metab. cintura:
gen sind_metab=0
replace sind_metab =1 if (cinturarisk==1 & fact_s_metab>=2)
lab var sind_metab "aproximación a sindrome metabólico"
lab def sind_meta 0 "no riesgo" 1 "si riesgo"
lab val sind_metab sind_meta
tab sind_metab

*Grupos de edad de analisis (adolescentes y adultos)
gen edrec2=edadanio
replace edrec2=. if (edadanio<10)
recode edrec2 (10/17=0) (18/max=1)
lab var edrec2 "edad (adolescentes y adultos)"
lab def edrec2 0 "adolescentes (10 a 17 años)" 1 "adultos (18 a 59 años)"
lab val edrec2 edrec2

********************************************************************************
*Estadisticas por sexo y edad glucosa, insulina, HOMA y lipidos


*Indice homa (formula de matthews para glucemia en mg/dl) (1985)
gen homair=(glucosa * insulina)/405
lab var homair "indicehoma"
di "*Estadisticas de indice HOMA por grupos de edad biomarcadores*"
bysort gedadbiomarcadores: summ homair [aw=pw],detail
tabout gedadbiomarcadores using pbiokdes_grbk.txt, ///
  replace c(mean homair lb ub) f(1.1) svy sum

*Estadisticas por sexo y edad
*glucosa, insulina, HOMA y lipidos
global varbk glucosa insulina homair chol hdlc ldlc trig
foreach V of global varbk {
	di "*Estadisticas de ""`V'"" por grupos de edad biomarcadores*"
	bysort gedadbiomarcadores: summ `V' ///
	  if gedadbiomarcadores!=. [aw=pw],detail
	tabout gedadbiomarcadores using pbiokdes_grbk`V'.txt, ///
	  replace c(mean `V' lb ub) f(1.1) svy sum
}

*Declarar missing a edad menor a 10 para diabetes
replace gluc126=. if edadanio <10

***Prevalencias Glucemia y lipidos NACIONAL***

global vardlp gluc126 cholrec hdlrec2 ldlcrec trigrec
foreach V of global vardlp {
	di "*HOMBRES Prevalencias de ""`V'"" por grupos de edad biomarcadores*"
	tabout gedadbiomarcadores `V' if(f1203==1) & gedadbiomarcadores!=. ///
	  using p_`V'.txt, replace c(freq) f(3.1)
	tabout gedadbiomarcadores `V' if(f1203==1) using p_`V'.txt , ///
	  append cells(row lb ub) f(3.1) svy
   di "*MUJERES Prevalencias de ""`V'"" por grupos de edad biomarcadores*"
   tabout gedadbiomarcadores `V' if(f1203==2) using p_`V'.txt , ///
	  append c(freq) f(3.1)
   tabout gedadbiomarcadores `V' if(f1203==2) using p_`V'.txt , ///
	  append cells(row lb ub) f(3.1) svy
   di "*TOTAL Prevalencias de ""`V'"" por grupos de edad biomarcadores*"
   tabout gedadbiomarcadores `V' if gedadbiomarcadores!=. using p_`V'.txt, ///
	  append c(freq) f(3.1)
   tabout gedadbiomarcadores `V' if gedadbiomarcadores!=. using p_`V'.txt, ///
	  append cells(row lb ub) f(3.1) svy
	}

*Prevalencias por desagregaciones especificas Glucemia y Lípidos
global vardlp gluc126 cholrec hdlrec2 ldlcrec trigrec
global vardsg quint gr_etn area subreg zonas_pl
foreach V of global vardlp {
	foreach Y of global vardsg {
		di "*TOTAL Prevalencias de ""`V'"" por ""`Y'"" *"
		tabout `Y' `V' if gedadbiomarcadores!=. using p_`V'_`Y'.txt , ///
		  replace c(freq) f(3.1)
		tabout `Y' `V' if gedadbiomarcadores!=. using q_`V'_`Y'.txt , ///
		  replace cells(row lb ub) f(3.1) svy
		}
	}

*Descripcion de circunferencia de cintura, Nacional****
svy: tabulate gedadbiomarcadores cinturarisk, ///
  subpop(if (f1203==1 & gedadbiomarcadores!=.)) row se ci  obs format(%17.4f)
svy: tabulate gedadbiomarcadores cinturarisk, ///
  subpop(if (f1203==2 & gedadbiomarcadores!=.)) row se ci  obs format(%17.4f)
svy: tabulate gedadbiomarcadores cinturarisk, ///
  subpop(if (gedadbiomarcadores!=.)) row se ci cv obs format(%17.4f)

*Descripcion de Sindrome Metabólico, Nacional****
svy: tabulate gedadbiomarcadores sind_metab, ///
  subpop(if (f1203==1 & gedadbiomarcadores!=. & cinturarisk!=.)) ///
  row se ci cv obs format(%17.4f)
svy: tabulate gedadbiomarcadores sind_metab, ///
  subpop(if (f1203==2 & gedadbiomarcadores!=. & cinturarisk!=.)) ///
  row se ci cv obs format(%17.4f)
svy: tabulate gedadbiomarcadores sind_metab, ///
  subpop(if (gedadbiomarcadores!=. & cinturarisk!=.)) ///
  row se ci cv obs format(%17.4f)

*Prevalencias de sindrome metabólico por desagregaciones**
*Quintil Económico
svy: tabulate quint sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)

*Grupo Étnico
svy: tabulate gr_etn sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)
*area
 svy: tabulate area sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)
*Subregion
 svy: tabulate subreg sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)
*Area
 svy: tabulate area sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)
*Zona de planificación
svy: tabulate zonas_pl sind_metab, ///
  subpop(if (sind_metab!=. & cinturarisk!=.)) row se ci cv obs format(%17.4f)

*Calculo de la razon colesterol / hdl c
gen ratioct_hdlc=chol / hdlc
lab var ratioct_hdlc "razón colesterol total/hdl colesterol"
*Estadisticas de razón colesterol total/hdl colesterol
*por grupos de edad biomarcadores
bysort gedadbiomarcadores: summ ratioct_hdlc [aw=pw],detail
tabout gedadbiomarcadores using pbiokdes_grbk.txt, ///
  replace c(mean ratioct_hdlc lb ub) f(1.1) svy sum

*Razon colesterol punto de corte ratio>5
gen razonrec=ratioct_hdlc
recode razonrec (min/4.99=0) (5/max=1)
lab var razonrec "razon colesterol-hdl recodificado a partir de 5"
lab def razonrec 0 "no riesgo " 1 "si riesgo"
lab val razonrec razonrec

di "*HOMBRES Prevalencias de razonrec por grupos de edad biomarcadores*"
tabout gedadbiomarcadores razonrec if(f1203==1) using pr_.txt, ///
  replace c(freq) f(3.1)
tabout gedadbiomarcadores razonrec if(f1203==1) using pr_.txt, ///
  append c(row lb ub) f(3.1) svy
di "*MUJERES Prevalencias de razonrec por grupos de edad biomarcadores*"
tabout gedadbiomarcadores razonrec if(f1203==2) using pr_.txt, ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores razonrec if(f1203==2) using pr_.txt, ///
  append c(row lb ub) f(3.1) svy
di "*TOTAL Prevalencias de razonrec por grupos de edad biomarcadores*"
tabout gedadbiomarcadores razonrec using pr_.txt, ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores razonrec using pr_.txt, ///
  append c(row lb ub) f(3.1) svy


*Homa segun grupos de edad:/1 10-17 años(>3.16) /2 >17 años (>2.5)
gen homa25y316=0 if(edadanio > 17 & homair<2.4999999999999)
replace homa25y316=1 if(edadanio > 17 & homair>2.4999999999999)
replace homa25y316=0 if(edadanio <= 17 & homair<3.16)
replace homa25y316=1 if(edadanio <= 17 & homair>3.15)
replace homa25y316=. if homair==.
lab var homa25y316 "homa (2.5) recodificado (edad)"
lab def homa25y316 0 "homa no riesgo" 1 "homa si riesgo"
lab val homa25y316 homa25y316
tab homa25y316
di "*HOMBRES Prevalencias de homa25y316 por grupos de edad biomarcadores*"
tabout gedadbiomarcadores homa25y316 if(f1203==1) using phoma_.txt , ///
  replace c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 if(f1203==1) using phoma_.txt , ///
  append cells(row lb ub) f(3.1) svy
di "*MUJERES Prevalencias de homa25y316 por grupos de edad biomarcadores*"
tabout gedadbiomarcadores homa25y316 if(f1203==2) using phoma_.txt , ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 if(f1203==2) using phoma_.txt , ///
  append cells(row lb ub) f(3.1) svy
di "*TOTAL Prevalencias de homa25y316 por grupos de edad biomarcadores*"
tabout gedadbiomarcadores homa25y316 using phoma_.txt , ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 using phoma_.txt , ///
  append cells(row lb ub) f(3.1) svy

*Descriptiva HOMA en funcion de diabetes*
di"*Descripción estadistica de HOMA en función de diabetes*"
bysort gluc126: summ homair [aw=pw],detail
tabout gluc126 using pbiokdes_grbk.txt, ///
  replace c(mean homair lb ub) f(1.1) svy sum

*Prevalencias homa y diabetes*
di "*GLUCEMIA <125mg/dl Prevalencias de homa25y316/gr.edad biomarcadores*"
tabout gedadbiomarcadores homa25y316 if(gluc126==0) using p_hodi_.txt, ///
  replace c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 if(gluc126==0) using p_hodi_.txt, ///
  append cells(row lb ub) f(3.1) svy
di "GLUCEMIA MAYOR a 125mg/dl Prevalencias de homa25y316/gr.edad biomarcadores"
tabout gedadbiomarcadores homa25y316 if(gluc126==1) using p_hodi_.txt, ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 if(gluc126==1) using p_hodi_.txt, ///
  append cells(row lb ub) f(3.1) svy
di "*TOTAL Prevalencias de homa25y316 por grupos de edad biomarcadores*"
tabout gedadbiomarcadores homa25y316 using p_hodi_.txt, ///
  append c(freq) f(3.1)
tabout gedadbiomarcadores homa25y316 using p_hodi_.txt, ///
  append cells(row lb ub) f(3.1) svy

*Suma de factores de dislipemia por sexo
replace fact_dislip=. if (fact_dislip==0)
di "*TOTAL Prevalencias de homa25y316 por grupos de edad biomarcadores*"
tabout f1203 fact_dislip using p.txt ,replace c(freq) f(3.1)
tabout f1203 fact_dislip using p.txt ,replace cells(row lb ub) f(3.1) svy
tabout f1203 fact_dislip using p.txt ,replace cells(col lb ub) f(3.1) svy

log close
translate Biomarcadores.smcl Biomarcadores.txt , ///
  replace linesize(255) translator(smcl2log)

*Análisis de Aprox. a Enfermedades Crónicas no tr. ensanut 2012 termina ahí*****
