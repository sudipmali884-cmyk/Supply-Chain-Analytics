{{ config(
    materialized='table'
) }}

with deliveries as (

    select *

    from {{ ref('stg_deliveries') }}

),

delivery_metrics as (

    select *

    from {{ ref('int_delivery_metrics') }}

),

final as (

    select

        d.delivery_id,

        d.shipment_id,


        d.delivery_partner,

        d.delivery_city,

        d.recipient_name,

        d.recipient_phone,

        d.delivery_status,


        d.expected_delivery_date,

        d.actual_delivery_date,

        d.delivery_attempts,

        d.delay_days,


        m.calculated_delay_days,

        m.delivery_delay_days, -- SAME AS IS_IN _TRANSIT


        m.is_delivered,

        m.is_delayed,

        m.is_out_for_delivery,

        m.is_failed,

        m.is_returned,

        m.is_pending,


        m.is_on_time,

        m.is_late,


        m.delivery_attempt_category,


        m.delay_category,


        m.delivery_performance_category,


        m.attempt_performance_category,

        m.delay_severity_score,

        case
            when d.actual_delivery_date is not null
            then 1
            else 0
        end as is_delivery_completed,

        case
            when upper(trim(d.delivery_status)) = 'OUT FOR DELIVERY'
            then 1 else 0
        end as is_delivery_in_progress,

        -- delivery failure flag

        case
            when upper(trim(d.delivery_status)) = 'FAILED'
            then 1
            else 0
        end as is_delivery_failed,

        -- return flag
        case
            when upper(trim(d.delivery_status)) = 'RETURNED'
            then 1
            else 0
        end as is_delivery_returned,

        -- multiple attempt flag

        case
        when
            d.delivery_attempts >=3
            then 1
            else 0
        end as is_multiple_attempt_delivery,

        case
            when d.delivery_attempts = 1
            and upper(trim(d.delivery_status))='DELIVERED'
            then 1
            else 0
        end as is_first_attempt_success,

        case
            when m.calculated_delay_days is not null
            and m.calculated_delay_days > 0
            then 1 else 0
        end as has_delivery_delay,
        -- DELIVERY ATTEMPT CATEGORY
        -- ====================================================

        case

            when d.delivery_attempts is null

                then 'Unknown'

            when d.delivery_attempts = 1

                then 'Single Attempt'

            when d.delivery_attempts = 2

                then 'Two Attempts'

            when d.delivery_attempts >= 3

                then 'Multiple Attempts'

            else 'Unknown'

        end as delivery_attempt_count_category,

                -- DELIVERY DELAY BAND
        -- ====================================================

        case

            when m.calculated_delay_days is null

                then 'No Delivery'

            when m.calculated_delay_days <= 0

                then 'On Time'

            when m.calculated_delay_days <= 3

                then 'Minor Delay'

            when m.calculated_delay_days <= 7

                then 'Moderate Delay'

            when m.calculated_delay_days <= 14

                then 'Major Delay'

            else 'Severe Delay'

        end as delivery_delay_band,

        -- delivery date information

        extract(year from d.expected_delivery_date) as expected_delivery_year,
        extract(month from d.expected_delivery_date) as expected_delivery_month,
        extract(quarter from d.expected_delivery_date) as expected_delivery_quarter,
        extract(year from d.actual_delivery_date) as actual_delivery_year,
        extract(month from d.actual_delivery_date) as actual_delivery_month,
        extract(quarter from d.actual_delivery_date) as actual_delivery_quarter,

       -- DELIVERY QUALITY FLAG
        -- ====================================================

        case

            when d.delivery_id is null

                then 'Invalid Delivery ID'

            when d.shipment_id is null

                then 'Missing Shipment ID'

            when d.delivery_status is null

                then 'Missing Delivery Status'

            when d.delivery_attempts is not null
             and d.delivery_attempts < 0

                then 'Invalid Delivery Attempts'

            when d.expected_delivery_date is not null
             and d.actual_delivery_date is not null
             and d.actual_delivery_date < d.expected_delivery_date
             and upper(trim(d.delivery_status)) != 'DELIVERED'

                then 'Delivery Date Validation Issue'

            else 'Valid Delivery'

        end as delivery_quality_flag
    from deliveries d
    left join delivery_metrics m
    on d.delivery_id = m.delivery_id
)

select * from final
