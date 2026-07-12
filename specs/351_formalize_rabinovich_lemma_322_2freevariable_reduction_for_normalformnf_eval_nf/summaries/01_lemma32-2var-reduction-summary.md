# Implementation Summary (Phase 3 dispatch) — Task 351 Lemma 3.2(2) reduction

- **Phase executed:** Phase 3 — FEASIBILITY GATE (arity-3 zone bridge for one existential over a
  fixed enclosing anchor pair). Single-phase dispatch (`phase_number = 3`); did not proceed past it.
- **Gate outcome:** **GO** — green, sorry-free, 0 new axioms.

## Lemmas proved (in `Lemma32Reduction.lean`)

1. `nfEval_pair_arity3_flatten` — the arity-3 inner existential
   `∃ w, nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) q` over a fixed enclosing anchor pair
   `(env i, env j)` drawn from the surrounding `env` is captured by `nf_zone_flatten_navigable` at
   those anchors. Direct specialization of the green `nf_zone_flatten_navigable_correct`
   (Base.lean:687), which internally contains the `nf_char2_zone_split5` five-zone split
   (Base.lean:584). One witness threaded through five zones; anchor set `{env i, env j}`; no arity
   climb past 3.
2. `nfEval_pair_arity3_interior` — the bounded interior zone `env i < w < env j` is coupled to the
   navigated interior characteristic via `seg_holds_coupled` (Base.lean:1150) specialized to
   `(env i, env j)`. Completes the order-theoretic resolution of all five zones.

## Why this is a GO, not a NO-GO

The single order-sensitive step (one existential over one fixed enclosing pair) closes using ONLY
the green order/zone machinery, with a single witness (no independent per-pair distribution — the
plan's SETTLED decision) and no arity climb past 3. The degenerate diagonal `env i = env j` is
subsumed by `nf_zone_flatten_navigable`'s tolerance of degenerate anchor orders.

## Gate's negative content (documented, machine-grounded)

The FIXED single-pair arity-`(n+1)`↔arity-3 *bi-implication* is a **non-theorem** when `n ≥ 3`: the
arity-3 restriction forgets non-pair anchors, so an arity-3 witness can satisfy the pair while the
arity-`(n+1)` inner existential fails. This is the same strict-weakness phenomenon already
machine-checked, sorry-free, by `endCharN0_correct_infeasible` (Base.lean:1779) and
`endCharN0_correct_world_local_obstruction` (Base.lean:1745). Consequently the Phase 4–5 merge must
proceed order-theoretically over the enclosing ZONE (a disjunction over possible enclosing pairs,
one witness threaded through linear-order transitivity), never by a per-pair arity collapse. The
arity-3 restriction MAP itself is Phase 4's task (`nfRestrict`), not Phase 3's.

## Verification

- Scoped `lake build …Lemma32Reduction`: green (1006 jobs), no warnings from the new file.
- `lean_verify` on both new lemmas: axioms exactly `[propext, Classical.choice, Quot.sound]` (0 new).
- 0 `sorry`, 0 `admit`, 0 vacuous defs in the new file.
- `Base.lean` and all existing files untouched.

## Plan deviations

- Bridge landed as two specialization lemmas (flatten + interior) rather than one monolithic lemma —
  more faithful to the "reuse the green two-anchor template" mandate.
- Diagonal handled by degenerate-order tolerance, so `nf_char2_diag_exist_tl_correct` is not
  separately invoked (it is a `Formula`-valued converter — navigation, 349's job).
- Estimated ~260 lines; actual ~90 lines added (two specializations + gate docstring).

## Sorry inventory

Empty. No sorries introduced or inherited.
