# Implementation Plan: Task #336 — Generalize `kvE2_sepBody_complete` to Right-Interior Owners

- **Task**: 336 - Generalize `kvE2_sepBody_complete` (⇐ / completeness half of Rabinovich Lemma 3.2(1)) from left-interior positive owners to right-interior owners
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: 334 (COMPLETED — faithful carrier re-grounding, provides the landed `kvE2_sepCoincidentAnchor_discharge_R`)
- **Research Inputs**: specs/336_generalize_completeness_right_interior_zAtX1R/reports/01_generalize-completeness-right-interior.md
- **Artifacts**: plans/01_generalize-completeness-right-interior.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Generalize the completeness (⇐) half of Rabinovich Lemma 3.2(1) so the coincident-owner
validity predicate covers **both** left-interior (`zXW3`, self-zone `zAtX1L`) and right-interior
(`zWT3`, self-zone `zAtX1R`) positive owners, instead of only the left class. All the genuine
model mathematics — the right coincidence discharge `kvE2_sepCoincidentAnchor_discharge_R`
(SharedWitness.lean:1493) — is already landed sorry-free and `lean_verify`-confirmed axiom-clean.
The remaining work is bounded: (1) make `kvE2_sepClosedLeafStub` read the placement-appropriate
closed self-zone bit via an `if nf0_zoneSpec σ.1 = kvE2_sep_zXW3` guard; (2) add one mechanical
mirror lemma `kvE2_sepCoincidentOwner_valid_right` (~25-35 lines); (3) relax
`kvE2_sepBody_complete`'s hypothesis from left-only `hL` to a left-OR-right disjunction `hLR`
with a per-owner case split.

**Definition of done**: `kvE2_sepBody_complete` accepts `hLR` (left ∨ right interior) and
proves `kvE2_sepArr' qnf ≠ []`; the module builds; and `kvE2_sepBody_complete`,
`kvE2_sepBody_nonvacuous`, and `kvE2_sepArr'_sound` all remain axiom-clean
`[propext, Classical.choice, Quot.sound]` with **no** `sorryAx`.

### Deliverable is `hL` → `hLR`, NOT unconditional

The deliverable is explicitly the **`hL` → `hLR`** generalization: from
`∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3` (left-only) to
`∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3`
(left ∨ right interior). The interior hypothesis **cannot be dropped entirely**: `kvE2_sepPos`
admits seven outer zone classes (`kvE2_sepOuterConsistent`, :631-633) and there is **no
dichotomy lemma** proving positive owners are always interior. A fully unconditional completeness
theorem covering exterior/boundary owners would require new mathematics (coincidence handling for
the five non-interior classes) and is out of scope. The exterior-owner gap must remain exactly as
a live hypothesis obligation — **no `sorry` and no new axiom may be introduced to paper over it.**

### Research Integration

Report `01_generalize-completeness-right-interior.md` grounds every claim in source reads plus
`lean_verify`:
- `zAtX1L` hardcode site: `kvE2_sepClosedLeafStub` (:726-728); `.coincident` branch of
  `kvE2_sepDisjValidOwner` (:737) delegates to it.
- Zone specs: `kvE2_sep_zAtX1L` (:114, left `x < x1 < w`), `kvE2_sep_zAtX1R` (:123, right
  `w < x1 < t`).
- Landed, axiom-clean core: `kvE2_sepCoincidentAnchor_discharge_R` (:1493-1514),
  `kvE2_sepBody_complete` (:1531-1546), `kvE2_sepBody_nonvacuous` (:1382-1401).
- Mirror source for the new lemma: `kvE2_sepCoincidentOwner_valid_left` (:1450-1481); bound-
  extraction pattern to reuse: `kvE2_sepHonestBundleR` (:1259-1301, `hbit_wx1`/`hbit_x1t` →
  `hwx1`/`hx1t` at :1275-1286).
- `if_neg` idiom + disequality lemma: `kvE2_sep_zWT3_ne_zXW3` (:1746), applied at :2513.
- `nonvacuous` is immune: it concerns `kvE2_sepModelOrder` (strict OPEN branches) and takes
  `hvalid` as a hypothesis; `kvE2_sepArr'_sound` (:2536-2543) is definition-agnostic and upgrades
  for free.
- Do-not-touch sibling: the Phase-1 "spike" cluster `kvE2_sepSpikeDisjValid` (:2278-2283) also
  hardcodes `zAtX1L` but is a separate predicate over a foreign `χ` — leave it alone.

### Prior Plan Reference

No prior plan for task 336.

### Roadmap Alignment

No `roadmap_path` provided to this planning run; no ROADMAP.md consultation performed. Task 336
advances the `kamp_theorem_formalization` topic (Rabinovich Lemma 3.2(1) completeness).

## Goals & Non-Goals

**Goals**:
- Make `kvE2_sepClosedLeafStub` placement-generic: left-interior owners read `zAtX1L`, right-
  interior owners read `zAtX1R`, via an `if nf0_zoneSpec σ.1 = kvE2_sep_zXW3` guard matching the
  established codebase pattern.
- Add `kvE2_sepCoincidentOwner_valid_right` as a mechanical mirror of `_valid_left`, routing the
  landed `kvE2_sepCoincidentAnchor_discharge_R`.
- Relax `kvE2_sepBody_complete`'s `hL` to `hLR` (left ∨ right interior) with a per-owner
  `cases` split dispatching to `_valid_left` / `_valid_right`.
- Preserve axiom-cleanliness `[propext, Classical.choice, Quot.sound]` (no `sorryAx`) of
  `kvE2_sepBody_complete`, `kvE2_sepBody_nonvacuous`, and `kvE2_sepArr'_sound`.
- Preserve all 7 faithfulness invariants, in particular F5 (closed vs open key discrimination):
  both `if` branches read CLOSED self-zone keys, never OPEN keys.

**Non-Goals**:
- Dropping the interior hypothesis entirely (unconditional completeness over all 7 outer zone
  classes) — out of scope; would require new mathematics.
- Any `sorry` or new axiom to bridge the exterior/boundary-owner gap — forbidden. If positive
  owners turn out not to be provably interior in a context the change needs, mark the task
  [BLOCKED] rather than defer with `sorry`.
- Touching the independent Phase-1 spike cluster (`kvE2_sepSpikeDisjValid` :2278-2283,
  `kvE2_sepCompat_zAtX1L_eq` :2378) or any OPEN-branch strict-order predicates.
- Changing `kvE2_sepBody_nonvacuous`'s statement or proof (it is definition-agnostic).
- The `||`-of-both-bits alternative (§4 of report) — rejected as a faithfulness risk; use the
  `if`-guard.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Adding `if nf0_zoneSpec σ.1 = …` forces `kvE2_sepClosedLeafStub` to become `noncomputable`, rippling to `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` | L | M | Harmless: `kvE2_sepArr'` is already `noncomputable`; `kvE2_sepArr'_decidable` (:753) decides `… = true` on a `Bool` regardless. Add `noncomputable` where the build requests it; the same `if` guard already compiles in sibling `noncomputable def`s. |
| Axiom regression (a `decide`/order step drags in an unexpected axiom, or `sorryAx` leaks) | H | L | Compose only the landed axiom-clean `discharge_R` with pure order facts; run `lean_verify` on all three theorems in Phase 4 and fail the phase on any deviation from `[propext, Classical.choice, Quot.sound]` or any `sorryAx`. |
| F5 faithfulness violation (an owner accepted via a bit not appropriate to its placement) | H | L | Use the `if`-guard (not `||`): each placement reads exactly its own closed self-zone bit. Both branches read CLOSED keys — verify no OPEN key appears in the guarded stub. |
| Exterior-owner gap tempts a `sorry`/axiom shortcut | H | L | Deliverable is `hLR` (guarded), NOT unconditional; the gap stays a live hypothesis. Any inability to satisfy `hLR` in a needed context → [BLOCKED], never `sorry`. |
| `if_neg` idiom mismatch in `_valid_right` | L | M | Reuse the exact idiom already at :2513: `rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h))]`. |
| Accidentally editing the do-not-touch spike sibling | M | L | Scope edits to `kvE2_sepClosedLeafStub`, `kvE2_sepCoincidentOwner_valid_left`, the new `_valid_right`, and `kvE2_sepBody_complete`. Leave `kvE2_sepSpikeDisjValid`/`kvE2_sepCompat_zAtX1L_eq` untouched. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
edits or depends on the same single-theorem chain and closes at a green (build-passing)
checkpoint suitable for a per-phase commit.

### Phase 1: Placement-generic `kvE2_sepClosedLeafStub` + patch `_valid_left` [COMPLETED]

**Goal**: Make the coincident closed-self-zone bit read `zAtX1L` for left-interior owners and
`zAtX1R` for right-interior owners, while keeping `kvE2_sepBody_complete` (still with `hL`) and
`_valid_left` green.

**Tasks**:
- [ ] Rewrite `kvE2_sepClosedLeafStub` (:726-728) with the guard:
      `if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1) else kvE2_sepBits σ kvE2_sep_zAtX1R (nf0_projFresh σ.1)`.
- [ ] If the build requests it, add `noncomputable` to `kvE2_sepClosedLeafStub` and propagate to
      `kvE2_sepDisjValidOwner` (:733) and `kvE2_sepDisjValid` (:742). Confirm `kvE2_sepArr'_decidable`
      (:753) is unaffected.
- [ ] Patch `kvE2_sepCoincidentOwner_valid_left` (:1480): after `rw [kvE2_sepClosedLeafStub]`,
      add `rw [if_pos hzone]` (reduces the `if` to the left branch under `hzone : … = zXW3`); the
      existing `kvE2_sepCoincidentAnchor_discharge …` line then closes the goal unchanged.
- [ ] Confirm F5 holds: both branches read CLOSED self-zone keys (`zAtX1L`/`zAtX1R`), no OPEN key.
- [ ] `lake build` the module (or `lean_verify kvE2_sepCoincidentOwner_valid_left`); confirm green.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` —
  rewrite `kvE2_sepClosedLeafStub` (:726-728); patch `_valid_left` (:1480); optionally add
  `noncomputable` to the stub / `kvE2_sepDisjValidOwner` / `kvE2_sepDisjValid`.

**Verification**:
- Module builds green (`kvE2_sepBody_complete` still uses `hL`, still compiles).
- `kvE2_sepCoincidentOwner_valid_left` proves with the added `rw [if_pos hzone]`.
- Both `if` branches read CLOSED keys (F5 preserved).

---

### Phase 2: Add `kvE2_sepCoincidentOwner_valid_right` mirror lemma [COMPLETED]

**Goal**: Add the right-interior per-owner validator as a mechanical mirror of `_valid_left`,
routing the landed `kvE2_sepCoincidentAnchor_discharge_R`.

**Tasks**:
- [ ] Add `kvE2_sepCoincidentOwner_valid_right` (mirror of `_valid_left` :1450-1481) taking
      `hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3`.
- [ ] Extract right-interior bounds `w < x1 < t` using the pattern in `kvE2_sepHonestBundleR`
      (:1275-1286: `hbit_wx1`/`hbit_x1t` → `hwx1`/`hx1t`), and obtain
      `hfresh : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`.
- [x] After `rw [kvE2_sepClosedLeafStub]`, select the right branch with
      `rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h))]` (exact idiom at :2513),
      then `exact kvE2_sepCoincidentAnchor_discharge_R …`. *(deviation: altered — the private
      `kvE2_sep_zWT3_ne_zXW3` was declared LATER in the file than the new `_valid_right` lemma, so
      it was moved up to just before `kvE2_sepClosedLeafStub` to be in scope; it remains in scope
      for its original later use site. Also used `hcon` instead of shadowing name `h`.)*
- [ ] `lean_verify kvE2_sepCoincidentOwner_valid_right`; confirm sorry-free and
      `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepCoincidentOwner_valid_right` adjacent to `_valid_left`.

**Verification**:
- New lemma builds green and is sorry-free.
- `lean_verify` shows `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.

---

### Phase 3: Relax `kvE2_sepBody_complete` `hL` → `hLR` with per-owner case split [COMPLETED]

**Goal**: Change the completeness theorem's hypothesis to the left-OR-right disjunction and
dispatch each owner to the placement-appropriate validator.

**Tasks**:
- [ ] Change the hypothesis of `kvE2_sepBody_complete` (:1531-1546) from
      `hL : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3` to
      `hLR : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3`.
- [ ] Replace the final line `exact kvE2_sepCoincidentOwner_valid_left … (hL σ hσmem)` with
      `cases (hLR σ hσmem) with` (or `rcases`) dispatching:
      left disjunct → `kvE2_sepCoincidentOwner_valid_left … hzone`;
      right disjunct → `kvE2_sepCoincidentOwner_valid_right … hzone`.
- [ ] Leave everything else in the proof unchanged (membership of the coincidence order in the
      enumeration and the filter unpacking are placement-generic).
- [ ] Confirm the exterior-owner gap remains a live hypothesis obligation — **no `sorry`, no new
      axiom** introduced anywhere. If `hLR` cannot be discharged in a needed downstream context,
      STOP and mark the task [BLOCKED]; do not defer with `sorry`.

**Timing**: 0.5 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — relax
  `hL` → `hLR` and add the per-owner `cases` in `kvE2_sepBody_complete` (:1531-1546).

**Verification**:
- `kvE2_sepBody_complete` builds green with `hLR` and the per-owner split.
- No `sorry`/axiom added for the exterior-owner gap.

---

### Phase 4: Full build + axiom-cleanliness verification [COMPLETED]

**Goal**: Prove the deliverable's invariants hold across the whole module.

**Tasks**:
- [ ] `lake build` the `SharedWitness.lean` module; confirm no errors/warnings introduced.
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kvE2_sepBody_complete` →
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] `lean_verify … kvE2_sepBody_nonvacuous` → `[propext, Classical.choice, Quot.sound]`, no
      `sorryAx` (should be unchanged — it is definition-agnostic).
- [ ] `lean_verify … kvE2_sepArr'_sound` → `[propext, Classical.choice, Quot.sound]`, no
      `sorryAx` (auto-upgrades to carry the right closed bit).
- [ ] Confirm the 7 faithfulness invariants are preserved (F5 in particular: closed-key
      discrimination), and that the do-not-touch spike sibling was not modified.

**Timing**: 0.5 hour

**Depends on**: 3

**Files to modify**:
- None (verification only). Fix-forward into the relevant phase if a check fails.

**Verification**:
- Module builds green.
- All three theorems `[propext, Classical.choice, Quot.sound]`, zero `sorryAx`.
- Faithfulness invariants intact; spike cluster untouched.

## Testing & Validation

- [ ] `lake build` of `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` passes with no new errors/warnings.
- [ ] `kvE2_sepBody_complete` compiles with hypothesis `hLR` (left ∨ right interior) and proves `kvE2_sepArr' qnf ≠ []`.
- [ ] `kvE2_sepCoincidentOwner_valid_right` is sorry-free and axiom-clean.
- [ ] `lean_verify` on `kvE2_sepBody_complete`, `kvE2_sepBody_nonvacuous`, `kvE2_sepArr'_sound` each yields exactly `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.
- [ ] No `sorry` and no new axiom anywhere in the diff (grep the diff for `sorry`/`axiom`).
- [ ] F5 preserved: both `if` branches of `kvE2_sepClosedLeafStub` read CLOSED self-zone keys.
- [ ] `kvE2_sepSpikeDisjValid`/`kvE2_sepCompat_zAtX1L_eq` (spike cluster) unchanged.

## Artifacts & Outputs

- plans/01_generalize-completeness-right-interior.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (guarded `kvE2_sepClosedLeafStub`; new `kvE2_sepCoincidentOwner_valid_right`; patched
  `_valid_left`; relaxed `kvE2_sepBody_complete` `hL` → `hLR`)
- summaries/01_generalize-completeness-right-interior-summary.md (on completion)

## Rollback/Contingency

- All changes are confined to a single file. If any phase fails to reach green, fix forward
  within that phase; never discard uncommitted work to reach a passing build.
- Each phase closes at a green, independently committable checkpoint, so a failed later phase
  leaves the earlier green commits intact.
- If the exterior-owner gap makes `hLR` undischargeable in a required downstream context, do NOT
  introduce `sorry`/axiom: mark the task [BLOCKED] with the specific obligation, preserve the
  green work from earlier phases, and hand back for re-scoping.
- Full revert path: `git checkout` of the single modified `SharedWitness.lean` restores the
  pre-task left-only `hL` completeness theorem.
