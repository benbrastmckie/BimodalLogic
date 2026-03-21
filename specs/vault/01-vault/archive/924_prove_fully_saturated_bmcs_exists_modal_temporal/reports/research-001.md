# Research Report: Task #924

**Task**: Prove fully_saturated_bmcs_exists: combining modal saturation with temporal coherence
**Date**: 2026-02-24
**Focus**: Investigate strategies for proving `fully_saturated_bmcs_exists_int` sorry-free
**Session**: sess_1771989886_c7be75

## Summary

This report analyzes the sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:819) which is the final blocker in the completeness chain. The theorem requires constructing a `BMCS Int` that simultaneously satisfies temporal coherence, modal saturation, and context preservation. The core tension is that modal saturation (via witness families) creates constant BFMCS families that need to be temporally coherent, but constant families are only temporally coherent when their underlying MCS is temporally saturated -- a property that Lindenbaum extension does not generally preserve.

The report identifies **three viable proof strategies**, with Strategy A (Domain Generalization to CanonicalMCS) being the most promising as it leverages the sorry-free `canonicalMCSBFMCS` infrastructure from Task 922.

## Findings

### 1. Current Sorry Landscape

The sorry at line 819 of TemporalCoherentConstruction.lean:

```lean
theorem fully_saturated_bmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  sorry
```

This is consumed by:
- `construct_saturated_bmcs_int` (TemporalCoherentConstruction.lean:890)
- `bmcs_representation` and `bmcs_context_representation` (Completeness.lean:101,122)
- `standard_representation` and completeness theorems (Representation.lean:552+)

The completeness chain flows: `fully_saturated_bmcs_exists_int` -> `construct_saturated_bmcs_int` -> `bmcs_representation` -> `bmcs_weak_completeness` / `bmcs_strong_completeness`. Everything downstream of the sorry is otherwise sorry-free.

### 2. The Core Tension

The difficulty arises from combining two independently achievable properties:

**Temporal coherence** (`B.temporally_coherent`): For every family in the BMCS, `forward_F` and `backward_P` hold. This means:
- F(phi) in family.mcs(t) implies there exists s >= t with phi in family.mcs(s)
- P(phi) in family.mcs(t) implies there exists s <= t with phi in family.mcs(s)

**Modal saturation** (`is_modally_saturated B`): For every family, every Diamond(psi) in family.mcs(t) has a witness family fam' in B.families with psi in fam'.mcs(t).

The tension: Modal saturation creates witness families via `constructWitnessFamily` (ModalSaturation.lean:277), which are **constant** BFMCS (same MCS at all times). A constant family satisfies temporal coherence iff its MCS is **temporally saturated** (F(psi) -> psi and P(psi) -> psi). But:
1. Lindenbaum extension (`extendToMCS`) does not preserve temporal saturation
2. Temporally saturated MCS existence was proven FALSE for the general case (the Henkin counterexample: {F(psi), neg psi} is consistent but cannot be in a temporally saturated MCS)
3. The `TemporalEvalSaturatedBundle` approach only works for MCS that ARE temporally saturated

### 3. The All-MCS Approach (Task 922) -- Key Infrastructure

Task 922 introduced `canonicalMCSBFMCS` in `CanonicalBFMCS.lean`:
- Domain: `CanonicalMCS` = all maximal consistent sets
- Ordering: `CanonicalR` (GContent subset relation), which is a Preorder (reflexive + transitive)
- Forward_G, backward_H: proven sorry-free via `canonical_forward_G`, `canonical_backward_H`
- **Forward_F, backward_P: PROVEN sorry-free** via `canonicalMCS_forward_F`, `canonicalMCS_backward_P`

This gives us a single BFMCS with all four temporal properties. For a BMCS, we need MULTIPLE BFMCS families with modal coherence between them.

### 4. Why D = Int Is Used

The completeness chain uses `D = Int` because:
1. `Representation.lean` constructs a `TaskFrame Int` with `WorldHistory (canonicalFrame B)` indexed by Int
2. The semantics layer (`Truth.lean`, `Validity.lean`) uses `AddCommGroup D` and `LinearOrder D` for time shift operations
3. `satisfiable Int` is the target statement for the standard representation theorem

However, the BMCS-level completeness (`Completeness.lean`) uses `BMCS Int` but the truth lemma `bmcs_truth_lemma` is generic over `D`. The Int constraint comes from `bmcs_representation` which produces `∃ (B : BMCS Int)`.

### 5. Strategy Analysis

#### Strategy A: Domain Generalization (Refactor completeness to use D = CanonicalMCS)

**Idea**: Instead of proving `fully_saturated_bmcs_exists_int`, change the completeness chain to use `D = CanonicalMCS` where temporal coherence is already proven sorry-free.

**Steps**:
1. Build a BMCS over `CanonicalMCS` using CoherentBundle approach or direct construction
2. The eval_family is `canonicalMCSBFMCS` (sorry-free temporal coherence)
3. For modal saturation: each Diamond(psi) in fam.mcs(t) needs a witness family fam' with psi in fam'.mcs(t). Since `fam.mcs(t) = t.world` (the MCS itself), Diamond(psi) in t.world means psi is consistent (`diamond_implies_psi_consistent`). Extend {psi} to MCS W, then build constant witness family from W. This witness family is `constantWitnessFamily W h_W_mcs` over CanonicalMCS.
4. The witness family IS temporally coherent because `D = CanonicalMCS` means the family assigns W to EVERY CanonicalMCS element (constant), and forward_F/backward_P for a constant family over CanonicalMCS amounts to: F(psi') in W implies exists s with psi' in W. For a constant family, `mcs(s) = W` for all s, so forward_F requires: F(psi') in W implies psi' in W, i.e., temporal saturation of W. THIS IS THE SAME PROBLEM.

**Actually**, wait -- `canonicalMCSBFMCS` is NOT constant. It maps each `w : CanonicalMCS` to `w.world`. So different time points (different MCSes) have different MCS values. The forward_F property of `canonicalMCSBFMCS` works because `canonical_forward_F` constructs a fresh witness MCS for each F-obligation. The witness IS a CanonicalMCS element (since all MCSes are included).

For modal saturation of a BMCS over CanonicalMCS, witness families would need to be BFMCS over CanonicalMCS. But these witness families cannot be constant (same problem) and cannot easily be non-constant while maintaining temporal coherence.

**Assessment**: This strategy has promise but still faces the witness-family temporal coherence issue. The non-constant eval_family from `canonicalMCSBFMCS` works, but modal saturation requires adding more families.

#### Strategy B: All-MCS BMCS with Universal Modal Properties

**Idea**: Construct a BMCS where the family set consists of ALL BFMCS of the form `canonicalMCSBFMCS` but with DIFFERENT "perspectives" on which MCS is the root.

Actually, `canonicalMCSBFMCS` has only ONE form -- it maps each CanonicalMCS to its own world. So there's only one such family, and a single-family BMCS cannot satisfy modal_backward (as proven by the `singleFamilyBMCS` sorry).

**Alternative formulation**: What if each "family" in the BMCS represents a different MCS, and family fam_M maps time `t` to some MCS depending on both M and t?

In the standard canonical model for S5 + temporal, one approach is:
- For each MCS M, define family_M(t) = M for all t (constant)
- The BMCS families = { family_M | M is an MCS }
- Modal forward: Box phi in family_M.mcs(t) = Box phi in M. By T-axiom, phi in M = phi in family_M.mcs(t). But we need phi in family_M'.mcs(t) = phi in M' for ALL M'. This requires: Box phi in M implies phi in M' for ALL MCS M'. This is NOT TRUE in general! Box phi being in one MCS does not force phi into all MCSes.

So the "all constant families" approach fails for modal_forward.

#### Strategy C: Enriched Canonical Construction (Single Non-Constant Eval + Constant Witnesses)

**Idea**: Use `canonicalMCSBFMCS` as the eval_family (non-constant, temporally coherent) and add constant witness families for modal saturation, BUT weaken the temporal coherence requirement to only apply to the eval_family.

**Key observation**: Looking at how `B.temporally_coherent` is used:
```lean
def BMCS.temporally_coherent (B : BMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
```

This requires forward_F/backward_P for ALL families, including witness families. However, examining `bmcs_truth_lemma` in TruthLemma.lean:

```lean
theorem bmcs_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : BFMCS D) (hfam : fam ∈ B.families)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

The truth lemma is proven by induction on phi. For the `all_future` case, it uses `temporal_backward_G` which requires `forward_F` on the specific family being evaluated. For the box case, it recurses to evaluate phi at OTHER families. So the truth lemma potentially needs temporal coherence at the witness families too.

But wait -- examining the box case more carefully: The backward direction of box says "if phi true at all families, then Box phi in fam.mcs t". The forward direction says "Box phi in fam.mcs t implies phi true at all fam'". When evaluating phi at fam', we invoke IH: `phi ∈ fam'.mcs t ↔ bmcs_truth_at B fam' t phi`. This IH needs temporal coherence of fam' if phi involves G/H operators.

So in principle, ALL families need temporal coherence for the truth lemma. Strategy C (weakening to eval-only) would require restructuring the truth lemma, which is a significant change.

#### Strategy D: CanonicalMCS BMCS with Identity-Based Modal Properties

**Idea**: Build a BMCS over `D = CanonicalMCS` where:
- Families = { one family per MCS M }, where family_M maps each CanonicalMCS element `w` to `w.world` (same as canonicalMCSBFMCS)
- Actually all these families are IDENTICAL because they all use the same mapping `w.world`
- So this collapses to a single-family BMCS again.

This doesn't work for the same reason as before.

#### Strategy E: Rethink the BMCS Architecture -- All-Pairs Construction

**Idea**: The fundamental problem is that the BMCS framework requires MULTIPLE BFMCS families (one eval + witnesses) all indexed by the SAME domain D. Each family maps each `t : D` to an MCS.

What if we construct a BMCS where:
- `D = CanonicalMCS` (all MCSes with CanonicalR ordering)
- The eval_family is `canonicalMCSBFMCS` (mapping w to w.world) -- sorry-free temporal coherence
- For each MCS M, we add a constant witness family that maps every `w : CanonicalMCS` to M
- Modal saturation: Diamond(psi) in `canonicalMCSBFMCS.mcs(w) = w.world` means Diamond(psi) in w.world. Need witness family where psi is in that family's mcs(w). The constant witness family for an MCS M containing psi has `mcs(w) = M` for all w. So psi in M at w.
- Modal forward: Box(phi) in eval_family.mcs(w) = Box(phi) in w.world. Need phi in family_M.mcs(w) = phi in M for ALL M. This means Box(phi) in w.world implies phi in every MCS M. But that's the S5 property: Box phi is true iff phi is true at all worlds. This is NOT generally true -- Box(phi) in one MCS does NOT mean phi is in ALL MCSes.

So `modal_forward` fails here too. The S5 semantics in the standard sense has Box phi true at w iff phi is true at all accessible worlds. In BMCS, `modal_forward` says Box phi in fam.mcs(t) implies phi in fam'.mcs(t) for ALL families fam' in the bundle. This is much stronger than S5 accessibility.

The BMCS modal_forward is essentially: if Box phi is true anywhere, then phi is true everywhere in the bundle. This is appropriate for S5 with UNIVERSAL accessibility, but requires the bundle to be carefully constructed.

#### Strategy F: The Correct Canonical Construction for BMCS + S5

**Key realization**: In the BMCS framework, `modal_forward` requires that Box phi in ANY family's MCS at time t implies phi in ALL families' MCS at time t. This means:
- All families must "agree" on boxed formulas
- Specifically: `BoxContent(fam, t) ⊆ fam'.mcs t` for all fam, fam', t

The CoherentBundle approach (CoherentConstruction.lean) achieves this for constant families by requiring all families to contain `UnionBoxContent`. For non-constant families (like `canonicalMCSBFMCS`), this is more complex.

For the CanonicalMCS domain: `canonicalMCSBFMCS.mcs(w) = w.world`. So Box phi in `w.world` at "time" w. Modal_forward requires: phi in `fam'.mcs(w)` for all families fam'. If all families map w to w.world (identity), then we need phi in w.world, which follows from T-axiom (Box phi -> phi). But this is a single-family scenario.

For multiple families: say fam1 maps w to w.world, and fam2 is a constant family mapping every w to some fixed MCS M. Then modal_forward requires: Box phi in w.world implies phi in M (for all w, phi). This means EVERY Box phi from EVERY MCS must be in M. Since different MCSes can have different Box phi, M would need to contain phi for EVERY phi that appears under Box in any MCS. This is not possible in general (M might not be consistent with all such phi).

**Conclusion about modal_forward**: The BMCS modal_forward condition essentially requires that all families at each time point share the SAME set of "boxed truths". For constant witness families and a non-constant eval family, this is extremely constraining.

#### Strategy G: Refactor the Completeness Chain to Use CanonicalMCS Directly

**This is the most promising approach.** Instead of fixing `fully_saturated_bmcs_exists_int`, we can:

1. Change `bmcs_representation` to produce `∃ (B : BMCS CanonicalMCS), ...` instead of `∃ (B : BMCS Int), ...`
2. The BMCS over CanonicalMCS can be a SINGLE-family BMCS using `canonicalMCSBFMCS`
3. Wait -- single family BMCS still has the modal_backward sorry.

**OR**: The key insight is that in the CanonicalMCS construction, Box phi in w.world means phi is in BoxContent(w.world). By S5 axiom 5 (negative introspection), if neg(Box phi) is in w.world, then Box(neg(Box phi)) is in w.world (proven as `mcs_neg_box_implies_box_neg_box` in ModalSaturation.lean). And by T axiom, Box phi in w.world implies phi in w.world. So for the single identity family:

- `modal_forward`: Box phi in w.world implies phi in w.world (T-axiom). For a single family, this is enough since the only family is itself.
- `modal_backward`: phi in w.world (for the only family) implies Box phi in w.world. This is FALSE in general (phi in MCS does not imply Box phi in MCS).

So single-family modal_backward STILL fails, even with CanonicalMCS.

The resolution requires MULTIPLE families. In the standard canonical model for S5:
- There are multiple families (one per MCS acting as eval point)
- OR: the bundle contains families that cover all necessary Diamond witnesses

**The standard approach for S5 canonical models:**
The canonical Kripke model for S5 has:
- Worlds = all MCSes
- R = universal (every world sees every world)
- Box phi true at w iff phi true at all worlds iff phi in every MCS

But this means Box phi is true at w iff phi is a THEOREM. In our BMCS encoding:
- modal_forward: Box phi in fam.mcs(t) implies phi in fam'.mcs(t) for all fam'
- This means: Box phi in some MCS implies phi in every MCS, i.e., phi is a theorem

This is mathematically correct for S5! In S5 with universal accessibility, Box phi = "phi is necessary" = "phi is a theorem".

So for the BMCS encoding: we need a bundle where Box phi in any family at any time implies phi in ALL families at that time. With family_M(w) = M (constant families, one per MCS):
- Box phi in M at time w means Box phi in M
- Need: phi in M' for all MCS M'
- This requires: Box phi in M implies phi is a theorem

This IS an S5 consequence: In S5, Box phi is in an MCS iff phi is a theorem (because S5 axioms make accessibility universal). Specifically:
- If Box phi is in M, then by T-axiom phi is in M
- If Box phi is in M, then by axiom 5 (5-collapse), Diamond(Box phi) -> Box phi, so Box phi is necessary, hence in all MCS
- Wait, that's backwards. We need: Box phi in M implies phi in every MCS M'.

By axiom 4: Box phi -> Box(Box phi). So Box(Box phi) in M.
By modal_forward (to prove): Box(Box phi) in M implies Box phi in M'. But this is circular.

The actual S5 property: Box phi in M implies Box(Box phi) in M (by axiom 4). And by necessitation of T: Box(Box phi -> phi), so Box(Box phi) -> Box phi (by K distribution). But this doesn't give phi in M'.

Actually, the key S5 property is: Box phi in M implies, for ANY MCS M' such that Box(neg phi) is NOT in M', we have phi in M'. But for S5 with universal R: Box phi in M implies phi in M' for ALL M' iff phi is a theorem.

This is NOT what we want. We want: Box phi in M implies phi in M' only for M' IN THE BUNDLE.

**Critical Insight**: The BMCS construction does NOT require universal accessibility across ALL MCSes, only within the BUNDLE. So we can carefully select which families go into the bundle.

### 6. The Winning Strategy: All-MCS Bundle with Time-Indexed Families

After extensive analysis, the most viable strategy combines the all-MCS approach with a carefully constructed bundle:

**Construction**:
1. Use `D = CanonicalMCS` (all MCSes with CanonicalR ordering)
2. For each MCS M, define `family_M : BFMCS CanonicalMCS` where `family_M.mcs(w) = M` (constant family mapping every w to M)
3. The bundle `families = { family_M | M is an MCS }`
4. The eval_family = `family_{M_0}` where M_0 extends Gamma

**Temporal coherence**: Each constant family_M satisfies forward_G/backward_H by T-axioms (same as `constantBFMCS`). For forward_F: F(psi) in M means... we need exists `s : CanonicalMCS` with `w <= s` and `psi in M`. Since M is constant, psi in M. So we need psi in M whenever F(psi) in M. This is temporal saturation of M -- SAME PROBLEM.

This approach also fails for constant families.

**The real alternative**: Use NON-constant families where `family_M.mcs(w)` varies with w. Specifically:
- `family_M.mcs(w) = w.world` (the identity family, i.e., `canonicalMCSBFMCS`)

But then all families are the same! There's only one identity family.

### 7. The Fundamental Blocker and Resolution Path

The fundamental issue is that the BMCS framework has two orthogonal dimensions:
1. **Temporal dimension** (different MCS at different times) -- handled by BFMCS
2. **Modal dimension** (multiple possible worlds) -- handled by having multiple families in BMCS

For temporal coherence of the eval_family, the all-MCS approach (CanonicalMCS) works beautifully. For modal saturation, we need multiple families. For temporal coherence of the witness families, we need them to be non-trivially constructed.

The only approach that can work simultaneously is:

**Strategy H: Multiple Identity-Like Families with Shifted Perspectives**

Each family maps `w : CanonicalMCS` to a DIFFERENT MCS depending on the family. Specifically:
- For each MCS M, define `family_M.mcs(w) = translate(M, w)` where translate produces an MCS that "looks like M modally but follows w temporally"

This is essentially what the standard canonical model does, but encoding it in the BMCS framework is non-trivial.

**Alternatively**:

**Strategy I: Refactor BMCS to Separate Modal and Temporal Dimensions**

Change `BMCS.temporally_coherent` to only require temporal coherence of the eval_family:
```lean
def BMCS.eval_temporally_coherent (B : BMCS D) : Prop :=
  (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ B.eval_family.mcs t → ...) ∧
  (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ B.eval_family.mcs t → ...)
```

Then verify that the truth lemma only needs this weaker condition.

Looking at the truth lemma more carefully: the G/H backward cases use `temporal_backward_G` and `temporal_backward_H`, which require `forward_F`/`backward_P` on the specific family being evaluated. When the truth lemma recurses into the Box case, it evaluates phi at all families. If phi = G(psi) and we're evaluating at a witness family, we need `temporal_backward_G` for that witness family, which requires forward_F on that witness family.

So the full truth lemma genuinely requires temporal coherence of ALL families, not just eval. However, THIS IS ONLY NEEDED WHEN EVALUATING TEMPORAL FORMULAS AT WITNESS FAMILIES.

**Strategy I (refined)**: Prove that if phi does not involve G/H operators at the witness-family level, temporal coherence is not needed for witness families. But since formulas can be arbitrary, this doesn't help in general.

**Strategy J: Direct Int Construction via Combined Seed**

Go back to the original `D = Int` approach, but construct the BMCS more carefully:
1. Build eval_family via DovetailingChain (has sorries for forward_F/backward_P)
2. For each Diamond(psi) obligation, build a witness family that includes BOTH modal AND temporal content in its seed
3. The witness seed for psi would be: `{psi} ∪ BoxContent(eval) ∪ GContent(W) ∪ HContent(W)` where W is some base MCS

This is essentially Option A from the implementation-007 plan.

### 8. Recommended Approach: Strategy G (Refactor to CanonicalMCS) with Modal Saturation via CoherentBundle

After thorough analysis, the recommended approach is:

1. **Refactor `bmcs_representation` and `bmcs_context_representation`** to produce `BMCS CanonicalMCS` instead of `BMCS Int`
2. **Build the BMCS** using the CoherentBundle approach on `CanonicalMCS`:
   - Start with `canonicalMCSBFMCS` as the base family
   - Add constant witness families via CoherentBundle saturation
   - The key challenge remains: constant witness families need temporal coherence
3. **Resolve constant family temporal coherence** by proving that for `D = CanonicalMCS`, a constant family_M has:
   - forward_F: F(psi) in M implies exists `s : CanonicalMCS` with `w <= s` and psi in M
   - Since family is constant (mcs(s) = M for all s), we need psi in M whenever F(psi) in M
   - This is temporal saturation of M, which is not generally true
4. **Alternative resolution**: Use NON-constant witness families that leverage the CanonicalMCS structure

**Bottom line**: The fundamental blocker is temporal coherence of witness families, regardless of whether D = Int or D = CanonicalMCS. The constant-family approach fails because temporal saturation is not achievable for arbitrary MCSes.

### 9. The True Resolution: Eval-Only Temporal Coherence (Strategy I)

After ruling out all approaches that require ALL families to be temporally coherent, the most promising path is to restructure the truth lemma to only require temporal coherence of the eval_family.

**Detailed analysis of truth lemma dependencies**:

The truth lemma for `all_future` (G phi) backward direction at family fam:
- Uses `temporal_backward_G fam_tc t phi h_all` where `fam_tc : TemporalCoherentFamily`
- This requires `forward_F` on fam specifically

When the truth lemma recurses through Box: Box phi = forall fam' in B, phi in fam'.mcs t. The IH needs: phi in fam'.mcs t iff bmcs_truth_at B fam' t phi. This IH is applied to ALL families, including witness families.

If phi involves G/H, then evaluating it at a witness family requires that family's temporal coherence. So the full truth lemma DOES need all families to be temporally coherent.

**However**: The truth lemma is used in Completeness.lean only at the EVAL family:
```lean
exact (bmcs_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 φ).mp h_in_mcs
```

The question is: does the induction on phi ever evaluate at a non-eval family? Yes, in the Box case: `bmcs_truth_at B fam t (box phi) = forall fam' in B.families, bmcs_truth_at B fam' t phi`. Then by IH: `phi in fam'.mcs t iff bmcs_truth_at B fam' t phi`. So we apply the truth lemma at fam' too.

If fam' is a witness family and phi = G(psi), then the backward direction needs forward_F on fam'. This is the fundamental issue.

**Can we avoid this?** The Box backward direction says: if `forall fam', phi in fam'.mcs t` then `Box phi in fam.mcs t`. This uses `modal_backward`, not the truth lemma. The Box forward direction says: if `Box phi in fam.mcs t` then `forall fam', phi in fam'.mcs t`. This uses `modal_forward`. Neither directly invokes the truth lemma at other families.

Wait -- let me re-read the truth lemma proof for Box more carefully.

The Box case in the truth lemma:
- Forward: `Box phi in fam.mcs t -> forall fam' in B, bmcs_truth_at B fam' t phi`
  - By modal_forward: Box phi in fam.mcs t -> phi in fam'.mcs t (for all fam')
  - By IH: phi in fam'.mcs t -> bmcs_truth_at B fam' t phi
  - So: forward direction uses IH at other families
- Backward: `(forall fam' in B, bmcs_truth_at B fam' t phi) -> Box phi in fam.mcs t`
  - For each fam': bmcs_truth_at B fam' t phi -> phi in fam'.mcs t (by IH backward)
  - Then: forall fam', phi in fam'.mcs t -> Box phi in fam.mcs t (by modal_backward)
  - So: backward direction also uses IH at other families

So the truth lemma at family fam DOES invoke the IH at all other families fam'. If phi is a temporal formula, the IH at fam' needs temporal coherence of fam'.

**This confirms**: Unless the truth lemma is restructured, ALL families need temporal coherence. Restructuring the truth lemma is a viable but significant change.

### 10. Alternative: Direct Proof of `fully_saturated_bmcs_exists_int`

Given the above analysis, let us consider whether the sorry can be filled DIRECTLY for `D = Int`:

The DovetailingChain approach gives a BFMCS over Int with:
- forward_G, backward_H: proven
- forward_F, backward_P: sorry (the 4 remaining sorries)

If these 4 sorries are eliminated (they are the subject of task 922), then `temporal_coherent_family_exists_Int` would be sorry-free, giving us the eval_family.

For modal saturation: we need witness families over Int. Each witness family needs:
- Contains psi at time 0 (for the Diamond(psi) obligation)
- forward_G, backward_H, forward_F, backward_P all satisfied

The most promising approach for Int witness families would be ANOTHER instance of the DovetailingChain or CanonicalMCS construction:
- Given Diamond(psi) at eval.mcs(0), we know psi is consistent
- Build a temporally coherent BFMCS over Int containing psi via `temporal_coherent_family_exists_Int`
- This family satisfies ALL temporal properties

But `temporal_coherent_family_exists_Int` itself relies on the DovetailingChain which has sorries! So this is circular unless the DovetailingChain sorries are eliminated first.

## Recommendations

### Recommendation 1 (Highest Priority): Restructure to Use CanonicalMCS Domain

Change the completeness chain from `D = Int` to `D = CanonicalMCS`:

1. Replace `fully_saturated_bmcs_exists_int` with `fully_saturated_bmcs_exists_CanonicalMCS`
2. Build a single-family BMCS using `canonicalMCSBFMCS` as eval_family
3. For modal saturation: add non-constant witness families that also use the identity mapping but shift perspective
4. Or: prove that for this specific domain, single-family modal_backward holds

This avoids the temporal coherence problem entirely for the eval family.

### Recommendation 2: Investigate Single-Family Modal Backward for CanonicalMCS

For `canonicalMCSBFMCS` as a single family in a BMCS over CanonicalMCS:
- `modal_backward`: phi in fam.mcs(w) (= phi in w.world) for all w implies Box phi in fam.mcs(w) (= Box phi in w.world)
- This requires: if phi is in EVERY MCS, then Box phi is in every MCS
- If phi is in every MCS, then phi is a theorem (by MCS properties)
- If phi is a theorem, then Box phi is a theorem (by necessitation)
- If Box phi is a theorem, then Box phi is in every MCS

This IS provable! The chain is:
1. phi in every MCS -> phi is a theorem
2. phi theorem -> Box phi is a theorem (necessitation)
3. Box phi theorem -> Box phi in every MCS

The key lemma needed: "if phi is in every MCS, then phi is a theorem". This is the COMPLETENESS direction and is NOT trivially available -- it's exactly what we're trying to prove!

So this is circular: we need completeness to prove modal_backward, but modal_backward is needed for completeness.

### Recommendation 3: Weaken BMCS.temporally_coherent for Witness Families

Modify the architecture so temporal coherence is only checked for the eval_family:
1. Change `BMCS.temporally_coherent` to only check eval_family
2. Verify the truth lemma still works (it may not for nested Box + temporal formulas)
3. If the truth lemma breaks, restructure it to separate modal and temporal reasoning

### Recommendation 4: Prove DovetailingChain forward_F/backward_P Sorry-Free

If the 4 DovetailingChain sorries (from task 922) can be eliminated:
1. `temporal_coherent_family_exists_Int` becomes sorry-free
2. For each modal witness obligation, build a separate temporally coherent family
3. Use `temporal_coherent_family_exists_Int` to build witness families
4. The resulting BMCS has all temporal + modal properties

This approach requires resolving the DovetailingChain sorries first, which is a separate (and difficult) problem.

### Recommendation 5: Explore the CanonicalMCS + CoherentBundle Hybrid

Use `canonicalMCSBFMCS` as the eval_family over CanonicalMCS, and for each Diamond obligation at a specific time w, use `canonical_forward_F` to get the witness MCS W, then add a non-constant family that maps each time point v to a fresh witness construction. This is complex but avoids the constant-family temporal saturation problem.

## References

- TemporalCoherentConstruction.lean: The sorry location and surrounding infrastructure
- CanonicalBFMCS.lean: The all-MCS BFMCS construction (sorry-free temporal coherence)
- CanonicalFrame.lean: canonical_forward_F, canonical_backward_P (sorry-free)
- ModalSaturation.lean: saturated_modal_backward, is_modally_saturated, axiom_5_negative_introspection
- CoherentConstruction.lean: CoherentBundle.toBMCS, mutual coherence
- Construction.lean: singleFamilyBMCS (modal_backward sorry), constantBFMCS
- Completeness.lean: bmcs_representation consuming fully_saturated_bmcs_exists_int
- Representation.lean: Standard semantics bridge (hardcoded to Int)
- Task 922 research-008: Analysis of CanonicalMCS approach and LinearOrder non-use
- Task 881 implementation-007: Decision tree for sorry-free path

## Next Steps

1. **Analyze truth lemma temporal dependency**: Carefully trace through the truth lemma proof to determine whether temporal coherence of witness families is genuinely required for the specific formulas that arise during the box case evaluation. If it's only needed for temporal formulas nested inside Box, there may be a structural argument.

2. **Prototype CanonicalMCS refactor**: Build a proof-of-concept that changes `bmcs_representation` to use `D = CanonicalMCS`, keeping `Representation.lean` as a separate bridge to `D = Int`.

3. **Investigate the "all formulas in all MCS implies theorem" lemma**: If this can be proven independently (perhaps using the compactness argument or the maximal extension construction), it would unlock single-family modal_backward for CanonicalMCS.

4. **Consider whether the Representation.lean layer can adapt**: The `canonicalFrame` uses `D = Int` for `TaskFrame Int`. Could it work with `TaskFrame CanonicalMCS`? This requires CanonicalMCS to have `AddCommGroup` and `LinearOrder`, which it does NOT have (only Preorder). So the standard semantics bridge would need reworking.
