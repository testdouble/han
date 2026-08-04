# Scope Boundary: user-level Han config

## Work Item

No tracker item names this work. The operator's typed request when invoking `plan-a-feature` is the only boundary this
run has, and it is quoted verbatim below.

Issue #112 ("Feature: a framework for user overrides to han integration points and skills") is the ancestor of the
already-shipped project-local `.han/config.md`. It does not name a user-level config file, so it is noted here for
context only and is not read as scope evidence for this run.

## Stated Scope

> xtra small, to adjust the han config file loading so that it reads `$CLAUDE_CONFIG_DIR/.han/config.md` first, and then
> reads overrides from the project level `.han/config.md` file after that

## Stated Exclusions

None stated.

## Operator-Stated Scope

The size band `xtra small` was passed as the size argument. No other scope was stated out loud beyond the request quoted
above.

## Direction of Travel

Nothing is being deprecated, replaced, or migrated away from. The operator answered: "both stay as implied in my
request." The project-local `.han/config.md` keeps its role and keeps the right to change settings for that project; the
user-level file adds a layer beneath it.

## Visual Material Received

None received.

## Record Provenance

Established by `han-planning:plan-a-feature` in this folder. Not inherited.
