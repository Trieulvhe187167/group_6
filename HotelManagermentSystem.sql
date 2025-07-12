-- Hotel Management System with Email Verification and Deposit System Database Script
-- Combined version including verification system for secure changes and deposit management
-- Enhanced with additional employee details

-- 1. Create database if not exists
IF DB_ID(N'HotelManagement') IS NULL
    CREATE DATABASE HotelManagement;
GO

USE HotelManagement;
GO

-- Drop existing tables if they exist (in correct order due to foreign keys)
-- Verification system tables
IF OBJECT_ID('dbo.NotificationHistory', 'U') IS NOT NULL DROP TABLE dbo.NotificationHistory;
IF OBJECT_ID('dbo.SecurityAuditLog', 'U') IS NOT NULL DROP TABLE dbo.SecurityAuditLog;
IF OBJECT_ID('dbo.EmailTemplates', 'U') IS NOT NULL DROP TABLE dbo.EmailTemplates;
IF OBJECT_ID('dbo.PendingChanges', 'U') IS NOT NULL DROP TABLE dbo.PendingChanges;

-- Hotel management tables
IF OBJECT_ID('dbo.Activities', 'U') IS NOT NULL DROP TABLE dbo.Activities;
IF OBJECT_ID('dbo.Comments', 'U') IS NOT NULL DROP TABLE dbo.Comments;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Blogs', 'U') IS NOT NULL DROP TABLE dbo.Blogs;
IF OBJECT_ID('dbo.Feedback', 'U') IS NOT NULL DROP TABLE dbo.Feedback;
IF OBJECT_ID('dbo.OTASync', 'U') IS NOT NULL DROP TABLE dbo.OTASync;
IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL DROP TABLE dbo.Notifications;
IF OBJECT_ID('dbo.AmenityInventory', 'U') IS NOT NULL DROP TABLE dbo.AmenityInventory;
IF OBJECT_ID('dbo.CheckOutDetails', 'U') IS NOT NULL DROP TABLE dbo.CheckOutDetails;
IF OBJECT_ID('dbo.CheckInDetails', 'U') IS NOT NULL DROP TABLE dbo.CheckInDetails;
IF OBJECT_ID('dbo.RoomDamages', 'U') IS NOT NULL DROP TABLE dbo.RoomDamages;
IF OBJECT_ID('dbo.InspectionItems', 'U') IS NOT NULL DROP TABLE dbo.InspectionItems;
IF OBJECT_ID('dbo.RoomInspections', 'U') IS NOT NULL DROP TABLE dbo.RoomInspections;
IF OBJECT_ID('dbo.ReservationAmenityUsage', 'U') IS NOT NULL DROP TABLE dbo.ReservationAmenityUsage;
IF OBJECT_ID('dbo.RoomAmenities', 'U') IS NOT NULL DROP TABLE dbo.RoomAmenities;
IF OBJECT_ID('dbo.ReservationServices', 'U') IS NOT NULL DROP TABLE dbo.ReservationServices;
IF OBJECT_ID('dbo.Services', 'U') IS NOT NULL DROP TABLE dbo.Services;
IF OBJECT_ID('dbo.RoomEquipment', 'U') IS NOT NULL DROP TABLE dbo.RoomEquipment;
IF OBJECT_ID('dbo.Equipment', 'U') IS NOT NULL DROP TABLE dbo.Equipment;
IF OBJECT_ID('dbo.HousekeepingTasks', 'U') IS NOT NULL DROP TABLE dbo.HousekeepingTasks;
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL DROP TABLE dbo.Reservations;
IF OBJECT_ID('dbo.Rooms', 'U') IS NOT NULL DROP TABLE dbo.Rooms;
IF OBJECT_ID('dbo.RoomTypeImages', 'U') IS NOT NULL DROP TABLE dbo.RoomTypeImages;
IF OBJECT_ID('dbo.RoomTypes', 'U') IS NOT NULL DROP TABLE dbo.RoomTypes;
IF OBJECT_ID('dbo.GroupBookings', 'U') IS NOT NULL DROP TABLE dbo.GroupBookings;
IF OBJECT_ID('dbo.EmployeeDetails', 'U') IS NOT NULL DROP TABLE dbo.EmployeeDetails;
IF OBJECT_ID('dbo.CustomerDetails', 'U') IS NOT NULL DROP TABLE dbo.CustomerDetails;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;

-- Drop existing procedures
-- Hotel management procedures
IF OBJECT_ID('dbo.sp_CreateCustomer', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateCustomer;
IF OBJECT_ID('dbo.sp_CreateEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateEmployee;
IF OBJECT_ID('dbo.sp_UpdateEmployeeDetails', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateEmployeeDetails;
IF OBJECT_ID('dbo.sp_StartRoomInspection', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_StartRoomInspection;
IF OBJECT_ID('dbo.sp_AddInspectionItem', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddInspectionItem;
IF OBJECT_ID('dbo.sp_AddRoomDamage', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddRoomDamage;
IF OBJECT_ID('dbo.sp_CompleteInspection', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CompleteInspection;
IF OBJECT_ID('dbo.sp_CheckRoomAvailability', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CheckRoomAvailability;

-- Deposit procedures
IF OBJECT_ID('dbo.sp_ProcessDepositPayment', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProcessDepositPayment;
IF OBJECT_ID('dbo.sp_RefundDeposit', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RefundDeposit;

-- Verification system procedures
IF OBJECT_ID('dbo.sp_InitiateChangeRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_InitiateChangeRequest;
IF OBJECT_ID('dbo.sp_ApproveChangeRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ApproveChangeRequest;
IF OBJECT_ID('dbo.sp_CleanupExpiredTokens', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CleanupExpiredTokens;

-- Drop existing views
-- Hotel management views
IF OBJECT_ID('dbo.vw_Customers', 'V') IS NOT NULL DROP VIEW dbo.vw_Customers;
IF OBJECT_ID('dbo.vw_Employees', 'V') IS NOT NULL DROP VIEW dbo.vw_Employees;
IF OBJECT_ID('dbo.vw_EmployeeDetails', 'V') IS NOT NULL DROP VIEW dbo.vw_EmployeeDetails;
IF OBJECT_ID('dbo.vw_PendingInspections', 'V') IS NOT NULL DROP VIEW dbo.vw_PendingInspections;
IF OBJECT_ID('dbo.vw_InspectionCharges', 'V') IS NOT NULL DROP VIEW dbo.vw_InspectionCharges;
IF OBJECT_ID('dbo.vw_ActiveReservations', 'V') IS NOT NULL DROP VIEW dbo.vw_ActiveReservations;
IF OBJECT_ID('dbo.vw_RoomStatus', 'V') IS NOT NULL DROP VIEW dbo.vw_RoomStatus;
IF OBJECT_ID('dbo.vw_RoomTypeAvailability', 'V') IS NOT NULL DROP VIEW dbo.vw_RoomTypeAvailability;
IF OBJECT_ID('dbo.vw_DailyInspectionReport', 'V') IS NOT NULL DROP VIEW dbo.vw_DailyInspectionReport;
IF OBJECT_ID('dbo.vw_MinibarConsumptionReport', 'V') IS NOT NULL DROP VIEW dbo.vw_MinibarConsumptionReport;
IF OBJECT_ID('dbo.vw_ReservationDeposits', 'V') IS NOT NULL DROP VIEW dbo.vw_ReservationDeposits;

-- Verification system views
IF OBJECT_ID('dbo.vw_PendingChangesSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_PendingChangesSummary;
IF OBJECT_ID('dbo.vw_SecurityAuditDashboard', 'V') IS NOT NULL DROP VIEW dbo.vw_SecurityAuditDashboard;

-- Drop existing triggers
IF OBJECT_ID('dbo.TR_Users_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Users_Update;
IF OBJECT_ID('dbo.TR_CustomerDetails_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_CustomerDetails_Update;
IF OBJECT_ID('dbo.TR_EmployeeDetails_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_EmployeeDetails_Update;
IF OBJECT_ID('dbo.TR_RoomTypes_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_RoomTypes_Update;
IF OBJECT_ID('dbo.TR_Reservations_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Reservations_Update;
IF OBJECT_ID('dbo.TR_Housekeeping_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Housekeeping_Update;
IF OBJECT_ID('dbo.TR_Blogs_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Blogs_Update;
IF OBJECT_ID('dbo.TR_Events_Update', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Events_Update;
IF OBJECT_ID('dbo.TR_Users_SecurityAudit', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Users_SecurityAudit;
GO

--------------------------------------------------------------------------------
-- PART 1: CORE HOTEL MANAGEMENT TABLES
--------------------------------------------------------------------------------

-- 2. Users Table (Base table for all users)
CREATE TABLE dbo.Users (
    Id           INT           IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName     NVARCHAR(100) NULL,
    Email        NVARCHAR(100) NULL UNIQUE,
    Phone        NVARCHAR(20)  NULL,
    Role         NVARCHAR(20)  NOT NULL
                 CONSTRAINT CK_Users_Role 
                     CHECK (Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR','CUSTOMER','INACTIVE')),    
    Status       BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt    DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

-- Trigger to update UpdatedAt
CREATE TRIGGER TR_Users_Update
ON dbo.Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE u
    SET u.UpdatedAt = GETDATE()
    FROM dbo.Users u
    JOIN inserted i ON u.Id = i.Id;
END;
GO

-- 3. CustomerDetails Table
CREATE TABLE dbo.CustomerDetails (
    Id              INT           IDENTITY(1,1) PRIMARY KEY,
    UserId          INT           NOT NULL UNIQUE,
    IdType          NVARCHAR(20)  NULL
                    CONSTRAINT CK_CustomerDetails_IdType
                        CHECK (IdType IN ('PASSPORT','ID_CARD','DRIVER_LICENSE')),
    IdNumber        NVARCHAR(50)  NULL,
    DateOfBirth     DATE          NULL,
    Gender          NVARCHAR(10)  NULL
                    CONSTRAINT CK_CustomerDetails_Gender
                        CHECK (Gender IN ('MALE','FEMALE','OTHER')),
    Address         NVARCHAR(500) NULL,
    City            NVARCHAR(100) NULL,
    Country         NVARCHAR(100) NULL,
    LoyaltyPoints   INT          NOT NULL DEFAULT 0,
    MembershipLevel NVARCHAR(20) NOT NULL DEFAULT 'BRONZE'
                    CONSTRAINT CK_CustomerDetails_MembershipLevel
                        CHECK (MembershipLevel IN ('BRONZE','SILVER','GOLD','PLATINUM')),
    IsVIP           BIT          NOT NULL DEFAULT 0,
    CreatedAt       DATETIME     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_CustomerDetails_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);
GO

-- Trigger to update UpdatedAt
CREATE TRIGGER TR_CustomerDetails_Update
ON dbo.CustomerDetails
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE cd
    SET cd.UpdatedAt = GETDATE()
    FROM dbo.CustomerDetails cd
    JOIN inserted i ON cd.Id = i.Id;
END;
GO

-- 4. EmployeeDetails Table (Enhanced with additional columns)
CREATE TABLE dbo.EmployeeDetails (
    Id           INT           IDENTITY(1,1) PRIMARY KEY,
    UserId       INT           NOT NULL UNIQUE,
    Department   NVARCHAR(50)  NULL,
    HireDate     DATE          NULL,
    Salary       DECIMAL(10,2) NULL,
    -- Additional columns
    DateOfBirth  DATE          NULL,
    Gender       NVARCHAR(10)  NULL
                 CONSTRAINT CK_EmployeeDetails_Gender
                     CHECK (Gender IN ('MALE','FEMALE','OTHER')),
    Address      NVARCHAR(500) NULL,
    City         NVARCHAR(100) NULL,
    Country      NVARCHAR(100) NULL,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_EmployeeDetails_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);
GO

-- Trigger to update UpdatedAt
CREATE TRIGGER TR_EmployeeDetails_Update
ON dbo.EmployeeDetails
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ed
    SET ed.UpdatedAt = GETDATE()
    FROM dbo.EmployeeDetails ed
    JOIN inserted i ON ed.Id = i.Id;
END;
GO

-- 5. GroupBookings Table
CREATE TABLE dbo.GroupBookings (
    Id        INT           IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(100) NOT NULL,
    CreatedBy INT           NULL,
    CreatedAt DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_GroupBookings_User FOREIGN KEY(CreatedBy)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 6. RoomTypes Table
CREATE TABLE dbo.RoomTypes (
    Id          INT          IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    BasePrice   DECIMAL(10,2) NOT NULL,
    imageUrl    NVARCHAR(500) NOT NULL,
    Capacity    INT          NOT NULL DEFAULT(1),
    Status      NVARCHAR(20) NOT NULL DEFAULT 'active',
    CreatedAt   DATETIME     NOT NULL DEFAULT GETDATE(),
    UpdatedAt   DATETIME     NOT NULL DEFAULT GETDATE()
);
GO

-- Trigger to update UpdatedAt for RoomTypes
CREATE TRIGGER TR_RoomTypes_Update
ON dbo.RoomTypes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE rt
    SET rt.UpdatedAt = GETDATE()
    FROM dbo.RoomTypes rt
    JOIN inserted i ON rt.Id = i.Id;
END;
GO

-- 7. RoomTypeImages Table
CREATE TABLE dbo.RoomTypeImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RoomTypeId INT NOT NULL,
    ImageUrl NVARCHAR(500) NOT NULL,
    ImageType NVARCHAR(50) NULL,
    DisplayOrder INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_RoomTypeImages_RoomType FOREIGN KEY(RoomTypeId)
        REFERENCES dbo.RoomTypes(Id)
        ON DELETE CASCADE
);
GO

-- 8. Rooms Table
CREATE TABLE dbo.Rooms (
    Id           INT          IDENTITY(1,1) PRIMARY KEY,
    RoomNumber   NVARCHAR(10) NOT NULL UNIQUE,
    RoomTypeId   INT          NOT NULL,
    Status       NVARCHAR(20) NOT NULL
                 CONSTRAINT CK_Rooms_Status 
                     CHECK (Status IN ('AVAILABLE','OCCUPIED','MAINTENANCE','DIRTY')),
    CONSTRAINT FK_Rooms_RoomTypes FOREIGN KEY(RoomTypeId)
        REFERENCES dbo.RoomTypes(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 9. Reservations Table (with Deposit columns)
CREATE TABLE dbo.Reservations (
    Id                  INT          IDENTITY(1,1) PRIMARY KEY,
    UserId              INT          NOT NULL,
    GroupBookingId      INT          NULL,
    CreatedBy           INT          NULL,
    RoomId              INT          NULL,
    RoomTypeId          INT          NULL,
    CheckIn             DATE         NOT NULL,
    CheckOut            DATE         NOT NULL,
    Status              NVARCHAR(20) NOT NULL
                         CONSTRAINT CK_Res_Status 
                             CHECK (Status IN ('PENDING','CONFIRMED','CANCELLED','COMPLETED')),
    TotalAmount         DECIMAL(10,2) NULL,
    Notes               NVARCHAR(MAX) NULL,
    SpecialRequests     NVARCHAR(500) NULL,
    NumberOfCustomers   INT          NOT NULL DEFAULT 1,
    -- Deposit columns
    DepositAmount       DECIMAL(10,2) NULL,
    DepositPaidDate     DATETIME      NULL,
    DepositStatus       NVARCHAR(20)  NULL
                        CONSTRAINT CK_Reservations_DepositStatus 
                            CHECK (DepositStatus IN ('PENDING', 'PAID', 'REFUNDED')),
    CreatedAt           DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt           DATETIME      NULL,
    CONSTRAINT FK_Res_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Res_CreatedBy FOREIGN KEY(CreatedBy)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Res_GroupBookings FOREIGN KEY(GroupBookingId)
        REFERENCES dbo.GroupBookings(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Res_Room FOREIGN KEY(RoomId)
        REFERENCES dbo.Rooms(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Res_RoomType FOREIGN KEY(RoomTypeId)
        REFERENCES dbo.RoomTypes(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- Trigger to update UpdatedAt for Reservations
CREATE TRIGGER TR_Reservations_Update
ON dbo.Reservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r
    SET r.UpdatedAt = GETDATE()
    FROM dbo.Reservations r
    JOIN inserted i ON r.Id = i.Id;
END;
GO

-- 10. Payments Table (with PaymentType column)
CREATE TABLE dbo.Payments (
    Id             INT           IDENTITY(1,1) PRIMARY KEY,
    ReservationId  INT           NOT NULL,
    Amount         DECIMAL(10,2) NOT NULL,
    Method         NVARCHAR(20)  NOT NULL
                   CONSTRAINT CK_Pay_Method 
                       CHECK (Method IN ('VNPay','MoMo','CASH','CREDIT_CARD','BANK_TRANSFER')),
    Status         NVARCHAR(20)  NOT NULL
                   CONSTRAINT CK_Pay_Status 
                       CHECK (Status IN ('PENDING','SUCCESS','FAILED')),
    TransactionId  NVARCHAR(100) NULL,
    PaymentType    NVARCHAR(20)  NOT NULL DEFAULT 'FULL_PAYMENT'
                   CONSTRAINT CK_Payments_PaymentType 
                       CHECK (PaymentType IN ('DEPOSIT', 'FULL_PAYMENT', 'REMAINING_BALANCE', 'REFUND')),
    CreatedAt      DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Pay_Res FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 11. HousekeepingTasks Table
CREATE TABLE dbo.HousekeepingTasks (
    Id           INT           IDENTITY(1,1) PRIMARY KEY,
    RoomId       INT           NOT NULL,
    AssignedTo   INT           NULL,
    Status       NVARCHAR(20)  NOT NULL
                 CONSTRAINT CK_Task_Status 
                     CHECK (Status IN ('PENDING','IN_PROGRESS','DONE')),
    Notes        NVARCHAR(MAX) NULL,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Task_Room FOREIGN KEY(RoomId)
        REFERENCES dbo.Rooms(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Task_User FOREIGN KEY(AssignedTo)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- Trigger to update UpdatedAt for HousekeepingTasks
CREATE TRIGGER TR_Housekeeping_Update
ON dbo.HousekeepingTasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET t.UpdatedAt = GETDATE()
    FROM dbo.HousekeepingTasks t
    JOIN inserted i ON t.Id = i.Id;
END;
GO

-- 12. Equipment & RoomEquipment Tables
CREATE TABLE dbo.Equipment (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.RoomEquipment (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    RoomId      INT           NOT NULL,
    EquipmentId INT           NOT NULL,
    Quantity    INT           NOT NULL DEFAULT(1),
    CONSTRAINT FK_REQ_Room FOREIGN KEY(RoomId)
        REFERENCES dbo.Rooms(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_REQ_Equip FOREIGN KEY(EquipmentId)
        REFERENCES dbo.Equipment(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 13. Services & ReservationServices Tables
CREATE TABLE dbo.Services (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Status      NVARCHAR(20) NOT NULL DEFAULT 'active',
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.ReservationServices (
    Id            INT           IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT           NOT NULL,
    ServiceId     INT           NOT NULL,
    Quantity      INT           NOT NULL DEFAULT(1),
    CONSTRAINT FK_RS_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_RS_Service FOREIGN KEY(ServiceId)
        REFERENCES dbo.Services(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 14. Room Amenities Tables
CREATE TABLE dbo.RoomAmenities (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RoomId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    UnitPrice DECIMAL(10,2) NOT NULL DEFAULT 0,
    IsChargeable BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_RoomAmenities_Room FOREIGN KEY(RoomId)
        REFERENCES dbo.Rooms(Id)
        ON DELETE CASCADE
);
GO

CREATE TABLE dbo.ReservationAmenityUsage (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    AmenityId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    CheckedBy INT NULL,
    CheckedAt DATETIME NULL,
    Notes NVARCHAR(500) NULL,
    CONSTRAINT FK_Usage_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id)
        ON DELETE CASCADE,
    CONSTRAINT FK_Usage_Amenity FOREIGN KEY(AmenityId)
        REFERENCES dbo.RoomAmenities(Id)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Usage_CheckedBy FOREIGN KEY(CheckedBy)
        REFERENCES dbo.Users(Id)
        ON DELETE NO ACTION
);
GO

-- 15. Room Inspection Tables
CREATE TABLE dbo.RoomInspections (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    InspectorId INT NOT NULL,
    InspectionTime DATETIME NOT NULL DEFAULT GETDATE(),
    RoomCondition NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Inspection_Condition 
            CHECK (RoomCondition IN ('EXCELLENT','GOOD','FAIR','POOR','DAMAGED')),
    CleanlinessScore INT NOT NULL
        CONSTRAINT CK_Inspection_Score
            CHECK (CleanlinessScore BETWEEN 1 AND 10),
    Notes NVARCHAR(MAX) NULL,
    PhotoUrls NVARCHAR(MAX) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CONSTRAINT CK_Inspection_Status
            CHECK (Status IN ('PENDING','APPROVED','REJECTED','COMPLETED')),
    ApprovedBy INT NULL,
    ApprovedAt DATETIME NULL,
    CONSTRAINT FK_Inspection_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id),
    CONSTRAINT FK_Inspection_Inspector FOREIGN KEY(InspectorId)
        REFERENCES dbo.Users(Id),
    CONSTRAINT FK_Inspection_ApprovedBy FOREIGN KEY(ApprovedBy)
        REFERENCES dbo.Users(Id)
);
GO

CREATE TABLE dbo.InspectionItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    InspectionId INT NOT NULL,
    ItemName NVARCHAR(100) NOT NULL,
    ItemCategory NVARCHAR(50) NOT NULL
        CONSTRAINT CK_Item_Category
            CHECK (ItemCategory IN ('MINIBAR','AMENITY','DAMAGE','SERVICE','OTHER')),
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice AS (Quantity * UnitPrice) PERSISTED,
    Notes NVARCHAR(500) NULL,
    CONSTRAINT FK_InspectionItem_Inspection FOREIGN KEY(InspectionId)
        REFERENCES dbo.RoomInspections(Id)
        ON DELETE CASCADE
);
GO

CREATE TABLE dbo.RoomDamages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    InspectionId INT NOT NULL,
    DamageType NVARCHAR(50) NOT NULL
        CONSTRAINT CK_Damage_Type
            CHECK (DamageType IN ('FURNITURE','ELECTRONICS','BATHROOM','WALLS','CARPET','LINEN','OTHER')),
    Description NVARCHAR(500) NOT NULL,
    EstimatedCost DECIMAL(10,2) NOT NULL,
    PhotoUrl NVARCHAR(500) NULL,
    Severity NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Damage_Severity
            CHECK (Severity IN ('MINOR','MODERATE','MAJOR','SEVERE')),
    CONSTRAINT FK_Damage_Inspection FOREIGN KEY(InspectionId)
        REFERENCES dbo.RoomInspections(Id)
        ON DELETE CASCADE
);
GO

-- 16. Check-in/Check-out Details Tables
CREATE TABLE dbo.CheckInDetails (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    IdType NVARCHAR(20) NOT NULL,
    IdNumber NVARCHAR(50) NOT NULL,
    AdditionalGuests INT NOT NULL DEFAULT 0,
    SpecialRequests NVARCHAR(500) NULL,
    SecurityDeposit DECIMAL(10,2) NOT NULL DEFAULT 0,
    KeyCards INT NOT NULL DEFAULT 2,
    KeyCardNumbers NVARCHAR(100) NULL,
    CheckInNotes NVARCHAR(500) NULL,
    CheckInTime DATETIME NOT NULL,
    CheckInBy INT NOT NULL,
    CONSTRAINT FK_CheckInDetails_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id),
    CONSTRAINT FK_CheckInDetails_User FOREIGN KEY(CheckInBy)
        REFERENCES dbo.Users(Id)
);
GO

CREATE TABLE dbo.CheckOutDetails (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    InspectionId INT NULL,
    RoomCondition NVARCHAR(20) NOT NULL,
    DamageDescription NVARCHAR(500) NULL,
    DamageCharges DECIMAL(10,2) NOT NULL DEFAULT 0,
    AmenityCharges DECIMAL(10,2) NOT NULL DEFAULT 0,
    ServiceCharges DECIMAL(10,2) NOT NULL DEFAULT 0,
    FinalAmount DECIMAL(10,2) NOT NULL,
    RefundAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    PaymentMethod NVARCHAR(20) NULL,
    CheckOutNotes NVARCHAR(500) NULL,
    CheckOutTime DATETIME NOT NULL,
    CheckOutBy INT NOT NULL,
    CONSTRAINT FK_CheckOutDetails_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id),
    CONSTRAINT FK_CheckOutDetails_User FOREIGN KEY(CheckOutBy)
        REFERENCES dbo.Users(Id),
    CONSTRAINT FK_CheckOut_Inspection FOREIGN KEY(InspectionId)
        REFERENCES dbo.RoomInspections(Id)
);
GO

CREATE TABLE dbo.AmenityInventory (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    AmenityId INT NOT NULL,
    InitialQuantity INT NOT NULL,
    Condition NVARCHAR(20) NOT NULL,
    Notes NVARCHAR(500) NULL,
    CheckedBy INT NOT NULL,
    CheckedAt DATETIME NOT NULL,
    CONSTRAINT FK_AmenityInventory_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id),
    CONSTRAINT FK_AmenityInventory_Amenity FOREIGN KEY(AmenityId)
        REFERENCES dbo.RoomAmenities(Id),
    CONSTRAINT FK_AmenityInventory_User FOREIGN KEY(CheckedBy)
        REFERENCES dbo.Users(Id)
);
GO

-- 17. Notifications Table
CREATE TABLE dbo.Notifications (
    Id             INT           IDENTITY(1,1) PRIMARY KEY,
    UserId         INT           NULL,
    ReservationId  INT           NULL,
    Type           NVARCHAR(50)  NOT NULL,
    Message        NVARCHAR(MAX) NOT NULL,
    SentAt         DATETIME      NULL,
    Status         NVARCHAR(20)  NOT NULL
                   CONSTRAINT CK_Notif_Status 
                     CHECK (Status IN ('SENT','FAILED')),
    CONSTRAINT FK_Notif_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Notif_Res FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 18. OTASync Table
CREATE TABLE dbo.OTASync (
    Id           INT           IDENTITY(1,1) PRIMARY KEY,
    Provider     NVARCHAR(50)  NOT NULL,
    RoomId       INT           NOT NULL,
    Action       NVARCHAR(30)  NOT NULL
                 CONSTRAINT CK_OTA_Action 
                     CHECK (Action IN ('PRICE_UPDATE','AVAILABILITY_UPDATE')),
    Payload      NVARCHAR(MAX) NULL
                 CONSTRAINT CK_OTA_Payload_JSON 
                     CHECK (ISJSON(Payload)=1),
    SyncedAt     DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_OTA_Room FOREIGN KEY(RoomId)
        REFERENCES dbo.Rooms(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 19. Feedback Table
CREATE TABLE dbo.Feedback (
    Id             INT           IDENTITY(1,1) PRIMARY KEY,
    ReservationId  INT           NOT NULL,
    UserId         INT           NOT NULL,
    Rating         TINYINT       NOT NULL 
                   CONSTRAINT CK_Feedback_Rating 
                     CHECK (Rating BETWEEN 1 AND 5),
    Comment        NVARCHAR(1000) NULL,
    CreatedAt      DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Feedback_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Feedback_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- 20. Blogs Table
CREATE TABLE dbo.Blogs (
    Id           INT           IDENTITY(1,1) PRIMARY KEY,
    Title        NVARCHAR(200) NOT NULL,
    Slug         NVARCHAR(200) NOT NULL UNIQUE,
    Content      NVARCHAR(MAX) NOT NULL,
    AuthorId     INT           NOT NULL,
    Status       NVARCHAR(20)  NOT NULL
                 CONSTRAINT CK_Blogs_Status
                     CHECK (Status IN ('DRAFT','PUBLISHED','ARCHIVED')),
    ImageUrl     NVARCHAR(500) NULL,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Blogs_Author
        FOREIGN KEY (AuthorId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- Trigger to update UpdatedAt for Blogs
CREATE TRIGGER TR_Blogs_Update
ON dbo.Blogs
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b
    SET b.UpdatedAt = GETDATE()
    FROM dbo.Blogs b
    JOIN inserted i ON b.Id = i.Id;
END;
GO

CREATE TABLE ContactMessages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 21. Events Table
CREATE TABLE dbo.Events (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Location    NVARCHAR(200) NULL,
    StartAt     DATETIME      NOT NULL,
    EndAt       DATETIME      NOT NULL,
    Status      NVARCHAR(20)  NOT NULL
                CONSTRAINT CK_Events_Status 
                    CHECK (Status IN ('SCHEDULED','ONGOING','COMPLETED','CANCELLED')),
    ImageUrl    NVARCHAR(500) NULL,
    CreatedBy   INT           NULL,
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_User 
        FOREIGN KEY (CreatedBy) 
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION 
        ON DELETE NO ACTION
);
GO

-- Trigger to update UpdatedAt for Events
CREATE TRIGGER TR_Events_Update
ON dbo.Events
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE e
    SET e.UpdatedAt = GETDATE()
    FROM dbo.Events e
    JOIN inserted i ON e.Id = i.Id;
END;
GO

-- 22. Comments Table
CREATE TABLE dbo.Comments (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    BlogId      INT           NOT NULL,
    AuthorName  NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(100) NOT NULL,
    Content     NVARCHAR(1000) NOT NULL,
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                CONSTRAINT CK_Comments_Status 
                    CHECK (Status IN ('PENDING','APPROVED','REJECTED')),
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Comments_Blog 
        FOREIGN KEY (BlogId) 
        REFERENCES dbo.Blogs(Id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);
GO

-- 23. Activities Table
CREATE TABLE dbo.Activities (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(50) NOT NULL,
    ReservationId INT NULL,
    UserId INT NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    Amount DECIMAL(10,2) NULL,
    Timestamp DATETIME NOT NULL,
    IpAddress NVARCHAR(50) NULL,
    CONSTRAINT FK_Activities_Reservation FOREIGN KEY(ReservationId)
        REFERENCES dbo.Reservations(Id),
    CONSTRAINT FK_Activities_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
);
GO
CREATE TABLE PasswordResetTokens (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Token NVARCHAR(100) NOT NULL UNIQUE,
    Expiry DATETIME NOT NULL
);
--------------------------------------------------------------------------------
-- PART 2: EMAIL VERIFICATION SYSTEM TABLES
--------------------------------------------------------------------------------

-- 24. Pending Changes Table - Store temporary changes awaiting approval
CREATE TABLE dbo.PendingChanges (
    Id              INT           IDENTITY(1,1) PRIMARY KEY,
    UserId          INT           NOT NULL,
    InitiatedBy     INT           NOT NULL,
    ChangeType      NVARCHAR(20)  NOT NULL 
                    CONSTRAINT CK_PendingChanges_Type 
                        CHECK (ChangeType IN ('EMAIL','PHONE','PASSWORD','PROFILE')),
    OriginalEmail   NVARCHAR(100) NULL,
    OriginalPhone   NVARCHAR(20)  NULL,
    NewEmail        NVARCHAR(100) NULL,
    NewPhone        NVARCHAR(20)  NULL,
    NewPasswordHash NVARCHAR(255) NULL,
    ChangeReason    NVARCHAR(500) NULL,
    ChangeDetails   NVARCHAR(MAX) NULL,
    VerificationToken    NVARCHAR(255) NOT NULL UNIQUE,
    TokenExpiry         DATETIME      NOT NULL,
    Status              NVARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                        CONSTRAINT CK_PendingChanges_Status 
                            CHECK (Status IN ('PENDING','APPROVED','REJECTED','EXPIRED')),
    NotificationSent    BIT          NOT NULL DEFAULT 0,
    ReminderSent        BIT          NOT NULL DEFAULT 0,
    ReminderCount       INT          NOT NULL DEFAULT 0,
    ApprovedAt          DATETIME     NULL,
    ApprovedByEmail     BIT          NOT NULL DEFAULT 0,
    RejectedAt          DATETIME     NULL,
    RejectionReason     NVARCHAR(500) NULL,
    CreatedAt           DATETIME     NOT NULL DEFAULT GETDATE(),
    UpdatedAt           DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_PendingChanges_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_PendingChanges_InitiatedBy FOREIGN KEY(InitiatedBy)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- Create indexes for PendingChanges
CREATE INDEX IX_PendingChanges_UserId ON dbo.PendingChanges(UserId);
CREATE INDEX IX_PendingChanges_Token ON dbo.PendingChanges(VerificationToken);
CREATE INDEX IX_PendingChanges_Status ON dbo.PendingChanges(Status);
CREATE INDEX IX_PendingChanges_Created ON dbo.PendingChanges(CreatedAt);
GO

-- 25. Notification History Table
CREATE TABLE dbo.NotificationHistory (
    Id              INT           IDENTITY(1,1) PRIMARY KEY,
    UserId          INT           NOT NULL,
    PendingChangeId INT           NULL,
    NotificationType NVARCHAR(30) NOT NULL
                    CONSTRAINT CK_NotificationHistory_Type 
                        CHECK (NotificationType IN ('CHANGE_REQUEST','REMINDER','APPROVED','REJECTED','EXPIRED')),
    Channel         NVARCHAR(20)  NOT NULL
                    CONSTRAINT CK_NotificationHistory_Channel 
                        CHECK (Channel IN ('EMAIL','SMS','IN_APP')),
    Recipient       NVARCHAR(100) NOT NULL,
    Subject         NVARCHAR(200) NULL,
    Message         NVARCHAR(MAX) NOT NULL,
    Status          NVARCHAR(20)  NOT NULL
                    CONSTRAINT CK_NotificationHistory_Status 
                        CHECK (Status IN ('SENT','FAILED','BOUNCED')),
    SentAt          DATETIME      NOT NULL DEFAULT GETDATE(),
    ErrorMessage    NVARCHAR(500) NULL,
    CONSTRAINT FK_NotificationHistory_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_NotificationHistory_PendingChange FOREIGN KEY(PendingChangeId)
        REFERENCES dbo.PendingChanges(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 26. Security Audit Log Table
CREATE TABLE dbo.SecurityAuditLog (
    Id              INT           IDENTITY(1,1) PRIMARY KEY,
    UserId          INT           NOT NULL,
    ActionBy        INT           NOT NULL,
    Action          NVARCHAR(50)  NOT NULL,
    EntityType      NVARCHAR(30)  NOT NULL,
    EntityId        INT           NOT NULL,
    FieldChanged    NVARCHAR(50)  NULL,
    OldValue        NVARCHAR(500) NULL,
    NewValue        NVARCHAR(500) NULL,
    ChangeReason    NVARCHAR(500) NULL,
    IpAddress       NVARCHAR(50)  NULL,
    UserAgent       NVARCHAR(500) NULL,
    SessionId       NVARCHAR(100) NULL,
    RiskLevel       NVARCHAR(20)  NOT NULL DEFAULT 'LOW'
                    CONSTRAINT CK_SecurityAuditLog_Risk 
                        CHECK (RiskLevel IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    RequiredApproval BIT          NOT NULL DEFAULT 0,
    ApprovalStatus  NVARCHAR(20)  NULL
                    CONSTRAINT CK_SecurityAuditLog_Approval 
                        CHECK (ApprovalStatus IN ('PENDING','APPROVED','REJECTED')),
    Timestamp       DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_SecurityAuditLog_User FOREIGN KEY(UserId)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_SecurityAuditLog_ActionBy FOREIGN KEY(ActionBy)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- Create indexes for SecurityAuditLog
CREATE INDEX IX_SecurityAuditLog_UserId ON dbo.SecurityAuditLog(UserId);
CREATE INDEX IX_SecurityAuditLog_ActionBy ON dbo.SecurityAuditLog(ActionBy);
CREATE INDEX IX_SecurityAuditLog_Timestamp ON dbo.SecurityAuditLog(Timestamp DESC);
CREATE INDEX IX_SecurityAuditLog_EntityType ON dbo.SecurityAuditLog(EntityType);
CREATE INDEX IX_SecurityAuditLog_RiskLevel ON dbo.SecurityAuditLog(RiskLevel);
GO

-- 27. Email Templates Table
CREATE TABLE dbo.EmailTemplates (
    Id              INT           IDENTITY(1,1) PRIMARY KEY,
    TemplateName    NVARCHAR(50)  NOT NULL UNIQUE,
    TemplateType    NVARCHAR(30)  NOT NULL
                    CONSTRAINT CK_EmailTemplates_Type 
                        CHECK (TemplateType IN ('CHANGE_REQUEST','REMINDER','APPROVED','REJECTED','EXPIRED')),
    Subject         NVARCHAR(200) NOT NULL,
    HtmlBody        NVARCHAR(MAX) NOT NULL,
    TextBody        NVARCHAR(MAX) NULL,
    Language        NVARCHAR(10)  NOT NULL DEFAULT 'en',
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME      NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT           NULL,
    CONSTRAINT FK_EmailTemplates_CreatedBy FOREIGN KEY(CreatedBy)
        REFERENCES dbo.Users(Id)
        ON UPDATE NO ACTION
        ON DELETE SET NULL
);
GO

--------------------------------------------------------------------------------
-- CREATE INDEXES FOR HOTEL MANAGEMENT SYSTEM
--------------------------------------------------------------------------------
CREATE INDEX IX_Users_Role ON dbo.Users(Role);
CREATE INDEX IX_CustomerDetails_UserId ON dbo.CustomerDetails(UserId);
CREATE INDEX IX_EmployeeDetails_UserId ON dbo.EmployeeDetails(UserId);
CREATE INDEX IX_Reservations_CheckIn ON dbo.Reservations(CheckIn);
CREATE INDEX IX_Reservations_CheckOut ON dbo.Reservations(CheckOut);
CREATE INDEX IX_Reservations_UserId ON dbo.Reservations(UserId);
CREATE INDEX IX_Reservations_RoomTypeId ON dbo.Reservations(RoomTypeId);
CREATE INDEX IX_HousekeepingTasks_AssignedTo ON dbo.HousekeepingTasks(AssignedTo);
CREATE INDEX IX_Activities_Timestamp ON dbo.Activities(Timestamp DESC);

-- Indexes for deposit system
CREATE INDEX IX_Payments_PaymentType ON dbo.Payments(PaymentType);
CREATE INDEX IX_Reservations_DepositStatus ON dbo.Reservations(DepositStatus);
GO

--------------------------------------------------------------------------------
-- STORED PROCEDURES
--------------------------------------------------------------------------------

-- Hotel Management Procedures
-- Procedure to create a new customer
CREATE PROCEDURE sp_CreateCustomer
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(255),
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @IdType NVARCHAR(20) = NULL,
    @IdNumber NVARCHAR(50) = NULL,
    @DateOfBirth DATE = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Country NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @UserId INT;
    
    INSERT INTO dbo.Users (Username, PasswordHash, FullName, Email, Phone, Role)
    VALUES (@Username, @PasswordHash, @FullName, @Email, @Phone, 'CUSTOMER');
    
    SET @UserId = SCOPE_IDENTITY();
    
    INSERT INTO dbo.CustomerDetails (UserId, IdType, IdNumber, DateOfBirth, Gender, Address, City, Country)
    VALUES (@UserId, @IdType, @IdNumber, @DateOfBirth, @Gender, @Address, @City, @Country);
    
    COMMIT TRANSACTION;
    
    SELECT @UserId AS NewUserId;
END;
GO

-- Enhanced procedure to create a new employee with additional details
CREATE PROCEDURE sp_CreateEmployee
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(255),
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Role NVARCHAR(20),
    @Department NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    -- New parameters
    @DateOfBirth DATE = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Country NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @UserId INT;
    
    -- Check age (must be >= 18 years old)
    IF @DateOfBirth IS NOT NULL
    BEGIN
        DECLARE @Age INT = DATEDIFF(YEAR, @DateOfBirth, GETDATE());
        IF @DateOfBirth > DATEADD(YEAR, -DATEDIFF(YEAR, @DateOfBirth, GETDATE()), GETDATE())
            SET @Age = @Age - 1;
            
        IF @Age < 18
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Employee must be at least 18 years old', 16, 1);
            RETURN;
        END
    END
    
    INSERT INTO dbo.Users (Username, PasswordHash, FullName, Email, Phone, Role)
    VALUES (@Username, @PasswordHash, @FullName, @Email, @Phone, @Role);
    
    SET @UserId = SCOPE_IDENTITY();
    
    INSERT INTO dbo.EmployeeDetails (UserId, Department, HireDate, Salary, 
                                    DateOfBirth, Gender, Address, City, Country)
    VALUES (@UserId, @Department, @HireDate, @Salary,
            @DateOfBirth, @Gender, @Address, @City, @Country);
    
    COMMIT TRANSACTION;
    
    SELECT @UserId AS NewUserId;
END;
GO

-- New procedure to update employee details
CREATE OR ALTER PROCEDURE sp_UpdateEmployeeDetails
    @UserId INT,
    @Department NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    @DateOfBirth DATE = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Country NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check age if updating date of birth
    IF @DateOfBirth IS NOT NULL
    BEGIN
        DECLARE @Age INT = DATEDIFF(YEAR, @DateOfBirth, GETDATE());
        IF @DateOfBirth > DATEADD(YEAR, -DATEDIFF(YEAR, @DateOfBirth, GETDATE()), GETDATE())
            SET @Age = @Age - 1;
            
        IF @Age < 18
        BEGIN
            RAISERROR('Employee must be at least 18 years old', 16, 1);
            RETURN;
        END
    END
    
    UPDATE dbo.EmployeeDetails
    SET Department = ISNULL(@Department, Department),
        HireDate = ISNULL(@HireDate, HireDate),
        Salary = ISNULL(@Salary, Salary),
        DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth),
        Gender = ISNULL(@Gender, Gender),
        Address = ISNULL(@Address, Address),
        City = ISNULL(@City, City),
        Country = ISNULL(@Country, Country),
        UpdatedAt = GETDATE()
    WHERE UserId = @UserId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- Procedure to check room availability by room type
CREATE PROCEDURE sp_CheckRoomAvailability
    @RoomTypeId INT,
    @CheckIn DATE,
    @CheckOut DATE,
    @ExcludeReservationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT r.Id, r.RoomNumber, r.Status
    FROM dbo.Rooms r
    WHERE r.RoomTypeId = @RoomTypeId
        AND r.Status = 'AVAILABLE'
        AND r.Id NOT IN (
            SELECT res.RoomId 
            FROM dbo.Reservations res 
            WHERE res.RoomId IS NOT NULL
                AND res.Status IN ('CONFIRMED', 'PENDING')
                AND NOT (res.CheckOut <= @CheckIn OR res.CheckIn >= @CheckOut)
                AND (@ExcludeReservationId IS NULL OR res.Id != @ExcludeReservationId)
        );
END;
GO

-- Procedure to start room inspection
CREATE PROCEDURE sp_StartRoomInspection
    @ReservationId INT,
    @InspectorId INT,
    @RoomCondition NVARCHAR(20),
    @CleanlinessScore INT,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM dbo.RoomInspections WHERE ReservationId = @ReservationId)
    BEGIN
        RAISERROR('Inspection already exists for this reservation', 16, 1);
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @InspectorId AND Role = 'ROOM_INSPECTOR')
    BEGIN
        RAISERROR('User is not authorized as room inspector', 16, 1);
        RETURN;
    END
    
    INSERT INTO dbo.RoomInspections (ReservationId, InspectorId, RoomCondition, CleanlinessScore, Notes)
    VALUES (@ReservationId, @InspectorId, @RoomCondition, @CleanlinessScore, @Notes);
    
    SELECT SCOPE_IDENTITY() AS InspectionId;
END;
GO

-- Procedure to add used items during inspection
CREATE PROCEDURE sp_AddInspectionItem
    @InspectionId INT,
    @ItemName NVARCHAR(100),
    @ItemCategory NVARCHAR(50),
    @Quantity INT,
    @UnitPrice DECIMAL(10,2),
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.InspectionItems (InspectionId, ItemName, ItemCategory, Quantity, UnitPrice, Notes)
    VALUES (@InspectionId, @ItemName, @ItemCategory, @Quantity, @UnitPrice, @Notes);
    
    SELECT SCOPE_IDENTITY() AS ItemId;
END;
GO

-- Procedure to record damage
CREATE PROCEDURE sp_AddRoomDamage
    @InspectionId INT,
    @DamageType NVARCHAR(50),
    @Description NVARCHAR(500),
    @EstimatedCost DECIMAL(10,2),
    @Severity NVARCHAR(20),
    @PhotoUrl NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.RoomDamages (InspectionId, DamageType, Description, EstimatedCost, Severity, PhotoUrl)
    VALUES (@InspectionId, @DamageType, @Description, @EstimatedCost, @Severity, @PhotoUrl);
    
    SELECT SCOPE_IDENTITY() AS DamageId;
END;
GO

-- Procedure to complete inspection and generate charges
CREATE PROCEDURE sp_CompleteInspection
    @InspectionId INT,
    @ApprovedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    UPDATE dbo.RoomInspections 
    SET Status = 'COMPLETED', 
        ApprovedBy = @ApprovedBy, 
        ApprovedAt = GETDATE()
    WHERE Id = @InspectionId;
    
    DECLARE @ItemCharges DECIMAL(10,2) = 0;
    DECLARE @DamageCharges DECIMAL(10,2) = 0;
    
    SELECT @ItemCharges = ISNULL(SUM(TotalPrice), 0)
    FROM dbo.InspectionItems
    WHERE InspectionId = @InspectionId;
    
    SELECT @DamageCharges = ISNULL(SUM(EstimatedCost), 0)
    FROM dbo.RoomDamages
    WHERE InspectionId = @InspectionId;
    
    SELECT 
        @InspectionId AS InspectionId,
        @ItemCharges AS ItemCharges,
        @DamageCharges AS DamageCharges,
        @ItemCharges + @DamageCharges AS TotalAdditionalCharges;
    
    COMMIT TRANSACTION;
END;
GO

-- Deposit System Procedures
-- Procedure to process deposit payment
CREATE PROCEDURE sp_ProcessDepositPayment
    @ReservationId INT,
    @DepositAmount DECIMAL(10,2),
    @PaymentMethod NVARCHAR(20),
    @TransactionId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Update reservation with deposit information
        UPDATE dbo.Reservations
        SET DepositAmount = @DepositAmount,
            DepositPaidDate = GETDATE(),
            DepositStatus = 'PAID'
        WHERE Id = @ReservationId;
        
        -- Create payment record for deposit
        INSERT INTO dbo.Payments (ReservationId, Amount, Method, Status, 
                                  TransactionId, PaymentType, CreatedAt)
        VALUES (@ReservationId, @DepositAmount, @PaymentMethod, 'SUCCESS',
                @TransactionId, 'DEPOSIT', GETDATE());
        
        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Deposit payment processed successfully' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END;
GO

-- Procedure to handle deposit refund
CREATE PROCEDURE sp_RefundDeposit
    @ReservationId INT,
    @RefundMethod NVARCHAR(20),
    @RefundedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @DepositAmount DECIMAL(10,2);
        
        -- Get deposit amount
        SELECT @DepositAmount = DepositAmount
        FROM dbo.Reservations
        WHERE Id = @ReservationId AND DepositStatus = 'PAID';
        
        IF @DepositAmount IS NULL OR @DepositAmount = 0
        BEGIN
            RAISERROR('No deposit found for this reservation', 16, 1);
            RETURN;
        END
        
        -- Update reservation deposit status
        UPDATE dbo.Reservations
        SET DepositStatus = 'REFUNDED'
        WHERE Id = @ReservationId;
        
        -- Create refund payment record
        INSERT INTO dbo.Payments (ReservationId, Amount, Method, Status, 
                                  TransactionId, PaymentType, CreatedAt)
        VALUES (@ReservationId, @DepositAmount, @RefundMethod, 'SUCCESS',
                'REFUND-' + CAST(@ReservationId AS NVARCHAR) + '-' + 
                CONVERT(NVARCHAR(30), GETDATE(), 120), 'REFUND', GETDATE());
        
        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Deposit refunded successfully' AS Message, @DepositAmount AS RefundAmount;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message, 0 AS RefundAmount;
    END CATCH
END;
GO

-- Email Verification Procedures
-- Procedure to initiate a change request
CREATE PROCEDURE sp_InitiateChangeRequest
    @UserId INT,
    @InitiatedBy INT,
    @ChangeType NVARCHAR(20),
    @NewEmail NVARCHAR(100) = NULL,
    @NewPhone NVARCHAR(20) = NULL,
    @NewPasswordHash NVARCHAR(255) = NULL,
    @ChangeReason NVARCHAR(500) = NULL,
    @ExpiryHours INT = 48
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @Token NVARCHAR(255) = CAST(NEWID() AS NVARCHAR(36)) + '-' + CAST(GETDATE() AS NVARCHAR(50));
    DECLARE @Expiry DATETIME = DATEADD(HOUR, @ExpiryHours, GETDATE());
    DECLARE @OriginalEmail NVARCHAR(100);
    DECLARE @OriginalPhone NVARCHAR(20);
    
    SELECT @OriginalEmail = Email, @OriginalPhone = Phone 
    FROM dbo.Users WHERE Id = @UserId;
    
    INSERT INTO dbo.PendingChanges (
        UserId, InitiatedBy, ChangeType, OriginalEmail, OriginalPhone,
        NewEmail, NewPhone, NewPasswordHash, ChangeReason,
        VerificationToken, TokenExpiry
    ) VALUES (
        @UserId, @InitiatedBy, @ChangeType, @OriginalEmail, @OriginalPhone,
        @NewEmail, @NewPhone, @NewPasswordHash, @ChangeReason,
        @Token, @Expiry
    );
    
    DECLARE @PendingId INT = SCOPE_IDENTITY();
    
    INSERT INTO dbo.SecurityAuditLog (
        UserId, ActionBy, Action, EntityType, EntityId,
        FieldChanged, OldValue, NewValue, ChangeReason,
        RiskLevel, RequiredApproval, ApprovalStatus
    ) VALUES (
        @UserId, @InitiatedBy, 'CHANGE_REQUEST_INITIATED', 'USER', @UserId,
        @ChangeType, 
        CASE @ChangeType 
            WHEN 'EMAIL' THEN @OriginalEmail
            WHEN 'PHONE' THEN @OriginalPhone
            ELSE 'SENSITIVE_DATA'
        END,
        CASE @ChangeType 
            WHEN 'EMAIL' THEN @NewEmail
            WHEN 'PHONE' THEN @NewPhone
            ELSE 'MASKED'
        END,
        @ChangeReason,
        'HIGH', 1, 'PENDING'
    );
    
    COMMIT TRANSACTION;
    
    SELECT @PendingId AS PendingChangeId, @Token AS VerificationToken;
END;
GO

-- Procedure to approve a change request
CREATE PROCEDURE sp_ApproveChangeRequest
    @Token NVARCHAR(255),
    @ApprovedBy NVARCHAR(100) = 'EMAIL_VERIFICATION'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @PendingId INT, @UserId INT, @ChangeType NVARCHAR(20);
    DECLARE @NewEmail NVARCHAR(100), @NewPhone NVARCHAR(20), @NewPasswordHash NVARCHAR(255);
    
    SELECT @PendingId = Id, @UserId = UserId, @ChangeType = ChangeType,
           @NewEmail = NewEmail, @NewPhone = NewPhone, @NewPasswordHash = NewPasswordHash
    FROM dbo.PendingChanges 
    WHERE VerificationToken = @Token 
      AND Status = 'PENDING' 
      AND TokenExpiry > GETDATE();
    
    IF @PendingId IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Invalid or expired verification token', 16, 1);
        RETURN;
    END
    
    IF @ChangeType = 'EMAIL'
        UPDATE dbo.Users SET Email = @NewEmail WHERE Id = @UserId;
    ELSE IF @ChangeType = 'PHONE'
        UPDATE dbo.Users SET Phone = @NewPhone WHERE Id = @UserId;
    ELSE IF @ChangeType = 'PASSWORD'
        UPDATE dbo.Users SET PasswordHash = @NewPasswordHash WHERE Id = @UserId;
    
    UPDATE dbo.PendingChanges 
    SET Status = 'APPROVED', ApprovedAt = GETDATE(), ApprovedByEmail = 1
    WHERE Id = @PendingId;
    
    INSERT INTO dbo.SecurityAuditLog (
        UserId, ActionBy, Action, EntityType, EntityId,
        FieldChanged, NewValue, RiskLevel
    ) VALUES (
        @UserId, @UserId, 'CHANGE_REQUEST_APPROVED', 'USER', @UserId,
        @ChangeType, 
        CASE @ChangeType 
            WHEN 'EMAIL' THEN @NewEmail
            WHEN 'PHONE' THEN @NewPhone
            ELSE 'MASKED'
        END,
        'HIGH'
    );
    
    COMMIT TRANSACTION;
    
    SELECT 'SUCCESS' AS Result, @UserId AS UserId, @ChangeType AS ChangeType;
END;
GO

-- Procedure to clean up expired tokens
CREATE PROCEDURE sp_CleanupExpiredTokens
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.PendingChanges 
    SET Status = 'EXPIRED' 
    WHERE Status = 'PENDING' AND TokenExpiry < GETDATE();
    
    SELECT @@ROWCOUNT AS ExpiredTokens;
END;
GO

--------------------------------------------------------------------------------
-- CREATE VIEWS
--------------------------------------------------------------------------------

-- Hotel Management Views
-- View for complete customer information
CREATE VIEW vw_Customers AS
SELECT 
    u.Id,
    u.Username,
    u.PasswordHash,
    u.FullName,
    u.Email,
    u.Phone,
    cd.IdType,
    cd.IdNumber,
    cd.DateOfBirth,
    cd.Gender,
    cd.Address,
    cd.City,
    cd.Country,
    cd.LoyaltyPoints,
    cd.MembershipLevel,
    cd.IsVIP,
    u.Status,
    u.CreatedAt,
    u.UpdatedAt
FROM dbo.Users u
INNER JOIN dbo.CustomerDetails cd ON u.Id = cd.UserId
WHERE u.Role = 'CUSTOMER';
GO

-- Enhanced view for complete employee information
CREATE VIEW vw_Employees AS
SELECT 
    u.Id,
    u.Username,
    u.PasswordHash,
    u.FullName,
    u.Email,
    u.Phone,
    u.Role,
    ed.Department,
    ed.HireDate,
    ed.Salary,
    ed.DateOfBirth,
    ed.Gender,
    ed.Address,
    ed.City,
    ed.Country,
    u.Status,
    u.CreatedAt,
    u.UpdatedAt
FROM dbo.Users u
INNER JOIN dbo.EmployeeDetails ed ON u.Id = ed.UserId
WHERE u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR');
GO

-- New detailed employee view
CREATE OR ALTER VIEW vw_EmployeeDetails AS
SELECT 
    u.Id,
    u.Username,
    u.FullName,
    u.Email,
    u.Phone,
    u.Role,
    CASE u.Role
        WHEN 'ADMIN' THEN 'Administrator'
        WHEN 'RECEPTIONIST' THEN 'Receptionist'
        WHEN 'HOUSEKEEPER' THEN 'Housekeeper'
        WHEN 'ROOM_INSPECTOR' THEN 'Room Inspector'
    END AS RoleDisplayName,
    ed.Department,
    ed.HireDate,
    ed.DateOfBirth,
    DATEDIFF(YEAR, ed.DateOfBirth, GETDATE()) - 
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, ed.DateOfBirth, GETDATE()), ed.DateOfBirth) > GETDATE() 
            THEN 1 
            ELSE 0 
        END AS Age,
    ed.Gender,
    ed.Address,
    ed.City,
    ed.Country,
    ed.Address + ', ' + ed.City + ', ' + ed.Country AS FullAddress,
    ed.Salary,
    DATEDIFF(YEAR, ed.HireDate, GETDATE()) AS YearsOfService,
    u.Status,
    u.CreatedAt,
    u.UpdatedAt
FROM dbo.Users u
INNER JOIN dbo.EmployeeDetails ed ON u.Id = ed.UserId
WHERE u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR')
AND u.Status = 1;
GO

-- View for pending inspections
CREATE VIEW vw_PendingInspections AS
SELECT 
    r.Id AS ReservationId,
    rm.RoomNumber,
    u.FullName AS GuestName,
    r.CheckOut AS ScheduledCheckOut,
    CASE 
        WHEN ri.Id IS NULL THEN 'Not Inspected'
        ELSE ri.Status
    END AS InspectionStatus
FROM dbo.Reservations r
INNER JOIN dbo.Users u ON r.UserId = u.Id
LEFT JOIN dbo.Rooms rm ON r.RoomId = rm.Id
LEFT JOIN dbo.RoomInspections ri ON r.Id = ri.ReservationId
WHERE r.Status = 'CONFIRMED' 
    AND r.CheckOut <= DATEADD(day, 1, GETDATE())
    AND (ri.Id IS NULL OR ri.Status != 'COMPLETED');
GO

-- View for inspection summary with charges
CREATE VIEW vw_InspectionCharges AS
SELECT 
    ri.Id AS InspectionId,
    ri.ReservationId,
    rm.RoomNumber,
    u.FullName AS GuestName,
    inspector.FullName AS InspectorName,
    ri.InspectionTime,
    ri.RoomCondition,
    ISNULL(items.TotalItemCharges, 0) AS ItemCharges,
    ISNULL(damages.TotalDamageCharges, 0) AS DamageCharges,
    ISNULL(items.TotalItemCharges, 0) + ISNULL(damages.TotalDamageCharges, 0) AS TotalAdditionalCharges
FROM dbo.RoomInspections ri
INNER JOIN dbo.Reservations r ON ri.ReservationId = r.Id
LEFT JOIN dbo.Rooms rm ON r.RoomId = rm.Id
INNER JOIN dbo.Users u ON r.UserId = u.Id
INNER JOIN dbo.Users inspector ON ri.InspectorId = inspector.Id
LEFT JOIN (
    SELECT InspectionId, SUM(TotalPrice) AS TotalItemCharges
    FROM dbo.InspectionItems
    GROUP BY InspectionId
) items ON ri.Id = items.InspectionId
LEFT JOIN (
    SELECT InspectionId, SUM(EstimatedCost) AS TotalDamageCharges
    FROM dbo.RoomDamages
    GROUP BY InspectionId
) damages ON ri.Id = damages.InspectionId;
GO

-- View for active reservations
CREATE VIEW vw_ActiveReservations AS
SELECT 
    r.Id,
    u.FullName AS CustomerName,
    u.Email AS CustomerEmail,
    u.Phone AS CustomerPhone,
    rm.RoomNumber,
    rt.Name AS RoomType,
    r.CheckIn,
    r.CheckOut,
    r.Status,
    r.TotalAmount,
    r.NumberOfCustomers,
    r.SpecialRequests,
    e.FullName AS CreatedByEmployee,
    CASE 
        WHEN r.RoomId IS NULL THEN 'Room Type Booking - Not Assigned'
        ELSE 'Room Assigned'
    END AS RoomAssignmentStatus,
    -- Deposit information
    r.DepositAmount,
    r.DepositPaidDate,
    r.DepositStatus,
    ISNULL(r.TotalAmount, 0) - ISNULL(r.DepositAmount, 0) AS RemainingBalance
FROM dbo.Reservations r
INNER JOIN dbo.Users u ON r.UserId = u.Id
LEFT JOIN dbo.Rooms rm ON r.RoomId = rm.Id
LEFT JOIN dbo.RoomTypes rt ON COALESCE(rm.RoomTypeId, r.RoomTypeId) = rt.Id
LEFT JOIN dbo.Users e ON r.CreatedBy = e.Id
WHERE r.Status IN ('PENDING', 'CONFIRMED');
GO

-- View for room status
CREATE VIEW vw_RoomStatus AS
SELECT 
    r.Id,
    r.RoomNumber,
    rt.Name AS RoomType,
    r.Status,
    CASE 
        WHEN res.Id IS NOT NULL THEN res.CheckOut
        ELSE NULL
    END AS ExpectedAvailableDate,
    res.Id AS CurrentReservationId,
    guest.FullName AS CurrentGuestName
FROM dbo.Rooms r
INNER JOIN dbo.RoomTypes rt ON r.RoomTypeId = rt.Id
LEFT JOIN dbo.Reservations res ON r.Id = res.RoomId 
    AND res.Status = 'CONFIRMED' 
    AND res.CheckIn <= GETDATE() 
    AND res.CheckOut >= GETDATE()
LEFT JOIN dbo.Users guest ON res.UserId = guest.Id;
GO

-- View for room type availability
CREATE VIEW vw_RoomTypeAvailability AS
SELECT 
    rt.Id AS RoomTypeId,
    rt.Name AS RoomTypeName,
    rt.BasePrice,
    COUNT(r.Id) AS TotalRooms,
    COUNT(CASE WHEN r.Status = 'AVAILABLE' THEN 1 END) AS AvailableRooms,
    COUNT(CASE WHEN r.Status = 'OCCUPIED' THEN 1 END) AS OccupiedRooms,
    COUNT(CASE WHEN r.Status = 'MAINTENANCE' THEN 1 END) AS MaintenanceRooms,
    COUNT(CASE WHEN r.Status = 'DIRTY' THEN 1 END) AS DirtyRooms
FROM dbo.RoomTypes rt
LEFT JOIN dbo.Rooms r ON rt.Id = r.RoomTypeId
WHERE rt.Status = 'active'
GROUP BY rt.Id, rt.Name, rt.BasePrice;
GO

-- View for daily inspection report
CREATE VIEW vw_DailyInspectionReport AS
SELECT 
    CAST(ri.InspectionTime AS DATE) AS InspectionDate,
    COUNT(DISTINCT ri.Id) AS TotalInspections,
    COUNT(DISTINCT CASE WHEN ri.RoomCondition IN ('EXCELLENT', 'GOOD') THEN ri.Id END) AS GoodConditionRooms,
    COUNT(DISTINCT CASE WHEN ri.RoomCondition IN ('FAIR', 'POOR', 'DAMAGED') THEN ri.Id END) AS ProblematicRooms,
    COUNT(DISTINCT rd.Id) AS TotalDamagesFound,
    ISNULL(SUM(ii.TotalPrice), 0) AS TotalMinibarRevenue,
    ISNULL(SUM(rd.EstimatedCost), 0) AS TotalDamageCosts,
    ISNULL(AVG(ri.CleanlinessScore), 0) AS AvgCleanlinessScore
FROM dbo.RoomInspections ri
LEFT JOIN dbo.InspectionItems ii ON ri.Id = ii.InspectionId AND ii.ItemCategory = 'MINIBAR'
LEFT JOIN dbo.RoomDamages rd ON ri.Id = rd.InspectionId
WHERE ri.Status = 'COMPLETED'
GROUP BY CAST(ri.InspectionTime AS DATE);
GO

-- View for minibar consumption report
CREATE VIEW vw_MinibarConsumptionReport AS
SELECT 
    ii.ItemName,
    COUNT(*) AS TimesConsumed,
    SUM(ii.Quantity) AS TotalQuantity,
    AVG(ii.UnitPrice) AS AvgPrice,
    SUM(ii.TotalPrice) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(ii.TotalPrice) DESC) AS RevenueRank
FROM dbo.InspectionItems ii
WHERE ii.ItemCategory = 'MINIBAR'
GROUP BY ii.ItemName;
GO

-- View for reservation deposits
CREATE VIEW vw_ReservationDeposits AS
SELECT 
    r.Id AS ReservationId,
    r.UserId,
    u.FullName AS CustomerName,
    r.TotalAmount,
    r.DepositAmount,
    r.DepositPaidDate,
    r.DepositStatus,
    ISNULL(r.TotalAmount, 0) - ISNULL(r.DepositAmount, 0) AS RemainingBalance,
    p.Id AS PaymentId,
    p.Amount AS PaymentAmount,
    p.PaymentType,
    p.Status AS PaymentStatus,
    p.CreatedAt AS PaymentDate
FROM dbo.Reservations r
INNER JOIN dbo.Users u ON r.UserId = u.Id
LEFT JOIN dbo.Payments p ON r.Id = p.ReservationId AND p.PaymentType = 'DEPOSIT'
WHERE r.Status NOT IN ('CANCELLED');
GO

-- Email Verification Views
-- View for pending changes summary
CREATE VIEW vw_PendingChangesSummary AS
SELECT 
    pc.Id,
    u.FullName AS UserName,
    u.Email AS CurrentEmail,
    u.Phone AS CurrentPhone,
    u.Role AS UserRole,
    admin.FullName AS InitiatedByName,
    pc.ChangeType,
    pc.NewEmail,
    pc.NewPhone,
    pc.ChangeReason,
    pc.Status,
    pc.CreatedAt,
    pc.TokenExpiry,
    DATEDIFF(HOUR, GETDATE(), pc.TokenExpiry) AS HoursUntilExpiry,
    pc.NotificationSent,
    pc.ReminderCount
FROM dbo.PendingChanges pc
INNER JOIN dbo.Users u ON pc.UserId = u.Id
INNER JOIN dbo.Users admin ON pc.InitiatedBy = admin.Id
WHERE pc.Status IN ('PENDING', 'APPROVED', 'REJECTED')
GO

-- View for security audit dashboard
CREATE VIEW vw_SecurityAuditDashboard AS
SELECT 
    sal.Id,
    u.FullName AS AffectedUser,
    u.Role AS UserRole,
    admin.FullName AS ActionBy,
    sal.Action,
    sal.FieldChanged,
    sal.RiskLevel,
    sal.RequiredApproval,
    sal.ApprovalStatus,
    sal.Timestamp,
    CASE 
        WHEN sal.Timestamp > DATEADD(HOUR, -1, GETDATE()) THEN 'Last Hour'
        WHEN sal.Timestamp > DATEADD(DAY, -1, GETDATE()) THEN 'Last 24 Hours'
        WHEN sal.Timestamp > DATEADD(DAY, -7, GETDATE()) THEN 'Last Week'
        ELSE 'Older'
    END AS TimeCategory
FROM dbo.SecurityAuditLog sal
INNER JOIN dbo.Users u ON sal.UserId = u.Id
INNER JOIN dbo.Users admin ON sal.ActionBy = admin.Id
WHERE sal.RiskLevel IN ('HIGH', 'CRITICAL')
GO

--------------------------------------------------------------------------------
-- TRIGGER FOR SECURITY AUDIT
--------------------------------------------------------------------------------

-- Trigger to log all user changes
CREATE TRIGGER TR_Users_SecurityAudit
ON dbo.Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log email changes
    INSERT INTO dbo.SecurityAuditLog (UserId, ActionBy, Action, EntityType, EntityId, FieldChanged, OldValue, NewValue, RiskLevel)
    SELECT 
        i.Id, i.Id, 'EMAIL_CHANGED', 'USER', i.Id, 'EMAIL', d.Email, i.Email, 'HIGH'
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id
    WHERE i.Email != d.Email;
    
    -- Log phone changes  
    INSERT INTO dbo.SecurityAuditLog (UserId, ActionBy, Action, EntityType, EntityId, FieldChanged, OldValue, NewValue, RiskLevel)
    SELECT 
        i.Id, i.Id, 'PHONE_CHANGED', 'USER', i.Id, 'PHONE', d.Phone, i.Phone, 'MEDIUM'
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id
    WHERE ISNULL(i.Phone, '') != ISNULL(d.Phone, '');
    
    -- Log password changes
    INSERT INTO dbo.SecurityAuditLog (UserId, ActionBy, Action, EntityType, EntityId, FieldChanged, OldValue, NewValue, RiskLevel)
    SELECT 
        i.Id, i.Id, 'PASSWORD_CHANGED', 'USER', i.Id, 'PASSWORD', 'MASKED', 'MASKED', 'CRITICAL'
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id
    WHERE i.PasswordHash != d.PasswordHash;
END;
GO

-- Insert Services
INSERT INTO dbo.Services (Name, Price, Description, Status)
VALUES
-- Transportation Services
('Airport Shuttle - One Way', 350000, 'Private car service from/to Tan Son Nhat Airport (45 mins)', 'active'),
('Airport Shuttle - Round Trip', 600000, 'Private car service round trip to/from airport with flexible timing', 'active'),
('City Tour - Half Day', 800000, 'Guided tour of Ho Chi Minh City highlights with English-speaking guide', 'active'),
('Private Car - Full Day', 1500000, 'Private car with driver for 8 hours within city limits', 'active'),

-- Dining Services  
('Breakfast Buffet', 350000, 'International breakfast buffet at Sunrise Restaurant (6:30-10:30 AM)', 'active'),
('Romantic Dinner Package', 1200000, 'Candlelight dinner for 2 with wine at rooftop restaurant', 'active'),
('Room Service - 24/7', 100000, 'In-room dining service available round the clock (per order)', 'active'),
('Mini Bar Package', 500000, 'Unlimited mini bar access during your stay', 'active'),

-- Spa & Wellness
('Traditional Vietnamese Massage - 60min', 800000, 'Relaxing full body massage with aromatic oils', 'active'),
('Luxury Spa Package - 120min', 1800000, 'Full spa treatment including massage, facial, and body scrub', 'active'),
('Couples Spa Experience', 3000000, 'Private spa suite for couples with champagne and treatments', 'active'),
('Yoga Session - Private', 400000, 'One-on-one yoga session with certified instructor', 'active'),

-- Business Services
('Meeting Room - Half Day', 2000000, 'Executive meeting room for up to 10 people (4 hours)', 'active'),
('Business Center Access', 200000, 'Full day access to business center with printing/scanning', 'active'),
('Video Conference Setup', 500000, 'Professional video conference equipment and support', 'active'),

-- Laundry Services
('Express Laundry (Same Day)', 200000, 'Same day laundry service - wash, dry, and iron', 'active'),
('Dry Cleaning Service', 150000, 'Professional dry cleaning for delicate garments (per item)', 'active'),
('Shoe Cleaning Service', 100000, 'Professional shoe cleaning and polishing service', 'active'),

-- Special Services
('Flower Arrangement', 300000, 'Fresh flower arrangement delivered to your room', 'active'),
('Birthday Celebration Package', 800000, 'Decorated room with cake and champagne for special occasions', 'active'),
('Honeymoon Package', 1500000, 'Rose petals, champagne, chocolates, and late checkout', 'active'),
('Pet Care Service', 250000, 'Professional pet sitting service (per day)', 'active'),
('Baby Sitting Service', 300000, 'Professional childcare service (per hour)', 'active');
GO

--------------------------------------------------------------------------------
-- INSERT EMAIL TEMPLATES
--------------------------------------------------------------------------------

INSERT INTO dbo.EmailTemplates (TemplateName, TemplateType, Subject, HtmlBody, TextBody) VALUES
('CHANGE_REQUEST_EMAIL', 'CHANGE_REQUEST', 
 'Action Required: Confirm Your Account Information Change',
 '<html><body>
    <h2>Account Information Change Request</h2>
    <p>Dear {USER_NAME},</p>
    <p>An administrator ({ADMIN_NAME}) has requested to change your <strong>{CHANGE_TYPE}</strong>.</p>
    <p><strong>Current {CHANGE_TYPE}:</strong> {OLD_VALUE}</p>
    <p><strong>Requested {CHANGE_TYPE}:</strong> {NEW_VALUE}</p>
    <p><strong>Reason:</strong> {REASON}</p>
    <p>If you approve this change, please click the link below:</p>
    <p><a href="{VERIFICATION_LINK}" style="background: #5a2b81; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">APPROVE CHANGE</a></p>
    <p>If you did not request this change, please contact our support team immediately.</p>
    <p>This link will expire on {EXPIRY_DATE}.</p>
    <p>Best regards,<br>Hotel Management Team</p>
  </body></html>',
 'Account Information Change Request

Dear {USER_NAME},

An administrator ({ADMIN_NAME}) has requested to change your {CHANGE_TYPE}.

Current {CHANGE_TYPE}: {OLD_VALUE}
Requested {CHANGE_TYPE}: {NEW_VALUE}
Reason: {REASON}

To approve this change, please visit: {VERIFICATION_LINK}

If you did not request this change, please contact support immediately.

This link expires on {EXPIRY_DATE}.

Best regards,
Hotel Management Team'
),

('CHANGE_APPROVED', 'APPROVED',
 'Your Account Information Has Been Updated',
 '<html><body>
    <h2>Account Information Updated</h2>
    <p>Dear {USER_NAME},</p>
    <p>Your <strong>{CHANGE_TYPE}</strong> has been successfully updated.</p>
    <p><strong>New {CHANGE_TYPE}:</strong> {NEW_VALUE}</p>
    <p>If you did not approve this change, please contact support immediately.</p>
    <p>Best regards,<br>Hotel Management Team</p>
  </body></html>',
 'Account Information Updated

Dear {USER_NAME},

Your {CHANGE_TYPE} has been successfully updated.
New {CHANGE_TYPE}: {NEW_VALUE}

If you did not approve this change, please contact support immediately.

Best regards,
Hotel Management Team'
),

('CHANGE_REMINDER', 'REMINDER',
 'Reminder: Pending Account Information Change',
 '<html><body>
    <h2>Reminder: Pending Account Change</h2>
    <p>Dear {USER_NAME},</p>
    <p>You have a pending request to change your <strong>{CHANGE_TYPE}</strong>.</p>
    <p>Please click the link below to approve or reject this change:</p>
    <p><a href="{VERIFICATION_LINK}" style="background: #5a2b81; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">REVIEW CHANGE</a></p>
    <p>This request will expire on {EXPIRY_DATE}.</p>
    <p>Best regards,<br>Hotel Management Team</p>
  </body></html>',
 'Reminder: Pending Account Change

Dear {USER_NAME},

You have a pending request to change your {CHANGE_TYPE}.

Please visit: {VERIFICATION_LINK}

This request expires on {EXPIRY_DATE}.

Best regards,
Hotel Management Team'
);
GO

--------------------------------------------------------------------------------
-- SAMPLE DATA INSERTION
--------------------------------------------------------------------------------

-- Create Admin with enhanced details
EXEC sp_CreateEmployee 
    @Username = 'admin',
    @PasswordHash = 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7',
    @FullName = 'Alice Administrator',
    @Email = 'luxuryhotel999@gmail.com',
    @Phone = '0123456789',
    @Role = 'ADMIN',
    @Department = 'Management',
    @HireDate = '2020-01-15',
    @Salary = 30000000,
    @DateOfBirth = '1980-03-15',
    @Gender = 'FEMALE',
    @Address = '123 Nguyen Hue Street',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';

-- Create Receptionist with enhanced details
EXEC sp_CreateEmployee 
    @Username = 'reception1',
    @PasswordHash = '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e',
    @FullName = 'Peter Receptionist',
    @Email = 'peter@luxuryhotel.com',
    @Phone = '0987654321',
    @Role = 'RECEPTIONIST',
    @Department = 'Front Office',
    @HireDate = '2021-03-01',
    @Salary = 15000000,
    @DateOfBirth = '1992-07-22',
    @Gender = 'MALE',
    @Address = '456 Le Loi Boulevard',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';

-- Create Housekeeper with enhanced details
EXEC sp_CreateEmployee 
    @Username = 'house1',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'Charlie Housekeeper',
    @Email = 'charlie@luxuryhotel.com',
    @Phone = '0911223344',
    @Role = 'HOUSEKEEPER',
    @Department = 'Housekeeping',
    @HireDate = '2021-06-15',
    @Salary = 12000000,
    @DateOfBirth = '1988-11-10',
    @Gender = 'MALE',
    @Address = '789 Tran Hung Dao Street',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';

-- Create additional housekeepers with enhanced details
DECLARE @i INT = 2;
DECLARE @userId INT;
WHILE @i <= 5
BEGIN
    DECLARE @username NVARCHAR(50) = CONCAT('house', @i);
    DECLARE @email NVARCHAR(100) = CONCAT('house', @i, '@luxuryhotel.com');
    DECLARE @fullname NVARCHAR(100) = CONCAT('Housekeeper ', @i);
    DECLARE @phone NVARCHAR(20) = CONCAT('091122334', @i);
    DECLARE @birthdate DATE = CASE @i
        WHEN 2 THEN '1990-05-20'
        WHEN 3 THEN '1993-09-18'
        WHEN 4 THEN '1991-12-25'
        WHEN 5 THEN '1989-04-30'
    END;
    DECLARE @gender NVARCHAR(10) = CASE 
        WHEN @i IN (2, 4) THEN 'FEMALE'
        ELSE 'MALE'
    END;
    DECLARE @address NVARCHAR(500) = CASE @i
        WHEN 2 THEN '321 Vo Van Tan Street'
        WHEN 3 THEN '654 Hai Ba Trung Street'
        WHEN 4 THEN '987 Nguyen Thi Minh Khai Street'
        WHEN 5 THEN '147 Pham Ngu Lao Street'
    END;
    
    EXEC sp_CreateEmployee 
        @Username = @username,
        @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
        @FullName = @fullname,
        @Email = @email,
        @Phone = @phone,
        @Role = 'HOUSEKEEPER',
        @Department = 'Housekeeping',
        @HireDate = '2022-01-01',
        @Salary = 11000000,
        @DateOfBirth = @birthdate,
        @Gender = @gender,
        @Address = @address,
        @City = 'Ho Chi Minh City',
        @Country = 'Vietnam';
    
    SET @i = @i + 1;
END;
GO

-- Create Room Inspectors with enhanced details
EXEC sp_CreateEmployee 
    @Username = 'inspector1',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'Diana Inspector',
    @Email = 'diana@luxuryhotel.com',
    @Phone = '0911223355',
    @Role = 'ROOM_INSPECTOR',
    @Department = 'Housekeeping',
    @HireDate = '2021-08-01',
    @Salary = 13000000,
    @DateOfBirth = '1985-06-12',
    @Gender = 'FEMALE',
    @Address = '258 Cong Quynh Street',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';

EXEC sp_CreateEmployee 
    @Username = 'inspector2',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'Frank Chen',
    @Email = 'frank.chen@luxuryhotel.com',
    @Phone = '0911223366',
    @Role = 'ROOM_INSPECTOR',
    @Department = 'Housekeeping',
    @HireDate = '2022-03-15',
    @Salary = 12500000,
    @DateOfBirth = '1987-02-28',
    @Gender = 'MALE',
    @Address = '369 Dien Bien Phu Street',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';

-- Create new receptionist (from file 1)
EXEC sp_CreateEmployee 
    @Username = 'reception2',
    @PasswordHash = '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e',
    @FullName = 'Sarah Johnson',
    @Email = 'sarah.johnson@luxuryhotel.com',
    @Phone = '0987654322',
    @Role = 'RECEPTIONIST',
    @Department = 'Front Office',
    @HireDate = '2023-01-15',
    @Salary = 14000000,
    @DateOfBirth = '1995-08-20',
    @Gender = 'FEMALE',
    @Address = '789 Park Avenue',
    @City = 'Ho Chi Minh City',
    @Country = 'Vietnam';
GO

-- Create Customers
EXEC sp_CreateCustomer
    @Username = 'customer1',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'David Johnson',
    @Email = 'david@gmail.com',
    @Phone = '0900000001',
    @IdType = 'PASSPORT',
    @IdNumber = 'US123456789',
    @DateOfBirth = '1985-05-15',
    @Gender = 'MALE',
    @Address = '123 Main St',
    @City = 'New York',
    @Country = 'USA';

EXEC sp_CreateCustomer
    @Username = 'customer2',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'Eva Williams',
    @Email = 'eva@gmail.com',
    @Phone = '0900000002',
    @IdType = 'PASSPORT',
    @IdNumber = 'GB987654321',
    @DateOfBirth = '1990-08-22',
    @Gender = 'FEMALE',
    @Address = '456 Oxford St',
    @City = 'London',
    @Country = 'UK';

-- Create VIP Customer
EXEC sp_CreateCustomer
    @Username = 'vip1',
    @PasswordHash = '46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97',
    @FullName = 'Michael Chen',
    @Email = 'michael.chen@company.com',
    @Phone = '0900000005',
    @IdType = 'PASSPORT',
    @IdNumber = 'CN888888888',
    @DateOfBirth = '1975-06-30',
    @Gender = 'MALE',
    @Address = '888 Business Blvd',
    @City = 'Singapore',
    @Country = 'Singapore';

-- Update customer loyalty status
DECLARE @customerId1 INT = (SELECT Id FROM Users WHERE Username = 'customer1');
DECLARE @customerId2 INT = (SELECT Id FROM Users WHERE Username = 'customer2');
DECLARE @vipId INT = (SELECT Id FROM Users WHERE Username = 'vip1');

UPDATE dbo.CustomerDetails SET LoyaltyPoints = 2500, MembershipLevel = 'GOLD' WHERE UserId = @customerId1;
UPDATE dbo.CustomerDetails SET LoyaltyPoints = 1200, MembershipLevel = 'SILVER' WHERE UserId = @customerId2;
UPDATE dbo.CustomerDetails SET LoyaltyPoints = 15000, MembershipLevel = 'PLATINUM', IsVIP = 1 WHERE UserId = @vipId;
GO

-- Insert Group Bookings
INSERT INTO dbo.GroupBookings (Name, CreatedBy)
VALUES
('FPT Corporation Team', 2),
('Smith Family Reunion', 1);
GO

-- Insert Room Types
INSERT INTO dbo.RoomTypes (Name, Description, BasePrice, imageUrl, Capacity, Status)
VALUES
('Single', 'Single room with one bed, modern amenities, Free WiFi, Air Conditioning', 500000, 'single.jpg', 1, 'active'),
('Double', 'Double room with two beds, city view, Free WiFi, Air Conditioning, Mini Bar', 800000, 'double.jpg', 2, 'active'),
('Suite', 'Luxury suite with living area, kitchen, Free WiFi, Air Conditioning, Jacuzzi', 1500000, 'suite.jpg', 4, 'active'),
('Twin', 'Two single beds side by side, flexible for 2 guests', 900000, 'twin.jpg', 2, 'active'),
('Triple', 'Three single beds or one double + one single bed', 1200000, 'triple.jpg', 3, 'active'),
('Family', 'Spacious room with 2 double beds or double + sofa bed', 1500000, 'family.jpg', 4, 'active'),
('Deluxe', 'Spacious with sofa, work desk, great view', 1000000, 'deluxe.jpg', 2, 'active'),
('Executive', 'Business room with executive lounge access', 1500000, 'executive.jpg', 2, 'active'),
('Presidential Suite', 'Top VIP suite with premium amenities', 3000000, 'presidential_suite.jpg', 6, 'active');
GO

-- Insert Rooms
INSERT INTO dbo.Rooms (RoomNumber, RoomTypeId, Status)
VALUES
-- Floor 1
('101', 1, 'AVAILABLE'),
('102', 1, 'OCCUPIED'),
('103', 4, 'AVAILABLE'),
('104', 5, 'AVAILABLE'),
('105', 6, 'AVAILABLE'),
-- Floor 2
('201', 2, 'AVAILABLE'),
('202', 2, 'MAINTENANCE'),
('203', 7, 'AVAILABLE'),
('204', 8, 'AVAILABLE'),
('205', 2, 'AVAILABLE'),
-- Floor 3
('301', 3, 'AVAILABLE'),
('302', 3, 'DIRTY'),
('303', 1, 'AVAILABLE'),
('304', 4, 'AVAILABLE'),
('305', 5, 'AVAILABLE');
GO

-- Insert Blogs
INSERT INTO dbo.Blogs (Title, Slug, Content, AuthorId, Status, ImageUrl)
VALUES
(
    'Discover Spa & Wellness at Luxury Hotel',
    'discover-spa-wellness-luxury-hotel',
    'Luxury Hotel proudly offers world-class Spa & Wellness services:
1. Relaxing massage treatments
2. Professional skincare therapies
3. Premium products and facilities
Book your appointment and enjoy moments of pure relaxation!',
    1, 'PUBLISHED', 'spa-wellness.jpg'
),
(
    'Simple Online Booking Guide',
    'simple-online-booking-guide',
    'Book your stay in just 3 easy steps:
1. Select check-in and check-out dates
2. Choose your preferred room type
3. Confirm and make payment
You will receive an instant confirmation email!',
    2, 'PUBLISHED', 'booking-guide.jpg'
),
(
    '5 Tips for Perfect Family Vacation',
    '5-tips-perfect-family-vacation',
    'Make your family vacation memorable:
- Choose Family or Connecting rooms
- Plan activities for all family members
- Book Kids Club services for children
- Enjoy family dining at our restaurant
- Capture precious moments together',
    1, 'PUBLISHED', 'family-vacation.jpg'
);
GO

-- Insert Events
INSERT INTO dbo.Events (Title, Description, Location, StartAt, EndAt, Status, CreatedBy, ImageUrl)
VALUES
('Summer Music Festival', 
 'Join us for three days of live music by the poolside with local and international bands.', 
 'Hotel Central Garden', 
 '2025-07-15 14:00', '2025-07-17 23:00', 
 'SCHEDULED', 1, 'event1.jpg'),

('Annual Business Conference', 
 'A full-day conference featuring keynote speakers on industry trends and networking sessions.', 
 'Grand Ballroom A', 
 '2025-08-20 09:00', '2025-08-20 17:00', 
 'SCHEDULED', 1, 'event2.jpg'),

('Poolside Movie Night', 
 'Outdoor screening of classic films under the stars with complimentary snacks.', 
 'Rooftop Pool Deck', 
 '2025-06-25 20:00', '2025-06-25 23:00', 
 'COMPLETED', 1, 'event3.jpg');
GO

-- Test email verification system with sample data
IF EXISTS (SELECT 1 FROM dbo.Users WHERE Role = 'ADMIN')
BEGIN
    DECLARE @AdminId INT = (SELECT TOP 1 Id FROM dbo.Users WHERE Role = 'ADMIN');
    DECLARE @CustomerId INT = (SELECT TOP 1 Id FROM dbo.Users WHERE Role = 'CUSTOMER');
    
    IF @CustomerId IS NOT NULL
    BEGIN
        -- Create a sample email change request
        EXEC sp_InitiateChangeRequest 
            @UserId = @CustomerId,
            @InitiatedBy = @AdminId,
            @ChangeType = 'EMAIL',
            @NewEmail = 'new.email@example.com',
            @ChangeReason = 'Customer requested email update',
            @ExpiryHours = 48;
        
        PRINT 'Sample email change request created successfully!';
    END
END
GO

-- Update existing payments to have PaymentType (for existing data compatibility)
UPDATE dbo.Payments 
SET PaymentType = 'FULL_PAYMENT' 
WHERE PaymentType IS NULL;
GO

-- Query to view enhanced employee information
SELECT 
    u.FullName,
    u.Role,
    ed.DateOfBirth,
    DATEDIFF(YEAR, ed.DateOfBirth, GETDATE()) AS Age,
    ed.Gender,
    ed.Address,
    ed.City,
    ed.Country,
    ed.Department,
    ed.HireDate
FROM dbo.Users u
INNER JOIN dbo.EmployeeDetails ed ON u.Id = ed.UserId
WHERE u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR')
ORDER BY u.Role, u.FullName;
GO

PRINT '';
PRINT '================================================================';
PRINT 'HOTEL MANAGEMENT SYSTEM WITH EMAIL VERIFICATION AND DEPOSIT SYSTEM';
PRINT 'ENHANCED WITH EMPLOYEE DETAILS';
PRINT '================================================================';
PRINT '';
PRINT 'Database created successfully with all features:';
PRINT '';
PRINT 'HOTEL MANAGEMENT FEATURES:';
PRINT '✅ User Management with Roles (Admin, Receptionist, Housekeeper, Inspector, Customer)';
PRINT '✅ Enhanced Employee Details (DateOfBirth, Gender, Address, City, Country)';
PRINT '✅ Customer loyalty program with membership levels';
PRINT '✅ Flexible room booking (by room type or specific room)';
PRINT '✅ Room inspection system for accurate billing';
PRINT '✅ Housekeeping task management';
PRINT '✅ Payment processing with multiple methods';
PRINT '✅ Blog and event management';
PRINT '✅ Activity logging and OTA sync';
PRINT '';
PRINT 'ENHANCED EMPLOYEE FEATURES:';
PRINT '✅ Added DateOfBirth, Gender, Address, City, Country to EmployeeDetails table';
PRINT '✅ Updated sp_CreateEmployee with age validation (>= 18 years)';
PRINT '✅ Created sp_UpdateEmployeeDetails procedure';
PRINT '✅ Enhanced vw_Employees view with new columns';
PRINT '✅ Created vw_EmployeeDetails view with calculated fields (Age, YearsOfService)';
PRINT '✅ Updated all sample employee data with complete information';
PRINT '';
PRINT 'DEPOSIT SYSTEM FEATURES:';
PRINT '✅ Deposit amount tracking on reservations';
PRINT '✅ Multiple payment types (DEPOSIT, FULL_PAYMENT, REMAINING_BALANCE, REFUND)';
PRINT '✅ Deposit processing and refund procedures';
PRINT '✅ Deposit status tracking (PENDING, PAID, REFUNDED)';
PRINT '✅ View for monitoring deposit payments';
PRINT '';
PRINT 'EMAIL VERIFICATION FEATURES:';
PRINT '✅ Secure token-based verification system';
PRINT '✅ Email notification with customizable HTML templates';
PRINT '✅ Comprehensive security audit logging';
PRINT '✅ Automatic token expiry and cleanup';
PRINT '✅ Admin monitoring dashboards';
PRINT '✅ Support for email, phone, and password changes';
PRINT '';
PRINT 'The system is ready for use!';
PRINT '================================================================';
GO
