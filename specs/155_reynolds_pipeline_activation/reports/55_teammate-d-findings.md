# Teammate D Findings: Literature Deep Dive and Strategic Horizons

**Task**: 155 — Fix no_gaps_discrete import cycle for sorry-free discrete completeness
**Date**: 2026-06-02
**Angle**: Literature analysis, formalization gap analysis, strategic direction
**Confidence**: HIGH

## 1. Literature Analysis: How Discrete Completeness Actually Works

### 1.1 Burgess 1982 — The Chronicle Construction

Burgess constructs a model by building a *chronicle* — a pair (f, g) where f maps rational numbers to MCS's and g maps adjacent pairs to deductively closed guard sets. The construction proceeds by starting with a single point and repeatedly eliminating counterexamples to C4 (counterexample elimination for ¬U) and C5 (witness insertion for U). Key features:

- **Domain is always a subset of Q** (Section 2, condition C0).
- The construction works for *all* linear orders simultaneously. Burgess obtains a model over the rationals by construction.
- **Burgess does NOT separately handle the discrete case.** Section 1.6 lists discreteness axioms (G'⊥ ∧ H'⊥) but says "the adaptation of our work below to prove these variants is a routine exercise" — without providing the proof.
- The construction guarantees density by default because new points are inserted at midpoints of rational intervals (2.9: "Let z = (x + y)/2").

**Critical insight**: Burgess's construction ALWAYS produces a dense model (subset of Q). Getting a discrete model requires an entirely different technique — Burgess punts on this.

### 1.2 Reynolds 1994 — The Actual Discrete Completeness Proof

Reynolds 1994 is THE paper about completeness over Z. His proof strategy (Theorem 18) is fundamentally different from trying to prove the chronicle is Z-isomorphic:

**Step 1 (Corollary 3)**: Use Burgess-Xu strong completeness for linear orders to get a countable, discrete, endpointless structure M₀ where all instances of Prior-UZ/SZ are valid and A₀ holds at t₀. This is exactly what the current formalization does via `cantor_bfmcs_discrete`.

**Step 2 (Theorem 5 = Expressive completeness)**: Prove U,S are expressively complete over Prior structures. This is done by showing U'(A,B) ≡ ⊥ in any Prior structure — because U' requires a gap, and Prior-U eliminates all gaps. (Section 6, proof of Theorem 5.)

**Step 3 (Theorem 14 = No gaps between equivalence classes)**: Define ~M as contemporaneous equivalence (a ~M b iff M|[a,b] is "very good", meaning k-equivalent to a Z-interval). Prove this is a contemporaneous equivalence relation. Then prove its classes DON'T end at gaps using Prior-UZ/SZ + expressive completeness. The proof goes:
  - If a class ends at a gap, there's a temporal formula R detecting this (by expressive completeness, Lemma 6).
  - R holds in maximal open intervals with excluded endpoints (Lemma 7).
  - These intervals have no first or last class (Lemma 8).
  - All classes in such an interval are elementarily equivalent as substructures (Lemma 9).
  - Replacing a bad interval by one of its classes preserves all temporal truths (Lemma 12).
  - But then R still holds in the reduced structure — contradiction, since the single class can't end at a gap (Lemma 13).
  - Therefore there ARE no bad points (Theorem 14).

**Step 4 (Conclusion)**: Since no equivalence class ends at a gap, in a discrete structure adjacent classes are connected by successors. By transitivity of ~M, the whole structure is in one class, meaning the whole structure is "very good" (k-equivalent to a Z-interval). Since M satisfies ∃t α(t), so does any Z-interval k-equivalent to it. Done.

### 1.3 Venema 1993 — Completeness via Completeness

Venema's approach is more elegant but works for well-orderings and ω, not Z directly. The key idea:

1. A **BW-model** (satisfying axiom W: Fp → U(p,¬p)) is **definably well-ordered** (Lemma 4.1). Proof: every definable subset has a smallest element because U'(ψ,χ) ≡ ⊥ in BW-models (gaps can't exist when W holds).

2. By **Doets's theorem** (3.8): any definably well-ordered model has n-equivalents for all n. These n-equivalents are actual well-orderings.

3. So any BW-consistent formula has a well-ordered model.

This is relevant because it shows the **general pattern**: (a) axioms → no definable gaps, (b) no definable gaps → Doets transfer to the target order type.

### 1.4 Doets 1989 — The Transfer Engine

Doets's paper provides the transfer machinery used by Reynolds and Venema. The key results:

- **Theorem 3.1**: If M satisfies definable induction (for ω) and M ≡₃ (ω,<), then M has n-equivalents of order type ω for every n. Proof uses condensation arguments.

- **Theorem 4.1**: If M is definably complete, it has complete n-equivalents for each n. Uses condensation: define ~ via "the interval (a,b) has a complete n-equivalent", show it's a definable congruence, show equivalence classes have complete n-equivalents, show the quotient can't be dense (else contradicts definable completeness), hence there's only one class.

- **Corollary 4.4**: If M is definably well-ordered, it has well-ordered n-equivalents. (Well-orderedness = completeness + least element + successors, all at quantifier rank ≤3.)

**Key structural insight**: All these proofs follow the SAME pattern:
1. Define a condensation ~ from a definable equivalence relation
2. Show each equivalence class has an n-equivalent of the target type
3. Show the quotient ordering is dense
4. Show definable-[property] prevents the quotient from being dense
5. Conclude: one class, so M itself has an n-equivalent of the target type

### 1.5 Verbrugge 2004 — Step-by-Step Construction

Verbrugge shows completeness of D (discrete logic) with respect to Z ⊙ Z (and Z ⊙ A for any infinite A) using finite adequate sets. Key points:

- **Theorem 6 (Z completeness)**: Uses maximal consistent sets relativized to a finite adequate set Σ. Constructs a finite "middle stretch" then extends cyclically in both directions. The Z1 axiom (G(Gφ→φ) → (FGφ→Gφ)) is crucial for case (a) in the construction.

- **Theorem 7 (Z ⊙ Z completeness)**: Shows D is complete with respect to Z ⊙ Z by building a middle part that may be Z ⊙ n (multiple copies of Z), then extending.

- **Theorem 8**: D is complete with respect to Z ⊙ A for ANY infinite linear order A.

**Critical observation**: D (discrete logic without Z1) has models that are NOT Z-isomorphic — they can be Z ⊙ Z or Z ⊙ Q or any Z ⊙ A. The Z1 axiom is what forces a single copy of Z.

### 1.6 GHR 1993/1994 — Expressive Completeness with Gaps

GHR 1993 proves that {U,S,U',S'} are expressively complete over ALL linear orders (including gappy ones), while {U,S} alone are expressively complete over gap-free (Prior) structures. This is Theorem 4 in Reynolds 1994.

## 2. Formalization Gap Analysis: Where TM Diverges

### 2.1 The S5 Modal Dimension

Standard temporal completeness proofs (Burgess, Reynolds, Venema) work with PURE temporal logic — no modal □ operator. TM adds S5 modality with:
- Box-equivalent classes of MCS's (all sharing the same □-formulas)
- WorldHistory-based evaluation with shift-closed Omega
- Position-independent worldstates (WorldState type in TaskFrame)

The completeness proof handles this by:
1. Case-splitting on □(F'⊤) vs □(U(⊤,⊥)) membership in the root MCS
2. Building the chronicle within a single box-equivalence class
3. Using the parametric canonical model construction to package as a TaskFrame

**This architecture is sound** — the modal dimension is handled at the outer level, and the temporal dimension (chronicle construction) works within a single box class. The sorry is entirely in the temporal dimension.

### 2.2 The Parametric Canonical Model Path

The dense case works because:
1. Chronicle → countable dense linear order → ≃o Q (Cantor)
2. `cantor_bfmcs_dense_restricted_tc/buc/fuc` all proved using the Cantor isomorphism to map domain points to rationals
3. Parametric truth lemma gives the countermodel

The discrete case TRIES to work the same way but needs:
1. Chronicle → countable discrete linear order → ≃o Z (?)
2. This requires `IsSuccArchimedean` for the `orderIsoIntOfLinearSuccPredArch` isomorphism
3. `IsSuccArchimedean` requires `succ_cofinal` which requires `chronicle_gap_contradiction` — sorry

### 2.3 Why the Current Approach Fails

The current formalization tries to prove `IsSuccArchimedean` directly on the chronicle's limit domain. But as documented extensively, this is impossible because:
- The chronicle construction can produce limit domains with multiple succ-orbits (Z+Z counterexample)
- The Z1 axiom prevents "definable" gaps but doesn't prevent the construction from placing points in separate orbits

**The ROADMAP correctly identifies this**: "Reynolds BYPASSES succ_cofinal entirely."

### 2.4 What Reynolds Actually Needs (And What's Missing)

Reynolds's proof requires:
1. ✅ A countable discrete endpointless Prior structure (the chronicle)
2. ❌ US expressive completeness over Prior structures (Theorem 5)
3. ❌ Gap elimination for contemporaneous equivalences (Theorem 14)
4. ❌ k-equivalence transfer from the Prior structure to Z (Theorem 15/Doets)

Items 2-4 are NOT formalized in the parametric canonical model path. The current code tries to shortcut by proving IsSuccArchimedean directly, which doesn't work.

## 3. Strategic Recommendations

### 3.1 The Core Insight: There Are Two Viable Paths

**Path A: Reynolds's actual proof (Theorems 5→14→15→18)**

This is the mathematically honest approach. It requires:
- Formalizing US expressive completeness over Prior structures
- Formalizing the contemporaneous equivalence argument
- Formalizing the Doets transfer (n-equivalence to Z)
- Connecting the Z-model back to the parametric canonical model

This is significant work (the WeakCanonical/ directory has partial infrastructure) but is mathematically well-founded.

**Path B: Doets-style condensation directly on the chronicle**

Instead of proving the chronicle IS Z, prove:
- Define ~ on the chronicle domain: a ~ b iff the interval [a,b] has a Z-interval n-equivalent
- Show ~ is a definable congruence
- Show each class has a Z-interval n-equivalent  
- Show the quotient can't be dense (using the axioms)
- Conclude: one class, so the chronicle has a Z-interval n-equivalent

This is essentially Reynolds's argument repackaged in Doets's condensation framework. It might be easier to formalize because the condensation argument is more structured.

**Path C: Build on Z directly (task 202's "Option C")**

The task 202 summary proposed: instead of building on the chronicle and transferring, build the BFMCS directly on Z. The idea: Z IS succ-Archimedean, so `succ_embed_surjective` would be trivially true.

The challenge: how to build a BFMCS on Z that models the given formula? The current `cantor_bfmcs_discrete` builds it on the chronicle's limit domain. Building it on Z directly would require showing that the Burgess-Xu construction can be done with Z as the underlying order — but Burgess always uses Q as the ambient order.

### 3.2 The Best Path: Condensation on the Chronicle (Path B)

I recommend **Path B** because:

1. **It mirrors how the dense case already works.** The dense case uses Cantor's theorem (all countable dense endpointless orders are isomorphic to Q) to get the isomorphism for free. The discrete case should use an analogous result: all countable discrete endpointless orders *satisfying definable succ-Archimedeanness* are n-equivalent to Z.

2. **It avoids proving IsSuccArchimedean directly.** Instead, we prove that the chronicle *doesn't have definable gaps between equivalence classes* (Theorem 14), which is a weaker and provable statement.

3. **Much of the infrastructure exists.** The EF-game and k-equivalence infrastructure in WeakCanonical/EFGames/ and WeakCanonical/NEquivalence.lean was built for exactly this purpose.

4. **The mathematical argument is clean.** The chain is:
   - Prior-UZ/SZ axioms → no definable gaps → US expressive completeness (Theorem 5) → no gaps between equivalence classes (Theorem 14) → one equivalence class → k-equivalent to Z (Doets) → countermodel exists on Z.

5. **It doesn't require the chronicle to literally be Z.** The current sorry tries to prove something that may not even be true (the chronicle being Z-isomorphic). Path B only needs k-equivalence, which IS true.

### 3.3 Critical Mathematical Dependencies

The chain of results needed (in order):

1. **US expressive completeness over Prior structures** (Reynolds Theorem 5 / Venema): U'(A,B) ≡ ⊥ in Prior structures. This requires formalizing the Stavi connective U' (partially done in StaviConnectives.lean) and showing U'(A,B) → ⊥ in Prior structures via Prior-UZ.

2. **Contemporaneous equivalence definition** (Reynolds Section 7): Define ~M as the "very good" relation. Show it's a contemporaneous equivalence relation defined by a monadic formula.

3. **Gap elimination** (Reynolds Theorem 14): The Prior axioms + expressive completeness + the Lemma 12 preservation argument → no bad points. This is the core mathematical argument and the hardest to formalize.

4. **Doets transfer** (Reynolds Theorem 15 / Doets 3.1/4.1): From "one equivalence class, all very good" to "k-equivalent to Z". Uses lexicographic sum preservation of k-equivalence (Doets Lemma 1.4).

5. **Truth transfer**: From k-equivalence of the monadic structures to truth-preservation for formulas of bounded quantifier depth. Since the formula being falsified has fixed depth, k can be chosen large enough.

### 3.4 What NOT to Do

- **Do NOT try to prove `chronicle_gap_contradiction` / `succ_cofinal` directly.** 55 plan versions have tried and failed. The mathematical literature doesn't prove this — it uses a completely different argument.

- **Do NOT try "simple solutions" like frozen guards, Henkin chains, or F-formula seeding.** These have all been tried (plans v50-v55) and fail because they try to prove something stronger than what's needed.

- **Do NOT try to bypass the mathematical argument.** The only way is through: formalize the actual Reynolds/Doets proof.

### 3.5 Effort Estimate

- US expressive completeness (Theorem 5): 8-15 hours (StaviConnectives partially exists)
- Contemporaneous equivalence infrastructure: 5-10 hours
- Gap elimination (Theorem 14): 15-25 hours (hardest part — multiple lemmas)
- Doets transfer: 10-15 hours (k-equivalence infrastructure partially exists)
- Integration with parametric canonical model: 5-10 hours

Total: 43-75 hours. This is significantly more than plan v55's 20-40 hours, but unlike v55, this approach is mathematically sound and can actually succeed.

### 3.6 Long-Term Strategic Alignment

Completing the Reynolds proof properly would:
- Close the last sorry on the critical path to publication
- Produce reusable infrastructure (expressive completeness, Doets transfer) for future frame class extensions (tasks 169, 170)
- Align with the algebraic representation roadmap (Phase 4) since orthodox axiomatizability is used throughout
- Enable the dense+complete extension (task 170) which needs similar Doets-style transfer arguments

## 4. Summary

The literature is unambiguous: discrete completeness for US temporal logic over Z requires the Reynolds/Doets argument chain (expressive completeness → gap elimination → k-equivalence transfer), NOT direct proof that the chronicle is Z-isomorphic. The current approach of proving `succ_cofinal` / `IsSuccArchimedean` has no mathematical foundation in the literature and has failed after 55 plan iterations.

The correct approach mirrors Reynolds 1994 Theorem 18: use the Burgess-Xu model as a countable discrete Prior structure, prove US expressive completeness eliminates definable gaps (Theorem 5+14), transfer to Z via k-equivalence (Theorem 15/Doets), and build the countermodel on the transferred Z-structure.
