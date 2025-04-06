# 什麼是 SQLite
SQLite 是一個輕量級、嵌入式關係型資料庫管理系統（RDBMS），廣泛應用於行動應用程式、桌面軟體和小規模專案。以下是對其功能、特性及限制的詳細說明，以條列式呈現，方便理解。

---

## **SQLite 的功能**
SQLite 提供基本的關係型資料庫功能，適合簡單且高效的數據管理需求：

1. **標準 SQL 支援**  
   - 支援大部分 SQL-92 標準，如 `SELECT`、`INSERT`、`UPDATE`、`DELETE`、`JOIN` 等。
   - 提供創建表格、索引、視圖和觸發器的能力。

2. **嵌入式儲存**  
   - 不需要獨立的伺服器進程，直接嵌入應用程式中。
   - 數據儲存在單一檔案中（通常為 `.db` 或 `.sqlite` 格式）。

3. **事務處理**  
   - 支援 ACID（原子性、一致性、隔離性、持久性）事務。
   - 提供 WAL（Write-Ahead Logging）模式，提升並發寫入性能。

4. **跨平台支援**  
   - 可運行於 Windows、Linux、macOS、Android、iOS 等多種平台。
   - 不依賴特定硬體或作業系統。

5. **動態類型**  
   - 支援靈活的資料類型（如 INTEGER、TEXT、REAL、BLOB），欄位可儲存任何類型數據。

6. **擴充功能**  
   - 支援自訂函數（UDF）和虛擬表。
   - 可透過擴充模組（如 FTS5）實現全文搜尋。

---

## **SQLite 的特性**
SQLite 的設計使其在特定場景中獨具優勢：

1. **輕量級**  
   - 核心程式庫大小約 700 KB，資源佔用極低。
   - 適合記憶體和儲存空間有限的設備（如手機、嵌入式系統）。

2. **無伺服器架構**  
   - 不需要獨立伺服器，直接由應用程式存取資料庫檔案。
   - 減少配置與維護成本。

3. **單檔案儲存**  
   - 所有數據（表格、索引等）儲存在單一檔案中，便於備份與遷移。

4. **高可靠性**  
   - 經過廣泛測試，穩定性高，適合長期運行。
   - 支援資料庫檔案加密（透過 SQLite Encryption Extension，需付費）。

5. **開源與免費**  
   - 遵循公共領域許可（Public Domain），無版權限制。
   - 可自由使用、修改與分發。

6. **零配置**  
   - 無需安裝或設定即可使用，開箱即用。

---

## **SQLite 的限制**
雖然功能強大，但 SQLite 的設計也帶來一些限制：

1. **並發性能有限**  
   - 僅支援有限的並發寫入（單一寫入者，WAL 模式下稍有改善）。
   - 不適合高並發應用（如大型網站後端）。

2. **資料量限制**  
   - 理論上限：281 TB（檔案系統限制）。
   - 實務建議：資料庫大小超過 1-2 GB 時性能下降，適合中小型數據集。

3. **功能不完整**  
   - 不支援某些進階 SQL 功能，如：
     - `RIGHT OUTER JOIN` 和 `FULL OUTER JOIN`（僅支援 `LEFT JOIN`）。
     - 無存儲過程（Stored Procedures）。
     - 無用戶管理或權限控制（因無伺服器設計）。
   - 觸發器功能有限，無法完全替代複雜邏輯。

4. **不支援分佈式系統**  
   - 單機運行，無法像 MySQL 或 PostgreSQL 那樣實現分區或複製。
   - 不適合需要高可用性或負載平衡的場景。

5. **寫入密集應用受限**  
   - 檔案鎖定機制可能導致寫入瓶頸，尤其在多執行緒環境中。
   - 不適合頻繁寫入的應用（如即時交易系統）。

6. **擴展性不足**  
   - 無法輕鬆升級到企業級資料庫，需重構至其他系統（如 PostgreSQL）。

---

## **總結與適用場景**
- **優勢總結**：輕量、簡單、高效，適合嵌入式應用、小型專案或單機環境。
- **適用場景**：
  - 行動應用（如 iOS/Android App 的本地資料庫）。
  - 桌面軟體（如瀏覽器、媒體播放器）。
  - 原型開發或教育用途。
- **不適用場景**：
  - 高並發 Web 應用。
  - 大規模企業資料庫。
  - 需要複雜權限管理的系統。

若您需要針對特定場景（如行動應用開發）深入分析 SQLite 的應用，或與其他資料庫（如 PostgreSQL）比較，請告訴我，我會進一步調整內容！

SQLite 的資料型別（Data Types）與傳統關係型資料庫（如 MySQL、PostgreSQL）有所不同，它採用**動態型別系統**（Dynamic Typing），這意味著欄位的資料型別並不嚴格綁定，而是根據儲存的值動態決定。以下是 SQLite 資料型別的詳細說明，包括其分類、特性與實際應用，呈現方式為條列式。

---

## **SQLite 資料型別的分類**
SQLite 官方定義了五種主要的**儲存類別**（Storage Classes），這些類別決定了數據在資料庫中的儲存方式：

1. **NULL**  
   - **描述**：表示空值或無數據。
   - **用途**：用於表示缺失或未知的值。
   - **範例**：`NULL`（如某欄位未填寫）。

2. **INTEGER**  
   - **描述**：有符號整數，根據值大小使用 1、2、3、4、6 或 8 位元組儲存。
   - **範圍**：-2^63 到 +2^63-1（約 ±9.22  quintillion）。
   - **用途**：儲存整數數據，如 ID、年齡。
   - **範例**：`42`, `-15`, `0`。

3. **REAL**  
   - **描述**：浮點數，使用 8 位元組儲存（IEEE 754 格式）。
   - **範圍**：精確度約 15-17 位有效數字。
   - **用途**：儲存帶小數的數值，如價格、溫度。
   - **範例**：`3.14`, `-0.001`, `2.0`。

4. **TEXT**  
   - **描述**：文字字符串，支援 UTF-8、UTF-16BE 或 UTF-16LE 編碼。
   - **長度**：無嚴格限制（取決於資料庫檔案大小，上限約 281 TB）。
   - **用途**：儲存文字數據，如姓名、地址。
   - **範例**：`"Hello"`, `"John Doe"`, `""`（空字符串）。

5. **BLOB**  
   - **描述**：二進位大型物件（Binary Large Object），儲存原始二進位數據。
   - **長度**：無嚴格限制（同 TEXT）。
   - **用途**：儲存圖片、文件或其他非結構化數據。
   - **範例**：`x'89504E47'`（PNG 檔案開頭的十六進位數據）。

---

### **動態型別的特性**
SQLite 的動態型別系統帶來以下獨特特性：

1. **型別親和性 (Type Affinity)**  
   - SQLite 在創建表格時，可以指定欄位的「親和性」（Affinity），但不強制約束儲存值的型別。
   - 五種親和性：
     - **INTEGER**：偏好儲存整數。
     - **REAL**：偏好儲存浮點數。
     - **TEXT**：偏好儲存文字。
     - **BLOB**：偏好儲存二進位數據。
     - **NUMERIC**：偏好儲存數字（整數或浮點數），若無法轉換則儲存原始值。
   - **範例**：  
     ```sql
     CREATE TABLE example (id INTEGER, value TEXT);
     INSERT INTO example VALUES ('123', 456); -- 允許插入不同型別
     ```

2. **靈活儲存**  
   - 一個欄位可以儲存任何儲存類別的值，不會因宣告型別而拒絕。
   - 範例：宣告為 `INTEGER` 的欄位仍可儲存 `"abc"`，但查詢時會嘗試轉為整數（失敗則返回原始值）。

3. **型別轉換**  
   - SQLite 在運算或比較時會自動嘗試轉換型別。
   - 範例：`"123" + 1` 結果為 `124`（文字轉整數）。

---

### **與 SQL 標準型別的對應**
雖然 SQLite 使用儲存類別，但支援傳統 SQL 型別的語法，這些型別會映射到對應的親和性：

| **SQL 型別**         | **映射到的親和性** |
|-----------------------|---------------------|
| INT, INTEGER, BIGINT  | INTEGER            |
| REAL, DOUBLE, FLOAT   | REAL               |
| CHAR, VARCHAR, TEXT   | TEXT               |
| BLOB, BINARY          | BLOB               |
| NUMERIC, DECIMAL      | NUMERIC            |

- **注意**：SQLite 不強制執行長度限制（如 `VARCHAR(50)` 的 50 不生效），僅作為親和性參考。

---
## Install SQLite

- 安裝 SQLite [Download](https://sqlite.com/download.html)
- 安裝 DBeaver GUI [Download](https://dbeaver.io/)


### install sqlite for windows
1. download sqlite
2. 解壓縮
3. 資料夾更名 sqlite
4. move folder to c:\
5. search environment
6. edit environment system
7. button environment variables
8. path -> edit
9. New -> C:\sqlite


### **實際應用範例**
以下是一個簡單的表格定義與資料，展示型別使用：
```sql
CREATE TABLE students (
  student_id INTEGER PRIMARY KEY,  -- 整數主鍵
  name TEXT,                      -- 文字
  gpa REAL,                       -- 浮點數
  photo BLOB,                     -- 二進位數據
  notes TEXT                      -- 可儲存任何值
);

INSERT INTO students VALUES 
  (1, 'Alice', 3.8, NULL, 'Good student'),
  (2, 'Bob', 3.2, x'89504E47', 123); -- BLOB 與數字混用
```
** IF NOT EXISTS **
```
CREATE TABLE IF NOT EXISTS students (
  student_id INTEGER PRIMARY KEY,  
  name TEXT,                     
  gpa REAL,                       
  photo BLOB,                    
  notes TEXT                      
);
```

---

### **限制與注意事項**
1. **無嚴格型別檢查**  
   - 不像 MySQL 或 PostgreSQL，SQLite 不會阻止插入不匹配的型別，可能導致數據一致性問題。
2. **無日期/時間型別**  
   - 無內建 `DATE` 或 `TIMESTAMP` 型別，需用 TEXT（如 "2023-10-15"）、INTEGER（Unix 時間戳）或 REAL（Julian 日）儲存。
   - 支援日期函數（如 `strftime`）處理。
3. **大小限制**  
   - 單一值最大約 1 GB（由 `SQLITE_MAX_LENGTH` 控制），但建議避免過大數據以保持性能。

### **總結**
- **功能**：SQLite 提供靈活的動態型別系統，支援五種儲存類別，滿足基本資料庫需求。
- **特性**：簡單、輕量，型別親和性允許高度自由度。
- **限制**：缺乏嚴格型別約束與進階型別（如日期），適合小型應用而非複雜系統。

若您需要針對某應用場景（如嵌入式系統）分析 SQLite 型別的應用，或想比較其與其他資料庫的型別系統，請告訴我，我會進一步深化說明！

---
### 新增 (insert) 及刪除 (delete) 資料
SQLite 中 INSERT 和 DELETE 的各種方式：

1. INSERT 插入資料的方法

基本插入：
```sql
-- 標準插入
INSERT INTO users (username, email) 
VALUES ('john_doe', 'john@example.com');

-- 完整欄位插入
INSERT INTO users (id, username, email) 
VALUES (1, 'john_doe', 'john@example.com');
```

批次插入：
```sql
-- 一次插入多筆資料
INSERT INTO users (username, email) VALUES 
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('bob_jones', 'bob@example.com');
```

預設值插入：
```sql
-- 使用預設值
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price DECIMAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name) VALUES ('Apple');
```

2. DELETE 刪除資料的方法

基本刪除：
```sql
-- 刪除符合條件的所有資料
DELETE FROM users WHERE username = 'john_doe';

-- 刪除特定 ID 的資料
DELETE FROM users WHERE id = 5;
```
---
### 更新資料 (UPDATE)
SQLite 的 UPDATE 語法有多種使用方式：

1. 基本 UPDATE
```sql
-- 更新單一欄位
UPDATE users 
SET username = 'new_username' 
WHERE id = 1;

-- 更新多個欄位
UPDATE users 
SET 
    username = 'new_username',
    email = 'new_email@example.com' 
WHERE id = 1;
```

2. 條件更新
```sql
-- 多條件更新
UPDATE products 
SET price = price * 1.1  -- 加10%
WHERE category = 'Electronics' 
AND stock > 0;
```

3. 更新所有資料
```sql
-- 更新表中所有資料
UPDATE users 
SET is_active = 1;
```

注意事項：
- 更新前務必確認條件
- 大量更新考慮效能
- 使用事務處理
- 注意資料完整性

最佳實踐：
- 明確指定更新條件
- 考慮效能和資源消耗
- 驗證更新結果

---
## 修改和刪除資料表

1. 修改資料表 (ALTER TABLE)

增加新欄位：
```sql
-- 為 users 表格增加新欄位
ALTER TABLE users 
ADD COLUMN phone TEXT;
```

重新命名資料表：
```sql
-- 將 users 表格重新命名為 customers
ALTER TABLE users 
RENAME TO customers;
```

2. 刪除資料表
```sql
-- 直接刪除資料表
DROP TABLE users;

-- 如果表格存在則刪除（避免錯誤）
DROP TABLE IF EXISTS users;
```

3. 完整範例

建立原始資料表：
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT,
    email TEXT
);
```

修改資料表結構：
```sql
-- 增加新欄位
ALTER TABLE users 
ADD COLUMN age INTEGER;

-- 增加預設值的欄位
ALTER TABLE users 
ADD COLUMN registration_date DATE DEFAULT CURRENT_DATE;
```

4. 重新命名欄位（SQLite 限制）
SQLite 不直接支持 RENAME COLUMN，需要變通方法：
```sql
-- 建立新表格
CREATE TABLE new_users (
    id INTEGER PRIMARY KEY,
    full_name TEXT,  -- 替代 username
    email TEXT
);

-- 複製資料
INSERT INTO new_users (id, full_name, email)
SELECT id, username, email FROM users;

-- 刪除舊表
DROP TABLE users;

-- 重新命名新表
ALTER TABLE new_users 
RENAME TO users;
```

5. 約束和索引管理
```sql
-- 增加唯一約束
CREATE UNIQUE INDEX idx_unique_email 
ON users(email);

-- 刪除索引
DROP INDEX idx_unique_email;
```

6. 實際業務場景範例
```sql
-- 原始使用者表
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT,
    email TEXT
);

-- 擴充使用者資訊
ALTER TABLE users 
ADD COLUMN phone TEXT;

ALTER TABLE users 
ADD COLUMN address TEXT;

-- 增加註冊日期
ALTER TABLE users 
ADD COLUMN register_date DATE DEFAULT CURRENT_DATE;
```

注意事項：
- SQLite 的 ALTER TABLE 功能比其他資料庫有限
- **複雜的結構變更需要重建資料表**
- **修改表格前務必備份資料**
- 大型資料表修改可能需要較長時間

建議流程：
1. 備份原始資料
2. 規劃修改
3. 測試修改
4. 執行修改
5. 驗證資料完整性

實用提示：
- 使用 `IF EXISTS` 避免不存在表格的錯誤
- 謹慎進行不可逆的操作
- 對於複雜的表格修改，建議使用程式輔助

---
## SQLite 鍵（Key）類型說明

SQLite 支援多種類型的鍵（keys）用於資料表設計和關聯管理。以下是 SQLite 中主要的鍵類型：

### 主鍵（PRIMARY KEY）

```sql
-- 單一欄位作為主鍵
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT NOT NULL
);
/* 
自動產生的主鍵 product_id
AUTOINCREMENT
*/

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL
);
```

SQLite 的主鍵特性：
- 可以使用任何資料型別作為主鍵，但通常使用 INTEGER
- 當宣告為 `INTEGER PRIMARY KEY` 時，該欄位會**自動成為別名為 `rowid` 的內部主鍵**
- 不使用 AUTOINCREMENT：當您刪除最大 ID 的記錄時，下一個插入的記錄可能會重用已刪除的 ID
- 使用 AUTOINCREMENT：系統會保證新 ID 永遠大於表中曾經使用過的最大 ID

大多數情況下，簡單的 INTEGER PRIMARY KEY 就足夠了，除非您的應用程式有特殊需求，要求 ID 永不重用（這在某些安全場景或需要嚴格遞增的情境中可能很重要）。
此外，**不使用 AUTOINCREMENT 還有些微的性能優勢，因為它不需要維護額外的內部計數器表**。

### 複合主鍵（COMPOSITE PRIMARY KEY）

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date TEXT,
    PRIMARY KEY (student_id, course_id)
);
```

複合主鍵特性：
- 由多個欄位組合而成
- 組合值在整個資料表中必須唯一
- 複合主鍵不能使用 `AUTOINCREMENT`

### 外鍵（FOREIGN KEY）

SQLite 從 3.6.19 版本開始支援外鍵約束，但預設是關閉的。需要使用 `PRAGMA foreign_keys = ON;` 啟用。

```sql
-- 啟用外鍵支援
PRAGMA foreign_keys = ON;

-- 單一外鍵
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 複合外鍵
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

外鍵特性：
- 用於建立表格之間的關聯
- 可以設定在更新或刪除參照記錄時的行為（CASCADE, SET NULL, SET DEFAULT, RESTRICT）
- 可以對**單一欄位或多個欄位**（複合外鍵）進行設定

### 唯一鍵（UNIQUE KEY）

```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    phone TEXT UNIQUE
);

-- 複合唯一鍵
CREATE TABLE employee_projects (
    employee_id INTEGER,
    project_id INTEGER,
    role TEXT,
    UNIQUE (employee_id, project_id)
);
```

唯一鍵特性：
- 確保該欄位或欄位組合的值在表格中是**唯一**的

與主鍵不同，**唯一鍵允許 NULL 值**（SQLite 中，多個 NULL 值被視為不同值）

### 索引（INDEX）

雖然索引不是嚴格意義上的「鍵」，但它們在關聯資料庫中扮演重要角色：

```sql
-- 創建索引
CREATE INDEX idx_customers_name ON customers(last_name, first_name);

-- 唯一索引
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

索引特性：
- 提升查詢效能
- 可以是單一欄位或多個欄位
- 可以設定為唯一索引（UNIQUE INDEX）

SQLite 的鍵結構雖然相比其他大型關聯式資料庫系統較為簡單，但仍提供了足夠的功能來確保資料的完整性和高效查詢。

---
### 約束（Constraints）
用來定義資料表中資料的規則和限制。

#### 常見的約束語法：

1. 主鍵約束 (PRIMARY KEY)
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL UNIQUE
);
```

2. 唯一約束 (UNIQUE)
```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    phone TEXT UNIQUE
);
```

3. 非空約束 (NOT NULL)
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price DECIMAL NOT NULL
);
```

4. 預設值約束 (DEFAULT)
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    order_date DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'Pending',
    total DECIMAL DEFAULT 0
);
```

5. 檢查約束 (CHECK)
```sql
CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    age INTEGER CHECK (age >= 18 AND age <= 100),
    score DECIMAL CHECK (score >= 0 AND score <= 100)
);
```

6. 外鍵約束 (FOREIGN KEY)
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

7. 複合主鍵
```sql
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
```

8. 組合約束
```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    salary DECIMAL CHECK (salary > 0),
    age INTEGER CHECK (age >= 18)
);
```

9. 外鍵約束（帶有級聯操作）
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

完整範例：
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    age INTEGER CHECK (age >= 18),
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price DECIMAL CHECK (price > 0),
    stock INTEGER CHECK (stock >= 0)
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    product_id INTEGER,
    quantity INTEGER CHECK (quantity > 0),
    order_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

約束的重要性：
1. 保證資料完整性
2. 防止無效資料輸入
3. 建立資料表之間的關聯
4. 提供基本的資料驗證

建議：
- 根據業務邏輯設計約束
- 合理使用約束來防止不合理的資料
- 平衡效能和資料完整性

注意事項：
- SQLite 的約束支援比某些資料庫系統較為簡單
- 某些複雜的約束可能需要應用層邏輯處理

---
### 資料處理函式
在 SQLite 中，有許多實用的資料處理函式可以幫助您操作和轉換資料。以下是一些常用的函式：

1. 字串處理函式
- `length()`: 計算字串長度
- `substr()`: 擷取子字串
- `trim()`: 移除字串左右兩側的空白
- `upper()`: 將字串轉換為大寫
- `lower()`: 將字串轉換為小寫
- `replace()`: 替換字串中的特定內容

2. 數值處理函式
- `round()`: 四捨五入
- `abs()`: 取絕對值
- `ceil()`: 向上取整
- `floor()`: 向下取整
- `max()`: 取最大值
- `min()`: 取最小值

3. 日期和時間函式
- `date()`: 日期處理
- `time()`: 時間處理
- `datetime()`: 日期時間處理
- `strftime()`: 格式化日期時間

4. 彙總函式
- `count()`: 計算記錄數
- `sum()`: 總和
- `avg()`: 平均值
- `max()`: 最大值
- `min()`: 最小值

5. 邏輯函式
- `coalesce()`: 回傳第一個非 NULL 的值
- `ifnull()`: 如果為 NULL 則回傳預設值
- `nullif()`: 比較兩值是否相等，相等則回傳 NULL

6. 型態轉換函式
- `cast()`: 將值轉換為指定型態

舉例說明:

```sql
-- 字串處理
SELECT upper(name), length(name) FROM users;

-- 數值處理
SELECT round(price, 2) FROM products;

-- 日期處理
SELECT date('now');

-- 彙總
SELECT avg(salary) FROM employees;

-- 邏輯函式
SELECT coalesce(nickname, name) FROM users;
```

這些函式讓 SQLite 中的資料處理變得更加靈活和高效。
