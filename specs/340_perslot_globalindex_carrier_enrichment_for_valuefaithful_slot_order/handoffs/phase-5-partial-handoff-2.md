# Task 340 Phase 5 — Partial Handoff #2 (continuation, sess_1783561356_89aa2d_340_cont)

## Immediate Next Action

Continue task 340 Phase 5. The model-agnostic **lex-rank kernel** (the sort spec) is now
DELIVERED, proven, and committed. Next: settle the honest-order layout design point below,
then define `kvE2_sepHonestOrder` + prove membership (B) + monotonicity (C) consuming the kernel,
then the step-6 bundle. Task 337 stays BLOCKED until the bundle lands.

## What This Dispatch Delivered (green, sorry-0, axiom-clean, committed)

`kvE2_ordRank` + three lemmas at SW:783-832 (commit `task 340 phase 5.1: lex-rank kernel …`):

```lean
def kvE2_ordRank {β} [LinearOrder β] {n} (g : Fin n → β) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => g j < g i)).card
theorem kvE2_ordRank_lt         : kvE2_ordRank g i < n
theorem kvE2_ordRank_strictMono : g a < g b → kvE2_ordRank g a < kvE2_ordRank g b
theorem kvE2_ordRank_injective  : Function.Injective g → Function.Injective (kvE2_ordRank g)
```

Axiom set `{propext, Classical.choice, Quot.sound}` (verified on `kvE2_ordRank_injective`), no
`sorryAx`. Scoped build green (1013 jobs).

**Why this is the right first deliverable.** The prior handoff (#1) stated every remaining
obligation — in-range `i<3n`, per-owner consistency `i₀<i₁<i₂`, cross-owner `Nodup`, and the
`a<u'<b` monotonicity — "all reduce to the sortedness/injectivity spec of that single sort." That
spec is EXACTLY these three lemmas: `_lt` → the `<3n` bound feeding `kvE2_sepIdxTuple_mem_of_lt`;
`_strictMono` → `i₀<i₁<i₂` (from the bundle chain `val₀<val₁<val₂`) AND the `a<u'<b` step (from
`val(σ,2)<val(τ,1)`); `_injective` → `Nodup`. Taking `g = (model value, slot index)` in the LEX
order makes the tiebreak the always-distinct slot index, which **sidesteps the SW:1585 distinctness
crux** (distinct owners may share witness values, so value alone is not a strict order) WITHOUT any
value-distinctness hypothesis. The kernel is design-agnostic — it applies to an `n`-anchor family
OR a `3n`-slot family — so it is reused whichever honest-order layout is settled below; landing it
is NOT churn.

## Structural Facts Uncovered This Dispatch (read before building the def)

1. **Slot granularity is per-(owner, REGION-RANK), coarse — NOT per individual slot.** The carrier
   tuple is `(i₀,i₁,i₂)` per owner (`KvE2SepWeakOrder = List (NormalForm × tag × (ℕ×ℕ×ℕ))`,
   SW:701). `kvE2_sepSlotGIdx wo s` (SW:939) reads the owner's tuple then picks the component by
   `kvE2_sepSlotRank s ∈ {0,1,2}`. So ALL of σ's `lXU σ χ` slots (one per positive base type χ in
   zone `zXU`, SW:295) share the SAME index `i₀`; all `lUW σ χ` share `i₂`; the anchor `lX1 σ` is
   `i₁`. A left-interior owner's slots (SW:292-299): `[lXU σ χ …] ++ lX1 σ :: [lUW σ χ …]` on the
   left list, `[lWT σ χ …]` (rank 0) on the right. Right-interior mirror (SW:304-311).

2. **The honest-order def must pick ONE representative M-value per (owner, region rank).** Because a
   whole region collapses to one index, the def cannot sort individual slot values; it sorts one
   value per (owner, region). `i₁`'s representative is unambiguous: the anchor `x1_σ`
   (`(h_quant σ).mpr hb`, cf. `kvE2_sepHonestBundleL/R` at SW:1489/1541, which give `x<x1<w` /
   `w<x1<t` and per-base-type region witnesses). `i₀`/`i₂` representatives are the open design point.

3. **Step-6 realizability collides with coinciding anchors (the deep obstruction).** A clean
   candidate layout is consecutive-block-by-lex-anchor-rank: `r := kvE2_ordRank` of the `n`-anchor
   lex family `(x1_σ, ownerIndex)`, tuple `= (3r, 3r+1, 3r+2)`. This gives IMMEDIATE membership:
   `i₀<i₁<i₂` by `omega` (`3r<3r+1<3r+2`); all `<3n` from `r<n` (`kvE2_ordRank_lt`); `i₀`-Nodup =
   `{3r}` distinct from `kvE2_ordRank_injective` (lex family injective in its index coord). BUT its
   step-6 realization requires owner-`r`'s region-2 points (all `> x1_σ`) to sit below owner-`(r+1)`'s
   region-0 points (all `< x1_{σ'}`), needing room in `(x1_σ, x1_{σ'})`. When two anchors COINCIDE
   (`x1_σ = x1_{σ'}`, which SW:1585 says is possible), the lex tiebreak still forces distinct ranks
   `r < r+1` and thus strict separation the model CANNOT realize. Coinciding-anchor owners belong at
   the SAME anchor — i.e. they route through `kvE2_sepCoincidentOrder` (SW:1700), not the strict
   honest interleaving. **So the honest order is a genuine bifurcation: strict-distinct anchors take
   the value-sorted interleaving; coinciding anchors fall back to coincidence.** This bifurcation is
   the unsettled design point; it must be decided BEFORE building the def, or a membership proof will
   be churned against a to-be-redesigned layout (H6).

## Concrete Remaining Construction (updated map, steps 2-6)

2. **Settle layout + define `kvE2_sepHonestOrder qnf M w x t : KvE2SepWeakOrder sig`** (noncomputable;
   `Classical.choose` over the bundle existentials for the anchor values, default to `x` off-domain
   via `Classical.dec`). Recommended: build the `n`-anchor lex family
   `g : Fin n → M.carrier ×ₗ Fin n`, `g k = (anchorVal k, k)`; `r k := kvE2_ordRank g k`; per owner
   tag `.coincident`, tuple `(3·r k, 3·r k + 1, 3·r k + 2)` for the strict-distinct case. DECIDE how
   coinciding anchors are handled (fall back to the coincident tuple layout, or prove the bundle
   forbids coincidence under an added hypothesis). Introduces NO `x1 < e_i` literal (LITMUS): only
   already-extracted anchor witnesses are ordered by M's `LinearOrder`.
3. **Membership `kvE2_sepHonestOrder_mem_arr'`** — mirror `kvE2_sepCoincidentOrder_mem_arr'`
   (SW:1899). (i) coincidence validity reused VERBATIM (all tags `.coincident`; owners interior via
   `hLR`; `kvE2_sepCoincidentOwner_valid_left/right`, SW:1721/1795). (ii) consistency `i₀<i₁<i₂`:
   `3r<3r+1<3r+2` by `omega`, OR (finer layout) `kvE2_ordRank_strictMono` on the bundle chain.
   (iii) `i₀`-Nodup: `kvE2_ordRank_injective` (lex family injective) → `List.Nodup` of the mapped
   `i₀` list (needs a `zipIdx`/`map` Nodup bridge). Enumeration membership via
   `kvE2_sepIdxTuple_mem_of_lt` (SW:757), all ranks `<3n`.
4. **Monotonicity `kvE2_sepHonestOrder_monotone`** — `kvE2_sepSlotsLOf/ROf` (mergeSort by
   `kvE2_sepSlotMergeLe`/`kvE2_sepSlotGIdx`, SW:939/954) reproduce M-value order. Needs a
   `List.mergeSort` sorted spec (`List.sorted_mergeSort` / `List.mergeSort_perm`) + the fact that the
   key `kvE2_sepSlotGIdx wo` on the honest `wo` equals the region-rank index, which is monotone in
   value by construction. The `a<u'<b` case: `i₂(σ) < i₁(τ)` ⟺ `r σ < r τ` ⟺ `x1_σ <_lex x1_τ`.
5. **Bundle export (5.2) `hpos/hlink/hnd/hreal`** for `k1v_sorted_realizationK`
   (SubBracket2V.lean:633-646). `hreal` (per-region realizer points) is where the coinciding-anchor
   obstruction must already be resolved by the layout choice in step 2 — realization freedom lets 337
   place each region's points to match the block order ONLY when consecutive anchors leave room.
6. **`kvE2_sepBody_complete_holds`** reduction to the 337-owned `.holds`
   (`kvE_subBracket2V_sound_of_parts`, SubBracket2V.lean:1025), feeding `kvE2_sepBody_holds_iff.mpr`
   (SW:1122). 340's sorry-free deliverable ends at the bundle; the `.holds` is 337's.

## Sorry Inventory

Empty (`[]`). No sorry, no vacuous placeholder, no new axiom introduced this dispatch.
`kvE2_sepCoincidentOrder` and all Phase 1-4/6 assets untouched.

## Interface to 337

Unchanged from handoff #1: task 337 remains BLOCKED. The engine-precondition bundle (step 5) is
NOT yet delivered. The kernel is a prerequisite now satisfied; steps 2-6 remain.
