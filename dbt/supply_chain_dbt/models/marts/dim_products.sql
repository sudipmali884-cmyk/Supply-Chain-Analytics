--MART 1 — dim_products.sql
--
--This will become your main Product Dimension for Power BI.
--
--Flow
--RAW.PRODUCTS
--      ↓
--stg_products
--      ↓
--dim_products
--      ↓
--Power BI
--
--We will keep the dimension clean and add a few useful business attributes
with products as (
    select * from {{ ref('stg_products')}}
),
product_analysis as (

    select
        product_id,

        product_name,

        category,

        sub_category,

        brand,


        -- ====================================================
        -- PRODUCT STATUS
        -- ====================================================

        product_status,


        -- ====================================================
        -- UNIT INFORMATION
        -- ====================================================

        unit_of_measure,

        reorder_level,


        -- ====================================================
        -- COST & SELLING PRICE
        -- ====================================================

        unit_cost,

        selling_price,

        case
            when unit_cost is not null
            and selling_price is not null
            then round(
            selling_price- unit_cost,2
            ) else null
        end as unit_profit,

        case
            when selling_price > 0
            and unit_cost is not null
            then round(
                (
                   ( selling_price - unit_cost)
                / selling_price
            )* 100, 2)
            else null
        end as profit_margin_percentage,


        case
            when unit_cost > 0
            and selling_price is not null
            then round(
            (
                (selling_price - unit_cost)/unit_cost
            )*100,2
            )
        end as markup_percentage,

        case
            when selling_price is null
                then 'Unknown'
            when selling_price <= 1000
                then 'Budget'
            when selling_price <=5000
                then 'Mid Range'
            when selling_price <= 20000
                then 'Premium'
            else 'Luxury'
        end as price_category,
        case

            when unit_cost is null
             or selling_price is null

                then 'Unknown'

            when selling_price <= unit_cost

                then 'Loss / No Margin'

            when (
                (selling_price - unit_cost)
                / selling_price
            ) * 100 < 10

                then 'Low Margin'

            when (
                (selling_price - unit_cost)
                / selling_price
            ) * 100 < 25

                then 'Medium Margin'

            when (
                (selling_price - unit_cost)
                / selling_price
            ) * 100 < 40

                then 'High Margin'

            else 'Very High Margin'

        end as profitability_category,

        case
                when reorder_level is null
                 then 'Unknown'
                when reorder_level = 0
                 then 'No Reorder Level'
                when reorder_level < 100
                 then 'Low Reorder Level'
                when reorder_level < 500
                 then 'Medium Reorder Level'
                else 'High Reorder Level'
        end as reorder_level_category,

        case
            when upper(trim(product_status))='ACTIVE'
                then 'Active Product'
            when upper(trim(product_status))='INACTIVE'
                then 'Inactive Product'
            when upper(trim(product_status))='Discontinued'
                THEN  'Discontinued Product'
            when upper(trim(product_status)) = 'OUT OF STOCK'

                then 'Out of Stock Product'

            else 'Unknown'

        end as product_lifecycle_category,
        -- ====================================================
        -- PRODUCT VALUE CATEGORY
        -- ====================================================

        case

            when unit_cost is null
                then 'Unknown'

            when unit_cost <= 500
                then 'Low Value'

            when unit_cost <= 5000
                then 'Medium Value'

            when unit_cost <= 25000
                then 'High Value'

            else 'Very High Value'

        end as product_value_category,
        -- ====================================================
        -- PRICING POSITION
        --
        -- Compares selling price against cost.
        -- ====================================================

        case

            when selling_price is null
             or unit_cost is null

                then 'Unknown'

            when selling_price < unit_cost

                then 'Below Cost'

            when selling_price = unit_cost

                then 'Same Price Selling & Cost'

            when selling_price < unit_cost * 1.25

                then 'Low Markup'

            when selling_price < unit_cost * 1.50

                then 'Standard Markup'

            when selling_price < unit_cost * 2

                then 'High Markup'

            else 'Very High Markup'

        end as pricing_position,

        -- ====================================================
        -- PRODUCT QUALITY FLAG
        --
        -- Used to identify suspicious product records.
        -- ====================================================

        case

            when product_id is null
                then 'Invalid Product ID'

            when product_name is null
                then 'Missing Product Name'

            when category is null
                then 'Missing Category'

            when sub_category is null
                then 'Missing Sub Category'

            when unit_cost is null
                then 'Missing Cost'

            when selling_price is null
                then 'Missing Selling Price'

            when selling_price <= 0
                then 'Selling Price is Less Then 0'

            when unit_cost <= 0
                then 'Invalid Unit Cost'

            when selling_price < unit_cost
                then 'Selling Below Cost'

            else 'Valid Product'

        end as product_quality_flag

    from products

)
select * from product_analysis
--
--{#{ config(
--    materialized='table'
--) }#}
--
--with products as (
--    select * from {{ ref('stg_products')}}
--),
--
--final as (
--    select
--        product_id,
--        product_name,
--        category,
--        sub_category,
--        brand,
--        unit_of_measure,
--        unit_cost,
--        selling_price,
--
--        case
--            when selling_price is not null
--            and unit_cost is not null
--            then round(
--                selling_price - unit_cost,2
--            )
--            else null
--            end as unit_margin,
--
--            case
--                when selling_price is not null
--                and selling_price > 0
--                and unit_cost is not null
--                then round(
--                    (
--                        (selling_price- unit_cost)/selling_price
--                    )* 100,2
--                )
--                else null
--            end as margin_percentage,
--
--            reorder_level,
--            case
--                when reorder_level is null
--                 then 'Unknown'
--                when reorder_level = 0
--                 then 'No Reorder Level'
--                when reorder_level < 100
--                 then 'Low'
--                when reorder_level < 500
--                 then 'Medium'
--                else 'High'
--            end as reorder_level_category,
--
--            product_status,
--
--            case
--                when upper(trim(product_status))='ACTIVE'
--                    then 1
--                else 0
--            end as is_active
--        from products
--
--)
--select * from final