# Metalogic/Conservativity/Open

The restricted-modal extension L^▷ = L⁺ plus the manuscript's open-future `▷` and open-past `◁`
operators, and the proof system over it.

This is the third language layer of the same shape as `Conservativity/Plus/` and
`Conservativity/Star/`: a separate inductive with a constructor-to-constructor embedding of the
language below, an axiom type mirroring the one below plus a block for the new operators, and a
soundness recursion transcribing the one below rule for rule.

**No completeness is claimed here, at any frame class, in any form.** The component delivers a
sound system that is conservative over TM⁺ in both directions and over TM at all four classes,
and nothing more. `plus_incomplete_base` stands as proved, the Burgess-style limit-closure
principle stays a non-theorem, and an LC_n-style schema is still required in L^▷ exactly as it is
in L⁺.

Completeness and decidability are pursued for TM⁺, not for L^▷ directly.
`Metalogic/Expressiveness/OpenFutureElimination.lean` gives the route by which a landed TM⁺
result would reach here: `exists_translation_ztime` and `exists_translation_rtime` say that,
conditional on `SeparationOver` (Gabbay's Separation Theorem over the relevant flow, an explicit
hypothesis discharged nowhere in this tree), a validity-preserving translation back to L⁺ exists
at `.ZTime` and `.RTime`, and `decidableOpenValidInOfTranslation` / `openDecider_correct` turn
such a translation into a decision procedure. `.Base` and `.Dense` have **no such route**: `▷`
is not L⁺-definable at either class, so there is no translation for a landed TM⁺ result to ride.

## Why atomization is unavailable here

`Conservativity/Plus/AxiomValidity.lean` discharges 45 of its 53 arms through
`Conservativity/Plus/Atomization.lean`: each TM⁺ schema instance is reduced to the landed L schema
at atomized parameters under one fixed encoding, so no schema is re-proved over `PlusTruthAt`.
That route does not transfer to L^▷, for two independent reasons.

* **Atomization rests on state-locality.** The encoding's correctness uses `stab_state_only` — the
  `⊡` clause sees only the present world state — and `▷χ` is not state-local: its truth at `(τ, t)`
  depends on the whole of `τ` up to `t`. An atom standing for `▷χ` would have to carry a valuation
  the `⊡` clause cannot reproduce.
* **TM⁺ is not substitution-closed through `atom_stab`.** The schema `p → ⊡p` is deliberately
  atom-restricted; widening it to arbitrary formulas would change TM⁺. So a uniform-substitution
  shortcut that replaces an atom by a compound formula is unavailable in the first place.

The consequence is that the restricted-modal block is cheap (every obligation is a landed
`openValid_*` theorem) while the 53 re-declared TM⁺ schemata must be discharged directly against
`OpenTruthAt`. A generic alternative — schema-validity lemmas stated once over
`[TruthEnv L] [StabClauses L]` in `Semantics/TruthClauses.lean`, serving L⁺, L⋆ and L^▷ at once —
would remove that cost for all three languages and is deliberately out of scope here.

## Modules

| Module | Contents |
|---|---|
| `OpenAxiomValidity.lean` | The L^▷ purity congruences `openTruthAt_congr_agreeFrom` / `openTruthAt_congr_agreeUpTo`; the time-shift infrastructure `openTruthAt_congr_ext` / `openTruthAt_timeShift`; the `K±` clause lemmas `openKPlus_iff` / `openKMinus_iff`; a per-constructor validity and reflection-validity theorem for each of the 71 `OpenAxiom` constructors; thirteen block aggregates whose covered-name lists partition that set exactly; and the two wildcard-free 71-arm dispatch lemmas `openAxiom_validIn_min` / `openAxiom_reflect_time_validIn_min` |
| `OpenSoundness.lean` | The companion recursion `open_derivable_valid_and_reflect_time_validIn` over `OpenDerivationTree`'s seven rules; `open_soundness_validIn` and the context form `open_soundness_in`; the four class rows `open_soundness_valid` / `_dense` / `_ztime` / `_rtime`; and the consistency row `open_not_derivable_nil_bot` |
| `Forward.lean` | `forward_open` and its four class rows; `openDerivable_ofFormula_iff` and its four class rows (the L ⊂ L^▷ row, both directions, through a `WeakCompleteness` engine for TM); and `openDerivable_ofPlus_iff`, the L⁺ ⊂ L^▷ row in both directions — unconditional, syntactic, and carrying no engine argument |

## References

* `FormalSystem/OpenLanguage/README.md` — the language, its semantics, and the paper-label table
* `FormalSystem/Metalogic/Conservativity/Plus/README.md` — the layer below, and the atomization
  route this directory cannot use
