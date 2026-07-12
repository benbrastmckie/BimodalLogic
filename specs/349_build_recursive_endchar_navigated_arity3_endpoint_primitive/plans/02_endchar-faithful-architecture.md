# Implementation Plan: Task #349 (v2 — faithful arity-general architecture)

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (consumes only already-landed, sorry-free assets)
- **Research Inputs**:
  - reports/01_endchar-faithful-architecture.md (H5 divergence audit; the load-bearing input for this revision)
  - (grounding) task-309 reports/02_endpoint-hook-discharge-research.md (§1.4, §4, §6) and reports/08_spawn-analysis.md
- **Artifacts**: plans/02_endchar-faithful-architecture.md (this file); supersedes plans/01_recursive-endchar-primitive.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build `endChar : (k : Nat) -> EndCharCarrier sig k` (where
`EndCharCarrier sig k := NormalForm sig k 3 -> TemporalPred`, Base.lean:1007) plus its correctness
theorem `endChar_correct`, using the **faithful Rabinovich navigational architecture** established by
the H5 divergence-audit report (reports/01). The prior plan (plans/01) attempted `endChar` by pure
`Nat.rec` into the *frozen arity-3* carrier and hit a **structural blocker at Phase 2**: the step case
required a `NormalForm sig k 4 -> NormalForm sig k 3` arity collapse that is provably impossible
(NormalForm.lean:134-136 — the modal-depth step increments arity by exactly one, by the type
definition). Report 01 confirms the collapse is a non-object AND, decisively, that **Rabinovich never
collapses arity — he navigates** (Cor 5.4, md:255-271: `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`, the
inner characteristic carried verbatim as an `Until` hook).

The revised design replaces the fixed-arity `Nat.rec` carrier with an **arity-general internal
recursion** on modal depth `k` with a Π-motive `(n : Nat) -> NormalForm sig k n -> TemporalPred`:

- `endCharRec (atomMap) (h_surj) : (k : Nat) -> {n : Nat} -> NormalForm sig k n -> TemporalPred`,
  recursing structurally on `k`. Each step flattens the arity-`(n+1)` inner `∃w'` with an
  **arity-general navigable brick** whose `h_past`/`h_fut` hooks **are the IH at `(k, n+1)`**; it
  bottoms out at a finite arity-`(3+k)` depth-0 atom layer. **NO collapse, NO forbidden
  `nf_char3_deeper_split`.**
- The consumer-facing `endChar : NormalForm sig k 3 -> TemporalPred` is the **arity-3 instance** of
  `endCharRec`, so the frozen `EndCharCarrier` interface is **UNCHANGED** and downstream task 309
  Phase 18/19 cite `endChar_correct` by name without modification.

The env arity legitimately climbs `3 -> 3+k` toward the base while the **free-anchor count stays ≤2**
(every deeper `w'` is a *bracket* witness bound one-at-a-time by an enclosing `Until`/`Since`, per
Rabinovich Notation 5.2, md:219). Env arity (witness depth) is distinct from free-anchor count (the
real ≤2 cap, G4).

Scope is `Base.lean` only, additive. Definition of done: `lake build` GREEN (scoped Base module at
minimum; full tree recommended); `endChar`/`endChar_correct` sorry-free; `lean_verify` on
`endChar_correct` = exactly `[propext, Classical.choice, Quot.sound]`; no frozen-file edits; task 309
Phase 18/19 can cite `endChar_correct` by name.

### Research Integration

This is a **plan revision (v2)** integrating the newly-landed H5 divergence-audit report:

- **reports/01_endchar-faithful-architecture.md** — REFUTES the v1 Phase-2 approach and supplies the
  faithful architecture. Key integrated findings:
  - VERDICT: the impossibility is CONFIRMED-BUT-MISDIRECTED — it refutes the frozen *contract*
    (pure arity-3 `Nat.rec`), not the task. The collapse is impossible AND not what Rabinovich does.
  - §1: the decisive type fact — `NormalForm sig (k+1) n .2 : NormalForm sig k (n+1) -> Bool`
    (NormalForm.lean:134-136); a depth-`k` recursion carrier fixed at one arity is ill-typed.
  - §2: Rabinovich Cor 5.4 is navigational (Until-hook), never collapsing; the ≤2-free-var cap is
    *held by* the navigation (witnesses bound one-at-a-time), and env arity ≠ free-anchor count.
  - §3: the exact buildable Lean shapes — `endCharN0`, `nf_endpoint_tl_gen`, `navBrickForm`,
    `endCharRec`, `endCharRec_correct`, arity-3 entry `endChar`.
  - §4: the H3 5-column lemma-mapping table (Rabinovich 2014 -> Lean identifiers).
  - §5.5: the "corrected lean-ready targets" — five signatures the next dispatch should attempt.
  - REJECTS the prior handoff's hook-parametric Option 3 as green-but-non-convergent (re-defers
    `innerConv` to the caller — the strike-5 deferral pattern report 02 diagnosed).

The phases below are shaped directly by the §5.5 corrected-target list and the §4 H3 mapping table.

### Prior Plan Reference

plans/01_recursive-endchar-primitive.md is superseded. Its Phase 1 deliverable is PRESERVED (already
landed, sorry-free — see Phase 1 below). Its Phase 2 ("arity-4->arity-3 brick-witness-collapse
bridge") is **discarded as a non-object** (report 01 §5.2: "the brick *flattens*, it does not
*collapse*"). Its Phases 3-5 are re-scoped onto the arity-general recursion.

### Roadmap Alignment

No `roadmap_flag` for this dispatch; ROADMAP.md is not modified. The work advances the Kamp-theorem
formalization line (unblocks task 309 Phase 18/19).

## Goals & Non-Goals

**Goals**:
- Define an **arity-general** internal recursion
  `endCharRec (atomMap) (h_surj) : (k) -> {n} -> NormalForm sig k n -> TemporalPred` (structural on
  `k`, Π-motive over `n`), with the depth step built from an arity-general atom base, an arity-general
  navigable brick (Until-hook), and the non-trivial `seg` interior — NO arity collapse.
- Define the consumer entry `endChar (k) : EndCharCarrier sig k := fun qnf => endCharRec … k qnf`,
  preserving the frozen arity-3 interface exactly.
- Prove `endCharRec_correct` by induction on `k` (base = generalized `endChar0_correct`; step =
  generalized `nf_char3_endpoint_tl_correct` with `h_inner` discharged by the brick whose hooks are
  the IH at `(k, n+1)`, interior coupled via `seg_holds_coupled`), and derive
  `endChar_correct : (endChar k qnf).eval_at M atomMap w <-> nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` as
  the arity-3 instance under the structurally-required residual hypotheses.
- Keep everything sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]`.
- Land additively in `Base.lean` only.

**Non-Goals**:
- Any `NormalForm sig k 4 -> NormalForm sig k 3` collapse or `nf_char3_deeper_split` route (FORBIDDEN;
  refuted as a non-object).
- The handoff's hook-parametric Option 3 (`endChar` taking a caller-supplied `innerConv`) — REJECTED
  as non-convergent; `innerConv` must be discharged internally by the brick + IH.
- The aggregate `∀`-qnf `quantEnd` construction and the three arm-correctness hook discharges
  (task-309 follow-up).
- Editing `KampPrior.lean`, `nf_nvar_exist_all_depths`'s signature, or the frozen provider files.
- Rebuilding `endChar0`, `seg`, or `nf_zone_flatten_navigable(_brick)` (generalize/consume, never
  rebuild from scratch).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The arity-general `navBrickForm` (arity-`(n+1)` generalization of the arity-3 brick, Base.lean:667/813) is the genuinely-new load-bearing core and may resist generalization | H | M | Phase 4 is the flagged load-bearing phase; it is a *generalization of an already-green proof* (report 01 §3.1), not new math. If it overruns one agent run, split at the (statement generalization)/(hook-discharge) seam into 4a/4b. Escalate `[BLOCKED]` rather than reach for a collapse |
| Temptation to re-attempt a collapse or `nf_char3_deeper_split` when the brick generalization resists | H | M | Guard binding: FORBIDDEN. The whole point of the brick is that `w'` stays a bracket witness (report 01 §3.3, §5.2). Route audit recorded per phase; grep-confirm no `nf_char3_deeper_split` |
| Temptation to fall back to Option 3 (caller-supplied `innerConv`) to get something green | H | M | REJECTED by report 01 §5 / Adversarial-Verification note: non-convergent (strike-5 deferral). `endCharRec` MUST discharge `innerConv` internally via the brick + IH. A hook-parametric `endChar` does not satisfy the definition of done |
| The Π-motive `Nat.rec` (arity climbs with depth) reads as an unbounded tower / non-terminating | M | M | Report 01 §Adversarial-Verification refutes this: recursion is structural on `k` (strictly decreasing); `n` is a motive parameter climbing to a *finite* `3+k` at base `k=0` where `NormalForm sig 0 n = AtomKind sig n -> Bool` is a pure atom layer. Termination is on `k` alone. Encode the motive explicitly (Phase 2) |
| Exact residual/coupling hypothesis shape of `endCharRec_correct` (the arity-general `h_nav` generalizing `endChar0_correct`'s `h_res`) is an open implementation choice | M | H | Fix and freeze the arity-general `NavResidual`/`h_nav` statement in Phase 3 (mirroring `h_res`, generalized over `n`); Phases 4-5 must prove that exact statement, never a convenience-weakened or vacuous form (guard against vacuity per lean4 vacuous-definitions rule) |
| A sub-piece cannot close green | H | L-M | Mark the phase `[BLOCKED]`, document the goal state reached and the missing lemma, return `status: partial`. Do NOT land a vacuous or sorry'd `endChar` |
| Manual Rabinovich chain-step bridge tempts a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro` bridges only, mirroring `seg_holds_coupled` (Base.lean:1157-1162) and `nf_zone_flatten_navigable_correct` (Base.lean:700-706) |
| Frozen-file edit slips in | H | L | Never open the frozen providers (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean, ExteriorNegationPast.lean, KampPrior.lean); verify `git status` touches only `Base.lean` before each commit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This chain is fully sequential: each phase
consumes the green artifact of the prior one. (The arity-general atom base, Phase 3, and the
arity-general navigable brick, Phase 4, are logically separable but share the arity-general motive
frozen in Phase 2, so they are ordered rather than parallel to keep each a single committable unit.)

### Phase 1: Step-target unfolding — ALREADY LANDED [COMPLETED]

**Goal**: The `k+1` step-target decomposition is exposed as a citable equivalence. This phase is
carried forward from plans/01 Phase 1 and is already green in the tree — do NOT re-do it.

**Landed asset** (green, sorry-free, committed):
- `nf_eval_nf_step_unfold` (Base.lean:~1483/1488, `Iff.rfl`) exposes
  `nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf ↔ (atom layer at zoneEnv3 w a b) ∧ (∀ sub : NormalForm sig k 4, (∃ w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub) ↔ qnf.2 sub = true)`.
  Axioms exactly `[propext, Classical.choice, Quot.sound]`. Report 01 §5.3 confirms this is a stable
  citation point requiring no change; the arity-4 inner `∃w'` it exposes is exactly what the
  arity-general brick (Phase 4) flattens.

**Tasks**:
- [x] `nf_eval_nf_step_unfold` proven and green (Base.lean:~1483). *(landed)*
- [x] Docstring records the atom-layer + per-arity-4-sub decomposition. *(landed)*

**Timing**: n/a (already complete)

**Depends on**: none

**Files to modify**: none (asset already present)

**Verification**:
- `lean_verify nf_eval_nf_step_unfold` = `[propext, Classical.choice, Quot.sound]`, sorry-free.
  (Confirm still green as a Phase-2 precondition; no new work.)

### Phase 2: Arity-general motive + frozen `endCharRec`/`endCharRec_correct` signatures [COMPLETED]

**Goal**: Encode the Π-motive `(n : Nat) -> NormalForm sig k n -> TemporalPred` and freeze the
signatures of `endCharRec` and `endCharRec_correct` (including the arity-general residual hypothesis
`h_nav`) so downstream phases prove a fixed, non-weakened statement. No proof bodies yet — this phase
fixes types.

**Tasks**:
- [x] Write the frozen signature of
  `endCharRec (atomMap) (h_surj) : (k : Nat) -> {n : Nat} -> NormalForm sig k n -> TemporalPred`
  (structural recursion on `k`, `n` a motive parameter). Record in a docstring that the motive arity
  `n` climbs `3 -> 3+k` toward the base and termination is on `k` alone (report 01
  §Adversarial-Verification). *(deviation: altered — body deferred to Phase 5 per the Phase-2 escape
  clause; the `def` body needs the unbuilt `endCharN0`/`nf_endpoint_tl_gen`/`navBrickForm`/`atomPartN`
  and cannot typecheck without `sorry`, so the signature is captured in a docstring at Base.lean:1509
  rather than as a stubbed `def`. The motive itself IS landed green as `abbrev EndCharMotive`,
  Base.lean:1579.)*
- [x] Write the frozen signature of `endCharRec_correct`:
  `∀ (k) {n} (qnf : NormalForm sig k n) (env : Fin n -> M.carrier) (h_nav : NavResidual M env), (endCharRec atomMap h_surj k qnf).eval_at M atomMap (env 0) ↔ nf_eval_nf M k n env qnf`
  (report 01 §3.2). Define the arity-general residual predicate `NavResidual M env` generalizing
  `endChar0_correct`'s `h_res` over `n` (report 01 §3.3, §5.4 row 4) — pin the anchor/order layer at
  the `n-1` non-witness positions; do NOT make it vacuous. *(deviation: altered — (a) `endCharRec_correct`
  statement deferred to a docstring (Base.lean:1531) because it references the deferred `endCharRec`
  term; (b) `NavResidual` is landed as a real green `def` (Base.lean:1608) but parameterized as
  `NavResidual M qnf env` with `[NeZero n]`, NOT the schematic `NavResidual M env` — faithfulness to
  `h_res` REQUIRES the `qnf` coupling (dropping it loses the predicate anchors / risks vacuity), and
  `[NeZero n]` makes the position-0 witness reference `(0 : Fin n)` well-typed (arity always ≥3).
  Non-vacuity + base-case coincidence with `h_res` are proved green by `navResidual_base_eq_hRes`,
  Base.lean:1620.)*
- [x] Write the frozen consumer entry signature
  `endChar (k) : EndCharCarrier sig k := fun qnf => endCharRec atomMap h_surj k qnf` and confirm
  `EndCharCarrier sig k = NormalForm sig k 3 -> TemporalPred` (Base.lean:1007) is inhabited by the
  `n = 3` instance (interface UNCHANGED). *(deviation: altered — `endChar` def body deferred to
  Phase 6 (docstring at Base.lean:1547, references the deferred `endCharRec`); inhabitation of the
  UNCHANGED frozen carrier at `n = 3` confirmed green via `example : Nonempty (EndCharCarrier sig k)`,
  Base.lean:1632.)*
- [x] Route audit: G1 (atom layer honest arity-`n`, no arity-1 collapse); G4 (free anchors ≤2 at the
  formula level, env arity is witness depth — record the distinction from report 01 §2/§3.3);
  explicitly assert FORBIDDEN `nf_char3_deeper_split` is not referenced. *(recorded in the Route audit
  docstring, Base.lean:1558-1570; grep-confirmed no code reference to `nf_char3_deeper_split` in any
  Phase-2 object.)*

**Timing**: ~1.5 hours (~60-120 lines; signatures + motive + `NavResidual` def, no heavy proofs)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — add the motive,
  `NavResidual`, and the frozen `endCharRec`/`endCharRec_correct`/`endChar` signatures/docstrings
  (additive; bodies may be `sorry`-free stubs only if they typecheck without `sorry` — otherwise
  defer the `def` bodies to their producing phase and capture the shape in docstrings, mirroring
  the plans/01 Phase-1 escape clause).

**Verification**:
- The signatures typecheck (`lake build` Base module GREEN with any deferred bodies clearly marked,
  never `sorry`'d).
- The `endCharRec_correct` statement is reviewed to be the faithful navigated characterization
  (report 01 §3.2), not weakened/vacuous; `endChar` inhabits `EndCharCarrier sig k` at `n = 3`.

### Phase 3: Arity-general atom base `endCharN0` + `endCharN0_correct` (k=0) [COMPLETED]

**Goal**: Build the depth-0 base of the recursion: the arity-general pure atom layer and its
correctness, generalizing `endChar0`/`nf3_locus0`/`endChar0_correct` over `n` (report 01 §5.5 target
1, §3.2 base case).

**Tasks**:
- [x] Define `endCharN0 (atomMap) (h_surj) : {n : Nat} -> NormalForm sig 0 n -> TemporalPred`
  generalizing `endChar0` (Base.lean:995) and `nf3_locus0` (Base.lean:982) from arity 3 to arbitrary
  `n`. At `k = 0`, `NormalForm sig 0 n = AtomKind sig n -> Bool` is a finite pure atom layer (no
  further recursion) — report 01 §Adversarial-Verification confirms the base is finite at arity
  `3+k`. *(landed green: `nfN_locus0` + `endCharN0` at Base.lean:1663/1682; `n = 0` arm is a
  total-function `TemporalPred.top` placeholder — never consumed — so the def stays `{n}`-general
  without `[NeZero n]`, matching the frozen `EndCharMotive`/`endCharRec` shape.)*
- [x] Prove `endCharN0_correct`: the generalized `endChar0_correct` (Base.lean:1056). The `w`-locus
  predicate layer is read locally; the anchor/order layer at the other `n-1` positions is the
  residual `h_nav` (the arity-general `h_res`). Reuse the existing `endChar0_correct` method,
  generalized over `n` — sorry-free. *(landed green: `endCharN0_wlocus_correct` +
  `endCharN0_correct` at Base.lean:1688/1723; axioms exactly `[propext, Classical.choice,
  Quot.sound]`; statement = frozen `endCharRec_correct` k=0 instance, full `nf_eval_nf` RHS, no
  weakening.)*
- [x] Route audit: G1 (honest arity-`n` atom layer, no arity-1 collapse), G4 (anchors ≤2 free;
  the `n-1` positions are residual, not fresh free anchors), G5 (manual bridges). *(recorded in the
  Phase-3 Route-audit docstring, Base.lean:1644-1656; grep-confirmed `nf_char3_deeper_split` is not
  code-referenced by any Phase-3 object.)*

**Timing**: ~2 hours (~100-180 lines; generalization of two green proofs over `n`)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — add `endCharN0`,
  `endCharN0_correct` (additive).

**Verification**:
- `lake build` Base module GREEN; `endCharN0`/`endCharN0_correct` sorry-free.
- `lean_verify endCharN0_correct` = exactly `[propext, Classical.choice, Quot.sound]`.
- The proved statement matches the frozen Phase-2 base-case shape (no weakening).

### Phase 4: Arity-general navigable brick `navBrickForm` + `_correct` (the load-bearing core) [COMPLETED]

**Goal**: Build the genuinely-new load-bearing object: the **arity-`(n+1)` generalization** of the
navigable brick (`nf_zone_flatten_navigable`/`_correct`, Base.lean:667/687, currently arity-3 only)
that flattens `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub` into the five navigated zones,
keeping `w'` a **bracket witness** (≤2 active anchors) — the Rabinovich `β_i Until F_i` navigation,
NOT a collapse (report 01 §3.1, §5.5 target 3, §4 mapping row 2).

**Tasks**:
- [x] Define `navBrickForm (rec : NormalForm sig k (n+1) -> TemporalPred) (sub : NormalForm sig k (n+1)) : ...`
  as the arity-general navigable brick applied to `sub`, using `rec` (the depth-`k` IH) as the
  `pastEnd`/`futureEnd` endpoint hooks and `seg` (Base.lean:1127) as the non-trivial bounded interior
  (G3 — never `TemporalPred.top`). Generalize `nf_zone_flatten_navigable` (Base.lean:667) from arity 3
  to arity `n+1`. *(landed green: `navBrickForm` at Base.lean:1806 — deviation: realized as a
  `Formula`-valued single-anchor 3-zone converter (structural analog of `nf_char2_diag_exist_tl`,
  Base.lean:168) rather than a Prop-valued 5-zone two-anchor brick, because `innerConv` requires a
  `Formula` evaluated at the single accessible anchor `a = env 0`; the non-trivial interior is
  `BracketFormula.trivial (rec sub)` carried through the seg-parameter of `A_past`/`A_future`, never
  `TemporalPred.top`.)*
- [x] Prove `navBrickForm_correct`: the generalized `nf_zone_flatten_navigable_correct`
  (Base.lean:687). Its `h_past`/`h_fut` hooks are held **parametric** (to be discharged in Phase 5 by
  the IH `endCharRec_correct k (n+1)`); the bounded interior rides the non-trivial `rec sub` segment
  (the `seg.holds` conjunct is absorbed by the parametric hooks, discharged in Phase 5 via
  `seg_holds_coupled`, Base.lean:1150). Target statement proved (with anchor `a`, Phase 5 sets
  `a := env 0`): `temporal_truth a (navBrickForm rec sub) ↔ ∃ w', nf_eval_nf M k (n+1) (Fin.cons w'
  env) sub` under the hook hypotheses (report 01 §3.2 step case). *(landed green at Base.lean:1827;
  axioms exactly `[propext, Classical.choice, Quot.sound]`.)*
- [x] Route audit: G2/G4 — every deeper `w'` is a *bracket* witness bound by the enclosing
  `Until`/`Since`; the free-anchor count stays ≤2 while env arity is `n+1` (report 01 §3.3). G5 —
  manual `or_congr`/`exists_congr`/`and_congr_right` composition (mirroring Base.lean:204-205 and
  700-706) over `exists_trichotomy_split`; no `simp`/`omega`/`aesop` chain-step shortcut.
  `nf_char3_deeper_split` NOT used. *(recorded in the Phase-4 Route-audit docstring, Base.lean
  ~1786-1804; grep-confirmed no `nf_char3_deeper_split`/`TemporalPred.top` code-reference in the new
  objects — only narrative mentions in docstrings.)*

**Timing**: ~3 hours (~200-350 lines). This is the flagged load-bearing phase (report 01: "the
~300-500 line core"). If it overruns one agent run, split at the (statement generalization)/(hook
discharge) seam into 4a/4b. If a sub-piece cannot close green, mark `[BLOCKED]`, document the goal
state and the missing lemma, return `status: partial` — do NOT land a vacuous or sorry'd brick.

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — add `navBrickForm`,
  `navBrickForm_correct` (additive).

**Verification**:
- `lake build` Base module GREEN; `navBrickForm`/`navBrickForm_correct` sorry-free.
- `lean_verify navBrickForm_correct` = exactly `[propext, Classical.choice, Quot.sound]`.
- Grep confirms no `nf_char3_deeper_split` occurrence in the new code; anchors provably ≤2.

### Phase 5: Assemble `endCharRec` + `endCharRec_correct` (k-induction) [IN PROGRESS]

**Goal**: Tie the base (Phase 3) and the brick step (Phase 4) into the arity-general recursion and
prove global correctness by induction on `k`, discharging the step's `h_inner`/`h_past`/`h_fut` hooks
with the IH `endCharRec_correct k (n+1)` — the IH consumed at the arity the step produces (report 01
§3.2, §5.5 target 4). Also generalize `nf_char3_endpoint_tl`/`_correct` (Base.lean:869/885) to
arity-`n` as `nf_endpoint_tl_gen` (report 01 §5.5 target 2) to assemble the step.

**Tasks**:
- [ ] Define `nf_endpoint_tl_gen (atomPart) (innerConv : NormalForm sig k (n+1) -> Formula) (q : NormalForm sig (k+1) n) : TemporalPred`
  generalizing `nf_char3_endpoint_tl` (Base.lean:869) from `zoneEnv3`/arity-3 to arity-`n`.
- [ ] Define `endCharRec` via `Nat.rec` with the Phase-2 Π-motive:
  `k = 0 => endCharN0 …`; `k+1 => nf_endpoint_tl_gen (atomPartN … qnf.1) (fun sub => navBrickForm (endCharRec k (n+1)) sub) qnf`
  — `innerConv` is the brick over the IH at arity `n+1`, **discharged internally** (NOT deferred to a
  caller; Option 3 rejected).
- [ ] Prove `endCharRec_correct` by induction on `k`: base = `endCharN0_correct` (Phase 3, supplying
  `h_nav`); step = generalized `nf_char3_endpoint_tl_correct` (Base.lean:885) whose `h_inner` is
  discharged by `navBrickForm_correct` (Phase 4) with its `h_past`/`h_fut` hooks **instantiated to the
  IH `endCharRec_correct k (n+1)`** — the recursion closes because the IH is available at `(k, n+1)`
  in a `k`-induction (report 01 §Adversarial-Verification, second refutation). Interior coupling via
  `seg_holds_coupled` (Base.lean:1150) — NOT a sorry.
- [ ] Route audit: G1-G5 satisfied by construction (inherited from Phases 3-4); G5 manual bridges for
  the `k->k+1` chain step.

**Timing**: ~2 hours (~120-220 lines: `nf_endpoint_tl_gen` + the `k`-induction assembly).

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — add
  `nf_endpoint_tl_gen`(`_correct` if needed), `endCharRec`, `endCharRec_correct` (additive).

**Verification**:
- `lake build` Base module GREEN; `endCharRec`/`endCharRec_correct` sorry-free.
- `lean_verify endCharRec_correct` = exactly `[propext, Classical.choice, Quot.sound]`.
- The proved statement is the frozen Phase-2 one (no weakening); `endCharRec` genuinely recurses
  (not vacuous).

### Phase 6: Consumer entry `endChar`/`endChar_correct` + axiom + downstream-citation gate [NOT STARTED]

**Goal**: Derive the frozen arity-3 consumer interface as the `n=3` instance, prove
`endChar_correct`, and confirm all definition-of-done gates including task-309 citability.

**Tasks**:
- [ ] Define `endChar (k) : EndCharCarrier sig k := fun qnf => endCharRec atomMap h_surj k qnf`
  (arity-3 instance; interface UNCHANGED, report 01 §5.5 target 5).
- [ ] Prove `endChar_correct`:
  `(endChar k qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` under the
  structurally-required residual hypotheses, as the `n=3` instance of `endCharRec_correct` (report 02
  §1.4 shape, corrected to the arity-general derivation). Never a weakened/vacuous form.
- [ ] `lean_verify` on `endChar_correct` (fully qualified) returns exactly
  `[propext, Classical.choice, Quot.sound]` and reports no `sorry`.
- [ ] Full-tree `lake build` GREEN (scoped Base module at minimum; full tree recommended).
- [ ] `git status` confirms only `Base.lean` (and this plan/summary) changed — no frozen-provider or
  `KampPrior.lean` edits.
- [ ] Grep-confirm `endChar_correct` is a top-level citable name reachable from task 309's Phase
  18/19 consumers (the `h_quant`/`h_past`/`h_fut`/`h_diag` hook sites).

**Timing**: ~1 hour (~60-100 lines: the instance derivation + verification).

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — add `endChar`,
  `endChar_correct` (additive); minor doc stabilization for downstream citation if needed.

**Verification**:
- All definition-of-done gates pass (axioms exactly `[propext, Classical.choice, Quot.sound]`,
  sorry-free, no frozen edits, `endChar`/`endChar_correct` top-level citable).

## Testing & Validation

- [ ] `lake build` of `Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base` is
  GREEN after every phase (per-phase gate).
- [ ] Final full-tree `lake build` is GREEN.
- [ ] `lean_verify` on `endChar_correct` = exactly `[propext, Classical.choice, Quot.sound]`, no
  `sorry`.
- [ ] `lean_verify` on `endCharRec_correct`, `navBrickForm_correct`, `endCharN0_correct` = the same
  axiom set.
- [ ] `git status --short` shows only `Base.lean` under `Theories/` modified (no frozen-file /
  `KampPrior.lean` edits).
- [ ] `endChar` and `endChar_correct` are top-level, name-citable declarations reachable by task 309.
- [ ] No occurrence of `nf_char3_deeper_split` in any new code; free anchors provably ≤2 (env arity
  may climb to `3+k` as bracket-witness depth — this is expected and correct).
- [ ] `endCharRec` discharges `innerConv` internally (NOT hook-parametric / Option 3).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — additive: the
  arity-general motive + `NavResidual`, `endCharN0`/`endCharN0_correct`,
  `navBrickForm`/`navBrickForm_correct`, `nf_endpoint_tl_gen`, `endCharRec`/`endCharRec_correct`, and
  the arity-3 entries `endChar`/`endChar_correct`. (`nf_eval_nf_step_unfold` already landed.)
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/plans/02_endchar-faithful-architecture.md`
  (this plan; supersedes plans/01).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/summaries/02_endchar-faithful-architecture-summary.md`
  (on completion).

## Rollback/Contingency

- The work is purely additive to `Base.lean`; rollback is `git checkout` of `Base.lean` to the
  pre-task commit (no other files touched). Snapshot before any intentional rollback per the "No
  Destructive Git on Uncommitted Work" rule (`bash .claude/scripts/git-snapshot.sh` first).
- If Phase 4 (the arity-general brick) or Phase 5 (the `k`-induction) cannot close green without a
  forbidden collapse or `nf_char3_deeper_split`, mark the phase `[BLOCKED]`, document the exact goal
  state and the missing structural lemma, return `status: partial` with `requires_user_review: true`,
  and escalate — do NOT land a vacuous, sorry'd, or Option-3 hook-parametric `endChar`. Each earlier
  green phase remains committed so no progress is lost.
- Do NOT revert Phase 1's landed `nf_eval_nf_step_unfold` under any rollback (it is an independent,
  already-committed green asset).
