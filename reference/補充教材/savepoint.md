# 假設我們正在開發一個電子商務網站的訂單處理功能。

**情境：** 用戶下單購買多個商品。這個訂單處理事務可能包含以下步驟：

1.  檢查庫存是否足夠。
2.  從用戶的購物車中獲取商品資訊。
3.  **設置保存點 `AFTER_CHECKOUT_INFO`。**
4.  計算訂單總金額。
5.  更新商品的庫存數量。
6.  **設置保存點 `AFTER_INVENTORY_UPDATE`。**
7.  創建訂單記錄。
8.  創建訂單明細記錄。
9.  從用戶的帳戶餘額中扣款。
10. **設置保存點 `BEFORE_PAYMENT`。**
11. 發送訂單確認郵件。

在這個事務中，我們設置了幾個保存點：

* **`AFTER_CHECKOUT_INFO`：** 在獲取購物車資訊後設置。
* **`AFTER_INVENTORY_UPDATE`：** 在更新庫存後設置。
* **`BEFORE_PAYMENT`：** 在嘗試從用戶帳戶扣款之前設置。

**現在，讓我們考慮幾種可能發生的錯誤情況以及如何使用保存點來處理：**

**錯誤情境一：庫存不足**

假設在步驟 1 檢查庫存時發現某個商品庫存不足，無法完成訂單。這時，我們可以直接 `ROLLBACK` 整個事務，因為還沒有進行任何實際的資料變更。

**錯誤情境二：更新庫存後創建訂單記錄失敗**

假設在步驟 5 成功更新了商品的庫存，但在步驟 7 創建訂單記錄時由於某些原因（例如資料庫連線問題）失敗了。這時，我們可以使用 `ROLLBACK TO SAVEPOINT AFTER_INVENTORY_UPDATE` 命令。這樣做的好處是：

* **只會撤銷步驟 7 和步驟 8 的操作（創建訂單記錄和訂單明細記錄）。**
* **步驟 5 的庫存更新仍然保留，避免了需要重新計算和更新庫存的麻煩。**
* 我們可以記錄錯誤，稍後重試創建訂單記錄，而不需要重新執行整個訂單處理流程。

**錯誤情境三：扣款失敗**

假設在步驟 9 嘗試從用戶帳戶扣款時，由於用戶餘額不足或其他支付問題而失敗。這時，我們可以使用 `ROLLBACK TO SAVEPOINT BEFORE_PAYMENT` 命令。這樣做的好處是：

* **只會撤銷步驟 9 和步驟 10 的操作（扣款和後續的保存點）。**
* **步驟 1 到步驟 8 的操作（檢查庫存、獲取商品資訊、計算總金額、更新庫存、創建訂單記錄和訂單明細記錄）仍然保留。**
* 我們可以通知用戶付款失敗，並引導他們完成支付流程，而不需要重新創建訂單。

**總結這個範例，SAVEPOINT 的作用在於：**

* **提供更細粒度的錯誤恢復機制。**
* **避免在部分操作成功後，由於後續步驟失敗而需要撤銷所有操作的情況。**
* **提高了事務的彈性和效率，特別是在處理複雜且包含多個獨立邏輯步驟的事務時。**

透過使用 SAVEPOINT，我們可以更精確地控制事務的回滾範圍，從而提升資料庫操作的可靠性和用戶體驗。