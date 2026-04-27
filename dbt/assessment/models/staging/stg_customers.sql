select
    "ID"::text as customer_id,
    "APP_ID"::text as app_id,
    "TAGS"::text as tags,
    "ADDRESSES" as addresses_json,
    to_timestamp("CREATED_AT") as created_at,
    "_PORTABLE_EXTRACTED"::timestamp as portable_extracted_at,
    "ADMIN_GRAPHQL_API_ID"::text as admin_graphql_api_id,
    _airbyte_raw_id,
    _airbyte_extracted_at,
    _airbyte_generation_id
from {{ source('raw', 'customers') }}