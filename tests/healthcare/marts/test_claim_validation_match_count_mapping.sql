-- Test for: healthcare.fct_claim_coverage_validation
-- Expected behavior: query returns 0 rows when the model is correct.

-- match_count must map correctly to coverage_status
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE (match_count = 0 AND coverage_status <> 'UNCOVERED')
   OR (match_count = 1 AND coverage_status <> 'COVERED')
   OR (match_count > 1 AND coverage_status <> 'AMBIGUOUS')