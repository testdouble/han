## File Path Truncation

When displaying file paths (in a bulleted list or a table), truncate paths longer than 50 characters: keep the first path segment, add `/...`, then fill remaining characters from the end to produce a 45-50 character result. Never include the character count in the output.

Example: `ui/src/pages/GearDetails/components/GearInfo/GearInfoContentFields/GearInfoContentFieldsReorderable.tsx` → `ui/...fo/GearInfoContentFieldsReorderable.tsx`

Paths 50 characters or shorter should be displayed in full.
