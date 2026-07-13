# Implementation Plan: Task #354 — Nested 2-Endpoint Bracket Re-Anchoring Converter

- **Task**: 354 - Build the FAITHFUL nested 2-endpoint bracket re-anchoring converter (Rabinovich 2014 Lemma 5.3 recursion)
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Dependencies**: None (parent task 353; closes task 352's blocked `_complete` halves)
- **Research Inputs**: reports/01_nested-reanchoring-converter.md (GO — conditional-provable)
- **Artifacts**: plans/01_nested-reanchoring-converter.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build the reverse-direction exterior converter that closes task 352's blocked `kvE_extNegFut_complete` / `kvE_extNegPast_complete` and discharges task 353's DoD, in two NEW sibling modules `ExteriorConverterK.lean` and `ExteriorConverterPastK.lean` under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`. The exterior `_complete` is the REVERSE of the already-green `_sound` (`ExteriorNegationK.lean:532`), assembled on the already-landed depth-`k` chain destructor `kvE_futChainDestructG` (`ExteriorNegationK.lean:293`, the Cor 5.4 `Oₙ` re-anchoring engine), consuming a CARRIED arity-5 pinned-env realization bundle (`hreal`) as a hypothesis. The F2 env-transfer wall is SIDESTEPPED by carrying that bundle — NOT overcome; do NOT re-attempt the flat `extF4` (task 353 refuted) nor an additive general-model transfer lemma (task 352 refuted). Definition of done: both `_complete` theorems green, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`, all frozen files byte-identical (`git diff` empty), full `lake build` green.

### Research Integration

Built directly on reports/01_nested-reanchoring-converter.md (verdict GO, conditional-provable). Key findings honored:
- Well-posedness is machine-confirmed (scratch probe `ConverterProbe354.lean` built GREEN `[1023/1023]` sorry-only, then removed; tree clean). `x1` is QUANTIFIED in the reconstruction, never pinned under `temporal_truth`.
- KEY SIMPLIFICATION: the exterior `_complete` does NOT consume the arity-3 bracket carrier `bracketEndChar_kvE` (DEAD/Boneyard). It is self-contained on the already-green chain infra `kvE_futChainG` / `BuildG` / `DestructG` — the depth-`k` lift of `kvE2_futChain`. This bypasses the largest piece the task framing assumed ("lift the entire `bracketEndChar_kvE2` assembly").
- Recursion is externalized: Lemma 5.3's length-`n` recursion is already green (chain infra); depth-`k` is carried by the `ExistProviders` bundle `P` (KampPrior `Nat.rec`, task-309). Task 354 adds only the reverse-direction assembly + bundle reconciliation.
- Phase 3 is the sole conditional (fiber-backward / `x1`-saturation); it lands sorry-free EITHER way (internal saturation via `nf_eval_unique` + `semantic_prior_UZ`, OR the residue is carried as one named outer-recursion hypothesis — the k=2 `hexclExt` pattern).

### Prior Plan Reference

No prior plan. Effort calibration and risk awareness inherited from the task-352 report 03 (F2 NO-GO) and task-353 report 01 (flat `extF4` NO-GO), both consumed by the research report as refuted approaches to avoid.

### Roadmap Alignment

No `roadmap_path` provided in delegation context; ROADMAP.md not consulted. This task advances the Kamp-theorem completeness direction (`kamp_theorem_formalization` topic) by closing the exterior negation `_complete` halves.

## Goals & Non-Goals

**Goals**:
- Land `kvE_extNegFut_complete` (Future) green, sorry-free, as the reverse of `kvE_extNegFut_sound`, consuming `kvE_futChainDestructG` + carried `hreal` bundle.
- Land `kvE_extNegPast_complete` (Past) green via the `semantic_prior_SZ` dual, mirroring the Future construction.
- Provide the new helper lemmas at their research-proposed signatures: `kvE_futReal_of_bundle`, `kvE_futEnd_forces_atom`, `kvE_futFiber_backward`.
- Reconcile the `hreal` bundle shape with the task-349 / `KampPrior:351` provider-discharge interface; optionally fold in the Option B determinacy reader.
- Axiom-clean (`[propext, Classical.choice, Quot.sound]`), frozen-files-clean, full `lake build` green.

**Non-Goals**:
- Do NOT re-attempt the flat arity-5 `extF4` converter (task 353 permanently refuted; ill-posed under `temporal_truth`).
- Do NOT add an additive general-model realizability transfer lemma (task 352 machine-refuted F2).
- Do NOT edit any frozen file. Do NOT consume the DEAD Boneyard arity-3 carrier `bracketEndChar_kvE`.
- Do NOT discharge `hreal` inside these modules (F2); it is carried and discharged one level up.
- Do NOT land any `sorry`, vacuous, or placeholder def; if a sub-piece cannot close green, escalate to BLOCKED (Phase 3 has a defined carried-residue branch instead).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3 `x1`-saturation under-determines σ's atom layer (env-free arity-1 profile does NOT generalize to `k≥1`, task 352 report 03 Del 2) | H | M | Phase 3 starts with an LSP probe; if `nf_eval_unique` under-determines the atom layer, add ONE named carried residue binder (the k=2 `hexclExt` pattern). Both branches land sorry-free. |
| Accidental edit to a frozen file (target `_complete` conceptually "belongs" beside `kvE_extNegPast_*` in the frozen `ExteriorNegationPastK.lean`) | H | L | Build Past `_complete` in the NEW `ExteriorConverterPastK.lean` (importing `ExteriorNegationPastK`), leaving the frozen file byte-identical. `git diff` gate on all 10 frozen files at every phase commit. |
| Bundle-shape drift between `hreal` (arity-5 `[v,x1,w,x,t]`) and the task-349 provider interface | M | M | Phase 5 reconciles against the `KampPrior:351` discharge interface and task-352 `hbelowFib`/`hexclExt` conventions before the final audit. |
| A helper closes locally but a `sorry` leaks into a downstream decl | H | L | Per-phase `lean_verify` axiom check + `lake build` green gate on the touched modules; no phase commit without a clean axiom set on the phase's new decls. |
| Import closure incomplete in new modules | M | L | Both new modules import `ExteriorNegationK` / `ExteriorNegationPastK` respectively; the research probe confirmed the full transitive closure (`[1023/1023]`) is available to a sibling. |

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

Phases within the same wave can execute in parallel. This plan is fully sequential: both new modules are shared territory across phases, so phases cannot be parallelized. Each phase is sized to one implementation dispatch.

---

### Phase 1: Scaffold + well-posed statements [COMPLETED]

**Goal**: Create the two new modules with correct imports/namespace/opens, and land the well-posed target statements with the reconstruction skeleton (probe-confirmed well-posed).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorConverterK.lean`: `import` the `ExteriorNegationK` clause module, set namespace + `open`s to match the k=2 assembly conventions.
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorConverterPastK.lean`: `import` `ExteriorNegationPastK`.
- [ ] State `kvE_extNegFut_complete` with the carried arity-5 `hreal` bundle, verbatim to the research Deliverable 1 signature: hypotheses `(P : ExistProviders sig atomMap k) … (σ : NormalForm sig (k+1) 4) (w x t) (hxw : x < w) (hwt : w < t)`, the `hreal : ∀ x1, t < x1 → ∀ s, σ.2 s = true → ∃ v, nf_eval_nf M k 5 (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s` bundle, the `hcl : ∀ x1, t < x1 → ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ` hypothesis, concluding `temporal_truth M atomMap t (kvE_extNegFut P σ)`.
- [ ] State `kvE_extNegPast_complete` (Past mirror) in `ExteriorConverterPastK.lean`.
- [ ] Land the reconstruction skeleton in the Future statement: `intro`, `admissible σ` (via `kvE_futRealizer_admissible`), `formula_disjList_iff` + `if_pos` peel, apply `kvE_futChainDestructG`. Placeholder-free: any not-yet-proved leaf is a named `have` with an explicit `sorry` ONLY as a transient during this dispatch, resolved before commit — OR left as an explicit downstream phase reference (do not commit a `sorry`).

**Timing**: ~1 hour (size S).

**Depends on**: none

**Files to modify**:
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` (NEW) — Future scaffold + `kvE_extNegFut_complete` statement + skeleton.
- `…/NfMultiAnchorBridge/ExteriorConverterPastK.lean` (NEW) — Past scaffold + `kvE_extNegPast_complete` statement.

**Verification**:
- `lake build` green on the two new modules (statements + skeleton type-check; probe already machine-confirmed well-posedness).
- `git diff` EMPTY on all 10 frozen files.
- No `sorry` committed: the phase terminus is the well-posed statements compiling; if the body cannot yet close, the statement is admitted only as a signature stub whose proof obligation is explicitly carried to Phase 2 (documented, not a bare `sorry`).

---

### Phase 2: Future `_complete` — atom-layer + fiber-forward [COMPLETED]

**Goal**: Complete the forward (producer) half of the Future reconstruction: reassemble `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` via `nf_eval_nfk_iff_efold`, feeding the carried `hreal` bundle into the per-gap-item occurrences.

**Tasks**:
- [ ] Prove helper `kvE_futReal_of_bundle` (Phase-2 adapter): route the carried `hreal` bundle into the per-gap-item occurrence shape `kvE_futChainDestructG` reconstruction needs — pin the `∃env` channel of `kvE_futItemShift_correct` (`ExteriorNegationK.lean:442`) to `[x1,w,x,t]`.
- [ ] Assemble the `nf_eval_nfk_iff_efold` (`NfEFold.lean:627`) reconstruction: (a) the atom layer at `[x1,w,x,t]`; (b) the per-sub fiber biconditional — forward direction `σ.2 s → ∃ v at [v,x1,w,x,t] s` supplied by `kvE_futReal_of_bundle`.
- [ ] Discharge admissibility + the `kvE_futPos` peel end-to-end for the forward direction.
- [ ] Consume UNCHANGED: `nf_eval_nfk_iff_efold`, `kvE_futItemShift_correct`, `kvE_futChainDestructG`, and the `hreal` bundle.

**Timing**: ~2 hours (size M-L).

**Depends on**: 1

**Files to modify**:
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` — `kvE_futReal_of_bundle` + forward-half body of `kvE_extNegFut_complete`.

**Verification**:
- `lake build` green on `ExteriorConverterK.lean`; forward half closes (fiber-backward may remain a named `have` carried to Phase 3).
- `lean_verify` axiom check on `kvE_futReal_of_bundle`: axioms ⊆ `[propext, Classical.choice, Quot.sound]`.
- `git diff` EMPTY on all frozen files.

---

### Phase 3: Future fiber-backward + `x1`-saturation [COMPLETED] — SOLE CONDITIONAL — BRANCH B FIRED

**Phase 3 probe outcome (Branch B — carried residue)**: The fiber-backward obligation
`(∃ v, nf_eval M k 5 [v,x1,w,x,t] sub) → σ.2 sub = true` is provably NOT derivable in-module. An
unrecorded-but-realizable on-fiber sub (`σ.2 sub = false` yet realizable at the reconstructed
anchor) would break the fold biconditional (`nf_eval_nfk_iff_efold`) while leaving the recorded
gap chain intact — so the bare converse of `kvE_extNegFut_sound` is FALSE. This forces Branch B:
the exterior-anchor saturation is carried as ONE named hypothesis `hsat` (the depth-`k` `hexclExt`
analog, env-dependent at arity 5 per task 352 report 03 Deliverable 2), discharged one level up by
the outer recursion / task-349 provider. Phase 4 (Past) MUST mirror Branch B.

Deviations from the proposed helpers:
- `kvE_futEnd_forces_atom` (risky saturation route) *(deviation: altered — superseded by the
  provable `kvE_futAtom_of_bundle`, which recovers σ's atom layer at `[x1,w,x,t]` by routing ONE
  bit-true sub through the carried `hreal` bundle + `nf_eval_nf0_cons_factor`, no env-free
  saturation needed; a reached endpoint forces the self-zone content nonempty ⇒ a bit-true sub
  always exists)*.
- `kvE_futFiber_backward` *(deviation: altered — folded into the carried `hsat` residue rather
  than proved in-module, per Branch B)*.
- `kvE_futReal_of_bundle` (Phase 2 adapter) *(deviation: skipped — the `hreal` bundle feeds the
  fold biconditional's `←` direction directly; no separate per-gap-item adapter was needed)*.

**Goal**: Close the fiber-backward obligation `(∃ v, nf_eval M k 5 [v,x1,w,x,t] s) → σ.2 s = true`, requiring the reconstructed exterior anchor `x1` to be saturated. Land sorry-free via EITHER the internal-saturation branch OR the carried-residue branch.

**Tasks**:
- [ ] **FIRST STEP — LSP probe** (mandatory): attempt `kvE_futEnd_forces_atom` via `nf_eval_unique`. Signature target: `(hend : temporal_truth M atomMap x1 (kvE_futEnd P σ)) (htx1 : t < x1) (hxw …) (hwt …) → nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1`. Use `lean_multi_attempt` / `lean_goal` to determine whether the endpoint description `kvE_futEnd` constrains EVERY bit of σ's atom layer at `x1`, or only the realized fiber content.
- [ ] **Branch A (internal saturation, full GO)** — if the probe closes: prove `kvE_futEnd_forces_atom` via `nf_eval_unique M k` at the reconstructed characteristic (mirror the already-green backward half of `kvE_subBit_iff` at `ExteriorBracketK.lean:345` and `kvE_fiberZoneList_realized` at `:496`), refine `x1` to the first such point via `semantic_prior_UZ` (infimum, Lemma 5.3 Case 2), then prove `kvE_futFiber_backward` `(∃ v, nf_eval M k 5 [v,x1,w,x,t] s) → σ.2 s = true` via `nf_eval_unique M k 5`. Complete `kvE_extNegFut_complete`.
- [ ] **Branch B (carried residue, GO-with-carried-residue)** — if the probe under-determines the atom layer: add ONE named outer-recursion hypothesis binder to `kvE_extNegFut_complete` (the k=2 `hexclExt` analog), documenting it as an explicit outer-recursion obligation (NOT debt, NOT a `sorry`). Close the remaining body against that binder. Update the Phase 1 statement signature accordingly and note the binder in the summary.
- [ ] Record in the phase notes which branch fired and why (probe outcome), so Phase 4 mirrors the SAME branch.
- [ ] Consume UNCHANGED: `nf_eval_unique` (`NormalForm.lean:245`), `semantic_prior_UZ` (`PriorDefs.lean:22`), `kvE_subBit_iff` (`ExteriorBracketK.lean:314` — NOT ExteriorFiberK).

**Timing**: ~2 hours (size M).

**Depends on**: 2

**Files to modify**:
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` — `kvE_futEnd_forces_atom`, `kvE_futFiber_backward`, completion of `kvE_extNegFut_complete` (with carried binder if Branch B).

**Verification**:
- `lake build` green: `kvE_extNegFut_complete` fully closed (Branch A) or closed against the named carried binder (Branch B).
- `lean_verify` on `kvE_extNegFut_complete`, `kvE_futEnd_forces_atom`, `kvE_futFiber_backward`: axioms ⊆ `[propext, Classical.choice, Quot.sound]`; ZERO `sorry`.
- `git diff` EMPTY on all frozen files.
- Branch decision recorded (drives Phase 4).

---

### Phase 4: Past dual `kvE_extNegPast_complete` [COMPLETED]

**Branch B mirrored** (per Phase 3 decision): `ExteriorConverterPastK.lean` (NEW) mirrors the
Future construction through `kvE_pastChainDestructG` + `semantic_prior_SZ` (endpoint `x1 < x` at
the left anchor `x`), carrying the same `hreal` bundle and `hsat` saturation residue. Atom layer
via `kvE_pastAtom_of_bundle` (side-agnostic replica of `kvE_futAtom_of_bundle`, keeping the module
self-contained on `ExteriorNegationPastK`). Off-fiber falsity via `kvE_pastAdmissible_offFiber`.
Green, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`.

**Goal**: Mirror Phases 2-3 through the Past chain and `semantic_prior_SZ` (last-occurrence), consuming the Past `_sound` template (`ExteriorNegationPastK.lean:539`). Land the SAME resolution branch as Phase 3.

**Tasks**:
- [ ] Mirror `kvE_futReal_of_bundle` → Past bundle adapter; mirror the `nf_eval_nfk_iff_efold` reconstruction on the Past chain.
- [ ] Mirror `kvE_futEnd_forces_atom` / `kvE_futFiber_backward` for the Past endpoint via `semantic_prior_SZ` (`PriorDefs.lean:33`, last-occurrence / supremum).
- [ ] Complete `kvE_extNegPast_complete`; if Phase 3 fired Branch B, add the mirrored carried residue binder.
- [ ] Consume UNCHANGED: `kvE_extNegPast_sound` (template), Past chain infra, `semantic_prior_SZ`.

**Timing**: ~2 hours (size M-L).

**Depends on**: 3

**Files to modify**:
- `…/NfMultiAnchorBridge/ExteriorConverterPastK.lean` — Past helpers + `kvE_extNegPast_complete`.

**Verification**:
- `lake build` green on `ExteriorConverterPastK.lean`; `kvE_extNegPast_complete` closed (matching Phase 3's branch).
- `lean_verify` on `kvE_extNegPast_complete`: axioms ⊆ `[propext, Classical.choice, Quot.sound]`; ZERO `sorry`.
- `git diff` EMPTY on all frozen files.

---

### Phase 5: Bundle-shape reconciliation + Option B determinacy reader [COMPLETED]

Added the **discharge template** `kvE_futBundle_of_realizer` (Future) / `kvE_pastBundle_of_realizer`
(Past): from a genuine exterior realizer `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, BOTH carried
obligations (`hreal` fiber-forward + `hsat` fiber-backward saturation) hold, by a direct read of
`nf_eval_nfk_iff_efold`. This is the faithful Option-B at-anchor determinacy reader (report 01
Deliverable 5) proving the carried hypotheses are a dischargeable interface for the task-349 outer
recursion — NOT debt. Both green, axioms exactly `[propext, Classical.choice, Quot.sound]`.

*(deviation: Option B realized as the anchor-determinacy discharge template rather than a redundant
`kvE_subBit_iff` below-`t` re-wrap — `kvE_subBit_iff` requires a realized σ and its below-`t`
bucket read is already green infra via `kvE_fiberBucket_nonempty_iff`; the discharge template is the
non-redundant, forward-usable slice.)*

**Goal**: Align the `hreal` bundle (and any Phase-3/4 carried residue binder) with the task-349 / `KampPrior:351` provider-discharge interface and task-352 `hbelowFib`/`hexclExt` conventions, so the `_complete` theorems are consumable by the outer recursion. Optionally fold in the Option B determinacy reader.

**Tasks**:
- [ ] Reconcile the `hreal` bundle signature with the task-349 Phase-2 bracket `_complete` interface and the `KampPrior:351` provider-discharge shape; adjust naming/argument order for drop-in consumption (without editing any frozen file).
- [ ] Fold in Option B (report 01 Del 5): package `nf_eval_nfk_iff_efold` + `kvE_subBit_iff` into an `hbelowFib`-shaped biconditional (below-`t` / at-anchor determinacy reader) as the immediately-dischargeable slice. If it would have de-risked Phase 3, note that it may be pulled forward in a future revision; here it lands as the reconciliation slice.
- [ ] Document the carried residue binder (if any) as an explicit outer-recursion obligation for the task-349 re-dispatch.

**Timing**: ~1.5 hours (size M).

**Depends on**: 4

**Files to modify**:
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` and/or `ExteriorConverterPastK.lean` — reconciliation lemmas + Option B determinacy reader.

**Verification**:
- `lake build` green on both new modules.
- `lean_verify` on new reconciliation/Option-B decls: axioms ⊆ `[propext, Classical.choice, Quot.sound]`; ZERO `sorry`.
- `git diff` EMPTY on all frozen files.

---

### Phase 6: Axiom / sorry audit + full build + frozen git-clean [COMPLETED]

Final audit PASSED: both `kvE_extNegFut_complete` and `kvE_extNegPast_complete` verify with axioms
EXACTLY `[propext, Classical.choice, Quot.sound]`; zero `sorry`/`admit`/vacuous defs in the two
new modules; zero new `axiom` declarations; full-project `lake build` green (1724 jobs); all 10
frozen files byte-identical; `git diff --stat HEAD~3 -- Theories/` shows ONLY the two new modules
(423 insertions).

**Goal**: Final verification that the deliverable is green, sorry-free, axiom-clean, and frozen-files-clean.

**Tasks**:
- [ ] `lean_verify` on both `kvE_extNegFut_complete` and `kvE_extNegPast_complete` (and all new helpers): axioms EXACTLY `[propext, Classical.choice, Quot.sound]`.
- [ ] Grep both new modules for `sorry` / `admit` / placeholder defs — must be ZERO.
- [ ] Full `lake build` green (whole project, not just touched modules).
- [ ] `git diff` EMPTY on all 10 frozen files: `PriorInterface.lean`, `SharedWitness.lean`, `SubBracket2V.lean`, `OuterGate.lean`, `ExteriorBracket.lean`, `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`, `ExteriorNegationPastK.lean`, `KampPrior.lean`, `ExteriorBracketK.lean`.
- [ ] Confirm both new modules are the ONLY changed source files.

**Timing**: ~1 hour (size S).

**Depends on**: 5

**Files to modify**:
- None (audit only; may add doc comments to the two new modules).

**Verification**:
- Axiom set exactly `[propext, Classical.choice, Quot.sound]` on both `_complete` theorems.
- Full `lake build` green.
- `git status --porcelain` shows only the two new modules (+ specs artifacts).

## Testing & Validation

- [ ] `lake build` green on `ExteriorConverterK.lean` and `ExteriorConverterPastK.lean` at every phase terminus.
- [ ] Full-project `lake build` green at Phase 6.
- [ ] `lean_verify kvE_extNegFut_complete` → axioms `[propext, Classical.choice, Quot.sound]`, zero sorry.
- [ ] `lean_verify kvE_extNegPast_complete` → axioms `[propext, Classical.choice, Quot.sound]`, zero sorry.
- [ ] `git diff --stat` on the 10 frozen files → empty at every phase commit.
- [ ] Both `_complete` theorems match the research Deliverable 1 well-posed signatures (with, at most, one named carried residue binder if Phase 3 Branch B fires).
- [ ] New helpers present at proposed signatures: `kvE_futReal_of_bundle`, `kvE_futEnd_forces_atom`, `kvE_futFiber_backward`.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorConverterK.lean` (NEW) — Future `kvE_extNegFut_complete` + helpers.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorConverterPastK.lean` (NEW) — Past `kvE_extNegPast_complete` + helpers.
- `specs/354_build_nested_2endpoint_bracket_reanchoring_converter/plans/01_nested-reanchoring-converter.md` (this plan).
- `specs/354_build_nested_2endpoint_bracket_reanchoring_converter/summaries/01_nested-reanchoring-converter-summary.md` (on completion).

## Rollback/Contingency

- All new code lands in two NEW modules; frozen files are never edited. To revert, delete the two new modules — no frozen-file surgery needed.
- If Phase 3's probe reveals the residue cannot be discharged internally AND the carried-residue binder cannot be stated faithfully (not anticipated — the research bounds this to a scoping question), mark the task `[BLOCKED]` and escalate with the probe transcript; do NOT land a `sorry`.
- Per-phase green commits (task {N} phase {P}: convention) allow resuming from the last green phase on interruption.
