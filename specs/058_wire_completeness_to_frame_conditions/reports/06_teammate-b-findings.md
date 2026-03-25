# Teammate B: Task Frame Implementation Analysis

**Task**: 58 - Wire completeness to FrameConditions
**Date**: 2026-03-25
**Focus**: How the current codebase handles Task Frame vs algebraic structures

---

## Key Findings

- The Task Frame is a two-place relation `task_rel : WorldState -> D -> WorldState -> Prop`, NOT a three-place relation `D x D x W`. The "three-place" description in the delegation brief refers to two world-states plus a duration, not two durations plus a world.
- `FrameConditions/Completeness.lean` does NOT exist in the codebase yet. It is the target file to be created. The three sorries referenced in the plan are in a file that must be authored.
- The canonical construction (`CanonicalTaskTaskFrame` in `SuccChainTaskFrame.lean`) uses `WorldState = Set Formula` and `task_rel = CanonicalTask` (an Int-indexed Succ-chain relation). This is fully sorry-free.
- The parametric construction (`ParametricCanonicalTaskFrame D` in `ParametricCanonical.lean`) uses `WorldState = ParametricCanonicalWorldState` (MCS subtypes) and `task_rel = parametric_canonical_task_rel` (sign-based ExistsTask). This is also sorry-free.
- The ONLY gap blocking all three target completeness theorems is a sorry-free `construct_bfmcs`. The existing `construct_bfmcs` in `UltrafilterChain.lean` is deprecated with `sorry` due to a mathematically FALSE supporting theorem (`f_nesting_is_bounded`).
- The truth lemma infrastructure is sorry-free for the BFMCS path (`parametric_canonical_truth_lemma` in `ParametricTruthLemma.lean`). The sorry in `succ_chain_truth_lemma` is a DIFFERENT sorry (box backward in singleton-Omega, intentionally left as documentation).

---

## Codebase Analysis

### Current Task Frame Structure

The Task Frame is defined in `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

The structure has `task_rel w d u` meaning "world `u` is reachable from world `w` by a task of duration `d`". This is a two-world, one-duration relation -- it contains the semantics of the full three-place relation from the paper (which uses two time-points and one world-state) via the transformation `d = t - s`.

**World History uses task_rel at `d = t - s`**: In `WorldHistory.lean`, the `respects_task` field states:
```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

This is where the connection to the paper's three-place semantics `R(t1, t2, w)` lives: the duration is `t - s` (not an independent argument). The convexity constraint ensures no temporal gaps in the domain.

### Canonical Construction Review

**CanonicalTaskTaskFrame** (`Bundle/SuccChainTaskFrame.lean`):
- `WorldState = Set Formula` (maximal consistent sets)
- `task_rel = CanonicalTask : Set Formula -> Int -> Set Formula -> Prop`
- `CanonicalTask u n v` = "v is reachable from u in exactly n steps" (positive = forward Succ chain, negative = backward Succ chain)
- All three TaskFrame axioms proven sorry-free from `CanonicalTask_nullity_identity`, `CanonicalTask_forward_comp_int`, `CanonicalTask_converse`

**ParametricCanonicalTaskFrame D** (`Algebraic/ParametricCanonical.lean`):
- `WorldState = ParametricCanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }`
- `task_rel = parametric_canonical_task_rel` which uses sign-based dispatch:
  - `d > 0`: `ExistsTask M.val N.val` (g_content M ⊆ N)
  - `d = 0`: `M = N`
  - `d < 0`: `ExistsTask N.val M.val` (converse)
- All three TaskFrame axioms proven sorry-free

**ExistsTask** (`Bundle/CanonicalFrame.lean`):
```lean
def ExistsTask (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```
This is the canonical forward accessibility relation (g_content M = all G-images in M must hold in M').

**WorldHistory construction** (`Bundle/SuccChainWorldHistory.lean`):
- `succ_chain_history M0 : WorldHistory CanonicalTaskTaskFrame`
- Domain = `fun _ => True` (full Int domain)
- States at time t = `succ_chain_fam M0 t`
- `respects_task` proven via `succ_chain_canonical_task` (sorry-free)

### The Real Gap

The three target sorries are in the file `Theories/Bimodal/Semantics/FrameConditions/Completeness.lean` which does NOT exist yet. From the plan, this file will contain:

1. `dense_completeness_fc` (line 108): completeness for dense temporal models
2. `discrete_completeness_fc` (line 151): completeness for discrete temporal models
3. `completeness_over_Int` (line 170): completeness over Int directly

All three reduce to calling `parametric_algebraic_representation_conditional` from `ParametricRepresentation.lean`, which has signature:

```lean
theorem parametric_algebraic_representation_conditional
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (h_not_prov : ¬Nonempty (DerivationTree [] φ)) :
    ∃ fam ∈ B.families, ∃ t : D, ¬truth_at ... (parametric_to_history fam) t φ
```

This theorem is **sorry-free**. The gap is that to CALL it, you must provide a temporally coherent BFMCS. The existing `construct_bfmcs` is deprecated and uses `sorry` through:

```
construct_bfmcs -> boxClassFamilies_temporally_coherent -> SuccChainTemporalCoherent
    -> succ_chain_forward_F -> f_nesting_boundary -> f_nesting_is_bounded (MATHEMATICALLY FALSE)
```

**`f_nesting_is_bounded` is mathematically FALSE**: The claim is that every MCS has bounded F-nesting depth. This fails because the MCS `{F^n(p) | n : Nat}` is finitely consistent (witnessed by the integers with p at position n) and thus extends to an MCS with unbounded F-nesting.

The sorry in `SuccChainTruth.lean` (box backward in singleton-Omega) is a SEPARATE issue that is intentionally documented and does NOT affect the BFMCS path. The comment at that sorry explicitly states: "For sorry-free completeness, use `semantic_weak_completeness` or the algebraic path (Algebraic/ParametricRepresentation.lean)."

### Current SuccChainFMCS Sorry Status

In `Bundle/SuccChainFMCS.lean`, three sorries block the Strategy C (restricted chain) approach:

1. **Line 1435** (`neg_not_in_boundary_resolution_set`): "The lemma may not be provable."
2. **Line 1480** (`augmented_seed_consistent`): Depends on unproven consistency argument
3. **Line 1543** (`constrained_successor_seed_restricted_consistent`): The key blocker; requires showing boundary_resolution_set elements don't create contradictions with ALL seed components

Additionally, `restricted_bounded_witness` at line 2380-2405 uses `sorry` for termination.

The current `boundary_resolution_set` definition (post v1 fix, per Phase 1 handoff) is:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | Formula.some_future psi in u and
         Formula.some_future (Formula.some_future psi) not_in (deferralClosure phi : Set Formula)}
```

The `chi in u` condition was already removed in Phase 1 partial work. But the consistency proof (sorries 1, 2, 3) remains.

---

## Existing Bridges

**Bridge 1: SuccChainWorldHistory -> CanonicalTaskTaskFrame**
`succ_chain_history` converts an FMCS (Succ-chain) into a `WorldHistory CanonicalTaskTaskFrame`. The `respects_task` proof uses `succ_chain_canonical_task`, which shows adjacent chain positions satisfy `CanonicalTask` (the Int-indexed Succ-chain traversal relation). This bridge is complete and sorry-free.

**Bridge 2: FMCS -> BFMCS**
`boxClassFamilies` in `UltrafilterChain.lean` constructs a BFMCS from an MCS by bundling all Succ-chain families that agree on box-content with M0. The `modal_forward` and `modal_backward` properties are proven via `boxClassFamilies_modal_backward` (sorry-free at line 1783). Only the `temporally_coherent` property is sorry-blocked (via the false `f_nesting_is_bounded`).

**Bridge 3: parametric_to_history (FMCS -> WorldHistory)**
`parametric_to_history fam : WorldHistory (ParametricCanonicalTaskFrame D)` converts an FMCS family into a WorldHistory over the parametric canonical frame. This bridge is sorry-free and used by the truth lemma.

**Bridge 4: parametric_canonical_truth_lemma (MCS membership <-> semantic truth)**
This is the main algebraic bridge. It converts MCS membership into semantic truth in the parametric canonical model. It is sorry-free and handles all formula constructors including box (via BFMCS modal_backward/forward).

---

## Recommended Approach

Based on the codebase analysis, there are two viable paths:

### Path A: Strategy A (Ultrafilter F-witness, ~600 LOC)

Use the sorry-free algebraic infrastructure in `UltrafilterChain.lean` and `UltrafilterMCS.lean` to build a sorry-free `construct_bfmcs`:

1. Prove `ultrafilter_F_witness`: if F(psi) in ultrafilter U, then exists V with R_G(U,V) and psi in V. This uses the filter extension argument: B = {a | G(a) in U} union {psi} generates a proper filter because F(psi) in U means neg(G(neg psi)) in U, preventing inconsistency.

2. Build `UltrafilterChain`: Int-indexed ultrafilter chain via iterated F-witness (forward) and P-witness via sigma duality (backward).

3. Convert to FMCS via `ultrafilterToMcs`, prove temporal coherence from the chain construction.

4. Assemble into BFMCS using existing `boxClassFamilies` infrastructure.

**Key insight**: This approach never needs `f_nesting_is_bounded` because ultrafilter completeness handles temporal coherence directly. The filter extension argument is the standard Jonsson-Tarski technique.

**Existing sorry-free support**:
- `STSA` typeclass on `LindenbaumAlg` (TenseS5Algebra.lean)
- `mcsToUltrafilter`/`ultrafilterToMcs` bijection (UltrafilterMCS.lean, sorry-free)
- `R_G_refl`, `R_G_trans` (UltrafilterChain.lean, sorry-free)
- `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1783, sorry-free)
- `sigma_quot` temporal duality automorphism (LindenbaumQuotient.lean, sorry-free)
- `parametric_algebraic_representation_conditional` (ParametricRepresentation.lean, sorry-free)
- `parametric_canonical_truth_lemma` (ParametricTruthLemma.lean, sorry-free)

### Path B: Strategy C (Restricted Chain, ~800 LOC)

Continue the current Phase 1 partial work: prove the three consistency sorries (lines 1435, 1480, 1543) and the termination sorry (2380-2405) in SuccChainFMCS.lean.

**The key consistency argument** (for the three sorries):
- `neg_not_in_g_content_when_F_in_u`: F(psi) in MCS u implies neg(psi) not in g_content(u). Proof: F(psi) = neg(G(neg psi)), so by MCS consistency, G(neg psi) not in u, so neg(psi) not in g_content(u).
- Use this to show `boundary_resolution_set` elements don't conflict with g_content, deferralDisjunctions, or p_step_blocking components.

**Risk**: The comment at line 1434 says "The lemma may not be provable." This is a warning flag. The consistency argument across all 4 seed components may require more careful case analysis than currently visible.

**Recommendation**: Path A (Strategy A) is recommended because it avoids the problematic consistency proofs entirely and uses well-understood algebraic techniques. The infrastructure is largely in place.

---

## Confidence Level

**High** for the overall picture:
- The Task Frame structure is well-understood: `task_rel w d u` with `respects_task` at `d = t - s`
- The gap is precisely identified: sorry-free `construct_bfmcs` is the sole missing piece
- The `FrameConditions/Completeness.lean` file does not exist yet; it must be created
- The three target sorries are in a target FILE, not in existing proofs (they will be authored)
- The sorry in `SuccChainTruth.lean` is a separate issue on a different completeness path

**Medium** for the recommended implementation path:
- Path A (Strategy A) has a clear mathematical argument but requires ~600 LOC of new development
- The filter extension argument is standard, but the Lean 4 ultrafilter API may have friction
- The parametric representation infrastructure is confirmed sorry-free but untested end-to-end

---

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` - Task Frame definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory with respects_task
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - truth_at definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - ExistsTask, canonical relations
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - CanonicalTask Int-indexed relation (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` - CanonicalTaskTaskFrame (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean` - succ_chain_history (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - truth lemma with documented box-backward sorry
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - BFMCS structure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - ParametricCanonicalTaskFrame (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - parametric truth lemma (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - representation theorem (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - succ_chain_completeness (uses sorry via truth lemma)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1793-1853) - deprecated construct_bfmcs with sorry
