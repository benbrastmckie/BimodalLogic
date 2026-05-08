# Phase 7 Handoff: CUD C1 Change Progress

## Session
- Session ID: sess_1778221275_3b41e2
- Agent: lean-implementation-agent
- Date: 2026-05-08

## Summary

Significant progress on Phase 7 (Approach A: allow CUD interval sets). The core architectural changes are complete but downstream proof fixups remain.

## Completed Changes

### 1. C1 Definition Changed (ChronicleTypes.lean)
```lean
-- BEFORE:
def Chronicle.c1 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y → SetDeductivelyClosed (χ.g x y)

-- AFTER:
def Chronicle.c1 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y → ClosedUnderDerivation (χ.g x y)
```

### 2. NoUnivBurgessR3 Definition Deleted (ChronicleTypes.lean)
The definition and its documentation removed entirely.

### 3. Zorn Family Changed to CUD (RRelation.lean)
```lean
-- BEFORE:
def burgessR3DCSExtensions (A S C : Set Formula) : Set (Set Formula) :=
  {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ burgessR3 A B C}

-- AFTER:
def burgessR3DCSExtensions (A S C : Set Formula) : Set (Set Formula) :=
  {B | S ⊆ B ∧ ClosedUnderDerivation B ∧ burgessR3 A B C}
```

### 4. burgessR3Maximal_extension_exists Simplified (RRelation.lean)
- Removed `h_no_univ` parameter
- Changed seed requirement from `SetDeductivelyClosed S` to `ClosedUnderDerivation S`
- Removed the SDC→CUD upgrade step (direct CUD Zorn now)
- Chain union proof simplified (only needs CUD, not consistency)

### 5. burgessR3Maximal_with_guard Simplified (RRelation.lean)
- Removed `h_nubr3 : NoUnivBurgessR3` parameter
- Removed entire 70-line consistency proof (no longer needed)
- Seed is `deductiveClosure_closed_under_derivation` (always CUD)

### 6. All h_nubr3 Parameters Removed (7 files)
Mechanical removal from all function signatures and call sites:
- ChronicleTypes.lean: 1 definition deleted
- RRelation.lean: 3 functions updated
- PointInsertion.lean: 10 functions updated
- CounterexampleElimination.lean: ~57 references removed
- ChronicleConstruction.lean: ~413 references removed
- ChronicleToCountermodel.lean: ~233 references removed
- Completeness.lean: bx_completeness now unconditional

### 7. Helper Lemma Added (ChronicleTypes.lean)
```lean
theorem cud_not_mem_is_sdc {B : Set Formula} (h_cud : ClosedUnderDerivation B)
    {φ : Formula} (h_not_mem : φ ∉ B) : SetDeductivelyClosed B
```

### 8. BurgessR3Maximal_sdc Restructured (CounterexampleElimination.lean)
Changed from taking `NoUnivBurgessR3` to taking `φ ∉ B`:
```lean
theorem BurgessR3Maximal_sdc {A B C : Set Formula}
    (h_r3m : BurgessR3Maximal A B C)
    {φ : Formula} (h_not_mem : φ ∉ B) :
    SetDeductivelyClosed B :=
  cud_not_mem_is_sdc h_r3m.1 h_not_mem
```

### 9. Splitting Lemma Parameter Change (PointInsertion.lean)
Changed 12 function signatures:
```lean
-- BEFORE: (h_B_dcs : SetDeductivelyClosed B)
-- AFTER:  (h_B_dcs : ClosedUnderDerivation B)
```

## Remaining Work (~63 build errors)

### Category 1: collect_guards infrastructure (lines 1800-2500)
Functions `collect_guards_mem_of_B`, `collect_guards_mem_of_untl`, `collect_guards_mem_of_snce`
still pass `h_dcs` where `SetDeductivelyClosed` is expected internally. Fix: continue
the SDC→CUD migration for helper functions or add type annotations.

### Category 2: h_B_dcs.1 usage (3 places)
Places that extract `SetConsistent B` from what is now `ClosedUnderDerivation B`:
- Line 2035: `burgess_D0_finite_subset_consistent_incons` -- derives β ∉ B from β.neg ∈ B + consistency
  - Fix: The CALLER has `h_β_not_B : β ∉ B`. Pass it as parameter.
- Line 2249: `h_mcs_B` check
  - Fix: Derive from `cud_not_mem_is_sdc h_B_dcs <some_not_in_B>`
- Line 2767: `SetConsistent_of_subset ... h_B_dcs.1`
  - Fix: Use `(cud_not_mem_is_sdc h_B_dcs h_β_not_B).1`

### Category 3: CounterexampleElimination BurgessR3Maximal_sdc calls (7 places)
Each needs a formula φ ∉ B to provide to the new `BurgessR3Maximal_sdc`:
- Forward walk (line 882): Use `Formula.bot` (prove ⊥ ∉ g from h_no_wit context)
  OR move h_B_sdc into not-condition-(i) branch and use the available ξ ∉ g / η ∉ g / etc.
- Backward walk (line 1453): Mirror of forward
- n=0 cases and other splitting contexts: Each has an available formula ∉ g

### Strategy for Remaining Fixes

The cleanest approach for Category 3:
1. Remove the upfront `h_B_sdc` derivation (before the condition-(i) case split)
2. In the NOT-condition-(i) branch, derive `h_B_sdc` case-by-case:
   - If `ξ ∉ g`: `h_B_sdc := cud_not_mem_is_sdc h_r3m_adj.1 h_xi_g`
   - If `ξ ∈ g` but `η ∉ g`: `h_B_sdc := cud_not_mem_is_sdc h_r3m_adj.1 h_eta_g`
   - If `ξ ∈ g` and `η ∈ g`: derive `η.neg ∉ g` from CUD + context, then use that
3. The "dead code" `h_bot_not_g` can be deleted (it's never used)

For the η ∈ g AND ξ ∈ g sub-case: η.neg ∉ g follows from:
- If η.neg ∈ g: by CUD modus ponens (η, η→⊥), ⊥ ∈ g. By ex falso, g = Set.univ.
  Then condition (i) becomes just `conj ∈ f(x')` (since ξ ∈ Set.univ trivially).
  NOT-condition-(i) means conj ∉ f(x'). By BX5: U(ξ,η) → (ξ∧U(ξ,η)) ∨ η.
  Since conj ∉ f(x'), we get η ∈ f(x'). Then x' IS a C5 witness (guard trivial),
  contradicting h_no_wit. So η.neg ∉ g by contradiction.

This argument can be extracted as a lemma `walk_g_consistent` or proved inline.

## Mathematical Correctness

The approach is mathematically sound:
- Burgess 1982 uses DCS = closed under derivation (NOT requiring consistency)
- CUD g-values allow Set.univ at finite stages (vacuous intervals)
- At the limit, g-values converge to intersections of f-values (which ARE consistent MCS)
- The splitting lemmas only run when some formula ∉ g, ensuring g is SDC at that point
- The Zorn construction over CUD sets directly gives CUD-maximality

## File Status

| File | Status |
|------|--------|
| ChronicleTypes.lean | DONE (compiles) |
| RRelation.lean | DONE (compiles) |
| PointInsertion.lean | IN PROGRESS (63 errors from SDC→CUD cascade) |
| CounterexampleElimination.lean | IN PROGRESS (7 BurgessR3Maximal_sdc calls need fixing) |
| ChronicleConstruction.lean | DONE (mechanical h_nubr3 removal) |
| ChronicleToCountermodel.lean | DONE (mechanical h_nubr3 removal) |
| Completeness.lean | DONE (unconditional bx_completeness) |

## Estimated Remaining Effort

- Category 1 (collect_guards): 1-2 hours (mechanical, follow the same SDC→CUD pattern)
- Category 2 (h_B_dcs.1): 30 min (3 places, clear fixes)
- Category 3 (BurgessR3Maximal_sdc): 2-3 hours (needs inline SDC derivation in 7 places)
- Build validation: 30 min

Total: ~4-6 hours
