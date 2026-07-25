# Research: Eliminate `sorry` in ModalS5.lean and Perpetuity/Principles.lean

**Task**: 294
**Type**: lean4
**Session**: sess_1784999032_8d6f8f_294
**File scope**: `Theories/Bimodal/Theorems/ModalS5.lean`, `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`

## Headline Finding

**The task premise is false. Both target files are already fully sorry-free.** There are zero
`sorry` instances to eliminate. No proof work is required.

The task description asserted "1-3 sorry each". This is not the case as of the current working
tree (`main`, dirty only in `specs/`). Verified by two independent methods that agree.

## Verification Evidence

### Method 1: Axiom audit (authoritative)

`#print axioms` is transitive over the whole dependency graph of a declaration, so a clean
result here is proof that no `sorry` reaches the declaration from anywhere. All 31 declarations
across the two files were audited via `lake env lean` on a scratch file importing both modules.

**Result**: every declaration depends on at most `[propext, Classical.choice, Quot.sound]` — the
three standard Lean/Mathlib axioms. **`sorryAx` appears nowhere.**

| File | Declarations audited | `sorryAx` present |
|------|---------------------|-------------------|
| `ModalS5.lean` | 12 (`box_conj_iff`, `box_contrapose`, `box_disj_intro`, `box_iff_intro`, `classical_merge`, `diamond_disj_iff`, `iff`, `k_dist_diamond`, `s5_diamond_box`, `s5_diamond_box_to_truth`, `t_box_consistency`, `t_box_to_diamond`) | none |
| `Perpetuity/Principles.lean` | 19 (`box_conj_intro`, `box_conj_intro_imp`, `box_conj_intro_imp_3`, `box_diamond_to_future_box_diamond`, `box_diamond_to_past_box_diamond`, `box_dne`, `box_to_box_past`, `contraposition`, `diamond_4`, `future_k_dist`, `mb_diamond`, `modal_5`, `past_k_dist`, `perpetuity_1`–`perpetuity_5`, `persistence`) | none |

`Bimodal.Theorems.ModalS5.iff` depends on no axioms at all (it is a plain `Formula` constructor
`def`, not a proof).

### Method 2: Source scan over the transitive import closure

The transitive `Bimodal.*` import closure of the two targets is **17 modules**. Scanning all 17
for `sorry`/`admit` as code tokens, with block comments (`/- ... -/`) and line comments (`--`)
stripped first:

**Result**: no `sorry` or `admit` in code anywhere in the closure.

This matters for PR 4 specifically: a cslib PR vendors whole files, so the debt surface is the
closure, not just the two files. The closure is clean.

### Method 3: Build

```
lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles
-> Build completed successfully (696 jobs).
```

Zero errors. Zero `declaration uses 'sorry'` warnings. Note the correct module names are
`Bimodal.Theorems.*` (lakefile sets `srcDir := "Theories"`, `roots := #[`Bimodal]`), **not**
`Theories.Bimodal.Theorems.*` — the latter fails with `unknown target`.

### Why the premise looked true

A naive `grep -rn "sorry"` returns 4 hits across the two files, but **all four are prose inside
comments**, three of which are stale claims and one of which asserts the opposite:

| Location | Text | Reality |
|----------|------|---------|
| `ModalS5.lean:485` | "Marked as sorry pending Phase 3." | Stale — the biconditionals below it are proven |
| `Principles.lean:103` | "which is left as sorry for the MVP" | Stale — `contraposition` is proven, `[propext]` only |
| `Principles.lean:686` | "FULLY DERIVED (zero sorry)" | Accurate |
| `Principles.lean:889` | "FULLY PROVEN (zero sorry)" | Accurate |

There are no Lean `axiom` declarations and no vacuous `:= True`/`trivial` placeholders in either
file. (`Axiom.prop_k` etc. are constructors of the *object-logic* `Axiom` inductive type, which
is the intended design, not Lean-level axiomatization.)

## Actual Remaining Work

The stated goal is already met, so there is nothing to prove. Two categories of real, small work
exist. Both are documentation/hygiene, not proof engineering.

### A. Stale documentation claiming sorries and incompleteness

These are actively misleading — they are what caused this task to be filed — and would misinform
a cslib PR-4 reviewer reading the module docstrings.

| Location | Stale claim | Correction |
|----------|-------------|------------|
| `ModalS5.lean:481-486` | Section header "Biconditional Theorems (Infrastructure Pending)" + "Marked as sorry pending Phase 3." | Biconditionals are proven; drop the "pending"/"sorry" framing |
| `Principles.lean:98-104` | "requires propositional reasoning patterns that are complex to encode"; "left as sorry for the MVP. The semantic justification remains sound." | `contraposition` is fully derived; remove the MVP/sorry disclaimer |
| `Theorems.lean:31` | "Modal S5 Phase 2: PARTIAL (4/6 proven, biconditionals pending)" | All 12 ModalS5 declarations audit clean — not partial |
| `Theorems.lean:39` | "P5: `◇▽φ → △◇φ` - THEOREM (using modal_5, 1 technical sorry)" | `perpetuity_5` audits clean; no sorry |
| `Theorems.lean:40` | "P6: `▽□φ → □△φ` - AXIOMATIZED (semantic justification)" | `perpetuity_6` audits clean (`[propext, Classical.choice, Quot.sound]`); it is derived, not axiomatized |

`Theorems.lean` and `Bridge.lean` are outside the declared `file_scope`. `Theorems.lean:31/39/40`
are the roll-up status lines that most directly contradict the audit, and `Bridge.lean:980-981`
already states P5/P6 are fully proven — so `Theorems.lean` is the file that is out of sync with
both the code and its own siblings. Recommend expanding scope to include `Theorems.lean`; flagged
rather than assumed.

### B. Linter warnings in the closure

Not `sorry`, but relevant if PR 4 targets cslib/Mathlib warning-free style. All are
`linter.unusedSimpArgs`, and every one names the same unused argument
`Formula.swap_temporal_all_past`:

| File | Warning lines | Count |
|------|---------------|-------|
| `Metalogic/Core/DeductionTheorem.lean` | — | 8 |
| `Theorems/Perpetuity/Principles.lean` | 400, 667, 744, 810, 846 | 5 |
| `Syntax/Formula.lean` | — | 4 |
| `Theorems/Perpetuity/Bridge.lean` | 191, 604, 706 | 3 |
| `Theorems/GeneralizedNecessitation.lean` | — | 1 |

`ModalS5.lean` produces **zero** warnings. The fix is mechanical: drop
`Formula.swap_temporal_all_past` from each flagged `simp only [...]` list. The linter already
prints the exact corrected invocation for each site. Low risk, but each edit must be
re-verified by build since removing a simp arg can in principle change simp's behavior.

## Recommendation

Do **not** dispatch a proof-implementation phase; there is no proof work and an implementation
agent given this task as written would either no-op or, worse, churn on already-correct proofs.

Suggested disposition:

1. **Re-scope the task** to "correct stale sorry/incompleteness documentation and clear
   `unusedSimpArgs` warnings in the PR-4 file set", or
2. **Close as already-satisfied** with the audit evidence above recorded, and file the
   documentation correction as its own small `markdown`/`lean4` task.

Either way the zero-sorry acceptance criterion for PR 4 is **already met** for these two files
and their entire 17-module import closure.

If option 1 is taken, the work is a single phase: 5 docstring/status corrections (item A) plus 5
`simp only` argument removals in `Principles.lean` (item B, scoped to the in-scope file), then
`lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` to confirm still
green. Clearing item B in the other four files is optional and can be deferred.

## Incidental Observation (out of scope, not actioned)

`CLAUDE.md` states "Lean v4.27.0-rc1 with Mathlib v4.27.0-rc1", but `lakefile.lean` pins mathlib
at `v4.33.0-rc1`. Worth correcting separately; unrelated to this task and not touched.

## Reproduction

Axiom audit (the load-bearing check):

```bash
# scratch file importing both modules, then #print axioms on each declaration
lake env lean /path/to/audit.lean
# every line reports at most [propext, Classical.choice, Quot.sound]
```

Build:

```bash
lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles
```
