# Implementation Plan: Task #349 (v3 — multi-anchor navigating characteristic)

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours
- **Dependencies**: None (consumes only already-landed, sorry-free assets)
- **Research Inputs**:
  - reports/02_rabinovich-faithfulness-audit.md (H5 divergence audit; the AUTHORITATIVE driver of this revision — corrected signatures §Q4, H3 mapping table, H4 refutations)
  - reports/01_endchar-faithful-architecture.md (still valid: arity climbs 3→3+k, navigate-not-collapse; INVALID/superseded: "single-anchor `Formula` suffices" — refuted by report 02 Q3/H4)
  - (blocker) .orchestrator-handoff.json blocker `blk-349-p5-inner-navresidual`; (prior) summaries/02_navbrickform-core-summary.md
- **Artifacts**: plans/03_multi-anchor-navigating-characteristic.md (this file); supersedes plans/02_endchar-faithful-architecture.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build `endChar : (k : Nat) → EndCharCarrier sig k` (where
`EndCharCarrier sig k := NormalForm sig k 3 → TemporalPred`, Base.lean:1007) plus its correctness
theorem `endChar_correct`, using the **multi-anchor navigating characteristic** architecture
mandated by the Rabinovich faithfulness audit (reports/02). This is plan **v3**; it supersedes
v2 (plans/02), which reached Phase 5 and hit the FROZEN blocker `blk-349-p5-inner-navresidual`.

**Root cause (report 02 Q3 / H4)**: v2's `navBrickForm` (Base.lean:1806) is a **single-anchor**
converter — a structural copy of the diagonal converter `nf_char2_diag_exist_tl` (Base.lean:168) —
applied to a **general multi-anchor** target `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub`
where `env` is `n` *distinct* anchors. A `Formula` evaluated at the single accessible anchor
`env 0` **provably cannot** certify the predicate layer at `env 1 … env (n-1)` (it cannot read
`M.interp p (env j)` for `j ≥ 1`). v2's `NavResidual` (Base.lean:1608) papered over this by
*assuming* the anchor-predicate layer matches — a non-theorem for the universally-quantified `sub`
of the quant layer. Option A (per-witness residual on hooks) merely relocates the same non-theorem
into the brick's own forward direction (H4 refutation target 1).

**Faithful fix (report 02 Q4)**: the inner converter must be a **multi-anchor navigating
characteristic** whose exterior hooks are **UNCONDITIONAL full-eval** biconditionals to the whole
arity-`(n+1)` `nf_eval_nf` — the `Formula`-valued generalization of the already-GREEN two-anchor
`nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687, full-eval hooks at 692-697). Because the
anchor layer is **discharged by navigation** (nested `Since`/`Until` reaching each enclosing
anchor) rather than assumed, `NavResidual` and the conditional `endCharRec_correct` statement are
**removed**: `endCharRec_correct` becomes **UNCONDITIONAL** (no `h_nav`). This reopens the FROZEN
Phase-2 and Phase-4 interfaces (a superset of the handoff's unblock option C).

Scope is `Base.lean` only, additive-then-corrective (removes v2's single-anchor machinery, adds the
multi-anchor machinery). Definition of done: scoped Base `lake build` GREEN (full tree recommended);
`endChar`/`endChar_correct` sorry-free; `lean_verify` on `endChar_correct` = exactly
`[propext, Classical.choice, Quot.sound]`; no frozen-provider edits; task 309 Phase 18/19 can cite
`endChar_correct` by name.

### Research Integration

This is a **plan revision (v3)** integrating the newly-landed Rabinovich faithfulness audit
(reports/02_rabinovich-faithfulness-audit.md). Key integrated findings that shape the phases below:

- **Q3 / H4 (root divergence)**: single-anchor `navBrickForm` cannot certify the multi-anchor eval;
  the diagonal template `nf_char2_diag_exist_tl` is faithful *only* for the all-anchors-coincident
  case. → Phases 4-6 replace it with `navMultiAnchorForm` whose hooks are unconditional full-eval.
- **Q4 target 1 (corrected inner converter)**: `navMultiAnchorForm_correct` with unconditional
  full-eval hooks, interior = the β-segment `seg` (Base.lean:1127), NOT `BracketFormula.trivial
  (rec sub)` and NOT `⊤`-with-no-segment. → Phase 6.
- **Q4 target 2 (certify anchors by navigation)**: `endCharRec`/`endCharN0` must reach each anchor
  and certify its predicate + order layer, not read only `pred p 0`. → Phase 5 re-states the base.
- **Q4 target 3 (unconditional correctness)**: `endCharRec_correct` sheds `h_nav`; `NavResidual` is
  removed. → Phase 4 (interface reset) + Phase 7.
- **Q2 / S3 (interior)**: Rabinovich's interior is the β-SEGMENT at the interval, with the recursive
  characteristic at the ENDPOINT — never smeared into the interior. → Phase 6 uses `seg`.
- **Q4 target 4 (contingency)**: if the multi-anchor characteristic proves not to exist within
  `TL(Until,Since)` at the climbing arity, fall back to Rabinovich Lemma 3.2(2) ≤2-free-variable
  reduction (md:119) — NO Lean analogue in-tree, so this is a **risk/contingency**, not the main
  line. → Rollback/Contingency section.

### Prior Plan Reference

plans/02_endchar-faithful-architecture.md is superseded. Preserved-green assets carried forward with
`[COMPLETED]` (Phases 1-3 below). v2's single-anchor deliverables (`navBrickForm`/`_correct`,
`NavResidual`/`navResidual_base_eq_hRes`, the conditional `endCharRec_correct` shape, and v2's
position-0-only `endCharN0`/`endCharN0_correct`) are **REMOVED/REPLACED** here (Phases 4-7). v1
(plans/01) remains discarded (arity-collapse non-object).

### Preserved-Assets Accounting (reuse, do NOT rebuild)

| Asset | Location | Disposition in v3 |
|-------|----------|-------------------|
| `nf_eval_nf_step_unfold` | Base.lean:~1483/1488 | **KEEP as-is** (Phase 1, green, `Iff.rfl`) |
| `EndCharMotive` Π-motive | Base.lean:1579 | **KEEP as-is** (Phase 2, green `abbrev`) |
| `atomPartN` | Base.lean (P5 def-half) | **KEEP** wrapper `(endCharN0 …).formula`; inherits Phase-5 re-statement of `endCharN0` |
| `nf_endpoint_tl_gen`(+`_correct`) | Base.lean (P5 def-half) | **KEEP as-is** (Phase 3, parametric over `innerConv`, arity-generic) |
| `endCharRec` def skeleton | Base.lean (P5 def-half, `c0a10c38f`) | **REUSE structure** (`Nat.rec` + `nf_endpoint_tl_gen` wrapper), but **re-point `innerConv`** from `navBrickForm` → `navMultiAnchorForm` (Phase 7) |
| `endCharN0`'s atom-literal core (`nf_depth0_char_formula`) | Base.lean:~1663 | **REUSE** the per-position atom-reader; extend the assembly to navigate to each anchor (Phase 5) |
| `seg`/`seg_holds_coupled` | Base.lean:1127/1150 | **REUSE** as the β-segment interior (Phase 6) |
| green two-anchor `nf_zone_flatten_navigable`/`_correct` | Base.lean:667/687 (hooks 692-697) | **REUSE as the FULL-eval hook TEMPLATE** to generalize (Phase 6) |
| `navBrickForm`/`navBrickForm_correct` | Base.lean:1806/1827 | **REMOVE/REPLACE** (single-anchor; → `navMultiAnchorForm`, Phase 4/6) |
| `NavResidual`, `navResidual_base_eq_hRes` | Base.lean:1608/1620 | **REMOVE** (conflated order-atoms with a non-Rabinovich anchor-predicate residual, Q1) |
| conditional `endCharRec_correct` statement (docstring, `h_nav`) | Base.lean:~1531 | **REPLACE** with the unconditional statement (Phase 4/7) |
| `endCharN0_correct` (v2, `h_nav`-conditional) | Base.lean:1723 | **REPLACE** with unconditional multi-anchor statement (Phase 5) |

### Corrected FROZEN Signatures (verbatim, report 02 §Q4)

These two signatures are FROZEN for v3. Downstream phases MUST prove exactly these (no weakening,
no `h_nav`, no vacuity). Reproduced verbatim from reports/02_rabinovich-faithfulness-audit.md §Q4
targets 1 and 3.

**Inner converter — `navMultiAnchorForm_correct` (unconditional full-eval hooks)**:

```lean
-- REPLACE navBrickForm / navBrickForm_correct with a multi-anchor navigating form whose hooks are:
theorem navMultiAnchorForm_correct
    (rec : NormalForm sig k (n+1) → TemporalPred) (sub : NormalForm sig k (n+1))
    (env : Fin n → M.carrier)
    -- each exterior zone certifies the FULL arity-(n+1) eval at its witness, INCLUDING the
    -- anchor-predicate layer, by NAVIGATING to env 1 … env (n-1); no free-standing NavResidual:
    (h_past : ∀ w' : M.carrier, w' < env 0 →
      ((rec sub).eval_at M atomMap w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub))
    (h_now  : (rec sub).eval_at M atomMap (env 0) ↔ nf_eval_nf M k (n+1) (Fin.cons (env 0) env) sub)
    (h_fut  : ∀ w' : M.carrier, env 0 < w' →
      ((rec sub).eval_at M atomMap w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub)) :
    temporal_truth M atomMap (env 0) (navMultiAnchorForm rec env sub) ↔
      ∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub
```

The interior slot in `navMultiAnchorForm` is the β-segment `seg` (Q2), NOT `BracketFormula.trivial
(rec sub)` and NOT `⊤`-with-no-segment. The hooks are **unconditional biconditionals to the full
eval** (matching Base.lean:692-697) — achievable only if `rec sub` (i.e. `endCharRec k sub`)
**navigates to and certifies** `env 1 … env (n-1)` (target 2 → Phase 5).

**Recursion correctness — unconditional `endCharRec_correct` (no `h_nav`)**:

```lean
theorem endCharRec_correct (M) (atomMap) (h_surj) :
    ∀ (k : Nat) {n : Nat} [NeZero n] (qnf : NormalForm sig k n) (env : Fin n → M.carrier),
      (endCharRec atomMap h_surj k qnf).eval_at M atomMap (env 0) ↔ nf_eval_nf M k n env qnf
```

— **unconditional** (no `h_nav`), because the navigating characteristic certifies the full env
itself. (`[NeZero n]` is retained per §Q4 verbatim: it is the well-typedness instance making the
position-0 reference `(0 : Fin n)`/`env 0` well-typed at arity ≥ 1. This is distinct from the
removed `NeZero`-coupled `NavResidual` predicate-residual machinery, which is deleted. If a residual
is still needed at the two genuine top-level anchors, it is the *order-only* fragment, kept strictly
≤ the two Rabinovich anchors — S1; do NOT reintroduce the predicate fragment.)

## Goals & Non-Goals

**Goals**:
- Replace the single-anchor `navBrickForm` with the **multi-anchor navigating** converter
  `navMultiAnchorForm`/`_correct` whose exterior hooks are the **unconditional full-eval**
  biconditionals of the frozen §Q4 target 1.
- Re-state the recursion base `endCharN0`/`endCharN0_correct` to certify the anchor layer **by
  navigation** (drop `h_nav`), reusing the atom-literal core.
- Remove `NavResidual`/`navResidual_base_eq_hRes`; prove `endCharRec_correct` **unconditional**
  (frozen §Q4 target 3), with the step's hooks discharged by the IH `endCharRec_correct k (n+1)`.
- Re-point `endCharRec`'s `innerConv` from `navBrickForm` → `navMultiAnchorForm` (reuse the def
  skeleton).
- Derive the consumer entry `endChar (k) : EndCharCarrier sig k` (arity-3 instance; frozen
  `EndCharCarrier` interface UNCHANGED) and `endChar_correct`.
- Keep everything sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]`;
  additive/corrective in `Base.lean` only.

**Non-Goals**:
- Any `NormalForm sig k 4 → NormalForm sig k 3` collapse or `nf_char3_deeper_split` route
  (FORBIDDEN; refuted as a non-object — grows the anchor set).
- Re-attempting the single-anchor `navBrickForm` + Option-A per-witness `NavResidual` reshape
  (H4-refuted; relocates the same non-theorem).
- Widening the frozen `EndCharCarrier sig k` abbreviation (Base.lean:1007) — FROZEN.
- The handoff's hook-parametric Option 3 (caller-supplied `innerConv`) — non-convergent.
- Editing the seven frozen provider files, `KampPrior.lean`, or `nf_nvar_exist_all_depths`'s
  signature.
- Implementing the Lemma-3.2(2) ≤2-free-variable reduction as the main line (contingency only).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The multi-anchor navigating characteristic (nested `Since`/`Until` reaching each anchor) may not be expressible within `TL(Until,Since)` at the climbing arity — the audit rates this **Medium / uncertain** (report 02 H4 table row "BUILDABLE … Medium") | H | M | Phase 6 is the load-bearing phase. Attempt the generalization of the GREEN two-anchor `nf_zone_flatten_navigable` full-eval hooks (Base.lean:692-697) first — this is a *generalization of an already-green proof*, not new math. If it cannot close, DO NOT reach for a collapse or single-anchor reshape: mark `[BLOCKED]` and trigger the Rollback/Contingency Lemma-3.2(2) escape hatch (`/spawn 349` or AskUserQuestion) |
| Phase 6 exceeds one agent run (>350 lines) | M | H | Pre-declared split: 6a = `navMultiAnchorForm` def + statement of `_correct`; 6b = the hook-discharge proof. Each 6a/6b is its own committable green unit |
| The unconditional base `endCharN0_correct` requires `endCharN0` to navigate to anchors — a Formula at `env 0` reading `env j` (`j≥1`) is exactly the obstruction that sank v2 | H | M | Phase 5 must build the navigation INTO `endCharN0` (reach each anchor via nested `Since`/`Until`, read its atoms there), reusing only the per-position atom-literal core. If the base cannot certify the multi-anchor atom layer unconditionally, that is the earliest signal to trigger the contingency (fail fast at Phase 5, not Phase 7) |
| Removing `NavResidual` breaks green consumers (`endCharN0_correct` v2, `navResidual_base_eq_hRes`) mid-phase, reddening the build | M | H | Phase 4 is a single "interface reset" unit: remove `NavResidual` + all its conditional consumers TOGETHER and revert `endCharRec`/`endCharN0_correct` to green stubs (docstring signatures, no `sorry`), leaving the module GREEN with only the preserved skeleton + frozen signatures before Phases 5-7 rebuild |
| Temptation to fake green with `sorry`/`def X := True`/vacuous placeholder when a sub-piece resists | H | M | PROHIBITED (handoff `prohibited`). Mark `[BLOCKED]`, record the exact `lean_goal` state + missing lemma, return `status: partial`. The module stays green + sorry-free with the def-half landed and the correctness lemma unstated — a stuck main-target sorry is never a legitimate strategic sorry |
| Frozen-file edit slips in | H | L | Never open SharedWitness.lean, SubBracket2V.lean, OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean, ExteriorNegationPast.lean, KampPrior.lean; verify `git status` touches only `Base.lean` before each commit |
| Manual Rabinovich chain-step bridge tempts a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro`/`or_congr`/`exists_congr`/`and_congr_right` bridges only, mirroring `seg_holds_coupled` (Base.lean:1157-1162) and `nf_zone_flatten_navigable_correct` (Base.lean:700-706) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. Phases 5 (base) and 6 (converter) are
logically independent (both consumed by Phase 7's k-induction) and MAY run in parallel; they are
listed in one wave for that reason, but each is a single committable green unit. Phases 1-3 are
already GREEN in the tree and are carried forward `[COMPLETED]` so the orchestrator heading-scan
resumes at the first real work item (Phase 4).

**Per-phase hard bar (applies to every `[NOT STARTED]` phase below)**:
- sorry-free; `lean_verify` on the phase's new correctness lemma = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped `lake build` of
  `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base` GREEN.
- Explicit "reuse vs rebuild" note satisfied (see each phase).
- **Guards**: FORBIDDEN `nf_char3_deeper_split` (grep-confirmed absent in new code); `EndCharCarrier`
  FROZEN (not widened); G1 honest arity-`n` atom layer (no arity-1 collapse); G2/G4 free anchors ≤2
  (env arity may climb to `3+k` as bracket-witness depth — expected); G3 non-trivial `seg` interior
  (never `TemporalPred.top`); G5 manual bridges only.

### Phase 1: Step-target unfolding `nf_eval_nf_step_unfold` [COMPLETED]

- **Goal:** The `k+1` step-target decomposition is exposed as a citable equivalence.
- **Reuse vs rebuild:** REUSE as-is — already green, sorry-free, committed (`7bfb8c9a5`). Do NOT
  re-do.
- **Landed asset:** `nf_eval_nf_step_unfold` (Base.lean:~1483/1488, `Iff.rfl`) exposes
  `nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf ↔ (atom layer) ∧ (∀ sub, (∃ w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub) ↔ qnf.2 sub = true)`.
  Axioms exactly `[propext, Classical.choice, Quot.sound]`. The arity-4 inner `∃w'` it exposes is
  exactly what the multi-anchor converter (Phase 6) flattens.
- **Tasks:**
  - [x] `nf_eval_nf_step_unfold` proven and green. *(landed)*
- **Timing:** n/a (already complete)
- **Depends on:** none
- **Completed:** 2026-07-11 (commit `7bfb8c9a5`)

### Phase 2: Arity-general Π-motive `EndCharMotive` [COMPLETED]

- **Goal:** The Π-motive `(n : Nat) → NormalForm sig k n → TemporalPred` for the arity-general
  internal recursion is landed.
- **Reuse vs rebuild:** REUSE as-is — `abbrev EndCharMotive` is green (Base.lean:1579). NOTE:
  v2's *other* Phase-2 outputs (`NavResidual`, `navResidual_base_eq_hRes`, and the conditional
  `endCharRec_correct`/`endChar` docstring signatures) are SUPERSEDED — their removal is Phase 4
  work, NOT part of this preserved phase.
- **Landed asset:** `EndCharMotive` (Base.lean:1579); the motive arity `n` climbs `3 → 3+k` toward
  the base, termination on `k` alone.
- **Tasks:**
  - [x] `EndCharMotive` landed green. *(landed)*
- **Timing:** n/a (already complete)
- **Depends on:** 1
- **Completed:** 2026-07-11

### Phase 3: Recursion assembly skeleton `atomPartN` + `nf_endpoint_tl_gen`(+`_correct`) [COMPLETED]

- **Goal:** The arity-general step-assembly skeleton (atom-part wrapper + the endpoint-TL generator
  and its correctness) is landed, parametric over `innerConv`.
- **Reuse vs rebuild:** REUSE as-is — `atomPartN`, `nf_endpoint_tl_gen`, `nf_endpoint_tl_gen_correct`
  are green (P5 def-half). `nf_endpoint_tl_gen` takes `innerConv : NormalForm sig k (n+1) → Formula`
  as a **parameter**, so it is agnostic to which converter fills the slot — no change needed here.
  The audit lists these explicitly as "reusable as-is under the revise". `atomPartN`'s wrapper
  (`(endCharN0 …).formula`) is kept but inherits Phase-5's re-statement of `endCharN0`.
- **Landed assets:** `atomPartN`; `nf_endpoint_tl_gen`; `nf_endpoint_tl_gen_correct` (axioms exactly
  `[propext, Classical.choice, Quot.sound]`).
- **Tasks:**
  - [x] `nf_endpoint_tl_gen`/`_correct` + `atomPartN` landed green. *(landed)*
- **Timing:** n/a (already complete)
- **Depends on:** 2
- **Completed:** 2026-07-11

### Phase 4: Interface reset — retire single-anchor machinery, freeze unconditional signatures [NOT STARTED]

- **Goal:** Remove v2's single-anchor / conditional machinery and freeze the corrected UNCONDITIONAL
  interfaces, leaving the module GREEN + sorry-free with only the preserved skeleton (Phases 1-3) and
  the new frozen docstring signatures. This is the "reopen the FROZEN Phase-2/Phase-4 interfaces"
  step (superset of unblock option C).
- **Reuse vs rebuild:** REMOVE `navBrickForm`/`navBrickForm_correct` (Base.lean:1806/1827),
  `NavResidual` (Base.lean:1608), `navResidual_base_eq_hRes` (Base.lean:1620), and v2's conditional
  `endCharN0_correct` (Base.lean:1723). Revert `endCharRec`'s body and `endCharN0`/`endCharN0_correct`
  to green stubs (docstring signatures — NEVER `sorry`) so the module compiles without the removed
  assets. FREEZE the two corrected signatures (verbatim §Q4, reproduced above) as docstrings:
  `navMultiAnchorForm_correct` (unconditional full-eval hooks) and unconditional `endCharRec_correct`
  (no `h_nav`).
- **Tasks:**
  - [ ] Delete `NavResidual` + `navResidual_base_eq_hRes` and every conditional consumer that
        references them, in one commit, keeping the module green.
  - [ ] Delete `navBrickForm`/`navBrickForm_correct`; remove `endCharRec`'s `navBrickForm` reference
        (revert `endCharRec` body to a docstring-captured signature stub if needed to stay green).
  - [ ] Record the FROZEN `navMultiAnchorForm_correct` and unconditional `endCharRec_correct`
        signatures verbatim (from §Q4, above) as docstrings at the intended definition sites.
  - [ ] Route audit: assert FORBIDDEN `nf_char3_deeper_split` not referenced; `EndCharCarrier` not
        widened; grep-confirm no `NavResidual` occurrence remains in code.
- **Hard bar:** sorry-free; scoped Base `lake build` GREEN with the removals applied; no new axioms.
  (No new correctness lemma is *stated* this phase, so the axiom check applies to the still-green
  preserved lemmas.)
- **Timing:** ~1.5 hours (~80-150 lines, mostly deletions + frozen docstrings)
- **Depends on:** 3
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`

### Phase 5: Multi-anchor navigating base `endCharN0`/`endCharN0_correct` (unconditional) [NOT STARTED]

- **Goal:** Build the depth-0 base of the recursion as a **multi-anchor navigating** characteristic
  and prove its **unconditional** correctness (§Q4 target 2, base case). At the navigated witness,
  `endCharN0 sub` must certify the FULL arity atom layer at all positions — including the anchors
  `env 1 … env (n-1)` — by navigating (nested `Since`/`Until`) to each anchor and reading its
  predicate + order atoms there, NOT reading only `pred p 0`.
- **Reuse vs rebuild:** REUSE the atom-literal core (`nf_depth0_char_formula` / the per-position
  atom-reader). REBUILD the assembly: v2's `endCharN0` read only position 0 (`nfN_locus0`,
  Base.lean:1664-1668) — this is INSUFFICIENT for the unconditional statement (a Formula at `env 0`
  cannot read `env j`, `j≥1`, without navigating there). **Reviser determination**: the base DOES
  need re-statement to the unconditional shape — the `h_nav` hypothesis is dropped and the anchor
  layer is certified by navigation. The atom-literal machinery is reused; the position-0-only
  assembly is replaced by a navigate-to-each-anchor assembly.
- **Corrected statement (base-case instance of the frozen §Q4 target 3, no `h_nav`)**:
  `endCharN0_correct : ∀ {n} [NeZero n] (qnf : NormalForm sig 0 n) (env : Fin n → M.carrier),`
  `  (endCharN0 atomMap h_surj qnf).eval_at M atomMap (env 0) ↔ nf_eval_nf M 0 n env qnf`
  (full `nf_eval_nf` RHS, no residual, no weakening).
- **Tasks:**
  - [ ] Define `endCharN0 (atomMap) (h_surj) : {n} → NormalForm sig 0 n → TemporalPred` as the
        multi-anchor navigating atom characteristic (navigate to each anchor, read its atoms),
        reusing the atom-literal core.
  - [ ] Prove `endCharN0_correct` UNCONDITIONALLY (the frozen §Q4 base-case shape); sorry-free.
  - [ ] Route audit: G1 (honest arity-`n` atom layer, no arity-1 collapse), G2/G4 (anchors ≤2 free;
        the `n-1` positions reached as bracket witnesses, not fresh free anchors), G5 (manual
        bridges). Grep-confirm no `nf_char3_deeper_split`.
- **Hard bar:** sorry-free; `lean_verify endCharN0_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped Base build GREEN; statement = frozen §Q4
  base-case (no `h_nav`).
- **Failure signal:** if the base cannot certify the multi-anchor atom layer unconditionally, this
  is the EARLIEST signal the multi-anchor characteristic is infeasible — mark `[BLOCKED]` and trigger
  the Rollback/Contingency escape hatch here (Phase 5), do not push the obstruction to Phase 7.
- **Timing:** ~2.5 hours (~120-220 lines)
- **Depends on:** 4
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`

### Phase 6: Multi-anchor navigating converter `navMultiAnchorForm`/`_correct` (load-bearing core) [NOT STARTED]

- **Goal:** Build the genuinely-new load-bearing object: the **multi-anchor navigating** converter
  that flattens `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub` under the **unconditional
  full-eval** hooks of the frozen §Q4 target 1 (reproduced verbatim above). The interior is the
  β-segment `seg` (Q2/S3), never `BracketFormula.trivial (rec sub)` and never `⊤`-with-no-segment.
- **Reuse vs rebuild:** REUSE the GREEN two-anchor `nf_zone_flatten_navigable`/`_correct`
  (Base.lean:667/687, full-eval hooks at 692-697) as the **template** — its hooks characterize the
  FULL arity-3 eval, which is exactly the shape to generalize to arity `n+1`. REUSE `seg`/
  `seg_holds_coupled` (Base.lean:1127/1150) as the interior. REBUILD: this REPLACES the removed
  single-anchor `navBrickForm`; do NOT resurrect the diagonal-template shape.
- **Frozen target (verbatim §Q4 target 1)**: prove `navMultiAnchorForm_correct` exactly as stated in
  the "Corrected FROZEN Signatures" block above — hooks `h_past`/`h_now`/`h_fut` are UNCONDITIONAL
  biconditionals `(rec sub).eval_at w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub`, held parametric
  in `rec` (discharged in Phase 7 by the IH). The interior slot is `seg`.
- **Tasks:**
  - [ ] Define `navMultiAnchorForm (rec : NormalForm sig k (n+1) → TemporalPred) (env) (sub) : Formula`
        as the multi-anchor navigating existential converter with `seg` interior, generalizing the
        two-anchor `nf_zone_flatten_navigable` structure.
  - [ ] Prove `navMultiAnchorForm_correct` (frozen §Q4 target 1) under the three parametric
        unconditional full-eval hooks; sorry-free. Manual bridges (G5), mirroring
        `nf_zone_flatten_navigable_correct` (Base.lean:700-706).
  - [ ] Route audit: G2/G4 (every `w'` a bracket witness; free anchors ≤2 while env arity is `n+1`),
        G3 (non-trivial `seg` interior — never `⊤`), G5. Grep-confirm no `nf_char3_deeper_split` and
        no `TemporalPred.top` code-reference in the new objects.
- **Hard bar:** sorry-free; `lean_verify navMultiAnchorForm_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped Base build GREEN; hooks are the unconditional
  full-eval shape (NOT conditional on any `NavResidual`).
- **Pre-declared split (audit: shape may imply >350 lines)**: if this overruns one agent run, split
  at the definition/statement vs proof seam:
  - **6a:** `navMultiAnchorForm` def + `navMultiAnchorForm_correct` statement (parametric hooks),
    with a temporary `[BLOCKED]`/handoff on the proof body — but only after 6a's *def* is green.
  - **6b:** the hook-discharge proof of `navMultiAnchorForm_correct`.
  Each of 6a/6b is its own committable green unit.
- **Contingency trigger:** if the unconditional full-eval hooks cannot be established within
  `TL(Until,Since)` at arity `n+1` (the audit's Medium-confidence risk), mark `[BLOCKED]` and invoke
  the Rollback/Contingency Lemma-3.2(2) escape hatch — do NOT fall back to the single-anchor shape or
  a collapse.
- **Timing:** ~4 hours (~200-350 lines; the flagged load-bearing core)
- **Depends on:** 4 (independent of Phase 5; both feed Phase 7)
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`

### Phase 7: Assemble unconditional `endCharRec` + `endCharRec_correct` (k-induction) [NOT STARTED]

- **Goal:** Re-point the recursion and prove global correctness UNCONDITIONALLY. Re-instate
  `endCharRec` with `innerConv` = `navMultiAnchorForm` (over the IH), then prove `endCharRec_correct`
  (frozen §Q4 target 3, NO `h_nav`) by induction on `k`: base = `endCharN0_correct` (Phase 5, now
  unconditional — nothing to supply); step = `nf_endpoint_tl_gen_correct` whose `h_inner` is
  discharged by `navMultiAnchorForm_correct` (Phase 6) with `h_past`/`h_now`/`h_fut` **instantiated to
  the IH `endCharRec_correct k (n+1)`** — which is now UNCONDITIONAL, so the inner-witness goal that
  blocked v2 (`NavResidual M sub (Fin.cons w' env)`) no longer arises.
- **Reuse vs rebuild:** REUSE the `endCharRec` def skeleton (`Nat.rec` + `nf_endpoint_tl_gen`
  wrapper + `atomPartN`) from the P5 def-half; the ONLY def change is `innerConv`:
  `k+1 ⇒ nf_endpoint_tl_gen (atomPartN … qnf.1) (fun sub => navMultiAnchorForm (endCharRec k (n+1)) env sub) qnf`.
  REBUILD `endCharRec_correct` to the unconditional statement.
- **Tasks:**
  - [ ] Re-instate `endCharRec` (`k=0 ⇒ endCharN0`; `k+1 ⇒ nf_endpoint_tl_gen` over `atomPartN` +
        `navMultiAnchorForm (endCharRec k (n+1))`); genuinely recurses; not vacuous.
  - [ ] Prove `endCharRec_correct` UNCONDITIONAL (frozen §Q4 target 3) by induction on `k`; discharge
        the step `h_inner` via `navMultiAnchorForm_correct` with hooks = the IH; interior segment
        coupled via `seg_holds_coupled` (Base.lean:1150). sorry-free.
  - [ ] Route audit: G1-G5 inherited from Phases 5-6; G5 manual bridges for the `k→k+1` chain step.
        Confirm NO `NavResidual`/`h_nav` residual goal remains (the v2 blocker is closed).
- **Hard bar:** sorry-free; `lean_verify endCharRec_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped Base build GREEN; statement = frozen §Q4 target 3
  (unconditional, no weakening); `endCharRec` genuinely recurses.
- **Timing:** ~2.5 hours (~140-240 lines: re-point + the k-induction assembly)
- **Depends on:** 5, 6
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`

### Phase 8: Consumer entry `endChar`/`endChar_correct` + axiom + downstream-citation gate [NOT STARTED]

- **Goal:** Derive the frozen arity-3 consumer interface as the `n=3` instance, prove
  `endChar_correct`, and confirm all definition-of-done gates including task-309 citability.
- **Reuse vs rebuild:** REUSE `endCharRec`/`endCharRec_correct` (Phase 7) at `n = 3`; the frozen
  `EndCharCarrier sig k` interface (Base.lean:1007) is UNCHANGED.
- **Tasks:**
  - [ ] Define `endChar (k) : EndCharCarrier sig k := fun qnf => endCharRec atomMap h_surj k qnf`
        (arity-3 instance; interface UNCHANGED).
  - [ ] Prove `endChar_correct`:
        `(endChar k qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` as the `n=3`
        instance of the unconditional `endCharRec_correct`. Never a weakened/vacuous form.
  - [ ] `lean_verify endChar_correct` (fully qualified) = exactly
        `[propext, Classical.choice, Quot.sound]`, no `sorry`.
  - [ ] Full-tree `lake build` GREEN (scoped Base module at minimum; full tree recommended).
  - [ ] `git status` confirms only `Base.lean` (+ this plan/summary) changed — no frozen-provider or
        `KampPrior.lean` edits.
  - [ ] Grep-confirm `endChar_correct` is a top-level citable name reachable from task 309 Phase
        18/19 consumers.
- **Hard bar:** all definition-of-done gates pass (axioms exactly
  `[propext, Classical.choice, Quot.sound]`, sorry-free, no frozen edits, `endChar`/`endChar_correct`
  top-level citable).
- **Timing:** ~1 hour (~60-100 lines: instance derivation + verification)
- **Depends on:** 7
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`

## Testing & Validation

- [ ] Scoped `lake build` of `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base` is
      GREEN after every phase (per-phase gate).
- [ ] Final full-tree `lake build` GREEN.
- [ ] `lean_verify` on `endChar_correct`, `endCharRec_correct`, `navMultiAnchorForm_correct`,
      `endCharN0_correct` = exactly `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- [ ] `endCharRec_correct` is UNCONDITIONAL (no `h_nav`); `NavResidual` no longer occurs in the
      module (grep-confirmed).
- [ ] `navMultiAnchorForm_correct` hooks are the unconditional full-eval shape (NOT conditional on
      any per-witness residual); interior is `seg` (no `TemporalPred.top` code-reference).
- [ ] `git status --short` shows only `Base.lean` under `Theories/` modified (no frozen-file /
      `KampPrior.lean` edits).
- [ ] `endChar`/`endChar_correct` are top-level, name-citable declarations reachable by task 309.
- [ ] No occurrence of `nf_char3_deeper_split` in any new code; `EndCharCarrier` not widened; free
      anchors provably ≤2 (env arity may climb to `3+k` as bracket-witness depth — expected).
- [ ] `endCharRec` discharges `innerConv` internally via `navMultiAnchorForm` (NOT hook-parametric /
      Option 3).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — corrective +
  additive: removes `navBrickForm`/`_correct`, `NavResidual`/`navResidual_base_eq_hRes`, v2's
  conditional `endCharN0_correct`; adds the multi-anchor navigating `endCharN0`/`endCharN0_correct`
  (unconditional), `navMultiAnchorForm`/`navMultiAnchorForm_correct`, unconditional
  `endCharRec`/`endCharRec_correct`, and the arity-3 entries `endChar`/`endChar_correct`. Preserves
  `nf_eval_nf_step_unfold`, `EndCharMotive`, `atomPartN`, `nf_endpoint_tl_gen`(+`_correct`).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/plans/03_multi-anchor-navigating-characteristic.md`
  (this plan; supersedes plans/02).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/summaries/03_multi-anchor-navigating-characteristic-summary.md`
  (on completion).

## Rollback/Contingency

- The work is confined to `Base.lean`; rollback is `git checkout` of `Base.lean` to the pre-phase
  commit (no other files touched). Snapshot before any intentional rollback per "No Destructive Git
  on Uncommitted Work" (`bash .claude/scripts/git-snapshot.sh` first).
- Do NOT revert Phase 1's landed `nf_eval_nf_step_unfold`, Phase 2's `EndCharMotive`, or Phase 3's
  `nf_endpoint_tl_gen`(+`_correct`)/`atomPartN` under any rollback (independent, already-committed
  green assets).
- Each earlier green phase remains committed so no progress is lost. If any `[NOT STARTED]` phase
  cannot close green without a forbidden collapse, `nf_char3_deeper_split`, or a single-anchor
  reshape, mark it `[BLOCKED]`, record the exact `lean_goal` state + missing lemma, return
  `status: partial` with `requires_user_review: true`. Do NOT land a vacuous, `sorry`'d, or
  Option-3 hook-parametric `endChar`.

### Escape hatch — Rabinovich Lemma 3.2(2) ≤2-free-variable reduction (contingency, NOT main line)

The audit rates the multi-anchor navigating characteristic as **Medium-confidence buildable** (H4
table): it is not yet realized in-tree. If the unconditional full-eval hooks (Phase 6) or the
unconditional base (Phase 5) prove **infeasible within `TL(Until,Since)` at the climbing arity**,
the faithful alternative is to apply Rabinovich **Lemma 3.2(2)** (md:119) — every `∃∀`-formula is
equivalent to a conjunction of `∃∀`-formulas with **at most two free variables** — as a REDUCTION
BEFORE navigating, keeping the recursion at arity ≤ 3 (two anchors + witness), as the green arity-3
`nf_zone_flatten_navigable` line does. **This requires a Lean analogue of Lemma 3.2(2), which does
NOT currently exist in-tree** (audit: Medium / uncertain, not exhaustively grepped) — hence it is a
contingency, not the primary path.

**Trigger condition** (explicit): if Phase 5 OR Phase 6 is marked `[BLOCKED]` because the multi-anchor
characteristic itself cannot be stated/proved (as opposed to a mere proof-engineering overrun, which
uses the 6a/6b split), then either:
- run `/spawn 349` to create a dedicated task for the Lean Lemma-3.2(2) ≤2-free-variable reduction
  analogue (the missing structural lemma), recording this plan's Phase-5/6 blocker as its blocker;
  OR
- if a human is in the loop, raise an `AskUserQuestion` offering: (a) spawn the Lemma-3.2(2)
  reduction sub-task, (b) accept a `[BLOCKED]` terminus with the def-half preserved green, or
  (c) authorize a further `/revise` to re-architect onto the ≤2-free-variable line.

Do NOT silently substitute the single-anchor `navBrickForm` or any `nf_char3_deeper_split` collapse
under this contingency — both are refuted (H4 / FORBIDDEN).
