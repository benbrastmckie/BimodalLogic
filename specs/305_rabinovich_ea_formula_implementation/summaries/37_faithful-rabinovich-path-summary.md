# Implementation Summary — Task 305 (plan v37, dispatch 1: Phases 1–2)

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4)
- **Plan**: plans/37_faithful-rabinovich-path.md (v37 faithful Rabinovich path)
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Scope this dispatch**: Phase 1 (decision gate) + Phase 2 (Lemma 3.2(2)). Phases 3–6 deferred.
- **Final state**: build GREEN (1671 jobs); 2 live sorries (= baseline); axiom set unchanged.

## Phase 1 — Boneyard triage + Prop 4.3 decision gate (COMPLETED)

**Verdict: REBUILD** (committed in writing in the plan file and `handoffs/phase-1-gate-rebuild-20260624.md`).

Decisive triage findings (read-only spike, no live-path edits):
- `Kamp/Boneyard/Prop43.lean` is **NOT** the structural FO-induction Prop 4.3. It is the
  depth-(k+1) NF-characterization / arity-tower machinery (`nf_succ_char_formula`). It is
  sorry-free but is the FORBIDDEN NF-depth construction — reviving it reintroduces the
  arity tower. REVIVE is therefore impossible.
- No live `StructuralInduction.lean` exists anywhere (the `KampPrior:28` reference is
  aspirational). There is no archived structural Prop 4.3 to lift.
- Baseline confirmed GREEN; `completeness_discrete` axioms = `[propext, sorryAx,
  Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`; 2 live sorries
  at `KampPrior:391` (n=1, critical) and `:394` (n≥2, off-critical-path).
- `nf_nvar_exist_all_depths` (the sorry host) has **no external live consumer** — contained
  within `KampPrior.lean`; only `PriorExpressiveness` imports `KampPrior` live. Re-wire
  surface for Phase 5 is contained; cycle risk LOW.
- All faithful assets confirmed sorry-free and off-path: `VecEA_m.existClosure`
  (bidirectional), `RabinovichTranslation.translate_correct`, `EANegationClosure`,
  `VecEAClosure`, `NegationIndep` (forward only — `:331` backward is the one gap).

## Phase 2 — Lemma 3.2(2) arity firewall (COMPLETED, sorry-free)

New module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAArityFirewall.lean`:
- `VecEA_m.endpointComponent : VecEA_m 1` + `endpointComponent_holds`.
- `VecEA_m.intervalComponent : VecEA_m 2` + `intervalComponent_holds`.
- `VecEA_m.arity_firewall` (**Lemma 3.2(2)**): arity-`m` `holds` ⟺ conjunction of all
  arity-1 endpoint components and all arity-2 interval components. Every RHS component
  has ≤ 2 free variables by type — the structural arity cap.

Faithful to Rabinovich md:78. No NF-depth, no depth-index recursion, no arity-3 appeal.
`lean_verify VecEA_m.arity_firewall` → `[propext, Classical.choice, Quot.sound]` (no sorryAx).
Module builds GREEN (989 jobs). OFF live import path — baseline unchanged (wiring is Phase 5).

## Verification (this dispatch)

| Check | Result |
|---|---|
| `lake build Bimodal.Metalogic.Metalogic` | GREEN, 1671 jobs |
| New module build | GREEN, 989 jobs |
| Live-path sorry count | 2 (= baseline; no new sorries) |
| New module sorries | 0 |
| Vacuous definitions | 0 |
| Top-level axioms in `Theories/` | 2 (= baseline, unchanged) |
| `completeness_discrete` axiom set | unchanged |
| `arity_firewall` axioms | propext, Classical.choice, Quot.sound (no sorryAx) |

## Plan Deviations

- **Phase 1, task "Map Prop43's structural cases against Rabinovich §4"** *(altered)*:
  Prop43.lean does not contain structural cases — it is the depth-(k+1) NF-char machinery.
  The mapping instead established that no structural Prop 4.3 exists to map, forcing REBUILD.
  This is the intended gate outcome, not a divergence from plan intent.

## Phase 3 — Prop 4.2 model-independent backward (COMPLETED-via-documented-fallback)

Dispatch 2 (session sess_1782337996_6c54a7, 2026-06-24).

Made **one genuine attempt** to close the model-independent backward, then took the
**pre-authorized model-dependent interim** (plan line 226/236).

- Stated candidate `neg_2var_vec_ea_indep_backward : (neg_2var_vec_ea_indep v).holds → ¬v.holds`
  at the live `VVecEA2` level; `lean_goal` confirmed goal `⊢ ¬VVecEA2.holds M atomMap v z0 z1`.
- `lean_multi_attempt`: `aesop` no progress, `exact?` no result — the obstruction is structural
  (the disjunction construction `neg_vecEA2_indep` is exhaustive but **not disjoint**, so it is
  not a biconditional; backward bottoms out at the B.1 interval mismatch, report 18 §2.3/§4).
  This **re-confirms** the documented `:331` obstruction. H6 churn cap honored: 1 attempt,
  conclusive negative, stopped.
- **Interim taken**: `neg_2var_vec_ea` (model-dependent Prop 4.2, EANegationClosure.lean,
  sorry-free, axioms `[propext, Classical.choice, Quot.sound]`) supplies the negation case for
  Prop 4.3 (Phase 4). The model-independent backward is a bounded follow-up, OFF the live
  completeness path.
- Edits: `NegationIndep.lean:331` NOTE region got a **PHASE 3 RESOLUTION** comment block
  (off-path, comment-only); plan Phase 3 marked `[COMPLETED]` with deviation annotations.
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationIndep` GREEN (990 jobs);
  `lake build Bimodal.Metalogic.Metalogic` GREEN (1671 jobs); 2 live sorries = baseline; axiom
  set unchanged. Committed (`task 305 phase 3: ...`).

## Phase 4 — NOT attempted this dispatch (H8 sizing)

Phase 4 (REBUILD Prop 4.3 structural FO induction over `MonadicFormula`) does **not** fit one
clean green-ending run: it requires an **arbitrary-arity negation closure that does not yet
exist** (grep confirms only arity-2 `neg_2var_vec_ea`). The faithful route is to consume the
Phase 2 `arity_firewall` (arity-m EA → conjunction of arity-≤2 components) + De Morgan +
per-component `neg_2var_vec_ea`, but that reassembly is itself a ~150–250-line sorry-free
sub-phase, plus the `.ex` case needs `Fin.cons`-vs-`existClosure` re-indexing glue. Full
decomposition (Phase 4a negation closure → 4b easy cases + ex glue → 4c not case) is in
`handoffs/phase-3-prop42-backward-20260624.md`. Stopping at the Phase 3 GREEN boundary per H8.

## Phase 4a — DONE (this dispatch), sorry-free, GREEN

The genuine long pole — the **arbitrary-arity negation closure** — landed sorry-free in a new
off-path file `Kamp/EAVecNegationClosure.lean`:

```
neg_vec_ea_m (h_INF) {m} (v : VVecEA_m m) (env) (StrictMono env) :
    ¬v.holds env → ∃ v', v'.holds env
```

Built **faithfully** via the Phase 2 `arity_firewall` (decompose arity-m EA → conjunction of
arity-≤2 components) + `not_and_or`/`push_neg` De Morgan + the Phase 3 arity-2 base
`neg_vecEA2`, with three lift constructors (`liftEndpoint`, `liftInterval`, `VVecEA_m.liftInterval`)
re-lifting arity-≤2 closures back to arity `m`. NOT via NF-depth/arity-tower descent.

**Deviation (load-bearing for 4c)**: the dispatch asked for a total function
`VVecEA_m m → VVecEA_m m`; that is not the codebase convention (every closure layer here is the
existential `¬holds → ∃ holds`, and a total function would need the model-INDEPENDENT
biconditional negation that Phase 3 proved unfixable). The existential form is the correct,
sufficient artifact for Prop 4.3's `not` case (Prop 4.3 is itself a model-by-model
biconditional). See `handoffs/phase-4a-negation-closure-20260624.md`.

`lean_verify neg_vec_ea_m` → `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
`lake build` full GREEN (1700 jobs); `Metalogic.Metalogic` GREEN (1671 = baseline); live-path
sorry baseline **2** (`KampPrior:391,:394`) UNCHANGED; axiom set unchanged. Committed
(`eee41b94a task 305 phase 4a: ...`).

## Next dispatch

Plan v37 **Phase 4b** (Prop 4.3 easy cases + `.ex` existential glue), then **4c** (wire the
`not` case via `neg_vec_ea_m` + assemble the Prop 4.3 correctness biconditional). The main 4b
cost is the `Fin.cons` (De-Bruijn index-0 prepend) ↔ `existClosure` (rightmost-variable absorb)
re-indexing lemma. 4c slots `neg_vec_ea_m` directly into the `not` case. Resume from
`handoffs/phase-4a-negation-closure-20260624.md`.
