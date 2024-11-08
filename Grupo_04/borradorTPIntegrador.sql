  /*
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
Cada grupo deberá generar una DB con un nombre distinto. Para ello usarán el nombre de la
comisión y del grupo como denominador de la DB. Por ejemplo “Com3900G02”. Note que es
una versión abreviada del nomenclador de las entregas. El formato es ComXXXXGYY donde
XXXX es el código de comisión e YY es el numero de grupo con cero a la izquierda de ser
necesario.
*/
--entrega 3: Creacion de base de datos, tablas, esquemas y stored procedures
/*
GRUPO 04
COMISION 5600
FECHA: 1-11
INTEGRANTES:
Ezequiel Muñoz Palazzo DNI :46700923
Churquina Diego Sebastián DNI: 40394243

--CREACIÓN DE LA BASE DE DATOS Y LOS ESQUEMAS
create database Com5600G04;
*/
use Com5600G04;
go

create schema catalogo;
go
create schema ventasSucursal;
go
CREATE SCHEMA SUCURSAL;
GO

--CREACIÓN DE LAS TABLAS
create or alter procedure catalogo.crear_tabla_producto as
begin
	create table catalogo.producto(
	id int primary key,
	categoria varchar(100),
	nombre varchar(100),
	precio varchar(50),
	precio_referencia varchar(50),
	unidad_referencia varchar(50),
	fecha date);
end
go
create or alter procedure catalogo.crear_tabla_accesorio_electronico as
begin
	create table catalogo.accesorio_electronico(
	id int identity(1,1) primary key,
	producto varchar(100),
	precioUnitUsd numeric(10, 2) check (precioUnitUsd > 0)
	);
end
go
create or alter procedure catalogo.crear_tabla_producto_importado as
begin
	create table catalogo.producto_importado(
	idProducto int primary key,
	NombreProducto varchar(100),
	Proveedor varchar(100),
	Categoria varchar(50),
	CantidadPorUnidad varchar(50),
	PrecioUnidad numeric (10, 2) check (precioUnidad > 0)
	);
end
go
create or alter procedure SUCURSAL.crear_tabla_sucursal as
begin
	create table SUCURSAL.sucursal(
	id int identity(1,1) primary key,
	ciudad varchar(50),
	direccion varchar(100) unique,
	horario varchar(50),
	telefono char(15),
	baja char(2) default 'NO',
	);
end
go
create or alter procedure SUCURSAL.crear_tabla_empleado as
begin
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
end
go
create or alter procedure ventasSucursal.crear_tabla_ventas_registradas as
begin
	create table ventasSucursal.venta_registrada(
	id_factura varchar(11) primary key ,
	tipo_de_factura char(1),
	ciudad varchar(50),
	tipo_de_cliente varchar(50),
	genero varchar(20),
	producto varchar(100),
	precio_unitario float,
	cantidad smallint,
	fecha date,
	hora time,
	medio_de_pago varchar(50),
	empleado_id int,
	identificador_de_pago varchar(50),
	constraint fk_ventas foreign key (empleado_id) references SUCURSAL.empleado(legajoId)
	);
end
GO

--stored procedures
/*
inserción
actualización
eliminación
*/

--REGISTRAR SUCURSALES

CREATE PROCEDURE SUCURSAL.REGISTRAR_SUCURSAL(@CIUDAD VARCHAR(20), @DIRECCION VARCHAR(70), @HORARIO VARCHAR(30), @TELEFONO CHAR(15)) 
AS INSERT INTO SUCURSAL.SUCURSAL(ciudad, direccion, horario, telefono) VALUES (@CIUDAD, @DIRECCION, @HORARIO, @TELEFONO);

--BAJA DE SUCURSALES
GO;

CREATE PROCEDURE SUCURSAL.BAJAR_SUCURSAL(@ID INT)
AS UPDATE SUCURSAL.sucursal SET BAJA = 'SI' WHERE ID = @ID;

--ALTA SUCURSALES
GO;
CREATE PROCEDURE SUCURSAL.ALTA_SUCURSAL(@ID INT)
AS UPDATE SUCURSAL.SUCURSAL SET BAJA = 'NO' WHERE ID = @ID;

GO;
--REGISTRAR EMPLEADOS
CREATE PROCEDURE SUCURSAL.REGISTRAR_EMPLEADO(@NOMBRE VARCHAR(20), @APELLIDO VARCHAR(20),@DNI CHAR(9), @DIRECCION VARCHAR(100), @MAILPERSONAL VARCHAR(50), @MAILEMPRESARIAL VARCHAR(50), @CUIL CHAR(12),
											 @CARGO VARCHAR(20), @SUCURSAL VARCHAR(20), @TURNO VARCHAR(20)) AS
INSERT INTO SUCURSAL.empleado(nombre, apellido, dni, direccion, email_personal, email_empresarial, cuil, cargo,  sucursal, turno) VALUES (@NOMBRE, @APELLIDO, @DNI, @DIRECCION, @MAILPERSONAL, @MAILEMPRESARIAL, @CUIL, @CARGO, @SUCURSAL, @TURNO);

--BAJA DE EMPLEADOS
GO;

CREATE PROCEDURE SUCURSAL.BAJAR_EMPLEADO(@LEGAJO INT)
AS UPDATE SUCURSAL.EMPLEADO SET BAJA = 'SI' WHERE legajoId = @LEGAJO;

--ALTA EMPLEADOS
GO;
CREATE PROCEDURE SUCURSAL.ALTA_EMPLEADO(@LEGAJO INT)
AS UPDATE SUCURSAL.EMPLEADO SET BAJA = 'NO' WHERE LEGAJOID = @LEGAJO;

--REGISTRAR PRODUCTOS
GO;
CREATE PROCEDURE CATALOGO.REGISTRAR_PRODUCTO(@CATEGORIA VARCHAR(30), @NOMBRE VARCHAR(30),@PRECIO NUMERIC(10,2), @PRECIO_REFERENCIA NUMERIC(10,2), @UNIDAD_REFERENCIA VARCHAR(5), @FECHA DATE) AS
INSERT INTO CATALOGO.PRODUCTO VALUES (@CATEGORIA, @NOMBRE, @PRECIO, @PRECIO_REFERENCIA, @UNIDAD_REFERENCIA, @FECHA);

-- BAJA DE PRODUCTOS
GO;
CREATE PROCEDURE CATALOGO.ELIMINAR_PRODUCTO(@ID INT) AS
DELETE FROM CATALOGO.PRODUCTO WHERE ID = @ID;

--REGISTRO DE ACCESORIOS ELECTRÓNICOS
GO;
CREATE PROCEDURE CATALOGO.REGISTRAR_ACCESORIOS_ELECTRONICOS(@PRODUCTO VARCHAR(20), @PRECIO_UNIT_USD NUMERIC(10, 2))
AS INSERT INTO CATALOGO.ACCESORIO_ELECTRONICO VALUES (@PRODUCTO, @PRECIO_UNIT_USD);

--BAJA DE ACCESORIOS ELECTRÓNICOS
GO;
CREATE PROCEDURE CATALOGO.ELIMINAR_ACCESORIOS_ELECTRONICOS(@ID INT)
AS DELETE FROM CATALOGO.ACCESORIO_ELECTRONICO WHERE ID = @ID;

--REGISTRAR PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.REGISTRAR_PRODUCTO_IMPORTADO(@NOMBRE VARCHAR(20), @PROVEEDOR VARCHAR(20), @CATEGORIA VARCHAR(20), @CANT_POR_UNIDAD INT,  @PRECIO_UNIDAD NUMERIC(10, 2))
AS INSERT INTO CATALOGO.PRODUCTO_IMPORTADO(NombreProducto, proveedor, categoria, CantidadPorUnidad, PrecioUnidad) VALUES (@NOMBRE, @PROVEEDOR, @CATEGORIA, @CANT_POR_UNIDAD, @PRECIO_UNIDAD);

--BAJA PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.BAJA_PRODUCTO_IMPORTADO(@ID INT)
AS DELETE FROM CATALOGO.PRODUCTO_IMPORTADO WHERE IDPRODUCTO = @ID;

-- MODIFICAR NOMBRE PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO_IMPORTADO(@ID INT, @NOMBRE VARCHAR(20))
AS UPDATE CATALOGO.producto_importado SET NOMBREPRODUCTO = @NOMBRE WHERE IDPRODUCTO = @ID;

-- MODIFICAR PROVEEDOR PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PROVEEDOR_PRODUCTO_IMPORTADO(@ID INT, @PROVEEDOR VARCHAR(20))
AS UPDATE CATALOGO.producto_importado SET PROVEEDOR = @PROVEEDOR WHERE IDPRODUCTO = @ID;

-- MODIFICAR CATEGORIA PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO_IMPORTADO(@ID INT, @CATEGORIA VARCHAR(20))
AS UPDATE CATALOGO.producto_importado SET CATEGORIA = @CATEGORIA WHERE IDPRODUCTO = @ID;

-- MODIFICAR CANTIDAD POR UNIDAD PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_CANT_POR_UNIDAD_PRODUCTO_IMPORTADO(@ID INT, @CANT INT)
AS UPDATE CATALOGO.producto_importado SET CANTIDADPORUNIDAD = @CANT WHERE IDPRODUCTO = @ID;

-- MODIFICAR PRECIO POR UNIDAD PRODUCTO IMPORTADO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO_IMPORTADO(@ID INT, @PRECIO NUMERIC(10, 2))
AS UPDATE CATALOGO.producto_importado SET PRECIOUNIDAD = @PRECIO WHERE IDPRODUCTO = @ID;

-- MODIFICAR PRODUCTO ACCESORIOS ELECTRÓNICOS
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PRODUCTO_ACCESORIOS_ELECTRONICOS(@ID INT, @PRODUCTO VARCHAR(20))
AS UPDATE CATALOGO.accesorio_electronico SET PRODUCTO = @PRODUCTO WHERE ID = @ID;

-- MODIFICAR PRECIO ACCESORIOS ELECTRÓNICOS
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_ACCESORIOS_ELECTRONICOS(@ID INT, @PRECIO NUMERIC(10, 2))
AS UPDATE CATALOGO.accesorio_electronico SET PRECIOUNITUSD = @PRECIO WHERE ID = @ID;

--MODIFICAR CATEGORICA PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO(@ID INT, @CAT VARCHAR(30))
AS UPDATE CATALOGO.PRODUCTO SET CATEGORIA = @CAT WHERE ID = @ID;

--MODIFICAR CATEGORICA PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO(@ID INT, @NOMBRE VARCHAR(30))
AS UPDATE CATALOGO.PRODUCTO SET NOMBRE = @NOMBRE WHERE ID = @ID;

--MODIFICAR CATEGORIA PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO(@ID INT, @PRECIOREF NUMERIC(10,2))
AS UPDATE CATALOGO.PRODUCTO SET PRECIO_REFERENCIA = @PRECIOREF WHERE ID = @ID;

--MODIFICAR PRECIO PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO(@ID INT, @PRECIO NUMERIC(10, 2))
AS UPDATE CATALOGO.PRODUCTO SET PRECIO = @PRECIO WHERE ID = @ID;

--MODIFICAR UNIDAD DE REFERENCIA PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA_PRODUCTO(@ID INT, @UNIDAD VARCHAR(5))
AS UPDATE CATALOGO.PRODUCTO SET UNIDAD_REFERENCIA = @UNIDAD WHERE ID = @ID;

--MODIFICAR FECHA PRODUCTO
GO;
CREATE PROCEDURE CATALOGO.ACTUALIZAR_FECHA_PRODUCTO(@ID INT, @FECHA DATE)
AS UPDATE CATALOGO.PRODUCTO SET FECHA = @FECHA WHERE ID = @ID;

--MODIFICAR DIRECCION SUCURSAL
GO;
CREATE PROCEDURE SUCURSAL.ACTUALIZAR_DIRECCION_SUCURSAL(@ID INT, @DIRECCION VARCHAR(70))
AS UPDATE SUCURSAL.SUCURSAL SET DIRECCION = @DIRECCION WHERE ID = @ID;

--MODIFICAR HORARIO SUCURSAL
GO;
CREATE PROCEDURE SUCURSAL.ACTUALIZAR_HORARIO_SUCURSAL(@ID INT, @HORARIO VARCHAR(30))
AS UPDATE SUCURSAL.SUCURSAL SET HORARIO = @HORARIO WHERE ID = @ID;

--MODIFICAR DIRECCION SUCURSAL
GO;
CREATE PROCEDURE SUCURSAL.ACTUALIZAR_TELEFONO_SUCURSAL(@ID INT, @TELEFONO VARCHAR(70))
AS UPDATE SUCURSAL.SUCURSAL SET DIRECCION = @TELEFONO WHERE ID = @ID;

--INVALIDAR VENTA
GO;
CREATE PROCEDURE VENTASSUCURSAL.INVALIDAR_VENTA(@ID INT)
AS UPDATE VENTASSUCURSAL.VENTA_REGISTRADA SET VALIDA = 'NO' WHERE ID_FACTURA = @ID;

--VALIDAR VENTA
GO;
CREATE PROCEDURE VENTASSUCURSAL.VALIDAR_VENTA(@ID INT)
AS UPDATE VENTASSUCURSAL.VENTA_REGISTRADA SET VALIDA = 'SI' WHERE ID_FACTURA = @ID;