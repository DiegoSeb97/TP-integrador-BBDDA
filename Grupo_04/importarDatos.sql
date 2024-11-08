use Com5600G04;
go

--habilito consultas distribuidas, para poder usar la funcion openrowset
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
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
--la ruta del archivo puede variar
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_ACCESORIOS_ELECTRONICOS_XLSX AS
begin
	insert into catalogo.accesorio_electronico (producto, precioUnitUsd)
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Productos\Electronic_accessories.xlsx',
		'select * from [Sheet1$]');
end

--Productos_importados.xlsx
GO
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_IMPORTADOS_XLSX AS
begin
	insert into catalogo.producto_importado 
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
		'select * from [Listado de productos$]');
end

--tabla sucursal desde informacion_complementaria.xlsx
GO
CREATE OR ALTER PROCEDURE SUCURSAL.CARGAR_SUCURSALES_XLSX AS
begin
	insert into SUCURSAL.sucursal (ciudad, direccion, horario, telefono)
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'select [Reemplazar por],direccion,horario,telefono from [sucursal$]')
end

--tabla empleado desde informacion_complementaria.xlsx
--la primer fila esta vacia, por lo tanto necesito evitarla
--creo un cte para usar row_number y luego cargar los datos que correspondan despues de la primer fila
/*
insert into SUCURSAL.empleado(legajoId, nombre, apellido, dni, direccion, email_personal, email_empresarial,
cuil, cargo, sucursal, turno)
SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Informacion_complementaria.xlsx',
	'select [Legajo/ID],Nombre,Apellido,DNI,Direccion,[email personal],
	[email empresa],Cuil,Cargo,Sucursal,Turno from [Empleados$]');
*/

--inserto desde catalogo.csv en tabla producto
--hay campos con comas por dentro, hay lineas que se cargan mal
--por ejemplo la linea 127, esto se ve al realizar select * de la tabla cargada
GO
CREATE OR ALTER PROCEDURE CATALOGO.CARGAR_PRODUCTOS_CSV AS
begin
	BULK INSERT catalogo.producto 
	FROM 'D:\datosTpBDA\TP_integrador_Archivos\Productos\catalogo.csv'
	   WITH (
		  FIELDTERMINATOR = ',',	--caracter delimitador
		  ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
		  FIELDQUOTE = '"',
		  firstrow = 2,				--primera linea de datos
		  codepage = '65001',		--para poder leer caracteres especiales
		  FORMAT = 'CSV');
end

--inserto desde ventas_registradas.csv en tabla ventas registradas
GO
CREATE OR ALTER PROCEDURE VENTASSUCURSAL.CARGAR_VENTAS_REGISTRADAS_CSV AS
begin
	BULK INSERT ventasSucursal.venta_registrada 
	FROM 'D:\datosTpBDA\TP_integrador_Archivos\Ventas_registradas.csv'
	   WITH (
		  FIELDTERMINATOR = ';',	--caracter delimitador
		  ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
		  firstrow = 2,				--primera linea de datos
		  codepage = '65001');		--para poder leer caracteres especiales
end