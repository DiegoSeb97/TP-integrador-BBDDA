--TEST DE IMPORTACION DE ARCHIVOS
USE Com5600G04
GO
/*
DELETE FROM CATALOGO.producto
EXEC CATALOGO.CARGAR_PRODUCTOS_CSV '', '', '', '', '', ''
--SELECT * FROM CATALOGO.PRODUCTO where id = 127;
*/

--importacion de datos

exec CATALOGO.CARGAR_PRODUCTOS_CSV
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\catalogo.csv';
select * from catalogo.producto;

exec catalogo.cargar_accesorios_electronicos_xlsx
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\Electronic_accessories.xlsx';

/*
exec catalogo.cargar_productos_importados_xlsx
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

exec SUCURSAL.cargar_sucursales_xlsx
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\catalogo.csv';

exec SUCURSAL.CARGAR_EMPLEADOS_XLSX
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\catalogo.csv';

exec ventasSucursal.cargar_ventas_registradas_csv
@ruta = N'C:\Users\SAJD\Desktop\tp-bda\tp_bdaProductosCsv\TP_integrador_Archivos\Productos\catalogo.csv';
*/
--select* from catalogo.accesorio_electronico;
--select * from catalogo.producto_importado;
--select * from SUCURSAL.sucursal;
--select * from catalogo.producto;
--select * from SUCURSAL.empleado
--select* from ventasSucursal.venta_registrada;