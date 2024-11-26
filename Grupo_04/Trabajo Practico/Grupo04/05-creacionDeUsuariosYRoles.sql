----------------------------------CREACION DE USUARIOS Y ROLES------------------------------
--creacion de usuarios y roles a nivel base de datos
use Com5600G04;
go

--creacion de usuarios
create user gerente_suc for login gerente_sucursal;
go

create user supervisor_suc for login supervisor_sucursal;
go

create user cajero_suc for login cajero_sucursal;
go


--creacion de roles gerente, supervisor y cajero
create role gerente;
go
create role supervisor;
go
create role cajero;
go


--otorgo permisos a los roles creados
/*
cajero: 
	debe tener permisos sobre las tablas de productos(solo para ver, select), factura(insert) 
	y ventas registradas(insert).

supervisor: 
	debe tener permisos sobre las mismas tablas de cajero, la tabla nota de credito(insert)
	y debe tener acceso a los esquiemas catalogo y ventas.

gerente:
	debe tener permisos sobre todas las tablas y sobre todos los esquiemas.
*/


--PERMISOS PARA CAJERO
--para ver productos
grant select on catalogo.productos to cajero;
go
grant select on catalogo.accesorio_electronico to cajero;
go
grant select on catalogo.producto_importado to cajero;
go
--para generar facturas
grant execute on object ventasSucursal.crear_factura to cajero;
go
--para insertar ventas efectuadas
--grant execute on object ventasSucursal.insertar_venta to cajero;
--go



--PERMISOS PARA SUPERVISOR
--para esquemas
grant select on schema::catalogo to supervisor;
go
grant select on schema::ventasSucursal to supervisor;
--para productos
grant select on catalogo.productos to supervisor;
go
grant select on catalogo.accesorio_electronico to supervisor;
go
grant select on catalogo.producto_importado to supervisor;
go
--para generar nota de credito
grant execute on object ventasSucursal.crear_nota to supervisor;
go
--para generar facturas
grant execute on object ventasSucursal.crear_factura to supervisor;
go
--para insertar ventas efectuadas
--grant execute on object ventasSucursal.insertar_venta to supervisor;


--PERMISOS PARA GERENTE
--para esquemas
grant select on schema::catalogo to gerente;
go
grant select on schema::ventasSucursal to gerente;
go
grant select on schema::sucursal to gerente;
go
--para productos
grant select on catalogo.productos to gerente;
go
grant select on catalogo.accesorio_electronico to gerente;
go
grant select on catalogo.producto_importado to gerente;
go
--para generar nota de credito
grant execute on object ventasSucursal.crear_nota to gerente;
go
--para generar facturas
grant execute on object ventasSucursal.crear_factura to gerente;
go
--para insertar ventas efectuadas
--grant execute on object ventasSucursal.insertar_venta to gerente;
--go

--


--AÑADO LOS ROLES A LOS USUARIOS CREADOS
alter role cajero add member cajero_suc;
go
alter role supervisor add member supervisor_suc;
go
alter role gerente add member gerente_suc;
go



