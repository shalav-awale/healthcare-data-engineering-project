-- Tests for: healthcare.fct_claim_coverage_validation
-- Expected behavior: each query returns 0 rows when the model is correct.

-- 1) claim_id should be unique (claim-grain)
SELECT claim_id, COUNT(*) AS cnt
FROM healthcare.fct_claim_coverage_validation
GROUP BY claim_id
HAVING COUNT(*) > 1;

-- 2) match_count must map correctly to coverage_status
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE (match_count = 0 AND coverage_status <> 'UNCOVERED')
   OR (match_count = 1 AND coverage_status <> 'COVERED')
   OR (match_count > 1 AND coverage_status <> 'AMBIGUOUS');

-- 3) uncovered + paid must be HIGH RISK
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE coverage_status = 'UNCOVERED'
  AND status = 'PAID'
  AND claim_risk_level <> 'HIGH_RISK';

-- 4) ambiguous should be HIGH RISK (per our current business rule)
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE coverage_status = 'AMBIGUOUS'
  AND status = 'PAID'
  AND claim_risk_level <> 'HIGH_RISK';