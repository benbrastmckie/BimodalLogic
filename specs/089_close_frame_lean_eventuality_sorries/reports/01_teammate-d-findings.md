# Teammate D Findings: Strategic Horizons

**Task**: #89 - Close 4 Frame.lean eventuality resolution sorries
**Role**: Strategic Horizons
**Date**: 2026-04-10

---

## Key Findings

### Finding 1: BXCanonical is a THIRD completeness path, not the primary one

The project has three parallel completeness architectures:

| Path | Module | Key Sorry Count | Status |
|------|--------|-----------------|--------|
| Path A (bypassed) | Completeness.lean (original) | ~39 | Legacy, abandoned |
| Path B (active) | FrameConditions/Completeness.lean via UltrafilterChain | 2 key sorries + ~12 Until/Since step transfer | **Primary path** (task 83/85/58) |
| Path C (BXCanonical) | BXCanonical/ | 4 Frame.lean + 1 Completeness.lean | **Task 89 target** |

The ROAD_MAP.md is unambiguous: Path B is the active path for the representation theorem. Task 89 targets Path C, which is architecturally independent. The BXCanonical module is not wired into `completeness_over_Int` -- it has its own separate `bx_completeness` theorem that requires a separate TaskModel embedding (sorry at Completeness.lean:154).

**Critical observation**: Even if all 4 Frame.lean sorries were closed, the BXCanonical path would still need:
1. A TaskModel embedding (Completeness.lean:154 sorry) -- converting BXPoints + bx_le into a concrete TaskModel over some D
2. The truth lemma connected to that TaskModel (not just the abstract MCS-level truth properties)

The 4 Frame.lean sorries are necessary but NOT sufficient for BXCanonical completeness.

### Finding 2: The X-vs-G mismatch is real but might be solvable by re-adding temp_linearity

Task 88 research (round 1, 4 teammates, 95% confidence) established that the BX axiom system is incomplete for linear time. The missing `temp_linearity` axiom (`F(phi) AND F(psi) -> F(phi AND psi) OR F(phi AND F(psi)) OR F(F(phi) AND psi)`) was present in the original system, is semantically valid (proved sorry-free in Soundness.lean:285), and its removal was identified as a mathematical error.

If `temp_linearity` were re-added:
- `bx_le` becomes provably linear (total order on BXPoints)
- All 4 Frame.lean sorries become closable via standard canonical model techniques
- The CanonicalEmbedding (deleted in task 88) would also have been closable

However, task 88 was completed by DELETING CanonicalEmbedding.lean rather than re-adding axioms, and task 89 was created as a separate item. The axiom re-addition recommendation from task 88 research was not acted upon.

### Finding 3: The FrameConditions path has the SAME Until/Since blocker, but worse

FrameConditions/Completeness.lean contains approximately 54 occurrences of "sorry" (counting comments and code). The actual sorry sites include:

- 3x `forward_until_since_coherent` (bundle, restricted, dovetailed paths)
- 6x step transfer sorries for backward Until/Since
- 1x `bfmcs_from_mcs_temporally_coherent`
- 1x `dense_completeness_fc`

The Until/Since coherence problem appears in BOTH Path B and Path C:
- **Path B**: Needs `forward_until_since_coherent` + backward step transfer for each of 3 completeness variants
- **Path C (BXCanonical)**: Needs `bx_until_eventuality_resolution` + `bx_until_backward` (and Since mirrors)

These are mathematically isomorphic problems: given `(phi U psi) in MCS w`, find a witness v where psi holds with phi guarding the interval. The BXCanonical version is slightly cleaner because it works directly with BXPoints and bx_le rather than through the SuccChain machinery.

### Finding 4: Task 87 and task 89 address the same mathematical problem from different angles

Task 87 ("Full representation theorem with Until/Since via enriched chain construction in Bundle/") is listed as NOT STARTED, depends on task 86, and targets the Bundle path. Task 89 targets BXCanonical. Both face the same Until/Since eventuality resolution challenge.

The key difference: Task 87 proposes an enriched chain with dovetailed scheduling over subformula closure (estimated 600-1000 LOC). Task 89 proposes quasimodel or Henkin fair scheduling (estimated 40-80h). Both are heavy investments targeting the same mathematical obstacle.

### Finding 5: The dovetailed path has sorry-free forward_F/backward_P but NOT Until/Since coherence

FrameConditions/Completeness.lean:468-498 shows `dovetailed_bundle_validity_implies_provability` which has sorry-free restricted temporal coherence (forward_F and backward_P). However, it STILL has sorry'd `forward_until_since_coherent` and backward step transfer. This means:

- The F/P eventuality resolution is SOLVED in the dovetailed path
- Only Until/Since forward and backward coherence remains sorry'd
- This is the same gap that task 89 targets for BXCanonical

### Finding 6: Publication readiness analysis

**Minimal publishable result**: The project already has a strong partial result:
- Sorry-free restricted truth lemma
- Sorry-free modal completeness (boxClassFamilies_modal_backward)
- Sorry-free G/H forward and backward
- Sorry-free canonical model construction
- Sorry-free completeness STRUCTURE (gap isolated to Until/Since coherence only)

A publication claiming "completeness of TM for the Until/Since-free fragment" (G, H, Box, atom, bot, imp) could be made with ZERO additional sorry closures. The BXCanonical module's `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` are all sorry-free and constitute a complete truth lemma for this fragment.

For full Until/Since completeness, the minimal sorry closure needed is:
1. Re-add `temp_linearity` axiom (or prove bx_le linearity another way)
2. Close the 4 Frame.lean eventuality sorries
3. Build the TaskModel embedding
4. Wire bx_completeness or close the Bundle path's Until/Since coherence

Options (1)+(2)+(3)+(4) is 40-80h. Alternatively, closing just the Bundle path's Until/Since coherence (tasks 85+87) is 40-60h but doesn't help BXCanonical at all.

## Strategic Recommendations

### 1. Do NOT invest 40-80h in BXCanonical (task 89) as currently scoped

**Rationale**: BXCanonical is Path C -- a third, independent completeness approach. Closing its 4 Frame.lean sorries does NOT advance the primary completeness goal (Path B via FrameConditions/Completeness.lean). The same 40-80h invested in task 87 (enriched chain in Bundle/) would directly advance the representation theorem.

### 2. INSTEAD: Re-add temp_linearity axiom and close BOTH paths simultaneously

The task 88 research finding that `temp_linearity` was erroneously removed is the single most actionable insight. Re-adding it:
- Takes ~2-4h (add constructor to Axiom inductive, add soundness case, update pattern matches)
- Unblocks the 4 Frame.lean sorries (BXCanonical, task 89)
- May also unblock the Bundle path's Until/Since coherence by making bx_le linear
- Is mathematically correct (semantically valid, present in every standard axiomatization)

**This transforms task 89 from 40-80h to 8-16h.**

### 3. If temp_linearity is NOT re-added, deprioritize task 89 entirely

Without the axiom fix, both BXCanonical and Bundle face the same mathematical wall. Investing in task 89 without this prerequisite is throwing effort at a problem proven to be intractable with the current axiom system (95% confidence from task 88 research).

### 4. Consider a fragment completeness publication first

A paper establishing completeness for TM without Until/Since (i.e., S5 + G + H over linear time) could be produced with near-zero additional work. The BXCanonical module already has sorry-free truth lemma for this fragment. This would be a genuine contribution (no prior Lean formalization of tense logic completeness exists per task 88 research).

## Cross-Task Opportunities

### BXCanonical truth lemma techniques are reusable for Path B

The BXCanonical module has clean, sorry-free proofs of:
- `g_content_closed_derivation`: generalized temporal necessitation for MCS
- `bx_G_forward/backward`, `bx_H_forward/backward`: G/H truth lemma (both directions)
- `bx_modal_witness`: diamond witness construction for S5
- `F_from_witness`, `P_from_witness`: F/P from ordering witnesses

These techniques could inform the Bundle path's approach to Until/Since. In particular, `F_from_witness` (TruthLemma.lean:226-247) shows a clean pattern: contradict G(neg psi) using bx_le to derive F(psi). This pattern should transfer to the SuccChain setting.

### temp_linearity benefits both paths

If `temp_linearity` is added:
- **BXCanonical**: bx_le becomes linear -> 4 Frame.lean sorries closable
- **Bundle/SuccChain**: The SuccChain already builds linear chains, but `succ_chain_restricted_forward_F` needs to resolve F-obligations. With temp_linearity providing linearity of the canonical ordering, the fair-scheduling argument for F-resolution becomes tractable (you can argue that in a linear order, F(psi) in deferralClosure must eventually resolve by pigeonhole over the finite closure)

### Closing task 82 (FMP, 2 sorries) is higher ROI than task 89

Task 82 needs just 2 sorries closed (`mcs_all_future_closure` and `mcs_all_past_closure` in TruthPreservation.lean) and provides weak completeness through the finite model property. This is an independent result with publication value. Estimated effort: 1-2 hours. Compare with task 89's 40-80 hours.

## Creative Alternatives

### Alternative 1: Redefine bx_le using Until-based ordering

Instead of `bx_le w v := g_content(w) subseteq v.formulas`, define:
```
bx_le w v := forall phi psi, (phi U psi) in w -> exists chain from w to v resolving all Until obligations
```
BX7 directly gives linearity for this ordering. The difficulty: this definition is non-trivially equivalent to the current one, and the G/H truth lemma depends on the g_content definition.

**Verdict**: Possible but requires redesigning Frame.lean from scratch. Not recommended without temp_linearity.

### Alternative 2: FMP-based completeness avoids canonical model entirely

The FMP path (task 82) establishes `not provable -> falsifiable in finite model`. This gives completeness WITHOUT building a canonical model. However, the ROAD_MAP explicitly states: "Decidability-based completeness is explicitly excluded as a path to the representation theorem." So this is not an option for the primary goal.

### Alternative 3: Completeness-via-FMP bridge

Even though FMP alone is excluded, a bridge theorem `fmp_completeness -> representation_theorem` could work if the finite model can be embedded into a canonical-style structure. Task 88 research (round 1, section 10 of ROAD_MAP dead ends) explicitly rejects this: "The FMP module is valuable for decidability but does NOT provide a shortcut to completeness."

### Alternative 4: Quasimodel construction (GHR 1994)

Replace the canonical model with a quasimodel that resolves eventualities by construction. This avoids bx_le linearity entirely because the model is BUILT to satisfy Until/Since. Task 83 report 24 found linearization issues. Task 89 proposes this as viable.

**Assessment**: This is the strongest alternative if temp_linearity is not added. Estimated 50% confidence, 2000 LOC. It would provide a complete, self-contained proof but at enormous cost.

### Alternative 5: Add new axioms beyond temp_linearity

The system could add `F_until_equiv: F(phi) <-> top U phi` which directly bridges F-reasoning to Until-reasoning. This was also present in the original system and removed during the BX refactoring. With this axiom, the Until eventuality resolution reduces to F-resolution, which the dovetailed path already handles sorry-free.

**This is potentially the highest-impact creative alternative**: if `F_until_equiv` is added, then `bx_until_eventuality_resolution` reduces to `bx_forward_witness` (already sorry-free) + guard verification (which becomes tractable with linear bx_le from temp_linearity). The Until problem literally reduces to the solved F problem.

## Confidence Level

| Assessment | Confidence |
|-----------|-----------|
| BXCanonical is not on the primary completeness path | 98% -- ROAD_MAP is explicit |
| temp_linearity re-addition would unblock the 4 Frame.lean sorries | 90% -- consistent with task 88 research (95%) minus execution risk |
| Investing 40-80h in task 89 without temp_linearity is poor ROI | 95% -- 40+ research rounds have failed at this exact wall |
| Fragment completeness (no Until/Since) is publishable with near-zero work | 85% -- depends on whether a TaskModel embedding can be built for the fragment |
| The Until/Since coherence problem is mathematically isomorphic across all 3 paths | 90% -- the core challenge (fair scheduling over eventualities) is identical |
| Task 82 (FMP, 2 sorries) is higher ROI than task 89 | 95% -- 1-2h vs 40-80h, independent publication value |

**Overall recommendation**: The single highest-impact action for the project is to re-add `temp_linearity` (and optionally `F_until_equiv`) as axioms. This is a 2-4 hour task that unblocks 40-80h of work across both BXCanonical and Bundle paths. Task 89 should be rephrased as "close 4 Frame.lean sorries AFTER axiom restoration" with a revised estimate of 8-16 hours.
