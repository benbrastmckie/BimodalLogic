# Axiom Elimination Strategies for Cases 5-8

## Executive Summary

This report analyzes five alternative proof strategies for eliminating the axioms in Cases 5-8 of the GHR94 separation theorem (Lemma 10.2.3) for {S,U} temporal logic over integer time Z. The analysis yields a clear recommendation: **iterated single-U elimination** (Q1) is the most viable strategy for Cases 6-8, combined with **axiom retention for Case 5** as the pragmatic choice given that the Case 5 formula on Z is an open problem.

Key findings:
1. **Q1 (Iterated elimination)**: Cases 6-8 CAN be reduced to Cases 1-5 by iterated single-U elimination. The approach is well-founded and preserves all preconditions.
2. **Q2 (Semantic Finset)**: Does NOT produce a fixed-size formula; the disjunction size depends on the model. Not viable for constructing a Formula witness.
3. **Q3 (Reynolds alternative)**: Reynolds' approach avoids explicit formulas but requires different infrastructure (completeness-based argument). High effort, uncertain payoff.
4. **Q4 (FO round-trip)**: Circular as stated; the non-circular version (using inductive hypothesis at lower junction depth) is equivalent to the iterated elimination approach.
5. **Q5 (Multi-U generalization)**: Subsumed by iterated elimination; unnecessary added complexity.

**Recommended strategy**: Prove Cases 6-8 via iterated elimination reducing to Cases 1-5. Retain Case 5 axiom (mathematically sound). Prove temporal closure axioms using the elimination infrastructure.

---

## 1. Analysis of Q1: Iterated Single-U Elimination

### 1.1 The Setup

After applying `neg_until_equiv` to `neg U(A,B)`, we obtain:
```
neg U(A,B) <-> G(neg A) v U(neg A ^ neg B, neg A)
```

For Case 6: `S(a ^ neg U(A,B), q v U(A,B))`, expanding gives:
```
S(a ^ [G(neg A) v U(A', B')], q v U(A, B))
```
where `A' = neg A ^ neg B`, `B' = neg A`.

Distributing the conjunction `a ^ [G(neg A) v U(A', B')]` over disjunction in the event:
```
S(a ^ G(neg A), q v U(A,B))  v  S(a ^ U(A', B'), q v U(A,B))
```
using `since_distrib_or_left` (already proved).

### 1.2 Analysis of Each Disjunct

**Disjunct 1**: `S(a ^ G(neg A), q v U(A,B))`

The event `a ^ G(neg A)` is U-free (since `a` is U-free and `G(neg A)` contains no U). The guard `q v U(A,B)` contains U. This is exactly **Case 3** with:
- event = `a ^ G(neg A)` (U-free, S-free since `a` is S-free and `G(neg A)` is S-free)
- guard = `q v U(A, B)`
- A, B are the same as original

Case 3 is ALREADY PROVED. We need to verify the preconditions:
- `is_U_free (a ^ G(neg A))` = `is_U_free a && is_U_free (G(neg A))` = `true && true` = `true` (since `G(neg A)` = `all_future(neg A)` and `neg A = A.imp bot`, both U-free when A is U-free)
- `is_S_free (a ^ G(neg A))` = `is_S_free a && is_S_free (G(neg A))` = `true && true` = `true` (since `all_future` preserves S-freeness)

All preconditions hold. Case 3 applies directly.

**Disjunct 2**: `S(a ^ U(A', B'), q v U(A,B))`

This has TWO distinct U-formulas:
- `U(A', B')` = `U(neg A ^ neg B, neg A)` in the event
- `U(A, B)` in the guard

This is the two-U problem. Can we eliminate one U at a time?

### 1.3 The Iterated Elimination Strategy

**Step 1: Treat U(A,B) as an atom.** Define a fresh atom `p` not in `a, q, A, B, A', B'`. Consider the formula:
```
S(a ^ U(A', B'), q v p)
```
This has a SINGLE U-formula `U(A', B')` in the event only. This is **Case 1** pattern with:
- event component `a ^ U(A', B')` (with U(A', B') being the unique U-subformula)
- guard `q v p` (U-free)

Wait -- but Case 1 is `S(a' ^ U(A', B'), q')` where the guard is just `q'` (no disjunction with U). The guard here is `q v p` which IS U-free (p is an atom). So this is literally Case 1 with `a' = a`, `q' = q v p`, `A = A'`, `B = B'`.

Preconditions for Case 1:
- `is_U_free a` = true (given)
- `is_U_free (q v p)` = `is_U_free (neg q -> p)` = `is_U_free (q.imp bot).imp (atom p)` -- this involves checking is_U_free of q (true) and atom p (true). Result: true.
- `is_U_free A'` = `is_U_free (neg A ^ neg B)` -- computed from is_U_free of A and B (both true). Result: true.
- `is_U_free B'` = `is_U_free (neg A)` = true.
- S-free conditions: all of a, q v p, A', B' are S-free since A, B, a, q, p are all S-free.

All preconditions hold. Case 1 gives us a separated formula `psi1` such that:
```
int_equiv (S(a ^ U(A', B'), q v p)) psi1
```
and `is_syntactically_separated psi1 = true`.

**Step 2: Substitute p back.** Now `psi1` is a separated formula containing atom `p`. We need to substitute `p := U(A,B)` back:
```
subst_formula psi1 p U(A,B)
```

By `subst_correctness`, this substituted formula is equivalent to the original `S(a ^ U(A', B'), q v U(A,B))` under the interpretation where `p` maps to the truth set of `U(A,B)`.

But is the RESULT syntactically separated?

After substitution, every occurrence of atom `p` in `psi1` gets replaced by `U(A,B)`. Since `psi1` is syntactically separated:
- If `p` appears inside an `snce` argument of `psi1`, then `psi1` has `is_U_free(arg) = true` for that argument. After substitution, `is_U_free(arg[p/U(A,B)])` would be FALSE (since U(A,B) is not U-free). **The result is NOT syntactically separated.**

This is precisely the problem. Substitution breaks separation.

### 1.4 The Correct Iterated Approach

The substitution-then-separation approach is exactly what GHR94 Lemmas 10.2.4-10.2.8 do. The key insight is:

After substituting `p := U(A,B)` into `psi1`, the result `psi1[p/U(A,B)]` is NOT separated. But it has **strictly lower junction depth** than the original formula, because `U(A',B')` has been eliminated from under `S`. Now `U(A,B)` appears in `psi1[p/U(A,B)]` but only where `p` appeared in `psi1` -- specifically, `U(A,B)` appears at positions that were atoms (specifically `p`) in the separated formula `psi1`.

In a syntactically separated formula, atoms can appear:
1. At top level (under `imp` only)
2. Inside `snce` arguments (which are U-free)
3. Inside `untl` arguments (which are S-free)
4. Inside `all_past` arguments (which are U-free)
5. Inside `all_future` arguments (which are S-free)

After substituting `p := U(A,B)`:
- In contexts (2) and (4): atom `p` was inside a U-free context. After substitution, `U(A,B)` appears where `p` was. The `snce`/`all_past` now has a non-U-free argument. This creates a new S-U junction.
- In contexts (3) and (5): atom `p` was inside an S-free context. After substitution, `U(A,B)` (which IS S-free since A,B are S-free) appears where `p` was. The S-freeness is PRESERVED.
- In context (1): no issue, `U(A,B)` at top level is fine.

So the problematic positions are where `p` appeared inside `snce` or `all_past` arguments. At these positions, we now have `U(A,B)` under `S`, which is a new junction. But this is exactly the situation that the 8-case elimination handles! And crucially, the formula now has only ONE U-formula (`U(A,B)`) nested under S, because `U(A',B')` was already eliminated.

**This means the result can be further separated by applying the elimination cases again.** The junction depth has decreased because we eliminated one of the two U-formulas.

### 1.5 Well-Foundedness

The measure that decreases is the **number of distinct U-subformula types under S** (or equivalently, `count_U_subformulas` applied to the S-arguments).

- Original `S(a ^ U(A',B'), q v U(A,B))`: two U-subformulas under S
- After eliminating U(A',B') and substituting p := U(A,B): the result `psi1[p/U(A,B)]` has at most one U-subformula type under each S (only `U(A,B)`)
- The single-U-under-S case is handled by Cases 1-5

This is well-founded because we go from 2 U-subformulas to 1 U-subformula to 0 U-subformulas.

### 1.6 Formalizing in Lean

The iterated elimination requires:

1. **Fresh atom generation**: `fresh_atom` already exists in `FormulaOps.lean`
2. **Substitution**: `subst_formula` and `subst_correctness` already exist
3. **Case 1 application**: already proved
4. **Re-separation**: After substitution, need to show the result is separable by applying the full separation machinery (Cases 1-8 including Case 5 axiom)

The critical question is: **does the re-separation step require Case 5?**

For Case 6 specifically: After eliminating U(A',B') via Case 1 and substituting p := U(A,B), the result has `U(A,B)` appearing under `snce` (in positions that were U-free in `psi1`). To separate this, we need to apply elimination Cases 1-8 again. The specific case depends on how `U(A,B)` appears:

- If `U(A,B)` appears only in the event of some `snce`: Case 1 or Case 2
- If `U(A,B)` appears only in the guard of some `snce`: Case 3 or Case 4
- If `U(A,B)` appears in both event and guard: Case 5

So yes, Case 5 MAY be needed for the re-separation. This means **Cases 6-8 still depend on Case 5** even with iterated elimination.

### 1.7 Detailed Case-by-Case Analysis of Dependencies

**Case 6**: `S(a ^ neg U(A,B), q v U(A,B))`
- Disjunct 1: `S(a ^ G(neg A), q v U(A,B))` -- Case 3 (already proved)
- Disjunct 2: `S(a ^ U(A',B'), q v U(A,B))` -- two-U; eliminate U(A',B') first via Case 1, substitute back, re-separate with single U(A,B). Re-separation may need Cases 1-5.
- **Depends on**: Cases 1, 3, and potentially 5.

**Case 7**: `S(a ^ U(A,B), q v neg U(A,B))`
- Expand neg U(A,B) in guard: `q v G(neg A) v U(A',B')`
- `S(a ^ U(A,B), q v G(neg A) v U(A',B'))`
- Split guard: `(q v G(neg A)) v U(A',B')`
- This has U(A,B) in event and U(A',B') in guard. Two-U problem.
- Eliminate U(A',B') from guard: treat U(A,B) as atom p1, apply Case 3 (U in guard only) to eliminate U(A',B'), substitute back.
- Wait: Case 3 is `S(a', q' v U(A',B'))` with U-free event. But here the event `a ^ p1` is U-free (p1 is an atom). So Case 3 applies with event = `a ^ p1`, guard = `(q v G(neg A)) v U(A',B')`, i.e., q' = `q v G(neg A) v p1_... `. Actually, let me be more careful.

After substituting `p := U(A,B)`:
```
S(a ^ p, (q v G(neg A)) v U(A',B'))
```
Event `a ^ p` is U-free (p is atom). Guard `(q v G(neg A)) v U(A',B')`. This is Case 3 pattern (U in guard only): `S(event, guard_U_free v U(A',B'))`.

Wait, actually Case 3 is `S(a, q v U(A,B))` where the event is U-free AND the guard's non-U part is U-free. Here event = `a ^ p` (U-free), guard = `(q v G(neg A)) v U(A',B')`. The "q" part is `q v G(neg A)` which is U-free. So Case 3 applies with:
- a_param = `a ^ p`  (U-free: yes; S-free: yes since p is atom and a is S-free)
- q_param = `q v G(neg A)` (U-free: yes; S-free: yes)
- A_param = A' = `neg A ^ neg B` (U-free: yes; S-free: yes)  
- B_param = B' = `neg A` (U-free: yes; S-free: yes)

Case 3 gives separated `psi3`. Substitute `p := U(A,B)` back into `psi3`. The result has `U(A,B)` at positions that were atoms in `psi3`. Re-separate using Cases 1-5 (single U under S).

**Depends on**: Cases 1-5.

**Case 8**: `S(a ^ neg U(A,B), q v neg U(A,B))`
- Expand both neg U(A,B):
  - Event: `a ^ [G(neg A) v U(A',B')]`
  - Guard: `q v G(neg A) v U(A',B')`
- Distribute event:
  - `S(a ^ G(neg A), q v G(neg A) v U(A',B'))  v  S(a ^ U(A',B'), q v G(neg A) v U(A',B'))`
- Disjunct 1: Event is U-free. Guard has single U(A',B'). This is Case 3 with A', B'.
- Disjunct 2: Event has U(A',B'). Guard has U(A',B'). Same U in both! This is Case 5 pattern with A', B'.

So Case 8 reduces to Case 3 (proved) + Case 5 (with A', B' parameters).

**Depends on**: Cases 3, 5.

### 1.8 Summary of Q1

Iterated single-U elimination **works** for Cases 6-8, but all three cases ultimately depend on Case 5 (with possibly different formula parameters). This is expected: Case 5 is the base case for "U appears in both event and guard of S".

**For Cases 6 and 7**: The iterated approach reduces to Cases 1-5 via fresh-atom substitution + re-separation. The re-separation step involves single-U elimination which may require Case 5.

**For Case 8**: Directly reduces to Case 3 + Case 5 (with primed parameters).

**The iterated approach does NOT solve Case 5 itself.** It only shows that Cases 6-8 follow from Cases 1-5.

---

## 2. Analysis of Q2: Semantic Finset Argument for Case 5

### 2.1 The Idea

`S(a ^ U(A,B), q v U(A,B))` at time t with witness s means:
- `a(s)`, `U(A,B)(s)` (with U-witness u), and for all r in (s,t): `q(r) v U(A,B)(r)`

On Z, the interval (s, t) = {s+1, ..., t-1} is finite with t - s - 1 elements. At each point r in this interval, either q(r) or U(A,B)(r) holds. Define the "pattern" as the function `f : {s+1,...,t-1} -> {q, U}` recording which disjunct holds.

### 2.2 Why It Fails

The number of patterns is `2^(t-s-1)`, which depends on the specific model (the value of t - s). For a FIXED formula `S(a ^ U(A,B), q v U(A,B))`, different models produce different interval lengths, hence different numbers of patterns.

A temporal formula must be a single syntactic object (a `Formula` term) that works for ALL models simultaneously. We cannot have a formula whose size depends on a model-dependent parameter.

**Could we bound the interval length?** No. The witness s can be arbitrarily far from t, so t - s can be arbitrarily large. There is no a priori bound on the interval length that depends only on the formula.

**Could we express "for some pattern of length n" as a temporal formula?** The statement "there exist s, t with a specific pattern on (s,t)" requires quantifying over the interval length, which is exactly what temporal operators do. Encoding a variable-length pattern as a fixed formula brings us back to the original problem.

### 2.3 Verdict

The semantic Finset argument does NOT produce a fixed-size `Formula` witness. The approach is inherently model-dependent and cannot be formalized as a concrete separated formula. **Not viable.**

---

## 3. Analysis of Q3: Reynolds' Alternative Approach

### 3.1 Reynolds (1994) Overview

Reynolds' "Axiomatising first-order temporal logic: Until and Since over linear time" (Studia Logica, 1994) proves completeness of an axiom system for {U,S} over integer time Z. The proof establishes:

1. A complete axiom system for {U,S} over Z
2. Expressive completeness of {U,S} (every monadic FO sentence over (Z, <) has a {U,S} equivalent)
3. The separation property as a consequence of completeness

Reynolds' proof structure is fundamentally different from GHR94:
- GHR94 proves separation first (via Lemma 10.2.3's 8-case elimination), then derives expressive completeness
- Reynolds proves completeness of the axiom system first, then derives separation as a corollary

### 3.2 How Reynolds Avoids Case 5

Reynolds does NOT use an explicit case analysis on how U appears inside S. Instead, Reynolds' proof of separation goes through the completeness theorem:

1. Every consistent formula has a model (completeness)
2. In the canonical model construction, separated and non-separated formulas are shown to be equivalent
3. Separation follows from the algebraic structure of the canonical model

This approach completely avoids the need for an explicit separated formula for any particular case. The separation is a consequence of the algebraic properties of the logic, not a syntactic construction.

### 3.3 Feasibility for Our Formalization

Adapting Reynolds' approach would require:
1. **Defining the axiom system for {U,S} over Z** (~200 LOC)
2. **Proving completeness of the axiom system** (~1500-3000 LOC, this is a major undertaking)
3. **Deriving separation from completeness** (~200-400 LOC)

The completeness proof is the bottleneck. It requires:
- Canonical model construction for temporal logic
- Truth lemma for the canonical model
- Showing the canonical model is based on integer time (not just any linear order)

This is a substantial project in its own right, likely 2000-4000 LOC beyond what currently exists.

### 3.4 Verdict

Reynolds' approach is mathematically elegant and avoids the Case 5 formula entirely, but requires building a complete axiom system and canonical model construction from scratch. **Not viable within the current project scope** given the existing architecture. The effort (2000-4000 LOC) vastly exceeds the benefit (eliminating one axiom).

---

## 4. Analysis of Q4: FO Translation Round-Trip

### 4.1 The Idea

1. Translate `S(a ^ U(A,B), q v U(A,B))` to monadic FO over (Z, <)
2. Apply the FO-to-temporal back-translation (Theorem 9.3.1 direction)
3. Show the result is separated

### 4.2 Circularity Analysis

The FO-to-temporal translation (showing every monadic FO sentence has a {U,S} equivalent) is exactly what `separation_implies_expressiveness` proves. And `separation_implies_expressiveness` assumes the separation theorem as a hypothesis:
```lean
theorem separation_implies_expressiveness
    (h_sep : forall phi, is_separable phi) : ...
```

So the FO-to-temporal direction USES separation. If we use the FO round-trip to prove Case 5, and Case 5 is needed for separation, we have a circularity.

### 4.3 Breaking the Circularity

The circularity CAN potentially be broken if we use the INDUCTIVE HYPOTHESIS rather than the full separation theorem. The separation proof proceeds by induction on junction_depth:

- At junction_depth 0: formula is already separated (no U/S alternation)
- At junction_depth k+1: reduce to junction_depth <= k using the elimination cases

For Case 5 at junction_depth k+1: the formula `S(a ^ U(A,B), q v U(A,B))` with `a, q, A, B` all U-free and S-free has junction_depth 1 (one level of U-under-S alternation). By the IH, every formula with junction_depth 0 is separable. But Case 5's formula has junction_depth 1, so we cannot use the IH directly on it.

The FO round-trip would need: translate to FO, show the FO formula has an equivalent temporal formula with junction_depth 0. But the FO-to-temporal translation produces formulas whose junction_depth is NOT necessarily smaller than the original. The translation goes through quantifier depth, not junction depth, and these measures are not directly comparable.

### 4.4 Non-Circular Alternative

There IS a non-circular version: if we can establish an independent proof that every monadic FO formula over (Z, <) has a separated {U,S} equivalent (without using the GHR94 separation theorem), then we can use this to prove Case 5.

This is essentially Reynolds' approach (Q3) or an Ehrenfeucht-Fraisse approach. Both require substantial new infrastructure.

### 4.5 Verdict

The FO round-trip is circular as stated. The non-circular version requires an independent proof of the FO-to-temporal direction, which is equivalent in effort to Reynolds' approach. **Not viable as a simple fix.**

---

## 5. Analysis of Q5: Multi-U Generalization

### 5.1 The Idea

Generalize the 8-case framework to handle `S(event, guard)` where event and guard contain k distinct U-subformulas `U(A1,B1), ..., U(Ak,Bk)` (all with S-free arguments).

### 5.2 Why It Is Subsumed

The iterated elimination approach (Q1) already handles the multi-U case by eliminating one U at a time. Generalizing the framework to handle multiple U-formulas simultaneously would:

1. Require a case analysis with `8^k` cases (exponential in k)
2. Each case would need its own explicit formula
3. The Case 5 analogue (U appears in both event and guard for ALL k U-formulas) would be even harder to solve

In contrast, iterated elimination:
1. Applies the existing 8-case framework k times
2. Each application reduces the U-count by 1
3. The only hard case (Case 5) is encountered at most once per iteration

### 5.3 Verdict

Multi-U generalization is **unnecessary** given iterated elimination. It would add complexity without solving the fundamental Case 5 problem. **Not recommended.**

---

## 6. Synthesis: The Recommended Strategy

### 6.1 The Clear Picture

After analyzing all five research questions, the situation is:

1. **Case 5 is genuinely hard.** No strategy avoids needing either (a) a correct explicit formula for Z (open problem), (b) a completeness-based argument (Reynolds' approach, 2000+ LOC new infrastructure), or (c) an axiom.

2. **Cases 6-8 reduce to Cases 1-5** via iterated elimination. This is a clean, well-founded reduction that can be formalized in Lean.

3. **The temporal closure axioms** in SeparationThm.lean can be proved using the substitution bridge (GHR94 Lemmas 10.2.4-10.2.8) once ALL elimination cases (1-8) are available, whether proved or axiomatized.

### 6.2 Recommended Strategy

**Phase A: Prove Cases 6-8 via iterated elimination (replacing 3 axioms with proofs)**

For each of Cases 6, 7, 8:
1. Apply `neg_until_equiv` to rewrite `neg U(A,B)`
2. Distribute using `since_distrib_or_left`
3. For each resulting disjunct:
   - If it matches Cases 1-4 pattern: apply directly
   - If it has two U-formulas: substitute one U by fresh atom, apply Cases 1-4, substitute back, invoke the full separability machinery (which includes Case 5 axiom) for re-separation
   - If it matches Case 5 pattern (with primed parameters): apply Case 5 (axiom)

**Concrete reductions**:

| Case | Expansion | Reduces to |
|------|-----------|------------|
| 6: `S(a ^ neg U, q v U)` | `S(a ^ G(neg A), q v U) v S(a ^ U', q v U)` | Case 3 + (Case 1 + re-separation via Cases 1-5) |
| 7: `S(a ^ U, q v neg U)` | `S(a ^ U, (q v G(neg A)) v U')` | Case 3 + (substitute U as atom, use Case 3, re-separate via Cases 1-5) |
| 8: `S(a ^ neg U, q v neg U)` | `S(a ^ G(neg A), q v G(neg A) v U') v S(a ^ U', q v G(neg A) v U')` | Case 3 + Case 5 (with A', B') |

**Phase B: Prove temporal closure axioms using substitution bridge**

With Cases 1-8 available (1-4 proved, 5 axiomatized, 6-8 proved via Phase A):

For `all_past_separable`:
1. Given `is_separable phi` with separated equivalent `phi'`
2. If `phi'` is U-free: `all_past phi'` is separated (U-free argument)
3. If `phi'` has U-subterms with S-free arguments: extract maximal U-subterms, replace by fresh atoms, separate the simpler formula, substitute back, re-separate using elimination cases

This requires the substitution bridge infrastructure but is a standard construction once the elimination cases are available.

**Phase C: Retain Case 5 axiom**

The Case 5 axiom remains as the single axiom in the formalization. It is:
- Mathematically sound (the separation theorem for Z is established)
- Well-documented (with counterexample to GHR94's explicit formula)
- The minimum necessary axiom (all other axioms can be eliminated)

### 6.3 Effort Estimates

| Component | Estimated LOC | Difficulty |
|-----------|---------------|------------|
| Case 6 proof (iterated elimination) | 150-250 | Medium |
| Case 7 proof (iterated elimination) | 150-250 | Medium |
| Case 8 proof (iterated elimination) | 80-150 | Medium (direct reduction to Case 3 + Case 5) |
| Temporal closure: `all_past_separable` | 200-350 | High (substitution bridge) |
| Temporal closure: `all_future_separable` | 100-150 | Medium (dual of all_past) |
| Temporal closure: `untl_separable` | 150-250 | Medium-High |
| Temporal closure: `snce_separable` | 150-250 | Medium-High |
| **Total** | **980-1650** | |

### 6.4 Dependency Structure

```
Cases 1-4 (PROVED)
    |
    v
Case 5 (AXIOM, retained)
    |
    +---> Cases 6-8 (Phase A: prove via iterated elimination)
    |         |
    |         v
    +---> all_past_separable  \
    +---> all_future_separable | Phase B: prove via substitution bridge
    +---> untl_separable      |
    +---> snce_separable      /
              |
              v
         all_separable (follows from structural induction + closure lemmas)
              |
              v
         separation_theorem_int
```

### 6.5 Axiom Count After Implementation

- **Before**: 4 axioms in Eliminations.lean + 4 axioms in SeparationThm.lean = **8 axioms**
- **After**: 1 axiom in Eliminations.lean (Case 5) = **1 axiom**
- **Reduction**: 7 axioms eliminated

---

## 7. Proof Sketches in Pseudo-Lean

### 7.1 Case 8 (Simplest Reduction)

```lean
theorem elim_case_8 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
        (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  -- Let A' = neg A ^ neg B, B' = neg A
  let A' := Formula.and (Formula.neg A) (Formula.neg B)
  let B' := Formula.neg A
  -- neg U(A,B) <-> G(neg A) v U(A', B')
  -- Expand neg U(A,B) in both event and guard:
  -- Event: a ^ (G(neg A) v U(A',B'))
  -- Guard: q v G(neg A) v U(A',B')
  -- Distribute event via since_distrib_or_left:
  -- Disjunct 1: S(a ^ G(neg A), q v G(neg A) v U(A',B'))
  --   Event is U-free. Guard has single U(A',B'). Case 3 applies.
  -- Disjunct 2: S(a ^ U(A',B'), q v G(neg A) v U(A',B'))
  --   Same U in both event and guard! Case 5 applies (with A', B').
  -- obtain psi3 from elim_case_3 ... A' B' ...
  -- obtain psi5 from elim_case_5 ... A' B' ...
  -- Result: Formula.or psi3 psi5
  sorry -- detailed proof
```

### 7.2 Case 6 (Two-U Iterated Elimination)

```lean
theorem elim_case_6 (a q A B : Formula) ... := by
  let A' := Formula.and (Formula.neg A) (Formula.neg B)
  let B' := Formula.neg A
  -- neg U(A,B) <-> G(neg A) v U(A', B')
  -- Event: a ^ (G(neg A) v U(A',B'))
  -- Guard: q v U(A,B)
  -- Distribute event:
  -- D1: S(a ^ G(neg A), q v U(A,B)) -- Case 3 (event U-free)
  -- D2: S(a ^ U(A',B'), q v U(A,B)) -- two U-formulas
  --   For D2: substitute p := U(A,B) to get S(a ^ U(A',B'), q v p)
  --   This is Case 1 with a_param = a, q_param = q v p, A = A', B = B'
  --   Gives separated psi1 containing atom p
  --   Substitute p := U(A,B) in psi1
  --   The result is equivalent to D2 but not yet separated
  --   Apply all_separable (which uses Case 5 axiom) to separate it
  --   This gives a separated formula for D2
  sorry -- detailed proof
```

### 7.3 Temporal Closure: all_past_separable

```lean
theorem all_past_separable (phi : Formula) (h : is_separable phi) :
    is_separable (.all_past phi) := by
  -- h gives: exists psi, is_syntactically_separated psi ∧ int_equiv phi psi
  obtain ⟨psi, hsep, hequiv⟩ := h
  -- all_past(phi) equiv all_past(psi) by congr
  -- Case 1: psi is U-free. Then all_past(psi) is separated.
  -- Case 2: psi has U-subterms. Extract maximal U-subterms,
  --   replace by fresh atoms, show the simplified formula is separated,
  --   substitute back and re-separate using elimination cases.
  -- Both cases establish is_separable (all_past phi)
  sorry -- requires substitution bridge infrastructure
```

---

## 8. Infrastructure Requirements

### 8.1 For Cases 6-8 (Iterated Elimination)

**Already available**:
- `neg_until_equiv` (NegationEquiv.lean)
- `since_distrib_or_left` (Distributivity.lean)
- `elim_case_1`, `elim_case_3`, `elim_case_5_axiom` (Eliminations.lean)
- `fresh_atom`, `subst_formula`, `subst_correctness` (FormulaOps.lean)
- `or_separable`, `and_separated`, `neg_separated` (Eliminations.lean, private)
- `is_separable_of_equiv` (Eliminations.lean/SeparationThm.lean, private)

**Needs to be made public** (currently private in Eliminations.lean):
- `int_truth_and_iff`, `int_truth_or_iff`, `int_truth_neg_iff`
- `u_free_s_free_imp_separated`
- `or_separable`
- `is_separable_of_equiv`
- `since_event_split`

**New lemmas needed**:
- `neg_U_free`: `is_U_free A -> is_U_free (Formula.neg A)` (simple)
- `and_U_free`: `is_U_free A -> is_U_free B -> is_U_free (Formula.and A B)` (simple)
- `or_U_free`: `is_U_free A -> is_U_free B -> is_U_free (Formula.or A B)` (simple)
- `neg_S_free`, `and_S_free`, `or_S_free`: same for S-free (simple)
- `all_future_U_free`: `is_U_free A -> is_U_free (all_future A)` (simple)
- `all_future_S_free`: `is_S_free A -> is_S_free (all_future A)` (simple)
- `since_distrib_event_or`: `S(a ^ (X v Y), guard) <-> S(a ^ X, guard) v S(a ^ Y, guard)` -- this is a consequence of `since_event_split` + `since_distrib_or_left` but may need explicit proof
- `or_equiv_congr`: if `int_equiv A A'` and `int_equiv B B'` then `int_equiv (or A B) (or A' B')`

### 8.2 For Temporal Closure (Substitution Bridge)

**Major new infrastructure**:
- `extract_maximal_U_subterms`: Given a separated formula, identify the list of maximal U-subformulas (those whose arguments are S-free)
- `multi_subst`: Substitute multiple atoms for multiple U-subterms simultaneously
- `multi_subst_correctness`: Correctness of multi-substitution
- `re_separation`: Given a formula with single-U-under-S, apply elimination cases to produce a separated equivalent. This is the core of Lemma 10.2.4.

**Estimated LOC for infrastructure**: 300-500

### 8.3 Alternative: Simplify Temporal Closure via all_separable Restructure

An alternative to building the full substitution bridge is to restructure `all_separable` to use well-founded induction on `junction_depth` directly:

```lean
theorem all_separable (phi : Formula) : is_separable phi := by
  -- Induction on junction_depth phi
  induction h : junction_depth phi using Nat.strongRecOn with
  | ind n ih => ...
```

At each step, the temporal cases (`all_past`, `all_future`, `untl`, `snce`) can be handled by:
1. Recursively separating the arguments (IH applies since arguments have <= junction_depth)
2. If the separated arguments create new junctions when composed with the temporal operator, the junction_depth of the result is strictly smaller than the original, so IH applies

This approach subsumes the need for separate temporal closure axioms entirely. The key technical challenge is showing that `junction_depth` strictly decreases through the elimination process.

**Recommendation**: Use the `junction_depth` induction approach for `all_separable`, avoiding the need for explicit temporal closure axioms. This reduces the total axiom count to 1 (Case 5) and eliminates the need for the full substitution bridge.

---

## 9. Revised Recommended Implementation Plan

### Phase A: Make Private Helpers Public + Add Missing Helpers (2 hours)

Modify Eliminations.lean to make key helpers public. Add missing `_U_free` and `_S_free` lemmas.

### Phase B: Prove Cases 6-8 via Iterated Elimination (6 hours)

1. **Case 8** (simplest): Reduce to Case 3 + Case 5 with primed parameters
2. **Case 6**: Reduce first disjunct to Case 3, second to Case 1 + re-separation
3. **Case 7**: Substitute U(A,B) as atom, apply Case 3, substitute back, re-separate

Each proof follows the pattern:
```
neg_until_equiv -> since_distrib_or_left -> case reduction -> or_separable
```

### Phase C: Restructure all_separable with Junction-Depth Induction (4 hours)

Replace the 4 temporal closure axioms with a single well-founded induction proof on `junction_depth`. This eliminates 4 axioms in one step.

### Phase D: Integration (1 hour)

Verify `lake build`, check axiom/sorry counts, update documentation.

### Total Estimate

- LOC: 800-1400
- Axioms eliminated: 7 (of 8)
- Axioms remaining: 1 (Case 5, mathematically sound)
- Risk: Medium (junction_depth induction is technically involved but mathematically straightforward)

---

## 10. Risk Analysis

### Case 5 Axiom Retention

**Risk**: The project retains one axiom (Case 5). Is this acceptable?

**Mitigation**: The axiom is mathematically sound -- the separation theorem for Z is established by multiple independent proofs (Kamp 1968, Reynolds 1994, GHR94 Chapter 10 modulo the formula error). The axiom introduces no logical inconsistency. The counterexample to GHR94's explicit formula is documented.

**Future work**: Finding the correct explicit formula for Case 5 on Z is a research problem that could be pursued independently. If solved, the axiom can be replaced with a proof without changing any downstream code.

### Junction-Depth Induction Failure

**Risk**: The `junction_depth` measure may not strictly decrease through the elimination process, causing the induction to fail.

**Mitigation**: Verify the measure decrease for each case before implementing. The key observation is that after applying the 8-case elimination to `S(event, guard)` with U under S, the result has U only at "top level" (not under S), so the S-U junction depth has decreased by 1. This needs formal verification.

**Fallback**: If junction_depth induction fails, prove the 4 temporal closure axioms individually using the substitution bridge (GHR94 Lemmas 10.2.4-10.2.8). This is more verbose but each step is straightforward.

### Re-Separation After Substitution

**Risk**: After substituting U(A,B) back into a separated formula, the re-separation step may require infrastructure not yet built.

**Mitigation**: The re-separation only needs to handle the case of single-U under S, which is exactly what Cases 1-5 handle. No new infrastructure beyond the elimination cases is needed for this step. The `all_separable` theorem (once proved) provides the re-separation automatically.

---

## 11. Relationship to DualEliminations.lean

The DualEliminations file (8 sorries) is declared "dead code" in the plan. The analysis confirms this: once `all_separable` is proved (via the temporal closure route), the dual eliminations become trivially derivable:

```lean
theorem elim_case_1_dual ... :
    ∃ psi, int_equiv (U(a ^ S(A,B), q)) psi ∧ is_S_free psi = true := by
  -- all_separable gives: exists chi, is_syntactically_separated chi ∧ int_equiv (U(a^S(A,B), q)) chi
  -- A syntactically separated chi that is equivalent to a U-form...
  -- We need is_S_free, not is_syntactically_separated.
  -- These are DIFFERENT requirements.
  sorry -- Still blocked by architectural mismatch
```

The `is_S_free` requirement is strictly stronger than `is_syntactically_separated`. A syntactically separated formula can have `snce` subformulas (with U-free arguments), which are NOT S-free.

**Recommendation**: Either:
1. Remove DualEliminations.lean entirely (if the `is_S_free` conclusion is not needed downstream)
2. Strengthen `all_separable` to produce formulas that are not just syntactically separated but also have the right freeness property for the context (e.g., inside `untl`, the separated equivalent should be S-free)

Option 1 is recommended since DualEliminations are not on the critical path.

---

## References

- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Clarendon Press, Oxford. Chapter 10, Section 10.2.
- Reynolds, M. (1994). "Axiomatising first-order temporal logic: Until and Since over linear time." *Studia Logica* 57, pp. 118-138.
- Kamp, J.A.W. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Hodkinson, I., Reynolds, M. (2005). "Separation -- past, present, and future." *We Will Show Them!*, pp. 117-142.
- Oliveira, D., Rasga, J. (2021). "Revisiting separation: Algorithms and complexity." *Logic Journal of the IGPL* 29(3).
