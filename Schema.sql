DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Toppings;
DROP TABLE IF EXISTS Dim_Vending_Machines;
DROP TABLE IF EXISTS Dim_Products;

-- 1. สร้างตารางข้อมูลสินค้า (Master Data)
CREATE TABLE Dim_Products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- เช่น Caffeine, Juice, Soft Drink
    price DECIMAL(10, 2) NOT NULL,
    menu_type VARCHAR(20) -- เช่น Hot, Cold
);

-- 2. สร้างตารางข้อมูลตู้และทำเลที่ตั้ง
CREATE TABLE Dim_Vending_Machines (
    machine_id VARCHAR(10) PRIMARY KEY,
    location_zone VARCHAR(100) NOT NULL, -- เช่น Emergency Room, OPD, Walkway
    is_low_light BOOLEAN NOT NULL, -- True = มุมมืด / False = สว่างปกติ
    has_led_strip BOOLEAN NOT NULL -- True = ติดไฟแล้ว / False = ยังไม่ติด
);

-- 2b. (ทางเลือก) ตารางท็อปปิ้ง ถ้าต้องการเก็บรายละเอียดท็อปปิ้ง
CREATE TABLE Dim_Toppings (
    topping_id VARCHAR(10) PRIMARY KEY,
    topping_name VARCHAR(100) NOT NULL,
    extra_price DECIMAL(10,2) DEFAULT 0.00
);

-- 3. สร้างตารางข้อมูลธุรกรรมการขาย (Fact Table)
CREATE TABLE Fact_Sales (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY, -- ระบบจะรันไอดีอัตโนมัติ (MySQL)
    machine_id VARCHAR(10),
    product_id VARCHAR(10),
    topping_id VARCHAR(10) NULL, -- เก็บไว้เผื่อมีท็อปปิ้งเพิ่มเติม
    sale_timestamp DATETIME NOT NULL, -- วันและเวลาที่กดน้ำ
    quantity INT NOT NULL,
    FOREIGN KEY (machine_id) REFERENCES Dim_Vending_Machines(machine_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Products(product_id),
    FOREIGN KEY (topping_id) REFERENCES Dim_Toppings(topping_id)
);

-- =============================================
-- 1. เพิ่มข้อมูลสินค้าจำลอง (Dim_Products)
-- =============================================
INSERT INTO Dim_Products (product_id, product_name, category, price, menu_type) VALUES
('P001', 'Espresso เย็น', 'Caffeine', 50.00, 'Cold'),
('P002', 'อเมริกาโน่ร้อน', 'Caffeine', 40.00, 'Hot'),
('P003', 'ชาเขียวนมเย็น', 'Soft Drink', 45.00, 'Cold'),
('P004', 'น้ำส้มคั้น 100%', 'Juice', 35.00, 'Cold'),
('P005', 'นมสดร้อน', 'Soft Drink', 30.00, 'Hot');

-- =============================================
-- 2. เพิ่มข้อมูลท็อปปิ้งจำลอง (Dim_Toppings)
-- =============================================
INSERT INTO Dim_Toppings (topping_id, topping_name, extra_price) VALUES
('T01', 'เพิ่มช็อตกาแฟ', 15.00),
('T02', 'บุกไข่มุก', 10.00),
('T03', 'ไม่เพิ่มท็อปปิ้ง', 0.00);

-- =============================================
-- 3. เพิ่มข้อมูลตู้กดน้ำจำลอง (Dim_Vending_Machines)
-- =============================================
-- เปรียบเทียบตู้ M001 (มุมมืด-ยังไม่ติดไฟ) กับ ตู้ M002 (มุมมืด-ติดไฟแล้ว)
INSERT INTO Dim_Vending_Machines (machine_id, location_zone, is_low_light, has_led_strip) VALUES
('M001', 'ทางเชื่อมอาคารเก่า (มุมมืด)', TRUE, FALSE), -- ตู้มืดสนิท
('M002', 'หน้าแผนกผู้ป่วยนอก (มุมมืด-ทดลองติดไฟ)', TRUE, TRUE), -- ตู้ที่ติดไฟ LED
('M003', 'โถงกลางอาคาร 1 (สว่างปกติ)', FALSE, FALSE);

-- =============================================
-- 4. เพิ่มข้อมูลประวัติการขายจำลอง (Fact_Sales)
-- =============================================
-- จำลองสถานการณ์ช่วงกะดึก (23.00 - 05.00 น.) ของวันที่ 23 พฤษภาคม
INSERT INTO Fact_Sales (machine_id, product_id, topping_id, sale_timestamp, quantity) VALUES
-- ช่วงดึก ตู้ M001 (มืดๆ) คนไม่ค่อยเดินมากด ได้แค่ 2 แก้ว
('M001', 'P001', 'T03', '2026-05-23 01:15:00', 1),
('M001', 'P002', 'T01', '2026-05-23 03:40:00', 1),

-- ช่วงดึก ตู้ M002 (มุมมืดแต่ติดไฟ LED ) คนเดินมาเห็นชัด กดรัวๆ โดยเฉพาะเมนูกาแฟ
('M002', 'P001', 'T01', '2026-05-23 00:30:00', 1), -- กาแฟเบิ้ลช็อต
('M002', 'P001', 'T03', '2026-05-23 01:45:00', 2),
('M002', 'P002', 'T03', '2026-05-23 02:20:00', 1),
('M002', 'P005', 'T03', '2026-05-23 03:10:00', 1), -- นมร้อนแก้หนาวตอนดึก
('M002', 'P001', 'T01', '2026-05-23 04:15:00', 1),

-- ช่วงกลางวัน ตู้ M003 (โซนสว่างปกติ) ขายน้ำส้ม น้ำชาเขียวดี
('M003', 'P003', 'T02', '2026-05-23 11:30:00', 1),
('M003', 'P004', 'T03', '2026-05-23 13:15:00', 2);
