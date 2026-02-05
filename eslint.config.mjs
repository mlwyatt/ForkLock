import { defineConfig, globalIgnores } from 'eslint/config';
import brands from '@brandsinsurance/eslint-plugin';
import globals from 'globals';
import tsEslint from 'typescript-eslint';

const internalGlobals = Object.fromEntries(
  [
    'Turbo',
  ].map((glob) => [glob, 'readonly']),
);
const ignores = [
  'node_modules/',
  'public/',
  'app/assets/builds',
  'app/assets/config/manifest.js',
  'esbuild.config.js',
  'app/javascript/dist/*',
];


export default defineConfig([
  globalIgnores(ignores),
  brands.configs.tsGeneric,
  brands.configs.tsStimulus,
  {
    linterOptions: { reportUnusedDisableDirectives: 'warn' },
    languageOptions: {
      globals: {
        ...internalGlobals,
        ...globals.browser,
      },
      ecmaVersion: 2025,
      parser: tsEslint.parser,
      parserOptions: {
        sourceType: 'module',
        ecmaVersion: 2025,
        project: ['./tsconfig.json'],
      },
    },
  },
  {
    files: ['./**/*'],
    rules: {
      "@typescript-eslint/no-type-alias": ['error', {
        allowAliases: 'always',
        allowCallbacks: 'always',
        allowConditionalTypes: 'always',
        allowConstructors: 'never',
        allowLiterals: 'always',
        allowMappedTypes: 'always',
        allowTupleTypes: 'never',
        allowGenerics: 'always',
      }],
      "@typescript-eslint/naming-convention": [
        "error",
        {
          "selector": "import",
          "format": ["camelCase", "PascalCase"],
        },
        {
          "selector": "variableLike",
          "filter": {
            "regex": "^(Turbo)$",
            "match": true,
          },
          "format": [
            "PascalCase",
          ],
          "leadingUnderscore": "allow",
          "trailingUnderscore": "allow",
        },
        {
          "selector": "property",
          "filter": {
            "regex": "^(PageSnapshot|Stimulus)$",
            "match": true,
          },
          "format": [
            "PascalCase",
          ],
          "leadingUnderscore": "allow",
          "trailingUnderscore": "allow",
        },
        {
          "selector": "property",
          "filter": {
            "regex": "^(X-CSRF-Token)$",
            "match": true,
          },
          "format": null,
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "variableLike",
          "filter": {
            "regex": "^([A-Z][a-z]+)+Search$",
            "match": true,
          },
          "format": [
            "PascalCase",
          ],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "default",
          "format": [
            "camelCase",
          ],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "default",
          "modifiers": [
            "unused",
          ],
          "format": [
            "camelCase",
          ],
          "leadingUnderscore": "require",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "variableLike",
          "modifiers": [
            "unused",
          ],
          "format": [
            "camelCase",
            "UPPER_CASE",
          ],
          "leadingUnderscore": "require",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "variableLike",
          "format": [
            "camelCase",
            "UPPER_CASE",
          ],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "enumMember",
          "format": [
            "UPPER_CASE",
          ],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
        {
          "selector": "typeLike",
          "format": [
            "PascalCase",
          ],
          "leadingUnderscore": "forbid",
          "trailingUnderscore": "forbid",
        },
      ],
      "no-restricted-imports": [
        'error',
        {
          patterns: [
            {
              group: ['../'],
              message: 'Relative imports from parent directories are not allowed.',
            },
          ],
        },
      ],
    },
  },
  {
    files: ['app/javascript/controllers/**/*'],
    rules: {
      'import/no-unused-modules': [
        'error',
        {
          missingExports: true,
          unusedExports: false,
        },
      ],
    },
  },
  {
    files: ['app/javascript/scripts/common/search/rawr/index.ts'],
    rules: {
      'import/no-unused-modules': 'off',
    },
  },
  {
    files: ['app/javascript/controllers/index.js'],
    rules: {
      'import/no-unresolved': 'off',
      'import/extensions': 'off',
      'import/no-unused-modules': 'off',
    },
  },
  {
    files: ['app/javascript/controllers/**/*'],
    rules: {
      'class-methods-use-this': 'off',
    },
  },
  {
    files: ['app/javascript/application.ts'],
    rules: {
      'import/no-unassigned-import': 'off',
      'import/no-unused-modules': 'off',
    },
  },
  {
    rules: {
      '@stylistic/object-curly-newline': [
        'error',
        {
          ObjectExpression: { multiline: true, consistent: true },
          ObjectPattern: { multiline: true, consistent: true },
          ImportDeclaration: { multiline: true, consistent: true },
          ExportDeclaration: { multiline: true, consistent: true },
          TSTypeLiteral: { multiline: true, consistent: true },
          TSInterfaceBody: 'always',
          // TSEnumBody: 'always',
        },
      ],
    },
    settings: {
      'import/parsers': {
        '@typescript-eslint/parser': ['.ts'],
      },
      'import/extentions': ['.js', '.ts'],
      'import/resolver': {
        typescript: true,
        node: true,
      },
      'import/cache': {
        lifetime: 'Infinity',
      },
    },
  },
]);
