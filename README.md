# A Bimodal Logic for Tense and Modality

[![CI](https://github.com/benbrastmckie/ProofChecker/actions/workflows/ci.yml/badge.svg)](https://github.com/benbrastmckie/ProofChecker/actions/workflows/ci.yml)

This repository implements the **bimodal fragment** of the [Logos](https://logos-labs.ai/) in Lean 4, establishing soundness and completeness for a logic designed for reasoning about future contingency in non-deterministic dynamical systems. The **task semantics** evaluates formulas at both a world-history and time, where world-histories are functions from times to world-states constrained by the task relation which encodes the possible transitions between world-states over a duration of time.

Whereas dynamical systems theory provides mathematical resources for modeling the evolution of both deterministic and non-deterministic systems, a bimodal logic with tense and modal operators provides inferential resources for conducting verified reasoning about such systems. By encoding the constraints on possible transitions into the logical framework itself, one can draw fast and principled inferences about past and future contingency despite incomplete information.

The repository implements the syntax, task semantics, proof theory, and metalogic for the _Bimodal Logic of Tense and Modality_ (TM) which combines S5 modal operators with the Since/Until linear tense operators.

**Paper**: ["The Construction of Possible Worlds"](https://benbrastmckie.com/publications/possible-worlds.pdf) (Brast-McKie, forthcoming in JPL) — compositional semantics for bimodal logics grounded in non-deterministic dynamical systems

**Specification**: [BimodalReference.pdf](latex/BimodalReference.pdf) — complete axiom schemas and proof-theoretic documentation (outdated)

**Demo**: [BimodalProofs.lean](FormalSystem/Examples/BimodalProofs.lean) — sorry-free demonstration proofs

| Metric | Count |
|--------|-------|
| Lean files | 539 |
| Lines of code | ~170,898 |
| Comment lines | ~96,290 |

To get current numbers (excludes `.lake` dependencies and `Boneyard/`), run:

```bash
cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .
```

---

## Operators

The logic uses 5 primitive connectives. All other operators are derived.

### Primitive

| Symbol | Lean Constructor | Reading |
|--------|-----------------|---------|
| `⊥` | `bot` | falsum |
| `φ → ψ` | `imp φ ψ` | material conditional |
| `□φ` | `box φ` | necessity ("necessarily φ") |
| `U(φ,ψ)` | `untl φ ψ` | "ψ until φ" |
| `S(φ,ψ)` | `snce φ ψ` | "ψ since φ" |

### Derived

| Symbol | Definition | Reading |
|--------|-----------|---------|
| `¬φ` | `φ → ⊥` | negation |
| `φ ∧ ψ` | `¬(φ → ¬ψ)` | conjunction |
| `φ ∨ ψ` | `¬φ → ψ` | disjunction |
| `◇φ` | `¬□¬φ` | possibility |
| `Fφ` | `U(φ, ¬⊥)` | "eventually φ" |
| `Pφ` | `S(φ, ¬⊥)` | "previously φ" |
| `Gφ` | `¬F¬φ` | "it is always going to be φ" |
| `Hφ` | `¬P¬φ` | "it always has been φ" |
| `△φ` | `Hφ ∧ φ ∧ Gφ` | "always φ" |
| `▽φ` | `¬△¬φ` | "sometimes φ" |
| `Xφ` | `U(φ, ⊥)` | "at the next moment φ" |
| `Yφ` | `S(φ, ⊥)` | "at the previous moment φ" |

---

## Task Semantics

A **task frame** `F = (W, D, R)` consists of a set `W` of world-states, a totally ordered commutative group `D` of durations, and a **task relation** `R : W → D → W → Prop` satisfying three constraints: *nullity* (each world-state transitions to itself in zero time), *compositionality* (accessibility composes forward across durations), and *reflection* (if `w ⇒_x u` then `u ⇒_{-x} w`).

A **world-history** `τ` in a task frame `F` is a function `τ : X → W` from a convex subset `X ⊆ D` to world states that respects the task relation: for all times `x, y ∈ X` with `x ≤ y`, we have `τ(x) ⇒_{y-x} τ(y)`.

A **task model** `M = (F, I)` extends a task frame `F` with an interpretation function `I : W → Atom → Prop` that assigns truth values to sentence letters `Atom := {p_i : i ∈ ℕ}` at each world state. Truth is evaluated relative to a model `M`, a world-history `τ`, and a time `x`:

- `M, τ, x ⊨ p_i` iff `x ∈ dom(τ)` and `I(τ(x), p_i)`
- `M, τ, x ⊨ ⊥` never
- `M, τ, x ⊨ φ → ψ` iff `M, τ, x ⊭ φ` or `M, τ, x ⊨ ψ`
- `M, τ, x ⊨ □φ` iff `M, σ, x ⊨ φ` for all world-histories `σ`
- `M, τ, x ⊨ U(φ,ψ)` iff there exists `y > x` with `M, τ, y ⊨ φ` and `M, τ, z ⊨ ψ` for all `z` with `x < z < y`
- `M, τ, x ⊨ S(φ,ψ)` iff there exists `y < x` with `M, τ, y ⊨ φ` and `M, τ, z ⊨ ψ` for all `z` with `y < z < x`

Relative to a world-history, any duration `x` may be referred to as the *time* after `x` duration from the origin (the additive unit `0` in `D`) in that world-history.

The task semantics is developed in ["The Construction of Possible Worlds"](https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf) (Brast-McKie, 2025), providing resources for modeling non-deterministic dynamical systems.

---

## Project Structure

```
.                                 # repository root
├── lakefile.lean                 # two libraries: FormalSystem (default target), BimodalTest
├── FormalSystem.lean             # Lake root module for the FormalSystem library
├── FormalSystem/                 # TM bimodal logic library (413 live .lean files)
│   ├── FormalSystem.lean         # library aggregator
│   ├── BaseLanguage/             # shared base-language definitions
│   ├── Syntax/                   # Formula types, atoms, contexts
│   ├── ProofSystem/              # Axioms (45 constructors, nine layers), derivation trees
│   ├── Semantics/                # TaskFrame, WorldHistory, TaskModel, validity predicates
│   ├── FrameConditions/          # Dense/Discrete/Dedekind frame classes and their soundness
│   ├── Metalogic/                # Soundness, completeness, decidability
│   │   ├── Core/                 # MCS theory, deduction theorem
│   │   ├── Bundle/               # BFMCS construction
│   │   ├── BXCanonical/          # BX chronicle construction — the wired completeness entry point
│   │   ├── WeakCanonical/        # Reynolds/Doets pipeline (19 modules, 8 subdirectories)
│   │   ├── Algebraic/            # Boolean/ultrafilter infrastructure (FlowFrame, Lindenbaum quotient)
│   │   ├── Decidability/         # Tableau procedure with proof extraction
│   │   ├── Independence/         # axiom-independence results
│   │   └── SoundnessLemmas/      # per-axiom soundness lemmas
│   ├── Theorems/                 # Derived theorems (perpetuity, combinators, propositional)
│   ├── Automation/               # Proof search tactics & training data pipeline
│   ├── Examples/                 # Pedagogical examples
│   └── Boneyard/                 # ARCHIVE — 156 archived .lean files, excluded from the live build
├── Tests/BimodalTest/            # Test suite (the BimodalTest library)
├── scripts/                      # Repository invariant checks and tooling
└── docs/                         # Repository documentation
```

`Metalogic/WeakCanonical/` is the largest subtree: 19 loose modules and 8 subdirectories. Besides
the Reynolds/Doets discrete pipeline it carries the Dedekind/real route — `DenseModelSurgery/`
(9 files) and `RealModel/` (7 files) — and `GroupModel/` (6 files), which hosts the discharged
`countermodel_discrete` at the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`. `Kamp/` (116 files) is
the Kamp-style expressiveness development.

---

## Installation

**Requirements**: Lean 4 v4.33.0-rc1 and Lake (included with Lean).

```bash
# Install elan (Lean version manager)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Clone and build (first build downloads Mathlib cache, ~30 minutes)
git clone https://github.com/benbrastmckie/ProofChecker.git
cd ProofChecker
lake build
```

For detailed setup instructions, see [Installation Guide](docs/installation/BASIC_INSTALLATION.md).

---

## Metalogical Results

The metalogic is organized around a base axiom system with three extensions: Dense, Discrete, and Dedekind. Every flagship soundness and completeness result below is `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`. Weak completeness and finite-context consequence completeness are proven for **all four** frame classes — Base, Dense, Discrete, and Dedekind.

**Strong completeness** is a separate and weaker-established matter. The repository reserves the term for consequence from a possibly-infinite premise set `Γ : Set Formula`; the results above are *finite*-context (`Context` is `List Formula`, so every context here is finite, and each such result is inter-derivable with the corresponding weak form through the deduction theorem). The infinitary statement has three distinct statuses across the four classes, which must not be collapsed into one:

- **Discrete** — **refuted**. `strongCompletenessDiscrete_refuted` and its companion `discrete_consequence_not_compact` (`Metalogic/DiscreteNonCompactness.lean`) settle it negatively.
- **Base** and **Dense** — **open**. Neither proved nor refuted; `CompactBase`/`StrongCompletenessBase` and `CompactDense`/`StrongCompletenessDense` (`Metalogic/SetConsequence.lean`) name the obligations.
- **Dedekind** — **not stated**, and unavailable on the primary source's own terms. Reynolds 1992 Theorem 7 is weak-only, and this tree contains no `CompactDedekind` definition and no refuting theorem, so the class is *unproved* rather than refuted.

Soundness and completeness for the Dedekind class are both stated against the *dense* Dedekind validity predicate `ValidDedekindDense`, not the density-free `ValidDedekind`: `density` and `dense_indicator` are admissible in a Dedekind derivation and both are false on ℤ (`FormalSystem/ProofSystem/Axioms.lean`).

```mermaid
graph TD
    B("<b>Base</b><br/>AddCommGroup<br/>LinearOrder · Nontrivial<br/>NoMaxOrder · NoMinOrder<br/>37 axioms<br/>Sound ✓ · Complete ✓")
    D("<b>Dense</b><br/>+ DenselyOrdered<br/>Base + 2 axioms = 39<br/>Sound ✓ · Complete ✓")
    C("<b>Dedekind</b><br/>+ DedekindComplete<br/>Dense + 3 axioms = 42<br/>Sound ✓ · Complete ✓")
    Z("<b>Discrete</b><br/>+ SuccOrder · PredOrder<br/>+ IsSuccArchimedean<br/>Base + 3 axioms = 40<br/>Sound ✓ · Complete ✓")

    B --> D
    D --> C
    B --> Z
```

### Axiom Systems

| System | Axioms | Additional Axioms | Standard Model | Soundness | Completeness |
|--------|--------|-------------------|----------------|-----------|--------------|
| **Base** | 37 | seriality built in (`⊤ → F⊤`, `⊤ → P⊤`) | — | `soundness` | `completeness` |
| **Discrete** | 40 | `Fφ → U(φ,¬φ)`, `Pφ → S(φ,¬φ)`, `G(Gφ→φ) → (FGφ→Gφ)` | ℤ | `soundness_discrete` | `completeness_discrete` |
| **Dense** | 39 | `GGφ → Gφ` (`density`), `¬U(⊤,⊥)` (`dense_indicator`) | ℚ | `soundness_dense` | `completeness_dense` |
| **Dedekind** | 42 | the two Dense axioms plus Reynolds' `prior_U_gap`, `prior_S_gap`, `sep` | ℝ | `soundness_dedekind` | `completeness_dedekind` |

`inductive Axiom` has **45 constructors in nine layers** (`FormalSystem/ProofSystem/Axioms.lean`). The 37 Base constructors are propositional (4), S5 modal (5), Burgess-Xu temporal (18), an additional Burgess-Xu temporal layer (4), modal-temporal interaction (1), and uniformity (5). The remaining eight are the class-specific extensions: density (2), Prior-UZ/SZ (2) and Z1 (1) for the discrete class, and Reynolds' Dedekind axioms (3).

The Dense and Discrete logics are independent extensions — neither subsumes the other. Dedekind extends **Dense**: `Axiom.minFrameClass` places `density` and `dense_indicator` below `FrameClass.Dedekind`, because Reynolds' own axiomatization of real flow contains them. Discrete and Dedekind are likewise incomparable, and `Dedekind ≰ Dense`.

**A gap worth naming.** `FrameClass.Dedekind` is the paper's **TM⁺_dc** (dense complete / real flow), *not* TM⁺_c. The paper's TM⁺_c is completeness *simpliciter* — no density binder — so its models are exactly `{ℤ, ℝ}` up to order-and-group isomorphism and its theory is `Th(ℤ) ∩ Th(ℝ)`. **No element of `FrameClass` picks that class out.** The two branches are covered separately and exhaustively (the complete-but-discrete branch is exactly `ℤ`, handled by `FrameClass.Discrete`; the dense branch is `FrameClass.Dedekind`), but their intersection is not itself a frame class, and adding one would require an axiom set for `Th(ℤ) ∩ Th(ℝ)` that this tree does not have.

### Decidability

`FormalSystem/Metalogic/Decidability/` implements a tableau decision procedure with proof
extraction. Its status is **one-directional**, and the directory's own history is the reason to
state that precisely: two theorems named `validity_decidable` and
`validity_has_decision_procedure` once stood in `Decidability/Correctness.lean` and are recorded
there as *retired as vacuous*, because their names claimed a decidability result their proofs
(instances of `Classical.em`) did not contain.

- **Landed.** The sound direction of the `isValid`-shaped statement, `isValid φ fc = true → ⊨ φ`:
  `sound_of_isValid` and its corollary `isValid_sound` (`Decidability/Correctness.lean`),
  sorry-free, together with the `isTautology` / `isContradiction` / `isSatisfiable` siblings and
  the frame-class-relativized forms. `decide_sound` (same file) is the corresponding corollary at
  the empty context. On the tableau side, `ruleSound_of_mem_allRulesForFC`
  (`Decidability/Verified/Decidable.lean`) is the rule half of `allClosed → valid`.
- **Open.** The completeness direction, `⊨ φ → isValid φ fc = true`, and therefore
  `valid_iff_allClosed`, the `isValid φ fc = true ↔ ⊨ φ` biconditional, and the `Decidable (⊨ φ)`
  instances for the four frame classes. No `isValid`-shaped biconditional is written before it
  can be proved.
- **Partial.** Proof extraction: `extractProof` (`Decidability/ProofExtraction.lean`) runs five
  strategies in order and returns `.incomplete` once all are exhausted.

---

## Documentation

### Reference

- [Axiom Reference](docs/reference/axiom-reference.md) — complete axiom schemas for all 45 constructors
- [Operator Reference](docs/reference/operators.md) — formal operator definitions
- [Tactic Reference](docs/reference/tactic-reference.md) — custom proof tactics
- [Specification Document](latex/BimodalReference.pdf) — full formal specification

### User Guides

- [Tutorial](docs/user-guide/tutorial.md) — introduction to writing bimodal proofs
- [Contributing](docs/development/CONTRIBUTING.md) — contribution guidelines

### Research

- [Bimodal Logic](docs/research/BIMODAL_LOGIC.md) — theoretical foundations and Logos connection
- [Metalogic README](FormalSystem/Metalogic/README.md) — architecture of the completeness proof

---

## Related Projects

- **[BimodalHarness](https://github.com/benbrastmckie/BimodalHarness)** — AlphaZero-style training harness for neural proof search. Consumes the training datasets generated by this repo's [data pipeline](docs/training/PIPELINE.md) to train value networks, policy networks, and run MCTS proof search over TM derivations.
- **[ModelChecker](https://github.com/benbrastmckie/ModelChecker)** — Python/Z3 countermodel generation for Logos semantics. Together with ProofChecker, this forms the dual verification architecture: ModelChecker searches for countermodels while ProofChecker constructs formal derivations.
- **[Logos Laboratories](https://logos-labs.ai/)** — the broader Logos project of which this bimodal logic is a fragment.

---

## Citation

If you use this project in your research, please cite:

```bibtex
@article{brastmckie2025construction,
  title     = {The Construction of Possible Worlds},
  author    = {Brast-McKie, Benjamin},
  year      = {2026},
  url       = {https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf}
}

@software{proofchecker2025,
  title     = {ProofChecker: Lean 4 Formalization of Bimodal Logic TM},
  author    = {Brast-McKie, Benjamin},
  year      = {2025},
  url       = {https://github.com/benbrastmckie/ProofChecker}
}
```

**Key references**:

- Burgess, J. P. (1982). Axioms for tense logic. I. "Since" and "Until." *Notre Dame Journal of Formal Logic*, 23(4), 367–374.
- Xu, M. (1988). On some U,S-tense logics. *Journal of Philosophical Logic*, 17(2), 181–202.
- Reynolds, M. (1994). Axiomatising U and S over integer time. *Advances in Modal Logic*.
- Venema, Y. (1993). Since and Until. *Advances in Modal Logic*.
- Doets, K. (1987). *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order and Intensional Logic*.
- Gabbay, D., Hodkinson, I., & Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1.
- Blackburn, P., de Rijke, M., & Venema, Y. (2002). *Modal Logic*. Cambridge University Press.

---

## License

This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.
