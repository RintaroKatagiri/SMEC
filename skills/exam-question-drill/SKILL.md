---
name: exam-question-drill
description: Create challenging exam-style practice questions from user-specified subject materials. Use when the user asks in Japanese or English for mock questions, drills, quizzes, practice questions, past-exam-like questions, or continued study practice from a specified subject, folder, file, or exam domain such as 中小企業診断士, 第一次試験, 財務・会計, 企業経営理論, or 中小企業経営・中小企業政策. Prefer local study materials over general knowledge, ask one clarification when the target subject is unspecified, and generate original questions rather than copying source questions.
---

# Exam Question Drill

## Core Workflow

1. Identify the exam, subject, folder, files, and topic range.
   - If the user does not specify the subject or source range, ask one concise clarification before creating questions.
   - If the user requests cross-subject practice, use only the subjects they explicitly name.
2. Read the local materials for the specified subject before writing questions.
   - Prefer the user's Markdown notes, PDFs, folders, and repository materials over general knowledge.
   - In this repository, first check `第一次試験/` and its subject folders when the user asks about 中小企業診断士 or first-stage exam practice.
   - Track recently used files, topics, and concepts in conversation. Rotate source files for each new question and avoid repeating the same small topic unless reviewing mistakes.
3. If the user asks for 本試験風, 過去問風, actual-exam level, or similar, use the local materials plus the pattern guidance in `references/past-exam-style.md`.
   - If current official rules, laws, or past-exam facts are needed and are not in the local materials, browse official or credible sources before relying on them.
   - Do not reproduce copyrighted question text. Extract only structure, difficulty, reasoning pattern, distractor style, and topic distribution, then write original questions.
4. Generate one question at a time unless the user requests a batch.
5. After the user answers, grade it, explain the reasoning, record any missed concept in the conversation, then ask the next question.

## Topic Rotation

- Change the source file or clearly distinct subtopic for every new question by default.
- Do not draw more than two consecutive questions from the same Markdown file, chapter, framework, or tightly related concept cluster.
- When a subject folder has many files, sample broadly across strategy, organization, human resources, labor law, marketing, and consumer behavior before returning to a recent area.
- If the user has an open file or named topic, use it for the next question only when they explicitly request that topic; otherwise treat it as context, not a command to stay there.
- Revisit missed concepts later, but change the surface form and separate the review by at least two unrelated questions when possible.
- If the user asks for more variety, immediately switch to a different file and different conceptual area, then continue rotating.

## Subject Control

- Treat the user's subject selection as binding.
- Do not silently switch subjects.
- If the user says `企業経営理論`, use only that folder or files unless they request mixed practice.
- If the user later switches subjects, reset recent-topic rotation for the new subject.
- If a requested topic cannot be found locally, say so and ask whether to use web research or another source.

## Question Quality

- Avoid low-level definition recall as the default.
- Prefer application, comparison, exception handling, cause-effect, and `最も適切` / `最も不適切` questions.
- Include a short case when it meaningfully raises difficulty.
- Make all answer choices plausible.
- Build distractors from common misunderstandings, nearby concepts, reversed causal relationships, missing conditions, overgeneralizations, and partial truths.
- Avoid choices that are obviously from unrelated topics.
- Require at least one reasoning step beyond matching a term to its definition.
- Mix formats:
  - 最も適切
  - 最も不適切
  - 正誤組み合わせ
  - 事例から概念を特定
  - 複数記述の比較
  - 計算または表の解釈

## Difficulty Target

Default to Japanese professional certification exam level:

- Basic recall: 10% or less, mostly for warm-up or review.
- Standard: 50%, requiring discrimination between similar concepts.
- Hard: 40%, combining concepts, exceptions, or case application.

For 中小企業診断士 第一次試験 practice:

- Use 4 or 5 choices as appropriate for the source style.
- Use exam-like phrasing such as `最も適切なものはどれか` and `最も不適切なものはどれか`.
- Include multi-statement questions when useful.
- Keep every question original even when inspired by a past-exam pattern.

## Interaction Style

- Ask only one question at a time by default.
- Do not reveal the answer before the user responds.
- Accept numeric answers, letters, and short Japanese answers when unambiguous.
- If the user's answer is ambiguous, ask for clarification instead of grading.
- For each graded question, include:
  - the tested concept and why it matters
  - the decisive clue in the question stem
  - why the correct choice is correct
  - why every incorrect choice is wrong, especially when partially true
  - the common trap behind at least the most plausible distractor
  - a short memory hook, comparison table, or rule of thumb when useful
- Keep explanations focused on the current question; avoid broad textbook summaries unless asked.
- Maintain a mistake log in conversation:
  - subject
  - source file or topic
  - concept
  - error type
- Revisit missed concepts later with a changed surface form.

## Output Template

Use this shape for a single question:

```markdown
**第N問：<subject or topic>**

<question text>

1. <choice>
2. <choice>
3. <choice>
4. <choice>

答えを番号でください。
```

For grading:

```markdown
正解です。 / 不正解です。正解は `<number>` です。

論点:
<tested concept>

判断の決め手:
<stem clue and reasoning>

選択肢の検討:
- `1`: <why correct or wrong>
- `2`: <why correct or wrong>
- `3`: <why correct or wrong>
- `4`: <why correct or wrong>

ひっかけポイント:
<common trap>

**第N+1問：...**
...
```
