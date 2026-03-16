# Scripts

Utility scripts for development, testing, and maintenance.

## Contents

| File | Description |
|------|-------------|
| check-regression.sh | Check for regressions in test suite |
| coverage-analysis.sh | Analyze test coverage |
| run-benchmarks.sh | Run performance benchmarks |
| update-context-refs.sh | Update Claude context references |
| verify-agent-tools.sh | Verify agent tool configurations |
| LintAll.lean | Run all Lean linters |
| LintStyle.lean | Style-specific linting |
| RunEnvLinters.lean | Environment linter runner |

## Usage

All shell scripts are executable:
```bash
./scripts/check-regression.sh
./scripts/run-benchmarks.sh
```

Lean scripts run via lake:
```bash
lake env lean scripts/LintAll.lean
```

---

*Last Updated: 2026-03-16*
