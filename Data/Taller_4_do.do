/*==============================================================================

						EVALUACIÓN DE IMPACTO (2025-1)
					 Taller diferencias en diferencias

--------------------------------------------------------------------------------

==============================================================================*/

*===============================================================================*
*								Inicializar Stata								*
*===============================================================================*

* Configuraciones iniciales
clear all
cls
set more off, perm

cd "xxxxx"


* Abro la base en Stata
use "SoapOperas2.dta", replace

*===============================================================================*
*							Pistas Taller 4							            *
*===============================================================================*

*-------------------------- Configuraciones inciales --------------------------*

* Recorderis: deben eliminar aleatoriamente el 5% de las observaciones
* Recuerden que para esto, deben usar una semilla con su código de estudiante

set seed 1234 // En vez de 1234 deben poner su código de estudiante. 


gen binomial = rbinomial(1,0.05) // En vez de x, deben poner el porcentaje de observaciones 
							  // que quieren que les marque como 1
drop if binomial==1

* Asi mismo, recuerden que deben restringir la base de datos hasta el percentil 95% 
* del tamaño del área

* Para ver esto, pueden hacer un sum detallado

sum geoarea80, detail	
return list		
keep if geoarea80 <= r(p95)			  

*---------------------------------- Punto 1 ---------------------------------*

* Especificación sin controles pero con correcciones por sobremuestreo, efectos
* fijos de año y clusters por área. 

*) i. Sin controles ni efectos fijos de área

reghdfe B globocoverage1 [pweight = weight], absorb(year) cluster(amc_code)
outreg2 ...reghdfe prop i.Corrupt, absorb(clavedelaescuela year) 
*outreg2 using "regresiones2.doc", append word keep(i.Corrupt) dec(3) nocons addtext(Controles, No, Efectos Fijos, Sí)

*) ii. Sin controles pero con efectos fijos de área
reghdfe B globocoverage1 [pweight = weight], absorb(amc_code year) 				///
	cluster(amc_code)
	
/* Recuerden que como controles deben incluir las variables:  	
1. married
2. yrsedu_head
3. wealth_noTV
4. catholic
5. rural
6. Doctors 
7. ipc_renta
8. age 
9. agesq
10. stock 
11. stocksq					
*/

*) iii. Con controles y con efectos fijos de área
global controles married yrsedu_head wealth_noTV catholic rural Doctors ipc_renta age  	///
	agesq stock stocksq
reghdfe B globocoverage1 $controles [pweight = weight], absorb(amc_code year) 				///
	cluster(amc_code)

	
*---------------------------------- Punto 2 ---------------------------------*

* Restringiendo la muestra por edad de la mujer. Esto se hace con un if!
* Por ejemplo, para las mujeres entre 15 y 24, lo puedo hacer así: 

reghdfe B globocoverage1 if age>=15 & age<25 [w=weight], absorb(year) cluster(amc_code)

* Aquí es mejor que lo hagan con un if en vez de hacerle drop a las observaciones. 
* Así: i) no editan los datos y ii) evitan tener que cargar la base cada vez que vayan a correr una regresion. 

*) opción 2
reghdfe B globocoverage1 [pweight = weight] if inrange(age,15,24),				///
	absorb(year) cluster(amc_code)
outreg ...	
*---------------------------------- Punto 4 ---------------------------------*

* Esto es súper fácil porque resulta que las variables interactuadas ya existen 
* en la base!

* Por ejemplo, hagámoslo para los años de educación de la cabeza del hogar: 

reghdfe B globocoverage1 yrsedu_head cov1eduhd [w=weight], absorb(year) cluster(amc_code)

* También exite la variable interactuada para los años de educación de la mujer, 
* y la riqueza del hogar. 

* Sin embargo, también pueden ustedes mismos crear esta variable de interaccion. 

gen interaccion = globocoverage1*yrsedu_head

reghdfe B globocoverage1 yrsedu_head interaccion [w=weight], absorb(year) cluster(amc_code)

* Otra manera de hacerlo, puede ser: 

reghdfe B i.globocoverage1##c.yrsedu_head [w=weight], absorb(year) cluster(amc_code)

* De las tres formas, obtenemos exactamente los mismos resultados. 

* Alguna idea de cómo interpretar el coeficiente de la interacción?
