/-
ζ/ε SPINE-REWIRE SEAM — machine-checked de-risking spike (viability gate).

VERDICT: recorded at the bottom of this file (see `## VERDICT`).

This is a SCRATCH / OFF-PATH probe under `specs/` — it is NOT under `Theories/` and is imported
by nothing live, so the `lake build` spine and `#print axioms completeness_discrete` are
untouched by anything here. Compile with:

    lake env lean specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/08_zeta-epsilon-seam-probe.lean

Purpose (front-loaded cheap probe): establish, with compiling Lean, that the two highest-risk
seams of the faithful E[Σ] re-architecture are VIABLE on a minimal case, BEFORE the large
`conjInterleave` build is sunk. The two seams:

  (a) the `NormalForm sig k n` ↔ `MonadicFO` (monadic first-order) object-language bridge at the
      completeness interface — which direction is viable;
  (b) the `esigma_descent.hcapture` discharge — folding one existential into a fresh E[Σ] atom
      evaluated at the anchor, sorry-free.

Faithfulness (Rabinovich, *A Proof of Kamp's Theorem*, 2014; cite by PDF page only — the `.md`
transcription is corrupt):
  - Def 3.1 (p.4): an ∃∀-formula has UNARY point/interval predicates α_j/β_j over a single
    descending chain x_n > … > x_0, with the m+1 free variables PINNED to chain points
    (z_k = x_{i_k}). No joint type over a tuple.
  - Lemma 3.2(2) (p.4): every ∃∀-formula ≡ a conjunction of ∃∀-formulas with ≤ 2 free variables.
  - Def 4.1 (p.5) + collapse note (p.6): E[Σ] := Σ ∪ { A | A a TL(Until,Since)-formula over Σ },
    a UNARY predicate-name expansion; in the canonical expansion each fresh atom A is interpreted
    as { a | M,a ⊨ A }. A TL(Until,Since)-formula over E[Σ] predicates is again equivalent to a
    TL(Until,Since)-formula over Σ, hence to an ATOMIC formula in the canonical expansion — an
    already-processed existential re-enters only as a unary atom at quantifier-depth 0. This is
    exactly the `hcapture` device: the folded existential's truth set IS a fresh unary atom
    evaluated at the anchor point.
  - Prop 4.3 / Thm 4.4 (p.6): FO(1 free var) → TL by structural induction over the formula, with
    the negation case bounded by the ≤2-free-var cap.

Durable anchors (no task-number pointers, per repo policy): the landed E[Σ] descent
`esigma_descent` and its atom-collapse facts `atom_eval_new`/`atom_eval_old` live in the sibling
module `Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion`; the object-language pieces
`NormalForm`/`nf_eval_nf`/`AtomKind` in `Bimodal.Metalogic.WeakCanonical.NormalForm`; the monadic
FO object `MonadicFO`/`MonadicFO.eval` in `Bimodal.Metalogic.WeakCanonical.MonadicFO`.
-/

import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion
import Bimodal.Syntax.Formula

open Bimodal.Metalogic.WeakCanonical
open Bimodal.Syntax (Formula)

namespace ZetaEpsilonSeamProbe

/-! ## Seam (b): the `esigma_descent.hcapture` discharge, minimal case

`esigma_descent` (landed, sorry-free) takes as a hypothesis

    hcapture : ∀ σ : NormalForm sig k (n+1),
        sat (Aσ σ) (env anchor) ↔ (∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) σ)

i.e. that each folded existential (the depth-`k` sub-normal-form σ under one more existential
witness `x`) is captured by the fresh E[Σ] atom `Aσ σ`, read off `sat` at the anchor point.
This is the Def 4.1 (p.5) / p.6-collapse mechanism: the atom's truth set is `{ a | ∃x, sub holds
anchored at a }`.

Seam (b) shows this hypothesis is DISCHARGEABLE sorry-free on the minimal case `k = 0`, `n = 1`,
`anchor = 0`. Given any injective naming `Aσ` of sub-normal-forms by formulas (injectivity is all
Def 4.1 requires — distinct processed formulas get distinct fresh predicate names), we EXHIBIT the
canonical `sat` whose value at a point `a` is exactly the anchored existential, and prove the
capture iff. Faithful: `sat (Aσ σ) a` unfolds to "∃ witness x, σ holds when the chain is anchored
at a" — the truth set of the fresh unary atom, matching Rabinovich's `{ a | M,a ⊨ A }`. -/

/-- Seam (b), core: the `hcapture` premise of `esigma_descent` is dischargeable sorry-free on the
minimal case. For any injective naming `Aσ`, the canonical anchored-existential `sat` satisfies the
capture iff at every sub-normal-form. -/
theorem hcapture_dischargeable_minimal
    {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (env : Fin 1 → M.carrier)
    (Aσ : NormalForm sig 0 2 → Formula) (hAσ : Function.Injective Aσ) :
    ∃ sat : Formula → M.carrier → Prop,
      ∀ σ : NormalForm sig 0 2,
        sat (Aσ σ) (env 0) ↔ (∃ x, nf_eval_nf M 0 2 (Fin.cons x env) σ) := by
  -- The canonical fresh-atom interpretation: `a ↦ { the anchored existential over the σ named by A }`.
  refine ⟨fun A a => ∃ σ, Aσ σ = A ∧ ∃ x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => a)) σ, ?_⟩
  intro σ
  have henv : (fun _ : Fin 1 => env 0) = env := by
    funext j; exact congrArg env (Subsingleton.elim 0 j)
  constructor
  · rintro ⟨σ', hσ', x, hx⟩
    have hσeq : σ' = σ := hAσ hσ'
    subst hσeq
    exact ⟨x, by rw [henv] at hx; exact hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨σ, rfl, x, by rw [henv]; exact hx⟩

/-- Seam (b), composed: the discharged `hcapture` feeds the LANDED `esigma_descent` verbatim,
yielding the arity-preserving depth-1 descent with NO `Fin.cons` arity-`(n+1)` joint environment on
the right — the folded existential read entirely off the fresh unary atom. This is the machine
check that the discharge is not merely internally consistent but actually drives the real descent. -/
theorem esigma_descent_composes_minimal
    {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (env : Fin 1 → M.carrier)
    (Aσ : NormalForm sig 0 2 → Formula) (hAσ : Function.Injective Aσ)
    (nf : NormalForm sig 1 1) :
    ∃ sat : Formula → M.carrier → Prop,
      nf_eval_nf M 1 1 env nf ↔
        ((∀ a : AtomKind sig 1, atom_eval M env a ↔ (nf.1 a = true)) ∧
         (∀ σ : NormalForm sig 0 2, sat (Aσ σ) (env 0) ↔ (nf.2 σ = true))) := by
  obtain ⟨sat, hsat⟩ := hcapture_dischargeable_minimal M env Aσ hAσ
  exact ⟨sat, esigma_descent sig M sat 0 1 env Aσ 0 hsat nf⟩

#print axioms hcapture_dischargeable_minimal
#print axioms esigma_descent_composes_minimal

end ZetaEpsilonSeamProbe
