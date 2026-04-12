with 
claim_coverage_validation as 
(
	select
	*,
	case
		when match_count = 1 then 'COVERED'
		when match_count = 0 then 'UNCOVERED'
		else 'AMBIGUOUS'
	end as coverage_status
	from {{ ref('int_claim_match_counts') }} claim_match_counts
),
claim_risk_classification as 
(
	select 
	*,
	case
		when coverage_status in ('UNCOVERED', 'AMBIGUOUS') and status = 'PAID' then 'HIGH_RISK'
		else 'LOW_RISK'
	end as claim_risk_level
	from claim_coverage_validation 
)
select
	claim_id ,
	member_id , 
	service_date ,
	paid_amount ,
	status , 
	match_count,
	coverage_status,
	claim_risk_level
from
claim_risk_classification 