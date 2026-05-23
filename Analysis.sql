-- =============================================
-- 1. วิเคราะห์ผลกระทบของ LED ในตู้มุมมืด (UNION ALL)
-- =============================================
SELECT 
    CASE WHEN m.has_led_strip = TRUE THEN 'ติดไฟ LED' ELSE 'ไม่มีไฟ LED' END AS 'สถานะ LED',
    COUNT(DISTINCT m.machine_id) AS 'จำนวนตู้',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE m.is_low_light = TRUE
GROUP BY m.has_led_strip

UNION ALL

SELECT
    'รวมทั้งหมด' AS 'สถานะ LED',
    COUNT(DISTINCT m.machine_id) AS 'จำนวนตู้',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE m.is_low_light = TRUE;

-- =============================================
-- 2. ยอดขายตามประเภทเครื่องดื่มในช่วงดึก (23:00 - 05:00 น.)
-- =============================================
SELECT 
    p.category AS 'ประเภทเครื่องดื่ม',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้ในช่วงดึก',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายช่วงดึก (บาท)'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE HOUR(s.sale_timestamp) >= 23 OR HOUR(s.sale_timestamp) < 5
GROUP BY p.category
ORDER BY SUM(s.quantity * (p.price + t.extra_price)) DESC;
