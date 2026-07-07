# Task 309 Phase 13 Summary: depth-k V-carrier correctness (R3b) — BLOCKED with finding F1

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Phase**: 13 (single-phase hard-mode dispatch, plan v5)
- **Date**: 2026-07-06
- **Session**: sess_1783391112_643ec1
- **Outcome**: [BLOCKED] — target theorem refuted at `k = 2`; 13a-seam content landed green

## What Happened

The Phase-13 target `bracketEndChar_kv_correct` (unconditional `∀ k` correctness `↔` for the
Phase-12 carrier `bracketEndChar_kv`) is **FALSE at `k = 2`** in the soundness (LHS→RHS)
direction. This is precisely the gate-strength risk the Phase-12 handoff flagged as Key
Decision 3 and mandated as "a Phase-13 finding to report". No `sorry`'d false theorem and no
vacuous placeholder was landed; the Phase-12 gate was not silently changed (KD3 honored).

## Finding F1 (four-element defect record: NfMultiAnchorBridge.lean:3871-3934)

1. **Counterexample**: `M = (ℚ, <)`, `P = {q, p, r}`, `q < x < u₂ < p < u₁ < w < t < r`.
   `u₁, u₂` share their complete depth-1 1-type `χ` while `[u₁,w,x,t]` and `[u₂,w,x,t]` have
   DISTINCT depth-1 arity-4 types in one `(zXW, χ, qnf.1)` fiber. With `qnf` the characteristic
   depth-2 3-type of `[w,x,t]` and `qnf'` = `qnf` with the `u₂`-sub un-marked: the carriers are
   EQUAL (machine-checked, `bracketEndChar_kv_factors`) yet no `w'` realizes `qnf'` in `M`;
   the two instances of the target `↔` are jointly contradictory. `qnf'` is realizable in a
   discrete chain, so no consistency hypothesis rescues the statement.
2. **Current behavior**: at successor depth the carrier factors through
   `(qnf.1, off-fiber Prop, fiber-existential bits)` — machine-checked.
3. **Required behavior**: `nf_eval_nf`'s quant layer is a per-sub biconditional that
   distinguishes in-fiber markings at `k ≥ 2` (D7, NfEFold:373 — fibers stop being singletons).
4. **Isolation**: `k = 1` is saved by the depth-0 split-kit bijection (NfEFold:235). Rabinovich
   avoids the `k ≥ 2` loss by ENRICHING the `α_j`/`β_j` vocabulary at every Prop-4.3 fold round
   (Def 3.1 PDF p.4; Cor 5.4's `F_i` are TL formulas, PDF p.7); the Phase-12 realization's plain
   base-signature `nfk_projFresh` 1-types discard exactly that joint structure.

## Landed Green (sorry-free; full tree GREEN, 1705 jobs)

| Declaration | Location | Content |
|---|---|---|
| `bracketEndChar_kv_correct_zero` | NfMultiAnchorBridge.lean:3783 | k=0 instance (recursion BASE): singleton `VVecEA2.holds` reduction + `bracketEndChar_k0_correct` |
| `bracketEndChar_kv_correct_one` | :3811 | k=1 instance: bridge `bracketEndChar_kv_one_eq` + `bracketEndChar_k1v_correct` |
| `bracketEndChar_kv_factors` | :3838 | fiber-factorization congruence (isolation half of F1) |
| F1 section record | :3871-3934 | four-element defect record with N1/N2 citations |

`lean_verify` on all three theorems = exactly `[propext, Classical.choice, Quot.sound]`.

## Verification

- `lake build` full tree: GREEN (1705 jobs), 0 errors
- New sorries: 0 (live-path baseline unchanged: KampPrior:351/354)
- Vacuous definitions: 0 new; real `axiom` declarations: 0
- Guards: anchors `{x,t}` type-level (G4/G6); no `nf_char3_deeper_split`; no fold asset
  redefined; no arity-4 residual reconstructed; chain steps cite PDF p.4-7 (G5)

## Plan Deviations

- The plan's `bracketEndChar_kv_correct` + `_sound`/`_complete` deliverables were NOT landed:
  refuted at `k = 2` (finding F1) — the mandated escalation path, not a deflection. The H8
  13a-seam content (base wiring + k=1 step) was landed instead, plus the machine-checked
  isolation lemma. Phase 13 heading → [BLOCKED] with the BLOCKER block in the plan.

## Next Steps

`/revise 309` (plan v6): redesign the `k ≥ 2` carrier with vocabulary enrichment per fold round
(inside-out iterated fold — Def 4.1 p.6 note at full strength). Do NOT dispatch Phase 14 against
the current carrier. Preserve the landed `k ≤ 1` instances, the completeness-direction shape,
the k1v kit, and the fold engine.

## Commits

- `e5924f492` — task 309 phase 13.1: k=0/k=1 instances (base wiring + bridge step)
- `0f1826739` — task 309 phase 13.2: fiber-factorization lemma + finding F1 record
- (final) task 309 phase 13: depth-k V-carrier correctness bracketEndChar_kv_correct (R3b)
