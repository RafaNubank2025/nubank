=========================
Tabelas seguindo DIAGRAMA
=========================

CREATE OR REPLACE TABLE `silver.accounts` AS 
SELECT 
  CAST(account_id AS INTEGER) account_id, 
  CAST(customer_id AS INTEGER) customer_id, 
  TIMESTAMP(created_at) created_at, 
  status, 
  account_branch, 
  account_check_digit, 
  account_number 
FROM `nubank-case-453405.bronze.accounts`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.city` AS 
SELECT 
  CAST(city_id AS INTEGER) city_id, 
  CAST(city AS STRING) city, 
  CAST(state_id AS INTEGER) state_id 
FROM `nubank-case-453405.bronze.city`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.country` AS 
SELECT 
  CAST(country_id AS INTEGER) country_id, 
  CAST(country AS STRING) country
FROM `nubank-case-453405.bronze.country`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.customers` AS 
SELECT 
  CAST(customer_id AS INTEGER) customer_id, 
  CAST(first_name AS STRING) first_name, 
  CAST(last_name AS STRING) last_name, 
  CAST(customer_city AS INTEGER) customer_city, 
  CAST(country_name AS STRING) country_name, 
  CAST(cpf AS INTEGER) cpf
FROM `nubank-case-453405.bronze.customers`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.d_month` AS 
SELECT 
  CAST(month_id AS INTEGER) month_id,
  CAST(action_month AS INTEGER) action_month
FROM `nubank-case-453405.bronze.d_month`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.d_time` AS 
SELECT 
  CAST(time_id AS INTEGER) time_id, 
  TIMESTAMP(action_timestamp) action_timestamp, 
  CAST(week_id AS INTEGER) week_id, 
  CAST(month_id AS INTEGER) month_id, 
  CAST(year_id AS INTEGER) year_id, 
  CAST(weekday_id AS INTEGER) weekday_id
FROM `nubank-case-453405.bronze.d_time`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.d_week` AS 
SELECT 
  CAST(week_id AS INTEGER) week_id,
  CAST(action_week AS INTEGER) action_week
FROM `nubank-case-453405.bronze.d_week`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.d_weekday` AS 
SELECT 
  CAST(weekday_id AS INTEGER) weekday_id,
  CAST(action_weekday AS INTEGER) action_weekday
FROM `nubank-case-453405.bronze.d_weekday`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.d_year` AS 
SELECT 
  CAST(year_id AS INTEGER) year_id,
  CAST(action_year AS INTEGER) action_year
FROM `nubank-case-453405.bronze.d_year`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.pix_movements` AS 
SELECT 
  CAST(id AS INTEGER) id, 
  CAST(account_id AS INTEGER) account_id, 
  in_or_out, 
  CAST(pix_amount AS FLOAT64) pix_amount, 
  CAST(pix_requested_at AS INTEGER) pix_requested_at, 
  CAST(pix_completed_at AS INTEGER) pix_completed_at, 
  status
FROM `nubank-case-453405.bronze.pix_movements`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.state` AS 
SELECT 
  state,
  state_id,
  CAST(country_id AS INTEGER) country_id
FROM `nubank-case-453405.bronze.state`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.transfer_ins` AS 
SELECT 
  CAST(id AS INTEGER) id, 
  CAST(account_id AS INTEGER) account_id, 
  CAST(amount AS FLOAT64) amount, 
  CAST(transaction_requested_at AS INTEGER) transaction_requested_at, 
  CAST(transaction_completed_at AS INTEGER) transaction_completed_at, 
  status
FROM `nubank-case-453405.bronze.transfer_ins`;
--------------------------------------------
CREATE OR REPLACE TABLE `silver.transfer_outs` AS 
SELECT 
  CAST(id AS INTEGER) id, 
  CAST(account_id AS INTEGER) account_id, 
  CAST(amount AS FLOAT64) amount, 
  CAST(transaction_requested_at AS INTEGER) transaction_requested_at, 
  CAST(transaction_completed_at AS INTEGER) transaction_completed_at, 
  status
FROM `nubank-case-453405.bronze.transfer_outs`;
