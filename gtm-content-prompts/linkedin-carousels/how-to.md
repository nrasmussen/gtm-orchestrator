# How-To and Tutorial Carousel

## Purpose

Generate a step-by-step LinkedIn carousel that teaches the audience a specific skill or process. How-to carousels drive saves and shares because they are immediately useful. Use this when you want to demonstrate expertise by teaching something concrete, not by making abstract arguments.

## Prompt

```
You are a LinkedIn content strategist and instructional writer. Write an 8-12 slide how-to carousel based on the following brief.

Author name and expertise area: [NAME] — [RELEVANT EXPERTISE]
Topic: [WHAT SKILL OR PROCESS YOU ARE TEACHING]
Who this is for: [AUDIENCE — JOB TITLE, EXPERIENCE LEVEL, CONTEXT]
The outcome the reader will achieve: [WHAT THEY WILL BE ABLE TO DO AFTER READING]
The steps involved (list them roughly): [STEP 1], [STEP 2], [STEP 3], etc.
Common mistake at each step (if applicable): [MISTAKE 1], [MISTAKE 2], etc.
Time or effort required to apply this: [HOW LONG IT TAKES IN PRACTICE]
One tool or resource that helps (optional): [NAME — OR OMIT IF TOOL-AGNOSTIC]

Write the carousel with this structure:
Slide 1: Hook — state the outcome the reader will have after the last slide. Make it specific and measurable where possible.
Slide 2: Why this matters — 2-3 lines on why most people fail at this or avoid it, and what it costs them.
Slides 3 to N-1: One step per slide. For each:
  - Step number and name
  - 2-4 lines explaining what to do
  - A one-line "watch out" warning or common mistake
  - Visual direction: what the slide should show (icon, example, diagram, or text-only)
Last slide: Summary + CTA — recap the steps in a numbered list, then invite a specific action (save, comment, DM, follow).

Rules:
- Every step must be actionable — avoid "think about" or "consider" as verbs; use "list," "write," "review," "send," etc.
- Use plain language. The reader is a professional, not a student.
- The hook slide must work without reading the rest of the carousel.
- No slide should require more than 6 seconds to read.
```

## Example Output Description

An 8-10 slide carousel. Slide 1 promises a concrete outcome in one line. Slides 2 through the second-to-last each focus on a single step with a bolded step name, 3 action-oriented lines, and a one-line warning. The final slide lists all steps in a numbered list and ends with a save prompt and a question for the comments.

## Suggested Pairing Hook

`typefully-draft-queue` — queues the carousel text as a draft for scheduling. Pair with `notion-content-archive` if you want to maintain a library of all how-to content you have created.
