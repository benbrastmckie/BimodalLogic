# `Decidability/Verified/`

The correctness theory of the tableau decision procedure, kept **beside** the executable engine
rather than inside it.

The engine in `Decidability/` (`SignedFormula.lean`, `Tableau.lean`, `Closure.lean`,
`Saturation.lean`, `DecisionProcedure.lean`, ...) is a running program with a stable public API
(`decide`, `buildTableau`, `isValid`). This subtree proves things *about* it. The separation is
deliberate: the engine's `#eval` suite and its runtime fuel defaults stay free of proof
obligations, and the proofs stay free of the engine's performance knobs.

## Layout

| Path | Contents | Status |
|------|----------|--------|
| `RuleSpec.lean` | `ruleFrameClass`, `ruleAxioms`, and the three GATE theorems tying the rule lattice to the axiom lattice | present |
| `Internalize.lean` | `Branch.internalize`, label-to-modality encoding | planned |
| `Refutation/Core.lean` | the generic `allClosed → Derivable` induction, parameterized by the rule spec | planned |
| `Refutation/Rules/*.lean` | one admissibility lemma per rule, grouped by rule family | planned |
| `Termination/SubformulaProperty.lean` | T1, the generalized signed subformula property (one theorem per rule): `RuleResult.emitted`, the `TableauClosed` closure census, the `as*?` inversions, all 36 rule cases, and the assembled `applyRule_subformula_closed` | complete |
| `Termination/TimeTypeBound.lean` | T2, the pigeonhole bound on time-types | planned |
| `Termination/Fuel.lean` | T3, uncapped `soundFuel'` and `buildTableau_isSome` | planned |
| `Bridge/Carrier.lean` | `class TemporalCarrier`, the four carrier instances (Base/Dense to Q, Discrete to Z, Dedekind to R) | planned |
| `Bridge/BranchOrder.lean` | the finite total order extracted from a saturated branch | planned |
| `Bridge/Embed.lean` | embedding that order into the carrier | planned |
| `Bridge/Interpolate.lean` | the constant-on-half-open-intervals model and its invariance lemma | planned |
| `Bridge/Omega.lean` | history construction and shift-closure | planned |
| `Bridge/TruthLemma.lean` | `not_valid_of_hasOpen`, proved once, generic in the carrier | planned |
| `Decidable.lean` | Track A: `Decidable (⊨ φ)` plus the three frame-class variants | planned |
| `Provable.lean` | Track B: `Decidable (Derivable fc [] φ)` and the completeness corollaries | deferred |

Rows marked *planned* are scheduled work, not aspiration; rows marked *deferred* belong to
follow-up tasks. Nothing in this table is a placeholder file — a path exists here only once its
contents do.

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
