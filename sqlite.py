import sqlite3
import datetime

class ProductManager:
    def __init__(self, db_name='products.db'):
        """
        初始化資料庫連線並建立產品表格
        """
        self.conn = sqlite3.connect(db_name)
        self.cursor = self.conn.cursor()
        self.create_table()

    def create_table(self):
        """
        建立產品資料表
        """
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price DECIMAL(10, 2) NOT NULL,
            category TEXT,
            stock INTEGER DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        ''')
        self.conn.commit()

    def add_product(self, name, price, category, stock):
        """
        新增產品
        """
        try:
            self.cursor.execute('''
            INSERT INTO products (name, price, category, stock) 
            VALUES (?, ?, ?, ?)
            ''', (name, price, category, stock))
            self.conn.commit()
            return self.cursor.lastrowid
        except sqlite3.Error as e:
            print(f"新增產品時發生錯誤: {e}")
            return None

    def get_product_by_id(self, product_id):
        """
        根據 ID 查詢產品
        """
        self.cursor.execute('SELECT * FROM products WHERE id = ?', (product_id,))
        return self.cursor.fetchone()

    def get_products_by_category(self, category):
        """
        根據類別查詢產品
        """
        self.cursor.execute('SELECT * FROM products WHERE category = ?', (category,))
        return self.cursor.fetchall()

    def update_product(self, product_id, name=None, price=None, category=None, stock=None):
        """
        更新產品資訊
        """
        update_fields = []
        params = []

        if name:
            update_fields.append('name = ?')
            params.append(name)
        if price is not None:
            update_fields.append('price = ?')
            params.append(price)
        if category:
            update_fields.append('category = ?')
            params.append(category)
        if stock is not None:
            update_fields.append('stock = ?')
            params.append(stock)

        params.append(product_id)

        if update_fields:
            query = f'UPDATE products SET {", ".join(update_fields)} WHERE id = ?'
            try:
                self.cursor.execute(query, params)
                self.conn.commit()
                return self.cursor.rowcount
            except sqlite3.Error as e:
                print(f"更新產品時發生錯誤: {e}")
                return None

    def delete_product(self, product_id):
        """
        刪除產品
        """
        try:
            self.cursor.execute('DELETE FROM products WHERE id = ?', (product_id,))
            self.conn.commit()
            return self.cursor.rowcount
        except sqlite3.Error as e:
            print(f"刪除產品時發生錯誤: {e}")
            return None

    def list_all_products(self):
        """
        列出所有產品
        """
        self.cursor.execute('SELECT * FROM products')
        return self.cursor.fetchall()

    def close_connection(self):
        """
        關閉資料庫連線
        """
        self.conn.close()

def main():
    # 創建產品管理器
    pm = ProductManager()

    # 新增產品
    apple_id = pm.add_product('Apple', 5.50, 'Fruit', 100)
    banana_id = pm.add_product('Banana', 3.25, 'Fruit', 150)
    laptop_id = pm.add_product('Laptop', 1000.00, 'Electronics', 10)

    # 查詢產品
    print("依 ID 查詢產品:")
    print(pm.get_product_by_id(apple_id))

    print("\n水果類產品:")
    fruits = pm.get_products_by_category('Fruit')
    for fruit in fruits:
        print(fruit)

    # 更新產品
    pm.update_product(banana_id, price=4.00, stock=200)

    # 列出所有產品
    print("\n所有產品:")
    for product in pm.list_all_products():
        print(product)

    # 關閉連線
    pm.close_connection()

if __name__ == '__main__':
    main()