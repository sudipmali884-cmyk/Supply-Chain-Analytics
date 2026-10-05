--This model combines:
--
--stg_inventory
--      │
--      ├── product_id ──→ stg_products
--      │
--      └── warehouse_id → stg_warehouses
--
--The purpose is to create a clean inventory-analysis dataset that the MART layer can directly use.

with inventory as(
    select * from {{ ref('stg_inventory')}}
),
products as (
    select * from {{ ref('stg_products')}}
),
warehouses as (
    select * from {{ ref('stg_warehouses')}}
),
joined_data as (
    select
         /* =====================================================
           INVENTORY
           ===================================================== */

        i.inventory_id,
        i.product_id,
        i.warehouse_id,
        i.inventory_date,

        i.quantity_on_hand,
        i.reserved_quantity,
        i.available_quantity,
        i.reorder_level,
        i.unit_cost,
        i.inventory_value,

        i.last_restock_date,
        i.inventory_status,
        i.stock_condition,

        /* =====================================================
           PRODUCT
           ===================================================== */

        p.product_name,
        p.category,
        p.sub_category,
        p.brand,
        p.selling_price,
        p.unit_of_measure,
        p.product_status,

        /* =====================================================
           WAREHOUSE
           ===================================================== */

        w.warehouse_name,
        w.warehouse_type,
        w.storage_type,
        w.country AS warehouse_country,
        w.state AS warehouse_state,
        w.city AS warehouse_city,
        w.capacity_units,
        w.warehouse_status
    from inventory i left join products p
    on i.product_id=p.product_id
    left join warehouses w
        on i.warehouse_id = w.warehouse_id
),

final as (
    select * ,
    case
        when quantity_on_hand is not null
        and quantity_on_hand > 0
        then round(
            reserved_quantity / quantity_on_hand * 100,2
        )else 0

    end as reserved_percentage,
    case
        when capacity_units is not null
        and capacity_units > 0
        then round (
            quantity_on_hand / capacity_units * 100,2
        ) else 0
    end as warehouse_capacity_utilization,

    case
        when reorder_level is not null
        and quantity_on_hand is not null
        then quantity_on_hand - reorder_level
        else null
    end as   stock_gap,

    case
        when quantity_on_hand=0
        then 'OUT_OF_STOCK'

        WHEN quantity_on_hand < reorder_level then 'low_stock'
        when quantity_on_hand > reorder_level * 5
        then 'overstock'
        else 'Healthy'

    end as stock_health,

    -- inventory age

    case
        when last_restock_date is not null
        then DATEDIFF(
            'day',
            last_restock_date,
            current_date()
        )
        else null
    end as days_since_restock,

    -- product margin

    case
        when selling_price is not null
        and unit_cost is not null
        and selling_price > 0
        then round(
            selling_price - unit_cost,2
        ) else null
    end as unit_margin_profit,

    case
        when selling_price is not null
        and unit_cost is not null
        and selling_price > 0
        then round(
            (
                (selling_price - unit_cost) / selling_price
            ) * 100 , 2
        )else null

    end as margin_percentage

from joined_data
)
select  * from final