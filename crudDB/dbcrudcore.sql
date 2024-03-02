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
	ModifyBy VARCHAR(100),
	Role VARCHAR(100),
	Token VARCHAR(100)
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
            INSERT INTO T_USERS (FirstName, LastName, Username, Email, Pass, IdStatus, UserCreation, DateCreation, ModifyBy)
            VALUES (@FirstName, @LastName, @Username, @Email, @Pass, @IdStatus, @Username, GETDATE(), @Username);

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
    @Pass VARCHAR(500),
    @Success BIT OUTPUT,
    @ErrorMessage VARCHAR(500) OUTPUT
)
AS
BEGIN
    DECLARE @IdUser INT;

    SELECT @IdUser = IdUser FROM T_USERS WHERE Email = @Email AND IdStatus = 1;

    IF @IdUser IS NOT NULL
    BEGIN
        -- Verificar si la contraseña ingresada es correcta
        IF (SELECT COUNT(*) FROM T_USERS WHERE IdUser = @IdUser AND Pass = @Pass) = 1
        BEGIN
            SELECT @IdUser AS IdUser;

            INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
            VALUES (@IdUser, 'validate', GETDATE(), (SELECT Username FROM T_USERS WHERE IdUser = @IdUser));

            SET @Success = 1;
            SET @ErrorMessage = '';
        END
        ELSE
        BEGIN
            SET @Success = 0;
            SET @ErrorMessage = 'La contraseña es incorrecta.';
            SELECT '0' AS IdUser;
        END
    END
    ELSE
    BEGIN
        SET @Success = 0;
        SET @ErrorMessage = 'El usuario no existe.';
        SELECT '0' AS IdUser;
    END

    -- Agregar esta instrucción SELECT para devolver el mensaje de error
    SELECT @Success AS Success, @ErrorMessage AS ErrorMessage;
END;

CREATE PROCEDURE sp_ReadUser(
    @IdUser INT = NULL,
    @ShowAllUsers BIT = 0,
    @ErrorMessage NVARCHAR(100) OUTPUT
)
AS
BEGIN
    DECLARE @CurrentUsername VARCHAR(100);

    IF EXISTS (SELECT 1 FROM T_USERS WHERE IdUser = @IdUser)
    BEGIN
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
                U.DateModification,
				U.ModifyBy
            FROM T_USERS U
            INNER JOIN T_STATUS S ON U.IdStatus = S.IdStatus;

            INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
            VALUES (@IdUser, 'read all', GETDATE(), @CurrentUsername);

            SET @ErrorMessage = '';
        END
        ELSE
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
                U.DateModification,
				U.ModifyBy
            FROM T_USERS U
            INNER JOIN T_STATUS S ON U.IdStatus = S.IdStatus
            WHERE U.IdUser = @IdUser;

            INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
            VALUES (@IdUser, 'read', GETDATE(), @CurrentUsername);

            SET @ErrorMessage = '';
        END
    END
    ELSE
    BEGIN
        SET @ErrorMessage = 'User not found with IdUser provided';
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


CREATE PROC sp_DeleteUser(
    @IdUser INT,
    @ModifyBy VARCHAR(100)
)
AS
BEGIN
    DECLARE @UserCount INT;

    -- Check if the user exists
    SELECT @UserCount = COUNT(*) FROM T_USERS WHERE IdUser = @IdUser;

    IF @UserCount = 0
    BEGIN
        -- User not found, return an error message
        SELECT 'User not found' AS ErrorMessage;
        RETURN;
    END

    -- Delete the user and audit log
    DELETE FROM T_AUDIT_LOG WHERE IdUser = @IdUser;
    DELETE FROM T_USERS WHERE IdUser = @IdUser;

    -- Insert a new audit log record
    INSERT INTO T_AUDIT_LOG (IdUser, AuditType, AuditDate, UserName)
    VALUES (@IdUser, 'delete', GETDATE(), @ModifyBy);
END;


CREATE PROC sp_GetAuditLogs(
    @PageSize INT,
    @PageNumber INT,
    @IncludeDate BIT = 0,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
)
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

							

					