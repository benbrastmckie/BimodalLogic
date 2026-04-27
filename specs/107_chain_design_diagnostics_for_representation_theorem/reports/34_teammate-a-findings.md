# Teammate A Findings: Sorry Audit and Closure Path

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Angle**: Primary — exhaustive sorry audit, limit_g evaluation, closure path mapping

## Key Findings

### Finding 1: The 7 c2' Sorry Sites Share a Single Root Cause — No g-Value Construction

Every individual elimination function (`eliminate_C5_counterexample`, `eliminate_C4_counterexample`, etc.) sets **g' = χ.g unchanged**. This is visible at:
- Line 177: `(∀ a b, χ'.g a b = χ.g a b)` in the return type
- Line 187: `χ.g` is used verbatim as the new chronicle's g field
- Same pattern at lines 235, 324, 461, 587, 630, 672

The density case (line 989ff) has a *partial* attempt at g-modification (`g' = if ... then χ.g pc.x pc.y else χ.g a b`), but it hits the self-pair blocker at line 1086.

In Burgess's paper, **every** elimination explicitly constructs new g-values:
- Lemma 2.9 (C4, case n=0): Apply Lemma 2.6 → get B', D, B'' with R(f(x), B', D), R(D, B'', f(y)), g(x,y) = B' ∩ D ∩ B''. Set g'(x,z) = B', g'(z,y) = B''.
- Lemma 2.10 (C5, case n=0): Apply Lemma 2.4 → get B, C with R(f(x), B, C). Set g'(x,y) = B.
- Both: "let C3 determine the other values of g'(w,z) and g'(z,w)."

The code's elimination functions DO NOT FOLLOW Burgess. They only construct f-values for the new point and leave g completely unchanged. This means c2' cannot possibly hold for new adjacent pairs involving the inserted point.

### Finding 2: The Intersection-Based limit_g IS Correct for FUC (Not Tautological)

Previous research (report 33) claimed the intersection-based limit_g is "tautological for FUC." **This is wrong.** Here is why:

The FUC proof (Claim 2.11, Until case) requires: given U(φ,ψ) ∈ f(t), show ∃s > t with ψ ∈ f(s) and ∀r (t < r < s → φ ∈ f(r)).

With the intersection-based limit_g(t,s) = {α | ∀w ∈ limit_dom, t < w < s → α ∈ limit_f(w)}, showing φ ∈ limit_g(t,s) is *exactly equivalent* to showing φ ∈ limit_f(r) for all intermediate r. So yes, limit_g(t,s) is definitionally equal to what we need.

The claim that this is "tautological" confuses two things:
1. **Can we use limit_g to SHORTCUT the proof?** No — proving φ ∈ limit_g(t,s) IS the same as proving φ at all intermediate points.
2. **Is the proof structure wrong?** No — we DON'T NEED limit_g for FUC at all!

The correct approach for FUC is:
1. U(φ,ψ) ∈ f(t) → by C5_weak, ∃s > t with ψ ∈ f(s)
2. For the guard: ∀r (t < r < s → φ ∈ f(r))
3. By until_guard axiom: U(φ,ψ) → φ. So φ ∈ f(t).
4. For any r with t < r < s, we need φ ∈ f(r). By density, there exist points between t and r and between r and s. We need to show U(φ,ψ) propagates through intermediate points.

Wait — actually this IS the hard part. The intersection-based limit_g won't help because we need the guard formula φ at intermediate points, which is what we're trying to prove. Let me reconsider...

**Revised analysis**: The real question is whether the finite-stage C5 witness carries enough information. At finite stage n, C5 elimination adds point y with ψ ∈ f(y). But does the guard φ hold at ALL intermediate domain points between t and y? Currently `eliminate_C5_counterexample` only guarantees ψ ∈ f(y) — it does NOT set g(t,y) at all (g' = χ.g).

In Burgess, Lemma 2.10 (C5, case n=0) constructs g(x,y) = B via Lemma 2.4, where R(f(x), B, f(y)). Then by C3, for any intermediate z: g(x,y) ⊆ f(z). And the guard η ∈ B = g(x,y) (from the seed construction).

So the correct architecture is:
1. C5 elimination constructs proper g(x,y) with the guard η in g(x,y)
2. C3 propagates: η ∈ g(x,y) ⊆ f(z) for intermediate z
3. At the limit, either use stage-based limit_g (with g-immutability), or use C3 + the intersection-based limit_g

**Key insight**: With proper g-values from C5 elimination, EITHER limit_g definition works. The intersection-based one works because C3 at finite stages gives g(t,s) ⊆ f(r) for intermediate r, which means the guard η is in f(r) for all domain points r between t and s. Since the limit domain is dense, this covers all intermediate points. But to prove this, we need η ∈ g_n(t,s) at the finite stage where the C5 witness was created.

So **the limit_g question is moot** — the real blocker is that g-values aren't being constructed at finite stages.

### Finding 3: The Self-Pair Blocker Is a Consequence of Wrong Density Construction

The density elimination currently sets f(z) = f(x) (line 672: `fun q => if q = z then χ.f x else χ.f q`). This creates the self-pair problem: for the new pair (x, z), we need burgessR3(f(x), g(x,y), f(x)), which is not the same as burgessR3(f(x), g(x,y), f(y)).

**Burgess's approach**: In Lemma 2.9, case n=0 (density/C4), he does NOT set f(z) = f(x). Instead, he applies Lemma 2.6:
- Input: R(f(x), g(x,y), f(y)) and δ ∉ g(x,y)
- Output: B', D, B'' with R(f(x), B', D), R(D, B'', f(y)), g(x,y) = B' ∩ D ∩ B''
- Set f'(z) = D, g'(x,z) = B', g'(z,y) = B''

The MCS D comes from Lemma 2.6's Lindenbaum extension — it is NOT f(x). It is a carefully constructed MCS that satisfies:
- R(f(x), B', D): B' is a valid interval set between f(x) and D
- R(D, B'', f(y)): B'' is a valid interval set between D and f(y)
- g(x,y) = B' ∩ D ∩ B'': C3 is preserved

The density case should use the SAME construction as C4 (Lemma 2.9 case n=0), just with a different δ to negate. For pure density (no specific formula to negate), we can pick any δ ∉ g(x,y) — since g(x,y) is a proper subset of the formula universe (being a DCS, it's consistent, so ⊥ ∉ g(x,y) ... wait, actually every DCS contains ⊥ → ⊥ = ⊤). 

Actually, for pure density elimination (no formula obligation), we DON'T need Lemma 2.6. We can simply use Lemma 2.4 or 2.7 applied to any Until formula in f(x), or we can apply Lemma 2.6 with an arbitrary δ ∉ g(x,y). But the simplest approach: since the purpose is just to break adjacency, AND we need c2' for the new pairs, we should apply Lemma 2.6 (or its generalization) with any δ ∉ g(x,y).

Wait — for pure density elimination where we just need to insert a point, there's an even simpler approach: since R(f(x), g(x,y), f(y)) holds (from c2'), we can use Lemma 2.6 with ¬⊤ = ⊥ ... but ⊥ ∉ g(x,y) because g(x,y) is consistent. So:
- Apply Lemma 2.6 with δ = ⊤ (so ¬δ = ⊥; wait, we want ¬δ ∈ D...)

Actually, for density we don't even need the negation. We just need to split g(x,y) into valid halves. The key insight from Lemma 2.5: if R(A, B, C), r(A, B₁, D), r(D, B₂, C), and B ⊆ B₁ ∩ D ∩ B₂, then B = B₁ ∩ D ∩ B₂. So any splitting of g(x,y) that satisfies r on both halves works.

**Recommendation for density**: Apply `burgessR3_absorption` backwards — take the existing g(x,y) with R(f(x), g(x,y), f(y)), and split it at any intermediate D. The simplest approach: pick D = any MCS extending g(x,y), then g(x,y) ⊆ D, and we can use g(x,y) itself as both B₁ and B₂. Then c2' for (x,z) requires R(f(x), g(x,z), D), and c2' for (z,y) requires R(D, g(z,y), f(y)).

But actually the current codebase doesn't have Lemma 2.6 formalized — it only has `burgessR3_absorption` which goes in the OTHER direction (from `burgessR3(A, B₁, D)` and `burgessR3(D, B₂, C)` to `burgessR3(A, B₁₂, C)` where B₁₂ ⊆ B₁ ∩ D ∩ B₂).

**We need Lemma 2.6 formalized**: the splitting lemma that takes R(A, B, C) and δ ∉ B and produces D, B', B'' with R(A, B', D), R(D, B'', C), B = B' ∩ D ∩ B''.

### Finding 4: The 2 FUC Sorries Depend on Resolving the 7 c2' Sorries

The FUC sorry sites at ChronicleToCountermodel.lean lines 615-619 need the guard formula at intermediate points. The proof structure should be:

1. Given U(φ,ψ) ∈ limit_f(t), by until_guard axiom, φ ∈ limit_f(t)
2. By C5_weak, ∃s > t with ψ ∈ limit_f(s)  
3. For intermediate r with t < r < s, need φ ∈ limit_f(r)

Step 3 requires one of:
- (a) Stage-based limit_g with g-immutability: φ ∈ g_n(t,s) at stage n → φ ∈ limit_g(t,s) → φ ∈ limit_f(r) by C3
- (b) Direct propagation: show U(φ,ψ) propagates through the omega chain to intermediate points

For approach (a), we need:
- C5 elimination to construct g(t,s) with the guard φ ∈ g(t,s)
- g-immutability: g-values for old pairs persist across stages
- Stage-based limit_g that captures the finite-stage g-value

For approach (b), this would be extremely complex and probably not viable.

**Therefore**: FUC closure requires proper g-value construction at finite stages (the 7 c2' sorries), PLUS limit_g infrastructure (either stage-based or intersection-based).

### Finding 5: The C5 Witness Lemma Doesn't Carry Guard Information

`limit_satisfies_c5_weak` (line 577) returns:
```
∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f y
```

This is the WEAK form — it has the endpoint witness ψ ∈ f(y) but NOT the guard at intermediate points. The STRONG form needed for FUC would be:
```
∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f y ∧ ∀ r ∈ limit_dom, x < r → r < y → ξ ∈ limit_f r
```

Getting from weak to strong requires the g-value infrastructure.

## Recommended Approach

### Step 1: Formalize Burgess Lemma 2.6 (Splitting Lemma) — NEW INFRASTRUCTURE

Formalize in `RRelation.lean`:
```
theorem burgess_lemma_2_6 (A B C : Set Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_R : BurgessR3Maximal A B C) (δ : Formula) (h_notin : δ ∉ B) :
    ∃ B' D B'', SetMaximalConsistent D ∧
      BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
      B = B' ∩ D ∩ B'' ∧ δ.neg ∈ D
```

This is THE critical missing lemma. Burgess proves it in 2.6 of the paper.

### Step 2: Modify ALL 7 Elimination Functions to Construct g-Values

Each function needs to:
1. Construct proper g-values for new adjacent pairs (using Lemma 2.4 for C5, Lemma 2.6 for C4/density/g_prop/h_prop)
2. Preserve g for old pairs: g'(a,b) = χ.g(a,b) for a,b ∈ old_dom
3. Use C3 to determine g for non-adjacent new pairs: g'(w,z) = g'(w,a) ∩ f'(a) ∩ ... ∩ g'(b,z)

**For C5/C5' (lines 786, 824)**: 
- Lemma 2.4 gives C, g_content(A) ⊆ C. Need R(f(x), B, C).
- Currently `lemma_2_4` returns: C mcs, β ∈ C, g_content(A) ⊆ C, P(U(γ,β)) ∈ C
- NEED: additionally construct B with BurgessR3Maximal(f(x), B, C) using `burgessR3Maximal_exists_from_seed`
- The seed η should satisfy burgessR(f(x), η, C) and burgessRSince(C, η, f(x))
- From g_content(A) ⊆ C and the BX axiom structure, we can construct such η

**For C4/C4' (lines 864, 902)**:
- Lemma 2.6 applied to the adjacent pair containing the counterexample
- Current code already finds the relevant adjacent pair (w, w_next) and uses c2'
- NEED: additionally apply Lemma 2.6 to split g(w, w_next), getting D, B', B''
- Set f'(z) = D, g'(w,z) = B', g'(z,w_next) = B''

**For density/g_prop/h_prop (lines 938, 970, 1086)**:
- Same Lemma 2.6 approach as C4
- For density: split g(x,y) at arbitrary D
- For g_prop: split g(x, x_next) at D with α ∈ D
- For h_prop: split g(z_prev, y) at D with α ∈ D

### Step 3: Add g-Value Output to Elimination Functions

Modify the return types to include proper g construction:
- `eliminate_C5_counterexample` should return g' with BurgessR3Maximal g-values
- Same for all other elimination functions
- The `EliminationResult.g_agrees` already tracks g-agreement on old pairs
- The `EliminationResult.c2'` field then becomes provable from the construction

### Step 4: For FUC — Use Stage-Based limit_g OR Direct Proof

**Option A (stage-based limit_g)**: 
- Define limit_g(x,y) = omega_chain_val(N).g(x,y) where N is the first stage with both x,y in domain
- Prove g-immutability: for old pairs, g doesn't change across stages
- Then φ ∈ g_n(t,s) → φ ∈ limit_g(t,s) → φ ∈ limit_f(r) by C3

**Option B (intersection-based limit_g with direct proof)**: 
- Keep current limit_g as intersection
- For FUC, prove directly that the guard is at all intermediate points
- This requires tracing through the omega chain construction

Option A is cleaner and more closely follows Burgess.

### Step 5: Close FUC (lines 615, 619)

With proper g-values at finite stages and limit_g:
1. U(φ,ψ) ∈ limit_f(t) → by until_guard, φ ∈ limit_f(t)
2. By C5 with proper g, ∃s and η ∈ limit_g(t,s)  
3. By C3 at limit: limit_g(t,s) ⊆ limit_f(r) for t < r < s
4. φ ∈ limit_g(t,s) → φ ∈ limit_f(r) for all intermediate r

## Evidence/Examples

### Why g' = χ.g Can't Work

The singleton chronicle starts with g = fun _ _ => ∅. After C5 inserts point y beyond x, g(x,y) = ∅ (unchanged). Then c2' requires BurgessR3Maximal(f(x), ∅, f(y)). But ∅ is not deductively closed (∅ doesn't contain theorems), so DCS(∅) fails. Therefore c2' MUST fail with g' = χ.g.

### Burgess's Lemma 2.6 Is the Key Missing Piece

From the paper: "Let D₀ = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}. We claim D₀ is consistent..."

This constructs an MCS D between A and C that splits B into two halves B' and B''. The proof uses A5a, A4a, and A3a (Burgess axioms, corresponding to BX5, BX4, BX3 in the codebase).

### The Density Self-Pair Is an Artifact of Wrong f(z) Choice

Setting f(z) = f(x) forces g(x,z) to relate identical endpoints, which is geometrically meaningless. Burgess never does this — he always uses Lemma 2.6 to get a GENUINE intermediate MCS D that is distinct from both f(x) and f(y).

## Summary of Sorry Closure Dependencies

```
Lemma 2.6 (splitting)
  ↓
Modify elimination functions to construct g-values
  ↓
c2' sorries x7 (CounterexampleElimination.lean)
  ↓
g-immutability + stage-based limit_g (or intersection approach)
  ↓
FUC sorries x2 (ChronicleToCountermodel.lean)
```

Total: 9 sorries, all dependent on Lemma 2.6 formalization.

## Confidence Level

**High** for the diagnosis (g-values not being constructed is clearly the root cause).

**High** for Lemma 2.6 being the right fix (it's exactly what Burgess uses).

**Medium** for the FUC closure approach (the connection from finite-stage g-values through limit_g to the FUC proof needs careful engineering, and the stage-based vs intersection-based limit_g choice affects complexity).

**Low-Medium** for effort estimate — Lemma 2.6 is a significant formalization effort (Burgess's proof uses A3a/A4a/A5a and their mirrors, which may need adaptation for strict semantics). Prior experience shows BX axiom translations can be tricky. Estimate: 20-30 hours total for all 9 sorries.
