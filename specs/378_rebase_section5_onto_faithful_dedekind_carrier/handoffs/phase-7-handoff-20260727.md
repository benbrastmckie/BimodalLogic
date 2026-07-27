# Phase 7 handoff — Lemma 5.1's recursion landed faithfully, in ONE run

**Session**: `sess_1785164194_b6cbfb` | **Date**: 2026-07-27 | **Phase 7 status**: COMPLETED

## Immediate next action

Dispatch **Phase 8** (`VecEANegFixFaithful.lean`): the three-step lift
`BracketFormula.negFixFaithful → VecEA2.negFixFaithful → VVecEA2.negFixFaithful` with their `_iff`
lemmas. Step one is a two-line wrapper — `negFixListFaithful (bf.segmentTypes ⟨0, _⟩) bf.foldPairs`
plus `BracketFormula.holds_iff_bracketOf`, exactly mirroring `BracketFormula.negFix` /
`BracketFormula.negFix_iff` (`EANegationFix/NegFix.lean:479`/`:694`). Re-confirm the four line
numbers Phase 8's task list quotes before editing; the ones this dispatch touched had not drifted,
but the plan says to re-check and the prior phases have all found that cheap.

**Binding Constraint 3 becomes live at Phase 8.** `BracketFormula.negFix_iff` (`NegFix.lean:694`)
is INF-anchored and CONFIRMS the three-strikes ruling; it must not be cited as license for a fourth
attempt at the model-independent backward direction. The faithful lift is carrier-anchored the same
way and needs no such attempt: `negFixListFaithful_iff` already supplies the whole biconditional.

## THE COST CENTRE DID NOT OVERRUN

The plan declared Phase 7 the one phase expected to need a re-split, sized off `negFixList`'s 681
lines, with mandatory 7a/7b/7c boundaries. **It closed in one agent run.** The boundaries were held
in reserve and never reached; the three-strikes sizing guard did not fire; the plan is not
re-split.

Three things the estimate treated as work were already done — record these, they are the reason:

1. **The `Aᵢ`/`Bᵢ` split is carrier-free.** `splitsAt` / `bracketOf_splitsAt_iff` /
   `splitsAt_rightPairs_length_le` (`NegFix.lean:180`/`:216`/`:191`) are Rabinovich's p.10-11
   definitions already formalized, and nothing about them changes when the carrier changes. They
   were imported and used unchanged, including as the termination measure.
2. **`bracketOne_witness_le_infPin` needed no generalization.** Despite its name it is stated about
   a bare `β₁`-prefix condition, not about `bracketOne`, so it is the confinement step at *every*
   peel verbatim. This is the single most valuable thing Phase 6 handed forward, and the Phase 6
   handoff's prediction that "Phase 7's recursion will need the same step at every peel" was
   exactly right.
3. **`negBoundedLeftFixAnchoredFaithful_iff` (Phase 5) is a drop-in** for
   `negBoundedLeftFixAnchored_iff` at both of its call sites, and it is where `HasAttainedSUP` used
   to enter.

The remaining bulk was the `VVecEA2` mirror of the `PinnedItem` DNF machinery, which is mechanical.
Net new proof: ~200 lines, not 681.

## What Phase 7 landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean`,
18 declarations, all axiom-clean, 0 sorries:

| Declaration | Role |
|---|---|
| `VecPinnedItem` + `holdsAt`/`conj`/`conj_holdsAt_iff` | the `VVecEA2` mirror of `PinnedItem` (`NegFix.lean:298`) |
| `vecPinnedConj` / `_holdsAt_iff`, `VecPinnedItem.unit` / `_holdsAt`, `vecPinnedConjAll` / `_holdsAt_iff` | the DNF product machinery, one type level up |
| `VecPinnedItem.toV`, `vecPinnedListToV` / `_holds_iff` | the pin gluing, built on Phase 3's `VVecEA2.concatPin` + `conjEverywhere` |
| `witness_absurd_of_kplusLeft` | Case 1's whole content — **carrier-free** |
| `negFixListFaithful` | the recursion, THREE disjuncts per cons step |
| `negFixListFaithful_nil_iff` | Rabinovich's *"The basis is trivial."* (p.10) |
| `negFixListFaithful_iff` | the biconditional, `HasDedekindINF` **alone** |
| `negFixListFaithful_case1_is_indispensable` | the non-vacuity artifact (see below) |
| `negFixListFaithful_iff_of_attained` | the attained → faithful shim (INF half only) |

Plus one import edge + NOTE in `Kamp/NfMultiAnchorBridge.lean`.

## Key decisions / findings to carry forward

1. **The faithful version has one MORE disjunct than the attained one, and it is the paper's.**
   `firstNegPin_or_all` (`NegFix.lean:137`) is a two-way dichotomy; `HasDedekindINF.first_occ`
   preserves Rabinovich's printed disjunction, so the top-level split is three-way: Case 1
   `K⁺(¬β₁)(z₀)` (PDF p.9), Case 2 `β₁` everywhere (p.10), Case 3 the eq (5.3) pin (p.10).
   The plan's Verification bullet anticipated the third gate *nested inside* Cases 2 and 3; it
   actually lands as a **top-level Case 1**, plus the pin's own two-alternative point type
   `infPinPoint`. Reported as Deviation 1 in the plan, not smoothed over.
2. **`kplusLeftBlock` (`Lemma53Faithful.lean:189`) now has a third consumer.** Landed in Phase 1,
   used by `negChainOnFaithful` and `negFixOneCase1`, now by `negFixListFaithful`'s Case 1. It is
   the standard carrier for the limit gate; Phase 8 should expect to keep it, not re-derive it.
3. **Non-vacuity is machine-checked, not argued.** `negFixListFaithful_case1_is_indispensable`
   proves that under `K⁺(¬β₁)(z₀)` **both** other disjuncts are unsatisfiable — Case 2 needs `β₁`
   at every interior point, Case 3 needs a pin with `β₁` on all of `(z₀,r₀)`, and `K⁺(¬β₁)(z₀)`
   produces a `¬β₁`-point inside both windows. So deleting Case 1 makes `negFixListFaithful_iff`
   false wherever `K⁺` is satisfiable. Carrier-free. This is `prior_makes_disjunct2_unreachable`'s
   class of artifact, one step further: not *where* the limit case is unreachable, but *why it
   cannot be absorbed*.
4. **Honest limit on that content**: Case 1 is dead on Prior and on any attained-INF structure
   (`hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`), so it is contentful mathematics not yet
   observable from any live consumer — same standing as Lemma 5.3's disjunct (2) and the `K⁻`
   boundary disjunct.
5. **`Bᵢ⁺`'s spelling comes from Figure 1's CAPTION, not the inline definition.** p.10's inline
   `Bᵢ⁺ := [βᵢ, αᵢβ_{i+1}α_{i+1},…]` loses one `βᵢ` in typesetting; the caption prints
   `B₂ := [α₀,β₁,α₁,β₂,β₂](z₀,z) ∧ [β₂,β₂,α₂,β₃,α₃](z,z₁)`, i.e. `βᵢ` occurs twice — point type at
   `z`, segment type just above it. Cite the caption, do not re-derive this.
6. **p.11's clauses (d) and (e) are already absorbed.** They are the two boundary items of the `Bᵢ`
   range, and they correspond to the "seg-0" and "witness" constructors of `splitsAt` that the
   landed proof already handles. No separate treatment was needed or written.

## `HasDedekindSUP`: FOURTH consecutive drop

Confirmed, not re-litigated. Every gate in this phase is INF-side; Rabinovich's pp.10-11 induction
uses no `K⁻`, no supremum, no last-occurrence point. `HasDedekindSUP`,
`orderedPointsExist_combine_kminus` and `HasDedekindSUP.last_occ_tp` remain unconsumed by Phases
4, 5, 6 and 7. Phases 8-9 are lifts, so they are not plausible consumers either. Phase 2 retains
its independent value (`kminusFormula`/`kminus_formula_correct` were absent from the tree before
it, plus the right-end chain primitives and the SUP-side exclusion theorem). Report if it drops
again; do not contrive a use.

## Measured results (actual, not asserted)

| Gate | After Phase 6 | After Phase 7 |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1889 | **1890** (+1) |
| Live modules from `FormalSystem.lean` | 275 | **276** (+1) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** |
| Tactic-position sorries in the new module | — | **0** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |

Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. Liveness by
transitive `import` walk from `FormalSystem.lean`; `lake build BoneyardArchive` never run or cited.
All 18 new declarations verify as subsets of `[propext, Classical.choice, Quot.sound]` — no
`sorryAx`.

**The recurring axiom-count note, carry it forward.** Bare `grep -c '^axiom ' FormalSystem/`
returns **2**; both are prose continuation lines inside `Boneyard/` comments
(`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: **0**.

## Sizing

Closed in one agent run. Three-strikes guard did not fire; the 7a/7b/7c re-split boundaries were
never reached and the plan is not re-split.
