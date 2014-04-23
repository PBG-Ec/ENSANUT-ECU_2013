******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
*********************Tomo 1***************************************************
*********************Capítulo: Actividad Física*******************************
******************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2013: Wilma Freire.
Investigadores y autores del informe:
  Elaboración: Luis Gomez
  Pamela Piñeiros, Philippe Belmont Guerrón,
  MSP-ENSANUT philippebelmont@gmail.com
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
*****************************************************************************
*Preparación de base:
*Variables de identificadores & svyset
set more off
*Ingresar el directorio de las bases:
cd ""

******************************************************************************
*****************Actividad fisica : niños de 5 a 9 años***********************
******************************************************************************
*Preparación de base:
*Identificadores y factores de expansion
*Base :
use ensanut_f5_fact_riesgo_ninos.dta, clear


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
  gr_etn area pd02 pd03 escol edadanio quint pd08b)
drop if _merge==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

**Escolaridad de la madre
rename idpers idpersona
rename idmadre idpers
rename escol escolar
merge m:1 idpers using "ensanut_F1_personas.dta", keepusing(escol)
drop if _merge==2
drop _merge
rename escol escolmadre
rename idpers idmadre
rename idpersona idpers
rename escolar escol

*********************
*Tiempo de television
gen tiempo_TV_1=0 if f5401!=.

*Missing values de no responde
foreach v of varlist  f543lu1a-f543do2b   {
	replace `v'=0 if `v'==.
	replace `v'=0 if `v'==99
}

gen t_lunes_TV=(f543lu1a*60)+f543lu1b+(f543lu2a*60)+f543lu2b
gen dia_lunes_TV=1 if (t_lunes_TV!=0)
replace dia_lunes_TV=0 if (t_lunes_TV==0)

gen t_martes_TV=(f543ma1a*60)+f543ma1b+(f543ma2a*60)+f543ma2b
gen dia_martes_TV=1 if (t_martes_TV!=0)
replace dia_martes_TV=0 if (t_martes_TV==0)

gen t_miercoles_TV=(f543mi1a*60)+f543mi1b+(f543mi2a*60)+f543mi2b
gen dia_miercoles_TV=1 if (t_miercoles_TV!=0)
replace dia_miercoles_TV=0 if (t_miercoles_TV==0)

gen t_jueves_TV=(f543ju1a*60)+f543ju1b+(f543ju2a*60)+f543ju2b
gen dia_jueves_TV=1 if (t_jueves_TV!=0)
replace dia_jueves_TV=0 if (t_jueves_TV==0)
gen t_viernes_TV=(f543vi1a*60)+f543vi1b+(f543vi2a*60)+f543vi2b
gen dia_viernes_TV=1 if (t_viernes_TV!=0)
replace dia_viernes_TV=0 if (t_viernes_TV==0)

gen t_sabado_TV=(f543sa1a*60)+f543sa1b+(f543sa2a*60)+f543sa2b
gen dia_sabado_TV=1 if (t_sabado_TV!=0)
replace dia_sabado_TV=0 if (t_sabado_TV==0)
gen t_domingo_TV=(f543do1a*60)+f543do1b+(f543do2a*60)+f543do2b

gen dia_domingo_TV=1 if (t_domingo_TV!=0)
replace dia_domingo_TV=0 if (t_domingo_TV==0)

gen t_total_TV= t_lunes_TV+t_martes_TV + ///
  t_miercoles_TV+t_jueves_TV+t_viernes_TV+t_sabado_TV+t_domingo_TV
gen promedio_TV=(t_total_TV/7)

gen TV_ninos_5=1 if promedio_TV<60
replace TV_ninos_5=2 if promedio_TV>=60 & promedio_TV<120
replace TV_ninos_5=3 if promedio_TV>=120 & promedio_TV<240
replace TV_ninos_5=4 if promedio_TV>=240 & promedio_TV<480
replace TV_ninos_5=5 if promedio_TV>=480 & promedio_TV<721

gen TV_ninos_4=1 if promedio_TV<60
replace TV_ninos_4=2 if promedio_TV>=60 & promedio_TV<120
replace TV_ninos_4=3 if promedio_TV>=120 & promedio_TV<240
replace TV_ninos_4=4 if promedio_TV>=240 & promedio_TV<721

gen TV_ninos_3=1 if promedio_TV<60
replace TV_ninos_3=2 if promedio_TV>=60 & promedio_TV<120
replace TV_ninos_3=3 if promedio_TV>=120 & promedio_TV<721


gen TV_ninos_3_3=1 if promedio_TV<120
replace TV_ninos_3_3=2 if promedio_TV>=120 & promedio_TV<240
replace TV_ninos_3_3=3 if promedio_TV>=240 & promedio_TV<721

gen TV_ninos_2_horas_o_mas=0 if promedio_TV<120
replace TV_ninos_2_horas_o_mas=1 if promedio_TV>=120 & promedio_TV<721

*Escolaridad de la madre
 gen escolaridad_3_madre=1 if escolmadre>=0 & escolmadre<=7
  *primaria incompleta o analfabeto
 replace escolaridad_3_madre=2 if escolmadre>=8 & escolmadre<=13
 *secundaria incompleta o completa
 replace escolaridad_3_madre=3 if escolmadre>=14 & escolmadre<=20
 *Más de secundaria
lab var escolaridad_3_madre "Escolaridad de la Madre 3 categorias"
lab def escolaridad_3_madre 1 "Primaria incompleta o analfabeto" ///
  2 "Secundaria incompleta o completa" 3 "Más de secundaria"
lab val escolaridad_3_madre escolaridad_3_madre

*Cuadros de Prevalencia de tiempo dedicado a ver television y
*video juegos (3 categorias, 1=menos de 2 hora, 2= más de 2 horas y menos de 4,
*3= 4 horas o más)
global y TV_ninos_3_3
global z pd02 edadanio area escolaridad_3_madre ///
  gr_etn subreg quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==2) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==2) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}

******************************************************************************
*****************Actividad fisica : Adolescentes 10-19 años*******************
******************************************************************************
*Preparación de base:
use ensanut_f6_fact_riesgo_adolescentes.dta,clear

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
  keepusing( provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 escol edadanio quint pd08b)
drop if _merge==2
drop _merge

*Identificador de madre:
gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
drop idptemp
lab var idmadre "Identificador de madre"

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

**Escolaridad de la madre
rename idpers idpersona
rename idmadre idpers
rename escol escolar
merge m:1 idpers using "ensanut_f1_personas.dta", keepusing(escol)
drop if _merge==2
drop _merge
rename escol escolmadre
rename idpers idmadre
rename idpersona idpers
rename escolar escol

*Missing values de no responde
replace f6501b=. if f6501b==99
gen  dias_AF_adolescentes=f6501b
replace  dias_AF_adolescentes=0 if f6501a==2
gen cumplir_recom_AF= 1 if dias_AF_adolescentes==0
replace cumplir_recom_AF= 2 if (dias_AF_adolescentes>=1 & dias_AF_adolescentes<=4)
replace cumplir_recom_AF= 3 if (dias_AF_adolescentes>=5 & dias_AF_adolescentes<=7)

gen dias_EF_adolescentes=11 if f6502a==3
*1= no plica
replace dias_EF_adolescentes=0 if f6502a==2
replace dias_EF_adolescentes=1 if f6502b==1
replace dias_EF_adolescentes=2 if f6502b==2
replace dias_EF_adolescentes=3 if f6502b==3
replace dias_EF_adolescentes=4 if f6502b==4
replace dias_EF_adolescentes=5 if f6502b==5
replace dias_EF_adolescentes=6 if f6502b==6
replace dias_EF_adolescentes=7 if f6502b==7
*Dudas de "no aplica" y cero
gen dias_EF=0 if dias_EF_adolescentes==0
* ningún día dias_EF_adolescentes
replace dias_EF=1 if dias_EF_adolescentes==1
*1 día
replace dias_EF=2 if dias_EF_adolescentes==2
replace dias_EF=2 if dias_EF_adolescentes==3
replace dias_EF=2 if dias_EF_adolescentes==4
replace dias_EF=2 if dias_EF_adolescentes==5
replace dias_EF=2 if dias_EF_adolescentes==6
replace dias_EF=2 if dias_EF_adolescentes==7
* 2 o más días
* más de 2 días es solo el 1,29%

*Missing values de no responde
gen tiempo_TV_1=0 if f6601!=.

foreach v of varlist  f662lu1a-f662do2b   {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}

gen t_lunes_TV=(f662lu1a*60)+f662lu1b+(f662lu2a*60)+f662lu2b
gen dia_lunes_TV=1 if (t_lunes_TV!=0)
replace dia_lunes_TV=0 if (t_lunes_TV==0)

gen t_martes_TV=(f662ma1a*60)+f662ma1b+(f662ma2a*60)+f662ma2b
gen dia_martes_TV=1 if (t_martes_TV!=0)
replace dia_martes_TV=0 if (t_martes_TV==0)

gen t_miercoles_TV=(f662mi1a*60)+f662mi1b+(f662mi2a*60)+f662mi2b
gen dia_miercoles_TV=1 if (t_miercoles_TV!=0)
replace dia_miercoles_TV=0 if (t_miercoles_TV==0)

gen t_jueves_TV=(f662ju1a*60)+f662ju1b+(f662ju2a*60)+f662ju2b
gen dia_jueves_TV=1 if (t_jueves_TV!=0)
replace dia_jueves_TV=0 if (t_jueves_TV==0)

gen t_viernes_TV=(f662vi1a*60)+f662vi1b+(f662vi2a*60)+f662vi2b
gen dia_viernes_TV=1 if (t_viernes_TV!=0)
replace dia_viernes_TV=0 if (t_viernes_TV==0)

gen t_sabado_TV=(f662sa1a*60)+f662sa1b+(f662sa2a*60)+f662sa2b
gen dia_sabado_TV=1 if (t_sabado_TV!=0)
replace dia_sabado_TV=0 if (t_sabado_TV==0)

gen t_domingo_TV=(f662do1a*60)+f662do1b+(f662do2a*60)+f662do2b
gen dia_domingo_TV=1 if (t_domingo_TV!=0)
replace dia_domingo_TV=0 if (t_domingo_TV==0)

gen t_total_TV= t_lunes_TV+t_martes_TV + ///
  t_miercoles_TV+t_jueves_TV+t_viernes_TV+t_sabado_TV+t_domingo_TV

gen promedio_TV=(t_total_TV/7)


gen escolaridad_3_madre=1 if escolmadre>=0 & escolmadre<=7
  *primaria incompleta o analfabeto
 replace escolaridad_3_madre=2 if escolmadre>=8 & escolmadre<=13
 *secundaria incompleta o completa
 replace escolaridad_3_madre=3 if escolmadre>=14 & escolmadre<=20
 *Más de secundaria
lab var escolaridad_3_madre "Escolaridad de la Madre 3 categorias"
lab def escolaridad_3_madre 1 "Primaria incompleta o analfabeto" ///
  2 "Secundaria incompleta o completa" 3 "Más de secundaria"
lab val escolaridad_3_madre escolaridad_3_madre

gen TV_adolescentes_5=1 if promedio_TV<60
replace TV_adolescentes_5=2 if promedio_TV>=60 & promedio_TV<120
replace TV_adolescentes_5=3 if promedio_TV>=120 & promedio_TV<240
replace TV_adolescentes_5=4 if promedio_TV>=240 & promedio_TV<480
replace TV_adolescentes_5=5 if promedio_TV>=480 & promedio_TV<866

gen TV_adolescentes_4=1 if promedio_TV<60
replace TV_adolescentes_4=2 if promedio_TV>=60 & promedio_TV<120
replace TV_adolescentes_4=3 if promedio_TV>=120 & promedio_TV<240
replace TV_adolescentes_4=4 if promedio_TV>=240 & promedio_TV<866

gen TV_adolescentes_3_3=1 if promedio_TV<120
replace TV_adolescentes_3_3=2 if promedio_TV>=120 & promedio_TV<240
replace TV_adolescentes_3_3=3 if promedio_TV>=240 & promedio_TV<866

gen TV_adolescentes_2=0 if promedio_TV<120
replace TV_adolescentes_2=1 if promedio_TV>=120 & promedio_TV<866

***Cruces especificos
svyset idsector [pweight=pw], strata(area)
log using  AFado,replace

********************************************************************************
*Prevalencia de ningun dia / un dia / mas de un dia de ef por semana
global y  dias_EF
global z pd02 edadanio gr_etn subreg quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v',subpop(if  edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v',subpop(if  edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de tiempo dedicado a ver television y video juegos
*(3 categorias, 1=menos de 2 hora, 2= más de 2 horas y menos de 4,
*3= 4 horas o más)
global y TV_adolescentes_3_3
global z pd02 edadanio area escolaridad_3_madre  gr_etn subreg quint

foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<19) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<20 ) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<20 ) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<20 ) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if edadanio<20) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if edadanio<20) ///
		  obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de niveles de af (3 categorias, 1=inactivo,
*2= baja actividad, 3= Mediana o alta actividad)
global y cumplir_recom_AF
global z edadanio gr_etn subreg quint

foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==1 & edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if pd02==2 & edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if edadanio<18) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if edadanio<18) ///
		  obs count format(%17.4f) cellwidth(20)
		}
	}
translate AFado.smcl AFado.txt , replace linesize(255)

******************************************************************************
*****************Actividad fisica : Adultos 20 a 59 años**********************
******************************************************************************
*Preparación de base:
use ensanut_f8_actividad_fisica.dta,clear

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

merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(provincia subreg zonas_planificacion ///
  gr_etn area pd02 pd03 pd14 escol pa01 pa02 quint)
drop if _merge==2
drop _merge

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

*Sexo
gen sexo= pd02
*Edad
gen edad=pd03
*Grupos de edad
gen edad_grupo=1 if edad>=18 & edad <20
replace edad_grupo=2 if edad>=20 & edad <25
replace edad_grupo=3 if edad>=25 & edad <30
replace edad_grupo=4 if edad>=30 & edad <35
replace edad_grupo=5 if edad>=35 & edad <40
replace edad_grupo=6 if edad>=40 & edad <45
replace edad_grupo=7 if edad>=45 & edad <50
replace edad_grupo=8 if edad>=50 & edad <54
replace edad_grupo=9 if edad>=55 & edad <59
label define gredd 1 "de 18 a 19 años" 2 "de 20 a 24 años" ///
  3 "de 25 a 29 años" 4 "de 30 a 34 años" 5 "de 35 a 39 años" ///
  6 "de 40 a 44 años" 7 "de 45 a 49 años" 8 "de 50 a 54 años" ///
  9 "de 55 a 59 años"
label values edad_grupo gredd

*Escolaridad
*Ninguna
gen escolaridad=1 if escol==0
*Primaria incompleta
replace escolaridad=2 if escol>=1 & escol<7
*Primaria completa o secundaria incompleta
replace escolaridad=3 if escol>=7 & escol<13
*Primaria completa o secundaria incompleta
replace escolaridad=4 if escol>=13 & escol<=20
label define esc0 1 "ninguna" 2 "primaria incompleta" ///
  3 "primaria completa o secundaria incompleta" ///
  4 "primaria completa o secundaria incompleta"
label values escolaridad esc0

*Escolaridad 2
*ninguna
gen escolaridad_2=1 if escol==0
*primaria incompleta
replace escolaridad_2=2 if escol>=1 & escol<7
*primaria completa
replace escolaridad_2=3 if escol==7
*secundaria incompleta
replace escolaridad_2=4 if escol>=8 & escol<13
*secundaria completa
replace escolaridad_2=5 if escol==13
*Más de secundaria
replace escolaridad_2=6 if escol>=14 & escol<=20
label define esc1 1 "ninguna" 2 "primaria incompleta" ///
  3 "primaria completa" 4 "secundaria incompleta" ///
  5 "secundaria completa" 6 "Más de secundaria"
label values escolaridad_2 esc1

*Escolaridad 3
*primaria incompleta o analfabeto
gen escolaridad_3=1 if escol>=0 & escol<=7
*secundaria incompleta o completa
replace escolaridad_3=3 if escol>=8 & escol<=13
*Más de secundaria
replace escolaridad_3=5 if escol>=14 & escol<=20
label define esc3 1 "primaria incompleta o analfabeto" ///
  3 "secundaria incompleta o completa" 5 "Más de secundaria"
label values escolaridad_3 esc3

*Estado civil
*Casado o unión libre
gen estado_civil=1 if (pd14==1 | pd14==2)
*Soltero
replace estado_civil=2 if pd14==6
*Divorsiado o separado
replace estado_civil=3 if (pd14==3 | pd14==4)
*Viudo
replace estado_civil=4 if pd14==5
label define escv 1 "Casado o unión libre" 2 "Soltero" ///
  3 "Divorciado o separado" 4 "Viudo"
label values estado_civil escv

*Actividad Principal
*Trabaja
gen prin_actividad=1 if (pa01==1 | pa01==2 | pa01==3 | pa01==4 | pa01==5)
*Cesante, buscó trabajo
replace prin_actividad= 2 if pa01==6
*Buscó trabajo y trabajaba previamente
 replace prin_actividad= 3 if pa01==7
*Buscó trabajo por primera vez
 replace prin_actividad= 4 if pa02==1
*Rentista
 replace prin_actividad= 5 if pa02==2
*Pensionado o juvilado
 replace prin_actividad= 6 if pa02==3
*Estudiante
 replace prin_actividad= 7 if pa02==4
*Actividades domesticas de su hogar
 replace prin_actividad= 8 if pa02==5
*Ama de casa
replace prin_actividad= 9 if pa02==6
*otro
replace prin_actividad= 10 if pa02==7
label def pr_ac 1 "Trabaja" 2 "Cesante, buscó trabajo" ///
  3 "Buscó trabajo y trabajaba previamente" 4 "Buscó trabajo por primera vez" ///
  5 "Rentista" 6 "Pensionado o jubilado" 7 "Estudiante" ///
  8 "Actividades domesticas de su hogar" 9 "Ama de casa" 10 "Otro"
label val prin_actividad pr_ac

*Actividad Principal_bis
*Trabaja
gen prin_actividad_2= 1 if (pa01==1 | pa01==2 | pa01==3 | pa01==4 | pa01==5)
*Cesante, buscó trabajo
replace prin_actividad_2= 2 if (pa01==6 | pa02==1)
*Estudiante
replace prin_actividad_2= 3 if pa02==4
*Actividades domesticas de su hogar
replace prin_actividad_2= 4 if pa02==5
*Otro: otro, rentista, pensionado
replace prin_actividad_2= 5 if (pa02==2 | pa02==3 | pa02==6 | pa02==7 )
label def pr_ac2 1 "Trabaja" 2 "Cesante, buscó trabajo" ///
  3 "Estudiante" 4 "Actividades domesticas de su hogar" ///
  5 "Otro: otro, rentista, pensionado"
label value  prin_actividad_2 pr_ac2

****************************************
*Desplazamiento en vehículos automotores
gen t_tsmv_1=0 if f8101!=.

*Missing values de no responde
foreach v of varlist  f812lu1a-f812do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_tsmv_2= t_tsmv_1+(f812lu1a*60)+f812lu1b+(f812ma1a*60) + ///
  f812ma1b+(f812mi1a*60)+f812mi1b+(f812ju1a*60)+f812ju1b + ///
  (f812vi1a*60)+f812vi1b+(f812sa1a*60)+f812sa1b+(f812do1a*60) + ///
  f812do1b+(f812lu2a*60)+f812lu2b+(f812ma2a*60)+f812ma2b + ///
  (f812mi2a*60)+f812mi2b+(f812ju2a*60)+f812ju2b+(f812vi2a*60) + ///
  f812vi2b+(f812sa2a*60)+f812sa2b+(f812do2a*60)+f812do2b
gen TRMAM_3=1 if f8101==2
replace TRMAM_3=2 if t_tsmv_2>=10 & t_tsmv_2<150 & f8101==1
replace TRMAM_3=3 if t_tsmv_2>=150 & f8101==1


*Bicicleta como medio de transporte
gen t_bici_transp_1=0 if f8103!=.
foreach v of varlist  f814lu1a-f814do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_bici_transp_2= t_bici_transp_1+(f814lu1a*60)+f814lu1b ///
  +(f814ma1a*60)+f814ma1b+(f814mi1a*60)+f814mi1b+(f814ju1a*60) ///
  +f814ju1b+(f814vi1a*60)+f814vi1b+(f814sa1a*60)+f814sa1b+(f814do1a*60) ///
  +f814do1b+(f814lu2a*60)+f814lu2b+(f814ma2a*60)+f814ma2b+(f814mi2a*60) ///
  +f814mi2b+(f814ju2a*60)+f814ju2b+(f814vi2a*60)+f814vi2b+(f814sa2a*60) ///
  +f814sa2b+(f814do2a*60)+f814do2b
gen bici_transp_3=1 if f8103==2
replace bici_transp_3=2 if t_bici_transp_2>=10 & ///
  t_bici_transp_2<150 & f8103==1
replace bici_transp_3=3 if t_bici_transp_2>=150 & f8103==1

*Caminar como medio de transporte
gen t_cam_transp_1=0 if f8105!=.
foreach v of varlist  f816lu1a-f816do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_cam_transp_2= t_cam_transp_1+(f816lu1a*60)+f816lu1b+(f816ma1a*60) + ///
  f816ma1b+(f816mi1a*60)+f816mi1b+(f816ju1a*60)+f816ju1b+(f816vi1a*60) + ///
  f816vi1b+(f816sa1a*60)+f816sa1b+(f816do1a*60)+f816do1b+(f816lu2a*60) + ///
  f816lu2b+(f816ma2a*60)+f816ma2b+(f816mi2a*60)+f816mi2b+(f816ju2a*60) + ///
  f816ju2b+(f816vi2a*60)+f816vi2b+(f816sa2a*60)+f816sa2b+(f816do2a*60)+f816do2b
gen cami_transp_3=1 if f8105==2
replace cami_transp_3=2 if t_cam_transp_2>=10 & t_cam_transp_2<150 & f8105==1
replace cami_transp_3=3 if t_cam_transp_2>=150 & f8105==1


*Caminar recreación
gen t_cam_recrea_1=0 if f8201!=.
foreach v of varlist  f822lu1a-f822do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_cam_recrea_2=t_cam_recrea_1+(f822lu1a*60)+f822lu1b+(f822ma1a*60) + ///
  f822ma1b+(f822mi1a*60)+f822mi1b+(f822ju1a*60)+f822ju1b+(f822vi1a*60) + ///
  f822vi1b+(f822sa1a*60)+f822sa1b+(f822do1a*60)+f822do1b+(f822lu2a*60) + ///
  f822lu2b+(f822ma2a*60)+f822ma2b+(f822mi2a*60)+f822mi2b+(f822ju2a*60) + ///
  f822ju2b+(f822vi2a*60)+f822vi2b+(f822sa2a*60)+f822sa2b+(f822do2a*60)+f822do2b
gen cami_recrea_3=1 if f8201==2
replace cami_recrea_3=2 if t_cam_recrea_2>=10 & t_cam_recrea_2<150 & f8201==1
replace cami_recrea_3=3 if t_cam_recrea_2>=150 & f8201==1

*Moderada recreación
gen t_mod_recrea_1=0 if f8203!=.
foreach v of varlist  f824lu1a-f824do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_mod_recrea_2=t_mod_recrea_1+(f824lu1a*60)+f824lu1b+(f824ma1a*60) + ///
  f824ma1b+(f824mi1a*60)+f824mi1b+(f824ju1a*60)+f824ju1b+(f824vi1a*60) + ///
  f824vi1b+(f824sa1a*60)+f824sa1b+(f824do1a*60)+f824do1b+(f824lu2a*60) + ///
  f824lu2b+(f824ma2a*60)+f824ma2b+(f824mi2a*60)+f824mi2b+(f824ju2a*60) + ///
  f824ju2b+(f824vi2a*60)+f824vi2b+(f824sa2a*60)+f824sa2b+(f824do2a*60)+f824do2b
gen mod_recrea_3=1 if f8203==2
replace mod_recrea_3=2 if t_mod_recrea_2>=10 & t_mod_recrea_2<150 & f8203==1
replace mod_recrea_3=3 if t_mod_recrea_2>=150 & f8203==1

*Vigorosa recreación
gen t_vig_recrea_1=0 if f8205!=.
foreach v of varlist  f826lu1a-f826do2b {
replace `v'=0 if `v'==.
replace `v'=0 if `v'==99
}
gen t_vig_recrea_2=t_vig_recrea_1+(f826lu1a*60)+f826lu1b+(f826ma1a*60) ///
  +f826ma1b+(f826mi1a*60)+f826mi1b+(f826ju1a*60)+f826ju1b+(f826vi1a*60) ///
  +f826vi1b+(f826sa1a*60)+f826sa1b+(f826do1a*60)+f826do1b+(f826lu2a*60) ///
  +f826lu2b+(f826ma2a*60)+f826ma2b+(f826mi2a*60)+f826mi2b+(f826ju2a*60) ///
	 +f826ju2b+(f826vi2a*60)+f826vi2b+(f826sa2a*60)+f826sa2b+(f826do2a*60) ///
	  +f826do2b
gen vig_recrea_3=1 if f8205==2
replace vig_recrea_3=2 if t_vig_recrea_2>=10 & t_vig_recrea_2<75 & f8205==1
replace vig_recrea_3=3 if t_vig_recrea_2>=75 & f8205==1


*Indice de Actividad Fisica Total
gen AFTL_3=1 if (cami_recrea_3==1 & mod_recrea_3==1 & vig_recrea_3==1)
replace AFTL_3=3 if (cami_recrea_3==3 | mod_recrea_3==3 | vig_recrea_3==3)
replace AFTL_3=2 if AFTL_3==.
replace AFTL_3=. if cami_recrea_3==.
replace AFTL_3=. if mod_recrea_3==.
replace AFTL_3=. if vig_recrea_3==.

gen af_global=1 if (AFTL_3==1 & cami_transp_3==1 & bici_transp_3==1)
replace af_global=3 if (AFTL_3==3 | cami_transp_3==3 | bici_transp_3==3)
replace af_global=2 ///
  if af_global==. | AFTL_3==. | cami_transp_3==. | bici_transp_3==.

************************************************************************
*Prevalencia de tiempo dedicado desplazandose en vehiculo automotor
global y TRMAM_3
global z  sexo edad_grupo area escolaridad_3 gr_etn ///
  subreg  estado_civil prin_actividad_2 zonas_planificacion  provincia quint

foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de aftl en poblacion adulta
global y AFTL_3
global z  sexo edad_grupo area escolaridad_3 gr_etn subreg ///
  estado_civil prin_actividad_2 zonas_planificacion  provincia quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de caminata como medio de transporte en poblacion adulta
global y cami_transp_3
global z  sexo edad_grupo area escolaridad_3 gr_etn subreg ///
  estado_civil prin_actividad_2 zonas_planificacion  provincia quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		   row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de bicicleta como medio de transporte en poblacion adulta
global y bici_transp_3
global z  sexo edad_grupo area escolaridad_3 gr_etn subreg ///
  estado_civil prin_actividad_2 zonas_planificacion  provincia quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}

*Prevalencia de actividad fisica global como medio de transporte en poblacion adulta
global y af_global
global z  sexo edad_grupo area escolaridad_3 gr_etn subreg  ///
  estado_civil prin_actividad_2 zonas_planificacion  provincia quint
foreach v of global y {
	foreach w of global z {
		di "*HOMBRE Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==1) ///
		  obs count format(%17.4f) cellwidth(20)
		di "*MUJER Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		  row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', subpop(if sexo==2) ///
		obs count format(%17.4f) cellwidth(20)
		di "*TOTAL Prevalencias de ""`v'"" por ""`w'""  *"
		svy: tabulate `w' `v', row ci format(%17.4f) cellwidth(20)
		svy: tabulate `w' `v', obs count format(%17.4f) cellwidth(20)
		}
	}
log off
log close
translate AFado.smcl AFado.txt , replace linesize(255)

*13-12-2013_v0.01
*Análisis de Actividad física ensansut 2012 termina ahí**************************
