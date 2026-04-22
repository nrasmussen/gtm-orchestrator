# Case Study One-Pager

## Purpose

Generate a concise one-page case study that can be shared during sales conversations, added to a proposal, or published on a website. This format gives prospective buyers a fast, credible proof point without requiring them to read a long-form document.

## Prompt

```
You are a B2B content writer specializing in customer case studies. Write a one-page case study based on the following details.

Customer name or anonymized label: [COMPANY NAME OR "A MID-SIZE LOGISTICS COMPANY"]
Customer description: [INDUSTRY, SIZE, LOCATION IF RELEVANT]
Your product or service: [WHAT WAS PROVIDED]
The situation before: [WHAT THE CUSTOMER WAS STRUGGLING WITH, IN SPECIFIC TERMS]
Why they chose you: [THE 1-2 REASONS THEY SELECTED THIS SOLUTION]
What was implemented: [WHAT WAS DONE, AT A SUMMARY LEVEL — NO NEED FOR TECHNICAL DEPTH]
Timeline: [HOW LONG IMPLEMENTATION TOOK — OR "WITHIN [X] WEEKS"]
Results achieved: [QUANTIFIED OUTCOMES — REVENUE GAINED, TIME SAVED, COST REDUCED, ETC.]
Customer quote: [A REAL OR REPRESENTATIVE QUOTE — OR "[INSERT QUOTE]"]
What they do now: [HOW THEY USE THE PRODUCT TODAY, ONE SENTENCE]

Structure the output with these sections:
1. Header — customer name/label, a results-led headline (e.g., "How [Customer] reduced churn by 40% in 90 days")
2. The Situation — 2-3 sentences on the challenge they faced before
3. The Approach — 2-3 sentences on what was implemented and how
4. The Results — a stat block with 3 key metrics, each with a label and number
5. In Their Words — the customer quote, attributed
6. What Changed — one paragraph on the current state and ongoing impact
7. About [Company Name] — two-sentence boilerplate

Keep the total under 300 words. Lead with outcomes. Every section should give a prospective buyer a reason to believe your solution will work for them too.
```

## Example Output Description

A results-led document with a bold headline metric in the title. The results section presents three stats in a visual block (e.g., "40% reduction in churn," "3 weeks to first value," "$120K saved annually"). The quote is clearly attributed. The about section is minimal and factual.

## Suggested Pairing Hook

`claude-design-output-to-notion` — pushes the case study to a Notion content library. Pair with `typefully-draft-queue` if you want to immediately draft a LinkedIn post adapting the case study for social distribution.
