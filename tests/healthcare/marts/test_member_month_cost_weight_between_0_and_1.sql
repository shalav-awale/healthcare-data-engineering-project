SELECT *
FROM healthcare.fct_member_month_cost 
WHERE member_month_weight < 0 
   OR member_month_weight > 1