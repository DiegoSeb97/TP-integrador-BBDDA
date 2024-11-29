--TESTING DE LAS NOTAS DE CR�DITO
--REGISTRAMOS UNA SUCURSAL, UN EMPLEADO Y UN PRODUCTO
USE Com5600G04;

EXEC SUCURSAL.REGISTRAR_SUCURSAL 'San Justo', 'Per� 1903', 'Lunes a Viernes 12 a 19', '1551200406';

EXEC SUCURSAL.REGISTRAR_EMPLEADO 'Jos�', 'Gonzales', 34527890, 10101, 'Presidente Per�n 1438', 'josegonzales@gmail.com', 'josegon890@aurora.com', '20345278901', 'Encargado',
'San Justo', 'Noche 20-04';

EXEC CATALOGO.REGISTRAR_PRODUCTO 'Producto de belleza', 'Labial AVON', 120.43, 100, '10 cajas de 10 labiales', 'grms', '2024-11-27', 'AVON Argentina SA';

--CREAMOS UN CLIENTE
EXEC VENTASSUCURSAL.REGISTRAR_CLIENTE 46700923, 'Normal' , 'M'

--GENERAMOS UNA VENTA 
EXECUTE AS LOGIN = 'cajero_sucursal' --EL CAJERO GENERA FACTURAS, Y VENTAS, PERO NO PUEDE GENERAR NOTAS DE CR�DITO
EXEC VENTASSUCURSAL.CREAR_PREFACTURA '2024-09-11', 'Pendiente', 1, 'B', '654-89-0924' 

--AHORA SE CREAN LOS DETALLES DE LA VENTA
EXEC VENTASSUCURSAL.CREAR_DETALLE 2, 1, '654-89-0924'

--LUEGO SE TERMINA DE EMITIR LA FACTURA
EXEC VENTASSUCURSAL.EMITIR_FACT '654-89-0924'

EXECUTE AS LOGIN = 'supervisor_sucursal'
--INTENTAMOS CREAR LA NOTA DE CR�DITO
--SIENDO SUPERVISOR:
EXEC credito.CREAR_NOTA '654-89-0924'
EXEC credito.ACTUALIZAR_PAGO_FACT '654-89-0924', 'Pagado' --AUNQUE CAMBIE EL PRECIO DEL PRODUCTO, EL PRECIO DEL DETALLE DE LA NOTA ES EL MISMO

--CREAMOS LOS DETALLES (UNO POR CADA PRODUCTO DE LA NOTA DE CR�DITO)
DECLARE @ID_PROD INT = (SELECT ID FROM CATALOGO.PRODUCTO WHERE NOMBRE = 'Labial AVON')
EXEC CATALOGO.ACTUALIZAR_PRECIO_PRODUCTO @ID_PROD, 100 --CAMBIAMOS EL PRECIO, PERO EL PRECIO DE LA NOTA DE CR�DITO DEBE SER EL DEL DETALLE DE LA FACTURA

DECLARE @ID_FACT INT = (SELECT ID FROM VENTASSUCURSAL.FACTURA WHERE ID_FACTURA = '654-89-0924')
DECLARE @ID_NOTA INT = (SELECT ID FROM credito.NOTA_DE_CREDITO WHERE FACTURA_ID = @ID_FACT)
EXEC credito.CREAR_DETALLE_NOTA @ID_NOTA, 'Labial AVON', 3, @ID_FACT --NO PODEMOS CREARLA PORQUE EL DETALLE DE LA FACTURA DICE 2 PRODUCTOS Y ESTAMOS HACIENDO LA NOTA PARA 3, AL CAMBIARLO FUNCIONA

EXEC credito.CREAR_DETALLE_NOTA @ID_NOTA, 'Labial AVON', 2, @ID_FACT --FUNCIONA CORRECTAMENTE

EXEC credito.EMITIR_NOTA @ID_NOTA

