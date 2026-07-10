# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`) — Current Interface

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`, the two-level quant-layer connector that `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter) consumes
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: 334 (COMPLETED — faithful carrier), 337 (COMPLETED — `kvE2_sepBody_holds_of_honest` completeness engine), 342 (COMPLETED — interior-restricted carrier, `hLR` deletion). Also builds on landed 336/338/339/340 assets.
- **Research Inputs**:
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/01_outer-gate-assembly-engine.md (original research; carrier/interface grounding — line numbers superseded)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/13_rxw-faithfulness-audit.md (CONFIRMED — pivot/faithfulness constraints on `.rXW`)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/14_tie-class-semantics-audit.md (CONFIRMED — tie-class disambiguation, primed-order guardrail)
- **Artifacts**: plans/02_outer-gate-assembly-current-interface.md (this file); supersedes plans/01_outer-gate-assembly.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **revision** of plan 01, which was written 2026-07-08 and is now STALE: it references
none of the current interface (zero hits for `kvE2_sepBody_holds_of_honest`,
`kvE2_sepBody_complete_holds'`, `hLR`). Since it was written, three completed tasks changed the
ground under it:

1. **Task 342 deleted the `hLR` interiority hypothesis** from all four completeness theorems.
   `kvE2_sepHonest_hLR_absurd` (`SharedWitness.lean:5738`) machine-certifies that any
   interiority hypothesis on realized types is INCONSISTENT with every honest evaluation — the old
   `hL`/`hLR`-conditional theorems were vacuous as stated. The carrier now indexes owners by the
   interior-restricted `kvE2_sepPosI` (`SharedWitness.lean:211`), so interiority is a construction
   invariant recovered definitionally, never a hypothesis. Non-interior positive owners ride the
   atomic `E[Σ]` endpoint/pivot literals. **Consequence for this plan: there is no `hL`/`hLR`
   guard. Every `_leftInterior` name and every left-interior restriction in plan 01 is deleted. The
   delivered theorems are UNCONDITIONAL.**

2. **Task 337 delivered exactly what 335 consumes**: `kvE2_sepBody_holds_of_honest`
   (`SharedWitness.lean:9262`) — public, sorry-free, axiom-clean `{propext, Classical.choice,
   Quot.sound}`, orchestrator-verified via `#print axioms`. This is the **⇐ completeness engine**
   (honest depth-2 evaluation ⟹ carrier body `.holds`) that plan 01's Phase 3 was BLOCKED on. It is
   a **verified INPUT**: consume it, do not re-prove it, do not weaken it. Its two companions
   `kvE2_sepDisjunct'_holds_of_honest` (SW:9240) and the task-342 completeness statement
   `kvE2_sepBody_complete_holds'` (SW:6166) are already wired underneath it.

3. **Phase 1 already landed.** `bracketEndChar_kvE2` (the first LIVE outer-gate def) and the
   `bracketEndChar_kvE2_two_eq` `rfl` bridge already exist in
   `NfMultiAnchorBridge/OuterGate.lean` (green, axiom-clean, committed by the prior task-335
   dispatch). **The task description's "currently has no live def" caveat is STALE** — verified
   against source: `OuterGate.lean:57-62` defines `bracketEndChar_kvE2`, `OuterGate.lean:68-74`
   proves the `rfl` bridge. This plan preserves Phase 1 as [COMPLETED] and does not re-do it.

**What remains.** The delivered interface is `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2
atomMap h_surj P)` at `k = 2` (`PriorInterface.lean:60`), a full `↔`:

```
(bracketEndChar_kvE2 … qnf).holds M atomMap x t  ↔  ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

- **⇐ (mpr, completeness)**: `∃ w, nf_eval_nf … ⟹ .holds`. Now a **consumption** of
  `kvE2_sepBody_holds_of_honest` — the substantive engine is landed. This is Phase 2.
- **⇒ (mp, soundness)**: `.holds ⟹ ∃ w, nf_eval_nf …`. The **residual engine work**. The extract
  `kvE2_sepBody_extract` (SW:6356) yields the per-σ bundles from `.holds`, but no landed theorem
  reassembles them into `nf_eval_nf M 2 3`. Verified: the entire `_of_honest` family (SW:7671–9262)
  runs the OTHER direction; there is no `_of_holds` / soundness reassembly on disk. This is Phases 3–4.
- **Assembly** into the full iff + axiom-clean audit + F1-F7/LITMUS audit + docstring update is Phase 5.

The work is **purely additive**: everything lands in the existing `OuterGate.lean` sibling file
(the aggregator import already exists, `NfMultiAnchorBridge.lean:39`). The task-334/336/337/338/339/340/342
carrier and its lemmas are **verified INPUTS**, only applied, never edited or re-proved.

### Research Integration (newly integrated since plan 01)

- **337 report 13 (`.rXW` faithfulness audit, CONFIRMED)**: the `.rXW` LEFT-list slot for a
  right-interior owner is faithful (Rabinovich Figure 1 pivot split, md:297-299); its epsilon bound
  was strengthened to `x < v ∧ v < w ∧ χ` (landed in 337 Phase 2). Consequence for 335: the pivot
  bound `last(usL) < w < first(usR)` is a **landed** value fact — the soundness reassembly and the
  completeness engine both rely on it, and it must not be re-litigated here. LITMUS-clean (`v < w`
  is env-anchored, not an `x1 < e_i` literal).
- **337 report 14 (tie-class semantics audit, CONFIRMED)**: the faithful merge key is the
  value-only rank (C) `kvE2_sepSlotHonestVIdx` (SW:5831), routed through the carrier merge key (A)
  by the proved bridge `kvE2_sepSlotGIdx_honestOrder'` (SW:7868). **The only correct order is the
  PRIMED `kvE2_sepHonestOrder'` (SW:5974)**; `kvE2_sepModelOrder` (SW:1476) and the unprimed
  `kvE2_sepHonestOrder` (SW:3891) carry injective payloads that force singleton classes and make
  grouped obligations FALSE under genuine ties. `kvE2_sepBody_holds_of_honest` already consumes the
  primed order internally; any soundness-side re-derivation that touches ordering MUST also use the
  primed order.

### Prior Plan Reference

Plan 01 (`plans/01_outer-gate-assembly.md`) is the immediate predecessor. Its Phase 1 is done and
carried forward. Its Phases 2–4 were BLOCKED on "the joint multi-owner disjunct bracket-`holds`
builder" — that builder is precisely what task 337 delivered (`kvE2_sepBody_holds_of_honest`), so the
completeness block is DISSOLVED. Its `hL`/left-interior scope is DELETED (task 342). Its soundness
block (the depth-2 reassembly) is re-scoped here as real, now-attemptable engine work because the
component lemmas (`kvE2_sepBody_extract`, `kvE_subBracket2V_sound_of_parts`, the O4 hgate core,
`ExistProviders.correct`) are all landed.

## Goals & Non-Goals

**Goals**:
- Prove **⇐ completeness** `bracketEndChar_kvE2_complete_two_prior` by consuming
  `kvE2_sepBody_holds_of_honest` (SW:9262) at the standard instantiation, closed through
  `bracketEndChar_kvE2_two_eq`.
- Prove **⇒ soundness** `bracketEndChar_kvE2_sound_two_prior`: `.holds ⟹ ∃ w, nf_eval_nf M 2 3 …`,
  reassembling the depth-2 evaluation from `kvE2_sepBody_extract`'s per-σ bundles via
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1290), the O4 hgate core (SW:6398+),
  `ExistProviders.correct` (PriorInterface:41) witness typing, and a depth-2 quant-layer fold.
- Assemble both directions into the **UNCONDITIONAL** `k = 2` gate-correctness theorem
  `bracketEndChar_kvE2_correct_two_prior : BracketCarrierCorrectVPrior atomMap
  (bracketEndChar_kvE2 atomMap h_surj P)`, mirroring the landed k≤1 lift pattern
  (`bracketEndChar_kv_correct_one_prior`, PriorInterface:95).
- Update the `OuterGate.lean` scope docstring: drop the `_leftInterior` suffix from delivered items
  4/5 (stale relative to the R-A/task-342 note already in the same file), record the final decls.
- Preserve F1–F7 and the LITMUS (`NavigatedSpine:437`): no `x1 < e_i` relative-position literal on
  any live path; witness bounds come from the bracket range, never a chain.

**Non-Goals**:
- **Do NOT re-prove or weaken** `kvE2_sepBody_holds_of_honest` or any task-334/336/337/338/339/340/342
  carrier input in `SharedWitness.lean` / `SubBracket2V.lean` (verified INPUTS).
- **Do NOT reintroduce any interiority hypothesis** (`hL`, `hLR`, or a left/right-interior guard on
  realized types). Such a hypothesis is refuted by `kvE2_sepHonest_hLR_absurd` (SW:5738); any phase
  that adds one is wrong by construction.
- **Do NOT wire the gate into `KampPrior.lean:351`** (threading `ExistProviders` through
  `nf_nvar_exist_all_depths`'s `Nat.rec` / `n=1` case). This is R-B, a DISTINCT DOWNSTREAM task, out
  of scope here (see Scope Decisions). `KampPrior.lean` currently has real `sorry`s at its `n=1` and
  `n+2` cases (verified) — those belong to R-B, NOT this task, and are not in `SharedWitness.lean`.
- No bare `sorry`/`admit`; no vacuous close (`False.elim`, `(kvE2_sepHonest_hLR_absurd …).elim`, or
  `def X := True`); no gate-modulo-assumed-`hgate`.

### Scope Decisions (resolved)

- **R-A (⇐ generality) → UNCONDITIONAL (task 342 update).** `kvE2_sepBody_complete_holds'` (SW:6166)
  is unconditional; owners are indexed by the interior-restricted `kvE2_sepPosI`, so interiority is a
  construction invariant, not a hypothesis. The historical `hL`/`hLR` guards are GONE. The delivered
  theorems carry NO interiority hypothesis.
- **R-B (KampPrior wiring) → DISTINCT DOWNSTREAM TASK, OUT OF SCOPE.** The gate is NOT wired into
  `KampPrior.lean:351`. Verified: `KampPrior.lean` does not reference `bracketEndChar_kvE2` or
  `BracketCarrierCorrectVPrior` (grep-0). Wiring means threading `ExistProviders` through
  `nf_nvar_exist_all_depths`'s `Nat.rec` / `n=1` case in a different file with its own verification —
  a separate one-agent-run unit of work. This plan flags it for a follow-on task and does not touch
  `KampPrior.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The depth-2 quant-layer fold (Phase 4, obligation (e)) is the old Phase-2 blocker; it may reveal a genuinely un-landed connector | H | M | Isolate it in its own phase; build it as standalone `have`s verified with `lean_goal` at each step. If a genuine un-landed obligation surfaces, checkpoint the green `have`s, mark the phase [BLOCKED] with a grounded blocker (goal state + what is missing), and STOP — never vacuous-close. The extract + `sound_of_parts` + O4 hgate core + `P.correct` are all landed, so the residual is the fold glue, not a full engine. |
| Accidentally editing a verified carrier INPUT (`SharedWitness.lean` / `SubBracket2V.lean`) | H | L | All new code lives in `OuterGate.lean`; inputs are only applied, never restated. A `git status` gate in Phase 5 confirms `SharedWitness.lean`/`SubBracket2V.lean` are unmodified. If a phase concludes a landed decl MUST change, STOP and flag for orchestrator re-authorization (do not assume permission — task 337 needed exactly one such authorization for three `.rXW` sites, granted only after a literature audit). |
| Wiring the soundness re-derivation to the wrong weak order (`kvE2_sepModelOrder` SW:1476 or unprimed `kvE2_sepHonestOrder` SW:3891) — injective payloads force singleton classes and make grouped obligations FALSE under ties | H | M | Guardrail (337 report 14 Q3/Q5): any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only. `kvE2_sepBody_holds_of_honest` already uses it internally; the extract path (`kvE2_sepBody_extract`) is order-agnostic (consumes `.holds` structurally). Add a checklist item. |
| `hcb`/`hck` char-formula bridges harder to build than expected | M | L | `hcb` = `nf_depth0_char_formula_correct` (KampTranslation:141) + `diagDup_eval_zero` (pattern landed at Base.lean:65). `hck` = `ExistProviders.correct` at `n=0`, `k=1` with the `Fin 0` env collapse (`insertEnv` on empty env reduces to `fun _ => u`); `h_UZ`/`h_SZ` are supplied by `BracketCarrierCorrectVPrior`. |
| Vacuous close typechecks and builds green but proves nothing | H | M | Explicit testing-checklist item: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`, `:= True`. A vacuous close is a FAILURE even though it is green. |
| Soundness phase overflows one agent run | M | M | Split soundness into Phase 3 (per-σ inner realizations) and Phase 4 (depth-2 fold + outer atom layer), each ~100–500 lines, committed at each green milestone (337 discipline). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1 (already landed) | -- |
| 1 | 2 | 1 |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 2, 4 |

Phase 2 (completeness) and Phase 3 (soundness part A) are independent given Phase 1 and may run in
either order; Phase 5 needs both directions closed.

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Goal**: Introduce the first live `bracketEndChar_kvE2` definition delegating to the faithful
carrier, plus the `rfl` bridge, in the isolated `OuterGate.lean` sibling wired into the aggregator.

**Delivered** (verified against source, already on disk and green):
- `bracketEndChar_kvE2` (`OuterGate.lean:57-62`): `noncomputable def` producing
  `BracketEndCharCarrierV sig 2`, delegating to `kvE2_sepBody (nf_depth0_char_formula atomMap
  h_surj) (fun χ => P.existF 0 χ)`.
- `bracketEndChar_kvE2_two_eq` (`OuterGate.lean:68-74`): the `rfl` bridge exposing `kvE2_sepBody`.
- Aggregator import (`NfMultiAnchorBridge.lean:39`).

**Status note**: This phase was completed by the prior task-335 dispatch. It is preserved as-is; the
new work begins at Phase 2. This supersedes the stale "no live def" caveat in the task description.

**Verification** (already satisfied): green build; axiom-clean `{propext, Classical.choice,
Quot.sound}`, no `sorryAx`.

---

### Phase 2: ⇐ completeness half — consume `kvE2_sepBody_holds_of_honest` [NOT STARTED]

**Goal**: Prove the reverse (mpr) direction of the gate as a standalone lemma:
`∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf  ⟹  (bracketEndChar_kvE2 atomMap
h_surj P qnf).holds M atomMap x t`, over the six `BracketCarrierCorrectVPrior` order hypotheses +
`h_UZ`/`h_SZ` + `x t`. This is a CONSUMPTION of the landed completeness engine — no new engine.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_complete_two_prior` (UNCONDITIONAL — no `hL`/`hLR`).
- [ ] Intro the witness: `obtain ⟨w, h⟩` with `h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ =>
      t))) qnf`.
- [ ] Derive `hxw : x < w` and `hwt : w < t` from `h`'s atom-order layer under the six interface
      order hypotheses (env `[w, x, t]`; use `nf_eval_nf`'s atom-layer projection).
- [ ] Derive the gate `hg : kvE2_sepGate qnf` from the interface order hypotheses (the gate,
      SW:1238, is stated over `qnf`'s off-fiber / consistency conditions; confirm with `lean_goal`
      whether it is definitional from the hyps or needs a short bridge).
- [ ] Build `hcb : ∀ χ u, temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ` via `nf_depth0_char_formula_correct` (KampTranslation:141) +
      `diagDup_eval_zero` (pattern at Base.lean:65).
- [ ] Build `hck : ∀ χ u, temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M 1 1 (fun _ => u)
      χ` via `P.correct 0 χ M h_UZ h_SZ u` + the `Fin 0` env collapse (`insertEnv` on empty).
- [ ] Apply `kvE2_sepBody_holds_of_honest (nf_depth0_char_formula …) (fun χ => P.existF 0 χ) qnf hg
      M atomMap w x t hxw hwt h hcb hck` to get `(kvE2_sepBody …).holds M atomMap x t`.
- [ ] `rw [bracketEndChar_kvE2_two_eq]` to land on the live carrier.
- [ ] Verify each `have` with `lean_goal`.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**: `OuterGate.lean` (add ⇐ lemma).

**Verification**:
- Lemma compiles sorry-free; no interiority hypothesis in its signature.
- `#print axioms` (via `lake env lean`) → `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- Uses `kvE2_sepBody_holds_of_honest` unmodified; `SharedWitness.lean` untouched (`git status`).

---

### Phase 3: ⇒ soundness, part A — per-σ inner realizations [NOT STARTED]

**Goal**: From the carrier `.holds`, extract the bundles and reconstruct, for every positive owner
`σ`, its depth-1 inner realization at the shared witness `w` — the inputs the depth-2 quant fold
(Phase 4) folds. Standalone `have`s, no top-level lemma yet (or a private helper).

**Tasks**:
- [ ] From `(bracketEndChar_kvE2 …).holds M atomMap x t`, `rw [bracketEndChar_kvE2_two_eq]`, then
      apply `kvE2_sepBody_extract` (SW:6356) → `epL@x`, `epR@t`, `∃ w (x<w<t)`, `ptW@w`, and per-σ
      `kvE2_sepBundleL`/`kvE2_sepBundleR` for positive owners of each zone. (The `hpairL`/`hpairR`/`hnd`
      side-conditions of `_extract` are discharged from landed sortedness/nodup lemmas — locate them
      with `lean_local_search`; do NOT re-prove.)
- [ ] Per positive `σ`: assemble the `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1290) input
      5-tuple from the bundle at the standard instantiation (`charBase = nf_depth0_char_formula …`).
- [ ] Derive the per-σ `hgate` from the O4 hgate core (SW:6398+, `kvE2_sepHgate_offFiber` SW:6526,
      `kvE2_sepHgate_innerNine` SW:6537) — the derivable core; do NOT assume `hgate`.
- [ ] Apply `kvE_subBracket2V_sound_of_parts` to obtain σ's inner depth-1 realization
      `(kvE_subBracket2V …).holds M atomMap …` / the `nf_eval_nf M 1 4 [x1,w,x,t] σ` witness.
- [ ] Type each depth-1 witness via `ExistProviders.correct` (PriorInterface:41), obligation (c).
- [ ] Verify each `have` with `lean_goal`; keep the interior closer PER-SUB (avoids the historical
      failed-closer level mismatch `NormalForm sig 1 (3+1)` vs `1 4`).

**Timing**: 1.75 hours

**Depends on**: 1

**Files to modify**: `OuterGate.lean` (add soundness part-A helper `have`s / private lemma).

**Verification**:
- Each per-σ inner realization compiles sorry-free; `lean_goal` clean at each step.
- Witness bounds read from the bracket range / slot indices (Def 3.1 monotone enumeration), NOT a
  chain — no `x1 < e_i` literal (LITMUS NS:437).
- Any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` only.
- `SharedWitness.lean`/`SubBracket2V.lean` untouched.

---

### Phase 4: ⇒ soundness, part B — depth-2 quant-layer fold [NOT STARTED]

**Goal**: Fold the per-σ inner realizations (Phase 3) plus the outer atom layer over `[w, x, t]`
into the full `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`, delivering the
soundness lemma `bracketEndChar_kvE2_sound_two_prior`. This is the substantive residual (old plan
01 Phase-2 blocker) — the pieces are now landed but the fold glue is un-attempted.

**Tasks**:
- [ ] Instantiate the outer witness at the `ptW` slot `w` (with `x < w < t` from the bracket's OWN
      range — FM-x1t, not a chain).
- [ ] Discharge the outer atom layer of `nf_eval_nf M 2 3` over `[w, x, t]` from `epL@x`/`epR@t`/`ptW@w`
      and the six interface order hypotheses.
- [ ] Discharge the depth-2 quant layer `∀ sub, (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w
      (Fin.cons x (fun _ => t)))) sub) ↔ qnf.2 sub = true` (BOTH directions, all subs):
  - `⟸`: `qnf.2 sub = true` ⟹ `sub` is a positive owner ⟹ use its Phase-3 inner realization.
  - `⟹`: a point realizing `sub` forces `qnf.2 sub = true` — via the gate `hg`'s off-fiber /
        consistency conditions (`kvE2_sepGate`, SW:1238) closing the false-owner cases.
- [ ] Assemble into `∃ w, nf_eval_nf M 2 3 …`; state and close `bracketEndChar_kvE2_sound_two_prior`.
- [ ] Verify each `have` with `lean_goal`.
- [ ] **If a genuine un-landed obligation surfaces in the quant fold**: checkpoint the green `have`s,
      commit them, mark THIS phase [BLOCKED] with the exact goal state + what landed lemma is
      missing, and STOP. Do NOT vacuous-close, do NOT assume `hgate`, do NOT add an interiority
      hypothesis.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**: `OuterGate.lean` (add ⇒ soundness lemma).

**Verification**:
- `bracketEndChar_kvE2_sound_two_prior` compiles sorry-free; no interiority hypothesis.
- `#print axioms` (via `lake env lean`) → `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- No `x1 < e_i` literal; witness bounds from bracket range. Primed order only.

---

### Phase 5: Assemble unconditional `k = 2` gate-correctness + axiom/faithfulness audit [NOT STARTED]

**Goal**: Combine both directions into `bracketEndChar_kvE2_correct_two_prior :
BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)`, confirm axiom-cleanliness
and F1–F7/LITMUS preservation, update the `OuterGate.lean` scope docstring.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_correct_two_prior` (UNCONDITIONAL): unfold `BracketCarrierCorrectVPrior`,
      `intro` the six order hypotheses + `h_UZ`/`h_SZ` + `x t`, then `constructor` combining Phase 4
      (⇒) and Phase 2 (⇐), mirroring `bracketEndChar_kv_correct_one_prior` (PriorInterface:95).
- [ ] Update the `OuterGate.lean` header docstring: drop the `_leftInterior` suffix from delivered
      items 4/5 (now stale vs. the R-A/task-342 note already in the same file); record final decl
      names and that R-A is unconditional, R-B is out of scope.
- [ ] Run `#print axioms bracketEndChar_kvE2_correct_two_prior` via `lake env lean` (NOT `lean_verify`
      — it is UNRELIABLE on `SharedWitness.lean`, returning contradictory `sorryAx` from stale LSP
      state after an external `lake build`). Confirm `{propext, Classical.choice, Quot.sound}`.
- [ ] F1–F7 + LITMUS preservation checklist (see Testing & Validation).
- [ ] `git status` confirms only `OuterGate.lean` changed; `SharedWitness.lean`/`SubBracket2V.lean`
      byte-for-byte unmodified.
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate`, then full
      `lake build`.

**Timing**: 0.75 hours

**Depends on**: 2, 4

**Files to modify**: `OuterGate.lean` (assembled theorem + docstring update).

**Verification**:
- `#print axioms bracketEndChar_kvE2_correct_two_prior` axiom-clean, no `sorryAx`.
- Full `lake build` green.
- No interiority hypothesis anywhere; no vacuous close.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate` succeeds after
      each phase; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)**: run each delivered declaration through
      `lake env lean` with `#print axioms <name>`; every one returns `{propext, Classical.choice,
      Quot.sound}` with no `sorryAx`. `lean_verify` is UNRELIABLE on `SharedWitness.lean` (stale LSP
      `sorryAx` after external `lake build`) — do not trust it.
- [ ] **No vacuous close**: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`,
      `:= True`, `:= trivial`. A vacuous close typechecks and builds green but proves NOTHING — it is
      a FAILURE, not a pass.
- [ ] **No interiority hypothesis**: no `hL`/`hLR`/left-or-right-interior guard on realized types in
      any delivered signature (refuted by `kvE2_sepHonest_hLR_absurd`, SW:5738).
- [ ] **Primed order only**: no live path consumes `kvE2_sepModelOrder` (SW:1476) or the unprimed
      `kvE2_sepHonestOrder` (SW:3891); ordering rides `kvE2_sepHonestOrder'` (SW:5974).
- [ ] **LITMUS (NavigatedSpine:437)**: no `x1 < e_i` relative-position literal on any live path;
      witness bounds come from the bracket range, never a chain.
- [ ] **F1–F7**: non-vacuous realization (F2/F3 via the landed completeness/soundness engines); no
      open/closed zone-key conflation (F5); no model literal buried (F4).
- [ ] **Additive**: `SharedWitness.lean`, `SubBracket2V.lean`, and all other 334/336/337/338/339/340/342
      files are byte-for-byte unmodified (`git status`). If any landed decl MUST change, STOP and
      flag for orchestrator re-authorization — do NOT edit and do NOT assume permission.
- [ ] **SW sorry count unchanged**: `SharedWitness.lean` has exactly 7 `sorry` string occurrences,
      ALL inside prose comments (zero real sorries). That count MUST NOT rise (this task does not
      edit `SharedWitness.lean` at all).
- [ ] `bracketEndChar_kvE2_two_eq` remains a genuine `rfl` bridge (unchanged from Phase 1).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — extended:
  ⇐ completeness lemma (`bracketEndChar_kvE2_complete_two_prior`), ⇒ soundness lemmas
  (`bracketEndChar_kvE2_sound_two_prior` + part-A helper), assembled unconditional gate-correctness
  theorem (`bracketEndChar_kvE2_correct_two_prior`), updated scope docstring. (Phase 1 def + `rfl`
  bridge already present.)
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/02_outer-gate-assembly-current-interface.md`
  (this file).
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/02_outer-gate-assembly-summary.md` (on
  completion).
- **Follow-on task recommendation (R-B)**: a separate lean4 task to wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior` into `KampPrior.lean:351` (thread `ExistProviders` through
  `nf_nvar_exist_all_depths`'s `Nat.rec` / `n=1` case, discharging the current `sorry`s there).

## Rollback/Contingency

- All work is additive and isolated to `OuterGate.lean`. To revert new phases: `git checkout`
  `OuterGate.lean` to its Phase-1 state; the tree returns to the current landed state with all
  carrier INPUTS untouched.
- If the depth-2 quant fold (Phase 4) cannot be closed within one agent run, checkpoint the green
  `have`s, commit the partial with the completed direction (⇐ from Phase 2) as a named lemma, mark
  Phase 4 [BLOCKED] with the grounded blocker (goal state + missing landed lemma), and split the
  residual fold into a follow-on. Never commit a bare `sorry`, an assumed-`hgate`, a vacuous close,
  or an interiority hypothesis.
- If any phase concludes a landed 334/336/337/338/339/340/342 declaration must change, STOP: this
  exceeds the additive mandate and requires explicit orchestrator re-authorization (as task 337's
  `.rXW` edit did — granted only after a literature audit). Do not edit and do not assume permission.
