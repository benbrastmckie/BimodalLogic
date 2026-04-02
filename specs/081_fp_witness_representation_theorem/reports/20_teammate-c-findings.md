# Report 20: Teammate C — Literature Verification and Integration Analysis

**Task**: 81 — F/P Witness Representation Theorem
**Date**: 2026-04-02
**Role**: Teammate C — Literature and integration verification
**Confidence**: HIGH for literature analysis, MEDIUM for Lean effort estimates

---

## Part 1: Literature Verification

### 1.1 Goldblatt 1992 (*Logics of Time and Computation*)

**Does Goldblatt use simultaneous induction for temporal completeness?**

Yes, but not using that exact terminology. Goldblatt's completeness proof for the basic tense logic Kt (Chapter 3) uses induction on formula complexity for the truth lemma. The proof is structured as a single induction where the base case (atoms) is trivial, Boolean cases use MCS properties, and modal/temporal cases use the canonical relation definitions. For the temporal operators G and H, Goldblatt defines the canonical temporal relation R_G such that w R_G v iff for all G(phi) in w, phi in v. The truth lemma then proceeds by showing:

- **Forward (G)**: G(phi) in w implies for all v with w R_G v, phi in v (immediate from R_G definition).
- **Backward (G)**: For all v with w R_G v, phi in v, then G(phi) in w. This uses the contrapositive: if G(phi) not in w, then F(neg(phi)) in w, and by the Lindenbaum/canonical construction there exists v with w R_G v and neg(phi) in v, contradicting the hypothesis.

**Key insight**: Goldblatt's backward direction for G requires constructing a witness v that is R_G-accessible from w AND contains neg(phi). This is exactly the "forward_F" property in TM's codebase. In Goldblatt's setting, this witness is constructed at the SAME level of the induction — it does not require truth at lower depths because the R_G relation is defined purely in terms of formula membership, not semantic truth.

**Conditions on the temporal relation**: Goldblatt works with a reflexive and transitive temporal order. The T-axiom (G(phi) -> phi) corresponds to reflexivity. This matches TM's reflexive semantics (t <= s, not t < s).

**Applicability to TM**: Goldblatt's construction works for uni-modal tense logic. It does NOT directly handle the bimodal S5 + tense combination. The truth lemma for the box operator is independent of the temporal truth lemma in Goldblatt's setting because there are no interaction axioms.

**Confidence**: HIGH — Goldblatt's proof is well-documented and the structure is clear.

### 1.2 Gabbay/Hodkinson/Reynolds 1994 (*Temporal Logic: Mathematical Foundations*)

**Step-by-step construction**: GHR's "step-by-step" construction builds the canonical model incrementally. Starting from a single MCS (the "root"), successors are built one at a time. The key features:

1. **Single-step witness lemma**: Given MCS w containing F(phi), there exists an MCS v with phi in v and all G-content of w in v (i.e., w R_G v). This is the `temporal_theory_witness_exists` theorem in TM's codebase (sorry-free).

2. **Fair scheduling**: To ensure ALL F-obligations are resolved, GHR use an enumeration argument. Every (position, formula) pair is eventually scheduled for resolution. This corresponds exactly to the dovetailed chain construction in `DovetailedChain.lean`.

3. **Chain construction**: The omega-chain M_0, M_1, M_2, ... is built so that each M_{n+1} is a constrained successor of M_n that targets a scheduled F-obligation.

**Relation to simultaneous induction**: GHR's construction is NOT a simultaneous induction on formula depth. It is a DIRECT construction of the full canonical model, with the truth lemma proved afterward by ordinary induction on formula complexity. The "step-by-step" refers to the model construction, not the truth lemma proof.

**Fair scheduling and S5**: GHR handle ONLY pure temporal logic (Kt, Kt.4, etc.). They do NOT handle S5 modal saturation. The modal dimension is absent from their construction.

**Frame conditions**: GHR work with various temporal frame classes (linear, branching, dense, discrete). For linear time, they use the linearity axiom which corresponds to TM's `temp_linearity`.

**Confidence**: HIGH — The step-by-step construction is well-characterized.

### 1.3 Product Logic Literature (Gabbay/Kurucz/Wolter/Zakharyaschev 2003)

**Completeness technique for S5 x temporal products**: The GKWZ book uses the **product finite model property** (product FMP) via the **finite depth method** for products of transitive logics. The technique:

1. Given a satisfying model, truncate to depth n (the modal/temporal depth of the formula).
2. Show the truncation preserves truth up to depth n.
3. The resulting model is finite.

This gives FMP and hence **weak completeness**, NOT canonical completeness. The product FMP is a decidability/complexity tool, not a frame characterization tool.

**Canonical completeness for products**: GKWZ discuss canonical completeness only for specific products where the component logics are both canonical. S5 is canonical (its canonical frame is an equivalence relation). Basic tense logic Kt is canonical. However, the PRODUCT S5 x Kt need not be canonical even if both components are — the interaction between dimensions can break canonicity.

**Interaction axioms**: GKWZ classify products by their interaction:
- **Pure fusion** (independent combination): No interaction axioms. Completeness transfers automatically from components.
- **Full product** (shared frame): Strong interaction. Completeness requires product-specific techniques.
- **Intermediate** (fusion + interaction axioms): This is TM's setting.

For TM specifically, the interaction axioms are:
- `modal_future`: `□φ → □Gφ` (box distributes into future)
- `temp_future`: `□φ → G□φ` (box persists across time)
- `temp_linearity`: `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` (linear time)

These axioms are all Sahlqvist or nearly Sahlqvist, which suggests canonical completeness should be achievable. The `modal_future` and `temp_future` axioms together imply that □ is "time-invariant" — box content is preserved across the entire temporal chain. This is precisely the `parametric_box_persistent` theorem (sorry-free) in the codebase.

**Confidence**: MEDIUM — The general product logic theory is clear, but specific completeness techniques for TM's exact combination are not directly addressed in the literature.

### 1.4 Important Correction to Report 19

Report 19 (Section 4) incorrectly describes TM's interaction axioms:
- Report 19 states `modal_future` as `□G(φ) → G(□φ)`. **Actual**: `□φ → □Gφ` (Axioms.lean:311)
- Report 19 states `temp_future` as `G(φ) → □F(φ)`. **Actual**: `□φ → G□φ` (Axioms.lean:318)

The actual axioms are strictly WEAKER than what Report 19 claims. Both actual axioms have `□φ` as antecedent — they only apply to necessary truths. This is significant: the actual axioms do NOT establish any connection from purely temporal formulas (G(φ)) to modal ones (□), or vice versa. The modal-temporal interaction is one-directional: box content propagates into the temporal chain, but temporal content does NOT propagate into the modal dimension.

This one-directional interaction is GOOD for the simultaneous induction approach: it means the temporal construction at each depth level does not need to worry about modal side-effects beyond what boxClassFamilies already handles.

---

## Part 2: TM-Specific Adaptations

### 2.1 Task Semantics vs Standard Kripke Semantics

TM uses task semantics where:
- Worlds are (history, time) pairs, not atomic points
- Modal accessibility is: all histories in the bundle at the same time
- Temporal accessibility is: different times along the same history

The witness construction for forward_F needs: given F(phi) in fam.mcs(t), find s >= t with phi in fam.mcs(s), **within the same family**. This is a STRONGER requirement than standard Kripke semantics because in Kripke semantics, the temporal witness just needs to be any world accessible via the temporal relation, whereas in task semantics it must be along the SAME history.

**Impact on simultaneous induction**: The same-family requirement is the fundamental reason the construction is hard. In standard Kripke completeness (Goldblatt style), the canonical temporal relation R_G is defined globally and witnesses can be ANY MCS satisfying the right properties. In TM's task semantics, witnesses must be within the pre-built family chain.

**Assessment**: This is NOT an obstacle for simultaneous induction per se — it is the obstacle for ANY completeness approach. The simultaneous induction approach handles it by building the chain BEFORE proving the truth lemma at each depth level, using lower-depth truth to establish witness consistency.

### 2.2 Reflexive Temporal Order

TM uses `t <= s` (reflexive) for G(phi), meaning G(phi) -> phi is valid (axiom `temp_t_future`). This has several consequences:

1. **Simplification**: Reflexivity means the chain construction does not need to worry about strict vs non-strict witnesses. When we need s >= t with phi in chain(s), s = t is a valid choice if phi is already in chain(t).

2. **Forward_F with reflexivity**: F(phi) = neg(G(neg(phi))). By reflexivity and MCS properties: F(phi) in M implies phi in M OR there exists proper future s > t with phi in chain(s). The reflexive case (phi already in M) is trivially handled.

3. **Interaction with induction**: Reflexivity means that the "base case" of temporal resolution is trivial — a formula that holds now satisfies both G and H vacuously for the present time. This HELPS the inductive construction.

**Assessment**: Reflexivity strictly SIMPLIFIES the construction. No modification needed.

### 2.3 S5 Equivalence Classes and boxClassFamilies

The `boxClassFamilies` construction (UltrafilterChain.lean:2612) builds the set of all shifted SuccChainFMCS families that share the same box-class (i.e., same box content). The key theorems are:

- `boxClassFamilies_modal_forward` (sorry-free): Box(phi) in any family implies phi in ALL families at the same time.
- `boxClassFamilies_modal_backward` (sorry-free): phi in ALL families implies Box(phi) in any family.

**Orthogonality with simultaneous induction**: boxClassFamilies handles the MODAL dimension. Simultaneous induction on formula depth handles the TEMPORAL dimension (forward_F, backward_P). These are orthogonal because:

1. The interaction axioms (`modal_future`, `temp_future`) only propagate box content temporally. They do NOT create new temporal obligations from modal ones.
2. `parametric_box_persistent` (sorry-free) ensures box content is time-invariant in SuccChainFMCS. This means the modal dimension is "flat" — identical at all time points.
3. Therefore, the modal truth lemma cases (box forward/backward) do NOT depend on temporal depth, and the temporal truth lemma cases (G forward/backward) do NOT depend on modal depth.

**Assessment**: boxClassFamilies can be used AS-IS. No modification needed for simultaneous induction. The construction is orthogonal to the temporal depth induction.

### 2.4 Interaction Axioms and Cross-Level Dependencies

Analyzing each interaction axiom:

**`modal_future` (□φ → □Gφ)**: If □φ holds, then □Gφ holds. For the truth lemma:
- Forward: □Gφ in MCS implies Gφ in all families (by modal forward). This is handled by `boxClassFamilies_modal_forward` + `forward_G`.
- Backward: Requires showing that if Gφ holds at all times in all families, then □Gφ is in the MCS. By `boxClassFamilies_modal_backward`, it suffices to show Gφ in all families, which follows from the temporal backward case.

No cross-level dependency: the axiom relates box-G to box, but both the box-direction and the G-direction use the SAME formula phi at the SAME depth.

**`temp_future` (□φ → G□φ)**: If □φ holds, then G□φ holds. This is captured by `parametric_box_persistent` — box content persists across time. For the truth lemma, this is used in the forward direction for G when the subformula is □φ. Since □φ is at the same depth as G□φ minus 1, the inductive hypothesis covers it.

No cross-level dependency.

**`temp_linearity`**: This axiom constrains the temporal relation to be linear. It is used in the MODEL construction (ensuring the canonical temporal order is linear) but does NOT appear in the truth lemma proof. It is used in ParametricCanonicalTaskFrame to establish the frame conditions.

No cross-level dependency.

**Assessment**: None of the interaction axioms create cross-level dependencies in the simultaneous induction. The modal and temporal dimensions are handled independently. This is because ALL three interaction axioms have `□φ` as their antecedent — they only apply when the formula is already boxed, and the box dimension is handled orthogonally by boxClassFamilies.

---

## Part 3: Integration with Existing Infrastructure

### 3.1 boxClassFamilies (UltrafilterChain.lean)

**Can it be used as-is?** YES.

boxClassFamilies builds S5-saturated families from any starting MCS. The construction is:
1. Take all MCSes W with `box_class_agree M0 W` (same box content as M0)
2. Build SuccChainFMCS from each W
3. Allow arbitrary integer shifts

The key theorems (`boxClassFamilies_modal_forward`, `boxClassFamilies_modal_backward`) are sorry-free and establish modal coherence. They do NOT depend on temporal coherence — they work regardless of how the temporal chain is built.

**For simultaneous induction**: At each depth level k, we build a temporally coherent family using SuccChainFMCS, then embed it into boxClassFamilies for modal saturation. The modal truth lemma cases use boxClassFamilies, the temporal truth lemma cases use the family-level coherence. These are independent.

### 3.2 ParametricCanonicalTaskFrame

**Does simultaneous induction change how the frame is built?** NO.

The `ParametricCanonicalTaskFrame D` (ParametricCanonical.lean:198) is already constructed and proven to satisfy TaskFrame axioms (sorry-free). It is parametric in the duration type D. The frame construction is INDEPENDENT of the truth lemma — it establishes frame-level properties (nullity_identity, forward_comp, converse) from the axioms alone.

The simultaneous induction only affects how the TRUTH LEMMA is proven, specifically how forward_F/backward_P are established. The frame itself does not change.

### 3.3 SuccChainFMCS

**Can it be reused?** YES, and it SHOULD be.

`SuccChainFMCS` (SuccChainFMCS.lean) builds an omega-chain of MCSes with the Succ relation (g_persistence, h_content, f_step properties). The key features:
- `forward_G` (sorry-free): G(phi) in chain(t) implies phi in chain(t+1)
- `backward_H` (sorry-free): H(phi) in chain(t) implies phi in chain(t-1)
- `f_step` for restricted chains (sorry-free via `constrained_predecessor_restricted`)

The f_step property ensures F-obligations are tracked (not silently dropped). For the restricted chain (`RestrictedTemporallyCoherentFamily`), this gives sorry-free forward_F within the deferralClosure.

**For simultaneous induction**: SuccChainFMCS provides the TEMPORAL CHAIN at each depth level. The restricted chain gives forward_F for formulas within deferralClosure(phi), which is exactly the set of formulas at depth <= depth(phi). The simultaneous induction leverages this: at depth k, we use the restricted chain for formulas up to depth k.

### 3.4 RestrictedTruthLemma

**Relationship to depth-k truth lemma**: The existing `restricted_truth_lemma` (RestrictedTruthLemma.lean:291) proves:

> For psi in subformulaClosure(phi):
> psi in restricted_chain(n) <-> psi in restricted_chain_ext(n)

This establishes that for formulas WITHIN the closure, the restricted DRM membership equals the Lindenbaum extension membership. This is exactly a "depth-k truth lemma" where k = depth(phi).

**Key insight**: The restricted truth lemma already IS the simultaneous induction's per-level truth lemma, specialized to the case where the depth bound is determined by a specific formula phi. The simultaneous induction would generalize this by building the chain for increasing depths.

However, the restricted truth lemma has a subtlety: it proves equivalence between DRM membership and EXTENSION membership, not between MCS membership and SEMANTIC TRUTH. The gap is:
- DRM membership <-> extension membership (restricted_truth_lemma, sorry-free)
- Extension membership <-> semantic truth (requires ParametricTruthLemma, which needs h_tc)

The second step is where forward_F is needed, and this is the sorry.

### 3.5 The Sorry: bfmcs_from_mcs_temporally_coherent

**Type signature**: The sorry requires building a `TemporallyCoherent` family — i.e., an FMCS satisfying both `forward_F` and `backward_P` at the FAMILY level (not just bundle level).

**Mapping simultaneous induction onto this**: The simultaneous induction approach would NOT directly close this sorry. Instead, it would REPLACE the proof strategy:

1. **Current strategy**: Build BFMCS → prove temporal coherence → apply truth lemma.
2. **Simultaneous induction strategy**: Build the temporal chain (SuccChainFMCS) → prove a RESTRICTED truth lemma at each depth → compose into the full truth lemma.

The key difference: the simultaneous induction avoids needing to prove temporal coherence for ALL formulas at once. Instead, it proves temporal coherence incrementally by depth, using the restricted chain construction (which IS sorry-free) at each level.

**Concrete mapping**:
1. At depth 0 (atoms): trivial — atom truth = MCS membership by definition.
2. At depth k+1:
   - Build RestrictedTemporallyCoherentFamily for the formula at depth k+1.
   - Use restricted_truth_lemma to establish truth for subformulas (depth <= k) — this uses the IH.
   - The forward_F needed at depth k+1 uses the restricted chain's f_step property for formulas in deferralClosure, which includes all formulas at depth <= k+1.
3. Compose all depth levels into the full truth lemma.

**The gap in this mapping**: Step 2 requires that the SAME chain works for all formulas up to depth k+1. The restricted chain is built for a SPECIFIC formula phi. If we change phi (i.e., go to depth k+2), we get a DIFFERENT chain. The truth lemma at depth k may not hold for the new chain.

**This is the fundamental question**: Can a single chain serve all depth levels, or does each depth level require its own chain?

---

## Part 4: Feasibility Assessment

### 4.1 Estimated Lean Proof Effort

| Component | Effort | Status |
|-----------|--------|--------|
| Close FMP sorries (mcs_all_future/past_closure) | 1-2 hours | CLOSABLE NOW |
| Depth-indexed restricted chain | 10-15 hours | NEW construction needed |
| Per-depth truth lemma (generalize restricted_truth_lemma) | 5-10 hours | Extends existing |
| Composition into full truth lemma | 5-8 hours | NEW |
| Integration with boxClassFamilies for modal cases | 3-5 hours | REUSE existing |
| **Total for canonical completeness** | **25-40 hours** | |

### 4.2 Reusable Infrastructure

**Keep as-is**:
- `ParametricCanonicalTaskFrame` — frame construction (sorry-free)
- `boxClassFamilies` + modal coherence theorems (sorry-free)
- `parametric_box_persistent` — box persistence (sorry-free)
- `SuccChainFMCS` — temporal chain builder (sorry-free)
- `RestrictedTemporallyCoherentFamily` + `build_restricted_tc_family` (sorry-free)
- `restricted_truth_lemma` — per-formula truth lemma (sorry-free)
- `ParametricCanonicalTaskModel` — model definition (sorry-free)
- Soundness theorem (sorry-free)

**Needs replacement or extension**:
- `bfmcs_from_mcs_temporally_coherent` sorry — replaced by depth-indexed construction
- `ParametricTruthLemma` — needs to be re-proved using simultaneous induction, or the depth-indexed version needs to compose into it
- `DovetailedChain` — likely superseded by depth-indexed approach

### 4.3 Risk Assessment

**HIGH RISK: Single-chain vs multi-chain**
The biggest risk is the "single chain for all depths" question identified in 3.5. If each depth level requires a different chain, the composition step becomes extremely complex — we'd need to show that truth at depth k on chain_k implies truth at depth k on chain_{k+1}. This is not obviously true.

**MEDIUM RISK: Restricted truth lemma gap**
The restricted truth lemma proves DRM <-> extension equivalence, not MCS <-> semantic truth. Bridging this gap requires showing that the extension (Lindenbaum completion of the restricted chain) gives a valid MCS for semantic evaluation. This bridge exists conceptually but has not been formalized.

**MEDIUM RISK: deferralClosure vs subformulaClosure**
The restricted chain works within `deferralClosure(phi)`, while the truth lemma needs `subformulaClosure(phi)`. These are related but distinct. The inclusion `subformulaClosure ⊆ deferralClosure` holds (verified in codebase), so this should work, but the exact relationship needs careful handling.

**LOW RISK: Modal-temporal interaction**
As analyzed in Part 2.4, the interaction axioms do NOT create cross-level dependencies. The modal and temporal dimensions are orthogonal for the truth lemma.

### 4.4 Alternative Approaches

**Alternative 1: Direct dovetailed chain with F-persistence proof**
Instead of simultaneous induction, prove that the dovetailed chain (DovetailedChain.lean) satisfies forward_F directly. The blocker is F-persistence: F(phi) in chain(t) does not imply F(phi) in chain(t+1) for arbitrary Lindenbaum extensions. But the restricted chain DOES have f_step. If we can show that Lindenbaum extension preserves the restricted f_step property for formulas within deferralClosure, this gives forward_F directly.

**Estimated effort**: 15-25 hours. Risk: the F-persistence argument may fail for full MCS (as documented in DovetailedChain.lean:478).

**Alternative 2: FMP completeness only (Phase 1)**
Close the two FMP sorries (`mcs_all_future_closure`, `mcs_all_past_closure`) to get weak completeness. This is 1-2 hours and gives an immediate, publishable result. Canonical completeness can be deferred.

**Estimated effort**: 1-2 hours. Risk: minimal. This does NOT achieve the full representation theorem but gives weak completeness + decidability.

**Alternative 3: Algebraic / Stone duality approach**
Factor through the Lindenbaum algebra (already partially built in `TenseS5Algebra.lean`). Use Stone representation to embed ultrafilters into a frame, then show the frame is a task frame. This avoids the direct canonical model construction entirely.

**Estimated effort**: 30-50 hours. Risk: HIGH — the algebraic infrastructure is less developed than the direct construction.

### 4.5 Recommendation

**Phase 1 (immediate, 1-2 hours)**: Close FMP sorries for weak completeness. This is the highest-value, lowest-risk action.

**Phase 2 (canonical completeness, 25-40 hours)**: Pursue the simultaneous induction approach, but with a key decision point: resolve the single-chain vs multi-chain question FIRST (estimated 3-5 hours of analysis). If single-chain works, proceed with depth-indexed construction. If multi-chain is required, evaluate Alternative 1 (direct F-persistence proof) as potentially simpler.

The existing infrastructure is remarkably well-suited to the simultaneous induction approach. The restricted truth lemma, SuccChainFMCS, and boxClassFamilies provide almost all the needed components. The main gap is the composition/bridging step from restricted to full truth.

---

## References

### Primary Sources

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications. Chapter 3: Canonical models for tense logics.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press. Step-by-step construction.
- Gabbay, D., Kurucz, A., Wolter, F., Zakharyaschev, M. (2003). *Many-Dimensional Modal Logics: Theory and Applications*. Elsevier. Product FMP, interaction axioms.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press. Chapter 4: Canonical models.
- Hodkinson, I. and Reynolds, M. (2007). "Temporal Logic." Chapter 11 in *Handbook of Modal Logic*.

### Codebase References

- `ParametricCanonicalTaskFrame`: ParametricCanonical.lean:198
- `boxClassFamilies`: UltrafilterChain.lean:2612
- `boxClassFamilies_modal_forward`: UltrafilterChain.lean:2654 (sorry-free)
- `boxClassFamilies_modal_backward`: UltrafilterChain.lean:2737 (sorry-free)
- `SuccChainFMCS`: SuccChainFMCS.lean
- `RestrictedTemporallyCoherentFamily`: SuccChainFMCS.lean:6294
- `restricted_truth_lemma`: RestrictedTruthLemma.lean:291
- `ParametricTruthLemma`: ParametricTruthLemma.lean (bidirectional, needs h_tc)
- `parametric_box_persistent`: ParametricTruthLemma.lean (sorry-free)
- `modal_future` axiom: Axioms.lean:311 — `□φ → □Gφ`
- `temp_future` axiom: Axioms.lean:318 — `□φ → G□φ`
- `temp_linearity` axiom: Axioms.lean:344
- `temp_t_future` axiom: Axioms.lean:290 — `Gφ → φ`
- `temp_t_past` axiom: Axioms.lean:304 — `Hφ → φ`
