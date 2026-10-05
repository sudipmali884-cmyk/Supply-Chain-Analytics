{{ config(
    materialized='table'
) }}
with fulfillment as (
    select * from {{ ref('int_order_fulfillment')}}
),
order_metrics as (
     select

        -- ====================================================
        -- ORDER IDENTIFICATION
        -- ====================================================

        order_id,
        product_id,
        supplier_id,

        order_date,
        order_expected_delivery_date,

        quantity,
        unit_price,
        order_amount,

        currency,
        payment_method,
        order_status,

        -- ====================================================
        -- SHIPMENT INFORMATION
        -- ====================================================

        shipment_id,
        shipment_date,
        shipment_status,

        carrier,
        shipping_method,

        -- ====================================================
        -- DELIVERY INFORMATION
        -- ====================================================

        delivery_id,
        delivery_partner,
        delivery_expected_delivery_date,
        delivery_actual_delivery_date,
        delivery_status,

        delivery_attempts,

        -- ====================================================
        -- FULFILLMENT METRICS
        -- ====================================================

        days_to_ship,

        transit_days,

        order_to_delivery_days,

        calculated_delay_days,

        -- ====================================================
        -- FULFILLMENT FLAGS
        -- ====================================================

        is_shipped,

        is_delivered,

        is_delayed,

        is_on_time,

        is_cancelled,

        -- ====================================================
        -- BUSINESS CLASSIFICATIONS
        -- ====================================================

        delivery_attempt_category,

        order_value_band,

        order_quantity_band,

        case
            when upper(trim(order_status)) = 'PENDING'
            then 1
            else 0
        end as is_pending,

         case
            when upper(trim(order_status)) = 'CONFIRMED'
            then 1
            else 0
        end as is_confirmed,


        case
            when upper(trim(order_status)) = 'PROCESSING'
            then 1
            else 0
        end as is_processing,


        case
            when upper(trim(order_status)) = 'SHIPPED'
            then 1
            else 0
        end as is_order_shipped,


        case
            when upper(trim(order_status)) = 'DELIVERED'
            then 1
            else 0
        end as is_order_delivered,

        CASE
            WHEN quantity >= 200
            then 1
            else 0
        end as is_bulk_order,

        case
            when quantity >= 100
            then 1
            else 0
        end as is_large_quantity_order,

        -- ====================================================
        -- HIGH VALUE ORDER
        -- ====================================================

        case
            when order_amount >= 200000
            then 1
            else 0
        end as is_high_value_order,

        -- delivery performance
        case
            when delivery_status ='Delivered' and is_on_time =1
             then 'On Time'
            when delivery_status ='Delivered' and is_on_time = 0
            then 'Late Delivered'
            when delivery_status='Delayed'
            then 'Delayed'
            when delivery_status='Pending'
            then 'Pending'
            when delivery_status = 'Returned'
            then 'Returned'
            when delivery_status = 'Failed'

            then 'Failed'

            else 'Unknown'

        end as delivery_performance,

        case
            when is_cancelled = 1
                then 'Cancelled'
            when is_delivered=1
            and is_on_time=1
                then 'Excellent'
            when is_delivered=1
            and is_on_time=0
            then 'Late'
            when is_delayed=1
            then 'Delayed'
            when is_shipped=1
            then 'In Transit'

            else 'Pending'
        end as fulfillment_performance,

        -- delay category
        case
            when calculated_delay_days is null
             then 'No Delivery'
            when calculated_delay_days <= 0
            then 'On Timne'
            when calculated_delay_days <=3
            then 'Minor Delay'
            when calculated_delay_days <= 7
            then 'Moderate Delay'


            when calculated_delay_days <= 14
                then 'Major Delay'


            else 'Severe Delay'

        end as delay_category,
                -- ====================================================
        -- SHIPPING SPEED
        -- ====================================================

        case

            when days_to_ship is null
                then 'Not Shipped'


            when days_to_ship = 0
                then 'Same Day'


            when days_to_ship <= 2
                then 'Fast'


            when days_to_ship <= 5
                then 'Normal'


            else 'Slow'

        end as shipping_speed_category

    from fulfillment

)
select * from order_metrics