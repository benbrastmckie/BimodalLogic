/-
Evidence for the Phase 3 blocker of `plans/04_bi-lasso-decision-layer.md`.

WHAT IS REFUTED.  Phase 3's third task reads:

    Derive the scan bounds: any property of `L.unroll` that holds at some `s > t` holds at some
    `s` with `t < s ≤ t + |mid| + |fwd|` (and the leftward mirror).  State these as the two
    lemmas `eval`'s temporal cases consume, in exactly the form they will be consumed.

Read as a bound on the *semantic* witness that `eval`'s `untl` case must find — which is the
reading "in exactly the form they will be consumed" forces, since `eval`'s `untl` case searches
for a time at which a *formula* holds, not for a time at which a *state predicate* holds — this
is false, and no bound computed from the lasso's segment lengths alone can replace it.

Two theorems below, both `sorry`-free:

1. `plan_scan_bound_fails` — the literal bound `t + |mid| + |fwd|` fails already for the atomic
   formula, on a two-state presentation and a three-cell bi-lasso.

2. `no_formula_independent_scan_bound` — stronger, and the one that closes the design off:
   for EVERY integer `N` there is a formula whose earliest witness after `t = -1` exceeds `N`,
   on this one fixed bi-lasso.  Since `N` ranges over every quantity computable from
   `|back|`, `|mid|`, `|fwd|` and `t`, no scan bound that is a function of the lasso alone can
   be correct.  The witness family is `prevⁿ p`, whose truth set along this path is exactly
   `[n, ∞)`, so the earliest witness grows without bound while the lasso stays fixed at
   `|back| = 1`, `|mid| = 0`, `|fwd| = 1`.

WHY THIS BLOCKS PHASES 4, 5, 7, 8 AND 9.  `eval_correct` (Phase 5) needs, in the `→` direction of
its `untl` case, that a semantic witness implies a witness inside `eval`'s finite scan.  With the
scan range fixed by the lasso, theorem 2 refutes that implication outright.  A *correct* bound
must depend on the formula, and establishing one is the theorem that the truth set of `ψ` along a
bi-lasso is eventually periodic beyond a `ψ`-dependent threshold — a substantially larger result
than Phase 3 is sized for, and one that changes what Phases 4 and 5 look like.  Phases 7, 8, 9 all
consume Phase 5.

Argument order is guard-first throughout (`Syntax/Formula.lean:85,97`;
`specs/decisions/untl-snce-argument-order.md`): `Formula.untl g e` has guard `g`, event `e`.

Compile with: `lake env lean <this file>`.
-/
import FormalSystem.Metalogic.Decidability.BiLasso.Basic
import FormalSystem.Semantics.Truth

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace Phase3Blocker

/-! ## The presentation and the bi-lasso -/

/-- Two states with the reflexive, upward-closed step relation `w ≤ u`. Bi-serial because the
relation is reflexive. -/
def chainPresentation : IntPresentation where
  card := 2
  card_pos := by omega
  step := fun w u => decide (w ≤ u)
  val := fun _ w => w == 1
  fwd := fun w => ⟨w, by simp⟩
  bwd := fun w => ⟨w, by simp⟩

/-- The bi-lasso `… 0 0 0 | 1 1 1 …`: constant `0` strictly left of the origin, constant `1` from
the origin rightward. `|back| = 1`, `|mid| = 0`, `|fwd| = 1`. -/
def L : BiLasso chainPresentation where
  back := [0]
  mid := []
  fwd := [1]
  back_ne := by simp
  fwd_ne := by simp
  coherent := by decide

/-- The decoded path: `0` on the negatives, `1` elsewhere. -/
theorem unroll_eq (t : ℤ) :
    L.unroll t = if t < 0 then (0 : Fin chainPresentation.card)
      else (1 : Fin chainPresentation.card) := by
  by_cases ht : t < 0
  · rw [BiLasso.unroll_neg L ht, if_pos ht]
    simp [BiLasso.cyc, L, Int.emod_one]
  · rw [BiLasso.unroll_fwd L (by simp only [L, List.length_nil, Nat.cast_zero]; omega),
      if_neg ht]
    simp [BiLasso.cyc, L, Int.emod_one]

/-- The atom the valuation reads. -/
def pAtom : Atom := Atom.mkBase "p"

/-- The presented model. -/
abbrev M : TaskModel chainPresentation.toTaskFrame := chainPresentation.toModel

/-- The total world history the bi-lasso decodes to. -/
abbrev tau : WorldHistory chainPresentation.toTaskFrame := L.toHF.val

/-! ## The truth set of `prevⁿ p` along this path is exactly `[n, ∞)` -/

/-- The atom holds exactly from the origin rightward. -/
theorem truth_atom (s : ℤ) : TruthAt M tau s (Formula.atom pAtom) ↔ 0 ≤ s := by
  constructor
  · rintro ⟨hd, hv⟩
    have hv' : chainPresentation.val pAtom (L.unroll s) = true := hv
    by_contra hs
    rw [unroll_eq, if_pos (by omega : s < 0)] at hv'
    simp [chainPresentation] at hv'
  · intro hs
    refine ⟨trivial, ?_⟩
    show chainPresentation.val pAtom (L.unroll s) = true
    rw [unroll_eq, if_neg (by omega : ¬ s < 0)]
    simp [chainPresentation]

/-- Over ℤ the `⊥`-guarded `snce` is exactly the previous-time operator: the empty open interval
pins the witness to `s - 1`. -/
theorem truth_prev (s : ℤ) (psi : Formula) :
    TruthAt M tau s (Formula.snce Formula.bot psi) ↔ TruthAt M tau (s - 1) psi := by
  constructor
  · rintro ⟨z, hzlt, hpsi, hgap⟩
    have hz : z = s - 1 := by
      by_contra hne
      have hlt : z < s - 1 := by omega
      exact hgap (s - 1) hlt (by omega)
    rwa [hz] at hpsi
  · intro h
    exact ⟨s - 1, by omega, h, fun r h1 h2 => absurd h2 (by omega)⟩

/-- `prevⁿ`. -/
def prevN : ℕ → Formula → Formula
  | 0, psi => psi
  | (k + 1), psi => Formula.snce Formula.bot (prevN k psi)

/-- **The truth set of `prevⁿ p` along this bi-lasso is exactly `[n, ∞)`.** The lasso is fixed;
the threshold is not. -/
theorem truth_prevN (k : ℕ) (s : ℤ) :
    TruthAt M tau s (prevN k (Formula.atom pAtom)) ↔ (k : ℤ) ≤ s := by
  induction k generalizing s with
  | zero => simpa [prevN] using truth_atom s
  | succ n ih =>
    simp only [prevN]
    rw [truth_prev, ih]
    omega

/-- `⊤` is true everywhere, so it is a vacuous guard. -/
theorem truth_top (s : ℤ) : TruthAt M tau s Formula.top := fun h => h

/-! ## Result 1: the literal bound fails at the atomic formula -/

/--
**`t + |mid| + |fwd|` is not a scan bound.** At `t = -5` the formula `untl ⊤ p` — "`p` at some
strictly later time" — is true, yet `p` is false at every `s` in the scan range `(t, t+0+1]`.
-/
theorem plan_scan_bound_fails :
    TruthAt M tau (-5) (Formula.untl Formula.top (Formula.atom pAtom)) ∧
      ∀ s : ℤ, -5 < s → s ≤ -5 + (L.mid.length : ℤ) + (L.fwd.length : ℤ) →
        ¬ TruthAt M tau s (Formula.atom pAtom) := by
  constructor
  · exact ⟨0, by omega, (truth_atom 0).mpr le_rfl, fun r _ _ => truth_top r⟩
  · intro s h1 h2 hs
    have : (0 : ℤ) ≤ s := (truth_atom s).mp hs
    simp [L] at h2
    omega

/-! ## Result 2: no bound computed from the lasso alone can work -/

/--
**No formula-independent scan bound exists.** For every integer `N` — in particular for every
quantity computed from `|back| = 1`, `|mid| = 0`, `|fwd| = 1` and `t = -1` — there is a formula
that is witnessed strictly after `-1`, but at no time in `(-1, N]`.

The lasso is the *same* one throughout; only the formula moves. So the scan range `eval`'s `untl`
case searches cannot be a function of the lasso, and Phase 3's deliverable cannot be stated in the
form Phases 4 and 5 consume.
-/
theorem no_formula_independent_scan_bound (N : ℤ) :
    ∃ psi : Formula,
      TruthAt M tau (-1) (Formula.untl Formula.top psi) ∧
        ∀ s : ℤ, -1 < s → s ≤ N → ¬ TruthAt M tau s psi := by
  obtain ⟨k, hkN⟩ : ∃ k : ℕ, N < (k : ℤ) := ⟨N.toNat + 1, by omega⟩
  have hk0 : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg _
  refine ⟨prevN k (Formula.atom pAtom), ?_, ?_⟩
  · exact ⟨(k : ℤ), by omega, (truth_prevN k (k : ℤ)).mpr le_rfl, fun r _ _ => truth_top r⟩
  · intro s _ hsN hs
    have := (truth_prevN k s).mp hs
    omega

/-! ## Axiom audit -/

#print axioms Phase3Blocker.truth_prevN
#print axioms Phase3Blocker.plan_scan_bound_fails
#print axioms Phase3Blocker.no_formula_independent_scan_bound

end Phase3Blocker
