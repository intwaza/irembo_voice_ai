/*
  Adoption KPIs (one row summary).
  Uses fact_voice_ai_sessions for session_date and user_id.
*/
with
sessions_with_month as (
    select
        session_id,
        user_id,
        session_date,
        date_trunc('month', session_date)::date as session_month
    from {{ ref('fact_voice_ai_sessions') }}
),
mau_by_month as (
    select
        session_month,
        count(distinct user_id) as mau
    from sessions_with_month
    group by session_month
),
sessions_per_user as (
    select
        user_id,
        count(*) as session_count
    from {{ ref('fact_voice_ai_sessions') }}
    group by user_id
),
retention as (
    select
        count(*) as total_users,
        count(case when session_count > 1 then 1 end) as returning_users
    from sessions_per_user
),
sessions_by_month as (
    select
        session_month,
        count(*) as session_count
    from sessions_with_month
    group by session_month
),
mom as (
    select
        session_month,
        session_count as current_sessions,
        lag(session_count) over (order by session_month) as previous_sessions,
        case
            when lag(session_count) over (order by session_month) > 0
            then 100.0 * (session_count - lag(session_count) over (order by session_month)) / lag(session_count) over (order by session_month)
            else null
        end as growth_pct
    from sessions_by_month
),
vulnerable_users as (
    select user_id
    from {{ ref('stg_users') }}
    where disability_flag = 'yes' or first_time_digital_user = 'yes'
),
vulnerable_using_voice as (
    select count(distinct sessions.user_id) as num_users
    from {{ ref('fact_voice_ai_sessions') }} sessions
    join vulnerable_users vulnerable on sessions.user_id = vulnerable.user_id
),
vulnerable_total as (
    select count(*) as num_users from vulnerable_users
)
select
    (select mau from mau_by_month order by session_month desc limit 1) as mau_latest_month,
    (select session_month from mau_by_month order by session_month desc limit 1) as mau_month,
    round(100.0 * retention.returning_users / nullif(retention.total_users, 0), 2) as user_retention_rate_pct,
    (select growth_pct from mom order by session_month desc limit 1) as mom_growth_rate_pct,
    (select session_month from mom order by session_month desc limit 1) as mom_growth_month,
    round(100.0 * (select num_users from vulnerable_using_voice) / nullif((select num_users from vulnerable_total), 0), 2) as voice_ai_adoption_target_users_pct
from retention
