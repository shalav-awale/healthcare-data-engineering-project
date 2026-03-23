# Healthcare Claims Coverage Validation Pipeline

## Overview

This project simulates a real-world data engineering workflow to validate medical claims against member eligibility periods.

In healthcare systems, claims submitted outside valid coverage periods can lead to data quality issues, incorrect billing, or financial exposure. This project demonstrates how to detect and analyze such scenarios using SQL-based transformations.

Built using SQL with a design that mirrors modern data warehouse modeling practices (dbt-ready).

----

## Problem

Validate whether claims occurred within valid eligibility coverage periods and quantify financial exposure from uncovered or ambiguous claims.

----

## Approach

- Temporal joins between claims and eligibility data  
- Classification of claims as COVERED, UNCOVERED, or AMBIGUOUS  
- Aggregation to member-level financial metrics 
- Layered transformation architecture (staging → intermediate → marts) 
- SQL-based validation checks  

----

## Key Logic

Claims are matched to eligibility using:

```sql
service_date BETWEEN eligibility.effective_date AND eligibility.end_date
```
----

### Coverage Classification
- 0 matches → UNCOVERED  
- 1 match → COVERED  
- > 1 matches → AMBIGUOUS  

----

### Risk Classification

```sql
CASE
  WHEN coverage_status IN ('UNCOVERED', 'AMBIGUOUS') AND status = 'PAID'
  THEN 'HIGH_RISK'
  ELSE 'LOW_RISK'
END
```
----

## Data Model 
	Table			Grain
- Members 		→ 1 row per member  
- Eligibility 	→ 1 row per member per coverage period  
- Claims 		→ 1 row per claim  

----

## Models

fct_claim_coverage_validation
	•	Grain: 1 row per claim
	•	Determines coverage status and risk level
	•	Handles overlapping eligibility using match counts

fct_member_claim_coverage_summary
	•	Grain: 1 row per member
	•	Aggregates validated claim data
	•	Avoids double counting by using claim-level model as input

## What This Project Demonstrates

- Data modeling and grain awareness  
- Handling join explosion and ambiguity
- Temporal joins in real-world scenarios 
- Translating business rules into SQL transformations
- Data validation and reconciliation  

----

## Architecture (High-Level)

This project follows a layered transformation approach:
- Staging → cleans and standardizes raw data
- Intermediate → applies business logic
- Mart → produces analytics-ready datasets

----

## Example Business Questions

This project enables analysis such as:
- Which members had claims submitted outside eligibility coverage?
- Which claims occurred outside eligibility coverage?
- What is the financial exposure from uncovered claims?
- Which claims are ambiguous due to overlapping eligibility?
- Which members have the highest risk exposure?

----

## Validation

The project includes SQL-based checks to ensure:
- claim_id uniqueness (claim-grain enforcement)
- match_count correctly maps to coverage_status
- uncovered/ambiguous paid claims are classified as HIGH_RISK
- uncovered_paid_amount ≤ total_paid_amount

## Technology Stack

The project currently uses:
	•	PostgreSQL
	•	SQL
	•	DBeaver
	•	Git
	•	GitHub

----

## Future Enhancements

- dbt integration
- workflow orchestration (Airflow)
- containerized setup (Docker)
- provider and PMPM modeling

----
