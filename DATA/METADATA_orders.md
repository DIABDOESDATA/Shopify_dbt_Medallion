# Orders — Metadata

**Source:** Shopify (Portable export). One JSON object per line.

| Field | Type | Notes |
|-------|------|--------|
| `_PORTABLE_EXTRACTED` | string (ISO) | Extract timestamp |
| `ID` | string | Order ID (e.g. `ORD_5000`) — **primary key** |
| `CREATED_AT` | string | ISO datetime |
| `EMAIL` | string | Contact email |
| `CURRENCY` | string | e.g. USD |
| `FINANCIAL_STATUS` | string | paid, pending, refunded |
| `FULFILLMENT_STATUS` | string | fulfilled, unfulfilled, partial |
| `TOTAL_PRICE`, `SUBTOTAL_PRICE`, `TOTAL_TAX`, `TOTAL_DISCOUNTS` | number | Order totals |
| `CUSTOMER` | object | Nested; `CUSTOMER.ID` = customer ID |
| `LINE_ITEMS` | array | Order line items |
| `REFUNDS` | array | Refund records |
| `BILLING_ADDRESS`, `SHIPPING_ADDRESS` | object | Address blocks |
| `DISCOUNT_CODES` | array | Applied discount codes |
| `SHIPPING_LINES` | array | Shipping method and price |

**LINE_ITEMS** (nested): `ID`, `PRODUCT_ID`, `VARIANT_ID`, `QUANTITY`, `PRICE`, `SKU`, `TITLE`, `VENDOR`, `DISCOUNT_ALLOCATIONS`, `TAX_LINES`.

**Joins:** `CUSTOMER.ID` → customers.`ID`; line item `PRODUCT_ID` → products; `VARIANT_ID` → product variants.
