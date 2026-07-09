# Task 342 Phase 6 Summary — Tie-admitting validity: conjunct (iii) replacement and tie-class grouping

**Session**: sess_1783617988_38e7cf
**Commit**: `1cb7dde1c` (`task 342 phase 6: tie-admitting validity — conjunct (iii) replacement and tie-class grouping`)
**Status**: Phase 6 [COMPLETED]; full `lake build` green (1720 jobs)
**File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` only (+ plan/handoff artifacts)

## What was done

### Conjunct (iii) replacement (the defect repair)

`kvE2_sepDisjValid` (SW:1767) no longer requires global `Nodup` over the flattened payload
tuples. That conjunct made the Lemma 3.2(1) equality-case order types unrepresentable: honest
base-base slot ties and base-foreign-anchor ties realized NO disjunct at all — a
machine-certified completeness hole. New conjuncts:

- **(iii') `kvE2_sepAnchorDistinct`** (SW:1625): cross-owner ANCHOR payload indices `Nodup`.
  Anchor-anchor ties stay excluded — a Lean-side, `nf_eval_unique`-backed pruning (task-340
  Phase 5A keystone: distinct positive owners provably cannot share a fresh anchor), documented
  as having NO Rabinovich counterpart (audit D7).
- **(iv) `kvE2_sepTieRead`** (SW:1639): every payload tie pairing an anchor slot of owner σa
  with a base slot of type χ (foreign or own) requires `kvE2_sepClosedLeafAt σa χ = true` —
  the anchor owner's CLOSED `zAtX1L`/`zAtX1R` self-zone bit generalized to the foreign base
  type. Base-base ties impose no read. No OPEN key enters any coincident read (F5).

Conjuncts (i)/(ii) kept verbatim; everything stays `Bool`/`decide`-able. Citation discipline
(audited form) observed throughout: forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure
without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13).

### New declarations (all in SharedWitness.lean)

| Declaration | Role |
|---|---|
| `kvE2_sepClosedLeafAt` + `kvE2_sepClosedLeafStub_eq_at` (`rfl`) | CLOSED-key read at a foreign base type; Phase-8 discharge target |
| `kvE2_sepSlotIsAnchor`, `kvE2_sepSlotBaseType`, `_eq_none_of_isAnchor` | slot classifiers |
| `kvE2_sepAnchorSlot`, `_injective`, `kvE2_sepSlotSub_anchorSlot`, `_mem_block` | anchor slot family |
| `kvE2_sepAnchorPayload`, `kvE2_sepAnchorPayload_map` | anchor payload projection (`kvE2_sepBlockPos`/`idxOf`-based) |
| `kvE2_sepAnchorDistinct`, `kvE2_sepTieRead` | the new conjuncts |
| `kvE2_sepValid_tie_of_nodup` | THE shared repair lemma: globally-`Nodup` `block.map g` payload ⟹ (iii') ∧ (iv) |
| `kvE2_sepTieRuns` (+ `_shape`, `_flatten`, `_ne_nil`, `_of_nodup`) | generic adjacent-run grouping kernel |
| `kvE2_sepTieGroupedL/R` (+ `_flatten`, `_ne_nil`, `_of_nodup`) | tie-class grouping over `kvE2_sepSlotsLOf/ROf` by merge key `kvE2_sepSlotGIdx wo` |

### Repaired consumers (the only four)

`kvE2_sepBody_complete`, `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'` —
conjunct-(iii) branches replaced by two applications of `kvE2_sepValid_tie_of_nodup` at the
banked `kvE2_sepAllSlots_map_slotIndexOf_nodup` / `_honestGIdx_nodup`; conjuncts (i)/(ii)
verbatim. `kvE2_sepArr'_sound` restated: second component is now
`kvE2_sepAnchorDistinct wo = true ∧ kvE2_sepTieRead wo = true` (old global-`Nodup` conclusion
is false by design under ties; zero downstream consumers existed).

## Representability check (defect demonstrated repaired)

The enumeration already contained duplicate-payload weak orders; only the filter changed.
1. **Base-base tie**: base entries never enter `wo.map kvE2_sepAnchorPayload`, so (iii') is
   unaffected; (iv)'s trigger requires the first member of a pair to be an anchor, so
   base-base pairs return `true` in both orientations. Such orders now pass validity —
   representable (previously excluded outright).
2. **Base-foreign-anchor tie**: (iii') unaffected (one anchor per class); (iv) demands exactly
   `kvE2_sepClosedLeafAt σa χ = true` — an F5-clean CLOSED-key read the honest model forces
   true (Phase 8 discharge). Representable, correctly gated.
3. **Anchor-anchor**: excluded by (iii') — documented Lean-side pruning, no paper counterpart.

## Verification results

- Full `lake build`: green, 1720 jobs.
- Sorry census (NfMultiAnchorBridge/): `sorry_count: 0`; SharedWitness `sorry` grep hits are
  all prose. Repo-wide sorry set identical to baseline (only SharedWitness modified; no code
  sorries in it).
- Axioms: `kvE2_sepValid_tie_of_nodup`, `kvE2_sepBody_complete`,
  `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'`, `kvE2_sepArr'_sound`,
  `kvE2_sepHonest_hLR_absurd` all `{propext, Classical.choice, Quot.sound}`;
  `kvE2_sepTieRuns_flatten`/`_of_nodup` `{propext}`; `kvE2_sepClosedLeafStub_eq_at`
  `{propext, Quot.sound}`.
- Guard: `kvE2_sepHonest_hLR_absurd` zero diff hunks; exactly one `hLR` binder file-wide
  (inside the guard). `kvE2_sepPosI_eq_pos`: 0 occurrences repo-wide.
- F5 grep: no `kvE_sub2_` key in any new code; LITMUS: no `x1 <` literal in new code.
- Vacuous defs: 1 pre-existing hit (`Examples/TemporalStructures.lean`, untouched baseline).
  Axiom count in Theories/: 2 (unchanged from HEAD).

## Plan deviations (annotated inline in the plan)

1. Anchor-payload projection via `kvE2_sepBlockPos`/`idxOf` instead of
   `(kvE2_sepS σ …).length` position arithmetic — same content, reuses banked machinery,
   keeps `kvE_sub2_` names out of new code.
2. Grouping kernel `kvE2_sepTieRuns` (house recursive) instead of `List.splitBy` — the
   v4.27.0-rc1 toolchain ships `splitBy` with no lemma support; plan sanctioned the house
   pattern.
3. Consequential repair beyond the three listed theorems: `kvE2_sepArr'_sound` restated
   (fourth consumer of old (iii); no downstream users).

## Sorry inventory

Empty.

## Next phase

Phase 7: grouped disjunct builder `kvE2_sepDisjunct'` + `kvE2_sepBody` rewire. Recipe with
current line anchors: `handoffs/phase-6-handoff-20260709.md`.
