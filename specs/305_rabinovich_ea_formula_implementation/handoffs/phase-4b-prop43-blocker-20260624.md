# Phase 4b Handoff — Prop 4.3 uniform atom/lt blocks + non-vacuity BLOCKER

- **Task**: 305 (lean4) — plan v37 faithful Rabinovich path
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Phase**: 4b of 6 (sub-step of Phase 4) — **PARTIAL: atom/lt landed sorry-free; and/all/ex/not BLOCKED**
- **Build**: GREEN (1700 jobs full). Live-path sorry baseline UNCHANGED at 2 (`KampPrior:391`, `:394`).
- **Phase 4 marked [BLOCKED]** in the plan (Escalation Protocol).

## Outcome

New file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean`, off the live
import path (imported by nothing). Sorry-free. Axioms `[propext, Classical.choice,
Quot.sound]` (= baseline; verified via `lean_verify` on `atomAt_holds`/`ltAt_holds`).

### Shipped sorry-free (genuine, uniform, reusable)

- `VVecEA_m.tt m` / `VVecEA_m.tt_holds` — constant-⊤ VVecEA_m (holds on every env).
- `VVecEA_m.ff m` / `VVecEA_m.ff_not_holds` — empty disjunction (holds on no env).
- `VVecEA_m.atomAt atomMap h_surj p i` / `atomAt_holds` — **atom case of Prop 4.3**,
  uniform: `(atomAt …).holds M atomMap env ↔ M.interp p (env i)` for ALL M/env.
  Built from `atom_literal` (`Separation/KampTranslation.lean`) lifted via
  `VecEA_m.liftEndpoint` (Phase 4a). Requires `h_surj : ∀ q, ∃ a, atomMap (.atom a) = q`.
- `VVecEA_m.ltAt i j` / `ltAt_holds` — **lt case of Prop 4.3**, uniform:
  `(ltAt i j).holds M atomMap env ↔ env i < env j` under `StrictMono env`
  (decided by indices: `tt` if `i < j`, else `ff`).

These are the two atomic cases of Prop 4.3 as genuine model-independent
translations with a uniform correctness iff. They are non-vacuous and directly
reusable by any future Prop 4.3 build.

## The BLOCKER (conclusive, H6-clean: 0 thrashing, analytic)

### Why the dispatch's per-model framing is vacuous

The dispatch asked to state Prop 4.3 as `∃ v : VVecEA_m m, v.holds env ↔ eval φ`
(per-model existential, matching the codebase `neg_2var_vec_ea`/`neg_vec_ea_m`
convention) and close atom/lt/and/or/ex.

I built exactly that and it type-checks — **but it is vacuous**: for ANY φ,
case-split on the (classical) truth of `eval M env φ`; if true use `⟨tt, …⟩`,
if false use `⟨ff, …⟩`. The witness never depends on φ's structure. This is the
*same* vacuity already latent in the codebase: `neg_vec_ea_m`'s conclusion
`∃ v', v'.holds env` is closed by `⟨tt, tt_holds⟩`. A per-model existential
**cannot** be Prop 4.3 — it carries no translation content. I therefore did NOT
ship it (anti-vacuous discipline).

### What a non-vacuous Prop 4.3 actually requires

A *uniform* function `translate : MonadicFormula sig m → VVecEA_m m` with
`∀ M atomMap env, StrictMono env → ((translate φ).holds M atomMap env ↔ eval M env φ)`.
Its connective cases are each blocked:

| Case | Need | Blocker |
|---|---|---|
| `not` | model-indep arity-`m` negation w/ uniform iff | = model-INDEP Prop 4.2 backward, **UNFIXABLE** (report 18; `NegationIndep.lean:331-351`). `neg_vec_ea_m` is only model-dependent existential. |
| `and` | complete arity-`m` conjunction (Lemma 3.2(1) iff) | `VVecEA_m.conj` forward-only; `conjStruct` over-approximates (`VecEAClosure.lean:163-169`). Missing. |
| `all`/`ex` | Lemma 3.4 (arbitrary-position ex closure) | `existClosure` (`VecEA_m.lean:208`) absorbs only rightmost var under `StrictMono (extendEnv env z)`; De Bruijn `.ex` prepends order-unconstrained witness at index 0 (`MonadicFO.lean:222-223`). Witness-position split + reordering + leftward existClosure all missing. Even live `KampPrior:391` (n=1) needs both leftward AND rightward absorption. |

### Key correction to the dispatch premise

The dispatch (and the 4a handoff) anticipated and/or as "already present via
`VVecEA_m.conj`/`disj`" and the ex case as "`existClosure` + a `Fin.cons`
re-indexing lemma." Both are wrong for a non-vacuous statement:
- `disj` IS a genuine iff (`disj_holds`), so **or** would be fine — but
  `MonadicFormula` has no `or` constructor (or is sugar `¬(¬∧¬)`), so it never
  appears structurally; the only binary connective is `and`, which is the hard one.
- `conj` is NOT an iff (over-approximates), so **and** is blocked.
- `existClosure` is a rightmost-only absorption; there is no re-indexing that turns
  `Fin.cons x env` (x at index 0, unordered) into `extendEnv env z` (z rightmost,
  StrictMono). The orders genuinely differ; the gap is full Lemma 3.4.

## Recommended unblock path (next dispatch / follow-up task)

This is a multi-phase research+build, not a single dispatch. Options:

1. **Restructure to avoid uniform per-connective negation**: push the FO formula to
   a positive (De Morgan) normal form so negation appears only at the top / on
   atoms; then `translate` needs only positive connective closures (complete `and`,
   `or` via `disj`, `ex` via Lemma 3.4) + a single top-level negation handled
   model-dependently. This sidesteps the UNFIXABLE model-indep negation.
2. **Build complete arity-`m` conjunction** (Lemma 3.2(1) as iff) — refine
   `conjStruct` to a common-refinement merge that preserves both conjuncts' segments.
3. **Build Lemma 3.4** (arbitrary-position ex closure): add a leftward `existClosure`
   companion and a witness-position split (x before z_0 / between z_i,z_{i+1} / after
   z_{m-1}), each branch reordering to a StrictMono env and absorbing.

Order: (1) first (it determines whether (the UNFIXABLE) negation can be avoided),
then (2) and (3). Each is likely its own phase. Recommend a `/research --hard` pass
on Lemma 3.2(1) + Lemma 3.4 mechanization before the next build dispatch.

## Files
- NEW: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` (sorry-free, off-path)
- Plan annotated: Phase 4 `[BLOCKED]` with the structured BLOCKER; 4b PARTIAL, 4c BLOCKED.
- Commits:
  - `task 305 phase 4b: Prop43 helpers + atom case (tt/ff/atomAt, sorry-free)`
  - `task 305 phase 4b: Prop43 uniform atom/lt blocks + non-vacuity blocker`

## Verification snapshot
- `lake build` (full) → GREEN, 1700 jobs.
- `Prop43.lean`: 0 `sorry` tactics (the 2 grep hits are the word "sorry-free" in the docstring).
- `lean_verify atomAt_holds`, `lean_verify ltAt_holds` → `[propext, Classical.choice, Quot.sound]`, no warnings, no sorryAx.
- Live-path sorry: 2 (`KampPrior:391`, `:394`) = baseline, UNCHANGED.
- New top-level axioms: 0 (the 2 `^axiom ` grep hits are Boneyard comments).
- `Prop43` imported by nothing live (off-path).
