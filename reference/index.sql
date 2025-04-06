CREATE TABLE Factory_Products (
    Emblem_ID VARCHAR(10),        -- 標誌或編號，唯一識別符，假設為字串
    Factory_CName NVARCHAR(100),     -- 工廠中文名稱，支援中文，必須填寫
    Factory_Address NVARCHAR(200),            -- 工廠地址，支援中文，可為空
    Factory_Tel VARCHAR(20),                  -- 工廠電話，字串格式（如 +886-2-12345678）
    Factory_Fax VARCHAR(20),                  -- 工廠傳真，字串格式，可為空
    Factory_Director NVARCHAR(50),            -- 工廠負責人姓名，支援中文，可為空
    Material_Name NVARCHAR(100),              -- 材料名稱，支援中文，可為空
    PType_Name NVARCHAR(50),                  -- 產品類型名稱，支援中文，可為空
    Product_Name NVARCHAR(100)                -- 產品名稱，支援中文，可為空
);

CREATE TABLE Factory_Products_index (
    Emblem_ID VARCHAR(10),        -- 標誌或編號，唯一識別符，假設為字串
    Factory_CName NVARCHAR(100),     -- 工廠中文名稱，支援中文，必須填寫
    Factory_Address NVARCHAR(200),            -- 工廠地址，支援中文，可為空
    Factory_Tel VARCHAR(20),                  -- 工廠電話，字串格式（如 +886-2-12345678）
    Factory_Fax VARCHAR(20),                  -- 工廠傳真，字串格式，可為空
    Factory_Director NVARCHAR(50),            -- 工廠負責人姓名，支援中文，可為空
    Material_Name NVARCHAR(100),              -- 材料名稱，支援中文，可為空
    PType_Name NVARCHAR(50),                  -- 產品類型名稱，支援中文，可為空
    Product_Name NVARCHAR(100)                -- 產品名稱，支援中文，可為空
);

CREATE INDEX idx_Emblem_ID ON Factory_Products_index(Emblem_ID);

select * from Factory_Products WHERE Emblem_ID = '121002';
select * from Factory_Products_index WHERE Emblem_ID = '121002';
