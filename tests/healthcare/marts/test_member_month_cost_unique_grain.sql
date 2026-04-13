SELECT
    member_id,
    coverage_month,
    COUNT(*) AS cnt
FROM healthcare.fct_member_month_cost
GROUP BY member_id, coverage_month
HAVING COUNT(*) > 1