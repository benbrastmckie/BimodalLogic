# Implementation Plan: Task #349 (v4 — reduction-navigated arity-3 endChar)

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction` family, green, sorry-free, 0-new-axiom)
- **Research Inputs**:
  - Task 351 deliverable `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean` (the AUTHORITATIVE unblocker — the Rabinovich Lemma 3.2(2) ≤2/≤3-free-variable reduction of `nf_eval_nf`; the driver of this revision)
  - reports/02_rabinovich-faithfulness-audit.md (§Q4 target 4 + H3 mapping — establishes the reduction-first line as the paper-faithful architecture; §Q3/§H4 refute the retired single-anchor/climbing lines)
  - reports/03_spawn-blocker-analysis.md (the world-locality infeasibility of the v3 climbing base; specifies the reduction as the only faithful exit)
  - reports/01_endchar-faithful-architecture.md (partially superseded: "navigate-not-collapse" survives; "arity climbs to n+1" is now CAPPED at 3 by the task-351 reduction)
- **Artifacts**: plans/04_reduction-navigated-endchar.md (this file); supersedes plans/03_multi-anchor-navigating-characteristic.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [01_endchar-faithful-architecture.md, 02_rabinovich-faithfulness-audit.md, 03_spawn-blocker-analysis.md]

## Overview

Build the recursive navigated arity-3 endpoint primitive `endChar : EndCharCarrier sig k` (where the
FROZEN carrier `EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred`, Base.lean:1007) plus its
correctness theorem `endChar_correct`, by **consuming task 351's `nfEval_le2_reduction`** to decompose
every arity-`n` obligation into arity-`≤3` pieces FIRST, then navigating each arity-`≤3` piece with the
already-GREEN arity-3 endpoint machinery (`nf_char3_endpoint_tl`/`_correct`, `nf_zone_flatten_navigable`/
`_correct`, `endChar0`, `seg`) via `Until`/`Since`, so the recursion **never climbs past anchor arity 3**.

This is plan **v4**; it supersedes v3 (plans/03), whose Phase 5 was proven UNPROVABLE. The decisive new
fact: **task 351 landed `nfEval_le2_reduction`** (green, sorry-free, 0-new-axiom) in the separate file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean`:

```
theorem nfEval_le2_reduction (M) : ∀ (k n) (env) (qnf),
    nf_eval_nf M k n env qnf ↔ nfEvalRHS M k n env qnf
```

where every `nf_eval_nf` conjunct that `nfEvalRHS` emits has anchor arity **exactly 2**, and each
realizability clause keeps its single witness OUTSIDE the reduced inner form (`∃ w, nfEvalRHS M k (n+1)
(Fin.cons w env) sub`). This is exactly the ≤2/≤3-anchor decomposition the world-locality obstruction
demanded, delivered as a `Prop ↔ Prop` equivalence that introduces **no single-world navigating
characteristic** (so it sidesteps `endCharN0_correct_infeasible` entirely).

### Root-cause recap (why v3 died, why v4 lives)

**v3 died (report 03; Base.lean:1745/1779):** the v3 recursion tried to build an UNCONDITIONAL
multi-anchor navigating base `endCharN0_correct` — a single `TemporalPred` evaluated at the navigated
witness `env 0`, biconditional to the FULL arity-`n` atom layer `nf_eval_nf M 0 n env qnf` for an
*arbitrary* `env`. Two green sorry-free refutations prove this UNPROVABLE:
`endCharN0_correct_world_local_obstruction` (any such base forces `nf_eval_nf` to be invariant under
changing `env` away from position 0) and `endCharN0_correct_infeasible` (a concrete `Bool` counter-model
at arity 2). `TemporalPred.eval_at tp t` reads only the single world `t`; the RHS reads `M.interp p (env j)`
at every position `j ≥ 1`. The obstruction is intrinsic and holds for EVERY candidate base — so v3's
`navMultiAnchorForm` (Phase 6) inherits the identical wall one arity up.

**v4 lives:** the reduction happens at the `nf_eval_nf` level BEFORE any navigation, so no base ever has
to certify an arbitrary-`env` arity-`n` layer in one shot. Each arity-`≤3` piece emitted by `nfEvalRHS`
is exactly the "two anchors + one witness" (`zoneEnv3`) shape the GREEN two-anchor
`nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687) and arity-3 endpoint
`nf_char3_endpoint_tl`/`_correct` (Base.lean:869/885) already certify. The world-locality wall never
arises because navigation only ever reaches the ≤2 anchors + 1 witness already within an arity-3 shape's
reach.

### Scope, file discipline, and definition of done

**Scope: a NEW file** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean`,
importing `...NfMultiAnchorBridge.Base` and `...NfMultiAnchorBridge.Lemma32Reduction`. Task 349 **imports/
depends on** task 351's lemma — it does **NOT re-derive it, and does NOT edit `Lemma32Reduction.lean` or
`Base.lean`.** The v3 climbing machinery remains as untouched docstrings in `Base.lean`; v4 "retires" it
architecturally by not depending on it, not by deleting it. `endChar`/`endChar_correct`/`endCharRec` are
currently only docstring text (inside comment code-fences) in `Base.lean` — there is no real `endChar`
declaration — so defining them in the new file (same namespace `Bimodal.Metalogic.WeakCanonical.Kamp`)
introduces no clash.

**Definition of done:** new-module `lake build` GREEN (full tree recommended); `endChar`/`endChar_correct`
sorry-free; `lean_verify endChar_correct` = exactly `[propext, Classical.choice, Quot.sound]`; `git status`
touches only `NavigatedEndChar.lean` (+ this plan/summary) — `Base.lean` and `Lemma32Reduction.lean`
UNCHANGED; navigation provably never climbs past anchor arity 3; task 309 Phase 18/19 can cite
`endChar_correct` by name.

### Research Integration (this revision)

This is a **plan revision (v4)** integrating the newly-landed task-351 reduction. Key integrated findings:

- **Task 351 `nfEval_le2_reduction` (the unblocker)**: the arity-`n` obligation decomposes into arity-`≤3`
  `nf_eval_nf` pieces at the Prop level, BEFORE navigation. → the whole v4 architecture (Phases 1-5).
- **Report 02 §Q4 target 4**: the reduction is the paper's own prescribed alternative to the
  (infeasible) climbing multi-anchor characteristic. → confirms v4 is faithful, not ad hoc.
- **Report 03 (world-locality infeasibility)**: the v3 unconditional climbing base is machine-checked
  unprovable; the reduction "eliminates the need for any base case to certify an arbitrary-arity `env` in
  one shot." → Phase 2 base is CONDITIONAL/navigable (never unconditional world-local).
- **Report 01 (navigate-not-collapse)**: Rabinovich carries the inner characteristic as an `Until` hook,
  never collapsing arity — SURVIVES. Its "arity climbs to `n+1`" thesis is now CAPPED at 3 by the
  reduction (report 01's own §Q4-target-4 escape hatch, now realized). → Phase 3 navigates ≤3 pieces.
- **SETTLED order-theoretic merge (task 351 §Phase-4 docstring)**: the merge is `∃w ∀ij` (one witness
  threaded through the enclosing zone), NOT the naive per-pair `∀ij ∃w` distribution (a machine-checked
  non-theorem for `n ≥ 3`). There is NO arity-collapsing quant `nfRestrict`. → binding postmortem
  constraint (below); Phase 3 threads a single witness through `nf_zone_flatten_navigable`.

### Achievable target for `endChar_correct` (world-locality-safe)

The v3 frozen shape `(endChar k qnf).eval_at w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` for **arbitrary**
`a, b` is UNPROVABLE by the same world-locality obstruction (`endChar0_correct`'s docstring counterexample,
Base.lean:1036-1047). The **achievable** target — the one the green arity-3 machinery already realizes — is
the **conditional/navigable** form, where the two enclosing anchors are reached/pinned by navigation
(exactly as the green `endChar0_correct` carries `h_res` and `nf_char3_endpoint_tl_correct` carries
`h_atom`):

```
-- semantic target (exact hypothesis shape pinned in Phase 1 by reading the green
-- nf_char3_endpoint_tl_correct / endChar0_correct anchor-coupling and task 309's consumption site):
(endChar k qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf
   -- under the enclosing-anchor coupling for {x, t}, discharged by navigation, arity ceiling 3
```

This is the SAME conditional shape v3's Phase 4 removed (`h_nav`) — but v4 discharges the coupling by the
task-351 reduction + arity-3 navigation, never by a free-standing `NavResidual`. **Phase 1 MUST pin the
exact hypothesis form (residual vs. flatten-navigable) against `nf_char3_endpoint_tl_correct` and task
309's citation site; it MUST NOT re-freeze the unconditional world-local shape.**

## Goals & Non-Goals

**Goals**:
- Build `endChar : EndCharCarrier sig k` (FROZEN arity-3 carrier UNCHANGED) and `endChar_correct` in a
  NEW file, by recursion on modal depth `k`, consuming `nfEval_le2_reduction`.
- Discharge the depth-`(k+1)` inner realizability obligation (`nf_char3_endpoint_tl_correct`'s `h_inner`,
  arity-4 `∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`) by REDUCING it to arity-`≤3` pieces
  (`nfEval_le2_reduction` / `nfEval_step_reduction`) and NAVIGATING each piece over its enclosing anchor
  pair via the arity-3 bridges `nfEval_pair_arity3_flatten` / `nfEval_pair_arity3_interior`, with hooks =
  the depth-`(k-1)` IH (`endChar` one depth down at arity 3).
- Keep everything sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]`;
  additive-only in the new file.

**Non-Goals**:
- Building v3's `navMultiAnchorForm`, the UNCONDITIONAL `endCharN0_correct`, or the climbing arity-`n`
  `endCharRec` (all RETIRED — the first two hit the machine-checked world-locality wall).
- Any `NormalForm sig k 4 → NormalForm sig k 3` collapse or `nf_char3_deeper_split` route (FORBIDDEN —
  grows the anchor set; the exact refuted failure mode).
- Re-deriving any part of task 351's `nfEval_le2_reduction` family (it is imported, not rebuilt).
- Editing `Base.lean` or `Lemma32Reduction.lean` (or the seven frozen provider files / `KampPrior.lean`).
- Widening the frozen `EndCharCarrier sig k` abbreviation (Base.lean:1007).
- Re-freezing the UNCONDITIONAL world-local `endChar_correct` shape (proven UNPROVABLE).
- The handoff's hook-parametric Option 3 (caller-supplied `innerConv`) — non-convergent.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The arity-4 inner realizability (`h_inner`) does not cleanly reduce+navigate: bridging `∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` (arity 4) to the arity-3 `nfEval_pair_arity3_flatten` shape requires the task-351 reduction to fire on the arity-4 inner term and then re-express the ≤3 pieces over the correct enclosing pair | H | M | Phase 3 is load-bearing. Attack it by applying `nfEval_le2_reduction` to the arity-4 inner `nf_eval_nf` FIRST (under `exists_congr`, keeping `w` outside — the SETTLED merge), then use `nfEval_step_reduction` / `nfEval_pair_arity3_flatten` on the resulting ≤3 pieces. If it cannot close, DO NOT reach for a collapse or single-anchor reshape: mark `[BLOCKED]`, record the exact `lean_goal`, and escalate (`/spawn 349` for a missing arity-4→3 navigation-bridge lemma) |
| Phase 3 exceeds one agent run (>350 lines) | M | H | Pre-declared split: 3a = `navPieceForm` def + `_correct` statement (parametric hooks); 3b = the hook-discharge proof. Each 3a/3b is its own committable green unit |
| The exact `endChar_correct` hypothesis shape mismatches task 309's consumption site (residual vs. flatten-navigable) | M | M | Phase 1 pins the shape by reading `nf_char3_endpoint_tl_correct` (Base.lean:885), `endChar0_correct` (Base.lean:1056), and task 309's citation before freezing; a thin adapter lemma is acceptable if 309 needs a specific hook form |
| Temptation to re-freeze the UNCONDITIONAL world-local target (it "looks cleaner") | H | M | PROHIBITED — machine-checked UNPROVABLE (`endCharN0_correct_infeasible`). The target is conditional/navigable. Phase 1 records the counterexample pointer next to the target |
| Temptation to fake green with `sorry`/`def X := True`/naive per-pair distribution when a sub-piece resists | H | M | PROHIBITED (postmortem constraints). The `∀ij ∃w` per-pair distribution is the SETTLED non-theorem; the arity-collapsing quant `nfRestrict` IS the non-theorem. Mark `[BLOCKED]`, record `lean_goal` + missing lemma, return `status: partial` |
| Accidental edit to `Base.lean` / `Lemma32Reduction.lean` | H | L | Never open them for edit; verify `git status --short` shows only `NavigatedEndChar.lean` (+ plan/summary) before each commit |
| Manual Rabinovich chain-step bridge tempts a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro`/`or_congr`/`exists_congr`/`and_congr_right` bridges only, mirroring `nf_zone_flatten_navigable_correct` (Base.lean:700-706) and `nfEval_step_reduction` (Lemma32Reduction.lean:443-450) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases 2 (base) and 3 (navigator) are logically independent (both consumed by Phase 4's k-induction) and
MAY run in parallel; each is a single committable green unit.

**Per-phase hard bar (applies to every `[NOT STARTED]` phase)**:
- sorry-free; `lean_verify` on the phase's new correctness lemma = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped `lake build` of
  `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedEndChar` GREEN.
- Explicit "reuse vs rebuild" note satisfied.
- **Guards**: FORBIDDEN `nf_char3_deeper_split` (grep-confirmed absent in new code); `EndCharCarrier`
  FROZEN (not widened); no `Base.lean`/`Lemma32Reduction.lean` edit (git-scope confirmed); navigation
  anchor arity ≤3 (G4 — witness depth via `Fin.cons` is fine; free anchors stay ≤2); G3 non-trivial `seg`
  interior (never `TemporalPred.top`); G5 manual bridges only; order-theoretic `∃w ∀ij` merge only (no
  per-pair `∀ij ∃w`); no arity-collapsing quant `nfRestrict`.

### Phase 1: New module scaffold + arity-3 reduction consumption [COMPLETED]

- **Goal:** Create the new module and establish the arity-3 specialization of the task-351 reduction,
  plus pin the achievable `endChar_correct` target shape. This is the import/wiring + reduction-entry
  phase; it MUST NOT re-freeze the unconditional world-local target.
- **Reuse vs rebuild:** REUSE (import) `nfEval_le2_reduction` (Lemma32Reduction.lean:535), `nfEvalRHS`
  (498), `nfEvalRHS_zero`/`nfEvalRHS_succ` (508/513); REUSE (import from Base) `zoneEnv3`, `EndCharCarrier`
  (1007), `nf_char3_endpoint_tl_correct` (885), `endChar0_correct` (1056). BUILD only thin specialization
  lemmas in the new file.
- **Tasks:**
  - [x] Create `NavigatedEndChar.lean` importing `...NfMultiAnchorBridge.Base` and
        `...NfMultiAnchorBridge.Lemma32Reduction`; open the shared namespace.
  - [x] Prove `nfEval3_reduction`: `nf_eval_nf M k 3 env qnf ↔ nfEvalRHS M k 3 env qnf` (specialize
        `nfEval_le2_reduction` at `n = 3`); confirm via `nfEvalRHS_succ`/`_zero` that the emitted
        conjuncts are arity-2 atom facts + realizability clauses (no arity climb past 3 among emitted
        `nf_eval_nf` facts). *(confirmation lemmas `nfEval3_reduction_zero_shape` /
        `nfEval3_reduction_succ_shape` added — arity-2 emitted-conjunct shape witnessed.)*
  - [x] Record (as a docstring at the intended `endChar_correct` site) the ACHIEVABLE conditional/
        navigable target shape, cross-referencing `nf_char3_endpoint_tl_correct`'s `h_atom`, and the
        world-locality counterexample pointer (Base.lean:1036-1047 / `endCharN0_correct_infeasible`) as
        the reason the unconditional form is FORBIDDEN. *(recorded as module-level docstring.)*
  - [x] Route audit: grep-confirm the new file references no `nf_char3_deeper_split`, no `navMultiAnchorForm`,
        no `NavResidual`; `EndCharCarrier` imported unchanged; `git status` shows only the new file.
        *(clean — only `NavResidual` mention is the docstring naming it forbidden; not a code construct.)*
- **Hard bar:** sorry-free; new-module `lake build` GREEN; `lean_verify nfEval3_reduction` axioms exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Timing:** ~1.5 hours (~60-140 lines)
- **Depends on:** none
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` (new)

### Phase 2: Depth-0 navigated base `endCharNav0_correct` (arity-3, conditional) [NOT STARTED]

- **Goal:** Establish the `k = 0` base of the recursion in the reduction-consuming, conditional/navigable
  form: `(endChar0 qnf).eval_at y ↔ nf_eval_nf M 0 3 (zoneEnv3 y x t) qnf` under the enclosing-anchor
  coupling, routed through the ≤2-atom reduction so the arity-2 atom pieces are the honest anchor+witness
  atom facts. NEVER the unconditional world-local form.
- **Reuse vs rebuild:** REUSE `endChar0` (Base.lean:995), `endChar0_wlocus_correct` (1015), and the
  already-GREEN conditional `endChar0_correct` (1056, which carries the anchor residual `h_res`). REUSE
  `nfEval0_reduction` (Lemma32Reduction.lean:237) / `nfRestrict0` (203) / `envPair` (118) to express the
  base against `nfEvalRHS M 0 3`. BUILD only the wrapper lemma connecting `endChar0_correct` to the
  reduced `nfEvalRHS M 0 3` shape (the form Phase 4's k-induction base consumes).
- **Tasks:**
  - [ ] Prove `endCharNav0_correct` (base case) in the conditional/navigable target shape pinned in
        Phase 1, deriving it from the green `endChar0_correct` + `nfEval3_reduction` at `k = 0`.
  - [ ] Confirm every atom piece is arity ≤2 (the anchor/witness atom facts from `nfEvalRHS M 0 3`); no
        arity climb; no unconditional world-local claim.
  - [ ] Route audit: G1 (honest atom layer, no arity-1 collapse), G4 (free anchors ≤2), no forbidden
        constructs; grep clean.
- **Hard bar:** sorry-free; `lean_verify endCharNav0_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; new-module build GREEN; statement is conditional/navigable
  (carries the anchor coupling — NOT unconditional).
- **Timing:** ~1.5 hours (~80-160 lines)
- **Depends on:** 1
- **Files to modify:** `.../NavigatedEndChar.lean`

### Phase 3: Arity-3 inner-realizability navigator `navPieceForm`/`_correct` (load-bearing core) [NOT STARTED]

- **Goal:** Build the closed-`Formula` converter that discharges the depth-`(k+1)` inner-realizability
  obligation `h_inner` of `nf_char3_endpoint_tl_correct` — for each arity-4 `sub`,
  `temporal_truth y (navPieceForm rec sub) ↔ ∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` —
  by REDUCING the arity-4 inner `nf_eval_nf` to arity-`≤3` pieces (`nfEval_le2_reduction` /
  `nfEval_step_reduction`) under a SINGLE shared witness (order-theoretic `∃w ∀ij` merge), then NAVIGATING
  each arity-3 piece over its enclosing anchor pair via `nfEval_pair_arity3_flatten` +
  `nfEval_pair_arity3_interior`, with the hooks `pastEnd`/`futureEnd` = `rec` (the depth-`(k-1)` IH at
  arity 3). Navigation NEVER climbs past anchor arity 3.
- **Reuse vs rebuild:** REUSE the GREEN two-anchor `nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687)
  as the navigation form; REUSE `nfEval_pair_arity3_flatten` (Lemma32Reduction.lean:318) and
  `nfEval_pair_arity3_interior` (344) as the Prop-level bridges; REUSE `seg`/`seg_holds_coupled`
  (Base.lean:1127/1150) as the β-segment interior; REUSE `nfEval_le2_reduction`/`nfEval_step_reduction`
  to cap the arity. BUILD the closed `navPieceForm : (NormalForm sig k 3 → TemporalPred) → NormalForm sig
  k 4 → Formula` and its correctness under the parametric arity-3 hooks. This REPLACES v3's removed
  single-anchor `navBrickForm` and v3's infeasible `navMultiAnchorForm` — do NOT resurrect either.
- **Tasks:**
  - [ ] Define `navPieceForm` (the closed `Until`/`Since` navigating converter with `seg` interior),
        parametric in the depth-`(k-1)` hooks, built on `nf_zone_flatten_navigable`'s structure.
  - [ ] Prove `navPieceForm_correct` under parametric arity-3 hooks: apply `nfEval_le2_reduction` to the
        arity-4 inner term under `exists_congr` (witness stays OUTSIDE — SETTLED merge), then discharge
        the arity-3 pieces with `nfEval_pair_arity3_flatten`/`_interior` and `seg_holds_coupled`. Manual
        bridges (G5).
  - [ ] Route audit: G2/G4 (every `w` a bracket witness; free anchors ≤2 while arity is capped at 3),
        G3 (non-trivial `seg` interior — never `⊤`), G5; no `nf_char3_deeper_split`; no per-pair `∀ij ∃w`
        distribution; no arity-collapsing quant `nfRestrict`. Grep clean.
- **Hard bar:** sorry-free; `lean_verify navPieceForm_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; new-module build GREEN; hooks are the arity-3 IH shape;
  interior is `seg`; navigation anchor arity ≤3.
- **Pre-declared split (shape may imply >350 lines):** if it overruns one agent run, split at the def/
  statement vs proof seam: **3a** = `navPieceForm` def + `navPieceForm_correct` statement (parametric
  hooks), only after 3a's def is green; **3b** = the hook-discharge proof. Each is its own committable
  green unit.
- **Contingency trigger:** if the arity-4→3 reduction+navigation cannot be closed (e.g. a missing
  arity-4-enclosing-pair navigation-bridge lemma), mark `[BLOCKED]`, record the exact `lean_goal`, and
  `/spawn 349` for the missing bridge — do NOT fall back to a collapse, a single-anchor reshape, or a
  per-pair distribution.
- **Timing:** ~4 hours (~200-350 lines; the flagged load-bearing core)
- **Depends on:** 1 (independent of Phase 2; both feed Phase 4)
- **Files to modify:** `.../NavigatedEndChar.lean`

### Phase 4: Assemble `endChar`/`endChar_correct` by recursion on `k` [NOT STARTED]

- **Goal:** Define `endChar` on the FROZEN `EndCharCarrier sig k` by recursion on modal depth `k` and
  prove `endChar_correct` (the conditional/navigable arity-3 target from Phase 1) by induction on `k`.
- **Reuse vs rebuild:** REUSE `nf_char3_endpoint_tl` (Base.lean:869) as the `k+1` closed endpoint builder
  and `nf_char3_endpoint_tl_correct` (885) as the step lemma; REUSE `endChar0` (Phase 2 base) and
  `navPieceForm` (Phase 3 navigator). REBUILD nothing that is already green.
- **Tasks:**
  - [ ] Define `endChar (k) : EndCharCarrier sig k` by recursion on `k`:
        `k = 0 ⇒ endChar0`; `k+1 ⇒ nf_char3_endpoint_tl (atomPart) (fun sub => (navPieceForm (endChar k) sub)) qnf`
        — `innerConv` discharged INTERNALLY by the navigator over the IH (NOT hook-parametric to a caller;
        Option 3 rejected). Genuinely recurses; not vacuous.
  - [ ] Prove `endChar_correct` by induction on `k`: base = `endCharNav0_correct` (Phase 2); step =
        `nf_char3_endpoint_tl_correct` whose `h_inner` is discharged by `navPieceForm_correct` (Phase 3)
        with hooks instantiated to the IH `endChar_correct` at depth `k` (arity 3). Interior coupled via
        `seg_holds_coupled`. sorry-free.
  - [ ] Route audit: G1-G5 inherited; confirm NO `navMultiAnchorForm`, NO `NavResidual`/`h_nav`
        free-standing residual, NO climbing arity; navigation anchor arity ≤3 throughout.
- **Hard bar:** sorry-free; `lean_verify endChar_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; new-module build GREEN; statement = the conditional/navigable
  target (never the UNPROVABLE unconditional world-local form); `endChar` genuinely recurses.
- **Timing:** ~2 hours (~120-240 lines)
- **Depends on:** 2, 3
- **Files to modify:** `.../NavigatedEndChar.lean`

### Phase 5: Consumer gate — axiom check + downstream citability + file-scope confirmation [NOT STARTED]

- **Goal:** Confirm all definition-of-done gates including task-309 citability and the strict file scope.
- **Reuse vs rebuild:** REUSE `endChar`/`endChar_correct` (Phase 4); the frozen `EndCharCarrier sig k`
  (Base.lean:1007) is UNCHANGED.
- **Tasks:**
  - [ ] `lean_verify endChar_correct` (fully qualified) = exactly `[propext, Classical.choice, Quot.sound]`,
        no `sorry`.
  - [ ] Full-tree `lake build` GREEN (new module at minimum; full tree recommended).
  - [ ] `git status --short` confirms only `NavigatedEndChar.lean` (+ this plan/summary) changed — NO
        `Base.lean`, NO `Lemma32Reduction.lean`, NO frozen-provider / `KampPrior.lean` edits.
  - [ ] Grep-confirm `endChar_correct` is a top-level citable name reachable from task 309 Phase 18/19
        consumers; if 309 needs a specific hook form, land a thin adapter lemma (still no world-local
        unconditional claim).
  - [ ] Grep-confirm no `nf_char3_deeper_split`, no `navMultiAnchorForm`, no `NavResidual`, no per-pair
        `∀ij ∃w` distribution, no arity-collapsing quant `nfRestrict` in the new file.
- **Hard bar:** all definition-of-done gates pass.
- **Timing:** ~1 hour (~40-100 lines: verification + any adapter)
- **Depends on:** 4
- **Files to modify:** `.../NavigatedEndChar.lean`

## Preserved-Assets Accounting (what survives vs. what is retired)

### Survives — REUSED (imported from `Base.lean`, GREEN, do NOT rebuild or edit)

| Asset | Location | Disposition in v4 |
|-------|----------|-------------------|
| `nf_zone_flatten_navigable` / `_correct` | Base.lean:667/687 | REUSE as the arity-3 navigation form (Phase 3) |
| `nf_char3_endpoint_tl` / `_correct` | Base.lean:869/885 | REUSE as the `k+1` closed endpoint builder + step lemma (Phases 3-4) |
| `endChar0` / `endChar0_wlocus_correct` / `endChar0_correct` | Base.lean:995/1015/1056 | REUSE as the conditional `k=0` base (Phase 2) |
| `EndCharCarrier` (abbrev) | Base.lean:1007 | REUSE unchanged (FROZEN carrier) |
| `seg` / `seg_holds_coupled` | Base.lean:1127/1150 | REUSE as the β-segment interior (Phase 3) |
| `zoneEnv3`, `nf_depth0_char_formula`, `nf3_locus0` | Base.lean | REUSE as the arity-3 env + atom-literal core |
| `nf_eval_nf_step_unfold` | Base.lean:1488 | REUSE (arity-3 step-unfold citation) |

### Survives — CONSUMED (imported from `Lemma32Reduction.lean`, task 351, GREEN, do NOT rebuild or edit)

| Asset | Location | Disposition in v4 |
|-------|----------|-------------------|
| `nfEval_le2_reduction` / `nfEvalRHS` (+ `_zero`/`_succ`) | Lemma32Reduction.lean:535/498/508/513 | CONSUME — the reduction that caps arity at ≤3 (Phases 1, 3) |
| `nfEval0_reduction` / `nfRestrict0` / `envPair` / `pairEmbed` / `pairSel` | Lemma32Reduction.lean:237/203/118/125/98 | CONSUME — depth-0 atom-layer ≤2 reduction (Phase 2) |
| `nfEval_pair_arity3_flatten` | Lemma32Reduction.lean:318 | CONSUME — arity-3 realizability ↔ navigable flatten bridge (Phase 3) |
| `nfEval_pair_arity3_interior` | Lemma32Reduction.lean:344 | CONSUME — `seg` interior coupling bridge (Phase 3) |
| `nfEval_step_reduction` / `nfEval_step_unfold_gen` | Lemma32Reduction.lean:432/404 | CONSUME — one-depth-step reduction with abstract IH (Phase 3) |

### Retired — NOT built in v4 (remain as untouched docstrings/decls in `Base.lean`; v4 does not depend on them)

| Asset | Location | Why retired |
|-------|----------|-------------|
| UNCONDITIONAL `endCharN0_correct` (frozen docstring) | Base.lean:1698-1704 | **UNPROVABLE** — `endCharN0_correct_infeasible` (world-locality wall). v4's base is conditional/navigable instead |
| `navMultiAnchorForm` / `navMultiAnchorForm_correct` (docstring) | Base.lean:1831 | Inherits the identical world-locality wall one arity up. v4 uses the reduction + arity-3 navigation instead |
| climbing arity-`n` `endCharRec` / `endCharRec_correct` (docstrings) | Base.lean:1957/1969 | Climbs anchor arity to `n+1`; v4 caps at 3 via the reduction. v4 recurses on `k` at fixed arity 3 |
| `EndCharMotive` (arity-general Π-motive) | Base.lean:1590 | Green but NOT consumed — v4 needs no arity-general motive (arity capped at 3) |
| `nfN_locus0` / `endCharN0` / `endCharN0_wlocus_correct` | Base.lean:1643/1660/1673 | Green arity-general position-0 base; NOT consumed — v4 uses the arity-3 `endChar0` |
| `atomPartN` / `nf_endpoint_tl_gen` / `nf_endpoint_tl_gen_correct` | Base.lean:1876/1889/1903 | Green arity-general endpoint skeleton; NOT consumed — v4 uses the arity-3 `nf_char3_endpoint_tl` |

### Survives — KEEP as green witnesses (imported truth, document WHY the unconditional line is retired)

| Asset | Location | Role |
|-------|----------|------|
| `endCharN0_correct_world_local_obstruction` | Base.lean:1745 | Green refutation: any world-local base forces `env`-position-≥1 invariance |
| `endCharN0_correct_infeasible` (+ `sigCex`/`Mcex`/`atomMapCex`) | Base.lean:1779/1756/1761/1767 | Green refutation: concrete counter-model — NO unconditional base exists |

## H3 Lemma-Mapping Table (Tier 1, Rabinovich 2014 — reduction-navigated realization)

| Rabinovich construct | Source location | Asset consumed (task 351 / Base) | Faithful / status | v4 usage |
|---|---|---|---|---|
| Lemma 3.2(2): every `∃∀`-formula ≡ conjunction of `∃∀`-formulas with ≤2 free variables | md:119 | `nfEval_le2_reduction` / `nfEvalRHS` (Lemma32Reduction.lean:535/498) | **Faithful** (the reduction itself, GREEN) | Phase 1 (arity-3 specialization); Phase 3 (arity-4 inner reduction) |
| ≤2-free-variable atom layer factors through anchor pairs `(z0,z1)` | md:119, md:165, md:219 | `nfEval0_reduction` / `nfRestrict0` / `envPair` (Lemma32Reduction.lean:237/203/118) | **Faithful** (GREEN) | Phase 2 base (arity-2 atom pieces) |
| `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` — inner char carried as `Until` endpoint hook, never collapsed | md:255-263 | `nf_char3_endpoint_tl`/`_correct` `innerConv` (Base.lean:869/885); `navPieceForm` (Phase 3) | **Faithful** (hook-carrying, arity-3) | Phase 3 navigator + Phase 4 step |
| Cor 5.4 navigated flatten with FULL-eval endpoint hooks over `(z0,z1)` | md:255-279 | `nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687); `nfEval_pair_arity3_flatten` (Lemma32Reduction.lean:318) | **Faithful** (two-anchor, GREEN) | Phase 3 navigates each ≤3 piece |
| Per-witness ordering discharged by `Until`/`Since`; non-adjacent transitive; single witness threaded | md:79, md:267-273 | order-theoretic `∃w ∀ij` merge in `nfEval_step_reduction` (Lemma32Reduction.lean:432) | **Faithful** (SETTLED merge, GREEN) | Phase 3 keeps `w` OUTSIDE (no per-pair `∀ij ∃w`) |
| Interior of `(x_i, x_{i+1})` = β-SEGMENT (qf), endpoint carries `F_i` | md:79, md:269-273, md:299 (Fig 1) | `seg` / `seg_holds_coupled` (Base.lean:1127/1150); `nfEval_pair_arity3_interior` (Lemma32Reduction.lean:344) | **Faithful** (GREEN) | Phase 3 interior = `seg` (never `⊤`) |
| depth-`(k+1)` arity-`n` eval unfolds to atom layer + arity-`(n+1)` inner `∃w` | (Lean type fact) | `nfEval_step_unfold_gen` (Lemma32Reduction.lean:404); `nf_char3_endpoint_tl_correct.h_inner` (Base.lean:893) | **Faithful** (`Iff.rfl`, GREEN) | Phase 3 (arity-4 inner) + Phase 4 (k-step) |
| Single-world characteristic CANNOT certify arbitrary multi-anchor `env` (the obstruction routed around) | (Lean impossibility) | `endCharN0_correct_infeasible` (Base.lean:1779) | **Refutation** (GREEN) — forbids the unconditional world-local form | Motivates the reduction-first architecture; forbidden target |

## Testing & Validation

- [ ] Scoped `lake build` of `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedEndChar`
      GREEN after every phase (per-phase gate).
- [ ] Final full-tree `lake build` GREEN.
- [ ] `lean_verify` on `endChar_correct`, `navPieceForm_correct`, `endCharNav0_correct`, `nfEval3_reduction`
      = exactly `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- [ ] `endChar_correct` is the CONDITIONAL/navigable arity-3 form (NOT the UNPROVABLE unconditional
      world-local shape); the anchor coupling is discharged by the reduction + navigation, never by a
      free-standing `NavResidual`.
- [ ] Navigation provably never climbs past anchor arity 3 (every emitted `nf_eval_nf` fact is arity ≤3;
      `Fin.cons` witness depth is not free-anchor growth).
- [ ] Single-witness order-theoretic `∃w ∀ij` merge only — no per-pair `∀ij ∃w` distribution; no
      arity-collapsing quant `nfRestrict`.
- [ ] `git status --short` shows only `NavigatedEndChar.lean` under `Theories/` modified — NO `Base.lean`,
      NO `Lemma32Reduction.lean`, NO frozen-file / `KampPrior.lean` edits.
- [ ] `endChar`/`endChar_correct` are top-level, name-citable declarations reachable by task 309.
- [ ] No occurrence of `nf_char3_deeper_split`, `navMultiAnchorForm`, or `NavResidual` in the new file;
      `EndCharCarrier` not widened.
- [ ] `endChar` discharges `innerConv` internally via `navPieceForm` (NOT hook-parametric / Option 3);
      the interior is `seg` (no `TemporalPred.top` code-reference).

## Postmortem Constraints (binding forbidden list — carried forward + extended)

The following are PROHIBITED in v4 (each is a machine-checked non-theorem, an H4-refuted route, or a
plan-forbidden failure mode). Landing any of them is a `[BLOCKED]` escalation, never a silent workaround:

1. **No unconditional world-local base** — no single-world `TemporalPred`/`Formula` biconditional to the
   arity-`n` atom layer for arbitrary `env` (`endCharN0_correct_infeasible`, Base.lean:1779, UNPROVABLE).
2. **No single-anchor `navBrickForm` reshape** — report 02 Option A (H4-refuted: provably-true LHS vs.
   provably-false RHS for disagreeing `sub`).
3. **No `nf_char3_deeper_split` arity collapse** — grows the anchor set to arity 4 (the exact failure mode).
4. **No free-standing `NavResidual`/`h_nav` predicate-layer residual** at inner witnesses (the refuted v2
   route). The anchor coupling is discharged by the reduction + navigation.
5. **No naive per-pair `∀ij ∃w` distribution** — machine-checked strictly-weaker WRONG reduction for
   `n ≥ 3` (SETTLED; task 351 §Phase-4). The single witness is threaded through the enclosing zone
   (order-theoretic `∃w ∀ij` merge).
6. **No arity-collapsing quant `nfRestrict`** — that map IS the non-theorem (task 351 §Phase-4). The quant
   assignment is preserved verbatim; inner arity reduction is delegated to the reduction/IH.
7. **No `navMultiAnchorForm`** — the v3 infeasible unconditional multi-anchor converter (inherits the
   world-locality wall).
8. **No edit to `Base.lean` or `Lemma32Reduction.lean`** (or any frozen provider / `KampPrior.lean`); all
   v4 work lands in the new `NavigatedEndChar.lean`.
9. **No `sorry`, no vacuous `def X := True`/`Unit`/`trivial`, no `simp`/`omega`/`aesop` shortcut** that
   silently weakens the RHS. A stuck main target is `[BLOCKED]` + `lean_goal` record, never a fake green.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` — NEW file,
  additive-only: imports `Base` + `Lemma32Reduction`; defines the arity-3 specialization `nfEval3_reduction`,
  the conditional base `endCharNav0_correct`, the load-bearing navigator `navPieceForm`/`_correct`, the
  recursion `endChar` (on the FROZEN `EndCharCarrier`), and `endChar_correct`. Consumes task 351's
  `nfEval_le2_reduction` family and Base's green arity-3 machinery; edits NEITHER source file.
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/plans/04_reduction-navigated-endchar.md`
  (this plan; supersedes plans/03).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/summaries/04_reduction-navigated-endchar-summary.md`
  (on completion).

## Rollback/Contingency

- The work is confined to the NEW `NavigatedEndChar.lean`; rollback is `git checkout` of that single new
  file (or `rm` if uncommitted). `Base.lean` and `Lemma32Reduction.lean` are never touched, so no green
  asset can be lost by a v4 rollback. Snapshot before any intentional rollback per "No Destructive Git on
  Uncommitted Work" (`bash .claude/scripts/git-snapshot.sh` first).
- Each green phase is committed as it lands (commit-per-green-substep mandate); no progress is lost across
  dispatches.
- If any `[NOT STARTED]` phase cannot close green without a forbidden construct (postmortem list above),
  mark it `[BLOCKED]`, record the exact `lean_goal` + missing lemma, return `status: partial` with
  `requires_user_review: true`. Do NOT land a vacuous, `sorry`'d, unconditional-world-local, or
  per-pair-distributed `endChar`.

### Escape hatch — a missing arity-4→3 navigation-bridge lemma (contingency, NOT main line)

The one genuine feasibility risk is Phase 3: bridging the arity-4 inner realizability
`∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` to the arity-3 `nfEval_pair_arity3_flatten`
shape. The main line applies `nfEval_le2_reduction` to the arity-4 inner term (under `exists_congr`,
witness OUTSIDE) and navigates the resulting ≤3 pieces. If a specific structural bridge lemma turns out
to be missing in-tree (e.g. re-expressing the reduced ≤3 pieces over the correct enclosing pair of the
arity-4 env), the faithful response is to `/spawn 349` for that single missing lemma (recording the exact
`lean_goal`), NOT to reach for a collapse, a single-anchor reshape, a per-pair distribution, or an
arity-collapsing `nfRestrict` — all refuted or SETTLED-forbidden.
