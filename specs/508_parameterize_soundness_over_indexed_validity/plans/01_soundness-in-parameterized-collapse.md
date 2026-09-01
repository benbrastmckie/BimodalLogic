# Implementation Plan: Task #508

- **Task**: 508 - Parameterize soundness over indexed validity
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 507 (landed), Task 510
- **Research Inputs**:
  - `specs/508_parameterize_soundness_over_indexed_validity/reports/01_parameterized-soundness.md`
  - `specs/508_parameterize_soundness_over_indexed_validity/reports/01_verified-reference-implementation.lean`
- **Artifacts**: plans/01_soundness-in-parameterized-collapse.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Collapse the soundness family onto one `FrameClass`-parameterized theorem
`soundness_in {fc} : DerivationTree fc Γ φ → fc.Sat F → … → TruthAt M τ t φ`, retaining every
existing public name as a one-line corollary so downstream call sites need zero edits. The
research phase did not merely design this: it **wrote the whole collapse, compiled it sorry-free
against the live tree as `FormalSystem/Probe508.lean` (`lake build`, exit 0), audited its
`#print axioms` profile against the four incumbents (identical at
`[propext, Classical.choice, Quot.sound]`), then removed it from `FormalSystem/` and preserved it
verbatim** at `reports/01_verified-reference-implementation.lean` (239 lines). This plan is a
**transplant plan**, not a derivation plan. Phases 2–4 copy that artifact into the tree and
retarget the incumbents onto it; the remaining phases extend the same move to the pruning,
BL-language, and list-context-consequence layers, and gate the result.

Definition of done: sorry-free, `lake build` green, `#print axioms` unchanged on all flagship
soundness results, no theorem weakened, no public name removed that has a live consumer.

### Research Integration

The research report is authoritative over the task brief wherever they conflict. Findings carried
into this plan:

- **All soundness line citations in the brief are stale.** The verified set (independently
  re-confirmed during planning by `grep -n` on the working tree) is recorded in the phase bodies
  below. Re-verify at implementation time anyway — stale citations have recurred across this batch.
- **The uniform `temporal_duality` case was the sole genuine technical risk and it is retired.**
  `derivable_valid_and_swap_validIn` (reference impl `:101–170`) is one recursion covering all four
  classes and it compiled. No phase may re-litigate this; copy it.
- **`FormalSystem/FrameConditions/` is gone.** That row of the brief's duplication inventory is
  void. Residual references live only in `FormalSystem/Boneyard/`, which is not compiled (no
  `.lake` output, no root import). Boneyard is out of scope and must not be touched.
- **The BL-side *definition* collapse already landed under task 507, in a different and
  deliberately-argued shape.** `BLValidIn fc := BLValidOnFrames fc.Sat` (`BLValidity.lean:107`) is
  native over `BLTruthAt`; the docstring at `BLValidity.lean:81-86` argues explicitly against the
  `ValidOn fc (tr φ)` route the brief prescribes, because `BLTruthAt` is native per
  `def:BL-semantics`. Review M3's definitional half is **discharged**. This plan does **not**
  pursue the brief's `BLValidOn fc φ := ValidOn fc (tr φ)` route — doing so would regress an
  anchored decision. Only the eight `bl_soundness*` theorems remain (Phase 6).
- **`BLValidIn.of_forall_total` / `.apply_total` do not exist** — only the `.mono` pair
  (`BLValidity.lean:141,147`). Adding them by mirroring `Validity.lean:426-450` is the sole
  genuinely new code the BL side needs.
- **The brief under-counts duplication.** `axiom_locally_valid_general`
  (`FrameClassVariants.lean:393`, ~290 lines, `private`) is a *third* copy of base-axiom validity.
  `FrameClassVariants.lean` therefore **shrinks** to roughly 500 lines rather than disappearing.
- **Implementation trap, already hit and fixed once:** in `axiom_swap_validIn_min`, the `density`
  and `dense_indicator` arms must pass `trivial` (not `by decide`) as the `h_fc` argument to
  `SoundnessLemmas.axiom_swap_valid`; `by decide` fails with *"Expected type must not contain free
  variables"*. The reference implementation already carries the fix — do not "improve" it.

### Correction to the research's own phase sketch (found during planning)

The research's §10 phase 3 says to *"delete the four `axiom_*_valid` dispatchers"*. That
contradicts its own §8 inventory, which promises zero downstream edits if collapsed names are
retained. Verified during planning:

```
FormalSystem/Metalogic/Independence/LexIntWitness.lean:182   axiom_valid
FormalSystem/Metalogic/Independence/LexIntWitness.lean:233   axiom_discrete_valid
FormalSystem/Metalogic/Independence/RationalWitness.lean:126 axiom_dense_valid
FormalSystem/Metalogic/Independence/RationalWitness.lean:172 axiom_dedekind_valid
```

All four have live consumers. **They are retained as one-line corollaries over `axiom_validIn`,
never deleted** (Phase 4). Only their 45-arm dispatch *bodies* go. `axiom_dedekind_swap_valid` and
`derivable_valid_and_swap_valid_dedekind` were confirmed to have no consumers outside
`Soundness.lean` and are genuinely deletable.

### Prior Plan Reference

No prior plan for this task. Task 507's plans (`specs/507_parameterize_validity_by_frameclass/plans/`)
delivered the `FrameClass` / `ValidIn` / `FrameClass.Sat` substrate this task consumes, and its
Set-consequence collapse (`SetConsequence.lean:91,98,129–197`) is the exact structural template for
Phase 7 — cited as precedent, not copied as phase text.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap phases are included and
`specs/ROADMAP.md` is neither read as a plan input nor modified. A read-only grep confirms the
roadmap's soundness entries concern the tableau/decision-engine side
(`ROADMAP.md:109,111,128,260`), not the Hilbert-system soundness family this task restructures;
no roadmap item is advanced or invalidated here.

## Goals & Non-Goals

**Goals**:
- Land `soundness_in` as the single `FrameClass`-parameterized soundness theorem, plus
  `axiom_validIn{,_min}`, `axiom_swap_validIn{,_min}`, `derivable_valid_and_swap_validIn`,
  `soundness_validIn`.
- Retarget all four `Formula`-side soundness headliners and three `*_valid` forms onto it, as
  corollaries preserving their exact existing statements.
- Retarget the eight `bl_soundness*` theorems onto a `bl_soundness_in`, adding the missing
  `BLValidOnFrames`/`BLValidIn` `of_forall_total`/`apply_total` adapters.
- Collapse the list-context consequence layer onto `SemanticConsequenceIn`, making the four
  `soundness_*_consequence` theorems one-liners (**in scope — see Decision below**).
- Delete the now-dead duplicate recursions and the three `axiom_locally_valid_*` /
  `axiom_swap_valid_discrete` private copies.
- Preserve every axiom profile and every public name that has a live consumer.

**Non-Goals**:
- Re-opening the BL-side definition shape (`BLValidIn` stays native over `BLTruthAt`; the brief's
  `ValidOn fc (tr φ)` route is explicitly rejected — see Research Integration).
- Retargeting `soundness_dedekind` from `ValidDedekindDense` to `ValidDedekind`. **Hard
  constraint**: `Sat .Dedekind = IsDedekind = IsDense ∧ IsComplete`, whereas `ValidDedekind` is
  `ValidOnFrames TaskFrame.IsComplete` (the bare clause, satisfied by `ℤ`); `Axiom.density` and
  `Axiom.dense_indicator` are admissible at `.Dedekind` and false on `ℤ`, so retargeting is
  **refutable**. The `ValidDedekindDense` binder bundle is preserved exactly.
- Touching `bl_soundness_discrete_succ` (`BaseLanguageSoundness.lean:381`),
  `bl_soundness_discrete_succ_valid` (`:413`), or `BLValidDiscreteSucc` (`BLValidity.lean:221`).
  These are **not** schema instances — no `FrameClass.Sat` variant bundles `SuccOrder`+`PredOrder`
  alone. PRESERVE UNTOUCHED.
- Touching `FormalSystem/Boneyard/**` (not compiled).
- Renaming `.Dedekind` to `.Complete` (rejected under task 507; "complete" is reserved here for
  proof-theoretic completeness).
- Repairing the two pre-existing gate failures (see Testing & Validation).

### Decision: list-context consequence layer is IN SCOPE

The four `SemanticConsequence*` defs (`Validity.lean:89`, `StrongCompleteness.lean:729`, `:839`,
`:174`) are still hand-written binder lists while task 507 already collapsed the Set layer onto
`SetSemanticConsequenceOn`. The research recommends keeping the collapse in scope and the team lead
has adopted that recommendation; Phases 7–8 implement it.

The cost is real and is named here so it is not discovered mid-phase: the four docstrings
currently justify themselves as a **hand-copied binder guard** (e.g.
`StrongCompleteness.lean:521-528`: *"it holds only because the definition above reproduces that
block verbatim. If a later edit weakens the consequence relation … this theorem breaks"*).
Collapsing moves that guard from a hand-copied list to `FrameClass.Sat` — strictly better (one
source of truth) but requiring those four docstrings to be **rewritten, not deleted**. Phase 7
budgets for that rewrite explicitly. If a concrete defect forces cutting Phases 7–8, the
implementer must record the resulting asymmetry (Set layer collapsed, List layer not) explicitly in
the phase's `#### Reasoned Exclusions` block rather than leaving it silent.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer re-derives the collapse instead of transplanting the verified artifact | H | M | Phases 2–4 mandate verbatim copy from `reports/01_verified-reference-implementation.lean` with a named line range; deviation must be justified by a compile error, not by taste |
| Stale line citations drift further before implementation | M | H | Phase 1 re-verifies every anchor by `grep -n` and records the delta; every later phase locates by declaration name, never by line number alone |
| `axiom_*_valid` deleted per the research's §10 sketch, breaking `LexIntWitness`/`RationalWitness` | H | M | Correction recorded above; Phase 4 explicitly retains all four as corollaries and Phase 1 re-confirms the consumer list |
| `by decide` reintroduced in the `density`/`dense_indicator` swap arms | M | M | Trap named in Research Integration and repeated in Phase 2's tasks; `trivial` is required |
| Axiom profile silently widens (e.g. a `decide`/`Classical` leak) | H | L | Phase 1 records the baseline `#print axioms` for all flagship results; Phase 9 diffs against it; Phase 4 spot-checks the four headliners immediately |
| Consequence-layer collapse breaks a definitional-equality-sensitive proof | M | M | Mirror `SetConsequence.lean:129–197` exactly, including the `.Discrete` adapter's `obtain`-and-`@` idiom (never `haveI`, which breaks defeq against instances baked into `F`'s type) |
| Deleting a `private` lemma that a surviving proof still consumes | M | L | Phase 5 runs a name-grep for each deletion candidate before removing it; `axiom_swap_valid_general` and the four `prior_UZ/SZ/z1` lemmas are protected content and must survive |
| Pre-existing gate failures absorbed as this task's defects | M | M | Named as reasoned exclusions up front (Testing & Validation); Phase 9 reports them as pre-existing and does not repair them |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 6, 7 | 3 |
| 5 | 5, 8 | 4 (for 5), 7 (for 8) |
| 6 | 9 | 5, 6, 8 |

Phases within the same wave can execute in parallel. **Territory contract for Wave 4** (disjoint
file ownership, so parallel dispatch is safe): Phase 4 owns `Metalogic/Soundness.lean`; Phase 6
owns `Semantics/BLValidity.lean` + `Metalogic/BaseLanguageSoundness.lean`; Phase 7 owns
`Semantics/Validity.lean` + `Metalogic/StrongCompleteness.lean`. Sequential execution is equally
valid and avoids `lake` contention — the waves record what *may* run in parallel, not a mandate.

---

### Phase 1: Anchor re-verification and downstream call-site inventory [NOT STARTED]

**Goal**: Establish the ground truth this whole plan is written against — every declaration anchor,
every downstream consumer, and the baseline axiom profile — before a single source byte changes.

**Tasks**:
- [ ] Confirm baseline: `lake build` green, record module count; record `git rev-parse HEAD`.
- [ ] Re-verify by `grep -n` (locate by declaration name; record actual line numbers and any delta
      from the values below):
  - `Metalogic/Soundness.lean`: `soundness`:1152, `soundness_dense`:1329, `soundness_discrete`:1477,
    `soundness_dedekind`:2014; `soundness_dense_valid`:1256, `soundness_discrete_valid`:1421,
    `soundness_dedekind_valid`:1995; `axiom_valid`:925, `axiom_dense_valid`:979,
    `axiom_discrete_valid`:1040, `axiom_dedekind_valid`:1819, `axiom_dedekind_swap_valid`:1888,
    `derivable_valid_and_swap_valid_dedekind`:1919, `sep_swap_valid`:1763
  - `Metalogic/StrongCompleteness.lean`: `soundness_dedekind_consequence`:530,
    `soundness_base_consequence`:676, `soundness_dense_consequence`:781,
    `soundness_discrete_consequence`:891; `SemanticConsequenceDedekindDense`:174,
    `SemanticConsequenceDense`:729, `SemanticConsequenceDiscrete`:839
  - `Metalogic/BaseLanguageSoundness.lean`: `bl_soundness`:201, `_dense`:215, `_discrete`:229,
    `_dedekind`:249; `*_valid`:264/269/274/280; **preserve** `bl_soundness_discrete_succ`:381,
    `_valid`:413
  - `Metalogic/SoundnessLemmas/FrameClassVariants.lean`: `axiom_swap_valid_general`:45 (**keep**),
    `axiom_locally_valid_general`:393 (private, delete), `derivable_valid_and_swap_valid_general`:683,
    `derivable_implies_swap_valid_general`:726, `prior_UZ_is_valid`:742 / `prior_SZ_is_valid`:782 /
    `z1_is_valid`:821 / `z1_past_is_valid`:883 (**keep all four**),
    `axiom_swap_valid_discrete`:939 (private, delete), `axiom_locally_valid_discrete`:972 (private,
    delete), `derivable_valid_and_swap_valid_discrete`:994,
    `derivable_implies_swap_valid_discrete`:1034
  - `Metalogic/SoundnessLemmas/DenseValidity.lean`: `axiom_swap_valid`:296 (**keep**),
    `derivable_valid_and_swap_valid`:1320, `derivable_locally_valid`:1362,
    `derivable_implies_swap_valid`:1369
  - `Semantics/Validity.lean`: `ValidIn.mono`:413, `ValidOnFrames.of_forall_total`:426 /
    `.apply_total`:433, `ValidIn.of_forall_total`:441 / `.apply_total`:448, `SemanticConsequence`:89
  - `Semantics/BLValidity.lean`: `BLValidOnFrames`:102, `BLValidIn`:107,
    `BLValidOnFrames.mono`:141, `BLValidIn.mono`:147; confirm `BLValidIn.of_forall_total` /
    `.apply_total` are **absent**
  - `Metalogic/SetConsequence.lean`: `SetConsequenceOnFrames`:91, `SetSemanticConsequenceOn`:98,
    adapters `:129–197`, `setConsequenceOnFrames_mono`:208, `setDerivable_iff_exists_finite`:247
- [ ] Re-run the downstream consumer inventory with a single grep over `FormalSystem/` and `Tests/`,
      excluding `FormalSystem/Boneyard/`, for every name this task retargets or deletes. Confirm the
      research's §8 table and the planning-time correction: the four `axiom_*_valid` have live
      consumers (`LexIntWitness.lean:182,233`, `RationalWitness.lean:126,172`) and must be retained;
      `axiom_dedekind_swap_valid` and `derivable_valid_and_swap_valid_dedekind` have none outside
      `Soundness.lean`.
- [ ] Record baseline `#print axioms` for: `soundness`, `soundness_dense`, `soundness_discrete`,
      `soundness_dedekind`, `soundness_dense_valid`, `soundness_discrete_valid`,
      `soundness_dedekind_valid`, `bl_soundness{,_dense,_discrete,_dedekind}`,
      `soundness_{base,dense,discrete,dedekind}_consequence`. Expected:
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Record baseline repo-wide `sorry` count.
- [ ] Write all of the above to
      `specs/508_parameterize_soundness_over_indexed_validity/reports/02_anchor-and-callsite-inventory.md`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a specific anchor set (~45 declaration line numbers) and a
specific consumer set (9 consumer modules, 4 retained `axiom_*_valid` names, 2 genuinely deletable
names). Both are hypotheses inherited from research plus planning-time spot checks. Confirm each by
`grep -n` on the working tree at implementation time; any delta is recorded in
`reports/02_anchor-and-callsite-inventory.md` and supersedes the numbers written here.

**Files to modify**:
- `specs/508_parameterize_soundness_over_indexed_validity/reports/02_anchor-and-callsite-inventory.md`
  - new; no `FormalSystem/` source is touched in this phase

**Verification**:
- The inventory file exists and every anchor in it was produced by an actual `grep -n`, not copied
  from this plan.
- `git status` shows zero modifications under `FormalSystem/`.
- Baseline build green and baseline axiom profiles recorded.

---

### Phase 2: Transplant the two leaf lemmas [NOT STARTED]

**Goal**: Land `axiom_validIn_min` and `axiom_swap_validIn_min` in `Metalogic/Soundness.lean`,
purely additively, with every incumbent still present and the build still green.

**Tasks**:
- [ ] Copy `axiom_validIn_min` **verbatim** from
      `reports/01_verified-reference-implementation.lean:11–58` (45 arms, each a one-line `exact`
      against an existing `*_valid` lemma) into `Soundness.lean` immediately after `sep_swap_valid`.
- [ ] Copy `axiom_swap_validIn_min` **verbatim** from the same file, `:60–90`, directly below it.
- [ ] Preserve the two naming traps the reference already handles: `serial_future ↦
      serial_future_axiom_valid`, `serial_past ↦ serial_past_axiom_valid`.
- [ ] **Preserve `trivial` (NOT `by decide`)** as the `h_fc` argument to
      `SoundnessLemmas.axiom_swap_valid` in the `density` and `dense_indicator` arms. `by decide`
      fails with *"Expected type must not contain free variables"* because the goal mentions
      `(Axiom.density a0).minFrameClass`. This was hit and fixed once already.
- [ ] Strip the `Probe508` namespace wrapper; place the declarations inside the module's existing
      namespace so the `open`s in the reference file are unnecessary. Adjust qualification only as
      the elaborator demands.
- [ ] Do not delete, rename, or edit any incumbent declaration in this phase.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts exactly two new declarations, 45 arms each, all one-line `exact`s
against lemmas that already exist, and zero edits to existing declarations. Confirm by
`git diff --stat` showing one file changed with insertions only, and by `lake build
FormalSystem.Metalogic.Soundness` succeeding with the incumbents untouched.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — append two theorems after `sep_swap_valid` (~1763)

**Verification**:
- `lake build FormalSystem.Metalogic.Soundness` exits 0, zero `sorry` warnings.
- `#print axioms` on both new lemmas reports `[propext, Classical.choice, Quot.sound]`.
- `git diff` shows insertions only.

---

### Phase 3: Transplant the uniform recursion and `soundness_in` [NOT STARTED]

**Goal**: Land the four remaining core declarations — still purely additive, incumbents untouched.
This phase carries the collapse's one genuine technical risk, and that risk is already retired by
the verified artifact.

**Tasks**:
- [ ] Copy verbatim from `reports/01_verified-reference-implementation.lean`:
  - `axiom_validIn` (`:92–94`) and `axiom_swap_validIn` (`:96–98`) — each `ValidIn.mono h_fc (…_min ax)`
  - `derivable_valid_and_swap_validIn` (`:100–170`), **including the `termination_by d.height` and
    `decreasing_by` block verbatim**
  - `soundness_in` (`:172–201`)
  - `soundness_validIn` (`:234–237`)
- [ ] **Do not re-derive or "simplify" the `temporal_duality` arm.** It is
      `((derivable_valid_and_swap_validIn d').2).apply_total F hF M τ h_mem t`. This is the single
      point where the four incumbent proofs diverge (Base via
      `derivable_implies_swap_valid_general`, Dense via `derivable_implies_swap_valid`, Discrete via
      `derivable_implies_swap_valid_discrete`, Dedekind via
      `derivable_valid_and_swap_valid_dedekind`); the uniform recursion is what makes it one arm and
      it has compiled. Copy it.
- [ ] Leave every incumbent declaration in place; the build must stay green with both the old and
      new architecture present.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts five new declarations, all additive, no incumbent edited. Confirm by
`git diff --stat` (insertions only) and a green single-module build.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — append after the Phase 2 block

**Verification**:
- `lake build FormalSystem.Metalogic.Soundness` exits 0, zero `sorry`.
- `#print axioms FormalSystem.Metalogic.soundness_in` reports
  `[propext, Classical.choice, Quot.sound]`.
- Termination checker accepts `derivable_valid_and_swap_validIn` with no `partial`/`unsafe`.

---

### Phase 4: Retarget the `Formula`-side theorems onto `soundness_in` [NOT STARTED]

**Goal**: Replace the bodies of the four soundness headliners, the three `*_valid` forms, and the
four `axiom_*_valid` dispatchers with one-line corollaries; delete only the two names confirmed to
have no consumers.

**Tasks**:
- [ ] Retarget bodies, **statements unchanged**:
  - `soundness`:1152 → `soundness_in Γ φ d F trivial M τ h_mem t h_ctx`
  - `soundness_dense`:1329 → `… F inst M …`
  - `soundness_discrete`:1477 → `… F ⟨so, po, hsa, hpa⟩ M …`
  - `soundness_dedekind`:2014 → `… F ⟨inst, h_lub⟩ M …` — **the `ValidDedekindDense` binder bundle
    is preserved exactly; do not retarget to `ValidDedekind`** (refutable, see Non-Goals)
  - `soundness_dense_valid`:1256, `soundness_discrete_valid`:1421, `soundness_dedekind_valid`:1995
    → `soundness_validIn d`
  - Reference bodies: `reports/01_verified-reference-implementation.lean:203–237`
    (`soundness'`/`soundness_dense'`/`soundness_discrete'`/`soundness_dedekind'`/`soundness_validIn`).
- [ ] **RETAIN and retarget** all four `axiom_*_valid` — they have live consumers (see the
      Correction section):
  - `axiom_valid`:925, `axiom_dense_valid`:979, `axiom_discrete_valid`:1040,
    `axiom_dedekind_valid`:1819 → each becomes `axiom_validIn h h_fc`, deleting only its 45-arm
    dispatch body.
- [ ] Delete `axiom_dedekind_swap_valid`:1888 and `derivable_valid_and_swap_valid_dedekind`:1919
      **only after** re-grepping to confirm no consumer outside `Soundness.lean` (Phase 1 inventory
      says none). If either turns out to have a consumer, retain it as a corollary instead
      (`axiom_swap_validIn h h_fc` / `derivable_valid_and_swap_validIn d`) and record the change.
- [ ] Run `#print axioms` on all four headliners and the three `*_valid` forms; diff against the
      Phase 1 baseline. Any widening is a stop-and-fix, not a note.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 11 bodies retargeted, 2 declarations deleted, 0 statements changed,
0 downstream call sites edited. Confirm by: `git diff` showing no change to any retargeted
theorem's signature lines; a grep for each deleted name returning nothing outside `Boneyard/`; and
building `Soundness.lean` plus its enumerated direct dependents
(`BaseLanguageSoundness`, `StrongCompleteness`, `TMCompletenessReduction`,
`DiscreteNonCompactness`, `Z1Countermodel`, `Independence/CoNotPriorU`,
`Independence/LexIntWitness`, `Independence/RationalWitness`) with zero edits to them.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — 11 bodies retargeted, 2 declarations removed

**Verification**:
- `lake build` of `Soundness.lean` and all eight enumerated direct dependents exits 0, with **no
  edits** to any dependent — this is the concrete test of the "zero downstream edits" promise.
- `#print axioms` on all seven flagship results matches the Phase 1 baseline exactly.
- Zero `sorry`.

---

### Phase 5: Prune the dead recursions and duplicate axiom-validity copies [NOT STARTED]

**Goal**: Remove the now-unreachable duplicate machinery from `FrameClassVariants.lean` and
`DenseValidity.lean` without removing the genuine semantic content those files also carry.

**Tasks**:
- [ ] Before each deletion, grep the name across `FormalSystem/` and `Tests/` (excluding
      `Boneyard/`) and confirm zero remaining consumers. Delete from
      `SoundnessLemmas/FrameClassVariants.lean`:
  - `axiom_locally_valid_general`:393 (private, ~290 lines — the third full copy of base-axiom
    validity the brief under-counted)
  - `derivable_valid_and_swap_valid_general`:683, `derivable_implies_swap_valid_general`:726
  - `axiom_swap_valid_discrete`:939 (private), `axiom_locally_valid_discrete`:972 (private)
  - `derivable_valid_and_swap_valid_discrete`:994, `derivable_implies_swap_valid_discrete`:1034
- [ ] **MUST NOT delete** from that file: `axiom_swap_valid_general`:45 (~348 lines, consumed by
      `axiom_swap_validIn_min`'s Base branch) and `prior_UZ_is_valid`:742 / `prior_SZ_is_valid`:782 /
      `z1_is_valid`:821 / `z1_past_is_valid`:883 (consumed by `axiom_swap_validIn_min`'s discrete
      arms). The file **shrinks to roughly 500 lines; it does not disappear** and stays imported
      from `SoundnessLemmas.lean:10`. No module-manifest change is required.
- [ ] Delete from `SoundnessLemmas/DenseValidity.lean`: `derivable_valid_and_swap_valid`:1320,
      `derivable_locally_valid`:1362 (no call sites), `derivable_implies_swap_valid`:1369.
      **MUST NOT delete** `axiom_swap_valid`:296 — consumed by `axiom_swap_validIn_min`.
- [ ] Update `FormalSystem/Metalogic/SoundnessLemmas/README.md`'s Modules table line counts to the
      post-prune actuals. Note: that table is **already stale before this task** (it lists
      `FrameClassVariants.lean` at 971 and `DenseValidity.lean` at 1338; the files are currently
      1041 and 1375). Set both rows from a fresh `wc -l`, and check the other rows in the same pass.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 10 declarations deleted across two files, 5 protected declarations
surviving, and a post-prune `FrameClassVariants.lean` of roughly 500 lines. Confirm by: a per-name
grep before each deletion; `wc -l` on both files after; and a grep confirming all five protected
names are still present and still referenced from `axiom_swap_validIn_min`.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 7 declarations removed
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` — 3 declarations removed
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` — Modules table line counts refreshed

**Verification**:
- `lake build` green across `SoundnessLemmas` and `Metalogic`.
- Each deleted name returns zero hits outside `Boneyard/`.
- All five protected names still present.
- README line counts match `wc -l`.

---

### Phase 6: BL-side collapse [NOT STARTED]

**Goal**: Add the missing generic BL adapters, introduce `bl_soundness_in` / `bl_soundness_validIn`,
and retarget the eight `bl_soundness*` theorems — while leaving the `BLValidIn` *definition* and the
`discrete_succ` pair entirely alone.

**Tasks**:
- [ ] Add to `Semantics/BLValidity.lean`, mirroring `Validity.lean:426–450` exactly:
      `BLValidOnFrames.of_forall_total`, `BLValidOnFrames.apply_total`, `BLValidIn.of_forall_total`,
      `BLValidIn.apply_total`. These are confirmed absent today (only the `.mono` pair at `:141,:147`
      exists). This is the sole genuinely new code on the BL side.
- [ ] **MUST NOT** change `BLValidOn`:96, `BLValidOnFrames`:102, or `BLValidIn`:107. The
      native-over-`BLTruthAt` shape landed under task 507 with a docstring at `:81-86` arguing
      explicitly against the brief's `ValidOn fc (tr φ)` route. Review M3's definitional half is
      discharged.
- [ ] Add `bl_soundness_in` to `Metalogic/BaseLanguageSoundness.lean`, per the research's §5 body:
      `(truthAt_tr M φ τ t).mp (soundness_in (trCtx Γ) (tr φ) (Conservativity.translate d) F hF M τ
      h_mem t (truthAt_trCtx M τ t h_ctx))`. `Conservativity.translate` is already `fc`-polymorphic;
      `truthAt_tr`:110 and `truthAt_trCtx`:131 carry no frame condition.
- [ ] Add `bl_soundness_validIn {fc} : BaseLanguage.DerivationTree fc [] φ → BLValidIn fc φ` via
      the new `BLValidIn.of_forall_total`.
- [ ] Retarget bodies, statements unchanged: `bl_soundness`:201 (`… trivial …`), `_dense`:215
      (`… inst …`), `_discrete`:229 (`… ⟨so,po,hsa,hpa⟩ …`), `_dedekind`:249 (`… ⟨inst,h_lub⟩ …`);
      `bl_soundness{,_dense,_discrete,_dedekind}_valid`:264/269/274/280 → `bl_soundness_validIn d`.
- [ ] **PRESERVE UNTOUCHED**: `bl_soundness_discrete_succ`:381,
      `bl_soundness_discrete_succ_valid`:413, `BLValidDiscreteSucc` (`BLValidity.lean:221`). These
      are not schema instances — no `FrameClass.Sat` variant bundles `SuccOrder`+`PredOrder` alone,
      and the theorem runs its own induction because `soundness_discrete`'s binder bundle carries the
      very Archimedean instances it drops. Verify by `git diff` that these three declarations are
      byte-identical after the phase.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 4 new adapters + 2 new theorems added, 8 bodies retargeted, 3
declarations byte-identical, 0 definitions changed. Confirm by `git diff` on both files: no hunk
may touch `BLValidOn`/`BLValidOnFrames`/`BLValidIn`'s definitions or the three preserved
`discrete_succ` declarations.

**Files to modify**:
- `FormalSystem/Semantics/BLValidity.lean` — 4 adapter theorems added, no definition changed
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — 2 theorems added, 8 bodies retargeted

**Verification**:
- `lake build` of both modules plus their direct dependents exits 0, zero `sorry`.
- `#print axioms` on all eight `bl_soundness*` matches the Phase 1 baseline.
- `git diff` confirms the three preserved `discrete_succ` declarations are unchanged.

---

### Phase 7: Collapse the list-context consequence definitions [NOT STARTED]

**Goal**: Introduce `ConsequenceOnFrames` / `SemanticConsequenceIn` with adapters, retarget the four
hand-written `SemanticConsequence*` binder-list defs onto it, and **rewrite** the four docstrings
whose stated purpose was to act as the hand-copied binder guard.

**Tasks**:
- [ ] In `Semantics/Validity.lean`, add `ConsequenceOnFrames (P : TaskFrame → Prop) (Γ : Context)
      (φ : Formula)` and `SemanticConsequenceIn (fc : FrameClass) Γ φ := ConsequenceOnFrames fc.Sat
      Γ φ`, modelled on `SetConsequence.lean:91,98`.
- [ ] Add `.of_forall_total` / `.apply_total` adapters at the generic layer plus the four per-class
      `.of_forall` / `.apply` pairs, mirroring `SetConsequence.lean:129–197` **exactly**. For the
      `.Discrete` adapter use that file's `obtain`-and-`@` idiom; **never `haveI`**, which breaks
      definitional equality against instances baked into `F`'s type.
- [ ] Retarget the four defs, statements-as-propositions unchanged:
      `SemanticConsequence` (`Validity.lean:89`), `SemanticConsequenceDedekindDense`
      (`StrongCompleteness.lean:174`), `SemanticConsequenceDense` (`:729`),
      `SemanticConsequenceDiscrete` (`:839`) → each `SemanticConsequenceIn <fc> Γ φ`.
- [ ] **Rewrite (do not delete) the four docstrings.** Each currently justifies itself as a guard
      that "reproduces that block verbatim" (e.g. `StrongCompleteness.lean:521-528`). The rewritten
      text must state that the guard has moved to `FrameClass.Sat` — one source of truth rather than
      a hand-copied list — and cite `FrameClassValidity.lean`'s `Sat` as the new anchor. This is
      budgeted work, not incidental: it is the cost of the in-scope decision recorded above.
- [ ] Confirm the four defs remain *propositionally and definitionally* what they were, so no
      existing proof over them needs editing. If any does, the edit belongs to this phase and must be
      listed in the commit.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 2 new defs + 10 adapter lemmas added, 4 defs retargeted, 4 docstrings
rewritten, and (hypothesis) 0 existing proofs over these defs requiring edits. The last item is the
one most likely to be wrong; confirm by a full `lake build` and by grepping every consumer of the
four `SemanticConsequence*` names before starting.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` — `ConsequenceOnFrames`, `SemanticConsequenceIn`, generic
  adapters; `SemanticConsequence`:89 retargeted, docstring rewritten
- `FormalSystem/Metalogic/StrongCompleteness.lean` — three defs retargeted at `:174`, `:729`,
  `:839`, docstrings rewritten; per-class adapters

**Verification**:
- Full `lake build` exits 0, zero `sorry`.
- Each of the four `SemanticConsequence*` names still elaborates at its original type.
- No docstring was deleted rather than rewritten (`git diff` shows replacement, not removal).

---

### Phase 8: Retarget the consequence theorems and close H2's literal form [NOT STARTED]

**Goal**: Make the four `soundness_*_consequence` theorems one-liners over `soundness_in`, and add
the `SetDerivable → SetSemanticConsequenceOn` theorem the review's H2 names as its target.

**Tasks**:
- [ ] Retarget bodies, statements unchanged: `soundness_dedekind_consequence`:530,
      `soundness_base_consequence`:676, `soundness_dense_consequence`:781,
      `soundness_discrete_consequence`:891 → each `fun … => soundness_in …` through the Phase 7
      adapters.
- [ ] Add `soundness_setConsequence {fc} : SetDerivable fc Γ φ → SetSemanticConsequenceOn fc Γ φ`,
      composed from `setDerivable_iff_exists_finite` (`SetConsequence.lean:247`), `soundness_in`, and
      `setConsequenceOnFrames_mono` (`:208`). No such theorem exists today; adding it closes review
      H2's stated form.
- [ ] `#print axioms` on all four consequence theorems and the new one; diff against the Phase 1
      baseline.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 4 bodies retargeted and 1 theorem added, with 0 statement changes.
Confirm by `git diff` showing no signature-line changes on the four, and by a full build.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — 4 bodies retargeted
- `FormalSystem/Metalogic/SetConsequence.lean` — `soundness_setConsequence` added (or
  `Metalogic/Soundness.lean` if the import direction requires it; resolve at implementation time and
  record which)

**Verification**:
- Full `lake build` exits 0, zero `sorry`.
- `#print axioms` on all four consequence theorems matches the Phase 1 baseline.
- `soundness_setConsequence` reports `[propext, Classical.choice, Quot.sound]`.

---

### Phase 9: Tree-wide acceptance [NOT STARTED]

**Goal**: Gate the completed collapse against the task's acceptance criteria and report the two
known pre-existing failures as reasoned exclusions rather than absorbing them.

**Tasks**:
- [ ] Full `lake build` from clean; record module count and compare against the Phase 1 baseline
      (2564 at research time).
- [ ] Repo-wide `sorry` count; must equal the Phase 1 baseline (target: unchanged, and zero
      introduced by this task).
- [ ] `#print axioms` audit across every flagship result recorded in Phase 1; every profile must
      match the baseline exactly. Any widening is a task failure, not a note.
- [ ] Confirm no theorem was weakened: `git diff` over the whole task shows **no change to any
      retained theorem's statement**, only to bodies, plus the enumerated deletions.
- [ ] Confirm zero downstream call-site edits: `git diff --stat` must show no modification to
      `TMCompletenessReduction.lean`, `DiscreteNonCompactness.lean`, `Z1Countermodel.lean`,
      `Independence/CoNotPriorU.lean`, `Independence/LexIntWitness.lean`,
      `Independence/RationalWitness.lean`.
- [ ] Run `scripts/check-module-invariants.sh`. **C6 is expected to FAIL** on four
      unreachable-and-unmanifested modules from other tasks (`FormalSystem.Metalogic.SpWitness`,
      `FormalSystem.Metalogic.TMCompletenessReduction`, `FormalSystem.Metalogic.Z1Countermodel`,
      `FormalSystem.Semantics.LexCarrier`). **Pre-existing — record as a reasoned exclusion, do not
      repair.** C14 (axiom baselines) and C15 (paper anchors) must PASS; if either regresses, that
      *is* this task's defect.
- [ ] Run `scripts/readme-lint.sh`. **Check 1 is expected to FAIL** on the missing
      `FormalSystem/Semantics/Ultraproduct/README.md`. **Pre-existing — record as a reasoned
      exclusion, do not repair.** Any *new* README failure introduced by Phase 5's edits is this
      task's defect and must be fixed.
- [ ] Confirm `FormalSystem/Boneyard/**` is unmodified.
- [ ] Write `#### Reasoned Exclusions` under this phase enumerating the two pre-existing failures
      with their evidence, and (only if Phases 7–8 were cut) the recorded Set/List consequence-layer
      asymmetry.

**Timing**: 1 hour

**Depends on**: 5, 6, 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts exactly two pre-existing gate failures (C6 and readme-lint check 1)
and that C14/C15 pass. Confirm by running both scripts and diffing their output against the Phase 1
baseline capture; any third failure is either new (this task's defect) or a fourth pre-existing one
requiring its own evidence before exclusion.

**Files to modify**:
- `specs/508_parameterize_soundness_over_indexed_validity/plans/01_soundness-in-parameterized-collapse.md`
  — phase status markers and the `#### Reasoned Exclusions` record
- no `FormalSystem/` source changes expected in this phase

**Verification**:
- Full `lake build` exits 0, module count ≥ baseline.
- Zero `sorry` introduced.
- All axiom profiles match baseline.
- C14 and C15 pass; C6 and readme-lint check 1 fail identically to baseline and are recorded as
  exclusions.

---

## Testing & Validation

- [ ] `lake build` green tree-wide (baseline: 2564/2564 modules, exit 0).
- [ ] Zero `sorry` introduced; repo-wide count equals the Phase 1 baseline.
- [ ] `#print axioms` identical to baseline on: `soundness`, `soundness_dense`,
      `soundness_discrete`, `soundness_dedekind`, the three `soundness_*_valid`, the eight
      `bl_soundness*`, the four `soundness_*_consequence`, and every new declaration
      (`soundness_in`, `axiom_validIn{,_min}`, `axiom_swap_validIn{,_min}`,
      `derivable_valid_and_swap_validIn`, `soundness_validIn`, `bl_soundness_in`,
      `bl_soundness_validIn`, `soundness_setConsequence`). Expected:
      `[propext, Classical.choice, Quot.sound]`.
- [ ] No theorem weakened: every retained name keeps its exact original statement.
- [ ] Zero downstream call-site edits in the nine consumer modules from the Phase 1 inventory.
- [ ] `soundness_dedekind` still targets `ValidDedekindDense`.
- [ ] `bl_soundness_discrete_succ`, `bl_soundness_discrete_succ_valid`, and `BLValidDiscreteSucc`
      byte-identical.
- [ ] `FormalSystem/Boneyard/**` unmodified.
- [ ] `scripts/check-module-invariants.sh`: C14 and C15 pass.

**Pre-existing failures — record as reasoned exclusions, do NOT absorb or repair**:
- `scripts/check-module-invariants.sh` C6: four unreachable-and-unmanifested modules from other
  tasks (`SpWitness`, `TMCompletenessReduction`, `Z1Countermodel`, `LexCarrier`).
- `scripts/readme-lint.sh` check 1: missing `FormalSystem/Semantics/Ultraproduct/README.md`.

## Artifacts & Outputs

- `specs/508_parameterize_soundness_over_indexed_validity/reports/02_anchor-and-callsite-inventory.md`
  (Phase 1)
- `FormalSystem/Metalogic/Soundness.lean` — 7 new declarations; 11 bodies retargeted; 2 removed
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 7 declarations removed
  (~1041 → ~500 lines); `axiom_swap_valid_general` and the four `prior_UZ/SZ/z1` lemmas preserved
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` — 3 declarations removed;
  `axiom_swap_valid` preserved
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` — Modules table line counts refreshed
- `FormalSystem/Semantics/BLValidity.lean` — 4 adapter theorems added; definitions unchanged
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — `bl_soundness_in`, `bl_soundness_validIn`
  added; 8 bodies retargeted; `discrete_succ` pair preserved
- `FormalSystem/Semantics/Validity.lean` — `ConsequenceOnFrames`, `SemanticConsequenceIn`, generic
  adapters; `SemanticConsequence` retargeted
- `FormalSystem/Metalogic/StrongCompleteness.lean` — 3 defs retargeted, 4 theorem bodies retargeted,
  4 docstrings rewritten, per-class adapters
- `FormalSystem/Metalogic/SetConsequence.lean` — `soundness_setConsequence` added
- `specs/508_parameterize_soundness_over_indexed_validity/summaries/01_*-summary.md` (postflight)

## Rollback/Contingency

Every phase ends `lake build`-green and committable, so rollback is `git revert` of the offending
phase commit — the additive phases (2, 3) can be reverted without touching the retargeting phases,
and the retargeting phases (4, 6, 8) restore the incumbent bodies, which remain in git history
verbatim.

Contingencies by phase:
- **Phase 2 or 3 fails to compile**: the reference implementation compiled at commit `2fcc66f4e`. If
  the tree has drifted, diff the consumed lemma names against that commit rather than rewriting the
  proof. The recursion and the `temporal_duality` arm are not to be re-derived.
- **Phase 4 reveals a consumer of `axiom_dedekind_swap_valid` or
  `derivable_valid_and_swap_valid_dedekind`**: retain the name as a one-line corollary instead of
  deleting it, and record the deviation. Nothing else changes.
- **Phase 5 reveals a surviving consumer of a deletion candidate**: keep the declaration, record it,
  and continue. A partially-pruned file is a green tree; a wrongly-pruned one is not.
- **Phases 7–8 blocked by a concrete defect**: revert to the four hand-written
  `SemanticConsequence*` defs (Phase 7 is the only phase that touches them) and mark Phase 7/8
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` block that **explicitly records
  the Set/List asymmetry** — the Set layer collapsed under task 507, the List layer not — per the
  in-scope decision above. Phases 1–6 and 9 stand independently and still satisfy the task's
  acceptance criteria.
