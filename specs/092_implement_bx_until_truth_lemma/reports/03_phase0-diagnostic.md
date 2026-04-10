# Task 92 — Phase 0 Diagnostic Gate Report

- **Task**: 92 — Close 4 Until/Since truth-lemma sorries in `BXCanonical/Frame.lean`
- **Phase**: 0 (Diagnostic Gate)
- **Date**: 2026-04-10
- **Method**: Read-only probes via `lean-lsp` MCP (`lean_goal`, `lean_multi_attempt`, `lean_state_search`, `lean_local_search`). Zero writes to `Theories/`.
- **Decision**: **NO-GO / BLOCKED**
- **Escalation triggered**: yes — (Probe 1 fails AND Probe 2 fails) AND (Probe 3 fails AND Probe 4 fails)

## Executive Summary

All four diagnostic probes that were expected to close Gap U5 (forward) and
B-GAP (backward) **fail as predicted by Teammate C's critique**. The
Burgess-Xu Until-induction kernel described in the task 90 recommendation
and the task 92 round-02 team research smuggles an unproved propagation step
past `bx_le := g_content ⊆`, and no rescue via BX7 two-formula earliest
selection, BX4 direct propagation, or BX4' `connect_past` succeeds in the
current axiom set. The diagnostic gate therefore halts the plan and
recommends `/spawn 92` with blocker description **"BX5 propagation gap and
BX4 connectedness disavowal both unrescued in diagnostic Phase 0"**.

This NO-GO verdict is a scientifically correct outcome that matches the
escalation clause of the plan at
`specs/092_implement_bx_until_truth_lemma/plans/02_burgess-xu-until-plan.md`
(Risks row 1 and 2, Rollback item 2). Per the zero-debt policy, task 92
should move to `[BLOCKED]` and downstream phases (1–6) must not execute
until a new rescue path is researched under task 94 (or equivalent spawned
task).

## Probe 1 — BX5 Self-Accumulation Propagation (Gap U5)

### Goal (verbatim from `lean_goal` at `Frame.lean:653`)

```
w : BXPoint
φ ψ : Formula
h_until : φ.untl ψ ∈ w.formulas
h_not_psi : ψ ∉ w.formulas
⊢ ∃ v, bx_le w v ∧ ψ ∈ v.formulas ∧
    ∀ (u : BXPoint), bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

### Attempted

1. `exact?` — **error**: "`exact?` could not close the goal."
2. Tactic skeleton building BX5 self-accumulation in `w.formulas`:
   ```lean
   have h5 : DerivationTree [] ((Formula.untl φ ψ).imp
              (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ)) :=
     DerivationTree.axiom [] _ (Axiom.self_accum_until φ ψ)
   have h_accum : Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas :=
     SetMaximalConsistent.implication_property w.is_mcs
       (theorem_in_mcs w.is_mcs h5) h_until
   sorry
   ```
   Typechecks — but the resulting formula lives in `w.formulas`, **not** in
   `g_content(w)`, so it does NOT propagate to arbitrary `u` with
   `bx_le w u`. The guard obligation for `u ∈ (w, v)` with `u ≠ w` is left
   wide open.

### Outcome — **FAIL**

The formal statement of **Gap U5** is confirmed:

> `(φ ∧ (φ U ψ)) U ψ` is an `Until`-formula, not of the form `G(χ)`.
> `bx_le w u = g_content(w) ⊆ u.formulas` restricts propagation to
> `G`-content. Therefore BX5 self-accumulation in `w.formulas` does not
> yield `(φ U ψ) ∈ u` (nor any derived Until) at an arbitrary `u` in the
> strict interval `(w, v)`, and the guard `φ ∈ u` cannot be discharged
> through BX9 `until_elim` at `u` because `(φ U ψ) ∉ u` is not established.

This matches Teammate A Finding 7 (no `G(φ U ψ)` lemma exists) and
Teammate C Issue 1 (BLOCKER: BX5 self-accumulation does not propagate along
`bx_le`).

## Probe 2 — BX7 Two-Formula Earliest-Witness Rescue (R1 for Gap U5)

### Strategy tested

Build `⊤ U ψ ∈ w.formulas` via BX10 (`until_F`) + BX12 (`F_until_equiv`),
then hope that BX7 `linear_until` applied to `(φ U ψ) ∧ (⊤ U ψ)` lets us
pick an "earliest ψ-witness" at the BXPoint level.

### Attempted

```lean
have h10 : DerivationTree [] ((Formula.untl φ ψ).imp (Formula.some_future ψ)) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
have h_Fψ : Formula.some_future ψ ∈ w.formulas :=
  SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h10) h_until
have h12 : DerivationTree [] ((Formula.some_future ψ).imp
            (Formula.untl (Formula.bot.imp Formula.bot) ψ)) :=
  DerivationTree.axiom [] _ (Axiom.F_until_equiv ψ)
have h_top_u : Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ w.formulas :=
  SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h12) h_Fψ
obtain ⟨v₀, h_wv₀, h_ψv₀⟩ := bx_forward_witness w ψ h_Fψ
refine ⟨v₀, h_wv₀, h_ψv₀, ?_⟩
intro u h_wu ⟨h_uv, h_not_vu⟩
sorry
```

This **builds** `⊤ U ψ ∈ w.formulas` and extracts `v₀` via
`bx_forward_witness`, but at the guard stage we are still left with
`⊢ φ ∈ u.formulas` for an arbitrary `u` in the strict interval. BX7's
three-way Until disjunction lives in `w.formulas` — it is a **formula-level
linearity** on Until resolution, not a **BXPoint-level minimum selector**.
Nothing about BX7's conclusion gives us `v₀` is the "earliest" BXPoint with
`ψ ∈ v₀`, nor does it force `ψ ∉ u` for strictly-earlier `u`.

Auxiliary searches:
- `lean_state_search` at `:653` returned only irrelevant Mathlib hits
  (`SimpleGraph.mk.injEq`, `CategoryTheory.Pretopology.mk.inj`, ...). No
  goal-closing lemma.
- `lean_local_search "earliest"` returned **0 hits**.
- `lean_local_search "until_witness"` returned only
  `Bimodal.Metalogic.Bundle.until_witness_seed` (a Lindenbaum seed
  generator, not an earliest-witness primitive).

### Outcome — **FAIL**

The proposed rescue helper `bx_earliest_until_witness` has no sound
derivation from the current axiom set. BX7 produces an object-level
conjunction-of-Untils disjunction inside one MCS; it does not deliver a
metalevel minimum on the BXPoint partial order. This matches Teammate C
Issue 3 (BX7 earliest-selection is ill-defined at the BXPoint level).

**Candidate helper name proposal** (for a hypothetical task 94 rescue):
`bx_earliest_until_witness` — but its proof does not exist in the current
axiom set. Proving it would require either (a) new infrastructure to lift
formula-level BX7 to MCS-level minimum selection, or (b) a redefinition of
`bx_le` (ruled out by task 90).

## Probe 3 — BX4 Backward Direction (B-GAP)

### Goal (verbatim from `lean_goal` at `Frame.lean:675`)

```
w : BXPoint
φ ψ : Formula
v : BXPoint
h_wv : bx_le w v
h_ψv : ψ ∈ v.formulas
h_guard : ∀ (u : BXPoint), bx_le w u →
           bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
h_not_psi : ψ ∉ w.formulas
⊢ φ.untl ψ ∈ w.formulas
```

### Attempted

1. `exact?` — **error**: "`exact?` could not close the goal."
2. Tactic skeleton pushing BX4 at `¬(φ U ψ)`:
   ```lean
   by_contra h_neg
   have h_neg_U : (Formula.untl φ ψ).neg ∈ w.formulas := ...
   have h_bx4 : DerivationTree [] ((Formula.untl φ ψ).neg.imp
                 (Formula.all_future (Formula.untl φ ψ).neg.some_past)) :=
     DerivationTree.axiom [] _ (Axiom.connect_future (Formula.untl φ ψ).neg)
   have h_G : Formula.all_future (Formula.untl φ ψ).neg.some_past ∈ w.formulas :=
     SetMaximalConsistent.implication_property w.is_mcs
       (theorem_in_mcs w.is_mcs h_bx4) h_neg_U
   have h_P_v : (Formula.untl φ ψ).neg.some_past ∈ v.formulas :=
     bx_G_forward h_wv h_G
   sorry
   ```
   Typechecks up to `P(¬(φ U ψ)) ∈ v`. To use this, we then need a
   **backward witness**: some `u' ≤ v` with `¬(φ U ψ) ∈ u'`. Applying
   `bx_backward_witness` at `v` yields such a `u'`, but the returned `u'`
   carries only `bx_le u' v` — **not** `bx_le w u'`, so the guard
   `h_guard u' ...` cannot be applied. No contradiction is reachable.

### Outcome — **FAIL**

The formal statement of **B-GAP** is confirmed:

> From `¬(φ U ψ) ∈ w`, BX4 `connect_future` produces `G(P(¬(φ U ψ))) ∈ w`.
> Propagating to `v`, we get `P(¬(φ U ψ)) ∈ v`. A backward witness from `v`
> yields `u' ≤ v` with `¬(φ U ψ) ∈ u'`, but nothing in the axiom set links
> `u'` back to `w`'s future cone (i.e., we cannot establish `bx_le w u'`).
> The linearity gap `w ≤ u'` is exactly what the task 90 recommendation
> claimed to bypass.

BX4's own docstring at `Axioms.lean:142` explicitly disavows the
Burgess-Xu Until-Since connectedness axiom as "not valid under half-open
guard semantics". The backward argument depends on precisely that
disavowed connectedness. This matches Teammate A Key Finding 2 and
Teammate C Issue 2.

## Probe 4 — BX4' `connect_past` Rescue (R4 for B-GAP)

### Strategy tested

Instantiate `connect_past` (BX4', `φ → H(F φ)`) at `v` with the witness
formula `ψ`, yielding `H(F ψ) ∈ v`. Via `bx_H_forward` pulled back to any
`u ≤ v`, this gives `F ψ ∈ u`. Hope: this creates a link between `u` in
`v`'s past cone and `w`.

### Attempted

```lean
by_contra h_neg
have h_bx4p : DerivationTree [] (ψ.imp (ψ.some_future.all_past)) :=
  DerivationTree.axiom [] _ (Axiom.connect_past ψ)
have h_HF : ψ.some_future.all_past ∈ v.formulas :=
  SetMaximalConsistent.implication_property v.is_mcs
    (theorem_in_mcs v.is_mcs h_bx4p) h_ψv
sorry
```

Typechecks. The resulting `H(F ψ) ∈ v` can be pulled to any `u ≤ v` via
`bx_H_forward` to give `F ψ ∈ u`, and then `bx_forward_witness` at `u`
yields a ψ-point reachable from `u`. **None of this establishes
`¬(φ U ψ) ∈ u` at a point `u` with both `bx_le w u` and `bx_le u v`.** The
`bx_backward_witness` primitive (`Frame.lean:176`) takes `P ψ ∈ w` and
returns some `v ≤ w` with `ψ ∈ v` — it provides **no locus control** on the
returned `v`, so it cannot be steered into the `w`-future cone.

### Outcome — **FAIL**

The candidate helper `bx_not_until_backward_pull` has no sound derivation
from the current axiom set. BX4' opens a past cone at `v` and pulls
formulas back, but there is no guarantee any backward-witnessed MCS
intersects `w`'s forward cone. The past cone of `v` and the future cone of
`w` are related by `bx_le`, but BX4'/connect_past alone gives no linking
structure.

## Probe 5 — Derived Until-Persistence Search

### Searches performed

1. `lean_local_search "until_persist"` returned:
   - `Bimodal.Metalogic.Algebraic.DeterministicChain.until_persists_chain`
     (Boneyard — chain construction, deprecated)
   - `Bimodal.Metalogic.Bundle.until_persists_through_succ`
     (SuccRelation-based; operates on step-relations, not `bx_le`)
   - `Bimodal.Metalogic.Algebraic.FiniteDeferral.until_persists_chain_general`
     (Boneyard — chain construction, deprecated)
   - `Bimodal.Metalogic.Algebraic.FiniteDeferral.until_persists_forward_steps`
     (Boneyard — chain construction, deprecated)

2. `lean_local_search "G_until"` — **0 hits**.

3. `lean_local_search "or_until_imp"` — **0 hits by exact name**, but
   Teammate B confirmed its existence at
   `Theories/Bimodal/Theorems/TemporalDerived.lean:338` as
   `(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`. This is the **expansion-law direction**
   consumed by BX6 absorption; it does not propagate Until along `bx_le`.

### Outcome — **FAIL** (no applicable persistence lemma)

All "Until persistence" hits live in the Boneyard (deprecated chain
constructions) or in the `Bundle/SuccRelation` layer (step-relations, not
`bx_le`). None operates on `bx_le := g_content ⊆`. This empirically
confirms — independent of Teammate B's prior-art survey and
DovetailedChain.lean's known failure mode — that **no BX-axiom-derived
Until-forward-persistence lemma exists** for the BXPoint partial order.
`or_until_imp` remains available as a BX6-direction helper but does not
close the propagation gap.

## Probe 6 — BX11 `temp_linearity` Role and Since-Mirror Asymmetry Walk

### BX11 role

BX11 `temp_linearity` (verified at `Axioms.lean:240-244`) states:
```
F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)
```
and is documented in `LinearityDerivedFacts.lean` as **not derivable** from
BX1–BX10. It is a **formula-level** linearity on `F`-witnesses within a
single MCS. It does **not** give BXPoint-level comparability between two
arbitrary MCSes in the future cone — that would require a metalogic bridge
identical to the one `bx_le_linear` would need, which task 90 ruled
non-derivable.

In the task 90 Burgess-Xu kernel, BX11 plays **no constructive role**:
- The forward direction needs `φ ∈ u` at arbitrary strict-interval `u`,
  which requires something to propagate `φ U ψ` (or a derived form) to
  `u`. BX11 is about `F`-formulas, not `U`-formulas, and its conclusion
  remains inside one MCS.
- The backward direction needs linking `u'` (a backward witness from `v`)
  to `w`'s future cone. BX11 does not produce a bridge lemma of that kind.

### Since-mirror asymmetry walk (Teammate C Issue 5, verified)

The `bx_since_eventuality_resolution` signature at `Frame.lean:687-688`:
```
∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas
```

The guard universal quantifies over `u` simultaneously in:
- **`v`'s future cone** (via `bx_le v u`), and
- **`w`'s past cone** (via `bx_le u w`).

Unlike the Until case, where the interval `[w, v]` has a single anchor at
`w` (the origin MCS) and a constructed end `v`, the Since case places `u`
in a **two-anchor interval** where both endpoints are specified: `v` is
the existentially chosen past witness and `w` is the universally given
origin. A Since-mirror helper lemma cannot be a `.symm` or `.dual`
renaming of an Until helper because:

1. `bx_le v u` uses `g_content(v) ⊆ u.formulas` — forward propagation from
   `v`.
2. `bx_le u w` uses `g_content(u) ⊆ w.formulas` — forward propagation from
   `u`. (This is the reverse of what a naive past-direction mirror would
   need: the duality `H` ↔ `G` does not flip `g_content` — it introduces
   `h_content` in a way the Until case does not use.)

A Since rescue (hypothetical task 94 sibling for Since) would need a
**standalone** past-direction propagation lemma, not a mirror rename. This
roughly doubles the scope of any future rescue effort and strengthens the
BLOCKED verdict.

### Outcome — **FAIL** (no BX11 role; mirror asymmetry confirmed)

BX11 is a red herring for the task 90 Burgess-Xu kernel. The Since-mirror
duals cannot be obtained by formal mirror rewriting; the asymmetry in the
guard interval anchors means Since helpers must be independently designed
and proven.

---

## Escalation Decision

**Gate condition**: (Probe 1 FAIL AND Probe 2 FAIL) OR
(Probe 3 FAIL AND Probe 4 FAIL)

**Actual state**:
- Probe 1: FAIL
- Probe 2: FAIL
- Probe 3: FAIL
- Probe 4: FAIL
- Probe 5: FAIL (no applicable persistence lemma)
- Probe 6: FAIL (BX11 inapplicable; mirror asymmetry confirmed)

Both disjuncts of the gate are triggered. **NO-GO / BLOCKED.**

### Recommended next action

Per `plans/02_burgess-xu-until-plan.md` Risks rows 1–2 and Rollback item 2:

1. Orchestrator to invoke `/spawn 92` with blocker description:
   **"BX5 propagation gap and BX4 connectedness disavowal both unrescued
   in diagnostic Phase 0"**
2. Set task 92 status to `[BLOCKED]` pending the spawned task(s).
3. Do NOT commit sorries. The four sorries at `Frame.lean:653, 675, 690,
   704` remain untouched per scope fence.
4. Preserve the existing `Frame.lean:585-622` and `:647-651` linearity-gap
   documentation; these probes **confirm** its accuracy (per Teammate C
   Issue 4) — it should be extended with a Phase 0 diagnostic addendum as
   part of the eventual task 94 research/plan, not rewritten.

### Rescue helper name proposals (for task 94 research)

These names did NOT pass Phase 0 validation. They are recorded as
**failed** candidates so task 94 can cite them in its research frame:

- `bx_earliest_until_witness` — proposed rescue for Gap U5 via BX7
  two-formula form. **Does not discharge the guard** (probe 2).
- `bx_not_until_backward_pull` — proposed rescue for B-GAP via BX4' /
  `connect_past`. **Does not link backward witness to `w`-cone**
  (probe 4).
- `bx_earliest_since_witness` / `bx_not_since_backward_pull` — Since
  mirrors. **Cannot be derived by mirror rename** (probe 6).

### Candidate pivots for task 94 (out of scope for this report)

- Re-examine Option A (redefine `bx_le` via Until-based witness
  ordering) despite task 90's non-equivalence findings — possibly with a
  layered definition that preserves Box/G truth lemmas.
- Quasimodel / Hintikka-set pivot (task 90 ruled out for scope, but may
  be necessary).
- New derived helpers built from `generalized_temporal_k` + BX4 + BX5 +
  BX6 + BX10, searched beyond a single investigation pass.
- Filtration of the canonical model (Teammate B identified this but
  noted ≥40h rebuild risk).

These are **research directions**, not commitments. The spawned task 94
should decide the pivot.

## References

- Plan: `specs/092_implement_bx_until_truth_lemma/plans/02_burgess-xu-until-plan.md`
- Research round 01: `specs/092_implement_bx_until_truth_lemma/reports/01_inherited-from-task90.md`
- Research round 02 synthesis: `specs/092_implement_bx_until_truth_lemma/reports/02_team-research.md`
- Teammate A (validator): `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-a-findings.md`
- Teammate B (alternatives): `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-b-findings.md`
- Teammate C (critic): `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-c-findings.md`
- Source file: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-704`
- Axiom definitions: `Theories/Bimodal/ProofSystem/Axioms.lean:140-264`
