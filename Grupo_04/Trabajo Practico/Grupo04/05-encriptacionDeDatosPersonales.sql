------------------ENCRIPTACION DE DATOS PERSONALES DE EMPLEADOS-----------------
/*
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
*/
use Com5600G04;
go

--agrego campos para encriptar los datos
alter table SUCURSAL.empleado
add dni_cifrado	VARBINARY(256), 
	direccion_cifrada VARBINARY(256), 
	email_personal_cif VARBINARY(256),
	cuil_cifrado VARBINARY(256);
go

--declaro una clave para encriptar
declare @FraseClave NVARCHAR(128) = 'aLaGrandeLePuseCuca';


--actualizo la tabla y encripto los datos
update SUCURSAL.empleado
set dni_cifrado = ENCRYPTBYPASSPHRASE(@FraseClave, dni),
	direccion_cifrada = ENCRYPTBYPASSPHRASE(@FraseClave, direccion),
	email_personal_cif = ENCRYPTBYPASSPHRASE(@FraseClave, email_personal),
	cuil_cifrado = ENCRYPTBYPASSPHRASE(@FraseClave, cuil);
go

