USE DBCRUDCORE


-- Create a new user

DECLARE @FirstName VARCHAR(100) = 'Alejandra';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'ale478';
DECLARE @Email VARCHAR(100) = 'ale@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IdStatus;



DECLARE @FirstName VARCHAR(100) = 'Jahi';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'jahi84';
DECLARE @Email VARCHAR(100) = 'jahi@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a620d39e2dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;


EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IdStatus;


DECLARE @FirstName VARCHAR(100) = 'Antonio';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'antonio1503';
DECLARE @Email VARCHAR(100) = 'antonio@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IDStatus;



DECLARE @FirstName VARCHAR(100) = 'Lilu';
DECLARE @LastName VARCHAR(100) = 'Molina';
DECLARE @Username VARCHAR(100) = 'lilu213';
DECLARE @Email VARCHAR(100) = 'lilu@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a620339e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IdStatus;


DECLARE @FirstName VARCHAR(100) = 'Anni';
DECLARE @LastName VARCHAR(100) = 'Linamol';
DECLARE @Username VARCHAR(100) = 'anni03';
DECLARE @Email VARCHAR(100) = 'anni@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a6203439e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IdStatus;





-- Validate user
DECLARE @Email VARCHAR(100) = 'sfsf@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a';
DECLARE @Success BIT;
DECLARE @ErrorMessage VARCHAR(500);

EXEC sp_ValidateUser @Email, @Pass, @Success OUTPUT, @ErrorMessage OUTPUT;



						   select * from T_USERS
-- Read users
-- 1 User
EXEC sp_ReadUser @IdUser = 1, @ShowAllUsers = 0;

--All Users
DECLARE @ErrorMessage NVARCHAR(100);

EXEC sp_ReadUser @IdUser = 1, @ShowAllUsers = 1, @ErrorMessage = @ErrorMessage OUTPUT;

SELECT @ErrorMessage AS ErrorMessage;


-- Update user
DECLARE @IdUser INT = 3;
DECLARE @FirstName VARCHAR(100) = 'Alejandra Updated';
DECLARE @LastName VARCHAR(100) = 'Linares Updated';
DECLARE @Username VARCHAR(100) = 'ale478 Updated';
DECLARE @Email VARCHAR(100) = 'ale@gmail.com Updated';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a Updated';
DECLARE @IdStatus INT = 2;
DECLARE @ModifiedBy VARCHAR(100) = @Username;

EXEC sp_UpdateUser @IdUser, @FirstName, @LastName, @Username, @Email, @Pass, @IdStatus, @ModifiedBy;



-- Remove user
DECLARE @IdUser INT = 1;
DECLARE @ModifiedBy VARCHAR(100);

SELECT @ModifiedBy = Username FROM T_USERS WHERE IdUser = @IdUser;

EXEC sp_DeleteUser @IdUser, @ModifiedBy;



-- Display audit logs
DECLARE @PageSize INT = 1;
DECLARE @PageNumber INT = 1;
DECLARE @IncludeDate BIT = 1;
DECLARE @StartDate DATETIME = '2024-02-26';
DECLARE @EndDate DATETIME = '2022-02-26';

EXEC sp_GetAuditLogs @PageSize, @PageNumber, @IncludeDate, @StartDate, @EndDate;

DECLARE @PageSize INT = 50;
DECLARE @PageNumber INT = 1;
DECLARE @IncludeDate BIT = 0;
DECLARE @AuditDate DATETIME = NULL;

EXEC sp_GetAuditLogs @PageSize, @PageNumber, @IncludeDate, @AuditDate;


-- Display status legend
SELECT StatusName, StatusDescription
FROM T_STATUS;