with customers as (
    select * from {{ ref ('stg_pierrealex_shop_customers')}}
),

orders as (
    select * from {{ ref('stg_pierrealex_shop_orders')}}
),

payments as (
    select * from {{ ref('stg_strip_payments')}}
),

customer_payments as (
    select
        orders.order_id,
        orders.customer_id,
        payments.amount
    
    from orders

    left join payments using (order_id)
),

customer_payments_2 as (
    select
        customer_id,
        sum(amount) as lifetime_value
    from customer_payments
    group by 1
),

customer_orders as (

    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_id) as most_recent_order_date,
        count(order_id) as number_of_orders
    
    from orders

    group by 1
),



final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        customer_payments_2.lifetime_value
    
    from customers

    left join customer_orders using (customer_id)
    left join customer_payments_2 using (customer_id)
)

select * from final
