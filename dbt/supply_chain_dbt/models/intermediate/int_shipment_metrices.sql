with shipments as (

    select *
    from {{ ref('stg_shipments') }}

),
shipment_metrics as (

    select

        -- ====================================================
        -- IDENTIFIERS
        -- ====================================================

        shipment_id,

        order_id,

        tracking_number,


        -- ====================================================
        -- SHIPMENT INFORMATION
        -- ====================================================

        carrier,

        shipping_method,

        shipment_status,


        -- ====================================================
        -- DATES
        -- ====================================================

        shipment_date,

        expected_delivery_date,

        actual_delivery_date,


        -- ====================================================
        -- SHIPPING COST
        -- ====================================================

        shipping_cost,

        case
            when shipment_date is not null
            and expected_delivery_date is not null
            then datediff(
                'day',
                shipment_date,
                expected_delivery_date
            )
            else null
        end as expected_transit_days,

        case
            when shipment_date is not null
            and actual_delivery_date is not null
            then datediff(
                'day',shipment_date,actual_delivery_date
            )
            else null

        end as actual_transit_days, -- same as is_in_transit

        case
            when expected_delivery_date is not null
            and actual_delivery_date is not null
            then datediff(
                'day',expected_delivery_date,actual_delivery_date
            )
            else null
        end as delivery_delay_days,


        case
            when shipment_status = 'Delivered'
            then 1
            else 0
        end as is_delivered,

        case
            when shipment_status ='In Transit'
            then 1
            else 0
        end as is_in_transit,

        case
            when shipment_status ='Delayed'
            then 1
            else 0
        end as is_delayed,

        case
            when shipment_status ='Cancelled'
            then 1
            else 0
        end as is_cancelled,

        case
            when actual_delivery_date is not null
            and expected_delivery_date is not null
            and actual_delivery_date <= expected_delivery_date
            then 1
            else 0
        end as is_on_time,
        case
            when actual_delivery_date is not null
            and expected_delivery_date is not null
            and actual_delivery_date > expected_delivery_date
            then 1
            else 0
        end as is_late,
        -- ====================================================
        -- SHIPPING COST CATEGORY
        -- ====================================================

        case

            when shipping_cost is null
                then 'Unknown'

            when shipping_cost <= 100
                then 'Low Cost'

            when shipping_cost <= 500
                then 'Medium Cost'

            when shipping_cost <= 1500
                then 'High Cost'

            else 'Very High Cost'

        end as shipping_cost_category,

        -- transit speed category - shipment to delivery
        case
            when shipment_date is null
            or actual_delivery_date is null
            then 'Unknown'

            when datediff('day',shipment_date,actual_delivery_date) <=2
             then 'Very Fast'
            when datediff('day',shipment_date,actual_delivery_date) <=5
             then 'Fast'
            when datediff('day',shipment_date,actual_delivery_date) <=10
             then 'Standard'
             else 'Slow'
        end as transit_speed_category,

        -- delay category
        case
            when actual_delivery_date is null
             then 'Not Delivered'
            when actual_delivery_date <= expected_delivery_date
            then 'On Time'
            when datediff('day',expected_delivery_date,actual_delivery_date) <=3
            then 'Minor Delay'
            when datediff('day',expected_delivery_date,actual_delivery_date)<=7
             then 'Severe Delay'
             else 'More Delay'
            end as delay_category

    from shipments
)
select * from shipment_metrics




