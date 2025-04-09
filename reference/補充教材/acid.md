# ACID
在資料庫系統中，**ACID** 是一個重要的概念，用來保證交易（Transaction）的可靠性與數據完整性。ACID 是四個特性（Atomicity、Consistency、Isolation、Durability）的縮寫。以下我會詳細說明每個特性，並以「線上訂閱制雜誌公司」的場景為例，展示其應用。

---

## **ACID 特性說明**

### **1. Atomicity（原子性）**
- **定義**：交易中的所有操作要麼全部成功執行並提交（Commit），要麼全部失敗並回滾（Rollback），不會有部分執行的情況。
- **目的**：確保交易是一個不可分割的單元，避免資料庫處於不一致的狀態。
- **實現方式**：透過回滾日誌（Rollback Journal）或預寫日誌（WAL）記錄操作，若失敗則還原。

### **2. Consistency（一致性）**
- **定義**：交易執行前後，資料庫必須從一個一致狀態轉換到另一個一致狀態，滿足所有約束條件（如主鍵、外鍵、檢查約束）。
- **目的**：保證數據符合業務邏輯與規則。
- **實現方式**：由資料庫的約束與觸發器（Trigger）強制執行。

### **3. Isolation（隔離性）**
- **定義**：多個交易同時執行時，彼此之間互不干擾，每個交易看到的數據是獨立的，直到交易提交才影響其他交易。
- **目的**：防止並發交易導致數據不一致（如髒讀、不可重複讀）。
- **實現方式**：透過鎖定機制（Locking）或多版本並行控制（MVCC）實現。

### **4. Durability（持久性）**
- **定義**：一旦交易提交，其結果必須永久儲存，即使系統崩潰也能恢復。
- **目的**：確保數據不會因硬體或軟體故障丟失。
- **實現方式**：將交易記錄寫入非揮發性儲存（如硬碟）並同步。

---

## **範例：線上訂閱制雜誌公司**
假設有一個簡單的資料庫，包含以下表格：
- **`customers`**：客戶資料
- **`subscriptions`**：訂閱記錄
- **`magazines`**：雜誌資料

### **表格結構**
```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    balance REAL
);

CREATE TABLE magazines (
    magazine_id INTEGER PRIMARY KEY,
    title TEXT,
    price REAL
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    magazine_id INTEGER,
    start_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (magazine_id) REFERENCES magazines(magazine_id)
);
```

### **初始數據**
```sql
INSERT INTO customers VALUES (1, 'Alice', 1000.0);
INSERT INTO magazines VALUES (1, '科技月刊', 100.0);
```

### **場景：客戶訂閱雜誌**
客戶 Alice（`customer_id = 1`）訂閱「科技月刊」（`magazine_id = 1`），需從餘額扣款並記錄訂閱。以下展示 ACID 如何運作。

---

## **範例 1：Atomicity（原子性）**
- **交易內容**：
  1. 檢查 Alice 的餘額是否足夠（1000 ≥ 100）。
  2. 從 `customers.balance` 扣除 100。
  3. 插入一筆訂閱記錄到 `subscriptions`。
- **SQL**：
```sql
BEGIN TRANSACTION;
UPDATE customers SET balance = balance - 100 WHERE customer_id = 1;
INSERT INTO subscriptions (customer_id, magazine_id, start_date) 
VALUES (1, 1, '2023-10-01');
COMMIT;
```
- **範例情境**：
  - 若插入 `subscriptions` 失敗（例如外鍵無效），交易回滾，餘額不會扣除。
  - **結果**：要麼餘額變為 900 且訂閱成功，要麼保持 1000 且無訂閱記錄。

---

## **範例 2：Consistency（一致性）**
- **約束**：假設新增檢查約束，餘額不得為負。
```sql
ALTER TABLE customers ADD CHECK (balance >= 0);
```
- **交易內容**：
  - Alice 餘額為 50，嘗試訂閱價格 100 的雜誌。
- **SQL**：
```sql
BEGIN TRANSACTION;
UPDATE customers SET balance = balance - 100 WHERE customer_id = 1; -- 餘額變為 -50
INSERT INTO subscriptions (customer_id, magazine_id, start_date) 
VALUES (1, 1, '2023-10-01');
COMMIT;
```
- **結果**：
  - 因違反 `CHECK (balance >= 0)`，交易失敗並回滾。
  - **保證**：資料庫保持一致，餘額不會變負。

---

## **範例 3：Isolation（隔離性）**
- **情境**：兩個交易同時執行：
  - 交易 A：Alice 訂閱「科技月刊」（扣款 100）。
  - 交易 B：查詢 Alice 的餘額。
- **無隔離性（假設）**：
  - 交易 A 扣款後未提交，交易 B 看到餘額為 900（髒讀）。
  - 若 A 回滾，B 看到的數據不正確。
- **有隔離性（SQLite WAL 模式）**：
```sql
-- 交易 A
BEGIN TRANSACTION;
UPDATE customers SET balance = balance - 100 WHERE customer_id = 1;
INSERT INTO subscriptions (customer_id, magazine_id, start_date) VALUES (1, 1, '2023-10-01');
-- 未提交

-- 交易 B（另一連線）
SELECT balance FROM customers WHERE customer_id = 1; -- 仍看到 1000
```
- **結果**：
  - 交易 B 看到提交前的數據（1000），直到 A 提交後才變為 900。
  - **保證**：交易間互不干擾。

---

## **範例 4：Durability（持久性）**
- **交易內容**：
  - Alice 成功訂閱，餘額扣除並記錄。
- **SQL**：
```sql
BEGIN TRANSACTION;
UPDATE customers SET balance = balance - 100 WHERE customer_id = 1;
INSERT INTO subscriptions (customer_id, magazine_id, start_date) 
VALUES (1, 1, '2023-10-01');
COMMIT;
```
- **情境**：交易提交後系統立即崩潰。
- **結果**：
  - 重啟後，資料庫恢復：
    - `customers.balance = 900`
    - `subscriptions` 含新記錄。
  - **保證**：提交的數據永久儲存（SQLite 使用 WAL 或 Journal 檔案實現）。

---

## **總結與圖書館管理系統應用**
以您提供的 SQLite 圖書館 SQL 為例：
- **Atomicity**：借書時更新 `Books.AvailableCopies` 並插入 `BorrowingRecords`，若失敗則回滾，避免數量不符。
- **Consistency**：檢查約束（如 `AvailableCopies <= TotalCopies`）確保借閱不超量。
- **Isolation**：多個會員同時查詢與借書，WAL 模式下查詢不被寫入阻塞。
- **Durability**：借閱記錄提交後，即使伺服器斷電，數據仍保留。

ACID 是資料庫的核心保障，SQLite 透過 WAL 與鎖定機制實現這些特性，適合中小型應用。若需更高並發性，可考慮其他資料庫（如 PostgreSQL）。若您想深入某特性或測試特定場景，請告訴我！