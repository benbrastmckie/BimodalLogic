# Implementation Plan: Joint Slot-Level Sorted Realization (Non-Vacuity Carrier Switch)

- **Task**: 334 - joint_slot_sorted_realization_nonvacuity_carrier_switch
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours (7 phases; crux-gated)
- **Dependencies**: 333 (green, axiom-clean; landed assets reused, not rebuilt)
- **Research Inputs**: reports/01_joint-slot-sorted-realization.md
- **Artifacts**: plans/01_joint-slot-sorted-realization.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Date**: 2026-07-08

## Overview

Close the sole remaining Phase-2 non-vacuity gap that task 333 converged on: the joint
(multi-owner) model-sorted arrangement of Rabinovich 2014 Def 3.1 / Lemma 3.2(1)-⇐ direction.
Concretely, wire the arrangement-aware compat filter switch, prove `kvE2_sepJointSortedL/R`
(a slot-keyed `List.mergeSort` over the pullback order `fun a b => pt a ≤ pt b`), and rewire
`kvE2_sepBody_nonvacuous` off `List.Perm.refl` onto the joint sort. Definition of done:
`lake build …SharedWitness` green, joint-sort lemmas sorry-free, the top-level non-vacuity
theorem axiom-clean, and every binding faithfulness invariant preserved (never weaken to
vacuity). All work is confined to
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` and its
surrounding directory.

### Research Integration

Integrates `reports/01_joint-slot-sorted-realization.md` (hard-mode, Tier-1 grounded), which
supersedes the task-333 frontier's tie-freeness recommendation. Key conclusions folded into the
phase design:

- **Sort-without-Nodup is SOLVED.** `List.mergeSort` + `List.mergeSort_perm` (zero hypotheses)
  + `List.sorted_mergeSort'` (`Std.Total` + `IsTrans` only — no `Nodup`, no `Antisymm`) over
  `fun a b => decide (pt a ≤ pt b)`, with local `Std.Total`/`IsTrans` instances derived from
  `LinearOrder M.carrier`. This replaces the `Nodup`-bound `k1v_sorted_realization`, whose
  type-keyed `Nodup` premise is false on the joint list (same χ recurs across owners).
- **Tie-freeness — adversarial correction.** The frontier's resolution (a) "global `pt`
  injectivity" is judged LIKELY UNPROVABLE (cross-owner same-χ Classical witnesses may coincide)
  AND unnecessary. Resolution (b) secondary-key is rejected (leaves the same boundary obligation).
  Strictness isolates to a SINGLE boundary — a foreign base-χ point vs a fresh E[Σ]-atom anchor
  `x1_σ` — discharged by a targeted local lemma `kvE2_sepFreshAnchor_ne_baseChiPoint` plus
  `lt_of_le_of_ne`.
- **THE MAKE-OR-BREAK CRUX (confidence Low).** Provability of
  `kvE2_sepFreshAnchor_ne_baseChiPoint` is UNESTABLISHED. It is front-loaded as a dedicated early
  phase (Phase 2) with an explicit escalation path, so a Low-confidence failure is discovered
  BEFORE investing in ~300 lines of joint-sort scaffolding.
- **Phase-1 filter switch is a pure mechanical rewire.** HEAD carries the predicate defs; only
  `kvE2_sepSlotLe` (~:458) is still the old `||` form. Apply the rename hunks, SKIP the
  predicate-add hunk. The intended breakage (`kvE2_sepSlotsL_valid`/`_valid`,
  `kvE2_sepBody_nonvacuous`) is exactly what the joint sort repairs.

### Prior Plan Reference

No prior task-334 plan. The task-333 frontier (`handoffs/03_phase2-joint-sort-frontier.md`),
blueprint (`02_...blueprint.md`), and `phase1-switch-and-repairs.patch` are reference inputs.
The research report OVERRIDES the frontier's tie-freeness resolution (a) — do not attempt global
`pt` injectivity.

### Roadmap Alignment

No ROADMAP.md consulted for this dispatch. This task advances the WeakCanonical / Kamp
completeness line (Rabinovich Def 3.1 / Lemma 3.2(1)-⇐ transcription).

## Preserved Assets (binding — do NOT break)

Task 333 landed these green, axiom-clean; they are reused, not rebuilt. Any phase that touches
`SharedWitness.lean` must leave them functionally intact (byte-identical where not deliberately
rewired):

- The four cross-σ compat leaves: `kvE2_sepCompat_lX1_eq`, `kvE2_sepCompat_lX1_after_eq`,
  `kvE2_sepCompat_rX1_eq`, `kvE2_sepCompat_rX1_after_eq` (the complete set the sort consumes).
- `kvE2_sepHonestBundleL` (per-σ left-interior witness bundle; blueprint point-map step 1).
- The refined-segment machinery (`kvE2_sepSegLForSub`/`RForSub`) and the settled item-1a
  fresh-less-sub exclusion (compat correctly SILENT — no third clause).
- Do-not-edit assets: `kvE_subBracket2_complete_extract` (SubBracket2), `kvE2_sepGate_holds_of_honest`
  (gate branch), and all `kvE2_sepBracketN` point-type machinery.
- The 2 pre-existing tracked strategic sorries (`kvE2_sepSingleton_coverage_left` ~:1997,
  `kvE2_sepBody_singleton_complete_left` ~:2129) remain untouched — they are task-333 Phases 4/5,
  OUT of this task's primary scope.

## Goals & Non-Goals

**Goals**:
- Wire the arrangement-aware `kvE2_sepSlotLe` filter switch (mechanical rewire onto present predicates).
- Prove the make-or-break boundary lemma `kvE2_sepFreshAnchor_ne_baseChiPoint` (or escalate honestly).
- Add the right-interior bundle `kvE2_sepHonestBundleR` (mirror of the landed L bundle).
- Prove `kvE2_sepJointSortedL` and `kvE2_sepJointSortedR` via `List.mergeSort` over `pt`.
- Rewire `kvE2_sepBody_nonvacuous` off `List.Perm.refl` onto the joint sort.
- End green: `lake build …SharedWitness` exit 0, joint-sort lemmas sorry-free, top-level
  non-vacuity theorem axiom-clean.

**Non-Goals**:
- Discharging the 2 pre-existing strategic sorries (task-333 Phases 4/5, downstream).
- Phases 12/13 (N2-C gate + F4 adversarial hardening) — downstream, out of primary scope.
- Global `pt` injectivity (rejected by research as likely unprovable and unnecessary).
- Any edit outside `SharedWitness.lean` / the `NfMultiAnchorBridge/` directory.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `kvE2_sepFreshAnchor_ne_baseChiPoint` unprovable (fresh E[Σ]-atom vs base-χ point separation) — the make-or-break crux | H | M-H (confidence Low) | Front-load as Phase 2 BEFORE joint-sort scaffolding. Attempt the semantic E[Σ]-atom/nf0-base separation via `nfk_projFresh` + no-nesting/quantifier-free (Lemma 5.1). If it resists: ESCALATE (write a blocker handoff, spawn a research sub-task). Do NOT vacuity-weaken the filter. |
| Right-interior env/zone reading of `kvE_subBracket2_complete_extract` differs for `w < x1_σ < t` | M | M | Phase 3 first CONFIRMS which extractor/env applies (`kvE2_sep_zWX1 = (w,x1)` middle region) before mirroring. If no right-interior analog exists, check coordinate-relabeling reuse; document finding. |
| Phase-1 switch breaks 3 sites, leaving a red build mid-plan | M | H (intended) | Phase 1 inserts CLEARLY-LABELED temporary scaffolding sorries at the 3 intended-broken sites to keep the build green; these are removed by Phase 6 (NOT strategic division points). |
| Local `Std.Total`/`IsTrans` instances not auto-inferred for the pullback relation | L | M | One-liners from `LinearOrder M.carrier`: `⟨fun a b c => le_trans⟩` and `⟨fun a b => le_total (pt a) (pt b)⟩`; `DecidableRel` from `DecidableLE`. |
| Joint-sort proof exceeds one implementation-agent run (~200-300 lines) | M | M | Split L (Phase 4) and R (Phase 5) into separate phases; each ~150 lines, one run each. |

## Faithfulness Invariants (plan-level acceptance checks — every phase preserves ALL)

1. **Rabinovich Lemma 5.1** — quantifier-free point types (`charBase χ` / `charK (nfk_projFresh σ)`); no nesting introduced.
2. **Lemma 3.2(1) filter grounding** — never weaken to vacuity; the sorted honest arrangement IS the literal ⇐-witness.
3. **Lemma 3.2(2)** — anchor cap 2; free `(x,t)` framing and `kvE2_sepGate_holds_of_honest` untouched.
4. **No-nesting audit** — new code adds a sort + a distinctness lemma; no type nesting.
5. **LITMUS** — no `x1 < e_i` slot-index literal; comparisons are on carrier points (`pt a ≤ pt b`).
6. **F4 adversarial test must DISCRIMINATE** — the switch strengthens the filter (cross-σ compat replaces unconditional admission); never weaken the discriminator.
7. **Macro-side confinement** — L list only `(x,w)` slots, R only `(w,t)`.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 5 | 1, 2 (and 3 for Phase 5) |
| 3 | 6 | 4, 5 |
| 4 | 7 | 6 |

Phases within the same wave are logically parallel. NOTE (H7 territory): all phases edit the
single file `SharedWitness.lean`, so within a wave they MUST be executed serially by one agent at
a time to avoid write conflicts — the wave grouping expresses dependency freedom, not concurrent
file ownership. Recommended serial order: 1 → 2 → 3 → 4 → 5 → 6 → 7, with Phase 2 (the crux) as
the gate: if Phase 2 fails, STOP before Phases 4-6.

---

### Phase 1: Wire the arrangement-aware filter switch (mechanical) [COMPLETED]

**Goal**: Replace the old arrangement-blind `kvE2_sepSlotLe` (`||` form, ~:458) with the
`if kvE2_sepSlotSub a = kvE2_sepSlotSub b then decide (rank ≤ rank) else kvE2_sepCompat a b` form,
applying the `phase1-switch-and-repairs.patch` rename hunks by hand on HEAD (`04ea18425`).
SKIP the predicate-add hunk (predicate defs already present at HEAD, :344-389).

**Tasks**:
- [x] Rewrite `kvE2_sepSlotLe` body (~:458) to the `if`-form onto the present predicates.
- [x] Rename `kvE2_sepSlotLe_of_rank` → `kvE2_sepSlotLe_same` (add `hsub` premise).
- [x] Replace `kvE2_sepSlotLe_of_sub_ne` with `kvE2_sepSlotLe_of_ne_compat` (add `hc : kvE2_sepCompat a b = true`).
- [x] Add `kvE2_sep_pairwise_rank_same`; split `kvE2_sepSlotsLFor_pairwise`/`RFor_pairwise` into `_rankPairwise` (rank-only) + thin wrapper.
- [x] Fix the `rw` at old `kvE2_sep_index_lt_of_rank_lt` (~:1234): `decide_eq_true hsub.symm, Bool.not_true, Bool.false_or, decide_eq_true_eq` → `if_pos hsub.symm, decide_eq_true_eq`.
- [x] Insert CLEARLY-LABELED temporary scaffolding sorries at the intended-broken sites *(deviation: altered — only 2 scaffold sorries needed, at `kvE2_sepSlotsL_valid` and `kvE2_sepSlotsR_valid`; `kvE2_sepBody_nonvacuous` compiles unchanged by referencing the two sorried `_valid` lemmas, so no third scaffold sorry is introduced. Both scaffold lemmas are removed in Phase 6.)*

**Timing**: 1-1.5 hours.

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — filter switch + mechanical renames + 3 scaffold sorries.

**Produces**: `kvE2_sepSlotLe` (if-form), `kvE2_sepSlotLe_same`, `kvE2_sepSlotLe_of_ne_compat`, `kvE2_sep_pairwise_rank_same`, split `_rankPairwise`/`_pairwise` wrappers.

**Faithfulness invariants**: pure refactor onto already-verified predicates — no semantic change to the compat filter, anchor cap, or free-variable framing (invariants 2, 3, 6, 7 preserved by construction).

**Verification / acceptance**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` exit 0.
- Sorry inventory: 2 pre-existing strategic + exactly 3 labeled scaffold sorries; 0 new axioms.
- Preserved assets (compat leaves, `kvE2_sepHonestBundleL`, do-not-edit assets) byte-identical.

---

### Phase 2: CRUX — prove `kvE2_sepFreshAnchor_ne_baseChiPoint` (make-or-break, front-loaded) [NOT STARTED]

**Goal**: Prove the single boundary-distinctness lemma the joint sort needs to upgrade `≤` to
strict `<` in the two binding cross-σ cases. Statement (to confirm/refine at implementation):

> For a positive owner σ with fresh anchor `x1_σ` (realizing `charK (nfk_projFresh σ)`, an
> E[Σ]-atom / nf1 fresh-coordinate type) and any foreign base-χ point `p` realizing an nf0 type χ
> (χ ∈ some τ's zXU/zUW set), `p ≠ x1_σ`.

This is the residual make-or-break (confidence Low): `nf_eval_unique` separates nf0-vs-nf0 but
does NOT forbid one carrier point realizing both an nf1 E[Σ]-atom and an nf0 base χ. A semantic
E[Σ]-atom / base-χ separation argument is required.

**Tasks**:
- [ ] State `kvE2_sepFreshAnchor_ne_baseChiPoint` precisely (fix env, owner, and the χ side conditions).
- [ ] Attempt the semantic separation: the fresh anchor's E[Σ]-atom type (via `nfk_projFresh σ`) is incompatible with an nf0 base-χ realization at the same point — grounded in the no-nesting / quantifier-free constraints (Lemma 5.1). Search for/verify supporting in-house lemmas (`nf_eval_unique` seeds nf0-vs-nf0 only; find the E[Σ]-atom vs nf0-base discriminator).
- [ ] If a direct type-class separation exists: prove sorry-free, axiom-clean.
- [ ] ESCALATION (if it resists after a bounded attempt): do NOT vacuity-weaken. Write a blocker handoff documenting the exact goal state, what was tried, and the missing semantic lemma; recommend a dedicated research sub-task. STOP the plan here (do not proceed to Phases 4-6 on a false foundation).

**Timing**: 2-4 hours (or escalate).

**Depends on**: none (independent of the switch; sequenced early to gate the joint sort).

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add the boundary lemma.

**Produces**: `kvE2_sepFreshAnchor_ne_baseChiPoint` (sorry-free) OR a blocker handoff + escalation.

**Faithfulness invariants**: matches Def 3.1's "strictly increasing ACROSS decomposition boundaries" (the boundaries are the fresh anchors) without over-claiming strictness everywhere (invariants 1, 2, 5 central here — no vacuity fallback).

**Verification / acceptance**:
- On success: lemma compiles green, sorry-free, axiom-clean; `lake build …SharedWitness` exit 0.
- On resistance: explicit blocker handoff written; plan status set to reflect escalation; NO vacuity weakening applied.

---

### Phase 3: Add right-interior bundle `kvE2_sepHonestBundleR` (mirror) [NOT STARTED]

**Goal**: Mirror the landed `kvE2_sepHonestBundleL` for right-interior owners, FIRST confirming
the right-interior env/zone reading of `kvE_subBracket2_complete_extract` (Risk §2). For a
right-interior σ (`w < x1_σ < t`), confirm `kvE_sub2_zXU` reads `(x,w)`, `kvE_sub2_zWT` reads
`(x1,t)`, middle region `kvE2_sep_zWX1 = (w,x1)` before mirroring.

**Tasks**:
- [ ] Confirm which extractor/env the right-interior realization uses (mirror gate branch; coordinate-relabeling reuse of the do-not-edit asset, or a right-interior analog). Document the finding inline.
- [ ] State `kvE2_sepHonestBundleR` mirroring the L bundle (per-σ right-list witnesses, strict interval bounds).
- [ ] Prove it, reusing `kvE_subBracket2_complete_extract` under the confirmed env; no `x1 < e_i` literal (LITMUS-clean).

**Timing**: 1.5-2.5 hours.

**Depends on**: none (independent mirror; needed by Phase 5).

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add `kvE2_sepHonestBundleR`.

**Produces**: `kvE2_sepHonestBundleR` (per-σ right-interior witness bundle).

**Faithfulness invariants**: invariant 5 (LITMUS: no `x1 < e_i`), invariant 7 (R list only `(w,t)` slots). No type nesting (invariant 4).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0; `kvE2_sepHonestBundleR` sorry-free, axiom-clean.
- Right-interior env/zone reading documented (Risk §2 resolved or flagged).

---

### Phase 4: Prove `kvE2_sepJointSortedL` (left list joint sort) [NOT STARTED]

**Goal**: Build the left-list joint model-sorted arrangement:
`∃ πL, List.Perm πL (kvE2_sepSlotsL qnf) ∧ kvE2_sepValid πL = true`, via `List.mergeSort` over the
pullback order, transferred to `kvE2_sepSlotLe`-Pairwise, with the two binding cross-σ cases
upgraded to strict via Phase 2's boundary lemma.

**Tasks**:
- [ ] Define the noncomputable `pt : KvE2SepSlot sig → M.carrier` (Classical) from `kvE2_sepHonestBundleL`: `.lX1 σ ↦ x1_σ`, `.lXU σ χ ↦` witness in `(x, x1_σ)`, `.lUW σ χ ↦` witness in `(x1_σ, w)`.
- [ ] Provide local instances `IsTrans _ (fun a b => pt a ≤ pt b)` and `Std.Total _ (…)` from `LinearOrder M.carrier`; `DecidableRel` from `DecidableLE`.
- [ ] `πL := kvE2_sepSlotsL qnf |>.mergeSort (fun a b => decide (pt a ≤ pt b))`; obtain `List.mergeSort_perm` (Perm) and `List.sorted_mergeSort'` (`Pairwise (pt · ≤ pt ·)`).
- [ ] Transfer to `Pairwise (kvE2_sepSlotLe · = true)` via `List.Pairwise.imp`, casing per pair on owner-equality and slot kind: same-owner ⇒ rank (model-order-refines-rank from strict bundle bounds `x<u<x1<u'<w`); two-foreign-χ ⇒ `kvE2_sepCompat` unconditional.
- [ ] Case A/B (foreign χ before `.lX1 σ` / `.lX1 σ` before foreign χ): upgrade `pt a ≤ x1_σ` to `<` via `kvE2_sepFreshAnchor_ne_baseChiPoint` + `lt_of_le_of_ne`; feed `pt`'s witness into the fold ⇐ (`kvE_subBracket2_complete_extract`'s `h_zonefwd`); close with `kvE2_sepCompat_lX1_eq` / `kvE2_sepCompat_lX1_after_eq`.

**Timing**: 2.5-3.5 hours (~150-200 lines).

**Depends on**: 1 (switched predicates), 2 (boundary lemma).

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add `pt` (L), local instances, `kvE2_sepJointSortedL`.

**Produces**: `kvE2_sepJointSortedL` (sorry-free), the L point map, local order instances.

**Faithfulness invariants**: invariants 1, 2 (honest arrangement = literal ⇐-witness, no vacuity), 5 (carrier-point comparisons, no `x1 < e_i`), 6 (compat leaves prove bad interleavings REJECTED), 7 (L only `(x,w)`).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0; `kvE2_sepJointSortedL` sorry-free, axiom-clean.
- Uses only the four landed compat leaves + Phase 2 lemma for strictness (no global-injectivity route).

---

### Phase 5: Prove `kvE2_sepJointSortedR` (right list joint sort, mirror) [NOT STARTED]

**Goal**: Mirror Phase 4 for the right list:
`∃ πR, List.Perm πR (kvE2_sepSlotsR qnf) ∧ kvE2_sepValid πR = true`, using `kvE2_sepHonestBundleR`
and the right-list compat leaves.

**Tasks**:
- [ ] Extend `pt` to R slots (`.rX1 σ ↦ x1_σ`, `.rXW`/right-region χ witnesses) from `kvE2_sepHonestBundleR`.
- [ ] `πR := kvE2_sepSlotsR qnf |>.mergeSort (…)`; Perm + Pairwise as in Phase 4.
- [ ] Transfer to `kvE2_sepSlotLe`-Pairwise; Case A/B via `kvE2_sepFreshAnchor_ne_baseChiPoint` + `kvE2_sepCompat_rX1_eq` / `kvE2_sepCompat_rX1_after_eq` and the `zWX1`/`zWT` zones.

**Timing**: 2.5-3.5 hours (~150-200 lines).

**Depends on**: 1, 2, 3.

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add `pt` (R), `kvE2_sepJointSortedR`.

**Produces**: `kvE2_sepJointSortedR` (sorry-free).

**Faithfulness invariants**: same as Phase 4, with invariant 7 (R only `(w,t)`).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0; `kvE2_sepJointSortedR` sorry-free, axiom-clean.

---

### Phase 6: Rewire `kvE2_sepBody_nonvacuous` off `List.Perm.refl` [NOT STARTED]

**Goal**: Rewire `kvE2_sepBody_nonvacuous` (~:1095) to exhibit `πL`/`πR` from
`kvE2_sepJointSortedL`/`R` instead of `List.Perm.refl` + the now-false identity-arrangement
lemmas. Remove the 3 Phase-1 scaffold sorries. Retire `kvE2_sepSlotsL_valid`/`_valid` and
`kvE2_sepSlotLe_of_sub_ne` (now false/unused). Gate branch `kvE2_sepGate_holds_of_honest`
UNCHANGED.

**Tasks**:
- [ ] Replace the `List.Perm.refl` (~:1112/:1116) witnesses with `kvE2_sepJointSortedL`/`R`.
- [ ] Remove the 3 scaffold sorries added in Phase 1.
- [ ] Delete/retire `kvE2_sepSlotsL_valid`, `kvE2_sepSlotsR_valid`, `kvE2_sepSlotLe_of_sub_ne`.
- [ ] Confirm the `dite` gate guard still discharged by the unchanged `kvE2_sepGate_holds_of_honest`.

**Timing**: 1-1.5 hours.

**Depends on**: 4, 5.

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — rewire nonvacuity; retire dead lemmas.

**Produces**: rewired `kvE2_sepBody_nonvacuous` (scaffold-sorry-free).

**Faithfulness invariants**: invariant 2 (non-vacuity now proven by the honest arrangement, not vacuity), invariant 3 (gate branch untouched).

**Verification / acceptance**:
- `lake build …SharedWitness` exit 0.
- Sorry inventory back to exactly the 2 pre-existing strategic sorries (0 scaffold sorries remain).
- No `List.Perm.refl` in `kvE2_sepBody_nonvacuous`.

---

### Phase 7: Final verification (build + sorry inventory + axiom check) [NOT STARTED]

**Goal**: Confirm the completed non-vacuity closure end-to-end.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` — green, exit 0.
- [ ] Sorry inventory on `SharedWitness.lean`: exactly the 2 pre-existing strategic sorries, 0 new/scaffold.
- [ ] Axiom check (`lean_verify` / `#print axioms`) on the top-level non-vacuity theorem (`kvE2_sepBody_nonvacuous` and its dependents) — no new axioms beyond `[propext, Quot.sound, Classical.choice]`.
- [ ] Diff-audit preserved assets (four compat leaves, `kvE2_sepHonestBundleL`, do-not-edit assets) — functionally intact.
- [ ] Confirm all 7 faithfulness invariants hold across the final file.

**Timing**: 0.5-1 hour.

**Depends on**: 6.

**Files to modify**: none (verification only).

**Produces**: verification report (sorry inventory, axiom check, invariant confirmation) for the summary.

**Verification / acceptance**:
- Build green; sorry inventory = 2 pre-existing strategic; axiom-clean top-level theorem; invariants confirmed.

## Testing & Validation

- [ ] `lake build …SharedWitness` exit 0 after each phase (green build discipline; scaffold sorries permitted only between Phases 1 and 6).
- [ ] `kvE2_sepFreshAnchor_ne_baseChiPoint`, `kvE2_sepHonestBundleR`, `kvE2_sepJointSortedL`, `kvE2_sepJointSortedR` each sorry-free and axiom-clean.
- [ ] Final sorry inventory = exactly 2 pre-existing strategic sorries (no regressions, no scaffold residue).
- [ ] Axiom check on `kvE2_sepBody_nonvacuous`: no new axioms.
- [ ] All 7 faithfulness invariants preserved; never weakened to vacuity.

## Artifacts & Outputs

- plans/01_joint-slot-sorted-realization.md (this file)
- summaries/01_joint-slot-sorted-realization-summary.md (on completion)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- New lemmas: `kvE2_sepFreshAnchor_ne_baseChiPoint`, `kvE2_sepHonestBundleR`, `kvE2_sepJointSortedL`, `kvE2_sepJointSortedR`; rewired `kvE2_sepBody_nonvacuous`; switched `kvE2_sepSlotLe`.

## Rollback/Contingency

- All work is a single file; `git` is the rollback mechanism. Before any destructive git op on a
  dirty tree, run `bash .claude/scripts/git-snapshot.sh` per the No-Destructive-Git rule.
- If Phase 2 (crux) resists: STOP; write a blocker handoff; do NOT vacuity-weaken the filter to
  force a green build. The filter is too STRONG only if a macro-side-confinement invariant is
  broken by plumbing — never relax the consistency condition. Escalate to a dedicated research
  sub-task on the E[Σ]-atom / base-χ semantic separation.
- If a joint-sort phase (4/5) exceeds a single agent run, the phase is already the smallest
  meaningful unit (one list); commit the green portion and resume; do not merge L and R.
