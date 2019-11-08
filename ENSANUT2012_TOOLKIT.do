********************************************************************************
* ENCUESTAS DE SALUD REPRODUTIVA ENSANUT-ECU 2012
* MINISTERIO DE SALUD PUBLICA DEL ECUADOR
* TOOLKIT PARA LA GENERACION DE VARIABLES EN LOS COMPONENTES DE:
*i Analisis de Fecundidad,
*ii Caracteristicas de la vivienda, del hogar y miembros del hogar,
*iii Salud Materna,
*iv Caracteristicas de las mujer en edad fertil y de los nacidos vivos de julio
*2007 a junio 2012,
*v Planificacion familiar,
*vi Mujeres que no usan anticonceptivos,
*vii Factores que influyen en la busqueda de atencion para el parto y las
*complicaciones obstetricas,
*viii Mortalidad infantil y en la ninez,
*ix Salud del nino/a,
*x Actividad sexual y salud reproductiva en mujeres de 15 a 24 anios,
*xi Infecciones de transmision sexual y VIH Sida,
*xii Uso de servicios de salud,
*xiii Gastos en salud
*Creado el: 05/03/2015
********************************************************************************
********************************************************************************
*Coordinadora de la Investigacion ENSANUT 2011-2014: Wilma Freire.
*Investigadores y autores del informe:
*  Elaboracion: Katherin Silva, Gabriela Rivas, Maria Jose Ramirez,
*  Pamela Pineiros, Philippe Belmont Guerron philippebelmont@gmail.com
********************************************************************************
********************************************************************************
/*
Coordinadora de la Investigacion ENSANUT 2011-2014: Wilma Freire.
Investigadores y autores del informe:
  Elaboracion: Philippe Belmont Guerron, MSP-ENSANUT philippebelmont@gmail.com
  Gabriela Rivas Marino gabrielarm19@gmail.com
  Aprobacion: Wilma Freire

Para citar esta sintaxis en una publicacion usar:
Freire, W.B., P. Belmont, G. Rivas-Marino, A. Larrea, M-J. Ramirez-Luzuriaga,
M.K. Silva-Jaramillo, and C. Valdivia. Tomo II Encuesta Nacional de Salud y Nutricion,
Salud Sexual y Reproductiva. ENSANUT-ECU 2012. Quito, Ecuador: MSP / INEC, 2015.

A BibTeX entry for LaTeX users is
@book{freire_tomo_2015,
	address = {Quito, Ecuador},
	title = {Tomo {II} {Encuesta} {Nacional} de {Salud} y {Nutricion},
        {Salud} {Sexual} y {Reproductiva}. {ENSANUT}-{ECU} 2012},
	language = {Es},
	publisher = {MSP / INEC},
	author = {Freire, W.B. and Belmont, P. and Rivas-Marino, G. and Larrea,
        A. and Ramirez-Luzuriaga, M-J. and Silva-Jaramillo, M.K. and Valdivia, C.},
	year = {2015}
}}

*/
******************************************************************************
*Nota al usuario: para usar la siguiente sintaxis el usuarios tiene que definir
*  el directorio de trabajo donde deben estar previamente ubicadas las bases
*  de datos de la ENSANUT-ECU 2012 en el commando siguiente:
cd ""
*p.e. "c:\ENSANUT2012\bases de datos\"

******************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013***************
*********************Tomo 2***************************************************
********************I.Fecundidad**********************************************
******************************************************************************
clear all
set more off
set matsize 8000
set seed 86915
*Paquete de analisis de fecundidad
ssc install tfr2
*Preparacion de bases
use ensanut_f2_mef.dta,clear
*Identificador de personas / Hogar / vivienda
drop id*
gen double idhog=ciudad*10^9+zona*10^6+sector*10^3+vivienda*10+hogar
format idhog %20.0f
gen double idviv=ciudad*10^8+zona*10^5+sector*10^2+vivienda
format idviv %20.0f
gen idptemp=hogar*10^2+persona
egen  idpers=concat (idviv idptemp),format(%20.0f)
drop idptemp
*Identificador de sector
gen double idsector = ciudad*10^6+zona*10^3+sector
lab var idviv "Identificador de vivienda"
lab var idpers "Identificador de persona"
lab var idsector "Identificador de sector"
lab var idhog "Identificador de hogar"

*Merge de variables de cruce
merge 1:1 idpers using ensanut_f1_personas.dta, keepusing (pd04c* dia mes ///
  anio provincia gr_etn quint subreg zonas_planificacion pd19* pa07 pa01)
drop if _merge ==2
drop _merge
*Fecha de entrevista y fecha nacimiento
merge 1:1 idhog using ensanut_f1_informacion_general.dta,keepusing(dia mes anio)
drop if _merge ==2
drop _merge
*Svyset para calculos considerando el diseno complejo
svyset idsector [pweight=pw], strata (area)

*Situacion de empleo sit_e
gen sit_e=pa07
replace sit_e=3 if pa01==6 | pa01==7
lab def sit_e 1 "Dentro del hogar" 2 "Fuera del hogar " 3 "No trabaja"
lab val sit_e sit_e
lab var sit_e "Situacion de empleo"
gen n=1

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"
recode f2700 (1=1 "casada") (2=2 "unida") ///
  (3/4=3 "separada o divorciada")  (5=4 "viuda") (6=5 "soltera"), gen(f2700r)
replace f2700r=3 if f2701==1
lab var f2700r "Estado civil recodificado"

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/203 401/406 600/607=2 "Primaria") ///
  (701/703 501/506 608/610 =3 "Secundaria") ///
  (801/803 901/908 1001/1003=4 "Superior"),gen(educa)
lab var educa "Nivel de instruccion 4 categorias"
*Nivel de educacion (INEC)
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/903 904/908 1001/1003 =6 "Educacion superior"),gen(educ2)
lab var educ2 "Nivel de instruccion"

*Grupos de edad (edad actual)
recode f2101 (12/14=1 "12/14") (15/19=2 "15/19") ///
  (20/24=3 "20/24") (25/29=4 "25/29") (30/34=5 "30/34") ///
  (35/39=6 "35/39") (40/44=7 "40/44") (45/49=8 "45/49") ,gen(gedad)
lab var gedad "Grupos de edad"
recode gedad (1=.),gen(gedad2)
lab val gedad2 gedad
lab var gedad2 "Grupos de edad"

******Fechas en formato CMC
rename f2160* f216*
*Missing values year
foreach y of varlist f216*b3 f2100c {
	replace `y'=. if `y'>2013 & `y'<7777
	replace `y'=. if `y'<f2100c & `y'<7777
	}
*Fecha nacimeinto y visita en mes
gen dov_cmc=(2012-1900)*12+7
gen dob_cmc=(f2100c-1900)*12+f2100b
*Edad del ninos CMC
foreach x of numlist 1/10 {
	gen f216`x'b_cmc = (f216`x'b3-1900)*12+f216`x'b2 ///
	  if f216`x'b3!=9999 & f216`x'b2!=99
	replace f216`x'b_cmc = (f216`x'b3-1900)*12+6 ///
	  if f216`x'b3!=9999 & f216`x'b2==99
	lab var f216`x'b_cmc "Edad del ninos `x' en CMC"
	}

*Limites de observacion 5 anios
gen lsup=(2012-1900)*12+7
gen linf=(2007-1900)*12+6
cap gen nh5=0
foreach x of numlist 1/10 {
	replace nh5=nh5+1 if f216`x'b_cmc>linf & f216`x'b_cmc<lsup
	}

*Intervalo del nacimiento anterior
forvalues y=1/9  {
	local z=`y'+1
	gen intp`y' = f216`y'b_cmc-f216`z'b_cmc
	replace intp`y' = . if (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	local w=`y'+2
	cap replace intp`y' = f216`y'b_cmc-f216`w'b_cmc if intp`y'==0
	replace intp`y' = . if intp`y'==0 & (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	replace intp`y' = . if f216`y'b_cmc<linf | f216`y'b_cmc>lsup
	}

*Fecha de fallecimiento del nino
foreach x of numlist 1/10 {
	gen f216`x'e_cmc = (f216`x'e2-1900)*12+f216`x'e1 ///
	  if f216`x'e2!=9999 &  f216`x'e1!=99
	replace f216`x'e_cmc = (f216`x'e2-1900)*12+6 ///
	  if f216`x'e2!=9999 &  f216`x'e1==99
	lab var f216`x'e_cmc "Edad nino `x' al fallecer en CMC"
	}

********************************************************************************
*Numero de nacidos vivos
recode f2215 (10/max=10 "10 o mas"),gen(nnv)
replace nnv =0 if f2205==2
lab var nnv "Numero de nacidos vivos"
recode  f2215 (6/max=6 "6 o mas"), gen(nhv)
replace nhv =0 if f2205==2
lab var nhv "numero de hijos nacidos vivos"

********************
*Edades medias y eventos de primera union, relacion sexual y primer nacimiento
*Edad de la Primer Union
cap gen funage = f2710
replace funage = f2713 if f2713 !=.
replace funage=100 if (est_civ==2)
replace  funage=999 if (funage==77)
lab var funage "Edad a la Primera Union"

foreach x of numlist 15 18 20 22 25{
	gen pu`x'=(funage>0 & funage<`x')*100 if funage!=. & funage!=999
	lab var pu`x' `"Edad primera union antes de los `x'"'
	}
gen puever=(funage>0 & funage<100)*100 if funage!=. & funage!=999
lab var puever "Alguna vez unida"
gen punever=(funage!=. & funage==100)*100 if funage!=. & funage!=999
lab var punever "Soltera / sin union"

*Edad a la primera relacion sexual fsexage
*12 a 14 y de 15 a 24 anios
cap gen fsexage=f2605 if (f2600==1|f2600==2) & f2605<=24 & f2605!=.
replace fsexage=100 if (f2600==1|f2600==2) & f2603==2 & f2603!=.
replace fsexage=999 if (f2600==1|f2600==2) & f2605>24 & f2605!=.
*25 a 49 anios
replace fsexage=f2638 if (f2600==3 & f2638>=4 & f2638 <= 49)
replace fsexage=999 if (f2600==3 & f2638>=4 & f2638 >49 & f2638!=.)
replace fsexage=100 if (f2637a==22)
lab var fsexage "Edad a la Primera Relacion Sexual"

foreach x of numlist 15 18 20 22 25{
	gen ps`x'=(fsexage>0 & fsexage<`x')*100 if fsexage!=. & fsexage!=999
	lab var ps`x' `"Edad primera relacion sexual antes de los `x'"'
	}
gen psever=(fsexage>0 & fsexage<100)*100 if fsexage!=. & fsexage!=999
lab var psever "Alguna vez unida"
gen psnever=(fsexage!=. & fsexage==100)*100 if fsexage!=. & fsexage!=999
lab var psnever "Soltera"

*Edad al primer nacimiento fbirage
gen mnaccmc=12*f2100c + f2100b
gen fbmes=.
gen fbano=.
forvalues i=1/10 {
	replace fbmes=f216`i'b2  if (f2215==`i')
	replace fbano=f216`i'b3  if (f2215==`i')
	}
gen phijocmc=12*fbano + fbmes if (fbano>=1979 & fbano<=2012 & fbmes!=.)
replace phijocmc=12*fbano + 6 if (fbano >= 1979 & fbano <=2012 & fbmes==.)
cap gen fbirage=100 if (f2215==0 | f2215==.)
replace fbirage=int((phijocmc-mnaccmc)/12) if (fbano >= 1979 & fbano <=2012)
replace fbirage=999 if (fbano<1979)
replace fbirage = 999 if f2215 > 10 & f2215!=.
replace fbirage=999 if (f2100b==77 & f2100c==7777)
lab var fbirage "Edad al primer nacimiento"

foreach x of numlist 15 18 20 22 25{
	gen pn`x'=(fbirage>0 & fbirage<`x')*100 if fbirage!=. & fbirage!=999
	lab var pn`x' `"Edad al primer nacimiento < a los `x'"'
	}
gen pnever=(fbirage>0 & fbirage<100)*100 if fbirage!=. & fbirage!=999
lab var pnever "No ha tenido parto"
gen pnnever=(fbirage!=. & fbirage==100)*100 if fbirage!=. & fbirage!=999
lab var pnnever "Soltera"
lab var pnever "Ha tenido nacimiento"

gen  putiempo=funage if funage!=999
replace putiempo = f2101 if funage == 100
replace putiempo=putiempo+uniform()
recode funage (100=0) (else=1),gen(pustatus)

gen pstiempo=fsexage if fsexage!=999
replace pstiempo = f2101 if fsexage == 100
replace pstiempo=pstiempo+uniform()
recode fsexage (100=0) (else=1),gen(psstatus)

gen pntiempo=fbirage if fbirage!=999
replace pntiempo = f2101 if fbirage == 100
replace pntiempo=pntiempo+uniform()
recode fbirage (100=0) (else=1),gen(pnstatus)

*Numero de veces una o mas que una que ha estado casada o unida
recode funage (0/14=1 "Menos de 15a") (15/17=2 "15-17a") (18/20=3 "18-20a") ///
  (21/22=4 "21-22a")(22/50=5 "Mas de 22a") (100=.) ///
  (nonmissing=6 "NSNR") , gen(fued)
lab var fued "Edad a la primera union"

*Actividad sexual reciente
*Cmc del ultimo hijo
gen hijoulcmc=(f2161b3-1900)*12+f2161b2 if f2161b3!=9999 & f2161b2!=99
gen acs_dia=f2639a+f2639b*7+f2639c*30+f2639d*365 if f2639d<55 & f2200!=1
replace acs_dia=(dov_cmc-hijoulcmc+9)*30 if (f2639a==55 & f2200!=1 & f2700r!=1)
replace acs_dia=-4 if f2639a==55 & f2200!=1 & (f2700r==1|f2700r==2)
replace acs_dia=-2 if f2603==2 | f2637a==22
replace acs_dia=-1 if (f2639a==77 | f2639a==99 | f2605==333 | acs_dia==.)
replace acs_dia=-3 if f2200==1
recode acs_dia (0/6=1 "< 1semana") (7/13=2 "1 semana") ///
  (14/29=3 "2 a 3 semanas") (30/89=4 "1 a 2 meses") (90/359=5 "3 a 11 meses") ///
  (360/max=6 "12 o mas meses") (-1=7 "NS/NR") (-2=8 "Nunca ha tenido relsex") ///
  (-3=9 "Embarazada") (-4=10 "abstinencia postparto"), gen(turs)
lab var turs "Tiempo desde la ultima relacion sexual"

********************
*Numero de veces unida
gen n_union=1 if f2700r!=5 & (f2708==1 | f2711==1)
replace n_union=2 if f2700r!=5 & (f2708==2 | f2711==2)
lab var n_union "Numero de uniones"
lab def n_union 1 "Una vez" 2 "Mas de una vez"
lab val n_union n_union

********************
*Deseo actual de hijos/as de mujeres unidas en edad fertil
recode f2501 (1 = 1 "Quiere tener hijos") (2 = 2 "No quiere mas hijos") ///
  (5 88 = 3 "Indecisa") (else = .), gen(des)
lab var des "Deseo actual de hijos/as"

*Fechas de nacimiento para tasas global de fecundidad (TGF) deseada y no deseada
forvalues x=1/4 {
	gen f216`x'sdes=f216`x'b_cmc if f4104`x'==1
	gen f216`x'ndes=f216`x'b_cmc if f4104`x'==2
	}
*Region simplificada
recode subreg (1/2 8=1 "Sierra") (3/4 9=2 "Costa") ///
  (5/6=3 "Amazonia") (else=.),gen(region)
lab var region "Region"
*Provincia total
gen prv=int(ciudad/10000)
lab var prv "provincia"
lab val prv pro
********************************************************************************
tfr2 [pweight=pw], bvar(f216*b_cmc) dates(dov_cmc) ///
  wbirth(dob_cmc) ageg(5) len(5) gr se
tabexp	[pweight=pw], bvar(f216*b_cmc) dates(dov_cmc) ///
	  wbirth(dob_cmc) ageg(5) len(5)
********************************************************************************
*Mujeres de 15 a 49 anios de edad que tuvieron la primera relacion
*sexual, primera union y primer nacimiento antes de cumplir las edades
*especificas, segun edad actual
foreach x in ps pu pn {
	cap matrix def res=(1519\2024\2529\3034\3539\4044\4549\9999)
	foreach y in 15 18 20 22 25 ever never {
		svy: mean `x'`y', over(gedad2)
		matrix q=(e(_N_subp)/1000 \ e(_N) \r(table))'
		svy: mean `x'`y'
		matrix q=q \ (e(_N_subp)/1000 \ e(_N) \r(table))'
		matrix q=q[1... ,1..3] , q[1... ,7..8]
		matrix res = res , q
		matrix drop q
		}
	matrix drop _all
	}
mat li res
foreach x in  ps pu pn {
	di "MEDIANA DE `x' POR GRUPOS DE EDAD"
	cap stset `x'tiempo [pweight=pw], fail(`x'status==1)
	stsum , by(gedad2) nosh
	}
********************************************************************************
*Duracion promedio meses de la amenorrea postparto, abstinencia
*sexual postparto y del periodo no susceptible para embarazarse
use ensanut_f4_salud_ninez.dta, clear
set seed 384737

*Edad del hijo
gen dov=anio*12 + mes
gen dob=pd04c*12 + pd04b if pd04c!=9999 & pd04b!=99
replace dob=pd04c*12+int((12-1.0001)*runiform()+1.0001) ///
  if pd04c!=9999 & pd04b==99
gen edn_cmc=dov-dob

*Correccion por dia de nacimiento ENDEMAIN 2004
gen  birthday=pd04a  if pd04a < 99
replace edn_cmc=edn_cmc-1  if (dia < birthday)

*Grupos de edad de la madre
gen edmn=int(f2101-(edn_cmc/12))
recode edmn (min/29 = 1 "Menor a 30 anios") ///
  (30/max = 2 "30 o mas anios") (999=.), gen(emn)
lab var emn "Edad de la madre al nacimiento"
recode edmn (min/19 = 1 "Menor a 20 anios") (20/29=2 "20-29") ///
  (30/39=3 "30-39") (40/49=4 "40-49") , gen(emn2)
lab var emn2 "Edad de la madre al nacimiento"

*Tiempo en que volvio el ciclo menstrual
gen amnpp=(f4504==23)
gen absex=(f4505==63)
gen nsusc= (f4504==23 | f4505==63)
gen totl=1

*Deseo de embarazo al nacimiento del nino
recode f4104 (1=1 "Deseado planeado") (2=2 "Deseado no previsto") ///
  (3/4=3 "No previsto"), gen(des)
lab var des "Deseo de embarazo del nino"

*Orden de nacimiento
sort idmadr edn_cmc
by idmadr: gen ord=_n
replace ord=f2215-ord+1
recode ord (1=1) (2/3=2 "2-3") (4/6=3 "4-6") (7/max=4 "7 o mas"), gen(ordn)
la var ordn "orden de nacimiento"

*Region simplificada
recode subreg (1/2 8=1 "Sierra") (3/4 9=2 "Costa") (5/6=3 "Amazonia") ///
  (else=.),gen(region)
lab var region "Region"

*Provincia total
gen prv=int(ciudad/10000)
lab var prv "provincia"
lab val prv pro

gen filtr= (f2101<15 | edn_cmc>59 | f4501==2 | est_civ!=1)
matrix drop _all
foreach iva of varlist area subreg gr_etn quint educa emn totl {
	levelsof `iva', local(levels)
	foreach iv of local levels{
		foreach x of varlist amnpp absex nsusc {
			preserve
			collapse (sum) `x' totl if filtr==0 & `iva' == `iv' [pw = pw], ///
			  by(edn_cmc)
			replace `x'=`x'/totl
			cap sum `x'
			mat A_`x' = nullmat(A_`x')\r(sum)
			restore
			}
		}
	cap total totl, over(`iva')
	mat A_`iva' = e(b)'
	mat A_uno = nullmat(A_uno)\A_`iva'
	}
mat A = A_amnpp, A_absex, A_nsusc , A_uno
matrix rownames A = Urb Rur SierraU Sierra_R Costa_U Costa_R Amazonia_U ///
  Amazonia_R Galapagos Guayaquil Quito Indigena Afroecuatoriano ///
  Montubio Mestizo/Otro Sin_instruccion_formal Hasta_primaria ///
  Hasta_secundaria Superior/postgrado Q1(Pobre) Q2 Q3(Intermedio) ///
  Q4 Q5(Rico) Menor_a_30_anos 30_o_mas_anos Total
matrix colnames A = Amenorrea_postparto Abstinencia_sexual_postparto ///
  Periodo_no_susceptible  No_de_casos
mat li A

*Analisis de Fecundidad ENSANUT 2012 termina ahi *****************************

******************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013****************
**************Tomo 1 *********************************************************
**************II. Caracteristicas del hogar **********************************
******************************************************************************
*Preparacion de la base de Personas con variabels de cruce
use ensanut_f1_personas.dta,clear
*Identificador de madre
cap gen idptemp=hogar*10^2+pd08b
cap egen  idmadre=concat (idviv idptemp),format(%20.0f)
cap drop idptemp
lab var idmadre "Identificador de madre"
******************************************************************************
*Caracteristicas generales del hogar y de la poblacion
*Edad en mes base Personas
*Fecha nacimiento en dias
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

*Anios de escolaridad (segun sintaxis NBI inec 2013)
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

*Variable de Grupo Etnico
cap gen gr_etn= pd13
replace gr_etn=1 if pd13==1
replace gr_etn=2 if (pd13==2 | pd13==3 | pd13==4)
replace gr_etn=3 if pd13==5
replace gr_etn=4 if (pd13==6 | pd13==7 | pd13==8)
label define etn 1 "Indigena" 2 "Afroecuatoriano" 3 "Montubio" ///
  4 "Resto de la Poblacion", replace
label values gr_etn etn

**Variable de Estado Civil
*Casado o union libre
cap gen estado_civil=1 if (pd14==1 | pd14==2)
*Soltero
replace estado_civil=2 if pd14==6
*Divorciado o separado
replace estado_civil=3 if (pd14==3 | pd14==4)
*Viudo
replace estado_civil=4 if pd14==5
label define eciv 1 "Casado o union libre" 2 "Soltero" ///
  3 "Divorsiado o separado" 4 "Viudo", replace
label values estado_civil eciv

********************************************************************************
*Variable de provincias y subregiones
*Variable de Dominios 26 (90150 / 170150 +15 km ag pot> 45% )
*Con el fin de abarcar el area de influencia de las ciudades de Quito y
*Guayaquil, se incluyeron ademas de la division politico-administrativa
*parroquial los sectores urbanizados (criterio: % de agua potable >45%) hasta
*una distancia de 15 km de limite parroquial.
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
label define pro 1 "Azuay" 2 "Bolivar" 3 "Canar" 4 "Carchi" 5 "Cotopaxi" ///
  6 "Chimborazo" 7 "El Oro" 8 "Esmeraldas" 9 "Guayas" 10 "Imbabura" 11 ///
  "Loja " 12 "Los Rios" 13 "Manabi" 14 "Morona Santiago" 15 "Napo" 16 ///
  "Pastaza" 17 "Pichincha" 18 "Tungurahua" 19 "Zamora Chinchipe" 20 ///
  "Galapagos" 21 "Sucumbios" 22 "Orellana" 23 "Sto Domingo dl Tsachilas" ///
  24 "Santa Elena" 25 "Quito" 26 "Guayaquil", replace
label values provincia pro

*Variable de Region / Subregion
*region= Sierra Urbana
cap gen subreg=1 if (area==1 & (provincia==1 | provincia==2 | provincia==3| ///
  provincia==4 | provincia==5 | provincia==6 | provincia==10| provincia==11| ///
  provincia==17 | provincia==18 | provincia==23))
replace subreg=2 if (area==2 & ( provincia==1 | provincia==2 | provincia==3| ///
  provincia==4 | provincia==5 | provincia==6 | provincia==10|provincia==11| ///
  provincia==17 | provincia==18 | provincia==23))
replace subreg=3 if (area==1 & (provincia==7 |provincia==8 | provincia==9| ///
  provincia==12 | provincia==13 | provincia==24))
replace subreg=4 if (area==2& (provincia==7 |provincia==8 | provincia==9| ///
  provincia==12 | provincia==13 | provincia==24))
replace subreg=5 if (area==1 & (provincia==14| provincia==15| provincia==16| ///
  provincia==19 | provincia==21 | provincia==22))
replace subreg=6 if (area==2 & (provincia==14| provincia==15| provincia==16| ///
  provincia==19 | provincia==21 | provincia==22))
 replace subreg=7 if ( provincia==20)
 replace subreg=8 if (provincia==25)
 replace subreg=9 if (provincia==26)
label define sbr 1 "Sierra Urbana" 2 "Sierra Rural" 3 "Costa Urbana" 4  ///
  "Costa Rural" 5 "Amazonia Urbana" 6 "Amazonia Rural" 7 "Galapagos" 8  ///
  "Quito" 9 "Guayaquil",replace
label value subreg sbr

*******************************************************************************
**Variable de Zonas de planificacion (9)
cap gen prov=int(ciudad/10000)
cap gen zonas_planificacion=1 if (prov==4 | prov==8 | prov==10 | prov==21)
replace zonas_planificacion=2 if (prov==15 | prov==17 | prov==22)
replace zonas_planificacion=3 if (prov==5 | prov==6 | prov==16 | prov==18)
replace zonas_planificacion=4 if (prov==13 | prov==23)
replace zonas_planificacion=5 if (prov==24|prov==9|prov==2|prov==12|prov==20)
replace zonas_planificacion=6 if (prov==1 | prov==3 | prov==14)
replace zonas_planificacion=7 if (prov==7 | prov==11 | prov==19)
replace zonas_planificacion=8 if (ciudad==90150 | ciudad==90156 | ///
  ciudad==90157 | ciudad==90750 | ciudad==91650 | ciudad==91651)
replace zonas_planificacion=9 if (ciudad==170150)
lab var zonas_planificacion "Zonas de Planificacion"
********************************************************************************
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
replace  vi02r=8 if vi02==6  | vi02==7
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
recode vi02r 5 8 = 8
lab def vi02r 1 "Casa o villa" 2 "Departamento en casa o apartamento" ///
  3 "Cuarto en casa de inquilinato" 4 "Mediagua" 8 "Otro"
lab val vi02r vi02r

*Analisis de caracteristicas de hogares ENSANUT 2012 termina ahi*************

******************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013****************
*********************Tomo 2***************************************************
*********************III. Salud Materna***************************************
******************************************************************************
*Indicadores relativos al parto de los ultimos hijos
****************************************
use ensanut_f4_salud_ninez.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)

*Variables de cruce
ren idpers idper
ren idmadre idpers
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(pd19*)
drop if _merge==2
drop _merge
merge m:1 idpers using ensanut_f2_mef.dta, keepusing(f2700 f2701 f2100*)
drop if _merge==2
drop _merge
ren idpers idmadre
ren idper idpers

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/max=6 "Superior/Postgrado"),gen(educa2)
lab var educa2 "Nivel de instruccion"

*Edad del nino
gen bcmc =(pd04c)*12+pd04b if pd04c!=9999 & pd04b!=99
replace bcmc = (pd04c)*12+6 if pd04c!=9999 & pd04b==99
gen vcmc=(anio)*12+mes
lab var vcmc "Fecha visita cmc"
lab var bcmc "Edad nino en CMC"

*Edad de la madre
gen mcmc=f2100c*12+f2100b if f2100c!=7777
lab var mcmc "Edad madre cmc"
*Edad de la madre al nacimiento
gen edmn= int((bcmc-mcmc)/12)
lab var edmn "Edad de la madre al nacimiento del hijo"
recode edmn (min/19=1 "<20") (20/29=2 "20 a 29") ///
  (30/39=3 "30 a 39") (40/49=4 "40 a 49"), gen(gedadm_n)
lab var gedadm_n  "Grupos de edad madre al nacimiento del hijo"
recode edmn (min/19=1 "<20") (20/24=2 "20 a 25") (25/29=3 "25 a 29") ///
  (30/34=4 "30 a 34") (35/39=5 "35 a 39") (40/49=6 "40 a 49"), gen(gedadm_n2)
lab var gedadm_n2  "Grupos de edad madre al nacimiento del hijo"

*Base Ninos menores de 5 anios:
gen inf=2007*12+7
gen sup=2012*12+6
drop if bcmc>sup | bcmc<inf

*Orden de nacimiento del nino
preserve
use ensanut_f2_mef.dta,clear
ren f2160* f216*
foreach x of numlist 1/10 {
	gen bcmc`x'=(f216`x'b3)*12+f216`x'b2 ///
	  if f216`x'b3!=9999 & f216`x'b2!=99
	replace bcmc`x'=(f216`x'b3)*12+6 if f216`x'b3!=9999 & f216`x'b2==99
	}
ren f216*a f216a*
keep bcmc* f216a* idpers f2215
reshape long f216a bcmc, i(idpers) j(ord)
rename idpers idmadre
ren f216a sexo
lab var sexo Sexo
drop if bcmc==.
*Orden de nac del nino
gen ord_n=f2215-ord+1
save f2_orden.dta,replace
restore
merge m:m idmadre bcmc using f2_orden.dta
drop if pw==.
drop _merge
erase f2_orden.dta
recode ord_n (min/1=1 "1ero") (2/4=2 "2do a 4to") (5/7=3 "5to a 7mo") ///
  (8/max=4 "8vo o mas" ), gen(ord_ni)
lab var ord_ni  "grupos orden del nacimiento"
recode ord_n (6/max=6 "6 o mas"), gen(ord_ni2)
lab var ord_ni2  "grupos orden del nacimiento"

********************************************************************************
*Trimestre de embarazo al primer control prenatal
recode f4203 (0/3 = 1 "Primero") (4/6 = 2 "Segundo") (7/9 = 3 "Tercero") ///
  (99=.) (else =4 "No tuvo control") if f4201 !=., gen(tr_pc)
lab var tr_pc "Fecha del primer control pre-natal segun trimestre de embarazo"
recode tr_pc (1/3=1 "Tuvo") (4=2 "No tuvo"), gen(rtr_pc)
*Numero de controles prenatales
recode f4204 (0/4 = 1 "1-4") (5/30=2 "5 o mas") (99 = .) ///
  (else =4 "No tuvo control") if f4201 !=., gen(no_cp)
label var no_cp "Numero de controles prenatales"
recode no_cp (1/3=1 "Tuvo") (4=2 "No tuvo"), gen(rno_cp)

*Cumplimiento de normas de atencion del control prenatal
gen cp_na = 0 if tr_pc !=. & no_cp !=.
replace cp_na = 1 if tr_pc == 1 & no_cp == 2
lab def sino 1 "Si" 0 "No"
lab val cp_na sino
label var cp_na "Cumplimiento de normas de atencion prenatal"

*Lugar de atencion prenatal
recode f4202  (1=1 "hospital maternidad msp") ///
  (2=2 "centros de salud similares msp") ///
  (3/4=3 "IESS SSC") (6=4 "junta beneficencia") ///
  (7=5 "consejo provincial unidad municipal") (8=6 "fundacion ong") ///
  (9=7 "clinica privada") (5 10/11=8  "Otro") (77/88=9 "NS NR "), gen(lu_ap)
lab var lu_ap "Lugar de atencion prenatal"

*Lugar de atencion al parto
recode f4301 (1=1 "hospital / maternidad msp") ///
  (2=2 "centros de salud / similares msp") (3/4=3 "IESS SSC") (5=4 "FFAA") ///
  (6=5 "junta de beneficencia") (7=6 "consejo provincial / unidad municipal") ///
  (8=7 "fundacion / ong") (9=8 "clinica / consultorio privado") ///
  (10=9 "en casa con partera") (11=10 "en casa con familiar") ///
  (12=11 "parto sola") (13=12 "Otro") (77/88=13 "NS NR"), gen(lu_pa)
lab var lu_pa "Lugar de atencion del parto"

*Profesional que atendio el parto
*tab f4302
*Tipo de parto vaginal o por cesarea
*f4303 Tipo de parto vaginal o cesarea

*Tiempo en dias al primer control postparto
gen tppp = f4502a + f4502b*7 + f4502c*30
replace tppp=999 if f4501==2
foreach x of varlist f4502*{
	replace tppp=888 if `x'==88|`x'==99
	}
recode tppp (0/40=1 "Menos de 41 dias") (41/375 = 2 "41 dias o mas") ///
  (888 = 3 "NS/NR") (999 = 4 "No tuvo control"), gen(tp_pp)
recode tppp (0/7=1 "hasta los 7 dias") (8/40 = 2 "de 8 a 40 dias") ///
  (41/375 = 3 "41 dias o mas") (888 = 4 "NS/NR") ///
  (999 = 5 "No tuvo control"), gen(tp_ppp)
drop tppp
lab var tp_pp "Tiempo trascurrido al primer control postparto"
lab var tp_ppp "Tiempo trascurrido al primer control postparto (7 dias)"
recode tp_pp (1/2=1 "tuvo") (nonmissing=2 "No tuvo"),gen (rtp_pp)
*Lugar de control postparto
recode f4503 (1=1 "hospital maternidad msp") ///
  (2=2 "centros de salud similares msp") ///
  (3/4=3 "hospital clinica dispensario iess") (5=4 "hospital FFAA") ///
  (7=5 "consejo provincial unidad municipal") (8=6 "fundacion ong") ///
  (9=7 "Hospital privado") (10 11 6=8 "Otro") (77/88=9 "NSNR"),gen(lu_pp)
label var lu_pp "Lugar de control postparto"

********************************************************************************
****************************************
*Indicadores relativos a la madre
****************************************
clear all
set more off
set matsize 8000
*Directorio de bases:
cd ""

use ensanut_f2_mef.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(dia mes anio provincia gr_etn quint ///
  subreg zonas_planificacion pd19*)
drop if _merge ==2
drop _merge

*Edad de las mujeres en edad fertil (MEF)
recode f2101 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(gr_ed)
lab var gr_ed "Grupos de edad por quiquenios"

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"

*Grupos de edad MEF
gen dmef=1 if f2101>=15 & f2101<=49
replace dmef=2 if dmef==.
lab def dmef 1 "15 a 49 anios" 2 "12 a 14 anios"
lab val  dmef dmef

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/908 1001/1003=6 "Superior/Postgrado"),gen(educa2)
lab var educa2 "Nivel de instruccion"
*Nivel educacion Simplificado
recode educa2 (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior"),gen (educa)
lab var educa "Nivel de instruccion 4 categorias"

*Hijos nacidos vivos
gen hnvda= f2215
replace hnvda =0 if f2205==2
replace hnvda = 6 if hnvda >= 6 & hnvda ~= .
lab var hnvda "Hijos nacidos vivos"
*Numero de embarazos
egen emb = rownonmiss(f2160*a)
replace emb=. if emb==0
replace emb=0 if f2205==2
recode emb (6/max=6)
lab def emb 6 "6 o mas"
lab val emb emb
lab var emb "Numero de embarazos"
********************************************************************************
*Recepcion de la vacuna contra el tetanos
gen vc_tt= f2323
replace vc_tt=4 if f2322 == 2
replace vc_tt=. if (vc_tt==99)
lab def vc_tt 1 "Una" 2 "Dos" 3 "3 o mas" 4 "No le han vacunado" ///
  88 "Recibio pero no sabe cuantas dosis"
lab val vc_tt vc_tt
label var vc_tt "Vacunacion para el tetanos"
recode  vc_tt (1/3=1 "Si tuvo") (nonmissing=2 "No tuvo"), gen(rvc_tt)

*Mujeres con experiencia sexual
gen f2603r=1
replace f2603r=2 if (f2603==2 | f2637a==22)
lab def f2603r 1 "Con experiencia sexual" 2 "Sin experiencia sexual"
lab val f2603r f2603r
lab var f2603r "Experiencia sexual 12-49 anios"

*Tiempo en meses desde que se hizo la ultima citologia
gen tpuc =int((f2328a + f2328b*7 + f2328c*30 + f2328d*365)/30)
foreach x of varlist f2328*{
	replace tpuc=-1 if `x'==77
	}
replace tpuc=-2 if f2326==2
replace tpuc=-3 if f2326==88|f2326==99
recode tpuc (-3=6 "NSNR")(-2=5 "Nunca tuvo citologia") (-1=4 "No recuerda") ///
  (0/11=1 "1-11meses") (12/23=2 "12-23meses") (24/max=3 "24 o mas") ///
  if (f2603r==1|f2603r==.), gen(tp_uc)
lab var tp_uc "Tiempo trascurrido desde la ultima citologia"
drop tpuc
recode tp_uc (1/3=1 "Si tuvo") (nonmissing=2 "No tuvo"),gen(rtp_uc)

*Lugar donde se hizo la ultima citologia vaginal
*f2330

*Razon principal para no hacerse alguna vez la citologia
recode f2331  (88/99 = 99), gen(rz_nc)
lab def f2331 9 "Otro" 99 "NS/NR", modify
lab val rz_nc f2331
lab var rz_nc "Razon principal para no hacerse alguna vez la citologia"

*Mujeres que han oido hablar del cancer de mama/realizacion de examen/autoexamen
*f2332 f2333 f2334 f2335

*Razon para no hacerse alguna vez el examen de mamografia
recode f2336 (88/99 = 88) , gen(rz_nm)
lab def f2336 88 "NS/NR" 8 "Otro" , modify
lab val rz_nm f2336
lab var rz_nm "Razon para no hacerse mamografia"

*Consumo de cigarrillos/ Ha fumado / fuma_actualmente
*f2337
recode f2338a (1/2=1) (else=.), gen(um_ac)
replace um_ac=2 if f2337!=. & um_ac!=1
lab def um_ac 1 "Fuma actualmente" 2 "No fuma actualmente"
lab val um_ac um_ac
lab var um_ac "Fuma actualmente"

*Cantidad de tabaco consumido
recode f2338b (1/4=1 "1-4") (5/9=2 "5-9") (10/19=3 "10/19") ///
  (20/max=4 "20 o mas"), gen(ct_cs)
replace ct_cs=5 if f2338a==2
replace ct_cs=6 if f2338a==88|f2338a==99
lab def ct_cs 5 "Fuma ocasionalmente" 6 "NSNR", modify
lab var ct_cs "Cantidad de tabaco consumido"

*Analisis de Salud materna ENSANUT 2012 termina ahi ****************************

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
**************Tomo 1 ***********************************************************
**************IV. Caracteristicas de las Mujeres en edad fertil ****************
**************MEF y de los NV de julio 2007 a junio 2012************************
********************************************************************************
*Caracteristicas de la Mujeres en edad fertil
clear all
set more off
********************************************************************************
use ensanut_f2_mef.dta,clear

*Svyset
svyset idsector [pweight=pw], strata (area)
*Variables de cruce
merge 1:1 idpers using "ensanut_f1_personas.dta", keepusing(provincia ///
  subreg zonas_planificacion gr_etn area pd02 pd03 quint  ///
  pse01 pse07a pa05 pa06 pa07 pd10a pd11a pd15 pd16 pd17 pd19a pd19b)
drop if _merge==2
drop _merge
********************************************************************************
*Grupos Edad 12 a 49
recode f2101 (min/14=1 "12 a 14") (15/49=2 "15 a 49"), gen(gedad1)
lab var gedad1 "grupos de edad mef de 12 a 49"
recode f2101  (15/19=2 "15 a 19") (20/24=3 "20 a 24") (25/29=4 "25 a 29") ///
  (30/34=5 "30 a 34") (35/39=6 "35 a 39") (40/44=7 "40 a 44") ///
  (45/49=8 "45 a 49"), gen(gedad2)
lab var gedad2  "grupos de edad mef de 15 a 49"

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=2 if f2701==1
lab var est_civ "Estado civil"
*Estado civil completo:
recode f2700 (1=1 "Casada") (2=2 "Unida") (3/4=3 "Divorciada Separada") ///
  (5=4 "Viuda") (6=5 "Soltera"), gen(est_cicom)
replace est_cicom=3 if f2701==1
lab var est_cicom "Estado civil completo"
*Hijos nacidos vivos
gen hnvda = f2215
replace hnvda = 6 if hnvda >= 6 & hnvda ~= .
replace hnvda =0 if f2205==2
*Tipos de seguro
recode pse01 (1/3=1 "Seguro social publico")  (4=3 "Sin seguro"), gen (pse1)
recode pse07a (1 5=2 "Privado") (2/4=1 "Publico")  (6=6 "no tiene"), gen (pse7a)
gen pse2= pse1*10 + pse7a
recode pse2 (11 16 31=1 "Publico unicamente") (12=2 "Publico y privado")  ///
  (32=3 "Privado unicamente") (36=4 "No tiene"), gen (psee)
drop pse1 pse7a pse2
lab var psee "Tipo de seguros"
*Situacion de empleo
gen sit_e=pa07
replace sit_e=3 if pa07==.
lab def sit_e 1 "Dentro del hogar" 2 "Fuera del hogar " 3 "No trabaja"
lab val sit_e sit_e
lab var sit_e "Situacion de empleo"
*Nivel de instruccion
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/max=6 "Superior/Postgrado"),gen(educ)
lab var educ "Nivel de instruccion"
*Nivel educacion Simplificado:
recode educ (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior"),gen (educa)
lab var educa "Nivel de instruccion 4 cat."
*Region
recode subreg (1/2 8=1 "Sierra") (3/4 9=2 "Costa") ///
  (5/6=3 "Amazonia" ) (7=4 "Insular" ), gen(region)
lab var region  "region"

********************************************************************************
*Caracteristicas de los Hijos nacidos vivos
clear all
set more off
********************************************************************************
use ensanut_f2_mef.dta,clear

*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (pd04* dia mes anio gr_etn area quint ///
  subreg zonas_planificacion prov pd03 pd19*)
drop if _merge ==2
drop _merge

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/203 401/406 600/607=2 "Primaria") ///
  (701/703 501/506 608/610 =3 "Secundaria") ///
  (801/803 901/908 1001/1003=4 "Superior"),gen(educa)
lab var educa "Nivel de instruccion 4 categorias"

*Total de ninos: hnvv+hnvm
gen hnv= f2215
lab var hnv "total de ninos nacidos vivos"

*Fecha de nacimiento y entrevista en meses:
gen dov=(2012)*12+7
gen dom=(f2100c)*12+f2100b if f2100c!=7777
*Renombrar
rename f2160* f216*
*Fecha de nacimiento del nino:
foreach x of numlist 1/10 {
	gen dob`x' = (f216`x'b3)*12+f216`x'b2 ///
	  if f216`x'b3!=9999 & f216`x'b2!=99
	replace dob`x' = (f216`x'b3)*12+6 ///
	  if f216`x'b3!=9999 & f216`x'b2==99
	lab var dob`x' "Edad del ninos `x' en CMC"
	}
*Limites de observacion 5 a:
gen lsup=(2012)*12+7
gen linf=(2007)*12+6
cap gen nh5=0
foreach x of numlist 1/10 {
	replace nh5=nh5+1 if dob`x'>linf & dob`x'<lsup
	}
replace dob1=. if dob1>lsup

*Intervalo del nacimiento anterior
forvalues y=1/9  {
	local z=`y'+1
	gen intp`y' = dob`y'-dob`z'
	replace intp`y' = . if (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	local w=`y'+2
	cap replace intp`y' = dob`y'-dob`w' if intp`y'==0
	replace intp`y' = . if intp`y'==0 & (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	replace intp`y' = . if dob`y'<linf | dob`y'>lsup
	}
*Por total de respuestas:
rename f216*a f216a*
rename f216*c f216c*
keep  intp* f216a* f216c* dob* hnv educa area est_civ idpers nh5 f2215 ///
  subreg prov zonas_pl idsector est_civ quint gr_etn pw dom dov linf lsup
reshape long intp f216a f216c dob, i(idpers) j(ord)
ren pw pwm
lab var pwm "factor de expansion de la madre"
egen nmiss=rmiss(f216* intp dob)
drop if nmiss==4 | dob<linf & dob!=. | dob>lsup & dob!=.
drop nmiss

*Hijos vivos descritos por madre
duplicates tag idpers, gen(hn5i)
replace hn5i=hn5+1
lab var hn5i "Ninos nv de 5 a"
replace pw=pw*nh5/hn5i
*Orden de nacimiento del nino
gen ord_n=f2215-ord+1
lab var ord_n "Orden de nacimiento del nino"
recode ord_n (min/1=1 "1ero") (2/4=2 "2do a 4to") (5/7=3 "5to a 7mo") ///
  (8/max=4 "8vo o mas" ), gen(ord_ni)
lab var ord_ni  "grupos orden del nacimiento"
*Svyset
svyset idsector [pweight=pw], strata (area)

*edad nino
gen age_n= int((dov- dob)/12)
*Intervalo de previo al nacimiento
recode intp (min/23=1 "< 24 meses") (24/47=2 "24 a 47") ///
  (48/max=3 "48 o mas" ), gen(ipn)
lab var ipn  "grupos intervalo previo al nacimiento en meses"
*Region
recode subreg (1/2 8=1 "Sierra") (3/4 9=2 "Costa") (5/6=3 "Amazonia" ) ///
  (7=4 "Insular" ), gen(region)
lab var region  "region"
*edad madre
gen age_m= int((dov-dom)/12)
*Edad de la madre al nacimiento
gen edmn= age_m-age_n
lab var edmn "Edad de la madre al nacimiento"

*Analisis de Caracteristicas de MEF e HV ENSANUT 2012 termina aqui**************


********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013*****************
*********************Tomo 2*****************************************************
*********************V. Planificacion Familiar**********************************
********************************************************************************
clear all
set more off
set matsize 8000
*Preparacion de bases
use ensanut_f2_mef.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (pd04* dia mes anio subreg provincia ///
  gr_etn area quint subreg zonas_planificacion pd19*)
drop if _merge ==2
drop _merge

*Grupos de Edad
recode f2101 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(gr_ed)
lab var gr_ed "Grupos de edad por quiquenios"
*Estado civil
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"
*Estado civil recodificado
recode est_civ (1=1 "Unida_casada") (2/3=2 "No unida"), gen(eciv)
lab var eciv "Estado civil"

*Grupos de edad MEF
gen dmef=(f2101>=15 & f2101<=49)
lab def dmef 0 "12 a 14 anios" 1 "15 a 49 anios"
lab val  dmef dmef

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/903 =6 "Hasta 3 anios de educacion superior") ///
  (904/908=6 "4 o mas anios de educacion superior (sin post grado)") ///
  (1001/1003=6 "Post grado"),gen(educ)
lab var educ "Nivel de instruccion"
*Nivel educacion Simplificado:
recode educ (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior"),gen (educa)
lab var educa "Nivel de instruccion 4 categorias"

*Numero de Hijos vivos
recode f2215 (6/max=6), gen(hnvda)
replace hnvda =0 if f2205==2
lab var hnvda "Hijos nacidos vivo declarados"

*Actividad sexual reciente
gen acs_dia=f2639a+f2639b*7+f2639c*30+f2639d*365 if f2639d<55
recode acs_dia (0/30=1 "Hace un mes ") (nonmissing=2 "Mas de un mes"),gen(acs)
lab var acs "Tiempo trascurrido desde la ultima relacion sexual"

********************************************************************************
*Conocimiento de metodos anticonceptivos
**********************************
*Conoce al menos un metodo anticeptivo
gen al_mc = .
forval x = 1/14{
	replace al_mc = 1 if f2401`x'  == 1
	}
replace al_mc = 2 if al_mc == .
lab var al_mc "Al menos 1 metodo es conocido"
lab val  al_mc sino
*Conoce al menos un metodo moderno
gen al_mm = .
foreach x of numlist 1/8 11/13  {
	replace al_mm = 1 if f2401`x'  == 1
	}
replace al_mm = 2 if al_mm == .
lab var al_mm "Al menos un metodo moderno conocido"
lab val  al_mm sino
*Conoce al menos un metodo anticeptivo tradicional
*retiro/ritmo/otro
gen al_mt = .
foreach x of numlist  9/10 14 {
	replace al_mt = 1 if f2401`x'  == 1
	}
replace al_mt = 2 if al_mt == .
lab var al_mt "Al menos un metodo anticeptivo tradicional conocido"
lab val  al_mt sino

****************************************
*f2402* *Ha Usado al menos un metodo anticeptivo:
egen nmiss = rsum(f2402*) , missing
gen au_mc=.
forval x = 1/14{
	replace au_mc = 1 if f2402`x' == 1
	}
replace au_mc = 2 if au_mc== . & nmiss!=.
lab var au_mc "Ha usado al menos un metodo"
lab val au_mc sino
drop nmiss
*Ha usado al menos un metodo Moderno  actualmente:
egen nmiss = rsum(f24021 f24022 f24023 f24024 f24025 f24026 f24037 f24028 ///
  f240211 f240212 f240213),mis
gen au_mm=.
foreach x of numlist 1/8 11/13{
replace au_mm = 1 if f2403`x' == 1
}
replace au_mm = 2 if au_mm== . & nmiss!=.
lab var au_mm "Ha usado al menos un metodo moderno"
lab val au_mm sino
drop nmiss
*Usa al menos un metodo anticeptivo tradicional
*retiro/ritmo/met.vagin./otro
egen nmiss = rsum(f24029 f240210 f240214),mis
gen au_mu=.
gen au_mt = .
foreach x of numlist 9 10 14 {
replace au_mt = 1 if f2401`x'  == 1
}
replace au_mt = 2 if au_mt==. & nmiss!=.
lab var au_mt "Ha usado al menos un  metodo tradicional"
lab val  au_mt sino
drop nmiss
*********************************************************
*Brechas entre ha usado y conocimiento
lab def br 11 "Conoce y ha usado" 12 "Conoce y no ha usado" ///
  22 "No conoce no ha usado"
gen br_mc = al_mc*10+au_mc
lab var br_mc "Brecha :todos met."
lab val br_mc br
gen br_mm = al_mm*10+au_mm
lab var br_mm "Brecha :met.mod"
lab val br_mm br
gen br_mt = al_mt*10+au_mt
lab var br_mt "Brecha :met.trad"
lab val br_mt br
forval x = 1/14{
	gen f240b`x' = f2401`x'*10+f2402`x'
	lab val f240b`x'  br
	lab var f240b`x' `"Brecha :`: var label f2401`x''"'
}

****************************************
*Variable Metodo mas efectivo de usos pasados (orden de efectividad CDC)
gen mmef=.
foreach x in 9 10 7 8 11 12 5 3 4 6 2 1 {
	replace mmef=`x' if f2402`x'==1
	}
egen nouso=anycount(f24021 f24022 f24023 f24024 f24025 ///
  f24026 f24027 f24028 f24029 f240210 f240211 f240212),values(2)
replace mmef=13 if nouso==12| f2404==2
recode mmef (1=1 "Vasectomia") (2=2 "Ester fem") (6=3 "DIU") ///
  (4=4 "Inyeccion") (3=5 "Implante") (5=6 "Pastillas") (12=7 "Mela") ///
  (11=8 "Met vag") (8=9 "Codon masc") (7=10 "Condon fem") ///
  (10=11 "Ritmo") (9=12 "Retiro") (13=13 "No usan"),gen(m_hu)
lab var m_hu "Metodo que ha usado de mayor efectividad"
*Variable Metodo mas efectivo de uso Actual
replace mmef=.
foreach x in 9 10 7 8 11 12 5 3 4 6 2 1 {
	replace mmef=`x' if f2403`x'==1
	}
replace mmef=13 if nouso==12 | f2404==2 | f2404==3
recode mmef (1=1 "Vasectomia") (2=2 "Ester fem") (6=3 "DIU") ///
  (4=4 "Inyeccion") (3=5 "Implante") (5=6 "Pastillas") (12=7 "Mela") ///
  (11=8 "Met vag") (8=9 "Codon masc") (7=10 "Condon fem") ///
  (10=11 "Ritmo") (9=12 "Retiro") (13=13 "No usan"),gen(mua)
lab var mua "Metodo en uso actual de mayor efectividad"
drop mmef nouso
*Variables Usan/Moderno/trad
recode mua (13=3 "No usa") (11/12=2 "Usa met Trad") ///
  (nonmissing=1 "Usa met mod"), gen(muar)
lab var muar "Metodo en uso actual recodificado"

*Variables Usan/No usan
recode m_hu (1/12=1 "Ha Usado un metodo") (13=2 "No ha usado"), gen(gm_hu)
lab var gm_hu "Ha usado un metodo 2 cat."
recode mua (1/12=1 "Usa un metodo") (13=2 "No usa"), gen(gmua)
lab var gm_hu "Usa un metodo 2 categorias"

*Solo mujeres fertiles
gen mua2=mua if mua!=2
lab var mua2 "Mujeres fertiles que usan metodo"
lab val mua2 mua
recode mua2 (2/12=1 "Usa un metodo") (13=2 "No usa"), gen(gmua2)
lab var gmua2 "Mujeres fertiles con uso de un metodo 2 categorias"
gen mua3=mua if mua!=7 & mua!=11  & mua!=12  & mua!=13
lab var mua3 "Metodo usado actualmente"
lab val mua3 mua
gen mua4=mua3 if mua3!=1 & mua3!=2
lab var mua4 "Metodo usado actualmente"
lab val mua4 mua
gen mua5=mua if mua!=1 & mua!=2 & mua!=13
lab var mua5 "Metodo  usado actualmente"
lab val mua5 mua

*Deseo de Embarazo
replace f2501=7 if f2430==4 & f2501==1
recode f2501 (1=1 "Desea actualmente") (1=2 "Desea espaciar") ///
  (2=3 "No desea") (5 6=4 "Indecisa/Nosabe") (else=.), gen(des)
****************************************
*Fuente de obtencion
gen obt=f2422
replace obt=f2427 if f2422==.
recode obt (1/4=1 "HosPub_MSP_CS_SCS_PS") (5/6=2 "IESS") (12=3 "ONG") ///
  (8/9=4 "HosPriv_Consult_Clin") (13=5 "Farmacia") (7 10 11 14/15=6 "Otro") ///
  (88/99=7 "NS_NR"), gen(ob)
lab var ob "Fuente de obtencion de metodos anticonceptivos"
****************************************
*Acceso a la fuente de metodo anticeptivos
*f2428* tiempo a la fuente de anticonceptivos
replace f2428b = 0 if f2428a != . & f2428b == .
gen ac_ = f2428a + f2428b*60 if f2428b!=99 | f2428a!=99
*f2428 (1 no se traslada):
replace ac_=0 if f2428==0
recode ac_ (0/14 = 1 "<15 min") (15/29 = 2 "15-29 min") ///
  (30/59 = 3 "30-59 min") (60/120 = 4 "1-2 horas") ///
  (121/max = 5 "2h o mas" ), gen(ac_m)
lab var ac_m "Tiempo de acceso a metodos anticonconceptivos"
****************************************
*Motivos de uso de anticonceptivos
*Razon de uso
recode f2430 (1=1) (5/8 = 5) (88 99 = 6) , gen(ra_m)
lab def ra_m 1 "No_quiere_mas_hijos" 2 "No_quiere_hijos" ///
  3 "No_quiere_hijos_todavia" 4 "Espaciar_embarazos" ///
  5 "Otro uso" 6 "NS_NR",replace
lab val ra_m ra_m
lab var ra_m "Razon de uso de metodos anticonceptivos"

****************************************
*Satisfaccion del metodo usado
*Solo mujeres no satisfechas con el metodo en uso actual
recode f2433 (1/5 7 8 13=1 "0tro metodo moderno" ) (15/max = 3 "NS_NR") ///
  (nonmissing = 2 "Otro metodo tradicional") , gen(p_ag)
lab var p_ag " cual metodo preferiria usar:"
*No respuesta en Satisfaccion de la esterilizacion
replace f2425=3 if f2425==88 | f2425==99
*Razon de insatisfaccion con la esterilizacion femenina
lab def rz_in 1 "Desea_otro hijo" 2 "Conviv_desea_hijo" ///
  3 "Prob_salud_post_op" 4 "Probl_emocionales_postop" ///
  5 "Otro",replace
lab val f2426 rz_in
*Edad a la esterilizacion
recode f2421 (20/24=1 "20-24") (25/29=2 "25-29") (30/34=3 "30-34") ///
  (35/39=4 "35-39") (40/44=5 "40-44") (45/49=6 "45-49") (else=.),gen(adest)
lab var adest "Edad a la esterilizacion"
*Razon principal por la cual no ha ido a operarse
recode f2510 (1=1 "miedo_operacion") (12=2 "todavia_muy_joven") ///
  (2=3 "miedo_efectos_colat") (10=4 "Oposicion_companero") ///
  (14=5 "Necesidad_mayor_info") (4=6 "Costo_elevado") ///
  (88/99=8 "NS_NR") (nonmissing=7 "Otro"), gen(rz_nio)
lab var rz_nio f2510
*Razon principal por la cual no desearia operarse
recode f2511 (1=1 "miedo_operacion") (2=3 "miedo_efectos_colat") ///
  (12=2 "todavia_muy_joven") (8=4 "cerca_menopausia") ///
  (7=5 "no_le_gusta") (15=6 "Miedo_arrepentirse") ///
  (9=7 "Pref_met_reversibles") (3/6 10 11 13 14 16=8 "Otro") ///
  (88/99=9 "NS_NR"), gen(rz_ndo)
lab var rz_ndo f2511

*Analisis de Planificacion Familiar ENSANUT 2012 termina ahi ****************

******************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013****************
*********************VI.Tomo 2************************************************
*********************No uso de anticonceptivos********************************
******************************************************************************

clear all
set more off
set matsize 8000
use ensanut_f2_mef.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (dia mes anio subreg provincia gr_etn area quint ///
  subreg zonas_planificacion pd19*)
drop if _merge ==2
drop _merge

*Edad de la MEF:
recode f2101 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(igr_ed)
lab var igr_ed "Grupos de edad por quiquenios"
recode f2101 (15/24 = 1 "15-24") (25/34 = 2 "25-34") (35/49 = 3 "35-49") (else=.) , gen(ge1)
lab var ge1 "Grupo de edad"
gen gr_ed= igr_ed if igr_ed>1
lab val gr_ed igr_ed
lab var gr_ed "Grupo de edad"
*Grupos de edad MEF
gen dmef=1 if f2101>=15 & f2101<=49
replace dmef=2 if dmef==.
lab def dmef 1 "15 a 49 anios" 2 "12 a 14 anios"
lab val  dmef dmef

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/908 1001/1003=6 "Superior & Postgrado"),gen(educa2)
lab var educa2 "Nivel de instruccion"
*Nivel educacion Simplificado:
recode educa2 (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior"),gen (educa)
lab var educa "Nivel de instruccion 4 categorias"

*Estado Civil Redocificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(eciv)
replace eciv=3 if f2701==1
lab var eciv "Estado civil"
recode eciv (1=1 "En union") (2/3=2 "Sin union"), gen(eciv2)
lab var eciv2 "Estado civil"

*Hijos que viven f2206c con usd. f2207c fuera de la casa
gen hnv = f2215
replace hnv =0 if f2205==2
replace hnv = 6 if hnv >= 6 & hnv ~= .
lab def hnv 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6 o mas", replace
lab val hnv hnv
lab var hnv "No. de hijos vivos"
recode hnv (4/6=4 "4 o mas"), gen(hnv2)
lab var hnv2 "numero de hijos declarados"

********************************************************************************
*Razones de no uso de metodo anticonceptivo
recode f2413 (1=4) (2=2) (3=5) (6=6) (7=7) (10=12) (8=9) (4=11) (5=13) ///
   (9=8) (10/11=88) (88/99=98)if f2404 > 1 & f2411 !=2, gen(raznuso)
replace raznuso=1 if f2404 > 1 & f2200==1
replace raznuso=15 if f2412==1 & f2404>1 & f2411==2
replace raznuso=3 if (f2412==2|f2412==3) & f2404>1 & f2411==2
replace raznuso=5 if f2412==4 & f2404>1 & f2411==2
replace raznuso=2 if f2412==5 & f2404>1 & f2411==2
replace raznuso=88 if f2412==6 & f2404>1 & f2411==2
lab var raznuso "razones de no uso"
lab def raznuso 1 "embarazada actualmente"  2 "postparto/amamantando"  ///
  3 "menopausia subfecund"  4 "deseo de embarazo"  5 "inactividad sexual" ///
  6 "miedo a efectos colaterales"  7 "tuvo efectos colaterales"  ///
  8 "no conoce metodos"  9 "companero se opone" 11 "edad avanzada" ///
  12 "razones religiosas" 13 "no le gusta" 15 "fue operada" 88 "otra" 98 "ns/nr",replace
lab val raznuso raznuso
recode raznuso  (1/5 15=1 "relacionada con emb,fert,asex") ///
  (6/14 88 98=2 "otras razones")(else=.),gen(raznusor)
lab var raznusor "razones de no uso agrupadas"

****************************************
*Deseo de usar anticonceptivos actualmente o en el futuro
gen desuso=9 if f2414==88 | f2415==88 | f2414==99 | f2415==99
replace desuso=1 if f2414==1
replace desuso=2 if f2415==1
replace desuso=3 if f2415==2
lab var desuso "Deseo de Uso de anticonceptivo, muj que no usan"
lab def desuso 1 "Desea usar actualmente" 2 "Desea usar en el futuro" ///
  3 "No desea usar" 9 "NS/NR"
lab val desuso desuso
recode  desuso (3 9=.), gen(desuso2)
lab val desuso2 desuso

****************************************
*Metodo preferido (uso potencial)
recode f2416 (1 7 9 10 = 14) (88 = 99), gen(mpref)
lab def mpref 2 "esterilizacion femenina" 3 "implante" ///
  4 "inyeccion anticonceptiva" 5 "pastillas anticonceptivas" ///
  6 "diu/espiral/t de cobre" 8 "condon" 11 "ritmo, calendario" ///
  14 "Otro" 99 "NS/NR",replace
lab val mpref mpref
label var mpref "Metodo potencial para MEF que desean usar"

recode f2416 (2=1 "esterilizacion femenina") (3=2 "implante") ///
  (4=3 "inyeccion anticonceptiva") (5=4 "pastillas anticonceptivas") ///
  (6=5 "diu / espiral / t de cobre") (1 7 9 8 14=6 "Otro") ///
  (else=.), gen(mpref2)
lab var mpref2 "Metodo potencial para MEF que desean usar"

****************************************
*Conocimiento de fuentes f2417
gen cofu = f2417 if f2416!=10 & f2416!=11 & f2416<14
lab var cofu "Sabe donde conseguir met mod"
recode f2418 (1/4 = 1 "MSP") (5/6 = 2 "IESS") (8/9 = 3 "Clinica,medicopriv") ///
  (7 10 11 15 = 6 "Otro*(FFAA,pol,jtabenef,Cpro)") ///
  (12 = 4 "ONG") (13 = 5 "Farmacia") (88/99 = 9 "NS/NR") if (cofu!=.), gen(fap)
lab var fap "Fuente potencial de metodo anticonceptivo"
****************************************
*Tiempo a la fuente donde conseguiria el metodo
replace f2419a = . if f2419a==88 | f2419a==99
gen timef = f2419a + f2419b*60
replace timef=0 if f2419==1
replace timef=. if f2419==88
lab var  timef "Tiempo a la fuente donde conseguiria el metodo"
****************************************
*Poblacion objetivo no cubierta por servicios de plan.fam.
*Tiempo trascurrido desde la ultima relacion sexual (dias)
gen turs= f2639a+ f2639b*7 + f2639c*30 + f2639d*365 if f2639d<77
lab var turs "tiempo trascurrido desde la ultima relacion sexual (dias)"
*Tiempo deseado al proximo hijo
gen f2502c=f2502b*12
egen tpe= rsum(f2502a f2502c),mis
replace tpe=. if f2502b==99|f2502b==88|f2502a==99|f2502a==88
lab var tpe "tiempo deseado de espaciamiento de embarazo"

gen nonecpf=.
replace nonecpf=1 if f2404==1
replace nonecpf=5 if turs>30
replace nonecpf=2 if f2412>=1 & f2412<=3
replace nonecpf=3 if f2200==1
replace nonecpf=4 if f2501==1 & (tpe < 12 | f2502==4)
replace nonecpf = 6 if nonecpf==.
lab def nonecpf 1 "Estan usando" 2 "Esteril/menopausica" 3 "Embarazada" ///
  4 "Quiere embarazo" 5 "No sexualemente activa en los ultimos 30 dias" 6 "Necesidad"
lab val nonecpf nonecpf
lab var nonecpf "Necesidad de Planificacion familiar y razones"

recode  nonecpf (1/5=1 "No necesitan") (6=2 "Necesitan"), gen(necpf)
lab var necpf "necesidad de servicios de planifacion familiar"
****************************************
*Mujeres que requieren planificacion familiar y que conocen
*No ha constestado a ninguna de las preguntas: nmiss==.
gen al_mc = .
forval x = 1/14{
replace al_mc = 1 if f2401`x'  == 1
}
replace al_mc = 2 if al_mc == .
lab var al_mc "Al menos 1 metodo es conocido"
lab def sino 1 "si" 2 "no", replace
lab val  al_mc sino
*f2402* *Ha Usado al menos un metodo anticeptivo:
egen nmiss = rsum(f2402*) , missing
gen au_mc=.
forval x = 1/14{
	replace au_mc = 1 if f2402`x' == 1
	}
replace au_mc = 2 if au_mc== .
replace au_mc =. if nmiss== .
lab var au_mc "Ha usado al menos un metodo"
lab val au_mc sino
drop nmiss

*Analisis de No uso de anticonceptivos  ENSANUT termina ahi*********************

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************IX Factores de atencion al parto y ************************
*********************complicaciones obstetricas*********************************
********************************************************************************
clear all
set more off
set matsize 8000
use ensanut_f2_mef, clear
*Svyset:
svyset idsector [pweight=pw], strata (area)

*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (dia mes anio subreg provincia gr_etn area ///
  quint subreg zonas_planificacion pd03 pd19*)
drop if _merge ==2
drop _merge

*Grupos de edad MEF
gen dmef=1 if f2101>=15 & f2101<=49
replace dmef=2 if dmef==.
lab def dmef 1 "15 a 49 anios" 2 "12 a 14 anios"
lab val  dmef dmef

*Estado civil simplificado
recode f2700 (1=1 "Unida") (2=2 "Casada") (6=3 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(eciv)
replace eciv=3 if f2701==1
lab var eciv "Estado civil"

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/908 1001/1003=6 "Educacion superior"),gen(meduca2)
lab var meduca2 "Nivel de instruccion de la madre"

*Numero de Hijos
gen nh = f2215
replace nh =0 if f2205==2
recode nh (1=1) (2/3=2 "2-3") (4/5=3 "4-5") (6/max=4 "6 o mas"),gen(nhnv)
drop nh
lab var nhnv "Numero de hijos"

*Filtro mujeres cuyo utlimo hijo nacio 2.8 anios antes de la encuesta:
*Fecha de nacimiento Ultimo hijo
gen uhcmc =f21601b3*12+f21601b2 if f21601b3!=9999 & f21601b2!=99
replace uhcmc = f21601b3*12+6 if f21601b3!=9999 & f21601b2==99
drop if uhcmc<(2010*12+1)|uhcmc==.
*Fecha de nacimiento de la madre
gen vcmc=anio*12+mes
gen bcmc=f2100c*12+f2100b if f2100c!=7777 & f2100b!=77
replace bcmc=f2100c*12+6 if f2100c!=7777 & f2100b==77
lab var vcmc "Fecha visita cmc"
lab var bcmc "Edad madre en CMC"
gen edmn=int((uhcmc-bcmc)/12)
recode edmn (min/24=1 "<25") (25/34=2 "25-34") (35/49=3 "35-49"),gen(igr_ed)
lab var igr_ed "Edad de la madre al nacimiento"

*Lugar del parto
recode f2301 (1/4 = 1 "MSP") (5/7 10 = 2 "Otros publicos") ///
  (8 = 3 "Privado con fines de lucro") ///
  (9 11 = 4 "Privado sin fines de lucro") ///
  (12 13 = 5 "En casa") (14 15 = 6 "Otro parto sola") ///
  (99 = 99 "NR"), gen(lpa)
lab var lpa "Lugar del parto"

*Tipo de parto segun lugar de residencia
recode f2301 (1/11 = 1 "Institucional") (12/13 = 2 "En casa") ///
  (14 15 99 = 3 "Otra, NR"), gen(tpa)
lab var tpa "Tipo de parto"

*Gastos en el ultimo parto segun tipos de gastos y conformidad parto en casa
recode f2307 (1=1 "Esta Conforme") (2=2 "No esta conforme") ///
  (88 99=3 "NS/NR"), gen(cgte)
lab var cgte "Conformidad con el tipo de gasto parto en establecimiento"
lab def f2306 1 "Pago la atencion" 2 "Compro insumos o medicamentos", modify

*Gastos en el ultimo parto segun tipos de gastos y satisfaccion
*con el parto en el establecimiento
recode f2313 (1=1 "Esta Conforme") (2=2 "No esta conforme") ///
  (88 99=3 "NS/NR"), gen(cgtc)
lab var cgtc "Conformidad con el tipo de gasto parto en casa"
lab def f2312 1 "Pago la atencion" 2 "Compro insumos o medicamentos", modify

*Percepcion de la mujeres sobre el tiempo esperado para ser atendidas
replace f2308 = 99 if f2308 == 88
lab def f2308 99 "NS/NR", modify

*Participantes en la decision de dar a luz en establecimiento de salud
egen f231412 = rowmin(f231411 f231410)
egen f231413 = rowmin(f231488 f231499)
drop f231488 f231499 f231411 f231410
lab var f231412 "decision dar a luz en estab./casa - Otro"
lab var f231413 "decision dar a luz en estab./casa - NS/NR"
foreach x of varlist f2314* {
	replace `x'=. if  `x'==2
	local n = substr("`x'",6,.)
	replace `x'=`n' if  `x' ==1
	}
egen pprt=concat(f2314*), punct(,)
replace pprt = subinstr(pprt,".,","",.)
replace pprt = subinstr(pprt,",.","",.)
replace pprt = subinstr(pprt,"1,","",.)
replace pprt ="4" if substr(pprt,1,.)=="2,3"|substr(pprt,1,.)=="2,4"
replace pprt ="10" if substr(pprt,1,.)=="2,5"
replace pprt ="14" if substr(pprt,1,.)=="3,5"
replace pprt ="11" if substr(pprt,1,.)=="2,7"|substr(pprt,1,.)=="2,6"
replace pprt ="15" if regexm(pprt,"4,")|regexm(pprt,"2,3")
replace pprt ="16" if regexm(pprt,"3,")
replace pprt ="17" if length(pprt)>2
destring(pprt),gen(ppt)
drop pprt
recode ppt (1=9 "Nadie/costumbre") (2=2 "Parturienta sola") ///
  (3=4 "Esp,pa,conv solo") (4=1 "Parturienta con esp,pa") ///
  (5=3 "madre/padre solo") (6=12 "Suegra(o) solo") (7=8 "otro familiar solo") ///
  (8=5 "personal de salud solo") (9=17 "partera sola") ///
  (10=6 "Parturienta y madre/padre") (11=15 "Parturienta y otro familiar") ///
  (12=14 "Otro" ) (13=16 "NS/NR") ///
  (14=13 "Part+Esp,pa,co+madpad") ///
  (15=7 "Partu+Esp,pa+otro") ///
  (16=11 "Esp,pa,co+otro sin partu") (17=10 "Otro"),gen(pprt)
drop ppt
lab var pprt "Participantes en la decision de lugar del parto"
*Lugar donde recurrio primero cuando se presentaron complicaciones al embarazo
replace f2318 = 99 if f2318 == 88
lab def f2318 4 "Personal tradicional" 99 "NS/NR", modify
*Lugar donde recurrio primero cuando se presentaron complicaciones al parto
replace f2321 = 99 if f2321 == 88
label define f2321 5 "Otro" 99 "NS/NR", modify
lab var gr_etn "Etnicidad"
lab var quint "Quintil Economico"

*Analisis de Factores de atencion al parto ENSANUT 2012 termina ahi ************

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************X. Mortalidad Infantil*************************************
********************************************************************************
clear all
set more off
set matsize 8000
set seed 13524
use ensanut_f2_mef.dta,clear
*Svyset
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (dia mes anio provincia gr_etn quint subreg ///
  zonas_planificacion pd19* pa07 pa01 pd03)
drop if _merge ==2
drop _merge

*Situacion de empleo sit_e
gen sit_e=pa07
replace sit_e=3 if pa01==6 | pa01==7
lab def sit_e 1 "Dentro del hogar" 2 "Fuera del hogar " 3 "No trabaja"
lab val sit_e sit_e
lab var sit_e "Situacion de empleo"
gen n=1

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/203 401/406 600/607=2 "Primaria") ///
  (701/703 501/506 608/610 =3 "Secundaria") ///
  (801/803 901/908 1001/1003=4 "Superior"),gen(educa)
lab var educa "Nivel de instruccion 4 categorias"
gen tot=1
lab var tot "Total"

******Conversion a formato CMC
rename f2160* f216*
*Missing values year
foreach y of varlist f216*b3 f2100c {
	replace `y'=9999 if `y'>2013 & `y'<7777
	replace `y'=9999 if `y'<f2100c & `y'<7777
	}
*Edad de nacimiento en mes a la fecha de visita
gen entcmc=(2012)*12+mes
gen dobcmc=(f2100c)*12+f2100b if f2100c!=7777

*Fecha de nacimiento en CMC:
foreach x of numlist 1/10 {
	gen bcmc`x' = (f216`x'b3)*12+f216`x'b2 ///
	  if f216`x'b3!=9999 & f216`x'b2!=99
	replace bcmc`x' = (f216`x'b3)*12+int((12-1.0001)*runiform()+1.0001 ) ///
	  if f216`x'b3!=9999 & f216`x'b2==99
	lab var bcmc`x' "Edad del ninos `x' en CMC"
	}

*Limites de observacion 5 anios:
gen endcmc=(2012)*12+7
gen begcmc=(2007)*12+6
*Limites de observacion 10 anios:
*gen begcmc=(2002)*12+6
cap gen nh5=0
foreach x of numlist 1/10 {
	replace nh5=nh5+1 if bcmc`x'>begcmc & bcmc`x'!=.
	}
*Intervalo del nacimiento anterior
forvalues y=1/9  {
	local z=`y'+1
	gen intp`y' = bcmc`y'-bcmc`z'
	replace intp`y' = . if (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	local w=`y'+2
	cap replace intp`y' = bcmc`y'-bcmc`w' if intp`y'==0
	replace intp`y' = . if intp`y'==0 & (f216`y'b3==9999 | ///
	  f216`z'b3==9999 | f216`y'b2==99 | f216`z'b2==99)
	replace intp`y' = . if bcmc`y'<begcmc | bcmc`y'>endcmc
	}

*Edad al fallecimiento
foreach x of numlist 1/10 {
	gen edmur`x' = f216`x'f1+100 if f216`x'f1!=99 & f216`x'f1!=.
	replace edmur`x' = f216`x'f2+200 if f216`x'f2!=99 & f216`x'f2!=.
	replace edmur`x' = f216`x'f3+300 if f216`x'f3!=99 & f216`x'f3!=.
	}

*Variables para mortalidad perinatal
*Ultimo natimuerto
gen bcmc11 = 12*f2211b+f2211a	 if f2211b!=8888 & f2211a!=88
replace bcmc11 = 12*f2211b+int((12-1.0001)*runiform()+1.0001) ///
  if f2211b!=8888 & f2211a==88
gen f21611c=3 if f2210a==1
gen edmur11=-1 if f2210a==1
*Penultimo natimuerto
gen bcmc12=12*f2213b+f2213a	 if f2213b!=8888 & f2213a!=88
replace bcmc12=12*f2213b+int((12-1.0001)*runiform()+1.0001) ///
  if f2213b!=8888 & f2213a==88
gen f21612c=3 if f2212==2
gen edmur12=-1 if f2212==2
********************************************************************************
*Base madres -> base de hijos_reshape
forvalues x=1/10{
	ren f216`x' f216g`x'
	}
ren f216*b1 f216b1*
ren f216*b2 f216b2*
ren f216*b3 f216b3*
ren f216*c f216c*
ren f216*a f216a*
keep f216a* f216c* bcmc* edmur* intp* f216b1* f216b2* f216b3* f216g* ///
  area hogar subreg idsector idpers quint gr_etn pw f2101 f2215 ///
  provincia entcmc educa begcmc endcmc dobcmc nh5
reshape long f216a f216c bcmc edmur intp f216b1 f216b2 f216b3 f216g, ///
  i(idpers) j(ord)
ren  f216c vivo
ren idpers idmadre
ren f216g persona
gen f400=ord
lab def sexo 1 "Hombre" 2 "Mujer"
lab val f216a sexo
lab var f216a "Sexo"
lab var vivo "Esta vivo"
lab def vivo 1 "vivo" 2 "muerto" 3 "mortinato"
lab val vivo vivo
lab var intp "Intervalo desde el nacimiento anterior del nino"
lab var bcmc "CMC Nacimiento"
lab var edmur "Edad fall fmt RHS"
lab var entcmc "CMC Fecha entrevista"
lab var dobcmc "CMC Fecha nacimiento de la madre"

*Eliminacion de casos fuera del periodo de analisis
egen nmiss=rowmiss(bcmc vivo edmur f216a intp)
drop if nmiss==5
drop nmiss
*replace bcmc1=. if bcmc1>endcmc
drop if (bcmc==. & vivo!=3)|(edmur==. & (vivo==2|vivo==3))

*Edad de la madre al nacimiento
gen med=int((bcmc-dobcmc)/12)
recode med (min/19=1 "<20") (20/29=2 "20-29") (30/39=3 "30-39") ///
  (40/49=4 "40-49"), gen(medad)
drop med
recode medad (9/24 = 1 "<25") (25/34 = 2 "25-34") ///
  (35/49 = 3 "35 +"),gen(medadr)
lab var medadr "Edad de la madre 3 categorias"

*Orden de nacimiento del nino
gen ord_n=f2215-f400+1 if f400<11
lab var ord_n "Orden de nacimiento del nino"
recode ord_n (min/1=1 "1ero") (2/3=2 "2do a 3ero") (5/6=3 "4to a 6to") ///
  (7/max=4 "7to o mas" ), gen(ord_ni)
lab var ord_ni  "grupos orden del nacimiento"

*Intervalo previo interparto
gen intpp=intp
replace intpp=-99 if ord_n==1
recode intpp (-99=4 "Primer nacimiento") (0/23=1 "<2 anios") (24/47=2 "2-3") ///
  (48/max=3 "4 o mas anios"), gen (intpr)
drop intpp
lab var intpr "Intervalos interparto - previos"
gen tot=1
lab var tot "Total"
********************************************************************************
*Muerte Neonatal
gen dthage=0  if (vivo==2 & edmur>=100 & edmur <= 128)
replace dthage=1 if (vivo==2 & edmur > 128 & edmur < 200)
replace dthage = edmur - 200 if (vivo==2 & edmur > 200 & edmur < 299)
replace dthage = 12 * (edmur - 300) + int((12-1.0001)*runiform()+1.0001 ) ///
  if (vivo==2 & edmur > 300 & edmur < 398)
*Fecha del mes en que murio cada nino
egen dcmc = rowtotal(bcmc  dthage) if vivo==2
replace dcmc = entcmc if dcmc > entcmc & vivo==2
*Aun esta vivo
replace dcmc=. if vivo==1
*1 si la fecha de nacimiento es entre el periodo
gen bcnt = (bcmc>=begcmc & bcmc <= endcmc) if vivo!=3
gen bcntwtd = (bcmc >= begcmc & bcmc <= endcmc)*pw if vivo!=3
gen dcnt = (dcmc >= begcmc & dcmc <= endcmc) if vivo!=3
*Fecha termina la exposicion*Fecha de muerte es < 60 meses & periodo de estudio
egen stopcmc = rowmin(dcmc endcmc)
gen hasdeath =(dcmc>=begcmc & dcmc<=endcmc & (dcmc < (bcmc + 60)))
*Conteo de muertes neonatales/1-11mes/12/59m
gen dtot01 = 0
gen dtot12 = 0
gen dtot60 = 0
*Edad que tenia en mes de la muerte /  acumulado del tiempo expuesto
forvalues y=1/60 {
	gen agecmc = bcmc + `y' - 1 if vivo!=3
	gen expos`y'=0
	replace expos`y' = pw  if (agecmc >= begcmc & agecmc <=stopcmc)
*Hasdeath: murio entre las fechas del periodo y <60meses
	gen deaths`y' = 0
	replace  deaths`y' = pw if (hasdeath==1 & dcmc==agecmc) ///
	  & (agecmc >= begcmc & agecmc <=stopcmc)
* Neonatal (0-28 dias)
   replace dtot01 = 1  if (`y' == 1) & (hasdeath==1 & dcmc==agecmc) ///
	  	  & (agecmc >= begcmc & agecmc <=stopcmc)
	replace dtot12 = 1  if (`y' <= 12) & (hasdeath==1 & dcmc==agecmc) ///
	  	  & (agecmc >= begcmc & agecmc <=stopcmc)
	replace dtot60 = 1 if (`y' > 12) & (hasdeath==1 & dcmc==agecmc) ///
		  & (agecmc >= begcmc & agecmc <=stopcmc)
	drop agecmc
	}

********************************************************************************
merge 1:1 idmadre persona f400 using ensanut_f4_salud_ninez.dta, keepusing( ///
  f4201 f4203 f4204 f4301 f4401 f4406 f4601 f4602 f4603 f4902a1 f4902a2)
drop if _merge==2
drop _merge
*Control prenatal
replace f4203=66 if f4201==2|  f4204==0
recode f4203 (0/3=1 "1er trimestre") (4/9=2 "2-3er trimestre") ///
  (66=3 "Ninguno") (else=.),gen(tcm)
lab var tcm "Control prenatal"
*Lugar del parto
recode  f4301 (1/9=1 "Institucional") (10/12=2 "Casa") (else=.),gen(lpar)
lab var lpar "Lugar del parto"
*Prematuridad
recode f4401 (2=1 "Si")(1 3=2 "No") (else=.),gen(prem)
lab var prem "Prematuridad"
*Tamano al nacer
recode f4406 (1= 1 "muy pequeno") (2=2 "Pequeno") (3/4=3 "Mas grande") ///
  (else=.),gen(tamn)
lab var tamn "Tamano al nacer"
*Peso al nacer
replace f4902a2=-1 if f4902a1==2
gen f4902a2b=f4902a2*0.00220462262
replace f4902a2b=-1 if f4902a1==2
recode f4902a2b (-1=1 "No especificado") (0/5.4999999=2 "<= 5,5 libras") ///
  (5.5/max=3 "5,5 libras o mas"), gen(pan)
lab var pan "Peso al nacer"
recode f4902a2 (-1=1 "No especificado") (0/2499=2 "Bajo peso") ///
  (2500/max=3 "Mayor o igual a 2500 g"), gen(pan2)
*Region simplificada
recode subreg (1/2 8=1 "Sierra") (3/4 9=2 "Costa") ///
  (5/6=3 "Amazonia") (else=.),gen(region)
lab var region "Region"

*Lugar del parto f4301 *Control Prenatal f4203 *Peso al nacer f4404
*Prematuridad f4401 *Tamano al nacer f4406
*Cuadro6 f4601 f4603
foreach x of varlist tot area region subreg educa gr_etn quint ///
  f216a medad ord_ni intpr tcm lpar pan pan2 prem tamn {
	preserve
	drop if bcmc<begcmc | bcmc>endcmc
	collapse (sum) expos* deaths* bcnt bcntwtd dcnt hasdeath ///
	  dtot01 dtot12 dtot60, by(`x')
	gen lx = 1
	forvalues i=1/60{
	  gen qx = 0
	  replace qx = deaths`i' / expos`i' if (expos`i' > 0)
	 	replace lx = lx * (1 - qx)
	 	gen q`i' = 1 - lx
	 	drop qx
	 	}
	gen qpnn = q12 - q1
	gen qchild = 1 - (1 - q60) / (1 - q12)
	*Muertes por 1000 nacimientos .
	replace q1 = 1000 * q1
	replace qpnn = 1000 * qpnn
	replace q12 = 1000 * q12
	replace qchild = 1000 * qchild
	replace q60 = 1000 * q60
	keep `x' q1 qpnn q12 qchild q60 bcnt
	mkmat _all , matrix(A)
	matrix Rr = nullmat(Rr) , A
	matrix colnames Rr = `x' Nacimientos_en_el_periodo Mrt_Neonatal ///
	  Mrt_infantil Mrt_min60_meses Mrt_Post_neonatal ///
	  Mrt_en_la_ninez
	labellist `x'
	mat rownames Rr = `r(labels)'
	mat li Rr
	matrix drop _all
restore
}

*Analisis de Mortalidad  Infantil ENSANUT 2012 termina ahi *********************

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************IX. Salud de ninos menores de 5 anios***********************
********************************************************************************

clear all
set more off
set matsize 8000
use ensanut_f4_salud_ninez.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)

*Variables de cruce (import.):
ren idpers idper
ren idmadre idpers
merge m:1 idpers using ensanut_f1_personas.dta, ///
  keepusing(dia mes anio provincia gr_etn area quint ///
  subreg zonas_planificacion pd19*)
drop if _merge==2
drop _merge
merge m:1 idpers using ensanut_f2_mef.dta, keepusing(f2700 f2701 f2100*)
drop if _merge==2
drop _merge
ren idpers idmadre
ren idper idpers

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/max=6 "Superior/Postgrado"),gen(educ)
lab var educ "Nivel de instruccion de la madre"

*Edad del nino :
gen bcmc =(pd04c)*12+pd04b if pd04c!=9999 & pd04b!=99
replace bcmc = (pd04c)*12+6 if pd04c!=9999 & pd04b==99
gen vcmc=(anio)*12+mes
lab var vcmc "Fecha visita cmc"
lab var bcmc "Edad nino en CMC"
*Grupos de edad de nino en meses
gen age_nm=vcmc-bcmc
*Correccion por dia de nacimiento ENDEMAIN 2004
gen  birthday=pd04a  if pd04a < 99
replace birthday=15  if pd04a==99
gen age_nm2=age_nm
replace age_nm2=age_nm-1  if (dia < birthday)
lab var age_nm "Edad del Nino en mes"
recode age_nm (0/5 = 1 "0-5") (6/11 = 2 "6-11") (12/23 = 3 "12-23") ///
  (24/35 = 4 "24-35") (36/59 = 5 "36-59") (else = .), gen(gedad_n)
recode age_nm2 (0/5 = 1 "0-5") (6/11 = 2 "6-11") (12/23 = 3 "12-23") ///
  (24/35 = 4 "24-35") (36/59 = 5 "36-59") (else = .), gen(gedad_n2)
label var gedad_n "Grupos de edad de nino en meses"
label var gedad_n2 "Grupos de edad de nino en meses"
*Edad de la madre
gen mcmc=f2100c*12+f2100b if f2100c!=7777
lab var mcmc "Edad madre cmc"
*Edad de la madre al nacimiento
gen edmn= int((bcmc-mcmc)/12)
lab var edmn "Edad de la madre al nacimiento del hijo"
recode edmn (min/19=1 "<20") (20/29=2 "20 a 29") ///
  (30/39=3 "30 a 39") (40/49=4 "40 a 49"), gen(gedadm_n)
lab var gedadm_n  "Grupos de edad madre al nacimiento del hijo"
recode edmn (min/19=1 "<20") (20/24=2 "20 a 25") (25/29=3 "25 a 29") ///
  (30/34=4 "30 a 34") (35/39=5 "35 a 39") (40/49=6 "40 a 49"), gen(gedadm_n2)
lab var gedadm_n2  "Grupos de edad madre al nacimiento del hijo"

*Estado civil de la madre:
cap recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil de la madre"

*Orden de nacimiento del nino
preserve
use ensanut_f2_mef.dta,clear
ren f2160* f216*
foreach x of numlist 1/10 {
	gen bcmc`x'=(f216`x'b3)*12+f216`x'b2 ///
	  if f216`x'b3!=9999 & f216`x'b2!=99
	replace bcmc`x'=(f216`x'b3)*12+6 if f216`x'b3!=9999 & f216`x'b2==99
	}
ren f216*a f216a*
keep bcmc* f216a* idpers f2215
reshape long f216a bcmc, i(idpers) j(ord)
rename idpers idmadre
ren f216a sexo
lab var sexo Sexo
drop if bcmc==.
*Orden de nacimiento del nino
gen ord_n=f2215-ord+1
save f2_orden.dta,replace
restore
merge m:m idmadre bcmc using f2_orden.dta
drop if pw==.
drop _merge
erase f2_orden.dta
lab var ord_n "Orden de nacimiento del nino"
recode ord_n (min/1=1 "1ero") (2/4=2 "2do a 4to") (5/7=3 "5to a 7mo") ///
  (8/max=4 "8vo o mas" ), gen(ord_ni)
lab var ord_ni  "grupos del orden del nacimiento"
recode ord_n (6/max=6 "6 o mas"), gen(ord_ni2)
lab var ord_ni2  "grupos del orden del nacimiento"

*Rango de observacion: julio2007-junio2012
gen inf=(2007)*12+7
gen sup=(2012)*12+6
drop if bcmc>sup | bcmc<inf

*****************************
*Lugar de atencion al parto
recode f4301 (1/4 7=1 "Establ Publico_IESS") ///
  (5/6 8 13=2 "Otro") (9=3 "HospPriv") ///
  (10/12=4 "En casa u sola") (77 88=5 "NR"), gen(lug_p)
lab var lug_p "Lugar del parto"
recode f4301 (1=1 "Hosp. MSP") (2=2 "Otro MSP") (3=3 "IESS") ///
  (4/5 8=4 "Otro") (6=5 "junta de beneficencia") ///
  (9=6 "hospital/clinica priv.") (7=7 "CP UMunicip") ///
  (10=8 "en casa con partera") (11=9 "en casa con familiar") ///
  (12=10 "parto sola") (77 88=11 "NSNR"), gen(lug_p2)
lab var lug_p2 "Lugar del parto"
*****************************
*Edad al primer control
gen edc = round((f4605a + f4605b*7 + f4605c*30)/30)
replace edc=77 if f4605a==77|f4605b==77|f4605c==77
replace edc=88 if f4604 == 2
recode edc (0=0 "<1") (3/12 =3) (77=4 "NSNR") (88=5 "No tuvo control"), ///
  gen(ed_pc)
drop edc
lab var ed_pc "Edad al primer control"
*Condicion de control
recode f4606 (88 99 = 3 "NS/NR"), gen(cd_s)
replace cd_s=4 if f4604 == 2
lab def f4606 3 "NS/NR" 4 "No tuvo control" , modify
lab val cd_s f4606
lab var cd_s "Condicion de salud del recien nacido al primer control"
*****************************
*Lugar de atencion al primer control
recode  f4607 (1/2 = 1 "MSP") (3/4 = 2 "IESS/SSC") ///
  (9=3 "Clinica Consult priv") (8=4 "Fundacion ONG") ///
  (7=5 "CP UMunicip") (77 88=7 "NSNR") ///
  (nonmissing = 6 "Otros") , gen(lu_pc)
*****************************
*Caracterizacion de diarreas
*Clasificacion de la diarrea segun gravedad
gen gravedad=3 if f4701==1 & f4610==1 & ///
  ((f4706a==1 & f4706c==1) | (f4706a==1 & f4706d==1) | ///
  (f4706a==1 & f4706e==1) |	(f4706c==1 & f4706d==1) | ///
  (f4706c==1 & f4706e==1) | (f4706d==1 & f4706e==1) |	///
  (f4706a==1 & f4706c==1 & f4706d == 1) | ///
  (f4706a==1 & f4706c==1 & f4706e == 1) |	///
  (f4706a==1 & f4706d==1 & f4706e == 1) | ///
  (f4706c==1 & f4706d==1 & f4706e == 1) |	///
  (f4706a==1 & f4706c==1 & f4706d==1 & f4706e==1))
replace gravedad=2 if (f4701==1  & f4610==1 & gravedad==. & ///
  (f4706b==1 | f4706e==1 | (f4706b==1 & f4706e==1) | (f4706b==1 & f4706a==1)))
replace gravedad=1 if f4701==1 & f4610==1 & gravedad==.
replace gravedad=10  if f4701==1 & f4702==0 & f4610==1
replace gravedad=10  if f4701!=1 & f4610==1
lab def gravedad 1 "Sin deshidratacion" 2 "Con deshidratacion no grave" ///
  3 "Con deshidratacion grave" 10 "No tuvo diarrea"
lab val gravedad gravedad
*Solo sintomas
gen gravedad2 = gravedad  if gravedad<4
lab var  gravedad2 "Clasificacion de diarrea 3 categorias"
lab val gravedad2 gravedad
*Tuvo no tuvo
recode gravedad (1/3=1 "Tuvo diarrea") (10=2 "No tuvo diarrea"),gen(grvd3)
lab var  grvd3 "Clasificacion de diarrea 2 categorias"

*Numero promedio media de dias que duro la diarrea
replace f4702 =. if f4702 == 99
*Numero de episodios
replace f4704 =. if f4704 > 20
*Lugar o persona donde las madres consultaron primero
recode f4710 (1=1 "hospital o maternidad msp") ///
  (2=2 "centros de salud similares msp") (3/4=3 "IESS/SSC") ///
  (9=4 "clinica o consultorio privado") (11=6 "farmacia o botica") ///
  (5/8 10 12=7 "Otro" ), gen(lu_co)
lab var lu_co "donde o a quien consulto primero"
*****************************
*Infecciones resparatorias - Clasificaciones de la gravedad
*de sintomas asociados (CDC)
*Tuvo IRA
gen  tuvoira=1 if f4801==1 & f4610==1
replace  tuvoira=2 if f4801!=1 & f4610==1
lab var tuvoira "Tuvo Infeccion Respiratoria"
*Clasificacion
gen cl_ir=1 if f4801==1 & f4804e==1 & f4610==1
replace cl_ir=2 if f4801==1 & f4804g==1 & f4610==1 & cl_ir==.
replace cl_ir=3 if f4801==1 & f4804h==1 & f4610==1 & cl_ir==.
replace cl_ir=4 if  f4801==1 & f4610==1  & cl_ir==. & ///
  ((f4804a==1) | (f4804b==1) | (f4804c==1) | (f4804d==1) | (f4804f==1))
replace cl_ir=5 if  f4801==1 & f4610==1  & cl_ir==. & ///
  f4804a !=. & f4804a !=1 & f4804b !=. & f4804b !=1 & ///
  f4804c !=. & f4804c !=1 & f4804d !=. & f4804d !=1 & ///
  f4804e !=. & f4804e !=1 & f4804f !=. & f4804f !=1 & ///
  f4804g !=. & f4804g !=1 & f4804h !=. & f4804h !=1
replace  cl_ir=10 if cl_ir==. & f4610==1 & f4801!=.
lab var cl_ir "Clasificacion de la Infeccion Respiratoria"
lab def cl_ir 1 "Neumonia grave (a)" 2 "Neumonia (b)" 3 "Silibancias (c)" ///
  4 "Tos o resfriado y enfermedad grave (d)" 5 "Solo tos o resfriado (e)" ///
  10 "No tuvo infeccion"
lab val cl_ir cl_ir
*Solo sintomas
gen cl_ir2= cl_ir if cl_ir <6
lab val cl_ir2 cl_ir
lab var cl_ir2 "Clasificacion de IRA"
*Tuvo no tuvo
recode cl_ir (1/5=1 "Tuvo Infeccion") (10=2 "No tuvo infeccion"), gen(cl_ir3)
lab var cl_ir3 "Clasificacion de IRA"
*Tratamiento recibido para la IRA
gen tos_rm=2 if f4801==1
foreach x of varlist f4805*{
	replace tos_rm=1 if `x'==1
	}
lab def tos_rm 2 "no hizo nada" 1 "hizo algo"
lab val tos_rm tos_rm
lab var tos_rm "Hizo algo para aliviarle la tos"

*Lugar o persona donde las madres consultaron primero
recode f4807 (1=1 "hospital o maternidad msp") ///
  (2=2 "centros de salud similares msp") (3/4=3 "IESS/SSC") ///
  (9=4 "clinica o consultorio privado") (11=6 "farmacia o botica") ///
  (5/8 10 12=7 "Otro" ), gen(lu_ir)
lab var lu_ir "donde o a quien consulto primero por IR"
*****************************
*Tenencia de carne infantil y actividades registradas
recode f2101 (12/14 = 1 "12-14") (15/19 = 2 "15-19") (20/24 = 3 "20-24") ///
  (25/29=4 "25-29") (30/34= 5 "30-34") (35/39 = 6 "35-39") (40/44=7 "40-44") ///
  (45/49 =8 "45-49") (else=.), gen(mgedad_m)
label var mgedad_m "Edad actual de las madres"

recode f4901 (1=1 "Si") (nonmissing=0 "No"),gen(f4901r)
lab var f4901r "Tiene el carnet de salud infantil"

*****************************
*Vacunacion
rename f4105* f41_5*
rename f4100* f410*
*Respuestas segun carne y madre en caso de no haber carne
forval  x = 1/36 {
	gen f410`x'f=f410`x'a
	replace f410`x'f=1 if f410`x'f==2 & f410`x'e==1
	lab var f410`x'f `"`: var label f410`x'a' segun carnet & madre"'
	lab val f410`x'f f41001a
	}
*Edad al recibir la vacuna:
forval x = 1/36 {
	gen f410`x'h=(f410`x'd)*12+f410`x'c if f410`x'd!=9999 & f410`x'c!=99
	replace f410`x'h= f410`x'h-bcmc
	replace f410`x'h=f410`x'h-1 if f410`x'b<pd04a & f410`x'b!=99 & pd04a!=99
	recode f410`x'h (0/2 = 1 "0-2") (3/5 = 2 "3-5") (6/8 = 3 "6-8") ///
	  (9/11 = 4 "9-11") (12/14 = 5 "12-14") (15/17 = 6 "15-17") ///
	  (18/23 = 7 "18-23") (24/35 = 8 "24-35") (36/59 = 9 "36-59") ///
	  (else = .), gen(f410`x'g)
	drop f410`x'h
	local lbl =substr(`"`: var label f410`x'a'"',9,.)
	local lbl =subinstr("`lbl'", " - dosis","",.)
	lab var f410`x'g "`lbl' Grupos de edad a la vacunacion en meses"
	}
*Inmunizacion : *12/23 meses total de respuestas *12/59 total de respuestas
*12/59 meses con carne + fecha valida
*BCG (antes de un anio)
recode f4101f (1=1) (2=0), gen(bcg)
gen bcgfv =(f4101g!=. & f4901==1)
replace bcgfv =.  if f4901==2|f4901==3|f4901==.|bcg==.
gen bcg1a = bcgfv
replace bcg1a=0 if f4101g!=. & f4101g>4 & bcgfv==1
lab var bcg "BCG"
lab var bcgfv "BCG fecha valida + carne"
lab var bcg1a "BCG antes de un anio + carne"

*Sarampion (a partir de 12 hasta 23 meses)
recode f41017f (1=1) (2=0), gen(srp)
gen srpfv =(f41017g!=. & f4901==1)
replace srpfv =. if f4901==2|f4901==3|f4901==.|srp==.
gen srp1a = srpfv
replace srp1a=0 if f41017g!=. & srpfv==1 & (f41017g>8 | f41017g<5)
lab var srp "Sarampion"
lab var srpfv "Sarampion fecha valida + carne"
lab var srp1a "Sarampion antes de un anio + carne"

*Polio
gen p1=f4108f*100+f4109f*10+f41010f
*Considerando IPV y OPV
gen pd1=(f4108f ==1|f41014f==1|f41029f==1)
replace pd1=. if (f4108f==.|f41014f==.|f41029f==.)
gen pd2=(f4109f==1|f41015f==1|f41030f==1)
replace pd1=. if  (f4109f==.|f41015f==.|f41030f==.)
gen pd3=(f41010f==1|f41016f==1|f41031f==1)
replace pd1=. if  (f41010f==.|f41016f==.|f41031f==.)
gen p1t=pd1*100+ pd2*10+pd3

recode p1t (111=1 "Si") (nonmissing=0 "No"),gen(poliot)
recode p1 (111=1 "Si") (nonmissing=0 "No"),gen(polio)

gen poliofv = (polio==1 & f4108g!=. & f4109g!=. & f41010g!=. & ///
  f4108g<=f4109g & f4109g<=f41010g & f4901==1)
replace poliofv =. if f4901==2|f4901==3|f4901==.|polio==.
gen polio1a=poliofv
replace polio1a=0 if f41010g!=. & f41010g>4 & poliofv==1
drop p1
lab var polio "Polio"
lab var poliofv "Polio fecha valida + carne"
lab var polio1a "Polio antes de un anio + carne"

*DPT/Pentavalente
gen penta=f4103f*100+f4104f*10+f4105f
recode penta (111=1) (nonmissing=0)
gen pentafv=(penta==1 & f4103g!=. & f4104g!=. & f4105g!=. & ///
  f4103g<=f4104g & f4104g<=f4105g & f4901==1)
replace pentafv=. if f4901==2|f4901==3|f4901==.|penta==.
gen penta1a=pentafv
replace penta1a=0 if f4105g!=. & f4105g>4 & pentafv==1
*dpt
gen dptp=f41026f*100+f41027f*10+f41028f
recode dptp (111=1) (nonmissing=0)
gen dptpfv=(dptp==1 & f41026g!=. & f41027g!=. & f41028g!=. & ///
  f41026g<=f41027g & f41027g<=f41028g & f4901==1)
replace dptpfv=. if f4901==2|f4901==3|f4901==.|dptp==.
gen dptp1a=dptpfv
replace dptp1a=0 if f41028g>4 & dptpfv==1
*DPT y Pentavalente
foreach x in "" fv 1a {
	replace dptp`x'=dptp`x'*10+penta`x'
	recode dptp`x' (11 10 1=1 "Si") (0=0 "No"),gen(dpt`x')
	}
drop penta penta1a dptp dptp1a
lab var dpt "DPT"
lab var dptfv "DPT fecha valida + carne"
lab var dpt1a "DPT antes de un anio + carne"

*Inmunizacion Completa
gen imcp=0 if (bcg!=. | polio!=. | dpt!=. | srp!=.)
replace imcp=1 if (bcg==1 & polio==1 & dpt==1 & srp==1)
gen imcpt=0 if (bcg!=. | poliot!=. | dpt!=. | srp!=.)
replace imcpt=1 if (bcg==1 & poliot==1 & dpt==1 & srp==1)
gen imcpfv=0 if (bcgfv!=. | poliofv!=. | dptfv!=. | srpfv!=.)
replace imcpfv=1 if (bcgfv==1 & poliofv==1 & dptfv==1 & srpfv==1)
gen imcp1a=0 if (bcg1a!=. | polio1a!=. | dpt1a!=. | srp1a!=.)
replace imcp1a=1 if (bcg1a==1 & polio1a==1 & dpt1a==1 & srp1a==1)
lab var imcp "Imunizacion completa"
lab var imcpt "Imunizacion completa"
lab var imcpfv "Imunizacion completa fecha valida + carne"
lab var imcp1a "Imunizacion completa antes de un anio + carne"
foreach x of varlist bcg-imcp1a{
	lab val `x' polio
	}
*******************
*Apoyo economico del padre f41105 / Numero de visitas
recode f41106 (0 = 0 "Ninguna") (1/4 = 1 "1-4") (5/9 = 2 "5-9") ///
  (10/14 = 3 "10-14") (888=5 "NS")(nonmissing=4 "15 o mas"), gen(pd_nv)
label var pd_nv "Numero de veces que los han visitado"
********************
*Bajo peso al nacer
*Peso al nacer
recode f4902a2 (0/2499=1 "Bajo peso")(2500/max=2 ">= 2500 g"),gen(pan)
lab var pan "Peso al nacer"

*Analisis de Salud de la Ninez ENSANUT 2012 termina ahi ************************

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************X. Actividad Sexual de Adolescentes************************
********************************************************************************
clear all
set more off
set matsize 8000
set seed 35890
use ensanut_f2_mef.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (pd04a pd04b pd04c dia mes anio subreg provincia ///
  gr_etn area quint subreg zonas_planificacion pd03 ///
  pd19a pd19b pa07 pa01)
drop if _merge ==2
drop _merge

recode f2101 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(gr_ed)
lab var gr_ed "Grupos de edad por quiquenios"
*Grupos de edazd considerados:
gen gr_edsx=gr_ed if gr_ed==2 | gr_ed==3
lab val gr_edsx gr_ed
lab var gr_edsx "Grupo Actividad sexual"

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"

*Grupos de edad MEF
gen dmef=1 if f2101>=15 & f2101<=49
replace dmef=2 if dmef==.
lab def dmef 1 "15 a 49 anios" 2 "12 a 14 anios"
lab val  dmef dmef

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/903 =6 "Hasta 3 anios de educacion superior") ///
  (904/908=7 "4 o mas anios de educacion superior (sin post grado)") ///
  (1001/1003=8 "Post grado"),gen(educ2)
lab var educ "Nivel de instruccion"

*Nivel instruccion Simplificado:
recode educ (1=1 "Ninguno") (2=2 "Primaria Incompleta") ///
  (3=3 "Primaria Completa")  (4=4 "Segundaria Incompleta") ///
  (5=5 "Segundaria Completa") (6/max=6 "Superior postgrado"),gen (ieduca)
lab var ieduca "Nivel de instruccion 6 cat."
recode educ (1=1 "Ninguno") (2/3=2 "Primaria") (4/5=3 "Segundaria") ///
  (6/max=4 "Superior postgrado"),gen (iedus)
lab var iedus "Nivel de instruccion 4 categorias"

*Numero de Hijos vivos
recode f2215 (6/max=6), gen(hnvda)
replace hnvda =0 if f2205==2
replace hnvda =0 if f2204==1
lab var hnvda "Hijos nacidos vivo declarados"
******************************************************************************
*Activida Sexual: f2603
recode f2603 (1=1 "Si") (2=2 "No") (else=.), gen(desa)

*Situacion de empleo sit_e
gen sit_e=pa07
replace sit_e=3 if pa01==6 | pa01==7
lab def sit_e 1 "Dentro del hogar" 2 "Fuera del hogar " 3 "No trabaja"
lab val sit_e sit_e
lab var sit_e "Situacion de empleo"
rename sit_e fsit_e

*Edad de la menarquia
recode f2646 (min/10=10 "antes de los 11 anios") ///
  (97=97 "no ha menstruado todavia"),gen(mrq)
lab var mrq "Edad a la menarquia"

recode f2101 (15/17 = 1 "15-17") (18/19 = 2 "18-19") (20/22 = 3 "20-22") ///
  (23/24 = 4 "23-24") (else = .), gen(mgr_asa)
lab var mgr_asa "Grupos de edad actividad sexual de adolescentes"

*Grupo de edad menarquia_
recode f2646 (min/10=10 "<11 anios") (16/19=16 "16 o mas") (97=.),gen(gr_mrq)
lab var gr_mrq "Grupo_menarquia"

*Fuente de informacion: sexualidad*Conocimiento *f2647
recode f2648 (77=77 "no recuerda") (4 7 11 =9 "Otro") ///
  (1=8 "padre y madre") (2=7 "padre") (8=6 "amiga") (6=5 "otro pariente") ///
  (5=4 "hermana") (10=3 "Nunca le explicaron")(9=2 "profesor(a)") ///
  (3=1 "madre"),gen(f_msr)
lab var f_msr "Fuente de informacion sobre la menstruacion"

*Fuente de informacion sobre los temas de educacion sexual
lab copy f2602a f2602_r
lab def f2602_r 4 "Otra persona u institucion",modify
foreach x of varlist f2602*{
	gen `x'r=`x'
	replace `x'r=4 if `x'==5
	lab val `x'r f2602_r
	lab var `x'r `"`: var label `x''"'
	}
******************************************************************
*Edad a la 1era relacion: f2605
*12 a 14 y de 15 a 24 anios
drop fsexage
cap gen fsexage=f2605 if (f2600==1|f2600==2) & f2605<=24 & f2605!=.
replace fsexage=100 if (f2600==1|f2600==2) & f2603==2 & f2603!=.
replace fsexage=999 if (f2600==1|f2600==2) & f2605>24 & f2605!=.
foreach x of numlist 15 18 20 22 25{
	gen ps`x'=(fsexage>0 & fsexage<`x')*100 if fsexage!=. & fsexage!=999
	lab var ps`x' `"Edad a lal primera relacion sexual antes de los `x'"'
	}
gen psever=(fsexage>0 & fsexage<100)*100 if fsexage!=. & fsexage!=999
lab var psever "Alguna vez unida"
gen psnever=(fsexage!=. & fsexage==100)*100 if fsexage!=. & fsexage!=999
lab var psnever "Soltera"
gen pstiempo=fsexage if fsexage!=. & fsexage!=999
replace pstiempo = f2101 if fsexage == 100
replace pstiempo=pstiempo+uniform()
recode fsexage (100=0) (else=1),gen(psstatus)

******************************************************************
*Edad de la pareja a la primera relacion sexual
*Anos cumplidos a la primera relacion: f2605
recode f2607 (min/14=1 "<15") (15/17=2 "15-17") (18/19=3 "18-19") ///
  (20/24=4 "20-24") (25/87=5 "24 o mas") (88/max=6 "NS NR"), gen(ed1prj)
lab var ed1prj "Edad de la primera pareja"
*Edad de la Primera relacion sexual:
recode f2605 (min/14=1 "<15") (15/17=2 "15-17") (18/19=3 "18-19") ///
  (20/24=4 "20-24") (25/max=.), gen(ed1rl)
lab var ed1rl "Edad de la primera relacion"
*Razon por la cual no uso anticonceptivos en la primera relacion
gen rz_nu= f2613
replace rz_nu=10 if  rz_nu==4
replace rz_nu=88 if  rz_nu==99
lab val rz_nu f2613
lab var rz_nu "Razon de no usar un metodo anticonceptivo la 1a vez"
*Mujeres alguna vez embarazadas primer embarazo
*Clasificacion Embarazo: f2614==1
gen cl_pe = f2614
replace cl_pe=3 if desa==2
lab def cl_pe 1 "Embarazada" 2 "Nunca embarazada" 3 "Sin experiencia sexual"
lab val cl_pe cl_pe
*Tipo personas en el embarazo:
gen tp_p=f2620
replace tp_p=0 if f2620==.
replace tp_p = cl_pe*10 + tp_p
replace tp_p=. if f2620==99
recode tp_p (11=1 "Conyuge/Conviviente") (12/13=2 "Novio/Amigo") ///
  (14/17=4 "Otro") (20=5 "Nunca embarazada") ///
  (30=6 "Sin experiencia sexual"), gen (tp_pe)
lab var tp_pe "Clasificacion persona con la cual se embarazo"
drop  tp_p
*Tipo personas en el embarazo:
gen tp_p2=f2620
replace tp_p2=7 if tp_p2==6
lab val tp_p2 f2620
lab var tp_p2 "Clasificacion de persona con la cual se embarazo"

*Edad al primer Embarazo
recode f2615 (10/ 14 = 1 "Menores a 15") (15/17 = 2 "15-17") ///
  (18/19 = 3 "18-19") (20/24 = 4 "20-24") (else = .), gen(je_emb)
lab var je_emb "Edad al primer embarazo"
*Recibio Informacion
recode  f2601c (1=1 "Si") (2=2 "No") (else=.), gen(bf2601c)
recode  f2601e (1=1 "Si") (2=2 "No") (else=.), gen(cf2601e)

*Edad de la pareja con la que tuvo el primer embarazo
recode f2619 (min/14 = 1 "< a 15 anios") (15/17 = 2 "15-17") ///
  (18/19 = 3 "18-19") (20/22=4 "20-22") (23/24=5 "23-24") (25/29=6 "25-29") ///
  (88=8 "NSNR") (nonmissing = 7 "30 o mas"), gen(hed_pj)
label var hed_pj "Edad de la pareja al primer embarazo "
recode hed_pj (1/2=1 "<18") (3=2 "18-19") (4/5=3 "20-24") ///
  (6/7=4 "25 o mas") (8=5 "NSNR"),gen(hed_pj2)
	label var hed_pj2 "Edad de la pareja al primer embarazo "

*Tipo de pareja con la que tuvo la primera relacion sexual, clasificacion
gen relsex = 1 if f2608!=. & f2608==1
replace relsex=2 if f2608!=. & f2608 > 1
replace relsex=2 if est_civ==2 & f2604a!=.
replace relsex = 2 if f2701==2 & fsexage < funage
replace relsex = 3 if desa==2
lab def relsex 1  "Marital" 2 "Premarital" 3 "Nunca tuvo"
lab val relsex relsex
lab var relsex "Primera relacion Premarital/Marital"
recode relsex  (1=1 "Marital") (2=2 "Premarital") (else=.) ,gen(rp_pm)
lab var rp_pm "Primera relacion Premarital o Marital"

recode f2608 (1=1 "Conyuge o conviviente") (2/3=2 "Novio Amigo") ///
  (4/7=3 "Otro") (else=.), gen(rp_pms)
lab var rp_pms "Tipo de relacion con la persona, 3 cat"

* Embarazo Premarital/Marital
gen tipemb=1 if f2205==1 & f2620==1
replace tipemb=2 if f2205==1 & f2620!=1 & f2620!=.
replace tipemb=3 if f2205==2
lab def tipemb 1 "Marital" 2 "Premarital" 3 "Nunca Embarazada" ///
  4 "Sin experiencia sexual"
la val tipemb tipemb
lab var tipemb "Embarazo Marital/Premarital"
gen tp_pe2 = tipemb
replace tp_pe2=4 if desa==2
la val tp_pe2 tipemb
lab var tp_pe2 "Embarazo Marital/Premarital"
recode tipemb (1=1 "Marital") (2=2 "Premarital") (else=.),gen(tp_ped)
lab var tp_ped "tipo de relacion con la persona en el primer embarazo"

************************************************************
*Actividad de la madre al momento del primer embarazo
gen ac_p = f2626*10+f2632
recode ac_p (12=1 "Solo estudiaba") (31 21=2 "Solo trabajaba") ///
  (11=3 "Estudiaba y trabajaba") (32 22=4 "No estudiaba ni trabajaba"), ///
  gen (ac_pe)
drop ac_p
lab var ac_pe "Actividad de la madre al momento del primer embarazo"

*Nivel de educacion al embarazo (INEC)
gen f2627ar=f2627a+2
replace f2627ar=f2627ar-1 if f2627ar<4
gen f2627br=f2627b
replace f2627br=0 if f2627ar==1
gen f2627ab=(f2627ar)*100+f2627br
recode f2627ab (100=1 "No estudiaba") ///
  (200/203 401/406 600/607 =2  "Primaria") ///
  (409 701/710 500/510 608/610=3 "Secundaria") ///
  (801/803 900/908 1001/1003=4 "Superior postgrado"),gen(k_educ)
replace k_educ=1 if f2626==3
lab var k_educ "Nivel de instruccion al embarazo"

*Implicaciones del embarazo :
*Sobre los estudios:
gen cs_e=f2628*10+f2630
recode cs_e (11=1 "Interrumpio y volvio") ///
  (12 22=2 "Interrumpio y No volvio") (21=3 "No interrumpio"), gen(cs_ed)
lab var cs_ed "Consecuencia del embarazo sobre los estudios"
*Sobre el trabajo:
gen cs_a=f2633*10+ f2635
recode cs_a (11=1 "Interrumpio y volvio") ///
  (12 22=2 "Interrumpio y No volvio") (21=3 "No interrumpio"), gen(cs_al)
lab var cs_al "Consecuencia del embarazo sobre el trabajo"
drop cs_a cs_e

*Actividad sexual reciente
gen acs_mes=(f2639a/30.43)+(f2639b/4.3481)+f2639c+f2639d*12 if f2639d<55
lab var acs_mes "Ultima relacion sexual en meses"
recode acs_mes (min/1=1 "En el ultimo mes") (else=2 "Mas de un mes"), ///
  gen(acs_1m)
recode acs_mes  (min/3=1 "En 3 ultimos mes") (else=2 "Mas de un mes"), ///
  gen(acs_3m)
lab var acs_1m "Ultima actividad sexual en el ultimo mes"
lab var acs_3m "Ultima actividad sexual en los 3 ultimos meses"

*Razon de no uso de condon
gen rz_un = f2642
replace rz_un=13 if rz_un==3 | rz_un==2
lab val rz_un f2642
lab var rz_un "Por que no uso condon"

*Metodo usado en la primera relacion
gen mup=f2611
replace mup=0 if f2610==2
lab val mup f2611
lab var mup "Metodo usado en la primera relacion"

*Analisis de Actividad Sexual de adolescentes ENSANUT termina ahi*************

******************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013****************
*********************Tomo 2***************************************************
*********************XI. Infeccion de Transmision Sexual***********************
******************************************************************************

clear all
set more off
set matsize 8000
use ensanut_f2_mef.dta,clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
*Merge de variables de cruce:
merge 1:1 idpers using ensanut_f1_personas.dta, ///
  keepusing (dia mes anio subreg provincia ///
  gr_etn area quint subreg zonas_planificacion pd03 pd19a pd19b)
drop if _merge ==2
drop _merge

*Edad
recode f2101 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(gr_ed)
lab var gr_ed "Grupos de edad"

*Estado civil simplificado
recode f2700 (1/2=1 "UnidaCasada") (6=2 "Solteras") ///
  (3/5=3 "DivorSeparViuda"), gen(est_civ)
replace est_civ=3 if f2701==1
lab var est_civ "Estado civil"
*Grupos de edad MEF
gen dmef=1 if f2101>=15 & f2101<=49
replace dmef=2 if dmef==.
lab def dmef 1 "15 a 49 ans" 2 "12 a 14 ans"
lab val  dmef dmef

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/203 401/406 600/607 =2 "Primaria") ///
  (701/703 501/506 608/610 =3 "Secundaria") ///
  (801/803 901/908 1001/1003=4 "Superior"),gen(educa)
lab var educa "Nivel de instruccion"
*****************************************************************************
*Conocimiento de Infeccciones de transmision sexual + VIH SIDA(espont|.dir.)
*Exp sex: si/no
*Mujeres con experiencia sexual.
gen f2603r=1
replace f2603r=2 if (f2603==2 | f2637a==22)
lab def f2603r 1 "Con experiencia sexual" 2 "Sin experiencia sexual"
lab val f2603r f2603r
lab var f2603r "Experiencia sexual 12-49 anios"

*Conocimiento de ITS : dirigido(f2802) + espontaneo(f2801*):
foreach x of newlist a b c d e f g h i j k l{
	gen f2803`x'=f2801`x'*10+f2802`x'
	recode f2803`x' (11=1) (21=1) (22=2)
	lab val f2803`x' f2801`x'
	local lbl =subinstr(`"`: var label f2801`x''"', ///
	  "f2801`x'. ha oido hablar - ","",.)
	local lbl =subinstr(`"`lbl'"', "(espontaneo)","",.)
	local lbl =subinstr(`"`lbl'"', "( espontaneo)","",.)
	lab var f2803`x' "`lbl'"
	}
gen f2804c=f2801c*10+f2802c
recode f2804c (11=1 "Espontaneo") (21=2 "dirigido") (22=3 "No conoce"),gen(csida)
lab var csida "Conocimiento Sida"
*****************************************************************************
*Numero de metodos preventivos para la contagion de VIH
gen nprv=0
foreach x of varlist f2809*{
	replace nprv= nprv+1 if `x'==1
}
replace nprv=. if f2803==3
recode nprv (0=0 "No conoce") (1=1 "Una") (2/max=2 "Dos o mas"),gen(nprev)
lab var nprev "Numero de metodos de prevencion conocidos (VIH/SIDA)"
*****************************************************************************
*variable para las tres en conjuntos (GJ)
gen npre3=0
foreach x of varlist f2809a f2809b f2809c{
	replace npre3= npre3+1 if `x'==1
}
replace npre3=2 if npre3<3
replace npre3=1 if npre3==3
replace npre3=. if f2803==3
lab def npre3 1 "Conoce las 3 formas" 2 "Conoce menos de 3" ,replace
lab val npre3 npre3
lab var npre3 "Conocimiento de las 3 formas primarias de prevencion"
*****************************************************************************
*Realizacion de  prueba
replace f2812=. if  f2812==0
*****************************************************************************
*Lugar de realizacion de la ultima prueba
recode f2816 (1/3=1 "MSP") (4/5=2 "IESS") (6=3 "FFAA/Policia") ///
  (7=4 "Clinica/medico privado") (9=5 "Cruz roja") (11=6 "Clinica ONG") ///
  (8=7 "Junta de Beneficencia") (10 12 13 =8 "Otros*"),gen(lu_pr)
label var lu_pr "Donde se hizo la prueba del VIH"
*****************************************************************************
*Voluntariedad de realizacion de la ultima prueba VIH
lab def f2817 1 "Voluntad propia" 2 "Tener que presentar resultados" ///
  3 "Otro", modify
lab val f2817 f2817
*****************************************************************************
*Tiempo a la fecha de la  realizacion de la ultima prueba VIH
gen t_p=f2815d*12 + f2815a/30.4368 + f2815b/4.34812 + f2815c
replace t_p=. if t_p==0
replace t_p=9999 if f2815a==77
recode t_p (min/11=1 "menos de 12 meses") (12/23=2 "12-23 meses") ///
  (24/35=3 "24-35 meses") (36/47=4 "36-47 meses") ///
  (48/360=5 "48 o mas meses") (9999=6 "No recuerda"), gen(trp_vih)
label var trp_vih "Tiempo desde el ultimo despistaje"
drop t_p
******************************************************************************
*Recepcion de informacion en prueba VIH
*f2818 f2819 f2820
******************************************************************************
*Razon de no realizacion, realizacion prueba VIH
*f2821 (clases ENDEMAIN 2004):
recode f2821 (1=1) (2=2) (3/4=3) (5=4) (6=5) (10=6) (11=7) (12 7/9=8) ///
  (88/99=9) (mis=.),gen(rz_nrp)
lab def rz_nrp 1 "No ha considerado necesario" ///
  2 "Temor confidencialidad" ///
  3 "Oposicion pareja o familiares" ///
  4 "Temor al resultado" 5 "no ha tenido tiempo" ///
  6 "Falta de dinero muy caro" 7 "Nunca indicado recomendado" ///
  8 "Otra" 9 "NSNR",replace
lab val rz_nrp rz_nrp
lab var rz_nrp "Razon por la que nunca se ha hecho el examen de sida"
*****************************************************************************
*Si no se harian prueba aun que fuese gratuito
recode f2823 (1=1 "no lo necesita") ///
  (2=2 "temor a falta de confidencialidad") ///
  (3=3 "oposicion de la pareja") (4 7 9 10=4 "Otro") ///
  (5=5 "temor al resultado") (6=6 "no tiene tiempo") ///
  (8=7 "dicen que el personal de salud regana") ///
  (88/99=8 "no sabe no responde") (mis=.),gen(rz_nhp)
lab var rz_nhp "Razon por la que nunca haria el examen de sida"
*****************************************************************************
*Percepcion de riesgo de infectarse del VIH/SIDA
*f2806 "Cree que usted tiene el peligro de infectarse con SIDA"
gen cinf = f2806
lab var cinf "Creencia en peligro de infectarse"
recode f2805 (1=2 "Si") (2=1 "No"), gen (f2805r)
*****************************************************************************
*Razon de percepcion de riesgo de infectarse del VIH/SIDA
*f2807. razon por la que puede infectarse con sida
gen rz_pri=f2807
replace rz_pri=10 if rz_pri==5 | rz_pri==6
replace rz_pri=88 if rz_pri==99
lab def rz_pri 1 "su pareja tiene mas parejas" 2 "Pareja pasa fuera" ///
  3 "no sabe como protegerse" 4 "su pareja rechaza el condon" ///
  5 "ya ha tenido its" 6 "por ser trabajadora sexual" ///
  7 "no usa siempre condon" 8 "No conoce promisc pareja" ///
  9 "Pareja consum_alcohol/droga" ///
  10 "otra, cual"	88 "NS NR"
lab val rz_pri rz_pri
lab var rz_pri "Razones percibidas de posible infeccion (VIH)"
*****************************************************************************
*Razon de Percepcion de no riesgo de infectarse del VIH/SIDA
gen rz_pnr=f2808
replace rz_pnr=11 if rz_pnr==3 | rz_pnr==8 | rz_pnr==9
replace rz_pnr=88 if rz_pnr==99
lab def f2808 88 "NS NR" , modify
lab val rz_pnr f2808
lab var rz_pnr "Razones percibidas de no infeccion (VIH)"
*****************************************************************************
*Uso del condon: f2641
*MEF sexualmente activas en el utlimo anio:
gen dmsa=.
replace dmsa=1 if f2640==1
lab var dmsa "MEF sexualmente activas en el utlimo anio"
*****************************************************************************
*Razon del no uso del condon
gen rz_nuc=f2642
replace rz_nuc=13 if rz_nuc==2 | rz_nuc==3
lab var rz_nuc "Por que no uso condon"
lab copy f2642 rz_nuc,replace
lab def  rz_nuc 3 "Es caro u costoso" 6 "disminuye el placer incomodo" ///
  8 "Para uso extramatrimonial" 13 "Otra",modify
lab val rz_nuc rz_nuc
tab rz_nuc

*Analisis de ITS ENSANUT 2012 termina ahi **************************************


********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************XII. Uso de servicios de salud*****************************
********************************************************************************

clear all
set more off
set matsize 8000
use ensanut_f1_personas, clear
svyset idsector [pweight=pw], strata (area)
*Estado civil simplificado
recode estado_civil (1=1 "UnidaCasada") (2=2 "Solteras") ///
  (3/4=3 "DivorSeparViuda"), gen(est_civ)

*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100 300 301 =1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/903 =6 "Hasta 3 anios de educacion superior") ///
  (904/908=7 "4 o mas anios de educacion superior (sin post grado)") ///
  (1001/1003=8 "Post grado"),gen(educ2)
lab var educ2 "Nivel de instruccion"
*Nivel de instruccion
recode educ (6/8=6) if pd03>=5, gen(educa2)
lab copy educ2 educa2,replace
lab def educa2 6  "Superior/Postgrado", modify
lab val educa2 educa2

*Nivel educacion Simplificado:
recode educ2 (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior") if pd03>=5,gen (educa)
lab var educa "Nivel de instruccion 4 categoria"

*Grupos de edad
recode pd03 (0/4=1 "0-4") (5/14=2 "5-14") (15/29=3 "15-29") (30/44=4 "30-44") ///
  (45/59=5 "45-59") (60/74=6 "60-74") (75/98=7 "75 o mas") (99=.), gen(ggr_ed)
lab var ggr_ed "Grupos generales de edad"

*Condicion de actividad economica
recode pa01 (1/6=1 "Trabajo") (7=2 "No trabajo") if pd03>=10, gen(act_ec)
replace act_ec=1 if pa01==7 & pa02==1 & pd03>=10
lab var act_ec "Condicion de empleo"
********************************************************************************
*Afiliacion de la poblacion a seguro
gen tpsg=pse01*100+pse07a*10+pse07b
recode tpsg (166 266=1 "IESS unicamente") (111/165 211/265=2 "IESS y otro") ///
  (366=3 "SCC unicamente") (311/365=4 "SCC y otro seguro") ///
  (416 461=5 "Privado unicamente") (426 436=6 "ISSFA,SSPOL unicamente") ///
  (466=7 "Sin Seguro") (nonmissing=8 "Otro"), gen(tp_sg)
drop tpsg
lab var tp_sg "Tipo de seguro"

recode tp_sg (7=1 "Sin seguro") (nonmissing=2 "Tiene seguro") ,gen(sg_sn)
lab var sg_sn "Disponibilidad de seguro"

*Problemas de salud durante (30dias_ps02) y hospitalizaciones (12meses)
recode ps55 (1 = 1 "Si") (2 = 0 "No"), gen(hp12)
label var hp12 "Hospitalizacion ultimos 12 meses"

*Razones para no estar afiliado o cubierto por el IESS y SSC : pse02

*Tipo de problemas de salud
recode ps03 (7 8 10 13/16 = 16), gen(tp_pb)
replace  tp_pb=17 if ps02==2
lab def ps03 17 "No tuvo problemas",add
lab val tp_pb ps03
lab var tp_pb "Tipo de problema de Salud"

*Numero de visitas a establecimientos de salud
gen n_vi = 1 if ps06 == 1 | ps06 == 2 | ps06 == 4
replace n_vi = 0 if n_vi == . & ps06 !=.
replace n_vi = n_vi+1 if ps27 == 1 | ps27 == 2 | ps27 == 3 | ps27 == 6
replace n_vi = n_vi+1 if ps37 == 1 | ps37 == 2 | ps37 == 3 | ps37 == 6
lab def n_vi 0 "Ninguna" 1 "1" 2 "2" 3 "3 o mas", replace
lab val  n_vi n_vi
lab var n_vi  "Numero de visitas"

*Tipo de establecimiento visitado resolver el problema de salud
gen estpri=ps08 if (ps06==1)
*Por casos de hospitalizacion
recode ps29(1=1)(2=5)(3=7)(4=8)(5=9)(6=10)(7=11)(8=16),gen(ps29r)
replace estpri=ps29r if (ps06==4)

recode estpri (1=1 "hospital publico") (2=2 "centro de salud publico") ///
  (3/4=3 "subcentro u puesto de salud publico") ///
  (5/6=4 "hospital clinica o dispensario iess") ///
  (8=6 "hospital clinica privada") (11=9 "fundacion ong") ///
  (12=10 "farmacia") (13=11 "consultorio medico") ///
  (nonmissing=14 "otro") , gen (tp_es)
lab var tp_es "Tipo de establecimiento acudido para resolver problemas salud"

*Motivo por el que no hizo nada para resolver cualquier
recode ps07 (1 8=1 "enfer leve o conocida") (2=2 "no tuvo tiempo") ///
  (3=3 "Servicio queda lejos") (4 6=4 "muy caro no tiene") ///
  (5=5 "atencion de mala calidad") (7 9 10=6 "Otro"), gen(rz_nt)
lab var rz_nt "Motivos para no tratarse el problema de salud"

*Primera accion tomada para resolver el problema de salud
*Si se resolvio el problema de salud despues de al accion tomada:
gen p_res = ps26
lab val p_res ps26
lab var p_res "Resolucion del problema de salud (1era accion)"
recode ps06 (1 4=1 "Visito a un agente de salud") ///
  (2=2 "At_agente_salud en casa") (3=3 "Automedicacion") ///
  (5=4 "No hizo nada"), gen(ac1)
lab var ac1 "1a Accion"

*Segunda accion tomada para resolver el problema de salud
recode ps27 (1 2 6=1), gen(ac2)
lab val ac2 ps27
lab var ac2 "2da Accion"
gen s_res = ps36
lab val s_res ps36
lab var s_res "Resolucion del problema de salud (2nda accion)"

*Tercera accion tomada para resolver el problema de salud
recode ps37 (1 2 6 = 1) (8=.), gen(ac3)
lab val ac3 ps37
lab var ac3 "Tercera accion"

*Atencion de servicios de salud preventiva y tipo de establecimiento ps40 ps41
recode ps41 (1=1 "Hospital MSP") (2=2 "Centro de salud MSP") ///
  (3 4=3 "Subcentro puesto de salud MSP") ///
  (5 6=4 "Hospital Clinica Dispensario del IESS") ///
  (8=5 "Hospital Clinica privada") (12=6 "Farmacia") ///
  (13=7 "Consultorio medico") (11=8 "ONGs") ///
  (nonmissing =9 "Otros"), gen(at_sp)
lab var at_sp "Tipo de establecimiento acudido para salud preventiva"


*Mujeres de 15 a 49 anios : embarazos y controles prenatales

*Mujer de 15 a 49:
recode pd03 (12/14=0 "mef 12-14 a") (15/49=1 "mef 15-49") ///
  (else=.) if pd02==2, gen (dmef15)
lab var dmef15 "Mujeres en edad fertil"

*N@ de controles prenatales:
recode pf03 (0=0 "Ninguno") (1=1 "1") (2=2 "2") (3=3 "3") (4=4 "4") ///
  (5=5 "5") (6=6 "6") (7=7 "7") (8=8 "8") (9/max=9 "Mas de 8"), gen(ncp)
lab var ncp "Numero de controles prenatales"

*Ha estado embarazada : pf02

*Control prenatal por tipo de establecimiento utilizado
recode pf05 (1=1 "Hospital msp") (2=2 "Centro de salud msp") ///
  (3/4=3 "Subcentro puesto de salud msp") (5/6=4 "Hosp clin Disp iess") ///
  (8=5 "Hospital clinica privada") (12=6 "Consultorio medico") ///
  (11=7 "Fundacion ong") (nonmissing=8 "Otro"), gen (ecp)
lab var ecp "Establecimiento acudido para el control prenatal"

*Motivos para elegir el establecimiento de salud publico o privada
replace pf07 = . if pf07  == 5 & sg_sn == 1
*Estableciminto elegido : publico o privado
recode pf05 (1/7 10=1 "Publico") (nonmissing=2 "Privado"), gen (epp)
lab var epp "Tipo de establecimiento acudido para el control prenatal"

*Atencion del parto durante los ultimos 12 meses
gen at_p=pf18
replace at_p=0 if pf02==3
lab def at_p 1 "Si" 2 "No" 0 "Nunca estuvo embarazada"
lab val at_p at_p
lab var at_p "Mujeres que tuvieron parto (ult. 12 meses)"

*Mujeres de 15 a 49 anios que dieron a luz durante los ultimos 12
recode pf19 (1=1 "hospital msp") (2=2 "centro de salud msp") ///
  (3/4=3 "subcentro Muesto msp") (5/6=4 "hosp,clin,Disp iess") ///
  (8=5 "hospital, clinica privada") (9=6 "junta de beneficencia") ///
  (10=7 "Cons Prov") (15=8 "partera") (16=9 "en casa con familiar") ///
  (7 12 13=10 "Otros establecimiento salud") (nonmissing=11 "Otro"), gen (lu_p)
lab var lu_p "Lugar del parto"

*Motivos para elegir el establecimiento de salud publico o privado
*pf22: motivo de eleccion
*Estableciminto elegido para el parto: publico o privado
recode pf19 (1/7 10=1 "Publico") (nonmissing=2 "Privado"), gen (eppa)
lab var eppa "Tipo de establecimiento acudido para el parto"

*Analisis de Uso de servicios de salud ENSANUT 2012 termina ahi ****************


********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2011-2013******************
*********************Tomo 2*****************************************************
*********************Gastos de servicios de salud*******************************
********************************************************************************

clear all
set more off
set matsize 8000
use ensanut_f1_personas, clear
*Svyset:
svyset idsector [pweight=pw], strata (area)
********************************************************************************
*Variables de cruce
*Nivel de educacion (INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100 300 301=1 "Sin estudios") ///
  (200/203 401/406 600/607=2 "Primaria") ///
  (701/703 501/506 608/610 =3 "Secundaria") ///
  (801/803 901/908 1001/1003=4 "Superior"),gen(educa)
lab var educa "Nivel de instruccion"

*Grupos de edad
recode pd03 (0/4=1 "0-4") (5/9=2 "05-09") (10/14=3 "10-14") ///
  (15/29=4 "15-29") (30/44=5 "30-44") (45/59=6 "45-59") (60/74=7 "60-74") ///
  (75/max=8 "75 o mas"),gen(gred)
lab var gred "Grupos de edad"
*Condicion de actividad economica
recode pa01 (1/6=1 "Trabajo") (7=2 "No trabajo") if pd03>=10, gen(act_ec)
replace act_ec=1 if pa01==7 & pa02==1 & pd03>=10
lab var act_ec "Condicion de empleo"

*Afiliacion de la poblacion a seguro
gen tpsg=pse01*100+pse07a*10+pse07b
recode tpsg (166 266=1 "IESS unicamente") (111/165 211/265=2 "IESS y otro") ///
  (366=3 "SCC unicamente") (311/365=4 "SCC y otro seguro") ///
  (416 461=5 "Privado unicamente") (426 436=6 "ISSFA,SSPOL unicamente") ///
  (466=7 "Sin Seguro") (nonmissing=8 "Otro"), gen(tp_sg)
drop tpsg
lab var tp_sg "Tipo de seguro"
recode tp_sg (7=1 "Sin seguro") (nonmissing=2 "Tiene seguro") ,gen(sg_sn)
lab var sg_sn "Disponibilidad de seguro"
********************************************************************************
*Labels
lab def pro 23 "Sto Domingo", modify
lab var provincia "Provincia"
********************************************************************************
*Gastos
*Gastos brutos de salud declarados
*Valores perdidos de gastos
global gst pse06 pse09 ps12 ps16b ps16c ps17b ps18b ps19b ps21 ps22b ///
  ps25 ps31b ps31c ps33b ps34b ps35b ps39 ps44 ps47b ps47c ps48b ps51 ///
  ps54 ps59b ps59c ps61b ps62b ps63b ps67 ps70 pf09 pf11 pf14 pf17 ///
  pf24 pf26 pf29 pf32 pf39 pf41 pf44 pf47

foreach x of global gst {
	replace `x' = . if `x' == 999999 | `x' == 999
	}
*Gastos en otra accion tomada relativo a hospitalizacion en el ultimo mes
*no contabilizado ver hospitalizacion en los 12 ultimos meses
replace ps39=. if ps37==6
*Gastos mensuales anualizados
foreach x of varlist pse06 pse09 ps12 ps16b ps16c ps17b ps18b ps19b ///
  ps21 ps22b ps25 ps39 ps44 ps47b ps47c ps48b ps51 ps54 {
	gen `x'_an = `x'*12
	lab var `x'_an `"`: var label `x''_anualizado"'
	}

********************************************************************************
*Gastos totales
*Filtro de Hogar Unico para totales por hogar
sort idhog pd06
egen Htt=tag(idhog)
lab var Htt "Total de Hogares"
*Etnicidad del hogar (~jefe de hogar)
gen gr_etnj=gr_etn if Htt==1
lab val gr_etnj etn
lab var gr_etnj "Etnicidad por autodefinicion"

********************************************************************************
*Gasto Atencion en Salud Ambulatoria (AA)
*Filtro de personas con Pb. AA.
recode ps02 (1=1 "Si") (else=0 "No"),gen(AA)
lab var AA "Personas del hogar con Pb. AA."
*Filtro de personas con Pb. AA. que no tomaron acciones para resolverlo
recode ps06 (5=0 "No") (nonmissing=1 "Si"),gen(AAn)
lab var AAn "Hogar con Pb AA & tomo accion para resolverlo"

********************
*Tipologia de gastos por otra accion tomada
recode ps37 (1 2=1) (6 7=.), gen(ps37r)
lab val ps37r ps37
separate ps39, by(ps37r) gen(ps39)
*Total
egen gAAt=rsum(ps12 ps16b ps16c ps17b ps18b ps19b ps21 ps22b ps25 ps39),mis
lab var gAAt "Gasto Atencion Ambulatoria total"
*Directo
egen gAAd=rsum(ps16b ps16c ps17b ps18b ps19b ps21 ps22b ps25 ps39),mis
lab var gAAd "Gasto Atencion Ambulatoria directo"
*Transporte
gen gAAtr=ps12
lab var gAAtr "Gasto Atencion Ambulatoria transporte"
*Perdida de Ingreso
egen gAAp=rsum(ps51 ps54),mis
lab var gAAp "Perdida de Ingreso Atencion Ambulatoria"
*G.A.A. Por accion tomada: visita establecimiento/Atencion en casa/
*automedicacion/siguio tratamiento medico
egen gAAtt=rsum(ps12 ps16b ps16c ps17b ps18b ps19b ps21 ps22b ps25),mis
separate gAAtt if (ps06<4) , by(ps06) gen(gAAt)
egen gAAt_1 =rsum(gAAt1 ps391),mis
egen gAAt_2 =rsum(gAAt2 ps393),mis
egen gAAt_3 =rsum(gAAt3 ps394),mis
gen gAAt_4 = ps395 if ps395!=.
lab var gAAt_1 "Visito a establecimiento de salud"
lab var gAAt_2 "Atencion en casa"
lab var gAAt_3 "Automedicacion"
lab var gAAt_4 "Siguio tratamiento medico"
drop gAAt3 gAAt2 gAAt1
*Filtro por Gasto AA:
gen AAt_1=(gAAt_1!=.)
gen AAt_2=(gAAt_2!=.)
gen AAt_3=(gAAt_3!=.)
gen AAt_4=(gAAt_4!=.)

*G.A.A. Por tipo de gasto:
*consulta medica
egen gAAc=rsum(ps16b ps16c ps21 ps391 ps393),mis
lab var gAAc "Consulta medica"
*Medicamento:
egen gAAm=rsum(ps17b ps22b ps25 ps394),mis
lab var gAAm "Medicamento/remedios"
*Examen en laboratorio
gen gAAe=ps18b
lab var gAAe "Examenes de laboratorio"
*Otros gastos
egen gAAo=rsum(ps19b ps398),mis
lab var gAAo "Otros gastos"
drop ps391 ps393 ps394 ps395 ps398 gAAtt

*Filtro por Gasto AA:
gen AAc=(gAAc!=.)
gen AAm=(gAAm!=.)
gen AAe=(gAAe!=.)
gen AAo=(gAAo!=.)

********************************************************************************
*Gasto hospitalizacion en los 12 ultimos meses (HP)
*Filtro de personas con Hospitalizados
recode  ps55 (1=1 "Si") (else=0 "No"),gen(HP)
lab var HP "Personas del hogar hopitalizadas el ultimo anio"
*Total
egen gHPt=rsum(ps59b ps59c ps61b ps62b ps63b ps67 ps70),mis
lab var gHPt "Gasto Hospitalizacion el ultimo anio total"

*Poblacion por Hopitalizacion ps55
*Poblacion por hospitalizada por forma de pago (persona)
recode ps59a (1=1 "pago todo") (2 4=2 "otra forma de pago") ///
  (3=3 "pago y recupero del seguro") (5/6=4 "No pago"),gen(ps59ar)
lab var ps59ar `"`: var label ps59a'"'

*Poblacion por hospitalizacion por mecanismo de pago (persona todo otro nopago) ps60
recode ps60 (1=1 "ahorros propios") (2=2 "prestamo bancario") ///
  (3/4=3 "prestamo familiar amigos") (5=4 "tuvo que vender algo") ///
  (6=5 "tarjeta de credito") (7=6 "otro") , gen(mpa)
lab var mpa "Mecanismo de pago"

*******************************************************************************
*Gasto Atencion Salud Preventiva	/hogar/capita/persona enferma (SP)
*Filtro de personas Salud Preventiva
recode  ps40 (1=1 "Si") (else=0 "No"),gen(SP)
lab var SP "Personas del hogar recurieron a SP"
*Total
egen gSPt=rsum(ps44 ps47b ps47c ps48b),mis
lab var gSPt "Gasto en Salud preventiva total"

********************************************************************************
*Gasto control prenatal (CP)
*Filtro de mujeres embarazadas
recode  pf02 (1=1 "Si") (else=0 "No"),gen(CP)
lab var CP "Mujeres que estuvieron embarazadas"
*Filtro de mujeres embarazadas que no realizaron controles prenatales
recode pf03 (0=0 "No") (nonmissing=1 "Si"),gen(CPn)
lab var CPn "Hogares con embarazadas & realizaron control prenatal"
*Total
egen gCPt=rsum(pf09 pf11),mis
lab var gCPt "Gasto en control prenatal total"
*Directo
gen gCPd=pf11
lab var gCPd "Gasto en control prenatal directo"
*Perdida ingreso pers/acomp pf14 pf17

********************************************************************************
*Gasto Atencion al parto (AP)
*Filtro de mujeres embarazadas
recode  pf18 (1=1 "Si") (else=0 "No"),gen(AP)
lab var AP "Mujeres que tuvieron parto"
*Total
egen gAPt=rsum(pf24 pf26),mis
lab var gAPt "Gasto en parto total"
*G. Directo
gen gAPd=pf26
lab var gAPd "Gasto en parto directo"
*Perdida Ingreso pf29 pf32

********************************************************************************
*Gasto en control Post parto (PP)
*Filtro de mujeres que realizaron control post parto
recode  pf33 (1=1 "Si") (else=0 "No"),gen(PP)
lab var PP "Mujeres que realizaron control post parto"
*Gasto Hospitalizacion ultimo mes * ps31b ps31c ps33b ps34b ps35b

********************************************************************************
*Gastos totales (gTT)
*Gasto total Anual directo
egen gTTd= rsum(ps16b_an ps16c_an ps17b_an ps18b_an ps19b_an ps21_an ///
  ps22b_an ps25_an ps39_an ps47b_an ps47c_an ps48b_an ps59b ps59c ps61b ///
  ps62b ps63b ps67 pf11 pf26 pf41), mis
lab var gTTd "Gasto anualizado total directo"
*Gasto total Anual Transporte
egen gTTtr=rsum(ps12_an ps44_an pf09 pf24 pf39), mis
lab var gTTtr "Gasto anualizado total en transporte"
*Gasto total Anual Perdida de ingreso
egen gTTp=rsum(ps51_an ps54_an ps70 pf14 pf17 pf29 pf32 pf44 pf47),mis
lab var gTTp "Perdida de ingreso anualizada total"
*Gasto total Anual + con pago mensual seguros de salud
egen gTTt= rsum(pse06_an pse09_an gTTd gTTp gTTtr),mis
lab var gTTt "Gasto anualizado total"

********************************************************************************
*Por Hogares
keep *AA* *HP* *SP* *CP* *AP* *PP* *TT* area subreg provincia ///
  zonas_planificacion prov gr_etnj quint idsector idhog
gen n=1
lab var n "Miembros del hogar"

*Label: conservar antes de la agregacion
foreach v of var * {
	local l`v' : variable label `v'
	}

*Suma de gastos por hogar
collapse (sum) n *AA* *HP* *SP* *CP* *AP* *PP* *TT* ///
  (mean) zonas_planificacion area subreg provincia ///
  prov gr_etnj quint idsector, by(idhog)

merge 1:1 idhog using ensanut_f1_vivienda.dta, keepusing(pw)
drop _merge

*Svyset:
svyset idsector [pweight=pw], strata (area)
gen p=1

*Label: aplicar despues de la agregacion
foreach v of var * {
	local L`v' : variable label `v'
	label var `v' `"`l`v''"'
	label val `v' `v'
	}
lab val subreg sbr
lab val provincia pro
lab val prov pro
lab val gr_etnj etn
replace AAn=. if AA==0
replace CPn=. if CP==0
recode AAn (0=0) (nonmissing=1)
recode CPn (0=0) (nonmissing=1)
********************************************************************************
*Gastos totales (gTT)
*Gastos total en Salud per capita
gen gTTtc=gTTt/n
lab var gTTtc "Gastos en Salud Ambulatoria per capita"
*Filtro hogares sin problemas de salud o no usaron los servicios de salud
gen TT=(AA==0 & HP==0 & SP==0 & CP==0 & AP==0 & PP==0)
lab var TT "hogar sin problemas de salud o no usaron los servicios de salud"
lab val TT AAn
*Filtro hogares con problemas de salud & que no realizaron acciones al respeto
gen TTn=((AAn==0 & CPn!=1)|(CPn==0 & AAn!=1))
lab var TTn "hogar con problemas de salud & no realizaron acciones al respeto"
lab val TTn AAn
*Hogares que sin pb de salud o que no tomaron acciones
foreach x of varlist gTT* {
	replace `x'=-2 if  TT==1
	replace `x'=-1 if  TTn==1
	}
*Gastos Total en Salud recodificado (END04)
foreach x of varlist gTTt gTTd {
	recode `x' (-2=-2 "Hogar sin pb de salud") ///
	  (-1=-1 "Hogar pb & no tomaron acciones") ///
	  (0=0 "Hogar uso servicio de salud & no gasto") (0.01/199.99=1 "de 0 a <200") ///
	  (200/399.99=2 "de 200 a <400") (400/799.99=3 "de 400 a <800") ///
	  (800/1999.99=4 "de 800 a <2000") (2000/max=5 ">2000") (missing=.),gen(r`x')
	lab var r`x' `"`: var label `x'' recodificado"'
	}
foreach x of varlist gTTtc  gTTtr{
	recode `x' (-2=-2 "Hogar sin pb de salud") ///
	  (-1=-1 "Hogar pb & no tomaron acciones") ///
	  (0=0 "Hogar uso servicio de salud & no gasto") ///
	  (0.01/19.99=1 "de 0 a <20") (20/39.99=2 "de 20 a <40") ///
	  (40/79.99=3 "de 40 a <80") (80/199.99=4 "de 80 a <200") ///
	  (200/max=5 ">200") (missing=.),gen(r`x')
	lab var r`x' `"`: var label `x'' recodificado"'
	}
recode gTTp (-2=-2 "Hogar sin pb de salud") ///
  (-1=-1 "Hogar con pb de salud & no tomaron acciones") ///
  (0=0 "Hogar que uso servicio de salud  & no gasto") ///
  (0.01/99.99=1 "de 0 a <100") (100/199.99=2 "de 100 a <200") ///
  (200/399.99=3 "de 200 a <400") (400/max=4 ">400") ///
  (missing=.),gen(rgTTp)
lab var rgTTp `"`: var label gTTp' recodificado"'

********************************************************************************
*Gastos en Salud Ambulatoria (gAA)
*Gastos en Salud Ambulatoria per capita
gen gAAca=gAAt/n
lab var gAAca "Gastos en Salud Ambulatoria per capita"

*Gastos en Salud Ambulatoria por enfermo
gen gAAen=gAAt/AA
replace gAAen=0 if gAAt==0
lab var gAAen "Gastos en Salud Ambulatoria por enfermo"
*Valores para hogares sin pb de salud y con Pb sin accion
foreach x of varlist gAA* {
	local w=substr("`x'",2,2)
	replace `x'=-2 if  `w'==0
	replace `x'=-1 if  `w'n==0
	}
replace gAAm=0 if AAn==0
replace gAAe=0 if AAn==0

*Solo casos validos de gastos especificos
foreach x of varlist gAAt_* gAAc gAAo {
	local w=substr("`x'",2,.)
	replace `x'=. if `w'==0
	}

********************************************************************************
*Gastos en Salud Ambulatoria (gAA)
*Gastos en Salud Ambulatoria por hogares (gAA)
foreach x of varlist gAAt gAAd gAAt_* gAAc gAAm gAAe gAAo {
	recode `x' (-2=-2 "Hogar sin pb de salud") ///
	  (-1=-1 "Hogar pb & no tomaron acciones") ///
	  (0=0 "Hogar uso servicio de salud & no gasto") ///
	  (0.001/9.99=1 "de 0 a <10") (10/29.99=2 "de 10 a <30") ///
	  (30/59.99=3 "de 30 a <60") (60/89.99=4 "de 60 a <90") ///
	  (90/max=5 ">90") (missing=.),gen(r`x')
	lab var r`x' `"`: var label `x'' recodificado"'
	}
*Gastos en Salud Ambulatoria por capita/enfermo
foreach x of varlist gAAca gAAen {
	recode `x' (-2=-2 "Hogar sin pb de salud") ///
	  (-1=-1 "Hogar con pb de salud & no tomaron acciones") ///
	  (0=0 "Hogar uso servicio de salud & no gasto") ///
	  (0.01/2.99=1 "de 0 a <3") (3/7.99=2 "de 3 a <8") ///
	  (8/15.99=3 "de 8 a <16") (16/31.99=4 "de 16 a <32") ///
	  (32/max=5 ">90") (missing=.),gen(r`x')
		lab var r`x' `"`: var label `x'' recodificado"'
	}
*Gastos en Salud Ambulatoria por transporte
recode gAAtr (-2=-2 "Hogar sin pb de salud") ///
  (-1=-1 "Hogar pb de salud & no tomaron acciones") ///
  (0=0 "Hogar uso servicio de salud & no gasto") ///
  (0.01/0.49=1 "de 0 a <0,5") (0.5/0.99=2 "de 0,50 a <1") ///
  (1/1.99=3 "de 1 a <2") (2/4.99=4 "de 2 a <5") ///
  (5/max=5 ">5") (missing=.),gen(rgAAtr)
lab var rgAAtr `"`: var label gAAtr' recodificado"'

*Perdida de Ingreso Salud Ambulatoria
recode gAAp (-2=-2 "Hogar sin pb de salud") ///
  (-1=-1 "Hogar con pb de salud & no tomaron acciones") ///
  (0=0 "Hogar uso servicio de salud & no gasto") ///
  (0.01/19.99=1 "de 0 a <20") (20/39.99=2 "de 20 a <40") ///
  (40/max=3 ">40") (missing=.),gen(rgAAp)
lab var rgAAp `"`: var label gAAp' recodificado"'

********************************************************************************
*Gastos en Hospitalizacion (gHP)
*Gastos en Hospitalizacion por enfermo
gen gHPe=gHPt/HP
lab var gHPe "Gastos por persona hospitalizada"
foreach x of varlist gHP* {
	local w=substr("`x'",2,2)
	replace `x'=-2 if  `w'==0
		}

*Recodificacion
foreach x of varlist gHPt gHPe {
	recode `x' (-2=-2 "Hogar sin persona hospitalizada") ///
	  (0=0 "no gasto") ///
	  (0.01/59.99=1 "de 0 a <60") (60/179.99=2 "de 60 a <180") ///
	  (180/max=3 ">180") (missing=.),gen(r`x')
		lab var r`x' `"`: var label `x'' recodificado"'
	}

********************************************************************************
*Gastos en Salud preventiva (gSP)
*Gastos en Salud preventiva per capita
gen gSPca=gSPt/n
lab var gSPca "Gastos en Salud preventiva per capita"

*Gastos en Salud Preventiva (gSP) por persona que recibio el servicio
gen gSPen=gSPt/SP
replace gSPen=0 if gSPt==0
lab var gSPen "Gastos en Salud Preventiva por persona que recibio el servicio"

foreach x of varlist gSP* {
	local w=substr("`x'",2,2)
	replace `x'=-2 if  `w'==0
		}

*Recodificacion
recode gSPt (-2=-2 "Hogar sin persona hospitalizada") ///
  (0=0 "no gasto") ///
  (0.01/9.99=1 "de 0 a <10") (10/29.99=2 "de 10 a <30") ///
  (30/max=3 ">30") (missing=.),gen(rgSPt)
	lab var rgSPt `"`: var label gSPt' recodificado"'

foreach x of varlist gSPca gSPen {
	recode `x' (-2=-2 "Hogar sin persona hospitalizada") ///
	  (0=0 "no gasto") ///
	  (0.01/1.99=1 "de 0 a <2") (2/7.99=2 "de 2 a <8") ///
	  (8/max=3 ">8") (missing=.),gen(r`x')
		lab var r`x' `"`: var label `x'' recodificado"'
	}

********************************************************************************
*Gastos en Control prenatal
foreach x of varlist gCP* {
	local w=substr("`x'",2,2)
	replace `x'=-2 if  `w'==0
	replace `x'=-1 if  `w'n==0
	}
foreach x of varlist gCP* {
	recode `x' (-2=-2 "Hogar sin personas hospitalizadas") ///
	  (-1=-1 "Hogar con embarazadas sin control prenatal") (0=0 "no gasto") ///
	  (0.01/9.99=1 "de 0 a <10") (10/29.99=2 "de 10 a <30") ///
	  (30/max=3 ">30") (missing=.),gen(r`x')
	lab var r`x' `"`: var label `x'' recodificado"'
	}
********************************************************************************
*Gastos en Parto
foreach x of varlist gAP* {
	local w=substr("`x'",2,2)
	replace `x'=-2 if  `w'==0
		}
foreach x of varlist gAP* {
	recode `x' (-2=-2 "Hogar sin mujeres que dieron a luz") ///
	  (0=0 "no gasto") ///
	  (0.01/29.99=1 "de 0 a <30") (30/59.99=2 "de 30 a <60") ///
	  (60/179.99=3 "de 60 a <180") (180/max=4 ">180") (missing=.),gen(r`x')
	lab var r`x' `"`: var label `x'' recodificado"'
	}
*Analisis de Gastos en servicios de salud ENSANUT 2012 termina ahi *************
