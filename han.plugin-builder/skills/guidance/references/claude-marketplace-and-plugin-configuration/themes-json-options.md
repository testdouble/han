# Theme File Schema Reference

Plugin theme files are JSON files placed in the `themes/` directory (or a custom path set via the `themes` field in `plugin.json`). The filename without `.json` becomes the theme's slug.

> **Experimental.** Themes are an experimental plugin component. In `plugin.json` the preferred placement is under the `experimental` key (`"experimental": { "themes": "./themes/" }`). The bare top-level `themes` key still works but `claude plugin validate` warns against it, and `--strict` treats that warning as an error. The manifest schema may change.

## Fields

All three fields are optional.

| Field       | Required | Type   | Default       | Description                                 |
| ----------- | -------- | ------ | ------------- | ------------------------------------------- |
| `name`      | No       | string | Filename slug | Display label shown in the `/theme` command |
| `base`      | No       | string | `"dark"`      | Built-in preset to inherit from             |
| `overrides` | No       | object | `{}`          | Color token → value mappings                |

## `base` Valid Values

| Value                | Description                                  |
| -------------------- | -------------------------------------------- |
| `"dark"`             | Default dark theme                           |
| `"light"`            | Default light theme                          |
| `"dark-daltonized"`  | Dark theme with colorblind-friendly palette  |
| `"light-daltonized"` | Light theme with colorblind-friendly palette |
| `"dark-ansi"`        | Dark theme using terminal ANSI colors        |
| `"light-ansi"`       | Light theme using terminal ANSI colors       |

## Color Value Formats

Any `overrides` token accepts these formats:

| Format       | Example                      |
| ------------ | ---------------------------- |
| Hex 6-digit  | `"#bd93f9"`                  |
| Hex 3-digit  | `"#f0f"`                     |
| RGB function | `"rgb(189, 147, 249)"`       |
| ANSI 256     | `"ansi256(141)"` (n = 0–255) |
| ANSI 16 name | `"ansi:magentaBright"`       |

ANSI 16 names: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, and their `Bright` variants (`blackBright`, `redBright`, etc.).

## Color Tokens

### Text and Accent

| Token         | Controls                                           |
| ------------- | -------------------------------------------------- |
| `claude`      | Primary brand accent, spinner, and assistant label |
| `text`        | Default foreground text                            |
| `inverseText` | Text on colored backgrounds (e.g. status badges)   |
| `inactive`    | Secondary text — hints, timestamps, disabled items |
| `subtle`      | Faint borders and de-emphasized text               |
| `permission`  | Dialog borders and permission prompts              |
| `remember`    | Memory and `CLAUDE.md` indicators                  |

### Status

| Token     | Controls                            |
| --------- | ----------------------------------- |
| `success` | Success messages and passing checks |
| `error`   | Error messages and failures         |
| `warning` | Warnings and caution messages       |
| `merged`  | Merged pull request status          |

### Input Box and Mode Indicators

| Token          | Controls                                |
| -------------- | --------------------------------------- |
| `promptBorder` | Input box border in default mode        |
| `planMode`     | Plan mode accent and border             |
| `autoAccept`   | Accept-edits mode accent and border     |
| `bashBorder`   | Input box border for `!` shell commands |
| `ide`          | IDE connection indicator                |
| `fastMode`     | Fast mode indicator                     |

### Diff Rendering

| Token               | Controls                              |
| ------------------- | ------------------------------------- |
| `diffAdded`         | Background of added lines             |
| `diffRemoved`       | Background of removed lines           |
| `diffAddedDimmed`   | Context background near added lines   |
| `diffRemovedDimmed` | Context background near removed lines |
| `diffAddedWord`     | Word-level highlight in added lines   |
| `diffRemovedWord`   | Word-level highlight in removed lines |

### Fullscreen Mode

| Token                   | Controls                          |
| ----------------------- | --------------------------------- |
| `userMessageBackground` | Background behind user messages   |
| `selectionBg`           | Background of mouse-selected text |

### Shimmer Variants

Animated gradient counterparts for select tokens:

`claudeShimmer`, `successShimmer`, `errorShimmer`, `warningShimmer`, `mergedShimmer`, `planModeShimmer`, `autoAcceptShimmer`, `bashBorderShimmer`, `ideShimmer`, `fastModeShimmer`

### Subagent Colors

Eight colors for distinguishing subagents visually. Suffix `_FOR_SUBAGENTS_ONLY` is required:

`red_FOR_SUBAGENTS_ONLY`, `blue_FOR_SUBAGENTS_ONLY`, `green_FOR_SUBAGENTS_ONLY`, `yellow_FOR_SUBAGENTS_ONLY`, `purple_FOR_SUBAGENTS_ONLY`, `orange_FOR_SUBAGENTS_ONLY`, `pink_FOR_SUBAGENTS_ONLY`, `cyan_FOR_SUBAGENTS_ONLY`

## Behavior

- Unknown tokens and invalid color values are silently ignored
- Tokens absent from `overrides` inherit from the `base` preset
- Claude Code auto-reloads themes from `~/.claude/themes/` when files change
- Selecting a plugin theme stores `custom:<plugin-name>:<slug>` in user config
- Pressing Ctrl+E on a plugin theme copies it to `~/.claude/themes/` for local editing

## Official Reference

https://code.claude.com/docs/en/terminal-config.md
https://code.claude.com/docs/en/plugins-reference.md

## JSON example

available at ../templates/themes-example.json
