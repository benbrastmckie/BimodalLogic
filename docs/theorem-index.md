# Theorem Index

**This page is the single per-theorem status ledger for the repository.** Every other surface —
`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
`FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Conservativity.lean`, the typst document —
carries a pointer here plus, at most, a five-row highlights table. If two of them disagree, this
page is right and the other is stale.

## How to read a row

| Column | Meaning |
|--------|---------|
| Paper label | The `\label{}` in ["The Construction of Possible Worlds"](https://benbrastmckie.com/publications/possible_worlds.pdf), pinned in [`specs/paper-definitions-of-record.md`](../specs/paper-definitions-of-record.md) and checked by C15. `—` means the result is the formalization's own, with no paper counterpart — compactness, non-compactness and consequence completeness are all in that category. |
| Statement | One line. The Lean statement itself is the authority. |
| Lean name | **Fully qualified, always.** A bare base identifier is not a row key: it can name declarations in more than one namespace, and the File column alone does not disambiguate them. `completeness_dense` and `completeness_ztime` used to do exactly that — the `BXCanonical` engines have since been renamed `derivable_of_validDense` / `derivable_of_validZTime`, but the convention stands for every row. |
| File | Path only. **No line numbers**: cite declaration names, never `file:line`. |
| Frame class | The `FrameClass` the result is stated at: `Base`, `Dense`, `ZTime`, `RTime`. `—` where the result is class-generic. |
| Axioms | `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`; anything else is written out literally. `pinned:C2` / `pinned:C14` names the check in `scripts/check-module-invariants.sh` that asserts the value on every build — the column is generated from those baselines, never typed. `claimed` would mean prose-only; no row currently reads that. |

Every declaration listed here is machine-pinned. To re-derive the whole column:

```bash
bash scripts/check-module-invariants.sh        # C2 and C14 assert every value below
```

## Notation and naming

The paper and the formalization use different vocabularies for the same objects. This table is
the mapping.

| Paper term | Lean identifier | Notes |
|------------|-----------------|-------|
| task frame | `FormalSystem.Semantics.TaskFrame` | `def:frame`; four axioms — Compositionality, Seriality, Limit, Saturation. Nullity is *derived*, not an axiom |
| partial history | `FormalSystem.Semantics.PartialHistory` | `def:world-history`; nonempty domain, no convexity requirement |
| convex history | `FormalSystem.Semantics.ConvexHistory` | `def:world-history`; a partial history whose domain is convex. **Not** a possible world: a bounded convex history is a member of neither `HF` nor the paper's top tier |
| possible world | `TaskFrame.HF` (predicate form: `ConvexHistory.IsTotal`) | `def:world-history`; a convex history whose domain is total, so `X = D`. `HF` is the paper's `H_F` |
| task relation `w ⇒ₓ v` | `TaskFrame.TaskRel` | `def:task-relation` |
| duration group `D` | `FormalSystem.Semantics.TemporalOrder` | `def:temporal-order`; a nontrivial totally ordered abelian group |
| TM | `FormalSystem.ProofSystem` over `FrameClass.Base` | `def:TMplus`. The anchor id still reads `TMplus` for historical reasons; its text defines the paper's **TM** over the language **𝓛**, which is this tree's **L**. The two names now coincide — see `Metalogic/Conservativity.lean` |
| TM_d (dense) | `FrameClass.Dense` | `def:BX-d` (the paper's **TM**_d, over **BX**_d) |
| TM_z (ℤ-time) | `FrameClass.ZTime` | `def:BX-z` (the paper's **TM**_z, over **BX**_z). The tree says `ZTime`, not `Discrete` |
| TM_r (dense and Dedekind-complete) | `FrameClass.RTime` | `def:BX-r` (the paper's **TM**_r, over **BX**_r, *Dense and Complete*). The tree says `RTime`, not `Dedekind` |
| L⁻ / TM⁻ (tense-primitive, `H`/`G` primitive) | `FormalSystem.MinusLanguage` | its truth relation is `Semantics.MinusTruthAt`, a native six-clause recursion, **not** `TruthAt ∘ tr`. L⁻ answers to **no paper name**: the H/G fragment was withdrawn from the paper, so nothing in the manuscript corresponds to it |
| L⁺ / TM⁺ (stability modal `⊡`) | `FormalSystem.PlusLanguage` | truth relation `Semantics.PlusTruthAt`. L⁺ is the **⊡-only fragment** of the paper's `𝓛⋆` (`sub:Extension`, `def:BLstar-semantics`); the paper supplies no logic for `𝓛⋆`, so TM⁺ answers to no paper name |
| L⋆ / TM⋆ (time registers `↑ⁱ`, `↓ⁱ`) | `FormalSystem.StarLanguage` | truth relation `Semantics.StarTruthAt`, whose point of evaluation carries a stored-time vector as well as a history and a time. L⋆ is the paper's `𝓛⋆` (`def:BLstar-semantics`) in full; the manuscript supplies no proof system for it, so TM⋆ — `FormalSystem.StarLanguage.StarAxiom` over `StarDerivationTree` — is formalization-native and answers to no paper name |
| `U(φ, ψ)` (until) | `Formula.untl ψ φ` | guard-first: `untl guard event` |
| `S(φ, ψ)` (since) | `Formula.snce ψ φ` | guard-first |
| `△φ` / `▽φ` | `Formula.always` / `Formula.sometimes` | derived, not primitive |
| `Xφ` / `Yφ` | `Formula.next` / `Formula.prev` | derived from `untl`/`snce` |
| validity on a frame class | `FrameClass.Sat` (`FormalSystem/Semantics/FrameClassValidity.lean`) | `def:frame-validity` |
| axiomatizability / Galois closure | `Semantics.Th` / `Semantics.Mod` | `Semantics/Correspondence/Galois.lean` |
| weak completeness | `WeakCompleteness fc` | one formula |
| finite-context consequence completeness | `consequence_completeness_*` | `Context = List Formula`; inter-derivable with the weak form through the deduction theorem. **Not** strong completeness |
| strong completeness | `StrongCompleteness fc` | consequence from a possibly-infinite `Γ : Set Formula` under `SetDerivable` |

## The ledger

### Soundness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `thm:TM-soundness` | TM is sound over all task frames | `FormalSystem.Metalogic.soundness` | `FormalSystem/Metalogic/Soundness.lean` | Base | pcq pinned:C14 |
| `thm:TM-soundness` | TM_d is sound over the densely ordered task frames | `FormalSystem.Metalogic.soundness_dense` | `FormalSystem/Metalogic/Soundness.lean` | Dense | pcq pinned:C14 |
| `thm:TM-soundness` | TM_z is sound over ℤ-time | `FormalSystem.Metalogic.soundness_ztime` | `FormalSystem/Metalogic/Soundness.lean` | ZTime | pcq pinned:C14 |
| `thm:TM-soundness` | TM_r is sound over the dense Dedekind-complete task frames | `FormalSystem.Metalogic.soundness_rtime` | `FormalSystem/Metalogic/Soundness.lean` | RTime | pcq pinned:C14 |

### Weak completeness — the engines

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `cor:tm-completeness` | Weak completeness over all task frames, by the chronicle construction | `FormalSystem.Metalogic.BXCanonical.completeness` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | Base | pcq pinned:C2 |
| `cor:tm-completeness` | Weak completeness over the dense class, by the chronicle construction | `FormalSystem.Metalogic.BXCanonical.derivable_of_validDense` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | Dense | pcq pinned:C2 |
| `cor:tm-completeness` | Weak completeness over ℤ-time, by the chronicle construction | `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | ZTime | pcq pinned:C2 |
| `cor:tm-completeness` | Weak completeness over the dense Dedekind-complete class, on the real line | `FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine` | `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` | RTime | pcq pinned:C14 |

### Weak completeness — the `WeakCompleteness` termini

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `cor:tm-completeness` | `WeakCompleteness FrameClass.Base`, the corollary of consequence completeness | `FormalSystem.Metalogic.completeness_base` | `FormalSystem/Metalogic/StrongCompleteness.lean` | Base | pcq pinned:C14 |
| `cor:tm-completeness` | `WeakCompleteness FrameClass.Dense` | `FormalSystem.Metalogic.completeness_dense` | `FormalSystem/Metalogic/StrongCompleteness.lean` | Dense | pcq pinned:C14 |
| `cor:tm-completeness` | `WeakCompleteness FrameClass.ZTime` | `FormalSystem.Metalogic.completeness_ztime` | `FormalSystem/Metalogic/StrongCompleteness.lean` | ZTime | pcq pinned:C14 |
| `cor:tm-completeness` | `WeakCompleteness FrameClass.RTime` | `FormalSystem.Metalogic.completeness_rtime` | `FormalSystem/Metalogic/StrongCompleteness.lean` | RTime | pcq pinned:C14 |

### Finite-context consequence completeness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Finite-context consequence completeness against `SemanticConsequence` | `FormalSystem.Metalogic.consequence_completeness_base` | `FormalSystem/Metalogic/StrongCompleteness.lean` | Base | pcq pinned:C14 |
| — | Finite-context consequence completeness against `SemanticConsequenceDense` | `FormalSystem.Metalogic.consequence_completeness_dense` | `FormalSystem/Metalogic/StrongCompleteness.lean` | Dense | pcq pinned:C14 |
| — | Finite-context consequence completeness against `SemanticConsequenceZTime` | `FormalSystem.Metalogic.consequence_completeness_ztime` | `FormalSystem/Metalogic/StrongCompleteness.lean` | ZTime | pcq pinned:C14 |
| — | Finite-context consequence completeness against `SemanticConsequenceRTime` | `FormalSystem.Metalogic.consequence_completeness_rtime` | `FormalSystem/Metalogic/StrongCompleteness.lean` | RTime | pcq pinned:C14 |

### Compactness and strong completeness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | `CompactBase`, by ultraproduct model existence over the finite sublists | `FormalSystem.Metalogic.compactBase` | `FormalSystem/Metalogic/Compactness.lean` | Base | pcq pinned:C14 |
| — | `CompactDense`, by ultraproduct model existence over the finite sublists | `FormalSystem.Metalogic.compactDense` | `FormalSystem/Metalogic/Compactness.lean` | Dense | pcq pinned:C14 |
| — | Strong completeness for `Γ : Set Formula` | `FormalSystem.Metalogic.strongCompletenessBase` | `FormalSystem/Metalogic/Compactness.lean` | Base | pcq pinned:C14 |
| — | Strong completeness for `Γ : Set Formula` | `FormalSystem.Metalogic.strongCompletenessDense` | `FormalSystem/Metalogic/Compactness.lean` | Dense | pcq pinned:C14 |

### TM⁺ over the deterministic frames

These are the `⊡ = identity` rows. **General (nondeterministic) TM⁺ completeness is open and is
not stated anywhere in the tree**; the nearest literature results are Reynolds (2003) and
Zanardo (1991). *Determined* axiomatizes the deterministic frames' logic without defining the
class — see `deterministic_not_plusDefinable` above.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `app:deterministic` | TM⁺ + *Determined* is sound over the frames validating *Determined* | `FormalSystem.Metalogic.Deterministic.detSoundness` | `FormalSystem/Metalogic/Deterministic/Soundness.lean` | — | pcq |
| `app:deterministic` | TM⁺ + *Determined* is complete over the deterministic task frames | `FormalSystem.Metalogic.Deterministic.detCompletenessBase` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | Base | pcq |
| `app:deterministic` | The same over the deterministic dense frames | `FormalSystem.Metalogic.Deterministic.detCompletenessDense` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | Dense | pcq |
| `app:deterministic` | The same over the deterministic ℤ-time frames | `FormalSystem.Metalogic.Deterministic.detCompletenessZTime` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | ZTime | pcq |
| `app:deterministic` | The same over the deterministic dense Dedekind-complete frames | `FormalSystem.Metalogic.Deterministic.detCompletenessRTime` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | RTime | pcq |
| `app:deterministic` | The logic of the deterministic frames and the logic of the *Determined*-valid frames coincide, at every class | `FormalSystem.Metalogic.Deterministic.logicDeterministicEqDeterminedValid` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | — | pcq |

### Non-redundancy of the TM⁺ axiom set

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Naive soundness: a TM⁺ theorem not using the pasting axioms is valid in every coarsened-state model | `FormalSystem.Metalogic.Independence.naive_cValid` | `FormalSystem/Metalogic/Independence/CoarsenedModels.lean` | Base | pcq |
| — | PS is not derivable from TM plus {SK, ST, S4, S5, MS, AS} | `FormalSystem.Metalogic.Independence.pasteNotNaiveDerivable` | `FormalSystem/Metalogic/Independence/PastingIndependence.lean` | Base | pcq |
| — | US is not derivable from TM plus {SK, ST, S4, S5, MS, AS} | `FormalSystem.Metalogic.Independence.untlPasteNotNaiveDerivable` | `FormalSystem/Metalogic/Independence/PastingIndependence.lean` | Base | pcq |

### Non-compactness — the two refutations

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | `¬ CompactZTime`: `{F p} ∪ {¬Xⁿ p}` is finitely satisfiable over ℤ, unsatisfiable on any Archimedean discrete carrier | `FormalSystem.Metalogic.notCompactZTime` | `FormalSystem/Metalogic/DiscreteNonCompactness.lean` | ZTime | pcq pinned:C14 |
| — | `¬ StrongCompletenessZTime`, the companion refutation | `FormalSystem.Metalogic.notStrongCompletenessZTime` | `FormalSystem/Metalogic/DiscreteNonCompactness.lean` | ZTime | pcq pinned:C14 |
| — | `¬ CompactRTime`: the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤}` witness, finitely satisfiable over ℝ | `FormalSystem.Metalogic.notCompactRTime` | `FormalSystem/Metalogic/DedekindNonCompactness.lean` | RTime | pcq pinned:C14 |
| — | `¬ StrongCompletenessRTime`, the companion refutation | `FormalSystem.Metalogic.notStrongCompletenessRTime` | `FormalSystem/Metalogic/DedekindNonCompactness.lean` | RTime | pcq pinned:C14 |

### Decidability

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | The tableau decision procedure | `FormalSystem.Metalogic.Decidability.decide` | `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` | Base | pcq pinned:C14 |
| — | Soundness of the decision procedure: a valid verdict yields validity | `FormalSystem.Metalogic.Decidability.sound_of_isValid` | `FormalSystem/Metalogic/Decidability/Correctness.lean` | Base | pcq pinned:C14 |

### Characterization and definability

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `app:dense` | `Sat .Dense` is Galois-closed, via the `nextTop` indicator | `FormalSystem.Semantics.galoisClosed_sat_dense` | `FormalSystem/Semantics/Correspondence/Indicator.lean` | Dense | pcq pinned:C14 |
| `app:discrete` | `{F | F.IsDiscrete}` is Galois-closed, via the `nextTop` indicator | `FormalSystem.Semantics.galoisClosed_isDiscrete` | `FormalSystem/Semantics/Correspondence/Indicator.lean` | ZTime | pcq pinned:C14 |
| — | A frame class is axiomatizable iff it is Galois-closed under `Th`/`Mod` | `FormalSystem.Semantics.galoisClosed_mod` | `FormalSystem/Semantics/Correspondence/Galois.lean` | — | `[propext]` pinned:C14 |
| — | Closure from one indicator formula valid on precisely the class's members | `FormalSystem.Semantics.galoisClosed_of_indicator` | `FormalSystem/Semantics/Correspondence/Galois.lean` | — | pcq pinned:C14 |
| `app:complete` | `Sat .RTime ⊊ Mod (AxiomSet .RTime)` — the narrowing is not Galois-closed | `FormalSystem.Metalogic.Independence.sat_rtime_ssubset_mod_axiomSet` | `FormalSystem/Metalogic/Independence/RationalWitness.lean` | RTime | pcq pinned:C14 |
| `app:discrete` | `Sat .ZTime ⊊ Mod (AxiomSet .ZTime)` — the narrowing is not Galois-closed | `FormalSystem.Metalogic.Independence.sat_ztime_ssubset_mod_axiomSet` | `FormalSystem/Metalogic/Independence/LexIntWitness.lean` | ZTime | pcq pinned:C14 |
| `app:deterministic` | No set of `PlusFormula`s defines `TaskFrame.Deterministic` | `FormalSystem.Metalogic.Independence.deterministic_not_plusDefinable` | `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` | — | pcq pinned:C14 |
| `def:BLstar-semantics` | No `Formula` of L is equivalent to `⊡Fp` over all task models — the stability modal is not L-definable | `FormalSystem.Metalogic.Independence.stabNotDefinable` | `FormalSystem/Metalogic/Independence/StabUndefinable.lean` | — | pcq |
| — | Every formula of the syntactic **state-locality** fragment of L⋆ has the semantic property: possible worlds sharing a world state at `t` agree about it at `t` | `FormalSystem.Semantics.isStateLocal_of_stateLocal` | `FormalSystem/Semantics/StarStateLocal.lean` | — | `[propext]` |
| — | `φ ↔ ⊡φ` is valid for every state-local `φ` — the fragment-level strengthening of the atom-level `p → ⊡p` | `FormalSystem.Semantics.stateLocal_starValid_iff_stab` | `FormalSystem/Semantics/StarStateLocal.lean` | Base | pcq |
| — | Every formula of the syntactic **state-locality** fragment of L⁺ has the semantic property: possible worlds sharing a world state at `t` agree about it at `t` | `FormalSystem.Semantics.isPlusStateLocal_of_stateLocal` | `FormalSystem/Semantics/PlusStateLocal.lean` | — | `[propext]` |
| — | `φ ↔ ⊡φ` is valid for every state-local `φ` of L⁺ — the fragment-level strengthening of the atom-level `p → ⊡p`, and the AS witness of TM⁺ soundness | `FormalSystem.Semantics.plusStateLocal_plusValid_iff_stab` | `FormalSystem/Semantics/PlusStateLocal.lean` | Base | pcq |
| — | The two state-locality fragments agree along `ofPlus`, as a biconditional: the L⁺ fragment is exactly the `ofPlus`-preimage of the L⋆ one | `FormalSystem.Semantics.stateLocal_ofPlus_iff` | `FormalSystem/Semantics/StateLocalTransfer.lean` | — | `[]` |
| — | `sent:det` is valid over the forward-deterministic `F^N` at **every** state-local instance, not only at sentence letters | `FormalSystem.Metalogic.Independence.fn_sentDet_stateLocal` | `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` | — | pcq |
| — | The two-sided bound: valid at every state-local instance, refuted at `P p`, which lies outside the fragment | `FormalSystem.Metalogic.Independence.fn_sentDet_bounds` | `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` | — | pcq |

### Conservativity — TM⁻ over L⁻, TM over TM⁻, TM⁺ over TM

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | `TM⁻ ⊢ φ ⟹ TM ⊢ tr φ`, the backward bridge | `FormalSystem.Metalogic.Conservativity.derivable_translate` | `FormalSystem/Metalogic/Conservativity/Backward.lean` | — | pcq pinned:C14 |
| — | CEB row corollary of the backward bridge | `FormalSystem.Metalogic.Conservativity.ceb_backward` | `FormalSystem/Metalogic/Conservativity/Backward.lean` | Base | pcq pinned:C14 |
| — | CEF row corollary of the backward bridge | `FormalSystem.Metalogic.Conservativity.cef_backward` | `FormalSystem/Metalogic/Conservativity/Backward.lean` | ZTime | pcq pinned:C14 |
| — | CED row corollary of the backward bridge | `FormalSystem.Metalogic.Conservativity.ced_backward` | `FormalSystem/Metalogic/Conservativity/Backward.lean` | Dense | pcq pinned:C14 |
| — | CEC row corollary of the backward bridge | `FormalSystem.Metalogic.Conservativity.cec_backward` | `FormalSystem/Metalogic/Conservativity/Backward.lean` | RTime | pcq pinned:C14 |
| — | Soundness of the H/G-fragment `TMFrag` | `FormalSystem.Metalogic.Conservativity.tmFrag_sound` | `FormalSystem/Metalogic/Conservativity/Fragment.lean` | — | pcq pinned:C14 |
| — | Completeness of `TMFrag` at all four frame classes | `FormalSystem.Metalogic.Conservativity.tmFrag_complete` | `FormalSystem/Metalogic/Conservativity/Fragment.lean` | — | pcq pinned:C14 |
| — | `TM ≤ TMFrag` everywhere | `FormalSystem.Metalogic.Conservativity.tmMinus_le_tmFrag` | `FormalSystem/Metalogic/Conservativity/Fragment.lean` | — | pcq pinned:C14 |
| — | `TM ⊊ TMFrag` at ℤ-time | `FormalSystem.Metalogic.Conservativity.tmMinus_lt_tmFrag_ztime` | `FormalSystem/Metalogic/Conservativity/Fragment.lean` | ZTime | pcq pinned:C14 |
| — | Proof-theoretic conservativity of TM⁺ over TM, both directions, all four classes | `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` | — | pcq pinned:C14 |
| — | Proof-theoretic conservativity of TM⁺ + *Determined* over TM, all four classes | `FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | — | pcq |
| — | Soundness of TM⁺ at every frame class | `FormalSystem.Metalogic.Conservativity.plus_soundness_validIn` | `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean` | — | pcq pinned:C14 |
| — | Semantic conservativity of L⁺ over L | `FormalSystem.Semantics.plusValidIn_ofFormula_iff` | `FormalSystem/Semantics/PlusValidity.lean` | — | `[propext]` pinned:C14 |

### TM⋆ over L⋆ — the store/recall language

TM⋆ is TM⁺ plus the manuscript's time registers `↑ⁱ`/`↓ⁱ` (`FormalSystem/Syntax/StarLanguage/`). Its
axiom set re-declares the TM⁺ schemata directly over `StarFormula`, with `modal_future` alone
under a `RecallFree` (`↓ⁱ`-free) side condition because it is refuted at arbitrary `φ` — see the
refutations section below.

`FormalSystem.StarLanguage.StarAxiom` has **no row here**, and its absence is deliberate rather
than an oversight: `#print axioms` reports it as `does not depend on any axioms`, a line the C14
pipeline's `grep 'depends on axioms'` filter drops, so C14's exact-string mechanism cannot pin
it and this page admits no unpinned row. `StarDerivationTree` immediately below carries the
axiom set of the derivation machinery `StarAxiom` feeds.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Derivation trees for TM⋆: the same seven rules as TM⁺ and TM, with `StarAxiom` in the `axiom` rule | `FormalSystem.StarLanguage.StarDerivationTree` | `FormalSystem/Syntax/StarLanguage/Derivation.lean` | — | `[propext]` pinned:C14 |
| — | Soundness of TM⋆ at every frame class | `FormalSystem.Metalogic.Conservativity.star_soundness_validIn` | `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` | — | pcq pinned:C14 |
| — | Proof-theoretic conservativity of TM⋆ over TM, both directions, all four classes | `FormalSystem.Metalogic.Conservativity.starDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |
| — | Conservativity of TM⋆ over TM⁺, **conditional** on general TM⁺ completeness at that class | `FormalSystem.Metalogic.Conservativity.starConservative_of_plusComplete` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |
| — | The unconditional contrapositive: a TM⋆/TM⁺ separating witness is a witness of TM⁺ incompleteness | `FormalSystem.Metalogic.Conservativity.plusIncomplete_of_starNonconservative` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |

### Base-language soundness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Soundness of TM⁻ against the native `MinusTruthAt` semantics | `FormalSystem.Metalogic.minus_soundness` | `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | Base | pcq pinned:C14 |
| — | TM⁻ soundness over the dense class | `FormalSystem.Metalogic.minus_soundness_dense` | `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | Dense | pcq pinned:C14 |
| — | TM⁻ soundness over ℤ-time | `FormalSystem.Metalogic.minus_soundness_ztime` | `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | ZTime | pcq pinned:C14 |
| — | TM⁻ soundness over the dense Dedekind-complete class | `FormalSystem.Metalogic.minus_soundness_rtime` | `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | RTime | pcq pinned:C14 |
| — | Consistency of TM⁻: `⊬ ⊥` | `FormalSystem.Metalogic.minus_not_derivable_nil_bot` | `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | Base | pcq pinned:C14 |

### Expressiveness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | `{U, S}` is expressively complete for Prior structures relative to monadic FO | `FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness` | `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | — | pcq pinned:C14 |
| — | The load-bearing corollary consumed by the live completeness chain | `FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior` | `FormalSystem/Metalogic/WeakCanonical/PriorExpressiveness.lean` | — | pcq pinned:C14 |

## Statuses that are refutations, not gaps, and one status that is a gap

Three of the rows above are negative results, and they are easy to misread as unfinished work:

- **Strong completeness at `ZTime` and `RTime` is machine-refuted**, not open.
  `notStrongCompletenessZTime` and `notStrongCompletenessRTime` settle both negatively, which is
  why only the weak forms appear for those two classes.
- **Forward proof-theoretic conservativity of TM over TM⁻ is refuted at `Base` and `ZTime`** and
  open at `Dense` and `RTime`. Both refutations are machine-checked:
  `FormalSystem.Metalogic.tmMinusCompleteBase_refuted`
  (`FormalSystem/Metalogic/Conservativity/SpCountermodel.lean`, over the native `MinusFrame`
  semantics) and `FormalSystem.Metalogic.tmMinusCompleteZTime_refuted`
  (`FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean`).
  `FormalSystem/Metalogic/Conservativity.lean` carries the standing
  prohibition on attempting or `sorry`-ing it; that record is the authority on the CEB/CEF/CED/CEC
  rows, this page on their per-theorem status.
- **The `Sat` narrowings are not Galois-closed** at `ZTime` and `RTime`
  (`sat_ztime_ssubset_mod_axiomSet`, `sat_rtime_ssubset_mod_axiomSet`). This is a statement about
  definability of the model class, a different property from strong completeness. Closed-form
  characterizations of `Mod (AxiomSet .ZTime)` and `Mod (AxiomSet .RTime)` remain open and are
  not promised.

One status here *is* a genuine gap, and is recorded so that its absence from the ledger above is
not read as an oversight:

- **Completeness for TM⋆, at every frame class, is OPEN** and is not promised. It is stated
  nowhere in the tree and is never discharged with `sorry`; the two recorded obstructions are in
  [`FormalSystem/Metalogic/Conservativity/Star/README.md`](../FormalSystem/Metalogic/Conservativity/Star/README.md).
  Conservativity of TM⋆ over TM⁺ is entangled with it rather than independent of it:
  `starConservative_of_plusComplete` settles that row *given* general TM⁺ completeness at the
  class, and `plusIncomplete_of_starNonconservative` shows the converse — a separating witness
  for non-conservativity is, verbatim, a witness of TM⁺ incompleteness. So, modulo TM⋆ soundness,
  the TM⋆/TM⁺ conservativity question cannot be settled either way without settling TM⁺
  completeness, which is itself open at every class.

## Related documentation

- [`README.md`](../README.md) — project overview and the `## Verifying the main theorems` recipe
- [`FormalSystem/Metalogic/README.md`](../FormalSystem/Metalogic/README.md) — the directory's
  generated inventory and the three completeness routes
- [`FormalSystem/Metalogic.lean`](../FormalSystem/Metalogic.lean) — the module docstring, whose
  every SORRY-FREE claim is pinned by C2 or C14
- [`specs/paper-definitions-of-record.md`](../specs/paper-definitions-of-record.md) — the pinned
  paper anchors C15 resolves against

## Tags

theorem-index · soundness · completeness · compactness · non-compactness · decidability · conservativity · correspondence · expressiveness
