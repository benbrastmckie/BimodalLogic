# Teammate B Findings: Literature-Based Alternative Approaches

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Teammate**: B (Alternative Approaches)
**Confidence**: High (primary findings based on direct reading of Burgess 1982 text)

---

## Key Findings

### 1. CRITICAL: The Density Elimination Sets f(z) = f(x) — This is WRONG per Burgess

**This is the most important finding in this report.**

In Burgess's Lemma 2.9 (C4 elimination, case n=0), when inserting z between adjacent x and y:

> "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Let z = (x+y)/2. Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and let C3 determine the other values."

The point D is a **new MCS obtained from Lemma 2.6**, not f(x) and not f(y). Lemma 2.6 constructs D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {~δ} ∪ {U(γ,β) : γ∈C, β∈B} and lets D be any MCS extending D₀.

The current code at CounterexampleElimination.lean line 1002 does:
```lean
val := ⟨fun q => if q = z then χ.f pc.x else χ.f q, g', insert z χ.dom⟩
```

This sets `f(z) = f(x)`, which is **not what Burgess does**. Burgess never sets f(z) equal to an existing f-value — he always constructs a fresh MCS from the relevant lemma (2.4, 2.6, 2.7, or 2.8).

**Why this matters for c2'**: With f(z) = f(x), the new adjacent pair (x, z) requires:
```
burgessR3(f(x), g(x,z), f(x))    — the self-pair case
```
But we only have `burgessR3(f(x), g(x,y), f(y))` from the old c2'. The self-pair `burgessR3(A, B, A)` requires `∀γ ∈ A, U(γ, β) ∈ A` for all β ∈ B — which is NOT guaranteed.

With f(z) = D from Lemma 2.6, the new pairs are:
```
R(f(x), B', D)     — from Lemma 2.6 directly
R(D, B'', f(y))    — from Lemma 2.6 directly
```
Both are **given by construction** — no separate proof needed! The self-pair problem vanishes entirely.

### 2. "burgessR3_absorption" is a Misnomer — The Splitting is Lemma 2.6, Not 2.5

The plan v20 references "burgessR3_absorption" for splitting g-values when inserting a point. This is misleading.

**Lemma 2.5** says: If R(A,B,C) and r(A,B',D) and r(D,B'',C) and B ⊆ B'∩D∩B'', then B = B'∩D∩B''. This is a **uniqueness/C3 result**, not a splitting result. It says that if you already have the pieces (B', D, B''), then B is determined by them.

**Lemma 2.6** is the actual splitting lemma: Given R(A,B,C) and δ∉B, it **constructs** B', D, B'' such that:
- ~δ ∈ D
- R(A, B', D) and R(D, B'', C) 
- B = B'∩D∩B''

The key: Lemma 2.6 produces R-maximal B' and B'' — it gives you BurgessR3Maximal for both new adjacent pairs automatically. There's no need for a separate "absorption" lemma.

### 3. What "Let C3 Determine the Other Values" Means

When Burgess says "let C3 determine the other values of g'(w,z) and g'(z,w)", he means: for non-adjacent pairs involving z, set:

```
g'(w, z) = g'(w, x) ∩ f(x) ∩ g'(x, z)    if w < x < z  (i.e., w < x are old points)
g'(z, w) = g'(z, y) ∩ f(y) ∩ g'(y, w)     if z < y < w  (i.e., y < w are old points)
```

And recursively for points further away. Since only g'(x,z) = B' and g'(z,y) = B'' are "new" adjacent-pair values, all other g' values involving z are determined by the C3 identity.

This is exactly what the intersection-based definition achieves for non-adjacent pairs. **But the adjacent-pair values (B', B'') must come from the lemma construction, not from intersection.**

### 4. C5 Elimination (Lemma 2.10): Two Cases with Different g-Construction

Lemma 2.10 (C5 elimination) has two cases:

**Case n=0** (x is the rightmost point in dom f):
- Apply Lemma 2.4 to A = f(x) obtaining B, C
- Set y = x+1, f'(y) = C, g'(x,y) = B
- C3 determines other values

Lemma 2.4 gives R(A, B, C) — so BurgessR3Maximal(f(x), B, C) is immediate.

**Case n=m+1** (there are points after x, let x' be the successor):
Three sub-cases:
1. If η∧U(ξ,η) ∈ f(x') and η ∈ g(x,x'), reduce to case n=m by replacing x by x'
2. If ξ ∈ f(x') and η ∈ g(x,x'), then it's not a counterexample — contradiction
3. Otherwise, apply Lemma 2.7 or 2.8 to **insert a new point z between x and x'**

Sub-case 3 is crucial: it uses Lemma 2.7/2.8 which produce B', D, B'' with:
- R(f(x), B', D) and R(D, B'', f(x'))
- B' ∩ D ∩ B'' = g(x, x') (the old g-value)

So the new g-values B' and B'' come with R-maximality automatically.

### 5. Claim 2.11 (FUC) and the Limit g

In Claim 2.11, Burgess says:

> "If α ∈ f(x), then by C5a there is y ∈ X with x < y and γ ∈ f(y) and β ∈ g(x,y). If z ∈ X and x < z < y, then by C3 we have g(x,y) ⊆ f(z), whence β ∈ f(z)."

Here g(x,y) is the **limit g**: g = ∪ gₙ. The critical insight:

- At some finite stage n, the C5 elimination added point y with g_n(x,y) containing β (from Lemma 2.4 or 2.7/2.8)
- The g-values are **never changed once set** — each (f', g') extends (f, g)
- So in the limit, g(x,y) = g_n(x,y) (the stage-n value)
- By C3 at the limit, g(x,y) ⊆ f(z) for all z between x and y

The key property is **g-immutability**: once g(x,y) is defined at stage n, later stages never change it. This is guaranteed by the "extends" requirement in Burgess — each (f_{n+1}, g_{n+1}) extends (f_n, g_n).

**However**: The current code does NOT preserve old g-values in all elimination functions. The density case redefines g' with an if-then-else that changes g for the (x,z) and (z,y) pairs but keeps old values. But if a later elimination inserts a point w between x and z, it might not properly preserve g'(x,z).

Actually, re-reading more carefully: each elimination function IS supposed to preserve g for old pairs (g_agrees field). The issue is that new adjacent pairs don't get proper g-values. The g-immutability property should hold as long as:
1. Each elimination preserves g for all old pairs (which g_agrees guarantees)
2. Each elimination sets non-trivial g-values for new adjacent pairs (which is currently missing — the 7 sorry sites)

### 6. Alternative Approaches from Other Literature

**Verbrugge 2004**: Uses a step-by-step construction for G/H logics only (without U/S). Not applicable to our problem — they don't handle the chronicle conditions C0-C5 at all. Their approach works for simple temporal logics where the canonical model can be linearized by adding points, but doesn't handle the g-function machinery.

**Reynolds 1992**: Uses Burgess's construction as a black box (Theorem 1) to get a rational-flowed model, then applies Doets's theorem for converting to real-number models. The core construction is Burgess's, so this doesn't provide an alternative strategy for c2'.

**Venema 1993**: Uses Burgess completeness (Theorem 3.5) as a starting point, then employs expressive completeness (Kamp's theorem) + Doets's theorem to lift to well-orderings. Again, the core construction is Burgess's. The key insight from Venema is that axiom W (Fp → U(p, ¬p)) makes U' and S' connectives trivially ⊥, which simplifies the Stavi-connective handling. But this is irrelevant to our chronicle construction.

**Conclusion on alternatives**: None of the alternative literature sources provide a different approach to the chronicle construction itself. They all either use Burgess's construction as a black box or work with G/H-only logics. **The correct path is to fix the current implementation to match Burgess exactly.**

## Recommended Approach

### Fix the Root Cause: Construct f(z) and g-values per Burgess

The 9 sorry sites and the self-pair blocker all stem from one architectural error: **the elimination functions do not construct f(z) and g-values the way Burgess does.**

#### For C4/C4'/density elimination (Lemma 2.9):
1. When inserting z between adjacent x and y, apply **Lemma 2.6** (not "absorption")
2. Lemma 2.6 takes R(f(x), g(x,y), f(y)) and δ∉g(x,y), and produces:
   - D (a new MCS — NOT f(x))
   - B' with R(f(x), B', D) 
   - B'' with R(D, B'', f(y))
   - g(x,y) = B' ∩ D ∩ B''
3. Set f'(z) = D, g'(x,z) = B', g'(z,y) = B''
4. c2' is immediate from the R-maximality outputs of Lemma 2.6

**The self-pair blocker disappears entirely** because f(z) ≠ f(x) in general.

#### For C5/C5' elimination (Lemma 2.10):
- Case n=0: Apply Lemma 2.4. Get B, C with R(A, B, C). Set f'(y) = C, g'(x,y) = B. c2' immediate.
- Case n>0: Either reduce to smaller n, or apply Lemma 2.7/2.8 to insert between x and x'. Get B', D, B'' with R(f(x), B', D) and R(D, B'', f(x')). c2' immediate.

#### For g_prop/h_prop elimination:
These insert a point between adjacent x and y to break a G/H propagation failure. The construction should use Lemma 2.6 as well — inserting z with f(z) = D (a new MCS that lacks the problematic formula), and getting R-maximal B', B'' for free.

### What This Changes in the Codebase

1. **Density elimination**: Change `f(z) = f(x)` to `f(z) = D` where D comes from Lemma 2.6
2. **C5 n>0 case**: Change the construction to use Lemma 2.7/2.8 for the insertion sub-case
3. **g_prop/h_prop**: Change to use Lemma 2.6 for the insertion
4. **Need to formalize**: Lemma 2.6 (the splitting lemma). This is the key missing piece.

### Lemma 2.6 Formalization Requirements

Lemma 2.6 requires:
- Input: R(A, B, C) (i.e., BurgessR3Maximal(A, B, C)) and δ∉B
- Output: B', D, B'' such that:
  - ~δ ∈ D
  - D is an MCS
  - B' is a DCS with R(A, B', D) 
  - B'' is a DCS with R(D, B'', C)
  - B = B' ∩ D ∩ B''

The proof requires:
1. Show D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {~δ} ∪ {U(γ,β) : γ∈C, β∈B} is consistent
2. Key step: for any particular ζ = S(α,β) ∧ β ∧ ~δ ∧ U(γ,β), show it's consistent
3. Uses: the fact that δ∉B implies ∃β₀∈B, γ₀∈C with ~U(γ₀, β₀∧δ) ∈ A
4. Then chains A4a, A5a, A3a to prove consistency via 2.2

This is non-trivial but purely syntactic/proof-theoretic — no semantic arguments needed.

### Limit g Definition

The limit g should be:
```
limit_g(x,y) = g_N(x,y)   where N is the first stage with both x,y in domain
```

By g-immutability (extensions never change old g-values), this is well-defined and equals the C3-derived intersection for non-adjacent pairs in the limit. The current intersection-based definition is correct for the FUC guard propagation but **cannot carry the seed β from C5 construction**, because the intersection definition only knows about f-values at intermediate points — it doesn't know what was put into g at finite stages.

However: in the dense limit domain, every pair has intermediate points, so:
```
limit_g(x,y) = g_N(x,y) ⊆ f(w) for all w between x and y (by C3 at finite stage)
```
And conversely, by C3 at the limit:
```
limit_g(x,y) = ∩{f(w) : w between x and y in limit_dom}
```

So the two definitions **coincide** for the limit of the Burgess construction! The issue is that proving they coincide requires g-immutability and the C3 property at finite stages.

For the FUC proof, what matters is:
- β ∈ g_N(x,y) (from C5 construction at stage N)
- g-immutability: g_N(x,y) = limit_g(x,y) via stage-based definition
- C3: limit_g(x,y) ⊆ f(z) for intermediate z
- Therefore β ∈ f(z) ✓

## Evidence/Examples

### Self-pair counterexample (why f(z)=f(x) fails)

Let A be an MCS with G(p) ∈ A (so F(~p).neg ∈ A). Let B = g(x,y) be a DCS.
Then burgessR3(A, B, A) requires: for all β ∈ B, for all γ ∈ A, U(γ, β) ∈ A.
In particular, taking γ = ~p and β = ⊤: U(~p, ⊤) = F(~p) ∈ A.
But G(p) ∈ A means ~F(~p) ∈ A, contradiction.

So burgessR3(A, B, A) fails whenever A contains any G-formula (which every non-trivial MCS does in tense logic with seriality). **The self-pair is genuinely unsatisfiable for most MCS.**

### Burgess's construction avoids self-pairs

In Lemma 2.6, D is constructed to contain B ∪ {~δ} plus "interaction formulas" S(α,β) and U(γ,β). The MCS D will generally differ from both A and C. The construction is specifically designed so that R(A, B', D) and R(D, B'', C) hold — this is the whole point of the lemma.

## Confidence Level

**High** for the main finding (density sets f(z)=f(x) incorrectly — this is directly verifiable from the Burgess paper text).

**High** for the Lemma 2.6 recommendation (it's the standard splitting tool in Burgess and is what all the alternative literature references as well).

**Medium-High** for the limit_g analysis (the equivalence of stage-based and intersection definitions requires careful argument, but the mathematical logic is sound).

**Low confidence for alternatives**: No viable alternative to the Burgess chronicle construction was found in the literature for Until/Since completeness over linear orders. The construction is essentially unique.
