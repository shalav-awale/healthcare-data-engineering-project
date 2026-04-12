-- Tests for: healthcare.fct_member_claim_coverage_summary
-- Expected behavior: query returns 0 rows when the model is correct.

-- uncovered paid amount cannot exceed total paid amount
SELECT *
FROM healthcare.fct_member_claim_coverage_summary
WHERE uncovered_paid_amount > total_paid_amount