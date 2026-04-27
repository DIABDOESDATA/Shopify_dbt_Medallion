select
    p.product_id,
    p.product_title,
    p.product_type,
    p.vendor as product_vendor,
    v.value ->> 'ID' as variant_id,
    v.value ->> 'SKU' as sku,
    v.value ->> 'TITLE' as variant_title,
    v.value ->> 'OPTION1' as option1,
    v.value ->> 'OPTION2' as option2,
    case
        when nullif(v.value ->> 'PRICE', '') is not null
            then (v.value ->> 'PRICE')::numeric
        else null
    end as variant_price,
    case
        when nullif(v.value ->> 'INVENTORY_QUANTITY', '') is not null
            then (v.value ->> 'INVENTORY_QUANTITY')::int
        else null
    end as inventory_quantity
from {{ ref('stg_products') }} p
cross join lateral jsonb_array_elements(p.variants_json) as v(value)