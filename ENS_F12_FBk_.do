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
Freire, W.B., P. Belmont, M-J. Mendieta, P. Piñeiros, M-J. Ramirez, N. Romero,
 y M.K. Silva. Encuesta Nacional de Salud y Nutrición del Ecuador ENSANUT-ECU
 TOMO I. Salud y Nutrición. Quito, Ecuador: MSP / INEC, 2013.

A BibTeX entry for LaTeX users is:

@book{freire_encuesta_2013,
	address = {Quito, Ecuador},
 title = {Encuesta Nacional de Salud y Nutrición del Ecuador. {ENSANUT-ECU}
 {TOMO} I. Salud y Nutrición},
	publisher = {{MSP} / {INEC}},
 author = {Freire, {W.B.} and Belmont, P. and Mendieta, M-J. and Piñeiros,
 P. and Ramirez, M-J. and Romero, N. and Silva, {M.K.}},
	year = {2013}
}

*/

******************************************************************************
*Preparación de bases
set more off
*Ingresar el directorio de las bases:
cd ""
use ensanut_f12_bioquimica.dta,clear

*Variables de identificadores
*Identificador de personas / Hogar / vivienda
cap drop id*
gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
format idhog %20.0f
gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
format idviv %20.0f
gen idptemp=hogar*10^2+persona
egen idpers=concat (idviv idptemp),format(%20.0f)
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

gen gedadvita=.
replace gedadvita=1 if edadanio>=5 & edadanio<6
replace gedadvita=2 if edadanio>=6 & edadanio<7
replace gedadvita=3 if edadanio>=7 & edadanio<8
replace gedadvita=4 if edadanio>=8 & edadanio<9
replace gedadvita=5 if edadanio>=9 & edadanio<10
label define gedadvita 1 "5 a 6 años" 2 "6 a 7 años" 3 "7 a 8 años" ///
  4 "8 a 9" 5 "9 a 10"
label value gedadvita gedadvita

*Grupos de edad para totales en PCR
gen gedad2=.
replace gedad2=1 if (edadmes>=6 & edadmes<60)
replace gedad2=2 if (edadanio>=5 & edadanio<60)

label define gedad2 1 "menores de 5 años" 2 "de 5 a 59", replace
label value gedad2 gedad2

*** Grupos de edad para Totales en Hemoglobina
gen gedad3=.
replace gedad3=1 if (edadmes>=6 & edadmes<60)
replace gedad3=2 if (edadanio>=5 & edadanio<12)
replace gedad3=3 if (edadanio>=12 & edadanio<20)
replace gedad3=4 if (edadanio>=20 & edadanio<60 & genero==1)
replace gedad3=5 if (edadanio>=20 & edadanio<60 & genero==2)

label define gedad3 1 "menores de 5 años" 2 "escolares" 3 "adolescentes" ///
  4 "adultos hombres" 5 "adultos mujeres", replace
label value gedad3 gedad3

**** Edades para adultos

gen gedad4=.
replace gedad4=1 if (edadanio>=20 & edadanio<30 & genero==1)
replace gedad4=2 if (edadanio>=30 & edadanio<40 & genero==1)
replace gedad4=3 if (edadanio>=40 & edadanio<60 & genero==1)
replace gedad4=4 if (edadanio>=20 & edadanio<30 & genero==2)
replace gedad4=5 if (edadanio>=30 & edadanio<40 & genero==2)
replace gedad4=6 if (edadanio>=40 & edadanio<50 & genero==2)
replace gedad4=7 if (edadanio>=50 & edadanio<60 & genero==2)


label define gedad4 1 "hombres 20 a 29" 2 "hombres 30 a 39" ///
  3 "hombres 40 a 60" 4 "MEF 20 a 29" 5 "MEF 30 a 39" 6 "MEF 40 a 49" ///
  7 "MEF 50 a 59", replace
label value gedad4 gedad4

*Totales
gen gedad5=.
replace gedad5=1 if (edadanio>=20 & edadanio<60 & genero==1)
replace gedad5=2 if (edadanio>=20 & edadanio<50 & genero==2)
replace gedad5=3 if (edadanio>=50 & edadanio<60 & genero==2)
lab def gedad5 1 "hombres 20 a 59" 2 "MEF" 3 "mujeres de 50 a 59", replace
label value gedad5 gedad5

*Svyset
svyset idsector [pweight=pw], strata (area)

********************************************************************************
*Analisis y cuadros del capitulo Bioquimica


****************************************
*PCR grupo sin embarazadas
drop if embrz==1
*Deficiencia de PCR.
gen idefpcr=1 if (pcr!=. & pcr>10 & (gedad1>=1 & gedad1<=12))
replace idefpcr=0 if (pcr!=. & pcr<=10 & (gedad1>=1 & gedad1<=12))

**Descriptive stat & Prevalence PCR < 5 años rango edad/sexo
*Estadisticas Descriptivas
svy: mean pcr, over (gedad1)
estpost tabstat pcr [aw=pw], ///
 by(gedad1) statistics(count median sd p25 p95) columns(statistics)
svy: mean pcr, subpop(if genero==1) over (gedad1)
estpost tabstat pcr [aw=pw] if genero==1, ///
 by(gedad1) statistics(count median sd p25 p95) columns(statistics)
svy: mean pcr, subpop(if genero==2) over (gedad1)
estpost tabstat pcr [aw=pw] if genero==2, ///
 by(gedad1) statistics(count median sd p5 p95) columns(statistics)
*Totales
 svy: mean pcr, over (gedad2)
estpost tabstat pcr [aw=pw], ///
 by(gedad2) statistics(count median sd p5 p95) columns(statistics)
svy: mean pcr, subpop(if genero==1) over (gedad2)
estpost tabstat pcr [aw=pw] if genero==1, ///
 by(gedad2) statistics(count median sd p5 p95) columns(statistics)
svy: mean pcr, subpop(if genero==2) over (gedad2)
estpost tabstat pcr [aw=pw] if genero==2, ///
 by(gedad2) statistics(count median sd p5 p95) columns(statistics)

*8.12b MEF
svy: mean pcr, subpop(if genero==2 & gedad1>6 & gedad1<12) over (gedad1)
estpost tabstat pcr if genero==2 & gedad1>6 & gedad1<12, ///
 by(gedad1) statistics(count median max min) columns(statistics)

*Prevalencia inflamación en Menores de 5 años
estpost svy: tab gedad1 idefpcr if gedad1<6, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.12.txt, ///
 c("obs row lb ub") tab replace unstack
estpost svy: tab genero idefpcr if gedad1<6, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.12.txt, ///
 c("obs row lb ub") tab append unstack
estpost svy: tab gr_etn idefpcr if gedad1<6, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.12.txt, ///
 c("obs row lb ub") tab append unstack

*Mayores de 5 años
estpost svy: tab gedad1 idefpcr if gedad1>=6 & gedad1<13, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.14.txt, ///
 c("obs row lb ub") tab replace unstack
estpost svy: tab genero idefpcr if gedad1>=6 & gedad1<13, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.14.txt, ///
 c("obs row lb ub") tab append unstack
estpost svy: tab gr_etn idefpcr if gedad1>=6 & gedad1<13, ///
 obs row ci format(%17.4f) cellw(20)
esttab . using cuadro8.14.txt, ///
 c("obs row lb ub") tab append unstack


*8.14bis MEF
tabout gr_etn gedad1 using 8.14b.txt if gedad1>6 & gedad1<12 ///
 & genero ==2, replace c(mean idefpcr ci ) sum svy lines(none) f(3 3) lay(row)
tabout gr_etn gedad1 using 8.14b.txt if gedad1>6 & gedad1<12 & ///
 genero ==2 , append c(N idefpcr) sum lines(none) f(1) lay(row)


****************************************
*Anemia: boy Dirren OMS

*Anemia calculo de la medicion de hemoglobina oms boy dirren
*Boy
gen hbr_frml=hb -(-0.032 * altitud * 0.0032808 + ///
 0.022 *( (altitud * 0.0032808)*(altitud * 0.0032808)))
replace hbr_frml=. if hbr_frml>19
replace hbr_frml=. if embrz==1
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
replace hbr_tbl=hb if (altitud >= 0 & altitud <= 199)
replace hbr_tbl=hb -0.1 if (altitud >= 200 & altitud <= 499)
replace hbr_tbl=hb -0.2 if (altitud >= 500 & altitud <= 699)
replace hbr_tbl=hb -0.3 if (altitud >= 700 & altitud <= 999)
replace hbr_tbl=hb -0.4 if (altitud >= 1000 & altitud <= 1199)
replace hbr_tbl=hb -0.5 if (altitud >= 1200 & altitud <= 1399)
replace hbr_tbl=hb -0.6 if (altitud >= 1400 & altitud <= 1499)
replace hbr_tbl=hb -0.7 if (altitud >= 1500 & altitud <= 1699)
replace hbr_tbl=hb -0.8 if (altitud >= 1700 & altitud <= 1899)
replace hbr_tbl=hb -0.9 if (altitud >= 1900 & altitud <= 1999)
replace hbr_tbl=hb -1.0 if (altitud >= 2000 & altitud <= 2099)
replace hbr_tbl=hb -1.1 if (altitud >= 2100 & altitud <= 2299)
replace hbr_tbl=hb -1.2 if (altitud >= 2300 & altitud <= 2399)
replace hbr_tbl=hb -1.3 if (altitud >= 2400 & altitud <= 2499)
replace hbr_tbl=hb -1.4 if (altitud >= 2500 & altitud <= 2599)
replace hbr_tbl=hb -1.5 if (altitud >= 2600 & altitud <= 2699)
replace hbr_tbl=hb -1.6 if (altitud >= 2700 & altitud <= 2799)
replace hbr_tbl=hb -1.7 if (altitud >= 2800 & altitud <= 2899)
replace hbr_tbl=hb -1.8 if (altitud >= 2900 & altitud <= 2999)
replace hbr_tbl=hb -1.9 if (altitud >= 3000 & altitud <= 3099)
replace hbr_tbl=hb - 2.0 if (altitud >= 3100 & altitud <= 3199)
replace hbr_tbl=hb - 2.2 if (altitud >= 3200 & altitud <= 3299)
replace hbr_tbl=hb - 2.3 if (altitud >= 3300 & altitud <= 3399)
replace hbr_tbl=hb - 2.4 if (altitud >= 3400 & altitud <= 3499)
replace hbr_tbl=hb - 2.6 if (altitud >= 3500 & altitud <= 3599)
replace hbr_tbl=hb - 2.7 if (altitud >= 3600 & altitud <= 3699)
replace hbr_tbl=hb - 2.9 if (altitud >= 3700 & altitud <= 3799)
replace hbr_tbl=hb - 3.0 if (altitud >= 3800 & altitud <= 3899)
replace hbr_tbl=hb - 3.2 if (altitud >= 3900 & altitud <= 3999)
replace hbr_tbl=hb - 3.4 if (altitud >= 4000 & altitud <= 4499)
replace hbr_tbl=hb - 4.4 if (altitud >= 4500)
replace hbr_tbl=. if embrz==1
gen an_dirren=0
replace an_dirren=1 if (hbr_tbl<11 & edadmes<60)
replace an_dirren=1 if (hbr_tbl<11.5 & edadanio>=5 &edadanio<10)
replace an_dirren=1 if (hbr_tbl<11.5 & edadanio>=10 &edadanio<12)
replace an_dirren=1 if (hbr_tbl<12 & edadanio>=12 &edadanio<15)
replace an_dirren=1 if (hbr_tbl<12 & edadanio>=15 &edadanio<60 & genero==2)
replace an_dirren=1 if (hbr_tbl<13 & edadanio>=15 &edadanio<60 & genero==1)
*replace an_dirren=. if edadmes>60

*OMS /Tabla de OMS correccion de altura /Correccion de
*hemoglobina por Tablas de OMS
gen hbr_to=.
replace hbr_to=hb if (altitud < 1000)
replace hbr_to=hb - .2 if (altitud >= 1000 & altitud <1500)
replace hbr_to=hb - .5 if (altitud >= 1500 & altitud <2000)
replace hbr_to=hb - .8 if (altitud >= 2000 & altitud <2500)
replace hbr_to=hb - 1.3 if (altitud >= 2500 & altitud <3000)
replace hbr_to=hb - 1.9 if (altitud >= 3000 & altitud <3500)
replace hbr_to=hb - 2.7 if (altitud >= 3500 & altitud <4000)
replace hbr_to=hb - 3.5 if (altitud >= 4000 & altitud <4500)
replace hbr_to=hb - 4.5 if (altitud >= 4500)
replace hbr_to=. if embrz==1
gen an_oms=0
replace an_oms=1 if (hbr_to<11 & edadmes<60)
replace an_oms=1 if (hbr_to<11.5 & edadanio>=5 &edadanio<10)
replace an_oms=1 if (hbr_to<11.5 & edadanio>=11 &edadanio<12)
replace an_oms=1 if (hbr_to<12 & edadanio>=12 &edadanio<15)
replace an_oms=1 if (hbr_to<12 & edadanio>=15 &edadanio<60 & genero==2)
replace an_oms=1 if (hbr_to<13 & edadanio>=15 &edadanio<60 & genero==1)

*Descriptive stat & Prevalence Anemia < 5 años /rango edad/sexo

*Estadisticas Descriptivas
tabout genero gedad1b using 8.15.16.txt , ///
 replace c(mean hbr_frml ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad1b using 8.15.16.txt if genero==1, append ///
 c(count hbr_frml median hbr_frml sd hbr_frml p5 hbr_frml p95 hbr_frml) ///
 sum lines(none) f(1) lay(row)
tabout gedad1b using 8.15.16.txt if genero==2, append ///
 c(count hbr_frml median hbr_frml sd hbr_frml p5 hbr_frml p95 hbr_frml) ///
 sum lines(none) f(1) lay(row)

*Estadísticas descriptivas con totales para menores de 5 años, escolares,
*adolescentes y adultos
tabout genero gedad3 using 8.15.16.1.txt , ///
 replace c(mean hbr_frml ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad3 using 8.15.16.1.txt if genero==1, append ///
 c(count hbr_frml median hbr_frml sd hbr_frml p5 hbr_frml p95 hbr_frml) ///
 sum lines(none) f(1) lay(row)
tabout gedad3 using 8.15.16.1.txt if genero==2, append ///
  c(count hbr_frml median hbr_frml sd hbr_frml p5 hbr_frml p95 hbr_frml) ///
  sum lines(none) f(1) lay(row)


*8.15.16b MEF
svy: mean hbr_frml, subpop(if genero==2) over (gedad1)
estpost tabstat hbr_frml if genero==2, by(gedad1) ///
  statistics(count median max min) columns(statistics)

*Menores de 5 años comparacion anemia boy dierren oms
local V an_boy an_oms an_dirren
foreach v in `V'{
	svy: tabulate gedad1 `v', subpop (if gedad1<6 & hbr_frml!=.,) ///
	 row ci format(%17.4f) cellwidth(15)
	svy: tabulate gedad1 `v', subpop (if gedad1<6 & hbr_frml!=.,) ///
	 obs count format(%17.4f) cellwidth(15)
	}

* Anemia nacional
svy: tabulate gedad1b an_boy, subpop (if gedad1<6 & hbr_frml!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b an_boy, subpop (if gedad1<6 & hbr_frml!=.) ///
  obs count format(%17.4f) cellwidth(15)

*Menores de 5 años anemia boy / genero pcr
tabout idefpcr genero gedad1b using 8.19.txt if gedad1b<6 & hbr_frml!=., ///
 replace c(mean an_boy ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.19.txt if gedad1b<6 & hbr_frml!=., ///
 append c(N an_boy ) sum lines(none) f(1) lay(row)


 *Anemia menores de 5 por quintil econ / grupo etnico
tabout quint gr_etn gedad1 using 8.23.txt if gedad1<6 & hbr_frml!=., ///
  replace c(mean an_boy ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1 using 8.23.txt if gedad1<6 & hbr_frml!=., ///
  append c(N an_boy ) sum lines(none) f(1) lay(row)

 *Anemia_boy Menores de 5 años subregion zonas de planificacion
tabout subreg zonas_pl gedad1 using 8.21.txt if gedad1<6 & hbr_frml!=., ///
  replace c(mean an_boy ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1 using 8.21.txt if gedad1b<6 & hbr_frml!=., ///
  append c(N an_boy ) sum lines(none) f(1) lay(row)

****************************************
*Escolares
*nacional
svy: tabulate gedad1b an_boy, subpop (if gedad1b==6 & hbr_frml!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b an_boy, subpop (if gedad1b==6 & hbr_frml!=.) ///
  obs count format(%17.4f) cellwidth(15)
*Sexo y pcr
tabout idefpcr genero gedad1b using 8.20a.txt if gedad1b==6 & hbr_frml!=., ///
  replace c(mean an_boy ci)sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.20a.txt if gedad1b==6 & hbr_frml!=., ///
  append c(N an_boy) sum lines(none) f(1) lay(row)

****************************************
*Adolescentes
*nacional
svy: tabulate gedad1b an_boy, subpop(if gedad1>=7 & gedad1b<9 & hbr_frml!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b an_boy, subpop(if gedad1>=7 & gedad1b<9 & hbr_frml!=.) ///
  obs count format(%17.4f) cellwidth(15)
*por sexo y pcr
tabout idefpcr genero gedad1b using 8.20b.txt if gedad1b>=7 & gedad1b<9 ///
  & hbr_frml!=.,replace c(mean an_boy ci)sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.20b.txt if gedad1b>=7 & gedad1b<9 ///
  & hbr_frml!=.,append c(N an_boy) sum lines(none) f(1) lay(row)

*****************************************
*Adolescentes de sexo femenino
*Anemia adolescentes de sexo femenino por quintil econ / grupo etnico
tabout quint gr_etn gedad1b using 8.25.txt if gedad1b>=7 & gedad1b<9 ///
  & genero==2 & hbr_frml!=., replace c(mean an_boy ci ) ///
  sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.25.txt if gedad1b>=7 & gedad1b<9 ///
  & genero==2 & hbr_frml!=., append c(N an_boy ) sum lines(none) f(1) lay(row)

*Anemia MEF por subregion y zonas de planificacion
tabout subreg zonas_pl gedad1b using 8.26.txt if gedad1b>=7 & gedad1b<9 ///
  & genero==2 & hbr_frml!=., replace c(mean an_boy ci ) ///
  sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.26.txt if gedad1b>=7 & gedad1b<9 ///
  & genero==2 & hbr_frml!=., append c(N an_boy ) sum lines(none) f(1) lay(row)

****************************************
*Adultos
*Nacional
svy: tabulate gedad4 an_boy, subpop (if hbr_frml!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad4 an_boy, subpop (if hbr_frml!=.) ///
  obs count format(%17.4f) cellwidth(15)
*Sexo y pcr
tabout  gedad4 idefpcr using 8.28.txt if gedad4!=. & hbr_frml!=.,replace ///
  c(mean an_boy ci)sum svy lines(none) f(3 3) lay(cb)
tabout  gedad4 idefpcr using 8.28.txt if hbr_frml!=., ///
  append c(N an_boy) sum lines(none) f(1) lay(row)
*nacional
estpost svy: tabulate gedad5 an_boy, subpop (if hbr_frml!=.) ///
  row ci format(%17.4f) cellwidth(15)

*por sexo y pcr
tabout idefpcr gedad5 using 8.28b.txt if hbr_frml!=. & gedad5!=., ///
  replace c(mean an_boy ci)sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad5 using 8.28b.txt if hbr_frml!=., ///
  append c(N an_boy) sum lines(none) f(1) lay(row)

*Sexo y pcr
*Anemia adultas mujeres por quintil econ / grupo etnico
tabout quint gr_etn gedad4 using 8.29.txt if gedad4>3 & gedad4<7 ///
  & hbr_frml!=., replace c(mean an_boy ci ) ///
  sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad4 using 8.29.txt if gedad4>3 & gedad4<7 ///
  & hbr_frml!=., append c(N an_boy ) sum lines(none) f(1) lay(row)

*Anemia adultas mujeres por subregion y zonas de planificacion
tabout subreg zonas_pl gedad4 using 8.30.txt if gedad4>3 & ///
  gedad4<7 & hbr_frml!=., replace c(mean an_boy ci ) ///
 sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad4 using 8.30.txt if gedad4>3 & ///
  gedad4<7 & hbr_frml!=., append c(N an_boy ) sum lines(none) f(1) lay(row)

****************************************
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
replace idefvcm=. if embrz==1

*8.26 VCM Estadisticas descriptivas
tabout genero gedad1b using 8.35.txt , replace ///
 c(mean vcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad1b using 8.35.txt if genero==1, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)
tabout gedad1b using 8.35.txt if genero==2, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)

 ** totales descriptivas
tabout genero gedad2 using 8.35b.txt , replace ///
 c(mean vcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad2 using 8.35b.txt if genero==1, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)
tabout gedad2 using 8.35b.txt if genero==2, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)

** Estadísticas descriptivas con totales para menores de 5 años, escolares,
*adolescentes y adultos
tabout genero gedad3 using 8.35c.txt , replace ///
 c(mean vcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad3 using 8.35c.txt if genero==1, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)
tabout gedad3 using 8.35c.txt if genero==2, append ///
 c(count vcm median vcm sd vcm p5 vcm p95 vcm) ///
 sum lines(none) f(1) lay(row)

*8.25.26b MEF
*svy: mean vcm, subpop(if genero==2) over (gedad1)
*estpost tabstat vcm if genero==2, ///
*  by(gedad1) statistics(count median max min) columns(statistics)

****************************************
*Menores de 5 años

*Nacional
svy: tabulate gedad1b idefvcm, subpop (if gedad1b<6 & idefvcm!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefvcm, subpop (if gedad1b<6 & idefvcm!=.) ///
  obs count format(%17.4f) cellwidth(15)

*VCM en menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero gedad1b using 8.36.txt if gedad1b<6, ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.36.txt if gedad1b<6, ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)

*VCM en mayores de 5 años grupos de edad, por PCR y genero
*tabout idefpcr genero gedad1b using 8.28.txt if gedad1b>=6, ///
 * replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
*tabout idefpcr genero gedad1b using 8.28.txt if gedad1b>=6, ///
 *append c(N idefvcm ) sum lines(none) f(1) lay(row)

 *VCM en menores de 5 años grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.37.txt if gedad1b<6, ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.37.txt if gedad1b<6, ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)


 *VCM en menores de 5 años grupos de edad, por subregion y zonas de plan
tabout subreg zonas_pl gedad1b using 8.38.txt if gedad1b<6, ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.38.txt if gedad1b<6, ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)

*8.28b VCM en MEF por grupos de edad, por PCR y genero
*tabout idefpcr gedad1b using 8.28b.txt if gedad1b>6 & ///
 * gedad1b<12 & genero==2, replace c(mean idefvcm ci ) ///
 *sum svy lines(none) f(3 3) lay(row)
*tabout idefpcr gedad1b using 8.28b.txt if gedad1b>6 & ///
 * gedad1b<12 & genero==2 ,append c(N idefvcm ) ///
 *sum lines(none) f(1) lay(row)


****************************************
*Escolares

*Nacional
svy: tabulate gedad1b idefvcm, subpop (if gedad1b==6 & idefvcm!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefvcm, subpop (if gedad1b==6 & idefvcm!=.) ///
  obs count format(%17.4f) cellwidth(15)

*PCR y genero
tabout idefpcr genero gedad1b using 8.40.txt if gedad1b==6 & idefvcm!=., ///
 replace c(mean idefvcm ci) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.40.txt if gedad1b==6 & idefvcm!=., ///
 append c(N idefvcm) sum lines(none) f(1) lay(row)

****************************************
*Adolescentes
*nacional
svy: tabulate gedad1b idefvcm, subpop (if gedad1b>=7 & gedad1b<9 ) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefvcm, subpop (if gedad1b>=7 & gedad1b<9 ) ///
  obs count format(%17.4f) cellwidth(15)

*PCR y genero
tabout idefpcr genero gedad1b using 8.40b.txt if gedad1b>=7 & gedad1b<9 & ///
  idefvcm!=., replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.40b.txt if gedad1b>=7 & gedad1b<9 & ///
  idefvcm!=., append c(N idefvcm ) sum lines(none) f(1) lay(row)

*VCM en escolares y adolescentes por grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.41.txt if gedad1b>=6 & gedad1b<9 , ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.41.txt if gedad1b>=6 & gedad1b<9 , ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)


*VCM en escolares y adolescentes por grupos de edad, por subregion y
*zonas de planificacion
tabout subreg zonas_pl gedad1b using 8.42.txt if gedad1b>=6 & gedad1b<9, ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.42.txt if gedad1b>=6 & gedad1b<9, ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)

****************************************
*Adultos
*Nacional
svy: tabulate gedad4 idefvcm, row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad4 idefvcm, obs count format(%17.4f) cellwidth(15)

*PCR y genero
tabout idefpcr gedad4 using 8.44.txt if gedad4!=., ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad4 using 8.44.txt , ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)
*MEF
*Nacional
svy: tabulate gedad5 idefvcm, row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad5 idefvcm, obs count format(%17.4f) cellwidth(15)
*PCR y genero
tabout idefpcr gedad5 using 8.44a.txt if gedad5!=., ///
 replace c(mean idefvcm ci ) sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad5 using 8.44a.txt , ///
 append c(N idefvcm ) sum lines(none) f(1) lay(row)

********************************************************************************
*Ferritina
replace ferritin=. if ferritin>900 & gedad1==1
replace ferritin=. if ferritin>1200 & gedad1==3 & genero==2
*ferritina
gen idefferr=1 if (ferritin!=. & ferritin<12 & (gedad1>=1 & gedad1<=5))
replace idefferr=0 if (ferritin!=. & ferritin>=12 & (gedad1>=1 & gedad1<=5))
replace idefferr=1 if (ferritin!=. & ferritin<15 & gedad1>=6 & gedad1<13)
replace idefferr=0 if (ferritin!=. & ferritin>=15 & gedad1>=6 & gedad1<13)

gen ferritin_log=.
replace ferritin_log=ferritin
replace ferritin_log=ln(ferritin)

*8.35 Ferritina: Estadisticas descriptivas
tabout genero gedad1 using 8.51.txt , replace ///
  c(mean ferritin_log ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad1 using 8.51.txt if genero==1, append ///
  c(count ferritin_log median ferritin_log sd ferritin_log p5 ///
  ferritin_log p95 ferritin_log) sum lines(none) f(1) lay(row)
tabout gedad1 using 8.51.txt if genero==2, append ///
  c(count ferritin_log median ferritin_log sd ferritin_log p5 ///
  ferritin_log p95 ferritin_log) sum lines(none) f(1) lay(row)

*Totales descriptivas
tabout genero gedad3 using 8.51b.txt , replace ///
  c(mean ferritin_log ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad3 using 8.51b.txt if genero==1, append c(count ferritin_log ///
  median ferritin_log sd ferritin_log p5 ferritin_log ///
  p95 ferritin_log) sum lines(none) f(1) lay(row)
tabout gedad3 using 8.51b.txt if genero==2, append c(count ferritin_log ///
  median ferritin_log sd ferritin_log p5 ferritin_log p95 ferritin_log) ///
  sum lines(none) f(1) lay(row)

****************************************
*Menores de 5 años
*Nacional
svy: tabulate gedad1b idefferr, subpop (if gedad1b<6 & idefferr!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefferr, subpop (if gedad1b<6 & idefferr!=.) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia de Ferritina en menores de 5 años grupos de edad,
*por PCR y genero
tabout idefpcr genero gedad1b using 8.52.txt if gedad1b<6, ///
 replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.52.txt if gedad1b<6, ///
 append c(N idefferr ) sum lines(none) f(1) lay(row)

*Deficiencia de Ferritina en menores de 5 años
*grupos de edad, por Quintil y grupo etnico
tabout quint gr_etn gedad1b using 8.53.txt if gedad1b<6, ///
 replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.53.txt if gedad1b<6, ///
 append c(N idefferr ) sum lines(none) f(1) lay(row)

 *Deficiencia de Ferritina en menores de 5 años
*grupos de edad, por subregion y zonas de plan
tabout subreg zonas_pl gedad1b using 8.54.txt if gedad1b<6, ///
 replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.54.txt if gedad1b<6, ///
 append c(N idefferr ) sum lines(none) f(1) lay(row)

****************************************
*Escolares
*Nacional
svy: tabulate gedad1b idefferr, subpop (if gedad1b==6 & idefferr!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefferr, subpop (if gedad1b==6 & idefferr!=.) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia de Ferritina grupos de edad,por PCR y genero
tabout idefpcr genero gedad1b using 8.56.txt if gedad1b==6, ///
 replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.56.txt if gedad1b==6, ///
 append c(N idefferr ) sum lines(none) f(1) lay(row)


****************************************
*Adolescentes
*Nacional
svy: tabulate gedad1b idefferr, subpop (if gedad1b>=7 & gedad1b<9 ///
  & idefferr!=.)row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefferr, subpop (if gedad1b>=7 & gedad1b<9 ///
  & idefferr!=.)obs count format(%17.4f) cellwidth(15)
*Deficiencia de Ferritina en menores de 5 años grupos de edad
*por PCR y genero
tabout idefpcr genero gedad1b using 8.56.txt if gedad1b>=7 & gedad1b<9, ///
 replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.56.txt if gedad1b>=7 & gedad1b<9, ///
 append c(N idefferr ) sum lines(none) f(1) lay(row)


*Adolescentes de sexo femenina
*Anemia adolescentes de sexo femenino por quintil econ / grupo etnico
tabout quint gr_etn gedad1b using 8.57.txt if gedad1b>=7 & gedad1b<9 & ///
  genero==2, replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1b using 8.57.txt if gedad1b>=7 & gedad1b<9 & ///
  genero==2, append c(N idefferr ) sum lines(none) f(1) lay(row)

*Anemia MEF por subregion y zonas de planificacion
tabout subreg zonas_pl gedad1b using 8.58.txt if gedad1b>=7 & gedad1b<9 & ///
  genero==2, replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1b using 8.58.txt if gedad1b>=7 & gedad1b<9 & ///
  genero==2, append c(N idefferr ) sum lines(none) f(1) lay(row)

****************************************
*Adultos
*nacional
svy: tabulate gedad4 idefferr, subpop (if idefferr!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad4 idefferr, subpop (if idefferr!=.) ///
  obs count format(%17.4f) cellwidth(15)
*sexo y pcr
tabout idefpcr gedad4 using 8.60.txt if idefferr!=. & gedad4!=., ///
  replace c(mean idefferr ci)sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad4 using 8.60.txt if idefferr!=., ///
  append c(N idefferr) sum lines(none) f(1) lay(row)

****************************************
*Totales nacionales
*nacional
svy: tabulate gedad5 idefferr, subpop (if idefferr!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad5 idefferr, subpop (if idefferr!=.) ///
  obs count format(%17.4f) cellwidth(15)
*MEF  y pcr
tabout idefpcr gedad5 using 8.60b.txt if idefferr!=. & gedad5!=., ///
  replace c(mean idefferr ci)sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad5 using 8.60b.txt if idefferr!=., ///
  append c(N idefferr) sum lines(none) f(1) lay(row)

*Anemia adultas mujeres (20 a 49) por quintil econ / grupo etnico
tabout quint gr_etn gedad4 using 8.60c.txt if gedad4>3 & gedad4<7, ///
  replace c(mean idefferr ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad4 using 8.60c.txt if gedad4>3 & gedad4<7, ///
  append c(N idefferr ) sum lines(none) f(1) lay(row)

*Anemia adultas muejres por subregion y zonas de planificacion
tabout subreg zonas_pl gedad4 using 8.60d.txt if gedad4>3 & gedad4<7, ///
  replace c(mean idefferr ci ) ///
 sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad4 using 8.60d.txt if gedad4>3 & gedad4<7, ///
  append c(N idefferr ) sum lines(none) f(1) lay(row)

********************************************************************************
*Estimacion de Anemia con Deficit de Hierro y Otros Indicadores
gen tipoanemia=.
replace tipoanemia=0 if gedad1<6 & hbr_frml>=11
replace tipoanemia=1 if gedad1<6 & hbr_frml>=10 & hbr_frml<11
replace tipoanemia=2 if gedad1<6 & hbr_frml>=7 & hbr_frml<10
replace tipoanemia=3 if gedad1<6 & hbr_frml<7
lab def tipoanemia 1 "leve" 2 "moderada" 3 "severa"
lab val tipoanemia tipoanemia

**Iron defficiency
gen ideficiency=1 if (idefvcm==1 & idefferr==1)
replace ideficiency=1 if (idefvcm==1 & idefferr==0)
replace ideficiency=1 if (idefvcm==0 & idefferr==1)
replace ideficiency=2 if (idefvcm==0 & idefferr==0)
lab def ideficiency 1 "Deficiencia" 2 "Sin deficiencia"
lab val ideficiency ideficiency

*Clase de anemia:
gen clasanem=1 if an_boy==0 & idefferr==0
replace clasanem=2 if an_boy==1 & idefferr==1
replace clasanem=3 if an_boy==1 & idefferr==0
replace clasanem=4 if an_boy==0 & idefferr==1
lab def clasanem 1 "Sin anemia sin deficiencia de hierro" ///
  2 "Con Anemia con deficiencia de hierro " ///
  3 "Con Anemia sin deficiencia de hierro" ///
  4 "Sin anemia con deficiencia de hierro",replace
lab val clasanem clasanem

****************************************
*Prevalencia de anemia / severidad <5 a por grupo de edad
log using 8.42, replace
svy: tabulate gedad1b tipoanemia , subpop(if gedad1b<6 & hbr_frml!=.) ///
 obs row ci format(%17.4f) cellwidth(15) vert
svy: tabulate gedad1b an_boy , subpop(if gedad1b<6 & hbr_frml!=.) ///
 obs row ci format(%17.4f) cellwidth(15) vert
log close
translate 8.42 8.42.txt, replace linesize(255) translator(smcl2txt)

*Prevalencia de deficiencia de hierro, anemia por deficiencia de
*de hierro y anemia por otras causas en menores de cinco años
log using 8.67, replace
svy: tabulate gedad1 clasanem, subpop(if gedad1<6 & idefpcr==0) ///
 obs row ci format(%17.4f) cellwidth(15) vert
svy: tabulate genero clasanem, subpop(if gedad1<6 & idefpcr==0) ///
 obs row ci format(%17.4f) cellwidth(15) vert
log close
translate 8.67 8.67.txt, replace linesize(255) translator(smcl2txt)

*Prevalencia de deficiencia de hierro, anemia por deficiencia de
*de hierro y anemia por otras causas en adolescentes mujeres
log using 8.68, replace
svy: tabulate gedad1 clasanem, subpop(if gedad1>=7 & gedad1<9 ///
  & idefpcr==0 & genero==2) obs row ci format(%17.4f) cellwidth(15) vert
svy: tabulate genero clasanem, subpop(if gedad1>=7 & gedad1<9 ///
  & idefpcr==0 & genero==2) obs row ci format(%17.4f) cellwidth(15) vert
log close
translate 8.68 8.68.txt, replace linesize(255) translator(smcl2txt)


*Prevalencia de deficiencia de hierro, anemia por
*deficiencia de hierro y anemia por otras causas en mujeres 20 a 49 años
log using 8.69, replace
svy: tabulate gedad1 clasanem, subpop(if gedad1>=9 & gedad1<12 & ///
  idefpcr==0 & genero==2) obs row ci format(%17.4f) cellwidth(15) vert
svy: tabulate genero clasanem, subpop(if gedad1>=9 & gedad1<12 & ///
  idefpcr==0 & genero==2) obs row ci format(%17.4f) cellwidth(15) vert
log close
translate 8.69 8.69.txt, replace linesize(255) translator(smcl2txt)

** 50 a 59 mujeres
log using 8.70, replace
svy: tab gedad1 clasanem, subpop(if gedad1==12 & idefpcr==0 & genero==2) ///
  obs row ci format(%17.4f) cellwidth(15) vert
svy: tab genero clasanem, subpop(if gedad1==12 & idefpcr==0 & genero==2) ///
 obs row ci format(%17.4f) cellwidth(15) vert
log close
translate 8.70 8.70.txt, replace linesize(255) translator(smcl2txt)

********************************************************************************
*Zinc Sérico
gen gedad2=gedad1
replace gedad2=9 if gedad1>9 & genero==2 & gedad1<13
replace gedad2=. if gedad1>9 & genero==1
label define gedad2 1 "5 a 11 meses" 2 "12 a 23 meses" 3 "24 a 35 meses" ///
 4 "36 a 47 meses" 5 "48 a 59 meses" 6 "de 5 a 11 años" 7 "de 12 a 14 años" ///
 8 "de 15 a 19 años" 9 "MEF de 20 a 59 años sin emb.",replace
label value gedad2 gedad2

*Grupos Edad General
recode edadanio (0=1 "5 a 11 meses") (1=2 "12 a 23 meses") ///
  (2=3 "24 a 35 meses") (3=4 "36 a 47 meses") (4=5 "48 a 59 meses") ///
  (5/11=6 "de 5 a 11 años") (12/14=7 "de 12 a 14 años") ///
  (15/19=8 "de 15 a 19 años") (20/29=9 "mujeres de 20 a 29 años") ///
  (30/39=10 "mujeres de 30 a 39 años") (40/49=11 "mujeres 40 a 49 años") ///
  (nonmissing=.), gen (gedad3)
replace gedad3=. if (genero==1 & (gedad3==9|gedad3==10|gedad3==11))
lab var gedad3 "Grupos de edad generales"

*** Grupos de edad para Totales
recode edadanio (0/4=1 "menores de 5 años") (5/11=2 "escolares") ///
  (12/19=3 "adolescentes") (12/19=3 "adolescentes") (nonmissing=.), gen (gedad4)
replace gedad4=4 if (edadanio>=20 & edadanio<50 & genero==2)

lab def ged4 1 "< a 5 años" 2 "escolares" 3 "adolescentes" 4 "MEF", replace
label value gedad4 ged4

*MEF
recode edadanio (12/14=1 "12 a 14") (15/19=2 "15 a 19") (20/29=3 "20 a 29") ///
  (30/39=4 "30 a 39") (40/49=5 "40 a 49"), gen (gedad5)
lab var gedad5 "Grupos de edad mef"

*Deficiencia de zinc
gen zndef=1 if (zinc!=. & zinc<65 & edadanio<=9)
replace zndef=0 if (zinc!=. & zinc>=65 & edadanio<=9)
replace zndef=1 if (zinc!=. & zinc<70 & genero==2 & edadanio>9 & gedad1 <= 13)
replace zndef=0 if (zinc!=. & zinc>=70 & genero==2 & edadanio>9 & gedad1 <= 13)
replace zndef=1 if (zinc!=. & zinc<74 & genero==1 & edadanio>9 & gedad1 <= 8)
replace zndef=0 if (zinc!=. & zinc>=74 & genero==1 & edadanio>9 & gedad1 <= 8)

*Zinc: Estadisticas descriptivas
tabout genero gedad3 using 8.71.txt if zinc!=., ///
 replace c(mean zinc ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad3 using 8.71.txt if genero==1 & zinc!=., append ///
 c(count zinc median zinc sd zinc p5 zinc p95 zinc) ///
 sum lines(none) f(1) lay(row)
tabout gedad3 using 8.71.txt if genero==2 & zinc!=., append ///
 c(count zinc median zinc sd zinc p5 zinc p95 zinc) ///
 sum lines(none) f(1) lay(row)

*estadísticas descriptivas totales
tabout genero gedad4 using 8.71a.txt, ///
 replace c(mean zinc ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad4 using 8.71a.txt if genero==1, append ///
 c(count zinc median zinc sd zinc p5 zinc p95 zinc) ///
 sum lines(none) f(1) lay(row)
tabout gedad4 using 8.71a.txt if genero==2, append ///
 c(count zinc median zinc sd zinc p5 zinc p95 zinc) ///
 sum lines(none) f(1) lay(row)

*estadistica descriptiva MEF
tabout genero gedad5 using 8.71b.txt, ///
 replace c(mean zinc ci ) sum svy lines(none) f(3 3) lay(row)
tabout gedad5 using 8.71b.txt, append ///
 c(count zinc median zinc sd zinc p5 zinc p95 zinc) ///
 sum lines(none) f(1) lay(row)

*Menores de 5 años
*nacional
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3<6) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3<6) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia Zinc en menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero gedad3 using 8.72.txt if zndef!=. & gedad3<6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad3 using 8.72.txt if zndef!=. & gedad3<6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

*Deficiencia de Zinc en menores de 5 años grupos de edad,
*por Quintil y grupo etnico
tabout quint gr_etn gedad3 using 8.73.txt if gedad3<6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad3 using 8.73.txt if gedad3<6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

*Deficiencia de Zinc en menores de 5 años grupos de edad,
*por subregion y zonas de plan
tabout subreg zonas_pl gedad3 using 8.74.txt if gedad3<6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad3 using 8.74.txt if gedad3<6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

****************************************
*Escolares
*nacional
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3==6) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3==6) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia Zinc en menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero gedad3 using 8.76.txt if zndef!=. & gedad3==6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad3 using 8.76.txt if zndef!=. & gedad3==6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

****************************************
*Adolescentes
*nacional
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3>6 & gedad3<9) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad3 zndef, subpop (if zndef!=. & gedad3>6 & gedad3<9) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia Zinc en menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero gedad3 using 8.76a.txt if zndef!=. & gedad3>6 ///
  & gedad3<9, replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad3 using 8.76a.txt if zndef!=. & gedad3>6 ///
  & gedad3<9, append c(N zndef ) sum lines(none) f(1) lay(row)

*Deficiencia de Zinc en escolares y adolescentes por Quintil y grupo etnico
tabout quint gr_etn gedad3 using 8.77.txt if gedad3==6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad3 using 8.77.txt if gedad3==6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

 tabout quint gr_etn gedad3 using 8.77a.txt if gedad3>6 & gedad3<9, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad3 using 8.77a.txt if gedad3>6 & gedad3<9, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

*Deficiencia de Zinc en escolares y adolescentes,
*por subregion y zonas de plan
tabout subreg zonas_pl gedad3 using 8.78.txt if gedad3==6, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad3 using 8.78.txt if gedad3==6, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

tabout subreg zonas_pl gedad3 using 8.78a.txt if gedad3>6 & gedad3<9, ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad3 using 8.78a.txt if gedad3>6 & gedad3<9, ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

****************************************
*MEF
*nacional
svy: tabulate gedad5 zndef, subpop (if zndef!=.) row ci format(%17.4f) cellw(15)
svy: tabulate gedad5 zndef, subpop (if zndef!=.) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia de Zinc MEF por PCR y genero
tabout idefpcr gedad5 using 8.80.txt if gedad5!=. & zndef!=., ///
  replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr gedad5 using 8.80.txt if zndef!=., ///
  append c(N zndef ) sum lines(none) f(1) lay(cb)
tabout quint gr_etn gedad5 using 8.81.txt if gedad5!=. & zndef!=., ///
  replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(cb)
tabout quint gr_etn gedad5 using 8.81.txt, ///
  append c(N zndef ) sum lines(none) f(1) lay(cb)
gen gedad6=(gedad5==2)
tabout subreg zonas_pl gedad6 using 8.82.txt if (gedad6!=.), ///
 replace c(mean zndef ci ) sum svy lines(none) f(3 3) lay(cb)
tabout subreg zonas_pl gedad6 using 8.82.txt if (gedad6!=.), ///
 append c(N zndef ) sum lines(none) f(1) lay(row)

********************************************************************************
*Vitamina A
gen vitadl= vita*100
gen idefvita=1 if (vitadl!=. & vitadl<20 & (gedad1>=1 & gedad1<=13))
replace idefvita=0 if (vitadl!=. & vitadl>=20 & (gedad1>=1 & gedad1<=13))

*VitA: Estadisticas descriptivas < 5 anos
tabout genero gedad1 using 8.87.txt if gedad1<6 & vitadl!=. , ///
  replace c(mean vitadl ci) ///
 sum svy lines(none) f(3 3) lay(row)
tabout gedad1b using 8.87.txt if genero==1 & gedad1<6 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)
tabout gedad1 using 8.87.txt if genero==2 & gedad1<6 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)

 *Estadísticas descriptivas 5 a 9 años
tabout genero gedad1 using 8.87a.txt if gedad1==6 & vitadl!=. , ///
  replace c(mean vitadl ci) ///
 sum svy lines(none) f(3 3) lay(row)
tabout gedad1b using 8.87a.txt if genero==1 & gedad1==6 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)
tabout gedad1 using 8.87a.txt if genero==2 & gedad1==6 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)

*MEF
svy: mean vita, subpop(if genero==2) over (gedad1)
estpost tabstat vita if genero==2, by(gedad1) ///
  statistics(count median max min) columns(statistics)

****************************************
*Menores 5 años
*nacional
svy: tabulate gedad1b idefvita, subpop (if vitadl!=. & gedad1b<6) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1b idefvita, subpop (if vitadl!=. & gedad1b<6) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia Vit.A en menores de 5 años grupos de edad, por PCR y genero
tabout idefpcr genero gedad1b using 8.88.txt if gedad1b<6, ///
 replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero gedad1b using 8.88.txt if gedad1b<6, ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

*Deficiencia de Vit.A en menores de 5 años grupos de edad,
*por Quintil y grupo etnico
tabout quint gr_etn gedad1 using 8.89.txt if gedad1b<6, ///
 replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(row)
tabout quint gr_etn gedad1 using 8.89.txt if gedad1b<6, ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

*Deficiencia de Vit.A en menores de 5 años grupos de edad,
*por subregion y zonas de plan
tabout subreg zonas_pl gedad1 using 8.90.txt if gedad1b<6, ///
 replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(row)
tabout subreg zonas_pl gedad1 using 8.90.txt if gedad1b<6, ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

****************************************
*Estadísticas descriptivas 5 a 9 años
tabout genero gedadvita using 8.91a.txt if vitadl!=. & gedadvita!=., ///
  replace c(mean vitadl ci) sum svy lines(none) f(3 3) lay(cb)
tabout gedadvita using 8.91a.txt if genero==1 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)
tabout gedadvita using 8.91a.txt if genero==2 & vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)
tabout gedadvita using 8.91a.txt if  vitadl!=., append ///
 c(count vitadl median vitadl sd vitadl p5 vitadl p95 vitadl) ///
 sum lines(none) f(1) lay(row)

*nacional
svy: tabulate gedadvita idefvita, subpop (if vitadl!=.) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedadvita idefvita, subpop (if vitadl!=.) ///
  obs count format(%17.4f) cellwidth(15)

*Deficiencia de Vit.A en de 5 a 9 años grupos de edad, por PCR y genero
tabout idefpcr genero gedadvita using 8.92b.txt if(edadanio>4 & edadanio<10), ///
  replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(cb)
tabout idefpcr genero gedadvita using 8.92b.txt if(edadanio>4 & edadanio<10), ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

*Deficiencia de Vit.A en 5-9 años genero,
*por Quintil y grupo etnico
tabout quint gr_etn gedadvita using 8.93.txt if(gedadvita!=.), ///
  replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(cb)
tabout quint gr_etn gedadvita using 8.93.txt  if(gedadvita!=.), ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

*Deficiencia de Vit.A poblacion de 5 a 9 años genero,
*por subregion y zonas de plan
tabout subreg zonas_pl gedadvita using 8.94.txt if(gedadvita!=.), ///
 replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(cb)
tabout subreg zonas_pl gedadvita using 8.94.txt, ///
 append c(N idefvita) sum lines(none) f(1) lay(row)

*MEF
*Deficiencia de Vit.A en de 5 a 9 años grupos de edad, por PCR y genero
tabout idefpcr genero using 8.94b.txt if(gedad5==2), ///
  replace c(mean idefvita ci ) sum svy lines(none) f(3 3) lay(row)
tabout idefpcr genero using 8.94b.txt if(gedad5==2), ///
 append c(N idefvita ) sum lines(none) f(1) lay(row)

********************************************************************************
*Acido Folico Serico
gen ideffolser=1 if (fols!=. & fols<4 & (gedad1>=1 & gedad1<=12))
replace ideffolser=0 if (fols!=. & fols>=4 & (gedad1>=1 & gedad1<=12))
gen ideffoleri=1 if (foler!=. & foler<151 & (gedad1>=1 & gedad1<=12))
replace ideffoleri=0 if (foler!=. & foler>=151 & (gedad1>=1 & gedad1<=12))

*8.66b MEF Descriptivas fols
*Fols
svy: mean fols, subpop(if gedad1>=6 & genero==1) over (gedad1)
estpost tabstat fols if gedad1>=6 & genero==1, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)
svy: mean fols, subpop(if gedad1>=6 & genero==2) over (gedad1)
estpost tabstat fols if gedad1>=6 & genero==2, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)

*Descriptivas con totales
svy: mean fols, subpop(if genero==1) over (gedad2)
estpost tabstat fols if genero==1, ///
  by(gedad2) statistics(count median sd p5 p95) columns(statistics)
svy: mean fols, subpop(if genero==2) over (gedad2)
estpost tabstat fols if genero==2, ///
  by(gedad2) statistics(count median sd p5 p95) columns(statistics)

*Deficiencia en menores de 5
*nacional
svy: tabulate gedad1 ideffolser, ///
  subpop (if ideffolser!=. & gedad1<6)row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 ideffolser, ///
  subpop (if ideffolser!=. & gedad1<6)obs count format(%17.4f) cellwidth(15)

*Deficiencia en mayores de 5
svy: tabulate gedad1 ideffolser, ///
  subpop (if ideffolser!=. & gedad1>=6)row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 ideffolser, ///
  subpop (if ideffolser!=. & gedad1>=6)obs count format(%17.4f) cellwidth(15)

*Deficiencia en MEF
svy: tabulate gedad5 ideffolser, ///
  subpop (if ideffolser!=.)row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad5 ideffolser, ///
  subpop (if ideffolser!=.)obs count format(%17.4f) cellwidth(15)

********************************************************************************
*Acido folico eritrocitario
*Estadísticas descriptivas
*Fols
svy: mean foler, subpop(if gedad1<6 & genero==1) over (gedad1)
estpost tabstat foler if gedad1<6 & genero==1, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)
svy: mean foler, subpop(if gedad1<6 & genero==2) over (gedad1)
estpost tabstat foler if gedad1<6 & genero==2, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)

svy: mean foler, subpop(if gedad1>=6 & genero==1) over (gedad1)
estpost tabstat foler if gedad1>=6 & genero==1, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)
svy: mean foler, subpop(if gedad1>=6 & genero==2) over (gedad1)
estpost tabstat foler if gedad1>=6 & genero==2, ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)

*Descriptivas con totales

svy: mean foler, subpop(if genero==1) over (gedad2)
estpost tabstat foler if genero==1, ///
  by(gedad2) statistics(count median sd p5 p95) columns(statistics)
svy: mean foler, subpop(if genero==2) over (gedad2)
estpost tabstat foler if genero==2, ///
  by(gedad2) statistics(count median sd p5 p95) columns(statistics)

*Deficiencia en menores de 5
*nacional
svy: tabulate gedad1 ideffoleri, ///
  subpop (if ideffoleri!=. & gedad1<6) row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 ideffoleri, ///
  subpop (if ideffoleri!=. & gedad1<6) obs count format(%17.4f) cellwidth(15)

*Deficiencia en mayores de 5
svy: tabulate gedad1 ideffoleri, ///
  subpop (if ideffoleri!=. & gedad1>=6) row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 ideffoleri, ///
  subpop (if ideffoleri!=. & gedad1>=6) obs count format(%17.4f) cellwidth(15)

*Deficiencia en MEF
svy: tabulate gedad5 ideffoleri, ///
  subpop (if ideffoleri!=.) row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad5 ideffoleri, ///
  subpop (if ideffoleri!=.) obs count format(%17.4f) cellwidth(15)

********************************************************************************
*Vitamina B12
replace vitb12=. if edadanio<10
gen vitb12def=1 if (vitb12!=. & vitb12<203 & (gedad1>=6))
replace vitb12def=0 if (vitb12!=. & vitb12>=203 &(gedad1>=6))

*descriptivas
svy: mean vitb12, subpop(if gedad1>=6 & genero==1 & vitb12!=.) over (gedad1)
estpost tabstat vitb12 if gedad1>=6 & genero==1 & vitb12!=., ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)
svy: mean vitb12, subpop(if gedad1>=6 & genero==2 & vitb12!=.) over (gedad1)
estpost tabstat vitb12 if gedad1>=6 & genero==2 & vitb12!=., ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)

*totales descriptivas
svy: mean vitb12, subpop(if genero==1 & vitb12!=.) over (gedad2)
estpost tabstat vitb12 if genero==1 & vitb12!=., ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)
svy: mean vitb12, subpop(if genero==2 & vitb12!=.) over (gedad2)
estpost tabstat vitb12 if genero==2 & vitb12!=., ///
  by(gedad1) statistics(count median sd p5 p95) columns(statistics)

*Deficiencia en mayores de 5
svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & gedad1>=6) ///
  row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & gedad1>=6) ///
  obs count format(%17.4f) cellwidth(15)
svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & ///
  gedad1>=6 & genero==1) row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & ///
  gedad1>=6 & genero==1) obs count format(%17.4f) cellwidth(15)

svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & ///
  gedad1>=6 & genero==2) row ci format(%17.4f) cellwidth(15)
svy: tabulate gedad1 vitb12def, subpop (if vitb12def!=. & ///
  gedad1>=6 & genero==2) obs count format(%17.4f) cellwidth(15)

*Prev val anom ac fol ser nac 10-14 15-19 20-39 40-59 por genero
*Est. decr. Yodo Escolares m20-49a

****************************************
*Yodo
*Grupos de edad yodo
gen gedadyodo=.
replace gedadyodo=1 if (edadanio>=6 & edadanio<10)
replace gedadyodo=2 if (edadanio>=10 & edadanio<13)
label define gedadyodo 1"escolares de 6 a 9" 2"escolares de 10 a 12", replace
label value gedadyodo gedadyodo

*Grupos de edad yoodo mef
*MEF
gen gedadyodo1=.
replace gedadyodo1=1 if (edadanio>=20 & edadanio<30 & genero==2)
replace gedadyodo1=2 if (edadanio>=30 & edadanio<40 & genero==2)
replace gedadyodo1=3 if (edadanio>=40 & edadanio<50 & genero==2)
label define gedad5 1 "20 a 29" 2 "30 a 39" 3 "40 a 49", replace
label value gedadyodo1 gedadyodo1

*edad total
gen gedadyodot=.
replace gedadyodot=1 if (edadanio>=6 & edadanio<13 & genero==1)
replace gedadyodot=2 if (edadanio>=6 & edadanio<13 & genero==2)
replace gedadyodot=3 if (genero==2 & edadanio>=20 & edadanio<50)

*edad total (sin sexo en escolares)
*gen gedadyodot=.
*replace gedadyodot=1 if (edadanio>=6 & edadanio<13)
*replace gedadyodot=2 if (genero==2 & edadanio>=20 & edadanio<50)


****************
replace yodo=. if edadanio<6
gen yodo1=1 if (yodo!=. & yodo<100 & (gedad1>=6))
replace yodo1=0 if (yodo!=. & yodo>=100 &(gedad1>=6))
replace yodo1=2 if (yodo!=. & yodo>=200 & yodo<300 & (gedad1>=6))
replace yodo1=3 if (yodo!=. & yodo>=300 & gedad1>=6)
lab def yodo1 0 "normal" 1 "deficiencia" 2 "sobre los requerimientos" ///
 3 "excesivo" 5,replace
lab val yodo1 yodo1

*Descriptivas en escolares de 6 a 12 años
*descriptivas escolares
svy: mean yodo, subpop(if genero==1 & yodo!=.) over (gedadyodo)
estpost tabstat yodo if genero==1 & yodo!=., ///
  by(gedadyodo) statistics(count median sd p5 p95) columns(statistics)
svy: mean yodo, subpop(if genero==2 & yodo!=.) over (gedadyodo)
estpost tabstat yodo if genero==2 & yodo!=., ///
  by(gedadyodo) statistics(count median sd p5 p95) columns(statistics)

*total descriptivas
* descriptivas MEF
svy: mean yodo, subpop(if yodo!=.) over (gedadyodo1)
estpost tabstat yodo if yodo!=., ///
  by(gedadyodo1) statistics(count median sd p5 p95) columns(statistics)

*Totales
svy: mean yodo, subpop(if yodo!=.) over (gedadyodot)
estpost tabstat yodo if yodo!=., ///
  by(gedadyodot) statistics(count median sd p5 p95) columns(statistics)

*Mediana y media de yodo escolares hombres y mujeres para gráfico
estpost tabstat yodo if yodo!=., ///
  by(gedadyodo) statistics(count median sd p5 p95) columns(statistics)
svy: mean yodo if yodo!=. & edadanio>=6 & edadanio<13

*Subregión
*escolares
svy: mean yodo, subpop(if yodo!=. & gedadyodot==1) over(subreg)
estpost tabstat yodo if yodo!=. & gedadyodot==1, ///
  by(subreg) statistics(count median sd p5 p95) columns(statistics)
*MEF
svy: mean yodo, subpop(if yodo!=. & gedadyodot==2) over(subreg)
estpost tabstat yodo if yodo!=. & gedadyodot==2, ///
  by(subreg) statistics(count median sd p5 p95) columns(statistics)

*Zonas de planificación
*escolares
svy: mean yodo, subpop(if yodo!=. & gedadyodot==1) over(zonas_planificacion)
estpost tabstat yodo if yodo!=. & gedadyodot==1, ///
  by(zonas_planificacion) statistics(count median sd p5 p95) columns(statistics)
*MEF
svy: mean yodo, subpop(if yodo!=. & gedadyodot==2) over(zonas_planificacion)
estpost tabstat yodo if yodo!=. & gedadyodot==2, ///
  by(zonas_planificacion) statistics(count median sd p5 p95) columns(statistics)

*Etnia
*escolares
svy: mean yodo, subpop(if yodo!=. & gedadyodot==1) over(gr_etn)
estpost tabstat yodo if yodo!=. & gedadyodot==1, ///
  by(gr_etn) statistics(count median sd p5 p95) columns(statistics)
*MEF
svy: mean yodo, subpop(if yodo!=. & gedadyodot==2) over(gr_etn)
estpost tabstat yodo if yodo!=. & gedadyodot==2, ///
  by(gr_etn) statistics(count median sd p5 p95) columns(statistics)

*Quintil económico
*Escolares
svy: mean yodo, subpop(if yodo!=. & gedadyodot==1) over(quint)
estpost tabstat yodo if yodo!=. & gedadyodot==1, ///
  by(quint) statistics(count median sd p5 p95) columns(statistics)
*MEF
svy: mean yodo, subpop(if yodo!=. & gedadyodot==2) over(quint)
estpost tabstat yodo if yodo!=. & gedadyodot==2, ///
  by(quint) statistics(count median sd p5 p95) columns(statistics)

****************************************
*Yodo
*grupos de edad: escolares 1, madres en edad fertil 2.
*Nacional
graph bar (median) yodo [pweight = pw], over(gedad1) blabel(bar)
*subregión
*Escolares
graph bar (median) yodo [pweight = pw] if gedad1>=6 & gedad1<8, ///
  over(subreg) blabel(bar)
*Mujeres en edad reproductiva
graph bar (median) yodo [pweight = pw] if gedad5>=3, over(subreg) blabel(bar)

*Zona
*Escolares
graph bar (median) yodo [pweight = pw] if gedad1>=6 & gedad1<8, ///
  over(zonas_pl) blabel(bar)
*Mujeres en edad reproductiva
graph bar (median) yodo [pweight = pw] if gedad5>=3, over(zonas_pl) blabel(bar)

*Condicion
*escolares
graph bar (median) yodo [pweight = pw] if gedad1>=6 & gedad1<8, ///
  over(quint) blabel(bar)
*Mujeres en edad reproductiva
graph bar (median) yodo [pweight = pw] if gedad5>=3, over(quint) blabel(bar)

*Etnia
*Escolares
graph bar (median) yodo [pweight = pw] if gedad1>=6 & gedad1<8, ///
  over(grupo_et) blabel(bar)

*Mujeres en edad reproductiva
graph bar (median) yodo [pweight = pw] if gedad5>=3, over(grupo_et) blabel(bar)

****************************************
*Numero de individuos n N: Individuos por variables y grupos de edad
*grupos de analisis 6mo-<6a/6-<10a/10<20a/20<60añosMnoemb&H
gen gan=.
replace gan=1 if (edadmes>=6 & edadanio<6 )
replace gan=2 if (edadanio>=6 & edadanio<10)
replace gan=3 if (edadanio>=10 & edadanio<20)
replace gan=4 if (edadanio>=20 & edadanio<60 & embrz!=1)
lab def gan 1 "6mo-<6a" 2 "6-<10a" 3 "10<20a" 4 "20<60añosMnoemb&H"
lab val gan gan
lab var gan "Grupo de analisis"
*Gr. especificos de analisis "1_6<12a" "2_M20<49a" "3_M20_49a+Emb" "4_HM20<60a"
gen gasp=.
replace gasp=1 if (edadanio>=6 & edadanio<12)
replace gasp=3 if (edadanio>=20 & edadanio<49 & pd02==2)
lab def gasp 1 "6<12a" 2 "M20<49a" 3 "M20_49a+Emb" 4 "HM20<60a"
lab val gasp gasp
lab var gasp "Grupo especifico de analisis"
gen n=1
svyset idsector [pweight=pw], strata (area)
svy: tab gedad1 n, obs count format(%17.4f) cellwidth(15)
*Biometría hemática VCM Ferritina PCR Fol Foler
foreach x of varlist vcm fols foler pcr ferritin hct wbc hb ///
  linfo mono neutro baso eos {
	svy: tab gan n, subpop( if `x'!=.) obs count format(%17.4f) cellwidth(15)
	}
*Biometría hemática Zinc
svy: tab gan n,subpop( if zinc!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if zinc!=. & pd02==2) ///
 obs count format(%17.4f) cellwidth(15)
*Vit A
svy: tab gan n,subpop( if vita!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if vita!=. & pd02==2) ///
 obs count format(%17.4f) cellwidth(15)
*Albumina
svy: tab gan n,subpop( if alb!=.) obs count format(%17.4f) cellwidth(15)
*Yodo
svy: tab gan n,subpop( if yodo!=.) obs count format(%17.4f) cellwidth(15)
svy: tab gan n,subpop( if yodo!=. & edadanio<12) ///
 obs count format(%17.4f) cellwidth(15)
svy: tab n,subpop( if yodo!=. & edadanio>=20 & edadanio<60) ///
  obs count format(%17.4f) cellwidth(15)
*Trig hdlc ldlc chol glucosa vit insulina
foreach x of varlist  trig hdlc ldlc chol glucosa vitb12 insulina {
	svy: tab gan n, subpop( if `x'!=.) obs count format(%17.4f) cellwidth(15)
	}

*Análisis de Bioquímica ensanut 2012 termina ahí********************************
