DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Toppings;
DROP TABLE IF EXISTS Dim_Vending_Machines;
DROP TABLE IF EXISTS Dim_Products;

-- =============================================
-- 1. สร้างตารางข้อมูลสินค้า (Dimension: Products)
-- วัตถุประสงค์: เก็บข้อมูลสินค้า ราคา และประเภท
-- =============================================
CREATE TABLE Dim_Products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL COMMENT 'เช่น Caffeine, Juice, Soft Drink',
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    menu_type VARCHAR(20) NOT NULL COMMENT 'เช่น Hot, Cold',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- 2. สร้างตารางข้อมูลตู้กดน้ำและทำเลที่ตั้ง (Dimension: Vending Machines)
-- วัตถุประสงค์: จดบันทึกข้อมูลตู้ สถานที่ และความสว่าง (เพื่อทดลองใช้ LED)
-- =============================================
CREATE TABLE Dim_Vending_Machines (
    machine_id VARCHAR(10) PRIMARY KEY,
    location_zone VARCHAR(100) NOT NULL COMMENT 'เช่น Emergency Room, OPD, Walkway',
    is_low_light BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'True = มุมมืด / False = สว่างปกติ',
    has_led_strip BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'True = ติดไฟ LED แล้ว / False = ยังไม่ติด',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- 3. สร้างตารางท็อปปิ้ง (Dimension: Toppings)
-- วัตถุประสงค์: เก็บรายละเอียดท็อปปิ้งและราคาเพิ่มเติม
-- =============================================
CREATE TABLE Dim_Toppings (
    topping_id VARCHAR(10) PRIMARY KEY,
    topping_name VARCHAR(100) NOT NULL,
    extra_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (extra_price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- 4. สร้างตารางธุรกรรมการขาย (Fact Table)
-- วัตถุประสงค์: บันทึกทุกการกดน้ำ (sales transaction) พร้อมข้อมูลเวลา สินค้า และราคา
-- =============================================
CREATE TABLE Fact_Sales (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'รหัสธุรกรรม (ระบบอัตโนมัติ)',
    machine_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    topping_id VARCHAR(10) NOT NULL DEFAULT 'T03' COMMENT 'T03 = ไม่เพิ่มท็อปปิ้ง',
    sale_timestamp DATETIME NOT NULL COMMENT 'วันและเวลาที่กดน้ำ',
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    product_price DECIMAL(10, 2) NOT NULL COMMENT 'ราคาสินค้า (ณ เวลาซื้อ)',
    topping_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'ราคาท็อปปิ้ง',
    total_price DECIMAL(10, 2) NOT NULL GENERATED ALWAYS AS (product_price + topping_price) * quantity STORED COMMENT 'ราคารวม',
    status VARCHAR(20) NOT NULL DEFAULT 'completed' COMMENT 'completed, refunded, error',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (machine_id) REFERENCES Dim_Vending_Machines(machine_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Dim_Products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (topping_id) REFERENCES Dim_Toppings(topping_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================
-- สร้าง Indexes สำหรับ Performance
-- =============================================
CREATE INDEX idx_sales_machine ON Fact_Sales(machine_id);
CREATE INDEX idx_sales_product ON Fact_Sales(product_id);
CREATE INDEX idx_sales_topping ON Fact_Sales(topping_id);
CREATE INDEX idx_sales_timestamp ON Fact_Sales(sale_timestamp);
CREATE INDEX idx_sales_status ON Fact_Sales(status);
CREATE INDEX idx_products_category ON Dim_Products(category);
CREATE INDEX idx_machines_location ON Dim_Vending_Machines(location_zone);

-- =============================================
-- เพิ่มข้อมูลสินค้า (Dim_Products)
-- =============================================
INSERT INTO Dim_Products (product_id, product_name, category, price, menu_type) VALUES
('P001', 'Espresso เย็น', 'Caffeine', 50.00, 'Cold'),
('P002', 'อเมริกาโน่ร้อน', 'Caffeine', 40.00, 'Hot'),
('P003', 'ชาเขียวนมเย็น', 'Soft Drink', 45.00, 'Cold'),
('P004', 'น้ำส้มคั้น 100%', 'Juice', 35.00, 'Cold'),
('P005', 'นมสดร้อน', 'Soft Drink', 30.00, 'Hot');

-- =============================================
-- เพิ่มข้อมูลท็อปปิ้ง (Dim_Toppings)
-- =============================================
INSERT INTO Dim_Toppings (topping_id, topping_name, extra_price) VALUES
('T01', 'เพิ่มช็อตกาแฟ', 15.00),
('T02', 'บุกไข่มุก', 10.00),
('T03', 'ไม่เพิ่มท็อปปิ้ง', 0.00);

-- =============================================
-- เพิ่มข้อมูลตู้กดน้ำ (Dim_Vending_Machines)
-- =============================================
-- จุดประสงค์: เปรียบเทียบ
--   - M001: มุมมืดสนิท (ไม่มีไฟ LED) = ควรขายน้อยลง
--   - M002: มุมมืดแต่ติดไฟ LED = ควรขายเพิ่มขึ้น
--   - M003: สว่างปกติ = ควรเป็น baseline
INSERT INTO Dim_Vending_Machines (machine_id, location_zone, is_low_light, has_led_strip) VALUES
('M001', 'ทางเชื่อมอาคารเก่า (มุมมืด)', TRUE, FALSE),
('M002', 'หน้าแผนกผู้ป่วยนอก (มุมมืด-ทดลองติดไฟ LED)', TRUE, TRUE),
('M003', 'โถงกลางอาคาร 1 (สว่างปกติ)', FALSE, FALSE);

-- =============================================
-- เพิ่มข้อมูลการขาย (Fact_Sales)
-- =============================================
-- จำลองสถานการณ์ช่วงกะดึก (23.00 - 05.00 น.) ของวันที่ 23 พฤษภาคม 2026
-- กลุ่ม 1: ตู้ M001 (มืดสนิท) - ขายน้อย
INSERT INTO Fact_Sales (machine_id, product_id, topping_id, sale_timestamp, quantity, product_price, topping_price, status) VALUES
('M001', 'P001', 'T03', '2026-05-23 01:15:00', 1, 50.00, 0.00, 'completed'),
('M001', 'P002', 'T01', '2026-05-23 03:40:00', 1, 40.00, 15.00, 'completed');

-- กลุ่ม 2: ตู้ M002 (มืด+LED) - ขายดี
INSERT INTO Fact_Sales (machine_id, product_id, topping_id, sale_timestamp, quantity, product_price, topping_price, status) VALUES
('M002', 'P001', 'T01', '2026-05-23 00:30:00', 1, 50.00, 15.00, 'completed'),
('M002', 'P001', 'T03', '2026-05-23 01:45:00', 2, 50.00, 0.00, 'completed'),
('M002', 'P002', 'T03', '2026-05-23 02:20:00', 1, 40.00, 0.00, 'completed'),
('M002', 'P005', 'T03', '2026-05-23 03:10:00', 1, 30.00, 0.00, 'completed'),
('M002', 'P001', 'T01', '2026-05-23 04:15:00', 1, 50.00, 15.00, 'completed');

-- กลุ่ม 3: ตู้ M003 (สว่างปกติ) - ขายดี
INSERT INTO Fact_Sales (machine_id, product_id, topping_id, sale_timestamp, quantity, product_price, topping_price, status) VALUES
('M003', 'P003', 'T02', '2026-05-23 11:30:00', 1, 45.00, 10.00, 'completed'),
('M003', 'P004', 'T03', '2026-05-23 13:15:00', 2, 35.00, 0.00, 'completed');
