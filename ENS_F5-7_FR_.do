******************************************************************************
**************Encuesta Nacional de Salud y Nutrición 2011-2013****************
*********************Tomo 1***************************************************
*********************Capítulo: Factores de riesgo*****************************
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
*Ingresar el directorio de la base:
cd ""
*Variables de identificadores & svyset
set more off

******************************************************************************
*****************Factores de riesgo niños de 5 a 9 años***********************
******************************************************************************
*Preparación de base:
*Identificadores y factores de expansion
*Base :
use "ensanut_f5_fact_riesgo_ninos.dta",clear


*Identificador de personas / Hogar / vivienda
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

*Variables de cruce:
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(pd02 area gr_etn subreg zonas_planificacion ///
  provincia quint edaddias edadanio)
drop if _merge==2
drop _merge

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

******************************************************************************
*Consulta al dentista
*Variable motivo de consulta prevencion y tratamiento
replace f5304=. if (f5304==9)
*****************
gen visitadentistacatego=f5304
recode visitadentistacatego (1/4=0) (5/8=1)
lab var visitadentistacatego "motivo visita al dentista categorizada"
lab def vsdt 0 "prevencion" 1 "tratamiento"
lab val visitadentistacatego vsdt
tab visitadentistacatego

*Motivo de visita al dentista por area
svy: tabulate edadanio visitadentistacatego, ///
 subpop(if (area==1)) row ci cv obs format(%17.4f)
svy: tabulate edadanio visitadentistacatego, ///
 subpop(if (area==2)) row ci cv obs format(%17.4f)
svy: tabulate edadanio visitadentistacatego, row ci cv obs format(%17.4f)

*Motivo de visita al dentista por sexo
svy: tabulate edadanio visitadentistacatego, ///
 subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate edadanio visitadentistacatego, ///
 subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edadanio visitadentistacatego, row ci cv obs format(%17.4f)

*Lugar de visita al dentista por sexo
*F5303 PROCEDENCIA DEL PROFESIONAL*
replace f5303=. if  (f5303==12)
gen dentistavisitacatego=f5303
recode  dentistavisitacatego (11=3) (1/4=0) (5/6=1) (7/10=2)
lab var  dentistavisitacatego "visita al dentista categorizada"
lab def dcg  0 "unidades del ministerio de salud" ///
  1 "unidades de la seguridad social" 2 ///
  "unidades de policia, fuerzas armadas y otros" 3 "unidades privadas"
lab val  dentistavisitacatego dcg
tab dentistavisitacatego

svy: tabulate edadanio dentistavisitacatego, ///
 subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate edadanio dentistavisitacatego, ///
 subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edadanio dentistavisitacatego, row ci cv obs format(%17.4f)

*Motivo de consulta y lugar de consulta
svy: tabulate dentistavisitacatego visitadentistacatego, ///
 row ci cv obs format(%17.4f)

*Motivo de no ir a la consulta y area
*Valores perdidas "sin otros cual"
replace f5302=. if (f5302==9)
svy: tabulate f5302 area, row ci cv obs format(%17.4f)


******************************************************************************
*CALIDAD DE VIDA
*Calidad de vida percibida por las madres, poblacion 5 a 9 años
*Calculo efectuado con el programa SPSS_
*Calculo de cluster con la metodogia de Ward:
*local vclu f5101 f5102 f5103 f5104 f5105 ///
* f5106 f5107 f5108 f5109 f5110 f5111 f5112
*cluster ward vclu
*cluster gen clu5 = group(5)
*estratificacion por sexo, area, etnia, quintil
global vardlp clu5_1
global vardsg pd02 area gr_etn quint
foreach V of global vardlp {
  foreach Y of global vardsg {
di "*TOTAL Prevalencias de ""`V'"" por ""`Y'"" *"
tabout `Y' `V' using p.txt ,replace c(freq) f(3.1)
tabout `Y' `V' using p.txt ,replace cells(row lb ub) f(3.1) svy
}
}

******************************************************************************
*Grupos de edad por caracteristicas y tamaños de poblaciones
svy: tabulate edadanio visitadentistacatego, ///
 subpop(if (area==1)) row ci cv obs format(%17.4f)

local V pd02 area gr_etn quint subreg zonas_planificacion provincia
local X edadanio
foreach Z in `X' {
foreach Y in `V' {
svy: tabulate `Y' `Z' ,obs count format(%17.4f)
svy: tabulate `Y' `Z' ,obs col format(%17.4f)
 }
}

******************************************************************************
*****************Factores de riesgo adolescentes (10 a 19 años)***************
******************************************************************************
*Identificacdores y factores de expansion
*Base :
use "ensanut_f6_fact_riesgo_adolescentes.dta",clear

*Identificador de personas / Hogar / vivienda
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

*Variables de cruce:
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(pd02 area gr_etn subreg zonas_planificacion ///
  provincia quint edaddias edadanio)
drop if _merge==2
drop _merge

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

*Grupos de edad especificos:
*edrec1019 = edrecadoles
*edrec2 = edrec22
*Grupos de edad de analisis (adolescentes 10 a 19 años)
gen edrecadoles=edadanio
recode edrecadoles (10/14=0) (15/max=1)
lab var edrecadoles "edad (adolescentes)"
lab def edrec22 0 "10 a 14 años" 1 "15 a 19 años"
lab val edrecadoles edrec22

**************************************************************************************
*Hábitos comida y bebida, 10 a 19 años

*Descripción del consumo de gaseosas, comida rápida y snacks por edadrecadoles y sexo
**f6101a = gaseosas
*Total* *hombre* *mujer*
svy: tabulate edrecadoles f6101a , subpop(if (pd02)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6101a , subpop(if (pd02==1)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6101a , subpop(if (pd02==2)) ///
 row ci cv obs format(%17.4f)

** f6102a = Comida rápida
*Total* *hombre* *mujer*
svy: tabulate edrecadoles f6102a , subpop(if (pd02)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6102a , subpop(if (pd02==1)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6102a , subpop(if (pd02==2)) ///
 row ci cv obs format(%17.4f)

** f6103a = Snacks
*Total* *hombre* *mujer*
svy: tabulate edrecadoles f6103a , subpop(if (pd02)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6103a , subpop(if (pd02==1)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6103a , subpop(if (pd02==2)) ///
 row ci cv obs format(%17.4f)

*Descripción de gaseosas, comida rápida y snacks por subregión
** f6101a = gaseosas
svy: tabulate subreg f6101a, row ci cv obs format(%17.4f)
** f6102a = Comida rápida
svy: tabulate subreg f6102a, row ci cv obs format(%17.4f)
** f6103a = Snacks
svy: tabulate subreg f6103a, row ci cv obs format(%17.4f)

*Descripción de gaseosas, comida rápida y snacks por zona de planificación
** f6101a = gaseosas
svy: tabulate zonas_planificacion f6101a, row ci cv obs format(%17.4f)
** f6102a = Comida rápida
svy: tabulate zonas_planificacion f6102a, row ci cv obs format(%17.4f)
** f6103a = Snacks
svy: tabulate zonas_planificacion f6103a, row ci cv obs format(%17.4f)

*Descripción de gaseosas, comida rápida y snacks por quintil económico
** f6101a = gaseosas
svy: tabulate quint f6101a, row ci cv obs format(%17.4f)
** f6102a = Comida rápida
svy: tabulate quint f6102a, row ci cv obs format(%17.4f)
** f6103a = Snacks
svy: tabulate quint f6103a, row ci cv obs format(%17.4f)

*Descripción de gaseosas, comida rápida y snacks por grupo étnico
** f6101a = gaseosas
svy: tabulate gr_etn f6101a, row ci cv obs format(%17.4f)
** f6102a = Comida rápida
svy: tabulate gr_etn f6102a, row ci cv obs format(%17.4f)
** f6103a = Snacks
svy: tabulate gr_etn f6103a, row ci cv obs format(%17.4f)

********************************************************************************
*Dieta para adelgazar, 10 a 19 años

*Prevalencia de la práctica de dieta, por edadrecadoles y sexo
*f6104a = dieta
*Total* *hombre* *mujer**
svy: tabulate edrecadoles f6104a, subpop(if (pd02)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6104a, subpop(if (pd02==1)) ///
 row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6104a, subpop(if (pd02==2)) ///
 row ci cv obs format(%17.4f)

*Prevalencia de la práctica de dieta, por area y sexo f6104a= dieta
*Total* *hombre* *mujer**
svy: tabulate area f6104a, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate area f6104a, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate area f6104a, subpop(if (pd02==2)) row ci cv obs format(%17.4f)

*Prevalencia de la práctica de dieta, por grupo étnico
*f6104a = dieta
svy: tabulate gr_etn f6104a, row ci cv obs format(%17.4f)

*Prevalencia de la práctica de dieta, por quintil económico
** f6104a = dieta
svy: tabulate quint f6104a, row ci cv obs format(%17.4f)

********************************************************************************
*Autopercepción, 10 a 19 años

*Prevalencia de percepción de peso corporal, evitar el aumento de peso
*f6701 = como ve usted con relación a su peso corporal
*Total* *hombre* *mujer**
svy: tabulate f6701 f6705, row ci cv obs format(%17.4f)
svy: tabulate f6701 f6705, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate f6701 f6705, subpop(if (pd02==2)) row ci cv obs format(%17.4f)

*Prevalencia de percepción de peso corporal, trata de perder peso
*f6701 tratae perder peso?
*Total* *hombre* *mujer*
svy: tabulate f6701 f6704, row ci cv obs format(%17.4f)
svy: tabulate f6701 f6704, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate f6701 f6704, subpop(if (pd02==2)) row ci cv obs format(%17.4f)

*Prevalencia de nacional de comer grasas, harinas y hacer ejercicio
svy: tabulate pd02 f6708, row ci cv obs format(%17.4f)
svy: tabulate pd02 f6709, row ci cv obs format(%17.4f)

*Prevalencia de medidas para perder peso
*Está comiendo menos grasa, harina o dulces para perder de peso :  f6706
svy: tabulate pd02 f6706, subpop(if (f6704==1)) row ci cv obs format(%17.4f)
*Está realizando ejercicios para perder de peso :  f6707
svy: tabulate pd02 f6707, subpop(if (f6704==1)) row ci cv obs format(%17.4f)
*En los últimos 30 días dejo de comer por 24 horas o más : f6710
svy: tabulate pd02 f6710, subpop(if (f6704==1)) row ci cv obs format(%17.4f)
*En los últimos 30 días consumió medicamentos
*para perder o no aumentar de peso: f6711
svy: tabulate pd02 f6711, subpop(if (f6704==1)) row ci cv obs format(%17.4f)
*En los últimos 30 días vomitó o tomó laxantes
*para perder o no aumentar de peso:  f6712
svy: tabulate pd02 f6712, subpop(if (f6704==1)) row ci cv obs format(%17.4f)

********************************************************************************
*Limpieza de los dientes y el lavado de manos
*Limpiado y cepillado de dientes, últimos 7 días, por sexo
svy: tabulate pd02 f6401, row ci cv obs format(%17.4f)
*Limpiado y cepillado de dientes, últimos 7 días, por area
svy: tabulate area f6401, row ci cv obs format(%17.4f)
*Lavado de manos antes de comer, últimos 7 días, por sexo
svy: tabulate pd02 f6402, row ci cv obs format(%17.4f)
*Lavado de manos antes de comer, últimos 7 días, por area
svy: tabulate area f6402, row ci cv obs format(%17.4f)
*Lavado de manos después de usar el inodoro o letrina, últimos 7 días, por sexo
svy: tabulate pd02 f6403, row ci cv obs format(%17.4f)
*Lavado de manos después de usar el inodoro o letrina, últimos 7 días, por area
svy: tabulate area f6403, row ci cv obs format(%17.4f)
*Frecuencia del uso de jabón al lavarse las manos, últimos 7 días, por sexo
svy: tabulate pd02 f6404, row ci cv obs format(%17.4f)
*Frecuencia del uso de jabón al lavarse las manos, últimos 7 días, por area
svy: tabulate area f6404, row ci cv obs format(%17.4f)
*Frecuencia del uso de jabón al lavarse las manos, últimos 7 días, por area
svy: tabulate quint f6404, row ci cv obs format(%17.4f)

********************************************************************************
*Tabaco y alcohol, 10 a 19 años

*Descripción de tabaco, has fumado cigarrilos y otros productos de tabaco,
*nacional *f6201 = Has fumano ciagarrillos u otros productos de tabaco
*alguna vez en tu vída
*Total**Mujer**Hombre*
svy: tabulate edrecadoles f6201, subpop(if (pd02)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6201, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6201, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Descripción de tabaco, has fumado cigarrilos y otros productos de tabaco,
*por grupo étnico
svy: tabulate gr_etn f6201, subpop (if (edrecadoles!=.)) ///
 row ci cv obs format(%17.4f)

*Descripción de tabaco, has fumado cigarrilos y
*otros productos de tabaco, por área
svy: tabulate area f6201, subpop (if (edrecadoles!=.)) ///
 row ci cv obs format(%17.4f)

*Descripción de tabaco, has fumado cigarrilos y otros productos de tabaco ///
*por provincia
svy: tabulate provincia f6201, ///
 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)

*Descripción de tabaco, has fumado cigarrilos y otros productos de tabaco,
*por quintil
svy: tabulate  quint f6201, ///
 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)

*Descripción de tabaco, edad del primer cigarrillo
*f6202 = Qué edad tenías cuando probaste un cigarrillo o
*otro producto de tabaco, por primera vez (nivel nacional)
svy: tabulate pd02 f6202, ///
 subpop (if (f6203a==1 & edrecadoles!=.)) row ci cv obs format(%17.4f)

*Descripción de tabaco, fumo durante los ultimos 30 días (consumo actual)
*f6203a = En los ultimos 30 días ha fumado?
*NACIONAL
*Total**mujer**hombre*
svy: tabulate edrecadoles f6203a, ///
 subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6203a, ///
 subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6203a, ///
 subpop(if (pd02==1)) row ci cv obs format(%17.4f)
*QUINTIL
svy: tabulate quint f6203a, ///
 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
* AREA
svy: tabulate area f6203a, ///
 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)

*Descriptiva estadistica de tabaco tabacos fumados ultimos 30 días
sum f6203b [aw=pw] if(edrecadoles!=.), detail
svy : mean f6203b , subpop (if (edrecadoles!=.))
bysort edrecadoles: sum f6203b [aw=pw] if(edrecadoles!=.), detail
tabout edrecadoles if (edrecadoles!=.) ///
  using pb.txt, replace c( mean f6203b lb ub) f(1.1) svy sum
*Mujer
bysort edrecadoles: sum f6203b [aw=pw] if(edrecadoles!=. & pd02==2), detail
tabout edrecadoles if (edrecadoles!=. & pd02==2) ///
  using pb.txt, replace c( mean f6203b lb ub) f(1.1) svy sum
*Hombre
bysort edrecadoles: sum f6203b [aw=pw] if(edrecadoles!=. & pd02==1), detail
tabout edrecadoles if (edrecadoles!=. & pd02==1) ///
  using pb.txt, replace c( mean f6203b lb ub) f(1.1) svy sum

*Descripción de tabaco, alguien fuma en su casa
*f6204 = Alguién de tu hogar fuma
*Total**mujer**hombre*
svy: tabulate edrecadoles f6204, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6204, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6204, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Descripción de tabaco, le dirias a un amigo que apague el cigarrillo
*f6205 = Le dirias a un amigo que apague el cigarrillo si fumara cerca de ti
*Total**mujer**hombre*
svy: tabulate edrecadoles f6205, ///
 subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6205, ///
 subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6205, ///
 subpop(if (pd02==1)) row ci cv obs format(%17.4f)

*Descripción de tabaco, obtener cigarrillos
*f6206 = para ti obtener cigarrillos o productos de tabaco es
*"no sabe" y "no responde" como missing:
replace f6206=. if f6206==88
replace f6206=. if f6206==99
*Total**mujer**hombre*
svy: tabulate edrecadoles f6206, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6206, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6206, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Descripción de alcohol, has bebido alcohol alguna vez en tu vída, nacional
replace f6301=. if f6301==99

** f6301 = Has bebido alcohol alguna vez en tu vída
*Total**mujer**hombre*
svy: tabulate edrecadoles f6301, row ci cv obs format(%17.4f)
 svy: tabulate edrecadoles f6301, ///
 subpop(if (pd02==2)) row ci cv obs format(%17.4f)
 svy: tabulate edrecadoles f6301, ///
 subpop(if (pd02==1)) row ci cv obs format(%17.4f)

*Descripción de alcohol, has bebido alcohol alguna vez en tu vída, Grupo Étnico
svy: tabulate gr_etn f6301, ///
 subpop (if edrecadoles!=.) row ci cv obs format(%17.4f)
*Descripción de alcohol, has bebido alcohol alguna vez en tu vída, por área
svy: tabulate area f6301 , ///
	 subpop(if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Descripción de alcohol, has bebido alcohol alguna vez en tu vída, por Provincia
svy: tabulate provincia f6301 , ///
	 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Descripción de alcohol, has bebido alcohol alguna vez en tu vída, por Quintil
svy: tabulate quint f6301 , ///
	 subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Descripción de alcohol, alguna vez te has enborrachado

*Descriptiva estadistica de días de alcohol en los ultimos 30 días
sum f6305b [aw=pw], detail
svy : mean f6305b
bysort edrecadoles: sum f6305b [aw=pw], detail
tabout edrecadoles using pb.txt, replace c( mean f6305b lb ub) f(1.1) svy sum
** Mujer
bysort edrecadoles: sum f6305b [aw=pw] if(edrecadoles!=. & pd02==2), detail
tabout edrecadoles if (edrecadoles!=. & pd02==2) using pb.txt, ///
 replace c( mean f6305b lb ub) f(1.1) svy sum
** Hombre
bysort edrecadoles: sum f6305b [aw=pw] if(edrecadoles!=. & pd02==1), detail
tabout edrecadoles if (edrecadoles!=. & pd02==1) using pb.txt, ///
 replace c( mean f6305b lb ub) f(1.1) svy sum

*f6302 = Alguna vez te has emborrachado
*Total**mujer**hombre*
svy: tabulate edrecadoles f6302, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6302, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6302, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Descripción de alcohol, edad del primer consumo
*f6303 = Qué edad tenías cuando tomaste tu primer trágo de alcohol.
*Nacional
svy: tabulate pd02 f6303, ///
  subpop (if (f6305a==1 & edrecadoles!=.)) row ci cv obs format(%17.4f)

*Descripción de alcohol, frecuencia :
*f6304 = Cuando tu tomas/tomaste lo haces por sexo
*Total**mujer**hombre*
svy: tabulate edrecadoles f6304, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6304, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6304, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Descripción de alcohol, ha bebido alcohol
*durante los ultimos 30 días (bebedor actual)
*f6305a = En los ultimos 30 días ha bebido alcohol?
*Total**mujer**hombre*
svy: tabulate edrecadoles f6305a, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadoles f6305a, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadoles f6305a, subpop(if (pd02==1)) row ci obs format(%17.4f)

*Grupo étnico
svy: tabulate gr_etn f6305a, ///
  subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Quintil
svy: tabulate quint f6305a, ///
  subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Area
svy: tabulate area f6305a, ///
  subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)
*Provincia
svy: tabulate provincia f6305a, ///
  subpop (if (edrecadoles!=.)) row ci cv obs format(%17.4f)

******************************************************************************
*****************Factores de riesgo adultos de 20 a 59 años*******************
******************************************************************************
*¨Preparación de la base
*Identificacdores y factores de expansion
*Base :
use ensanut_f7_fact_riesgo_mayores.dta,clear
cap drop id*
*Identificador de personas / Hogar / vivienda
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

*Variables de cruce: Area / Quintil ...
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(pd02 area gr_etn subreg zonas_planificacion ///
  provincia quint edadanio)
drop if _merge==2
drop _merge

*Configuracion de svy:
svyset idsector [pweight=pw], strata (area)

*Asignación Missing values:
global y f7403 f7404 f7405 f71051 f71052 f71053 f71054 f71055 f71056 f7203 ///
  f7204lu1 f7204ma1 f7204mi1 f7204ju1 f7204vi1 f7204sa1 f7204do1 f7204lu2 ///
  f7204ma2 f7204mi2 f7204ju2 f7204vi2 f7204sa2 f7204do2 f7301
foreach V of global y {
replace `V'=. if (`V'==88|`V'==99)
}

******************************************************************************
*Cuadros descriptivos de l poblacion:
global g subreg zonas_planificacion gr_etn quint
foreach V of global g {
svy: tabulate `V' pd02, obs count format(%17.4f) cellwidth(20)
svy: tabulate `V' pd02, row ci format(%17.4f) cellwidth(20)
}

*Grupos de edad (decenios)
gen edrecadul=edadanio
recode edrecadul (20/29=0) (30/39=1) (40/49=2)(50/59=3)
lab var edrecadul "edad decenios"
lab def edrec 0 "20 a 29 años" 1 "30 a 39 años" ///
  2 "40 a 49 años" 3 "50 a 59 años"
lab val edrecadul edrec

******************************************************************************
*Consumo de comidas fuera de casa
*Estadisticas descriptivas generales
summ f7301 [aw=pw],detail
bysort pd02: summ f7301 [aw=pw],detail
bysort edrec: summ f7301 [aw=pw],detail
*Mean & 95 CI
svy: mean f7301
svy: mean f7301,subpop(if (pd02==1))
svy: mean f7301,subpop(if (pd02==2))
svy: mean f7301,subpop(if (edrec==0))
svy: mean f7301,subpop(if (edrec==1))

*Dummy Consumo de comidas fuera de casa
gen comidarec=0 if f7301==0
replace comidarec=1 if f7301!=0
replace comidarec=. if f7301==.
lab var comidarec "Come fuera de casa en la semana"
lab def comidarec 0 "no" 1 "si"
lab val comidarec comidarec
svy: tab comidarec, ci obs format(%17.4f) cellwidth(20)

*Comida fuera de casa recodificada en dicotómica
gen comerec=f7301
recode comerec (88 99=.) (0 = 0) (1/21=1)
lab var comerec "comer fuera de casa"
lab def comerfuera 0 "no" 1 "si"
lab val comerec comerfuera

*Ha ingerido comidas preparadas fuera del hogar, edad sexo
*total**mujer**hombre*
svy: tabulate edrecadul comerec, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul comerec, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul comerec, subpop(if (pd02==2)) row ci cv obs format(%17.4f)

*Ha ingerido comidas preparadas fuera del hogar, por subregión
svy: tabulate subreg comerec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Ha ingerido comidas preparadas fuera del hogar, por área
svy: tabulate area comerec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Ha ingerido comidas preparadas fuera del hogar, por zona de planificación
svy: tabulate zonas_planificacion comerec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Ha ingerido comidas preparadas fuera del hogar, por quintil economico
svy: tabulate quint comerec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Ha ingerido comidas preparadas fuera del hogar, por grupo étnico
svy: tabulate gr_etn comerec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)


*Consumo de sal, 20 a 59 años
*Cuanta sal cree que usted consume? nacional y por area
replace f7403=. if f7403==88
replace f7403=. if f7403==99
svy: tabulate pd02 f7403, row ci cv obs format(%17.4f)
svy: tabulate area f7403, row ci cv obs format(%17.4f)

*Piensa que un regimen alimentario con sal ...? nacional y por area*
replace f7404=. if f7404==88
replace f7404=. if f7404==99
svy: tabulate pd02 f7404, row ci cv obs format(%17.4f)
svy: tabulate area f7404, row ci cv obs format(%17.4f)

********************************************************************************
*Consumo de tabaco y alcohol, 20 a 59 años
*Prevalencia de vida de consumo de tabaco
*f7101 = Ha fumado alguna vez en su vida cigarrillos
*u otros productos de tabaco.
*Total**mujer**hombre*
svy: tabulate edrecadul f7101, row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7101, ///
  subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7101, ///
  subpop(if (pd02==1)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por subregión *
svy: tabulate subreg f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por área *
svy: tabulate area f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por zona de planificación *
svy: tabulate zonas_planificacion f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por quintil economico *
svy: tabulate quint f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por grupo étnico *
svy: tabulate gr_etn f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de fumar, por provincia *
svy: tabulate provincia f7101, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)

*Edad de inicio de consumo de cigarrillo

*Estadistica descriptiva de edad de inicio de consumo de tabaco
replace f7102=. if f7102==77
sum f7102 [aw=pw] if(f7103==1 & edrecadul!=.), detail
svy : mean f7102, subpop (if(f7103==1 & edrecadul!=.))
bysort edrecadul: sum f7102 [aw=pw] if(f7103==1 & edrecadul!=.), detail
tabout edrecadul if(f7103==1 & edrecadul!=.) using pb.txt, ///
  replace c( mean f7102 lb ub) f(1.1) svy sum
* Mujer
bysort edrecadul: sum f7102 [aw=pw] if(f7103==1 & edrecadul!=. & pd02==2), detail
tabout edrecadul if(f7103==1 & edrecadul!=. & pd02==2) using pb.txt, ///
  replace c( mean f7102 lb ub) f(1.1) svy sum
* Hombre
bysort edrecadul: sum f7102 [aw=pw] if(f7103==1 & edrecadul!=. & pd02==1), detail
tabout edrecadul if(f7103==1 & edrecadul!=. & pd02==1) using pb.txt, ///
  replace c( mean f7102 lb ub) f(1.1) svy sum


*Consumo actual de tabaco
*f7103 Ha fumado en los ultimos 30 días
*Total**mujer**hombre*
svy: tabulate edrecadul f7103, row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7103, subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7103, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por subregión
svy: tabulate subreg f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por área
svy: tabulate area f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por zona de planificación
svy: tabulate zonas_planificacion f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por quintil economico
svy: tabulate quint f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por grupo étnico
svy: tabulate gr_etn f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de tabaco, por provincia
svy: tabulate provincia f7103, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)

*Frecuencia del consumo de tabaco ***
*f7104rec Con que frecuencia fuma recodificada

*Total**mujer**hombre**
gen f7104rec=f7104
recode f7104rec (1=1) (2/5=0) (6/max=.)
lab def f7104re 1 "diariamente" 0 "otra frecuencia"
lab val f7104rec f7104re

svy: tabulate edrecadul f7104rec, ///
  subpop(if (f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7104rec, ///
  subpop(if (pd02==2 & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7104rec, ///
  subpop(if (pd02==1 & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
*Por estratos
*Prevalencia de frecuencia del consumo de tabaco, por subregión
svy: tabulate subreg f7104rec, ///
  subpop (if (edrecadul!=. & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por área
svy: tabulate area f7104rec, ///
  subpop (if (edrecadul!=. & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por quintil economico
svy: tabulate quint f7104rec, ///
  subpop (if (edrecadul!=. & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por grupo étnico
svy: tabulate gr_etn f7104rec, ///
  subpop (if (edrecadul!=. & f7103==1 & f7104!=5)) row ci cv obs format(%17.4f)

*Prevalencia de exfumadores
*Variable exfumadores:
gen exfum=f7104
recode exfum (5 = 0) (1/4=1)
lab var exfum "ex fumadores"
lab def exfumadores 0 "exfumador" 1 "fumador"
lab val exfum exfumadores

*Total**mujer**hombre**
svy: tabulate edrecadul exfum, row ci cv obs format(%17.4f)
svy: tabulate edrecadul exfum, subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul exfum, subpop(if (pd02==1)) row ci cv obs format(%17.4f)
*Por estratos
*Prevalencia de frecuencia del consumo de tabaco, por subregión
svy: tabulate subreg exfum, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por área
svy: tabulate area exfum, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por quintil economico
svy: tabulate quint exfum, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por grupo étnico
svy: tabulate gr_etn exfum, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de frecuencia del consumo de tabaco, por provincia
svy: tabulate provincia exfum, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)

*Estadisticas descriptivas del promedio de cigarrillos fumados por día
sum f71051 [aw=pw] if(f7103==1 & edrecadul!=.), detail
svy : mean f71051, subpop (if(f7103==1 & edrecadul!=.))
bysort edrecadul: sum f71051 [aw=pw] if(f7103==1 & edrecadul!=.), detail
tabout edrecadul if(f7103==1 & edrecadul!=.) using pb.txt, ///
  replace c( mean f71051 lb ub) f(1.1) svy sum
* Femenino
bysort edrecadul: sum f71051 [aw=pw] if(f7103==1 & edrecadul!=. & pd02==2),detail
tabout edrecadul if(f7103==1 & edrecadul!=. & pd02==2) using pb.txt, ///
  replace c( mean f71051 lb ub) f(1.1) svy sum
* Masculino
bysort edrecadul: sum f71051 [aw=pw] if(f7103==1 & edrecadul!=. & pd02==1),detail
tabout edrecadul if(f7103==1 & edrecadul!=. & pd02==1) using pb.txt, ///
  replace c( mean f71051 lb ub) f(1.1) svy sum
* Quintil
bysort quint: sum f71051 [aw=pw] if(f7103==1 & edrecadul!=.), detail
tabout quint if(f7103==1 & edrecadul!=.) using pb.txt, ///
  replace c( mean f71051 lb ub) f(1.1) svy sum

********************************************************************************
*Prevalencia de vida de consumo de alcohol
*f7201 = ha consumido alguna bebida que contenga alcohol, alguna vez en su vida?
*Total**mujer**hombre**
svy: tabulate edrecadul f7201, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7201, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadul f7201, subpop(if (pd02==1)) row ci obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por subregión *
svy: tabulate subreg f7201, subpop (if (edrecadul!=.)) row ci obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por área
svy: tabulate area f7201, subpop (if (edrecadul!=.)) row ci obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por zona de planificación
svy: tabulate zonas_planificacion f7201, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por quintil economico
svy: tabulate quint f7201, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por grupo étnico
svy: tabulate gr_etn f7201, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de vida de consumo de alcohol, por provincia
svy: tabulate provincia f7201, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)

*Edad de inicio de consumo de alcohol
*Variable categorica para consume actual:
gen f7203rec=f7203
recode f7203rec(1/30=1)
lab var f7203rec "Bebe actualmente"
lab def f7203rec 0 "No" 1 "Si"
lab val f7203rec f7203rec

svy: tabulate pd02 f7203rec, ///
  subpop(if (f7203rec==1)) row ci cv obs format(%17.4f)

**Estadistica descriptiva de edad de inicio de consumo de alcohol

replace f7202=. if f7202==77
sum f7202 [aw=pw] if(f7203rec==1 & edrecadul!=.), detail
svy : mean f7202, subpop (if(f7203rec==1 & edrecadul!=.))
bysort edrecadul: sum f7202 [aw=pw] ///
  if(f7203rec==1 & edrecadul!=.), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=.) using pb.txt, ///
  replace c( mean f7202 lb ub) f(1.1) svy sum
* Mujer
bysort edrecadul: sum f7202 [aw=pw] ///
  if(f7203rec==1 & edrecadul!=. & pd02==2), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=. & pd02==2) using pb.txt, ///
  replace c( mean f7202 lb ub) f(1.1) svy sum
* Hombre
bysort edrecadul: sum f7102 [aw=pw] ///
  if(f7203rec==1 & edrecadul!=. & pd02==1), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=. & pd02==1) using pb.txt, ///
  replace c( mean f7202 lb ub) f(1.1) svy sum

******************************************
*Prevalencia del consumo actual de alcohol

*f7203rec = Ha consumido alguna bebida que contenga
*Alcohol en los ultimos 30 días / Bebe actualmente.
*Total**mujer**hombre**
svy: tabulate edrecadul f7203rec, subpop(if (pd02)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7203rec, subpop(if (pd02==2)) row ci obs format(%17.4f)
svy: tabulate edrecadul f7203rec, subpop(if (pd02==1)) row ci obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por subregión
svy: tabulate subreg f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por área
svy: tabulate area f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por zona de planificación
svy: tabulate zonas_planificacion f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por quintil economico
svy: tabulate quint f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por grupo étnico
svy: tabulate gr_etn f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)
*Prevalencia de consumo actual de alcohol, por provincia
svy: tabulate provincia f7203rec, ///
  subpop (if (edrecadul!=.)) row ci cv obs format(%17.4f)

***Estadistica descriptiva del N° de días que consume alcohol ultimos 30 días
sum f7203 [aw=pw] if(f7203rec==1 & edrecadul!=.), detail
svy : mean f7203, subpop (if(f7203rec==1 & edrecadul!=.))
bysort edrecadul: sum f7203 [aw=pw] if(f7203rec==1 & edrecadul!=.), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=.) using pb.txt, ///
  replace c( mean f7203 lb ub) f(1.1) svy sum
* Femenino
bysort edrecadul: sum f7203 [aw=pw] ///
  if(f7203rec==1 & edrecadul!=. & pd02==2), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=. & pd02==2) using pb.txt, ///
  replace c( mean f7203 lb ub) f(1.1) svy sum
* Masculino
bysort edrecadul: sum f7203 [aw=pw] ///
  if(f7203rec==1 & edrecadul!=. & pd02==1), detail
tabout edrecadul if(f7203rec==1 & edrecadul!=. & pd02==1) using pb.txt, ///
  replace c( mean f7203 lb ub) f(1.1) svy sum



*Cantidad de alcohol consumido por semana: approximacion con el
*n° de tragos consumidos declarados
*Corrección  datos de días duplicados, solo se retiene declaraciones con
*siete dias consecutivos declarados
generate f7204vald = 0
replace f7204vald = 1 if (f7204lu1!=. & f7204ma1!=. & f7204mi1!=. & ///
  f7204ju1!=. & f7204vi1!=. & f7204sa1!=. & f7204do1!=.)
replace f7204vald = 2 if (f7204vald!=1 & f7204ma1!=. & f7204mi1!=. & ///
  f7204ju1!=. & f7204vi1!=. & f7204sa1!=. & f7204do1!=. & f7204lu2!=.)
replace f7204vald = 3 if (f7204vald>0 & f7204mi1!=. & f7204ju1!=. & ///
  f7204vi1!=. & f7204sa1!=. & f7204do1!=. & f7204lu2!=.& f7204ma2!=.)
replace f7204vald = 4 if (f7204vald>0 & f7204ju1!=. & f7204vi1!=. & ///
  f7204sa1!=. & f7204do1!=. & f7204lu2!=.& f7204ma2!=. & f7204mi2!=.)
replace f7204vald = 5 if (f7204vald>0 & f7204vi1!=. & f7204sa1!=. & ///
  f7204do1!=. & f7204lu2!=.& f7204ma2!=. & f7204mi2!=. & f7204ju2!=.)
replace f7204vald = 6 if (f7204vald>0 & f7204sa1!=. & f7204do1!=. & ///
  f7204lu2!=. & f7204ma2!=. & f7204mi2!=.& f7204ju2!=. & f7204vi2!=.)
replace f7204vald = 7 if (f7204vald>0 & f7204do1!=. & f7204lu2!=. & ///
  f7204ma2!=. & f7204mi2!=. & f7204ju2!=.& f7204vi2!=. & f7204sa2!=.)

*Correcion Lunes :
global y f7204lu2 f7204ma2 f7204mi2 f7204ju2 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==1)
}
*Correcion Martes :
global y f7204lu1 f7204ma2 f7204mi2 f7204ju2 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==2)
}
*Correcion Miercoles :
global y f7204lu1 f7204ma1 f7204mi2 f7204ju2 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==3)
}
*Correcion Jueves :
global y f7204lu1 f7204ma1 f7204mi1 f7204ju2 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==4)
}
*Correcion Viernes :
global y f7204lu1 f7204ma1 f7204mi1 f7204ju1 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==5)
}
*Correcion Sabado:
global y f7204lu1 f7204ma1 f7204mi1 f7204ju1 f7204vi1 f7204sa2 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==6)
}
*Correcion Domingo :
global y f7204lu1 f7204ma1 f7204mi1 f7204ju1 f7204vi1 f7204sa1 f7204do2
foreach V of global y {
replace `V'=. if (f7204vald==7)
}

*Convertir los datos 0 a missing
global y f7204lu1 f7204ma1 f7204mi1 f7204ju1 f7204vi1 f7204sa1 f7204do1 ///
  f7204lu2 f7204ma2 f7204mi2 f7204ju2 f7204vi2 f7204sa2 f7204do2
foreach V of global y {
replace `V'=0 if (`V'==.)
}

*Las variables que son suma de cada
generate f7204lu = f7204lu1 + f7204lu2
generate f7204ma = f7204ma1 + f7204ma2
generate f7204mi = f7204mi1 + f7204mi2
generate f7204ju = f7204ju1 + f7204ju2
generate f7204vi = f7204vi1 + f7204vi2
generate f7204sa = f7204sa1 + f7204sa2
generate f7204do = f7204do1 + f7204do2

*Corrección de valores 0 por missing
global y f7204lu f7204ma f7204mi f7204ju f7204vi f7204sa f7204do
foreach V of global y {
	replace `V'=. if (f7204vald==0)
	}
*Consumo de alcohol en la ultima semana
*General: variable de suma
gen f7204sum = f7204lu+ f7204ma+ f7204mi+ f7204ju+ f7204vi+ f7204sa+ f7204do
*Recode
gen f7204act = f7204sum
recode f7204act (0=0) (1/max=1)
lab var f7204act "bebio en la ultima semana"
lab def er 0 "No" 1 "si"
lab val f7204act er
*Total**mujer**hombre**
svy: tabulate edrecadul f7204act, row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7204act, ///
  subpop(if (pd02==2)) row ci cv obs format(%17.4f)
svy: tabulate edrecadul f7204act, ///
  subpop(if (pd02==1)) row ci cv obs format(%17.4f)

*Generación de cuadros para descriptiva estadistica
global y f7204lu f7204ma f7204mi f7204ju f7204vi f7204sa f7204do
foreach V of global y {
	sum `V' [aw=pw] if(f7204act==1), detail
	svy : mean `V', subpop (if(f7204act==1))
		}
*Por decenios
global y f7204lu f7204ma f7204mi f7204ju f7204vi f7204sa f7204do
foreach V of global y {
	bysort edrecadul: sum `V' [aw=pw] if(f7204act==1), detail
	tabout edrecadul if(f7204act==1) using pb.txt, ///
	  replace c( mean `V' lb ub) f(1.1) svy sum
	}
*Por sexo
global y f7204lu f7204ma f7204mi f7204ju f7204vi f7204sa f7204do
foreach V of global y {
	bysort pd02: sum `V' [aw=pw] if(f7204act==1), detail
	tabout pd02 if(f7204act==1) using pb.txt, ///
	  replace c( mean `V' lb ub) f(1.1) svy sum
	}


*** DIAS DE CONSUMO DE ALCOHOL ULTIMOS 7 DIAS ***
gen f7204lurec = f7204lu
recode f7204lurec (0=0) (1/max=1)
gen f7204marec = f7204ma
recode f7204marec (0=0) (1/max=1)
gen f7204mirec = f7204mi
recode f7204mirec (0=0) (1/max=1)
gen f7204jurec = f7204ju
recode f7204jurec (0=0) (1/max=1)
gen f7204virec = f7204vi
recode f7204virec (0=0) (1/max=1)
gen f7204sarec = f7204sa
recode f7204sarec (0=0) (1/max=1)
gen f7204dorec = f7204do
recode f7204dorec (0=0) (1/max=1)
gen f7204recsum = f7204lurec+ f7204marec+ f7204mirec+ ///
  f7204jurec+ f7204virec+ f7204sarec+ f7204dorec
** Estadistica descriptiva
sum f7204recsum [aw=pw] if(f7204act==1), detail

*Análisis de Factores de riegos ensanut 2012 termina ahí***********************
