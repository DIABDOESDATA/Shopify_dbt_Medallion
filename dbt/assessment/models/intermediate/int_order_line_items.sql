select
    o.order_id,
    o.customer_json ->> 'ID' as customer_id,
    o.created_at as order_date,
    o.financial_status,
    o.fulfillment_status,
    li.value ->> 'ID' as line_item_id,
    li.value ->> 'PRODUCT_ID' as product_id,
    li.value ->> 'VARIANT_ID' as variant_id,
    li.value ->> 'SKU' as sku,
    li.value ->> 'TITLE' as line_item_title,
    li.value ->> 'VENDOR' as vendor,
    coalesce((li.value ->> 'QUANTITY')::int, 0) as quantity,
    coalesce((li.value ->> 'PRICE')::numeric, 0) as unit_price,
    coalesce((li.value ->> 'QUANTITY')::int, 0) * coalesce((li.value ->> 'PRICE')::numeric, 0) as line_amount
from {{ ref('stg_orders') }} o
cross join lateral jsonb_array_elements(o.line_items_json) as li(value)