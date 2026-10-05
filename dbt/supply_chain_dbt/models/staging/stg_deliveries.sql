with deliveries as (
    select * from {{ source('raw','deliveries')}}
),
cleaned_data as(
    select
        delivery_id,
        case
            when regexp_like(nullif(trim(shipment_id),''), '^SHP[0-9]{7}$')
            then trim(shipment_id)
        else null
    end as shipment_id,

    case
        when delivery_partner is null then null
        when delivery_partner = '' then null
        when delivery_partner in (
               'Wrong partner','Unknown','This partner is not good'
        ) then null
        else delivery_partner
    end as delivery_partner,

    expected_delivery_date,
    actual_delivery_date,

    case
        when delay_days is null then null
        when delay_days < 0 then null
        when delay_days > 20 then null
        else delay_days
    end as delay_days,
    delivery_attempts,

    case
        when delivery_city is null then null
        when trim(delivery_city)='' then null
        when upper(trim(delivery_city)) in (
             'DARGANHALLI',
        'SHELAGI',
        'AKKALKOT'
        ) then null

        else initcap(trim(delivery_city))
    end as delivery_city,

    case
        when recipient_name is null then null
        when trim(recipient_name) = '' then null
        else initcap(trim(recipient_name))
    end as recipient_name,
--    case
--    when recipient_name is null then null
--    when trim(recipient_name) = '' then null
--
--    else initcap(
--        regexp_replace(
--            trim(recipient_name),
--            '\\s+',
--            ' '
--        )
--    )
--end as recipient_name,

    case
        when regexp_like(nullif(trim(recipient_phone),''),'^[6-9][0-9]{9}$')
        then trim(recipient_phone)
        else null
    end as recipient_phone,
    delivery_status

from deliveries

),
deduplicated as(
    select * from cleaned_data
    qualify row_number() over(
        partition by delivery_id
        order by expected_delivery_date desc
    )=1
)

select * from deduplicated