{{ config(
    materialized='table'
) }}
with orders as (
    select * from {{ ref('stg_orders')}}
),
order_metrics as (
    select
        order_id,

        count(*) as order_line_count,

        sum(quantity) as total_quantity,

        sum(order_amount) as calculated_order_amount,

        min(order_date) as first_order_date,

        max(expected_delivery_date) as expected_delivery_date

    from orders
    group by order_id

),
final as (


    select

        -- =====================================================
          -- ORDER IDENTIFICATION
           -- ==================================================== */

        o.order_id,

        o.product_id,

        o.supplier_id,



        --/* =====================================================
          -- ORDER DATE
           --===================================================== */

        o.order_date,

        extract(year from o.order_date) as order_year,

        extract(month from o.order_date) as order_month,

        extract(quarter from o.order_date) as order_quarter,


        -- /* =====================================================
         --  ORDER DETAILS
           --===================================================== */

        o.quantity,

        o.unit_price,

        o.order_amount,

        o.currency,

        o.payment_method,

        o.expected_delivery_date,




         --/* =====================================================
          -- ORDER STATUS
           --===================================================== */

        o.order_status,

        case
            when upper(trim(o.order_status)) = 'PENDING'
                THEN 'Pending'
            when upper(trim(o.order_status)) = 'CONFIRMED'
                THEN    'Confirmed'
            when upper(trim(o.order_status))='PROCESSING'
                THEN 'Processing'
            when upper(trim(o.order_status))='SHIPPED'
                THEN 'Shipped'
            when upper(trim(o.order_status))='DELIVERED'
                THEN 'Delivered'
            when upper(trim(o.order_status))='CANCELLED'
                then 'Cancelled'

            else 'Unknown'

        end as order_status_group,

        -- order status flag
        case
            when upper(trim(o.order_status))='CONFIRMED'
                THEN 1
            ELSE 0
        END AS id_confirmed,

        case
            when upper(trim(o.order_status))='PENDING'
                THEN 1
            ELSE 0
        END AS is_pending,

        case
            when upper(trim(o.order_status))='PROCESSING'
            THEN 1
            ELSE 0
        END AS is_processing,

        case
            when upper(trim(o.order_status))='SHIPPED'
            THEN 1
            ELSE 0
        END AS is_shipped,
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

        -- delivery expectation

        case
            when o.expected_delivery_date is not null
            and o.order_date is not null
            then datediff(

            'day',o.order_date,o.expected_delivery_date
            )
        end as expected_delivery_days,

        -- order size classification

        case
            when o.order_amount is null
                then 'Unknown'

            when o.order_amount < 10000
                then 'Small Order'
            when o.order_amount < 50000
                then'Medium Order'
            when o.order_amount < 200000
                then 'Large Order'
            else 'Very Large Order'
        end as order_size_category,

        case
            when o.quantity is null
                then 'Unknown'
            when o.quantity <=10
                then 'Low Quantity'
            when o.quantity <=100
                then 'Medium Quantity'
            when o.quantity <=500
                then 'High Quantity'
            else 'Very High Quantity'
        end as quantity_category,

        -- price classification

        case
            when o.unit_price is null
                then null
            when o.unit_price < 1000
                then 'Low Value'
            when o.unit_price < 10000
                then 'Medium Value'
            when o.unit_price < 50000
                then 'High Value'
            else 'Premium Value'
        end as unit_price_category,
        -- payment method classification
        case

            when upper(trim(o.payment_method))
                in ('BANK TRANSFER', 'NEFT', 'RTGS')

                then 'Banking'

            when upper(trim(o.payment_method))
                = 'UPI'

                then 'Digital Payment'

            when upper(trim(o.payment_method))
                = 'CREDIT'

                then 'Credit'

            when upper(trim(o.payment_method))
                = 'CHEQUE'

                then 'Cheque'

            when upper(trim(o.payment_method))
                = 'CASH'

                then 'Cash'

            else 'Other'

        end as payment_category,

        -- currency classification

        case
            when upper(trim(o.currency)) = 'INR'
                then 'Indian Rupee'
            else 'Other Currency'

        end as currency_category,
         --DATE FLAGS


        case

            when o.order_date is null
                then 0

            when dayofweek(o.order_date) in (1,7)
                then 1

            else 0

        end as is_weekend_order,


        case

            when o.order_date is null
                then 0

            when month(o.order_date) in (1,3,4,5,6,7,8,9,10,11,12)
                then 0

            else 1

        end as is_valid_order_month,

        m.order_line_count,
        m.total_quantity,
        m.calculated_order_amount

    from orders o
    left join order_metrics m
    on o.order_id=m.order_id
)
select * from final
















