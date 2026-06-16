# Cosarc Design System V2

Premium dark-first design language. Editorial serif headlines paired with clean UI sans-serif — distinct from generic Material/Inter apps.

## Color Philosophy

| Token | Value | Usage |
|-------|-------|-------|
| `CosarcColors.primary` | `#D7BB73` | CTAs, active states, streak accent |
| `CosarcColors.background` | `#040405` | Root surface |
| `CosarcColors.surfaceElevated` | `#101012` | Cards, sheets |
| `CosarcColors.textPrimary` | `#F8F5EC` | Headlines, data |
| `CosarcColors.textSecondary` | 70% primary text | Body copy |
| `CosarcColors.accent` | `#42D888` | Success, completion |
| `CosarcColors.meshGradient` | Multi-stop dark | Ambient scaffold background |

## Typography

- **Display/Headlines:** Instrument Serif — editorial, lightweight, generous letter-spacing
- **UI/Body:** Plus Jakarta Sans — modern, readable, Apple-adjacent
- **Overline:** 10px, w700, 2.0 letter-spacing — section labels
- **Metric:** 38px, w800 — live data

Use `CosarcTypography.display()`, `.headline()`, `.title()`, `.body()`, `.caption()`, `.overline()`, `.metric()`, `.brandMark()`.

## Spacing

4pt base scale via `CosarcSpacing`: `xxs(4)` → `huge(48)`. Screen horizontal: **24px**. Card padding: **20px**. Button height: **52px**.

## Radius

| Token | Value |
|-------|-------|
| `radiusSm` | 12 |
| `radiusMd` | 16 |
| `radiusLg` | 20 |
| `radiusXl` | 24 |
| `radiusPill` | 999 |

## Glass System

`CosarcGlass` — frosted surface with `BackdropFilter`, configurable blur/opacity/border/highlight.

`CosarcScaffold` — mesh gradient + ambient gold radial overlay.

## Motion

`CosarcMotion` — spring physics, durations 180–680ms.

`CosarcFadeThroughRoute` — fade + scale page transition.

`CosarcSharedAxisRoute` — vertical shared-axis for auth/onboarding.

## Components

| Component | Purpose |
|-----------|---------|
| `CosarcButton` | Primary / secondary / ghost |
| `CosarcGlass` | Frosted surfaces |
| `CosarcInput` | Glass-wrapped fields |
| `CosarcNavBar` | Arc dock navigation |
| `CosarcLoader` | Branded loading |
| `CosarcEmptyState` | Empty placeholders |
| `DynamicIslandStreak` | Expandable streak widget |

## Navigation

`DashboardRoot` + arc-style `CosarcNavBar` with `extendBody: true`.

## Backend Boundaries

No changes to Supabase, auth logic, Hive, Unity, or nutrition calculations.
