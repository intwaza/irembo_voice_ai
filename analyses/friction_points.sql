/*
  Part 3a: Top 3 friction points in Voice AI interactions.

  Friction = things that slow or block users: errors (misunderstanding, silence)
  and repeated requests (detected_intent = 'repeat'). We count how often each
  occurs across all voice turns, then rank to get the top 3.

  Uses: voice turns (error_type, detected_intent). Run with: dbt compile, then
  run the compiled SQL in your warehouse, or use as reference for your analysis.
*/
with
-- Friction from error_type: each turn with an error (misunderstanding, silence, etc.) counts
errors as (
    select
        coalesce(nullif(trim(error_type), ''), 'unknown_error') as friction_point,
        count(*) as occurrence_count
    from {{ ref('stg_voice_turns') }}
    where error_type is not null and trim(error_type) != ''
    group by 1
),
-- Friction from "repeat" intent: user or system had to repeat
repeats as (
    select
        'repeat_intent' as friction_point,
        count(*) as occurrence_count
    from {{ ref('stg_voice_turns') }}
    where detected_intent = 'repeat'
),
combined as (
    select friction_point, occurrence_count from errors
    union all
    select friction_point, occurrence_count from repeats
),
totals as (
    select friction_point, sum(occurrence_count) as occurrence_count
    from combined
    group by friction_point
)
select
    friction_point,
    occurrence_count,
    row_number() over (order by occurrence_count desc) as friction_rank
from totals
order by occurrence_count desc
limit 3
