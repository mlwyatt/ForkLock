# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What Is This

ForkLock  is a group restaurant decision app. Users create a session, share a 4-letter code, everyone swipes on restaurants (Tinder-style), and ranked results show group consensus.

**Stack:** Rails 7.1, SQLite, Hotwire (Turbo + Stimulus), Bulma CSS, TypeScript, esbuild, Docker


## Configuration

**master.key** (CRITICAL): Required for credentials decryption. Place in `config/master.key` with no trailing newline. Never commit.

**Environment**: `.env` file for local port configuration. Docker handles all services (web, css, js, redis).

## Architecture

### Core Flow
Create session → Share 4-letter code → Participants join → Everyone swipes → Ranked results

### Authentication
Cookie-based via signed participant tokens (no user accounts). `ApplicationController` provides `current_participant` and `current_session` helpers. Auth guard: `require_participant!`, `require_session_participant!(session)`.

### Data Model
```
Session (code, status enum, expires_at 24h)
  └─< Participant (name, token, completed_at)
       └─< Vote (liked boolean)
            └── Restaurant (name, cuisine, rating, price_level, distance, image_url)
```
- Session generates unique 4-char code (excludes I/O/L)
- Participant marked complete when all restaurants voted on
- Vote uniqueness enforced on (participant_id, restaurant_id)

### Controllers
- `HomeController` — Landing page
- `SessionsController` — CRUD + `swipe` and `results` member actions (keyed by `param: :code`)
- `ParticipantsController` — Join session flow with duplicate name handling
- `VotesController` — Creates votes via Turbo Stream, auto-marks participant complete

### Frontend
- **Stimulus controllers** in `app/javascript/controllers/` (TypeScript)
  - `swipe_controller.ts` — Drag/touch gestures, card animation, vote submission via fetch + Turbo Stream
  - `clipboard_controller.ts` — Copy session code to clipboard
  - `flash_controller.ts` — Dismiss flash messages
- **TypeScript mixin** at `app/javascript/scripts/mixins/typescript_stimulus.ts` — Provides `typedController()` for strongly-typed Stimulus targets/values
- **Entry point**: `app/javascript/application.ts` → imports Turbo + controllers

### Bulma Service Objects
`app/services/bulma/` contains a component library (Button, Card, Modal, Select, etc.) with concerns (HasContent, HasField, HasIcon, etc.). Views use helper methods like `bulma_button`, `bulma_link`, `bulma_text_field` instead of raw HTML form helpers — see `.claude/rules/rails.md` for the full list.

### Styles
- `app/assets/stylesheets/application.scss` — Imports Bulma + partials
- `app/assets/stylesheets/forklock.scss` — App-specific styles (swipe animations, card layouts, result rankings)
- Build: `sass` compiles `application.bulma.scss` → `app/assets/builds/application.css`

### Real-time
ActionCable infrastructure exists (Redis in production, async in dev). Turbo Streams used for vote submission responses. Full real-time lobby updates not yet wired.

## Current State

Phase 1 MVP is largely implemented (models, session flow, swipe UI, results). Phase 2 (Google Places integration, location-based restaurants) is planned but not started. Currently uses seeded restaurant data. Test specs exist but are mostly pending.

## Plans

- At end of each plan, list unresolved questions (extremely concise, sacrifice grammar)
- When working on multi-phase plan, commit between phases with "Phase X completed" in message

## Additional Rules

See `.claude/rules/*.md` for domain-specific guidance (git, docker, ruby, rails, rspec, css, javascript/typescript)
