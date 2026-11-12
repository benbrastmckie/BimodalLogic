/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Enumerate
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import FormalSystem.Semantics.Validity

/-!
# `Decidable (ValidZTime φ)`

The two halves meet here. `Agreement.lean`'s `WitnessFamily.refutes_of_certifies` is the
**soundness** half: a certified family produces a genuine ℤ-time countermodel.
`Compression/Family.lean`'s `exists_witnessFamily_of_not_validZTime` is the **completeness**
half: a ℤ-time countermodel compresses to a certified family meeting three enumeration side
conditions. `Compression/Enumerate.lean`'s `mem_cands_of_bounded` says every such family is on a
computable list, and `Decide.lean`'s `decidableCertifies` decides the four conditions. Composing
them gives a decision procedure.

## The shape of the procedure

`Γ ⊨_ZTime σ` iff **no** candidate on `candsCtx Γ [σ]` certifies a refutation at any time in
`[0, compressionBound Γ [σ]]`; `φ` is ℤ-valid iff the same holds of `cands φ`. Both
quantifiers are over finite objects — a `List` and a `Finset.Icc` — so the right-hand side is
decidable, and `decidable_of_iff` transports that to
`ValidZTime φ`.

## `def`, not `instance`

`decidableValidZTime` and `decidableSemanticConsequenceNil` are `def`s, exactly as the landed
`BiLasso/Assembly.lean` declares `decidableValidZTimeFamily`. A global
`Decidable (ValidZTime φ)` instance would change instance resolution repository-wide and could
slow or loop elaboration in modules that have nothing to do with this one. Callers that want it
can `letI` it locally.

## The complexity, stated honestly

`candsCtx Γ [σ]` is astronomically large — roughly `(2^k)^{3B(1 + k)}` with
`k = |closureOf (Γ ++ [σ])|` and `B = compressionBound Γ [σ]`. Nothing here should be read as a
complexity claim, and the cost is **the literature's own, not an artefact of the Lean
encoding**: [GKWZ] 2003 §6.5 gives an EXPSPACE-hardness lower bound for `PTL × S5`, so no
encoding of this decision problem does materially better. `Decidable` is the deliverable.

## The bound is a grid, and a consumer that folds by modulus needs to know

`cands` sweeps every triple of segment lengths in `[0, B]³`. A bound alone does **not** transfer
to a consumer whose registry folds `back`/`mid`/`fwd` bounds by exact modulus: such a search at
bound `n` represents exactly the periods dividing `n`, so representability, not magnitude, is
what the folding decides. Anyone porting this bound to a model checker must sweep the grid, not
pick a single triple.

## Scope: arbitrary finite premises, but no stability modal

`decidableSemanticConsequenceZTime` covers `SemanticConsequenceIn FrameClass.ZTime Γ σ` at
arbitrary finite `Γ`; `decidableSemanticConsequenceNil` is its `Γ = []` specialization and
`Compression.decidableValidZTime` the corresponding validity procedure. The route is the
**direct** one: `SemanticConsequenceIn` unfolds to local consequence at a point, so its negation
is already the shape `WitnessFamily.Refutes` describes, and `WitnessFamily.Refutes`,
`WitnessFamily.refutes_of_certifies`, `WitnessFamily.joint_countermodel`,
`exists_labelledLasso_of_history_realized`, `compressionBound` and the four `Decidable` instances
composed as `WitnessFamily.decidableCertifies` were already stated at arbitrary `Γ Del`.

Three things had been `Γ = []`-specific and all three are discharged. The entry point's carrier
normalization is now `Family.lean`'s `consequenceZTime_iff_consequenceInt`, the consequence
analogue of `validZTime_iff_validInt`, available from `truthAt_map` — stated at a fixed aligned
triple, so it applies simultaneously to every `γ ∈ Γ` and to `σ`. `WitnessFamily.Target`'s premise
clause, once discharged from `List.not_mem_nil`, is now the mirror of the conclusion clause
beside it. And `Enumerate.lean`'s enumeration is de-specialized from a single `φ` to `closureOf
(Γ ++ Del)` via the computable `closureList`, with the `φ`-indexed names kept as wrappers.

A **reduction** route exists beside the direct one. It is true that the tree has no
`Context.conj` or `bigConj` — no single formula denotes a context's conjunction — but
`StrongCompleteness.lean`'s `semantic_deduction_in` gives the iterated-implication form
`SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ)`, which
`ZTimeProvability.lean`'s `decidableSemanticConsequenceZTimeReduction` composes with
`Compression.decidableValidZTime`. The direct route is kept as primary because only it yields
candidates in the exported `WitnessFamily Γ [σ]` shape; the reduction route's candidates fold the
premises into the conclusion formula.

`ValidZTime` is stated for `FormalSystem.Syntax.Formula`, which has no stability modal `⊡`; `⊡`
lives only in `FormalSystem.PlusLanguage.Formula`. The durable scope sentence for that is
recorded at `BiLasso/Assembly.lean`'s docstring and is not restated here.

## Axioms

Every named result measures `[propext, Classical.choice, Quot.sound]`. The `Decidable`
produced **computes** — it carries no `Classical.dec` in its data — but that is not choice-freedom
and none is claimed; `wlem_of_saturation` shows no finite-carrier route to this result can be
choice-free.

## Main Results

- `validZTime_iff_noCertifiedCandidate` — the decision criterion for validity
- `Compression.decidableValidZTime` — **the decision procedure** (sub-namespaced: see its
  docstring — `BiLasso/Assembly.lean` already owns the bare name for the *conditional* procedure)
- `consequence_iff_noCertifiedCandidate` — the decision criterion at arbitrary finite premises
- `decidableSemanticConsequenceZTime` — **the decision procedure** for `Γ ⊨_ZTime σ`
- `decidableSemanticConsequenceNil` — its empty-premise specialization
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
**The decision criterion.**

`φ` is ℤ-valid exactly when no enumerated candidate certifies a refutation at any time of the
bounded window.

Forward, by contraposition through `exists_witnessFamily_of_not_validZTime` and
`mem_cands_of_bounded`: a failure of validity produces a certified candidate inside the window.
Backward through `WitnessFamily.refutes_of_certifies`: a certified candidate produces a genuine
ℤ-time countermodel, which refutes validity outright.

Paper: — (formalization-native; the paper's `cor:tm-decidability` is commented out and
carries no live label, and states nothing about the witness-family route)
-/
theorem validZTime_iff_noCertifiedCandidate (φ : Formula) :
    ValidZTime φ ↔
      ∀ W ∈ cands φ, ∀ t ∈ Finset.Icc (0 : ℤ) (compressionBound [] [φ] : ℤ),
        ¬ W.Certifies t := by
  constructor
  · intro hv W _ t _ hcert
    obtain ⟨F, hF, M, τ, u, -, hno⟩ := WitnessFamily.refutes_of_certifies W hcert
    exact hno φ (by simp) (hv F hF M τ u)
  · intro hall
    by_contra hnv
    obtain ⟨W, t, hlen, hcount, hbx, ht0, ht1, hcert⟩ :=
      exists_witnessFamily_of_not_validZTime φ hnv
    exact hall W (mem_cands_of_bounded φ W hlen hcount hbx) t
      (Finset.mem_Icc.mpr ⟨ht0, ht1⟩) hcert


/--
**The decision criterion at arbitrary finite premises.**

`Γ ⊨_ZTime σ` exactly when no enumerated candidate certifies a refutation at any time of the
bounded window. The candidates are `WitnessFamily Γ [σ]`, with `Γ` and `Δ` named separately — the
shape the certificate layer exists to export.

Forward, by contraposition through `exists_witnessFamily_of_not_consequence` and
`mem_candsCtx_of_bounded`: a failure of consequence produces a certified candidate inside the
window. Backward through `WitnessFamily.refutes_of_certifies`: a certified candidate produces a
genuine ℤ-time countermodel satisfying every premise and failing `σ`, which refutes the
consequence outright.

Paper: — (formalization-native; the paper's `cor:tm-decidability` is commented out and
carries no live label, and states nothing about the witness-family route)
-/
theorem consequence_iff_noCertifiedCandidate (Γ : Context) (σ : Formula) :
    SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ ↔
      ∀ W ∈ candsCtx Γ [σ], ∀ t ∈ Finset.Icc (0 : ℤ) (compressionBound Γ [σ] : ℤ),
        ¬ W.Certifies t := by
  constructor
  · intro hv W _ t _ hcert
    obtain ⟨F, hF, M, τ, u, hprem, hno⟩ := WitnessFamily.refutes_of_certifies W hcert
    exact hno σ (by simp) (hv F hF M τ u hprem)
  · intro hall
    by_contra hnv
    obtain ⟨W, t, hlen, hcount, hbx, ht0, ht1, hcert⟩ :=
      exists_witnessFamily_of_not_consequence Γ σ hnv
    exact hall W (mem_candsCtx_of_bounded Γ [σ] W hlen hcount hbx) t
      (Finset.mem_Icc.mpr ⟨ht0, ht1⟩) hcert

namespace Compression

/--
**The decision procedure for `ValidZTime`.**

A `def` and not an `instance`: a global `Decidable (ValidZTime φ)` instance would change instance
resolution repository-wide. See this module's header for the complexity statement.

**Why the extra `Compression` namespace.** `BiLasso/Assembly.lean` already declares
`FormalSystem.Metalogic.Decidability.decidableValidZTime` — the *conditional* procedure that
takes a finite-model-property witness `fmp` as a hypothesis, the hypothesis `Probe476.fmp_false`
refutes. This one is unconditional, and the two are genuinely different results that happen to
deserve the same simple name, so this one takes the sub-namespace rather than either being
renamed or `BiLasso/` being edited. It is the only declaration in this subdirectory whose
namespace differs from the rest.

Paper: — (formalization-native; the paper's `cor:tm-decidability` is commented out and
carries no live label, and states nothing about the witness-family route)
-/
def decidableValidZTime (φ : Formula) : Decidable (ValidZTime φ) :=
  decidable_of_iff _ (validZTime_iff_noCertifiedCandidate φ).symm

end Compression

/--
**The decision procedure for `Γ ⊨_ZTime σ`** at arbitrary finite `Γ`, by the direct route.

A `def` and not an `instance`, for the reason this module's header gives for
`Compression.decidableValidZTime`: a global `Decidable` instance here would change instance
resolution repository-wide. Callers that want it can `letI` it locally.

It carries no `noncomputable` modifier — `candsCtx` and `Finset.Icc` are both computable, and
`WitnessFamily.decidableCertifies` decides the four certificate conditions. See this module's
header for the complexity statement and the literature's own lower bound.

Paper: — (formalization-native; the paper's `cor:tm-decidability` is commented out and
carries no live label, and states nothing about the witness-family route)
-/
def decidableSemanticConsequenceZTime (Γ : Context) (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) :=
  decidable_of_iff _ (consequence_iff_noCertifiedCandidate Γ σ).symm

/--
**The empty-premise consequence corollary.**

The `Γ = []` specialization of `decidableSemanticConsequenceZTime`. Its name and signature are
pinned, so it survives as a thin wrapper rather than being retired; the general finite-premise
form beside it is what callers should reach for.
-/
def decidableSemanticConsequenceNil (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime [] σ) :=
  decidableSemanticConsequenceZTime [] σ

end FormalSystem.Metalogic.Decidability
