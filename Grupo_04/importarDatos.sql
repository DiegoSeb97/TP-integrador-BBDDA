use Com5600G04;
go

--habilito consultas distribuidas, para poder usar la funcion openrowset
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

--inserto desde archivo excel en tabla accesorio_electronico
--la ruta del archivo puede variar
insert into catalogo.accesorio_electronico(producto, precioUnitUsd) 
SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0; Database=D:\datosTpBDA\TP_integrador_Archivos\Productos\Electronic_accessories.xlsx',
	[Sheet1$]);

--inserto desde catalogo.csv en tabla producto
--hay campos con comas por dentro, hay lineas que se cargan mal
--por ejemplo la linea 127, esto se ve al realizar select * de la tabla carga
BULK INSERT catalogo.producto 
FROM 'D:\datosTpBDA\TP_integrador_Archivos\Productos\catalogo.csv'
   WITH (
      FIELDTERMINATOR = ',',	--caracter delimitador
      ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
	  firstrow = 2,				--primera linea de datos
	  codepage = '65001'		--para poder leer caracteres especiales
);
GO

select * from catalogo.producto;


--inserto desde ventas_registradas.csv en tabla ventas registradas
BULK INSERT ventasSucursal.venta_registrada 
FROM 'D:\datosTpBDA\TP_integrador_Archivos\Ventas_registradas.csv'
   WITH (
      FIELDTERMINATOR = ';',	--caracter delimitador
      ROWTERMINATOR = '0x0a',	--10 en hexadecimal, salto de linea
	  firstrow = 2,				--primera linea de datos
	  codepage = '65001'		--para poder leer caracteres especiales
);
GO

select * from ventasSucursal.venta_registrada;