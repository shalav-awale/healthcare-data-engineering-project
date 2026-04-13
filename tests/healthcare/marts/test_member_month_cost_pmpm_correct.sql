SELECT *
FROM healthcare.fct_member_month_cost
WHERE member_month_weight > 0
  AND ABS(
        paid_pmpm - (total_paid_amount / member_month_weight)
      ) > 0.01