# ruby

## Important rules

- Never auto-fix unsafe cops (`rubocop -A`); instead use `rubocop -a` to auto-fix safe cops
- Never inline-disable rubocop without asking. There's almost always a fix

## YARD

- Single-line comments are fine for self-explanatory methods: `# @return [Boolean]`
- Multiline format:
  - First line: description
  - Blank line
  - One line per `@param`
  - Blank line
  - `@return` line
  - Blank line

```ruby
# @return [Boolean]
def my_method?
  rand > 0.5
end
```

```ruby
# Combines the two arguments into a hash
#
# @param arg_one [Boolean]
# @param arg_two [Boolean]
#
# @return [Hash]
#
def my_method(arg_one, arg_two)
  { first: arg_one, second: arg_two }
end
```

## Code Style

- RuboCop inherits from `rubocop-rubomatic-rails` gem
- Don't use `unless [...].include?(...)`. Instead, use `if [...].exclude?(...)`
- When returning `nil`, don't do `return nil`, just use `return`
- Instead of
  ```ruby
  @tasks = ClaimWorkflowTask.includes(:claim, :assigned_to)
    .pending
    .order(:due_date, :created_at)
  ```
  do
  ```ruby
  @tasks =
    ClaimWorkflowTask
      .includes(:claim, :assigned_to)
      .pending
      .order(:due_date, :created_at)
  ```
- Instead of
  ```ruby
  val = if rand > 0.5
          1
        else
          0
        end
  ```
  do
  ```ruby
  val =
    if rand > 0.5
      1
    else
      0
    end
  ```

## Code Quality

```bash
# RuboCop (Ruby linting)
rubocop              # Check all
rubocop -a           # Auto-fix
rubocop path/to/file # Specific file
```
