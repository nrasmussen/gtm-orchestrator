# ICP Summary One-Pager

## Purpose

Generate a one-page ideal customer profile document for internal alignment. Use this to ensure sales, marketing, and product teams are working from the same definition of who the best-fit customer is, and why.

## Prompt

```
You are a go-to-market strategist. Write a one-page ideal customer profile (ICP) document based on the following inputs.

Company or product name: [NAME]
What the product does: [ONE-SENTENCE DESCRIPTION]
Best customers to date (describe 2-3 if possible): [COMPANY TYPES, SIZES, OR NAMES]
Worst-fit customers (if known): [WHO CHURNS OR COMPLAINS]
Firmographic criteria:
  - Industries: [LIST]
  - Company size: [EMPLOYEE COUNT OR REVENUE RANGE]
  - Geography: [REGIONS OR "GLOBAL"]
  - Business model: [B2B / B2C / ENTERPRISE / SMB / ETC.]
Technographic criteria (tools they use): [CRM, DATA STACK, TECH STACK SIGNALS — OR "NOT YET DEFINED"]
Trigger events that indicate buying readiness: [HIRING SURGE, FUNDING ROUND, NEW LEADERSHIP, ETC.]
Primary buyer persona: [JOB TITLE, DEPARTMENT]
Economic buyer (who signs): [JOB TITLE, DEPARTMENT]
Core pain this ICP has: [THE BUSINESS PROBLEM IN THEIR OWN LANGUAGE]
What makes them qualified (not just a fit, but ready to buy): [CRITERIA]

Structure the output with these sections:
1. ICP Name — a short label for this profile (e.g., "Growth-Stage SaaS Operations Lead")
2. Who They Are — firmographic and technographic snapshot in a table or structured list
3. Why They Buy — the pain, the trigger event, the desired outcome
4. Who Is Involved — buyer persona, economic buyer, potential blockers
5. Qualification Signals — the 3-5 indicators that make this account a priority right now
6. Disqualification Signals — the 3-5 reasons to walk away fast
7. Messaging Hook — one headline sentence that would stop this buyer mid-scroll

Keep the document under 400 words. Make every criterion actionable — a sales rep should be able to read this and immediately know whether a new account qualifies.
```

## Example Output Description

A structured document with a named ICP profile at the top. The "Who They Are" section is a two-column list of firmographic criteria. The qualification signals are numbered 1-5. The disqualification signals are equally specific. The messaging hook is a single sentence written in the buyer's language.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the ICP to a Notion wiki page. Pair with `attio-upsert-company` if you want to immediately test the ICP against accounts already in your CRM.
