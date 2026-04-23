# Teammate A Findings: Burgess 1982 Literature Study

**Task**: 107 - Chain design diagnostics for representation theorem
**Round**: 5 (Literature study)
**Source**: Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367-374.
**Date**: 2026-04-23

---

## Question 1: How Does Burgess Build the Linear Order?

**Answer**: Burgess does NOT use a fixed omega-chain. He builds points DYNAMICALLY by iterative extension of finite chronicles, using the RATIONALS as the index set.

**Details**:

The construction starts with a single point `f_0(0) = A_0` (an MCS containing the consistent formula `alpha_0`) and forms a sequence `(f_n, g_n)` of elements of F (the set of all chronicles), each extending the one before. At each step, a single counterexample to either C4a/C4b (negation witness) or C5a/C5b (Until/Since witness) is eliminated by adding ONE new rational point.

The final model has `X = union of dom(f_n)` as a subset of the rationals, ordered by the usual order on Q.

Key properties of the construction:
- (C0): `f` maps a FINITE subset of Q to the set of all MCSs
- (C0'): dom(f) is finite at each stage
- Each extension adds exactly one new rational point (placed at midpoints or beyond existing points)

**Confidence**: HIGH -- This is stated explicitly in Sections 2.9, 2.10, and the final assembly paragraph after 2.10.

---

## Question 2: What Is a "Chronicle"?

**Answer**: A chronicle `(f, g)` is a pair satisfying conditions C0-C3:

- `f`: A function from a finite subset of Q to the set of all MCSs. `f(x)` represents the complete state of affairs at time `x`.
- `g(x, y)`: A function from pairs `{(x, y) : x, y in dom(f), x < y}` to the set of all DCSs (deductively closed sets). `g(x, y)` describes what remains true throughout the entire interval between `x` and `y`.

**Critical conditions**:

- **(C2)**: For `x < y` in dom(f), `r(f(x), g(x,y), f(y))` holds, where the relation `r(A, beta, C)` means: for all `gamma in C`, `U(gamma, beta) in A`, equivalently for all `alpha in A`, `S(alpha, beta) in C` (Lemma 2.3).

- **(C2')**: When `x` immediately precedes `y` in dom(f), the stronger condition `R(f(x), g(x,y), f(y))` holds, where `R` means `g(x,y)` is MAXIMAL with respect to the `r`-relation.

- **(C3)**: For `x < y < z`, `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`. This is the INTERSECTION PROPERTY: the formulas true throughout `[x,z]` are exactly those true throughout `[x,y]`, at `y`, and throughout `[y,z]`.

**Mapping to project**: `g(x,y)` is conceptually analogous to the project's `g_content`, but with a crucial difference. In the project, `g_content(M) = {phi | G(phi) in M}` extracts from a SINGLE MCS. In Burgess, `g(x,y)` is a DCS that mediates between TWO specific MCSs `f(x)` and `f(y)`, and it satisfies the maximality condition (C2'). This maximality is essential -- it enables the interpolation lemmas (2.6, 2.7, 2.8) that are the heart of the proof.

**Confidence**: HIGH -- Direct from Burgess Sections 2.3-2.8 and the chronicle definition.

---

## Question 3: How Does Burgess Handle the Until Operator?

**Answer**: The key axioms and their roles:

**A5a** (`U(p,q) -> U(p, q /\ U(p,q))`): Self-accumulation. If p-Until-q holds, then the guard q can be strengthened to include the Until itself. This corresponds to BX5 in the project.

**A6a** (`U(q /\ U(p,q), q) -> U(p,q)`): Absorption. If Until holds with a strengthened guard, we can recover the original Until. This corresponds to BX6 in the project.

**A7a** (Linearity of Until): When two Until formulas hold simultaneously, the witnesses are linearly ordered. This corresponds to BX7 in the project.

**A4a** (`U(p,q) /\ ~U(p,r) -> U(q /\ ~r, q)`): The negation separation axiom. When `U(p,q)` holds but `U(p,r)` fails, there exists an intermediate point where `q` holds but `r` doesn't.

**C5a** (chronicle condition): "Whenever `x in dom(f)` and `U(xi, eta) in f(x)`, there is some `y in dom(f)` with `x < y` and `xi in f(y)` and `eta in g(x,y)`."

This is the EXISTENCE condition for Until witnesses. It says: if `phi U psi` holds at time `x`, there must be a future time `y` where `psi` holds, with `phi` true throughout the interval `(x, y)` -- captured by `eta in g(x,y)`.

**C4a** (negation separation): "Whenever `x < y` and `~U(gamma, delta) in f(x)` and `gamma in f(y)`, there is some `z` with `x < z < y` and `~delta in f(z)`."

This prevents false Until witnesses. If `~U(gamma, delta)` holds at `x` but `gamma` holds at `y`, there must be an intermediate point where `delta` fails.

**Confidence**: HIGH -- Direct from Burgess Sections 1.3 and 2.8-2.10.

---

## Question 4: The KEY STEP -- How F(phi) Is Resolved

**THIS IS THE CRITICAL FINDING FOR THE PROJECT.**

**Answer**: Burgess resolves F(phi) by building SEPARATE witness chains for each temporal obligation, one counterexample at a time, via POINT INSERTION into the rationals.

The algorithm is:

### Pseudocode for the Full Construction

```
1. Start: (f_0, g_0) with dom(f_0) = {0}, f_0(0) = A_0 (MCS containing alpha_0)

2. Enumerate all counterexamples to C4a, C4b, C5a, C5b for the current (f_n, g_n).
   Since dom(f_n) is finite and the set of formulas in each MCS is fixed,
   the set of potential counterexamples is enumerable.

3. For each counterexample, apply Lemma 2.9 or 2.10 (or mirror) to extend
   (f_n, g_n) to (f_{n+1}, g_{n+1}) that eliminates that counterexample.

4. Take the union: X = union dom(f_n), f = union f_n, g = union g_n.
   The result satisfies C0-C5.
```

### The Specific F-Resolution Mechanism (Lemma 2.10)

When `U(xi, eta) in f(x)` is a counterexample to C5a:

**Case n = 0** (no points after x):
- Apply Lemma 2.4 to `A = f(x)`, obtaining `B, C` such that `eta in B`, `xi in C`, `R(A, B, C)`.
- Set `y = x + 1`, `f'(y) = C`, `g'(x, y) = B`.
- This creates the Until witness: `xi in f'(y)` and `eta in g'(x, y)`.

**Case n = m + 1** (points exist after x):
Let `x'` immediately succeed `x` in dom(f).

Three sub-cases:
1. If `eta /\ U(xi, eta) in f(x')` AND `eta in g(x, x')`: REDUCE to case n = m by replacing x with x'. The Until obligation propagates forward along the existing chain.

2. If condition (1) fails AND `xi in f(x')` AND `eta in g(x, x')`: DONE -- x' IS the witness (xi in f(x') and eta in g(x, x')).

3. If both (1) and (2) fail: Apply Lemma 2.7 or 2.8 to INSERT a new point `z = (x + x')/2` between x and x'. The interpolation lemmas guarantee that the new DCSs `g'(x, z)` and `g'(z, x')` satisfy all chronicle conditions, and the Until witness appears at the inserted point.

**THE KEY INSIGHT**: Burgess does NOT try to prove that F(phi) propagates through an infinite chain. Instead, he proves that for any SPECIFIC Until obligation `U(xi, eta) in f(x)`, there exists a FINITE extension of the chronicle that provides a witness point. The extension adds at most one new point per counterexample. The full model is the union of all such finite extensions.

This completely bypasses the F-propagation problem because:
- Each Until/F obligation is handled INDEPENDENTLY
- The construction is NOT building a single infinite chain where obligations must propagate
- Instead, it's building a GROWING set of rational points where each obligation gets its own witness

### Why This Works and the Project's Approach Doesn't

The project's approach tries to build an omega-indexed chain `M_0, M_1, M_2, ...` where:
- `g_content(M_n) subset M_{n+1}` at each step
- F(phi) must eventually be resolved at some step

The problem: the BX11 fold resolves SOME formula at each step, but may perpetually defer phi due to Case 3 non-determinism.

Burgess avoids this entirely by:
1. NOT fixing the index set in advance (it grows dynamically)
2. Inserting points into GAPS in the rational order (midpoints)
3. Using Lemma 2.4 for fresh witness construction (not BX11 fold)
4. Using Lemmas 2.6-2.8 for interpolation (splitting an interval at a new point)

**The BX11 fold is NOT used for F-resolution in Burgess.** The linearity axiom A7a (= BX7, not BX11) appears only in Lemma 2.7 for the interpolation step when inserting a point between two EXISTING points. The F-resolution itself uses only Lemma 2.4, which relies on A3a (= BX4, temporal connectedness) and the consistency criterion 2.2.

**Confidence**: HIGH -- This is the central argument of the paper, stated explicitly in Lemmas 2.9, 2.10, and the final construction paragraph.

---

## Question 5: Reflexive vs. Strict Until

**Answer**: Burgess uses STRICT Until.

In Burgess's semantics (Section 1.2):
```
V(U(alpha, beta)) = {x : exists y (x < y /\ y in V(alpha) /\ forall z (x < z < y => z in V(beta)))}
```

The witness `y` satisfies `x < y` (STRICT inequality). The guard interval is the OPEN interval `(x, y)`.

The project uses REFLEXIVE Until (Section `Truth.lean` line 128):
```
| Formula.untl phi psi => exists s, t <= s /\ truth_at ... s psi /\ forall r, t <= r -> r < s -> truth_at ... r phi
```

The witness `s` satisfies `t <= s` (WEAK inequality). The guard interval is `[t, s)`.

**Implications for applying Burgess's technique**:

1. BX8 (`psi -> phi U psi`) is sound for reflexive Until but NOT for strict Until. Burgess does not have this axiom. This is fine -- BX8 is an ADDITIONAL axiom the project has, which makes the project's logic STRONGER, not weaker.

2. The chronicle conditions C4a and C5a use strict inequality (`x < y`, `x < z < y`). For reflexive Until, the analog would use weak inequality (`x <= y`, `x <= z < y`).

3. The critical Lemma 2.4 (witness construction) works for both strict and reflexive Until. For reflexive Until, the "trivial witness" (s = t with psi(t)) is already handled by BX8, so the interesting case is when we need a STRICTLY future witness, which is exactly what Lemma 2.4 provides.

4. Burgess's `F(alpha)` is defined as `U(alpha, T)` -- i.e., strict Until with tautological guard. In the project, `F(phi) = ~G(~phi)`. Under reflexive Until, `F(phi)` includes the case phi(t) (current time). BX12 bridges these: `F(phi) -> T U phi`.

**Bottom line**: Burgess's construction IS applicable to the project's reflexive Until. The reflexive case is strictly easier (BX8 gives "trivial" witnesses for free). The hard case (strict future witnesses) is handled identically.

**Confidence**: HIGH -- Direct comparison of the two semantics.

---

## Question 6: Burgess "Chronicles" vs. Project "BFMCS"

**Answer**: The correspondence is:

| Burgess | Project | Notes |
|---------|---------|-------|
| `f(x)` for x in dom(f) | `fam.mcs(t)` for t in Int | MCS at time point |
| `g(x, y)` | `g_content(fam.mcs(t))` for adjacent t | Formulas true throughout interval |
| Chronicle `(f, g)` | FMCS (family of MCS) | One "timeline" |
| Set of chronicles F | BFMCS.families | Bundle of timelines |
| dom(f) subset Q | Int (= Z) | Index set |
| C3: `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)` | Implicit via g_content propagation | Interval decomposition |
| R(A, B, C) maximality | No direct analog | **CRITICAL GAP** |

**Critical differences**:

1. **Index set**: Burgess uses a dynamically growing finite subset of Q. The project uses ALL of Z (integers). This is a fundamental architectural difference. Burgess can insert points between existing points; the project cannot (integers have no gaps).

2. **g(x,y) vs g_content**: In Burgess, `g(x,y)` is a DCS that encodes what's true throughout `[x,y]`. It's defined for all pairs, not just adjacent ones. In the project, `g_content(M) = {phi | G(phi) in M}` is defined for a SINGLE MCS, and only captures what `M` asserts about ALL future times, not about a specific interval. The project has NO analog of `g(x,y)` for a specific interval.

3. **C3 (intersection property)**: Burgess has `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`. The project approximates this with `g_content(M_n) subset M_{n+1}`, but this is strictly weaker. It does not track what's true on a SPECIFIC interval.

4. **Maximality**: Burgess's `R(A, B, C)` means `g(x,y)` is MAXIMAL among DCSs satisfying the `r`-relation. This maximality is essential for the interpolation lemmas (2.6-2.8). The project has no analog of this maximality.

5. **Point insertion**: Burgess's key proof technique (inserting points at midpoints of rationals) is impossible in the project's Z-indexed chain. There is no integer between two consecutive integers.

**Confidence**: HIGH -- Direct structural comparison.

---

## Exact Technique Summary: Burgess's Algorithm

```
INPUT: Consistent formula alpha_0
OUTPUT: Linear order (X, <) with valuation V where alpha_0 is satisfiable

ALGORITHM:
1. INITIALIZE:
   - Let A_0 be an MCS containing alpha_0 (Lindenbaum's lemma)
   - Set f_0(0) = A_0, g_0 = empty, dom(f_0) = {0}

2. ITERATE (enumerate all counterexamples):
   For each (f_n, g_n), consider all tuples that constitute counterexamples
   to C4a, C4b, C5a, C5b:

   a. C5a COUNTEREXAMPLE (F/Until resolution):
      U(xi, eta) in f_n(x) but no y > x in dom(f_n) with xi in f_n(y), eta in g_n(x,y).
      -> Apply Lemma 2.10: Add one point y to dom(f_n).
         - If no points exist after x: use Lemma 2.4 to create fresh witness.
         - If points exist after x: either propagate forward or INSERT midpoint.

   b. C4a COUNTEREXAMPLE (negation separation):
      ~U(gamma, delta) in f_n(x), gamma in f_n(y), x < y,
      but no z between x and y with ~delta in f_n(z).
      -> Apply Lemma 2.9: Insert one point z between x and y.
         - Uses Lemma 2.6 (or 2.7/2.8) for interpolation.

   c. Mirror images for C4b, C5b (Since direction).

3. UNION:
   X = union dom(f_n)
   f = union f_n
   g = union g_n
   V(p_i) = {x in X | p_i in f(x)}

4. VERIFY:
   (+) x in V(alpha) iff alpha in f(x)  -- by induction on complexity (Claim 2.11)
   alpha_0 in f(0) = A_0, so alpha_0 is satisfiable.
```

---

## Mapping to Project Infrastructure

### What Burgess's Approach Requires That the Project Lacks

1. **DENSE index set with point insertion**: The project uses Z (integers). Burgess uses Q (rationals). The project CANNOT insert points between consecutive integers. To adopt Burgess's approach, the project would need to either:
   - Switch to Q-indexed chains (major refactor)
   - Use a tree-like construction where "insertion" means adding a new branch
   - Use an equivalent construction on Z that simulates density

2. **Interval-specific g(x,y)**: The project's `g_content(M)` does not track interval-specific truth. Burgess's `g(x,y)` is essential for interpolation. The project would need to define and maintain interval content.

3. **Maximality of g(x,y)**: The project has no analog of `R(A, B, C)` maximality. This is needed for the interpolation lemmas.

4. **Lemma 2.4 analog**: The project needs a proof that given `U(xi, eta) in M` (MCS), there exist MCSs `B` (interval content) and `C` (witness point) with `eta in B`, `xi in C`, and `R(M, B, C)`. The project has `forward_temporal_witness_seed_consistent` and `fwd_succ` which partially serve this purpose but do not construct the full `(B, C)` pair with the maximality property.

### What the Project Already Has

1. **BX axioms corresponding to Burgess's axioms**: BX2=A1a, BX3=A2a, BX4=A3a, BX5=A5a, BX6=A6a, BX7=A7a. The axiom systems are closely aligned.

2. **MCS infrastructure**: Lindenbaum's lemma, MCS properties, g_content propagation.

3. **F(F(psi)) -> F(psi)**: Derived in `FF_imp_F` (line 61). Burgess doesn't need this explicitly because his construction doesn't iterate F-formulas.

4. **BX11 fold**: The project's `enriched_fwd_fold` and `resolving_enriched_fwd_exists` are more sophisticated than anything in Burgess. They are needed for the project's omega-chain approach but are NOT needed for Burgess's point-insertion approach.

### Concrete Adaptation Strategy

The most faithful adaptation of Burgess to the project would be:

**Option A: Switch to Q-indexed model (HIGH effort, HIGH fidelity)**
- Replace `dd_chain : Int -> Set Formula` with a growing finite subset of Q
- Define `g(x,y)` as a DCS for each pair, with maximality
- Implement Lemmas 2.4, 2.6, 2.7, 2.8 as separate theorems
- Build the model by iterative counterexample elimination
- Estimated effort: 40-80 hours (major architectural change)

**Option B: Finite witness chains per obligation (MEDIUM effort, MEDIUM fidelity)**
- Keep the Z-indexed chain skeleton
- For each F(phi) obligation, build a SEPARATE finite chain (bounded by |Sigma|) that resolves phi
- Assembly: interleave the witness chains into the main chain
- This captures the spirit of Burgess (separate witness per obligation) without Q-indexing
- The quasimodel infrastructure (`HintikkaPoint`, `sigma_signature`, `defect_count`) supports this
- Estimated effort: 25-40 hours

**Option C: Simulate density via the BX11 fold (LOW effort, UNCERTAIN)**
- Keep the current architecture entirely
- Prove convergence of the BX11 fold (the open question from Report 03)
- This does NOT use Burgess's technique but may work if convergence can be proved
- Risk: convergence may fail due to perpetual Case 3 deferral
- Estimated effort: 10-20 hours (if convergence holds), DEAD END (if not)

### What the Sorry Sites Need, Mapped to Burgess

| Sorry | What It Needs | Burgess Analog | Gap |
|-------|---------------|----------------|-----|
| #1 (line 1143) `fwd_chain_forward_F` | F(phi) in chain(n) => phi in chain(m) for some m > n | Lemma 2.10 (C5a counterexample elimination) | Burgess inserts points; project needs phi at a fixed Z-index |
| #2 (line 1170) backward F in chain | F(phi) in backward chain => resolved in forward chain | Mirror of Lemma 2.10 + cross-chain reasoning | Project has no backward preserving step |
| #3 (line 1177) backward P | P(phi) in chain(t) => phi in chain(u) for u < t | Mirror of Lemma 2.10 (C5b) | Symmetric to #1 for backward direction |
| #4 (line 1185/1192) backward Until/Since coherence | phi U psi at t given semantic witnesses | Claim 2.11 (induction on complexity) | Project needs step-transfer for Until |
| #5 (line 1210) forward Until/Since coherence | phi U psi propagation | Claim 2.11 + C4a/C5a | Requires resolved F-obligations |

---

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Q-indexed refactor is too large | HIGH | Use Option B (finite witness chains) instead |
| Option B requires connecting quasimodel to main chain | MEDIUM | Quasimodel infrastructure exists; connection is well-scoped |
| Finite witness chains may face same g_content issues | LOW | Burgess's g(x,y) intervals avoid g_content entirely |
| BX system differs enough from Burgess to invalidate technique | LOW | Axiom correspondence is nearly exact (BX2-7 = A1a-A7a) |
| Backward direction (sorries #2, #3) requires separate treatment | MEDIUM | Build symmetric backward infrastructure (preserving_bwd_step) |

---

## Appendix: Axiom Correspondence Table

| Burgess | BX System | Statement |
|---------|-----------|-----------|
| A1a | BX2 (left_mono_until) | G(p->q) -> (U(p,r) -> U(q,r)) |
| A2a | BX3 (right_mono_until) | G(p->q) -> (U(r,p) -> U(r,q)) |
| A3a | BX4 (connect_future) | p /\ U(q,r) -> U(q /\ S(p,r), r) |
| A4a | (derived / implicit) | U(p,q) /\ ~U(p,r) -> U(q /\ ~r, q) |
| A5a | BX5 (self_accum_until) | U(p,q) -> U(p /\ U(p,q), q) |
| A6a | BX6 (absorb_until) | U(q /\ U(p,q), q) -> U(p,q) |
| A7a | BX7 (linear_until) | Linearity of two concurrent Untils |
| -- | BX8 (refl_intro_until) | psi -> phi U psi (reflexive intro, Burgess lacks this) |
| -- | BX9 (until_elim) | phi U psi -> phi \/ psi |
| -- | BX10 (until_F) | phi U psi -> F(psi) |
| -- | BX11 (temp_linearity) | F(p) /\ F(q) -> F(p/\q) \/ F(p/\F(q)) \/ F(F(p)/\q) |
| -- | BX12 (F_until_equiv) | F(phi) -> T U phi |

**Note on A3a vs BX4**: Burgess's A3a connects Until with Since (cross-temporal). The project's BX4 is `phi -> G(P(phi))` (temporal connectedness). These are DIFFERENT axioms. Need to verify whether A3a is derivable in BX or if it needs to be added. This is a potential gap.

**Note on A4a**: Burgess's A4a (`U(p,q) /\ ~U(p,r) -> U(q /\ ~r, q)`) is used in Lemma 2.6 for the interpolation. Need to verify whether this is derivable from BX1-BX12. If not, this is a CRITICAL gap.

---

## Summary of Key Findings

1. **Burgess builds points dynamically in Q, not a fixed omega-chain.** The project's Z-indexed chain is architecturally incompatible with Burgess's point-insertion technique.

2. **F-resolution works by creating INDEPENDENT witnesses per obligation**, not by propagating F-formulas through a single chain. Each Until obligation gets its own witness point via Lemma 2.4.

3. **The interpolation lemmas (2.6-2.8) are the technical heart.** They enable inserting a new point between two existing ones while maintaining all chronicle conditions. These require the MAXIMALITY of g(x,y), which the project lacks.

4. **Burgess uses STRICT Until; the project uses REFLEXIVE Until.** The reflexive case is easier (BX8 gives trivial witnesses). Burgess's technique applies with minor adaptation.

5. **The BX11 fold is NOT part of Burgess's approach.** The project's reliance on BX11 for F-resolution is a deviation from the literature. Burgess uses BX7 (A7a) only for interpolation, not for F-resolution.

6. **Two axioms need derivability verification**: A3a (cross-temporal Until/Since connection) and A4a (negation separation for Until). If either is not derivable in BX, this is a gap that must be addressed.

7. **Most promising path forward**: Finite witness chains (Option B) -- build separate bounded chains for each temporal obligation using the existing quasimodel infrastructure, capturing Burgess's core insight without the Q-indexed refactor.
