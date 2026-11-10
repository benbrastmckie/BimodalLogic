# Implementation Plan: Task #895

- **Task**: 895 - The Auxiliary-Atoms rule for L⁺ at ZTime, forward and mirror, formula level with soundness
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 894 [COMPLETED], Task 915 [COMPLETED] — both landed, both load-bearing
- **Research Inputs**: specs/895_auxiliary_atoms_rule_soundness_ztime/reports/01_auxiliary-atoms-rule-soundness.md
- **Artifacts**: plans/01_auxiliary-atoms-rule-soundness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

State the transposed Reynolds-2001 Auxiliary-Atoms rule at the L⁺ formula level in a new module
`FormalSystem/Metalogic/AuxiliaryAtoms.lean`, and prove it validity-preserving at
`FrameClass.ZTime` by running the premise on the cone unravelling of the given frame under a
machine-run valuation, forgetting the auxiliary atoms by a family freshness congruence, and
projecting along the two-way bounded morphism. Three headline theorems land: `aa_sound_int` at
`PlusValidInt`, `aa_sound_ztime` by carrier normalization, and `aa_reflectTime_sound_ztime` as
the mirror by reflection. No completeness, derivability, or axiomatizability claim is made.
Definition of done: all three headlines sorry-free, the full project and test library green with
zero warnings, axiom profiles pinned in a new evidence module, and the repository gate set run.

### Research Integration

The research report establishes that the route is **compiled, not argued**: all seven semantic
ingredients beyond landed library theorems are checked sorry-free in
`specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean` (`lake env lean` exit 0, zero
diagnostics). This plan is therefore an assembly plan. The findings it consumes directly:

- **Statement level is `PlusValidInt`, not a class-generic `PlusValidIn fc`** — `coneFrame F`
  exists only over `intOrder`, and `PlusValidInt`'s binder bundle
  (`(F : FrameOver intOrder) [F.IsRegular]`) is exactly what `coneFrame` demands, so the premise
  instantiates at the cone with no plumbing. `PlusValidZTime` follows by
  `plusValidZTime_iff_plusValidInt`; the mirror follows by `plusValidIn_reflectTime_iff`. This
  reuses the landed `lcN_plusValidInt` → `lcN_plusValidZTime` → `lcN_reflectTime_plusValidZTime`
  ladder verbatim.
- **`exists_coneUnravelling` must not be used** — it quantifies the carrier away, and the proof
  must define a valuation *on that carrier*. The concrete layer (`coneFrame`, `coneF`,
  `coneF_twoWayBounded`, `coneF_surjective`, `coneFrame_isRegular`) plus a direct call to
  `TwoWayBounded.plus_invariance_of_isZTime` is the route.
- **State-locality is same-time only, which looks like a design gap and is not** — the machine's
  input function must be `idx : F.WorldState → ℕ`, a function of the state alone, while
  `IsPlusStateLocal` fixes the time on both sides. The composition of `plusStateLocal_stab_iff`
  with `stab_state_only` *is* the different-times statement. This is the finding most likely to
  be missed by an implementer reading `StateLocal` alone.
- **Three library gaps, each probe-checked with a sibling-language precedent**: no `next_iff` at
  `PlusTruthAt`, no family form of `plusTruthAt_congr_of_fresh`, no different-times corollary of
  state-locality. All three land in the new module (Phase 1), each recording its own promotion
  rationale at the declaration.
- **`HistMap.lift` is the anchoring device and is already a field** — instantiated at
  `.inr (τ.state x, [])`, where `coneF (.inr (w, [])) = w` holds by `rfl`. No history
  construction and no onto-histories argument is needed.
- **`omega` fails on `↑intOrder`** ("no usable constraints"), so the archived probe's offset
  extraction does not transfer; `Int.toNat_of_nonneg` + `sub_nonneg` + `abel` replaces it.

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only (no `roadmap_path` was passed on this dispatch;
the file exists and was read directly). This task is the **formula-level rule, gated on 894**,
the middle member of the filed trio 894 (the cone carrier) → 895 (this task) → 896 (the extended
system), itself part of Stage 2's `P2 → P3 → P4` walk of 879's ingredient table. The roadmap
also records (item 903) that the Auxiliary-Atoms rule **carries no acceptance condition**, which
is why a deterministic Muller automaton suffices for it — consistent with this task's scope being
one soundness fact and nothing automata-theoretic. No roadmap item is edited by this plan;
ROADMAP.md is not in any phase's file list.

## Goals & Non-Goals

**Goals**:
- `plusTruthAt_next_iff_succ`, `plusTruthAt_next_iff_add_one` -- the missing L⁺ truth clause for
  `X`, over a successor order and at `intOrder` respectively.
- `plusTruthAt_stateLocal_state_only` -- a state-local formula's truth depends on the world state
  alone, at possibly different times.
- `plusTruthAt_congr_of_fresh_family` -- the finite-family form of
  `NamingRules.plusTruthAt_congr_of_fresh`, reusing `NamingRules.Fresh` itself.
- `aaStep`, `aaExcl`, `aaAnte` -- the rule's antecedent as L⁺ formulas: the machine-step clause,
  the exclusivity clause, and their assembly under `⊡G≤`.
- `aa_sound_int` -- **the headline**: the Auxiliary-Atoms rule is validity-preserving over every
  regular frame over `intOrder`.
- `aa_sound_ztime` -- the same rule at `FrameClass.ZTime`, by carrier normalization.
- `aa_reflectTime_sound_ztime` -- the mirror rule at `FrameClass.ZTime`, by reflection, with its
  side conditions stated on the unreflected data.

**Non-Goals**:
- Any completeness, decidability, or axiomatizability claim. This is a soundness fact about one
  rule, as the task states.
- Any derivability (proof-system) form of the rule. Nothing is added to `ProofSystem/`.
- Expanding the mirror rule in syntax. See Decisions — the `lcN_reflectTime_plusValidZTime`
  precedent declines exactly this, and a mirrored cone is likewise not built.
- Using `Semantics.exists_coneUnravelling`. The existential headline cannot be the entry point
  here; nothing in `ConeUnravelling.lean` is changed or re-proved.
- Promoting the three infrastructure lemmas out of this module into `PlusLanguage/`. Two of them
  are promotion *candidates* and the rationale is recorded at the declaration, but promotion
  would add import edges for declarations no current client consumes.
- Strengthening the `aᵢ` partition conditions to Reynolds' "substitution instance of a classical
  tautology". Semantic validity is taken instead, which is weaker and yields a more general rule.
- Any new axiom and any `sorry`. Zero-debt; none is proposed anywhere in this plan.

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| 1 | `omega` cannot see arithmetic over `↑intOrder` ("no usable constraints"), so the archived probe's `⟨(s-t).toNat, by omega⟩` offset extraction does not transfer | H | H (already observed twice: task 894, and this task's research) | Use `Int.toNat_of_nonneg` + `sub_nonneg` + `abel`, exactly as the probe's `aaState_step` does. Compiled. |
| 2 | `coneFrame_taskRel` does not rewrite a goal phrased with `(coneFrame F).toTaskFrame.TaskRel`, as `WorldHistory.respects_task` gives it | M | H | State an intermediate `have` at `FrameOver.TaskRel` first; `toTaskFrame` is `@[reducible]` so it typechecks. Compiled in probe (C). |
| 3 | `IsPlusStateLocal` is same-time only, so `aaIdx` looks ill-defined | H | M | Closed by `plusTruthAt_stateLocal_state_only` (Phase 1), which is the different-times statement. Phase 4 consumes it explicitly rather than re-deriving it. |
| 4 | Axiom profile rises (`Classical.choice`, from `aaIdx`'s `dite`) | L | H | `Classical.choice` is already in the cone modules' measured ceiling `[propext, Classical.choice, Quot.sound]`. **Measure** and pin in the new evidence module; never type a profile from memory. |
| 5 | Style/linter gates on new code (`linter.style.show`, unused `simp` arguments); CI builds with `--wfail`, so a warning is a failure | M | M | Both were hit and fixed inside the probe (`change` instead of `show`), which now compiles with zero diagnostics, so transcribed code starts clean. |
| 6 | Sibling tasks 910 and 911 are dispatched this same cycle on this shared working tree | L | M | Their declared `file_scope` is `Decidability/RaySummary/{LadderCell,LadderPump}.lean`, disjoint from every path in this plan. Phase 6's generated-inventory surfaces (`README.md`, `FormalSystem/Metalogic/README.md`) are the only wide files: re-read each immediately before editing and stage only this task's own hunks, never a directory or glob `git add`. |
| 7 | The deployed `.claude/` tree is stale for five extensions | L | H | No `.claude/**` file is written by this plan. The repository gate scripts cited below were read from `scripts/` (the repository's own, not a deployed copy). |
| 8 | The exclusivity clause's diagonal (`j = j'`) has no formula-level content | L | M | `aaExcl` guards the diagonal with `if j = j' then PlusFormula.top`, so `bigAnd_iff` yields a clean `∀ j < m, ∀ j' < m, ...` that `rcases eq_or_ne` splits. Recorded in Decisions; the convention is stated at the declaration. |

## Lean Challenge Statements

Every block below **type-checks against the live library as written**: it was compiled in this
planning dispatch with `lake env lean`, exit 0, with `declaration uses 'sorry'` as the only
diagnostics. The three `def`s carry real bodies rather than `sorry` — following task 894's own
Challenge block, which did the same for the definitions its theorem statements mention — because
the antecedent's *shape* is itself part of this task's contract and a `sorry` body would discard
it. Every theorem body is `sorry`.

```lean
import FormalSystem.Metalogic.NamingRules
import FormalSystem.Semantics.ConeUnravelling
import FormalSystem.PlusLanguage.PlusStateLocal
import FormalSystem.PlusLanguage.PlusIntTransfer
import FormalSystem.PlusLanguage.PlusLCSchema

namespace FormalSystem.Metalogic.AuxiliaryAtoms

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules

theorem plusTruthAt_next_iff_succ {F : TaskFrame} [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (Order.succ t) φ := sorry

theorem plusTruthAt_next_iff_add_one {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ↑intOrder) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (t + 1) φ := sorry

theorem plusTruthAt_stateLocal_state_only {F : TaskFrame} {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration) (h : τ.state t = σ.state s) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M σ s φ := sorry

theorem plusTruthAt_congr_of_fresh_family {F : TaskFrame} (M M' : TaskModel F) (qa : ℕ → Atom)
    (m : ℕ)
    (hV : ∀ (w : F.WorldState) (r : Atom), (∀ j, j < m → r ≠ qa j) →
      (M.valuation w r ↔ M'.valuation w r)) :
    ∀ φ : PlusFormula, (∀ j, j < m → Fresh (qa j) φ) →
      ∀ (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := sorry

def aaStep (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) : PlusFormula :=
  bigAnd m fun j => bigAnd k fun i =>
    ((PlusFormula.atom (qa j)).and (a i)).imp
      (PlusFormula.stab (PlusFormula.atom (qa (p j i))).next)

def aaExcl (qa : ℕ → Atom) (m : ℕ) : PlusFormula :=
  bigAnd m fun j => bigAnd m fun j' =>
    if j = j' then PlusFormula.top
    else ((PlusFormula.atom (qa j)).and (PlusFormula.atom (qa j'))).neg

def aaAnte (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) :
    PlusFormula :=
  ((PlusFormula.atom (qa b₀)).and (PlusFormula.stab (aaStep qa m k a p).gle)).and
    (PlusFormula.stab (aaExcl qa m).gle)

theorem aa_sound_int (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)
    (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidInt (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidInt (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidInt ((aaAnte qa m k a p b₀).imp φ)) :
    PlusValidInt φ := sorry

theorem aa_sound_ztime (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)
    (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidZTime (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidZTime (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidZTime ((aaAnte qa m k a p b₀).imp φ)) :
    PlusValidZTime φ := sorry

theorem aa_reflectTime_sound_ztime (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
    (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidZTime (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidZTime (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidZTime (((aaAnte qa m k a p b₀).imp φ).reflectTime)) :
    PlusValidZTime φ.reflectTime := sorry

end FormalSystem.Metalogic.AuxiliaryAtoms
```

### What is deliberately not pinned here

`aaRun`, `aaState`, `aaState_step`, `coneHist_step`, `coneHist_inr_of_anchor`, `aaModel`,
`aaModel_atom_q`, `aaModel_valuation_off`, `aaIdx` and `plusTruthAt_aaAnte` are internal
machinery, fully specified in the phase tasks below against the compiled probe, and are not
Challenge-pinned. Pinning them would force every internal signature into the contract, where an
implementation-time need for one extra hypothesis on a helper becomes a drift finding rather than
ordinary work. The externally meaningful contract — the antecedent's shape, the three
infrastructure lemmas and the three headlines — is what the block above fixes.

## Decisions

- **Statement level `PlusValidInt`, not a class-generic `PlusValidIn fc`.** Forced: the cone
  construction exists only over `intOrder`. Recorded so a reader does not read the narrowing
  (against `clock_irr_sound`'s class-generic signature) as sloppiness.
- **Concrete cone API, not `exists_coneUnravelling`.** Forced by the need to define a valuation
  on the carrier.
- **`ℕ`-indexed bounded families for `Q`, the `aᵢ` and the machine**, not `Fin`/`Finset`. Chosen
  to match `bigAnd`'s own indexing and `lcN`'s style; the alternative buys nothing and costs
  conversion lemmas at every `bigAnd_iff` site.
- **The `aᵢ` partition conditions enter as semantic validity hypotheses.** Weaker than Reynolds'
  "substitution instance of a classical tautology", hence a *more general* rule. Stated at the
  declaration as a deliberate deviation from the source, not a silent one.
- **Exhaustiveness is stated as `PlusValidInt (bigAnd k (fun i => (a i).neg)).neg`**, not via a
  `bigOr`. The research confirmed no `bigOr` exists in the tree; the double-negated conjunction of
  negations says exactly "not all `aᵢ` false" and reuses the landed `bigAnd_iff`. Introducing a
  `bigOr` for one use site was rejected as a wider change than the rule needs.
- **The exclusivity clause's diagonal is guarded by `if j = j' then PlusFormula.top`.** `bigAnd`
  is single-level and `ℕ`-indexed, so the pairwise conjunction is a nested `bigAnd` over the full
  square; the diagonal carries `top` rather than the unsatisfiable `¬(q ∧ q)`. Decidable equality
  on `ℕ` means no classical choice enters here.
- **`NamingRules.Fresh` is reused, not re-defined.** Only the congruence theorem is generalized,
  so the tree keeps one notion of freshness.
- **One new module plus a prose-only change to `NamingRules.lean`.** Putting the rule in
  `NamingRules.lean` would add four imports for declarations none of its current clients consume.
  The prose change adds no import, so `check-metalogic-cycles.sh`'s Assertion B sees no new
  upward edge.
- **Mirror rule: stated, not expanded in syntax.** Expanding it would require an `H≤` definition
  (neither `Formula` nor `PlusFormula` carries a reflexive *past* closure), a `reflect_time_gle`
  push-through and a `reflect_time_bigAnd` — the three declarations
  `lcN_reflectTime_plusValidZTime`'s own doc comment names and declines. Follow that precedent and
  record it at the declaration. A mirrored cone is likewise not built.
- **The mirror's side conditions are stated on the unreflected data**, so that no
  `Fresh`-vs-`reflectTime` commutation lemma is needed.
- **Partition hypotheses are stated at `PlusValidInt` in `aa_sound_int` and at `PlusValidZTime` in
  the two ZTime theorems**, converted by `plusValidZTime_iff_plusValidInt`. Mixing levels within
  one signature was rejected as harder to read than two `.mp` applications.
- **The three infrastructure lemmas stay local to this module.** Two are promotion candidates
  (`plusTruthAt_next_iff_succ` to `PlusLanguage/PlusTruth.lean`,
  `plusTruthAt_stateLocal_state_only` to `PlusLanguage/PlusStateLocal.lean`); the promotion
  rationale is recorded at each declaration, following the `base_taskRel_eq_ofStepRel` precedent,
  rather than executed here.
- **The evidence probe is tracked but not `WIRED`.** It lives at
  `specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean` (already committed).
  Task 894 declined a `WIRED` entry for its own probe; an unlisted file there is unguarded rather
  than a gate failure.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential by
construction: every phase from 1 to 5 writes into the same new module, so no two can be
dispatched concurrently regardless of their logical dependencies. Phase 3's only *logical*
dependency is Phase 1 (it consumes `plusTruthAt_next_iff_add_one`, not Phase 2's machine), and
Phase 2's is Phase 1's module skeleton alone; the chain records the file-level serialization, not
a deeper logical order.

---

### Phase 1: Module skeleton and the three infrastructure lemmas [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/AuxiliaryAtoms.lean` with its header, module docstring
and registration, and land the three probe-checked library gaps.

**Tasks**:
- [ ] Create the module with the four-line Apache copyright header in the repository's exact shape
      (`scripts/check-copyright-headers.sh` is the gate), the five imports from the Challenge
      block, and `namespace FormalSystem.Metalogic.AuxiliaryAtoms` with the two `open` lines.
- [ ] Write the module docstring with the repository's section set: a narrative opening, `## Main
      Definitions`, `## Main Results`, `## Not formalized` (no completeness, decidability or
      axiomatizability claim), `## References` and `## Tags`. Cite Reynolds 2001 §7
      (Definition 4, Lemma 6) by section only and §4.7 Lemma 3 for the unravelling remark — quote
      no OCR'd formula verbatim, the display OCR is degraded (`⋀` renders as `A`, `θ` as `0`).
- [ ] Transcribe `plusTruthAt_next_iff_succ` from probe (B) — `rw [PlusFormula.next,
      PlusTruth.untl_iff]` then `rcases lt_or_eq_of_le (Order.succ_le_of_lt hts)`. Record at the
      declaration that this is the twin of `SourceLanguage/SentenceTruth.lean`'s and
      `NomicLanguage/NomicTruth.lean`'s `next_iff_succ`, that `PlusLanguage/PlusTruth.lean` lacks
      it, and that promotion there is the eventual home (not done here).
- [ ] Transcribe `plusTruthAt_next_iff_add_one` from probe (B') — one `rw` through
      `Order.succ_eq_add_one`, which synthesizes over `↑intOrder`.
- [ ] Transcribe `plusTruthAt_stateLocal_state_only` from probe (A) — a term-mode `Iff.trans`
      chain through `plusStateLocal_stab_iff` and `stab_state_only`, no tactic needed. Record at
      the declaration that `PlusStateLocal.lean`'s docstring says the different-times shape "does
      **not** generalize to this fragment" — true of `box φ`, and this composition is the case
      where it does hold for a `StateLocal φ` — and that `PlusStateLocal.lean` is the promotion
      candidate.
- [ ] Transcribe `plusTruthAt_congr_of_fresh_family` from probe (E) — the seven-case induction
      with `hV`'s side condition read as `∀ j < m, r ≠ qa j`, using `imp_congr`,
      `forall_congr'`, `exists_congr`, `and_congr_right`, `imp_congr_right`. Cross-reference the
      single-atom `NamingRules.plusTruthAt_congr_of_fresh` at the declaration.
- [ ] Place a `Paper:` line on each of the four public declarations
      (`Paper: — (formalization-native; …)` for the three that have no manuscript counterpart);
      `scripts/check-paper-definitions.sh` and `check-module-invariants.sh`'s C15 read these.
- [ ] Add `import FormalSystem.Metalogic.AuxiliaryAtoms` to `FormalSystem/Metalogic.lean` (C8,
      aggregator convention).
- [ ] Run `lake exe mk_all --lib FormalSystem` and stage the regenerated `FormalSystem.lean`
      (C33, byte-currency).
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` in the
      same commit as the Lean lines — `.githooks/pre-commit` enforces the line-count field.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts four declarations (`plusTruthAt_next_iff_succ`,
`plusTruthAt_next_iff_add_one`, `plusTruthAt_stateLocal_state_only`,
`plusTruthAt_congr_of_fresh_family`) transcribe from the probe's `Probe895` namespace without
proof change, at roughly 160 lines including the module docstring. Both figures are **carried
from** `reports/01_auxiliary-atoms-rule-soundness.md` (its "~90 lines" estimate for the three
gaps, re-apportioned here to include the fourth lemma and the docstring). Confirm by diffing each
transcribed body against `specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean`
before compiling; if any body needs a change, record which and why in the progress file rather
than silently editing.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` — no shell suite maps any of them — so the covering check is the `local` row's
own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms`,
which is the only thing that can observe a break confined to one brand-new module no other module
imports yet.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - created: copyright header, module docstring, four infrastructure declarations
- `FormalSystem/Metalogic.lean` - CORRECTION TARGET, confirmed present at authoring time (its import block ends with `import FormalSystem.Metalogic.NamingRules`): one new import line appended to that block. If the block's shape has changed, append in whatever alphabetical or trailing position the file then uses and record the placement
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` to import the new module
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`; blocking surface, cannot be deferred

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms` is green with zero warnings (CI builds with `--wfail`, so a lint warning is a failure).
- `grep -c 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean` is 0.
- `bash scripts/check-copyright-headers.sh` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0, so the phase's own commit is not refused by `.githooks/pre-commit`.
- Each transcribed statement matches the probe's character-for-character, as diffed in the task above.

---

### Phase 2: Cone-history lemmas and the machine run [COMPLETED]

**Goal**: Land the two cone-history facts and the machine-labelling definitions, ending with
`aaState_step` — the semantic core of the antecedent.

**Tasks**:
- [ ] Transcribe `coneHist_step` from probe (C): state the intermediate
      `have h0 : (coneFrame F).TaskRel (τ'.state s) 1 (τ'.state (s + 1))` **at
      `FrameOver.TaskRel`** before rewriting with `coneFrame_taskRel`, because that theorem does
      not rewrite a goal phrased with `(coneFrame F).toTaskFrame.TaskRel` as
      `WorldHistory.respects_task` gives it. Use `abel` for `s + 1 - s = 1`, never `omega`.
- [ ] Transcribe `coneHist_inr_of_anchor` from probe (D): the `hin` induction over genuine world
      histories, strengthened with the recorded list's length, using `push_cast`/`abel` for
      `t + ((n + 1 : ℕ) : ℤ) = t + (n : ℤ) + 1`.
- [ ] Transcribe `aaRun` and `aaState` from probe (F) as `def`s, with their doc comments. Both
      are lowerCamelCase, so C26-clean. Record at `aaRun` that the recorded list is most-recent-
      first, which is the orientation `coneRin` produces.
- [ ] Transcribe `aaState_step` from probe (G). Its offset extraction is
      `⟨(s - t).toNat, …⟩` discharged by `Int.toNat_of_nonneg` + `sub_nonneg` + `abel`; the final
      restatement uses `change`, **not** `show` (`linter.style.show` rejects a goal-changing
      `show`). Record at the declaration that this is the archived probe's `aa_expand` restated
      over `WorldHistory (coneFrame F)`, citing
      `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` Part J as the Mathlib-only
      ancestor.
- [ ] Place `Paper:` lines on the public declarations and extend the docstring's `## Main
      Definitions` / `## Main Results` lists.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts four declarations (`coneHist_step`,
`coneHist_inr_of_anchor`, `aaRun`, `aaState`) plus `aaState_step` transcribe from the probe
without proof change, at roughly 130 lines — the figure carried from the research report's
"~120 lines" estimate for its Phase 2. Confirm by diffing each body against the probe before
compiling, and record any body that needs a change.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` — no shell suite maps either of them — so the covering check is the `local`
row's own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms`,
which is the only thing that can observe a break confined to this one module, which nothing yet
imports.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - the two cone-history lemmas plus aaRun, aaState and aaState_step, and docstring list entries
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean` is 0.
- `grep -n 'omega' FormalSystem/Metalogic/AuxiliaryAtoms.lean` returns no hit inside either
  duration-arithmetic proof — the `↑intOrder` obstruction means a passing `omega` there would be
  a surprise worth investigating, not a convenience.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 3: The antecedent as L⁺ syntax [COMPLETED]

**Goal**: Define `aaStep`, `aaExcl` and `aaAnte` exactly as pinned in `## Lean Challenge
Statements`, and prove the three unpacking lemmas that read each conjunct back out of a truth
assumption.

**Tasks**:
- [ ] Define `aaStep`, `aaExcl`, `aaAnte` verbatim from the Challenge block. Do not alter the
      shape: the exclusivity conjunct sits under `⊡G≤` and the step clause carries `⊡X` (not a
      bare `X`), which is Definition 4's structure clause for clause.
- [ ] Doc-comment each: `aaStep` as `⋀_{j<m} ⋀_{i<k} ((q_j ∧ aᵢ) → ⊡X q_{p j i})`, `aaExcl` with
      the `top`-on-the-diagonal convention stated explicitly, `aaAnte` naming the three conjuncts
      and the Reynolds §7 `θ` they transpose.
- [ ] Prove `plusTruthAt_aaAnte_initial` — from `PlusTruthAt M τ x (aaAnte …)`, the atom `qa b₀`
      holds at `(τ, x)`. One `PlusTruth.and_iff` unpacking.
- [ ] Prove `plusTruthAt_aaAnte_step` — from the same assumption, for every history `σ` through
      `τ.state x` at `x`, every `s ≥ x`, every `j < m` and `i < k`: if `qa j` and `a i` hold at
      `(σ, s)` then `qa (p j i)` holds at `(σ, s + 1)` on every history through `σ.state s`.
      Route: `PlusTruth.and_iff` → `PlusTruth.stab_iff` → `gle_iff` → `bigAnd_iff` twice →
      `PlusTruth.imp_iff`/`and_iff` → `PlusTruth.stab_iff` → `plusTruthAt_next_iff_add_one`.
- [ ] Prove `plusTruthAt_aaAnte_excl` — from the same assumption, for every history `σ` through
      `τ.state x` at `x`, every `s ≥ x` and every `j ≠ j'` both `< m`: not both `qa j` and
      `qa j'` hold at `(σ, s)`. Route: the same ladder, then `rcases eq_or_ne j j'` to discharge
      the `top` diagonal.
- [ ] Place `Paper:` lines and extend the docstring lists.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts three definitions and three unpacking lemmas at roughly
120 lines — the figure carried from the research report's "Phase 3" item, which named the three
`def`s "with their three truth-characterization lemmas" without a line estimate, so the 120 is
this plan's own apportionment of its ~600-750-line total. Confirm at implementation time by
measuring the phase's added lines; the three `def`s are pinned statements and cannot shrink, so a
large overrun means the unpacking lemmas need their own sub-lemmas, which is a decomposition
finding to record rather than a silent widening.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` — no shell suite maps either of them — so the covering check is the `local`
row's own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms`,
which is the only thing that can observe a break confined to this still-unimported module.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - the three antecedent definitions aaStep, aaExcl and aaAnte plus their three unpacking lemmas
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean` is 0.
- `aaStep`, `aaExcl` and `aaAnte` are character-for-character the Challenge block's definitions,
  as diffed against `## Lean Challenge Statements` in this file.

---

### Phase 4: The auxiliary-atom model and the machine's input function [NOT STARTED]

**Goal**: Land `aaModel` with its two reading lemmas, and `aaIdx` with the well-definedness facts
that make it the right input to the machine.

**Tasks**:
- [ ] Transcribe `aaModel` and its two reading lemmas (`aaModel_atom_q`,
      `aaModel_valuation_off`) from probe (F). Record at `aaModel_atom_q` that the
      injectivity-below-`m` hypothesis is load-bearing.
- [ ] Define `aaIdx F M a k : F.WorldState → ℕ` as a `noncomputable def` by
      `dite` on `∃ i, i < k ∧ ∃ (τ : WorldHistory F.toTaskFrame) (t : ℤ), τ.state t = w ∧
      PlusTruthAt M τ t (a i)`, taking `h.choose` in the real branch and `0` otherwise. Record at
      the declaration that `Classical.choice` enters here and nowhere else, and that the `0`
      fallback is never consulted at an occurring state.
- [ ] Prove `aaIdx_lt` — `aaIdx … w < k` whenever the `dite` takes its real branch — and
      `aaIdx_spec`: if `a i` holds at `(M, τ, t)` with `τ.state t = w` and `i < k`, then
      `aaIdx … w = i`. `aaIdx_spec` is where the two partition hypotheses are consumed: the
      `dite`'s real branch is reached by `hexh` (exhaustiveness at the occurring point) and the
      chosen index is forced to be `i` by `hdisj` (pairwise inconsistency), with
      `plusTruthAt_stateLocal_state_only` transporting `a i`'s truth from the chosen witness
      history to `(τ, t)`. **This step is the one with real content in this phase** — it is the
      closure of the same-time/different-times gap, and it must cite
      `plusTruthAt_stateLocal_state_only` rather than `IsPlusStateLocal` directly.
- [ ] Prove `aaIdx_of_occurring` — at any `w` of the form `τ.state t`, the `dite` takes its real
      branch — so that no global "history through a state" existence lemma is needed. The tree
      has none, and the proof must not assume one.
- [ ] Place `Paper:` lines and extend the docstring lists.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts three transcribed declarations plus one new `def` and
three new lemmas, at roughly 140 lines — this plan's own apportionment, not a figure carried from
the research report (whose Phase 4 bundled `aaModel`, `aaIdx` and `plusTruthAt_aaAnte` together
with no line estimate). Confirm by measuring the phase's added lines; `aaIdx_spec` is the
plausible overrun, and if it needs its own helper lemmas that is a decomposition finding to
record in the progress file.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` — no shell suite maps either of them — so the covering check is the `local`
row's own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms`,
which is the only thing that can observe a break confined to this still-unimported module.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - aaModel with its two reading lemmas, and aaIdx with its three well-definedness lemmas
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean` is 0.
- `aaIdx` compiles as a `noncomputable def` whose stated hypotheses are each consumed — it is not
  a `Decidable`-valued declaration, so `lean4.md`'s noncomputable-`Decidable` vacuity test does
  not apply, but confirm by deleting no hypothesis: `aaIdx_spec` fails without both `hexh` and
  `hdisj`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: The antecedent holds at the constructed model [NOT STARTED]

**Goal**: Prove `plusTruthAt_aaAnte` — the auxiliary-atom model satisfies the whole antecedent on
every history of the cone anchored at an `inr` empty-record node.

**Tasks**:
- [ ] State `plusTruthAt_aaAnte` over `(F : FrameOver intOrder) [F.IsRegular]`, the base model
      `M`, the data `qa m k a p b₀`, the valuation
      `aaModel F M qa m (aaState p b₀ (aaIdx F M a k) ∘ …)` as Phase 4 built it, a cone history
      `τ'` with `τ'.state x = .inr (w, [])`, and the two partition hypotheses plus injectivity.
      The conclusion is `PlusTruthAt (aaModel …) τ' x (aaAnte qa m k a p b₀)`.
- [ ] Discharge the initial conjunct: `aaModel_atom_q` plus `aaState (.inr (w, [])) = aaRun … []
      = b₀`, which is `rfl`.
- [ ] Discharge the exclusivity conjunct: `PlusTruth.stab_iff` → `gle_iff` → `bigAnd_iff` twice,
      then `aaModel_atom_q` at both indices — two machine states at one node forces `j = j'` by
      functionality of `aaState`, and the diagonal is `top`.
- [ ] Discharge the step conjunct, **the only branch with work in it**: at a cone node `z` where
      `qa j` and `a i` both hold, transfer `a i`'s truth to the base model by
      `aaModel_valuation_off` and `plusTruthAt_congr_of_fresh_family` (using `hfreshA`), then by
      `TwoWayBounded.plus_invariance_of_isZTime`'s truth equivalence; apply `aaIdx_spec` to force
      `i = aaIdx … (coneF z)`, which is the index `aaState` actually stepped on; then close with
      `aaState_step` and `plusTruthAt_next_iff_add_one`. `aaModel_atom_q` reads the resulting
      machine state back as `qa (p j i)`.
- [ ] Place a `Paper:` line and extend the docstring's `## Main Results` list.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts one theorem with three conjunct branches at roughly 160
lines — this plan's own apportionment, not a research-report figure. The research names this step
as "the only one with work in it", so an overrun here is the expected shape of surprise: if the
step branch needs its own named sub-lemma, add it and record the decomposition in the progress
file rather than inlining a 100-line tactic block.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` — no shell suite maps either of them — so the covering check is the `local`
row's own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms`,
which is the only thing that can observe a break confined to this still-unimported module.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - plusTruthAt_aaAnte and any sub-lemma the step branch needs
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.AuxiliaryAtoms` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean` is 0.
- No branch of the proof invokes a "history through a state" existence lemma — the cone has none,
  and `aaIdx_of_occurring` is what stands in its place.

---

### Phase 6: The three headline theorems, evidence pin, documentation and the full gate set [NOT STARTED]

**Goal**: Land `aa_sound_int`, `aa_sound_ztime` and `aa_reflectTime_sound_ztime`; pin their axiom
profiles as permanent evidence; retire `NamingRules.lean`'s "where it stops" framing; add the
theorem-index rows; regenerate the inventory surfaces; and run the complete gate set.

**Tasks**:
- [ ] Prove `aa_sound_int` at the Challenge-pinned signature, following the research's eight-step
      skeleton: `plus_invariance_of_isZTime (coneF_twoWayBounded F) (coneF_surjective (E := F.step)) M`
      for the morphism; `aaIdx`/`aaState`/`aaModel` for the model; `g.lift τ (.inr (τ.state x, [])) x (by rw [hgf])`
      for the anchored cone history; `plusTruthAt_aaAnte` for the antecedent; `hprem` at
      `coneFrame F` (its `[(coneFrame F).IsRegular]` binder discharged by `coneFrame_isRegular`'s
      instance status); `plusTruthAt_congr_of_fresh_family` with `aaModel_valuation_off` to forget
      the `Q`-atoms; the morphism's truth equivalence to reach the base; and
      `WorldHistory.ext_state` on `g.lift`'s projection equation to turn `g.mapH τ' = τ`.
- [ ] Prove `aa_sound_ztime` at the Challenge-pinned signature: convert each `PlusValidZTime` side
      condition by `(plusValidZTime_iff_plusValidInt _).mp`, apply `aa_sound_int`, and conclude by
      `(plusValidZTime_iff_plusValidInt φ).mpr`.
- [ ] Prove `aa_reflectTime_sound_ztime` at the Challenge-pinned signature:
      `plusValidIn_reflectTime_iff.mp hprem` unreflects the premise (the implication reflects
      componentwise by `rfl`), `aa_sound_ztime` gives `PlusValidZTime φ`, and
      `plusValidIn_reflectTime` reflects the conclusion. Doc-comment it with the
      `lcN_reflectTime_plusValidZTime` precedent: the three declarations an expanded mirror would
      need (`H≤`, `reflect_time_gle`, `reflect_time_bigAnd`) and why none is built.
- [ ] Create `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` on
      `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean`'s pattern: a docstring saying it is
      permanent evidence rather than a conventional test, a "When one of these guards fires"
      paragraph, and `#guard_msgs in #print axioms` blocks for `plusTruthAt_congr_of_fresh_family`,
      `aaState_step`, `plusTruthAt_aaAnte`, `aa_sound_int`, `aa_sound_ztime` and
      `aa_reflectTime_sound_ztime`. Every expected block is **measured** in this dispatch, never
      typed from memory. The expected ceiling is `[propext, Classical.choice, Quot.sound]`
      (`Classical.choice` genuinely consumed, by `aaIdx`) — but record what is measured, not what
      is expected.
- [ ] Add `import BimodalTest.Metalogic.AuxiliaryAtomsTest` to `Tests/BimodalTest.lean`.
- [ ] Amend `FormalSystem/Metalogic/NamingRules.lean`'s module docstring: retire the "and where it
      stops" framing of its `### The Auxiliary-Atoms expansion, and where it stops` section now
      that the rule exists, naming
      `FormalSystem.Metalogic.AuxiliaryAtoms.aa_sound_int`/`aa_sound_ztime`, and add the new
      module to that docstring's `## References` list. Introduce **no import** — prose only, so
      `check-metalogic-cycles.sh`'s Assertion B sees no new upward edge.
- [ ] Add `docs/theorem-index.md` rows for `aa_sound_int`, `aa_sound_ztime` and
      `aa_reflectTime_sound_ztime`, each anchored by the `Paper:` line already placed at its
      declaration and each naming `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` as the
      profile guard.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated
      inventory blocks. Re-read each touched README immediately before staging — tasks 910 and
      911 are live on this tree this cycle — and stage only this task's own hunks.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Run the complete gate set and record its outcome per the criteria below.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts (a) that the regenerated module-inventory surface lands
within the ancestor-chain READMEs listed below and nowhere else, and (b) that
`NamingRules.lean`'s docstring still carries the section heading `### The Auxiliary-Atoms
expansion, and where it stops` and the sentence beginning "That transfer is **not** formalized
here" — both confirmed present at authoring time by reading the file. Confirm (a) by reading the
staged diff after `--emit-inventory` and staging exactly the files it actually rewrote; a
no-change outcome for a `rows=loose` README is expected, not a failure. Confirm (b) by grepping
for both strings before editing.

**Files to modify**:
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - the three headline theorems and their doc comments
- `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` - created: measured `#guard_msgs`-gated `#print axioms` blocks for six declarations
- `Tests/BimodalTest.lean` - add the import of the new evidence module
- `FormalSystem/Metalogic/NamingRules.lean` - CORRECTION TARGET, confirmed present at authoring time: the `### The Auxiliary-Atoms expansion, and where it stops` section heading and its "That transfer is **not** formalized here" sentence. If either string is absent when this phase runs, do not invent a replacement target: grep the docstring for whatever sentence then carries the not-formalized-here claim, amend that, and record the discrepancy in the progress file; if no such claim remains, record the paragraph as already retired and add only the `## References` entry
- `docs/theorem-index.md` - three new rows, each anchored by a `Paper:` line at its declaration
- `README.md` - generated inventory block regenerated by `check-module-invariants.sh --emit-inventory`
- `FormalSystem/README.md` - generated inventory block regenerated by the same run, if that run touches it
- `FormalSystem/Metalogic/README.md` - generated inventory block regenerated by the same run, if that run touches it
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) is green with zero warnings, **and** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` is green — the default target does not include the test library, so the unscoped build alone would not compile the new `#guard_msgs` module.
- `bash .claude/scripts/verify-deploy.sh` — the agent-system deploy gate set — records its outcome. This repository's deployed `.claude/` tree is already stale for the core, lean, literature, memory and typst extensions (see this dispatch's deploy-freshness context), so findings there are pre-existing baseline, not this task's: the criterion is that no finding names a file this task touched. Enumerate any pre-existing findings rather than reporting a bare pass or fail. Check the command's exit status, not only a diff of its stdout.
- The repository's own complete gate set runs, each stated as a touched-file scope or a baseline delta, never an absolute repo-wide zero: `bash scripts/check-module-invariants.sh` (C26, C33, C15 paper-anchor integrity and its theorem-index anchoring assertion, and `FAIL INV` on the inventory blocks), `bash scripts/typst-sync-check.sh`, `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-copyright-headers.sh`, `bash scripts/check-paper-definitions.sh`, `bash scripts/check-phantom-citations.sh`, `bash scripts/check-evidence-probes.sh`, `bash scripts/readme-lint.sh`. Each is invoked through the repository's own `scripts/` entry point and its exit status is recorded.
- `grep -rn 'sorry' FormalSystem/Metalogic/AuxiliaryAtoms.lean Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` returns nothing.
- Every `#guard_msgs` block in the new evidence module was populated from a measured `#print axioms` run in this dispatch, and the module compiles — a red guard means a profile moved and is never re-baselined to turn the build green.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 895 .` is run and its verdict recorded. Per `rules/plan-compliance.md` the verdict is **ADVISORY ONLY**: a drift finding is a signal to investigate, never grounds to fail the phase on its own. If no manifest exists for this task the expected outcome is `ERROR: no manifest found … exit 71`; record that as the verdict and do **not** run the script without `--check` to manufacture a manifest after the fact, which would record the implementation rather than the contract.
- All ten `## Lean Challenge Statements` identifiers are present in `FormalSystem/Metalogic/AuxiliaryAtoms.lean` at the pinned signatures.
- `check-metalogic-cycles.sh` Assertion B is unchanged — this task adds no new upward import; the `NamingRules.lean` edit is prose only.

---

## Testing & Validation

- [ ] Full project build green with zero warnings, and `lake build BimodalTest` green (CI builds with `--wfail`; a lint warning is a CI failure).
- [ ] Zero `sorry` and zero new axiom in both new files; the measured axiom profile ceiling is `[propext, Classical.choice, Quot.sound]` or lower for every pinned declaration.
- [ ] All ten `## Lean Challenge Statements` identifiers present at their pinned signatures.
- [ ] The six axiom-profile `#guard_msgs` blocks compile against **measured** profiles.
- [ ] `scripts/check-module-invariants.sh` clean for every touched file, with any pre-existing repo-wide finding enumerated.
- [ ] `scripts/typst-sync-check.sh` green (both Check 2 and the inventory-block check).
- [ ] `scripts/check-metalogic-cycles.sh` unchanged — no new upward import.
- [ ] `scripts/check-copyright-headers.sh`, `check-paper-definitions.sh`, `check-phantom-citations.sh`, `check-evidence-probes.sh`, `readme-lint.sh` each run with exit status recorded and any finding attributed to a touched file or to the pre-existing baseline.
- [ ] `.githooks/pre-commit` accepted every Lean-touching commit without `--no-verify`.
- [ ] No file outside this plan's declared `Files to modify` lists is staged in any of this task's commits.

## Artifacts & Outputs

- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` — the new module. Per-phase line estimates 160, 130, 120, 140, 160 and 40 sum to roughly **750 lines**, which is under the 1500-line `longFile` linter ceiling; if the running total approaches 1500 the contingency is to split the model/antecedent half into a sibling module rather than to suppress the linter.
- `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` — the permanent axiom-profile evidence pin.
- `FormalSystem/Metalogic.lean`, `FormalSystem.lean`, `Tests/BimodalTest.lean` — aggregator/root imports extended and regenerated.
- `FormalSystem/Metalogic/NamingRules.lean` — the retired "where it stops" framing and the new `## References` entry; prose only, no import.
- `docs/theorem-index.md` — three new rows.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `typst/generated/status.typ` — regenerated counts.
- `specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean` — the research probe, tracked, not `WIRED`.
- `specs/895_auxiliary_atoms_rule_soundness_ztime/summaries/01_auxiliary-atoms-rule-soundness-summary.md` — the completion summary.

## Rollback/Contingency

Each phase is one commit or a short series of green sub-step commits, and Phases 1-5 touch only
the new module plus two generated files, so reverting is `git revert` of that phase's own commits
— no snapshot-then-rollback is needed for an ordinary back-out. Tasks 910 and 911 are live on
this tree this cycle, so a revert must name this task's own commits explicitly and never a range
that could span a sibling's.

Should a phase need a genuine working-tree rollback that would discard uncommitted work, follow
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag; do not emit a bare precautionary `git-snapshot.sh 895`.
For an ordinary defensive checkpoint before Phase 5 — the one phase whose proof is genuinely new
assembly rather than transcription — use `git-snapshot.sh --no-revert`, which is durable without
reverting the tree.

If Phase 5's step branch proves intractable at the planned decomposition, the contingency is to
add named sub-lemmas inside Phase 5 (recorded as a decomposition deviation), **not** to weaken a
Challenge-pinned statement and **not** to place a `sorry`: zero-debt holds, the route is already
compiled in the probe, and `rules/plan-compliance.md` requires marking the phase `[BLOCKED]` and
escalating rather than substituting a different statement.
