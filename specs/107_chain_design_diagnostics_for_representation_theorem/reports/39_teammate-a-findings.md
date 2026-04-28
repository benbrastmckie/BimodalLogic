# Teammate A Findings: Burgess 1982 Chronicle Construction — Detailed Mapping

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Focus**: Read Burgess 1982 in detail and map his proof strategy onto the Lean codebase
**Date**: 2026-04-28

## 1. How Burgess Defines the r-Relation

### Burgess's Definition (p. 370)

Burgess defines r as a **3-argument relation with a single formula** as the middle argument:

> "We write r(A, β, C) to indicate that A, C are MCSs related as in 2.3."

Where Lemma 2.3 establishes the equivalence: for MCSs A, C and any formula β:
- (a) ∀γ ∈ C, U(γ, β) ∈ A  ⟺  (b) ∀α ∈ A, S(α, β) ∈ C

He then lifts to sets:
- **r(A, B, C)**: B is a DCS and r(A, β, C) holds for ALL β ∈ B
- **R(A, B, C)**: B is **maximal** with respect to r(A, —, C)

### Critical Observation: Burgess's r is NOT the Codebase's rRelation

The codebase has TWO different r-relations:

| Concept | Definition | Direction |
|---------|-----------|-----------|
| **Codebase `rRelation(A, B)`** | ∀ γ δ, (γ U δ) ∈ A → δ ∈ B ∨ (γ ∈ B ∧ (γ U δ) ∈ B) | Obligation propagation: A → B |
| **Burgess `r(A, β, C)`** | ∀ γ ∈ C, U(γ, β) ∈ A | Content: β guards between A and C |

**Burgess's r is the codebase's `burgessR`** (ChronicleTypes.lean:274):
```lean
def burgessR (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  ∀ γ ∈ C, Formula.untl β γ ∈ A
```

And the set version is `burgessRSet` (line 281). The combined forward+backward version is `burgessR3` (line 305).

**The codebase `rRelation` is a DIFFERENT concept** that does not appear in Burgess's paper. It captures obligation propagation (how Until formulas resolve step-by-step), while Burgess's r captures content (what a guard formula β contributes to the relationship between endpoints).

### Burgess Does NOT Use Anything Like the Codebase's `rRelation`

Burgess's entire proof uses only r(A, β, C) / r(A, B, C) / R(A, B, C). The two-argument obligation-propagation relation is an artifact of the codebase, not from the paper.

**Impact**: The FUC sorry sites that rely on `rRelation_guard_continues'` are using the WRONG concept. Report 38 correctly identified that `rRelation` is not established between limit_f pairs, but the deeper issue is that Burgess's proof doesn't use this concept at all.

## 2. How Burgess Proves Consistency of the Seed Set (Lemma 2.6)

### Burgess's Lemma 2.6 (p. 371)

**Statement**: Suppose R(A, B, C) and δ ∉ B. Then there exist B', D, B'' such that ¬δ ∈ D and R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B''.

**Proof**: The seed set is:
```
D₀ = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}
```

Burgess proves consistency of each particular:
```
ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β)
```

The proof uses (with our axiom naming):
1. Since R(A, B, C) and δ ∉ B, there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀ ∧ δ) ∈ A
2. From r(A, B, C): U(γ, β) ∈ A (for β ∈ B, γ ∈ C)
3. **A5a** (self_accum_until/BX5): U(γ, β ∧ U(γ, β)) ∈ A
4. **A4a** (BX equivalent): from U(γ, β) and ¬U(γ, β ∧ δ), derive U(β ∧ U(γ,β) ∧ ¬δ, β) ∈ A
5. **A3a** (BX equivalent): enrich with S(α, β) to get U(β ∧ U(γ,β) ∧ ¬δ ∧ S(α,β), β) ∈ A
6. **Consistency Criterion 2.2**: the formula inside U is consistent

### Does Burgess Need B ⊆ A? **NO!**

Critically, Burgess's proof **never uses** B ⊆ A or B ⊆ C. The elements of B enter the seed set D₀ **directly** (B is a component of D₀). The consistency argument works because:
- For S(α,β) with α ∈ A, β ∈ B: these come from r(A,B,C) applied backward (Lemma 2.3b)
- For U(γ,β) with γ ∈ C, β ∈ B: these come from r(A,B,C) applied forward (Lemma 2.3a)
- For β ∈ B: these are DCS elements, used as guards in the Until/Since formulas
- For ¬δ: the negation of the formula being inserted

The key is that B elements serve as **guards** in Until and Since formulas that belong to A or C. Burgess never needs to prove that B elements themselves belong to A or C.

### What Axioms Does He Actually Use?

1. **A4a** — This is `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. In BX terms, this is a combination of BX5 + BX7 (self_accum + linear_until). Let me verify: A4a says if Until(p,q) holds and Until(p,r) fails, then Until(q∧¬r, q) holds. This is the "linearity of Until" combined with negation.

2. **A5a** — This is `U(p,q) → U(p, q ∧ U(p,q))`. This is exactly **BX5** (self_accum_until).

3. **A3a** — This is `p ∧ U(q,r) → U(q ∧ S(p,r), r)`. This enriches an Until guard with a Since formula. In BX, this corresponds to BX4 (connect_future) combined with other axioms.

### Does It Work Under Open Guard? **THIS IS THE KEY QUESTION**

Burgess's semantics (p. 368) defines:
```
V(U(α,β)) = {x : ∃y(x < y ∧ y ∈ V(α) ∧ ∀z(x < z < y ⊃ z ∈ V(β)))}
```

This is **open guard** semantics! The guard β holds on (x,y), NOT on [x,y) or [x,y]. Burgess's entire paper uses strict/open intervals.

**Therefore**: Burgess's axioms A1a-A7a are sound under open guard. His proof of Lemma 2.6 uses only these axioms. The proof works under open guard.

### The Problem: A3a and A4a Are NOT Valid Under Our Semantics

Wait — the codebase header says (PointInsertion.lean:17-18):

> "Burgess uses axioms A3a and A4a which are **not valid** under strict semantics"

But Burgess PROVES A3a and A4a are valid (Soundness theorem 1.4). His semantics IS strict/open guard. So either:
1. The codebase is wrong about A3a/A4a being invalid, OR
2. The codebase's "strict semantics" differs from Burgess's in some other way

**Critical finding**: The codebase uses a BIMODAL logic (TM) that adds Box/Diamond for S5 modality on top of tense logic. Burgess's paper is pure tense logic (G, H, U, S only). The axioms A3a/A4a may be invalid in the presence of Box/Diamond interactions, even though they are valid in pure tense logic.

**However**, looking at A3a more carefully: `p ∧ U(q,r) → U(q ∧ S(p,r), r)`. This is purely temporal — no Box/Diamond. If the tense operators have the same semantics, A3a should be valid regardless of whether there's a Box modality.

**The real question**: Is the codebase's Until semantics identical to Burgess's? If yes, A3a/A4a are valid and the codebase's claim they are invalid is wrong. If no, there's a semantic difference beyond the guard convention.

Let me check: Burgess has `V(U(α,β)) = {x : ∃y(x < y ∧ y ∈ V(α) ∧ ∀z(x < z < y ⊃ z ∈ V(β)))}`. Note the argument order: **U(event, guard)** — the FIRST argument is the EVENT, the SECOND is the GUARD.

The codebase (from ChronicleTypes.lean comments): `untl γ δ` where γ is the GUARD and δ is the EVENT. So `untl(γ,δ)` corresponds to Burgess's `U(δ, γ)` — **the argument order is SWAPPED**.

With this correction, Burgess's A3a becomes (in codebase terms):
```
p ∧ untl(r, q) → untl(r, q ∧ snce(r, p))
```

This should be a valid axiom if the semantics match. Let me verify against the axiom list.

Looking at Axioms.lean: The BX axioms include BX4 (connect_future): `φ → G(P(φ))`, BX5 (self_accum_until), etc. But I don't see A3a or A4a listed directly. The codebase may have replaced them with equivalent BX axioms during the formalization.

**Bottom line**: Burgess's Lemma 2.6 proof does NOT need B_sub_A. It uses axioms A3a, A4a, A5a which are valid under open guard. The plan revision should follow Burgess's original proof structure.

## 3. How Burgess Handles the "Nested Until" Case in C4 Elimination

### Burgess's Lemma 2.9 (p. 372-373): Counterexample Elimination for C4

**Statement**: If (f,g) ∈ F and x, y, γ, δ constitute a counterexample to C4a (i.e., ¬U(γ,δ) ∈ f(x), γ ∈ f(y), no z between with ¬δ ∈ f(z)), then there exists an extension where it's no longer a counterexample.

**Proof by induction on n = number of domain points between x and y:**

**Case n = 0**: x, y are adjacent. Apply Lemma 2.6 with A = f(x), B = g(x,y), C = f(y). Get a new point z between x and y with ¬δ ∈ f(z).

**Case n = m + 1**: Let x' be the immediate successor of x in dom f.

- **If ¬U(γ,δ) ∈ f(x')**: reduce to n = m by replacing x with x'.
- **If U(γ,δ) ∈ f(x')**: Note that we must have δ ∈ f(x') (otherwise x, y, γ, δ would not be a counterexample — there would be no z between x and y with ¬δ, but this is vacuously satisfied when there are none... wait).

Actually, re-reading more carefully: "note first that we must have δ ∈ f(x'), else x, y, γ, δ would not be a counterexample." Hmm, this needs unpacking.

Wait — Burgess's C4a says: ¬U(γ,δ) ∈ f(x) and **γ ∈ f(y)**, looking for z with **¬δ ∈ f(z)**.

**CRITICAL OBSERVATION**: In Burgess, the C4 condition checks the **EVENT** (first argument of U) at the far endpoint, and negates the **GUARD** (second argument) at intermediate points. This is because Burgess has U(event, guard).

The codebase's C4 (ChronicleTypes.lean:392-397) has:
```lean
(Formula.untl γ δ).neg ∈ χ.f x →
δ ∈ χ.f y →
∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z
```

With `untl γ δ` where γ = GUARD, δ = EVENT. So: neg(untl(guard, event)) ∈ f(x), EVENT ∈ f(y), find z with neg(GUARD) ∈ f(z). This matches Burgess when we account for the argument swap.

Back to the nested case: Burgess has U(γ,δ) ∈ f(x') (where γ is EVENT, δ is GUARD in his notation). He then says: "note first that we must have δ ∈ f(x')."

Why? Because the counterexample has γ ∈ f(y) (event at y) and no z between x and y with ¬δ ∈ f(z) (no negated guard). Since x' is between x and y, we need ¬δ ∉ f(x'), i.e., δ ∈ f(x').

Then he constructs γ' = δ ∧ U(γ,δ) ∈ f(x') and shows ¬U(γ',δ) ∈ f(x), reducing to the n=0 case by replacing γ with γ' and y with x'.

### How Does This Avoid the "Nested Bridging" Problem?

**Burgess does NOT need a "nested bridging lemma" at all!** His C4 elimination is structured as an induction on the number of intermediate points, NOT as finding the rightmost point with neg-until. The induction step either:
1. Propagates the neg-Until to the successor (reducing n), or
2. When the successor has the Until formula, uses A3a to construct a DIFFERENT neg-Until formula and reduces to n=0.

The codebase's approach (CounterexampleElimination.lean:340-433) uses a completely different strategy: find the **rightmost** w with neg(untl(γ,δ)) ∈ f(w), then look at its successor. This creates the nested case (when the successor has untl(γ,δ) instead of δ). **This strategy is not what Burgess does.**

Burgess's strategy processes from left to right (from x toward y), peeling off one domain point at a time. The codebase's strategy jumps to the rightmost point. The rightmost-point strategy introduces the nested case that Burgess's left-to-right strategy avoids.

### The Fix

**The C4 elimination should be restructured to follow Burgess's induction exactly**: induction on the number of domain points between x and y. The inductive step peels off the immediate successor x' of x and either:
- Reduces n by moving x to x' (if neg-Until propagates), or
- Reduces to n=0 by inserting a point between x and x' (using Lemma 2.6)

This eliminates the need for `burgessR3_gamma_not_in_B_nested` entirely.

## 4. How Burgess Proves the Forward Witness Property (FUC)

### Burgess's Truth Lemma (Claim 2.11, p. 373-374)

Burgess proves (+) x ∈ V(α) iff α ∈ f(x) by induction on formula complexity.

For the case α = U(β,γ) (his notation: β = EVENT, γ = GUARD):

**Forward direction** (α ∈ f(x) → x ∈ V(α)):
- By C5a, ∃y ∈ X with x < y and β ∈ f(y) (EVENT at y) and γ ∈ g(x,y) (GUARD in interval)
- If z ∈ X and x < z < y, then by C3: g(x,y) ⊆ f(z), so γ ∈ f(z)
- By induction: y ∈ V(β) and z ∈ V(γ) for all z between x and y
- Hence x ∈ V(U(β,γ))

**Backward direction** (¬α ∈ f(x) → x ∉ V(α)):
- For any y ∈ X with x < y and y ∈ V(β), by IH β ∈ f(y), so by C4a there's z between x and y with ¬γ ∈ f(z), hence z ∉ V(γ)
- So x ∉ V(α)

### What Does C5a Give?

Burgess's C5a (p. 372): If x ∈ dom f and U(ξ,η) ∈ f(x), there is some y ∈ dom f with x < y and **ξ ∈ f(y)** and **η ∈ g(x,y)**.

In his notation: ξ = EVENT, η = GUARD. So C5a gives: the event at the witness point, and the GUARD IN THE INTERVAL g(x,y).

Then C3 gives: g(x,y) ⊆ f(z) for all z between x and y. So the guard η holds at all intermediate points.

**Burgess does NOT track guards through intermediate stages.** The guard is in g(x,y), and C3 distributes it to all intermediate f(z). This is the whole point of the g-function.

### The Codebase's C5 Definition Matches

ChronicleTypes.lean:418-424:
```lean
def Chronicle.c5 (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom, ∀ (γ δ : Formula),
    Formula.untl γ δ ∈ χ.f x →
    ∃ y ∈ χ.dom, x < y ∧ δ ∈ χ.f y ∧
      ∀ z ∈ χ.dom, x < z → z < y →
        γ ∈ χ.f z ∧ Formula.untl γ δ ∈ χ.f z
```

This has γ = GUARD, δ = EVENT. So: event at y, guard (and persisted Until) at all z between. The `Formula.untl γ δ ∈ χ.f z` part is an ADDITIONAL requirement beyond Burgess.

### The FUC Problem Reframed

The sorry sites at ChronicleToCountermodel.lean:615,619 are about proving the forward direction of the truth lemma: that `untl(γ,δ) ∈ f(x)` implies x ∈ V(U(γ,δ)).

In Burgess's proof, this follows DIRECTLY from:
1. C5 gives y with δ ∈ f(y) and γ ∈ g(x,y)
2. C3 gives g(x,y) ⊆ f(z) for intermediate z
3. Done — γ ∈ f(z) for all z between x and y

**The codebase may be overcomplicating this.** If the limit chronicle satisfies C5 (including guards in g) and C3, the truth lemma follows as Burgess describes, without needing `rRelation_guard_continues'`.

The question is whether the omega-chain construction actually produces a limit that satisfies the FULL C5 (with guards in g), or only a weak version (just the witness without guards). If it's only the weak version (`limit_satisfies_c5_weak`), then the guards must be recovered separately — which is the FUC problem.

**Key insight**: The C5 counterexample elimination (Lemma 2.10) in Burgess's proof explicitly places η (the guard) in g(x,y). See p. 373: "in such a way that ξ ∈ f'(y), η ∈ g'(x,y)." The Case n=0 applies Lemma 2.4 which produces B with η ∈ B, and sets g'(x,y) = B.

So in Burgess's construction, every C5 elimination step puts the guard in the interval set. The full C5 (with guards) holds AT EVERY FINITE STAGE. The limit inherits it. The FUC sorry sites shouldn't exist if the construction follows Burgess faithfully.

**The codebase's `eliminate_C5_counterexample`** (line 167-204) does NOT put the guard in g(x,y). It uses `lemma_2_4` to get an MCS C with η ∈ C, but then sets `g' = χ.g` (unchanged!). The new g-values for the interval (x, y) are left as placeholders (`χ.g` which is the OLD g, not defined for the new pair). The comment says "full interval assignment in ChronicleConstruction."

This is why there's a sorry at line 786: `c2' := sorry -- Phase 3: direct g-construction for new adjacent pair`. The g-value construction for new pairs is deferred, and this is exactly where the guards should go.

## 5. Burgess's Exact Definition of "Chronicle"

### Burgess's Conditions (p. 372)

| Condition | Burgess Definition | Codebase Equivalent |
|-----------|-------------------|---------------------|
| **C0** | f maps dom f → MCSs | `Chronicle.c0` ✓ |
| **C0'** | dom f is finite | Implicit (Finset Rat) ✓ |
| **C1** | g maps {(x,y) : x,y ∈ dom f, x < y} → DCSs | `Chronicle.c1` ✓ |
| **C2** | ∀ x < y in dom f, r(f(x), g(x,y), f(y)) | `Chronicle.c2` — but uses `r3Relation` not `burgessR3` |
| **C2'** | ∀ adjacent x,y: R(f(x), g(x,y), f(y)) (R-maximal) | `Chronicle.c2'` — uses `burgessR3` but NOT maximality (R) |
| **C3** | g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) for x < y < z | `Chronicle.c3` ✓ (three-way) |
| **C4a** | ¬U(γ,δ) ∈ f(x), γ ∈ f(y) → ∃z between with ¬δ ∈ f(z) | `Chronicle.c4` ✓ (accounting for arg swap) |
| **C5a** | U(ξ,η) ∈ f(x) → ∃y > x: ξ ∈ f(y) ∧ η ∈ g(x,y) | `Chronicle.c5` — STRONGER (also requires guard at all intermediate f(z)) |

### Key Discrepancies

1. **C2 uses wrong r-relation**: Codebase uses `r3Relation` (which combines `rRelation` + `rRelationSince`), not `burgessR3` (which combines `burgessRSet` + `burgessRSetSince`). These are DIFFERENT concepts (see §1).

2. **C2' lacks maximality**: Burgess requires **R**(f(x), g(x,y), f(y)) — i.e., g(x,y) is MAXIMAL with respect to r. The codebase's `c2'` only requires DCS + `burgessR3`, NOT maximality (BurgessR3Maximal). This is significant because Lemma 2.6 uses the maximality to find δ ∉ B (the formula to negate).

3. **C5 is stronger than Burgess**: Codebase C5 requires γ ∈ f(z) AND untl(γ,δ) ∈ f(z) at ALL intermediate z. Burgess's C5 only requires η ∈ g(x,y). The guard-at-intermediate-points follows from C3, so the codebase's C5 is a derived property, not a primitive condition.

### Impact of Discrepancy #2 (No Maximality in c2')

Burgess's Lemma 2.6 explicitly uses R(A, B, C) — the maximality of B. The proof begins "Suppose we have R(A,B,C) and δ ∉ B." The maximality is used to find β₀, γ₀ with ¬U(γ₀, β₀ ∧ δ) ∈ A (this follows from the definition of R-maximality: if δ ∉ B then there exist elements violating r for extensions of B by δ).

If the codebase's c2' only requires `burgessR3` without maximality, then Lemma 2.6's proof strategy cannot be applied directly. The plan must either:
- Upgrade c2' to include maximality (use `BurgessR3Maximal`), or
- Find an alternative proof of the seed set consistency that doesn't use maximality

The existing `burgessR3Maximal_exists_from_seed` (RRelation.lean:1131) produces maximal DCSs, so upgrading c2' to require maximality is feasible.

## 6. Does Burgess Use Density at Finite Stages?

**No.** Burgess's chronicle conditions C0-C5 apply to finite chronicles (C0' requires finite domain). The point insertion lemmas (2.6, 2.9, 2.10) operate on finite chronicles and produce finite extensions. Density appears only at the limit.

The omega-chain construction (described briefly on p. 373): start with a single point, repeatedly eliminate C4/C5 counterexamples. "We now let X be the union of the sets dom f_n... Then (f,g) satisfies C0-C5." Density of Q provides that every pair of rationals has a rational between them, which is used when inserting z = (x + y)/2 or z = x + 1.

## Summary: What the Codebase Gets Wrong

### 1. The C4 Elimination Strategy Is Wrong
The codebase uses "find rightmost w with neg-until, check successor" which creates the nested case. Burgess uses "induction on intermediate point count, peel from left" which avoids it entirely.

**Fix**: Restructure C4 elimination to follow Burgess's induction. This eliminates the need for `burgessR3_gamma_not_in_B_nested`.

### 2. C2' Lacks Maximality
Burgess requires R-maximality (R(A,B,C)) for adjacent pairs. The codebase only requires DCS + burgessR3. This blocks the Lemma 2.6 consistency argument.

**Fix**: Upgrade c2' to require `BurgessR3Maximal`. The infrastructure already exists (`burgessR3Maximal_exists_from_seed`).

### 3. C5 Elimination Doesn't Assign g-Values
Burgess's Lemma 2.10 explicitly assigns g'(x,y) = B where η ∈ B (guard in interval). The codebase defers g-value assignment, creating the c2' sorry sites.

**Fix**: Make `eliminate_C5_counterexample` assign g-values using Lemma 2.4's output, following Burgess exactly.

### 4. The FUC Problem Doesn't Exist in Burgess's Framework
Burgess's truth lemma follows directly from C5 (η ∈ g(x,y)) + C3 (g(x,y) ⊆ f(z)). No `rRelation_guard_continues'` needed. The problem arises only because the codebase's C5 elimination defers g-value assignment.

**Fix**: Once #3 is fixed, the truth lemma proof follows Burgess directly.

### 5. The Two r-Relations Are Conflated
`rRelation` (obligation propagation) and `burgessR3` (content-based) are different concepts. The plan/reports sometimes conflate them. Burgess uses only the content-based one.

**Fix**: The revised plan should use only `burgessR3`/`BurgessR3Maximal` terminology, matching Burgess's paper.

### 6. A3a/A4a Validity Needs Verification
The codebase claims A3a/A4a are invalid under strict semantics, but Burgess proves them sound under open guard semantics (which IS strict). Either the codebase is wrong, or there's a semantic difference in the bimodal setting. This needs verification — if A3a/A4a are actually valid, Burgess's proofs can be used directly.

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Burgess r-relation ≠ codebase rRelation | **HIGH** — direct comparison of definitions |
| No B_sub_A needed in Burgess | **HIGH** — traced through Lemma 2.6 proof, B enters D₀ directly |
| C4 nested case avoidable via Burgess's strategy | **HIGH** — Burgess's induction explicitly avoids it |
| FUC follows from proper C5+C3 | **HIGH** — Burgess's truth lemma is explicit |
| C2' needs maximality | **HIGH** — Lemma 2.6 proof uses R-maximality |
| A3a/A4a validity under bimodal semantics | **MEDIUM** — valid in pure tense logic per Burgess, unclear in TM |

**Overall**: The main finding is that the codebase deviates from Burgess's construction in several ways that INTRODUCE problems that don't exist in the original proof. A faithful implementation of Burgess's construction would avoid the nested bridging problem, the FUC problem, and the B_sub_A gap entirely.
