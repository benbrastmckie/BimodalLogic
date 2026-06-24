# Phase 2 Handoff — Lemma 3.2(2) Arity Firewall

- **Task**: 305 (lean4) — plan v37 faithful Rabinovich path
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Phase**: 2 of 6 — Lemma 3.2(2) arity firewall — **COMPLETED, GREEN**

## What landed

New module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAArityFirewall.lean`
(imports only `VecEA_m`), containing the faithful Lemma 3.2(2):

- `VecEA_m.endpointComponent (vea) (i) : VecEA_m 1` — arity-1 component carrying
  only the `i`-th endpoint predicate.
- `VecEA_m.endpointComponent_holds` — holds on `fun _ => env i` iff the `i`-th
  endpoint predicate holds at `env i`.
- `VecEA_m.intervalComponent (vea) (i) : VecEA_m 2` — arity-2 component carrying
  only the `i`-th interval bracket (trivial `⊤` endpoints).
- `VecEA_m.intervalComponent_holds` — holds on `env2 a b` iff the `i`-th interval
  bracket holds on `(a, b)`.
- `VecEA_m.arity_firewall` (**Lemma 3.2(2)**) — the arity-`m` `holds` is equivalent
  to the conjunction of all arity-1 endpoint components AND all arity-2 interval
  components. Every RHS component has at most two free variables, by type.

Faithful to Rabinovich md:78: *"Every exists-forall formula is equivalent to a
conjunction of exists-forall formulas with at most two free variables."* The proof
exploits that `VecEA_m.holds` is already a conjunction of per-endpoint (arity-1) and
per-interval (arity-2) conditions. No NF-depth parameter, no depth-index recursion,
no arity-3 appeal — the firewall is structural and arity-capped by construction.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAArityFirewall` → GREEN (989 jobs).
- `lean_verify VecEA_m.arity_firewall` → axioms `[propext, Classical.choice, Quot.sound]`.
  No `sorryAx`, no `Lean.ofReduceBool`/`Lean.trustCompiler` introduced, no new top-level axiom.
- Module sorry-free (0 sorries); no vacuous definitions.
- **Baseline unchanged**: `lake build Bimodal.Metalogic.Metalogic` → GREEN (1671 jobs);
  `completeness_discrete` axioms still `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]`; 2 live critical sorries intact at `KampPrior:391/394`.
  The firewall is OFF the live import path (not yet imported by `KampPrior`) — wiring is
  Phase 5, exactly as planned.

## Sorry inventory (live path)

| Site | Status |
|---|---|
| `KampPrior.lean:391` (n=1 arm) | sorry — UNCHANGED (THE critical-path obstruction) |
| `KampPrior.lean:394` (n≥2 arm) | sorry — UNCHANGED (documented off-critical-path) |

Net live-path sorry count: **2** (= baseline). No regression.

## Next action (Wave 2 remainder / Wave 3)

- **Phase 3** (Prop 4.2 model-indep backward, `NegationIndep.lean:331`): ⚠️ HIGH RISK.
  The `:331` NOTE + report 18 §4 declare the backward direction UNFIXABLE at the
  BracketFormula level, and explicitly state it does NOT block completeness (the
  model-DEPENDENT `neg_interval_formula` in `EANegationClosure.lean`, sorry-free,
  suffices). Plan line 226 pre-authorizes the contingency: budget cautiously, and if
  the backward resists, wire Prop 4.3 (Phase 4) with the model-DEPENDENT Prop 4.2 as a
  documented interim rather than churning on the unfixable BracketFormula gap.
- **Phase 4** (REBUILD Prop 4.3 structural FO induction): consumes Phase 2 firewall +
  Phase 3 (or its model-dependent interim). Build fresh — no archived asset; cap arity ≤ 2
  using `arity_firewall`; existential case via `VecEA_m.existClosure`; negation case via
  Prop 4.2; translation via `RabinovichTranslation.translate_correct`.
- **Phase 5**: rewire `KampPrior` imports to bring the firewall + Prop 4.3 on-path, then
  re-anchor `:391` through Prop 4.3 + Prop 3.5. Verify acyclicity with a build before
  touching `:391`. Cycle risk LOW (faithful modules do not import KampPrior).

Resume point: plan v37, Phase 3 (or Phase 4 if Phase 3 takes the interim). Phases 1–2
COMPLETED and committed.
