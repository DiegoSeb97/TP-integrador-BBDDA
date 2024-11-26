--TEST DE IMPORTACIÓN DE ARCHIVOS

USE Com5600G04

/*
DELETE FROM CATALOGO.producto
EXEC CATALOGO.CARGAR_PRODUCTOS_CSV '', '', '', '', '', ''
*/

SELECT * FROM CATALOGO.PRODUCTO where id = 127;

--importacion de datos

exec catalogo.cargar_accesorios_electronicos_xlsx;
--select* from catalogo.accesorio_electronico;
exec catalogo.cargar_productos_importados_xlsx;
--select * from catalogo.producto_importado;
exec SUCURSAL.cargar_sucursales_xlsx;
--select * from SUCURSAL.sucursal;

exec catalogo.cargar_productos_csv;
--select * from catalogo.producto;
exec ventasSucursal.cargar_ventas_registradas_csv;
--select* from ventasSucursal.venta_registrada;