# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`)

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2` (task 321 v4 / NavigatedSpine Phase-7 two-level quant-layer connector)
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: 334 (COMPLETED — verified carrier inputs in `SharedWitness.lean`)
- **Research Inputs**: specs/335_outer_gate_assembly_engine_kvE2_body/reports/01_outer-gate-assembly-engine.md
- **Artifacts**: plans/01_outer-gate-assembly.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The outer gate has **no live definition** — the only `def`s of `kvE2_body` / `bracketEndChar_kvE2`
live in the quarantined Boneyard and encode the superseded two-level "navigated" carrier that
failed to assemble. Task 334 delivered a re-architected **faithful carrier** `kvE2_sepBody`
(`SharedWitness.lean:806`), verified sorry-free and axiom-clean, whose type is *definitionally*
`BracketEndCharCarrierV sig 2`. This task assembles that verified carrier into a **live**
`bracketEndChar_kvE2` def and proves the `k = 2` correctness gate against the interface
`BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) that `KampPrior.lean:351` will eventually
consume.

The work is **purely additive**: a new sibling file `OuterGate.lean` in
`NfMultiAnchorBridge/`, plus an aggregator import. The task-334 carrier and its correctness lemmas
are treated as **verified INPUTS** and are **not edited or re-proved**. Definition of done: a live
`bracketEndChar_kvE2` def + `_two_eq` `rfl` bridge, plus a proved, `lean_verify` axiom-clean
`k = 2` gate-correctness theorem for the **left-interior** owner class, with all seven faithfulness
invariants (F1-F7) preserved.

### Research Integration

The report (`reports/01_outer-gate-assembly-engine.md`) supplies: the no-live-def state (Boneyard
`:814/:918`); the verified carrier inputs with grounded signatures (`kvE2_sepBody` :806,
`_holds_iff` :840, `_nonvacuous` :1382, `_complete` :1531, `_extract` :1955, `kvE2_sepArr'_sound`
:2536, honest bundles :1207/:1259, `kvE2_sepBundleL/R_parts` :1634/:1656); the consumed interface
`BracketCarrierCorrectVPrior` and the k≤1 landed pattern to mirror
(`bracketEndChar_kv_correct_zero_prior`/`_one_prior`, PriorInterface :80/:95); the connector
`kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`); the four historical failed closers
(NavigatedSpine :423-435) and *why* the task-334 carrier structurally disarms them; and the
five-part connector obligation (a)-(e) (NS:414-419). Every axiom check
(`{propext, Classical.choice, Quot.sound}`, no `sorryAx`) was run live via `lean_verify`.

### Prior Plan Reference

No prior plan for task 335. The immediate predecessor is task 334's plan
(`specs/334_faithful_carrier/plans/03_faithful-carrier-regrounding.md`), used here **only** as
reference: it fixes the acceptance bar (axiom-clean, no bare `sorry`), the F1-F7 faithfulness
invariants, and the tracked scope note (lines 417-419, 428-430) that defers right-interior
validity-channel generalization — the exact boundary this task honors by scoping to left-interior.

### Roadmap Alignment

No ROADMAP.md consulted for this task (roadmap flag not set). The task advances the
`kamp_theorem_formalization` topic by supplying the missing k=2 rung between the verified carrier
and the depth-k≥2 Cor 5.4 converter.

## Goals & Non-Goals

**Goals**:
- Introduce a **live** `noncomputable def bracketEndChar_kvE2` delegating to the faithful carrier
  `kvE2_sepBody`, with a `bracketEndChar_kvE2_two_eq : … = kvE2_sepBody … := rfl` bridge.
- Prove the **⇒ soundness** direction of the k=2 gate: `holds → ∃ w, nf_eval_nf M 2 3 …` via
  `kvE2_sepBody_extract` + `kvE_subBracket2V_sound_of_parts` + `ExistProviders.correct`.
- Prove the **⇐ completeness** direction (LEFT-INTERIOR class) via `kvE2_sepBody_complete` +
  honest bundles + `kvE2_sepArr'_sound`, closed through `kvE2_sepBody_holds_iff`.
- Assemble both directions into a `lean_verify` axiom-clean `k=2` gate-correctness theorem for the
  left-interior owner class, mirroring the landed k≤1 lift pattern.
- Preserve F1-F7 (no vacuous placeholders, no open/closed zone-key conflation, no `x1 < e_i`
  relative-position literal — the LITMUS at NS:437, witness bounds from the bracket range).

**Non-Goals**:
- **Do NOT edit or re-prove** the task-334 carrier inputs in `SharedWitness.lean` (verified INPUT).
- **Do NOT** extend `kvE2_sepDisjValidOwner` to the placement-generic self-zone / right-interior
  class — that carrier-input redefinition is **task 336's** job (R-A resolved to left-interior).
- **Do NOT** wire the gate into `KampPrior.lean:351` (`ExistProviders`/`Nat.rec` threading) — that
  integration is out of scope (R-B resolved to follow-on; see Risks).
- No bare `sorry`/`admit`, no gate-modulo-assumed-`hgate` (zero-debt, per the NS:441-449 honest
  RESCOPE discipline).

### Scope Decisions (resolved)

- **R-A (⇐ generality) → LEFT-INTERIOR ONLY.** `kvE2_sepBody_complete` requires `hL` (all positive
  owners left-interior; `nf0_zoneSpec σ.1 = kvE2_sep_zXW3`). Extending the validity channel
  (`kvE2_sepDisjValidOwner`) to the placement-generic self-zone would touch the verified carrier
  INPUT and is explicitly deferred to task 336 (right-interior generalization, runs AFTER this
  task). This task therefore proves the gate for the left-interior owner class only, exposed as a
  bespoke `hL`-guarded correctness theorem. This is additive and zero-debt: it makes the restriction
  an explicit hypothesis rather than a hidden assumption.
- **R-B (KampPrior wiring) → FOLLOW-ON (recommended, out of scope for task 335).**
  **Recommendation: keep the KampPrior:351 wiring as a distinct follow-on task, not part of task
  335.** Rationale: (1) the deliverable — the live gate def + k=2 correctness proof — is
  self-contained and sits entirely inside the declared `NfMultiAnchorBridge/` file scope; (2)
  `KampPrior.lean` does not yet reference `bracketEndChar_kvE2` or `BracketCarrierCorrectVPrior`
  (grep-0), so wiring means threading `ExistProviders` through `nf_nvar_exist_all_depths`'s
  `Nat.rec`/`n=1` case in a *different* file, outside this task's scope; (3) that threading is its
  own one-agent-run unit of work with distinct verification. This plan flags it for a follow-on
  task and does not touch `KampPrior.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Soundness connector (⇒, obligations (c)+(e)) is the real engine work and may overflow one agent run | H | M | Isolate it as its own phase (Phase 2); build it as a standalone `have`/auxiliary lemma verifying with `lean_goal` at each step; the pre-landed `_extract` already discharges (a)+(b) and the per-σ bundle inputs for (d), shrinking the residual to (c)+(e). |
| Accidentally editing the verified carrier INPUT (`SharedWitness.lean`) | H | L | All new code lives in a new sibling file `OuterGate.lean`; carrier lemmas are only *applied*, never restated. A grep gate in Phase 4 confirms `SharedWitness.lean` is unmodified. |
| Left-interior restriction leaves a hidden gap vs. the unconditional `BracketCarrierCorrectVPrior` | M | M | Make `hL` an explicit hypothesis on the delivered theorem and document that unconditional k=2 correctness requires task 336; do not silently claim the full interface. |
| Faithfulness regression: `x1 < e_i` relative-position literal (LITMUS NS:437) or open/closed zone-key conflation (F5) | H | L | Reuse carrier lemmas verbatim (they already satisfy F1-F7); add an F1-F7 preservation checklist to Phase 4 verification; witness bounds taken from the bracket range, never a chain. |
| `rfl` bridge fails because delegation is not definitional | M | L | Report confirms `kvE2_sepBody … : NormalForm sig 2 3 → VVecEA2` is *definitionally* `BracketEndCharCarrierV sig 2`; if `rfl` fails, fall back to `by unfold bracketEndChar_kvE2` — still additive. |
| Type mismatch recurrence of failed-closer #1 (`qnf.2 : NormalForm sig 1 (3+1)` vs `NormalForm sig 1 4`) | M | L | The flat one-bracket-per-weak-order carrier removes the two-level nesting; keep the interior closer PER-SUB and let the connector range over subs (the documented lesson). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Goal**: Introduce the first live `bracketEndChar_kvE2` definition, delegating to the faithful
carrier, in a new isolated file wired into the aggregator.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`
      importing `…NfMultiAnchorBridge.SharedWitness` (transitively brings `PriorInterface`,
      `ExistProviders`, `BracketEndCharCarrierV`, `CarrierK1V` into scope).
- [ ] Add `noncomputable def bracketEndChar_kvE2 (atomMap) (h_surj) (P : ExistProviders sig atomMap 1) : BracketEndCharCarrierV sig 2 := fun qnf => kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf`
      (mirror Boneyard `:918` shape but delegate to the *faithful* carrier).
- [ ] Add `theorem bracketEndChar_kvE2_two_eq … : bracketEndChar_kvE2 atomMap h_surj P qnf = kvE2_sepBody … qnf := rfl` (fallback: `by unfold bracketEndChar_kvE2` if `rfl` is not definitional).
- [ ] Add `OuterGate` to the `NfMultiAnchorBridge.lean` aggregator import list.

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — new file: def + bridge.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (aggregator) — add import.

**Verification**:
- `lake build` of `OuterGate.lean` succeeds; `mcp__lean-lsp__lean_diagnostic_messages` clean.
- `bracketEndChar_kvE2_two_eq` typechecks (bridge is `rfl` or `unfold`).
- `lean_verify bracketEndChar_kvE2_two_eq` shows no `sorryAx`.

---

### Phase 2: ⇒ soundness direction lemma [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: Cannot build `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`
  from the carrier `holds`. `nf_eval_nf M 2 3` (NormalForm.lean:203-207) decomposes into the atom
  layer over `[w,x,t]` PLUS the quant-layer iff `∀ sub, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔
  qnf.2 sub = true` (BOTH directions, all subs). `kvE2_sepBody_extract` yields the endpoint/ptW
  point realizations and the per-σ `kvE2_sepBundleL/R` for positive left/right-interior owners, and
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1290) reconstructs a single positive σ's
  inner realization — but only under a large per-σ `hgate` hypothesis and only the ⟸ direction.
- **What was tried**: Grounded reading of `kvE2_sepBody_extract` (:1955), `_sound_of_parts`
  (:1290), and the depth-2 eval structure. Confirmed the extract lands the per-σ bundle INPUTS but
  not the reassembly of the full depth-2 evaluation.
- **Why it's stuck**: The ⟹ direction of the quant iff (a point realizing σ forces `qnf.2 σ =
  true`) and the outer atom-layer reconstruction over `[w,x,t]` have no landed connector; assembling
  them is symmetric to the missing joint multi-owner bracket engine (see Phase 3 blocker).
- **What is needed**: The joint-disjunct connector engine (Phase 3 blocker) plus a depth-2
  quant-layer fold connecting per-σ realizations to `nf_eval_nf M 2 3`. A dedicated dispatch.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.



**Goal**: Prove the forward half of the gate as a standalone auxiliary lemma:
carrier `holds` at `(x,t)` ⟹ `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`.
This is the substantive connector engine (R-C).

**Tasks**:
- [ ] State `bracketEndChar_kvE2_sound_two_prior` (⇒ direction, standalone `have`/lemma) over the
      six bracket-zone order-atom hypotheses + `M, h_UZ, h_SZ, x, t`.
- [ ] `rw [bracketEndChar_kvE2_two_eq]`; apply `kvE2_sepBody_extract` → obtain `epL@x`, `epR@t`,
      `∃ w (x<w<t)`, `ptW@w`, and per-σ `bundleL/bundleR` (obligations (a)+(b)+(d)-inputs pre-landed).
- [ ] Per positive `σ`: `kvE2_sepBundleL/R_parts` → 5-tuple → `kvE_subBracket2V_sound_of_parts`
      (`SubBracket2V.lean:1290`) reconstructs σ's inner realization.
- [ ] Type each depth-1 witness via `P.correct` (`ExistProviders.correct`, PriorInterface:41)
      (obligation (c)).
- [ ] Assemble the outer witness `w` at the `ptW` slot and discharge the depth-2 quant layer
      `∀ sub, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ qnf.2 sub` (obligation (e)).
- [ ] Verify at each `have` with `mcp__lean-lsp__lean_goal`; keep the interior closer PER-SUB
      (avoids failed-closer #1 level mismatch).

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — add ⇒ lemma.

**Verification**:
- Lemma compiles sorry-free; `lean_diagnostic_messages` clean.
- `lean_verify bracketEndChar_kvE2_sound_two_prior` → `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- F1-F7 spot-check: witness bounds from bracket range (not a chain); no `x1 < e_i` literal.

---

### Phase 3: ⇐ completeness direction lemma (left-interior) [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: Cannot build the joint disjunct realization
  `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap
  x t`, which `kvE2_sepBody_holds_iff` (:840, mpr) requires to close the ⇐ direction. The gate
  (`kvE2_sepGate_holds_of_honest` :1134) and the non-emptiness (`kvE2_sepBody_complete` :1531, which
  DOES consume `hL`) compose fine, but the disjunct's `VecEA2.holds` (VecEAFormula:262) unfolds to
  `endpointLeft@x ∧ endpointRight@t ∧ bracket.holds`, and `bracket.holds` is an
  `IntervalPattern.holds` requiring a globally monotone witness sequence over ALL slots in the
  merged per-owner lists `kvE2_sepSlotsL/R qnf` realizing every point type and every segment.
- **What was tried**: Full survey of SharedWitness.lean builders — only extractors exist
  (`kvE2_sepDisjunct_extract` :1807, `_halves` :1906, order-type `kvE2_sepArr'_sound` :2536); no ⇐
  `holds` builder. Confirmed `kvE_subBracket2V_complete` (SubBracket2V:1730) builds only a per-σ
  single-owner sub-bracket, and `bracketEndChar_k1v_complete` (CarrierK1V:1629) only the k=1
  carrier — neither lifts to the joint disjunct. A probe lemma was drafted then removed (kept the
  file sorry-free).
- **Why it's stuck**: The joint multi-owner disjunct bracket-`holds` builder is an **un-landed**
  obligation explicitly deferred by task 334 (`SharedWitness.lean:1954`: "the general multi-owner
  pairwise discharge is the completeness-side Phase-8 obligation"). Building it is a substantial
  dedicated construction, not a composition of landed lemmas.
- **What is needed**: A new construction wiring the general region engine `k1v_sorted_realizationK`
  (SubBracket2V.lean:633) into the `kvE2_sepDisjunct` slot/segment/endpoint layout: map each
  positive owner's honest bundle (`kvE2_sepHonestBundleL`) into a region, run the engine to get a
  monotone interleaved witness sequence, and match it to `kvE2_sepBracketN`'s `IntervalPattern`
  point types + segments, plus discharge `kvE2_sepEpL/EpR` at `x`/`t`. This is a follow-on dispatch
  (comparable in size to CarrierK1V's ~370-line `bracketEndChar_k1v_complete`).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.


**Goal**: Prove the reverse half as a standalone `hL`-guarded auxiliary lemma:
`∃ w, nf_eval_nf M 2 3 …` (+ left-interior `hL`) ⟹ carrier `holds` at `(x,t)`.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_complete_two_prior_leftInterior` (⇐ direction) carrying the
      explicit `hL : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3` hypothesis.
- [ ] From the realization + `x<w<t`, obtain the gate via `kvE2_sepGate_holds_of_honest`.
- [ ] Apply `kvE2_sepBody_complete` (with `hL`) → a present valid disjunct `wo ∈ kvE2_sepArr'`.
- [ ] Build that disjunct's realization at `(x,t)` from `kvE2_sepHonestBundleL/R` +
      `kvE2_sepArr'_sound`.
- [ ] Close via `kvE2_sepBody_holds_iff` (mpr); `rw [bracketEndChar_kvE2_two_eq]` to land on the
      carrier.
- [ ] Verify at each `have` with `lean_goal`.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — add ⇐ lemma.

**Verification**:
- Lemma compiles sorry-free; `lean_diagnostic_messages` clean.
- `lean_verify bracketEndChar_kvE2_complete_two_prior_leftInterior` → axiom-clean, no `sorryAx`.
- `hL` appears as an explicit hypothesis (restriction is not hidden).

---

### Phase 4: Assemble k=2 gate-correctness theorem + faithfulness/scope audit [BLOCKED]

**BLOCKER** (Phase 4): Depends on Phases 2 and 3, both BLOCKED (missing joint multi-owner
disjunct bracket-`holds` builder). Cannot assemble the k=2 gate-correctness theorem without both
directions. Deferred to the same follow-on dispatch. Do NOT use `sorry` or any vacuous placeholder.


**Goal**: Combine the two directions into the delivered left-interior gate-correctness theorem,
confirm axiom-cleanliness and F1-F7 preservation, and record the R-A/R-B scope decisions in the
file.

**Tasks**:
- [ ] State the delivered theorem `bracketEndChar_kvE2_correct_two_prior_leftInterior` : for all
      `qnf` (with the `hL` left-interior guard), `BracketCarrierCorrectVPrior`-shaped iff holds for
      `bracketEndChar_kvE2 atomMap h_surj P` at `k=2` — `constructor` combining Phase 2 (⇒) and
      Phase 3 (⇐), mirroring the landed k≤1 lift pattern (`bracketEndChar_kv_correct_one_prior`).
- [ ] Add a docstring/comment block recording: R-A resolution (left-interior only; unconditional
      k=2 requires task 336 right-interior generalization) and R-B resolution (KampPrior:351 wiring
      is a follow-on, not wired here).
- [ ] Run `lean_verify` on the assembled theorem; confirm `{propext, Classical.choice, Quot.sound}`,
      no `sorryAx`.
- [ ] F1-F7 preservation checklist: no vacuous placeholders (F2 via `_complete`/`_nonvacuous`),
      no open/closed zone-key conflation (F5), no `x1 < e_i` literal (LITMUS NS:437), witness bounds
      from bracket range.
- [ ] Grep-confirm `SharedWitness.lean` is unmodified (carrier INPUT untouched).
- [ ] `lake build` the full `NfMultiAnchorBridge/` target.

**Timing**: 1.25 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — assembled theorem + scope docstring.

**Verification**:
- `lean_verify bracketEndChar_kvE2_correct_two_prior_leftInterior` axiom-clean, no `sorryAx`.
- Full `lake build` green.
- `git status` shows `SharedWitness.lean` unmodified; only `OuterGate.lean` (new) + aggregator changed.
- F1-F7 checklist passes.

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target succeeds after each phase.
- [ ] `mcp__lean-lsp__lean_diagnostic_messages` on `OuterGate.lean` is clean (no errors, no `sorry`).
- [ ] `lean_verify` on all four delivered declarations returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit` tactic anywhere in `OuterGate.lean`.
- [ ] `SharedWitness.lean` and other task-334 carrier files are byte-for-byte unmodified.
- [ ] F1-F7 faithfulness checklist passes (see Phase 4).
- [ ] `bracketEndChar_kvE2_two_eq` is a genuine `rfl`/`unfold` bridge (definitional delegation).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — new file:
  live `bracketEndChar_kvE2` def, `_two_eq` bridge, ⇒/⇐ direction lemmas, assembled left-interior
  gate-correctness theorem, scope docstring.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — aggregator import add.
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/01_outer-gate-assembly.md` (this file).
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/01_outer-gate-assembly-summary.md` (on completion).
- **Follow-on task recommendation** (R-B): a separate task to wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior_leftInterior` into `KampPrior.lean:351` (thread
  `ExistProviders` through `nf_nvar_exist_all_depths`'s `Nat.rec`/`n=1` case).

## Rollback/Contingency

- All work is additive and isolated to `OuterGate.lean` + one aggregator import line. To revert:
  delete `OuterGate.lean` and remove its import from the aggregator; the tree returns to the
  pre-task-335 state with the carrier INPUT untouched.
- If the ⇒ soundness connector (Phase 2) cannot be closed within one agent run, checkpoint the
  green `have`s, commit the partial with the completed direction as a named lemma, and split the
  residual `(e)` quant-layer fold into a follow-on — never commit a bare `sorry` or an
  assumed-`hgate` gate (honest RESCOPE discipline, NS:441-449).
- The `rfl` bridge failing is non-fatal: fall back to `by unfold bracketEndChar_kvE2`; still additive.
