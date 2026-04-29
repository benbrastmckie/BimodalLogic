# Teammate B Findings: Alternative Approaches to Burgess Chronicle Construction Blockers

**Task**: 107 — Burgess chronicle construction blockers
**Date**: 2026-04-29
**Teammate**: B (Alternatives)
**Artifact**: 47b

---

## Key Findings

### 1. The Three Blockers in Context

From the three handoffs, the blockers are:

- **Blocker 1 (Lemma 2.7, Phase 6)**: The Until-formula splitting (Case 1: D1/D3 and Case 2) in `PointInsertion.lean` is unproved. This is needed for C5 n>0 sub-case 3.

- **Blocker 2 (Density fix, Phase 8)**: The density case in `CounterexampleElimination.lean` line 1130 has a "self-pair problem" — setting `f(z) = χ.f pc.x` gives `BurgessR3Maximal(f(pc.x), g(pc.x,pc.y), f(pc.x))` (same MCS left and right), which does not follow from `h_c2'`. The fix requires propagating a `g_content A ⊆ C` invariant through the chain and using `lemma_2_6_splitting`.

- **Blocker 3 (C4/g_prop/h_prop c2', Phase 9)**: Four sorry sites (lines 908, 946, 982, 1014) in `eliminate_potential_counterexample` require proving `c2'` for chronicles returned by C4/g_prop/h_prop elimination. These are structurally unresolvable with the current approach because the g_prop counterexample condition directly contradicts the `h_gc : g_content A ⊆ C` hypothesis required by `lemma_2_6_splitting`.

---

## Xu 1988: What His Approach Offers

### Xu's Chronicle Structure (Definition 2.5)

Xu's chronicle conditions are:
- **C0**: T is finite
- **C1**: (T, <) is a frame (irreflexive — notably NOT transitive)
- **C2**: f maps points to MCS; g maps comparable pairs (t, t') to DCS
- **C3**: for t < t', r(f(t), g(t,t'), f(t'))
- **C4**: for t < t'' < t', g(t,t') ⊆ f(t'') (g-values are subsets of intermediate points)

Then Xu seeks C5a (C4 counterexample elimination) and C6a (Until witness insertion).

### Critical Difference: Xu Has No BurgessR3Maximal

Xu's condition C3 is just `r(A, B, C)` — i.e., `U(γ, β) ∈ A` for all `γ ∈ C` and `β ∈ B` — whereas the codebase uses `BurgessR3Maximal(A, B, C)` which is R(A, B, C), the maximally extended version.

Xu's Lemma 2.4 is the direct source of the splitting construction:

> **Xu Lemma 2.4**: Suppose that r(A, B, C), ¬U(γ, β) ∈ A and γ ∈ C. Then there are B', D, B'' such that R(A, B', D), R(D, B'', C) and B ∪ {¬β} ⊆ D.

The proof: extend B to B* with R(A, B*, C); β ∉ B* so {B* ∪ {¬β}} is consistent; let D be an MCS containing it. Then by Xu Lemma 2.3: S(α, ⊤) ∈ B* for all α ∈ A (and U(γ, ⊤) ∈ B* for all γ ∈ C). By Xu Lemma 2.1, r(A, ⊤, D) and r(D, ⊤, C). Complete by maximality.

### What g_content A ⊆ D Means in Xu's Setting

In Xu's proof of Lemma 2.4, D is constructed to contain B* (the maximal extension of B). Xu's C4 condition says g(t, t') ⊆ f(t'') for all intermediate t''. This is essentially the `g_content A ⊆ D` invariant the handoff identifies as the missing piece.

In Xu's framework, the R(A, B*, D) conclusion from 2.4 directly gives a new g-value B' with R(A, B', D), so `g_content(A) ⊆ D` follows from the construction of D (D contains B* which contains all g-relevant content from A).

**Xu's Lemma 2.4 does give both halves of a splitting**: B' with R(A, B', D) and B'' with R(D, B'', C). This is the exact analogue of `lemma_2_6_splitting`. The critical structural property is that D is built from B* which already contains everything from g-content(A).

### Can Xu's Lemma 2.4 Justify the `g_content A ⊆ D` Claim?

Yes, with the following correspondence:
- Xu's `B*` (the R-maximal extension of B at (A, C)) = `g_content A` in the codebase sense
- Xu constructs D ⊇ B* ⊇ g_content(A)
- Therefore g_content(A) ⊆ D is established by the seed construction itself

This is confirmed by the Phase 8 handoff's observation: inside `lemma_2_6_splitting`, the proof already establishes `h_gc_AD : g_content A ⊆ D` at line 923-929 of PointInsertion.lean. The problem is just that this fact is not returned in the output type. **Extending `lemma_2_6_splitting`'s return type is the correct fix**, and it is directly justified by Xu's construction.

---

## Option B Analysis: Remove c2' from EliminationResult

### What Option B Says (from Phase 9 handoff)

Remove `c2'` from `EliminationResult`, relying on c2' being vacuously true at the limit (dense domain, no adjacent pairs).

### Concrete Argument

In the limit chronicle, the domain is a dense linear order (specifically, a countable dense linear order without endpoints, which by Cantor's theorem is isomorphic to Q). Dense linear orders have **no adjacent pairs**. Therefore:

```
c2' = ∀ x y, Adjacent dom x y → BurgessR3Maximal(f(x), g(x,y), f(y))
```

is vacuously true because the antecedent `Adjacent dom x y` is never satisfied when the domain is dense.

### Is This Valid?

The Phase 9 handoff confirms this analysis:
> "Since c2' is vacuously true at the limit (dense domain, no adjacent pairs), Burgess's approach is to prove c2' ONLY at the limit."

The density of the limit domain follows from the density elimination step (which inserts a midpoint between every adjacent pair). After all density counterexamples are eliminated, the domain has no adjacent pairs.

### Is c2' Vacuously True for Dense Linear Orders with No Adjacent Pairs?

Yes, by definition: `Adjacent(S, x, y)` in the codebase means x, y ∈ S with x < y and no z ∈ S with x < z < y. A dense domain has no such pairs, so `Adjacent dom x y` is always false. The universal statement over Adjacent pairs is vacuously true.

**Conclusion**: c2' at the limit is indeed vacuously true, and Option B is mathematically valid.

### Implementation Effort for Option B

1. **Remove `c2'` field from `EliminationResult`** — the 4 sorry sites (908, 946, 982, 1014) simply disappear.
2. **Update `omega_chain`** to not carry c2' as an invariant.
3. **Prove c2' in `limit_chronicle`** by showing the limit domain is dense (no adjacent pairs).
4. **Density of limit domain**: This follows from the density elimination phase. If for all n, the n-th chronicle has no adjacent pairs remaining at step n+k for some k, then the limit has none.

The density-at-limit argument requires showing that the omega-chain eventually eliminates all density counterexamples. This follows from the density elimination step being included in the enumeration of potential counterexamples.

### Risk Assessment for Option B

**Medium risk**. The main risk is in step 4: proving that the limit domain is actually dense. This requires a careful argument about the omega-chain construction. The density counterexample enumeration needs to cover all adjacent pairs, which requires that adjacent pairs are eventually addressed.

The key observation: if (x, y) is an adjacent pair in chronicle n, then the density counterexample (x, y) appears at some index m in the enumeration. At step m, if (x, y) is still adjacent (it may have been resolved already by some earlier step), the midpoint z = (x+y)/2 is inserted. So after step m, (x, y) is no longer adjacent. Therefore every adjacent pair is eventually resolved.

---

## Alternative to Lemma 2.7: Restructuring the C5 Case

### What Lemma 2.7 Is Used For

According to Phase 6 handoff, Lemma 2.7 is needed for the C5 case with n > 0 (sub-case 3), specifically when `U(guard, alpha∧top) ∈ A` (D3 case) or `U(guard, eta∧top) ∈ A` (D1 case) after applying BX7 (linear_until).

### Xu's Approach to the C5 Case (Lemma 2.6)

Xu Lemma 2.6 handles C5a counterexamples, which correspond to our C4 case (¬U(γ,β) ∈ f(t₁) and γ ∈ f(t₂)). The proof applies Xu Lemma 2.4 directly — no induction on n is needed because Xu's framework does not have the Burgess "n = 0 vs n > 0" case split.

**Why there's no n > 0 induction in Xu**: Xu uses non-transitive frames (C1 is just irreflexivity, not linearity with transitivity). The C5a condition (`¬U(γ,β) ∈ f(t₁)` and `γ ∈ f(t₂)`) is directly resolved by Lemma 2.4, inserting t₃ between t₁ and t₂. There is no intermediate element structure to handle.

**In the codebase, Lemma 2.7 handles the transitive case** where there are intermediate elements between x and the witness. Xu avoids this by working with non-transitive frames — but the codebase targets **linear frames** (transitive), so Xu's avoidance does not directly apply.

### Can We Avoid Lemma 2.7 with Option B?

If we adopt Option B (removing c2' from EliminationResult), then the C5 sorry site (line 830) is the only remaining sorry. The Phase 9 handoff notes:

```
c2' := sorry -- Phase 9: C5 g-construction (n=0 via burgessR3Maximal_from_g_content_sub, n>0 via Lemma 2.7)
```

If c2' is removed from EliminationResult, the C5 sorry also disappears. The C5 case's `eliminate_C5_counterexample` still needs to insert a new point with the right f-value and g-values. But the g-values for the new adjacent pairs only need to satisfy c2' at the limit (which is vacuous), not at intermediate stages.

**Alternative approach for C5**: Without the c2' requirement in EliminationResult, we can use `burgessR3Maximal_from_g_content_sub` for the n=0 case (which gives BurgessR3Maximal trivially from g_content), and for n>0 we don't need c2' at all. This avoids Lemma 2.7 entirely if Option B is adopted.

### Restructuring C5 to Avoid Lemma 2.7 under Option A (g_ordered invariant)

If we don't adopt Option B and instead use the g_ordered invariant (Option A from Phase 9 handoff):

- The g_ordered invariant `∀ a b, Adjacent dom a b → g_content(f(a)) ⊆ f(b)` means that for any adjacent pair (a, b), we have `g_content(f(a)) ⊆ f(b)`.
- The C5 case with n=0: `eliminate_C5_counterexample` inserts a new point y with `η ∈ f(y)`. For adjacent pairs (x, y), `burgessR3Maximal_from_g_content_sub` gives BurgessR3Maximal(f(x), B', f(y)) using `g_content(f(x)) ⊆ f(y)` from g_ordered.
- The C5 case with n>0: intermediate points have the g_ordered invariant already, so splitting is not needed for the existing pairs. For the new pair (x, y), same argument as n=0.

**Key insight**: Under the g_ordered invariant, Lemma 2.7 (Until-formula splitting for n>0) can be avoided. Instead, g_ordered provides the bridge between existing adjacent pairs and the new ones. This restructuring is valid and avoids the most complex sorry.

---

## Venema 1993: Relevance to the Blockers

Venema's approach uses Burgess's completeness for linear frames as a stepping stone to completeness for well-orderings and the natural numbers. It is not directly relevant to the three blockers, which concern the Burgess-Xu construction for linear frames.

However, Venema's paper confirms two architectural points:

1. **The Burgess construction (via Xu's simplification) is foundational**: Reynolds explicitly calls these the "Burgess-Xu axioms" and refers to Xu's simplified construction. This validates that Xu's Lemma 2.4 is the canonical version of the splitting.

2. **c2' at the limit is standard**: Venema's Theorem 3.5 (citing Burgess) establishes completeness for linear frames without mentioning c2' as an intermediate invariant. This suggests Burgess's original proof did not require c2' at finite stages — consistent with Option B.

---

## Reynolds 1992: Relevance to the Blockers

Reynolds explicitly describes the Burgess-Xu construction (Section 4):

> "We use the rationals as a base board on which we successively place whole maximal consistent sets of formulas as points which will eventually make up a flow of time."

Reynolds references Xu 1988 for simplifications to Burgess's proof. The key passage:

> "By carefully choosing a single maximal consistent set to right the counter-example and satisfy some other stringent conditions kept holding throughout the construction..."

The "stringent conditions" kept throughout correspond to what the codebase calls C0, C2', C3 (and potentially g_ordered). Reynolds does not specify which intermediate invariants are maintained at finite stages vs. only at the limit, which is consistent with Option B's view that c2' is only needed at the limit.

---

## Recommended Approach

### Primary Recommendation: Option B (Remove c2' from EliminationResult)

Rationale:
1. **Mathematically sound**: c2' is vacuously true at the limit when the domain is dense with no adjacent pairs. This is the design intent of the Burgess construction.
2. **Eliminates 5 sorry sites in one architectural change**: Lines 830, 868, 908, 946, 982, 1014 all become either vacuous or trivially provable.
3. **Avoids Lemma 2.7 entirely**: Without c2' in EliminationResult, the Lemma 2.7 sorry sites (Case 1 D1/D3, Case 2) are not needed for the EliminationResult. Lemma 2.7 may still be useful for proving properties of the limit, but that is a separate concern.
4. **Consistent with Xu/Reynolds**: Neither Xu Lemma 2.4 nor the Reynolds description of the construction suggests maintaining c2' at finite stages.

### What Must Still Be Proved Under Option B

- **Density of limit domain**: The limit chronicle's domain has no adjacent pairs. Proof strategy: for any adjacent pair (x, y) in some finite stage, the density counterexample (x, y) is eventually handled by the omega-chain enumeration, inserting (x+y)/2 between them. Formalize this.
- **c2' at limit**: Once density is established (no adjacent pairs), c2' is vacuously true — one line proof.
- **Lemma 2.7 (Phase 6 blocker)**: The Phase 6 sorry sites remain but are no longer blocking the critical path. They can be addressed separately or with a plan revision marking them as non-critical.

### Secondary Recommendation: Export g_content from lemma_2_6_splitting

Regardless of which option is chosen for c2', the Phase 8 density sorry (line 1130) requires:

```lean
theorem lemma_2_6_splitting ... :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D ∧
      g_content A ⊆ D ∧ g_content D ⊆ C   -- MUST ADD
```

This is already proved internally (h_gc_AD, h_gc_DC at lines 923-933 of PointInsertion.lean) and just needs to be returned. This change is low-risk and is confirmed by both the handoff analysis and Xu's proof structure.

---

## Evidence and Examples

### Evidence for Option B Validity

From Xu Definition 2.5 and Theorem 2.8: Xu's proof constructs the limit chronicle and proves it satisfies C1-C6 (which includes C3, the analog of our c2'). The proof of C3 at the limit relies on the limit domain being a dense linear order, not on intermediate chronicles satisfying it.

From the codebase: `singleton_invariant` at ChronicleConstruction.lean line 96-111 already shows c2' (called `hc2'`) is vacuously true for singleton chronicles. The same vacuity argument applies at the limit.

### Evidence for g_content Export

From PointInsertion.lean lines 923-933 (as reproduced in Phase 8 handoff):
```lean
have h_gc_AD : g_content A ⊆ D :=
  fun φ hφ => h_sup (Set.mem_union_left _ (Set.mem_union_right _ hφ))
have h_gc_DC : g_content D ⊆ C :=
  h_content_subset_implies_g_content_reverse C D h_mcs_C h_D_mcs h_hc_CD
```

These proofs exist and are complete. Only the return type needs updating.

### Evidence Against Maintaining c2' at Finite Stages (Option A is Harder)

From Phase 9 handoff: "The plan's Phase 9 approach cannot close these sorry sites as described. The blocker is structural, not merely technical."

Specifically, for g_prop: the counterexample condition is `G(α) ∈ f(pc.x)` but `α ∉ f(pc.y)`, which means `g_content(f(pc.x)) ⊈ f(pc.y)`. This directly contradicts the hypothesis needed to propagate c2' through the g_prop insertion. Option A (maintaining g_ordered as an invariant) would require that g_prop counterexamples never arise — a different structural design.

---

## Confidence Levels

| Finding | Confidence | Basis |
|---------|------------|-------|
| Option B (remove c2') is mathematically valid | High | Density vacuity argument; Xu/Burgess design intent |
| g_content export from lemma_2_6_splitting is safe | High | Code inspection; proofs already exist internally |
| c2' at the limit is vacuously true | High | Dense domain definition; no adjacent pairs |
| Xu Lemma 2.4 justifies g_content A ⊆ D | High | Direct correspondence with codebase seed construction |
| Lemma 2.7 can be avoided under Option B | Medium-High | Structural argument; detailed verification needed |
| Option A (g_ordered invariant) would also work | Medium | Harder path but structurally sound |
| Reynolds/Venema support Option B's design | Medium | Indirect evidence from proof structure descriptions |

---

## Action Items

1. **Immediate (blocks everything)**: Export `g_content A ⊆ D ∧ g_content D ⊆ C` from `lemma_2_6_splitting` — closes Phase 8 density sorry and enables Phase 9.

2. **Architectural decision (requires /revise 107)**: Choose Option B (remove c2' from EliminationResult) or Option A (g_ordered invariant). Recommendation is Option B.

3. **If Option B chosen**:
   - Remove `c2'` field from `EliminationResult`
   - Remove 4 sorry sites in `eliminate_potential_counterexample` (they disappear)
   - Remove C5 sorry sites (830, 868) from `eliminate_potential_counterexample`
   - Update `omega_chain` to not thread c2' through steps
   - Add proof of density-at-limit (key new proof obligation)
   - Add one-line proof of c2' from density-at-limit

4. **Deferred (non-blocking under Option B)**: Lemma 2.7 sorry sites in PointInsertion.lean can be addressed separately as they are not on the critical path.
