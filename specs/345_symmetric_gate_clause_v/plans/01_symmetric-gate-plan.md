# Implementation Plan: Symmetrize kvE2_sepGate with RIGHT inner-consistency clause (v)

- **Task**: 345 - symmetric_gate_clause_v
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: 344 (landed `_frag` fold chain and `kvE2_sep_zone4_consistentR`)
- **Research Inputs**: specs/345_symmetric_gate_clause_v/reports/01_literature-fidelity-gate-design.md
- **Artifacts**: plans/01_symmetric-gate-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Make `kvE2_sepGate` symmetric per Rabinovich 2014 Cor 5.4(1)/(2) mirror pair (PDF p.9) by adding
clause (v) — the zWT3 (RIGHT-owner) mirror of the landed zXW3 clause (iv) — to the gate
definition in `SharedWitness.lean` (~L1244–1246). Clause (v) turns the task-344 `hInnerR`
hypothesis from a free, LEFT-unsatisfiable premise into a **gate consequence**, so it is then
*removed* (not guarded) from the three landed 344 `_frag` lemmas, unblocking the 335 outer fold.
Definition of done: full `lake build` green, axiom-clean `{propext, Classical.choice, Quot.sound}`
on the gate, `holds_of_honest`, and the three simplified `_frag` lemmas; zero sorries on live
paths; SharedWitness.lean byte-identical outside the sanctioned exception surface.

### Research Integration

The literature-fidelity report (reports/01) supplies the ground truth this plan transcribes:
- **Verdict R1-faithful** (report Executive verdict): the mirror clause (v) is required by the
  paper's uniform point-type consistency (Prop 3.5, p.5; Lemma 5.1, p.7) and its explicit mirror
  fold (Cor 5.4(1)/(2), p.9). Rabinovich is cited by PDF page only.
- **Exact clause (v) text** (report "Faithful gate shape — exact clause text", L72–85) is
  transcribed verbatim in Phase 1.
- **Discharge recipe** (report L87–93): byte-mirror the clause-(iv) discharge (SW:2706–2726) via
  the landed `kvE2_sep_zone4_consistentR` (SW:11309); a RIGHT honest bundle
  (`kvE2_sepHonestBundleR`, mirror of `kvE2_sepHonestBundleL` at SW:2739) may be added as closer.
- **Impact list** (report L104–119): only the gate def, `kvE2_sepGate_holds_of_honest`, and the
  three `_frag` lemmas change; all other gate consumers are inert (receive clause (v) as an extra
  hypothesis with no obligation). `hInnerR` is confirmed LEFT-unsatisfiable (Q3), so removal — not
  guarding — is the correct repair.

### Prior Plan Reference

No prior plan. This is the first plan for task 345 (spawned from 335 R1 decision).

### Roadmap Alignment

No ROADMAP.md consultation was requested (`roadmap_flag` not set). This task advances the 335
outer-gate assembly line by dissolving the 344 `hInnerR` blocker; 335 Phases B–D resume with
discharge obligations reduced to `{hcorrK, hexcl}`, and 341's GATE-phase re-diff absorbs the
SharedWitness delta.

## Goals & Non-Goals

**Goals**:
- Add clause (v) (zWT3 RIGHT mirror of clause iv) to `kvE2_sepGate` (SW:1238, clause at ~1244).
- Discharge the resulting obligation in the sole gate constructor `kvE2_sepGate_holds_of_honest`
  (SW:2666) via the RIGHT mirror of the clause-(iv) discharge and `kvE2_sep_zone4_consistentR`.
- Remove the `hInnerR` parameter from `kvE2_sepGateAtPin_fragR`, `kvE2_sepBody_kit_sound_frag`,
  and `kvE2_outer_fold_frag`, deriving RIGHT inner-consistency internally from `hg` clause (v).
- Keep full `lake build` green and axiom-clean at every green milestone; incremental commits.
- Leave `kvE2_outer_fold_frag` taking only `hfrag`/`hcorrK`/`hexcl` — no `hInnerR` obligation.

**Non-Goals**:
- No change to any declaration in SharedWitness.lean outside the sanctioned surface (gate def,
  `holds_of_honest`, the three `_frag` lemmas, plus any *newly added* helper such as
  `kvE2_sepHonestBundleR`). Existing declarations must remain byte-identical.
- No edits to OuterGate.lean or any other module (335 keeps OuterGate; 341 re-diffs GATE phase).
- No new axioms, no `sorry` on live paths, no refactor of clause (iv) or the LEFT geometry.
- No change to gate consumers, decision sites (SW:2332 `dite`, SW:2361 `¬gate`) — verify inert.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| RIGHT honest closer for clause (v) proves harder than the L mirror suggests | H | L | Report flags this as the one Medium-confidence item; the RIGHT classifier `kvE2_sep_zone4_consistentR` is already landed and machine-checked. If the direct byte-mirror stalls, run a dedicated GO/NO-GO probe on the clause-(v) discharge (report Zero-debt note) — never a placeholder sorry. |
| Build breaks at every gate constructor between adding clause (v) and discharging it | M | H (expected) | This is anticipated: clause (v) adds an unmet conjunct until `holds_of_honest` closes it. Phase 1 lands the gate def and the discharge in a single dispatch; the first green commit is the gate+honest pair, not the def alone. |
| A gate consumer turns out non-inert (needs clause v handling) | M | L | Report Impact list + adversarial verification say all 8 consumer sites (`hg :` at SW:5901,6362,6669,6680,8435,9647,10402,11558) are additive/inert. Phase 4 re-verifies at build level, not just by reading. |
| Freeze violation: an unintended edit to a frozen declaration | M | L | Phase 4 includes a `git diff` verification item confirming only the sanctioned surface changed (existing declarations byte-identical; only additive new helpers permitted). |
| `hInnerR` removal misses a threading site | M | L | Report pinpoints the exact param lines (SW:11544, 12476, 12520) and pass-through (SW:12495); Phases 2–3 target them explicitly and rebuild after each. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
depends on a green build from the prior phase.

---

### Phase 1: Add clause (v) and discharge holds_of_honest [COMPLETED]

**Deviations (recorded per H7 consumer-sweep contract)**:
- *Relocation (forced by forward-reference)*: `kvE2_sepInnerConsistentR` (def) and
  `kvE2_sep_zone4_consistentR` (theorem) were defined ~L11295/11309, BELOW the gate (L1238)
  and `holds_of_honest` (L2666) that now reference them. Both were moved verbatim (byte-identical
  bodies) to just above the gate doc / above `holds_of_honest`. No body change.
- *Two consumer projection shifts (minimal)*: appending clause (v) makes clause (iv) the
  penultimate conjunct, so its positional projection `hg.2.2.2` shifts to `hg.2.2.2.1` at
  exactly two sites: `kvE2_sepHgate_innerNine` and `kvE2_sepGateAtPin_fragL`. One-token edits;
  no signature change. All other consumers (which use `hg.2.2.1` clause iii or take `hg` opaquely)
  compiled unmodified.
- *Closer*: clause (v) discharged directly via the landed `kvE2_sep_zone4_consistentR` +
  the depth-1 fold `h_zone` iff (no new `kvE2_sepHonestBundleR` closer needed).

**Goal**: Land the symmetric gate. Add clause (v) to `kvE2_sepGate` and discharge the new
obligation in the sole gate constructor in one dispatch, since the build breaks at every gate
constructor until the discharge lands. The first green commit is the gate+honest pair.

**Tasks**:
- [ ] Add clause (v) to `kvE2_sepGate` (SharedWitness.lean:1238; new conjunct after clause iv at
      ~L1246), transcribing the report's exact text (report L82–84): the zWT3 mirror keying on
      `nf0_zoneSpec σ.1 = kvE2_sep_zWT3` and `¬ kvE2_sepInnerConsistentR zs`.
- [ ] In `kvE2_sepGate_holds_of_honest` (SW:2666), add the `refine` goal for clause (v) and close
      it as the byte-mirror of the clause-(iv) discharge (SW:2706–2726): extract `x1` with
      `x < w < x1 < t` from the RIGHT-owner `hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, read the
      RIGHT order bits, and close the marked-bit `¬consistentR` case by contradiction via the
      landed `kvE2_sep_zone4_consistentR` (SW:11309).
- [ ] If the closer needs it, add `kvE2_sepHonestBundleR` (mirror of `kvE2_sepHonestBundleL`,
      SW:2739) as a new additive helper — permitted because it does not modify any existing
      declaration.
- [ ] `lake build` the module green; run axiom check on `kvE2_sepGate` and
      `kvE2_sepGate_holds_of_honest` (must be `{propext, Classical.choice, Quot.sound}`).
- [ ] Commit: `task 345 phase 1: add clause (v) + discharge holds_of_honest`.

**Timing**: ~1.5 hours (~150–300 lines).

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — gate
  def (+1 conjunct), `kvE2_sepGate_holds_of_honest` (+1 discharge goal), optional new
  `kvE2_sepHonestBundleR`.

**Verification**:
- `lake build` green.
- `lean_verify kvE2_sepGate` and `lean_verify kvE2_sepGate_holds_of_honest` show only the three
  sanctioned axioms; no `sorryAx`.

---

### Phase 2: Remove hInnerR from kvE2_sepGateAtPin_fragR [COMPLETED]

*Note: committed jointly with Phase 3 — removing fragR's `hInnerR` param immediately breaks its
caller `kit_sound_frag`, so the tree is only green once all three removals land together
(sanctioned "one commit for all three if natural" path).*


**Goal**: Drop the `hInnerR` parameter from `kvE2_sepGateAtPin_fragR` (SW:11525), deriving the
bit→`consistentR` direction from `hg` clause (v) at the existing `by_cases hg` (SW:11558). Mirror
how fragL recovers LEFT inner-consistency from `hg` clause (iv).

**Tasks**:
- [ ] Remove the `hInnerR` param at SW:11544 from `kvE2_sepGateAtPin_fragR`.
- [ ] In the RIGHT branch under the existing `by_cases hg` (SW:11558), obtain RIGHT
      inner-consistency from `hg`'s clause (v) — the `hg.2.2.2…` projection mirroring fragL's
      clause-(iv) usage.
- [ ] `lake build` green; axiom check `kvE2_sepGateAtPin_fragR`.
- [ ] Commit: `task 345 phase 2: drop hInnerR from kvE2_sepGateAtPin_fragR`.

**Timing**: ~1 hour (~100–200 lines).

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` —
  `kvE2_sepGateAtPin_fragR` signature and body.

**Verification**:
- `lake build` green.
- `kvE2_sepGateAtPin_fragR` no longer lists `hInnerR`; `lean_verify` axiom-clean.

---

### Phase 3: Thread the removal through kit_sound_frag and outer_fold_frag [COMPLETED]

**Goal**: Propagate the `hInnerR` removal up the fold chain. Drop the param from
`kvE2_sepBody_kit_sound_frag` (SW:12459, param at :12476) and `kvE2_outer_fold_frag` (SW:12502,
param at :12520), and remove the RIGHT-branch pass-through (SW:12495). `kvE2_outer_fold_frag`
must end taking only `hfrag`/`hcorrK`/`hexcl`.

**Tasks**:
- [ ] Remove `hInnerR` param from `kvE2_sepBody_kit_sound_frag` (SW:12476); the RIGHT branch
      (SW:12494–12495) no longer threads it into `kvE2_sepGateAtPin_fragR`.
- [ ] Remove `hInnerR` param from `kvE2_outer_fold_frag` (SW:12520); it is now a gate consequence
      inside the fold.
- [ ] Confirm `kvE2_outer_fold_frag`'s remaining signature is exactly `hfrag`/`hcorrK`/`hexcl`.
- [ ] `lake build` green; axiom check both lemmas.
- [ ] Commit: `task 345 phase 3: drop hInnerR from kit_sound_frag + outer_fold_frag`.

**Timing**: ~1 hour (~80–150 lines).

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` —
  `kvE2_sepBody_kit_sound_frag` and `kvE2_outer_fold_frag` signatures/bodies.

**Verification**:
- `lake build` green.
- `kvE2_outer_fold_frag` takes only `hfrag`/`hcorrK`/`hexcl`; both lemmas axiom-clean.

---

### Phase 4: Consumer sweep, freeze-diff, axiom check, 335 handback [NOT STARTED]

**Goal**: Verify the freeze exception held and the change is inert everywhere else. Full-build
green, axiom check on all four sanctioned identifiers, confirm gate consumers compiled unmodified,
and record the 335 handback (obligations now `{hcorrK, hexcl}`).

**Tasks**:
- [ ] Full `lake build` green across the project (not just the module).
- [ ] Verify all other `kvE2_sepGate` consumers (`hg :` at SW:5901,6362,6669,6680,8435,9647,
      10402,11558) and decision sites (SW:2332 `dite`, SW:2361 `¬gate`) compiled with **no**
      source change (inert, per report Impact list).
- [ ] Freeze-diff: `git diff` SharedWitness.lean and confirm the only modified existing
      declarations are the gate def, `kvE2_sepGate_holds_of_honest`, and the three `_frag`
      lemmas; any other change is additive (new helpers only). No existing declaration outside
      the sanctioned surface is byte-altered.
- [ ] Axiom check `kvE2_sepGate`, `kvE2_sepGate_holds_of_honest`, `kvE2_sepGateAtPin_fragR`,
      `kvE2_sepBody_kit_sound_frag`, `kvE2_outer_fold_frag` — all `{propext, Classical.choice,
      Quot.sound}`, zero `sorryAx` on live paths.
- [ ] Record the 335 handback: `kvE2_outer_fold_frag` is consumable with `hcorrK`
      (ExistProviders.correct) and `hexcl` (335 Phase-C GO/NO-GO probe); no `hInnerR` remains.
- [ ] Commit: `task 345 phase 4: consumer sweep + freeze-diff + 335 handback`.

**Timing**: ~1 hour.

**Depends on**: 3

**Files to modify**:
- None expected (verification-only). Any edit here would signal a non-inert consumer to
  investigate before proceeding.

**Verification**:
- Full `lake build` green.
- `git diff --stat` shows SharedWitness.lean as the only touched `.lean` file.
- All five identifiers axiom-clean; handback state recorded.

## Testing & Validation

- [ ] Full `lake build` succeeds with no errors or warnings on live paths.
- [ ] `lean_verify` on the five sanctioned identifiers returns exactly `{propext,
      Classical.choice, Quot.sound}` (no `sorryAx`, no extra axioms).
- [ ] Clause (v) text matches the report's exact transcription (report L82–84).
- [ ] `kvE2_outer_fold_frag` final signature is `hfrag`/`hcorrK`/`hexcl` only.
- [ ] `git diff` confirms the SharedWitness freeze exception surface (existing declarations
      byte-identical outside gate def, `holds_of_honest`, three `_frag` lemmas).

## Artifacts & Outputs

- specs/345_symmetric_gate_clause_v/plans/01_symmetric-gate-plan.md (this plan)
- specs/345_symmetric_gate_clause_v/summaries/01_symmetric-gate-summary.md (on completion)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- Incremental commits: `task 345 phase {P}: {name}` with `Session: sess_1783723095_edd5a7_345`.

## Rollback/Contingency

Each phase is an isolated green commit. If a later phase fails to build, `git revert` (or reset to
the last green commit — never discard uncommitted work per git-workflow.md) restores the prior
green state; SharedWitness.lean is the single touched file. If the Phase 1 RIGHT honest closer
stalls, run a dedicated GO/NO-GO probe on the clause-(v) discharge (report Zero-debt note) rather
than deferring with a sorry; the RIGHT classifier `kvE2_sep_zone4_consistentR` is already landed,
so the discharge channel is sound. No axiom introduction or sorry-deferral is sanctioned on live
paths.
