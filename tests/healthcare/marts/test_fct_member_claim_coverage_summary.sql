-- Tests for: healthcare.fct_member_claim_coverage_summary
-- Expected behavior: each query returns 0 rows when the model is correct.

-- 1) member_id should be unique (member-grain)
SELECT member_id, COUNT(*) AS cnt
FROM healthcare.fct_member_claim_coverage_summary
GROUP BY member_id
HAVING COUNT(*) > 1;

-- 2) uncovered paid amount cannot exceed total paid amount
SELECT *
FROM healthcare.fct_member_claim_coverage_summary
WHERE uncovered_paid_amount > total_paid_amount;

-- 3) member with no claims should exist and have zeros (we know 1000001 has no claims)
SELECT *
FROM healthcare.fct_member_claim_coverage_summary
WHERE total_claim_count = 0
AND (
    uncovered_claim_count <> 0
    OR total_paid_amount <> 0
    OR uncovered_paid_amount <> 0
);