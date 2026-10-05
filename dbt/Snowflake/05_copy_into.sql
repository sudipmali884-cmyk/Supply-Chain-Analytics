-- =============================================
-- COPY INTO
-- =============================================

USE DATABASE supply_db;

USE SCHEMA raw;

-- Products
copy into products from @supply_stage/products_master.csv file_format=(format_name='csv_format');

-- Suppliers
copy into suppliers from @supply_stage/suppliers.csv file_format=(format_name='csv_format');

-- Warehouses
copy into warehouses from @supply_stage/warehouses.csv file_format=(format_name='csv_format');

-- Inventory
copy into inventory from @supply_stage/inventory.csv file_format=(format_name='csv_format');

-- Shipments
COPY INTO SHIPMENTS
FROM @SUPPLY_STAGE/shipments.csv
FILE_FORMAT = (
    FORMAT_NAME = RAW.CSV_FORMAT
);


-- Deliveries

COPY INTO DELIVERIES
FROM @SUPPLY_STAGE/deliveries.csv
FILE_FORMAT = (
    FORMAT_NAME = RAW.CSV_FORMAT
);


-- Orders

COPY INTO ORDERS
FROM @SUPPLY_STAGE/orders.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
);
