# Pricing Page

## Purpose

Generate the copy and structure for a pricing page. A pricing page must do four things: help the visitor self-select the right plan, build confidence that the price is justified, overcome the top 2-3 objections before they arise, and make the next step obvious. Use this when building or rewriting a pricing page for a website.

## Prompt

```
You are a conversion copywriter specializing in SaaS and services pricing pages. Write a complete pricing page based on the following inputs.

Product or service name: [NAME]
Company name: [COMPANY NAME]
Target visitor: [WHO LANDS ON THIS PAGE — JOB TITLE, COMPANY TYPE, BUYING STAGE]
Pricing model: [FLAT / TIERED / USAGE-BASED / SEAT-BASED / CONTACT US / HYBRID]
Plans (describe up to 4):
  Plan 1: Name: [NAME] | Price: [PRICE] | Who it is for: [DESCRIPTION] | Included: [KEY FEATURES]
  Plan 2: Name: [NAME] | Price: [PRICE] | Who it is for: [DESCRIPTION] | Included: [KEY FEATURES]
  Plan 3: Name: [NAME] | Price: [PRICE] | Who it is for: [DESCRIPTION] | Included: [KEY FEATURES]
  Plan 4 (optional): Name: [NAME] | Price: [PRICE / CONTACT] | Who it is for: [DESCRIPTION] | Included: [KEY FEATURES]
Features shared across all plans: [LIST]
Most popular plan: [PLAN NAME — OR "DO NOT HIGHLIGHT ONE"]
Annual vs monthly pricing: [DISCOUNT FOR ANNUAL — OR "MONTHLY ONLY"]
Free trial or freemium: [YES — [TERMS] / NO]
Money-back or satisfaction guarantee: [DETAILS — OR "NONE"]
Top 3 objections visitors have before buying: [OBJECTION 1], [OBJECTION 2], [OBJECTION 3]
Social proof available: [CUSTOMER LOGOS, REVIEW COUNTS, QUOTES, RATINGS — OR "NONE YET"]
Primary CTA: [WHAT YOU WANT THEM TO DO — START TRIAL, BOOK DEMO, CONTACT SALES, ETC.]

Write the pricing page with these sections:
1. Page headline — outcome-focused, not product-focused (what they achieve, not what the product is)
2. Subheadline — 1-2 sentences expanding on the headline, addressing the visitor's decision context
3. Plan comparison — the full pricing table with all plans, prices, and included features
4. FAQ — answers to the top 3 objections plus 2-3 common questions (billing cycle, cancellation, support level)
5. Social proof block — how to present the available proof, or placeholder if none
6. Final CTA block — a closing section that restates the primary action with a low-friction message

For each FAQ answer, write in plain language and anticipate the follow-up question. Do not use phrases like "we're happy to help" — be direct and specific.
```

## Example Output Description

A six-section page document. The headline is a single line focused on the buyer's outcome. The plan table has each plan as a column with a "Most Popular" badge on one. The FAQ section has 5-6 questions with 2-4 sentence answers. The social proof block describes where to place logos, a review count, and a short quote. The final CTA block has a headline, one line of reassurance (e.g., "no credit card required"), and the CTA button label.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the pricing page copy to Notion for review and iteration. Pair with `linear-ticket-from-brief` to create a ticket for the design team to implement the page layout.
