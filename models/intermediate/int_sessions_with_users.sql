/*
  Intermediate: Sessions joined to user attributes.
  Adds: region (rural/urban), is_vulnerable, first_time_digital_user for KPI splits.
  "Vulnerable" = disability_flag = 'yes' OR first_time_digital_user = 'yes'
  (Assignment also mentions low-literacy; add that flag here if the column exists in users.)
*/
select
    session.session_id,
    session.user_id,
    session.final_outcome,
    session.transfer_reason,
    session.total_duration_sec,
    session.total_turns,
    session.session_date,
    users.region,
    case
        when users.disability_flag = 'yes' or users.first_time_digital_user = 'yes' then 1
        else 0
    end as is_vulnerable,
    case when users.first_time_digital_user = 'yes' then 1 else 0 end as is_first_time_digital_user
from {{ ref('stg_voice_sessions') }} session
left join {{ ref('stg_users') }} users on session.user_id = users.user_id
