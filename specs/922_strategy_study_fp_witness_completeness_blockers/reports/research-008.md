# Research Report: Task #922

**Task**: Strategy study: forward_F/backward_P completeness blockers
**Date**: 2026-02-24
**Focus**: Investigation of unused LinearOrder, removed AddCommGroup/timeshift, and frame construction gap
**Session**: sess_1771985428_baae33

## Summary

This report investigates why `LinearOrder` is declared but never used in proofs, why `AddCommGroup` (which supports timeshift operations) was removed from the metalogic/Bundle completeness chain, and what this reveals about a fundamental gap between the semantic frame definition and the canonical model construction. The core finding is that the canonical model construction uses a trivial task relation (`fun _ _ _ => True`) and bypasses the actual temporal structure (AddCommGroup, time_shift, compositionality) that the semantic definitions require. This works for completeness (which is existential) but means the constructed canonical model does not faithfully represent the intended temporal semantics of world histories as linearly ordered sequences of states.

## Findings

### 1. LinearOrder: Declared but Never Used in the Completeness Chain

A systematic audit confirms that `LinearOrder` appears only as a type constraint in the metalogic/Bundle completeness chain. No proof in the chain uses any `LinearOrder`-specific property:

| Property | Used? | Evidence |
|----------|-------|---------|
| `le_total` (totality) | NO | Zero uses in TruthLemma, BMCS, BMCSTruth, TemporalCoherentConstruction |
| `lt_trichotomy` | NO | Zero uses |
| `le_antisymm` (antisymmetry) | NO | Zero uses |
| `Decidable` ordering | NO | Zero uses |
| `lt_or_eq_of_le` | YES, but PartialOrder suffices | Used in TruthLemma lines 103, 126 |

The only ordering property actually used is `lt_or_eq_of_le` (splitting `t <= s` into `t < s` or `t = s`), which is available from `PartialOrder`, not just `LinearOrder`.

**Why this matters**: If `LinearOrder` is never used, the completeness proof never appeals to the fact that world histories are TOTALLY ORDERED sequences. But the intended semantics (from the JPL paper) specifically requires D to be a totally ordered abelian group. The linearity of time is essential for temporal logic -- it ensures that for any two moments, one is in the future of the other. The fact that linearity is unused suggests the canonical model construction has abstracted away too much temporal structure.

### 2. AddCommGroup Removal: When and Why

**When**: Task 922 (commit `63d310ab`) removed `AddCommGroup D` and `IsOrderedAddMonoid D` from the `variable` declarations in BFMCS.lean, changing:
```
variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```
to:
```
variable (D : Type*) [LinearOrder D]
```
This also removed the `import Mathlib.Algebra.Order.Group.Defs` line.

**Why**: The removal was propagated through the metalogic/Bundle chain (BMCS.lean, BMCSTruth.lean, TruthLemma.lean, etc.) because no proof in that chain uses `AddCommGroup` operations. The chain never adds, subtracts, negates, or uses zero as an additive identity on the time parameter D. The only operations used are `<` and `<=` comparisons.

**What AddCommGroup supports**: In the SEMANTICS layer (which is separate from the metalogic/Bundle completeness chain), `AddCommGroup D` is essential for:
- `WorldHistory.time_shift`: Shifting a world history by delta uses `z + Δ`, `z + -Δ`, `add_assoc`, `neg_add_cancel` -- all requiring additive group structure
- `WorldHistory.respects_task`: The task relation uses `t - s` (subtraction) to compute durations
- `Truth.time_shift_preserves_truth`: The proof uses `y - x`, `x + (y - x)`, `add_sub`, `add_sub_cancel_left` -- requiring group + order compatibility
- `ShiftClosed`: The shift-closure property uses time_shift which needs additive structure

**Where AddCommGroup IS still used**: It remains in all semantic files:
- `Semantics/TaskFrame.lean` (line 84)
- `Semantics/WorldHistory.lean` (line 69)
- `Semantics/Truth.lean` (line 82)
- `Semantics/Validity.lean` (lines 72, 95)
- `Metalogic/SoundnessLemmas.lean` (line 87)
- `Metalogic/Representation.lean` (uses TaskFrame Int which inherits AddCommGroup)

### 3. Where LinearOrder IS Actually Used: Soundness, Not Completeness

The crucial finding is that `le_total` (the defining property of `LinearOrder`) IS used in the SOUNDNESS proof, specifically for the temporal linearity axiom:

**SoundnessLemmas.lean lines 528, 766**:
```lean
rcases le_total s1 s2 with h_le | h_le
```

This appears in the proof of `swap_axiom_temp_linearity_valid` (the swap of the temporal linearity axiom `F(phi) and F(psi) -> F(phi and F(psi)) or F(phi and psi) or F(F(phi) and psi)`). The proof needs to compare two witness times s1 and s2 to determine which comes first -- which is exactly what `le_total` provides.

**This makes perfect sense**: The linearity axiom asserts that temporal witnesses can always be compared. It is valid precisely because D is linearly ordered. The soundness proof MUST use linearity to validate this axiom. But the completeness proof does not need it because completeness is constructive/existential -- we just need to build ONE model, and we can choose a model where linearity holds by fiat (e.g., D = Int).

### 4. The Time_Shift Gap: Soundness vs Completeness

**In soundness** (`SoundnessLemmas.lean`): `time_shift_preserves_truth` is used for the modal-future (MF) and temporal-future (TF) axioms. These axioms relate truth at different times within the SAME history but at different time points, and the proof works by shifting the history. This is the core use of the additive group structure.

**In completeness** (`Representation.lean`): The canonical frame uses `task_rel := fun _ _ _ => True` (lines 101-103). This trivializes the task relation entirely -- every world state is reachable from every other world state at every duration. Consequently:
- `WorldHistory.respects_task` becomes trivially true (any history respects a trivial task relation)
- The compositional structure of the frame (nullity, compositionality) becomes vacuous
- Time_shift is used only for `shiftClosedCanonicalOmega` (the enlarged Omega set), not for establishing truth

**What this means**: The canonical model construction completely ignores the intended temporal structure. The task relation -- which in the JPL paper represents "what states are reachable by executing tasks of duration d" -- is trivialized. The additive group structure of D is used only to make the canonical histories shift-closed (a technical requirement), not to model actual temporal relationships.

### 5. The Frame Construction Gap: What's Missing

The standard canonical model construction for temporal logic (e.g., Goldblatt 1992) builds a frame where:
- **Worlds** = all maximal consistent sets
- **Future accessibility**: w R_F w' iff GContent(w) is a subset of w' (i.e., if G(phi) is in w, then phi is in w')
- **Past accessibility**: w R_P w' iff HContent(w) is a subset of w' (dual)

The current codebase HAS this construction in `CanonicalFrame.lean`:
- `CanonicalR M M' := GContent M ⊆ M'`
- `CanonicalR_past M M' := HContent M ⊆ M'`

And the key properties are PROVEN:
- `canonical_forward_F`: F(psi) in M implies exists MCS W with CanonicalR M W and psi in W (PROVEN, sorry-free)
- `canonical_backward_P`: P(psi) in M implies exists MCS W with CanonicalR_past M W and psi in W (PROVEN, sorry-free)
- `canonical_forward_G`: G(phi) in M and CanonicalR M M' implies phi in M' (PROVEN, trivial)
- `canonical_backward_H`: H(phi) in M and CanonicalR_past M M' implies phi in M' (PROVEN, trivial)
- `canonicalR_reflexive`: CanonicalR M M for any MCS M (PROVEN via T-axiom)
- `canonicalR_transitive`: CanonicalR is transitive (PROVEN via Temporal 4 axiom)

**The blocker**: These properties hold in the "flat" canonical model (where D = Set of all MCSes with the CanonicalR preorder). But the completeness chain requires a BFMCS, which is a function `mcs : D -> Set Formula` from a linearly ordered domain D. To turn the flat canonical model into a BFMCS, we need to assign a linear ordering to MCSes. The current approach (CanonicalQuotient.lean) takes the Antisymmetrization quotient of CanonicalReachable, giving LinearOrder, but this introduces the "quotient representative mismatch" problem: when we map a witness W to the quotient, the representative `s.repr` may differ from W, and individual formulas (like the witnessed phi) don't propagate between equivalent representatives.

### 6. What the Intended Semantics SHOULD Require

In the JPL paper's intended semantics, a frame F = (W, G, .) where G = (D, +, <=) is a totally ordered abelian group. Each world history tau is a function from a convex subset of D to W, satisfying: if tau(x) = w and y >= x, then tau(y) in w . (y - x) (the task relation). The key semantic equations are:
- M, tau, x |= F(phi) iff exists y >= x, M, tau, y |= phi
- M, tau, x |= P(phi) iff exists y <= x, M, tau, y |= phi
- M, tau, x |= G(phi) iff forall y >= x, M, tau, y |= phi
- M, tau, x |= H(phi) iff forall y <= x, M, tau, y |= phi

For the TRUTH LEMMA to work, each world history must be a linearly ordered sequence of MCSes (one for each time point). The F/P modalities quantify WITHIN the same history, while Box quantifies ACROSS histories. The linear ordering of D constrains HOW F and P interact (the linearity axiom), and the additive group structure enables time-shifting (the MF and TF axioms).

**What's missing in the canonical construction**: The canonical BFMCS should map each time point to an MCS such that:
1. G-formulas propagate forward (forward_G): already achieved
2. H-formulas propagate backward (backward_H): already achieved
3. F-obligations are witnessed (forward_F): proven in CanonicalFrame.lean for the flat model, but blocked when mapping to a linearly ordered domain
4. P-obligations are witnessed (backward_P): same as forward_F

The root cause is that the "family" abstraction (BFMCS: D -> Set Formula) implicitly treats a history as a linearly ordered sequence of MCSes, but the CANONICAL model has MCSes connected by an arbitrary preorder (CanonicalR), not a linear order. The gap between "preorder on MCSes" and "linear order on a time domain" is precisely the LinearOrder/AddCommGroup gap.

### 7. Why Removing AddCommGroup Was a Symptom, Not a Solution

The removal of AddCommGroup from the Bundle chain was mathematically correct in a narrow sense: no proof in the chain used it. But this removal is a symptom of a deeper issue: **the completeness chain has diverged from the intended semantics**.

The semantic layer (Semantics/Truth.lean, Semantics/WorldHistory.lean) uses AddCommGroup to define time_shift, which is essential for soundness of the MF and TF axioms. The completeness layer (Metalogic/Bundle/) does not use AddCommGroup because it never constructs a genuine TaskFrame with a meaningful task relation. Instead, it uses `task_rel := fun _ _ _ => True`.

This means:
- **Soundness**: Proven for the full semantic definition (with AddCommGroup, LinearOrder, real task relations, time_shift)
- **Completeness**: Proven for a degenerate semantic definition (trivial task relation, no time_shift)

The completeness proof shows: if phi is derivable from no premises, then phi is true in ALL BMCS models. By contrapositive: if phi is not derivable, then there exists a BMCS where phi is false. The key question is whether BMCS-validity implies standard validity. If it does, we have full completeness. If not, we only have completeness relative to BMCS semantics.

The current approach handles this via `Representation.lean`, which constructs a standard TaskFrame from a BMCS. Since the TaskFrame has a trivial task relation, it IS a valid TaskFrame. The WorldHistory respects the trivial task relation trivially. So BMCS-satisfiability implies standard satisfiability (with a degenerate frame). This works because standard validity quantifies over ALL frames, including degenerate ones.

### 8. The Intended Role of Linearity and Timeshifts

**LinearOrder on families**: Each family (world history) should represent a linearly ordered sequence of world states. Linearity ensures that for any two moments in the history, one is in the future of the other. This is what makes F(phi) and P(phi) interact properly (the temporal linearity axiom).

In the intended canonical construction:
- Each family is indexed by a linearly ordered domain D (e.g., Int)
- The MCS at time t represents the set of formulas true at that moment in that history
- Linear ordering ensures that if F(phi) is in MCS_t, then there exists a SPECIFIC future time s > t where phi is in MCS_s -- and this witness is on the SAME linear history

**AddCommGroup (timeshifts)**: The group structure enables "sliding" along a history. If tau is a history at evaluation time x, then time_shift tau delta gives the same history but evaluated at time x - delta. This is used in:
- Soundness of MF axiom: "if there exists a future time where phi holds at some history, then there exists a history where phi holds at the current time" -- proven by shifting the witness history
- Soundness of TF axiom: similar for temporal operators
- Shift-closure of Omega: the set of admissible histories must be closed under time-shifting for the soundness proof to go through

**Why they were removable from the completeness chain**: The completeness chain works at the level of BMCS (sets of MCSes), not at the level of standard frames. The BMCS truth predicate directly defines Box as quantification over families and G/H as quantification over time points. It does NOT use time_shift or task relations. The standard representation theorem (Representation.lean) bridges from BMCS to standard semantics using a trivial frame, which trivially satisfies all frame constraints including time_shift and task relations.

### 9. Diagnosis: The Completeness Proof is Sound but Misses Semantic Content

The completeness chain is mathematically correct: it proves that the TM proof system is complete with respect to standard task semantics. No axioms or sorries are needed in the truth lemma or completeness theorem themselves -- the remaining technical debt is in the construction of fully saturated, temporally coherent BMCS (`fully_saturated_bmcs_exists_int`), which has 1 sorry.

However, the construction is "degenerate" in the following sense:
- The canonical frame has a trivial task relation (every state reaches every state at every duration)
- The canonical model ignores the compositionality structure that the JPL paper emphasizes
- Linear ordering and group structure of D are not leveraged in the construction

This degeneracy is NOT a bug -- it's standard practice in completeness proofs for modal/temporal logics. The canonical model is always somewhat artificial (e.g., Kripke's canonical model for modal logic uses ALL MCSes as worlds and BoxContent-inclusion as accessibility, which gives a universal frame with no real "structure" beyond what the axioms force). The real structural content comes from the SOUNDNESS direction, which forces the axioms to hold in all genuine frames.

### 10. The Forward_F / Backward_P Blocker: Root Cause

With all the above context, the forward_F/backward_P blocker can now be precisely diagnosed:

**Root cause**: The BFMCS structure requires `mcs : D -> Set Formula` where D is linearly ordered. Forward_F requires: if F(phi) is in mcs(t), then there exists s >= t with phi in mcs(s). In the canonical frame, this witness exists (canonical_forward_F proves it), but it exists as a standalone MCS W, not as a value of the `mcs` function at some time point s.

**Why previous approaches failed**:
1. **DovetailingChain** (linear chain of MCSes indexed by Int): F-formulas don't persist through GContent seeds. When building MCS_{t+1} from GContent(MCS_t), the F-formulas of MCS_t are not inherited. So even if F(phi) is in MCS_t, the witness phi may not appear at any specific MCS_{t+k}.

2. **CanonicalQuotient** (quotient of CanonicalReachable to get LinearOrder): The quotient maps the witness MCS W to a quotient element s, but s.repr (the quotient representative) may differ from W. Individual formulas don't propagate between equivalent representatives (only G-formulas/GContent propagates).

3. **The fundamental tension**: BFMCS requires a SINGLE assignment mcs : D -> Set Formula that simultaneously satisfies forward_G, backward_H, forward_F, and backward_P. But:
   - forward_G/backward_H constrain what formulas MUST be in each MCS (based on G/H membership at other times)
   - forward_F/backward_P require WITNESSES (specific MCSes containing specific formulas) to exist in the family
   - These witnesses are not determined by G/H content alone -- they depend on individual formula membership
   - A linear chain forces all MCSes into a single sequence, making it impossible to satisfy all F-obligations simultaneously

**The resolution path (from research-007)**: Generalize the BFMCS domain from `[LinearOrder D]` to `[Preorder D]` and use CanonicalReachable directly as D. Then:
- `mcs w := w.world` (each CanonicalReachable element IS its MCS)
- forward_F witness: canonical_forward_F gives W, construct CanonicalReachable from W, and `mcs W = W.world` directly contains phi
- No quotient, no representative mismatch

This approach makes LinearOrder and AddCommGroup genuinely unnecessary for the completeness proof, which is consistent with the finding that they were never used. The Preorder on CanonicalReachable is the natural ordering structure for the canonical model.

## Recommendations

1. **Pursue the Preorder generalization (research-007 Option 1)**: Change BFMCS from `[LinearOrder D]` to `[Preorder D]`, change forward_G/backward_H from strict `<` to reflexive `<=`, and use CanonicalReachable as the domain. This eliminates the fundamental blocker while maintaining mathematical correctness.

2. **Do NOT try to restore LinearOrder or AddCommGroup to the completeness chain**: These are not needed for completeness. They serve the SOUNDNESS direction. The completeness chain correctly abstracts them away.

3. **Understand the architectural separation**: Soundness uses the full semantic structure (AddCommGroup, LinearOrder, time_shift, task_rel). Completeness only needs ordering (Preorder suffices) and MCS membership. The two directions have different structural requirements, and this is standard in the literature.

4. **The "trivial task relation" is not a defect**: Using `task_rel := fun _ _ _ => True` in the canonical frame is standard practice. Completeness shows that consistent formulas have SOME satisfying model -- the trivial frame suffices. It does not need to be the "most natural" or "most structured" model.

5. **Remaining technical debt after Preorder generalization**: The `fully_saturated_bmcs_exists_int` theorem still has 1 sorry (combining temporal coherence with modal saturation). With the Preorder approach, this becomes `fully_saturated_bmcs_exists` over CanonicalReachable, where temporal coherence is trivially satisfied. Modal saturation would still need to be addressed, but the temporal component would be fully resolved.

## Architecture Summary

The following diagram shows the separation of concerns:

```
SOUNDNESS (needs full structure)              COMPLETENESS (needs only MCS/preorder)
================================================  ==========================================
Semantics/TaskFrame.lean                          Metalogic/Bundle/BFMCS.lean
  [AddCommGroup D] [LinearOrder D]                  [Preorder D] (proposed)
  task_rel : W x D x W -> Prop                     mcs : D -> Set Formula
  nullity, compositionality                         forward_G, backward_H, forward_F, backward_P

Semantics/WorldHistory.lean                       Metalogic/Bundle/CanonicalFrame.lean
  [AddCommGroup D] [LinearOrder D]                  CanonicalR = GContent subset
  time_shift : WorldHistory -> D -> WorldHistory    canonical_forward_F (PROVEN)
  respects_task                                     canonical_backward_P (PROVEN)

Semantics/Truth.lean                              Metalogic/Bundle/TruthLemma.lean
  truth_at uses time_shift for temporal             bmcs_truth_lemma (SORRY-FREE)
  time_shift_preserves_truth (needs AddCommGroup)   No time_shift needed

Metalogic/SoundnessLemmas.lean                    Metalogic/Bundle/Completeness.lean
  le_total (needs LinearOrder)                      SORRY-FREE
  time_shift_preserves_truth (needs AddCommGroup)   No le_total needed

Metalogic/Soundness.lean                          Metalogic/Representation.lean
  valid phi -> derivable phi                        task_rel := fun _ _ _ => True (trivial)
  Uses FULL semantic structure                      Bridges to standard semantics
```

## References

- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`: BFMCS structure (LinearOrder only, AddCommGroup removed in task 922)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`: Canonical relations with proven forward_F/backward_P
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean`: Blocked canonical BFMCS (quotient representative mismatch)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`: Antisymmetrization quotient construction
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`: Sorry-free truth lemma
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`: Sorry-free completeness
- `Theories/Bimodal/Metalogic/Representation.lean`: Standard representation (trivial task_rel)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`: Uses le_total (LinearOrder) and time_shift_preserves_truth (AddCommGroup)
- `Theories/Bimodal/Semantics/Truth.lean`: Full semantic truth definition
- `Theories/Bimodal/Semantics/WorldHistory.lean`: WorldHistory with time_shift
- research-007.md: Option 1 (Preorder generalization) analysis

## Next Steps

1. **Create implementation plan for Preorder generalization**: Phase A (change forward_G/backward_H to <=), Phase B (change LinearOrder to Preorder), Phase C (build BFMCS on CanonicalReachable), Phase D (wire into completeness)
2. **Phase A is the minimal testable delta**: Change `<` to `<=` in BFMCS forward_G/backward_H, then verify all existing constructions still compile
3. **After Phase B**: CanonicalReachable BFMCS should give trivial forward_F and backward_P, eliminating the main blocker
4. **Address modal saturation**: Once temporal coherence is resolved via CanonicalReachable, focus on combining with modal saturation for the `fully_saturated_bmcs_exists` sorry
