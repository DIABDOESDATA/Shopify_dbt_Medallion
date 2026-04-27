# Customers — Metadata

**Source:** Shopify (Portable export). One JSON object per line.

| Field | Type | Notes |
|-------|------|--------|
| `_PORTABLE_EXTRACTED` | string (ISO) | Extract timestamp |
| `ADMIN_GRAPHQL_API_ID` | string | Shopify GID |
| `APP_ID` | string | App identifier |
| `ID` | string | Customer ID (e.g. `CUST_1000`) — **primary key** |
| `CREATED_AT` | integer | Unix timestamp |
| `TAGS` | string | Comma-separated (e.g. vip, loyal) |
| `ADDRESSES` | array | One or more address objects |

**ADDRESSES** (nested): `ID`, `ADDRESS1`, `ADDRESS2`, `CITY`, `COMPANY`, `COUNTRY`, `COUNTRY_CODE`, `CUSTOMER_ID`, `DEFAULT` (bool), `FIRST_NAME`, `LAST_NAME`, `NAME`, `PHONE`, `PROVINCE`, `PROVINCE_CODE`, `ZIP`, `LATITUDE`, `LONGITUDE`.

**Join to orders:** `CUSTOMER.ID` in orders = `ID` here.
