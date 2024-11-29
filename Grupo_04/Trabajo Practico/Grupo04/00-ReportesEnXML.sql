--GENERACION DE REPORTES EN XML
use Com5600G04;
go

--creo un esquema para los reportes
if not exists (select * from sys.schemas where name='reportes')
begin
	exec('create schema reportes');
end
go

--Mensual: ingresando un mes y año determinado mostrar el total facturado por días de
--la semana, incluyendo sábado y domingo

create or alter procedure REPORTES.TOTAL_FACTURADO_POR_DIA (@mes tinyint, @anio smallint)
as
begin
	SELECT DATENAME(WEEKDAY, fecha) AS DiaSemana, SUM(total) AS TotalFacturado
	FROM VENTASSUCURSAL.factura
	WHERE YEAR(fecha) = @anio AND MONTH(fecha) = @mes
	for XML path('reporte'), root('reportes_total_fac_x_dia');
end
go


/*
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
*/
create or alter procedure REPORTES.PRODUCTOS_VENDIDOS_EN_FECHA_TOTALES 
(@fecha1 date, @fecha2 date) as
begin
	SELECT SUM(dt.cantidadProd) AS CantidadVendida
	FROM ventasSucursal.factura fc inner join ventasSucursal.detalle dt on fc.id = dt.id_fact
	WHERE fc.fecha BETWEEN @fecha1 AND @fecha2 AND fc.baja = null
	GROUP BY fc.fecha
	ORDER BY CantidadVendida DESC
	for XML path('reporte'),root('productos_vendidos_entre_fechas');
end
go



--Mostrar los 5 productos más vendidos en un mes, por semana
create or alter procedure REPORTES.PRODUCTOS_MAS_VENDIDOS_DEL_MES
(@anio tinyint, @mes tinyint) as
begin
	SELECT TOP 5 dt.id_prod, SUM(dt.cantidadProd) AS CantidadVendida
	FROM ventasSucursal.factura fc inner join ventasSucursal.detalle dt on fc.id = dt.id_fact
	WHERE YEAR(fc.fecha) = @anio AND MONTH(fc.fecha) = @mes AND fc.baja = null
	GROUP BY dt.id_prod, DATEPART(WEEK, fc.fecha)
	ORDER BY CantidadVendida DESC
	for XML path('reporte'),root('top5_productos_mas_vendidos_del_mes');
end
go


--Mostrar los 5 productos menos vendidos en el mes.
create or alter procedure REPORTES.PRODUCTOS_MENOS_VENDIDOS_DEL_MES
(@anio tinyint, @mes tinyint) as
begin
	SELECT TOP 5 dt.id_prod, SUM(dt.cantidadProd) AS CantidadVendida
	FROM ventasSucursal.factura fc inner join ventasSucursal.detalle dt on fc.id = dt.id_fact
	WHERE YEAR(fc.fecha) = @anio AND MONTH(fc.fecha) = @mes and fc.baja = null
	GROUP BY dt.id_prod, DATEPART(WEEK, fc.fecha)
	ORDER BY CantidadVendida ASC
	for XML path('reporte'),root('top5_productos_menos_vendidos_del_mes');
end
go


/*
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a
menor.
*/
create or alter procedure REPORTES.PRODUCTOS_VENDIDOS_EN_FECHA_POR_SUCURSAL 
(@fecha1 date, @fecha2 date) as
begin
	--
end
go


--Trimestral: mostrar el total facturado por turnos de trabajo por mes.
create or alter procedure REPORTES.TOTAL_FACTURADO_POR_TURNOS_DE_TRABAJO_POR_MES AS
begin
	--corregir
	SELECT MONTH(fecha) AS Mes, turno, SUM(monto) AS TotalFacturado
	FROM 
	WHERE fecha BETWEEN @fecha_inicio_trimestre AND @fecha_fin_trimestre
	GROUP BY MONTH(fecha), turno
	ORDER BY Mes, turno
	for XML path('reporte'),root('reportes_total_fac_x_turnos');
end
go

--Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha
--y sucursal particulares
create or alter procedure REPORTES.TOTAL_ACUMULADO_DE_VENTAS
(@fecha date, @sucursal varchar(20)) as
begin
	--corregir
	SELECT sucursal_id, fecha, SUM(monto) AS TotalAcumulado
	FROM ventas
	WHERE fecha = @fecha_especifica AND sucursal_id = @sucursal_id
	GROUP BY sucursal_id, fecha
	for XML path('reporte'),root('total_acumulado_de_ventas_para_fecha_y_sucursal');
end
go