{{
    config(
        materialized='table'
    )
}}

with orders as (

    select
        order_id,
        customer_id,
        order_date,
        status

    from {{ ref('stg_orders') }}

),

final as (

    select
        order_id,
        customer_id,
        order_date,
        status,
        case
            when status = 'completed' then true
            else false
        end as is_completed

    from orders

)

select * from final
