# Handoff: Sorry #2 Plumbing and Sorry #3 First-Conjunct Fix

Session: sess_1778014444_dca927
Task: 107
Status: PARTIAL - analysis complete, implementation needs interactive debugging

## Sorry #2 (PI:2941): List Extraction Plumbing

### Mathematical Structure (PROVEN)
The `h_key` helper (lines 2921-3017 in PointInsertion.lean) is fully proved. It produces:
- Given b in B, gamma_hat in C, alpha_list in A
- An `event` with: F(event) in A, event -> b, event -> eta, event -> untl(b, gamma_hat),
  event -> snce(b and (xi and untl(xi,eta)), alpha) for each alpha in alpha_list

### What Remains
The sorry at line 2941 needs to:
1. Build `b_list` (B-guards from L), `c_list` (C-events), `a_list` (A-events)
2. Form `b = list_conj(beta0 :: b_list)` in B, `gamma_hat = list_conj(gamma0 :: c_list)` in C
3. Apply `h_key` to get `event`
4. Show `event` implies each phi in L (5-way case split on seed membership)
5. Derive contradiction via `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false`

### Key Technical Challenge
The `lemma_2_7_seed` has 5 components (vs 4 for `burgess_D0_seed`):
1. phi in B
2. phi = eta
3. phi = untl(beta', gamma') with beta' in B, gamma' in C
4. phi = snce(beta', alpha') with beta' in B, alpha' in A
5. phi = snce(beta' and xi, alpha') with beta' in B, alpha' in A

The existing extractors (`collect_guards`, `d0_c_event_list`, `d0_a_event_list`) only handle 4 components. New extractors are needed for component 5.

### Critical Issue: Classical.choose Tracking
When using `Classical.choose` to extract witnesses from existentials, two different proofs of the same proposition produce different `Classical.choose` values. This makes it impossible to track that:
- The B-guard extracted by `filterMap` for `untl(beta', gamma')` equals `beta'` (by injectivity)
- The C-event extracted by `filterMap` for `untl(beta', gamma')` equals `gamma'` (by injectivity)

### Recommended Approach
Define proper extractors OUTSIDE the proof as `private noncomputable def`s (following the pattern of `collect_guards` at line 1508):

```
private noncomputable def l27_collect_guards {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (xi : Formula) :
    (L : List Formula) ->
    (hL : forall phi in L, phi in lemma_2_7_seed A B C xi eta) ->
    { gs : List Formula // forall g in gs, g in B }
```

With property theorems:
- `l27_collect_guards_mem_of_B`: if phi in L and phi in B, then phi in guards
- `l27_collect_guards_mem_of_untl`: if untl(beta', gamma') in L, then beta' in guards
- `l27_collect_guards_mem_of_snce`: if snce(beta', alpha') in L, then beta' in guards
- `l27_collect_guards_mem_of_snce_xi`: if snce(beta' and xi, alpha') in L, then beta' in guards

Similarly for c_event_list and a_event_list.

### Alternative Approach (attempted)
Using `Classical.choice` to wrap the case analysis in `Nonempty` (Prop):
```lean
have h_event_implies_L : forall phi in L, DerivationTree [event] phi := by
  intro phi hphi
  apply Classical.choice
  -- Now in Prop, obtain works for existential destruction
  ...
```
This avoids the `Exists.casesOn` universe issue (DerivationTree is in Type, not Prop).

The `b_of_seed` function was defined as:
```lean
classical
let b_of_seed : Formula -> Formula := fun phi =>
  if phi in B then phi
  else if h : exists beta' in B, exists gamma in C, phi = Formula.untl beta' gamma then
    Classical.choose h
  ...
```

The issues encountered:
1. `List.mem_map_of_mem b_of_seed hphi` fails with "Application type mismatch" because `b_of_seed` defined via `classical` doesn't match the expected function type
2. `simp only [b_of_seed, h_B_case]` fails to simplify `dite` from `classical` blocks
3. `h_guard_eq triangleq h_b_to_guard` substitution fails in Type contexts

### Suggested Fix
Use `split` instead of `simp` for all `dite` simplification. Use tactic-mode `by` blocks instead of term-mode for all type-sensitive operations. Define `b_of_seed` as a proper `private noncomputable def` outside the proof.

## Sorry #3 (PI:3156): First-Conjunct Fix

### The Problem
When xi is inconsistent (like p and not p), no consistent `SetDeductivelyClosed` set can contain xi. The current `BurgessR3Maximal` definition requires `SetDeductivelyClosed B` (= `SetConsistent B and ClosedUnderDerivation B`) as first conjunct.

### The Fix (from task description)
Change BurgessR3Maximal first conjunct from `SetDeductivelyClosed B` to `ClosedUnderDerivation B`:

File: ChronicleTypes.lean line 326
```lean
-- Current:
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B and burgessR3 A B C and ...

-- Change to:
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  ClosedUnderDerivation B and burgessR3 A B C and ...
```

### Cascade Analysis
All callers of:
- `h_r3m.1` (extracts first conjunct, currently `SetDeductivelyClosed B`)
- `BurgessR3Maximal_dcs'` (accessor returning first conjunct)
- `h_B_dcs : SetDeductivelyClosed B := h_r3m.1`

Need to be updated to use `ClosedUnderDerivation B` instead.

Key files:
- ChronicleTypes.lean:326 - definition
- RRelation.lean:761 - Zorn proof (`burgessR3Maximal_extension_exists`)
- RRelation.lean:808 - accessor (`BurgessR3Maximal_dcs'`)
- PointInsertion.lean - all uses of `h_r3m.1` and `h_B_dcs`

### When xi is inconsistent
With `ClosedUnderDerivation B` (no consistency requirement):
- B' can be Set.univ (which IS ClosedUnderDerivation)
- `set_univ_closed_under_derivation` (PI:~671) proves Set.univ is CUD
- `closedUnderDerivation_inconsistent_is_univ` (RRelation:~729) proves inconsistent CUD = Set.univ

The sorry at line 3156 can then be closed by using Set.univ as B' when xi is inconsistent.

## Implementation Order
1. Close sorry #2 (define extractors, write plumbing proof)
2. Verify build
3. Change BurgessR3Maximal definition (sorry #3 prerequisite)
4. Fix cascade
5. Close sorry #3
6. Verify build

## File Paths
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
