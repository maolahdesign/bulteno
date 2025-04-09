# 交易處理與並行存取控制

## 11.0 學習指引

本章節將介紹資料庫系統中的交易處理與並行存取控制機制，這是確保多用戶環境下資料一致性的關鍵技術。我們將使用SQLite作為實例來說明這些概念，透過理論與實務相結合的方式，幫助您理解交易如何確保資料庫操作的ACID特性，以及各種並行控制機制如何避免資料不一致的問題。

學習目標：
- 理解交易的基本概念與ACID特性
- 掌握交易處理中的排程與回復機制
- 學習並行控制的各種技術與應用場景
- 了解分散式資料庫中的交易處理特點

建議先備知識：
- 基本的SQL查詢語法
- 資料庫的基本結構與操作

## 11.1 交易處理與並行存取控制的觀念簡介

### 11.1.1 交易的基本觀念

**交易(Transaction)** 是資料庫管理系統中的一個邏輯工作單位，它由一系列資料庫操作組成，這些操作要麼全部成功執行，要麼全部不執行，保證資料庫從一個一致性狀態轉變到另一個一致性狀態。

#### ACID特性

交易必須滿足的四個特性：

1. **原子性(Atomicity)**：交易中的所有操作視為一個不可分割的工作單位，要麼全部完成，要麼全部失敗復原。
2. **一致性(Consistency)**：交易執行前後，資料庫都必須處於一致性狀態。
3. **隔離性(Isolation)**：一個交易的執行不應該被其他交易干擾。
4. **持久性(Durability)**：一旦交易提交，其結果應該永久保存在資料庫中。

#### SQLite中的交易示例

```sql
-- 開始交易
BEGIN TRANSACTION;

-- 從帳戶A扣除100元
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';

-- 向帳戶B增加100元
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';

-- 如果以上操作都成功，提交交易
COMMIT;

-- 如果出現問題，復原交易
-- ROLLBACK;
```

### 11.1.2 交易處理中並行存取控制的由來

在多用戶環境下，多個交易可能同時訪問相同的資料，如果沒有適當的控制機制，可能導致以下問題：

1. **更新遺失(Lost Update)**：兩個交易同時修改同一筆資料，後者覆蓋前者的修改。
2. **髒讀(Dirty Read)**：一個交易讀取了另一個未提交交易修改的資料。
3. **不可重複讀(Non-repeatable Read)**：一個交易內多次讀取同一資料，但由於其他交易的提交修改，導致多次讀取的結果不同。
4. **幻讀(Phantom Read)**：一個交易在讀取某個範圍的記錄時，另一個交易插入了新記錄，導致再次讀取時出現「幻影」記錄。

**並行存取控制**就是為了解決這些問題而設計的，確保多個交易可以安全地並行執行。

### 11.1.3 從實例中看交易處理的問題

考慮以下情境：銀行系統中兩個用戶同時操作帳戶A和B。

```sql
-- 創建測試資料表
CREATE TABLE Accounts (
    AccountID TEXT PRIMARY KEY,
    CustomerName TEXT,
    Balance REAL CHECK(Balance >= 0)
);

-- 插入測試資料
INSERT INTO Accounts VALUES ('A', '張三', 1000);
INSERT INTO Accounts VALUES ('B', '李四', 500);
```

**情境1：更新遺失**

交易T1和T2同時讀取帳戶A的餘額，分別加上不同的金額，然後更新。

交易T1：
```sql
BEGIN TRANSACTION;
-- 讀取A的餘額=1000
-- 計算新餘額=1000+200=1200
UPDATE Accounts SET Balance = 1200 WHERE AccountID = 'A';
COMMIT;
```

交易T2：
```sql
BEGIN TRANSACTION;
-- 讀取A的餘額=1000
-- 計算新餘額=1000+300=1300
UPDATE Accounts SET Balance = 1300 WHERE AccountID = 'A';
COMMIT;
```

如果T1先執行完畢，然後T2執行，最終A的餘額將是1300，而不是應該的1500，造成更新遺失。

## 11.2 交易的排程 (schedule) 與回復 (recovery) 

### 11.2.1 從系統的觀點來看交易

#### 系統記錄檔 (System log)

**系統記錄檔**是資料庫系統用來記錄所有交易操作的文件，包含足夠的信息以便系統在發生故障時可以恢復到前一致狀態。

SQLite中，日誌檔案通常稱為"journal"，在交易開始時自動創建，交易提交後自動刪除。

```sql
-- 開啟SQLite的日誌模式
PRAGMA journal_mode = WAL;
```

#### 交易的確認點 (commit point)

**確認點**是交易執行過程中的一個標記，表示交易已成功完成並且所有更改已經永久保存。

在SQLite中，使用`COMMIT`語句來標記確認點：

```sql
BEGIN TRANSACTION;
-- 一系列操作
COMMIT;
```

#### System log 中的檢查點 (checkpoints)

**檢查點**是系統定期建立的一個點，在這個點上，所有已修改的緩衝區頁面被強制寫入磁盤。檢查點可以縮短系統恢復時間。

在SQLite的WAL模式下：

```sql
-- 手動觸發檢查點
PRAGMA wal_checkpoint;
```

### 11.2.2 交易的排程

**交易排程**是指多個交易的操作在時間上的安排順序。排程決定了交易間的交錯執行方式。

**可序列化(Serializable)排程**：多個交易的並行執行結果與某種序列執行的結果相同，這種排程是正確的。

考慮兩個交易：
- T1：從A轉賬到B
- T2：計算A和B的總餘額

可能的排程：

1. **序列排程**：先完成T1，再執行T2
2. **並行排程**：T1和T2操作交錯執行

### 11.2.3 SQL 對於交易觀念的支援

SQLite提供了以下關鍵字來支援交易：

1. **BEGIN TRANSACTION**：開始一個交易
2. **COMMIT**：提交交易
3. **ROLLBACK**：復原交易
4. **SAVEPOINT**：在交易中創建保存點
5. **RELEASE**：釋放保存點
6. **ROLLBACK TO**：復原到指定保存點

```sql
-- 使用保存點示例
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
    
    SAVEPOINT sp1;
        UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';
        -- 假設這裡發現B的賬號有問題
        ROLLBACK TO sp1;  -- 只復原B的操作
    
    -- 改為更新C的賬戶
    UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'C';
COMMIT;
```

## 11.3 並行控制 (concurrency control)

### 11.3.1 資料鎖定 (locking)

**鎖定**是最常用的並行控制機制，通過對資料加鎖來防止同時修改。

主要的鎖類型：
- **共享鎖(Shared Lock)**：允許多個交易同時讀取，但阻止寫入
- **排他鎖(Exclusive Lock)**：允許持有鎖的交易讀取和寫入，但阻止其他交易訪問

SQLite中實現：

```sql
-- 開始交易並立即獲取排他鎖
BEGIN IMMEDIATE TRANSACTION;

-- 或者開始交易並等待獲取排他鎖
BEGIN EXCLUSIVE TRANSACTION;
```

**兩階段鎖定協議(Two-Phase Locking)**：
1. **獲取階段**：交易只獲取鎖，不釋放
2. **釋放階段**：交易只釋放鎖，不獲取

### 11.3.2 時間戳記 (timestamp)

**時間戳記**方法為每個交易分配一個唯一的時間戳，並用它來確定交易的執行順序。

基本規則：
- 如果交易T1要讀取被T2最後修改的資料項，且T1的時間戳早於T2，則T1必須重新啟動並獲得新的時間戳
- 如果交易T1要修改被T2最後讀取或修改的資料項，且T1的時間戳早於T2，則T1必須重新啟動並獲得新的時間戳

SQLite本身不直接支援時間戳記方法，但可以通過應用層實現。

### 11.3.3 多版並行控制 (multiversion concurrency control)

**多版並行控制(MVCC)**通過保留資料的多個版本來實現並行控制，每個交易看到的是一個一致性快照。

SQLite的WAL模式部分實現了MVCC的理念：

```sql
-- 啟用WAL模式
PRAGMA journal_mode = WAL;
```

在WAL模式下：
- 寫入操作不直接修改原始資料庫檔案，而是寫入日誌
- 讀取操作可以看到交易開始時的資料庫狀態，不受並發寫入影響

### 11.3.4 與並行控制相關的一些問題

#### 死鎖(Deadlock)

**死鎖**發生在兩個或多個交易互相等待對方釋放資源的情況。

SQLite處理死鎖的方式是設置超時機制：

```sql
-- 設置鎖等待超時（毫秒）
PRAGMA busy_timeout = 5000;
```

當超時發生時，SQLite會拋出"database is locked"錯誤。

#### 隔離級別

SQL標準定義了四種隔離級別：
1. **讀未提交(Read Uncommitted)**
2. **讀已提交(Read Committed)**
3. **可重複讀(Repeatable Read)**
4. **可序列化(Serializable)**

SQLite僅支援可序列化隔離級別，這是最嚴格的級別，可以防止所有並發問題。

## 11.4 分散式資料庫系統中的交易與並行處理

分散式資料庫中的交易涉及多個節點上的資料操作，需要特殊的協議來確保一致性。

### 兩階段提交協議(Two-Phase Commit)

**兩階段提交**是分散式交易常用的協議，包括：

1. **準備階段**：協調者要求所有參與者準備提交交易
2. **提交階段**：如果所有參與者都準備好，協調者發出提交指令

SQLite主要用於嵌入式應用，不直接支援分散式交易，但可以通過應用層實現。

### SQLite在分散式環境中的應用

雖然SQLite本身不是分散式數據庫，但可以在以下分散式場景使用：

1. **應用層分片**：在應用層將資料分散到多個SQLite資料庫
2. **主從複製**：一個主SQLite資料庫和多個從資料庫
3. **同步機制**：使用外部同步方案，如文件同步或專用協議

```sql
-- 示例：應用層處理分散式交易
-- 假設我們有兩個SQLite資料庫：db1和db2

-- 在db1上執行
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
-- 記錄交易狀態
INSERT INTO TransactionLog VALUES ('TX001', 'PREPARE', datetime('now'));
COMMIT;

-- 在db2上執行
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';
-- 記錄交易狀態
INSERT INTO TransactionLog VALUES ('TX001', 'PREPARE', datetime('now'));
COMMIT;

-- 應用層確認兩個資料庫都準備好後，執行最終提交
-- 在db1上執行
BEGIN TRANSACTION;
UPDATE TransactionLog SET Status = 'COMMIT' WHERE TransactionID = 'TX001';
COMMIT;

-- 在db2上執行
BEGIN TRANSACTION;
UPDATE TransactionLog SET Status = 'COMMIT' WHERE TransactionID = 'TX001';
COMMIT;
```

# 第12章：資料庫復原機制

## 12.1 復原 (recovery) 的基本觀念

資料庫復原是指在系統故障、軟體錯誤或硬體錯誤後，將資料庫恢復到某個一致性狀態的過程。復原機制是確保資料庫持久性和一致性的關鍵。

### 故障類型

1. **交易故障**：單個交易因邏輯錯誤、死鎖等無法正常完成
2. **系統故障**：整個資料庫系統崩潰，如電源故障、軟體錯誤
3. **媒體故障**：儲存媒體損壞導致資料丟失

### SQLite中的復原機制

SQLite透過日誌檔案實現復原機制：

```sql
-- 查看當前的日誌模式
PRAGMA journal_mode;

-- 設置為DELETE模式（默認模式）
PRAGMA journal_mode = DELETE;

-- 設置為WAL模式（寫入前日誌）
PRAGMA journal_mode = WAL;
```

各種日誌模式的特點：
- **DELETE**：交易期間創建臨時日誌，提交後刪除
- **TRUNCATE**：與DELETE類似，但通過截斷而非刪除日誌檔案
- **PERSIST**：保留日誌檔案但標記為無效
- **WAL**：使用預寫日誌，提高並發性能

### 12.1.1 復原演算法的分類

#### 延遲更新 (deferred update) 的復原作業

**延遲更新**策略將所有實際的資料庫修改延遲到交易確認提交後才執行。

**特點**：
- 交易執行期間，所有更新先記錄在日誌中
- 只有在交易確認提交後，才將更新寫入實際資料庫
- 如果交易失敗，只需放棄日誌中的更新，無需復原實際資料庫

**SQLite中的應用**：
WAL（Write-Ahead Logging）模式部分實現了延遲更新思想：

```sql
-- 啟用WAL模式
PRAGMA journal_mode = WAL;

-- 示例交易
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';
COMMIT;
```

在WAL模式下，更新操作首先寫入WAL檔案，然後在交易提交後，系統才將更改合併到主資料庫檔案。

#### 立即更新 (immediate update) 的復原作業

**立即更新**策略在交易執行期間即時將更新寫入資料庫，同時在日誌中記錄更新前後的值。

**特點**：
- 交易執行期間，更新即時反映在資料庫中
- 日誌中記錄「重做(redo)」和「復原(undo)」信息
- 如果交易失敗，需要使用日誌中的信息來復原更改

**SQLite中的應用**：
DELETE、TRUNCATE和PERSIST日誌模式使用立即更新策略：

```sql
-- 使用DELETE模式
PRAGMA journal_mode = DELETE;

-- 示例交易
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';
COMMIT;
```

在這些模式下，SQLite在修改資料庫頁面前，先將原始頁面複製到日誌檔案，以便在需要復原時恢復。

### 12.1.2 從系統處理的觀點來看復原的作業

從系統處理角度看，復原過程涉及以下幾個關鍵部分：

1. **日誌記錄**：系統維護一個日誌，記錄所有交易操作
2. **檢查點處理**：定期將內存中的更改刷新到磁盤
3. **故障檢測**：系統能夠檢測到各種故障
4. **復原程序**：在故障後執行的恢復操作

#### SQLite中的復原過程

當SQLite資料庫因系統崩潰而未正常關閉時，在下次開啟時會自動執行以下復原步驟：

1. **檢查日誌檔案**：系統檢查是否存在日誌檔案
2. **分析日誌內容**：確定哪些交易已提交，哪些未提交
3. **重做(Redo)已提交交易**：對於已提交但可能未寫入磁盤的交易進行重做
4. **撤銷(Undo)未提交交易**：復原未提交交易的影響

```sql
-- 手動強制檢查點（在WAL模式下）
PRAGMA wal_checkpoint(FULL);
```

SQLite的WAL模式下的檢查點操作會將WAL檔案中的內容合併到主資料庫檔案中，減少日誌的大小並提高後續操作的效率。

### 12.1.3 交易的復原 (rollback)

**交易復原**是指取消交易中已執行的全部或部分操作，將資料庫恢復到這些操作執行前的狀態。

#### 復原的原因

1. **顯式復原**：應用程序顯式請求復原交易
2. **錯誤復原**：因錯誤或約束違反導致的自動復原
3. **死鎖解決**：系統選擇某個交易作為死鎖的受害者進行復原

#### SQLite中的復原機制

```sql
-- 完全復原交易
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
-- 假設這裡發生了錯誤
ROLLBACK;  -- 復原整個交易

-- 部分復原使用保存點
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A';
    
    SAVEPOINT transfer_point;
        UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'B';
        -- 假設B賬戶操作需要復原
        ROLLBACK TO transfer_point;  -- 只復原到保存點
    
    -- 繼續其他操作
    UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'C';
COMMIT;
```

#### 復原的實現方式

SQLite根據日誌模式的不同，採用不同的復原實現方式：

1. **在DELETE/TRUNCATE/PERSIST模式中**：
   - 使用日誌檔案中保存的原始頁面副本恢復被修改的頁面

2. **在WAL模式中**：
   - 只需放棄WAL檔案中未提交的條目，不需要修改主資料庫檔案

### 復原機制的效能考量

1. **日誌模式選擇**：
   - DELETE模式：標準模式，適用於大多數應用
   - WAL模式：提供更好的並發性和更快的寫入速度

2. **檢查點頻率**：
   - 頻繁的檢查點提高故障恢復速度但降低日常操作效能
   - 較少的檢查點提高日常操作效能但延長故障恢復時間

3. **同步模式設置**：
```sql
-- 查看當前同步模式
PRAGMA synchronous;

-- 完全同步（最安全，但最慢）
PRAGMA synchronous = FULL;

-- 普通同步（平衡安全性和速度）
PRAGMA synchronous = NORMAL;

-- 關閉同步（最快，但最不安全）
PRAGMA synchronous = OFF;
```

### 總結

在資料庫系統中，復原機制是確保交易的ACID特性中的持久性和一致性的關鍵部分。SQLite提供了多種日誌模式和復原機制，可以根據應用需求在安全性和效能間取得平衡。了解交易處理、並行控制和復原機制的基本概念，對於設計和實現可靠的資料庫應用至關重要。
