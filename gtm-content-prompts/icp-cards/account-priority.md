# Account Priority Card

## Purpose

Generate an account priority card for a specific target company. Use this during account planning, before an outbound sequence, or to brief a sales rep going into discovery. An account priority card answers: "Why this account, why now, and what is the angle?"

## Prompt

```
You are a strategic account planner and sales researcher. Write an account priority card based on the following inputs.

Account name: [COMPANY NAME]
Account website: [URL — OR "NOT YET RESEARCHED"]
Industry: [SECTOR]
Company size: [EMPLOYEE COUNT AND/OR REVENUE]
Stage or funding: [BOOTSTRAPPED / SERIES A / PUBLIC / ETC.]
Why this account is a priority now: [TRIGGER EVENTS — FUNDING, HIRING, NEW EXEC, EXPANSION, NEWS, ETC.]
Primary contact (if known): [NAME, TITLE, AND LINKEDIN URL — OR "TO BE IDENTIFIED"]
What we know about their current situation: [RELEVANT CONTEXT — TECH STACK, INITIATIVES, PAIN SIGNALS]
Our hypothesis for why they need us: [THE SPECIFIC PROBLEM WE BELIEVE THEY HAVE]
Competing solutions they may use: [KNOWN TOOLS OR VENDORS — OR "UNKNOWN"]
Our strongest point of differentiation for this account: [WHY US OVER THE ALTERNATIVE]
Ideal outcome of first contact: [INTRO CALL / DEMO / TRIAL / REFERRAL / OTHER]
Relevant proof points for this account: [CASE STUDIES, CUSTOMER NAMES, METRICS THAT RESONATE WITH THEIR PROFILE]

Write the account priority card with these sections:
1. Account Snapshot — name, size, stage, industry, website
2. Why Now — the specific trigger events or signals that make this the right moment to reach out
3. The Hypothesis — a 2-3 sentence theory of the pain and why we are the right solution
4. Key Contacts — known contacts with titles and engagement history, or a description of who to find
5. Competitive Context — what they are likely using today and where the gaps are
6. Our Angle — the specific message, proof point, and differentiation that fits this account
7. Recommended First Move — the specific action, channel, and message type to open the account
8. Open Questions — the 3-5 things we need to learn in the first conversation

Keep the card under 400 words. Every section must be specific to this account — no generic filler. If a field is unknown, mark it "[RESEARCH NEEDED]" rather than leaving it vague.
```

## Example Output Description

A tightly structured card focused entirely on one account. The "why now" section lists 2-3 specific trigger events with dates. The hypothesis is written in cause-and-effect form. The angle section recommends one specific message with a named proof point. The recommended first move names a specific outreach channel and format. Open questions are numbered 1-5.

## Suggested Pairing Hook

`attio-upsert-company` — immediately syncs the account data and priority status to your CRM. Pair with `lemlist-push-sequence` if you want to add the account's key contacts to an outbound sequence right after building the card.
