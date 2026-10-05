with products as(
    select * from {{ source('raw','products')}}
),
cleaned_data as (
    select
        case
            when regexp_like(nullif(trim(product_id),''),
            '^PRD[0-9]{6}$')
            then nullif(trim(product_id),'')
            else null
        end as product_id,
--        nullif(trim(product_name),'') as product_name,
        CASE
            WHEN product_name IS NULL THEN NULL
            WHEN TRIM(product_name) = '' THEN NULL
            ELSE INITCAP(TRIM(product_name))
        END AS product_name,
--        TRIM = remove outside spaces
--REGEXP_REPLACE(..., '\\s+', ' ') = convert multiple spaces inside to one space.
--        CASE
--            WHEN product_name IS NULL THEN NULL
--            WHEN TRIM(product_name) = '' THEN NULL
--            ELSE INITCAP(
--                REGEXP_REPLACE(TRIM(product_name), '\\s+', ' ')
--            )
--        END AS product_name
        nullif(initcap(trim(category)),'') as category,
        nullif(initcap(trim(sub_category)),'') as sub_category,

        case
            when
                brand is null then null
            when trim(brand)='' then null
            else initcap(trim(brand))
        end as brand,

        case
            when try_to_decimal(unit_cost) is null then null
            when try_to_decimal(unit_cost) <=0 then null
            when try_to_decimal(unit_cost) > 1000000 then null
            else try_to_decimal(unit_cost)
        end as unit_cost,

        case
            when try_to_decimal(selling_price) is null then null
            when try_to_decimal(selling_price)  <= 0 then null
            when try_to_decimal(selling_price)  > 1000000 then null
            else try_to_decimal(selling_price)
        end as selling_price,

        case
            when (reorder_level) is null then null
            when trim(reorder_level) = '' then null
            when (reorder_level)  <=0 then null
            when (reorder_level)  >= 999999 then null
            else (reorder_level)
        end as reorder_level,



        case
            when unit_of_measure is null then null
            when trim(unit_of_measure)='' then null
            when upper(trim(unit_of_measure)) in ('UNKNOWN','N/A','UNIT','KG') then null
            when upper(trim(unit_of_measure)) ='PIECES' THEN 'PCS'
            ELSE upper(trim(unit_of_measure))
        end as unit_of_measure,


        case
            when upper(trim(product_status)) in ('ACTIVE','INACTIVE','DISCONTINUED')
            then initcap(trim(product_status))
            else 'Unknown'
        end as product_status
    from products
),
deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
        partition by product_id
        order by product_id
    ) = 1
)
select * from deduplicated