--1)How many users does wave have?

SELECT count(u_id) AS number_of_users
FROM users;

--2) How many transfers have been sent in the currency CFA?

SELECT count(transfer_id) AS CFA_transfers
FROM transfers
WHERE send_amount_currency='CFA';

--3)How many different users have sent a transfer in CFA?

SELECT COUNT(DISTINCT u_id) AS unique_users_cfa_transfers
FROM transfers;

--4)How many agent_transactions did we have in the months of 2018?
 --5)5. Over the course of the last week, how many Wave agents were “net depositors” vs. “netwithdrawers”?

select agent_id,
       sum(amount),
       case
           when sum(amount)>0 then 'Net depositor'
           when sum(amount)<0 then 'Net withdrawer'
       end status
from agent_transactions
where when_created>'2020-07-17 00:00:00'
group by agent_id
order by sum(amount) desc;

--6

select agents.city,
       count(agent_transactions.amount) as volume
from agent_transactions
join agents on agent_transactions.agent_id=agents.agent_id
where agent_transactions.when_created>'2020-07-17 00:00:00'
group by agents.city;

