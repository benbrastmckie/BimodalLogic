# `Decidability/Verified/`

The correctness theory of the tableau decision procedure, kept **beside** the executable engine
rather than inside it.

The engine in `Decidability/` (`SignedFormula.lean`, `Tableau.lean`, `Closure.lean`,
`Saturation.lean`, `DecisionProcedure.lean`, ...) is a running program with a stable public API
(`decide`, `buildTableau`, `isValid`). This subtree proves things *about* it. The separation is
deliberate: the engine's `#eval` suite and its runtime fuel defaults stay free of proof
obligations, and the proofs stay free of the engine's performance knobs.

## Layout

Two status values, both mechanically checkable, and neither asserting schedule or intent:

- **`landed`** — the path exists (`test -f`) *and* is imported by the
  `FormalSystem/Metalogic/Decidability.lean` aggregator (a grep of its import block; check C4 of
  `scripts/check-module-invariants.sh` keeps that import resolvable).
- **`not built`** — no such path exists (`test -e`).

All 21 live `.lean` files in this subtree are `landed`; every one is imported by the aggregator.
The Contents column is lifted from that aggregator's own module docstring so the two cannot drift
apart.

### Landed

| Path | Contents | Status |
|------|----------|--------|
| `RuleSpec.lean` | rule/axiom frame-class gate lemmas: `ruleFrameClass`, `ruleAxioms`, and the three GATE theorems tying the rule lattice to the axiom lattice | landed |
| `Termination/SubformulaProperty.lean` | T1, the signed subformula property (per rule): `RuleResult.emitted`, the `TableauClosed` closure census, the `as*?` inversions, all 36 rule cases, and the assembled `applyRule_subformula_closed` | landed |
| `Termination/TimeTypeBound.lean` | T2, the `2 ^ (2 * \|C\|)` time-type bound and pigeonhole | landed |
| `Termination/Fuel.lean` | T3, the set-growth progress measure and the uncapped fuel figure `soundFuel'`, with `soundFuel_le_soundFuel'`, `chain_le_stock`, `chain_le_soundFuel'`, `chain_le_worlds_bounded`, and the totality theorems `expandBranchWithFuel_isSome_of_noSplit` and `expandBranchWithFuel_isSome_of_stock` | landed |
| `Termination/MintBound.lean` | an independent ceiling on fresh-time minting, lifting T3's no-branching scope: the `IrreflOrd` run invariant, reachability transport and witness preservation across `TimeOrdering.identifyTime`, the mint potential, and the amortized counting chain | landed |
| `Bridge/BranchOrder.lean` | the finite linear order a gated saturated branch carries | landed |
| `Bridge/Embed.lean` | monotone placement of a finite order in a dense carrier or in `ℤ` | landed |
| `Bridge/Carrier.lean` | `TemporalCarrier fc D`, the per-frame-class carrier interface | landed |
| `Bridge/Interpolate.lean` | the region structure a placement cuts in the carrier, the total-on-`D` extension operator, and the invariance induction's propositional and modal cases | landed |
| `Bridge/RegionFrame.lean` | the countermodel's `TaskFrame`, its region histories, the fact that those are exactly the frame's total histories — which is what `valid` quantifies over — and `truthAt_box_iff`: `□` is the universal modality, with no closure hypothesis needed | landed |
| `Bridge/TruthLemma.lean` | `InterpInvariantAt`, region invariance at a single history — the form this carrier admits — and its instantiation at the countermodel's base histories | landed |
| `Bridge/Valuation.lean` | the countermodel's `TaskModel` — the branch's atoms at placed region codes, a parameter at gap codes — with the placed-point readback the truth lemma's atom case consumes, and the two theorems refuting the endpoint-copy gap policies | landed |
| `Bridge/BoxSaturation.lean` | `sat_box_temporal`, `sat_all_future_pos`, `sat_all_past_pos` and their composition `sat_box_cross`, plus `BoxAnchored`/`boxAnchoredCheck` and `sat_box_grid_of_check` | landed |
| `Bridge/PropSaturation.lean` | `sat_imp_pos`, the one member of the `sat_*` family `CountermodelExtraction.lean` does not carry, because `impPos` is the only *branching* propositional rule | landed |
| `Bridge/TemporalSaturation.lean` | `sat_untl_pos_future` and `sat_snce_pos_past` — the positive temporal witnesses with the one fact `sat_untl_pos`/`sat_snce_pos` discard, namely that the witness lies strictly after (resp. before) the formula's own time; also `orderDual_converse` | landed |
| `Bridge/RegionLabel.lean` | the gap arm of the atom clause: a region takes the atoms of a *chosen known label*, certified by the decidable gate `regionLabelCheck` | landed |
| `Bridge/TemporalGate.lean` | `temporalWitnessCheck`, a fourth decidable branch gate, carrying the four demands the `untl`/`snce` cases make and the region gate does not | landed |
| `Bridge/IntGaps.lean` | the `ℤ` placement is contiguous, so a non-placed integer lies on one of the two rays and there is no interior gap | landed |
| `Bridge/IntTruth.lean` | the signed truth correspondence and its six-case induction, run at `ℤ`; the `atom`, `bot`, `imp` and `box` cases are proved for an arbitrary carrier and an arbitrary injective placement | landed |
| `Bridge/DenseTruth.lean` | the same correspondence at a dense carrier; `branchTruthAt_of_temporal` is the machine-checked statement of what the two milestones share | landed |
| `Decidable.lean` | the *other* direction — `allClosed → valid`. `SatState`, `SatResult`, `RuleSound`, the 34 `ruleSound_*` instances, and their assembly `ruleSound_of_mem_allRulesForFC` | landed |

### Not built

These paths record a designed-but-unbuilt route. None of them exists; each is listed so the route
stays visible and so nobody mistakes an absent path for a landed one.

| Path | Contents it was to carry | Status |
|------|--------------------------|--------|
| `Internalize.lean` | `Branch.internalize`, label-to-modality encoding | not built |
| `Refutation/Core.lean` | the generic `allClosed → Derivable` induction, parameterized by the rule spec | not built |
| `Refutation/Rules/*.lean` | one admissibility lemma per rule, grouped by rule family | not built |
| `Bridge/Omega.lean` | history construction and shift-closure; this content is covered by `Bridge/RegionFrame.lean`, whose region histories are exactly the frame's total histories | not built |
| `Provable.lean` | Track B: `Decidable (Derivable fc [] φ)` and the completeness corollaries | not built |

Note what `Decidable.lean`'s `landed` marker does and does not say. The file exists and is
imported; what it *proves* is the rule half of `allClosed → valid`
(`ruleSound_of_mem_allRulesForFC`, all 34 rules, sorry-free). The `Decidable (⊨ φ)` instances for
the four frame classes are **not** proved there — see `Decidability/Correctness.lean`'s section
"`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous" for what is still
owed. `landed` is a claim about the path, never about the contents of a theorem name.

## The organising idea: base plus extensions, not four copies

TM's proof system and semantics already vary over `FrameClass` by parameter: `DerivationTree`
threads `fc` as a single index with the side condition `ax.minFrameClass ≤ fc`, and the five
validity predicates differ only in the binders on the carrier `D`. The decidability layer should
vary the same way. Concretely that means two commitments:

1. **One theorem, four instantiations.** The refutation induction and the truth lemma are each
   proved once — the first over `allRulesForFC fc` for an arbitrary `fc`, the second against an
   abstract carrier — and the Dense/Discrete/Dedekind results are instantiations, not re-proofs.
   Wholesale per-class delegation files are the named anti-pattern here.
2. **The lattices cannot drift apart.** `RuleSpec.lean` makes the correspondence between "which
   rules run at `fc`" and "which axioms are admissible at `fc`" a machine-checked fact.

The second is what `RuleSpec.lean` exists for, and it is worth stating plainly what it buys.

## `RuleSpec.lean`, and what its gates catch

Every `TableauRule` constructor declares a frame class (`ruleFrameClass`) and a set of grounding
axioms (`ruleAxioms`). Both are exhaustive matches with no wildcard arm, so a new constructor
does not compile until someone declares both. Three theorems then hold `by decide` over the
finite product of 36 rules and 4 frame classes:

- **GATE 1** `ruleAxioms_minFrameClass_le` — no rule is available at a frame class that cannot
  admit its own justifying axioms.
- **GATE 2** `mem_allRulesForFC_iff` — the engine's hand-maintained rule lists agree with
  `ruleFrameClass`, modulo an explicit exclusion clause for the two rules that are *scheduled*
  rather than prioritised (see below).
- **GATE 3** `ruleAxioms_covers_ruleFrameClass` — the converse of GATE 1: a rule gated above
  `.Base` must name an axiom at exactly its own frame class, so the rule lattice cannot grow past
  the axiom lattice.

Each gate is independently load-bearing. Deliberately mis-gating a rule was measured against all
three: moving `densityRule` from `.Dense` to `.Base` breaks GATE 1 and GATE 2; moving `priorUGap`
from `.Dedekind` to `.Discrete` breaks all three; grounding a `.Base` rule in `Axiom.prior_U_gap`
breaks GATE 1 alone; emptying `ruleAxioms .sepRule` breaks GATE 3 alone; and deleting the
`serialityRule` exclusion clause breaks GATE 2 alone.

### Reading `ruleAxioms`

`ruleAxioms r` is the *grounding set* for `r` — the axioms whose content the rule internalizes,
and the material from which the eventual per-rule admissibility lemma will be built. It is a
declaration checked here for frame-class consistency. It is **not** a proof that `r` is
admissible, and it is not claimed to be minimal or unique.

Several base rules therefore carry the empty list, and that is a positive statement rather than a
gap: the eight `G`/`H`/`F`/`P` decomposition rules implement the semantic truth condition of a
temporal quantifier, which is a rule of the system and not the image of any axiom, and the two
negative Until/Since rules perform a Reynolds co-decomposition that likewise has no single axiom
behind it. GATE 3 is what makes an empty entry safe: it is licit at `.Base` and can never be
anything else.

### The two rules outside `allRulesForFC`

`serialityRule` and `timeLinearity` are `.Base` rules — `serial_future`/`serial_past` and
`temp_linearity` are base axioms — but neither appears in `allRulesForFC`, and neither should be
added to it. Each is keyed on something other than a formula's shape (`serialityRule` on the
label, `timeLinearity` on the branch's time structure), so each applies to every signed formula
on the branch and no position in a per-formula priority list is the right one. They are scheduled
instead as the second and third stages of `expandOnce`.

That is why GATE 2 carries an exclusion clause rather than the plain equivalence
`r ∈ allRulesForFC fc ↔ ruleFrameClass r ≤ fc`. Both rules satisfy the right-hand side at every
frame class while satisfying the left at none.

One consequence is recorded as a corollary, `serialityRule_not_mem_allRulesForFC`, because
downstream code depends on it: `findUnexpanded` scans `allRulesForFC`, so a branch can report as
saturated while still owed `T(F ⊤)` and `T(P ⊤)` at each of its labels. Those are true at every
point of a serial frame, so the extracted model is unaffected — but the truth lemma must state
that `findUnexpanded = none` means "no **ordinary** rule applies", rather than quietly assuming
more.

## Related Documentation

- [Decidability README](../README.md) - the engine this subtree proves things about
- [Metalogic README](../../README.md) - overall metalogic architecture
- [FMP README](../FMP/README.md) - the finite model property route
- [Propositional README](../Propositional/README.md) - Kalmár-style propositional decision procedure

---

*Last verified: 2026-08-24*
