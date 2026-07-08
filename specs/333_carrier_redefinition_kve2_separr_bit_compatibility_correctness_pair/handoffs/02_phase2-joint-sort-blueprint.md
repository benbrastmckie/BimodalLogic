# Task 333 Handoff — Phase 2 make-or-break (joint model-sorted non-vacuity)

- **Session**: sess_1783522894_0a5276
- **Status**: partial — Phase 2 confirmed make-or-break; green milestone landed (discrimination
  witness + audit-item resolutions), the filter switch itself is NOT yet wired.
- **Build**: GREEN — `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
  exit 0. Full staged predicate present; filter still the task-321 arrangement-blind one.
- **Live sorries**: 2 (unchanged strategic pair) — `SharedWitness.lean` (post-commit line numbers):
  `kvE2_sepSingleton_coverage_left` and `kvE2_sepBody_singleton_complete_left`.
- **Only file touched**: `SharedWitness.lean` (+25 lines). Do-not-edit assets byte-identical.
- **HEAD**: `ec9e63b7c` (task 333 phase 2.1).
- **Correct lake target**: `Bimodal.Metalogic.…SharedWitness` (root `Bimodal`, srcDir `Theories`).

## What this dispatch resolved

### 1. Fresh-less-sub cross-σ gap (audit item 1) → **RESOLVED as 1a (documented, no third clause)**

The audit's one soundness-blocking item is CLOSED in favour of option (a). The whole-macro-side
exclusion of a *fresh-less* sub is owned by the refined-segment machinery, NOT the compat filter,
so `kvE2_sepCompat` is correctly silent for fresh-less pairs:

- `kvE2_sepSegLForSub` (SharedWitness.lean, `if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
  kvE2_sepSegForm charBase σ kvE_sub2_zXU`): a **right-interior** σ (fresh-less on the LEFT list)
  contributes a UNIFORM `kvE_sub2_zXU` exclusion segment at EVERY left cut. So a foreign χ-point
  landing anywhere in that σ's `(x,w)` region is governed by `kvE2_sepBits σ zXU χ` through the
  carrier's segment structure — exactly the paper's consistency condition.
- `kvE2_sepSegRForSub` (mirror, `if … = kvE2_sep_zXW3 then kvE2_sepSegForm charBase σ
  kvE_sub2_zWT`): a **left-interior** σ (fresh-less on the RIGHT list) contributes uniform
  `kvE_sub2_zWT` at every right cut.

Therefore the compat filter's job is only the *fresh-adjacency* constraint (which region a foreign
point falls into relative to a fresh witness), and the fresh-less whole-region constraint is a
segment-form obligation discharged downstream in the carrier `.holds`. No third compat clause is
needed; adding one would DOUBLE-count and risk over-constraint. This resolution is recorded in the
in-code docstring of the new `kvE2_sepCompat_lX1_eq`.

### 2. Mixed-class discrimination (audit item 2) → **proof-form witness landed (supersedes #eval)**

Instead of a concrete `#eval` (which requires heavy `NormalForm sig 2 3` scaffolding and, per item
1a, cannot even exercise the fresh-less obligation because that lives in the segments, not the
filter), the discrimination is captured as a machine-checked, `sig`-generic theorem:

```
theorem kvE2_sepCompat_lX1_eq (σ) (χ) (a) (hχ : kvE2_sepSlotChi a = some χ) :
    kvE2_sepCompat a (.lX1 σ) = kvE2_sepBits σ kvE_sub2_zXU χ
```

i.e. a foreign χ-slot placed BEFORE a left-interior σ's fresh slot is admitted iff σ's before-fresh
`zXU` bit for χ is TRUE. Hence the arrangement-blind bad interleaving (`bit = false`) is REJECTED
and the bit-true one ADMITTED — the exact cross-σ correctness the task-321 filter lacked. This is
strictly stronger than a single `#eval` datapoint (it is universally quantified). Axiom-clean
`[propext, Quot.sound]`. The `.rX1` (right-interior, `kvE2_sep_zWX1`) and after-fresh mirrors hold
by the identical `cases a <;> simp_all [zone/chi/sub defs]` reduction.

## The make-or-break wall (Phase 2 non-vacuity) — precise blueprint for the next dispatch

The filter switch (`handoffs/phase1-switch-and-repairs.patch`) applies cleanly onto the **baseline
`443684ae6`** file (NOT onto HEAD — HEAD already contains the predicate defs, so the patch's
predicate-add hunk conflicts; use `git show 443684ae6:…SharedWitness.lean > …; git apply <patch>`).
After the switch, exactly two private lemmas fail:
`kvE2_sepSlotsL_valid` / `kvE2_sepSlotsR_valid` (they reference the deleted
`kvE2_sepSlotLe_of_sub_ne`; the patch renamed it to `kvE2_sepSlotLe_of_ne_compat`, which now
REQUIRES a `kvE2_sepCompat = true` proof the identity arrangement cannot supply).

### Why there is no shortcut (proven structurally)

- `kvE2_sepBody_nonvacuous` reduces (via `kvE2_sepBody`, `kvE2_sepArrL/R`) to a PURELY COMBINATORIAL
  obligation: exhibit ONE permutation of `kvE2_sepSlotsL qnf` with `kvE2_sepValid = true`, and one
  for R. The model `h` is used ONLY to discharge the gate branch (`kvE2_sepGate_holds_of_honest`);
  the filter itself references no model.
- **Single-positive qnf**: identity still passes (no cross-σ pairs) — `kvE2_sepSlotsLFor_pairwise`
  suffices. So the two `_valid` lemmas are FALSE only for **multi-positive** qnf.
- **Multi-positive**: NO bit-independent arrangement passes. Whenever two positives σ,τ coexist,
  τ's before-fresh χ-slots are positioned relative to σ's fresh slot; compat clause (1)/(2) then
  demands those χ ∈ σ's `zXU`/`zUW` set — not implied by τ's own bits. Verified against
  `kvE2_sepSlotsLFor` (:292, slots come only from `kvE2_sepS`, i.e. the owner's own bit-true set).
  So a valid arrangement exists ONLY because the honest model's bits are mutually consistent, and
  extracting it REQUIRES the model.

### The exact missing machinery (novel — the plan's flagged irreducible core)

A **joint slot-level sorted realization**. It is NOT a lift of `k1v_sorted_realization`
(CarrierK1V.lean:1447) nor `k1v_sorted_realization3` (SubBracket2V.lean:379): those require the type
list to be `Nodup`, but the joint slot list has the SAME χ-type recurring across different owners
(σ's before-fresh χ and τ's before-fresh χ are two distinct slots of one type), so a type-level sort
cannot separate them. The new lemma must sort SLOTS keyed by real model position.

Foundations that already exist (compose these):
- **Semantic bridge**: `nf_eval_depth1_fold_iff` (CarrierKv.lean) gives, per positive σ realized at
  `[x1_σ,w,x,t]`, `σ.2 (nf0_assemble zs χ σ.1) = true ↔ ∃ v, zoneHolds M env zs v ∧ realizes χ`.
  For `zs = kvE_sub2_zXU` this yields `∃ v ∈ (x, x1_σ)` carrying χ — i.e. the `hrealXU` hypothesis.
  Witnesses `x1_σ` and the fold `hσ` are already extracted inside `kvE2_sepGate_holds_of_honest`
  (:963 `obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb`).
- **Per-σ order facts**: `hxx1 : x < x1_σ`, `hx1w : x1_σ < w` are derived at :1000-1007.

Construction sketch (~200-300 lines, matches plan Phase 2 budget):
1. For each positive left-interior σ and each χ ∈ `kvE2_sepS σ zXU`, pick a witnessing point
   `p ∈ (x, x1_σ)` carrying χ (bridge). Same for `zUW` in `(x1_σ, w)`. Map each LEFT slot to its
   `(slot, point)` pair (fresh slot `.lX1 σ ↦ x1_σ`).
2. Sort ALL left `(slot, point)` pairs by point (`List.Perm` of `kvE2_sepSlotsL qnf`,
   `List.Sorted (·<·)` on points — allow ties by a stable secondary key; distinctness is NOT needed
   for the FILTER, only for later realization).
3. Prove the sorted order is `kvE2_sepValid`: for a cross-σ pair (foreign χ-slot at point p, σ's
   fresh `.lX1 σ` at `x1_σ`): if `p < x1_σ` then `p ∈ (x, x1_σ)` so σ's `zXU` bit for χ is TRUE
   (bridge ⇐), giving `kvE2_sepCompat = true` via `kvE2_sepCompat_lX1_eq` (already proven!); if
   `p > x1_σ` then `p ∈ (x1_σ, w)` so σ's `zUW` bit is true (after-fresh mirror lemma — prove it
   next, same shape as `kvE2_sepCompat_lX1_eq`). Same-owner pairs respect rank because
   before-fresh points `< x1_σ <` after-fresh points.
4. Rebuild `kvE2_sepSlotsL_valid`/`_valid` as honest-order lemmas (or delete and inline the sorted
   witness into `kvE2_sepBody_nonvacuous`), then re-wire `nonvacuous` (:1035/:1039) off `Perm.refl`
   onto the sorted witness. Gate branch unchanged.

### First next step
Prove the after-fresh mirror `kvE2_sepCompat_lX1_after_eq`
(`kvE2_sepCompat (.lX1 σ) b = kvE2_sepBits σ kvE_sub2_zUW χ` when `kvE2_sepSlotChi b = some χ`) and
the two `.rX1` right-list analogues — trivial `cases <;> simp_all` clones of the landed lemma — then
build the point-map of step 1. These four small lemmas are the reusable compat leaves the sort proof
consumes; landing them keeps every intermediate green.

### Preserve
Do NOT weaken the filter to vacuity (Postmortem HIGH). The honest arrangement is the literal
⇐-witness of Rabinovich Lemma 3.2(1) (audit §4), warranted by construction. Keep the macro-side
confinement invariant (audit §1.1): L list only `(x,w)` slots, R list only `(w,t)` — the single
before/after zone per side is faithful only because of it.

## Sorry inventory (both pre-existing strategic, tracked)

| file:line | statement | strategic | why deferred | follow-up |
|-----------|-----------|-----------|--------------|-----------|
| SharedWitness.lean (~1920) | `kvE2_sepSingleton_coverage_left` | true | plan Phase 4 — needs Phase 3 segments, which need the Phase 2 switch | task 333 Phase 4 |
| SharedWitness.lean (~2052) | `kvE2_sepBody_singleton_complete_left` | true | plan Phase 5 — O6 lift, needs switched filter + Phase 4 | task 333 Phase 5 |
