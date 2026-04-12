-- Test for: healthcare.fct_claim_coverage_validation
-- Expected behavior: query returns 0 rows when the model is correct.

-- uncovered + paid must be HIGH RISK
SELECT *
FROM healthcare.fct_claim_coverage_validation
WHERE coverage_status = 'UNCOVERED'
  AND status = 'PAID'
  AND claim_risk_level <> 'HIGH_RISK'