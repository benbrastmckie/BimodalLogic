# Report 06 — Residual Granularity Verdict: Does 337's `.holds` builder need task 340?

**Task**: 337 — build joint multi-owner disjunct `bracket.holds` engine for `kvE2_sepDisjunct`
**Mode**: RESEARCH/VERIFY-ONLY (no file edits; `lean_run_code` scratch experiments only)
**Question**: Can the additive `.holds` builder (`kvE2_sepBody_holds_iff.mpr`) be built directly on
task 339's 2-level point-level slots, OR is a FOURTH carrier layer (a per-slot global index,
task 340) genuinely required first?

## Verdict

```json
{
  "task_340_required": true,
  "cross_region_interleaving_occurs_in_honest_models": true,
  "evidence": "SharedWitness.lean:1415-1419 (kvE2_sepHonestBundleL constrains σ's above-anchor lUW witness ONLY by x1_σ < u < w, NO cross-owner relation); :880-885 (kvE2_sepSlotMergeLe region-rank PRIMARY); :896-898 (kvE2_sepSlotsLOf mergeSort by that key); :1041-1050 (kvE2_sepBody_holds_iff.mpr builder obligation over kvE2_sepSlotsLOf/ROf wo); :1619-1621 (kvE2_sepCoincidentOrder — honest arrangement .mpr serves — carries the coincident tag as a bit-selector only, still building σ's lUW slots); :245-253 (kvE2_sepSlotRank lXU=0,lX1=1,lUW=2); :289-299 (kvE2_sepSlotsLFor block shape). Scratch experiments: (A) region-primary mergeSort of {σ.lX1(r1), σ.lUW(r2), τ.lX1(r1)} yields [σ.lX1, τ.lX1, σ.lUW] — τ.x1 before σ.lUW; (B1) honest below-anchor config a<u<b is constructible; (B2) omega derives False from (a<u<b honest) ∧ (a<b<u forced by list order); (C) both owner-rank assignments keep τ.lX1 before σ.lUW (rank-independent).",
  "path": "340 per-slot-global-index spec — see §5 below"
}
```

**Bottom line**: The residual granularity gap flagged by 339's own design-spec (report 02,
lines 112-121) is REAL and it bites the honest arrangement that `kvE2_sepBody_holds_iff.mpr` must
serve. An owner σ's region-2 slot (`lUW`, above σ's anchor) can be realized at a model value
*below* another owner τ's region-1 slot (`lX1`, τ's anchor). 339's region-rank-primary 2-level key
puts τ.x1 before σ.lUW unconditionally, contradicting that value order. No additive monotone
witness exists over the fixed 339 slot order. Task 340 (a per-slot global index reflecting model
value order) is genuinely required before 337 can proceed.

## 1. The builder obligation and the arrangement it serves (ground truth)

`kvE2_sepBody_holds_iff.mpr` (SW:1041-1050) is the 337 obligation: for some `wo ∈ kvE2_sepArr'`,
construct `(kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds`. Via
`holds_eq_succ` (ExistsForallNF.lean:188-204) this is ONE globally strictly-monotone
`witnesses : Fin n → M.carrier` whose index order **is** the slot-list order (line 117 global
monotonicity; line 121 point types at witnesses).

The honest arrangement the completeness side selects is `kvE2_sepCoincidentOrder` (SW:1619-1621)
— every owner at its own fresh anchor. Critically, the `coincident` tag is a **bit-selector only**
(report 04:31-50; SW:748-752): it changes which validity bit is read, NOT the slots built. Each
owner σ still contributes its full `kvE2_sepSlotsLFor` block `[lXU σ …] ++ [lX1 σ] ++ [lUW σ …]`
(SW:289-299), so σ's above-anchor `lUW` slots are present in the coincident arrangement.

## 2. Honest models DO permit cross-region interleaving (decisive question 1 → YES)

The honest witness bundle `kvE2_sepHonestBundleL` (SW:1408-1419) is the exact realizability
guarantee 337 gets. Its conclusion for σ's above-anchor (zUW) 1-types (SW:1418-1419):

```
(∀ χ ∈ kvE2_sepS σ kvE_sub2_zUW, ∃ u : M.carrier, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ)
```

The ONLY constraint on σ's `lUW` witness `u` is `x1_σ < u < w`. There is **no** relation to any
other owner's anchor. The bundle is extracted per-owner independently
(`kvE_subBracket2_complete_extract σ`, SW:1424), so two owners σ, τ with anchors `x1_σ = a`,
`x1_τ = b`, `x < a < b < w`, may honestly realize σ's `lUW` witness `u` **anywhere in `(a, w)`**,
including in `(a, b)` — i.e. `a < u < b`, σ's region-2 point BELOW τ's region-1 anchor.

This is a strictly HONEST configuration: `u ∈ (x1_σ, w)` satisfies the bundle exactly; the
universal `_of_honest` obligation must cover it. (This refines report 04, which established that
interleaving honest models exist but exhibited the *above*-anchor direction `u > b`, which the
region-primary key happens to handle. The *below*-anchor direction is the one 339's key cannot.)

## 3. 339's 2-level key mis-orders it (decisive question 2 → confirmed)

`kvE2_sepSlotMergeLe` (SW:880-885) = `ra < rb ∨ (ra = rb ∧ ownerRank a ≤ ownerRank b)`, region
rank PRIMARY. With `kvE2_sepSlotRank` (SW:245-253) giving `lX1 = 1`, `lUW = 2`:

**Experiment A** (`lean_run_code`, region-primary mergeSort of the 3 slots):
`[σ.lX1(r1,o0), σ.lUW(r2,o0), τ.lX1(r1,o1)] → ["σ.lX1", "τ.lX1", "σ.lUW"]`.
So the list index order is `σ.lX1 (0) < τ.lX1 (1) < σ.lUW (2)`; τ's anchor precedes σ's lUW.

`.holds` global monotonicity along that index order forces
`witness(σ.lX1) < witness(τ.lX1) < witness(σ.lUW)`, i.e. `a < b < u`.

**Experiment B** (`lean_run_code`): B1 — the honest config `a < u < b` is constructible
(`⟨0,1,2,3,4⟩` over `Int`). B2 — `(a < u ∧ u < b) ∧ (a < b ∧ b < u) ⊢ False` by `omega`. So the
339-ordered monotone witness sequence is UNSATISFIABLE on this honest model.

**Experiment C** (`lean_run_code`, rank-independence): both owner-rank assignments
(`σ<τ`, `τ<σ`) sort to keep `τ.lX1` strictly before `σ.lUW` (`["σ.lX1","τ.lX1","σ.lUW"]` and
`["τ.lX1","σ.lX1","σ.lUW"]`). Because region is primary and `kvE2_sepSlotRank` is a fixed static
field, NO `wo` choice (which only permutes `kvE2_sepOwnerRank`, the SECONDARY key) can move σ.lUW
(region 2) before τ.lX1 (region 1). No `wo ∈ kvE2_sepArr'` rescues the build.

Therefore the additive 337 builder CANNOT realize the fixed 339 slot order monotonically for this
honest input. **Task 340 is genuinely required.**

## 4. Why this is a 2-level-key limitation, not a wo-choice limitation

339's key is `(region, ownerRank)` ∈ ℕ×ℕ. Region separates the three intra-owner layers; owner
rank orders owners *within* a layer. The honest value order `a < u < b` places
`σ.lX1(region1) < σ.lUW(region2) < τ.lX1(region1)` — a region-2 slot strictly between two
region-1 slots. No lexicographic key with region primary can produce "region-1, region-2, region-1"
(region primary always groups all region-1 before all region-2). This is exactly report 02's
flagged case `a < u' < b` (339 report 02:114-116): "not value-faithfully reproduced by ANY 2-level
key — full value-faithfulness needs a per-SLOT global index."

## 5. What task 340 must add (the per-slot-index spec)

**Core change**: replace the derived 2-level key with a single per-slot GLOBAL INDEX reflecting the
model value order of the point each slot realizes, so `mergeSort` reproduces the exact honest value
order (a total order on the full slot multiset, not a region×owner product).

**Carrier / definitions to add or change** (all in SharedWitness.lean unless noted):

| Item (line) | 340 change |
|---|---|
| `KvE2SepWeakOrder` (SW:694-695) + `kvE2_sepOrderTypes` (SW:706-711) | Enrich so each disjunct carries a **per-slot** global index (a total order on the merged slot multiset), not just a per-owner rank. Enumeration ranges over order-consistent global interleavings of individual slots. |
| `kvE2_sepSlotMergeLe` (SW:880-885) | Collapse to a **single-level** compare on the per-slot global index; drop the region-primary lex. |
| `kvE2_sepOwnerRank` (SW:868-870) | Replaced/supplemented by a per-slot index reader keyed on the slot (not the owner). |
| `kvE2_sepSlotsLOf/ROf` (SW:896-904) | Sort the flatMap base by the global-index key. Membership (`mergeSort_perm`) preserved. |
| `kvE2_sepDisjValid[Owner]` (SW:748-759) | Add a consistency conjunct: the per-slot global index must EXTEND each owner's own region order (`lXU < lX1 < lUW` on the left, mirror on the right) — a linear-extension-of-partial-order constraint. |
| `kvE2_sepCoincidentOrder` (SW:1619-1621) + `kvE2_sepBody_complete` (SW:1590) | The honest completeness witness must supply the global index consistent with the model value order. |
| `kvE2_sepHonestBundleL/R` (SW:1408, 1460) | Must be extended to yield the **cross-owner value order** of the extracted witnesses (currently only per-owner `(x, x1_σ, w)` bounds). The carrier's total order on `M.carrier` makes the cross-owner comparison derivable; 340 must thread it into the index. |

**Preserved (statement + same-owner rank→index monotonicity survives)**: the ⇒-extraction lemmas
`kvE2_sepDisjunct_extract` (SW:2015) and `kvE2_sepBody_extract` (SW:2163) rely only on
`rank a < rank b → index a < index b` for SAME-owner slots (report 02:45-53). A per-slot global
index that extends each owner's region order still satisfies this, so those lemmas are preserved
(re-verify only). 339's `kvE2_sepSlotsLOf_mem`/`ROf_mem` membership route via `mergeSort_perm` is
also preserved (the base flatMap is unchanged; only the comparator changes).

**Only AFTER 340** can 337's builder proceed: with a value-faithful per-slot index the merged slot
order equals the honest model value order, and the monotone witness is the sorted realization via
the boundary-linked merged-anchor engine `k1v_sorted_realizationK` (SubBracket2V.lean:633) — the
construction 339 report 02:108-110 anticipated but which fails on a 2-level key.

## Adversarial Self-Verification

| Claim | Source / Counterexample | Verification Method | Confidence |
|-------|--------------------------|---------------------|------------|
| σ's lUW witness constrained only by `x1_σ < u < w`, no cross-owner relation | SW:1415-1419 (bundle conclusion), :1424 (per-owner extractor) | source read of committed lemma | High |
| Honest below-anchor config `a < u < b` is realizable | fold-bit forces zUW witness to exist; bundle admits any `u ∈ (a,w)`; B1 constructible | `lean_run_code` (B1) + bundle read | High |
| Region-primary key sorts τ.lX1 before σ.lUW | SW:880-885 + `kvE2_sepSlotRank` SW:245-253 | `lean_run_code` mergeSort (A) | High |
| Fixed 339 order → no monotone witness on that honest model | list order forces `a<b<u`, honesty gives `a<u<b` | `lean_run_code` omega ⊢ False (B2) | High |
| No `wo` rescues it (rank-independent) | region primary + static `kvE2_sepSlotRank`; both owner-rank assignments keep τ.lX1 first | `lean_run_code` (C) | High |
| Gap applies to the arrangement `.mpr` serves (coincident) | SW:1619-1621 (tag = bit-selector), :289-299 (lUW slots still built), :748-752 | source read | High |
| Same-owner rank→index preserved → ⇒-extraction lemmas survive | report 02:45-53; a global index extends each owner's region order | analytic + report cross-check | Medium-High |

**Contradiction log**: none. One nuance surfaced and resolved: report 04's interleaving example
used the *above*-anchor direction (`u > b`), which region-primary handles; the residual gap is the
*below*-anchor direction (`u < b`), which it does not. Both are honest; the builder must serve
both, so the below-anchor case alone forces 340. No forbidden "mathlib likely has" conclusions;
every load-bearing claim is either a `lean_run_code` result or a cited `file:line` source read.

**Recommendations modified after verification**: none — the verdict (`task_340_required: true`) was
reached only after Experiments A/B/C, not by abstract reasoning alone.
