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

fct_member_claim_coverage_summary

⸻

#### Model: fct_member_claim_coverage_summary

Grain

1 row per member

Purpose

Summarizes claim activity for each member and identifies financial exposure from claims that occurred outside valid eligibility coverage.

Claims are considered covered when:

service_date BETWEEN eligibility.effective_date AND eligibility.end_date

Metrics produced
	•	total_claim_count
	•	uncovered_claim_count
	•	total_paid_amount
	•	uncovered_paid_amount

These metrics allow analysts to identify members with uncovered claims and quantify the financial exposure associated with those claims.

⸻

Example Business Questions

This project enables analysis such as:
	•	Which members had claims submitted outside eligibility coverage?
	•	What is the financial exposure from uncovered claims?
	•	Which members have the highest uncovered claim risk?

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
	•	Claim-level coverage validation model
	•	Provider-level claim exposure analysis
	•	Member-month modeling for PMPM analysis
	•	dbt transformation framework
	•	Dockerized development environment
	•	Airflow orchestration pipeline

⸻

## Project Structure

healthcare-data-engineering-project
│
├── models
│   └── healthcare
│       ├── staging
│       ├── intermediate
│       └── marts
│           └── fct_member_claim_coverage_summary.sql
│
├── tests
├── docs
└── data

⸻

## Goal of the Project

The goal of this project is to demonstrate practical data engineering skills applied to healthcare data problems, including:
	•	Modeling relational datasets
	•	Implementing temporal joins
	•	Building layered transformation pipelines
	•	Producing business-ready analytics models