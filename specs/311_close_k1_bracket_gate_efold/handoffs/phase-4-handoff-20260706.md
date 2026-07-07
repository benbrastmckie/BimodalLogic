# Task 311 Phase 4 Handoff (2026-07-06)

## Immediate Next Action

Phase 5 (Completeness direction RHS→LHS, assembled `↔`, R2 re-probe verdict): state
`private theorem bracketEndChar_k1v_complete` (six k0-mirror order hypotheses). From
`∃ w, nf_eval_nf M 1 3 [w,x,t] qnf`:
1. Derive both gate conjuncts (RHS-derivable): off-fiber from `nf_eval_nf1_iff_efold`
   (NfEFold:490) 2nd conjunct; order-conflict falsity from `k1v_zone_consistent`'s
   contrapositive (Phase 4 already shows: any realized zone over `[w,x,t]` with `x < w < t` is
   one of the seven consistent zones — the fold biconditional then forces inconsistent bits
   false; `nf_depth0_pair_cycle_empty'` not needed).
2. Fold biconditionals per (zone, χ) via `nf_quant_layer_fold_k1_gate` (NfEFold:525) `.mp`.
3. Realizing-point extraction per positive χ ∈ S_L/S_R + distinctness via `nf_eval_unique`
   (NormalForm:245) through `nfPred_correct` (NfToVecEA:69 — use this, NOT KampPrior:168,
   which is OUTSIDE the Bridge import closure).
4. Arrangement selection (Risk R1', rule N5): insertion induction; the disjunct list contains
   ALL `(lL, lR)` arrangements; select via `List.mem_permutations` (import landed Phase 4).
5. Assemble `theorem bracketEndChar_k1v_correct` from `bracketEndChar_k1v_sound` (:2308) + the
   completeness lemma; record the R2 re-probe verdict doc-comment (N3 lead; verdict either way).

## Current State

- Phases 1-4 [COMPLETED]; Phase 5 [NOT STARTED]. Full `lake build` GREEN (1705 jobs).
- Phase 4 diff: ~660 insertions, 0 deletions (4.1 kit commit 425d54d32 + 4.2 theorem).
- New declarations (NfMultiAnchorBridge.lean, all `private`, all axioms exactly
  `[propext, Classical.choice, Quot.sound]`):
  - `k1v_bool_eq_false` (:2016), `k1v_not_of_iff_false` (:2312 region) — Bool/iff micro-helpers
  - `k1v_zoneHolds_cons_iff` (:2026) — zoneHolds over `[w,x,t]` at a `Fin.cons` zone spec ↔
    three coordinate biconditionals
  - `k1v_zone_consistent` (:2044) — any realized zone spec with `x < w < t` is one of the 7
    consistent zones (trichotomy; discharges inconsistent-zone bits both directions)
  - `k1v_bracket_extract` (:2135 region) — bracketFromLists holds ⟹ middle witness `w` at
    position `lL.length`, per-list witness realization strictly inside `(x,w)`/`(w,t)`, and
    the witness-or-segment gap classification (REUSABLE for Phase 5's segment obligations in
    reverse? NO — Phase 5 needs the CONSTRUCTIVE direction: build `IntervalPattern.holds` from
    realized points; mirror `existsBounded_right`'s append construction, VecEAClosure:265)
  - `k1v_reconstruct_nf3` (:2280 region) — private clone of VecEADecomp:407 (that one is
    `private` there); atom layer at `[w,x,t]` from 3 point types + 6 order biconditionals
  - `bracketEndChar_k1v_sound` (:2345 region) — the Phase 4 deliverable

## Key Decisions / Gotchas (READ BEFORE Phase 5)

- **Import added**: `Mathlib.Data.List.Permutation` at file head (for `List.mem_permutations`).
  Additive-only; documented in the plan as a deviation.
- **Destructuring the carrier**: `simp only [bracketEndChar_k1v, VVecEA2.holds] at h` zeta/beta
  inlines all carrier lets; then `obtain`, then `split at hmem` cases the gate dite
  (`case isTrue hg =>` / `case isFalse hg =>`). For Phase 5 (constructing `holds`), instead
  prove the gate Prop first, then `rw [dif_pos]`-style or `simp only [bracketEndChar_k1v,
  VVecEA2.holds]; refine ⟨mkDisjunct-term, mem, ?_⟩` and `split` on the goal.
- **Fin.cons at mk indices does NOT reduce in the unifier**: always
  `simp only [Fin.cons] at h0 h1 h2` (or `simpa only [Fin.cons] using h`) — pattern proven in
  `k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`.
- **`simp [h]` with atom-order hypotheses FAILS**: default simp normalizes `Fin.mk 0/1/2` to
  `OfNat` literals breaking the match; use `simp only [h_yx]; decide` instead.
- **getElem index rewrites fail with motive errors**: never rw an index inside `l[i]'pf`;
  prove the whole-element equality as a `have helem : (lL ++ ptW :: lR)[i]'pf = elem` (via
  `List.getElem_append_right` + `simp only [show idx-arith by omega, List.getElem_cons_succ]`)
  then `rwa [helem] at h`.
- **if-conditions with `Fin.val`-of-mk**: `rw [if_pos hj]`/`if_neg (show ¬(EXPR) by omega)`
  works via defeq; a bare `if_neg (by omega)` fails (omega can't see through `↑⟨e,pf⟩`).
- **Membership extraction from the inlined conjunction lists**: ascribe the target type on the
  `have` (forces the metavariable), then `hepL _ (List.mem_append_left _ List.mem_cons_self)` /
  `(List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp)))`. In this toolchain
  `List.mem_cons_self` and `List.mem_map_of_mem`'s `f` are implicit.
- **efold bridge**: `(efold_of_nf1 qnf).2 (zs, χ) = qnf.2 (nf0_assemble zs χ qnf.1)` is `rfl`;
  bridge via `rw [show ... from rfl]` while `zs` is still a variable (before rcases).
- **List parse**: `a :: l1 ++ l2` parses as `(a :: l1) ++ l2` — epL/epR extraction uses
  `mem_append_left _ List.mem_cons_self` for heads.

## Sorry Inventory

Empty (no task-owned sorries; pre-existing out-of-scope sorries — KampPrior:351/354,
EANegation:1090/1249 and repo-wide non-Kamp files — untouched).
