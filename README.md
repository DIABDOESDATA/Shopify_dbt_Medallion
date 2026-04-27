# Proof Of Concept

This assessment evaluates proof of concept to build an end-to-end pipeline include **ingestion, transformation, orchestration, and database design** using Shopify-style data (customers, orders, products).

---

## Overview

Build an end-to-end data pipeline: ingest JSONL into Postgres (via Airbyte), define Postgres roles and RBAC, transform data with dbt (staging + order summary mart), and run dbt via GitHub Actions (on PR and on a schedule). The task mirrors a realistic client scenario and tests your ability to make clear design choices and document them.

**Full instructions:** [CHALLENGE.md](CHALLENGE.md) — read this first.

---

## Repository structure

```
.
├── CHALLENGE.md          # Full task list and deliverables
├── README.md             # This file
└── DATA/
    ├── portable_shopify.customers.sample.jsonl
    ├── portable_shopify.orders.sample.jsonl
    ├── portable_shopify.products.sample.jsonl
    ├── METADATA_customers.md
    ├── METADATA_orders.md
    └── METADATA_products.md
```

- **Raw data:** Three JSONL files in `DATA/` (Shopify-style customers, orders, products).
- **Metadata:** See `DATA/METADATA_*.md` for field descriptions and join keys.

---


## Evaluation criteria

| Area | Description |
|------|-------------|
| **Data / pipeline design** | How well the solution handles ingestion (Airbyte → Postgres), schema/namespace choices, and transformation (staging → mart). |
| **Code quality** | Structure, readability, maintainability of dbt models and any scripts; adherence to common DE practices. |
| **System design** | RBAC design (four roles), staging vs production targets, and clarity of documentation. |
| **Completeness** | All deliverables in [CHALLENGE.md](CHALLENGE.md) met; run/validation (dbt run, tests, Actions) succeeds; docs cover run steps and secrets. |
| **Presentation** | If you provide a Loom: clarity and professionalism of the walkthrough. |

---

## Contact

For technical questions about this challenge, reach out to Hussein Diab

---


# Solution Notes

## Data Engineering Assessment

The implementation covers ingestion, transformation, orchestration, and database design using Shopify-style sample data for customers, orders, and products.

## Solution Summary

This solution implements an end-to-end local data pipeline with the following components:

- Airbyte OSS for ingesting JSONL source files into Postgres
- Postgres for raw storage and role-based access control
- dbt Core for staging, intermediate, and mart transformations
- GitHub Actions for automated staging and production dbt runs

### Final Deliverable
- Mart: `order_summary`
- Declared grain: one row per order

---

## Architecture

### Data Flow
1. Shopify-style JSONL files are ingested into Postgres using Airbyte OSS
2. Raw data lands in the `raw` schema
3. dbt transforms raw data into staging, intermediate, and mart layers
4. GitHub Actions runs dbt automatically for staging and production workflows

### Design Choices
- Raw ingestion is kept separate from transformed data by using a dedicated `raw` schema
- Nested source structures are preserved in the raw layer as JSONB where appropriate
- Flattening, light cleaning, and standardization are handled in dbt
- The final mart is designed for order-level analytics and downstream BI consumption

---

## Repository Structure

```text
.
├── CHALLENGE.md
├── README.md
├── DATA/
│   ├── portable_shopify.customers.sample.jsonl
│   ├── portable_shopify.orders.sample.jsonl
│   ├── portable_shopify.products.sample.jsonl
│   ├── METADATA_customers.md
│   ├── METADATA_orders.md
│   └── METADATA_products.md
├── dbt/assessment/
├── scripts/
│   ├── create_roles.sql
│   └── load_sample_raw.py
└── .github/workflows/
    ├── dbt-staging.yml
    └── dbt-prod.yml
```

### Source Data
- `DATA/portable_shopify.customers.sample.jsonl`
- `DATA/portable_shopify.orders.sample.jsonl`
- `DATA/portable_shopify.products.sample.jsonl`

### Metadata
Field descriptions and join guidance are documented in:
- `DATA/METADATA_customers.md`
- `DATA/METADATA_orders.md`
- `DATA/METADATA_products.md`

---

## Raw Layer

Airbyte loads source data into the Postgres `raw` schema.

### Raw Tables
- `raw.customers` — raw Shopify-style customer records
- `raw.orders` — raw Shopify-style order records
- `raw.products` — raw Shopify-style product records

### Nested Data Handling
Nested structures are preserved in the raw layer and transformed downstream in dbt. This keeps ingestion simple and reproducible while allowing transformation logic to remain explicit and version-controlled.

---

## Postgres Roles and RBAC

Four roles are defined to separate responsibilities across ingestion, transformation, development, and consumption.

### Roles
- `developer`
  - Purpose: development and staging access for engineering work
  - Intended access: read/write in non-production development and staging schemas

- `airbyte`
  - Purpose: ingestion role for Airbyte
  - Intended access: write to the `raw` schema only

- `dbt`
  - Purpose: transformation role for dbt
  - Intended access: read from `raw` and write to transformation / analytics schemas

- `bi`
  - Purpose: read-only analytics access for BI tools
  - Intended access: read-only access to the final analytics / mart layer

### Role Script
- `scripts/create_roles.sql`

This script contains the role creation and grants required to apply the RBAC design.

---

## dbt Project

### Project Path
- `dbt/assessment`

### Environments
The dbt project supports separate staging and production targets:

- Staging target: `dev`
- Production target: `prod`

### dbt Layers
- Staging: source cleanup, renaming, standardization
- Intermediate: supporting transformations and flattening logic
- Mart: final analytical output

### Final Mart
- Model: `order_summary`
- Grain: one row per order

### Example Columns in `order_summary`
- `order_id`
- `customer_id`
- `order_date`
- `financial_status`
- `fulfillment_status`
- `total_amount`
- `line_item_count`
- `discount_amount`

---

## How to Run Locally

### 1) Airbyte

Airbyte OSS is intended to be run locally using `abctl`.

#### Start Airbyte
```bash
abctl local install
```

#### Airbyte Setup
Configure:
- 3 file-based JSONL sources
- 1 Postgres destination
- Destination schema: `raw`

#### Source Files
Use the following files from the `DATA/` folder:
- `portable_shopify.customers.sample.jsonl`
- `portable_shopify.orders.sample.jsonl`
- `portable_shopify.products.sample.jsonl`

### 2) dbt

From the dbt project directory:

```bash
cd dbt/assessment
```

#### Run Staging
```bash
dbt build --target dev --profile assessment
```

#### Run Production
```bash
dbt build --target prod --profile assessment
```

---

## dbt Tests and Documentation

The solution includes dbt model documentation and tests for core analytical outputs.

### Included Validation
The final mart should include core tests such as:
- uniqueness
- not null
- relationship validation

### Model Documentation
The `order_summary` model is documented in dbt metadata, including its business purpose and declared grain.

---

## GitHub Actions

Two GitHub Actions workflows are included to automate dbt execution.

### Workflow Files
- `.github/workflows/dbt-staging.yml`
- `.github/workflows/dbt-prod.yml`

### Staging Workflow
- Runs on pull request activity and merge/push to `main`
- Executes dbt against the staging target

### Production Workflow
- Runs on a schedule and can also be triggered manually
- Executes dbt against the production target

### Production Schedule
`0 6 * * *`

---

## GitHub Secrets

The following repository secrets are required for the workflows:

### Staging
- `DBT_STAGING_USER`
- `DBT_STAGING_PASSWORD`
- `DBT_STAGING_DBNAME`

### Production
- `DBT_PROD_USER`
- `DBT_PROD_PASSWORD`
- `DBT_PROD_DBNAME`

These secrets are configured in:

GitHub → Settings → Secrets and variables → Actions

---

## Assumptions

- Airbyte is demonstrated locally rather than deployed to a hosted environment
- GitHub Actions bootstraps sample raw tables using `scripts/load_sample_raw.py`
- The final mart, `order_summary`, is intentionally modeled at one row per order
- Nested structures are preserved in raw ingestion and flattened in dbt rather than during ingestion

---

## Reviewer Notes

### What to Review
- Airbyte ingestion design and raw schema separation
- Postgres RBAC role design
- dbt project structure and target separation
- `order_summary` mart logic and grain
- GitHub Actions workflow configuration and successful runs

### Key Paths
- Airbyte / source data: `DATA/`
- Role grants: `scripts/create_roles.sql`
- Raw data bootstrap for workflows: `scripts/load_sample_raw.py`
- dbt project: `dbt/assessment`
- CI/CD workflows: `.github/workflows/`

---

## Contact

For technical questions about the assessment, please contact Hussein Diab

