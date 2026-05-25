-- =============================================
-- SQL Analysis Queries for Vending Machine Sales
-- วิเคราะห์การขายของตู้กดน้ำในโรงพยาบาล
-- =============================================

-- =============================================
-- 1. วิเคราะห์ผลกระทบของ LED ในตู้มุมมืด (UNION ALL)
-- Purpose: เปรียบเทียบยอดขายระหว่างตู้มุมมืดที่มีไฟ LED กับไม่มี
-- =============================================
SELECT 
    CASE WHEN m.has_led_strip = TRUE THEN 'ติดไฟ LED' ELSE 'ไม่มีไฟ LED' END AS 'สถานะ LED',
    COUNT(DISTINCT m.machine_id) AS 'จำนวนตู้',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)',
    ROUND(AVG(s.quantity), 2) AS 'เฉลี่ยแก้วต่อครั้ง'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE m.is_low_light = TRUE
GROUP BY m.has_led_strip

UNION ALL

SELECT
    'รวมทั้งหมด (มุมมืด)' AS 'สถานะ LED',
    COUNT(DISTINCT m.machine_id) AS 'จำนวนตู้',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)',
    ROUND(AVG(s.quantity), 2) AS 'เฉลี่ยแก้วต่อครั้ง'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE m.is_low_light = TRUE;

-- =============================================
-- 2. ยอดขายตามประเภทเครื่องดื่มในช่วงดึก (23:00 - 05:00 น.)
-- Purpose: วิเคราะห์ความนิยมของประเภทเครื่องดื่มในช่วงกลางคืน
-- =============================================
SELECT 
    p.category AS 'ประเภทเครื่องดื่ม',
    SUM(s.quantity) AS 'จำนวนแก้วที่ขายได้ในช่วงดึก',
    COUNT(s.transaction_id) AS 'จำนวนธุรกรรม',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายช่วงดึก (บาท)',
    ROUND(SUM(s.quantity * (p.price + t.extra_price)) / COUNT(s.transaction_id), 2) AS 'ค่าเฉลี่ยต่อธุรกรรม (บาท)'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
WHERE HOUR(s.sale_timestamp) >= 23 OR HOUR(s.sale_timestamp) < 5
GROUP BY p.category
ORDER BY SUM(s.quantity * (p.price + t.extra_price)) DESC;

-- =============================================
-- 3. ยอดขายตามสถานที่ตั้งตู้ (Location Analysis)
-- Purpose: เปรียบเทียบประสิทธิภาพการขายของแต่ละสถานที่
-- =============================================
SELECT 
    m.machine_id AS 'รหัสตู้',
    m.location_zone AS 'สถานที่ตั้ง',
    CASE WHEN m.is_low_light = TRUE THEN 'มุมมืด' ELSE 'สว่าง' END AS 'ความสว่าง',
    CASE WHEN m.has_led_strip = TRUE THEN 'มี' ELSE 'ไม่มี' END AS 'ไฟ LED',
    COUNT(DISTINCT s.transaction_id) AS 'จำนวนธุรกรรม',
    SUM(s.quantity) AS 'จำนวนแก้วทั้งหมด',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)',
    ROUND(SUM(s.quantity * (p.price + t.extra_price)) / COUNT(DISTINCT s.transaction_id), 2) AS 'เฉลี่ยต่อธุรกรรม (บาท)'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY m.machine_id, m.location_zone, m.is_low_light, m.has_led_strip
ORDER BY SUM(s.quantity * (p.price + t.extra_price)) DESC;

-- =============================================
-- 4. ความนิยมของสินค้า (Product Performance)
-- Purpose: ระบุสินค้าที่ขายดีที่สุด
-- =============================================
SELECT 
    p.product_id AS 'รหัสสินค้า',
    p.product_name AS 'ชื่อสินค้า',
    p.category AS 'ประเภท',
    p.menu_type AS 'ประเภทการบริการ (Hot/Cold)',
    SUM(s.quantity) AS 'จำนวนแก้วขายได้',
    COUNT(DISTINCT s.transaction_id) AS 'จำนวนครั้งที่ขาย',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)',
    ROUND(SUM(s.quantity * (p.price + t.extra_price)) / SUM(s.quantity), 2) AS 'ราคาเฉลี่ยต่อแก้ว (บาท)'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY p.product_id, p.product_name, p.category, p.menu_type
ORDER BY SUM(s.quantity * (p.price + t.extra_price)) DESC;

-- =============================================
-- 5. ความนิยมของท็อปปิ้ง (Topping Analysis)
-- Purpose: วิเคราะห์อัตราการซื้อท็อปปิ้งเพิ่มเติม
-- =============================================
SELECT 
    t.topping_id AS 'รหัสท็อปปิ้ง',
    t.topping_name AS 'ชื่อท็อปปิ้ง',
    COUNT(s.transaction_id) AS 'จำนวนครั้งที่สั่ง',
    SUM(s.quantity) AS 'จำนวนแก้ว',
    SUM(t.extra_price * s.quantity) AS 'ยอดขายท็อปปิ้ง (บาท)',
    ROUND(COUNT(s.transaction_id) / (SELECT COUNT(*) FROM Fact_Sales) * 100, 2) AS 'สัดส่วนผู้สั่ง (%)'
FROM Fact_Sales s
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY t.topping_id, t.topping_name
ORDER BY COUNT(s.transaction_id) DESC;

-- =============================================
-- 6. วิเคราะห์แบบ Hourly Distribution ของการขาย
-- Purpose: ดูรูปแบบการขายตามเวลา
-- =============================================
SELECT 
    HOUR(s.sale_timestamp) AS 'ชั่วโมง',
    COUNT(s.transaction_id) AS 'จำนวนธุรกรรม',
    SUM(s.quantity) AS 'จำนวนแก้ว',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขาย (บาท)',
    CASE 
        WHEN HOUR(s.sale_timestamp) >= 23 OR HOUR(s.sale_timestamp) < 5 THEN 'กลางคืน (23:00-05:00)'
        WHEN HOUR(s.sale_timestamp) >= 5 AND HOUR(s.sale_timestamp) < 12 THEN 'เช้า (05:00-12:00)'
        WHEN HOUR(s.sale_timestamp) >= 12 AND HOUR(s.sale_timestamp) < 17 THEN 'บ่าย (12:00-17:00)'
        ELSE 'เย็น (17:00-23:00)'
    END AS 'ช่วงเวลา'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY HOUR(s.sale_timestamp)
ORDER BY HOUR(s.sale_timestamp);

-- =============================================
-- 7. สรุปยอดขายทั้งหมด (Summary Statistics)
-- Purpose: ดูภาพรวมของการขายทั้งหมด
-- =============================================
SELECT 
    COUNT(DISTINCT s.transaction_id) AS 'จำนวนธุรกรรมทั้งหมด',
    COUNT(DISTINCT s.machine_id) AS 'จำนวนตู้ที่ใช้งาน',
    COUNT(DISTINCT s.product_id) AS 'จำนวนประเภทสินค้า',
    SUM(s.quantity) AS 'จำนวนแก้วขายได้ทั้งหมด',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขายรวม (บาท)',
    ROUND(AVG(s.quantity * (p.price + t.extra_price)), 2) AS 'ค่าเฉลี่ยต่อธุรกรรม (บาท)',
    ROUND(SUM(s.quantity * (p.price + t.extra_price)) / COUNT(DISTINCT s.machine_id), 2) AS 'เฉลี่ยต่อตู้ (บาท)',
    MIN(s.sale_timestamp) AS 'วันที่เริ่มต้น',
    MAX(s.sale_timestamp) AS 'วันที่สิ้นสุด'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id;

-- =============================================
-- 8. วิเคราะห์ Cross-Analysis: LED ต่อ Location
-- Purpose: ดูผลกระทบของ LED ในแต่ละสถานที่
-- =============================================
SELECT 
    m.location_zone AS 'สถานที่ตั้ง',
    CASE WHEN m.has_led_strip = TRUE THEN 'ติดไฟ LED' ELSE 'ไม่มีไฟ LED' END AS 'สถานะ LED',
    COUNT(DISTINCT m.machine_id) AS 'จำนวนตู้',
    SUM(s.quantity) AS 'จำนวนแก้ว',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขาย (บาท)',
    ROUND(SUM(s.quantity * (p.price + t.extra_price)) / COUNT(DISTINCT m.machine_id), 2) AS 'เฉลี่ยต่อตู้ (บาท)'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY m.location_zone, m.has_led_strip
ORDER BY m.location_zone, m.has_led_strip;

-- =============================================
-- 9. ยอดขายตามสถานะของธุรกรรม (Status Analysis)
-- Purpose: ตรวจสอบจำนวนธุรกรรมที่ถูกต้องและสภาวะผิดปกติ
-- =============================================
SELECT 
    s.status AS 'สถานะ',
    COUNT(s.transaction_id) AS 'จำนวนธุรกรรม',
    SUM(s.quantity) AS 'จำนวนแก้ว',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขาย (บาท)',
    ROUND(COUNT(s.transaction_id) / (SELECT COUNT(*) FROM Fact_Sales) * 100, 2) AS 'สัดส่วน (%)'
FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY s.status;

-- =============================================
-- 10. ยอดขายโดยเทียบเคียงแต่ละตู้ (Detailed Machine Comparison)
-- Purpose: ดูรายละเอียดการขายของแต่ละตู้พร้อมสินค้า
-- =============================================
SELECT 
    m.machine_id AS 'รหัสตู้',
    m.location_zone AS 'สถานที่',
    p.product_name AS 'สินค้า',
    SUM(s.quantity) AS 'จำนวนแก้ว',
    SUM(s.quantity * (p.price + t.extra_price)) AS 'ยอดขาย (บาท)',
    COUNT(s.transaction_id) AS 'จำนวนครั้งที่ขาย'
FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
JOIN Dim_Toppings t ON s.topping_id = t.topping_id
GROUP BY m.machine_id, m.location_zone, p.product_name
ORDER BY m.machine_id, SUM(s.quantity * (p.price + t.extra_price)) DESC;
