USE DBCRUDCORE


-- Create a new user

DECLARE @FirstName VARCHAR(100) = 'David';
DECLARE @LastName VARCHAR(100) = 'Farias';
DECLARE @Username VARCHAR(100) = 'defa88';
DECLARE @Email VARCHAR(100) = 'david@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a';


EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass;



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



			   SELECT * FROM T_USERS

-- Validate user
DECLARE @Email VARCHAR(100) = 'brensi@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';
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


DECLARE @IdUser INT;
DECLARE @ErrorMessage NVARCHAR(100);

EXEC sp_GetUserIdByEmail @Email = 'brensi@gmail.com', @IdUser = @IdUser OUTPUT, @ErrorMessage = @ErrorMessage OUTPUT;

SELECT @IdUser AS IdUser, @ErrorMessage AS ErrorMessage;