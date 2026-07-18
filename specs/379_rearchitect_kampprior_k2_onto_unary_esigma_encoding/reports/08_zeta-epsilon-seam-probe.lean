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

/-! ## Seam (a): the `NormalForm` ↔ `MonadicFormula` object-language bridge, minimal case

Finding on which DIRECTION is viable (the deliverable the plan asks Phase 0 to record for Phases 1
and 7): there is **NO syntactic `NormalForm sig k n → MonadicFormula sig n` (or reverse) translation
function** in the codebase, and none is needed. The bridge the live spine actually uses
(`kamp_prior_expressive_completeness`) is **SEMANTIC**, in the direction

    MonadicFormula sig n  ⟶  (characteristic) NormalForm sig k n  ⟶  truth-determined,

via two landed, sorry-free pieces:
  - `nf_characteristic M k n env : NormalForm sig k n` — the normal form realized by `(M, env)`,
    always satisfied (`nf_characteristic_satisfies`). The MonadicFormula's semantic content is thus
    RECORDED in a `NormalForm` object at the interface.
  - `doets_lemma_1_1` — depth-bounded EF-invariance: any two structures agreeing on the depth-`k`
    `NormalForm` agree on every `MonadicFormula` of `quantifier_depth ≤ k`. This is exactly the
    interface `nf_characterizable_temporal_prior` / `kamp_prior_expressive_completeness` consume to
    turn a `MonadicFormula sig 1` into an equivalent temporal `Formula`.

Seam (a) below closes this bridge sorry-free on minimal formulas (a single atom and a single order
literal, both `quantifier_depth 0`), confirming the object-language interface is viable WITHOUT
inventing a `NormalForm → MonadicFormula` syntactic translation. Phases 1/7 should wire the new
`translate` path through this SEMANTIC bridge (characteristic NF + `doets_lemma_1_1`), NOT a new
syntactic object-language function. -/

/-- Seam (a.i): the MonadicFormula's semantic content lands in a `NormalForm` object at the
interface — the characteristic normal form of `(M, env)` is always satisfied. -/
theorem seam_a_characteristic_records {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (env : Fin 1 → M.carrier) :
    nf_eval_nf M 0 1 env (nf_characteristic M 0 1 env) :=
  nf_characteristic_satisfies M 0 1 env

/-- Seam (a.ii), single-atom case: `MonadicFormula` truth transports across any two structures
agreeing on the depth-0 characteristic `NormalForm` — the viable SEMANTIC bridge, sorry-free. -/
theorem seam_a_bridge_atom {sig : MonadicSignature}
    (p : sig.preds) (i : Fin 1)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin 1 → M.carrier) (env_N : Fin 1 → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig 0 1,
        nf_eval_nf M 0 1 env_M nf ↔ nf_eval_nf N 0 1 env_N nf) :
    eval M env_M (MonadicFormula.atom p i) ↔ eval N env_N (MonadicFormula.atom p i) :=
  doets_lemma_1_1 0 1 (MonadicFormula.atom p i) (le_refl 0) M N env_M env_N h_same_nf

/-- Seam (a.ii), one-connective (order literal) case: the same bridge closes on `.lt`, confirming
the interface is not atom-specific. -/
theorem seam_a_bridge_lt {sig : MonadicSignature}
    (i j : Fin 1)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin 1 → M.carrier) (env_N : Fin 1 → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig 0 1,
        nf_eval_nf M 0 1 env_M nf ↔ nf_eval_nf N 0 1 env_N nf) :
    eval M env_M (MonadicFormula.lt i j) ↔ eval N env_N (MonadicFormula.lt i j) :=
  doets_lemma_1_1 0 1 (MonadicFormula.lt i j) (le_refl 0) M N env_M env_N h_same_nf

#print axioms hcapture_dischargeable_minimal
#print axioms esigma_descent_composes_minimal
#print axioms seam_a_characteristic_records
#print axioms seam_a_bridge_atom
#print axioms seam_a_bridge_lt

/-! ## VERDICT

**GO.**

Both highest-risk ζ/ε seams are machine-checked VIABLE on the minimal case, sorry-free (each
`#print axioms` above lists only `[propext, Classical.choice, Quot.sound]` — no `sorryAx`):

  - **Seam (b) — `esigma_descent.hcapture` discharge: DISCHARGEABLE.** For any injective naming of
    sub-normal-forms by formulas, the canonical anchored-existential `sat` discharges `hcapture`
    (`hcapture_dischargeable_minimal`) and feeds the LANDED `esigma_descent` verbatim
    (`esigma_descent_composes_minimal`), yielding the arity-preserving depth-1 descent with the
    folded existential read entirely off a fresh unary atom (Def 4.1, p.5 / p.6 collapse). No
    arity-`(n+1)` joint environment on the right; no new mathematics.

  - **Seam (a) — `NormalForm` ↔ `MonadicFormula` bridge: VIABLE, semantic direction.** The viable
    bridge is `MonadicFormula ⟶ characteristic NormalForm ⟶ truth-determined` via
    `nf_characteristic`/`nf_characteristic_satisfies` + `doets_lemma_1_1` — NOT a syntactic
    `NormalForm → MonadicFormula` translation (which does not exist and is not needed). Closed
    sorry-free on the single-atom and order-literal minimal cases.

**Direction recorded for Phases 1 and 7:** wire the new `translate` / spine rewire through the
SEMANTIC bridge (characteristic `NormalForm` + `doets_lemma_1_1`, the interface
`kamp_prior_expressive_completeness` already consumes), and discharge the live-spine `hcapture`
by the Prop 3.5 / Lemma 3.2(2) instance generalizing `hcapture_dischargeable_minimal`. The large
`conjInterleave` (α) build is AUTHORIZED — the crux interface is not a wall.
-/

end ZetaEpsilonSeamProbe
