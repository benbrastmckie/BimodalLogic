# Task 325 v2 — Phase 1 Implementation Summary

- **Task**: 325 — redesign_k2_subbracket_to_vvecea2_arrangementdisjunction
- **Plan**: plans/02_vvecea2-carrier-v2-nine-zone-gate.md (Phase 1 of 4)
- **Session**: sess_1783441118_6b8bfa
- **Status**: Phase 1 [COMPLETED]; Phases 2-4 remain (task partial)

## What landed

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`.

### Carrier amendment (in place, same names — plan Naming Decision)
- Added the two interior WITNESS SELF-ZONES to `kvE_subBracket2V`: `zAtX1 := mk4 eqz ltz gtz ltz`
  (`v = x1`) and `zAtW := mk4 gtz eqz gtz ltz` (`v = w`).
- Extended the gate `consistent` set from SEVEN to NINE zones (inserted `zAtX1`, `zAtW`).
- Folded each witness self-zone's 1-type literals into the witness point types (arity-4 analog of
  k1v `hptW` :3277): `ptX1 = ⟨conjList (charK (nfk_projFresh σ) :: allTypes.map (lit (bits zAtX1) charBase))⟩`,
  `ptW = ⟨conjList (charBase (proj 1) :: allTypes.map (lit (bits zAtW) charBase))⟩`. Amendment F3
  preserved (zone-literal fold on the complete 1-type, not a provider equation).
- `kvE_subChain2V` left byte-identical (dead accessor consumed by nothing; elaborates unchanged).

### Downstream green-keeping (fix-forward, conclusion byte-identical)
- `kvE_subBracket2V_extract` now projects the folded `ptX1` head via `formula_conjList_iff` +
  `List.mem_cons_self`, so its conclusion (`⟨charK (nfk_projFresh σ)⟩.eval_at`) is unchanged. The
  entire downstream `_reaches_z*`/`_fold_z*`/`kvE_subBracket2V_sound` chain is therefore untouched
  and still compiles.

### The mandatory NON-VACUITY GATE (hard exit criterion — driven closed)
- `kvE_sub2V_zone_consistent` (private): arity-4 9-zone realizability — any zone realized by a point
  over the honest env `[x1,w,x,t]` under `x < x1 < w < t` is one of the nine consistent zones
  (analog of `k1v_zone_consistent` :2065).
- `kvE_subBracket2V_gate_holds_of_honest`: honest σ ⟹ the corrected nine-zone gate (both conjuncts).
  Off-fiber = the fold's own off-fiber clause; inconsistent-zone falsity via the realizability
  contrapositive. Flips the removed v1 `gate_unsat` probe to provable.
- `kvE_subBracket2V_nonvacuous`: honest σ ⟹ `(kvE_subBracket2V …).disjuncts ≠ []`. Reduces the
  carrier's `dite` gate to its true branch and shows the arrangement `flatMap` non-empty via
  `List.mem_permutations.mpr (List.Perm.refl _)`. Refutes the removed v1 `never_holds` probe.

## Verification

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`: GREEN.
- `lean_verify` on `kvE_subBracket2V_gate_holds_of_honest` and `kvE_subBracket2V_nonvacuous`:
  axioms = `{propext, Classical.choice, Quot.sound}` (clean).
- No `sorry` on any new/amended live path (all 42 "sorry" tokens in the file are prose; no
  `declaration uses 'sorry'` compiler warning for this module).
- Forbidden-tactic grep clean on new blocks (`by omega` only for Fin-index typing; `simp only
  [Fin.cons]`/`[kvE_subBracket2V]` are index-reduction / def-unfolding, not chain shortcuts).
- PRIOR do-not-edit ranges byte-identical (all diff hunks start at line ≥ 6797, inside task 325's
  own :6779+ block); SURVIVE task-325 kit (`bracketFromLists3`, `k1v_sorted_realization3`,
  `k1v_bracket_construct3`, `bracketFromLists3_extract`) unedited.

## Plan deviations

- The `kvE_subBracket2V_extract` anchor-projection fix (nominally Phase-2 RE-DRIVE territory) was
  pulled into Phase 1 to keep the build green after the `ptX1` fold, per the binding "build green at
  every commit" constraint. Its conclusion is byte-identical, so no Phase-2 obligation is consumed
  (the RE-DRIVE chain still compiles and Phase 2 only needs to confirm non-vacuous closure).

## Commits

- `be865449c` — task 325 v2 phase 1.1: nine-zone gate + witness self-type fold (ptX1/ptW)
- `72c34be83` — task 325 v2 phase 1: nine-zone-gate carrier + witness self-type fold + non-vacuity gate

## Next

Phase 2 (soundness re-driven non-vacuously) and Phase 3 (completeness) are now unblocked — the
NON-VACUITY GATE is green.
