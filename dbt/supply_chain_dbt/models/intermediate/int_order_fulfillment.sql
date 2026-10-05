--This model joins:
--
--stg_orders
--    ↓ order_id
--stg_shipments
--    ↓ shipment_id
--stg_deliveries
--
--It creates one clean fulfillment dataset for later marts.


with orders as (
    select

       order_id,
        product_id,
        supplier_id,
        order_date,
        quantity,
        unit_price,
        order_amount,
        currency,
        payment_method,
        expected_delivery_date as order_expected_delivery_date,
        order_status

    from {{ ref('stg_orders') }}
),
shipments as (
    select
        shipment_id,
        order_id,
        carrier,
        shipping_method,
        tracking_number,
        shipment_date,
        expected_delivery_date as shipment_expected_delivery_date,
        actual_delivery_date as shipment_actual_delivery_date,
        shipping_cost,
        shipment_status

    from {{ ref('stg_shipments') }}

),
deliveries as (
    select
        delivery_id,
        shipment_id,
        delivery_partner,
        expected_delivery_date as delivery_expected_delivery_date,
        actual_delivery_date as delivery_actual_delivery_date,
        delay_days,
        delivery_attempts,
        delivery_city,
        recipient_name,
        recipient_phone,
        delivery_status

    from {{ ref('stg_deliveries') }}


),
joined as (
    select
        o.order_id,
        o.product_id,
        o.supplier_id,
        o.order_date,
        o.quantity,
        o.unit_price,
        o.order_amount,
        o.currency,
        o.payment_method,
        o.order_expected_delivery_date,
        o.order_status,

        -- shipment
        s.shipment_id,
        s.carrier,
        s.shipping_method,
        s.tracking_number,
        s.shipment_date,
        s.shipment_expected_delivery_date,
        s.shipment_actual_delivery_date,
        s.shipping_cost,
        s.shipment_status,

        /* =============================
           DELIVERY
           ============================= */

        d.delivery_id,
        d.delivery_partner,
        d.delivery_expected_delivery_date,
        d.delivery_actual_delivery_date,
        d.delay_days,
        d.delivery_attempts,
        d.delivery_city,
        d.recipient_name,
        d.recipient_phone,
        d.delivery_status

    from orders o
        left join shipments s
            on o.order_id = s.order_id
        left join  deliveries d
            on s.shipment_id = d.shipment_id


),

final as (
    select * ,
    case
    -- ====================================================
        -- ORDER → SHIPMENT
        -- ====================================================

        when shipment_date is not null
        and order_date is not null

        then datediff(
            'day',order_date,shipment_date
        )
    end as days_to_ship,

    case
        when shipment_date is not null
        and delivery_actual_delivery_date is not null
        then datediff(
            'day',shipment_date,delivery_actual_delivery_date
        )
        else null
    end as transit_days,-- shipment to delivery days

--    case
--        when order_date is not null and
--        order_expected_delivery_date is not null
--        then datediff(
--        'day',order_date,order_expected_delivery_date
--        )
--        else null
--    end as expected_delivery_date_order,


    case
        when order_date is not null
        and delivery_actual_delivery_date is not null
        then datediff(
            'day',order_date,delivery_actual_delivery_date
        )else null
    end as order_to_delivery_days,
    case
        when delivery_actual_delivery_date is not null
        and delivery_expected_delivery_date is not null
        then datediff(
            'day',delivery_expected_delivery_date,delivery_actual_delivery_date
        )
        else null
    end as calculated_delay_days,

    case
        when upper(trim(delivery_status))='DELIVERED'
        then 1
        else 0
    end as is_delivered,

    case
        when upper(trim(delivery_status))='DELAYED'
        then 1
        else 0
    end as is_delayed,

    case
        when delivery_actual_delivery_date is not null
        and delivery_expected_delivery_date is not null
        and delivery_actual_delivery_date <= delivery_expected_delivery_date
        then 1
        else 0
    end as  is_on_time,

    case
        when upper(trim(order_status)) = 'CANCELLED'
        then 1 else 0
    end as is_cancelled,

    case
        when shipment_id is not null
        then 1
        else 0
    end as is_shipped,
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

    end as order_quantity_band

from joined
)
select * from final