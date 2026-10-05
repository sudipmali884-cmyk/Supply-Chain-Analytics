{{ config(
    materialized='table'
) }}

with fulfillment as (

    select *

    from {{ ref('int_order_fulfillment') }}

),

final as (

    select

        -- ====================================================
        -- ORDER IDENTIFICATION
        -- ====================================================

        order_id,

        product_id,

        supplier_id,


        -- ====================================================
        -- ORDER INFORMATION
        -- ====================================================

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

        carrier,

        shipping_method,

        tracking_number,

        shipment_date,

        shipment_expected_delivery_date,

        shipment_actual_delivery_date,

        shipping_cost,

        shipment_status,


        -- ====================================================
        -- DELIVERY INFORMATION
        -- ====================================================

        delivery_id,

        delivery_partner,

        delivery_expected_delivery_date,

        delivery_actual_delivery_date,

        delivery_status,

        delivery_attempts,

        delivery_city,

        recipient_name,

        recipient_phone,


        -- ====================================================
        -- FULFILLMENT TIMING METRICS
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
        -- DELIVERY PERFORMANCE
        -- ====================================================

        case

            when upper(trim(delivery_status)) = 'DELIVERED'
             and is_on_time = 1

                then 'On Time'

            when upper(trim(delivery_status)) = 'DELIVERED'
             and is_on_time = 0

                then 'Late Delivered'

            when upper(trim(delivery_status)) = 'DELAYED'

                then 'Delayed'

            when upper(trim(delivery_status)) = 'PENDING'

                then 'Pending'

            when upper(trim(delivery_status)) = 'RETURNED'

                then 'Returned'

            when upper(trim(delivery_status)) = 'FAILED'

                then 'Failed'

            when delivery_status is null

                then 'No Delivery'

            else 'Unknown'

        end as delivery_performance,


        -- ====================================================
        -- FULFILLMENT PERFORMANCE
        -- ====================================================

        case

            when is_cancelled = 1

                then 'Cancelled'

            when is_delivered = 1
             and is_on_time = 1

                then 'Excellent'

            when is_delivered = 1
             and is_on_time = 0

                then 'Late'

            when is_delayed = 1

                then 'Delayed'

            when is_shipped = 1

                then 'In Transit'

            else 'Pending'

        end as fulfillment_performance,


        -- ====================================================
        -- DELAY CATEGORY
        -- ====================================================

        case

            when calculated_delay_days is null

                then 'No Delivery'

            when calculated_delay_days <= 0

                then 'On Time'

            when calculated_delay_days <= 3

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

        end as shipping_speed_category,


        -- ====================================================
        -- DELIVERY ATTEMPT CATEGORY
        -- ====================================================

        case

            when delivery_attempts is null

                then 'Unknown'

            when delivery_attempts = 1

                then 'First Attempt'

            when delivery_attempts = 2

                then 'Second Attempt'

            when delivery_attempts >= 3

                then 'Multiple Attempts'

            else 'Unknown'

        end as delivery_attempt_category,


        -- ====================================================
        -- ORDER STATUS FLAGS
        -- ====================================================

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


        -- ====================================================
        -- ORDER SIZE FLAGS
        -- ====================================================

        case

            when quantity >= 200

                then 1

            else 0

        end as is_bulk_order,


        case

            when quantity >= 100

                then 1

            else 0

        end as is_large_quantity_order,


        -- ====================================================
        -- HIGH VALUE ORDER FLAG
        -- ====================================================

        case

            when order_amount >= 200000

                then 1

            else 0

        end as is_high_value_order,


        -- ====================================================
        -- ORDER VALUE BAND
        -- ====================================================

        case

            when order_amount is null

                then 'Unknown'

            when order_amount < 10000

                then 'Low Value'

            when order_amount < 50000

                then 'Medium Value'

            when order_amount < 200000

                then 'High Value'

            else 'Very High Value'

        end as order_value_band,


        -- ====================================================
        -- ORDER QUANTITY BAND
        -- ====================================================

        case

            when quantity is null

                then 'Unknown'

            when quantity <= 10

                then 'Small Order'

            when quantity <= 50

                then 'Medium Order'

            when quantity <= 200

                then 'Large Order'

            else 'Bulk Order'

        end as order_quantity_band,


        -- ====================================================
        -- ORDER DATE INFORMATION
        -- ====================================================

        extract(
            year from order_date
        ) as order_year,

        extract(
            month from order_date
        ) as order_month,

        extract(
            quarter from order_date
        ) as order_quarter,


        -- ====================================================
        -- FULFILLMENT QUALITY FLAG
        -- ====================================================

        case

            when is_cancelled = 1

                then 'Cancelled Order'

            when is_delivered = 1
             and is_on_time = 1

                then 'Successfully Fulfilled'

            when is_delivered = 1
             and is_on_time = 0

                then 'Late Fulfillment'

            when is_delayed = 1

                then 'Delayed Fulfillment'

            when is_shipped = 1

                then 'In Transit'

            when order_id is not null
             and shipment_id is null

                then 'Awaiting Shipment'

            else 'Pending Fulfillment'

        end as fulfillment_quality_category


    from fulfillment

)

select *

from final