-- Tests for: healthcare.fct_member_claim_coverage_summary
-- Expected behavior: query returns 0 rows when the model is correct.

-- member with no claims should exist and have zeros (we know 1000001 has no claims)
SELECT *
FROM healthcare.fct_member_claim_coverage_summary
WHERE total_claim_count = 0
AND (
    uncovered_claim_count <> 0
    OR total_paid_amount <> 0
    OR uncovered_paid_amount <> 0
)