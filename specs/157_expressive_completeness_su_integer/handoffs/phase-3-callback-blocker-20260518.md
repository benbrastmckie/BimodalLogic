# Phase 3 Handoff: Callback Blocker Analysis

**Date**: 2026-05-18
**Session**: sess_1779137455_784a5a
**Phase**: 3 (Hierarchy Theorem)
**Status**: IN PROGRESS (callback blocker identified)

## What Was Done

1. Added `snce_depth_of_U` measure (non-mutual S-nesting depth) to Hierarchy.lean
2. Proved base case: `snce_depth_zero_single_U_separated` (depth 0 + single U-type = separated)
3. Proved `no_S_nested_in_U_separable_noax` by count induction on `count_U_subformulas`
4. The count induction framework works: abstract a U-type, IH gives separability, substitute back
5. ALL steps are axiom-free EXCEPT the callback in `subst_in_separated_separable`

## The Callback Blocker (Detailed Analysis)

### Structure of the Problem

`no_S_nested_in_U_separable_noax` proves: `no_S_nested_in_U phi -> has_no_allpast_allfuture phi -> is_separable phi`.

The proof abstracts U-type U(A,B), gets separated phi', substitutes back using `subst_in_separated_separable`. The callback `ih_snce` receives `.snce c' d'` with `no_S_nested_in_U`. We need `is_separable (.snce c' d')`.

### Why Count Induction Fails for the Callback

The callback formula chi = `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free from the separated form psi.

- `count_U_subformulas chi` = number of p-occurrences in c and d (each p replaced by one `.untl A B`)
- This can be LARGER than `count_U_subformulas phi`
- So count_U does not decrease for the callback
- When phi IS a `.snce` at the root: abstracting and substituting back gives chi = phi itself

### Why S-Nesting Induction Also Fails

For the S-nesting approach (GHR94 Lemma 10.2.5):
- `snce_depth_of_U C < snce_depth_of_U (.snce C F)` when C contains U
- By IH: C is separable, F is separable
- But combining `is_separable C` and `is_separable F` into `is_separable (.snce C F)` requires `snce_separable` -- the axiom

### Why the Problem is Fundamentally Circular

To prove `is_separable (.snce C F)` without axioms:
1. Need to CONSTRUCT a syntactically separated formula equivalent to `.snce C F`
2. Abstracting U from `.snce C F` gives separated `.snce C' F'` (U-free args)
3. Substituting back gives `.snce C F` -- no progress
4. The callback in `subst_in_separated_separable` is called on the WHOLE `.snce` after substitution
5. This IS `.snce C F` when the separated formula is `.snce C' F'`

### The Correct Approach (from GHR94)

GHR94 Lemma 10.2.4 (lines 124-139) says: for `.snce C F` where U(A,B) appears only at top level (not under S), C and F can be decomposed using:
1. DNF on C, CNF on F  
2. S-distributivity (Lemma 10.2.1): `S(A v B, C) <-> S(A,C) v S(B,C)` and `S(A, B ^ C) <-> S(A,B) ^ S(A,C)`
3. After distribution: each piece is `S(C1, C2)`, `S(C1, C2 v +-U)`, or `S(C1 ^ +-U, C2 v +-U)` with C1, C2 U-free/S-free
4. Apply the 8 elimination cases (all proved)

### What Needs to Be Formalized

Option A: **DNF/CNF + S-Distributivity Decomposition** (~300-500 LOC)
- Define DNF/CNF conversion for formulas with U(A,B) as a special "atom"
- Prove S(DNF-event, CNF-guard) decomposes into boolean combination of the 8 case forms
- Apply `lemma_10_2_4` to each piece
- This is the GHR94 approach but requires substantial boolean algebra infrastructure

Option B: **Event-Guard Splitting Induction** (~200-300 LOC)  
- Induction on number of U-occurrences in event and guard
- Event-split: `S(C,F) <-> S(C^U,F) v S(C^~U,F)` (removes one U from event analysis)
- After event-split: `C^U` semantically simplifies (U=true), effectively removing U from C
- Need to formalize "C ^ U <-> C[U:=true] ^ U" where C[U:=true] is U-free
- This requires `abstract_untl` + semantic argument for "U is true in this branch"
- Guard similarly
- After full splitting: each branch has U only as +-U factor, matching cases 1-8

Option C: **Prove `snce_separable` Directly** (~400-600 LOC)
- For `.snce phi psi` with separable phi and psi:
- Get separated phi', psi'. `.snce phi psi <-> .snce phi' psi'`
- phi' and psi' have `.untl` nodes with S-free args
- Abstract all `.untl` from phi' and psi' into atoms
- Result is U-free `.snce`, which is separated
- Substitute back using multi-step substitution
- Each substitution step uses `subst_in_separated_separable` with callback = previous steps
- Multi-step substitution framework is new infrastructure

### Recommended Next Steps

1. **Option B** is the most direct and avoids new data structures
2. Key lemma needed: "In the branch where U(A,B) holds, C ^ U(A,B) is int_equiv to C' ^ U(A,B) where C' = abstract_untl C A B p [p := neg bot] (U-free)"
3. This can be proved semantically: when int_truth M t (.untl A B) holds, atom p (interpreted as U(A,B)'s truth set) is true at t, so replacing p with neg bot (true) preserves truth
4. After event-guard splitting on each U-occurrence: each branch has the event/guard in the form needed by `lemma_10_2_4`

### Current File State

- **Hierarchy.lean**: 1647 lines, builds clean, 0 sorry
- `all_separable` used at lines 854, 1520, 1557, 1563
- New infrastructure: lines 1366-1521 (snce_depth_of_U + no_S_nested_in_U_separable_noax)
- `all_formulas_separable_aux` still delegates `.snce` and `.untl` to `all_separable`

### Immediate Next Action

Implement the key lemma for Option B:
```lean
theorem and_untl_simplify_event (C A B : Formula) (p : Atom)
    (hfresh : ¬(p ∈ C.atoms))
    (hC_single : has_single_U_type C A B) :
    int_equiv (Formula.and C (.untl A B))
              (Formula.and (subst_formula (abstract_untl C A B p) p (Formula.neg .bot)) (.untl A B))
```

This says: `C ^ U(A,B) <-> C[U:=true] ^ U(A,B)` where C[U:=true] is U-free. The proof is by showing that when U(A,B) holds, all occurrences of U(A,B) in C evaluate to true, so replacing them with true (neg bot) preserves truth.
