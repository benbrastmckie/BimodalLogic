# Teammate D Findings: Strategic Alignment and Horizons

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Artifact**: reports/05_teammate-d-findings.md
- **Role**: Teammate D - Horizons / Strategic researcher
- **Date**: 2026-04-12

---

## Key Findings

### 1. Current State of the Sorries

Task 102 closed 6 of 10 sorries by delegating the 6 Realization.lean functions directly to the 4 Frame.lean stub theorems. The 4 Frame.lean sorries remain open and are the actual blocking obstacle:

- `Frame.lean:~613` — `bx_until_eventuality_resolution`
- `Frame.lean:~624` — `bx_until_backward`
- `Frame.lean:~636` — `bx_since_eventuality_resolution`
- `Frame.lean:~647` — `bx_since_backward`

The prior research trail is substantial. Two full attempts (plan v4 chain approach, plan v5 direct BX7 approach) have failed at the same structural root cause: the canonical ordering `bx_le` (g_content inclusion) is a preorder but NOT total. BX7/BX11 constrain witness ordering in formula space, not g_content inclusion between BXPoints. There is no axiom-derivable bridge between these two levels.

### 2. Roadmap Context

The roadmap (ROAD_MAP.md) states the project goal is:

> BX completeness and publication

The roadmap lists exactly 6 active-path sorries: the 4 Frame.lean Until/Since sorries, 1 `bx_modal_witness` sorry (Frame.lean:440, owned by task 93), and 1 TaskModel embedding sorry (Completeness.lean:154, owned by task 93). The Until/Since group is the main blocking cluster. Closing these 4 sorries unblocks:

1. The TruthLemma.lean Until/Since cases (which already delegate to Frame.lean)
2. The Completeness.lean final step (which needs TruthLemma)
3. Eventually: the publication milestone

The roadmap also documents a "Burgess-Xu Until-induction technique" as the intended proof path (ROAD_MAP.md lines 311-325), noting that BX5+BX6+BX7+BX10 were supposed to provide the induction. The handoff from v5 (phase5_bx7_blocked.md) shows this belief was falsified: BX7/BX11 do NOT close the gap.

### 3. The Core Mathematical Obstacle

Every approach taken so far eventually hits the same wall:

> `bx_le w u` propagates only G-content (formulas of the form `G(chi)`). The Until eventuality guard requires `phi in u` for intermediate BXPoints u, but `phi` (an arbitrary formula, not necessarily of G-form) does not propagate through `bx_le`.

The standard Burgess 1984 completeness proof constructs a CHAIN-based canonical model (a dovetailed omega-sequence of MCSs), which is TOTALLY ordered. The standard truth lemma for Until works because linearity of the chain makes the guard trivially checkable inductively along the chain. BXCanonical chose a PREORDER-based canonical model (BXPoints with g_content inclusion), which is more general but does not have the linearity needed for the Until truth lemma.

This is not a gap in the BX axiom system — it is a gap between the canonical model ARCHITECTURE and the proof strategy.

### 4. Axiom System Design Assessment

The BX axiom system (37 axioms) is well-designed and appropriate for the project:

- BX1/BX1' correctly encode reflexive T (necessary for `bx_le_refl`)
- BX8/BX8' encode reflexive Until (sound under the current semantics)
- BX9 encodes current-time elimination (correct)
- The system is documented with Burgess 1982/84, Xu 1988, Venema 1993 references

The axiom system is NOT the problem. The problem is that the canonical model construction chosen does not match the proof strategy expected by the axioms.

Specifically: the Until-induction axiom (Burgess 1984) was removed in an earlier refactoring on the assumption that BX5+BX6+BX7 would replace it. That assumption was incorrect for the preorder-based canonical model. It would be correct for a chain-based or quotient-based canonical model.

---

## Strategic Assessment of Each Path

### Path 1: Add Until Induction Axiom Back to BX

**What it is**: Add `G(psi → chi) ∧ G((phi ∧ chi) → G(chi)) → ((phi U psi) → chi)` as a new BX axiom.

**Axiom system design**: This is sound for all linear temporal frames (reflexive or strict). Burgess 1984 included it. Its removal was a bet that BX5+BX6+BX7 could replace it — a bet that has now been experimentally falsified at the canonical model proof level.

**Strategic fit**: MEDIUM. Adding one axiom is a small, local change. However:
- The axiom is derivable from BX1-12 in the INTENDED models (all linear temporal frames), so adding it does not extend the logic — it adds proof-theoretic redundancy.
- The redundancy is not principled: BX5+BX6+BX7 should jointly imply Until-induction modulo Burgess's original proof. If they don't, either the axioms are incomplete (unlikely given the design) or the canonical model's logic for extracting induction from BX7 has not been found yet.
- Adding Until-induction enables a direct MCS-level proof of `bx_until_eventuality_resolution` because: from `phi U psi in w`, `G(phi)` would follow from the induction schema instantiated with `chi = phi U psi`, and `G(phi)` propagates through `bx_le`.
- **Soundness proof cost**: The axiom is sound on the project's frame class (linear temporal orders with S5 modal equivalence). Soundness can be proved by direct semantic argument. Estimated effort: 2-4h.
- **Downstream effects**: Positive. Soundness proofs for the new axiom are straightforward. No existing proofs break. The completeness proof gets a shorter path.
- **Publication impact**: Minor negative — it slightly weakens the claim that BX5+BX6 replace Until-induction. A note in the paper explaining the choice would suffice.

**Assessment**: Low-risk, fast (estimated 8-12h total to close all 4 sorries), high confidence (85%+). Best choice if speed matters.

### Path 2: Build Chain-Based Completeness Bypass

**What it is**: Bypass `bx_le`-based eventuality reasoning by constructing a chain of BXPoints (totally ordered, omega-sequence) that realises the Until formulas, proving the truth lemma on the chain.

**Strategic fit**: LOW for the current codebase. The v4 plan (Phases 5-8) attempted this and was abandoned due to two structural obstacles documented in report 09 (phase5-blocker-resolution.md):
1. Strict seed inconsistency when G-formulas fall outside enriched Sigma
2. G-formula non-persistence through Hintikka chains

These obstacles are genuine and arise from the architectural mismatch between the BXPoint abstraction (which projects to finite Sigma) and the MCS-level commitment (which has full formula sets). A chain bypasses the Frame.lean sorries only if the chain has total order — but constructing such a chain from BXPoints requires resolving the same G-propagation issue.

**The dovetail alternative**: Burgess 1984 uses a dovetailed omega-chain directly on MCSs (not BXPoints). This approach would bypass the Hintikka/BXPoint abstraction entirely. But `DovetailedChain.lean` already exists in the legacy codebase (ROAD_MAP.md lists it with ~29 sorries in the legacy strict-semantics architecture). Adapting it to reflexive semantics is a substantial effort.

**Downstream effects**: This path fundamentally changes the canonical model architecture away from BXPoint/BXCanonical. It undermines the work done in Phases 1-4b (EnrichedClosure, HintikkaPoint, Construction) and the existing TruthLemma.lean/Completeness.lean structure.

**Assessment**: High-risk, high-cost (estimated 60-80h). Not recommended unless the project wants to restructure around a chain-based proof.

### Path 3: Restructure bx_le to Be Total on Relevant Intervals

**What it is**: Redefine `bx_le` using Until-witness ordering instead of g_content inclusion, making it total on the intervals needed by the truth lemma.

**Strategic fit**: VERY LOW. Report 09 rates this LOW feasibility with catastrophic impact on completed phases. All of Frame.lean and downstream consumers depend on `bx_le = g_content subseteq`. The impact is not incremental — it requires rebuilding the canonical model from scratch.

**Assessment**: Not viable. Would require 60-80h and invalidate Phases 1-4b.

---

## The Quasimodel Pivot Context

Task 98 (parent to task 102) is the "quasimodel pivot." Its v5 plan (plans/05_quasimodel-pivot-plan.md) proposes the direct BX7 approach (Phase 5), which was subsequently attempted and blocked (summaries/10_v5-implementation-summary.md). The v5 plan's Phase 9 contingency is the quotient/filtration approach.

**Quotient/filtration (Phase 9 contingency)**: Define equivalence classes on BXPoints by Sigma-agreement, work in the finite quotient where the ordering is total. This is the approach recommended by summaries/10_v5-implementation-summary.md and report 09. Estimated 40-60h, 85% confidence.

**Strategic position**: The quasimodel pivot was intended to find a path to completeness that avoids the chain construction. The pivot succeeded in building EnrichedClosure, HintikkaPoint, and enriched-seed consistency infrastructure (Phases 1-4b), but the direct BX7 approach that was supposed to close the Frame.lean sorries is blocked. The pivot is now at a decision point:

- Continue on the quotient/filtration path (the intended contingency): substantial effort, high confidence
- Or take a shorter path (Until-induction axiom) and complete the original BXCanonical architecture

The quasimodel pivot's long-term value was to establish a FINITE model, which has advantages for decidability proofs (finite models are easier to reason about computationally). The quotient/filtration approach preserves this advantage. The Until-induction path completes the INFINITE BXPoint canonical model, which is simpler for completeness but less directly useful for decidability.

---

## Creative Alternatives

### Alternative A: Prove Until-Induction is Derivable from BX1-12

The ROAD_MAP (lines 311-325) states the "Burgess-Xu Until-induction technique" should work via BX5+BX6+BX7+BX10. The handoffs say "currently believed to be non-derivable" for the full schema. However:

- The full schema `G(psi → chi) ∧ G((phi ∧ chi) → G(chi)) → ((phi U psi) → chi)` is quite general.
- The SPECIFIC instances needed by the truth lemma are more constrained: `chi` is always `phi in u` for particular `u` in the canonical model, not an arbitrary formula.
- It is worth 3-4 hours of careful mathematical investigation to determine if the specific induction instances (not the full schema) are derivable from BX5+BX6+BX7 at the MCS level. If they are, this closes the gap without adding a new axiom.

**Why this is promising**: The handoffs note `enriched_seed_with_G_phi_inconsistent` was proved — this shows the combination `{neg(phi U psi), G(phi)} union g_content(w)` is inconsistent. This is essentially one direction of Until induction (if G(phi) holds, phi U psi follows). The missing piece is deriving G(phi) from the Until formula's guard. A focused proof search for this derivation could succeed.

### Alternative B: Two-Phase Separation (Frame.lean → Quotient/Filtration)

Rather than choosing between "add axiom" and "build quotient," consider:
1. **Phase A** (2-4h): Add Until-induction as a temporary axiom, marked with a clear TODO comment.
2. **Phase B** (40-60h, new task): Build the quotient/filtration model, then prove Until-induction is derivable from BX1-12 in the quotient, then remove the temporary axiom.

This unblocks the completeness milestone NOW while the deeper architectural work proceeds. The temporary axiom is explicitly scoped, not a permanent debt.

**Risk**: The "temporary" axiom might become permanent if the follow-up task is deprioritized. Mitigate by making it a condition of Phase A that the follow-up task is CREATED and PLANNED before merging.

### Alternative C: Adopt the Quotient Model as the Canonical Model Architecture

The quotient/filtration approach (Path 3 from report 09) constructs a FINITE quotient where the ordering is total. This is the "right" architecture for a logic that aims at decidability and model checking. Instead of treating the quotient as a bypass, treat it as the INTENDED canonical model:

- Replace the infinite BXPoint model with the finite quotient model as the primary completeness witness.
- TruthLemma.lean and Completeness.lean are restructured around the quotient.
- The Until truth lemma becomes straightforward because the quotient is totally ordered.
- The EnrichedClosure, HintikkaPoint, Construction infrastructure (Phases 1-4b) feeds INTO the quotient construction (it builds the quotient points).

This is the most architecturally principled option and aligns best with the quasimodel pivot's original intent. It is also the highest-cost short-term option (40-60h for a new task), but it produces a canonical model that supports future decidability work directly.

---

## Recommended Direction

**Primary recommendation: Add Until-Induction axiom (Path 1) to close the immediate 4 sorries, then spawn a new task for the quotient model as a follow-up.**

**Rationale**:

1. **Immediacy**: The completeness milestone is blocked. The paper cannot be written until completeness is proved. Adding Until-induction is a 8-12h path to unblocking this milestone at high confidence (85%+).

2. **Soundness is certain**: Until-induction is sound on all linear temporal frames. There is no correctness risk from adding it — only a proof-theoretic elegance tradeoff.

3. **The axiom belongs in BX**: Burgess 1984 included it. Its removal was a refactoring bet that failed. Restoring it corrects the refactoring error. The axiom system becomes more faithful to the reference literature.

4. **Quotient/filtration is the right long-term path**: The quasimodel pivot was intended to produce a finite model with decidability implications. That vision is still valid and should be pursued — but as a separate task after the completeness milestone is cleared. The quotient model can be built independently of BXCanonical and can serve as an alternative completeness proof (which also validates the axiom system).

5. **Strategic coherence**: The project has two parallel goals: (a) establish completeness, and (b) build infrastructure for decidability. The Until-induction axiom serves goal (a). The quotient/filtration model serves goal (b). These are compatible and can proceed in parallel once (a) is unblocked.

**Against adding Until-induction permanently**: If the team believes BX1-12 should be minimal and self-contained, the axiom should be marked as a NAMED intermediate result with a proof-obligation to derive it from BX1-12 in the quotient model. This preserves the axiom-system design goal while unblocking progress.

**Concrete next step**: Before adding the axiom, invest 3-4h in Alternative A above: check whether the specific induction instances needed by the Frame.lean sorries are derivable from BX5+BX6+BX7+BX11 at the MCS level. The `enriched_seed_with_G_phi_inconsistent` result (from the v5 handoff) may be the key stepping stone. If this succeeds, no new axiom is needed.

---

## Downstream Effects Assessment

| Effect | Path 1 (Add axiom) | Path 2 (Chain bypass) | Path 3 (Restructure bx_le) | Alt C (Quotient as primary) |
|--------|-------------------|-----------------------|---------------------------|------------------------------|
| Completeness milestone | Unblocked (8-12h) | Unblocked (60-80h) | Unblocked (60-80h) | Unblocked (40-60h) |
| Decidability work | No help (infinite model) | No help | No help | Strong support (finite model) |
| Existing phases 1-4b | Preserved | Partially obsoleted | Fully invalidated | Consumed as input |
| Axiom system purity | Minor reduction | No change | No change | No change |
| TruthLemma.lean | No change needed | Major rewrite | Major rewrite | Moderate rewrite |
| Publication impact | Note required | New section required | Architectural rewrite required | New construction described |

---

## Confidence Level

**High** on the strategic assessment. The mathematical obstacles are well-documented across 5 rounds of research. The structural root cause (bx_le non-totality vs. Until truth lemma requirements) is clear and verified.

**Medium** on the Until-induction specific instances (Alternative A): the mathematical possibility exists but has not been formally verified. The `enriched_seed_with_G_phi_inconsistent` lemma is suggestive but not conclusive.

**High** on the quotient/filtration approach as a long-term solution: this is a well-understood construction from the literature (Goldblatt 1992, Blackburn et al. 2001) with 85% confidence per report 09.

---

## Summary of Key Recommendations

1. **Invest 3-4h** checking whether Until-induction instances are derivable from BX1-12 at the MCS level (using `enriched_seed_with_G_phi_inconsistent` as a stepping stone). This is the lowest-risk path and avoids adding any new axiom.

2. **If (1) fails, add Until-induction axiom** to the BX system. It is sound, belongs in Burgess's original system, and unblocks completeness in 8-12h. Mark it with a proof obligation to derive from BX1-12 in the quotient model.

3. **Spawn a new task** for the quotient/filtration model construction, regardless of which path closes the 4 Frame.lean sorries. This serves the decidability and model-checking goals of the quasimodel pivot.

4. **Do not attempt** to restructure bx_le (Path 3) or rebuild the chain construction (Path 2). The cost-benefit ratio is unfavorable given the alternatives.
