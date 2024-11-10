 /*
Luego de decidirse por un motor de base de datos relacional, llego el momento de generar la
base de datos.
Deber? instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicacion de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaria al DBA.

Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Debera entregar
un archivo .sql con el script completo de creacion (debe funcionar si se lo ejecuta tal cual es
entregado). Incluya comentarios para indicar que hace cada modulo de codigo.

Genere store procedures para manejar la inserci?n, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con SP.

Genere esquemas para organizar de forma logica los componentes del sistema y aplique esto
en la creacion de objetos. NO use el esquema dbo.

El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, numero de grupo, nombre de la materia, nombres y DNI de los alumnos.

Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la secci?n de pr?cticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
Cada grupo debera generar una DB con un nombre distinto. Para ello usaran el nombre de la
comision y del grupo como denominador de la DB. Por ejemplo Com3900G02. Note que es
una version abreviada del nomenclador de las entregas. El formato es ComXXXXGYY donde
XXXX es el codigo de comision e YY es el numero de grupo con cero a la izquierda de ser
necesario.
*/
--entrega 3: Creacion de base de datos, tablas, esquemas y stored procedures

/*
GRUPO 04
COMISION 5600
FECHA: 1-11
INTEGRANTES:
Ezequiel Muñoz Palazzo DNI :46700923
Churquina Diego Sebastian DNI: 40394243
*/

--CREACION DE LA BASE DE DATOS Y LOS ESQUEMAS
create database Com5600G04;
go
use Com5600G04;
go

create schema catalogo;
go
create schema ventasSucursal;
go
CREATE SCHEMA SUCURSAL;
GO

--CREACION DE LAS TABLAS
create table catalogo.producto(
	id int IDENTITY(1, 1) primary key,
	categoria varchar(30),
	nombre varchar(30),
	precio numeric(10, 2) check (precio > 0),
	precio_referencia numeric(10, 2) check (precio_referencia > 0),
	unidad_referencia varchar(5),
	fecha date
);
go

create table catalogo.accesorio_electronico(
	id int identity(1,1) primary key,
	producto varchar(20),
	precioUnitUsd numeric(10, 2) check (precioUnitUsd > 0)
);
go

create table catalogo.producto_importado(
	idProducto int primary key,
	NombreProducto varchar(20),
	Proveedor varchar(20),
	Categoria varchar(20),
	CantidadPorUnidad int CHECK (CANTIDADPORUNIDAD >= 0),
	PrecioUnidad numeric (10, 2) check (precioUnidad > 0)
);
go

create table SUCURSAL.sucursal(
	id int identity(1,1) primary key,
	ciudad varchar(20),
	direccion varchar(70),
	horario varchar(30),
	telefono char(15),
	baja char(2) default 'NO',
);
go

create table SUCURSAL.empleado(
	legajoId int identity(1,1) primary key,
	nombre varchar(20),
	apellido varchar(20),
	dni char(9),
	direccion varchar(100),
	email_personal varchar(50),
	email_empresarial varchar(50),
	cuil char(12),
	cargo varchar(20),
	sucursal varchar(20),
	turno varchar(20), 
	baja char(2) default 'NO',
);
go

create table ventasSucursal.venta_registrada(
	id_factura varchar(11) primary key ,
	tipo_de_factura char(1),
	ciudad varchar(20),
	tipo_de_cliente varchar(10),
	genero varchar(10),
	producto varchar(50),
	precio_unitario float,
	cantidad smallint,
	fecha date,
	hora time,
	medio_de_pago varchar(10),
	empleado_id int,
	identificador_de_pago varchar(30),
	valida char(2) default 'si',
	constraint fk_ventas foreign key (empleado_id) references SUCURSAL.empleado(legajoId)
);
go