SELECT *
FROM healthcare.fct_member_month_cost
WHERE member_month_weight > 0
  AND ABS(
        uncovered_pmpm - (uncovered_paid_amount / member_month_weight)
      ) > 0.01