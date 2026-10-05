with inventory as(
    select * from {{ source('raw','inventory')}}
),
cleaned_data as(
    select
        case
            when regexp_like(trim(inventory_id),'^INV[0-9]{7}$')
            then trim(inventory_id)
            else null
        end as inventory_id,

        case
            when regexp_like(trim(product_id),'^PRD[0-9]{6}$')
            then trim(product_id)
            else null
        end as product_id,

        case
            when regexp_like(trim(warehouse_id),'WH[0-9]{6}$')
            then trim(warehouse_id)
            else null
        end as warehouse_id,

        inventory_date,

        case
            when quantity_on_hand is null then null
            when quantity_on_hand < 0 then null
            when quantity_on_hand > 5000 then null
            else quantity_on_hand
        end as quantity_on_hand,

        reserved_quantity,

        available_quantity,

        reorder_level,

        unit_cost,

        case
            when quantity_on_hand is null then null
            when unit_cost is null then null

            when quantity_on_hand < 0 then null
            when unit_cost <= 0 then null

            else try_to_number(quantity_on_hand)
            *
            try_to_decimal(unit_cost)
        end as inventory_value,

        case
            when (last_restock_date) is null
            then null
            else (last_restock_date)
        end as last_restock_date,

        case
            when inventory_status is null then null
            when upper(trim(inventory_status)) in (
                'HEALTHY',
                    'LOW STOCK',
                    'OUT OF STOCK',
                    'OVERSTOCK',
                    'RESERVED'
            )
            then initcap(trim(inventory_status))
            else null
        end as inventory_status,

        CASE
            WHEN stock_condition IS NULL THEN NULL
            WHEN TRIM(stock_condition) = '' THEN NULL
            ELSE INITCAP(TRIM(stock_condition))
        END AS stock_condition
    from inventory

),
deduplicated as(
    select * from cleaned_data
       qualify row_number() over(
       partition by inventory_id
        order by inventory_id desc
       )=1
)

select * from deduplicated