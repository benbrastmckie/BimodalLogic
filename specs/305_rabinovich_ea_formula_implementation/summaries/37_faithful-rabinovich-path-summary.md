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

## Next dispatch

Phase 3 (Prop 4.2 model-indep backward, `NegationIndep:331`) — HIGH risk, documented
UNFIXABLE at BracketFormula level (report 18) and non-blocking; plan line 226 pre-authorizes
the model-DEPENDENT Prop 4.2 interim. Then Phase 4 REBUILD Prop 4.3 consuming the firewall.
Resume from `handoffs/phase-2-arity-firewall-20260624.md`.
