/*
  Staging model: Voice turns
  One row per utterance in a session. Used for friction (turns, repeats) and error analysis.
*/
select
    turn_id,
    session_id,
    turn_number,
    lower(trim(speaker)) as speaker,
    lower(trim(detected_intent)) as detected_intent,
    trim(error_type) as error_type
from {{ ref('voice_turns') }}
