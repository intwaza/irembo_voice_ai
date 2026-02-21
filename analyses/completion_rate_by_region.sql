/*
  Part 3b(ii): Compare completion rates — Rural vs urban users.

  We use the fact table (Voice AI sessions only): for rural vs urban users,
  what % of sessions had a completed application (had_completed_application = 1).
  So we compare completion success by user region.

  Uses: fact_voice_ai_sessions (region, had_completed_application). Run with:
  dbt compile, then execute the compiled SQL in your warehouse.
*/
select
    region,
    count(*) as total_sessions,
    sum(had_completed_application) as completed_sessions,
    round(100.0 * sum(had_completed_application) / nullif(count(*), 0), 2) as completion_rate_pct
from {{ ref('fact_voice_ai_sessions') }}
group by region
order by region
