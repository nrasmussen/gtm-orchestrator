# Scope of Work Document

## Purpose

Generate a clear, complete scope of work document to accompany a contract or proposal. A scope of work removes ambiguity about what is included, what is not, who is responsible for what, and how success is defined. Use this to protect both parties and prevent project disputes.

## Prompt

```
You are a project scoping and contracts writer. Write a complete scope of work document based on the following inputs.

Your company name: [COMPANY NAME]
Client company name: [CLIENT NAME]
Project or engagement name: [TITLE]
Effective date: [DATE — OR "[TO BE FILLED]"]
Project summary: [WHAT THIS ENGAGEMENT IS ABOUT IN 1-2 SENTENCES]
Objectives: [WHAT THE CLIENT WANTS TO ACHIEVE — LIST 2-4 SPECIFIC GOALS]
Deliverables (what you will provide): [LIST EACH DELIVERABLE WITH A BRIEF DESCRIPTION]
What is explicitly not included: [LIST ANYTHING THAT MIGHT BE ASSUMED BUT IS OUT OF SCOPE]
Client responsibilities: [WHAT THE CLIENT MUST PROVIDE OR DO FOR THIS TO SUCCEED — MATERIALS, ACCESS, APPROVALS, CONTACTS, ETC.]
Phases and timeline:
  Phase 1: [NAME] — [DESCRIPTION] — [DURATION OR DATE]
  Phase 2: [NAME] — [DESCRIPTION] — [DURATION OR DATE]
  (Add as many phases as needed)
Acceptance criteria: [HOW WILL WE BOTH KNOW WHEN EACH DELIVERABLE IS DONE AND APPROVED]
Change order process: [WHAT HAPPENS WHEN SCOPE CHANGES — HOW IT IS REQUESTED, PRICED, AND APPROVED]
Communication and review cadence: [MEETING FREQUENCY, POINT OF CONTACT, TURNAROUND TIME FOR FEEDBACK]
Fees and payment schedule: [TOTAL FEE, MILESTONE-BASED PAYMENTS OR RECURRING BILLING]
Assumptions: [ANYTHING THIS SCOPE DEPENDS ON BEING TRUE]

Write the scope of work with these sections:
1. Document Header — project name, parties, date, version number
2. Project Overview — objective and summary (2-3 sentences)
3. Scope — what is included, written as a numbered deliverables list with descriptions
4. Out of Scope — explicit exclusions, formatted as a list
5. Client Responsibilities — what the client commits to providing or doing
6. Project Timeline — a phases table with name, description, and date
7. Acceptance Criteria — how deliverables will be reviewed and approved
8. Fees and Payment — total, schedule, and invoicing terms
9. Change Order Process — the procedure for any scope additions
10. Assumptions and Dependencies — conditions under which this scope is valid

Use plain language. Use tables where they add clarity. Avoid legal jargon — this should be readable without a lawyer.
```

## Example Output Description

A ten-section document suitable for attaching to a contract. The scope section is a numbered list with 4-8 deliverable entries. The out-of-scope section has 3-5 items. The timeline table has columns for phase, description, and date. The acceptance criteria section defines a specific review window (e.g., "5 business days to provide written feedback"). The assumptions section has 2-4 items that protect both parties if circumstances change.

## Suggested Pairing Hook

`claude-design-output-to-notion` — saves the scope document to a Notion client workspace. Pair with `linear-ticket-from-brief` to automatically create project tickets from the deliverables list.
