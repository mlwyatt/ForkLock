# Git & GitHub

## Important rules

- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.
- All commit messages should start with `fix:`, `task:`, `feat:`, or `docs:`
- Never force push to git
- Never push directly to: `main`, `production`, `staging`
- Never rebase
- All of our repos are private by default. A regular web fetch for GitHub will fail, use the CLI instead

## Worktrees

- When working with git worktrees, add them to the `./.trees` folder
- When creating a new worktree, copy `config/master.key` into it so `rails` commands work

## Branches

- `main` - Main development branch (default for PRs)
  - You should not push here directly
- `staging` - Testing environment
- `production` - Production environment
  - You should never push here directly

**CRITICAL**: Never merge `staging` into working branches!

## Branch Naming

- Prefix branches with `claude.` to indicate they came from you
- Include short snake_case description followed by `.` and ticket number when applicable
  - `claude.fix_login_page.g1234` - GitHub issue #1234

## Commit Messages

- First line: brief description
- If multiline needed: blank line, then more description lines
- If tagging issues: blank line, then one line per ticket
- All lines limited to 72 characters

### Examples

- ```txt
  fix: typo in login logic
  ```
- ```txt
  feat: add this really cool feature users asked for

  they wanted A, B, and C
  A works like this
  B works like this
  C works like this

  closes #1234
  ```
- ```txt
  fix: fix some bug with corresponding ticket

  fixes #1234
  ```

## Workflow

1. Branch from `main`
2. Run RuboCop and ESLint before committing
3. Open PR to `main`
4. After approval, squash and merge

## PR Comments

<pr-comment-rule>
When I say to add a comment to a PR with a TODO on it, use the 'checkbox' markdown format:

<example>
- [ ] A description of the todo goes here
</example>
</pr-comment-rule>

- When tagging Claude in GitHub issues, use '@claude'

## GitHub

- Primary method for interacting with GitHub: GitHub CLI
- When creating a PR for code you wrote, ask which labels to apply per the PR Labels section (typically offering "AI Generated", "Manual PR Body", and "coderabbitreview") and make it a draft
- When pulling an issue via `gh issue view`, use `--json` to avoid GraphQL deprecation error:

```bash
gh issue view 873 --json title,body,labels,state --jq '{title, body, labels: [.labels[].name], state}'
```

- When updating a PR, don't use `gh pr edit`. Use `gh api` to avoid GraphQL deprecation error

```bash
gh api repos/mlwyatt/sudoku/pulls/39 -X PATCH -f body="##..."
```

## PR Labels

When creating PRs, always use `AskUserQuestion` with `multiSelect: true` to confirm labels. Format options as:
1. First option: all labels combined with "(Recommended)"
2. Then each label individually
