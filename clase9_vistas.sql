## VISTAS ##


# Trabajamos con Sakila

use sakila;


# Creación de vistas

-- Se desea enviar mails promocionales a los clientes regularmente. Para esto, se necesita un reporte de los clientes del local 1, que incluya sus nombres y sus emails.
-- Creamos una vista que traiga los nombres y mails de los clientes de la tienda 1:
select * from customer;
create view clientes_tienda1 as (select first_name, last_name, email from customer where store_id=1);



# Utilización de vistas

-- Vemos que nos trae
select * from clientes_tienda1;

-- Podemos realizar querys sobre la vista, como si fuera una tabla
select *, concat(first_name, ' ', last_name) as full_name from clientes_tienda1;



# Eliminación de vistas

drop view clientes_tienda1;



# Reemplazar una vista ya existente

-- El [or replace] nos permite sobreecribir una vista ya creada, en caso de que ya exista.
create view clientes_tienda1 as (select first_name, last_name, email from customer where store_id=1);
create or replace view clientes_tienda1 as (select concat(first_name, ' ', last_name) as full_name , email from customer where store_id=1);
select * from clientes_tienda1;
drop view clientes_tienda1;



# Cambio de nombre de las columnas

-- Cambiamos los nombres de las columnas que se muestran en la vista, en comparación con los nombres originales.
create or replace view clientes_tienda1 as (select concat(first_name, ' ', last_name) as full_name, email from customer where store_id=1);
create or replace view clientes_tienda1 (nombre_completo, correo_electronico) as (select concat(first_name, ' ', last_name) as full_name, email from customer where store_id=1);
-- Notar que la cantidad de nombres indicados debe coincidir con la cantidad de columnas que devuelve la vista.

select * from clientes_tienda1 where nombre_completo like 'M%';

create view vista2 as (select * from clientes_tienda1);
select * from vista2;

# Alteración de una vista

alter view clientes_tienda1 as (select * from film);

select * from country;
select * from actor;
select * from film;
create view pelis_lenguages as (select f.title, l.name as language from film f inner join language l on f.language_id=l.language_id);

select * from pelis_lenguages;



# Inserción mediante vistas

-- Es posible la inserción, eliminación o modificación de registros mediante una vista.
-- Hay que ser cuidadosos, porque la modificación mediante vistas va a modificar las tablas que alimentan a la vista.
select * from clientes_tienda1;
update clientes_tienda1 set full_name='Mary Smith' where email='MARY.SMITH@sakilacustomer.org';



# Práctica con vistas

-- La empresa sakila desea premiar cada mes a los tres clientes más fieles. Estos están definidos como los clientes que desembolsaron la mayor cantidad de dinero en pagos de alquiler de películas. Específicamente, se quiere conocer su nombre, apellido y correo, además del importe pagado durante el mes.
-- Se desea obtener la información de junio de 2005. Para esto, es necesario crear una vista que, basada en las tablas “customer” y “payment” devuelva un informe con la información solicitada.

create view clientes_fieles as 
(SELECT 
    first_name, last_name, email, SUM(amount) total_payed
FROM
    payment p
        INNER JOIN
    customer c ON p.customer_id = c.customer_id
WHERE
    MONTH(payment_date) = 06
        AND YEAR(payment_date) = 2005
GROUP BY p.customer_id
ORDER BY total_payed DESC
LIMIT 3);