******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
*********************Tomo 1***************************************************
*********************Capítulo: Antropometría**********************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboración: Katerin Silva  kate436@hotmail.com
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
*Preparación de bases:
*Variables de identificadores
clear all
set more off
set maxvar 20000

*Ingresar el directorio de las bases:
cd ""
global bases "ensanut_f10_antropometria ensanut_f2_mef"
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

*En la base de antropometria:
use ensanut_f10_antropometria.dta, clear

*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (pd04a pd04b pd04c dia mes anio escol subreg provincia ///
  gr_etn area  pd00 nbi quint subreg zonas_planificacion pd08b pd03)
drop if _merge ==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"

********************************************************************************
gen dob=mdy(pd04b, pd04a, pd04c)
gen dov=mdy(mes,dia,anio)
gen edaddias= dov- dob

*Nivel de escolaridad de la madre
rename idpers idpers1
rename idmadre idpers
rename escol escolpers
merge m:1 idpers using ensanut_f1_personas.dta, keepusing (escol pd19a)
drop if ( _merge==2)
drop _merge
rename idpers idmadre
rename idpers1 idpers
rename escol escolmadre
rename escolpers escol

*Nivel de escolaridad de la Madre Agregado por anios escolaridad
gen escolaridad_madre=.
*analfabeto o primaria incompleta
replace escolaridad_madre=1 if escolmadre>=0 & escolmadre<6
*primaria completa o secundaria incompleta
replace escolaridad_madre=2 if escolmadre>=6 & escolmadre<12
*secundaria completa
replace escolaridad_madre=3 if escolmadre==12
*Superior
replace escolaridad_madre=4 if escolmadre>12
replace escolaridad_madre=. if escolmadre==.
label define escolariop 1 "analfabeto funcional o primaria incompleta" ///
  2 "primaria completa o secundaria incompleta" 3 "secundaria completa" ///
  4 "Superior"
label value escolaridad_madre escolariop

*Promedio de mediciones de antropometría repetidas mas cercanas
*Peso
gen pesof=.
*Umbral de inclusion medida 1 y 2 :
replace pesof=(peso1+peso2)/2 if peso1-peso2<0.5
*Media de los 2 valores mas cercanos
replace pesof=abs(peso1+peso2)/2 if (abs(peso1-peso2)<abs(peso1-peso3)) ///
  & (abs(peso1-peso2)<abs(peso2-peso3))
replace pesof=abs(peso1+peso3)/2 if (abs(peso1-peso3)<abs(peso1-peso2)) ///
  & (abs(peso1-peso3)<abs(peso2-peso3))
replace pesof=abs(peso2+peso3)/2 if (abs(peso2-peso3)<abs(peso1-peso2)) ///
  & (abs(peso2-peso3)<abs(peso1-peso3))
*Coreccion missings
replace pesof=. if pesof==999

*Cintura
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
  (abs(cintu2-cintu3)<abs(cintu1-talla3))
*Coreccion missings
replace cintuf=. if cintuf==999

*Talla
gen tallaf=.
*Umbral de inclusion medida 1 y 2 :
replace tallaf=(talla1+talla2)/2 if talla1-talla2<0.5
*Media de los 2 valores mas cercanos
replace tallaf=abs(talla1+talla2)/2 ///
  if (abs(talla1-talla2)<abs(talla1-talla3)) & ///
  (abs(talla1-talla2)<abs(talla2-talla3))
replace tallaf=abs(talla1+talla3)/2 ///
  if (abs(talla1-talla3)<abs(talla1-talla2)) & ///
  (abs(talla1-talla3)<abs(talla2-talla3))
replace tallaf=abs(talla2+talla3)/2 ///
  if (abs(talla2-talla3)<abs(talla1-talla2)) & ///
  (abs(talla2-talla3)<abs(talla1-talla3))
*Coreccion missings
replace tallaf=. if tallaf==999

*Longitud
gen longf=.
*Umbral de inclusion medida 1 y 2 :
replace longf=(long1+long2)/2 if long1-long2<0.5
*Media de los 2 valores mas cercanos
replace longf=abs(long1+long2)/2 if (abs(long1-long2)<abs(long1-long3)) ///
  & (abs(long1-long2)<abs(long2-long3))
replace longf=abs(long1+long3)/2 if (abs(long1-long3)<abs(long1-long2)) ///
  & (abs(long1-long3)<abs(long2-long3))
replace longf=abs(long2+long3)/2 if (abs(long2-long3)<abs(long1-long2)) ///
  & (abs(long2-long3)<abs(long1-talla3))
*Coreccion missings
replace longf=. if longf==999

*Talla & Longitud segun edad
gen tallap=longf
replace  tallap=tallaf if pd03>=2

gen tallau=longf if pd03<2
replace tallau= tallap if pd03>=2

*svyset:
svyset idsector [pweight=pw], strata (area)

*********************************************************************************
*igrowup_stata: niños menores a 5 años
*La siguiente sintaxis esta basada en la sintaxis survey_standard.do de la OMS
*dispnible en el paquete de analisis igrowup disponible en linea:
*http://www.who.int/childgrowth/software/igrowup_stata.zip
*la siguiente sintaxis genera dentro del directorio de trabajo
*un nuevo directorio "igrowup":
local dir `c(pwd)'
local y ="`dir'\igrowup"
cap mkdir "`y'"
cd "`y'"
*Descarga y extracción del paquete de Child growth standards "igrowup_stata":
cap copy http://www.who.int/childgrowth/software/igrowup_stata.zip ///
  igrowup_stata.zip
cap unzipfile igrowup_stata.zip
cd "`dir'"
*Calculo de indicadores de antropometria (igrowup):
adopath + "`y'"
*Generate the first three parameters reflib, datalib & datalab
gen str200 reflib="`y'"
lab var reflib "Directory of reference tables"
gen str200 datalib="`y'"
lab var datalib "Directory for datafiles"
gen str30 datalab="ensanut"
lab var datalab "Working file"

*Check the variable gender for "sex"	1 = male, 2=female
gen gender=f10sexo
*	check the variable for "age"
gen agemons=edaddias
*	define your ageunit
gen str6 ageunit="days"
lab var ageunit "days"
*	check the variable for body "weight" which must be in kilograms
* 	NOTE: if not available, please create as [gen weight=.]
gen  weight=pesof
desc weight
summ weight
* 	check the variable for "height" which must be in centimeters
* 	NOTE: if not available, please create as [gen height=.]
gen  height=tallap
desc height
summ height
*	check the variable for "measure"
* 	NOTE: if not available, please create as [gen str1 measure=" "]
gen str1 measure=" "
* 	check the variable for "headc" which must be in centimeters
* 	NOTE: if not available, please create as [gen headc=.]
gen headc=.
* 	check the variable for "armc" which must be in in centimeters
* 	NOTE: if not available, please create as [gen armc=.]
gen muac=.
* 	check the variable for "triskin" which must be in millimeters
* 	NOTE: if not available, please create as [gen triskin=.]
gen triskin=.
* 	check the variable for "subskin" which must be in millimeters
* 	NOTE: if not available, please create as [gen subskin=.]
gen subskin=.
gen sub=.
* 	check the variable for "oedema"
* 	NOTE: if not available, please create as [gen str1 oedema="n"]
gen str1 oedema="n"
*	check the variable for "sw" for the sampling weight
* 	NOTE: if not available, please create as [gen sw=1]
gen sw=1
save ensanut_f10_antropometria1.dta,replace

* 	Fill in the macro parameters to run the command
igrowup_standard reflib datalib datalab gender agemons ageunit ///
  weight height measure head muac tri sub oedema sw

*En la base original añadir las variables generadas:
use ensanut_f10_antropometria1.dta,clear
local w ="`y'\ensanut_z_st.dta"
cap merge 1:1 idpers using `w', keepusing(_*)
cap drop _merge
*Rename Variable para la siguiente corrida 5 a 19 años
cap renpfix _ _1

********************************************************************************
*survey_who2007: 5 a 19  años
*La siguiente sintaxis esta basada en la sintaxis survey_who2007.do de la OMS
*dispnible en el paquete de analisis igrowup disponible en linea:
*http://www.who.int/growthref/tools/who2007_stata.zip
*la siguiente sintaxis genera dentro del directorio de trabajo
*un nuevo directorio "who2007":
local dir `c(pwd)'
local dy ="`dir'\who2007"
cap mkdir "`dy'"
cd "`dy'"
*Descarga y extrae el paquete de Child growth standards:
cap copy http://www.who.int/growthref/tools/who2007_stata.zip ///
  who2007_stata.zip
cap unzipfile who2007_stata.zip
cd "`dir'"
* Indicate to the Stata compiler where the igrowup_standard.ado file is stored:
adopath + "`dy'"
*Generate the first three parameters reflib, datalib & datalab
replace  reflib="`dy'"
replace  datalib="`dy'"
gen sex=gender
save ensanut_f10_antropometria1.dta,replace
* 	Fill in the macro parameters to run the command
* ADVERTENCIA: El
who2007 reflib datalib datalab sex agemons ageunit weight height oedema sw

*En la base original añadir las variables generadas:
use ensanut_f10_antropometria1.dta,clear
local w ="`dy'\ensanut_z.dta"
cap merge 1:1 idpers using `w', keepusing(_*)
cap drop _merge
save ensanut_f10_antropometria1.dta,replace

********************************************************************************
*Correccion si embarazada
*base F2 MEF : var f2200: Actualmente está embarazada :1 Si 2 No	88 No sabe
merge 1:1 idpers using ensanut_f2_mef.dta,keepusing(f2200)
drop if _merge==2
drop _merge
foreach _var of varlist _* {
	replace `_var'=.  if (f2200==1)
	}

********************************************************************************
*Variables Ficticias de Pre-escolares de 0 a 5 a
*Variable Ficticia Desnutricion Cronica Infantil
gen dcronica=0
replace dcronica=1 if (_1zlen!=. & agemons<=1856 & _1zlen< -2)
replace dcronica=. if (agemons>1856)
replace dcronica=. if _1zlen==.

*Variable Ficticia Desnutricion Global Infantil
gen dglobal=0
replace dglobal=1 if (_1zwei!=. & agemons<=1856 & _1zwei<-2)
replace dglobal=. if (agemons>1856)
replace dglobal=. if _1zwei==.

*Variable Ficticia Desnutricion Aguda
gen daguda=0
replace daguda=1 if (_1zwfl!=. & agemons<=1856 & _1zwfl<-2)
replace daguda=. if (agemons>1856)
replace daguda=. if _1zwfl==.

*Variable Ficticia de Sobrepeso y obesidad infantil

gen drs=0
replace drs=1 if (_1zbmi!=. & agemons<=1856 & _1zbmi>1 & _1zbmi<=2)
replace drs=. if (agemons>1856)
replace drs=. if _1zbmi==.

gen dsp=0
replace dsp=1 if (_1zbmi!=. & agemons<=1856 & _1zbmi>2 & _1zbmi<=3)
replace dsp=. if (agemons>1856)
replace dsp=. if _1zbmi==.

gen dobes=0
replace dobes=1 if ( _1zbmi!=. & agemons<=1856 & _1zbmi>3)
replace dobes=. if (agemons>1856)
replace dobes=. if _1zbmi==.

gen dspob=0
replace dspob=1 if (_1zbmi!=. & agemons<=1856 & _1zbmi>2)
replace dspob=. if (agemons>1856)
replace dspob=. if _1zbmi==.

*********************************************************************************
*Variables Ficticias de Pre-escolares de 0 a 59 meses
*para comparaciones con DANS,ENDEMAIN

*Variable Ficticia Desnutricion Cronica Infantil
gen dcronicac=0
replace dcronicac=1 if (_1zlen!=. & agemons<=1823 & _1zlen< -2)
replace dcronicac=. if (agemons>1823)
replace dcronicac=. if _1zlen==.

*Variable Ficticia Desnutricion Global Infantil
gen dglobalc=0
replace dglobalc=1 if (_1zwei!=. & agemons<=1823 & _1zwei<-2)
replace dglobalc=. if (agemons>1823)
replace dglobalc=. if _1zwei==.

*Variable Ficticia Desnutricion Aguda
gen dagudac=0
replace dagudac=1 if (_1zwfl!=. & agemons<=1823 & _1zwfl<-2)
replace dagudac=. if (agemons>1823)
replace dagudac=. if _1zwfl==.

*Variable Ficticia de Sobrepeso y obesidad infantil

gen drsc=0
replace drsc=1 if (_1zbmi!=. & agemons<=1823 & _1zbmi>1 & _1zbmi<=2)
replace drsc=. if (agemons>1823)
replace drsc=. if _1zbmi==.

gen dspc=0
replace dspc=1 if (_1zbmi!=. & agemons<=1823 & _1zbmi>2 & _1zbmi<=3)
replace dspc=. if (agemons>1823)
replace dspc=. if _1zbmi==.

gen dobesc=0
replace dobesc=1 if ( _1zbmi!=. & agemons<=1823 & _1zbmi>3)
replace dobesc=. if (agemons>1823)
replace dobesc=. if _1zbmi==.

gen dspobc=0
replace dspobc=1 if (_1zbmi!=. & agemons<=1823 & _1zbmi>2)
replace dspobc=. if (agemons>1823)
replace dspobc=. if _1zbmi==.


********************************************************************************
*Variables Ficticias de Escolares de 5 a 11 a y global (5 a 9 a)

*Variable Ficticia Desnutricion Cronica Niños de 5 a 11 a
gen dcro5_11=0
replace dcro5_11=1 if (_zhfa!=. &  agemons>=1857 & agemons<=4382 & _zhfa< -2)
replace dcro5_11=. if (agemons>4382 )
replace dcro5_11=. if (agemons<1857 )
replace dcro5_11=. if _zhfa==.


*Variable Ficticia Desnutricion Global Niños de 5 a 10 a  y un mes
gen dglo5_9=0
replace dglo5_9=1 if (_zwfa!=. &  agemons>=1857 & agemons<=3682 & _zwfa<-2)
replace dglo5_9=. if (agemons>3682)
replace dglo5_9=. if (agemons<1857)
replace dglo5_9=. if _zwfa==.


*Variable Ficticia de Sobrepeso y obesidad Niños de 5 a 11 a
gen dsp5_11=0
replace dsp5_11=1 ///
  if (_zbfa!=. & agemons>=1857 & agemons<=4382 & _zbfa>1 & _zbfa<=2)
replace dsp5_11=. if (agemons>4382)
replace dsp5_11=. if (agemons<1857)
replace dsp5_11=. if _zbfa==.

gen dobes5_11=0
replace dobes5_11=1 if (_zbfa!=. & agemons>=1857 & agemons<=4382 & _zbfa>2)
replace dobes5_11=. if (agemons>4382)
replace dobes5_11=. if (agemons<1857)
replace dobes5_11=. if _zbfa==.

gen dspob5_11=0
replace dspob5_11=1 if (_zbfa!=. & agemons>=1857 & agemons<=4382 & _zbfa>1 )
replace dspob5_11=. if (agemons>4382)
replace dspob5_11=. if (agemons<1857)
replace dspob5_11=. if _zbfa==.

*Variable Ficticia Delgadez de 5 a 11 a
gen ddelg5_11=0
replace ddelg5_11=1 if (_zbfa!=. & agemons>=1857 & agemons<=4382 & _zbfa<-2)
replace ddelg5_11=. if (agemons>4382)
replace ddelg5_11=. if (agemons<1857)
replace ddelg5_11=. if _zbfa==.

********************************************************************************
*Variables Ficticias de Desnutricion Cronica Adolescentes de 12 a 19 a

*Variable Ficticia Desnutricion Cronica adolescentes
gen dcro12_19=0
replace dcro12_19=1 if (_zhfa!=. & agemons>=4383 & agemons<=6970 & _zhfa<-2)
replace dcro12_19=. if agemons<4383
replace dcro12_19=. if agemons>6970
replace dcro12_19=. if _zhfa==.

*Variable Ficticia de Sobrepeso y obesidad adolescentes
gen dsp12_19=0
replace dsp12_19=1 if (_zbfa!=. & agemons>=4383 & ///
  agemons<=6970 & _zbfa>1 & _zbfa<=2)
replace dsp12_19=. if agemons<4383
replace dsp12_19=. if agemons>6970
replace dsp12_19=. if _zbfa==.

gen dobes12_19=0
replace dobes12_19=1 if (_zbfa!=. & agemons>=4383 & agemons<=6970 & _zbfa>2)
replace dobes12_19=. if agemons<4383
replace dobes12_19=. if agemons>6970
replace dobes12_19=. if _zbfa==.

gen dspob12_19=0
replace dspob12_19=1 if (_zbfa!=. & agemons>=4383 & agemons<=6970 & _zbfa>1)
replace dspob12_19=. if agemons<4383
replace dspob12_19=. if agemons>6970
replace dspob12_19=. if _zbfa==.

*Variable ficticia de delgadez adolescentes
gen ddelg12_19=0
replace ddelg12_19=1 if (_zbfa!=. & agemons>=4383 & agemons<=6970 & _zbfa<-2)
replace ddelg12_19=. if agemons<4383
replace ddelg12_19=. if agemons>6970
replace ddelg12_19=. if _zbfa==.

*******************************************************************************
*Variables Ficticias de Adultos de 19 a 59 a
*Correccion para valores outlier de IMC (>5std(bmi>53.14)  <-5 std)
*Z cbmi:(x-µ)/std
codebook _cbmi if (agemons>=6971 & agemons<=21899)
gen _zcbmi=(_cbmi-  26.8916)/ 5.30475 if (agemons>=6971 & agemons<=21899)
replace _cbmi=. if (_zcbmi<-5 | _zcbmi>5)

*Variable Ficticia Bajo peso o desnutricion
gen dbpeso19_59=0
replace dbpeso19_59=1 if (_cbmi!=. & agemons>=6971 & agemons<=21899 & ///
  _cbmi <18.5)
replace dbpeso19_59=. if agemons<6971
replace dbpeso19_59=. if agemons>21899
replace dbpeso19_59=. if _cbmi==.

*Variable Ficticia de Normal
gen dnorm19_59=0
replace dnorm19_59=1 if (_cbmi!=. & agemons>=6971 & agemons<=21899 & ///
  _cbmi >= 18.5 & _cbmi <25)
replace dnorm19_59=. if agemons<6971
replace dnorm19_59=. if agemons>21899
replace dnorm19_59=. if _cbmi==.

*Variable Ficticia de Sobrepeso y obesidad
gen dspeso19_59=0
replace dspeso19_59=1 if (_cbmi!=. & agemons>=6971 & agemons<=21899 & ///
  _cbmi >= 25 & _cbmi <30)
replace dspeso19_59=. if agemons<6971
replace dspeso19_59=. if agemons>21899
replace dspeso19_59=. if _cbmi==.


gen dobes19_59=0
replace dobes19_59=1 if (_cbmi!=. & agemons>=6971 & agemons<=21899  & ///
  _cbmi >=30)
replace dobes19_59=. if agemons<6971
replace dobes19_59=. if agemons>21899
replace dobes19_59=. if _cbmi==.

gen dspobes19_59=0
replace dspobes19_59=1 if (_cbmi!=. & agemons>=6971 & agemons<=21899 & ///
  _cbmi >= 25)
replace dspobes19_59=. if agemons<6971
replace dspobes19_59=. if agemons>21899
replace dspobes19_59=. if _cbmi==.

********************************************************************************
*Variables Ficticias con IMC
*Correccion para valores outlier: IMC en Adultos(>5std<-5 std)*Z cbmi:(x-µ)/std
gen IMC= .
replace IMC= (pesof/((tallap/100)*(tallap/100)))
replace IMC= . if (agemons<6971 | agemons>21899)

codebook IMC
gen _zIMC=(IMC- 26.8658)/ 5.33605
replace IMC=. if (_zIMC<-5 | _zIMC>5)


*Variable Ficticia Bajo peso o desnutricion
gen dbpeso19_59v2=0
replace dbpeso19_59v2=1 if (IMC!=. & agemons>=6971 & agemons<=21899 & IMC<18.5)
replace dbpeso19_59v2=. if agemons<6971
replace dbpeso19_59v2=. if agemons>21899
replace dbpeso19_59v2=. if IMC==.

*Variable Ficticia de Normal
gen dnorm19_59v2=0
replace dnorm19_59v2=1 if (IMC!=. & agemons>=6971 & agemons<=21899 & ///
  IMC>= 18.5 & IMC<25)
replace dnorm19_59v2=. if agemons<6971
replace dnorm19_59v2=. if agemons>21899
replace dnorm19_59v2=. if IMC==.

*Variable Ficticia de Sobrepeso y obesidad
gen dspeso19_59v2=0
replace dspeso19_59v2=1 if (IMC!=. & agemons>=6971 & agemons<=21899 & ///
  IMC>= 25 & IMC<30)
replace dspeso19_59v2=. if agemons<6971
replace dspeso19_59v2=. if agemons>21899
replace dspeso19_59v2=. if IMC==.

gen dobes19_59v2=0
replace dobes19_59v2=1 if (IMC!=. & agemons>=6971 & agemons<=21899  & IMC>=30)
replace dobes19_59v2=. if agemons<6971
replace dobes19_59v2=. if agemons>21899
replace dobes19_59v2=. if IMC==.

gen dspobes19_59v2=0
replace dspobes19_59v2=1 if (IMC!=. & agemons>=6971 & agemons<=21899 & IMC >= 25)
replace dspobes19_59v2=. if agemons<6971
replace dspobes19_59v2=. if agemons>21899
replace dspobes19_59v2=. if IMC==.

*********************************************************************************
*Grupos de edad especificos : Preescolares
gen grupo_pres=.
replace grupo_pres=1 if (agemons >=0 & agemons <183)
replace grupo_pres=2 if (agemons >=183 & agemons <366)
replace grupo_pres=3 if (agemons >=366 & agemons <731)
replace grupo_pres=4 if (agemons >=731 & agemons <1096)
replace grupo_pres=5 if (agemons >=1096 & agemons <1461)
replace grupo_pres=6 if (agemons >=1461 & agemons <1857)
label define grep 1 "0 a 5 meses" 2 "6 a 11 meses" 3 "12 a 23 meses" ///
  4 "24 a 35 meses" 5 "36 a 47 meses" 6 "48 a 60 meses"
label value grupo_pres grep

*grupos de edad especificos para comparaciones en población de 0 a 59 meses
*dans,endemain
gen grupo_presc=.
replace grupo_presc=1 if (agemons >=0 & agemons <183)
replace grupo_presc=2 if (agemons >=183 & agemons <366)
replace grupo_presc=3 if (agemons >=366 & agemons <731)
replace grupo_presc=4 if (agemons >=731 & agemons <1096)
replace grupo_presc=5 if (agemons >=1096 & agemons <1461)
replace grupo_presc=6 if (agemons >=1461 & agemons <1824)
label define grepc 1 "0 a 5 meses" 2 "6 a 11 meses" 3 "12 a 23 meses" ///
  4 "24 a 35 meses" 5 "36 a 47 meses" 6 "48 a 59 meses"
label value grupo_pres grepc


*Grupos especificos para Quito y Guayaquil
gen grupo_pres3=.
replace grupo_pres3=1 if (agemons >=0 & agemons <183)
replace grupo_pres3=1 if (agemons >=183 & agemons <366)
replace grupo_pres3=2 if (agemons >=366 & agemons <731)
replace grupo_pres3=3 if (agemons >=731 & agemons <1096)
replace grupo_pres3=3 if (agemons >=1096 & agemons <1461)
replace grupo_pres3=3 if (agemons >=1461 & agemons <1857)
label define gr3p 1 "0 a 11 meses" 2 "12 a 23 meses" 3 "12 a 60 meses"
label value grupo_pres3 gr3p

*Grupos especificos para subreg
gen grupo_pres2=.
replace grupo_pres2=1 if (agemons >=0 & agemons <731)
replace grupo_pres2=2 if (agemons >=731 & agemons <1857)
label define gr4p 1 "0 a 23 meses" 2 "24 a 60 meses"
label value grupo_pres2 gr4p

*Grupos especificos para tres cruces
gen grupo_pres1=.
replace grupo_pres1=1 if (agemons >=0 & agemons <1857)

label define gr5p 1 "0 a 60 meses"
label value grupo_pres1 gr5p


*Grupos de edad para Escolares
gen grupo_esc=.
replace grupo_esc=1 if (agemons>=1857 & agemons<2192)
replace grupo_esc=2 if (agemons>=2192 & agemons<2557)
replace grupo_esc=3 if (agemons>=2557 & agemons<2922)
replace grupo_esc=4 if (agemons>=2922 & agemons<3288)
replace grupo_esc=5 if (agemons>=3288 & agemons<3653)
replace grupo_esc=6 if (agemons>=3653 & agemons<4018)
replace grupo_esc=7 if (agemons>=4018 & agemons<4383)

label define gree 1 "5 años" 2 "6 años" 3 "7 años" ///
  4 "8 años" 5 "9 años" 6 "10 años" 7 "11 años"
label value grupo_esc gree


*Grupos de edad para Adolescentes
gen  grupo_ado=1 if (agemons>=4383 & agemons<5844)
replace grupo_ado=2 if (agemons>=5844 & agemons<6971)

label define gra 1 "de 12 a 14 años" 2 "de 15 a 19 años"
label value grupo_ado gra


*Grupos de edad para Adultos
gen  grupo_adu=1 if (agemons>=6971 & agemons<10958)
replace grupo_adu=2 if (agemons>=10958 & agemons<14610)
replace grupo_adu=3 if (agemons>=14610 & agemons<18264)
replace grupo_adu=4 if (agemons>=18264 & agemons<=21899)

label define gradu 1 "19 a 29 años" 2 "de 30 a 39 años" ///
  3 "de 40 a 49 años " 4 "de 50 a 59 años "
label values grupo_adu gradu


*Grupos de edad para Adultos2
gen grupo_adu2=.
replace grupo_adu2=1 if (agemons>=6971 & agemons<14610)
replace grupo_adu2=2 if (agemons>=14610& agemons<=21899)
label define gradu2 1 "19 a 39 años" 2 "de 40 a 59 años "
label values grupo_adu2 gradu2

********************************************************************************
*Variables ficticias para grupos especificos de edad:

egen dcro5_19 = rowtotal( dcro5_11 dcro12_19 )
replace dcro5_19=.   if (pd03>=20)

egen dspob5_19 = rowtotal( dspob5_11 dspob12_19 )
replace dspob5_19=.   if (pd03>=20)

egen dobes5_19 = rowtotal( dobes5_11 dobes12_19 )
replace dobes5_19=.   if (pd03>=20)

egen ddelg5_19 = rowtotal( ddelg5_11 ddelg12_19 )
replace ddelg5_19=.   if (pd03>=20)

save ensanut_f10_antropometria1.dta, replace

svy: mean dspob, subpop(if (subreg== 9 &  grupo_pres==1))
estat effects

********************************************************************************
*Cuadros y Cruces de variables
********************************************************************************
log using mylognacional, replace

********************************************************************************
*Prevalencia de desnutricion crónica a nivel nacional
*Preescolares
*Maculino
svy: tabulate grupo_pres dcronica, subpop(if (dcronica!=. & sex==1)) ///
  row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres dcronica , subpop( if (dcronica!=. & sex==2)) ///
  row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres dcronica, subpop( if (dcronica!=. & dcronica!=.)) ///
  row se ci cv obs format(%17.4f)

*Escolares
*Masculino
svy: tabulate grupo_esc dcro5_11 , subpop( if (dcro5_11!=. & sex==1)) ///
  row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_esc dcro5_11 , subpop( if (dcro5_11!=. & sex==2)) ///
  row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_esc dcro5_11, subpop( if (dcro5_11!=. & dcro5_11!=.)) ///
  row se ci cv obs format(%17.4f)

*Adolescentes
*Masculino
svy: tabulate grupo_ado dcro12_19  if   dcro12_19!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
svy: tabulate grupo_ado dcro12_19, ///
  subpop(if sex==1 & dcro12_19!=.) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_ado dcro12_19 if dcro12_19!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_ado dcro12_19, ///
  subpop(if ( dcro12_19!=.)) row se ci cv obs format(%17.4f)

*********************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años nivel nacional

*Masculino
svy: tabulate grupo_pres  daguda  if  daguda!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres  daguda  if  daguda!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres  daguda, ///
  subpop(if ( daguda!=.)) row se ci cv obs format(%17.4f)


*********************************************************************************
*Prevalencia de desnutricion global en menores de 5 años nivel nacional

*Preescolares
*Masculino
svy: tabulate grupo_pres dglobal  if   dglobal!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres dglobal  if   dglobal!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres dglobal, ///
  subpop(if (dglobal!=.)) row se ci cv obs format(%17.4f)

*********************************************************************************
*Prevalencia de riesgo de sobrepeso en menores de 5 años a nivel nacional

*Preescolares
*Masculino
svy: tabulate grupo_pres dsp  if dsp!=., ///
   subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres dsp  if dsp!=., ///
   subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres  dsp, ///
   subpop(if ( dsp!=.)) row se ci cv obs format(%17.4f)

*Escolares
*Masculino
svy: tabulate grupo_esc dsp5_11  if dsp5_11!=., ///
   subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_esc dsp5_11  if dsp5_11!=., ///
   subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_esc dsp5_11, ///
   subpop(if (dsp5_11!=.)) row se ci cv obs format(%17.4f)

*Adolescentes
*Masculino
svy: tabulate grupo_ado dsp12_19  if  dsp12_19!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
svy: tabulate grupo_ado dsp12_19 , ///
  subpop(if sex==1 & dsp12_19!=.) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_ado dsp12_19  if  dsp12_19!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate  grupo_ado dsp12_19, ///
  subpop(if (dsp12_19!=.)) row se ci cv obs format(%17.4f)

*Adultos
*Masculino
svy: tabulate grupo_adu dspeso19_59v2  if dspeso19_59v2!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_adu dspeso19_59v2  if dspeso19_59v2!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_adu dspeso19_59v2, ///
  subpop(if (dspeso19_59v2!=.)) row se ci cv obs format(%17.4f)

********************************************************************************
*Prevalencia de obesidad a nivel nacional

*Preescolares
*Masculino
svy: tabulate grupo_pres dobes, subpop(if sex==1 & dobes!=.) ///
  row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres dobes  if  dobes!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres dobes, ///
  subpop(if (dobes!=.)) row se ci cv obs format(%17.4f)

*Escolares
*Masculino
svy: tabulate grupo_esc dobes5_11  if  dobes5_11!=., ///
  subpop(if sex==1) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_esc dobes5_11  if  dobes5_11!=., ///
  subpop(if sex==2) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_esc dobes5_11, ///
  subpop(if (dobes5_11!=.)) row se ci cv obs format(%17.4f)

*Adolescentes
*Masculino
svy: tabulate grupo_ado dobes12_19  if dobes12_19!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_ado dobes12_19  if  dobes12_19!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate  grupo_ado dobes12_19, ///
  subpop(if (dobes12_19!=.)) row se ci cv obs format(%17.4f)

*Adultos
*Masculino
svy: tabulate grupo_adu dobes19_59v2  if  dobes19_59v2!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_adu dobes19_59v2  if   dobes19_59v2!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_adu dobes19_59v2, ///
  subpop(if ( dobes19_59v2!=.)) row se ci cv obs format(%17.4f)

********************************************************************************
*Prevalencia de sobrepeso u obesidad a nivel nacional
*Preescolares
*Masculino
svy: tabulate grupo_pres dspob  if dspob!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_pres dspob  if dspob!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_pres dspob, ///
      subpop(if (dspob!=.)) row se ci cv obs format(%17.4f)

*Escolares
*Masculino
svy: tabulate grupo_esc dspob5_11  if dspob5_11!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_esc dspob5_11  if dspob5_11!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_esc dspob5_11, ///
  subpop(if (dspob5_11!=.)) row se ci cv obs format(%17.4f)

*Adolescentes
*Masculino
svy: tabulate grupo_ado dspob12_19  if dspob12_19!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_ado dspob12_19  if dspob12_19!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate  grupo_ado dspob12_19, ///
      subpop(if (dspob12_19!=.)) row se ci cv obs format(%17.4f)

*Adultos
*Masculino
svy: tabulate grupo_adu dspobes19_59v2  if dspobes19_59v2!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_adu dspobes19_59v2  if dspobes19_59v2!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_adu dspobes19_59v2, ///
      subpop(if ( dspobes19_59v2!=.)) row se ci cv obs format(%17.4f)

*********************************************************************************
*Prevalencia de delgadez & delgadez severa a nivel nacional
*Escolares
*Masculino
svy: tabulate grupo_esc ddelg5_11  if  ddelg5_11!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_esc ddelg5_11  if  ddelg5_11!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_esc ddelg5_11, ///
  subpop(if (ddelg5_11!=.)) row se ci cv obs format(%17.4f)

*Adolescentes
*Masculino
svy: tabulate grupo_ado ddelg12_19  if dspob12_19!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_ado ddelg12_19  if dspob12_19!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate  grupo_ado ddelg12_19, ///
  subpop(if (ddelg12_19!=.)) row se ci cv obs format(%17.4f)

*Adultos
*Masculino
svy: tabulate grupo_adu dbpeso19_59v2  if  dbpeso19_59v2!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_adu dbpeso19_59v2  if  dbpeso19_59v2!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_adu dbpeso19_59v2, ///
  subpop(if (dbpeso19_59v2!=.)) row se ci cv obs format(%17.4f)

********************************************************************************
*Prevalencia de peso normal en adultos a nivel nacional
*Adultos
*Masculino
svy: tabulate grupo_adu dnorm19_59v2  if dnorm19_59v2!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_adu dnorm19_59v2  if dnorm19_59v2!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_adu dnorm19_59v2, ///
  subpop(if (dnorm19_59v2!=.)) row se ci cv obs format(%17.4f)

log off
log close
translate mylognacional.smcl mylognacional.txt


********************************************************************************
*Prevalencia de desnutricion crónica  a nivel regional
log using mylogregional, replace

tab subreg
local j
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 dcronica, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Escolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_esc  dcro5_11, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
 tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_ado  dcro12_19, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*****************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años a nivel regional

tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 daguda, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }

*****************************************************************************
*Prevalencia de desnutricion global en menores de 5 años a nivel regional

tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 dglobal, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }

********************************************************************************
*Prevalencia de riesgo de sobrepeso en menores de 5 años a nivel regional
*Preescolares por subregiones
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 drs, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }

********************************************************************************
*Prevalencia de sobrepeso a nivel regional
*Preescolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 dsp, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }

*Escolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_esc dsp5_11, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Adolescentes
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_ado dsp12_19, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Adultos
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_adu2 dspeso19_59v2, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

****************************************************************************
*Prevalencia de obesidad nivel regional
*Preescolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 dobes, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Escolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_esc dobes5_11, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Adolescentes
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_ado dobes12_19, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
 }
*Adultos
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_adu2  dobes19_59v2, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
}

**************************************************************************
*Prevalencia de sobrepeso u obesidad a nivel regional
*Preescolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_pres2 dspob, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_esc dspob5_11, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_ado dspob12_19,  ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_adu2 dspobes19_59v2, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de delgadez& delgadez severa a nivel regional
*Escolares
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_esc ddelg5_11, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_ado ddelg12_19, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_adu2 dbpeso19_59v2, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

****************************************************************************
*Prevalencia de peso normal en adultos a nivel regional
*Adultos
tab  subreg
local i = 1
while `i' <=9 {
   svy: tabulate grupo_adu2 dnorm19_59v2, ///
	  subpop(if (subreg== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
log off
log close
translate mylogregional.smcl mylogregional.txt

******************************************************************************
*A nivel Provincial:
log using mylogprovincial, replace
*Prevalencia de desnutricion crónica a nivel provincial
*Preescolares
tab provincia
local i = 1
while `i' <=26 {
   svy: tabulate grupo_pres2 dcronica, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab provincia
local i = 1
while `i' <=26 {
   svy: tabulate grupo_esc dcro5_11, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab provincia
local i = 1
while `i' <=26 {
   svy: tabulate grupo_ado dcro12_19, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años a nivel provincial
tab provincia
local i = 1
while `i' <=26 {
   svy: tabulate grupo_pres2 daguda, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion global en menores de 5 años a nivel provincial
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_pres2 dglobal, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de riesgo de sobrepeso en menores de 5 años a nivel prov
*Preescolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_pres2 drs, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

***************************************************************************
*Prevalencia de sobrepeso a nivel provincial
*Preescolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_pres2 dsp, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_esc dsp5_11, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_ado dsp12_19, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_adu2 dspeso19_59v2, ///
	  subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

****************************************************************************
*Prevalencia de obesidad nivel provincial
*Preescolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_pres2 dobes, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_esc dobes5_11, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_ado dobes12_19, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_adu2  dobes19_59v2, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de sobrepeso u obesidad a nivel provincial
*Preescolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_pres2 dspob, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_esc dspob5_11, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_ado dspob12_19,	///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_adu2 dspobes19_59v2, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de delgadez& delgadez severa a nivel provincial
*Escolares
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_esc ddelg5_11, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_ado ddelg12_19, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_adu2 dbpeso19_59v2, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}


********************************************************************************
*Prevalencia de peso normal en adultos a nivel provincial
*Adultos
tab provincia
local i = 1
while `i' <=26 {
	svy: tabulate grupo_adu2 dnorm19_59v2, ///
		subpop(if (provincia== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
log off
log close
translate mylogprovincial.smcl mylogprovincial.txt

********************************************************************************
*A nivel de Zonas de planificación:
log using mylogplanif, replace

********************************************************************************
*Prevalencia de desnutricion cronica por zona de planificación
*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dcronica , ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
 tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_esc dcro5_11, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_ado dcro12_19, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*******************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años por zona de planif.
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 daguda , ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion global en menores de 5 años por zona de planificac

tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dglobal, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}


********************************************************************************
*Prevalencia de riesgo de sobrepeso en menores de cinco años por zonas de planif
*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 drs, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

************************************************************************
*Prevalencia de sobrepeso a nivel por zona de planificacion
*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dsp, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dsp, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_esc dsp5_11, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adolescentes
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_ado dsp12_19 , ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Adultos
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_adu dspeso19_59v2, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de obesidad nivel por zonas de planificacion

*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dobes, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_esc dobes5_11, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_ado dobes12_19, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_adu dobes19_59v2, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*******************************************************************************
*Prevalencia de sobrepeso u obesidad por zonas de planificacion

*Preescolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_pres2 dspob, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_esc dspob5_11, ///
	  subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_ado dspob12_19, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_adu dspobes19_59v2, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de delgadez& delgadez severa por zonas de planificacion
*Escolares
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_esc ddelg5_11, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_ado ddelg12_19, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_adu dbpeso19_59v2, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

**********************************************************************************
*Prevalencia de peso normal en *adultos por zonas de planificacion

*Adultos
tab zonas_planificacion
local i = 1
while `i' <=9 {
	svy: tabulate grupo_adu dnorm19_59v2, ///
		subpop(if (zonas_planificacion== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

log off
log close
translate mylogplanif.smcl mylogplanif.txt

********************************************************************************
*A nivel de grupos etnicos
log using mylogetnia, replace

********************************************************************************
*Prevalencia de desnutricion crónica por etnia

*Preescolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres dcronica, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_esc dcro5_11, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_ado dcro12_19, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años por etnia

tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres daguda, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion global en menores de 5 años por etnia

tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres dglobal, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}


***************************************************************************
*Prevalencia de riesgo de sobrepeso en menores de cinco años por etnia

tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres drs, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

***************************************************************************
*Prevalencia de sobrepeso por etnia

*Preescolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres dsp, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_esc dsp5_11, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_ado dsp12_19 , ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_adu dspeso19_59v2, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

***********************************************************************
*Prevalencia de obesidad nivel por etnia

*Preescolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres dobes, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_esc dobes5_11, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_ado dobes12_19, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_adu dobes19_59v2, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de sobrepeso u obesidad a nivel por etnia
*Preescolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_pres dspob, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_esc dspob5_11, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_ado dspob12_19, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_adu dspobes19_59v2, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de delgadez& delgadez severa por etnia

*Escolares
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_esc ddelg5_11, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_ado ddelg12_19, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_adu dbpeso19_59v2, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de peso normal en adultos por etnia

*Adultos
tab gr_etn
local i = 1
while `i' <=4 {
	svy: tabulate grupo_adu dnorm19_59v2, ///
		subpop(if (gr_etn== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

log off
log close
translate mylogetnia.smcl mylogetnia.txt

*******************************************************************************
*Por Quintiles Economicos

log using mylogquint, replace

*******************************************************************************
*Prevalencia de desnutricion crónica por quintil
*Escolares
tab  quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dcronica, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Preescolares
tab  quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_esc dcro5_11, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab  quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_ado dcro12_19, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
********************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años por quintil

tab  quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres daguda, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*********************************************************************************Prevalencia de desnutricion global en menores de 5 años por quintil

tab  quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dglobal, ///
		subpop(if ( quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

********************************************************************************
*Prevalencia de desnutricion global en menores de 5 años por quintil

tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dglobal, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*********************************************************************************Prevalencia de riesgo de sobrepeso en menores de 5 años por quintil
*Preescolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres drs, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*****************************************************************************Prevalencia de sobrepeso por quintil

*Preescolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dsp, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_esc dsp5_11, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_ado dsp12_19 , ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_adu dspeso19_59v2, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

**************************************************************************Prevalencia de obesidad nivel por quintil
*Preescolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dobes, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Escolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_esc dobes5_11, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_ado dobes12_19, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_adu dobes19_59v2, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*********************************************************************************Prevalencia de sobrepeso u obesidad a nivel por quintil
*Preescolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_pres dspob, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}
*Escolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_esc dspob5_11, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_ado dspob12_19, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_adu dspobes19_59v2, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

**********************************************************************Prevalencia de delgadez& delgadez severa por quintil
*Escolares
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_esc ddelg5_11, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adolescentes
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_ado ddelg12_19, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*Adultos
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_adu dbpeso19_59v2, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

*********************************************************************************Prevalencia de peso normal en adultos por quintil

*Adultos
tab quint
local i = 1
while `i' <=5 {
	svy: tabulate grupo_adu dnorm19_59v2, ///
		subpop(if (quint== `i')) row se ci cv obs format(%17.4f)
	local i = `i' + 1
	}

log off
log close
translate mylogquint.smcl mylogquint.txt

*******************************************************************************
*Segun el nivel de instruccion de la madre

log using mylogmadre, replace

********************************************************************************Prev. de desnutricion crónica en <5a por nivel de instruccion de la madre
svy: tabulate escolaridad_madre dcronica, ///
	subpop(if (grupo_pres1==1)) row se ci obs format(%17.4f)

********************************************************************************Prev. de desnutricion aguda en <5a por nivel de instruccion de la madre

svy: tabulate escolaridad_madre daguda, ///
  subpop(if (grupo_pres1==1)) row se ci obs format(%17.4f)

******************************************************************************
*Prev. Desn. glo. en <5a por nivel de instruccion de la madre
svy: tabulate escolaridad_madre dglobal, ///
  subpop(if (grupo_pres1==1)) row se ci obs format(%17.4f)

******************************************************************************
*Prev. riesgo sobrepeso en <5a por nivel de instruccion de la madre
svy: tabulate escolaridad_madre drs, ///
  subpop(if (grupo_pres1==1 )) row se ci obs format(%17.4f)

*******************************************************************************
*Prev. sobrepeso en <5a por nivel de instruccion de la madre

svy: tabulate escolaridad_madre dsp, ///
  subpop(if (grupo_pres1==1)) row se ci obs format(%17.4f)

*******************************************************************************
*Prev. obesidad en <5a por nivel de instruccion de la madre
svy: tabulate escolaridad_madre dobes, ///
  subpop(if (grupo_pres1==1 )) row se ci obs format(%17.4f)

********************************************************************************
*Prev. sobrepeso u obes. en <5a por nivel de instruccion de la madre
svy: tabulate escolaridad_madre dspob, ///
  subpop(if (grupo_pres1==1 )) row se ci obs format(%17.4f)
svy: tab escolaridad_madre zonas_planificacion if grupo_pres4==1 & dcronica==1

log off
log close
translate mylogmadre.smcl mylogmadre.txt

********************************************************************************
*Prev.desn.cro. por nivel de instruccion de la madre y por zona de planificacion
local j = 1
while `j' <=9 {
    svy: tabulate escolaridad_madre dcronica, ///
	  subpop(if (grupo_pres==1 & zonas_planificacion==`j')) ///
	  row se ci cv obs format(%17.4f)
	local j = `j' + 1
	}

*********************************************************************************
*Prev.desn.cro. por nivel de instruccion de la madre y por grupo etnico
local j = 1
while `j' <=4 {
	svy: tabulate escolaridad_madre dcronica, ///
	  subpop(if (grupo_pres==1 & gr_etn==`j')) ///
	  row se ci cv obs format(%17.4f)
	local j = `j' + 1
	}

********************************************************************************
*Otros tipos de cruces
log using mylognacional2cat, replace

********************************************************************************
*Prevalencia de desnutricion crónica en menores de 5 años a nivel nacional
*Total
svy: tabulate grupo_pres2 dcronica , ///
  subpop(if (dcronica!=.)) row se ci cv obs format(%17.4f)


*******************************************************************************
*Prevalencia de desnutricion aguda en menores de 5 años a nivel nacional
*Total
svy: tabulate grupo_pres2	daguda, ///
  subpop(if ( daguda!=.)) row se ci cv obs format(%17.4f)

*******************************************************************************
*Prevalencia de desnutricion global en menores de 5 años a nivel nacional
*Total
svy: tabulate grupo_pres2 dglobal, ///
  subpop(if (dglobal!=.)) row se ci cv obs format(%17.4f)

*******************************************************************************
*Prevalencia de sobrepeso a nivel nacional
*Total Preescolares
svy: tabulate grupo_pres2	dsp, ///
  subpop(if ( dsp!=.)) row se ci cv obs format(%17.4f)
*Adultos Total
svy: tabulate grupo_adu2 dspeso19_59v2, ///
  subpop(if (dspeso19_59v2!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Prevalencia de obesidad a nivel nacional
*Total
svy: tabulate grupo_pres2 dobes, ///
	subpop(if (dobes!=.)) row se ci cv obs format(%17.4f)
*Adultos Total
svy: tabulate grupo_adu2 dobes19_59v2, ///
	subpop(if ( dobes19_59v2!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Prevalencia de sobrepeso u obesidad a nivel nacional
*Total
svy: tabulate grupo_pres2 dspob, ///
	subpop(if (dspob!=.)) row se ci cv obs format(%17.4f)
*Adultos Total
svy: tabulate grupo_adu2 dspobes19_59v2, ///
	subpop(if ( dspobes19_59v2!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Prevalencia de delgadez& delgadez severa a nivel nacional

*Adultos Total
svy: tabulate grupo_adu2 dbpeso19_59v2, ///
	subpop(if (dbpeso19_59v2!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Prevalencia de peso normal en adultos a nivel nacional

*Adultos Total
svy: tabulate grupo_adu2 dnorm19_59v2, ///
	subpop(if (dnorm19_59v2!=.)) row se ci cv obs format(%17.4f)

log off
log close
translate mylognacional2cat.smcl mylognacional12cat.txt

********************************************************************************
*Estadisticas generales descriptivas
gen comb_dcro_exc=1 if (dcronica==1 & dspob==1)
replace comb_dcro_exc=0 if (dcronica==0)
replace comb_dcro_exc=0 if (dspob==0)
replace comb_dcro_exc=. if (dspob==.)
replace comb_dcro_exc=. if (dcronica==.)

gen comb_dcro_exc_esc=1 if (dcro5_11==1 &	 dspob5_11==1)
replace comb_dcro_exc_esc=0 if (dcro5_11==0)
replace comb_dcro_exc_esc=0 if (dspob5_11==0)
replace comb_dcro_exc_esc=. if (dspob5_11==.)
replace comb_dcro_exc_esc=. if (dcro5_11==.)

********************************************************************************
*Promedios de peso y talla a nivel nacional
*Preescolares
tabout grupo_pres  if (gender==1 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Promediotallap1.txt, ///
  replace sum c(uwsum tallap count tallap p5 tallap p25 tallap  p50 ///
  tallap  p75 tallap  p95 tallap) f(1.1)
tabout grupo_pres  if (gender==2 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Promediotallap2.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)

tabout grupo_pres  if (gender==1 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Promediosdepesop1.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)
tabout grupo_pres  if (gender==2 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Promediosdepesop2.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)

tabout grupo_pres if (gender==1 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Mediatallap1.txt, replace sum svy c(mean tallap ci ) f(1.1)
tabout grupo_pres if (gender==2 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Mediatallap2.txt, replace sum svy c(mean tallap ci ) f(1.1)

tabout grupo_pres if (gender==1 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Mediapeso1.txt, replace sum svy c(mean pesof ci ) f(1.1)
tabout grupo_pres if (gender==2 & (_1zwei!=. & ///
  _1zlen!=. & _1zbmi!=. & _1zwfl!=.)) ///
  [aw= pw] using Mediapeso2.txt, replace sum svy c(mean pesof ci ) f(1.1)

*Escolares
tabout grupo_esc  if (gender==1 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Promediotallae1.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)
tabout grupo_esc  if (gender==2 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Promediotallae2.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)

tabout grupo_esc  if (gender==1 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Promediosdepesoe1.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)
tabout grupo_esc  if (gender==2 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Promediosdepesoe2.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)

tabout grupo_esc if (gender==1 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Mediatallae1.txt, replace sum svy c(mean tallap ci ) f(1.1)
tabout grupo_esc if (gender==2 & (_zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Mediatallae2.txt, replace sum svy c(mean tallap ci ) f(1.1)

tabout grupo_esc if (gender==1 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Mediapesoe1.txt, replace sum svy c(mean pesof ci ) f(1.1)
tabout grupo_esc if (gender==2 & ( _zbfa!=. & _zhfa!=. )) [aw= pw] using ///
  Mediapesoe2.txt, replace sum svy c(mean pesof ci ) f(1.1)

*Adolescentes
tabout grupo_ado  if (gender==1 & ( _zbfa!=.)) [aw= pw] using ///
  Promediotallaa1.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)
tabout grupo_ado  if (gender==2 & ( _zbfa!=.)) [aw= pw] using ///
  Promediotallaa2.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)

tabout grupo_ado  if (gender==1 & ( _zbfa!=.)) [aw= pw] using ///
  Promediosdepesoa1.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)
tabout grupo_ado  if (gender==2 & ( _zbfa!=.)) [aw= pw] using ///
  Promediosdepesoa2.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)

tabout grupo_ado if (gender==1 & ( _zbfa!=.)) [aw= pw] using ///
  Mediatallaa1.txt, replace sum svy c(mean tallap ci ) f(1.1)
tabout grupo_ado if (gender==2 & (_zbfa!=. )) [aw= pw] using ///
  Mediatallaa2.txt, replace sum svy c(mean tallap ci ) f(1.1)

tabout grupo_ado if (gender==1 & ( _zbfa!=.)) [aw= pw] using ///
  Mediapesoa1.txt, replace sum svy c(mean pesof ci ) f(1.1)
tabout grupo_ado if (gender==2 & ( _zbfa!=.)) [aw= pw] using ///
  Mediapesoa2.txt, replace sum svy c(mean pesof ci ) f(1.1)

*Adultos
 tabout grupo_adu  if (gender==1 & ( IMC!=.)) [aw= pw] using ///
  Promediotallad1.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)
tabout grupo_adu  if (gender==2 & ( IMC!=.)) [aw= pw] using ///
  Promediotallad.txt, replace sum c(uwsum tallap ///
  count tallap p5 tallap p25 tallap  p50 tallap  p75 tallap  p95 tallap) f(1.1)

tabout grupo_adu  if (gender==1 & ( IMC!=.)) [aw= pw] using ///
  Promediosdepesod1.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)
tabout grupo_adu  if (gender==2 & ( IMC!=.)) [aw= pw] using ///
  Promediosdepesod2.txt, replace sum c(uwsum pesof ///
  count pesof p5 pesof p25 pesof  p50 pesof  p75 pesof  p95 pesof) f(1.1)

tabout grupo_adu if (gender==1 & ( IMC!=.)) [aw= pw] using ///
  Mediatallad1.txt, replace sum svy c(mean tallap ci ) f(1.1)
tabout grupo_adu if (gender==2 & ( IMC!=. )) [aw= pw] using ///
  Mediatallad2.txt, replace sum svy c(mean tallap ci ) f(1.1)

tabout grupo_adu if (gender==1 & ( IMC!=.)) [aw= pw] using ///
  Mediapesod1.txt, replace sum svy c(mean pesof ci ) f(1.1)
tabout grupo_adu if (gender==2 & ( IMC!=.)) [aw= pw] using ///
  Mediapesod2.txt, replace sum svy c(mean pesof ci ) f(1.1)


********************************************************************************
*Desnutricion cronica por grupo Preescolares de comparación
*Masculino
svy: tabulate grupo_presc dcronicac  if dcronicac!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc dcronicac  if dcronicac!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc dcronicac , ///
  subpop(if (dcronicac!=.)) row se ci cv obs format(%17.4f)

*******************************************************************************
*Prevalencia de desnutricion aguda Preescolares grupos de comparación

*Masculino
svy: tabulate grupo_presc  dagudac  if  dagudac!=.,  ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc  dagudac  if  dagudac!=.,  ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc  dagudac,  ///
  subpop(if ( dagudac!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Prevalencia de desnutricion global por grupos de comparación
*Masculino
svy: tabulate grupo_presc dglobalc  if   dglobalc!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc dglobalc  if   dglobalc!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc dglobalc, ///
  subpop(if (dglobalc!=.)) row se ci cv obs format(%17.4f)

********************************************************************************
*Prevalencia de sobrepeso a nivel nacional por grupos de comparación
*Preescolares
*Masculino
svy: tabulate grupo_presc  dspc  if dspc!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc  dspc  if dspc!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc  dspc, ///
  subpop(if ( dspc!=.)) row se ci cv obs format(%17.4f)

********************************************************************************
*Prevalencia de obesidad a nivel nacional grupos de comparación
*Preescolares
*Masculino
svy: tabulate grupo_presc dobesc  if  dobesc!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc dobesc  if  dobesc!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc dobesc, ///
  subpop(if (dobesc!=.)) row se ci cv obs format(%17.4f)

********************************************************************
*Prevalencia de sobrepeso u obesidad a nivel nacional
*Preescolares
*Masculino
svy: tabulate grupo_presc dspobc  if dspobc!=., ///
  subpop(if sex==1 ) row se ci cv obs format(%17.4f)
*Femenino
svy: tabulate grupo_presc dspobc  if dspobc!=., ///
  subpop(if sex==2 ) row se ci cv obs format(%17.4f)
*Total
svy: tabulate grupo_presc dspobc, ///
  subpop(if (dspobc!=.)) row se ci cv obs format(%17.4f)

******************************************************************************
*Estadisticas Descriptivas del Nivel instruccion padres & madres/ base de
*Antropometria

use ensanut_f10_antropometria1.dta,clear
gen dantro=1
drop if (pw==. | pd03<6)
collapse (mean) dantro idhog, by(idmadre)
*Idpers == Idmadre valida
gen  elim=substr(idmadre, -1, 1)
gen  idpers= idmadre if elim!="."
drop if elim=="."
drop elim
lab var dantro "Madres de los niños menores a 5 a antro"
keep idpers dantro
save tp.dta,replace

use ensanut_f10_antropometria1.dta,clear
gen dantro=1
drop if (pw==. | pd03<6)
collapse (mean) dantro , by(idhog)
rename  dantro dhogantro
lab var dhogantro "Hogares con niños menores a 5 a antro"
keep idhog dhogantro
save tph.dta,replace

use ensanut_f1_personas.dta,clear
merge 1:1 idpers using tp
drop if _merge==2
drop _merge
merge m:1 idhog using tph
drop if _merge==2
drop _merge

gen educa = .
replace educa =1 if pd19a == 1 | pd19a == 2
replace educa = 2 if pd19a == 3 | pd19a == 4 | (pd19a == 6 & pd19b <= 7)
replace educa = 3 if pd19a == 5 | pd19a == 6 & educa == . | pd19a == 7
replace educa = 4 if pd19a >= 8 & pd19a <= 10

label define educa 1 "Sin instrucción formal" 2 "Hasta primaria" ///
3 "Hasta secundaria" 4 "Superior/postgrado", replace
label values educa educa

replace educa =. if pd03 < 5

svyset idsector [pweight=pw], strata (area)
log using "EducaMadrePadre.smcl",replace

di "Educacion de Madres"
local X  area  gr_etn nbi quint  subreg zonas_planificacion
local V   educa
foreach Y in `V' {
foreach Z in `X' {
   svy: tabulate `Z' `Y', ///
      subpop(if dantro==1) row ci format(%17.4f) cellwidth(15)
		}
	}
foreach Y in `V' {
foreach Z in `X' {
   svy: tabulate `Z' `Y', ///
      subpop(if dantro==1) obs count format(%17.4f) cellwidth(15)
		}
	}
di "Educacion de Padres"
local X  area  gr_etn nbi quint  subreg zonas_planificacion
local V   educa
foreach Y in `V' {
foreach Z in `X' {
   svy: tabulate `Z' `Y', ///
      subpop(if dhogantro==1 & pd06==1) row ci format(%17.4f) cellwidth(15)
		}
	}
foreach Y in `V' {
foreach Z in `X' {
   svy: tabulate `Z' `Y', ///
      subpop(if dhogantro==1 & pd06==1) obs count format(%17.4f) cellwidth(15)
		}
	}
log close
translate EducaMadrePadre.smcl EducaMadrePadre.log, ///
  replace linesize(255) translator(smcl2log)

*Análisis de Antropometria ensanut 2012 termina ahí******************************
