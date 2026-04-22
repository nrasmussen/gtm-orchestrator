# Buyer Persona Card

## Purpose

Generate a detailed buyer persona card for a specific decision-maker or influencer in your sales process. Use this for sales enablement, messaging alignment, and onboarding new reps. A persona card answers the question: "Who exactly are we selling to, and what do they care about?"

## Prompt

```
You are a go-to-market strategist and sales enablement writer. Write a buyer persona card based on the following inputs.

Persona name (a descriptive label, not a made-up first name): [E.G., "HEAD OF REVENUE OPERATIONS" OR "GROWTH-STAGE CMO"]
Job title or title range: [EXACT TITLES THIS PERSON HOLDS]
Company type: [INDUSTRY, SIZE, STAGE — E.G., "SERIES B SAAS, 50-200 EMPLOYEES"]
Primary responsibility: [WHAT THEY ARE ACCOUNTABLE FOR AT WORK]
What success looks like for them: [HOW THEIR PERFORMANCE IS MEASURED]
Day-to-day pain: [THE RECURRING FRUSTRATION OR BOTTLENECK IN THEIR WORK]
Strategic pain: [THE BIGGER PROBLEM THAT KEEPS THEM UP AT NIGHT]
How they currently solve the problem: [THE EXISTING WORKAROUND, TOOL, OR PROCESS]
Why the current solution falls short: [THE GAP THAT CREATES THE BUYING OPPORTUNITY]
What they read or follow: [PUBLICATIONS, COMMUNITIES, NEWSLETTERS, INFLUENCERS]
How they prefer to buy: [SELF-SERVE / DEMO-LED / COMMITTEE / CHAMPION-LED / ETC.]
What makes them distrust a vendor: [THE RED FLAGS THAT KILL DEALS WITH THIS PERSONA]
Objections they raise most often: [LIST 3-5]
What language they use to describe the problem: [EXACT PHRASES — IN QUOTES IF POSSIBLE]

Write the persona card with these sections:
1. Persona Label and Role — name, titles, company context
2. Their World — responsibilities, success metrics, daily reality
3. The Pain — day-to-day friction and strategic pressure, in their words
4. How They Currently Cope — the workaround and its cost
5. What They Want — the ideal outcome if the problem were solved
6. How They Buy — buying process, typical timeline, who else is involved
7. What Wins Them Over — the message that lands, the proof that convinces them
8. What Loses Them — objections, red flags, deal-killers
9. How to Reach Them — channels, formats, tone

Keep the card under 500 words. Use plain, specific language. A new sales rep should be able to read this card and immediately adjust their outreach and call preparation.
```

## Example Output Description

A structured nine-section card. The pain section uses first-person language ("I need to know why our pipeline keeps stalling"). The what-wins-them-over section lists 2-3 specific proof types (e.g., "a peer reference from a company at their stage, not a Fortune 500 logo"). The objections section lists 3-5 verbatim-style phrases. The how-to-reach-them section names specific channels and formats.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the persona card to a Notion sales enablement wiki. Pair with `attio-upsert-company` if you want to update a CRM account with the persona context while you are working on it.
