{{ config(materialized='table')}}
with warehouses as (
    select * from {{ ref('stg_warehouses')}}
),

final as (
    select
        warehouse_id,
        warehouse_name,
        warehouse_type,
        storage_type,
        country,
        state,
        city,
        postal_code,
        capacity_units,
        phone,
        warehouse_status,
        case
            when upper(trim(warehouse_status))='ACTIVE' then 1
            else 0
        end as is_active,

        CASE
            when warehouse_type is null then 'Unknown'

            WHEN UPPER(TRIM(warehouse_type))
                = 'DISTRIBUTION CENTER'
                THEN 'Distribution Center'

            WHEN UPPER(TRIM(warehouse_type))
                = 'FULFILLMENT CENTER'
                THEN 'Fulfillment Center'

            WHEN UPPER(TRIM(warehouse_type))
                = 'REGIONAL WAREHOUSE'
                THEN 'Regional Warehouse'

            WHEN UPPER(TRIM(warehouse_type))
                = 'COLD STORAGE'
                THEN 'Cold Storage'

            ELSE 'Other'

        END AS warehouse_category,

        case
            when storage_type is null then 'Unknown'
            when upper(trim(storage_type)) in ('GENERAL','GENERAL STORAGE')
                THEN 'General Storage'
            when upper(trim(storage_type)) in  ('COLD','COLD STORAGE')
                then 'Cold storage'
            when upper(trim(storage_type))
                in ('HAZARDOUS', 'HAZMAT')

                then 'Hazardous Storage'

            when upper(trim(storage_type))
                in ('CONTROLLED', 'CONTROLLED STORAGE')

                then 'Controlled Storage'

            else 'Specialized Storage'

        end as storage_category,


        case
            when capacity_units is null then 'Unknown'
            when capacity_units < 10000 then 'Small'
            when capacity_units < 50000 then 'Medium'
            when capacity_units < 150000 then 'Large'
            when capacity_units <= 300000 then 'Very Large'
            else 'Mega Warehouse'
        end as capacity_category,
                -- ====================================================
        -- CAPACITY BAND
        -- ====================================================

        case

            when capacity_units is null
                then 'Unknown'

            when capacity_units < 25000
                then 'Under 25K'

            when capacity_units < 50000
                then '25K - 50K'

            when capacity_units < 100000
                then '50K - 100K'

            when capacity_units < 250000
                then '100K - 250K'

            when capacity_units < 500000
                then '250K - 500K'

            else '500K+'

        end as capacity_band,

                -- ====================================================
        -- WAREHOUSE SCALE
        -- ====================================================

        case

            when capacity_units is null

                then 'Unknown'

            when capacity_units <= 50000

                then 'Local'

            when capacity_units <= 150000

                then 'Regional'

            when capacity_units <= 300000

                then 'National'

            else 'Large Scale'

        end as warehouse_scale,

                -- ====================================================
        -- COUNTRY REGION
        -- ====================================================

        case

            when country is null

                then 'Unknown'

            when upper(trim(country)) = 'INDIA'

                then 'India'

            when upper(trim(country))
                in (
                    'CHINA',
                    'SINGAPORE',
                    'UNITED ARAB EMIRATES'
                )

                then 'Asia'

            when upper(trim(country))
                in (
                    'UNITED STATES',
                    'CANADA'
                )

                then 'North America'

            when upper(trim(country))
                in (
                    'UNITED KINGDOM',
                    'GERMANY',
                    'FRANCE'
                )

                then 'Europe'

            else 'Other Region'

        end as geographic_region,

        -- indian location flag
        case
            when upper(trim(country))='INDIA'
                then 1
            else 0
        end as is_india_warehouse,

        -- active warehouse flag

        case
            when upper(trim(warehouse_status))='ACTIVE'
                then 1
                else 0
        end as is_active_warehouse,

                -- ====================================================
        -- OPERATIONAL STATUS CATEGORY
        -- ====================================================

        case

            when warehouse_status is null

                then 'Unknown'

            when upper(trim(warehouse_status)) = 'ACTIVE'

                then 'Operational'

            when upper(trim(warehouse_status))
                in ('INACTIVE', 'CLOSED')

                then 'Non Operational'

            when upper(trim(warehouse_status))
                in ('MAINTENANCE', 'UNDER MAINTENANCE')

                then 'Under Maintenance'

            else 'Other Status'

        end as operational_status_category,

               -- ====================================================
        -- WAREHOUSE ROLE
        -- ====================================================

        case

            when upper(trim(warehouse_type))
                = 'DISTRIBUTION CENTER'

                then 'Distribution'

            when upper(trim(warehouse_type))
                = 'FULFILLMENT CENTER'

                then 'Order Fulfillment'

            when upper(trim(warehouse_type))
                = 'REGIONAL WAREHOUSE'

                then 'Regional Distribution'

            when upper(trim(warehouse_type))
                = 'COLD STORAGE'

                then 'Temperature Controlled'

            else 'General Storage'

        end as warehouse_role,

        -- capacity priority

        case

            when capacity_units >= 150000
            and upper(trim(warehouse_status)) = 'ACTIVE'

                then 'High Capacity'

            when capacity_units >= 50000
            and upper(trim(warehouse_status)) = 'ACTIVE'

            then 'Standard Capacity'

            when capacity_units >= 30000
            and upper(trim(warehouse_status)) = 'ACTIVE'
                then 'Critical Capacity'
            when upper(trim(warehouse_status)) != 'ACTIVE'

                then 'Non Operational'

            else 'Low Capacity'

        end as capacity_priority,

                -- ====================================================
        -- STORAGE SPECIALIZATION FLAG
        -- ====================================================

        case

            when upper(trim(storage_type))
                in (
                    'COLD',
                    'COLD STORAGE',
                    'HAZARDOUS',
                    'HAZMAT',
                    'CONTROLLED',
                    'CONTROLLED STORAGE'
                )

                then 1

            else 0

        end as is_specialized_storage,

        -- large warehouse flag
        case
        when
            capacity_units > 150000
            then 1
            else 0
        end as is_large_warehouse,

                -- ====================================================
        -- WAREHOUSE QUALITY FLAG
        -- ====================================================

        case

            when warehouse_id is null

                then 'Invalid Warehouse ID'

            when warehouse_name is null
              or trim(warehouse_name) = ''

                then 'Missing Warehouse Name'

            when warehouse_type is null
              or trim(warehouse_type) = ''

                then 'Missing Warehouse Type'

            when country is null
              or trim(country) = ''

                then 'Missing Country'

            when state is null
              or trim(state) = ''

                then 'Missing State'

            when city is null
              or trim(city) = ''

                then 'Missing City'

            when capacity_units is null

                then 'Missing Capacity'

            when capacity_units <= 0

                then 'Invalid Capacity'

            else 'Valid Warehouse'

        end as warehouse_quality_flag


    from warehouses

)
select * from final