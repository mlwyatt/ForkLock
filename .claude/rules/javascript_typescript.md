# JavaScript/TypeScript

## Code Quality

```bash
# ESLint (JavaScript/TypeScript)
yarn lint app          # Check all
yarn lint path/to/file # Specific file

# Asset building
yarn build:ts         # TypeScript/JavaScript
```

## Code Style

- ESLint configured with `@brandsinsurance/eslint-plugin`
- Don't use HTML IDs for JS lookup. Instead, use HTML classes prefixed with `js--`
