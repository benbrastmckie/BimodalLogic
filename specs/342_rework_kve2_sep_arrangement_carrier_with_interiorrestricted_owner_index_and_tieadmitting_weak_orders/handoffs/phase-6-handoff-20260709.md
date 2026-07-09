# Task 342 Phase 6 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 7 (meet-folded grouped disjunct builder + `kvE2_sepBody` rewire): add the grouped
segment dispatcher `kvE2_sepSegsG`, the TOP-LEVEL `kvE2_sepDisjunct'` consuming
`gL gR : List (List (KvE2SepSlot sig))`, the `.holds`-level singleton-compatibility lemma,
the per-class evaluation helper, then rewire `kvE2_sepBody` (SW:2206) and restate
`kvE2_sepBody_holds_iff` (SW:2243) and `kvE2_sepBody_complete_holds` (SW:4859). See
"Phase 7 Recipe" below.

## Current State

- Phase 6 [COMPLETED] (plan heading + all checklist items updated, deviations annotated).
- Full `lake build` green (1720 jobs). Commit `1cb7dde1c`
  (`task 342 phase 6: tie-admitting validity — conjunct (iii) replacement and tie-class
  grouping`). Diff: 466 insertions, 69 deletions (SharedWitness.lean + plan file).
- **Conjunct (iii) REPLACED** in `kvE2_sepDisjValid` (SW:1767). Live conjunct structure now:

  ```lean
  wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2.1)          -- (i)   unchanged verbatim
    && wo.all (fun p => kvE2_sepConsistentBlock p.1 p.2.2)    -- (ii)  unchanged verbatim
    && kvE2_sepAnchorDistinct wo                              -- (iii') anchor payloads Nodup
    && kvE2_sepTieRead wo                                     -- (iv)  base-anchor tie reads
  ```

  Destructuring pattern at consumers: `rw [kvE2_sepDisjValid, Bool.and_eq_true,
  Bool.and_eq_true, Bool.and_eq_true]` then `⟨⟨⟨(i), (ii)⟩, (iii')⟩, (iv)⟩`.
- **New declarations** (all axiom-clean `{propext, Classical.choice, Quot.sound}` or less):
  - `kvE2_sepClosedLeafAt` (SW:1525) + `kvE2_sepClosedLeafStub_eq_at` (`rfl`) — CLOSED
    `zAtX1L`/`zAtX1R` self-zone read at a FOREIGN base type (F5-clean; the Phase-8 discharge
    target).
  - `kvE2_sepSlotIsAnchor`, `kvE2_sepSlotBaseType` (+ `_eq_none_of_isAnchor`) — slot
    classifiers.
  - `kvE2_sepAnchorSlot` (+ `_injective`, `kvE2_sepSlotSub_anchorSlot`,
    `kvE2_sepAnchorSlot_mem_block`), `kvE2_sepAnchorPayload` (+ `kvE2_sepAnchorPayload_map`)
    — `idxOf`/`kvE2_sepBlockPos`-based anchor projection (deviation from the plan's
    `(kvE2_sepS σ …).length` arithmetic — same content, keeps `kvE_sub2_` names out of the
    new code entirely).
  - `kvE2_sepAnchorDistinct` (SW:1625), `kvE2_sepTieRead` (SW:1639).
  - `kvE2_sepValid_tie_of_nodup` (SW:1659) — THE shared repair lemma: globally-`Nodup`
    `block.map g` payload ⟹ (iii') ∧ (iv), parametric over the tag function and `g`.
  - `kvE2_sepTieRuns` kernel (SW:1971; house recursive adjacent-run grouping —
    `List.splitBy` ships without lemma support on v4.27.0-rc1) with `_shape`, `_flatten`,
    `_ne_nil`, `_of_nodup`; `kvE2_sepTieGroupedL/R` (SW:2054/2059) + `_flatten`, `_ne_nil`,
    `_of_nodup` instances.
- **Repaired consumers** (the ONLY four): `kvE2_sepBody_complete`,
  `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'` — (iii)/(iv) branches
  discharged by `kvE2_sepValid_tie_of_nodup` instantiated at the banked
  `kvE2_sepAllSlots_map_slotIndexOf_nodup` resp. `_honestGIdx_nodup` (conjuncts (i)/(ii)
  verbatim); `kvE2_sepArr'_sound` restated — its second component is now
  `kvE2_sepAnchorDistinct wo = true ∧ kvE2_sepTieRead wo = true` (the old global-`Nodup`
  conclusion is false by design under ties; it had zero downstream consumers).
- **Exit-gate audit**: guard `kvE2_sepHonest_hLR_absurd` (now SW:5226) zero diff hunks;
  exactly one `hLR` binder file-wide (SW:5230, inside the guard); `kvE2_sepPosI_eq_pos`
  0 occurrences repo-wide; 0 code sorries in SharedWitness (all 7 grep hits are prose);
  no `kvE_sub2_` key and no `x1 <` literal anywhere in the new code; axiom count in
  Theories/ unchanged (2, baseline); vacuous-def scan: 1 pre-existing hit in
  `Examples/TemporalStructures.lean` (untouched, baseline).

## Representability check (the defect this phase repairs — demonstrated, not restated)

The enumeration `kvE2_sepOrderTypes` (via `kvE2_sepIdxTuplesN`) always contained weak orders
with cross-owner duplicate payload entries; the old (iii) filtered ALL of them out of
`kvE2_sepArr'`, so the Lemma 3.2(1) equality-case order types realized no disjunct:

1. **Honest base-base tie** (two base slots share a payload value): (iii') reads ONLY the
   anchor positions' payloads — base entries never enter `wo.map kvE2_sepAnchorPayload`, so
   the tie cannot falsify it. (iv)'s trigger requires the FIRST member of a tied pair to be
   an anchor slot (`kvE2_sepSlotIsAnchor sj.1`); for a base-base pair NEITHER orientation
   triggers, so the branch returns `true`. Hence such a wo passes the new (iii')&&(iv), and
   with (i)/(ii) unchanged it is a member of `kvE2_sepArr'` — representable.
2. **Honest base-foreign-anchor tie** (base slot of type `χ` ties the anchor of owner `σa`):
   (iii') is untouched (one anchor in the class); (iv)'s (anchor, base) orientation demands
   exactly `kvE2_sepClosedLeafAt σa χ = true` — the anchor owner's CLOSED self-zone bit
   generalized to the foreign base type, which the honest model forces true (Phase 8
   discharge, generalizing `kvE2_sepCoincidentAnchor_discharge`/`_R`). Representable, gated
   by an F5-clean CLOSED-key read.
3. **Anchor-anchor ties remain excluded** by (iii') — Lean-side `nf_eval_unique`-backed
   pruning (task-340 Phase 5A keystone), documented as having NO Rabinovich counterpart
   (audit D7).

## Phase 7 Recipe (meet-folded grouped disjunct builder)

**Current live shapes** (anchors as of commit `1cb7dde1c`):
- `kvE2_sepDisjunct` (SW:1194): point types `lL.map (kvE2_sepSlotType charBase charK)`,
  bracket `kvE2_sepBracketN` (SW:1183), segments `kvE2_sepSegs charBase qnf lL lR`.
- `kvE2_sepSegLAt` (SW:1156): the per-cut refined conjunction the grouped dispatcher reuses
  at the flat prefix — segment at grouped cut `i` of `gL` =
  `kvE2_sepSegLAt charBase qnf gL.flatten ((gL.take i).flatten).length` (segments already
  meet-fold across all owners per cut — Phase 4 finding; tie folding is point-type grouping
  + cut reindexing ONLY).
- `kvE2_sepBody` (SW:2206): `dite` on the gate; disjuncts =
  `(kvE2_sepArr' qnf).map fun wo => kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)`.
- `kvE2_sepBody_holds_iff` (SW:2243): `dif_pos`/`holds_flatMap_map` route.
- `kvE2_sepBody_complete_holds` (SW:4859): wires `holds_iff` + `HonestOrder_mem_arr'`.
- `kvE2_sepBracketN_construct` (SW:5129, private) and `kvE2_sepDisjunct_extract` (SW:5278)
  are parametric in flat point-type lists — MUST survive unchanged.

**Steps** (plan Phase 7 tasks):
1. `kvE2_sepSegsG` grouped segment dispatcher: cut `i` of `gL` reuses `kvE2_sepSegLAt` at
   `((gL.take i).flatten).length` on `gL.flatten`; right mirror. NO new β machinery.
2. `kvE2_sepDisjunct'` TOP-LEVEL (crux failed-closer-3 lesson: no let-buried builders):
   point types `gL.map (fun c => ⟨formula_conjList (c.map (kvE2_sepSlotType charBase charK))⟩)`,
   shared `ptW`, `kvE2_sepBracketN` reused as-is, segments `kvE2_sepSegsG`. Docstring: the
   strict-quotient guard + audited citation form (forced by Def 3.1 p.4; Lemma 3.2(1) states
   the closure without printed proof; k=m split p.7 and Def 7.5 p.13 corroboration only —
   NEVER "per the proof of Lemma 3.2(1)").
3. Singleton-compatibility at `.holds` level (NOT syntactic): all-singleton `gL`/`gR` with
   `gL.flatten = lL`, `gR.flatten = lR` ⟹ `(kvE2_sepDisjunct' …).2.holds M atomMap x t ↔
   (kvE2_sepDisjunct … lL lR).2.holds M atomMap x t`. Pointwise `formula_conjList [f]`
   eval-equals `f`; segments align by cut arithmetic. The Phase-6 lemmas
   `kvE2_sepTieGroupedL/R_of_nodup` produce exactly the all-singleton hypothesis shape
   (`(kvE2_sepSlotsLOf wo).map (fun s => [s])`) from a `Nodup` payload.
4. Per-class evaluation helper: realized `formula_conjList (c.map …)` point ⟹ each member's
   type realized (the one extraction-side deliverable owed to the 337 re-plan).
5. Rewire `kvE2_sepBody`: `… fun wo => kvE2_sepDisjunct' charBase charK qnf
   (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)`.
6. Restate `kvE2_sepBody_holds_iff` over the grouped builder (same route), then
   `kvE2_sepBody_complete_holds`: the honest order's payload is `Nodup`
   (`kvE2_sepAllSlots_map_honestGIdx_nodup` via `kvE2_sepSlotGIdx_honestOrder` — note the
   grouping key on `kvE2_sepSlotsLOf (HonestOrder …)` is `kvE2_sepSlotGIdx`, equal to
   `kvE2_sepSlotHonestGIdx` on block slots by the banked halign bridge SW:~3600s), so
   `kvE2_sepTieGroupedL/R` are singletons and the proof wires through the singleton-compat
   lemma + `HonestOrder_mem_arr'` exactly as before.
7. Confirm `kvE2_sepDisjunct_extract` and `kvE2_sepBracketN_construct` untouched and green;
   `IntervalPattern.holds` untouched (git diff on Kamp/ExistsForallNF.lean empty); LITMUS
   grep (`x1 <`) clean on new code. Full `lake build`.

**Singleton-compat hint**: to get the `Nodup` hypothesis for `kvE2_sepTieGroupedL_of_nodup`
on the honest order, note `kvE2_sepSlotsLOf wo` is a `mergeSort` PERMUTATION of the flatMap
union (`List.mergeSort_perm`), map-key `Nodup` transfers along permutations
(`List.Perm.map` + `List.Perm.nodup_iff`), and the flatMap union's `kvE2_sepSlotGIdx` image
is `Nodup` on the honest order via the halign bridge + `_honestGIdx_nodup` restricted to the
LEFT-region sub-family (a sublist of `kvE2_sepAllSlots`; `List.Sublist.nodup` on the map —
`kvE2_sepSlotsLFor σ` is a prefix-sublist of `kvE2_sepSlotBlock σ`).

## Key Decisions / Gotchas

- `kvE2_sepTieRead` quantifies pairwise over BOTH orientations of every slot-occurrence
  pair, so the (anchor, base) read triggers regardless of order; base-base pairs never
  trigger (first component must be an anchor). Intra-owner ties (own anchor vs own
  cross-region base) are deliberately INCLUDED ("foreign or own", plan wording).
- `rw [kvE2_sepTieRuns, heq]` works on the grouping kernel, but `if_pos`/`if_neg` must be
  applied with `simp only` — the ite sits under the match-branch binder (rw cannot rewrite
  under binders). Same pattern applies to any future proof unfolding `kvE2_sepTieRuns`.
- `List.forall_mem_zipIdx'` (Mathlib Enum.lean) is NOT in this file's import closure — use
  core `List.mem_zipIdx_iff_getElem?` + `List.getElem?_eq_some_iff` instead (as
  `kvE2_sepValid_tie_of_nodup` does).
- The lean-lsp `lean_run_code` tool returns empty diagnostics even for failing snippets in
  this environment — do not trust it; probe toolchain sources or use `lean_goal`/builds.
- The 340-plan file `specs/340_*/plans/03_*.md` and `working-progress-1783582863.patch`
  remain dirty from an unrelated session — do NOT stage them.
- FORBIDDEN (unchanged): any PosI/Pos equality lemma; any hLR-shaped hypothesis;
  `kvE2_sepPosI` as an append of two zone filters; weakening `IntervalPattern.holds`
  strictness; citing "per the proof of Lemma 3.2(1)".

## Sorry Inventory

(empty)
