-- Test for: healthcare.fct_claim_coverage_validation
-- Expected behavior: query returns 0 rows when the model is correct.

-- claim_id should be unique (claim-grain)
SELECT claim_id, COUNT(*) AS cnt
FROM healthcare.fct_claim_coverage_validation
GROUP BY claim_id
HAVING COUNT(*) > 1