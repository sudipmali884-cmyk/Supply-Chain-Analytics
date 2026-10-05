with shipments as(
    select * from {{ source ('raw','shipments')}}
),

cleaned_data as(
    select
        case
            when regexp_like(nullif(trim(shipment_id),''),'^SHP[0-9]{7}$')
            then trim(shipment_id)
            else null
        end as shipment_id,

        case
            when regexp_like(nullif(trim(order_id),''),'^ORD[0-9]{7}$')
            then trim(order_id)
            else null
        end as order_id,

        case
            when carrier is null then null
            when trim(carrier)='' then null

            when (carrier)in (
                       'delhivery',

                        'DELHIVERY',

                        ' Delhivery',

                        'Delhivery ',

                        'BlueDart',

                        'unknown',

                        'N/A',

                        'Fake Express'
            ) then null

            else carrier
        end as carrier,

        case
            when shipping_method is null then null
            when trim(shipping_method)='' then null
            when upper(trim(shipping_method) ) in
                (
                    'STANDARD',
                    'EXPRESS',
                    'SAME DAY',
                    'ECONOMY',
                    'AIR',
                    'ROAD'
                )
            then initcap(trim(shipping_method))
            else null
        end as shipping_method,

        case
            when regexp_like(nullif(trim(tracking_number),''),
            '^(DEL|BLU|DHL|FED|ECM|DTC|XPR|EKT|SHF)[0-9]{10}$'
            )
            then trim(tracking_number)
            else null
        end as tracking_number,
--        case
--            when
--            (nullif(trim(shipment_date),''))is not null
--            then (nullif(trim(shipment_date),'')) else null
--        end as shipment_date,
        case
    when try_to_date(
        nullif(trim(shipment_date), '')
    ) is not null
    then try_to_date(
        nullif(trim(shipment_date), '')
    )
    else null
end as shipment_date,
        expected_delivery_date,


        -- ====================================================
        -- ACTUAL DELIVERY DATE
        -- NULL is valid here because undelivered shipments
        -- don't have an actual delivery date.
        -- ====================================================

--        case
--            when nullif(trim(actual_delivery_date),'' ) is null then null
--            when (trim(actual_delivery_date))is not null
--                then (trim(actual_delivery_date))
--            else null
--        end as actual_delivery_date,
case
    when try_to_date(
        nullif(trim(actual_delivery_date), '')
    ) is not null
    then try_to_date(
        nullif(trim(actual_delivery_date), '')
    )
    else null
end as actual_delivery_date,

        case
            when shipping_cost is null then null
            when shipping_cost <= 0 then null
            when shipping_cost > 2500 then  null
            else shipping_cost
        end as shipping_cost,

--        CASE
--    WHEN UPPER(TRIM(shipment_status)) IN (
--        'PENDING',
--        'PICKED UP',
--        'IN TRANSIT',
--        'OUT FOR DELIVERY',
--        'DELIVERED',
--        'DELAYED',
--        'CANCELLED'
--    )
--    THEN INITCAP(TRIM(shipment_status))
--
--    ELSE 'Unknown'
--END AS shipment_status
        case
            when shipment_status in (
            'Pending','Picked Up','In Transit', 'Out for Delivery',
             'Delivered','Delayed','Cancelled'
            ) then shipment_status
            else 'Unknown'
        end as shipment_status

    from shipments
),

deduplicated as(
    select * from cleaned_data
    qualify row_number() over(
        partition by shipment_id
        order by shipment_date desc
    )= 1
)
select * from deduplicated
