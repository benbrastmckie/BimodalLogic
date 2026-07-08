# Implementation Summary: Task #336 — Generalize `kvE2_sepBody_complete` to Right-Interior Owners

- **Task**: 336 (lean4) — Generalize the completeness (⇐) half of Rabinovich Lemma 3.2(1) from
  left-interior positive owners (`hL`) to left-OR-right interior owners (`hLR`).
- **Status**: COMPLETED — all 4 phases green, full project build passes, axiom-clean.
- **Session**: sess_1783546987_0faeae_336
- **File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## Outcome

`kvE2_sepBody_complete` now accepts the honest disjunctive hypothesis

```
hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3
```

(left OR right interior) and proves `kvE2_sepArr' qnf ≠ []`. The interior hypothesis remains a
**live obligation** — the exterior/boundary-owner gap over the remaining five of seven zone
classes is honestly carried, NOT bridged. No `sorry` and no new axiom were introduced.

## Phases

### Phase 1 — Placement-generic `kvE2_sepClosedLeafStub` + patch `_valid_left` [COMPLETED]
Rewrote `kvE2_sepClosedLeafStub` with the guard
`if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then kvE2_sepBits σ zAtX1L … else kvE2_sepBits σ zAtX1R …`.
Patched `kvE2_sepCoincidentOwner_valid_left`'s final rewrite to `rw [kvE2_sepClosedLeafStub, if_pos hzone]`.
No `noncomputable` was required (equality on `ZoneSpec` decides). Module builds green;
`kvE2_sepCoincidentOwner_valid_left` verified `[propext, Classical.choice, Quot.sound]`.

### Phase 2 — Add `kvE2_sepCoincidentOwner_valid_right` mirror lemma [COMPLETED]
Added `kvE2_sepCoincidentOwner_valid_right` (mirror of `_valid_left`) taking
`hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3`. It extracts the right-interior bounds `w < x1 < t`
inline (the `kvE2_sepHonestBundleR` :1259 extraction pattern), obtains
`hfresh : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`, selects the RIGHT (`else`) branch
via `rw [kvE2_sepClosedLeafStub, if_neg (fun hcon => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans hcon))]`,
and closes with the landed `kvE2_sepCoincidentAnchor_discharge_R`. Verified sorry-free and
`[propext, Classical.choice, Quot.sound]`.

### Phase 3 — Relax `hL` → `hLR` with per-owner case split [COMPLETED]
Changed `kvE2_sepBody_complete`'s hypothesis to the `hLR` disjunction and replaced the single
`exact` with an `rcases hLR σ hσmem with hzone | hzone` dispatching LEFT →
`kvE2_sepCoincidentOwner_valid_left`, RIGHT → `kvE2_sepCoincidentOwner_valid_right`. All other
proof steps (enumeration membership, filter unpacking) are placement-generic and unchanged.
Doc comment updated to record the generalization and the honest exterior-owner gap. Verified
`[propext, Classical.choice, Quot.sound]`.

### Phase 4 — Full build + axiom-cleanliness verification [COMPLETED]
- Full `lake build` (1720 jobs) completed successfully.
- `lean_verify` on all three gate targets, each `[propext, Classical.choice, Quot.sound]`, no `sorryAx`:
  - `kvE2_sepBody_complete`
  - `kvE2_sepBody_nonvacuous` (unchanged — definition-agnostic)
  - `kvE2_sepArr'_sound` (auto-upgraded to carry the right closed bit)
- No `sorry`/`admit` tactic, no new `axiom`, no vacuous definitions in the diff.
- F5 preserved: both `if` branches of `kvE2_sepClosedLeafStub` read CLOSED self-zone keys
  (`zAtX1L` / `zAtX1R`); no OPEN key.
- Do-not-touch spike cluster (`kvE2_sepSpikeDisjValid`, `kvE2_sepCompat_zAtX1L_eq`) untouched.

## Verification Results

| Check | Result |
|-------|--------|
| Full `lake build` | PASS (1720 jobs) |
| `kvE2_sepBody_complete` axioms | `[propext, Classical.choice, Quot.sound]` |
| `kvE2_sepBody_nonvacuous` axioms | `[propext, Classical.choice, Quot.sound]` |
| `kvE2_sepArr'_sound` axioms | `[propext, Classical.choice, Quot.sound]` |
| New `sorry` / `axiom` | NONE |
| Vacuous definitions | NONE |
| F5 (closed-key discrimination) | PRESERVED |
| Spike cluster | UNTOUCHED |

## Plan Deviations

- **Phase 2 (altered)**: The private lemma `kvE2_sep_zWT3_ne_zXW3` was originally declared *after*
  the new `kvE2_sepCoincidentOwner_valid_right` insertion point, so it was moved up to just before
  `kvE2_sepClosedLeafStub`. It remains a single declaration in scope for both the new lemma and its
  original later use site (`kvE2_sepSegRForSub'_at_sound`). The `if_neg` closure binder was named
  `hcon` (not `h`) to avoid shadowing the realization hypothesis. No semantic change.

## Notes / Follow-ups

- `OuterGate.lean:28` (task 335's file, out of scope for this task) contains a now-stale prose
  comment describing `kvE2_sepBody_complete` as "LEFT-INTERIOR ONLY". It is a comment, not a call —
  no build impact. A future task touching OuterGate may wish to refresh that note to reflect the
  `hLR` generalization.
- The deliverable is the honest `hL → hLR` generalization. A fully unconditional completeness
  theorem covering the exterior/boundary owner classes remains out of scope and would require new
  coincidence mathematics for those five zone classes.
