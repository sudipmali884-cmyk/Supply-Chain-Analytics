{{ config (
    materialized='table'
)}}

with suppliers as (
    select * from {{ ref('stg_suppliers')}}
),

final as (
    select
        supplier_id,
        supplier_name,
        supplier_type,
        contact_person,
        email,
        phone,
        country,
        state,
        city,
        payment_terms,
        lead_time_days,
        supplier_rating,
        supplier_status,

        -- supplier type category

        case
            when supplier_type is null
                then 'Unknown'
            when upper(trim(supplier_type)) = 'MANUFACTURER'
                then 'Manufacturer'
            when upper(trim(supplier_type)) = 'DISTRIBUTOR'
            then 'Distributor'

            when upper(trim(supplier_type)) = 'WHOLESALER'
                then 'Wholesaler'

            when upper(trim(supplier_type)) = 'RETAILER'
                then 'Retailer'

            else 'Other Supplier'

        end as supplier_type_category,


        case
            when supplier_rating is null then 'Unknown'
            when supplier_rating >=5  then 'Excellent'
            when supplier_rating >=4  then 'Good'

            when supplier_rating =3 then 'Average'
            when supplier_rating =2 then 'Poor'

            else 'Very Poor'
        end as supplier_rating_category,

         case
            when supplier_rating is null then null
            when supplier_rating >= 5  then 5
            when supplier_rating >= 4  then 4
            when supplier_rating =3 then 3
            when supplier_rating =2 then 2
            else 1
        end as supplier_rating_score,


        case
            when supplier_rating >= 4
            and lead_time_days <= 15
                then 'High Performer'
            when supplier_rating >= 4
            and lead_time_days <= 30
                then 'Reliable'
            when supplier_rating >= 3
            and lead_time_days <= 30
                then  'Standard Performer'
            when supplier_rating <= 2
             or lead_time_days >45
                then 'Low Performer'
            else 'Average Performer'
        end as supplier_performance_category,
        -- ====================================================
        -- SUPPLIER RISK CATEGORY
        -- ====================================================

        case

            when supplier_status is null

                then 'Unknown Risk'

            when upper(trim(supplier_status)) != 'ACTIVE'

                then 'High Risk'

            when supplier_rating <= 2

                then 'High Risk'

            when lead_time_days > 45

                then 'High Risk'

            when supplier_rating = 3
             or lead_time_days > 30

                then 'Medium Risk'

            else 'Low Risk'

        end as supplier_risk_category,

        -- payment term category

        case
            when payment_terms is null
                then 'Unknown'
            when upper(trim(payment_terms)) like '%IMMEDIATE%'
                then 'Immediate Payment'

            when upper(trim(payment_terms)) like '%15%'
                then 'Net 15'

            when upper(trim(payment_terms)) like '%30%'
                then 'Net 30'

            when upper(trim(payment_terms)) like '%45%'
                then 'Net 45'

            when upper(trim(payment_terms)) like '%60%'
                then 'Net 60'

            when upper(trim(payment_terms)) like '%90%'
                then 'Net 90'

            else 'Other Terms'

        end as payment_term_category,

                -- ====================================================
        -- ACTIVE SUPPLIER FLAG
        -- ====================================================

        case

            when upper(trim(supplier_status)) = 'ACTIVE'
                then 1

            else 0

        end as is_active_supplier,


        -- ====================================================
        -- HIGH RATED SUPPLIER FLAG
        -- ====================================================

        case

            when supplier_rating >= 4
                then 1

            else 0

        end as is_high_rated_supplier,


        -- ====================================================
        -- LONG LEAD TIME FLAG
        -- ====================================================

        case

            when lead_time_days > 45
                then 1

            else 0

        end as is_long_lead_supplier,

                -- ====================================================
        -- SUPPLIER QUALITY FLAG
        --
        -- Identifies suspicious / incomplete records.
        -- ====================================================

        case

            when supplier_id is null

                then 'Invalid Supplier ID'

            when supplier_name is null

                then 'Missing Supplier Name'

            when supplier_name = ''

                then 'Missing Supplier Name'

            when supplier_type is null

                then 'Missing Supplier Type'

            when country is null

                then 'Missing Country'

            when lead_time_days is null

                then 'Missing Lead Time'

            when lead_time_days < 0

                then 'Invalid Lead Time'

            when supplier_rating is null

                then 'Missing Rating'

            when supplier_rating < 1
              or supplier_rating > 5

                then 'Invalid Rating'

            else 'Valid Supplier'

        end as supplier_quality_flag

    from suppliers
)

select * from final
