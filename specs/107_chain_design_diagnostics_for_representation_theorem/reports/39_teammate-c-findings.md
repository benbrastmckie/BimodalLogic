# Teammate C (Critic) Findings: Burgess Paper vs. Lean Implementation Mapping

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Focus**: Systematic paper-to-code comparison, identifying mismatches
**Date**: 2026-04-28

## Concept Mapping Table

| # | Burgess Paper | Lean Codebase | Match? | Notes |
|---|--------------|---------------|--------|-------|
| 1 | `r(A, β, C)`: ∀γ∈C, U(γ,β)∈A | `burgessR A β C`: ∀γ∈C, untl(β,γ)∈A | **SWAPPED ARGS** | Burgess: U(**event**, **guard**). Code: untl(**guard**, **event**). See Section 1 below. |
| 2 | `r(A, B, C)`: B is DCS, r(A,β,C) for all β∈B | `burgessRSet A B C`: ∀β∈B, burgessR A β C | Match (modulo #1) | Both say "for all β in B, the single-element relation holds" |
| 3 | `R(A, B, C)`: B maximal DCS w.r.t. r(A,—,C) | `BurgessR3Maximal A B C`: B maximal DCS w.r.t. burgessR3(A,—,C) | **DIFFERENT** | Code uses `burgessR3` (bidirectional) for maximality. Burgess uses only forward `r`. See Section 2. |
| 4 | C2: ∀ x<y in dom, r(f(x), g(x,y), f(y)) | `c2`: r3Relation(f(x), g(x,y), f(y)) | **DIFFERENT TYPE** | Code's C2 uses `r3Relation` (obligation propagation), not `burgessR3` (content-based). See Section 3. |
| 5 | C2': ∀ adjacent x,y: R(f(x),g(x,y),f(y)) | `c2'`: DCS ∧ burgessR3(f(x),g(x,y),f(y)) | **WEAKER** | Code omits **maximality** from c2'. Paper has R (maximal). See Section 4. |
| 6 | C3: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) | `c3`: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) | **MATCH** | Three-way decomposition correct. |
| 7 | C4a: ∀ x<y, ¬U(γ,δ)∈f(x) ∧ **γ∈f(y)** → ∃z, ¬δ∈f(z) | `c4`: ¬(untl γ δ)∈f(x) ∧ **δ∈f(y)** → ∃z, γ.neg∈f(z) | **MATCH** (corrected convention) | See Section 5 for guard/event convention analysis. |
| 8 | C5a: U(ξ,η)∈f(x) → ∃y>x, ξ∈f(y) ∧ η∈g(x,y) | `c5`: untl(γ,δ)∈f(x) → ∃y>x, δ∈f(y) ∧ ∀z∈dom, γ∈f(z) ∧ untl(γ,δ)∈f(z) | **DIFFERENT** | Paper uses **g(x,y)** for guard. Code checks **individual domain points**. See Section 6. |
| 9 | `rRelation A B` (codebase invention) | Not in Burgess | **INVENTED** | See Section 7. |
| 10 | Lemma 2.9 (C4): induction on n (elements between x,y) | Code: rightmost w with ¬U(γ,δ) + successor | **STRUCTURALLY DIFFERENT** | Paper uses induction with formula substitution. Code uses max/successor. See Section 8. |
| 11 | Lemma 2.10 (C5): Case n=m+1 uses 2.7 or 2.8 | Code: places y beyond all domain points | **MISSING INDUCTION** | Paper uses induction on elements after x. Code only does case n=0. See Section 9. |
| 12 | Lemma 2.5: R(A,B,C), r(A,B',D), r(D,B'',C), B⊆B'∩D∩B'' → B=B'∩D∩B'' | `burgessR3_absorption` | Partial match | Code proves the r3-relation propagates but doesn't prove the equality B=B'∩D∩B''. |

## Detailed Analysis

### Section 1: The Argument Swap in `r(A, β, C)` / `burgessR`

**Burgess (p. 370)**: "We write `r(A, β, C)` to indicate that A, C are MCSs related as in 2.3."

Lemma 2.3 says: for A, C MCSs, the following are equivalent for any β:
- (a) ∀γ∈C (U(γ, β) ∈ A)
- (b) ∀α∈A (S(α, β) ∈ C)

So in Burgess, **β is the guard** (the formula that persists throughout the interval), γ ranges over C (the right endpoint), and U(γ, β) has the **event** γ as the first argument to U.

**Lean code (ChronicleTypes.lean:274)**:
```lean
def burgessR (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  ∀ γ ∈ C, Formula.untl β γ ∈ A
```

Here `untl β γ` has β as the first argument. In our syntax, `untl φ ψ` means "φ U ψ" where **φ is the guard** and **ψ is the event**.

So `burgessR A β C` = ∀γ∈C, (β U γ)∈A. Here β is the guard, γ is the event.

**Burgess's** `r(A, β, C)` = ∀γ∈C, U(γ, β)∈A. Here γ is the "event" (first arg to U), β is the "guard" (second arg to U).

**CRITICAL**: This depends entirely on whether Burgess's U(p,q) notation means "p is the event, q is the guard" or vice versa.

From **Burgess p. 367**: "F α = U(α, T)" and "G'α = U(T, α)". Since F α means "α will eventually hold", and U(α, T) = F α, the FIRST argument to U is the eventuality (what will happen). The second argument "T" (always true) is the guard. So **U(event, guard)** in Burgess.

Therefore:
- Burgess `r(A, β, C)` = ∀γ∈C, U(γ, β)∈A = "for all events γ from C, the Until with guard β and event γ is in A"
- Code `burgessR A β C` = ∀γ∈C, untl(β, γ)∈A = "for all γ from C, untl(guard=β, event=γ) is in A"

**These are THE SAME** once we account for the U(event, guard) vs untl(guard, event) convention swap. The code's `untl(β, γ)` = Burgess's `U(γ, β)`. No mismatch here.

**Confidence**: HIGH. The convention is correctly handled.

### Section 2: BurgessR3Maximal vs Burgess's R(A,B,C)

**Burgess (p. 370)**: "We write R(A, B, C) to indicate that B is maximal with respect to the property r(A, —, C)." This is one-directional maximality: B is maximal among DCS satisfying `r(A, B, C)` = ∀β∈B ∀γ∈C, U(γ,β)∈A.

**Lean code (ChronicleTypes.lean:315)**:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

Where `burgessR3 A B C = burgessRSet A B C ∧ burgessRSetSince C B A`.

So the code's maximality is with respect to `burgessR3` (bidirectional: Until from A AND Since from C). Burgess's maximality is only with respect to `r` (Until from A, via Lemma 2.3 equivalence).

**But Lemma 2.3 shows these are equivalent**: r(A, β, C) includes BOTH directions because (a) ↔ (b). The forward (Until) condition implies the backward (Since) condition. So maximality w.r.t. r is the SAME as maximality w.r.t. the bidirectional condition.

**Confidence**: HIGH. No real mismatch — the code makes both directions explicit while Burgess gets the backward direction for free from Lemma 2.3.

### Section 3: C2 Uses Wrong r-Relation Type

**Burgess (p. 372)**: "(C2) Whenever x, y ∈ dom f and x < y, then r(f(x), g(x,y), f(y)) holds."

Here `r(A, B, C)` is the Burgess content-based relation: ∀β∈B ∀γ∈C, U(γ,β)∈A.

**Lean code (ChronicleTypes.lean:351)**:
```lean
def Chronicle.c2 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y → r3Relation (χ.f x) (χ.g x y) (χ.f y)
```

Where `r3Relation A B C = rRelation A B ∧ rRelationSince C B` — the **obligation propagation** concept:
```lean
def rRelation (A B : Set Formula) : Prop :=
  ∀ (γ δ : Formula), Formula.untl γ δ ∈ A → δ ∈ B ∨ (γ ∈ B ∧ Formula.untl γ δ ∈ B)
```

**This is fundamentally different from Burgess's r**:
- Burgess's r: "for β in B and γ in C, U(γ,β) ∈ A" — products of B and C elements appear as Until formulas in A
- Code's rRelation: "for U(γ,δ) in A, either δ∈B or (γ∈B and U(γ,δ)∈B)" — Until obligations from A are resolved/continued in B

Neither implies the other in general. The code's C2 is checking a DIFFERENT CONDITION than what Burgess requires.

**However**: The code's `c2` is only used in `ValidChronicle` (the target state). The actual construction uses `c2'` (adjacent pairs only) which uses `burgessR3`. The plan is that C2 (for all pairs) is derived at the limit from C2' + C3 via Lemma 2.5 absorption. So the fact that `c2` uses `r3Relation` instead of `burgessR3` is a definition-level issue — it may need to be changed to `burgessR3` to match the actual provable property.

**Impact**: MEDIUM. The `c2` condition as stated may be unprovable even at the limit. It should probably be changed to use `burgessR3` instead of `r3Relation`. However, it's not on the sorry critical path since `c2` is only checked in `ValidChronicle` and the construction targets C0+C1+C2'+C3+C4+C5.

**Confidence**: HIGH that this is a genuine definitional mismatch.

### Section 4: C2' Omits Maximality

**Burgess (p. 372)**: "(C2') Whenever x, y ∈ dom f and x immediately precedes y in dom f, then **R**(f(x), g(x,y), f(y)) holds."

R means **maximal** — B is a maximal DCS with the r-relation property.

**Lean code (ChronicleTypes.lean:363)**:
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    SetDeductivelyClosed (χ.g x y) ∧ burgessR3 (χ.f x) (χ.g x y) (χ.f y)
```

This checks `DCS ∧ burgessR3` but NOT maximality. The code comment says: "This is the weakened version that omits the maximality requirement of BurgessR3Maximal."

**This is a deliberate weakening**. But it has consequences:

1. **Lemma 2.6 (point insertion)** uses `R(A, B, C)` — specifically the maximality to get the δ∉B condition that triggers the D0 consistency argument. Without maximality in C2', the plan can't apply Lemma 2.6 to adjacent pairs directly.

2. **Lemma 2.5 (absorption)** uses `R(A, B, C)` for the equality `B = B' ∩ D ∩ B''`. Without maximality, only the weaker containment `B ⊆ B' ∩ D ∩ B''` holds.

3. **The C4 hard case** (Lemma 2.9, Case n=0) applies Lemma 2.6 to an adjacent pair, which requires R (maximal). With only c2', you'd need to first strengthen to BurgessR3Maximal.

**Impact**: HIGH. This weakening propagates to every place Lemma 2.6 or 2.5 is invoked. The code's `burgessR3Maximal_exists_from_seed` (RRelation.lean:1131) can produce BurgessR3Maximal from a seed, but the current c2' condition doesn't guarantee the seed exists.

**Confidence**: HIGH.

### Section 5: C4 Guard/Event Convention

**Burgess (p. 372)**: "(C4a) Whenever x, y ∈ dom f and x < y and ∼U(γ,δ) ∈ f(x) and **γ ∈ f(y)**, there is some z ∈ dom f with x < z < y and **∼δ ∈ f(z)**."

With Burgess's U(event, guard) convention: γ is the EVENT, δ is the GUARD. C4a checks the EVENT at f(y) and negates the GUARD at f(z).

**Lean code (ChronicleTypes.lean:392)**:
```lean
def Chronicle.c4 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y →
    ∀ (γ δ : Formula),
      (Formula.untl γ δ).neg ∈ χ.f x →
      δ ∈ χ.f y →
      ∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z
```

With code's `untl(guard, event)` convention: γ is the GUARD, δ is the EVENT. C4 checks EVENT δ at f(y) and negates GUARD γ at f(z).

Mapping: Burgess γ (event) → Code δ (event), Burgess δ (guard) → Code γ (guard).

**Match confirmed**. Both check the event at the endpoint and negate the guard at the intermediate point.

**Confidence**: HIGH.

### Section 6: C5 — Paper Uses g(x,y), Code Uses Domain Points

**Burgess (p. 372)**: "(C5a) Whenever x ∈ dom f and U(ξ,η) ∈ f(x), there is some y ∈ dom f with x < y and **ξ ∈ f(y)** and **η ∈ g(x,y)**."

With U(event, guard): ξ is the EVENT, η is the GUARD. C5a requires:
- Event ξ at f(y) (endpoint)
- Guard η in g(x,y) (the interval DCS between x and y)

**Lean code (ChronicleTypes.lean:418)**:
```lean
def Chronicle.c5 (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom,
    ∀ (γ δ : Formula),
      Formula.untl γ δ ∈ χ.f x →
      ∃ y ∈ χ.dom, x < y ∧ δ ∈ χ.f y ∧
        ∀ z ∈ χ.dom, x < z → z < y →
          γ ∈ χ.f z ∧ Formula.untl γ δ ∈ χ.f z
```

With untl(guard, event): γ is the GUARD, δ is the EVENT. Code's C5 requires:
- Event δ at f(y) ✓
- Guard γ at **every domain point z between x and y** AND untl(γ,δ) ∈ f(z)

**KEY MISMATCH**: Burgess puts η (guard) in **g(x,y)** (the interval DCS). The code puts γ (guard) in **f(z) for each domain point z**. These are NOT equivalent:

- **g(x,y) is one set** — the interval DCS. By C3, g(x,y) ⊆ f(z) for any z between x and y. So η∈g(x,y) IMPLIES η∈f(z) for all intermediate z.
- But the converse fails: η∈f(z) for all z doesn't imply η∈g(x,y). g(x,y) is the INTERSECTION of all information at intermediate points, so it's a stronger condition.

**The code's C5 is WEAKER than Burgess's C5**. Burgess requires the guard to be in the interval DCS (which implies it's at every intermediate point), while the code only checks individual domain points.

**However**: The code also requires `untl(γ,δ) ∈ f(z)` at intermediate points, which Burgess does NOT require. This extra condition is an artifact — Burgess's construction doesn't need it because η∈g(x,y) is the sufficient condition for the truth lemma.

**Impact**: HIGH. This is the root cause of the FUC (Forward Until Closure) sorry:
- The truth lemma (Claim 2.11) needs: if U(β,γ)∈f(x) then by C5 there's y with γ∈f(y) and β∈g(x,y), then by C3 g(x,y)⊆f(z) so β∈f(z) for intermediate z.
- **If C5 only says β∈f(z) at domain points**, you DON'T get β∈g(x,y), so C3 can't propagate.
- But if C5 says β∈g(x,y) (as in Burgess), you DO get β∈f(z) for ALL z (including non-domain points in the dense limit).

**The code's C5 should be reformulated to put the guard in g(x,y)**, matching Burgess. This would make the FUC proof straightforward via C3.

**Confidence**: HIGH. This is likely the deepest architectural mismatch.

### Section 7: `rRelation` Is an Invention Not in Burgess

The codebase defines (ChronicleTypes.lean:142):
```lean
def rRelation (A B : Set Formula) : Prop :=
  ∀ (γ δ : Formula), Formula.untl γ δ ∈ A → δ ∈ B ∨ (γ ∈ B ∧ Formula.untl γ δ ∈ B)
```

**This concept does not appear in Burgess's paper**. Burgess only defines `r(A, β, C)` (the content-based relation). The "obligation propagation" concept — where Until formulas in A must be resolved or continued in B — is an invention of the codebase.

The `rRelation` is used in:
- `r3Relation` (used by `c2`)
- `rMaximal` (used by `R3Maximal`)
- `rRelation_guard_continues'`

The `rRelation` concept has a different character than Burgess's `r`:
- Burgess's `r` is about CONTENT: B's elements combined with C's elements produce Until formulas in A
- `rRelation` is about OBLIGATION: Until formulas already in A must be tracked in B

While `rRelation` is mathematically valid, its presence creates confusion and the FUC sorry depends on trying to use `rRelation_guard_continues'` in a context where only `burgessR3` is available.

**Confidence**: HIGH.

### Section 8: C4 Elimination — Structural Divergence from Burgess

**Burgess Lemma 2.9** (C4 elimination) uses **induction on n** (number of domain elements between x and y):

- **Case n = 0**: Adjacent pair. Apply Lemma 2.6 (which requires R(f(x), g(x,y), f(y)) — **maximality**).
- **Case n = m+1**: Let x' immediately succeed x.
  - If ¬U(γ,δ) ∈ f(x'): replace x by x' (reduce to n=m).
  - If U(γ,δ) ∈ f(x'): note δ∈f(x') (else not a counterexample). Let γ' = δ ∧ U(γ,δ) ∈ f(x'). Using A3a: ¬U(γ',δ)∈f(x). **Reduce to n=0** by replacing γ→γ', y→x'.

**Key insight**: Burgess SUBSTITUTES the formula, creating ¬U(δ∧U(γ,δ), δ)∈f(x), and then applies Lemma 2.6 to the **adjacent pair (x, x')** instead of the original (x, y). This avoids the "nested" case entirely — the new formula has the ORIGINAL δ as the event component.

**Lean code** (CounterexampleElimination.lean:340-433): Uses a completely different strategy:
1. Find the **rightmost** w in [x,y) with ¬U(γ,δ)∈f(w)
2. Find successor w_next of w
3. If w_next = y: use simple bridging (δ∈f(y))
4. If w_next < y: U(γ,δ)∈f(w_next), call `burgessR3_gamma_not_in_B_nested` — **INVALID**

**The nested bridging sorry exists because the code doesn't follow Burgess's induction with formula substitution**. If the code implemented Burgess's approach:
1. At x', either ¬U(γ,δ)∈f(x') → induct with smaller n
2. Or U(γ,δ)∈f(x') → **substitute** γ' = δ∧U(γ,δ), and use A3a to get ¬U(γ',δ)∈f(x), then do the n=0 case with (x, x') adjacent

This substitution approach never encounters the "nested" case because the Lemma 2.6 application always uses the ORIGINAL event δ (not U(γ,δ)) as the formula to check at the right endpoint. The right endpoint is always x' (the immediate successor of x), and either δ∈f(x') (from the U(γ,δ)∈f(x') hypothesis) or the formula substitution ensures it.

**Impact**: CRITICAL. Implementing Burgess's induction with formula substitution would:
1. Eliminate the need for `burgessR3_gamma_not_in_B_nested` entirely
2. Require C2' to have **maximality** (for Lemma 2.6 application)
3. Need axiom A3a (BX3, right_mono_until) and BX5 (self_accum) — both available

**Confidence**: HIGH. This is likely the correct fix for the nested bridging sorry.

### Section 9: C5 Elimination — Missing Induction Step

**Burgess Lemma 2.10** (C5 elimination) uses induction on the number n of elements after x:

- **Case n = 0**: Apply Lemma 2.4. New y placed after x.
- **Case n = m+1**: Let x' immediately succeed x.
  - If (i) both η∧U(ξ,η)∈f(x') AND η∈g(x,x'): replace x by x' (reduce to n=m).
  - If (i) fails: either **Lemma 2.7** or **Lemma 2.8** applies. Insert z between x and x'.

**Lean code** (CounterexampleElimination.lean:167-204): Only implements **case n=0**. The code places y beyond ALL domain points, never between existing points. There is NO induction on elements after x.

**Impact**: HIGH. The missing induction step means the code's C5 elimination always places the witness AFTER all existing domain points, which means:
1. η is NOT placed in g(x,y) — the g-function isn't properly assigned
2. The guard at intermediate points (between x and y) is not ensured
3. This is a second root cause of the FUC sorry

Burgess's approach with the induction step is crucial because:
- When there are existing points between x and the witness, the guard must be maintained
- Lemma 2.7 and 2.8 handle the case where the Until obligation needs to be split

**Confidence**: HIGH.

## Summary of Mismatches by Severity

### CRITICAL (directly cause sorry sites)

1. **C4 elimination doesn't follow Burgess's formula substitution induction** (Section 8) → causes nested bridging sorry
2. **C5 condition uses domain-point guard instead of g(x,y) membership** (Section 6) → causes FUC sorry
3. **C5 elimination missing induction step** (Section 9) → guard not propagated, causes FUC sorry

### HIGH (architectural issues affecting correctness)

4. **C2' omits maximality** (Section 4) → Lemma 2.6 requires R (maximal), not just r
5. **C2 uses `r3Relation` instead of `burgessR3`** (Section 3) → definitional mismatch

### MEDIUM (confusion-causing but not directly blocking)

6. **`rRelation` is an invention not in Burgess** (Section 7) → creates confusion in the FUC proof strategy

### OK (correctly handled)

7. Guard/event convention swap (Section 1) — correctly handled
8. Bidirectional maximality (Section 2) — equivalent by Lemma 2.3
9. C3 three-way decomposition (Section 6 table) — correct
10. C4 guard/event checking (Section 5) — correct

## Recommended Fixes

1. **Restructure C4 elimination** to follow Burgess's induction with formula substitution (uses A3a=BX3, A5a=BX5). This eliminates the nested bridging sorry without needing `burgessR3_gamma_not_in_B_nested`.

2. **Reformulate C5 to use g(x,y)**: Change from "guard at every domain point" to "guard in g(x,y)". This makes the truth lemma follow directly from C3.

3. **Implement C5 elimination induction step** with Lemma 2.7/2.8. This ensures the guard is properly placed in the interval DCS.

4. **Strengthen C2' to include maximality**: Either change to `BurgessR3Maximal` or prove that `burgessR3Maximal_exists_from_seed` can upgrade any c2' pair to maximal when needed.

5. **Change C2 definition** from `r3Relation` to `burgessR3` to match the actual provable property.

## Confidence Level

**Overall**: HIGH. The paper-to-code mapping is clear, and the mismatches directly explain the stuck sorry sites. The critical mismatches (C4 induction strategy, C5 formulation, C5 elimination induction) are all cases where the code departs from Burgess's construction in ways that create problems the paper's approach avoids.
