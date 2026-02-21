/*
  Staging model: Users
  One row per user. We clean column names and ensure consistent types for downstream KPIs.
  Used for: rural/urban split, vulnerable flags (disability, first-time digital), retention.
*/
select
    user_id,
    lower(trim(region)) as region,                    -- 'rural' or 'urban'
    lower(trim(disability_flag)) as disability_flag,  -- 'yes' or 'no'
    lower(trim(first_time_digital_user)) as first_time_digital_user  -- 'yes' or 'no'
from {{ ref('users') }}
