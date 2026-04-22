# Internal Strategy Deck

## Purpose

Generate a structured internal strategy deck for presenting a plan, initiative, or quarterly direction to your team, leadership, or board. This deck is not for external audiences — it is for alignment and decision-making inside the organization.

## Prompt

```
You are an internal communications writer and strategy consultant. Write a complete internal strategy deck for the following initiative.

Organization or team name: [NAME]
Initiative title: [WHAT IS BEING PROPOSED OR PRESENTED]
Audience: [WHO WILL READ THIS — LEADERSHIP, FULL TEAM, BOARD, ETC.]
Time horizon: [QUARTER, HALF-YEAR, YEAR, ETC.]
Current situation: [WHERE THINGS STAND TODAY — KEY FACTS, METRICS, CONTEXT]
Goal: [WHAT SUCCESS LOOKS LIKE AT THE END OF THE TIME HORIZON]
Strategic options considered: [LIST 2-3 PATHS THAT WERE EVALUATED]
Recommended option: [WHICH PATH YOU ARE RECOMMENDING AND WHY]
Resources required: [HEADCOUNT, BUDGET, TOOLS, TIMELINE]
Key risks: [TOP 2-3 RISKS AND HOW YOU PLAN TO MITIGATE THEM]
Decision needed from this audience: [WHAT YOU ARE ASKING THEM TO APPROVE OR ALIGN ON]

Write a slide-by-slide outline with:
- Slide title
- Core message of the slide (one sentence)
- Content: structured bullets, tables, or frameworks as appropriate
- Facilitator note: what to say, what discussion to invite, what decision to capture

Suggested slide structure:
1. Context — where we are today, why this matters now
2. Goal — what we are trying to achieve and how we will measure it
3. Options — the paths considered, with tradeoffs for each
4. Recommendation — the chosen path with rationale
5. Plan — key workstreams, owners, and timeline (as a simple table)
6. Resources — what is needed and what it costs
7. Risks — top risks, likelihood, mitigation
8. Decision — the specific ask from this group today

Use plain language. Avoid corporate filler. Quantify everything that can be quantified. Where numbers are unknown, write "[DATA NEEDED]" so the presenter knows what to gather before the meeting.
```

## Example Output Description

An eight-section document written in direct, factual prose. The context slide includes 2-3 quantified facts about the current situation. The options slide presents a simple 3-column comparison table. The plan slide has a table with workstream, owner, and target date columns. The decision slide ends with a single bolded question for the room.

## Suggested Pairing Hook

`notion-session-log` — logs the session to Notion so the strategy document is immediately available to collaborators, or `claude-design-output-to-notion` to push the full content into a dedicated Notion page.
