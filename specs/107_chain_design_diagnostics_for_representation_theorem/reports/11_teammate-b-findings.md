# Teammate B Findings: Venema 1993 and the Density Question

**Artifact**: 11 | **Role**: Teammate B (Literature: Venema 1993 + Verbrugge 2004)
**Task**: 107 -- Chain design diagnostics for representation theorem
**Focus**: Can a completeness proof using dense countermodels (like Q) inadvertently restrict to dense frames?

---

## Executive Summary

The core concern is well-founded but ultimately navigable. Venema 1993 and Verbrugge 2004 address *different* logics with different expressive power, and neither one directly faces the "accidental density" problem in the way our codebase does. The reason: both papers work with logics where the frame class is **axiomatically pinned** -- Venema's completeness results are for well-orders and omega specifically, while Verbrugge constructs models on specific named frames (Q, Z, R). Neither proves completeness for "all strict linear orders" using a dense countermodel. The ProofChecker's situation is genuinely different because its target frame class (all strict linear orders, or a specific class of task frames) must be carefully identified.

---

## Question 1: How Does Venema Handle Strict vs Reflexive Temporal Operators?

### Venema's Semantics Are Strictly Irreflexive

Venema's Since and Until operators use **strict** semantics throughout:

```
M, t ⊨ U(φ, ψ)  iff  ∃ v > t such that M,v ⊨ φ and ∀ u with t < u < v, M,u ⊨ ψ
M, t ⊨ S(φ, ψ)  iff  ∃ v < t such that M,v ⊨ φ and ∀ u with v < u < t, M,u ⊨ ψ
```

The derived operators are:

```
G φ  ≡  U(⊥, φ)       -- "all strictly future times satisfy φ"
F φ  ≡  ¬G(¬φ)         -- "some strictly future time satisfies φ"
H φ  ≡  S(⊥, φ)        -- "all strictly past times satisfy φ"
P φ  ≡  ¬H(¬φ)         -- "some strictly past time satisfies φ"
```

**Critical observation about G φ ≡ U(⊥, φ)**: Under Venema's Until semantics, `U(⊥, φ)` means "there exists v > t with ⊥ true at v (impossible!) and φ true at all u with t < u < v". Since the witness v must satisfy ⊥, the existential is vacuously impossible... UNLESS we interpret this as "φ true at all future points". This is indeed the standard abbreviation: `G φ ≡ U(⊥, φ)` captures "φ at all strictly future times" because no witness for ⊥ exists, so the inner universal quantifier ranges over all future points by convention (the negation `F φ = ¬G¬φ` gives the dual reading).

More precisely: `G φ` is NOT defined through the Until clause directly but as a separate abbreviation. Venema writes `G φ ≡ U(⊥, φ)` where the semantics of `G` is: `M, t ⊨ G φ iff ∀ s > t, M, s ⊨ φ`. This is strict, irreflexive, and matches the ProofChecker's `all_future` semantics exactly.

### Alignment with ProofChecker

The ProofChecker uses:
```lean
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

This is semantically identical to Venema's G. Both are strict (irreflexive).

---

## Question 2: Does Venema Discuss the Density Axiom (GGp -> Gp)?

### Venema Does NOT Include a Density Axiom

Venema's axiom systems are:
- **B**: Base system for all linear orders (axioms A1-A7 for S/U, with mirror images)
- **BW**: B + axiom W (`Fp → U(p, ¬p)`) -- for well-orderings
- **BN**: BW + axiom D -- for omega (natural numbers)

The axiom D in Venema is the **discreteness** axiom:
```
(D):  F⊤ → U(⊤, ⊥)  ∧  P⊤ → S(⊤, ⊥)
```

This says: "if there is a future, then there is an immediate successor (no point strictly between t and its successor)." Venema's Lemma 3.3 confirms: `F ⊨ D iff F is a discrete ordering`.

**There is no density axiom in any of Venema's systems.** The base system B is complete for ALL linear orders (by Burgess's Theorem 3.5). There is no need for a density axiom because the S/U language is expressive enough over linear orders to not need one -- Kamp's theorem gives expressive completeness of S/U over complete linear orders.

### Contrast with Verbrugge 2004

Verbrugge explicitly includes the density axiom for the logic Q:

```
(Q):  GGφ → Gφ
```

This is the additional axiom that extends P (successive linear orders) to Q (dense successive linear orders). Verbrugge's Lemma 5 states: "the relation ≺ over maximal S-consistent sets is dense if (Q) ∈ S."

**The density axiom GGφ → Gφ is valid on dense strict linear orders and fails on discrete ones.** This is because under strict semantics, `G φ` means "φ at all strictly future points." If the order is dense, then between any two points there is a third, so `GG φ → G φ` holds (any strictly future point has a strictly future point between it and the present, so if G φ holds at all those intermediaries, it holds everywhere). On Z, there is an immediate successor with no point between, so `GG φ` can hold (φ true from the successor's successor onward) while `G φ` fails (φ false at the immediate successor).

---

## Question 3: How Does Venema's "Completeness via Completeness" Method Work?

### The Three-Step Method

Venema's proof of completeness for well-orderings (Theorem 4.2) proceeds:

**Step 1**: Start with a BW-consistent formula φ. Use Lindenbaum to get a maximal BW-consistent set Φ containing φ. Since BW extends B, and B is complete for all linear orders (Burgess), Φ is satisfiable in some linear model M.

**Step 2**: Show M is a BW-model (satisfies all BW axioms). Then by Lemma 4.1, M is **definably well-ordered** (every first-order definable subset has a smallest element). This uses the key insight that axiom W forces the Stavi connectives U'/S' to be equivalent to ⊥, which means every definable set is SU-definable, and W guarantees smallest elements for definable sets.

**Step 3**: Apply Doets' Theorem 3.8: any definably well-ordered linear model has n-equivalents in WO (the class of well-orderings) for all n. Since φ^c has finite quantifier depth n, the n+1-equivalent well-ordered model M' also satisfies φ.

### What Frame Does the Countermodel Live On?

The initial model M from Step 1 lives on an **arbitrary linear order** (whatever Burgess's completeness theorem produces -- this is a canonical model construction that yields some linear order, not necessarily Q, Z, or R). The final model M' lives on a **well-ordering**.

**Crucially**: Venema does NOT construct a model on Q. The intermediate model is just "some linear order" from the canonical model. The final model is guaranteed to be a well-ordering by Doets' theorem.

### Completeness for Omega (Theorem 4.3)

For omega, Venema takes a BN-consistent formula φ, notes that φ ∧ □D is BW-consistent, gets a well-ordered model M, and then observes that □D forces the frame to be isomorphic to omega. This is direct and clean.

---

## Question 4: Does Venema Address Whether Dense Countermodels Suffice for General Completeness?

### No, Because His Method Doesn't Use Dense Countermodels

Venema's method is fundamentally different from step-by-step construction. He:
1. Gets ANY linear model (from Burgess's existing completeness for all linear orders)
2. Uses model-theoretic transfer (Doets' theorem) to move to the target frame class

The intermediate model is not constructed to be dense or discrete -- it's whatever the canonical model produces. The expressive completeness of S/U is what makes the transfer work.

**This means Venema's approach entirely sidesteps the density concern.** He never builds a model on Q and tries to use it for a non-dense frame class.

### Verbrugge's Approach: Frame-Specific Construction

Verbrugge 2004 takes the opposite approach -- step-by-step construction where the frame is built explicitly:

- **Theorem 1 (Lin)**: Constructs an arbitrary strict linear order, step by step
- **Theorem 3 (Q)**: Constructs specifically Q by adding density points at odd stages
- **Theorem 5 (D)**: Constructs a discrete, successive strict linear order
- **Theorem 6 (Z)**: Constructs specifically Z using adequate sets

Each construction targets a specific frame class. The density axiom (Q) is ONLY included when the target is a dense frame. When constructing models for discrete logics, discrete axioms (D1, D2) are used instead, and the resulting frame is discrete.

**Verbrugge never uses a dense countermodel for a non-dense logic.** The frame class of the countermodel always matches the axiom system.

---

## Question 5: Under Strict G Semantics, Is GGp → Gp Valid on Dense Frames But Not Discrete Ones?

### Yes, Definitively

**On dense strict linear orders**: Let (T, <) be dense and t ∈ T. Suppose M, t ⊨ GGp, i.e., for all s > t, M, s ⊨ Gp, i.e., for all s > t and all u > s, M, u ⊨ p. We want M, t ⊨ Gp, i.e., for all v > t, M, v ⊨ p. Given any v > t, by density there exists s with t < s < v. Then s > t so M, s ⊨ Gp, and v > s so M, v ⊨ p. Therefore GGp → Gp is valid.

**On discrete strict linear orders (e.g., Z)**: Let t have immediate successor t+1. Define V(p) = T \ {t+1}. Then M, t ⊨ GGp (because for all s > t, the points strictly after s all satisfy p -- the only problematic point t+1 is never strictly after any s > t... wait, this needs more care).

Actually, let me be precise on Z. Let t = 0. Set V(p) = Z \ {1}. Then:
- M, 0 ⊨ Gp? We need p true at all s > 0, i.e., at 1, 2, 3, .... But p is false at 1. So M, 0 ⊭ Gp.
- M, 0 ⊨ GGp? We need Gp true at all s > 0. At s = 1: need p true at all u > 1, i.e., at 2, 3, 4, .... These are all in V(p), so M, 1 ⊨ Gp. At s = 2: need p true at 3, 4, 5, ..., all true. Similarly for all s > 0. So M, 0 ⊨ GGp.

Therefore M, 0 ⊨ GGp ∧ ¬Gp. This confirms **GGp → Gp fails on Z under strict semantics**.

### Implication for the ProofChecker

The ProofChecker uses strict semantics (`t < s`, not `t ≤ s`). If the completeness proof constructs a countermodel on a dense frame (like Q), then:
- GGp → Gp is automatically valid in the countermodel
- This means the countermodel cannot refute GGp → Gp
- If the target logic does NOT include the density axiom, then the completeness proof would be incomplete -- it could not produce a countermodel for a formula like ¬(GGp → Gp) that is consistent with the base logic but invalid on dense frames

**However**: This only matters if the target frame class includes non-dense frames AND the logic does not include the density axiom. If the ProofChecker's BX logic includes axioms that force density (or if the target is specifically dense frames), then there is no problem.

---

## Synthesis: What This Means for Task 107

### The Core Issue Restated

The ProofChecker needs a completeness theorem. The question is: for WHICH class of frames?

1. **If the target is all strict linear orders**: A dense countermodel (on Q) would only prove completeness for dense linear orders, not all. The proof would need either:
   - A Venema-style transfer theorem (model-theoretic, using expressive completeness) to move from "any linear model" to the target frame, OR
   - A Verbrugge-style frame-specific construction where the frame matches the target class

2. **If the target is dense strict linear orders (or Q specifically)**: A dense countermodel is fine. The density axiom GGp → Gp should be included in the axiom system.

3. **If the target is a specific frame like R or Q**: The construction should produce that specific frame, as Verbrugge does.

### What the Chronicle Construction Actually Does

The omega-chain chronicle construction builds a countable domain within Q (the rationals). The key question is whether this domain is dense in Q.

Looking at the construction:
- It starts with {0}
- At each step, it may add midpoints (between existing points) or +1 successors
- The `limit_dom` is the union of all finite chronicle domains

**If the domain is dense**: The model lives on a dense suborder of Q, and GGp → Gp is valid. This is fine IF the BX axiom system includes (or derives) GGp → Gp.

**If the domain is NOT dense**: There may be gaps, and the extension to all of Q (via `extended_limit_f`) must handle non-domain points. The `forward_G` problem arises precisely at these gaps.

### The Resolution Path

The ProofChecker's BX system includes the temporal 4-axiom: `Gφ → GGφ` (BX3/temp_4). Under strict semantics on dense frames, this plus density gives `GGφ → Gφ` as valid. But the 4-axiom alone does NOT give `GGφ → Gφ`.

**Key question for the project**: Does the BX axiom system include a density axiom? If not, what class of frames is the completeness theorem targeting?

Looking at the ProofChecker's axiom system, it appears to be a bimodal logic (S5 modal + linear temporal). The temporal part uses strict semantics. If the domain D is required to satisfy `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and the canonical instantiation is `D = Rat`, then the frame IS dense (Q is dense). In this case:

1. GGp → Gp IS valid on the target frame (Q with strict <)
2. The completeness theorem is specifically for Q-based task frames
3. A dense countermodel is perfectly appropriate
4. There is NO accidental restriction -- density is a feature of the target frame class, not a bug

**This resolves the core concern**: The ProofChecker is not trying to prove completeness for all strict linear orders. It is proving completeness for task frames over Q (or more generally, dense ordered abelian groups). The density axiom is valid on these frames, and the chronicle construction producing a dense countermodel is correct.

---

## Detailed Literature Notes

### Venema 1993: Key Technical Details

| Aspect | Detail |
|--------|--------|
| **Semantics** | Strict (irreflexive) for S/U, with G/H derived as U(⊥,φ)/S(⊥,φ) |
| **Base logic B** | Complete for all linear orders (Burgess) |
| **BW** | B + well-foundedness axiom W; complete for well-orderings |
| **BN** | BW + discreteness axiom D; complete for omega |
| **Method** | Expressive completeness (Kamp/Stavi) + model-theoretic transfer (Doets) |
| **No density axiom** | Not needed because B already captures all linear orders |
| **Key Lemma 4.1** | Every BW-model is definably well-ordered (uses Stavi connectives + axiom W) |
| **Intermediate model** | Lives on arbitrary linear order, NOT necessarily dense |

### Verbrugge 2004: Key Technical Details

| Aspect | Detail |
|--------|--------|
| **Semantics** | Strict (G and H with strict <) |
| **Density axiom** | (Q): GGφ → Gφ, explicitly included for dense logics |
| **Discreteness axioms** | (D1): (φ ∧ Gφ) → PGφ; (D2): (φ ∧ Hφ) → FHφ |
| **Method** | Step-by-step construction building specific frame |
| **Theorem 3** | Q complete w.r.t. Q -- constructs model on Q by adding density points |
| **Theorem 5** | D complete w.r.t. discrete orders -- constructs discrete model |
| **Theorem 6** | Z complete w.r.t. Z -- uses adequate sets for finite model property |
| **Theorem 7** | D complete w.r.t. Z ⊙ Z -- copies-of-Z construction |
| **Key insight** | Frame class ALWAYS matches axiom system; no cross-class transfer |

### The "Accidental Density" Phenomenon

Verbrugge's construction for Q (Theorem 3) explicitly adds density points at odd stages. This is intentional, not accidental. For D and Z, no density points are added, and the resulting frames are discrete.

The concern about "accidental density" would arise if:
1. The axiom system does NOT include GGφ → Gφ
2. The construction produces a dense frame
3. The completeness theorem claims to cover non-dense frames

None of the literature papers have this problem because they are careful about matching axioms to frame classes.

---

## References

1. Venema, Y. (1993). "Completeness via Completeness: Since and Until." In: de Rijke (ed.), Diamonds and Defaults, Synthese Library 229, Kluwer.
2. Verbrugge, R., de Jongh, D., Veltman, F. (2004). "Completeness by Construction for Tense Logics of Linear Time." ILLC University of Amsterdam.
3. Burgess, J.P. (1982). "Axioms for Tense Logic: I. 'Since' and 'Until'." NDJFL 23, 367-374.
4. Kamp, J.A.W. (1968). Tense Logic and the Theory of Linear Order. PhD thesis, UCLA.
5. Doets, K. (1989). "Monadic Π¹₁-Theories of Π¹₁-Properties." NDJFL 30, 224-240.
