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

`φ` is ℤ-valid iff **no** candidate on `cands φ` certifies a refutation at any time in
`[0, compressionBound [] [φ]]`. Both quantifiers are over finite objects — a `List` and a
`Finset.Icc` — so the right-hand side is decidable, and `decidable_of_iff` transports that to
`ValidZTime φ`.

## `def`, not `instance`

`decidableValidZTime` and `decidableSemanticConsequenceNil` are `def`s, exactly as the landed
`BiLasso/Assembly.lean` declares `decidableValidZTimeFamily`. A global
`Decidable (ValidZTime φ)` instance would change instance resolution repository-wide and could
slow or loop elaboration in modules that have nothing to do with this one. Callers that want it
can `letI` it locally.

## The complexity, stated honestly

`cands φ` is astronomically large — roughly `(2^k)^{3B(1 + k)}` with `k = |closureOf ([] ++ [φ])|`
and `B = compressionBound [] [φ]`. Nothing here should be read as a complexity claim, and the
cost is **the literature's own, not an artefact of the Lean encoding**: [GKWZ] 2003 §6.5 gives an
EXPSPACE-hardness lower bound for `PTL × S5`, so no encoding of this decision problem does
materially better. `Decidable` is the deliverable.

## The bound is a grid, and a consumer that folds by modulus needs to know

`cands` sweeps every triple of segment lengths in `[0, B]³`. A bound alone does **not** transfer
to a consumer whose registry folds `back`/`mid`/`fwd` bounds by exact modulus: such a search at
bound `n` represents exactly the periods dividing `n`, so representability, not magnitude, is
what the folding decides. Anyone porting this bound to a model checker must sweep the grid, not
pick a single triple.

## Scope: no premises, and no stability modal

`decidableSemanticConsequenceNil` covers `SemanticConsequenceIn FrameClass.ZTime [] σ` only. The
general finite-premise case is unproved, and the obstruction is narrower than a missing deduction
theorem. It is the **reduction** route — deriving `Γ ⊨ σ` from `⊨ ⋀Γ → σ` — that needs a
context-conjunction deduction theorem, and the tree has none: there is no `Context.conj`, `bigConj`
or equivalent. The **direct** route needs no such theorem. `SemanticConsequenceIn` unfolds to local
consequence at a point, so its negation is already the shape `WitnessFamily.Refutes` describes, and
`WitnessFamily.Refutes`, `WitnessFamily.refutes_of_certifies`, `WitnessFamily.joint_countermodel`,
`exists_labelledLasso_of_history_realized`, `compressionBound` and the four `Decidable` instances
composed as `WitnessFamily.decidableCertifies` are all already stated at arbitrary `Γ Del`.

What is genuinely `Γ = []`-specific is three things: this module's entry point normalizes the
carrier with `validZTime_iff_validInt`, and the general case needs that lemma's consequence
analogue — available from `truthAt_map`, which is stated at a fixed aligned triple and so applies
simultaneously to every `γ ∈ Γ` and to `σ`; `WitnessFamily.Target`'s premise clause, discharged
here from `List.not_mem_nil`, becomes the mirror of the conclusion clause beside it; and
`Enumerate.lean`'s `closureSubsetsOf`, `rawLabelledLassos`, `IsLabelledLasso`, `boundedLassos` and
`cands` are specialized to a single `φ` over `closureOf ([] ++ [φ])`. That residue is bounded and
enumerated rather than open-ended — and it is **not** discharged: the consequence-form carrier
normalization has never been written, so nothing here claims the general form compiles.

`ValidZTime` is stated for `FormalSystem.Syntax.Formula`, which has no stability modal `⊡`; `⊡`
lives only in `FormalSystem.PlusLanguage.Formula`. The durable scope sentence for that is
recorded at `BiLasso/Assembly.lean`'s docstring and is not restated here.

## Axioms

The three named results measure `[propext, Classical.choice, Quot.sound]`. The `Decidable`
produced **computes** — it carries no `Classical.dec` in its data — but that is not choice-freedom
and none is claimed; `wlem_of_saturation` shows no finite-carrier route to this result can be
choice-free.

## Main Results

- `validZTime_iff_noCertifiedCandidate` — the decision criterion
- `Compression.decidableValidZTime` — **the decision procedure** (sub-namespaced: see its
  docstring — `BiLasso/Assembly.lean` already owns the bare name for the *conditional* procedure)
- `decidableSemanticConsequenceNil` — the empty-premise consequence corollary
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
**The empty-premise consequence corollary.**

Via `semanticConsequenceIn_nil_iff`, the bridge `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ`.
The non-empty-premise case is unproved here. A deduction theorem is what the *reduction* route
(`Γ ⊨ σ` from `⊨ ⋀Γ → σ`) would need, and the tree has none; the *direct* route needs none, since
everything downstream of the entry point is already stated at arbitrary `Γ Del`. See this module's
header for the three `Γ = []`-specific items that remain, none of them yet written.
-/
def decidableSemanticConsequenceNil (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime [] σ) :=
  letI := Compression.decidableValidZTime σ
  decidable_of_iff (ValidZTime σ) (semanticConsequenceIn_nil_iff _ σ).symm

end FormalSystem.Metalogic.Decidability
