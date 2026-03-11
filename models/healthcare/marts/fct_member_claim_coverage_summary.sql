/*
Model: fct_member_claim_coverage_summary

Grain:
1 row per member

Purpose:
Identify potential financial exposure caused by claims paid outside eligibility coverage.

Business Logic:
Claims are considered covered when the claim service date falls within an eligibility coverage segment.

Metrics:
- total_claim_count
- uncovered_claim_count
- total_paid_amount
- uncovered_paid_amount
*/



SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    COUNT(cl.claim_id) AS total_claim_count,
    SUM(
        CASE 
            WHEN cl.coverage_status = 'UNCOVERED' THEN 1
            ELSE 0
        END
    ) AS uncovered_claim_count,
    SUM(
        CASE
            WHEN cl.status = 'PAID' THEN cl.paid_amount
            ELSE 0        
        END
    ) AS total_paid_amount,
    SUM(
        CASE 
            WHEN cl.coverage_status = 'UNCOVERED'
             AND cl.status = 'PAID' 
            THEN cl.paid_amount
            ELSE 0
        END
    ) AS uncovered_paid_amount
FROM healthcare.members m 
LEFT JOIN healthcare.fct_claim_coverage_validation cl
  ON cl.member_id = m.member_id 
GROUP BY
    m.member_id,
    m.first_name,
    m.last_name
ORDER BY m.member_id;



