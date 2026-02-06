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
- Do not use `this` more than 5 times. Instead use `const self = this;`
- Do not use `this` across function scopes:
```js
// Bad
function calc() {
  [1,2,3].forEach((n) => {
    console.log(this);
  });
}

// Good
function calc() {
  const self = this;
  [1,2,3].forEach((n) => {
    console.log(self);
  });
}
```
