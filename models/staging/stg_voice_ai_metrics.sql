/*
  Staging model: AI performance metrics per session
  Used for: session error/timeout rate (misunderstanding, escalation), quality.
*/
select
    session_id,
    avg_asr_confidence,
    avg_intent_confidence,
    misunderstanding_rate,
    silence_rate,
    lower(trim(recovery_success)) as recovery_success,
    lower(trim(escalation_flag)) as escalation_flag
from {{ ref('voice_ai_metrics') }}
