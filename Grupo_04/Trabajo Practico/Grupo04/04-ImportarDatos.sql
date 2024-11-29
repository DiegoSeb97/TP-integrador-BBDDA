--------------------------------IMPORTACION DE DATOS-----------------------------------
use Com5600G04;
go

SP_CONFIGURE 'show advanced options' ,1;
go
reconfigure;
GO
SP_CONFIGURE 'Ole Automation Procedures', 1;
go
reconfigure;
GO

--habilito consultas distribuidas, para poder usar la funcion openrowset

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO



--NECESARIO PARA PODER IMPORTAR DESDE XLSX

USE [master] 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
GO 

--FUNCI”N QUE DEVUELVE EL PRECIO DEL D”LAR OFICIAL
CREATE OR ALTER FUNCTION CATALOGO.PRECIO_DOLAR() RETURNS NUMERIC(10, 2) AS
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
	RETURN @PRECIOUSD
END

GO

--inserto desde catalogo.csv en tabla producto
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_CSV @RUTA NVARCHAR(255) AS
begin
	--creo tabla temporal
	create table #productos_temp(
		id varchar(max),
		category varchar(MAX),
		name varchar(MAX),
		price varchar(MAX),
		reference_price varchar(MAX),
		reference_unit varchar(MAX),
		date DATETIME
	);
	
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'BULK INSERT #productos_temp 
	FROM ''' + @RUTA + '''
	   WITH (
		  FIELDTERMINATOR = '','',	
		  ROWTERMINATOR = ''0x0a'',	
		  FIELDQUOTE = ''"'',
		  firstrow = 2,			
		  codepage = ''65001'',		
		  FORMAT = ''CSV'');';
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA
	
	--CORREGIMOS LOS CARACTERES INCORRECTOS

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√©', 'È') WHERE NAME LIKE '%√©%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√≥', 'Û') WHERE NAME LIKE '%√≥%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√±', 'Ò') WHERE NAME LIKE '%√±%';
	
	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '¬∫', '∫') WHERE NAME LIKE '%¬∫%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√∫', '˙') WHERE NAME LIKE '%√∫%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√°', '·') WHERE NAME LIKE '%√°%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√≠', 'Ì') WHERE NAME LIKE '%√≠%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√≠', 'Ì') WHERE NAME LIKE '%√≠%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√≠', '¡') WHERE NAME LIKE '%√≠%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, 'Âçò≠', 'Ò') WHERE NAME LIKE '%Âçò%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√É¬∫≠', '˙') WHERE NAME LIKE '%√É¬∫%';

	UPDATE #PRODUCTOS_TEMP SET 
	NAME = REPLACE(NAME, '√ë', '—') WHERE NAME LIKE '%√ë%';

	declare @cotizacionUsd numeric (10, 2)= CATALOGO.PRECIO_DOLAR()

	insert into catalogo.producto (categoria, nombre, precio, precio_referencia,
	unidad_referencia, fecha, PRECIOUSD)
	select MAX(category), name, cast(max(price) as numeric(10,2)), 
		cast(MAX(reference_price) as numeric(10,2)), MAX(reference_unit), 
		MIN(DATE), CAST(MAX(price) / @COTIZACIONUSD AS NUMERIC(10, 3))
	from #productos_temp WHERE NOT EXISTS(SELECT 1 FROM CATALOGO.PRODUCTO WHERE NOMBRE = NAME) GROUP BY NAME --Si HAY NOMBRES DUPLICADOS NO LOS INSERTA 2 VECES

	--elimino tabla temporal
	drop table #productos_temp;
end
go

--inserto desde accesorios_electronicos en tabla productos
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_ACCESORIOS_ELECTRONICOS_XLSX (@RUTA NVARCHAR(255)) AS
begin
	--creacion de tabla temp
	create table #accesoriosTemp(
		prod varchar(50),
		precio varchar(50)
	);
	
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 
	N'insert into #accesoriosTemp(prod, precio)
    SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
	'''Excel 12.0;HDR=Yes;Database='+@RUTA+';'','+'''select * from [Sheet1$]'');';
	--insercion en tabla temp
	EXEC SP_EXECUTESQL @CONSULTA

	DECLARE @COTIZACIONUSD NUMERIC(10, 2) = CATALOGO.PRECIO_DOLAR()
	--insersion de datos de la tabla temp en la tabla producto
	insert into catalogo.producto (nombre, precio, PRECIOUSD) select prod, MAX(cast(precio as numeric(10,2))), MAX(cast(precio / @COTIZACIONUSD as numeric(10, 2)))
	from #accesoriosTemp where not exists (SELECT 1 FROM CATALOGO.PRODUCTO WHERE NOMBRE LIKE PROD) GROUP BY PROD

	drop table #accesoriosTemp;
end
go

--Productos_importados.xlsx
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_IMPORTADOS_XLSX (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #prod_imp_temp(
		id varchar(MAX),
		NombreProducto varchar(MAX),
		Proveedor varchar(MAX),
		Categoria varchar(MAX),
		CantidadPorUnidad varchar(MAX),
		PrecioUnidad VARCHAR(MAX)
	);
	
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 
	N'insert into #PROD_IMP_TEMP
    SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
	'''Excel 12.0;HDR=Yes;Database='+@RUTA+';'','+'''select * from [Listado de Productos$]'');';
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA;

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√©', 'È') WHERE NombreProducto LIKE '%√©%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√≥', 'Û') WHERE NombreProducto LIKE '%√≥%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√±', 'Ò') WHERE NombreProducto LIKE '%√±%';
	
	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '¬∫', '∫') WHERE NombreProducto LIKE '%¬∫%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√∫', '˙') WHERE NombreProducto LIKE '%√∫%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√°', '·') WHERE NombreProducto LIKE '%√°%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√≠', 'Ì') WHERE NombreProducto LIKE '%√≠%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√≠', '¡') WHERE NombreProducto LIKE '%√≠%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, 'Âçò≠', 'Ò') WHERE NombreProducto LIKE '%Âçò%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√É¬∫≠', '˙') WHERE NombreProducto LIKE '%√É¬∫%';

	UPDATE #prod_imp_temp SET 
	NombreProducto = REPLACE(NombreProducto, '√ë', '—') WHERE NombreProducto LIKE '%√ë%';

	DECLARE  @PRECIOUSD NUMERIC(10, 2) = CATALOGO.PRECIO_DOLAR() --COTIZACI”N DEL D”LAR AL MOMENTO DE INSERTAR

	--inserto desde tabla temporal en la tabla producto
	insert into catalogo.producto (nombre, proveedor, categoria, cantPorUnidad, precio, PRECIOUSD)
	select NombreProducto, MAX(Proveedor), MAX(Categoria), MAX(CantidadPorUnidad), 
		cast(MAX(PrecioUnidad) as numeric(10,2)), cast(MAX(PrecioUnidad) / @PRECIOUSD as numeric(10,2))
	from #prod_imp_temp TEMP where not exists (SELECT 1 FROM CATALOGO.PRODUCTO WHERE NOMBRE = TEMP.NombreProducto) GROUP BY NOMBREPRODUCTO --SI HAY MUCHOS REGISTROS DE UN PRODUCTO CARGA SOLO UNO

	--elimino la tabla temporal
	drop table #prod_imp_temp;
end
go

--tabla sucursal desde informacion_complementaria.xlsx
CREATE OR ALTER PROCEDURE SUCURSAL.CARGAR_SUCURSALES_XLSX (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #sucursal_temp(
		ciudad varchar(max),
		direccion varchar(max),
		horario varchar(max),
		telefono varchar(max),
	);

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #sucursal_temp (ciudad, direccion, horario, telefono)
		SELECT *
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
		'''Excel 12.0;HDR=Yes;Database=' + @RUTA + ';'',' + 
		'''select [Reemplazar por],direccion,horario,telefono from [sucursal$]'');';
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA

	--inserto desde tabla temporal en la tabla destino
	insert into SUCURSAL.sucursal (ciudad, direccion, horario, telefono)
	select MAX(CIUDAD), DIRECCION, MAX(HORARIO), MAX(TELEFONO)
	from #sucursal_temp TEMP WHERE NOT EXISTS (SELECT 1 FROM SUCURSAL.SUCURSAL WHERE DIRECCION = TEMP.DIRECCION) GROUP BY DIRECCION;

	--elimino la tabla temporal
	drop table #sucursal_temp;
end
go

--tabla empleado desde informacion_complementaria.xlsx
create or alter procedure SUCURSAL.CARGAR_EMPLEADOS_XLSX (@RUTA NVARCHAR(255)) as
begin
	--creo tabla temporal
	create table #empl_temp(
		legajoId VARCHAR(MAX),
		nombre varchar(MAX),
		apellido varchar(MAX),
		dni INT,
		direccion varchar(MAX),
		email_personal varchar(MAX),
		email_empresarial varchar(MAX),
		cuil varchar(MAX),
		cargo varchar(MAX),
		sucursal varchar(MAX),
		turno varchar(MAX)
	);
	
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #empl_temp
		SELECT *
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
		'''Excel 12.0;HDR=Yes;Database=' + @RUTA + ';'',' + 
		'''select * from [Empleados$]'');';
	
	--inserto datos en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA
	
	--elimino tabulaciones de los campos email_personal, empresarial, nombre y apellido
	--char(9) = \t
	--para emails reemplazo con caracter vacio, para nombre y apellido reemplazo con un espacio en blanco
	UPDATE #empl_temp
	SET email_personal = REPLACE(email_personal, CHAR(9), '')
	WHERE email_personal LIKE '%' + CHAR(9) + '%';
	
	UPDATE #empl_temp
	SET email_empresarial = REPLACE(email_empresarial, CHAR(9), '')
	WHERE email_empresarial LIKE '%' + CHAR(9) + '%';

	UPDATE #empl_temp
	SET nombre = REPLACE(nombre, CHAR(9), ' ')
	WHERE nombre LIKE '%' + CHAR(9) + '%';

	UPDATE #empl_temp
	SET apellido = REPLACE(apellido, CHAR(9), ' ')
	WHERE apellido LIKE '%' + CHAR(9) + '%';

	--ELIMINAMOS CAMPOS CON DNI NULO PORQUE ES INFORMACI”N ERR”NEA
	DELETE FROM #empl_temp WHERE DNI IS NULL

	--inserto en tabla empleado desde tabla temporal
	insert into SUCURSAL.empleado(legajo, nombre, apellido, dni, 
		direccion, email_personal, email_empresarial,
		cuil, cargo, sucursal, turno)
	select CAST(MAX(LEGAJOID) AS INT), MAX(NOMBRE), MAX(APELLIDO), DNI, MAX(DIRECCION), MAX(EMAIL_PERSONAL), MAX(EMAIL_EMPRESARIAL), CAST(MAX(CUIL) AS INT), MAX(CARGO), (SELECT ID FROM SUCURSAL.SUCURSAL WHERE CIUDAD LIKE MAX(SUCURSAL)), MAX(TURNO)
	from #empl_temp WHERE NOT EXISTS (SELECT 1 FROM SUCURSAL.EMPLEADO WHERE DNI = DNI) GROUP BY DNI

	--elimino la tabla temporal
	drop table #empl_temp;
end
go

--INSERTAR MEDIOS DE PAGO DESDE informacion_complementaria.xlsx
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CARGAR_MEDIOS_PAGO (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #MEDIO_TEMP(
		COMENTARIO varchar(max),
		MEDIO VARCHAR(MAX),
		COMENTARIO2 VARCHAR(MAX)
	);

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #MEDIO_TEMP
		SELECT *
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
		'''Excel 12.0;HDR=Yes;Database=' + @RUTA + ';'',' + 
		'''select * from [medios de pago$]'');';
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA

	--inserto desde tabla temporal en la tabla destino
	insert into ventasSucursal.medio_pago
	select MEDIO
	from #MEDIO_TEMP TEMP WHERE NOT EXISTS (SELECT 1 FROM VENTASSUCURSAL.MEDIO_PAGO WHERE MEDIO_PAGO = TEMP.MEDIO);

	--elimino la tabla temporal
	drop table #MEDIO_TEMP;
end
go

--inserto desde ventas_registradas.csv en tabla ventas registradas
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CARGAR_VENTAS_REGISTRADAS_CSV (@RUTA NVARCHAR(255), @RUTA2 NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #ventas_temp(
		id_factura varchar(MAX),
		tipo_de_factura VARCHAR(MAX),
		ciudad varchar(MAX),
		tipo_de_cliente varchar(MAX),
		genero varchar(MAX),
		producto varchar(MAX),
		precio_unitario varchar(MAX),
		cantidad varchar(MAX),
		fecha varchar(MAX),
		hora varchar(MAX),
		medio_de_pago varchar(MAX),
		empleado_id varchar(MAX),
		identificador_de_pago varchar(MAX)
	)

	create table #sucursal_temp(
		reemplazo varchar(max),
		ciudad varchar(max)
	);
	
	DECLARE @CONSULTA2 NVARCHAR(max)
	SET @CONSULTA2 = 'INSERT INTO #SUCURSAL_TEMP SELECT *
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
		'''Excel 12.0;HDR=Yes;Database=' + @RUTA2 + ';'',' + 
		'''select [Reemplazar por], ciudad from [sucursal$]'');';

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'BULK INSERT #ventas_temp 
	FROM ''' + @RUTA + '''
	   WITH (
		  FIELDTERMINATOR = '';'',	
		  ROWTERMINATOR = ''0x0a'',
		  firstrow = 2,				
		  codepage = ''65001'',
		  FORMAT = ''CSV'');'		

	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA
	EXEC SP_EXECUTESQL @CONSULTA2
	
	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√©', 'È') WHERE producto LIKE '%√©%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√≥', 'Û') WHERE producto LIKE '%√≥%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√±', 'Ò') WHERE producto LIKE '%√±%';
	
	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '¬∫', '∫') WHERE producto LIKE '%¬∫%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√∫', '˙') WHERE producto LIKE '%√∫%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√°', '·') WHERE producto LIKE '%√°%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√≠', 'Ì') WHERE producto LIKE '%√≠%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√≠', '¡') WHERE producto LIKE '%√≠%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, 'Âçò≠', 'Ò') WHERE producto LIKE '%Âçò%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√É¬∫≠', '˙') WHERE producto LIKE '%√É¬∫%';

	UPDATE #ventas_temp SET 
	producto = REPLACE(producto, '√ë', '—') WHERE producto LIKE '%√ë%';

	--PRIMERO SE CREAN LAS FACTURAS
	INSERT INTO VENTASSUCURSAL.FACTURA(ID_FACTURA, FECHA, ESTADO, TIPO, TOTAL, TOTALIVA) 
	SELECT ID_FACTURA, CAST(MIN(FECHA) AS DATE), 'Pago', CAST(MAX(TIPO_DE_FACTURA) AS CHAR(1)), CAST(MAX(PRECIO_UNITARIO) AS NUMERIC(11, 2)) * CAST(MAX(CANTIDAD) AS NUMERIC(11, 2)), CAST(MAX(PRECIO_UNITARIO) AS NUMERIC(11, 2)) * CAST(MAX(CANTIDAD) AS NUMERIC(11, 2)) * 1.21 
	FROM #ventas_temp T WHERE NOT EXISTS (SELECT 1 FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = T.ID_FACTURA) GROUP BY ID_FACTURA

	--LUEGO SE CREAN LOS DETALLES
	INSERT INTO VENTASSUCURSAL.DETALLE(ID_FACT, CANTIDADPROD, PRECIO, SUBTOTAL, ID_PROD) 
	SELECT (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = T.ID_FACTURA), CAST(MAX(CANTIDAD) AS INT), CAST(MAX(PRECIO_UNITARIO) AS NUMERIC(10, 2)), CAST(MAX(PRECIO_UNITARIO) AS NUMERIC(11, 2)) * CAST(MAX(CANTIDAD) AS NUMERIC(11, 2)), (SELECT ID FROM CATALOGO.PRODUCTO WHERE NOMBRE = MAX(PRODUCTO))
	FROM #ventas_temp T WHERE NOT EXISTS (SELECT 1 FROM VENTASSUCURSAL.DETALLE WHERE ID_FACT = (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = T.ID_FACTURA)) GROUP BY ID_FACTURA

	--inserto en tabla desde tabla temporal
	INSERT INTO VENTASSUCURSAL.VENTA_REGISTRADA (ID_FACTURA, CIUDAD, FECHA, HORA, EMPLEADO_ID, MEDIO_PAGO, IDENTIFICADOR_PAGO)
	SELECT (SELECT ID FROM VENTASSUCURSAL.FACTURA F WHERE F.ID_FACTURA = T.ID_FACTURA), (SELECT REEMPLAZO FROM #SUCURSAL_TEMP TS WHERE MAX(T.CIUDAD) = TS.CIUDAD), CAST(MIN(FECHA) AS DATE), CAST(MIN(HORA) AS TIME), (SELECT ID FROM SUCURSAL.EMPLEADO WHERE LEGAJO = MAX(EMPLEADO_ID)), (SELECT ID FROM VENTASSUCURSAL.MEDIO_PAGO WHERE MEDIO_PAGO = MAX(MEDIO_DE_PAGO)), MAX(IDENTIFICADOR_DE_PAGO)
	FROM #ventas_temp T WHERE NOT EXISTS (SELECT 1 FROM VENTASSUCURSAL.VENTA_REGISTRADA VR WHERE VR.ID_FACTURA = (SELECT ID FROM VENTASSUCURSAL.FACTURA F WHERE F.ID_FACTURA = T.ID_FACTURA)) GROUP BY ID_FACTURA

	--elimino tabla temporal
	drop table #ventas_temp
end

