{{ config(
    materialized='table'
) }}

with shipment_metrics as (

    select *
    from {{ ref('int_shipment_metrices') }}

),
orders as (
    select
        order_id,
        product_id,
        supplier_id,
        order_date,
        quantity,
        order_amount,
        order_status
    from {{ ref('stg_orders') }}

),
final as (
    select

        /* =====================================================
           SHIPMENT IDENTIFICATION
           ===================================================== */

        s.shipment_id,

        s.order_id,

        o.product_id,

        o.supplier_id,


        /* =====================================================
           SHIPMENT DETAILS
           ===================================================== */

        s.carrier,

        s.shipping_method,

        s.tracking_number,

        s.shipment_date,

        s.expected_delivery_date,

        --is_late, -- this is from int_shipment_metices

        -- S.delivery_delay_days

        s.actual_delivery_date,

        s.shipment_status,


        /* =====================================================
           SHIPPING COST
           ===================================================== */

        s.shipping_cost,


        /* =====================================================
           ORDER INFORMATION
           ===================================================== */

        o.order_date,

        o.quantity as order_quantity,

        o.order_amount,

        o.order_status,


        /* =====================================================
           SHIPMENT PERFORMANCE METRICS
           ===================================================== */

        m.expected_transit_days,

        m.actual_transit_days,

        m.is_delivered,

        m.is_delayed,

        m.is_on_time,


        -- business flags
        case
            when s.shipment_date is null
            then 1
            else 0
        end as is_not_shipped,

        case
            when s.shipment_status='Cancelled'
            then 1
            else 0
        end as is_cancelled,

        case
            when s.actual_delivery_date is null
            and s.shipment_status not in ('Cancelled')
                then 1
            else 0
        end as is_pending_delivery,

        case
           when s.actual_delivery_date is not null
           and s.expected_delivery_date is not null
           and s.actual_delivery_date > s.expected_delivery_date
           then 1
           else 0
        end as is_late_delivery,

        case
            when s.expected_delivery_date is not null
            and s.actual_delivery_date is not null
            and s.actual_delivery_date <= s.expected_delivery_date
            then 1
            else 0
        end as is_successful_delivery,

        case
           when s.shipment_date is not null
           and s.actual_delivery_date is null
           then 1
           else 0
        end as is_in_transit,

--        case
--            when m.actual_transit_days is null
--            then 1
--            else 0
--        end as is_in_transit,



        case
            when s.shipping_cost is null
            then 'Unknown'
            when s.shipping_cost <=100
            then 'Low Cost'
            when s.shipping_cost <=500
            then 'Medium Cost'
            when s.shipping_cost <=1500
             then 'High Cost'
            else 'Very High Cost'

        end as shipping_cost_category,
        -- ====================================================
        -- TRANSIT SPEED CATEGORY
        -- ====================================================

        case

            when m.actual_transit_days is null

                then 'Unknown'

            when m.actual_transit_days <= 2

                then 'Very Fast'

            when m.actual_transit_days <= 5

                then 'Fast'

            when m.actual_transit_days <= 10

                then 'Standard'

            else 'Slow'

        end as transit_speed_category,
                -- ====================================================
        -- DELIVERY DELAY CATEGORY
        -- ====================================================

        case

            when s.actual_delivery_date is null

                then 'Not Delivered'

            when s.expected_delivery_date is null

                then 'Unknown'

            when s.actual_delivery_date <= s.expected_delivery_date

                then 'On Time'

            when m.delivery_delay_days <= 3

                then 'Minor Delay'

            when m.delivery_delay_days <= 7

                then 'Moderate Delay'

            when m.delivery_delay_days <= 14

                then 'Major Delay'

            else 'Severe Delay'

        end as delay_category,

        -- ====================================================
        -- SHIPMENT PERFORMANCE CATEGORY
        -- ====================================================

        case

            when upper(trim(s.shipment_status)) = 'CANCELLED'

                then 'Cancelled'

            when s.actual_delivery_date is not null
             and s.expected_delivery_date is not null
             and s.actual_delivery_date <= s.expected_delivery_date

                then 'On Time'

            when s.actual_delivery_date is not null
             and s.expected_delivery_date is not null
             and s.actual_delivery_date > s.expected_delivery_date

                then 'Late'

            when upper(trim(s.shipment_status)) = 'DELAYED'

                then 'Delayed'

            when upper(trim(s.shipment_status)) = 'IN TRANSIT'

                then 'In Transit'

            when upper(trim(s.shipment_status)) = 'PENDING'

                then 'Pending'

            else 'Unknown'

        end as shipment_performance_category,


        -- ====================================================
        -- SHIPPING METHOD CATEGORY
        -- ====================================================

        case

            when s.shipping_method is null

                then 'Unknown'

            when upper(trim(s.shipping_method))
                in ('EXPRESS', 'EXPRESS SHIPPING')

                then 'Express'

            when upper(trim(s.shipping_method))
                in ('STANDARD', 'STANDARD SHIPPING')

                then 'Standard'

            when upper(trim(s.shipping_method))
                in ('ECONOMY', 'ECONOMY SHIPPING')

                then 'Economy'

            when upper(trim(s.shipping_method))
                in ('SAME DAY', 'SAME-DAY')

                then 'Same Day'

            else 'Other'

        end as shipping_method_category,


        -- ====================================================
        -- SHIPPING SPEED
        -- ====================================================

        case

            when m.expected_transit_days is null
             or m.actual_transit_days is null

                then 'Unknown'

            when m.actual_transit_days <= m.expected_transit_days

                then 'Within Expected Time'

            when m.actual_transit_days
                 <= m.expected_transit_days + 3

                then 'Slightly Delayed'

            when m.actual_transit_days
                 <= m.expected_transit_days + 7

                then 'Moderately Delayed'

            else 'Highly Delayed'

        end as shipping_performance_category,


        -- ====================================================
        -- SHIPPING DATE METRICS
        -- ====================================================

        case

            when s.shipment_date is not null
             and o.order_date is not null

                then datediff(
                    'day',
                    o.order_date,
                    s.shipment_date
                )

            else null

        end as days_from_order_to_shipment,-- days to ship



        -- ====================================================
        -- EXPECTED DELIVERY METRIC
        -- ====================================================

        case

            when s.shipment_date is not null
             and s.expected_delivery_date is not null

                then datediff(
                    'day',
                    s.shipment_date,
                    s.expected_delivery_date
                )

            else null

        end as expected_delivery_days,


        -- ====================================================
        -- ACTUAL DELIVERY METRIC
        -- ====================================================
         case
            when s.expected_delivery_date is not null
            and s.actual_delivery_date is not null
            then datediff(
                'day',s.expected_delivery_date,s.actual_delivery_date
            )
            else null
        end as delivery_delay_days,

        case

            when s.shipment_date is not null
             and s.actual_delivery_date is not null

                then datediff(
                    'day',
                    s.shipment_date,
                    s.actual_delivery_date
                )

            else null

        end as actual_delivery_days, -- days to delivery


        -- ====================================================
        -- SHIPMENT DATE INFORMATION
        -- ====================================================

        extract(
            year from s.shipment_date
        ) as shipment_year,

        extract(
            month from s.shipment_date
        ) as shipment_month,

        extract(
            quarter from s.shipment_date
        ) as shipment_quarter,


        -- ====================================================
        -- DELIVERY DATE INFORMATION
        -- ====================================================

        extract(
            year from s.actual_delivery_date
        ) as delivery_year,

        extract(
            month from s.actual_delivery_date
        ) as delivery_month,

        extract(
            quarter from s.actual_delivery_date
        ) as delivery_quarter,


        -- ====================================================
        -- SHIPPING COST FLAG
        -- ====================================================

        case

            when s.shipping_cost is not null
             and s.shipping_cost > 1500

                then 1

            else 0

        end as is_high_shipping_cost,


        -- ====================================================
        -- DELIVERY DELAY FLAG
        -- ====================================================

        case

            when m.delivery_delay_days is not null
             and m.delivery_delay_days > 7

                then 1

            else 0

        end as is_severely_delayed,





        -- ====================================================
        -- ORDER / SHIPMENT VALIDATION
        -- ====================================================

        case

            when s.order_id is not null
             and o.order_id is not null

                then 1

            else 0

        end as is_valid_order_reference,


        -- ====================================================
        -- TRACKING INFORMATION
        -- ====================================================

        case

            when s.tracking_number is not null
             and trim(s.tracking_number) != ''

                then 1

            else 0

        end as has_tracking_number


    from {{ ref('stg_shipments') }} s

    left join orders o

        on s.order_id = o.order_id

    left join shipment_metrics m

        on s.shipment_id = m.shipment_id

)

select *

from final

