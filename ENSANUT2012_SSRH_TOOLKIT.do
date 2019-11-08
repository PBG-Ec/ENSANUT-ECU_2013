********************************************************************************
* ENCUESTAS DE SALUD REPRODUTIVA ENSANUT-ECU 2012
* MINISTERIO DE SALUD PUBLICA DEL ECUADOR
* TOOLKIT PARA LA GENERACION DE VARIABLES EN LOS COMPONENTES DE:
* SALUD SEXUAL Y REPRODUCTIVA DE HOMBRES:
*i Caracteristicas de la poblacion de hombres
*ii Actividad Sexual y Salud Reproductiva en Hombres
*iii Planificacion Familial Hombres
*iv Infeccion de Trasmision Sexual Hombres
********************************************************************************
*Coordinadora de la Investigacion ENSANUT 2011-2014: Wilma Freire.
*Investigadores y autores del informe:
*  Elaboracion:  Philippe Belmont Guerron philippebelmont@gmail.com
*  Gabriela Rivas Marino gabrielarm19@gmail.com

********************************************************************************
**************Encuesta Nacional de Salud y Nutricion 2012-2014******************
********************I. Caracteristicas de la poblacion de hombres  *************
********************************************************************************
clear all
set more off
set matsize 8000
*Instalar estout (paquete de formateo de cuadros)
*findit estout
*Directorio de bases (esta sintaxis tiene dependencias con las bases:
*ensanut_f1_personas y ensanut_f9_salud_reproductiva):
cd ""

*Preparacion de bases
use "ensanut_f9_salud_reproductiva.dta",clear
*Identificador de personas / Hogar / vivienda
cap drop id*
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

*Merge de variables de cruce:
merge 1:1 idpers using "ensanut_f1_personas.dta", ///
  keepusing(provincia subreg zonas_planificacion gr_etn ///
  area pd04a pd04b pd04c dia mes anio pd02 pd03 edadanio ///
  quint pse01 pse07a pa01 pa07 pd10a pd11a pd14 pd15 ///
  pd16 pd17 pd19a pd19b)
drop if _merge==2
drop _merge

*Svyset:
svyset idsector [pweight=pw], strata (area)


*Grupos de edad
recode pd03 (12/14=1 "12-14") (15/49=2 "15-49"),gen (gedad)
lab var gedad "grupos de edad9"

*grupos de edad de 15 a19 y 20a 24 anios
recode pd03  (12/14=.)(15/19=1 "15-19") (20/24=2 "20-24") ///
  (25/49=.)(mis=.), gen (gr_edex)
lab var gr_edex "Grupos de edad 15 a 24"

*Grupos Edad 15 a 49 anios
recode pd03 (12/14=1 "12-14") (15/19=2 "15-19") (20/24=3 "20-24") ///
  (25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39") (40/44=7 "40-44") ///
  (45/49=8 "45-49") (mis=.), gen(gedad2)
lab var gedad2  "grupos de edad mef de 15 a 49"

*Estado civil simpl.:
recode pd14 (1/2=1 "UnidoCasado") (3/5=3 "DivorSeparViudo") ///
  (6=2 "Soltero"), gen(est_civ)

*Estado civil
recode pd14 (1/2=1 "Unido_casado") (3 4 6 =2 "Soltero_Sep.") ///
  (5=3 "Viudo"), gen(eciv)
*Tipo de seguro
recode pse01 (1/3=1 "Publico")  (4=3 "Sin seguro"), gen (pse1)
recode pse07a (1 5=2 "Privado") (2/4=1 "Publico")  (6=6 "no tiene"), gen (pse7a)
gen pse2= pse1*10 + pse7a
recode pse2 (11 16 31=1 "Publico unicamente") (12=2 "Publico y privado")  ///
    (32=3 "Privado unicamente") (36=4 "No tiene"), gen (psee)
drop pse1 pse7a pse2
lab var psee "Tipo de seguro"


*situacion de empleo generacion de variable
gen sit_e=pa07
replace sit_e=3 if pa01==6 | pa01==7
lab def sit_e 1 "Dentro del hogar" 2 "Fuera del hogar " 3 "No trabaja" , replace
lab val sit_e sit_e
lab var sit_e "Situacion de empleo"

*situacion migratoria combinacion de variables necesarias para el cruce
recode pd11a (1=1) (2=2) (.=3)
gen migrac= pd10a*10 + pd11a
recode migrac (13 21=1 "Nativo") (22=2 "Migrante"),gen (sit_mi)
lab var sit_mi "situacion migratoria"

*Nivel de educacion.(segun INEC)
gen pd19ab=pd19a*100+pd19b
recode pd19ab (100=1 "Sin estudios") ///
  (200/202 401/405 600/606=2 "Primaria incompleta") ///
  (203 406 607 =3  "Primaria completa") ///
  (701 702 501/505 608/610 =4 "Secundaria incompleta") ///
  (506 703 =5 "Secundaria completa") ///
  (801/803 901/903 =6 "Hasta 3 anios de educacion superior") ///
  (904/908=7 "4 o mas anios de educacion superior (sin post grado)") ///
  (1001/1003=8 "Post grado"),gen(educ)
lab var educ "Nivel de instruccion"

*Nivel educacion Simplificado:
recode educ (1=1 "Ninguno") (2/3=2 "Primaria") ///
  (4/5=3 "Segundaria") (6/max=4 "Superior"),gen (educa)
lab var educa "Nivel de instruccion 4 cat."


*Causas por las que dejaron de estudiar
gen cne=pd17
replace cne=11 if pd16==1
lab def pd17 11 "Sigue estudiando", add
lab val cne pd17
lab var cne "causas para dejar de estudiar"

********************************************************************************
*Analisis de Caractersticas de hombres ENSANUT termina ahi**********************

********************************************************************************
*************************II. Actividad sexual y salud reprodutiva***************
**************************************de  hombres*******************************
********************************************************************************

*Actividad Sexual:
recode f9201 (1=1 "Si") (2=2 "No") (else=.), gen(desa)

*Edad a la 1era relacion: f9202 *12 a 14 y de 15 a 24 anios
set seed 221729
gen fsexage=f9202 if f9202<41 & pd03>=15 & pd03<=24 & f9202!=.
replace fsexage=100 if  f9201==2 & pd03>=15 & pd03<=24
replace fsexage=999 if f9202 >40 & pd03>=15 & pd03<=24 & f9202!=.

foreach x of numlist 15 18 20 22 25{
    gen ps`x'=(fsexage>0 & fsexage<`x')*100
    lab var ps`x' `"Edad 1era rel.sex. < a los `x'"'
     }
gen psever=(fsexage>0 & fsexage<100)*100 if fsexage!=999 & fsexage!=.
lab var psever "Alguna vez unida"
gen psnever=(fsexage!=. & fsexage==100)*100 if fsexage!=999 & fsexage!=.
lab var psnever "Soltero"
gen pstiempo=fsexage if fsexage!=999
replace pstiempo = pd03 if fsexage == 100
replace pstiempo=pstiempo+uniform()
recode fsexage (100=0) (else=1),gen(psstatus)

********************************************************************************
*Analisis de Actividad sexual de hombres ENSANUT termina ahi********************

********************************************************************************
*************************III. Planificaction Familiar en  hombres***************
********************************************************************************

*Svyset
svyset idsector [pweight=pw], strata (area)

*Conoce al menos un met. anticep.
*No ha constestado a ninguna de las preguntas:nmiss==.
gen al_mc = .
forval x = 1/14{
replace al_mc = 1 if f9105`x'  == 1
}
replace al_mc = 2 if al_mc == .
lab var al_mc "Al menos 1 metodo es conocido"
lab def sino 1 "si" 2 "no", replace
lab val  al_mc sino

*Conoce al menos un met. moderno
gen al_mm = .
foreach x of numlist 1 2 3 4 5 6 7 8 11 12 13{
replace al_mm = 1 if f9105`x'  == 1
}
replace al_mm = 2 if al_mm == .
lab var al_mm ">=1.met.moderno conocido"
lab val  al_mm sino

*Conoce al menos un met. anticep. tradi. *retiro/ritmo/otro
gen al_mt = .
foreach x of numlist 9 10 14{
	replace al_mt = 1 if f9105`x'  == 1
	}
replace al_mt = 2 if al_mt == .
lab var al_mt ">=1 met.tradi. es conocido"
lab val  al_mt sino

*Usa al menos un met. Moderno  actualmente:
egen nmiss = rsum(f91071 f91072 f91073 f91074 f91075 f91076 f91077 ///
  f91078 f910712 f910713),mis
gen u_mm=.
foreach x of numlist 1 2 3 4 5 6 7 8 12 13{
	replace u_mm = 1 if f9107`x' == 1
	}
replace u_mm = 2 if u_mm== .
replace u_mm =. if nmiss== .
lab var u_mm "Usa al menos un metodo moderno"
lab val u_mm sino
********************************************************************************
*Usa al menos un met. anticep. tradi. *retiro/ritmo/OTRO
drop nmiss
egen nmiss = rsum(f91079 f910710 f910711 f910714),mis
gen u_mt = .
foreach x of numlist 9/11 14{
	replace u_mt = 1 if f9105`x'  == 1
	}
replace u_mt = 2 if u_mt == .
lab var u_mt "Usa >=1 met.tradi."
lab val  u_mt sino

*f9106* *Ha Usado al menos un metodo anticeptivo:
drop nmiss
egen nmiss = rsum(f9106*) , missing
gen au_mc=.
forval x = 1/14{
	replace au_mc = 1 if f9106`x' == 1
	}
replace au_mc = 2 if au_mc== .
replace au_mc =. if nmiss== .
lab var au_mc "Ha usado al menos un metodo"
lab val au_mc sino

*Ha usado al menos un met. Moderno  actualmente:
drop nmiss
egen nmiss = rsum(f91061 f91062 f91063 f91064 ///
  f91065 f91066 f91067 f91068 f910612 f910613),mis
gen au_mm=.
foreach x of numlist 1 2 3 4 5 6 7 8 12 13{
replace au_mm = 1 if f9106`x' == 1
}
replace au_mm = 2 if au_mm== .
replace au_mm =. if nmiss== .
lab var au_mm "Ha usado al menos un metodo moderno"
lab val au_mm sino
drop nmiss
*Usa al menos un met. anticep. tradi. *retiro/ritmo/OTRO
egen nmiss = rsum(f91069 f910610 f910611 f910614),mis
gen au_mu=.
gen au_mt = .
foreach x of numlist 9/11 14 {
replace au_mt = 1 if f9105`x'  == 1
}
replace au_mt = 2 if au_mt == .
lab var au_mt "Ha usado >=1 met.tradi."
lab val  au_mt sino
********************************************************************************
*Brechas entre ha usado y conocimiento
gen br_mc = al_mc*10+au_mc
lab var br_mc ">=1 Metodo Brecha entre conocimiento y uso"
lab def br 11 "Conoce y usa" 12 "Conoce y no usa" 22 "No conoce no usa", replace
lab val br_mc br
gen br_mm = al_mm*10+au_mm
lab var br_mm ">=1 Metodo Mod.Brecha entre conocimiento y uso"
lab val br_mm br
gen br_mt = al_mt*10+au_mt
lab var br_mt ">=1 Metodo trad.Brecha entre conocimiento y uso"
lab val br_mt br
forval x = 1/14{
	gen f910b`x' = f9105`x'*10+f9106`x'
	lab val f910b`x'  br
	lab var f910b`x' `"Brecha :`: var label f9105`x''"'
}

********************************************************************************
*Usa o ha usado un metodo anticeptivo f9107* Usa actualmente f9106* Ha usado

*Variable Metodo mas efectivo de usos pasados
gen mp_ef=.
foreach x in 9 10 8 7 11 12 5 3 4 6 2 1 {
    replace mp_ef=`x' if f9106`x'==1
    }
egen nousop=anycount(f91061 f91062 f91063 f91064 f91065 ///
  f91066 f91067 f91068 f91069 f910610 f910611 f910612),values(2)
replace mp_ef=13 if nousop==12 | mp_ef==.
recode mp_ef (1=1 "Vasectomia") (2=2 "Ester fem") (6=3 "DIU") ///
  (4=4 "Inyeccion") (3=5 "Implante") (5=6 "Pastillas") (12=7 "Mela") ///
   (11=8 "Metodos vaginales") (7=9 "Codon masculino") (8=10 "Condon femenino") ///
  (10=11 "Ritmo") (9=12 "Retiro") (13=13 "No usan"),gen(m_hu)

*Variable Metodo mas efectivo de uso Actual
gen ma_ef=.
foreach x in 9 10 8 7 11 12 5 3 4 6 2 1 {
    replace ma_ef=`x' if f9107`x'==1
    }
egen nousoa=anycount(f91071 f91072 f91073 f91074 f91075 ///
   f91076 f91077 f91078 f91079 f910710 f910711 f910712),values(2)
replace ma_ef=13 if nousop==12 | ma_ef==.
recode ma_ef (1=1) (2=2) (6=3) (4=4) (3=5) (5=6) (12=7) (11=8) (7=9) (8=10) ///
  (10=11) (9=12) (13=13),gen(m_ua)
lab val m_ua m_hu
drop ma_ef nousoa mp_ef nousop
*Recodificacion de variables para cruces *Variables Usan/No usan
recode m_hu (1/12=1 "Ha Usado un metodo") (13=2 "No ha usado"), gen(gm_hu)
recode m_ua (1/12=1 "Usa un metodo") (13=2 "No usa"), gen(gm_ua)

*Estado civil recodificado
recode pd14 (1/2=1 "Unido_casado") (3 4 5 6 =2 "Soltero,separado,viudo") ///
  (4=.), gen(ecivs)


********************************************************************************
*Analisis de Planificacion familiar en hombres ENSANUT termina ahi**************

********************************************************************************
*****************IV. Infeccion de transmision sexual en hombres*****************
********************************************************************************

*Svyset
svyset idsector [pweight=pw], strata (area)

*Conocimiento de Infeccciones de transmision sexual + VIH SIDA(espont|.dir.)
*Conocimiento de ITS : dirigido(f9303) + espontaneo(f9302*):
foreach x of newlist a b c d e f g h i j k{
	gen f9399`x'=f9302`x'*10+f9303`x'
	recode f9399`x' (11=1) (21=1) (22=2)
	lab val f9399`x' f9302`x'
	local lbl =subinstr(`"`: var label f9302`x''(+dirigido)"', ///
	  "1`x'. ha oido hablar - ","3`x'. ",.)
	lab var f9399`x' "`lbl'"
	}

*Numero de metodos preventivos para la contagion de VIH
gen nprev=0
foreach x of varlist f9310*{
	replace nprev= nprev+1 if `x'==1
}
replace nprev=. if f9304==3
recode nprev (0=0) (1=1) (2/max=2)
lab def nprev 0 "No conoce" 1 "Una" 2 "Dos o mas"
lab val nprev nprev
lab var nprev "No. de metodos de prevencion conocidos (VIH/SIDA)"

*Conocimiento espontaneo de 3 formas de prevencion VIH
*variable para las tres en conjuntos (GJ)
gen npre3=0
foreach x of varlist f9310a f9310b f9310c{
	replace npre3= npre3+1 if `x'==1
}
replace npre3=2 if npre3<3
replace npre3=1 if npre3==3
replace npre3=. if f9304==3
lab def npre3 1 "Conoce las 3 formas" 2 "Conoce menos de 3" ,replace
lab val npre3 npre3
lab var npre3 "Conocimiento de las 3 formas primarias de prevencion"

*Lugar de realizacion de la ultima prueba
recode f9317 (1/3=1 "MSP") (4/5=2 "IESS") (6=3 "FFAA/Policia") ///
  (7=4 "Clinica/medico privado") (9=5 "Cruz roja") (11=6 "Clinica ONG") ///
  (8=7 "Junta de Beneficencia") (10 12 13 =8 "Otros*"),gen(lu_pr)
label var lu_pr "Donde se hizo la prueba del VIH"

*Voluntariedad de realizacion de la ultima prueba VIH
lab def f9318 1 "Voluntad propia" ///
  2 "Tener que presentar resultados" 3 "Otro", modify
lab val f9318 f9318

*Tiempo a la fecha de la  realizacion de la ultima prueba VIH
gen t_p=f9316d*12 + f9316a/30.4368 + f9316b/4.34812 + f9316c
replace t_p=. if t_p==0
replace t_p=9999 if f9316a==77
recode t_p (min/11=1 "menos de 12 meses") (12/23=2 "12-23 meses") ///
  (24/35=3 "24-35 meses") (36/47=4 "36-47 meses") ///
  (48/360=5 "48 o mas meses") (9999=6 "No recuerda"), gen(trp_vih)
label var trp_vih "Tiempo desde el ultimo despistaje"
drop t_p

*Razon de no realizacion, realizacion prueba VIH
*f9322 (clases ENDEMAIN 2004):
recode f9322 (1=1) (2=2) (3/4=3) (5=4) (6=5) (10=6) (11=7) (12 7/9=8) ///
  (88/99=9) (mis=.),gen(rz_nrp)
lab def rz_nrp 1 "No ha considerado necesario" ///
  2 "Temor confidencialidad" ///
  3 "Oposicion pareja_familiares" ///
  4 "Temor al resultado" 5 "no ha tenido tiempo" ///
  6 "Falta de dinero muy caro" 7 "Nunca indicado_recomendado" ///
  8 "Otra" 9 "NSNR",replace
lab val rz_nrp rz_nrp
lab var rz_nrp "Razon x la que nunca se ha hecho el examen de sida"

*Recepcion de informacion en prueba VIH
*f9319 f9320 f9321

*Razon para no hacerse la prueba de VIH si fuera gratuito
recode f9324 (1=1 "no lo necesita") ///
  (2=2 "temor a falta de confidencialidad") ///
  (3=3 "oposicion de la pareja") (7 9 10=4 "Otro") ///
  (5=5 "temor al resultado") (6=6 "no tiene tiempo") ///
   (8=7 "dicen que el personal de salud regana") ///
  (88/99=8 "no sabe no responde") (mis=.),gen(rz_nhp)
lab var rz_nhp "Razon x la que no se haria el examen si fuera gratis"

*Percepcion de riesgo de infectarse del VIH/SIDA
*f9307 "Cree que usted tiene el peligro de infectarse con SIDA"

*Razon de riesgo de infectarse del VIH/SIDA
*f9308. razon x la que puede infectarse con sida
gen rz_pri=f9308
replace rz_pri=10 if rz_pri==5 | rz_pri==6
replace rz_pri=88 if rz_pri==99
lab def rz_pri 1 "su pareja tiene mas parejas" 2 "Pareja pasa fuera" ///
  3 "no sabe como protegerse" 4 "su pareja rechaza el condon" ///
  5 "ya ha tenido its" 6 "por ser trabajadora sexual" ///
  7 "no usa siempre condon" 8 "No conoce promisc pareja" ///
  9 "Pareja consum_alcohol/droga" ///
  10 "otra, cual"	88 "NS NR"
lab val rz_pri rz_pri
lab var rz_pri "Razones de posible infeccion (VIH)"

*Razon conocida no riesgo de infectarse del VIH/SIDA
gen rz_pnr=f9309
replace rz_pnr=11 if rz_pnr==3 | rz_pnr==8 | rz_pnr==9
replace rz_pnr=88 if rz_pnr==99
lab def f9309 88 "NS NR" , modify
lab val rz_pnr f9309
lab var rz_pnr "Razones de no infeccion (VIH)"

*Uso del condon: f9204

*Dispocion  del uso del condon
*f9205 Si le pide la pareja estaria disp. a uso de condon.
* f9303c==1 conoce VIH/SIDA

*Actividad Sexual:
cap recode f9201 (1=1 "Si") (2=2 "No") (else=.), gen(desa)

********************************************************************************
*Analisis deInfeccion de transmision sexual en hombres ENSANUT termina ahi******
