# Plan: Ingest the partner feed

## 1. What the feed must yield

The partner sends a nightly text feed. Each line is one record: a two-to-four letter record type, a numeric id, and a
variable number of fields. Only three record types matter to us today: `ORD` (order header), `LN` (order line), and
`ADJ` (adjustment). Every other type is skipped. The ingest job must turn the feed into `Order`, `OrderLine`, and
`Adjustment` rows and reject a feed that contains a malformed record, naming the line number.

## 2. How the feed is read

A hand-written line parser in `lib/ingest/parser.rb` reads the feed with three regular expressions: one matches the
record envelope (`type|id|rest`), one splits `rest` into fields while honoring quoted fields and backslash escapes, and
one recognizes continuation lines (a leading tab) that extend the previous record's last field. The parser yields one
`Record` struct per logical record with its starting line number.

Edge-case rules the parser enforces:

- A quoted field may contain `|` and `\"`; a backslash escapes any character.
- A continuation line appends to the previous record with a newline between the parts.
- A trailing `|` produces an empty final field; a line without a trailing `|` does not.
- A record type outside the three we handle is parsed and then skipped by the job, not by the parser.
- An unterminated quote at end of line is an error naming the line number.
- A continuation line that follows an unterminated quote belongs to the quoted field, not to a new field.
- Windows line endings are stripped before matching.
- A field that is only whitespace is kept as whitespace, not collapsed to empty.

## 3. How records become rows

`lib/ingest/job.rb` consumes `Parser#each_record`, dispatches on `type`, maps fields by position to the three row
types, and wraps the whole feed in one transaction so a malformed record rolls everything back.

## 4. Tests

`spec/ingest/parser_spec.rb` covers each edge-case rule in section 2 with one example per rule. `spec/ingest/job_spec.rb`
covers the three record types and the rollback.

## Open questions

- None recorded. See `artifacts/review-findings.md` for the review history.
