# 露營用品銷售網站資料庫專案

## 專案簡述
此專案建立一個露營用品銷售網站的資料庫，並實現銷售紀錄的查詢功能。整個資料庫從規劃設計到實際建立，遵循資料庫正規化原則，經過1NF、2NF和3NF的演進過程。

## 資料模型與正規化說明

### 原始資料需求分析
假設我們收集到的原始資料欄位包含：訂單編號、客戶資訊（ID、姓名、電話、電子郵件、地址）、產品資訊（ID、名稱、類別、價格、庫存量、描述）、訂單日期、訂購數量等。

### 第一正規化(1NF)
首先，我們確保每個欄位都是原子值（不可再分割），不存在重複的列。

**未正規化的資料表：**
```
訂單(訂單編號, 客戶ID, 客戶姓名, 客戶電話, 客戶電子郵件, 客戶地址, 產品ID, 產品名稱, 產品類別, 產品價格, 產品庫存, 產品描述, 訂購數量, 訂單日期, 訂單狀態)
```

**1NF表格：**
```
訂單(訂單編號, 客戶ID, 客戶姓名, 客戶電話, 客戶電子郵件, 客戶地址, 產品ID, 產品名稱, 產品類別, 產品價格, 產品庫存, 產品描述, 訂購數量, 訂單日期, 訂單狀態)
```

在1NF階段，我們的資料已經符合每個欄位都是原子值的要求，但仍然存在著資料冗餘和更新異常的問題。

### 第二正規化(2NF)
在2NF中，我們確保所有非主鍵屬性都完全依賴於主鍵，如果某個屬性只依賴於主鍵的一部分，就應該被分離出來。

分析資料表：
- 客戶資訊只依賴於客戶ID，不完全依賴於訂單編號
- 產品資訊只依賴於產品ID，不完全依賴於訂單編號

**2NF表格：**
```
客戶(客戶ID, 客戶姓名, 客戶電話, 客戶電子郵件, 客戶地址)
產品(產品ID, 產品名稱, 產品類別, 產品價格, 產品庫存, 產品描述)
訂單(訂單編號, 客戶ID, 訂單日期, 訂單狀態)
訂單明細(訂單編號, 產品ID, 訂購數量, 單價)
```

經過2NF的處理，我們解決了資料冗餘的問題，但仍然有可能存在傳遞依賴。

### 第三正規化(3NF)
在3NF中，我們要確保所有非主鍵屬性都不傳遞依賴於主鍵，也就是非主鍵屬性之間不應該相互依賴。

分析現有資料表：
- 產品類別資訊可能依賴於產品類別名稱，而不直接依賴於產品ID

**3NF表格：**
```
客戶(客戶ID, 客戶姓名, 客戶電話, 客戶電子郵件, 客戶地址)
產品類別(類別ID, 類別名稱, 類別描述)
產品(產品ID, 產品名稱, 類別ID, 產品價格, 產品庫存, 產品描述)
訂單(訂單編號, 客戶ID, 訂單日期, 訂單狀態)
訂單明細(訂單編號, 產品ID, 訂購數量, 單價)
```

為了更完整地支援業務需求，我們還增加了額外的資料表：
```
供應商(供應商ID, 供應商名稱, 聯絡人, 電話, 電子郵件, 地址)
產品供應(產品ID, 供應商ID, 供應價格, 交貨天數)
```

## 資料庫表格結構

### 1. 客戶表 (Customer)
- CustomerID (INTEGER): 客戶唯一識別碼，主鍵
- Name (TEXT): 客戶姓名
- Phone (TEXT): 電話號碼
- Email (TEXT): 電子郵件
- Address (TEXT): 地址

### 2. 產品類別表 (Category)
- CategoryID (INTEGER): 類別唯一識別碼，主鍵
- CategoryName (TEXT): 類別名稱
- Description (TEXT): 類別描述

### 3. 產品表 (Product)
- ProductID (INTEGER): 產品唯一識別碼，主鍵
- ProductName (TEXT): 產品名稱
- CategoryID (INTEGER): 產品類別識別碼，外鍵
- Price (REAL): 產品價格
- StockQuantity (INTEGER): 庫存數量
- Description (TEXT): 產品描述

### 4. 訂單表 (Orders)
- OrderID (INTEGER): 訂單唯一識別碼，主鍵
- CustomerID (INTEGER): 客戶識別碼，外鍵
- OrderDate (TEXT): 訂單日期
- Status (TEXT): 訂單狀態

### 5. 訂單明細表 (OrderDetail)
- OrderID (INTEGER): 訂單識別碼，外鍵
- ProductID (INTEGER): 產品識別碼，外鍵
- Quantity (INTEGER): 購買數量
- UnitPrice (REAL): 單價
- 主鍵: (OrderID, ProductID)

### 6. 供應商表 (Supplier)
- SupplierID (INTEGER): 供應商唯一識別碼，主鍵
- SupplierName (TEXT): 供應商名稱
- ContactName (TEXT): 聯絡人
- Phone (TEXT): 電話號碼
- Email (TEXT): 電子郵件
- Address (TEXT): 地址

### 7. 產品供應表 (ProductSupply)
- ProductID (INTEGER): 產品識別碼，外鍵
- SupplierID (INTEGER): 供應商識別碼，外鍵
- SupplyPrice (REAL): 供應價格
- LeadTimeDays (INTEGER): 交貨天數
- 主鍵: (ProductID, SupplierID)

## 資料庫操作指南

1. 執行 `CampDB_Setup.sql` 腳本來建立資料庫結構並插入初始資料。
2. 查詢結果存儲在 `Orders_Result.txt` 中。

## 資料庫視圖關係

客戶(1) ----< 訂單(多)
產品類別(1) ----< 產品(多)
產品(多) >---- 訂單明細(多) ----< 訂單(多)
供應商(多) >---- 產品供應(多) ----< 產品(多)

## 索引設計
為了提高查詢性能，資料庫包含以下索引：
- 產品表的類別ID索引
- 訂單表的客戶ID索引
- 訂單表的日期索引
- 訂單明細表的產品ID索引

## 資料完整性約束
1. 主鍵約束：每個表都有明確的主鍵
2. 外鍵約束：所有關聯都有正確的外鍵引用
3. CHECK約束：確保數量、價格等數值欄位的合理性
4. NOT NULL約束：確保重要欄位不為空
5. DEFAULT值：為部分欄位設定預設值
