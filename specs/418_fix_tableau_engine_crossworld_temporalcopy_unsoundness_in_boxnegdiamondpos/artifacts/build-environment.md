# Build Environment Snapshot and Build-Reliability Protocol

Task 418 — Phase 1 artifact. Establishes the advisory build-lock convention (none existed in this
repository before this task) and the infra-vs-verdict triage checklist every later phase follows
verbatim.

## 1. Starting State Snapshot

Captured at Phase 1 start.

| Datum | Value |
|-------|-------|
| `find .lake/build -name "*.olean" \| wc -l` | **405** |
| `git rev-parse HEAD` | `6c4dc2711aa47f407ff241f631a97ad61402421b` |
| `git status --short` | 4 modified files, all under `specs/` (`418_.../plans/01_...md`, `TODO.md`, `events.jsonl`, `state.json`). **Zero `.lean` files modified.** |

### Concurrent processes at Phase 1 start (`pgrep -af "lake\|lean --"`)

Three independent `lake serve` instances (PIDs 779004, 1418956, 2061239) with their paired
`lean --server` processes, plus five `lean --worker` file workers:

| PID | Worker file |
|-----|-------------|
| 1443365 | `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` |
| 1447869 | `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` |
| 1520663 | `FormalSystem/Theorems/DedekindDerived.lean` |
| 1544036 | `FormalSystem/Semantics/DurationClassification.lean` |
| 2385729 | `Cslib/Logics/Propositional/Tableau/Intuitionistic/Scheme.lean` (different repo) |

PID 1447869 holds `Verified/Decidable.lean` — task 165's file, and this task's named
do-not-touch file — open in an editor session. This is exactly the hazard the protocol below
guards against.

## 2. Advisory Build Lock Convention

**Lock path**: `.lake/.task-418-build.lock` (under the gitignored `.lake/` tree; not a
deliverable, not committed).

**Contents**: three lines — task number, acquiring PID, ISO8601 acquisition time.

### Acquire

```bash
if [ -f .lake/.task-418-build.lock ]; then
  # inspect; see stale detection below
  cat .lake/.task-418-build.lock
else
  printf '418\n%s\n%s\n' "$$" "$(date -Iseconds)" > .lake/.task-418-build.lock
fi
```

### Release

```bash
rm -f .lake/.task-418-build.lock
```

### Stale detection

A lock is **stale**, and may be broken, when BOTH hold:

1. Its acquisition timestamp is more than 60 minutes old, AND
2. Its recorded PID is not alive (`kill -0 <pid>` fails).

If either condition fails, the lock is live: wait and retry rather than breaking it.

**This lock is advisory only.** The three concurrent sessions predating this task (tasks 408,
414, 415) do not know it exists and will not honor it. It is honored here so that (a) this task
never destroys its own concurrent work, and (b) a convention exists for later tasks to adopt.
It is not a guarantee of exclusivity — the olean-count bracketing in section 3 is the actual
detector.

## 3. Infra-vs-Verdict Error Triage Checklist

**Run before drawing any conclusion from any build.** Every phase follows this verbatim.

### Step A — bracket the build

```bash
before=$(find .lake/build -name "*.olean" | wc -l)
lake build ... 2>&1 | tee <logfile>; rc=${PIPESTATUS[0]}
after=$(find .lake/build -name "*.olean" | wc -l)
```

### Step B — classify every error

| Class | Signatures | Meaning |
|-------|-----------|---------|
| **Verdict error** | `#guard_msgs` mismatch; `unsolved goals`; `type mismatch`; `unknown identifier`; `function expected`; any error with a `file:line:col` Lean diagnostic pointing into source | Real, attributable to this task's edit. Act on it. |
| **Infrastructure error** | `could not resolve import`; missing or corrupt `.olean`; `error: no such file or directory` under `.lake/`; abrupt non-zero exit with **no** Lean diagnostic; `after < before` olean count | The concurrent-session hazard. **Not** a result. |

### Step C — act on the classification

- **Infrastructure error, or `after < before`**: the run is **INCONCLUSIVE**. Re-check the olean
  count, wait, and **retry the whole build**. It never means the gate passed. It never means the
  gate failed. Discard any partially-written measurement artifact from that run.
- **Verdict error**: attributable. Record it, triage it, repair it per the owning phase.
- **`rc == 0` and `after >= before`**: the build ran to completion. Only in this case may a
  baseline or acceptance result be written to an artifact.

### Standing prohibitions (bind every phase)

1. **Never run `lake clean`.** Not to force a rebuild, not to resolve a confusing error, not as
   a last resort. If a stale artifact is genuinely suspected, delete the single specific
   `.olean`/`.trace` pair under `.lake/build/lib/lean/` and rebuild that one module.
2. **Never record an oleans-were-deleted failure as corpus validation.**
3. **Prefer scoped builds during iteration** (`lake build FormalSystem.Metalogic.Decidability.Tableau`);
   reserve full `lake build` + `lake build BimodalTest` for phase-end and acceptance gates.

## 4. Corpus Command Confirmation

Read from `lakefile.lean` at Phase 1:

```lean
@[default_target]
lean_lib FormalSystem where
  srcDir := "."
  roots := #[`FormalSystem]

lean_lib BimodalTest where      -- NO @[default_target]
  srcDir := "Tests"
  roots := #[`BimodalTest]
```

`package Logos where testDriver := "BimodalTest"`.

**Confirmed**: `@[default_target]` sits on `lean_lib FormalSystem` only. A bare `lake build`
compiles the library and **not one `#guard_msgs` row**. The corpus command is:

```
lake build BimodalTest
```

Both commands are required at every full gate, in that order.

## 5. Accessor Definitions Confirmed Present

`FormalSystem/Metalogic/Decidability/SignedFormula.lean`, verified by `grep -n "AtTime"`:

| Line | Definition |
|------|-----------|
| 473 | `def allFuturePosAtTime (b : Branch) (t : TimeIndex) : List SignedFormula` |
| 483 | `def allPastPosAtTime` |
| 494 | `def someFutureNegAtTime` |
| 505 | `def somePastNegAtTime` |
| 516 | `def untlNegAtTime` |
| 527 | `def snceNegAtTime` |

All six exist at the predicted `473-537` range. The Phase 3 edit is therefore unambiguously a
**call-site deletion** inside `applyRule` — these six definitions are NOT deleted (they remain
named by `SubformulaProperty.lean`).
