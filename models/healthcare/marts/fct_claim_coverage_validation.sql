with 
claim_eligibility_matches as
	(
	select 
		c.claim_id ,
		c.member_id ,
		c.service_date ,
		c.paid_amount ,
		c.status ,
		e.plan_id 
		from healthcare.claims c 
		left join healthcare.eligibility e
		on e.member_id = c.member_id
		and c.service_date  between e.effective_date and e.end_date 
	),
claim_match_counts as 
	(
	select 
		claim_id ,
		max(member_id) as member_id , 
		max(service_date) as service_date ,
		max(paid_amount) as paid_amount ,
		max(status) as status ,
		count(plan_id) as match_count
		--sum(case when plan_id is not null then 1 else 0 end) as match_count
	from claim_eligibility_matches 
	group by claim_id
	),
claim_coverage_validation as 
(
	select
	*,
	case
		when match_count = 1 then 'COVERED'
		when match_count = 0 then 'UNCOVERED'
		when match_count > 1 then 'AMBIGUOUS'
	end as coverage_status
	from claim_match_counts 
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
order by claim_id, member_id ;