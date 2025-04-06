-- CampDB_Setup.sql
-- 露營用品銷售網站資料庫建立與資料插入指令

-- 1. 建立資料表（DDL）

-- 客戶資料表
CREATE TABLE IF NOT EXISTS Customer (
    CustomerID INTEGER PRIMARY KEY,
    Name TEXT NOT NULL,
    Phone TEXT,
    Email TEXT,
    Address TEXT
);

-- 產品類別資料表
CREATE TABLE IF NOT EXISTS Category (
    CategoryID INTEGER PRIMARY KEY,
    CategoryName TEXT NOT NULL UNIQUE,
    Description TEXT
);

-- 產品資料表
CREATE TABLE IF NOT EXISTS Product (
    ProductID INTEGER PRIMARY KEY,
    ProductName TEXT NOT NULL,
    CategoryID INTEGER NOT NULL,
    Price REAL NOT NULL CHECK(Price > 0),
    StockQuantity INTEGER NOT NULL DEFAULT 0 CHECK(StockQuantity >= 0),
    Description TEXT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

-- 訂單資料表
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INTEGER PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    OrderDate TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    Status TEXT NOT NULL DEFAULT 'Processing' CHECK(Status IN ('Processing', 'Shipped', 'Completed', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- 訂單明細資料表
CREATE TABLE IF NOT EXISTS OrderDetail (
    OrderID INTEGER,
    ProductID INTEGER,
    Quantity INTEGER NOT NULL CHECK(Quantity > 0),
    UnitPrice REAL NOT NULL CHECK(UnitPrice >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- 供應商資料表
CREATE TABLE IF NOT EXISTS Supplier (
    SupplierID INTEGER PRIMARY KEY,
    SupplierName TEXT NOT NULL,
    ContactName TEXT,
    Phone TEXT,
    Email TEXT,
    Address TEXT
);

-- 產品供應關聯表
CREATE TABLE IF NOT EXISTS ProductSupply (
    ProductID INTEGER,
    SupplierID INTEGER,
    SupplyPrice REAL NOT NULL CHECK(SupplyPrice > 0),
    LeadTimeDays INTEGER DEFAULT 7,
    PRIMARY KEY (ProductID, SupplierID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- 建立索引，提高查詢效能
CREATE INDEX IF NOT EXISTS idx_product_category ON Product(CategoryID);
CREATE INDEX IF NOT EXISTS idx_order_customer ON Orders(CustomerID);
CREATE INDEX IF NOT EXISTS idx_order_date ON Orders(OrderDate);
CREATE INDEX IF NOT EXISTS idx_orderdetail_product ON OrderDetail(ProductID);

-- 2. 插入資料（DML）

-- 插入客戶資料
INSERT INTO Customer (CustomerID, Name, Phone, Email, Address) VALUES 
(1, '王大明', '0912345678', 'daming@example.com', '台北市中山區中山路123號'),
(2, '李小華', '0923456789', 'xiaohua@example.com', '新北市板橋區民生路456號'),
(3, '張小美', '0934567890', 'xiaomei@example.com', '台中市西區公益路789號');

-- 插入產品類別資料
INSERT INTO Category (CategoryID, CategoryName, Description) VALUES 
(1, '帳篷', '各種露營帳篷，包含帳篷本體和配件'),
(2, '睡袋', '各種露營睡袋和睡墊'),
(3, '炊具', '露營烹飪和餐飲用具'),
(4, '照明', '露營照明設備和工具'),
(5, '戶外家具', '折疊桌椅和其他露營家具');

-- 插入產品資料
INSERT INTO Product (ProductID, ProductName, CategoryID, Price, StockQuantity, Description) VALUES 
(1, '四人帳篷', 1, 3200, 15, '適合四人家庭露營使用的防水帳篷'),
(2, '雙人睡袋', 2, 1500, 20, '舒適保暖的雙人睡袋，適合溫度0-15度'),
(3, '露營爐具組', 3, 1200, 8, '含瓦斯爐、鍋具和餐具的露營爐具組'),
(4, 'LED營燈', 4, 450, 30, '高亮度LED充電式營燈，可調光'),
(5, '折疊桌椅組', 5, 1800, 12, '一桌四椅的折疊桌椅組，輕便易攜帶'),
(6, '單人睡墊', 2, 600, 25, '自動充氣式單人睡墊，防潮保暖'),
(7, '二人帳篷', 1, 2200, 10, '輕量化二人帳篷，適合登山使用'),
(8, '多功能露營燈', 4, 650, 18, '多功能LED露營燈，含手電筒和警示燈功能');

-- 插入供應商資料
INSERT INTO Supplier (SupplierID, SupplierName, ContactName, Phone, Email, Address) VALUES 
(1, '山野戶外用品有限公司', '陳經理', '02-12345678', 'contact@shanye.com', '台北市內湖區'),
(2, '大自然戶外裝備', '林總監', '04-23456789', 'info@nature.com', '台中市南區');

-- 插入產品供應關聯
INSERT INTO ProductSupply (ProductID, SupplierID, SupplyPrice, LeadTimeDays) VALUES 
(1, 1, 1800, 5),
(2, 1, 900, 3),
(3, 2, 700, 7),
(4, 2, 250, 4),
(5, 1, 1100, 6),
(6, 1, 350, 3),
(7, 1, 1300, 5),
(8, 2, 380, 4);

-- 插入訂單資料
INSERT INTO Orders (OrderID, CustomerID, OrderDate, Status) VALUES 
(1, 1, '2023-09-15 10:30:00', 'Completed'),
(2, 2, '2023-09-20 14:45:00', 'Shipped'),
(3, 3, '2023-09-25 09:15:00', 'Processing');

-- 插入訂單明細資料
INSERT INTO OrderDetail (OrderID, ProductID, Quantity, UnitPrice) VALUES 
(1, 1, 1, 3200),
(1, 3, 1, 1200),
(1, 4, 2, 450),
(2, 2, 1, 1500),
(2, 6, 2, 600),
(3, 5, 1, 1800),
(3, 8, 1, 650);

-- 3. 查詢資料（DQL）

-- 查詢所有訂單及其詳細資訊
-- 將結果輸出到Ordes_Result.txt
.output Ordes_Result.txt
.mode column
.header on
.width 10 15 20 10 30 10 10 15
SELECT 
    o.OrderID,
    c.Name as CustomerName,
    o.OrderDate,
    o.Status,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) as Subtotal
FROM Orders o
JOIN Customer c ON o.CustomerID = c.CustomerID
JOIN OrderDetail od ON o.OrderID = od.OrderID
JOIN Product p ON od.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductName;

-- 查詢每個類別的銷售總額
SELECT 
    cat.CategoryName,
    SUM(od.Quantity * od.UnitPrice) as TotalSales
FROM OrderDetail od
JOIN Product p ON od.ProductID = p.ProductID
JOIN Category cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID
ORDER BY TotalSales DESC;

-- 查詢庫存量低於10的產品
SELECT 
    p.ProductID,
    p.ProductName,
    cat.CategoryName,
    p.StockQuantity,
    s.SupplierName
FROM Product p
JOIN Category cat ON p.CategoryID = cat.CategoryID
JOIN ProductSupply ps ON p.ProductID = ps.ProductID
JOIN Supplier s ON ps.SupplierID = s.SupplierID
WHERE p.StockQuantity < 10;

.output stdout
