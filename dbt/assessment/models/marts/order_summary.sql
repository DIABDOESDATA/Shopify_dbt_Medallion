with line_items_enriched as (

    select
        li.order_id,
        li.line_item_id,
        li.product_id,
        li.variant_id,
        li.line_item_title,
        li.quantity,
        li.unit_price,
        li.line_amount,
        pv.product_title,
        pv.variant_title
    from {{ ref('int_order_line_items') }} li
    left join {{ ref('int_product_variants') }} pv
        on li.variant_id = pv.variant_id

),

line_rollup as (

    select
        order_id,
        count(distinct line_item_id) as line_item_count,
        sum(quantity) as total_quantity,
        sum(line_amount) as computed_line_amount,
        count(distinct product_id) as distinct_product_count,
        count(distinct variant_id) as distinct_variant_count,
        string_agg(
            distinct coalesce(product_title, line_item_title),
            ', '
        ) as product_titles
    from line_items_enriched
    group by 1

)

select
    o.order_id,
    o.customer_json ->> 'ID' as customer_id,
    o.created_at as order_date,
    o.email as customer_email,
    o.currency,
    o.financial_status,
    o.fulfillment_status,
    o.subtotal_price,
    o.total_tax,
    o.total_discounts as discount_amount,
    o.total_price as total_amount,
    coalesce(lr.line_item_count, 0) as line_item_count,
    coalesce(lr.total_quantity, 0) as total_quantity,
    coalesce(lr.distinct_product_count, 0) as distinct_product_count,
    coalesce(lr.distinct_variant_count, 0) as distinct_variant_count,
    coalesce(lr.computed_line_amount, 0) as computed_line_amount,
    c.tags as customer_tags,
    lr.product_titles,
    o.portable_extracted_at
from {{ ref('stg_orders') }} o
left join line_rollup lr
    on o.order_id = lr.order_id
left join {{ ref('stg_customers') }} c
    on c.customer_id = o.customer_json ->> 'ID'