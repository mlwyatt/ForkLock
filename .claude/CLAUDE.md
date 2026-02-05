# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
See `.claude/CLAUDE.shared.md` for organization standards.

## Project Overview

**ForkLock** is a commercial trucking insurance management system built with Ruby on Rails. It manages insurance policies, quotes, claims, billing, and agency operations for trucking companies.

- **Ruby**: 3.4.4
- **Rails**: ~> 7.1.0
- **Database**: MySQL 8.0.36
- **Frontend**: Hotwire (Turbo + Stimulus), Bulma CSS, TypeScript
- **Background Jobs**: Delayed Job
- **Testing**: RSpec with FactoryBot

## Configuration

### Required Setup

**master.key** (CRITICAL):
- Required for credentials decryption
- Obtain from AWS SSM Parameter Store (search for project's `MASTER_KEY` parameter)
- Place in `config/master.key` with no trailing newline
- Never commit to version control

**Environment Variables**:
- `.env` file for local port configuration

## Plans

- At end of each plan, list unresolved questions (extremely concise, sacrifice grammar)
- When working on multi-phase plan, commit between phases with "Phase X completed" in message

## Additional Rules

See `.claude/rules/*.md` for domain-specific guidance (git, docker, ruby, etc.)
Don't assume what an abbreviation means. If you don't know, ask
