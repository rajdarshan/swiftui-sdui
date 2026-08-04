module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'refactor',
        'test',
        'docs',
        'chore',
        'perf',
        'build',
        'ci',
        'style',
        'revert'
      ]
    ],
    'scope-enum': [
      2,
      'always',
      [
        'ios',
        'sdui-config',
        'perf',
        'docs',
        'deps',
        'release'
      ]
    ],
    'scope-empty': [1, 'never'],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100]
  }
};