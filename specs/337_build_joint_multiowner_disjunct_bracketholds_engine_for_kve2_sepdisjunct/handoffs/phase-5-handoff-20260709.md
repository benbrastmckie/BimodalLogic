# Task 337 — Phases 4-5 COMPLETE, Phases 6-7 Continuation Handoff

**Session**: sess_1783639750_29c89e_337 | **Agent**: lean-implementation-agent
**State**: Phases 1-5 COMPLETE, green, axiom-clean. Full `lake build` green (1720 jobs).
**Next**: Phase 6 (O3b gap discharge) + Phase 7 (O4 assembly + the two public deliverables).

## What landed this dispatch (Phases 4 and 5)

All additive, at the END of `SharedWitness.lean` (after the Phase-3 lemmas, before `end Bimodal…`).
All axiom-clean `{propext, Classical.choice, Quot.sound}`; SharedWitness `sorry` count still **7**
(all prose). Committed:
- `task 337 phase 4: O2 class point-type realization at honest value`
- `task 337 phase 5: O3(a) honest segment-evaluation family`

### Phase 4 (O2) lemmas — REUSE, do not re-derive
- `kvE2_sepOwnerLit_zAtX1L` / `kvE2_sepOwnerLit_zAtX1R` (private): CLOSED self-zone literal honesty
  at the anchor value. Mirrors of `kvE2_sepOwnerLit_zAtWL`.
- `kvE2_sepPtX1L_eval_of_honest` / `kvE2_sepPtX1R_eval_of_honest`:
  `(kvE2_sepPtX1L/R charBase charK σ).eval_at M atomMap (kvE2_sepAnchorVal … σ)` given
  `hσ : σ ∈ kvE2_sepPos qnf` and `hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3` (resp `zWT3`).
- `kvE2_sepSlotType_eval_at_value`: for `s ∈ kvE2_sepSlotBlock σ` (σ positive),
  `(kvE2_sepSlotType charBase charK s).eval_at M atomMap (kvE2_sepSlotValue … s)`.
- **`kvE2_sepTieGroupedL_classType_eval` / `…R…`** (THE O2 deliverables): for
  `hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' …)` and `hs0 : s0 ∈ c`,
  `(kvE2_sepClassType charBase charK c).eval_at M atomMap (kvE2_sepSlotValue … s0)`.
  These directly feed `hptL`/`hptR` once you know `usL[i] = value of a member of gL[i]`.

### Phase 5 (O3a) segment-eval family — REUSE
- `kvE2_sepSegForm_eval_of_honest` (core): honest σ at `[a,w,x,t]` (hspec) + `hcb` + a zone `zs` +
  `hy : zoneHolds M [a,w,x,t] zs y` ⟹ `temporal_truth M atomMap y (kvE2_sepSegForm charBase σ zs)`.
- **`kvE2_sepSegLAt_eval_of_honest`** / **`kvE2_sepSegRAt_eval_of_honest`** (THE O3 deliverables):
  `(kvE2_sepSegLAt charBase qnf lL i).eval_at M atomMap y` given `x < y`, `y < w`, and the GENERIC
  bridge
  `hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →`
  `  ((lL.take i).contains (.lX1 σ) = true → kvE2_sepAnchorVal … σ < y) ∧`
  `  ((lL.take i).contains (.lX1 σ) = false → y < kvE2_sepAnchorVal … σ)`.
  RIGHT mirror uses `w < y`, `y < t`, `zWT3`, `.rX1 σ`, `lR.take j`. The cross-region owners'
  uniform-zone exclusion is discharged INTERNALLY (from `w < a` / `a < w`), so the bridge only
  quantifies the SAME-region interior owners.

## What remains (Phases 6-7) — the assembly

Target (verbatim, plan 13 §2.1): `kvE2_sepDisjunct'_holds_of_honest` producing
`(kvE2_sepDisjunct' charBase charK qnf gL gR).2.holds M atomMap x t`, where
`gL := kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)`, `gR := …TieGroupedR…`.

`.2.holds` decomposes `⟨EpL@x, EpR@t, bracket.holds⟩` (obtain ⟨hepL, hepR, hbr⟩; see
`kvE2_sepDisjunct_extract` ~SW:6215). EpL/EpR from `kvE2_sepEpL_eval_of_honest` (SW:7671) /
`kvE2_sepEpR_eval_of_honest` (SW:7797). `bracket.holds` from the engine
`kvE2_sepBracketN_construct` (SW:5365, private) fed with:
- `lL := gL.map (kvE2_sepClassType charBase charK)`, `ptW := kvE2_sepPtW charBase charK qnf`,
  `lR := gR.map (…)`, `segs := kvE2_sepSegsG charBase qnf gL gR`.
- `usL`, `usR` = the per-class honest VALUE lists.

### Recommended `usL`/`usR` construction
Every class is nonempty (`kvE2_sepTieGroupedL_ne_nil` SW:2074 / `…R…` SW:2079) and one-value-per-class
(`kvE2_sepTieGroupedL_value_const` SW:8063 / `…R…` SW:8093). Use `attach` to keep length:
```
usL := gL.attach.map (fun p => kvE2_sepSlotValue qnf M w x t h (p.1.head (kvE2_sepTieGroupedL_ne_nil … p.1 p.2)))
```
Then `hlenL : usL.length = (gL.map kvE2_sepClassType).length` is `by simp [List.length_map, List.length_attach]`.
The load-bearing getElem fact to prove once: `usL[i] = kvE2_sepSlotValue … (gL[i].head …)` and hence
`usL[i]` = value of any member of `gL[i]` (via `_value_const`). Use `List.getElem_map` +
`List.getElem_attach` (or `List.getElem_attachWith`). This getElem-through-attach threading is the
main mechanical cost.

### Obligation → discharge map
- **hlenL/hlenR**: `List.length_map`/`length_attach`.
- **hsort** `(usL ++ w :: usR).Pairwise (· < ·)`: `List.pairwise_append` + `List.pairwise_cons`.
  - within usL: `usL[i] < usL[j]` (i<j) from `kvE2_sepTieGroupedL_strictMono` (SW:8131) applied to
    `gL[i]`,`gL[j]` (heads are members) — but you must relate the list `Pairwise` on `usL` to the
    class-list `Pairwise` on `gL`. `List.pairwise_map` + the attach getElem fact.
  - usL-last < w and w < usR-first: `kvE2_sepSlotsLOf_honestOrder'_value_bound` (SW:8290, every LEFT
    slot value < w) and `…ROf…` (SW:8307). Each `usL[i]` = value of a member ∈ slotsLOf, so < w.
  - within usR: `kvE2_sepTieGroupedR_strictMono` (SW:8172).
- **hrange** `∀ u ∈ usL++w::usR, x < u ∧ u < t`: LEFT via `…LOf…_value_bound` (x<·<w<t), pivot w
  via hxw/hwt, RIGHT via `…ROf…_value_bound` (x<w<·<t).
- **hptL/hptR**: `kvE2_sepTieGroupedL_classType_eval` / `…R…` (Phase 4). Need `lL[i] =
  kvE2_sepClassType (gL[i])` (`List.getElem_map`) and `usL[i] = value of a member of gL[i]`.
- **hptW**: `kvE2_sepPtW_eval_of_honest` (SW:7732).
- **hseg0/hsegmid/hseglast**: `kvE2_sepSegsG` unfolds (SW:2167) to `kvE2_sepSegLAt … gL.flatten
  ((gL.take i).flatten).length` for `i ≤ gL.length`, else `kvE2_sepSegRAt …`. Feed
  `kvE2_sepSegLAt_eval_of_honest` / `…RAt…` (Phase 5). The remaining NEW work is the **bridge**:
  for grouped cut `j` with flat cut `FC_j = ((gL.take j).flatten).length`, prove
  `(gL.flatten.take FC_j).contains (.lX1 σ) = true ↔ kvE2_sepAnchorVal … σ < y` when
  `y ∈ (ws[j-1], ws[j])`. Ingredients:
  1. `gL.flatten.take FC_j = (gL.take j).flatten` — PROVEN helper (paste in), generic:
     ```
     theorem take_flatten_prefix {α : Type*} (L : List (List α)) (n : Nat) :
         (L.take n).flatten = L.flatten.take ((L.take n).flatten.length) := by
       induction L generalizing n with
       | nil => simp
       | cons a rest ih =>
         cases n with
         | zero => simp
         | succ m =>
           simp only [List.take_succ_cons, List.flatten_cons, List.length_append]
           rw [List.take_append, List.take_of_length_le (Nat.le_add_right _ _),
             Nat.add_sub_cancel_left, ← ih m]
     ```
  2. `.lX1 σ ∈ (gL.take j).flatten` ⟺ `.lX1 σ` is in one of the first `j` classes ⟺ (by value-order
     + `_value_const` + `_strictMono`) the class index `k` of `.lX1 σ` satisfies `k < j`, i.e.
     `a_σ = usL[k] ≤ usL[j-1] < y` (contains) or `a_σ = usL[k] ≥ usL[j] > y` (not). Uses
     `List.mem_flatten`, `List.mem_take_iff_getElem` and the class strict-mono.
  This bridge is the single hardest remaining piece (~one substantial lemma per region).
- **flat-cut length reindexing** for hsegmid indices: `(gL.take i).flatten.length` vs the point
  index; align via `kvE2_sepTieGroupedL_flatten` (SW:2064) and `List.length_flatten`/`take` arith.

### Public deliverables
1. `kvE2_sepDisjunct'_holds_of_honest` — EXACT §2.1 statement (plan Overview), after the Phase-5
   lemmas.
2. `kvE2_sepBody_holds_of_honest := kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)`
   (`kvE2_sepBody_complete_holds'` at SW:6166 consumes the PRIMED order at SW:6172 — MATCH IT).
   Task 335 consumes this.

## Guardrails (all still binding)
- Builder consumes the PRIMED `kvE2_sepHonestOrder'` (SW:5974). NOT `kvE2_sepModelOrder` / unprimed
  `kvE2_sepHonestOrder`.
- No vacuous close, no `sorry`, `hLR` stays deleted. Additive only from here (Plan-13 `.rXW`
  authorization is SPENT).
- Axiom check via `#print axioms <fq.name>` through `lake env lean` (the `lean_verify` MCP is
  unreliable on this file). SharedWitness `sorry` count must stay 7.

## Verification snapshot at handoff
- `lake build` (full): green, 1720 jobs, 0 errors.
- New Phase-4/5 lemmas: axiom-clean (verified via `#print axioms`).
- SharedWitness `sorry`: 7 (all prose).
