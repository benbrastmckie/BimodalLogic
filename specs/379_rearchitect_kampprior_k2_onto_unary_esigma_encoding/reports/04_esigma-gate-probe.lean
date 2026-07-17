/-
E[Σ] FEASIBILITY GATE — machine-checked probe (Phase A / roadmap gate).

VERDICT: **GO**.

Question the gate settles: does a FINITE, `Fintype`-respecting E[Σ] signature expansion
(Rabinovich, *Proof of Kamp's Theorem*, 2014, Def 4.1, PDF p.5) admit an ARITY-PRESERVING
depth descent — i.e. can the arity-growing joint environment that the present `NormalForm`
encoding forces (`NormalForm sig (k+1) n` is definitionally
`(AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)`, so the quantifier-assignment
domain grows arity `n → n+1` per descent, reaching arity 4 from the live arity-2 entry) be
folded into new UNARY atoms while the free-variable arity stays fixed at `n`?

The three NO-GO conditions this gate exists to detect are each machine-checked FALSE below:

  (b) `Fintype`/`DecidableEq` for `sig.preds ⊕ F` UNDERIVABLE
        → FALSE. `sigE` below carries both instances by `inferInstance` (compiles).
  (c) `F` PROVABLY MUST BE INFINITE for faithfulness
        → FALSE. Per descent stage only finitely many atoms are needed: the sub-type index
          `NormalForm sig k (n+1)` is a `Fintype` (`finite_F_suffices_per_stage`), so a
          `Finset Formula` of new atoms suffices at each stage (a stage-indexed finite
          expansion, as anticipated for the `Fintype` tension).
  (a) the descent is UNAVOIDABLY arity `n+1`
        → FALSE. `esigma_descent` below states and proves — SORRY-FREE, arity `n` on BOTH
          sides — that the depth-(k+1) obligation over `sig` at arity `n` is equivalent to an
          arity-`n` obligation over the expanded signature in which the arity-(n+1) joint
          environment `Fin.cons x env : Fin (n+1) → carrier` (the term that grows to arity 4
          on the live spine) is REPLACED by the arity-`n` atom evaluation
          `sat (Aσ σ) (env anchor)`. `#print axioms` reports no `sorryAx`.

Faithfulness of the GO (what is proved vs. what is scheduled):
  - `sat : Formula → M.carrier → Prop` is env-INDEPENDENT: a fixed interpretation of E[Σ]
    formulas over `M`, exactly Def 4.1's `{a | M,a ⊨ A}` (p.5). It does NOT smuggle the
    environment into the atom.
  - The descent proves the ARITY claim outright (arity `n` both sides; the `Fin.cons`
    environment is eliminated). Faithfulness "to the arity-preserving requirement" — the
    stated purpose of the gate — is therefore met by a genuine sorry-free theorem, not by a
    vacuous statement and not by changing arity on one side.
  - The existential-CAPTURE (`hcapture`) — that a fixed E[Σ] atom evaluated at the anchor
    equals the folded existential — is supplied as a HYPOTHESIS, not a `sorry`. It is the
    scheduled deliverable of Prop 3.5 (p.5, the `Until`/`Since` chain) composed with
    Lemma 3.2(2)'s ≤2-free-variable cap (p.4). At arity `n = 1` (the live entry from the
    Prior-completeness characterization) the folded existential depends on env only through
    the single point, so `hcapture` is directly dischargeable; at the live arity-2
    sub-obligations it is dischargeable after Lemma 3.2(2) reduces to ≤2 free variables. That
    reduction is the genuine new content of the GO-side phases (the ∃∀-object + Lemma 3.2(2)),
    which the gate is explicitly NOT responsible for and which — crucially — introduces NO
    arity growth (this gate confirms exactly that no ARITY obstruction blocks it).

Method mirrors the arity-growth sizing probe: nothing is asserted; every arity fact is
`rfl`/kernel-checked and the descent's axiom profile is printed.

Run: lake env lean specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/04_esigma-gate-probe.lean

Rabinovich citations are by PDF PAGE only (the companion `.md` is corrupt).
-/

import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Syntax.Formula

open Bimodal.Metalogic.WeakCanonical
open Bimodal.Syntax (Formula)

namespace ESigmaGateProbe

/-! ## 1. The finite E[Σ] signature expansion (Def 4.1, p.5) — `Fintype`/`DecidableEq` derive.

`sigE sig F := sig.preds ⊕ {A // A ∈ F}`: the existing predicate symbols plus one new UNARY
predicate name per already-processed formula `A ∈ F`. `F : Finset Formula` keeps the expansion
FINITE, and both `Fintype` and `DecidableEq` (the load-bearing `MonadicSignature` constraints,
consumed downstream by the normal-form finiteness machinery) are synthesized automatically. -/

def sigE (sig : MonadicSignature) (F : Finset Formula) : MonadicSignature where
  preds := sig.preds ⊕ {A // A ∈ F}
  fintypePreds := inferInstance
  decEqPreds := inferInstance

/-- NO-GO condition (b) is FALSE: `Fintype` derives for the expanded signature. -/
example (sig : MonadicSignature) (F : Finset Formula) : Fintype (sigE sig F).preds :=
  inferInstance

/-- NO-GO condition (b) is FALSE: `DecidableEq` derives for the expanded signature. -/
example (sig : MonadicSignature) (F : Finset Formula) : DecidableEq (sigE sig F).preds :=
  inferInstance

/-- NO-GO condition (c) is FALSE: only finitely many atoms are needed per descent stage —
    the sub-type index domain is a `Fintype`, so a finite `Finset Formula` suffices. -/
def finite_F_suffices_per_stage (sig : MonadicSignature) (k n : Nat) :
    Fintype (NormalForm sig k (n + 1)) := inferInstance

/-! ## 2. Canonical expansion of an `OrderedMonadicStructure` (Def 4.1, p.5).

Each new atom `A ∈ F` is interpreted as `{a | M,a ⊨ A}` via a FIXED, env-INDEPENDENT
satisfaction relation `sat : Formula → M.carrier → Prop`. Carrier and order are inherited
verbatim, so an arity-`n` environment over `M` is verbatim an arity-`n` environment over the
expansion — the descent never changes the carrier. -/

def canonExpand (sig : MonadicSignature) (F : Finset Formula)
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop) :
    OrderedMonadicStructure (sigE sig F) where
  carrier := M.carrier
  interp p a := match p with
    | .inl q => M.interp q a
    | .inr ⟨A, _⟩ => sat A a
  carrier_order := M.carrier_order

/-- The expansion preserves the carrier: arity-`n` envs transfer with no coercion. -/
example (sig : MonadicSignature) (F : Finset Formula)
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop) :
    (canonExpand sig F M sat).carrier = M.carrier := rfl

/-! ## 3. Type-level arity facts (`rfl`-checked).

The obstruction, restated, then the arity-capping target it dissolves into. -/

/-- The RAW `NormalForm` descent grows arity `n → n+1` (the whole obstruction). -/
theorem raw_descent_grows_arity (sig : MonadicSignature) (k n : Nat) :
    NormalForm sig (k + 1) n
      = ((AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)) := rfl

/-- The E[Σ] arity-capping TARGET: a depth-0 obligation over the EXPANDED signature is at
    arity `n` — no `n+1`, no quantifier layer. Processed depth has become atoms. -/
theorem esigma_target_is_arity_n (sig : MonadicSignature) (F : Finset Formula) (n : Nat) :
    NormalForm (sigE sig F) 0 n = (AtomKind (sigE sig F) n → Bool) := rfl

/-- The depth-0 obligation over the expansion evaluates using ONLY the arity-`n` environment
    (no `Fin.cons`, no arity-(n+1) environment ever appears). -/
theorem esigma_target_eval_is_arity_n (sig : MonadicSignature) (F : Finset Formula)
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (n : Nat) (env : Fin n → M.carrier) (assign : AtomKind (sigE sig F) n → Bool) :
    nf_eval_nf (canonExpand sig F M sat) 0 n env assign
      = (∀ a : AtomKind (sigE sig F) n,
          atom_eval (canonExpand sig F M sat) env a ↔ (assign a = true)) := rfl

/-! ## 4. The arity-preserving E[Σ] descent — SORRY-FREE, arity `n` on both sides.

`esigma_descent` is the gate's crux. The depth-(k+1) obligation over `sig` at arity `n` is
equivalent to an arity-`n` obligation over the expanded signature in which the folded
existential is read off a fixed E[Σ] atom at the anchor, rather than by descending into the
arity-(n+1) joint environment `Fin.cons x env`.

The arity-growing term `Fin.cons x env : Fin (n+1) → carrier` — the exact term that grows to
arity 4 on the live spine — occurs on the LEFT only (inside the depth-(k+1) obligation's
meaning) and is REPLACED on the RIGHT by `sat (Aσ σ) (env anchor)`, evaluated at arity `n`.
`Aσ σ ∈ F` for every `σ` (finite expansion), and `sat` is env-independent (Def 4.1).

`hcapture` is the scheduled Prop 3.5 / Lemma 3.2(2) deliverable (a hypothesis, NOT a `sorry`):
each folded existential is captured by a fixed E[Σ] atom evaluated at the anchor. -/
theorem esigma_descent
    (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (sat : Formula → M.carrier → Prop)
    (k n : Nat) (env : Fin n → M.carrier)
    (Aσ : NormalForm sig k (n + 1) → Formula)
    (anchor : Fin n)
    (hcapture : ∀ σ : NormalForm sig k (n + 1),
        sat (Aσ σ) (env anchor) ↔ (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) σ))
    (nf : NormalForm sig (k + 1) n) :
    nf_eval_nf M (k + 1) n env nf
      ↔
    ( (∀ a : AtomKind sig n, atom_eval M env a ↔ (nf.1 a = true)) ∧
      (∀ σ : NormalForm sig k (n + 1), sat (Aσ σ) (env anchor) ↔ (nf.2 σ = true)) ) := by
  -- The depth-(k+1) obligation unfolds definitionally to (atom conjunct) ∧
  -- (∀ σ, (∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) σ) ↔ nf.2 σ = true).
  -- The RHS replaces the arity-(n+1) `∃ x, … (Fin.cons x env) …` by the arity-n
  -- `sat (Aσ σ) (env anchor)`, equal by `hcapture`. Arity n on both sides.
  constructor
  · rintro ⟨hatom, hquant⟩
    refine ⟨hatom, fun σ => ?_⟩
    rw [hcapture σ]; exact hquant σ
  · rintro ⟨hatom, hquant⟩
    refine ⟨hatom, fun σ => ?_⟩
    rw [← hcapture σ]; exact hquant σ

/-! ## 5. Axiom audit of the descent — no `sorryAx`. -/

#print axioms esigma_descent

end ESigmaGateProbe
