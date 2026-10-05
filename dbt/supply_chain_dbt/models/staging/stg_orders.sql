with orders as(
    select * from {{ source('raw','orders')}}
),
cleaned_data as(
    select
        case
            when regexp_like(trim(order_id),'^ORD[0-9]{7}$')
            then trim(order_id)
            else null
    end as order_id,

    case when regexp_like(trim(product_id),'^PRD[0-9]{6}$')
        then trim(product_id)
        else null
    end as product_id,

    case
        when regexp_like(trim(supplier_id),'^SUP[0-9]{6}$') then trim(supplier_id)
        else null
    end as supplier_id,

    order_date ,
    case
        when quantity is null then null
        when try_to_number(quantity) < 1 then null

        when try_to_number(quantity) > 500 then null

        else try_to_number(quantity)
    end as quantity,

    case
        when unit_price is null then null
        when unit_price <=0 then null
        when unit_price > 500000 then null
        else unit_price
    end as unit_price,

--    case
--        when order_amount is null then null
--        when order_amount  <=0 then null
--        when order_amount  > 5000000000000 then null
--        when quantity is not null and unit_price is not null then round(
--            quantity * unit_price,2
--        )
--        -- when order_amount in ('unknown','N/A') then null
--        else order_amount
--    end as order_amount,

    CASE
        WHEN quantity IS NULL
          OR unit_price IS NULL
            THEN NULL

        WHEN quantity <= 0
            THEN NULL

        WHEN unit_price <= 0
            THEN NULL

        WHEN quantity * unit_price > 2000000000
            THEN NULL

        ELSE ROUND(quantity * unit_price, 2)
    END AS order_amount,

    case
        when upper(trim(currency))='INR' then 'INR'
        else null
    end as currency,

    case
        when payment_method is null then null
        when trim(payment_method)='' then null
        else payment_method
    end as payment_method,

    expected_delivery_date,
    order_status

from orders

),
deduplicated as(
    select * from cleaned_data
    qualify row_number() over(
        partition by order_id
        order by order_id desc
    )=1
)
select * from deduplicated
