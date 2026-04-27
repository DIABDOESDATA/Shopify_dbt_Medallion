import json
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path

import psycopg2
from psycopg2.extras import Json

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "DATA"

conn = psycopg2.connect(
    host=os.environ["PGHOST"],
    port=os.environ["PGPORT"],
    dbname=os.environ["PGDATABASE"],
    user=os.environ["PGUSER"],
    password=os.environ["PGPASSWORD"],
)
conn.autocommit = True


def now_utc():
    return datetime.now(timezone.utc)


def create_schemas(cur):
    cur.execute("create schema if not exists raw;")
    cur.execute("create schema if not exists analytics_staging;")
    cur.execute("create schema if not exists analytics;")


def create_tables(cur):
    cur.execute("""
    create table if not exists raw.customers (
      _airbyte_raw_id varchar not null,
      _airbyte_extracted_at timestamptz not null,
      _airbyte_meta jsonb not null default '{}'::jsonb,
      _airbyte_generation_id bigint not null,
      "ID" varchar,
      "TAGS" varchar,
      "APP_ID" varchar,
      "ADDRESSES" jsonb,
      "CREATED_AT" bigint,
      "_PORTABLE_EXTRACTED" varchar,
      "ADMIN_GRAPHQL_API_ID" varchar
    );
    """)

    cur.execute("""
    create table if not exists raw.products (
      _airbyte_raw_id varchar not null,
      _airbyte_extracted_at timestamptz not null,
      _airbyte_meta jsonb not null default '{}'::jsonb,
      _airbyte_generation_id bigint not null,
      "ADMIN_GRAPHQL_API_ID" varchar,
      "APP_ID" varchar,
      "ID" varchar,
      "TITLE" varchar,
      "PRODUCT_TYPE" varchar,
      "VENDOR" varchar,
      "TAGS" varchar,
      "OPTIONS" jsonb,
      "VARIANTS" jsonb,
      "_PORTABLE_EXTRACTED" varchar
    );
    """)

    cur.execute("""
    create table if not exists raw.orders (
      _airbyte_raw_id varchar not null,
      _airbyte_extracted_at timestamptz not null,
      _airbyte_meta jsonb not null default '{}'::jsonb,
      _airbyte_generation_id bigint not null,
      "_PORTABLE_EXTRACTED" varchar,
      "ID" varchar,
      "CREATED_AT" varchar,
      "EMAIL" varchar,
      "CURRENCY" varchar,
      "FINANCIAL_STATUS" varchar,
      "FULFILLMENT_STATUS" varchar,
      "TOTAL_PRICE" numeric,
      "SUBTOTAL_PRICE" numeric,
      "TOTAL_TAX" numeric,
      "TOTAL_DISCOUNTS" numeric,
      "CUSTOMER" jsonb,
      "LINE_ITEMS" jsonb,
      "REFUNDS" jsonb,
      "BILLING_ADDRESS" jsonb,
      "SHIPPING_ADDRESS" jsonb,
      "DISCOUNT_CODES" jsonb,
      "SHIPPING_LINES" jsonb
    );
    """)


def truncate_tables(cur):
    cur.execute("truncate table raw.customers;")
    cur.execute("truncate table raw.products;")
    cur.execute("truncate table raw.orders;")


def insert_customers(cur):
    path = DATA_DIR / "portable_shopify.customers.sample.jsonl"
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            r = json.loads(line)
            cur.execute("""
                insert into raw.customers (
                  _airbyte_raw_id, _airbyte_extracted_at, _airbyte_meta, _airbyte_generation_id,
                  "ID", "TAGS", "APP_ID", "ADDRESSES", "CREATED_AT",
                  "_PORTABLE_EXTRACTED", "ADMIN_GRAPHQL_API_ID"
                ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                str(uuid.uuid4()), now_utc(), Json({}), 1,
                r.get("ID"), r.get("TAGS"), r.get("APP_ID"), Json(r.get("ADDRESSES")),
                r.get("CREATED_AT"), r.get("_PORTABLE_EXTRACTED"), r.get("ADMIN_GRAPHQL_API_ID")
            ))


def insert_products(cur):
    path = DATA_DIR / "portable_shopify.products.sample.jsonl"
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            r = json.loads(line)
            cur.execute("""
                insert into raw.products (
                  _airbyte_raw_id, _airbyte_extracted_at, _airbyte_meta, _airbyte_generation_id,
                  "ADMIN_GRAPHQL_API_ID", "APP_ID", "ID", "TITLE", "PRODUCT_TYPE",
                  "VENDOR", "TAGS", "OPTIONS", "VARIANTS", "_PORTABLE_EXTRACTED"
                ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                str(uuid.uuid4()), now_utc(), Json({}), 1,
                r.get("ADMIN_GRAPHQL_API_ID"), r.get("APP_ID"), r.get("ID"), r.get("TITLE"),
                r.get("PRODUCT_TYPE"), r.get("VENDOR"), r.get("TAGS"),
                Json(r.get("OPTIONS")), Json(r.get("VARIANTS")), r.get("_PORTABLE_EXTRACTED")
            ))


def insert_orders(cur):
    path = DATA_DIR / "portable_shopify.orders.sample.jsonl"
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            r = json.loads(line)
            cur.execute("""
                insert into raw.orders (
                  _airbyte_raw_id, _airbyte_extracted_at, _airbyte_meta, _airbyte_generation_id,
                  "_PORTABLE_EXTRACTED", "ID", "CREATED_AT", "EMAIL", "CURRENCY",
                  "FINANCIAL_STATUS", "FULFILLMENT_STATUS", "TOTAL_PRICE", "SUBTOTAL_PRICE",
                  "TOTAL_TAX", "TOTAL_DISCOUNTS", "CUSTOMER", "LINE_ITEMS", "REFUNDS",
                  "BILLING_ADDRESS", "SHIPPING_ADDRESS", "DISCOUNT_CODES", "SHIPPING_LINES"
                ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                str(uuid.uuid4()), now_utc(), Json({}), 1,
                r.get("_PORTABLE_EXTRACTED"), r.get("ID"), r.get("CREATED_AT"), r.get("EMAIL"),
                r.get("CURRENCY"), r.get("FINANCIAL_STATUS"), r.get("FULFILLMENT_STATUS"),
                r.get("TOTAL_PRICE"), r.get("SUBTOTAL_PRICE"), r.get("TOTAL_TAX"),
                r.get("TOTAL_DISCOUNTS"), Json(r.get("CUSTOMER")), Json(r.get("LINE_ITEMS")),
                Json(r.get("REFUNDS")), Json(r.get("BILLING_ADDRESS")),
                Json(r.get("SHIPPING_ADDRESS")), Json(r.get("DISCOUNT_CODES")),
                Json(r.get("SHIPPING_LINES"))
            ))


with conn.cursor() as cur:
    create_schemas(cur)
    create_tables(cur)
    truncate_tables(cur)
    insert_customers(cur)
    insert_products(cur)
    insert_orders(cur)

conn.close()
print("Loaded sample raw data.")