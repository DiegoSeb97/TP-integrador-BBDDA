------------------------------GENERACION DE LOGIN----------------------------------

/*
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
*/
--uso master porque los login deben ser creados a nivel servidor
use MASTER;
go

--login para gerente

IF NOT EXISTS (select 1 from syslogins where name = 'gerente_sucursal')
create login gerente_sucursal
	with password = 'contra123',	--contraseña
	default_database = Com5600G04,		--base de datos por defecto para el login
	check_policy = on,					--para que siga politicas de seguridad del sistema operativo
	check_expiration = off;				--para que la contraseña no expire, podria poner on para cambiarla regularmente
go

--login para supervisor
IF NOT EXISTS (select 1 from syslogins where name = 'supervisor_sucursal')
create login supervisor_sucursal
	with password = 'password',
	default_database = Com5600G04,
	check_policy = off,
	check_expiration = off;
go

--login para cajero
IF NOT EXISTS (SELECT 1 FROM SYSLOGINS WHERE NAME = 'cajero_sucursal')
create login cajero_sucursal
	with password = 'd321',
	default_database = Com5600G04,
	check_policy = off,
	check_expiration = off;
go
USE Com5600G04;

--CREACION DE USUARIOS Y ROLES
IF NOT EXISTS (select * from sysusers where name = 'gerente_suc')
BEGIN
create user gerente_suc for login gerente_sucursal with default_schema = CATALOGO;
create role gerente;
END
go

IF NOT EXISTS (select * from sysusers where name = 'supervisor_suc')
BEGIN
create user supervisor_suc for login supervisor_sucursal WITH default_schema = CATALOGO;
create role supervisor;
END
go

IF NOT EXISTS (select * from sysusers where name = 'cajero_suc')
BEGIN
create user cajero_suc for login cajero_sucursal WITH default_schema = CATALOGO;
create role cajero;
END
go

use Com5600G04

--PERMISOS PARA ROL CAJERO
grant control on schema::ventassucursal to cajero
go
grant select, execute on schema::sucursal to cajero
go
grant select, execute on schema::catalogo to cajero
go
--para ver productos
grant select on catalogo.producto to cajero;
go
--para ver clientes
grant select on VENTASSUCURSAL.cliente to cajero;
--para insertar ventas efectuadas
grant execute on VENTASSUCURSAL.REGISTRAR_VENTA to cajero;
go
--para generar facturas
grant execute on VENTASSUCURSAL.CREAR_PREFACTURA to cajero;
go
grant execute on VENTASSUCURSAL.EMITIR_FACT to cajero;
go
grant execute on VENTASSUCURSAL.CREAR_DETALLE to cajero;
go
grant execute on VENTASSUCURSAL.CREAR_MEDIO to cajero;
go


--PERMISOS PARA SUPERVISOR
--para esquemas
grant control on schema::sucursal to gerente;
go
grant control on schema::ventassucursal to supervisor
go
grant control on schema::catalogo to supervisor
go
grant control on schema::credito to supervisor
go
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
grant execute on CATALOGO.REGISTRAR_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ELIMINAR_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_FECHA_PRODUCTO to supervisor;
go
grant execute on CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA_PRODUCTO to supervisor;
go

--registro de clientes, alta y baja
grant execute on VENTASSUCURSAL.REGISTRAR_CLIENTE to supervisor;
go
grant execute on VENTASSUCURSAL.BAJA_CLIENTE to supervisor;
go
grant execute on VENTASSUCURSAL.ALTA_CLIENTE to supervisor;
go

--para insertar, validar e invalidar ventas efectuadas
grant execute on VENTASSUCURSAL.REGISTRAR_VENTA to supervisor;
go
grant execute on VENTASSUCURSAL.VALIDAR_VENTA to supervisor;
go
grant execute on VENTASSUCURSAL.INVALIDAR_VENTA to supervisor;
go

--para generar facturas
grant execute on VENTASSUCURSAL.CREAR_PREFACTURA to supervisor;
go
grant execute on VENTASSUCURSAL.EMITIR_FACT to supervisor;
go
grant execute on VENTASSUCURSAL.CREAR_DETALLE to supervisor;
go
grant execute on VENTASSUCURSAL.ELIMINAR_DETALLE to supervisor;
go
grant execute on VENTASSUCURSAL.CREAR_MEDIO to supervisor;
go
grant execute on VENTASSUCURSAL.ELIMINAR_MEDIO to supervisor;
go
grant execute on VENTASSUCURSAL.ACTUALIZAR_PAGO_FACT to supervisor;
go

--para generar nota de credito
grant execute on credito.crear_nota to supervisor;
go
grant execute on credito.crear_detalle_nota to supervisor;
go
grant execute on credito.emitir_nota to supervisor;
go

--PERMISOS PARA GERENTE
--para ver tablas de los esquemas
grant control on schema::sucursal to gerente;
go
grant control on schema::catalogo to gerente;
go
grant control on schema::VENTASSUCURSAL to gerente;
go
grant control on schema::sucursal to gerente;
go

--sucursal
grant execute on SUCURSAL.REGISTRAR_SUCURSAL to gerente;
go
grant execute on SUCURSAL.BAJAR_SUCURSAL to gerente;
go
grant execute on SUCURSAL.ALTA_SUCURSAL to gerente;
go
grant execute on SUCURSAL.ACTUALIZAR_DIRECCION_SUCURSAL to gerente;
go
grant execute on SUCURSAL.ACTUALIZAR_HORARIO_SUCURSAL to gerente;
go
grant execute on SUCURSAL.ACTUALIZAR_TELEFONO_SUCURSAL to gerente;
go

--empleados
grant execute on SUCURSAL.REGISTRAR_EMPLEADO to gerente;
go
grant execute on SUCURSAL.ALTA_EMPLEADO to gerente;
go
grant execute on SUCURSAL.BAJAR_EMPLEADO to gerente;
go

--productos
grant execute on CATALOGO.REGISTRAR_PRODUCTO to gerente;
go
grant execute on CATALOGO.ELIMINAR_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_CATEGORIA_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_NOMBRE_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_PRECIO_REFERENCIA_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_FECHA_PRODUCTO to gerente;
go
grant execute on CATALOGO.ACTUALIZAR_UNIDAD_REFERENCIA_PRODUCTO to gerente;
go

--registro de clientes, alta y baja
grant execute on VENTASSUCURSAL.REGISTRAR_CLIENTE to gerente;
go
grant execute on VENTASSUCURSAL.BAJA_CLIENTE to gerente;
go
grant execute on VENTASSUCURSAL.ALTA_CLIENTE to gerente;
go

--para insertar, validar e invalidar ventas efectuadas
grant execute on VENTASSUCURSAL.REGISTRAR_VENTA to gerente;
go
grant execute on VENTASSUCURSAL.VALIDAR_VENTA to gerente;
go
grant execute on VENTASSUCURSAL.INVALIDAR_VENTA to gerente;
go

--para generar facturas
grant execute on VENTASSUCURSAL.CREAR_PREFACTURA to gerente;
go
grant execute on VENTASSUCURSAL.EMITIR_FACT to gerente;
go
grant execute on VENTASSUCURSAL.CREAR_DETALLE to gerente;
go
grant execute on VENTASSUCURSAL.ELIMINAR_DETALLE to gerente;
go
grant execute on VENTASSUCURSAL.CREAR_MEDIO to gerente;
go
grant execute on VENTASSUCURSAL.ELIMINAR_MEDIO to gerente;
go
grant execute on VENTASSUCURSAL.ACTUALIZAR_PAGO_FACT to gerente;
go


--para generar nota de credito
grant execute on credito.crear_nota to supervisor;
go
grant execute on credito.crear_detalle_nota to supervisor;
go
grant execute on credito.emitir_nota to supervisor;
go

--AÑADO LOS ROLES A LOS USUARIOS CREADOS
alter role cajero add member cajero_suc;
go
alter role supervisor add member supervisor_suc;
go
alter role gerente add member gerente_suc;
go


