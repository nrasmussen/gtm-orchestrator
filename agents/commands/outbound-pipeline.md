---
description: Run the full 5-stage outbound pipeline on a company CSV
argument: file path to CSV with company data
---

# Outbound Pipeline Orchestrator

Run all 5 pipeline agents sequentially on the provided CSV file.

## Step 1: Validate Input

Read the file at `$ARGUMENTS`. Verify it exists and contains at minimum a `company_name` column (or common variants like `Company name`, `company`, `name`, `Company`).

The Signal Scraper agent will handle:
- Adding missing columns
- Researching companies via web search to fill empty fields
- Normalizing the CSV structure

So the only hard requirement is that company names are present.

Count the number of companies (data rows) and report: "Processing N companies through the pipeline..."

If the CSV has sparse data (many empty fields), inform the user: "Input data is sparse — the Signal Scraper will auto-enrich via web search before extracting signals."

## Step 2: Run Pipeline

Run these 5 agents **sequentially** using the Task tool. Each agent must complete before the next starts. Between each step, verify the output file was created.

### Stage 1: Signal Scraper (with auto-enrichment)
Use the Task tool to spawn the `signal-scraper` agent:
- Prompt: "Read the CSV at `$ARGUMENTS` and extract all buying signals. If the CSV is missing columns or has empty fields, enrich the data via web search first. Write enriched data to `output/0-enriched.csv` (if enrichment was needed) and signals to `output/1-signals.csv`."
- After completion, verify `output/1-signals.csv` exists using Read tool
- If `output/0-enriched.csv` was created, report: "Auto-enriched N companies via web search → output/0-enriched.csv"

### Pause & Review (after enrichment, before scoring)

If `output/0-enriched.csv` was created (meaning enrichment happened), **pause and show the user the enriched data**:

1. Read `output/0-enriched.csv` and display a summary table showing each company with its enriched fields
2. Ask the user: "The Signal Scraper auto-enriched your company data via web search. Please review the enriched data above. Would you like to continue with this data, or edit `output/0-enriched.csv` first?"
3. Wait for the user to confirm before proceeding
4. If the user says to continue, proceed to Stage 2
5. If the user wants to edit, stop the pipeline and tell them to re-run after editing

If no enrichment was needed (input was already complete), skip this pause and continue.

### Stage 2: Lead Prioritizer
Use the Task tool to spawn the `lead-prioritizer` agent:
- Prompt: "Read `output/1-signals.csv`, score and prioritize all leads. Write results to `output/2-prioritized.csv`."
- After completion, verify `output/2-prioritized.csv` exists

### Stage 3: Prospect Profiler
Use the Task tool to spawn the `prospect-profiler` agent:
- Prompt: "Read `output/2-prioritized.csv`, build prospect profiles. Write results to `output/3-profiles.csv`."
- After completion, verify `output/3-profiles.csv` exists

### Stage 4: Hook Writer
Use the Task tool to spawn the `hook-writer` agent:
- Prompt: "Read `output/3-profiles.csv`, write personalized opening lines. Write results to `output/4-hooks.csv`."
- After completion, verify `output/4-hooks.csv` exists

### Stage 5: Sequence Builder
Use the Task tool to spawn the `sequence-builder` agent:
- Prompt: "Read `output/4-hooks.csv` and `output/3-profiles.csv`, build 7-touch sequences for each company. Write results to `output/5-sequences.csv`."
- After completion, verify `output/5-sequences.csv` exists

## Step 3: Report Results

After all 5 stages complete, report:

```
Pipeline complete!

Stage 0 — Data Enrichment:  N companies enriched via web search  → output/0-enriched.csv (if applicable)
Stage 1 — Signal Scraper:    X signals found across N companies → output/1-signals.csv
Stage 2 — Lead Prioritizer:  N companies scored and tiered     → output/2-prioritized.csv
Stage 3 — Prospect Profiler: N prospect profiles built          → output/3-profiles.csv
Stage 4 — Hook Writer:       N opening lines crafted            → output/4-hooks.csv
Stage 5 — Sequence Builder:  X sequence steps generated         → output/5-sequences.csv
```

Read each output file to get the actual row counts. Show the final sequences file path prominently.
