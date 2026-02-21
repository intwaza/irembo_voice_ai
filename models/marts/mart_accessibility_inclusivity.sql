/*
  Accessibility / Inclusivity KPIs (one row summary).
  Built from fact_voice_ai_sessions.
*/
with
active_users as (
    select
        user_id,
        region,
        is_vulnerable,
        is_first_time_digital_user
    from {{ ref('fact_voice_ai_sessions') }}
    group by user_id, region, is_vulnerable, is_first_time_digital_user
),
session_completion as (
    select
        session_id,
        user_id,
        region,
        is_vulnerable,
        had_completed_application
    from {{ ref('fact_voice_ai_sessions') }}
),
totals as (
    select
        count(distinct user_id) as total_active_users,
        count(distinct case when region = 'rural' then user_id end) as rural_users,
        count(distinct case when is_first_time_digital_user = 1 then user_id end) as first_time_digital_users
    from active_users
),
completion_by_region as (
    select
        region,
        count(*) as sessions,
        sum(had_completed_application) as completed_sessions
    from session_completion
    group by region
),
completion_by_vulnerable as (
    select
        is_vulnerable,
        count(*) as sessions,
        sum(had_completed_application) as completed_sessions
    from session_completion
    group by is_vulnerable
),
rates as (
    select
        (select rates.completed_sessions * 1.0 / nullif(rates.sessions, 0) from completion_by_region rates where rates.region = 'urban' limit 1) as urban_completion_rate,
        (select rates.completed_sessions * 1.0 / nullif(rates.sessions, 0) from completion_by_region rates where rates.region = 'rural' limit 1) as rural_completion_rate,
        (select vulnerable.completed_sessions * 1.0 / nullif(vulnerable.sessions, 0) from completion_by_vulnerable vulnerable where vulnerable.is_vulnerable = 0 limit 1) as non_vulnerable_completion_rate,
        (select vulnerable.completed_sessions * 1.0 / nullif(vulnerable.sessions, 0) from completion_by_vulnerable vulnerable where vulnerable.is_vulnerable = 1 limit 1) as vulnerable_completion_rate
),
vulnerable_sessions as (
    select
        count(*) as total_sessions,
        sum(had_completed_application) as completed_sessions
    from session_completion
    where is_vulnerable = 1
)
select
    round(100.0 * totals.rural_users / nullif(totals.total_active_users, 0), 2) as rural_user_growth_pct,
    round(100.0 * vulnerable_sessions.completed_sessions / nullif(vulnerable_sessions.total_sessions, 0), 2) as vulnerable_user_completion_rate_pct,
    round(100.0 * totals.first_time_digital_users / nullif(totals.total_active_users, 0), 2) as first_time_digital_user_rate_pct,
    round((rates.urban_completion_rate - rates.rural_completion_rate) * 100.0, 2) as completion_gap_urban_minus_rural_pct,
    round((rates.non_vulnerable_completion_rate - rates.vulnerable_completion_rate) * 100.0, 2) as completion_gap_non_vulnerable_minus_vulnerable_pct
from totals totals
cross join vulnerable_sessions
cross join rates
