import Mathlib.Data.Fintype.Card
import Mathlib.Order.SuccPred.Basic
import Mathlib.Data.Fin.Tuple.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finite.Card
import Mathlib.Tactic.Positivity

/-!
# Monadic First-Order Logic over Linear Orders

Pure monadic first-order definitions for the Reynolds/Doets framework,
extracted from NEquivalence.lean to break a circular import with NormalForm.lean.

## Key definitions
- `MonadicSignature`: finite set of predicate symbols
- `MonadicFormula sig n`: monadic FO formula with `n` free variables (De Bruijn `Fin n`)
- `MonadicSentence sig`: abbreviation for `MonadicFormula sig 0` (closed formula)
- `MonadicStructure`: carrier with predicate interpretations
- `OrderedMonadicStructure`: monadic structure with `LinearOrder` on the carrier
- `eval`: Tarski satisfaction for monadic FO formulas
- `finLift`, `lift`, `weaken`: De Bruijn variable shifting operations
- `insertEnv`: environment insertion at arbitrary position
- `lift_eval`, `weaken_eval`: substitution lemmas
- `atomCount`, `nfCount`: Doets 1989 normal form counting functions
- `NormalFormIdx sig k n`: finite index type for depth-≤k normal forms

## Design
`MonadicFormula sig n` uses De Bruijn variable binding with `Fin n` indices,
following Reynolds 1994 Section 6 and Doets 1987 Chapter 1. Constructors:
`atom`, `lt`, `not`, `and`, `all`, `ex`. Evaluation (`eval`) uses `Fin.cons`
for quantifier binding.

## References
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Section 6 (monadic FO language): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Monadic Signature -/

structure MonadicSignature where
  preds : Type
  [fintypePreds : Fintype preds]
  [decEqPreds : DecidableEq preds]

attribute [instance] MonadicSignature.fintypePreds
attribute [instance] MonadicSignature.decEqPreds

/-! ## Monadic Formula (De Bruijn indexed) -/

/--
A monadic first-order formula with `n` free variables over signature `sig`.
Variables are represented as De Bruijn indices (`Fin n`).

Constructors:
- `atom p i`: unary predicate `p` applied to variable `i`
- `lt i j`: order relation `x_i < x_j`
- `not α`: negation
- `and α β`: conjunction
- `all α`: universal quantification (binds variable 0, shifts others up)
- `ex α`: existential quantification (binds variable 0, shifts others up)
-/
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom {n : Nat} (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt {n : Nat} (i j : Fin n) : MonadicFormula sig n
  | not {n : Nat} (α : MonadicFormula sig n) : MonadicFormula sig n
  | and {n : Nat} (α β : MonadicFormula sig n) : MonadicFormula sig n
  | all {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
  | ex {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
  deriving DecidableEq

/-- A monadic sentence: a closed formula with 0 free variables. -/
abbrev MonadicSentence (sig : MonadicSignature) := MonadicFormula sig 0

/-- Quantifier depth of a monadic formula. -/
def MonadicFormula.quantifier_depth {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → Nat
  | .atom _ _ => 0
  | .lt _ _ => 0
  | .not α => α.quantifier_depth
  | .and α β => max α.quantifier_depth β.quantifier_depth
  | .all α => α.quantifier_depth + 1
  | .ex α => α.quantifier_depth + 1

/-! ## Monadic Structure -/

/--
A monadic structure over signature `sig`. The carrier is any type;
predicate interpretations map each predicate symbol to a unary predicate
on the carrier.
-/
structure MonadicStructure (sig : MonadicSignature) where
  carrier : Type
  interp (p : sig.preds) : carrier → Prop

/-! ## Ordered Monadic Structure -/

/--
An ordered monadic structure bundles a monadic structure with a
`LinearOrder` on its carrier. This enables subinterval restriction,
the ordered sum construction, and Tarski evaluation of `lt` formulas.
-/
structure OrderedMonadicStructure (sig : MonadicSignature) extends MonadicStructure sig where
  carrier_order : LinearOrder carrier

attribute [instance] OrderedMonadicStructure.carrier_order

instance (sig : MonadicSignature) (M : OrderedMonadicStructure sig) : LinearOrder M.carrier :=
  M.carrier_order

/--
Convert an `OrderedMonadicStructure` to a plain `MonadicStructure`,
dropping the order information.
-/
def OrderedMonadicStructure.toMonadic (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    MonadicStructure sig where
  carrier := M.carrier
  interp := M.interp

/--
The subinterval of an ordered monadic structure between points a and b.

The carrier is `{x : M.carrier // a ≤ x ∧ x ≤ b}` (Subtype), and the
predicate interpretations are inherited as `M.interp p x.val`.

The linear order on the subinterval is the inherited Subtype order
(using `Subtype.instLinearOrder` which is available from Mathlib).
-/
def OrderedMonadicStructure.subinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x ≤ b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance

/--
If a = b, the subinterval [a, a] is a singleton, hence finite.

Proof: every element x in the subinterval satisfies a ≤ x.val ∧ x.val ≤ a,
so x.val = a by antisymmetry. Thus the subinterval has exactly one element.
-/
theorem subinterval_singleton_finite (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a : M.carrier) : Finite (M.subinterval sig a a).carrier := by
  -- The subinterval carrier is {x : M.carrier // a ≤ x ∧ x ≤ a}
  let elem : (M.subinterval sig a a).carrier := ⟨a, le_refl a, le_refl a⟩
  have h_fintype : Fintype (M.subinterval sig a a).carrier := {
    elems := {elem}
    complete := by
      intro x
      have hx := x.property
      have h_eq_val : x.val = a := le_antisymm hx.2 hx.1
      apply Finset.mem_singleton.mpr
      exact Subtype.ext h_eq_val
  }
  haveI : Fintype (M.subinterval sig a a).carrier := h_fintype
  infer_instance

/--
If b = Order.succ a in a SuccOrder, the subinterval [a, succ a] has exactly
two elements: a and succ(a).
-/
theorem subinterval_two_element_finite (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] (a : M.carrier) :
    Finite (M.subinterval sig a (Order.succ a)).carrier := by
  let c : (M.subinterval sig a (Order.succ a)).carrier := ⟨a, le_refl a, Order.le_succ a⟩
  let d : (M.subinterval sig a (Order.succ a)).carrier := ⟨Order.succ a, Order.le_succ a, le_refl _⟩
  have h_fintype : Fintype (M.subinterval sig a (Order.succ a)).carrier := {
    elems := {c, d}
    complete := by
      intro x
      rcases x with ⟨x_val, hx_a, hx_succ⟩
      by_cases h_eq_a : x_val = a
      · subst h_eq_a; simp [c]
      · have ha_lt_x : a < x_val := lt_of_le_of_ne hx_a (Ne.symm h_eq_a)
        have h_succ_le : Order.succ a ≤ x_val := SuccOrder.succ_le_of_lt ha_lt_x
        have h_eq_succ : x_val = Order.succ a := le_antisymm hx_succ h_succ_le
        subst h_eq_succ; simp [d]
  }
  haveI : Fintype (M.subinterval sig a (Order.succ a)).carrier := h_fintype
  infer_instance

/-! ## Z-Structure: Integer-Based Monadic Structures -/

/--
A Z-structure: a monadic structure whose carrier is ℤ. This represents
a "Z-model" or "Z-interval" in the Reynolds framework.
-/
structure ZStructure (sig : MonadicSignature) where
  interp (p : sig.preds) : ℤ → Prop

/--
Convert a Z-structure to a plain monadic structure.
-/
def ZStructure.toMonadic (sig : MonadicSignature) (Z : ZStructure sig) : MonadicStructure sig where
  carrier := ℤ
  interp := Z.interp

/--
Convert a Z-structure to an ordered monadic structure (using ℤ's natural order).
-/
def ZStructure.toOrdered (sig : MonadicSignature) (Z : ZStructure sig) :
    OrderedMonadicStructure sig where
  carrier := ℤ
  interp := Z.interp
  carrier_order := inferInstance

/-! ## Tarski Satisfaction (eval) -/

/--
Tarski satisfaction for monadic FO formulas. Evaluates a formula with `n` free
variables in an ordered monadic structure `M` under an environment `env` that
assigns carrier elements to each free variable.

Quantifier binding uses `Fin.cons`: `∀ x, eval M (Fin.cons x env) α` binds
variable 0 to `x` and shifts the remaining variables.
-/
def eval {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j => env i < env j
  | .not α => ¬ eval M env α
  | .and α β => eval M env α ∧ eval M env β
  | .all α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .ex α => ∃ (x : M.carrier), eval M (Fin.cons x env) α

/-! ## De Bruijn Lifting and Weakening -/

/--
Shift a `Fin n` index at cutoff `c`: indices below `c` are unchanged,
indices `≥ c` are incremented by 1. This is the variable-level operation
underlying the De Bruijn lift.
-/
def finLift (c : Nat) {n : Nat} (i : Fin n) : Fin (n + 1) :=
  if i.val < c then ⟨i.val, by omega⟩ else ⟨i.val + 1, by omega⟩

/--
Lift a monadic formula through a binder at cutoff `c`. Variables with
De Bruijn index `≥ c` are shifted up by 1; variables below `c` are
unchanged. Going under a binder increments the cutoff.

- `c = 0`: shift all free variables (standard weakening for closed-binder context)
- `c = 1`: leave bound variable 0 alone, shift free variables 1..n
- etc.
-/
def MonadicFormula.lift {sig : MonadicSignature} {n : Nat} (c : Nat) :
    MonadicFormula sig n → MonadicFormula sig (n + 1)
  | .atom p i => .atom p (finLift c i)
  | .lt i j => .lt (finLift c i) (finLift c j)
  | .not α => .not (α.lift c)
  | .and α β => .and (α.lift c) (β.lift c)
  | .all α => .all (α.lift (c + 1))
  | .ex α => .ex (α.lift (c + 1))

/--
Weaken a monadic formula: shift all free variable indices up by 1.
Defined as `lift 0`. Maps `MonadicFormula sig n` to `MonadicFormula sig (n + 1)`.
The new variable 0 is unused; original variable `i` becomes `i + 1`.

Used in the table translation when entering a quantifier scope.
-/
def MonadicFormula.weaken {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) : MonadicFormula sig (n + 1) :=
  α.lift 0

/--
Insert a value at position `c` into an environment of size `n`,
producing an environment of size `n + 1`. Indices below `c` map to
the same environment value; index `c` maps to the inserted value;
indices above `c` shift down by 1.
-/
def insertEnv {α : Type} {n : Nat} (c : Fin (n + 1)) (x : α) (env : Fin n → α) :
    Fin (n + 1) → α :=
  fun i =>
    if h : i.val < c.val then env ⟨i.val, by omega⟩
    else if h2 : i = c then x
    else env ⟨i.val - 1, by omega⟩

/--
`insertEnv 0 x env = Fin.cons x env`.
-/
theorem insertEnv_zero_eq_cons {α : Type} {n : Nat} (x : α) (env : Fin n → α) :
    insertEnv 0 x env = Fin.cons x env := by
  funext i
  cases i using Fin.cases with
  | zero => simp [insertEnv, Fin.cons_zero]
  | succ i => simp [insertEnv, Fin.cons_succ, Fin.val_succ]

/--
Inserting at position `c+1` after `Fin.cons y` equals `Fin.cons y` followed
by inserting at position `c`. This is the key commutation lemma for the
binder case of `lift_eval`.
-/
theorem insertEnv_succ_cons {α : Type} {n : Nat} (c : Fin (n + 1)) (x y : α)
    (env : Fin n → α) :
    insertEnv c.succ x (Fin.cons y env) = Fin.cons y (insertEnv c x env) := by
  funext i
  cases i using Fin.cases with
  | zero =>
    unfold insertEnv
    rw [dif_pos (show (0 : Fin (n + 2)).val < c.succ.val by simp [Fin.val_succ])]
    rfl
  | succ j =>
    simp only [Fin.cons_succ, insertEnv, Fin.val_succ]
    have hj_lt : j.val < n + 1 := j.isLt
    split_ifs
    all_goals first | rfl | (exfalso; omega) | skip
    · rename_i h1 h2 _ h4
      exact absurd (Fin.succ_inj.mp h2) h4
    · rename_i h1 h2 _ h4
      exact absurd (congrArg Fin.succ h4) h2
    · rename_i h1 h2 h3 h4
      have hne : j.val ≠ c.val := fun h => h4 (Fin.ext h)
      have hpos : 0 < j.val := by omega
      have hjm1_lt : j.val - 1 < n := by omega
      convert @Fin.cons_succ n (fun _ => α) y env ⟨j.val - 1, hjm1_lt⟩ using 2
      ext; simp [Fin.val_mk]; omega

/-- `insertEnv c x env` composed with `finLift c.val` recovers `env`. -/
private theorem insertEnv_finLift {α : Type} {n : Nat} (c : Fin (n + 1))
    (x : α) (env : Fin n → α) (i : Fin n) :
    insertEnv c x env (finLift c.val i) = env i := by
  simp only [finLift]
  by_cases hlt : i.val < c.val
  · simp only [if_pos hlt, insertEnv, dif_pos hlt]
  · simp only [if_neg hlt, insertEnv]
    have h1 : ¬(i.val + 1 < c.val) := by omega
    rw [dif_neg h1]
    have h2 : ¬((⟨i.val + 1, (by omega : i.val + 1 < n + 1)⟩ : Fin (n + 1)) = c) := by
      intro heq; have := Fin.ext_iff.mp heq; simp at this; omega
    rw [dif_neg h2]
    congr 1

/-- Lift preserves evaluation under inserted environments. -/
theorem lift_eval {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (c : Fin (n + 1)) (x : M.carrier) (α : MonadicFormula sig n) :
    eval M (insertEnv c x env) (α.lift c.val) = eval M env α := by
  induction α with
  | atom p i => simp [eval, MonadicFormula.lift, insertEnv_finLift]
  | lt i j => simp [eval, MonadicFormula.lift, insertEnv_finLift]
  | not α ih => simp only [eval, MonadicFormula.lift]; rw [ih env c]
  | and α β ihα ihβ => simp only [eval, MonadicFormula.lift]; rw [ihα env c, ihβ env c]
  | all α ih =>
    simp only [eval, MonadicFormula.lift]
    have key : ∀ y, eval M (Fin.cons y (insertEnv c x env)) (α.lift (c.val + 1)) = eval M (Fin.cons y env) α := by
      intro y
      rw [(insertEnv_succ_cons c x y env).symm]
      exact ih (Fin.cons y env) c.succ
    simp_rw [key]
  | ex α ih =>
    simp only [eval, MonadicFormula.lift]
    have key : ∀ y, eval M (Fin.cons y (insertEnv c x env)) (α.lift (c.val + 1)) = eval M (Fin.cons y env) α := by
      intro y
      rw [(insertEnv_succ_cons c x y env).symm]
      exact ih (Fin.cons y env) c.succ
    simp_rw [key]

/--
Weakening preserves evaluation: evaluating a weakened formula in an
extended environment yields the same result as evaluating the original
in the base environment.

This is the standard substitution lemma for De Bruijn indices:
`eval M (Fin.cons x env) (α.weaken) = eval M env α`.
-/
theorem weaken_eval {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (x : M.carrier) (α : MonadicFormula sig n) :
    eval M (Fin.cons x env) α.weaken = eval M env α := by
  rw [MonadicFormula.weaken, ← insertEnv_zero_eq_cons x env]
  exact lift_eval M env 0 x α

/-! ## Syntactic Sugar for MonadicFormula -/

/-- Implication: ¬(α ∧ ¬β) -/
def MonadicFormula.imp {sig : MonadicSignature} {n : Nat}
    (α β : MonadicFormula sig n) : MonadicFormula sig n :=
  .not (.and α (.not β))

/-- Disjunction: ¬(¬α ∧ ¬β) -/
def MonadicFormula.or {sig : MonadicSignature} {n : Nat}
    (α β : MonadicFormula sig n) : MonadicFormula sig n :=
  .not (.and (.not α) (.not β))

/-- x_i ≤ x_j, defined as ¬(x_j < x_i) -/
def MonadicFormula.leq {sig : MonadicSignature} {n : Nat}
    (i j : Fin n) : MonadicFormula sig n :=
  .not (.lt j i)

/-- Boolean true: ¬(x_0 < x_0) -/
def MonadicFormula.true_ {sig : MonadicSignature} {n : Nat}
    (hn : 0 < n := by omega) : MonadicFormula sig n :=
  .not (.lt ⟨0, hn⟩ ⟨0, hn⟩)

/-- Boolean false: x_0 < x_0 -/
def MonadicFormula.false_ {sig : MonadicSignature} {n : Nat}
    (hn : 0 < n := by omega) : MonadicFormula sig n :=
  .lt ⟨0, hn⟩ ⟨0, hn⟩

@[simp]
theorem eval_imp {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (α β : MonadicFormula sig n) :
    eval M env (MonadicFormula.imp α β) ↔ (eval M env α → eval M env β) := by
  simp only [MonadicFormula.imp, eval]
  tauto

@[simp]
theorem eval_or {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (α β : MonadicFormula sig n) :
    eval M env (MonadicFormula.or α β) ↔ (eval M env α ∨ eval M env β) := by
  simp only [MonadicFormula.or, eval]
  tauto

@[simp]
theorem eval_leq {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (i j : Fin n) :
    eval M env (MonadicFormula.leq i j) ↔ (env i ≤ env j) := by
  simp only [MonadicFormula.leq, eval, not_lt]

@[simp]
theorem eval_true {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (hn : 0 < n) :
    eval M env (MonadicFormula.true_ hn) ↔ True := by
  simp only [MonadicFormula.true_, eval, lt_irrefl, not_false_eq_true]

@[simp]
theorem eval_false {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (hn : 0 < n) :
    eval M env (MonadicFormula.false_ hn) ↔ False := by
  simp only [MonadicFormula.false_, eval, lt_irrefl]

/-! ## Bounded Quantifier Relativization

Standard model-theoretic technique for relativizing quantifiers to a
subinterval. Given a sentence φ (0 free variables), the relativization
`relativize_sentence φ` produces a formula with 2 free variables (lo, hi)
such that `eval M (![lo, hi]) (relativize_sentence φ)` holds iff
`eval (M.subinterval lo hi) Fin.elim0 φ` holds.

This is used to express properties of subintervals (like `good` and
`very_good`) as formulas over the full structure.
-/

/--
Relativize a MonadicFormula to the subinterval [var n, var (n+1)].
The formula φ : MonadicFormula sig n is transformed into a formula
of type MonadicFormula sig (n + 2) where all quantifiers are bounded
to elements in [var n, var (n+1)].

Variable layout in the result:
- Variables 0..n-1: same as in φ (original free variables)
- Variable n: lo (lower bound of the subinterval)
- Variable n+1: hi (upper bound of the subinterval)
-/
noncomputable def relativize {sig : MonadicSignature} :
    {n : Nat} → MonadicFormula sig n → MonadicFormula sig (n + 2)
  | _, .atom p i => .atom p (i.castSucc.castSucc)
  | _, .lt i j => .lt (i.castSucc.castSucc) (j.castSucc.castSucc)
  | _, .not α => .not (relativize α)
  | _, .and α β => .and (relativize α) (relativize β)
  | n, .all α =>
    -- ∀ x, (lo ≤ x ∧ x ≤ hi) → relativize(α)
    -- In relativize α : MonadicFormula sig (n+3), lo is at n+1, hi is at n+2
    .all (MonadicFormula.imp
      (.and (MonadicFormula.leq ⟨n + 1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.leq ⟨0, by omega⟩ ⟨n + 2, by omega⟩))
      (relativize α))
  | n, .ex α =>
    -- ∃ x, (lo ≤ x ∧ x ≤ hi) ∧ relativize(α)
    .ex (.and
      (.and (MonadicFormula.leq ⟨n + 1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.leq ⟨0, by omega⟩ ⟨n + 2, by omega⟩))
      (relativize α))

/--
Relativize a sentence (0 free variables) to [var 0, var 1].
Produces a formula with 2 free variables.
-/
noncomputable def relativize_sentence {sig : MonadicSignature}
    (φ : MonadicSentence sig) : MonadicFormula sig 2 :=
  relativize φ

/--
Environment for evaluating relativized formulas. Maps a Fin n environment
over the subinterval carrier to a Fin (n+2) environment over M.carrier,
by projecting subtype values and appending lo, hi.
-/
def relativize_env {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier) :
    Fin (n + 2) → M.carrier :=
  fun i =>
    if h : i.val < n then (env_sub ⟨i.val, h⟩).val
    else if i.val = n then lo
    else hi

private theorem relativize_env_lt {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier)
    (i : Fin n) :
    relativize_env M lo hi env_sub (i.castSucc.castSucc) = (env_sub i).val := by
  simp [relativize_env, Fin.castSucc, Fin.val_mk, i.isLt]

private theorem relativize_env_lo {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier) :
    relativize_env M lo hi env_sub ⟨n, by omega⟩ = lo := by
  simp [relativize_env, dif_neg (by omega : ¬ n < n)]

private theorem relativize_env_hi {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier) :
    relativize_env M lo hi env_sub ⟨n + 1, by omega⟩ = hi := by
  simp only [relativize_env]
  rw [dif_neg (show ¬ (n + 1 < n) from by omega)]
  simp [show ¬ (n + 1 = n) from by omega]

/--
Key commutation lemma: `Fin.cons x (relativize_env ...)` equals
`relativize_env ... (Fin.cons x_sub ...)` when `x = x_sub.val`.
-/
private theorem relativize_env_cons {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier)
    (x_sub : (M.subinterval sig lo hi).carrier) :
    Fin.cons x_sub.val (relativize_env M lo hi env_sub) =
    relativize_env M lo hi (Fin.cons x_sub env_sub) := by
  funext i
  cases i using Fin.cases with
  | zero =>
    simp only [Fin.cons_zero]
    show x_sub.val = relativize_env M lo hi (Fin.cons x_sub env_sub) ⟨0, _⟩
    simp only [relativize_env, dif_pos (show (0 : Nat) < n + 1 from by omega)]
    simp [Fin.cons_zero]
  | succ j =>
    simp only [Fin.cons_succ]
    simp only [relativize_env, Fin.val_succ]
    by_cases h1 : j.val < n
    · rw [dif_pos h1, dif_pos (show j.val + 1 < n + 1 from by omega)]
      rfl
    · rw [dif_neg h1, dif_neg (show ¬ (j.val + 1 < n + 1) from by omega)]
      by_cases h2 : j.val = n
      · simp [h2, show j.val + 1 = n + 1 from by omega]
      · have : j.val + 1 ≠ n + 1 := by omega
        simp [h2, this]

/--
Correctness of `relativize`: evaluating a relativized formula in the full
structure with lo/hi is equivalent to evaluating the original formula in
the subinterval.
-/
theorem relativize_correct {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (h_le : lo ≤ hi)
    (env_sub : Fin n → (M.subinterval sig lo hi).carrier)
    (φ : MonadicFormula sig n) :
    eval M (relativize_env M lo hi env_sub) (relativize φ) ↔
    eval (M.subinterval sig lo hi) env_sub φ := by
  induction φ with
  | atom p i =>
    simp only [relativize, eval, OrderedMonadicStructure.subinterval]
    rw [relativize_env_lt]
  | lt i j =>
    simp only [relativize, eval]
    constructor
    · intro h; rw [relativize_env_lt, relativize_env_lt] at h; exact h
    · intro h; rw [relativize_env_lt, relativize_env_lt]; exact h
  | not α ih =>
    simp only [relativize, eval]
    exact (ih env_sub).not
  | and α β ihα ihβ =>
    simp only [relativize, eval]
    exact (ihα env_sub).and (ihβ env_sub)
  | @all n α ih =>
    -- After unfolding relativize for .all: we get .all (imp guard (relativize α))
    -- After eval of .all: ∀ x, eval(Fin.cons x env)(imp guard (relativize α))
    simp only [relativize, eval]
    constructor
    · -- Forward: bounded universal on M → universal on subinterval
      intro h_all x_sub
      specialize h_all x_sub.val
      -- h_all has the form: eval of (imp guard (relativize α))
      -- which is ¬(guard ∧ ¬(relativize α))
      -- We need to show the guard holds and extract the body
      have h_lo_x : lo ≤ x_sub.val := x_sub.property.1
      have h_x_hi : x_sub.val ≤ hi := x_sub.property.2
      -- Use eval_imp to convert
      rw [eval_imp] at h_all
      have h_guard : eval M (Fin.cons x_sub.val (relativize_env M lo hi env_sub))
          (MonadicFormula.and
            (MonadicFormula.leq ⟨n + 1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.leq ⟨0, by omega⟩ ⟨n + 2, by omega⟩)) := by
        simp only [eval, eval_leq]
        -- Goal: env ⟨n+1⟩ ≤ env ⟨0⟩ ∧ env ⟨0⟩ ≤ env ⟨n+2⟩
        -- where env = Fin.cons x_sub.val (relativize_env M lo hi env_sub)
        -- env ⟨0⟩ = x_sub.val, env ⟨n+1⟩ = lo, env ⟨n+2⟩ = hi
        rw [relativize_env_cons] at h_all ⊢
        refine ⟨?_, ?_⟩
        · -- lo ≤ x_sub.val
          simp only [relativize_env, dif_pos (show (0 : Nat) < n + 1 from by omega),
            dif_neg (show ¬ (n + 1 < n + 1) from by omega),
            show (n + 1 = n + 1) from rfl, ite_true, Fin.cons_zero]
          exact h_lo_x
        · -- x_sub.val ≤ hi
          simp only [relativize_env, dif_pos (show (0 : Nat) < n + 1 from by omega),
            dif_neg (show ¬ (n + 2 < n + 1) from by omega),
            show ¬ (n + 2 = n + 1) from by omega, ite_false, Fin.cons_zero]
          exact h_x_hi
      have h_body := h_all h_guard
      rw [relativize_env_cons] at h_body
      exact (ih (Fin.cons x_sub env_sub)).mp h_body
    · -- Backward: universal on subinterval → bounded universal on M
      intro h_all x
      rw [eval_imp]
      intro h_guard
      -- Extract lo ≤ x ∧ x ≤ hi from h_guard
      simp only [eval, MonadicFormula.leq, not_lt] at h_guard
      have h_lo : lo ≤ x := by
        have := h_guard.1
        simp [Fin.cons] at this
        rwa [relativize_env_lo] at this
      have h_hi : x ≤ hi := by
        have := h_guard.2
        simp [Fin.cons] at this
        rwa [relativize_env_hi] at this
      let x_sub : (M.subinterval sig lo hi).carrier := ⟨x, h_lo, h_hi⟩
      rw [relativize_env_cons (x_sub := x_sub)]
      exact (ih (Fin.cons x_sub env_sub)).mpr (h_all x_sub)
  | @ex n α ih =>
    simp only [relativize, eval]
    constructor
    · -- Forward: ∃ x with guard ∧ body → ∃ x_sub
      intro ⟨x, h_guard, h_body⟩
      simp only [eval, MonadicFormula.leq, not_lt] at h_guard
      have h_lo : lo ≤ x := by
        have := h_guard.1
        simp [Fin.cons] at this
        rwa [relativize_env_lo] at this
      have h_hi : x ≤ hi := by
        have := h_guard.2
        simp [Fin.cons] at this
        rwa [relativize_env_hi] at this
      let x_sub : (M.subinterval sig lo hi).carrier := ⟨x, h_lo, h_hi⟩
      rw [relativize_env_cons (x_sub := x_sub)] at h_body
      exact ⟨x_sub, (ih (Fin.cons x_sub env_sub)).mp h_body⟩
    · -- Backward: ∃ x_sub → ∃ x with guard ∧ body
      intro ⟨x_sub, h_body⟩
      refine ⟨x_sub.val, ?_, ?_⟩
      · -- Guard: lo ≤ x_sub.val ∧ x_sub.val ≤ hi
        simp only [eval, MonadicFormula.leq, not_lt]
        constructor
        · simp [Fin.cons]
          rw [relativize_env_lo]; exact x_sub.property.1
        · simp [Fin.cons]
          rw [relativize_env_hi]; exact x_sub.property.2
      · -- Body
        rw [relativize_env_cons (x_sub := x_sub)]
        exact (ih (Fin.cons x_sub env_sub)).mpr h_body

/--
The relativize_env for an empty subinterval environment is [lo, hi].
-/
private theorem relativize_env_empty {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (lo hi : M.carrier) :
    relativize_env M lo hi (Fin.elim0 : Fin 0 → (M.subinterval sig lo hi).carrier) =
    Fin.cons lo (Fin.cons hi Fin.elim0) := by
  funext ⟨i, hi'⟩
  simp only [relativize_env]
  have h0 : ¬ (i < 0) := by omega
  rw [dif_neg h0]
  by_cases h : i = 0
  · subst h; simp [Fin.cons]
  · have h1 : i = 1 := by omega
    subst h1; rfl

/--
Correctness of `relativize_sentence` specialized to sentences.
-/
theorem relativize_sentence_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (h_le : lo ≤ hi)
    (φ : MonadicSentence sig) :
    eval M (Fin.cons lo (Fin.cons hi Fin.elim0)) (relativize_sentence φ) ↔
    eval (M.subinterval sig lo hi) Fin.elim0 φ := by
  have h := relativize_correct M lo hi h_le Fin.elim0 φ
  simp only [relativize_sentence]
  rw [show Fin.cons lo (Fin.cons hi Fin.elim0) =
    relativize_env M lo hi (Fin.elim0 : Fin 0 → (M.subinterval sig lo hi).carrier) from
    (relativize_env_empty M lo hi).symm]
  exact h

/-! ## Normal Form Count (Doets 1989, Lemma 1.1) -/

/--
The number of atomic propositions available with `p` unary predicates and
`n` free variables over a linear order:
- `p * n` predicate atoms: `P_i(x_j)` for each predicate and variable
- `n * (n - 1)` order atoms: `x_i < x_j` for each ordered pair of distinct variables
-/
def atomCount (p n : Nat) : Nat := p * n + n * (n - 1)

/--
The number of semantically distinct monadic FO formulas of quantifier
depth at most `k` with `n` free variables, over a signature with `p`
unary predicates and a linear order.

WARNING: Double-exponential growth. Never mark `@[reducible]` or `@[simp]`.
-/
def nfCount (p : Nat) : Nat → Nat → Nat
  | 0, n => 2 ^ atomCount p n
  | k + 1, n => 2 ^ (atomCount p n + nfCount p k (n + 1))

/-- `nfCount p k n` is always positive. -/
theorem nfCount_pos (p k n : Nat) : 0 < nfCount p k n := by
  induction k generalizing n with
  | zero => simp only [nfCount]; positivity
  | succ k _ih => simp only [nfCount]; positivity

/--
The finite index type for normal forms at depth `k` with `n` free variables.
`Fin (nfCount ...)` is always `Fintype` since `Fin N` is `Fintype`.
-/
abbrev NormalFormIdx (sig : MonadicSignature) (k n : Nat) :=
  Fin (nfCount (Fintype.card sig.preds) k n)

end Bimodal.Metalogic.WeakCanonical
