# Implementation Plan: Task #337 — Joint Multi-Owner Disjunct Bracket-`holds` Engine for `kvE2_sepDisjunct`

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct`
- **Status**: [BLOCKED] (Phase 1 — architectural: fixed flatMap slot arrangement not model-sorted-realizable; see Phase 1 BLOCKER note)
- **Effort**: 5 hours
- **Dependencies**: 336 (COMPLETED — `kvE2_sepBody_complete` generalized `hL` → `hLR`)
- **Research Inputs**: specs/335_outer_gate_assembly_engine_kvE2_body/reports/02_spawn-analysis.md
- **Artifacts**: plans/01_joint-disjunct-bracket-holds.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build the ⇐-direction `holds` **builder** that is the exact inverse of the landed extractor
`kvE2_sepDisjunct_extract` (`SharedWitness.lean:1865`): given the merged per-owner slot lists
`kvE2_sepSlotsL/R qnf`, an honest depth-2 evaluation
`h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` with `x < w < t`, and the
left-OR-right interior guard `hLR`, produce
`(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t`.
This is the single un-landed obligation blocking task 335 Phases 2-4 (spawn analysis, root cause).

The construction is entirely additive to `SharedWitness.lean` and is a single coherent proof,
decomposed here into four sorry-free auxiliary lemmas (one per agent run) that compose into the
deliverable, plus a final verification gate. The pipeline mirrors `bracketEndChar_k1v_complete`
(CarrierK1V ~370 lines) lifted to the joint multi-owner case: (1) map each positive owner's honest
bundle (`kvE2_sepHonestBundleL/R`) into a `k1v_sorted_realizationK` region; (2) run the engine
(`SubBracket2V.lean:633`) to obtain a globally monotone interleaved witness sequence
`interleaveK ps` across all owners; (3) re-index that sequence as the bracket witness function and
match it to `kvE2_sepBracketN`'s point types and `kvE2_sepSegs` segments via
`IntervalPattern.holds_eq_succ.mpr` (`ExistsForallNF.lean:188`); (4) discharge the endpoint
conjuncts `kvE2_sepEpL`@x / `kvE2_sepEpR`@t and assemble the three-part `VecEA2.holds`.

Definition of done: a new sorry-free lemma `kvE2_sepDisjunct_holds_of_honest` (naming mirrors
`kvE2_sepGate_holds_of_honest` :1149) in `SharedWitness.lean`, `lean_verify` axiom-clean
(`{propext, Classical.choice, Quot.sound}` only, no `sorryAx`), all seven faithfulness invariants
F1-F7 preserved, full `lake build` green, and all task-334/336 carrier lemmas used strictly as
verified INPUTS (applied, never re-derived or weakened).

### Research Integration

The spawn analysis (`specs/335_outer_gate_assembly_engine_kvE2_body/reports/02_spawn-analysis.md`)
supplies: the root-cause framing (only extractors exist in `SharedWitness.lean`; no ⇐ `holds`
builder); the precise unblocking path (wire `k1v_sorted_realizationK` into the
slot/segment/endpoint layout); the size precedent (`bracketEndChar_k1v_complete` ~370 lines,
single-agent-run-sized, not decomposable into independent sub-problems); and the verified-INPUT
boundary (`kvE2_sepBody_extract`, `kvE2_sepBody_complete`, `kvE2_sepHonestBundleL/R`,
`kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound`). Grounded signatures confirmed live in this
plan's preparation:
- Engine `k1v_sorted_realizationK` (`SubBracket2V.lean:633`): consumes
  `regions : List (M.carrier × M.carrier × List (NormalForm sig 0 1))` with `hpos` (per-region
  positivity), `hlink` (`List.Chain'` boundary-linking), `hnd` (per-region `Nodup`), `hreal`
  (per-region strict-interior realizability); produces per-region point lists `ps` (via
  `List.Forall₂`) and `(interleaveK ps).Pairwise (· < ·)`.
- Target shape `IntervalPattern.holds_eq_succ` (`ExistsForallNF.lean:188`, mpr): witnesses
  function + strict monotonicity + endpoint range + per-slot point-type realizations + three
  segment families (`beta[0]` on `(x, ws 0)`, `beta[i+1]` on `(ws i, ws i+1)`, `beta[k+1]` on
  `(ws k, t)`).
- Disjunct layout `kvE2_sepDisjunct` :613 / `kvE2_sepBracketN` :602 / `kvE2_sepSegs` :590 /
  `kvE2_sepEpL` :479 / `kvE2_sepEpR` :501; merged-list pairwise facts
  `kvE2_sepSlotsLFor_pairwise` :996 / `kvE2_sepSlotsRFor_pairwise` :1027 and the membership
  helpers used by the extractor (`kvE2_sep_lX1_mem_slotsLFor`, `kvE2_sep_getElem_*`).
- Honest bundles `kvE2_sepHonestBundleL` :1222 / `kvE2_sepHonestBundleR` :1274 (both `private`,
  same file — the deliverable MUST live in `SharedWitness.lean` to access them).

### Prior Plan Reference

No prior plan for task 337. The immediately relevant reference is task 335's plan
(`specs/335_outer_gate_assembly_engine_kvE2_body/plans/01_outer-gate-assembly.md`), whose Phase 3
`[BLOCKED]` note scoped this exact obligation and set the acceptance bar (sorry-free, axiom-clean,
F1-F7, LITMUS NS:437 no `x1 < e_i` literal). Its effort calibration (a single ~370-line
construction, comparable to `bracketEndChar_k1v_complete`) and its verified-INPUT discipline are
carried forward here. Task 336's summary
(`specs/336_generalize_completeness_right_interior_zAtX1R/summaries/01_generalize-completeness-right-interior-summary.md`)
confirms the `hLR` disjunctive signature of `kvE2_sepBody_complete` now in scope and that
`kvE2_sepArr'_sound` auto-upgraded to carry the right closed bit — both consumed as INPUTS.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). The task advances the
`kamp_theorem_formalization` topic by landing the completeness-side joint bracket engine that
unblocks task 335 Phases 2-4 (soundness, completeness, assembled k=2 gate).

## Goals & Non-Goals

**Goals**:
- Deliver a sorry-free `kvE2_sepDisjunct_holds_of_honest` in `SharedWitness.lean` producing
  `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t`
  from the honest depth-2 evaluation + `x < w < t` + `hLR` interior guard.
- Map each positive owner's honest bundle (`kvE2_sepHonestBundleL/R`) into a
  `k1v_sorted_realizationK` region and run the engine to obtain one globally monotone interleaved
  witness sequence across all owners.
- Match that sequence to `kvE2_sepBracketN`'s point types and `kvE2_sepSegs` segments via
  `IntervalPattern.holds_eq_succ.mpr`, discharging `kvE2_sepEpL`@x / `kvE2_sepEpR`@t.
- `lean_verify` axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`); full
  `lake build` green.
- Preserve F1-F7 (esp. F5: no open/closed zone-key conflation; LITMUS NS:437: no `x1 < e_i`
  relative-position literal — witness bounds from the bracket range, never a chain).

**Non-Goals**:
- **Do NOT edit, re-derive, or weaken** any task-334/336 carrier INPUT (`kvE2_sepBody_extract`,
  `kvE2_sepBody_complete`, `kvE2_sepHonestBundleL/R`, `kvE2_sepDisjunct_extract`,
  `kvE2_sepArr'_sound`, and their support lemmas). Apply them only.
- **Do NOT** touch `OuterGate.lean` or `KampPrior.lean` — the task-335 consumption of this builder
  is a separate re-dispatch.
- **Do NOT** generalize beyond the left-OR-right interior owner class (`hLR`); the
  exterior/boundary owner classes remain honestly out of scope (task 336 note).
- No bare `sorry`/`admit`, no vacuous placeholder (`def X := True`), no gate-modulo-assumed
  hypothesis.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3 (point-type + segment matching) overflows one agent run | H | M | It is the largest phase; build point-type realizations and the three `beta` segment families as separate green `have`s; if overflow looms, checkpoint the point-type helper as its own committed sorry-free lemma and split the segment matcher into a follow-on green sub-step (never a `sorry`). |
| Witness re-indexing mismatch: `interleaveK ps` order vs `kvE2_sepBracketN`'s `lL ++ ptW :: lR` slot order (off-by-region, the `ptW` pivot at index `|lL|`) | H | M | Mirror the extractor's index arithmetic verbatim (`kvE2_sep_getElem_left/mid/right`, :1897-...); the `ptW` slot sits at position `(lL.map …).length`; place regions in the SAME left/pivot/right order the extractor reads back. |
| Accidentally editing a verified carrier INPUT while adding to the same file | H | M | The new lemma is appended near `kvE2_sepArr'_sound` (end of file, before `end`); a Phase 5 `git diff` gate confirms only additive insertions and no change to any existing declaration body/signature. |
| Merged-list preconditions (`hnd` Nodup, `hlink` boundary-link) not directly supplied by per-owner bundles | M | M | Derive `hnd` from `kvE2_sepSlotsLFor/RFor` rank-pairwise nodup structure; build `hlink` from the shared `w` pivot linking the left block `(x,w,·)` to the right block `(w,t,·)` — the region boundaries are exactly `x < w < t`, not a derived chain (F3/F4-safe). |
| Endpoint conjuncts `kvE2_sepEpL`@x / `kvE2_sepEpR`@t not obviously derivable from `h` | M | L | They are the past/future outer characters of `qnf.1`; extract them from the atom-layer of `h` over `[w,x,t]` (same source the extractor destructures as `hepL, hepR`); if a dedicated helper is missing, add a small private `have`, still additive. |
| Faithfulness regression: `x1 < e_i` relative-position literal (LITMUS NS:437) or F5 open/closed key conflation | H | L | Take all witness bounds from the region endpoints `x`/`w`/`t` and the engine's interior guarantees (`hrange`), never from an owner-to-owner chain; reuse the honest bundles verbatim (they already satisfy F1-F7); Phase 5 checklist re-audits. |
| `hLR` case split (left vs right interior) doubles the region-mapping work | M | M | Handle the two interior zones symmetrically as in task 336's `rcases hLR … with hzone | hzone`; left → `kvE2_sepHonestBundleL` → left region block, right → `kvE2_sepHonestBundleR` → right region block; the engine consumes both blocks uniformly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
consumes the sorry-free auxiliary lemma produced by the previous phase.

### Phase 1: Signature verification + region assembly with engine preconditions [BLOCKED]

**BLOCKER** (Phase 1 — architectural; blocks the whole deliverable):
- **What failed**: The deliverable's required conclusion is
  `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t`
  — i.e. `.holds` for the **FIXED flat-union (flatMap) slot arrangement** `kvE2_sepSlotsL/R qnf`
  (confirmed as the exact object consumed by `kvE2_sepBody_holds_iff` :863-864 and hardcoded in
  `kvE2_sepBody` :835-836, where the weak-order `_wo` is *ignored* for slot ordering). Building
  `.holds` requires a **strictly-monotone witness sequence `ws`** with `ws i` realizing point type
  `(kvE2_sepSlotsL qnf).map (kvE2_sepSlotType …)[i]` in flatMap order (`IntervalPattern.holds_eq_succ`
  :188, mpr, first conjunct `∀ i j, i<j → ws i < ws j`). The plan's engine `k1v_sorted_realizationK`
  (SubBracket2V:633) instead returns a **`List.Perm`** of the input type list, sorted by *value*
  (`List.Perm (p.2.2.map Prod.fst) r.2.2` :642 — NOT order-equality). Its `interleaveK ps` matches a
  DIFFERENT slot arrangement (the model-sorted permutation), not the fixed flatMap `kvE2_sepSlotsL qnf`.
- **What was tried**: Full signature verification (Phase 1, task 1) — `kvE2_sepBody_complete` :1592
  confirmed carrying `hLR`; `kvE2_sepArr'_sound` :2594 confirmed; honest bundles
  `kvE2_sepHonestBundleL` :1222 / `kvE2_sepHonestBundleR` :1274 confirmed. Then traced the required
  point-type match through the landed extractor `kvE2_sepDisjunct_extract` :1865 (which *reads* `ws`
  from a GIVEN holds — never proves flatMap monotonicity) and the single-owner template
  `bracketEndChar_k1v_complete` (CarrierK1V:1629). The template resolves the identical
  Perm-vs-order-equality issue ONLY because its carrier `bracketEndChar_k1v` **enumerates all
  permutations** and the proof *selects the value-sorted permutation* as the disjunct's point-type
  list (`List.mem_permutations.mpr hpermL`, CarrierK1V:1995-1996). The joint carrier `kvE2_sepBody`
  does NOT enumerate permutations — every disjunct is over the same fixed flatMap list — so no
  value-sorted permutation can be selected.
- **Why it's stuck (root cause)**: The codebase itself documents this exact unresolved obstruction.
  SharedWitness :334-337 (task 334 Phase 6 note): switching the live filter "breaks the
  identity-arrangement `kvE2_sepSlotsL_valid`/`_valid` … **whose repair requires a joint
  model-sorted arrangement (Phase 2 make-or-break — no single-σ `k1v_sorted_realization3` analog
  exists for the joint slot list)**." SharedWitness :1038-1041 records that the two FALSE scaffolds
  `kvE2_sepSlotsL_valid`/`kvE2_sepSlotsR_valid` were REMOVED because "the identity interleaving of
  the flat union is NOT a valid arrangement (need not be cross-σ compat; handoff 05)." Concretely:
  when two positive interior owners' anchors interleave in the model (e.g. σ1's `(x1_σ1,w)` UW
  witnesses exceed σ2's `(x,x1_σ2)` XU witnesses), the flatMap order — which groups ALL of σ1's
  slots before ALL of σ2's — is NOT value-monotone, so **no strictly-monotone `ws` aligned to it
  exists**, and `.holds` for the fixed `kvE2_sepSlotsL qnf` is not a theorem (the deliverable is
  universally quantified over M, so an interleaving model is admissible). The honest bundles supply
  realizers only in anchor-relative sub-intervals; they do not (and cannot in general) place all of
  one owner's witnesses below all of the next owner's.
- **What is needed (to unblock)**: A carrier-level change to `kvE2_sepBody` / `kvE2_sepDisjunct`
  instantiation so the disjunct is built over a **model-sorted joint slot list** (the engine's
  `interleaveK ps` permutation) — OR permutation-enumeration of the joint slot lists mirroring the
  single-owner `bracketEndChar_k1v` carrier — so that the value-sorted witness produced by
  `k1v_sorted_realizationK` matches the disjunct's point-type order. Either is an edit to a
  task-334 carrier INPUT (`kvE2_sepBody`, `kvE2_sepDisjunct`), which this task's Non-Goals
  explicitly FORBID ("Do NOT edit, re-derive, or weaken any task-334/336 carrier INPUT …
  `kvE2_sepDisjunct` … Apply them only"). Resolution therefore requires a scope decision: either
  authorize a carrier redesign (new task), or supply the missing "joint model-sorted arrangement"
  machinery the task-334 note flags as the unbuilt make-or-break, and re-target the deliverable's
  conclusion to that sorted list.
- **Prohibited workarounds**: Did NOT use `sorry`, `def X := True`, or any vacuous placeholder.
  `SharedWitness.lean` is left **byte-for-byte unmodified** (no additive helper was landed, because
  every candidate helper bottoms out on the non-existent flatMap-monotonicity fact).

**Goal**: Confirm the in-scope carrier signatures, then build the `k1v_sorted_realizationK`
region list from the merged slot lists + honest bundles and discharge the four engine
preconditions (`hpos`, `hlink`, `hnd`, `hreal`). Deliver as a sorry-free private helper lemma
(suggested `kvE2_sepDisjunct_regions_of_honest`).

**Tasks**:
- [ ] Verify on start (per file-safety note) that `kvE2_sepBody_complete` carries the `hLR`
      disjunctive hypothesis and `kvE2_sepArr'_sound` the right-closed-bit upgrade (grep + one
      `lean_hover_info` each); confirm `kvE2_sepHonestBundleL` :1222 / `kvE2_sepHonestBundleR`
      :1274 signatures.
- [ ] State the helper: from `qnf`, `M`, `atomMap`, `w x t`, `hxw : x < w`, `hwt : w < t`, `hLR`,
      and `h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`, produce the region
      list `regions` (left block `(x,w,·)`, right block `(w,t,·)`, pivoted at the shared `w`)
      together with `hpos`, `hlink`, `hnd`, `hreal`.
- [ ] Per positive owner σ: `rcases hLR σ hσmem with hzone | hzone`; LEFT →
      `kvE2_sepHonestBundleL` (yields `x < x1 < w` + per-`kvE2_sepS` interior realizers), RIGHT →
      `kvE2_sepHonestBundleR` (yields `w < x1 < t` + realizers). Fold these into the region
      type-lists (`List (NormalForm sig 0 1)`) at region-interior positions.
- [ ] Discharge `hpos` from `hxw`/`hwt`; `hlink` from the `w` pivot (`x<w<t` boundaries, not a
      chain, F3/F4); `hnd` from `kvE2_sepSlotsLFor_pairwise`/`_RFor_pairwise` rank structure;
      `hreal` from the honest-bundle interior realizers.
- [ ] Verify each `have` with `mcp__lean-lsp__lean_goal`; keep the lemma sorry-free.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepDisjunct_regions_of_honest` (private helper) near the end, before `end`.

**Verification**:
- Helper compiles sorry-free; `mcp__lean-lsp__lean_diagnostic_messages` on the file clean.
- `lean_verify kvE2_sepDisjunct_regions_of_honest` shows no `sorryAx`.
- Region boundaries are exactly `x`/`w`/`t` (no `x1 < e_i` literal introduced).

---

### Phase 2: Engine invocation + global witness sequence (monotonicity + range) [NOT STARTED]

**Goal**: Apply `k1v_sorted_realizationK` to the Phase-1 regions, obtain `ps` +
`(interleaveK ps).Pairwise (· < ·)`, define the bracket witness function
`ws : Fin (N+1) → M.carrier` (N = `|lL.map …| + |lR.map …|`), and prove strict monotonicity plus
the endpoint range `x < ws i < t`. Deliver as a sorry-free private helper (suggested
`kvE2_sepDisjunct_witnesses_of_honest`).

**Tasks**:
- [ ] `obtain ⟨ps, hf, hsorted⟩ := k1v_sorted_realizationK M regions hpos hlink hnd hreal`
      (consuming the Phase-1 helper).
- [ ] Define `ws` by re-indexing `interleaveK ps` into the `kvE2_sepBracketN` slot order
      `lL ++ ptW :: lR` with the shared `ptW` pivot at index `(lL.map …).length` (mirror the
      extractor's `kvE2_sep_getElem_left/mid/right` index arithmetic, :1897 onward, in reverse).
- [ ] Prove strict monotonicity `∀ i j, i < j → ws i < ws j` from `hsorted`
      (`interleaveK` pairwise).
- [ ] Prove the range `∀ i, x < ws i ∧ ws i < t` from the region positivity/link facts (leftmost
      block lower bound `x`, rightmost block upper bound `t`).
- [ ] Verify each step with `lean_goal`; keep sorry-free.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepDisjunct_witnesses_of_honest` (private helper).

**Verification**:
- Helper compiles sorry-free; diagnostics clean.
- `lean_verify kvE2_sepDisjunct_witnesses_of_honest` no `sorryAx`.
- `ws` indexing agrees with `kvE2_sepBracketN`'s `lL ++ ptW :: lR` layout (pivot at `|lL|`).

---

### Phase 3: Point-type + segment matching → `bracket.holds` [NOT STARTED]

**Goal**: From the Phase-2 witness sequence, prove every point-type realization
(`alpha[i].eval_at (ws i)`) and the three `kvE2_sepSegs` segment families, then close
`bracket.holds` via `IntervalPattern.holds_eq_succ.mpr`. Deliver as a sorry-free private helper
(suggested `kvE2_sepBracketN_holds_of_honest`). This is the largest phase.

**Tasks**:
- [ ] `rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t (by omega)]` and `refine ⟨ws, ?_, ?_,
      ?_, ?_, ?_, ?_⟩` to expose the six mpr obligations (mono, range, point types, `beta[0]`,
      `beta[i+1]`, `beta[k+1]`).
- [ ] Mono + range: discharge from the Phase-2 helper directly.
- [ ] Point types: for each slot `i`, evaluate `((lL.map …) ++ ptW :: (lR.map …))[i]` at `ws i` —
      left slots from `kvE2_sepHonestBundleL` fresh-point realizers, the pivot `kvE2_sepPtW` from
      the shared `w`, right slots from `kvE2_sepHonestBundleR` (mirror the extractor's
      `kvE2_sep_getElem_left/mid/right` reads).
- [ ] Segments (`kvE2_sepSegs` = `kvE2_sepSegLAt` for `i ≤ |lL|`, else `kvE2_sepSegRAt`): for each
      inter-witness gap and the two boundary gaps, realize the refined-conjunction segment type
      from the region-interior realizers (`hreal` content threaded through the engine's `ps`
      per-region point guarantees).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free. If the phase approaches an agent-run
      boundary, commit the point-type portion as a standalone green lemma and continue segments in
      a follow-on green sub-step.

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepBracketN_holds_of_honest` (private helper).

**Verification**:
- Helper compiles sorry-free; diagnostics clean.
- `lean_verify kvE2_sepBracketN_holds_of_honest` no `sorryAx`.
- Segment bounds come from region endpoints/engine guarantees, not owner-to-owner chains
  (LITMUS NS:437); F5 closed/open keys unconflated.

---

### Phase 4: Endpoint discharge + assemble deliverable `kvE2_sepDisjunct_holds_of_honest` [NOT STARTED]

**Goal**: Discharge the endpoint conjuncts `kvE2_sepEpL`@x and `kvE2_sepEpR`@t from the honest
evaluation `h`, then assemble the three-part `VecEA2.holds`
(`endpointLeft@x ∧ endpointRight@t ∧ bracket.holds`) and state + prove the deliverable lemma
`kvE2_sepDisjunct_holds_of_honest`, sorry-free.

**Tasks**:
- [ ] Prove `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x` and
      `(kvE2_sepEpR charBase charK qnf).eval_at M atomMap t` from the atom-layer of `h` over
      `[w,x,t]` (same data the extractor destructures as `hepL`/`hepR`; add a small private `have`
      if no direct helper exists).
- [ ] State `kvE2_sepDisjunct_holds_of_honest` (signature mirroring `kvE2_sepGate_holds_of_honest`
      :1149 — `qnf`, `charBase`, `charK`, `M`, `atomMap`, `w x t`, `hxw`, `hwt`, `hLR`, `h`)
      concluding
      `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t`.
- [ ] `refine ⟨hepL, hepR, ?_⟩`; close the bracket via the Phase-3 helper (instantiated at
      `lL = kvE2_sepSlotsL qnf`, `lR = kvE2_sepSlotsR qnf`).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 0.75 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  the deliverable `kvE2_sepDisjunct_holds_of_honest`.

**Verification**:
- Deliverable compiles sorry-free; diagnostics clean.
- Conclusion type is byte-exactly the `.holds` that `kvE2_sepBody_holds_iff` (:855, mpr) consumes.
- `lean_verify kvE2_sepDisjunct_holds_of_honest` no `sorryAx` (full audit in Phase 5).

---

### Phase 5: Axiom-cleanliness gate + F1-F7 faithfulness audit + full build [NOT STARTED]

**Goal**: Run the explicit axiom-cleanliness gate, audit F1-F7 preservation, confirm carrier
INPUTS untouched, and pass a full project build.

**Tasks**:
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest` and each Phase-1..3 helper; confirm each
      returns `{propext, Classical.choice, Quot.sound}` with **no `sorryAx`**.
- [ ] Grep the diff for `sorry`/`admit`/new `axiom`/vacuous `:= True` — must be NONE.
- [ ] F1-F7 checklist: F2 (non-vacuous — realizers come from honest bundles, not placeholders);
      F5 (no open/closed zone-key conflation — closed `zAtX1L`/`zAtX1R` bits read as in task 336);
      LITMUS NS:437 (no `x1 < e_i` relative-position literal — all witness/segment bounds from the
      bracket range `x`/`w`/`t` and engine interior guarantees).
- [ ] `git diff` gate: confirm the change is purely additive to `SharedWitness.lean` (no existing
      declaration body/signature altered; carrier INPUTS `kvE2_sepBody_extract`,
      `kvE2_sepBody_complete`, `kvE2_sepHonestBundleL/R`, `kvE2_sepDisjunct_extract`,
      `kvE2_sepArr'_sound` untouched).
- [ ] Full `lake build` green.

**Timing**: 0.75 hours

**Depends on**: 4

**Files to modify**:
- None (verification-only; no code changes beyond fixups surfaced by the audit).

**Verification**:
- `lean_verify` on all delivered declarations axiom-clean, no `sorryAx`.
- Full `lake build` succeeds.
- F1-F7 checklist passes; carrier INPUTS byte-for-byte unmodified.

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 5) succeeds.
- [ ] `mcp__lean-lsp__lean_diagnostic_messages` on `SharedWitness.lean` clean (no errors, no `sorry`).
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest` and every auxiliary helper returns
      `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit`, no new `axiom`, no vacuous definition anywhere in the diff.
- [ ] All task-334/336 carrier INPUT declarations are byte-for-byte unmodified.
- [ ] The deliverable's conclusion type matches `kvE2_sepBody_holds_iff` (:855) mpr's required
      `.holds` exactly.
- [ ] F1-F7 faithfulness checklist passes (F5 closed/open discrimination; LITMUS NS:437 no
      `x1 < e_i` literal; witness bounds from the bracket range).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — additive:
  `kvE2_sepDisjunct_regions_of_honest`, `kvE2_sepDisjunct_witnesses_of_honest`,
  `kvE2_sepBracketN_holds_of_honest` (private helpers), and the deliverable
  `kvE2_sepDisjunct_holds_of_honest`.
- `specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/plans/01_joint-disjunct-bracket-holds.md` (this file).
- `specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/summaries/01_joint-disjunct-bracket-holds-summary.md` (on completion).
- **Downstream**: task 335 re-dispatches Phases 2-4 to consume `kvE2_sepDisjunct_holds_of_honest`.

## Rollback/Contingency

- All work is additive to `SharedWitness.lean`. To revert: delete the four new declarations; the
  file returns to its post-task-336 state with every carrier INPUT untouched.
- If Phase 3 (point-type + segment matching) cannot close within one agent run: commit the
  point-type helper as a standalone sorry-free lemma (green checkpoint), then continue the segment
  matcher in a follow-on green sub-step. Never commit a bare `sorry`, a vacuous placeholder, or a
  `.holds` modulo an assumed segment obligation (honest RESCOPE discipline).
- If the `interleaveK ps` → `ws` re-indexing proves harder than the extractor's forward read:
  fall back to defining `ws` directly from the per-region `ps` blocks with explicit `Fin.append`
  splicing at the `ptW` pivot; still additive, still engine-driven.
- Carrier-INPUT edit is forbidden: if a fix appears to require changing a task-334/336 lemma, stop
  and surface it as a scope question rather than weakening a verified INPUT.
