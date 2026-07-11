# Implementation Plan: Successor Carrier Redefinition (the 321-N2 named successor)

- **Task**: 346 - successor_carrier_redefinition
- **Status**: [IMPLEMENTING]
- **Effort**: ~12 hours (6 phases)
- **Dependencies**: 345 (landed; symmetric-gate clause (v))
- **Research Inputs**: reports/01_successor-carrier-redefinition.md (H4-verified, Tier 1)
- **Artifacts**: plans/01_successor-carrier-redefinition.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

Report 01 corrects the task framing (H4-surfaced): the "bit-compatibility filtering carrier
redefinition" is **already landed** (tasks 333/334); it is NOT the open work. The genuine,
decision-complete work task 346 owns is a **fragment-predicate repair + non-vacuous restatement +
exterior-completeness re-scope**. The landed `kvE2_sepFragment` demands a GLOBAL single positive
sub (`kvE2_sepPos qnf = [σ0]`), which `nf_exists_unique` proves unrealizable (every realized qnf
carries >=3 boundary positives; report 07 Refutation 1). The repair swaps the carrier list to the
**interior-restricted** index `kvE2_sepPosI` (SW:211), which is realizable (High confidence, H4 #1
— the 3 forced positives sit at at-point zones zAtX/zAtW/zAtT, excluded by the interior filter).

`hexcl` (the outer-forward exterior-completeness direction) is machine-confirmed **NOT dischargeable
on any currently-unblocked route** (report 07 Refutation 2 + independently-blocked `Prop43.lean`).
The achievable deliverable is therefore a **re-scoped interior+boundary-complete CONDITIONAL gate**
(resolution R1): boundary-restrict `hexcl`'s binder to the interior+boundary cone `x <= x1 <= t`,
under which `hexcl` IS discharged by the landed endpoint/witness biconditional literals. Full-exterior
completeness is **deferred to a named Prop-4.3 successor task** (documented in Phase 6, NOT attempted
here). No sorry is left on any live path — the gate is a genuine conditional theorem; the exterior
obligation is carried by the caller and becomes the successor task.

**Definition of done**: (1) both `kvE2_sepFragment` (OuterGate:200) and `kvE2_sepFragment_frag`
(SW:10219) carry the interior-singleton predicate byte-identically; (2) a realizability witness
lemma exhibits a concrete satisfiable qnf/M; (3) `kvE2_outer_fold_frag` backward branch is repaired
for boundary positives; (4) `bracketEndChar_kvE2_sound_two_prior_frag` is re-stated non-vacuously
with both VACUITY NOTEs replaced; (5) `lake build` green, axiom-clean {propext, Classical.choice,
Quot.sound}, no sorries on live paths; (6) consumer + successor handoff documented.

### Research Integration

- **reports/01_successor-carrier-redefinition.md** (integrated in plan version 1, 2026-07-11):
  H3 5-column mapping table, decision-complete resolutions (a)-(e), survival audit, adversarial
  verification. All load-bearing file:line targets re-confirmed at HEAD during planning.

### Preserved Assets

The following work is complete and must be **verified, not rewritten** (predicate swap is expected
to preserve all of it; `lake build` is the confirmatory check):

| Component | File / Decl | Status | Verified | Instruction |
|-----------|-------------|--------|----------|-------------|
| Symmetric-gate clause (v) (Rabinovich Cor 5.4 p.9, task 345) | SW `kvE2_sep_zone4_consistentR` (:11309), gate clause (v) (:1238) | LANDED | 2026-07-11 (report) | DO NOT edit; keys on zone not list; inert under swap |
| Pin-anchored gate producers (tasks 344/345) | SW `kvE2_sepGateAtPin_fragL` (:10526), `_fragR` (:11553) | LANDED, proofs genuine | 2026-07-11 (report) | Verify green after swap; no direct `kvE2_sepPos` destructure |
| Kit soundness (task 344) | SW `kvE2_sepBody_kit_sound_frag` (:12487) | LANDED, pass-through of hfrag | 2026-07-11 (report) | Verify green; must not be re-proved |
| Completeness half (335 Phase 2, unconditional) | OuterGate `bracketEndChar_kvE2_complete_two_prior` (:139) | LANDED, unconditional | 2026-07-11 (report) | Untouched by swap |
| Provider correctness bridge (335 Phase B) | OuterGate `bracketEndChar_kvE2_hck` (:115) | LANDED | 2026-07-11 (report) | Untouched |
| Interior index + membership lemmas (task 342) | SW `kvE2_sepPosI` (:211), `_mem` (:217), `_zone` (:230), `_subset` (:224) | LANDED, proven | 2026-07-11 (planning grep) | Reuse as new fragment carrier; do not modify |
| Bit-compatibility carrier (tasks 333/334) | SW `kvE2_sepCompat` (:951) wired into `kvE2_sepSlotLe` (:1035) | LANDED | 2026-07-11 (report) | Frozen; NOT re-plumbed (task-description "carrier redefinition" already satisfied) |

### Source-to-Implementation Mapping (H3, Tier 1)

| Source claim | Source | Lean target | Action |
|---|---|---|---|
| Global-singleton fragment unrealizable | 335 report 07 Refutation 1 | `kvE2_sepFragment` (OuterGate:200), `kvE2_sepFragment_frag` (SW:10219) | Swap `kvE2_sepPos` -> `kvE2_sepPosI`, byte-identical (Phase 1) |
| Interior filter dodges Refutation 1 (realizable) | 335 report 07; H4 #1 | new `kvE2_sepFragment_realizable` witness | Add satisfiable qnf/M witness (Phase 2) |
| `hexcl` = outer-forward exterior direction, NOT dischargeable | 335 report 07 Refutation 2; `Prop43.lean:120-159` blocked | `kvE2_outer_fold_frag` hexcl param (SW ~:12543) | Boundary-restrict binder to `x <= x1 <= t` (R1, Phase 3) |
| Fold backward branch loses contradiction under swap | H4 #5; SW backward branch (fold body ~:12603-12633 at report HEAD) | `kvE2_outer_fold_frag` backward branch | Genuine repair via endpoint/witness literals (Phase 4) |
| Boundary positives realized by endpoint literals | O4 record SW:6702-6704 | `kvE2_sepEpL` (:1054), `kvE2_sepEpR` (:1076), `kvE2_sepPtW` (:1100) | Realization channel in Phase 4 |
| Exterior completeness needs Prop 4.3 (BLOCKED) | 330 report 01; 335 report 07 point 1 | `Prop43.lean` | OUT OF SCOPE; named successor (Phase 6) |
| Rabinovich symmetric gate clause (v) | Rabinovich 2014 Cor 5.4 p.9 (PDF page only) | SW gate clause (v) | Untouched |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from report 01 (H4-verified) and the
335/330 audit trail.

**Do NOT**:
- Do NOT re-plumb the carrier arrangement (`kvE2_sepBody`, `kvE2_sepSlotLe`, `kvE2_sepCompat`). The
  bit-compatibility redefinition is ALREADY landed (333/334); "SW:6763-6770" is a stale proof-body
  reference, not an open obligation. Touching carrier internals violates the 341 frozen-file gate.
- Do NOT attempt to discharge full-exterior `hexcl` (over all `x1 : M.carrier`). Machine-confirmed
  underivable (report 07 Refutation 2: category mismatch at inner-bits layer + `bracketEndChar_kv_factors`
  arity-1 inseparability) AND the alternative route `Prop43.lean` is independently blocked. Any
  dispatch that re-opens this is analysis churn — stop and re-read this constraint.
- Do NOT edit any decl ABOVE the 341 GATE banner (SW:10210). The fragment repair touches only
  `kvE2_sepFragment_frag` and the fold backward branch, both below the banner.
- Do NOT use `simp`/`omega`/`aesop` to bypass the endpoint-literal realization steps in Phase 4;
  the boundary-positive realization is a literature-faithful transcription (Rabinovich §5 bracket
  assembly), not a search target.
- Do NOT introduce an `x1 < e_i` positioning literal (LITMUS anti-pattern from prior 335 dispatches).
- Do NOT leave a `sorry` on a live path. The exterior gap is quarantined by binder restriction, not
  by a sorry.
- Do NOT change the fragment predicate at one site only. The `rfl` defeq bridge (OuterGate:223-224)
  requires `kvE2_sepFragment` and `kvE2_sepFragment_frag` to have BYTE-IDENTICAL bodies.

**MUST preserve** (verify with `lake build`, do not rewrite — see Preserved Assets table):
- The 344/345 pin/kit/symmetric-gate machinery (fragL/fragR/kit_sound/clause (v)).
- The unconditional completeness half (OuterGate:139) and provider bridge (OuterGate:115).
- Axiom cleanliness: final `lean_verify` must show only {propext, Classical.choice, Quot.sound}.

**Design decisions are SETTLED** (do not re-open without a concrete machine counterexample):
- **RE-SCOPE, not hexcl-elimination.** The deliverable is an interior+boundary-complete conditional
  gate. Rejected alternative: a fully hexcl-free gate — proven unreachable on every in-tree route
  (report 07 exhausts fold-interface enrichment; `Prop43.lean` exhausts the navigated route).
- **Interior singleton via `kvE2_sepPosI`, not global `kvE2_sepPos`.** Rejected alternative: keep
  the global predicate and prove realizability — impossible (Refutation 1, >=3 forced positives).
- **R1 (boundary-restrict the hexcl binder), not R2 (retain full hexcl + realizability witness of
  the premise set).** R2 only un-vacuates; it does not unblock the consumer (309 still cannot
  discharge full hexcl). R1 delivers a genuinely consumable interior+boundary gate.

## Goals & Non-Goals

- **Goals**:
  - Swap the fragment predicate to the interior-singleton `kvE2_sepPosI` at both sites, byte-identical.
  - Add a realizability witness proving the new predicate is satisfiable (non-vacuity ground).
  - Boundary-restrict `hexcl` (R1) and repair the fold backward branch for boundary positives.
  - Re-state `bracketEndChar_kvE2_sound_two_prior_frag` non-vacuously; remove both VACUITY NOTEs.
  - Document consumer impact (309 Phases 13.4/14, KampPrior.lean:351, 335 Phase D) and the deferred
    Prop-4.3 exterior-completeness successor.
- **Non-Goals**:
  - Full-exterior completeness / full `hexcl` (deferred to Prop-4.3 successor task).
  - Any carrier-arrangement re-plumbing (already landed by 333/334).
  - Any edit above the SW:10210 341 GATE banner.
  - Editing the completeness half or provider bridge (untouched by the swap).

## Risks & Mitigations

- **Risk**: The byte-identical swap breaks decls beyond the expected fold backward branch (survival
  audit is Medium-High / grep-level). **Mitigation**: Phase 1 is a dedicated triage phase that
  localizes the break surface with `lake build` BEFORE any repair work — failures surface first.
- **Risk**: Interior-singleton realizability is subtler than expected (Phase 2 witness hard to
  construct). **Mitigation**: report H4 #1 gives the concrete model shape (x<w<t, one strictly-interior
  realized 1-type); construct against `nf_exists_unique`. If the witness cannot be built, this is a
  hard STOP (would refute the whole RE-SCOPE verdict) — escalate, do not paper over.
- **Risk**: Phase 4 fold repair exceeds the line budget / the boundary-positive realization channel
  is incomplete. **Mitigation**: Phase 3 lands the re-scoped `hexcl` binder FIRST so Phase 4 has the
  realization admissibility; if Phase 4 overruns 300 lines, split at the LEFT/RIGHT branch boundary.
- **Risk**: Re-stated theorem's hexcl binder mismatches the consumer's expectation (309). **Mitigation**:
  Phase 6 documents the exact new signature and flags the exterior residue as the successor's job.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 2, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Wave 2 (Phases 2 and 3) both edit
`SharedWitness.lean` but in disjoint regions — Phase 2 appends a new witness lemma near the
`kvE2_sepPosI` block (~SW:245), Phase 3 edits the `kvE2_outer_fold_frag` signature (~SW:12543).
An orchestrator may serialize them to avoid overlapping edits to the same file; the logical
dependency permits parallelism.

### Phase 1: Byte-identical fragment-predicate swap + build triage [PARTIAL]

**TRIAGE RESULT** (Phase 1, session sess_1783782450_230288): swap applied byte-identically at both
sites; break surface localized to 3 errors in the fold family (all below the GATE banner). SURVIVAL
AUDIT REFINED: `kvE2_sepBody_kit_sound_frag` (SW:12487) ALSO errors (2 sites: fragL call SW:12517-18,
fragR call SW:12519-20), contrary to this phase's "NO error in ... kit" criterion — kit_sound
destructures the fragment and feeds `hpos` to the global-typed gate producers. Producers fragL
(:10526)/fragR (:11553) themselves stay GREEN; no error above the banner; RE-SCOPE verdict intact.
Marked [PARTIAL] (not [COMPLETED]) because the stated kit criterion failed — this EXPANDS the Phase 4
repair surface (kit_sound fwd + fold backward, not fold backward alone). Full record:
`progress/phase1-triage.md`. Fix is non-trivial: `kvE2_sepPosI = [σ0] ⇏ kvE2_sepPos = [σ0]`, so no
one-line subset bridge — Phases 3/4 own it.
- **Goal:** Swap the carrier list from global `kvE2_sepPos` to interior-restricted `kvE2_sepPosI`
  at both fragment-predicate sites, byte-identical, then localize the resulting build breakage.
  This phase front-loads the highest-uncertainty surface: it reveals exactly what Phase 4 must fix.
- **File targets:**
  - `OuterGate.lean:200-203` — `kvE2_sepFragment`: replace `kvE2_sepPos qnf = [σ0]` with
    `kvE2_sepPosI qnf = [σ0]`. Keep the zone side-condition (derivable from `kvE2_sepPosI_zone`,
    retained to minimize churn in destructuring branches).
  - `SharedWitness.lean:10219` — `kvE2_sepFragment_frag`: apply the IDENTICAL edit (byte-for-byte)
    to preserve the `rfl` defeq bridge (OuterGate:223-224). Both below the 341 GATE banner (SW:10210).
- **Tasks:**
  - [x] Apply the swap at both sites, byte-identical.
  - [x] Run `lake build` (targeted: the NfMultiAnchorBridge modules); capture the full error set.
  - [x] Confirm the break surface matches the survival audit *(deviation: altered — break surface is
    the fold backward branch AS PREDICTED (SW:12627 `rw [hpos]` failure) PLUS an unpredicted 2-error
    break in `kvE2_sepBody_kit_sound_frag` (SW:12517-20); the gate producers fragL/fragR remain green,
    so the audit is refined not refuted)*.
  - [x] Record the exact erroring decls + line numbers in the progress file for Phase 4 to consume
    *(progress/phase1-triage.md)*.
- **Verification criteria:** `lake build` errors are localized to the fold backward branch (and any
  strictly-downstream consumers of it); NO error in the preserved-asset producers (fragL/fragR/kit).
  If breakage appears in an unexpected decl, STOP and re-audit before proceeding (survival assumption
  violated).
- **Estimated output:** ~40-80 lines (small edit + triage record).
- **Depends on:** none

### Phase 2: Interior-singleton realizability witness lemma [NOT STARTED]
- **Goal:** Prove the new interior-singleton predicate is satisfiable — the non-vacuity ground the
  re-stated theorem (Phase 5) cites. Directly refutes the old VACUITY NOTE.
- **File targets:**
  - `SharedWitness.lean` — add `kvE2_sepFragment_realizable` (or `_nonvacuous`) near the
    `kvE2_sepPosI` block (~SW:245), exhibiting a concrete `qnf : NormalForm sig 2 3` and
    `M : OrderedMonadicStructure sig` with `x < w < t` and exactly ONE strictly-interior realized
    1-type, so `kvE2_sepPosI qnf = [σ0]` holds and the zone side-condition is satisfied.
- **Tasks:**
  - [ ] Construct the witness model from the report's H4 #1 shape (x<w<t; the 3 forced characteristic
    positives at at-point zones zAtX/zAtW/zAtT are excluded by the interior filter; one strictly-interior
    1-type remains).
  - [ ] Discharge against `nf_exists_unique` (NormalForm.lean:276) and `kvE2_sepPosI_mem`/`_zone`.
  - [ ] `lean_verify` the lemma: sorry-free, axiom-clean.
- **Verification criteria:** `lake build` green for the new lemma; `lean_verify kvE2_sepFragment_realizable`
  shows only {propext, Classical.choice, Quot.sound}; no sorry.
- **Estimated output:** ~80-150 lines.
- **Depends on:** 1 (needs the swapped predicate in place)

### Phase 3: hexcl boundary-restriction (R1) + kit/pin survival verification [NOT STARTED]
- **Goal:** Weaken the `hexcl` binder in `kvE2_outer_fold_frag` from `∀ x1 : M.carrier` to the
  interior+boundary cone `x <= x1 <= t` (R1), and confirm the pin/kit producers remain green.
- **File targets:**
  - `SharedWitness.lean` — `kvE2_outer_fold_frag` (:12529) hexcl parameter (~:12543): add the
    `x <= x1` / `x1 <= t` binder guards (mirroring the re-scoped binder that Phase 5 will expose in
    OuterGate:260-265). Do NOT yet repair the backward-branch body — that is Phase 4; this phase only
    changes the SIGNATURE and re-threads it.
  - Verify `kvE2_sepBody_kit_sound_frag` (:12487) and `kvE2_sepGateAtPin_fragL/_fragR` compile
    unchanged (they do not reference the hexcl binder shape).
- **Tasks:**
  - [ ] Restrict the `hexcl` binder to the boundary/interior cone.
  - [ ] Re-thread the restricted `hexcl` through the fold's forward branch (unchanged logic, tighter
    domain — should type-check as-is or with a trivial cone-membership fill).
  - [ ] `lake build`; confirm fragL/fragR/kit_sound are green (Preserved Assets check).
- **Verification criteria:** `hexcl` signature carries the cone restriction; the preserved-asset
  producers build green; the ONLY remaining error is the Phase-1-triaged backward branch (now with a
  tighter, discharargeable exterior domain).
- **Estimated output:** ~60-120 lines.
- **Depends on:** 1

### Phase 4: Fold backward-branch repair for boundary positives [NOT STARTED]
- **Goal (THE main derivation work):** Repair the `kvE2_outer_fold_frag` backward branch so a
  boundary positive `σ` (not equal to the interior `σ0`) is realized via the landed endpoint/witness
  biconditional literals, closing the branch the swap un-vacuated.
- **File targets:**
  - `SharedWitness.lean` — `kvE2_outer_fold_frag` backward branch (the `obtain ⟨σ0, hpos, hzone⟩ := hfrag;
    rw [hpos] at hmem` region; fold body below :12555). With `kvE2_sepPosI qnf = [σ0]`, a positive
    `σ` splits into (i) interior -> `σ = σ0` (served by `hLreal`/`hRreal`, unchanged); (ii)
    boundary -> NOT `σ0`, realized by `kvE2_sepEpL` (:1054) / `kvE2_sepEpR` (:1076) / `kvE2_sepPtW`
    (:1100) under the Phase-3 boundary-restricted `hexcl` admissibility.
- **Tasks:**
  - [ ] Case-split the positive `σ` on interior vs boundary via `kvE2_sepPosI_mem`/`_zone`.
  - [ ] Interior case: reuse the existing `List.mem_singleton` collapse (`σ = σ0`).
  - [ ] Boundary case: realize via the endpoint/witness literals (O4 record SW:6702-6704 six
    biconditional literals), literature-faithful (Rabinovich §5), no `simp`/`omega` bypass.
  - [ ] `lake build`; iterate with `lean_goal` at the branch position.
- **Verification criteria:** `kvE2_outer_fold_frag` is sorry-free and green; `lean_verify` axiom-clean;
  the fold's forward branch and `kvE2_sepBody_kit_sound_frag` remain green. If output exceeds ~300
  lines, split at the LEFT/RIGHT (`_fragL`/`_fragR`) branch boundary into 4.1 / 4.2.
- **Estimated output:** ~150-300 lines (main risk; split if >300).
- **Depends on:** 3 (needs the boundary-restricted `hexcl` admissibility)

### Phase 5: Non-vacuous restatement + VACUITY-NOTE removal [NOT STARTED]
- **Goal:** Re-state `bracketEndChar_kvE2_sound_two_prior_frag` against the repaired predicate and
  the boundary-restricted `hexcl`, and replace both VACUITY NOTEs with NON-VACUITY + deferred-exterior
  notes citing the Phase-2 witness.
- **File targets:**
  - `OuterGate.lean:245` — `bracketEndChar_kvE2_sound_two_prior_frag`: the `hfrag` hypothesis now
    carries the interior-singleton predicate; restrict the `hexcl` binder (currently :260-265,
    `∀ x1 : M.carrier`) to the cone `x <= x1 <= t` matching the Phase-3 fold signature. The derivation
    body (:268-273: `rw [bracketEndChar_kvE2_two_eq]; exact kvE2_outer_fold_frag …`) is unchanged
    modulo the repaired backward branch — a genuine proof from its hypotheses.
  - `OuterGate.lean:192-199` and `:236-244` — replace both VACUITY NOTEs with a NON-VACUITY note
    citing `kvE2_sepFragment_realizable` (Phase 2) and stating the deferred-exterior scope.
- **Tasks:**
  - [ ] Update the theorem signature (repaired `hfrag` predicate + cone-restricted `hexcl`).
  - [ ] Confirm the body type-checks via the repaired fold.
  - [ ] Remove/replace both VACUITY NOTEs with NON-VACUITY + deferred-exterior text.
  - [ ] `lake build`; `lean_verify bracketEndChar_kvE2_sound_two_prior_frag` axiom-clean.
- **Verification criteria:** Theorem green and non-vacuous (premise set satisfiable by the Phase-2
  witness); both VACUITY NOTEs gone; axiom-clean; no sorry.
- **Estimated output:** ~80-150 lines.
- **Depends on:** 2, 4

### Phase 6: Handoff — sorry inventory, consumer notes, deferred-successor documentation [NOT STARTED]
- **Goal:** Final verification and handoff: full-project build, sorry inventory, consumer impact
  notes, and explicit documentation of the deferred Prop-4.3 exterior-completeness successor.
- **File targets:**
  - Full-project `lake build`; `lean_verify` on the three touched theorems.
  - Documentation (in the implementation summary, and as a note at OuterGate:245 if concise):
    consumer impact + successor recommendation.
- **Tasks:**
  - [ ] Full `lake build` green; axiom audit {propext, Classical.choice, Quot.sound} on
    `kvE2_sepFragment_realizable`, `kvE2_outer_fold_frag`, `bracketEndChar_kvE2_sound_two_prior_frag`.
  - [ ] Sorry inventory: confirm ZERO sorries on live paths (the exterior gap is quarantined by
    binder restriction, not a sorry).
  - [ ] Consumer impact notes: **task 309** Phases 13.4/14 + `KampPrior.lean:351` strategic sorry
    now consume the interior+boundary gate (they must NOT expect a full-exterior hexcl-free gate);
    **task 335** Phase D assembles the interior+boundary-scoped correct gate. Document the exact new
    `hexcl` cone binder they must supply.
  - [ ] **Deferred-successor documentation** (explicit follow-up, NOT attempted here): full-exterior
    completeness requires the navigated Prop-4.3 re-flatten (`Prop43.lean`, currently BLOCKED on the
    uniform-negation connective cases, :120-159). Recommend the orchestrator/user `/spawn` a
    successor task "prop43_exterior_completeness" carrying: (a) the full-exterior `hexcl` obligation
    over all `x1`, (b) the `Prop43.lean` uniform-negation blocker as its entry problem, (c) 330
    report 01 + 335 report 07 as grounding. This is a distinct major effort, out of 346 scope.
- **Verification criteria:** Full build green; zero live-path sorries; consumer + successor notes
  written; the exterior residue is unambiguously quarantined and its successor named.
- **Estimated output:** ~40-80 lines (verification + notes; no new proof work).
- **Depends on:** 5

## Testing & Validation

- [ ] `lake build` green after each phase (targeted per phase; full project at Phase 6).
- [ ] `lean_verify` axiom-clean {propext, Classical.choice, Quot.sound} on all three touched theorems.
- [ ] Zero sorries on live paths (grep + `lean_verify`).
- [ ] Preserved-asset producers (fragL/fragR/kit_sound/clause (v)/completeness half/provider bridge)
  build unchanged.
- [ ] `kvE2_sepFragment` and `kvE2_sepFragment_frag` bodies are byte-identical (rfl defeq bridge).
- [ ] Realizability witness demonstrates premise-set satisfiability (non-vacuity).

## Artifacts & Outputs

- plans/01_successor-carrier-redefinition.md (this file)
- summaries/01_successor-carrier-redefinition-summary.md (at completion)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`,
  `.../SharedWitness.lean` (only below the SW:10210 341 GATE banner + the new witness lemma).

## Rollback/Contingency

- Each phase is an atomic green commit; revert the phase commit to roll back.
- If Phase 2 (realizability witness) proves impossible, this refutes the RE-SCOPE verdict — HARD STOP,
  escalate to user; do NOT substitute a vacuous/`True` placeholder.
- If Phase 4 (fold repair) cannot close the boundary case within budget, mark the phase [BLOCKED],
  document the goal state reached, and escalate — do NOT leave a sorry on the live path or weaken the
  predicate to hide the gap.
- The carrier internals (above SW:10210) are never touched, so no rollback risk to the frozen gate.
