# Theorem Index

**This page is the single per-theorem status ledger for the repository.** Every other surface —
`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
`FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Conservativity.lean`, the typst document —
carries a pointer here plus, at most, a five-row highlights table. If two of them disagree, this
page is right and the other is stale.

## How to read a row

| Column | Meaning |
|--------|---------|
| Paper label | The `\label{}` in ["The Construction of Possible Worlds"](https://benbrastmckie.com/publications/possible_worlds.pdf), pinned in [`docs/reference/paper-definitions-of-record.md`](reference/paper-definitions-of-record.md) and checked by C15. `—` means the result is the formalization's own, with no paper counterpart — compactness, non-compactness and consequence completeness are all in that category. |
| Statement | One line. The Lean statement itself is the authority. |
| Lean name | **Fully qualified, always.** A bare base identifier is not a row key: it can name declarations in more than one namespace, and the File column alone does not disambiguate them. `completeness_dense` and `completeness_ztime` used to do exactly that — the `BXCanonical` engines have since been renamed `derivable_of_validDense` / `derivable_of_validZTime`, but the convention stands for every row. |
| File | Path only. **No line numbers**: cite declaration names, never `file:line`. |
| Frame class | The `FrameClass` the result is stated at: `Base`, `Dense`, `ZTime`, `RTime`. `—` where the result is class-generic. |
| Axioms | `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`; anything else is written out literally. `pinned:C2` / `pinned:C14` names the check in `scripts/check-module-invariants.sh` that asserts the value on every build — the column is generated from those baselines, never typed. `claimed` would mean prose-only; no row currently reads that. |

Every declaration listed here is machine-pinned, with one deliberate exception that is not a
gap: `PlusSlicedCertificate.FiniteCarrier.θ_eq_ofFormula` is proved by `decide` and depends on no
axioms at all, so `#print axioms` emits no axiom line for it and the C2 baseline — which compares
axiom lines — has nothing to assert. Its cell therefore states the measured value literally and
carries no `pinned:` token. To re-derive the pinned rows' column:

```bash
bash scripts/check-module-invariants.sh        # C2 and C14 assert every value below
```

## Notation and naming

The paper and the formalization use different vocabularies for the same objects. This table is
the mapping.

| Paper term | Lean identifier | Notes |
|------------|-----------------|-------|
| task frame | `FormalSystem.Semantics.TaskFrame` | `def:frame`; four axioms — Compositionality, Seriality, Limit, Saturation. Nullity is *derived*, not an axiom |
| partial history | `FormalSystem.Semantics.PartialHistory` | `def:world-history`; nonempty domain, no convexity requirement. The one history structure; its total instances are the world histories |
| convex history | `PartialHistory.IsConvex` (a predicate, not a structure) | `def:world-history`; a partial history whose domain is convex. A bounded convex history is not a `WorldHistory` |
| world history / possible world | `WorldHistory` (defining predicate: `PartialHistory.IsTotal`) | sec:Construction; a partial history whose domain is total, so `X = D` (the appendix's "convex history with total domain" is the same set, `IsTotal.isConvex`). `WorldHistory F` is the paper's `H_F`; truth, validity and satisfiability are evaluated at and quantify over it |
| task relation `w ⇒ₓ v` | `TaskFrame.TaskRel` | `def:task-relation` |
| `𝒯_F` of the **revised** `def:task-topology` (the cone-*neighbourhood* topology) | `TaskFrame.nbhdTopology`; at a frame, `FrameOver.stateTopology` | The revision **reassigns** the symbol. Its one-clause Open Sets definition is `TaskFrame.nbhdTopology_isOpen_iff` / `FrameOver.isOpen_iff`. Lean keeps the construction-naming `nbhdTopology`, which the reassigned symbol no longer supplies; `StateTopology.lean`'s docstrings write `𝒩_F` for it throughout |
| the superseded subbasis topology, recorded in the revised appendix only as a footnote | `TaskFrame.coneTopology`; at a frame, `FrameOver.coneTop` | What `def:task-topology` called `𝒯_F` before the revision: the cones closed under arbitrary union and finite intersection. Finer than the neighbourhood topology (`TaskFrame.coneTopology_le_nbhdTopology`), strictly so on the hedgehog (`StateTopology.Hedgehog.coneTopology_lt_nbhdTopology`), equal to it on the two-origin frame (`StateTopology.TwoOrigins.coneTopology_eq_nbhdTopology`) |
| duration group `D` | `FormalSystem.Semantics.TemporalOrder` | `def:temporal-order`; a nontrivial totally ordered abelian group |
| TM | `FormalSystem.ProofSystem` over `FrameClass.Base` | `def:TMplus`. The anchor id still reads `TMplus` for historical reasons; its text defines the paper's **TM** over the language **𝓛**, which is this tree's **L**. The two names now coincide — see `Metalogic/Conservativity.lean` |
| TM_d (dense) | `FrameClass.Dense` | `def:BX-d` (the paper's **TM**_d, over **BX**_d). The tree says `Dense`, not `QTime`: the class is not categorical, but its validity equals ℚ-time validity (`FormalSystem.Metalogic.validQTime_iff_validDense`); the argument is on the `FrameClass` docstring |
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

These are the `⊡ = identity` rows. **General (nondeterministic) completeness of the current TM⁺
axiom set is false at Base** (`plus_incomplete_base` above); completeness of any extension is
open at every class and is not stated anywhere in the tree. The nearest literature results are
Reynolds (2003) and Zanardo (1991). *Determined* axiomatizes the deterministic frames' logic without defining the
class — see `deterministic_not_plusDefinable` above.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `app:deterministic` | TM⁺ + *Determined* is sound over the frames validating *Determined* | `FormalSystem.Metalogic.Deterministic.detSoundness` | `FormalSystem/Metalogic/Deterministic/Soundness.lean` | — | pcq |
| `app:deterministic` | TM⁺ + *Determined* is complete over the deterministic task frames | `FormalSystem.Metalogic.Deterministic.detCompletenessBase` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | Base | pcq |
| `app:deterministic` | The same over the deterministic dense frames | `FormalSystem.Metalogic.Deterministic.detCompletenessDense` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | Dense | pcq |
| `app:deterministic` | The same over the deterministic ℤ-time frames | `FormalSystem.Metalogic.Deterministic.detCompletenessZTime` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | ZTime | pcq |
| `app:deterministic` | The same over the deterministic dense Dedekind-complete frames | `FormalSystem.Metalogic.Deterministic.detCompletenessRTime` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | RTime | pcq |
| `app:deterministic` | The logic of the deterministic frames and the logic of the *Determined*-valid frames coincide, at every class | `FormalSystem.Metalogic.Deterministic.logicDeterministicEqDeterminedValid` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | — | pcq |
| `app:deterministic` | The deterministic task frames determine the same L-logic as all task frames, at every class: `ValidIn fc φ ↔ ValidDetIn fc φ`, proved semantically through the shift-set representation | `FormalSystem.Metalogic.Deterministic.validIn_iff_validDetIn` | `FormalSystem/Metalogic/Deterministic/SameLogic.lean` | — | pcq pinned:C14 |
| `app:deterministic` | The same at `.Base` in the manuscript's unbundled shape: `Valid φ` iff `φ` is true at every point of every model over every deterministic frame | `FormalSystem.Metalogic.Deterministic.valid_iff_valid_deterministic` | `FormalSystem/Metalogic/Deterministic/SameLogic.lean` | Base | pcq pinned:C14 |

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
| — | Every ℤ-time countermodel compresses to a bounded, canonically guessed witness family that certifies the refutation | `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` | ZTime | pcq pinned:C14 |
| — | `φ` is ℤ-valid iff no enumerated candidate family certifies a refutation in the bounded window | `FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` | ZTime | pcq pinned:C14 |
| — | Decidability of ℤ-time validity, via the witness-family certificate route | `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` | ZTime | pcq pinned:C14 |
| — | Carrier normalization for L: ℤ-time validity over every discrete duration carrier is validity over `ℤ` alone | `FormalSystem.Semantics.validZTime_iff_validInt` | `FormalSystem/Semantics/IntTransfer.lean` | ZTime | pcq pinned:C2 |
| — | Carrier normalization for L⁺: the same reduction for `PlusValidZTime`, the prerequisite any integer-indexed L⁺ enumeration route rests on | `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` | `FormalSystem/PlusLanguage/PlusIntTransfer.lean` | ZTime | pcq pinned:C2 |
| — | Every world history of the branching witness frame is a thread's trace — the determinism-free replacement for `ShiftSet.total_eq_orbit` | `FormalSystem.Metalogic.Decidability.SharingSkeleton.total_eq_thread` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` | ZTime | pcq pinned:C2 |
| — | (C5) implies that indices naming the same world state agree on every stability-modal label | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.stabFaithful_share_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` | — | pcq pinned:C2 |
| — | L⁺ agreement: labels are truth along every thread, all seven constructors, the `stab` case pinned by (C5) | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` | ZTime | pcq pinned:C2 |
| — | A six-condition L⁺ certificate produces an explicit ℤ-time joint countermodel | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusRefutes_of_certifies` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` | ZTime | pcq pinned:C2 |
| — | (C5) is not vacuous: a two-lasso family whose shared class separates `⊡Fp` from `Fp` | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.stabFamily_separates` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | — | pcq pinned:C2 |
| — | The deterministic diagonal: on identity representatives (C5) degenerates to `⊡φ ↔ φ` | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.stabFaithful_diagonal` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | — | pcq pinned:C2 |
| — | `Pp → ⊡Pp` is a genuine ℤ-time non-validity, so the empty certificate class is a completeness failure | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_stabSnce` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | ZTime | pcq pinned:C2 |
| — | A six-condition L⁺ certificate for `Pp → ⊡Pp` at non-trivial sharing, which no family could supply before succession was separated from state-identity | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusCertifies_stabSnce_example` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | — | pcq pinned:C2 |
| — | The redesigned (C1') does not entail `share`-class agreement on past-tense labels: the retired congruence is refuted, not merely unproved | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_snce_share_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | `Fp → (¬p → ⊡Fp)` is a genuine ℤ-time non-validity, making the `untl`-side emptiness a completeness failure too | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_stabUntl` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | ZTime | pcq pinned:C2 |
| — | A six-condition L⁺ certificate for `Fp → (¬p → ⊡Fp)` at non-trivial sharing, closing the `untl` side | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusCertifies_stabUntl_example` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | — | pcq pinned:C2 |
| — | The redesigned (C1') does not entail `share`-class agreement on the one-step `untl` unfolding either: the shifted congruence is refuted, not merely unproved | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_untl_shift_share_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | `trans`-related indices agree on the `untl` label itself — forced by `trans_refl` alone, the bounded residual retaining it costs | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.untl_trans_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | `trans`-related indices agree on the `snce` label itself — the `snce`-side mirror of `untl_trans_congr`, also forced by `trans_refl` alone | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.snce_trans_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | Two indices sharing one common `untl`-successor agree on the label — reflexivity-free, the exact residual surviving if `trans_refl` is ever dropped | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.untl_common_succ_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | Two indices sharing one common `snce`-predecessor agree on the label — the reflexivity-free `snce`-side mirror of `untl_common_succ_congr` | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.snce_common_pred_congr` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` | — | pcq pinned:C2 |
| — | `□⟐Xp → (□⟐X¬p → ⊥)` is a genuine ℤ-time non-validity: the specification the hop-free strategy is measured against | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_hopTarget` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` | ZTime | pcq pinned:C2 |
| — | No hop-free family certifies `hopTarget`, at any lasso count: the hop-free producer is incomplete, though `TransId.lean`'s collapse theorems stay true | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_exists_hopFree_plusCertifies_hopTarget` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean` | — | pcq pinned:C2 |
| — | `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))` is a genuine ℤ-time non-validity: the specification the whole certificate class is measured against | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_pumpTarget` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` | ZTime | pcq pinned:C2 |
| — | **No** `PlusSharingWitnessFamily` certifies `pumpTarget`, under no hypothesis at all: the landed L⁺ certificate class is incomplete and no bound repairs it | `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` | — | pcq pinned:C2 |
| — | The nine-clause time-sliced L⁺ certificate condition is decidable: the checker is **synthesized** from its clauses rather than postulated | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.decidableCertifies` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` | ZTime | pcq pinned:C2 |
| — | An accepted time-sliced L⁺ certificate produces an explicit ℤ-time joint countermodel, landing the **unchanged** `PlusRefutes` export beside the landed sharing-family producer | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.plusRefutes_of_certifies` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Sound.lean` | ZTime | pcq pinned:C2 |
| — | Completeness relative to tail-stable sliced models: a bi-serial, tail-stable, semantically labelled structure carrying a refuting path admits a box guess the checker accepts, on the same carrier and with **no** bound on the slice width | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.exists_plusSlicedCertificate_of_tailStable_countermodel` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` | ZTime | pcq pinned:C2 |
| — | Every ℤ-time non-validity of an embedded L-formula admits an accepted time-sliced L⁺ certificate: the landed L witness family embeds, so the sliced class is non-vacuous on `⊡`-free targets | `FormalSystem.Metalogic.Decidability.WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` | ZTime | pcq pinned:C2 |
| — | The CTL-like, `⊡`-carrying witness `Φ.neg` is a genuine ℤ-time non-validity of L⁺, on a countable finitely branching regular ℤ-frame | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` | ZTime | pcq pinned:C2 |
| — | **No** model on any finite-width `FrameOver.ofSlicedStep` frame satisfies `Φ` anywhere: `[Finite W] [Nonempty W]` is the whole finiteness hypothesis, with no hypothesis on the succession relation beyond bi-seriality | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.no_finite_width_sat` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` | ZTime | pcq pinned:C2 |
| — | **No** time-sliced certificate certifies `Φ.neg`, with the presented frame kept rather than exported through `PlusRefutes` | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_certifies` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` | ZTime | pcq pinned:C2 |
| — | **The time-sliced certificate class is incomplete for L⁺ over ℤ-time**: `Φ.neg` is a ℤ-time non-validity, inside the CTL-like fragment, that no `PlusSlicedCertificate` certifies | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_sliced_complete` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` | ZTime | pcq pinned:C2 |
| — | **No** certificate class presenting finite-width sliced frames is complete for L⁺, whatever its clauses: the completeness obstruction is exactly finite width | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` | ZTime | pcq pinned:C2 |
| — | The finite-carrier witness `θ` is `⊡`-free: it is the embedding `ofFormula ψL` of a base-language formula, so the refutations below are already statements about TM and not only about L⁺ | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.θ_eq_ofFormula` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | — | no axioms (proved by `decide`; absent from the C2 baseline by construction, since `#print axioms` emits no axiom line for it) |
| — | The `⊡`-free witness `θ.neg` is a genuine ℤ-time non-validity of L⁺, witnessed on an infinite ℤ-carrier shift set | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.not_plusValidZTime_neg_θ` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | **No** model on any regular ℤ-frame with a finite world-state carrier satisfies `θ` anywhere: `[Finite F.WorldState]` is the whole finiteness hypothesis, with no hypothesis on the succession relation beyond the regularity `[F.IsRegular]` carries | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_finite_carrier_sat` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | The same at the concrete constructor: no model on `FrameOver.ofStep R fwd bwd` over a finite type satisfies `θ` — the time-independent relation, not `FrameOver.ofSlicedStep` | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_ofStep_sat` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | **The finite-carrier finite model property fails for L⁺ over ℤ-time**: a ℤ-time non-validity with no countermodel on any regular ℤ-frame with a finite world-state carrier. Scope is ℤ (discrete) frames; nothing is claimed about an infinite carrier, no bound is claimed, and soundness is untouched | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.not_finite_carrier_fmp` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | The `⊡`-bearing fragment twin `θ'.neg` is a genuine ℤ-time non-validity of L⁺ inside the CTL-like fragment, on the same shift set | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.not_plusValidZTime_neg_θ'` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | **No** model on any regular ℤ-frame with a finite world-state carrier satisfies the fragment twin `θ'` anywhere either | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_finite_carrier_sat'` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |
| — | **The finite-carrier finite model property fails already for the CTL-like fragment**: restricting the language does not rescue the finite-carrier shape. Unlike `θ`, this twin bears `⊡`, so it is an L⁺ result and not a TM one | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.not_finite_carrier_fmp_fragment` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` | ZTime | pcq pinned:C2 |

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
| — | The current TM⁺ axiom set is **incomplete** at Base: the limit-closure formula `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` is valid and is not a Base theorem | `FormalSystem.Metalogic.Independence.plus_incomplete_base` | `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean` | Base | pcq pinned:C14 |
| `def:BLstar-semantics` | No `Formula` of L is equivalent to `⊡Fp` over all task models — the stability modal is not L-definable | `FormalSystem.Metalogic.Independence.stabNotDefinable` | `FormalSystem/Metalogic/Independence/StabUndefinable.lean` | — | pcq |
| — | Every formula of the syntactic **state-locality** fragment of L⋆ has the semantic property: possible worlds sharing a world state at `t` agree about it at `t` | `FormalSystem.StarLanguage.isStateLocal_of_stateLocal` | `FormalSystem/StarLanguage/StarStateLocal.lean` | — | `[propext]` |
| — | `φ ↔ ⊡φ` is valid for every state-local `φ` — the fragment-level strengthening of the atom-level `p → ⊡p` | `FormalSystem.StarLanguage.stateLocal_starValid_iff_stab` | `FormalSystem/StarLanguage/StarStateLocal.lean` | Base | pcq |
| — | Every formula of the syntactic **state-locality** fragment of L⁺ has the semantic property: possible worlds sharing a world state at `t` agree about it at `t` | `FormalSystem.PlusLanguage.isPlusStateLocal_of_stateLocal` | `FormalSystem/PlusLanguage/PlusStateLocal.lean` | — | `[propext]` |
| — | `φ ↔ ⊡φ` is valid for every state-local `φ` of L⁺ — the fragment-level strengthening of the atom-level `p → ⊡p`, and the AS witness of TM⁺ soundness | `FormalSystem.PlusLanguage.plusStateLocal_plusValid_iff_stab` | `FormalSystem/PlusLanguage/PlusStateLocal.lean` | Base | pcq |
| — | The two state-locality fragments agree along `ofPlus`, as a biconditional: the L⁺ fragment is exactly the `ofPlus`-preimage of the L⋆ one | `FormalSystem.Semantics.stateLocal_ofPlus_iff` | `FormalSystem/Semantics/StateLocalTransfer.lean` | — | `[]` |
| — | `sent:det` is valid over the forward-deterministic `F^N` at **every** state-local instance, not only at sentence letters | `FormalSystem.Metalogic.Independence.fn_sentDet_stateLocal` | `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` | — | pcq |
| — | The two-sided bound: valid at every state-local instance, refuted at `P p`, which lies outside the fragment | `FormalSystem.Metalogic.Independence.fn_sentDet_bounds` | `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` | — | pcq |
| — | Rigidity: over a dense Archimedean duration group, a task frame is static (`w ⇒ₓ u ↔ w = u`) iff it has a uniform dwell time (one `x₀ > 0` with `(w)_{x₀} = {w}` for every `w`) | `FormalSystem.Semantics.FrameOver.static_iff_uniformDwell` | `FormalSystem/Semantics/Correspondence/Rigidity.lean` | — | pcq pinned:C14 |
| — | Every task frame with finitely many world states over a dense Archimedean duration group is static; both hypotheses are sharp (`RigiditySharpness.lean`) | `FormalSystem.Semantics.FrameOver.static_of_finite` | `FormalSystem/Semantics/Correspondence/Rigidity.lean` | — | pcq pinned:C14 |
| — | Over `ℝ` every task frame with countably many world states is static — no finiteness, density or Archimedean hypothesis; Dedekind completeness replaces them, through Sierpiński's theorem on countable closed partitions of the line | `FormalSystem.Semantics.FrameOver.static_of_countable` | `FormalSystem/Semantics/Correspondence/RigidityReal.lean` | — | pcq pinned:C14 |
| — | The time-indexed rigidity boundary is Dedekind, not Archimedean: over a densely ordered, Dedekind-complete time order, a time-indexed frame with finitely many states satisfying *Limit* has only constant histories | `FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub` | `FormalSystem/Semantics/TimeIndexed.lean` | — | pcq pinned:C14 |
| — | Dedekind completeness cannot be dropped: over `ℚ` a two-state time-indexed frame switching across `√2` satisfies *Limit* and every other frame condition, yet has a non-constant history | `FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories` | `FormalSystem/Semantics/TimeIndexedSharpness.lean` | — | pcq pinned:C14 |

### The extension chain, and what `def:frame`'s constraints buy it

`thm:extension` is the paper's bridge from partial histories to possible worlds. The rows here
record what each link actually consumes, at the granularity the general/regular split
(`FrameOver.IsRegular`) makes statable, and the identification the theorem is one half of:
**partial histories are exactly the restrictions of possible worlds**. Two of these results have
**no paper anchor yet** — the audit proposes labels for them, but no such `\label` exists in the
manuscript, so their rows read `—` and no label-shaped token for them appears anywhere in this
tree (C15 would resolve it against the record and fail).

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| `def:task-relation` | The reflection law costs *Limit* **alone** — no `IsRegular` instance, no *Seriality* | `FormalSystem.Semantics.FrameOver.reflection_of_limit` | `FormalSystem/Semantics/TaskFrame.lean` | — | pcq pinned:C14 |
| — | *Completion* — the condition `lem:step` actually consumes — **is** the one-point extension property, at any frame satisfying *Seriality* and *Limit* | `FormalSystem.Semantics.PartialHistory.completion_iff_onePointExtension` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq pinned:C14 |
| `lem:step` | *Saturation* **derives** *Completion*, through `lem:step` — the one route by which *Saturation* enters the chain, and the reason *Completion* is a lemma about frames rather than a constraint on them | `FormalSystem.Semantics.PartialHistory.completion_of_isRegular` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq pinned:C14 |
| `thm:extension` | `thm:extension` in full from *Completion* + *Seriality* + *Limit*, with **no** *Saturation* and **no** *Compositionality*. Elaborates with no `[F.IsRegular]` binder at all, which certifies the Zorn layer is constraint-free — **and is where the minimality is recorded**, a theorem's hypotheses being where a tight hypothesis belongs | `FormalSystem.Semantics.PartialHistory.extension_of_completion` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq pinned:C14 |
| `lem:step` | `lem:step`'s own closing remark, made precise: *Completion* from *Compositionality* + *Seriality* + nearest times, with **neither** *Saturation* **nor** *Limit* | `FormalSystem.Semantics.PartialHistory.completion_of_hasNearest` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq pinned:C14 |
| `def:BX-z` | Over ℤ-time `thm:extension` follows from *Compositionality* + *Seriality* + *Limit* alone — ***Saturation* is redundant there** | `FormalSystem.Semantics.PartialHistory.extension_of_isZTime` | `FormalSystem/Semantics/Extension/Completion.lean` | ZTime | pcq pinned:C14 |
| — | ***Completion*, over a bare task relation** — the **derived** condition `lem:step` consumes, stated in the primitives `W`, `D` and `⇒` alone so that it is comparable with `def:frame`'s constraints in their own vocabulary. It is **not** one of them: its hypothesis clause is `def:world-history`'s clause verbatim, and `completion_iff_onePointExtension` makes it equivalent to "the construction `thm:extension` performs succeeds". Sited beside `Saturation`, `Serial`, `Compositional` and `Limit`; `PartialHistory.CoherentCompletion` is definitionally it | `FormalSystem.Semantics.TaskFrame.Completion` | `FormalSystem/Semantics/TaskFrame.lean` | — | — |
| `lem:step` | **Finitary *Completion*** from *Compositionality* + *Seriality* over **any** temporal order: a finite domain has a nearest time on each side of the target. With `RationalTwoOrigins.not_rel_completion` this shows no condition implied by *Compositionality* can be equivalent to *Completion*, so the infinitary quantifier is essential | `FormalSystem.Semantics.PartialHistory.completion_of_finite_domain` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq pinned:C14 |
| — | **A nest**: a nonempty `⊆`-chain of sets. General order theory, staged for upstreaming; Mathlib carries no ball-space API at all | `Order.IsNest` | `FormalSystem/ForMathlib/Order/BallSpace.lean` | — | — |
| — | A nest is `⊇`-directed in the members-witness sense — **the entire mathematical content of the ball-space hierarchy's `S₁ᵈ → S₁`**, with no frame in it | `Order.IsNest.exists_subset_inter` | `FormalSystem/ForMathlib/Order/BallSpace.lean` | — | `[propext]` |
| — | **Spherical completeness `S₁`** over an arbitrary ball predicate: every nest of nonempty balls has nonempty intersection | `Order.SphericallyComplete` | `FormalSystem/ForMathlib/Order/BallSpace.lean` | — | — |
| — | A family of sets containing a nest that refines every member — the exact indexing property that makes the nest form as strong as the directed form **at one family** | `Order.HasCofinalNest` | `FormalSystem/ForMathlib/Order/BallSpace.lean` | — | — |
| — | **The reduction**: `S₁` plus a cofinal nest plus nonempty members gives a point common to the whole family. No frame, no relation, no duration type | `Order.sInter_nonempty_of_sphericallyComplete` | `FormalSystem/ForMathlib/Order/BallSpace.lean` | — | `[propext]` |
| `def:frame#Saturation` | **The nest condition `S₁`** over a bare task relation: `Saturation` with `Order.IsNest S` in place of `DirectedFamily S`. The member condition is character-for-character `Saturation`'s, so the two differ in exactly one clause | `FormalSystem.Semantics.TaskFrame.NestSaturation` | `FormalSystem/Semantics/TaskFrame.lean` | — | — |
| `def:frame#Saturation` | **Genus membership, machine-checked**: `NestSaturation` *is* spherical completeness of the ball space of fibers and segments, by `Iff.rfl`. Edit either spelling incompatibly and this stops elaborating | `FormalSystem.Semantics.TaskFrame.nestSaturation_iff_sphericallyComplete` | `FormalSystem/Semantics/TaskFrame.lean` | — | `[propext]` |
| `def:frame#Saturation` | **The ball-space footnote's asserted implication, machine-checked**: `S₁ᵈ → S₁`. The converse is **open**; nothing in this development bears on it | `FormalSystem.Semantics.TaskFrame.nestSaturation_of_saturation` | `FormalSystem/Semantics/TaskFrame.lean` | — | `[propext]` |
| — | `Constraints τ z` contains a nonempty `⊆`-chain refining every member — the one-line instantiation of `Order.HasCofinalNest`. A property of the constraint family, never of the frame, which is exactly why the general form upstreams and this one does not | `FormalSystem.Semantics.PartialHistory.HasCofinalNest` | `FormalSystem/Semantics/Extension/Completion.lean` | — | — |
| — | **The reduction, instantiated**: `S₁`, a cofinal nest and nonempty members give exactly what `lem:step` consumes. Stated as a property of `Constraints τ z` — the frame-level `S₁ → Saturation` is **not** available and must never be stated | `FormalSystem.Semantics.PartialHistory.sInter_constraints_nonempty_of_nestSaturation` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq |
| — | **The carrier discharge**: a countable domain has a cofinal nest, in three regimes — `z` itself a domain time, a one-sided domain, and a straddling domain diagonalised through the running extrema. No hypothesis on `D`, and no `Archimedean`/Hölder route | `FormalSystem.Semantics.PartialHistory.hasCofinalNest_of_countable` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq |
| — | **The headline: the `⇒`-directedness of `def:frame`'s fourth constraint is not *forced*.** Over any history with countably many times — automatic for `ℤ`-time and `ℚ`-time — the nest condition `S₁` buys exactly what `S₁ᵈ` buys at `lem:step`. The directedness is kept on the naturalness criterion, and this is the sharpness result recording the fact | `FormalSystem.Semantics.PartialHistory.sInter_constraints_nonempty_of_countable` | `FormalSystem/Semantics/Extension/Completion.lean` | — | pcq |
| `def:world-history` | The identification's easy direction: every restriction of a possible world is a partial history, at **no** frame constraint and no `[F.IsRegular]` | `FormalSystem.Semantics.PartialHistory.restrict_isPartialHistory` | `FormalSystem/Semantics/PartialHistory.lean` | — | `[propext]` pinned:C14 |
| `def:world-history` | A partial history extended by a possible world **is** that world's restriction to its own domain, on the nose | `FormalSystem.Semantics.PartialHistory.eq_restrict_of_extends` | `FormalSystem/Semantics/PartialHistory.lean` | — | `[propext, Quot.sound]` pinned:C14 |
| `thm:extension` | The identification's hard direction, as a surjection: every partial history is literally `restrict h` for some possible world | `FormalSystem.Semantics.PartialHistory.exists_restrict_eq` | `FormalSystem/Semantics/Extension/Extension.lean` | — | pcq pinned:C14 |
| `thm:extension` | **The surjection carries the order**: whenever `τ ≤ σ`, a *single* possible world restricts onto both | `FormalSystem.Semantics.PartialHistory.exists_worldHistory_restricting_pair` | `FormalSystem/Semantics/Extension/Extension.lean` | — | pcq pinned:C14 |
| `def:world-history` | The free converse half of the order statement: two restrictions of one possible world stand in the extension order exactly as their time sets stand in inclusion | `FormalSystem.Semantics.PartialHistory.restrict_le_restrict_iff` | `FormalSystem/Semantics/PartialHistoryOrder.lean` | — | `[propext]` pinned:C14 |

### The state topology, and frames that satisfy some constraints and not others

For the manuscript-facing view of this section — each element of the task-semantics topology
appendix against the declaration that certifies it, plus the statements the library does **not**
certify — see [`reference/state-topology-appendix-support.md`](reference/state-topology-appendix-support.md).

`def:frame`'s four constraints are frame **conditions** on the general frame structure
`FrameOver`, carried by the class `FrameOver.IsRegular` rather than as fields
(`FormalSystem/Semantics/TaskFrame.lean`, "General frames and the regular class"). Every row below
is a statement that the split makes expressible: it either characterises a constraint, or is about
a frame that violates one.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|---|---|---|---|---|---|
| `app:topology-t1` | The cone-neighbourhood topology `𝒩_F` on a **general** frame's state space is T1 **if and only if** the frame satisfies *Limit* | `FormalSystem.Semantics.FrameOver.t1Space_iff_limit` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq pinned:C14 |
| `app:topology-t1` | The converse of `app:topology-t1` is false for the cone topology `𝒯_F`: on the four-state funnel `𝒯_F` is T1 (indeed discrete) **while *Limit* fails** | `FormalSystem.Semantics.StateTopology.funnel_t1Space_coneTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq pinned:C14 |
| `def:frame#Limit` | *Limit* fails on the four-state funnel: state `2` lies in every positive cone of state `0` | `FormalSystem.Semantics.StateTopology.funnel_not_limit` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq pinned:C14 |
| `def:frame#Limit` | Injectivity at zero, at the constraint it uses: *Limit* alone, with no *Seriality*, *Compositionality* or *Saturation* | `FormalSystem.Semantics.FrameOver.eq_of_taskRel_zero_of_limit` | `FormalSystem/Semantics/TaskFrame.lean` | — | `[propext]` |
| `def:frame#Limit` | Separation of shift-related histories, at the constraint it uses: *Limit* alone. Its converse fails — separation holds on the funnel, where *Limit* does not (`funnel_sep_of_history`) | `FormalSystem.Semantics.ShiftSet.rev_sep_of_limit` | `FormalSystem/Semantics/ShiftSet.lean` | — | `[propext, Quot.sound]` |
| — | A state space that is T1 but **not Hausdorff**: the half-line with two origins, which satisfies all four `def:frame` constraints | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_not_t2Space` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `app:topology-t1` | **Some *task frame* is T1 and not Hausdorff** — the sharp form, on a frame with all four constraints proved rather than on a three-of-four structure | `FormalSystem.Semantics.StateTopology.TwoOrigins.taskFrame_t1_not_t2` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:frame#Saturation` | The half-line with two origins satisfies *Saturation*, by the shadow argument — which is what makes it a task frame and an `FrameOver.IsRegular` instance | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_saturation` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | `𝒩_F` is **strictly** below the final topology of all histories: the hedgehog separates them | `FormalSystem.Semantics.StateTopology.Hedgehog.finalTopology_ne_nbhdTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:frame#Saturation` | The hedgehog satisfies *Saturation*, by the mirrored shadow argument — which upgrades the separation above from a statement about a structure to one about a **task frame** | `FormalSystem.Semantics.StateTopology.Hedgehog.frame_saturation` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | The reusable half of both shadow arguments: a `⊇`-directed family of nonempty sets whose images under a map into a topological space are compact and closed has a common image point. A `DirectedFamily`-shaped wrapper around Mathlib's Cantor-intersection lemma, serving `def:frame`'s *Saturation* clause | `FormalSystem.Semantics.TaskFrame.exists_mem_image_of_directedFamily` | `FormalSystem/Semantics/TaskFrame.lean` | — | pcq |
| — | Its `Set.Icc` specialisation, which is what the three *Saturation* proofs actually call: over a `CompactIccSpace`, a member whose shadow is a closed interval needs no separate compactness or closedness argument | `FormalSystem.Semantics.TaskFrame.exists_mem_image_of_directedFamily_Icc` | `FormalSystem/Semantics/TaskFrame.lean` | — | pcq |
| `def:frame#Saturation` | ***Saturation* is a completeness property.** The two-origin relation transcribed verbatim over `ℚ` keeps *Seriality*, *Compositionality* and *Limit* and **fails *Saturation*** — rational intervals straddling the cut `{q : q² < 2}` have empty intersection. This is why the real witness is over `ℝ` | `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.not_rel_saturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| — | **The rational carrier is not the separator**: it fails *Completion* too, by a coherent family at the times `-(1/2)ⁿ` whose fibre intersection at `0` would have to be `√2`. Over dense time the pinch is general, so no dense-time drift frame separates *Completion* from *Saturation* | `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.not_rel_completion` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| — | ***Completion* holds on the separating frame** — unit-speed drift on `ℚ` over `ℤ`-time — because `ℤ` has nearest times, so no completeness of the carrier is demanded | `FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_completion` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Saturation` | **The separation.** The same frame **fails *Saturation***, although *Seriality*, *Compositionality*, *Limit* and *Completion* all hold: fibres and segments are not indexed by times, so a `⊇`-directed family of them shrinks onto the cut `{q : q² < 2} \| {q : 2 < q²}`. Hence `Completion → Saturation` is **false** and *Completion* is a **strict** weakening | `FormalSystem.Semantics.StateTopology.SeparatingFrame.not_srel_saturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Saturation` | **Correction of a standing assumption**: the separating frame fails the **nest** condition `S₁`, not merely the directed condition `S₁ᵈ`. So neither existing witness separates the two forms, and the existing sharpness result is about `S₁` as much as about `S₁ᵈ` | `FormalSystem.Semantics.StateTopology.SeparatingFrame.not_srel_nestSaturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Saturation` | The cofinal **nest** inside `straddle` — the intervals `[phi (n+2), nt n]`, decreasing onto the cut at `√2`. Its existence is what makes the separating frame a witness against `S₁` and not merely against `S₁ᵈ` | `FormalSystem.Semantics.StateTopology.SeparatingFrame.nest` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | — |
| `def:frame#Saturation` | The rational carrier fails the nest condition too, making the correction uniform across both witnesses | `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.not_rel_nestSaturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| — | The Newton-minus-gap sequence stays strictly below the cut: `(nt n - (1/2)ⁿ)² < 2` | `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.phi_sq_lt_two` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| — | From index `2` on, `phi` clears `1` — the load-bearing `1 ≤ a` conjunct of `straddle`, which `phi 0` and `phi 1` both fail. This is why the nest is indexed `phi (n + 2)` | `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.one_le_phi_add_two` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| — | **The fibers-only weakening of *Saturation***, stated for the sharpness fact below: `Saturation` with its member condition narrowed to fibers alone | `FormalSystem.Semantics.StateTopology.SeparatingFrame.FiberSaturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | — |
| — | **Segments are load bearing.** The separating frame satisfies the fibers-only condition while failing *Saturation*, so dropping segments from `def:frame`'s fourth constraint would weaken it strictly — the fibers-only candidate is closed | `FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_fiberSaturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| `def:frame#Seriality` | **The independence witness for *Seriality***: the void frame — the empty task relation on `Bool` over ℤ-time — satisfies *Compositionality*, *Limit* and *Saturation* and fails *Seriality*, since no state has a successor | `FormalSystem.Semantics.StateTopology.voidFrame_not_serial` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | `[propext, Quot.sound]` pinned:C14 |
| `def:frame#Compositionality` | *Compositionality* holds vacuously on the void frame | `FormalSystem.Semantics.StateTopology.voidFrame_compositional` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | `[propext, Quot.sound]` pinned:C14 |
| `def:frame#Limit` | *Limit* holds vacuously on the void frame | `FormalSystem.Semantics.StateTopology.voidFrame_limit` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `cor:saturation-finite` | *Saturation* on the void frame, free from the finite carrier | `FormalSystem.Semantics.StateTopology.voidFrame_saturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Compositionality` | **The independence witness for *Compositionality***: the bump frame — identity at `0`, everything at `±1`, identity from `\|d\| ≥ 2` — satisfies *Seriality*, *Limit* and *Saturation*, yet `ff ⇒₁ tt` and `tt ⇒₁ tt` while `ff ⇏₂ tt`. **With this the independence matrix for all four constraints is complete** | `FormalSystem.Semantics.StateTopology.bumpFrame_not_compositional` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Seriality` | *Seriality* on the bump frame: every state is its own successor and predecessor at every `x ≥ 0` | `FormalSystem.Semantics.StateTopology.bumpFrame_serial` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame#Limit` | *Limit* on the bump frame, free from `limit_of_succOrder` over ℤ | `FormalSystem.Semantics.StateTopology.bumpFrame_limit` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `cor:saturation-finite` | *Saturation* on the bump frame, free from the finite carrier | `FormalSystem.Semantics.StateTopology.bumpFrame_saturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq pinned:C14 |
| `def:frame` | **The four constraints are pairwise independent, as one theorem.** For each of *Compositionality*, *Seriality*, *Limit* and *Saturation*, a carrier and a relation over `ℤ` satisfying the other three and refuting it. The four rows above establish the same four facts individually, at scattered witnesses and over three different duration orders; this is the tree's single aggregate statement of them, uniform over `ℤ`, and the only form in which "the four-clause frame-condition row cannot be compressed to three" is citable as a theorem. Bounds the **clause** count of `def:frame`, never the count of Lean **definitions** a transcription audit must read — see [`reference/transcription-audit-surface.md`](reference/transcription-audit-surface.md) | `FormalSystem.Semantics.FrameConstraintIndependence.constraints_pairwise_independent` | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | — | pcq |
| `def:frame#Seriality` | *Seriality* refuted at the empty relation on `Bool` over `ℤ`, stated at a bare duration with no topology import. The same relation as `StateTopology.voidRel`; restated so the aggregate above is reachable from the `Semantics.lean` aggregator, which the topology-carrying witnesses deliberately are not | `FormalSystem.Semantics.FrameConstraintIndependence.emptyRel_not_serial` | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | — | `[propext]` |
| `def:frame#Limit` | ***Limit* refuted over discrete time.** `false` lies in every positive cone of `true` under the total relation on `Bool`. This row is what the tree did not already have: the four-state funnel's `funnel_not_limit` carries a `[DenselyOrdered ↑D]` binder, so nothing previously refuted *Limit* over the duration order the certificate uses | `FormalSystem.Semantics.FrameConstraintIndependence.totalRel_not_limit` | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | — | `[propext]` |
| `def:frame#Saturation` | *Saturation* refuted at upward rays on `ℤ`: the duration-`1` fibres form a `⊇`-directed family of nonempty rays with empty intersection. A **recession** failure, unbounded family over a complete carrier — not the completeness failure of `RationalTwoOrigins.not_rel_saturation`, which is a bounded family over a carrier missing its limit point | `FormalSystem.Semantics.FrameConstraintIndependence.rayRel_not_saturation` | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | — | pcq |
| `def:frame#Compositionality` | *Compositionality* refuted at a functional but non-additive shift on `ℤ`, `u = w + drift x` with `drift` the identity except at `1`: two unit steps compose to `w + 10` while the duration-`2` step gives `w + 2`. A second witness for the row `StateTopology.bumpFrame_not_compositional` already holds, breaking the law by non-additivity rather than by a clause boundary | `FormalSystem.Semantics.FrameConstraintIndependence.driftRel_not_compositional` | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | — | pcq |
| `app:topology-r0` | **R0 can fail without *Limit***, so R0 is exactly as fragile as T1: the ghost-ray frame is *Serial* and *Compositional*, fails *Limit*, and its state topology is not R0 | `FormalSystem.Semantics.StateTopology.GhostRay.frame_not_r0Space` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| `def:frame#Limit` | *Limit* fails on the ghost-ray frame — a corollary of the R0 failure, since *Limit* would force R0 | `FormalSystem.Semantics.StateTopology.GhostRay.frame_not_limit` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | — | pcq |
| — | **A single surjective open history collapses the final topology of all histories onto `𝒩_F`** — the converse of `finalTopology_le_nbhdTopology`, with no relation-level hypothesis | `FormalSystem.Semantics.TaskFrame.finalTopology_eq_of_surjective_open_history` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| — | On the **metric frame** — carrier `ℝ`, a task of duration `y` moving at speed at most `c` — `𝒩_F` **is** the final topology of all histories. So the hedgehog's separation of the two is a feature of branching, not of the cone construction | `FormalSystem.Semantics.StateTopology.MetricFrame.finalTopology_eq_nbhdTopology` | `FormalSystem/Semantics/StateTopology/MetricFrame.lean` | — | pcq |
| `def:frame` | The metric frame is **regular** at every positive speed — all four constraints, *Saturation* by the degenerate shadow argument (the identity is its own shadow map) | `FormalSystem.Semantics.StateTopology.MetricFrame.isRegular` | `FormalSystem/Semantics/StateTopology/MetricFrame.lean` | — | pcq |
| `def:task-topology` | The revised definition's one-clause Open Sets criterion over a bare relation: `O` is open exactly when every `w ∈ O` has a positive cone `(w)_x ⊆ O` | `FormalSystem.Semantics.TaskFrame.nbhdTopology_isOpen_iff` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:task-topology` | The same criterion at a frame, so that no consumer unfolds the `stateTopology` instance | `FormalSystem.Semantics.FrameOver.isOpen_iff` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:task-topology` | The paper's *T1* clause `cl{w} = {w}` against Mathlib's `T1Space`, so the closure formulation and the class agree by a checked fact | `FormalSystem.Semantics.TaskFrame.t1Space_iff_closure_singleton` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-t1` | `𝒩_F` is T1 **if and only if** the relation satisfies *Limit*, over a bare relation, with no frame constraint consumed in either direction | `FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_limit` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-t1` | The same biconditional against the paper's **equality** form `⋂_{x>0} (w)_x = {w}`, under *Seriality* alone — `app:topology-t1` exactly as the revised appendix states it | `FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-t1` | The converse for the subbasis topology `𝒯_F`, which is **not** free: it needs *NoOneWay* on top of T1, and the gap is exactly the one-way instantaneous pairs | `FormalSystem.Semantics.TaskFrame.limit_of_t1Space_coneTopology` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:frame#Limit` | The paper's equality form of *Limit* is `𝒩_F` T1 together with `w ∈ (w)_x`, which is why `TaskFrame.Limit` transcribes only the `⊆` inclusion | `FormalSystem.Semantics.TaskFrame.limit_eq_iff` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:frame#Limit` | The paper's equality form `⋂_{x>0} (w)_x = {w}` at a regular frame | `FormalSystem.Semantics.FrameOver.iInter_cone_eq_singleton` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-r0` | `𝒩_F` is R0 under *Limit*, over a bare relation | `FormalSystem.Semantics.TaskFrame.r0Space_nbhdTopology_of_limit` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-r0` | `app:topology-r0` for the state topology at a regular frame, **named** — previously available only as an anonymous `example`, which no citation could reach | `FormalSystem.Semantics.FrameOver.r0Space_stateTopology` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `app:topology-r0` | The paper's *R0* clause `w ∈ cl{u} ↔ u ∈ cl{w}` against Mathlib's `R0Space`, via `specializes_iff_mem_closure` | `FormalSystem.Semantics.TaskFrame.r0Space_iff_mem_closure_comm` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| — | **Every history is continuous** from the order topology on the duration carrier into `𝒩_F`, with no frame constraint consumed — the history-continuity lemma the revised appendix adds | `FormalSystem.Semantics.TaskFrame.continuous_nbhdTopology_of_history` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| — | The same at a frame; the order topology on the carrier is an explicit binder, never a global instance | `FormalSystem.Semantics.FrameOver.continuous_of_history` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| — | `𝒯_F` is **finer** than `𝒩_F` (Mathlib's order: `coneTopology R ≤ nbhdTopology R`) given only that every state loops at duration zero; the two are comparable, not incomparable | `FormalSystem.Semantics.TaskFrame.coneTopology_le_nbhdTopology` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:frame#Saturation` | The four-state funnel satisfies *Saturation*, so its failure of *Limit* is a three-of-four profile rather than a degenerate one | `FormalSystem.Semantics.StateTopology.funnel_saturation` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | The funnel's one-way instantaneous pair: `0 ⇒_y 2` for arbitrarily small `y ≥ 0` and never `2 ⇒_y 0` — the configuration `limit_of_t1Space_coneTopology` says must be present whenever `𝒯_F` is T1 and *Limit* fails | `FormalSystem.Semantics.StateTopology.funnel_one_way_pair` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | *Triangle*, the mixed-sign shortcut condition, **fails** on the half-line with two origins, so it is sufficient but **not necessary** for cone-openness | `FormalSystem.Semantics.StateTopology.TwoOrigins.not_triangle` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | Cone membership on the two-origin frame: an origin lies in a cone at an origin exactly when they are the same origin | `FormalSystem.Semantics.StateTopology.TwoOrigins.o_mem_cone_o` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | Cone membership on the two-origin frame: a ray point lies in a cone at an origin exactly when it is nearer than the radius | `FormalSystem.Semantics.StateTopology.TwoOrigins.p_mem_cone_o` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | Cone membership on the two-origin frame: an origin lies in a cone at a ray point exactly when the ray point is nearer than the radius — for **both** origins, which is the non-Hausdorffness | `FormalSystem.Semantics.StateTopology.TwoOrigins.o_mem_cone_p` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | Cone membership on the two-origin frame: on the ray the cones are Euclidean intervals | `FormalSystem.Semantics.StateTopology.TwoOrigins.p_mem_cone_p` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | Every cone of the two-origin relation is `𝒩_F`-open, with explicit radii `min t (x - t)`, `x - |s - t|` and `x - t` | `FormalSystem.Semantics.StateTopology.TwoOrigins.isOpen_nbhdTopology_cone` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-topology` | `𝒯_F = 𝒩_F` on the two-origin frame, by cone-openness rather than by the shortcut condition, which fails there | `FormalSystem.Semantics.StateTopology.TwoOrigins.coneTopology_eq_nbhdTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | `𝒯_F` is **not Hausdorff** on the two-origin frame either: it coincides with `𝒩_F`, which separates neither origin from the other | `FormalSystem.Semantics.StateTopology.TwoOrigins.not_t2Space_coneTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-topology` | The two topologies coincide on the two-origin frame, as a fact about the **frame** | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_coneTop_eq_stateTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | **Neither** topology on the two-origin frame is Hausdorff — so being T1 and not Hausdorff is a property of the frame, not an artefact of which topology is chosen | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_not_t2Space_coneTop` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | Cone membership at the hedgehog's centre: every positive cone at `c` meets every ray | `FormalSystem.Semantics.StateTopology.Hedgehog.p_mem_cone_c` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | `{c}` is `𝒯_F`-open on the hedgehog: it is a finite intersection of cross-ray cones | `FormalSystem.Semantics.StateTopology.Hedgehog.isOpen_coneTopology_singleton_c` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | `{c}` is **not** `𝒩_F`-open on the hedgehog: every positive cone at `c` escapes it along ray `0` | `FormalSystem.Semantics.StateTopology.Hedgehog.not_isOpen_nbhdTopology_singleton_c` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-topology` | `𝒯_F ≠ 𝒩_F` on the hedgehog — the named inequality the two singleton facts bracket | `FormalSystem.Semantics.StateTopology.Hedgehog.coneTopology_ne_nbhdTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-topology` | `𝒯_F` is **strictly finer** than `𝒩_F` on the hedgehog (`coneTopology rel < nbhdTopology rel` in Mathlib's order) | `FormalSystem.Semantics.StateTopology.Hedgehog.coneTopology_lt_nbhdTopology` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | On a frame over `ℝ` whose cones are Euclidean balls, `𝒩_F` is the usual topology — the bridge lemma that keeps a real carrier's two topologies from being confused | `FormalSystem.Semantics.TaskFrame.nbhdTopology_eq_real` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| — | And on such a frame the two topologies coincide | `FormalSystem.Semantics.TaskFrame.coneTopology_eq_nbhdTopology_real` | `FormalSystem/Semantics/StateTopology.lean` | — | pcq |
| `def:frame#Limit` | Over `ℤ`, *Limit* is exactly injectivity at duration zero, and `𝒩_F` is the partition topology of `⇒₀` | `FormalSystem.Semantics.TaskFrame.limit_int_iff` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | Over `ℤ`, `𝒩_F` is discrete exactly when `⇒₀` is trivial — so *Limit*, discreteness and T1 coincide there | `FormalSystem.Semantics.TaskFrame.discreteTopology_nbhdTopology_int_iff` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| `def:task-relation` | The funnel's cone computation: `(w)_x` for every positive `x`, the calculation the footnote's four-state example rests on | `FormalSystem.Semantics.StateTopology.mem_cone_funnelRel` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |
| — | On the funnel each singleton is the intersection of the positive cones at its state, yet *Limit* fails — the subbasis topology is discrete while `𝒩_F` is indiscrete | `FormalSystem.Semantics.StateTopology.funnelRel_singleton_eq_biInter_cone` | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` | — | pcq |

### The translation product

The translation product `F.translationProduct` (`FormalSystem/Semantics/Frames/TranslationProduct.lean`) is a proof device, never an intended model: it shows that no object language sees recurrence at the level of a frame class.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | At every frame class, L-validity over the class equals L-validity over its recurrence-free members: every member is covered by its translation product, which is recurrence-free and in the class | `FormalSystem.Semantics.validIn_iff_recurrenceFree` | `FormalSystem/Semantics/Frames/TranslationProduct.lean` | — | pcq pinned:C14 |
| — | The same for L⁺: `PlusValidIn fc φ ↔ PlusValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ` | `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree` | `FormalSystem/Semantics/Frames/TranslationProduct.lean` | — | pcq pinned:C14 |
| — | The same for L⋆, at every register vector: the store/recall clauses are inert under the projection | `FormalSystem.Semantics.starValidIn_iff_recurrenceFree` | `FormalSystem/Semantics/Frames/TranslationProduct.lean` | — | pcq pinned:C14 |

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
| — | Soundness engine: `Ax ⊆ TMFrag fc → TM⁻ + Ax ⊆ TMFrag fc` | `FormalSystem.Metalogic.Conservativity.minusExt_le_tmFrag` | `FormalSystem/Metalogic/Conservativity/MinusExt.lean` | — | pcq pinned:C14 |
| — | Soundness of `TM⁻ + (Sp)` relative to `TMFrag` (Σ_Base row) | `FormalSystem.Metalogic.Conservativity.minusExt_sigmaBase_le_tmFrag` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | Base | pcq pinned:C14 |
| — | Soundness of `TM⁻_z + Z1` relative to `TMFrag` (Σ_ZTime row) | `FormalSystem.Metalogic.Conservativity.minusExt_sigmaZTime_le_tmFrag` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | ZTime | pcq pinned:C14 |
| — | `TM⁻ ⊊ TM⁻ + (Sp)`, witnessed by `Sp p p` | `FormalSystem.Metalogic.Conservativity.tmMinus_lt_minusExt_sigmaBase` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | Base | pcq pinned:C14 |
| — | `TM⁻_z ⊊ TM⁻_z + Z1`, witnessed by `Z1 p` | `FormalSystem.Metalogic.Conservativity.tmMinus_lt_minusExt_sigmaZTime` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | ZTime | pcq pinned:C14 |
| — | Fragment theorems are chain-bundle valid | `FormalSystem.Metalogic.Conservativity.tmFrag_chainValidIn` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | — | pcq pinned:C14 |
| — | Conditional completeness: `TM⁻ + Ax = TMFrag fc` given `ChainComplete fc Ax` (discharged at `.Dense` by `chainComplete_dense`) | `FormalSystem.Metalogic.Conservativity.minusExt_iff_tmFrag_of_chainComplete` | `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` | — | pcq pinned:C14 |
| — | Chain-completeness of TM⁻_d: `ChainComplete FrameClass.Dense ∅`, by an L⁻ canonical model and the Burgess §2.5 ℚ-chronicle construction | `FormalSystem.Metalogic.Conservativity.chainComplete_dense` | `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` | Dense | pcq pinned:C14 |
| — | `TM⁻_d = TMFrag .Dense` unconditionally | `FormalSystem.Metalogic.Conservativity.minusExt_iff_tmFrag_dense` | `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` | Dense | pcq pinned:C14 |
| — | Task-frame validity implies chain-bundle validity, at every class | `FormalSystem.Metalogic.Conservativity.minusValidIn_chainValidIn` | `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` | — | pcq pinned:C14 |
| — | `TMMinusComplete FrameClass.Dense`: TM⁻_d is weakly complete over the dense task frames | `FormalSystem.Metalogic.Conservativity.tmMinusComplete_dense` | `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` | Dense | pcq pinned:C14 |
| — | `Forward FrameClass.Dense`: forward proof-theoretic conservativity of TM over TM⁻ at `.Dense` | `FormalSystem.Metalogic.Conservativity.forward_dense` | `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` | Dense | pcq pinned:C14 |
| — | `⊢⁻ □χ → G□χ`, `□`-globality (future) | `FormalSystem.Metalogic.Conservativity.boxGlobalFuture` | `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` | — | `[propext]` pinned:C14 |
| — | `⊢⁻ □χ → H□χ`, `□`-globality (past, by TR) | `FormalSystem.Metalogic.Conservativity.boxGlobalPast` | `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` | — | `[propext]` pinned:C14 |
| — | `⊢⁻ ¬□χ → G¬□χ`, negated `□`-globality (future) | `FormalSystem.Metalogic.Conservativity.notBoxGlobalFuture` | `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` | — | `[propext]` pinned:C14 |
| — | `⊢⁻ ¬□χ → H¬□χ`, negated `□`-globality (past, by TR) | `FormalSystem.Metalogic.Conservativity.notBoxGlobalPast` | `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` | — | `[propext]` pinned:C14 |
| — | Proof-theoretic conservativity of TM⁺ over TM, both directions, all four classes | `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` | — | pcq pinned:C14 |
| — | Proof-theoretic conservativity of TM⁺ + *Determined* over TM, all four classes | `FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Deterministic/Completeness.lean` | — | pcq |
| — | Soundness of TM⁺ at every frame class | `FormalSystem.Metalogic.Conservativity.plus_soundness_validIn` | `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean` | — | pcq pinned:C14 |
| — | Semantic conservativity of L⁺ over L | `FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff` | `FormalSystem/PlusLanguage/PlusValidity.lean` | — | `[propext]` pinned:C14 |

### TM⋆ over L⋆ — the store/recall language

TM⋆ is TM⁺ plus the manuscript's time registers `↑ⁱ`/`↓ⁱ` (`FormalSystem/StarLanguage/`). Its
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
| — | Derivation trees for TM⋆: the same seven rules as TM⁺ and TM, with `StarAxiom` in the `axiom` rule | `FormalSystem.StarLanguage.StarDerivationTree` | `FormalSystem/StarLanguage/Derivation.lean` | — | `[propext]` pinned:C14 |
| — | Soundness of TM⋆ at every frame class | `FormalSystem.Metalogic.Conservativity.star_soundness_validIn` | `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` | — | pcq pinned:C14 |
| — | Proof-theoretic conservativity of TM⋆ over TM, both directions, all four classes | `FormalSystem.Metalogic.Conservativity.starDerivable_ofFormula_iff` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |
| — | Conservativity of TM⋆ over TM⁺, **conditional** on general TM⁺ completeness at that class | `FormalSystem.Metalogic.Conservativity.starConservative_of_plusComplete` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |
| — | The unconditional contrapositive: a TM⋆/TM⁺ separating witness is a witness of TM⁺ incompleteness | `FormalSystem.Metalogic.Conservativity.plusIncomplete_of_starNonconservative` | `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | — | pcq pinned:C14 |

### L^▷ — the open-future and open-past language

L^▷ is L⁺ plus the manuscript's open-future modal `▷` and open-past modal `◁`
(`FormalSystem/OpenLanguage/`). It is **semantic only**: the manuscript supplies no logic for the
restricted modals and none is claimed, so every row below is a validity or a refutation, never a
derivability result. The rows record that `▷`, not the stability modal `⊡`, is the operator of
this semantics that answers to Ockhamist historical necessity.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | The Ockhamist principle `Pα → ▷P▷̂α` is valid over every task frame | `FormalSystem.OpenLanguage.hnOpen_openValid` | `FormalSystem/OpenLanguage/OpenOckhamist.lean` | Base | pcq pinned:C14 |
| — | Its stability transposition `Pp → ⊡P⟐p` is refuted on `sinkFrame`, a three-state integer-time frame satisfying all four frame axioms | `FormalSystem.OpenLanguage.hnStab_refuted_sinkFrame` | `FormalSystem/OpenLanguage/OpenOckhamist.lean` | — | pcq pinned:C14 |
| — | L^▷ validity is closed under time reflection, which exchanges `▷` with `◁` and fixes `⊡` | `FormalSystem.OpenLanguage.openValid_reflectTime` | `FormalSystem/OpenLanguage/OpenReversal.lean` | Base | pcq pinned:C14 |
| — | The open-past mirror of the Ockhamist principle is valid | `FormalSystem.OpenLanguage.hnOpenMirror_openValid` | `FormalSystem/OpenLanguage/OpenOckhamist.lean` | Base | pcq pinned:C14 |

### The hybrid state language — state registers and the same-state modality

The hybrid state language is L⁺ plus the same-state modality `[≡]`, state registers and the state
binder `↓` (`FormalSystem/HybridLanguage/`). A state nominal is a free register. It is **semantic
only**: every row below is an invariance, a validity on a frame or a refutation, never a
derivability result. The rows record what makes recurrence of world states visible: `[≡]` does
not, one state register does. A history-lifting morphism and recurrence-freeness are those of
`FormalSystem/Semantics/HistoryMorphism.lean`.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Truth of every register-free formula, so of every L⁺ formula and every `[≡]φ`, is invariant along any history-lifting morphism | `FormalSystem.HybridLanguage.regFree_invariance` | `FormalSystem/HybridLanguage/HybridInvariance.lean` | — | [propext, Quot.sound] pinned:C14 |
| — | The recurrence formula `¬(i ∧ (P i ∨ F i))` is valid on a frame iff no world history of the frame visits a world state twice | `FormalSystem.HybridLanguage.recF_defines` | `FormalSystem/HybridLanguage/HybridRecurrence.lean` | — | pcq pinned:C14 |
| — | The transposition formula `¬(E(i ∧ F j) ∧ E(j ∧ F i))` is valid on a frame iff the frame is recurrence-free: any transposition forces a recurrence | `FormalSystem.HybridLanguage.transF_defines` | `FormalSystem/HybridLanguage/HybridTransposition.lean` | — | pcq pinned:C14 |

### The propositional-quantifier language

The propositional-quantifier language is the base language plus `∀p`, evaluated relative to a
family of admissible propositions, sets of world states (`FormalSystem/QuantLanguage/`). It is
**semantic only** and has no validity layer: every row is a frame-level result. The rows record
the contrast the admissible family exists to state: quantifiers over the lifted propositions see
no recurrence, quantifiers over every set of world states do.

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | When `∀p` ranges over the preimages of state sets along a history-lifting morphism, truth at the pulled-back model equals standard truth at the image history | `FormalSystem.QuantLanguage.lifted_invariance` | `FormalSystem/QuantLanguage/QuantInvariance.lean` | — | [propext, Quot.sound] pinned:C14 |
| — | Under the standard semantics `∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))` is valid on a frame iff the frame is recurrence-free | `FormalSystem.QuantLanguage.qRec_defines` | `FormalSystem/QuantLanguage/QuantRecurrence.lean` | — | pcq pinned:C14 |
| — | Standard quantifier truth is not invariant along a history-lifting morphism from a recurrence-free frame onto a frame with recurrence | `FormalSystem.QuantLanguage.standard_not_invariant` | `FormalSystem/QuantLanguage/QuantRecurrence.lean` | — | pcq pinned:C14 |

### Base-language soundness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | Soundness of TM⁻ against the native `MinusTruthAt` semantics | `FormalSystem.Metalogic.minus_soundness` | `FormalSystem/MinusLanguage/Soundness.lean` | Base | pcq pinned:C14 |
| — | TM⁻ soundness over the dense class | `FormalSystem.Metalogic.minus_soundness_dense` | `FormalSystem/MinusLanguage/Soundness.lean` | Dense | pcq pinned:C14 |
| — | TM⁻ soundness over ℤ-time | `FormalSystem.Metalogic.minus_soundness_ztime` | `FormalSystem/MinusLanguage/Soundness.lean` | ZTime | pcq pinned:C14 |
| — | TM⁻ soundness over the dense Dedekind-complete class | `FormalSystem.Metalogic.minus_soundness_rtime` | `FormalSystem/MinusLanguage/Soundness.lean` | RTime | pcq pinned:C14 |
| — | Consistency of TM⁻: `⊬ ⊥` | `FormalSystem.Metalogic.minus_not_derivable_nil_bot` | `FormalSystem/MinusLanguage/Soundness.lean` | Base | pcq pinned:C14 |

### Expressiveness

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|-------------|-----------|-----------|------|-------------|--------|
| — | `{U, S}` is expressively complete for Prior structures relative to monadic FO | `FormalSystem.Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness` | `FormalSystem/Metalogic/Expressiveness/Kamp/KampPrior.lean` | — | pcq pinned:C14 |
| — | The load-bearing corollary consumed by the live completeness chain | `FormalSystem.Metalogic.Expressiveness.uSExpressivelyCompleteOverPrior` | `FormalSystem/Metalogic/Expressiveness/PriorExpressiveness.lean` | — | pcq pinned:C14 |

## Statuses that are refutations, not gaps, and one status that is a gap

Three of the rows above are negative results, and they are easy to misread as unfinished work:

- **Strong completeness at `ZTime` and `RTime` is machine-refuted**, not open.
  `notStrongCompletenessZTime` and `notStrongCompletenessRTime` settle both negatively, which is
  why only the weak forms appear for those two classes.
- **Forward proof-theoretic conservativity of TM over TM⁻ is refuted at `Base` and `ZTime`**,
  proved at `Dense` (`forward_dense`, above), and open at `RTime`. Both refutations are
  machine-checked:
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
  for non-conservativity is, verbatim, a witness of TM⁺ incompleteness. At Base the hypothesis of
  the first is now **refuted** (`plus_incomplete_base`), so that conditional is vacuous there;
  this does *not* decide conservativity at Base, since incompleteness yields no separating
  witness. At Dense, ZTime and RTime the hypothesis is still open, as is completeness of any
  extension of the TM⁺ axiom set at every class.

## Related documentation

- [`README.md`](../README.md) — project overview and the `## Verifying the main theorems` recipe
- [`FormalSystem/Metalogic/README.md`](../FormalSystem/Metalogic/README.md) — the directory's
  generated inventory and the three completeness routes
- [`FormalSystem/Metalogic.lean`](../FormalSystem/Metalogic.lean) — the module docstring, whose
  every SORRY-FREE claim is pinned by C2 or C14
- [`docs/reference/paper-definitions-of-record.md`](reference/paper-definitions-of-record.md) — the pinned
  paper anchors C15 resolves against

## Tags

theorem-index · soundness · completeness · compactness · non-compactness · decidability · conservativity · correspondence · expressiveness
