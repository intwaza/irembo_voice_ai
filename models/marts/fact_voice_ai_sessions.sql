/*
  Fact table: one row per Voice AI session.
  Central table for session-level analysis and for building Accessibility, Efficiency, and Adoption KPIs.
  Joins session data with user attributes, service outcomes, error flags, and turn friction.
*/
select
    sessions_with_users.session_id,
    sessions_with_users.user_id,
    sessions_with_users.session_date,
    sessions_with_users.region,
    sessions_with_users.is_vulnerable,
    sessions_with_users.is_first_time_digital_user,
    sessions_with_users.final_outcome,
    sessions_with_users.transfer_reason,
    sessions_with_users.total_duration_sec,
    sessions_with_users.total_turns,
    coalesce(turn_friction.repeat_count, 0) as repeat_count,
    session_service_outcomes.had_completed_application,
    session_service_outcomes.time_to_submit_sec_completed,
    coalesce(session_errors.has_error_or_timeout, 0) as has_error_or_timeout
from {{ ref('int_sessions_with_users') }} sessions_with_users
left join {{ ref('int_session_service_outcomes') }} session_service_outcomes on sessions_with_users.session_id = session_service_outcomes.session_id
left join {{ ref('int_session_errors') }} session_errors on sessions_with_users.session_id = session_errors.session_id
left join {{ ref('int_turn_friction') }} turn_friction on sessions_with_users.session_id = turn_friction.session_id
