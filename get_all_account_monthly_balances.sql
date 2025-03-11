WITH transactions AS (
    -- Coletando entradas de transfer_ins
    SELECT 
        ti.account_id,
        dy.action_year AS year,
        dm.action_month AS month,
        SUM(ti.amount) AS total_in,
        0 AS total_out
    FROM `silver.transfer_ins` ti
    JOIN `silver.d_time` dt ON ti.transaction_completed_at = dt.time_id
    JOIN `silver.d_month` dm ON dt.month_id = dm.month_id
    JOIN `silver.d_year` dy ON dt.year_id = dy.year_id
    WHERE dy.action_year = 2020 
    AND LOWER(TRIM(status)) = 'completed'
    GROUP BY ti.account_id, dy.action_year, dm.action_month

    UNION ALL

    -- Coletando saídas de transfer_outs
    SELECT 
        to_.account_id,
        dy.action_year AS year,
        dm.action_month AS month,
        0 AS total_in,
        SUM(to_.amount) AS total_out
    FROM `silver.transfer_outs` to_
    JOIN `silver.d_time` dt ON to_.transaction_completed_at = dt.time_id
    JOIN `silver.d_month` dm ON dt.month_id = dm.month_id
    JOIN `silver.d_year` dy ON dt.year_id = dy.year_id
    WHERE dy.action_year = 2020
    AND LOWER(TRIM(status)) = 'completed'
    GROUP BY to_.account_id, dy.action_year, dm.action_month

    UNION ALL

    -- Coletando movimentações PIX
    SELECT 
        pm.account_id,
        dy.action_year AS year,
        dm.action_month AS month,
        SUM(CASE WHEN LOWER(TRIM(pm.in_or_out)) = 'pix_in'  AND LOWER(TRIM(status)) = 'completed' THEN pm.pix_amount ELSE 0 END) AS total_in,
        SUM(CASE WHEN LOWER(TRIM(pm.in_or_out)) = 'pix_out' AND LOWER(TRIM(status)) = 'completed' THEN pm.pix_amount ELSE 0 END) AS total_out
    FROM `silver.pix_movements` pm
    JOIN `silver.d_time` dt ON pm.pix_completed_at = dt.time_id
    JOIN `silver.d_month` dm ON dt.month_id = dm.month_id
    JOIN `silver.d_year` dy ON dt.year_id = dy.year_id
    WHERE dy.action_year = 2020
    GROUP BY pm.account_id, dy.action_year, dm.action_month
),

aggregated AS (
    -- Somando entradas e saídas por conta e mês
    SELECT 
        account_id,
        year,
        month,
        SUM(total_in) AS total_transfer_in,
        SUM(total_out) AS total_transfer_out
    FROM transactions
    GROUP BY account_id, year, month
),

balances AS (
    -- Calculando o saldo acumulado mês a mês
    SELECT 
        year,
        month,
        account_id,
        ROUND(total_transfer_in, 2) total_transfer_in,
        ROUND(total_transfer_out, 2) total_transfer_out,
        ROUND(SUM(total_transfer_in - total_transfer_out) 
            OVER (PARTITION BY account_id ORDER BY year, month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) 
        AS saldo_mensal_conta
    FROM aggregated
)

SELECT * FROM balances
ORDER BY account_id, month;
