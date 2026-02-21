/*
  Staging model: Voice sessions
  One row per Voice AI session. We keep key fields for duration, outcome, and date.
  Used for: completion rates, session duration, MAU, retention, growth.
*/
select
    session_id,
    user_id,
    channel,
    lower(trim(final_outcome)) as final_outcome,      -- 'completed', 'abandoned', 'transferred'
    trim(transfer_reason) as transfer_reason,          -- e.g. 'repeated_errors', 'system', 'user_request'
    total_duration_sec,
    total_turns,
    cast(created_at as date) as session_date
from {{ ref('voice_sessions') }}
