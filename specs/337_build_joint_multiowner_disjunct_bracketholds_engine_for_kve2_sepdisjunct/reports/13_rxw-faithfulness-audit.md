# Report 13 — `.rXW` Weak-Epsilon Bound: Faithfulness Audit vs. Rabinovich (2014)

**Task**: 337 | **Session**: sess_1783639750_29c89e_337 | **Type**: lean4 research (read-only)
**Blocker**: `kvE2_sepSepSlotValue .rXW` epsilon predicate lacks a `v < w` bound; O1's grouped LEFT
bracket needs `usL-last < w`.
**Primary source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(md line numbers below; PDF consulted where the markdown mangles subscripts — flagged inline).

---

## Bottom line (verdict up front)

**Verdict = (a): a transcription omission in the `.rXW` epsilon predicate.** The slot ASSIGNMENT is
faithful (a right-interior owner *should* contribute a `(x,w)` slot to the LEFT list), the strict-`<`
demand of O1 is faithful (it is exactly Rabinovich's pivot-split constraint), and the missing `v < w`
conjunct is a genuine faithfulness DEFECT that the fix RESTORES. The information needed to prove
`v < w` is present in the model data all along (it is coordinate 1 of the `kvE_sub2_zXU` zone spec)
but is discarded at the very first extraction step. The fix is a **bounded carrier edit** to the
landed task-340 asset `kvE2_sepSlotValue` plus its `_rXW_spec`; it **cannot** be done purely
additively, so the escalation against plan 12's "strictly additive / do not edit any existing
declaration" constraint (plan 12 lines 119, 126) is legitimate and unavoidable.

The bug is **isolated to `.rXW`** — the other four base branches faithfully match their zone bits.

---

## Q1 — Faithfulness of the slot itself: should a RIGHT-interior owner contribute to the LEFT list?

**Answer: YES — the slot assignment is faithful. This is NOT a `kvE2_sepSlotsLOf` bug.**

`kvE2_sepSlotsLFor` (SW:331-338) sends, for a right-interior owner
(`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, i.e. `w < x1 < t`, SW:87-88), the slots
`(kvE2_sepS σ kvE_sub2_zXU).map (.rXW σ)` into the LEFT block. Its own doc comment (SW:328-330)
states the intent: *"for a right-interior σ its `(x,w)` types (read through the placement-generic
`kvE_sub2_zXU` bit pattern)."* The slot name `.rXW` literally encodes region **X-to-W** = `(x, w)`.

This is faithful to Rabinovich's construction. The Lean `w` is the shared **pivot** — Rabinovich's
split point `z` in the §5 inductive step. **Figure 1 (md:297-299, PDF p.9)** gives the pivot split
explicitly:

> `B2(z0, z, z1) := [α0, β1, α1, β2, β2](z0, z) ∧ [β2, β2, α2, β3, α3](z, z1)`

The LEFT bracket `[…](z0, z)` collects **all** witnesses strictly below the pivot `z`, regardless of
which quantifier layer (which owner σ) produced them. Cor 5.4 (md:255-279) and the Lemma 5.3
monotone chain `z0 < x1 < ··· < xn < z1` (md:225) confirm the witnesses are individual points
interleaved by position, not grouped by owner. So a right-interior owner whose normal form asserts
"there is a χ-witness in `(x, w)`" contributes a genuine below-pivot point that belongs in the LEFT
interleaving list. Placing it there is correct.

*Paper citation*: Rabinovich §5, Figure 1 (md:297-299, PDF p.9); Cor 5.4 (md:255-279); Lemma 5.3
(md:225). The paper does not name "owners" or "slots" (those are formalization terms), but the
pivot-split of Figure 1 settles that below-pivot witnesses from any layer join one LEFT bracket.

**Consequence**: verdict (b) (slot-assignment drift in `kvE2_sepSlotsLOf`) is **ruled out**. The
LEFT-list membership of `.rXW` is exactly right; only its epsilon BOUND is wrong.

---

## Q2 — Faithfulness of the bound: does the zone semantics entail `v < w`?

**Answer: YES — `v < w` is genuinely carried by the zone bit, then discarded by the extraction.
The missing conjunct is a transcription omission; strengthening is faithfulness RESTORATION.**

Trace, decisively, through the zone spec (all over the anchor env `[x1, w, x, t]`, i.e. coord
0 = x1, coord 1 = **w**, coord 2 = x, coord 3 = t):

1. **The zone spec carries `v < w`.** `kvE_sub2_zXU` (SubBracket2.lean:123-124) is
   `Fin.cons (true,false) (Fin.cons (true,false) (Fin.cons (false,true) (fun _ => (true,false))))`.
   Via `kvE_sub2_zoneHolds_cons_iff` (SubBracket2.lean:538-546), the four coordinates decode as:
   - coord 0 (x1): `(true,false)` ⟹ `v < x1`
   - coord 1 (**w**): `(true,false)` ⟹ **`v < w`**
   - coord 2 (x): `(false,true)` ⟹ `x < v`
   - coord 3 (t): `(true,false)` ⟹ `v < t`

   So `kvE_sub2_zXU` genuinely means `x < v ∧ v < w ∧ v < x1 ∧ v < t`. For a right-interior owner
   (`w < x1`), the binding upper bound is `w`; `v < x1` is implied by `v < w < x1`. This exactly
   confirms the placement-generic comment (SW:102-105): *"for a RIGHT-interior σ (`w < x1 < t`) the
   SAME pattern `kvE_sub2_zXU` reads `x < v < w`."*

2. **The extraction throws `v < w` away.** `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565-572)
   destructures `⟨hp0, _, hp2, _⟩` — the second component `hp1` (the **w**-coordinate) is dropped —
   and returns only `x < v ∧ v < x1`. The `v < w` fact (`hp1.1.mpr rfl`) is derivable but discarded.

3. **The omission propagates.** `kvE_subBracket2_complete_extract`'s zXU field
   (SubBracket2.lean:619-620) therefore only offers `∃ v, x < v ∧ v < x1 ∧ …`; and
   `kvE2_sepSlotValue_rXW_spec` (SW:3642-3655) inherits only `v < anchorVal (= x1)`; and the landed
   `.rXW` epsilon predicate (SW:3540-3541) is written `x < v ∧ v < anchorVal ∧ χ` to match what the
   spec can prove.

The `v < w` information was present in the source zone datum at every stage and only lost at step 2.
Restoring it is faithfulness restoration, not a convenience.

*Paper citation*: The bound is the Def 3.1 point-type ordering channel (md:61-74; SubBracket2.lean:529
labels `kvE_sub2_zoneHolds_cons_iff` "Def 3.1 ordering channel, PDF p.4") and, at the construction
level, the below-pivot half of Figure 1's `[…](z0, z)` (md:297-299). Faithful.

---

## Q3 — Is the ε-over-weak-predicate a systematic bug? Audit of all five base branches.

**Answer: NO. The defect is isolated to `.rXW`. It is a copy-paste from the `.lXU` branch.**

Each branch's epsilon predicate (SW:3534-3545) vs. the zone bit it realizes:

| Branch | Owner class | Zone bit | Zone's true region | Epsilon predicate (SW) | Match? |
|--------|-------------|----------|--------------------|------------------------|--------|
| `.lXU` | LEFT-int (`x<x1<w`) | `kvE_sub2_zXU` | `x < v < x1` (x1<w) | `x<v ∧ v<anchorVal(=x1)` | ✓ faithful |
| `.lUW` | LEFT-int | `kvE_sub2_zUW` | `x1 < v < w` | `anchorVal<v ∧ v<w` | ✓ faithful |
| `.lWT` | LEFT-int | `kvE_sub2_zWT` | `w < v < t` | `w<v ∧ v<t` | ✓ faithful |
| **`.rXW`** | **RIGHT-int (`w<x1<t`)** | **`kvE_sub2_zXU`** | **`x < v < w`** | **`x<v ∧ v<anchorVal(=x1>w)`** | **✗ DEFECT** |
| `.rWX1` | RIGHT-int | `kvE2_sep_zWX1` | `w < v < x1` | `w<v ∧ v<anchorVal(=x1)` | ✓ faithful |
| `.rX1T` | RIGHT-int | `kvE_sub2_zWT` | `x1 < v < t` | `anchorVal<v ∧ v<t` | ✓ faithful |

The `.rXW` predicate (SW:3540-3541) is **byte-identical** to `.lXU` (SW:3534-3535): both
`x < v ∧ v < anchorVal`. That is the smoking gun — the right-interior branch was cloned from the
left-interior branch, carrying over the left-interior upper bound `x1` where the right-interior
reading requires `w`. Because `w < x1` for right-interior owners, `v < x1` is strictly weaker than
`v < w`, and the honest epsilon may land in `[w, x1)`.

The four faithful branches derive their bounds from extractions that DO keep the correct coordinate:
`.lUW`/`.lWT` via `kvE2_sepHonestAnchorBundleL` (SW:3433-3467), `.rWX1`/`.rX1T` via
`kvE2_sepHonestAnchorBundleR` (SW:3472-3514) which reads `kvE_sub2_zoneHolds_cons_iff` directly and
keeps the pivot coordinate (SW:3505-3506, 3512-3513). Only the `zXU` path routes through the
lossy `kvE_sub2_zoneHolds_zXU`. **One instance, one root cause — a one-branch patch, not a
carrier-wide correction.**

---

## Q4 — Strict monotonicity vs. ties: is O1's `Pairwise (· < ·)` itself the unfaithful step?

**Answer: NO. Weakening O1 (verdict (c)) would be UNFAITHFUL. Strict-`<` between tie classes is
exactly Rabinovich's construction; the `usL-last < w` demand is the below-pivot constraint.**

Rabinovich's witness chains are **strict**: Lemma 5.3 quantifies `∃x1…∃xn (z0 < x1 < ··· < xn < z1)`
(md:225); Def 3.1 (md:61-74) enumerates a strict chain of individual points. Task 342 already
handled genuine coincidences correctly: `kvE2_sepTieGroupedL` (SW:2054-2056) collapses maximal runs
of equal merge key into single bracket slots with a conjoined point type
(`formula_conjList (class.map kvE2_sepSlotType)`, SW:1960-1961), and one value per class
(`kvE2_sepSlotHonestVIdx_eq_iff`, SW:5857). So the `Pairwise (· < ·)` in O1
(`kvE2_sepBracketN_construct` `hsort`, SW:5363) is over **class representatives**, which are already
tie-merged — distinct classes legitimately demand strict `<`. This matches Def 7.13's union of slot
structures over distinct `zi` (md:451) and the meet-at-formula-level of Figure 1's shared `β2` at the
pivot (md:299).

Crucially, the pivot constraint is not about ties at all: Figure 1's LEFT bracket `[…](z0, z)`
requires **every** left witness strictly below `z (= w)`. A `.rXW` value in `[w, x1)` violates this
no matter how ties are grouped — grouping cannot rescue a value that is itself on the wrong side of
the pivot. So `usL-last < w` is faithful and mandatory. Weakening O1 to a non-strict or
pivot-crossing order would let a LEFT witness sit at/after the pivot, breaking the `[…](z0, z) ∧
[…](z, z1)` decomposition. Verdict (c) is **ruled out**.

*Paper citation*: Lemma 5.3 strict chain (md:225); Figure 1 pivot split (md:297-299); Def 7.13
(md:451). The paper requires strict below-pivot placement; O1 is faithful.

---

## Q5 — Verdict and minimal faithful fix

**Verdict: (a) transcription omission in `.rXW` → strengthen the predicate to `x < v ∧ v < w ∧ χ`.**

### Why it cannot be additive (escalation is justified)

The value is `Classical.epsilon` over the `.rXW` predicate (SW:3540-3541) and is structurally pinned:
`kvE2_sepSlotValue_baseType_spec` (SW:5943) and the honest order route
`kvE2_sepSlotHonestVIdx_eq_iff` (SW:5857) equate the tie-class witness with this exact
`kvE2_sepSlotValue`. `Classical.epsilon_spec` can only yield conjuncts that appear in the predicate;
since `v < w` is absent, no downstream additive lemma can recover it, and the epsilon may genuinely
select `v ∈ [w, x1)`. Plan 12 itself pre-flagged this (line 140) but mis-mitigated it: it claimed O1
"rides `kvE2_sepSlotsLOf_honest_valueSorted` (SW:4157), NOT zone bounds." Value-sortedness proves the
left values are mutually ordered; it does **not** prove the largest left value is `< w`. So the plan
12 mitigation is unsound, and the definition must change. This is why the edit violates plan 12's
"do not edit any existing declaration; strictly additive" constraint (plan 12 lines 119, 126) — and
that violation is unavoidable for a faithful fix.

### Minimal edit (name exact declarations / lines / landed assets touched)

1. **Strengthen the extraction to keep `v < w`** (SubBracket2.lean — task-324/340 asset). Either
   (preferred, most local) add a sibling lemma to `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565-572)
   that returns `x < v ∧ v < w ∧ v < x1` by keeping the discarded `hp1` (the coord-1 component of
   `kvE_sub2_zoneHolds_cons_iff`, SubBracket2.lean:543-544); or add a `zXU`-below-`w` field to
   `kvE_subBracket2_complete_extract` (SubBracket2.lean:619-620). No new axioms, sorry-free — the
   fact is already provable from the zone spec.
2. **Strengthen `kvE2_sepSlotValue_rXW_spec`** (SW:3642-3655, a landed task-340 spec) to conclude
   `x < v ∧ v < w ∧ χ` (from step 1). `v < anchorVal` remains derivable as `v < w < x1`, so any
   consumer that still wants `v < anchorVal` (e.g. `region_rank_mono` machinery) is unaffected.
3. **Edit the `.rXW` branch of `kvE2_sepSlotValue`** (SW:3540-3541, the task-340 CARRIER) from
   `fun v => x < v ∧ v < kvE2_sepAnchorVal … σ ∧ …` to
   `fun v => x < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ`. This is the single non-additive line.

**Landed assets touched**: `kvE2_sepSlotValue` (SW:3528, task-340 carrier — the forbidden edit);
`kvE2_sepSlotValue_rXW_spec` (SW:3642, task-340 spec); and one extraction lemma in
`SubBracket2.lean` (task-324/340). All three are landed 340-chain assets; none belong to 342.
The edit is ~3 lines of substance plus spec re-derivation, sorry-free and axiom-clean.

### Alternative if the additive constraint is held firm

If plan 12's "no existing-declaration edits" is treated as inviolable, the only faithful alternative
is a **plan revision** (`/revise 337`) that re-authorizes the bounded carrier edit above, because no
additive construction can strengthen a `Classical.epsilon` value already pinned by
`kvE2_sepSlotHonestVIdx_eq_iff`. Verdicts (b) and (c) are both ruled out (Q1, Q4), so there is no
faithful additive escape.

---

## F1-F7 invariants and LITMUS (NavigatedSpine:437) — fix is clean

- **LITMUS (NavigatedSpine:437-439)**: forbids introducing an `x1 < e_i` *relative-position* literal
  (a fresh/anchor point pinned against another existential point). The fix's new conjunct is `v < w`,
  where `w` is a fixed **environment** point (the shared pivot). This is an absolute env-anchored
  comparison, the same KIND already present and LITMUS-clean in the sibling `.lUW` predicate
  (`… v < w …`, SW:3537) and in the bundle-L/R specs (SW:3444, 3480). No `x1 < e_i` literal is
  introduced. **LITMUS clean.**
- **F1 (QF/E[Σ]-atom point types)**: untouched — `v < w` is an ordering-channel literal, not a
  formula literal; point types (`kvE2_sepSlotType`, SW:316-326) are unchanged.
- **F4/F5 (no model literal buried / no OPEN-key)**: the bound is read from the same zone
  ordering channel already used by the four faithful branches; no new model coupling. Consistent with
  the F4/F5/LITMUS-clean annotations on the surrounding value layer (SW:3525).
- **F2/F3**: realization stays non-vacuous (the honest witness genuinely exists in `(x,w)`); no new
  anchors are created — `.rXW` remains a base slot with `charBase χ` point type (SW:323).

The strengthened predicate uses a literal form already sanctioned elsewhere in `kvE2_sepSlotValue`,
so it introduces no new faithfulness liability.

---

## Evidence index (file:line)

- Zone spec carries `v<w`: `SubBracket2.lean:123-124` (def), `:538-546` (cons-iff decode).
- `v<w` discarded: `SubBracket2.lean:565-572` (`kvE_sub2_zoneHolds_zXU`, `hp1` dropped);
  propagates via `:619-620` (`complete_extract` zXU field).
- Defective predicate: `SharedWitness.lean:3540-3541` (`.rXW`), identical to `:3534-3535` (`.lXU`).
- Weak spec: `SharedWitness.lean:3642-3655` (`kvE2_sepSlotValue_rXW_spec`).
- Slot assignment (faithful): `SharedWitness.lean:331-338` (`kvE2_sepSlotsLFor`), doc `:328-330`;
  placement-generic reading `:102-105`.
- Faithful sibling branches: `SharedWitness.lean:3433-3467` (bundle L), `:3472-3514` (bundle R).
- Value pin: `SharedWitness.lean:5857` (`kvE2_sepSlotHonestVIdx_eq_iff`), `:5943`
  (`baseType_spec` consumes `_rXW_spec`).
- Tie grouping (Q4): `SharedWitness.lean:2054-2056`, `:1960-1961`.
- O1 obligation: `SharedWitness.lean:5357-5363` (`kvE2_sepBracketN_construct`, `hsort`).
- Plan 12 constraint / mis-mitigation: plan 12 lines 119, 126, 140, 222-225.
- Paper: Figure 1 pivot split md:297-299 (PDF p.9); Lemma 5.3 md:225; Cor 5.4 md:255-279;
  Def 3.1 md:61-74; Def 7.13 md:451.

*Note on the markdown source*: subscripts/superscripts are badly mangled throughout the md
conversion (e.g. Lemma 5.1/5.3 formula bodies, md:207-247). The load-bearing citations above (the
pivot split of Figure 1, the strict chain `z0 < x1 < ··· < xn < z1`) survive legibly in the md; the
`v < w` determination rests on the Lean zone spec (`SubBracket2.lean:123-124`, machine-decoded), not
on the mangled paper formulas, so no PDF re-extraction was required to settle the verdict.
