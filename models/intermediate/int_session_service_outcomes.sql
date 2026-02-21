/*
  Intermediate: For each Voice AI session, whether it led to a completed application
  and the time_to_submit for completed applications.
  "Successful service completion" = at least one application with status = 'completed' for that session.
  We count any completed application linked to the session (any channel), so voice sessions that
  lead to completion via USSD/web etc. are still counted as successful.
*/
select
    session.session_id,
    session.user_id,
    max(case when applications.status = 'completed' then 1 else 0 end) as had_completed_application,
    min(case when applications.status = 'completed' then applications.time_to_submit_sec end) as time_to_submit_sec_completed
from {{ ref('stg_voice_sessions') }} session
left join {{ ref('stg_applications') }} applications
    on session.session_id = applications.session_id
group by session.session_id, session.user_id
