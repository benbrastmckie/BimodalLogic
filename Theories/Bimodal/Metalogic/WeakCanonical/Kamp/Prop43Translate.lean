import Bimodal.Metalogic.WeakCanonical.Kamp.LiftPair
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeSatNegation

/-!
# δ — structural Proposition 4.3 `translate` (monadic FO → ∨∃∀, PDF p.6)

Rabinovich Proposition 4.3 (p.6): every monadic first-order formula over the E[Σ] alphabet is,
on strictly-increasing environments, equivalent to a `∨∃∀`-formula. This module proves the
correctness statement by **well-founded recursion on `MonadicFormula.size`** (`translate_correct`,
`termination_by φ.size`), reusing the landed connective machinery of the earlier phases:

- **atom** `P(z_i)`: emit, via `hCapture`, the interval `S = {τ | τ ⊨ P}` at the pinned free
  variable `i`, realized as the sub-disjunction of the universally-satisfiable skeleton `skelR`
  keeping exactly the point-type assignments whose `i`-th type lies in `S` (`atomEmit`). This is
  the base case that is **impossible on complete types** and only works because `IntervalType` is a
  *partial* (admissible-completion) set (report 09 §5, "this is where (A) pays off").
- **lt** `z_i < z_j`: index-decided under `StrictMono` (`StrictMono.lt_iff_lt`): emit the
  tautological skeleton `skelR` when `i < j`, and the empty disjunction `[]` when `j ≤ i`.
- **and**: the landed `veeConj_iff` (Phase 9, `VeeConj.lean`).
- **not**: the landed `veeSat_negation` (Phase 11, `VeeSatNegation.lean`), threading `hCapture` /
  `hne` uniformly.
- **ex** / **all**: the order-unconstrained De Bruijn binder prepends a witness at index 0; the
  induction hypothesis is gated on `StrictMono (Fin.cons a env)`, which fails for witnesses that
  are not the least element. Per report 14 (path (c)) the closure lives on the `eval` side. §0
  lands the substrate: `MonadicFormula.rename`/`eval_rename` (variable reindexing +
  eval-naturality), `MonadicFormula.size`/`size_rename` (the rename-preserving well-founded
  measure), `MonadicFormula.subst0`/`eval_subst0` (the tie substitution `x = env i`), and
  `ExistsForallFormula.renamePin`/`veeSat_renamePin` (the ∃∀-side free-variable permutation that
  pushes a gap witness to rank 0 — report 14 §4's flagged pin-rank risk, discharged). The
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

The emitted `VeeExistsForall` depends on the model `N` (the atom interval comes from `hCapture`,
the negation formula from `veeSat_negation` via classical choice). So the deliverable is the
existential-by-induction correctness theorem `translate_correct`, in exactly the shape β
(`efSat_negation_general`) and γ (`veeSat_negation`) already take — not a model-independent
`MonadicFormula → VeeExistsForall` function.

## Threaded hypotheses (never discharged — CONDITIONAL orphan until ζ)

`translate_correct` carries the same `N / atomMap / h_surj / h_INF / h_SUP / hCapture / hne`
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

variable {sig : MonadicSignature} {F : Finset Formula}

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

/-! ### Free-variable permutation on the ∃∀ side (pin-rank bookkeeping)

The gap half of the `ex` closure produces a `veeSat` over a *reordered* environment
`w = w' ∘ σ` (witness pushed to its sorted rank via `insertEnv`), while the induction hypothesis
yields a `veeSat` over the sorted `w'`. `renamePin` composes the pin map with a free-variable
permutation `σ`; because `efSat`'s environment enters *only* through the pin clause
`∀ k, env k = x (ψ.pin k)` (point/interval types are env-independent), reindexing is exact. This
is report 14 §4's flagged load-bearing risk, discharged here as a clean naturality lemma. -/

/-- Reindex the free variables of an `∃∀`-formula along `τ : Fin r' → Fin r` (compose the pin map
with `τ`; the ordered chain and all point/interval types are unchanged). -/
def _root_.Bimodal.Metalogic.WeakCanonical.ExistsForallFormula.renamePin
    {sig : MonadicSignature} {F : Finset Formula} {r r' : Nat} (τ : Fin r' → Fin r)
    (ψ : ExistsForallFormula sig F r) : ExistsForallFormula sig F r' where
  n := ψ.n
  pin := fun k => ψ.pin (τ k)
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- **efSat naturality under a free-variable permutation.** Renaming the pins by a permutation `σ`
and reindexing the environment by `σ.symm` are inverse: satisfaction is preserved. The witness
chain and all point/interval clauses are shared verbatim; only the pin clause reindexes. -/
theorem efSat_renamePin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (σ : Equiv.Perm (Fin r))
    (env : Fin r → N.carrier) (ψ : ExistsForallFormula sig F r) :
    efSat N env (ψ.renamePin (σ : Fin r → Fin r)) ↔ efSat N (env ∘ σ.symm) ψ := by
  constructor
  · rintro ⟨x, hmono, hpin, hpt, hb, hbet, haf⟩
    refine ⟨x, hmono, ?_, hpt, hb, hbet, haf⟩
    intro j
    have h := hpin (σ.symm j)
    simpa [ExistsForallFormula.renamePin, Function.comp, Equiv.apply_symm_apply] using h
  · rintro ⟨x, hmono, hpin, hpt, hb, hbet, haf⟩
    refine ⟨x, hmono, ?_, hpt, hb, hbet, haf⟩
    intro k
    have h := hpin (σ k)
    simpa [ExistsForallFormula.renamePin, Function.comp, Equiv.symm_apply_apply] using h

/-- **veeSat naturality under a free-variable permutation.** Lifting `efSat_renamePin` over the
disjunction (`List.map (renamePin σ)`): quantifying satisfaction of a `∨∃∀`-formula on a permuted
environment. -/
theorem veeSat_renamePin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (σ : Equiv.Perm (Fin r))
    (env : Fin r → N.carrier) (Ψ : VeeExistsForall sig F r) :
    veeSat N env (Ψ.map (ExistsForallFormula.renamePin (σ : Fin r → Fin r)))
      ↔ veeSat N (env ∘ σ.symm) Ψ := by
  unfold veeSat
  constructor
  · rintro ⟨χ, hmem, hsat⟩
    rw [List.mem_map] at hmem
    obtain ⟨ψ, hψmem, rfl⟩ := hmem
    exact ⟨ψ, hψmem, (efSat_renamePin N σ env ψ).1 hsat⟩
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨ψ.renamePin (σ : Fin r → Fin r), List.mem_map_of_mem hmem,
      (efSat_renamePin N σ env ψ).2 hsat⟩

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

/-! ## 1. The identity-pinned skeleton disjunct, characterized -/

/-- **Satisfaction of a single skeleton disjunct.** On a strictly increasing environment, the
identity-pinned ⊤-interval object `skelDisjunct m σ` holds exactly when the environment realizes
`σ`'s point type at every point: the witness chain is forced to be `env` (identity pins), the
interval caps are ⊤ (`intervalHolds_top`), so only the point-type clauses remain. -/
theorem skelDisjunct_efSat {m : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (σ : Fin (m + 1) → UnaryType sig F) (env : Fin (m + 1) → N.carrier)
    (hmono : StrictMono env) :
    efSat N env (skelDisjunct m σ) ↔ ∀ j : Fin (m + 1), unaryHolds N (σ j) (env j) := by
  constructor
  · rintro ⟨x, _, hxpin, hxpt, _, _, _⟩
    have hxeq : x = env := by
      funext k
      have h := hxpin k
      simp only [skelDisjunct, id_eq] at h
      exact h.symm
    intro j
    have h := hxpt j
    simp only [skelDisjunct] at h
    rw [hxeq] at h
    exact h
  · intro hpt
    refine ⟨env, hmono, ?_, ?_, ?_, ?_, ?_⟩
    · intro k; simp [skelDisjunct]
    · intro j; simpa [skelDisjunct] using hpt j
    · intro y _; exact intervalHolds_top N y
    · intro i y _ _; simpa [skelDisjunct] using intervalHolds_top N y
    · intro y _; simpa [skelDisjunct] using intervalHolds_top N y

/-! ## 2. The atom base case: a captured interval at a pinned free variable -/

/-- **Atom emit.** The sub-disjunction of the skeleton `skelR` keeping exactly the point-type
assignments whose type at the pinned variable `i` is admissible for the captured interval `S`.
Realizes "the interval `S` holds at `z_i`" as a `∨∃∀`-formula. -/
noncomputable def atomEmit {m : Nat} (i : Fin (m + 1)) (S : IntervalType sig F) :
    VeeExistsForall sig F (m + 1) :=
  ((Finset.univ : Finset (Fin (m + 1) → UnaryType sig F)).filter (fun σ => σ i ∈ S)).toList.map
    (skelDisjunct m)

/-- **Correctness of `atomEmit`.** On a strictly increasing environment, `atomEmit i S` is
satisfied exactly when the interval `S` holds at `env i`. Forward: any satisfied disjunct pins `σ`
with `σ i ∈ S` and realizes it at `env i`. Backward: given `τ ∈ S` realized at `env i`, take the
characteristic-type assignment updated to `τ` at position `i`. -/
theorem atomEmit_iff {m : Nat} (N : OrderedMonadicStructure (sigE sig F)) (i : Fin (m + 1))
    (S : IntervalType sig F) (env : Fin (m + 1) → N.carrier) (hmono : StrictMono env) :
    veeSat N env (atomEmit i S) ↔ intervalHolds N S (env i) := by
  classical
  unfold atomEmit veeSat
  simp only [List.mem_map, Finset.mem_toList, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨ψ, ⟨σ, hσS, rfl⟩, hsat⟩
    have hpt := (skelDisjunct_efSat N σ env hmono).mp hsat
    exact ⟨σ i, hσS, hpt i⟩
  · rintro ⟨τ, hτS, hτ⟩
    refine ⟨skelDisjunct m (Function.update (fun v => charType N (env v)) i τ),
      ⟨Function.update (fun v => charType N (env v)) i τ, ?_, rfl⟩, ?_⟩
    · rw [Function.update_self]; exact hτS
    · rw [skelDisjunct_efSat N _ env hmono]
      intro j
      by_cases hj : j = i
      · subst hj; rw [Function.update_self]; exact hτ
      · rw [Function.update_of_ne hj]; exact unaryHolds_charType N (env j)

/-! ## 2b. Monotone-pin forcing (Fact P-comp) -/

/-- **Monotone pin forces a strictly monotone environment (Fact P-comp).** If every disjunct of `Ψ`
has a strictly monotone pin and `veeSat N w Ψ` holds, then `w` is strictly monotone: the satisfying
disjunct's `efSat` witness chain `x` is `StrictMono` and `w = x ∘ ψ.pin` (the pin clause), so a
`StrictMono` pin imprints its order type on `w`. This is the mechanism (audit §2.1) by which the
strengthened `translate_correct` invariant pins an existential gap witness into its gap. -/
theorem strictMono_of_veeSat_pin_mono {m : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (w : Fin m → N.carrier) (Ψ : VeeExistsForall sig F m)
    (hmono : ∀ ψ ∈ Ψ, StrictMono ψ.pin) (hsat : veeSat N w Ψ) : StrictMono w := by
  obtain ⟨ψ, hψmem, x, hx, hpin, -⟩ := hsat
  intro a b hab
  rw [hpin a, hpin b]
  exact hx ((hmono ψ hψmem) hab)

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

/-! ## 2d. The `∃`-closure assembly (shared by the `ex` and `all` cases) -/

/-- **The existential-closure assembly (Rabinovich Prop 4.3, `∃`-case, PDF p.6).** Given, for a body
`α : MonadicFormula (m+1)`, a `∨∃∀`-translation of each **gap** reindexing `α.rename (insertPerm p)`
(`p : Fin (m+1)`) and each **tie** substitution `α.subst0 i` (`i : Fin m`), assemble a single
`∨∃∀`-formula equivalent to `∃ x, eval (Fin.cons x env) α` on strictly increasing environments. The
emitted formula is the concatenation of the `m+1` gap disjuncts
`((Ψg p).map (renamePin (insertPerm p))).map dropPin` and the `m` tie disjuncts `Ψt i`.

Forward (`veeSat → ∃`): a satisfied gap disjunct yields, via `veeSat_exists`/`veeSat_renamePin`, an
*unconditional* witness `a` with `veeSat (insertNth p a env) (Ψg p)`; the monotone-pin invariant
`hΨgmono` forces `insertNth p a env` strictly monotone (`strictMono_of_veeSat_pin_mono`, Fact
P-comp), pinning `a` into gap `p`, so the gap translation fires and `eval_insertNth_rename` returns
`eval (cons a env) α`. A satisfied tie disjunct closes directly via `eval_subst0`.

Backward (`∃ → veeSat`): classify the eval witness `x` (`witness_classification`) as a tie
(`x = env i`, closed by `eval_subst0` + the tie translation) or a gap (`strictMono (insertNth p x
env)`, closed by the gap translation reversed through `veeSat_renamePin`/`veeSat_exists`). -/
theorem ex_closure_translate {m : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (α : MonadicFormula (sigE sig F) (m + 1))
    (Ψg : Fin (m + 1) → VeeExistsForall sig F (m + 1))
    (hΨgmono : ∀ p, ∀ ψ ∈ Ψg p, StrictMono ψ.pin)
    (hΨg : ∀ (p : Fin (m + 1)) (env : Fin (m + 1) → N.carrier), StrictMono env →
        (veeSat N env (Ψg p) ↔ eval N env (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))))
    (Ψt : Fin m → VeeExistsForall sig F m)
    (hΨtmono : ∀ i, ∀ ψ ∈ Ψt i, StrictMono ψ.pin)
    (hΨt : ∀ (i : Fin m) (env : Fin m → N.carrier), StrictMono env →
        (veeSat N env (Ψt i) ↔ eval N env (α.subst0 i))) :
    ∃ Ψ : VeeExistsForall sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ env : Fin m → N.carrier, StrictMono env →
      (veeSat N env Ψ ↔ ∃ x : N.carrier, eval N (Fin.cons x env) α) := by
  classical
  refine ⟨((List.finRange (m + 1)).flatMap fun p =>
             ((Ψg p).map (ExistsForallFormula.renamePin
               (insertPerm p : Fin (m + 1) → Fin (m + 1)))).map dropPin)
          ++ ((List.finRange m).flatMap fun i => Ψt i), ?_, fun env hmono => ?_⟩
  · -- Pin-monotonicity of every disjunct: gap pins are `ψ.pin ∘ p.succAbove`; tie pins from `hΨtmono`.
    intro φ hφ
    rw [List.mem_append] at hφ
    rcases hφ with hφ | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨p, _, hφ⟩ := hφ
      rw [List.mem_map] at hφ
      obtain ⟨χ, hχmem, rfl⟩ := hφ
      rw [List.mem_map] at hχmem
      obtain ⟨ψ, hψmem, rfl⟩ := hχmem
      have hcomp : (dropPin (ExistsForallFormula.renamePin
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
    rw [veeSat_append]
    constructor
    · rintro (hgapv | htiev)
      · rw [veeSat_flatMap] at hgapv
        obtain ⟨p, _, hpv⟩ := hgapv
        rw [← veeSat_exists] at hpv
        obtain ⟨a, hav⟩ := hpv
        rw [veeSat_renamePin, cons_comp_insertPerm_symm] at hav
        have hsm : StrictMono (Fin.insertNth p a env) :=
          strictMono_of_veeSat_pin_mono N _ (Ψg p) (hΨgmono p) hav
        have heval := (hΨg p (Fin.insertNth p a env) hsm).mp hav
        rw [eval_insertNth_rename] at heval
        exact ⟨a, heval⟩
      · rw [veeSat_flatMap] at htiev
        obtain ⟨i, _, hiv⟩ := htiev
        have heval := (hΨt i env hmono).mp hiv
        rw [eval_subst0] at heval
        exact ⟨env i, heval⟩
    · rintro ⟨x, hx⟩
      rcases witness_classification env hmono x with ⟨i, rfl⟩ | ⟨p, hsm⟩
      · rw [← eval_subst0] at hx
        have hiv := (hΨt i env hmono).mpr hx
        refine Or.inr ?_
        rw [veeSat_flatMap]
        exact ⟨i, List.mem_finRange i, hiv⟩
      · rw [← eval_insertNth_rename N p x env α] at hx
        have hpv := (hΨg p (Fin.insertNth p x env) hsm).mpr hx
        rw [← cons_comp_insertPerm_symm p x env, ← veeSat_renamePin] at hpv
        refine Or.inl ?_
        rw [veeSat_flatMap]
        refine ⟨p, List.mem_finRange p, ?_⟩
        rw [← veeSat_exists]
        exact ⟨x, hpv⟩

/-! ## 3. Proposition 4.3 (structural, per-model, conditional on `hCapture`) -/

/-- **Proposition 4.3 (structural, PDF p.6).** Every monadic FO formula over the E[Σ] alphabet is,
on strictly increasing environments, equivalent to a `∨∃∀`-formula. Proved by **well-founded
recursion on `MonadicFormula.size`** (`termination_by φ.size`); the emitted `∨∃∀`-formula is
model-dependent (atoms via `hCapture`, negation via `veeSat_negation`). `hCapture` / `hne` are
threaded, never discharged (CONDITIONAL orphan until ζ).

The `ex` / `all` cases carry a tracked strategic `sorry`: the De Bruijn binder prepends an
order-unconstrained witness at index 0, so the recursive translation (gated on
`StrictMono (Fin.cons a env)`) does not apply to non-least witnesses. The path-(c) substrate
(`rename`, `eval_rename`, `size`, `subst0`, `eval_subst0`, `renamePin`, `veeSat_renamePin`) is
landed in §0, and the gap-insertion permutation infrastructure (`insertPerm`,
`insertNth_comp_insertPerm`, `eval_insertNth_rename`) plus the WF-`size` restructure are landed.
The residual is the disjunction assembly, and specifically the forward direction of the gap
disjuncts (see the strategic-sorry comments in the `all`/`ex` arms and the handoff). -/
theorem translate_correct
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {m : Nat} (φ : MonadicFormula (sigE sig F) m) :
    ∃ Ψ : VeeExistsForall sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ env : Fin m → N.carrier, StrictMono env →
      (veeSat N env Ψ ↔ eval N env φ) := by
  classical
  match m, φ with
  | 0, .atom _ i => exact i.elim0
  | (m' + 1), .atom p i =>
      obtain ⟨a, ha⟩ := h_surj p
      obtain ⟨S, hS⟩ := hCapture (.atom a)
      refine ⟨atomEmit i S, ?_, fun env hmono => ?_⟩
      · intro φ' hφ'
        unfold atomEmit at hφ'
        rw [List.mem_map] at hφ'
        obtain ⟨σ, _, rfl⟩ := hφ'
        exact skelDisjunct_pin_strictMono σ
      rw [atomEmit_iff N i S env hmono, hS (env i)]
      show temporal_truth N atomMap (env i) (Formula.atom a) ↔ eval N env (MonadicFormula.atom p i)
      simp only [temporal_truth, ha, eval]
  | 0, .lt i _ => exact i.elim0
  | (m' + 1), .lt i j =>
      by_cases hij : i < j
      · refine ⟨skelR m', ?_, fun env hmono => ?_⟩
        · exact fun φ' hφ' => skelR_pin_strictMono φ' hφ'
        show veeSat N env (skelR m') ↔ env i < env j
        constructor
        · intro _; exact hmono.lt_iff_lt.mpr hij
        · intro _; exact skelR_sat N env hmono
      · refine ⟨[], ?_, fun env hmono => ?_⟩
        · intro φ' hφ'; exact absurd hφ' List.not_mem_nil
        show veeSat N env ([] : VeeExistsForall sig F (m' + 1)) ↔ env i < env j
        constructor
        · intro h; exact absurd h (veeSat_nil N env)
        · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | _, .not α =>
      obtain ⟨Ψα, _, hα⟩ := translate_correct N atomMap h_surj h_INF h_SUP hCapture hne α
      obtain ⟨Ψ', hΨ'mono, hΨ'⟩ := veeSat_negation N atomMap h_surj h_INF h_SUP hCapture hne Ψα
      refine ⟨Ψ', hΨ'mono, fun env hmono => ?_⟩
      show veeSat N env Ψ' ↔ ¬ eval N env α
      rw [← hΨ' env hmono, hα env hmono]
  | _, .and α β =>
      obtain ⟨Ψα, hαmono, hα⟩ := translate_correct N atomMap h_surj h_INF h_SUP hCapture hne α
      obtain ⟨Ψβ, _, hβ⟩ := translate_correct N atomMap h_surj h_INF h_SUP hCapture hne β
      refine ⟨veeConj Ψα Ψβ, ?_, fun env hmono => ?_⟩
      · exact fun χ hχ => veeConj_pin_strictMono Ψα Ψβ hαmono χ hχ
      show veeSat N env (veeConj Ψα Ψβ) ↔ eval N env α ∧ eval N env β
      rw [veeConj_iff N env Ψα Ψβ, hα env hmono, hβ env hmono]
  | _, .all α =>
      -- STRATEGIC SORRY (residual: gap/tie ∃-closure assembly — Phase 12b follow-up).
      -- WF-size restructure LANDED (this `match … termination_by φ.size`): the IH is now the
      -- size-decreasing recursive `translate_correct` call, which fires on `α.subst0 i`
      -- (ties, `size_subst0`) and `α.rename (insertPerm p)` (gaps, `size_rename`). Residual: the
      -- `all` case is the eval `¬∃¬` bridge + two landed `veeSat_negation` over the `ex` closure.
      sorry
  | _, .ex α =>
      -- STRATEGIC SORRY (residual: gap/tie ∃-closure assembly — Phase 12b follow-up).
      -- WF-size restructure LANDED. Residual `ex` assembly: split `∃ x, eval (cons x env) α` by the
      -- order type of `x` vs the m-point strict-mono `env` — m ties (`x = env i`, closed by
      -- `eval_subst0` + recursive call at arity m) and m+1 gaps (reindex
      -- `cons x env = insertNth p x env ∘ insertPerm p` via `eval_rename`; recursive call on
      -- `α.rename (insertPerm p)` at the strict-mono `insertNth p x env`; push the witness to rank
      -- 0 with `veeSat_renamePin` and close by `veeSat_exists`/`dropPin`). See handoff.
      sorry
termination_by φ.size
decreasing_by
  all_goals simp only [MonadicFormula.size]; omega

end Bimodal.Metalogic.WeakCanonical.Kamp
