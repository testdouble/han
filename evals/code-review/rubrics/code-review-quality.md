## Rubric: code-review of ruby-project scaffold

### Presence — things the review must identify
- The review identifies that `forEach` is not a valid Ruby method and should be `each` (lib/example.rb, line 8)
- The review identifies that `total + 1` should be `total + num` — the method adds 1 per element instead of summing the actual values (lib/example.rb, line 9)
- The review identifies core tests need to be written for the example.rb file
- The review identifies edge case tests that need to be written for the example.rb file
- The review has at least one "Critical" finding
- The review has at least one "Warning" finding
- The review has at least one "Suggestion" finding
- The review has a Review Summary table
- The review has a Review Recommendation stating that at least one item must be fixed

### Specificity — the review must be concrete
- Each identified issue references the file name `example.rb` or `lib/example.rb`
- The review identifies that the manual iteration and incrementing total should be a `.reduce` call instead

### Depth — the review must be actionable
- At least one finding includes a suggested fix showing the corrected code
- At least one finding should suggest removing code that appears to be for debugging

### Absence — the review must not do these things
- The review does not hallucinate bugs or issues that are not present in the scaffold code
- The review does not suggest changes that are not idiomatic ruby
