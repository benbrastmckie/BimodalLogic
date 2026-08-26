# Bimodal Known Limitations

Current limitations of the Bimodal TM logic MVP and available workarounds.

## MVP Scope

This is a **Minimum Viable Product** release with intentional scope limitations.

## Limitation 1: Strong Completeness (Infinite Premise Sets) Is Not Available Uniformly

### Description

The four weak completeness theorems are proved and sorryAx-free: `completeness`
(`FormalSystem/Metalogic/BXCanonical/Completeness.lean:196`), `completeness_dense` (`:255`),
`completeness_discrete` (`:296`), and `completeness_dedekind`
(`FormalSystem/Metalogic/StrongCompleteness.lean:469`). None of them carries an outstanding
proof obligation; check C2 of `scripts/check-module-invariants.sh` asserts their axiom sets are
exactly `[propext, Classical.choice, Quot.sound]`.

**The distinction that matters here is between consequence completeness and strong
completeness**, and the two must not be read as one. `Context` is `List Formula`
(`FormalSystem/Syntax/Context.lean`), so every `consequence_completeness_*` theorem in the tree
is a *finite*-context result, inter-derivable with the corresponding weak (single-formula) form
through the deduction theorem. As `StrongCompleteness.lean:25-41` puts it, calling a statement
that is inter-derivable with weak completeness "strong completeness" would misrepresent it. The
reserved name applies only to `Γ ⊨_X φ → Γ ⊢_X φ` with `Γ : Set Formula` and a finitary
set-derivability relation. For a finitary proof system that entails compactness of the class
consequence relation, so it is available exactly for the frame classes whose consequence
relation is compact.

The infinitary statement has **three distinct statuses** across the four frame classes, which
`FormalSystem/Metalogic.lean:83-101` warns explicitly must not be collapsed into one:

| Frame class | Status of strong completeness | Anchor |
|-------------|-------------------------------|--------|
| `FrameClass.Discrete` | **Machine-refuted** | `DiscreteNonCompactness.lean:250` `discrete_consequence_not_compact`, `:280` `strongCompletenessDiscrete_refuted` |
| `FrameClass.Base`, `FrameClass.Dense` | **Open** -- neither proved nor refuted | `SetConsequence.lean:219` `CompactBase`, `:263` `CompactDense`; `:211` `StrongCompletenessBase`, `:256` `StrongCompletenessDense` |
| `FrameClass.Dedekind` | **Unavailable on the primary source's own terms** -- unproved *and* unrefuted | `StrongCompleteness.lean:74-89` |

For Base and Dense, neither class's binder list imposes Archimedean-ness, so the standard
non-compactness counterexamples do not apply; whether the full task-frame consequence relation
is in fact compact is an open research question for this development. The set-based MCS layer
(`SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum` in
`FormalSystem/Metalogic/Core/MaximalConsistent.lean`) is already in place; the missing
substantive piece is a model-existence theorem, which does not follow from the single-formula
countermodel engines. `strongCompletenessBase_of_compact` and
`strongCompletenessDense_of_compact` reduce each case to its compactness hypothesis alone.

For Dedekind, Reynolds 1992 (Theorem 7, section 9) is *weak* completeness for the real-line
axiomatisation, and the restriction there is genuine rather than an artefact of presentation.
What the tree does **not** contain is a refutation: there is no `CompactDedekind` definition and
no theorem refuting compactness for this class. "The Dedekind consequence relation is not
compact" is therefore a claim resting on the source's own scope, not a machine-checked fact --
a weaker and more accurate claim than the one Discrete supports. Reading Dedekind's status as
sharing Discrete's would overstate the evidence.

### Impact

- All four weak completeness theorems, and their finite-context `consequence_completeness_*`
  companions, can be relied upon directly.
- No statement of the form "`Γ ⊨ φ` implies `Γ ⊢ φ` for an arbitrary infinite `Γ`" is available
  for any frame class. For Discrete it is false; for Base and Dense it is unsettled; for
  Dedekind it is out of the primary source's scope.

### Workaround

Work with finite premise sets, where the deduction theorem makes the finite-context results
fully general:

```lean
-- Consequence completeness at a finite Context is available for every class
#check @FormalSystem.Metalogic.consequence_completeness
```

### Resolution

Base and Dense are open research questions, tracked in the tree as the named obligations
`CompactBase` and `CompactDense`. Discrete is settled negatively and needs no further work.
Dedekind would require going beyond Reynolds's Theorem 7.

## Limitation 2: ProofSearch Has Build Issues (Resolved)

### Description

`Automation/ProofSearch.lean` no longer exists as a single file; it is now
`Automation/ProofSearch/Core.lean` and `Automation/ProofSearch/Strategies.lean`, both compiled by
the green full `lake build` (1877 jobs, 0 errors). The historical build failure described here no
longer reproduces.

### Impact

None currently observed. `boundedSearch` and related automation build cleanly as part of the
main build.

### Workaround

Not needed; the modules build without error.

### Resolution

Resolved by the reorganization into `Automation/ProofSearch/Core.lean` and
`Automation/ProofSearch/Strategies.lean`.

## Limitation 3: Example Files Have Pedagogical Sorries (Resolved)

### Description

`FormalSystem/Examples/` contains exactly two files, `BimodalProofs.lean` and
`TemporalStructures.lean`, both sorry-free (0 total, as of the current build).

### Impact

None currently observed. Both example files fully compile.

### Workaround

Not needed.

### Resolution

Resolved — both example files are sorry-free per the `Examples.lean` module docstring and the
current build.

## Limitation 4: Test Suite Has Pending Tests (Resolved)

### Description

`Metalogic/CompletenessTest.lean` does not exist anywhere in the tree.
`Tests/BimodalTest/Theorems/PerpetuityTest.lean` and `.../PropositionalTest.lean` contain zero
`sorry` uses.

### Impact

None currently observed. The tests that exist verify their expected behavior.

### Workaround

Not needed.

### Resolution

Resolved — no outstanding `sorry` placeholders found in `PerpetuityTest.lean` or
`PropositionalTest.lean`; `CompletenessTest.lean` no longer exists in the tree.

## Limitation 5: Modal S4 Theorems Partial (Resolved)

### Description

`Theorems/ModalS4.lean` is sorry-free; all four of its theorems, including
`s4DiamondBoxConj`, are fully proven.

### Impact

None currently observed. All Modal S4 theorems are available for use in downstream proofs.

### Workaround

Not needed.

### Resolution

Resolved — all Modal S4 theorems, including `s4DiamondBoxConj`, are fully proven and
sorry-free.

## Limitation 6: The Decision Procedure's Completeness Direction Is Open

### Description

A decision procedure **does** exist: the `FormalSystem/Metalogic/Decidability/` subtree
implements tableau-based validity checking with entry points `decide`, `decideBlocking`,
`decideAuto`, and `decideAutoAdaptive`.

What is proved is the **sound direction only**. From
`FormalSystem/Metalogic/Decidability/Correctness.lean`:

| Theorem | Line | Statement |
|---------|------|-----------|
| `sound_of_isValid` | 100 | `r.isValid = true` gives `⊨ φ`, for any `DecisionResult φ` |
| `isValid_sound` | 111 | `isValid φ fc = true` gives `⊨ φ` |
| `isTautology_sound` | 124 | `isTautology φ fc = true` gives `⊨ φ` |
| `isContradiction_sound` | 131 | `isContradiction φ fc = true` gives `⊨ φ.neg` |
| `not_isSatisfiable_sound` | 142 | `isSatisfiable φ fc = false` gives `⊨ φ.neg` |

The conclusion is the *unrelativized* `⊨ φ`, forced by the types rather than chosen:
`DecisionResult.valid` carries `⊢ φ` = `DerivationTree FrameClass.Base [] φ` regardless of which
`fc` was passed in, so a `true` from any frame class yields validity over all task frames. The
frame-class-relative corollaries are weakenings obtained via the `Validity.valid_implies_*`
monotonicity lemmas.

The **completeness direction** -- `models φ → isValid φ fc = true`, that a valid formula is
always reported valid -- is open.

### The `extractionFailed` caveat

`isKnownValid` is **not** a substitute hypothesis for `isValid`. Quoting
`Correctness.lean:95-99` directly:

> `DecisionResult.isKnownValid` is also `true` on `extractionFailed`, which carries no `⊢ φ`
> witness; getting `⊨ φ` from a closed tableau with no extracted proof is the open
> `valid_iff_allClosed` obligation described in the retirement section below, not a consequence
> of anything proved in this file.

A `true` from `isKnownValid` therefore does not license concluding `⊨ φ`. Use `isValid`.

### Impact

- A `true` result from `isValid` (or `isTautology`) is trustworthy: the formula is valid.
- A non-`true` result is **not** evidence of invalidity. It may be `fuelExhausted` or
  `extractionFailed`, neither of which carries information about `φ`.

### Workaround

Read the procedure as a semi-decision procedure for validity: treat `isValid φ fc = true` as
proof, and treat anything else as "no answer" rather than as a negative answer. Where a negative
answer is needed, construct a countermodel.

### Resolution

The completeness direction turns on the open `valid_iff_allClosed` obligation described in
`Correctness.lean`'s retirement section.

## Limitation 7: The Discrete Consequence Relation Is Not Compact

### Description

This is a genuine negative result, machine-checked rather than informal, in
`FormalSystem/Metalogic/DiscreteNonCompactness.lean`. The witness set is

```
archWitness p  =  {F p} ∪ {¬Xⁿ p : n ∈ ℕ}
```

(`archWitness`, `:102`). `ValidDiscrete` requires `IsSuccArchimedean`/`IsPredArchimedean`, and
`Formula.next φ = Formula.untl Formula.bot φ` is a genuine next-step operator on discrete
orders, so the set is finitely satisfiable over `ℤ` -- place `p` far enough out
(`archWitness_finitely_satisfiable`, `:194`) -- yet unsatisfiable over every Archimedean
discrete carrier, since the `F p` witness would have to lie at some finite successor distance
(`archWitness_not_satisfiable`, `:229`).

The two conclusions are `discrete_consequence_not_compact` (`:250`), refuting `CompactDiscrete`,
and `strongCompletenessDiscrete_refuted` (`:280`), refuting `StrongCompletenessDiscrete`. All
are sorry-free at exactly `[propext, Classical.choice, Quot.sound]`.

### Impact

- Strong completeness for `FrameClass.Discrete` is **false**, not merely unproved. No amount of
  further work will supply it.
- Only weak completeness (`completeness_discrete`) and its finite-context consequence corollary
  are available for this class. See Limitation 1.

### Workaround

None is needed or possible: this is a fact about the logic, not a gap in the formalization. Work
with finite premise sets over Discrete frames.

### Resolution

Settled. This limitation is permanent and is recorded here so that the absence of a Discrete
strong-completeness theorem is not misread as outstanding work.

## Limitation 8: TM/TM⁺ Conservativity Holds Backward Only

### Description

The bridge between TM (stated over the tense-primitive base language,
`FormalSystem/BaseLanguage/`) and TM⁺ (this repository's until/since-primitive system) is
proved in the **backward** direction only:

```
TM ⊢ φ   ⟹   TM⁺ ⊢ tr φ
```

`FormalSystem/Metalogic/Conservativity.lean` proves this by structural recursion over TM
derivations, parameterized by frame class so that the paper's four rows are four instantiations
of one theorem: `translate` (`:170`), `derivable_translate` (`:194`), and the four row
corollaries `ceb_backward` (`:210`), `cef_backward` (`:222`), `ced_backward` (`:232`),
`cec_backward` (`:253`). All are sorry-free.

**The forward direction is refuted, not open.** `TM⁺ ⊢ tr φ ⟹ TM ⊢ φ` is refuted for the Base
and Discrete rows and open for the other two. The module docstring is the standing record of
why it must not be attempted or `sorry`-ed; see also the "Conservativity (proof-theoretic, no
semantics)" section of `FormalSystem/Metalogic.lean`.

### Impact

- A TM theorem transfers to TM⁺ automatically. A TM⁺ theorem does **not** transfer back.
- Results proved in the until/since-primitive language cannot be assumed to be statable, let
  alone provable, in the tense-primitive one.
- The base language now has a **semantics and a soundness theorem of its own**, so BL results
  no longer have to be routed through `tr` to be given meaning:
  `FormalSystem/Semantics/BLTruth.lean` defines `BLTruthAt` natively on `BLFormula`,
  `FormalSystem/Semantics/BLValidity.lean` carries the four BL validity predicates, and
  `FormalSystem/Metalogic/BaseLanguageSoundness.lean` proves BL soundness at `FrameClass.Base`
  and its three extensions. **This does not change the limitation**: it is a fact about the
  proof systems, and the forward direction stays refuted.

### Workaround

State results in the base language where backward transfer is needed, and use `tr` to move
them across.

### Resolution

Settled negatively for two rows; the remaining two are open. This is not outstanding work on
the two refuted rows.

What a *machine-checked* refutation of the two settled rows would need has narrowed from three
items to one. `Metalogic/Conservativity.lean` used to record that a BL-side semantics, a BL-side
soundness theorem, and two countermodels were all missing. The first two now exist (see the
Impact section above); the countermodels — the two-fibre structure for the Base row and
`ℤ ×_lex ℤ` for the Discrete row — do not, and building them is separate work against the
non-Archimedean discrete carrier.

## Limitation 9: `CO` Does Not Derive Reynolds's Prior-U

### Description

An independence result, established by exhibiting a model rather than by failing to find a
proof. Over the dense base, the paper's `CO` principle (`Formula.co`,
`△(Hφ → F(Hφ)) → (Hφ → Gφ)`) does **not** derive `Axiom.prior_U_gap`.

The witness is the periodic clock frame (`FormalSystem/Metalogic/Independence/ClockFrame.lean`)
-- temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation
the deterministic translation flow -- carrying the symmetric irrational arc valuation
(`Independence/CoNotPriorU.lean`). `Independence/LoopingDuration.lean` isolates the reusable
content: any frame carrying a *looping duration* has periodic histories, hence periodic truth,
hence validates every instance of `CO`.

The converse direction is a **positive** result: Reynolds's triple *does* derive `CO`, as
`FormalSystem.Theorems.DedekindDerived.co_derived`. The two together settle the relationship in
both directions.

### Impact

- `CO` is strictly weaker than Reynolds's Prior-U over the dense base. A development that
  assumes only `CO` cannot recover the Dedekind layer.

### Workaround

Assume the Dedekind axioms (`prior_U_gap`, `prior_S_gap`, `sep`) where the strength is needed;
`CO` alone does not suffice.

### Resolution

Settled. Recorded here so that the absence of a `CO`-based derivation is not misread as
outstanding work.

## Summary Table

| Limitation | Severity | Workaround | Status |
|------------|----------|------------|--------|
| Strong completeness not uniformly available | Medium | Use finite premise sets | Base/Dense open; Discrete refuted; Dedekind out of source scope |
| ProofSearch issues | Low | Use specific tactics | Resolved |
| Example sorries | Low | Use as exercises | Resolved |
| Test sorries | Low | Signature tests work | Resolved |
| Modal S4 partial | Low | Manual derivation | Resolved |
| Decision procedure completeness direction | Medium | Treat as semi-decision procedure | Open (`valid_iff_allClosed`) |
| Discrete consequence relation not compact | Medium | None; work with finite premise sets | Settled negatively |
| TM/TM⁺ conservativity backward only | Low | State results in the base language | Two rows refuted, two open |
| `CO` does not derive Prior-U | Low | Assume the Dedekind axioms directly | Settled negatively |

## What Works Well

Despite limitations, the following are fully functional:

- ✅ All 45 axiom constructors (Base 37 / Dense 2 / Discrete 3 / Dedekind 3)
- ✅ All 7 inference rules
- ✅ Full soundness proof
- ✅ Task frame semantics
- ✅ Core tactics (`modal_t`, `apply_axiom`)
- ✅ Perpetuity principles P1-P6 (fully proven; not yet registered as Aesop safe rules — see
  `tactic-registry.md`)
- ✅ Modal S5 theorem
- ✅ Weak completeness for all four frame classes, sorryAx-free
- ✅ Sound direction of the tableau decision procedure
- ✅ Propositional theorem library

## Reporting Issues

If you encounter issues not listed here:

1. Check [Project Issues](https://github.com/benbrastmckie/BimodalLogic/issues)
2. Verify against latest `main` branch
3. Report with minimal reproducing example

## See Also

- [Implementation Status](implementation-status.md) - Detailed module status
- [API Reference](../reference/API_REFERENCE.md) - Declaration-level reference
