# {Feature Name}

<!-- One-sentence description: what this feature/system does and why it exists. -->

- **Last Updated:** {YYYY-MM-DD HH:mm}
- **Authors:**
  - {name} ({email})

## Overview

<!-- 2-4 bullet points covering the most important facts a reader needs to orient themselves. -->

- ...
- ...

Key files:
<!-- List the 3-5 most important files. This is the quick-reference; the full table goes in Key Files below. -->
- `path/to/primary-file` - Brief purpose
- `path/to/secondary-file` - Brief purpose

## Architecture

<!-- ASCII flow diagram showing the feature's high-level structure. -->
<!-- Use box-drawing characters (┌─┐│└─┘) for boxes, arrows (→ ──▶ │ ▼) for flow -->

```
Diagram here
```

## Key Files

<!-- Organize by layer. Include all files relevant to understanding or modifying this feature. -->

### Backend
<!-- CONDITIONAL: Include only if the feature has backend files -->
| File | Purpose |
|------|---------|
| `path/to/file` | ... |

### Frontend
<!-- CONDITIONAL: Include only if the feature has UI components -->
| File | Purpose |
|------|---------|
| `path/to/file` | ... |

### Infrastructure
<!-- CONDITIONAL: Include only if there are deployment, CI/CD, or config files -->
| File | Purpose |
|------|---------|
| `path/to/file` | ... |

## Database Schema

<!-- CONDITIONAL: Include when the feature has its own tables or adds columns to existing tables. -->

```sql
CREATE TABLE TableName (
    id int(11) NOT NULL AUTO_INCREMENT,
    -- ... columns with comments explaining non-obvious ones
    PRIMARY KEY (id)
);
```

## Core Types

<!-- CONDITIONAL: Include when key interfaces, structs, or types define the feature's contract. -->
<!-- For cross-cutting features, include both Backend and Frontend sub-headings. For single-layer features, use only the relevant sub-heading. -->

### Backend

```{language}
// Type definitions from source with brief annotations
```

### Frontend

```{language}
// Type definitions from source with brief annotations
```

## Constants

<!-- CONDITIONAL: Include when magic numbers, enum values, or named constants are important. -->
<!-- For cross-cutting features, split into Backend and Frontend sub-sections. For single-layer features, skip the sub-headings. -->

### Backend
| Constant | Value | Description |
|----------|-------|-------------|
| `ConstantName` | `42` | What it means |

### Frontend
| Constant | Value | Description |
|----------|-------|-------------|
| `CONSTANT_NAME` | `"value"` | What it means |

## Implementation Details

<!-- The main body of the document. Sub-head by operation, feature area, or logical grouping. -->
<!-- For cross-cutting features, split into Backend and Frontend sub-sections. For single-layer features, skip the sub-headings and organize directly by operation. -->

### Backend
#### {Operation or Feature Area}

```{language}
// Annotated code example from actual source
```

### Frontend
#### {Operation or Feature Area}

```{language}
// Annotated code example from actual source
```

## API Endpoints

<!-- CONDITIONAL: Include when the feature exposes API endpoints. -->

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| `GET` | `/v1/resource` | `ListResource` | List with pagination |
| `POST` | `/v1/resource` | `CreateResource` | Create new |

### {Endpoint Name}

```
POST /v1/resource
Content-Type: application/json
```

**Request:**
```json
{
  "field": "value"
}
```

**Response:**
```json
{
  "data": { ... }
}
```

## Events

<!-- CONDITIONAL: Include when the feature emits or subscribes to events. -->

### Emitted Events
| Event | Payload Type | When Emitted |
|-------|-------------|--------------|
| `domain.action` | `DomainActionPayload` | When ... |

### Subscribed Events
| Event | Handler | Behavior |
|-------|---------|----------|
| `other.event` | `handleOtherEvent` | Does ... |

## Configuration

<!-- CONDITIONAL: Include when environment variables or config files are involved. -->
<!-- For cross-cutting features, split into Backend and Frontend sub-sections. For single-layer features, skip the sub-headings. -->

### Backend
| Variable | Description | Default |
|----------|-------------|---------|
| `ENV_VAR_NAME` | What it controls | `default_value` |

### Frontend
| Variable | Description | Default |
|----------|-------------|---------|
| `ENV_VAR_NAME` | What it controls | `default_value` |

## Error Handling

<!-- CONDITIONAL: Include when there are specific error scenarios worth documenting. -->
<!-- For cross-cutting features, split into Backend and Frontend sub-sections. For single-layer features, skip the sub-headings. -->

### Backend
| Scenario | Error / HTTP Status | Behavior |
|----------|---------------------|----------|
| Description | `400 Bad Request` | What happens |

### Frontend
| Scenario | Error Handling | Behavior |
|----------|----------------|----------|
| Description | Error boundary / toast / fallback | What happens |

## Frontend Components

<!-- CONDITIONAL: Include when the feature has significant UI components. -->
<!-- Include only the sub-sections below that apply. Each sub-section is CONDITIONAL. -->

### Component Hierarchy

<!-- CONDITIONAL: Include when there's a meaningful page/component tree to illustrate. -->

```
PageComponent
└── ContainerComponent
    ├── HeaderComponent
    └── TableComponent
        └── CellComponents
```

### Routing

<!-- CONDITIONAL: Include when the feature defines its own routes or has multiple URL patterns. -->

| Route | Page Component | Description |
|-------|----------------|-------------|
| `/feature` | `FeaturePage` | Main listing |
| `/feature/:id` | `FeatureDetailsPage` | Detail view |

### Custom Hooks

<!-- CONDITIONAL: Include when the feature has custom hooks beyond generated API hooks. -->

| Hook | Purpose | Key Params |
|------|---------|------------|
| `useFeatureState()` | Manages local feature state | `featureId` |

### Context / Providers

<!-- CONDITIONAL: Include when the feature defines or consumes contexts or providers. -->

| Context | Provider | Purpose |
|---------|----------|---------|
| `FeatureContext` | `FeatureProvider` | Shares feature state across component tree |

### State Management

<!-- CONDITIONAL: Include when the feature has notable state management patterns (query caching, stores, reducers). -->

```{language}
// State management patterns from actual source
```

### Offline Support

<!-- CONDITIONAL: Include when the feature uses local storage, background sync, or offline-first patterns. -->

| Component | Purpose |
|-----------|---------|
| `path/to/offline-service` | Local storage CRUD operations for offline cache |
| `path/to/sync-component` | Background sync when connectivity restored |

### Event Patterns

<!-- CONDITIONAL: Include when the feature uses custom DOM events, editor events, or window events. -->

| Event | Dispatched By | Handled By | Purpose |
|-------|---------------|------------|---------|
| `feature:updated` | `FeatureEditor` | `FeatureList` | Refresh list after inline edit |

## Adding a New {Item}

<!-- CONDITIONAL: Include when the feature has a repeatable extension pattern (new event type, new endpoint, new column, etc.). -->

1. **Step one** — What to do and where
2. **Step two** — What to do and where
3. **Step three** — What to do and where

## Testing

<!-- CONDITIONAL: Include when there are notable test patterns, test file locations, or isolation requirements. -->
<!-- For cross-cutting features, split into Backend and Frontend sub-sections. For single-layer features, skip the sub-headings. -->

### Backend
- `path/to/test_file` - What it tests

### Frontend
- `path/to/test_file` - What it tests

### Test Patterns
<!-- Describe any special setup, fixtures, or isolation needed, including patterns shared across layers. -->

## Troubleshooting

<!-- CONDITIONAL: Include when there are known issues, common mistakes, or debugging tips. -->

### {Problem Description}

1. Check ...
2. Verify ...
3. Try ...

## Related Documentation

<!-- Always include. Link to related docs and ADRs using relative links. -->

- [Related Doc](./related-doc.md) - How it relates
- [ADR-NNNN](./adr/NNNN-title.md) - Relevant architectural decision
