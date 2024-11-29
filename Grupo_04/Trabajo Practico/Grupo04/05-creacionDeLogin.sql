------------------------------GENERACION DE LOGIN----------------------------------

--uso master porque los login deben ser creados a nivel servidor
use master;
go

--login para gerente

create login gerente_sucursal
	with password = 'contra123',	--contraseña
	default_database = Com5600G04,		--base de datos por defecto para el login
	check_policy = on,					--para que siga politicas de seguridad del sistema operativo
	check_expiration = off;				--para que la contraseña no expire, podria poner on para cambiarla regularmente
go

--login para supervisor
create login supervisor_sucursal
	with password = 'password',
	default_database = Com5600G04,
	check_policy = on,
	check_expiration = off;
go

--login para cajero
create login cajero_sucursal
	with password = 'd321',
	default_database = Com5600G04,
	check_policy = on,
	check_expiration = off;
go