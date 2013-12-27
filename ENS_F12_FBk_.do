******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
*********************Tomo 1***************************************************
*********************Capítulo: Bioquímica*************************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboración: Maria Jose Mendieta michu@mendietajara.com
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
*Observacion: this code was orginaly written in SPSS, with small changes in
*date and age calculation.
*Preparación de bases:
*Variables de identificadores
clear all
set more off
*Ingresar el directorio de las bases:
cd ""
use ensanut_f12_bioquimica.dta,clear

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

merge 1:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 escol quint idmadre)
drop if _merge==2
drop _merge


*Variable de altura para correccion de hemoglobina
merge m:1 idhog using ensanut_f1_informacion_general.dta,keepusing(altitud)
drop if _merge ==2
drop _merge
replace altitud =0 if (altitud==9999)

*Mujeres embarazadas :
gen embrz=strpos(historia,"E")
recode embrz (12 13 = 1)

******************************************
*Grupos Edad General
gen gedad1=.
replace gedad1=1 if (edadmes>=6 & edadmes<12)
replace gedad1=2 if (edadmes>=12 & edadmes<24)
replace gedad1=3 if (edadmes>=24 & edadmes<36)
replace gedad1=4 if (edadmes>=36 & edadmes<48)
replace gedad1=5 if (edadmes>=48 & edadmes<60)
replace gedad1=6 if (edadanio>=5 & edadanio<12)
replace gedad1=7 if (edadanio>=12 & edadanio<15)
replace gedad1=8 if (edadanio>=15 & edadanio<20)
replace gedad1=9 if (edadanio>=20 & edadanio<30)
replace gedad1=10 if (edadanio>=30 & edadanio<40)
replace gedad1=11 if (edadanio>=40 & edadanio<50)
replace gedad1=12 if (edadanio>=50 & edadanio<60)
gen gedad1b=gedad1
replace gedad1=13 if (embrz==1)
label define gedad1 1 "5 a 11 meses" 2 "12 a 23 meses" 3 "24 a 35 meses" ///
  4 "36 a 47 meses" 5 "48 a 59 meses" 6 "de 5 a 11 años" 7 "de 12 a 14 años" ///
  8 "de 15 a 19 años" 9 "de 20 a 29 años" 10 "de 30 a 39 años" ///
  11 "40 a 49 años" 12 "50 a 59 años" 13 "Embarazadas",replace
label value gedad1 gedad1
label value gedad1b gedad1


**************************************************************
*Cuadros y salidas de SVY, todo los indicadores de Bioquimica
**************************************************************
svyset idsector [pweight=pw], strata (area)
**************************************************************
*PCR grupo sin embarazadas
*Deficiencia de PCR.
gen idefpcr=1 if (pcr!=. & pcr>10 & (gedad1>=1 & gedad1<=12))
replace idefpcr=0 if (pcr!=. & pcr<=10 & (gedad1>=1 & gedad1<=12))

**Descriptive stat & Prevalence PCR < 5 años /
*rango edad/sexo ->no medido en embarazadas
*8.11 8.12 Estadisticas Descriptivas
tabout  genero  gedad1 using 8.11.txt, replace  c(mean pcr ci )  ///
  sum svy  lines(none) f(3 3) lay(row)
tabout    gedad1 using 8.11.12.txt if   genero==1, append  ///
  c(count pcr median pcr sd pcr min pcr max pcr)  sum  lines(none) f(1) lay(row)
tabout    gedad1 using 8.11.12.txt if   genero==2, append  ///
  c(count pcr median pcr sd pcr min pcr max pcr)  sum  lines(none) f(1) lay(row)

*8.13 Menores de 5 años
tabout  gr_etn genero gedad1 using 8.13.txt if gedad1b<6, ///
  replace  c(mean idefpcr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout  gr_etn genero gedad1 using 8.13.txt if gedad1b<6, ///
  append  c(N idefpcr)  sum  lines(none) f(1) lay(row)

*8.14 Mayores de 5 años
tabout  gr_etn genero gedad1b using 8.14.txt if gedad1b>=6, ///
  replace  c(mean idefpcr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout  gr_etn genero gedad1b using 8.14.txt if gedad1b>=6, ///
  append  c(N idefpcr)  sum  lines(none) f(1) lay(row)

*8.14bis MEF
tabout gr_etn gedad1  using 8.14b.txt if gedad1>6 & gedad1<12 ///
  & genero ==2, replace c(mean idefpcr ci ) sum svy lines(none) f(3 3) lay(row)
tabout gr_etn gedad1  using 8.14b.txt if gedad1>6 & gedad1<12 & ///
  genero ==2 , append  c(N idefpcr)  sum  lines(none) f(1) lay(row)

**************************************************************
********anemia boy Dirren OMS

*Anemia calculo de la medicion de hemoglobina oms boy dirren
*Boy
gen hbr_frml=hb -(-0.032 * altitud * 0.0032808 + ///
  0.022 *( (altitud * 0.0032808)*(altitud * 0.0032808)))
gen an_boy=.
replace an_boy=1 if (hbr_frml<11 & edadmes<60)
replace an_boy=0 if (hbr_frml>=11 & edadmes<60)
replace an_boy=1 if (hbr_frml<11.5 & edadanio>=5 & edadanio<12)
replace an_boy=0 if (hbr_frml>=11.5 & edadanio>=5 & edadanio<12)
replace an_boy=1 if (hbr_frml<12 & edadanio>=12 & edadanio<15)
replace an_boy=0 if (hbr_frml>=12 & edadanio>=12 & edadanio<15)
replace an_boy=1 if (hbr_frml<12 & edadanio>=15 & edadanio<60 & genero==2)
replace an_boy=0 if (hbr_frml>=12 & edadanio>=15 & edadanio<60 & genero==2)
replace an_boy=1 if (hbr_frml<13 & edadanio>=15 & edadanio<60 & genero==1)
replace an_boy=0 if (hbr_frml>=13 & edadanio>=15 & edadanio<60 & genero==1)

*Dirren /Correccion de hemoglobina por Tablas de Dirren
gen hbr_tbl=.
replace  hbr_tbl=hb if (altitud >= 0 & altitud <= 199)
replace  hbr_tbl=hb -0.1 if (altitud >= 200 & altitud <= 499)
replace  hbr_tbl=hb -0.2 if (altitud >= 500 & altitud <= 699)
replace  hbr_tbl=hb -0.3 if (altitud >= 700 & altitud <= 999)
replace  hbr_tbl=hb -0.4 if (altitud >= 1000 & altitud <= 1199)
replace  hbr_tbl=hb -0.5 if (altitud >= 1200 & altitud <= 1399)
replace  hbr_tbl=hb -0.6 if (altitud >= 1400 & altitud <= 1499)
replace  hbr_tbl=hb -0.7 if (altitud >= 1500 & altitud <= 1699)
replace  hbr_tbl=hb -0.8 if (altitud >= 1700 & altitud <= 1899)
replace  hbr_tbl=hb -0.9 if (altitud >= 1900 & altitud <= 1999)
replace  hbr_tbl=hb -1.0 if (altitud >= 2000 & altitud <= 2099)
replace  hbr_tbl=hb -1.1 if (altitud >= 2100 & altitud <= 2299)
replace  hbr_tbl=hb -1.2 if (altitud >= 2300 & altitud <= 2399)
replace  hbr_tbl=hb -1.3 if (altitud >= 2400 & altitud <= 2499)
replace  hbr_tbl=hb -1.4 if (altitud >= 2500 & altitud <= 2599)
replace  hbr_tbl=hb -1.5 if (altitud >= 2600 & altitud <= 2699)
replace  hbr_tbl=hb -1.6 if (altitud >= 2700 & altitud <= 2799)
replace  hbr_tbl=hb -1.7 if (altitud >= 2800 & altitud <= 2899)
replace  hbr_tbl=hb -1.8 if (altitud >= 2900 & altitud <= 2999)
replace  hbr_tbl=hb -1.9 if (altitud >= 3000 & altitud <= 3099)
replace  hbr_tbl=hb - 2.0 if (altitud >= 3100 & altitud <= 3199)
replace  hbr_tbl=hb - 2.2 if (altitud >= 3200 & altitud <= 3299)
replace  hbr_tbl=hb - 2.3 if (altitud >= 3300 & altitud <= 3399)
replace  hbr_tbl=hb - 2.4 if (altitud >= 3400 & altitud <= 3499)
replace  hbr_tbl=hb - 2.6 if (altitud >= 3500 & altitud <= 3599)
replace  hbr_tbl=hb - 2.7 if (altitud >= 3600 & altitud <= 3699)
replace  hbr_tbl=hb - 2.9 if (altitud >= 3700 & altitud <= 3799)
replace  hbr_tbl=hb - 3.0 if (altitud >= 3800 & altitud <= 3899)
replace  hbr_tbl=hb - 3.2 if (altitud >= 3900 & altitud <= 3999)
replace  hbr_tbl=hb - 3.4 if (altitud >= 4000 & altitud <= 4499)
replace  hbr_tbl=hb - 4.4 if (altitud >= 4500)
gen an_dirren=0
replace an_dirren=1 if (hbr_tbl<11 & edadmes<60)
replace an_dirren=1 if (hbr_tbl<11.5 & edadanio>=5 &edadanio<10)
replace an_dirren=1 if (hbr_tbl<11.5 & edadanio>=10 &edadanio<12)
replace an_dirren=1 if (hbr_tbl<12 & edadanio>=12 &edadanio<15)
replace an_dirren=1 if (hbr_tbl<12 & edadanio>=15 &edadanio<60 & genero==2)
replace an_dirren=1 if (hbr_tbl<13 & edadanio>=15 &edadanio<60 & genero==1)
*replace an_dirren=. if edadmes>60

*OMS  /Tabla de OMS correccion de altura /Correccion de
*hemoglobina por Tablas de OMS
gen  hbr_to=.
replace  hbr_to=hb if (altitud < 1000)
replace  hbr_to=hb - .2 if (altitud >= 1000 & altitud <1500)
replace  hbr_to=hb - .5 if (altitud >= 1500 & altitud <2000)
replace  hbr_to=hb - .8 if (altitud >= 2000 & altitud <2500)
replace  hbr_to=hb - 1.3 if (altitud >= 2500 & altitud <3000)
replace  hbr_to=hb - 1.9 if (altitud >= 3000 & altitud <3500)
replace  hbr_to=hb - 2.7 if (altitud >= 3500 & altitud <4000)
replace  hbr_to=hb - 3.5 if (altitud >= 4000 & altitud <4500)
replace  hbr_to=hb - 4.5 if (altitud >= 4500)
gen an_oms=0
replace an_oms=1 if (hbr_frml<11 & edadmes<60)
replace an_oms=1 if (hbr_frml<11.5 & edadanio>=5 &edadanio<10)
replace an_oms=1 if (hbr_frml<11.5 & edadanio>=11 &edadanio<12)
replace an_oms=1 if (hbr_frml<12 & edadanio>=12 &edadanio<15)
replace an_oms=1 if (hbr_frml<12 & edadanio>=15 &edadanio<60 & genero==2)
replace an_oms=1 if (hbr_frml<13 & edadanio>=15 &edadanio<60 & genero==1)

**Descriptive stat & Prevalence Anemia < 5 años /rango edad/sexo

*8.15 8.16 Estadisticas Descriptivas
tabout  genero  gedad1b using 8.15.16.txt , ///
  replace  c(mean  hbr_frml ci )  sum svy  lines(none) f(3 3) lay(row)
tabout    gedad1b using 8.15.16.txt if   genero==1, append  ///
  c(count  hbr_frml median  hbr_frml sd  hbr_frml min  hbr_frml max  hbr_frml) ///
  sum  lines(none) f(1) lay(row)
tabout    gedad1b using 8.15.16.txt if   genero==2, append  ///
  c(count  hbr_frml median  hbr_frml sd  hbr_frml min  hbr_frml max  hbr_frml) ///
  sum  lines(none) f(1) lay(row)

*8.17 Menores de 5 años comparacion anemia boy dierren oms
local V an_boy an_oms an_dirren
foreach v in `V'{
	svy: tabulate gedad1 `v', subpop (if gedad1<6) ///
	  row ci format(%17.4f) cellwidth(15)
	svy: tabulate gedad1 `v', subpop (if gedad1<6) ///
	  obs count format(%17.4f) cellwidth(15)
	}
*8.19 Menores de 5 años anemia boy / genero pcr
tabout idefpcr genero  gedad1b using 8.19.txt if gedad1b<6, ///
  replace  c(mean an_boy ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.19.txt if gedad1b<6, ///
  append  c(N an_boy )  sum  lines(none) f(1) lay(row)

*8.20 Mayores de 5 años
tabout idefpcr genero  gedad1b using 8.20.txt if gedad1b>=6 ///
  & gedad1<12, replace  c(mean an_boy ci )  ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.20.txt if gedad1b>=6 & ///
  gedad1<12, append  c(N an_boy )  sum  lines(none) f(1) lay(row)

*8.20bis MEF *mujeres_en_edad_fertil por PCR
tabout idefpcr gedad1b using 8.20b.txt if gedad1b>6 & ///
  gedad1<12 & genero ==2, replace  c(mean an_boy ci )  ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr   gedad1b using 8.20b.txt if gedad1b>6 & ///
  gedad1<12 & genero==2, append  c(N an_boy )  ///
  sum  lines(none) f(1) lay(row)

*8.21 Anemia_boy Menores de 5 años subregion zonas de planificacion y grupo etn
tabout subreg zonas_pl   an_boy using 8.21.txt ///
  if gedad1b<6, replace  c(mean an_boy ci )  sum svy  lines(none) f(3 3)
tabout subreg zonas_pl   an_boy using 8.21.txt ///
  if gedad1b<6, append  c(N an_boy )  sum  lines(none) f(1)


*8.22 Anemia  MEF  por subregion y zonas de planificacion y grupo etnico
tabout subreg zonas_pl  gedad1 using 8.22.txt if gedad1>6 & gedad1<12 ///
  & genero==2, replace  c(mean an_boy ci )  ///
  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl   gedad1 using 8.22.txt ///
  if gedad1>6 & gedad1<12 ///
  & genero==2, append  c(N an_boy )  sum  lines(none) f(1) lay(row)

*8.23 Anemia  menores de 5  por quitil econ / grupo etnico
tabout quint gr_etn gedad1 using 8.23.txt if gedad1<6 ///
  & genero==2, replace  c(mean an_boy ci )  ///
  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1 using 8.23.txt if gedad1<6 ///
  & genero==2, append c(N an_boy ) sum lines(none) f(1) lay(row)

*8.24 Anemia  MEF   por quitil econ / grupo etnico
tabout quint gr_etn gedad1 using 8.24.txt if gedad1>6 & gedad1<12 ///
  & genero==2, replace c(mean an_boy ci) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1 using 8.24.txt if gedad1>6 & gedad1<12 ///
  & genero==2, append  c(N an_boy )  sum  lines(none) f(1) lay(row)


*******************************************************************************
*Volumen Corpuscular medio
*gen idefvcm
*volumen corpuscular medio.
gen idefvcm=1 if (vcm<77 & (gedad1==1|gedad1==2|gedad1==3))
replace idefvcm=0 if (vcm>=77 & (gedad1==1|gedad1==2|gedad1==3))
replace idefvcm=1 if (vcm<79 & (gedad1==4 | gedad1==5))
replace idefvcm=0 if (vcm>=79 & (gedad1==4 | gedad1==5))
replace idefvcm=1 if (vcm<79 & (edadanio>=5 & edadanio<6))
replace idefvcm=0 if (vcm>=79 & (edadanio>=5 & edadanio<6))
replace idefvcm=1 if (vcm<80 & (edadanio>=6 & edadanio<10))
replace idefvcm=0 if (vcm>=80 & (edadanio>=6 & edadanio<10))
replace idefvcm=1 if (vcm<80 & (edadanio>=10 & edadanio<12))
replace idefvcm=0 if (vcm>=80 & (edadanio>=10 & edadanio<12))
replace idefvcm=1 if (vcm<82 & (edadanio>=12 & edadanio<15))
replace idefvcm=0 if (vcm>=82 & (edadanio>=12 & edadanio<15))
replace idefvcm=1 if (vcm<82 & gedad1==8)
replace idefvcm=0 if (vcm>=82 & gedad1==8)
replace idefvcm=1 if (vcm<85 & gedad1>=9 & gedad1<13)
replace idefvcm=0 if (vcm>=85 & gedad1>=9 & gedad1<13)

*8.25 8.26 VCM Estadisticas descriptivas
tabout  genero  gedad1b using 8.25.26.txt , replace  ///
  c(mean vcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout  gedad1b using 8.25.26.txt if   genero==1, append  ///
  c(count  vcm median  vcm sd  vcm min  vcm max  vcm) ///
  sum  lines(none) f(1) lay(row)
tabout  gedad1b using 8.25.26.txt if   genero==2, append  ///
  c(count  vcm median  vcm sd  vcm min  vcm max  vcm) ///
  sum  lines(none) f(1) lay(row)

*8.27 VCM en  menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.27.txt if gedad1b<6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.27.txt if gedad1b<6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.28 VCM en  mayores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.28.txt if gedad1b>=6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.28.txt if gedad1b>=6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.28b VCM en MEF por grupos de edad, por PCR y genero
tabout idefpcr   gedad1b using 8.28b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, replace  c(mean idefvcm ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr  gedad1b using 8.28b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2 ,append  c(N idefvcm )  ///
  sum  lines(none) f(1) lay(row)

*8.29 VCM en  menores  de 5 años grupos de edad, por subregion y zonas de plan
tabout subreg zonas_pl  gedad1b using 8.29.txt if gedad1b<6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1b using 8.29.txt if gedad1b<6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.30 VCM en  mayores de 5 años genero, por subregion y zonas de plan
tabout subreg zonas_pl  gedad1b using 8.30.txt if gedad1b>=6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1b using 8.30.txt if gedad1b>=6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.30b VCM en  MEF, por subregion y zonas de plan
tabout  subreg zonas_pl  gedad1b using 8.30b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean idefvcm ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  subreg zonas_pl  gedad1b using 8.30b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N idefvcm )  ///
  sum  lines(none) f(1) lay(row)

*8.31 VCM en  menores  de 5 años grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.31.txt if gedad1b<6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.31.txt if gedad1b<6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.32 VCM en  mayores de 5 años genero, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.32.txt if gedad1b>=6, ///
  replace  c(mean idefvcm ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.32.txt if gedad1b>=6, ///
  append  c(N idefvcm )  sum  lines(none) f(1) lay(row)

*8.32b VCM en  MEF grupos de edad, por Quintil y grupo etnico
tabout  subreg zonas_pl  gedad1b using 8.32b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean idefvcm ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  subreg zonas_pl  gedad1b using 8.32b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N idefvcm )  ///
  sum  lines(none) f(1) lay(row)

*************************************************************************************
***Ferritina
*ferritina
gen idefferr=1 if (ferritin!=. & ferritin<12 & (gedad1>=1 & gedad1<=5))
replace idefferr=0 if (ferritin!=. & ferritin>=12 & (gedad1>=1 & gedad1<=5))
replace idefferr=1 if (ferritin!=. & ferritin<15 & gedad1>=6 & gedad1<13)
replace idefferr=0 if (ferritin!=. & ferritin>=15 & gedad1>=6 & gedad1<13)

gen ferritin_log=.
replace ferritin_log=ferritin
replace ferritin_log=ln(ferritin)

*8.34 8.35 Ferritina: Estadisticas descriptivas
tabout  genero  gedad1 using 8.34.35.txt , replace  ///
  c(mean  ferritin ci )  sum svy  lines(none) f(3 3) lay(row)
tabout  gedad1 using 8.34.35.txt if   genero==1, append  ///
  c(count  ferritin median  ferritin sd  ferritin min  ferritin max  ferritin) ///
  sum  lines(none) f(1) lay(row)
tabout  gedad1 using 8.34.35.txt if   genero==2, append  ///
  c(count  ferritin median  ferritin sd  ferritin min  ferritin max  ferritin) ///
  sum  lines(none) f(1) lay(row)

*8.36 Deficiencia de  Ferritina en  menores de 5 años grupos de edad,
* por PCR y genero
tabout idefpcr genero  gedad1b using 8.36.txt if gedad1b<6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.36.txt if gedad1b<6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.37 Deficiencia de Ferritina en  mayores de 5 años grupos de edad,
* por PCR y genero
tabout idefpcr genero  gedad1b using 8.37.txt if gedad1b>=6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.37.txt if gedad1b>=6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.37b Deficiencia de Ferritina en MEF por grupos de edad, por PCR y genero
tabout idefpcr   gedad1b using 8.37b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, replace  c(mean idefferr ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr  gedad1b using 8.37b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2 ,append  c(N idefferr )  ///
  sum  lines(none) f(1) lay(row)

*8.38 Deficiencia de Ferritina en  menores  de 5 años
*grupos de edad,
* por subregion y zonas de plan
tabout subreg zonas_pl  gedad1b using 8.38.txt if gedad1b<6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1b using 8.38.txt if gedad1b<6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.39 Deficiencia de Ferritina en  mayores de 5 años genero,
* por subregion y zonas de plan
tabout subreg zonas_pl  gedad1b using 8.39.txt if gedad1b>=6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1b using 8.39.txt if gedad1b>=6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.39b Deficiencia de Ferritina en  MEF, por subregion y zonas de plan
tabout  subreg zonas_pl  gedad1b using 8.39b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean idefferr ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  subreg zonas_pl  gedad1b using 8.39b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N idefferr )  ///
  sum  lines(none) f(1) lay(row)

*8.40 Deficiencia de Ferritina en  menores  de 5 años
*grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.40.txt if gedad1b<6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.40.txt if gedad1b<6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.41 Deficiencia de Ferritina en  mayores de 5 años genero,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.41.txt if gedad1b>=6, ///
  replace  c(mean idefferr ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.41.txt if gedad1b>=6, ///
  append  c(N idefferr )  sum  lines(none) f(1) lay(row)

*8.41b Deficiencia de Ferritina en  MEF grupos de edad,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.41b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean idefferr ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.41b.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N idefferr )  ///
  sum  lines(none) f(1) lay(row)

********************************************************************
**Estimacion de Anemia con Deficit de Hierro y Otros Indicadores
*gen tipoanemia
gen tipoanemia=.
replace tipoanemia=0 if gedad1<6 & hbr_frml>=11
replace tipoanemia=1 if gedad1<6 & hbr_frml>=10 & hbr_frml<11
replace tipoanemia=2 if gedad1<6 & hbr_frml>=7 & hbr_frml<10
replace tipoanemia=3 if gedad1<6 & hbr_frml<7
lab def tipoanemia 1 "leve" 2 "moderada" 3 "severa"
lab val tipoanemia tipoanemia

**Iron defficiency
gen ideficiency=1 if  (idefvcm==1 & idefferr==1)
replace ideficiency=1 if  (idefvcm==1 & idefferr==0)
replace ideficiency=1 if  (idefvcm==0 & idefferr==1)
replace ideficiency=2 if  (idefvcm==0 & idefferr==0)
lab def ideficiency 1 "Deficiencia" 2 "Sin deficiencia"
lab val ideficiency ideficiency

*Clase de anemia:
gen clasanem=1 if  (an_boy==0 & idefferr==0 & idefvcm==0)
replace clasanem=2 if an_boy==1 & ((idefferr==1 & idefvcm==0)|idefvcm==1)
replace clasanem=3 if an_boy==1 & idefferr==0 & idefvcm==0
replace clasanem=4 if idefferr!=. & an_boy==0 & (idefferr==1|idefvcm==1)
lab def clasanem 1 "Sin deficiencia de hierro, sin anemia" ///
  2 "Anemia por deficiencia de hierro " 3 "Anemia por otras causas" ///
  4 "Deficiencia de hierro sin anemia",replace
lab val clasanem clasanem

*8.42 Prevalencia de anemia / severidad <5 a por grupo de edad
log using 8.42, replace
svy: tabulate gedad1b tipoanemia , subpop(if gedad1b<6) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
svy: tabulate gedad1b an_boy , subpop(if gedad1b<6) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
log close
translate 8.42 8.42.txt, replace linesize(255) translator(smcl2txt)

*8.43 Prevalencia de deficiencia de hierro, anemia por deficiencia de
*de hierro y anemia por otras causas en menores de cinco años
log using 8.43, replace
svy: tabulate gedad1 clasanem, subpop(if gedad1<6 & idefpcr==0) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
svy: tabulate genero clasanem, subpop(if gedad1<6 & idefpcr==0) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
log close
translate 8.43 8.43.txt, replace linesize(255) translator(smcl2txt)
*8.44 Prevalencia de deficiencia de hierro, anemia por
*deficiencia de hierro y anemia por otras causas en
*hombres y mujeres 12 a 49 años
log using 8.44, replace
di "Deficiencia/Anemia + Grupos de edad 5 a 59"
svy: tabulate gedad1 clasanem, subpop(if gedad1>=6 & gedad1<13 & idefpcr==0) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
di "Deficiencia + Sexo pop 5 a 59"
svy: tabulate genero clasanem, subpop(if gedad1>=6 & gedad1<13 & idefpcr==0) ///
  obs  row ci format(%17.4f) cellwidth(15)  vert
di "Deficiencia/Anemia + MEF 12 a 49"
svy: tabulate gedad1 clasanem, subpop(if gedad1>6 & gedad1<12 & genero==2 ///
  & idefpcr==0) obs  row ci format(%17.4f) cellwidth(15)  vert
log close
translate 8.44 8.44.txt, replace linesize(255) translator(smcl2txt)

********************************************************************
**Zinc Sérico
gen gedad2 = gedad1
replace gedad2=9 if gedad1>9 & genero==2 & gedad1<13
replace gedad2=. if gedad1>9 & genero==1
label define gedad2 1 "5 a 11 meses" 2 "12 a 23 meses" 3 "24 a 35 meses" ///
  4 "36 a 47 meses" 5 "48 a 59 meses" 6 "de 5 a 11 años" 7 "de 12 a 14 años" ///
  8 "de 15 a 19 años" 9 "MEF de 20 a 59 años sin emb.",replace
label value gedad2 gedad2

*gen zndef *Zn
*gen zndef=1 if  (zinc!=. & zinc<65 & edadanio<=9)
*replace zndef=0 if  (zinc!=. & zinc>=65 & edadanio<=9)
*replace zndef=1 if  (zinc!=. & zinc<70 & genero==2 & edadanio>9  & gedad1 <= 13)
*replace zndef=0 if  (zinc!=. & zinc>=70 & genero==2 & edadanio>9 & gedad1 <= 13)
*replace zndef=1 if  (zinc!=. & zinc<74 & genero==1 & edadanio>9 & gedad1 <= 8)
*replace zndef=0 if  (zinc!=. & zinc>=74 & genero==1 & edadanio>9 & gedad1 <= 8)

*8.45 8.46 Zinc: Estadisticas descriptivas
tabout gedad2  using 8.45.46.txt if genero==1 & gedad2<9, ///
  replace  c(mean  zinc ci )  sum svy  lines(none) f(3 3) lay(row)
tabout gedad2 using 8.45.46.txt if genero==2 & gedad2<13, ///
  replace  c(mean  zinc ci )  sum svy  lines(none) f(3 3) lay(row)
tabout  gedad1 using 8.45.46.txt if  genero==1 & gedad1<9, append  ///
  c(count  zinc median  zinc sd  zinc min  zinc max  zinc) ///
  sum  lines(none) f(1) lay(row)
tabout  gedad1 using 8.45.46.txt if   genero==2, append  ///
  c(count  zinc median  zinc sd  zinc min  zinc max  zinc) ///
  sum  lines(none) f(1) lay(row)

*8.47 def Zinc en  menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.47.txt if gedad1b<6, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.47.txt if gedad1b<6, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.48 Deficiencia de Zinc en  de 5 a 19 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.48.txt if gedad1b>=6 & gedad1b<=8, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.48.txt if gedad1b>=6 & gedad1b<=8, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.49 Deficiencia de Zinc en MEF por grupos de edad, por PCR y genero
tabout idefpcr   gedad1b using 8.49.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, replace  c(mean zndef ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr  gedad1b using 8.49.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2 ,append  c(N zndef )  ///
  sum  lines(none) f(1) lay(row)

*8.50 Deficiencia de Zinc en  menores  de 5 años grupos de edad,
*por subregion y zonas de plan
tabout subreg zonas_pl  gedad1b using 8.50.txt if gedad1b<6, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1b using 8.50.txt if gedad1b<6, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.51 Deficiencia de Zinc poblacion de  5 a 19 años genero,
*por subregion y zonas de plan
tabout subreg zonas_pl gedad1b using 8.51.txt if gedad1b>=6 & gedad1b<=8, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.51.txt if gedad1b>=6 & gedad1b<=8, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.52 Deficiencia de Zinc en  MEF, por subregion y zonas de plan
tabout  subreg zonas_pl  gedad1b using 8.52.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean zndef ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  subreg zonas_pl  gedad1b using 8.52.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N zndef )  ///
  sum  lines(none) f(1) lay(row)

*8.53 Deficiencia de Zinc en  menores  de 5 años grupos de edad,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.53.txt if gedad1b<6, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.53.txt if gedad1b<6, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.54 Deficiencia de Zinc en  5-19 años genero, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.54.txt if gedad1b>=6 & gedad1b<=8, ///
  replace  c(mean zndef ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.54.txt if gedad1b>=6 & gedad1b<=8, ///
  append  c(N zndef )  sum  lines(none) f(1) lay(row)

*8.55 Deficiencia de Zinc en  MEF grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.55.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2,replace  c(mean zndef ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.55.txt if gedad1b>6 & ///
  gedad1b<12 & genero==2, append  c(N zndef )  ///
  sum  lines(none) f(1) lay(row)

********************************************************************
**Vitamina A
*gen idefvita
gen vitadl= vita*100
gen idefvita=1 if (vitadl!=. & vitadl<20 & (gedad1>=1 & gedad1<=13))
replace idefvita=0 if (vitadl!=. & vitadl>=20 & (gedad1>=1 & gedad1<=13))

*8.56  VitA: Estadisticas descriptivas > 5 anos
tabout  genero  gedad1 using 8.56.txt if gedad1<6,replace c(mean vita ci) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  gedad1b using 8.56.txt if gedad1<6, append  ///
  c(count  vita median  vita sd  vita min  vita max  vita) ///
  sum  lines(none) f(1) lay(row)
tabout  gedad1 using 8.56.txt if gedad1<6, append  ///
  c(count  vita median  vita sd  vita min  vita max  vita) ///
  sum  lines(none) f(1) lay(row)

*8.57  VitA: Estadisticas descriptivas m f 5-9 anos
tabout  genero  gedad1 using 8.57.txt if edadanio>4 & edadanio<9, ///
  replace c(mean vita ci) sum svy  lines(none) f(3 3) lay(row)
tabout  gedad1 using 8.57.txt if edadanio>4 & edadanio<9 & ///
  genero==1,append c(count vita median vita sd vita min vita max vita) ///
  sum  lines(none) f(1) lay(row)
tabout  gedad1 using 8.57.txt if edadanio>4 & edadanio<9 & ///
  genero==2,append c(count vita median vita sd vita min vita max vita) ///
  sum  lines(none) f(1) lay(row)

*8.58 def Vit.A en  menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.58.txt if gedad1b<6, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.58.txt if gedad1b<6, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)

*8.59 Deficiencia de Vit.A en  de 5 a 9 años grupos de edad, por PCR y genero
tabout idefpcr genero  gedad1b using 8.59.txt if gedad1b>=6 & edadanio<=9, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr genero  gedad1b using 8.59.txt if gedad1b>=6 & edadanio<=9, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)

*8.60 Deficiencia de Vit.A en MEF por grupos de edad, por PCR y genero
tabout idefpcr   gedad1 using 8.60.txt if gedad1b>8 & ///
  gedad1b<12 & genero==2, replace  c(mean idefvita ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout idefpcr  gedad1 using 8.60.txt if gedad1b>8 & ///
  gedad1b<12 & genero==2 ,append  c(N idefvita )  ///
  sum  lines(none) f(1) lay(row)

*8.61 Deficiencia de Vit.A en  menores  de 5 años grupos de edad,
*por subregion y zonas de plan
tabout subreg zonas_pl  gedad1 using 8.61.txt if gedad1b<6, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl  gedad1 using 8.61.txt if gedad1b<6, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)


*8.62 Deficiencia de Vit.A poblacion de  5 a 9 años genero,
*por subregion y zonas de plan
tabout subreg zonas_pl gedad1 using 8.62.txt if gedad1b>=6 & edadanio<=9, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1 using 8.62.txt if gedad1b>=6 & edadanio<=9, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)

*8.63 Deficiencia de Vit.A en  MEF 20-49,
*por subregion y zonas de plan
tabout  subreg zonas_pl  gedad1b using 8.63.txt if gedad1b>8 & ///
  gedad1b<12 & genero==2,replace  c(mean idefvita ci ) ///
  sum svy  lines(none) f(3 3) lay(row)
tabout  subreg zonas_pl  gedad1b using 8.63.txt if gedad1b>8 & ///
  gedad1b<12 & genero==2, append  c(N idefvita )  ///
  sum  lines(none) f(1) lay(row)

*8.64 Deficiencia de Vit.A en  menores  de 5 años grupos de edad,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1 using 8.64.txt if gedad1b<6, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1 using 8.64.txt if gedad1b<6, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)

*8.65 Deficiencia de Vit.A en  5-9 años genero,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.65.txt if gedad1b>=6 & edadanio<=9, ///
  replace  c(mean idefvita ci )  sum svy  lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.65.txt if gedad1b>=6 & edadanio<=9, ///
  append  c(N idefvita )  sum  lines(none) f(1) lay(row)


********************************************************************
**Folato
*gen ideffol?
*ÁCIDO FÓLICO.
gen ideffolser=1 if (fols!=. & fols<4 &  (gedad1>=1 & gedad1<=12))
replace ideffolser=2 if (fols!=. & fols>=4 &  (gedad1>=1 & gedad1<=12))
gen  ideffoleri=1 if (foler!=. & foler<151 &  (gedad1>=1 & gedad1<=12))
replace ideffoleri=2 if (foler!=. & foler>=151 &  (gedad1>=1 & gedad1<=12))

*def foler menores de 5 años grupos de edad, genero, y pcr
svy: tabulate gedad1 ideffoleri, subpop (if gedad1<6)

*8.74 Prev val anom ac fol ser nac 10-14 15-19 20-39 40-59 por genero
*8.75 Est. decr. Yodo Escolares m20-49a
*Graph mediana de estado de yodo Subreg Escolares m20-49a
*Graph mediana de estado de yodo zona_pl Escolares m20-49a
*Graph mediana de estado de yodo quintil  Escolares m20-49a
*Graph mediana de estado de gr_etn quintil  Escolares m20-49a

****************************************************************************
**********Cuadro de numero de individuos n N
********************************
*Individuos por variables y grupos de edad
*grupos de analisis 6mo-<6a/6-<10a/10<20a/20<60añosMnoemb&H
gen gan=.
replace gan=1 if (edadmes>=6 & edadanio<6 )
replace gan=2 if (edadanio>=6 & edadanio<10)
replace gan=3 if (edadanio>=10 & edadanio<20)
replace gan=4 if (edadanio>=20 & edadanio<60 & embrz!=1)
lab def gan 1 "6mo-<6a" 2 "6-<10a" 3 "10<20a" 4 "20<60añosMnoemb&H"
lab val gan gan
*Grupos especificos de analisis "1_6<12a" "2_M20<49a" "3_M20_49a+Emb" "4_HM20<60a"
gen gasp=.
replace gasp=1 if (edadanio>=6 & edadanio<12)
replace gasp=3 if (edadanio>=20 & edadanio<49 & pd02==2)
lab def gasp 1 "6<12a" 2 "M20<49a" 3 "M20_49a+Emb" 4 "HM20<60a"
lab val gasp gasp


gen n=1
svyset idsector [pweight=pw], strata (area)
svy: tab gedad1 n, obs  count format(%17.4f) cellwidth(15)

*Primera serie Biometría hemática VCM Ferritina PCR Fol Foler
svy: tab gan n, subpop( if vcm!=.)  obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if fols!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if foler!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if pcr!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if ferritin!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if hct!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if wbc!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if hb!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if linfo!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if mono!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if neutro!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if baso!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n, subpop( if eos!=.) obs count format(%17.4f) cellwidth(15)

*Segunda serie Biometría hemática Zinc
svy: tab gan n,subpop( if zinc!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if zinc!=. & pd02==2) ///
  obs count format(%17.4f) cellwidth(15)

*Tercera serie vita
svy: tab gan n,subpop( if vita!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if vita!=. & pd02==2) ///
  obs count format(%17.4f) cellwidth(15)

*Cuarta serie alb
svy: tab gan n,subpop( if alb!=.) obs count format(%17.4f) cellwidth(15)

*Quinta serie Yodo
svy: tab gan n,subpop( if yodo!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if yodo!=. & edadanio<12) ///
  obs count format(%17.4f) cellwidth(15)

svy: tab n,subpop( if yodo!=. & edadanio>=20 & edadanio<60) ///
  obs count format(%17.4f) cellwidth(15)
*Sexta serie trig hdlc ldlc chol glucosa vitb12 insulina
svy: tab gan n,subpop( if trig!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if hdlc!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if ldlc!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if chol!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if glucosa!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if vitb12!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if insulina!=.) obs count format(%17.4f) cellwidth(15)


*Análisis de Bioquímica ensanut 2012 termina ahí********************************







