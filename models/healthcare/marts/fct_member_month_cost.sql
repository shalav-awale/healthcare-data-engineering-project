with claim_month as 
(
	select
	*,
	date_trunc('month', service_date)::date as claim_month
	from {{ ref('fct_claim_coverage_validation') }}
),
member_month_claims as
(
select 
member_id,
claim_month,
count(claim_id) as total_claim_count,
sum(case
		when status = 'PAID' then paid_amount
	else 0
	end)  as total_paid_amount,
sum(case
	when status = 'PAID' and coverage_status = 'UNCOVERED' then paid_amount
	else 0
end) as uncovered_paid_amount
from claim_month
group by member_id, claim_month 
), 
member_month_denominator as
(
select
member_id,
coverage_month ,
max(member_month_weight) as member_month_weight
from {{ ref('int_member_month_eligibility') }}
group by member_id, coverage_month
)
SELECT
    d.member_id,
    d.coverage_month,
    d.member_month_weight,
    COALESCE(c.total_claim_count, 0) AS total_claim_count,
    COALESCE(c.total_paid_amount, 0) AS total_paid_amount,
    COALESCE(c.uncovered_paid_amount, 0) AS uncovered_paid_amount,

    -- PMPM metrics
    CASE 
        WHEN d.member_month_weight > 0 
        THEN  COALESCE(c.total_paid_amount, 0) / d.member_month_weight
        ELSE 0
    END AS paid_pmpm,
     CASE 
        WHEN d.member_month_weight > 0 
        THEN COALESCE(c.uncovered_paid_amount, 0) / d.member_month_weight
        ELSE 0
    END AS uncovered_pmpm

FROM member_month_denominator d
LEFT JOIN member_month_claims c
    ON d.member_id = c.member_id
   AND d.coverage_month = c.claim_month
