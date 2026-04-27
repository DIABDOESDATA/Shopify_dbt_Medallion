select
    "ID"::text as product_id,
    "TITLE"::text as product_title,
    "PRODUCT_TYPE"::text as product_type,
    "VENDOR"::text as vendor,
    "TAGS"::text as tags,
    "OPTIONS" as options_json,
    "VARIANTS" as variants_json,
    "_PORTABLE_EXTRACTED"::timestamp as portable_extracted_at,
    "ADMIN_GRAPHQL_API_ID"::text as admin_graphql_api_id,
    "APP_ID"::text as app_id,
    _airbyte_raw_id,
    _airbyte_extracted_at,
    _airbyte_generation_id
from {{ source('raw', 'products') }}