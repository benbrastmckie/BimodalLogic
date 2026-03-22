# Teammate D Findings: Codebase and Vault Archive Analysis

**Task**: 33 - expand_design_choices_reflexive_analysis
**Date**: 2026-03-22
**Session**: sess_1774212234_48e1ac
**Focus**: Prior attempts and lessons learned — codebase and vault archive analysis

---

## Key Findings

1. **The project has switched between strict and reflexive semantics four times**. The current state (Task 29 in progress) is a return to reflexive semantics (`<=`).

2. **The original switch to reflexive (Task 658, 2026-01-28) was mathematically necessary**: independent Lindenbaum extensions for the indexed family approach cannot be proven coherent without the T-axiom local constraint. This was not a proof convenience — it was a mathematical impossibility under strict semantics.

3. **The reversion to strict semantics (Task 991, 2026-03-18) was motivated by frame class separation concerns** and has a concrete cost: the `canonicalR_irreflexive` theorem became unprovable under strict semantics, because Step 7 of the Gabbay IRR proof requires the T-axiom (`H(¬p) → ¬p`) which is invalid under strict semantics.

4. **The current codebase has an active inconsistency**: `canonicalR_irreflexive_axiom` is a Lean `axiom` (not proven theorem) and is FALSE under the reflexive semantics now in Truth.lean. Reports from Task 29 Wave 2 count 25+ active call sites using this false axiom.

5. **FMCS coherence conditions are documented as reflexive (≤) but were partially reverted to strict (<) by Task 991**. The Task 29 plan lists fixing this as a required change.

6. **IRR soundness has a residual sorry** (`IRRSoundness.lean` line 322) introduced by the Task 29 switch to reflexive semantics. Under reflexive semantics, the antecedent `p ∧ H(¬p)` is unsatisfiable (since `H(¬p)` includes the present, contradicting `p`), requiring the IRR soundness proof to be fundamentally redesigned.

7. **Frame class collapse is a real architectural consequence of reflexive semantics**: All four extension axioms (DN, DF, SF, SP) become trivially valid on any linear order, collapsing the three-variant (Base/Dense/Discrete) architecture to one.

---

## Historical Timeline (Semantic Switches)

| Date | Task | Switch | Direction | Primary Motivation |
|------|------|--------|-----------|-------------------|
| 2025-12-01 | (initial) | — | Reflexive (`<=`) | Project inception |
| 2026-01-18 | Task 571 | — | Blocked | `closure_mcs_implies_locally_consistent` needs temporal reflexivity |
| 2026-01-28 | Task 658 | Strict → Reflexive | Reflexive (`<=`) | Independent Lindenbaum extensions cannot be proven coherent without T-axiom |
| 2026-03-09 | Task 956 | Reflexive → Strict | Strict (`<`) | Perceived density proof obstruction (later shown unfounded by Task 967) |
| 2026-03-14 | Task 967 | Strict → Reflexive | Reflexive (`<=`) | Density concern shown unfounded; T-axiom needed for Gabbay IRR proof |
| 2026-03-18 | Task 991 | Reflexive → Strict | Strict (`<`) | Frame class separation motivation |
| 2026-03-21 | Task 29 | Strict → Reflexive | Reflexive (`<=`) | IRR proof broken under strict; theoretical analysis recommends reflexive |

**Net result**: The project has orbited reflexive semantics as the natural home, with two excursions into strict semantics — both ultimately reversed.

---

## Lessons from Prior Attempts

### Lesson 1: The Coherence Impossibility (Task 658 — the decisive finding)

The most important lesson is from Task 658 (2026-01-28). Under strict semantics, the indexed family construction builds MCS at each time point via independent Lindenbaum extensions:

```
mcs(0) = extendToMCS(Gamma)
mcs(t > 0) = extendToMCS(future_seed(Gamma))   -- {phi | G phi in Gamma}
mcs(t < 0) = extendToMCS(past_seed(Gamma))      -- {phi | H phi in Gamma}
```

**The impossibility**: Different calls to `extendToMCS` make independent, non-deterministic choices. Without a local constraint connecting `G phi in mcs(t)` to `phi in mcs(t)`, coherence between time points cannot be proven — not because the proof is hard, but because the statement is false in general.

**The T-axiom solution**: `G phi → phi` provides the required local constraint. If `G phi in mcs(t)`, then `phi in mcs(t)` by deductive closure. This makes coherence conditions (forward_G, backward_H) trivially provable.

**Lesson**: Strict semantics is incompatible with the indexed family approach to completeness unless an alternative construction is used (relational approach estimated 16-24 hours; coordinated Lindenbaum estimated 40+ hours with uncertain achievability).

### Lesson 2: The Density Proof Non-Problem (Task 956 → Task 967)

Task 956 (2026-03-09) switched to strict semantics based on concern that density proofs would be harder under reflexive semantics: "between w₁ ≤ w₂, there may be no STRICTLY intermediate point when w₁ = w₂."

Task 967 (2026-03-14) showed this concern was unfounded: the density axiom DN (`GGφ → Gφ`) operates on strict ordering BETWEEN distinct MCSs. Whether temporal operators use `≤` or `<` is independent of whether a distinct MCS M'' exists between M and M'.

**Lesson**: The strict/reflexive choice for temporal operators is orthogonal to the existence of intermediate elements in the canonical model. Do not conflate the semantics of the operators with the structure of the canonical timeline.

### Lesson 3: The Gabbay IRR Freshness Failure (Task 967)

Under strict semantics, the Gabbay IRR proof for canonical irreflexivity requires a fresh atom `p` not appearing in `atoms(g_content(M))`. With `String` atoms, this fails because every string appears in tautologies — there is no truly "fresh" string.

Under reflexive semantics, the T-axiom approach (Step 7: "Apply T-axiom: `H(¬p) → ¬p`") eliminates the freshness requirement entirely.

**Lesson**: The Gabbay IRR proof for `canonicalR_irreflexive` requires the T-axiom, which is valid only under reflexive semantics. The theorem cannot be proven under strict semantics with the current atom type.

### Lesson 4: Frame Class Collapse is a Feature, Not a Bug (Task 991 → Task 29)

Task 991 identified that reflexive semantics causes DN, DF, SF, SP to become trivially valid, collapsing the three-variant architecture. It treated this as a reason to revert to strict semantics.

Task 29 research reframes this: the frame class collapse is an **architectural simplification**, not a mathematical problem. Three completeness theorems become one. The canonical model construction actually becomes easier, not harder.

**Lesson**: Frame class collapse is a trade-off. It loses the ability to axiomatically distinguish dense from discrete from base frames, but simplifies the completeness proof architecture. Whether this is acceptable depends on the project's goals.

### Lesson 5: The IRR Soundness Proof Requires Redesign (Task 29 — current)

Task 29 changed Truth.lean to reflexive semantics but left a `sorry` in `IRRSoundness.lean` at the antecedent construction step. Under reflexive semantics, the antecedent `p ∧ H(¬p)` becomes semantically contradictory (since `H(¬p)` at `t` includes `t ≤ t`, giving `¬p` at `t`, contradicting `p`). The "first moment" construction that makes the antecedent satisfiable under strict semantics fails under reflexive semantics.

**Lesson**: The IRR soundness proof for dense frames depends critically on strict semantics. Under reflexive semantics, the IRR rule's antecedent is unsatisfiable, which trivializes the soundness proof in the wrong direction — the premise is vacuously true but the proof structure breaks.

---

## Current Implementation State

### Truth.lean (Reflexive — Correct)

`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` lines 124-125:
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```
Status: **Reflexive semantics correctly implemented.** The module docstring documents this as Task 29's change.

### Axioms.lean (T-axioms Added)

`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`:
- 21 total axioms listed in docstring (was 19)
- `temp_t_future` and `temp_t_past` are included as base axioms
- Comment notes these are valid under reflexive semantics (Task 29)
- Status: **T-axioms present.** The docstring still has an old Task 991 note saying they are NOT included — this is a documentation inconsistency.

### FMCSDef.lean (Reflexive — Correct)

`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`:
```lean
forward_G : forall t t' phi, t ≤ t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
backward_H : forall t t' phi, t' ≤ t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```
Status: **Reflexive (≤) coherence conditions.** The FMCS structure is correct for reflexive semantics.

### CanonicalIrreflexivityAxiom.lean (Paradoxical State)

`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`:
- Documents `canonicalR_irreflexive` as a "proven theorem" using the T-axiom approach
- References `CanonicalIrreflexivity.lean` for the proof
- Under reflexive semantics, `CanonicalR M M` holds (by T-axiom), so `¬CanonicalR M M` is FALSE
- Status: **The axiom is inconsistent with reflexive semantics.** The module documents the Gabbay IRR proof, which establishes irreflexivity under the old system. Under reflexive semantics, the canonical relation IS reflexive (that's the point), and the proof machinery needs to use antisymmetry/quotient structure instead.

### canonicalR_irreflexive_axiom (FALSE Lean axiom)

Referenced in 25+ active call sites. Task 29 Phase 5 enumeration report (07_enumeration.md) catalogs all 35 sites with replacement strategies (all using `canonicalR_antisymmetric`).
Status: **Must be removed.** The axiom is false under reflexive semantics.

### IRRSoundness.lean (One Sorry)

`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/IRRSoundness.lean` line 322:
```lean
  sorry  -- TASK 29 NOTE: The IRR rule proof needs redesign for reflexive semantics.
```
The comment explains that under reflexive semantics, the antecedent `(p ∧ H(¬p))` is unsatisfiable.
Status: **Open research problem.** The IRR rule soundness proof requires fundamental redesign under reflexive semantics.

### Soundness.lean (Several Sorries)

Active sorries in `Soundness.lean`:
- Lines 573, 577, 580, 583: Frame-class extension axioms (density, discreteness_forward, seriality) — these become trivially provable under reflexive semantics but the proofs haven't been updated
- Line 603: `temporal_duality` — component proofs exist in SoundnessLemmas.lean but not assembled
- Line 606: IRR rule soundness — awaits IRRSoundness.lean resolution
- Line 688: Non-domain case in `soundness_dense_valid` — semantic gap for non-full-domain histories

---

## Vault Archive Discoveries

### Task 730: Investigate Reflexive Semantics Motivation (2026-01-28)

**Location**: `specs/vault/01-vault/archive/730_investigate_reflexive_semantics_motivation/`

**Finding**: The reflexive semantics switch (Task 658) was investigated for legitimacy. Conclusion: the switch was **well-motivated and necessary** — the indexed family construction faced a mathematical impossibility, not just a proof difficulty. The primary motivation was solving forward coherence conditions (forward_G, backward_H) needed for the representation theorem, NOT the backwards Truth Lemma (which is not needed for completeness).

Key alternatives analyzed and rejected:
| Option | Effort | Outcome |
|--------|--------|---------|
| Add T axioms (reflexive) | 730-1080 LOC | Coherence trivial |
| Relational approach | 16-24 hours | Still has compositionality gaps |
| Coordinated Lindenbaum | 40+ hours | "Uncertain if achievable" |

### Task 957: Density Frame Condition Under Irreflexive Semantics (2026-03-10)

**Location**: `specs/vault/01-vault/archive/957_density_frame_condition_irreflexive_temporal/`

**Finding**: Under strict (irreflexive) semantics, the density frame condition IS provable without importing an external dense order. The proof uses Case A (G(delta) not in M) which always exists by contradiction from Case B impossibility. The backward direction uses canonical linearity.

**Significance for Task 33**: This is evidence that strict semantics can support density proofs — the "density proof obstruction" argument that motivated both reverts to strict is genuinely unfounded. Strict semantics does not block density.

### Task 958: CanonicalR Irreflexivity via IRR Rule (2026-03-10)

**Location**: `specs/vault/01-vault/archive/958_prove_canonicalr_irreflexive_irr_rule/`

**Finding**: Under strict semantics, `CanonicalR M M` means `GContent(M) ⊆ M`, i.e., all G-formulas in M have their arguments in M (the T-axiom property). The research analyzed three proof strategies:

- Strategy A (direct from axioms): Gets complicated; seriality/density don't directly give contradiction
- Strategy B (via IRR rule): Conceptually sound but circular — requires T-axiom to apply IRR
- Strategy C (axioms alone): Serial + density approach circular

**Finding**: The theorem is not provable under strict semantics without the T-axiom. This confirms that reflexive semantics is required for the Gabbay IRR approach.

**Note in ROAD_MAP.md**: "Task 958 (CanonicalIrreflexivity): Confirmed UNUSED and UNPROVABLE with String atoms. Irreflexivity is obtained for free via strict `<` on CanonicalMCS preorder; the standalone `canonicalR_irreflexive` theorem is not needed." This represents Task 956's approach — using strict ordering on the quotient — which circumvents the need for the theorem.

### Task 962: Dense Timeline Strict Intermediate Reflexive Source (2026-03-13)

**Location**: `specs/vault/01-vault/archive/962_dense_timeline_strict_intermediate_reflexive_source/`

**Finding**: Under strict semantics, the `density_frame_condition` function has a Case B1 bug where the intermediate MCS can be the endpoint itself when M' is reflexive (i.e., `CanonicalR M' M'`). The fix uses `density_frame_condition_reflexive_source` which guarantees strictness when the SOURCE is reflexive.

**Why reflexive source helps**: When `CanonicalR M M`, Case B (G(delta) in M with delta not in M) is impossible because `G(delta) in M` and M reflexive implies `delta in M` — contradiction. So only Case A applies, which always gives a strictly intermediate witness.

**Significance for Task 33**: This reveals an interesting asymmetry — even under a generally strict-semantics framework, handling reflexive MCSes (those that happen to satisfy `CanonicalR M M`) requires special cases. Under reflexive semantics, ALL MCSes are reflexive, which eliminates these special cases at the cost of losing strict ordering.

### Task 801: Document Soundness temp_t Axiom Validity Issue (2026-02-02)

**Location**: `specs/vault/01-vault/archive/801_document_soundness_temp_t_axiom_validity/`

**Finding**: Task 658's switch to reflexive semantics left sorries in SoundnessLemmas.lean and Soundness.lean where proofs were written for strict semantics but the truth definition used reflexive. Under reflexive semantics, the temp_t axiom sorries are trivially provable (just update `<` to `≤`). These were "code synchronization issues, not fundamental semantic problems."

**Significance**: Demonstrates the pattern of semantic switch → code/proof desynchronization that has occurred multiple times. The current state (post-Task 29) likely has similar desynchronization.

---

## Task 29 Summary

### Decision Made (Research Phase)

Task 29 decided to switch back to reflexive semantics based on:
1. **IRR proof broken under strict**: The Gabbay IRR proof requires the T-axiom at Step 7, which is invalid under strict semantics. Multiple resolution attempts (temp_a + linearity, seriality fallback) all failed. Van Benthem non-definability theorem confirms irreflexivity is not modally definable — no axiomatic approach can prove it under strict semantics.
2. **Theoretical analysis**: Reflexive semantics offers proof-theoretic simplicity in exchange for loss of frame-definability expressiveness. For TM's goals (completeness for linear temporal reasoning), reflexive is preferable.
3. **Frame class collapse acceptable**: The three-variant structure (Base/Dense/Discrete) collapsing to one is an architectural simplification, not a mathematical problem.

### Current Implementation State (Plan v2)

The revised plan (02_reflexive-semantics-revised.md) has 8 phases:
- **Phase 0**: Enumeration and pattern catalog — **COMPLETED** (07_enumeration.md)
- **Phase 1**: Core semantic change (Truth.lean, T-axioms) — **COMPLETED** (semantic change done; T-axioms in Axioms.lean)
- **Phase 2**: FMCS coherence conditions (< → ≤) — Status unclear
- **Phase 3**: Soundness proof repairs — **IN PROGRESS** (IRRSoundness.lean has sorry)
- **Phase 4**: Truth lemma backward G/H direction — Status unclear
- **Phase 5**: Replace all 35 `canonicalR_irreflexive` call sites — **PENDING**
- **Phase 6**: Axiom assessment and proof — **PENDING**
- **Phase 7**: Frame class simplification — **PENDING**

### Trade-offs Identified

**In favor of reflexive**:
- T-axioms definitionally valid → canonical irreflexivity provable without fresh atom trick
- FMCS coherence conditions provable (mathematical necessity, not convenience)
- Single completeness theorem replaces three
- Aligns with existing ROAD_MAP.md documentation

**Against reflexive (reasons prior switches to strict)**:
- Frame class collapse: DN, DF, SF, SP trivially valid → three logics become one
- IRR rule soundness requires fundamental redesign under reflexive semantics
- Standard temporal logic literature predominantly uses strict semantics
- `CanonicalR M M` is TRUE → 35+ proof sites must be rearchitected

---

## Evidence/References

| Source | Location | Content |
|--------|----------|---------|
| Task 730 report | `specs/vault/01-vault/archive/730_investigate_reflexive_semantics_motivation/reports/research-001.md` | Full analysis of original reflexive switch motivation |
| Task 957 report | `specs/vault/01-vault/archive/957_density_frame_condition_irreflexive_temporal/reports/research-001.md` | Density frame condition under strict semantics |
| Task 958 report | `specs/vault/01-vault/archive/958_prove_canonicalr_irreflexive_irr_rule/reports/research-001.md` | Irreflexivity unprovable under strict without T-axiom |
| Task 962 report | `specs/vault/01-vault/archive/962_dense_timeline_strict_intermediate_reflexive_source/reports/research-001.md` | Reflexive-source density lemma under strict semantics |
| Task 801 report | `specs/vault/01-vault/archive/801_document_soundness_temp_t_axiom_validity/reports/research-001.md` | Desynchronization after semantic switch |
| Task 29 team research (Wave 1) | `specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md` | Key consequences of reflexive switch |
| Task 29 historical analysis | `specs/029_switch_to_reflexive_gh_semantics/reports/02_historical-issues-analysis.md` | Complete timeline and issue assessment |
| Task 29 theoretical analysis | `specs/029_switch_to_reflexive_gh_semantics/reports/06_theoretical-analysis.md` | Mathematical foundations comparison |
| Task 29 enumeration | `specs/029_switch_to_reflexive_gh_semantics/reports/07_enumeration.md` | All 35 call sites and replacement strategies |
| Task 29 Wave 2 | `specs/029_switch_to_reflexive_gh_semantics/reports/05_team-research.md` | Task ordering, blast radius, axiom gap |
| Task 29 plan v2 | `specs/029_switch_to_reflexive_gh_semantics/plans/02_reflexive-semantics-revised.md` | Current implementation plan |
| Truth.lean | `Theories/Bimodal/Semantics/Truth.lean` | Current reflexive semantics definition |
| Axioms.lean | `Theories/Bimodal/ProofSystem/Axioms.lean` | 21 axioms including T-axioms |
| FMCSDef.lean | `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` | Reflexive coherence conditions |
| IRRSoundness.lean | `Theories/Bimodal/Metalogic/IRRSoundness.lean` | Sorry at line 322 |
| Soundness.lean | `Theories/Bimodal/Metalogic/Soundness.lean` | 6 sorries related to frame/IRR |
| ROAD_MAP.md | `specs/ROAD_MAP.md` | Decision: Reflexive G/H Semantics (Revised) at line 245 |

---

## Confidence Level

**HIGH** for:
- Historical timeline of semantic switches (multiple corroborating sources)
- Primary motivation for original reflexive switch (Task 658 — mathematical impossibility)
- Current implementation state (Truth.lean, FMCSDef.lean, Axioms.lean verified by direct reading)
- Call site inventory (35 sites, enumerated in 07_enumeration.md)
- IRRSoundness.lean sorry and its cause (directly read the code and comment)

**MEDIUM** for:
- Task 29 implementation phase status (plan says Phase 0-1 completed based on report existence and code state, but full phase status not explicitly verified)
- Whether the IRR soundness sorry is a fundamental blocker or has a known solution path

**LOW** for:
- Exact count of remaining sorries across all files (comprehensive grep would be needed)
- Whether Phase 2-7 of Task 29 plan have any partial progress
