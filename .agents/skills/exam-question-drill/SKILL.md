---
name: exam-question-drill
description: Create challenging exam-style practice questions from user-specified subject materials. Use when the user asks for mock questions, drills, quizzes, past-exam-like questions, or continued practice from a specified subject, folder, file, or exam domain such as 中小企業診断士. The skill must confirm the target subject when unspecified, research official or credible past questions when the user asks for past-exam style, and generate original questions rather than copying source questions.
---

# Exam Question Drill

## Core workflow

1. Identify the target subject, folder, files, and exam.
   - If the user does not specify the subject or source range, ask one concise clarification before creating questions.
   - If the user requests cross-subject questions, use only the subjects they explicitly name.
2. Read the local materials for the specified subject.
   - Prefer the user's Markdown, PDFs, notes, or folders over general knowledge.
   - Track recently used files and concepts in conversation, and avoid repeating them unless reviewing mistakes.
3. If the user asks for past-exam style or actual-exam level, inspect official or credible past questions for the named exam.
   - Prefer official exam body pages and official PDFs.
   - Use third-party sites only to understand indexing, explanations, or availability when official pages are insufficient.
   - Do not reproduce copyrighted question text. Extract structure, difficulty, reasoning pattern, distractor style, and topic distribution, then write original questions.
4. Generate one question at a time unless the user requests a batch.
5. After the user answers, grade it, give a detailed explanation, then ask the next question.

## Subject control

- Treat the user's subject selection as binding.
- Do not silently switch subjects.
- If the user says "企業経営理論", use only that folder or files unless they request 横断.
- If the user later says "財務・会計にして", switch to that subject and reset recent-topic rotation for the new subject.
- If a requested topic cannot be found locally, say so and ask whether to use web research or another source.

## Question quality rules

- Avoid low-level definition recall as the default.
- Prefer application, comparison, exception handling, cause-effect, and "most appropriate / most inappropriate" questions.
- Include a short case when it meaningfully raises difficulty.
- Make all answer choices plausible.
- Build distractors from common misunderstandings, nearby concepts, reversed causal relationships, missing conditions, overgeneralizations, or partial truths.
- Avoid choices that are obviously from unrelated topics.
- Require at least one reasoning step beyond matching a term to its definition.
- Mix formats:
  - most appropriate
  - most inappropriate
  - correct/incorrect combination
  - case-based concept identification
  - statement comparison
  - calculation or table interpretation when the subject supports it

## Difficulty target

Default to Japanese professional certification exam level:

- Basic recall: 10% or less, mostly for warm-up or review.
- Standard: 50%, requires discriminating similar concepts.
- Hard: 40%, combines concepts, exceptions, or case application.

For 中小企業診断士 first-stage practice:

- Use 4 or 5 choices as appropriate for the source style.
- Use phrasing similar to the exam, such as "最も適切なものはどれか" and "最も不適切なものはどれか".
- Include multi-statement questions when useful.
- Keep the question original even when inspired by a past question.

## Past-exam research notes

When researching 中小企業診断士:

- Start with 日本中小企業診断士協会連合会 / 中小企業診断協会 official exam problem pages.
- Check recent first-stage PDFs and answer-all-treatment notes because invalidated questions reveal ambiguity risks.
- Observe:
  - number of choices
  - whether the question is direct, case-based, or multi-statement
  - how distractors are made
  - how legal or policy questions handle dates and statutory detail
  - whether a concept is tested by definition, application, contrast, or exception
- Convert observations into original questions grounded in the user's local materials.

See `references/past-exam-style.md` for reusable design patterns.

## Interaction style

- Ask only one question at a time by default.
- Do not reveal the answer before the user responds.
- Accept lowercase answers.
- If the user answers ambiguously, ask for clarification instead of grading.
- Make explanations detailed enough for review, not just answer confirmation.
- For each graded question, include:
  - the tested concept and why it matters
  - the decisive clue in the question stem
  - why the correct choice is correct
  - why every incorrect choice is wrong, especially when it is partially true
  - the common trap or misunderstanding behind at least the most plausible distractor
  - a short memory hook, comparison table, or rule of thumb when it helps retention
- Keep the explanation focused on the current question; do not add broad textbook summaries unless the user asks.
- Maintain a mistake log in conversation:
  - subject
  - source file or topic
  - concept
  - error type
- Revisit missed concepts later with a changed surface form.

## Output template

Use this shape for a single question:

```markdown
**第N問：<subject or topic>**

<question text>

A. <choice>
B. <choice>
C. <choice>
D. <choice>

回答は `A`〜`D` でどうぞ。
```

For grading:

```markdown
正解です / 不正解です。正解は `<letter>` です。

論点:
<tested concept>

判断の決め手:
<stem clue and reasoning>

選択肢の検討:
- `<correct letter>`: <why correct>
- `<wrong letter>`: <why wrong>
- `<wrong letter>`: <why wrong>
- `<wrong letter>`: <why wrong>

ひっかけポイント:
<common trap>

**第N+1問：...**
...
```
