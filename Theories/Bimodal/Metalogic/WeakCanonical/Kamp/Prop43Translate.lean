import Bimodal.Metalogic.WeakCanonical.Kamp.LiftPair
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeSatNegation

/-!
# δ — structural Proposition 4.3 `translate` (monadic FO → ∨∃∀, PDF p.6)

Rabinovich Proposition 4.3 (p.6): every monadic first-order formula over the E[Σ] alphabet is,
on strictly-increasing environments, equivalent to a `∨∃∀`-formula. This module proves the
correctness statement by **well-founded recursion on `MonadicFormula.size`**
(`translate_correctFin`, `termination_by φ.size`) on the per-formula (Fin) representation,
reusing the landed connective machinery of the earlier phases. (The total-type twin
`translate_correct` and its `∃`-closure assembly `ex_closure_translate` were DELETED at the
switchover, along with the total-type helpers `ExistsForallFormula.renamePin` /
`efSat_renamePin` / `veeSat_renamePin` / `skelDisjunct_efSat` / `atomEmit` / `atomEmit_iff` /
`strictMono_of_veeSat_pin_mono` — the §4 Fin layer carries their Fin twins; the §0 eval
substrate, the gap-insertion permutation block, and the §2c witness classification remain.)

- **atom** `P(z_i)`: emit, via `hCapture`, the interval `S = {τ | τ ⊨ P}` at the pinned free
  variable `i`, realized as the sub-disjunction of the universally-satisfiable skeleton
  `skelRFin` keeping exactly the point-type assignments whose `i`-th type lies in `S`
  (`atomEmitFin`). This is the base case that is **impossible on complete types** and only
  works because the interval sets are *partial* (admissible-completion) sets (report 09 §5,
  "this is where (A) pays off").
- **lt** `z_i < z_j`: index-decided under `StrictMono` (`StrictMono.lt_iff_lt`): emit the
  tautological skeleton `skelRFin` when `i < j`, and the empty disjunction `[]` when `j ≤ i`.
- **and**: the landed `veeConjFin_iff` (`VeeConj.lean` Fin layer).
- **not**: the landed `veeSat_negationFin` (`VeeSatNegation.lean` Fin layer), threading
  `hCapture` / `hne` uniformly.
- **ex** / **all**: the order-unconstrained De Bruijn binder prepends a witness at index 0; the
  induction hypothesis is gated on `StrictMono (Fin.cons a env)`, which fails for witnesses that
  are not the least element. Per report 14 (path (c)) the closure lives on the `eval` side. §0
  lands the substrate: `MonadicFormula.rename`/`eval_rename` (variable reindexing +
  eval-naturality), `MonadicFormula.size`/`size_rename` (the rename-preserving well-founded
  measure), `MonadicFormula.subst0`/`eval_subst0` (the tie substitution `x = env i`), and
  `ExistsForallFormulaFin.renamePin`/`veeSatFin_renamePin` (the ∃∀-side free-variable
  permutation that pushes a gap witness to rank 0 — report 14 §4's flagged pin-rank risk,
  discharged). The
  well-founded-`size` restructure is now LANDED (the recursion fires on the size-smaller
  `α.subst0 i` / `α.rename (insertPerm p)`), together with the gap-insertion permutation
  `insertPerm` + `insertNth_comp_insertPerm` + `eval_insertNth_rename`. The residual (the two
  tracked strategic `sorry`s at `ex`/`all`) is the *disjunction assembly* — specifically the
  **forward direction of the gap disjuncts**: whether the emitted gap disjunct `D_p` fires only on
  genuine gap-`p` witnesses. That reduces to whether `translate`'s output pins the environment at
  monotone ranks (in which case the strict-mono internal chain forces the witness into gap `p`
  automatically) or whether an explicit per-gap order-constraint conjunct is required. See the
  strategic-sorry comments below and the handoff.

## Model-dependence (why this is a theorem, not a bare function)

The emitted disjunction depends on the model `N` (the atom interval comes from `hCapture`,
the negation formula from the negation stack via classical choice). So the deliverable is the
existential-by-induction correctness theorem `translate_correctFin`, in exactly the shape β
(`efSat_negation_generalFin`) and γ (`veeSat_negationFin`) already take — not a
model-independent `MonadicFormula → VeeExistsForall` function.

## Threaded hypotheses (never discharged — CONDITIONAL orphan until ζ)

`translate_correctFin` carries the same `N / atomMap / h_surj / h_INF / h_SUP / hCapture / hne`
hypotheses β/γ thread. `hCapture` (interval-level capture) and `hne` are **threaded, never
discharged** — their discharge is the Phase-ζ concern. This module stays OFF the live import path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 (p.6), Definition 3.1 (p.4).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `LiftPair.lean`: `skelDisjunct`, `skelR`, `skelR_sat`, `charType`, `unaryHolds_charType`,
  `intervalHolds_top` — the universally-satisfiable arity-`m+1` skeleton.
- `VeeConj.lean`: `veeConj`, `veeConj_iff` (Lemma 3.4, ∧-part).
- `VeeSatNegation.lean`: `veeSat_negation` (Prop 4.3, ¬-case).
- `ExistsForallLemmas.lean`: `veeSat_exists` (Lemma 3.4, ∃-closure).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}

/-! ## 0. Eval-side reindexing infrastructure (path (c): `rename`, `size`, `subst0`)

The `ex`/`all` cases of `translate_correct` need to relate `eval N (Fin.cons x env) α` at an
*unordered* witness insertion to `eval` at a strictly-increasing chain, where the induction
hypothesis is available. Following report 14 (path (c)), the bridge lives on the `eval` side:

- `MonadicFormula.rename` — variable reindexing along an arbitrary index map `ρ : Fin n → Fin n'`,
  generalizing the landed `MonadicFormula.lift` (which is `rename` along `finLift c`).
- `eval_rename` — its eval-naturality lemma, `eval M env' (α.rename ρ) = eval M (env' ∘ ρ) α`,
  mirroring `lift_eval`.
- `MonadicFormula.size` — a connective-count measure that `rename` provably preserves (unlike the
  auto-`sizeOf`, which counts the `Fin` indices), enabling well-founded induction over a *renamed*
  subformula.
- `MonadicFormula.subst0` / `eval_subst0` — the tie substitution identifying the bound variable `0`
  with a free variable `i` (a special case of `rename`), for witnesses `x = env i`. -/

/-- **Variable reindexing.** Reindex the free variables of a monadic formula along an arbitrary
index map `ρ : Fin n → Fin n'`. Generalizes `MonadicFormula.lift` (which is `rename (finLift c)`).
Under a binder, `ρ` is lifted to fix the bound variable `0` and shift the rest: `Fin.cons 0
(Fin.succ ∘ ρ)`. -/
def _root_.Bimodal.Metalogic.WeakCanonical.MonadicFormula.rename {sig : MonadicSignature} :
    {n n' : Nat} → (Fin n → Fin n') → MonadicFormula sig n → MonadicFormula sig n'
  | _, _, ρ, .atom p i => .atom p (ρ i)
  | _, _, ρ, .lt i j => .lt (ρ i) (ρ j)
  | _, _, ρ, .not α => .not (MonadicFormula.rename ρ α)
  | _, _, ρ, .and α β => .and (MonadicFormula.rename ρ α) (MonadicFormula.rename ρ β)
  | _, _, ρ, .all α => .all (MonadicFormula.rename (Fin.cons 0 (fun i => (ρ i).succ)) α)
  | _, _, ρ, .ex α => .ex (MonadicFormula.rename (Fin.cons 0 (fun i => (ρ i).succ)) α)

/-- The environment composition underlying the binder case of `eval_rename`: consing a fresh value
at the front commutes with the lifted rename map. -/
theorem cons_comp_liftRename {M : Type*} {n n' : Nat} (ρ : Fin n → Fin n')
    (env' : Fin n' → M) (x : M) :
    (Fin.cons x env') ∘ (Fin.cons 0 (fun i => (ρ i).succ)) = Fin.cons x (env' ∘ ρ) := by
  funext k
  refine Fin.cases ?_ ?_ k
  · simp [Fin.cons_zero]
  · intro i; simp [Fin.cons_succ]

/-- **Eval-naturality of `rename`.** Evaluating a renamed formula under `env'` equals evaluating the
original under the reindexed environment `env' ∘ ρ`. The `eval`-side analogue of `lift_eval`. -/
theorem eval_rename {sig : MonadicSignature} (M : OrderedMonadicStructure sig) :
    ∀ {n n' : Nat} (ρ : Fin n → Fin n') (env' : Fin n' → M.carrier)
      (α : MonadicFormula sig n),
      eval M env' (α.rename ρ) = eval M (env' ∘ ρ) α := by
  intro n n' ρ env' α
  induction α generalizing n' with
  | atom p i => rfl
  | lt i j => rfl
  | not α ih => simp only [MonadicFormula.rename, eval]; rw [ih ρ env']
  | and α β ihα ihβ =>
    simp only [MonadicFormula.rename, eval]; rw [ihα ρ env', ihβ ρ env']
  | all α ih =>
    simp only [MonadicFormula.rename, eval]
    have key : ∀ x, eval M (Fin.cons x env') (α.rename (Fin.cons 0 (fun i => (ρ i).succ)))
        = eval M (Fin.cons x (env' ∘ ρ)) α := by
      intro x
      rw [ih (Fin.cons 0 (fun i => (ρ i).succ)) (Fin.cons x env'), cons_comp_liftRename ρ env' x]
    simp_rw [key]
  | ex α ih =>
    simp only [MonadicFormula.rename, eval]
    have key : ∀ x, eval M (Fin.cons x env') (α.rename (Fin.cons 0 (fun i => (ρ i).succ)))
        = eval M (Fin.cons x (env' ∘ ρ)) α := by
      intro x
      rw [ih (Fin.cons 0 (fun i => (ρ i).succ)) (Fin.cons x env'), cons_comp_liftRename ρ env' x]
    simp_rw [key]

/-- **Connective-count size.** Counts only the logical connectives/quantifiers (not the `Fin`
indices), so it is preserved by `rename`. This is the well-founded measure under which a renamed
subformula is strictly smaller than a quantified formula. -/
def _root_.Bimodal.Metalogic.WeakCanonical.MonadicFormula.size {sig : MonadicSignature} :
    {n : Nat} → MonadicFormula sig n → Nat
  | _, .atom _ _ => 0
  | _, .lt _ _ => 0
  | _, .not α => α.size + 1
  | _, .and α β => α.size + β.size + 1
  | _, .all α => α.size + 1
  | _, .ex α => α.size + 1

/-- `rename` preserves the connective-count size (it rebuilds the same constructor tree, only
touching leaves and index maps). This is what makes the well-founded-size induction fire on a
renamed subformula. -/
theorem size_rename {sig : MonadicSignature} :
    ∀ {n n' : Nat} (ρ : Fin n → Fin n') (α : MonadicFormula sig n),
      (α.rename ρ).size = α.size := by
  intro n n' ρ α
  induction α generalizing n' with
  | atom p i => rfl
  | lt i j => rfl
  | not α ih => simp only [MonadicFormula.rename, MonadicFormula.size]; rw [ih ρ]
  | and α β ihα ihβ =>
    simp only [MonadicFormula.rename, MonadicFormula.size]; rw [ihα ρ, ihβ ρ]
  | all α ih => simp only [MonadicFormula.rename, MonadicFormula.size]; rw [ih _]
  | ex α ih => simp only [MonadicFormula.rename, MonadicFormula.size]; rw [ih _]

/-- **Tie substitution.** Identify the bound variable `0` of an `(m+1)`-ary formula with the free
variable `i`, producing an `m`-ary formula. Realized as `rename` along `Fin.cons i id`
(`0 ↦ i`, `j+1 ↦ j`). Used for existential witnesses `x = env i` (ties), which admit no
strictly-monotone reordering. -/
def _root_.Bimodal.Metalogic.WeakCanonical.MonadicFormula.subst0 {sig : MonadicSignature} {m : Nat}
    (i : Fin m) (α : MonadicFormula sig (m + 1)) : MonadicFormula sig m :=
  α.rename (Fin.cons i (fun j => j))

/-- **Eval of the tie substitution.** Evaluating `α.subst0 i` under `env` equals evaluating `α`
under `Fin.cons (env i) env` — i.e. binding the quantified variable to the existing point
`env i`. -/
theorem eval_subst0 {sig : MonadicSignature} {m : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin m → M.carrier) (i : Fin m) (α : MonadicFormula sig (m + 1)) :
    eval M env (α.subst0 i) = eval M (Fin.cons (env i) env) α := by
  rw [MonadicFormula.subst0, eval_rename M (Fin.cons i (fun j => j)) env α]
  congr 1
  funext k
  refine Fin.cases ?_ ?_ k
  · simp [Fin.cons_zero]
  · intro j; simp [Fin.cons_succ]

/-- `subst0` preserves the connective-count size. -/
theorem size_subst0 {sig : MonadicSignature} {m : Nat} (i : Fin m)
    (α : MonadicFormula sig (m + 1)) : (α.subst0 i).size = α.size := by
  rw [MonadicFormula.subst0, size_rename]

/-! ### The gap-insertion permutation (front insertion ↦ sorted insertion)

The gap half of the `ex` closure inserts an unordered witness `x` at the *front* of `env`
(`Fin.cons x env`), then reorders it to its sorted rank `p` (`Fin.insertNth p x env`, a
strictly-increasing chain when `x` sits in gap `p`). The permutation bridging the two is
`insertPerm p : Equiv.Perm (Fin (m+1))`, sending rank `0` to `p` and `j+1` to `p.succAbove j`. -/

/-- The permutation of `Fin (m+1)` sending `0 ↦ p` and `j+1 ↦ p.succAbove j`. Reindexes the sorted
insertion `Fin.insertNth p x env` back to the front insertion `Fin.cons x env`. -/
noncomputable def insertPerm {m : Nat} (p : Fin (m + 1)) : Equiv.Perm (Fin (m + 1)) :=
  Equiv.ofBijective (Fin.cons p p.succAbove)
    (Finite.injective_iff_bijective.mp (by
      rw [Fin.cons_injective_iff]
      refine ⟨?_, Fin.succAbove_right_injective⟩
      simp only [Set.mem_range, not_exists]
      exact fun j => (Fin.succAbove_ne p j)))

@[simp] theorem insertPerm_zero {m : Nat} (p : Fin (m + 1)) : insertPerm p 0 = p := by
  simp [insertPerm, Equiv.ofBijective_apply]

@[simp] theorem insertPerm_succ {m : Nat} (p : Fin (m + 1)) (j : Fin m) :
    insertPerm p j.succ = p.succAbove j := by
  simp [insertPerm, Equiv.ofBijective_apply]

/-- **Composition identity.** Reindexing the sorted insertion by `insertPerm p` recovers the front
insertion: `Fin.insertNth p x env ∘ insertPerm p = Fin.cons x env`. This is the bridge that lets
`eval_rename` rewrite `eval (Fin.cons x env) α` as `eval (Fin.insertNth p x env) (α.rename …)`. -/
theorem insertNth_comp_insertPerm {α : Type*} {m : Nat} (p : Fin (m + 1)) (x : α)
    (env : Fin m → α) :
    (Fin.insertNth p x env) ∘ (insertPerm p : Fin (m + 1) → Fin (m + 1)) = Fin.cons x env := by
  funext k
  refine Fin.cases ?_ ?_ k
  · simp [Function.comp, Fin.insertNth_apply_same]
  · intro j; simp [Function.comp, Fin.insertNth_apply_succAbove]

/-- Restated with `insertPerm p |>.symm`: the sorted insertion equals the front insertion
reindexed by the inverse permutation. Used on the `veeSat` side after `veeSat_renamePin`. -/
theorem cons_comp_insertPerm_symm {α : Type*} {m : Nat} (p : Fin (m + 1)) (x : α)
    (env : Fin m → α) :
    (Fin.cons x env) ∘ ((insertPerm p).symm : Fin (m + 1) → Fin (m + 1))
      = Fin.insertNth p x env := by
  rw [← insertNth_comp_insertPerm p x env]
  funext k
  simp [Function.comp, Equiv.apply_symm_apply]

/-- **Gap eval-bridge.** Evaluating the reindexed body `α.rename (insertPerm p)` on the *sorted*
insertion `Fin.insertNth p x env` equals evaluating `α` on the *front* insertion `Fin.cons x env`.
The `ex` gap half uses this to move a gap witness onto a strictly-increasing chain (where the
recursive translation applies) while preserving the eval value. Combines `eval_rename` with the
`insertNth_comp_insertPerm` composition identity. -/
theorem eval_insertNth_rename {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (p : Fin (m + 1)) (x : M.carrier)
    (env : Fin m → M.carrier) (α : MonadicFormula sig (m + 1)) :
    eval M (Fin.insertNth p x env) (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      = eval M (Fin.cons x env) α := by
  rw [eval_rename M (insertPerm p : Fin (m + 1) → Fin (m + 1)) (Fin.insertNth p x env) α,
    insertNth_comp_insertPerm p x env]

/-! ## 2c. Witness classification for the `ex`/`all` gap-tie split -/

/-- **`insertNth` is strictly monotone when `x` fits its gap.** If `env` is strictly monotone, `x`
exceeds every env value placed strictly before position `p`, and `x` is below every env value placed
at-or-after `p`, then inserting `x` at `p` yields a strictly monotone chain. -/
theorem strictMono_insertNth {m : Nat} {C : Type*} [LinearOrder C] (p : Fin (m + 1)) (x : C)
    (env : Fin m → C) (henv : StrictMono env)
    (hlt : ∀ j : Fin m, j.castSucc < p → env j < x)
    (hgt : ∀ j : Fin m, p ≤ j.castSucc → x < env j) :
    StrictMono (Fin.insertNth p x env) := by
  intro a b hab
  rcases eq_or_ne p a with rfl | hpa
  · obtain ⟨j, rfl⟩ := Fin.exists_succAbove_eq (Ne.symm (ne_of_lt hab))
    rw [Fin.insertNth_apply_same, Fin.insertNth_apply_succAbove]
    apply hgt j
    by_contra hcon
    push_neg at hcon
    rw [Fin.succAbove_of_castSucc_lt p j hcon] at hab
    exact absurd (hab.trans hcon) (lt_irrefl p)
  · rcases eq_or_ne p b with rfl | hpb
    · obtain ⟨i, rfl⟩ := Fin.exists_succAbove_eq (Ne.symm hpa)
      rw [Fin.insertNth_apply_succAbove, Fin.insertNth_apply_same]
      apply hlt i
      by_contra hcon
      push_neg at hcon
      rw [Fin.succAbove_of_le_castSucc p i hcon] at hab
      exact absurd (lt_trans (lt_of_le_of_lt hcon Fin.castSucc_lt_succ) hab) (lt_irrefl p)
    · obtain ⟨i, rfl⟩ := Fin.exists_succAbove_eq (Ne.symm hpa)
      obtain ⟨j, rfl⟩ := Fin.exists_succAbove_eq (Ne.symm hpb)
      rw [Fin.insertNth_apply_succAbove, Fin.insertNth_apply_succAbove]
      exact henv ((Fin.strictMono_succAbove p).lt_iff_lt.mp hab)

/-- **Witness classification.** For a strictly monotone `env : Fin m → C` and any `x`, either `x` is
a tie (`x = env i` for some `i`) or there is a gap position `p` — the count of env points `< x` — at
which inserting `x` yields a strictly monotone chain `Fin.insertNth p x env`. -/
theorem witness_classification {m : Nat} {C : Type*} [LinearOrder C] (env : Fin m → C)
    (henv : StrictMono env) (x : C) :
    (∃ i : Fin m, x = env i) ∨ ∃ p : Fin (m + 1), StrictMono (Fin.insertNth p x env) := by
  classical
  by_cases htie : ∃ i : Fin m, x = env i
  · exact Or.inl htie
  · push_neg at htie
    have hb : (Finset.univ.filter (fun i => env i < x)).card < m + 1 := by
      have h := Finset.card_filter_le (Finset.univ : Finset (Fin m)) (fun i => env i < x)
      simp only [Finset.card_univ, Fintype.card_fin] at h; omega
    refine Or.inr ⟨⟨(Finset.univ.filter (fun i => env i < x)).card, hb⟩, ?_⟩
    apply strictMono_insertNth _ x env henv
    · intro j hj
      rw [strictMono_lt_iff_val_lt_filterCard env henv x j]
      have hval := Fin.lt_def.mp hj
      simpa [Fin.val_castSucc] using hval
    · intro j hj
      have hle := Fin.le_def.mp hj
      have hnlt : ¬ (env j < x) := by
        rw [strictMono_lt_iff_val_lt_filterCard env henv x j]
        simp only [Fin.val_castSucc] at hle; omega
      exact lt_of_le_of_ne (le_of_not_gt hnlt) (htie j)

/-! ## 4. Fin layer: structural Prop 4.3 on the per-formula representation

Fin counterparts of sections 1-3 on `ExistsForallFormulaFin`/`efSatFin`/`veeSatFin`. The §0
eval-side substrate (`rename`/`eval_rename`/`size`/`subst0`/`insertPerm`/
`eval_insertNth_rename`) and the §2c order-theoretic witness classification are
alphabet-independent and reused verbatim. The skeleton is `skelDisjunctFin`/`skelRFin`
(`LiftPair.lean` §11.2) over an ambient mentioned set `M`; the atom base case enumerates
`M`-relatively over the CAPTURED set's `M` (never the whole alphabet); negation is
`veeSat_negationFin`, conjunction `veeConjFin`, ∃-closure `veeSatFin_exists`. The
`StrictMono ψ.pin` strengthening (Fact P-comp) is preserved verbatim. NO alphabet instances. -/

section FinLayer

variable {sig₀ : MonadicSignature} {F₀ : Finset Formula}

/-- Fin-variant of `ExistsForallFormula.renamePin`: reindex the free variables of a per-formula
`∃∀`-formula along `τ : Fin r' → Fin r` (compose the pin map with `τ`; chain, `M`, and partial
types unchanged). -/
def ExistsForallFormulaFin.renamePin {r r' : Nat} (τ : Fin r' → Fin r)
    (ψ : ExistsForallFormulaFin sig₀ F₀ r) : ExistsForallFormulaFin sig₀ F₀ r' where
  n := ψ.n
  M := ψ.M
  pin := fun k => ψ.pin (τ k)
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- Fin-variant of `efSat_renamePin`: `efSatFin` naturality under a free-variable permutation.
Only the pin clause reindexes; chain and partial-type clauses are shared verbatim. -/
theorem efSatFin_renamePin {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (σ : Equiv.Perm (Fin r)) (env : Fin r → N.carrier) (ψ : ExistsForallFormulaFin sig₀ F₀ r) :
    efSatFin N env (ψ.renamePin (σ : Fin r → Fin r)) ↔ efSatFin N (env ∘ σ.symm) ψ := by
  constructor
  · rintro ⟨x, hmono, hpin, hpt, hb, hbet, haf⟩
    refine ⟨x, hmono, ?_, hpt, hb, hbet, haf⟩
    intro j
    have h := hpin (σ.symm j)
    simpa [ExistsForallFormulaFin.renamePin, Function.comp, Equiv.apply_symm_apply] using h
  · rintro ⟨x, hmono, hpin, hpt, hb, hbet, haf⟩
    refine ⟨x, hmono, ?_, hpt, hb, hbet, haf⟩
    intro k
    have h := hpin (σ k)
    simpa [ExistsForallFormulaFin.renamePin, Function.comp, Equiv.symm_apply_apply] using h

/-- Fin-variant of `veeSat_renamePin`: `veeSatFin` naturality under a free-variable
permutation, disjunct-wise by `efSatFin_renamePin`. -/
theorem veeSatFin_renamePin {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (σ : Equiv.Perm (Fin r)) (env : Fin r → N.carrier) (Ψ : VeeExistsForallFin sig₀ F₀ r) :
    veeSatFin N env (Ψ.map (ExistsForallFormulaFin.renamePin (σ : Fin r → Fin r)))
      ↔ veeSatFin N (env ∘ σ.symm) Ψ := by
  unfold veeSatFin
  constructor
  · rintro ⟨χ, hmem, hsat⟩
    rw [List.mem_map] at hmem
    obtain ⟨ψ, hψmem, rfl⟩ := hmem
    exact ⟨ψ, hψmem, (efSatFin_renamePin N σ env ψ).1 hsat⟩
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨ψ.renamePin (σ : Fin r → Fin r), List.mem_map_of_mem hmem,
      (efSatFin_renamePin N σ env ψ).2 hsat⟩

/-- Fin-variant of `skelDisjunct_efSat`: on a strictly increasing environment, the
identity-pinned ⊤-interval per-formula disjunct `skelDisjunctFin M m σ` holds exactly when the
environment realizes `σ`'s partial point type at every point. -/
theorem skelDisjunctFin_efSat {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (σ : Fin (m + 1) → UnaryTypeFin sig₀ F₀ M) (env : Fin (m + 1) → N.carrier)
    (hmono : StrictMono env) :
    efSatFin N env (skelDisjunctFin M m σ) ↔
      ∀ j : Fin (m + 1), partialHolds N (σ j) (env j) := by
  constructor
  · rintro ⟨x, _, hxpin, hxpt, _, _, _⟩
    have hxeq : x = env := by
      funext k
      have h := hxpin k
      simp only [skelDisjunctFin, id_eq] at h
      exact h.symm
    intro j
    have h := hxpt j
    simp only [skelDisjunctFin] at h
    rw [hxeq] at h
    exact h
  · intro hpt
    refine ⟨env, hmono, ?_, ?_, ?_, ?_, ?_⟩
    · intro k; simp [skelDisjunctFin]
    · intro j; simpa [skelDisjunctFin] using hpt j
    · intro y _; exact intervalHoldsFin_top N y
    · intro i y _ _; simpa [skelDisjunctFin] using intervalHoldsFin_top N y
    · intro y _; simpa [skelDisjunctFin] using intervalHoldsFin_top N y

open Classical in
/-- Fin-variant of `atomEmit`: the sub-disjunction of the `M`-relative skeleton `skelRFin`
keeping exactly the partial point-type assignments whose type at the pinned variable `i` is
admissible for the captured `M`-relative interval `S`. Every enumeration is over
`UnaryTypeFin sig₀ F₀ M` — per-formula-finite from `M` alone, never alphabet-sized. -/
noncomputable def atomEmitFin {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (i : Fin (m + 1)) (S : IntervalTypeFin sig₀ F₀ M) :
    VeeExistsForallFin sig₀ F₀ (m + 1) :=
  ((Finset.univ : Finset (Fin (m + 1) → UnaryTypeFin sig₀ F₀ M)).filter
      (fun σ => σ i ∈ S)).toList.map (skelDisjunctFin M m)

/-- Fin-variant of `atomEmit_iff`: on a strictly increasing environment, `atomEmitFin i S` is
satisfied exactly when the captured partial interval `S` holds at `env i`
(`intervalHoldsFin`). Backward: the characteristic-completion assignment (`charTypeFin`)
updated to the admissible `τ` at position `i`. -/
theorem atomEmitFin_iff {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (N : OrderedMonadicStructure (sigE sig₀ F₀)) (i : Fin (m + 1))
    (S : IntervalTypeFin sig₀ F₀ M) (env : Fin (m + 1) → N.carrier) (hmono : StrictMono env) :
    veeSatFin N env (atomEmitFin i S) ↔ intervalHoldsFin N S (env i) := by
  classical
  unfold atomEmitFin veeSatFin
  simp only [List.mem_map, Finset.mem_toList, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨ψ, ⟨σ, hσS, rfl⟩, hsat⟩
    have hpt := (skelDisjunctFin_efSat N σ env hmono).mp hsat
    exact ⟨σ i, hσS, hpt i⟩
  · rintro ⟨τ, hτS, hτ⟩
    refine ⟨skelDisjunctFin M m (Function.update (fun v => charTypeFin N M (env v)) i τ),
      ⟨Function.update (fun v => charTypeFin N M (env v)) i τ, ?_, rfl⟩, ?_⟩
    · rw [Function.update_self]; exact hτS
    · rw [skelDisjunctFin_efSat N _ env hmono]
      intro j
      by_cases hj : j = i
      · subst hj; rw [Function.update_self]; exact hτ
      · rw [Function.update_of_ne hj]; exact partialHolds_charTypeFin N M (env j)

/-- Fin-variant of `strictMono_of_veeSat_pin_mono` (Fact P-comp): a monotone pin imprints its
order type on any satisfying environment. -/
theorem strictMono_of_veeSatFin_pin_mono {m : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (w : Fin m → N.carrier) (Ψ : VeeExistsForallFin sig₀ F₀ m)
    (hmono : ∀ ψ ∈ Ψ, StrictMono ψ.pin) (hsat : veeSatFin N w Ψ) : StrictMono w := by
  obtain ⟨ψ, hψmem, x, hx, hpin, -⟩ := hsat
  intro a b hab
  rw [hpin a, hpin b]
  exact hx ((hmono ψ hψmem) hab)

/-- Fin-variant of `ex_closure_translate` (Rabinovich Prop 4.3, `∃`-case, PDF p.6): assemble
the existential closure from per-gap and per-tie translations. Forward: a satisfied gap
disjunct yields an unconditional witness whose sorted insertion is forced strictly monotone by
the monotone-pin invariant (`strictMono_of_veeSatFin_pin_mono`); backward: classify the eval
witness (`witness_classification`) as tie or gap. All eval-side bridges (`eval_subst0`,
`eval_insertNth_rename`) are the reused alphabet-independent §0 substrate. -/
theorem ex_closure_translateFin {m : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (α : MonadicFormula (sigE sig₀ F₀) (m + 1))
    (Ψg : Fin (m + 1) → VeeExistsForallFin sig₀ F₀ (m + 1))
    (hΨgmono : ∀ p, ∀ ψ ∈ Ψg p, StrictMono ψ.pin)
    (hΨg : ∀ (p : Fin (m + 1)) (env : Fin (m + 1) → N.carrier), StrictMono env →
        (veeSatFin N env (Ψg p) ↔ eval N env (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))))
    (Ψt : Fin m → VeeExistsForallFin sig₀ F₀ m)
    (hΨtmono : ∀ i, ∀ ψ ∈ Ψt i, StrictMono ψ.pin)
    (hΨt : ∀ (i : Fin m) (env : Fin m → N.carrier), StrictMono env →
        (veeSatFin N env (Ψt i) ↔ eval N env (α.subst0 i))) :
    ∃ Ψ : VeeExistsForallFin sig₀ F₀ m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ env : Fin m → N.carrier, StrictMono env →
      (veeSatFin N env Ψ ↔ ∃ x : N.carrier, eval N (Fin.cons x env) α) := by
  classical
  refine ⟨((List.finRange (m + 1)).flatMap fun p =>
             ((Ψg p).map (ExistsForallFormulaFin.renamePin
               (insertPerm p : Fin (m + 1) → Fin (m + 1)))).map dropPinFin)
          ++ ((List.finRange m).flatMap fun i => Ψt i), ?_, fun env hmono => ?_⟩
  · -- Pin-monotonicity of every disjunct: gap pins are `ψ.pin ∘ p.succAbove`; ties from `hΨtmono`.
    intro φ hφ
    rw [List.mem_append] at hφ
    rcases hφ with hφ | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨p, _, hφ⟩ := hφ
      rw [List.mem_map] at hφ
      obtain ⟨χ, hχmem, rfl⟩ := hφ
      rw [List.mem_map] at hχmem
      obtain ⟨ψ, hψmem, rfl⟩ := hχmem
      have hcomp : (dropPinFin (ExistsForallFormulaFin.renamePin
          (insertPerm p : Fin (m + 1) → Fin (m + 1)) ψ)).pin
          = ψ.pin ∘ (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ) := rfl
      rw [hcomp]
      have hsucc : (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ)
          = p.succAbove := by funext k; exact insertPerm_succ p k
      rw [hsucc]
      exact (hΨgmono p ψ hψmem).comp (Fin.strictMono_succAbove p)
    · rw [List.mem_flatMap] at hφ
      obtain ⟨i, _, hφ⟩ := hφ
      exact hΨtmono i φ hφ
  · -- Correctness: gap/tie forward + witness-classified backward.
    rw [veeSatFin_append]
    constructor
    · rintro (hgapv | htiev)
      · rw [veeSatFin_flatMap] at hgapv
        obtain ⟨p, _, hpv⟩ := hgapv
        rw [← veeSatFin_exists] at hpv
        obtain ⟨a, hav⟩ := hpv
        rw [veeSatFin_renamePin, cons_comp_insertPerm_symm] at hav
        have hsm : StrictMono (Fin.insertNth p a env) :=
          strictMono_of_veeSatFin_pin_mono N _ (Ψg p) (hΨgmono p) hav
        have heval := (hΨg p (Fin.insertNth p a env) hsm).mp hav
        rw [eval_insertNth_rename] at heval
        exact ⟨a, heval⟩
      · rw [veeSatFin_flatMap] at htiev
        obtain ⟨i, _, hiv⟩ := htiev
        have heval := (hΨt i env hmono).mp hiv
        rw [eval_subst0] at heval
        exact ⟨env i, heval⟩
    · rintro ⟨x, hx⟩
      rcases witness_classification env hmono x with ⟨i, rfl⟩ | ⟨p, hsm⟩
      · rw [← eval_subst0] at hx
        have hiv := (hΨt i env hmono).mpr hx
        refine Or.inr ?_
        rw [veeSatFin_flatMap]
        exact ⟨i, List.mem_finRange i, hiv⟩
      · rw [← eval_insertNth_rename N p x env α] at hx
        have hpv := (hΨg p (Fin.insertNth p x env) hsm).mpr hx
        rw [← cons_comp_insertPerm_symm p x env, ← veeSatFin_renamePin] at hpv
        refine Or.inl ?_
        rw [veeSatFin_flatMap]
        refine ⟨p, List.mem_finRange p, ?_⟩
        rw [← veeSatFin_exists]
        exact ⟨x, hpv⟩

/-- **Fin-variant of `translate_correct` (Rabinovich Prop 4.3, structural, PDF p.6).** Every
monadic FO formula over the E[Σ] alphabet is, on strictly increasing environments, equivalent
to a per-formula `∨∃∀`-formula, with the `StrictMono ψ.pin` invariant preserved on every
emitted disjunct. Well-founded recursion on `MonadicFormula.size`; atoms via the `M`-relative
`hCapture` + `atomEmitFin`, `lt` via `skelRFin ∅`, negation via `veeSat_negationFin`,
conjunction via `veeConjFin`, quantifiers via `ex_closure_translateFin`. `hCapture` / `hne`
threaded, never discharged (CONDITIONAL orphan until ζ). -/
theorem translate_correctFin
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (atomMap : Formula → (sigE sig₀ F₀).preds)
    (h_surj : ∀ p : (sigE sig₀ F₀).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ (M : Finset (AtomKind (sigE sig₀ F₀) 1))
        (S : IntervalTypeFin sig₀ F₀ M),
        ∀ y : N.carrier, intervalHoldsFin N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {m : Nat} (φ : MonadicFormula (sigE sig₀ F₀) m) :
    ∃ Ψ : VeeExistsForallFin sig₀ F₀ m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ env : Fin m → N.carrier, StrictMono env →
      (veeSatFin N env Ψ ↔ eval N env φ) := by
  classical
  match m, φ with
  | 0, .atom _ i => exact i.elim0
  | (m' + 1), .atom p i =>
      obtain ⟨a, ha⟩ := h_surj p
      obtain ⟨M, S, hS⟩ := hCapture (.atom a)
      refine ⟨atomEmitFin i S, ?_, fun env hmono => ?_⟩
      · intro φ' hφ'
        unfold atomEmitFin at hφ'
        rw [List.mem_map] at hφ'
        obtain ⟨σ, _, rfl⟩ := hφ'
        exact skelDisjunctFin_pin_strictMono σ
      rw [atomEmitFin_iff N i S env hmono, hS (env i)]
      show temporal_truth N atomMap (env i) (Formula.atom a) ↔ eval N env (MonadicFormula.atom p i)
      simp only [temporal_truth, ha, eval]
  | 0, .lt i _ => exact i.elim0
  | (m' + 1), .lt i j =>
      by_cases hij : i < j
      · refine ⟨skelRFin ∅ m', ?_, fun env hmono => ?_⟩
        · exact fun φ' hφ' => skelRFin_pin_strictMono φ' hφ'
        show veeSatFin N env (skelRFin ∅ m') ↔ env i < env j
        constructor
        · intro _; exact hmono.lt_iff_lt.mpr hij
        · intro _; exact skelRFin_sat N env hmono
      · refine ⟨[], ?_, fun env hmono => ?_⟩
        · intro φ' hφ'; exact absurd hφ' List.not_mem_nil
        show veeSatFin N env ([] : VeeExistsForallFin sig₀ F₀ (m' + 1)) ↔ env i < env j
        constructor
        · intro h; exact absurd h (veeSatFin_nil N env)
        · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | _, .not α =>
      obtain ⟨Ψα, _, hα⟩ := translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne α
      obtain ⟨Ψ', hΨ'mono, hΨ'⟩ := veeSat_negationFin N atomMap h_surj h_INF h_SUP hCapture hne Ψα
      refine ⟨Ψ', hΨ'mono, fun env hmono => ?_⟩
      show veeSatFin N env Ψ' ↔ ¬ eval N env α
      rw [← hΨ' env hmono, hα env hmono]
  | _, .and α β =>
      obtain ⟨Ψα, hαmono, hα⟩ := translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne α
      obtain ⟨Ψβ, _, hβ⟩ := translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne β
      refine ⟨veeConjFin Ψα Ψβ, ?_, fun env hmono => ?_⟩
      · exact fun χ hχ => veeConjFin_pin_strictMono Ψα Ψβ hαmono χ hχ
      show veeSatFin N env (veeConjFin Ψα Ψβ) ↔ eval N env α ∧ eval N env β
      rw [veeConjFin_iff N env Ψα Ψβ, hα env hmono, hβ env hmono]
  | m, .all α =>
      -- `all α = ¬∃¬`: ex-close the body `.not α`, then negate the closure (recursion fires only
      -- on the size-preserved renamed/substituted α-pieces).
      have hgap := fun p : Fin (m + 1) =>
        translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      have hgapN := fun p : Fin (m + 1) =>
        veeSat_negationFin N atomMap h_surj h_INF h_SUP hCapture hne (Ψg p)
      choose Ψg' hΨg'mono hΨg'neg using hgapN
      have htieN := fun i : Fin m =>
        veeSat_negationFin N atomMap h_surj h_INF h_SUP hCapture hne (Ψt i)
      choose Ψt' hΨt'mono hΨt'neg using htieN
      obtain ⟨Ψex, hΨexmono, hΨex⟩ :=
        ex_closure_translateFin N (.not α) Ψg' hΨg'mono
          (fun p env h => (hΨg'neg p env h).symm.trans (not_congr (hΨg p env h)))
          Ψt' hΨt'mono
          (fun i env h => (hΨt'neg i env h).symm.trans (not_congr (hΨt i env h)))
      obtain ⟨Ψall, hΨallmono, hΨall⟩ :=
        veeSat_negationFin N atomMap h_surj h_INF h_SUP hCapture hne Ψex
      refine ⟨Ψall, hΨallmono, fun env hmono => ?_⟩
      rw [← hΨall env hmono, hΨex env hmono]
      exact not_exists_not
  | m, .ex α =>
      -- Gap/tie ∃-closure assembly (`ex_closure_translateFin`), size-smaller IH throughout.
      have hgap := fun p : Fin (m + 1) =>
        translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_correctFin N atomMap h_surj h_INF h_SUP hCapture hne (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      exact ex_closure_translateFin N α Ψg hΨgmono hΨg Ψt hΨtmono hΨt
termination_by φ.size
decreasing_by
  all_goals simp only [MonadicFormula.size, size_rename, size_subst0]
  all_goals omega

end FinLayer

end Bimodal.Metalogic.WeakCanonical.Kamp
