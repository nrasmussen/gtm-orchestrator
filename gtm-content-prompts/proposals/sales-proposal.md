# Sales Proposal

## Purpose

Generate a complete sales proposal document to send after a discovery call or demo. A good proposal does three things: confirms you understood the buyer's problem, presents a clear and credible solution, and makes it easy for them to say yes. Use this when you need to move a qualified opportunity to close.

## Prompt

```
You are a sales writer and proposal specialist. Write a complete sales proposal based on the following inputs.

Your company name: [COMPANY NAME]
Your product or service: [WHAT IS BEING PROPOSED]
Prospect company name: [BUYER COMPANY NAME]
Primary contact name and title: [NAME, TITLE]
Date: [DATE — OR "TO BE FILLED"]
What we learned in discovery (their situation): [KEY FACTS, PAIN POINTS, AND GOALS SURFACED IN DISCOVERY CALLS]
What they want to achieve: [THEIR STATED GOALS — IN THEIR OWN LANGUAGE IF POSSIBLE]
What we are proposing: [THE SPECIFIC SOLUTION, PACKAGE, OR ENGAGEMENT]
Scope of work (what is included): [LIST OF DELIVERABLES, ACCESS, FEATURES, OR SERVICES]
What is not included: [EXPLICIT EXCLUSIONS TO AVOID SCOPE CREEP]
Proposed timeline: [START DATE, KEY MILESTONES, END DATE OR RENEWAL DATE]
Investment: [PRICE, PAYMENT TERMS, BILLING SCHEDULE]
Why now: [WHY STARTING THIS MONTH OR QUARTER MAKES SENSE FOR THEM]
Risk reduction or guarantee (if applicable): [TRIAL, MONEY-BACK, SLA, ONBOARDING SUPPORT, ETC.]
Next steps: [WHAT NEEDS TO HAPPEN TO MOVE FORWARD]

Write the proposal with these sections:
1. Cover — to/from/date block, document title
2. Summary — 3-5 sentences restating the buyer's situation, goal, and what you are proposing. This should read like you were listening.
3. The Challenge — 2-3 paragraphs expanding on the problem in the buyer's language, with the cost of inaction clearly stated
4. Our Proposed Solution — describe the solution clearly, connect each element to a specific need identified in discovery
5. Scope of Work — a table or structured list of exactly what is included
6. Timeline — a simple milestone table (phase, description, date)
7. Investment — clear pricing with payment terms
8. Why Now — the business case for starting this month
9. Next Steps — numbered, with clear ownership and dates

Write in the second person. Avoid vague value claims. Every paragraph in sections 2-4 should reference something learned in discovery. Keep the total under 800 words.
```

## Example Output Description

A structured nine-section proposal. The summary section uses the buyer's exact language from discovery. The scope of work is a table with two columns: deliverable and description. The timeline table has three columns: phase, what happens, and target date. The investment section includes the price, a one-line explanation of billing, and the payment schedule. Next steps are numbered 1-3 with owner labels.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the proposal to a Notion deal room page. Pair with `hubspot-upsert-contact` or `attio-upsert-company` to update the associated CRM deal stage when the proposal is generated.
