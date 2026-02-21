/*
  Intermediate: Per-session turn and repeat counts for "Conversation Friction Rate".
  Friction = average turns per session + average repeats per session.
  We get total_turns from sessions; repeat count from voice_turns (detected_intent = 'repeat').
*/
select
    session.session_id,
    session.total_turns,
    coalesce(turns.repeat_count, 0) as repeat_count
from {{ ref('stg_voice_sessions') }} session
left join (
    select
        session_id,
        count(*) as repeat_count
    from {{ ref('stg_voice_turns') }}
    where detected_intent = 'repeat'
    group by session_id
) turns on session.session_id = turns.session_id
