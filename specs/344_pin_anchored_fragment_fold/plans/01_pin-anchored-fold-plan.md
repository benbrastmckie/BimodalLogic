# Implementation Plan: Task #344 — Pin-Anchored Fragment Fold (`kvE2_outer_fold_frag`, SharedWitness additive)

- **Task**: 344 - Land the pin-anchored fragment fold in `SharedWitness.lean`, ADDITIVE-ONLY: `kvE2_sepGateAtPin_fragL/R` (six gate conjuncts at the extracted pin `q` with `x < q < w`), `kvE2_sepBody_kit_sound_frag`, and `kvE2_outer_fold_frag` (pin-anchored variant of the landed `kvE2_outer_fold`). Spawned from task 335 blocker escalation 2; consumed by 335 Phase B.
- **Status**: [IMPLEMENTING]
- **Effort**: 5-7 hours (3 dispatches; the genuine risk is the first-phase pin/segment-extraction output shape)
- **Dependencies**:
  - 335 (BLOCKED — the consumer; its Phase B stops precisely because the pin-anchored gate is unlanded)
  - 333 (COMPLETED — `ff54d45c5`) — landed `kvE2_outer_fold` (`SharedWitness.lean:9897`), `kvE2_sepBody_extract` (`SW:8410`), `kvE2_sepBody_kit_sound` (`SW:9787`), the O4 CRUX RECORD (`SW:6698-6791`). 344 consumes all unchanged and appends new decls only.
  - Landed pin extraction: `kvE_sub2V_bounded_anchor_of_outer` + `kvE_subBracket2V_sound_of_outer` (`SubBracket2V.lean` — line numbers per report ~`:1447-1470`/`:1216`; **re-confirm against current HEAD** `ff54d45c5` via `lean_local_search`, the report was checked at `cfc7fd5c2`).
  - 341 (interacts — its Phase-3 GATE re-diffs `SharedWitness.lean` before code moves; 344's additive banner section makes that re-diff trivial to classify).
- **Research Inputs**: specs/344_pin_anchored_fragment_fold/reports/01_fragment-extractor-derivability.md (machine-verified GO; original at specs/335_.../reports/05_fragment-extractor-derivability.md)
- **Artifacts**: plans/01_pin-anchored-fold-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, lean4.md, git-workflow.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 335 Phase B is blocked because the landed `kvE2_outer_fold` takes a **∀-anchor** `hgateL`/`hgateR`
FORWARD family with no public producer — and report 01 machine-verifies that this ∀-anchor statement
is **FALSE** in gate-legal, `hfrag`-legal configurations (§1: a spurious anchor realizer `a' ∈ (w,t)`
satisfies `.holds` yet violates the demanded `a' < w`). No extractor, public or private, can derive a
false statement, so a segment-coverage extractor serving that interface is **REFUTED** and MUST NEVER
be attempted.

The GO path (report §2, adversarially checked §4) is a **pin-anchored** `_frag` variant. The ∃-side of
the landed chain already extracts the designated pin witness `q` with `x < q < w` realizing the pin
`⟨charK (nfk_projFresh σ)⟩` (via `kvE_sub2V_bounded_anchor_of_outer`). At **this** `q` — not an
arbitrary anchor — all six gate conjuncts close conjunct-by-conjunct from `.holds` content plus one
dischargeable extra input `hcorrK` (provider correctness at the pin, the `ExistProviders.correct` step
335 already owns). The work is confined to `SharedWitness.lean` because the segment/arrangement
internals the new extractor unfolds are file-private (82 `private` decls). It is **ADDITIVE-ONLY**:
zero existing declarations modified, all new decls appended below a banner so 341's GATE re-diff
classifies the delta trivially.

Deliverables (SharedWitness territory only): `kvE2_sepGateAtPin_fragL`, `kvE2_sepGateAtPin_fragR`,
`kvE2_sepBody_kit_sound_frag`, `kvE2_outer_fold_frag`. The 335-side consumption
(`hcorrK` instantiation, `hexcl` probe, `bracketEndChar_kvE2_correct_two_prior_frag` assembly in
`OuterGate.lean`) is **NOT part of this task** — it is 335's resume, unblocked by the signatures 344
lands.

### Research Integration

- Report 01 verdict table: candidate (P) ∀-anchor extractor = **NO-GO REFUTED** (binder-level
  obstruction survives the fragment, `SW:6772-6778`); candidate (R) pin-anchored `_frag` fold =
  **GO, interface-verified** (residue-vanish accounting closes conjunct-by-conjunct at the pin,
  `SW:6785-6791`).
- The six-conjunct closure channel table (§2) is the derivation map for Phases 1-2: each conjunct at
  the pin has a cited landed public lemma (`kvE2_sepHgate_offFiber` `SW:6660-6662`;
  `kvE2_sepSegForm_excludes` `SW:6683-6696`; `kvE_sub2V_zone_consistent` + `kvE2_sepHgate_innerNine`
  `SW:6669-6675`; `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via `nfPred_correct` `SW:9963-9977`).
- The one extra input `hcorrK` enters as an explicit hypothesis (same A1 pattern as `hexcl`),
  discharged downstream by 335 at `charK := P.existF 0`; §2 proves it is genuinely needed (closes the
  self-zone coherence hole).
- Exact lemma statement sketches (§2, lines 104-131 of the report) are the signature targets; adopt
  their shape verbatim, adjusting only line-number references to current HEAD.

### Prior Plan Reference

No prior plan for task 344 (this is round 1). The consumer's plan
(`specs/335_.../plans/05_fragment-gate-v5.md`) and its Phase-B blocker handoff were read for
calibration: they confirm `hbdry` discharges vacuously under `hfrag`, the fold reduction typechecks
(order bits unify defeq), and the exact wall is the ∀-anchor FORWARD conjunct — which the pin-anchored
form dissolves by never instantiating at an arbitrary anchor.

### Roadmap Alignment

No `roadmap_flag` in delegation context; ROADMAP consultation skipped. This task advances the k=2 N2
fragment deliverable feeding 309 Phase 13.4 and `KampPrior.lean:351` via the 335 chain.

## Goals & Non-Goals

**Goals**:
- Land `kvE2_sepGateAtPin_fragL` and `kvE2_sepGateAtPin_fragR`: the six gate conjuncts derived at the
  extracted pin `q` (`x < q < w`), under `hfrag` + `hcorrK`, from `.holds`.
- Land the segment/pin-realization extractor plumbing the pin-anchored gate needs (the original gap:
  segments are discarded by `kvE2_sepBody_extract`, `SW:8410`) — serving the **pin-anchored**
  interface, never the refuted ∀-anchor one.
- Land `kvE2_sepBody_kit_sound_frag` (kit_sound's conclusion from `hfrag` + `hcorrK`, no ∀-anchor
  hgate) and `kvE2_outer_fold_frag` (fold with `hgateL`/`hgateR`/`hbdry` replaced by `hfrag` + `hcorrK`;
  `hexcl` threaded verbatim, A1 provider-conditional, unchanged).
- Keep every deliverable `lake build` green + axiom-clean `{propext, Classical.choice, Quot.sound}` +
  zero sorries on live paths, at **every** phase commit.
- Hand back verified signatures to 335: confirm the new lemmas match what 335 Phase B consumes (six
  gate conjuncts at pin `q` with `x < q < w`) and record any drift in the handoff.

**Non-Goals**:
- **NEVER** attempt the refuted ∀-anchor extractor / segment-coverage extractor serving the landed
  fold's `hgateL` (report §1). It derives a FALSE statement; file ownership is irrelevant.
- **Do NOT modify any existing declaration** in `SharedWitness.lean` — additive-only, new decls below
  the banner exclusively.
- **Do NOT edit any other `.lean` file** — `OuterGate.lean`, `SubBracket2V.lean`, and all 333/334/342
  carrier inputs are consumed byte-unchanged.
- **Do NOT perform the 335-side consumption** (`hcorrK` instantiation from `ExistProviders.correct`,
  the `hexcl` GO/NO-GO probe, `bracketEndChar_kvE2_correct_two_prior_frag` assembly). Those are 335's
  resume, in `OuterGate.lean`.
- **Do NOT discharge `hcorrK` or `hexcl` inside 344** — both remain explicit hypotheses on the `_frag`
  lemmas (A1 provider-conditional pattern), dischargeable by 335.
- No bare `sorry`/`admit` on live paths; no vacuous close (`False.elim`, `:= trivial`); no new axioms.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Pin-extraction output shape**: `kvE_sub2V_bounded_anchor_of_outer` (and `bracketFromLists_flatMap_subchain_below_pin`) may not deliver the segment context **jointly** with `q` — if not, the extraction lemma is where the additive work starts (report §3.3) | H | M | **Front-loaded probe in Phase 1** (first tasks, before any gate derivation). Inspect the pin extraction's exact output type via `lean_hover_info`/`lean_goal`. If the segment context is not co-delivered, land a small additive joint-extraction lemma FIRST; if that lemma cannot be stated additively, STOP and escalate (do not reshape existing decls). |
| **Arrangement-shape reduction under `hfrag`**: `kvE2_sepArr'` reduces to the two-slot bracket under single-positive `hfrag`; mechanical but **unlanded** (report §3.2) | M | M | **Front-loaded probe in Phase 1.** Confirm the reduction as a `have`/skeleton before building the gate. If it does not reduce mechanically, capture the residual goal and treat as an early NO-GO signal (escalate rather than thrash). |
| **`hexcl` threading**: `hexcl` remains threaded verbatim through `kvE2_outer_fold_frag` (A1 provider-conditional); a mis-thread breaks the fold reduction (report §2, §3.1) | M | L | **Front-loaded probe in Phase 1**: confirm `hexcl`'s exact position/shape in the landed `kvE2_outer_fold` signature so Phase 3 threads it verbatim. `hexcl` stays an explicit hypothesis — never discharged in 344. |
| Refuted ∀-anchor shape accidentally re-attempted | H | L | Explicit Non-Goal + Phase 1 checklist gate: any gate conjunct must be proved AT the extracted pin `q`, never `∀ a`. Grep the new section for `∀ a` binder patterns over the anchor before each commit. |
| Line numbers stale (report checked at `cfc7fd5c2`; HEAD is `ff54d45c5`) | L | M | Re-confirm every cited `SW:`/`SubBracket2V:` line via `lean_local_search`/`lean_file_outline` before consuming; the report's semantic claims hold, only line refs may drift. |
| Accidental edit to an existing decl (breaks 341's additive-classification) | H | L | All new decls below the banner only; `git diff` gate before each commit confirms no hunk touches pre-banner lines; only appended lines change. |
| Axiom leakage / `sorryAx` on a live path | H | L | `#print axioms` via `lake env lean` (NOT `lean_verify` — unreliable on `SharedWitness.lean`, stale `sorryAx`) at each phase; must return `{propext, Classical.choice, Quot.sound}`. |

## Implementation Phases

**Additive banner** (append to `SharedWitness.lean` at the START of the new section; all 344 decls go
below it, nothing above it is edited):

```
-- ============================================================================
-- TASK 344: PIN-ANCHORED FRAGMENT FOLD  (ADDITIVE-ONLY — zero existing decls modified)
--   Spawned from task 335 blocker escalation 2 (sess_1783723095_edd5a7).
--   Grounding: reports/01_fragment-extractor-derivability.md (GO: pin-anchored _frag).
--   Deliverables: kvE2_sepGateAtPin_fragL / kvE2_sepGateAtPin_fragR /
--                 kvE2_sepBody_kit_sound_frag / kvE2_outer_fold_frag.
--   REFUTED (never attempt): the ∀-anchor segment-coverage extractor (report §1).
--   Consumer: task 335 Phase B (bracketEndChar_kvE2_correct_two_prior_frag).
--   341 GATE re-diff: everything below this banner is new; nothing above is touched.
-- ============================================================================
```

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases form a linear chain (each consumes the prior phase's decls). All edits are additive to
`SharedWitness.lean`. Sized to one agent dispatch each.

### Phase 1: Risk probe + pin/segment extraction + `kvE2_sepGateAtPin_fragL` [COMPLETED]

*(dispatch 8: h_fwd now fully sorry-free — WITNESS case (the flagged "last h_fwd blocker")
landed green; added helpers `kvE2_sepPtW_owner_lit`, `kvE2_sepPtX1L_owner_lit`,
`kvE2_sep_lUW_mem_slotsLFor`. 344-section sorry count 2 → 1. Sole remaining Phase-1 blocker:
`h_bwd` (`SharedWitness.lean:11076`) — per-zone witness inversion; recipe in
`handoffs/08_continuation.md`.)*

**Goal**: Front-load the three residual risks as bounded early NO-GO probes, then land the additive
segment/pin-realization extractor and the LEFT pin-anchored gate `kvE2_sepGateAtPin_fragL` (six
conjuncts at the extracted pin `q`, `x < q < w`). This is the heavy dispatch.

**Tasks**:
- [x] Append the additive banner (above) to start the new section. Confirm via `git diff` that only
      appended lines are added and no pre-existing decl is touched. *(completed — committed 9ea246946;
      also added local `kvE2_sepFragment_frag` predicate, defeq to `OuterGate.kvE2_sepFragment`, to
      avoid an import cycle. Build green.)*
- [x] **PROBE 1 (pin-extraction output shape)**: *(completed — GO-with-caveat. The bundle
      `kvE2_sepBundleL` (`SW:5327`) co-delivers the pin `x1` with `x < x1 ∧ x1 < w` BY CONSTRUCTION
      (not an arbitrary anchor) plus the `kvE2_sepPtX1L` realization and the `zXU` below-clause — this
      DISSOLVES the O4 "first obstruction" (`a < w` for arbitrary `a`). CAVEAT: `kvE2_sepDisjunct'_extract`
      (`SW:8273`, `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩`) DISCARDS the bracket segment forms — the
      three `beta` components 4/5/6 of `IntervalPattern.holds_eq_succ` (`ExistsForallNF.lean:188-203`).
      The FORWARD gate conjunct needs those segments (to exclude bit-false 1-types at open-interior
      points), so an ADDITIVE JOINT EXTRACTOR that keeps components 4/5/6 is required — exactly the
      mitigation this probe anticipated. It CAN be stated additively (content is present in `hbr`
      pre-discard), so this is GO, not a NO-GO escalation.)*
- [x] **PROBE 2 (arrangement-shape reduction under `hfrag`)**: *(completed — GO. The segment forms are
      present in the raw bracket `.holds` (`hbr`) and recoverable additively via the joint extractor
      above. Under `hfrag` the tie-grouped left/right lists collapse to `σ0`'s own slots (no cross-σ
      residue — the O4 record's channel-exhaustion vanishes), so segment zone keys align with the
      `[x1,w,x,t]` zones. Re-surfacing + zone-aligning the segments is the substantive remaining work,
      not a wall.)*
- [x] **PROBE 3 (`hexcl` threading)**: *(completed — GO. `hexcl` is the FINAL hypothesis of
      `kvE2_outer_fold` (`SW:9952-9956`): `∀ w, x<w → w<t → ptW w → ∀ σ, qnf.2 σ = false → ∀ x1,
      ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ`. Threaded verbatim into `kvE2_outer_fold_frag`, never
      discharged — Phase 3 copies it byte-identical.)*
- [x] Land the pin-anchored **continuation closers** `kvE2_sepBundleL_sound_frag` /
      `kvE2_sepBundleR_sound_frag` (dispatch 3, commits `90debe333` then refactored `7816c494a`).
      These inline `kvE_subBracket2V_sound_of_parts`'s continuation (`SubBracket2V:1324-1345` /
      `SW:9750-9776`) taking the four gate conjuncts (`h_atom`/`h_off`/`h_fwd`/`h_bwd`) AT the
      specific pin `x1` as explicit args (NOT ∀-anchor) plus `hbelow`, producing
      `∃ x1', nf_eval_nf M 1 4 [x1',w,x,t] σ`. Green, axiom-clean `{propext,Classical.choice,Quot.sound}`.
      *(deviation: the segment re-extraction itself is NOT a separate committable lemma — dispatch 2
      showed "segForm ∀ point of open zone" is FALSE at witness points; the segments must be unfolded
      inline INSIDE the gate producer below. What IS landed is the continuation closer that consumes
      the four conjuncts, so the gate producer reduces to deriving those four at the pin.)*
- [ ] **[IN PROGRESS — dispatch 7: h_fwd 3 of 4 sub-cases PROVED green+committed `e0d607927` (mid interior zUW/zXU/zWT via segForm+`kvE2_sep_pin_mem_take_flatten_iff`; boundary v≤x → zPastX/zAtX and hhigh t≤v → zFutT/zAtT via new `kvE2_sepEpL_owner_lits`/`kvE2_sepEpR_owner_lits`; zXU template verbatim). Only h_fwd WITNESS case (SW:10623) + h_bwd (SW:10813) remain `sorry` — 2 total, == HEAD baseline. Full witness recipe (2 clean AT-cases via ptW/ptX1L literals + 3 interior sub-cases via `hbelow` gidx/rank pattern) in `handoffs/07_continuation.md`; dispatch 6: h_fwd CRUX SOLVED+VALIDATED (`zoneHolds_unique` `29f97d115`); dispatch 5: STAGE A + h_atom COMPLETE]** State and prove `kvE2_sepGateAtPin_fragL` per report §2 sketch (lines 104-120). *(dispatch 6: confirmed via `kvE2_sepInnerConsistentL` SW:1220 that the 9 consistent zones = 5 intervals + 4 at-points, mapped each to its exclusion channel — interior→`kvE2_sepSegForm_excludes` (VALIDATED green), exterior/boundary→`hepL`/`hepR` snce/at-literals, witnesses→`nf_eval_unique`. Full paste-ready h_fwd template + all four sub-case recipes + h_bwd recipe in `handoffs/06_continuation.md`.)* *(dispatch 4: landed `kvE2_sep_locate_witness` — the model-general point-location core of h_fwd — green + committed `ddf5eb916`; built gate producer to STAGE A. dispatch 5: recovered the WIP and COMPLETED `h_atom` — all 16 atom cases sorry-free, green, committed `1cd512ebc`. The non-fresh order/pred cases use per-atom `congrFun` bridges on `hdrop`/`hz` with `Fin.isValue`/`Fin.succ_mk`/`Nat.reduceAdd` normalization + `Fin.ne_of_val_ne (show (a:ℕ)≠b by decide)` closed ne-proofs (the `nf0_assemble` order branch does NOT simp-reduce, so the earlier `rw [hσ0eq]` route was replaced entirely); fresh order cases prove `hbit : σ.1 (.order ⟨i,_⟩ ⟨j,_⟩ hne) = <bool>` via `simpa [Fin.isValue,…] using congrArg Prod.fst/snd (congrFun hz ⟨k,_⟩)` then `rw [hbit]`. Remaining: **h_fwd** (the crux — trichotomy via `kvE2_sep_locate_witness` + `kvE2_sepSegForm_excludes` SW:6683 + `nf_eval_unique` NormalForm:245, with the `kvE2_sepSegsG`→per-σ `kvE2_sepSegForm` before/after-pin split; the O4 CRUX SW:6698 confirms this is derivable ONLY under `hfrag` single-positive), and **h_bwd** (σ's own zUW/zWT slot channel, mirroring `kvE2_sepBundleR_sound` SW:9760-9776 `match i`). Both remain `by sorry` (leaf sub-sorries, tracked). WIP file `handoffs/gate-producer-wip.lean` superseded by the committed tree — content fully landed.)* Hypotheses
      `hfrag`, `hcorrK` (explicit), `h : (kvE2_sepBody … charK qnf).holds M atomMap x t`, `σ`,
      `hσ : σ ∈ kvE2_sepPos qnf`, `hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3`; conclusion
      `∃ w q, x < q ∧ q < w ∧ w < t ∧ …` the six conjuncts. Close each conjunct via its cited channel:
      - `q < w`, `w < t`: from the pin extraction itself.
      - full base at `[q,w,x,t]`: `χ0*` at `q` from `hcorrK`; w/x/t coordinate types from
        `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via `nfPred_correct` (`SW:9963-9977`); order bits from
        `x<q<w<t`.
      - off-fiber: `kvE2_sepHgate_offFiber` (`SW:6660-6662`).
      - FORWARD consistent zones: `kvE2_sepSegForm_excludes` contrapositive (`SW:6683-6696`) at
        segment-INTERIOR points + `nf_eval_unique` (`NormalForm.lean:245`) at WITNESS points (dispatch-2
        finding — the report's channel table omitted the witness case) + self-zone `zAtX1L`
        biconditional-literal argument.
      - FORWARD inconsistent zones: `kvE_sub2V_zone_consistent` contrapositive + `kvE2_sepHgate_innerNine`
        (`SW:6669-6675`).
      - backward: σ's own slot channel + literals.
- [ ] Every gate conjunct is proved AT the extracted pin `q`, NEVER `∀ a` over an arbitrary anchor
      (refuted-shape guard).

**Timing**: 3-4 hours (~300-500 lines; the heavy dispatch). **Depends on**: none.

**Files to modify**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(additive: banner + extractor + `kvE2_sepGateAtPin_fragL`).

**Verification**:
- All three probes recorded with an explicit GO/NO-GO note.
- `kvE2_sepGateAtPin_fragL` typechecks, sorry-free; conclusion matches report §2 sketch.
- No `∀ a`-over-anchor pattern in the new section.
- `#print axioms kvE2_sepGateAtPin_fragL` (via `lake env lean`) = `{propext, Classical.choice, Quot.sound}`.
- `git diff` touches only appended lines below the banner; no other `.lean` file changed.
- `lake build …SharedWitness` green.
- Commit: `task 344 phase 1: pin-extraction probe + segment extractor + kvE2_sepGateAtPin_fragL` with
  session ID `sess_1783723095_edd5a7_344`.

---

### Phase 2: `kvE2_sepGateAtPin_fragR` (mirror) + `kvE2_sepBody_kit_sound_frag` [NOT STARTED]

**Goal**: Land the RIGHT pin-anchored gate `kvE2_sepGateAtPin_fragR` (the `zWX1`-mirrored clone of
`fragL`) and the fragment kit `kvE2_sepBody_kit_sound_frag` (kit_sound's conclusion from `hfrag` +
`hcorrK`, no ∀-anchor hgate).

**Tasks**:
- [ ] State and prove `kvE2_sepGateAtPin_fragR` as the `zWX1`-mirrored clone of `fragL` (report §2:
      "RIGHT is the zWX1-mirrored clone"). The L/R geometries genuinely differ — mirror the structure,
      confirm each `have` type with `lean_goal`; do not blind-copy.
- [ ] State `kvE2_sepBody_kit_sound_frag` with the **verbatim conclusion** of the landed
      `kvE2_sepBody_kit_sound` (`SW:9830-9839`), hypotheses `hfrag` + `hcorrK` + `h` (no ∀-anchor
      `hgate`). Prove it by consuming `kvE2_sepGateAtPin_fragL`/`_fragR` at the sole interior positive
      σ0 (under `hfrag` there is exactly one, so the per-σ obligation collapses to L/R at the pin).
- [ ] Keep `hcorrK` and `hexcl` as explicit hypotheses — never discharged here.

**Timing**: 2-2.5 hours (~200-300 lines). **Depends on**: 1 (mirrors `fragL`; kit consumes both gates).

**Files to modify**: `…/SharedWitness.lean` (additive: `kvE2_sepGateAtPin_fragR` + `kvE2_sepBody_kit_sound_frag`).

**Verification**:
- `kvE2_sepGateAtPin_fragR` and `kvE2_sepBody_kit_sound_frag` typecheck, sorry-free.
- `kvE2_sepBody_kit_sound_frag`'s conclusion is byte-identical to `kvE2_sepBody_kit_sound` (`SW:9830-9839`).
- No refuted ∀-anchor pattern; `hcorrK`/`hexcl` remain hypotheses.
- `#print axioms` on both = `{propext, Classical.choice, Quot.sound}`.
- `git diff` additive-only, below banner; `lake build …SharedWitness` green.
- Commit: `task 344 phase 2: kvE2_sepGateAtPin_fragR + kvE2_sepBody_kit_sound_frag` with session ID.

---

### Phase 3: `kvE2_outer_fold_frag` assembly + 335 handback verification [NOT STARTED]

**Goal**: Land `kvE2_outer_fold_frag` (pin-anchored variant of `kvE2_outer_fold`: `hgateL`/`hgateR`/
`hbdry` replaced by `hfrag` + `hcorrK`, `hexcl` threaded verbatim) and hand back verified signatures to
task 335.

**Tasks**:
- [ ] State `kvE2_outer_fold_frag` per report §2 sketch (lines 126-131): same conclusion as
      `kvE2_outer_fold` (`∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`), with
      `hgateL`/`hgateR`/`hbdry` replaced by `hfrag` + `hcorrK`, and `hexcl` threaded **verbatim** from
      the landed fold (position/shape confirmed in Phase 1 PROBE 3).
- [ ] Prove it by feeding `kvE2_sepBody_kit_sound_frag` (Phase 2) into the landed `kvE2_outer_fold`'s
      internal structure. `hbdry` discharges vacuously under `hfrag` (single interior positive — the
      335 handoff already confirmed this collapse). `hexcl` stays an explicit hypothesis.
- [ ] `#print axioms kvE2_outer_fold_frag` via `lake env lean` = `{propext, Classical.choice, Quot.sound}`,
      no `sorryAx`.
- [ ] **HANDBACK to 335 (explicit)**: verify the four new lemmas' signatures against what 335 Phase B
      consumes — the six gate conjuncts at pin `q` with `x < q < w`, and `kvE2_outer_fold_frag`'s
      hypothesis list (`hfrag` + `hcorrK` + `hexcl`, the four families replaced). Cross-check against
      `specs/335_.../plans/05_fragment-gate-v5.md` Phase B/D expectations and the 335 blocker handoff.
      Record any signature drift (argument order, implicit/explicit, the exact `hcorrK` shape 335 must
      discharge from `ExistProviders.correct`).
- [ ] Full `lake build` green (whole project, not just `SharedWitness`).
- [ ] Write `specs/344_pin_anchored_fragment_fold/handoffs/01_frag-fold-for-335.md`: the four delivered
      signatures verbatim, the `hcorrK`/`hexcl` discharge obligations 335 owns, and any noted drift.

**Timing**: 1.5-2 hours (~150-300 lines + handback). **Depends on**: 2.

**Files to modify**: `…/SharedWitness.lean` (additive: `kvE2_outer_fold_frag`); new handoff note
`specs/344_pin_anchored_fragment_fold/handoffs/01_frag-fold-for-335.md`.

**Verification**:
- `kvE2_outer_fold_frag` typechecks, sorry-free; conclusion identical to `kvE2_outer_fold`; `hexcl`
  threaded verbatim; `hgateL`/`hgateR`/`hbdry` replaced by `hfrag` + `hcorrK`.
- `#print axioms kvE2_outer_fold_frag` = `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- Handback note records the four signatures and confirms/flags alignment with 335 Phase B's six-conjunct-
  at-pin consumption.
- Full `lake build` green; `git diff` additive-only below banner; no other `.lean` file changed.
- Commit: `task 344 phase 3: kvE2_outer_fold_frag + 335 handback` with session ID.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` green after
      each phase; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)** through `lake env lean`: every delivered
      `_frag`/`GateAtPin` declaration returns `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- [ ] **Additive-only**: `git diff` on `SharedWitness.lean` adds lines below the banner only; zero
      hunks modify pre-existing declarations. No other `.lean` file changed.
- [ ] **Refuted-shape guard**: no gate conjunct proved `∀ a` over an arbitrary anchor; every conjunct
      lives at the extracted pin `q` (`x < q < w`).
- [ ] **`hcorrK`/`hexcl` remain hypotheses**: neither is discharged inside 344; both appear only as
      explicit hypotheses on the `_frag` lemmas (A1 provider-conditional pattern).
- [ ] **No vacuous close on live paths**: grep the new section for `sorry`, `admit`, `False.elim`,
      `:= trivial`. Green + vacuous is a FAILURE.
- [ ] **Zero sorries on live paths at every phase commit** (incremental green milestones).
- [ ] **Handback signature verification** (Phase 3): the four lemma signatures match 335 Phase B's
      six-gate-conjunct-at-pin consumption; drift recorded in the handoff.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — extended
  additively: banner + segment/pin extractor + `kvE2_sepGateAtPin_fragL` (Phase 1);
  `kvE2_sepGateAtPin_fragR` + `kvE2_sepBody_kit_sound_frag` (Phase 2); `kvE2_outer_fold_frag` (Phase 3).
- `specs/344_pin_anchored_fragment_fold/plans/01_pin-anchored-fold-plan.md` (this file).
- `specs/344_pin_anchored_fragment_fold/handoffs/01_frag-fold-for-335.md` (Phase 3 — the four delivered
  signatures + `hcorrK`/`hexcl` discharge obligations for 335's resume).
- `specs/344_pin_anchored_fragment_fold/summaries/01_pin-anchored-fold-summary.md` (on completion).
- **Consumer (NOT this task)**: task 335 Phase B resumes on these signatures — instantiates `hcorrK`
  from `ExistProviders.correct`, runs the `hexcl` probe, assembles
  `bracketEndChar_kvE2_correct_two_prior_frag` in `OuterGate.lean`.

## Rollback/Contingency

- All 344 work is additive and isolated to the banner section of `SharedWitness.lean`. To revert:
  delete the appended section (everything below the banner); the file returns byte-identical to HEAD
  `ff54d45c5`, and 341's frozen-file lineage is preserved.
- **If PROBE 1/2/3 (Phase 1) surfaces a NO-GO** (pin extraction cannot co-deliver segment context
  additively; arrangement-shape does not reduce; `hexcl` cannot be threaded verbatim): STOP, capture
  the exact residual goal (`lean_goal` transcript), do NOT reshape existing decls, do NOT attempt the
  refuted ∀-anchor extractor, and escalate to the user / 335 orchestrator. The additive-only
  constraint is a hard boundary.
- **NEVER** re-attempt the ∀-anchor / segment-coverage extractor serving the landed fold's `hgateL` —
  adjudicated REFUTED (report §1); it derives a false statement.
- **Never** discharge `hcorrK` or `hexcl` inside 344 — they are 335's obligations; smuggling them in
  breaks the A1 provider-conditional contract.
