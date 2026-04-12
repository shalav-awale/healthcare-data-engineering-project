-- Tests for: healthcare.fct_claim_coverage_validation
-- Expected behavior: each query returns 0 rows when the model is correct.

-- ambiguous should be HIGH RISK (per our current business rule)
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE coverage_status = 'AMBIGUOUS'
  AND status = 'PAID'
  AND claim_risk_level <> 'HIGH_RISK'