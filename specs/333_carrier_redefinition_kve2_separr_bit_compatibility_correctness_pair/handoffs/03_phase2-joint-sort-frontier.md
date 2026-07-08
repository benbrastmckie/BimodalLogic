# Task 333 Handoff 03 — Phase 2 joint-sort frontier (faithfulness + Lean-engineering ledger)

- **Session**: sess_1783522894_0a5276 (final budgeted orchestrator cycle)
- **Status**: partial — three green reusable increments landed and committed; the joint
  slot-level sorted realization (the make-or-break non-vacuity core) is NOT yet closed. Build
  GREEN throughout; filter switch still staged-not-wired at HEAD.
- **Build**: GREEN — `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
  exit 0. 2 tracked strategic sorries only (`kvE2_sepSingleton_coverage_left` :1997,
  `kvE2_sepBody_singleton_complete_left` :2129). 0 vacuous defs, 0 new axioms. Only
  `SharedWitness.lean` changed vs baseline `443684ae6` (+177 lines); all do-not-edit assets
  byte-identical.
- **HEAD**: `04ea18425`.
- **Correct lake target**: `Bimodal.Metalogic.…SharedWitness` (root `Bimodal`, srcDir `Theories`).

## What landed this cycle (all green + committed)

1. **`3e2129039` — three mirror compat leaves** (blueprint step 1, DONE). Clones of the landed
   `kvE2_sepCompat_lX1_eq`, axiom-clean `[propext, Quot.sound]`:
   - `kvE2_sepCompat_lX1_after_eq` : `kvE2_sepCompat (.lX1 σ) b = kvE2_sepBits σ kvE_sub2_zUW χ`
     when `kvE2_sepSlotChi b = some χ` — the after-fresh (`p > x1_σ`) left-list branch.
   - `kvE2_sepCompat_rX1_eq` : `kvE2_sepCompat a (.rX1 σ) = kvE2_sepBits σ kvE2_sep_zWX1 χ` — right
     list before-fresh.
   - `kvE2_sepCompat_rX1_after_eq` : `kvE2_sepCompat (.rX1 σ) b = kvE2_sepBits σ kvE_sub2_zWT χ` —
     right list after-fresh.
   Together with the pre-existing `kvE2_sepCompat_lX1_eq`, these are the **complete set of four
   reusable compat leaves** the sort-validity proof consumes. They reduce every binding cross-σ
   pair to a single `kvE2_sepBits` read.
2. **`04ea18425` — `kvE2_sepHonestBundleL`** (blueprint step 1 point-map, DONE for the left list,
   left-interior σ). Signature:
   ```
   private theorem kvE2_sepHonestBundleL (qnf) (M) (w x t) (hxw hwt)
       (h : nf_eval_nf M 2 3 [w,x,t] qnf)
       (σ) (hσpos : σ ∈ kvE2_sepPos qnf) (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
       ∃ x1, x < x1 ∧ x1 < w ∧
         (∀ χ ∈ kvE2_sepS σ kvE_sub2_zXU, ∃ u, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _=>u) χ) ∧
         (∀ χ ∈ kvE2_sepS σ kvE_sub2_zUW, ∃ u, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _=>u) χ)
   ```
   This is the exact `hrealXU`/`hrealUW` shape `k1v_sorted_realization3` consumes, but keyed to
   the qnf gate's per-σ extracted anchor `x1_σ`. It **reuses the do-not-edit extractor**
   `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`) — no new model reasoning, no
   `x1 < e_i` literal (LITMUS-clean). This is the confirmed bridge from "one honest qnf
   realization" to "per-σ region witnesses," which the sort needs once per positive owner.

## KEY DISCOVERY that de-risks the frontier

The qnf gate's per-σ existential `(h_quant σ).mpr hb ⟹ ⟨x1_σ, hσ⟩` yields `hσ` at env
**exactly** `Fin.cons x1_σ (Fin.cons w (Fin.cons x (fun _=>t))) = [x1_σ, w, x, t]`, which is
**byte-for-byte the env `kvE_subBracket2_complete_extract` demands**. So the entire per-region
zone→order extraction (including the `zoneHolds → x<v<x1` translation via
`kvE_sub2_zoneHolds_zXU/_zUW/_zWT`) is already done inside a do-not-edit asset and is directly
reusable per owner. The successor does NOT need to re-derive any zone/order plumbing.

---

## 1. FAITHFULNESS LEDGER (Rabinovich 2014 → Lean)

Ground truth: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Rabinovich result | Paper anchor | Lean site | Faithfulness state |
|---|---|---|---|
| **Lemma 3.2(1)** — conjunction of ∃∀ ≡ disjunction over *consistent* interval-decomposition refinements | md:77 (form md:65–74) | Filter `kvE2_sepCompat`/`kvE2_sepSlotLe` (SharedWitness :385/:421 staged; switch in `phase1-switch-and-repairs.patch`) | **⇒-direction (soundness of the filter) faithfully transcribed**: the compat predicate admits a cross-σ placement iff the owner's fold bit for that (region, χ) is TRUE — proven EXACTLY equal to the bit by the four compat leaves. **⇐-direction (every honest arrangement is admitted) NOT yet transcribed** — this is the joint sort (Frontier §2). The per-σ ⇐-witnesses are landed (`kvE2_sepHonestBundleL`); the joint interleaving of them is the gap. |
| **Lemma 3.2(2)** — anchor cap 2; everything over free `(x,t)` | md:78 | `kvE2_sepGate` (:663) + `kvE2_sepBody` bracket at fixed `(x,t)` (:682); depth-2 gate NOT redefined | **Faithful, preserved.** The redefinition touches only the enumeration filter, never the anchor cap or the free-variable framing. `kvE2_sepBracketN` point types live over `lL ++ ptW :: lR` at the two fixed endpoints + one shared `w`. |
| **Lemma 5.1** — quantifier-free point types = `charBase χ` (depth-0) / `charK (nfk_projFresh σ)` (E[Σ]-atom), no nesting | md:72, :134–135 | `kvE2_sepSlotType` (:277), `kvE2_sepPtX1L/R` (:258/:267) | **Faithful.** Every slot point type is `charBase χ` or the folded `charK` E[Σ]-atom. The four compat leaves read only `kvE2_sepBits` (a `σ.2 ∘ nf0_assemble` fold read), never a nested type. No-nesting audit passes on all new code. |
| **Lemma 3.2(2) fresh-less-sub exclusion** (audit item 1a) | md:77 consistency condition, segment mechanics §5 | `kvE2_sepSegLForSub` (:560) / `kvE2_sepSegRForSub` (:571) — uniform `kvE_sub2_zXU` / `kvE_sub2_zWT` segment forms | **Faithful and SETTLED.** A fresh-less sub's whole-macro-side exclusion is owned by the refined-segment machinery, NOT the compat filter. The filter is correctly SILENT for fresh-less pairs (`.rXW`/`.lWT` slots, which carry χ, are always mutually compat). No third compat clause — adding one would double-count. Recorded in the `kvE2_sepCompat_lX1_eq` docstring. |
| **Section 5 splitting / Def 3.1 monotone enumeration** — model-sorted witness arrangement | md:61–74, md:134–157 | `k1v_sorted_realization` (CarrierK1V.lean:~1447), `k1v_sorted_realization3` (SubBracket2V.lean:379) | **Faithful per single σ; NOT yet lifted to the joint list.** The single-σ three-region sort is faithfully in place and reused by the do-not-edit O6 source. The JOINT multi-anchor sort (Frontier §2) is the missing transcription: Def 3.1's strictly-increasing witness order must be taken over ALL owners' witnesses simultaneously, not one owner at a time. |

**Net**: the filter is a *faithful, not over-strong, not vacuous* encoding of Lemma 3.2(1)'s
consistency condition — proven by the compat leaves equalling the exact fold bits. The one
Rabinovich notion still lacking a Lean encoding is the **joint** (multi-owner) model-sorted
arrangement of Def 3.1 / Lemma 3.2(1)-⇐.

---

## 2. LEAN-ENGINEERING FRONTIER (the joint slot-level sorted realization)

### The precise obligation
After wiring the switch (`kvE2_sepSlotLe` → the `if sub=sub then rank else kvE2_sepCompat`
form), `kvE2_sepBody_nonvacuous` (:1049, currently on `List.Perm.refl` + the now-false
`kvE2_sepSlotsL_valid`/`_valid`) must instead exhibit, from the honest realization `h`, ONE
permutation `πL` of `kvE2_sepSlotsL qnf` with `kvE2_sepValid πL = true`, and one `πR` for the
right list. (The gate branch `kvE2_sepGate_holds_of_honest` is UNCHANGED and already discharges
the `dite` guard.)

### Why `k1v_sorted_realization`/`_3` do NOT lift (the Nodup-recurrence obstruction)
`k1v_sorted_realization M x x1 S hnd hreal` requires `S.Nodup` and sorts a list of *1-types*
keyed by a per-type witness point, producing a `List.Perm` of `S`. Per single σ this holds
(`kvE2_sepS σ zs` is a `Finset.univ.toList.filter`, hence Nodup). But the JOINT left slot list
`kvE2_sepSlotsL qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor` places the SAME χ-type under
different owners: σ's `.lXU σ χ` and τ's `.lXU τ χ` are two distinct SLOTS carrying one type χ.
A type-keyed sort cannot separate them (its `Nodup` premise is on types, which recur). The sort
must therefore be keyed on **slots** (which are distinct) tagged with **real model points**, not
on types.

### The concrete replacement shape
A new private lemma (call it `kvE2_sepJointSortedL`), roughly:
```
∃ πL, List.Perm πL (kvE2_sepSlotsL qnf) ∧ kvE2_sepValid πL = true
```
built as:
1. **Point assignment** `pt : KvE2SepSlot sig → M.carrier` (noncomputable, via `Classical`):
   - `.lX1 σ ↦ x1_σ` (from `kvE2_sepHonestBundleL`, LANDED);
   - `.lXU σ χ ↦` a witness `u ∈ (x, x1_σ)` carrying χ (from the bundle's zXU clause, LANDED);
   - `.lUW σ χ ↦` a witness `u ∈ (x1_σ, w)` carrying χ (bundle zUW clause, LANDED);
   - `.rXW σ χ ↦` a witness `u ∈ (x, w)` carrying χ for a fresh-less right-interior σ
     (needs a RIGHT-interior analog of `kvE2_sepHonestBundleL` — see §3 risk).
   Each slot's point lands in a model interval determined by its owner's anchor.
2. **Sort** `kvE2_sepSlotsL qnf` by `pt` under the classical linear order on `M.carrier`
   (insertion sort or `List.MergeSort` with `fun a b => decide (pt a ≤ pt b)`), giving `πL` with
   `List.Perm πL (kvE2_sepSlotsL qnf)` and `List.Sorted (fun a b => pt a ≤ pt b) πL`.
3. **Validity** `kvE2_sepValid πL`: for any `a` before `b` in `πL` (so `pt a ≤ pt b`):
   - same owner ⇒ `kvE2_sepSlotLe` via rank; the per-owner block is internally rank-sorted and
     the model points respect rank (before-fresh χ points `< x1_σ <` after-fresh χ points, from
     the bundle's strict interval bounds) — so the model order refines the rank order **within**
     an owner. (Needs: model-point order ⇒ rank order for same-owner slots; provable from the
     bundle bounds.)
   - different owners, neither fresh ⇒ `kvE2_sepCompat a b = true` unconditionally (two χ-slots).
   - different owners, `b = .lX1 σ`, `a` carries χ_a, `pt a ≤ x1_σ` ⇒ need
     `kvE2_sepBits σ kvE_sub2_zXU χ_a = true`. Since `pt a ∈ (x, x1_σ)` (strictly; see tie risk
     §3) and `pt a` carries χ_a, the fold ⇐ (`kvE_subBracket2_complete_extract`'s third
     conjunct `h_zonefwd` : `(∃ v, zoneHolds zXU v ∧ χ realized) → bit = true`, applied to
     `v := pt a`) gives the bit; then `kvE2_sepCompat_lX1_eq` closes it. Symmetric for
     `a = .lX1 σ` before `b` via `kvE2_sepCompat_lX1_after_eq` and the zUW zone.
4. **Rewire** `kvE2_sepBody_nonvacuous` off `Perm.refl`/`kvE2_sepSlotsL_valid` onto
   `kvE2_sepJointSortedL` (and the R mirror). Delete/retire `kvE2_sepSlotsL_valid`,
   `kvE2_sepSlotsR_valid`, `kvE2_sepSlotLe_of_sub_ne` (all now false/unused) — matching the
   `phase1-switch-and-repairs.patch` mechanical repairs, which already compile except these two.

### Ordered next concrete steps for a successor
1. **Wire the switch by hand on top of HEAD** (predicate defs already present — skip the patch's
   predicate-add hunk): replace `kvE2_sepSlotLe` (:421) with the `if`-form, and apply the
   patch's mechanical renames (`kvE2_sepSlotLe_of_rank`→`_same`, add `kvE2_sepSlotLe_of_ne_compat`,
   `kvE2_sep_pairwise_rank_same`, split the `_rankPairwise`/`_pairwise` lemmas, fix the
   `kvE2_sep_index_lt_of_rank_lt` `rw` at the old :1234). Everything downstream compiles EXCEPT
   `kvE2_sepSlotsL_valid`/`_valid` and `kvE2_sepBody_nonvacuous`.
2. **Add the RIGHT-interior bundle** `kvE2_sepHonestBundleR` (mirror of the landed L bundle; see
   §3 for the env/zone-reading caveat).
3. **Prove `kvE2_sepJointSortedL`/`R`** per the shape above. Budget the sort + validity at
   ~200–300 lines; the two hardest sub-obligations are the tie-freeness (§3) and the
   same-owner model-order-refines-rank step.
4. **Rewire `kvE2_sepBody_nonvacuous`**; confirm green; then proceed to Phases 3–5
   (plumbing + the two strategic sorries), which the wired filter unblocks.

### What is already proven reusable (do not rebuild)
- The four compat leaves (`kvE2_sepCompat_lX1_eq`, `_lX1_after_eq`, `_rX1_eq`, `_rX1_after_eq`).
- `kvE2_sepHonestBundleL` (per-σ left witnesses).
- `kvE_subBracket2_complete_extract` (do-not-edit; the zone→order + fold-⇐ engine).
- `kvE2_sepGate_holds_of_honest` (gate branch, unchanged).
- The staged `phase1-switch-and-repairs.patch` for the mechanical downstream renames.

---

## 3. RISK / OPEN QUESTIONS (where the correct Lean encoding is not yet nailed down)

1. **Tie-freeness of the point assignment (HIGHEST).** The validity argument needs `pt a < x1_σ`
   *strictly* (not just `≤`) when a foreign χ-slot `a` precedes `.lX1 σ` in the sorted order.
   `List.Sorted (≤)` gives only `pt a ≤ pt b`. Two resolutions, both faithful:
   (a) prove the assignment is **injective on the slot list** — distinct slots get distinct model
   points — using that an E[Σ]-atom point (`x1_σ`, charK) cannot coincide with a base-χ point,
   and per-owner region-disjointness; then sort by `<` and get strict inequalities. This is the
   cleaner encoding but requires a point-distinctness lemma.
   (b) sort by a strict order with a **stable secondary key** (owner index, then rank) so equal
   model points still yield a decidable total order, and prove the boundary case
   `pt a = x1_σ ⇒ a` is same-owner (so it never becomes a binding cross-σ pair). Encoding (b)
   sidesteps global injectivity but needs the "equal point ⇒ same owner" lemma. **A successor
   must pick one; (a) is recommended as the more paper-faithful (Def 3.1 witnesses are strictly
   increasing, md:61–74).**
2. **Right-interior bundle env/zone reading (MEDIUM).** `kvE_subBracket2_complete_extract` is
   stated for the LEFT-interior env `[x1,w,x,t]` with `zXU=(x,x1)`, `zUW=(x1,w)`, `zWT=(w,t)`.
   For a RIGHT-interior σ (`w < x1_σ < t`), the placement-generic reading (SharedWitness :102–105)
   makes `kvE_sub2_zXU` read `(x,w)` and `kvE_sub2_zWT` read `(x1,t)`, with the middle region
   `kvE2_sep_zWX1 = (w,x1)`. The successor must confirm which extractor/env the right-interior
   realization uses (there is a mirror gate branch; check whether a right-interior analog of
   `kvE_subBracket2_complete_extract` exists or whether the same asset applies under a
   coordinate relabeling). Until confirmed, the RIGHT-list joint sort is less certain than the
   LEFT.
3. **Sort primitive choice (LOW).** Whether to use `List.MergeSort`, `List.insertionSort`, or the
   existing per-region insertion of `k1v_sorted_realization` generalized. The existing
   `k1v_sorted_realization` induction is the most in-house-consistent, but it bakes in `Nodup`;
   a slot-keyed variant would need the `Nodup` premise moved to slots (which IS satisfiable:
   `kvE2_sepSlotsL qnf` is Nodup — flatMap of Nodup blocks over the Nodup `kvE2_sepPos` with
   disjoint owners). **Confirm `kvE2_sepSlotsL_nodup` is available or provable** — if so, a
   slot-keyed lift of `k1v_sorted_realization` may be the shortest path and reuses the most
   in-house machinery.

## Sorry inventory (both pre-existing strategic, tracked — unchanged)

| file:line | statement | strategic | why deferred | follow-up |
|-----------|-----------|-----------|--------------|-----------|
| SharedWitness.lean:1997 | `kvE2_sepSingleton_coverage_left` | true | plan Phase 4 — needs Phase 3 segments, which need the Phase 2 switch | task 333 Phase 4 |
| SharedWitness.lean:2129 | `kvE2_sepBody_singleton_complete_left` | true | plan Phase 5 — O6 lift, needs switched filter + Phase 4 | task 333 Phase 5 |

## Preserve (binding)
Do NOT weaken the filter to vacuity (Postmortem HIGH); the honest arrangement is the literal
⇐-witness of Lemma 3.2(1). Do NOT weaken the F4 discriminator (Phase 8). Keep the macro-side
confinement invariant (L list only `(x,w)` slots, R only `(w,t)`). If joint non-vacuity resists,
the filter is too STRONG only if a macro-side-confinement invariant is broken by plumbing — never
relax the consistency condition.
