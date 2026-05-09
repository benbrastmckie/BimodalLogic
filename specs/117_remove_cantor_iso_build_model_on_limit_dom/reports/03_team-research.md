# Research Report: Task #117 (Round 3)

**Task**: Remove Cantor isomorphism — concrete implementation study
**Date**: 2026-05-08
**Mode**: Team Research (4 teammates)
**Focus**: Verify discreteness, ℤ embedding, CE refactoring, FMCS construction on ℤ

## Summary

The premise "Burgess's base construction always produces a discrete limit domain" is **not unconditionally true**. C4a counterexample elimination inserts midpoints `z = (x+y)/2` that can cascade, creating accumulation points in the limit. However, the density case IS cleanly separable — removing `.density` from `PotentialCounterexampleKind` eliminates the only code path requiring `SetConsistent g`, making the sorry at CE:3570 dead code. Since X is always a countable subset of ℚ (by construction), the natural inclusion X ⊂ ℚ provides an order-preserving embedding without requiring any isomorphism or density property.

## Key Findings

### 1. C4a Can Create Accumulation Points (Teammates A, C, D — Converge After Analysis)

C4a (Lemma 2.9) inserts z = (x+y)/2 when ¬U(γ,δ) ∈ f(x) and γ ∈ f(y). This can cascade:
- Insert z₁ = 0.5 between 0 and 1 (C4a for formula pair (γ₁,δ₁))
- Insert z₂ = 0.25 between 0 and z₁ (C4a for formula pair (γ₂,δ₂) at the NEW pair)
- Insert z₃ = 0.125 between 0 and z₂ ...

The sequence 0, 0.125, 0.25, 0.5, 1 converges to 0, making 0 an accumulation point with no immediate successor. Whether this happens depends on the formula content of the MCSs at inserted points.

**Teammate D's initial claim** that C4a cascades are bounded by the finite subformula closure is **partially correct** — only finitely many DISTINCT formula pairs can trigger C4a FROM a fixed point x. But each new inserted point has its own MCS, and the SAME formula pair can trigger C4a at the NEW pair (x, z_i) if γ ∈ f(z_i). So cascading is possible.

**Conclusion**: X may be discrete, dense, or mixed depending on formula content. The construction does NOT guarantee discreteness for the base logic.

### 2. Density Case Is Cleanly Separable (Teammates B, D — Unanimous)

The `.density` counterexample kind (CE:575) is completely independent of C4a/C5a:
- `.density` inserts midpoints between ALL adjacent pairs regardless of formula content
- It is the ONLY case requiring `SetConsistent (χ.g pc.x pc.y)` (the sorry at CE:3570)
- C4a/C5a branches explicitly use `lemma_2_8`/`lemma_2_8_since` which AVOIDS SetConsistent (documented at CE:1026, 1607, 2105, 2631)
- Removing `.density` from the enum makes the sorry dead code

The density branch is ~248 lines (CE:3535-3783), self-contained.

### 3. X Is Always a Subset of ℚ (All Teammates)

The chronicle construction starts with dom f₀ = {0} ⊂ ℚ and inserts rational points:
- C4a: z = (x+y)/2 ∈ ℚ
- C5a: y = x+1 ∈ ℚ (or similar rational successor)

So X = ⋃ dom f_n ⊂ ℚ always. The inclusion X ↪ ℚ is trivially order-preserving.

### 4. No Hidden Density Assumptions in Parametric Infrastructure (Teammates C, D)

- `RestrictedParametricTruthLemma.lean:37` requires only `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`
- `ParametricRepresentation.lean` header (lines 28, 40, 66-68) explicitly documents D = Int for base logic
- `TemporalCoherence.lean` uses only `[Preorder D]`
- `DenselyOrdered` appears ONLY in `ChronicleToCountermodel.lean` for the Cantor iso

### 5. The Limit C2' Issue (Teammate A — Critical)

The limit-level C2' (BurgessR3Maximal for adjacent pairs) is currently proved **vacuously**: "limit_dom is dense, so no adjacent pairs exist" (uses `no_adjacent_in_dense` + `limit_dom_dense`).

Without density, adjacent pairs may exist in X. For these pairs, `limit_g(x,y) = Set.univ`. The question is whether `BurgessR3Maximal (limit_f x) Set.univ (limit_f y)` holds.

**However**: this C2' property is needed for the CHRONICLE'S internal consistency, not for the FMCS/BFMCS construction. The FMCS only uses forward_G, backward_H, and the Until/Since coherence conditions — which are proved from C5/C5' (witnesses) and C4/C4' (counterexample elimination), NOT from C2'. If C2' at the limit is only used internally by the chronicle, and the downstream FMCS construction doesn't depend on it, this may not be a blocker.

**Needs verification**: trace all uses of `limit_c2'` or equivalent in ChronicleConstruction.lean and ChronicleToCountermodel.lean to determine if it's actually needed downstream.

### 6. Archival Plan (Teammate B)

| Source | Lines | Action | Destination |
|--------|-------|--------|-------------|
| CE.lean density branch | ~248 | ARCHIVE | Boneyard/DenseChronicle/ |
| CE.lean density_witness field | ~30 | MODIFY (remove field) | In-place |
| CE.lean PotentialCounterexampleKind.density | ~5 | MODIFY (remove variant) | In-place |
| ChronicleToCountermodel.lean DenselyOrdered instance | ~10 | ARCHIVE | Boneyard/DenseChronicle/ |
| ChronicleToCountermodel.lean cantor_iso + all cantor_* | ~530 | ARCHIVE | Boneyard/DenseChronicle/ |
| ChronicleConstruction.lean limit_dom_dense | ~35 | ARCHIVE | Boneyard/DenseChronicle/ |
| ChronicleConstruction.lean limit_c2' (vacuous) | ~30 | MODIFY (non-vacuous proof or remove) | In-place |

New code needed: ~200-300 lines for the replacement FMCS construction.

### 7. FMCS on ℚ via Natural Inclusion (Teammate C, adapted)

Since X ⊂ ℚ, the natural inclusion replaces the Cantor iso. The FMCS on ℚ:

```
-- For q ∈ X (limit_dom): use limit_f directly
-- For q ∉ X: extend to an MCS via Lindenbaum on g_content of enclosing interval
extended_f(q) :=
  if q ∈ limit_dom then limit_f(q)
  else lindenbaum_extend(g_content_of_enclosing_interval(q))
```

The shifted/rooted FMCS uses ℚ arithmetic (t - s) exactly as before — ℚ has AddCommGroup. The proofs are structurally identical to the current cantor_fmcs proofs but without routing through cantor_iso.symm.

**For the discrete variant** (future task): The chronicle construction with discrete axioms produces X that IS discrete (the X/Y operators require immediate successors). Then X ≅ ℤ via Mathlib's `orderIsoIntOfLinearSuccPredArch`, and D = ℤ.

## Synthesis

### Conflict Resolution

**Teammates A and C** initially said X is NOT discrete (C4a cascading).
**Teammate D** initially said X IS discrete (bounded by subformula closure).
**After full analysis**, D acknowledged that accumulation points can occur. All converge: **X may or may not be discrete depending on formula content**.

This is NOT a problem for the approach — it just means we can't use X ≅ ℤ for the base logic. We use X ⊂ ℚ (natural inclusion) instead.

### Revised Approach

1. **Remove `.density` from PotentialCounterexampleKind** — sorry becomes dead code
2. **Archive density-related code to Boneyard/DenseChronicle/** — don't delete
3. **Remove cantor_iso and DenselyOrdered instance** — archive to Boneyard/DenseChronicle/
4. **Define extended_f : Rat → Set Formula** using natural inclusion X ⊂ ℚ + Lindenbaum extension for non-domain rationals
5. **Build FMCS/BFMCS on Rat** using extended_f (same shifted/rooted pattern, same arithmetic)
6. **Prove coherence directly** — forward_G/backward_H for extended points, Until/Since via C5/C4 elimination
7. **D = Rat** (has AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial)
8. **Use existing parametric infrastructure unchanged**

### Variant Flexibility

- **Base logic**: X ⊂ ℚ (possibly mixed discrete/dense), natural inclusion, D = ℚ
- **Dense variant**: X ⊂ ℚ dense (density elimination added), Cantor iso X ≅ ℚ works, D = ℚ
- **Discrete variant**: X discrete (discrete axioms ensure it), X ≅ ℤ, D = ℤ

### Gaps Remaining

1. **Extension coherence**: Proving forward_G/backward_H for non-domain rationals under the Lindenbaum extension
2. **Limit C2' without density**: May need non-vacuous proof or verification that C2' is not needed downstream
3. **The extension function design**: Lindenbaum of g_content vs constant (root MCS) vs nearest domain point

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Discreteness proof, ℤ embedding | completed | high |
| B | CE refactoring, archival plan | completed | high |
| C | FMCS/BFMCS on ℤ construction | completed | high |
| D | Burgess alignment, guard semantics | completed | high |
