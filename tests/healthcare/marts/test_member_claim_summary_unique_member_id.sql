-- Tests for: healthcare.fct_member_claim_coverage_summary
-- Expected behavior: query returns 0 rows when the model is correct.

--member_id should be unique (member-grain)
SELECT member_id, COUNT(*) AS cnt
FROM healthcare.fct_member_claim_coverage_summary
GROUP BY member_id
HAVING COUNT(*) > 1