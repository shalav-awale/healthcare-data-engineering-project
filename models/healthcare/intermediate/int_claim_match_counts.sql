with
claim_eligibility_matches as
    (
    select 
        c.claim_id ,
        c.member_id ,
        c.service_date ,
        c.paid_amount ,
        c.status ,
        e.plan_id 
        from healthcare.claims c 
        left join healthcare.eligibility e
        on e.member_id = c.member_id
        and c.service_date  between e.effective_date and e.end_date 
    )
select 
    claim_id ,
    max(member_id) as member_id , 
    max(service_date) as service_date ,
    max(paid_amount) as paid_amount ,
    max(status) as status ,
    count(plan_id) as match_count
from claim_eligibility_matches
group by claim_id