# Research Report: Joint Slot-Level Sorted Realization (Non-Vacuity Carrier Switch)

- **Task**: 334 — joint_slot_sorted_realization_nonvacuity_carrier_switch
- **Date**: 2026-07-08
- **Status**: researched
- **Agent**: lean-research-hard-agent (H2 + H3 + H4, Tier 1 literature grounding)
- **Session**: sess_1783528900_f190c7
- **Primary file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (2131 lines, HEAD `04ea18425`)
- **Ground-truth source**: Rabinovich 2014, *A Proof of Kamp's Theorem*, LMCS 10(1:14) — Def 3.1, Lemma 3.2(1).

---

## Executive Summary

The sole remaining gap (joint multi-owner model-sorted arrangement, Rabinovich Def 3.1 / Lemma 3.2(1) ⇐-direction) **decomposes cleanly into two independent sub-problems**, and research settles them asymmetrically:

1. **The sort itself is fully solved and Nodup-free.** `List.mergeSort` + `List.mergeSort_perm` (zero hypotheses) + `List.sorted_mergeSort'` (`Std.Total` + `IsTrans` only — *no* `Nodup`, *no* `Std.Antisymm`) give a permutation of the joint slot list that is `List.Pairwise (fun a b => pt a ≤ pt b)`, where `pt` is the (noncomputable, `Classical`) slot→carrier point map. All signatures verified via lean-lsp. This is the correct replacement for the `Nodup`-bound `k1v_sorted_realization`.

2. **Tie-freeness is the true make-or-break, and it does NOT reduce to global point-injectivity.** ADVERSARIAL FINDING (modifies the task-333 frontier recommendation): the frontier's recommended resolution (a) "prove `pt` injective on the slot list" is **likely unprovable**, because two distinct owners' `Classical`-chosen witnesses for the *same* base type χ can legitimately coincide as one carrier point (nothing in the per-χ existentials forces cross-owner distinctness). The strictness obligation localizes to a single boundary — a foreign base-χ point versus a fresh E[Σ]-atom anchor `x1_σ` — and *that* local distinctness is the genuine residual risk. Recommendation below reframes (a) as a **targeted local lemma**, not global injectivity, and shows resolution (b) does not eliminate the same boundary obligation.

3. **Step-1 filter switch is a faithful mechanical rewire.** HEAD already carries the predicate defs (`kvE2_sepCompat`, `kvE2_sepSlotChi`, `kvE2_sepFreshZoneBefore/After`, lines 344–389); only `kvE2_sepSlotLe` (:458) is still the old arrangement-blind `||` form. Applying the patch's rename hunks by hand (skipping the predicate-add hunk) is a pure refactor onto already-present, already-verified predicates.

No binding faithfulness constraint is violated by the recommended plan.

---

## Findings

### 5-Column Lemma Mapping Table (H3, Tier 1)

Every Mathlib lemma below was confirmed via lean-lsp (`lean_loogle` / `lean_leansearch`); signatures are the verbatim tool output.

| Paper construct (Rabinovich) | Target Lean lemma | Existing Mathlib support (verified name + signature) | Reuse verdict | Risk / note |
|---|---|---|---|---|
| **Def 3.1** — strictly-increasing model-sorted witness order over ALL owners | `kvE2_sepJointSortedL` / `_R` (new, ~200–300 ln) | `List.mergeSort_perm (l : List α) (le : α → α → Bool) : (l.mergeSort le).Perm l` — **no hypotheses** (module `Init.Data.List.Sort.Lemmas`) | **build-from-scratch** (uses Mathlib sort as engine) | Perm is unconditional; safe. |
| **Def 3.1** — the *sorted* (non-decreasing) property of the arrangement | (inside `kvE2_sepJointSortedL/R`) | `List.sorted_mergeSort' (r : α→α→Prop) [DecidableRel r] [Std.Total r] [IsTrans α r] (l) : List.Pairwise r (l.mergeSort fun a b => decide (r a b))` (`Mathlib.Data.List.Sort`; alias `List.pairwise_mergeSort'`) | **adapt** (instantiate `r := fun a b => pt a ≤ pt b`) | **Requires only `Std.Total` + `IsTrans`** — NO `Nodup`, NO `Std.Antisymm`. Both instances follow from `LinearOrder M.carrier` (pullback along `pt`); must be provided as local instances. See §Sort-without-Nodup. |
| **Lemma 3.2(1) ⇐** — every honest arrangement is admitted (validity of the sorted order) | validity clause of `kvE2_sepJointSortedL/R` | `List.Pairwise.imp {R S} (H : ∀ {a b}, R a b → S a b) : Pairwise R l → Pairwise S l`; `List.Pairwise.iff_of_mem (H : ∀ {a b}, a∈l → b∈l → (R a b ↔ S a b)) : Pairwise R l ↔ Pairwise S l` (both `Init.Data.List.Pairwise`) | **adapt** (transfer `pt`-order Pairwise → `kvE2_sepSlotLe`-Pairwise) | The `imp`/`iff_of_mem` step needs per-pair `pt a ≤ pt b → kvE2_sepSlotLe a b`; the cross-σ binding cases need STRICT `<` (tie risk). |
| **Lemma 3.2(1)** cross-σ before-fresh admission | (validity, Case A) | in-house `kvE2_sepCompat_lX1_eq` (:405) `: kvE2_sepCompat a (.lX1 σ) = kvE2_sepBits σ kvE_sub2_zXU χ` (when `kvE2_sepSlotChi a = some χ`) — **landed, axiom-clean** | **reuse (in-house)** | Consumes a point strictly in `(x, x1_σ)`; strictness is the tie risk. |
| **Lemma 3.2(1)** cross-σ after-fresh admission | (validity, Case B) | in-house `kvE2_sepCompat_lX1_after_eq` (:423), `kvE2_sepCompat_rX1_eq` (:435), `kvE2_sepCompat_rX1_after_eq` (:447) — **landed** | **reuse (in-house)** | The four compat leaves are the complete set the sort consumes. |
| **Def 3.1** per-owner region witnesses (point-map step 1, LEFT) | reuse `kvE2_sepHonestBundleL` (:1053) | in-house; yields `∃ x1, x<x1 ∧ x1<w ∧ (∀χ∈zXU-set, ∃u∈(x,x1) realizing χ) ∧ (∀χ∈zUW-set, ∃u∈(x1,w) realizing χ)` — **landed** | **reuse (in-house)** | Strict bounds `x<u<x1` and `x1<u<w` are what give within-owner region separation. |
| **Def 3.1** per-owner region witnesses (RIGHT) | `kvE2_sepHonestBundleR` (new, mirror) | mirror of `kvE2_sepHonestBundleL`; depends on right-interior extractor/env | **adapt** (mirror) | MEDIUM risk: right-interior env/zone reading of `kvE_subBracket2_complete_extract` must be confirmed (see §Risks). |
| **Def 3.1** point-distinctness at decomposition boundaries | `nf_eval_unique` (local, `NormalForm.lean:245`) | `Bimodal.Metalogic.WeakCanonical.nf_eval_unique` — **exists locally** (distinct complete 1-types exclude each other at a point) | **reuse (in-house)** | Powers within-owner same-region distinctness AND is the seed for the boundary lemma — but does NOT by itself separate a base-χ point from an E[Σ]-atom anchor (different type classes). |
| **Def 3.1** slot list is duplicate-free (needed only for the *permutation faithfulness*, not the sort) | `kvE2_sepSlotsL_nodup` (new, provable) | `List.nodup_flatMap : (List.flatMap f l₁).Nodup ↔ (∀ x ∈ l₁, (f x).Nodup) ∧ List.Pairwise (Function.onFun List.Disjoint f) l₁` (`Mathlib.Data.List.Nodup`) | **build (short)** | Owners disjoint (distinct `kvE2_sepSlotSub`), `kvE2_sepPos` Nodup (`kvE2_sepPos_nodup` :848), each block Nodup. Provable. Note: NOT required by `mergeSort`; only if an injectivity route is attempted. |
| **Lemma 3.2(2)** anchor cap 2, free `(x,t)` framing | `kvE2_sepGate_holds_of_honest` (unchanged) | in-house — discharges the `dite` guard in `kvE2_sepBody_nonvacuous` | **reuse (in-house, untouched)** | Rewire must not touch the gate branch. |

UNVERIFIED entries: none. Every cited Mathlib name returned a matching signature from lean-lsp.

---

### Sort-Without-Nodup Analysis (core technical question)

**Why `k1v_sorted_realization` cannot lift.** `k1v_sorted_realization` (`CarrierK1V.lean:1447`) takes `(S : List (NormalForm sig 0 1)) (hnd : S.Nodup)` and sorts *types* keyed by a per-type witness point. Its induction uses `hnd` at exactly one place — proving the new point is distinct from all listed points:

```
have hne : ∀ p ∈ ps', p.2 ≠ u := fun p hp heq =>
  … nf_eval_unique … (χ ∈ S' contradiction from Nodup) …
```

For the JOINT list `kvE2_sepSlotsL qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor`, the SAME base type χ recurs under different owners (σ's `.lXU σ χ` and τ's `.lXU τ χ` are two distinct slots of one type). A type-keyed `Nodup` premise is therefore FALSE on types, and `nf_eval_unique` cannot separate the two owners' χ-points. Confirmed against the definitions at `SharedWitness.lean:292–322`.

**The Mathlib sort avoids Nodup entirely.** Sort *slots* (which ARE distinct) keyed by real model points:

- `pt : KvE2SepSlot sig → M.carrier` — noncomputable, via `Classical.choice` on the `kvE2_sepHonestBundleL/R` existentials: `.lX1 σ ↦ x1_σ`, `.lXU σ χ ↦` a witness in `(x, x1_σ)`, `.lUW σ χ ↦` a witness in `(x1_σ, w)` (and the R-mirror).
- `le := fun a b => decide (pt a ≤ pt b)`. `M.carrier` carries `LinearOrder` (`MonadicFO.lean:104`, `carrier_order : LinearOrder carrier`, registered as instance :108), so `≤` is total, transitive, and decidable.
- `List.mergeSort_perm` gives `(sorted).Perm (kvE2_sepSlotsL qnf)` — **no hypotheses at all**.
- `List.sorted_mergeSort'` (with `r := fun a b => pt a ≤ pt b`) gives `List.Pairwise (fun a b => pt a ≤ pt b) sorted` — requiring ONLY `[DecidableRel r] [Std.Total r] [IsTrans α r]`.

**Instance provision (engineering note).** `Std.Total`/`IsTrans` for the pullback relation are not auto-inferred; supply them locally, e.g. `haveI : IsTrans _ (fun a b => pt a ≤ pt b) := ⟨fun a b c => le_trans⟩` and `haveI : Std.Total (fun a b => pt a ≤ pt b) := ⟨fun a b => le_total (pt a) (pt b)⟩`. Both are immediate from `LinearOrder M.carrier`. `DecidableRel` comes from `LinearOrder`'s `DecidableLE`.

**Conclusion**: the sort machinery is `Nodup`-free and fully in Mathlib. `Nodup` re-enters (if at all) only via the *strictness* argument — decoupled below.

---

### Tie-Freeness Resolution Recommendation

`List.sorted_mergeSort'` yields only `pt a ≤ pt b` (non-strict) for `a` before `b`. Two cross-σ validity cases need STRICT `<`:

- **Case A**: foreign χ-slot `a` (owner τ) before `.lX1 σ`. Need `pt a < x1_σ` to place `pt a ∈ (x, x1_σ)` (strict-open zone `kvE_sub2_zXU`; confirmed strict — `kvE2_sepHonestBundleL` derives `hbelowXU : u < x1` and `hbelowUW : x1 < u`, both strict) and read σ's `zXU` bit via the fold ⇐, closing with `kvE2_sepCompat_lX1_eq`.
- **Case B**: `.lX1 σ` before foreign χ-slot `b`. Need `x1_σ < pt b` symmetrically via `kvE2_sepCompat_lX1_after_eq` and the `zUW` zone.

(Two foreign χ-slots: `kvE2_sepCompat` is unconditionally `true` — no strictness needed. Same-owner pairs: `kvE2_sepSlotLe` checks region RANK, and the bundle's strict region bounds `x<u<x1<u'<w` give model-order-refines-rank without any tie-break. So the strictness obligation is ISOLATED to Cases A/B — a foreign χ point vs a fresh anchor.)

**Evaluation of the two candidate resolutions (against Def 3.1 and the verified Mathlib support):**

- **(a) as stated in the frontier — global point-injectivity of `pt`: REJECT.** ADVERSARIAL FINDING. The point map draws each χ-witness from a per-owner existential (`kvE2_sepHonestBundleL`'s `∀ χ ∈ kvE2_sepS σ zXU, ∃ u, x < u ∧ u < x1_σ ∧ …`). For owners σ ≠ τ both carrying the same χ, the two `Classical`-chosen witnesses `u_σ`, `u_τ` are NOT forced distinct — if the χ-region is realized at overlapping intervals they may be the *same* carrier point. Global injectivity of `pt` is thus not guaranteed and is plausibly false. Moreover it is UNNECESSARY: two foreign χ-slots sharing a point is harmless (`kvE2_sepCompat` unconditional there). So global injectivity over-shoots the obligation.

- **(b) secondary-key strict sort (pt, ownerIdx, rank): REJECT as standalone.** A strict lex order makes the sort a strict total order, but in Case A a lex-`before` still permits `pt a = x1_σ` (broken by the secondary key). To read σ's `zXU` bit we STILL need `pt a < x1_σ` strictly, i.e. we STILL must prove "`pt a = x1_σ ⇒ a` is same-owner as σ" — the identical boundary lemma. So (b) does not eliminate the crux; it only adds machinery.

- **(a-local) RECOMMENDED — a targeted boundary-distinctness lemma.** Sort by the total preorder `pt a ≤ pt b` (Mathlib `sorted_mergeSort'`, verified), and discharge Cases A/B with a single local lemma:

  > **`kvE2_sepFreshAnchor_ne_baseChiPoint`** (to prove): for a positive owner σ with fresh anchor `x1_σ` (realizing `charK (nfk_projFresh σ)`, an E[Σ]-atom / nf1 fresh-coordinate type) and any foreign base-χ point `p` realizing an nf0 type χ (χ ∈ some τ's zXU/zUW set), `p ≠ x1_σ`.

  Given this, `pt a ≤ x1_σ` (Case A) upgrades to `pt a < x1_σ` via `lt_of_le_of_ne`, and symmetrically for Case B. This matches Def 3.1's requirement that witnesses be **strictly increasing across the decomposition boundaries** (md:61–74) — the boundaries are exactly the fresh anchors — without over-claiming strictness everywhere (Def 3.1 does not require distinct witnesses of the SAME interval type across different reference points).

**Concrete recommendation.** Adopt (a-local):
1. Sort with `List.mergeSort (fun a b => decide (pt a ≤ pt b))`; obtain `Perm` (`List.mergeSort_perm`) and `Pairwise (pt · ≤ pt ·)` (`List.sorted_mergeSort'` + local `Std.Total`/`IsTrans` instances).
2. Transfer to `Pairwise (kvE2_sepSlotLe · = true)` via `List.Pairwise.imp`, per-pair casing on owner-equality and slot kind, using the four landed compat leaves.
3. In the two binding cross-σ cases, upgrade `≤` to `<` with `kvE2_sepFreshAnchor_ne_baseChiPoint` and `lt_of_le_of_ne`, then feed `pt`'s witness into the fold ⇐ (`kvE_subBracket2_complete_extract`'s `h_zonefwd`).

**RESIDUAL RISK (make-or-break, flagged honestly).** The provability of `kvE2_sepFreshAnchor_ne_baseChiPoint` is NOT established by this research. `nf_eval_unique` separates two nf0 base types at a point but does not, on its own, forbid a single carrier point from realizing BOTH an nf1 E[Σ]-atom (as σ's fresh anchor) AND an nf0 base χ. The lemma must be grounded in a semantic argument that the fresh anchor's E[Σ]-atom type (via `nfk_projFresh` and the no-nesting / quantifier-free constraints, Lemma 5.1) is incompatible with the base-χ realization at the same point — OR the construction must be shown to place fresh anchors off the base-χ witness set. This is the first thing the implementer should attempt and, if it resists, the point at which to escalate (it is the literal ⇐-witness boundary of Lemma 3.2(1) and must not be papered over with a vacuity weakening).

---

### Step-1 Filter-Switch Grounding

Confirmed faithful and low-risk. At HEAD (`04ea18425`):
- Predicate defs are ALREADY present: `kvE2_sepSlotChi` (:344), `kvE2_sepFreshZoneBefore` (:362), `kvE2_sepFreshZoneAfter` (:371), `kvE2_sepCompat` (:385). Their bodies match the patch's predicate-add hunk verbatim.
- `kvE2_sepSlotLe` (:458) is STILL the old arrangement-blind form `!(decide (sub a = sub b)) || decide (rank a ≤ rank b)`, and the old lemma names `kvE2_sepSlotLe_of_rank` (:762) / `kvE2_sepSlotLe_of_sub_ne` (:768) are unchanged.

Step 1 therefore applies ONLY the patch's mechanical-rename hunks (skip the predicate-add hunk, which would conflict):
- Rewrite `kvE2_sepSlotLe` body to the `if kvE2_sepSlotSub a = kvE2_sepSlotSub b then decide (rank ≤ rank) else kvE2_sepCompat a b` form.
- `kvE2_sepSlotLe_of_rank → kvE2_sepSlotLe_same` (add `hsub` premise); replace `kvE2_sepSlotLe_of_sub_ne` with `kvE2_sepSlotLe_of_ne_compat` (adds `hc : kvE2_sepCompat a b = true`).
- Add `kvE2_sep_pairwise_rank_same`; split `kvE2_sepSlotsLFor_pairwise`/`RFor_pairwise` into `_rankPairwise` (rank-only) + a thin wrapper.
- Fix the `rw` at the old `kvE2_sep_index_lt_of_rank_lt` (:1234-region): `decide_eq_true hsub.symm, Bool.not_true, Bool.false_or, decide_eq_true_eq` → `if_pos hsub.symm, decide_eq_true_eq`.

**Faithfulness**: pure refactor of the validity relation onto already-defined, already-verified predicates — no semantic change to the compat filter, anchor cap, or free-variable framing. **Risk**: the two identity-arrangement lemmas `kvE2_sepSlotsL_valid` (:853) / `kvE2_sepSlotsR_valid` (:865) will FAIL after the switch (they invoke `kvE2_sepSlotLe_of_sub_ne` unconditionally). This is the *intended* breakage; it is exactly what the joint sort must repair, and it is why `kvE2_sepBody_nonvacuous` (:1095) must be rewired off `List.Perm.refl` (:1112/:1116) onto `kvE2_sepJointSortedL/R`. Everything else downstream compiles.

---

### Faithfulness Ledger Check (binding constraints)

| Binding constraint (tasks 321 / 333) | Status under the recommended plan |
|---|---|
| Rabinovich Lemma 5.1 — quantifier-free point types | PRESERVED. `pt` reads only `charBase χ` (nf0) and `charK (nfk_projFresh σ)` (E[Σ]-atom) points; the sort/validity never introduces a nested or quantified type. |
| Lemma 3.2(1) filter grounding — never weaken to vacuity | PRESERVED. The sorted honest arrangement IS the literal ⇐-witness; the recommendation explicitly forbids a vacuity fallback and flags the boundary lemma as the escalation point instead. |
| Lemma 3.2(2) — anchor cap 2 | PRESERVED. `kvE2_sepGate_holds_of_honest` and the free `(x,t)` framing are untouched; the sort operates on the slot enumeration only. |
| No-nesting audit | PRESERVED. New code adds a sort + a point-distinctness lemma; no type nesting. |
| LITMUS — no `x1 < e_i` literal | PRESERVED. `pt`/sort compare CARRIER points (`pt a ≤ pt b`), and the fresh anchor bounds come from `kvE2_sepHonestBundleL` (which is already LITMUS-clean per task 333); no `x1 < e_i` slot-index literal is introduced. |
| F4 adversarial test must DISCRIMINATE | PRESERVED. The switch strengthens the filter (cross-σ compat replaces unconditional admission); it does not weaken the discriminator. The compat leaves prove the bad interleaving is REJECTED. |
| Macro-side confinement — L list only `(x,w)` slots, R only `(w,t)` | PRESERVED. `kvE2_sepSlotsL/R` are unchanged; `pt` maps L-slots into `(x,w)` and R-slots into `(w,t)` per the bundle. |

No violation identified.

---

## Adversarial Self-Verification (H4)

Re-checked every cited Mathlib lemma against its claimed use; challenged the "sort-without-Nodup" claim for a smuggled distinctness side-condition.

### Claim Verification Table

| Claim | Source / Counterexample checked | Verification Method | Confidence |
|---|---|---|---|
| `List.mergeSort_perm` gives a permutation with no hypotheses | signature has no `Nodup`/order args | lean_loogle hit (exact signature returned) | High |
| `List.sorted_mergeSort'` needs only `Std.Total` + `IsTrans` (no `Nodup`, no `Antisymm`) | Challenged: does it smuggle distinctness via antisymmetry? Signature shows `[DecidableRel] [Std.Total] [IsTrans]` ONLY; the antisymm-requiring siblings (`mergeSort_eq_self`, `coe_sort`) are DIFFERENT lemmas | lean_leansearch + lean_loogle (both returned the signature; antisymm siblings distinguished) | High |
| Pullback relation `fun a b => pt a ≤ pt b` is Total + Trans + Decidable | `M.carrier` has `LinearOrder` (instance) | lean_local_search + Read of `MonadicFO.lean:104-108` | High |
| The sort avoids Nodup; Nodup only powered the OLD point-distinctness step | Read `k1v_sorted_realization` (`CarrierK1V.lean:1464-1469`): `hnd` used solely for `hne : p.2 ≠ u` via `nf_eval_unique` | Read of source | High |
| Global `pt`-injectivity (frontier resolution a) is likely UNPROVABLE | Cross-owner same-χ witnesses drawn from independent existentials (`kvE2_sepHonestBundleL:1061-1064`) — no distinctness forced | Read of source + logical analysis | High (unprovable-as-stated); Medium (that it is actually false in some model — not constructed, but not excluded) |
| Strictness obligation isolates to the fresh-anchor boundary (Cases A/B only) | Zone bounds strict-open (`hbelowXU: u<x1`, `hbelowUW: x1<u`, :1068); two-foreign-χ compat unconditional (`kvE2_sepCompat` :385); same-owner uses rank not points | Read of source (`SharedWitness.lean:385, 1068`) | High |
| `kvE2_sepFreshAnchor_ne_baseChiPoint` (the recommended boundary lemma) is PROVABLE | `nf_eval_unique` separates nf0 from nf0, NOT nf1-atom from nf0-base; no in-house lemma found that forbids a point realizing both | lean_local_search (`nf_eval_unique` only) — no separating lemma located | **Low** — flagged as residual make-or-break risk |
| Step-1 switch is a pure mechanical rewire (predicates present, old `kvE2_sepSlotLe` unwired) | Read HEAD lines 344-460, 762-771: predicate defs present, `kvE2_sepSlotLe` still `||` form | Read of source | High |
| `kvE2_sepSlotsL_nodup` provable (if injectivity route attempted) | `List.nodup_flatMap` + disjoint owners + `kvE2_sepPos_nodup` (:848) | lean_loogle hit + Read | High (but not needed for the recommended route) |

### What the adversarial pass CHANGED

1. **Downgraded the frontier's recommendation (a).** The frontier (handoff 03, Risk §1) recommended proving `pt` globally injective as "the more paper-faithful" route. The adversarial pass shows this is likely unprovable (cross-owner χ-witness coincidence) AND unnecessary (harmless for two-foreign-χ pairs). The report replaces it with a **localized** boundary-distinctness lemma.
2. **Rejected resolution (b) as a standalone fix.** Showed the secondary-key sort still leaves the exact same boundary obligation (`pt a = x1_σ ⇒ same owner`), so it adds machinery without closing the crux.
3. **Elevated the true residual risk.** The genuine make-or-break is not "which sort" (solved) nor "which tie-break" (both need the same lemma) but the **provability of the fresh-anchor / base-χ point separation**, whose confidence is Low pending a semantic argument. This is now flagged explicitly rather than buried under "injectivity."

No forbidden verification output ("mathlib likely has…") is present: every Mathlib claim carries a verified signature.

### Contradiction Log

One contradiction with an upstream source, resolved:
- **A**: task-333 frontier — "resolution (a) global injectivity is recommended, more paper-faithful."
- **B**: this research — "global injectivity is likely unprovable and unnecessary; use a local boundary lemma."
- **Resolution** (precedence: direct source-read of the point-map existentials + Def 3.1 semantics > prior handoff heuristic): B supersedes A. Def 3.1 requires strict increase *across decomposition boundaries* (the reference points / fresh anchors), not global witness distinctness; the Lean point-map cannot force cross-owner distinctness. Downstream risk if ignored: an implementer spends the phase budget attempting an unprovable global-injectivity lemma. Mitigation: report routes directly to the local lemma.

---

## Recommended Implementation Order (grounding the task's 4 steps)

1. **Wire the switch** (mechanical, HEAD, skip predicate-add hunk) — §Step-1. Expect `kvE2_sepSlotsL_valid`/`_valid` + `kvE2_sepBody_nonvacuous` to break (intended).
2. **Add `kvE2_sepHonestBundleR`** — mirror of `kvE2_sepHonestBundleL`; FIRST confirm the right-interior env/zone reading of `kvE_subBracket2_complete_extract` (Risk §Right-interior).
3. **Prove `kvE2_sepJointSortedL/R`** — `List.mergeSort (fun a b => decide (pt a ≤ pt b))`, `List.mergeSort_perm` + `List.sorted_mergeSort'`, transfer via `List.Pairwise.imp`, discharge Cases A/B with the four compat leaves and `kvE2_sepFreshAnchor_ne_baseChiPoint` (+ `lt_of_le_of_ne`). Attempt the boundary lemma EARLY; escalate if it resists.
4. **Rewire `kvE2_sepBody_nonvacuous`** off `List.Perm.refl` (:1112/1116) onto the joint sort; retire `kvE2_sepSlotsL_valid`/`_valid`, `kvE2_sepSlotLe_of_sub_ne`. Gate branch (`kvE2_sepGate_holds_of_honest`) unchanged. Confirm green with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`.

Downstream (out of primary scope): Phases 3–5 strategic sorries (`kvE2_sepSingleton_coverage_left` :1997, `kvE2_sepBody_singleton_complete_left` :2129), Phases 12/13 (N2-C gate + F4 adversarial).

## Risks / Open Questions

1. **Boundary point-distinctness (`kvE2_sepFreshAnchor_ne_baseChiPoint`) — HIGHEST, residual make-or-break.** Provability unestablished (confidence Low). Needs a semantic separation of the fresh E[Σ]-atom anchor from base-χ points. If unprovable, the joint sort's binding cross-σ cases cannot upgrade `≤` to `<`, and non-vacuity stalls at exactly this boundary. Do NOT weaken the filter to vacuity to sidestep it; escalate.
2. **Right-interior bundle env/zone reading — MEDIUM.** `kvE_subBracket2_complete_extract` is stated for the LEFT-interior env `[x1,w,x,t]`. For a right-interior σ (`w < x1_σ < t`), confirm which extractor/env applies (`kvE2_sep_zWX1 = (w,x1)` middle region) before mirroring the bundle. Until confirmed, `kvE2_sepJointSortedR` is less certain than `L`.
3. **Local `Std.Total`/`IsTrans` instance provision — LOW.** Must be supplied for the pullback relation; both are one-liners from `LinearOrder M.carrier`. No blocker.
