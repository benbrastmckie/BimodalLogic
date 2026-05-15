import Bimodal.Metalogic.WeakCanonical.MonadicFO
import Bimodal.Syntax.Formula

/-!
# Table Translation: Temporal Formulas to Monadic FO

Defines the standard translation from temporal formulas to monadic first-order
formulas with one free variable. This is the "table method" mapping temporal
formulas to their first-order equivalents, following Reynolds 1994 Section 6.

The key function `table` translates a temporal formula `φ` to a monadic FO
formula `C_φ(t)` with one free variable `t` (represented as `MonadicFormula sig 1`).
This follows Reynolds' convention: `C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))`.

## Status (Task 140)
- `table` definition: IMPLEMENTED (Reynolds Section 6, all 8 Formula constructors)
- `table_depth_bound`: PROVED (structural induction + `lift_quantifier_depth`)
- `temporal_truth`: DEFINED (semantic interpretation on OrderedMonadicStructure)
- `table_correctness`: PROVED for base cases (atom, bot, imp, box);
  temporal operator cases (G, H, U, S) sorry-propagating from `lift_eval` (Task 141)

## Design
The standard translation sends each temporal atom to a distinct monadic predicate.
The signature's `preds` type is indexed by formulas, providing the finite set
of predicates needed for a given formula's translation.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Helper: Operator Depth -/

/--
Operator depth: a natural number bounding the quantifier depth of the table
translation. Counts the nesting depth of temporal operators (modal + temporal)
in the formula.

Note: This is distinct from `Bimodal.Syntax.Formula.complexity` which counts
total structural complexity (sum of all subformula sizes). `operator_depth`
counts only the maximum nesting depth of modal/temporal operators, which
directly corresponds to quantifier depth in the FO translation.
-/
def operator_depth : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (operator_depth φ) (operator_depth ψ)
  | .box φ => operator_depth φ + 1
  | .all_future φ => operator_depth φ + 1
  | .all_past φ => operator_depth φ + 1
  | .untl φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
  | .snce φ ψ => max (operator_depth φ) (operator_depth ψ) + 2

/-! ## Standard Translation Table -/

/--
The standard translation "table" from temporal formulas to monadic
first-order formulas with one free variable over signature `sig`,
following Reynolds 1994 Section 6.

Parameters:
- `sig`: the monadic signature providing predicate symbols
- `atomMap`: maps temporal formulas (atoms and box-subformulas) to predicate symbols
- `φ`: the temporal formula to translate

Returns `MonadicFormula sig 1` — a formula with one free variable `t`
(De Bruijn index 0): `C_φ(t)`.

## Translation cases

| Formula | Reynolds FO | MonadicFormula encoding |
|---------|-------------|------------------------|
| atom a  | P_a(t) | `atom (atomMap (atom a)) 0` |
| bot     | t < t  | `lt 0 0` (always false) |
| imp φ ψ | ¬(C_φ ∧ ¬C_ψ) | `not (and (table φ) (not (table ψ)))` |
| box φ   | P_□φ(t) | `atom (atomMap (box φ)) 0` (MCS atom) |
| G φ     | ∀s>t, C_φ(s) | `all (not (and (lt 1 0) (not (C_φ at var 0))))` |
| H φ     | ∀s<t, C_φ(s) | `all (not (and (lt 0 1) (not (C_φ at var 0))))` |
| U(φ,ψ)  | ∃s>t(C_φ(s) ∧ ∀u(t<u<s→C_ψ(u))) | 2 quantifiers |
| S(φ,ψ)  | ∃s<t(C_φ(s) ∧ ∀u(s<u<t→C_ψ(u))) | 2 quantifiers |

## De Bruijn conventions

Variable naming in nested quantifier contexts:
- `MonadicFormula sig 1`: variable 0 = t (current time)
- After `all`/`ex`: variable 0 = new bound var, variable 1 = t
- After `ex` then `all`: variable 0 = inner, variable 1 = outer, variable 2 = t

`(table φ).lift 1` lifts the translation into a deeper binder context,
keeping variable 0 (the relevant time point) unchanged.
-/
def table (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (φ : Formula) : MonadicFormula sig 1 :=
  match φ with
  -- Atom: P_a(t)
  | .atom a => .atom (atomMap (.atom a)) ⟨0, by omega⟩
  -- Bot: t < t (always false)
  | .bot => .lt ⟨0, by omega⟩ ⟨0, by omega⟩
  -- Imp: ¬(C_φ ∧ ¬C_ψ)
  | .imp ψ₁ ψ₂ =>
    .not (.and (table sig atomMap ψ₁) (.not (table sig atomMap ψ₂)))
  -- Box: treated as atom via MCS labeling
  | .box ψ => .atom (atomMap (.box ψ)) ⟨0, by omega⟩
  -- all_future (G φ): ∀s, ¬(t < s ∧ ¬C_φ(s))
  -- In sig 2 context: var 0 = s, var 1 = t
  -- lt ⟨1, ..⟩ ⟨0, ..⟩ = t < s
  -- (table φ).lift 1 = C_φ(s) [var 0 preserved by lift at cutoff 1]
  | .all_future ψ =>
    .all (.not (.and
      (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
      (.not ((table sig atomMap ψ).lift 1))))
  -- all_past (H φ): ∀s, ¬(s < t ∧ ¬C_φ(s))
  -- lt ⟨0, ..⟩ ⟨1, ..⟩ = s < t
  | .all_past ψ =>
    .all (.not (.and
      (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
      (.not ((table sig atomMap ψ).lift 1))))
  -- Until U(φ, ψ): ∃s > t, C_φ(s) ∧ ∀u(t < u ∧ u < s → C_ψ(u))
  -- In sig 2 (after ex): var 0 = s, var 1 = t
  --   t < s: lt ⟨1, ..⟩ ⟨0, ..⟩
  --   C_φ(s): (table φ).lift 1 [var 0 = s]
  -- In sig 3 (after ex then all): var 0 = u, var 1 = s, var 2 = t
  --   t < u: lt ⟨2, ..⟩ ⟨0, ..⟩
  --   u < s: lt ⟨0, ..⟩ ⟨1, ..⟩
  --   C_ψ(u): ((table ψ).lift 1).lift 1 [var 0 = u preserved]
  | .untl ψ₁ ψ₂ =>
    .ex (.and
      (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s
      (.and
        ((table sig atomMap ψ₁).lift 1)    -- C_φ(s)
        (.all (.not (.and
          (.and
            (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)   -- t < u
            (.lt ⟨0, by omega⟩ ⟨1, by omega⟩))   -- u < s
          (.not (((table sig atomMap ψ₂).lift 1).lift 1)))))))  -- ¬C_ψ(u)
  -- Since S(φ, ψ): ∃s < t, C_φ(s) ∧ ∀u(s < u ∧ u < t → C_ψ(u))
  -- Symmetric to Until with reversed order direction
  -- In sig 2 (after ex): var 0 = s, var 1 = t
  --   s < t: lt ⟨0, ..⟩ ⟨1, ..⟩
  -- In sig 3 (after ex then all): var 0 = u, var 1 = s, var 2 = t
  --   s < u: lt ⟨1, ..⟩ ⟨0, ..⟩
  --   u < t: lt ⟨0, ..⟩ ⟨2, ..⟩
  | .snce ψ₁ ψ₂ =>
    .ex (.and
      (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t
      (.and
        ((table sig atomMap ψ₁).lift 1)    -- C_φ(s)
        (.all (.not (.and
          (.and
            (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)   -- s < u
            (.lt ⟨0, by omega⟩ ⟨2, by omega⟩))   -- u < t
          (.not (((table sig atomMap ψ₂).lift 1).lift 1)))))))  -- ¬C_ψ(u)

/-- Lifting preserves quantifier depth. -/
theorem lift_quantifier_depth {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) (c : Nat) :
    (α.lift c).quantifier_depth = α.quantifier_depth := by
  induction α generalizing c with
  | atom _ _ => rfl
  | lt _ _ => rfl
  | not α ih => simp [MonadicFormula.lift, MonadicFormula.quantifier_depth, ih]
  | and α β ihα ihβ => simp [MonadicFormula.lift, MonadicFormula.quantifier_depth, ihα, ihβ]
  | all α ih => simp [MonadicFormula.lift, MonadicFormula.quantifier_depth, ih]
  | ex α ih => simp [MonadicFormula.lift, MonadicFormula.quantifier_depth, ih]

/-- The quantifier depth of the table translation is bounded by the operator depth.
    Each temporal operator contributes: G/H → 1 quantifier, U/S → 2 quantifiers,
    box → 0 quantifiers (treated as atom). -/
theorem table_depth_bound (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (φ : Formula) :
    (table sig atomMap φ).quantifier_depth ≤ operator_depth φ := by
  induction φ with
  | atom _ => simp [table, MonadicFormula.quantifier_depth, operator_depth]
  | bot => simp [table, MonadicFormula.quantifier_depth, operator_depth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, MonadicFormula.quantifier_depth, operator_depth]
    omega
  | box _ => simp [table, MonadicFormula.quantifier_depth, operator_depth]
  | all_future ψ ih =>
    simp only [table, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
    omega
  | all_past ψ ih =>
    simp only [table, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
    omega
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
    omega
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
    omega

/-! ## Table Correctness -/

/--
Temporal truth on an ordered monadic structure: the intended semantic
interpretation of temporal formulas where atoms are interpreted by the
structure's predicate symbols via `atomMap`.

For atoms and box-subformulas, truth is determined by the structure's
predicate interpretation (through `atomMap`). For temporal operators,
truth is defined by quantification over the carrier's linear order.

This mirrors `truth_at` from `Theories/Bimodal/Semantics/Truth.lean`
but operates on `OrderedMonadicStructure` rather than `TaskModel`.
-/
def temporal_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) : Formula → Prop
  | .atom a => M.interp (atomMap (.atom a)) t
  | .bot => False
  | .imp φ ψ => temporal_truth M atomMap t φ → temporal_truth M atomMap t ψ
  | .box φ => M.interp (atomMap (.box φ)) t
  | .all_future φ => ∀ s : M.carrier, t < s → temporal_truth M atomMap s φ
  | .all_past φ => ∀ s : M.carrier, s < t → temporal_truth M atomMap s φ
  | .untl φ ψ => ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s φ ∧
      ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ
  | .snce φ ψ => ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s φ ∧
      ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ

/--
Helper: `lift_eval` specialized to cutoff 1 for use in table_correctness.
`eval M (insertEnv 1 x env) (α.lift 1) = eval M env α`
-/
private theorem cons_eq_insertEnv_one {α : Type} (s t : α) :
    (Fin.cons s (fun (_ : Fin 1) => t) : Fin 2 → α) =
    insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
  sorry -- Task 141: proof in progress

private theorem lift1_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) (s : M.carrier)
    (α : MonadicFormula sig 1) :
    eval M (Fin.cons s (fun _ => t)) (α.lift 1) =
    eval M (fun _ => s) α := by
  rw [cons_eq_insertEnv_one]
  exact lift_eval M (fun _ => s) ⟨1, by omega⟩ t α

private theorem cons3_eq_insertEnv {α : Type} (u s t : α) :
    (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) : Fin 3 → α) =
    insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
  sorry -- Task 141: proof in progress

/-- Double lift for the 3-variable context in Until/Since. -/
private theorem lift1_lift1_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (t s u : M.carrier)
    (α : MonadicFormula sig 1) :
    eval M (Fin.cons u (Fin.cons s (fun _ => t))) ((α.lift 1).lift 1) =
    eval M (fun _ => u) α := by
  -- First lift: α.lift 1 : MonadicFormula sig 2
  -- Second lift: (α.lift 1).lift 1 : MonadicFormula sig 3
  -- eval at Fin.cons u (Fin.cons s (fun _ => t)) = eval at (fun _ => u) after undoing both lifts
  rw [cons3_eq_insertEnv]
  rw [lift_eval M (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
  exact lift1_eval M t u α

/--
**Table Correctness** (Reynolds 1994, Section 6):
The standard translation preserves temporal truth. Evaluating the monadic
FO translation of `φ` at time `t` is equivalent to the temporal truth
of `φ` at `t` on the same ordered monadic structure.

Formally: `eval M (fun _ => t) (table sig atomMap φ) ↔ temporal_truth M atomMap t φ`

This theorem connects the syntactic translation (`table`) to the semantic
interpretation (`temporal_truth`), establishing that the table method is
both sound and complete.
-/
theorem table_correctness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula) :
    eval M (fun _ => t) (table sig atomMap φ) ↔ temporal_truth M atomMap t φ := by
  induction φ generalizing t with
  | atom a =>
    simp only [table, eval, temporal_truth]
  | bot =>
    simp only [table, eval, temporal_truth, lt_irrefl]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, eval, temporal_truth]
    constructor
    · intro h hψ₁
      push_neg at h
      exact (ih₂ t).mp (h ((ih₁ t).mpr hψ₁))
    · intro h ⟨hψ₁_eval, hψ₂_not⟩
      exact hψ₂_not ((ih₂ t).mpr (h ((ih₁ t).mp hψ₁_eval)))
  | box ψ =>
    simp only [table, eval, temporal_truth]
  | all_future ψ ih =>
    -- G ψ: ∀s > t, C_ψ(s) ↔ ∀s, t < s → temporal_truth s ψ
    simp only [table, eval, temporal_truth]
    sorry  -- depends on lift_eval (sorry-propagating from NEquivalence)
  | all_past ψ ih =>
    simp only [table, eval, temporal_truth]
    sorry  -- depends on lift_eval (sorry-propagating from NEquivalence)
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, eval, temporal_truth]
    sorry  -- depends on lift_eval (sorry-propagating from NEquivalence)
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table, eval, temporal_truth]
    sorry  -- depends on lift_eval (sorry-propagating from NEquivalence)


end Bimodal.Metalogic.WeakCanonical
