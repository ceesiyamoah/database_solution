--1)How many users does wave have?

SELECT COUNT(u_id) AS number_of_users
FROM users;

--2) How many transfers have been sent in the currency CFA?

SELECT COUNT(transfer_id) AS CFA_transfers
FROM transfers
WHERE send_amount_currency='CFA';

--3)How many different users have sent a transfer in CFA?

SELECT COUNT(DISTINCT u_id) AS unique_users_cfa_transfers
FROM transfers;

--4)How many agent_transactions did we have in the months of 2018?
-- For each month ( 1,2,.. 12) I converted it to string for easy readability

SELECT CASE extract(month
                    FROM when_created)
           WHEN 1 THEN 'January'
           WHEN 2 THEN 'February'
           WHEN 3 THEN 'March'
           WHEN 4 THEN 'April'
           WHEN 5 THEN 'May'
           WHEN 6 THEN 'June'
           WHEN 7 THEN 'July'
           WHEN 8 THEN 'August'
           WHEN 9 THEN 'September'
           WHEN 10 THEN 'October'
           WHEN 11 THEN 'November'
           WHEN 12 THEN 'December'
       END months,
       COUNT(amount)
FROM agent_transactions
WHERE EXTRACT(year
              FROM when_created) = '2018'
GROUP BY extract(month
                 FROM when_created) --5) Over the course of the last week, how many Wave agents were “net depositors” vs. “netwithdrawers”?

SELECT agent_id,
       SUM(amount),
       CASE
           WHEN SUM(amount)>0 THEN 'Net depositor'
           WHEN SUM(amount)<0 THEN 'Net withdrawer'
       END status
FROM agent_transactions
WHERE when_created > NOW() - INTERVAL '7days'
GROUP BY agent_id
ORDER BY SUM(amount) DESC;

--6 Build an “atx volume city summary” table: find the volume of agent transactions create in the last week, grouped by city

SELECT agents.city,
       SUM(agent_transactions.amount) AS volume
FROM agent_transactions
JOIN agents ON agent_transactions.agent_id=agents.agent_id
WHERE agent_transactions.when_created > NOW() - INTERVAL '7days'
GROUP BY agents.city
ORDER BY volume DESC;

--7 Now separate the atx volume by country as well (so your columns should be country, city, volume)

SELECT agents.country,
       agents.city,
       SUM(agent_transactions.amount) AS volume
FROM agent_transactions
JOIN agents ON agent_transactions.agent_id=agents.agent_id
WHERE agent_transactions.when_created>NOW() - INTERVAL '7days'
GROUP BY agents.city,
         agents.country
ORDER BY agents.country,
         volume DESC;

--8 Build a “send volume by country and kind” table: find the total volume of transfers (by send_amount_scalar) sent in the past week

SELECT wallets.ledger_location AS country,
       transfers.kind AS transferkind,
       SUM(transfers.send_amount_scalar) AS volume
FROM wallets
JOIN transfers ON wallets.wallet_id=transfers.source_wallet_id
WHERE transfers.when_created > NOW() - INTERVAL '7days'
GROUP BY country,
         transferkind
ORDER BY country ASC,
         transferkind DESC;

--9 Then add columns for transaction count and number of unique senders (still broken down by country and transfer kind).

SELECT wallets.ledger_location AS country,
       transfers.kind AS transferkind,
       SUM(transfers.send_amount_scalar) AS volume,
       COUNT(transfers.send_amount_scalar) AS transactionCount,
       COUNT(distinct transfers.source_wallet_id) AS uniqueWallets
FROM wallets
JOIN transfers ON wallets.wallet_id=transfers.source_wallet_id
WHERE transfers.when_created > NOW() - INTERVAL '7days'
GROUP BY country,
         transferkind
ORDER BY country ASC,
         transferkind DESC;

--10 which wallets have sent more than 10,000,000 CFA in transfers in the last month(as identified by the source_wallet_id column on the transfers table), and how much did they send?

SELECT source_wallet_id AS wallet,
       send_amount_scalar AS amount
FROM transfers
WHERE send_amount_scalar>10000
    AND send_amount_currency='CFA'
    AND when_created> NOW()- INTERVAL '1month'