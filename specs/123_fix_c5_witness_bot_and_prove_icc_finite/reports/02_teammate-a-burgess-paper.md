# Teammate A: Deep Study of Burgess 1982 — The Discrete Case

**Task**: Understand how Burgess's construction relates to the discrete case and what the "routine exercise" means.
**Date**: 2026-05-11

## Key Finding: Burgess's Construction Works Correctly — The Problem Is the ProofChecker's Goal

Burgess's construction DOES produce infinite bounded intervals when the discrete axiom G'⊥ = U(⊤,⊥) is present. This is NOT a bug — it's by design. The "routine exercise" does NOT mean fixing the construction. It means observing that the resulting model already satisfies the discrete axiom.

## 1. Burgess's Complete Construction (Section 2)

### Conditions C0–C5

A chronicle (f, g) ∈ F satisfies:

- **C0**: f maps a finite subset of ℚ to MCSs
- **C0'**: dom f is finite
- **C1**: g maps pairs (x,y) with x < y in dom f to DCSs (deductively closed sets)
- **C2**: r(f(x), g(x,y), f(y)) holds for all x < y (the "r-relation" from Lemma 2.3)
- **C2'**: R(f(x), g(x,y), f(y)) holds for ADJACENT x,y (MAXIMAL r-relation)
- **C3**: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) for x < y < z (decomposition)
- **C4a/b**: Counterexample elimination for ¬U and ¬S
- **C5a/b**: Until/Since witness existence

### The Omega Chain

Start with (f₀, g₀) where dom f₀ = {0}, f₀(0) = A₀ (MCS containing consistent formula α₀). Repeatedly apply Lemmas 2.9 and 2.10 to eliminate counterexamples. Take the limit X = ⋃ dom fₙ, f = ⋃ fₙ, g = ⋃ gₙ. The limit satisfies C0–C5.

### The Completeness Proof (Claim 2.11)

Define V(α) in (X, <) by: x ∈ V(α) iff α ∈ f(x). This satisfies (+) for all formulas, proved by induction:
- For U(β, γ): if U(β,γ) ∈ f(x), C5a gives witness y with γ ∈ f(y) and β ∈ g(x,y). For any z between x and y, C3 gives β ∈ f(z). By induction, V is correct.

## 2. Lemma 2.7 — The Splitting Lemma

**Statement**: Given R(A, B, C) and U(ξ, η) ∈ A and η ∉ B, produces B', D, B'' such that:
- R(A, B', D) and R(D, B'', C) and B = B' ∩ D ∩ B''
- η ∈ B' (the guard formula enters the LEFT split)
- ξ ∈ D (the event formula enters the NEW point)
- B ⊆ B', B ⊆ D, B ⊆ B''

**Key fact about B''**: B'' is constructed by taking B (the original g-value) and finding a MAXIMAL extension satisfying r(D, -, C). Since B ⊆ B'', B'' contains everything in B. But η may or may not be in B''. When η = ⊥: B'' is a maximal consistent set satisfying the r-relation, so ⊥ ∉ B'' (consistent sets never contain ⊥).

**Note on Burgess's notation**: His U(ξ, η) has ξ = event, η = guard. The ProofChecker swaps: U(η, ξ) with η = event, ξ = guard. In what follows I use Burgess's convention.

## 3. Lemma 2.10 — The C5 Walk

**Condition (i)**: `η ∧ U(ξ, η) ∈ f(x')` AND `η ∈ g(x, x')`.

For U(⊤, ⊥) (ξ = ⊤, η = ⊥):
- First conjunct: ⊥ ∧ U(⊤, ⊥) = ⊥ ∈ f(x') — **IMPOSSIBLE** (f(x') is MCS)
- So condition (i) **ALWAYS fails**

**Condition (ii)**: `ξ ∈ f(x')` AND `η ∈ g(x, x')`.
- First conjunct: ⊤ ∈ f(x') — always true
- Second conjunct: ⊥ ∈ g(x, x') — fails (g is consistent)
- So condition (ii) also fails

When both fail: apply Lemma 2.7 (or 2.8). Insert midpoint z = (x + x')/2. Set g'(x, z) = B' with η = ⊥ ∈ B' (but actually, η ∈ B' means ⊥ ∈ B'... wait, B' is the LEFT split where η enters. For the C5 walk, B' gets the guard η. So ⊥ ∈ B'? Only if B' is inconsistent.)

Let me recheck. In Lemma 2.7, η ∈ B' — here η is the guard formula, which is ⊥ for U(⊤, ⊥). So ⊥ ∈ B'. Since ⊥ is in B', B' is inconsistent (B' = Set.univ via deductive closure). This is fine — B' is a DCS (deductively closed set), not required to be consistent. And R(A, B', D) can hold even when B' is inconsistent.

Wait — can R(A, B', D) hold when B' is inconsistent? R(A, B, C) means B is MAXIMAL with r(A, -, C). r(A, β, C) means ∀γ ∈ C, U(γ, β) ∈ A. When B' = Set.univ, r(A, B', D) requires ∀β ∈ Set.univ, ∀γ ∈ D, U(γ, β) ∈ A. This requires U(γ, β) ∈ A for ALL β, which is very strong. Does Lemma 2.7 actually claim R(A, B', D) when η = ⊥?

Looking at 2.7 more carefully: it says "there exist B', D, B'' such that η ∈ B', ξ ∈ D, R(A, B', D), R(D, B'', C), B = B' ∩ D ∩ B''."

But this CAN'T hold when η = ⊥ and B' is inconsistent, because R(A, B', D) requires r(A, β, D) for all β ∈ B' = Set.univ, which requires U(γ, β) ∈ A for all β, γ. Taking β = ⊥: U(γ, ⊥) ∈ A for all γ ∈ D. U(γ, ⊥) is F(γ). So F(γ) ∈ A for all γ ∈ D. This requires EVERY formula in D to be "eventually true" from A's perspective. Since D is an MCS, it contains either γ or ¬γ for each formula. So F(γ) ∈ A for every γ ∈ D. In particular, F(⊥) ∈ A, i.e., U(⊥, ⊤) ∈ A... wait, F(⊥) = U(⊥, ⊤). Since ⊥ is inconsistent, U(⊥, ⊤) should be inconsistent too (by Consistency Criterion 2.2). So F(⊥) ∉ A. Contradiction.

**THIS MEANS LEMMA 2.7 DOES NOT APPLY WHEN η = ⊥.** The proof of 2.7 constructs D₀ = {...} ∪ {ξ}, and proves its consistency. But when η = ⊥, the construction of D₀ includes {S(α, ⊥ ∧ η')} terms... let me look more carefully.

Actually, re-reading Lemma 2.7's proof: it needs to prove the consistency of ζ = S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β) for α ∈ A, β ∈ B, γ ∈ C. When η = ⊥, ζ = S(α, β ∧ ⊥) ∧ β ∧ ξ ∧ U(γ, β) = S(α, ⊥) ∧ β ∧ ξ ∧ U(γ, β). S(α, ⊥) = P(α). So ζ = P(α) ∧ β ∧ ξ ∧ U(γ, β).

Is this always consistent? ξ = ⊤ in our case, so ζ = P(α) ∧ β ∧ U(γ, β). This IS consistent (assuming A, B, C are reasonable). So the CONSISTENCY proof works.

But then what about R(A, B', D)? The proof says "let B' be maximal with respect to B ⊆ B' and r(A, B', D)." If B ⊆ B' and η ∈ B' and η = ⊥, then ⊥ ∈ B', so B' = Set.univ (deductive closure). But can r(A, Set.univ, D) hold?

r(A, Set.univ, D) means: for all β ∈ Set.univ, for all δ ∈ D, U(δ, β) ∈ A. This requires U(δ, β) ∈ A for ALL β, ALL δ ∈ D. As shown above, taking β = ⊥ gives F(δ) ∈ A for all δ ∈ D, which is impossible (F(⊥) ∉ A by 2.2).

So r(A, Set.univ, D) CANNOT hold. But the proof says B' is maximal with r(A, B', D). If we try to include ⊥ in B', we need r(A, B' ∪ {⊥}, D), which requires U(δ, ⊥) = F(δ) ∈ A for all δ ∈ D. This fails.

**SO THE PROOF OF 2.7 DOESN'T CLAIM ⊥ ∈ B'!** Let me re-read.

"Then there exist B', D, B'' such that η ∈ B', ξ ∈ D, and R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B''."

Wait — it DOES claim η ∈ B'. When η = ⊥, it claims ⊥ ∈ B'. But as I just showed, this would make B' = Set.univ and r(A, Set.univ, D) would fail.

Is the lemma statement wrong for η = ⊥? Or does the proof avoid this case?

Actually, let me re-read the lemma's HYPOTHESES: "Suppose we have R(A, B, C) and U(ξ, η) ∈ A and **η ∉ B**."

The hypothesis is η ∉ B. When η = ⊥ and B is a DCS (deductively closed set): is ⊥ ∈ B? A DCS could be inconsistent (B = Set.univ), in which case ⊥ ∈ B. But the proof of 2.6 and 2.7 builds B from R(A, B, C), and R requires r(A, B, C) which requires B to be "maximal with r(A, -, C)." If B contained ⊥, then r(A, B, C) would require F(δ) ∈ A for all δ... which fails.

Wait, actually, R(A, B, C) requires r(A, B, C), which is r(A, β, C) for all β ∈ B. This means for all β ∈ B, for all γ ∈ C, U(γ, β) ∈ A. If ⊥ ∈ B, then for all γ ∈ C, U(γ, ⊥) = F(γ) ∈ A. By 2.2, since F(⊥) is inconsistent, ⊥ ∉ C. But C is MCS, so ⊥ ∉ C is fine. We need F(γ) ∈ A for all γ ∈ C. Since C is MCS, γ ranges over half of all formulas. F(γ) ∈ A for many γ is plausible... but F(⊥) ∈ A? F(⊥) = U(⊥, ⊤). By 2.2, U(⊥, ⊤) ∈ A requires ⊥ to be consistent, which it isn't. So F(⊥) ∉ A.

But ⊥ ∉ C (C is MCS), so we don't need F(⊥) ∈ A. We only need F(γ) ∈ A for γ ∈ C, and ⊥ ∉ C. Hmm, but there are OTHER inconsistent formulas in C... wait, C is an MCS, so every formula in C is consistent (otherwise C itself would be inconsistent, contradicting MCS). So all γ ∈ C are consistent, and U(γ, ⊥) = F(γ) ∈ A is PLAUSIBLE for consistent γ.

Actually wait — does A necessarily contain F(γ) for all consistent γ? Not necessarily. A is an MCS and may not contain F(γ) for a particular consistent γ. For example, if G(¬γ) ∈ A, then F(γ) ∉ A.

So r(A, B, C) with ⊥ ∈ B is VERY restrictive. It requires F(γ) ∈ A for all γ ∈ C. This is a strong condition that may or may not hold depending on A and C.

**The key realization**: In Burgess's construction, the g-values produced at each stage satisfy R(f(x), g(x,y), f(y)). If U(⊤, ⊥) ∈ f(x) and ⊥ ∉ g(x, y), then Lemma 2.7 applies to produce B', D, B'' with ⊥ ∈ B'. But as shown, having ⊥ ∈ B' AND R(A, B', D) requires F(δ) ∈ A for all δ ∈ D.

Does the proof of 2.7 actually guarantee this? The proof constructs D first (from the seed D₀ = {S(α, β ∧ η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}). Then B' is defined as maximal with B ⊆ B' and r(A, B', D). The proof DOES NOT claim B' contains anything beyond B — except it says B = B' ∩ D ∩ B''. If η ∉ B, we need η ∈ B' (the claim). But the proof doesn't separately show η ∈ B'; it follows from the maximality and the structure.

Hmm, actually looking at the proof again more carefully: Burgess says the problem "reduces to proving the consistency of" certain formulas. The consistency argument constructs D₀ and shows it's consistent, then extends to D as an MCS. Then B' is maximal with B ⊆ B' and r(A, B', D). The claim η ∈ B' follows from... what exactly?

Looking at Lemma 2.7's proof: "Let D₀ = {S(α, β ∧ η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}." This is the seed for D. Then D extends D₀. Then B' is maximal with r(A, B', D) and B ⊆ B'.

But where does η ∈ B' come from? The proof says "B = B' ∩ D ∩ B''" via Lemma 2.5. Since η ∉ B, at least one of η ∉ B', η ∉ D, η ∉ B'' must hold. But the claim says η ∈ B'... so maybe the claim is wrong? Let me re-read.

"Then there exist B', D, B'' such that η ∈ B', ξ ∈ D, and R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B''."

Hmm, maybe I'm confusing Burgess's 2.7 with 2.6. Let me re-read 2.6:

Lemma 2.6: R(A, B, C) and δ ∉ B → B', D, B'' with ¬δ ∈ D and R(A, B', D), R(D, B'', C), B = B' ∩ D ∩ B''.

Lemma 2.7: R(A, B, C) and U(ξ, η) ∈ A and η ∉ B → B', D, B'' with **η ∈ B'**, ξ ∈ D, and R(A, B', D), R(D, B'', C), B = B' ∩ D ∩ B''.

So 2.7 DOES claim η ∈ B'. For η = ⊥, this means ⊥ ∈ B'. And R(A, B', D) must hold.

But as I showed, r(A, B', D) with ⊥ ∈ B' requires U(δ, ⊥) = F(δ) ∈ A for all δ ∈ D. Is this actually provable?

Wait — r(A, β, C) is defined in 2.3 as: ∀γ ∈ C, U(γ, β) ∈ A. So r(A, ⊥, D) means ∀δ ∈ D, U(δ, ⊥) ∈ A, i.e., F(δ) ∈ A for all δ ∈ D.

But U(⊤, ⊥) ∈ A is just F(⊤) ∈ A, which is equivalent to ¬G(⊥) ∈ A, equivalent to saying A is not the "empty future" MCS. This is true as long as A is consistent and doesn't have G(⊥).

But we need F(δ) ∈ A for ALL δ ∈ D. Since D is an MCS, it contains ⊤, so we need at least F(⊤) ∈ A, which is U(⊤, ⊥) ∈ A — our hypothesis! But we also need F(δ) for other δ ∈ D.

Hmm, does A necessarily contain F(δ) for all δ ∈ D? In the discrete case, U(⊤, ⊥) ∈ A means "there's an immediate successor." The formula U(⊤, ⊥) says: there exists a future point where ⊤ holds (trivially) with ⊥ holding throughout the gap (vacuously = no gap). So F(⊤) ∈ A. But F(δ) for arbitrary δ?

F(δ) = U(δ, ⊤). This says: there's a future time where δ holds with ⊤ throughout the gap (trivially true). So F(δ) ∈ A iff A believes δ will eventually be true. This is NOT guaranteed for all δ.

So r(A, ⊥, D) does NOT hold in general when D is an MCS with both δ and ¬δ' formulas where A doesn't believe F(δ) for some δ ∈ D.

**CONCLUSION: The hypothesis η ∉ B in Lemma 2.7 prevents η = ⊥ in practice, because ⊥ is always in every DCS (deductively closed sets contain ⊥).**

Wait — is ⊥ always in every DCS? A DCS is a deductively closed set. ⊥ is a consequence of any inconsistent set. If the DCS is CONSISTENT, then ⊥ is NOT a consequence, so ⊥ ∉ DCS. If the DCS is inconsistent, ⊥ ∈ DCS.

So for consistent DCS B: ⊥ ∉ B. The hypothesis "η ∉ B" with η = ⊥ is automatically satisfied when B is a consistent DCS. So Lemma 2.7 DOES apply with η = ⊥!

But then we need the conclusion to be consistent: η ∈ B' means ⊥ ∈ B', meaning B' is inconsistent, meaning R(A, B', D) with B' inconsistent. As I showed, this requires F(δ) ∈ A for all δ ∈ D.

Is the proof of 2.7 valid with η = ⊥? Let me trace through more carefully.

The proof reduces to showing consistency of ζ = S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β). With η = ⊥, ξ = ⊤:
ζ = S(α, β ∧ ⊥) ∧ β ∧ ⊤ ∧ U(γ, β) = S(α, ⊥) ∧ β ∧ U(γ, β) = P(α) ∧ β ∧ U(γ, β).

This IS consistent (for appropriate α, β, γ). So D₀ is consistent and D extends it to an MCS.

Then B' is maximal with B ⊆ B' and r(A, B', D). The claim is η ∈ B'. But does the proof actually PROVE η ∈ B'?

Looking at the proof structure: "the problem reduces to proving consistency" of certain seeds. Then "let B' be maximal..." The claim B = B' ∩ D ∩ B'' follows from Lemma 2.5. Since η ∉ B and B = B' ∩ D ∩ B'', and η ∈ B' (claimed), we need η ∉ D or η ∉ B''. 

For η = ⊥: ⊥ ∉ D (D is MCS, hence consistent). So B = B' ∩ D ∩ B'' with ⊥ ∉ D means ⊥ ∉ (B' ∩ D ∩ B'') regardless of whether ⊥ ∈ B'. So the equation B = B' ∩ D ∩ B'' is consistent with ⊥ ∈ B' and ⊥ ∉ D.

But the REAL question is: does the proof actually establish ⊥ ∈ B'? 

Looking at Lemma 2.7's structure: D₀ includes {S(α, β ∧ η) : α ∈ A, β ∈ B}. With η = ⊥, this is {S(α, ⊥) : α ∈ A} = {P(α) : α ∈ A}. D extends D₀, so P(α) ∈ D for all α ∈ A.

Now, B' is defined as maximal with B ⊆ B' and r(A, B', D). We need to check: can B' contain ⊥?

r(A, ⊥, D) means ∀δ ∈ D, U(δ, ⊥) ∈ A, i.e., F(δ) ∈ A for all δ ∈ D.

Is this true? We know U(⊤, ⊥) = F(⊤) ∈ A. What about F(δ) for other δ ∈ D?

We know D ⊇ D₀ which contains B ∪ {⊤} ∪ {U(γ, β) : γ ∈ C, β ∈ B} ∪ {P(α) : α ∈ A}. For δ ∈ B: is F(δ) ∈ A? Since r(A, B, C) holds, ∀γ ∈ C, U(γ, δ) ∈ A. In particular, U(⊤, δ) ∈ A, which means... hmm, U(⊤, δ) is NOT F(δ). F(δ) = U(δ, ⊤). These are different formulas!

Actually wait. In Burgess's notation: F(α) = U(α, ⊤). And U(⊤, ⊥) = G'(⊥). Let me double check. From section 1.1:
- F(α) = U(α, ⊤)
- G'(α) = U(⊤, α)

So U(⊤, ⊥) = G'(⊥), and F(δ) = U(δ, ⊤).

r(A, β, D) means ∀δ ∈ D, U(δ, β) ∈ A. So r(A, ⊥, D) means ∀δ ∈ D, U(δ, ⊥) = G'(⊥) ∈ A when δ = ⊤... actually U(δ, ⊥) is not a fixed formula. It's U(δ, ⊥) for each δ.

U(δ, ⊥) semantically means: there exists a future point where δ holds, and ⊥ holds throughout the gap. Since ⊥ never holds, U(δ, ⊥) means: there exists a future point where δ holds AND no points between (the gap is empty). In a discrete order, this means the IMMEDIATE SUCCESSOR satisfies δ.

So r(A, ⊥, D) means: for all δ ∈ D, A believes δ holds at the immediate successor. Since D is an MCS, this means A believes the immediate successor's state is exactly described by D. This is a STRONG but MEANINGFUL condition — it says D is the MCS of A's immediate successor.

Is this condition achievable? In the discrete case, yes! If U(⊤, ⊥) ∈ A (the discrete axiom), then A believes in an immediate successor. The MCS of that successor should be some D with r(A, ⊥, D).

**SO r(A, ⊥, D) CAN hold when the discrete axiom is present!** The key is that U(δ, ⊥) ∈ A for all δ ∈ D means "the immediate successor satisfies every formula in D." Since D is an MCS describing the successor's state, this is exactly what we'd expect in a discrete model.

**THEREFORE**: Lemma 2.7 with η = ⊥ DOES produce ⊥ ∈ B', and R(A, B', D) holds. The B' is inconsistent (Set.univ), but that's fine — it represents the "gap" between x and the midpoint z, which in the discrete case should be empty (containing everything vacuously, including ⊥).

## 3. The ProofChecker's Deviation

Looking at the ProofChecker's code, condition (i) checks `ξ ∧ U(η, ξ) ∈ f(x')` AND `ξ ∈ g(pt, x')`. In Burgess's notation (with the swap), this is `η ∧ U(ξ, η) ∈ f(x')` AND `η ∈ g(x, x')`. This matches Burgess exactly.

The ProofChecker's `BurgessR3Maximal` corresponds to Burgess's R(A, B, C). The ProofChecker's `r` corresponds to Burgess's r(A, β, C).

**The deviation is in the definition of BurgessR3Maximal vs R(A, B, C):**

In the ProofChecker, `BurgessR3Maximal(A, B, C)` is defined in ChronicleTypes.lean. Let me check if it allows inconsistent B (= Set.univ).

From the earlier research: `BurgessR3Maximal A B C` requires `burgessR3 A B C`, which involves `∀ β ∈ B, ∀ γ ∈ C, untl(γ, β) ∈ A`. When B = Set.univ, this requires `untl(γ, β) ∈ A` for ALL β, which includes `untl(γ, ⊥)`. 

In Burgess's notation, `untl(γ, ⊥) = U(γ, ⊥)`. This means F(γ) must be in A for all γ ∈ C... wait, U(γ, ⊥) is NOT F(γ). F(γ) = U(γ, ⊤). U(γ, ⊥) means "γ eventually with ⊥ throughout the gap" = "γ at the immediate next point."

Hmm, the ProofChecker might have a different convention. Let me check. In the ProofChecker, `Formula.untl η ξ` is `U(η, ξ)`. And the `burgessR3` condition involves `untl(γ, β)` which is `U(γ, β)`. So `burgessR3 A B C` requires `∀ β ∈ B, ∀ γ ∈ C, U(γ, β) ∈ A`. This matches Burgess's r(A, B, C) = r(A, β, C) for all β ∈ B = ∀β ∈ B, ∀γ ∈ C, U(γ, β) ∈ A.

So for B = Set.univ: we need U(γ, β) ∈ A for all β, γ ∈ C. Taking β = ⊥: U(γ, ⊥) ∈ A for all γ ∈ C.

As I analyzed above, U(γ, ⊥) means "γ at the immediate next point." When A has U(⊤, ⊥) (discrete axiom), does U(γ, ⊥) ∈ A for all γ ∈ C?

No, not necessarily. U(γ, ⊥) ∈ A means A asserts γ will hold at the immediate next point. A might believe ¬γ at the next point. So U(γ, ⊥) ∉ A in general.

**WAIT**. This means r(A, ⊥, D) requires U(δ, ⊥) ∈ A for all δ ∈ D, which means A asserts every formula in D holds at the immediate next point. But D was constructed from A in the proof of 2.7 — maybe by construction, D IS exactly what A says the next point looks like?

Looking at D₀ in the proof of 2.7: D₀ = {S(α, β ∧ η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}. With η = ⊥, ξ = ⊤: D₀ = {P(α) : α ∈ A} ∪ B ∪ {⊤} ∪ {U(γ, β) : γ ∈ C, β ∈ B}.

D extends D₀ to an MCS. Is U(δ, ⊥) ∈ A for all δ ∈ D? Not obviously. The proof of 2.7 doesn't directly show this. It shows the CONSISTENCY of D₀, then EXTENDS to D, then defines B' as maximal with r(A, B', D).

Does B' actually contain ⊥? Let me look at the proof structure once more. The proof says η ∈ B'. But HOW is this proved? The proof structure is:

1. Show D₀ is consistent
2. Let D be MCS extending D₀
3. Let B' be maximal with B ⊆ B' and r(A, B', D)
4. Let B'' be maximal with B ⊆ B'' and r(D, B'', C)
5. B = B' ∩ D ∩ B'' by Lemma 2.5

But step 3 defines B' by maximality. The CLAIM is η ∈ B'. This would need to be PROVED from the maximality construction. Specifically, we'd need r(A, B ∪ {η}, D) to hold, so that η can be added to B in the maximization.

r(A, η, D) means ∀δ ∈ D, U(δ, η) ∈ A. With η = ⊥: ∀δ ∈ D, U(δ, ⊥) ∈ A.

**The proof of 2.7 should establish this!** Let me look at how. The proof says ζ = S(α, β ∧ η) ∧ β ∧ ξ ∧ U(γ, β) is consistent. With η = ⊥: ζ = P(α) ∧ β ∧ U(γ, β). This gives S(α, ⊥) = P(α) ∈ D. From Lemma 2.3, P(α) ∈ D for all α ∈ A implies ∀α ∈ A, S(α, ⊥) ∈ D, which by the 2.3 equivalence means ∀δ ∈ D, U(δ, ⊥) ∈ A.

**YES!** This is exactly what we need. The construction of D₀ with {P(α) : α ∈ A} = {S(α, ⊥) : α ∈ A} ⊆ D gives us, by Lemma 2.3 equivalence (2.3(b) → 2.3(a)), that r(A, ⊥, D) holds. So ⊥ CAN be added to B' in the maximization, and η = ⊥ ∈ B'.

**CONCLUSION**: Burgess's Lemma 2.7 DOES work with η = ⊥. The proof is valid. The resulting B' contains ⊥ (is inconsistent / = Set.univ), and R(A, B', D) holds because r(A, ⊥, D) is guaranteed by the construction of D from {S(α, ⊥) : α ∈ A} = {P(α) : α ∈ A}.

## 4. What the "Routine Exercise" Actually Means

Burgess's Section 1.6:

> "For the reader familiar with ordinary G,H-tense logic, the adaptation of our work below to prove these variants is a routine exercise."

This means: **Add the discreteness axiom G'⊥ ∧ H'⊥ to the system. Run the same construction. The limit model automatically satisfies the discreteness axiom because every MCS in the limit contains G'⊥ (from the axiom), and C5 ensures each point has an immediate successor (with an empty gap, since g contains ⊥).**

The infinite midpoint chains are FINE for Burgess's purpose. He only needs a LINEAR model where the formula is satisfiable. The model IS discrete (every point has an immediate successor), even though it has infinite bounded intervals. Burgess doesn't need ℤ-isomorphism — he just needs SOME discrete linear order.

## 5. Does Burgess's Construction Produce Infinite Bounded Intervals?

**YES.** As analyzed above, the C5 walk for U(⊤, ⊥) always inserts midpoints (condition (i) always fails). Each insertion closes the LEFT gap (⊥ ∈ B') but leaves the RIGHT gap open (⊥ ∉ B''). The right gap gets another midpoint at the next processing, creating an infinite chain.

**Burgess doesn't care about this.** His model is a COUNTABLE DISCRETE LINEAR ORDER, not necessarily isomorphic to ℤ. For his completeness theorem (sound and complete for the CLASS OF ALL discrete linear orders), this is fine.

## 6. What the ProofChecker Needs (Beyond Burgess)

The ProofChecker's `bx_completeness` proves `valid φ → Nonempty (DerivationTree [] φ)` where `valid` quantifies over ALL frames with `AddCommGroup D`. The non-dense countermodel must provide:

```lean
∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F) ...
```

This requires D to have `AddCommGroup` structure. The intended D is ℤ (= Int). To get from the limit domain (countable discrete linear order) to ℤ, the ProofChecker uses:

```
limitDomSubtype_Icc_finite → IsSuccArchimedean → orderIsoIntOfLinearSuccPredArch → ℤ
```

But `limitDomSubtype_Icc_finite` is FALSE because the limit domain has infinite bounded intervals. And `IsSuccArchimedean` is also FALSE (succ chains converge but don't reach their target).

**The gap is NOT in Burgess's construction — it's in the ProofChecker's need for ℤ-isomorphism.**

## 7. The Correct Adaptation for the ProofChecker

**Option A: Use Burgess's model directly.** The limit domain IS a discrete linear order. Don't try to iso to ℤ. Instead, show that the limit domain itself (LimitDomSubtype) can serve as D with appropriate AddCommGroup structure. But LimitDomSubtype ⊂ ℚ is not closed under addition, so AddCommGroup fails.

**Option B: Quotient/collapse.** Define an equivalence on limit_dom that collapses each ω-chain to a point. The quotient should be isomorphic to ℤ (each original adjacent pair becomes a single "macro-step"). Transport the FMCS through the quotient.

**Option C: Modify the construction to avoid infinite chains.** When processing C5 for U(η, ⊥), instead of always splitting (which creates the infinite chain), recognize that the dom-successor c is already a valid witness in the LIMIT (even if not at the current finite stage). This requires changing how the C5 check works — but it means changing sorry-free code.

**Option D: Two-pass approach.** First pass: build the omega chain normally (infinite chains and all). Second pass: define the countermodel on the QUOTIENT of the limit domain, collapsing the ω-chains. The quotient has finite bounded intervals and is isomorphic to ℤ.

**Option E: Weaken the validity quantifier.** Change `valid` to not require `AddCommGroup D`, or use a different semantic framework that works with arbitrary discrete linear orders (not just ℤ). This is a major architectural change.

**Recommended: Option B or D** — they don't modify the sorry-free construction and directly address the gap between Burgess's discrete model and the ProofChecker's ℤ requirement.
