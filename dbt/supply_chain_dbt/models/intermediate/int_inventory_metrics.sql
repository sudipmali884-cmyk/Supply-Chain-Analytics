{{ config(
    materialized='table'
) }}

with inventory as (

    select

        inventory_id,
        product_id,
        warehouse_id,

        inventory_date,

        quantity_on_hand,
        reserved_quantity,
        available_quantity,

        reorder_level,

        unit_cost,
        inventory_value,

        last_restock_date,

        inventory_status,
        stock_condition

    from {{ ref('stg_inventory') }}

),
metrics as (

    select

        -- ====================================================
        -- IDENTIFICATION
        -- ====================================================

        inventory_id,

        product_id,

        warehouse_id,

        inventory_date,


        -- ====================================================
        -- STOCK QUANTITIES
        -- ====================================================

        quantity_on_hand,

        reserved_quantity,

        available_quantity,

        reorder_level,


        -- ====================================================
        -- COST / VALUE
        -- ====================================================

        unit_cost,

        inventory_value,


        -- ====================================================
        -- DATES
        -- ====================================================

        last_restock_date,


        -- ====================================================
        -- STATUS
        -- ====================================================

        inventory_status,

        stock_condition,

        -- ====================================================
        -- RESERVED STOCK PERCENTAGE
        -- ====================================================

        case

            when quantity_on_hand is not null
             and quantity_on_hand > 0
             and reserved_quantity is not null

            then round(
                (
                    reserved_quantity
                    / quantity_on_hand
                ) * 100,
                2
            )

            else 0

        end as reserved_percentage,
        -- ====================================================
        -- AVAILABLE STOCK PERCENTAGE
        -- ====================================================

        case

            when quantity_on_hand is not null
             and quantity_on_hand > 0
             and available_quantity is not null

            then round(
                (
                    available_quantity
                    / quantity_on_hand
                ) * 100,
                2
            )

            else 0

        end as available_percentage,

                -- ====================================================
        -- STOCK GAP
        --
        -- How many units are below reorder level?
        -- ====================================================

        case

            when reorder_level is not null
             and available_quantity is not null
             and available_quantity < reorder_level

            then reorder_level - available_quantity

            else 0

        end as reorder_gap_quantity,

                -- ====================================================
        -- DAYS SINCE LAST RESTOCK
        -- ====================================================

        case

            when last_restock_date is not null
             and inventory_date is not null

            then datediff(
                'day',
                last_restock_date,
                inventory_date
            )

            else null

        end as days_since_last_restock,

                -- ====================================================
        -- OUT OF STOCK FLAG
        -- ====================================================

        case

            when available_quantity = 0

            then 1

            else 0

        end as is_out_of_stock,

        case
            when available_quantity > 0
            and reorder_level is not null
            and available_quantity < reorder_level
            then 1
            else 0
        end as is_low_stock,


        case
            when available_quantity is not null
            and reorder_level is not null
            and available_quantity <= reorder_level
            then 1
            else 0
        end as is_reorder_required,

        case
            when available_quantity is not null
            and reorder_level is not null
            and available_quantity > reorder_level * 5
            then 1
            else 0
        end as is_overstock,

        case
            when reserved_quantity is not null
            and reserved_quantity > 0
            then 1
            else 0
        end as has_reserved_stock,

        case
            when upper(trim(stock_condition)) = 'DAMAGED'
            then 1
            else 0
        end as is_damaged_stock,

        case
            when upper(trim(stock_condition))='EXPIRED'
            THEN 1
            ELSE 0
        END AS IS_EXPIRED_STOCK,

                -- ====================================================
        -- STOCK CONDITION CATEGORY
        -- ====================================================

        case

            when upper(trim(stock_condition)) = 'GOOD'
                then 'Good Stock'

            when upper(trim(stock_condition)) = 'DAMAGED'
                then 'Damaged Stock'

            when upper(trim(stock_condition)) = 'EXPIRED'
                then 'Expired Stock'

            when upper(trim(stock_condition)) = 'UNDER INSPECTION'
                then 'Inspection Required'

            else 'Unknown'

        end as stock_condition_category,

                -- ====================================================
        -- INVENTORY HEALTH
        -- ====================================================

        case

            when available_quantity = 0
                then 'Critical'

            when reorder_level is not null
             and available_quantity < reorder_level
                then 'At Risk'

            when available_quantity is not null
             and reorder_level is not null
             and available_quantity > reorder_level * 5
                then 'Overstocked'

            when upper(trim(stock_condition)) in (
                'DAMAGED',
                'EXPIRED'
            )
                then 'Quality Risk'

            else 'Healthy'

        end as inventory_health,


        -- ====================================================
        -- STOCK LEVEL CATEGORY
        -- ====================================================

        case

            when available_quantity = 0
                then 'Out of Stock'

            when reorder_level is not null
             and available_quantity < reorder_level
                then 'Low Stock'

            when reorder_level is not null
             and available_quantity <= reorder_level * 2
                then 'Normal Stock'

            when reorder_level is not null
             and available_quantity <= reorder_level * 5
                then 'High Stock'

            when reorder_level is not null
             and available_quantity > reorder_level * 5
                then 'Overstock'

            else 'Unknown'

        end as stock_level_category,


        -- ====================================================
        -- INVENTORY VALUE BAND
        -- ====================================================

        case

            when inventory_value is null
                then 'Unknown'

            when inventory_value < 10000
                then 'Low Value'

            when inventory_value < 100000
                then 'Medium Value'

            when inventory_value < 500000
                then 'High Value'

            else 'Very High Value'

        end as inventory_value_band,


        -- ====================================================
        -- UNIT COST BAND
        -- ====================================================

        case

            when unit_cost is null
                then 'Unknown'

            when unit_cost < 1000
                then 'Low Cost'

            when unit_cost < 10000
                then 'Medium Cost'

            when unit_cost < 50000
                then 'High Cost'

            else 'Very High Cost'

        end as unit_cost_band,


        -- ====================================================
        -- INVENTORY RISK
        -- ====================================================

        case

            when available_quantity = 0
                then 'Critical Risk'

            when upper(trim(stock_condition)) = 'EXPIRED'
                then 'Critical Risk'

            when upper(trim(stock_condition)) = 'DAMAGED'
                then 'High Risk'

            when reorder_level is not null
             and available_quantity < reorder_level
                then 'High Risk'

            when reorder_level is not null
             and available_quantity > reorder_level * 5
                then 'Medium Risk'

            else 'Low Risk'

        end as inventory_risk


    from inventory

)


-- ============================================================
-- FINAL RESULT
-- ============================================================

select *

from metrics








