# healthcare-data-engineering-project

# Healthcare Claims Coverage Validation Pipeline

## Overview

This project simulates a real-world healthcare data engineering workflow for validating medical claim coverage against member eligibility periods.

Healthcare insurers and analytics teams frequently need to ensure that claims were submitted during valid coverage periods. Claims that occur outside eligibility coverage may represent data quality issues, billing errors, or potential financial exposure.

This project demonstrates how data engineers can build a SQL-based transformation pipeline to detect uncovered claims and summarize financial exposure at the member level.

Key concepts demonstrated include:
	•	Relational data modeling
	•	Temporal joins using coverage periods
	•	Aggregation at multiple grains
	•	Layered transformation architecture
	•	Data quality validation

⸻

## Data Model

The project uses three core tables that represent common healthcare entities.

### Members

Represents insured individuals.

Grain

1 row per member

Example fields
	•	member_id
	•	first_name
	•	last_name
	•	dob
	•	gender

⸻

### Eligibility

Represents member coverage periods.

Members may have multiple eligibility segments depending on plan changes or coverage gaps.

Grain

1 row per member per plan per coverage period

Example fields
	•	eligibility_id
	•	member_id
	•	plan_id
	•	effective_date
	•	end_date
	•	member_status

⸻

### Claims

Represents medical claims submitted for healthcare services.

Grain

1 row per claim

Example fields
	•	claim_id
	•	member_id
	•	service_date
	•	paid_amount
	•	status

⸻

## Architecture Overview

The pipeline validates claim coverage by comparing claim service dates against member eligibility periods.

Data flows through a layered transformation architecture.

Raw Tables
↓
Eligibility + Claims Temporal Join
↓
Coverage Validation Logic
↓
Member-Level Aggregation

Data Flow

members
    ↓
eligibility
    ↓
claims
    ↓
coverage validation logic
    ↓
fct_member_claim_coverage_summary

This architecture allows claim-level validation logic to feed aggregated analytics models used for reporting and monitoring financial exposure.

⸻

## Transformation Architecture

The project follows a layered transformation pattern inspired by modern analytics engineering practices.

models/
  healthcare/
    staging/
    intermediate/
    marts/

### Staging Layer

Standardizes source data and prepares base datasets for transformation.

Example models:
	•	stg_members
	•	stg_claims
	•	stg_eligibility

⸻

### Intermediate Layer

Implements business logic and relationships between datasets.

Example transformation:

claims_coverage_check

This logic determines whether a claim occurred during a valid eligibility period.

⸻

### Mart Layer

Produces analytics-ready datasets for reporting and analysis.

Current model:

- fct_claim_coverage_validation
- fct_member_claim_coverage_summary

⸻
#### Model: fct_claim_coverage_validation

**Grain**

1 row per claim

**Purpose**

Validates whether each claim matches zero, one, or multiple eligibility segments based on member coverage periods.

This model is used to classify claims as:

- `COVERED`
- `UNCOVERED`
- `AMBIGUOUS`

It also derives a risk classification to highlight potentially problematic paid claims.

**Key fields**

- claim_id
- member_id
- service_date
- paid_amount
- status
- match_count
- coverage_status
- claim_risk_level

**Business logic**

A claim is matched to eligibility using a temporal join:

`service_date BETWEEN eligibility.effective_date AND eligibility.end_date`

Coverage classification rules:

- `match_count = 0` → `UNCOVERED`
- `match_count = 1` → `COVERED`
- `match_count > 1` → `AMBIGUOUS`

Risk classification rules:

- paid claims with `UNCOVERED` or `AMBIGUOUS` coverage status are classified as `HIGH_RISK`
- all other claims are classified as `LOW_RISK`


##### Model: fct_member_claim_coverage_summary

**Grain**

1 row per member

**Purpose**

Summarizes claim activity and financial exposure at the member level using the claim-level validation model as the source.

This model aggregates validated claim records to produce member-level metrics such as:

- total_claim_count
- uncovered_claim_count
- total_paid_amount
- uncovered_paid_amount

This model is built from `fct_claim_coverage_validation` so that each claim contributes only once, even when eligibility overlaps create ambiguous claim attribution.

⸻

## Example Business Questions

This project enables analysis such as:
	•	Which members had claims submitted outside eligibility coverage?
	•	What is the financial exposure from uncovered claims?
	•	Which members have the highest uncovered claim risk?

⸻

## Validation Tests

The project includes SQL-based validation tests to verify both claim-level and member-level models.

### Claim-level tests
- `claim_id` is unique
- `match_count` maps correctly to `coverage_status`
- uncovered paid claims are classified as `HIGH_RISK`
- ambiguous paid claims are classified as `HIGH_RISK`

### Member-level tests
- `member_id` is unique
- `uncovered_paid_amount` never exceeds `total_paid_amount`
- members with zero claims have zero-valued metrics

⸻

## Technology Stack

The project currently uses:
	•	PostgreSQL
	•	SQL
	•	DBeaver
	•	Git
	•	GitHub

⸻

## Future Enhancements

Planned improvements include:
	•	dbt transformation framework
	•	Dockerized development environment
	•	Airflow orchestration pipeline
	•	provider-level claim exposure analysis
	•	member-month modeling for PMPM analysis
	


⸻

## Project Structure

healthcare-data-engineering-project
│
├── models
│   └── healthcare
│       ├── staging
│       ├── intermediate
│       └── marts
│           ├── fct_claim_coverage_validation.sql
│           └── fct_member_claim_coverage_summary.sql
│
├── tests
│   └── healthcare
│       └── marts
│           ├── test_fct_claim_coverage_validation.sql
│           └── test_fct_member_claim_coverage_summary.sql
│
├── docs
└── data

⸻

## Goal of the Project

The goal of this project is to demonstrate practical data engineering skills applied to healthcare data problems, including:
	•	Modeling relational datasets
	•	Implementing temporal joins
	•	Building layered transformation pipelines
	•	Producing business-ready analytics models

⸻

## How to Run This Project

1. Clone the repository

    git clone git@github.com:yourusername/healthcare-data-engineering-project.git
    cd healthcare-data-engineering-project

2. Set up PostgreSQL

    Install PostgreSQL locally and create a database.

    Example:
    CREATE DATABASE practice_healthcare;

3. Create tables

    Run the SQL scripts in the project to create the following tables:
        •	members
        •	eligibility
        •	claims

4. Insert seed data

    Load sample records into the tables.

5. Run transformation models

    Execute the SQL model:
    models/healthcare/marts/fct_member_claim_coverage_summary.sql

    This will produce the member-level claims coverage summary.