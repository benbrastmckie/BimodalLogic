import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion
import Bimodal.Syntax.Formula

/-!
# General `esigma_descent.hcapture` discharge (Rabinovich 2014, Def 4.1, PDF p.5 / p.6 collapse)

The landed E[Σ] descent `esigma_descent` (sibling module
`Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion`) takes as a hypothesis

    hcapture : ∀ σ : NormalForm sig k (n+1),
        sat (Aσ σ) (env anchor) ↔ (∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) σ)

i.e. that each folded existential — a depth-`k` sub-normal-form `σ` under one additional
existential witness `x` — is captured by the fresh E[Σ] atom `Aσ σ`, read off `sat` at the
anchor point. This is exactly the Def 4.1 (p.5) predicate-name expansion together with the p.6
collapse note: in the canonical expansion the fresh atom `A` is interpreted as `{ a | M,a ⊨ A }`,
so an already-processed existential re-enters only as a UNARY atom at quantifier-depth 0.

This module discharges that hypothesis sorry-free, generalizing the minimal-case probe
(`hcapture_dischargeable_minimal`, which fixed depth `k = 0`, arity `n = 1`) in two directions:

* `hcapture_dischargeable` — arbitrary depth `k`, arbitrary arity `n`, arbitrary environment and
  anchor. The fresh atom is interpreted by the truth set `{ a | ∃x, σ holds anchored under env }`
  (the anchored existential over the ambient environment), which discharges the capture iff by
  injectivity of the fresh-atom naming `Aσ` — the only property Def 4.1 requires of the fresh
  predicate names (distinct processed formulas receive distinct fresh names).
* `hcapture_dischargeable_faithful` — the same discharge at the Lemma 3.2(2) two-free-variable cap
  (arity `n = 1`), with the fresh atom's truth set rendered as the point-indexed anchored
  existential `{ a | ∃x, σ holds when the chain is anchored at a }` — the literal Def 4.1
  `{ a | M,a ⊨ A }` shape, generalizing the minimal probe's `(fun _ => a)` device over arbitrary
  processed depth `k`.
* `esigma_descent_composes` — the general discharge feeds the landed `esigma_descent` verbatim,
  the machine check that the discharge actually drives the real depth-`(k+1)` descent with the
  folded existential read entirely off a fresh unary atom (no arity-`(n+1)` joint environment on
  the right).

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine;
Phase ζ wires these into the live spine.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5), collapse note (p.6),
  Lemma 3.2(2) (p.4). Cited by PDF page only; the companion markdown transcription is corrupt.
- `Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion`: `esigma_descent`.
- `Bimodal.Metalogic.WeakCanonical.NormalForm`: `NormalForm`, `nf_eval_nf`, `AtomKind`, `atom_eval`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Metalogic.WeakCanonical
open Bimodal.Syntax (Formula)

/-- **General `hcapture` discharge (Def 4.1, p.5 / p.6 collapse).** For any injective naming `Aσ`
of depth-`k` sub-normal-forms by formulas, the fresh atom interpreted by the anchored-existential
truth set discharges the `esigma_descent.hcapture` premise at arbitrary depth `k`, arity `n`,
environment `env`, and anchor. Injectivity is all Def 4.1 requires of the fresh predicate names. -/
theorem hcapture_dischargeable
    {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k n : Nat} (env : Fin n → M.carrier) (anchor : Fin n)
    (Aσ : NormalForm sig k (n + 1) → Formula) (hAσ : Function.Injective Aσ) :
    ∃ sat : Formula → M.carrier → Prop,
      ∀ σ : NormalForm sig k (n + 1),
        sat (Aσ σ) (env anchor) ↔ (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) σ) := by
  -- The fresh atom named `A` is interpreted by the anchored existential over the ambient `env`.
  refine ⟨fun A _ => ∃ σ, Aσ σ = A ∧ ∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) σ, ?_⟩
  intro σ
  constructor
  · rintro ⟨σ', hσ', x, hx⟩
    have hσeq : σ' = σ := hAσ hσ'
    subst hσeq
    exact ⟨x, hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨σ, rfl, x, hx⟩

/-- **Faithful `hcapture` discharge at the Lemma 3.2(2) cap (Def 4.1, p.5 / p.6).** At the
two-free-variable cap (arity `n = 1`), the fresh atom's truth set is the genuine point-indexed
anchored existential `{ a | ∃x, σ holds when the chain is anchored at a }` — the literal Def 4.1
`{ a | M,a ⊨ A }` shape — discharging the capture iff for arbitrary processed depth `k`. This
generalizes the minimal probe's `(fun _ => a)` device over depth. -/
theorem hcapture_dischargeable_faithful
    {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 1 → M.carrier)
    (Aσ : NormalForm sig k 2 → Formula) (hAσ : Function.Injective Aσ) :
    ∃ sat : Formula → M.carrier → Prop,
      ∀ σ : NormalForm sig k 2,
        sat (Aσ σ) (env 0) ↔ (∃ x, nf_eval_nf M k 2 (Fin.cons x env) σ) := by
  -- The point-indexed anchored existential: `a ↦ { the anchored existential over the σ named by A }`.
  refine ⟨fun A a => ∃ σ, Aσ σ = A ∧ ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => a)) σ, ?_⟩
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

/-- **Composed general descent.** The general `hcapture` discharge feeds the landed
`esigma_descent` verbatim, yielding the depth-`(k+1)` descent at arbitrary arity with the folded
existential read entirely off a fresh unary atom — no arity-`(n+1)` joint environment on the
right. Generalizes the minimal probe's `esigma_descent_composes_minimal`. -/
theorem esigma_descent_composes
    {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k n : Nat} (env : Fin n → M.carrier) (anchor : Fin n)
    (Aσ : NormalForm sig k (n + 1) → Formula) (hAσ : Function.Injective Aσ)
    (nf : NormalForm sig (k + 1) n) :
    ∃ sat : Formula → M.carrier → Prop,
      nf_eval_nf M (k + 1) n env nf ↔
        ((∀ a : AtomKind sig n, atom_eval M env a ↔ (nf.1 a = true)) ∧
         (∀ σ : NormalForm sig k (n + 1), sat (Aσ σ) (env anchor) ↔ (nf.2 σ = true))) := by
  obtain ⟨sat, hsat⟩ := hcapture_dischargeable M env anchor Aσ hAσ
  exact ⟨sat, esigma_descent sig M sat k n env Aσ anchor hsat nf⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
