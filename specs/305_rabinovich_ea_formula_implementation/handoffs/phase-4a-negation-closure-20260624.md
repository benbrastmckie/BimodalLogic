# Phase 4a Handoff — Arbitrary-arity negation closure (neg_vec_ea_m)

- **Task**: 305 (lean4) — plan v37 faithful Rabinovich path
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Phase**: 4a of 6 (sub-step of Phase 4) — **COMPLETED, sorry-free, GREEN**
- **Next**: Phase 4b (Prop 4.3 easy cases + existential glue), then 4c (wire `not` + assemble Prop 4.3)

## Outcome (success)

The genuine long pole landed sorry-free. New file:

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EAVecNegationClosure.lean`

imports `VecEAArityFirewall` (Phase 2) + `EANegationClosure` (Phase 3); **imported by
nothing live** (off the live import path; verified by grep — only self).

### Key theorem

```
theorem neg_vec_ea_m
    (h_INF : HasAttainedINF M atomMap)
    {m : Nat} (v : VVecEA_m m) (env : Fin m → M.carrier)
    (henv_mono : StrictMono env)
    (h_neg : ¬v.holds M atomMap env) :
    ∃ v' : VVecEA_m m, v'.holds M atomMap env
```

`lean_verify` → axioms `[propext, Classical.choice, Quot.sound]`, no warnings, no `sorryAx`.
Single-conjunct version `neg_vecEA_m` (one `VecEA_m m`) verifies identically.

### IMPORTANT deviation from the dispatch signature (read before 4c)

The dispatch asked for `neg_vec_ea_m : VVecEA_m m → VVecEA_m m` (a **total function**).
That is **not** the codebase convention and would not have wired into anything: every
negation-closure layer in this project is the **model-dependent existential** form
`¬holds → ∃ v', v'.holds` (see `neg_2var_vec_ea`, `neg_vecEA2`, `neg_interval_formula`,
`VVecEA2.conj_holds_vvecEA2` — all return `∃ v, v.holds`, never a syntactic function).
Building a total `VVecEA_m m → VVecEA_m m` would require a *biconditional* negation
(syntactic De Morgan with a provable converse), which is exactly the model-INDEPENDENT
backward that report 18 / Phase 3 proved **unfixable** at the `BracketFormula` level.

So `neg_vec_ea_m` was built in the existential form. This is the correct, faithful,
sufficient artifact for Prop 4.3's `not` case: Prop 4.3 is itself a correctness
*biconditional* threaded model-by-model, and its `not` case needs exactly
"`¬(translation holds) → ∃ a VVecEA_m that holds`", which is `neg_vec_ea_m`. No biconditional
negation function is needed downstream.

## Construction (faithful: firewall + De Morgan + arity-2 base)

1. **Lift constructors** (re-lift arity-≤2 results back to arity `m`):
   - `VecEA_m.liftEndpoint (i) (P) : VecEA_m m` — `P` at endpoint `i`, `⊤` elsewhere,
     trivial-`⊤` brackets. `liftEndpoint_holds`: `holds env ↔ P.eval_at (env i)`.
   - `VecEA_m.liftInterval (i) (vea2 : VecEA2 k) : VecEA_m m` — `endpointLeft` at `z_i`,
     `endpointRight` at `z_{i+1}`, the bracket on interval `i`, `⊤`/trivial elsewhere.
     `liftInterval_holds`: `holds env ↔ vea2.holds (env z_i) (env z_{i+1})` (no mono needed —
     `⊤` endpoints and trivial-`⊤` brackets hold vacuously).
   - `VVecEA_m.liftInterval` + `liftInterval_holds` — disjunct-wise.
   - `VVecEA_m.ofEndpoint` + `ofEndpoint_holds` — singleton wrapper for the endpoint case.
2. **`neg_vecEA_m`** (single conjunct): `rw [arity_firewall]` then `rw [not_and_or]`:
   - **endpoint fails** branch: `push_neg`, extract failing `i`, rewrite via
     `endpointComponent_holds`, lift `(endpointTypes i).neg` via `ofEndpoint` +
     `TemporalPred.eval_at_neg'`.
   - **interval fails** branch: `push_neg`, extract failing `i`, rewrite via
     `intervalComponent_holds`, set `a = env z_i`, `b = env z_{i+1}`, get `a < b` from
     `StrictMono`, wrap the failing bracket as `VecEA2.fromBracket` (top endpoints), negate
     with `neg_vecEA2` (Phase 3), lift the resulting `VVecEA2` via `VVecEA_m.liftInterval`.
3. **`neg_vec_ea_m`** (full `VVecEA_m`): `push_neg` over disjuncts, then `neg_vecEA_m_list`
   inducts over disjuncts conjoining via `VVecEA_m.conj` / `VVecEA_m.conj_holds`
   (nil case = a trivial all-`⊤` `VecEA_m m`).

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EAVecNegationClosure` → GREEN (994 jobs),
  no warnings on the new file.
- `lake build Bimodal.Metalogic.Metalogic` → GREEN (1671 jobs) = baseline, file is off this path.
- `lake build` (full) → GREEN (1700 jobs).
- Live-path sorry baseline: **2** (`KampPrior:391`, `:394`) — UNCHANGED.
- Axiom set unchanged; zero new top-level `axiom`; no `sorryAx`.

## Sorry inventory (live path)

| Site | Status |
|---|---|
| `KampPrior.lean:391` (n=1 arm) | sorry — UNCHANGED (Phase 5 target) |
| `KampPrior.lean:394` (n≥2 arm) | sorry — UNCHANGED (Phase 6, off-critical-path) |

Net live-path sorry count: **2** (= baseline). The new file adds **0** live-path sorries
(it is off-path) and **0** off-path sorries.

## Resume point — what 4b and 4c still need

Phase 4 is split 4a/4b/4c (per the phase-3 handoff). 4a done. Remaining:

### Phase 4b — Prop 4.3 easy cases + existential glue
State Prop 4.3 over `MonadicFormula sig m` (constructors atom/lt/not/and/all/ex;
`MonadicFO.eval` at `MonadicFO.lean:63,:216`), target `VVecEA_m m`. Close:
- **atom / lt**: express each as a concrete `VecEA_m m` with a `holds`-vs-`eval` proof
  (small but real constructions).
- **and / or**: `VVecEA_m.conj` / `VVecEA_m.disj` (both already in `VecEA_m.lean`, with
  `conj_holds` / `disj_holds`).
- **ex**: `VecEA_m.existClosure` + `existClosure_correct`/`_rev` (`VecEA_m.lean:208,245,314`,
  bidirectional). **Index glue (the 4b sub-difficulty)**: `eval (.ex α) env = ∃ x,
  eval (Fin.cons x env) α` binds De Bruijn **index 0** (prepend), but `existClosure` absorbs
  the **rightmost** free variable. Need a variable-permutation / re-indexing lemma between
  `Fin.cons x env` and the `existClosure` (`extendEnv`-append) convention. Non-trivial; this
  is the main 4b cost.
- Leave **not** as the only open case, consuming 4a.

### Phase 4c — wire `not` + assemble biconditional
Wire the `not` case via **`neg_vec_ea_m`** (this dispatch's artifact, existential form) and
assemble the full Prop 4.3 correctness biconditional vs `MonadicFO.eval`. The `not` case shape:
from `¬(IH-translation holds env)` produce `∃ v', v'.holds env` via `neg_vec_ea_m` — it slots
in directly because Prop 4.3 is a model-by-model biconditional, not a syntactic function.
Requires `StrictMono env` available in the induction context (carry it as a hypothesis).

Then Phase 5 (re-anchor `KampPrior:391` via Prop 4.3 + Prop 3.5 `translate_correct`,
`RabinovichTranslation.lean:200`) and Phase 6 (verify, clear/off-path `:394`, axiom audit).

## Files
- NEW: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EAVecNegationClosure.lean`
- Plan annotated: `specs/305_rabinovich_ea_formula_implementation/plans/37_faithful-rabinovich-path.md`
  (Phase 4 `[IN PROGRESS]`, 4a marked done, 4b/4c enumerated)
- Commit: `eee41b94a task 305 phase 4a: arbitrary-arity negation closure (neg_vec_ea_m)`
