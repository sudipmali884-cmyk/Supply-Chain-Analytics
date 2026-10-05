# Supply Chain Analytics

An end-to-end Supply Chain Analytics project built using Python, Snowflake, dbt, SQL, and Power BI.

## 🚀 Project Architecture

Python

↓

Raw Data

↓

Snowflake RAW

↓

dbt STAGING

↓

dbt INTERMEDIATE

↓

dbt MARTS

↓

Power BI

## 🛠️ Technologies Used

- Python
- Pandas
- SQL
- Snowflake
- dbt
- Power BI

- Git
- GitHub

## 📊 Supply Chain Data

The project contains data related to:

- Orders
- Products
- Inventory
- Warehouses
- Shipments
- Deliveries
- Suppliers
- Procurement

## 🏗️ dbt Data Models

### STAGING

- stg_deliveries
- stg_inventory
- stg_orders
- stg_products
- stg_shipments
- stg_suppliers
- stg_warehouses

### INTERMEDIATE

- int_delivery_metrics
- int_inventory_analysis
- int_inventory_metrics
- int_order_fulfillment
- int_order_metrics
- int_shipment_metrics

### MARTS - Dimensions

- dim_orders
- dim_products
- dim_suppliers
- dim_warehouses

### MARTS - Facts

- fact_deliveries
- fact_inventory
- fact_order_fulfillment
- fact_orders
- fact_shipments

## 🔄 Data Transformation

The data follows a layered architecture:

### RAW

Raw supply chain data is loaded into Snowflake without major transformations.

### STAGING

Data cleaning and standardization are performed.

### INTERMEDIATE

Business logic and analytical calculations are applied through intermediate models.

### MARTS

Dimensional and fact models are created for Power BI analytics.

## 📈 Power BI Dashboard

The Power BI dashboard contains:

1. Executive Supply Chain Dashboard
2. Inventory & Warehouse Analytics
3. Order & Fulfillment Analytics
4. Shipment & Delivery Performance
5. Supplier Performance & Procurement

### Key KPIs

- Total Orders
- Total Order Amount
- Average Order Value
- Delivered Orders
- Cancelled Orders
- Total Inventory Value
- Available Stock
- Out of Stock
- Supplier Count
- Supplier Rating
- Supplier Risk
- Lead Time
- On-Time Delivery
- Shipment Performance


## 🧹 Data Quality

The project includes realistic data-quality scenarios such as:

- Duplicate records
- NULL values
- Blank values
- Invalid values
- Incorrect formatting
- Data validation

dbt models and tests are used to improve data quality and reliability.

## 🎯 Key Learning Outcomes

Through this project, I practiced:

- ETL/ELT pipeline development
- Data warehouse architecture
- Snowflake data loading
- SQL transformations
- dbt modeling
- Staging, Intermediate, and Mart layers
- Dimensional modeling
- Data quality testing
- Python data generation
- Power BI dashboard development
- DAX
- Git and GitHub

