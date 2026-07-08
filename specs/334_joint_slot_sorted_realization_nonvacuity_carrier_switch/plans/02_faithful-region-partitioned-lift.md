# Implementation Plan: Faithful Region-Partitioned Multi-Anchor Lift (Non-Vacuity Carrier Switch)

- **Task**: 334 - joint_slot_sorted_realization_nonvacuity_carrier_switch
- **Status**: [NOT STARTED]
- **Effort**: 12-18 hours (8 phases; 2 landed, crux-gated)
- **Dependencies**: 333 (green, axiom-clean; landed assets reused, not rebuilt)
- **Research Inputs**: reports/01_joint-slot-sorted-realization.md; handoffs/02_phase2-crux-blocker.md; handoffs/03_blocker-research-verdict.md; handoffs/04_faithfulness-audit.md
- **Artifacts**: plans/02_faithful-region-partitioned-lift.md (this file); plans/01_joint-slot-sorted-realization.md (superseded history)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Date**: 2026-07-08
- **reports_integrated**: 04_faithfulness-audit.md, 03_blocker-research-verdict.md, 02_phase2-crux-blocker.md, 01_joint-slot-sorted-realization.md

## Why This Is Faithful (per the Handoff-04 audit — read this first)

Plan `01` represented the multi-owner conjunction as a **single `List.mergeSort` keyed on one
point per slot** (`fun a b => decide (pt a ≤ pt b)`), forcing a total order over a witness
multiset that Rabinovich **never totally-orders**. That construction manufactured a false blocker:
an *unconditional* `p ≠ x1_σ` inequality (Phase-2 `[BLOCKED]` in plan 01). The Handoff-04
faithfulness audit adjudicated this a **SELF-INFLICTED ARTIFACT (HIGH confidence)**: the blocker
has **no analogue in Rabinovich 2014**.

The paper's actual technique (audit §2):

1. **Def 3.1 (md:61-74)** orders witnesses as a **region-partitioned interval decomposition** —
   FIXED anchor points `x_0 < … < x_n` partition the chain; interval witnesses are **strictly
   interior** to the open intervals `(x_{j-1}, x_j)`. Strictness is **definitional**, never derived
   from a distinctness lemma the model must supply.
2. **Lemma 3.2(1) (md:77)** combines multiple owners by a **disjunction over merge order-types**,
   NOT a joint total sort. Each disjunct is a single region-partitioned decomposition over the
   merged anchor set.
3. **§5 coincidence handling (md:168-173, 213-219)**: when two owners' witnesses coincide, that
   order-type disjunct **identifies the points** into one shared anchor carrying the **meet type** —
   NOT a tie to be refuted by an inequality.

The audit's inversion (§5, adversarial challenge 1): the very fact Handoff-03 cited as making the
coincidence *unpreventable* — `charK = P.existF 0` is **existential** (`NavigatedSpine.lean:411`),
so a point can realize both σ's depth-1 fresh type AND a foreign depth-0 base χ — is exactly what
**discharges** the coincidence disjunct. At a shared anchor `v = x1_σ`, "`x1_σ` realizes χ" is
TRUE, so the foreign fold bit is supplied by a **point-type channel**, not a refuted tie. The
obligation is **dissolved, not relocated**.

**The pivot in one line**: replace the single-point joint `mergeSort` with a **region-partitioned
multi-anchor lift of the already-proven `k1v_sorted_realization3`** (SubBracket2V.lean:379-402),
disjoined over anchor order-types, plus a point-type channel discharging coincident anchors. This
is not a fifth speculative single-point carrier (Rec-1) — it is the *first faithful transcription*
of the paper's conjunction handling, and it directly reuses the proven per-region engine.

## Overview

Close the sole remaining Phase-2 non-vacuity gap task 333 converged on — the joint (multi-owner)
model-realized arrangement of Rabinovich Def 3.1 / Lemma 3.2(1)-⇐ — by building the FAITHFUL
region-partitioned construction rather than the artifact single-point sort. Concretely:

1. Add a **point-type (closed-zone) channel** to the extractor `kvE_subBracket2_complete_extract`
   so a coincident witness `v = x1_σ` at a shared anchor is discharged by "`x1_σ` realizes χ"
   (front-loaded verification spike — the new make-or-break).
2. Lift `k1v_sorted_realization3` from its two fixed anchors `{x1, w}` to the **merged multi-owner
   anchor set** `{ x1_σ : σ ∈ kvE2_sepPos } ∪ {w}`, reusing `k1v_sorted_realization` verbatim per
   region.
3. Build the left and right arrangements (`kvE2_sepJointArrangedL/R`) as the model-order disjunct
   (Lemma 3.2(1)), with coincident anchors discharged by the point channel and non-coincident
   region boundaries supplied by the reduced (landed) `kvE2_sepFreshAnchor_ne_baseChiPoint`.
4. Rewire `kvE2_sepBody_nonvacuous` off `List.Perm.refl` onto the new arrangements; remove the two
   Phase-1 scaffold sorries.

Definition of done: `lake build …SharedWitness` green, the new arrangement lemmas sorry-free, the
top-level non-vacuity theorem axiom-clean, and every binding faithfulness invariant preserved
(never weaken to vacuity). Work is confined to
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` plus a
bounded extension to `…/SubBracket2.lean` (the extractor point-type channel) and, if a generic
multi-anchor engine is placed with its siblings, `…/SubBracket2V.lean` (next to
`k1v_sorted_realization3`).

### Research Integration

This revision integrates the **Handoff-04 faithfulness audit** (the decisive input; verdict
SELF-INFLICTED ARTIFACT, HIGH confidence), the **Handoff-03 carrier-salvage verdict** (its code
facts are correct and reused; its "architecture pivot / no fifth carrier" *framing* is SUPERSEDED
by the audit, which re-grounds the same target as the faithful Def-3.1 construction), and the
**Handoff-02 crux blocker** (the obstruction, now understood as an artifact of the single-point
sort). Key integrated conclusions:

- The single-point `mergeSort` joint sort is the **divergence**; the region-partitioned disjunction
  is the **correct** construction and reuses the proven `k1v_sorted_realization` region induction.
- The coincident-witness case is **dischargeable** via a point-type channel (existential `charK`),
  not a genuine obstruction. The exact fact that made the tie "unpreventable" is the discharge
  witness.
- The reduced, landed `kvE2_sepFreshAnchor_ne_baseChiPoint` (hypothesis `χ ≠ nf0_projFresh σ.1 →
  p ≠ x1_σ`) is REUSED verbatim for the non-coincident disjuncts, where the region partition
  supplies the base-type inequality by construction. Its residual is no longer demanded
  unconditionally.
- Plan `01`'s conclusions on "global `pt` injectivity" and "single-point secondary-key" are
  discarded (both were downstream of the artifact framing).

### Prior Plan Reference

Supersedes `plans/01_joint-slot-sorted-realization.md` (retained as history). Plan 01's Phases 1-3
were largely sound; Phase 1 (filter switch) and the Phase-2 reduced lemma are LANDED and committed
(marked DONE below). Plan 01's `mergeSort`-based Phases 4/5 and its `Perm.refl` rewire (Phase 6)
are REPLACED by the region-partitioned-lift phases here.

### Roadmap Alignment

Advances the WeakCanonical / Kamp completeness line (Rabinovich Def 3.1 / Lemma 3.2(1)-⇐
transcription). This IS the ROADMAP's pre-authorized "Option B" (interval-typed rebuild), now
re-scoped by the audit as the faithful transcription rather than a speculative carrier gamble.

## Preserved Assets (binding — do NOT re-plan or break)

Landed green + axiom-clean; reused, not rebuilt. Any phase touching these must leave them
functionally intact (byte-identical where not deliberately rewired):

- **LANDED & COMMITTED (Phase 1)**: the arrangement-aware `kvE2_sepSlotLe` filter switch
  (if-form onto the present predicates, SharedWitness ~:459), the mechanical renames
  (`kvE2_sepSlotLe_same`, `kvE2_sepSlotLe_of_ne_compat`, `kvE2_sep_pairwise_rank_same`, the
  `_rankPairwise`/`_pairwise` split). DO NOT redo.
- **LANDED & COMMITTED (Phase 2)**: the reduced, axiom-clean
  `kvE2_sepFreshAnchor_ne_baseChiPoint` (SharedWitness ~:1133; hypothesis-bearing
  `χ ≠ nf0_projFresh σ.1 → p ≠ x1_σ`). This is a genuine theorem, the honest distinctness engine;
  REUSED for the non-coincident region boundaries. DO NOT redo.
- **`k1v_sorted_realization3`** (SubBracket2V.lean:379-402) and its per-region engine
  **`k1v_sorted_realization`** (CarrierK1V ~:1447): the paper-faithful reference implementation of
  the region-partitioned sort. The multi-anchor engine LIFTS this verbatim per region.
- Task 333's four cross-σ compat leaves: `kvE2_sepCompat_lX1_eq`, `kvE2_sepCompat_lX1_after_eq`,
  `kvE2_sepCompat_rX1_eq`, `kvE2_sepCompat_rX1_after_eq` (the complete set the arrangement
  consumes per disjunct).
- `kvE2_sepHonestBundleL` (SharedWitness ~:1083; per-σ left-interior witness bundle supplying the
  anchor `x1_σ` and strictly-interior region witnesses).
- The refined-segment machinery (`kvE2_sepSegLForSub`/`RForSub`), `kvE2_sepGate_holds_of_honest`
  (gate branch — UNCHANGED), and the `kvE2_sepBracketN` point-type machinery.
- The 2 pre-existing tracked strategic sorries (`kvE2_sepSingleton_coverage_left` ~:1997,
  `kvE2_sepBody_singleton_complete_left` ~:2129) remain untouched — task-333 Phases 4/5, OUT of
  scope.

**Scaffold state carried in from Phase 1** (to be discharged by the new construction, NOT re-planned):
the 2 labeled scaffold sorries `kvE2_sepSlotsL_valid` (~:894) and `kvE2_sepSlotsR_valid` (~:901)
remain live until Phase 7 rewires `kvE2_sepBody_nonvacuous` onto the new arrangements. Sorry
inventory today: 2 scaffold + 2 pre-existing strategic; 0 vacuous defs; 0 new axioms.

**Deviation from plan 01's preserved-assets list**: `kvE_subBracket2_complete_extract` was marked
"do-not-edit" in plan 01. The audit (§4) directs a *bounded extension* — adding a point-type
(closed-zone) channel alongside its three strict-open zone channels. This is the ONLY new edit to
a do-not-edit asset, and it is additive (a new conjunct/channel), not a rewrite of the existing
channels.

## Goals & Non-Goals

**Goals**:
- Add the point-type (closed-zone) channel on `kvE_subBracket2_complete_extract` discharging the
  shared-anchor meet-type case (`v = x1_σ` → "`x1_σ` realizes χ").
- Prove (front-loaded verification spike) that the coincident-witness obligation DISSOLVES in the
  region-partitioned frame — the make-or-break, closed BEFORE building the full L/R lift.
- Build the generic multi-anchor region-partitioned realization engine (lift of
  `k1v_sorted_realization3` to k merged anchors).
- Prove `kvE2_sepJointArrangedL` and `kvE2_sepJointArrangedR` (region-partitioned model-order
  disjunct; replaces plan 01's `kvE2_sepJointSortedL/R`).
- Add the right-interior bundle `kvE2_sepHonestBundleR` (mirror of the landed L bundle).
- Rewire `kvE2_sepBody_nonvacuous` off `List.Perm.refl` onto the new arrangements; remove the 2
  Phase-1 scaffold sorries.
- End green: `lake build …SharedWitness` exit 0, new arrangement lemmas sorry-free, top-level
  non-vacuity theorem axiom-clean, all 7 faithfulness invariants confirmed.

**Non-Goals**:
- Any single-point joint `mergeSort` / total sort keyed on one `pt` per slot (the artifact — DO
  NOT rebuild it).
- An *unconditional* `p ≠ x1_σ` inequality (the manufactured blocker — deleted; replaced by the
  region partition + point channel case split).
- Global `pt` injectivity or single-point secondary-key tie-breaks (plan 01 conclusions,
  discarded).
- Discharging the 2 pre-existing strategic sorries (task-333 Phases 4/5, downstream).
- Any edit outside `SharedWitness.lean`, the bounded extractor extension in `SubBracket2.lean`, and
  (optionally) the multi-anchor engine placed with its siblings in `SubBracket2V.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Point-type channel does NOT close: the shared-anchor discharge `nf_eval_nf M 0 1 (fun _ => x1_σ) χ` is not derivable from the extractor's fold — the new make-or-break | H | M (audit confidence Medium-High on this exact step) | **Phase 3 is a front-loaded VERIFICATION SPIKE** proving this in isolation BEFORE the L/R lift. Route: `charK = existF` existential (NavigatedSpine:411) + the extractor's generic zone-forward channel (SubBracket2:614-618) at the closed self-zone `kvE2_sep_zAtX1L`. If it resists: ESCALATE (blocker handoff); do NOT vacuity-weaken. (325 v1's vacuous-soundness failure is the cautionary precedent — catch unsoundness at the spike, not at build's end.) |
| Multi-anchor lift of `k1v_sorted_realization3` larger than one agent run | M | H | Split: generic engine (Phase 4) separate from L instantiation (Phase 5) and R instantiation (Phase 6). Each bounded ~200-350 lines. The per-region engine `k1v_sorted_realization` is REUSED verbatim — net-new is only the k-anchor partition + stitching. |
| Coincident-anchor interleaving in the slot permutation not expressible under `kvE2_sepValid`'s `kvE2_sepSlotLe`-Pairwise | M | M | The compat leaves (`kvE2_sepCompat_lX1_eq` etc.) already encode the cross-σ fold-bit predicate PER disjunct; at a shared anchor both owners' slots sit at rank boundaries, discharged by compat + the point channel (not a strict inequality). Phase 3 spike confirms the discharge shape feeds `kvE2_sepSlotLe`. |
| Right-interior env/zone reading of the extractor differs for `w < x1_σ < t` | M | M | Phase 6 first CONFIRMS the right-interior extractor/env (`kvE2_sep_zWX1 = (w,x1)` middle region) before mirroring; document the finding. |
| Non-coincident region boundary still needs a base-type inequality not supplied by the partition | M | L | The reduced `kvE2_sepFreshAnchor_ne_baseChiPoint` consumes exactly `χ ≠ nf0_projFresh σ.1`; the strictly-interior region typing supplies this by construction (a region-interior χ-witness carries a region base type distinct from the anchor's fresh-coordinate type). Confirm at Phase 5. |
| Extending `kvE_subBracket2_complete_extract` breaks its existing consumers | M | L | The extension is ADDITIVE (new channel/conjunct); existing channels and their consumers (`kvE2_sepHonestBundleL`, gate branch) unchanged. `lake build` after the edit confirms no regression. |

## Faithfulness Invariants (plan-level acceptance checks — every phase preserves ALL)

The 7 binding invariants, encoded as per-phase acceptance checks (see each phase's "Faithfulness
invariants" line):

1. **Rabinovich Lemma 5.1** — quantifier-free point types (`charBase χ` / `charK (nfk_projFresh σ)`);
   NO nesting introduced by any new code.
2. **Lemma 3.2(1) — never weaken to vacuity**: the region-partitioned model-order arrangement IS
   the literal ⇐-witness; the disjunction over order-types is the paper's conjunction handling, not
   a vacuous admission.
3. **Lemma 3.2(2)** — anchor cap 2 in each SUB's own decomposition; free `(x,t)` framing and
   `kvE2_sepGate_holds_of_honest` untouched. (The MERGED anchor set has k anchors across owners,
   but each owner contributes ≤ 2 — the cap is per-owner.)
4. **No-nesting audit** — new code adds a partition + a point channel + a distinctness case split;
   NO type nesting.
5. **LITMUS** — no `x1 < e_i` slot-index literal; region membership and anchor comparisons are on
   carrier points, and slot placement reads structural slot INDICES only.
6. **F4 adversarial test must DISCRIMINATE** — the switched filter strengthens admission (cross-σ
   compat replaces unconditional interleaving); the arrangement never weakens the discriminator.
7. **Macro-side confinement** — L list only `(x,w)` slots, R only `(w,t)`.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 (landed) | 1, 2 | -- (DONE) |
| 1 | 3 | -- (crux gate) |
| 2 | 4 | 3 |
| 3 | 5, 6 | 4 (6 also needs its own bundle) |
| 4 | 7 | 5, 6 |
| 5 | 8 | 7 |

Phases within a wave are logically parallel, but (H7 territory) ALL phases edit
`SharedWitness.lean` (and Phases 3/4 also `SubBracket2.lean`/`SubBracket2V.lean`), so within a wave
they MUST be executed serially by one agent at a time. Recommended serial order:
3 → 4 → 5 → 6 → 7 → 8, with **Phase 3 as the crux gate**: if Phase 3 fails, STOP before Phases 4-7.

---

### Phase 1: Wire the arrangement-aware filter switch (mechanical) [COMPLETED]

**DONE — LANDED & COMMITTED (plan 01 Phase 1; commit `04ea18425` and successors).** Reproduced
here for accounting only; do NOT re-execute.

- [x] `kvE2_sepSlotLe` rewritten to the `if kvE2_sepSlotSub a = kvE2_sepSlotSub b then decide (rank ≤ rank) else kvE2_sepCompat a b` form (~:459).
- [x] Mechanical renames: `kvE2_sepSlotLe_same`, `kvE2_sepSlotLe_of_ne_compat`, `kvE2_sep_pairwise_rank_same`; `_rankPairwise`/`_pairwise` split.
- [x] 2 labeled scaffold sorries at `kvE2_sepSlotsL_valid` / `kvE2_sepSlotsR_valid` (NOT 3 — `kvE2_sepBody_nonvacuous` compiles unchanged referencing the two sorried `_valid` lemmas). Removed in Phase 7.

**Acceptance (already met)**: `lake build …SharedWitness` exit 0; sorry inventory 2 scaffold + 2
pre-existing strategic; preserved assets byte-identical.

---

### Phase 2: Reduced crux lemma `kvE2_sepFreshAnchor_ne_baseChiPoint` [COMPLETED]

**DONE — LANDED & COMMITTED (plan 01 Phase 2, reduced form).** The UNCONDITIONAL form plan 01
sought is NOT provable and was the artifact blocker; the REDUCED, hypothesis-bearing form IS a
genuine sorry-free, axiom-clean theorem and is REUSED here (non-coincident region boundaries). Do
NOT re-execute.

- [x] `kvE2_sepFreshAnchor_ne_baseChiPoint` landed at SharedWitness ~:1133 with hypothesis
  `hχne : χ ≠ nf0_projFresh σ.1`, sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]`).
- [x] Established (and the audit confirmed) there is NO fresh-vs-base discriminator; the correct
  reduction is base-vs-base via `nf_eval_nf0_cons_factor` + `nf_eval_unique`.

**Acceptance (already met)**: lemma compiles green, sorry-free, axiom-clean. **Re-framing (per
audit)**: its residual `χ ≠ nf0_projFresh σ.1` is no longer demanded *unconditionally* — it is
supplied by-construction on non-coincident disjuncts and *dissolved* (not demanded) on coincident
ones via the Phase-3 point channel.

---

### Phase 3: CRUX VERIFICATION SPIKE — point-type channel discharges the coincident-witness case [BLOCKED]

**BLOCKER** (Phase 3 — make-or-break spike FAILED: point channel RELOCATES, does not dissolve):
- **What landed GREEN (deliverables 1 & 2)**: (i) Confirmed the extractor's generic zone-forward
  channel (`SubBracket2.lean:614-618`, `∀ zs χ, (∃ v, zoneHolds env zs v ∧ v realizes χ) → bit`)
  ALREADY covers the closed self-zone — NO extractor extension needed. (ii) Proved
  `kvE2_sepCoincidentAnchor_discharge` (SharedWitness ~:1161), sorry-free, axiom-clean
  (`[propext, Classical.choice, Quot.sound]`): at `v = x1`, χ-realized-at-anchor ⇒
  `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true`.
- **What FAILED (deliverable 3 — the dissolution)**: The discharge produces σ's CLOSED self-zone
  bit `kvE2_sepBits σ **kvE2_sep_zAtX1L** χ`. The arrangement validity `kvE2_sepValid` (a PRESERVED
  asset, unchanged by this plan) routes every cross-owner fresh-adjacency through σ's OPEN-zone
  bits: `kvE2_sepCompat_lX1_eq` = `kvE2_sepBits σ **kvE_sub2_zXU** χ` (foreign slot BEFORE `.lX1 σ`)
  and `kvE2_sepCompat_lX1_after_eq` = `kvE2_sepBits σ **kvE_sub2_zUW** χ` (AFTER). These three zone
  specs differ in coordinate 0 (`zAtX1L`=`(false,false)`, `zXU`=`(true,false)`, `zUW`=`(false,true)`),
  so `nf0_assemble` yields distinct keys and `σ.2` at them are INDEPENDENT bits. Confirmed at the
  Lean type-checker: `σ.2 (nf0_assemble zAtX1L χ σ.1)` does NOT unify with
  `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1)` ("Type mismatch"; `unfold` does not bridge).
- **The refuting counterexample (non-vacuity is FALSE for the full carrier)**: Take two positive
  left-interior owners σ, τ. σ realized at `[x1_σ,w,x,t]` with x1_σ realizing χ but NO χ-witness in
  `(x,x1_σ)` nor `(x1_σ,w)` — the extractor's REVERSE channels (`SubBracket2:619-622`) then FORCE
  `σ.2(zXU χ)=false` and `σ.2(zUW χ)=false`, while the forward channel forces `σ.2(zAtX1L χ)=true`.
  τ realized at `[x1_τ,w,x,t]` with `x1_σ < x1_τ` and τ realizing χ at exactly `x1_σ` (in τ's
  `(x,x1_τ)` region, so `.lXU τ χ ∈ kvE2_sepSlotsL`). For THIS realizable qnf, any permutation must
  order `.lXU τ χ` vs `.lX1 σ`: placing it BEFORE demands `σ.2(zXU χ)=true` (false); AFTER demands
  `σ.2(zUW χ)=true` (false). No valid arrangement exists ⇒ `kvE2_sepArrL qnf = []` ⇒
  `kvE2_sepBody_nonvacuous` is FALSE, not merely hard. The point channel supplies only the
  `zAtX1L` disjunct, which the preserved open-zone compat cannot consume.
- **Root cause**: This is EXACTLY the residual already diagnosed by the LANDED task-333 analysis at
  `SharedWitness.lean:1879-1928`: "the honest-derivable DISJUNCTIVE clause (σ's zXU- OR zAtX1- OR
  zUW-bit true) cannot select the disjunct matching the REALIZED arrangement's placement of τ's
  slot — the Bool disjunction is arrangement-blind while the placement is arrangement-chosen"; and
  "the faithful repair is BIT-COMPATIBILITY FILTERING of the interleaving enumeration ... That
  re-defines `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` ... a carrier re-definition outside this
  phase's additive scope." Plan 02's model-order arrangement DOES discharge all STRICT cases
  (strictly-below → zXU via σ's forward channel; strictly-above → zUW) — genuine progress over the
  identity arrangement — but the point channel does NOT extend that to the EXACT coincidence, which
  is model-possible (no density) and fatal.
- **What is needed to unblock (plan-level decision, NOT more proof in this scope)**: (A) Redefine
  `kvE2_sepValid`/`kvE2_sepCompat` to a DISJUNCTIVE (zXU ∨ zAtX1L ∨ zUW) bit-compatibility filter
  keyed to arrangement placement, then re-establish non-vacuity + O2/O3 plumbing under the new
  filter (the "faithful repair" task-333 identified; large; breaks the preserved compat leaves). OR
  (B) Accept the completeness line runs through the already-landed N2 single-positive-sub fragment
  (`kvE2_sepBody_singleton_*`, SharedWitness ~:1952) where cross-σ slots — and this crux — vanish,
  and formally close multi-owner non-vacuity as out-of-scope. OR (C) a density assumption ruling
  out exact coincidences (likely unfaithful / unavailable).
- **Prohibited workarounds NOT applied**: no `sorry`, no `def X := True`, no compat-filter vacuity
  weakening, no single-point `mergeSort` reintroduction. The green `kvE2_sepCoincidentAnchor_discharge`
  is retained (correct, axiom-clean, faithful §5 meet-type transcription; a live input to repair (A)).

**The new make-or-break, front-loaded.** Before building any of the L/R lift, PROVE in isolation
that the coincident-witness obligation dissolves in the region-partitioned frame. This is a small,
targeted spike (driven-proof discipline): catch any residual unsoundness here, not at build's end.

**Goal**: Add a point-type (closed-zone) channel to `kvE_subBracket2_complete_extract` and prove
that at a shared anchor `v = x1_σ`, the foreign fold bit is discharged by "`x1_σ` realizes χ"
(TRUE — `charK = P.existF 0` is existential). Concretely, produce a lemma of the shape:

> For a positive owner σ realized at env `[x1,w,x,t]` and a foreign base type χ with
> `nf_eval_nf M 0 1 (fun _ => x1) χ` (χ realized AT the anchor), the closed self-zone fold bit
> `σ.2 (nf0_assemble kvE2_sep_zAtX1L χ σ.1)` (or the compat leaf's coincident-anchor obligation)
> is discharged — WITHOUT any `p ≠ x1_σ` inequality.

**Tasks**:
- [x] Confirm the extractor's generic zone-forward channel (`SubBracket2.lean:614-618`,
  `∀ zs χ, (∃ v, zoneHolds … zs v ∧ nf_eval_nf … v χ) → σ.2 (nf0_assemble zs χ σ.1) = true`)
  fires for the CLOSED self-zone spec `kvE2_sep_zAtX1L` at `v = x1`. *(completed: the generic
  channel already quantifies over ALL zone specs; NO extractor extension needed — `SubBracket2.lean`
  UNCHANGED.)*
- [x] Prove the spike lemma `kvE2_sepCoincidentAnchor_discharge`. *(completed: landed at
  SharedWitness ~:1161, sorry-free, axiom-clean; concludes `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true`
  from χ-realized-at-anchor.)*
- [ ] VERIFY the dissolution. *(deviation: FAILED — the make-or-break. The discharge gives the
  CLOSED-zone bit `zAtX1L`; the preserved compat filter demands the OPEN-zone bits `zXU`/`zUW`
  (`kvE2_sepCompat_lX1_eq`/`_after_eq`). Distinct `nf0_assemble` keys ⇒ independent `σ.2` bits;
  no bridge (Lean type-mismatch confirmed). Concrete counterexample shows non-vacuity is FALSE for
  the full carrier. See the BLOCKER entry above. This is the task-333 residual at :1879-1928.)*
- [x] ESCALATION guard fired: STOPPED before Phase 4; blocker handoff written; NO compat vacuity
  weakening; NO single-point sort reintroduced.

**Timing**: 2-4 hours (~100-200 lines; or escalate).

**Depends on**: none (independent gate; sequenced first to de-risk the lift).

**Files to modify**:
- `…/NfMultiAnchorBridge/SubBracket2.lean` — additive point-type (closed-zone) channel on
  `kvE_subBracket2_complete_extract` (only if the generic channel does not already cover the closed
  zone).
- `…/NfMultiAnchorBridge/SharedWitness.lean` — the spike lemma `kvE2_sepCoincidentAnchor_discharge`.

**Produces**: point-type channel (extractor), `kvE2_sepCoincidentAnchor_discharge` (spike lemma) OR
a blocker handoff + escalation.

**Faithfulness invariants**: 1 (QF point types — the channel reads `charBase χ`/`charK`, no
nesting), 2 (the discharge is the paper's §5 shared-anchor meet-type identification, not vacuity),
4 (no nesting), 5 (closed zone is a self-zone spec, not an `x1 < e_i` literal). Invariant 6
preserved (discharge strengthens, never weakens, admission).

**Verification / acceptance**:
- On success: spike lemma + channel compile green, sorry-free, axiom-clean; `lake build …SubBracket2`
  and `…SharedWitness` exit 0; existing extractor consumers (`kvE2_sepHonestBundleL`, gate branch)
  unregressed.
- On resistance: explicit blocker handoff; NO vacuity weakening; STOP before Phase 4.

---

### Phase 4: Generic multi-anchor region-partitioned realization engine [NOT STARTED]

**Goal**: Lift `k1v_sorted_realization3` (2 fixed anchors `{x1, w}`) to k MERGED anchors. State a
generic engine: given a sorted list of fixed anchors `a_0 < a_1 < … < a_k` partitioning an open
interval `(lo, hi)`, and per-region Nodup type lists each realized strictly interior to its open
sub-interval, produce per-region sorted blocks (via `k1v_sorted_realization` per region) whose
stitched witness list is strictly increasing across the fixed anchors. Coincident anchors (a
degenerate region) are handled by the Phase-3 point channel (the region collapses; the shared
anchor carries the meet type).

**Tasks**:
- [ ] State `kvE2_multiAnchor_sorted_realization` (name TBD): the k-anchor generalization of
  `k1v_sorted_realization3`'s signature (SubBracket2V.lean:379-394) — per-region `Nodup` + strict
  interior realization ⇒ ∃ per-region point-lists, permutation-correct, stitched strictly
  increasing around the fixed anchors.
- [ ] Prove by induction on the anchor list, reusing `k1v_sorted_realization`
  (CarrierK1V ~:1447) VERBATIM per region and the `k1v_sorted_realization3` stitching pattern
  (SubBracket2V:403-419) at each anchor boundary. Distinctness is per-region-per-owner
  (type-driven via `Nodup` + `nf_eval_unique`), which IS available — the artifact's error was
  demanding it ACROSS owners AT an anchor.
- [ ] Place the engine next to `k1v_sorted_realization3` in `SubBracket2V.lean` if it is generic
  over the carrier (preferred for reuse), OR in `SharedWitness.lean` if it must reference
  slot-specific structure. Document the placement decision.

**Timing**: 3-4.5 hours (~250-350 lines).

**Depends on**: 3 (the coincident-anchor discharge shape the engine's degenerate-region case
consumes).

**Files to modify**:
- `…/NfMultiAnchorBridge/SubBracket2V.lean` (or `SharedWitness.lean`) — the generic multi-anchor
  engine.

**Produces**: `kvE2_multiAnchor_sorted_realization` (generic, sorry-free).

**Faithfulness invariants**: 1 (QF region types), 2 (region partition = the literal interval
decomposition, no vacuity), 4 (no nesting), 5 (LITMUS — anchors are carrier points, witnesses
strictly interior; no `x1 < e_i`). Invariant 3 preserved (per-owner anchor cap unaffected by the
merge).

**Verification / acceptance**:
- `lake build` on the engine's module exit 0; `kvE2_multiAnchor_sorted_realization` sorry-free,
  axiom-clean.
- Engine reuses `k1v_sorted_realization` unchanged (diff-audit: no edit to the per-region lemma).
- Stitched output is `Pairwise (· < ·)` across non-coincident anchors; coincident anchors routed
  to the Phase-3 discharge (no strict inequality demanded there).

---

### Phase 5: LEFT arrangement `kvE2_sepJointArrangedL` (Lemma 3.2(1) model-order disjunct) [NOT STARTED]

**Goal**: Build the left-list faithful arrangement:
`∃ πL, List.Perm πL (kvE2_sepSlotsL qnf) ∧ kvE2_sepValid πL = true`, as the **model-order disjunct**
of the merged left anchors `{ x1_σ : σ left-interior } ∪ {w}` (Lemma 3.2(1)). The syntactic carrier
already enumerates every order-type via `permutations.filter kvE2_sepValid` (rule N5 / VVecEA2), so
non-vacuity needs the ONE arrangement matching the actual model order — built by instantiating
Phase 4 with the anchors and region witnesses from `kvE2_sepHonestBundleL`.

**Tasks**:
- [ ] Read the per-owner left anchors and strictly-interior region witnesses from
  `kvE2_sepHonestBundleL` (each left-interior σ: anchor `x1_σ` with `x < x1_σ < w`, `zXU` witnesses
  in `(x, x1_σ)`, `zUW` witnesses in `(x1_σ, w)`). The merged anchor set is `{x1_σ} ∪ {w}` in `(x, w]`.
- [ ] Instantiate `kvE2_multiAnchor_sorted_realization` with the merged left anchors (sorted by the
  model's `LinearOrder`), obtaining the per-region sorted point-lists and the strictly-increasing
  stitched witness list.
- [ ] Build `πL` as the induced slot permutation and prove `List.Perm πL (kvE2_sepSlotsL qnf)` (the
  flatMap-over-owners list reorders to the region-partitioned order).
- [ ] Prove `kvE2_sepValid πL = true` by transferring to `Pairwise (kvE2_sepSlotLe · = true)`:
  same-owner pairs ⇒ rank (from the strict region bounds `x < u < x1_σ < u' < w`);
  cross-owner NON-coincident pairs ⇒ `kvE2_sepCompat` via the strict open zone, with the base-type
  inequality supplied BY CONSTRUCTION (region-interior χ ≠ `nf0_projFresh σ.1`) fed to the reduced
  `kvE2_sepFreshAnchor_ne_baseChiPoint`;
  cross-owner COINCIDENT-anchor pairs ⇒ Phase-3 point channel `kvE2_sepCoincidentAnchor_discharge`
  + the compat leaves `kvE2_sepCompat_lX1_eq` / `kvE2_sepCompat_lX1_after_eq`. NO unconditional
  inequality anywhere.

**Timing**: 3-4 hours (~200-300 lines).

**Depends on**: 3 (point channel), 4 (engine).

**Files to modify**:
- `…/NfMultiAnchorBridge/SharedWitness.lean` — `kvE2_sepJointArrangedL` (+ any L-side point-map glue).

**Produces**: `kvE2_sepJointArrangedL` (sorry-free) — the faithful replacement for plan 01's
`kvE2_sepJointSortedL`.

**Faithfulness invariants**: 1, 2 (arrangement = literal ⇐-witness, no vacuity), 5 (carrier-point
region comparisons, no `x1 < e_i`), 6 (compat leaves reject bad interleavings), 7 (L only `(x,w)`).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0; `kvE2_sepJointArrangedL` sorry-free, axiom-clean.
- Uses ONLY the four landed compat leaves + the reduced `kvE2_sepFreshAnchor_ne_baseChiPoint`
  (non-coincident) + the Phase-3 point channel (coincident). NO single-point `mergeSort`, NO global
  injectivity, NO unconditional inequality.

---

### Phase 6: RIGHT bundle `kvE2_sepHonestBundleR` + arrangement `kvE2_sepJointArrangedR` [NOT STARTED]

**Goal**: Mirror Phases 5 for the right list. FIRST confirm the right-interior extractor env/zone
reading (`w < x1_σ < t`; `kvE2_sep_zWX1 = (w, x1)` middle region), add the mirror bundle
`kvE2_sepHonestBundleR`, then build
`∃ πR, List.Perm πR (kvE2_sepSlotsR qnf) ∧ kvE2_sepValid πR = true` via Phase 4 over the merged
right anchors `{ x1_σ : σ right-interior } ∪ {w}` in `[w, t)`.

**Tasks**:
- [ ] Confirm the right-interior env/zone reading of `kvE_subBracket2_complete_extract` (mirror of
  the L bundle; coordinate-relabeling reuse or a right-interior analog). Document inline.
- [ ] State + prove `kvE2_sepHonestBundleR` (per-σ right-interior witnesses, strict interval
  bounds; mirror of `kvE2_sepHonestBundleL`). LITMUS-clean (no `x1 < e_i`).
- [ ] Instantiate `kvE2_multiAnchor_sorted_realization` with the merged right anchors; build `πR`;
  prove `List.Perm πR (kvE2_sepSlotsR qnf)` and `kvE2_sepValid πR = true` using
  `kvE2_sepCompat_rX1_eq` / `kvE2_sepCompat_rX1_after_eq`, the `zWX1`/`zWT` zones (non-coincident),
  and the Phase-3 point channel (coincident).
- [ ] If the bundle + arrangement exceed one agent run, split: Phase 6a (bundle) → Phase 6b
  (arrangement). Note the split at execution; commit 6a green before 6b.

**Timing**: 3.5-5 hours (~250-350 lines; splittable 6a/6b).

**Depends on**: 4 (engine); its own bundle (6a) blocks the arrangement (6b).

**Files to modify**:
- `…/NfMultiAnchorBridge/SharedWitness.lean` — `kvE2_sepHonestBundleR`, `kvE2_sepJointArrangedR`.

**Produces**: `kvE2_sepHonestBundleR`, `kvE2_sepJointArrangedR` (sorry-free).

**Faithfulness invariants**: same as Phase 5, with invariant 7 (R only `(w,t)`).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0; both lemmas sorry-free, axiom-clean.
- Right-interior env/zone reading documented; mirror symmetry with L confirmed.

---

### Phase 7: Rewire `kvE2_sepBody_nonvacuous` off `List.Perm.refl` [NOT STARTED]

**Goal**: Rewire `kvE2_sepBody_nonvacuous` (~:1156) to exhibit `πL`/`πR` from
`kvE2_sepJointArrangedL`/`R` instead of `List.Perm.refl` + the now-false identity-arrangement
`_valid` lemmas. Remove the 2 Phase-1 scaffold sorries. Retire `kvE2_sepSlotsL_valid`/`_valid`
(false post-switch) and any now-dead `kvE2_sepSlotLe_of_sub_ne`. Gate branch
`kvE2_sepGate_holds_of_honest` UNCHANGED.

**Tasks**:
- [ ] Replace the two `List.Perm.refl` witnesses (~:1173/:1177) with `kvE2_sepJointArrangedL`/`R`
  (destructure the `∃ π, Perm ∧ valid` and feed into `List.mem_filter.mpr ⟨mem_permutations, valid⟩`).
- [ ] Remove the 2 scaffold sorries (`kvE2_sepSlotsL_valid`, `kvE2_sepSlotsR_valid`); delete the
  retired lemmas.
- [ ] Confirm the `dite` gate guard still discharged by the unchanged `kvE2_sepGate_holds_of_honest`.

**Timing**: 1-1.5 hours.

**Depends on**: 5, 6.

**Files to modify**:
- `…/NfMultiAnchorBridge/SharedWitness.lean` — rewire nonvacuity; retire dead lemmas.

**Produces**: rewired `kvE2_sepBody_nonvacuous` (scaffold-sorry-free).

**Faithfulness invariants**: 2 (non-vacuity now proven by the honest region-partitioned
arrangement, not `Perm.refl`/vacuity), 3 (gate branch untouched).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0.
- Sorry inventory back to exactly the 2 pre-existing strategic sorries (0 scaffold remain).
- No `List.Perm.refl` and no single-point `mergeSort` in `kvE2_sepBody_nonvacuous`'s dependency
  cone.

---

### Phase 8: Final verification (build + sorry inventory + axiom check + invariant audit) [NOT STARTED]

**Goal**: Confirm the completed faithful non-vacuity closure end-to-end.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` — green,
  exit 0 (and the extractor module `…SubBracket2` / engine module `…SubBracket2V`).
- [ ] Sorry inventory across the touched files: exactly the 2 pre-existing strategic sorries; 0
  scaffold, 0 new.
- [ ] Axiom check (`lean_verify` / `#print axioms`) on `kvE2_sepBody_nonvacuous` and its new
  dependents (`kvE2_sepJointArrangedL/R`, `kvE2_multiAnchor_sorted_realization`, the point channel)
  — no new axioms beyond `[propext, Quot.sound, Classical.choice]`.
- [ ] Diff-audit preserved assets (four compat leaves, `kvE2_sepHonestBundleL`,
  `k1v_sorted_realization`/`3`, gate branch) — functionally intact; extractor extension additive only.
- [ ] Confirm all 7 faithfulness invariants hold across the final files; confirm NO single-point
  `mergeSort` and NO unconditional `p ≠ x1_σ` inequality anywhere in the new construction.

**Timing**: 0.5-1 hour.

**Depends on**: 7.

**Files to modify**: none (verification only).

**Produces**: verification report (sorry inventory, axiom check, invariant confirmation, artifact
audit) for the summary.

**Verification / acceptance**:
- Build green; sorry inventory = 2 pre-existing strategic; axiom-clean top-level theorem; all 7
  invariants confirmed; artifact construction (single-point sort / unconditional inequality) absent.

## Testing & Validation

- [ ] `lake build …SharedWitness` (and `…SubBracket2`, `…SubBracket2V`) exit 0 after each phase
  (green build discipline; the 2 scaffold sorries permitted only between Phases 1 and 7).
- [ ] `kvE2_sepCoincidentAnchor_discharge` (Phase 3), `kvE2_multiAnchor_sorted_realization` (Phase 4),
  `kvE2_sepJointArrangedL` (Phase 5), `kvE2_sepHonestBundleR` + `kvE2_sepJointArrangedR` (Phase 6)
  each sorry-free and axiom-clean.
- [ ] Final sorry inventory = exactly 2 pre-existing strategic sorries (no scaffold residue, no
  regressions).
- [ ] Axiom check on `kvE2_sepBody_nonvacuous`: no new axioms.
- [ ] All 7 faithfulness invariants preserved; never weakened to vacuity; NO single-point
  `mergeSort`; NO unconditional `p ≠ x1_σ`.

## Artifacts & Outputs

- plans/02_faithful-region-partitioned-lift.md (this file)
- plans/01_joint-slot-sorted-realization.md (superseded history)
- summaries/02_faithful-region-partitioned-lift-summary.md (on completion)
- Modified: `…/NfMultiAnchorBridge/SharedWitness.lean`, `…/SubBracket2.lean` (additive channel),
  and (if the engine lands there) `…/SubBracket2V.lean`.
- New lemmas: `kvE2_sepCoincidentAnchor_discharge` (+ extractor point channel),
  `kvE2_multiAnchor_sorted_realization`, `kvE2_sepJointArrangedL`, `kvE2_sepHonestBundleR`,
  `kvE2_sepJointArrangedR`; rewired `kvE2_sepBody_nonvacuous`; retired `kvE2_sepSlotsL_valid`/`_valid`.

## Rollback/Contingency

- All net-new work is additive within a small file set; `git` is the rollback mechanism. Before any
  destructive git op on a dirty tree, run `bash .claude/scripts/git-snapshot.sh` per the
  No-Destructive-Git rule.
- **Phase 3 (crux) resistance**: STOP; write a blocker handoff; do NOT vacuity-weaken the compat
  filter and do NOT reintroduce the single-point `mergeSort`. The point channel is the audit's
  HIGH-confidence dissolution; if it genuinely resists, the escalation is a targeted research
  sub-task on the extractor's closed-zone fold (NOT another single-point carrier — Rec-1).
- **Phase 4/5/6 overflow**: each is already near the smallest meaningful unit; commit the green
  portion (per-region engine, one arrangement side, or the 6a bundle) and resume; do not merge L
  and R.
- The reduced `kvE2_sepFreshAnchor_ne_baseChiPoint` and the Phase-1 switch are switch-independent
  landed assets; a clean baseline can retain them even if the lift is paused.
