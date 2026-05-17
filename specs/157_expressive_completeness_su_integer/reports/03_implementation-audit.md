# Task 157 Implementation Audit: Expressive Completeness of {S,U} over Integer Time

## Date: 2026-05-16

---

## 1. Inventory of Completed Work

### 1.1 File Summary

| File | LOC | Definitions | Theorems Proved | Sorries | Status |
|------|-----|-------------|-----------------|---------|--------|
| Defs.lean | 274 | 15 | 3 | 0 | COMPLETE |
| FormulaOps.lean | 223 | 12 | 5 | 0 | COMPLETE |
| IntHelpers.lean | 157 | 0 | 9 | 0 | COMPLETE |
| Duality.lean | 196 | 1 | 7 | 0 | COMPLETE |
| Distributivity.lean | 188 | 0 | 4 | 0 | COMPLETE |
| NegationEquiv.lean | 155 | 0 | 2 | 0 | COMPLETE |
| Eliminations.lean | 372 | 1 | 4 proved, 4 sorry | 4 | PARTIAL |
| DualEliminations.lean | 150 | 0 | 0 proved, 8 sorry | 8 | BLOCKED |
| SeparationThm.lean | 165 | 0 | 1 partial, 4 trivial | 4 | BLOCKED |
| Separation.lean (hub) | 32 | 0 | 0 | 0 | COMPLETE |
| ExpressiveCompleteness.lean | 206 | 4 | 1 proved, 1 sorry | 1 | BLOCKED |
| **TOTAL** | **2118** | **33** | **~35** | **17** | |

### 1.2 Fully Proved Theorems (Complete List)

#### Defs.lean (3 theorems)
- `int_equiv_refl : (phi : Formula) -> int_equiv phi phi`
- `int_equiv_symm : int_equiv phi psi -> int_equiv psi phi`
- `int_equiv_trans : int_equiv phi psi -> int_equiv psi chi -> int_equiv phi chi`

#### FormulaOps.lean (5 theorems)
- `subst_correctness : int_truth M t (subst_formula phi target replacement) <-> int_truth (M.withAtom target {s | int_truth M s replacement}) t phi`
- `dnf_equiv : int_equiv phi (from_DNF (to_DNF phi))`
- `cnf_equiv : int_equiv phi (from_CNF (to_CNF phi))`
- `fresh_atom_not_in : fresh_atom phi not-in phi.atoms`
- `fresh_atoms_disjoint : forall a in fresh_atoms phi n, a not-in phi.atoms`
- `fresh_atoms_nodup : (fresh_atoms phi n).Nodup`

#### IntHelpers.lean (9 theorems)
- `Int.Ioo_finite'` : bounded open intervals in Z are finite
- `Int.Ioo_succ_empty` : (t, t+1) is empty in Z
- `Int.succ_least` : t < s implies t+1 <= s
- `Int.exists_least_above` : well-ordering for Z (KEY lemma)
- `Int.exists_greatest_below` : dual well-ordering
- `Int.exists_least_above'` : classical non-decidable version
- `until_witness_construction` : direct U-witness
- `since_witness_construction` : direct S-witness
- `neg_bot_true`, `since_top_is_past`, `until_top_is_future`

#### Duality.lean (7 theorems)
- `IntStructure.reverse_reverse` : M.reverse.reverse = M
- `swap_temporal_int_truth` : int_truth M t phi.swap_temporal <-> int_truth M.reverse (-t) phi
- `dual_equiv` : int_equiv phi psi -> int_equiv phi.swap_temporal psi.swap_temporal
- `dual_U_free_iff_S_free` : is_U_free phi.swap_temporal = is_S_free phi
- `dual_S_free_iff_U_free` : is_S_free phi.swap_temporal = is_U_free phi
- `dual_separated` : is_syntactically_separated phi.swap_temporal = is_syntactically_separated phi
- `dual_separable` : is_separable phi -> is_separable phi.swap_temporal

#### Distributivity.lean (4 theorems)
- `until_distrib_or_left` : U(AvB, C) <-> U(A,C) v U(B,C)
- `since_distrib_or_left` : S(AvB, C) <-> S(A,C) v S(B,C)
- `until_distrib_and_right` : U(A, B^C) <-> U(A,B) ^ U(A,C)
- `since_distrib_and_right` : S(A, B^C) <-> S(A,B) ^ S(A,C)

#### NegationEquiv.lean (2 theorems)
- `neg_until_equiv` : not U(A,B) <-> G(not A) v U(not A ^ not B, not A) -- KEY Z-dependent
- `neg_since_equiv` : not S(A,B) <-> H(not A) v S(not A ^ not B, not A)

#### Eliminations.lean (4 proved)
- `elim_case_1` : S(a ^ U(A,B), q) has separated equivalent (158 LOC proof)
- `elim_case_2` : S(a ^ not U(A,B), q) has separated equivalent (reduces to neg_until_equiv + Case 1)
- `elim_case_3` : S(a, q v U(A,B)) has separated equivalent (uses neg_since_equiv + Case 2)
- `elim_case_4` : S(a, q v not U(A,B)) has separated equivalent (uses neg_since_equiv + Case 1)

#### ExpressiveCompleteness.lean (1 proved)
- `q_exists_correct` : int_truth M t (q_exists A) <-> exists s, int_truth M s A

### 1.3 Key Definitions

- `IntStructure` : temporal structure over Z (valuation: Atom -> Set Z)
- `int_truth` : recursive truth evaluation for formulas over Z
- `int_equiv` : semantic equivalence over integer time
- `is_U_free`, `is_S_free` : syntactic absence predicates
- `is_syntactically_separated` : recursive separation check
- `is_separable` : existential separation predicate
- `junction_depth` / `junction_depth_U` / `junction_depth_S` : mutual induction measures
- `subst_formula` : formula substitution
- `IntStructure.withAtom` : single-atom modification
- `IntStructure.reverse` : time reversal
- `q_exists` : existential quantifier encoding as P(A) v A v F(A)
- `MonadicSignature`, `MonadicFormula`, `eval` (from MonadicFO.lean)

---

## 2. Inventory of Remaining Sorries

### 2.1 Eliminations.lean (4 sorries) -- PRIMARY BLOCKERS

**Sorry 1: `elim_case_5` (line 337)**
```
Goal: ∃ psi, int_equiv ((a.and (A.untl B)).snce (q.or (A.untl B))) psi
      ∧ is_syntactically_separated psi = true
```
Meaning: Find a syntactically separated formula equivalent to `S(a ^ U(A,B), q v U(A,B))`.
This is GHR94 Lemma 10.2.3 Case 5. **Blocked by incorrect GHR94 formula.**

**Sorry 2: `elim_case_6` (line 348)**
```
Goal: ∃ psi, int_equiv ((a.and (A.untl B).neg).snce (q.or (A.untl B))) psi
      ∧ is_syntactically_separated psi = true
```
Meaning: Find separated equivalent of `S(a ^ not U(A,B), q v U(A,B))`.

**Sorry 3: `elim_case_7` (line 359)**
```
Goal: ∃ psi, int_equiv ((a.and (A.untl B)).snce (q.or (A.untl B).neg)) psi
      ∧ is_syntactically_separated psi = true
```
Meaning: Find separated equivalent of `S(a ^ U(A,B), q v not U(A,B))`.

**Sorry 4: `elim_case_8` (line 370)**
```
Goal: ∃ psi, int_equiv ((a.and (A.untl B).neg).snce (q.or (A.untl B).neg)) psi
      ∧ is_syntactically_separated psi = true
```
Meaning: Find separated equivalent of `S(a ^ not U(A,B), q v not U(A,B))`.

### 2.2 DualEliminations.lean (8 sorries) -- DEPEND ON ELIMINATIONS + ARCHITECTURAL ISSUE

**All 8 dual cases** have the same structure:
```
Goal: ∃ psi, int_equiv (U-form with S nested) psi ∧ is_S_free psi = true
```

Note: These conclude `is_S_free psi = true`, NOT `is_syntactically_separated psi = true`. This is a stronger requirement than the primary cases. The duality approach (`swap_temporal` + primary case + swap back) gives `is_syntactically_separated` but NOT `is_S_free`. This is an **architectural mismatch** documented in the file comments.

### 2.3 SeparationThm.lean (4 sorries)

**Sorry 1: `all_separable` case `all_past` (line 87)**
```
Goal: case all_past
  phi phi' : Formula
  hphi' : is_syntactically_separated phi' = true
  heφ : int_equiv phi phi'
  ⊢ is_separable phi.all_past
```
Meaning: Given phi is separable (equiv to separated phi'), show all_past(phi) is separable.
Issue: `all_past(phi')` is separated only if `phi'` is U-free. If phi' contains untl, need substitution argument.

**Sorry 2: `all_separable` case `all_future` (line 90)**
```
Goal: same structure as all_past, for all_future (needs phi' to be S-free)
```

**Sorry 3: `all_separable` case `untl` (line 94)**
```
Goal: case untl
  phi psi phi' psi' : Formula
  hphi' : is_syntactically_separated phi' = true
  heφ : int_equiv phi phi'
  hpsi' : is_syntactically_separated psi' = true
  hepsi : int_equiv psi psi'
  ⊢ is_separable (phi.untl psi)
```
Meaning: Given phi equiv separated phi' and psi equiv separated psi', show U(phi,psi) is separable.
Issue: Need phi' and psi' to be S-free. If they're not, need the full elimination machinery.

**Sorry 4: `all_separable` case `snce` (line 98)**
```
Goal: same structure as untl, for snce (needs phi' and psi' U-free)
```

### 2.4 ExpressiveCompleteness.lean (1 sorry)

**Sorry: `separation_implies_expressiveness` (line 190)**
```
Goal: h_sep : ∀ (phi : Formula), is_separable phi
  ⊢ ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ A atomMap, ∀ (M : IntStructureFromSig sig) (t : ℤ),
        eval (int_to_ordered sig M) (fun x ↦ t) psi ↔ int_truth (to_int_struct M atomMap) t A
```
Meaning: Prove Theorem 9.3.1: if separation holds, then {U,S} is expressively complete.
This is a self-contained proof by induction on quantifier depth of the FO formula. It is logically independent of the elimination case issues.

---

## 3. Dependency Graph

```
                 elim_case_5 (BLOCKED)
                      |
              +-------+-------+-------+
              |       |       |       |
         elim_case_6  7  8  (can reduce to Case 5)
              |       |       |
              +---+---+---+---+
                  |
     +------------+------------+
     |                         |
DualEliminations (8)    all_separable (4 cases)
     |                         |
     +------------+------------+
                  |
       separation_theorem_int
                  |
  separation_implies_expressiveness (INDEPENDENT)
                  |
     US_expressively_complete_over_Z
```

### Dependency Details

1. **Cases 6, 7, 8** can potentially be proved by reducing to Cases 1-5 (using neg_until_equiv). Case 6 = neg event + Case 5 args. Case 7 = neg guard + Case 5 analog. Case 8 = double negation.

2. **DualEliminations** have an architectural issue: they need `is_S_free` conclusions, not just `is_syntactically_separated`. The simple duality approach (swap + primary + swap back) does NOT achieve this.

3. **all_separable** in SeparationThm.lean needs the full elimination hierarchy. The `all_past`, `all_future`, `untl`, `snce` cases all require the substitution-then-eliminate strategy from GHR94 Lemmas 10.2.4-10.2.8.

4. **separation_implies_expressiveness** is logically INDEPENDENT of the elimination cases. It only needs `h_sep : forall phi, is_separable phi` as a hypothesis, and proves the FO translation by induction on quantifier depth.

### Minimal Closure Set

To achieve zero sorries, we need:
- **Critical path**: Case 5 -> Cases 6-8 -> DualEliminations -> all_separable -> separation_theorem_int -> US_expressively_complete_over_Z
- **Independent**: separation_implies_expressiveness (can be proved in parallel)

---

## 4. Blocker Analysis: Case 5 and the GHR94 Formula Gap

### 4.1 The Problem

GHR94 p.370 claims Case 5 (`S(a ^ U(A,B), q v U(A,B))`) is equivalent to a formula containing the factor `A v (B ^ U(A,B))` evaluated at time t. A concrete counterexample demonstrates this is WRONG for integer time:

- With s=0, t=3: a(0), A(1), B vacuous on (0,1), q covers (0,3)
- LHS holds (S-witness at 0, U-witness at 1 with vacuous B)
- RHS fails (A(3)=false, B(3)=false)

### 4.2 Root Cause

On integers, `U(A,B)` at time s can hold with a **vacuous B-guard** when the U-witness is at s+1 (because the open interval (s, s+1) contains no integers). This means U(A,B) can hold without B being true at ANY point. The GHR94 formula implicitly assumes B-coverage reaches t, which is false with vacuous guards.

### 4.3 Why Cases 6-8 Are Also Blocked

- **Case 6**: `S(a ^ not U(A,B), q v U(A,B))` -- the guard `q v U(A,B)` has the same cascade issue
- **Case 7**: `S(a ^ U(A,B), q v not U(A,B))` -- event contains U(A,B), guard involves not U(A,B)
- **Case 8**: `S(a ^ not U(A,B), q v not U(A,B))` -- can be reduced via neg_until_equiv once Case 5 is solved

### 4.4 Implications

The blocker affects 17 of the 17 remaining sorries (all of them transitively depend on Cases 5-8 being resolved, except `separation_implies_expressiveness` which is independent).

---

## 5. Possible Paths Forward

### Path A: Find Correct Case 5 Formula (Direct Fix)

**Idea**: Derive a correct separated equivalent for `S(a ^ U(A,B), q v U(A,B))` that handles the vacuous B-guard scenario.

**Key Insight**: The formula must account for the fact that on integers, `U(A,B)` coverage in the guard can be satisfied purely by "stepping" through consecutive A-points with empty B-intervals between them.

**Candidate approach**: Use the discrete-time unfolding:
```
U(A,B)(t) <-> A(t+1) v (B(t+1) ^ U(A,B)(t+1))   [on integers]
```
This recursion "unrolls" U into a finite cascade (since the since-witness bounds the interval).

**Difficulty**: The formula needs to work for arbitrary A, B, q, a -- it cannot hard-code a fixed unrolling depth. However, within a bounded interval (s,t), only finitely many cascade steps are possible, and well-ordering gives the minimal/maximal points.

**Estimated effort**: High. The correct formula likely involves nested Since operators tracking the cascade. 200-400 LOC for Case 5 alone, plus similar for Cases 6-8.

### Path B: Restructure all_separable Without 8-Case Lemma

**Idea**: Prove `all_separable` using a different induction that avoids the explicit 8-case elimination. Instead of case-splitting on how U(A,B) appears in S-arguments, use a global substitution-based approach.

**Strategy**: 
1. By IH, every proper subformula is separable
2. For `S(phi, psi)`: replace each maximal U-subformula with a fresh atom
3. The resulting S-formula has U-free arguments (hence is already separated)
4. The fresh atoms each stand for U(A_i, B_i) where A_i, B_i are already separated
5. Use `subst_correctness` to relate the substituted formula back to the original
6. The substituted formula is equivalent to the original under the interpretation where fresh atoms get the truth sets of U(A_i, B_i)
7. Since the substituted formula is S-free (it's just S with U-free args), it IS separated
8. Therefore the original is separable (witnessed by the substituted formula)

**Key issue**: Step 7 is wrong -- the substituted formula `S(phi[p/U(A,B)], psi[p/U(A,B)])` is syntactically separated (S with U-free args), but we need to UNDO the substitution to show the ORIGINAL formula is equivalent to something separated. The substitution replaces U(A,B) with an atom `p`, and the equivalence only holds under a SPECIFIC interpretation of `p`. We cannot just use the substituted formula as the separated equivalent because it uses atom `p` which is unrelated to the original formula's atoms.

**This is exactly why GHR94 needs the 8-case lemma**: the elimination cases provide formulas that are equivalent WITHOUT any auxiliary atoms.

**Verdict**: This path does not work as a simple bypass. The 8-case lemma (or equivalent) is mathematically necessary.

### Path C: Alternative Induction on Discrete Unfolding

**Idea**: Instead of GHR94's structural elimination, use the discrete-time recursion:
```
U(A,B)(t) <-> exists n >= 1, A(t+n) ^ forall k in [1,n-1], B(t+k)
```

This rewrites U(A,B) in terms of a bounded existential over integers. Inside S, this bounded existential can be distributed.

**Strategy**:
1. For `S(phi, psi)` where phi/psi mention U(A,B):
2. Replace U(A,B)(r) at each point r in (s,t) with the bounded-existential form
3. Since the interval (s,t) is finite, the disjunction is finite
4. Each disjunct involves only atoms (from A, B expanded) and S/all_past operators with U-free args
5. The result is syntactically separated

**Key issue**: The bounded-existential form is `exists n, A(t+n) ^ forall k<n, B(t+k)` which is itself an INFINITE disjunction (n ranges over all naturals). We cannot write this as a single formula without using U again. The point of U is exactly to capture this infinite disjunction finitely.

**Verdict**: Does not directly work. The recursion `U(A,B)(t) <-> A(t+1) v (B(t+1) ^ U(A,B)(t+1))` still involves U on the right, so it is circular.

### Path D: Reynolds (2010) / Gabbay (1981) Alternative Formulations

**Idea**: Consult alternative literature sources for a correct Case 5 formula or alternative proof architecture.

**Reynolds (2010) "Axiomatising U and S over integer time"** provides an alternative axiomatization and may have a cleaner separation argument. The paper characterizes the complete axiom system for {U,S} over Z and likely includes separation as a consequence.

**Gabbay (1981)** introduced the separation theorem originally. His formulation may avoid the specific formula error in GHR94.

**Verdict**: Most promising research direction. A literature search for the correct Case 5 formula (or alternative proof approach) is the recommended next step.

### Path E: Prove Case 5 via Well-Founded Induction on the Cascade Length

**Idea**: Instead of providing a SINGLE separated formula equivalent to `S(a ^ U(A,B), q v U(A,B))`, prove existence by well-founded induction on the number of U-cascade steps in the interval.

**Strategy**:
1. Define a measure: the number of "U-steps" in the interval (s,t) where the guard is satisfied by U(A,B) rather than by q
2. When this measure is 0: all guard points satisfy q, so `S(a^U(A,B), q)` -- this is Case 1 (proved)
3. When this measure is k+1: find the last point m where U(A,B) provides coverage. At m+1 either A holds or B^U(A,B) holds. This gives a recursive decomposition that eventually terminates
4. By well-foundedness, a finite (formula-constructible) equivalent exists

**Key issue**: This gives an existential proof of separability but might not construct an explicit formula. In Lean, `exists` proofs can use classical logic, so we could potentially prove Case 5 using `Classical.choice` without exhibiting a concrete formula.

**Crucial observation**: The goal is `exists psi, int_equiv ... psi ^ is_syntactically_separated psi = true`. We only need to PROVE existence, not compute the formula. A classical existence argument might work!

**Verdict**: This is the most promising PROOF approach. We can potentially prove Case 5 using well-founded recursion on cascade length combined with Cases 1-4 (which are proved), without needing GHR94's explicit formula.

### Path F: Prove DualEliminations Differently

**Idea**: The DualEliminations have `is_S_free psi = true` as their conclusion, which is STRONGER than `is_syntactically_separated`. But notice: if we already have `all_separable` (which gives `is_syntactically_separated` equivalent for every formula), we don't actually NEED the dual eliminations as stated. The `all_separable` theorem already handles the `untl` case directly.

**Observation**: In SeparationThm.lean, the `untl` case of `all_separable` needs to show `is_separable (phi.untl psi)`. This means: find a separated equivalent. The separated equivalent of `U(phi, psi)` is:
- If phi' and psi' are S-free: `U(phi', psi')` is already separated
- If not: need to eliminate S from within U -- this is what DualEliminations provides

But if we restructure `all_separable` to use a stronger IH (induction on junction_depth), then at each step we can guarantee the IH gives us formulas with the right freeness properties.

**Verdict**: Coupled with Path E. Restructuring `all_separable` with a stronger induction could potentially bypass the need for separate DualEliminations entirely.

---

## 6. Recommendations

### Priority 1: Prove Case 5 via Classical Well-Founded Argument (Path E)

The most viable approach to unblock everything:

1. **Observation**: Cases 1-4 handle all situations where U(A,B) appears in ONLY the event OR ONLY the guard (with the other being U-free)
2. **Case 5 reduction**: When U(A,B) appears in BOTH event and guard, we can use the discrete-time "stepping" argument:
   - In the interval (s,t), there are finitely many points
   - At each point r, the guard `q(r) v U(A,B)(r)` holds
   - Partition the interval into "q-covered" subintervals and "U-covered" points
   - Each U-covered point r has a U-witness u_r > r with A(u_r)
   - By well-ordering, there's a FIRST non-q point m in (s,t)
   - Case split on whether the U-chain from m reaches past t or terminates before t
   - In both cases, reduce to formulas expressible via Cases 1-4 + induction

3. **Implementation**: ~200-300 LOC. Use `Classical.choice` and well-ordering. The proof CONSTRUCTS the separated equivalent implicitly through the existence proof.

### Priority 2: Restructure `all_separable` with Junction-Depth Induction

Once Case 5 (and derivatively 6-8) are proved:
- Restructure `all_separable` to use `Nat.strongRecOn` on `junction_depth`
- At junction_depth 0: formula has no U/S alternation, already separated
- At junction_depth k+1: extract the innermost alternation, apply elimination cases, recurse with strictly smaller junction_depth

This sidesteps the DualEliminations architectural mismatch: instead of needing `is_S_free` conclusions for the dual cases, we just apply the primary elimination cases to the DUAL (swapped) formula and use `dual_separated` to translate back.

### Priority 3: Prove `separation_implies_expressiveness` in Parallel

This sorry is INDEPENDENT of the Case 5 blocker. It requires:
- Induction on quantifier depth of MonadicFormula
- Use of `q_exists_correct` (already proved)
- Substitution via `subst_correctness` (already proved)
- The separation hypothesis `h_sep` (assumed as parameter)

Estimated effort: 150-250 LOC. Can be done without resolving the elimination case issues.

### Summary of Recommended Plan

| Phase | Work | Estimated LOC | Depends On |
|-------|------|---------------|------------|
| 1 | Prove `separation_implies_expressiveness` | 150-250 | Nothing (independent) |
| 2 | Prove Case 5 via well-founded cascade argument | 200-300 | Cases 1-4 (done) |
| 3 | Prove Cases 6-8 via reduction to Case 5 | 100-200 | Phase 2 |
| 4 | Restructure `all_separable` + DualEliminations | 200-300 | Phases 2-3 |
| 5 | Verify zero-sorry build | - | All phases |

**Total remaining**: ~650-1050 LOC of proof code.

---

## 7. Build Status

The project builds successfully with `lake build` (994 jobs). All 17 sorries produce only warnings, no errors. No type mismatches, no missing imports, no other issues. The sorry sites are all well-typed and the goal states are exactly as documented above.

---

## 8. Critical Assessment

### What Went Right
- Foundational modules (Defs, IntHelpers, Duality, Distributivity, NegationEquiv) are solid
- Cases 1-4 of the elimination lemma are fully proved with correct architecture
- The counterexample to GHR94's Case 5 formula is a genuine finding about the published literature
- Build infrastructure is clean (no non-sorry errors)

### What Needs Attention
- **DualEliminations architecture**: The `is_S_free` conclusion is problematic. Consider replacing with a different formulation that uses `all_separable` directly
- **all_separable proof structure**: The current simple structural induction is insufficient. Needs junction_depth well-founded induction
- **Case 5**: The mathematical content is correct (separation DOES hold for this case) but GHR94's specific formula is wrong. A constructive or classical existence proof is needed

### Risk Assessment
- **High confidence**: `separation_implies_expressiveness` can be proved (standard textbook argument)
- **Medium confidence**: Cases 5-8 can be proved via well-founded cascade argument (novel but mathematically sound)
- **Lower confidence**: DualEliminations as currently stated (may need reformulation)
- **Recommendation**: Consider whether DualEliminations are even needed if `all_separable` is restructured properly
