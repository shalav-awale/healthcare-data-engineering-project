# Healthcare Claims Coverage Validation Pipeline

## Overview

This project is a dbt-based healthcare data pipeline built on PostgreSQL. It validates medical claims against member eligibility periods, identifies uncovered and ambiguous claims, and produces member-level and member-month outputs for exposure and PMPM-style analysis.

----

## Problem

Claims that fall outside valid eligibility periods can create billing issues, payment integrity risk, and misleading downstream analytics. Overlapping eligibility can also make claim attribution ambiguous.

----

## Approach

The pipeline does four things:

1. Stages core source data for claims and eligibility  
2. Matches claims to eligibility using temporal logic  
3. Builds intermediate models for claim match counts and member-month eligibility  
4. Produces fact models for claim validation, member exposure, and member-month cost analysis 

----

## Key Logic

Claims are matched to eligibility using:

```sql
service_date BETWEEN eligibility.effective_date AND eligibility.end_date
```
----

### Coverage Classification

- 	match_count = 0 matches -> UNCOVERED  
- 	match_count = 1 match 	-> COVERED  
- 	match_count > 1 matches -> AMBIGUOUS  

----

## Risk Classification

```sql
CASE
  WHEN coverage_status IN ('UNCOVERED', 'AMBIGUOUS') AND status = 'PAID'
  THEN 'HIGH_RISK'
  ELSE 'LOW_RISK'
END
```
----
## Member-month weighting

member_month_weight = covered_days_in_month / days_in_month

----

## Project Structure

### Staging
	*	stg_claims
	*	stg_eligibility

### Intermediate
	*	int_claim_match_counts
	*	int_member_month_eligibility

### Marts
	*	fct_claim_coverage_validation
	*	fct_member_claim_coverage_summary
	*	fct_member_month_cost

----

## Data Model 

		Table									Grain											Purpose

- 	stg_claims			 				-> raw claim grain							-> staged source claims
- 	stg_eligibility						-> raw eligiblity grain						-> staged source eligibility
- 	int_claim_match_counts 				-> 1 row per claim 							-> Counts eligibility matches per claim
- 	int_member_month_eligibility 		-> 1 row per member per month per plan 		-> Expands eligibility into monthly denominator rows
- 	fct_claim_coverage_validation 		-> 1 row per claim 							-> Coverage + risk classification
- 	fct_member_claim_coverage_summary	-> 1 row per member 						-> Member-level exposure summary
- 	fct_member_month_cost 				-> 1 row per member per month 				-> Monthly cost and PMPM-style metrics 

----

## What This Project Demonstrates
-	Temporal joins and overlap handling
-	Grain correction after join expansion
-	dbt layering with ref() dependencies
-	Member-month denominator modeling
-	PMPM-style cost normalization
-	Custom SQL data tests for structural and business-rule validation

----

## Architecture (High-Level)

This project follows a layered transformation approach:
- 	Staging → cleans and standardizes raw data
- 	Intermediate → applies business logic
- 	Mart → produces analytics-ready datasets

## Raw tables (claims, eligibility, members)
- 	intermediate dbt models
- 	fact marts
- 	dbt data tests

## High-level flow:

### claims + eligibility
- 	int_claim_match_counts
- 	fct_claim_coverage_validation
- 	fct_member_claim_coverage_summary

### eligibility
- 	int_member_month_eligibility
- 	fct_member_month_cost

----

## Example Business Questions

This project enables analysis such as:
- 	Which claims were paid outside eligibility coverage?
- 	Which claims are ambiguous due to overlapping eligibility?
- 	Which members have the highest uncovered paid exposure?
- 	What is monthly paid cost normalized by member-month weight?
- 	What is the financial exposure from uncovered claims?
- 	How do partial-month eligibility periods affect PMPM?

----

## Validation Approach

The project includes dbt singular tests for:
-	claim-grain uniqueness
-	member-grain uniqueness
-	member-month grain uniqueness
-	match_count to coverage_status mapping
-	financial sanity checks such as uncovered_paid_amount <= total_paid_amount
-	denominator rules such as 0 <= member_month_weight <= 1
-	PMPM formula correctness with tolerance-based validation

----

## Design Decisions

The monthly cost mart was intentionally built at member-month grain, not member-month-plan grain, because claim-to-plan attribution was not reliably resolved in the current model. This avoids duplicating or misattributing cost across plans while still supporting valid PMPM-style analysis.

----

## Technology Stack

The project currently uses:
-	PostgreSQL
-	dbt Core
-	SQL
-	DBeaver
-	Git / GitHub

----

## Future Enhancements

- 	orchestrate dbt runs on a schedule with Airflow or Dagster
- 	scheduled orchestration with Airflow or Dagster
- 	containerized setup (Docker)
- 	add provider or plan-attributed cost modeling once attribution logic is available
-	deploy the pipeline on a cloud warehouse

----