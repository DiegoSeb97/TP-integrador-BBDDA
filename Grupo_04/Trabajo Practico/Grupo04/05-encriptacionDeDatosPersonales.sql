------------------ENCRIPTACION DE DATOS PERSONALES DE EMPLEADOS-----------------
/*
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
*/
use Com5600G04;
go

--agrego campos para encriptar los datos a la tabla empleado
--DEFINIMOS UNA NUEVA TABLA PARA DEJAR LAS ENTREGAS DIVIDIDAS EN SCRIPTS
--TABLA EMPLEADO 
IF NOT EXISTS (SELECT * 
               FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'SUCURSAL' 
                 AND TABLE_NAME = 'empleado')
BEGIN
	create table SUCURSAL.empleado(
		id int identity(1, 1) primary key,
		legajo int,
		nombre varchar(50),
		apellido varchar(50),
		dni int,
		direccion varchar(100),
		email_personal varchar(75),
		email_empresarial varchar(75),
		cuil char(12),
		cargo varchar(20),
		sucursal int foreign key references sucursal.sucursal(id),
		turno varchar(20), 
		dni_cifrado	VARBINARY(256), 
		direccion_cifrada VARBINARY(256), 
		email_personal_cif VARBINARY(256),
		cuil_cifrado VARBINARY(256),
		nombre_cifrado VARBINARY(256),
		apellido_cifrado VARBINARY(256),
		baja datetime default null
	)
END
ELSE
	ALTER TABLE SUCURSAL.EMPLEADO ADD dni_cifrado VARBINARY(256), 
		direccion_cifrada VARBINARY(256), 
		email_personal_cif VARBINARY(256),
		cuil_cifrado VARBINARY(256),
		nombre_cifrado VARBINARY(256),
		apellido_cifrado VARBINARY(256)
go

--declaro una clave para encriptar
declare @FraseClave NVARCHAR(128) = 'aLaGrandeLePuseCuca';

--actualizo la tabla y encripto los datos
update SUCURSAL.empleado
set dni_cifrado = ENCRYPTBYPASSPHRASE(@FraseClave, CAST(dni AS VARCHAR(MAX))),
	direccion_cifrada = ENCRYPTBYPASSPHRASE(@FraseClave, direccion),
	email_personal_cif = ENCRYPTBYPASSPHRASE(@FraseClave, email_personal),
	cuil_cifrado = ENCRYPTBYPASSPHRASE(@FraseClave, cuil),
	nombre_cifrado = ENCRYPTBYPASSPHRASE(@FRASECLAVE, nombre),
	apellido_cifrado = ENCRYPTBYPASSPHRASE(@FRASECLAVE, APELLIDO);
go

