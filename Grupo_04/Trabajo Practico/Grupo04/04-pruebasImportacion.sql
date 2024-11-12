--TEST DE IMPORTACION DE ARCHIVOS
USE Com5600G04
GO
/*
DELETE FROM CATALOGO.producto
EXEC CATALOGO.CARGAR_PRODUCTOS_CSV '', '', '', '', '', ''
--SELECT * FROM CATALOGO.PRODUCTO where id = 127;
*/

--importacion de datos

exec catalogo.cargar_accesorios_electronicos_xlsx;

exec catalogo.cargar_productos_importados_xlsx;

exec SUCURSAL.cargar_sucursales_xlsx;

exec catalogo.cargar_productos_csv;

exec SUCURSAL.CARGAR_EMPLEADOS_XLSX;

exec ventasSucursal.cargar_ventas_registradas_csv;

--select* from catalogo.accesorio_electronico;
--select * from catalogo.producto_importado;
--select * from SUCURSAL.sucursal;
--select * from catalogo.producto;
--select * from SUCURSAL.empleado
--select* from ventasSucursal.venta_registrada;