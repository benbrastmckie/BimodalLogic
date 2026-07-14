# Blocker Analysis: Task #358

**Parent Task**: #358 - Realization recursion: nf_nvar_exist_all_depths (n>=1 arms)
**Generated**: 2026-07-14
**Blocker**: Phase 2's G2 exterior slice supply (plan v04, rows 8-11) is machine-refuted against task 363's landed `kvE_fiberElemConsistent` interface: the mate check is atom-row-only and is defeated by a planted, unrealizable, interior-zoned mate that restores the doppelgänger countermodel task 363 believed it had closed.

## Root Cause

Task 363 landed a depth-recursive fiber-consistency guard (`kvE_fiberElemConsistent` /
`kvE_fiberConsistent`, `ExteriorFiberConsistencyK.lean:33-55`) to close the m=1 doppelgänger
countermodel that had blocked both the interior (G1, rows 5-6) and exterior (G2, rows 8-11)
supply obligations. The guard's mate check reads:

```
mergeNF (e.atom_assgn) ⟨1,_⟩ = s'.atom_assgn   -- decided over σ's marked fibers s'
```

This is **atom-row-only**: it requires only that some `σ`-marked fiber `s'` share the dropped
atom row of the inner witness `e`. It imposes no constraint on `s'`'s own depth-≥1 marking
(`.2`), no realizability requirement, and no fresh-projection match.

Task 358's Phase 2 implementation dispatch (route R2, session
`sess_1784045100_2e3ffe`) built the mandated pre-flight probe before attempting the G2 supply
theorem, per plan v04's probe-first discipline. The probe
(`ExteriorPinnedProbe358K.lean`, certificate `kvE_probe358_eP_atomMate_present`, sorry-free,
floor axioms `[propext, Classical.choice, Quot.sound]`) constructs a **planted mate**:

```
mate := (mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)
```

i.e. an inner witness whose atom row is manufactured to equal the dropped row of `e_P` (the
`s*`-carrying inner witness task 363 proved had NO honest atom-mate,
`kvE_probe363_fake_elem_inconsistent`), but whose depth-≥1 marking is the constant-false
predicate. This plant is:
- **on-fiber**: its drop-drop content equals the doppelgänger's honest 4-row (`τ.1`), so it
  passes every existing on-fiber list check;
- **vacuously elem-consistent**: `.2 = fun _ => false` means `kvE_fiberElemConsistent` recurses
  over an empty marked set and trivially returns `true`;
- **interior-zoned**: its fresh coordinate (20) sits strictly inside the doppelgänger-sensitive
  bracket `(15, 18)` relative to anchors `[25,15,2,18]`, so it is invisible to all three
  exterior zone lists that gate slice equality;
- **unrealizable**: no model/environment actually realizes this fiber (it is a syntactic plant,
  not a witness derived from any realization).

Planting this mate re-supplies exactly the atom-row `kvE_probe363_fake_elem_inconsistent` had
declared absent, so `σ₂ := τ ⊕ s* ⊕ mate` becomes slice-equal to the honest `σ` under the
current guard, and the G2 conclusion (`hsliceFut`) fails to close — the same doppelgänger shape
task 363 fixed at the atom-row level survives one layer deeper, because nothing in the guard
distinguishes a "real" mate born of realization from a hand-planted, unrealizable, vacuously
elem-consistent stand-in.

**Scope confirmation**: G1 (interior, rows 5-6) is NOT re-broken by this hole. The plant is
projection-**visible** (its fresh atom sits in a position `igFoldBit`'s `nfk_projFresh` channel
reads), so `igFoldBit (qnf ⊕ σ₂) ≠ igFoldBit (honest qnf)` and task 363's interior separation
certificate (`kvE_probe363_qnfG1_antecedent_fails`) is untouched. The blocker is exterior-leg
(G2) only, and the fix target is exactly the guard task 363 authored, not a new consumer site.

**Category**: Missing prerequisite (a design defect in a just-landed interface) — the guard
that G2 depends on is provably too weak for the obligation it was built to discharge. This is
structurally identical to task 363's own genesis (spawned from task 358 to fix a
machine-refuted m=1 interface) — a second iteration of the same refine-interface-then-reprobe
loop, one layer deeper (depth-≥1 mate CONTENT, not just depth-0 atom row).

## Proposed New Tasks

### New Task 1: Strengthen `kvE_fiberElemConsistent` mate check against planted unrealizable mates

- **Effort**: 6-10 hours
- **Task Type**: lean4
- **Rationale**: This is the sole obligation blocking task 358 Phase 2 (G2 exterior supply,
  rows 8-11). The mechanized, sorry-free certificate `kvE_probe358_eP_atomMate_present`
  (`ExteriorPinnedProbe358K.lean`) proves the current interface is defeatable; task 358 cannot
  proceed against this interface as landed. A single interface-refinement task, following the
  exact methodology task 363 used successfully (machine probe before/after, frozen reference
  layer, zero-debt terminus), is sufficient — no separate research task or supply-theorem task
  is needed, since the fix is localized to one guard definition and its direct probes.
- **Depends on**: None (among new tasks). Builds on task 363's landed interface as its starting
  point (see Dependency Reasoning).

**Description** (for implementer): Strengthen `kvE_fiberElemConsistent`'s mate check
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean:52-55`)
so that it rejects the planted unrealizable mate constructed by
`kvE_probe358_eP_atomMate_present` (`ExteriorPinnedProbe358K.lean`) while continuing to accept
every honestly realized fiber and continuing to reject task 363's original fake
(`kvE_probe363_fake_elem_inconsistent`, `ExteriorPinnedProbeM1K.lean`).

Two candidate approaches (adjudicate in-task against the existing and new probes; either or a
synthesis is acceptable):
- (a) **Fresh-projection-aware mate content**: require the mate `s'`'s fresh projection
  (`nfk_projFresh`) — or its full `.2` depth-≥1 marking — to match the inner witness `e`'s
  corresponding content, not only the depth-0 atom row (`.atom_assgn`). The plant is
  projection-**visible** (its fresh coordinate sits inside the projection-read bracket), so this
  mirrors task 363's own G1 separation (`kvE_probe363_qnfG1_antecedent_fails`) and is flagged in
  the phase-2 handoff as the most promising direction.
- (b) **Realizability-anchored mate**: require the mate `s'` to be a genuinely realizable fiber
  (derivable from some model/environment), which would directly exclude the plant's
  `.2 = fun _ => false` construction as unrealizable-by-fiat.

Definition of done (mirrors task 363's re-probe discipline — the re-probe IS the definition of
done, not a restated signature alone):
1. Restate `kvE_fiberElemConsistent`'s mate check per the chosen approach.
2. Re-run `kvE_probe358_eP_atomMate_present` (or a re-derived successor) against the new
   interface and confirm it NO LONGER supplies an atom-mate for the plant — i.e. the plant is
   now correctly rejected.
3. Re-run all four of task 363's existing GO certificates
   (`ExteriorPinnedProbeM1K.lean`: `kvE_probeM1_sliceId_NOGO`,
   `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical`, and the
   `ExteriorFiberConsistencyProbeK.lean` Phase-1 GO certificate) to confirm the strengthened
   guard still accepts every honestly realized fiber and still rejects the original m=1
   doppelgänger — i.e. no regression on the interface task 363 built.
4. MUST NOT touch or re-open k=0 layers (rung0/rung1, task 360's m=0 supply theorems,
   `kampPrior_case1_arm_k0`) — unrefuted, must stay frozen (same constraint task 363 operated
   under).
5. MUST NOT attempt the general-m/general-depth G1/G2 supply build-out itself (that remains
   task 358 Phase 2/3, resumed after this task completes) — scope is the interface
   strengthening plus re-probe only.
6. Zero-debt terminus: no sorry, no vacuous def, no forcing a proof against a live
   countermodel. If neither candidate approach closes green, return `[BLOCKED]` with its own
   structured escalation (as task 363 itself was permitted to do) rather than landing debt.

**File scope**:
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean`,
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean`,
new additive probe leaf(s) alongside `ExteriorPinnedProbe358K.lean` /
`ExteriorPinnedProbeM1K.lean` under the same `NfMultiAnchorBridge/` directory.

## Dependency Reasoning

There is only one new task, so there is no internal new-task dependency graph to reason about.
The single new task's relationship to EXISTING work:

- **New Task 1 builds on task 363's landed interface** (not a fresh design): task 363's
  completion summary explicitly recorded the "FINAL PREDICATE SIGNATURE" of
  `kvE_fiberElemConsistent`/`kvE_fiberConsistent` as "the task-358 re-keying contract" — New
  Task 1 strengthens that exact predicate in place rather than replacing it, reuses its
  consumption sites (`ExteriorNegationK.lean`/`ExteriorNegationPastK.lean` conjunct-2,
  `EndIntervalConsumerK.lean` rows-5-6 antecedent, `kampPrior_site_rungK_gate_match`) unchanged,
  and must preserve the m=0 inertness lemmas (`kvE_fiberElemConsistent_zero`,
  `kvE_fiberConsistent_zero`) that those frozen sites rely on. This is why New Task 1 is scoped
  as a dependency of task 358 keyed to task 363's interface, not an independent redesign.
- **Task 358 depends on New Task 1** (not the reverse): task 358's Phase 2 dispatch is the one
  that discovered the hole via the mandated probe-before-supply gate, and the phase-2 handoff
  explicitly directs "Do NOT re-attempt G2 against the 363 interface as landed." Task 358 cannot
  resume Phase 2/3 (G1/G2 supply mechanization) until the interface New Task 1 produces passes
  its own re-probe gate — the supply theorems' proof strategy is directly shaped by which of
  approach (a) or (b) New Task 1 lands (e.g. a fresh-projection-content mate check changes what
  witness term the G2 supply proof must construct, versus a realizability-anchored mate check
  changes what obligation must be discharged to invoke the guard). This is an
  implementation-detail dependency, not merely a completion-order dependency: the specific
  choice New Task 1 makes determines the shape of the term task 358's Phase 2/3 must build.

## After Completion

Once New Task 1 is complete, resume the parent task with `/implement 358` (Phase 2, plan v04),
re-keyed against the strengthened interface.

The blocker will be resolved because: New Task 1's re-probe gate (item 2 in its definition of
done) directly falsifies the mechanism task 358's Phase 2 probe used to defeat G2 — once the
planted unrealizable mate can no longer supply an atom-mate for `e_P`, the doppelgänger
countermodel `σ₂ := τ ⊕ s* ⊕ mate` is no longer slice-equal to the honest `σ`, and the G2
`hsliceFut` supply obligation (rows 8-11) can be attempted against a interface that is not
already machine-refuted.
