

## Voice AI KPIs (dbt models)

This project implements the **Accessibility**, **Efficiency**, and **Adoption** KPIs for the Irembo Voice AI assignment as dbt models.

### How it’s organized (step by step)

1. **Seeds** (`seeds/`)  
   Your CSVs: `users`, `voice_sessions`, `voice_turns`, `voice_ai_metrics`, `applications`.  
   Load them with: `dbt seed`.

2. **Staging** (`models/staging/`)  
   One model per seed: clean column names and normalize values (e.g. `region` → `rural`/`urban`).  
   Built so all downstream models see consistent types and casing.

3. **Intermediate** (`models/intermediate/`)  
   Joins and flags used by the KPIs:
   - **int_sessions_with_users**: sessions + user attributes (region, `is_vulnerable`, first-time digital).
   - **int_session_service_outcomes**: per session, “had completed application?” and time-to-submit for completed apps.
   - **int_session_errors**: per session, “had error or timeout?” (repeated_errors, escalation, misunderstanding).
   - **int_turn_friction**: per session, total turns and repeat count (for friction KPI).

4. **Marts** (`models/marts/`)  
   - **fact_voice_ai_sessions**: Fact table — one row per Voice AI session, with user attributes (region, vulnerable, first-time digital), session measures (duration, turns, repeats), completion outcome, and error flag. This is the central table for analysis and for building the KPI marts.
   - **mart_accessibility_inclusivity**: One-row summary — rural_user_growth_pct, vulnerable_user_completion_rate_pct, first_time_digital_user_rate_pct, completion_gap_urban_minus_rural_pct, completion_gap_non_vulnerable_minus_vulnerable_pct.
   - **mart_efficiency**: One-row summary — avg_session_duration_sec, avg_turns_per_session, avg_repeats_per_session, session_error_timeout_rate_pct, avg_service_completion_time_sec.
   - **mart_adoption**: One-row summary — mau_latest_month, mau_month, user_retention_rate_pct, mom_growth_rate_pct, mom_growth_month, voice_ai_adoption_target_users_pct.

5. **Part 3 – Analyses** (`analyses/`)  
   SQL used for insight generation (run after `dbt run`; then run compiled SQL in your DB or DuckDB UI):
   - **friction_points.sql** — Top 3 friction points in Voice AI (errors + repeat intents).
   - **completion_rate_by_channel.sql** — Completion rate: voice vs USSD vs web.
   - **completion_rate_by_region.sql** — Completion rate: rural vs urban (Voice AI sessions).
   - **first_time_digital_users_analysis.sql** — For first-time digital users, completion rate by channel (Voice vs others).  
   See **analyses/PART3_INSIGHTS_SUMMARY.md** for how to turn results into 2–4 key insights for the report.

### Definitions used in the models

- **Vulnerable user**: `disability_flag = 'yes'` OR `first_time_digital_user = 'yes'` (no low-literacy column in the data; add it in `stg_users` / `int_sessions_with_users` if you have it).
- **Successful service completion**: session has at least one application with `status = 'completed'` and `channel = 'voice'`.
- **Session error/timeout**: `transfer_reason = 'repeated_errors'` OR `escalation_flag = 'yes'` OR `misunderstanding_rate > 0`.

### Run with DuckDB (local)

This project runs with **DuckDB** (no separate database server).

1. **Install dependencies** (from the project root):
   ```bash
   pip install -r requirements.txt
   ```
   Installs `dbt-core` and `dbt-duckdb`.

2. **Profile at the dbt root**  
   dbt looks for `profiles.yml` in **`~/.dbt/profiles.yml`** (your user directory, not inside the project).  
   Add or update the `irembo_voice_ai` profile there. For DuckDB, for example:
   ```yaml
   irembo_voice_ai:
     target: dev
     outputs:
       dev:
         type: duckdb
         path: target/irembo_voice_ai.duckdb   # or a full path, e.g. /path/to/irembo_voice_ai/target/irembo_voice_ai.duckdb
   ```
   If `path` is relative, it’s resolved from the directory where you run `dbt` (usually the project root).

3. **Run** (from the project root):
   ```bash
   dbt seed
   dbt run
   ```
   Then optionally: `dbt test`

**If you see “unknown variant duckdb”**  
That means the `dbt` in your path is **dbt-fusion** (or another fork that doesn’t support DuckDB). This project needs **standard dbt** (dbt-core) with the **dbt-duckdb** adapter. Do this in your project folder:

- Create a dedicated venv and install only the DuckDB stack:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate   # on Windows: .venv\Scripts\activate
  pip install -r requirements.txt
  ```
- Run with this env active so `dbt` is the one from `requirements.txt`:
  ```bash
  dbt seed
  dbt run
  ```
- If you previously had `dbt-fusion` (or similar) in this env, uninstall it first:  
  `pip uninstall dbt-fusion` (or the package name you see in `pip list`), then `pip install -r requirements.txt` again.

### View the data and docs

**1. In the browser (tables + KPIs)**  
From the project root, with the same env that has `dbt` and DuckDB:
```bash
pip install streamlit   # if not already in requirements.txt
streamlit run view_data.py
```
A tab opens with: Seeds, Staging, Intermediate, Fact & marts (including the one-row KPI tables), and a “Browse all” tab.

**2. Project lineage and model docs**  
After `dbt run`:
```bash
dbt docs generate
dbt docs serve
```
Open the URL shown (e.g. http://localhost:8080) to see the DAG and model descriptions (no row data).

### Other warehouses

For Postgres, BigQuery, Snowflake, etc., put the right connection in `~/.dbt/profiles.yml` under profile `irembo_voice_ai`. For BigQuery, in `mart_adoption.sql` change `date_trunc('month', session_date)::date` to `date_trunc(session_date, month)`.

---

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
