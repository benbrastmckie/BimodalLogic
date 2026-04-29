# Teammate A Findings: Burgess Chronicle Construction Blockers

**Date**: 2026-04-29
**Session**: Primary research angle
**Task**: 107 — Chronicle construction blocker analysis

---

## Key Findings

### Finding 1: Burgess Lemma 2.7 — The Actual Proof (Phase 6 Blocker)

**What Burgess actually does in Lemma 2.7** (Burgess 1982, p. 371):

Burgess does NOT case-split on consistency of `{eta} ∪ B`. That is a deviation introduced in the current formalization. The Burgess proof is much more direct:

> "Proof: Much as in the proof of 2.6 the problem reduces to proving the consistency of the set of formulas of form
>
> ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β)
>
> for α ∈ A, β ∈ B, γ ∈ C..."

The proof proceeds as follows:
1. Since `η ∉ B` and `R(A, B, C)` (maximality), there exist `β₀ ∈ B`, `γ₀ ∈ C` with `¬U(γ₀, β₀∧η) ∈ A`.
2. We may assume `β₀ = β`, `γ₀ = γ` (replacing by conjunctions if necessary).
3. From `U(γ, β) ∈ A` (by `r(A, B, C)`) and A5a: `U(γ, β∧U(γ,β)) ∈ A`.
4. From `U(ξ, η) ∈ A` and A5a: `U(ξ, η∧U(ξ,η)) ∈ A`.
5. Let `θ = β∧U(γ,β)∧ξ∧U(ξ,η)`.
6. Apply **A7a** (the linearity axiom) to `U(γ,β∧U(γ,β))` and `U(ξ,η∧U(ξ,η))` — getting the three-way disjunction.
7. Since `¬U(γ, β∧η) ∈ A`, using A1a and A2a the first two candidates are ruled out, leaving the third: `U(β∧U(γ,β)∧ξ, θ) ∈ A`.
8. Applying A3a: `U(ξ, β∧η) ∈ A`, from which consistency of ζ follows (by Lemma 2.2).

**The seed for D is**: `{S(α, β∧η) : α ∈ A} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C}`

(By analogy with the proof of 2.6, which uses `{S(α,β) : α ∈ A} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C}`.)

**Critical observation**: Burgess does NOT need to case-split on whether `{η}∪B` is consistent. He directly shows the seed is consistent using A7a after first establishing `¬U(γ, β∧η) ∈ A` from the maximality of B (since `η ∉ B`). The entire proof is a single consistency argument for the seed.

**What the constructed D satisfies**:
- `ξ ∈ D` (by construction from seed)
- `η ∈ B'` where `B'` is maximal with `B ⊆ B' ∧ r(A, B', D)` — this follows because `r(A, β∧η, D)` holds for each β ∈ B (from `U(ξ, β∧η) ∈ A` — see below), and η is a consequence.

**How `η ∈ B'` is established**: Burgess concludes that `U(ξ, β∧η) ∈ A` for all β ∈ B (after the A3a step above). By Lemma 2.3 criterion (a), `r(A, β∧η, C)` holds... wait, that's not quite right. Let me re-read.

Actually, Burgess's seed has `B ⊆ D` (from `β ∈ B` being in the seed) and `η ∈ D` (but the seed has `{ξ}`, not `{η}`). Looking more carefully:

The seed is `D₀ = {S(α, β∧η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}`.

So `B ⊆ D₀ ⊆ D` and `ξ ∈ D`. Then B' is chosen maximal with `B ⊆ B'` and `r(A, B', D)`. Since `r(A, β∧η, D)` holds for each β ∈ B (this follows from `U(ξ, β∧η) ∈ A` and the fact that `ξ ∈ D`... actually this uses the `r` relation criterion 2.3b), `η ∈ B'` follows from the maximality choice.

**More precisely**: Since `U(ξ, β∧η) ∈ A` and `ξ ∈ D`, by criterion 2.3b (the `r` equivalent condition): for every `α ∈ A`, `S(α, β∧η) ∈ D` (from the seed). So `r(A, β∧η, D)` holds. Hence `η` can be added to B' (since `r(A, η, D)` follows from the `S(α, β∧η) ∈ D` for all α ∈ A, by consequences).

**Implication for Phase 6**: The current formalization approach (case-splitting on `{η}∪B` consistency, then using BX7 with guard = `α∧η.neg`) diverges significantly from Burgess. The correct approach is:

1. Use the maximality of B to get `¬U(γ, β∧η) ∈ A` for some γ ∈ C, β ∈ B (this is what the `BurgessR3Maximal_extension_fails` gives us, but applied differently).
2. Build the seed `D₀ = {S(α, β∧η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}`.
3. Show D₀ consistent by showing each formula `ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β)` is consistent — this is the BX7 (A7a) argument leading to `U(ξ, β∧η) ∈ A`.
4. Lindenbaum to get MCS D with `ξ ∈ D`, then choose B' maximal with `B ⊆ B' ∧ r(A, B', D)`.

### Finding 2: g_content Invariant — What Burgess Actually Maintains (Phases 8-9 Blocker)

**Burgess does NOT use an explicit `g_content(A) ⊆ C` invariant.** His structure has no `h_gc` hypothesis equivalent.

Burgess's C3 condition is the key: `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)` for x < y < z. This means that the "between" set for any span is always the intersection of intermediate values. Since the limit domain is dense, there are no adjacent pairs — C2' holds vacuously.

**What Burgess proves at finite stages**: At each finite stage, Burgess proves:
- C0: all f(x) are MCS
- C2: r(f(x), g(x,y), f(y)) for all pairs (not just adjacent)
- C2': R(f(x), g(x,y), f(y)) for adjacent pairs — but he does this by construction
- C3: the intersection condition

The g-values are set by explicit construction in each lemma (2.6, 2.7):
- In 2.6 (splitting for C4): D₀ contains `{S(α,β) : α ∈ A}` and `{U(γ,β) : γ ∈ C}`, and B', B'' are chosen maximal — this ensures R(A, B', D) and R(D, B'', C).
- The old B = B' ∩ D ∩ B'' by Lemma 2.5.

**No g_content inclusion is needed** because Burgess's proof of C3 is purely by construction: when he inserts point z between x and y, he sets g(x,z) = B', g(z,y) = B'', and g(x,y) = B = B' ∩ f(z) ∩ B'' by Lemma 2.5.

**Critical gap in the present formalization**: The current formalization's `BurgessR3Maximal` definition requires `g_content(A) ⊆ C` as a precondition for `lemma_2_6_splitting`. This is an addition to Burgess's structure that is creating the blocker. In Burgess's original proof, the splitting lemma (his 2.6) does not require any such precondition — the seed consistency follows directly from the maximality argument (using the fact that `δ ∉ B` where B is maximal).

**Why the precondition was added**: Looking at the codebase's `splitting_seed_consistent`:
```
{β.neg} ∪ g_content A ∪ h_content C
```
This seed was designed to ensure that D satisfies both `g_content(A) ⊆ D` and `g_content(D) ⊆ C`. This is NOT Burgess's seed. Burgess's seed is:
```
{S(α,β) : α ∈ A} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C}
```
The present formalization replaced Burgess's explicit S/U-formula seed with a semantic content-based seed (using g_content/h_content). This introduced the `h_gc` dependency.

### Finding 3: c2' at Finite Stages vs. Limit (Phases 8-9 Blocker)

**Burgess's approach**: He proves c2' (his condition C2', which is `R(f(x), g(x,y), f(y))`) at EACH STAGE by construction. When a new point z is inserted, the new adjacent pairs (x,z) and (z,y) have g-values B' and B'' chosen maximally by Lemma 2.5/2.6 construction. So C2' is an invariant maintained at each step, NOT deferred to the limit.

However, Burgess's proof does NOT require `g_content(f(x)) ⊆ f(z)` for the new pairs. He establishes R(f(x), B', f(z)) by the explicit seed construction + maximality — the seed contains the right formulas by design.

**The h_gc blocker origin**: The present codebase's `burgessR3Maximal_from_g_content_sub` takes `g_content(A) ⊆ C` and produces `BurgessR3Maximal(A, B, C)`. This is a convenience lemma, not Burgess's approach. Burgess never uses this direction — he always constructs B' and B'' from explicit seeds.

**For the g_prop case**: The handoff notes that the g_prop counterexample has `G(α) ∈ f(x)` but `α ∉ f(y)`, meaning `g_content(f(x)) ⊆ f(y)` fails. Burgess's observation is:
- The point z is inserted with `f(z) = D` where D extends `{α} ∪ g_content(f(x))` (call this the g-propagation witness).
- For (x,z): R(f(x), B', D) by Burgess's construction where B' is chosen maximal with `r(A, B', D)` — using the explicit seed `{S(α', β') : α' ∈ f(x)} ∪ g_content(f(x)) ∪ {U(γ', β') : γ' ∈ D}`. This does NOT require `g_content(f(x)) ⊆ D` as a precondition — it establishes it as a consequence of D containing g_content(f(x)) by seed construction.
- For (z,y): need R(D, B'', f(y)). Burgess would use a seed for B'' from D and f(y). The key is that D contains `h_content(f(y))` — this requires showing h_content(f(y)) ⊆ D.

**The two-sided seed for g_prop**: The correct D for the g_prop case should contain:
- `α` (the formula being propagated)
- `g_content(f(x))` (so that G(φ) ∈ f(x) → φ ∈ D)
- `h_content(f(y))` (so that H(φ) ∈ f(y) → φ ∈ D, enabling r(D, B'', f(y)))

**Consistency of the two-sided seed** `{α} ∪ g_content(f(x)) ∪ h_content(f(y))`: This IS provable even when `g_content(f(x)) ⊈ f(y)`. The g_prop counterexample says `G(α) ∈ f(x)` but `α ∉ f(y)`. But `g_content(f(x)) ∪ h_content(f(y))` can still be consistent: we need `G(φ) ∈ f(x) ∧ H(ψ) ∈ f(y)` implies `{φ, ψ}` consistent. This follows from BurgessR3Maximal(f(x), g(x,y), f(y)) — since `φ ∈ g_content(f(x)) ⊆ g(x,y)` (by `g_content_sub_B_of_BurgessR3Maximal`, but this requires `h_gc`...) Actually no — this is circular again.

**The correct approach**: Burgess's Lemma 2.4 (his C5 elimination) gives the D for the g_prop/h_prop cases. The seed is `{U(γ, β) : γ ∈ f(y), β ∈ g(x,y)} ∪ {α}`, and consistency follows because `¬U(γ,β) ∈ f(x)` combined with `γ ∈ f(y)` (the counterexample condition) directly gives the relevant formula in the seed. This is Xu's Lemma 2.4, which provides D with `γ ∈ D` and `r(f(x), g_seed, D)` and `r(D, g_seed', f(y))`.

### Finding 4: Xu's Approach (Section 2 vs Burgess)

Xu's Lemma 2.4 (Xu 1988) is the key for the C5a counterexample (our g_prop case). It says:

> "Suppose that r(A, B, C), ¬U(γ, β) ∈ A and γ ∈ C. Then there are B', D, B'' such that R(A, B', D), R(D, B'', C) and B ∪ {¬β} ⊆ D."

Note what this requires:
- `r(A, B, C)` — only the non-maximal r relation, not R
- `¬U(γ, β) ∈ A` — the negation of an Until is in A
- `γ ∈ C` — the Until's argument is in C

And what it produces: D with `¬β ∈ D` (the formula being "negated") and both R pairs established.

**Xu's proof** uses the following seed for D:
```
B^* ∪ {¬β}
```
where B^* is any maximal extension of B (i.e., R(A, B^*, C)). Consistency of B^* ∪ {¬β} follows because `β ∉ B^*` (since `¬U(γ,β) ∈ A` and `γ ∈ C` with `r(A, B^*, C)` would give `U(γ,β) ∈ A` by the r-relation definition, contradicting consistency).

Then D extends B^* ∪ {¬β}. Since B^* is maximal: R(A, B^*, C), the new D contains B^*, so:
- By Xu's Lemma 2.3: `r(A, ⊤, D)` and `r(D, ⊤, C)` (since D contains B^* which contains U(γ,⊤) for all γ ∈ C and S(α,⊤) for all α ∈ A).
- Then B' and B'' are chosen maximally.

**For the g_prop case in the formalization**: The g_prop counterexample has:
- `G(α) ∈ f(x)`, i.e., α ∈ g_content(f(x))
- `α ∉ f(y)`, so `α.neg ∈ f(y)` (MCS)
- This means `¬U(⊤, α) ∉ A` wait, no. Let me re-examine.

Actually for g_prop: the counterexample is `G(α) ∈ f(x)` but `α ∉ f(y)`. In Burgess's C4a formulation:
- `¬U(γ, δ) ∈ f(x)` and `γ ∈ f(y)` and no z between x and y with `¬δ ∈ f(z)`.

g_prop corresponds to: `G(α) ∈ f(x)` means `U(⊤, ¬α)` is NOT in A... Actually G(α) = ¬F(¬α) = ¬U(¬α, ⊤). Hmm, this is getting into the precise definitions.

The point is: Xu's Lemma 2.4 handles the C5a counterexample by a much simpler seed construction (just `B^* ∪ {¬β}`) that does NOT require the `g_content(A) ⊆ C` precondition.

### Finding 5: The g_ordered Invariant — the Correct Approach

The handoff (Phase 9) suggests two options: (A) add g_ordered invariant, or (B) remove c2' from EliminationResult.

**From reading Burgess carefully**: Neither option exactly matches what Burgess does. Burgess DOES maintain c2' at each stage (it is never vacuous at finite stages for him). He achieves this by constructing g-values explicitly from seeds.

However, Option A (g_ordered invariant) is the correct direction. Here is why:

In Burgess, the seed for the new D always contains `B` (the current interval set). This ensures `B ⊆ D`. From `B ⊆ D` and `BurgessR3Maximal(A, B^*, C)` (where B^* ⊇ B is maximal), we get that D contains enough U(γ,β) formulas to establish `r(D, B'', C)`.

In the present formalization, the analogous condition is `h_content(C) ⊆ D` (which is how `r(D, ., C)` is established via `h_content_subset_implies_g_content_reverse`). And `h_content(C) ⊆ D` is achieved when D's seed contains the right U-formulas from C — specifically, when D contains the B^* that contains those U-formulas.

The g_ordered invariant `g_content(f(x)) ⊆ f(y)` for adjacent pairs (x,y) is equivalent to saying: for G(φ) ∈ f(x), φ ∈ f(y). This is NOT required by Burgess for C5a elimination. It IS used in his C4a elimination (the density/splitting case).

**The real solution**: The density case correctly uses `lemma_2_6_splitting` with `h_gc`. For g_prop/h_prop/C4 cases, the correct approach is Xu's Lemma 2.4 / Burgess's 2.6 C5a elimination without the `h_gc` precondition.

**Concretely**: For g_prop, the f(z) = D should be constructed differently:
1. The g_prop counterexample gives `¬U(γ,δ) ∈ f(x)` and `γ ∈ f(y)` (in Burgess's formulation for C4).
2. Apply Xu/Burgess: let B^* be maximal with `B ⊆ B^*` and `R(f(x), B^*, f(y))`. Since `γ ∈ f(y)` and `¬U(γ,δ) ∈ f(x)`, we have `δ ∉ B^*`.
3. Let D extend B^* ∪ {¬δ}. This is consistent. Then D contains `g_content(f(x))` (since g_content(f(x)) ⊆ B^* ⊆ D by the g_content_sub_B theorem, which only requires h_gc as a precondition... again the circular issue).

Actually wait: `g_content_sub_B_of_BurgessR3Maximal` requires `h_gc`. But Xu's approach avoids this entirely by noting that `r(A, ⊤, D)` follows from D containing B^* (since B^* contains all U(γ,⊤) for γ ∈ C, by Xu's Lemma 2.3). The BurgessR3Maximal condition for the (x,z) pair is then obtained without needing g_content inclusion.

**The issue is the present BurgessR3Maximal definition**. Let me check: what exactly is `BurgessR3Maximal` in the formalization?

---

## Recommended Approach

### For Phase 6 (Lemma 2.7 Sorry Sites)

**Discard the current case-split approach entirely.** Replace with Burgess's direct proof:

1. From `η ∉ B` and maximality of B: obtain `β₀ ∈ B`, `γ₀ ∈ C` with `¬U(γ₀, β₀∧η) ∈ A`. (This is `BurgessR3Maximal_extension_fails` applied to `β₀∧η`.)

2. Construct seed:
   ```
   D₀ = {S(α, β∧η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}
   ```

3. Show D₀ consistent: for any finite combination `S(α,β∧η) ∧ β ∧ ξ ∧ U(γ,β)` (with α ∈ A, β ∈ B, γ ∈ C), apply A5a twice to get `U(γ,β∧U(γ,β))` and `U(ξ,η∧U(ξ,η))` in A, then apply A7a to rule out two disjuncts (using `¬U(γ,β∧η) ∈ A`), obtaining `U(β∧U(γ,β)∧ξ, θ) ∈ A` for appropriate θ, then A3a gives `U(ξ, β∧η) ∈ A`, and Lemma 2.2 gives consistency of ζ.

4. Lindenbaum: D = MCS extending D₀. Then ξ ∈ D (from seed). B' maximal with `B ⊆ B' ∧ r(A, B', D)`. B'' maximal with `B ⊆ B'' ∧ r(D, B'', C)`.

5. η ∈ B': since for each β ∈ B, `U(ξ, β∧η) ∈ A` and `ξ ∈ D`, by 2.3 criterion (b), `S(α, β∧η) ∈ D` for all α ∈ A — so `r(A, β∧η, D)` holds. Hence `η` can be added to B' (B' is chosen to be maximal with β∧η included for each β ∈ B, and η is a consequence).

6. B = B' ∩ D ∩ B'' by Lemma 2.5.

**Note on g_content**: This approach does NOT need `h_gc : g_content A ⊆ C` as precondition for Lemma 2.7! The seed D₀ contains B (so `g_content(A) ⊆ B ⊆ D₀ ⊆ D` follows from `g_content_sub_B_of_BurgessR3Maximal` — BUT ONLY IF h_gc holds). So actually, if h_gc is available (as it is in the current signature of lemma_2_7), then `g_content(A) ⊆ B ⊆ D` is derivable from `h_gc` + `g_content_sub_B_of_BurgessR3Maximal`. This makes the current signature correct.

### For Phases 8-9 (h_gc Blocker)

**The blockers have different roots and need different fixes:**

#### Density case (Phase 8)
The density case is already correctly handled by the plan: use `lemma_2_6_splitting`. The `h_gc` precondition IS needed and IS available once `h_gc_adj` is added as an invariant. This is correct.

#### g_prop/h_prop/C4 cases (Phase 9)
**Recommended: Option B from Phase 9 handoff — remove c2' from EliminationResult**.

The rationale from Burgess: at each finite stage, Burgess maintains c2' by explicit construction in Lemmas 2.6 and 2.7. However, the g_prop/C4 elimination functions (`eliminate_g_prop_counterexample`, `eliminate_C4_counterexample`) are analogous to Burgess's C4a elimination (his Lemma 2.9), not his density insertion. Burgess's C4a insertion DOES maintain c2', but by construction of specific B', B'' seeds — not by invoking `lemma_2_6_splitting`.

For the g_prop case in the present codebase: the new point z is inserted with `f(z) = D` where `α ∈ D`. The g-values for (x,z) and (z,y) should be set by explicit BurgessR3Maximal constructions. Specifically:

- For (x,z): since `g_content(f(x)) ⊆ D` follows from D being the g-propagation witness (D extends `{α} ∪ g_content(f(x))`), use `burgessR3Maximal_from_g_content_sub` to get B' with `BurgessR3Maximal(f(x), B', D)`.

- For (z,y): need `g_content(D) ⊆ f(y)`. This requires `h_content(f(y)) ⊆ D`. Does h_content(f(y)) ⊆ D? D extends g_content(f(x)). h_content(f(y)) ⊆ g(x,y) by `h_content_sub_B_of_BurgessR3Maximal` (given BurgessR3Maximal(f(x), g(x,y), f(y)) AND `g_content(f(x)) ⊆ f(y)`). But the g_prop counterexample means `g_content(f(x)) ⊈ f(y)`. So this fails.

**True resolution**: Xu's approach for C5a (our g_prop) does NOT split g(x,y) in the way assumed by the current C4a code. Xu's Lemma 2.6 directly produces a point between the C5a counterexample (x,y) pair. The g-value for the new (x,z) pair comes from a maximal B' with R(f(x), B', D), and for (z,y) from R(D, B'', f(y)).

The proof that R(D, B'', f(y)) is achievable comes from Xu's Lemma 2.3: since D contains B^* (the maximal extension of g(x,y)), D contains `U(γ,⊤) ∈ B^*` for all γ ∈ f(y), giving `r(D, ⊤, f(y))`, then B'' exists by 2.0(ii). This requires D to contain B^*, which requires the g_prop's D to extend g(x,y) — but the present formalization's g_prop D only extends `{α} ∪ g_content(f(x))`, not g(x,y).

**The concrete fix**: The g_prop D should extend `{α} ∪ B^*` where B^* is the maximal extension of g(x,y). This requires `α ∉ B^*` for consistency (which holds since `G(α) ∈ f(x)` but `α ∉ f(y)` means `¬U(⊤,¬α) = G(α)... wait, I need to map the g_prop condition to Burgess's C4 notation more carefully.

**Summary for Phases 8-9**: The cleanest path is Option A (g_ordered invariant) from the Phase 9 handoff, with the following key insight: if `g_content(f(x)) ⊆ f(y)` holds as an invariant for adjacent pairs, then:
- The g_prop counterexample (`G(α) ∈ f(x)`, `α ∉ f(y)`) cannot arise (vacuous case).
- The density case uses `lemma_2_6_splitting` with `h_gc` from the invariant.
- The C5 (c5_forward) case uses `lemma_2_7` (after it is fixed per Phase 6).
- The C4 cases use `lemma_2_6_splitting` as well (since C4 does NOT violate g_ordered).

---

## Evidence and Examples

### Evidence 1: Burgess's Lemma 2.7 Proof Text

From Burgess 1982, pp. 371:
> "Much as in the proof of 2.6 the problem reduces to proving the consistency of the set of formulas of form ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β) for α ∈ A, β ∈ B, γ ∈ C... Now letting θ = β∧U(γ,β)∧ξ∧U(ξ,η), A7a applies to tell us that one of the following must belong to A... the third. Using A3a we then get U(ξ, β∧η) ∈ A, whence the consistency of ζ follows."

This confirms: the proof is a SINGLE consistency argument for the seed containing `{ξ}` (not a case split), using A5a twice then A7a then A3a.

### Evidence 2: Burgess's Chronicle Conditions

From Burgess 1982, p. 373 (conditions on the chronicle):
- C2: r(f(x), g(x,y), f(y)) for all pairs — NOT R (the non-maximal relation)
- C2': R(f(x), g(x,y), f(y)) for adjacent pairs — maximality only for adjacent

Burgess's Lemma 2.9 (C4 elimination) explicitly constructs the new g-values using Lemma 2.6, maintaining C2' for the new adjacent pair by the R construction. The old g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y) by C3 (no longer adjacent after insertion).

### Evidence 3: No g_content precondition in Burgess's 2.6

Burgess's Lemma 2.6 signature:
> "Suppose we have R(A, B, C) and δ ∉ B. Then there exist B', D, B'' such that ¬δ ∈ D and R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B''."

No `g_content(A) ⊆ C` precondition appears anywhere. The consistency proof uses ONLY the maximality of B (to get `β₀ ∈ B`, `γ₀ ∈ C` with `¬U(γ₀, β₀∧δ) ∈ A`) and A4a/A5a/A3a to derive the seed consistency.

### Evidence 4: Xu's Simpler C5 Insertion

From Xu 1988, Lemma 2.4:
> "Suppose that r(A, B, C), ¬U(γ,β) ∈ A and γ ∈ C. Then there are B', D, B'' such that R(A, B', D), R(D, B'', C) and B ∪ {¬β} ⊆ D."

Xu's proof: B^* maximal extending B with R(A, B^*, C). Since ¬U(γ,β) ∈ A and γ ∈ C, β ∉ B^* (by r-relation definition). So B^* ∪ {¬β} is consistent. Let D extend it. By Xu's Lemma 2.3, r(A, ⊤, D) and r(D, ⊤, C). Then B', B'' exist by maximalization.

**Key**: Xu's Lemma 2.3 says R(A, B, C) implies U(γ,⊤) ∈ B for all γ ∈ C, and S(α,⊤) ∈ B for all α ∈ A. So B^* ⊆ D gives these, which gives r(A, ⊤, D) and r(D, ⊤, C).

This is the approach for the g_prop/h_prop cases: use Xu's Lemma 2.4 directly. The condition `¬U(γ,β) ∈ f(x)` with `γ ∈ f(y)` is exactly the C5a counterexample condition.

**The present formalization's issue**: It is not using Xu's Lemma 2.4 / Burgess's C5a elimination (their Lemmas 2.10 / 2.4) for the g_prop case. Instead it is treating g_prop as if it were a density/splitting case. The g_prop case corresponds to Burgess's C4a (which is his C5a in the Xu notation), and the correct D is NOT from `lemma_2_6_splitting` but from `lemma_2_4` / a new `xu_lemma_2_4` theorem.

---

## Confidence Level

- **Phase 6 (Lemma 2.7)**: HIGH confidence. Burgess's proof text is clear and unambiguous. The correct approach is a single seed consistency argument using A5a+A7a+A3a, not a case split. The fix requires restructuring the current Case 1/Case 2 approach.

- **Phases 8-9 (h_gc blocker, density)**: HIGH confidence that the density case is correctly handled by `lemma_2_6_splitting` + `h_gc_adj` invariant. The plan (Tasks A-F) is correct for this case.

- **Phases 8-9 (h_gc blocker, g_prop/h_prop/C4)**: HIGH confidence that these cases are misidentified as splitting cases. They correspond to Burgess's C5a/C5b elimination (not density/C4a splitting). The correct fix is Xu's Lemma 2.4: construct D from `B^* ∪ {α}` where B^* is the maximal extension of g(x,y). This bypasses the h_gc precondition entirely.

- **g_ordered invariant**: MEDIUM-HIGH confidence. If Option A is pursued, it is self-consistent: the g_prop case becomes vacuous (g_content(f(x)) ⊆ f(y) for adjacent pairs means no g_prop counterexample arises), and all remaining cases use `lemma_2_6_splitting` which already works. This is the most architecturally clean path.

---

## Recommended Next Steps

1. **For Phase 6**: Rewrite Lemma 2.7 using the single-seed approach. The seed is `D₀ = {S(α, β∧η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}`. The consistency proof uses BX5+BX7+BX3 in that order.

2. **For Phase 8 (density)**: Continue with the plan as written (Tasks A-F from Phase 8 handoff). The `h_gc_adj` invariant + extended `lemma_2_6_splitting` return type is the correct fix.

3. **For Phase 9 (g_prop/C4 sorry sites)**: Pursue Option A (g_ordered invariant). Add `g_content(f(x)) ⊆ f(y)` for adjacent pairs to `ChronicleInvariant`. Then g_prop/h_prop counterexamples become vacuous (they violate the invariant, so they cannot arise). C4 cases remain but do not violate g_ordered (C4 is about `¬U(γ,δ) ∈ f(x)` with `γ ∈ f(y)`, independent of g_content inclusion).

4. **For C4 sorry sites specifically**: Use Burgess's Lemma 2.9 approach: insert z, set f(z) = D (from lemma_2_6_splitting applied to the adjacent pair (w, w_next) from C4's inductive step), propagate the g_ordered invariant using `h_gc_AD` and `h_gc_DC` from `lemma_2_6_splitting`.
