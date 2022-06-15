USE sakila;

## Stored procedures ##


# Sintaxis básica:
-- Creamos un procedure que muestre los primeros n registros de una tabla
DROP PROCEDURE IF EXISTS primers_n_actores;
DELIMITER $$
CREATE PROCEDURE primeros_n_actores (IN cantidad_filas INT)
BEGIN
	SELECT * FROM actor LIMIT cantidad_filas;
END $$
DELIMITER ;

-- Llamamos al procedimiento
CALL primeros_n_actores (3);
CALL primeros_n_actores (200);

-- Notar que utilizamos un parámetro de entrada. Es necesario especificarlo al momento de hacer la llamada al procedimiento.

SELECT * FROM film_category;
SELECT * FROM category;

SELECT count(*) FROM film_category WHERE category_id = (SELECT category_id FROM category WHERE name = 'Action');

# Parámetros de entrada y de salida
-- Creamos un procedure que devuelva la cantidad de películas que pertenecen a una categoría específica
DROP PROCEDURE IF EXISTS cantidad_pelis_genero;
DELIMITER $$
CREATE PROCEDURE cantidad_pelis_genero (IN nombre_categoria VARCHAR(20), OUT cantidad_pelis INT)
BEGIN
	SELECT count(*) INTO cantidad_pelis FROM film_category WHERE category_id = (SELECT category_id from category WHERE name = nombre_categoria);
END $$
DELIMITER ;

-- Llamamos al procedimiento
#En call solo se guarda la
CALL cantidad_pelis_genero ('Action', @cantidad_peliculas_accion);
select @cantidad_peliculas_accion AS cantidad_peliculas_accion;
CALL cantidad_pelis_genero ('Drama', @cantidad_peliculas_drama);
select @cantidad_peliculas_drama AS cantidad_peliculas_drama;

-- Notar que agregamos un parámetro de salida. Al llamar al procedimiento, es necesario especificar el nombre de la variable donde queremos guardar el resultado de procedimiento


# Procedimiento con muchos parámetros
-- Creamos un procedimiento que devuelva la cantidad de películas que pertenecen a un género, y las longitudes máxima y mínima de las películas pertenecientes al género.
DROP PROCEDURE IF EXISTS cantidad_pelis_genero;
DELIMITER $$
CREATE PROCEDURE cantidad_pelis_genero (IN nombre_categoria VARCHAR(20), OUT cantidad_pelis INT, OUT max_longitud INT, OUT min_longitud INT)
BEGIN
	SELECT count(*) INTO cantidad_pelis FROM film_category WHERE category_id = (SELECT category_id from category WHERE name = nombre_categoria);
    SELECT max(length) INTO max_longitud FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name=nombre_categoria;
    SELECT min(length) INTO min_longitud FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name=nombre_categoria;
END $$
DELIMITER ;

-- Llamamos al procedimiento
CALL cantidad_pelis_genero ('Action', @cantidad_peliculas_accion, @maxima_duracion_accion, @minima_duracion_accion);
select @cantidad_peliculas_accion AS cantidad_peliculas_accion, @maxima_duracion_accion AS max_duracion, @minima_duracion_accion AS min_duracion;
CALL cantidad_pelis_genero ('Drama', @cantidad_peliculas_drama, @maxima_duracion_drama, @minima_duracion_drama);
select @cantidad_peliculas_drama AS cantidad_peliculas_drama, @maxima_duracion_drama AS max_duracion, @minima_duracion_drama AS min_duracion;


# Agregamos condicionales
-- Quiero verificar si una pelicula específica pertenece a un género específico
-- Voy a indicar un film_id y un género (varchar), y voy a esperar que el procedimiento me devuelva un mensaje indicando si la peli pertenece o no al género indicado.
-- Antes de chequear si el film_id pertenece al género, voy a querer chequear si la peli está registrada en la tabla film.

#Estructura del condicional:
#IF se cumple una condición THEN haceme-esto

DROP PROCEDURE IF EXISTS peli_pertenece_genero;

DELIMITER $$
CREATE PROCEDURE peli_pertenece_genero (IN nombre_categoria VARCHAR(20), IN id_peli INT)
BEGIN
	IF id_peli NOT IN (SELECT film_id FROM film) THEN
		SELECT 'La peli no se encuentra en la base de datos' AS Mensaje;
	ELSEIF id_peli IN (SELECT f.film_id FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name=nombre_categoria) THEN
		SELECT 'Sí, pertenece' AS Mensaje;
	ELSE
		SELECT 'No pertenece' AS Mensaje;
	END IF;
END $$
DELIMITER ;

-- Llamamos al procedimiento
CALL peli_pertenece_genero ('Action', 1);
CALL peli_pertenece_genero ('Documentary', 1);
CALL peli_pertenece_genero ('Documentary', 1001);

-- Notar que la condición a cumplir, especificada en la 1mera parte del IF (entre "if" y "then"), puede ser una condición de igualdad (=), desigualdad (>, por ej) u otra condicion que se pueda utilizar en el WHERE de una consulta SELECT
-- Notar que se pueden agregar muchas condiciones a cumplir, usando ELSEIF tantas veces como sea necesario.
-- Notar que no utilizamos parámetros de salida, ya que en este caso solo queríamos enviar un mensaje como resultado del stored procedure.

# Seteamos variables
-- Creamos un procedure que traiga la diferencia entre la máxima y mínima longitud entre las películas de una categoría específica
DROP PROCEDURE IF EXISTS rango_longitud_categoria;
DELIMITER $$
CREATE PROCEDURE rango_longitud_categoria (IN nombre_categoria VARCHAR(20), OUT rango INT)
BEGIN
	SET @maxima_long = (SELECT max(length) FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name= nombre_categoria);
    SET @minima_long = (SELECT min(length) FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name= nombre_categoria);
    SET @rango = @maxima_long - @minima_long;
    SELECT @rango INTO rango;
END $$
DELIMITER ;

SELECT max(length) FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name= 'Action';
SELECT min(length) FROM film f INNER JOIN film_category fc ON f.film_id=fc.film_id INNER JOIN category c ON fc.category_id=c.category_id WHERE c.name= 'Action';

-- Llamamos al procedimiento
CALL rango_longitud_categoria ('Action', @rango_accion);
SELECT @rango_accion AS Rango_pelis_accion;

-- Notar que, si bien utilizamos SET para definir las variables dentro del stored procedure, utilizamos "SELECT <variable> INTO <parametro_salida>" para indicar que la variable definida va a ser el output del procedimiento almacenado.

# Convertir string en cláusula
-- En este último ejemplo vamos a querer modificar las cláusulas de la consulta SELECT en función del input que indiquemos al llamar al stored procedure.
-- Con este procedure vamos a querer ordenar los registros de una tabla, en función de una columna que le indiquemos como parámetro de entrada.
-- Con un segundo parámetro de entrada, vamos a querer especificar si el ordenamiento en ascendente o descendente.
DROP PROCEDURE IF EXISTS ordenamiento_film;
delimiter $$
CREATE PROCEDURE ordenamiento_film (IN campo_a_ordenar VARCHAR(50), IN orden BOOLEAN)
-- orden=1 -> asc
-- orden=0 -> desc
-- Notar que si campo_a_ordenar='' entonces no importa el orden
BEGIN
	IF campo_a_ordenar <> '' AND orden = 1 THEN
		SET @ordenar = concat('ORDER BY ', campo_a_ordenar);
	ELSEIF campo_a_ordenar <> '' AND orden = 0 THEN
		SET @ordenar = concat('ORDER BY ', campo_a_ordenar, ' DESC');
	ELSEIF campo_a_ordenar <> '' AND orden NOT IN (0,1) THEN
		SET @ordenar = 'No válido';
		SELECT 'Parámetro de ordenamiento ingresado no válido' AS Mensaje;
    ELSE
		SET @ordenar = '';
	END IF;
    IF @ordenar <> 'No válido' THEN
		SET @clausula_select = concat('SELECT * FROM film ', @ordenar);
		PREPARE ejecucion FROM @clausula_select;
		EXECUTE ejecucion;
		DEALLOCATE PREPARE ejecucion;
	END IF;
END $$
delimiter ;
CALL ordenamiento_film('rental_duratio',0);

-- Los comandos PREPARE, EXECUTE y DEALLOCATE PREPARE se usan en ese orden, para ejecutar una sentencia que fue armada concatenando más de una cadena de caracteres.

# Ejemplo inserción
DROP PROCEDURE IF EXISTS nueva_categoria;
DELIMITER $$
CREATE PROCEDURE nueva_categoria (IN nombre varchar(25))
BEGIN
	INSERT INTO category VALUES (DEFAULT, nombre, DEFAULT);
END $$
DELIMITER ;

select * from category;
CALL nueva_categoria('Western');
select * from category where name='Western';

# Diferencias entre functions & stored procedures (Link a hilo en stackoverflow)
# https://stackoverflow.com/questions/2680745/whats-the-differences-between-stored-procedures-functions-and-routines