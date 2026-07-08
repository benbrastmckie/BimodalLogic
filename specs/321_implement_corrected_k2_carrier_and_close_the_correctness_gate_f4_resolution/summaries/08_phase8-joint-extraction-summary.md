# Phase 8 Summary — Joint Soundness Extraction (O3)

- **Task**: 321 — Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Phase**: 8 of 13 (v7 plan `plans/07_v7-faithful-separate-bracket.md`) — COMPLETED
- **Session**: sess_1783487859_3f6358 (2026-07-07)
- **Commits**: 2c55cf3f1 (bundles + Lemma 5.1 kit split + navigation helpers), 8c22e01c5 (extraction theorems)

## What Was Implemented

Appended ~450 lines to
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(now 1,393 lines; the ONLY file touched):

1. **`kvE2_sepDisjunct_extract`** (main O3 theorem): from a realized joint disjunct over
   valid interleavings `lL ∈ kvE2_sepArrL qnf`, `lR ∈ kvE2_sepArrR qnf` — the joint
   endpoint realizations `epL@x`/`epR@t`, the shared witness `w` (`ptW` slot at position
   `|lL|`, `x < w < t` from the bracket's own range — FM-x1t), and at that same `w` the
   per-σ bundles for both interior classes.
2. **`kvE2_sepBody_extract`**: carrier-level corollary with NO gate hypothesis (routes
   the gate-failure branch through `kvE2_sepBody_gate_fail` to `False`).
3. **`kvE2_sepDisjunct_halves`** + generic **`kvE2_sepBracket_split_at`**: the shared-`w`
   pivot CONSUMING `BracketFormula.leftPart_holds`/`rightPart_holds`
   (`VecEAFormula.lean:375/:412`; D4 — kit consumed, never rebuilt), with
   **`kvE2_sepCastBracket`**(+`_holds`) normalizing the non-successor witness count
   `|lL|+1+|lR|`. The halves carry the refined-segment realizations Phase 9 needs.
4. **`kvE2_sepBundleL`/`kvE2_sepBundleR`** (per-σ bundle defs) and
   **`kvE2_sepBundleL_parts`** — the EXACT `kvE_subBracket2V_sound_of_parts`
   (`SubBracket2V.lean:1025`) input 5-tuple `(x1, hxx1, hx1t, hanchor, hbelow)`;
   **`kvE2_sepBundleR_parts`** mirrored fragment; **`kvE2_sepPtX1L/R_anchor`** charK head
   projections; **`kvE2_sepPos_mem`**.
5. Private structural plumbing reusable by Phase 9: getElem navigation
   (`kvE2_sep_getElem_mid/left/right`), region-rank index ordering
   (`kvE2_sep_index_lt_of_rank_lt` via `List.pairwise_iff_getElem`), slot-block
   membership, arrangement transfer + pairwise lemmas.

## Verification

| Gate | Result |
|------|--------|
| `lake build` (full) | GREEN (1720 jobs) |
| Axiom check (all 10 public Phase 8 theorems) | exactly `[propext, Classical.choice, Quot.sound]` |
| Sorries in SharedWitness.lean | 0 (none introduced anywhere) |
| Litmus grep (`fChainPred` / `x1 < e_i`) | 0 hits |
| Vacuous defs | 0 new (1 pre-existing baseline hit in Examples/) |
| New axioms | 0 |
| `git diff` scope | `SharedWitness.lean` only (+ specs artifacts) |
| DO-NOT-EDIT assets | untouched (append-only file edit) |

## Plan Deviations

- *(deviation: altered)* "for EVERY positive σ" read per the recorded Phase 7 scope
  decision: bundles for the two INTERIOR classes; the five non-interior classes carry no
  bracket slots by construction — their data are the σ-level endpoint literals, surfaced
  verbatim by the extraction's `epL@x`/`epR@t`/`ptW@w` conjuncts. Right-interior bundles
  ARE extracted (watch item honored) despite the missing landed consumer kit.

## Handoff

`handoffs/phase-8-handoff-20260707.md` — landed API table, key decisions, Phase 9/10
watch items (right-interior kit gap, O4 crux residue, possible additive `kvE2_sepGate`
extension), empty sorry inventory.
