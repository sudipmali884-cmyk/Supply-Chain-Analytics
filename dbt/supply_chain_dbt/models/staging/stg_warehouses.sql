with warehouses as (
    select * from {{ source('raw','warehouses')}}
),

cleaned_data as(
    select
        case
            when regexp_like (trim(warehouse_id),'^WH[0-9]{6}$')
            then trim(warehouse_id)
            else null
        end as warehouse_id,

        case
            when warehouse_name is null then null
            when trim(warehouse_name) = '' then null
            else initcap(trim(warehouse_name)) -- this will only remove the space begining and end and title capital
--
--            else initcap(regexp_replce(trim(warehouse_name),
--                '\\s+',' '
--            ))--  this will remove extra spaxe inside


        end as warehouse_name,

        case
            when warehouse_type is null then null
            when trim(warehouse_type)='' then null
            when upper(trim(warehouse_type)) in
            (
                   'DISTRIBUTION CENTER',
                    'FULFILLMENT CENTER',
                    'REGIONAL WAREHOUSE',
                    'COLD STORAGE'
            )
            then initcap(trim(warehouse_type))
            else null
        end as warehouse_type,

        case
            when storage_type is null then null
            when trim(storage_type) = '' then null
            when  upper(trim(storage_type)) in (
                 'very hot',
                    'very bad',
                    'unknown',
                    'faltu',
                    'n/a'
            ) then null

            else initcap(trim(storage_type))
        end as storage_type,

        case
            when country is null then null
            when trim(country) ='' then null
            when upper(trim(country)) in (
                'PAKISTAN','IRAN','AMERICA','SOLAPUR'
            ) THEN NULL

            ELSE initcap(regexp_replace(trim(regexp_replace(country,'^\\s*#\\s*|\\s*#\\s*$','')

                                            ),
                                            '\\s+',''
                        )
            )

        end as country,

        state,
        initcap(trim(city)) as city,

--            when city is null then null
--            when trim(city)='' then null
--            else initcap(trim(city))
--              end as city

        case
            -- when postal_code is null then null
            when regexp_like(trim(postal_code),'^[0-9]{6}$')
            then trim(postal_code)
            else null
        end as postal_code,

        capacity_units,

        case
            when phone is null then null
            when (trim(phone))='' then null
            when  regexp_like(trim(phone),'^[0-9]{10}$') then trim(phone)
            else null
        end as phone,

        case
            when warehouse_status is null then null
            when trim(warehouse_status)='' then null
            when upper(trim(warehouse_status)) in (
                 'UNKNOWN',
                    'N/A',
                    'NOT ACTIVE',
                    'DELEIVERED'
            ) then null
            else initcap(trim(warehouse_status))
        end as warehouse_status
    from warehouses

),
deduplicated as(
    select * from cleaned_data
    qualify row_number() over(
        partition by warehouse_id
        order by warehouse_id
    )=1
)
select * from deduplicated