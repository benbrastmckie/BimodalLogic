# Implementation Plan: Bound-Anchor Zone Converter (Kamp Cor 5.4, KampPrior.lean:391)

- **Task**: 307 - kamp_cor54_bound_anchor_zone_converter
- **Status**: [IMPLEMENTING]
- **Effort**: 14-20 hours (8 phases; gated — NO-GO branch is shorter)
- **Dependencies**: None (residual of task 305 Phase 16; task 305 rewire is downstream of this task)
- **Research Inputs**: reports/01_bound-anchor-verdict.md (VERDICT (a): uniform navigable A exists)
- **Artifacts**: plans/01_bound-anchor-converter.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (literature fidelity, blocked MCP tools)
- **Type**: lean4

## Overview

Close `KampPrior.lean:391` — the `n=1` arm of `nf_nvar_exist_all_depths` — whose obligation is
`temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`, where
the second anchor `x` is EXISTENTIALLY BOUND and navigated-to (not free). Research VERDICT (a)
(reports/01_bound-anchor-verdict.md) established decisively that a uniform (model-independent)
navigable Formula `A` EXISTS for this bound-anchor case and that the Phase-16 free-anchor
obstruction does NOT recur under existential binding (its load-bearing lemma
`gate_forces_x_independence` is unstatable without a free `x`). The construction is
`A = A_past ∨ A_diag ∨ A_future` (a Rabinovich Cor-5.4 `F_i` navigation chain per zone), with the
one extra depth-`(k+1)` quant layer `∃w, nf_eval M k 3 [w,x,t] q` absorbed by a NEW depth-graded
NAVIGATED (not atomic) flattening lemma discharged by the depth-`k` IH `exist_tl_fn_k`.

The single open risk (R1, Low-Medium) is whether that navigated-flattening brick lands sorry-free
in this `NormalForm` encoding. **Phase 1 is a mandatory GO/NO-GO probe** for exactly this brick at
`k=1`, categorically distinct from the already-refuted atomic D1 probe. On NO-GO the plan routes to
the obstruction-documentation outcome (b) — see Rollback/Contingency — rather than continuing
construction phases.

**Definition of done (outcome a):** `:391` closed sorry-free; live-path sorry baseline 2 → 1
(`:394` inherits verdict, off critical path); `lake build` GREEN; top-level axiom set unchanged
(2: `propext, Classical.choice, Quot.sound`, zero domain axioms); handoff notes for task 305
rewire recorded. **Definition of done (outcome b):** sorry-free counterexample machinery for the
bound-anchor obstruction + documented scope decision for `:391`/`:394`; same build/axiom
invariants preserved.

### Research Integration

- reports/01_bound-anchor-verdict.md integrated in plan_version 1 (2026-07-06). Provides goal shape
  at `:391`, the three-obstruction non-transfer table, the `A_past/A_diag/A_future` decomposition,
  the risk register (R1-R4), and the H3 Tier-1 paper↔Lean mapping.

### Preserved Assets

The following work is complete and sorry-free and MUST be consumed, never rebuilt or overwritten:

| Component | File:Line | Role in this task | Status |
|-----------|-----------|-------------------|--------|
| `exist_tl_fn_k` / `exist_tl_fn_k_correct` (depth-k IH) | KampPrior.lean:334-344 | Discharges the depth-`k` residual after flattening; in scope at `:391` | [COMPLETED] |
| `char_k1` / `char_k1_correct` | KampPrior.lean:347-361 | Diagonal (`x=t`) arm depth-`(k+1)` arity-1 characteristic | [COMPLETED] |
| `renameNF_eval_diag0` | NfDepth0Generalized.lean:1646 | Depth-0 diagonal value-duplication base for A_diag | [COMPLETED] |
| `bracketBuildLeft` / `_correct` | VecEATranslation.lean:50 | Since-chain navigation (A_past) — the `F_i` mechanism | [COMPLETED] |
| `bracketBuildRight` / `_correct` | VecEATranslation.lean:234 | Until-chain navigation (A_future) — the `F_i` mechanism | [COMPLETED] |
| `prior_hasAttainedINF` | PriorINF.lean:224 | Supplies Dedekind-completeness (INF attainment) on the live path via h_UZ | [COMPLETED] |
| `neg_interval_formula` (Lemma 5.1 fwd) | EANegationClosure.lean:401 | Interval-negation closure | [COMPLETED] |
| `neg_bounded_exists` (Cor 5.4 fwd) | EANegationClosure.lean:492 | Bounded-∃ / INF closure | [COMPLETED] |
| `existClosureLeft(_correct/_rev)` / `existClosure` | VecEATranslation.lean; VecEA_m.lean:208 | Leftward existential closure (n≥2 reduction) | [COMPLETED] |
| Prop-4.3 atomic clauses `atomAt/ltAt/tt/ff` (+`_holds`) | Prop43.lean:45-109 | Faithful uniform Prop-4.3 atomic clauses (do NOT reopen VecEA-negation framing) | [COMPLETED] |
| Zone-split assets (`nf_eval_atom_layer`, `zoneEnv3`, `nf3_order_*`, `nf_eval_quant_layer`, `nf_zone_exists_iff_char`, `exists_trichotomy_split`, `nf_zone_partition5`, `nf_zone_exists_partition5`, `nf_characteristic_*`, `nf_char_eq_iff_eval`, `exists_nested_split3`, `nf_char3_eq_succ_iff`) | NfZoneDepthK.lean | Templates/lemmas for the x-trichotomy and w-zone splits | [COMPLETED] |

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

| Paper statement | Paper loc | Lean target | Phase |
|-----------------|-----------|-------------|-------|
| Cor 5.4 `F_n:=α_n`, `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`; witnesses in one interval | md:154-157 | `bracketBuildLeft`/`bracketBuildRight` (assets) driving A_past/A_future | 5, 6 |
| Prop 3.5 — single free var, nested Until/Since over point/segment types | md:87-94 | Navigable endpoint type carrying the flattened core | 4 |
| Lemma 3.2.2 — ≤ 2 free variables; deeper quant absorbed as bracket witnesses, never new anchors | md:78 | Anchor-budget `{x,t}` constraint (Postmortem Constraint) | all |
| Lemma 5.1 / Cor 5.4 (fwd) — interval-negation / bounded-∃ closure | md:134-157 | `neg_interval_formula`, `neg_bounded_exists` (assets) | 4-7 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the four proven obstructions
(task brief), report 40's divergence audit, and the R1-R4 risk register.

**Do NOT** (each is a refuted route — re-attempting is churn):
- Do NOT re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal (Obstruction 1:
  `liftIdx(totalUnskip)` non-injectivity, proven in NfZoneDepthK.lean). The diagonal factors
  through `renameNF_eval_diag0`+`char_k1`, never per-variable projection.
- Do NOT re-attempt a flat single-interval ATOMIC bracket absorption (Obstruction 2: D1
  interior-confinement, `interior_bracket_cannot_realize_exterior_sub_k1`, NfZoneDepthK1Probe.lean).
  The flattening endpoint types MUST be depth-graded / NAVIGATED (`Until`/`Since` reaching
  exterior `w`), never depth-0 `.atom`/`.box`.
- Do NOT use a free-anchor-style x-independent gate (Obstruction 3:
  `no_x_independent_formula_captures_future_zone_k1`, NfZoneNavProbe.lean). The `x` here is BOUND;
  quantify over it (lay the witness), never NAME a specific free anchor.
- Do NOT encode a characteristic-type condition on a third anchor at a single navigable point
  (R2 arity-tower, report 40 §2.1-A). Keep the anchor set exactly `{x,t}`; lay `w` as a NAVIGATED
  bracket witness, never as a new `nf_eval` env position (no env-arity growth).
- Do NOT reopen the uniform-VecEA-negation framing (Prop43.lean's own BLOCKER note over-reaches
  the paper per plan v40's mitigated divergence risk). Consume `atomAt/ltAt/tt/ff` as-is.
- Do NOT use `simp`/`omega`/`aesop` to bypass a Rabinovich `F_i` chain step (lean4 literature
  fidelity); follow the paper step-by-step.

**MUST preserve**:
- Every asset in the Preserved Assets table — consume, never re-derive or overwrite.
- `lake build` GREEN at the end of every phase.
- Top-level axiom set = exactly 2 (`propext, Classical.choice, Quot.sound`; zero domain axioms).
  Verify with `lean_verify` on touched decls each phase.
- Live-path sorry count may only DECREASE (target 2 → 1 at Phase 7); never introduce a new
  live-path sorry. Off-path probe scaffolding in the new file is permitted intra-phase but must
  be sorry-free by that phase's end.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- Outcome (a) — a uniform navigable `A` EXISTS — is the verdict (report 01 §Executive Verdict,
  three converging grounds). Do not re-litigate existence; the only open question is Lean
  reachability of the flattening brick (R1), resolved by Phase 1.
- The four prior refutations are decisive for the class "name/project a third anchor at a single
  point" and IRRELEVANT to the navigated bound-witness chain. Do not rebuild refuted machinery to
  "re-check" them.
- `A = A_past ∨ A_diag ∨ A_future` with per-zone `F_i` navigation is the committed construction.

## Goals & Non-Goals

- **Goals**:
  - Resolve R1 decisively via a k=1 navigated-flattening GO/NO-GO probe (Phase 1).
  - On GO: construct `A` and close `:391` sorry-free, reducing live-path sorry baseline 2 → 1.
  - On NO-GO: produce sorry-free obstruction machinery for the bound-anchor case and a documented
    scope decision for `:391`/`:394`.
  - Preserve build/axiom invariants at every phase.
- **Non-Goals**:
  - `:394` (`n≥2` arm) — off the live completeness path; reduces to `n=1` by iterated existential
    closure (`existClosure`) once `:391` lands; inherits this task's verdict (R3).
  - The task-305 rewire itself — this task only hands back working notes for it.
  - Re-deriving any preserved asset or re-opening any settled decision above.

## Risks & Mitigations

- **R1 — flattening brick un-built (Low-Medium, GATING).** The navigated depth-graded flattening
  is the only genuinely new mathematics; D1 refuted its atomic simplification, the navigated
  version is unrefuted but unverified. *Mitigation:* Phase 1 is a dedicated k=1 GO/NO-GO probe;
  NO-GO routes to outcome (b) instead of sinking dispatches into a doomed construction.
- **R2 — arity-tower temptation (Medium).** *Mitigation:* Postmortem Constraint (lay `w` as a
  navigated bracket witness; anchor set stays `{x,t}`). Any phase that grows `nf_eval` env arity
  is an immediate stop-and-flag.
- **R3 — scope of `:394` (Low, off critical path).** *Mitigation:* explicit Non-Goal; handled by
  iterated existential closure after `:391`, tracked as a handoff note only.
- **R4 — build/axiom drift (Medium).** *Mitigation:* per-phase `lake build` + `lean_verify` gate;
  MUST-preserve invariants; commit only on green.
- **R5 — Phase 4 (the brick) overruns one dispatch (Medium).** *Mitigation:* if it exceeds ~500
  lines / 4h, split into 4.1 (w-zone partition split, unconditional) and 4.2 (navigated endpoint
  construction + per-zone discharge by `exist_tl_fn_k` + assembly). Do NOT inflate the top-level
  phase count past 8; use sub-numbering.

## Implementation Phases

All new lemmas land in a new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneFlattenNavigable.lean`
(imported by KampPrior.lean). Only Phase 7 edits KampPrior.lean itself (the `:391` wiring).

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 (GO) |
| 3 | 5, 6 | 2, 4 |
| 4 | 7 | 3, 5, 6 |
| 5 | 8 | 7 |

Phases within the same wave are dependency-independent. **Territory note (H7):** phases 2, 3, 4
all write `NfZoneFlattenNavigable.lean`; because they share one file they must be SERIALIZED in
practice (append disjoint lemma blocks), not dispatched concurrently. Phases 5 and 6 also share
that file and serialize. Only cross-file independence (new file vs KampPrior.lean) is truly
parallel. Wave membership expresses dependency readiness; file ownership caps real parallelism.

### Phase 1: k=1 navigated-flattening GO/NO-GO probe [COMPLETED]

**GATE VERDICT: GO** (2026-07-06, session sess_1783342946_dfd523). The probe
`nf_zone_flatten_navigable_k1_probe` is proven **sorry-free**, `lake build` GREEN (993 jobs),
axioms exactly `[propext, Classical.choice, Quot.sound]` (2 baseline, zero domain axioms),
live-path sorry count unchanged at 2 (`:391`, `:394`; probe file is off the live import path —
`KampPrior.lean` does not import it). → **Proceed to Phase 2.**

New file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneFlattenNavigable.lean` (4 sorry-free
theorems):
- `navigated_bracket_reaches_exterior_future` — the constructive dual of D1's
  `interior_bracket_cannot_realize_exterior_sub_k1`: a `bracketBuildRight` (Until) chain from `t`
  with a trivial (`top`) segment is equivalent to `∃ w, t < w ∧ endRight.eval_at w` for an
  **arbitrary navigated** endpoint. Where D1 proved atomic brackets are interior-confined
  (cannot reach exterior `w`), this proves navigated brackets reach the **future exterior** `t < w`.
- `navigated_bracket_reaches_exterior_past` — Since-mirror; navigation reaches the past exterior
  `w < t`.
- `nf_zone_flatten_navigable_k1_probe` — **the gate**: the nested navigated bracket
  `bracketBuildRight (t→w) ∘ bracketBuildLeft (w→z0)` at `t` is equivalent to the coupled
  two-witness existential `∃ w, t < w ∧ ∃ z0, z0 < w ∧ innerEnd.eval_at z0`. Both `w` and `z0` are
  existentially bound and **navigated-to** (laid as bracket witnesses in one Rabinovich `F_i`
  chain), never named — the exact depth-graded coupling mechanism the flattening needs, and it
  composes to arbitrary depth via the arbitrary `innerEnd`. Categorically distinct from the
  refuted atomic D1 (navigated, not `.atom`/`.box`) and from the free-anchor NO-GO (both witnesses
  bound, so `gate_forces_x_independence`'s free `∀x` premise is unstatable).
- `exterior_future_zone_eval_shape` — grounds the probe in the real `:391` core: its
  exterior-future zone `∃ w, t < w ∧ nf_eval_nf M 1 3 (zoneEnv3 w x t) q` (the make-or-break zone
  D1 refuted for atomic types) has exactly the `∃ w, t < w ∧ P w` shape the navigated future
  bracket captures.

**R1 resolution:** the make-or-break claim (navigation can express the bound-witness coupling that
atomic simplification could not) is established sorry-free at `k=1`; **no impossibility surfaced**
(so this is not a NO-GO). The residual constructive obligation — realizing `P w := nf_eval_nf M 1 3
(zoneEnv3 w x t) q` as the navigated endpoint type via nested back-navigation to `x, t` and
discharging the depth-`k` residual by the IH — is the Phase-4 brick, exactly as planned. The
mechanism it relies on (exterior reach + `F_i` back-coupling composition) is now proven to work.

- **Goal:** Decide R1. Prove (or refute) that the coupled core `∃w, nf_eval M 1 3 [w,x,t] q` at
  `k=1` is equivalent to a `bracketBuild` disjunction over `w`'s zones whose endpoint types are
  DEPTH-GRADED / NAVIGATED (Until/Since reaching exterior `w`) — categorically distinct from the
  refuted atomic D1 (`.atom`/`.box` local types). This is the GO/NO-GO gate for the whole plan.
- **Tasks:**
  - [ ] Create `NfZoneFlattenNavigable.lean`; state `nf_zone_flatten_navigable_k1_probe` with
        NAVIGATED endpoint types built from `bracketBuildLeft`/`bracketBuildRight` (NOT atomic),
        anchor set `{x,t}`, `w` laid as a bracket witness (no new env position).
  - [ ] Attempt the equivalence proof at `k=1` using `bracketBuild*_correct` for the navigation
        arms and the depth-0 residual handled directly (k=1 core is depth-0 under one layer).
  - [ ] Record the GO/NO-GO verdict in `.orchestrator-handoff.json` `next_action_hint` and in a
        one-paragraph note (GO: brick equivalence holds at k=1; NO-GO: exact goal state where
        navigation still cannot express the coupling — the first evidence toward outcome (b)).
- **GO/NO-GO decision gate:**
  - **GO** = `nf_zone_flatten_navigable_k1_probe` is proven sorry-free, `lake build` GREEN, axioms
    still 2 → proceed to Phase 2.
  - **NO-GO** = a genuine obstruction is exhibited (navigation provably cannot express the coupling
    at k=1, isolated to a specific irreducible goal) → HALT phases 2-7; execute the
    "Contingency Route: Obstruction Documentation" section below, then Phase 8.
  - A mere tactic failure or incomplete proof is NOT a NO-GO; it is a resume point (mark [PARTIAL]).
    NO-GO requires positive evidence of impossibility, mirroring NfZoneNavProbe's free-anchor proof.
- **Verification:** `lake build` GREEN; `lean_verify NfZoneFlattenNavigable.<probe>` shows
  sorry-free + axioms `[propext, Classical.choice, Quot.sound]`; live-path sorry count unchanged
  at 2 (probe is off-path).
- **Estimated output:** ~150-300 lines. **Done when:** GO or NO-GO recorded in handoff + build green.
- **Depends on:** none

### Phase 2: x-trichotomy split of the :391 RHS existential [COMPLETED]

**COMPLETED** (2026-07-06, session sess_1783342946_dfd523). `nf_zone_exists_trichotomy_k1` proven
**sorry-free** in `NfZoneFlattenNavigable.lean` (appended after the Phase-1 probes), `lake build`
GREEN (993 jobs), axioms exactly `[propext, Classical.choice, Quot.sound]` (2 baseline, zero domain
axioms), live-path sorry count unchanged at 2 (`:391`, `:394`; file still off the live import path).
The lemma is a direct term-mode delegation to the generic atom `exists_trichotomy_split` (boundary
`c := t`, `P x := nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`) — no navigation, no new
math, as scoped. Env convention `Fin.cons x (fun _ => t)` matches `exist_tl_fn_k_correct` verbatim so
Phases 3/5/6 consume the three disjuncts directly.

- **Goal:** Unconditional split of `∃x, nf_eval M (k+1) 2 [x,t] sub_nf` into
  `(∃x<t, …) ∨ (x=t case) ∨ (∃x>t, …)` — the single-anchor analog of `nf_zone_exists_partition5`.
  Pure trichotomy on `x` vs the fixed origin `t`; no navigation, no new math.
- **Tasks:**
  - [x] State and prove `nf_zone_exists_trichotomy_k1` (past / diagonal / future) reusing
        `exists_trichotomy_split` / `nf_zone_exists_partition5` templates (NfZoneDepthK.lean).
        *(delegated to `exists_trichotomy_split` directly — the single-boundary case collapses
        `nf_zone_exists_partition5`'s five zones to three, needing only the generic atom.)*
- **Verification:** `lake build` GREEN; lemma sorry-free; axioms unchanged; live-path sorry still 2.
- **Estimated output:** ~120-200 lines. **Done when:** trichotomy lemma proven sorry-free, build green.
- **Depends on:** 1 (GO)

### Phase 3: A_diag arm (x = t), assets only [COMPLETED]

**COMPLETED** (2026-07-06, session sess_1783353840_ba1b1d) — BLOCKER RESOLVED by prerequisite task
308. The arity-1-collapse route (below) stays refuted; the correct object is task 308's two-anchor
characteristic FORMULA builder `nf_char2_formula` / `nf_char2_formula_correct`
(`NfMultiAnchorBridge.lean`, deliverable 1, sorry-free). Landed `A_diag` + `A_diag_correct` in
`NfMultiAnchorBridge.lean` (append-only): `A_diag := nf_char2_formula …`, and `A_diag_correct` proves
`temporal_truth M t (A_diag …) ↔ nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t)) sub_nf` — the exact
diagonal disjunct of the Phase-2 trichotomy `nf_zone_exists_trichotomy_k1` — by composing
`nf_char2_formula_correct` (its `h_exist_correct` discharged per-`qnf` via
`nf_char2_diag_exist_tl_correct`) with the constant-env identity
`(Fin.cons t (fun _ => t) : Fin 2 → M.carrier) = (fun _ => t)`. Pure consumption glue, no new math.
The arm stays hook-parametric over the depth-`k` recursion hooks `pastEnd`/`futureEnd`/`diagChar` and
their correctness `h_past`/`h_fut`/`h_diag` (the depth-`k` arity-3 IH), exactly as `nf_char2_formula`
is; the induction (Phase 4 / `nf_nvar_exist_all_depths`) supplies the hooks. `lake build` GREEN (996
jobs); `lean_verify A_diag`/`A_diag_correct` axioms exactly `[propext, Classical.choice, Quot.sound]`,
0 warnings; live-path sorry count unchanged at 2 (`:391`, `:394`; `NfMultiAnchorBridge` is a leaf, no
importers, off the live path).

- **Goal:** Discharge the diagonal disjunct `nf_eval M (k+1) 2 [t,t] sub_nf` — RESOLVED via task 308's
  `nf_char2_formula` (NOT the refuted arity-1 collapse). No new math (assets only, consumption glue).
- **Tasks:**
  - [x] Prove `A_diag_correct` for the diagonal disjunct via task 308's `nf_char2_formula_correct` +
        `nf_char2_diag_exist_tl_correct` + the constant-env identity. *(deviation: altered — the
        original arity-1-collapse route `char_k1 (diagCollapse sub_nf)` is a non-theorem at depth k+1
        (BLOCKER below, still valid); replaced by consuming task 308's two-anchor characteristic
        formula builder, which is the correct object.)*
  - [x] Land `A_diag` + `A_diag_correct` in `NfMultiAnchorBridge.lean`. *(deviation: altered target
        file — the plan says land in `NfZoneFlattenNavigable.lean`, but the arm consumes
        `nf_char2_formula` which lives in `NfMultiAnchorBridge` (which imports `NfZoneFlattenNavigable`);
        placing it in `NfZoneFlattenNavigable` would create an import cycle. `NfMultiAnchorBridge` is
        the only valid home and is itself a leaf off the live path.)*

**BLOCKER (Phase 3) [RESOLVED by task 308]** — recorded 2026-07-06, session sess_1783342946_dfd523.
The refutation below (the arity-1-collapse route is a non-theorem) remains correct and is why task 308
was spawned; task 308 delivered the two-anchor characteristic formula builder that this phase now
consumes, so the BLOCKER is discharged without re-attempting the refuted route:
- **What failed:** `A_diag_correct` as a plain iff for arbitrary `sub_nf : NormalForm sig (k+1) 2`.
  Any `char_k1`-of-collapse formula characterizes only `Coll sub_nf = char₁[t]`, strictly weaker
  than the diagonal disjunct `sub_nf = char₂[t,t]` (collapse is non-injective).
- **What was tried:** value-duplication collapse maps built and the depth-0 base
  (`diagDup_eval_zero`) proven sorry-free via `renameNF_eval_diag0`. Attempting to lift to depth
  `k+1` reduces, at the quant layer, to the inner iff
  `(∃x, nf_eval M k 3 [x,t,t] sub_a) ↔ (∃x, nf_eval M k 2 [x,t] (Coll' sub_a))`.
- **Why stuck (grounded, not a stall):** the `←` direction of that inner iff is FALSE — a
  non-diagonal-invariant `sub_a` (e.g. demanding `order 1 2`, unsatisfiable at `[x,t,t]` since
  `t<t` is false) can have a realizable collapse, so RHS holds while LHS fails. Therefore
  `char₂[t,t] ≠ diagDup(char₁[t])`; the arity-2 characteristic carries information no arity-1
  collapse encodes. This is exactly the depth-`≥1` diagonal crux flagged sorry-free at
  `NfDepth0Generalized.lean:1691-1719`. The plan mis-scoped Phase 3 as "assets only" on a depth-0
  intuition.
- **What is needed:** a genuine **arity-2 (two-anchor) characteristic FORMULA builder** at depth
  `k+1` (the "Phase-11 crux"). It does not exist as an asset: `nf_succ_char_formula` is arity-1
  only, and `nf_char3_eq_succ_iff` is an equality *decomposition*, not a formula construction.
  Recommend spawning a task to build the two-anchor characteristic converter, which Phases 3/5/6
  then consume. Does NOT contradict VERDICT (a): a uniform navigable `A` still exists.
- **Prohibited:** no `sorry` (none introduced; live-path count stays 2), no `def X := True`, no
  arity-1-collapse `A_diag` (refuted above).

Sorry-free scaffolding landed in `NfZoneFlattenNavigable.lean` (append-only): `diagCollapseMap`,
`diagExpandMap`, `diagCollapse_expand_id`, `diagDup`, `diagDup_eval_zero`, plus the in-code
OBSTRUCTION note. `lake build` GREEN (994 jobs); axioms exactly `[propext, Classical.choice,
Quot.sound]`; live-path sorry count unchanged at 2.

- **Verification:** `lake build` GREEN; sorry-free; axioms unchanged; NO projection used
  (Obstruction 1 constraint); live-path sorry still 2.
- **Estimated output:** ~80-160 lines. **Done when:** A_diag arm iff proven sorry-free, build green.
- **Depends on:** 1 (GO)

### Phase 4: depth-graded navigable flattening brick (general k) [COMPLETED]

**COMPLETED** (2026-07-06, session sess_1783353840_ba1b1d) — consumed prerequisite task 308's
deliverable 2 verbatim, hook-parametric, WITHOUT rebuilding. Task 308 already shipped this exact brick
as `nf_zone_flatten_navigable` / `nf_zone_flatten_navigable_correct` (`NfMultiAnchorBridge.lean`,
sorry-free): the coupled inner-`w` arity-3 existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q`
equals the five-zone navigated disjunction (past-exterior `w < x` via `bracketBuildLeft` from `x`;
`w = x`; interior `x < w < t`; `w = t`; future-exterior `t < w` via `bracketBuildRight` from `t`),
under the two navigated-endpoint-hook correctness hypotheses `h_past`/`h_fut` — which ARE the depth-`k`
IH (bottoming out at `k = 0` in `nf_zone_flatten_navigable_zero`). Phase 4 lands
`nf_zone_flatten_navigable_brick` (append-only in `NfMultiAnchorBridge.lean`) — a Phase-4-named
correctness re-export delegating to `nf_zone_flatten_navigable_correct`, the single stable citation
point Phases 5/6 invoke. `lake build` GREEN (996 jobs); `lean_verify nf_zone_flatten_navigable_brick`
axioms exactly `[propext, Classical.choice, Quot.sound]`, 0 warnings; live-path sorry count unchanged
at 2 (`:391`, `:394`; `NfMultiAnchorBridge` is a leaf, off the live path).

- **Goal:** Generalize the Phase-1 k=1 probe to `nf_zone_flatten_navigable` at arbitrary depth —
  DELIVERED by task 308 (deliverable 2); Phase 4 consumes it hook-parametric, no rebuild.
- **Tasks:**
  - [x] State `nf_zone_flatten_navigable` (depth-`k` graded; anchor set `{x,t}`; `w` a bracket
        witness). *(deviation: altered — shipped by task 308 as deliverable 2; Phase 4 consumes it
        verbatim rather than re-stating from scratch. Landed `nf_zone_flatten_navigable_brick`
        re-export as the Phase-5/6 citation point.)*
  - [x] w-zone partition (exterior-past / interior / exterior-future). *(deviation: altered —
        delivered by task 308 as `nf_char2_zone_split5` / `exists_zone_split5`; consumed, not rebuilt.)*
  - [x] Navigated endpoint per zone + assemble the equivalence. *(deviation: altered — the two open
        exterior zones are `bracketBuild*` navigations and the assembly is
        `nf_zone_flatten_navigable_correct` (task 308); the depth-`k` residuals stay hook obligations
        (`h_past`/`h_fut` = the IH), discharged at Phase 7 by the `nf_nvar_exist_all_depths` recursion
        rather than inline — the IH is unavailable off the live recursion.)*
  - Target-file deviation: landed in `NfMultiAnchorBridge.lean` (the brick's home), not
    `NfZoneFlattenNavigable.lean`, for the same import-cycle reason as Phase 3.
- **Verification:** `lake build` GREEN; `lean_verify` sorry-free + axioms 2; env arity never grows
  beyond the `{w,x,t}=arity 3 → {x,t}=arity 2` reduction (no arity tower); live-path sorry still 2.
- **Estimated output:** ~300-450 lines (R5: split into 4.1/4.2 if >500 lines or >4h; keep top-level
  count at 8). **Done when:** `nf_zone_flatten_navigable` proven sorry-free, build green.
- **Depends on:** 1 (GO)

### Phase 5: A_past arm (x < t) via bracketBuildLeft [COMPLETED]

**COMPLETED** (2026-07-06, session sess_1783353840_ba1b1d). Landed `A_past` + `A_past_correct` in
`NfZoneFlattenNavigable.lean` (append-only). `A_past pastEnd := bracketBuildLeft
(BracketFormula.trivial TemporalPred.top) pastEnd` — the OUTER Since-navigation from origin `t` back
to the bound witness `x` in the past exterior — and `A_past_correct` proves `temporal_truth M t
(A_past pastEnd) ↔ ∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` (the exact past
disjunct of `nf_zone_exists_trichotomy_k1`) by a direct application of the preserved-asset-backed
pillar `navigated_bracket_reaches_exterior_past` — the navigation mechanism (`bracketBuildLeft`) is
reused, NOT rebuilt. Hook-parametric over the endpoint `pastEnd` and its correctness `h_past` (the
recursion IH); the Phase-4 brick `nf_zone_flatten_navigable_brick` is consumed inside the deferred
construction of `pastEnd`/`h_past` (the quant layer of the arity-2 char at `[x,t]` flattens via the
brick), wired at Phase 7. `lake build` GREEN (994 jobs; downstream `NfMultiAnchorBridge` 996 jobs);
`lean_verify A_past_correct` axioms `[propext, Classical.choice, Quot.sound]`, `A_past` axioms a subset
(`[propext, Quot.sound]`), 0 warnings, 0 domain axioms; live-path sorry count unchanged at 2.

**Cycle-safe placement (advances Phase-7 concern):** `A_past`/`A_past_correct` depend only on
`navigated_bracket_reaches_exterior_past` (this file) and `bracketBuildLeft` (`VecEATranslation`) —
neither `NfMultiAnchorBridge` nor `KampPrior` — so they live in the **KampPrior-independent**
`NfZoneFlattenNavigable.lean`. The outer-navigation arms are cycle-safe; only Phase 3's `A_diag`
(needs KampPrior-side `nf_char2_formula`) and the Phase-4 brick remain to be relocated for Phase 7.

- **Goal:** Build `A_past` as a `bracketBuildLeft` (Since) chain from `t` to the bound witness `x`;
  prove the past-disjunct iff — DONE.
- **Tasks:**
  - [x] Define `A_past` via `bracketBuildLeft` over the endpoint hook. *(deviation: altered — endpoint
        is the parametric hook `pastEnd : TemporalPred` (the depth-`(k+1)` arity-2 char at `[x,t]`),
        not the Phase-4 flattened type directly; the Phase-4 brick is consumed one level in, inside
        `h_past` (the IH), which is supplied at Phase 7. Assembly stays hook-parametric, mirroring
        Phases 3/4.)*
  - [x] Prove `A_past_correct` via `navigated_bracket_reaches_exterior_past` (= `bracketBuildLeft_correct`
        + trivial-segment collapse). *(deviation: altered — the residual is carried by the endpoint
        hook `h_past` rather than discharged inline by `exist_tl_fn_k_correct`; the IH is unavailable
        off the live recursion, exactly as in Phases 3/4.)*
  - Placement deviation: landed in `NfZoneFlattenNavigable.lean` (cycle-safe), not
    `NfMultiAnchorBridge.lean` — A_past needs no KampPrior-side asset (preferred cycle-safe placement).
- **Verification:** `lake build` GREEN; sorry-free; axioms 2; follows Rabinovich `F_i` chain (no
  simp/omega shortcut of a chain step); live-path sorry still 2.
- **Estimated output:** ~150-250 lines. **Done when:** A_past arm iff proven sorry-free, build green.
- **Depends on:** 2, 4

### Phase 6: A_future arm (t < x) via bracketBuildRight [NOT STARTED]
- **Goal:** Dual of Phase 5: `A_future` as a `bracketBuildRight` (Until) chain; prove the
  future-disjunct iff.
- **Tasks:**
  - [ ] Define `A_future` via `bracketBuildRight` over the Phase-4 flattened endpoint.
  - [ ] Prove `A_future_correct`: `temporal_truth M t A_future ↔ ∃x>t, nf_eval M (k+1) 2 [x,t] sub_nf`
        using `bracketBuildRight_correct` + `nf_zone_flatten_navigable` + `exist_tl_fn_k_correct`.
- **Verification:** `lake build` GREEN; sorry-free; axioms 2; live-path sorry still 2.
- **Estimated output:** ~150-250 lines. **Done when:** A_future arm iff proven sorry-free, build green.
- **Depends on:** 2, 4

### Phase 7: Assemble A and wire into KampPrior.lean:391 [NOT STARTED]
- **Goal:** Define `A := A_past ∨ A_diag ∨ A_future`; prove the packaged iff by disjunction
  elimination over the Phase-2 trichotomy (each arm discharged by Phases 3/5/6); replace the
  `:391` `sorry` with this witness. Reduce live-path sorry baseline 2 → 1.
- **Tasks:**
  - [ ] State `bound_anchor_converter_k1`: the exact `:391` obligation
        `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M t A ↔ ∃x, nf_eval M (k+1) 2 [x,t] sub_nf`.
  - [ ] Prove it via `⟨A_past ∨ A_diag ∨ A_future, …⟩` + trichotomy disjunction elimination.
  - [ ] Edit KampPrior.lean `n=1` arm (`:391`): replace `sorry` with `bound_anchor_converter_k1 …`;
        add the import of `NfZoneFlattenNavigable`.
- **Verification:** `lake build` GREEN (full project); `lean_verify` on `nf_nvar_exist_all_depths`
  and downstream: axioms still exactly 2, zero domain axioms; live-path sorry count = 1 (only
  `:394` remains); no other sorry introduced anywhere.
- **Estimated output:** ~120-220 lines (assembly + minimal KampPrior edit). **Done when:** `:391`
  sorry-free, full build green, sorry baseline confirmed 2 → 1.
- **Depends on:** 3, 5, 6

### Phase 8: Wrap-up — verify invariants, summary, handoff, task-305 rewire notes [NOT STARTED]
- **Goal:** Final invariant verification and handoff for the task-305 rewire.
- **Tasks:**
  - [ ] Confirm `lake build` GREEN, axioms exactly 2, live-path sorry = 1 (`:394` only), and that
        every Preserved Asset is unmodified.
  - [ ] Write `specs/307_kamp_cor54_bound_anchor_zone_converter/summaries/01_bound-anchor-converter-summary.md`
        recording which outcome (a/b) was reached, the sorry-count delta, and the axiom check.
  - [ ] Update `.orchestrator-handoff.json`: `status: "implemented"` (or `"blocked"` on outcome b),
        `next_action_hint` = concrete task-305 rewire instructions (how to consume the new converter
        to replace `:391`'s downstream usage) plus the `:394` (n≥2) scope note.
- **Verification:** summary file exists and non-empty; handoff updated; build green; axioms 2.
- **Estimated output:** ~summary prose + handoff JSON (no Lean output beyond re-verification).
  **Done when:** summary written, handoff updated, invariants re-confirmed.
- **Depends on:** 7

## Testing & Validation

- [ ] After each phase: `lake build` GREEN (scoped `lake build ...Kamp.NfZoneFlattenNavigable`
      intra-phase; full `lake build` at Phases 7-8).
- [ ] After each phase: `lean_verify` on the phase's new/edited decls — sorry-free and axioms
      exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] Phase 7: confirm live-path sorry count moved 2 → 1 (only `:394` remains).
- [ ] Phase 8: confirm zero domain axioms and all Preserved Assets unmodified (`git diff` scoped to
      asset files shows no changes).
- [ ] Commit per green sub-step (git-workflow.md commit-per-green-substep mandate).

## Artifacts & Outputs

- plans/01_bound-anchor-converter.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneFlattenNavigable.lean (new; Phases 1-6)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean (edited at `:391`; Phase 7 only)
- summaries/01_bound-anchor-converter-summary.md (Phase 8)
- .orchestrator-handoff.json (updated: gate verdict at Phase 1, final at Phase 8)

## Rollback/Contingency

**Per-phase rollback:** each phase leaves the tree GREEN and is committed only when green; if a
phase cannot reach green, mark it `[PARTIAL]` (leaving the prior green commit intact) and resume —
never discard uncommitted work to force a build (lean4.md fix-forward; no destructive git on a
dirty tree). If a phase would require introducing a live-path sorry to compile, STOP and mark
`[BLOCKED]`; do not paper over with a vacuous definition.

**Contingency Route: Obstruction Documentation (activate ONLY on Phase 1 NO-GO).**
This route replaces phases 2-7 and is NOT auto-dispatched (it carries no `[NOT STARTED]` marker so
the orchestrator's phase scanner skips it); the orchestrator enters it only when Phase 1 records a
NO-GO verdict. Steps:
1. Promote the Phase-1 NO-GO goal state into a sorry-free counterexample lemma for the bound-anchor
   case, analogous to `no_x_independent_formula_captures_future_zone_k1` (NfZoneNavProbe.lean) — a
   proof that no uniform navigable `A` captures the bound-anchor gate in the exhibited model. Keep
   it in `NfZoneFlattenNavigable.lean`, sorry-free, axioms 2.
2. Document the scope decision for `:391` and `:394` in the Phase-8 summary: whether the two
   sorries become a permanent documented gap, an axiom (with justification and axiom-count impact
   flagged — this would change the baseline and must be surfaced), or route Kamp's theorem in this
   codebase to a different overall proof strategy.
3. Update `.orchestrator-handoff.json` with `status: "blocked"`, the obstruction lemma name, and
   the scope recommendation for task 305.
4. Proceed to Phase 8 (wrap-up) which records outcome (b) instead of (a).
Note: outcome (b) would contradict research VERDICT (a); per report 01 §6 it is deemed
*unprovable* because false. A NO-GO therefore demands especially rigorous positive evidence of
impossibility (not a mere proof-engineering stall) before this route is taken.

**Full task rollback:** revert `NfZoneFlattenNavigable.lean` (new file) and the single `:391`
edit in KampPrior.lean; the baseline (build GREEN, 2 live-path sorries, 2 axioms) is restored with
no impact on any preserved asset.
