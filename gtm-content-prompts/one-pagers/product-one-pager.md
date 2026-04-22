# Product Overview One-Pager

## Purpose

Generate a single-page product overview document suitable for leaving behind after a sales call, attaching to an email, or posting on a website as a downloadable asset. The goal is to give a reader everything they need to understand the product in under two minutes.

## Prompt

```
You are a product marketing writer. Write a single-page product overview document for the following product.

Product name: [PRODUCT NAME]
Company name: [COMPANY NAME]
Target buyer: [JOB TITLE AND COMPANY TYPE]
The problem it solves: [THE PAIN IN THE BUYER'S OWN LANGUAGE]
What the product does: [CORE FUNCTIONALITY IN ONE PARAGRAPH]
Top 3 features or capabilities: [FEATURE 1], [FEATURE 2], [FEATURE 3]
Key benefit for each feature: [BENEFIT 1], [BENEFIT 2], [BENEFIT 3]
Proof point: [A METRIC, CUSTOMER QUOTE, OR CASE STUDY REFERENCE — OR "[INSERT PROOF]"]
Integrations or compatibility: [TOOLS IT WORKS WITH — OR "WORKS WITH YOUR EXISTING STACK"]
Pricing overview: [STARTING PRICE OR MODEL — OR "CONTACT FOR PRICING"]
Call to action: [WHAT TO DO NEXT — URL, EMAIL, PHONE, ETC.]

Structure the output as a formatted one-pager with these sections:
1. Header — product name, tagline (one punchy sentence), company name
2. The Problem — 2-3 sentences describing the pain in the buyer's voice
3. What [Product Name] Does — a 3-5 sentence product description, benefit-led
4. Key Capabilities — three blocks, each with a feature name, one-line description, and the business outcome it drives
5. Results — the proof point, formatted as a pull quote or stat block
6. Works With — a short list of compatible tools or a brief sentence
7. Pricing — one or two sentences on how pricing works
8. Get Started — CTA with contact information or URL

Write in second person ("your team"). Keep the total word count under 350 words. Every sentence must earn its place — cut anything that does not help the buyer decide.
```

## Example Output Description

A clean document with eight labeled sections totaling approximately 280-320 words. The header has a product name and a 6-10 word tagline. The capabilities section has three blocks, each with a bolded feature name and two short lines of copy. The results section presents a metric or quote in a visually distinct block. The get started section has a single, clear action.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the one-pager to Notion where it can be formatted and shared. Pair with `notion-content-archive` if you want all product content archived in a single database.
