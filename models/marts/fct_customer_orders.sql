{{
    config(
        materialized='table'
    )
}}

with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

order_summary as (

    select
        customer_id,
        count(order_id)                                         as total_orders,
        min(order_date)                                         as first_order_date,
        max(order_date)                                         as most_recent_order_date,
        sum(case when status = 'completed' then 1 else 0 end)  as completed_orders,
        sum(case when status = 'returned' then 1 else 0 end)   as returned_orders,
        round(
            100.0 * sum(case when status = 'completed' then 1 else 0 end)
            / nullif(count(order_id), 0),
            1
        )                                                       as completion_rate_pct

    from orders

    group by 1

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        coalesce(order_summary.total_orders, 0)          as total_orders,
        coalesce(order_summary.completed_orders, 0)      as completed_orders,
        coalesce(order_summary.returned_orders, 0)       as returned_orders,
        order_summary.completion_rate_pct,
        order_summary.first_order_date,
        order_summary.most_recent_order_date,
        case
            when order_summary.total_orders >= 3 then 'High Value'
            when order_summary.total_orders = 2  then 'Returning'
            when order_summary.total_orders = 1  then 'New'
            else 'No Orders'
        end                                              as customer_segment

    from customers

    left join order_summary using (customer_id)

)

select * from final
