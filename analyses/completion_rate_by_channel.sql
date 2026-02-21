/*
  Part 3b(i): Compare completion rates — Voice vs non-voice channels.

  We use applications: for each channel (voice, ussd, web), what % of
  applications have status = 'completed'. That shows whether users complete
  more often on Voice AI vs other channels.

  Uses: stg_applications (channel, status). Run with: dbt compile, then
  execute the compiled SQL in your warehouse.
*/
select
    channel,
    count(*) as total_applications,
    sum(case when status = 'completed' then 1 else 0 end) as completed_applications,
    round(100.0 * sum(case when status = 'completed' then 1 else 0 end) / nullif(count(*), 0), 2) as completion_rate_pct
from {{ ref('stg_applications') }}
group by channel
order by completion_rate_pct desc
