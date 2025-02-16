--CREACION DE STORED PROCEDURES
USE Com5600G04;
GO

SP_CONFIGURE 'show advanced options' ,1;
go
reconfigure;
GO
SP_CONFIGURE 'Ole Automation Procedures', 1;
go
reconfigure;
GO

--REGISTRAR SUCURSALES
CREATE OR ALTER PROCEDURE SUCURSAL.REGISTRAR_SUCURSAL(@CIUDAD VARCHAR(20), 
@DIRECCION VARCHAR(70), @HORARIO VARCHAR(30), @TELEFONO CHAR(15)) AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM SUCURSAL.SUCURSAL WHERE DIRECCION = @DIRECCION AND CIUDAD = @CIUDAD)
		INSERT INTO SUCURSAL.SUCURSAL(ciudad, direccion, horario, telefono) 
		VALUES (@CIUDAD, @DIRECCION, @HORARIO, @TELEFONO)
	ELSE
	BEGIN
		UPDATE SUCURSAL.SUCURSAL SET CIUDAD = @CIUDAD, HORARIO = @HORARIO, TELEFONO = @TELEFONO WHERE DIRECCION = @DIRECCION AND CIUDAD = @CIUDAD
	END
END
GO

--BAJA DE SUCURSALES
CREATE OR ALTER PROCEDURE SUCURSAL.BAJAR_SUCURSAL(@ID INT) AS 
BEGIN
	UPDATE SUCURSAL.sucursal SET BAJA = getdate() WHERE ID = @ID
	UPDATE SUCURSAL.EMPLEADO SET BAJA = GETDATE() WHERE SUCURSAL = @ID
END
GO

--ALTA SUCURSALES
CREATE OR ALTER PROCEDURE SUCURSAL.ALTA_SUCURSAL(@ID INT) AS 
BEGIN
	UPDATE SUCURSAL.SUCURSAL SET BAJA = NULL WHERE ID = @ID
END
GO

--REGISTRAR EMPLEADOS
CREATE OR ALTER PROCEDURE SUCURSAL.REGISTRAR_EMPLEADO(@NOMBRE VARCHAR(20), 
@APELLIDO VARCHAR(20), @DNI INT, @LEGAJO INT, @DIRECCION VARCHAR(100), @MAILPERSONAL VARCHAR(50), 
@MAILEMPRESARIAL VARCHAR(50), @CUIL CHAR(12), @CARGO VARCHAR(20), @SUCURSAL VARCHAR(20), 
@TURNO VARCHAR(20)) AS
BEGIN
	DECLARE @SUCURSALID INT = (SELECT CAST(ID AS INT) FROM SUCURSAL.SUCURSAL WHERE CIUDAD = @SUCURSAL);
	IF @SUCURSALID IS NULL
		RAISERROR('LA SUCURSAL %s NO EXISTE', 10, 1, @SUCURSAL)
	ELSE
	BEGIN
		IF (SELECT TOP(1) BAJA FROM SUCURSAL.SUCURSAL WHERE CIUDAD = @SUCURSAL) IS NOT NULL
			RAISERROR(N'LA SUCURSAL %s FUE DADA DE BAJA', 10, 1, @SUCURSAL)
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM SUCURSAL.EMPLEADO WHERE DNI = @DNI)
				INSERT INTO SUCURSAL.empleado(nombre, apellido, dni, direccion, 
				email_personal, email_empresarial, cuil, cargo,  sucursal, turno, LEGAJO) 
				VALUES (@NOMBRE, @APELLIDO, @DNI, @DIRECCION, @MAILPERSONAL, @MAILEMPRESARIAL, 
				@CUIL, @CARGO, @SUCURSALID, @TURNO, @LEGAJO);
			ELSE
			BEGIN
				UPDATE SUCURSAL.EMPLEADO SET NOMBRE = @NOMBRE, APELLIDO = @APELLIDO, DIRECCION = @DIRECCION, email_personal = @MAILPERSONAL, email_empresarial = @MAILEMPRESARIAL, CUIL = @CUIL, 
				CARGO = @CARGO, SUCURSAL = @SUCURSALID, TURNO = @TURNO, LEGAJO = @LEGAJO WHERE DNI = @DNI;
			END
		END
	END
END
GO

--BAJA DE EMPLEADOS
CREATE OR ALTER PROCEDURE SUCURSAL.BAJAR_EMPLEADO(@LEGAJO INT) AS 
BEGIN
	UPDATE SUCURSAL.EMPLEADO SET BAJA = getdate() WHERE legajo = @LEGAJO
END
GO

--ALTA EMPLEADOS
CREATE OR ALTER PROCEDURE SUCURSAL.ALTA_EMPLEADO(@LEGAJO INT) AS 
BEGIN
	IF (SELECT BAJA FROM SUCURSAL.SUCURSAL WHERE ID = (SELECT SUCURSAL FROM SUCURSAL.EMPLEADO WHERE LEGAJO = @LEGAJO)) IS NOT NULL
		RAISERROR(N'LA SUCURSAL SLECCIONADA FUE DADA DE BAJA', 10, 1)
	ELSE
		UPDATE SUCURSAL.EMPLEADO SET BAJA = NULL WHERE LEGAJO = @LEGAJO
END
GO

--REGISTRAR PRODUCTOS
CREATE OR ALTER PROCEDURE CATALOGO.REGISTRAR_PRODUCTO(@CATEGORIA VARCHAR(30), 
@NOMBRE VARCHAR(30), @PRECIO NUMERIC(10,2), @PRECIO_REFERENCIA NUMERIC(10,2), @CANT_POR_UNIDAD VARCHAR(25), 
@UNIDAD_REFERENCIA VARCHAR(5), @FECHA DATE, @PROVEEDOR VARCHAR(50)) AS
BEGIN
	DECLARE @URL VARCHAR(MAX) = 'https://dolarapi.com/v1/dolares/oficial'
	DECLARE @OBJ AS INT
	DECLARE @RESPONSETEXT AS VARCHAR(250)
	DECLARE @PRECIOUSD NUMERIC(10, 2)
	EXEC SP_OACREATE 'MSXML2.XMLHTTP', @OBJ OUT

	EXEC SP_OAMETHOD @OBJ, 'Open', NULL, 'get', @URL, 'false'
	EXEC SP_OAMETHOD @OBJ, 'send'
	EXEC SP_OAMETHOD @OBJ, 'responseText', @RESPONSETEXT OUT

	SET @PRECIOUSD = JSON_VALUE(@RESPONSETEXT, '$.compra')
	SET @PRECIOUSD = CAST(@PRECIOUSD AS NUMERIC(10,2))

	EXEC SP_OADESTROY @OBJ

	IF NOT EXISTS (SELECT ID FROM CATALOGO.PRODUCTO WHERE NOMBRE = @NOMBRE)
		INSERT INTO CATALOGO.PRODUCTO(CATEGORIA, NOMBRE, PRECIO, PRECIO_REFERENCIA, CANTPORUNIDAD, UNIDAD_REFERENCIA, FECHA, PRECIOUSD, PROVEEDOR) 
		VALUES (@CATEGORIA, @NOMBRE, @PRECIO, @PRECIO_REFERENCIA, @CANT_POR_UNIDAD, @UNIDAD_REFERENCIA, @FECHA, @PRECIO / @PRECIOUSD, @PROVEEDOR)
	ELSE
		BEGIN
		UPDATE CATALOGO.PRODUCTO SET CATEGORIA = @CATEGORIA, PRECIO = @PRECIO, PRECIO_REFERENCIA = @PRECIO_REFERENCIA, unidad_referencia = @UNIDAD_REFERENCIA,
		PRECIOUSD = @PRECIO / @PRECIOUSD, PROVEEDOR = @PROVEEDOR, CANTPORUNIDAD = @CANT_POR_UNIDAD WHERE NOMBRE = @NOMBRE;
		END
END
GO

-- BAJA DE PRODUCTOS
CREATE OR ALTER PROCEDURE CATALOGO.ELIMINAR_PRODUCTO(@ID INT) AS
BEGIN
	DELETE FROM CATALOGO.PRODUCTO WHERE ID = @ID
END
GO

--MODIFICAR CATEGORIA PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO(@ID INT, @CAT VARCHAR(30))
AS 
BEGIN
	UPDATE CATALOGO.PRODUCTO SET CATEGORIA = @CAT WHERE ID = @ID
END
GO

--MODIFICAR NOMBRE PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO(@ID INT, @NOMBRE VARCHAR(30))
AS 
BEGIN
	UPDATE CATALOGO.PRODUCTO SET NOMBRE = @NOMBRE WHERE ID = @ID
END
GO

--MODIFICAR PRECIO REFERENCIA PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO(@ID INT, 
@PRECIOREF NUMERIC(10,2)) AS 
BEGIN
	UPDATE CATALOGO.PRODUCTO SET PRECIO_REFERENCIA = @PRECIOREF WHERE ID = @ID
END
GO

--MODIFICAR PRECIO PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO(@ID INT, @PRECIO NUMERIC(10, 2))
AS 
BEGIN
	UPDATE CATALOGO.PRODUCTO SET PRECIO = @PRECIO WHERE ID = @ID
END
GO

--MODIFICAR UNIDAD DE REFERENCIA PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA_PRODUCTO(@ID INT, @UNIDAD VARCHAR(5))
AS 
BEGIN
	UPDATE CATALOGO.PRODUCTO SET UNIDAD_REFERENCIA = @UNIDAD WHERE ID = @ID
END
GO

--MODIFICAR FECHA PRODUCTO
CREATE OR ALTER PROCEDURE CATALOGO.ACTUALIZAR_FECHA_PRODUCTO(@ID INT, @FECHA DATE) 
AS
BEGIN
	UPDATE CATALOGO.PRODUCTO SET FECHA = @FECHA WHERE ID = @ID
END
GO

--MODIFICAR DIRECCION SUCURSAL
CREATE OR ALTER PROCEDURE SUCURSAL.ACTUALIZAR_DIRECCION_SUCURSAL(@ID INT, @DIRECCION VARCHAR(70))
AS 
BEGIN
	UPDATE SUCURSAL.SUCURSAL SET DIRECCION = @DIRECCION WHERE ID = @ID
END
GO

--MODIFICAR HORARIO SUCURSAL
CREATE OR ALTER PROCEDURE SUCURSAL.ACTUALIZAR_HORARIO_SUCURSAL(@ID INT, @HORARIO VARCHAR(30))
AS 
BEGIN
	UPDATE SUCURSAL.SUCURSAL SET HORARIO = @HORARIO WHERE ID = @ID
END
GO

--MODIFICAR TEL�FONO SUCURSAL
CREATE OR ALTER PROCEDURE SUCURSAL.ACTUALIZAR_TELEFONO_SUCURSAL(@ID INT, @TELEFONO VARCHAR(70))
AS 
BEGIN
	UPDATE SUCURSAL.SUCURSAL SET DIRECCION = @TELEFONO WHERE ID = @ID
END
GO

--REGISTRO DE CLIENTE
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.REGISTRAR_CLIENTE(@DNI INT, @TIPO VARCHAR(15), @GEN CHAR(1))
AS
IF NOT EXISTS(SELECT 1 FROM VENTASSUCURSAL.CLIENTE WHERE DNI = @DNI)
	INSERT INTO VENTASSUCURSAL.CLIENTE(DNI, TIPO, GENERO) VALUES (@DNI, @TIPO, @GEN)
ELSE
	UPDATE VENTASSUCURSAL.CLIENTE SET TIPO = @TIPO, GENERO = @GEN WHERE DNI = @DNI
GO

--BAJA DE CLIENTE 
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.BAJA_CLIENTE (@DNI INT)
AS UPDATE VENTASSUCURSAL.CLIENTE SET BAJA = GETDATE() WHERE DNI = @DNI
GO
--ALTA DE CLIENTE
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.ALTA_CLIENTE (@DNI INT)
AS UPDATE VENTASSUCURSAL.CLIENTE SET BAJA = NULL WHERE DNI = @DNI
GO

--INVALIDAR VENTA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.INVALIDAR_VENTA(@ID INT)
AS 
BEGIN
	UPDATE VENTASSUCURSAL.VENTA_REGISTRADA SET BAJA = GETDATE() WHERE ID = @ID
	UPDATE VENTASSUCURSAL.FACTURA SET BAJA = GETDATE() WHERE ID = (SELECT id_factura FROM VENTASSUCURSAL.venta_registrada WHERE ID = @ID)
END
GO

--VALIDAR VENTA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.VALIDAR_VENTA(@ID INT)
AS 
BEGIN
	UPDATE VENTASSUCURSAL.VENTA_REGISTRADA SET BAJA = NULL WHERE ID = @ID
	UPDATE VENTASSUCURSAL.FACTURA SET BAJA = NULL WHERE ID = (SELECT id_factura FROM VENTASSUCURSAL.venta_registrada WHERE ID = @ID)
END
GO

--INSERTAR VENTA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.REGISTRAR_VENTA (@CIUDAD VARCHAR(20), @FECHA DATE, @HORA TIME, @EMPLEADO_LEGAJO INT, @ID_FACT CHAR(11), @MEDIO_PAGO VARCHAR(20), @IDENT_PAGO VARCHAR(50)) AS
BEGIN
	DECLARE @EMPLEADO_ID INT = (SELECT ID FROM SUCURSAL.EMPLEADO WHERE LEGAJO = @EMPLEADO_LEGAJO)
	DECLARE @ID INT = (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = @ID_FACT)
	DECLARE @ID_PAGO INT = (SELECT ID FROM VENTASSUCURSAL.MEDIO_PAGO WHERE MEDIO_PAGO LIKE '')
	IF @ID IS NULL OR (SELECT BAJA FROM VENTASSUCURSAL.FACTURA WHERE ID = @ID) IS NOT NULL
			RAISERROR(N'LA FACTURA %s FUE DADA DE BAJA O NO EXISTE', 10, 1, @ID_FACT)
	ELSE
		IF @ID_PAGO IS NULL
			RAISERROR(N'EL MEDIO DE PAGO NO EXISTE', 10, 1)
		ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ventasSucursal.venta_registrada WHERE id_FACTURA = @ID)
			INSERT INTO ventasSucursal.venta_registrada(ID_FACTURA, CIUDAD, FECHA, HORA, EMPLEADO_ID, MEDIO_PAGO, identificador_pago)
			VALUES (@ID, @CIUDAD, @FECHA, @HORA, @EMPLEADO_ID, @ID_PAGO, @IDENT_PAGO)
		ELSE
			UPDATE ventasSucursal.venta_registrada SET CIUDAD = @CIUDAD, FECHA = @FECHA, HORA = @HORA, MEDIO_PAGO = @ID_PAGO, empleado_id = @EMPLEADO_ID, IDENTIFICADOR_PAGO = @IDENT_PAGO
			WHERE id_factura = @ID
	END
END
go
-- SE CREA LA FACTURA, LOS DETALLES Y LA VENTA POR SEPARADO PORQUE NO ENCONTRAMOS MANERA DE GENERAR M�LTIPLES DETALLES PARA UNA FACTURA EN UN SOLO STORED PROCEDURE Y CONSIDERAMOS QUE ES 
--IDEAL QUE CADA FACTURA PUEDA TENER N PRODUCTOS DISTINTOS 
--INSERTAR FACTURA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CREAR_PREFACTURA(@fecha date, @estado varchar(20), @cliente int, @tipo char(1), @ID_FACTURA CHAR(11))
AS
BEGIN
IF (SELECT TOP(1) BAJA FROM VENTASSUCURSAL.CLIENTE WHERE ID = @CLIENTE) IS NOT NULL
		RAISERROR(N'EL CLIENTE ID: %d FUE DADO DE BAJA', 10, 1, @CLIENTE)
IF NOT EXISTS (SELECT 1 FROM ventasSucursal.factura WHERE id_factura = @id_factura)
	BEGIN
		
		INSERT INTO ventasSucursal.factura(cliente_id, fecha, estado, TIPO, id_factura)
		VALUES(@cliente, @fecha, @estado, @TIPO, @id_factura);
	END
ELSE
	BEGIN
		UPDATE ventasSucursal.factura SET FECHA = @FECHA, ESTADO = @ESTADO, cliente_id = @CLIENTE, TIPO = @TIPO WHERE id_factura = @id_factura
	END
END
GO

CREATE OR ALTER PROCEDURE VENTASSUCURSAL.EMITIR_FACT(@ID CHAR(11)) AS
BEGIN
	DECLARE @ID_FACT INT = (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = @ID)
	DECLARE @TOTAL NUMERIC(11, 2) = (SELECT SUM(SUBTOTAL) FROM VENTASSUCURSAL.DETALLE WHERE ID_FACT = @ID_FACT)
	UPDATE VENTASSUCURSAL.FACTURA SET TOTAL = @TOTAL, TOTALIVA = @TOTAL * 1.21 WHERE ID = @ID_FACT
END
GO

CREATE OR ALTER PROCEDURE VENTASSUCURSAL.ACTUALIZAR_PAGO_FACT(@ID CHAR(11), @ESTADO VARCHAR(20)) AS
UPDATE VENTASSUCURSAL.FACTURA SET ESTADO = @ESTADO WHERE ID_FACTURA = @ID
/*
--BAJA DE FACTURA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.BAJA_FACTURA(@ID INT)
AS UPDATE ventasSucursal.factura SET BAJA = GETDATE() WHERE ID = ID
GO

--ALTA DE FACTURA
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.BAJA_FACTURA(@ID INT)
AS UPDATE ventasSucursal.factura SET BAJA = NULL WHERE ID = ID;*/

--REGISTRAR DETALLE DE FACTURA
GO
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CREAR_DETALLE (@CANTIDAD INT, @ID_PROD INT, @ID_FACT CHAR(11)) AS 
BEGIN
	DECLARE @ID INT = (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = @ID_FACT)
	DECLARE @PRECIO NUMERIC(10, 2) = (SELECT PRECIO FROM CATALOGO.PRODUCTO WHERE ID = @ID_PROD)
	DECLARE @SUBTOTAL NUMERIC(11, 2) = @PRECIO * @CANTIDAD
	IF NOT EXISTS (SELECT 1 FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = @ID_FACT) OR (SELECT BAJA FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = @ID_FACT) IS NOT NULL
		RAISERROR('LA FACTURA NO EXISTE O FUE DADA DE BAJA', 1, 1)
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ventasSucursal.DETALLE WHERE ID_FACT = @ID AND ID_PROD = @ID_PROD)
			INSERT INTO ventasSucursal.DETALLE(CANTIDADPROD, PRECIO, SUBTOTAL, ID_PROD, ID_FACT) VALUES (@CANTIDAD, @PRECIO, @SUBTOTAL, @ID_PROD, @ID)
		ELSE
		UPDATE ventasSucursal.DETALLE SET CANTIDADPROD = @CANTIDAD, PRECIO = @PRECIO, SUBTOTAL = @SUBTOTAL WHERE ID_PROD = @ID_PROD AND ID_FACT = @ID
	END
END
--ELIMINAR DETALLE 
GO
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.ELIMINAR_DETALLE(@ID int)
AS DELETE FROM ventasSucursal.DETALLE WHERE ID = @ID

--CREAR MEDIO DE PAGO
go
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CREAR_MEDIO(@MEDIO VARCHAR(20))
AS IF NOT EXISTS(SELECT 1 FROM ventasSucursal.MEDIO_PAGO WHERE MEDIO_PAGO = @MEDIO)
	INSERT INTO ventasSucursal.MEDIO_PAGO (MEDIO_PAGO) VALUES (@MEDIO)
	ELSE
		UPDATE ventasSucursal.MEDIO_PAGO SET MEDIO_PAGO = @MEDIO WHERE MEDIO_PAGO = @MEDIO
go
--ELIMINAR MEDIO PAGO
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.ELIMINAR_MEDIO(@ID int)
AS DELETE FROM ventasSucursal.MEDIO_PAGO WHERE ID = @ID
GO
