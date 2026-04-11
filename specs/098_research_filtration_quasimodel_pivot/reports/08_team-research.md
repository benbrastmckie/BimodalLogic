# Research Report: Task #98 Phase 4 Architectural Gap Resolution

**Task**: 98 — research_filtration_quasimodel_pivot
**Round**: 4 (Phase 4 gap resolution)
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1775873649_08b347

---

## Summary

The Phase 4 blocker is real: `chain_step_seed_consistent` cannot be proved against the current `HintikkaPoint` abstraction because a pairwise `locally_consistent` field does not imply the derivation-level consistency needed for Teammate A (round 3)'s §3.3 contradiction chain. Four independent investigation angles converged on two structurally viable paths and one strategic off-ramp:

1. **Option 4a (Teammate B, recommended)**: Back `HintikkaStepOracle` with a concrete `BXPoint` at chain-construction time. Because `SetConsistent` is "every finite subset consistent" and MCS subsets are trivially consistent, the Phase 4 lemma collapses to a one-line subset witness. **Estimate: 6-10h. Zero-debt compliant.**
2. **Option 2' (Teammate A, refined Option 2)**: Quantify `Sigma := enrichedClosure target` explicitly, close the final contradiction at `sigma_signature` level instead of `h_{i+1}` level, using infrastructure already in-tree. **Estimate: 10-15h. Zero-debt compliant.**
3. **Descope / spin-off task 99 (Teammate D)**: Trigger plan v3's own rollback clause (Gate B failure, line 361), commit Phases 1-3, and open a narrowly scoped task 99 for direct `BXPoint`-level chain construction. Unblock tasks 93 and 94 immediately in parallel.

**Teammate C (Critic)** contributed independent blockers that all three paths must address: (a) Phase 5 `realize_chain_step` has a stricter unstated consistency obligation; (b) Phase 6 locus-control exhaustiveness is independently hard and plan v3's "fall back to axiom" clause violates zero-debt policy; (c) realistic effort for Phases 4-8 is 70-135h, not 52-98h.

**Lead recommendation**: Adopt a **hybrid of Option 4a and Teammate D's strategic descope**. Specifically: (i) transition task 98 to `[BLOCKED]` at the current Phase 4 partial checkpoint, (ii) spawn **task 99** targeted specifically at Option 4a (BXPoint-backed HintikkaStepOracle + concrete Phase 4 reduction, 6-10h budget), (iii) unblock tasks 93 and 94 for immediate parallel work, (iv) revise plan v3's Phase 6 axiom-fallback clause before any implementation session touches Phase 6. Do **not** attempt further Phase 4 work under plan v3 as written.

---

## Key Findings

### Primary Approach (Teammate A) — Option 2' refinement

Teammate A identifies the summary's Option 2 wording as unprovable in full generality ("Hintikka points are not MCSs and do not have closure under derivation") and proposes **Option 2'**: close the final contradiction at `sigma_signature v_i` level, not `h_{i+1}` level. Rationale:

- Every ingredient is already landed: `enrichedClosure`, `enriched_g_neg_bigconj_mem`, `enriched_h_neg_bigconj_mem`, `enriched_neg_of_core_mem` (Phase 1); `bigconj_intro`, `bigconj_mem_iff` (Phase 4 scaffolding).
- No type changes required to `HintikkaPoint` / `hintikka_step` / `sigma_signature`.
- The chain-step lemma takes an enrichment hypothesis `h_enriched : ∀ T ⊆ Sigma, G(neg_bigconj T.toList) ∈ Sigma`, discharged at call-site by `enriched_g_neg_bigconj_mem`.
- `Sigma` must be explicitly specialized to `enrichedClosure target`.

Teammate A's Lean sketch routes the contradiction through `g_content_closed_derivation` (forcing `G(neg_bigconj L_h) ∈ v_i.formulas`) then the `sigma_signature` round-trip (forcing it into `h_i.formulas`) then the `hintikka_step` G-clause (forcing `neg_bigconj L_h ∈ h_{i+1}.formulas`).

**Unresolved in Teammate A's sketch**: the final-step wrapper lemma that bridges the pairwise `locally_consistent` field to the derivation-level statement `[bigconj L_h] ⊢ ⊥ → False`. Teammate A acknowledges this wrapper is needed but does not produce its proof. Teammate C identifies this wrapper as the structural crux (§C.2 below).

**Confidence**: medium-high. **Estimate**: 10-15h for Phase 4 alone, 25-40h with Phase 5.

---

### Alternative Approaches (Teammate B) — Option 4a: MCS-backed oracle

Teammate B rejects all three summary options in favor of a **new Option 4a**: tie `HintikkaStepOracle` to a backing `BXPoint` at chain-construction time, not post-hoc. Key insights:

- `SetConsistent` in the codebase is defined as "every finite subset is consistent" (Core/README.md:50-51), so any subset of an MCS is trivially consistent.
- The Phase 4 seed consistency lemma collapses to a one-line subset witness into `w.is_mcs.1`, **exactly as `enriched_seed_consistent_until` (Realization.lean:226-276) already does** in its `h_neg_in = false` branch.
- The structural root cause of the Phase 4 gap is that `HintikkaStepOracle` (Construction.lean:452) is existential over arbitrary `HintikkaPoint Sigma` with **no MCS backing**. Phase 3's output type is too weak to support Phase 4's reduction.
- `bx_forward_witness` (Frame.lean:164) already produces both the next BXPoint and its `bx_le` witness. Threading this through `hintikka_chain_exists` is structurally simple.
- **Prior art verdict**: no published completeness proof (Burgess, Xu, Verbrugge, Goldblatt, Lichtenstein-Pnueli, Reynolds, LIPIcs.ITP.2024.28) attempts the combination Phase 4 currently attempts. They all avoid the gap by either (a) never mixing MCS data into seeds or (b) never constructing MCSes. The round-3 reduction has no template in the literature.

**Open risk** (Teammate B flagged): the defect-decrease oracle branch should be prototyped on one step before full commitment. 75% confidence.

**Estimate**: 6-10h for Phase 4. **Zero-debt compliant**.

---

### Gaps and Shortcomings (Teammate C, Critic)

Teammate C's critique substantially narrows the solution space. Principal findings:

**C.1 — Assumption B unflagged**: Teammate A's §3.3 reduction (round 3) requires `bigconj L_h ∈ h_{i+1}.formulas` for the final contradiction, but `HintikkaPoint` is **not closed under conjunction introduction at the set level**. `bigconj_intro` is a `DerivationTree` combinator (`L ⊢ bigconj L`), not a membership rule. This invalidates **Options 1 and 2 as originally framed**, and resurfaces inside Option 3's projection step.

*Note (lead)*: Teammate A's refinement to Option 2' routes around C.1 by deriving the contradiction at the `v_i.formulas` derivation level (where conjunction introduction is valid via `DerivationTree`) rather than at the `h_{i+1}` membership level. But A's final wrapper lemma still asks `locally_consistent` to yield a derivation-level fact, which is exactly C.1's objection in a different place. **This conflict is not cleanly resolved.**

**C.2 — EnrichedClosure scope mismatch**: `enriched_g_neg_bigconj_mem` is stated over `T ⊆ SubformulaClosure target`, not `T ⊆ enrichedClosure target`. For the `L_h ⊆ h_{i+1}.formulas ⊆ enrichedClosure` case, the hypothesis does not discharge. **Impact**: Teammate A's Option 2' sketch needs a second Phase 1 scaffolding tweak (generalize `enriched_g_neg_bigconj_mem` to arbitrary `T ⊆ enrichedClosure target`). Small delta (~2h), but it means Option 2' is not as "infrastructure-complete" as A claims.

**C.3 — Option 3 has its own gaps**:
  (a) Until-persistence in the Lindenbaum seed is a separate consistency obligation.
  (b) `bx_forward_witness` gives one hop, not arbitrary-length guard propagation.
  (c) The locus-control gap relocates rather than disappears.
  (d) The `hintikka_step` projection needs an Until-persistence clause that BX does not prove without enriched seeds.

*Note (lead)*: C.3's critique of Option 3 partially applies to Teammate B's Option 4a (which is a refined Option 3). However, Option 4a's key differentiator — threading the BXPoint witness *inside* `HintikkaStepOracle` rather than rebuilding the chain at BXPoint level — sidesteps (a) and (b) by reusing the already-landed Phase 3 chain construction. Option 4a still inherits (c) and (d), which become Phase 5/6 obligations.

**C.4 — Phase 5 is independently blocked**: `realize_chain_step` needs the seed
```
h_{i+1}.formulas ∪ g_content(v_i) ∪ {¬f | f ∈ Sigma \ h_{i+1}}
```
to force `sigma_signature v_{i+1} = h_{i+1}`. This is a stricter consistency obligation than `chain_step_seed_consistent` and is **not addressed anywhere in plan v3**. Any Phase 4 resolution that doesn't also unblock Phase 5 is a mirage.

**C.5 — Phase 6 is independently blocked**: Locus-control exhaustiveness requires the chain to span every reachable HintikkaPoint in Sigma-signature space. Phase 3's `hintikka_chain_exists` builds a *target-defect path*, not a *spanning chain*. Plan v3 Phase 6's "fallback to axiom" clause **violates the Zero-Debt Policy** and must be revised.

**C.6 — Correct architectural move**: Fuse Phase 3 and Phase 5 so the chain is realized-as-it-is-built. Carry an MCS-backing witness inside `QuasimodelChain`. *This is structurally Teammate B's Option 4a.* The current Phase 3 → Phase 5 decomposition is the wrong shape because it tries to prove a consistency property at a level of abstraction where the property is not true.

**C.7 — Effort honesty**: Plan v3's 52-98h estimate is optimistic by ~30%. Realistic bound for Phases 4-8 with zero-debt compliance: **70-135h**.

**Confidence**: High (90%) on C.1 and C.5 being independent blockers. Medium (70%) that Option 3+4 fusion is the viable path. Low (40%) on whether Frame.lean guard weakening could bypass locus control entirely (worth a dedicated sub-investigation).

---

### Strategic Horizons (Teammate D)

Teammate D frames the choice in trajectory terms:

**Trajectory A (continue plan v3 as-is)**: Effort 70-135h per Teammate C, probability of success 40-60%, delivers 10 sorries closed.

**Trajectory B (recommended)**: Transition task 98 to `[BLOCKED]` at current Phase 4 partial checkpoint, **spawn task 99** for direct BXPoint chain construction (Option 3/4a unification). Estimated 8-15h for task 99. Unblocks the 4 Frame.lean Until/Since sorries on a much shorter path. Tasks 93 and 94 start **immediately in parallel** (they are logically independent of the Until/Since sorries despite ROAD_MAP sequencing convention).

**Trajectory C (axiomatize)**: Rejected by zero-debt policy. Listed only for completeness.

**Trajectory D (strengthen precondition, not postcondition)**: Reformulate `chain_step_seed_consistent` so its precondition is "HintikkaPoints of BXPoint origin" (i.e., carry the BXPoint witness at the type level, not as a hypothesis). This is structurally equivalent to Teammate B's Option 4a and confirms the convergence.

**Trajectory E (publication fallback)**: Modal fragment completeness (G/H/Box without Until/Since) via task 93 alone delivers a genuine publishable intermediate result in weeks, not months. If task 99 stalls, this is a clean scoping decision that preserves the work.

**Core diagnosis**: The exponential-discovery spiral (round 2 guard propagation, round 3 defect-count termination, round 4 `locally_consistent` vs finite-MCS-consistent) is a signal that the **Hintikka-chain problem formulation is wrong**, not that the proofs are wrong. Patching the formulation builds debt faster than it closes sorries.

**Confidence**: 90% on descope recommendation and parallel-work opportunities; 60-70% on Trajectory B cost estimate and TaskModel semantic-bypass viability.

---

## Synthesis

### Conflicts Resolved

**Conflict 1 — Is Option 2' (Teammate A) viable without type changes?**

*Teammate A*: Yes, infrastructure already landed, 10-15h.
*Teammate C*: No, Assumption B (C.1) blocks the final wrapper lemma, and C.2 exposes a scope mismatch in `enriched_g_neg_bigconj_mem`.

**Resolution**: Partial. Teammate A's routing through `sigma_signature` does sidestep the direct form of C.1, but the final wrapper lemma still lives in the gap C.1 identifies. The C.2 scope fix is cheap (~2h). **Verdict: Option 2' is not dead, but it is not "shovel-ready" either — it requires a detailed proof of the final wrapper lemma whose existence is unproven.** Treat A's estimate as a lower bound.

**Conflict 2 — Is Option 3 clean (Teammate A says no, Teammate D says yes)?**

*Teammate A*: Option 3 runs into `bx_le` non-totality and is not cleaner, just relocates the difficulty.
*Teammate D*: Option 3 is "the cleanest mathematically" (citing the Phase 4 summary).

**Resolution**: Both are correct about different framings. Pure Option 3 (rebuild chain at BXPoint level from scratch) has the problems Teammate A describes. **Option 4a** (Teammate B's refinement — thread BXPoint witness through existing `HintikkaStepOracle`) is a narrower scope that avoids the rebuild while capturing Option 3's benefits. This is the convergent path.

**Conflict 3 — Continue task 98 or descope?**

*Teammates A, B, C*: Continue with structural refinement (different paths).
*Teammate D*: Descope to `[BLOCKED]`, spawn task 99 for a narrowly scoped fix.

**Resolution**: These are compatible if task 99 *is* the Option 4a implementation. Teammate D's strategic framing and Teammate B's technical proposal are the same decision viewed from different angles. **Combined recommendation**: spin off task 99 with Option 4a as its explicit scope, commit Phases 1-3 of task 98, put task 98 on `[BLOCKED]` pending task 99 completion.

**Conflict 4 — Is Phase 6 axiom-fallback acceptable?**

*Plan v3*: Yes, as an escape hatch.
*Teammate C*: No, zero-debt policy violation.

**Resolution**: Teammate C is correct per zero-debt policy. Plan v3 must be revised before any Phase 6 work begins.

### Gaps Identified

1. **The final wrapper lemma in Option 2'** (Teammate A's sketch §3) has not been proved or shown provable. This is the actual load-bearing open problem.
2. **Phase 5 `realize_chain_step` consistency obligation** (C.4) is not addressed by any of the three summary options or by Option 4a. Any chosen path must include a Phase 5 consistency plan.
3. **Phase 6 locus-control exhaustiveness** (C.5) remains independently hard. None of the proposed resolutions address it. Plan v3 must be revised.
4. **Until-persistence in the Lindenbaum seed** (C.3a) is a separate consistency obligation that Option 3 / Option 4a must handle.

### Recommendations

**Primary recommendation** (high confidence):

1. **Transition task 98 to `[BLOCKED]`** at the Phase 4 partial checkpoint. Preserve the commits (Phases 1-3 complete, Phase 4 scaffolding). Do not attempt further Phase 4 work under plan v3.
2. **Spawn task 99** with scope: "Implement Option 4a — thread `BXPoint` witness through `HintikkaStepOracle` at chain-construction time. Prove `chain_step_seed_consistent` via MCS subset witness (`w.is_mcs.1`). Effort budget: 10-15h (B's 6-10h + C.2 scope fix buffer)."
3. **Immediately unblock tasks 93 and 94** for parallel work. They are logically independent of the Until/Since sorries. Task 93 (Box sorry + TaskModel embedding) may expose a semantic-bypass path that makes Until/Since sorries trivial via frame correspondence, further justifying descope.
4. **Before any Phase 5/6 implementation session**, revise plan v3 to (a) remove Phase 6's axiom-fallback clause (zero-debt violation per C.5), (b) add an explicit Phase 5 consistency-obligation plan addressing C.4, (c) adjust effort estimates to 70-135h per C.7.

**Fallback trajectory** (if task 99 stalls at >15h without convergence):
- Invoke Teammate D's Trajectory E: pursue modal-fragment completeness (G/H/Box only) via tasks 93 + 95 as a publishable intermediate milestone. Accept the 4 Frame.lean Until/Since sorries as a documented limitation, not as axioms.

**Do NOT**:
- Continue Phase 4 under plan v3 as written. Teammate C's critique (C.1, C.4, C.5) makes this a high-risk path.
- Axiomatize `chain_step_seed_consistent` or `locus_control_exhaustive`. Zero-debt violation.
- Attempt Option 3 (rebuild chain at BXPoint level) without first implementing Option 4a's narrower scope.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (Option 2') | completed | medium-high | Refined Option 2 via `sigma_signature`-level contradiction; concrete Lean sketch |
| B | Alternatives (Option 4a) | completed | medium-high (75%) | New Option 4a: BXPoint-backed `HintikkaStepOracle`; prior-art gap analysis |
| C | Critic | completed | high (90% on blockers) | Assumption B (C.1), Phase 5/6 independent blockers (C.4, C.5), zero-debt flag (C.5) |
| D | Horizons | completed | 90% / 60-70% | Strategic descope, task 99 spin-off, parallel unblock of 93/94, Trajectory E fallback |

---

## References

- specs/098_research_filtration_quasimodel_pivot/summaries/07_phase4-summary.md (current blocker documentation)
- specs/098_research_filtration_quasimodel_pivot/summaries/06_phase3-completion-summary.md
- specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-a-findings.md (round 3 §3.3 reduction being critiqued)
- specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-c-findings.md (round 3 locus-control critique)
- specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-d-findings.md (round 3 strategic framing)
- specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md (plan v3)
- Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean
- Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean (HintikkaStepOracle, hintikka_chain_exists)
- Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean (bigconj_intro, bigconj_mem_iff, enriched_seed_consistent_until)
- Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean
- Theories/Bimodal/Metalogic/BXCanonical/Frame.lean (bx_forward_witness)
- Burgess 1984, Goldblatt 1992, Verbrugge, LIPIcs.ITP.2024.28 (prior art; no template for combined MCS-Hintikka approach)
