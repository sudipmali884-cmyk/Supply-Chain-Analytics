-- step 1 - create warehouse

create warehouse supply_wh with
warehouse_size='XSMALL'
auto_suspend=60
auto_resume=TRUE;

use warehouse supply_wh;
-- step 2 - create DATABASE
create database supply_db;

use database supply_db;

-- step 3 create schema 
create schema raw;
create schema staging;
create schema mart;

