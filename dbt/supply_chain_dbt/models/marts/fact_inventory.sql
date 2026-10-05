{{ config(materialized='table')}}
with inventory as (
    select * from {{ ref('stg_inventory')}}
),
metrics as (
    select * from {{ ref('int_inventory_metrics')}}
),
final as (
    select

        /* =====================================================
           KEYS
           ===================================================== */

        i.inventory_id,

        i.product_id,

        i.warehouse_id,


        /* =====================================================
           INVENTORY DATE
           ===================================================== */

        i.inventory_date,


        /* =====================================================
           STOCK QUANTITIES
           ===================================================== */

        i.quantity_on_hand,

        i.reserved_quantity,

        i.available_quantity,

        i.reorder_level,

        i.unit_cost,

        i.inventory_value,


        /* =====================================================
           RESTOCK INFORMATION
           ===================================================== */

        i.last_restock_date,


        /* =====================================================
           INVENTORY STATUS
           ===================================================== */

        i.inventory_status,

        case
            when upper(trim(i.inventory_status))='HEALTHY'
                then 'Healthy'
            when upper(trim(i.inventory_status))='lOW STOCK'
                THEN 'Low Stock'
            when upper(trim(i.inventory_status)) = 'OUT OF STOCK'
                THEN 'Out of Stock'
            when upper(trim(i.inventory_status)) = 'OVERSTOCK'
                then 'Overstock'

            when upper(trim(i.inventory_status)) = 'RESERVED'
                then 'Reserved'

            else 'Unknown'
        end as inventory_status_group,

        i.stock_condition,
        case

            when upper(trim(i.stock_condition)) = 'GOOD'
                then 'Good'

            when upper(trim(i.stock_condition)) = 'DAMAGED'
                then 'Damaged'

            when upper(trim(i.stock_condition)) = 'EXPIRED'
                then 'Expired'

            when upper(trim(i.stock_condition)) = 'UNDER INSPECTION'
                then 'Under Inspection'

            else 'Unknown'

        end as stock_condition_group,
        --                /* =====================================================
        --           STOCK FLAGS
        --           ===================================================== */

        case

            when coalesce(i.quantity_on_hand,0) = 0
                then 1

            else 0

        end as is_out_of_stock,


        case

            when i.quantity_on_hand is not null
             and i.reorder_level is not null
             and i.quantity_on_hand < i.reorder_level

                then 1

            else 0

        end as is_below_reorder_level,


        case

            when i.quantity_on_hand is not null
             and i.reorder_level is not null
             and i.quantity_on_hand > i.reorder_level * 5

                then 1

            else 0

        end as is_overstock,


        case

            when i.reserved_quantity is not null
             and i.quantity_on_hand is not null
             and i.reserved_quantity > 0

                then 1

            else 0

        end as has_reserved_stock,

        -- available stock check

        case
            when i.quantity_on_hand is not null and i.reserved_quantity is not null
            and i.available_quantity is not null and i.available_quantity =
            i.quantity_on_hand - i.reserved_quantity
            then 1
            else 0
        end as is_stock_balance_correct,
        -- stock utilization
        case
            when i.quantity_on_hand > 0 then
            round(
                (i.reserved_quantity/i.quantity_on_hand)* 100,2
            ) else 0
        end as reserved_stock_percentage,

        -- available stock percentage
        case
            when i.quantity_on_hand > 0 then
                round(
                    (i.available_quantity/ i.quantity_on_hand)* 100,2
                )
                else 0
        end as available_stock_percentage,
        -- INVENTORY VALUE CLASSIFICATION
        case

            when i.inventory_value is null
                then 'Unknown'

            when i.inventory_value < 10000
                then 'Low Value'

            when i.inventory_value < 100000
                then 'Medium Value'

            when i.inventory_value < 1000000
                then 'High Value'

            else 'Very High Value'

        end as inventory_value_category,

        -- stock quantity classification
        case

            when i.quantity_on_hand is null
                then 'Unknown'

            when i.quantity_on_hand = 0
                then 'No Stock'

            when i.quantity_on_hand <= 100
                then 'Low Stock'

            when i.quantity_on_hand <= 1000
                then 'Medium Stock'

            when i.quantity_on_hand <= 5000
                then 'High Stock'

            else 'Very High Stock'

        end as stock_quantity_category,
        -- reorder gap
        case
            when i.reorder_level is not null
            and i.quantity_on_hand is not null
            and i.quantity_on_hand < i.reorder_level
            then i.reorder_level - i.quantity_on_hand
            else 0
        end as reorder_gap_quantity,

        -- days since restock
        case
            when i.last_restock_date is not null
            and i.inventory_date is not null
            then datediff(
            'day',i.last_restock_date,i.inventory_date
            )
            else null
        end as days_since_restock,

        -- restock age category

        case
            when i.last_restock_date is null
                then 'Unknown'
            when datediff(
            'day',i.last_restock_date,
            i.inventory_date
            ) <= 30
            then 'Recent Restock'

            when datediff(
            'day',i.last_restock_date,i.inventory_date
            )<= 90
            then 'Moderate Age'

            when datediff(
            'day',i.last_restock_date,i.inventory_date
            )<= 180

            then 'Old Stock'
            else 'Very Old Stock'
        end as restock_age_category,

        -- stock risk
                case

            when i.quantity_on_hand = 0

                then 'Critical'

            when i.quantity_on_hand < i.reorder_level

                then 'High'

            when i.quantity_on_hand <= i.reorder_level * 2

                then 'Medium'

            when i.quantity_on_hand > i.reorder_level * 5

                then 'High Overstock Risk'

            else 'Low'

        end as inventory_risk_category,

        -- condition risk category
                case

            when upper(trim(i.stock_condition)) = 'DAMAGED'
                then 'High Risk'

            when upper(trim(i.stock_condition)) = 'EXPIRED'
                then 'Critical Risk'

            when upper(trim(i.stock_condition)) = 'UNDER INSPECTION'
                then 'Medium Risk'

            when upper(trim(i.stock_condition)) = 'GOOD'
                then 'Low Risk'

            else 'Unknown'

        end as condition_risk_category,

        -- date information
        extract(year from i.inventory_date) as inventory_year,
        extract(month from i.inventory_date) as inventory_month,
        extract(quarter from i.inventory_date) as inventory_quarter,

        -- intermediate metrucs

    from inventory i
    left join metrics m
    on i.inventory_id = m.inventory_id

)

select * from final
