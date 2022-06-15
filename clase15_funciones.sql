drop database if exists clase15_funciones;
create database clase15_funciones;
use clase15_funciones;

﻿/*CREAR FUNCION PARA SUMAR DOS NÚMEROS*/

DELIMITER $$
CREATE FUNCTION SUMA_ENTEROS(NRO1 INT, NRO2 INT) 
RETURNS int
DETERMINISTIC
BEGIN
	DECLARE RESULTADO INT;
    SET RESULTADO = NRO1 + NRO2;
	RETURN RESULTADO;
END$$
DELIMITER ;

-- LLAMAR A LA FUNCIÓN

SELECT SUMA_ENTEROS(1,3);


/*CREAR FUNCIÓN PARA CALCULO DE PINTURA*/

DELIMITER #
drop function if exists suma_enteros; 
CREATE FUNCTION LITROS_PINTURA(LARGO FLOAT, ALTO FLOAT, Q_MANOS INT)
RETURNS DECIMAL(10,2)   
DETERMINISTIC
BEGIN
	DECLARE LITRO_X_METRO DECIMAL (10,2);
    DECLARE M2_PARED FLOAT;
    DECLARE LITROS_TOTALES DECIMAL(10,2); 
    
    SET LITRO_X_METRO = 0.1;	
	SET M2_PARED = LARGO * ALTO;
    SET LITROS_TOTALES = M2_PARED * LITRO_X_METRO * Q_MANOS;
    
    RETURN LITROS_TOTALES;
    
END#
DELIMITER ;

-- LLAMAR A LA FUNCIÓN
SELECT LITROS_PINTURA(10,10,1);

#Para recuperar el código de la funcion se posiciona en la SCHEMAS/"BASE DE DATOS"/FUNCITON, te posicionas en la funcion, CLICK DERECHO 
#Copy to Clipboard Create Statement y ahi podes pegar el código en el script. 

SELECT 
	  P.*
    , LITROS_PINTURA(P.ALTO, LARGO, 1) UNA_MANO
    , LITROS_PINTURA(ALTO, LARGO, 2) DOS_MANOS
    , LITROS_PINTURA(ALTO, LARGO, 3) TRES_MANOS
FROM clase15.PARED AS P;



/* SAKILA */
USE sakila;

/*CREAR FUNCIÓN PARA CALCULAR PELICULAS DE UN ACTOR*/
DELIMITER #
DROP FUNCTION IF EXISTS Q_PELICULAS#
CREATE FUNCTION Q_PELICULAS(PARAM_ACTOR INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE PELICUAS_ACTUADAS INT;
    
    SELECT COUNT(FILM_ID) INTO PELICUAS_ACTUADAS
	FROM FILM_ACTOR
	WHERE ACTOR_ID = PARAM_ACTOR;
    
    RETURN PELICUAS_ACTUADAS;
    
END#
DELIMITER ;

SELECT A.*
	, Q_PELICULAS(ACTOR_ID)
FROM ACTOR A;


/*FUNCIÓN PARA OBTENER EL IDIOMA*/
DELIMITER $$
DROP FUNCTION IF EXISTS get_language_film$$
CREATE FUNCTION GET_LANGUAGE_FILM(ID_IDIOMA INT) 
RETURNS varchar(50)
READS SQL DATA
BEGIN
	DECLARE IDIOMA_DE_PELICULA VARCHAR(50);

	SELECT NAME INTO IDIOMA_DE_PELICULA
	FROM LANGUAGE
	WHERE LANGUAGE_ID = ID_IDIOMA;
	
    RETURN IDIOMA_DE_PELICULA;
    
END$$
DELIMITER ;

-- USO DE LA FUNCIÓN
select 
title,
language_id,
GET_LANGUAGE_FILM(LANGUAGE_ID) as language_name
from film A;

-- ESTO REEMPLAZARÍA A ESTA OTRA QUERY
select 
title,LANGUAGE_ID, NAME
from film A INNER JOIN LANGUAGE ON A.LANGUAGE_ID = B.LANGUAJE_ID;

/* IMPLEMENTACIÓN DE UN CICLO EN UNA FUNCIÓN*/
use clase15_funciones;

# Creamos una tabla solo para poder usarla a modo de ejemplo
create table nombre_tabla (id int primary key);

delimiter $$
drop function if exists ciclo_insercion$$
create function ciclo_insercion (inicio int, fin int)
returns varchar(60)
deterministic
begin
	declare contador int;
    declare cantidad int;
    declare mensaje varchar(60);
    
    select inicio-fin into cantidad;
    set contador=1;
    
    while contador<cantidad+1 do
		insert into nombre_tabla values (contador);
        set contador=contador+1;
	end while;
    
    set mensaje = concat('Cantidad de registros insertados: ',cantidad);
	return mensaje;
end $$
delimiter ;

select prueba_loop(5,1);