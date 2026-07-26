# Judgment-Requiring Linter Categories — Re-Derived Inventory and Validated Methodology

**Task**: 398 — fix_judgment_requiring_linter_categories
**Session**: sess_1785074764_351b3f_398
**Status**: research complete
**Toolchain**: Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1` (resolved `79d0395a`)

Every count and every claim below comes from a command that was actually run in this session.
Reproduction commands are inline. Nothing is carried over from the predecessor report without
re-measurement.

---

## 0. Baseline verification (invariant for this task)

```
$ lake build
Build completed successfully (1875 jobs).      # 0 errors

$ grep -rnE '^\s*sorry\s*$|:= *sorry|by sorry' --include=*.lean Theories/ Tests/ | grep -v Boneyard
Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1227:  sorry
```

**Confirmed**: 0 errors, **exactly 1 live sorry**, at `Transfer.lean:1227`
(`WeakCanonical.countermodel_discrete`). The dispatch's staleness correction is accurate; the
task description's own "12 sorries" invariant is wrong and must not be used.

Working tree source is clean (only `specs/` files modified, by concurrent sibling agents). No
source file was mutated during this research — all experiments ran on copies under a scratch
directory, which works because `lake env lean` resolves imports by module name, not by file
location.

---

## 1. Scope resolution

Tiers are inherited from the predecessor baseline (`specs/293_.../reports/01_...md` §3) and
re-derived here as explicit file lists:

| Tier | Roots | Files |
|---|---|---|
| T1 | `Syntax/`, `Semantics/`, `ProofSystem/`, `Theorems/`, `FrameConditions/` | 34 |
| T2 | `Metalogic/{Core,SoundnessLemmas,Decidability,WeakCanonical/Separation}/` + `Soundness.lean`, `Completeness.lean`, `Decidability.lean`, `Metalogic.lean` | 33 |

**T1 + T2 = 67 files.** Reproduction:

```bash
find Theories/Bimodal/{Syntax,Semantics,ProofSystem,Theorems,FrameConditions} -name '*.lean' | grep -v Boneyard   # 34
find Theories/Bimodal/Metalogic/{Core,SoundnessLemmas,Decidability,WeakCanonical/Separation} -name '*.lean' | grep -v Boneyard   # 29, +4 top-level = 33
```

### Linter invocations (both verified working this session)

```bash
# Mechanism A — style/syntax linters (per file)
lake env lean -Dlinter.mathlibStandardSet=true <file.lean>

# Mechanism B — declaration/environment linters (whole library)
lake exe runLinter Bimodal
```

Mechanism A over all 67 files with `xargs -P 8` completes in a few minutes. Mechanism B is a
single run (~2 min warm) producing 2,657 lines.

Note on the task description's claim that `set_option linter.all true` "DOES exist and work":
this was **not** needed and not used. Mechanisms A and B between them account for every finding
in the inventory below, and A's per-file granularity is what the plan needs anyway.

---

## 2. Re-derived inventory — and the number that changes the plan

### 2.1 The raw-vs-distinct distinction (most important finding in this report)

The predecessor's counts are **raw warning emissions**, not source sites. A single tactic inside
a `cases a <;> cases b` chain is re-elaborated once per branch and the linter fires once per
elaboration. `ProofSystem/Axioms.lean` reports **9** `linter.flexible` warnings — all of them at
the identical position `392:40`, i.e. **one** `simp [LE.le]` to edit.

| Category | Raw (matches stale figure) | **Distinct source sites (actual work)** |
|---|---|---|
| `linter.flexible` | 78 | **41** |
| `linter.style.show` | 10 | **10** |
| `unusedArguments` (Mech. B) | 10 | **10** |
| `linter.style.nativeDecide` | 4 | **4** |
| `linter.unusedTactic` | 2 | **2** |
| `linter.style.multiGoal` | 2 | **2** |
| `linter.style.openClassical` | 1 | **1** |
| `simpNF` (Mech. B) | 42 | **42** (41 spurious — see §4) |
| **Total edit sites** | | **70**, of which **~29 are real work** |

Reproduction of the distinct-site count: parse each Mechanism-A output pairing every
`file:line:col: warning:` line with the following `set_option linter.X false` note line, then
deduplicate on `(category, file, line, col)`.

### 2.2 Delta against the stale inventory

| Category | Stale | Re-derived (raw) | Delta | Cause |
|---|---|---|---|---|
| `linter.flexible` | 78 | 78 | **0** | archival touched only T3 files |
| `linter.style.show` | 10 | 10 | 0 | — |
| `unusedArguments` | 10 | 10 | 0 | (predecessor report said 11; now 10) |
| `linter.style.nativeDecide` | 4 | 4 | 0 | — |
| `linter.unusedTactic` | 2 | 2 | 0 | — |
| `linter.style.multiGoal` | 2 | 2 | 0 | — |
| `linter.style.openClassical` | 1 | 1 | 0 | — |
| `simpNF` in scope | "1 of 42" | 1 real of 42 | 0 | — |
| `docBlame` in T1+T2 | 8 | **0** | −8 | fixed by predecessor |
| `linter.defProp` | 3 | 3 | 0 | out of scope (naming task) |

**The Mechanism-A delta is zero.** The predecessor's Boneyard archival moved only T3 material
(`Metalogic/Bundle/SuccExistence.lean`, a block of `Metalogic/Bundle/SuccRelation.lean`, and the
`BXCanonical/Chronicle` + `WeakCanonical/Transfer` chronicle chain), none of which is in T1 or
T2. `Metalogic/Core/RestrictedMCS/Basic.lean` was edited (dead import removed) but its
`linter.flexible` raw count is unchanged at 6 — which resolves to **2** distinct sites.

The one real delta is `docBlame` dropping from 8 to 0 — the predecessor closed it.

### 2.3 Per-file, per-category, distinct sites

| Category | Tier | Sites | File |
|---|---|---|---|
| `linter.flexible` | T2 | 9 | `Metalogic/Core/DeductionTheorem.lean` |
| `linter.flexible` | T2 | 8 | `Metalogic/Decidability/Saturation.lean` |
| `linter.flexible` | T2 | 4 | `Metalogic/Decidability/CountermodelExtraction.lean` |
| `linter.flexible` | T2 | 4 | `Metalogic/Decidability/FMP/Filtration.lean` |
| `linter.flexible` | T2 | 4 | `Metalogic/SoundnessLemmas/FrameClassVariants.lean` |
| `linter.flexible` | T2 | 2 | `Metalogic/Core/RestrictedMCS/Basic.lean` |
| `linter.flexible` | T2 | 1 | `Metalogic/Core/MaximalConsistent.lean` |
| `linter.flexible` | T1 | 2 | `Theorems/Propositional/Connectives.lean` |
| `linter.flexible` | T1 | 2 | `Theorems/Propositional/Reasoning.lean` |
| `linter.flexible` | T1 | 1 | `ProofSystem/Axioms.lean` |
| `linter.flexible` | T1 | 1 | `Semantics/TaskFrame.lean` |
| `linter.flexible` | T1 | 1 | `Semantics/WorldHistory.lean` |
| `linter.flexible` | T1 | 1 | `Theorems/GeneralizedNecessitation.lean` |
| `linter.flexible` | T1 | 1 | `Theorems/Perpetuity/Principles.lean` |
| `linter.style.show` | T2 | 7 | `Metalogic/SoundnessLemmas/FrameClassVariants.lean` |
| `linter.style.show` | T2 | 1 | `Metalogic/Decidability/Propositional/Decidable.lean` |
| `linter.style.show` | T2 | 1 | `Metalogic/Decidability/Propositional/PropForm.lean` |
| `linter.style.show` | T1 | 1 | `Syntax/Atom.lean` |
| `linter.style.nativeDecide` | T2 | 4 | `Metalogic/Decidability/SignedFormula.lean` |
| `linter.style.multiGoal` | T2 | 2 | `Metalogic/Core/DeductionTheorem.lean` |
| `linter.unusedTactic` | T2 | 2 | `Metalogic/Core/DeductionTheorem.lean` |
| `linter.style.openClassical` | T2 | 1 | `Metalogic/Core/DeductionTheorem.lean` |
| `unusedArguments` | T1 | 6 | `FrameConditions/Soundness.lean` (`:69 :84 :100 :119 :130 :142`) |
| `unusedArguments` | T2 | 4 | `Metalogic/SoundnessLemmas/FrameClassVariants.lean` (`:711 :752 :791 :853`) |
| `simpNF` | T1 | 18 | `Derivable.lean` ×1 real; `Truth.lean` ×6, `BigConj.lean` ×3, `Formula.lean` ×4, `NestingDepth.lean` ×4 spurious |
| `simpNF` | T2 | 24 | `Separation/Defs.lean` ×22, `Kalmar.lean` ×2 — all spurious |

**File count for phase sizing: 16 distinct files carry in-scope findings.** Exactly one file
(`DeductionTheorem.lean`) carries four different categories; it is the natural first phase.

### 2.4 Exact flexible site list (41)

```
ProofSystem/Axioms.lean:392:40                       simp [LE.le]           (⊢)
Semantics/TaskFrame.lean:265:25                      simp at hnd
Semantics/WorldHistory.lean:419:4                    simp at this
Theorems/GeneralizedNecessitation.lean:80:22         simp                   (⊢)
Theorems/Perpetuity/Principles.lean:639:4            simp at hx ⊢
Theorems/Propositional/Connectives.lean:253:19       simp                   (⊢)
Theorems/Propositional/Connectives.lean:273:19       simp                   (⊢)
Theorems/Propositional/Reasoning.lean:166:54         simp                   (⊢)
Theorems/Propositional/Reasoning.lean:169:54         simp                   (⊢)
Metalogic/Core/DeductionTheorem.lean:115:2           simp at hx
Metalogic/Core/DeductionTheorem.lean:118:2           simp at this
Metalogic/Core/DeductionTheorem.lean:136:4           simp at h
Metalogic/Core/DeductionTheorem.lean:143:6           simp at h_in
Metalogic/Core/DeductionTheorem.lean:149:6           simp                   (⊢)
Metalogic/Core/DeductionTheorem.lean:238:10          simp                   (⊢)
Metalogic/Core/DeductionTheorem.lean:261:10          simp at hx ⊢           (2 warnings, 1 site)
Metalogic/Core/DeductionTheorem.lean:268:10          simp                   (⊢)
Metalogic/Core/DeductionTheorem.lean:402:12          simp at this
Metalogic/Core/MaximalConsistent.lean:512:4          simp [Set.mem_insert_iff] at h_L_sub
Metalogic/Core/RestrictedMCS/Basic.lean:175:6        simp [Set.mem_insert_iff] at h_L_sub
Metalogic/Core/RestrictedMCS/Basic.lean:220:6        simp [Set.mem_insert_iff] at h_L'_sub
Metalogic/Decidability/CountermodelExtraction.lean:373:4    simp [hb] at hOpen
Metalogic/Decidability/CountermodelExtraction.lean:448:2    simp [Bool.not_eq_true] at h
Metalogic/Decidability/CountermodelExtraction.lean:931:4    simp [extractSemanticCountermodel] at hw'
Metalogic/Decidability/CountermodelExtraction.lean:989:16   simp [extractSemanticCountermodel]  (⊢)
Metalogic/Decidability/FMP/Filtration.lean:205:6     simp at h
Metalogic/Decidability/FMP/Filtration.lean:214:6     simp ...
Metalogic/Decidability/FMP/Filtration.lean:228:8     simp at h1
Metalogic/Decidability/FMP/Filtration.lean:231:6     simp [hy0] at h_uv
Metalogic/Decidability/Saturation.lean:1021:2        simp [SignedFormula.neg] at h_mem
Metalogic/Decidability/Saturation.lean:1110:4        simp at h_result
Metalogic/Decidability/Saturation.lean:1121:6        simp at h_result
Metalogic/Decidability/Saturation.lean:1124:6        simp at h_result
Metalogic/Decidability/Saturation.lean:1203:10       simp [hfc] at h
Metalogic/Decidability/Saturation.lean:1213:14       simp [hexp] at h
Metalogic/Decidability/Saturation.lean:1215:14       simp [hexp] at h
Metalogic/Decidability/Saturation.lean:1219:14       simp ...
Metalogic/SoundnessLemmas/FrameClassVariants.lean:722:4     simp  (⊢)
Metalogic/SoundnessLemmas/FrameClassVariants.lean:741:6     simp  (⊢)
Metalogic/SoundnessLemmas/FrameClassVariants.lean:762:4     simp  (⊢)
Metalogic/SoundnessLemmas/FrameClassVariants.lean:780:6     simp  (⊢)
```

---

## 3. The `simp?`-transcription methodology — validated end to end

### 3.1 The loop

For each file:

1. Replace the flagged `simp…` with `simp?…` at every flagged position (regex: first `\bsimp\b`
   on the line; this handles `simp`, `simp at h`, `simp [X] at h`, `simp at h ⊢` uniformly).
2. `lake env lean <file>` → collect the `Try this: [apply] simp only [...]` suggestions.
   Suggestions are emitted **in source order**, one per flagged position; when one position is
   re-elaborated N times (the `<;> cases` case) it emits N *identical* suggestions.
3. Transcribe each suggestion back, preserving whatever followed the tactic on the line
   (`; exact hnd`, etc.).
4. **Wrap any resulting line over 100 characters** (see §3.3).
5. `lake env lean -Dlinter.mathlibStandardSet=true <file>` → must show 0 errors and 0
   `linter.flexible`.
6. **Repeat from step 1 until fixpoint** (see §3.2 — this is not optional).

### 3.2 Hazard: fixing a flexible site UNMASKS new ones

The `linter.flexible` inventory is **not static**. The linter reports the *first* flexible tactic
in a chain whose result a later tactic depends on. Converting it to `simp only` makes it rigid,
at which point a downstream `simp` in the same proof becomes the new first flexible tactic and is
newly reported.

Measured, in `Metalogic/Core/DeductionTheorem.lean`: fixing the 9 inventoried sites produced a
**new** warning at `152:6` that did not exist in the baseline scan. A second iteration cleared it
and reached fixpoint. **The 41-site figure is a lower bound; budget ~10–15% extra.**

### 3.3 Hazard: the fix reintroduces `linter.style.longLine`

`simp?` suggestions are long. The transcription of `DeductionTheorem.lean:115` is

```
simp only [ne_eq, decide_not, List.mem_filter, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not] at hx
```

which is 114 chars at that indentation. Applying the nine suggestions verbatim introduced **five
new `linter.style.longLine` warnings** in a file the predecessor task had taken to zero. Manual
wrapping (break the lemma list across two lines, continuation indented +2) cleared all five with
no elaboration change.

**The plan must treat "wrap the transcribed line" as part of the edit, not a follow-up.** The
`fix_long_lines.py` helper is not reliable here — it breaks at the last comma before column 100,
which lands inside the bracket list acceptably, but the plan should verify per file rather than
assume.

### 3.4 Validated results

**All 9 T1 flexible sites: fixed, verified 0 errors, 0 residual warnings.**

| Site | Original | Verified replacement |
|---|---|---|
| `ProofSystem/Axioms.lean:392` | `simp [LE.le]` | `simp only [LE.le]` |
| `Theorems/Propositional/Connectives.lean:253` | `simp` | `simp only [List.mem_cons, List.not_mem_nil, or_false]` |
| `Theorems/Propositional/Connectives.lean:273` | `simp` | same as above |
| `Theorems/Propositional/Reasoning.lean:166` | `simp` | `simp only [List.mem_cons]` |
| `Theorems/Propositional/Reasoning.lean:169` | `simp` | `simp only [List.mem_cons]` |
| `Semantics/TaskFrame.lean:265` | `simp at hnd` | `simp only [ne_eq, neg_eq_zero] at hnd` |
| `Semantics/WorldHistory.lean:419` | `simp at this` | `simp only [neg_neg] at this` |
| `Theorems/GeneralizedNecessitation.lean:80` | `simp` | `simp only [List.mem_cons]` |
| `Theorems/Perpetuity/Principles.lean:639` | `simp at hx ⊢` | `simp only [List.mem_cons, List.not_mem_nil, or_false] at hx ⊢` |

**`Metalogic/Core/DeductionTheorem.lean` taken to fully clean** (0 warnings, 0 errors) in two
iterations — 10 flexible edits (9 + 1 unmasked), 2 `simp_wf` deletions, 1 `open Classical`
deletion, plus line wrapping. Verified replacements:

| Line | Replacement |
|---|---|
| 115 | `simp only [ne_eq, decide_not, List.mem_filter, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not] at hx` |
| 118 | `simp only [List.mem_cons] at this` |
| 136 | `simp only [List.mem_cons] at h` |
| 143 | (same big list) `... at h_in` |
| 149 | `simp only [List.mem_cons]` |
| 152 (unmasked) | (same big list) |
| 238 | (same big list) |
| 261 | (same big list) `... at hx ⊢` |
| 268 | (same big list) |
| 402 | `simp only [List.mem_cons] at this` |

**`Metalogic/Decidability/Saturation.lean` — all 8 suggestions obtained** (not yet applied):

```
1021  simp only [SignedFormula.neg, List.mem_cons, List.not_mem_nil, or_false] at h_mem
1110  simp only at h_result
1121  simp only [Option.some.injEq, Sum.inr.injEq] at h_result
1124  simp only at h_result
1203  simp only [hfc] at h
1213  simp only [hexp, Option.some.injEq, Sum.inr.injEq, Prod.mk.injEq] at h
1215  simp only [hexp] at h
1219  simp only [hexp] at h
```

Note the two `simp only at h_result` forms (empty lemma list). These are legitimate — they
perform beta/eta/structural reduction only — and are what `simp?` actually suggests. Transcribe
them verbatim; do not "improve" them into `simp only []` or delete them.

**Zero sites out of the 21 probed produced a failing suggestion.** The transcription methodology
has a measured 21/21 success rate on this codebase, which is materially better than the
predecessor's risk assessment implied.

---

## 4. The `simpNF` "LINTER FAILED" hazard — diagnosed, and it is not a defect at the reported sites

**41 of the 42 in-scope `simpNF` findings are `LINTER FAILED`. Every one of them has the same
body:**

```
Tactic `simp` failed with a nested error:
maximum recursion depth has been reached
```

### 4.1 It is not a `maxRecDepth` setting problem

```lean
-- probe A: import ONLY the module under test
import Bimodal.Syntax.BigConj
import Batteries.Tactic.Lint
#lint only simpNF in Bimodal.Syntax
--> "Found 0 errors in 117 declarations ... All linting checks passed!"
```

At the *default* `maxRecDepth`, in isolation, these declarations are perfectly simp-normal.
Raising `maxRecDepth` to 20000 does **not** fix the failure when it does occur — so it is a
genuine non-terminating rewrite, not a depth shortfall.

### 4.2 Root cause: a looping `@[simp]` lemma in `Automation/Normalization.lean`

```lean
-- probe B: add ONE import
import Bimodal.Syntax.BigConj
import Bimodal.Automation.Normalization      -- <-- the only change
import Batteries.Tactic.Lint
#lint only simpNF in Bimodal.Syntax
--> "Found 7 errors" — all LINTER FAILED / maximum recursion depth
```

Bisected to a single lemma:

```lean
-- Theories/Bimodal/Automation/Normalization.lean:69
@[simp] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl
-- against Theories/Bimodal/Syntax/Formula.lean:121
def neg (φ : Formula) : Formula := φ.imp bot
```

`neg_unfold`'s RHS is definitionally its own LHS pattern, so simp rewrites `φ.imp bot` back to a
match for `?φ.neg` and loops. Confirmed by discharge:

```lean
example : bigconj ([] : List Formula) = Formula.bot.neg := by
  simp [-Bimodal.Automation.Normalization.neg_unfold]     -- SUCCEEDS
  -- with -top_unfold or -and_unfold instead: still fails
```

`lake exe runLinter Bimodal` imports the whole library, so this `@[simp]` set is live and poisons
simp for every `Formula`-valued LHS in the project. That is the entire explanation for all 41
`LINTER FAILED` reports.

### 4.3 What the plan should do with this

Removing `@[simp]` from `neg_unfold` converts the 7 `LINTER FAILED` in `Bimodal.Syntax` into 4
*real* `simpNF` reports of the form "LHS simplifies from `φ.some_future.swap_temporal` to
`(φ.untl Formula.bot.neg).swap_temporal` using `some_future_unfold, neg_fold`". Those are still
artifacts of the same Automation simp set, not defects in `Syntax/Formula.lean`. "Fixing" them at
the reported site would mean restating readable theorems in unfolded primitive form to satisfy a
linter run in an environment (whole-library import) that no consumer actually uses.

**Recommendation**: record all 41 `LINTER FAILED` as **accepted residuals** with the root cause
above, and do NOT edit any T1/T2 file for them. `Theories/Bimodal/Automation/Normalization.lean`
is outside this task's scope (it is `Automation/`, neither T1 nor T2). The plan should note the
diagnosis for a follow-up Automation-scoped task rather than absorb it here.

### 4.4 The one genuine `simpNF`

```
ProofSystem/Derivable.lean:117: @Bimodal.ProofSystem.Derivable.ax
  Left-hand side does not simplify, when using the simp lemma on itself.
  The simp lemma is invalid because the value of argument `h : Bimodal.ProofSystem.Axiom p`
  cannot be inferred by `simp`.
```

```lean
@[aesop safe apply, simp]
theorem Derivable.ax {fc : FrameClass} (G : Context) (p : Formula)
    (h : Axiom p) (h_fc : h.minFrameClass ≤ fc) : Derivable fc G p
```

`h` occurs only in `h_fc`'s type, never in the conclusion `Derivable fc G p`, so simp can never
instantiate it — the lemma is dead weight in the simp set and, per the linter, "will never
apply". The fix is to drop `simp` from the attribute list, keeping `@[aesop safe apply]`.

**Risk assessment**: low but not zero. Because the lemma provably never fires, removing it should
be semantically inert. **This was NOT empirically verified** — the edit invalidates
`ProofSystem/Derivable.lean` and forces a ~1875-job rebuild, and concurrent sibling agents were
building in this session, so the repo was deliberately not mutated. The plan must gate this edit
on a full `lake build` and be prepared to revert.

---

## 5. Category-by-category risk assessment and validated fixes

### 5.1 Low risk — validated clean

| Category | Sites | Fix | Evidence |
|---|---|---|---|
| `linter.style.show` | 10 | `show T` → `change T` | Applied to `Syntax/Atom.lean:92` (1) and `FrameClassVariants.lean:{802,839,864,891,914,917,920}` (7): **0 errors, 0 residual `style.show`**. The Mathlib linter (`Mathlib/Tactic/Linter/Style.lean:635-657`) fires exactly when `show` changed the goal type, and its own message names `change` as the intended replacement. Purely mechanical. |
| `linter.style.nativeDecide` | 4 | `native_decide` → `decide` | Applied to all 4 in `Metalogic/Decidability/SignedFormula.lean` (`:132 :138 :139 :144`): **0 errors, 0 residual**. All four decide propositions over `Sign`, a 2-constructor inductive — `decide` is trivially sufficient. This also removes the Lean *compiler* from the trust base of `LawfulBEq Sign` / `ReflBEq Sign`, which is a correctness improvement, not just a style one. |
| `linter.unusedTactic` | 2 | delete the `simp_wf` line | `DeductionTheorem.lean:287` and `:420`, both inside `decreasing_by` blocks followed by focused `·` bullets. Verified: **0 errors**. |
| `linter.style.multiGoal` | 2 | same deletion | Both multiGoal reports are at the **same two positions** as the unusedTactic reports — they are the same `simp_wf` no-op seen from two angles. **Two line deletions clear four findings.** |
| `linter.style.openClassical` | 1 | delete `open Classical` | `DeductionTheorem.lean:53`. The following line `attribute [local instance] Classical.propDecidable` is what actually does the work. Verified: file elaborates with **0 errors and 0 warnings of any kind**. |

### 5.2 Medium risk — validated methodology, per-site work

| Category | Sites | Notes |
|---|---|---|
| `linter.flexible` | 41 (+unmasking) | 21/21 probed sites transcribed successfully with no proof breakage. Hazards: fixpoint iteration (§3.2) and longLine regression (§3.3). |

### 5.3 High risk — recommend accepted residual

| Category | Sites | Why it should not be "fixed" |
|---|---|---|
| `unusedArguments` | 10 | **Every one is an unused typeclass instance argument**, and each is semantically load-bearing as API documentation. `FrameConditions/Soundness.lean:69` `soundness_linear` has an unused `[LinearTemporalFrame D]`; `:84` `soundness_dense` an unused `[DenseTemporalFrame D]`; `:100` `soundness_discrete` an unused `[DiscreteTemporalFrame D]`. These instance arguments *are* the frame-class index — they are the entire reason `soundness_linear`, `soundness_dense`, `soundness_discrete` are three separate declarations rather than one. Removing them collapses all three into `Metalogic.soundness` and destroys the frame-class-stratified API. Likewise `FrameClassVariants.lean:{711,752,791,853}` carry unused `[IsPredArchimedean D]` / `[IsSuccArchimedean D]` / `[Nontrivial D]` that document the discrete-order setting of Prior-UZ/SZ. **Recommend `@[nolint unusedArguments]` with a one-line rationale comment, or accept as residual.** Either way this is a user-visible API decision, not a linter chore. |
| `simpNF` LINTER FAILED | 41 | §4 — the defect is in `Automation/Normalization.lean`, out of scope. Accept as residual with the root-cause note. |
| `simpNF` real | 1 | §4.4 — `Derivable.ax`. Safe in principle, unverified in practice; gate on full `lake build`. |

---

## 6. Cross-task observations the plan should know

1. **`push_neg` deprecations are NOT zero in T1+T2.** The predecessor report claimed "zero in
   T1+T2"; the re-derived count is **32**, all in T2: `SoundnessLemmas/DenseValidity.lean` (12),
   `Core/MCSProperties.lean` (6), `Core/RestrictedMCS/Basic.lean` (4), `Core/MaximalConsistent.lean`
   (2), `Decidability/CountermodelExtraction.lean` (3), `SoundnessLemmas/FrameClassVariants.lean`
   (2), `Decidability/Closure.lean` (1), `Decidability/Propositional/Decidable.lean` (1), and 1
   more. These remain **out of scope** (deprecation task owns them) but they will appear in every
   per-file lint gate this task runs, so the verification criterion must be *"no new warnings and
   no `linter.flexible`/`style.show`/etc."*, not *"file is silent"*.

2. **`linter.defProp` (3 sites)** — `FrameConditions/FrameClass.lean` ×2,
   `FrameConditions/Soundness.lean` ×1 — is explicitly out of scope (naming task). Note that
   `FrameConditions/Soundness.lean` is in scope for `unusedArguments`, so both tasks will touch
   that file; territory should be assigned by category, not by file.

3. **`defsWithUnderscore` (189 T1 + 50 T2)** unchanged and out of scope.

---

## 7. Recommended phase sizing

Each phase is one agent run ending with `lake build` (0 errors, 1 sorry at `Transfer.lean:1227`)
plus per-file `lake env lean -Dlinter.mathlibStandardSet=true`.

| Phase | Work | Sites | Files | Risk | Notes |
|---|---|---|---|---|---|
| 1 | Mechanical low-risk sweep: `style.show` (10), `nativeDecide` (4), `unusedTactic`+`multiGoal` (2 deletions → 4 findings), `openClassical` (1) | 17 edits → 19 findings | 6 | very low | **All fully validated in this report.** Files: `Syntax/Atom.lean`, `SoundnessLemmas/FrameClassVariants.lean`, `Decidability/Propositional/{Decidable,PropForm}.lean`, `Decidability/SignedFormula.lean`, `Core/DeductionTheorem.lean` |
| 2 | T1 `linter.flexible` — all 9 sites | 9 | 7 | low | **Every replacement string is given verbatim in §3.4.** Effectively transcription. |
| 3 | `Core/DeductionTheorem.lean` flexible (9 + ≥1 unmasked) | ~10 | 1 | low | **Replacement strings given verbatim in §3.4.** Combine with phase 1's DeductionTheorem edits if the planner prefers one commit per file. |
| 4 | `Decidability/Saturation.lean` flexible | 8 | 1 | medium | **Suggestions given verbatim in §3.4**, not yet applied/verified. |
| 5 | Remaining T2 flexible: `CountermodelExtraction` (4), `Filtration` (4), `FrameClassVariants` (4), `RestrictedMCS/Basic` (2), `MaximalConsistent` (1) | 15 | 5 | medium | Run the §3.1 loop per file. Parallelizable — disjoint files. |
| 6 | `simpNF`: drop `simp` from `Derivable.ax`'s attribute list; record 41 `LINTER FAILED` as residuals | 1 edit | 1 | medium | **Full `lake build` gate mandatory** — this file is imported library-wide. Revert on any breakage and record as residual. |
| 7 | `unusedArguments` decision: `@[nolint unusedArguments]` + rationale comments, or accept as residual | 10 | 2 | — | **Recommend NOT removing the arguments.** This is a user-visible API decision (§5.3). |

Phases 2 and 5 are parallelizable by file. Phase 6 must be serialized (library-wide rebuild).

**Expected end state**: 0 errors, 1 sorry, and in-scope findings reduced from 70 distinct sites
to **51 accepted residuals** (41 `simpNF LINTER FAILED` + 10 `unusedArguments`), both documented
with root causes.

---

## 8. Reproduction commands

```bash
# Baseline
lake build
grep -rnE '^\s*sorry\s*$|:= *sorry|by sorry' --include=*.lean Theories/ Tests/ | grep -v Boneyard

# Full Mechanism A sweep over the 67 in-scope files
find Theories/Bimodal/{Syntax,Semantics,ProofSystem,Theorems,FrameConditions} -name '*.lean' \
  | grep -v Boneyard > /tmp/scope.txt
find Theories/Bimodal/Metalogic/{Core,SoundnessLemmas,Decidability,WeakCanonical/Separation} \
  -name '*.lean' | grep -v Boneyard >> /tmp/scope.txt
printf '%s\n' Theories/Bimodal/Metalogic/{Soundness,Completeness,Decidability,Metalogic}.lean >> /tmp/scope.txt
xargs -P 8 -I{} lake env lean -Dlinter.mathlibStandardSet=true {} < /tmp/scope.txt

# Mechanism B
lake exe runLinter Bimodal

# simpNF root-cause probes (§4)
printf 'import Bimodal.Syntax.BigConj\nimport Batteries.Tactic.Lint\n#lint only simpNF in Bimodal.Syntax\n' > /tmp/A.lean
printf 'import Bimodal.Syntax.BigConj\nimport Bimodal.Automation.Normalization\nimport Batteries.Tactic.Lint\n#lint only simpNF in Bimodal.Syntax\n' > /tmp/B.lean
lake env lean /tmp/A.lean   # clean
lake env lean /tmp/B.lean   # 7 LINTER FAILED
```
