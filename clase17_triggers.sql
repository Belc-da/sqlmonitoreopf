## CLASE 17 - TRIGGERS ##

-- Mostrar triggers existentes --

use sakila;
show triggers;

#
-- Sintaxis de creación

drop database if exists clase17_triggers;
create database clase17_triggers;
use clase17_triggers;

DROP TABLE IF EXISTS cliente;
CREATE TABLE cliente (
id_cliente INT PRIMARY KEY,
nombre VARCHAR(10) NOT NULL
);

select * from cliente;
DESCRIBE cliente;

DROP TABLE IF EXISTS log_cliente;
CREATE TABLE log_insercion_cliente (
id_log INT PRIMARY KEY auto_increment,
id_cliente INT NOT NULL,
nombre VARCHAR(10),
usuario VARCHAR(50),
fecha_hora DATETIME 
);

CREATE TABLE log_modificacion_cliente (
id_log INT PRIMARY KEY auto_increment,
id_cliente INT NOT NULL,
nombre_viejo VARCHAR(10),
nombre_nuevo VARCHAR(10),
usuario VARCHAR(50),
fecha_hora DATETIME 
);


## Ejemplos

# Log de evento de inserción
-- Creación
DROP TRIGGER IF EXISTS log_insercion_cliente;
CREATE TRIGGER log_insercion_cliente
AFTER INSERT ON cliente
FOR EACH ROW
INSERT INTO log_insercion_cliente VALUES (DEFAULT, new.id_cliente, new.nombre, user(), now());

-- Lo probamos:
select * from log_insercion_cliente;
INSERT INTO cliente VALUES (7, 'agus');
INSERT INTO cliente VALUES (1, 'roberto');
select * from log_insercion_cliente;

# Log de evento de modificación
-- Creación
DROP TRIGGER IF EXISTS log_modificacion_cliente;
CREATE TRIGGER log_modificacion_cliente
AFTER UPDATE ON cliente
FOR EACH ROW
INSERT INTO log_modificacion_cliente VALUES (DEFAULT, old.id_cliente, old.nombre, new.nombre, user(), now());

-- Lo probamos:
select * from log_modificacion_cliente;
update cliente set nombre='juani' WHERE id_cliente=1;
select * from log_modificacion_cliente;
truncate log_modificacion_cliente;

# Trigger para evitar inserción vacía
-- Supongamos que queremos evitar que se inserten valores nulos (NULL) en el campo nombre de la tabla cliente.
-- Pero también queremos evitar que se inserten valores vacíos ('').
-- Lo podemos evitar con un trigger:
DROP TRIGGER IF EXISTS chequeo_vacios_cliente;
DELIMITER $$
CREATE TRIGGER chequeo_vacios_cliente
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
	IF new.nombre = '' THEN
		signal sqlstate '45000';
	END IF;
END $$
DELIMITER ;

-- Lo probamos:
INSERT INTO cliente VALUES (3, 'sofia');
INSERT INTO cliente VALUES (5, '');
SELECT * FROM CLIENTE;
DESCRIBE CLIENTE;

## No se puede utilizar un trigger que devuelva una tabla como resultado
DROP TRIGGER IF EXISTS prueba_select;
DELIMITER $$
create trigger prueba_select
AFTER INSERT on cliente
FOR EACH ROW
BEGIN
	SELECT * FROM CLIENTE;
END $$
DELIMITER ;
-- Va a tirar Error Code 1415

## Pero sí se puede usar una consulta sql para obtener una variable, o como subquery
create table tabla_log_cantidad_clientes (
id_registro int primary key auto_increment,
cantidad_clientes int,
nombre_cliente varchar(20)
);

DROP TRIGGER IF EXISTS trigger_con_select_y_variable;
DELIMITER $$
create trigger trigger_con_select_y_variable
BEFORE INSERT on cliente
FOR EACH ROW
BEGIN
	SET @cantidad_clientes = (SELECT COUNT(*) FROM cliente);
	INSERT INTO tabla_log_cantidad_clientes values (DEFAULT, @cantidad_clientes, new.nombre);
END $$
DELIMITER ;

select * from cliente;
select * from tabla_log_cantidad_clientes;
insert into cliente (id_cliente, nombre) values (2, 'martina');

-- Notar que no es lo mismo si el trigger es BEFORE o AFTER.
-- Tal como fue explicado en clase, la @cantidad_clientes va a ser distinta en cada caso.
-- En un trigger BEFORE, el trigger se ejecuta antes de que el nuevo registro sea insertado en la tabla cliente.
-- Por lo tanto, la cantidad de clientes no va a contar al cliente nuevo que se va a insertar.
-- En un trigger AFTER, el trigger se ejecuta después de que el nuevo registro sea insertado en la tabla cliente.
-- Por lo tanto, la cantidad de clientes sí va a contar al cliente nuevo que se insertó.

## Funciones integradas
select CURRENT_TIMESTAMP();
select current_time();
select curtime();
select now();

select user();
select session_user();
select system_user();

select database();
select version();