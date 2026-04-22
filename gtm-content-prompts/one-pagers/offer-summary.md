# Offer and Pricing Summary One-Pager

## Purpose

Generate a clear, persuasive offer summary that explains what is included, what it costs, and what the buyer gets for their investment. Use this as a leave-behind after a sales conversation, an attachment to a proposal, or a page on your website.

## Prompt

```
You are a pricing and offer copywriter. Write a one-page offer summary for the following product or service.

Product or service name: [NAME]
Company name: [COMPANY NAME]
Target buyer: [JOB TITLE AND COMPANY TYPE]
Core promise: [WHAT THE BUYER WILL ACHIEVE BY USING THIS — ONE SENTENCE]
Pricing tiers (describe up to 3):
  - Tier 1 name: [NAME] | Price: [PRICE OR "CONTACT US"] | Who it is for: [DESCRIPTION]
  - Tier 2 name: [NAME] | Price: [PRICE] | Who it is for: [DESCRIPTION]
  - Tier 3 name: [NAME] | Price: [PRICE] | Who it is for: [DESCRIPTION]
What is included in each tier (list the key line items): [LIST]
What is NOT included (common add-ons or exclusions): [LIST — OR "ALL FEATURES INCLUDED"]
Billing model: [MONTHLY / ANNUAL / ONE-TIME / USAGE-BASED]
Discount or incentive: [ANNUAL DISCOUNT, PILOT OFFER, MONEY-BACK GUARANTEE, ETC. — OR "NONE"]
Most popular or recommended tier: [TIER NAME — OR "ALL ARE EQUALLY POSITIONED"]
Onboarding or support included: [WHAT HELP THE BUYER GETS AFTER SIGNING]
Call to action: [URL, EMAIL, OR NEXT STEP]

Structure the output as:
1. Header — product name, core promise, company name
2. Pricing Table — a clearly formatted comparison of all tiers: features, limits, and price
3. What Is Included — a short narrative paragraph on the core deliverables
4. What Happens After You Sign — 3-4 bullet points on onboarding and support
5. Frequently Asked Questions — 3 questions a buyer typically asks before deciding, with direct answers
6. Get Started — CTA

Write with clarity and specificity. Avoid vague phrases like "robust" or "enterprise-grade." Every line should help the buyer understand the value relative to the cost.
```

## Example Output Description

A structured document with a comparison table in the center. Each tier has a name, price, and 4-6 included items with checkmarks or clear labels. The FAQ section answers three real buying objections. The CTA is direct and ties back to the core promise.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the offer summary to Notion for version control across pricing iterations. Pair with `typefully-draft-queue` to repurpose the core promise and FAQ answers for social content.
