# Teammate D (Horizons) Findings: Task 117

**Task**: Remove Cantor isomorphism and build countermodel on limit domain
**Date**: 2026-05-08
**Role**: Strategic alignment and long-term implications

## Key Findings

### 1. The Cantor isomorphism is a structural liability, not just a sorry source

The sorry at CE:3570 (`SetConsistent (χ.g pc.x pc.y)`) is the symptom, but the disease is deeper. The Cantor isomorphism introduced a **false dependency on density** into the completeness proof. Burgess 1982 works with sparse subsets of Q — the chronicle construction produces a countable linear order with no max/min, but NOT necessarily dense. The DenselyOrdered instance on LimitDomSubtype (line 98-104 of ChronicleToCountermodel.lean) is mathematically provable (limit_dom_dense is sorry-free) but forces an architectural path where every rational must be a domain point, which then requires the density counterexample elimination code path, which requires g-value consistency — an indirect consequence chain that Burgess's original construction avoids entirely.

### 2. The parametric representation theorem requires AddCommGroup + LinearOrder + IsOrderedAddMonoid

This is the critical constraint for the "build directly on LimitDomSubtype" approach. The `dd_countermodel_chronicle` returns an existential `∃ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...`. Currently `D = Rat`. LimitDomSubtype is NOT an AddCommGroup — it's not closed under addition (the sum of two elements of limit_dom may not be in limit_dom).

**Implication**: The task cannot simply replace `D = Rat` with `D = LimitDomSubtype`. Instead, the approach must either:
- **(A)** Keep `D = Rat` but avoid the Cantor isomorphism by using a different extension of limit_f to all of Rat (one that doesn't require density for coherence proofs)
- **(B)** Restructure the parametric representation theorem to accept `D` with only `LinearOrder` (no AddCommGroup), changing the ShiftClosed/shifted FMCS infrastructure
- **(C)** Embed LimitDomSubtype into a type with group structure (e.g., use an order-preserving injection into Rat or Int, rather than an order isomorphism)

Option (A) seems most feasible — the key insight is that `cantor_fmcs` maps ALL rationals to MCS via `cantor_iso.symm`, but we could instead map non-domain rationals to a default MCS (e.g., the root MCS) and prove coherence only for domain points. The density elimination code path in CE.lean becomes unnecessary because we never claim the domain IS all of Rat — we just need coherence on the actual domain points.

Option (C) is essentially what the current approach does (Cantor iso is an order-preserving bijection), but the problem is that the iso forces density. A non-surjective injection would avoid this.

### 3. The density counterexample elimination is the only code path that needs SetConsistent g

Looking at CounterexampleElimination.lean:3547-3570, the sorry appears in the `density` case of the elimination step. This case handles adjacent pairs (pc.x, pc.y) with no domain points between them. It inserts a midpoint z = (pc.x + pc.y)/2 and uses lemma_2_6_splitting to split the g-value. The splitting needs β ∉ g, which uses `BurgessR3Maximal_bot_not_mem`, which needs `SetConsistent g`.

**If density elimination is removed entirely**, this sorry disappears. The question is: does the completeness proof need density elimination? The answer depends on whether the domain produced by the chronicle construction already satisfies all required coherence conditions WITHOUT inserting density points.

## Strategic Alignment

### Burgess 1982 Migration

Removing the Cantor iso is **strongly aligned** with the Burgess 1982 migration goal. Burgess constructs a countable linear order X ⊂ Q, not all of Q. The original construction:

1. Start with {0}
2. Iteratively insert points to satisfy C4/C5 (counterexample elimination)
3. Take the limit — a countable subset of Q with specific properties
4. Build the model on X directly

The current formalization adds an extra step (3.5: embed X isomorphically into all of Q via Cantor's theorem) that Burgess doesn't use. Removing this step makes the formalization closer to the paper.

### Impact on BXCanonical (Task 109)

The 19 BXCanonical sorries are blocked by Lindenbaum opacity, not by density. Task 117 has **no direct impact** on task 109. However, if the chronicle path achieves sorry-free completeness, the 5 critical-path sorries in RootScopedChain.lean become permanently dead code, and only the 14 irreflexive-consequence sorries remain as independent cleanup.

### Publication Readiness

If task 117 succeeds:
- `#print axioms bx_completeness` drops `sorryAx`
- The Chronicle module is **fully sorry-free on the critical path**
- The completeness theorem is publishable without caveats
- This would be (to our knowledge) the first mechanized completeness proof for a Since-Until temporal logic with S5 modality

The BXCanonical pathway's 19 sorries would need to be either closed (task 109) or clearly documented as "alternative pathway, not on critical path" for the paper. The Chronicle pathway alone is sufficient for the result.

### Task 116 Interaction

Task 116 (redefine G, H, F, P in terms of U and S) is **orthogonal** to task 117. Task 116 changes the Formula inductive type; task 117 changes the countermodel construction. They share no code. However:

- Task 116's convention changes would affect ~3200 references, including some in ChronicleToCountermodel.lean
- If task 117 rewrites ChronicleToCountermodel.lean, doing it BEFORE task 116 is preferable (smaller file to rewrite)
- Alternatively, if task 116 goes first, task 117 would rewrite against the new conventions

**Recommendation**: Execute task 117 first, then task 116. Task 117 is higher priority (eliminates the last critical-path sorry) and touches fewer files.

## Opportunities and Creative Approaches

### 1. Sparse domain approach (avoid density entirely)

Instead of mapping limit_dom into all of Rat via Cantor, build the FMCS/BFMCS directly on the domain that the chronicle produces. The key insight: the parametric truth lemma works on ANY linear order — it doesn't need density, addition, or group structure. The group structure is only needed for `ShiftClosed` (the shift operation τ ↦ τ(· - s) requires subtraction).

**Creative approach**: Define a custom shift operation on LimitDomSubtype-indexed families that doesn't require group structure. The shift just re-roots the FMCS at a different domain point, which is exactly what `rooted_cantor_fmcs` already does — it just does it via Rat arithmetic. A direct version would pick a different element of limit_dom as the root.

### 2. Generalize the parametric representation theorem

The current theorem requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. If we generalize to just `[LinearOrder D]` with a notion of "re-rooting" (instead of shift by subtraction), the entire Cantor iso becomes unnecessary. This is more work but would be architecturally cleaner and more faithful to Burgess.

### 3. Keep Rat as D but avoid the iso

The simplest approach: keep `D = Rat`, keep the shifted FMCS infrastructure, but DON'T embed limit_dom isomorphically into all of Rat. Instead:

- For domain points q ∈ limit_dom, use limit_f(q)
- For non-domain points q ∉ limit_dom, assign the MCS from the nearest domain point (or the root MCS, or any default)
- The coherence proofs (forward_G, backward_H, C4, C5) only need to hold FOR DOMAIN POINTS, which they already do from the chronicle construction

The restricted coherence conditions in the parametric truth lemma work with the `deferralClosure` — they only need witnesses at points where the relevant formulas hold, which are always domain points.

**This is essentially what the Cantor iso achieves** (making all rationals domain points), but we can achieve the same effect more cheaply by extending limit_f to all of Rat in a way that doesn't require density for coherence. The key: the coherence proofs in `cantor_bfmcs_restricted_tc/buc/fuc` transfer everything through `cantor_iso.symm`, which always lands in limit_dom. If we define `extended_f` on all of Rat such that the coherence conditions hold (by redirecting non-domain queries to domain points), we get the same result without the iso.

### 4. Lean/Mathlib techniques

- **Mathlib's `Set.Countable`**: Already used for LimitDomSubtype countability
- **`Order.iso_of_countable_dense`**: Currently used for the Cantor iso — would be removed
- **Subtype coercion**: LimitDomSubtype already inherits LinearOrder from Rat via subtype coercion. No additional order infrastructure needed.
- **`Finset.sup`/`Finset.inf`**: Could be used for finding "nearest domain point" in the extension approach

### 5. Scope extension opportunities

While rewriting ChronicleToCountermodel.lean:
- **Remove imports**: `Mathlib.Order.CountableDenseLinearOrder` and `Mathlib.Data.Rat.Encodable` would no longer be needed if the Cantor iso is removed
- **Simplify shifted FMCS**: The `cantor_zero` / offset arithmetic is boilerplate forced by the Cantor iso. A direct approach would be simpler.
- **Clean limit_dom_dense**: The `limit_dom_dense` theorem in ChronicleConstruction.lean could be kept (it's sorry-free and mathematically correct) or removed if no longer needed. Keeping it is harmless.
- **The DenselyOrdered instance** on LimitDomSubtype (lines 98-104) would be removed as it's no longer needed.

## Confidence Level

**High** on the strategic analysis.

- The Burgess 1982 alignment is clear and well-documented in the roadmap
- The type constraint issue (AddCommGroup on D) is a concrete technical blocker for the naive "use LimitDomSubtype as D" approach
- The "keep Rat, avoid iso" approach (option 3 / approach #3 above) is the most feasible path
- Task ordering (117 before 116) is straightforward

**Medium** on the specific implementation approach. The devil is in the details of how to extend limit_f to all of Rat without density. The coherence proofs need careful analysis to ensure they don't implicitly rely on density somewhere other than the Cantor iso transfer.
