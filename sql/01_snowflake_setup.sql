-- 01_snowflake_setup.sql
-- Rebuilds the Snowflake side of the DummyJSON pipeline in a new account.
-- Run as ACCOUNTADMIN, one block at a time.

USE ROLE ACCOUNTADMIN;

-- 1. Warehouse, database, schemas
CREATE WAREHOUSE IF NOT EXISTS DUMMYJSON_WH
  WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE DATABASE IF NOT EXISTS DUMMYJSON_DB;
CREATE SCHEMA IF NOT EXISTS DUMMYJSON_DB.RAW;
CREATE SCHEMA IF NOT EXISTS DUMMYJSON_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS DUMMYJSON_DB.MARTS;

-- 2. Storage integration (S3 access)
CREATE OR REPLACE STORAGE INTEGRATION dummyjson_s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::985151712784:role/snowflake-dummyjson-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://iamnc-dummyjson-raw/raw/dummyjson/');

DESC INTEGRATION dummyjson_s3_int;
-- NEXT: copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID into the
-- trust policy of the AWS role snowflake-dummyjson-role (new values per account).

-- 3. File format and stage
USE SCHEMA DUMMYJSON_DB.RAW;

CREATE OR REPLACE FILE FORMAT json_ff
  TYPE = JSON
  STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE STAGE dummyjson_stage
  URL = 's3://iamnc-dummyjson-raw/raw/dummyjson/'
  STORAGE_INTEGRATION = dummyjson_s3_int
  FILE_FORMAT = json_ff;

LIST @dummyjson_stage;   -- should show products, users and carts files

-- 4. Raw tables
CREATE OR REPLACE TABLE raw_products (
  v VARIANT, _source_file STRING,
  _loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP());
CREATE OR REPLACE TABLE raw_users (
  v VARIANT, _source_file STRING,
  _loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP());
CREATE OR REPLACE TABLE raw_carts (
  v VARIANT, _source_file STRING,
  _loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP());

-- 5. Load
COPY INTO raw_products (v, _source_file)
  FROM (SELECT $1, METADATA$FILENAME FROM @dummyjson_stage/products/)
  PATTERN = '.*\.json';
COPY INTO raw_users (v, _source_file)
  FROM (SELECT $1, METADATA$FILENAME FROM @dummyjson_stage/users/)
  PATTERN = '.*\.json';
COPY INTO raw_carts (v, _source_file)
  FROM (SELECT $1, METADATA$FILENAME FROM @dummyjson_stage/carts/)
  PATTERN = '.*\.json';

-- 6. Check counts (expect 194 / 208 / 208)
SELECT 'products' AS tbl, COUNT(*) AS n FROM raw_products
UNION ALL SELECT 'users', COUNT(*) FROM raw_users
UNION ALL SELECT 'carts', COUNT(*) FROM raw_carts;

-- 7. dbt user (key-pair auth). Paste your PUBLIC key body below.
-- Never put the private key (dbt_key.p8) in this file.
CREATE USER IF NOT EXISTS DBT_USER
  DEFAULT_ROLE = ACCOUNTADMIN
  DEFAULT_WAREHOUSE = DUMMYJSON_WH
  RSA_PUBLIC_KEY = '<PASTE_PUBLIC_KEY_BODY_HERE>';
GRANT ROLE ACCOUNTADMIN TO USER DBT_USER;