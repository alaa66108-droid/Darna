SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

IF DB_ID(N'darana_db') IS NULL
    CREATE DATABASE darana_db;
GO
USE darana_db;
GO

CREATE TABLE dbo.Admin (
    adminID           INT IDENTITY(1,1) NOT NULL,
    firstName         NVARCHAR(50)      NOT NULL,
    lastName          NVARCHAR(50)      NOT NULL,
    email             VARCHAR(150)      NOT NULL,
    phoneNumber       CHAR(9)           NOT NULL,
    DOB               DATE              NOT NULL,
    password          VARCHAR(255)      NOT NULL,
    registrationDate  DATETIME2(0)      NOT NULL CONSTRAINT DF_Admin_reg DEFAULT (SYSDATETIME()),
    jobTitle          NVARCHAR(80)      NOT NULL,
    CONSTRAINT PK_Admin PRIMARY KEY (adminID),
    CONSTRAINT UQ_Admin_email UNIQUE (email),
    CONSTRAINT CK_Admin_phone CHECK (phoneNumber LIKE '5[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

CREATE TABLE dbo.HomeOwner (
    homeOwnerID       INT IDENTITY(1,1) NOT NULL,
    adminID           INT               NULL,
    firstName         NVARCHAR(50)      NOT NULL,
    lastName          NVARCHAR(50)      NOT NULL,
    email             VARCHAR(150)      NOT NULL,
    phoneNumber       CHAR(9)           NOT NULL,
    DOB               DATE              NOT NULL,
    password          VARCHAR(255)      NOT NULL,
    registrationDate  DATETIME2(0)      NOT NULL CONSTRAINT DF_HomeOwner_reg DEFAULT (SYSDATETIME()),
    accountStatus     VARCHAR(10)       NOT NULL CONSTRAINT DF_HomeOwner_status DEFAULT ('Active'),
    CONSTRAINT PK_HomeOwner PRIMARY KEY (homeOwnerID),
    CONSTRAINT UQ_HomeOwner_email UNIQUE (email),
    CONSTRAINT UQ_HomeOwner_phone UNIQUE (phoneNumber),
    CONSTRAINT CK_HomeOwner_phone CHECK (phoneNumber LIKE '5[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CK_HomeOwner_status CHECK (accountStatus IN ('Active', 'Suspended')),
    CONSTRAINT FK_HomeOwner_Admin FOREIGN KEY (adminID) REFERENCES dbo.Admin (adminID)
);
GO

CREATE TABLE dbo.Address (
    addressID    INT IDENTITY(1,1) NOT NULL,
    homeOwnerID  INT               NOT NULL,
    street       NVARCHAR(120)     NOT NULL,
    district     NVARCHAR(80)      NOT NULL,
    city         NVARCHAR(60)      NOT NULL,
    region       NVARCHAR(60)      NOT NULL,
    postalCode   CHAR(5)           NOT NULL,
    CONSTRAINT PK_Address PRIMARY KEY (addressID),
    CONSTRAINT CK_Address_postal CHECK (postalCode LIKE '[1-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT FK_Address_HomeOwner FOREIGN KEY (homeOwnerID) REFERENCES dbo.HomeOwner (homeOwnerID)
);
CREATE INDEX IX_Address_owner ON dbo.Address (homeOwnerID);
GO

CREATE TABLE dbo.ServiceProvider (
    serviceProviderID  INT IDENTITY(1,1) NOT NULL,
    adminID            INT               NULL,
    firstName          NVARCHAR(50)      NOT NULL,
    lastName           NVARCHAR(50)      NOT NULL,
    password           VARCHAR(255)      NOT NULL,
    registrationDate   DATETIME2(0)      NOT NULL CONSTRAINT DF_SP_reg DEFAULT (SYSDATETIME()),
    accountStatus      VARCHAR(10)       NOT NULL CONSTRAINT DF_SP_status DEFAULT ('Active'),
    DOB                DATE              NOT NULL,
    email              VARCHAR(150)      NOT NULL,
    phoneNumber        CHAR(9)           NOT NULL,
    whatsappNumber     CHAR(9)           NOT NULL,
    yearsOfExperince   INT               NOT NULL,
    socialMediaLink    NVARCHAR(255)     NULL,
    approvalStatus     VARCHAR(10)       NOT NULL CONSTRAINT DF_SP_approval DEFAULT ('Pending'),
    classificationType VARCHAR(10)       NOT NULL,
    CONSTRAINT PK_ServiceProvider PRIMARY KEY (serviceProviderID),
    CONSTRAINT UQ_SP_email UNIQUE (email),
    CONSTRAINT UQ_SP_phone UNIQUE (phoneNumber),
    CONSTRAINT CK_SP_phone CHECK (phoneNumber LIKE '5[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CK_SP_whatsapp CHECK (whatsappNumber LIKE '5[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CK_SP_status CHECK (accountStatus IN ('Active', 'Suspended')),
    CONSTRAINT CK_SP_approval CHECK (approvalStatus IN ('Pending', 'Approved', 'Rejected')),
    CONSTRAINT CK_SP_class CHECK (classificationType IN ('Small', 'Medium', 'Large')),
    CONSTRAINT CK_SP_years CHECK (yearsOfExperince BETWEEN 0 AND 50),
    CONSTRAINT CK_SP_admin CHECK (approvalStatus = 'Pending' OR adminID IS NOT NULL),
    CONSTRAINT FK_SP_Admin FOREIGN KEY (adminID) REFERENCES dbo.Admin (adminID)
);
GO

CREATE TABLE dbo.PortfolioFile (
    portfolioFileID    INT IDENTITY(1,1) NOT NULL,
    serviceProviderID  INT               NOT NULL,
    fileName           NVARCHAR(150)     NOT NULL,
    fileType           VARCHAR(10)       NOT NULL,
    filePath           NVARCHAR(300)     NOT NULL,
    lastUpdatedDate    DATETIME2(0)      NOT NULL CONSTRAINT DF_PF_date DEFAULT (SYSDATETIME()),
    fileSize           INT               NOT NULL,
    CONSTRAINT PK_PortfolioFile PRIMARY KEY (portfolioFileID),
    CONSTRAINT CK_PF_type CHECK (fileType IN ('PDF', 'JPG', 'PNG')),
    CONSTRAINT CK_PF_size CHECK (fileSize BETWEEN 1 AND 10485760),
    CONSTRAINT FK_PF_SP FOREIGN KEY (serviceProviderID) REFERENCES dbo.ServiceProvider (serviceProviderID)
);
CREATE INDEX IX_PF_provider ON dbo.PortfolioFile (serviceProviderID);
GO

CREATE TABLE dbo.Service (
    serviceID        INT IDENTITY(1,1) NOT NULL,
    adminID          INT               NOT NULL,
    serviceCategory  VARCHAR(20)       NOT NULL,
    serviceName      NVARCHAR(80)      NOT NULL,
    description      NVARCHAR(400)     NOT NULL,
    iconClass        VARCHAR(40)       NOT NULL CONSTRAINT DF_Service_icon DEFAULT ('bi-tools'),
    CONSTRAINT PK_Service PRIMARY KEY (serviceID),
    CONSTRAINT UQ_Service_name UNIQUE (serviceName),
    CONSTRAINT CK_Service_category CHECK (serviceCategory IN ('Structural', 'MEP', 'Finishing', 'Carpentry', 'Exterior')),
    CONSTRAINT FK_Service_Admin FOREIGN KEY (adminID) REFERENCES dbo.Admin (adminID)
);
GO

CREATE TABLE dbo.ServiceArea (
    serviceAreaID  INT IDENTITY(1,1) NOT NULL,
    adminID        INT               NOT NULL,
    region         NVARCHAR(60)      NOT NULL,
    city           NVARCHAR(60)      NOT NULL,
    CONSTRAINT PK_ServiceArea PRIMARY KEY (serviceAreaID),
    CONSTRAINT UQ_ServiceArea UNIQUE (region, city),
    CONSTRAINT FK_ServiceArea_Admin FOREIGN KEY (adminID) REFERENCES dbo.Admin (adminID)
);
GO

CREATE TABLE dbo.ServiceOffering (
    serviceOfferingID  INT IDENTITY(1,1) NOT NULL,
    serviceProviderID  INT               NOT NULL,
    serviceID          INT               NOT NULL,
    serviceAreaID      INT               NOT NULL,
    CONSTRAINT PK_ServiceOffering PRIMARY KEY (serviceOfferingID),
    CONSTRAINT UQ_ServiceOffering UNIQUE (serviceProviderID, serviceID, serviceAreaID),
    CONSTRAINT FK_SO_SP FOREIGN KEY (serviceProviderID) REFERENCES dbo.ServiceProvider (serviceProviderID),
    CONSTRAINT FK_SO_Service FOREIGN KEY (serviceID) REFERENCES dbo.Service (serviceID),
    CONSTRAINT FK_SO_Area FOREIGN KEY (serviceAreaID) REFERENCES dbo.ServiceArea (serviceAreaID)
);
CREATE INDEX IX_SO_search ON dbo.ServiceOffering (serviceID, serviceAreaID);
GO

CREATE TABLE dbo.SubscriptionPlan (
    SubscriptionPlanID  INT IDENTITY(1,1) NOT NULL,
    adminID             INT               NOT NULL,
    planName            NVARCHAR(60)      NOT NULL,
    description         NVARCHAR(300)     NOT NULL,
    price               DECIMAL(8,2)      NOT NULL,
    duration            INT               NOT NULL,
    CONSTRAINT PK_SubscriptionPlan PRIMARY KEY (SubscriptionPlanID),
    CONSTRAINT UQ_Plan_name UNIQUE (planName),
    CONSTRAINT CK_Plan_price CHECK (price BETWEEN 1 AND 100000),
    CONSTRAINT CK_Plan_duration CHECK (duration BETWEEN 1 AND 36),
    CONSTRAINT FK_Plan_Admin FOREIGN KEY (adminID) REFERENCES dbo.Admin (adminID)
);
GO

CREATE TABLE dbo.Subscription (
    subscriptionID      INT IDENTITY(1,1) NOT NULL,
    serviceProviderID   INT               NOT NULL,
    subscriptionPlanID  INT               NOT NULL,
    startDate           DATE              NOT NULL,
    subscriptionStatus  VARCHAR(10)       NOT NULL CONSTRAINT DF_Sub_status DEFAULT ('Pending'),
    CONSTRAINT PK_Subscription PRIMARY KEY (subscriptionID),
    CONSTRAINT CK_Sub_status CHECK (subscriptionStatus IN ('Pending', 'Active', 'Expired', 'Cancelled')),
    CONSTRAINT FK_Sub_SP FOREIGN KEY (serviceProviderID) REFERENCES dbo.ServiceProvider (serviceProviderID),
    CONSTRAINT FK_Sub_Plan FOREIGN KEY (subscriptionPlanID) REFERENCES dbo.SubscriptionPlan (SubscriptionPlanID)
);
CREATE UNIQUE INDEX UX_Sub_one_active ON dbo.Subscription (serviceProviderID) WHERE subscriptionStatus = 'Active';
GO

CREATE TABLE dbo.Payment (
    paymentID       INT IDENTITY(1,1) NOT NULL,
    subscriptionID  INT               NOT NULL,
    paymentDate     DATETIME2(0)      NOT NULL CONSTRAINT DF_Pay_date DEFAULT (SYSDATETIME()),
    amount          DECIMAL(8,2)      NOT NULL,
    paymentStatus   VARCHAR(10)       NOT NULL CONSTRAINT DF_Pay_status DEFAULT ('Pending'),
    paymentMethod   VARCHAR(12)       NOT NULL,
    transactionRef  VARCHAR(40)       NULL,
    CONSTRAINT PK_Payment PRIMARY KEY (paymentID),
    CONSTRAINT UQ_Payment_sub UNIQUE (subscriptionID),
    CONSTRAINT CK_Pay_amount CHECK (amount > 0),
    CONSTRAINT CK_Pay_status CHECK (paymentStatus IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    CONSTRAINT CK_Pay_method CHECK (paymentMethod IN ('Mada', 'Visa', 'Mastercard', 'Apple Pay')),
    CONSTRAINT CK_Pay_ref CHECK (paymentStatus NOT IN ('Paid', 'Refunded') OR transactionRef IS NOT NULL),
    CONSTRAINT FK_Pay_Sub FOREIGN KEY (subscriptionID) REFERENCES dbo.Subscription (subscriptionID)
);
CREATE UNIQUE INDEX UX_Pay_ref ON dbo.Payment (transactionRef) WHERE transactionRef IS NOT NULL;
GO

CREATE TABLE dbo.Project (
    projectID      INT IDENTITY(1,1) NOT NULL,
    homeOwnerID    INT               NOT NULL,
    addressID      INT               NOT NULL,
    projectName    NVARCHAR(80)      NOT NULL,
    startDate      DATE              NOT NULL,
    projectStatus  VARCHAR(10)       NOT NULL CONSTRAINT DF_Project_status DEFAULT ('Active'),
    CONSTRAINT PK_Project PRIMARY KEY (projectID),
    CONSTRAINT CK_Project_status CHECK (projectStatus IN ('Active', 'Completed', 'Deleted')),
    CONSTRAINT FK_Project_HomeOwner FOREIGN KEY (homeOwnerID) REFERENCES dbo.HomeOwner (homeOwnerID),
    CONSTRAINT FK_Project_Address FOREIGN KEY (addressID) REFERENCES dbo.Address (addressID)
);
CREATE INDEX IX_Project_owner ON dbo.Project (homeOwnerID, projectStatus);
GO

CREATE TABLE dbo.Appointment (
    appointmentID      INT IDENTITY(1,1) NOT NULL,
    projectID          INT               NOT NULL,
    serviceOfferingID  INT               NOT NULL,
    appointmentDate    DATE              NOT NULL,
    appointmentTime    TIME(0)           NOT NULL,
    description        NVARCHAR(500)     NULL,
    appointmentStatus  VARCHAR(10)       NOT NULL CONSTRAINT DF_Appt_status DEFAULT ('Pending'),
    CONSTRAINT PK_Appointment PRIMARY KEY (appointmentID),
    CONSTRAINT CK_Appt_status CHECK (appointmentStatus IN ('Pending', 'Accepted', 'Rejected', 'Cancelled', 'Completed')),
    CONSTRAINT CK_Appt_time CHECK (appointmentTime BETWEEN '08:00' AND '21:30' AND DATEPART(MINUTE, appointmentTime) IN (0, 30)),
    CONSTRAINT FK_Appt_Project FOREIGN KEY (projectID) REFERENCES dbo.Project (projectID),
    CONSTRAINT FK_Appt_SO FOREIGN KEY (serviceOfferingID) REFERENCES dbo.ServiceOffering (serviceOfferingID)
);
CREATE INDEX IX_Appt_offering ON dbo.Appointment (serviceOfferingID, appointmentDate);
GO

CREATE TABLE dbo.ServiceRequest (
    serviceRequestID   INT IDENTITY(1,1) NOT NULL,
    projectID          INT               NOT NULL,
    serviceOfferingID  INT               NOT NULL,
    startDate          DATE              NOT NULL,
    serviceProgress    INT               NOT NULL CONSTRAINT DF_SR_progress DEFAULT (0),
    serviceStatus      VARCHAR(12)       NOT NULL CONSTRAINT DF_SR_status DEFAULT ('Pending'),
    requestDate        DATETIME2(0)      NOT NULL CONSTRAINT DF_SR_reqdate DEFAULT (SYSDATETIME()),
    statusUpdatedAt    DATETIME2(0)      NOT NULL CONSTRAINT DF_SR_upd DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_ServiceRequest PRIMARY KEY (serviceRequestID),
    CONSTRAINT CK_SR_status CHECK (serviceStatus IN ('Pending', 'Accepted', 'Rejected', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT CK_SR_progress CHECK (serviceProgress BETWEEN 0 AND 100
        AND (serviceStatus <> 'Completed' OR serviceProgress = 100)
        AND (serviceStatus NOT IN ('Pending', 'Rejected', 'Accepted') OR serviceProgress = 0)),
    CONSTRAINT CK_SR_dates CHECK (statusUpdatedAt >= requestDate),
    CONSTRAINT FK_SR_Project FOREIGN KEY (projectID) REFERENCES dbo.Project (projectID),
    CONSTRAINT FK_SR_SO FOREIGN KEY (serviceOfferingID) REFERENCES dbo.ServiceOffering (serviceOfferingID)
);
CREATE INDEX IX_SR_offering ON dbo.ServiceRequest (serviceOfferingID, serviceStatus);
CREATE INDEX IX_SR_project ON dbo.ServiceRequest (projectID);
GO

CREATE TABLE dbo.Rating (
    ratingID          INT IDENTITY(1,1) NOT NULL,
    serviceRequestID  INT               NOT NULL,
    qualityRating     INT               NOT NULL,
    timeRating        INT               NOT NULL,
    costRating        INT               NOT NULL,
    ratingDate        DATETIME2(0)      NOT NULL CONSTRAINT DF_Rating_date DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_Rating PRIMARY KEY (ratingID),
    CONSTRAINT UQ_Rating_request UNIQUE (serviceRequestID),
    CONSTRAINT CK_Rating_values CHECK (qualityRating BETWEEN 1 AND 5 AND timeRating BETWEEN 1 AND 5 AND costRating BETWEEN 1 AND 5),
    CONSTRAINT FK_Rating_SR FOREIGN KEY (serviceRequestID) REFERENCES dbo.ServiceRequest (serviceRequestID)
);
GO

PRINT 'darana_db: 15 tables created.';
GO

CREATE TABLE dbo.failed_jobs (
    id          BIGINT IDENTITY(1,1) NOT NULL,
    uuid        NVARCHAR(255)     NOT NULL,
    connection  NVARCHAR(MAX)     NOT NULL,
    queue       NVARCHAR(MAX)     NOT NULL,
    payload     NVARCHAR(MAX)     NOT NULL,
    exception   NVARCHAR(MAX)     NOT NULL,
    failed_at   DATETIME          NOT NULL CONSTRAINT DF_failed_jobs_failed_at DEFAULT (GETDATE()),
    CONSTRAINT PK_failed_jobs PRIMARY KEY (id),
    CONSTRAINT UQ_failed_jobs_uuid UNIQUE (uuid)
);
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO
USE darana_db;
GO

SET IDENTITY_INSERT dbo.Admin ON;
INSERT INTO dbo.Admin (adminID, firstName, lastName, email, phoneNumber, DOB, password, registrationDate, jobTitle) VALUES
    (1, N'آلاء', N'المجعد', N'alaa.almjoud@darana.sa', N'553104827', '1999-04-12', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-01-04 09:00:00', N'مديرة المنصّة'),
    (2, N'نورة', N'الشمري', N'noura.alshammari@darana.sa', N'547721906', '1996-11-02', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-01-10 10:30:00', N'مشرفة اعتماد المزوّدين');
SET IDENTITY_INSERT dbo.Admin OFF;
GO

SET IDENTITY_INSERT dbo.HomeOwner ON;
INSERT INTO dbo.HomeOwner (homeOwnerID, adminID, firstName, lastName, email, phoneNumber, DOB, password, registrationDate, accountStatus) VALUES
    (1, NULL, N'شوق', N'الرشيد', N'shoug.alrasheed@gmail.com', N'551234567', '1996-03-15', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-02-11 19:20:00', N'Active'),
    (2, NULL, N'نوف', N'السبيعي', N'nouf.alsubaie@gmail.com', N'502187392', '1990-07-09', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-05-02 12:10:00', N'Active'),
    (3, NULL, N'عبدالله', N'القحطاني', N'abdullah.alqahtani@outlook.com', N'534481902', '1988-01-22', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-06-18 20:45:00', N'Active'),
    (4, 1, N'ريم', N'العنزي', N'reem.alanazi@gmail.com', N'567031158', '1993-09-30', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-01-25 11:00:00', N'Active'),
    (5, NULL, N'خالد', N'الدوسري', N'khalid.aldossary@hotmail.com', N'573628840', '1985-12-05', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-06-01 08:35:00', N'Active'),
    (6, NULL, N'سارة', N'الحربي', N'sara.alharbi@gmail.com', N'585904467', '1998-05-14', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-09-12 17:15:00', N'Active'),
    (7, NULL, N'فيصل', N'الزهراني', N'faisal.alzahrani@gmail.com', N'591256603', '1991-02-27', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-04-07 21:05:00', N'Suspended');
SET IDENTITY_INSERT dbo.HomeOwner OFF;
GO

SET IDENTITY_INSERT dbo.Address ON;
INSERT INTO dbo.Address (addressID, homeOwnerID, street, district, city, region, postalCode) VALUES
    (1, 1, N'شارع الأمير نايف', N'الفناتير', N'الجبيل', N'المنطقة الشرقية', N'31961'),
    (2, 1, N'شارع الخليج', N'الشاطئ', N'الدمام', N'المنطقة الشرقية', N'32415'),
    (3, 2, N'شارع الملك فهد', N'الفيصلية', N'الدمام', N'المنطقة الشرقية', N'32233'),
    (4, 3, N'شارع الكورنيش', N'الشاطئ الغربي', N'الدمام', N'المنطقة الشرقية', N'32413'),
    (5, 4, N'شارع الملك عبدالعزيز', N'الحمراء', N'الجبيل', N'المنطقة الشرقية', N'35514'),
    (6, 5, N'شارع جبير', N'الدفي', N'الجبيل', N'المنطقة الشرقية', N'35718'),
    (7, 6, N'شارع الأمير تركي', N'اليرموك', N'الخبر', N'المنطقة الشرقية', N'34423'),
    (8, 7, N'طريق أنس بن مالك', N'الملقا', N'الرياض', N'منطقة الرياض', N'13521');
SET IDENTITY_INSERT dbo.Address OFF;
GO

SET IDENTITY_INSERT dbo.ServiceProvider ON;
INSERT INTO dbo.ServiceProvider (serviceProviderID, adminID, firstName, lastName, password, registrationDate, accountStatus, DOB, email, phoneNumber, whatsappNumber, yearsOfExperince, socialMediaLink, approvalStatus, classificationType) VALUES
    (145, 1, N'منال', N'فهّاد', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-01-20 10:00:00', N'Active', '1989-08-19', N'manal.fahhad@gmail.com', N'558802145', N'558802145', 11, N'https://instagram.com/manal_gardens', N'Approved', N'Large'),
    (158, 1, N'ماجد', N'الشهري', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-01-08 09:15:00', N'Active', '1982-03-11', N'majed.alshehri@gmail.com', N'503337158', N'503337158', 15, NULL, N'Approved', N'Large'),
    (201, 2, N'فهد', N'الدوسري', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-02-25 13:40:00', N'Active', '1987-06-02', N'fahad.aldossary.tiles@gmail.com', N'536645201', N'536645201', 9, N'https://instagram.com/fahad_tiles', N'Approved', N'Medium'),
    (233, 2, N'سلطان', N'العتيبي', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-03-14 18:05:00', N'Active', '1994-10-27', N'sultan.alotaibi@outlook.com', N'544120233', N'544120233', 5, NULL, N'Approved', N'Small'),
    (287, 1, N'غلا', N'الشمراني', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-02-02 16:30:00', N'Active', '1995-01-18', N'ghala.alshamrani@gmail.com', N'569910287', N'569910287', 6, N'https://instagram.com/ghala_kitchens', N'Approved', N'Small'),
    (312, 1, N'بدور', N'الحربي', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-03-01 11:20:00', N'Active', '1992-11-02', N'bodor.alharbi@gmail.com', N'559876543', N'559876543', 8, N'https://instagram.com/bodor_paint', N'Approved', N'Medium'),
    (340, NULL, N'تركي', N'الغامدي', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-10-15 20:10:00', N'Active', '1990-04-08', N'turki.alghamdi@gmail.com', N'577714340', N'577714340', 7, NULL, N'Pending', N'Small'),
    (347, 2, N'هند', N'القحطاني', N'$2y$10$J4eyO6nIhvbH0RhH3Qs5WOs1sy3fXsSWH5q64A71RrD7OyaRQ6m4G', '2026-09-28 09:45:00', N'Active', '1997-12-21', N'hind.alqahtani@gmail.com', N'588003347', N'588003347', 2, NULL, N'Rejected', N'Small');
SET IDENTITY_INSERT dbo.ServiceProvider OFF;
GO

SET IDENTITY_INSERT dbo.PortfolioFile ON;
INSERT INTO dbo.PortfolioFile (portfolioFileID, serviceProviderID, fileName, fileType, filePath, lastUpdatedDate, fileSize) VALUES
    (1, 312, N'أعمال-الدهانات-2025.pdf', N'PDF', N'uploads/portfolio/312/sample-1.pdf', '2026-10-01 12:00:00', 1207),
    (2, 312, N'فيلا-الجبيل.jpg', N'JPG', N'uploads/portfolio/312/sample-2.jpg', '2026-10-01 12:00:00', 44980),
    (3, 287, N'مطابخ-2026.jpg', N'JPG', N'uploads/portfolio/287/sample-3.jpg', '2026-02-02 16:30:00', 60039),
    (4, 145, N'حدائق-الخبر.jpg', N'JPG', N'uploads/portfolio/145/sample-4.jpg', '2026-01-20 10:00:00', 114152),
    (5, 145, N'ملف-أعمال-منال.pdf', N'PDF', N'uploads/portfolio/145/sample-5.pdf', '2026-01-20 10:00:00', 1207),
    (6, 158, N'مشاريع-إنشائية.jpg', N'JPG', N'uploads/portfolio/158/sample-6.jpg', '2026-01-08 09:15:00', 54825),
    (7, 201, N'بلاط-فلل.jpg', N'JPG', N'uploads/portfolio/201/sample-7.jpg', '2026-02-25 13:40:00', 186358),
    (8, 233, N'شهادات-الكهرباء.pdf', N'PDF', N'uploads/portfolio/233/sample-8.pdf', '2026-03-14 18:05:00', 1207),
    (9, 340, N'أعمال-السباكة.pdf', N'PDF', N'uploads/portfolio/340/sample-9.pdf', '2026-10-15 20:10:00', 1207),
    (10, 347, N'نماذج-تكييف.pdf', N'PDF', N'uploads/portfolio/347/sample-10.pdf', '2026-09-28 09:45:00', 1207);
SET IDENTITY_INSERT dbo.PortfolioFile OFF;
GO

SET IDENTITY_INSERT dbo.Service ON;
INSERT INTO dbo.Service (serviceID, adminID, serviceCategory, serviceName, description, iconClass) VALUES
    (1, 1, N'Structural', N'الحفر والردم', N'حفر الموقع وتسويته وردم الأساسات بالمواد المعتمدة.', N'bi-cone-striped'),
    (2, 1, N'Structural', N'الأساسات', N'تنفيذ القواعد والميد والعزل حسب المخططات الإنشائية.', N'bi-bricks'),
    (3, 1, N'Structural', N'الخرسانة المسلحة', N'صب الأعمدة والأسقف والجسور مع أعمال الشدّات.', N'bi-boxes'),
    (4, 1, N'Structural', N'الحدادة', N'تفصيل وتركيب حديد التسليح والأعمال المعدنية.', N'bi-hammer'),
    (5, 1, N'Structural', N'البلوك', N'بناء الجدران الخارجية والداخلية بالبلوك العازل.', N'bi-grid-1x2'),
    (6, 1, N'MEP', N'الأعمال الكهربائية', N'تمديد المواسير والأسلاك وتركيب اللوحات والإنارة.', N'bi-lightning-charge-fill'),
    (7, 1, N'MEP', N'السباكة', N'تمديدات المياه والصرف وتركيب الأدوات الصحية.', N'bi-droplet-fill'),
    (8, 1, N'MEP', N'التكييف والتبريد', N'توريد وتركيب أنظمة التكييف المركزي والسبليت.', N'bi-wind'),
    (9, 1, N'Finishing', N'الدهانات', N'أعمال تجهيز الأسطح ودهان الجدران والأسقف الداخلية والخارجية.', N'bi-paint-bucket'),
    (10, 1, N'Finishing', N'البلاط والسيراميك', N'تركيب البلاط والسيراميك والرخام للأرضيات والجدران.', N'bi-grid-3x3-gap-fill'),
    (11, 1, N'Finishing', N'اللياسة (القصارة)', N'لياسة الجدران الداخلية والخارجية وتسويتها.', N'bi-layers'),
    (12, 1, N'Finishing', N'الجبس والأسقف المعلّقة', N'تنفيذ أسقف الجبس بورد والديكورات الجبسية.', N'bi-columns-gap'),
    (13, 1, N'Carpentry', N'الأبواب الخشبية', N'تصنيع وتركيب الأبواب الداخلية والخارجية.', N'bi-door-open'),
    (14, 1, N'Carpentry', N'المطابخ والخزائن', N'تصميم وتركيب المطابخ وخزائن الملابس.', N'bi-archive'),
    (15, 1, N'Carpentry', N'الألمنيوم والزجاج', N'النوافذ والواجهات الزجاجية وأبواب الألمنيوم.', N'bi-window'),
    (16, 1, N'Exterior', N'الواجهات الحجرية', N'تكسية الواجهات بالحجر والكلادينج.', N'bi-building'),
    (17, 1, N'Exterior', N'تنسيق الحدائق', N'تصميم الحدائق والري والزراعة والممرات.', N'bi-tree-fill'),
    (18, 1, N'Exterior', N'المظلات والأسوار', N'تركيب المظلات والسواتر والأسوار الخارجية.', N'bi-umbrella');
SET IDENTITY_INSERT dbo.Service OFF;
GO

SET IDENTITY_INSERT dbo.ServiceArea ON;
INSERT INTO dbo.ServiceArea (serviceAreaID, adminID, region, city) VALUES
    (1, 1, N'المنطقة الشرقية', N'الجبيل'),
    (2, 1, N'المنطقة الشرقية', N'الدمام'),
    (3, 1, N'المنطقة الشرقية', N'الخبر'),
    (4, 1, N'المنطقة الشرقية', N'الظهران'),
    (5, 1, N'المنطقة الشرقية', N'القطيف'),
    (6, 1, N'المنطقة الشرقية', N'الأحساء'),
    (7, 2, N'منطقة الرياض', N'الرياض'),
    (8, 2, N'منطقة مكة المكرمة', N'جدة'),
    (9, 2, N'منطقة مكة المكرمة', N'مكة المكرمة');
SET IDENTITY_INSERT dbo.ServiceArea OFF;
GO

SET IDENTITY_INSERT dbo.ServiceOffering ON;
INSERT INTO dbo.ServiceOffering (serviceOfferingID, serviceProviderID, serviceID, serviceAreaID) VALUES
    (1, 312, 9, 1),
    (2, 312, 9, 2),
    (3, 312, 11, 1),
    (4, 287, 14, 2),
    (5, 287, 13, 2),
    (6, 287, 14, 1),
    (7, 145, 17, 3),
    (8, 145, 16, 3),
    (9, 145, 17, 2),
    (10, 201, 10, 1),
    (11, 201, 10, 2),
    (12, 233, 6, 1),
    (13, 158, 2, 1),
    (14, 158, 3, 1),
    (15, 158, 1, 1),
    (16, 340, 7, 2),
    (17, 347, 8, 3);
SET IDENTITY_INSERT dbo.ServiceOffering OFF;
GO

SET IDENTITY_INSERT dbo.SubscriptionPlan ON;
INSERT INTO dbo.SubscriptionPlan (SubscriptionPlanID, adminID, planName, description, price, duration) VALUES
    (1, 1, N'الباقة الشهرية', N'للتجربة وبدء الظهور أمام ملّاك المنازل.', 150.00, 1),
    (2, 1, N'الباقة الربع سنوية', N'الأنسب لموسم البناء ومتابعة عدّة مشاريع.', 399.00, 3),
    (3, 1, N'الباقة السنوية', N'أفضل قيمة للمؤسسات النشطة على مدار العام.', 1299.00, 12);
SET IDENTITY_INSERT dbo.SubscriptionPlan OFF;
GO

SET IDENTITY_INSERT dbo.Subscription ON;
INSERT INTO dbo.Subscription (subscriptionID, serviceProviderID, subscriptionPlanID, startDate, subscriptionStatus) VALUES
    (1, 158, 3, '2026-01-10', N'Active'),
    (2, 145, 3, '2026-02-01', N'Active'),
    (3, 201, 2, '2026-03-01', N'Expired'),
    (4, 312, 2, '2026-04-01', N'Expired'),
    (5, 287, 2, '2026-04-15', N'Expired'),
    (6, 312, 1, '2026-08-01', N'Expired'),
    (7, 201, 2, '2026-08-15', N'Active'),
    (8, 233, 1, '2026-08-20', N'Expired'),
    (9, 312, 2, '2026-09-01', N'Active'),
    (10, 233, 1, '2026-09-20', N'Active'),
    (11, 287, 2, '2026-10-04', N'Cancelled'),
    (12, 287, 1, '2026-10-05', N'Active');
SET IDENTITY_INSERT dbo.Subscription OFF;
GO

SET IDENTITY_INSERT dbo.Payment ON;
INSERT INTO dbo.Payment (paymentID, subscriptionID, paymentDate, amount, paymentStatus, paymentMethod, transactionRef) VALUES
    (1, 1, '2026-01-10 10:02:00', 1299.00, N'Paid', N'Visa', N'PAY-20260110-K7Q2'),
    (2, 2, '2026-02-01 12:40:00', 1299.00, N'Paid', N'Apple Pay', N'PAY-20260201-M3R8'),
    (3, 3, '2026-03-01 09:30:00', 399.00, N'Paid', N'Mastercard', N'PAY-20260301-P9T4'),
    (4, 4, '2026-04-01 08:15:00', 399.00, N'Paid', N'Mada', N'PAY-20260401-B2W6'),
    (5, 5, '2026-04-15 19:45:00', 399.00, N'Paid', N'Mada', N'PAY-20260415-H5N1'),
    (6, 6, '2026-08-01 09:15:00', 150.00, N'Paid', N'Mada', N'PAY-20260801-D8C3'),
    (7, 7, '2026-08-15 18:22:00', 399.00, N'Paid', N'Mastercard', N'PAY-20260815-Z4F7'),
    (8, 8, '2026-08-20 14:00:00', 150.00, N'Paid', N'Mada', N'PAY-20260820-L6V9'),
    (9, 9, '2026-09-01 08:50:00', 399.00, N'Paid', N'Visa', N'PAY-20260901-X1J5'),
    (10, 10, '2026-09-20 13:31:00', 150.00, N'Paid', N'Mada', N'PAY-20260920-R3G8'),
    (11, 11, '2026-10-04 21:12:00', 399.00, N'Failed', N'Visa', NULL),
    (12, 12, '2026-10-05 10:07:00', 150.00, N'Paid', N'Mada', N'PAY-20261005-C5Y7');
SET IDENTITY_INSERT dbo.Payment OFF;
GO

SET IDENTITY_INSERT dbo.Project ON;
INSERT INTO dbo.Project (projectID, homeOwnerID, addressID, projectName, startDate, projectStatus) VALUES
    (118, 4, 5, N'شقة الحمراء', '2026-05-01', N'Completed'),
    (121, 1, 2, N'ترميم فيلا الشاطئ', '2026-04-01', N'Completed'),
    (140, 5, 6, N'منزل الجبيل الصناعية', '2026-07-15', N'Active'),
    (147, 1, 1, N'فيلا الفناتير', '2026-09-01', N'Active'),
    (155, 4, 5, N'استراحة الجبيل', '2026-08-20', N'Active'),
    (163, 2, 3, N'فيلا الدمام الغربية', '2026-08-15', N'Deleted'),
    (170, 3, 4, N'منزل الشاطئ', '2026-10-01', N'Active'),
    (182, 6, 7, N'فيلا اليرموك', '2026-11-01', N'Active');
SET IDENTITY_INSERT dbo.Project OFF;
GO

SET IDENTITY_INSERT dbo.Appointment ON;
INSERT INTO dbo.Appointment (appointmentID, projectID, serviceOfferingID, appointmentDate, appointmentTime, description, appointmentStatus) VALUES
    (1, 118, 1, '2026-04-18', '16:00:00', N'معاينة جدران الشقة قبل الدهان.', N'Completed'),
    (2, 147, 13, '2026-08-26', '09:00:00', N'معاينة أرض الفيلا قبل الحفر.', N'Completed'),
    (3, 140, 1, '2026-08-25', '15:00:00', N'معاينة الجدران الخارجية.', N'Rejected'),
    (4, 155, 1, '2026-09-05', '16:00:00', N'معاينة الاستراحة وتحديد الألوان.', N'Completed'),
    (5, 147, 6, '2026-09-28', '11:00:00', N'قياس مساحة المطبخ.', N'Completed'),
    (6, 163, 2, '2026-10-07', '17:00:00', N'معاينة الجدران الداخلية.', N'Accepted'),
    (7, 147, 1, '2026-10-15', '16:30:00', N'معاينة الجدران قبل الدهان واختيار الألوان.', N'Accepted'),
    (8, 170, 2, '2026-10-16', '10:00:00', N'معاينة المنزل وتقدير المساحات.', N'Accepted'),
    (9, 147, 6, '2026-10-19', '10:00:00', N'اعتماد تصميم المطبخ النهائي.', N'Accepted'),
    (10, 147, 12, '2026-10-21', '09:30:00', N'معاينة لوحة الكهرباء الرئيسية.', N'Pending'),
    (11, 182, 7, '2026-10-24', '16:00:00', N'معاينة مساحة الحديقة الأمامية.', N'Pending');
SET IDENTITY_INSERT dbo.Appointment OFF;
GO

SET IDENTITY_INSERT dbo.ServiceRequest ON;
INSERT INTO dbo.ServiceRequest (serviceRequestID, projectID, serviceOfferingID, startDate, serviceProgress, serviceStatus, requestDate, statusUpdatedAt) VALUES
    (95, 118, 1, '2026-05-10', 100, N'Completed', '2026-04-20 18:00:00', '2026-06-05 16:00:00'),
    (96, 118, 6, '2026-05-20', 100, N'Completed', '2026-04-21 19:30:00', '2026-06-20 12:00:00'),
    (101, 121, 11, '2026-04-10', 100, N'Completed', '2026-03-20 20:00:00', '2026-05-12 15:30:00'),
    (102, 121, 9, '2026-05-01', 100, N'Completed', '2026-03-25 21:10:00', '2026-06-08 10:00:00'),
    (150, 147, 13, '2026-09-01', 100, N'Completed', '2026-08-29 20:00:00', '2026-09-24 17:00:00'),
    (151, 147, 10, '2026-09-25', 100, N'Completed', '2026-09-10 19:00:00', '2026-10-14 18:30:00'),
    (152, 147, 12, '2026-10-10', 0, N'Accepted', '2026-09-22 21:00:00', '2026-09-23 09:10:00'),
    (160, 155, 14, '2026-08-25', 100, N'Completed', '2026-08-12 13:00:00', '2026-09-18 11:00:00'),
    (176, 140, 1, '2026-09-10', 0, N'Rejected', '2026-08-28 17:30:00', '2026-08-30 10:15:00'),
    (188, 155, 1, '2026-09-22', 70, N'In Progress', '2026-09-08 20:10:00', '2026-10-16 18:00:00'),
    (203, 147, 6, '2026-10-20', 0, N'Accepted', '2026-10-06 19:40:00', '2026-10-07 08:30:00'),
    (212, 147, 1, '2026-11-01', 0, N'Pending', '2026-10-16 20:05:00', '2026-10-16 20:05:00'),
    (219, 163, 2, '2026-11-08', 0, N'Pending', '2026-10-12 18:20:00', '2026-10-12 18:20:00'),
    (224, 170, 2, '2026-11-15', 0, N'Pending', '2026-10-16 22:40:00', '2026-10-16 22:40:00'),
    (230, 182, 7, '2026-11-10', 0, N'Pending', '2026-10-15 16:00:00', '2026-10-15 16:00:00'),
    (231, 140, 15, '2026-07-20', 100, N'Completed', '2026-07-05 10:00:00', '2026-08-10 12:00:00');
SET IDENTITY_INSERT dbo.ServiceRequest OFF;
GO

SET IDENTITY_INSERT dbo.Rating ON;
INSERT INTO dbo.Rating (ratingID, serviceRequestID, qualityRating, timeRating, costRating, ratingDate) VALUES
    (1, 95, 5, 5, 4, '2026-06-07 20:00:00'),
    (2, 96, 5, 4, 4, '2026-06-22 18:10:00'),
    (3, 101, 4, 5, 4, '2026-05-14 21:00:00'),
    (4, 102, 5, 5, 5, '2026-06-10 19:30:00'),
    (5, 150, 5, 4, 5, '2026-09-26 20:45:00'),
    (6, 151, 5, 5, 4, '2026-10-15 21:15:00'),
    (7, 160, 4, 4, 5, '2026-09-20 17:00:00'),
    (8, 231, 4, 5, 4, '2026-08-12 20:00:00');
SET IDENTITY_INSERT dbo.Rating OFF;
GO

PRINT 'darana_db: sample data inserted.';
GO
