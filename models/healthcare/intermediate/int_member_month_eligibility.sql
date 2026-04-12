with coverage_month as
(
select
	e.member_id,
	e.plan_id,
	e.effective_date,
	e.end_date,
	gs.coverage_month::date as coverage_month
from healthcare.eligibility e
cross join lateral generate_series(
	date_trunc('month', e.effective_date), 
	date_trunc('month', LEAST(e.end_date, date '2026-12-31')),
	interval '1 month'
	) as gs(coverage_month)
),
coverage_month_range as
(
select 
	member_id,
	plan_id,
	coverage_month,
	effective_date,
	end_date,
	coverage_month as month_start,
	(date_trunc('month', coverage_month) + interval '1 month - 1 day')::date as month_end
from coverage_month
),
coverage_month_aligned as
(
	select
	member_id,
	plan_id,
	effective_date,
	end_date,
	coverage_month,
	month_start,
	month_end,
	greatest(month_start, effective_date) as coverage_start_in_month,
	least(month_end, end_date) as coverage_end_in_month
	from coverage_month_range
),
month_days_count as 
(
select *,
coverage_end_in_month  - coverage_start_in_month + 1 as covered_days_in_month,
month_end - month_start + 1 as days_in_month
from coverage_month_aligned
),
member_monthly_weight as 
(
select 
*,
covered_days_in_month::numeric / days_in_month::numeric as member_month_weight
from
month_days_count 
)
select
*,
case
	when member_month_weight = 1 then 'FULL_MONTH'
	else 'PARTIAL_MONTH'
end as coverage_month_type
from member_monthly_weight 