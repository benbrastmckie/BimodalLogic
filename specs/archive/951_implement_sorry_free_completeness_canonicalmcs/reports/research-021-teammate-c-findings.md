# Research Report: Task #951 (research-021-teammate-c-findings)

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Focus**: Creative alternative exploration -- outside-the-box approaches
**Dependencies**: research-001 through research-020 (prior research corpus)
**Sources/Inputs**: Codebase analysis, Mathlib searches, literature survey, mechanized proof surveys
**Artifacts**: this report

## Executive Summary

After reviewing 20+ prior reports and conducting extensive Mathlib/literature searches, this report presents fresh perspectives that prior research has not considered or has dismissed prematurely. The key insight emerging from this analysis is that the project may be fighting the formalization rather than working with it, and several structural reorganizations could unlock a sorry-free proof.

The five most promising fresh directions are:

1. **The "Two-Phase" Factored Completeness** -- separate temporal completeness from modal saturation at the THEOREM level, not just the construction level
2. **The Pruning/Decision Procedure Route** (from Doczkal-Smolka) -- completeness as a corollary of decidability
3. **The Synthetic Completeness Pattern** (from From's Isabelle framework) -- abstract away the canonical model into reusable locale/typeclass
4. **The "Lazy Witness" BFMCS** -- defer witness family temporal coherence until needed
5. **The Fragment-Indexed BFMCS** -- use BidirectionalFragment as D directly, bypassing Int transfer entirely

## Part A: What Would Mathlib Experts Do?

### A1. Observation: The Project Has Completeness Infrastructure Working Backwards

Mathlib's first-order logic infrastructure (`FirstOrder.Language.Theory`) already has:
- `Theory.IsMaximal`: Maximal consistent theories (identical concept to MCS)
- `Theory.CompleteType`: Complete types = maximal consistent extensions of theories
- `Theory.isSatisfiable_iff_isFinitelySatisfiable`: Compactness via ultraproducts
- `ElementaryEmbedding.map_sentence`: Truth preservation under embeddings
- Ultraproduct infrastructure (`Ultraproduct.sentence_realize` = Los's theorem)

A Mathlib expert would likely ask: "Why not encode TM as a first-order theory and use the existing completeness infrastructure?" The answer is that TM is NOT first-order (it has modal and temporal operators), but the question points to a real insight: **the project is rebuilding ALL completeness infrastructure from scratch when much of the MCS machinery could be abstracted**.

**Actionable insight**: The Lindenbaum lemma, MCS properties, and Zorn-based extension are already proven in this project. The gap is NOT in the MCS infrastructure -- it is specifically in the **combination of temporal coherence and modal saturation**. A Mathlib expert would focus narrowly on THAT combination, not rebuild the world.

### A2. The Lindenbaum-Algebra/Ultrafilter Path

The project already has `Theories/Bimodal/Metalogic/Algebraic/` with:
- `LindenbaumQuotient.lean`: The Lindenbaum-Tarski algebra (`LindenbaumAlg`)
- `BooleanStructure.lean`: Boolean algebra structure on the quotient
- `UltrafilterMCS.lean`: Bijection between ultrafilters and MCSes (with sorries)
- `InteriorOperators.lean`: Modal operators as interior operations on the algebra

This algebraic path was started but abandoned (Task 700). The Jonsson-Tarski representation theorem says: **every Boolean algebra with operators (BAO) is represented by an algebra of sets on a relational structure**. Concretely:
- The Lindenbaum algebra of TM is a BAO (with `G`, `H` as operators)
- Its Stone space (= ultrafilters = MCSes) naturally carries a Kripke structure
- The accessibility relation on MCSes IS CanonicalR
- Completeness follows from the representation theorem

**Why this might bypass the current blocker**: The algebraic approach doesn't need to construct Int-indexed families. It works with the FULL set of ultrafilters/MCSes as worlds, with CanonicalR as accessibility. The truth lemma is a direct consequence of the Stone representation. There is no "temporal coherence" to worry about because the algebraic approach doesn't decompose into per-family temporal properties -- it works globally.

**Status in Mathlib**: `BoolAlg` and `FinBoolAlg` categories exist. Stone duality is partially formalized. The interior operator structure is NOT in Mathlib (would need custom work).

**Risk**: The Algebraic/ directory has sorries in the ultrafilter-MCS correspondence. Completing this path requires finishing a parallel infrastructure. But the AMOUNT of sorry-free work already done is substantial.

### A3. The Ultrafilter Compactness Route

Mathlib has `ultrafilter_compact : CompactSpace (Ultrafilter alpha)` -- the space of ultrafilters on any type is compact. Combined with `Filter.mem_iff_ultrafilter` (filter membership via ultrafilters), there's a compactness-based route to completeness.

The standard route: prove that the set of satisfiable formulas forms a filter on `LindenbaumAlg`, then use compactness to extend to an ultrafilter (= MCS = model). This avoids the explicit Zorn's lemma construction entirely.

## Part B: Alternative Mathematical Frameworks

### B1. Coalgebraic Semantics

Mathlib has `CategoryTheory.Endofunctor.Coalgebra` with a full category structure. In coalgebraic modal logic, models are coalgebras for an endofunctor, and completeness follows from cofree coalgebra existence.

**Assessment**: This is mathematically elegant but would require encoding TM's bimodal structure as an endofunctor on Set, which is highly non-trivial. The temporal operators G/H with T-axioms (reflexive) and 4-axioms (transitive) correspond to a specific "type functor" related to preorder coalgebras. While Mathlib's coalgebra infrastructure exists, the formalization effort would be enormous. **Not recommended as a primary path.**

### B2. Point-Free (Locale-Theoretic) Approach

Instead of constructing points (worlds) and then building a frame, work directly with the lattice of "open sets" (= definable sets of worlds). The canonical frame is the spectrum of the Lindenbaum algebra.

**Assessment**: This is essentially the algebraic approach (A2 above) viewed through a topological lens. It doesn't add new content but may provide cleaner formalization patterns. Mathlib's `PrimeSpectrum` infrastructure handles prime ideals of commutative rings; the analogous construction for Boolean algebras uses ultrafilters instead. **Subsumes into A2.**

### B3. Game-Theoretic Semantics

Replace truth-at-a-world with winning strategies in evaluation games. For modal logic, Eloise chooses witnesses for existential operators (F, Diamond), Abelard chooses for universal operators (G, Box). Completeness = existence of winning strategy iff formula is consistent.

**Assessment**: Game semantics are well-studied for modal mu-calculus and CTL* but I found no Lean/Mathlib infrastructure. Building this from scratch would be a multi-month project. **Not recommended.**

### B4. The Pruning/Decision Procedure Route (Doczkal-Smolka Style)

This is the most promising alternative framework. The coq-community/comp-dec-modal project proves completeness for K, K* (tense logic with past operators), CTL, and PDL using a **pruning-based algorithm**:

1. For a given formula phi, compute a finite set of "clauses" (similar to subformula closure)
2. Build a pruning algorithm that iteratively removes unsupportable clauses
3. If the algorithm terminates with phi's clause remaining: construct a finite model
4. If phi's clause is pruned: construct a Hilbert refutation

**Key insight for this project**: K* IS a tense logic with past operators, which is closely related to TM. The pruning approach gives:
- **Completeness as a corollary of decidability** (not independent)
- **Finite model property for free**
- **No need for Int-indexed families AT ALL** -- the model is finite
- **No temporal coherence problem** because the model is constructed directly from the pruning tableau

**Why this could work for TM**: TM extends K* with S5-style modal operators and task_rel structure. The modal S5 fragment has the finite model property. The temporal tense fragment has the finite model property. The combination may also have it (needs investigation).

**Risk**: TM's interaction between modal and temporal operators might break the finite model property. The task_rel structure adds complexity. But even if the full FMP fails, the pruning technique could handle the temporal part while modal saturation uses the existing Zorn approach.

**This is the approach I most strongly recommend investigating further.**

## Part C: Radical Simplification Ideas

### C1. Change the Statement of Completeness

The current theorem requires:
```lean
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B
```

This single theorem must simultaneously produce: (1) a BFMCS, (2) containing Gamma, (3) temporally coherent, (4) modally saturated.

**Radical simplification**: What if we factored this into two theorems that compose?

```
-- Theorem 1: Temporal coherence (ALREADY PROVEN sorry-free for Fragment/CanonicalMCS)
theorem temporal_coherent_bfmcs_exists_int : exists B : BFMCS Int, ... /\ B.temporally_coherent

-- Theorem 2: Modal saturation preserves temporal coherence
theorem modal_saturation_preserves_tc : B.temporally_coherent -> exists B', B'.temporally_coherent /\ is_modally_saturated B'
```

The problem is that Theorem 2 is where the difficulty lies -- modal saturation via Zorn adds witness families, and those families need temporal coherence. But here's the insight:

**What if witness families DON'T need temporal coherence?**

### C2. Witness Families Don't Need Full Temporal Coherence (The "Lazy" Approach)

Looking at the truth lemma (`canonical_truth_lemma` in CanonicalConstruction.lean), the backward direction for G/H needs `h_tc` (temporal coherence) ONLY for the family being evaluated. Specifically at line 307:
```lean
obtain <h_forward_F, h_backward_P> := h_tc fam hfam
```

This uses `h_tc` for `fam` specifically. For the box case (line 280), it uses `modal_forward` which requires the formula to be in ALL families, and `modal_backward` which requires it in all families to conclude it's boxed.

**Key observation**: The truth lemma needs temporal coherence ONLY for the eval family. Witness families are used only via `modal_forward`/`modal_backward`, which don't require temporal coherence.

**What this means**: We could define `partially_temporally_coherent` as:
```
def partially_temporally_coherent (B : BFMCS Int) : Prop :=
  let <h_F, h_P> := ... -- forward_F/backward_P for eval_family ONLY
  True
```

Then `fully_saturated_bfmcs_exists_int` becomes:
1. Start with eval_family from the dovetailing chain (temporally coherent)
2. Add modal witness families (constant families, NOT temporally coherent)
3. The truth lemma only needs eval_family's temporal coherence

**BUT**: Does the truth lemma actually work with this? Let me trace the proof more carefully.

The G backward case (line 304-319) does:
```
obtain <h_forward_F, h_backward_P> := h_tc fam hfam
```
where `fam` ranges over ALL families in the bundle (via the induction hypothesis). So if `fam` is a witness family (not the eval family), we still need `h_tc fam hfam`.

**This means the truth lemma AS CURRENTLY STATED needs temporal coherence for ALL families.**

### C3. Restructure the Truth Lemma (The Real Radical Move)

The truth lemma currently proves `phi in fam.mcs t <-> truth_at ... t phi` for ALL families. But for completeness, we only need it for the EVAL family. What if we proved a WEAKER truth lemma?

```lean
theorem restricted_truth_lemma
    (B : BFMCS Int) (h_tc_eval : temporal_coherent_for_family B B.eval_family)
    (h_sat : is_modally_saturated B)
    (t : Int) (phi : Formula) :
    phi in B.eval_family.mcs t <-> truth_at ... t phi
```

The difference: this doesn't universally quantify over all families. For the G backward case, we need `forward_F` only for the eval family (which we have). For the box backward case, we need to show that if `phi` is in ALL families' MCS at t, then `Box phi` is in eval_family's MCS at t. This is `modal_backward`, which requires `phi in ALL families` -- but we don't need to PROVE `phi in fam'.mcs t` via the truth lemma for fam'. Instead, `modal_backward` is a property of the BFMCS.

**Wait** -- the box forward case (line 274-282) does:
```
obtain <fam', hfam', h_eq> := h_sigma_mem
-- ... (ih fam' hfam' t).mp h_psi_mcs
```

This uses the induction hypothesis FOR fam' (an arbitrary family). So the truth lemma needs to hold for ALL families, not just the eval family.

**The real question**: Can we restructure the truth lemma to avoid needing the full IH for all families? The box case quantifies over histories in Omega, where each history comes from a family. We need the forward direction (membership implies truth) for ALL families.

**Alternative**: Use a DIFFERENT characterization of Box truth. Instead of quantifying over Omega (histories from bundle families), quantify over ALL POSSIBLE histories compatible with the task frame. Then Box truth follows from soundness (which is already proven). This is the "validity-based" approach.

But this changes the semantics fundamentally -- Box would quantify over all histories, not just bundle histories. This IS the standard semantics. The bundle restriction was introduced precisely to make the truth lemma provable. Returning to standard semantics would require proving the truth lemma directly, which was the original hard problem.

### C4. The Minimal Viable Completeness

What is the absolute minimum needed for the completeness theorem? Let's trace backwards:

```
standard_weak_completeness : valid phi -> Nonempty (DerivationTree [] phi)
  = By contraposition: not provable -> not valid
  = not provable -> exists model where phi false
  = ContextConsistent [phi.neg] -> satisfiable Int [phi.neg]
```

So we need: given a consistent formula, construct a model. The model needs:
- A TaskFrame Int (WorldState, task_rel with nullity + compositionality)
- A TaskModel (valuation)
- A set of WorldHistories (Omega, shift-closed)
- A distinguished history tau in Omega
- A time t with the formula true at (tau, t)

The BFMCS is just machinery for CONSTRUCTING this model. If we can construct the model without BFMCS, we bypass ALL the BFMCS-related sorries.

**Direct construction without BFMCS**:

1. Given consistent phi, extend {phi} to MCS M0 via Lindenbaum
2. Build BidirectionalFragment from M0 (sorry-free, CanonicalCompleteness.lean)
3. The fragment is totally ordered and has forward_F/backward_P (sorry-free)
4. Define: WorldState = CanonicalWorldState, task_rel = canonical_task_rel (sorry-free, CanonicalConstruction.lean)
5. For each MCS M in the fragment, define a WorldHistory by... WHAT?

The challenge: a WorldHistory maps `Int -> WorldState` (with domain, convexity, respects_task). We need to map integers to fragment elements.

**This is precisely the Fragment-to-Int transfer problem.** The fragmentFMCS gives an FMCS over the BidirectionalFragment. Converting to FMCS Int requires an order-preserving map `Int -> BidirectionalFragment` -- which is the chain-embedding problem.

### C5. Use BidirectionalFragment AS the Domain (No Transfer Needed)

**The most radical simplification**: Don't use Int at all. Use BidirectionalFragment as D.

Requirements for D in TaskFrame: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

The BidirectionalFragment is linearly ordered (proven). It does NOT have AddCommGroup structure (the core obstruction identified in research-019).

But what if we could prove completeness for a WEAKER TaskFrame?

```lean
structure WeakTaskFrame (D : Type*) [LinearOrder D] where
  WorldState : Type
  -- No task_rel at all!
```

The truth_at definition for temporal operators only uses `<=` on D:
```
truth_at M Omega tau t (G phi) = forall s >= t, truth_at M Omega tau s phi
```

The task_rel is NOT used in truth_at. It appears only in WorldHistory.respects_task.

**If we could define WorldHistory without respects_task**, we could use D = BidirectionalFragment with ONLY LinearOrder, no group structure needed.

But WorldHistory.respects_task IS part of the definition. And the TaskFrame with its group structure IS part of the semantics by design (the paper defines it this way).

**Modified proposal**: Define completeness with respect to a WeakTaskFrame (just WorldState, no task_rel/group), prove it sorry-free, then show that every WeakTaskFrame model can be enriched to a full TaskFrame model (by adding trivial task_rel and D=Int wrapping).

This separates the MATHEMATICAL content (temporal+modal completeness) from the STRUCTURAL overhead (group structure for D). The mathematical completeness is in the WeakTaskFrame; the TaskFrame enrichment is trivial.

## Part D: Lessons from Related Domains

### D1. Bentzen's S5 Lean Formalization

Key structural insight from Bentzen's `mpl` repository: The S5 completeness proof in Lean uses the standard Henkin approach with a SINGLE canonical model:
- Worlds = all MCSes
- Accessibility = equivalence relation (universal for S5)
- Valuation = MCS membership
- Truth lemma by induction on formula complexity

**No families, no bundles, no temporal coherence.** The box case works because S5 accessibility is universal: Box phi in M iff phi in ALL MCSes. The backward direction uses Lindenbaum extension to find a witness MCS.

**Lesson for TM**: The BFMCS bundle was introduced because the modal component uses S5-style box (all families see all families). But the temporal component adds G/H which need forward/backward propagation. The BFMCS tries to combine both into a single structure. Bentzen's approach suggests: **handle the modal S5 component separately, using the standard S5 canonical model.**

### D2. Doczkal-Smolka's Coq K* Completeness

K* is basic tense logic with G, H, F, P operators (no modality). Their completeness proof uses:
1. **Subformula closure** (finite set of relevant formulas)
2. **Pruning tableau** constructing finite models
3. **Hilbert derivation extraction** from refutation proofs

**Lesson for TM**: TM combines K* (tense) with S5 (modal). If we could prove completeness for the tense fragment and the modal fragment SEPARATELY, then combine them, we might avoid the interference that causes the sorry.

**The combination lemma would be**: If phi is consistent in TM, it is consistent in the temporal fragment and the modal fragment. A model can be built for each fragment, and the product model satisfies both.

### D3. From's Isabelle Synthetic Completeness Framework (CPP 2025)

Jireh From's framework mechanizes an abstract Lindenbaum lemma and defines abstract canonical models parametric over:
- A notion of consistency
- A notion of derivability
- A set of formulas

The truth lemma is proven generically for ANY logic satisfying certain interface requirements (captured as Isabelle locales).

**Lesson for TM**: The project should identify the EXACT interface requirements that the truth lemma needs, then verify them modularly. The current approach has everything interleaved. A cleaner architecture would have:

```
-- Interface
class CompletenessLogic (L : Type) where
  consistent : Set L -> Prop
  derivable : List L -> L -> Prop
  lindenbaum : consistent S -> exists M, S <= M /\ maximal_consistent M
  -- ... other requirements

-- Generic truth lemma
theorem generic_truth_lemma [CompletenessLogic Formula] ...
```

### D4. The Adequate Set Method (Solovay 1973)

For temporal logics of discrete time (integers), the standard Lindenbaum approach can fail because strong completeness fails (the set {FGneg p, Fp, FFp, FFFp, ...} is finitely satisfiable but not satisfiable over Z).

However, WEAK completeness (single formula) still holds. The adequate set method restricts MCSes to a finite set of formulas (the subformula closure plus some auxiliaries). This gives:
- Finite model property
- Decidability
- Weak completeness

**This might be directly applicable**: Since we only need weak completeness (single formula satisfiable), the adequate set method could give a finite model construction that avoids all the Int-indexed family machinery.

## Part E: The "Elegant" Path

### E1. The Textbook-Beautiful Proof

If designing from scratch for a textbook, the proof would have this structure:

1. **Define the Lindenbaum algebra** of TM (quotient of formulas by provable equivalence)
2. **Show it's a Boolean algebra with temporal and modal operators** (BAO with G, H)
3. **Apply Stone/Jonsson-Tarski representation**: ultrafilters of the Lindenbaum algebra = worlds of the canonical model
4. **The canonical model**: worlds = MCSes = ultrafilters, accessibility = CanonicalR, time = CanonicalMCS preorder
5. **Truth lemma**: direct from the representation theorem
6. **Completeness**: consistent phi is in some ultrafilter, that ultrafilter satisfies phi in the canonical model

This is 6 clean steps with clear separation of concerns. The project's current approach jumps from step 4 to step 6, trying to simultaneously handle BFMCS construction, temporal coherence, and modal saturation.

### E2. How Do You KNOW a Proof Is on the Right Track?

Signs that a formalization is fighting the math:
- **20+ research reports for a single sorry**: The sorry is not a proof difficulty; it's an architectural mismatch
- **Multiple blocked approaches**: When many approaches fail at the same point, the STATEMENT is likely wrong
- **Composition failure**: When two proven components can't be combined, the interface is wrong

Signs that a formalization is on the right track:
- **Each sorry is independent**: Fixing one doesn't create new ones
- **The proof sketch is simple**: The formal version adds detail but not new ideas
- **Structures compose naturally**: `A sorry-free + B sorry-free => A+B sorry-free` should work

**Diagnosis for task 951**: The current architecture has an inherent tension between temporal coherence (per-family property) and modal saturation (cross-family property). Witness families added for modal saturation must be temporally coherent, but temporal coherence requires a chain embedding, which requires the chain to hit all witnesses, which creates circular dependencies.

**The resolution must eliminate this circularity.** This means either:
1. Proving witness families are automatically temporally coherent (unlikely given the analysis)
2. Proving the truth lemma doesn't need witness family temporal coherence (C3 above)
3. Combining temporal and modal construction into a single step (interleaving)
4. Changing the architecture so the circularity doesn't arise (algebraic, decision procedure)

### E3. My Recommended "Elegant" Path

**Step 1**: Factor the completeness proof into temporal + modal components.

Define `TemporallyComplete B` = forward_F/backward_P for eval family only.
Define `ModallyComplete B` = is_modally_saturated B.

**Step 2**: Prove a restricted truth lemma that only needs eval family temporal coherence.

Modify the truth lemma to use a two-tier argument:
- For the eval family: full induction with temporal coherence
- For witness families: only the FORWARD direction of the IH (membership => truth), which does NOT need temporal coherence

**Step 3**: Check if Step 2 actually works by examining the box backward case.

The box backward case says: if phi is true at t in ALL histories sigma, then Box phi is in fam.mcs t. This uses `modal_backward`, which says: if phi is in all families' mcs at t, then Box phi is in fam's mcs at t. The premise requires phi to be in all families' mcs at t. For witness families fam', this means we need the BACKWARD direction of the truth lemma for fam' (truth => membership). This is the direction that uses the IH for fam'.

For the backward direction of the truth lemma for fam' (a witness family), we need... the FULL truth lemma for fam'. So we're back to needing temporal coherence for fam'.

**Unless**: we restructure to prove a weaker backward direction for witness families that doesn't need temporal coherence. For example, if witness families are constant (same MCS at all times), then forward_G and backward_H hold trivially (by T-axioms), and forward_F/backward_P are not needed for the box case.

**Wait -- ARE forward_F/backward_P needed for the box case?** Let me check.

The box backward case (line 284-293) uses:
```
have h_psi_all_mcs : forall fam' in B.families, psi in fam'.mcs t := by
  intro fam' hfam'
  have h_truth := h_all (to_history fam') h_in_omega
  exact (ih fam' hfam' t).mpr h_truth
```

Here `ih fam' hfam' t` is the FULL induction hypothesis for fam'. When phi = Box (G psi), the inner formula is G psi. The backward direction (truth => membership) for G psi needs temporal_backward_G, which needs forward_F.

**So yes, forward_F IS needed for the box backward case when the inner formula contains temporal operators.**

**But for the special case of atoms, bot, imp, box (no temporal operators)**: The backward truth lemma for witness families would NOT need forward_F/backward_P. If we could restrict modal saturation to formulas without temporal operators...

**Unfortunately**, Diamond formulas can contain temporal operators: Diamond(G psi) is a valid formula. So witness families might need to witness G psi, requiring forward_F.

### E4. The "Almost Elegant" Path That Could Actually Work

**Constant witness families with temporally saturated MCSes.**

A constant family `fam(t) = M for all t` has:
- forward_G: by T-axiom (G phi in M => phi in M, so G phi in M => phi in fam(t+1) = M). **WORKS.**
- backward_H: by T-axiom (H phi in M => phi in M, so H phi in M => phi in fam(t-1) = M). **WORKS.**
- forward_F: F phi in M (= fam(t)) => exists s >= t with phi in fam(s) = M. This requires `F phi in M => phi in M`. **FAILS in general.**
- backward_P: Symmetric, also FAILS.

`F phi in M => phi in M` is NOT a theorem of TM. It holds iff M is "temporally saturated" (closed under F and P).

**Question**: Can we construct temporally saturated MCSes?

An MCS M is temporally saturated if: `F phi in M => phi in M` and `P phi in M => phi in M`.

This is equivalent to: M contains `F phi -> phi` and `P phi -> phi` for all phi. But `F phi -> phi` is NOT a theorem of TM (it says "if phi holds eventually, it holds now" -- clearly false semantically).

**However**: what if we add formulas to M that make it temporally saturated? Start with seed `{psi} union BoxContent(M0)`, add all instances of `F chi -> chi` and `P chi -> chi`... But this is inconsistent in general. The formula `F(neg p)` is consistent with `p`, but `F(neg p) -> neg p` together with `p` is inconsistent.

So temporally saturated MCSes cannot be constructed in general. This is the same blocker identified in research-019 Section 6.5.

### E5. The "Actually Elegant" Path

After exhaustive analysis, here is what I believe is the most promising path forward:

**Use the CanonicalConstruction.lean infrastructure directly, with the canonical_task_rel that already has sorry-free nullity and compositionality.** The remaining sorry is in `fully_saturated_bfmcs_exists_int`.

The specific gap is: combining temporal coherence (from fragmentFMCS/dovetailing chain) with modal saturation (from Zorn/closure construction).

**The cleanest resolution**: Build the BFMCS in TWO STAGES with a truth lemma that handles each stage differently.

**Stage 1 -- Temporal Core**: Build the eval family from the BidirectionalFragment approach (sorry-free temporal coherence).

**Stage 2 -- Modal Saturation via Fragment-Based Witnesses**: For each Diamond(psi) obligation in the eval family at time t:
1. The eval family's MCS at time t contains Diamond(psi)
2. This means psi is consistent with BoxContent of that MCS
3. Extend {psi} union BoxContent to an MCS M_psi via Lindenbaum
4. M_psi is in some BidirectionalFragment (rooted at M_psi)
5. Build a fragmentFMCS for M_psi's fragment (sorry-free)
6. This fragmentFMCS is the witness family

**Key claim**: Each witness family built from a BidirectionalFragment has sorry-free temporal coherence (because fragmentFMCS has sorry-free forward_F/backward_P from `forward_F_stays_in_fragment`/`backward_P_stays_in_fragment`).

**The conversion to FMCS Int**: This still requires the Fragment-to-Int transfer. But here's the twist: **we don't need SURJECTIVITY of the chain**. We only need the EVAL family's chain to visit the right witnesses. Each witness family can use its OWN chain embedding (different chain for different family). The chain for a witness family need only map Int to that family's BidirectionalFragment -- it doesn't need to hit specific witnesses because the truth lemma for a witness family doesn't need to prove arbitrary forward_F, just that the fragment-level F/P works.

**Actually**: fragmentFMCS over BidirectionalFragment ALREADY has forward_F/backward_P. The issue is converting from FMCS(BidirectionalFragment) to FMCS(Int). If we use a monotone injection `Int -> BidirectionalFragment`, the pulled-back family has forward_G and backward_H (by composition). But forward_F requires: given F(phi) at chain position n, finding m > n on the chain with phi at m. The fragment-level forward_F gives a witness in the fragment, but that witness might not be ON the chain.

**The real resolution**: Use a chain that ENUMERATES the entire fragment (not just a successor sequence). Since the fragment is countable (it's generated by countable operations from a countable formula set), there exists a surjection `Int -> BidirectionalFragment` (after showing the fragment is countably infinite). With a surjective, order-preserving chain, every fragment element is hit, so the fragment-level F/P witness IS on the chain.

**Can we prove the fragment is order-isomorphic to Int?** This would require:
1. Countably infinite -- plausible (each step adds at most countably many elements)
2. No maximum or minimum -- from `mcs_has_F_top` and `mcs_has_P_top`
3. Densely ordered or discretely ordered -- unknown

If the fragment is discretely ordered with no max/min and countably infinite, then by `orderIsoIntOfLinearSuccPredArch` it IS order-isomorphic to Int. **But this requires SuccOrder, which is exactly what's blocked (research-019).**

**Alternative**: If the fragment is DENSE and countably infinite with no endpoints, it's order-isomorphic to Q (by Cantor's theorem). Then we could use D = Q instead of D = Int.

But the project requires D = Int (or at least D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`). Both Int and Rat satisfy these.

**Using D = Rat would avoid the SuccOrder blocker entirely.** The only change is replacing `Int` with `Rat` in the completeness theorem. Since the soundness theorem is parametric over D, this is harmless.

**Risk**: Is the BidirectionalFragment order-isomorphic to Q? This needs:
- Dense: between any two elements, there's a third. This is plausible if Lindenbaum extensions can always create intermediate MCSes.
- Countable: Yes (constructed from countable data).
- No endpoints: From `mcs_has_F_top`/`mcs_has_P_top`.

Whether the fragment is dense requires investigation. It might be neither dense nor discrete (it could have dense parts and discrete parts), in which case neither Int nor Rat works as D.

## Summary of Recommendations

Ordered by estimated feasibility and impact:

1. **(HIGH PRIORITY) Investigate whether the truth lemma can be weakened to require temporal coherence only for the eval family.** Trace through the box backward case carefully -- if witness families only need FORWARD truth lemma (membership => truth), and forward truth for temporal operators only needs forward_G (which T-axiom gives for constant families), this might work. This is the single highest-leverage investigation.

2. **(HIGH PRIORITY) Investigate fragment-based witness families with independent chain embeddings.** Each witness family gets its own BidirectionalFragment and its own chain. The chain doesn't need to be surjective -- it just needs to hit the specific witnesses that the truth lemma demands for that family. A carefully constructed chain (dovetailing over F/P obligations) might work for each individual family.

3. **(MEDIUM PRIORITY) Investigate D = Rat (dense time) to avoid the SuccOrder blocker.** If the BidirectionalFragment is dense (which is plausible), this gives an immediate order isomorphism and bypasses the chain-embedding problem entirely.

4. **(MEDIUM PRIORITY) Investigate the pruning/decision procedure approach from Doczkal-Smolka.** This is a fundamentally different proof architecture that could bypass ALL current blockers, but requires significant new infrastructure.

5. **(LOW PRIORITY) Complete the algebraic path (Lindenbaum algebra + Stone representation).** This is mathematically the most elegant approach but requires completing the Algebraic/ module infrastructure, which is substantial work.

## Appendix: Search Queries and Key Findings

### Mathlib Searches

**lean_leansearch**:
1. "completeness theorem for modal logic Kripke model canonical frame" -> Order.Frame (lattice frames, not Kripke)
2. "Zorn lemma chain maximal element upper bound" -> zorn_le_nonempty0, exists_maximal_of_chains_bounded
3. "constant function family MCS temporal logic" -> No relevant results

**lean_loogle**:
1. `BooleanAlgebra, Ultrafilter, Homeomorph` -> No results
2. `Lindenbaum` -> No results in Mathlib

**lean_leanfinder**:
1. "Stone duality Boolean algebra ultrafilter prime filter" -> Ultrafilter structure, ultrafilter_compact
2. "first-order completeness theorem Henkin model maximal consistent extension" -> FirstOrder.Language.Theory.IsMaximal, CompleteType
3. "Lindenbaum Tarski algebra quotient Boolean algebra" -> BoolAlg category
4. "model transfer homomorphism preserve satisfaction" -> FirstOrder.Language.ElementaryEmbedding.map_sentence
5. "prime spectrum Boolean algebra Stone space" -> BoolAlg.dual, BoolAlg.dualEquiv
6. "filtration finite model property modal logic bounded" -> No relevant results
7. "coalgebraic semantics functor modal logic endofunctor" -> CategoryTheory.Endofunctor.Coalgebra
8. "product of models satisfiability ultraproduct Los theorem" -> Ultraproduct.sentence_realize (Los's theorem!)

**lean_local_search**:
1. `Ultrafilter` -> Both Mathlib and local (Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean)
2. `LindenbaumAlg` -> Local (Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean)
3. `PrimeSpectrum` -> Mathlib (RingTheory/Spectrum/Prime/Defs.lean)
4. `exists_fullySaturated` -> Local (Boneyard/Metalogic/Bundle/SaturatedConstruction.lean)
5. `constantBFMCS` -> Local (Theories/Bimodal/Metalogic/Bundle/Construction.lean)

### Literature Survey

| Source | Approach | Relevance |
|--------|----------|-----------|
| Bentzen 2019 (Lean S5) | Henkin canonical model, single MCS world set | Clean S5 structure, no temporal |
| Doczkal-Smolka 2014 (Coq CTL/K*) | Pruning + decision procedure | K* = tense logic, directly applicable technique |
| From 2025 (Isabelle) | Synthetic/abstract completeness framework | Architecture pattern for separating concerns |
| From 2018 (Isabelle) | Canonical model for K | Basic modal, standard Henkin |
| coq-community/comp-dec-modal | Pruning for K, K*, CTL, PDL | K* completeness could be adapted |
| De Jongh et al. 2004 | Completeness by construction for tense logics | Direct construction technique |
| Goldblatt 1992 | Omega-sequences for linear temporal logic | Standard reference for canonical model |
| Jonsson-Tarski 1951/52 | BAO representation theorem | Algebraic completeness foundation |

### References

- [Bentzen S5 Lean formalization](https://github.com/bbentzen/mpl)
- [Doczkal-Smolka CTL Coq](https://link.springer.com/chapter/10.1007/978-3-319-08970-6_15)
- [comp-dec-modal (Coq)](https://github.com/coq-community/comp-dec-modal)
- [From: Synthetic Completeness (CPP 2025)](https://dl.acm.org/doi/10.1145/3703595.3705882)
- [From: Epistemic Logic (Isabelle AFP)](https://www.isa-afp.org/entries/Epistemic_Logic.html)
- [From: Fitting-style Completeness (ITP 2025)](https://drops.dagstuhl.de/storage/00lipics/lipics-vol352-itp2025/LIPIcs.ITP.2025.8/LIPIcs.ITP.2025.8.pdf)
- [Completeness by construction for tense logics](https://www.researchgate.net/publication/252750536_Completeness_by_construction_for_tense_logics_of_linear_time)
- [Goldblatt: Logics of Time and Computation (1992)](https://press.uchicago.edu/ucp/books/book/distributed/L/bo3620529.html)
- [Jonsson-Tarski Representation](https://www.emergentmind.com/topics/jonsson-tarski-representation)
