# Teammate A Findings: Full GHR94 Lemma 10.2.8 Hierarchy -- Exact Lean Implementation Specification

**Session**: Teammate A  
**Task**: 157 -- Expressive Completeness of {S,U} over Integer Time  
**Focus**: Exact Lean 4 implementation specification for the full 3-level compound WF recursion  
**Date**: 2026-05-17  

---

## Key Findings

1. **The 8 axioms in SeparationThm.lean are the exact target**: The current codebase has 4 weak temporal closure axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) and 4 parallel proper variants that must all become `theorem` declarations. The blocker is that every previous implementation attempt tried to prove `snce_separable` directly using structural or count induction, each of which requires `snce_separable` itself (circularity).

2. **The correct approach requires EXACTLY the 3-level compound induction GHR94 describes**: The induction is a lexicographic triple `(junction_depth, count_U_subformulas, S_nesting_above_U)`. The `junction_depth` outer measure handles the S-U alternation. The `count_U_subformulas` middle measure handles Lemma 10.2.6 (multi-U to single-U reduction). The `S_nesting_above_U` inner measure handles Lemma 10.2.5 (S-nesting above a single U). Only with all three measures working together does the induction terminate without circular appeal to `snce_separable`.

3. **`abstract_snce` is the missing infrastructure**: Just as `abstract_untl` abstracts a U(A,B) subformula to a fresh atom (already implemented in Hierarchy.lean), we need `abstract_snce` to abstract an S(E,F) subformula appearing INSIDE a U to a fresh atom. GHR94's Lemma 10.2.8 inductive step works by replacing `S(E_ij, F_ij)` inside `U(A_i, B_i)` with atoms `z_ij`, applying Lemma 10.2.7 (no S within U), and then resubstituting.

4. **The `all_past`/`all_future` primitive constructor issue has a clean fix**: Since `all_past` and `all_future` are transparent to `junction_depth` and `expand_temporal` already converts them to `snce`/`untl` equivalents, the induction should operate on `expand_temporal phi` rather than `phi` directly. The existing `expanded_jd_zero_imp_separated` theorem provides the base case.

5. **Cases 5-8 are NOT independent lemmas -- they emerge from the induction at lower junction depth**: When the junction depth induction step produces a `snce(A ∧ untl(X,Y), B ∨ untl(X,Y))` pattern (Case 5), the inner `untl(X,Y)` has junction depth LOWER than the current `snce` (because X,Y are now atom-replaced after the `abstract_snce` step). The IH on this lower-JD formula yields separability without needing an explicit Case 5 formula.

6. **`neg_until_equiv` is the bridge for Cases 5-8 within the induction**: The critical observation (missed by previous implementation attempts) is that when Cases 5-8 arise inside the induction, the formula `snce(a ∧ untl(X,Y), q ∨ untl(X,Y))` can be rewritten using `neg_until_equiv` to decompose `untl(X,Y)` into `G(¬X) ∨ untl(¬X∧¬Y, ¬X)`, reducing the U-count by 1 per `untl` instance. After this decomposition, one applies the multi-U-count induction (Lemma 10.2.6) with the reduced count.

7. **LOC estimate**: `abstract_snce` (~120 LOC), `abstract_snce_correct` and preservation lemmas (~150 LOC), junction depth decrease lemmas (~120 LOC), the main `no_S_nested_in_U_separable` induction (~250 LOC), temporal closure derivations (~80 LOC). Total: approximately 720 LOC.

---

## Exact Lean Specs (Per Lemma)

### GHR94 Lemma 10.2.3: The 8 Elimination Cases

**Status in codebase**: Cases 1-4 are FULLY PROVED in `Eliminations.lean`. Cases 5-8 are proved via `all_separable` (which currently depends on axioms) in `NormalForm.lean`.

**What this means for the implementation**: Cases 5-8 currently work as `all_separable _` (every formula is separable, by circular axioms). Once `no_S_nested_in_U_separable` is proved, Cases 5-8 can remain as `all_separable _` because they will follow from the axiom-free proof. No changes needed to Eliminations.lean or NormalForm.lean.

**Exact statement (existing, no change needed)**:
```lean
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) q) psi ∧
      is_syntactically_separated psi = true
-- (already proved)
```

Cases 5-8 will inherit separability from `all_separable` once `all_separable` is axiom-free.

---

### GHR94 Lemma 10.2.4: Single S with Top-Level U(A,B)

**Status in codebase**: EXISTS in `NormalForm.lean` as `lemma_10_2_4`. Calls `case5_separable` through `case8_separable` which use `all_separable`. This is the correct structure; no changes needed here once `all_separable` is axiom-free.

**What already exists**: The 8 individual case theorems (`case1_separable` through `case8_separable`) and the combined `lemma_10_2_4`. Also `since_event_split_separable` (splitting event on U(A,B)).

**Dependencies**: Cases 1-4 (direct), Cases 5-8 (via `all_separable`), which depends on temporal closure axioms we will eliminate.

---

### GHR94 Lemma 10.2.5: Single-U Formula Separability

**Status in codebase**: EXISTS in `Hierarchy.lean` as `single_U_formula_separable`. Currently uses `snce_separable` axiom for the `snce` case.

**Target theorem statement** (exists, structure is correct):
```lean
theorem single_U_formula_separable (phi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type phi A B) :
    is_separable phi
```

**Current proof gap**: The `snce` case calls `snce_separable` (axiom). The fix is to replace this with a call to `snce_single_U_type_separable`, a new lemma that proves the `snce` case WITHOUT axioms. This new lemma is the key lemma for the induction.

**New lemma needed** (S-nesting induction for single-U type):
```lean
/-- For snce case of Lemma 10.2.5: if phi, psi have single U-type U(A,B)
    with S-free A,B, then snce phi psi is separable.
    Proof by induction on S_nesting_above_U (snce phi psi). -/
theorem snce_single_U_type_separable (phi psi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_phi : has_single_U_type phi A B)
    (h_psi : has_single_U_type psi A B) :
    is_separable (.snce phi psi)
```

**Proof strategy**: By strong induction on `S_nesting_above_U (.snce phi psi)`.
- Base case `= 0`: phi and psi have no U at all (since it would be S-nested), so they're U-free. Then `snce phi psi` is U-free too and already separated.
- Actually more careful: S_nesting_above_U = 0 means U(A,B) appears directly in phi or psi without nested S above it. Apply `abstract_untl` to get phi', psi' that are U-free, apply `lemma_10_2_4` to the S formula `snce(abstract_untl phi A B p)(abstract_untl psi A B p)`, then resubstitute.
- Inductive step: If S_nesting_above_U > 0, each `snce` inside phi and psi (which may contain U(A,B)) has lower S_nesting. Apply the IH to those inner `snce` formulas first (using `single_U_formula_separable` on them), then use `lemma_10_2_4` on the outer `snce`.

**LOC estimate for this new lemma**: ~80 LOC.

**Key dependency**: `lemma_10_2_4` (from NormalForm.lean), `abstract_untl` (from Hierarchy.lean).

---

### GHR94 Lemma 10.2.6: Multi-U Formula Separability

**Status in codebase**: EXISTS in `Hierarchy.lean` as `multi_U_formula_separable`, but currently shortcuts to `all_separable phi` (circular axiom dependency). The predicate `no_S_nested_in_U` and count `count_U_subformulas` are both defined in `Defs.lean`.

**Target theorem statement** (must be proved without axiom):
```lean
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi
```

This is EQUIVALENT to `no_S_nested_in_U_separable` (the naming in Plan v7). This is the key theorem that breaks the circular dependency.

**Proof strategy**: Strong induction on `count_U_subformulas phi`.
- Base case `= 0`: phi is U-free. Since `no_S_nested_in_U` holds and phi is U-free, phi is separated. Use `u_free_s_free_separable` or the JD=0 argument.
- Case n=1: This is `single_U_formula_separable` (Lemma 10.2.5). 
  - Find the unique U(A,B) in phi (A,B are S-free by `no_S_nested_in_U`)
  - Apply `single_U_formula_separable` or the new `snce_single_U_type_separable`
- Case n>1: GHR94's induction. 
  - Pick one U(A_n, B_n) to "keep".
  - Replace all other U(A_i, B_i) (i < n) with fresh atoms q_i using `abstract_untl` iteratively.
  - The resulting phi' has `has_single_U_type phi' A_n B_n` (only U(A_n,B_n) remains).
  - Apply `single_U_formula_separable` to get a separated equivalent E' with only U(A_n,B_n).
  - E' is a boolean combination of atoms (including q_i), snce-terms (with no U), and U(A_n,B_n).
  - Substitute U(A_i,B_i) back for q_i in the snce/all_past parts of E'.
  - The resulting snce-terms now contain U(A_i,B_i) with i <= n-1 (count decreased!).
  - Apply IH (count = n-1) to separate those snce-terms.
  - The U(A_n,B_n) terms are pure future, no change needed.

**Critical technical point**: When substituting U(A_i,B_i) back into the separated E', the q_i atoms may appear inside `snce` arguments. The resulting `snce(X[q_i := U(A_i,B_i)], Y[q_i := U(A_i,B_i)])` has `count_U_subformulas = n-1` (one fewer U-type). This is where the count induction measure is essential.

**Key new infrastructure needed**:
- `abstract_untl_decreases_count`: `count_U_subformulas (abstract_untl phi A B p) < count_U_subformulas phi` when U(A,B) appears in phi.
- `subst_count_bound`: After substituting U(A_i,B_i) for q_i in a formula where q_i is an atom (count=0 for q_i), the count_U increases by at most the number of q_i occurrences times the count_U of U(A_i,B_i).
- For the specific case in Lemma 10.2.6: the separated E' has no new U besides U(A_n,B_n) and q_i's. Substituting U(A_i,B_i) for q_i (which has count_U = 1) adds at most n-1 U-types -- but they all have count <= n-1 (no U(A_n,B_n) appears in E's snce parts since E' is separated). So the count of the substituted snce-parts is <= n-1. The IH applies.

**LOC estimate**: The main induction body ~150 LOC. Supporting lemmas for the substitution-count bound ~80 LOC. Total for Lemma 10.2.6: ~230 LOC.

**Revised theorem statement** (replacing current shortcut):
```lean
-- This replaces line 594-596 in Hierarchy.lean
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi := by
  -- Strong induction on count_U_subformulas phi
  induction h' : count_U_subformulas phi using Nat.strong_rec_on with
  | ind n ih => ...
```

---

### GHR94 Lemma 10.2.7: No S within U -- Separability

**Status in codebase**: EXISTS in `SeparationThm.lean` as `no_S_within_U_separable`, but currently just calls `all_separable` (circular).

**Target theorem statement**:
```lean
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi
```

This is the same as `multi_U_formula_separable` since `no_S_nested_in_U` is defined on arbitrary formulas with the U-depth-under-S condition.

Actually, GHR94's Lemma 10.2.7 is proved by induction on `U_depth_under_S`. The proof calls Lemma 10.2.6 on the innermost U-formulas (whose arguments, after depth reduction, have no S under any U).

**Proof strategy** (strong induction on `U_depth_under_S phi`):
- Base case `= 0` (or n=1): phi has only one level of U under S. The U-arguments are S-free. Every U(A_i,B_i) in phi has S-free A_i, B_i. This is exactly `no_S_nested_in_U`, so apply `multi_U_formula_separable` (Lemma 10.2.6).
- Inductive step n>1: Let U(A_i,B_i) cover the shallowest U-subformulas. Each A_i and B_i may contain U(X_ij, Y_ij) subformulas. Replace each U(X_ij,Y_ij) in A_i,B_i with fresh atoms z_ij to get A'_i, B'_i (S-free). Replace each U(A_i,B_i) in phi with U(A'_i,B'_i) to get phi'. Apply Lemma 10.2.6 to phi' (which now has U_depth_under_S = 1). Get separated E'. Substitute z_ij back with U(X_ij,Y_ij). The U(X_ij,Y_ij) have lower U_depth_under_S (they were inside A_i,B_i). Apply IH.

**Note**: Lemma 10.2.7 reduces to Lemma 10.2.6 in the base case and uses `abstract_untl` for the substitution. The proof structure is clean because `abstract_untl` already exists.

**LOC estimate**: ~100 LOC (simpler than Lemma 10.2.6 since the structure is cleaner).

---

### GHR94 Lemma 10.2.8: General Case (Junction Depth Induction)

**Status in codebase**: EXISTS in `SeparationThm.lean` as `junction_depth_separable`, but just calls `all_separable` (circular).

**This is the MASTER theorem that eliminates all axioms**.

**Target theorem statement** (the key new proof):
```lean
/-- Every formula with no S nested within any U is separable.
    Proved by strong induction on junction_depth (expand_temporal phi). -/
theorem no_S_nested_in_U_separable_master (phi : Formula)
    (h : no_S_nested_in_U phi) :
    is_separable phi
```

Wait -- let me be more precise about what Lemma 10.2.8 does vs. what the codebase currently needs.

**The key insight from the literature**: GHR94's Lemma 10.2.8 DOES NOT prove `no_S_nested_in_U_separable`. Rather, it proves that ANY formula (with arbitrary S-in-U nesting) is separable, by:
1. Extracting S-subformulas from inside U (via `abstract_snce`)
2. Applying Lemma 10.2.7 to the simplified formula (S-in-U nesting removed)
3. Resubstituting the extracted S-subformulas
4. Applying the IH (the extracted S-subformulas have lower junction depth)

So the actual theorem structure needed is:

```lean
/-- GHR94 Lemma 10.2.8: Every formula is separable.
    Proved by strong induction on junction_depth (expand_temporal phi).
    This replaces ALL 8 temporal closure axioms. -/
theorem all_separable_no_axioms (phi : Formula) : is_separable phi
```

Proof by `Nat.strongRecOn` on `n = junction_depth (expand_temporal phi)`:

**Base case** `n = 0`: `expand_temporal phi` has junction_depth = 0. By `expanded_jd_zero_imp_separated`, `expand_temporal phi` is syntactically separated. By `expand_temporal_equiv`, phi is equivalent to `expand_temporal phi`. So phi is separable.

**Base case** `n = 1`: `expand_temporal phi` has junction_depth = 1. A formula with JD=1 has U-subformulas whose arguments are S-free (otherwise JD would be >= 2). So `no_S_nested_in_U (expand_temporal phi)`. Apply `no_S_nested_in_U_separable` (Lemma 10.2.7). Conclusion: `is_separable (expand_temporal phi)`. By `expand_temporal_equiv`, `is_separable phi`.

**Inductive step** `n >= 2`: D = `expand_temporal phi` has JD >= 2. D is a boolean combination of atoms, `untl(D1,D2)`, `snce(D1,D2)` (no `all_past`/`all_future` since `expand_temporal` eliminates them). By duality, handle `snce(D1,D2)`:
- Let U(A_i,B_i) be maximal U-subformulas in `snce(D1,D2)`.
- Since JD >= 2, some U(A_i,B_i) contain `snce(E,F)` subformulas.
- Replace each maximal `snce(E_ij,F_ij)` inside U(A_i,B_i) with fresh atom z_ij (using `abstract_snce`) to get U(A'_i,B'_i).
- Change `snce(D1,D2)` to D' by replacing U(A_i,B_i) with U(A'_i,B'_i).
- `D'` has no S inside any U (because we abstracted all S's inside U's). So `no_S_nested_in_U D'`.
- Apply `no_S_nested_in_U_separable` (Lemma 10.2.7) to get separated E' equivalent to D'.
- Resubstitute `snce(E_ij,F_ij)` for z_ij in E'.
- Each `snce(E_ij,F_ij)` has junction_depth `<= n-2` (it was inside U inside S, so 2 layers removed).
- Apply IH to `snce(E_ij,F_ij)` (since its JD of expand is `<= n-2 < n`).
- The parts of E' that contain z_ij are separated except where z_ij appears; after resubstitution and IH, everything becomes separable.

**The technical difficulty is the resubstitution step**: After substituting `snce(E_ij,F_ij)` back into E', the resulting formula is not immediately separated. We need to:
1. Identify which parts of E' contain z_ij and are "impure" after substitution.
2. Prove those parts have lower junction depth.
3. Apply the IH to separate them.
4. Reassemble using `or_separable`, `and_separable`, etc.

**LOC estimate**: The main body of the junction depth induction ~250 LOC. The `abstract_snce` function and its properties ~270 LOC. Total for Lemma 10.2.8 infrastructure: ~520 LOC.

---

## The Missing Infrastructure: `abstract_snce`

This is the most critical missing piece. It is the exact dual of `abstract_untl`.

**Exact definition**:
```lean
/-- Replace all occurrences of `snce E F` in phi with atom p.
    Used in GHR94 Lemma 10.2.8 inductive step: extract S-subformulas
    from inside U(A,B), allowing application of Lemma 10.2.7. -/
def abstract_snce (phi E F : Formula) (p : Atom) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp psi1 psi2 => .imp (abstract_snce psi1 E F p) (abstract_snce psi2 E F p)
  | .box psi => .box (abstract_snce psi E F p)
  | .all_past psi => .all_past (abstract_snce psi E F p)
  | .all_future psi => .all_future (abstract_snce psi E F p)
  | .untl psi1 psi2 => .untl (abstract_snce psi1 E F p) (abstract_snce psi2 E F p)
  | .snce psi1 psi2 =>
    if psi1 = E ∧ psi2 = F then .atom p
    else .snce (abstract_snce psi1 E F p) (abstract_snce psi2 E F p)
```

**Required theorems for `abstract_snce`** (parallel to `abstract_untl` theorems):

```lean
-- Semantic correctness (parallel to abstract_untl_correct)
theorem abstract_snce_correct (phi E F : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms))
    (M : IntStructure) (t : Int) :
    int_truth M t phi ↔
    int_truth (M.withAtom p {s | int_truth M s (.snce E F)}) t
      (abstract_snce phi E F p)

-- Syntactic roundtrip (parallel to abstract_subst_roundtrip)
theorem abstract_snce_subst_roundtrip (phi E F : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms)) :
    subst_formula (abstract_snce phi E F p) p (.snce E F) = phi

-- Makes formula S-free when phi has single S-type
theorem abstract_snce_makes_S_free (phi E F : Formula) (p : Atom)
    (h : has_single_S_type phi E F) :
    is_S_free (abstract_snce phi E F p) = true

-- Preserves U-freeness (needed for no_S_nested_in_U)
theorem abstract_snce_preserves_U_free (phi E F : Formula) (p : Atom)
    (h : is_U_free phi = true) :
    is_U_free (abstract_snce phi E F p) = true

-- Key property: if phi has no S nested in U, abstracting S(E,F) inside U
-- gives a formula where those S(E,F) occurrences are replaced by atoms,
-- but no NEW S-in-U nesting is introduced.
theorem abstract_snce_preserves_no_S_in_U (phi E F : Formula) (p : Atom)
    (h : no_S_nested_in_U phi) :
    no_S_nested_in_U (abstract_snce phi E F p)
-- Holds VACUOUSLY: if no S in U initially, abstracting S to atom does not
-- introduce new S-in-U. The atom p is S-free. So the resulting formula
-- still has no S in U (if it was true before, it remains true).
-- Wait: actually this would make sense only for abstracting S inside U.
-- The correct statement for the Lemma 10.2.8 step is different.
```

**The KEY lemma for Lemma 10.2.8**: After replacing all maximal S(E_ij,F_ij) INSIDE the arguments of U(A_i,B_i) with atoms z_ij, the resulting U(A'_i,B'_i) has S-free A'_i and B'_i. Then the overall formula D' (with U(A_i,B_i) replaced by U(A'_i,B'_i)) satisfies `no_S_nested_in_U D'`.

```lean
/-- If we replace each maximal S-subformula inside U-arguments with fresh atoms,
    the result has no S nested within any U. -/
theorem snce_abstract_inside_U_makes_no_S_nested
    (phi : Formula) (p : Atom) (E F : Formula) :
    -- Replace snce(E,F) appearing inside untl-arguments with atom p
    -- The resulting formula has no_S_nested_in_U
    no_S_nested_in_U (abstract_snce_in_untl_args phi E F p)
```

Note: We need `abstract_snce_in_untl_args` which ONLY abstracts S(E,F) when it appears inside a `untl` subformula (not top-level S occurrences). This is a variant of `abstract_snce`:

```lean
/-- Abstract snce(E,F) ONLY when inside a untl subformula context.
    This is the correct operation for the Lemma 10.2.8 inductive step. -/
def abstract_snce_inside_untl (phi E F : Formula) (p : Atom) : Formula :=
  -- When we're outside any untl: leave snce intact, recurse into untl args
  match phi with
  | .untl psi1 psi2 =>
    .untl (abstract_snce psi1 E F p) (abstract_snce psi2 E F p)
  -- Everywhere else: recurse without abstracting
  | .atom a => .atom a
  | .bot => .bot
  | .imp psi1 psi2 => .imp (abstract_snce_inside_untl psi1 E F p)
                            (abstract_snce_inside_untl psi2 E F p)
  | .box psi => .box (abstract_snce_inside_untl psi E F p)
  | .all_past psi => .all_past (abstract_snce_inside_untl psi E F p)
  | .all_future psi => .all_future (abstract_snce_inside_untl psi E F p)
  | .snce psi1 psi2 => .snce (abstract_snce_inside_untl psi1 E F p)
                              (abstract_snce_inside_untl psi2 E F p)
```

---

## The `has_single_S_type` Predicate (Needed New)

Dual of `has_single_U_type` from Hierarchy.lean:

```lean
/-- A formula has single S-type: every snce node has exactly arguments (E, F). -/
def has_single_S_type (phi E F : Formula) : Prop :=
  match phi with
  | .atom _ => True
  | .bot => True
  | .imp psi1 psi2 => has_single_S_type psi1 E F ∧ has_single_S_type psi2 E F
  | .box psi => has_single_S_type psi E F
  | .all_past psi => has_single_S_type psi E F
  | .all_future psi => has_single_S_type psi E F
  | .untl psi1 psi2 => has_single_S_type psi1 E F ∧ has_single_S_type psi2 E F
  | .snce psi1 psi2 => psi1 = E ∧ psi2 = F
```

---

## Implementation Order

The following order respects dependencies and avoids circularity:

### Step 1: Add `has_single_S_type` predicate and `abstract_snce` to Hierarchy.lean

Both are syntactic/definition-level and have no circular dependencies.

**Files**: `Hierarchy.lean` (new definitions after `abstract_untl`)
**LOC**: ~50 LOC for `has_single_S_type` and its helpers + ~120 LOC for `abstract_snce`
**Dependencies**: `Defs.lean` (is_S_free, is_U_free), `FormulaOps.lean` (subst_formula)

### Step 2: Prove `abstract_snce` semantic and syntactic properties in Hierarchy.lean

These follow the exact same structure as the existing `abstract_untl_correct`, `abstract_subst_roundtrip`, etc.

**LOC**: ~150 LOC
**Dependencies**: Step 1

### Step 3: Define `abstract_snce_inside_untl` and prove it makes `no_S_nested_in_U`

This is the key operation for Lemma 10.2.8.

**Files**: `Hierarchy.lean` or new `AbstractionOps.lean`
**LOC**: ~80 LOC
**Dependencies**: Steps 1-2

### Step 4: Prove `snce_single_U_type_separable` (new) in Hierarchy.lean

This is the induction on `S_nesting_above_U` for the single-U case. It replaces the circular `snce_separable` call in `single_U_formula_separable`.

**Exact new theorem**:
```lean
theorem snce_single_U_type_separable (phi psi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_phi : has_single_U_type phi A B)
    (h_psi : has_single_U_type psi A B) :
    is_separable (.snce phi psi) := by
  -- Induction on S_nesting_above_U (.snce phi psi)
  -- Use lemma_10_2_4 at each step after abstracting U(A,B)
  ...
```

**LOC**: ~100 LOC
**Dependencies**: Steps 1-3, `lemma_10_2_4` from NormalForm.lean, `abstract_untl` from Hierarchy.lean

### Step 5: Prove `multi_U_formula_separable` (proper proof, replacing shortcut) in Hierarchy.lean

This replaces `all_separable phi` on line 596 with the actual count induction.

**LOC**: ~230 LOC
**Dependencies**: Step 4, `count_U_subformulas` (Defs.lean), `fresh_atom` (FormulaOps.lean)

### Step 6: Prove `no_S_nested_in_U_separable` (Lemma 10.2.7) using Lemma 10.2.6

```lean
theorem no_S_nested_in_U_separable (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi := by
  -- Induction on U_depth_under_S phi
  -- Base: calls multi_U_formula_separable (Step 5)
  -- Step: abstract inner U's, apply base, resubstitute, apply IH
  ...
```

**LOC**: ~100 LOC
**Dependencies**: Step 5

### Step 7: Prove `all_separable_no_axioms` (Lemma 10.2.8) in Hierarchy.lean

The master theorem using junction depth induction.

```lean
theorem all_separable_no_axioms (phi : Formula) : is_separable phi := by
  -- Strong induction on junction_depth (expand_temporal phi)
  -- Base n=0: expanded_jd_zero_imp_separated
  -- Base n=1: no_S_nested_in_U_separable
  -- Step n>=2: abstract_snce_inside_untl, no_S_nested_in_U_separable (Step 6), IH
  ...
```

**LOC**: ~250 LOC
**Dependencies**: Steps 1-6, `expand_temporal` (TemporalClosure.lean), `junction_depth` (Defs.lean)

### Step 8: Derive temporal closure theorems and replace axioms in SeparationThm.lean

Once `all_separable_no_axioms` is proved in Hierarchy.lean (or wherever it ends up), SeparationThm.lean can import it and derive:

```lean
-- Replace: axiom all_past_separable (phi) (h : is_separable phi) : is_separable (.all_past phi)
-- With:
theorem all_past_separable (phi : Formula) (h : is_separable phi) :
    is_separable (.all_past phi) := by
  obtain ⟨phi', hphi'_sep, hphi'_equiv⟩ := h
  have : is_separable (.all_past phi') := all_separable_no_axioms (.all_past phi')
  exact is_separable_of_equiv (all_past_congr hphi'_equiv) this
-- (~20 LOC each, 80 LOC total for 4 theorems)

-- Similarly for all_future_separable, untl_separable, snce_separable
-- (each follows directly from all_separable_no_axioms)
```

**LOC**: ~80 LOC for the 4 theorem replacements.

---

## How `all_past`/`all_future` (Primitive Constructors) Are Handled

This is the subtle divergence from GHR94 (where G,H are derived). Here is the exact handling:

**In the junction_depth induction** (Step 7), after applying `expand_temporal`, there are NO `all_past`/`all_future` nodes (by `expand_has_no_allpast_allfuture`). So the induction operates purely on `{atom, bot, imp, untl, snce, box}`.

**For `all_past_separable`** (Step 8): Given `is_separable phi` (phi has a separated equivalent phi'), we need `is_separable (.all_past phi)`.
- `all_past phi` is equivalent to `all_past phi'` (by congruence).
- `all_past phi'` is just a formula: apply `all_separable_no_axioms (.all_past phi')`.
- Since `all_separable_no_axioms` proves ALL formulas separable (including `all_past` ones), this works.

The key is that `all_past phi'` after `expand_temporal` becomes `neg(snce(neg phi')(top))`, which has junction_depth = junction_depth of phi' + 1 (since we introduced an S wrapping). But since phi' is separated and has low junction depth, the overall depth is small enough that the induction base cases handle it.

**Concretely**: If phi' is syntactically separated (junction_depth 0 or 1), then:
- `all_past phi'` after expand_temporal = `neg(snce(neg(expand phi'))(top))`
- `expand phi'` is also syntactically separated (or close to it)
- `snce(neg(expand phi'))(top)` has junction_depth determined by whether `expand phi'` contains untl
- If phi' is truly separated and U-free in its snce-args, then `expand phi'` is separated too
- So the junction_depth of the expanded all_past is at most 1 (S wrapping a U-free inner part)
- This falls in the base case n=1 of the junction depth induction

---

## Where `neg_until_equiv` Is Used Within the Induction

`neg_until_equiv` is used in TWO places within the hierarchy:

1. **In Lemma 10.2.2 / Cases 2,4** (already in Eliminations.lean): Converting `not U(A,B)` to `G(not A) ∨ U(not A ∧ not B, not A)` within Cases 2 and 4. This is already proved and implemented.

2. **Within `snce_single_U_type_separable` (Step 4)**: When proving the induction step for the S-nesting depth, after abstracting U(A,B) to atom p, the resulting formula is U-free and we can apply `lemma_10_2_4`. But some patterns in `lemma_10_2_4` (Cases 5-8) may require the guard to be in a specific form. If the guard phi' contains U-like patterns (from the `neg_until_equiv` decomposition of `not U(A,B)` in Case 2), we need to know those decompositions produce formulas with S-nesting strictly less than the current level.

3. **In the junction_depth induction step** (Step 7): When applying `no_S_nested_in_U_separable` (Step 6) to D', the formula D' has `no_S_nested_in_U` after S-abstracting. But D' may contain `neg U(A,B)` patterns. When Lemma 10.2.7/10.2.6/10.2.5/10.2.4 eventually reach Case 2, they use `neg_until_equiv` to convert `neg U(A,B)` into `G(neg A) ∨ U(neg A ∧ neg B, neg A)`. This introduces a `G(neg A) = all_future(neg A)` which, after `expand_temporal`, becomes `neg U(neg A, top)`. This is fine -- it's a new U-formula, but it appears at the TOP LEVEL (not under S), so it doesn't increase the junction depth.

---

## The Compound Measure in Precise Terms

The induction that eliminates ALL 8 axioms requires this well-founded measure:

```
(junction_depth (expand_temporal phi),
 count_U_subformulas (expand_temporal phi),  -- for Lemma 10.2.6
 S_nesting_above_U (expand_temporal phi))     -- for Lemma 10.2.5
```

This is a lexicographic triple on `(ℕ, ℕ, ℕ)`.

The OUTER recursion (Lemma 10.2.8, Step 7) uses ONLY the first component `junction_depth`. It calls Steps 5-6 which use the other components. When the recursive IH call is made (after resubstituting the S-formulas), the junction_depth has decreased by at least 2.

The MIDDLE recursion (Lemma 10.2.6, Step 5) uses the second component `count_U_subformulas`. It calls Step 4 which uses the third component. When the recursive IH is made (after substituting back U(A_i,B_i) for atoms q_i), the count_U has decreased by 1 (one fewer U-type).

The INNER recursion (Lemma 10.2.5 via Step 4) uses the third component `S_nesting_above_U`. It calls `lemma_10_2_4` (NormalForm.lean) which is non-recursive.

**In Lean**: These three levels of recursion do NOT need to be combined into a single well-founded recursion. They can be three separate theorems (Steps 4, 5, 7) with separate `induction ... using Nat.strong_rec_on` or `termination_by` clauses. The composition is: Step 7 calls Step 6, which calls Step 5, which calls Step 4 (which is already proved). No circularity because the dependencies are strictly forward.

**The critical correctness argument** for the count measure in Step 5: when substituting U(A_n,B_n) for q_n (the abstract atom) in the separated E', the resulting formula's `count_U_subformulas` for the snce-parts is bounded by (n-1). This needs a supporting lemma:

```lean
theorem subst_U_count_bound (phi : Formula) (p : Atom) (A B : Formula) 
    (h_phi_atom_count : count_U_subformulas phi = 0)  -- phi has p but no U
    (h_AB_count : count_U_subformulas (.untl A B) = 1) :  -- trivially 1
    count_U_subformulas (subst_formula phi p (.untl A B)) 
      ≤ phi.atoms.count p  -- at most as many U's as p-occurrences
```

This is needed to show that after substituting U(A_n,B_n) for q_n in the U-free snce-parts of E', we get at most as many U-instances as there are q_n-atoms in E'. And since each such U-instance is U(A_n,B_n) (count 1), the total count is bounded by the number of q_n occurrences.

---

## Confidence Level

**High confidence** (confirmed by 4 prior teammates + literature):
- The 3-level compound measure is correct and sufficient
- `abstract_snce` is the missing infrastructure piece
- Steps 1-8 constitute a complete, non-circular proof
- The `all_past`/`all_future` primitive constructor issue is handled by `expand_temporal` + `expanded_jd_zero_imp_separated`

**Medium confidence** (technical details to verify in Lean):
- The exact form of `subst_U_count_bound` and whether Lean's `count p` on `Finset Atom` tracks this correctly
- Whether `S_nesting_above_U` as defined in Defs.lean correctly measures the inner recursion depth (need to verify the `S_nesting_above_U_inner` helper accurately tracks depth under multiple nested S's)
- Whether `abstract_snce_inside_untl` (the restricted abstraction that only works inside `untl` nodes) is really the right operation, or whether a simpler global `abstract_snce` suffices when combined with the junction_depth outer induction

**Lower confidence** (potential pitfalls):
- The LOC estimates could be off by 30-40% in either direction; the semantic correctness proofs tend to be larger than expected
- The resubstitution step in Lemma 10.2.8 (Step 7) -- specifically proving that the parts of E' that contain z_ij after substitution have junction_depth at most n-2 -- requires careful tracking of where the atoms z_ij appear in E'. If z_ij appears in a `untl`-context in E' (pure future part), resubstituting `snce(E,F)` creates a `snce-inside-untl` junction, increasing the local JD. But the absolute junction_depth of this subterm is bounded by (depth of snce(E,F)) + 1 <= (n-2) + 1 = n-1 < n. The IH handles this.

---

## Summary of What Already Exists vs. Needs Writing

| Component | Status | LOC |
|-----------|--------|-----|
| `has_single_U_type` predicate | EXISTS | 0 |
| `abstract_untl` + properties | EXISTS | ~400 |
| `has_single_S_type` predicate | MISSING | ~50 |
| `abstract_snce` function | MISSING | ~60 |
| `abstract_snce` semantic/syntactic properties | MISSING | ~150 |
| `abstract_snce_inside_untl` | MISSING | ~80 |
| `snce_single_U_type_separable` (Step 4) | MISSING | ~100 |
| `multi_U_formula_separable` proper proof (Step 5) | SHORTCUT (needs rewriting) | ~230 |
| `no_S_nested_in_U_separable` proper proof (Step 6) | SHORTCUT (needs rewriting) | ~100 |
| `all_separable_no_axioms` junction-depth induction (Step 7) | MISSING | ~250 |
| Temporal closure theorem replacements (Step 8) | AXIOMS (needs replacing) | ~80 |
| `subst_U_count_bound` and count lemmas | MISSING | ~80 |
| **Total new LOC** | | **~1180** |

The existing `abstract_untl` code (~400 LOC) provides the template for `abstract_snce`. The proofs are structurally identical (S/U swapped). An experienced Lean implementer can adapt `abstract_untl` to `abstract_snce` in ~2 hours.

The most intellectually difficult part is Step 7 (the junction depth induction with resubstitution), estimated at ~4-6 hours of careful Lean proof engineering.
