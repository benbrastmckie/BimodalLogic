import Mathlib.Data.Real.Archimedean
import FormalSystem.Semantics.PlusLanguage.PlusValidity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.Extension.Extension

/-!
# Probe 01 — what makes recurrence and transposition visible

Compiled against the live `FrameOver` / `WorldHistory` / `TaskModel` structures, sorry-free, with
`lake env lean` against the repository's own oleans. Two extension languages are defined here as
standalone inductives (the live `PlusFormula` cannot be extended in place):

* `NFormula` — L⁺ plus the same-state modality `[≡]` (`same`), **state registers** `reg i`
  (true iff the current world state is the `i`-th stored state) and the **binder** `bind i`
  (`↓_i`: store the current state in register `i`). A *state nominal* is a free register: nominal
  validity is validity under every register assignment; a register-closed sentence `↓_i φ` needs
  no assignment at all.
* `QFormula` — L plus **propositional quantifiers** `all n`, evaluated relative to a family `Adm`
  of admissible propositions (state sets). `Adm = Set.univ` is the standard semantics; the
  *lifted* family `pulledBack g` along a history-lifting morphism is the clock-independent
  semantics of the dispatch's Q1.

Results, keyed to the dispatch questions:

* **Q1 (negative)** — `regFree_invariance`: truth of every register-free `NFormula` (so of every
  L⁺ formula *and of `[≡]φ`*) is invariant along any history-lifting morphism `HistMorphism F' F`
  (the notion of the translation-product probe, `prodProj` being the instance), for arbitrary
  register vectors on both sides. `lifted_invariance`: truth of every `QFormula` under the lifted
  family is invariant along the same morphisms. Both are the same induction as the product probe's
  `histMorphism_invariance`; the `[≡]` clause is discharged by `lift` (the product's
  `liftH_through`), the quantifier clause by `pullV_update`.
* **Q2 (positive)** — `recF_defines`: the nominal formula `¬(i ∧ (P i ∨ F i))` is valid on a task
  frame **iff** the frame is recurrence-free; `bindRec_defines`: so is the register-closed
  `↓_i ¬(P i ∨ F i)`. `exists_splice` (compiled gluing of two histories meeting at a time) gives
  `transF_valid`: `¬(E(i ∧ F j) ∧ E(j ∧ F i))` is valid on every recurrence-free frame, and
  `transF_refuted_distinct` refutes it on `permissiveFrame` with `i`, `j` naming distinct states.
  `recF_not_validIn` / `transF_not_validIn`: at every `FrameClass` tag the class does not validate
  either formula, while its recurrence-free members do (`recF_valid`, `transF_valid`). The
  invariance breaks exactly at `reg`/`bind`: no other clause consults a state's identity.
* **Q3** — `formula_univ_iff`: in the live `Formula`, `□(Hφ ∧ φ ∧ Gφ)` is the universal modality
  over all (history, time) pairs — this uses only that `WorldHistory` is total. `isAtom_iff`:
  under the standard semantics `Atom(p) := E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))` says exactly that `p`
  is a singleton among occurring states; `qRec_defines`: `∀p (Atom(p) → ¬(p ∧ (Pp ∨ Fp)))` is
  valid iff the frame is recurrence-free; `standard_not_invariant`: hence standard-semantics
  quantifier truth is NOT invariant along any history-lifting morphism from a recurrence-free
  frame onto a recurrent one (the translation projection being one such).
-/

set_option linter.unusedSectionVars false

namespace Probe628

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## Part 0 — history-lifting morphisms (the translation-product probe's notion, restated) -/

section Morphism
variable {D : TemporalOrder}

/-- A history-lifting map (as in the translation-product probe). -/
structure HistMap (F' F : FrameOver D) where
  toFun : F'.WorldState → F.WorldState
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (toFun a) x (toFun b)
  lift : ∀ (τ : WorldHistory F.toTaskFrame) (a : F'.WorldState) (t : ↑D),
    toFun a = τ.state t →
      ∃ τ' : WorldHistory F'.toTaskFrame, τ'.state t = a ∧ ∀ s, toFun (τ'.state s) = τ.state s

/-- A history-lifting morphism: onto histories. -/
structure HistMorphism (F' F : FrameOver D) extends HistMap F' F where
  onto : ∀ τ : WorldHistory F.toTaskFrame,
    ∃ τ' : WorldHistory F'.toTaskFrame, ∀ s, toFun (τ'.state s) = τ.state s

variable {F' F : FrameOver D}

def HistMap.mapH (g : HistMap F' F) (τ' : WorldHistory F'.toTaskFrame) :
    WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => g.toFun (τ'.state t))
    (fun s t => g.forth _ _ _ (τ'.respects_task s t))

@[simp] theorem HistMap.mapH_state (g : HistMap F' F) (τ' : WorldHistory F'.toTaskFrame)
    (t : ↑D) : (g.mapH τ').state t = g.toFun (τ'.state t) := rfl

def HistMap.pullM (g : HistMap F' F) (M : TaskModel F.toTaskFrame) : TaskModel F'.toTaskFrame :=
  ⟨fun a p => M.valuation (g.toFun a) p⟩

end Morphism

/-- A task frame is recurrence-free when no world history visits a world state twice. -/
def RecurrenceFree (G : TaskFrame) : Prop :=
  ∀ (τ : WorldHistory G) (s t : G.Duration), τ.state s = τ.state t → s = t

/-! ## Part 1 — L⁺ with `[≡]`, state registers and the state binder -/

inductive NFormula : Type where
  | atom : Atom → NFormula
  | bot : NFormula
  | imp : NFormula → NFormula → NFormula
  | box : NFormula → NFormula
  | untl : NFormula → NFormula → NFormula
  | snce : NFormula → NFormula → NFormula
  | stab : NFormula → NFormula
  /-- `[≡]φ`: `φ` at every (history, time) pair occupying the current world state. -/
  | same : NFormula → NFormula
  /-- register atom `i`: the current world state is the `i`-th stored state. -/
  | reg : ℕ → NFormula
  /-- `↓_i φ`: store the current world state in register `i`, then evaluate `φ`. -/
  | bind : ℕ → NFormula → NFormula

namespace NFormula

def top : NFormula := bot.imp bot
def neg (φ : NFormula) : NFormula := φ.imp bot
def and (φ ψ : NFormula) : NFormula := (φ.imp ψ.neg).neg
def or (φ ψ : NFormula) : NFormula := φ.neg.imp ψ
def someFuture (φ : NFormula) : NFormula := untl top φ
def somePast (φ : NFormula) : NFormula := snce top φ
def allFuture (φ : NFormula) : NFormula := (someFuture φ.neg).neg
def allPast (φ : NFormula) : NFormula := (somePast φ.neg).neg
/-- The universal modality `A φ := □(Hφ ∧ φ ∧ Gφ)`. -/
def univ (φ : NFormula) : NFormula := box ((allPast φ).and (φ.and (allFuture φ)))
/-- `E φ := ¬A¬φ`. -/
def exist (φ : NFormula) : NFormula := (univ φ.neg).neg
/-- The recurrence formula `¬(i ∧ (P i ∨ F i))` for the state nominal / register `i`. -/
def recF (i : ℕ) : NFormula := ((reg i).and ((somePast (reg i)).or (someFuture (reg i)))).neg
/-- The transposition formula `¬(E(i ∧ F j) ∧ E(j ∧ F i))`. -/
def transF (i j : ℕ) : NFormula :=
  ((exist ((reg i).and (someFuture (reg j)))).and (exist ((reg j).and (someFuture (reg i))))).neg

/-- The register-free fragment: L⁺ plus `[≡]`. -/
def RegFree : NFormula → Prop
  | atom _ => True
  | bot => True
  | imp a b => RegFree a ∧ RegFree b
  | box a => RegFree a
  | untl a b => RegFree a ∧ RegFree b
  | snce a b => RegFree a ∧ RegFree b
  | stab a => RegFree a
  | same a => RegFree a
  | reg _ => False
  | bind _ _ => False

end NFormula

variable {G : TaskFrame}

/-- Truth with a register vector `r : ℕ → WorldState`. The seven L⁺ clauses are `PlusTruthAt`'s. -/
def NTruthAt (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState) :
    NFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => NTruthAt M τ t r φ → NTruthAt M τ t r ψ
  | .box φ => ∀ σ : WorldHistory G, NTruthAt M σ t r φ
  | .untl ψ φ => ∃ s : G.Duration, t < s ∧ NTruthAt M τ s r φ ∧
      ∀ u : G.Duration, t < u → u < s → NTruthAt M τ u r ψ
  | .snce ψ φ => ∃ s : G.Duration, s < t ∧ NTruthAt M τ s r φ ∧
      ∀ u : G.Duration, s < u → u < t → NTruthAt M τ u r ψ
  | .stab φ => ∀ σ : WorldHistory G, τ.state t = σ.state t → NTruthAt M σ t r φ
  | .same φ => ∀ (σ : WorldHistory G) (s : G.Duration), σ.state s = τ.state t → NTruthAt M σ s r φ
  | .reg i => τ.state t = r i
  | .bind i φ => NTruthAt M τ t (Function.update r i (τ.state t)) φ

namespace NTruth

variable (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState)

theorem box_iff (φ : NFormula) :
    NTruthAt M τ t r φ.box ↔ ∀ σ : WorldHistory G, NTruthAt M σ t r φ := Iff.rfl
theorem imp_iff (φ ψ : NFormula) :
    NTruthAt M τ t r (φ.imp ψ) ↔ (NTruthAt M τ t r φ → NTruthAt M τ t r ψ) := Iff.rfl
theorem reg_iff (i : ℕ) : NTruthAt M τ t r (.reg i) ↔ τ.state t = r i := Iff.rfl
theorem bind_iff (i : ℕ) (φ : NFormula) :
    NTruthAt M τ t r (.bind i φ) ↔ NTruthAt M τ t (Function.update r i (τ.state t)) φ := Iff.rfl
theorem neg_iff (φ : NFormula) : NTruthAt M τ t r φ.neg ↔ ¬ NTruthAt M τ t r φ := Iff.rfl

theorem and_iff (φ ψ : NFormula) :
    NTruthAt M τ t r (φ.and ψ) ↔ NTruthAt M τ t r φ ∧ NTruthAt M τ t r ψ := by
  show ¬ (NTruthAt M τ t r φ → ¬ NTruthAt M τ t r ψ) ↔ _
  constructor
  · intro h; by_contra h'; exact h fun hφ hψ => h' ⟨hφ, hψ⟩
  · rintro ⟨hφ, hψ⟩ h; exact h hφ hψ

theorem or_iff (φ ψ : NFormula) :
    NTruthAt M τ t r (φ.or ψ) ↔ NTruthAt M τ t r φ ∨ NTruthAt M τ t r ψ := by
  show (¬ NTruthAt M τ t r φ → NTruthAt M τ t r ψ) ↔ _
  constructor
  · intro h
    by_cases hφ : NTruthAt M τ t r φ
    · exact Or.inl hφ
    · exact Or.inr (h hφ)
  · rintro (h | h) hn
    · exact absurd h hn
    · exact h

theorem someFuture_iff (φ : NFormula) :
    NTruthAt M τ t r φ.someFuture ↔ ∃ s, t < s ∧ NTruthAt M τ s r φ := by
  constructor
  · rintro ⟨s, hs, hφ, _⟩; exact ⟨s, hs, hφ⟩
  · rintro ⟨s, hs, hφ⟩; exact ⟨s, hs, hφ, fun _ _ _ h => h⟩

theorem somePast_iff (φ : NFormula) :
    NTruthAt M τ t r φ.somePast ↔ ∃ s, s < t ∧ NTruthAt M τ s r φ := by
  constructor
  · rintro ⟨s, hs, hφ, _⟩; exact ⟨s, hs, hφ⟩
  · rintro ⟨s, hs, hφ⟩; exact ⟨s, hs, hφ, fun _ _ _ h => h⟩

theorem allFuture_iff (φ : NFormula) :
    NTruthAt M τ t r φ.allFuture ↔ ∀ s, t < s → NTruthAt M τ s r φ := by
  show ¬ NTruthAt M τ t r φ.neg.someFuture ↔ _
  rw [someFuture_iff]
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn⟩
  · rintro h ⟨s, hs, hn⟩; exact hn (h s hs)

theorem allPast_iff (φ : NFormula) :
    NTruthAt M τ t r φ.allPast ↔ ∀ s, s < t → NTruthAt M τ s r φ := by
  show ¬ NTruthAt M τ t r φ.neg.somePast ↔ _
  rw [somePast_iff]
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn⟩
  · rintro h ⟨s, hs, hn⟩; exact hn (h s hs)

/-- `A φ` quantifies over all (history, time) pairs: `WorldHistory` is total. -/
theorem univ_iff (φ : NFormula) :
    NTruthAt M τ t r φ.univ ↔ ∀ (σ : WorldHistory G) (s : G.Duration), NTruthAt M σ s r φ := by
  unfold NFormula.univ
  simp only [box_iff, and_iff, allPast_iff, allFuture_iff]
  constructor
  · intro h σ s
    obtain ⟨hP, hφ, hF⟩ := h σ
    rcases lt_trichotomy s t with hlt | rfl | hgt
    · exact hP s hlt
    · exact hφ
    · exact hF s hgt
  · intro h σ
    exact ⟨fun s _ => h σ s, h σ t, fun s _ => h σ s⟩

theorem exist_iff (φ : NFormula) :
    NTruthAt M τ t r φ.exist ↔ ∃ (σ : WorldHistory G) (s : G.Duration), NTruthAt M σ s r φ := by
  show ¬ NTruthAt M τ t r φ.neg.univ ↔ _
  rw [univ_iff]
  constructor
  · intro h; by_contra h'; exact h fun σ s hn => h' ⟨σ, s, hn⟩
  · rintro ⟨σ, s, hφ⟩ h; exact h σ s hφ

end NTruth

/-! ### Q1 — the register-free fragment (L⁺ plus `[≡]`) is invariant along history-lifting morphisms -/

section Invariance
variable {D : TemporalOrder} {F' F : FrameOver D}

/-- **Truth of every register-free formula — in particular every `[≡]φ` — is invariant along
any history-lifting morphism**, for arbitrary register vectors on both sides. The `same` clause is
discharged by `lift` exactly as the `stab` clause is: a history through the image state at time
`s` lifts to a history through the given state at time `s`. -/
theorem regFree_invariance (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : NFormula), φ.RegFree → ∀ (τ' : WorldHistory F'.toTaskFrame) (t : ↑D)
      (r' : ℕ → F'.WorldState) (r : ℕ → F.WorldState),
      NTruthAt (g.pullM M) τ' t r' φ ↔ NTruthAt M (g.mapH τ') t r φ := by
  intro φ
  induction φ with
  | atom p => intro _ τ' t r' r; exact Iff.rfl
  | bot => intro _ τ' t r' r; exact Iff.rfl
  | imp a b ih1 ih2 =>
    intro h τ' t r' r
    exact imp_congr (ih1 h.1 τ' t r' r) (ih2 h.2 τ' t r' r)
  | box a ih =>
    intro h τ' t r' r
    constructor
    · intro hb ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' t r' r).1 (hb _)
      rwa [hm] at this
    · intro hb σ'; exact (ih h σ' t r' r).2 (hb _)
  | untl a b ih1 ih2 =>
    intro h τ' t r' r
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s r' r) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' u r' r)
  | snce a b ih1 ih2 =>
    intro h τ' t r' r
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s r' r) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' u r' r)
  | stab a ih =>
    intro h τ' t r' r
    constructor
    · intro hs ρ hρ
      obtain ⟨ρ', hρ't, hρ'⟩ := g.lift ρ (τ'.state t) t hρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' t r' r).1 (hs _ hρ't.symm)
      rwa [hm] at this
    · intro hs σ' he
      exact (ih h σ' t r' r).2 (hs _ (congrArg g.toFun he))
  | same a ih =>
    intro h τ' t r' r
    constructor
    · intro hs ρ s hρ
      obtain ⟨ρ', hρ's, hρ'⟩ := g.lift ρ (τ'.state t) s hρ.symm
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' s r' r).1 (hs _ _ hρ's)
      rwa [hm] at this
    · intro hs σ' s he
      exact (ih h σ' s r' r).2 (hs _ _ (congrArg g.toFun he))
  | reg i => intro h; exact False.elim h
  | bind i a _ => intro h; exact False.elim h

end Invariance

/-! ### Q2 — state nominals / registers define recurrence-freeness -/

section Nominals

/-- `¬(i ∧ (P i ∨ F i))` is valid on every recurrence-free frame, under every assignment. -/
theorem recF_valid (hG : RecurrenceFree G) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i : ℕ) : NTruthAt M τ t r (NFormula.recF i) := by
  simp only [NFormula.recF, NTruth.neg_iff, NTruth.and_iff, NTruth.or_iff, NTruth.somePast_iff,
    NTruth.someFuture_iff, NTruth.reg_iff]
  rintro ⟨hi, ⟨s, hs, hsi⟩ | ⟨s, hs, hsi⟩⟩
  · exact hs.ne (hG τ s t (hsi.trans hi.symm))
  · exact hs.ne' (hG τ s t (hsi.trans hi.symm))

/-- The register-closed sentence `↓_i ¬(P i ∨ F i)` needs no assignment. -/
theorem bindRec_valid (hG : RecurrenceFree G) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i : ℕ) :
    NTruthAt M τ t r (NFormula.bind i (NFormula.recF i)) :=
  recF_valid hG M τ t _ i

/-- **Definability**: the recurrence formula is valid on a frame iff the frame is recurrence-free.
The refuting assignment names the recurring state; the model is irrelevant. -/
theorem recF_defines (G : TaskFrame) (i : ℕ) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState),
      NTruthAt M τ t r (NFormula.recF i)) ↔ RecurrenceFree G := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s (fun _ => τ.state s)
    simp only [NFormula.recF, NTruth.neg_iff, NTruth.and_iff, NTruth.or_iff, NTruth.somePast_iff,
      NTruth.someFuture_iff, NTruth.reg_iff] at h1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact h1 ⟨rfl, Or.inr ⟨t, hlt, hst.symm⟩⟩
    · exact h1 ⟨rfl, Or.inl ⟨t, hgt, hst.symm⟩⟩
  · intro hG M τ t r; exact recF_valid hG M τ t r i

/-- The same for the register-closed sentence: binder instead of assignment. -/
theorem bindRec_defines (G : TaskFrame) (i : ℕ) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState),
      NTruthAt M τ t r (NFormula.bind i (NFormula.recF i))) ↔ RecurrenceFree G := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s (fun _ => τ.state s)
    simp only [NTruth.bind_iff, NFormula.recF, NTruth.neg_iff, NTruth.and_iff, NTruth.or_iff,
      NTruth.somePast_iff, NTruth.someFuture_iff, NTruth.reg_iff, Function.update_self] at h1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact h1 ⟨rfl, Or.inr ⟨t, hlt, hst.symm⟩⟩
    · exact h1 ⟨rfl, Or.inl ⟨t, hgt, hst.symm⟩⟩
  · intro hG M τ t r; exact bindRec_valid hG M τ t r i

/-! #### Splicing two histories that meet at a time -/

/-- **Gluing at a single time** (`app:gluing` for two total histories meeting at `t`): the history
that follows `τ` up to `t` and `σ` from `t` on. Cross-pairs are discharged by *Compositionality*
through the shared state at `t`, the reversed cross-pairs by the reflection law. -/
theorem exists_splice (G : TaskFrame) (τ σ : WorldHistory G) (t : G.Duration)
    (h : τ.state t = σ.state t) :
    ∃ η : WorldHistory G, (∀ x, x ≤ t → η.state x = τ.state x) ∧
      (∀ x, t ≤ x → η.state x = σ.state x) := by
  classical
  have cross : ∀ x y, x ≤ t → t ≤ y → G.TaskRel (τ.state x) (y - x) (σ.state y) := by
    intro x y hx hy
    have e : (t - x) + (y - t) = y - x := by abel
    rw [← e]
    refine (G.comp _ _ _ _ (sub_nonneg.2 hx) (sub_nonneg.2 hy)).2 ⟨τ.state t, τ.respects_task x t, ?_⟩
    rw [h]; exact σ.respects_task t y
  let f : G.Duration → G.WorldState := fun x => if x ≤ t then τ.state x else σ.state x
  have hf : ∀ x y, G.TaskRel (f x) (y - x) (f y) := by
    intro x y
    by_cases hx : x ≤ t <;> by_cases hy : y ≤ t
    · show G.TaskRel (if x ≤ t then _ else _) _ (if y ≤ t then _ else _)
      rw [if_pos hx, if_pos hy]; exact τ.respects_task x y
    · show G.TaskRel (if x ≤ t then _ else _) _ (if y ≤ t then _ else _)
      rw [if_pos hx, if_neg hy]; exact cross x y hx (le_of_not_le hy)
    · show G.TaskRel (if x ≤ t then _ else _) _ (if y ≤ t then _ else _)
      rw [if_neg hx, if_pos hy]
      have h2 := (G.reflection _ _ _).1 (cross y x hy (le_of_not_le hx))
      rwa [neg_sub] at h2
    · show G.TaskRel (if x ≤ t then _ else _) _ (if y ≤ t then _ else _)
      rw [if_neg hx, if_neg hy]; exact σ.respects_task x y
  refine ⟨WorldHistory.ofTotal G f hf, fun x hx => ?_, fun x hx => ?_⟩
  · show (if x ≤ t then τ.state x else σ.state x) = τ.state x
    rw [if_pos hx]
  · show (if x ≤ t then τ.state x else σ.state x) = σ.state x
    rcases eq_or_lt_of_le hx with rfl | hlt
    · rw [if_pos le_rfl]; exact h
    · rw [if_neg (not_le.2 hlt)]

/-- **The transposition formula is valid on every recurrence-free frame.** Two histories through
`i` then `j`, resp. `j` then `i`, time-shift and splice (through `j`) into one history that visits
`i` twice. -/
theorem transF_valid (hG : RecurrenceFree G) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i j : ℕ) : NTruthAt M τ t r (NFormula.transF i j) := by
  simp only [NFormula.transF, NTruth.neg_iff, NTruth.and_iff, NTruth.exist_iff,
    NTruth.someFuture_iff, NTruth.reg_iff]
  rintro ⟨⟨τ₁, s₁, h₁, t₁, hs₁, h₁'⟩, ⟨τ₂, s₂, h₂, t₂, hs₂, h₂'⟩⟩
  -- shift `τ₂` so that it occupies `r j` at time `t₁`
  have hσ : τ₁.state t₁ = (τ₂.timeShift (s₂ - t₁)).state t₁ := by
    show τ₁.state t₁ = τ₂.state (t₁ + (s₂ - t₁))
    rw [show t₁ + (s₂ - t₁) = s₂ by abel, h₁', h₂]
  obtain ⟨η, hη₁, hη₂⟩ := exists_splice G τ₁ (τ₂.timeShift (s₂ - t₁)) t₁ hσ
  have hle : t₁ ≤ t₁ + (t₂ - s₂) := le_add_of_nonneg_right (sub_nonneg.2 hs₂.le)
  have e1 : η.state s₁ = r i := by rw [hη₁ s₁ hs₁.le, h₁]
  have e2 : η.state (t₁ + (t₂ - s₂)) = r i := by
    rw [hη₂ _ hle]
    show τ₂.state (t₁ + (t₂ - s₂) + (s₂ - t₁)) = r i
    rw [show t₁ + (t₂ - s₂) + (s₂ - t₁) = t₂ by abel, h₂']
  exact (lt_of_lt_of_le hs₁ hle).ne (hG η s₁ (t₁ + (t₂ - s₂)) (e1.trans e2.symm))

/-! #### Refutations: the trivial frame at every class, and distinct states on the permissive frame -/

/-- The constant history of the one-state frame. -/
def constHist {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    WorldHistory (FrameOver.trivialFrame (D := D)).toTaskFrame :=
  WorldHistory.ofTotal _ (fun _ => ()) fun _ _ => FrameOver.trivialFrame_taskRel.mpr trivial

theorem trivialFrame_not_recurrenceFree {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    ¬ RecurrenceFree (FrameOver.trivialFrame (D := D)).toTaskFrame := by
  intro h
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  haveI : Subsingleton (FrameOver.trivialFrame (D := D)).WorldState :=
    inferInstanceAs (Subsingleton Unit)
  exact hx.ne (h constHist 0 x (Subsingleton.elim _ _))

/-- Validity of an `NFormula` over a frame class (all models, histories, times, assignments). -/
def NValidIn (fc : FormalSystem.ProofSystem.FrameClass) (φ : NFormula) : Prop :=
  ∀ G : TaskFrame, fc.Sat G → ∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration)
    (r : ℕ → G.WorldState), NTruthAt M τ t r φ

/-- A frame in each class that is not recurrence-free: the one-state frame over `ℤ`, `ℚ`, `ℝ`. -/
theorem exists_sat_not_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass) :
    ∃ G : TaskFrame, fc.Sat G ∧ ¬ RecurrenceFree G := by
  cases fc with
  | Base => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame, trivial,
      trivialFrame_not_recurrenceFree⟩
  | Dense => exact ⟨(FrameOver.trivialFrame (D := ℚ)).toTaskFrame,
      inferInstanceAs (DenselyOrdered ℚ), trivialFrame_not_recurrenceFree⟩
  | ZTime => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame,
      TaskFrame.isZTime_of_instances _, trivialFrame_not_recurrenceFree⟩
  | RTime => exact ⟨(FrameOver.trivialFrame (D := ℝ)).toTaskFrame,
      ⟨inferInstanceAs (DenselyOrdered ℝ), fun s hne hbdd => ⟨sSup s, isLUB_csSup hne hbdd⟩⟩,
      trivialFrame_not_recurrenceFree⟩

/-- **At every class tag the recurrence formula is not class-valid** … -/
theorem recF_not_validIn (fc : FormalSystem.ProofSystem.FrameClass) (i : ℕ) :
    ¬ NValidIn fc (NFormula.recF i) := by
  intro h
  obtain ⟨G, hG, hrec⟩ := exists_sat_not_recurrenceFree fc
  exact hrec ((recF_defines G i).1 (h G hG))

/-- … while it is valid over the class's recurrence-free members. -/
theorem recF_valid_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass) (i : ℕ) :
    ∀ G : TaskFrame, fc.Sat G → RecurrenceFree G →
      ∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState),
        NTruthAt M τ t r (NFormula.recF i) :=
  fun _ _ hG M τ t r => recF_valid hG M τ t r i

/-- The transposition formula fails wherever a state recurs (`i`, `j` both naming it). -/
theorem transF_refuted_of_recur (τ : WorldHistory G) {s t : G.Duration} (hst : s < t)
    (h : τ.state s = τ.state t) :
    ∃ (M : TaskModel G) (r : ℕ → G.WorldState), ¬ NTruthAt M τ s r (NFormula.transF 0 1) := by
  refine ⟨⟨fun _ _ => False⟩, fun _ => τ.state s, ?_⟩
  simp only [NFormula.transF, NTruth.neg_iff, NTruth.and_iff, NTruth.exist_iff,
    NTruth.someFuture_iff, NTruth.reg_iff, not_not]
  exact ⟨⟨τ, s, rfl, t, hst, h.symm⟩, ⟨τ, s, rfl, t, hst, h.symm⟩⟩

theorem transF_not_validIn (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ NValidIn fc (NFormula.transF 0 1) := by
  intro h
  obtain ⟨G, hG, hrec⟩ := exists_sat_not_recurrenceFree fc
  apply hrec
  intro τ s t hst
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · obtain ⟨M, r, hr⟩ := transF_refuted_of_recur τ hlt hst
    exact hr (h G hG M τ s r)
  · obtain ⟨M, r, hr⟩ := transF_refuted_of_recur τ hgt hst.symm
    exact hr (h G hG M τ t r)

/-- The permissive two-state frame over `ℤ`, in which every state assignment is a history. -/
def permZ : FrameOver intOrder := permissiveFrame intOrder inferInstance inferInstance

/-- Any function `ℤ → Bool` is a history of `permZ`. -/
def permHist (f : ℤ → Bool) : WorldHistory permZ.toTaskFrame :=
  WorldHistory.ofTotal _ f (by
    intro s t
    refine (permissiveFrame_taskRel _ _ _ _ _).2 ?_
    by_cases h : t - s = 0
    · right; rw [sub_eq_zero.1 h]
    · left; exact h)

/-- **Transposition with two distinct named states**: `i ↦ true`, `j ↦ false`; the history
`true, false` and the history `false, true` refute `¬(E(i ∧ F j) ∧ E(j ∧ F i))` on `permZ`. So the
formula separates the recurrence-free frames from the full class even with `i ≠ j` enforced. -/
theorem transF_refuted_distinct :
    ∃ (M : TaskModel permZ.toTaskFrame) (τ : WorldHistory permZ.toTaskFrame) (t : ℤ)
      (r : ℕ → permZ.WorldState), r 0 ≠ r 1 ∧ ¬ NTruthAt M τ t r (NFormula.transF 0 1) := by
  refine ⟨⟨fun _ _ => False⟩, permHist (fun x => decide (x = 0)), 0, fun n => decide (n = 0),
    by decide, ?_⟩
  simp only [NFormula.transF, NTruth.neg_iff, NTruth.and_iff, NTruth.exist_iff,
    NTruth.someFuture_iff, NTruth.reg_iff, not_not]
  refine ⟨⟨permHist (fun x => decide (x = 0)), 0, by decide, 1, zero_lt_one, by decide⟩,
    ⟨permHist (fun x => decide (x = 1)), 0, by decide, 1, zero_lt_one, by decide⟩⟩

end Nominals

/-! ## Part 2 — propositional quantifiers -/

inductive QFormula : Type where
  | atom : ℕ → QFormula
  | bot : QFormula
  | imp : QFormula → QFormula → QFormula
  | box : QFormula → QFormula
  | untl : QFormula → QFormula → QFormula
  | snce : QFormula → QFormula → QFormula
  /-- `∀p_n φ`. -/
  | all : ℕ → QFormula → QFormula

namespace QFormula

def top : QFormula := bot.imp bot
def neg (φ : QFormula) : QFormula := φ.imp bot
def and (φ ψ : QFormula) : QFormula := (φ.imp ψ.neg).neg
def or (φ ψ : QFormula) : QFormula := φ.neg.imp ψ
def someFuture (φ : QFormula) : QFormula := untl top φ
def somePast (φ : QFormula) : QFormula := snce top φ
def allFuture (φ : QFormula) : QFormula := (someFuture φ.neg).neg
def allPast (φ : QFormula) : QFormula := (somePast φ.neg).neg
def univ (φ : QFormula) : QFormula := box ((allPast φ).and (φ.and (allFuture φ)))
def exist (φ : QFormula) : QFormula := (univ φ.neg).neg
/-- `Atom(p_n) := E p_n ∧ ∀q (A(p_n → q) ∨ A(p_n → ¬q))`, with `q := p_{n+1}`. -/
def isAtom (n : ℕ) : QFormula :=
  (exist (atom n)).and (all (n + 1) ((univ ((atom n).imp (atom (n + 1)))).or
    (univ ((atom n).imp (atom (n + 1)).neg))))
/-- `∀p_n (Atom(p_n) → ¬(p_n ∧ (P p_n ∨ F p_n)))`. -/
def qRec (n : ℕ) : QFormula :=
  all n ((isAtom n).imp ((atom n).and ((somePast (atom n)).or (someFuture (atom n)))).neg)

end QFormula

/-- Truth relative to an admissible family `Adm` for the quantifier and a valuation
`V : ℕ → Set WorldState` (sentence letters denote state sets, `def:BL-semantics`). -/
def QTruthAt (G : TaskFrame) (Adm : Set (Set G.WorldState)) (V : ℕ → Set G.WorldState)
    (τ : WorldHistory G) (t : G.Duration) : QFormula → Prop
  | .atom n => τ.state t ∈ V n
  | .bot => False
  | .imp φ ψ => QTruthAt G Adm V τ t φ → QTruthAt G Adm V τ t ψ
  | .box φ => ∀ σ : WorldHistory G, QTruthAt G Adm V σ t φ
  | .untl ψ φ => ∃ s : G.Duration, t < s ∧ QTruthAt G Adm V τ s φ ∧
      ∀ u : G.Duration, t < u → u < s → QTruthAt G Adm V τ u ψ
  | .snce ψ φ => ∃ s : G.Duration, s < t ∧ QTruthAt G Adm V τ s φ ∧
      ∀ u : G.Duration, s < u → u < t → QTruthAt G Adm V τ u ψ
  | .all n φ => ∀ S, S ∈ Adm → QTruthAt G Adm (Function.update V n S) τ t φ

namespace QTruth

variable (Adm : Set (Set G.WorldState)) (V : ℕ → Set G.WorldState) (τ : WorldHistory G)
  (t : G.Duration)

theorem atom_iff (n : ℕ) : QTruthAt G Adm V τ t (.atom n) ↔ τ.state t ∈ V n := Iff.rfl
theorem box_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.box ↔ ∀ σ : WorldHistory G, QTruthAt G Adm V σ t φ := Iff.rfl
theorem imp_iff (φ ψ : QFormula) :
    QTruthAt G Adm V τ t (φ.imp ψ) ↔ (QTruthAt G Adm V τ t φ → QTruthAt G Adm V τ t ψ) := Iff.rfl
theorem all_iff (n : ℕ) (φ : QFormula) :
    QTruthAt G Adm V τ t (.all n φ) ↔
      ∀ S, S ∈ Adm → QTruthAt G Adm (Function.update V n S) τ t φ := Iff.rfl
theorem neg_iff (φ : QFormula) : QTruthAt G Adm V τ t φ.neg ↔ ¬ QTruthAt G Adm V τ t φ := Iff.rfl

theorem and_iff (φ ψ : QFormula) :
    QTruthAt G Adm V τ t (φ.and ψ) ↔ QTruthAt G Adm V τ t φ ∧ QTruthAt G Adm V τ t ψ := by
  show ¬ (QTruthAt G Adm V τ t φ → ¬ QTruthAt G Adm V τ t ψ) ↔ _
  constructor
  · intro h; by_contra h'; exact h fun hφ hψ => h' ⟨hφ, hψ⟩
  · rintro ⟨hφ, hψ⟩ h; exact h hφ hψ

theorem or_iff (φ ψ : QFormula) :
    QTruthAt G Adm V τ t (φ.or ψ) ↔ QTruthAt G Adm V τ t φ ∨ QTruthAt G Adm V τ t ψ := by
  show (¬ QTruthAt G Adm V τ t φ → QTruthAt G Adm V τ t ψ) ↔ _
  constructor
  · intro h
    by_cases hφ : QTruthAt G Adm V τ t φ
    · exact Or.inl hφ
    · exact Or.inr (h hφ)
  · rintro (h | h) hn
    · exact absurd h hn
    · exact h

theorem someFuture_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.someFuture ↔ ∃ s, t < s ∧ QTruthAt G Adm V τ s φ := by
  constructor
  · rintro ⟨s, hs, hφ, _⟩; exact ⟨s, hs, hφ⟩
  · rintro ⟨s, hs, hφ⟩; exact ⟨s, hs, hφ, fun _ _ _ h => h⟩

theorem somePast_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.somePast ↔ ∃ s, s < t ∧ QTruthAt G Adm V τ s φ := by
  constructor
  · rintro ⟨s, hs, hφ, _⟩; exact ⟨s, hs, hφ⟩
  · rintro ⟨s, hs, hφ⟩; exact ⟨s, hs, hφ, fun _ _ _ h => h⟩

theorem allFuture_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.allFuture ↔ ∀ s, t < s → QTruthAt G Adm V τ s φ := by
  show ¬ QTruthAt G Adm V τ t φ.neg.someFuture ↔ _
  rw [someFuture_iff]
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn⟩
  · rintro h ⟨s, hs, hn⟩; exact hn (h s hs)

theorem allPast_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.allPast ↔ ∀ s, s < t → QTruthAt G Adm V τ s φ := by
  show ¬ QTruthAt G Adm V τ t φ.neg.somePast ↔ _
  rw [somePast_iff]
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn⟩
  · rintro h ⟨s, hs, hn⟩; exact hn (h s hs)

theorem univ_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.univ ↔
      ∀ (σ : WorldHistory G) (s : G.Duration), QTruthAt G Adm V σ s φ := by
  unfold QFormula.univ
  simp only [box_iff, and_iff, allPast_iff, allFuture_iff]
  constructor
  · intro h σ s
    obtain ⟨hP, hφ, hF⟩ := h σ
    rcases lt_trichotomy s t with hlt | rfl | hgt
    · exact hP s hlt
    · exact hφ
    · exact hF s hgt
  · intro h σ
    exact ⟨fun s _ => h σ s, h σ t, fun s _ => h σ s⟩

theorem exist_iff (φ : QFormula) :
    QTruthAt G Adm V τ t φ.exist ↔
      ∃ (σ : WorldHistory G) (s : G.Duration), QTruthAt G Adm V σ s φ := by
  show ¬ QTruthAt G Adm V τ t φ.neg.univ ↔ _
  rw [univ_iff]
  constructor
  · intro h; by_contra h'; exact h fun σ s hn => h' ⟨σ, s, hn⟩
  · rintro ⟨σ, s, hφ⟩ h; exact h σ s hφ

end QTruth

/-! ### Q1 (second half) — quantifiers over lifted propositions are invariant -/

section Lifted
variable {D : TemporalOrder} {F' F : FrameOver D}

/-- The lifted (clock-independent, along `g`) propositions on `F'`: preimages of state sets of `F`. -/
def pulledBack (g : HistMap F' F) : Set (Set F'.WorldState) :=
  {S | ∃ T : Set F.WorldState, S = g.toFun ⁻¹' T}

def HistMap.pullV (g : HistMap F' F) (V : ℕ → Set F.WorldState) : ℕ → Set F'.WorldState :=
  fun n => g.toFun ⁻¹' (V n)

theorem pullV_update (g : HistMap F' F) (V : ℕ → Set F.WorldState) (n : ℕ) (T : Set F.WorldState) :
    g.pullV (Function.update V n T) = Function.update (g.pullV V) n (g.toFun ⁻¹' T) := by
  funext m
  by_cases h : m = n
  · subst h; simp [HistMap.pullV]
  · simp [HistMap.pullV, Function.update_of_ne h]

/-- **Quantifiers ranging over lifted propositions see nothing the base frame does not**: truth
under the lifted family on `F'` equals standard truth on `F`, along any history-lifting
morphism. -/
theorem lifted_invariance (g : HistMorphism F' F) :
    ∀ (φ : QFormula) (V : ℕ → Set F.WorldState) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      QTruthAt F'.toTaskFrame (pulledBack g.toHistMap) (g.toHistMap.pullV V) τ' t φ ↔
        QTruthAt F.toTaskFrame Set.univ V (g.mapH τ') t φ := by
  intro φ
  induction φ with
  | atom n => intro V τ' t; exact Iff.rfl
  | bot => intro V τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro V τ' t; exact imp_congr (ih1 V τ' t) (ih2 V τ' t)
  | box a ih =>
    intro V τ' t
    constructor
    · intro hb ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih V ρ' t).1 (hb _)
      rwa [hm] at this
    · intro hb σ'; exact (ih V σ' t).2 (hb _)
  | untl a b ih1 ih2 =>
    intro V τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 V τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 V τ' u)
  | snce a b ih1 ih2 =>
    intro V τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 V τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 V τ' u)
  | all n a ih =>
    intro V τ' t
    constructor
    · intro h T _
      refine (ih (Function.update V n T) τ' t).1 ?_
      rw [pullV_update]
      exact h (g.toFun ⁻¹' T) ⟨T, rfl⟩
    · rintro h S ⟨T, rfl⟩
      rw [← pullV_update]
      exact (ih (Function.update V n T) τ' t).2 (h T (Set.mem_univ _))

end Lifted

/-! ### Q3 — the universal modality in L, `Atom(p)`, and recurrence under standard quantification -/

section Universal

/-- `A φ := □(Hφ ∧ φ ∧ Gφ)` in the live language L: the box ranges over all histories at the
present time, and `H`, `G` over all other times of a *total* history. -/
theorem fand_iff (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (a b : Formula) :
    TruthAt M τ t (a.and b) ↔ TruthAt M τ t a ∧ TruthAt M τ t b := by
  show ¬ (TruthAt M τ t a → ¬ TruthAt M τ t b) ↔ _
  constructor
  · intro h; by_contra h'; exact h fun ha hb => h' ⟨ha, hb⟩
  · rintro ⟨ha, hb⟩ h; exact h ha hb

theorem fallFuture_iff (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (a : Formula) :
    TruthAt M τ t a.allFuture ↔ ∀ s, t < s → TruthAt M τ s a := by
  show ¬ (∃ s, t < s ∧ ¬ TruthAt M τ s a ∧ ∀ r, t < r → r < s → TruthAt M τ r Formula.top) ↔ _
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn, fun _ _ _ x => x⟩
  · rintro h ⟨s, hs, hn, _⟩; exact hn (h s hs)

theorem fallPast_iff (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (a : Formula) :
    TruthAt M τ t a.allPast ↔ ∀ s, s < t → TruthAt M τ s a := by
  show ¬ (∃ s, s < t ∧ ¬ TruthAt M τ s a ∧ ∀ r, s < r → r < t → TruthAt M τ r Formula.top) ↔ _
  constructor
  · intro h s hs; by_contra hn; exact h ⟨s, hs, hn, fun _ _ _ x => x⟩
  · rintro h ⟨s, hs, hn, _⟩; exact hn (h s hs)

/-- **The universal modality is definable in L**: `□(Hφ ∧ φ ∧ Gφ)` holds iff `φ` holds at every
(history, time) pair. The only structural fact used is totality of `WorldHistory`. -/
theorem formula_univ_iff (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.box (φ.allPast.and (φ.and φ.allFuture))) ↔
      ∀ (σ : WorldHistory G) (s : G.Duration), TruthAt M σ s φ := by
  show (∀ σ : WorldHistory G, TruthAt M σ t (φ.allPast.and (φ.and φ.allFuture))) ↔ _
  constructor
  · intro h σ s
    have h1 := (fand_iff M σ t _ _).1 (h σ)
    have h2 := (fand_iff M σ t _ _).1 h1.2
    rcases lt_trichotomy s t with hlt | rfl | hgt
    · exact (fallPast_iff M σ t φ).1 h1.1 s hlt
    · exact h2.1
    · exact (fallFuture_iff M σ t φ).1 h2.2 s hgt
  · intro h σ
    exact (fand_iff M σ t _ _).2 ⟨(fallPast_iff M σ t φ).2 fun s _ => h σ s,
      (fand_iff M σ t _ _).2 ⟨h σ t, (fallFuture_iff M σ t φ).2 fun s _ => h σ s⟩⟩

/-- **`Atom(p)` under the standard semantics says that `p` is a singleton among occurring
states**: some occurring state satisfies `p`, and all occurring `p`-states coincide. The (⇐)
direction uses `cor:occurrence` for `E p`. -/
theorem isAtom_iff (V : ℕ → Set G.WorldState) (τ : WorldHistory G) (t : G.Duration) (n : ℕ) :
    QTruthAt G Set.univ V τ t (QFormula.isAtom n) ↔
      ∃ w ∈ V n, ∀ (ρ : WorldHistory G) (s : G.Duration), ρ.state s ∈ V n → ρ.state s = w := by
  have hne : n ≠ n + 1 := Nat.ne_of_lt (Nat.lt_succ_self n)
  rw [QFormula.isAtom, QTruth.and_iff, QTruth.exist_iff, QTruth.all_iff]
  simp only [QTruth.or_iff, QTruth.univ_iff, QTruth.imp_iff, QTruth.neg_iff, QTruth.atom_iff,
    Function.update_self, Function.update_of_ne hne]
  constructor
  · rintro ⟨⟨ρ₀, s₀, h₀⟩, hq⟩
    refine ⟨ρ₀.state s₀, h₀, fun ρ s hs => ?_⟩
    rcases hq {ρ₀.state s₀} (Set.mem_univ _) with h | h
    · exact h ρ s hs
    · exact absurd (Set.mem_singleton _) (h ρ₀ s₀ h₀)
  · rintro ⟨w, hw, huniq⟩
    obtain ⟨ρ₀, hρ₀⟩ := PartialHistory.occurrence G w t
    refine ⟨⟨ρ₀, t, by rw [hρ₀]; exact hw⟩, fun S _ => ?_⟩
    by_cases hwS : w ∈ S
    · left; intro ρ s hs; rw [huniq ρ s hs]; exact hwS
    · right; intro ρ s hs; rw [huniq ρ s hs]; exact hwS

/-- `∀p (Atom(p) → ¬(p ∧ (Pp ∨ Fp)))` is valid on every recurrence-free frame. -/
theorem qRec_valid (hG : RecurrenceFree G) (V : ℕ → Set G.WorldState) (τ : WorldHistory G)
    (t : G.Duration) (n : ℕ) : QTruthAt G Set.univ V τ t (QFormula.qRec n) := by
  rw [QFormula.qRec, QTruth.all_iff]
  intro S _
  rw [QTruth.imp_iff, isAtom_iff, QTruth.neg_iff, QTruth.and_iff, QTruth.or_iff,
    QTruth.somePast_iff, QTruth.someFuture_iff]
  simp only [QTruth.atom_iff, Function.update_self]
  rintro ⟨w, -, huniq⟩ ⟨ht, ⟨s, hs, hs'⟩ | ⟨s, hs, hs'⟩⟩
  · exact hs.ne (hG τ s t ((huniq τ s hs').trans (huniq τ t ht).symm))
  · exact hs.ne' (hG τ s t ((huniq τ s hs').trans (huniq τ t ht).symm))

/-- **Definability under standard quantification**: the quantified recurrence sentence is valid
on a frame iff the frame is recurrence-free — the propositional quantifier manufactures the
nominal `{τ(s)}` itself. -/
theorem qRec_defines (G : TaskFrame) (n : ℕ) :
    (∀ (V : ℕ → Set G.WorldState) (τ : WorldHistory G) (t : G.Duration),
      QTruthAt G Set.univ V τ t (QFormula.qRec n)) ↔ RecurrenceFree G := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h (fun _ => ∅) τ s
    rw [QFormula.qRec, QTruth.all_iff] at h1
    have h2 := h1 {τ.state s} (Set.mem_univ _)
    rw [QTruth.imp_iff, isAtom_iff, QTruth.neg_iff, QTruth.and_iff, QTruth.or_iff,
      QTruth.somePast_iff, QTruth.someFuture_iff] at h2
    simp only [QTruth.atom_iff, Function.update_self] at h2
    apply h2
    · exact ⟨τ.state s, Set.mem_singleton _, fun ρ u hu => hu⟩
    · refine ⟨Set.mem_singleton _, ?_⟩
      rcases lt_or_gt_of_ne hne with hlt | hgt
      · exact Or.inr ⟨t, hlt, hst.symm⟩
      · exact Or.inl ⟨t, hgt, hst.symm⟩
  · intro hG V τ t; exact qRec_valid hG V τ t n

/-- **Standard-semantics quantifier truth is not invariant** along any history-lifting morphism
from a recurrence-free frame onto a frame with recurrence (the translation projection
`prodProj F` of the product probe is one, for every `F` with recurrence). Contrast
`lifted_invariance`. -/
theorem standard_not_invariant {D : TemporalOrder} {F' F : FrameOver D} (g : HistMorphism F' F)
    (hF' : RecurrenceFree F'.toTaskFrame) (hF : ¬ RecurrenceFree F.toTaskFrame) :
    ¬ ∀ (φ : QFormula) (V : ℕ → Set F.WorldState) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      QTruthAt F'.toTaskFrame Set.univ (g.toHistMap.pullV V) τ' t φ ↔
        QTruthAt F.toTaskFrame Set.univ V (g.mapH τ') t φ := by
  intro hinv
  apply hF
  rw [← qRec_defines _ 0]
  intro V τ t
  obtain ⟨τ', hτ'⟩ := g.onto τ
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  rw [← hm]
  exact (hinv _ V τ' t).1 (qRec_valid hF' _ τ' t 0)

end Universal

end Probe628
