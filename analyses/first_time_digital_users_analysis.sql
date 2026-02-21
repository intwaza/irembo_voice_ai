/*
  Part 3c: Do first-time digital users perform better with Voice AI vs other channels?

  We take users who are first_time_digital_user = 'yes', join to their
  applications (by user_id), and compute completion rate by channel. If
  completion_rate_pct is higher for voice than for ussd/web, Voice AI is
  performing better for this group.

  Uses: stg_users (first_time_digital_user), stg_applications (user_id, channel, status).
  Run with: dbt compile, then execute the compiled SQL in your warehouse.
*/
select
    a.channel,
    count(*) as total_applications,
    sum(case when a.status = 'completed' then 1 else 0 end) as completed_applications,
    round(100.0 * sum(case when a.status = 'completed' then 1 else 0 end) / nullif(count(*), 0), 2) as completion_rate_pct
from {{ ref('stg_applications') }} a
join {{ ref('stg_users') }} u on a.user_id = u.user_id
where u.first_time_digital_user = 'yes'
group by a.channel
order by completion_rate_pct desc
