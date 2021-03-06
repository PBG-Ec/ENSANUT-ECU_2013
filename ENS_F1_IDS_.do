*****************************************************************************
**************Encuesta Nacional de Salud y Nutrici�n 2011-2013****************
**************Tomo 1 *********************************************************
**************Informaci�n general / migracion internacional*******************
**************Personas y Vivienda ********************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe: Wilma Freire
  Elaboraci�n: Wilma Freire  freirewi@gmail.com
  Philippe Belmont Guerr�n, MSP-ENSANUT  philippebelmont@gmail.com
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
*Preparaci�n de bases: Personas - Migraci�n - Mortalidad -
*Informaci�n General - Vivienda
*Variables de identificadores
clear all
set more off
*Ingresar el directorio de las bases:
*ej. cd "C:\Users\Desktop\ENSANUT"
cd ""

*Identificadores para las bases de personas y vivienda:
global bases ensanut_f1_informacion_general ensanut_f1_personas ///
  ensanut_f1_migracion_internacional ensanut_f1_mortalidad ensanut_f1_vivienda
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

******************************************************************************
*Preparaci�n de la base de Personas con variabels de cruce
use ensanut_f1_personas.dta,clear
*Identificador de madre
cap gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
cap drop idptemp
lab var idmadre "Identificador de madre"



*Edad en mes base Personas:
*Fecha nacimiento en dias:
replace pd04a=. if pd04a==99
replace pd04b=. if pd04b==99
replace pd04c=. if pd04c==9999
cap gen dob=mdy(pd04b,pd04a,pd04c)
*Fecha de la encuesta en dias:
cap merge m:1 idhog using ensanut_f1_informacion_general.dta, ///
  keepusing(dia mes anio)
cap drop if _merge==2
cap drop _merge

cap gen dov=mdy(mes,dia,anio)
cap gen edaddias = dov- dob
cap gen edadmes= int(edaddias/30)
cap gen edadanio= int(edadmes/12)

*Identificador de madres
cap gen idptemp=hogar*10^2+pd08b
cap egen idmadre=concat (idviv idptemp),format(%20.0f)
cap drop idptemp idptemp
cap lab var idmadre "Identificador de madre"


*A�os de escolaridad (segun sintaxis NBI inec 2013):
drop escol
replace pd19b=. if (pd19b==99)
gen escol=0  if (pd19a==1 | pd19a==3)
replace escol=pd19b*2  if pd19a==2
replace escol=pd19b    if pd19a==4
replace escol=pd19b+6  if pd19a==5
replace escol=0 if (pd19a==6 & pd19b==0)
replace escol=pd19b-1  if (pd19a==6 & pd19b>=1 & pd19b<.)
replace escol=pd19b+9  if pd19a==7
replace escol=pd19b+12 if (pd19a==8 | pd19a==9)
replace escol=pd19b+17 if pd19a==10
replace escol=escol-1 if (pd16==1 & pd19a!=2 & escol>=1 & escol<.)
replace escol=escol-2 if (pd16==1 & pd19a==2 & escol>=1 & escol<.)

*Experiencia profesional
cap gen exper=0
replace exper=edadanio-escol-6 if escol>4
replace exper=edadanio-10 if escol<=4
replace exper=0 if exper<0

**Variable de Grupo Etnico
cap gen gr_etn= pd13
replace gr_etn=1 if pd13==1
replace gr_etn=2 if (pd13==2 | pd13==3 | pd13==4)
replace gr_etn=3 if pd13==5
replace gr_etn=4 if (pd13==6 | pd13==7 | pd13==8)
label define etn 1 "Indigena" 2 "Afroecuatoriano" 3 "Montubio" ///
  4 "Resto de la Poblacion", replace
label values gr_etn etn

**Variable de Estado Civil
*Casado o uni�n libre
cap gen estado_civil=1 if (pd14==1 | pd14==2)
*Soltero
replace estado_civil=2 if pd14==6
*Divorciado o separado
replace estado_civil=3 if (pd14==3 | pd14==4)
*Viudo
replace estado_civil=4 if pd14==5
label define eciv 1 "Casado o uni�n libre" 2 "Soltero" ///
  3 "Divorsiado o separado" 4 "Viudo", replace
label values estado_civil eciv

********************************************************************************
*Variable de provincias y subregiones
*Variable de Dominios 26 (90150 / 170150 +15 km ag pot> 45% )
*Con el fin de abarcar el �rea de influencia de las ciudades de Quito y
*Guayaquil, se incluyeron adem�s de la divisi�n politico-administrativa
*parroquial los sectores urbanizados (criterio: % de agua potable >45%) hasta
*una distancia de 15 km de l�mite parroquial.

cap gen provincia=int(ciudad/10000)
 replace provincia=26 if (ciudad==90150)
replace provincia=26 if (idsector==90156002001|idsector==90650005002| ///
  idsector==90650010006|idsector==90650017006|idsector==90750008003| ///
  idsector==90750012003|idsector==90750027006|idsector==90750038003| ///
  idsector==90750043009|idsector==90750049010|idsector==90750055004| ///
  idsector==92150005002|idsector==92150009003|idsector==92150999010| ///
  idsector==92550001005)
replace provincia=25 if (ciudad==170150)
replace provincia=25 if (idsector==170151903014|idsector==170155007007| ///
  idsector==170155012006|idsector==170155017004|idsector==170155021001| ///
  idsector==170155024007|idsector==170155028005|idsector==170155031004| ///
  idsector==170155034007|idsector==170155038008|idsector==170156001002| ///
  idsector==170156005009|idsector==170156009007|idsector==170156013007| ///
  idsector==170156016003|idsector==170156910008|idsector==170157004005| ///
  idsector==170157007005|idsector==170160002001|idsector==170163003004| ///
  idsector==170164999023|idsector==170170002004|idsector==170170999010| ///
  idsector==170175002009|idsector==170177003005|idsector==170177006010| ///
  idsector==170179999033|idsector==170180002004|idsector==170180005011| ///
  idsector==170184002002|idsector==170184005009|idsector==170184999006| ///
  idsector==170184999066|idsector==170357999007)
label define pro 1 "Azuay" 2 "Bol�var" 3 "Ca�ar" 4 "Carchi" 5 "Cotopaxi" ///
  6 "Chimborazo" 7 "El Oro" 8 "Esmeraldas" 9 "Guayas" 10 "Imbabura" 11 ///
  "Loja " 12 "Los R�os" 13 "Manab�" 14 "Morona Santiago" 15 "Napo" 16 ///
  "Pastaza" 17 "Pichincha" 18 "Tungurahua" 19 "Zamora Chinchipe" 20 ///
  "Gal�pagos" 21 "Sucumb�os" 22 "Orellana" 23 "Sto Domingo de los Ts�chilas" ///
  24 "Santa Elena" 25 "Quito" 26 "Guayaquil", replace
label values provincia pro


*Variable de Region / Subregion
*regi�n= Sierra Urbana
cap gen subreg=1 if (area==1 & (provincia==1 | provincia==2 | provincia==3| ///
  provincia==4 | provincia==5 | provincia==6 | provincia==10| provincia==11| ///
  provincia==17 | provincia==18 | provincia==23))
*regi�n= Sierra Rural
replace subreg=2 if (area==2 & ( provincia==1 | provincia==2 | provincia==3| ///
  provincia==4 | provincia==5 | provincia==6 | provincia==10|provincia==11| ///
  provincia==17 | provincia==18 | provincia==23))
*regi�n= Costa Urbana
replace subreg=3 if (area==1 & (provincia==7 |provincia==8 | provincia==9| ///
  provincia==12 | provincia==13 | provincia==24))
*regi�n= Costa Rural
replace subreg=4 if (area==2& (provincia==7 |provincia==8 | provincia==9| ///
  provincia==12 | provincia==13 | provincia==24))
*regi�n= Oriente Urbano
replace subreg=5 if (area==1 & (provincia==14| provincia==15| provincia==16| ///
  provincia==19 | provincia==21 | provincia==22))
*regi�n= Oriente Rural
replace subreg=6 if (area==2 & (provincia==14| provincia==15| provincia==16| ///
  provincia==19 | provincia==21 | provincia==22))
*regi�n= Galapagos
 replace subreg=7 if ( provincia==20)
*regi�n= Guayaquil
 replace subreg=8 if (provincia==25)
*regi�n= Quito
 replace subreg=9 if (provincia==26)
label define sbr 1 "Sierra Urbana" 2 "Sierra Rural" 3 "Costa Urbana" 4  ///
  "Costa Rural" 5 "Amazonia Urbana" 6 "Amazonia Rural" 7 "Galapagos" 8  ///
  "Quito" 9 "Guayaquil",replace
label value subreg sbr

*******************************************************************************
**Variable de Zonas de planificacion (9)
cap gen prov=int(ciudad/10000)
*Esmeralda, Imbabura, Carchi, Sucumbios
cap gen zonas_planificacion=1 if (prov==4 | prov==8 | prov==10 | prov==21)
*Pichincha (excepto Quito), Napo y Orellana
replace zonas_planificacion=2 if (prov==15 | prov==17 | prov==22)
*Cotopaxi, Tungurahua, Chimborazo, Pastasa
replace zonas_planificacion=3 if (prov==5 | prov==6 | prov==16 | prov==18)
*Manab�, Santo Domingo de los Sachiras
replace zonas_planificacion=4 if (prov==13 | prov==23)
*Santa Helena, Guayas (excepto Guayaquil, Samborondon y Dur�n),
*Bol�var, Los Rios, Gal�pagos
replace zonas_planificacion=5 if (prov==24 | prov==9 | ///
  prov==2 | prov==12 | prov==20)
*Ca�ar, Azuai, Morona Santiago
replace zonas_planificacion=6 if (prov==1 | prov==3 | prov==14)
*El Oro, Loja; Zamora, Chinchipe
replace zonas_planificacion=7 if (prov==7 | prov==11 | prov==19)
*Cantones de Guayaquil, San Borondon y Duran
replace zonas_planificacion=8 if (ciudad==90150 | ciudad==90156 | ///
  ciudad==90157 | ciudad==90750 | ciudad==91650 | ciudad==91651)
*DM de Quito
 replace zonas_planificacion=9 if (ciudad==170150)

********************************************************************************
*C�lculo de necesidades basicas insatisfechas

*Variables de hogar para NBI:
merge m:1  idhog using ensanut_f1_vivienda, ///
  keepusing(vi02 vi04 vi07 vi06 vi08 vi11 vi05)
drop _merge

replace vi11 = . if vi11 == 99
recode pd06 (6= 5)(5=6)
gen pob_siise=1

*Personas vivendo en viviendas particulares
cap gen viv_parti=1 if (vi02>=1  & vi02<=7)
replace viv_parti=0 if (vi02>=8 & vi02<=17)

*N�mero de personas por hogar
cap egen numper=count(pob_siise), by (idhog)

*************************************
*1er componente: dependencia econ�mica
*A�os de escolaridad del jefe de hogar -observacion:cada a�o aprobado del
*centro de alfabetizaci�n equivale a 2 a�os en el antiguo sistema de educaci�n
cap gen escol1=escol

*Jefes de hogar con 2 a�os o menos de educaci�n primaria
cap gen escje_=1 if  escol1<=2 & pd06==1
replace escje_=0 if (escol1>=3 & escol1<. & pd06==1)
replace escje_=0 if (escje_==. &  pd06==1 &(pd19a==5 |(pd19a>=7 & pd19a<=10)))
cap egen escje = max(escje_) if viv_parti==1, by(idhog)
cap drop escje_

*Definicion de Ocupados
cap gen ocup_=0 if  pd03>=10
replace ocup_=1 if (pa01>=1 & pa01<=5 & pd03>=10)
cap egen ocup = sum (ocup_) if viv_parti==1, by(idhog)
cap drop ocup_

*Ocupados por personas en el hogar
cap gen ocupc=numper/ocup

*M�s de tres ocupados por persona en el hogar u hogar sin ocupados
cap gen m3ocuxper=0 if  (ocupc<=3 & viv_parti==1)
replace m3ocuxper=1 if (ocupc> 3 & ocupc<. & viv_parti==1)
replace m3ocuxper=1 if (ocup==0 & viv_parti==1)

*Dependencia econ�mica
cap gen depec=0 if escje!=. & m3ocuxper!=.
replace depec=1 if escje==1 & m3ocuxper==1
drop  escol1 escje ocup ocupc m3ocuxper pob_siise

**********************************************************
*2do componente: hogares con ni�os que no asisten a clases
cap gen noasis_=0 if (pd16==1 & pd03>=6 & pd03<=12)
replace noasis_=1 if (pd16==2 & pd03>=6 & pd03<=12)
cap egen    noasis = sum (noasis_) if viv_parti==1, by(idhog)

cap drop hog_noasis
cap gen hog_noasis= 0 if  noasis==0
replace hog_noasis= 1 if (noasis>= 1 & noasis<.)
cap drop noasis_ noasis

****************************************
*3er componente: materiales deficitarios
cap drop matdef
cap gen matdef=0 if (vi04>=1 & vi04<=5) & (vi05>=1 & vi05<=5)
replace matdef=1 if (vi04>=6 & vi04<=7) | (vi05>=6 & vi05<=7)

***************************************
*4to componente: servicios deficitarios
cap drop agua_ade
cap gen agua_ade=0 if (viv_parti==1)
replace agua_ade=1 if (viv_parti==1 & vi06==1 & vi07==1)

*Vivienda con agua de red p�blica y tuberia dentro de la vivienda
cap drop serdef
cap gen serdef=0 if (agua_ade==1 & vi08>=1 & vi08<=2)
replace serdef=1 if (agua_ade==0 | (vi08>=3 & vi08!=.))
cap drop agua_ade

******************************
*5to componente: hacinamiento
cap gen perdor=numper/vi11
replace perdor=numper if( vi11==0)
cap drop hacina
cap gen hacina=0 if (perdor<=3)
replace hacina=1 if (perdor>3 & perdor<.)
cap drop perdor

******************************************
*NBI : suma de necesidades no satisfechas
cap drop nbi
cap egen nbi=rsum(depec hog_noasis matdef serdef hacina)
replace nbi=. if (nbi==0 & (depec==. | hog_noasis==.))
label var nbi "Necesidades Basicas Insatisfechas"

*Variable Pobre por nbi (NBI>0)
cap drop pobre
cap gen pobre=0 if  nbi==0
replace pobre=1 if (nbi>=1 & nbi<=5)

*Pobreza extrema por nbi (NBI>1)
cap drop pobre_ext
cap gen pobre_ext=0 if (nbi==0 | nbi==1)
replace pobre_ext=1 if (nbi>=2 & nbi<=5)
save ensanut_f1_personas.dta,replace
********************************************************************************
*Calculo de Quintil Economico
use ensanut_f1_personas, clear
sort idviv
keep idviv pw
collapse (mean) pw, by (idviv)
drop if pw == .
save vpw, replace

use ensanut_f1_vivienda, clear
sort idviv
cap merge m:1 idviv using vpw
cap keep if _merge ==3
cap drop _merge

qui recode  vi02 (1/2=1) (nonmissing=0), gen(cv1)
qui recode  vi03 (1/3=1) (nonmissing=0), gen(cv2)
qui recode  vi04 (1/2=1) (nonmissing=0), gen(cv3)
qui recode  vi05 (1/4=1) (nonmissing=0), gen(cv4)
qui recode  vi06 (1/1=1) (nonmissing=0), gen(cv5)
qui recode  vi07 (1/1=1) (nonmissing=0), gen(cv6)
qui recode  vi08 (1/1=1) (nonmissing=0), gen(cv7)
qui recode  vi10 (1/1=1) (nonmissing=0), gen(cv8)
gen cv9= vi12/ vi11
qui recode  vi13 (1/1=1) (nonmissing=0), gen(cv10)
qui recode  vi16 (1/1=1) (nonmissing=0), gen(cv11)
qui recode  vi17 (1/1=1) (nonmissing=0), gen(cv12)
qui recode  vi18 (1/1=1) (nonmissing=0), gen(cv13)
forvalues i=2001/2029 {
qui recode  vi`i' (1=1) (nonmissing=0), gen(cv`i')
}
cap factor cv* [aw = pw], pcf
cap predict  proxy_index
cap xtile quint   = proxy_index [aw = pw], nq(5)
cap mean cv*, over(quint)

save ensanut_f1_vivienda, replace

use ensanut_f1_personas, clear
cap merge m:1 idhog using ensanut_f1_vivienda, keepusing(quint)
cap drop _merge
save ensanut_f1_personas, replace

********************************************************************************
*Cuadro descriptivos generales
*Cobertura Sectores / Viviendas
use ensanut_f1_personas.dta,clear
*Sectores
cap gen  n=1
collapse (sum) n, by(idsector area provin)
replace n=1
collapse (sum) n, by(area provin)

*Viviendas
use ensanut_f1_personas.dta,clear
cap gen  n=1
collapse (sum) n, by(idviv area provincia)
replace n=1
collapse (sum) n, by(area provincia)

*Viviendas Submuestra
use ensanut_f1_personas.dta,clear
cap gen  n=1
drop if pd05c12==0
collapse (sum) n, by(idviv area provin)
replace n=1
collapse (sum) n, by(area provin)


***Cuadros de poblacion
*Individuos de f1: grupo de edad
*0a<6m 	6a12meses 1a<4a�os 4a<5a�os 5<10a�os 10a<12a�os	12a<18a�os
*12a<18a�os 18a<20a�os 18a<20a�os 20a<50a�os	20a<50a�os 50a59a�os 50a59a�os
use ensanut_f1_personas.dta,clear
replace pd03=. if pd03==99
replace edadanio=pd03 if edadanio==.
cap gen gedad=.
replace gedad=1 if (edadmes<6 & edadmes!=.)
replace gedad=2 if (edadmes>=6 & edadmes<12)
replace gedad=3 if (edadmes>=12 & edadanio<4)
replace gedad=4 if (edadanio>=4 & edadanio<5)
replace gedad=5 if (edadanio>=5 & edadanio<10)
replace gedad=6 if (edadanio>=10 & edadanio<12)
replace gedad=7 if (edadanio>=12 & edadanio<18 & pd02==1)
replace gedad=8 if (edadanio>=12 & edadanio<18 & pd02==2)
replace gedad=9 if (edadanio>=18 & edadanio<20 & pd02==1)
replace gedad=10 if (edadanio>=18 & edadanio<20 & pd02==2)
replace gedad=11 if (edadanio>=20 & edadanio<50 & pd02==1)
replace gedad=12 if (edadanio>=20 & edadanio<50 & pd02==2)
replace gedad=13 if (edadanio>=50 & edadanio<60 & pd02==1)
replace gedad=14 if (edadanio>=50 & edadanio<60 & pd02==2)

lab def gedad 1 "0a<6m  " 2 "6a12m " 3 "1a<4a " 4 "4a<5a "  ///
  5 "5<10a " 6 "10a<12a " 7 "12a<18ah " 8 "12a<18am " 9 "18a<20ah "  ///
  10 "18a<20am " 11 "20a<50ah " 12 "20a<50am " 13 "50a59ah " 14 "50a59am ",replace
lab val gedad gedad

svyset idsector [pweight=pw], strata (area)
local X  pd02 area  gr_etn quint  subreg zonas_planificacion
local V  gedad
foreach Z in `X' {
foreach Y in `V' {
svy: tabulate `Y' `Z' ,obs count format(%17.4f) cellwidth(15)
svy: tabulate `Y' `Z' ,row count format(%17.4f) cellwidth(15)
  }
}

**Caracteristicas de Hogar
*Hacinamiento
use "ensanut_f1_personas.dta",clear
cap gen pob_s=1
cap egen numper=count(pob_s), by (idhog)
cap keep if pd06==1
ren escol escolj
ren  estado_civil  est_civj
ren zonas_planificacion  zpl
ren gr_etn etn
keep idhog  etn  est_civj zpl subreg nbi pobre quint escolj numper
keep  idhog etn  est_civj zpl pobre escolj numper
save varj.dta,replace

use ensanut_f1_vivienda.dta,clear

replace vi11 = . if vi11 == 99
merge 1:1 idhog using varj
drop _merge

gen perdor=numper/vi11
replace perdor=numper if vi11==0

cap drop hacina
gen hacina=0 if perdor<=3
replace hacina=1 if perdor>3 & perdor<.
drop perdor

*Recodificacion de categorias marginales
gen vi02r = vi02
replace  vi02r=8 if vi02==6 | vi02==7
gen vi09r = vi09
replace  vi09r=5 if vi09==2 | vi09==3
gen vi10r = vi10
replace  vi10r=6 if vi10==2 | vi10==4 | vi10==5
gen vi19r = vi19
replace  vi19r=1 if vi19==2 | vi19==3
replace  vi19r=7 if vi19==5
lab def vi19r 1 "propia" 4 "prestada o cedida" 6 "arrendada" 7 "otro"
lab val vi19r vi19r
lab val vi02r vi02
lab val vi09r vi09
lab val vi10r vi10

*variables de cruces :
merge 1:m idhog using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 edadanio quint nbi)
drop if _merge==2
drop _merge


svyset idsector [pweight=pw], strata (area)

*Cuadros
log using Carhog.smcl
local X  area  gr_etn   subreg zonas_planificacion nbi quint
local V   hacin vi02r vi06 vi08 vi09r vi10r vi15 vi17 vi18 vi19r
foreach Y in `V' {
foreach Z in `X' {
svy: tabulate `Z' `Y' ,row ci format(%17.4f) cellwidth(15)
svy: tabulate `Z' `Y' ,obs count format(%17.4f) cellwidth(15)
  }
}
log close
translate Carhog.smcl carhog.log, replace linesize(255) translator(smcl2log)

*An�lisis de Caracteristica de Hogar ensanut 2012 termina ah�*******************
