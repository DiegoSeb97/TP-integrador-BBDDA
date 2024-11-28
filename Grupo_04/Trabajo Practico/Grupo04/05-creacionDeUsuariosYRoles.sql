----------------------------------CREACION DE USUARIOS Y ROLES------------------------------
--creacion de usuarios y roles a nivel base de datos
use Com5600G04;
go

--CREACION DE USUARIOS
create user gerente_suc for login gerente_sucursal;
go

create user supervisor_suc for login supervisor_sucursal;
go

create user cajero_suc for login cajero_sucursal;
go


--CREACION DE ROLES
create role gerente;
go
create role supervisor;
go
create role cajero;
go


--PERMISOS PARA ROL CAJERO
--para ver productos
grant select on catalogo.producto to cajero;
go
--para ver clientes
grant select on VENTASSUCURSAL.cliente to cajero;
--para insertar ventas efectuadas
grant execute on object VENTASSUCURSAL.REGISTRAR_VENTA to cajero;
go
--para generar facturas
grant execute on object VENTASSUCURSAL.CREAR_PREFACTURA to cajero;
go
grant execute on object VENTASSUCURSAL.EMITIR_FACT to cajero;
go
grant execute on object VENTASSUCURSAL.CREAR_DETALLE to cajero;
go
grant execute on object VENTASSUCURSAL.CREAR_MEDIO to cajero;
go


--PERMISOS PARA SUPERVISOR
--para esquemas
grant select on schema::catalogo to supervisor;
go
grant select on schema::ventasSucursal to supervisor;
--para ver productos
grant select on catalogo.producto to supervisor;
go
--para ver clientes
grant select on VENTASSUCURSAL.cliente to supervisor;
go
--para ver medios de pago
grant select on VENTASSUCURSAL.medio_pago to supervisor;
go

--registrar, eliminar y actualizar productos
grant execute on object CATALOGO.REGISTRAR_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ELIMINAR_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_FECHA_PRODUCTO to supervisor;
go
grant execute on object CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA to supervisor;
go

--registro de clientes, alta y baja
grant execute on object VENTASSUCURSAL.REGISTRAR_CLIENTE to supervisor;
go
grant execute on object VENTASSUCURSAL.BAJA_CLIENTE to supervisor;
go
grant execute on object VENTASSUCURSAL.ALTA_CLIENTE to supervisor;
go

--para insertar, validar e invalidar ventas efectuadas
grant execute on object VENTASSUCURSAL.REGISTRAR_VENTA to supervisor;
go
grant execute on object VENTASSUCURSAL.VALIDAR_VENTA to supervisor;
go
grant execute on object VENTASSUCURSAL.INVALIDAR_VENTA to supervisor;
go

--para generar facturas
grant execute on object VENTASSUCURSAL.CREAR_PREFACTURA to supervisor;
go
grant execute on object VENTASSUCURSAL.EMITIR_FACT to supervisor;
go
grant execute on object VENTASSUCURSAL.CREAR_DETALLE to supervisor;
go
grant execute on object VENTASSUCURSAL.ELIMINAR_DETALLE to supervisor;
go
grant execute on object VENTASSUCURSAL.CREAR_MEDIO to supervisor;
go
grant execute on object VENTASSUCURSAL.ELIMINAR_MEDIO to supervisor;
go
grant execute on object VENTASSUCURSAL.ACTUALIZAR_PAGO_FACT to supervisor;
go
/*
--para generar nota de credito
grant execute on object ventasSucursal.crear_nota to supervisor;
go
*/


--PERMISOS PARA GERENTE
--para ver tablas de los esquemas
grant select on schema::catalogo to gerente;
go
grant select on schema::VENTASSUCURSAL to gerente;
go
grant select on schema::sucursal to gerente;
go

--sucursal
grant execute on object SUCURSAL.REGISTRAR_SUCURSAL to gerente;
go
grant execute on object SUCURSAL.BAJAR_SUCURSAL to gerente;
go
grant execute on object SUCURSAL.ALTA_SUCURSAL to gerente;
go
grant execute on object SUCURSAL.ACTUALIZAR_DIRECCION_SUCURSAL to gerente;
go
grant execute on object SUCURSAL.ACTUALIZAR_HORARIO_SUCURSAL to gerente;
go
grant execute on object SUCURSAL.ACTUALIZAR_TELEFONO_SUCURSAL to gerente;
go

--empleados
grant execute on object SUCURSAL.REGISTRAR_EMPLEADO to gerente;
go
grant execute on object SUCURSAL.ALTA_EMPLEADO to gerente;
go
grant execute on object SUCURSAL.BAJAR_EMPLEADO to gerente;
go

--productos
grant execute on object CATALOGO.REGISTRAR_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ELIMINAR_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_FECHA_PRODUCTO to gerente;
go
grant execute on object CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA to gerente;
go

--registro de clientes, alta y baja
grant execute on object VENTASSUCURSAL.REGISTRAR_CLIENTE to gerente;
go
grant execute on object VENTASSUCURSAL.BAJA_CLIENTE to gerente;
go
grant execute on object VENTASSUCURSAL.ALTA_CLIENTE to gerente;
go

--para insertar, validar e invalidar ventas efectuadas
grant execute on object VENTASSUCURSAL.REGISTRAR_VENTA to gerente;
go
grant execute on object VENTASSUCURSAL.VALIDAR_VENTA to gerente;
go
grant execute on object VENTASSUCURSAL.INVALIDAR_VENTA to gerente;
go

--para generar facturas
grant execute on object VENTASSUCURSAL.CREAR_PREFACTURA to gerente;
go
grant execute on object VENTASSUCURSAL.EMITIR_FACT to gerente;
go
grant execute on object VENTASSUCURSAL.CREAR_DETALLE to gerente;
go
grant execute on object VENTASSUCURSAL.ELIMINAR_DETALLE to gerente;
go
grant execute on object VENTASSUCURSAL.CREAR_MEDIO to gerente;
go
grant execute on object VENTASSUCURSAL.ELIMINAR_MEDIO to gerente;
go
grant execute on object VENTASSUCURSAL.ACTUALIZAR_PAGO_FACT to gerente;
go

/*
--para generar nota de credito
grant execute on object ventasSucursal.crear_nota to supervisor;
go
*/



--AÑADO LOS ROLES A LOS USUARIOS CREADOS
alter role cajero add member cajero_suc;
go
alter role supervisor add member supervisor_suc;
go
alter role gerente add member gerente_suc;
go



