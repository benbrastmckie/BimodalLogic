# Research Report: Task #107 — Forward_G Resolution: The Adjacent-Only C4 Is the Second Definition Error

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Mode**: Team Research (4 teammates, Opus)
**Session**: sess_1777143370_037ede

## Summary

**SECOND DEFINITION ERROR IDENTIFIED**: The codebase's C4 is restricted to `Adjacent χ.dom x y` (ChronicleTypes.lean:306), but Burgess's C4a applies to ALL pairs `x < y` with NO adjacency restriction. This is why generalized C4 cannot be proved at the limit — the omega chain only eliminates adjacent C4 counterexamples, skipping non-adjacent ones entirely.

**The fix**: Remove `Adjacent` from C4/C4' definitions, implement Burgess's Lemma 2.9 induction on intermediate points for non-adjacent C4 elimination, and modify the omega chain to process C4 counterexamples for ALL pairs.

**Unanimous agreement**: All four teammates converge on this diagnosis. Option 2 (Lemma 2.9 generalization) is the correct path. Option 1 (two-sided seeds) has an unresolved consistency gap. Option 3 (remove forward_G from FMCS) displaces the problem without solving it.

## Key Findings

### 1. Burgess's C4a Has No Adjacency Restriction (Teammates A + D — DEFINITIVE)

Burgess 1982 line 210:
> (C4a) Whenever x, y ∈ dom f and **x < y** and ~U(γ, δ) ∈ f(x) and γ ∈ f(y), there is some z ∈ dom f with x < z < y and ~δ ∈ f(z).

The condition is `x < y`, not "x and y are adjacent." The codebase (ChronicleTypes.lean:306) uses `Adjacent χ.dom x y`, which is a second definitional divergence from Burgess (the first was the argument swap, now fixed).

**Consequence**: At the dense limit, there are no adjacent pairs. Adjacent-only C4 is vacuously true and provides zero information. This is why forward_G could not be proved.

### 2. Lemma 2.9 Handles Non-Adjacent C4 by Induction (Teammates A + D — DEFINITIVE)

Burgess's Lemma 2.9 proves: given a C4a counterexample (x, y, γ, δ) with n intermediate domain points, there exists an extension eliminating it. The proof is by induction on n:

**n = 0 (adjacent)**: Apply Lemma 2.6 directly. Insert z = (x+y)/2, set f(z) = D (from Lemma 2.6).

**n = m+1 (non-adjacent)**: Let x' be the immediate successor of x. Two sub-cases:
- **~U(γ, δ) ∈ f(x')**: Reduce to (x', y) with m intermediate points. Apply IH.
- **U(γ, δ) ∈ f(x')**: Then δ ∈ f(x') (else x' would already be the witness z). Set γ' = δ ∧ U(γ, δ). By A3a, ~U(γ', δ) ∈ f(x). Reduce to (x, x') with 0 intermediate points.

**Key insight**: Lemma 2.9 reduces non-adjacent to adjacent via formula manipulation. It always inserts exactly ONE point.

### 3. The Omega Chain Must Enumerate ALL-Pairs C4 Counterexamples (Teammate D — HIGH)

Burgess (lines 238-248):
> "We wish to form a sequence ... in such a way that whenever we have a counterexample to C4a ... there will eventually be an (f_n, g_n) for which it is no longer a counterexample."

The enumeration covers ALL potential C4 counterexamples — (x, y, γ, δ) where x < y in dom f, not just adjacent pairs. The codebase's enumeration (CounterexampleElimination.lean:646-650) checks `Adjacent χ.dom pc.x pc.y` and skips non-adjacent counterexamples.

### 4. Option 1 (Two-Sided Seeds) Has an Unresolved Consistency Gap (Teammate C — HIGH)

The consistency of `g_content(f(x)) ∪ h_content(f(y)) ∪ {target}` is NOT proved. The containment argument (`h_content(f(y)) ⊆ f(x)` by duality) gives the union ⊆ `g_content(f(x)) ∪ f(x)`, but `g_content(f(x)) ∪ f(x)` is NOT necessarily consistent under strict semantics (G(φ) ∈ f(x) does not imply φ ∈ f(x), so g_content may contain formulas whose negations are in f(x)).

**Verdict**: Option 1 requires a novel consistency proof that no one has produced in 26 rounds.

### 5. Option 3 (Remove forward_G) Doesn't Help (Teammate C — HIGH)

The truth lemma for G still requires C4 for all pairs (the Until completeness direction invokes C4a without adjacency restriction). Removing forward_G from FMCS just moves the obligation to the truth lemma proof, adding 20-30 hours of refactoring without resolving the mathematical issue.

### 6. What Needs To Change (All teammates converge)

1. **Remove `Adjacent` from C4/C4' definitions** — change `Adjacent χ.dom x y` to `x ∈ χ.dom → y ∈ χ.dom → x < y`
2. **Implement Lemma 2.9 induction** for non-adjacent C4 elimination — the n>0 case reduces to adjacent via formula manipulation (uses A3a axiom)
3. **Remove adjacency check from omega chain enumeration** — process C4 counterexamples for ALL pairs, not just adjacent
4. **Implement `lemma_2_6_full`** — the n=0 base case of Lemma 2.9 requires the full Lemma 2.6 seed (currently sorry'd)

## Synthesis

### Conflicts

None — all four teammates agree that the `Adjacent` restriction is the root cause.

### The Implementation Path

**Phase A: Fix C4/C4' adjacency restriction** (2-3 hours)
- Remove `Adjacent` from C4/C4' definitions
- Update `C4Counterexample`/`C4'Counterexample` structures
- Remove adjacency check from omega chain enumeration
- Fix compilation errors

**Phase B: Implement Lemma 2.9 induction** (8-12 hours)
- Implement the n>0 case: reduce to adjacent via formula manipulation
- The n>0 case needs: (a) finding the immediate successor x', (b) case split on ~U/U at f(x'), (c) formula construction using A3a, (d) recursive call to n-1 or n=0 case
- This is the bulk of the work — the formula manipulation uses A3a (BX4/connect_future in the codebase)

**Phase C: Implement Lemma 2.6 full seed** (5-8 hours)
- The n=0 base case of Lemma 2.9 uses Lemma 2.6
- Burgess's seed: {~δ} ∪ B ∪ {S(α, β) | α ∈ A, β ∈ B} ∪ {U(γ, β) | γ ∈ C, β ∈ B}
- Consistency follows from R3Maximality of B (if adding ~δ broke r3Relation, the contradiction gives a derivation that contradicts B's maximality)

**Phase D: Prove forward_G from generalized C4 + C0** (2-3 hours)
- With generalized C4 at the limit: G(φ) = ¬(untl(⊤, φ.neg)). If φ.neg ∈ f(y), C4 gives ⊤.neg = ⊥ ∈ f(z). ⊥ in MCS contradicts C0.
- This is now a clean one-step proof since C4 applies to ALL pairs

**Phase E: Close downstream sorry sites** (5-8 hours)
- forward_G/backward_H → chronicle_fmcs → box_stable → restricted coherence → dd_countermodel

**Total**: 22-34 hours (with false-lemma buffer: 30-45 hours)

### What Can Be Deleted

- The `Adjacent` field from `C4Counterexample`/`C4'Counterexample`
- The adjacency check in `eliminate_potential_counterexample`
- All g_ordered-related comments and dead code
- The old C4 "hard case" structure (will be replaced by Lemma 2.9)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Lemma 2.9 analysis | completed | HIGH | Traced Lemma 2.9 induction step-by-step with correct variable translation |
| B | Two-sided seeds | completed | HIGH | Viable in theory, but seed consistency unresolved |
| C | Critic | completed | HIGH | Identified fatal consistency gap in Option 1; confirmed Option 2 is correct but underestimated |
| D | Burgess end-to-end | completed | DEFINITIVE | **Identified `Adjacent` restriction as second definition error** |

## References

- Burgess 1982, line 210: C4a — "x < y" not "adjacent"
- Burgess 1982, lines 216-224: Lemma 2.9 — induction on intermediate points
- Burgess 1982, lines 238-248: Omega chain enumerates ALL counterexamples
- ChronicleTypes.lean:306: `Adjacent χ.dom x y` — the incorrect restriction
- CounterexampleElimination.lean:646-650: Adjacency check in enumeration
