# Task 311 Phase 3 Handoff (2026-07-06)

## Immediate Next Action

Phase 4 (Soundness direction, LHS→RHS): state
`private theorem bracketEndChar_k1v_sound` with the six k0-mirror bracket-zone order hypotheses
(template: `bracketEndChar_k0_correct`, NfMultiAnchorBridge.lean:1577-1589). From `VVecEA2.holds`
obtain the arrangement disjunct `(lL, lR)`; middle witness is at bracket position `lL.length`
(see `bracketFromLists` :1879 — point types = `lL ++ ptW :: lR` indexed via `getElem`, segment
types = `if i.val ≤ lL.length then segL else segR`). Chain: `nf_eval_nf1_iff_efold` (NfEFold:490)
→ `nf_quant_layer_fold_k1_gate` (NfEFold:525) → `nf_3var_bracket_xyt_correct` (VecEADecomp:244)
→ per-zone matching (plan v3 Phase 4 checklist).

## Current State

- Phase 3 [COMPLETED]; Phases 1-2 [COMPLETED] (untouched); Phases 4-5 [NOT STARTED].
- Full `lake build` GREEN (1705 jobs). Diff: 178 insertions, 0 deletions — additive after :1823.
- New declarations (NfMultiAnchorBridge.lean):
  - `BracketEndCharCarrierV` (abbrev) :1855 — `NormalForm sig k 3 → VVecEA2`
  - `BracketCarrierCorrectV` :1864 — two-anchor `holds ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf`
  - `private def bracketFromLists` :1879 — disjunct builder (Risk R6 factoring)
  - `noncomputable def bracketEndChar_k1v` :1923 — the k=1 V-carrier
- Axioms: `bracketEndChar_k1v`, `BracketCarrierCorrectV` = `[propext, Classical.choice,
  Quot.sound]`; `bracketFromLists` = `[propext, Quot.sound]` (subset).
- Sorry count: 0 new; live Kamp sorries still exactly KampPrior:351/354 (+ EANegation:1090/1249
  documented non-blocking).

## Key Decisions

- Building blocks copied verbatim from `bracketEndChar_k1` (:1676-1739) as local lets; `ptW`
  drops the refuted interior `bracketBuildLeft/Right` chains (rule N4) — interior-positive
  content rides witness slots instead.
- `S_L`/`S_R` = `allTypes.filter (b zXW ·)` / `(b zWT ·)`; disjunct list =
  `S_L.permutations.flatMap fun lL => S_R.permutations.map fun lR => mkDisjunct lL lR` (rule N5).
- `bracketFromLists` uses `getElem` with an `omega` bound proof for point types and a
  `≤ lL.length` split for segment types — Phase 4/5 proofs should unfold these two equations.
- Gate identical to Phase 1 (off-fiber falsity + order-conflict falsity); gate-failure branch =
  `⟨[]⟩` (holds = False).

## Sorry Inventory

Empty (no task-owned sorries; pre-existing out-of-scope sorries listed above are untouched).
