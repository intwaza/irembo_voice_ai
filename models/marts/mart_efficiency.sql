/*
  Efficiency KPIs (one row summary).
  Built from fact_voice_ai_sessions.
*/
with
session_agg as (
    select
        count(*) as total_sessions,
        sum(total_duration_sec) as total_duration_sec,
        sum(total_turns) as total_turns_sum,
        sum(repeat_count) as total_repeats_sum,
        sum(has_error_or_timeout) as sessions_with_error
    from {{ ref('fact_voice_ai_sessions') }}
),
completion_time as (
    select avg(time_to_submit_sec_completed) as avg_time_to_submit_sec
    from {{ ref('fact_voice_ai_sessions') }}
    where time_to_submit_sec_completed is not null
)
select
    round(session_agg.total_duration_sec * 1.0 / nullif(session_agg.total_sessions, 0), 2) as avg_session_duration_sec,
    round(session_agg.total_turns_sum * 1.0 / nullif(session_agg.total_sessions, 0), 2) as avg_turns_per_session,
    round(session_agg.total_repeats_sum * 1.0 / nullif(session_agg.total_sessions, 0), 2) as avg_repeats_per_session,
    round(100.0 * session_agg.sessions_with_error / nullif(session_agg.total_sessions, 0), 2) as session_error_timeout_rate_pct,
    round((select avg_time_to_submit_sec from completion_time), 2) as avg_service_completion_time_sec
from session_agg
