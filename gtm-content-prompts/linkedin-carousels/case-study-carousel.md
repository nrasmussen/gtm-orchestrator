# Case Study Carousel

## Purpose

Generate a LinkedIn carousel that tells the story of a customer win or project result in a format designed for the feed. Case study carousels build trust with prospects because they are specific, story-driven, and prove results rather than claiming them. Use this when you want to convert attention into pipeline.

## Prompt

```
You are a LinkedIn content strategist and B2B case study writer. Write a 9-slide case study carousel based on the following details.

Author or company name: [NAME]
Customer name or label: [COMPANY NAME — OR "A SERIES B FINTECH STARTUP"]
Customer's industry and size: [DETAILS]
The situation before: [WHAT THEY WERE STRUGGLING WITH — SPECIFIC AND CONCRETE]
What you did: [YOUR SOLUTION OR APPROACH, 2-3 SENTENCES]
Timeline: [HOW LONG THE ENGAGEMENT OR RESULT TOOK]
Results: [3 SPECIFIC METRICS — BEFORE AND AFTER IF POSSIBLE]
Customer quote: [REAL OR REPRESENTATIVE — OR "[INSERT QUOTE]"]
Who in the audience would benefit from reading this: [TARGET READER]

Write 9 slides:
Slide 1: Hook — lead with the result. Example: "We helped [Customer] [result] in [timeframe]. Here's exactly how."
Slide 2: Who the customer is — one paragraph setting the context without jargon
Slide 3: The problem — what they were dealing with before, in specific terms, with a quantified cost or impact if possible
Slide 4: Why they picked us — the 1-2 reasons they chose this solution over alternatives
Slide 5: The approach — what was done, broken into 2-3 clear phases or actions
Slide 6: What changed first — the earliest signal that it was working
Slide 7: The full results — the three metrics, presented clearly with before/after or absolute numbers
Slide 8: In their words — the customer quote, full and attributed (or "[INSERT QUOTE]")
Slide 9: What this means for you — connect the reader to the result, then give a CTA

For each slide, write:
- Slide headline (under 8 words)
- Body copy (3-5 lines)
- Visual direction

Do not exaggerate. Write only what is substantiated. Where data is unavailable, mark "[INSERT METRIC]" clearly.
```

## Example Output Description

A nine-slide story arc. Slide 1 leads with a bold result and a "here's how" hook. Slides 3 and 7 are the most data-dense, presenting specific before/after numbers. Slide 8 gives the quote maximum space. Slide 9 ends with a direct connection to the reader ("If your team is dealing with X, this is how we approach it") and a specific CTA.

## Suggested Pairing Hook

`typefully-draft-queue` — queues the carousel for scheduling immediately. Pair with `claude-design-output-to-notion` to archive the case study story in Notion for future use in proposals and decks.
