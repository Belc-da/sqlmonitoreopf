##Creación de la base de datos para Monitoreo de Plazos Fijos del Banco X

CREATE DATABASE monitoreo_pf;
USE monitoreo_pf;

/*Creación de la tabla CLIENTE, que contiene información de la persona 
titular de cuenta/cuentas del banco.
*/

CREATE TABLE Cliente (
cuit_cuil INT NOT NULL PRIMARY KEY,
titular VARCHAR(30) NOT NULL,
sector VARCHAR(20) NOT NULL,
pais VARCHAR(20) NOT NULL,
tipo_persona VARCHAR(20) NOT NULL,
UNIQUE KEY (cuit_cuil)
);

#Pruebo como queda la tabla
SELECT * FROM cliente;
#Detalle de cada campo
DESCRIBE cliente;

/*Creación de la tabla CUENTA, que contiene información de la/las cuentas de los clientes.
*/

CREATE TABLE Cuenta (
numero_cuenta INT NOT NULL PRIMARY KEY,
sucursal VARCHAR(20) NOT NULL,
pais VARCHAR(20) NOT NULL,
estado VARCHAR(20) NOT NULL,
cuit_cuil INT NOT NULL,
FOREIGN KEY (cuit_cuil) REFERENCES cliente(cuit_cuil),
UNIQUE KEY (numero_cuenta)
);

#Pruebo como queda la tabla
SELECT * FROM cuenta;
#Detalle de cada campo
DESCRIBE cuenta;

/*Creación de la tabla MONEDA, que contiene los tipos de moneda con su código de moneda
*/

CREATE TABLE Moneda (
id_moneda INT NOT NULL PRIMARY KEY,
moneda VARCHAR(20) NOT NULL,
UNIQUE KEY (id_moneda)
);

#Pruebo como queda la tabla
SELECT * FROM moneda;
#Detalle de cada campo
DESCRIBE moneda;

/*Creación de la tabla MODULO, que contiene los productos y el número de módulo que le correspone
*/

CREATE TABLE Modulo (
numero_modulo INT NOT NULL PRIMARY KEY,
nombre_producto VARCHAR(20) NOT NULL,
tipo_producto VARCHAR(30) NOT NULL,
UNIQUE KEY (numero_modulo)
);

#Pruebo como queda la tabla
SELECT * FROM modulo;
#Detalle de cada campo
DESCRIBE modulo;

/*Creación de la tabla ESPECIE, que contiene las especies con las que se opera
*/

CREATE TABLE Especie (
numero_especie INT NOT NULL PRIMARY KEY,
tipo_especie VARCHAR(20) NOT NULL,
UNIQUE KEY (numero_especie)
);

#Pruebo como queda la tabla
SELECT * FROM especie;
#Detalle de cada campo
DESCRIBE especie;

/*Creación de la tabla PIZARRA, que contiene las tasas para cada tipo de plazo fijo
*/

CREATE TABLE Pizarra (
numero_pizarra INT NOT NULL PRIMARY KEY,
tipo_plazo_fijo VARCHAR(20) NOT NULL,
id_moneda INT NOT NULL,
FOREIGN KEY (id_moneda) REFERENCES moneda(id_moneda),
tipo_tasa VARCHAR(20) NOT NULL,
numero_especie INT NOT NULL, 
FOREIGN KEY (numero_especie) REFERENCES especie(numero_especie),
tasa FLOAT NOT NULL,
vigencia DATE NOT NULL,
UNIQUE KEY (numero_pizarra)
);

#Pruebo como queda la tabla
SELECT * FROM pizarra;
#Detalle de cada campo
DESCRIBE pizarra;

/*Creación de la tabla TIPO_OPERACIÓN, que contiene los tipos de operación para cada pizarra y módulo
*/

CREATE TABLE Tipo_operacion (
id_tipo_operacion INT NOT NULL PRIMARY KEY,
tipo_operacion VARCHAR(20) NOT NULL,
numero_pizarra INT NOT NULL,
FOREIGN KEY (numero_pizarra) REFERENCES pizarra(numero_pizarra),
numero_modulo INT NOT NULL, 
FOREIGN KEY (numero_modulo) REFERENCES modulo(numero_modulo),
UNIQUE KEY (id_tipo_operacion)
);

#Pruebo como queda la tabla
SELECT * FROM tipo_operacion;
#Detalle de cada campo
DESCRIBE tipo_operacion;

/*Creación de la tabla PLAZO FIJO, que contiene información del producto Plazo Fijo que tiene el cliente.
*/

CREATE TABLE Plazo_fijo (
numero_operacion INT NOT NULL PRIMARY KEY,
numero_cuenta INT NOT NULL,
FOREIGN KEY (numero_cuenta) REFERENCES cuenta(numero_cuenta),
id_tipo_operacion INT NOT NULL,
FOREIGN KEY (id_tipo_operacion) REFERENCES tipo_operacion(id_tipo_operacion),
id_moneda INT NOT NULL,
FOREIGN KEY (id_moneda) REFERENCES moneda(id_moneda),
suboperacion INT NOT NULL,
capital FLOAT NOT NULL,
fecha_origen DATE NOT NULL,
fecha_vencimiento DATE NOT NULL,
UNIQUE KEY (numero_operacion)
);

#Pruebo como queda la tabla
SELECT * FROM Plazo_fijo;
#Detalle de cada campo
DESCRIBE Plazo_fijo;