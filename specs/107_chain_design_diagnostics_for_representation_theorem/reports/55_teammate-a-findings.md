# Research Report: Task #107 — Teammate A Findings
# Burgess 1982 Definition Discrepancy Analysis

**Task**: 107 — chain_design_diagnostics_for_representation_theorem
**Artifact**: 55, teammate-a
**Date**: 2026-05-05
**Phases completed prior to this research**: 1 (NoUnivBurgessR3 resolved), 2 (sorries #1, #3 closed), 3 (sorry #2 closed)
**Focus**: Precise, exhaustive discrepancy analysis between current Lean definitions and Burgess 1982

---

## Key Findings

1. **The r-relation is split into two fundamentally different concepts in our code** (Burgess has one). `rRelation`/`r3Relation` is an obligation-propagation relation (monotone in B), while `burgessR`/`burgessR3` is a content-based relation (anti-monotone in B). Burgess's `r(A, beta, C)` corresponds only to `burgessR`.

2. **`SetDeductivelyClosed` versus `ClosedUnderDerivation` split was fixed in Phase 2/3** but partial threading remains. Burgess's "DCS" requires only closure under derivation (no consistency requirement). Our `SetDeductivelyClosed` adds consistency. `BurgessR3Maximal` now correctly uses `ClosedUnderDerivation B` as first conjunct.

3. **`NoUnivBurgessR3` is a construction artifact with no Burgess analog**. Burgess implicitly assumes DCS = ClosedUnderDerivation throughout, so `Set.univ` is always a valid DCS. Our extra `¬burgessR3 A Set.univ C` hypothesis appears in 6 sorry stubs because our Zorn proof needs it to upgrade SDC-maximality to CUD-maximality. This is the root dependency for 6 of the 9 remaining sorries.

4. **C2' uses `BurgessR3Maximal` (correct content-based r-relation) but c2' sorries are NOT about the definition** — they are about the elimination functions not updating g-values for new adjacent pairs created during point insertion.

5. **The two ChronicleToCountermodel.lean sorries are downstream from c2'** — they need the full guard condition (C3 + limit_g) which depends on c2' being established at all finite stages.

---

## Discrepancy Table

### 1. r-Relation: Fundamental Conceptual Split

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| `r(A, beta, C)` (single beta) | For all gamma in C: U(beta, gamma) in A | `burgessR A beta C` — exactly this | YES |
| `r(A, B, C)` (set B, Def 2.3) | B is DCS AND for all beta in B: `r(A, beta, C)` | `burgessRSet A B C ∧ burgessRSetSince C B A` = `burgessR3 A B C` | DIVERGES — see note |
| `R(A, B, C)` maximality (Def 2.3) | B is maximal DCS with r(A, B, C) | `BurgessR3Maximal A B C` | YES (after Phase 2 fix) |

**Note on `r(A, B, C)` divergence**: Burgess's `r(A, B, C)` in Definition 2.3 means B is a DCS and for all beta in B: r(A, beta, C). This combines a Set condition (B is DCS) with a content condition (every element of B can serve as the guard for Until formulas from A landing in C).

Our `burgessR3 A B C` = `burgessRSet A B C ∧ burgessRSetSince C B A` adds a **symmetric backward condition** (Since from C through B to A). Burgess uses the asymmetric `r(A, B, C)` but employs its mirror image `r(C, B, A)` via Since-direction separately.

**Impact on sorries**: The symmetric `burgessR3` definition is more permissive than Burgess's single-direction `r(A, B, C)`, which means the `NoUnivBurgessR3` hypothesis may be harder to prove (requiring refutation of BOTH directions simultaneously).

### 2. DCS Definition

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| DCS = "deductively closed set" | Closed under consequence (no consistency requirement) | `ClosedUnderDerivation` = no consistency; `SetDeductivelyClosed` = consistent + CUD | SPLIT |
| DCS used for interval function g | Yes — g(x,y) is a DCS | `c1` requires `SetDeductivelyClosed` (consistent) for g(x,y) | DIVERGES |
| DCS used for BurgessR3Maximal first conjunct | DCS = closed under derivation | `ClosedUnderDerivation B` (fixed in Phase 2) | NOW MATCHES |
| `Set.univ` as valid DCS | Yes — trivially closed under derivation | `Set.univ` is `ClosedUnderDerivation` but NOT `SetDeductivelyClosed` | DIVERGES |

**Critical observation**: Our `c1` condition requires `SetDeductivelyClosed` (consistent DCS) for all g(x,y) values. Burgess's C1 requires only that g(x,y) is a DCS (closed under derivation). In practice, the Zorn construction always produces consistent g-values, so `c1` with `SetDeductivelyClosed` should hold. But this divergence means the formal statement of c1 is stronger than Burgess requires.

**Impact on sorries**: Not a direct blocker. The c2' sorries are about g-value construction, not c1.

### 3. R-Maximality (Most Important for Current Sorries)

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| "R(A, B, C)" maximality | B is max DCS with r(A, B, C); no proper extension B' satisfies r(A, B', C) | `BurgessR3Maximal A B C`: `ClosedUnderDerivation B ∧ burgessR3 A B C ∧ ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C` | MATCHES |
| Maximality range | Over all DCS (= CUD in Burgess) | Over all `ClosedUnderDerivation` sets (now fixed) | NOW MATCHES |
| Existence proof | Implicit (Zorn + DCS properties) | `burgessR3Maximal_extension_exists` via Zorn over SDC sets + `NoUnivBurgessR3` to upgrade | DIVERGES (extra hypothesis) |

**The `NoUnivBurgessR3` gap**: Burgess proves existence by Zorn over DCS (= CUD in his terminology). In his framework, Set.univ IS a valid DCS (it is CUD), but if burgessR3(A, Set.univ, C) held, then every formula would have to be an Until-guard formula in A, which contradicts A being an MCS. However, this argument requires knowing that A is MCS and appeals to MCS properties. Burgess does not need to state this explicitly because he doesn't distinguish CUD from SDC.

Our code separates CUD from SDC, and the Zorn construction runs over SDC. The upgrade from SDC-maximality to CUD-maximality requires excluding Set.univ (the only CUD-but-not-SDC set), which requires `NoUnivBurgessR3`. This is where the 6 sorry stubs come from.

### 4. C0 — Points Map to MCS

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C0 | f is a function from a subset of rationals to MCS | `∀ x ∈ dom, SetMaximalConsistent (f x)` | YES |
| C0' | dom(f) is finite | `dom : Finset Rat` (structurally enforced) | YES |

### 5. C1 — Intervals Map to DCS

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C1 | g maps pairs (x < y) in dom to DCS | `∀ x y, x ∈ dom → y ∈ dom → x < y → SetDeductivelyClosed (g x y)` | DIVERGES (consistency added) |

Burgess says DCS; we require SDC. As argued above, this is stronger than necessary but should hold in practice.

### 6. C2 — r-Relation for All Pairs

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C2 | r(f(x), g(x,y), f(y)) holds for all x < y in dom | `r3Relation (f x) (g x y) (f y)` for all x < y | DIVERGES — uses r3Relation not burgessR3 |

**Critical divergence**: Our `c2` uses `r3Relation` (the obligation-propagation version), not `burgessR3` (the content-based version). These are different relations! Burgess's C2 uses the content-based r-relation.

At the limit (dense domain), C2 in the obligation-propagation sense may be derivable from C2' (BurgessR3Maximal for adjacent pairs) via the Lemma 2.5 absorption lemma. But at finite stages, the mismatch matters.

**Impact on sorries**: The c2' sorries (#6-10) are about maintaining `BurgessR3Maximal` (= C2' using burgessR3) at adjacent pairs. These are the correct Burgess condition. The c2 condition (using r3Relation) is NOT what Burgess uses.

### 7. C2' — R-Maximality for Adjacent Pairs

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C2' | R(f(x), g(x,y), f(y)) for adjacent pairs | `BurgessR3Maximal (f x) (g x y) (f y)` for adjacent pairs | YES (correct definition) |

This matches Burgess exactly. The 5 sorry stubs (#6-10) in CounterexampleElimination.lean are NOT definition mismatches — they are missing proofs that c2' is maintained after each type of point insertion.

### 8. C3 — Three-Way Intersection

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C3 | g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) | `χ.g x z = χ.g x y ∩ χ.f y ∩ χ.g y z` | YES (fixed from two-way) |

This is confirmed correct per the docstring ("earlier two-way version was a transcription error that blocked 21 research rounds").

### 9. C4a — Backward Counterexample for Until

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C4a | x < y in dom, ¬U(γ,δ) ∈ f(x), γ ∈ f(y) → ∃ z, x < z < y, ¬δ ∈ f(z) | `¬(untl γ δ) ∈ f(x) → δ ∈ f(y) → ∃ z, ¬γ ∈ f(z)` | DIVERGES — argument order |

**Convention mismatch (resolved)**: Burgess writes U(γ, δ) where γ is the EVENT and δ is checked in C4a (guard at z). In our Lean code, `untl γ δ` has γ = GUARD and δ = EVENT. This means:
- Burgess C4a: ¬U(γ,δ) ∈ f(x), **δ** ∈ f(y), ∃ z with **¬γ** ∈ f(z) — his δ is the event, his γ is the guard checked at z
- Our c4: `¬(untl γ δ) ∈ f(x)`, **δ** ∈ f(y), ∃ z with **¬γ** ∈ f(z) — our δ is EVENT, our γ is GUARD (negated at z)

These correspond IF we interpret `untl γ δ` as "γ is guard, δ is event" — which is our convention. The c4 definition in ChronicleTypes.lean correctly implements Burgess C4a under this convention: "if Until(γ,δ) is false at x but the event δ holds at y, then the guard γ must have failed somewhere between x and y."

**Applies to ALL pairs, not just adjacent**: Confirmed in ChronicleTypes.lean docstring. Correct.

### 10. C5a — Forward Until Witness

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| C5a | U(ξ,η) ∈ f(x) → ∃ y, x < y, ξ ∈ f(y), η ∈ g(x,y) | `untl γ δ ∈ f(x) → ∃ y, x < y, δ ∈ f(y) ∧ ∀ z, x < z < y, γ ∈ f(z) ∧ untl γ δ ∈ f(z)` | DIVERGES — guard condition |

**Key divergence in C5**: Burgess C5a says the guard **η** holds in **g(x,y)** (the interval set). Our c5 says the guard **γ** holds at every **domain point f(z)** between x and y AND `untl γ δ ∈ f(z)`.

These are different formulations. Burgess uses the interval function g(x,y) to capture "holds throughout" semantics. Our c5 instead quantifies over domain points, requiring both γ ∈ f(z) and untl γ δ ∈ f(z) for all domain points z between x and y.

**Why our c5 is stronger**: Burgess's `η ∈ g(x,y)` means η is in the interval set (holds throughout the interval), which by C3 implies η ∈ f(z) for all z between x and y. But our c5 also requires `untl γ δ ∈ f(z)` at intermediate points, which Burgess doesn't state explicitly.

**Impact**: The two c5 sorries in ChronicleToCountermodel.lean (#11, #12) are about the **guard at intermediate domain points**. These require the full C3 + limit_g infrastructure. The formulation mismatch may complicate the proof.

### 11. Two-Argument r-Relation (rRelation, r3Relation)

| Aspect | Burgess 1982 | Our Code | Match? |
|--------|-------------|----------|--------|
| Purpose | Content-based: which formulas can serve as guards | `rRelation A B`: obligation-propagation (for all U(γ,δ) ∈ A, δ ∈ B or γ ∈ B ∧ U(γ,δ) ∈ B) | DOES NOT MATCH Burgess |
| Used in | NOT used in Burgess at all (he only uses burgessR) | Used in c2 condition (which is itself non-Burgess) | N/A |

`rRelation` and `r3Relation` are internal engineering constructs not in Burgess. They are monotone relations used to power `rMaximal_extension_exists` and `r3Maximal_extension_exists`. These exist alongside but separate from the true Burgess relations. The naming is potentially confusing.

**Impact on sorries**: The c2' sorries use `BurgessR3Maximal` (correct). The c2 condition uses `r3Relation` (non-Burgess). This architectural dual-track is documented in ChronicleTypes.lean but is a source of ongoing confusion.

### 12. Chronicle Conditions Summary

| Condition | Burgess 1982 | Our Code | Verdict |
|-----------|-------------|----------|---------|
| C0/C0' | f maps finite subset of Q to MCS | Structure enforced by `dom : Finset Rat` and `c0` | MATCHES |
| C1 | g maps pairs to DCS | c1 requires SDC (stronger than Burgess) | SLIGHTLY DIVERGES |
| C2 | r(f(x), g(x,y), f(y)) for all pairs | `r3Relation` for all pairs (wrong relation!) | DIVERGES |
| C2' | R(f(x), g(x,y), f(y)) for adjacent pairs | `BurgessR3Maximal` for adjacent pairs | MATCHES |
| C3 | g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) | Exact three-way intersection | MATCHES |
| C4a | ¬U event-check, guard-negate | Our c4 correctly implements this | MATCHES |
| C4b | mirror | Our c4' correctly mirrors | MATCHES |
| C5a | U witness with g-interval guard | Our c5 uses point-wise guard + U persistence | DIVERGES |
| C5b | mirror | Our c5' mirrors | DIVERGES |

---

## Analysis of Impact on Remaining 9 Sorries

### Sorries 1-6 in PointInsertion.lean (all NoUnivBurgessR3)

**Lines 178, 2717, 2719, 3596, 3598, 3686**

All 6 stubs are of the form `¬burgessR3 A Set.univ C` or `¬burgessR3 D Set.univ C`. These arise because:

1. Our Zorn construction in `burgessR3Maximal_extension_exists` runs over SDC sets (consistent + CUD)
2. The maximality clause in `BurgessR3Maximal` covers CUD sets (which includes Set.univ)
3. To close the gap, we need `¬burgessR3 A Set.univ C` to exclude Set.univ from extending B

**Burgess analogy**: Burgess never needs this because his DCS = CUD, and his Zorn argument directly produces a maximal CUD set. Set.univ is a valid CUD set in Burgess's framework, but his maximality argument doesn't need to exclude it explicitly — the content-based r-relation `r(A, B, C)` can hold for B = Set.univ only if EVERY formula is an Until-guard in A for every formula in C, which contradicts consistency of A.

**Proof path for NoUnivBurgessR3**:
From `burgessR3 A Set.univ C`, the condition `burgessRSet A Set.univ C` requires: for all β ∈ Set.univ and all γ ∈ C, `untl(β, γ) ∈ A`. Taking β = Formula.bot: for all γ ∈ C, `untl(bot, γ) ∈ A`. But `untl(bot, γ) → F(γ)` by BX10, and `untl(bot, γ) → untl(bot, bot)` by BX3 (right monotonicity with G(γ→bot) which follows from `G(¬γ)` using BX11). If `untl(bot, bot) ∈ A`, then F(bot) ∈ A, meaning some_future(bot) ∈ A. But some_future(bot) = some_future(bot) which by semantics would require a future point where bot holds — which is impossible in any model. Can this be derived syntactically? Yes: from `untl(bot, γ) ∈ A` for ALL γ, we can take γ = bot, giving `untl(bot, bot) ∈ A`. Then BX10 gives F(bot) ∈ A. Then `F(bot) = some_future(bot)` and `G(¬bot) = all_future(bot.neg)` is a theorem (from BX12 and consistency). So `¬F(bot) ∈ A` (from G(¬bot) being a theorem), contradicting `F(bot) ∈ A`.

**Lean proof sketch**: 
```
have h_bot : Formula.untl Formula.bot Formula.bot ∈ A := h_r3.1 Formula.bot Set.mem_univ Formula.bot Set.mem_univ
have h_F_bot := until_implies_F_in_mcs h_mcs_A h_bot
have h_G_neg_bot := ... -- G(¬bot) is a theorem via temporal_necessitation of neg_bot_thm
have h_neg_F_bot := ... -- H_mcs implies ¬F(bot) from G(¬bot)
exact absurd h_F_bot h_neg_F_bot
```

This proof requires only: (1) `h_mcs_A : SetMaximalConsistent A` and (2) `h_r3 : burgessR3 A Set.univ C`. It does NOT require any C being MCS — only that A is an MCS.

**Confidence: HIGH** that NoUnivBurgessR3 is provable as: `∀ A C, SetMaximalConsistent A → ¬burgessR3 A Set.univ C`.

### Sorries #6-10 in CounterexampleElimination.lean (c2' maintenance)

**Lines 758, 796, 836, 874, 920** — all `c2' := by sorry -- TODO Phase 4`

These are NOT definition mismatches. The issue is architectural: when a point z is inserted into the domain, new adjacent pairs are created. The `EliminationResult` structure returns a new chronicle but does not compute new g-values for new adjacent pairs. Therefore c2' (BurgessR3Maximal for adjacent pairs) cannot be proved for the new chronicle.

**Burgess correspondence**:
- For C5 insertion (Lemma 2.10): Burgess says "let B be maximal with respect to the properties that β ∈ B and r(A, B, C)". This B becomes g'(x, y_new). The BurgessR3Maximal fact for the new pair comes from the `lemma_2_4` output.
- For C4 insertion (Lemma 2.9): Burgess says "let D be any MCS extending D_0, and let B', B'' be maximal with respect to...". These B', B'' become g'(x, z) and g'(z, y). BurgessR3Maximal facts come from `lemma_2_6_splitting` output.
- For density insertion: Insert z = (x+y)/2 with f(z) = f(x). Need BurgessR3Maximal for (f(x), g(x,z), f(z)) = (f(x), g(x,z), f(x)). This requires computing a new g(x,z) value.

**Critical observation**: The elimination functions currently set `χ'.g = χ.g` (old g unchanged) or `∀ a b, χ'.g a b = χ.g a b` — they do NOT update g for new pairs. To close c2', the elimination functions must:
1. Compute new g-values for each new adjacent pair using lemma_2_4 (C5) or lemma_2_6_splitting (C4) or Zorn directly (density)
2. Return these new g-values as part of the chronicle structure
3. This requires changing the elimination function return types

**Impact on sorries #11-12** in ChronicleToCountermodel.lean: These are downstream — they need `limit_satisfies_c5_full` which depends on the limit chronicle satisfying C3 (which depends on c2' being maintained at all finite stages).

### Sorries #11-12 in ChronicleToCountermodel.lean

**Lines 611, 615** — guard at intermediate domain points

The two `sorry` stubs in `cantor_bfmcs_restricted_fuc` block the `forward_until_since_coherent` property:
- Forward Until: `U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ ∀ r ∈ (t,s), φ ∈ mcs(r)`
- Backward Since: mirror

The "endpoint witness" (∃ s > t with ψ ∈ f(s)) is available via `limit_satisfies_c5_weak`. The MISSING piece is the GUARD at intermediate points: `∀ r ∈ (t,s), φ ∈ mcs(r)`. This requires:
1. The limit chronicle satisfies c5 with the FULL guard (γ ∈ g(x, y) from the interval function, which by C3 gives γ ∈ f(z) for all z between x and y)
2. C3 at the limit (which holds by union of C3 at finite stages)
3. The interval function `limit_g` being properly defined

**Connection to c2' sorries**: c2' being maintained at all finite stages enables the Burgess Lemma 2.5 absorption argument to derive C2 (r-relation for all pairs) at the limit, which is needed for the truth lemma (Claim 2.11) that makes the interval function g work correctly.

---

## Recommended Approach

### Priority 1: Close NoUnivBurgessR3 (6 sorries)

Prove as a standalone lemma in PointInsertion.lean or RRelation.lean:

```lean
theorem no_univ_burgessR3 {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) :
    ¬burgessR3 A Set.univ C := by
  intro h_r3
  -- Taking beta = bot and gamma = bot (both in Set.univ and C respectively):
  have h_until_bot : Formula.untl Formula.bot Formula.bot ∈ A :=
    h_r3.1 Formula.bot Set.mem_univ Formula.bot Set.mem_univ
  have h_F_bot := until_implies_F_in_mcs h_mcs_A Formula.bot Formula.bot h_until_bot
  -- G(¬bot) is a theorem; hence ¬F(bot) is in A
  ... -- Use G_neg_bot_thm and MCS consistency
```

Note: The argument does NOT depend on C at all. Only A being MCS is needed. This means the 6 sorry stubs in PointInsertion.lean can each be closed by calling `no_univ_burgessR3 h_mcs_A` (or `h_mcs_D` as appropriate).

**Dependency**: None. Can be proved immediately.

### Priority 2: c2' Co-Construction (5 sorries in CounterexampleElimination.lean)

This requires architectural changes:

1. Modify elimination functions to compute new g-values and return them:
   - `eliminate_C5_counterexample`: capture B from `lemma_2_4` output; set `g'(x_max, y_new) = B`
   - `eliminate_C4_counterexample`: capture B', B'' from `lemma_2_6_splitting`; set `g'(w, z) = B'`, `g'(z, w_next) = B''`
   - `eliminate_C4'_counterexample`: mirror
   - Density insertion: use Zorn to compute g'(x, z) and g'(z, y) with BurgessR3Maximal

2. Update the `EliminationResult` structure or the c2' proof to use these new g-values.

**Key insight**: The g-function in `eliminate_C5_counterexample` currently returns `χ.g` (unchanged), but C5 adds a NEW domain point y_new. The pair (x_max, y_new) is a new adjacent pair with no g-value. Phase 4 of the plan addresses this.

**Dependency**: NoUnivBurgessR3 (needed for Zorn calls in lemma_2_4 and lemma_2_6_splitting which are called during c2' co-construction).

### Priority 3: FUC/FSC Coherence (2 sorries in ChronicleToCountermodel.lean)

These are structurally dependent on c2' being established at the limit. With c2' in place at finite stages, the limit chronicle satisfies C3 (by construction), and:
- `limit_g x y := ⋃ {g_n(x,y) | n, x,y ∈ dom_n}` satisfies C3
- C5 with full guard follows from: `η ∈ limit_g(x,y)` implies `η ∈ f_n(z)` for all intermediate domain points z (by C3 at each finite stage)

**Dependency**: c2' maintenance (Priority 2), plus limit_g infrastructure already in place.

---

## Confidence Level

| Claim | Confidence | Notes |
|-------|------------|-------|
| NoUnivBurgessR3 is provable from `SetMaximalConsistent A` alone | HIGH (90%) | The bot-guard argument is clean. Only risk: F(bot) refutation may need a specific theorem that's not yet proved |
| c2' sorries require EliminationResult architecture change | HIGH (95%) | Current elimination functions demonstrably set g unchanged; c2' cannot be proved without new g-values |
| C5 divergence (g-interval vs point-wise) does not block sorries #11-12 | MEDIUM (70%) | The point-wise formulation is derivable from g-interval formulation via C3; may need a bridging lemma |
| `burgessR3` symmetric definition is stronger than Burgess's `r(A,B,C)` | HIGH (85%) | Burgess uses separate directions; our symmetric definition requires both simultaneously |
| `r3Relation` (obligation-propagation) vs `burgessR3` (content-based) distinction | CERTAIN (100%) | These are provably different relations; documented in ChronicleTypes.lean; architectural dual-track is intentional |

---

## Summary for Phase 4 Planning

The 9 remaining sorries cluster into three independent groups:

**Group A (6 sorries): NoUnivBurgessR3 stubs**
- Location: PointInsertion.lean lines 178, 2717, 2719, 3596, 3598, 3686
- Resolution: Prove `no_univ_burgessR3` from `SetMaximalConsistent A` via bot-guard argument; replace all 6 stubs
- Effort: ~2-4 hours

**Group B (5 sorries): c2' co-construction**
- Location: CounterexampleElimination.lean lines 758, 796, 836, 874, 920
- Resolution: Modify elimination functions to compute and return new g-values; wire to c2' field in EliminationResult
- Depends on Group A (Zorn calls in lemma_2_4/lemma_2_6_splitting need NoUnivBurgessR3)
- Effort: ~8-12 hours (architectural change required)

**Group C (2 sorries): FUC/FSC guard coherence**
- Location: ChronicleToCountermodel.lean lines 611, 615
- Resolution: Establish `limit_satisfies_c5_full` using limit_g + C3 at limit; bridge from g-interval to point-wise guard
- Depends on Group B
- Effort: ~4-6 hours

**Total estimated remaining effort**: 14-22 hours to sorry-free completeness theorem.
