-- ============================================================
-- 1. Products
-- ============================================================

CREATE OR REPLACE TABLE PRODUCTS
(
    product_id STRING,
    product_name STRING,
    category STRING,
    sub_category STRING,
    brand STRING,
    unit_cost NUMBER,
    selling_price NUMBER,
    reorder_level NUMBER,
    unit_of_measure STRING,
    product_status STRING
);

-- ============================================================
-- 2. SUPPLIERS
-- ============================================================

CREATE OR REPLACE TABLE SUPPLIERS
(
    supplier_id STRING,
    supplier_name STRING,
    supplier_type STRING,
    contact_person STRING,
    email STRING,
    phone STRING,
    country STRING,
    state STRING,
    city STRING,
    payment_terms STRING,
    lead_time_days NUMBER,
    supplier_rating NUMBER,
    supplier_status STRING
);


-- ============================================================
-- 3. WAREHOUSES
-- ============================================================

CREATE OR REPLACE TABLE WAREHOUSES
(
    warehouse_id STRING,
    warehouse_name STRING,
    warehouse_type STRING,
    storage_type STRING,
    country STRING,
    state STRING,
    city STRING,
    postal_code STRING,
    capacity_units NUMBER,
    phone STRING,
    warehouse_status STRING
);


-- ============================================================
-- 4. ORDERS
-- ============================================================

CREATE OR REPLACE TABLE ORDERS
(
    order_id STRING,
    product_id STRING,
    supplier_id STRING,
    order_date DATE,
    quantity NUMBER,
    unit_price NUMBER,
    order_amount NUMBER,
    currency STRING,
    payment_method STRING,
    expected_delivery_date DATE,
    order_status STRING
);



-- ============================================================
-- 5. INVENTORY
-- ============================================================

CREATE OR REPLACE TABLE INVENTORY
(
    inventory_id STRING,
    product_id STRING,
    warehouse_id STRING,
    inventory_date DATE,
    quantity_on_hand NUMBER,
    reserved_quantity NUMBER,
    available_quantity NUMBER,
    reorder_level NUMBER,
    unit_cost NUMBER,
    inventory_value STRING,
    last_restock_date DATE,
    inventory_status STRING,
    stock_condition STRING
  
);


-- ============================================================
-- 6. SHIPMENTS
-- ============================================================

CREATE OR REPLACE TABLE SHIPMENTS
(
    shipment_id STRING,
    order_id STRING,
    carrier STRING,
    shipping_method STRING,
    tracking_number STRING,
    shipment_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost STRING,
    shipment_status STRING
);


-- ============================================================
-- 7. DELIVERIES
-- ============================================================

CREATE OR REPLACE TABLE DELIVERIES
(
    delivery_id STRING,
    shipment_id STRING,
    delivery_partner STRING,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    delay_days NUMBER,
    delivery_attempts NUMBER,
    delivery_city STRING,
    recipient_name STRING,
    recipient_phone STRING,
    delivery_status STRING
);
