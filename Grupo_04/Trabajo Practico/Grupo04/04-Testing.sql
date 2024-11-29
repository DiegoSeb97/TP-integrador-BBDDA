--TEST DE IMPORTACION DE ARCHIVOS
USE Com5600G04
GO

--importacion de datos
--IMPORTAMOS LOS PRODUCTOS DEL CATÁLOGO
exec CATALOGO.CARGAR_PRODUCTOS_CSV
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Productos\catalogo.csv';
--IMPORTAMOS LOS ACCESORIOS ELECTRÓNICOS
exec CATALOGO.CARGAR_ACCESORIOS_ELECTRONICOS_XLSX
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
--IMPORTAMOS LOS PRODUCTOS IMPORTADOS
EXEC CATALOGO.CARGAR_PRODUCTOS_IMPORTADOS_XLSX 
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
--IMPORTAMOS LAS SUCURSALES
exec SUCURSAL.cargar_sucursales_xlsx
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx';
--IMPORTAMOS LOS EMPLEADOS
EXEC SUCURSAL.CARGAR_EMPLEADOS_XLSX 
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx'
--IMPORTAMOS LOS MEDIOS DE PAGO
EXEC VENTASSUCURSAL.CARGAR_MEDIOS_PAGO 
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx'
--IMPORTAMOS LAS VENTAS REGISTRADAS
EXEC VENTASSUCURSAL.CARGAR_VENTAS_REGISTRADAS_CSV 
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Ventas_registradas.csv',
N'C:\Users\Ezequiel\Documents\Bases de Datos Aplicadas\TP-integrador-BBDDA\Grupo_04\Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx'

SELECT * FROM SUCURSAL.SUCURSAL;
SELECT * FROM SUCURSAL.EMPLEADO;
SELECT * FROM VENTASSUCURSAL.MEDIO_PAGO;
SELECT * FROM VENTASSUCURSAL.VENTA_REGISTRADA;
SELECT * FROM VENTASSUCURSAL.FACTURA;
SELECT * FROM CATALOGO.PRODUCTO;
DELETE FROM SUCURSAL.EMPLEADO
DELETE FROM CATALOGO.PRODUCTO;
DELETE FROM VENTASSUCURSAL.MEDIO_PAGO
DELETE FROM VENTASSUCURSAL.DETALLE
DELETE FROM VENTASSUCURSAL.VENTA_REGISTRADA
DELETE FROM VENTASSUCURSAL.FACTURA;
SELECT * FROM VENTASSUCURSAL.FACTURA WHERE ID IN (
SELECT id_fact FROM VENTASSUCURSAL.DETALLE WHERE ID_PROD IS NULL)