# Internal Win Write-Up

## Purpose

Generate an internal document that captures a significant win — a closed deal, a retention save, a successful launch, or a process improvement — in a structured format. Use this to share learnings across the team, build institutional memory, and recognize the people involved.

## Prompt

```
You are an internal communications writer. Write an internal win write-up based on the following details.

Team or company name: [NAME]
Type of win: [CLOSED DEAL / RETENTION SAVE / PRODUCT LAUNCH / PROCESS IMPROVEMENT / PARTNERSHIP / OTHER]
Win summary in one sentence: [WHAT HAPPENED AND WHY IT MATTERS]
Date or period: [WHEN THIS OCCURRED]
People involved: [NAMES AND ROLES OF TEAM MEMBERS WHO CONTRIBUTED]
What happened — the story: [DESCRIBE THE SEQUENCE OF EVENTS, KEY ACTIONS TAKEN, AND DECISIONS MADE]
What made the difference: [THE 1-2 FACTORS THAT DETERMINED THE OUTCOME]
The result: [QUANTIFIED OUTCOME — REVENUE, RETENTION RATE, TIME SAVED, ETC.]
What we learned: [WHAT WORKED, WHAT TO REPLICATE, WHAT SURPRISED US]
What we would do differently: [HONEST REFLECTION — EVEN IF THE WIN WAS CLEAN, THERE IS USUALLY SOMETHING]
Who to notify or recognize: [NAMES TO CALL OUT PUBLICLY, CHANNEL TO SHARE IN]

Structure the write-up as:
1. Win Headline — a title that would make the team excited to read it (specific, not generic)
2. The Short Version — a 3-bullet TL;DR for busy readers
3. Context — 1-2 paragraphs on the background and why this win was hard or important
4. What We Did — a chronological account, written as a narrative with named contributors
5. The Result — quantified outcomes in a clear format (table or bullet list)
6. Key Learnings — three numbered takeaways, each with a one-line label and a 2-3 sentence explanation
7. What to Replicate — a short list of specific behaviors or actions to standardize
8. Recognition — names and specific contributions of everyone involved

Keep the total under 500 words. Write in plain language. The goal is clarity and replication, not celebration for its own sake.
```

## Example Output Description

A structured internal document with a specific, energetic headline. The TL;DR section has exactly three bullets. The what-we-did section reads as a short narrative with named individuals and dates. The result section has 2-4 metrics. The key learnings section has three numbered items, each with a short label like "Why first response time mattered." Recognition is the final section and names each contributor with one specific sentence.

## Suggested Pairing Hook

`notion-session-log` — logs the write-up to a Notion wins database. Pair with `slack-ping-on-stop` to send a Slack notification when the write-up is ready so it can be shared with the team immediately.
