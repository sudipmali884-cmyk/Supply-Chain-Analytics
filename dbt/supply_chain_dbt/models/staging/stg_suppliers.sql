with suppliers as(
    select * from  {{ source('raw','suppliers')}}
),
cleaned_data as(
    select
        case
            when regexp_like(trim(supplier_id),'^SUP[0-9]{6}$')
                then trim(supplier_id)
            else null
        end as supplier_id,

        case
            when supplier_name is null then null
            when trim(supplier_name)='' then null
            else initcap(regexp_replace(trim(supplier_name),
            '\\s+',' '))
        end as supplier_name,

        case
            when supplier_type is null then null
            when trim(supplier_type)='' then null
            else initcap(regexp_replace(trim(supplier_type),'\\s+',' '))
        end as supplier_type,

        case
            when contact_person is null then null
            when trim(contact_person)='' then null
            else initcap(regexp_replace(
                trim(contact_person),
                '\\s+',' '
            ))
        end as contact_person,

        case
            when email is null then null
            when trim(email) = '' then null
            when lower(trim(email)) in ('unknown','n/a','not_available') then null
            when regexp_like(lower(trim(email)),'^[a-z0-9]+@[a-z0-9]+.[a-z]{2,}$')
            then lower(trim(email))
            else null
        end as email,

        case
            when phone is null then null
            when trim(phone)='' then null
            when lower(trim(phone)) in ('UNKNOWN','N/A') THEN null
            when regexp_like(trim(phone),'^[6-9][0-9]{9}$')
            and length(trim(phone)) between 10 and 12
            and regexp_like(trim(phone),'.*[0-9].*')
            then trim(phone)
            else null
        end as phone,

        case
            when country is null then null
            when trim(country) = '' then null
            when lower(trim(country)) in (
            'pakistan','bhikaristan','engrez','dakshin korea', 'None'
            )
            then null
            else initcap(regexp_replace(trim(country),
            '\\s+',' '))

        end as country,

        case
            when state is null then null
            when trim(state)= '' then null
            when upper(trim(state)) in ('UNKNOWN','N/A') THEN NULL
            WHEN LOWER(TRIM(state)) = 'kabul' then null
            else initcap(regexp_replace(trim(state),'\\s+',' '))
        end as state,

        case
            when city is null then null
            when trim(city) = '' then null
            when lower(trim(city)) in (
                'darganhalli',
                'mulagav',
                'shelagi',
                'saat rssata'
            )
            then null
            else initcap(regexp_replace(trim(city),'\\s+',' '))
        end as city,
        case
            when payment_terms is null then null
            when trim(payment_terms) = '' then null
--            else initcap(regexp_replace(
--                trim(payment_terms),'\\s+',' '
--            ))
            else initcap(trim(payment_terms))
        end as payment_terms,
        lead_time_days,

        case
            when supplier_rating is null then null
            when supplier_rating < 0 then null
            when supplier_rating > 5 then null
            else supplier_rating
        end as supplier_rating,

        supplier_status

    from suppliers

),
deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
        partition by supplier_id
        order by supplier_id
    )=1
)

select * from deduplicated
