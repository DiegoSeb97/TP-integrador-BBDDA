--IMPORTACION DE DATOS
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

/*
--NECESARIO PARA PODER IMPORTAR DESDE XLSX
USE [master] 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
GO 
*/

--inserto desde archivo excel en tabla accesorio_electronico
--la ruta del archivo puede variar, mandar como parametro
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_ACCESORIOS_ELECTRONICOS_XLSX AS
begin
	--creacion de tabla temp
	create table #accesoriosTemp(
		prod varchar(50),
		precio varchar(50)
	);
	--insercion en tabla temp
	insert into #accesoriosTemp(prod, precio)
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Productos\Electronic_accessories.xlsx',
		'select * from [Sheet1$]');
	--insersion de datos de la tabla temp en la tabla accesorio_electronico
	insert into catalogo.accesorio_electronico (producto, precioUnitUsd)
	select prod, cast(precio as numeric(10,2))
	from #accesoriosTemp;
	--elimino tabla temp
	drop table #accesoriosTemp;
end
go

--Productos_importados.xlsx
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_IMPORTADOS_XLSX AS
begin
	create table #prod_imp_temp(
		idProd int,
		NombreProducto varchar(50),
		Proveedor varchar(50),
		Categoria varchar(30),
		CantidadPorUnidad varchar(50),
		PrecioUnidad varchar(30)
	);

	insert into #prod_imp_temp 
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
		'select * from [Listado de productos$]');
	
	--realizar insert en tabla, solucionar problema de la cantidad por unidad.
	select * from #prod_imp_temp;
	drop table #prod_imp_temp;
end
go

--tabla sucursal desde informacion_complementaria.xlsx
CREATE OR ALTER PROCEDURE SUCURSAL.CARGAR_SUCURSALES_XLSX AS
begin
	create table #sucursal_temp(
		ciudad varchar(50),
		direccion varchar(100),
		horario varchar(50),
		telefono varchar(15),
	);

	insert into #sucursal_temp (ciudad, direccion, horario, telefono)
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'select [Reemplazar por],direccion,horario,telefono from [sucursal$]');

	insert into SUCURSAL.sucursal (ciudad, direccion, horario, telefono)
	select *
	from #sucursal_temp;

	drop table #sucursal_temp;
end
go

--tabla empleado desde informacion_complementaria.xlsx
create or alter procedure SUCURSAL.CARGAR_EMPLEADOS_XLSX as
begin
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
	insert into #empl_temp
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'select [Legajo/ID],Nombre,Apellido,DNI,Direccion,[email personal],
		[email empresa],Cuil,Cargo,Sucursal,Turno from [Empleados$]');
	
	--elimino tabulaciones de los campos
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

	--elimino registros vacios
	delete from #empl_temp where legajoId is null;
	--inserto en tabla empleado
	insert into SUCURSAL.empleado(legajoId, nombre, apellido, dni, 
		direccion, email_personal, email_empresarial,
		cuil, cargo, sucursal, turno)
	select * 
	from #empl_temp;

	--select * from #empl_temp;
	--select * from SUCURSAL.empleado;
	drop table #empl_temp;
end


--inserto desde catalogo.csv en tabla producto
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_CSV AS
begin
	create table #productos_temp(
		id int,
		categoria varchar(50),
		nombre varchar(100),
		precio varchar(50),
		precio_referencia varchar(50),
		unidad_referencia varchar(10),
		fecha varchar(50)
	);

	BULK INSERT #productos_temp 
	FROM 'D:\datosTpBDA\TP_integrador_Archivos\Productos\catalogo.csv'
	   WITH (
		  FIELDTERMINATOR = ',',	--caracter delimitador
		  ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
		  FIELDQUOTE = '"',
		  firstrow = 2,				--primera linea de datos
		  codepage = '65001',		--para poder leer caracteres especiales
		  FORMAT = 'CSV');

	insert into catalogo.producto
	select id, categoria, nombre, cast(precio as numeric(10,2)), 
		cast(precio_referencia as numeric(10,2)), unidad_referencia, cast(fecha as smalldatetime)
	from #productos_temp

	drop table #productos_temp;
end
go


--inserto desde ventas_registradas.csv en tabla ventas registradas
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CARGAR_VENTAS_REGISTRADAS_CSV AS
begin
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

	BULK INSERT #ventas_temp 
	FROM 'D:\datosTpBDA\TP_integrador_Archivos\Ventas_registradas.csv'
	   WITH (
		  FIELDTERMINATOR = ';',	--caracter delimitador
		  ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
		  firstrow = 2,				--primera linea de datos
		  codepage = '65001');		--para poder leer caracteres especiales
	
	insert into ventasSucursal.venta_registrada(id_factura, tipo_de_factura, ciudad,
	tipo_de_cliente, genero, producto, precio_unitario, cantidad, fecha, hora, medio_de_pago,
	empleado_id, identificador_de_pago)
	select id_factura, tipo_de_factura, ciudad, tipo_de_cliente, genero, producto, 
		cast(precio_unitario as numeric(10,2)), cast(cantidad as smallint), 
		cast(fecha as date), cast(hora as time), medio_de_pago, cast(empleado_id as int),
		identificador_de_pago
	from #ventas_temp;

	--select * from #ventas_temp;
	--select * from ventasSucursal.venta_registrada;
	drop table #ventas_temp;
end