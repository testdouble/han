# Review findings: Ingest the partner feed

Three review rounds (R1, R2, R3) of `plans/ingest-parser/plan.md`. The round cap for this plan is 3. Round 3 produced
four new findings, three of them major, so the stop rule's convergence condition was not met at the cap.

## Major findings

### F1: Record envelope regex rejects ids with leading zeros

- **Agent:** edge-case-explorer
- **Category:** edge case
- **Finding:** `RECORD` in `lib/ingest/parser.rb:6` matches `\d+` and the job calls `Integer(m[:id])`, which raises on
  `007`. The partner's sample feed contains zero-padded ids.
- **Evidence considered:** `lib/ingest/parser.rb:6`, `lib/ingest/parser.rb:47`
- **Alternatives:** —
- **Resolution:** Section 2 gained the rule "ids are parsed as decimal with leading zeros allowed".
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Section 2

### F2: Escaped backslash before a closing quote ends the field early

- **Agent:** edge-case-explorer
- **Category:** edge case
- **Finding:** `FIELD` at `lib/ingest/parser.rb:7` treats `\\"` as an escaped quote, so a field ending in a literal
  backslash (`"C:\path\"`) swallows the closing quote and the next field.
- **Evidence considered:** `lib/ingest/parser.rb:7`
- **Alternatives:** —
- **Resolution:** Section 2 escape rule reworded; `FIELD` regex to gain an alternation for `\\\\` before `"`.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Section 2

### F3: Continuation line before any record raises the wrong error class

- **Agent:** junior-developer
- **Category:** unhandled failure mode
- **Finding:** The job's rollback contract names `Ingest::ParseError`, but a continuation line as the first line raises
  from inside `each_record` before the transaction opens.
- **Evidence considered:** `lib/ingest/parser.rb:23`, plan section 3
- **Alternatives:** —
- **Resolution:** Section 3 now opens the transaction before the first `each_record` call.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Section 3

### F4: Quoted field spanning a continuation line is split into two fields

- **Agent:** edge-case-explorer
- **Category:** edge case
- **Finding:** `FIELD` is applied per logical line after continuation joining, but the newline inserted at
  `lib/ingest/parser.rb:26` is not inside the quote-aware branch, so a quote opened before the continuation and closed
  after it yields two fields and an unterminated-quote error on the first.
- **Evidence considered:** `lib/ingest/parser.rb:26`, `lib/ingest/parser.rb:7`
- **Alternatives:** —
- **Resolution:** Section 2 gained the rule "a continuation line that follows an unterminated quote belongs to the quoted
  field". Implementation note: join before scanning and let `[^"\\]` match the newline.
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Section 2

### F5: Empty quoted field is indistinguishable from a missing field

- **Agent:** behavioral-analyst
- **Category:** edge case
- **Finding:** `FIELD` captures `""` as an empty quoted group and `` as an empty bare group; both land as `""` in
  `fields`, so the job cannot tell "explicitly empty" from "absent", which section 3 says it must for `ADJ` reason
  codes.
- **Evidence considered:** `lib/ingest/parser.rb:40-44`, plan section 3
- **Alternatives:** —
- **Resolution:** Section 2 gained a rule distinguishing `""` from an absent field; the struct gains a `quoted` flag
  per field.
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Section 2, Section 3

### F6: Trailing-pipe rule contradicts the sample feed

- **Agent:** evidence-based-investigator
- **Category:** assumption refuted
- **Finding:** The partner's sample feed ends every record with `|`, so the rule "a trailing `|` produces an empty final
  field" would give every record one phantom field.
- **Evidence considered:** partner sample in the ticket; `lib/ingest/parser.rb:45`
- **Alternatives:** —
- **Resolution:** Section 2 trailing-pipe rule inverted; `fields.pop` condition inverted to match.
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Section 2

### F7: Windows line endings inside a quoted field are stripped

- **Agent:** edge-case-explorer
- **Category:** edge case
- **Finding:** `raw.chomp` at `lib/ingest/parser.rb:21` strips `\r\n` at the end of every physical line, including the
  line that ends a quoted field whose value legitimately ends in `\r`.
- **Evidence considered:** `lib/ingest/parser.rb:21`
- **Alternatives:** —
- **Resolution:** Section 2 line-ending rule narrowed to "outside quotes"; implementation to chomp only when the quote
  depth is zero.
- **Resolved by:** evidence
- **Raised in round:** R3
- **Changed in plan:** Section 2

### F8: Backslash escape rule is ambiguous for `\n`

- **Agent:** junior-developer
- **Category:** ambiguity
- **Finding:** Section 2 says "a backslash escapes any character", so `\n` inside a quoted field is the letter `n`, but
  the partner's documentation says `\n` is a newline. `gsub(/\\(.)/, '\1')` at `lib/ingest/parser.rb:43` implements the
  plan, not the partner.
- **Evidence considered:** `lib/ingest/parser.rb:43`, partner documentation section 4.2
- **Alternatives:** —
- **Resolution:** Open. Needs the partner's escape table, which the plan does not carry.
- **Resolved by:** deferred to open item
- **Raised in round:** R3
- **Changed in plan:** —

### F9: Whitespace-only field rule has no test and the regex collapses it

- **Agent:** edge-case-explorer
- **Category:** edge case
- **Finding:** Section 2 says a whitespace-only field is kept, but the bare-field branch of `FIELD` is applied after
  `chomp` and a trailing whitespace-only field at end of line is dropped by the `fields.pop` guard at
  `lib/ingest/parser.rb:45`.
- **Evidence considered:** `lib/ingest/parser.rb:45`, plan section 4
- **Alternatives:** —
- **Resolution:** Open. The guard needs to know whether the last field was bare or quoted, which the scan loses.
- **Resolved by:** deferred to open item
- **Raised in round:** R3
- **Changed in plan:** —

## Minor edits

- F10: Section 1 record-type list reformatted as a table — junior-developer — Section 1
- F11: "nightly" clarified to "once per calendar day, 02:00 UTC" — evidence-based-investigator — Section 1
