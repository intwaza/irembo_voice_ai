/*
  Intermediate: Sessions with error/timeout flags for KPI "Session Error and Timeout Rate".
  A session counts as having error or timeout if:
  - transfer_reason = 'repeated_errors', or
  - AI metrics show escalation, or
  - misunderstanding_rate > 0 (AI error).
  We keep a simple 0/1 flag for "session had error or timeout".
*/
select
    session.session_id,
    case
        when session.transfer_reason = 'repeated_errors' then 1
        when metrics.escalation_flag = 'yes' then 1
        when coalesce(metrics.misunderstanding_rate, 0) > 0 then 1
        else 0
    end as has_error_or_timeout
from {{ ref('stg_voice_sessions') }} session
left join {{ ref('stg_voice_ai_metrics') }} metrics on session.session_id = metrics.session_id
