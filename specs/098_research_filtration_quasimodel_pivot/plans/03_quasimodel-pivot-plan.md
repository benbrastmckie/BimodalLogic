# Implementation Plan: Quasimodel Pivot via EnrichedClosure (v3)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [NOT STARTED]
- **Effort**: 52-98 hours (point estimate: 72h)
- **Dependencies**: None (parallel to tasks 93, 94)
- **Research Inputs**:
  - specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
  - specs/098_research_filtration_quasimodel_pivot/reports/02_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-a-findings.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-c-findings.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-d-findings.md
- **Artifacts**: plans/03_quasimodel-pivot-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v2 halted at the Phase 4b gate: the "chain-step combined seed consistency" obligation could not be closed with the existing `SubformulaClosure` because `g_content_closed_derivation` produces `G(¬(∧ L_h))` formulas that do not land in Sigma. Round 3 research (Teammate A) identifies a sixth approach — extend Sigma to a **Fisher-Ladner / EnrichedClosure** that includes `G(¬(∧ T))` (and the dual `H(¬(∧ T))`) for every subset `T ⊆ Sigma`. This directly closes the consistency gap via the chain `L_g ⊢ ¬(∧ L_h) → G(¬(∧ L_h)) ∈ v_i → ∈ Sigma → ∈ h_i → ¬(∧ L_h) ∈ h_{i+1} → ⊥`. Teammate C exposed two independent hard sub-problems the v2 plan glossed over (chain-exhaustiveness for locus-control; `hintikka_chain_exists` with well-founded termination). Teammate D specified the defect-count termination design (track a "target defect" in the chain type). The revised plan front-loads EnrichedClosure behind an explicit checkpoint gate, then treats chain existence (with termination) and chain-step seed consistency as independent proof obligations, and only afterwards tackles realization, locus-control exhaustiveness, and the ten sorry targets. Definition of done: `lake build` succeeds with zero new sorries and the ten targeted sorries (4 in Frame.lean + 6 in Realization.lean) replaced by proofs.

### Research Integration

- **01_filtration-quasimodel-pivot.md** — established local quasimodel approach and identified realization lifting + locus-control as load-bearing.
- **02_team-research.md** — correctly identified combined-seed consistency as the sole remaining hard sub-problem under the old Sigma; ruled out 5 alternative approaches; motivated restructure of phases 4-5.
- **03_team-research.md** (primary input for v3) — introduces EnrichedClosure (sixth approach); documents `defect_count` termination design; recommends separating chain existence from chain-step consistency.
- **03_teammate-a-findings.md** — full EnrichedClosure construction including `bigconj`, `neg_bigconj`, and the negation-pairing property for Hintikka locally-maximal sets.
- **03_teammate-c-findings.md** — critical gap identification: (i) `quasimodel_chain_exists` is unproved (not just "Phase 4a work"); (ii) locus-control exhaustiveness for arbitrary interval points `u` is a second hard sub-problem equivalent in difficulty to combined-seed consistency.
- **03_teammate-d-findings.md** — defect-count strict-decrease lemma design; `QuasimodelChain` type must track a "target defect"; strategic recommendation to spin off a narrowly-scoped implementation task (interpreted here as defining checkpoint gates within task 98 rather than creating task 99).

### Prior Plan Reference

Plan v2 (phases 1-3 and 6 complete; phases 4-5 blocked at gate 4b). What we keep: Sigma-closure/HintikkaPoint/Construction/Integration-wiring are already in tree and sorry-free. What we learned: `enriched_seed_consistent_until`/`..._since` (Realization.lean:140, 193) are single-step lemmas NOT reusable verbatim at the chain level; the pattern they establish is still the right template. Effort calibration: the v2 estimate (20-35h) underestimated both the chain-existence proof and the locus-control lemma; the v3 estimate (52-98h) reflects Round 3 corrections.

### Roadmap Alignment

Task 98 advances the BX canonical-model completeness milestone by unblocking the Until/Since Truth Lemma, which in turn unblocks the four Frame.lean Until/Since sorries. It is parallelizable with task 93 (TaskModel embedding / Box sorry) and task 94 (legacy-sorry archival). No direct dependency on tasks 96/97.

## Goals & Non-Goals

**Goals**:
- Define `bigconj`, `neg_bigconj`, and the Fisher-Ladner `EnrichedClosure` in `SubformulaClosure.lean` (or a new file) and prove its closure + negation-pairing properties.
- Migrate `HintikkaPoint`, `Construction`, and `Realization` to use `EnrichedClosure` as the Sigma of record (either by rewrite or by typeclass parameterization).
- Prove `chain_step_seed_consistent` (the Phase 4b obligation) using the EnrichedClosure route.
- Define a refined `QuasimodelChain` type tracking a "target defect" and prove `hintikka_step_target_decrease` (strict-decrease lemma).
- Prove `hintikka_chain_exists` by well-founded recursion on `defect_count`, plus `hintikka_chain_guard` and `hintikka_chain_witness`.
- Prove `realize_chain_step` and `realize_full_chain` by induction, plus `guard_transfer` and `witness_transfer` via `sigma_signature_mem`.
- Prove the locus-control exhaustiveness theorem for arbitrary `u` with `bx_le v_0 u ∧ bx_le u v_k`.
- Close all 6 Realization.lean sorries (lines 282, 286, 346, 372, 374, 404) and all 4 Frame.lean sorries (lines 653, 675, 690, 704).
- Mirror the Until work to Since (`h_content`, `neg_bigconj` under `H`, backward ordering).

**Non-Goals**:
- Redefining `bx_le` (cascade cost too high; ruled out in round 2).
- Adding new BX axioms.
- Building the TaskModel embedding (task 93).
- Touching Frame.lean lines 140-583 beyond the four targeted sorries.
- Any changes to TruthLemma.lean G/H/Box cases.
- Archiving the legacy ~210 sorries (task 94).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| EnrichedClosure refactor cascade breaks phases 1-3 | H | M (30%) | **Checkpoint gate** after Phase 2 — prefer typeclass `ClosureScheme` parameterization over file rewrite to minimize blast radius; bail to a v4 plan if cascade exceeds 8h. |
| `EnrichedClosure` powerset explodes Lean kernel perf | M | M (25%) | Target is `Finset.powerset` of a `Finset` (Mathlib-native, Decidable); profile early with `lean_profile_proof`; if slow, restrict to "needed" T via on-demand elaboration. |
| Locus-control exhaustiveness (Teammate C's sub-problem C2) is harder than budgeted | H | M (35%) | Dedicated phase (Phase 6); use `sigma_signature` equality (not just membership) via `locally_maximal` property; if proof exceeds 12h, declare `locus_control_exhaustive` an axiom and re-scope. |
| `hintikka_chain_exists` termination proof requires deeper surgery on `hintikka_step` | M | L (15%) | Teammate D design tracks target defect in `QuasimodelChain` wrapper, not in `hintikka_step` itself; isolates change. |
| Sigma-projection gap: `g_content(v_i)` infinite vs `h_i` finite (Teammate C's A1 flag) | H | L (10%) | EnrichedClosure precisely closes this gap by ensuring `G(¬(∧ L_h)) ∈ Sigma` for any finite `L_h ⊆ h_{i+1}`; finite-subset-of-infinite reduction is the whole point of the approach. |
| Since direction diverges structurally from Until | M | M (30%) | Budget dedicated Since sub-phase (Phase 8b); dualize `neg_bigconj` under `H`; verify `h_content_closed_derivation` exists and mirrors `g_content_closed_derivation`. |
| Total effort exceeds 98h | M | M (30%) | After Phase 4 gate review, if remaining scope looks > 40h, split off Since + locus-control exhaustiveness into a follow-on task. |
| `defect_count` strict-decrease fails because `hintikka_step` allows defect propagation | M | L (15%) | Teammate D explicitly addresses this — the strict-decrease holds for `QuasimodelChain` steps that carry a target, not for arbitrary `hintikka_step` pairs. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 5, 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel.

**Checkpoint gates**:
- **Gate A** (end of Phase 2): EnrichedClosure integrated into phases 1-3; `lake build` clean; refactoring blast radius within budget. If failed, bail to v4 plan.
- **Gate B** (end of Phase 5): Chain-step seed consistency proved; realization lifting validates. If failed, re-scope to declare an axiom and document.

---

### Phase 1: Bigconj and EnrichedClosure Definition [COMPLETED]

**Goal**: Define the Fisher-Ladner closure and its core helper functions in isolation so they can be typechecked before any refactor.

**Tasks**:
- [ ] Create (or extend) `Theories/Bimodal/Syntax/BigConj.lean` (or a section in an existing Syntax file) with:
  - [ ] `bigconj : List Formula -> Formula` (fold `φ₁ ∧ φ₂ ∧ ... ∧ φₙ`, base case `⊤`).
  - [ ] `neg_bigconj : List Formula -> Formula := fun L => ¬ (bigconj L)`.
  - [ ] `bigconj_mem_iff`: `φ ∈ L -> DerivationTree {bigconj L} φ` (conjunction elimination by induction on `L`).
  - [ ] `bigconj_intro`: from a proof of each `φ ∈ L`, derive `bigconj L` (conjunction introduction).
- [ ] Extend `SubformulaClosure.lean` (or add `EnrichedClosure.lean` alongside it) with:
  - [ ] `def enrichedClosure (target : Formula) : Finset Formula := let base := subformulaClosure target; let negConj := base.powerset.image (fun T => Formula.all_future (neg_bigconj T.toList)); let negConjH := base.powerset.image (fun T => Formula.all_past (neg_bigconj T.toList)); (base ∪ negConj ∪ negConjH) |>.image (fun φ => φ) ∪ ... |>.image Formula.neg` (exact shape per Teammate A §3.2).
  - [ ] `enriched_target_mem`: `target ∈ enrichedClosure target`.
  - [ ] `enriched_subformula_mem`: every subformula of target is in the closure.
  - [ ] `enriched_g_neg_bigconj_mem`: for every `T ⊆ enrichedClosure target`, `G(neg_bigconj T.toList) ∈ enrichedClosure target`.
  - [ ] `enriched_h_neg_bigconj_mem`: dual for `H`.
  - [ ] `enriched_neg_pairing`: for all `φ ∈ enrichedClosure target`, `¬φ ∈ enrichedClosure target`.
  - [ ] `enriched_finite`: the closure is a `Finset` (trivial from `Finset.powerset` + `Finset.image`).
- [ ] Verify `lake build` passes for the new file(s) in isolation.
- [ ] Use `lean_profile_proof` on `enriched_g_neg_bigconj_mem` to catch kernel-explosion early.

**Timing**: 5-9 hours

**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Syntax/BigConj.lean` (new) — `bigconj`, `neg_bigconj`, derivation-tree lemmas
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` (modify) OR `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` (new) — Fisher-Ladner closure

**Verification**:
- [ ] `lake build` clean for new/modified files.
- [ ] `#check enrichedClosure`, `#check enriched_g_neg_bigconj_mem` evaluate.
- [ ] No new sorries introduced.
- [ ] `lean_profile_proof enriched_g_neg_bigconj_mem` reports < 5s elaboration.

---

### Phase 2: Migrate HintikkaPoint / Construction to EnrichedClosure [COMPLETED]

**Goal**: Replace references to `SubformulaClosure` with `enrichedClosure` across the HintikkaPoint / Construction / Realization API surface, preferring a `ClosureScheme` typeclass if the direct rewrite cascades too broadly.

**Tasks**:
- [ ] Audit uses of `SubformulaClosure` in `HintikkaPoint.lean`, `Construction.lean`, `Realization.lean`, `LocusControl.lean`.
- [ ] **Decision point**: direct rewrite vs typeclass parameterization. Default to typeclass `ClosureScheme` if more than ~6 lemmas are affected.
- [ ] Update `HintikkaPoint Sigma` to quantify over `Sigma := enrichedClosure target` (or remain abstract via typeclass).
- [ ] Re-prove / re-check the `sigma_signature` round-trip with the larger Sigma:
  - [ ] `sigma_signature_mem`: for `f ∈ Sigma`, `f ∈ v.formulas ↔ f ∈ (sigma_signature v Sigma).formulas`.
  - [ ] `locally_maximal`: `∀ f ∈ Sigma, f ∈ h ∨ ¬f ∈ h` (follows from `enriched_neg_pairing`).
- [ ] Re-run all existing Phase 1-3 verifications.
- [ ] **CHECKPOINT GATE A**: if the refactor blast radius exceeds 8h or a non-trivial cascade of new proof obligations emerges, halt and draft plan v4.

**Timing**: 4-8 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (non-chain-related parts only)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (enriched_seed_consistent_until/since lemma preambles only)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` (signature updates only)

**Verification**:
- [ ] `lake build` clean across the Quasimodel subdirectory.
- [ ] Zero new sorries.
- [ ] Phase 1-3 verification tests still pass (sigma_signature round-trip, locally_maximal, seed consistency single-step).
- [ ] Gate A passed: blast radius within 8h budget.

---

### Phase 3: Refined QuasimodelChain Type and Defect-Count Termination [COMPLETED]

**Goal**: Introduce the `QuasimodelChain` type tracking a "target defect" and prove the strict-decrease lemma required for well-founded chain termination.

**Tasks**:
- [ ] In `Construction.lean` (or a new `QuasimodelChain.lean`), define:
  - [ ] `structure QuasimodelChain (Sigma : Finset Formula) (target : Formula × Formula)` carrying: a list of `HintikkaPoint Sigma`, a proof each consecutive pair satisfies `hintikka_step`, and a target Until-defect `(φ, ψ)`.
  - [ ] `chain_last : QuasimodelChain Sigma target -> HintikkaPoint Sigma`.
  - [ ] `chain_witness_reached : QuasimodelChain Sigma (φ,ψ) -> Prop := ψ ∈ (chain_last c).formulas`.
- [ ] Prove `hintikka_step_target_decrease`: for `hintikka_step h1 h2` where `(φ U ψ) ∈ h1` is the target and `ψ ∉ h1`, either `ψ ∈ h2` (witness reached) or the defect set strictly shrinks (use `defect_count h2 < defect_count h1` with the construction picking the target).
- [ ] Prove `hintikka_chain_exists`: by well-founded recursion on `defect_count`, given `(φ U ψ) ∈ h_0` consistent and `¬ψ ∈ h_0`, construct a `QuasimodelChain` ending in an `h_k` with `ψ ∈ h_k.formulas`.
- [ ] Prove the helper lemmas `hintikka_chain_guard` (`φ ∈ h_i` for every interior `i` with `ψ ∉ h_i` — trivial from `hintikka_step` clause 3) and `hintikka_chain_witness` (`ψ ∈ h_k`).
- [ ] Mirror for Since: `hintikka_chain_exists_since`, `hintikka_chain_guard_since`, `hintikka_chain_witness_since`.

**Timing**: 8-14 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` — add `QuasimodelChain`, strict-decrease lemma, chain existence
- (optional) `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/QuasimodelChain.lean` — new file if Construction.lean grows too large

**Verification**:
- [ ] `hintikka_chain_exists` compiles, `#check` returns expected signature.
- [ ] Axiom audit: `lean_verify hintikka_chain_exists` shows only standard Lean axioms.
- [ ] `lake build` clean.

---

### Phase 4: Chain-Step Seed Consistency [NOT STARTED]

**Goal**: Prove `chain_step_seed_consistent` — the Phase 4b obligation from plan v2 — using the EnrichedClosure route.

**Tasks**:
- [ ] State `chain_step_seed_consistent`: for every `i`, the seed `h_{i+1}.formulas ∪ g_content(v_i.formulas)` is Derivation-consistent (and dually for Since).
- [ ] Structure the proof as a contradiction argument following Teammate A §3.3:
  - [ ] Assume finite subsets `L_h ⊆ h_{i+1}.formulas` and `L_g ⊆ g_content(v_i.formulas)` with `L_g ∪ L_h ⊢ ⊥`.
  - [ ] Derive `L_g ⊢ ¬(bigconj L_h)` (classical reasoning in DerivationTree).
  - [ ] Apply `g_content_closed_derivation` to get `G(neg_bigconj L_h.toList) ∈ v_i.formulas`.
  - [ ] By EnrichedClosure membership (Phase 1), `G(neg_bigconj L_h.toList) ∈ Sigma`.
  - [ ] By `sigma_signature_mem` (Phase 2, EnrichedClosure version), `G(neg_bigconj L_h.toList) ∈ h_i.formulas`.
  - [ ] By `hintikka_step` G-clause, `neg_bigconj L_h.toList ∈ h_{i+1}.formulas`.
  - [ ] By `bigconj_intro` on `L_h ⊆ h_{i+1}.formulas`, `bigconj L_h.toList ∈ h_{i+1}.formulas`.
  - [ ] Contradiction with local consistency of `h_{i+1}`.
- [ ] Add supporting lemmas: `bigconj_mem_hintikka`, `neg_bigconj_mem_next_hintikka`, `hintikka_locally_consistent`.
- [ ] Prove the Since dual `chain_step_seed_consistent_since` (replace `g_content`/`G` with `h_content`/`H`).

**Timing**: 8-15 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` — add `chain_step_seed_consistent` and supporting lemmas

**Verification**:
- [ ] `chain_step_seed_consistent` compiles and `lean_verify` shows only standard axioms.
- [ ] Zero new sorries.
- [ ] `lake build` clean.

---

### Phase 5: Realize Full Chain [NOT STARTED]

**Goal**: Turn the Hintikka-level chain from Phase 3 into a BXPoint-level witness chain using the consistency result from Phase 4.

**Tasks**:
- [ ] Prove `realize_chain_step`: given `v_i` with `sigma_signature v_i Sigma = h_i` and `hintikka_step h_i h_{i+1}`, construct `v_{i+1}` via Lindenbaum on the seed from Phase 4, with `bx_le v_i v_{i+1}` and `sigma_signature v_{i+1} Sigma = h_{i+1}`.
- [ ] Prove `realize_full_chain` by induction on the `QuasimodelChain`:
  - [ ] Base case: `v_0 := w` (the given starting BXPoint with `sigma_signature w Sigma = h_0`).
  - [ ] Step case: apply `realize_chain_step` to extend.
  - [ ] Output: `List BXPoint` with `bx_le`-chain between consecutive points and sigma-signatures matching the Hintikka chain.
- [ ] Prove `guard_transfer`: `φ ∈ h_i.formulas → φ ∈ v_i.formulas` (via `sigma_signature_mem`, since `φ ∈ Sigma`).
- [ ] Prove `witness_transfer`: `ψ ∈ h_k.formulas → ψ ∈ v_k.formulas`.
- [ ] Mirror for Since: `realize_full_chain_since`, `guard_transfer_since`, `witness_transfer_since`.
- [ ] **CHECKPOINT GATE B**: if Phase 4/5 gate consistency proof fails to compose, halt and re-scope.

**Timing**: 8-14 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

**Verification**:
- [ ] `realize_full_chain` compiles; axiom audit clean.
- [ ] `guard_transfer` and `witness_transfer` both sorry-free.
- [ ] Gate B passed.

---

### Phase 6: Locus-Control Exhaustiveness [NOT STARTED]

**Goal**: Prove the second hard sub-problem identified by Teammate C — every BXPoint `u` with `bx_le v_0 u ∧ bx_le u v_k` has its sigma-signature projected onto the constructed chain.

**Tasks**:
- [ ] State `locus_control_exhaustive`: given the realized chain `v_0, ..., v_k` and arbitrary `u : BXPoint` with `bx_le v_0 u ∧ bx_le u v_k`, there exists an `i ∈ {0, ..., k}` with `sigma_signature u Sigma = h_i` AND `u` (projected into Sigma) witnesses the same formulas as `v_i`.
- [ ] Proof strategy: show `sigma_signature u Sigma` satisfies `hintikka_step`-reachability from `h_0` within `k` steps; by Phase 3's chain exhaustiveness (the chain visits every reachable intermediate), this signature is some `h_i`.
- [ ] Add helper lemma `hintikka_reachable_in_chain`: every `HintikkaPoint` reachable from `h_0` in `k` `hintikka_step`s that is distinct from `h_k` appears in the chain.
- [ ] If `hintikka_reachable_in_chain` requires strengthening `hintikka_chain_exists` to include all intermediates (not just on the target-defect path), iterate back to Phase 3 — but document the iteration.
- [ ] Update `LocusControl.lean` to expose `locus_control_exhaustive` as the load-bearing lemma consumed by Phase 7.
- [ ] **Fallback**: if the proof exceeds 12h, declare `locus_control_exhaustive` an axiom (clearly marked), document the gap in the task summary, and proceed.

**Timing**: 8-16 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (strengthen chain existence if needed)

**Verification**:
- [ ] `locus_control_exhaustive` compiles (or is cleanly declared an axiom with rationale).
- [ ] `lake build` clean.

---

### Phase 7: Close Realization.lean Sorries (Until and Since) [NOT STARTED]

**Goal**: Replace the six sorries in `Realization.lean` using the infrastructure from phases 3-6.

**Tasks**:
- [ ] **Sorry R1 (Realization.lean:282)** — Until realization consistency branch. Close via `chain_step_seed_consistent` (Phase 4) composed with Phase 5.
- [ ] **Sorry R2 (Realization.lean:286)** — Until realization sigma-signature round-trip. Close via updated `sigma_signature_mem` over EnrichedClosure (Phase 2).
- [ ] **Sorry R3 (Realization.lean:346)** — `until_backward` top-level. Close via `realize_full_chain` (Phase 5) + `locus_control_exhaustive` (Phase 6) + `witness_transfer`.
- [ ] **Sorry R4 (Realization.lean:372)** — Since realization consistency branch. Close via Since-dual of Phase 4.
- [ ] **Sorry R5 (Realization.lean:374)** — Since realization sigma-signature round-trip. Close via EnrichedClosure dual.
- [ ] **Sorry R6 (Realization.lean:404)** — `since_backward` top-level. Close via Since-dual of R3.
- [ ] After each sorry closure, re-run `lake build`.

**Timing**: 6-10 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

**Verification**:
- [ ] Zero sorries remaining in `Realization.lean`.
- [ ] `lean_verify` on each of the six targeted theorems shows only standard axioms (unless Phase 6 declared `locus_control_exhaustive` an axiom).
- [ ] `lake build` clean.

---

### Phase 8: Close Frame.lean Sorries [NOT STARTED]

**Goal**: Replace the four Until/Since sorries in `Frame.lean` using the now-proved Realization.lean lemmas.

**Tasks**:
- [ ] **Sorry F1 (Frame.lean:653)** — `bx_until_eventuality_resolution`. Invoke `until_forward` / `realize_full_chain` directly.
- [ ] **Sorry F2 (Frame.lean:675)** — `bx_until_backward`. Invoke the now-sorry-free `until_backward` (R3).
- [ ] **Sorry F3 (Frame.lean:690)** — `bx_since_eventuality_resolution`. Since dual of F1.
- [ ] **Sorry F4 (Frame.lean:704)** — `bx_since_backward`. Since dual of F2.
- [ ] Confirm Frame.lean lines 140-583 are untouched (the cascade-fragile region).
- [ ] Confirm TruthLemma.lean G/H/Box cases still compile unchanged.
- [ ] Final full-project `lake build`.

**Timing**: 5-12 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (only lines 628-707, i.e., the four sorry theorems)

**Verification**:
- [ ] Zero sorries in Frame.lean for the four targeted theorems.
- [ ] `lake build` clean at the project root.
- [ ] Sorry audit: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns only `Completeness.lean:154` (task 93 scope) and legacy doc-comment references.
- [ ] `lean_verify` on `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward` shows only standard axioms (plus `locus_control_exhaustive` if Phase 6 fell back to axiom).

---

## Testing & Validation

- [ ] `lake build` clean at project root at the end of each phase.
- [ ] Sorry counts monotonically decrease across phases 7-8 (track in phase-complete commit messages).
- [ ] `lean_verify` on every theorem closed in phases 3-8 shows only standard Lean/Mathlib axioms (exception: `locus_control_exhaustive` if Phase 6 uses axiom fallback).
- [ ] `lean_profile_proof` on `enrichedClosure` helper lemmas shows elaboration < 5s each.
- [ ] No new sorries introduced in any file other than the explicit `locus_control_exhaustive` fallback (if triggered).
- [ ] Frame.lean lines 140-583 unchanged (verify with `git diff --stat`).
- [ ] TruthLemma.lean unchanged.

## Artifacts & Outputs

- `specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md` (this file)
- `Theories/Bimodal/Syntax/BigConj.lean` (new) OR updates to an existing Syntax file
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` OR new `EnrichedClosure.lean`
- Updates to `HintikkaPoint.lean`, `Construction.lean`, `Realization.lean`, `LocusControl.lean`
- Updates to `Frame.lean` (4 theorems only, lines 628-707)
- Final implementation summary at `specs/098_research_filtration_quasimodel_pivot/summaries/03_implementation-summary.md`

## Rollback/Contingency

- **Per-phase rollback**: each phase is scoped to a single logical commit; reverting the commit returns the codebase to the prior phase.
- **Gate A failure (end of Phase 2)**: halt, revert Phase 2 commit, and draft plan v4 with a different EnrichedClosure integration strategy (e.g., full typeclass `ClosureScheme` vs direct rewrite).
- **Gate B failure (end of Phase 5)**: halt, keep Phases 1-4 committed (they are independently valuable), and draft plan v4 with a different chain-realization approach.
- **Phase 6 fallback**: declare `locus_control_exhaustive` an axiom with documented rationale; proceed to Phase 7/8; mark task as `[PARTIAL]` in TODO.md with the axiom as a known debt.
- **Total-effort overrun (>98h) after Phase 5**: split Phase 6 (locus-control exhaustiveness) + Phase 7 Since sorries (R4, R5, R6) + Phase 8 Since sorries (F3, F4) into a follow-on task 99 scoped to ~20-30h; complete task 98 with Until direction only.
- **Baseline recovery**: if all else fails, `git reset` to commit `cc49612fb` (task 98: revise plan v2) and mark task 98 as `[BLOCKED]` pending a fresh research round.
