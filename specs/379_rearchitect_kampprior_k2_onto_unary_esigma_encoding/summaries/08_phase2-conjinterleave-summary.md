# Phase 2 (α part 1) Execution Summary — `conjInterleave` def + forward

**Status**: PARTIAL. Dispatch: Phase 2 only, hard mode, session `sess_1784392190_93d19d`.

## Delivered (all in new off-live-path module `ConjInterleave.lean`)

Sorry-free, genuine (non-vacuous):
- `belowCount` / `belowCount_le` / `intervalSlot` — merged-position → source interval slot.
- `chainPointType` / `chainIntervalType` — a source chain's point/interval contribution at a merged slot.
- `MergePair` (+ `Fintype` via `equivProd`, `DecidableEq`), `MergePair.valid` (mono + joint-surj +
  pin-compat, decidable), `MergePair.pointConsistent`.
- `mergedFormula` (single `StrictMono` chain of unary types — no arity growth), `conjInterleave`
  (the `∨∃∀` enumerating valid point-consistent merges).
- `mergedSet` / `mergedSet_card_succ` — sorted-union carrier of two witness chains.
- `pointConsistent_of_holds` — the crux: a realized merge is point-consistent via `nf_eval_unique`.

Documented strategic sorry (TRUE statement, full in-proof plan):
- `conjInterleave_forward` — forward direction of Lemma 3.2(1). Residual = sorted-union
  `orderEmbOfFin` rank realization bookkeeping.

## Verification

- Full `lake build` EXIT 0 at 1769 jobs (no regression).
- Off live import path (grep audit: nothing imports the module); spine `completeness_discrete`
  untouched; no new axioms on sorry-free decls; `vacuous_count = 0`.
- Exactly one tracked strategic sorry (`conjInterleave_forward`).

## Design finding (escalated)

Rabinovich Def 3.1 (PDF p.4): `αⱼ, βⱼ` are **partial quantifier-free formulas** (conjoinable,
contradiction forces an interval empty — footnote 2 p.5). Landed `UnaryType = NormalForm 0 1` is a
**complete** type (no faithful conjunction). Full-consistency `conjInterleave_iff` is therefore
FALSE at empty merged intervals with mismatched interval types (2-point counterexample); forward is
recovered by a **point-consistency-only** filter. **Phase 3 (backward/iff) needs a partial-type
interval representation** (`List`/`Finset UnaryType`) — a change to the landed `ExistsForallFormula`,
i.e. an orchestrator/user design decision. See the module design note, plan Phase 2 heading, and
`handoffs/phase-2-handoff-20260718T102303.md`.

## Plan deviations

- Consistency filter is point-only (not full) — required for forward to be true (see finding).
- Forward proved as a documented strategic-sorry skeleton, not fully closed — residual is mechanical.
