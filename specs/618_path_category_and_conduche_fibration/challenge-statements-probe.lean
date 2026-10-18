import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.Combinatorics.Quiver.Path
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Duration
import FormalSystem.Semantics.IntNormalFormEffective

namespace FormalSystem.Semantics.Presheaf

open CategoryTheory

variable {F : TaskFrame}

-- Phase 1: the cast kit and sum-form gluing

def Beh.castLen {l l' : F.Duration} (h : l = l') (τ : Beh F l) : Beh F l' := sorry

@[simp] theorem Beh.castLen_val {l l' : F.Duration} (h : l = l') (τ : Beh F l) :
    (Beh.castLen h τ).val = τ.val := sorry

theorem Beh.castLen_eq_iff {l l' : F.Duration} (h : l = l') (τ : Beh F l) (σ : Beh F l') :
    Beh.castLen h τ = σ ↔ τ.val = σ.val := sorry

def glueSum (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) : Beh F (l₁ + l₂) := sorry

theorem glueSum_restrict_left (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict 0 l₁ le_rfl h₁ (by rw [zero_add]; exact le_add_of_nonneg_right h₂)
      (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₁ := sorry

theorem glueSum_restrict_right (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict l₁ l₂ h₁ h₂ le_rfl (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₂ := sorry

theorem glueSum_states_zero (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states 0
        (Beh.mem_dom _ le_rfl (add_nonneg h₁ h₂))
      = τ₁.val.states 0 (Beh.mem_dom τ₁ le_rfl h₁) := sorry

theorem glueSum_states_end (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states (l₁ + l₂)
        (Beh.mem_dom _ (add_nonneg h₁ h₂) le_rfl)
      = τ₂.val.states l₂ (Beh.mem_dom τ₂ h₂ le_rfl) := sorry

-- Phase 2: the hom structure, identities, composition, unit laws, the one-object category

structure PathHom (F : TaskFrame) (w u : F.WorldState) where
  len : Dur F.Duration
  sec : Beh F len.val
  src : sec.val.states 0 (Beh.mem_dom sec le_rfl len.property) = w
  tgt : sec.val.states len.val (Beh.mem_dom sec len.property le_rfl) = u

theorem PathHom.ext' {w u : F.WorldState} {f g : PathHom F w u} (hl : f.len = g.len)
    (hs : f.sec.val = g.sec.val) : f = g := sorry

def PathHom.id (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : PathHom F w w := sorry

def PathHom.comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u v : F.WorldState}
    (f : PathHom F w u) (g : PathHom F u v) : PathHom F w v := sorry

@[simp] theorem PathHom.comp_len (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) :
    (PathHom.comp hcomp f g).len = Dur.comp f.len g.len := sorry

@[simp] theorem PathHom.id_len (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    (PathHom.id F w).len = Dur.id := sorry

theorem PathHom.id_comp [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp (PathHom.id F w) f = f := sorry

theorem PathHom.comp_id [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp f (PathHom.id F u) = f := sorry

structure BObj (D : TemporalOrder) where
  unit : Unit

instance BObj.instCategory (D : TemporalOrder) : Category (BObj D) where
  Hom _ _ := Dur D
  id _ := Dur.id
  comp f g := Dur.comp f g
  id_comp := Dur.id_comp
  comp_id := Dur.comp_id
  assoc := Dur.comp_assoc

-- Phase 3: associativity, the path category, the length functor

theorem PathHom.comp_assoc (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v x : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) (h : PathHom F v x) :
    PathHom.comp hcomp (PathHom.comp hcomp f g) h
      = PathHom.comp hcomp f (PathHom.comp hcomp g h) := sorry

def PathCat (F : TaskFrame) : Type := F.WorldState

instance PathCat.instCategory (F : TaskFrame) [F.IsRegular] : Category (PathCat F) where
  Hom w u := PathHom F w u
  id w := PathHom.id F w
  comp f g := PathHom.comp F.comp f g
  id_comp f := PathHom.id_comp f
  comp_id f := PathHom.comp_id f
  assoc f g h := PathHom.comp_assoc F.comp f g h

def PathCat.len (F : TaskFrame) [F.IsRegular] : PathCat F ⥤ BObj F.Duration := sorry

theorem PathCat.len_map (F : TaskFrame) [F.IsRegular] {w u : PathCat F} (f : w ⟶ u) :
    (PathCat.len F).map f = PathHom.len f := sorry

-- Phase 4: the discrete Conduché fibration property of `len`

def IsDiscreteConduche {D : TemporalOrder} {E : Type*} [Category E] (P : E ⥤ BObj D) : Prop :=
  ∀ {A B : E} (e : A ⟶ B) (fac : Factorization (P.map e)),
    ∃! t : Σ C : E, (A ⟶ C) × (C ⟶ B),
      t.2.1 ≫ t.2.2 = e ∧ (P.map t.2.1).val = fac.fst ∧ (P.map t.2.2).val = fac.snd

def PathHom.cutState {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    F.WorldState := sorry

def PathHom.factorLeft {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F w (e.cutState fac) := sorry

def PathHom.factorRight {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F (e.cutState fac) u := sorry

@[simp] theorem PathHom.factorLeft_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorLeft fac).len.val = fac.fst := sorry

@[simp] theorem PathHom.factorRight_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorRight fac).len.val = fac.snd := sorry

theorem PathHom.factor_comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom.comp hcomp (e.factorLeft fac) (e.factorRight fac) = e := sorry

theorem PathHom.factor_unique (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) {c : F.WorldState}
    (e₁ : PathHom F w c) (e₂ : PathHom F c u) (h : PathHom.comp hcomp e₁ e₂ = e)
    (h₁ : e₁.len.val = fac.fst) (h₂ : e₂.len.val = fac.snd) :
    c = e.cutState fac ∧ e₁.sec.val = (e.factorLeft fac).sec.val
      ∧ e₂.sec.val = (e.factorRight fac).sec.val := sorry

theorem PathCat.len_isDiscreteConduche (F : TaskFrame) [F.IsRegular] :
    IsDiscreteConduche (PathCat.len F) := sorry

-- Phase 5: the associated presheaf of `len` is `Beh F`, as an equality

def PathHom.assocRestrict {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) : Σ c c' : F.WorldState, PathHom F c c' := sorry

theorem PathHom.assocRestrict_len {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.len = l' := sorry

theorem PathHom.assocRestrict_sec {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.sec.val
      = (Beh.restrictTr f (Beh.castLen (congrArg Subtype.val hl) e.sec)).val := sorry

theorem PathHom.assocRestrict_unique (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l) (e : PathHom F w u)
    (hl : e.len = l) {c c' : F.WorldState} (e₁ : PathHom F w c) (e₂ : PathHom F c c')
    (e₃ : PathHom F c' u) (h : PathHom.comp hcomp (PathHom.comp hcomp e₁ e₂) e₃ = e)
    (h₁ : e₁.len.val = f.shift) (h₂ : e₂.len.val = l'.val) :
    e₂.sec.val = (PathHom.assocRestrict f e hl).2.2.sec.val := sorry

theorem PathHom.assocRestrict_id {w u : F.WorldState} (e : PathHom F w u) :
    (PathHom.assocRestrict (Tr.id e.len) e rfl).2.2.sec.val = e.sec.val := sorry

theorem PathHom.assocRestrict_comp {w u : F.WorldState} {l'' l' l : Obj F.Duration}
    (f : Tr l' l) (g : Tr l'' l') (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict g (PathHom.assocRestrict f e hl).2.2
        (PathHom.assocRestrict_len f e hl)).2.2.sec.val
      = (PathHom.assocRestrict (Tr.comp f g) e hl).2.2.sec.val := sorry

-- Phase 6: `D = ℤ`, layer 1 — sections over `[0, n]` are the adjacency-respecting windows

theorem iter_of_adjacent_window (F : FrameOver intOrder) (n : ℤ) (g : ℤ → F.WorldState)
    (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (s t : ℤ) (hs : 0 ≤ s) (hst : s ≤ t) (htn : t ≤ n) :
    iter (FrameOver.step F) (Int.toNat (t - s)) (g s) (g t) := sorry

def Beh.ofAdjacentWindow (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1))) :
    Beh F.toTaskFrame n := sorry

theorem Beh.ofAdjacentWindow_states (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (i : ℤ) (hi : (Beh.ofAdjacentWindow F n hn g hg).val.domain i) :
    (Beh.ofAdjacentWindow F n hn g hg).val.states i hi = g i := sorry

theorem beh_int_iff_adjacent_window (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) :
    (∃ τ : Beh F.toTaskFrame n, ∀ i (hi : τ.val.domain i), τ.val.states i hi = g i)
      ↔ ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)) := sorry

-- Phase 7: `D = ℤ`, layer 2a — sections to paths in the one-step graph

def StepGraph (F : FrameOver intOrder) : Type := F.WorldState

instance StepGraph.instQuiver (F : FrameOver intOrder) : Quiver (StepGraph F) :=
  ⟨fun a b => PLift (FrameOver.step F a b)⟩

abbrev StepPath (F : FrameOver intOrder) (w u : F.WorldState) : Type :=
  Quiver.Path (V := StepGraph F) w u

def PathHom.toPathAux (F : FrameOver intOrder) [F.IsRegular] (n : ℕ) {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) (hn : (n : ℤ) = e.len.val) : StepPath F w u := sorry

def PathHom.toPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) : StepPath F w u := sorry

theorem PathHom.toPath_length (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) :
    (PathHom.toPath F e).length = Int.toNat e.len.val := sorry

theorem PathHom.toPath_id (F : FrameOver intOrder) [F.IsRegular] (w : F.WorldState) :
    PathHom.toPath F (PathHom.id F.toTaskFrame w) = Quiver.Path.nil := sorry

theorem PathHom.toPath_comp (F : FrameOver intOrder) [F.IsRegular] {w u v : F.WorldState}
    (f : PathHom F.toTaskFrame w u) (g : PathHom F.toTaskFrame u v) :
    PathHom.toPath F (PathHom.comp (TaskFrame.comp F.toTaskFrame) f g)
      = (PathHom.toPath F f).comp (PathHom.toPath F g) := sorry

-- Phase 8: `D = ℤ`, layer 2b — paths to sections, the round trips, the free category

def PathHom.ofStep (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (h : FrameOver.step F w u) : PathHom F.toTaskFrame w u := sorry

def PathHom.ofPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (p : StepPath F w u) : PathHom F.toTaskFrame w u := sorry

theorem PathHom.ofPath_toPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) : PathHom.ofPath F (PathHom.toPath F e) = e := sorry

theorem PathHom.toPath_ofPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (p : StepPath F w u) : PathHom.toPath F (PathHom.ofPath F p) = p := sorry

def PathHom.pathEquiv (F : FrameOver intOrder) [F.IsRegular] (w u : F.WorldState) :
    PathHom F.toTaskFrame w u ≃ StepPath F w u := sorry

end FormalSystem.Semantics.Presheaf
