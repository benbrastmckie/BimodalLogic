# Phase 2 Handoff: Case 5-8 Separability (BLOCKED)

**Task**: 157
**Session**: sess_1779084016_ff70c0
**Date**: 2026-05-17
**Phase**: 2 (Case 5 Intermediate Equivalence for Z)
**Status**: BLOCKED

## Immediate Next Action

Prove `case3_equiv_Z_general`: the three-disjunct semantic equivalence from GHR94 Lemma 10.3.11.3, specialized to integer time (Z), for ARBITRARY event `a` (not requiring U-free). This is the Q-lemma based decomposition:

```
S(a, q v U(A,B)) <->
  S(a, q)
  v [S(alpha, Q_Z(A,B,~q)) ^ (A v (B ^ U(A,B)))]
  v S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z(A,B,~q)), q)
```

where `alpha = a v (~q ^ S(a, q) ^ (q v U(A,B)))` and `Q_Z(A,B,~q) = B v A v ~S(~q, ~A)`.

On Z: K-/K+/Gamma all vanish (already proved in DedekindZ.lean), so the fourth disjunct (involving Gamma+(q)) disappears.

## Current Proof State

### What Is Proved (Phase 1 -- COMPLETED)
- `K_plus_bot_on_Z`, `K_minus_bot_on_Z`, `Gamma_plus_bot_on_Z`, `Gamma_minus_bot_on_Z`: K/Gamma triviality on Z
- `Q_lemma_Z_fwd`: Forward direction of Q-lemma for Z
- `Q_lemma_Z_bwd`: Backward direction of Q-lemma for Z
- `Q_Z_U_free`, `Q_Z_no_S_nested`: Syntactic properties of Q_Z
- All in `DedekindZ.lean` (~280 lines, sorry-free)

### What Is NOT Proved (Phase 2 -- BLOCKED)
- `case5_separable_Z`: Currently uses `all_separable _` (circular dependency on axioms)
- `case6_separable_Z`, `case7_separable_Z`, `case8_separable_Z`: Same
- `case5_dedekind_Z` (the semantic equivalence): NOT proved, only definitions exist

### Key Files
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (365 lines) -- Phase 1 done, Cases 5-8 still use `all_separable`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- Cases 1-4 proved, helpers (is_separable_of_equiv, or_separable, and_separable, neg_separable)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NegationEquiv.lean` -- neg_since_equiv, neg_until_equiv
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/IntHelpers.lean` -- Int.exists_least_above, Int.exists_greatest_below

## Critical Analysis: Why Simpler Approaches Fail

### Approach 1: neg_since_equiv Decomposition
```
S(a^U, qvU) <-> not H(not a v not U) ^ not S(not q ^ not U, not a v not U)
```
- First conjunct: reduces to Case 1 (S(a^U, top)). WORKS.
- Second conjunct: S(not q ^ not U, not a v not U) is Case 8 form (S(a' ^ not U, q' v not U) with a'=not q, q'=not a).
- Case 8 via neg_since_equiv decomposes back into Case 5 form.
- **Result**: CIRCULAR dependency between Cases 5 and 8.

### Approach 2: abstract_untl + subst_correctness Semantic Chain
- Abstract U(A,B) from `.snce event guard` using abstract_untl
- Get syntactically separated `phi_abs`
- Chain: `int_truth M t phi <-> int_truth M' t phi_abs` where M' = M.withAtom p ...
- phi_abs is separated in M', but NOT int_equiv to phi in the standard sense
- `subst_formula phi_abs p (.untl A B) = phi` (roundtrip), gives `int_equiv phi phi` (trivial)
- **Result**: Cannot extract a non-trivial separated formula from the abstraction.

### Approach 3: Junction-Depth Induction
- `junction_depth(S(a^U, qvU)) = 1` (single level of S-U nesting)
- JD induction at level 1 IS the base case
- After abstracting and substituting back into a separated formula, get a formula with U in S-args
- Need to re-separate this -- which is Cases 1-8
- **Result**: JD=1 base case IS Cases 1-8. No escape.

### Approach 4: Structural Induction
- For `.snce C F`: by IH, C and F are separable
- Need `.snce C' F'` (where C', F' separated) to be separable
- This is the `snce_separable` temporal closure AXIOM
- **Result**: Requires the axiom we're trying to eliminate.

## Correct Approach: Q-Lemma Based Case 3 General Equivalence

### Proof Structure (GHR94 Lines 488-529 of Literature File)

**Forward direction**: S(a, qvU)(t) -> RHS(t)

1. Assume exists s<t: a(s) and for all r in (s,t): q(r) or U(A,B)(r)
2. Define L = {z in (s,t) | q on (s,z)}, l = max L (or l=s if empty)
3. If L = (s,t): S(a, q)(t) holds -> disjunct (i). DONE.
4. Otherwise l < t-1 (exists point where q fails after l)
5. Define R = {z in (s,t) | q on (z,t)}, r = min R (or r=t if empty)
6. Show alpha(l) holds (boundary marker at l)
7. Show Q_Z on (l, r) by Q_lemma_Z_fwd (with guard C = ~q, interval (l, r))
8. Therefore S(alpha, Q_Z)(r) holds
9. Case split on r:
   - r = t: disjunct (ii) via S(alpha, Q_Z)(t) ^ beta(t)
   - r < t with U(A,B)(r): sub-cases on witness w of U(A,B)
   - r < t without U(A,B)(r): disjunct (iii) via S(event, q)(t)

**Backward direction**: RHS(t) -> S(a, qvU)(t)

1. Disjunct (i): S(a, q)(t) -> S(a, qvU)(t) by weakening guard
2. Disjunct (ii): S(alpha, Q_Z)(t) ^ beta(t). Find witness v for S(alpha, Q_Z). Unpack alpha(v) to find event point s. Use Q_lemma_Z_bwd to show C -> U(A,B) on (v, t). Show qvU on (s, t).
3. Disjunct (iii): S(event, q)(t). Find witness u with A(u), (qvU)(u), S(alpha,Q_Z)(u). From S(alpha,Q_Z)(u) find v < u. Use Q_lemma_Z_bwd on (v, u). Show qvU on (v, t).

### On Z Simplifications
- L and R are finite discrete sets. sup/inf become max/min or direct integer operations.
- Use `Int.exists_least_above` and `Int.exists_greatest_below` from IntHelpers.lean.
- No Dedekind completeness or limit arguments needed.
- The Q-lemma intervals are all finite with empty integer gaps.

### Estimated Effort
- Forward direction: ~120 lines (many case splits)
- Backward direction: ~80 lines
- Helper lemmas: ~30 lines
- Total: ~230 lines

## Dependency Graph for Cases 5-8

After proving `case3_equiv_Z_general`:

```
case3_equiv_Z_general (proved)
  |
  +-- Case 5: instantiate with a := a' ^ U(A,B)
  |     RHS separability: disjunct (i) = Case 1, (ii) = Case 1 + boolean, (iii) = Case 1
  |
  +-- Case 6: instantiate with a := a' ^ not U(A,B)
  |     RHS uses Cases 2, 3 (equivalence)
  |
  +-- Case 8: proved via neg_since_equiv + Cases 1, 2, 5
  |     S(a ^ not U, q v not U) <-> not H(not a v U) ^ not S(not q ^ U, not a v U)
  |     Second term = Case 5 form (now proved!)
  |
  +-- Case 7: uses Cases 4, 8
        S(a^U, qv not U) via neg_since_equiv + Cases 4, 8
```

## Key Decisions Made
1. The neg_since_equiv approach is CIRCULAR for Cases 5-8 when attempted directly
2. The abstraction/substitution approach cannot break the circularity
3. The Q-lemma based proof is the ONLY viable non-circular approach
4. Cases 5-8 are the irreducible base case of the junction-depth induction
5. Phase 1 infrastructure (Q-lemma, K/Gamma triviality) is solid and ready to use

## After Phase 2 Unblocks

Once Cases 5-8 are proved without `all_separable`:
1. **Phase 3**: Cases 6-8 follow from Case 5 + Cases 1-4 + neg_since_equiv (dependency is NON-circular once Case 5 is proved via Q-lemma)
2. **Phase 4**: Wire into hierarchy, prove junction_depth_separable_aux
3. **Phase 5**: Replace 9 axioms in SeparationThm.lean
4. **Phase 6**: Final verification and cleanup
