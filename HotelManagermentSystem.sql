
/*run to create database*/
Create database HotelManagement_3


/*run before run to create database*/
USE [HotelManagement_3]
GO
/****** Object:  Table [dbo].[PendingChanges]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PendingChanges](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[ChangeType] [nvarchar](20) NOT NULL,
	[OriginalEmail] [nvarchar](100) NULL,
	[OriginalPhone] [nvarchar](20) NULL,
	[NewEmail] [nvarchar](100) NULL,
	[NewPhone] [nvarchar](20) NULL,
	[NewPasswordHash] [nvarchar](255) NULL,
	[ChangeReason] [nvarchar](500) NULL,
	[ChangeDetails] [nvarchar](max) NULL,
	[VerificationToken] [nvarchar](255) NOT NULL,
	[TokenExpiry] [datetime] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[NotificationSent] [bit] NOT NULL,
	[ReminderSent] [bit] NOT NULL,
	[ReminderCount] [int] NOT NULL,
	[ApprovedAt] [datetime] NULL,
	[ApprovedByEmail] [bit] NOT NULL,
	[RejectedAt] [datetime] NULL,
	[RejectionReason] [nvarchar](500) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[FullName] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [nvarchar](20) NULL,
	[Role] [nvarchar](20) NOT NULL,
	[Status] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_PendingChangesSummary]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------
-- 6. Views for monitoring and reporting
--------------------------------------------------------------------------------

-- View for pending changes summary
CREATE VIEW [dbo].[vw_PendingChangesSummary] AS
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
/****** Object:  Table [dbo].[SecurityAuditLog]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SecurityAuditLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ActionBy] [int] NOT NULL,
	[Action] [nvarchar](50) NOT NULL,
	[EntityType] [nvarchar](30) NOT NULL,
	[EntityId] [int] NOT NULL,
	[FieldChanged] [nvarchar](50) NULL,
	[OldValue] [nvarchar](500) NULL,
	[NewValue] [nvarchar](500) NULL,
	[ChangeReason] [nvarchar](500) NULL,
	[IpAddress] [nvarchar](50) NULL,
	[UserAgent] [nvarchar](500) NULL,
	[SessionId] [nvarchar](100) NULL,
	[RiskLevel] [nvarchar](20) NOT NULL,
	[RequiredApproval] [bit] NOT NULL,
	[ApprovalStatus] [nvarchar](20) NULL,
	[Timestamp] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_SecurityAuditDashboard]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for security audit dashboard
CREATE VIEW [dbo].[vw_SecurityAuditDashboard] AS
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
/****** Object:  Table [dbo].[RoomInspections]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomInspections](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[InspectorId] [int] NOT NULL,
	[InspectionTime] [datetime] NOT NULL,
	[RoomCondition] [nvarchar](20) NOT NULL,
	[CleanlinessScore] [int] NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[PhotoUrls] [nvarchar](max) NULL,
	[Status] [nvarchar](20) NOT NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InspectionItems]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InspectionItems](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InspectionId] [int] NOT NULL,
	[ItemName] [nvarchar](100) NOT NULL,
	[ItemCategory] [nvarchar](50) NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](10, 2) NOT NULL,
	[TotalPrice]  AS ([Quantity]*[UnitPrice]) PERSISTED,
	[Notes] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoomDamages]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomDamages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InspectionId] [int] NOT NULL,
	[DamageType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[EstimatedCost] [decimal](10, 2) NOT NULL,
	[PhotoUrl] [nvarchar](500) NULL,
	[Severity] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CheckInDetails]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CheckInDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[IdType] [nvarchar](20) NOT NULL,
	[IdNumber] [nvarchar](50) NOT NULL,
	[AdditionalGuests] [int] NOT NULL,
	[SpecialRequests] [nvarchar](500) NULL,
	[SecurityDeposit] [decimal](10, 2) NOT NULL,
	[KeyCards] [int] NOT NULL,
	[KeyCardNumbers] [nvarchar](100) NULL,
	[CheckInNotes] [nvarchar](500) NULL,
	[CheckInTime] [datetime] NOT NULL,
	[CheckInBy] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[GroupBookingId] [int] NULL,
	[CreatedBy] [int] NULL,
	[RoomId] [int] NULL,
	[CheckIn] [date] NOT NULL,
	[CheckOut] [date] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[Notes] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[RoomTypeId] [int] NULL,
	[SpecialRequests] [nvarchar](500) NULL,
	[NumberOfCustomers] [int] NOT NULL,
	[UpdatedAt] [datetime] NULL,
	[DepositAmount] [decimal](10, 2) NULL,
	[DepositPaidDate] [datetime] NULL,
	[DepositStatus] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[Method] [nvarchar](20) NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[TransactionId] [nvarchar](100) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[PaymentType] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalculateReservationCharges]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Function to calculate total charges for a reservation
CREATE FUNCTION [dbo].[fn_CalculateReservationCharges](@ReservationId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.TotalAmount AS RoomCharges,
        COALESCE((
            SELECT SUM(ii.TotalPrice)
            FROM dbo.RoomInspections ri
            INNER JOIN dbo.InspectionItems ii ON ri.Id = ii.InspectionId
            WHERE ri.ReservationId = @ReservationId
              AND ri.Status = 'APPROVED'
              AND ii.ItemCategory IN ('MINIBAR', 'AMENITY')
        ), 0) AS MinibarCharges,
        COALESCE((
            SELECT SUM(ii.TotalPrice)
            FROM dbo.RoomInspections ri
            INNER JOIN dbo.InspectionItems ii ON ri.Id = ii.InspectionId
            WHERE ri.ReservationId = @ReservationId
              AND ri.Status = 'APPROVED'
              AND ii.ItemCategory = 'SERVICE'
        ), 0) AS ServiceCharges,
        COALESCE((
            SELECT SUM(rd.EstimatedCost)
            FROM dbo.RoomInspections ri
            INNER JOIN dbo.RoomDamages rd ON ri.Id = rd.InspectionId
            WHERE ri.ReservationId = @ReservationId
              AND ri.Status = 'APPROVED'
        ), 0) AS DamageCharges,
        COALESCE((
            SELECT SecurityDeposit
            FROM dbo.CheckInDetails
            WHERE ReservationId = @ReservationId
        ), 0) AS SecurityDeposit,
        COALESCE((
            SELECT SUM(Amount)
            FROM dbo.Payments
            WHERE ReservationId = @ReservationId
              AND Status = 'COMPLETED'
        ), 0) AS AmountPaid
    FROM dbo.Reservations r
    WHERE r.Id = @ReservationId
);
GO
/****** Object:  View [dbo].[vw_ReservationDeposits]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_ReservationDeposits] AS
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
/****** Object:  Table [dbo].[CustomerDetails]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[IdType] [nvarchar](20) NULL,
	[IdNumber] [nvarchar](50) NULL,
	[DateOfBirth] [date] NULL,
	[Gender] [nvarchar](10) NULL,
	[Address] [nvarchar](500) NULL,
	[City] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[LoyaltyPoints] [int] NOT NULL,
	[MembershipLevel] [nvarchar](20) NOT NULL,
	[IsVIP] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Customers]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------
-- CREATE VIEWS
--------------------------------------------------------------------------------

-- View for complete customer information
CREATE VIEW [dbo].[vw_Customers] AS
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
/****** Object:  Table [dbo].[EmployeeDetails]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[Department] [nvarchar](50) NULL,
	[HireDate] [date] NULL,
	[Salary] [decimal](10, 2) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
	[DateOfBirth] [date] NULL,
	[Gender] [nvarchar](10) NULL,
	[Address] [nvarchar](500) NULL,
	[City] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Employees]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Cập nhật View vw_Employees để hiển thị thông tin mới
CREATE VIEW [dbo].[vw_Employees] AS
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
/****** Object:  Table [dbo].[Rooms]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rooms](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoomNumber] [nvarchar](10) NOT NULL,
	[RoomTypeId] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[HoldUntil] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_PendingInspections]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for pending inspections
CREATE VIEW [dbo].[vw_PendingInspections] AS
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
INNER JOIN dbo.Rooms rm ON r.RoomId = rm.Id
LEFT JOIN dbo.RoomInspections ri ON r.Id = ri.ReservationId
WHERE r.Status = 'CONFIRMED' 
    AND r.CheckOut <= DATEADD(day, 1, GETDATE())
    AND (ri.Id IS NULL OR ri.Status != 'COMPLETED');
GO
/****** Object:  View [dbo].[vw_EmployeeDetails]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. Tạo View mới để xem thông tin chi tiết của nhân viên
CREATE   VIEW [dbo].[vw_EmployeeDetails] AS
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
/****** Object:  View [dbo].[vw_InspectionCharges]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for inspection summary with charges
CREATE VIEW [dbo].[vw_InspectionCharges] AS
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
INNER JOIN dbo.Rooms rm ON r.RoomId = rm.Id
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
/****** Object:  Table [dbo].[RoomTypes]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[BasePrice] [decimal](10, 2) NOT NULL,
	[imageUrl] [nvarchar](500) NOT NULL,
	[Capacity] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_ActiveReservations]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for active reservations
CREATE VIEW [dbo].[vw_ActiveReservations] AS
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
    e.FullName AS CreatedByEmployee
FROM dbo.Reservations r
INNER JOIN dbo.Users u ON r.UserId = u.Id
INNER JOIN dbo.Rooms rm ON r.RoomId = rm.Id
INNER JOIN dbo.RoomTypes rt ON rm.RoomTypeId = rt.Id
LEFT JOIN dbo.Users e ON r.CreatedBy = e.Id
WHERE r.Status IN ('PENDING', 'CONFIRMED');
GO
/****** Object:  View [dbo].[vw_RoomStatus]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for room status
CREATE VIEW [dbo].[vw_RoomStatus] AS
SELECT 
    r.Id,
    r.RoomNumber,
    rt.Name AS RoomType,
    r.Status,
    CASE 
        WHEN res.Id IS NOT NULL THEN res.CheckOut
        ELSE NULL
    END AS ExpectedAvailableDate
FROM dbo.Rooms r
INNER JOIN dbo.RoomTypes rt ON r.RoomTypeId = rt.Id
LEFT JOIN dbo.Reservations res ON r.Id = res.RoomId 
    AND res.Status = 'CONFIRMED' 
    AND res.CheckIn <= GETDATE() 
    AND res.CheckOut >= GETDATE();
GO
/****** Object:  View [dbo].[vw_DailyInspectionReport]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for daily inspection report
CREATE VIEW [dbo].[vw_DailyInspectionReport] AS
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
/****** Object:  View [dbo].[vw_MinibarConsumptionReport]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- View for minibar consumption report
CREATE VIEW [dbo].[vw_MinibarConsumptionReport] AS
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
/****** Object:  Table [dbo].[Activities]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activities](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[ReservationId] [int] NULL,
	[UserId] [int] NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[Amount] [decimal](10, 2) NULL,
	[Timestamp] [datetime] NOT NULL,
	[IpAddress] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmenityInventory]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmenityInventory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[AmenityId] [int] NOT NULL,
	[InitialQuantity] [int] NOT NULL,
	[Condition] [nvarchar](20) NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[CheckedBy] [int] NOT NULL,
	[CheckedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Blogs]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Slug] [nvarchar](200) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[AuthorId] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CheckOutDetails]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CheckOutDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[InspectionId] [int] NULL,
	[RoomCondition] [nvarchar](20) NOT NULL,
	[DamageDescription] [nvarchar](500) NULL,
	[DamageCharges] [decimal](10, 2) NOT NULL,
	[AmenityCharges] [decimal](10, 2) NOT NULL,
	[ServiceCharges] [decimal](10, 2) NOT NULL,
	[FinalAmount] [decimal](10, 2) NOT NULL,
	[RefundAmount] [decimal](10, 2) NOT NULL,
	[PaymentMethod] [nvarchar](20) NULL,
	[CheckOutNotes] [nvarchar](500) NULL,
	[CheckOutTime] [datetime] NOT NULL,
	[CheckOutBy] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BlogId] [int] NOT NULL,
	[AuthorName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Content] [nvarchar](1000) NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactMessages]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactMessages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Email] [nvarchar](255) NOT NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[CreatedAt] [datetime] NULL,
	[feedbackId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmailTemplates]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](50) NOT NULL,
	[TemplateType] [nvarchar](30) NOT NULL,
	[Subject] [nvarchar](200) NOT NULL,
	[HtmlBody] [nvarchar](max) NOT NULL,
	[TextBody] [nvarchar](max) NULL,
	[Language] [nvarchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Equipment]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Equipment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Events]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Events](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Location] [nvarchar](200) NULL,
	[StartAt] [datetime] NOT NULL,
	[EndAt] [datetime] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[CreatedBy] [int] NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Feedback]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feedback](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Rating] [tinyint] NOT NULL,
	[Comment] [nvarchar](1000) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[disabled] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GroupBookings]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupBookings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HousekeepingTasks]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HousekeepingTasks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoomId] [int] NOT NULL,
	[AssignedTo] [int] NULL,
	[Status] [nvarchar](20) NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationHistory]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[PendingChangeId] [int] NULL,
	[NotificationType] [nvarchar](30) NOT NULL,
	[Channel] [nvarchar](20) NOT NULL,
	[Recipient] [nvarchar](100) NOT NULL,
	[Subject] [nvarchar](200) NULL,
	[Message] [nvarchar](max) NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[SentAt] [datetime] NOT NULL,
	[ErrorMessage] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[ReservationId] [int] NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[SentAt] [datetime] NULL,
	[Status] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OTASync]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OTASync](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Provider] [nvarchar](50) NOT NULL,
	[RoomId] [int] NOT NULL,
	[Action] [nvarchar](30) NOT NULL,
	[Payload] [nvarchar](max) NULL,
	[SyncedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PasswordResetTokens]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PasswordResetTokens](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[Token] [nvarchar](100) NOT NULL,
	[Expiry] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationAmenityUsage]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationAmenityUsage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[AmenityId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](10, 2) NOT NULL,
	[TotalPrice] [decimal](10, 2) NOT NULL,
	[CheckedBy] [int] NULL,
	[CheckedAt] [datetime] NULL,
	[Notes] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationServices]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationServices](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[ServiceId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoomAmenities]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomAmenities](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoomId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[UnitPrice] [decimal](10, 2) NOT NULL,
	[IsChargeable] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoomEquipment]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomEquipment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoomId] [int] NOT NULL,
	[EquipmentId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoomTypeImages]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomTypeImages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoomTypeId] [int] NOT NULL,
	[ImageUrl] [nvarchar](500) NOT NULL,
	[ImageType] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Services]    Script Date: 7/22/2025 10:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Services](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Status] [nvarchar](20) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Activities] ON 

INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1, N'LOGIN', NULL, 1, N'Admin logged in', NULL, CAST(N'2025-06-18T19:59:21.570' AS DateTime), N'192.168.1.100')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2, N'RESERVATION_CREATE', 1, 2, N'Created reservation #1', CAST(1000000.00 AS Decimal(10, 2)), CAST(N'2025-06-13T21:59:21.570' AS DateTime), N'192.168.1.101')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3, N'PAYMENT_RECEIVE', 1, 2, N'Received payment for reservation #1', CAST(1000000.00 AS Decimal(10, 2)), CAST(N'2025-06-13T21:59:21.570' AS DateTime), N'192.168.1.101')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4, N'ROOM_INSPECT', 1, 8, N'Completed room inspection for reservation #1', NULL, CAST(N'2025-06-18T21:59:21.570' AS DateTime), N'192.168.1.102')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (5, N'CHECKOUT', 1, 2, N'Guest checked out from room 101', CAST(1210000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:21.570' AS DateTime), N'192.168.1.101')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1002, N'RESERVATION_CREATE', 2002, 1002, N'New reservation created for room 303', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T17:33:17.503' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1003, N'RESERVATION_CREATE', 2003, 1002, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T17:42:31.537' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1004, N'PAYMENT_RECEIVE', 2003, 1002, N'Payment received for reservation #2003', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T17:43:12.023' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1005, N'RESERVATION_CREATE', 2004, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:00:11.463' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1006, N'RESERVATION_CREATE', 2005, 1002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:01:49.557' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1007, N'RESERVATION_CREATE', 2006, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:08:16.247' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1008, N'RESERVATION_CREATE', 2007, 1002, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:10:32.930' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1009, N'RESERVATION_CREATE', 2008, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:21:06.020' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1010, N'RESERVATION_CREATE', 2009, 1002, N'New reservation created for room 201', CAST(2640000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:31:23.647' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1011, N'RESERVATION_CREATE', 2010, 1002, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T20:31:54.720' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1012, N'RESERVATION_CREATE', 2011, 1002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T22:37:29.210' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1013, N'RESERVATION_CREATE', 2012, 1002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T22:39:23.617' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1014, N'RESERVATION_CREATE', 2013, 1002, N'New reservation created for room 101', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T22:44:00.187' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1015, N'RESERVATION_CREATE', 2014, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T22:48:14.580' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1016, N'RESERVATION_CREATE', 2015, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T22:51:56.563' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1017, N'RESERVATION_CREATE', 2016, 1002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:29:07.940' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1018, N'RESERVATION_CREATE', 2017, 1002, N'New reservation created for room 105', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:36:18.373' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1019, N'RESERVATION_CREATE', 2018, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:42:55.530' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1020, N'RESERVATION_CREATE', 2019, 1002, N'New reservation created for room 303', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:43:59.180' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1021, N'RESERVATION_CREATE', 2020, 1002, N'New reservation created for room 104', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:44:53.623' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1022, N'RESERVATION_CREATE', 2021, 1002, N'New reservation created for room 103', CAST(3960000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:50:49.140' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1023, N'RESERVATION_CREATE', 2022, 1002, N'New reservation created for room 105', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-06-21T23:53:08.473' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1024, N'RESERVATION_CREATE', 2023, 1002, N'New reservation created for room 105', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-06-22T00:51:16.777' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1025, N'RESERVATION_CREATE', 2024, 1002, N'New reservation created for room 303', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-06-22T17:41:59.680' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1026, N'RESERVATION_CREATE', 2025, 2002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-23T07:33:55.763' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1027, N'RESERVATION_CONFIRM', 2012, 2, N'Confirmed reservation #2012', NULL, CAST(N'2025-06-24T10:15:41.507' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1028, N'RESERVATION_CONFIRM', 2025, 2, N'Confirmed reservation #2025', NULL, CAST(N'2025-06-24T10:16:35.677' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1029, N'RESERVATION_CONFIRM', 2024, 2, N'Confirmed reservation #2024', NULL, CAST(N'2025-06-24T10:17:04.320' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1030, N'RESERVATION_CONFIRM', 2023, 2, N'Confirmed reservation #2023', NULL, CAST(N'2025-06-24T10:17:08.503' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1031, N'RESERVATION_CREATE', 2027, 1002, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-24T10:37:01.463' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1032, N'RESERVATION_CONFIRM', 2027, 2, N'Confirmed reservation #2027', NULL, CAST(N'2025-06-24T10:55:41.660' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1033, N'RESERVATION_CONFIRM', 2022, 2, N'Confirmed reservation #2022', NULL, CAST(N'2025-06-24T11:10:31.177' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1034, N'RESERVATION_CANCEL', 2002, 2, N'Cancelled reservation #2002', NULL, CAST(N'2025-06-24T11:10:37.297' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1035, N'RESERVATION_CREATE', 2028, 2003, N'New reservation created for room 303', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-06-24T11:38:26.827' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1036, N'RESERVATION_CREATE', 2029, 2004, N'New reservation created for room 205', CAST(5110000.00 AS Decimal(10, 2)), CAST(N'2025-06-25T18:11:07.170' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (1037, N'RESERVATION_CREATE', 2030, 1002, N'New reservation created for room 105', CAST(4000000.00 AS Decimal(10, 2)), CAST(N'2025-06-25T22:12:34.027' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2036, N'RESERVATION_CREATE', 3029, 10, N'New reservation created for room 105', CAST(2300000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T00:41:51.260' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2037, N'RESERVATION_CREATE', 3030, 10, N'New reservation created for room 101 (10% deposit: 55,000₫)', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T01:25:23.390' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2038, N'RESERVATION_CREATE', 3031, 10, N'New reservation created for room 101 (10% deposit: 55,000₫)', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T01:25:47.720' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2039, N'RESERVATION_CREATE', 3032, 11, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T15:49:58.607' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2040, N'RESERVATION_CREATE', 3033, 11, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T15:52:57.180' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2041, N'RESERVATION_CREATE', 3034, 11, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T16:03:52.113' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2042, N'RESERVATION_CREATE', 3035, 11, N'New reservation created for room 303', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T16:04:09.263' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2043, N'PAYMENT_RECEIVE', 3035, 11, N'Payment received for reservation #3035', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T16:05:04.310' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2044, N'RESERVATION_CREATE', 3036, 10, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T16:39:06.887' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2045, N'RESERVATION_CREATE', 3037, 10, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T16:42:34.833' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2046, N'RESERVATION_CREATE', 3038, 1002, N'New reservation created for room 303', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T17:17:57.260' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2047, N'DEPOSIT_PAYMENT', 3038, 1002, N'Deposit payment received for reservation #3038 - Amount: 55000.0 (10% of total)', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T17:18:15.423' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2048, N'RESERVATION_CREATE', 3039, 1002, N'New reservation created for room 103', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T17:53:03.257' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2049, N'DEPOSIT_PAYMENT', 3039, 1002, N'Deposit payment received for reservation #3039 - Amount: 99000.0 (10% of total)', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T17:53:16.257' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2050, N'RESERVATION_CREATE', 3040, 1002, N'New reservation created for room 301', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:05:18.100' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2051, N'DEPOSIT_PAYMENT', 3040, 1002, N'Deposit payment received for reservation #3040 - Amount: 165000.0 (10% of total)', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:05:35.613' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2052, N'RESERVATION_CREATE', 3041, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:13:47.697' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2053, N'DEPOSIT_PAYMENT', 3041, 1002, N'Deposit payment received for reservation #3041 - Amount: 55000.0 (10% of total)', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:14:19.867' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2054, N'RESERVATION_CREATE', 3042, 2004, N'New reservation created for room 104', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:18:20.440' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2055, N'DEPOSIT_PAYMENT', 3042, 2004, N'Deposit payment received for reservation #3042 - Amount: 132000.0 (10% of total)', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:18:37.070' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2056, N'RESERVATION_CREATE', 3043, 2004, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T18:52:55.013' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2057, N'RESERVATION_CREATE', 3044, 2004, N'New reservation created for room 101', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T19:03:28.313' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2058, N'DEPOSIT_PAYMENT', 3044, 2004, N'Deposit payment received for reservation #3044 - Amount: 110000.0 (10% of total)', CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-06-28T19:03:36.783' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2059, N'CHECK_IN', 3045, 2, N'Checked in guest to room 104', NULL, CAST(N'2025-06-29T17:34:44.917' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2060, N'RESERVATION_CREATE', 3046, 1002, N'New reservation created for room 101', CAST(750000.00 AS Decimal(10, 2)), CAST(N'2025-06-29T18:10:22.277' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2061, N'DEPOSIT_PAYMENT', 3046, 1002, N'Deposit payment received for reservation #3046 - Amount: 75000.0 (10% of total)', CAST(75000.00 AS Decimal(10, 2)), CAST(N'2025-06-29T18:10:30.100' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2062, N'CHECK_IN', 3046, 2, N'Checked in guest to room 101', NULL, CAST(N'2025-06-29T18:12:32.990' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2063, N'CHECK_IN', 2030, 2, N'Checked in guest to room 105', NULL, CAST(N'2025-07-01T10:29:36.697' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2064, N'RESERVATION_CREATE', 3047, 2004, N'New reservation created for room 102', CAST(900000.00 AS Decimal(10, 2)), CAST(N'2025-07-01T21:02:33.487' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2065, N'DEPOSIT_PAYMENT', 3047, 2004, N'Deposit payment received for reservation #3047 - Amount: 90000.0 (10% of total)', CAST(90000.00 AS Decimal(10, 2)), CAST(N'2025-07-01T21:03:10.110' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2066, N'RESERVATION_CREATE', 3048, 2004, N'New reservation created for room 303', CAST(1400000.00 AS Decimal(10, 2)), CAST(N'2025-07-01T23:22:22.410' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2067, N'DEPOSIT_PAYMENT', 3048, 2004, N'Deposit payment received for reservation #3048 - Amount: 140000.0 (10% of total)', CAST(140000.00 AS Decimal(10, 2)), CAST(N'2025-07-01T23:22:27.930' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2068, N'RESERVATION_CREATE', 3049, 2004, N'New reservation created for room 102', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T21:17:27.803' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2069, N'DEPOSIT_PAYMENT', 3049, 2004, N'Deposit payment received for reservation #3049 - Amount: 55000.0 (10% of total)', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T21:17:47.377' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2070, N'RESERVATION_CREATE', 3050, 2004, N'New reservation created for room 303', CAST(900000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T21:26:29.000' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2071, N'DEPOSIT_PAYMENT', 3050, 2004, N'Deposit payment received for reservation #3050 - Amount: 90000.0 (10% of total)', CAST(90000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T22:01:03.643' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2072, N'RESERVATION_UPDATE', 3043, 2, N'Updated booking #3043', NULL, CAST(N'2025-07-03T22:39:48.067' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2073, N'CHECK_IN', 3032, 2, N'Checked in guest to room 101', NULL, CAST(N'2025-07-04T07:37:34.403' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2074, N'RESERVATION_CREATE', 3051, 2004, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-04T08:19:53.160' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2075, N'RESERVATION_UPDATE', 3043, 2, N'Updated booking #3043', NULL, CAST(N'2025-07-04T08:42:18.897' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2076, N'RESERVATION_UPDATE', 3043, 2, N'Updated booking #3043', NULL, CAST(N'2025-07-04T08:44:25.913' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2077, N'RESERVATION_CREATE', 3052, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-08T23:32:17.143' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2078, N'RESERVATION_CREATE', 3053, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-09T01:43:13.600' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2079, N'RESERVATION_CREATE', 3054, 3006, N'New reservation created for room 205', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-09T01:43:13.670' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2080, N'RESERVATION_CREATE', 3055, 3006, N'New reservation created for room 103', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-09T01:43:13.770' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2081, N'DEPOSIT_PAYMENT', 3053, 3006, N'Deposit payment received for reservation #3053 - Amount: 88000.0 (10% of total)', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-09T01:43:23.770' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2082, N'RESERVATION_CREATE', 3056, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.340' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2083, N'RESERVATION_CREATE', 3057, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.467' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2084, N'RESERVATION_CREATE', 3058, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.587' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2085, N'RESERVATION_CREATE', 3059, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.700' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2086, N'RESERVATION_CREATE', 3060, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.833' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2087, N'RESERVATION_CREATE', 3061, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:08.950' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2088, N'RESERVATION_CREATE', 3062, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:09.077' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2089, N'RESERVATION_CREATE', 3063, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:09.187' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2090, N'RESERVATION_CREATE', 3064, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:09.300' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2091, N'RESERVATION_CREATE', 3065, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:09.437' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2092, N'DEPOSIT_PAYMENT', 3056, 3006, N'Deposit payment received for reservation #3056 - Amount: 88000.0 (10% of total)', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T01:05:16.930' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2093, N'RESERVATION_CREATE', 3066, 3006, N'New reservation created for room 205', CAST(6160000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T23:41:21.133' AS DateTime), N'0:0:0:0:0:0:0:1')
GO
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2094, N'RESERVATION_CREATE', 3067, 3006, N'New reservation created for room 103', CAST(6930000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T23:41:21.290' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2095, N'DEPOSIT_PAYMENT', 3066, 3006, N'Deposit payment received for reservation #3066 - Amount: 616000.0 (10% of total)', CAST(616000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T23:41:48.167' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2096, N'RESERVATION_CREATE', 3068, 3006, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:29:28.823' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2097, N'RESERVATION_CREATE', 3069, 3006, N'New reservation created for room 304', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:29:28.957' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2098, N'RESERVATION_CREATE', 3070, 3006, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:37:28.947' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2099, N'RESERVATION_CREATE', 3071, 3006, N'New reservation created for room 203', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:37:29.060' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2100, N'DEPOSIT_PAYMENT', 3070, 3006, N'Deposit payment received for reservation #3070 - Amount: 121000.0 (group deposit)', CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:38:38.570' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2101, N'DEPOSIT_PAYMENT', 3071, 3006, N'Deposit payment received for reservation #3071 - Amount: 121000.0 (group deposit)', CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:38:38.677' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2102, N'DEPOSIT_PAYMENT', 3070, 3006, N'Deposit payment received for reservation #3070 - Amount: 121000.0 (group deposit)', CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:38:43.203' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2103, N'DEPOSIT_PAYMENT', 3071, 3006, N'Deposit payment received for reservation #3071 - Amount: 121000.0 (group deposit)', CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T22:38:43.293' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2104, N'RESERVATION_CREATE', 3072, 3006, N'New reservation created for room 304', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T23:34:52.300' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2105, N'RESERVATION_CREATE', 3073, 3006, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T23:34:52.410' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2106, N'DEPOSIT_PAYMENT', 3072, 3006, N'Deposit payment received for reservation #3072 - Amount: 115500.0 (group deposit)', CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-11T23:37:05.960' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2107, N'DEPOSIT_PAYMENT', 3073, 3006, N'Deposit payment received for reservation #3073 - Amount: 115500.0 (group deposit)', CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-11T23:37:06.033' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2108, N'RESERVATION_CREATE', 3074, 3006, N'New reservation created for room 304', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:53.940' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2109, N'RESERVATION_CREATE', 3075, 3006, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:01:02.730' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2110, N'DEPOSIT_PAYMENT', 3074, 3006, N'Deposit payment received for reservation #3074 - Amount: 115500.0', CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:21:16.503' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2111, N'DEPOSIT_PAYMENT', 3075, 3006, N'Deposit payment received for reservation #3075 - Amount: 115500.0', CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:21:16.870' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2112, N'RESERVATION_CREATE', 3076, 1002, N'New reservation created for room 205', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:33:57.703' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2113, N'RESERVATION_CREATE', 3077, 1002, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:34:02.750' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2114, N'DEPOSIT_PAYMENT', 3076, 1002, N'Deposit payment received for reservation #3076 - Amount: 110000.0', CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:19:09.987' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2115, N'DEPOSIT_PAYMENT', 3077, 1002, N'Deposit payment received for reservation #3077 - Amount: 110000.0', CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:19:10.073' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2116, N'RESERVATION_CREATE', 3078, 3006, N'New reservation created for room 502', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:35:59.660' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2117, N'RESERVATION_CREATE', 3079, 3006, N'New reservation created for room 103', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:35:59.793' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2118, N'DEPOSIT_PAYMENT', 3078, 3006, N'Deposit payment received for reservation #3078 - Amount: 165000.0', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:45:15.507' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2119, N'DEPOSIT_PAYMENT', 3079, 3006, N'Deposit payment received for reservation #3079 - Amount: 99000.0', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T01:45:15.590' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2120, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 2 x1', NULL, CAST(N'2025-07-13T02:41:57.590' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2121, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 1002', NULL, CAST(N'2025-07-13T02:58:42.250' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2122, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 1003', NULL, CAST(N'2025-07-13T02:58:42.337' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2123, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 1011', NULL, CAST(N'2025-07-13T02:59:32.160' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2124, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 1014', NULL, CAST(N'2025-07-13T02:59:32.250' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2125, N'SERVICE_ORDERED', 2023, 1002, N'Ordered service 1002', NULL, CAST(N'2025-07-13T02:59:42.560' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2126, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1006', NULL, CAST(N'2025-07-13T23:07:05.160' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2127, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1005', NULL, CAST(N'2025-07-13T23:20:05.320' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2128, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1003', NULL, CAST(N'2025-07-13T23:24:29.603' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (2129, N'RESERVATION_CREATE', 3080, 3007, N'New reservation created for room 501', CAST(3300000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T02:07:39.500' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3120, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1002', NULL, CAST(N'2025-07-14T08:11:47.313' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3121, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1003', NULL, CAST(N'2025-07-14T08:11:47.407' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3122, N'RESERVATION_CREATE', 4080, 1002, N'New reservation created for room 504', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T08:36:58.020' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3123, N'DEPOSIT_PAYMENT', 4080, 1002, N'Deposit payment received for reservation #4080 - Amount: 165000.0', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T08:37:53.957' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3124, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 2', NULL, CAST(N'2025-07-14T08:39:26.830' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3125, N'SERVICE_ORDERED', 2012, 1002, N'Ordered service 1002', NULL, CAST(N'2025-07-14T08:39:26.890' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3126, N'PAYMENT', 2, 2, N'Payment status updated to SUCCESS', CAST(3200000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T21:15:20.473' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3127, N'PAYMENT', 2, 2, N'Payment status updated to SUCCESS', CAST(3200000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T21:15:26.237' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3128, N'PAYMENT', 3069, 2, N'Payment status updated to SUCCESS', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T21:19:34.790' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3129, N'PAYMENT', 3069, 2, N'Payment status updated to FAILED', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T21:19:42.567' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3130, N'RESERVATION_CREATE', 4081, 1002, N'New reservation created for room 304', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T22:39:16.093' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3131, N'DEPOSIT_PAYMENT', 4081, 1002, N'Deposit payment received for reservation #4081 - Amount: 99000.0', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T22:40:15.203' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3132, N'PAYMENT', 3068, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:04:07.173' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3133, N'PAYMENT', 3068, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:04:42.927' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3134, N'RESERVATION_CREATE', 4082, 1002, N'New reservation created for room 504', CAST(3300000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:17:18.500' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3135, N'PAYMENT', 4082, 2, N'Payment status updated to SUCCESS', CAST(3300000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:24:11.007' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3136, N'PAYMENT', 3065, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:25:42.710' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3137, N'RESERVATION_CREATE', 4083, 1002, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:48:35.600' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3138, N'DEPOSIT_PAYMENT', 4083, 1002, N'Deposit payment pending for reservation #4083 - Amount: 132000.0', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:49:28.987' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3139, N'PAYMENT', 4083, 2, N'Payment status updated to SUCCESS', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:50:02.723' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3140, N'PAYMENT', 3067, 2, N'Payment status updated to SUCCESS', CAST(6930000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:51:27.380' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3141, N'PAYMENT', 3064, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:59:11.757' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3142, N'PAYMENT', 3064, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T23:59:15.773' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3143, N'RESERVATION_CREATE', 4084, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:17:39.350' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3144, N'DEPOSIT_PAYMENT', 4084, 1002, N'Deposit payment pending for reservation #4084 - Amount: 55000.0', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:18:06.543' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3145, N'PAYMENT', 4084, 2, N'Payment status updated to SUCCESS', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:18:37.993' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3146, N'PAYMENT', 4084, 2, N'Payment status updated to SUCCESS', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:29:08.570' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3147, N'RESERVATION_CREATE', 4085, 1002, N'New reservation created for room 102', CAST(1100000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:29:54.890' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3148, N'DEPOSIT_PAYMENT', 4085, 1002, N'Deposit payment pending for reservation #4085 - Amount: 110000.0', CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:30:10.110' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3149, N'PAYMENT', 4085, 2, N'Payment status updated to SUCCESS', CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:30:32.930' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3150, N'RESERVATION_CREATE', 4086, 1002, N'New reservation created for room 101', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:41:04.080' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3151, N'DEPOSIT_PAYMENT', 4086, 1002, N'Deposit payment pending for reservation #4086 - Amount: 55000.0', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:41:23.843' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3152, N'PAYMENT', 4086, 2, N'Payment status updated to SUCCESS', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:41:46.897' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3153, N'RESERVATION_CREATE', 4087, 1002, N'New reservation created for room 303', CAST(550000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:43:31.333' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3154, N'DEPOSIT_PAYMENT', 4087, 1002, N'Deposit payment pending for reservation #4087 - Amount: 55000.0', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:43:44.447' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3155, N'PAYMENT', 4087, 2, N'Payment status updated to SUCCESS', CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:44:04.240' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3156, N'RESERVATION_CREATE', 4088, 1002, N'New reservation created for room 504', CAST(1650000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:54:35.143' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3157, N'DEPOSIT_PAYMENT', 4088, 1002, N'Deposit payment pending for reservation #4088 - Amount: 165000.0', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:55:07.683' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3158, N'PAYMENT', 4088, 2, N'Payment status updated to SUCCESS', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:55:42.040' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (3159, N'PAYMENT', 4088, 2, N'Payment status updated to SUCCESS', CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:55:48.270' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4143, N'RESERVATION_CREATE', 5085, 3005, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T10:27:01.653' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4144, N'DEPOSIT_PAYMENT', 5085, 3005, N'Deposit payment pending for reservation #5085 - Amount: 132000.0', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T10:43:53.500' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4145, N'PAYMENT', 5085, 2, N'Payment status updated to SUCCESS', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T10:45:35.010' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4146, N'PAYMENT', 5085, 2, N'Payment status updated to SUCCESS', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T10:45:48.120' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4147, N'RESERVATION_CREATE', 5086, 3005, N'New reservation created for room 103', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:16:03.383' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4148, N'RESERVATION_CREATE', 5087, 3005, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:16:03.510' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4149, N'RESERVATION_CREATE', 5088, 3005, N'New reservation created for room 103', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:17:10.087' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4150, N'RESERVATION_CREATE', 5089, 3005, N'New reservation created for room 205', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:17:10.197' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4151, N'DEPOSIT_PAYMENT', 5088, 3005, N'Deposit payment pending for reservation #5088 - Amount: 99000.0', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:24:56.237' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4152, N'DEPOSIT_PAYMENT', 5089, 3005, N'Deposit payment pending for reservation #5089 - Amount: 88000.0', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:24:56.333' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4153, N'DEPOSIT_PAYMENT', 5088, 3005, N'Deposit payment pending for reservation #5088 - Amount: 99000.0', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:27:00.487' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4154, N'DEPOSIT_PAYMENT', 5089, 3005, N'Deposit payment pending for reservation #5089 - Amount: 88000.0', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:27:00.583' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4155, N'PAYMENT', 5089, 2, N'Payment status updated to SUCCESS', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:28:56.530' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4156, N'PAYMENT', 5088, 2, N'Payment status updated to SUCCESS', CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:28:56.717' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4157, N'PAYMENT', 5087, 2, N'Payment status updated to FAILED', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:51:31.527' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4158, N'PAYMENT', 5086, 2, N'Payment status updated to FAILED', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T11:51:38.520' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (4159, N'PAYMENT', 3059, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-16T20:31:17.620' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (5159, N'CHECK_IN', 4084, 2, N'Checked in guest to room 101', NULL, CAST(N'2025-07-17T14:26:34.027' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (5160, N'CHECK_IN', 4087, 2, N'Checked in guest to room 303', NULL, CAST(N'2025-07-17T20:48:01.700' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (5161, N'SERVICE_ADDED', 4084, 2, N'Added Couples Spa Experience x1', CAST(3000000.00 AS Decimal(10, 2)), CAST(N'2025-07-17T22:24:03.900' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (5162, N'SERVICE_ADDED', 4087, 2, N'Added Room Service x1', CAST(50000.00 AS Decimal(10, 2)), CAST(N'2025-07-17T22:26:43.273' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (6160, N'CHECK_IN', 5090, 2, N'Checked in guest to room 102', NULL, CAST(N'2025-07-18T09:22:26.660' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7160, N'PAYMENT', 3046, 2, N'Refund processed: 2044', CAST(75000.00 AS Decimal(10, 2)), CAST(N'2025-07-19T00:10:30.167' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7161, N'PAYMENT', 3046, 2, N'Refund processed: 12212', CAST(75000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T18:12:36.203' AS DateTime), N'127.0.0.1')
GO
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7162, N'RESERVATION_CREATE', 6090, 1002, N'New reservation created for room 305', CAST(1320000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T20:28:22.677' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7163, N'DEPOSIT_PAYMENT', 6090, 1002, N'Deposit payment pending for reservation #6090 - Amount: 132000.0', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T20:28:38.780' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7164, N'PAYMENT', 6090, 2, N'Payment status updated to SUCCESS', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T20:30:39.747' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7165, N'PAYMENT', 6090, 2, N'Payment status updated to SUCCESS', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T20:30:45.390' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7166, N'CHECK_IN', 6090, 2, N'Checked in guest to room 305', NULL, CAST(N'2025-07-20T20:31:59.223' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7167, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1006', NULL, CAST(N'2025-07-20T20:32:31.387' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7168, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1021', NULL, CAST(N'2025-07-20T22:33:04.830' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7169, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1012', NULL, CAST(N'2025-07-20T22:33:04.950' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7170, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 2', NULL, CAST(N'2025-07-20T23:13:40.530' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7171, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1006', NULL, CAST(N'2025-07-20T23:33:27.720' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7172, N'SERVICE_CANCELLED', 6090, 1002, N'Cancelled service 4015', NULL, CAST(N'2025-07-21T00:36:01.637' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7173, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1006', NULL, CAST(N'2025-07-21T00:36:52.530' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (7174, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1006', NULL, CAST(N'2025-07-21T00:36:52.680' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (8168, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1015', NULL, CAST(N'2025-07-21T08:50:43.270' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (8169, N'SERVICE_ORDERED', 6090, 1002, N'Requested service 1015', NULL, CAST(N'2025-07-21T08:50:43.487' AS DateTime), NULL)
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9168, N'RESERVATION_CREATE', 6091, 1002, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:17:23.147' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9169, N'RESERVATION_CREATE', 6092, 1002, N'New reservation created for room 205', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:17:23.250' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9170, N'DEPOSIT_PAYMENT', 6091, 1002, N'Deposit payment pending for reservation #6091 - Amount: 88000.0', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:17:55.867' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9171, N'DEPOSIT_PAYMENT', 6092, 1002, N'Deposit payment pending for reservation #6092 - Amount: 88000.0', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:17:55.963' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9172, N'RESERVATION_CREATE', 6093, 1002, N'New reservation created for room 203', CAST(2200000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:19:22.633' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9173, N'PAYMENT', 6092, 2, N'Payment status updated to SUCCESS', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:21:40.110' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9174, N'PAYMENT', 6091, 2, N'Payment status updated to SUCCESS', CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:21:41.890' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9175, N'RESERVATION_CANCEL', 6093, 2, N'Cancelled reservation #6093', NULL, CAST(N'2025-07-21T16:22:14.727' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9176, N'PAYMENT', 6093, 2, N'Payment status updated to FAILED', CAST(2200000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:22:44.480' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9177, N'RESERVATION_CREATE', 6094, 2004, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:26:34.307' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9178, N'PAYMENT', 6094, 2, N'Payment status updated to FAILED', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:30:31.300' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9179, N'RESERVATION_CANCEL', 6094, 2, N'Cancelled reservation #6094', NULL, CAST(N'2025-07-21T16:30:48.243' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9180, N'RESERVATION_CREATE', 6095, 1002, N'New reservation created for room 203', CAST(2200000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:39:36.517' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9181, N'CHECK_IN', 6091, 2, N'Checked in guest to room 201', NULL, CAST(N'2025-07-21T16:40:34.433' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9182, N'CHECK_IN', 6092, 2, N'Checked in guest to room 205', NULL, CAST(N'2025-07-21T16:40:51.533' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9183, N'RESERVATION_CREATE', 6096, 2004, N'New reservation created for room 105', CAST(3300000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:48:30.293' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9184, N'RESERVATION_CREATE', 6097, 1002, N'New reservation created for room 104', CAST(2640000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:59:47.323' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9185, N'RESERVATION_CREATE', 6098, 1002, N'New reservation created for room 201', CAST(1760000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:59:47.450' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9186, N'DEPOSIT_PAYMENT', 6097, 1002, N'Cash payment pending for reservation #6097', CAST(0.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:59:54.947' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9187, N'DEPOSIT_PAYMENT', 6098, 1002, N'Cash payment pending for reservation #6098', CAST(0.00 AS Decimal(10, 2)), CAST(N'2025-07-21T16:59:55.083' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9188, N'RESERVATION_CREATE', 6099, 1002, N'New reservation created for room 201', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:02:42.957' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9189, N'DEPOSIT_PAYMENT', 6099, 1002, N'Cash payment pending for reservation #6099', CAST(0.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:03:03.013' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9190, N'PAYMENT', 6095, 2, N'Payment status updated to FAILED', CAST(2200000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:14:07.590' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9191, N'RESERVATION_CANCEL', 6096, 2, N'Cancelled reservation #6096', NULL, CAST(N'2025-07-21T17:14:21.497' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9192, N'RESERVATION_CANCEL', 6095, 2, N'Cancelled reservation #6095', NULL, CAST(N'2025-07-21T17:14:25.890' AS DateTime), N'0:0:0:0:0:0:0:1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9193, N'PAYMENT', 6099, 2, N'Payment status updated to SUCCESS', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:22:12.427' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9194, N'PAYMENT', 6098, 2, N'Payment status updated to SUCCESS', CAST(1760000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:22:16.137' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9195, N'PAYMENT', 6097, 2, N'Payment status updated to SUCCESS', CAST(2640000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:22:18.403' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9196, N'PAYMENT', 3055, 2, N'Payment status updated to FAILED', CAST(990000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:30:14.177' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9197, N'PAYMENT', 3054, 2, N'Payment status updated to FAILED', CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:30:27.223' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Activities] ([Id], [Type], [ReservationId], [UserId], [Description], [Amount], [Timestamp], [IpAddress]) VALUES (9198, N'PAYMENT', 6090, 2, N'Refund processed: 11222', CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T17:40:28.080' AS DateTime), N'127.0.0.1')
SET IDENTITY_INSERT [dbo].[Activities] OFF
GO
SET IDENTITY_INSERT [dbo].[Blogs] ON 

INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (1, N'Discover Spa & Wellness at Luxury Hotel', N'discover-spa-wellness-luxury-hotel', N'Luxury Hotel proudly offers world-class Spa & Wellness services:
1. Relaxing massage treatments
2. Professional skincare therapies
3. Premium products and facilities
Book your appointment and enjoy moments of pure relaxation!', 1, N'PUBLISHED', N'spa-wellness.jpg', CAST(N'2025-06-18T21:59:21.520' AS DateTime), CAST(N'2025-06-18T21:59:21.520' AS DateTime))
INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (2, N'Simple Online Booking Guide', N'simple-online-booking-guide', N'Book your stay in just 3 easy steps:
1. Select check-in and check-out dates
2. Choose your preferred room type
3. Confirm and make payment
You will receive an instant confirmation email!', 2, N'PUBLISHED', N'booking-guide.jpg', CAST(N'2025-06-18T21:59:21.520' AS DateTime), CAST(N'2025-06-18T21:59:21.520' AS DateTime))
INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (1002, N'5 Tips for Perfect Family Vacation', N'5-tips-perfect-family-vacation', N'Make your family vacation memorable:
- Choose Family or Connecting rooms
- Plan activities for all family members
- Book Kids Club services for children
- Enjoy family dining at our restaurant
- Capture precious moments together', 1, N'PUBLISHED', N'family-vacation.jpg', CAST(N'2025-06-19T21:06:26.180' AS DateTime), CAST(N'2025-06-19T21:06:26.180' AS DateTime))
INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (1003, N'Why Choose Executive Room for Business Trips', N'why-choose-executive-room-business-trips', N'Executive Room benefits:
• Dedicated work desk
• Free Executive Lounge access
• Priority room upgrades
• Business center services
Perfect for productive business stays!', 2, N'PUBLISHED', N'executive-room.jpg', CAST(N'2025-06-19T21:06:26.180' AS DateTime), CAST(N'2025-06-19T21:06:26.180' AS DateTime))
INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (1004, N'Quick Check-in Tips and Free Late Check-out', N'quick-checkin-late-checkout-tips', N'Get free late check-out:
1. Contact reception before 12 noon
2. Send request via email or hotline
3. Enjoy late check-out until 2 PM
Convenient and flexible for your schedule!', 1, N'PUBLISHED', N'checkin-tips.jpg', CAST(N'2025-06-19T21:06:26.180' AS DateTime), CAST(N'2025-06-26T23:05:52.497' AS DateTime))
INSERT [dbo].[Blogs] ([Id], [Title], [Slug], [Content], [AuthorId], [Status], [ImageUrl], [CreatedAt], [UpdatedAt]) VALUES (2002, N'how to booking hotel to price discount', N'how-to-booking-hotel-to-price-discount', N'12321321', 1, N'ARCHIVED', NULL, CAST(N'2025-07-16T22:14:14.757' AS DateTime), CAST(N'2025-07-16T22:15:01.097' AS DateTime))
SET IDENTITY_INSERT [dbo].[Blogs] OFF
GO
SET IDENTITY_INSERT [dbo].[CheckInDetails] ON 

INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (1, 3045, N'PASSPORT', N'123123123123213', 2, NULL, CAST(500000.00 AS Decimal(10, 2)), 1, N'102', N'', CAST(N'2025-06-29T17:34:44.683' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (2, 3046, N'NATIONAL_ID', N'022204006060', 2, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'101', N'', CAST(N'2025-06-29T18:12:32.817' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (3, 2030, N'PASSPORT', N'022204006060', 1, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'101', N'', CAST(N'2025-07-01T10:29:36.390' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (4, 3032, N'PASSPORT', N'022204006060', 1, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'101', N'', CAST(N'2025-07-04T07:37:34.217' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (5, 4084, N'PASSPORT', N'022204006060', 2, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'102', N'', CAST(N'2025-07-17T14:26:33.803' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (6, 4087, N'NATIONAL_ID', N'022204006060', 3, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'302', N'', CAST(N'2025-07-17T20:48:01.483' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (1006, 5090, N'PASSPORT', N'123123123123213', 3, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'102', N'', CAST(N'2025-07-18T09:22:26.527' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (2006, 6090, N'PASSPORT', N'1231231231', 3, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'301', N'', CAST(N'2025-07-20T20:31:59.047' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (2007, 6091, N'PASSPORT', N'123123123123213', 0, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'', N'', CAST(N'2025-07-21T16:40:34.260' AS DateTime), 2)
INSERT [dbo].[CheckInDetails] ([Id], [ReservationId], [IdType], [IdNumber], [AdditionalGuests], [SpecialRequests], [SecurityDeposit], [KeyCards], [KeyCardNumbers], [CheckInNotes], [CheckInTime], [CheckInBy]) VALUES (2008, 6092, N'PASSPORT', N'123123123123213', 0, NULL, CAST(500000.00 AS Decimal(10, 2)), 2, N'', N'', CAST(N'2025-07-21T16:40:51.357' AS DateTime), 2)
SET IDENTITY_INSERT [dbo].[CheckInDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[Comments] ON 

INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (1, 1, N'John Smith', N'johnsmith@gmail.com', N'Very helpful article about spa services!', N'APPROVED', CAST(N'2025-06-18T21:59:21.540' AS DateTime))
INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (2, 1, N'Emily Johnson', N'emilyjohnson@gmail.com', N'The spa here is absolutely wonderful.', N'APPROVED', CAST(N'2025-06-18T21:59:21.540' AS DateTime))
INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (3, 2, N'Michael Brown', N'michaelbrown@gmail.com', N'Thanks for the detailed booking guide.', N'APPROVED', CAST(N'2025-06-18T21:59:21.540' AS DateTime))
INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (1002, 1002, N'trieu', N'trieulvhe1871678@fpt.edu.vn', N'iss goood', N'APPROVED', CAST(N'2025-06-19T21:07:43.860' AS DateTime))
INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (1003, 1002, N'trieu', N'trieulvhe1871678@fpt.edu.vn', N'12321213', N'PENDING', CAST(N'2025-06-19T21:30:02.130' AS DateTime))
INSERT [dbo].[Comments] ([Id], [BlogId], [AuthorName], [Email], [Content], [Status], [CreatedAt]) VALUES (1004, 1002, N'Le Van Trieu', N'trieulvhe187167@fpt.edu.v', N'mot trai nghiem that tuyet voi', N'APPROVED', CAST(N'2025-06-19T21:43:30.423' AS DateTime))
SET IDENTITY_INSERT [dbo].[Comments] OFF
GO
SET IDENTITY_INSERT [dbo].[ContactMessages] ON 

INSERT [dbo].[ContactMessages] ([Id], [Name], [Email], [Phone], [Message], [CreatedAt], [feedbackId]) VALUES (1, N'Le Van Trieu', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'Hello I want to booking luxury Hotel 
How???', CAST(N'2025-07-01T23:59:24.543' AS DateTime), NULL)
INSERT [dbo].[ContactMessages] ([Id], [Name], [Email], [Phone], [Message], [CreatedAt], [feedbackId]) VALUES (2, N'Le Van Trieu', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'helllo peter', CAST(N'2025-07-03T18:14:25.887' AS DateTime), NULL)
INSERT [dbo].[ContactMessages] ([Id], [Name], [Email], [Phone], [Message], [CreatedAt], [feedbackId]) VALUES (3, N'Hotel Staff', N'staff@luxuryhotel.com', N'(+84) 3 1234 5678', N'Subject: Thank You for Your Feedback

Message: Dear Le Van Trieu,

Thank you for taking the time to share your feedback with us. We truly appreciate your input and value your experience at our hotel.

Your feedback helps us improve our services and ensure that all our guests have the best possible stay.

We look forward to welcoming you back in the future.

Best regards,
Luxury Hotel Team

Related to Feedback ID: 1002', CAST(N'2025-07-22T01:41:00.350' AS DateTime), 1002)
SET IDENTITY_INSERT [dbo].[ContactMessages] OFF
GO
SET IDENTITY_INSERT [dbo].[CustomerDetails] ON 

INSERT [dbo].[CustomerDetails] ([Id], [UserId], [IdType], [IdNumber], [DateOfBirth], [Gender], [Address], [City], [Country], [LoyaltyPoints], [MembershipLevel], [IsVIP], [CreatedAt], [UpdatedAt]) VALUES (1, 10, N'PASSPORT', N'US123456789', CAST(N'1985-05-15' AS Date), N'MALE', N'123 Main St', N'New York', N'USA', 2500, N'GOLD', 0, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-18T21:59:20.890' AS DateTime))
INSERT [dbo].[CustomerDetails] ([Id], [UserId], [IdType], [IdNumber], [DateOfBirth], [Gender], [Address], [City], [Country], [LoyaltyPoints], [MembershipLevel], [IsVIP], [CreatedAt], [UpdatedAt]) VALUES (2, 11, N'PASSPORT', N'GB987654321', CAST(N'1990-08-22' AS Date), N'FEMALE', N'456 Oxford St', N'London', N'UK', 1200, N'SILVER', 0, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-18T21:59:20.893' AS DateTime))
INSERT [dbo].[CustomerDetails] ([Id], [UserId], [IdType], [IdNumber], [DateOfBirth], [Gender], [Address], [City], [Country], [LoyaltyPoints], [MembershipLevel], [IsVIP], [CreatedAt], [UpdatedAt]) VALUES (3, 12, N'PASSPORT', N'CN888888888', CAST(N'1975-06-30' AS Date), N'MALE', N'888 Business Blvd', N'Singapore', N'Singapore', 15000, N'PLATINUM', 1, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-18T21:59:20.893' AS DateTime))
INSERT [dbo].[CustomerDetails] ([Id], [UserId], [IdType], [IdNumber], [DateOfBirth], [Gender], [Address], [City], [Country], [LoyaltyPoints], [MembershipLevel], [IsVIP], [CreatedAt], [UpdatedAt]) VALUES (1002, 1002, N'ID_CARD', N'022204006060', CAST(N'2004-06-17' AS Date), N'MALE', N'Lien Vi', N'Quang Ninh', N'VietNam', 30000, N'PLATINUM', 1, CAST(N'2025-06-29T01:35:39.980' AS DateTime), CAST(N'2025-07-13T00:49:51.230' AS DateTime))
INSERT [dbo].[CustomerDetails] ([Id], [UserId], [IdType], [IdNumber], [DateOfBirth], [Gender], [Address], [City], [Country], [LoyaltyPoints], [MembershipLevel], [IsVIP], [CreatedAt], [UpdatedAt]) VALUES (1003, 3005, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, N'BRONZE', 0, CAST(N'2025-07-04T09:23:09.420' AS DateTime), CAST(N'2025-07-15T07:56:41.830' AS DateTime))
SET IDENTITY_INSERT [dbo].[CustomerDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[EmailTemplates] ON 

INSERT [dbo].[EmailTemplates] ([Id], [TemplateName], [TemplateType], [Subject], [HtmlBody], [TextBody], [Language], [IsActive], [CreatedAt], [UpdatedAt], [CreatedBy]) VALUES (1, N'CHANGE_REQUEST_EMAIL', N'CHANGE_REQUEST', N'Action Required: Confirm Your Account Information Change', N'<html><body>
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
  </body></html>', N'Account Information Change Request

Dear {USER_NAME},

An administrator ({ADMIN_NAME}) has requested to change your {CHANGE_TYPE}.

Current {CHANGE_TYPE}: {OLD_VALUE}
Requested {CHANGE_TYPE}: {NEW_VALUE}
Reason: {REASON}

To approve this change, please visit: {VERIFICATION_LINK}

If you did not request this change, please contact support immediately.

This link expires on {EXPIRY_DATE}.

Best regards,
Hotel Management Team', N'en', 1, CAST(N'2025-06-22T23:26:18.337' AS DateTime), CAST(N'2025-06-22T23:26:18.337' AS DateTime), NULL)
INSERT [dbo].[EmailTemplates] ([Id], [TemplateName], [TemplateType], [Subject], [HtmlBody], [TextBody], [Language], [IsActive], [CreatedAt], [UpdatedAt], [CreatedBy]) VALUES (2, N'CHANGE_APPROVED', N'APPROVED', N'Your Account Information Has Been Updated', N'<html><body>
    <h2>Account Information Updated</h2>
    <p>Dear {USER_NAME},</p>
    <p>Your <strong>{CHANGE_TYPE}</strong> has been successfully updated.</p>
    <p><strong>New {CHANGE_TYPE}:</strong> {NEW_VALUE}</p>
    <p>If you did not approve this change, please contact support immediately.</p>
    <p>Best regards,<br>Hotel Management Team</p>
  </body></html>', N'Account Information Updated

Dear {USER_NAME},

Your {CHANGE_TYPE} has been successfully updated.
New {CHANGE_TYPE}: {NEW_VALUE}

If you did not approve this change, please contact support immediately.

Best regards,
Hotel Management Team', N'en', 1, CAST(N'2025-06-22T23:26:18.337' AS DateTime), CAST(N'2025-06-22T23:26:18.337' AS DateTime), NULL)
INSERT [dbo].[EmailTemplates] ([Id], [TemplateName], [TemplateType], [Subject], [HtmlBody], [TextBody], [Language], [IsActive], [CreatedAt], [UpdatedAt], [CreatedBy]) VALUES (3, N'CHANGE_REMINDER', N'REMINDER', N'Reminder: Pending Account Information Change', N'<html><body>
    <h2>Reminder: Pending Account Change</h2>
    <p>Dear {USER_NAME},</p>
    <p>You have a pending request to change your <strong>{CHANGE_TYPE}</strong>.</p>
    <p>Please click the link below to approve or reject this change:</p>
    <p><a href="{VERIFICATION_LINK}" style="background: #5a2b81; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">REVIEW CHANGE</a></p>
    <p>This request will expire on {EXPIRY_DATE}.</p>
    <p>Best regards,<br>Hotel Management Team</p>
  </body></html>', N'Reminder: Pending Account Change

Dear {USER_NAME},

You have a pending request to change your {CHANGE_TYPE}.

Please visit: {VERIFICATION_LINK}

This request expires on {EXPIRY_DATE}.

Best regards,
Hotel Management Team', N'en', 1, CAST(N'2025-06-22T23:26:18.337' AS DateTime), CAST(N'2025-06-22T23:26:18.337' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[EmailTemplates] OFF
GO
SET IDENTITY_INSERT [dbo].[EmployeeDetails] ON 

INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (1, 1, N'Management', CAST(N'2025-01-01' AS Date), CAST(30000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.537' AS DateTime), CAST(N'2025-06-29T16:34:44.023' AS DateTime), CAST(N'2004-06-17' AS Date), N'MALE', N'Hoa Lac', N'Ha Noi', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (2, 2, N'Front Office', CAST(N'2021-03-01' AS Date), CAST(15000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-29T15:46:46.207' AS DateTime), CAST(N'1992-07-22' AS Date), N'MALE', N'456 Le Loi Boulevard', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (3, 3, N'Housekeeping', CAST(N'2021-06-15' AS Date), CAST(12000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-29T15:46:46.223' AS DateTime), CAST(N'1988-11-10' AS Date), N'MALE', N'789 Tran Hung Dao Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (4, 4, N'Housekeeping', CAST(N'2022-01-01' AS Date), CAST(11000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-29T15:46:46.223' AS DateTime), CAST(N'1990-05-20' AS Date), N'FEMALE', N'321 Vo Van Tan Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (5, 5, N'Housekeeping', CAST(N'2022-01-01' AS Date), CAST(11000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-29T15:46:46.223' AS DateTime), CAST(N'1993-09-18' AS Date), N'MALE', N'654 Hai Ba Trung Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (6, 6, N'Housekeeping', CAST(N'2022-01-01' AS Date), CAST(11000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.543' AS DateTime), CAST(N'2025-06-29T15:46:46.223' AS DateTime), CAST(N'1991-12-25' AS Date), N'FEMALE', N'987 Nguyen Thi Minh Khai Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (7, 7, N'Housekeeping', CAST(N'2022-01-01' AS Date), CAST(11000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.547' AS DateTime), CAST(N'2025-06-29T15:46:46.223' AS DateTime), CAST(N'1989-04-30' AS Date), N'MALE', N'147 Pham Ngu Lao Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (8, 8, N'Housekeeping', CAST(N'2021-08-01' AS Date), CAST(13000000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.873' AS DateTime), CAST(N'2025-06-29T15:46:46.227' AS DateTime), CAST(N'1985-06-12' AS Date), N'FEMALE', N'258 Cong Quynh Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (9, 9, N'Housekeeping', CAST(N'2022-03-15' AS Date), CAST(12500000.00 AS Decimal(10, 2)), CAST(N'2025-06-18T21:59:20.877' AS DateTime), CAST(N'2025-06-29T15:46:46.227' AS DateTime), CAST(N'1987-02-28' AS Date), N'MALE', N'369 Dien Bien Phu Street', N'Ho Chi Minh City', N'Vietnam')
INSERT [dbo].[EmployeeDetails] ([Id], [UserId], [Department], [HireDate], [Salary], [CreatedAt], [UpdatedAt], [DateOfBirth], [Gender], [Address], [City], [Country]) VALUES (1002, 3004, N'Front Office', CAST(N'2023-01-15' AS Date), CAST(14000000.00 AS Decimal(10, 2)), CAST(N'2025-06-29T15:46:46.253' AS DateTime), CAST(N'2025-06-29T15:46:46.253' AS DateTime), CAST(N'1995-08-20' AS Date), N'FEMALE', N'789 Park Avenue', N'Ho Chi Minh City', N'Vietnam')
SET IDENTITY_INSERT [dbo].[EmployeeDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[Equipment] ON 

INSERT [dbo].[Equipment] ([Id], [Name], [Description], [CreatedAt]) VALUES (1, N'TV', N'32 inch Smart TV', CAST(N'2025-06-18T21:59:21.077' AS DateTime))
INSERT [dbo].[Equipment] ([Id], [Name], [Description], [CreatedAt]) VALUES (2, N'Mini Fridge', N'Mini refrigerator', CAST(N'2025-06-18T21:59:21.077' AS DateTime))
INSERT [dbo].[Equipment] ([Id], [Name], [Description], [CreatedAt]) VALUES (3, N'Coffee Maker', N'Nespresso machine', CAST(N'2025-06-18T21:59:21.077' AS DateTime))
INSERT [dbo].[Equipment] ([Id], [Name], [Description], [CreatedAt]) VALUES (4, N'Safe', N'Digital safe box', CAST(N'2025-06-18T21:59:21.077' AS DateTime))
INSERT [dbo].[Equipment] ([Id], [Name], [Description], [CreatedAt]) VALUES (5, N'Hair Dryer', N'Professional hair dryer', CAST(N'2025-06-18T21:59:21.077' AS DateTime))
SET IDENTITY_INSERT [dbo].[Equipment] OFF
GO
SET IDENTITY_INSERT [dbo].[Events] ON 

INSERT [dbo].[Events] ([Id], [Title], [Description], [Location], [StartAt], [EndAt], [Status], [ImageUrl], [CreatedBy], [CreatedAt], [UpdatedAt]) VALUES (1, N'Summer Music Festival', N'Join us for three days of live music by the poolside with local and international bands.', N'Hotel Central Garden', CAST(N'2025-07-15T14:00:00.000' AS DateTime), CAST(N'2025-07-17T23:00:00.000' AS DateTime), N'COMPLETED', N'event1.jpg', 1, CAST(N'2025-06-18T21:59:21.530' AS DateTime), CAST(N'2025-07-17T23:01:59.470' AS DateTime))
INSERT [dbo].[Events] ([Id], [Title], [Description], [Location], [StartAt], [EndAt], [Status], [ImageUrl], [CreatedBy], [CreatedAt], [UpdatedAt]) VALUES (1002, N'Poolside Movie Night', N'Outdoor screening of classic films under the stars with complimentary snacks.', N'Rooftop Pool Deck', CAST(N'2025-06-25T20:00:00.000' AS DateTime), CAST(N'2025-06-25T23:00:00.000' AS DateTime), N'COMPLETED', N'event3.jpg', 1, CAST(N'2025-06-25T23:28:09.963' AS DateTime), CAST(N'2025-06-25T23:28:09.963' AS DateTime))
INSERT [dbo].[Events] ([Id], [Title], [Description], [Location], [StartAt], [EndAt], [Status], [ImageUrl], [CreatedBy], [CreatedAt], [UpdatedAt]) VALUES (2002, N'Starlit Jazz Soirée on the Rooftop', N'Join us for an unforgettable evening under the stars at our Starlit Jazz Soirée on the Rooftop. From 7:00 PM to 10:00 PM every Friday, our sky-high lounge transforms into a chic jazz club, featuring live performances by a renowned quartet. Sip on signature cocktails—like our “Midnight Mojito” and “Silver Lining Spritz”—while you soak in panoramic city views and the smooth sounds of saxophone, piano, bass, and drums.

Whether you’re celebrating a special occasion or simply unwinding after a long week, the Starlit Jazz Soirée offers the perfect blend of sophistication and relaxation. Comfortable lounge seating, ambient lighting, and a curated canapé menu ensure that every moment feels like a private concert. Don’t miss this chance to elevate your weekend with soulful rhythms and starry skies!', N'Quang Ninh', CAST(N'2025-06-28T10:10:00.000' AS DateTime), CAST(N'2025-06-30T22:10:00.000' AS DateTime), N'COMPLETED', N'33990d89-9401-4cd8-bb50-ccc4e1c3d684.png', 1, CAST(N'2025-06-27T08:09:20.620' AS DateTime), CAST(N'2025-07-01T10:34:28.337' AS DateTime))
SET IDENTITY_INSERT [dbo].[Events] OFF
GO
SET IDENTITY_INSERT [dbo].[Feedback] ON 

INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1, 1, 10, 5, N'Clean and beautiful room, excellent service! Will definitely come back.', CAST(N'2025-06-18T21:59:21.550' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (2, 4, 11, 4, N'Good overall experience, but the check-in process was a bit slow.', CAST(N'2025-06-18T21:59:21.550' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (3, 5, 12, 5, N'Amazing VIP treatment! The staff went above and beyond.', CAST(N'2025-06-18T21:59:21.550' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1002, 3053, 3006, 5, N'Excellent service and friendly staff.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1003, 3054, 3006, 4, N'Room was spacious and well-furnished.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1004, 3055, 3006, 5, N'Very clean and tidy, enjoyed my stay.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1005, 3056, 3006, 4, N'Comfortable bed but bathroom could be bigger.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1006, 3057, 3006, 5, N'Great location, close to restaurants and shops.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1007, 3058, 3006, 4, N'Breakfast buffet was delicious and varied.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1008, 3059, 3006, 5, N'Wi-Fi connection was fast and reliable throughout.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1009, 3060, 3006, 4, N'Pool was clean but a bit crowded at peak hours.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1010, 3061, 3006, 5, N'Staff responded quickly to all requests.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1011, 3062, 3006, 4, N'Nice city view from the balcony.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1012, 3063, 3006, 5, N'Gym facilities were modern and well-maintained.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1013, 3064, 3006, 4, N'Quiet atmosphere, slept very well.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1014, 3065, 3006, 5, N'Housekeeping did a great job every day.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1015, 3066, 3006, 4, N'Check-in process was smooth and efficient.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1016, 3067, 3006, 5, N'Parking was convenient with ample space.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1017, 3068, 3006, 4, N'The minibar prices were reasonable.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1018, 3069, 3006, 5, N'Loved the decor and ambient lighting.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1019, 3070, 3006, 4, N'Overall value for money was excellent.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1020, 3071, 3006, 5, N'Spa services were top-notch.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1021, 3072, 3006, 4, N'Air conditioning worked perfectly.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1022, 3073, 3006, 5, N'Complimentary coffee machine in the lobby was lovely.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1023, 3074, 3006, 4, N'Elevator was slow during peak hours.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1024, 3075, 3006, 5, N'Shuttle service to the airport was very convenient.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1025, 3076, 1002, 4, N'Nice pool area but could use more lounge chairs.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1026, 3077, 1002, 5, N'Amazing breakfast selection with fresh options.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1027, 3078, 3006, 4, N'Good value for the price, comfortable stay overall.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1028, 3079, 3006, 5, N'Felt very safe and secure throughout the stay.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Feedback] ([Id], [ReservationId], [UserId], [Rating], [Comment], [CreatedAt], [disabled]) VALUES (1029, 3080, 3007, 5, N'Room so Luxury, perfect, services is so good and staff Trieu handsome.', CAST(N'2025-07-14T01:00:00.000' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Feedback] OFF
GO
SET IDENTITY_INSERT [dbo].[GroupBookings] ON 

INSERT [dbo].[GroupBookings] ([Id], [Name], [CreatedBy], [CreatedAt]) VALUES (1, N'FPT Corporation Team', 2, CAST(N'2025-06-18T21:59:20.997' AS DateTime))
INSERT [dbo].[GroupBookings] ([Id], [Name], [CreatedBy], [CreatedAt]) VALUES (2, N'Smith Family Reunion', 1, CAST(N'2025-06-18T21:59:20.997' AS DateTime))
SET IDENTITY_INSERT [dbo].[GroupBookings] OFF
GO
SET IDENTITY_INSERT [dbo].[HousekeepingTasks] ON 

INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1, 1, 3, N'DONE', N'Clean room after checkout', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-06-24T10:31:28.543' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (2, 2, 3, N'DONE', N'Room occupied - schedule cleaning for tomorrow morning', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-06-24T10:31:46.167' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (3, 4, 3, N'DONE', N'Replacing bedding and cleaning ceiling fan', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-07-01T22:08:16.010' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (4, 5, NULL, N'PENDING', N'VIP guest arriving - ensure premium amenities and fresh flowers', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-06-18T21:59:21.137' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (5, 11, 3, N'DONE', N'Preparing honeymoon suite - special decoration setup', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-07-01T22:08:51.833' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (6, 12, NULL, N'PENDING', N'Monthly deep clean scheduled - move furniture and clean behind', CAST(N'2025-06-18T21:59:21.137' AS DateTime), CAST(N'2025-06-18T21:59:21.137' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1002, 4, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-06-29T17:34:44.873' AS DateTime), CAST(N'2025-06-29T17:34:44.873' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1003, 1, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-06-29T18:12:32.937' AS DateTime), CAST(N'2025-06-29T18:12:32.937' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1004, 5, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-01T10:29:36.633' AS DateTime), CAST(N'2025-07-01T10:29:36.633' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1005, 1, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-04T07:37:34.323' AS DateTime), CAST(N'2025-07-04T07:37:34.323' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1006, 1, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-17T14:26:33.983' AS DateTime), CAST(N'2025-07-17T14:26:33.983' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (1007, 13, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-17T20:48:01.650' AS DateTime), CAST(N'2025-07-17T20:48:01.650' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (2007, 2, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-18T09:22:26.623' AS DateTime), CAST(N'2025-07-18T09:22:26.623' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (3007, 15, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-20T20:31:59.170' AS DateTime), CAST(N'2025-07-20T20:31:59.170' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (3008, 6, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-21T16:40:34.370' AS DateTime), CAST(N'2025-07-21T16:40:34.370' AS DateTime))
INSERT [dbo].[HousekeepingTasks] ([Id], [RoomId], [AssignedTo], [Status], [Notes], [CreatedAt], [UpdatedAt]) VALUES (3009, 10, NULL, N'PENDING', N'Guest checked in - daily cleaning required', CAST(N'2025-07-21T16:40:51.480' AS DateTime), CAST(N'2025-07-21T16:40:51.480' AS DateTime))
SET IDENTITY_INSERT [dbo].[HousekeepingTasks] OFF
GO
SET IDENTITY_INSERT [dbo].[InspectionItems] ON 

INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1, 1, N'Beer - Heineken 330ml', N'MINIBAR', 3, CAST(50000.00 AS Decimal(10, 2)), N'Guest consumed 3 beers')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2, 1, N'Coca Cola 330ml', N'MINIBAR', 2, CAST(30000.00 AS Decimal(10, 2)), NULL)
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (3, 3, N'Champagne - Moet & Chandon', N'MINIBAR', 1, CAST(2500000.00 AS Decimal(10, 2)), N'Premium champagne')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (4, 3, N'Whiskey - Johnnie Walker Blue', N'MINIBAR', 1, CAST(3000000.00 AS Decimal(10, 2)), N'Premium whiskey')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (5, 4, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (6, 4, N'Soft Drink - Coca Cola', N'MINIBAR', 1, CAST(30000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (7, 4, N'Water - 500ml', N'MINIBAR', 1, CAST(20000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1002, 1002, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1003, 1002, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1004, 1002, N'Soft Drink - Coca Cola', N'MINIBAR', 1, CAST(30000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1005, 1002, N'Water - 500ml', N'MINIBAR', 1, CAST(20000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (1006, 1002, N'Snacks', N'MINIBAR', 1, CAST(40000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2002, 2002, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2003, 2002, N'Soft Drink - Coca Cola', N'MINIBAR', 1, CAST(30000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2004, 2002, N'Snacks', N'MINIBAR', 1, CAST(40000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2005, 2002, N'Water - 500ml', N'MINIBAR', 1, CAST(20000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2006, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2007, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2008, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2009, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2010, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2011, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2012, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2013, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2014, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2015, 2003, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2016, 2004, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2017, 2004, N'Soft Drink - Coca Cola', N'MINIBAR', 1, CAST(30000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2018, 2004, N'Water - 500ml', N'MINIBAR', 1, CAST(20000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2019, 2005, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2020, 2005, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2021, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2022, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2023, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2024, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2025, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2026, 2006, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2027, 2006, N'Snacks', N'MINIBAR', 1, CAST(40000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2028, 2007, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2029, 2007, N'Soft Drink - Coca Cola', N'MINIBAR', 1, CAST(30000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2030, 2007, N'Snacks', N'MINIBAR', 1, CAST(40000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2031, 2008, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (2032, 2008, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (3030, 3011, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (3031, 3011, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
INSERT [dbo].[InspectionItems] ([Id], [InspectionId], [ItemName], [ItemCategory], [Quantity], [UnitPrice], [Notes]) VALUES (3032, 3017, N'Beer - Heineken 330ml', N'MINIBAR', 1, CAST(50000.00 AS Decimal(10, 2)), N'Quick add')
SET IDENTITY_INSERT [dbo].[InspectionItems] OFF
GO
SET IDENTITY_INSERT [dbo].[Notifications] ON 

INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1, 10, 1, N'BOOKING_CONFIRM', N'Your booking #1 has been confirmed.', CAST(N'2025-06-18T21:59:21.500' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2, 10, 1, N'CHECKIN_REMINDER', N'Reminder: You will check in on 2025-06-20.', CAST(N'2025-06-18T21:59:21.500' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3, 11, 2, N'BOOKING_PENDING', N'Your booking #2 is pending confirmation.', CAST(N'2025-06-18T21:59:21.500' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1002, 1002, 2002, N'BOOKING_CONFIRM', N'Your booking #2002 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T17:33:17.533' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1003, 1002, 2003, N'BOOKING_CONFIRM', N'Your booking #2003 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T17:42:31.560' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1004, 1002, 2004, N'BOOKING_CONFIRM', N'Your booking #2004 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:00:11.497' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1005, 1002, 2005, N'BOOKING_CONFIRM', N'Your booking #2005 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:01:49.580' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1006, 1002, 2006, N'BOOKING_CONFIRM', N'Your booking #2006 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:08:16.263' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1007, 1002, 2007, N'BOOKING_CONFIRM', N'Your booking #2007 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:10:32.950' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1008, 1002, 2008, N'BOOKING_CONFIRM', N'Your booking #2008 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:21:06.040' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1009, 1002, 2009, N'BOOKING_CONFIRM', N'Your booking #2009 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:31:23.673' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1010, 1002, 2010, N'BOOKING_CONFIRM', N'Your booking #2010 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T20:31:54.743' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1011, 1002, 2011, N'BOOKING_CONFIRM', N'Your booking #2011 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T22:37:29.230' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1012, 1002, 2012, N'BOOKING_CONFIRM', N'Your booking #2012 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T22:39:23.650' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1013, 1002, 2013, N'BOOKING_CONFIRM', N'Your booking #2013 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T22:44:00.203' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1014, 1002, 2014, N'BOOKING_CONFIRM', N'Your booking #2014 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T22:48:14.600' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1015, 1002, 2015, N'BOOKING_CONFIRM', N'Your booking #2015 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T22:51:56.580' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1016, 1002, 2016, N'BOOKING_CONFIRM', N'Your booking #2016 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:29:07.960' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1017, 1002, 2017, N'BOOKING_CONFIRM', N'Your booking #2017 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:36:18.393' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1018, 1002, 2018, N'BOOKING_CONFIRM', N'Your booking #2018 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:42:55.547' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1019, 1002, 2019, N'BOOKING_CONFIRM', N'Your booking #2019 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:43:59.197' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1020, 1002, 2020, N'BOOKING_CONFIRM', N'Your booking #2020 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:44:53.650' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1021, 1002, 2021, N'BOOKING_CONFIRM', N'Your booking #2021 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:50:49.160' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1022, 1002, 2022, N'BOOKING_CONFIRM', N'Your booking #2022 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-21T23:53:08.550' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1023, 1002, 2023, N'BOOKING_CONFIRM', N'Your booking #2023 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-22T00:51:16.807' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1024, 1002, 2024, N'BOOKING_CONFIRM', N'Your booking #2024 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-22T17:41:59.703' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1025, 2002, 2025, N'BOOKING_CONFIRM', N'Your booking #2025 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-23T07:33:55.923' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1026, 1002, 2027, N'BOOKING_CONFIRM', N'Your booking #2027 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-24T10:37:01.483' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1027, 2003, 2028, N'BOOKING_CONFIRM', N'Your booking #2028 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-24T11:38:26.850' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1028, 2004, 2029, N'BOOKING_CONFIRM', N'Your booking #2029 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-25T18:11:07.197' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (1029, 1002, 2030, N'BOOKING_CONFIRM', N'Your booking #2030 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-25T22:12:34.053' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2028, 10, 3029, N'BOOKING_CONFIRM', N'Your booking #3029 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T00:41:51.297' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2029, 10, 3030, N'BOOKING_CONFIRM', N'Your booking #3030 has been created. 10% deposit of 55,000₫ is required to confirm your reservation.', CAST(N'2025-06-28T01:25:23.423' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2030, 10, 3031, N'BOOKING_CONFIRM', N'Your booking #3031 has been created. 10% deposit of 55,000₫ is required to confirm your reservation.', CAST(N'2025-06-28T01:25:47.740' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2031, 11, 3032, N'BOOKING_CONFIRM', N'Your booking #3032 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T15:49:58.647' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2032, 11, 3033, N'BOOKING_CONFIRM', N'Your booking #3033 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T15:52:57.200' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2033, 11, 3034, N'BOOKING_CONFIRM', N'Your booking #3034 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T16:03:52.140' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2034, 11, 3035, N'BOOKING_CONFIRM', N'Your booking #3035 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T16:04:09.290' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2035, 10, 3036, N'BOOKING_CONFIRM', N'Your booking #3036 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T16:39:06.913' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2036, 10, 3037, N'BOOKING_CONFIRM', N'Your booking #3037 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T16:42:34.857' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2037, 1002, 3038, N'BOOKING_CONFIRM', N'Your booking #3038 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T17:17:57.283' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2038, 1002, 3039, N'BOOKING_CONFIRM', N'Your booking #3039 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T17:53:03.283' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2039, 1002, 3040, N'BOOKING_CONFIRM', N'Your booking #3040 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T18:05:18.137' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2040, 1002, 3041, N'BOOKING_CONFIRM', N'Your booking #3041 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T18:13:47.720' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2041, 2004, 3042, N'BOOKING_CONFIRM', N'Your booking #3042 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T18:18:20.467' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2042, 2004, 3043, N'BOOKING_CONFIRM', N'Your booking #3043 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T18:52:55.040' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2043, 2004, 3044, N'BOOKING_CONFIRM', N'Your booking #3044 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-28T19:03:28.363' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2044, 1002, 3046, N'BOOKING_CONFIRM', N'Your booking #3046 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-06-29T18:10:22.303' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2045, 2004, 3047, N'BOOKING_CONFIRM', N'Your booking #3047 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-01T21:02:33.510' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2046, 2004, 3048, N'BOOKING_CONFIRM', N'Your booking #3048 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-01T23:22:22.440' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2047, 2004, 3049, N'BOOKING_CONFIRM', N'Your booking #3049 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-03T21:17:27.830' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2048, 2004, 3050, N'BOOKING_CONFIRM', N'Your booking #3050 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-03T21:26:29.023' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2049, 2004, 3051, N'BOOKING_CONFIRM', N'Your booking #3051 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-04T08:19:53.230' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2050, 3006, 3052, N'BOOKING_CONFIRM', N'Your booking #3052 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-08T23:32:17.187' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2051, 3006, 3053, N'BOOKING_CONFIRM', N'Your booking #3053 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-09T01:43:13.620' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2052, 3006, 3054, N'BOOKING_CONFIRM', N'Your booking #3054 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-09T01:43:13.690' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2053, 3006, 3055, N'BOOKING_CONFIRM', N'Your booking #3055 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-09T01:43:13.787' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2054, 3006, 3056, N'BOOKING_CONFIRM', N'Your booking #3056 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.370' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2055, 3006, 3057, N'BOOKING_CONFIRM', N'Your booking #3057 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.490' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2056, 3006, 3058, N'BOOKING_CONFIRM', N'Your booking #3058 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.610' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2057, 3006, 3059, N'BOOKING_CONFIRM', N'Your booking #3059 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.727' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2058, 3006, 3060, N'BOOKING_CONFIRM', N'Your booking #3060 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.860' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2059, 3006, 3061, N'BOOKING_CONFIRM', N'Your booking #3061 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:08.970' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2060, 3006, 3062, N'BOOKING_CONFIRM', N'Your booking #3062 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:09.100' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2061, 3006, 3063, N'BOOKING_CONFIRM', N'Your booking #3063 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:09.207' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2062, 3006, 3064, N'BOOKING_CONFIRM', N'Your booking #3064 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:09.333' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2063, 3006, 3065, N'BOOKING_CONFIRM', N'Your booking #3065 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T01:05:09.460' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2064, 3006, 3066, N'BOOKING_CONFIRM', N'Your booking #3066 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T23:41:21.157' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2065, 3006, 3067, N'BOOKING_CONFIRM', N'Your booking #3067 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-10T23:41:21.307' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2066, 3006, 3068, N'BOOKING_CONFIRM', N'Your booking #3068 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T22:29:28.847' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2067, 3006, 3069, N'BOOKING_CONFIRM', N'Your booking #3069 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T22:29:28.977' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2068, 3006, 3070, N'BOOKING_CONFIRM', N'Your booking #3070 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T22:37:28.973' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2069, 3006, 3071, N'BOOKING_CONFIRM', N'Your booking #3071 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T22:37:29.080' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2070, 3006, 3072, N'BOOKING_CONFIRM', N'Your booking #3072 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T23:34:52.320' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2071, 3006, 3073, N'BOOKING_CONFIRM', N'Your booking #3073 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-11T23:34:52.430' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2072, 3006, 3074, N'BOOKING_CONFIRM', N'Your booking #3074 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T00:00:53.983' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2073, 3006, 3075, N'BOOKING_CONFIRM', N'Your booking #3075 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T00:01:02.760' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2074, 1002, 3076, N'BOOKING_CONFIRM', N'Your booking #3076 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T00:33:57.740' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2075, 1002, 3077, N'BOOKING_CONFIRM', N'Your booking #3077 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T00:34:02.780' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2076, 3006, 3078, N'BOOKING_CONFIRM', N'Your booking #3078 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T01:35:59.680' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2077, 3006, 3079, N'BOOKING_CONFIRM', N'Your booking #3079 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-12T01:35:59.820' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (2078, 3007, 3080, N'BOOKING_CONFIRM', N'Your booking #3080 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-14T02:07:39.523' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3078, 1002, 4080, N'BOOKING_CONFIRM', N'Your booking #4080 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-14T08:36:58.060' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3079, 1002, 4081, N'BOOKING_CONFIRM', N'Your booking #4081 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-14T22:39:16.130' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3080, 1002, 4082, N'BOOKING_CONFIRM', N'Your booking #4082 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-14T23:17:18.540' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3081, 1002, 4083, N'BOOKING_CONFIRM', N'Your booking #4083 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-14T23:48:35.623' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3082, 1002, 4084, N'BOOKING_CONFIRM', N'Your booking #4084 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T00:17:39.407' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3083, 1002, 4085, N'BOOKING_CONFIRM', N'Your booking #4085 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T00:29:54.923' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3084, 1002, 4086, N'BOOKING_CONFIRM', N'Your booking #4086 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T00:41:04.100' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3085, 1002, 4087, N'BOOKING_CONFIRM', N'Your booking #4087 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T00:43:31.353' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (3086, 1002, 4088, N'BOOKING_CONFIRM', N'Your booking #4088 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T00:54:35.167' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4082, 3005, 5085, N'BOOKING_CONFIRM', N'Your booking #5085 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T10:27:01.677' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4083, 3005, 5086, N'BOOKING_CONFIRM', N'Your booking #5086 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T11:16:03.407' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4084, 3005, 5087, N'BOOKING_CONFIRM', N'Your booking #5087 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T11:16:03.530' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4085, 3005, 5088, N'BOOKING_CONFIRM', N'Your booking #5088 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T11:17:10.110' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4086, 3005, 5089, N'BOOKING_CONFIRM', N'Your booking #5089 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-15T11:17:10.213' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4087, 1002, 6090, N'BOOKING_CONFIRM', N'Your booking #6090 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-20T20:28:22.720' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4088, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-20T20:32:31.450' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4089, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-20T20:32:31.467' AS DateTime), N'SENT')
GO
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4090, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1021', CAST(N'2025-07-20T22:33:04.880' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4091, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1021', CAST(N'2025-07-20T22:33:04.900' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4092, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1012', CAST(N'2025-07-20T22:33:04.987' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4093, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1012', CAST(N'2025-07-20T22:33:05.007' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4094, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 2', CAST(N'2025-07-20T23:13:40.590' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4095, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 2', CAST(N'2025-07-20T23:13:40.610' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4096, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-20T23:33:27.797' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4097, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-20T23:33:27.827' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4098, 3004, 6090, N'SERVICE_CANCELLED', N'Le Van Trieu cancelled service 4015', CAST(N'2025-07-21T00:36:01.717' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4099, 2, 6090, N'SERVICE_CANCELLED', N'Le Van Trieu cancelled service 4015', CAST(N'2025-07-21T00:36:01.737' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4100, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-21T00:36:52.583' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4101, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-21T00:36:52.613' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4102, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-21T00:36:52.723' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (4103, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1006', CAST(N'2025-07-21T00:36:52.747' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (5090, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1015', CAST(N'2025-07-21T08:50:43.367' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (5091, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1015', CAST(N'2025-07-21T08:50:43.400' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (5092, 3004, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1015', CAST(N'2025-07-21T08:50:43.543' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (5093, 2, 6090, N'SERVICE_REQUEST', N'Le Van Trieu requested service 1015', CAST(N'2025-07-21T08:50:43.563' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6090, 1002, 6091, N'BOOKING_CONFIRM', N'Your booking #6091 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:17:23.170' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6091, 1002, 6092, N'BOOKING_CONFIRM', N'Your booking #6092 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:17:23.267' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6092, 1002, 6093, N'BOOKING_CONFIRM', N'Your booking #6093 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:19:22.653' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6093, 2004, 6094, N'BOOKING_CONFIRM', N'Your booking #6094 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:26:34.330' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6094, 1002, 6095, N'BOOKING_CONFIRM', N'Your booking #6095 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:39:36.540' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6095, 2004, 6096, N'BOOKING_CONFIRM', N'Your booking #6096 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:48:30.327' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6096, 1002, 6097, N'BOOKING_CONFIRM', N'Your booking #6097 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:59:47.360' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6097, 1002, 6098, N'BOOKING_CONFIRM', N'Your booking #6098 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T16:59:47.470' AS DateTime), N'SENT')
INSERT [dbo].[Notifications] ([Id], [UserId], [ReservationId], [Type], [Message], [SentAt], [Status]) VALUES (6098, 1002, 6099, N'BOOKING_CONFIRM', N'Your booking #6099 has been created. Please proceed to payment to confirm your reservation.', CAST(N'2025-07-21T17:02:42.977' AS DateTime), N'SENT')
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[OTASync] ON 

INSERT [dbo].[OTASync] ([Id], [Provider], [RoomId], [Action], [Payload], [SyncedAt]) VALUES (1, N'Booking.com', 1, N'PRICE_UPDATE', N'{"price":550000}', CAST(N'2025-06-18T21:59:21.557' AS DateTime))
INSERT [dbo].[OTASync] ([Id], [Provider], [RoomId], [Action], [Payload], [SyncedAt]) VALUES (2, N'Agoda', 3, N'AVAILABILITY_UPDATE', N'{"available":true}', CAST(N'2025-06-18T21:59:21.557' AS DateTime))
INSERT [dbo].[OTASync] ([Id], [Provider], [RoomId], [Action], [Payload], [SyncedAt]) VALUES (3, N'Expedia', 5, N'PRICE_UPDATE', N'{"price":950000}', CAST(N'2025-06-18T21:59:21.557' AS DateTime))
SET IDENTITY_INSERT [dbo].[OTASync] OFF
GO
SET IDENTITY_INSERT [dbo].[Payments] ON 

INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1, 1, CAST(1000000.00 AS Decimal(10, 2)), N'VNPay', N'SUCCESS', N'TXN123456', CAST(N'2025-06-18T21:59:21.070' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2, 2, CAST(3200000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', NULL, CAST(N'2025-06-18T21:59:21.070' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3, 3, CAST(1800000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'SUCCESS', N'CC789012', CAST(N'2025-06-18T21:59:21.070' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4, 4, CAST(1000000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', NULL, CAST(N'2025-06-18T21:59:21.070' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (5, 5, CAST(6000000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BT456789', CAST(N'2025-06-18T21:59:21.070' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1002, 2002, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1750501997457167', CAST(N'2025-06-21T17:33:17.480' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1003, 2003, CAST(880000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'SUCCESS', N'CREDITCARD175050259174364', CAST(N'2025-06-21T17:42:31.510' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1004, 2004, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1750510811359155', CAST(N'2025-06-21T20:00:11.433' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1005, 2005, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750510909507526', CAST(N'2025-06-21T20:01:49.530' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1006, 2006, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1750511296210180', CAST(N'2025-06-21T20:08:16.227' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1007, 2007, CAST(880000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN175051143286888', CAST(N'2025-06-21T20:10:32.900' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1008, 2008, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1750512065985368', CAST(N'2025-06-21T20:21:06.000' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1009, 2009, CAST(2640000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1750512683602718', CAST(N'2025-06-21T20:31:23.620' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1010, 2010, CAST(880000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750512714679299', CAST(N'2025-06-21T20:31:54.700' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1011, 2011, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN175052024917578', CAST(N'2025-06-21T22:37:29.193' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1012, 2012, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750520363566424', CAST(N'2025-06-21T22:39:23.590' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1013, 2013, CAST(1100000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN175052064015534', CAST(N'2025-06-21T22:44:00.170' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1014, 2014, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750520894542789', CAST(N'2025-06-21T22:48:14.560' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1015, 2015, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750521116524938', CAST(N'2025-06-21T22:51:56.540' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1016, 2016, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750523347891932', CAST(N'2025-06-21T23:29:07.913' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1017, 2017, CAST(1650000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750523778342577', CAST(N'2025-06-21T23:36:18.357' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1018, 2018, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN175052417549984', CAST(N'2025-06-21T23:42:55.513' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1019, 2019, CAST(1650000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750524239140278', CAST(N'2025-06-21T23:43:59.160' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1020, 2020, CAST(1320000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN175052429357190', CAST(N'2025-06-21T23:44:53.597' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1021, 2021, CAST(3960000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750524649100694', CAST(N'2025-06-21T23:50:49.120' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1022, 2022, CAST(1650000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750524788365243', CAST(N'2025-06-21T23:53:08.397' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1023, 2023, CAST(1650000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN175052827671110', CAST(N'2025-06-22T00:51:16.743' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1024, 2024, CAST(1100000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750588919637196', CAST(N'2025-06-22T17:41:59.657' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1025, 2025, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750638835399372', CAST(N'2025-06-23T07:33:55.573' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1026, 2027, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750736221419714', CAST(N'2025-06-24T10:37:01.440' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1027, 2028, CAST(1100000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN175073990677038', CAST(N'2025-06-24T11:38:26.797' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1028, 2029, CAST(5110000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1750849867110984', CAST(N'2025-06-25T18:11:07.140' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (1029, 2030, CAST(4000000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1750864353976839', CAST(N'2025-06-25T22:12:33.997' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2028, 3029, CAST(2300000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751046111187988', CAST(N'2025-06-28T00:41:51.230' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2029, 3030, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1751048723329622', CAST(N'2025-06-28T01:25:23.357' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2030, 3031, CAST(55000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751048747675784', CAST(N'2025-06-28T01:25:47.693' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2031, 3032, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1751100598544415', CAST(N'2025-06-28T15:49:58.567' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2032, 3033, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751100777138121', CAST(N'2025-06-28T15:52:57.157' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2033, 3034, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751101432063964', CAST(N'2025-06-28T16:03:52.090' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2034, 3035, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER175110150409442', CAST(N'2025-06-28T16:04:09.243' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2035, 3036, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751103546834196', CAST(N'2025-06-28T16:39:06.857' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2036, 3037, CAST(550000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'PENDING', N'TXN1751103754791144', CAST(N'2025-06-28T16:42:34.810' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2037, 3038, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751105895282176', CAST(N'2025-06-28T17:17:57.237' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2038, 3039, CAST(99000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751107996126576', CAST(N'2025-06-28T17:53:03.233' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2039, 3040, CAST(165000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751108735503118', CAST(N'2025-06-28T18:05:18.077' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2040, 3041, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751109259670295', CAST(N'2025-06-28T18:13:47.673' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2041, 3042, CAST(132000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751109516823757', CAST(N'2025-06-28T18:18:20.417' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2042, 3043, CAST(550000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1751111574947731', CAST(N'2025-06-28T18:52:54.977' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2043, 3044, CAST(110000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751112216627688', CAST(N'2025-06-28T19:03:28.273' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2044, 3046, CAST(75000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751195429941255', CAST(N'2025-06-29T18:10:22.240' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2045, 3047, CAST(90000.00 AS Decimal(10, 2)), N'CREDIT_CARD', N'SUCCESS', N'CREDITCARD-DEPOSIT-1751378589862522', CAST(N'2025-07-01T21:02:33.463' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2046, 3048, CAST(140000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751386947711504', CAST(N'2025-07-01T23:22:22.380' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2047, 3049, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751552267195987', CAST(N'2025-07-03T21:17:27.773' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2048, 3050, CAST(90000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1751554863448893', CAST(N'2025-07-03T21:26:28.973' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2049, 3051, CAST(880000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1751591993003158', CAST(N'2025-07-04T08:19:53.100' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2050, 3052, CAST(880000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'PENDING', N'TXN1751992337023496', CAST(N'2025-07-08T23:32:17.093' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2051, 3053, CAST(88000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'CASH-DEPOSIT-1752000203646155', CAST(N'2025-07-09T01:43:13.577' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2052, 3054, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', N'TXN1752000193643172', CAST(N'2025-07-09T01:43:13.657' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2053, 3055, CAST(990000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', N'TXN1752000193739373', CAST(N'2025-07-09T01:43:13.753' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2054, 3056, CAST(88000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'CASH-DEPOSIT-1752084316750833', CAST(N'2025-07-10T01:05:08.297' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2055, 3057, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084308425357', CAST(N'2025-07-10T01:05:08.443' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2056, 3058, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084308541937', CAST(N'2025-07-10T01:05:08.560' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2057, 3059, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1752084308658954', CAST(N'2025-07-10T01:05:08.680' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2058, 3060, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084308785975', CAST(N'2025-07-10T01:05:08.810' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2059, 3061, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084308907180', CAST(N'2025-07-10T01:05:08.927' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2060, 3062, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084309030417', CAST(N'2025-07-10T01:05:09.050' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2061, 3063, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'PENDING', N'TXN1752084309148422', CAST(N'2025-07-10T01:05:09.167' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2062, 3064, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1752084309259793', CAST(N'2025-07-10T01:05:09.277' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2063, 3065, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1752084309395160', CAST(N'2025-07-10T01:05:09.413' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2064, 3066, CAST(616000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752165708033170', CAST(N'2025-07-10T23:41:21.100' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2065, 3067, CAST(6930000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'TXN1752165681260445', CAST(N'2025-07-10T23:41:21.273' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2066, 3068, CAST(880000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'TXN1752247768764799', CAST(N'2025-07-11T22:29:28.790' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2067, 3069, CAST(990000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'FAILED', N'TXN1752247768926330', CAST(N'2025-07-11T22:29:28.940' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2068, 3070, CAST(121000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752248323111870', CAST(N'2025-07-11T22:37:28.927' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2069, 3071, CAST(121000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752248323111870', CAST(N'2025-07-11T22:37:29.043' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2070, 3072, CAST(115500.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752251825796648', CAST(N'2025-07-11T23:34:52.277' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2071, 3073, CAST(115500.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752251825796648', CAST(N'2025-07-11T23:34:52.390' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2072, 3074, CAST(115500.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752254476163269', CAST(N'2025-07-12T00:00:53.883' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2073, 3075, CAST(115500.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752254476163269', CAST(N'2025-07-12T00:01:02.703' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2074, 3076, CAST(110000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752257949840671', CAST(N'2025-07-12T00:33:57.667' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2075, 3077, CAST(110000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752257949840671', CAST(N'2025-07-12T00:34:02.713' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2076, 3078, CAST(165000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-175225951539037', CAST(N'2025-07-12T01:35:59.630' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2077, 3079, CAST(99000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-175225951539037', CAST(N'2025-07-12T01:35:59.773' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (2078, 3080, CAST(3300000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'FAILED', NULL, CAST(N'2025-07-14T02:07:39.480' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3078, 4080, CAST(165000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752457073793541', CAST(N'2025-07-14T08:36:57.990' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3079, 4081, CAST(99000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752507614972465', CAST(N'2025-07-14T22:39:16.057' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3080, 4082, CAST(3300000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'TXN1752509838421725', CAST(N'2025-07-14T23:17:18.453' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3081, 4083, CAST(132000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752511768853228', CAST(N'2025-07-14T23:48:35.570' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3082, 4084, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752513486229537', CAST(N'2025-07-15T00:17:39.310' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3083, 4085, CAST(110000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752514209990857', CAST(N'2025-07-15T00:29:54.867' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3084, 4086, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752514883726207', CAST(N'2025-07-15T00:41:04.060' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3085, 4087, CAST(55000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752515024337465', CAST(N'2025-07-15T00:43:31.313' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (3086, 4088, CAST(165000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-175251570758692', CAST(N'2025-07-15T00:54:35.123' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4082, 5085, CAST(132000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752551033389304', CAST(N'2025-07-15T10:27:01.630' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4083, 5086, CAST(990000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'FAILED', N'TXN1752552963327217', CAST(N'2025-07-15T11:16:03.353' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4084, 5087, CAST(1320000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'FAILED', N'TXN175255296347321', CAST(N'2025-07-15T11:16:03.490' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4085, 5088, CAST(99000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752553620345181', CAST(N'2025-07-15T11:17:10.067' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4086, 5089, CAST(88000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1752553620345181', CAST(N'2025-07-15T11:17:10.177' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4087, 3046, CAST(75000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'REFUND-TXN1752858630075', CAST(N'2025-07-19T00:10:30.123' AS DateTime), N'REFUND')
GO
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4088, 3046, CAST(75000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'REFUND-TXN1753009956065', CAST(N'2025-07-20T18:12:36.153' AS DateTime), N'REFUND')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4089, 6090, CAST(132000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1753018118624477', CAST(N'2025-07-20T20:28:22.643' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4090, 6091, CAST(88000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1753089475703151', CAST(N'2025-07-21T16:17:23.117' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4091, 6092, CAST(88000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'BANKTRANSFER-DEPOSIT-1753089475703151', CAST(N'2025-07-21T16:17:23.230' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4092, 6093, CAST(2200000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', N'TXN1753089562582744', CAST(N'2025-07-21T16:19:22.613' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4093, 6094, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', N'TXN1753089994259889', CAST(N'2025-07-21T16:26:34.283' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4094, 6095, CAST(2200000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', N'TXN1753090776465797', CAST(N'2025-07-21T16:39:36.490' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4095, 6096, CAST(3300000.00 AS Decimal(10, 2)), N'CASH', N'FAILED', NULL, CAST(N'2025-07-21T16:48:30.250' AS DateTime), N'FULL_PAYMENT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4096, 6097, CAST(2640000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1753091987260327', CAST(N'2025-07-21T16:59:47.290' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4097, 6098, CAST(1760000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1753091987414253', CAST(N'2025-07-21T16:59:47.430' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4098, 6099, CAST(880000.00 AS Decimal(10, 2)), N'CASH', N'SUCCESS', N'TXN1753092162922838', CAST(N'2025-07-21T17:02:42.940' AS DateTime), N'DEPOSIT')
INSERT [dbo].[Payments] ([Id], [ReservationId], [Amount], [Method], [Status], [TransactionId], [CreatedAt], [PaymentType]) VALUES (4099, 6090, CAST(132000.00 AS Decimal(10, 2)), N'BANK_TRANSFER', N'SUCCESS', N'REFUND-TXN1753094427953', CAST(N'2025-07-21T17:40:28.033' AS DateTime), N'REFUND')
SET IDENTITY_INSERT [dbo].[Payments] OFF
GO
SET IDENTITY_INSERT [dbo].[PendingChanges] ON 

INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1, 10, 1, N'EMAIL', N'david@gmail.com', N'0900000000', N'new.email@example.com', NULL, NULL, N'Customer requested email update', NULL, N'B3F54A4D-A57E-4F20-B238-37B7EE51B3C8-Jun 22 2025 11:26PM', CAST(N'2025-06-24T23:26:18.407' AS DateTime), N'PENDING', 0, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-22T23:26:18.407' AS DateTime), CAST(N'2025-06-22T23:26:18.407' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (2, 1002, 1, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'trieulvhe187167@fpt.edu.vn', NULL, NULL, N'Admin requested email change from baotrieu300@gmail.com to trieulvhe187167@fpt.edu.vn', NULL, N'06327709-1526-493E-A1AA-16CAD7FBDB8C-Jun 23 2025  6:10PM', CAST(N'2025-06-25T18:10:59.147' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T18:10:59.147' AS DateTime), CAST(N'2025-06-23T18:10:59.147' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (3, 1002, 1, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, N'Admin requested email change from baotrieu300@gmail.com to trieulvhe1871678@fpt.edu.vn', NULL, N'7FD59D08-AB78-434A-94B7-35BF7AC6C462-Jun 23 2025 10:40PM', CAST(N'2025-06-25T22:40:00.953' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-06-23T22:49:24.633' AS DateTime), 1, NULL, NULL, CAST(N'2025-06-23T22:40:00.957' AS DateTime), CAST(N'2025-06-23T22:40:00.957' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (4, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0908070690', NULL, N'Admin requested phone change from 0385217604 to 0908070690', NULL, N'E748DBE5-0140-4751-8FE0-F9ACAB5EFAF6-Jun 23 2025 10:50PM', CAST(N'2025-06-25T22:50:48.220' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T22:50:48.220' AS DateTime), CAST(N'2025-06-23T22:50:48.220' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (5, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'Admin requested phone change from 0385217604 to 0123456789', NULL, N'44DE14C0-755B-4FE4-B7AC-6D74AC14AB3E-Jun 23 2025 10:58PM', CAST(N'2025-06-25T22:58:23.463' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T22:58:23.467' AS DateTime), CAST(N'2025-06-23T22:58:23.467' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (6, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'07EA9E25-8A61-431C-8C2D-FAAA0C5CED92-Jun 23 2025 10:59PM', CAST(N'2025-06-25T22:59:31.410' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T22:59:31.410' AS DateTime), CAST(N'2025-06-23T22:59:31.410' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (7, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'2AAEEEF1-129F-491B-A554-2F8DAF01FDB7-Jun 23 2025 11:03PM', CAST(N'2025-06-25T23:03:49.043' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:03:49.047' AS DateTime), CAST(N'2025-06-23T23:03:49.047' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (8, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'506DD247-7B15-4431-AE19-CA0AB5EB7F5D-Jun 23 2025 11:07PM', CAST(N'2025-06-25T23:07:54.067' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:07:54.070' AS DateTime), CAST(N'2025-06-23T23:07:54.070' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (9, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'3F4C13C5-2C6B-4671-9745-6A4FB18DE33E-Jun 23 2025 11:10PM', CAST(N'2025-06-25T23:10:55.903' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:10:55.903' AS DateTime), CAST(N'2025-06-23T23:10:55.903' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (10, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'8506F3EE-F5F1-4660-BC13-4376F02B78B7-Jun 23 2025 11:13PM', CAST(N'2025-06-25T23:13:46.950' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:13:46.950' AS DateTime), CAST(N'2025-06-23T23:13:46.950' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (11, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'D90B34CA-1A4D-4593-A10B-46A7570C50B1-Jun 23 2025 11:15PM', CAST(N'2025-06-25T23:15:07.460' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:15:07.460' AS DateTime), CAST(N'2025-06-23T23:15:07.460' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (12, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'A343F4A4-49C2-4278-AF21-5B6A0CA0D944-Jun 23 2025 11:18PM', CAST(N'2025-06-25T23:18:15.190' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:18:15.190' AS DateTime), CAST(N'2025-06-23T23:18:15.190' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (13, 1002, 1, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, N'', NULL, N'D521767A-77BA-4FB0-8B23-49EC824FD07B-Jun 23 2025 11:21PM', CAST(N'2025-06-25T23:21:35.063' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:21:35.063' AS DateTime), CAST(N'2025-06-23T23:21:35.063' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (14, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'5588546C-9B36-4131-A5B4-C525EB1FC3CF-Jun 23 2025 11:24PM', CAST(N'2025-06-25T23:24:26.510' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:24:26.510' AS DateTime), CAST(N'2025-06-23T23:24:26.510' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (15, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'C9300FC3-854E-460D-B87A-0487D371BC65-Jun 23 2025 11:30PM', CAST(N'2025-06-25T23:30:03.367' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:30:03.370' AS DateTime), CAST(N'2025-06-23T23:30:03.370' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (16, 7, 1, N'PHONE', N'house5@luxuryhotel.com', N'0911223345', NULL, N'0911223345', NULL, N'', NULL, N'3040ACF6-9C94-41FF-BF11-5E2E1B893F05-Jun 23 2025 11:30PM', CAST(N'2025-06-25T23:30:24.160' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:30:24.160' AS DateTime), CAST(N'2025-06-23T23:30:24.160' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (17, 10, 1, N'PHONE', N'david@gmail.com', N'0900000000', NULL, N'0900000000', NULL, N'', NULL, N'B91AAB2A-1394-4C67-9AB7-8F256B3DD98A-Jun 23 2025 11:31PM', CAST(N'2025-06-25T23:31:17.410' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:31:17.410' AS DateTime), CAST(N'2025-06-23T23:31:17.410' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (18, 10, 1, N'EMAIL', N'david@gmail.com', N'0900000000', N'david@gmail.com', NULL, NULL, N'', NULL, N'6748ABFB-3F5E-460D-8B67-93E2498B97A6-Jun 23 2025 11:33PM', CAST(N'2025-06-25T23:33:45.300' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:33:45.300' AS DateTime), CAST(N'2025-06-23T23:33:45.300' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (19, 10, 1, N'EMAIL', N'david@gmail.com', N'0900000000', N'david@gmail.com', NULL, NULL, N'', NULL, N'9047C19E-B23A-497B-9A89-5FD19F7AAB9E-Jun 23 2025 11:35PM', CAST(N'2025-06-25T23:35:28.290' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:35:28.290' AS DateTime), CAST(N'2025-06-23T23:35:28.290' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (20, 10, 1, N'PHONE', N'david@gmail.com', N'0900000000', NULL, N'0900000000', NULL, N'', NULL, N'ECCE3F20-4E24-4247-B5C6-A6B5874BB46C-Jun 23 2025 11:36PM', CAST(N'2025-06-25T23:36:08.487' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:36:08.487' AS DateTime), CAST(N'2025-06-23T23:36:08.487' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (21, 1002, 1, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, N'', NULL, N'A830BEC3-A2D4-4E5C-96C2-7ABF381339C8-Jun 23 2025 11:38PM', CAST(N'2025-06-25T23:38:45.467' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:38:45.470' AS DateTime), CAST(N'2025-06-23T23:38:45.470' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (22, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'B25670F5-2BDA-47B2-A00A-05426553CDA9-Jun 23 2025 11:42PM', CAST(N'2025-06-25T23:42:14.877' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:42:14.877' AS DateTime), CAST(N'2025-06-23T23:42:14.877' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (23, 1002, 1, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, N'', NULL, N'48114E04-FE2B-45B5-9947-32547B4CEC58-Jun 23 2025 11:43PM', CAST(N'2025-06-25T23:43:02.330' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-23T23:43:02.330' AS DateTime), CAST(N'2025-06-23T23:43:02.330' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (24, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'23241018-DD2D-4B91-BD34-45E70AA0FEB9-Jun 24 2025 12:04AM', CAST(N'2025-06-26T00:04:22.290' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T00:04:22.293' AS DateTime), CAST(N'2025-06-24T00:04:22.293' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (25, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'CEB755EF-6070-4D76-A189-6766B6E84FF1-Jun 24 2025 12:10AM', CAST(N'2025-06-26T00:10:13.177' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T00:10:13.180' AS DateTime), CAST(N'2025-06-24T00:10:13.180' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1013, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'A2036E25-884E-4416-836D-ADE113B1E1EF-Jun 24 2025  7:39AM', CAST(N'2025-06-26T07:39:34.327' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T07:39:34.330' AS DateTime), CAST(N'2025-06-24T07:39:34.330' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1014, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'3F886710-AC54-43F8-A321-7E99B6A4D0A3-Jun 24 2025  7:40AM', CAST(N'2025-06-26T07:40:05.880' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T07:40:05.880' AS DateTime), CAST(N'2025-06-24T07:40:05.880' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1015, 1002, 1, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', N'baotrieu300@gmail.com', NULL, NULL, N'Admin requested email change from trieulvhe1871678@fpt.edu.vn to baotrieu300@gmail.com', NULL, N'8C7B78C3-41E8-4B41-A26E-0FC31933275C-Jun 24 2025  7:42AM', CAST(N'2025-06-26T07:42:16.770' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T07:42:16.770' AS DateTime), CAST(N'2025-06-24T07:42:16.770' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1016, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'408F43BE-B4DE-488C-953E-4546EF541F0A-Jun 24 2025  7:44AM', CAST(N'2025-06-26T07:44:20.153' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T07:44:20.157' AS DateTime), CAST(N'2025-06-24T07:44:20.157' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1017, 1002, 1, N'PHONE', N'trieulvhe1871678@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'EF45686C-51E2-4E4E-ACFF-8037C30EFE75-Jun 24 2025  7:45AM', CAST(N'2025-06-26T07:45:23.733' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T07:45:23.733' AS DateTime), CAST(N'2025-06-24T07:45:23.733' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1018, 1, 1, N'PHONE', N'luxuryhotel999@gmail.com', N'0123456789', NULL, N'0888888888', NULL, N'Admin requested phone change from 0123456789 to 0888888888', NULL, N'EAA46F8E-10F9-4373-B41F-63A7BA9F6C1B-Jun 24 2025  7:49AM', CAST(N'2025-06-26T07:49:30.440' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-06-24T07:51:14.843' AS DateTime), 1, NULL, NULL, CAST(N'2025-06-24T07:49:30.440' AS DateTime), CAST(N'2025-06-24T07:49:30.440' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1019, 1002, 1, N'PHONE', N'trieulvhe187167@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'D85514D1-41CA-402F-BE21-93A8295F23E9-Jun 24 2025  9:32AM', CAST(N'2025-06-26T09:32:11.433' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T09:32:11.437' AS DateTime), CAST(N'2025-06-24T09:32:11.437' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1020, 1002, 1, N'PHONE', N'trieulvhe187167@fpt.edu.vn', N'0385217604', NULL, N'0123456789', NULL, N'', NULL, N'98536576-2AF4-408E-A885-6E998BD9CA8B-Jun 24 2025  9:32AM', CAST(N'2025-06-26T09:32:48.520' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-06-24T09:34:03.307' AS DateTime), 1, NULL, NULL, CAST(N'2025-06-24T09:32:48.520' AS DateTime), CAST(N'2025-06-24T09:32:48.520' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1021, 1002, 1, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'0123456789', N'baotrieu300@gmail.com', NULL, NULL, N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, N'5DCC7148-F32A-4023-8B30-0B94A3610E68-Jun 24 2025  9:34AM', CAST(N'2025-06-26T09:34:59.863' AS DateTime), N'REJECTED', 1, 0, 0, NULL, 0, CAST(N'2025-06-24T09:35:23.703' AS DateTime), N'User rejected the change request', CAST(N'2025-06-24T09:34:59.867' AS DateTime), CAST(N'2025-06-24T09:34:59.867' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1022, 1002, 1, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'0123456789', N'baotrieu300@gmail.com', NULL, NULL, N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, N'FD58CA4F-42A9-4247-9910-B0BDFC01FE47-Jun 24 2025  9:35AM', CAST(N'2025-06-26T09:35:52.323' AS DateTime), N'REJECTED', 1, 0, 0, NULL, 0, CAST(N'2025-06-24T09:38:10.067' AS DateTime), N'User rejected the change request', CAST(N'2025-06-24T09:35:52.323' AS DateTime), CAST(N'2025-06-24T09:35:52.323' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1023, 1002, 1, N'PHONE', N'trieulvhe187167@fpt.edu.vn', N'0123456789', NULL, N'0385217604', NULL, N'Admin requested phone change from 0123456789 to 0385217604', NULL, N'D1B9C80F-66CC-401A-8F21-4903D1A8330D-Jun 24 2025  9:35AM', CAST(N'2025-06-26T09:35:57.927' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-06-24T09:38:36.103' AS DateTime), 1, NULL, NULL, CAST(N'2025-06-24T09:35:57.927' AS DateTime), CAST(N'2025-06-24T09:35:57.927' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1024, 1002, 1, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'baotrieu300@gmail.com', NULL, NULL, N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, N'0A0E12EF-2AF8-4D91-9B91-900A69E1972E-Jun 24 2025  9:39AM', CAST(N'2025-06-26T09:39:13.173' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-06-24T09:39:29.403' AS DateTime), 1, NULL, NULL, CAST(N'2025-06-24T09:39:13.173' AS DateTime), CAST(N'2025-06-24T09:39:13.173' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1025, 1002, 1, N'PHONE', N'baotrieu300@gmail.com', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'9CA0459A-D57D-40E7-A04A-5F9B511EA171-Jun 24 2025  9:40AM', CAST(N'2025-06-26T09:40:16.327' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T09:40:16.327' AS DateTime), CAST(N'2025-06-24T09:40:16.327' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1026, 1, 1, N'PHONE', N'luxuryhotel999@gmail.com', N'0888888888', NULL, N'0999999999', NULL, N'Admin requested phone change from 0888888888 to 0999999999', NULL, N'1E766FEC-96C7-4DE9-A73E-B63F18457C9D-Jun 24 2025  9:44AM', CAST(N'2025-06-26T09:44:27.180' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T09:44:27.183' AS DateTime), CAST(N'2025-06-24T09:44:27.183' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1027, 1002, 1, N'PHONE', N'baotrieu300@gmail.com', N'0385217604', NULL, N'0123456789', NULL, N'Admin requested phone change from 0385217604 to 0123456789', NULL, N'9AA00BAF-AA29-4656-83A1-24AEF68EC589-Jun 24 2025  9:51AM', CAST(N'2025-06-26T09:51:15.577' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-24T09:51:15.580' AS DateTime), CAST(N'2025-06-24T09:51:15.580' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1028, 2004, 1, N'PHONE', N'trieulvhe187167@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'750EE822-4733-45EF-B293-C0B4C2158D96-Jun 26 2025  8:49PM', CAST(N'2025-06-28T20:49:02.927' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-26T20:49:02.930' AS DateTime), CAST(N'2025-06-26T20:49:02.930' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1029, 2004, 1, N'PHONE', N'trieulvhe187167@fpt.edu.vn', N'0385217604', NULL, N'0385217604', NULL, N'', NULL, N'EBEE1472-3FFA-4BA1-9E3A-158E3EFAE889-Jun 26 2025  8:58PM', CAST(N'2025-06-28T20:58:35.593' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-26T20:58:35.600' AS DateTime), CAST(N'2025-06-26T20:58:35.600' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1030, 2004, 1, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'trieulvhe187167@fpt.edu.vn', NULL, NULL, N'', NULL, N'62E90D35-B662-4888-A629-01C5577BE2CB-Jun 26 2025  8:58PM', CAST(N'2025-06-28T20:58:44.137' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-26T20:58:44.137' AS DateTime), CAST(N'2025-06-26T20:58:44.137' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1031, 2004, 1, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'levantrieu170604@gmail.com', NULL, NULL, N'Admin requested email change from trieulvhe187167@fpt.edu.vn to levantrieu170604@gmail.com', NULL, N'C84F9F2F-91C7-410B-901B-82AB04B4EA15-Jun 28 2025  5:54PM', CAST(N'2025-06-30T17:54:55.837' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-28T17:54:55.843' AS DateTime), CAST(N'2025-06-28T17:54:55.843' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1032, 1002, 1, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'levantrieu170604@gmail.com', NULL, NULL, N'Admin requested email change for customer', NULL, N'C0214D1A-6127-41B6-A071-C8F029491205-Jun 29 2025  1:39AM', CAST(N'2025-07-01T01:39:47.383' AS DateTime), N'REJECTED', 1, 0, 0, NULL, 0, CAST(N'2025-06-29T01:40:56.780' AS DateTime), N'User rejected the change request', CAST(N'2025-06-29T01:39:47.387' AS DateTime), CAST(N'2025-06-29T01:39:47.387' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1033, 1002, 1, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'levantrieu170604@gmail.com', NULL, NULL, N'Admin requested email change from baotrieu300@gmail.com to levantrieu170604@gmail.com', NULL, N'214031FF-D33F-48B6-AF63-4A60A6F6B55B-Jun 29 2025  3:35PM', CAST(N'2025-07-01T15:35:04.573' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-06-29T15:35:04.573' AS DateTime), CAST(N'2025-06-29T15:35:04.573' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1034, 1002, 1, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'levantrieu170604@gmail.com', NULL, NULL, N'Admin requested email change from baotrieu300@gmail.com to levantrieu170604@gmail.com', NULL, N'782F903B-4621-48C3-9636-3BF6622A2BC7-Jun 29 2025  3:35PM', CAST(N'2025-07-01T15:35:09.140' AS DateTime), N'REJECTED', 1, 0, 0, NULL, 0, CAST(N'2025-06-29T15:35:49.553' AS DateTime), N'User rejected the change request', CAST(N'2025-06-29T15:35:09.140' AS DateTime), CAST(N'2025-06-29T15:35:09.140' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1035, 1, 1, N'EMAIL', N'luxuryhotel999@gmail.com', N'0888888888', N'levantrieu170604@gmail.com', NULL, NULL, N'Admin requested email change from luxuryhotel999@gmail.com to levantrieu170604@gmail.com', NULL, N'A21426E0-844C-4E94-9158-7C3CD7DDE26E-Jun 29 2025  3:37PM', CAST(N'2025-07-01T15:37:51.363' AS DateTime), N'REJECTED', 1, 0, 0, NULL, 0, CAST(N'2025-06-29T15:38:12.627' AS DateTime), N'User rejected the change request', CAST(N'2025-06-29T15:37:51.367' AS DateTime), CAST(N'2025-06-29T15:37:51.367' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1036, 1002, 1002, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'trieuhao2004@gmail.com', NULL, NULL, N'User requested email change', NULL, N'E812454A-E492-4466-B12A-4399AF6E2C5C-Jul 13 2025  1:04AM', CAST(N'2025-07-15T01:04:02.897' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-07-13T01:04:02.897' AS DateTime), CAST(N'2025-07-13T01:04:02.897' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1037, 1002, 1002, N'EMAIL', N'baotrieu300@gmail.com', N'0385217604', N'trieuhao2004@gmail.com', NULL, NULL, N'User requested email change', NULL, N'661B84B8-A98F-4F5A-9B69-9BD7411E29A1-Jul 13 2025  1:04AM', CAST(N'2025-07-15T01:04:20.080' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-07-13T01:06:13.540' AS DateTime), 1, NULL, NULL, CAST(N'2025-07-13T01:04:20.080' AS DateTime), CAST(N'2025-07-13T01:04:20.080' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1038, 1002, 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'0385217604', N'baotrieu300@gmail.com', NULL, NULL, N'User requested email change', NULL, N'6630DF2D-D974-40BC-A1BD-72C142343D47-Jul 13 2025  1:06AM', CAST(N'2025-07-15T01:06:58.607' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-07-13T01:06:58.607' AS DateTime), CAST(N'2025-07-13T01:06:58.607' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1039, 1002, 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'0385217604', N'baotrieu300@gmail.com', NULL, NULL, N'User requested email change', NULL, N'A79F5EB4-7EED-4A4E-B173-EF608E0566D0-Jul 13 2025  1:08AM', CAST(N'2025-07-15T01:08:06.170' AS DateTime), N'PENDING', 1, 0, 0, NULL, 0, NULL, NULL, CAST(N'2025-07-13T01:08:06.170' AS DateTime), CAST(N'2025-07-13T01:08:06.170' AS DateTime))
INSERT [dbo].[PendingChanges] ([Id], [UserId], [InitiatedBy], [ChangeType], [OriginalEmail], [OriginalPhone], [NewEmail], [NewPhone], [NewPasswordHash], [ChangeReason], [ChangeDetails], [VerificationToken], [TokenExpiry], [Status], [NotificationSent], [ReminderSent], [ReminderCount], [ApprovedAt], [ApprovedByEmail], [RejectedAt], [RejectionReason], [CreatedAt], [UpdatedAt]) VALUES (1040, 1002, 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'0385217604', N'baotrieu300@gmail.com', NULL, NULL, N'User requested email change', NULL, N'F97FFF01-0BAE-4A0F-B574-1B99933CBF82-Jul 13 2025  1:09AM', CAST(N'2025-07-15T01:09:15.390' AS DateTime), N'APPROVED', 1, 0, 0, CAST(N'2025-07-13T01:10:28.740' AS DateTime), 1, NULL, NULL, CAST(N'2025-07-13T01:09:15.390' AS DateTime), CAST(N'2025-07-13T01:09:15.390' AS DateTime))
SET IDENTITY_INSERT [dbo].[PendingChanges] OFF
GO
SET IDENTITY_INSERT [dbo].[Reservations] ON 

INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (1, 10, NULL, NULL, 1, CAST(N'2024-06-20' AS Date), CAST(N'2024-06-22' AS Date), N'COMPLETED', CAST(1000000.00 AS Decimal(10, 2)), N'Regular customer', CAST(N'2025-06-18T21:59:21.057' AS DateTime), 1, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2, 11, 1, 2, 3, CAST(N'2025-12-01' AS Date), CAST(N'2025-12-05' AS Date), N'PENDING', CAST(3200000.00 AS Decimal(10, 2)), N'Group booking - FPT team', CAST(N'2025-06-18T21:59:21.057' AS DateTime), 4, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3, 10, NULL, 2, 5, CAST(N'2025-11-25' AS Date), CAST(N'2025-11-27' AS Date), N'CONFIRMED', CAST(1800000.00 AS Decimal(10, 2)), N'Repeat customer', CAST(N'2025-06-18T21:59:21.057' AS DateTime), 6, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4, 11, NULL, 2, 8, CAST(N'2025-06-18' AS Date), CAST(N'2025-06-19' AS Date), N'COMPLETED', CAST(1000000.00 AS Decimal(10, 2)), N'Business trip', CAST(N'2025-06-18T21:59:21.057' AS DateTime), 7, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5, 12, NULL, 1, 11, CAST(N'2025-10-22' AS Date), CAST(N'2025-10-26' AS Date), N'CONFIRMED', CAST(6000000.00 AS Decimal(10, 2)), N'VIP customer - special care', CAST(N'2025-06-18T21:59:21.057' AS DateTime), 3, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6, 11, NULL, 2, 1, CAST(N'2025-06-17' AS Date), CAST(N'2025-06-19' AS Date), N'CONFIRMED', CAST(1000000.00 AS Decimal(10, 2)), N'Khách đặt mới để test pending inspection', CAST(N'2025-06-19T01:01:50.203' AS DateTime), 1, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (1002, 11, NULL, 2, 1, CAST(N'2025-06-19' AS Date), CAST(N'2025-06-20' AS Date), N'CONFIRMED', CAST(2000000.00 AS Decimal(10, 2)), N'Booking test cho pending inspection ngày mai', CAST(N'2025-06-19T17:59:39.117' AS DateTime), 1, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2002, 1002, NULL, NULL, 13, CAST(N'2025-06-21' AS Date), CAST(N'2025-06-22' AS Date), N'CANCELLED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T17:33:17.443' AS DateTime), 1, NULL, 1, CAST(N'2025-06-24T11:10:37.173' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2003, 1002, NULL, NULL, 6, CAST(N'2025-06-21' AS Date), CAST(N'2025-06-22' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T17:42:31.470' AS DateTime), 2, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2004, 1002, NULL, NULL, 1, CAST(N'2025-06-21' AS Date), CAST(N'2025-06-22' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:00:11.320' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2005, 1002, NULL, NULL, 2, CAST(N'2025-06-21' AS Date), CAST(N'2025-06-22' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:01:49.507' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2006, 1002, NULL, NULL, 1, CAST(N'2025-06-22' AS Date), CAST(N'2025-06-23' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:08:16.203' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2007, 1002, NULL, NULL, 6, CAST(N'2025-06-23' AS Date), CAST(N'2025-06-24' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:10:32.860' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2008, 1002, NULL, NULL, 1, CAST(N'2025-06-23' AS Date), CAST(N'2025-06-24' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:21:05.977' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2009, 1002, NULL, NULL, 6, CAST(N'2025-06-24' AS Date), CAST(N'2025-06-27' AS Date), N'PENDING', CAST(2640000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:31:23.593' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2010, 1002, NULL, NULL, 6, CAST(N'2025-06-27' AS Date), CAST(N'2025-06-28' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T20:31:54.677' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2011, 1002, NULL, NULL, 2, CAST(N'2025-06-22' AS Date), CAST(N'2025-06-23' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T22:37:29.170' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2012, 1002, NULL, NULL, 2, CAST(N'2025-06-23' AS Date), CAST(N'2025-06-24' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T22:39:23.553' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T10:15:41.443' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2013, 1002, NULL, NULL, 1, CAST(N'2025-06-24' AS Date), CAST(N'2025-06-26' AS Date), N'PENDING', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T22:44:00.147' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2014, 1002, NULL, NULL, 1, CAST(N'2025-06-27' AS Date), CAST(N'2025-06-28' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T22:48:14.533' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2015, 1002, NULL, NULL, 1, CAST(N'2025-06-28' AS Date), CAST(N'2025-06-29' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T22:51:56.517' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2016, 1002, NULL, NULL, 2, CAST(N'2025-06-28' AS Date), CAST(N'2025-06-29' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:29:07.880' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2017, 1002, NULL, NULL, 5, CAST(N'2025-06-26' AS Date), CAST(N'2025-06-27' AS Date), N'PENDING', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:36:18.333' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2018, 1002, NULL, NULL, 1, CAST(N'2025-06-26' AS Date), CAST(N'2025-06-27' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:42:55.497' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2019, 1002, NULL, NULL, 13, CAST(N'2025-06-27' AS Date), CAST(N'2025-06-30' AS Date), N'PENDING', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:43:59.137' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2020, 1002, NULL, NULL, 4, CAST(N'2025-06-28' AS Date), CAST(N'2025-06-29' AS Date), N'PENDING', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:44:53.567' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2021, 1002, NULL, NULL, 3, CAST(N'2025-06-27' AS Date), CAST(N'2025-07-01' AS Date), N'PENDING', CAST(3960000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:50:49.090' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2022, 1002, NULL, NULL, 5, CAST(N'2025-06-21' AS Date), CAST(N'2025-06-22' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-21T23:53:08.357' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T11:10:31.070' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2023, 1002, NULL, NULL, 5, CAST(N'2025-06-27' AS Date), CAST(N'2025-06-28' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-22T00:51:16.697' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T10:17:08.457' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2024, 1002, NULL, NULL, 13, CAST(N'2025-06-23' AS Date), CAST(N'2025-06-25' AS Date), N'CONFIRMED', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-22T17:41:59.623' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T10:17:04.260' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2025, 2002, NULL, NULL, 2, CAST(N'2025-06-24' AS Date), CAST(N'2025-06-25' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-23T07:33:55.380' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T10:16:35.617' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2026, 10, NULL, 2, 2, CAST(N'2025-06-26' AS Date), CAST(N'2025-06-27' AS Date), N'CONFIRMED', CAST(500000.00 AS Decimal(10, 2)), N'', CAST(N'2025-06-24T10:25:22.257' AS DateTime), NULL, NULL, 0, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2027, 1002, NULL, NULL, 2, CAST(N'2025-06-27' AS Date), CAST(N'2025-06-28' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-24T10:37:01.410' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-24T10:55:41.517' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2028, 2003, NULL, NULL, 13, CAST(N'2025-06-25' AS Date), CAST(N'2025-06-27' AS Date), N'PENDING', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: US', CAST(N'2025-06-24T11:38:26.760' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2029, 2004, NULL, NULL, 10, CAST(N'2025-06-25' AS Date), CAST(N'2025-06-27' AS Date), N'PENDING', CAST(5110000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-25T18:11:07.010' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (2030, 1002, NULL, NULL, 5, CAST(N'2025-07-01' AS Date), CAST(N'2025-07-02' AS Date), N'CONFIRMED', CAST(4000000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-25T22:12:33.857' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-01T10:29:36.570' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3029, 10, NULL, NULL, 5, CAST(N'2025-06-28' AS Date), CAST(N'2025-06-29' AS Date), N'PENDING', CAST(2300000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T00:41:51.053' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3030, 10, NULL, NULL, 1, CAST(N'2025-06-30' AS Date), CAST(N'2025-07-01' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T01:25:23.320' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3031, 10, NULL, NULL, 1, CAST(N'2025-07-01' AS Date), CAST(N'2025-07-02' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T01:25:47.670' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3032, 11, NULL, NULL, 1, CAST(N'2025-07-04' AS Date), CAST(N'2025-07-05' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T15:49:58.533' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-04T07:37:34.300' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3033, 11, NULL, NULL, 2, CAST(N'2025-07-04' AS Date), CAST(N'2025-07-05' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T15:52:57.133' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3034, 11, NULL, NULL, 2, CAST(N'2025-06-30' AS Date), CAST(N'2025-07-01' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T16:03:52.057' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3035, 11, NULL, NULL, 13, CAST(N'2025-06-30' AS Date), CAST(N'2025-07-01' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T16:04:09.220' AS DateTime), NULL, NULL, 1, CAST(N'2025-06-28T16:05:04.247' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3036, 10, NULL, NULL, 1, CAST(N'2025-07-02' AS Date), CAST(N'2025-07-03' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T16:39:06.820' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3037, 10, NULL, NULL, 2, CAST(N'2025-07-02' AS Date), CAST(N'2025-07-03' AS Date), N'PENDING', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T16:42:34.787' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3038, 1002, NULL, NULL, 13, CAST(N'2025-07-04' AS Date), CAST(N'2025-07-05' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T17:17:57.200' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-28T17:18:15.400' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3039, 1002, NULL, NULL, 3, CAST(N'2025-07-04' AS Date), CAST(N'2025-07-05' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T17:53:03.200' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-28T17:53:16.233' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3040, 1002, NULL, NULL, 11, CAST(N'2025-07-03' AS Date), CAST(N'2025-07-04' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T18:05:18.040' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-28T18:05:35.590' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3041, 1002, NULL, NULL, 1, CAST(N'2025-07-12' AS Date), CAST(N'2025-07-13' AS Date), N'CANCELLED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T18:13:47.637' AS DateTime), NULL, NULL, 0, CAST(N'2025-07-03T22:31:28.503' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3042, 2004, NULL, NULL, 4, CAST(N'2025-07-03' AS Date), CAST(N'2025-07-04' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T18:18:20.383' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-28T18:18:37.043' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3043, 2004, NULL, NULL, 1, CAST(N'2025-07-05' AS Date), CAST(N'2025-07-06' AS Date), N'PENDING', CAST(500000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T18:52:54.937' AS DateTime), NULL, N'', 1, CAST(N'2025-07-04T08:44:25.863' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3044, 2004, NULL, NULL, 1, CAST(N'2025-07-05' AS Date), CAST(N'2025-07-06' AS Date), N'CONFIRMED', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-28T19:03:28.097' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-28T19:03:36.760' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3045, 2004, NULL, 2, 4, CAST(N'2025-06-29' AS Date), CAST(N'2025-06-30' AS Date), N'CONFIRMED', CAST(1200000.00 AS Decimal(10, 2)), N'', CAST(N'2025-06-29T17:20:12.627' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-29T17:34:44.843' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3046, 1002, NULL, NULL, 1, CAST(N'2025-06-29' AS Date), CAST(N'2025-06-30' AS Date), N'CONFIRMED', CAST(750000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-06-29T18:10:22.083' AS DateTime), NULL, NULL, 0, CAST(N'2025-06-29T18:12:32.910' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3047, 2004, NULL, NULL, 2, CAST(N'2025-07-01' AS Date), CAST(N'2025-07-02' AS Date), N'CONFIRMED', CAST(900000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-07-01T21:02:33.380' AS DateTime), NULL, NULL, 0, CAST(N'2025-07-01T21:03:10.080' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3048, 2004, NULL, NULL, 13, CAST(N'2025-07-02' AS Date), CAST(N'2025-07-03' AS Date), N'CONFIRMED', CAST(1400000.00 AS Decimal(10, 2)), N'Adults: 2, Children: 0, Nationality: VN', CAST(N'2025-07-01T23:22:22.253' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-01T23:22:27.900' AS DateTime), CAST(140000.00 AS Decimal(10, 2)), CAST(N'2025-07-01T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3049, 2004, NULL, NULL, 2, CAST(N'2025-07-03' AS Date), CAST(N'2025-07-04' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: VN', CAST(N'2025-07-03T21:17:27.717' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-03T21:17:47.350' AS DateTime), CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3050, 2004, NULL, NULL, 13, CAST(N'2025-07-03' AS Date), CAST(N'2025-07-04' AS Date), N'CONFIRMED', CAST(900000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: VN', CAST(N'2025-07-03T21:26:28.880' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-03T22:01:03.600' AS DateTime), CAST(90000.00 AS Decimal(10, 2)), CAST(N'2025-07-03T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3051, 2004, NULL, NULL, 6, CAST(N'2025-07-05' AS Date), CAST(N'2025-07-06' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: VN', CAST(N'2025-07-04T08:19:52.960' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3052, 3006, NULL, NULL, 6, CAST(N'2025-07-08' AS Date), CAST(N'2025-07-09' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-08T23:32:17.017' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3053, 3006, NULL, NULL, 6, CAST(N'2025-07-09' AS Date), CAST(N'2025-07-10' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-09T01:43:13.547' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-09T01:43:23.750' AS DateTime), CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-09T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3054, 3006, NULL, NULL, 10, CAST(N'2025-07-09' AS Date), CAST(N'2025-07-10' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-09T01:43:13.640' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3055, 3006, NULL, NULL, 3, CAST(N'2025-07-09' AS Date), CAST(N'2025-07-10' AS Date), N'PENDING', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-09T01:43:13.737' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3056, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.243' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-10T01:05:16.907' AS DateTime), CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3057, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.423' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3058, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.540' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3059, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.653' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-16T20:31:09.233' AS DateTime), CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-16T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3060, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.780' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3061, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:08.903' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3062, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:09.030' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3063, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:09.143' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3064, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:09.257' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-14T23:59:15.690' AS DateTime), CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3065, 3006, NULL, NULL, 6, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-11' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T01:05:09.390' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3066, 3006, NULL, NULL, 10, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-17' AS Date), N'CONFIRMED', CAST(6160000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T23:41:21.060' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-10T23:41:48.147' AS DateTime), CAST(616000.00 AS Decimal(10, 2)), CAST(N'2025-07-10T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3067, 3006, NULL, NULL, 3, CAST(N'2025-07-10' AS Date), CAST(N'2025-07-17' AS Date), N'CONFIRMED', CAST(6930000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-10T23:41:21.257' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-14T23:58:53.187' AS DateTime), CAST(6930000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3068, 3006, NULL, NULL, 6, CAST(N'2025-07-11' AS Date), CAST(N'2025-07-12' AS Date), N'PENDING', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T22:29:28.753' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3069, 3006, NULL, NULL, 14, CAST(N'2025-07-11' AS Date), CAST(N'2025-07-12' AS Date), N'PENDING', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T22:29:28.923' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3070, 3006, NULL, NULL, 15, CAST(N'2025-07-11' AS Date), CAST(N'2025-07-12' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T22:37:28.900' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-11T22:38:43.183' AS DateTime), CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3071, 3006, NULL, NULL, 8, CAST(N'2025-07-11' AS Date), CAST(N'2025-07-12' AS Date), N'CONFIRMED', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T22:37:29.027' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-11T22:38:43.277' AS DateTime), CAST(121000.00 AS Decimal(10, 2)), CAST(N'2025-07-11T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3072, 3006, NULL, NULL, 14, CAST(N'2025-07-12' AS Date), CAST(N'2025-07-13' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T23:34:52.240' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-11T23:37:05.943' AS DateTime), CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-11T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3073, 3006, NULL, NULL, 15, CAST(N'2025-07-12' AS Date), CAST(N'2025-07-13' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-11T23:34:52.377' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-11T23:37:06.020' AS DateTime), CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-11T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3074, 3006, NULL, NULL, 14, CAST(N'2025-07-14' AS Date), CAST(N'2025-07-15' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T00:00:53.823' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T00:21:16.420' AS DateTime), CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3075, 3006, NULL, NULL, 15, CAST(N'2025-07-14' AS Date), CAST(N'2025-07-15' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T00:01:02.670' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T00:21:16.813' AS DateTime), CAST(115500.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3076, 1002, NULL, NULL, 10, CAST(N'2025-07-24' AS Date), CAST(N'2025-07-25' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T00:33:57.613' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T01:19:09.950' AS DateTime), CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3077, 1002, NULL, NULL, 15, CAST(N'2025-07-24' AS Date), CAST(N'2025-07-25' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T00:34:02.683' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T01:19:10.060' AS DateTime), CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3078, 3006, NULL, NULL, 1003, CAST(N'2025-07-19' AS Date), CAST(N'2025-07-20' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T01:35:59.603' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T01:45:15.483' AS DateTime), CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3079, 3006, NULL, NULL, 3, CAST(N'2025-07-19' AS Date), CAST(N'2025-07-20' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-12T01:35:59.750' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-12T01:45:15.573' AS DateTime), CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-12T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (3080, 3007, NULL, NULL, 1002, CAST(N'2025-07-14' AS Date), CAST(N'2025-07-15' AS Date), N'CONFIRMED', CAST(3300000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-14T02:07:39.450' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4080, 1002, NULL, NULL, 1005, CAST(N'2025-07-26' AS Date), CAST(N'2025-07-27' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-14T08:36:57.920' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-14T08:37:53.927' AS DateTime), CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4081, 1002, NULL, NULL, 14, CAST(N'2025-07-15' AS Date), CAST(N'2025-07-16' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-14T22:39:16.003' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-14T22:40:15.177' AS DateTime), CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4082, 1002, NULL, NULL, 1005, CAST(N'2025-07-14' AS Date), CAST(N'2025-07-16' AS Date), N'PENDING', CAST(3300000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-14T23:17:18.410' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4083, 1002, NULL, NULL, 15, CAST(N'2025-07-26' AS Date), CAST(N'2025-07-27' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-14T23:48:35.530' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-14T23:50:02.610' AS DateTime), CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-14T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4084, 1002, NULL, NULL, 1, CAST(N'2025-07-17' AS Date), CAST(N'2025-07-18' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T00:17:39.243' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-17T14:26:33.943' AS DateTime), CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4085, 1002, NULL, NULL, 2, CAST(N'2025-07-16' AS Date), CAST(N'2025-07-18' AS Date), N'CONFIRMED', CAST(1100000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T00:29:54.833' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T00:30:32.877' AS DateTime), CAST(110000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4086, 1002, NULL, NULL, 1, CAST(N'2025-07-26' AS Date), CAST(N'2025-07-27' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T00:41:04.030' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T00:41:46.803' AS DateTime), CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4087, 1002, NULL, NULL, 13, CAST(N'2025-07-17' AS Date), CAST(N'2025-07-18' AS Date), N'CONFIRMED', CAST(550000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T00:43:31.293' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-17T20:48:01.610' AS DateTime), CAST(55000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (4088, 1002, NULL, NULL, 1005, CAST(N'2025-07-25' AS Date), CAST(N'2025-07-26' AS Date), N'CONFIRMED', CAST(1650000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T00:54:35.097' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T00:55:38.090' AS DateTime), CAST(165000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5085, 3005, NULL, NULL, 15, CAST(N'2025-07-15' AS Date), CAST(N'2025-07-16' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T10:27:01.600' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T10:45:25.797' AS DateTime), CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5086, 3005, NULL, NULL, 3, CAST(N'2025-07-25' AS Date), CAST(N'2025-07-26' AS Date), N'PENDING', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T11:16:03.320' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5087, 3005, NULL, NULL, 15, CAST(N'2025-07-25' AS Date), CAST(N'2025-07-26' AS Date), N'PENDING', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T11:16:03.470' AS DateTime), NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5088, 3005, NULL, NULL, 3, CAST(N'2025-07-26' AS Date), CAST(N'2025-07-27' AS Date), N'CONFIRMED', CAST(990000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T11:17:10.040' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T11:28:46.333' AS DateTime), CAST(99000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5089, 3005, NULL, NULL, 10, CAST(N'2025-07-26' AS Date), CAST(N'2025-07-27' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-15T11:17:10.160' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-15T11:28:43.920' AS DateTime), CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-15T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (5090, 3007, NULL, 2, 2, CAST(N'2025-07-18' AS Date), CAST(N'2025-07-20' AS Date), N'CONFIRMED', CAST(1000000.00 AS Decimal(10, 2)), N'', CAST(N'2025-07-18T09:20:35.540' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-18T09:22:26.603' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6090, 1002, NULL, NULL, 15, CAST(N'2025-07-20' AS Date), CAST(N'2025-07-21' AS Date), N'CONFIRMED', CAST(1320000.00 AS Decimal(10, 2)), N'Adults: 3, Children: 0, Nationality: N/A', CAST(N'2025-07-20T20:28:22.597' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-20T20:31:59.140' AS DateTime), CAST(132000.00 AS Decimal(10, 2)), CAST(N'2025-07-20T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6091, 1002, NULL, NULL, 6, CAST(N'2025-07-21' AS Date), CAST(N'2025-07-22' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:17:23.077' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T16:40:34.337' AS DateTime), CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6092, 1002, NULL, NULL, 10, CAST(N'2025-07-21' AS Date), CAST(N'2025-07-22' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:17:23.213' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T16:40:51.453' AS DateTime), CAST(88000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6093, 1002, NULL, NULL, 8, CAST(N'2025-07-22' AS Date), CAST(N'2025-07-24' AS Date), N'CANCELLED', CAST(2200000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:19:22.590' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T16:22:14.653' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6094, 2004, NULL, NULL, 6, CAST(N'2025-07-22' AS Date), CAST(N'2025-07-23' AS Date), N'CANCELLED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:26:34.260' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T16:30:48.120' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6095, 1002, NULL, NULL, 8, CAST(N'2025-07-22' AS Date), CAST(N'2025-07-24' AS Date), N'CANCELLED', CAST(2200000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:39:36.463' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T17:14:25.820' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6096, 2004, NULL, NULL, 5, CAST(N'2025-07-22' AS Date), CAST(N'2025-07-24' AS Date), N'CANCELLED', CAST(3300000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:48:30.183' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T17:14:21.410' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6097, 1002, NULL, NULL, 4, CAST(N'2025-07-23' AS Date), CAST(N'2025-07-25' AS Date), N'CONFIRMED', CAST(2640000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:59:47.250' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T17:22:09.337' AS DateTime), CAST(2640000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6098, 1002, NULL, NULL, 6, CAST(N'2025-07-23' AS Date), CAST(N'2025-07-25' AS Date), N'CONFIRMED', CAST(1760000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T16:59:47.410' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T17:22:07.513' AS DateTime), CAST(1760000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T00:00:00.000' AS DateTime), N'PAID')
INSERT [dbo].[Reservations] ([Id], [UserId], [GroupBookingId], [CreatedBy], [RoomId], [CheckIn], [CheckOut], [Status], [TotalAmount], [Notes], [CreatedAt], [RoomTypeId], [SpecialRequests], [NumberOfCustomers], [UpdatedAt], [DepositAmount], [DepositPaidDate], [DepositStatus]) VALUES (6099, 1002, NULL, NULL, 6, CAST(N'2025-07-22' AS Date), CAST(N'2025-07-23' AS Date), N'CONFIRMED', CAST(880000.00 AS Decimal(10, 2)), N'Adults: 1, Children: 0, Nationality: N/A', CAST(N'2025-07-21T17:02:42.917' AS DateTime), NULL, NULL, 1, CAST(N'2025-07-21T17:22:03.223' AS DateTime), CAST(880000.00 AS Decimal(10, 2)), CAST(N'2025-07-21T00:00:00.000' AS DateTime), N'PAID')
SET IDENTITY_INSERT [dbo].[Reservations] OFF
GO
SET IDENTITY_INSERT [dbo].[ReservationServices] ON 

INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1, 1, 1, 2, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2, 2, 2, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (3, 3, 3, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (4, 3, 4, 3, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1002, 2029, 1006, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1003, 2029, 1012, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1004, 2030, 2, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1005, 2030, 1006, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (1006, 2030, 1011, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2002, 3029, 1006, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2003, 3029, 1, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2004, 3044, 2, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2005, 3044, 1002, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2006, 3046, 2, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2007, 3047, 1006, 1, N'PENDING', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2008, 3048, 1006, 1, N'CONFIRMED', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2009, 3048, 1009, 1, N'CONFIRMED', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (2010, 3050, 1006, 1, N'CONFIRMED', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (3015, 4084, 1012, 2, N'CANCELLED', NULL, CAST(N'2025-07-20T20:10:37.640' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (4015, 6090, 1006, 3, N'CANCELLED', 1002, CAST(N'2025-07-20T20:32:31.290' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (4019, 6090, 1006, 2, N'CONFIRMED', 1002, CAST(N'2025-07-21T00:36:52.507' AS DateTime))
INSERT [dbo].[ReservationServices] ([Id], [ReservationId], [ServiceId], [Quantity], [Status], [CreatedBy], [CreatedAt]) VALUES (5016, 6090, 1015, 3, N'CONFIRMED', 1002, CAST(N'2025-07-21T08:50:43.217' AS DateTime))
SET IDENTITY_INSERT [dbo].[ReservationServices] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomAmenities] ON 

INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (1, 1, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (2, 2, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (3, 3, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (4, 4, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (5, 5, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (6, 6, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (7, 7, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (8, 8, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (9, 9, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (10, 10, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (11, 11, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (12, 12, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (13, 13, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (14, 14, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (15, 15, N'Mini Bar - Beer', N'Local beer 330ml', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (16, 1, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (17, 2, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (18, 3, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (19, 4, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (20, 5, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (21, 6, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (22, 7, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (23, 8, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (24, 9, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (25, 10, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (26, 11, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (27, 12, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (28, 13, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (29, 14, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (30, 15, N'Mini Bar - Soft Drink', N'Coca Cola, Pepsi 330ml', CAST(30000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (31, 1, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (32, 2, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (33, 3, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (34, 4, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (35, 5, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (36, 6, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (37, 7, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (38, 8, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (39, 9, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (40, 10, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (41, 11, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (42, 12, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (43, 13, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (44, 14, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (45, 15, N'Mini Bar - Snacks', N'Chips, Nuts', CAST(40000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (46, 1, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (47, 2, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (48, 3, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (49, 4, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (50, 5, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (51, 6, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (52, 7, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (53, 8, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (54, 9, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (55, 10, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (56, 11, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (57, 12, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (58, 13, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (59, 14, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (60, 15, N'Mini Bar - Water', N'Bottled water 500ml', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (61, 1, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (62, 2, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (63, 3, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (64, 4, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (65, 5, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (66, 6, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (67, 7, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (68, 8, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (69, 9, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (70, 10, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (71, 11, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (72, 12, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (73, 13, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (74, 14, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (75, 15, N'Laundry Service', N'Per piece', CAST(50000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (76, 1, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (77, 2, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (78, 3, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (79, 4, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (80, 5, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (81, 6, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (82, 7, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (83, 8, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (84, 9, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (85, 10, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (86, 11, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (87, 12, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (88, 13, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (89, 14, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (90, 15, N'Extra Towel', N'Per piece', CAST(20000.00 AS Decimal(10, 2)), 1, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (91, 1, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (92, 2, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (93, 3, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (94, 4, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (95, 5, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (96, 6, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (97, 7, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (98, 8, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (99, 9, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
GO
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (100, 10, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (101, 11, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (102, 12, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (103, 13, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (104, 14, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (105, 15, N'Bathrobe', N'Complimentary', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (106, 1, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (107, 2, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (108, 3, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (109, 4, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (110, 5, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (111, 6, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (112, 7, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (113, 8, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (114, 9, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (115, 10, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (116, 11, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (117, 12, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (118, 13, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (119, 14, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
INSERT [dbo].[RoomAmenities] ([Id], [RoomId], [Name], [Description], [UnitPrice], [IsChargeable], [CreatedAt]) VALUES (120, 15, N'Toiletries', N'Shampoo, Soap, etc.', CAST(0.00 AS Decimal(10, 2)), 0, CAST(N'2025-06-18T21:59:21.120' AS DateTime))
SET IDENTITY_INSERT [dbo].[RoomAmenities] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomDamages] ON 

INSERT [dbo].[RoomDamages] ([Id], [InspectionId], [DamageType], [Description], [EstimatedCost], [PhotoUrl], [Severity]) VALUES (1, 2, N'FURNITURE', N'Scratch on bedside table surface', CAST(300000.00 AS Decimal(10, 2)), N'damage_photos/room103_table_scratch.jpg', N'MINOR')
SET IDENTITY_INSERT [dbo].[RoomDamages] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomEquipment] ON 

INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (1, 1, 1, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (2, 1, 2, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (3, 1, 4, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (4, 3, 1, 2)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (5, 3, 2, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (6, 3, 3, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (7, 3, 4, 1)
INSERT [dbo].[RoomEquipment] ([Id], [RoomId], [EquipmentId], [Quantity]) VALUES (8, 3, 5, 2)
SET IDENTITY_INSERT [dbo].[RoomEquipment] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomInspections] ON 

INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (1, 1, 8, CAST(N'2025-06-18T21:59:21.180' AS DateTime), N'GOOD', 8, N'Guest used minibar. Room in good condition, no damage found.', NULL, N'COMPLETED', 2, CAST(N'2025-06-18T21:59:21.213' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2, 3, 8, CAST(N'2025-06-18T21:59:21.227' AS DateTime), N'FAIR', 6, N'Found some damage to furniture and stains on carpet. Extra cleaning required.', NULL, N'COMPLETED', 2, CAST(N'2025-06-18T21:59:21.250' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3, 5, 9, CAST(N'2025-06-18T21:59:21.267' AS DateTime), N'EXCELLENT', 9, N'VIP guest maintained room in excellent condition. Heavy minibar usage noted.', NULL, N'COMPLETED', 1, CAST(N'2025-06-18T21:59:21.287' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (4, 6, 8, CAST(N'2025-06-19T01:08:46.427' AS DateTime), N'GOOD', 1, N'ok good', NULL, N'COMPLETED', 8, CAST(N'2025-06-19T01:12:30.997' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (1002, 1002, 8, CAST(N'2025-06-20T10:23:59.727' AS DateTime), N'EXCELLENT', 10, N'okokokoko', NULL, N'COMPLETED', 8, CAST(N'2025-06-20T10:26:19.427' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2002, 2012, 8, CAST(N'2025-06-24T10:27:40.580' AS DateTime), N'EXCELLENT', 10, N'all ok', NULL, N'COMPLETED', 8, CAST(N'2025-06-24T10:27:58.357' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2003, 2022, 8, CAST(N'2025-06-24T11:12:16.887' AS DateTime), N'DAMAGED', 10, N'thang nay dung nhu pha', NULL, N'COMPLETED', 8, CAST(N'2025-06-24T11:13:04.117' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2004, 2024, 8, CAST(N'2025-06-24T11:13:35.320' AS DateTime), N'DAMAGED', 1, N'lỗi', NULL, N'COMPLETED', 8, CAST(N'2025-06-26T21:23:27.673' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2005, 2025, 8, CAST(N'2025-06-26T21:21:48.010' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-06-29T21:14:59.450' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2006, 2026, 8, CAST(N'2025-06-29T22:36:34.140' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-06-29T22:36:42.600' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2007, 2023, 8, CAST(N'2025-07-01T11:43:30.597' AS DateTime), N'GOOD', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-01T11:43:41.610' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (2008, 2027, 8, CAST(N'2025-07-01T12:06:05.433' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-01T12:09:18.397' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3007, 3045, 8, CAST(N'2025-07-04T09:10:58.500' AS DateTime), N'POOR', 7, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:41:17.480' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3008, 3046, 8, CAST(N'2025-07-21T07:41:28.607' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:41:31.897' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3009, 3035, 8, CAST(N'2025-07-21T07:41:54.850' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:42:03.423' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3010, 3047, 8, CAST(N'2025-07-21T07:42:19.317' AS DateTime), N'GOOD', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:42:22.940' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3011, 2030, 8, CAST(N'2025-07-21T07:42:32.690' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:42:40.240' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3012, 3048, 8, CAST(N'2025-07-21T07:42:56.280' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:42:58.870' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3013, 3049, 8, CAST(N'2025-07-21T07:43:14.017' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:43:16.060' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3014, 3050, 8, CAST(N'2025-07-21T07:43:23.333' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:43:25.027' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3015, 6090, 8, CAST(N'2025-07-21T07:43:46.127' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:43:48.927' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3016, 3040, 8, CAST(N'2025-07-21T07:43:55.023' AS DateTime), N'GOOD', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:43:56.800' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3017, 3042, 8, CAST(N'2025-07-21T07:44:03.090' AS DateTime), N'GOOD', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:44:07.390' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3018, 3038, 8, CAST(N'2025-07-21T07:44:12.870' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:44:14.503' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3019, 5090, 8, CAST(N'2025-07-21T07:44:25.717' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:44:27.677' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3020, 3079, 8, CAST(N'2025-07-21T07:45:00.480' AS DateTime), N'EXCELLENT', 9, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:45:03.307' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3021, 3078, 8, CAST(N'2025-07-21T07:45:24.593' AS DateTime), N'GOOD', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:45:26.850' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3022, 4087, 8, CAST(N'2025-07-21T07:45:36.970' AS DateTime), N'EXCELLENT', 9, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:45:44.647' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3023, 4085, 8, CAST(N'2025-07-21T07:45:51.247' AS DateTime), N'EXCELLENT', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:45:53.230' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3024, 4084, 8, CAST(N'2025-07-21T07:45:59.793' AS DateTime), N'EXCELLENT', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:46:02.030' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3025, 3067, 8, CAST(N'2025-07-21T07:46:24.020' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:46:26.427' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3026, 3066, 8, CAST(N'2025-07-21T07:46:38.263' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:46:40.063' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3027, 5085, 8, CAST(N'2025-07-21T07:46:55.430' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:46:57.700' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3028, 3039, 8, CAST(N'2025-07-21T07:47:03.813' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:47:05.673' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3029, 3032, 8, CAST(N'2025-07-21T07:47:15.997' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:47:18.460' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3030, 3044, 8, CAST(N'2025-07-21T07:47:24.287' AS DateTime), N'FAIR', 7, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:47:26.410' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3031, 3053, 8, CAST(N'2025-07-21T07:47:30.993' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:47:33.393' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3032, 3056, 8, CAST(N'2025-07-21T07:47:51.697' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:47:53.870' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3033, 3059, 8, CAST(N'2025-07-21T07:47:59.850' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:01.647' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3034, 3064, 8, CAST(N'2025-07-21T07:48:06.900' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:08.737' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3035, 3070, 8, CAST(N'2025-07-21T07:48:28.830' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:30.750' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3036, 3071, 8, CAST(N'2025-07-21T07:48:37.160' AS DateTime), N'GOOD', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:38.733' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3037, 3072, 8, CAST(N'2025-07-21T07:48:44.893' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:46.667' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3038, 3073, 8, CAST(N'2025-07-21T07:48:52.680' AS DateTime), N'EXCELLENT', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:48:54.503' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3039, 3074, 8, CAST(N'2025-07-21T07:48:59.063' AS DateTime), N'GOOD', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:49:00.750' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3040, 3075, 8, CAST(N'2025-07-21T07:49:05.683' AS DateTime), N'GOOD', 10, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:49:07.970' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3041, 3080, 8, CAST(N'2025-07-21T07:49:12.270' AS DateTime), N'EXCELLENT', 9, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:49:14.117' AS DateTime))
INSERT [dbo].[RoomInspections] ([Id], [ReservationId], [InspectorId], [InspectionTime], [RoomCondition], [CleanlinessScore], [Notes], [PhotoUrls], [Status], [ApprovedBy], [ApprovedAt]) VALUES (3042, 4081, 8, CAST(N'2025-07-21T07:49:20.080' AS DateTime), N'EXCELLENT', 8, N'', NULL, N'COMPLETED', 8, CAST(N'2025-07-21T07:49:21.960' AS DateTime))
SET IDENTITY_INSERT [dbo].[RoomInspections] OFF
GO
SET IDENTITY_INSERT [dbo].[Rooms] ON 

INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1, N'101', 1, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (2, N'102', 1, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (3, N'103', 4, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (4, N'104', 5, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (5, N'105', 6, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (6, N'201', 2, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (7, N'202', 2, N'MAINTENANCE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (8, N'203', 7, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (9, N'204', 8, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (10, N'205', 2, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (11, N'301', 3, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (12, N'302', 3, N'DIRTY', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (13, N'303', 1, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (14, N'304', 4, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (15, N'305', 5, N'OCCUPIED', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1002, N'501', 1002, N'AVAILABLE', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1003, N'502', 6, N'HELD', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1004, N'503', 7, N'HELD', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1005, N'504', 8, N'HELD', NULL)
INSERT [dbo].[Rooms] ([Id], [RoomNumber], [RoomTypeId], [Status], [HoldUntil]) VALUES (1006, N'505', 1002, N'AVAILABLE', NULL)
SET IDENTITY_INSERT [dbo].[Rooms] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomTypeImages] ON 

INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2, 7, N'single_bathroom.jpg', N'bathroom', 2, CAST(N'2025-06-18T21:59:21.017' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1002, 1, N'overview.jpg', N'Single', 1, CAST(N'2025-07-01T11:32:54.010' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1003, 1, N'overview2.jpg', N'Single', 2, CAST(N'2025-07-01T11:32:54.060' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1004, 1, N'window.jpg', N'Single', 3, CAST(N'2025-07-01T11:32:54.110' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1005, 1, N'table.jpg', N'Single', 4, CAST(N'2025-07-01T11:32:54.157' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1006, 1, N'bathroom.jpg', N'Single', 5, CAST(N'2025-07-01T11:32:54.207' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1007, 1, N'amenities.webp', N'Single', 6, CAST(N'2025-07-01T11:32:54.250' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1008, 1, N'amenities2.webp', N'Single', 7, CAST(N'2025-07-01T11:32:54.290' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (1009, 1, N'amenities3.webp', N'Single', 8, CAST(N'2025-07-01T11:32:54.320' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2002, 4, N'overview.jpg', N'Single', 1, CAST(N'2025-07-04T09:00:51.513' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2003, 4, N'overview2.jpg', N'Single', 2, CAST(N'2025-07-04T09:00:51.563' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2004, 4, N'window.jpg', N'Single', 3, CAST(N'2025-07-04T09:00:51.620' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2005, 4, N'table.jpg', N'Single', 4, CAST(N'2025-07-04T09:00:51.667' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2006, 4, N'bathroom.jpg', N'Single', 5, CAST(N'2025-07-04T09:00:51.730' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2007, 4, N'amenities.webp', N'Single', 6, CAST(N'2025-07-04T09:00:51.770' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2008, 4, N'amenities2.webp', N'Single', 7, CAST(N'2025-07-04T09:00:51.810' AS DateTime))
INSERT [dbo].[RoomTypeImages] ([Id], [RoomTypeId], [ImageUrl], [ImageType], [DisplayOrder], [CreatedAt]) VALUES (2009, 4, N'amenities3.webp', N'Single', 8, CAST(N'2025-07-04T09:00:51.847' AS DateTime))
SET IDENTITY_INSERT [dbo].[RoomTypeImages] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomTypes] ON 

INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (1, N'Single', N'Single room with one bed,Single Bed,Free WiFi, Air Conditioning', CAST(500000.00 AS Decimal(10, 2)), N'single.jpg', 1, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-07-01T11:32:53.890' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (2, N'Double', N'Double room with two beds, City view, Free WiFi, Air Conditioning, Mini Bar', CAST(800000.00 AS Decimal(10, 2)), N'double.jpg', 2, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-24T11:46:52.597' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (3, N'Suite', N'Luxury suite with living area, Kitchen, Free WiFi, Air Conditioning, Jacuzzi', CAST(1500000.00 AS Decimal(10, 2)), N'suite.jpg', 4, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-24T11:47:04.730' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (4, N'Twin', N'Two single beds side by side,Double Bed,', CAST(900000.00 AS Decimal(10, 2)), N'twin.jpg', 2, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-07-04T09:00:51.377' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (5, N'Triple', N'Three single beds or one double + one single bed', CAST(1200000.00 AS Decimal(10, 2)), N'triple.jpg', 3, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-18T21:59:21.007' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (6, N'Family', N'Spacious room with 2 double beds or double + sofa bed', CAST(1500000.00 AS Decimal(10, 2)), N'family.jpg', 4, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-18T21:59:21.007' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (7, N'Deluxe', N'Spacious with sofa, Work desk, Great view', CAST(1000000.00 AS Decimal(10, 2)), N'deluxe.jpg', 2, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-24T11:47:28.003' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (8, N'Executive', N'Business room with executive lounge access, Sleep with Tran Ha Linh + ....., Free BCS', CAST(1500000.00 AS Decimal(10, 2)), N'executive.jpg', 2, N'active', CAST(N'2025-06-18T21:59:21.007' AS DateTime), CAST(N'2025-06-24T11:49:34.310' AS DateTime))
INSERT [dbo].[RoomTypes] ([Id], [Name], [Description], [BasePrice], [imageUrl], [Capacity], [Status], [CreatedAt], [UpdatedAt]) VALUES (1002, N'Presidential Suite', N'Top VIP suite with premium amenities', CAST(3000000.00 AS Decimal(10, 2)), N'presidential_suite.jpg', 6, N'active', CAST(N'2025-06-30T22:19:32.750' AS DateTime), CAST(N'2025-06-30T22:19:32.750' AS DateTime))
SET IDENTITY_INSERT [dbo].[RoomTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[SecurityAuditLog] ON 

INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1, 10, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 10, N'EMAIL', N'david@gmail.com', N'new.email@example.com', N'Customer requested email update', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-22T23:26:18.410' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (2, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-22T23:51:55.423' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (3, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieulvhe187167@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-22T23:53:51.057' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (4, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-23T00:05:33.633' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (5, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-23T00:05:49.710' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (6, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-23T00:08:00.540' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (7, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieulvhe187167@fpt.edu.vn', N'Admin requested email change from baotrieu300@gmail.com to trieulvhe187167@fpt.edu.vn', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T18:10:59.153' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (8, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieulvhe1871678@fpt.edu.vn', N'Admin requested email change from baotrieu300@gmail.com to trieulvhe1871678@fpt.edu.vn', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T22:40:00.963' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (9, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-23T22:49:24.630' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (10, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'EMAIL', NULL, N'trieulvhe1871678@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-23T22:49:24.633' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (11, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0908070690', N'Admin requested phone change from 0385217604 to 0908070690', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T22:50:48.223' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (12, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'Admin requested phone change from 0385217604 to 0123456789', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T22:58:23.470' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (13, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T22:59:31.410' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (14, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:03:49.050' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (15, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:07:54.070' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (16, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:10:55.907' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (17, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:13:46.957' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (18, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:15:07.460' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (19, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:18:15.193' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (20, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'trieulvhe1871678@fpt.edu.vn', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:21:35.067' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (21, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:24:26.513' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (22, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:30:03.370' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (23, 7, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 7, N'PHONE', N'0911223345', N'0911223345', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:30:24.160' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (24, 10, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 10, N'PHONE', N'0900000000', N'0900000000', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:31:17.410' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (25, 10, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 10, N'EMAIL', N'david@gmail.com', N'david@gmail.com', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:33:45.303' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (26, 10, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 10, N'EMAIL', N'david@gmail.com', N'david@gmail.com', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:35:28.290' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (27, 10, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 10, N'PHONE', N'0900000000', N'0900000000', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:36:08.487' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (28, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'trieulvhe1871678@fpt.edu.vn', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:38:45.473' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (29, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:42:14.880' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (30, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'trieulvhe1871678@fpt.edu.vn', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-23T23:43:02.330' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (31, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T00:04:22.297' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (32, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T00:10:13.183' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1020, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:39:34.337' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1021, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:40:05.880' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1022, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'baotrieu300@gmail.com', N'Admin requested email change from trieulvhe1871678@fpt.edu.vn to baotrieu300@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:42:16.770' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1023, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:44:20.160' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1024, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:45:23.733' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1025, 1, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1, N'PHONE', N'0123456789', N'0888888888', N'Admin requested phone change from 0123456789 to 0888888888', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T07:49:30.440' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1026, 1, 1, N'PHONE_CHANGED', N'USER', 1, N'PHONE', N'0123456789', N'0888888888', NULL, NULL, NULL, NULL, N'MEDIUM', 0, NULL, CAST(N'2025-06-24T07:51:14.840' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1027, 1, 1, N'CHANGE_REQUEST_APPROVED', N'USER', 1, N'PHONE', NULL, N'0888888888', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T07:51:14.847' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1028, 2002, 2002, N'EMAIL_CHANGED', N'USER', 2002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'trieulvhe18716@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:31:01.470' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1029, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieulvhe1871678@fpt.edu.vn', N'trieulvhe187167@fpt.edu.vn', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:31:12.503' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1030, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:32:11.437' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1031, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:32:48.523' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1032, 1002, 1002, N'PHONE_CHANGED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', NULL, NULL, NULL, NULL, N'MEDIUM', 0, NULL, CAST(N'2025-06-24T09:34:03.303' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1033, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'PHONE', NULL, N'0123456789', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:34:03.307' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1034, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:34:59.867' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1035, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:35:52.327' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1036, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0123456789', N'0385217604', N'Admin requested phone change from 0123456789 to 0385217604', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:35:57.927' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1037, 1002, 1002, N'PHONE_CHANGED', N'USER', 1002, N'PHONE', N'0123456789', N'0385217604', NULL, NULL, NULL, NULL, N'MEDIUM', 0, NULL, CAST(N'2025-06-24T09:38:36.100' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1038, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'PHONE', NULL, N'0385217604', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:38:36.103' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1039, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', N'Admin requested email change from trieulvhe187167@fpt.edu.vn to baotrieu300@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:39:13.177' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1040, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:39:29.403' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1041, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'EMAIL', NULL, N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-06-24T09:39:29.403' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1042, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:40:16.327' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1043, 1, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1, N'PHONE', N'0888888888', N'0999999999', N'Admin requested phone change from 0888888888 to 0999999999', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:44:27.190' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1044, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'PHONE', N'0385217604', N'0123456789', N'Admin requested phone change from 0385217604 to 0123456789', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-24T09:51:15.583' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1045, 2004, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 2004, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-26T20:49:02.940' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1046, 2004, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 2004, N'PHONE', N'0385217604', N'0385217604', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-26T20:58:35.603' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1047, 2004, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 2004, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'trieulvhe187167@fpt.edu.vn', N'', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-26T20:58:44.140' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1048, 2004, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 2004, N'EMAIL', N'trieulvhe187167@fpt.edu.vn', N'levantrieu170604@gmail.com', N'Admin requested email change from trieulvhe187167@fpt.edu.vn to levantrieu170604@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-28T17:54:55.853' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1049, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'levantrieu170604@gmail.com', N'Admin requested email change for customer', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-29T01:39:47.393' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1050, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'levantrieu170604@gmail.com', N'Admin requested email change from baotrieu300@gmail.com to levantrieu170604@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-29T15:35:04.580' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1051, 1002, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'levantrieu170604@gmail.com', N'Admin requested email change from baotrieu300@gmail.com to levantrieu170604@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-29T15:35:09.140' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1052, 1, 1, N'CHANGE_REQUEST_INITIATED', N'USER', 1, N'EMAIL', N'luxuryhotel999@gmail.com', N'levantrieu170604@gmail.com', N'Admin requested email change from luxuryhotel999@gmail.com to levantrieu170604@gmail.com', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-06-29T15:37:51.370' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1053, 1002, 1002, N'PASSWORD_CHANGED', N'USER', 1002, N'PASSWORD', N'MASKED', N'MASKED', NULL, NULL, NULL, NULL, N'CRITICAL', 0, NULL, CAST(N'2025-07-03T22:23:36.880' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1054, 1002, 1002, N'PASSWORD_CHANGED', N'USER', 1002, N'PASSWORD', N'MASKED', N'MASKED', NULL, NULL, NULL, NULL, N'CRITICAL', 0, NULL, CAST(N'2025-07-13T01:01:55.427' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1055, 1002, 1002, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieuhao2004@gmail.com', N'User requested email change', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-07-13T01:04:02.900' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1056, 1002, 1002, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieuhao2004@gmail.com', N'User requested email change', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-07-13T01:04:20.080' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1057, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'baotrieu300@gmail.com', N'trieuhao2004@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-07-13T01:06:13.540' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1058, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'EMAIL', NULL, N'trieuhao2004@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-07-13T01:06:13.543' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1059, 1002, 1002, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'baotrieu300@gmail.com', N'User requested email change', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-07-13T01:06:58.610' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1060, 1002, 1002, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'baotrieu300@gmail.com', N'User requested email change', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-07-13T01:08:06.170' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1061, 1002, 1002, N'CHANGE_REQUEST_INITIATED', N'USER', 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'baotrieu300@gmail.com', N'User requested email change', NULL, NULL, NULL, N'HIGH', 1, N'PENDING', CAST(N'2025-07-13T01:09:15.390' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1062, 1002, 1002, N'PASSWORD_CHANGED', N'USER', 1002, N'PASSWORD', N'MASKED', N'MASKED', NULL, NULL, NULL, NULL, N'CRITICAL', 0, NULL, CAST(N'2025-07-13T01:09:49.980' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1063, 1002, 1002, N'EMAIL_CHANGED', N'USER', 1002, N'EMAIL', N'trieuhao2004@gmail.com', N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-07-13T01:10:28.740' AS DateTime))
INSERT [dbo].[SecurityAuditLog] ([Id], [UserId], [ActionBy], [Action], [EntityType], [EntityId], [FieldChanged], [OldValue], [NewValue], [ChangeReason], [IpAddress], [UserAgent], [SessionId], [RiskLevel], [RequiredApproval], [ApprovalStatus], [Timestamp]) VALUES (1064, 1002, 1002, N'CHANGE_REQUEST_APPROVED', N'USER', 1002, N'EMAIL', NULL, N'baotrieu300@gmail.com', NULL, NULL, NULL, NULL, N'HIGH', 0, NULL, CAST(N'2025-07-13T01:10:28.743' AS DateTime))
SET IDENTITY_INSERT [dbo].[SecurityAuditLog] OFF
GO
SET IDENTITY_INSERT [dbo].[Services] ON 

INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1, N'Spa Treatment', CAST(300000.00 AS Decimal(10, 2)), N'In-room spa service', N'active', CAST(N'2025-06-18T21:59:21.097' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (2, N'Airport Shuttle', CAST(200000.00 AS Decimal(10, 2)), N'Airport pickup and drop-off service', N'active', CAST(N'2025-06-18T21:59:21.097' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (3, N'Laundry Service', CAST(100000.00 AS Decimal(10, 2)), N'Same day laundry service', N'active', CAST(N'2025-06-18T21:59:21.097' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (4, N'Room Service', CAST(50000.00 AS Decimal(10, 2)), N'24/7 room service', N'active', CAST(N'2025-06-18T21:59:21.097' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (5, N'Car Rental', CAST(500000.00 AS Decimal(10, 2)), N'Daily car rental service', N'active', CAST(N'2025-06-18T21:59:21.097' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1002, N'Airport Shuttle - One Way', CAST(350000.00 AS Decimal(10, 2)), N'Private car service from/to Tan Son Nhat Airport (45 mins)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1003, N'Airport Shuttle - Round Trip', CAST(600000.00 AS Decimal(10, 2)), N'Private car service round trip to/from airport with flexible timing', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1004, N'City Tour - Half Day', CAST(800000.00 AS Decimal(10, 2)), N'Guided tour of Ho Chi Minh City highlights with English-speaking guide', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1005, N'Private Car - Full Day', CAST(1500000.00 AS Decimal(10, 2)), N'Private car with driver for 8 hours within city limits', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1006, N'Breakfast Buffet', CAST(350000.00 AS Decimal(10, 2)), N'International breakfast buffet at Sunrise Restaurant (6:30-10:30 AM)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1007, N'Romantic Dinner Package', CAST(1200000.00 AS Decimal(10, 2)), N'Candlelight dinner for 2 with wine at rooftop restaurant', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1008, N'Room Service - 24/7', CAST(100000.00 AS Decimal(10, 2)), N'In-room dining service available round the clock (per order)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1009, N'Mini Bar Package', CAST(500000.00 AS Decimal(10, 2)), N'Unlimited mini bar access during your stay', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1010, N'Traditional Vietnamese Massage - 60min', CAST(800000.00 AS Decimal(10, 2)), N'Relaxing full body massage with aromatic oils', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1011, N'Luxury Spa Package - 120min', CAST(1800000.00 AS Decimal(10, 2)), N'Full spa treatment including massage, facial, and body scrub', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1012, N'Couples Spa Experience', CAST(3000000.00 AS Decimal(10, 2)), N'Private spa suite for couples with champagne and treatments', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1013, N'Yoga Session - Private', CAST(400000.00 AS Decimal(10, 2)), N'One-on-one yoga session with certified instructor', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1014, N'Meeting Room - Half Day', CAST(2000000.00 AS Decimal(10, 2)), N'Executive meeting room for up to 10 people (4 hours)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1015, N'Business Center Access', CAST(200000.00 AS Decimal(10, 2)), N'Full day access to business center with printing/scanning', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1016, N'Video Conference Setup', CAST(500000.00 AS Decimal(10, 2)), N'Professional video conference equipment and support', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1017, N'Express Laundry (Same Day)', CAST(200000.00 AS Decimal(10, 2)), N'Same day laundry service - wash, dry, and iron', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1018, N'Dry Cleaning Service', CAST(150000.00 AS Decimal(10, 2)), N'Professional dry cleaning for delicate garments (per item)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1019, N'Shoe Cleaning Service', CAST(100000.00 AS Decimal(10, 2)), N'Professional shoe cleaning and polishing service', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1020, N'Flower Arrangement', CAST(300000.00 AS Decimal(10, 2)), N'Fresh flower arrangement delivered to your room', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1021, N'Birthday Celebration Package', CAST(800000.00 AS Decimal(10, 2)), N'Decorated room with cake and champagne for special occasions', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1022, N'Honeymoon Package', CAST(1500000.00 AS Decimal(10, 2)), N'Rose petals, champagne, chocolates, and late checkout', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1023, N'Pet Care Service', CAST(250000.00 AS Decimal(10, 2)), N'Professional pet sitting service (per day)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
INSERT [dbo].[Services] ([Id], [Name], [Price], [Description], [Status], [CreatedAt]) VALUES (1024, N'Baby Sitting Service', CAST(300000.00 AS Decimal(10, 2)), N'Professional childcare service (per hour)', N'active', CAST(N'2025-06-24T23:02:07.703' AS DateTime))
SET IDENTITY_INSERT [dbo].[Services] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (1, N'admin', N'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7', N'Administrator', N'luxuryhotel999@gmail.com', N'0888888888', N'ADMIN', 1, CAST(N'2025-06-18T21:59:20.537' AS DateTime), CAST(N'2025-06-29T15:36:14.147' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (2, N'reception1', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Peter Receptionist', N'peter@luxuryhotel.com', N'0987654321', N'RECEPTIONIST', 1, CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-18T22:12:38.977' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (3, N'house1', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Charlie Housekeeper', N'charlie@luxuryhotel.com', N'0911223344', N'HOUSEKEEPER', 1, CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-18T21:59:20.540' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (4, N'house2', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Housekeeper 2', N'house2@luxuryhotel.com', N'0911223342', N'HOUSEKEEPER', 1, CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-18T21:59:20.540' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (5, N'house3', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Housekeeper 3', N'house3@luxuryhotel.com', N'0911223343', N'HOUSEKEEPER', 1, CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-18T21:59:20.540' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (6, N'house4', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Housekeeper 4', N'house4@luxuryhotel.com', N'0911223344', N'HOUSEKEEPER', 1, CAST(N'2025-06-18T21:59:20.540' AS DateTime), CAST(N'2025-06-18T21:59:20.540' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (7, N'house5', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Housekeeper 5', N'house5@luxuryhotel.com', N'0911223345', N'HOUSEKEEPER', 0, CAST(N'2025-06-18T21:59:20.547' AS DateTime), CAST(N'2025-07-04T09:21:20.407' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (8, N'inspector1', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Diana Inspector', N'diana@luxuryhotel.com', N'0911223355', N'ROOM_INSPECTOR', 1, CAST(N'2025-06-18T21:59:20.873' AS DateTime), CAST(N'2025-06-18T21:59:20.873' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (9, N'inspector2', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Frank Chen', N'frank.chen@luxuryhotel.com', N'0911223366', N'ROOM_INSPECTOR', 1, CAST(N'2025-06-18T21:59:20.877' AS DateTime), CAST(N'2025-06-18T21:59:20.877' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (10, N'customer1', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'David Johnson', N'david@gmail.com', N'0900000000', N'CUSTOMER', 1, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-22T22:43:14.750' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (11, N'customer2', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Eva Williams', N'eva@gmail.com', N'0900000002', N'CUSTOMER', 1, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-18T21:59:20.883' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (12, N'vip1', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Michael Chen', N'michael.chen@company.com', N'0900000005', N'CUSTOMER', 1, CAST(N'2025-06-18T21:59:20.883' AS DateTime), CAST(N'2025-06-18T21:59:20.883' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (1002, N'trieu09', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'Le Van Trieu', N'baotrieu300@gmail.com', N'0385217604', N'CUSTOMER', 1, CAST(N'2025-06-19T21:04:44.110' AS DateTime), CAST(N'2025-07-13T01:10:28.730' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (2002, N'guest_1750638834597', N'2fc345a9e8a590232f5c45db2604701ee302d061172d2dd29075d60de1813651', N'Le Van Trieu', N'trieulvhe18716@fpt.edu.vn', N'0385217604', N'CUSTOMER', 0, CAST(N'2025-06-23T07:33:54.793' AS DateTime), CAST(N'2025-06-24T09:31:01.430' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (2003, N'guest_1750739906662', N'a414ef1ea68d49d91c83c9dbea28047b499fa17daf840ec7e4aca57690ef3437', N'Nguyễn Đức Cường', N'cuongnd30803@gmail.com', N'0862933803', N'CUSTOMER', 1, CAST(N'2025-06-24T11:38:26.687' AS DateTime), CAST(N'2025-06-24T11:38:26.687' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (2004, N'guest_1750849866695', N'e6204c52369226f0e3f1a31f700a9f1d2b15730539c5159e85766171c2cafa9b', N'Le Van Trieu', N'trieulvhe187167@fpt.edu.vn', N'0385217604', N'CUSTOMER', 1, CAST(N'2025-06-25T18:11:06.760' AS DateTime), CAST(N'2025-06-25T18:11:06.760' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (3004, N'reception2', N'0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', N'Sarah Johnson', N'sarah.johnson@luxuryhotel.com', N'0987654322', N'RECEPTIONIST', 1, CAST(N'2025-06-29T15:46:46.250' AS DateTime), CAST(N'2025-06-29T15:46:46.250' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (3005, N'phong', N'46708f23d682fef9aa996ecbb139bfb6c9ffdc039905ad6ad5c85a88b9411d97', N'giaphong', N'bruh280905@gmail.com', N'0913511637', N'CUSTOMER', 1, CAST(N'2025-07-04T08:35:31.220' AS DateTime), CAST(N'2025-07-04T08:35:31.220' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (3006, N'guest_1751992336889', N'2f820585b2b74f67e46305943890e030343d946242233cb23e1803487f936738', N'Le Van Trieu', N'levantrieu170604@gmail.com', N'0385217604', N'CUSTOMER', 1, CAST(N'2025-07-08T23:32:16.943' AS DateTime), CAST(N'2025-07-08T23:32:16.943' AS DateTime))
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [FullName], [Email], [Phone], [Role], [Status], [CreatedAt], [UpdatedAt]) VALUES (3007, N'guest_1752433659346', N'acc770cdf171e3be4fceff5c9517da864c9710eab84bce58b7e062d9a803c676', N'Le Xuan Hieu', N'trieuhao2004@gmail.com', N'0385217604', N'CUSTOMER', 1, CAST(N'2025-07-14T02:07:39.370' AS DateTime), CAST(N'2025-07-14T02:07:39.370' AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Blogs__BC7B5FB6A16847D5]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[Blogs] ADD UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Customer__1788CC4D217CB178]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[CustomerDetails] ADD UNIQUE NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__EmailTem__A6C2DA66567F5F5F]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[EmailTemplates] ADD UNIQUE NONCLUSTERED 
(
	[TemplateName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Employee__1788CC4D63226983]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[EmployeeDetails] ADD UNIQUE NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Password__1EB4F8174A339A2A]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[PasswordResetTokens] ADD UNIQUE NONCLUSTERED 
(
	[Token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__PendingC__B74669299FCCD0D9]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[PendingChanges] ADD UNIQUE NONCLUSTERED 
(
	[VerificationToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Rooms__AE10E07A6D0AFAF8]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[Rooms] ADD UNIQUE NONCLUSTERED 
(
	[RoomNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__536C85E457F91DA7]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__A9D10534EF8CAD9A]    Script Date: 7/22/2025 10:19:50 AM ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Blogs] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Blogs] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[CheckInDetails] ADD  DEFAULT ((0)) FOR [AdditionalGuests]
GO
ALTER TABLE [dbo].[CheckInDetails] ADD  DEFAULT ((0)) FOR [SecurityDeposit]
GO
ALTER TABLE [dbo].[CheckInDetails] ADD  DEFAULT ((2)) FOR [KeyCards]
GO
ALTER TABLE [dbo].[CheckOutDetails] ADD  DEFAULT ((0)) FOR [DamageCharges]
GO
ALTER TABLE [dbo].[CheckOutDetails] ADD  DEFAULT ((0)) FOR [AmenityCharges]
GO
ALTER TABLE [dbo].[CheckOutDetails] ADD  DEFAULT ((0)) FOR [ServiceCharges]
GO
ALTER TABLE [dbo].[CheckOutDetails] ADD  DEFAULT ((0)) FOR [RefundAmount]
GO
ALTER TABLE [dbo].[Comments] ADD  DEFAULT ('PENDING') FOR [Status]
GO
ALTER TABLE [dbo].[Comments] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ContactMessages] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CustomerDetails] ADD  DEFAULT ((0)) FOR [LoyaltyPoints]
GO
ALTER TABLE [dbo].[CustomerDetails] ADD  DEFAULT ('BRONZE') FOR [MembershipLevel]
GO
ALTER TABLE [dbo].[CustomerDetails] ADD  DEFAULT ((0)) FOR [IsVIP]
GO
ALTER TABLE [dbo].[CustomerDetails] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CustomerDetails] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[EmailTemplates] ADD  DEFAULT ('en') FOR [Language]
GO
ALTER TABLE [dbo].[EmailTemplates] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmailTemplates] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[EmailTemplates] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[EmployeeDetails] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[EmployeeDetails] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[Equipment] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Events] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Events] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[Feedback] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Feedback] ADD  DEFAULT ((0)) FOR [disabled]
GO
ALTER TABLE [dbo].[GroupBookings] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[HousekeepingTasks] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[HousekeepingTasks] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[InspectionItems] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[NotificationHistory] ADD  DEFAULT (getdate()) FOR [SentAt]
GO
ALTER TABLE [dbo].[OTASync] ADD  DEFAULT (getdate()) FOR [SyncedAt]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ('FULL_PAYMENT') FOR [PaymentType]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT ('PENDING') FOR [Status]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT ((0)) FOR [NotificationSent]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT ((0)) FOR [ReminderSent]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT ((0)) FOR [ReminderCount]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT ((0)) FOR [ApprovedByEmail]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PendingChanges] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[ReservationAmenityUsage] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Reservations] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Reservations] ADD  DEFAULT ((1)) FOR [NumberOfCustomers]
GO
ALTER TABLE [dbo].[ReservationServices] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[ReservationServices] ADD  CONSTRAINT [DF_ReservationServices_Status]  DEFAULT ('PENDING') FOR [Status]
GO
ALTER TABLE [dbo].[ReservationServices] ADD  CONSTRAINT [DF_ReservationServices_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RoomAmenities] ADD  DEFAULT ((0)) FOR [UnitPrice]
GO
ALTER TABLE [dbo].[RoomAmenities] ADD  DEFAULT ((0)) FOR [IsChargeable]
GO
ALTER TABLE [dbo].[RoomAmenities] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RoomEquipment] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[RoomInspections] ADD  DEFAULT (getdate()) FOR [InspectionTime]
GO
ALTER TABLE [dbo].[RoomInspections] ADD  DEFAULT ('PENDING') FOR [Status]
GO
ALTER TABLE [dbo].[RoomTypeImages] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[RoomTypeImages] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RoomTypes] ADD  DEFAULT ((1)) FOR [Capacity]
GO
ALTER TABLE [dbo].[RoomTypes] ADD  DEFAULT ('active') FOR [Status]
GO
ALTER TABLE [dbo].[RoomTypes] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RoomTypes] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[SecurityAuditLog] ADD  DEFAULT ('LOW') FOR [RiskLevel]
GO
ALTER TABLE [dbo].[SecurityAuditLog] ADD  DEFAULT ((0)) FOR [RequiredApproval]
GO
ALTER TABLE [dbo].[SecurityAuditLog] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[Services] ADD  DEFAULT ('active') FOR [Status]
GO
ALTER TABLE [dbo].[Services] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_Activities_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_Activities_Reservation]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_Activities_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_Activities_User]
GO
ALTER TABLE [dbo].[AmenityInventory]  WITH CHECK ADD  CONSTRAINT [FK_AmenityInventory_Amenity] FOREIGN KEY([AmenityId])
REFERENCES [dbo].[RoomAmenities] ([Id])
GO
ALTER TABLE [dbo].[AmenityInventory] CHECK CONSTRAINT [FK_AmenityInventory_Amenity]
GO
ALTER TABLE [dbo].[AmenityInventory]  WITH CHECK ADD  CONSTRAINT [FK_AmenityInventory_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[AmenityInventory] CHECK CONSTRAINT [FK_AmenityInventory_Reservation]
GO
ALTER TABLE [dbo].[AmenityInventory]  WITH CHECK ADD  CONSTRAINT [FK_AmenityInventory_User] FOREIGN KEY([CheckedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[AmenityInventory] CHECK CONSTRAINT [FK_AmenityInventory_User]
GO
ALTER TABLE [dbo].[Blogs]  WITH CHECK ADD  CONSTRAINT [FK_Blogs_Author] FOREIGN KEY([AuthorId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Blogs] CHECK CONSTRAINT [FK_Blogs_Author]
GO
ALTER TABLE [dbo].[CheckInDetails]  WITH CHECK ADD  CONSTRAINT [FK_CheckInDetails_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[CheckInDetails] CHECK CONSTRAINT [FK_CheckInDetails_Reservation]
GO
ALTER TABLE [dbo].[CheckInDetails]  WITH CHECK ADD  CONSTRAINT [FK_CheckInDetails_User] FOREIGN KEY([CheckInBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[CheckInDetails] CHECK CONSTRAINT [FK_CheckInDetails_User]
GO
ALTER TABLE [dbo].[CheckOutDetails]  WITH CHECK ADD  CONSTRAINT [FK_CheckOut_Inspection] FOREIGN KEY([InspectionId])
REFERENCES [dbo].[RoomInspections] ([Id])
GO
ALTER TABLE [dbo].[CheckOutDetails] CHECK CONSTRAINT [FK_CheckOut_Inspection]
GO
ALTER TABLE [dbo].[CheckOutDetails]  WITH CHECK ADD  CONSTRAINT [FK_CheckOutDetails_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[CheckOutDetails] CHECK CONSTRAINT [FK_CheckOutDetails_Reservation]
GO
ALTER TABLE [dbo].[CheckOutDetails]  WITH CHECK ADD  CONSTRAINT [FK_CheckOutDetails_User] FOREIGN KEY([CheckOutBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[CheckOutDetails] CHECK CONSTRAINT [FK_CheckOutDetails_User]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Blog] FOREIGN KEY([BlogId])
REFERENCES [dbo].[Blogs] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Blog]
GO
ALTER TABLE [dbo].[CustomerDetails]  WITH CHECK ADD  CONSTRAINT [FK_CustomerDetails_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerDetails] CHECK CONSTRAINT [FK_CustomerDetails_User]
GO
ALTER TABLE [dbo].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [FK_EmailTemplates_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[EmailTemplates] CHECK CONSTRAINT [FK_EmailTemplates_CreatedBy]
GO
ALTER TABLE [dbo].[EmployeeDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDetails_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmployeeDetails] CHECK CONSTRAINT [FK_EmployeeDetails_User]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_User]
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD  CONSTRAINT [FK_Feedback_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Feedback] CHECK CONSTRAINT [FK_Feedback_Reservation]
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD  CONSTRAINT [FK_Feedback_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Feedback] CHECK CONSTRAINT [FK_Feedback_User]
GO
ALTER TABLE [dbo].[GroupBookings]  WITH CHECK ADD  CONSTRAINT [FK_GroupBookings_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[GroupBookings] CHECK CONSTRAINT [FK_GroupBookings_User]
GO
ALTER TABLE [dbo].[HousekeepingTasks]  WITH CHECK ADD  CONSTRAINT [FK_Task_Room] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([Id])
GO
ALTER TABLE [dbo].[HousekeepingTasks] CHECK CONSTRAINT [FK_Task_Room]
GO
ALTER TABLE [dbo].[HousekeepingTasks]  WITH CHECK ADD  CONSTRAINT [FK_Task_User] FOREIGN KEY([AssignedTo])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[HousekeepingTasks] CHECK CONSTRAINT [FK_Task_User]
GO
ALTER TABLE [dbo].[InspectionItems]  WITH CHECK ADD  CONSTRAINT [FK_InspectionItem_Inspection] FOREIGN KEY([InspectionId])
REFERENCES [dbo].[RoomInspections] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InspectionItems] CHECK CONSTRAINT [FK_InspectionItem_Inspection]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [FK_NotificationHistory_PendingChange] FOREIGN KEY([PendingChangeId])
REFERENCES [dbo].[PendingChanges] ([Id])
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [FK_NotificationHistory_PendingChange]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [FK_NotificationHistory_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [FK_NotificationHistory_User]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notif_Res] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notif_Res]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notif_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notif_User]
GO
ALTER TABLE [dbo].[OTASync]  WITH CHECK ADD  CONSTRAINT [FK_OTA_Room] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([Id])
GO
ALTER TABLE [dbo].[OTASync] CHECK CONSTRAINT [FK_OTA_Room]
GO
ALTER TABLE [dbo].[PasswordResetTokens]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Pay_Res] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Pay_Res]
GO
ALTER TABLE [dbo].[PendingChanges]  WITH CHECK ADD  CONSTRAINT [FK_PendingChanges_InitiatedBy] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[PendingChanges] CHECK CONSTRAINT [FK_PendingChanges_InitiatedBy]
GO
ALTER TABLE [dbo].[PendingChanges]  WITH CHECK ADD  CONSTRAINT [FK_PendingChanges_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[PendingChanges] CHECK CONSTRAINT [FK_PendingChanges_User]
GO
ALTER TABLE [dbo].[ReservationAmenityUsage]  WITH CHECK ADD  CONSTRAINT [FK_Usage_Amenity] FOREIGN KEY([AmenityId])
REFERENCES [dbo].[RoomAmenities] ([Id])
GO
ALTER TABLE [dbo].[ReservationAmenityUsage] CHECK CONSTRAINT [FK_Usage_Amenity]
GO
ALTER TABLE [dbo].[ReservationAmenityUsage]  WITH CHECK ADD  CONSTRAINT [FK_Usage_CheckedBy] FOREIGN KEY([CheckedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[ReservationAmenityUsage] CHECK CONSTRAINT [FK_Usage_CheckedBy]
GO
ALTER TABLE [dbo].[ReservationAmenityUsage]  WITH CHECK ADD  CONSTRAINT [FK_Usage_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReservationAmenityUsage] CHECK CONSTRAINT [FK_Usage_Reservation]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Res_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Res_CreatedBy]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Res_GroupBookings] FOREIGN KEY([GroupBookingId])
REFERENCES [dbo].[GroupBookings] ([Id])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Res_GroupBookings]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Res_Room] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([Id])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Res_Room]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Res_RoomType] FOREIGN KEY([RoomTypeId])
REFERENCES [dbo].[RoomTypes] ([Id])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Res_RoomType]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Res_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Res_User]
GO
ALTER TABLE [dbo].[ReservationServices]  WITH CHECK ADD  CONSTRAINT [FK_RS_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[ReservationServices] CHECK CONSTRAINT [FK_RS_CreatedBy]
GO
ALTER TABLE [dbo].[ReservationServices]  WITH CHECK ADD  CONSTRAINT [FK_RS_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[ReservationServices] CHECK CONSTRAINT [FK_RS_Reservation]
GO
ALTER TABLE [dbo].[ReservationServices]  WITH CHECK ADD  CONSTRAINT [FK_RS_Service] FOREIGN KEY([ServiceId])
REFERENCES [dbo].[Services] ([Id])
GO
ALTER TABLE [dbo].[ReservationServices] CHECK CONSTRAINT [FK_RS_Service]
GO
ALTER TABLE [dbo].[RoomAmenities]  WITH CHECK ADD  CONSTRAINT [FK_RoomAmenities_Room] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoomAmenities] CHECK CONSTRAINT [FK_RoomAmenities_Room]
GO
ALTER TABLE [dbo].[RoomDamages]  WITH CHECK ADD  CONSTRAINT [FK_Damage_Inspection] FOREIGN KEY([InspectionId])
REFERENCES [dbo].[RoomInspections] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoomDamages] CHECK CONSTRAINT [FK_Damage_Inspection]
GO
ALTER TABLE [dbo].[RoomEquipment]  WITH CHECK ADD  CONSTRAINT [FK_REQ_Equip] FOREIGN KEY([EquipmentId])
REFERENCES [dbo].[Equipment] ([Id])
GO
ALTER TABLE [dbo].[RoomEquipment] CHECK CONSTRAINT [FK_REQ_Equip]
GO
ALTER TABLE [dbo].[RoomEquipment]  WITH CHECK ADD  CONSTRAINT [FK_REQ_Room] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([Id])
GO
ALTER TABLE [dbo].[RoomEquipment] CHECK CONSTRAINT [FK_REQ_Room]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [FK_Inspection_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [FK_Inspection_ApprovedBy]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [FK_Inspection_Inspector] FOREIGN KEY([InspectorId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [FK_Inspection_Inspector]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [FK_Inspection_Reservation] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([Id])
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [FK_Inspection_Reservation]
GO
ALTER TABLE [dbo].[Rooms]  WITH CHECK ADD  CONSTRAINT [FK_Rooms_RoomTypes] FOREIGN KEY([RoomTypeId])
REFERENCES [dbo].[RoomTypes] ([Id])
GO
ALTER TABLE [dbo].[Rooms] CHECK CONSTRAINT [FK_Rooms_RoomTypes]
GO
ALTER TABLE [dbo].[RoomTypeImages]  WITH CHECK ADD  CONSTRAINT [FK_RoomTypeImages_RoomType] FOREIGN KEY([RoomTypeId])
REFERENCES [dbo].[RoomTypes] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoomTypeImages] CHECK CONSTRAINT [FK_RoomTypeImages_RoomType]
GO
ALTER TABLE [dbo].[SecurityAuditLog]  WITH CHECK ADD  CONSTRAINT [FK_SecurityAuditLog_ActionBy] FOREIGN KEY([ActionBy])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[SecurityAuditLog] CHECK CONSTRAINT [FK_SecurityAuditLog_ActionBy]
GO
ALTER TABLE [dbo].[SecurityAuditLog]  WITH CHECK ADD  CONSTRAINT [FK_SecurityAuditLog_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[SecurityAuditLog] CHECK CONSTRAINT [FK_SecurityAuditLog_User]
GO
ALTER TABLE [dbo].[Blogs]  WITH CHECK ADD  CONSTRAINT [CK_Blogs_Status] CHECK  (([Status]='ARCHIVED' OR [Status]='PUBLISHED' OR [Status]='DRAFT'))
GO
ALTER TABLE [dbo].[Blogs] CHECK CONSTRAINT [CK_Blogs_Status]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [CK_Comments_Status] CHECK  (([Status]='REJECTED' OR [Status]='APPROVED' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [CK_Comments_Status]
GO
ALTER TABLE [dbo].[CustomerDetails]  WITH CHECK ADD  CONSTRAINT [CK_CustomerDetails_Gender] CHECK  (([Gender]='OTHER' OR [Gender]='FEMALE' OR [Gender]='MALE'))
GO
ALTER TABLE [dbo].[CustomerDetails] CHECK CONSTRAINT [CK_CustomerDetails_Gender]
GO
ALTER TABLE [dbo].[CustomerDetails]  WITH CHECK ADD  CONSTRAINT [CK_CustomerDetails_IdType] CHECK  (([IdType]='DRIVER_LICENSE' OR [IdType]='ID_CARD' OR [IdType]='PASSPORT'))
GO
ALTER TABLE [dbo].[CustomerDetails] CHECK CONSTRAINT [CK_CustomerDetails_IdType]
GO
ALTER TABLE [dbo].[CustomerDetails]  WITH CHECK ADD  CONSTRAINT [CK_CustomerDetails_MembershipLevel] CHECK  (([MembershipLevel]='PLATINUM' OR [MembershipLevel]='GOLD' OR [MembershipLevel]='SILVER' OR [MembershipLevel]='BRONZE'))
GO
ALTER TABLE [dbo].[CustomerDetails] CHECK CONSTRAINT [CK_CustomerDetails_MembershipLevel]
GO
ALTER TABLE [dbo].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [CK_EmailTemplates_Type] CHECK  (([TemplateType]='EXPIRED' OR [TemplateType]='REJECTED' OR [TemplateType]='APPROVED' OR [TemplateType]='REMINDER' OR [TemplateType]='CHANGE_REQUEST'))
GO
ALTER TABLE [dbo].[EmailTemplates] CHECK CONSTRAINT [CK_EmailTemplates_Type]
GO
ALTER TABLE [dbo].[EmployeeDetails]  WITH CHECK ADD  CONSTRAINT [CK_EmployeeDetails_Gender] CHECK  (([Gender]='OTHER' OR [Gender]='FEMALE' OR [Gender]='MALE'))
GO
ALTER TABLE [dbo].[EmployeeDetails] CHECK CONSTRAINT [CK_EmployeeDetails_Gender]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [CK_Events_Status] CHECK  (([Status]='CANCELLED' OR [Status]='COMPLETED' OR [Status]='ONGOING' OR [Status]='SCHEDULED'))
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [CK_Events_Status]
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD  CONSTRAINT [CK_Feedback_Rating] CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
ALTER TABLE [dbo].[Feedback] CHECK CONSTRAINT [CK_Feedback_Rating]
GO
ALTER TABLE [dbo].[HousekeepingTasks]  WITH CHECK ADD  CONSTRAINT [CK_Task_Status] CHECK  (([Status]='DONE' OR [Status]='IN_PROGRESS' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[HousekeepingTasks] CHECK CONSTRAINT [CK_Task_Status]
GO
ALTER TABLE [dbo].[InspectionItems]  WITH CHECK ADD  CONSTRAINT [CK_Item_Category] CHECK  (([ItemCategory]='OTHER' OR [ItemCategory]='SERVICE' OR [ItemCategory]='DAMAGE' OR [ItemCategory]='AMENITY' OR [ItemCategory]='MINIBAR'))
GO
ALTER TABLE [dbo].[InspectionItems] CHECK CONSTRAINT [CK_Item_Category]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [CK_NotificationHistory_Channel] CHECK  (([Channel]='IN_APP' OR [Channel]='SMS' OR [Channel]='EMAIL'))
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [CK_NotificationHistory_Channel]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [CK_NotificationHistory_Status] CHECK  (([Status]='BOUNCED' OR [Status]='FAILED' OR [Status]='SENT'))
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [CK_NotificationHistory_Status]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [CK_NotificationHistory_Type] CHECK  (([NotificationType]='EXPIRED' OR [NotificationType]='REJECTED' OR [NotificationType]='APPROVED' OR [NotificationType]='REMINDER' OR [NotificationType]='CHANGE_REQUEST'))
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [CK_NotificationHistory_Type]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [CK_Notif_Status] CHECK  (([Status]='FAILED' OR [Status]='SENT'))
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [CK_Notif_Status]
GO
ALTER TABLE [dbo].[OTASync]  WITH CHECK ADD  CONSTRAINT [CK_OTA_Action] CHECK  (([Action]='AVAILABILITY_UPDATE' OR [Action]='PRICE_UPDATE'))
GO
ALTER TABLE [dbo].[OTASync] CHECK CONSTRAINT [CK_OTA_Action]
GO
ALTER TABLE [dbo].[OTASync]  WITH CHECK ADD  CONSTRAINT [CK_OTA_Payload_JSON] CHECK  ((isjson([Payload])=(1)))
GO
ALTER TABLE [dbo].[OTASync] CHECK CONSTRAINT [CK_OTA_Payload_JSON]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [CK_Pay_Method] CHECK  (([Method]='BANK_TRANSFER' OR [Method]='CREDIT_CARD' OR [Method]='CASH' OR [Method]='MoMo' OR [Method]='VNPay'))
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CK_Pay_Method]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [CK_Pay_Status] CHECK  (([Status]='FAILED' OR [Status]='SUCCESS' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CK_Pay_Status]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [CK_Payments_PaymentType] CHECK  (([PaymentType]='REFUND' OR [PaymentType]='REMAINING_BALANCE' OR [PaymentType]='FULL_PAYMENT' OR [PaymentType]='DEPOSIT'))
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CK_Payments_PaymentType]
GO
ALTER TABLE [dbo].[PendingChanges]  WITH CHECK ADD  CONSTRAINT [CK_PendingChanges_Status] CHECK  (([Status]='EXPIRED' OR [Status]='REJECTED' OR [Status]='APPROVED' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[PendingChanges] CHECK CONSTRAINT [CK_PendingChanges_Status]
GO
ALTER TABLE [dbo].[PendingChanges]  WITH CHECK ADD  CONSTRAINT [CK_PendingChanges_Type] CHECK  (([ChangeType]='PROFILE' OR [ChangeType]='PASSWORD' OR [ChangeType]='PHONE' OR [ChangeType]='EMAIL'))
GO
ALTER TABLE [dbo].[PendingChanges] CHECK CONSTRAINT [CK_PendingChanges_Type]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [CK_Res_Status] CHECK  (([Status]='COMPLETED' OR [Status]='CANCELLED' OR [Status]='CONFIRMED' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [CK_Res_Status]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [CK_Reservations_DepositStatus] CHECK  (([DepositStatus]='REFUNDED' OR [DepositStatus]='PAID' OR [DepositStatus]='PENDING'))
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [CK_Reservations_DepositStatus]
GO
ALTER TABLE [dbo].[RoomDamages]  WITH CHECK ADD  CONSTRAINT [CK_Damage_Severity] CHECK  (([Severity]='SEVERE' OR [Severity]='MAJOR' OR [Severity]='MODERATE' OR [Severity]='MINOR'))
GO
ALTER TABLE [dbo].[RoomDamages] CHECK CONSTRAINT [CK_Damage_Severity]
GO
ALTER TABLE [dbo].[RoomDamages]  WITH CHECK ADD  CONSTRAINT [CK_Damage_Type] CHECK  (([DamageType]='OTHER' OR [DamageType]='LINEN' OR [DamageType]='CARPET' OR [DamageType]='WALLS' OR [DamageType]='BATHROOM' OR [DamageType]='ELECTRONICS' OR [DamageType]='FURNITURE'))
GO
ALTER TABLE [dbo].[RoomDamages] CHECK CONSTRAINT [CK_Damage_Type]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [CK_Inspection_Condition] CHECK  (([RoomCondition]='DAMAGED' OR [RoomCondition]='POOR' OR [RoomCondition]='FAIR' OR [RoomCondition]='GOOD' OR [RoomCondition]='EXCELLENT'))
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [CK_Inspection_Condition]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [CK_Inspection_Score] CHECK  (([CleanlinessScore]>=(1) AND [CleanlinessScore]<=(10)))
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [CK_Inspection_Score]
GO
ALTER TABLE [dbo].[RoomInspections]  WITH CHECK ADD  CONSTRAINT [CK_Inspection_Status] CHECK  (([Status]='COMPLETED' OR [Status]='REJECTED' OR [Status]='APPROVED' OR [Status]='PENDING'))
GO
ALTER TABLE [dbo].[RoomInspections] CHECK CONSTRAINT [CK_Inspection_Status]
GO
ALTER TABLE [dbo].[Rooms]  WITH CHECK ADD  CONSTRAINT [CK_Rooms_Status] CHECK  (([Status]='HELD' OR [Status]='DIRTY' OR [Status]='MAINTENANCE' OR [Status]='OCCUPIED' OR [Status]='AVAILABLE'))
GO
ALTER TABLE [dbo].[Rooms] CHECK CONSTRAINT [CK_Rooms_Status]
GO
ALTER TABLE [dbo].[SecurityAuditLog]  WITH CHECK ADD  CONSTRAINT [CK_SecurityAuditLog_Approval] CHECK  (([ApprovalStatus]='REJECTED' OR [ApprovalStatus]='APPROVED' OR [ApprovalStatus]='PENDING'))
GO
ALTER TABLE [dbo].[SecurityAuditLog] CHECK CONSTRAINT [CK_SecurityAuditLog_Approval]
GO
ALTER TABLE [dbo].[SecurityAuditLog]  WITH CHECK ADD  CONSTRAINT [CK_SecurityAuditLog_Risk] CHECK  (([RiskLevel]='CRITICAL' OR [RiskLevel]='HIGH' OR [RiskLevel]='MEDIUM' OR [RiskLevel]='LOW'))
GO
ALTER TABLE [dbo].[SecurityAuditLog] CHECK CONSTRAINT [CK_SecurityAuditLog_Risk]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CK_Users_Role] CHECK  (([Role]='INACTIVE' OR [Role]='CUSTOMER' OR [Role]='ROOM_INSPECTOR' OR [Role]='HOUSEKEEPER' OR [Role]='RECEPTIONIST' OR [Role]='ADMIN'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_Role]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddInspectionItem]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to add used items during inspection
CREATE PROCEDURE [dbo].[sp_AddInspectionItem]
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
/****** Object:  StoredProcedure [dbo].[sp_AddRoomDamage]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to record damage
CREATE PROCEDURE [dbo].[sp_AddRoomDamage]
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
/****** Object:  StoredProcedure [dbo].[sp_ApproveChangeRequest]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to approve a change request - FIXED column name
CREATE PROCEDURE [dbo].[sp_ApproveChangeRequest]
    @Token NVARCHAR(255),
    @ApprovedBy NVARCHAR(100) = 'EMAIL_VERIFICATION'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @PendingId INT, @UserId INT, @ChangeType NVARCHAR(20);
    DECLARE @NewEmail NVARCHAR(100), @NewPhone NVARCHAR(20), @NewPasswordHash NVARCHAR(255);
    
    -- Get pending change
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
    
    -- Apply the change - FIXED: Use correct column name 'PasswordHash'
    IF @ChangeType = 'EMAIL'
        UPDATE dbo.Users SET Email = @NewEmail WHERE Id = @UserId;
    ELSE IF @ChangeType = 'PHONE'
        UPDATE dbo.Users SET Phone = @NewPhone WHERE Id = @UserId;
    ELSE IF @ChangeType = 'PASSWORD'
        UPDATE dbo.Users SET PasswordHash = @NewPasswordHash WHERE Id = @UserId;
    
    -- Update pending change status
    UPDATE dbo.PendingChanges 
    SET Status = 'APPROVED', ApprovedAt = GETDATE(), ApprovedByEmail = 1
    WHERE Id = @PendingId;
    
    -- Log approval
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
/****** Object:  StoredProcedure [dbo].[sp_CleanupExpiredTokens]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to clean up expired tokens
CREATE PROCEDURE [dbo].[sp_CleanupExpiredTokens]
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.PendingChanges 
    SET Status = 'EXPIRED' 
    WHERE Status = 'PENDING' AND TokenExpiry < GETDATE();
    
    SELECT @@ROWCOUNT AS ExpiredTokens;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CompleteInspection]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to complete inspection and generate charges
CREATE PROCEDURE [dbo].[sp_CompleteInspection]
    @InspectionId INT,
    @ApprovedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    -- Update inspection status
    UPDATE dbo.RoomInspections 
    SET Status = 'COMPLETED', 
        ApprovedBy = @ApprovedBy, 
        ApprovedAt = GETDATE()
    WHERE Id = @InspectionId;
    
    -- Get total charges
    DECLARE @ItemCharges DECIMAL(10,2) = 0;
    DECLARE @DamageCharges DECIMAL(10,2) = 0;
    
    SELECT @ItemCharges = ISNULL(SUM(TotalPrice), 0)
    FROM dbo.InspectionItems
    WHERE InspectionId = @InspectionId;
    
    SELECT @DamageCharges = ISNULL(SUM(EstimatedCost), 0)
    FROM dbo.RoomDamages
    WHERE InspectionId = @InspectionId;
    
    -- Return summary
    SELECT 
        @InspectionId AS InspectionId,
        @ItemCharges AS ItemCharges,
        @DamageCharges AS DamageCharges,
        @ItemCharges + @DamageCharges AS TotalAdditionalCharges;
    
    COMMIT TRANSACTION;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateCustomer]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------
-- STORED PROCEDURES
--------------------------------------------------------------------------------

-- Procedure to create a new customer
CREATE PROCEDURE [dbo].[sp_CreateCustomer]
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
    
    -- Insert into Users table
    INSERT INTO dbo.Users (Username, PasswordHash, FullName, Email, Phone, Role)
    VALUES (@Username, @PasswordHash, @FullName, @Email, @Phone, 'CUSTOMER');
    
    SET @UserId = SCOPE_IDENTITY();
    
    -- Insert into CustomerDetails table
    INSERT INTO dbo.CustomerDetails (UserId, IdType, IdNumber, DateOfBirth, Gender, Address, City, Country)
    VALUES (@UserId, @IdType, @IdNumber, @DateOfBirth, @Gender, @Address, @City, @Country);
    
    COMMIT TRANSACTION;
    
    SELECT @UserId AS NewUserId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateEmployee]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Cập nhật stored procedure sp_CreateEmployee
CREATE PROCEDURE [dbo].[sp_CreateEmployee]
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(255),
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Role NVARCHAR(20),
    @Department NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    -- Thêm các tham số mới
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
    
    -- Kiểm tra tuổi (phải >= 18 tuổi)
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
/****** Object:  StoredProcedure [dbo].[sp_InitiateChangeRequest]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------
-- 5. Stored Procedures for Verification System
--------------------------------------------------------------------------------

-- Procedure to initiate a change request - FIXED token generation
CREATE PROCEDURE [dbo].[sp_InitiateChangeRequest]
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
    
    -- FIXED: Generate token using CAST and string concatenation
    DECLARE @Token NVARCHAR(255) = CAST(NEWID() AS NVARCHAR(36)) + '-' + CAST(GETDATE() AS NVARCHAR(50));
    DECLARE @Expiry DATETIME = DATEADD(HOUR, @ExpiryHours, GETDATE());
    DECLARE @OriginalEmail NVARCHAR(100);
    DECLARE @OriginalPhone NVARCHAR(20);
    
    -- Get current values
    SELECT @OriginalEmail = Email, @OriginalPhone = Phone 
    FROM dbo.Users WHERE Id = @UserId;
    
    -- Insert pending change
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
    
    -- Log security audit
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
/****** Object:  StoredProcedure [dbo].[sp_ProcessDepositPayment]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ProcessDepositPayment]
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
/****** Object:  StoredProcedure [dbo].[sp_RefundDeposit]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_RefundDeposit]
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
/****** Object:  StoredProcedure [dbo].[sp_StartRoomInspection]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure to start room inspection
CREATE PROCEDURE [dbo].[sp_StartRoomInspection]
    @ReservationId INT,
    @InspectorId INT,
    @RoomCondition NVARCHAR(20),
    @CleanlinessScore INT,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if inspection already exists
    IF EXISTS (SELECT 1 FROM dbo.RoomInspections WHERE ReservationId = @ReservationId)
    BEGIN
        RAISERROR('Inspection already exists for this reservation', 16, 1);
        RETURN;
    END
    
    -- Check if user is room inspector
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateEmployeeDetails]    Script Date: 7/22/2025 10:19:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Tạo stored procedure để cập nhật thông tin employee
CREATE   PROCEDURE [dbo].[sp_UpdateEmployeeDetails]
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
    
    -- Kiểm tra tuổi nếu cập nhật ngày sinh
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
