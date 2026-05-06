# Handoff: Sorry #3 Closed (BurgessR3Maximal First-Conjunct Fix)

## Summary

Sorry #3 (PI:3619) is CLOSED. The degenerate case in `lemma_2_7` where the guard formula xi is inconsistent is now handled by setting B' = Set.univ.

## Changes Made

### 1. ChronicleTypes.lean: Definition Change
- `BurgessR3Maximal` first conjunct changed from `SetDeductivelyClosed B` to `ClosedUnderDerivation B`
- This matches Burgess 1982 exactly: his "deductively closed set" (DCS) is closed under derivation with NO consistency requirement
- Updated docstring to explain the rationale

### 2. RRelation.lean: Zorn Proof + Accessor
- `burgessR3Maximal_extension_exists` return type now includes `SetDeductivelyClosed B`:
  `∃ B, S ⊆ B ∧ SetDeductivelyClosed B ∧ BurgessR3Maximal A B C`
  This exposes the SDC fact from the Zorn construction to callers that need consistency.
- Proof tuple construction uses `hB_dcs.2` (CUD from SDC) for the BurgessR3Maximal component
- `BurgessR3Maximal_dcs'` renamed to `BurgessR3Maximal_cud`, returns `ClosedUnderDerivation B`
- `burgessR3Maximal_exists_from_seed` caller updated to destructure new tuple

### 3. PointInsertion.lean: Cascade Fixes

**Parameter additions** (added `h_B_dcs : SetDeductivelyClosed B`):
- `burgess_D0_finite_subset_consistent`
- `burgess_D0_finite_subset_consistent_incons`
- `burgess_D0_seed_consistent`
- `lemma_2_6_splitting`
- `lemma_2_7_seed_consistent`
- `lemma_2_7`

**Signature change**:
- `neg_mem_of_inconsistent_union`: changed from `h_dcs : SetDeductivelyClosed B` to `h_cud : ClosedUnderDerivation B` (only uses CUD internally)
- Callers at lines 2610, 2635 updated to pass `.2` from SDC

**Reference fixes**:
- All `h_r3m.1` uses that expected SDC now use the new `h_B_dcs` parameter
- `dcs_contains_theorems h_r3m.1` changed to `cud_contains_theorems h_r3m.1`
- Zorn call sites updated to destructure the new 4-element tuple `⟨B, _, _, h_max⟩`
- Zorn seed arguments changed from `h_r3m.1` to `h_B_dcs`

**Sorry #3 closure** (lines 3610-3693):
When {xi} is inconsistent:
- B' = Set.univ (trivially CUD, burgessR3 holds since every φ is a consequence of xi, maximality is vacuous)
- burgessR3(A, Set.univ, D) proved by showing `⊢ xi → φ` for all φ (xi is inconsistent so DerivationTree [] xi.neg, then ex falso), then applying untl/snce left monotonicity
- BurgessR3Maximal(A, Set.univ, D) constructed directly (no Zorn needed)
- B'' still from Zorn with seed B (using h_B_dcs)
- xi ∈ Set.univ trivially

## Remaining Sorries

In PointInsertion.lean, 6 sorries remain (all NoUnivBurgessR3 stubs):
- Line 178: initial Zorn call
- Lines 2717, 2719: lemma_2_6_splitting
- Lines 3596, 3598: lemma_2_7 consistent case
- Line 3686: lemma_2_7 inconsistent case (new, for B'' Zorn)

These are all of the form `¬burgessR3 A Set.univ C` or `¬burgessR3 D Set.univ C`, to be threaded from the chronicle construction.

## Build Status
- `lake build`: passes (1097 jobs)
- New axioms: 0 (still 4 total, unchanged)
- Target sorry: CLOSED

## Burgess Alignment Analysis

The current formalization now aligns more closely with Burgess 1982 in several ways, but there are remaining divergences that could benefit from a clean-break refactor.

### Current Alignment

1. **BurgessR3Maximal definition**: Now uses `ClosedUnderDerivation B` (matching Burgess's "deductively closed set" which has no consistency requirement), with CUD-maximality (matching Burgess who maximizes over ALL deductively closed extensions, not just consistent ones).

2. **Lemma 2.7 inconsistent guard**: Now handled correctly. Burgess's proof implicitly uses DC({xi}) = Set.univ when xi is inconsistent, and Set.univ is a valid DCS in his framework.

### Remaining Divergences from Burgess

1. **`SetDeductivelyClosed` parameter threading**: The current approach threads `h_B_dcs : SetDeductivelyClosed B` as a separate parameter alongside `BurgessR3Maximal`. This is a pragmatic choice to minimize cascade changes. A cleaner Burgess-faithful approach would:
   - Remove `SetDeductivelyClosed` from the helper infrastructure entirely
   - Change ALL helper functions (`list_conj_mem_dcs`, `d0_guard`, `collect_guards`, `l27_guard`, `l27_collect_guards`, `dc_delta_B_controlled`, etc.) from `h_dcs : SetDeductivelyClosed B` to `h_cud : ClosedUnderDerivation B`
   - Replace `dcs_contains_theorems`, `dcs_conj_closed`, `dcs_modus_ponens` calls with `cud_contains_theorems`, `cud_conj_closed`, `cud_modus_ponens` (already defined in ChronicleTypes.lean)
   - Where `SetConsistent B` is genuinely needed (e.g., `dcs_neg_union_consistent` at line 449 which uses both), derive it from context rather than from BurgessR3Maximal

2. **NoUnivBurgessR3**: Burgess doesn't need this hypothesis explicitly. In his framework, the Zorn construction over SDC (consistent + CUD) sets automatically excludes Set.univ. The CUD-maximality upgrade (from SDC-max to CUD-max) then follows from the argument: if D is CUD and B ⊂ D, either D is consistent (handled by SDC-Zorn-max) or D is inconsistent (D = Set.univ, excluded by NoUnivBurgessR3). This is correct but the NoUnivBurgessR3 hypothesis needs to be established from the chronicle construction context.

3. **`R3Maximal` vs `BurgessR3Maximal`**: The codebase has TWO maximality definitions:
   - `R3Maximal` (used for the interval function g): maximality over `SetDeductivelyClosed` with `r3Relation` (a different, simpler r-relation)
   - `BurgessR3Maximal` (used for point insertion lemmas 2.4-2.7): maximality over `ClosedUnderDerivation` with `burgessR3` (the full Burgess content-based r-relation)

   Burgess has only ONE definition. A clean refactor would unify these or clearly document why they differ.

### Recommended Clean-Break Refactor (Future Task)

If maximum alignment with Burgess is desired:

**Phase 1: CUD-ify the helper infrastructure** (~20 function signatures)
- Change `d0_guard`, `collect_guards`, `list_conj_mem_dcs`, `dc_delta_B_controlled`, and all their l27_ variants from `SetDeductivelyClosed` to `ClosedUnderDerivation`
- Add a `list_conj_mem_cud` function (or rename `list_conj_mem_dcs`)
- This is a large but mechanical refactor (each function only uses CUD internally)

**Phase 2: Remove h_B_dcs parameter threading**
- Remove the `h_B_dcs : SetDeductivelyClosed B` parameters added in this session
- In the ~3 places where `SetConsistent B` is genuinely needed (e.g., `burgess_D0_finite_subset_consistent_incons` line 1910 for β ∉ B derivation), derive it from the Zorn output or add it as a targeted hypothesis

**Phase 3: Resolve NoUnivBurgessR3**
- Prove `¬burgessR3 A Set.univ C` from the chronicle construction context
- This would close the 6 remaining NoUnivBurgessR3 sorry stubs
- Burgess's argument: in a valid chronicle, every MCS A is satisfiable at some point, so burgessR3(A, Set.univ, C) would require every formula to hold at intermediate points, which contradicts consistency of A

**Phase 4: Unify R3Maximal and BurgessR3Maximal** (optional)
- Determine if `R3Maximal` can be subsumed by `BurgessR3Maximal` or vice versa
- If not, document the distinction clearly

Each phase is independently valuable and builds on the previous.
