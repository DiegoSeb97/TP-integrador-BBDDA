--GENERACION DE TABLAS

use Com5600G04;

exec catalogo.crear_tabla_producto;
go
exec catalogo.crear_tabla_accesorio_electronico;
go
exec catalogo.crear_tabla_producto_importado;
go
exec SUCURSAL.crear_tabla_sucursal;
go
exec SUCURSAL.crear_tabla_empleado;
go
exec ventasSucursal.crear_tabla_ventas_registradas;



--test
drop table catalogo.producto;
go
drop table catalogo.accesorio_electronico;
go
drop table catalogo.producto_importado;
go
drop table SUCURSAL.sucursal;
go
drop table ventasSucursal.venta_registrada;
go
drop table SUCURSAL.empleado;
