/*
  Staging model: Service applications
  Links sessions/users to application outcomes. Used for: service completion, completion time.
*/
select
    application_id,
    session_id,
    user_id,
    service_code,
    lower(trim(channel)) as channel,
    lower(trim(status)) as status,   -- 'completed', 'abandoned', 'failed'
    time_to_submit_sec,
    cast(submitted_at as date) as submitted_date
from {{ ref('applications') }}
