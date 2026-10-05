{{ config(
    materialized='table'
) }}

with orders as (

    select *
    from {{ ref('stg_orders') }}

),

metrics as (

    select *
    from {{ ref('int_order_metrices') }}

),
final as (

    select



        o.order_id,

        o.product_id,

        o.supplier_id,


        o.order_date,

        extract(year from o.order_date)
            as order_year,

        extract(month from o.order_date)
            as order_month,

        extract(quarter from o.order_date)
            as order_quarter,




        o.quantity,

        o.unit_price,

        o.order_amount,

        o.currency,

        o.payment_method,

        o.expected_delivery_date,



        o.order_status,

        case

            when upper(trim(o.order_status)) = 'PENDING'
                then 'Pending'

            when upper(trim(o.order_status)) = 'CONFIRMED'
                then 'Confirmed'

            when upper(trim(o.order_status)) = 'PROCESSING'
                then 'Processing'

            when upper(trim(o.order_status)) = 'SHIPPED'
                then 'Shipped'

            when upper(trim(o.order_status)) = 'DELIVERED'
                then 'Delivered'

            when upper(trim(o.order_status)) = 'CANCELLED'
                then 'Cancelled'

            else 'Unknown'

        end as order_status_group,

        -- status flags
        case
            when upper(trim(o.order_status)) = 'PENDING'
                then 1
            else 0
        end as is_pending,


        case
            when upper(trim(o.order_status)) = 'CONFIRMED'
                then 1
            else 0
        end as is_confirmed,


        case
            when upper(trim(o.order_status)) = 'PROCESSING'
                then 1
            else 0
        end as is_processing,


        case
            when upper(trim(o.order_status)) = 'SHIPPED'
                then 1
            else 0
        end as is_shipped,


        case
            when upper(trim(o.order_status)) = 'DELIVERED'
                then 1
            else 0
        end as is_delivered,


        case
            when upper(trim(o.order_status)) = 'CANCELLED'
                then 1
            else 0
        end as is_cancelled,

        -- order value category
        case
            when o.order_amount is null
            then 'Unknown'

             when o.order_amount < 10000
            then 'Small'
            when o.order_amount < 50000
            then'Medium'
             when o.order_amount < 200000
            then 'Large'
            else 'Very Large'
        end as order_Value_category,


        -- quantity category
        case

            when o.quantity is null
                then 'Unknown'

            when o.quantity <= 10
                then 'Low'

            when o.quantity <= 100
                then 'Medium'

            when o.quantity <= 500
                then 'High'

            else 'Very High'

        end as quantity_category,

        -- unit price category

        case
            when o.unit_price is null
                then 'Unknown'
            when o.unit_price < 1000
                then 'Low'
            when o.unit_price < 10000
                then 'Medium'
            when o.unit_price < 50000
                then 'High'
            else 'Premium'
        end as unit_price_category,

        -- payment category
        case

            when upper(trim(o.payment_method))
                in ('BANK TRANSFER', 'NEFT', 'RTGS')

                then 'Banking'

            when upper(trim(o.payment_method)) = 'UPI'
                then 'Digital Payment'

            when upper(trim(o.payment_method)) = 'CREDIT'
                then 'Credit'

            when upper(trim(o.payment_method)) = 'CHEQUE'
                then 'Cheque'

            when upper(trim(o.payment_method)) = 'CASH'
                then 'Cash'

            else 'Other'

        end as payment_category,

        -- expected delivery metrics
        case
            when o.order_date is not null
             and o.expected_delivery_date is not null
             then datediff(
             'day',o.order_date,o.expected_delivery_date
             )
             else null
        end as expected_delivery_days,

        -- order agae
        case
            when o.order_date is not null
            then datediff(
            'day',o.order_date,current_date()
            )
            else null
        end as order_age_days,

        -- orde date flags
        case
            when o.order_date is not null
            and dayofweek(o.order_date) in (1,7)
            then 1
            else 0
        end as is_weekend_order,

        -- delivery expection flag
        case
            when o.expected_delivery_date is not null
            and o.expected_delivery_date < o.order_date
            then 1
            else 0
        end as is_invalid_expected_delivery_date,

        -- order amount validation

        case
            when o.quantity  is not null
            and o.unit_price is not null
            and o.order_amount is not null
            and round(o.quantity * o.unit_price,2
            )= round(o.order_amount,2)
            then 1
            else 0
        end as is_order_amount_correct,

        -- calculated  order amount
        case
            when o.quantity is not null and o.unit_price is not null
            then round(
            o.quantity * o.unit_price,2
            )
            else null
        end as calculated_order_amount,

        --order amount difference
        case
            when o.quantity is not null
            and o.unit_price is not null
            and o.order_amount is not null
            then round(
                o.order_amount - (o.quantity * o.unit_price),2
            )

            else null
        end as order_amount_difference

        from orders o


)
select * from final








