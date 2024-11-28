--------------------------------IMPORTACION DE DATOS-----------------------------------
use Com5600G04;
go

--habilito consultas distribuidas, para poder usar la funcion openrowset
/*
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
*/


--NECESARIO PARA PODER IMPORTAR DESDE XLSX
/*
USE [master] 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
GO 
*/


--inserto desde catalogo.csv en tabla producto
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_CSV @RUTA NVARCHAR(255) AS
begin
	--creo tabla temporal
	create table #productos_temp(
		id VARCHAR(15),
		categoria varchar(50),
		nombre varchar(100),
		precio varchar(50),
		precio_referencia varchar(50),
		unidad_referencia varchar(10),
		fecha varchar(50)
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

	--desde tabla temporal inserto en la tabla producto
	insert into catalogo.producto (id, categoria, nombre, precio, precio_referencia,
	unidad_referencia, fecha)
	select cast(id as int), categoria, nombre, cast(precio as numeric(10,2)), 
		cast(precio_referencia as numeric(10,2)), unidad_referencia, 
		cast(fecha as datetime)
	from #productos_temp
	/*
	insert into catalogo.producto
	select cast(id as int), categoria, nombre, cast(precio as numeric(10,2)), 
		cast(precio_referencia as numeric(10,2)), unidad_referencia, cast(fecha as smalldatetime)
	from #productos_temp
	*/
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
	insert into #accesoriosTemp (prod, precio)
	select * 
	from openrowset('Microsoft.ACE.OLEDB.12.0',
                    'Excel 12.0;HDR=Yes;Database=C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\Electronic_accessories.xlsx;',
                    'SELECT * FROM [Sheet1$]');
	/*
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 
	'insert into #accesoriosTemp(prod, precio)
    SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'','+
	'''Excel 12.0;HDR=Yes;Database='+@RUTA+';'','+'''select * from [Sheet1$]'');';
	--insercion en tabla temp
	EXEC SP_EXECUTESQL @CONSULTA
	--insersion de datos de la tabla temp en la tabla producto
	insert into catalogo.producto (nombre, precioUsd)
	select distinct prod, cast(precio as numeric(10,2))
	from #accesoriosTemp;
	*/

	/*
	insert into catalogo.accesorio_electronico (producto, precioUnitUsd)
	select prod, cast(precio as numeric(10,2))
	from #accesoriosTemp;
	*/
	--elimino tabla temp
	drop table #accesoriosTemp;
end
go

--Productos_importados.xlsx
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_IMPORTADOS_XLSX (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #prod_imp_temp(
		idProd int,
		NombreProducto varchar(50),
		Proveedor varchar(50),
		Categoria varchar(30),
		CantidadPorUnidad varchar(50),
		PrecioUnidad varchar(30)
	);
	
	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #prod_imp_temp 
		SELECT *
		FROM OPENROWSET("Microsoft.ACE.OLEDB.12.0",
		"Excel 12.0; Database="' + @RUTA + ';' + ',
		"select * from [Listado de productos$]");'
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA;

	--inserto desde tabla temporal en la tabla producto
	insert into catalogo.producto (nombre, proveedor, categoria, cantXunidad, precio)
	select NombreProducto, Proveedor, Categoria, CantidadPorUnidad, 
		cast(PrecioUnidad as numeric(10,2))
	from #prod_imp_temp;
	/*
	insert into catalogo.producto_importado
	select idProd, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, 
		cast(PrecioUnidad as numeric(10,2))
	from #prod_imp_temp;
	*/
	--elimino la tabla temporal
	drop table #prod_imp_temp;
end
go

--tabla sucursal desde informacion_complementaria.xlsx
CREATE OR ALTER PROCEDURE SUCURSAL.CARGAR_SUCURSALES_XLSX (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #sucursal_temp(
		ciudad varchar(50),
		direccion varchar(100),
		horario varchar(50),
		telefono varchar(15),
	);

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #sucursal_temp (ciudad, direccion, horario, telefono)
		SELECT *
		FROM OPENROWSET("Microsoft.ACE.OLEDB.12.0",
		"Excel 12.0; Database="' + @RUTA + ';' + ',
		"select [Reemplazar por],direccion,horario,telefono from [sucursal$]");'
	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA

	--inserto desde tabla temporal en la tabla destino
	insert into SUCURSAL.sucursal (ciudad, direccion, horario, telefono)
	select *
	from #sucursal_temp;

	--elimino la tabla temporal
	drop table #sucursal_temp;
end
go

--tabla empleado desde informacion_complementaria.xlsx
create or alter procedure SUCURSAL.CARGAR_EMPLEADOS_XLSX (@RUTA NVARCHAR(255)) as
begin
	--creo tabla temporal
	create table #empl_temp(
		legajoId int,
		nombre varchar(50),
		apellido varchar(50),
		dni int,
		direccion varchar(100),
		email_personal varchar(75),
		email_empresarial varchar(75),
		cuil varchar(15),
		cargo varchar(20),
		sucursal varchar(20),
		turno varchar(20)
	);

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'insert into #empl_temp
		SELECT *
		FROM OPENROWSET("Microsoft.ACE.OLEDB.12.0",
		"Excel 12.0; Database="' + @RUTA + ';' + ',
		"select [Legajo/ID],Nombre,Apellido,DNI,Direccion,[email personal],
		[email empresa],Cuil,Cargo,Sucursal,Turno from [Empleados$]");'
	
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

	--elimino registros vacios, aquellos empleados que lleguen con id nulo
	delete from #empl_temp where legajoId is null;

	--inserto en tabla empleado desde tabla temporal
	insert into SUCURSAL.empleado(legajoId, nombre, apellido, dni, 
		direccion, email_personal, email_empresarial,
		cuil, cargo, sucursal, turno)
	select * 
	from #empl_temp;

	--elimino la tabla temporal
	drop table #empl_temp;
end
go


--inserto desde ventas_registradas.csv en tabla ventas registradas
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CARGAR_VENTAS_REGISTRADAS_CSV (@RUTA NVARCHAR(255)) AS
begin
	--creo tabla temporal
	create table #ventas_temp(
		id_factura varchar(50),
		tipo_de_factura char(1),
		ciudad varchar(20),
		tipo_de_cliente varchar(10),
		genero varchar(10),
		producto varchar(100),
		precio_unitario varchar(50),
		cantidad varchar(50),
		fecha varchar(100),
		hora varchar(100),
		medio_de_pago varchar(100),
		empleado_id varchar(50),
		identificador_de_pago varchar(50)
	);

	DECLARE @CONSULTA NVARCHAR(max)
	SET @CONSULTA = 'BULK INSERT #ventas_temp 
	FROM "' + @RUTA + '"
	   WITH (
		  FIELDTERMINATOR = ";",	
		  ROWTERMINATOR = "0x0a",
		  firstrow = 2,				
		  codepage = "65001");'		

	--inserto en tabla temporal
	EXEC SP_EXECUTESQL @CONSULTA
	
	--inserto en tabla desde tabla temporal
	insert into ventasSucursal.venta_registrada(id_factura, tipo_de_factura, ciudad,
	tipo_de_cliente, genero, producto, precio_unitario, cantidad, fecha, hora, medio_de_pago,
	empleado_id, identificador_de_pago)
	select id_factura, tipo_de_factura, ciudad, tipo_de_cliente, genero, producto, 
		cast(precio_unitario as numeric(10,2)), cast(cantidad as smallint), 
		cast(fecha as date), cast(hora as time), medio_de_pago, cast(empleado_id as int),
		identificador_de_pago
	from #ventas_temp;

	--elimino tabla temporal
	drop table #ventas_temp;
end

