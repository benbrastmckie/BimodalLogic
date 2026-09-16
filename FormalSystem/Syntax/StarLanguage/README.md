# StarLanguage — the language L⋆ (L⁺ plus the time store/recall operators)

This directory defines a **fourth object language** for the tree, **L⋆**, obtained from L⁺
(`FormalSystem/PlusLanguage/`) by adding the manuscript's two hybrid **time registers**:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | ↑ⁱφ | ↓ⁱφ
```

`↑ⁱ` (`timeStore i`) writes the present time into register `i`; `↓ⁱ` (`timeRecall i`) moves the
point of evaluation to the time register `i` holds. This is the manuscript's `\BL^\star` in the
presentation `def:BLstar-semantics` gives it for the deterministic-frame appendix: points are
`(τ, x, v⃗)` with `v⃗` a vector of stored **times**, and the world registers `↑_M`/`↓_M` are
suppressed.

L⋆ is a **separate inductive** (`StarFormula`) with a constructor-to-constructor embedding
`ofPlus : PlusFormula → StarFormula`, following the landed `MinusLanguage/` and `PlusLanguage/`
pattern. Every derived operator has `PlusFormula`'s right-hand side verbatim, so the embedding
commutes with each of them by `rfl`.

## Why the operators are not added to `PlusFormula`

The atomization route to TM⁺ soundness
(`Metalogic/Conservativity/Plus/Atomization.lean`) rests on `stab_state_only`
(`Semantics/PlusTruth.lean`): `⊡φ`'s truth depends on the world state **alone**, at any time.
That invariant is **false inside a recall scope** — `⊡↓ⁱφ` reaches back to a time the register
names, which the present world state does not determine — so adding `timeStore`/`timeRecall` to
`PlusFormula` would silently invalidate a landed conservativity result. Breaking the invariant is
the whole point of this language, and it must be broken in a *separate* type.

## Modules

| File | Description |
|------|-------------|
| `Formula.lean` | `StarFormula`, the derived operators (with `PlusFormula`'s right-hand sides), the `⊡`-specific `dstab`/`Will`/`will`/`Could`/`could`, `swapTemporal` (`stab ↦ stab`, and both registers structural) with `swap_temporal_involution` and the `swap_temporal_*` push-through family, and the embedding `ofPlus`/`ofStarCtx` with `ofPlus_injective`, `ofPlus_ne_timeStore`, `ofPlus_ne_timeRecall`, `ofPlus_swapTemporal` and the `rfl` commutation pins |
| `Axioms.lean` | `StarAxiom` — TM⋆'s axiom set: the 53 TM⁺ schemata re-declared directly over `StarFormula` (`modal_future` alone under a `RecallFree` side condition), plus the sixteen register schemata of the store/recall block; `StarAxiom.minFrameClass` |
| `Derivation.lean` | `StarDerivationTree` (the seven TM⁺ rules, verbatim), the notation `⊢⋆[fc]`, `StarDerivable` with `StarDerivable.mono`, the structural apparatus `lift`/`height`/`ofWeakeningNil`, and the derived, **unrestricted** `stabNecessitation` |
| `Embedding.lean` | `StarAxiom.ofPlusAxiom` and `StarAxiom.minFrameClass_ofPlusAxiom`, `StarDerivationTree.ofPlusTree`, `starDerivable_of_plusDerivable`, `starDerivable_of_derivable` — every TM⁺ theorem is a TM⋆ theorem at its embedded formula |

The sibling aggregator is `FormalSystem/StarLanguage.lean`.

## The proof system TM⋆: `StarAxiom` is declared

`StarAxiom` (`Axioms.lean`) is TM⋆'s axiom set. The manuscript supplies no proof system for
`\BL^\star` — every result this component was originally built for is semantic — so TM⋆ is a
formalization-native system, built to the shape of `PlusAxiom`/`PlusDerivationTree` so that the
two are structurally comparable and the L⁺ ⊂ L⋆ questions can be *stated*.

The one structural decision worth naming here is that `StarAxiom` **re-declares** the TM⁺
schemata over `StarFormula` rather than embedding them, exactly as `PlusAxiom` re-declares the 45
TM schemata over `PlusFormula`. Fifty-two of the 53 are valid at arbitrary `StarFormula`
metavariables, each proved individually; `paste` and `untl_paste` carry L⋆ counterparts of the
purity conditions their `PlusAxiom` mirrors already carry.

`modal_future` (`□φ → □Gφ`) is the sole exception: it is *refuted* over `StarFormula`
(`refute_modal_future`, `Semantics/StarNonValidities.lean`). MF is the only schema in the TM
block whose soundness proof consumes time-shift homogeneity — audited, and recorded in the
`Metalogic/Soundness.lean` module docstring's *The time-shift consumer set* section, which is the
authority: one schema, two declarations (`modal_future_valid` and `mf_swap_valid`, the latter
carrying TF, which is not a separate `Axiom` constructor) — and the L⋆ time-shift lemma shifts
the stored-time vector with the history, which a `↓ⁱ` can observe. It is therefore carried alone
under a `RecallFree` (`↓ⁱ`-free) side condition. That fragment is **strictly wider** than the
embedded one: `□↑¹p → □G↑¹p` is an instance, and `↑¹p` is not an `ofPlus` image
(`ofPlus_ne_timeStore`). The embedding survives as the derived function `StarAxiom.ofPlusAxiom`
(`Embedding.lean`), which adds nothing to TM⋆.

**No L⋆ atomization, ever.** The TM⁺ soundness arms go through
`Metalogic/Conservativity/Plus/Atomization.lean`, which rests on `stab_state_only` — the
invariant `StarFormula` is built to break, since neither `↓ⁱχ` nor `↑ⁱχ` is state-determined.
There is no L⋆ analogue and there cannot be one. Facing 53 schematic arms this is the shortcut a
future contributor is most likely to reach for; every arm is a fresh direct proof against
`StarTruthAt` instead, and uniform substitution is unavailable too (TM⁺ is not
substitution-closed, via `atom_stab`).

`StarDerivationTree`, the notation `⊢⋆[fc]` and the name TM⋆ for the resulting system are
declared in `Derivation.lean`: the same seven inference rules as TM⁺ and TM, constructor for
constructor, with `StarAxiom` in the `axiom` rule.

**`⊡`-necessitation reaches every formula.** In TM⁺, `⊢ φ ⟹ ⊢ ⊡φ` is derivable at every formula
via `necessitation` and MS (`□φ → ⊡φ`); the same now holds in TM⋆ at every `ψ : StarFormula`,
registers included (`stabNecessitation`, `Derivation.lean`). Under the earlier embedding-only
design the derived rule reached embedded formulas only, because MS arrived only at `ofPlus`
instances. The rule was *sound* at every formula throughout — the `stab` clause merely restricts
the `box` clause's quantifier — so that restriction was an artefact of axiom packaging rather
than of the logic, and declaring `box_stab` natively removed it.

## Where the L⋆ semantics lives

Nothing in this directory defines truth, validity, or a frame. The semantics sits on the far side
of the permitted import edge:

| File | What it carries |
|------|-----------------|
| `FormalSystem/Semantics/StarTruth.lean` | `StarTruthAt` over `(τ, x, v⃗)`; the `StarTruth.*` clause lemmas; `starTruthAt_ofPlus`; the transport layer `star_truth_congr_ext`, `update_shift_comm`, `starTruthAt_timeShift` |
| `FormalSystem/Semantics/StarValidity.lean` | `TaskFrame.StarValidOn`, `StarValidOnFrames`, `StarValidIn`, `StarValid`; `starValidOn_ofPlus`; `settledDisj`, `sentDet`, `sentDet_unfold`, `not_starValidOn_sentDet` |
| `FormalSystem/Semantics/StarDeterminism.lean` | `star_congr_of_deterministic`, `sentDet_of_deterministic`, `detPM`, `detPM_unfold`, `detPM_of_deterministic`, `deterministic_of_detPM`, `deterministic_starDefinable` |
| `FormalSystem/Semantics/StarNonValidities.lean` | `refute_sentDet`, `not_starValid_sentDet`; `mfWitness` and `refute_modal_future` (MF is not an L⋆ schema); `storeG_recall_valid` with `refute_erasure` (register erasure is not a conservativity translation) |
| `FormalSystem/Metalogic/Conservativity/Star/` | TM⋆'s metatheory: `starAxiom_validIn_min`, `starAxiom_swap_validIn_min`, `star_soundness_validIn`, `starDerivable_ofFormula_iff`, `starConservative_of_plusComplete`, `plusIncomplete_of_starNonconservative` |
| `FormalSystem/Semantics/StarStateLocal.lean` | `StarFormula.StateLocal` (syntactic) and `IsStateLocal` (semantic); `isStateLocal_box`, `isStateLocal_stab`, `isStateLocal_of_stateLocal`; `not_isStateLocal_someFuture`, `not_isStateLocal_somePast`, `not_isStateLocal_timeRecall`; `stateLocal_stab_iff`, `stateLocal_starValid_iff_stab` |
| `FormalSystem/Metalogic/Independence/StarDiscrimination.lean` | `driftLinear`, `fzero_refutes_sentDet`, `f1_sentDet`, `sentDet_discriminates`, `star_discriminates_where_plus_cannot` |
| `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` | `fnRel`, `FN`, `fn_forwardDeterministic`, `fn_not_deterministic`, `states_eq_of_forwardDeterministic`, `fn_sentDet_stateLocal`, `fn_separates`, `fn_refutes_sentDet_somePast`, `fn_sentDet_bounds` |

## Paper-label correspondence

Every manuscript `\label` this component touches, mapped to a Lean declaration or to an explicit
exclusion. Anchors are cited by `\label` only, never by line number.

| Paper anchor | Claim | Lean |
|---|---|---|
| `def:BLstar-semantics` (store/recall clauses) | `M,τ,x,v⃗ ⊨ ↑ⁱφ` iff `M,τ,x,v⃗[x/vᵢ] ⊨ φ`; `M,τ,x,v⃗ ⊨ ↓ⁱφ` iff `M,τ,vᵢ,v⃗ ⊨ φ` | `Semantics/StarTruth.lean` — the `timeStore`/`timeRecall` clauses of `StarTruthAt`, with `StarTruth.timeStore_iff` / `StarTruth.timeRecall_iff` |
| `def:BLstar-semantics` (world registers `↑_M`, `↓_M`) | — | **Excluded**: world registers are suppressed on the main path, exactly as the deterministic-frame appendix suppresses them. A single-world-register `Det-m` was declared optional at plan time and is not built |
| `lem:deterministic-singleton` (⇒) | Deterministic ⟹ `⟨τ⟩_x = {τ}` | `states_eq_of_deterministic` (`Semantics/PlusDeterminism.lean`), restated at the predicate as `singletonClasses_of_deterministic` (`Semantics/DeterministicBridge.lean`); choice-free |
| `lem:deterministic-singleton` (⇐) | `⟨τ⟩_x = {τ}` ⟹ Deterministic | `deterministic_of_singletonClasses` (`Semantics/DeterministicBridge.lean`); a theorem of **ZFC**, via `thm:extension` |
| `lem:deterministic-singleton` (biconditional) | the two together | `deterministic_iff_singletonClasses` |
| `sent:det` | `↑¹\Future↑²↓¹(⊡↓²¬φ ∨ ⊡↓²φ)` | `sentDet` (`Semantics/StarValidity.lean`); `\Future` is the manuscript's **universal** future, so the tree's `allFuture` |
| `app:deterministic-future` (`(∗)` chain) | the four-line unfolding | `sentDet_unfold` |
| `app:deterministic-future` (positive half) | `sent:det` valid over every deterministic frame | `sentDet_of_deterministic` (`Semantics/StarDeterminism.lean`) |
| `app:deterministic-future` (negative half) | `sent:det` invalid over some non-deterministic frame | `refute_sentDet` (`Semantics/StarNonValidities.lean`), over `NF` — the manuscript's own reused countermodel |
| footnote after `app:deterministic-future` | store/recall discriminate `F°` from `F¹` | `fzero_refutes_sentDet`, `f1_sentDet`, `sentDet_discriminates`, `star_discriminates_where_plus_cannot` (`Metalogic/Independence/StarDiscrimination.lean`) |
| `app:drift` | `F°` is a non-deterministic frame validating *Determined* | already landed: `Metalogic/Independence/DriftFrame.lean`, `DeterminismUndefinable.lean` |
| `cor:no-characterization` | no store/recall-free sentence set characterizes the deterministic frames | already landed: `deterministic_not_plusDefinable` (`Metalogic/Independence/DeterminismUndefinable.lean`) |
| `cor:saturation-finite` (finite-**fibres** variant) | *Saturation* from finite fibres | `TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean`) — not a paper result; the paper's corollary is the finite-**carrier** one, which does not reach `FN` |
| Theorem C, `Det-pm` half (report-level) | `Det-pm` defines the deterministic frames, as a three-way equivalence: `Det-pm`'s validity at bare sentence letters already **forces** determinism, and determinism **delivers** `Det-pm` at every `StarFormula` | `detPM` (schematic), `deterministic_starDefinable` (`Semantics/StarDeterminism.lean`) |
| Theorem C, `Det-m` half (report-level) | `Det-m` defines the deterministic frames | **Excluded**: needs a world register, declared optional at plan time and not built |
| `sent:det` defines only *forward* determinism (report-level) | separating frame `F^N`, with the validity widened from sentence letters to the whole **state-locality** fragment and the two-sided bound recorded as one object | `FN`, `fn_forwardDeterministic`, `fn_not_deterministic`, `fn_sentDet_stateLocal`, `fn_separates`, `fn_sentDet_bounds` (`Metalogic/Independence/ForwardDeterministicFrame.lean`) |
| state-locality of L⋆ (no paper anchor) | a state-local `φ` is already `⊡`-stable: `φ ↔ ⊡φ` is valid on the fragment, and `□`/`⊡` belong to it for an *arbitrary* argument | `StarFormula.StateLocal`, `isStateLocal_of_stateLocal`, `stateLocal_starValid_iff_stab` (`Semantics/StarStateLocal.lean`) — **not a manuscript result**; it is the structural closure of the reason the sentence-letter form gave for itself |
| TM⋆ (a proof system for L⋆) | — | **Formalization-native**, not a manuscript result: the manuscript supplies no proof system for `\BL^\star`. `StarAxiom` (`Axioms.lean`), `StarDerivationTree` and `⊢⋆[fc]` (`Derivation.lean`) present TM⋆, shaped after `PlusAxiom`/`PlusDerivationTree` so the two systems are structurally comparable |
| MF over L⋆ (formalization-native) | `□φ → □Gφ` is **not** valid over `StarFormula`, and is valid at every `↓ⁱ`-free formula | `refute_modal_future` (`Semantics/StarNonValidities.lean`) — which is why `StarAxiom.modal_future` alone among the 53 mirror constructors carries a `RecallFree` side condition; the fragment is strictly wider than the `ofPlus` image |
| TM⋆ soundness (formalization-native) | every TM⋆ theorem at `fc` is `StarValidIn fc` | `star_soundness_validIn` (`Metalogic/Conservativity/Star/StarSoundness.lean`), at all four classes, with `star_not_derivable_nil_bot` for consistency at `.Base` |
| L⁺ ⊂ L⋆, backward (formalization-native) | every TM⁺ theorem is a TM⋆ theorem at its embedding | `starDerivable_of_plusDerivable` (`StarLanguage/Embedding.lean`) |
| L ⊂ L⋆, conservativity (formalization-native) | TM⋆ is a conservative extension of TM, both directions, all four classes, **unconditionally** | `starDerivable_ofFormula_iff` (`Metalogic/Conservativity/Star/Forward.lean`) |
| L⁺ ⊂ L⋆, conservativity (formalization-native) | **CONDITIONAL**: general TM⁺ completeness at `fc` implies TM⋆ is conservative over TM⁺ at `fc`; and, unconditionally, any separating witness for non-conservativity *is* a witness of TM⁺ incompleteness | `starConservative_of_plusComplete` and `plusIncomplete_of_starNonconservative` (`Metalogic/Conservativity/Star/Forward.lean`). Both syntactic routes are closed: naive erasure by `storeG_recall_valid`/`refute_erasure`, register collapse by the rigidity schema |
| TM⋆ completeness, any class | — | **OPEN**, never stated and never sorried, with two obstructions named in `Metalogic/Conservativity/Star/README.md`: the four TM engines build deterministic countermodels and `sent:det` is valid on every deterministic frame but not `StarValid`, with no "narrow to the deterministic class" escape because registers do not collapse there; and the standard hybrid pure-axiom/PASTE route needs nominals, which L⋆ has none of |

**Report-level results are cited as such.** `Det-pm`, `Det-m`, and the forward-determinism
sharpening are recorded in the PossibleWorlds repository's determinism-axiom-correspondence
report (`reports/02_determinism-axiom-correspondence.md`, §3.2, §3.3, §4) and are **pending paper
integration**. They are never cited as manuscript text and never as conjectures.

**One recorded divergence from that report's Theorem A, now bounded from both sides.**
`fn_sentDet_stateLocal` is stated at every **state-local** instance, not schematically. The
schematic form is *refutable* over `F^N`, and `fn_refutes_sentDet_somePast` is the
machine-checked refutation: forward determinism settles the future and says nothing about the
past, so a past-looking instance such as `P p` distinguishes two possible worlds of the same
stability class at a *future* time. Theorem A itself is stated at the sentence-letter level (it
runs the singleton valuation `|p| = {τ(y)}`), so nothing in the report is contradicted — the
Lean statement is *stronger* than Theorem A on the positive side, and the schematic reading must
still not be assumed.

The restriction is no longer an artifact. The sentence-letter form gave as its reason "an atom's
truth depends on nothing but the state at the time of evaluation" — a reason about
state-locality, not about atoms. `StarFormula.StateLocal` (`Semantics/StarStateLocal.lean`) is
that reason cut as a syntactic fragment, and `fn_sentDet_bounds` records the resulting two-sided
bound as a single machine-checked object: valid at every state-local instance, refuted at `P p`,
which the middle conjunct certifies lies outside the fragment.

## Module Invariants

**1. Nothing under `FormalSystem/StarLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'import FormalSystem.Semantics' FormalSystem/StarLanguage/`. The invariant
is directional, exactly as for `MinusLanguage/` and `PlusLanguage/`; the converse edge is
permitted and is how L⋆ acquires its semantics.

**2. No L⋆ atomization, ever, and no argument by uniform substitution.** Both shortcuts are
permanently unavailable, not merely unused:

- *Atomization* rests on `stab_state_only` (`Metalogic/Conservativity/Plus/Atomization.lean`) —
  the very invariant `StarFormula` is built to break, since neither `↓ⁱχ` nor `↑ⁱχ` is
  state-determined. There is no L⋆ analogue and there cannot be one.
- *Uniform substitution* is unsound over this family: TM⁺ is already not substitution-closed via
  `PlusAxiom.atom_stab`.

The 53 schematic validity arms in `Metalogic/Conservativity/Star/StarAxiomValidity.lean` are each
a fresh direct proof against `StarTruthAt`. Facing that many arms, atomization is the shortcut a
future contributor is most likely to reach for; it is recorded here so the reach is stopped at
the invariant list rather than at a failed proof.

## References

* JPL paper `possible_worlds.tex` — `def:BLstar-semantics`, `sub:Extension`, `sent:det`,
  `app:deterministic-future`, `app:drift`, `cor:no-characterization`,
  `lem:deterministic-singleton`, `thm:extension`
* `FormalSystem/PlusLanguage/README.md` — L⁺, the language this one extends
* The PossibleWorlds `02_determinism-axiom-correspondence.md` report — Theorem C and the
  forward-determinism sharpening, both pending paper integration
