import Bimodal.Metalogic.WeakCanonical.Kamp.PerFormulaType
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Per-formula renderer: a partial 1-type as a temporal-logic formula

**Purpose.** The per-formula-finite analog of the rendering step of Prop 3.5: render a partial
1-type `c : UnaryTypeFin sig F M` as the conjunction of atom literals over exactly the finite
mentioned-atom set `M` — never over the whole alphabet. This is the NEW additive renderer for the
exists-forall chain at `sigE`; the signature-generic total renderer `nf_depth0_char_formula`
(`Separation/KampTranslation.lean`), which folds over `Fintype.elems`, is NOT edited and keeps all
its finite-signature consumers.

Rabinovich's `A_i` (Prop 3.5, PDF p.5) is built from the finite syntax of its own `alpha_i`
(Def 3.1, p.4: a quantifier-free one-variable formula mentions finitely many atoms), so the
faithful rendering enumerates only the mentioned atoms `M`. Correctness (`unaryToFormulaFin_correct`)
mirrors `nf_depth0_char_formula_correct` bounded to `M`: the rendered formula holds at a point iff
the point realizes the partial type (`partialHolds`).

**No full-alphabet `Finset.univ` and no `Fintype (sigE sig F).preds` anywhere in this module** —
the fold is over `M.attach.toList`, so every construction survives the infinite E[Sigma] of
Def 4.1 (p.5).

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1 (p.5).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `PerFormulaType.lean` (`UnaryTypeFin`, `partialHolds`); `Separation/KampTranslation.lean`
  (`formula_conjList`, `atom_literal` — reused, not modified); `NormalForm.lean` (`AtomKind`,
  `atom_eval`).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff atom_literal atom_literal_correct)

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Arity-1 atom classification (total form) -/

/-- The predicate carried by an arity-1 atom: at one variable there is no distinct pair, so no
order atom exists and every `AtomKind sig' 1` is `pred p i`. -/
def atomPred1 {sig' : MonadicSignature} : AtomKind sig' 1 → sig'.preds
  | .pred p _ => p
  | .order i j h => (h (Subsingleton.elim i j)).elim

/-- Every arity-1 atom is its predicate applied to the single variable. -/
theorem atomKind1_eq_pred {sig' : MonadicSignature} (a : AtomKind sig' 1) :
    a = AtomKind.pred (atomPred1 a) ⟨0, Nat.zero_lt_one⟩ := by
  cases a with
  | pred p i =>
    simp only [atomPred1]
    congr 1
    exact Subsingleton.elim i _
  | order i j h => exact absurd (Subsingleton.elim i j) h

/-- Evaluating an arity-1 atom at the constant environment `y` is exactly interpreting its
predicate at `y`. -/
theorem atom_eval1_iff_interp {sig' : MonadicSignature} (N : OrderedMonadicStructure sig')
    (a : AtomKind sig' 1) (y : N.carrier) :
    atom_eval N (fun _ => y) a ↔ N.interp (atomPred1 a) y := by
  conv_lhs => rw [atomKind1_eq_pred a]
  simp only [atom_eval]

/-! ## 2. The per-formula renderer -/

/-- **The per-formula renderer (Prop 3.5's `A_i`, PDF p.5, bounded to the mentioned atoms).**
Render a partial 1-type `c` over the mentioned-atom set `M` as the conjunction of atom literals
for exactly the atoms of `M`: positive literal where `c` is `true`, negated where `false`. The
fold is over `M.attach.toList` — per-formula-finite, no whole-alphabet enumeration. -/
noncomputable def unaryToFormulaFin
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) : Formula :=
  formula_conjList (M.attach.toList.map fun a =>
    atom_literal atomMap h_surj (atomPred1 a.1) (c a))

/-! ## 3. Render correctness -/

/-- **Render correctness (mirrors `nf_depth0_char_formula_correct`, bounded to `M`).** The
rendered formula holds at `t` (under temporal truth) iff `t` realizes the partial type `c`:
atom-wise agreement over exactly the mentioned atoms `M` (`partialHolds`). No correctness is
weakened — this IS the satisfaction notion of a quantifier-free one-variable formula over its
own finite syntax (Def 3.1, p.4). -/
theorem unaryToFormulaFin_correct
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) (t : N.carrier) :
    temporal_truth N atomMap t (unaryToFormulaFin atomMap h_surj c) ↔ partialHolds N c t := by
  simp only [unaryToFormulaFin]
  rw [formula_conjList_iff]
  simp only [partialHolds]
  constructor
  · intro h a
    have hmem : atom_literal atomMap h_surj (atomPred1 a.1) (c a) ∈
        M.attach.toList.map (fun a => atom_literal atomMap h_surj (atomPred1 a.1) (c a)) := by
      simp only [List.mem_map]
      exact ⟨a, by simp [Finset.mem_toList, Finset.mem_attach], rfl⟩
    have hlit := (atom_literal_correct N atomMap h_surj (atomPred1 a.1) (c a) t).mp (h _ hmem)
    rw [atom_eval1_iff_interp]
    exact hlit
  · intro h φ hmem
    simp only [List.mem_map] at hmem
    obtain ⟨a, _, rfl⟩ := hmem
    refine (atom_literal_correct N atomMap h_surj (atomPred1 a.1) (c a) t).mpr ?_
    rw [← atom_eval1_iff_interp]
    exact h a

end Bimodal.Metalogic.WeakCanonical.Kamp
