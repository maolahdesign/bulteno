-- 創建 customers 表格
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT
);

-- 插入 5 個客戶
INSERT INTO customers VALUES
    (1, 'Alice'),
    (2, 'Bob'),
    (3, 'Charlie'),
    (4, 'David'),
    (5, 'Eve');

-- 創建 products 表格
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL
);

-- 插入 6 個商品
INSERT INTO products VALUES
    (1, 'Laptop', 1000.00),
    (2, 'Mouse', 20.00),
    (3, 'Keyboard', 50.00),
    (4, 'Monitor', 200.00),
    (5, 'Headphones', 80.00),
    (6, 'USB Drive', 15.00);
    
-- 創建 orders 表格（單一外鍵）
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 插入 10 筆訂單紀錄
INSERT INTO orders VALUES
    (1, 1, '2023-10-01'),  -- Alice
    (2, 2, '2023-10-02'),  -- Bob
    (3, 3, '2023-10-03'),  -- Charlie
    (4, 4, '2023-10-04'),  -- David
    (5, 5, '2023-10-05'),  -- Eve
    (6, 1, '2023-10-06'),  -- Alice
    (7, 2, '2023-10-07'),  -- Bob
    (8, 3, '2023-10-08'),  -- Charlie
    (9, 4, '2023-10-09'),  -- David
    (10, 5, '2023-10-10'); -- Eve

-- 創建 order_items 表格（複合外鍵）
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 插入 10 筆訂單的商品紀錄，每筆訂單商品數量不同
INSERT INTO order_items VALUES
    -- 訂單 1: 3 項商品
    (1, 1, 1),  -- Laptop x1
    (1, 2, 2),  -- Mouse x2
    (1, 3, 1),  -- Keyboard x1
    -- 訂單 2: 2 項商品
    (2, 4, 1),  -- Monitor x1
    (2, 5, 3),  -- Headphones x3
    -- 訂單 3: 1 項商品
    (3, 6, 5),  -- USB Drive x5
    -- 訂單 4: 4 項商品
    (4, 1, 1),  -- Laptop x1
    (4, 2, 1),  -- Mouse x1
    (4, 3, 2),  -- Keyboard x2
    (4, 4, 1),  -- Monitor x1
    -- 訂單 5: 2 項商品
    (5, 5, 1),  -- Headphones x1
    (5, 6, 10), -- USB Drive x10
    -- 訂單 6: 3 項商品
    (6, 2, 4),  -- Mouse x4
    (6, 3, 1),  -- Keyboard x1
    (6, 5, 2),  -- Headphones x2
    -- 訂單 7: 1 項商品
    (7, 1, 2),  -- Laptop x2
    -- 訂單 8: 2 項商品
    (8, 4, 1),  -- Monitor x1
    (8, 6, 3),  -- USB Drive x3
    -- 訂單 9: 3 項商品
    (9, 2, 5),  -- Mouse x5
    (9, 3, 1),  -- Keyboard x1
    (9, 5, 1),  -- Headphones x1
    -- 訂單 10: 4 項商品
    (10, 1, 1), -- Laptop x1
    (10, 4, 2), -- Monitor x2
    (10, 5, 1), -- Headphones x1
    (10, 6, 2); -- USB Drive x2

-- 查詢所有訂單
SELECT * FROM orders;

-- 查詢某訂單的商品
SELECT o.order_id, p.name, oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = 4;