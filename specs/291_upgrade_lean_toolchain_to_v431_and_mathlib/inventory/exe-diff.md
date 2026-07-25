# Phase 8 — `do`-Elaborator Semantic Audit and Executable Output Diff

This phase exists because **a green `lake build` cannot detect the change it tests**. Lean 4.32
(#13912) altered where `return e` returns *from* when it sits inside a nested action, with no
compile error either way.

## Part 1 — Source audit: nested-`return` exposure is ZERO

The dangerous syntax is `return` lexically inside a `(← do …)` or `(← try … catch …)`. Before
4.32 such a `return` exited the **nested** block; from 4.32 it exits the **enclosing** `do`.

A scan of `Theories/` and `Tests/` for nested-arrow action blocks — matching both the inline form
(`… ← try`) and the wrapped form (a line ending in `←` followed by `do`/`try`), since a
single-line grep misses the latter — finds exactly **two** sites in the whole repository:

| Site | Shape | Body | Affected? |
|---|---|---|---|
| `Automation/DatasetGenerator.lean:1729` | `let labeled ← try … catch _e => …` | `labelFormulaWithCache …` / `pure (mkTimeout φ)` | **No** — no `return` in either branch |
| `Automation/Tactics/Deduction.lean:64` | `let newGoals ← try … catch _ => …` | `goal.apply …` / `throwError …` | **No** — no `return` in either branch |

**Neither branch of either site contains a `return`.** The repo's exposure to #13912 is nil.

This is worth stating precisely because the plan's own risk assessment pointed the other way:
it noted 12 `IO`-heavy `lean_exe` targets, 241 `let mut`, 15 `catch`, 10 `try` and called the
exposure "concentrated exactly where it hurts". Those raw counts are not the exposure. `return`
appears 338 times under `Automation/` alone, but every one of them is in a plain `do` block or a
plain `try`/`catch` **statement**, where both the old and the new semantics agree. Only the
nested-arrow position changed, and the repo uses it twice.

Two near-misses worth recording, since both look like hits under a coarser grep:

- `Automation/Tactics/Helpers.lean:629` has `return ()` inside a `try … catch _ => continue`.
  That `try` is a **statement**, not `← try`, so the `return` exits the enclosing `observing? do`
  under both old and new semantics. Unchanged.
- `Automation/DatasetGenerator.lean:1747` has `cache.atomically do return (← get)`. The `do` is a
  function **argument**, not in `←` position — the `←` binds `cache.atomically (…)`, not the
  `do`. The `return` exits that inner block under both semantics. Unchanged.

## Part 2 — The other 4.32 `do`-elaborator changes

| Change | Repo exposure | Detected by |
|---|---|---|
| `do` now requires `Pure`, not just `Bind` | — | green build (type error if violated) |
| `do match` arms non-dependent by default | **0 occurrences** of `do match` | grep |
| `try`/`catch` bodies no longer coerce to match | — | green build (type error if violated) |
| `let pat := rhs \| otherwise` scopes over the following `doSeq` | 1 site | see below |

The single `let pat := … | otherwise` site is `Automation/Tactics/Helpers.lean:815`:

```lean
let [memGoal] := newGoals | throwError "expected single membership goal"
```

The `otherwise` branch **throws**, so it cannot fall through into the re-scoped `doSeq` and the
change is semantically invisible here. This construct is only dangerous when `otherwise`
*returns normally* (e.g. `| pure ()`) and statements follow it.

## Part 3 — Executable output diff

Captured with `baseline/run-exes.sh`, the same script used for the Phase 1 baseline, so the
invocations are byte-identical. Compared with `baseline/compare-exes.sh`, which applies the
per-target tiering measured in `baseline/exe/REPRODUCIBILITY.md`:

- **Tier 1** (7 targets) — exact comparison after elapsed-time and absolute-path masking.
- **Tier 2** (5 targets) — RNG-derived cardinalities additionally masked, because these targets
  call unseeded `IO.rand` and **do not reproduce against themselves**. A Tier 2 "pass" is
  therefore a weaker statement than a Tier 1 pass, and that weakness is a property of the
  targets, not of this upgrade.

Results are appended below once the post-upgrade capture completes.

---

## Part 3 results — 7/7 Tier 1 exact, one real behaviour change

### Two harness defects found first (both would have produced a bogus verdict)

The first capture attempt reported **10 of 12 targets differing**. Every one of those was a
harness artifact, not an upgrade effect. Recording both, because either alone is enough to make
this gate lie:

1. **Five exe roots import modules outside the default `lake build` target's closure.**
   `benchmark_anchors`, `machine_appendix`, `proof_extractor`, `trace_exporter` exited 1 with
   `object file '…/Bimodal/Automation/AxiomNames.olean' … does not exist` (likewise
   `Theorems/ContextualProofs`, `Decidability/TraceExport`), and `benchmark_oracle` then failed
   on the missing input file the first of those was supposed to produce. A green `lake build`
   does **not** imply the exe roots are runnable. Fix: build the twelve exe root modules by name
   first — `lake build Bimodal.Automation.DatasetValidator …` (790 jobs).

2. **`normalize.sh` masks output paths only under directories literally named
   `exe`, `exe-run2`, or `exe-post`** (`s#[^ "]*/(exe|exe-run2|exe-post)/…#<OUTDIR>/\2#g`). A
   capture written to any other directory name reports a spurious path diff on every target that
   prints its output path. Fix: name the capture directory `exe-post`.

Both are recorded as follow-ups; neither is a defect introduced by this upgrade.

### Comparison after fixing the harness

```
MATCH       benchmark_anchors      [exact]
MATCH       benchmark_oracle       [exact]
DIFF        contrastive_generator  [structural]   <-- REAL, see below
DIFF        dataset_generator      [structural]   <-- VmPeak only
MATCH       dataset_validator      [exact]
DIFF        enum_benchmark         [structural]   <-- documented RNG non-reproducibility
MATCH       machine_appendix       [exact]
MATCH       proof_extractor        [exact]
DIFF        proof_first_generator  [structural]   <-- unmasked 0ms/1ms timing field
MATCH       tableau_bridge         [exact]
MATCH       tableau_proof_steps    [structural]
MATCH       trace_exporter         [exact]
```

**All 7 Tier 1 targets match exactly.** That is the strong gate, and it passes cleanly.

Of the 4 Tier 2 differences, 3 are not behaviour changes:

| Target | Difference | Assessment |
|---|---|---|
| `dataset_generator` | `VmPeak: 4746168 kB` → `23957024 kB` | Peak *virtual* address space, not program output. `normalize.sh` masks `VmRSS` but not `VmPeak`. A larger reservation by the new runtime, not a change in what the program computed — every other line of a 67-line comparison is identical. |
| `enum_benchmark` | closure converged at round 4 → round 5 | Within this target's documented self-non-reproducibility: `REPRODUCIBILITY.md` records two *pre-upgrade* runs giving pool sizes 108 vs 98 and valid counts 43 vs 45. |
| `proof_first_generator` | `Ex-falso cap applied in 0ms` → `1ms` | Timing field that `normalize.sh` does not mask in the `in <N>ms` form. |

### Data products: 7 of 10 byte-identical

Compared by SHA256 against `baseline/exe/data-products.tsv`:

| Product | Lines | Verdict |
|---|---|---|
| `axiom-instances.jsonl` | 110 = 110 | **MATCH** |
| `oracle-validated.jsonl` | 110 = 110 | **MATCH** |
| `machine-appendix.jsonl` | 71 = 71 | **MATCH** |
| `proof_steps.jsonl` | 12,077 = 12,077 | **MATCH** |
| `dataset_metadata.json` | 23 = 23 | **MATCH** |
| `tableau_steps.jsonl` | 0 = 0 | **MATCH** |
| `tableau_steps_metadata.json` | 20 = 20 | **MATCH** |
| `contrastive.jsonl` | 3 = 3 | DIFF — same three records, **reordered** (`r,q,p` vs `q,p,r`); content identical field-for-field |
| `dataset.jsonl` | 321 = 321 | DIFF — Tier 2, RNG-ordered |
| `proof_first.jsonl` | 10,000 = 10,000 | DIFF — Tier 2, RNG-ordered |

A byte-identical 12,077-line `proof_steps.jsonl` is the single strongest signal in this gate.

### The one real behaviour change: `deriving Inhabited` now respects field defaults

`contrastive_generator`'s console output differs structurally, and the cause is **not** the
change this phase was built to catch:

```
- Config: maxComplexity=3, maxModalDepth=0, maxTemporalDepth=0, maxFormulas=0
+ Config: maxComplexity=3, maxModalDepth=2, maxTemporalDepth=2, maxFormulas=1000
- [enum] Level 3/3: 0 formulas (cumulative: 0)          - [gen] Total: 5 unique formulas
+ [enum] Level 3/3: 684 formulas (cumulative: 684)      + [gen] Total: 689 unique formulas
```

Root cause, verified directly under the new toolchain rather than inferred from release notes:

```lean
structure Cfg where
  a : Nat := 5
  b : Nat := 2
  c : String := "hello"
  deriving Repr, Inhabited

#eval (default : Cfg)
-- v4.27: { a := 0, b := 0, c := "" }
-- v4.33: { a := 5, b := 2, c := "hello" }
```

`FormulaMutator.lean:1058` seeds CLI parsing with `go args default`, so under v4.27 every field
except the explicitly-passed `--max-complexity` was zero — and `maxFormulas = 0` made the
generator enumerate nothing. The upgrade **fixed a latent bug**, silently, with a green build
throughout. `baseline/exe/contrastive.jsonl` records the *broken* behaviour and must not be
treated as the desired output.

This is precisely the class of change the phase exists for; it simply arrived through a different
mechanism than #13912.

### Other `default`-seeded sites

Fifteen structures in the tree combine field defaults with `deriving Inhabited`. Only consumption
through a bare `default` changes behaviour — `{}` and `{ x with … }` always used the declared
defaults. The consuming sites:

| Site | Structure | Effect |
|---|---|---|
| `FormulaMutator.lean:1058` | `ContrastiveConfig` | confirmed above |
| `DatasetExport.lean:197-198` | `PatternKey`, `DifficultyMetrics` | `difficultyTier` `""` → `"unknown"` in **timeout** records |
| `DatasetGenerator.lean:231` | `DifficultyMetrics` | same |
| `Tests/…/ProofFirstTests.lean:186,190` | `DifficultyMetrics`, `PatternKey` | same, in fixtures |

The `difficultyTier` flip did not surface in this run's `dataset.jsonl` — that capture produced
no timeout records, and the emitted schema does not carry the field — but it is a real
data-format change for any run that does, and downstream consumers should be told.
