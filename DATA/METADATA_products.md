# Products — Metadata

**Source:** Shopify (Portable export). One JSON object per line.

| Field | Type | Notes |
|-------|------|--------|
| `_PORTABLE_EXTRACTED` | string (ISO) | Extract timestamp |
| `ADMIN_GRAPHQL_API_ID` | string | Shopify GID |
| `APP_ID` | string | App identifier |
| `ID` | string | Product ID (e.g. `PROD_3000`) — **primary key** |
| `TITLE` | string | Product title |
| `PRODUCT_TYPE` | string | e.g. Home, Accessories |
| `VENDOR` | string | Brand/vendor |
| `TAGS` | string | Comma-separated |
| `OPTIONS` | array | e.g. Size, Color and values |
| `VARIANTS` | array | SKU-level variants |

**VARIANTS** (nested): `ID` (e.g. `VAR_4000`), `SKU`, `TITLE`, `OPTION1`, `OPTION2`, `PRICE`, `COMPARE_AT_PRICE`, `PRODUCT_ID`, `INVENTORY_QUANTITY`, `CREATED_AT`, `UPDATED_AT` (unix), `WEIGHT`, `WEIGHT_UNIT`, `BARCODE`, `TAXABLE`, `REQUIRES_SHIPPING`.

**Join to orders:** Order `LINE_ITEMS[].PRODUCT_ID` = `ID`; `LINE_ITEMS[].VARIANT_ID` = `VARIANTS[].ID`.
