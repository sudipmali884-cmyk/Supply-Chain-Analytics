with deliveries as(
    select * from {{ ref('stg_deliveries')}}
),
delivery_metrics as (
    select
               -- ====================================================
        -- IDENTIFIERS
        -- ====================================================

        delivery_id,

        shipment_id,


        -- ====================================================
        -- DELIVERY INFORMATION
        -- ====================================================

        delivery_partner,

        delivery_city,

        recipient_name,

        recipient_phone,

        delivery_status,


        -- ====================================================
        -- DELIVERY DATES
        -- ====================================================

        expected_delivery_date,

        actual_delivery_date,


        -- ====================================================
        -- DELIVERY ATTEMPTS
        -- ====================================================

        delivery_attempts,


        -- ====================================================
        -- SOURCE DELAY
        -- ====================================================

        delay_days,


        -- ====================================================
        -- CALCULATED DELAY
        --
        -- Actual delivery date - Expected delivery date
        -- ====================================================
        case
            when expected_delivery_date is not null
            and actual_delivery_date is not null
            then datediff(
                'day',expected_delivery_date,actual_delivery_date
            )
            else null
        end as calculated_delay_days,

        case
            when delivery_status = 'Delivered'
            then 1
            else 0
        end as is_delivered,

        case
            when delivery_status= 'Delayed'
            then 1
            else 0
        end as is_delayed,

        case
            when delivery_status = 'Out for Delivery'
            then 1
            else 0

        end as is_out_for_delivery,

        case
            when delivery_status = 'Failed'
            then 1
            else 0
        end as is_failed,

        case
            when delivery_status = 'Returned'
            then 1
            else 0
        end as is_returned,
        case
            when delivery_status = 'Pending'
            then 1
            else 0
        end as is_pending,

        -- on time delivery
        case
            when actual_delivery_date is not null
            and expected_delivery_date is not  null
            and actual_delivery_date <= expected_delivery_date
            then 1
            else 0
        end as is_on_time,

        -- late delivery
        case
            when actual_delivery_date is not null
            and expected_delivery_date is not null
            and actual_delivery_date > expected_delivery_date
            then 1
            else 0
        end as is_late,

        -- delivery attempt category

        case
            when delivery_attempts  is null then 'Unknown'
            when delivery_attempts = 1 then 'First Attempt'
            when delivery_attempts = 2 then 'Second Attempt'
            when delivery_attempts >= 3 then 'Multiple Attempts'
            else 'Unknown'
        end as delivery_attempt_category,

                -- ====================================================
        -- CALCULATED DELAY
        -- ====================================================

--        case
--
--            when actual_delivery_date is not null
--             and expected_delivery_date is not null
--
--            then datediff(
--                'day',
--                expected_delivery_date,
--                actual_delivery_date
--            )
--
--            else null
--
--        end as calculated_delay_days,

                -- ====================================================
        -- DELIVERY TIME
        -- ====================================================

        case

            when actual_delivery_date is not null
             and expected_delivery_date is not null

            then datediff(
                'day',
                expected_delivery_date,
                actual_delivery_date
            )

            else null

        end as delivery_delay_days,

        -- delay category
        case
            when actual_delivery_date is null
             then 'Delivery Not Completed'

            when actual_delivery_date <= expected_delivery_date
                then 'Delivery On Time'

            when datediff(
            'day',expected_delivery_date,actual_delivery_date
            ) <=3
                then 'Minor Delay'
                
            when datediff(
            'day',expected_delivery_date,actual_delivery_date
            )<= 7
                then 'Moderate Delay'
            else 'Severe Delay'
        end as delay_category,

        -- delivery performance cate gory

        case
            when delivery_status = 'Delivered'
            and actual_delivery_date <= expected_delivery_date
            and delivery_attempts = 1
                then 'Excellent'
            when delivery_status = 'Delivered'
            and actual_delivery_date <= expected_delivery_date

            then 'Good'

            when delivery_status='Delivered'
            and actual_delivery_date > expected_delivery_date
            then 'Delayed Delivery'

            when delivery_status='Failed'
            then 'Failed Delivery'
            when delivery_status = 'Returned'
             then 'Returned'

            when delivery_status = 'Out for Delivery'
             then 'In Progress'
             when delivery_status ='Pending'
             then 'Pending'
            else null
        end as delivery_performance_category,

        -- delivery attempt performance

        case
            when delivery_attempts = 1
                then 'Efficient'
            when delivery_attempts = 2
                then 'Needs Attention'
            when delivery_attempts >= 3
                then 'Poor'
            else 'Unknown'

        end as attempt_performance_category,

        case
            when actual_delivery_date is null
             then null
            when actual_delivery_date <= expected_delivery_date
                then 0
            when datediff(
            'day',expected_delivery_date,actual_delivery_date
            ) <=3
                then 1
            when datediff(
            'day',expected_delivery_date,actual_delivery_date
            )<= 7
                then 2
            else 3
        end as delay_severity_score
    from deliveries

)
select * from delivery_metrics