CREATE OR REPLACE TABLE `bronze.country` (
  country_id STRING NOT NULL,
  country STRING
);

CREATE OR REPLACE TABLE `bronze.state` (
  state_id STRING NOT NULL,
  state STRING,
  country_id STRING
);

CREATE OR REPLACE TABLE `bronze.city` (
  city_id STRING NOT NULL,
  city STRING,
  state_id STRING
);

CREATE OR REPLACE TABLE `bronze.customers` (
  customer_id STRING NOT NULL,
  first_name STRING,
  last_name STRING,
  customer_city STRING,
  country_name STRING,
  cpf STRING
);

CREATE OR REPLACE TABLE `bronze.accounts` (
  account_id STRING NOT NULL,
  customer_id STRING,
  created_at STRING,
  status STRING,
  account_branch STRING,
  account_check_digit STRING,
  account_number STRING
);

CREATE OR REPLACE TABLE `bronze.transfer_ins` (
  id STRING NOT NULL,
  account_id STRING,
  amount STRING,
  transaction_requested_at STRING,
  transaction_completed_at STRING,
  status STRING
);

CREATE OR REPLACE TABLE `bronze.transfer_outs` (
  id STRING NOT NULL,
  account_id STRING,
  amount STRING,
  transaction_requested_at STRING,
  transaction_completed_at STRING,
  status STRING
);

CREATE OR REPLACE TABLE `bronze.pix_movements` (
  id STRING NOT NULL,
  account_id STRING,
  in_or_out STRING,
  pix_amount STRING,
  pix_requested_at STRING,
  pix_completed_at STRING,
  status STRING
);

CREATE OR REPLACE TABLE `bronze.d_month` (
  month_id STRING NOT NULL,
  action_month STRING
);

CREATE OR REPLACE TABLE `bronze.d_year` (
  year_id STRING NOT NULL,
  action_year STRING
);

CREATE OR REPLACE TABLE `bronze.d_time` (
  time_id STRING NOT NULL,
  action_timestamp STRING,
  week_id STRING,
  month_id STRING,
  year_id STRING,
  weekday_id STRING
);

CREATE OR REPLACE TABLE `bronze.d_week` (
  week_id STRING NOT NULL,
  action_week STRING
);

CREATE OR REPLACE TABLE `bronze.d_weekday` (
  weekday_id STRING NOT NULL,
  action_weekday STRING
);
