CREATE DATABASE DBCRUDCORE;
										
USE DBCRUDCORE;

CREATE TABLE T_STATUS (
    IdStatus INT PRIMARY KEY IDENTITY(1,1),
    StatusName VARCHAR(10) CHECK (StatusName IN ('A', 'I')),
    StatusDescription VARCHAR(100),
    UserCreation VARCHAR(100),
    DateCreation DATETIME,
    UserModification VARCHAR(100),
    DateModification DATETIME
);

INSERT INTO T_STATUS (StatusName, StatusDescription, UserCreation, DateCreation)
VALUES ('A', 'Activated', SUSER_SNAME(), GETDATE()), ('I', 'Inactivated', SUSER_SNAME(), GETDATE());

CREATE TABLE T_USERS (
    IdUser INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Username VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Pass VARCHAR(500),
    IdStatus INT,
    UserCreation VARCHAR(100),
    DateCreation DATETIME,
    UserModification VARCHAR(100),
    DateModification DATETIME,
	ModifyBy VARCHAR(100)
    FOREIGN KEY (IdStatus) REFERENCES T_STATUS(IdStatus)
);

CREATE TABLE T_AUDIT_LOG (
    IdAuditLog INT PRIMARY KEY IDENTITY(1,1),
    IdUser INT,
    AuditType VARCHAR(50),
    AuditDate DATETIME,
    UserName VARCHAR(100),
);



CREATE PROC sp_CreateUser(
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Username VARCHAR(100),
    @Email VARCHAR(100),
    @Pass VARCHAR(500),
    @IdStatus INT
)
AS
BEGIN
    DECLARE @Register BIT;
    DECLARE @Message VARCHAR(100);

    IF NOT EXISTS (SELECT * FROM T_USERS WHERE Email = @Email)
    BEGIN
        DECLARE @IdUser INT;

        IF (@IdStatus IS NOT NULL AND @IdStatus BETWEEN 1 AND 2)
        BEGIN
            INSERT INTO T_USERS (FirstName, LastName, Username, Email, Pass, IdStatus, UserCreation, DateCreation)
            VALUES (@FirstName, @LastName, @Username, @Email, @Pass, @IdStatus, @Username, GETDATE());

            SET @IdUser = SCOPE_IDENTITY();

            INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
            VALUES (@IdUser, 'create', GETDATE(), (SELECT Username FROM T_USERS WHERE IdUser = @IdUser));

            SET @Register = 1;
            SET @Message = 'registered user';

            UPDATE T_USERS
            SET UserModification = @Username,
                DateModification = GETDATE()
            WHERE IdUser = @IdUser;

            UPDATE T_STATUS
            SET UserModification = @Username,
                DateModification = GETDATE()
            WHERE IdStatus = @IdStatus;
        END
        ELSE
        BEGIN
            SET @Register = 0;
            SET @Message = 'invalid status';
        END
    END
    ELSE
    BEGIN
        SET @Register = 0;
        SET @Message = 'mail already exists';
    END

    SELECT @Register AS Register, @Message AS Message;
END;



CREATE PROC sp_ValidateUser(
    @Email VARCHAR(100),
    @Pass VARCHAR(500)
)
AS
BEGIN
    DECLARE @IdUser INT;

    SELECT @IdUser = IdUser FROM T_USERS WHERE Email = @Email AND Pass = @Pass AND IdStatus = 1;

    IF @IdUser IS NOT NULL
    BEGIN
        SELECT @IdUser AS IdUser;

        INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
        VALUES (@IdUser, 'validate', GETDATE(), (SELECT Username FROM T_USERS WHERE IdUser = @IdUser));
    END
    ELSE
    BEGIN
        SELECT '0' AS IdUser;
    END
END;


CREATE PROC sp_ReadUser
    @IdUser INT = NULL,
    @ShowAllUsers BIT = 0
AS
BEGIN
    DECLARE @CurrentUsername VARCHAR(100);

    SELECT @CurrentUsername = Username FROM T_USERS WHERE IdUser = @IdUser;

    IF @ShowAllUsers = 1
    BEGIN
        SELECT 
            U.IdUser,
            U.FirstName,
            U.LastName,
            U.Username,
            U.Email,
            U.IdStatus,
            S.StatusName,
            S.StatusDescription,
            U.UserCreation,
            U.DateCreation,
            U.UserModification,
            U.DateModification
        FROM T_USERS U
        INNER JOIN T_STATUS S ON U.IdStatus = S.IdStatus;

        INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
        VALUES (@IdUser, 'read all', GETDATE(), @CurrentUsername);
    END
    ELSE
    BEGIN
        IF @IdUser IS NOT NULL
        BEGIN
            SELECT 
                U.IdUser,
                U.FirstName,
                U.LastName,
                U.Username,
                U.Email,
                U.IdStatus,
                S.StatusName,
                S.StatusDescription,
                U.UserCreation,
                U.DateCreation,
                U.UserModification,
                U.DateModification
            FROM T_USERS U
            INNER JOIN T_STATUS S ON U.IdStatus = S.IdStatus
            WHERE IdUser = @IdUser;

            INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
            VALUES (@IdUser, 'read', GETDATE(), @CurrentUsername);
        END
        ELSE
        BEGIN
            SELECT 'No se proporcionó un IdUser válido' AS ErrorMessage;
        END
    END
END;

CREATE PROC sp_UpdateUser( 
	@IdUser INT, 
	@FirstName VARCHAR(100), 
	@LastName VARCHAR(100),
	@Username VARCHAR(100),
	@Email VARCHAR(100),
	@Pass VARCHAR(500), 
	@IdStatus INT, 
	@ModifyBy VARCHAR(100)
	)
	AS 
	BEGIN
		UPDATE T_USERS
		SET FirstName = @FirstName,
			LastName = @LastName,
			Username = @Username,
			Email = @Email,
			Pass = @Pass,
			IdStatus = @IdStatus,
			UserModification = @ModifyBy,
			DateModification = GETDATE()
		WHERE IdUser = @IdUser;

		INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
		VALUES (@IdUser, 'update', GETDATE(), @UserName);
	END;


CREATE PROC sp_RemoveUser(
    @IdUser INT,
    @ModifyBy VARCHAR(100)
)
AS
BEGIN

    DELETE FROM T_AUDIT_LOG WHERE IdUser = @IdUser;

    DELETE FROM T_USERS WHERE IdUser = @IdUser;

    INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
    VALUES (@IdUser, 'delete', GETDATE(), @ModifyBy);
END;


CREATE PROC sp_GetAuditLogs
    @PageSize INT,
    @PageNumber INT,
    @IncludeDate BIT = 0,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    DECLARE @TotalRows INT;

    IF @IncludeDate = 1
    BEGIN
        SELECT @TotalRows = COUNT(*) FROM T_AUDIT_LOG
        WHERE (AuditDate = @StartDate OR @StartDate IS NULL)
          AND (AuditDate = @EndDate OR @EndDate IS NULL)

        IF @TotalRows > 0
        BEGIN
            SELECT * FROM T_AUDIT_LOG
            WHERE (AuditDate = @StartDate OR @StartDate IS NULL)
              AND (AuditDate = @EndDate OR @EndDate IS NULL)
            ORDER BY AuditDate ASC
            OFFSET (@PageNumber - 1) * @PageSize ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT * FROM T_AUDIT_LOG
            ORDER BY AuditDate ASC
            OFFSET (@PageNumber - 1) * @PageSize ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
    END
    ELSE
    BEGIN
        SELECT @TotalRows = COUNT(*) FROM T_AUDIT_LOG;
        SELECT * FROM T_AUDIT_LOG
        ORDER BY AuditDate ASC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END
END;

							


-- Create a new user

DECLARE @FirstName VARCHAR(100) = 'Alejandra';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'ale478';
DECLARE @Email VARCHAR(100) = 'ale@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;


EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @IdStatus;

SELECT @Register AS Registered, @Message AS Message;


DECLARE @FirstName VARCHAR(100) = 'Jahi';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'jahi84';
DECLARE @Email VARCHAR(100) = 'jahi@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a620d39e2dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;
DECLARE @Register BIT;
DECLARE @Message VARCHAR(100);

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @Status, @Register OUTPUT, @Message OUTPUT;

SELECT @Register AS Registered, @Message AS Message;

DECLARE @FirstName VARCHAR(100) = 'Antonio';
DECLARE @LastName VARCHAR(100) = 'Linares';
DECLARE @Username VARCHAR(100) = 'antonio1503';
DECLARE @Email VARCHAR(100) = 'antonio@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;
DECLARE @Register BIT;
DECLARE @Message VARCHAR(100);

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @Status, @Register OUTPUT, @Message OUTPUT;

SELECT @Register AS Registered, @Message AS Message;

DECLARE @FirstName VARCHAR(100) = 'Lilu';
DECLARE @LastName VARCHAR(100) = 'Molina';
DECLARE @Username VARCHAR(100) = 'lilu213';
DECLARE @Email VARCHAR(100) = 'lilu@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a620339e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;
DECLARE @Register BIT;
DECLARE @Message VARCHAR(100);

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @Status, @Register OUTPUT, @Message OUTPUT;

SELECT @Register AS Registered, @Message AS Message;

DECLARE @FirstName VARCHAR(100) = 'Anni';
DECLARE @LastName VARCHAR(100) = 'Linamol';
DECLARE @Username VARCHAR(100) = 'anni03';
DECLARE @Email VARCHAR(100) = 'anni@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a6203439e25dd75ceffa3b72c632010c53a';
DECLARE @IdStatus INT = 1;
DECLARE @Register BIT;
DECLARE @Message VARCHAR(100);

EXEC sp_CreateUser @FirstName, @LastName,@Username, @Email, @Pass, @Status, @Register OUTPUT, @Message OUTPUT;

SELECT @Register AS Registered, @Message AS Message;


-- Validate user
DECLARE @Email VARCHAR(100) = 'ale@gmail.com';
DECLARE @Pass VARCHAR(500) = 'a62039e2dd75ceffa3b72c632010c53a';

EXEC sp_ValidateUser @Email, @Pass;

-- Read users
-- 1 User
EXEC sp_ReadUser @IdUser = 1, @ShowAllUsers = 0;

--All Users
EXEC sp_ReadUser  @IdUser = 1, @ShowAllUsers = 1;

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

EXEC sp_RemoveUser @IdUser, @ModifiedBy;

-- Display audit logs
DECLARE @PageSize INT = 10;
DECLARE @PageNumber INT = 1;
DECLARE @IncludeDate BIT = 1;
DECLARE @StartDate DATETIME = '2024-02-26';
DECLARE @EndDate DATETIME = '2022-02-26';

EXEC sp_GetAuditLogs @PageSize, @PageNumber, @IncludeDate, @StartDate, @EndDate;


DECLARE @PageSize INT = 15;
DECLARE @PageNumber INT = 1;
DECLARE @IncludeDate BIT = 0;
DECLARE @AuditDate DATETIME = NULL;

EXEC sp_GetAuditLogs @PageSize, @PageNumber, @IncludeDate, @AuditDate;

-- Display status legend
SELECT StatusName, StatusDescription
FROM T_STATUS;


