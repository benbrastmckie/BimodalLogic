import FormalSystem.OpenLanguage

/-!
# Probe 01: `▷` is eliminable through separation — the Lean half of the definability verdict

**Compiled-live**: stated against the repository's own `OpenTruthAt`, `PlusTruthAt`, `paste`,
`AgreeUpTo`/`AgreeFrom` and `IsPurePast`/`IsPureFuture`, not against a mirror. No faithfulness
audit is owed.

## What is proved here

Write a formula as **past-determined** at a frame when its truth at `(τ, t)` depends only on
`τ|(-∞, t]` (`PastDet`), and **future-determined** when it depends only on `τ|[t, ∞)` (`FutDet`).
Every `IsPurePast` L⁺ formula is past-determined and every `IsPureFuture` one future-determined
(`pastDet_of_isPurePast`, `futDet_of_isPureFuture`, from the landed `truth_congr_agreeUpTo` /
`truth_congr_agreeFrom`).

1. **The elimination** (`ofutP_or_iff`, `opastP_or_iff`): on every regular task frame, for `α`
   past-determined and `β` future-determined,

   ```
   ▷(α ∨ β)  ↔  α ∨ ⊡β          ◁(α ∨ β)  ↔  ⊡α ∨ β
   ```

   The `→` half is one `paste`: a world `σ` through the present state is replaced by
   `τ|(-∞,t] ⌢ σ|(t,∞) ∈ |τ⟩_t`, on which `α` reads as on `τ` and `β` as on `σ`. The `←` half is
   the inclusion `|τ⟩_t ⊆ ⟨τ⟩_t` and past-determinedness. `[F.IsRegular]` enters through `paste`
   and nowhere else.

2. **The CNF form** (`ofutP_sepForm_iff`, `opastP_sepForm_iff`): `▷` of a conjunction of such
   clauses is the conjunction of the eliminated clauses, `⋀ᵢ (αᵢ ∨ ⊡βᵢ)`.

3. **The translation** (`tr`, `openTruthAt_iff_tr`, `openValidIn_iff_tr`): given a *separation
   hypothesis* over a frame predicate `P` — every L⁺ formula is equivalent, on every regular frame
   satisfying `P`, to a CNF of (past-determined ∨ future-determined) clauses — there is a
   translation `tr : OpenFormula → PlusFormula` agreeing with `OpenTruthAt` at every model, world
   and time over every regular `P`-frame. Hence `OpenValidIn fc φ ↔ PlusValidIn fc (tr φ)` for
   `fc ∈ {ZTime, RTime}` once the hypothesis is supplied for that class.

## What is NOT proved here, and where it comes from

The separation hypothesis itself. For `.ZTime` it is Gabbay's Separation Theorem over the integer
flow (Gabbay, Hodkinson, Reynolds, *Temporal Logic* vol. 1, Theorem 10.2.9); for `.RTime`, its
Dedekind-complete form (ibid., Theorem 10.3.20) — in both cases applied to the U/S formula obtained
by reading each maximal `□ψ`/`⊡ψ` subformula and each atom as a propositional leaf, which is
legitimate because each such leaf is a function of the time alone (`□`) or of the present state
alone (`⊡`, `stab_state_only`), hence both past- and future-determined. The paper-level bookkeeping
(leaf abstraction, the CNF rearrangement of a separated formula, order-isomorphism invariance of
U/S truth) is recorded in the research report and is UNVERIFIED in Lean. Over non-Dedekind-complete
durations (`ℚ`, hence the `.Dense` and `.Base` classes) the hypothesis is **false** for U/S, so
nothing here applies there; see the report.

## Axioms

`#print axioms` at the end: the elimination and CNF lemmas report `[propext, Classical.choice, Quot.sound]`
(`Classical.choice` only through the case split on `α` that the disjunctive statement forces — `or` is `¬α → β` and `PlusTruth.or_iff` is classical; `paste` itself is choice-free, and the pure-future instance `ofutP_of_futDet`, which needs no split, reports `[propext, Quot.sound]`); the translation also uses choice to pick a separated form, as
any function defined from an existential must.

## Compile

```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/854_open_future_modal_lplus_definability/probes/01_ofut-elimination-and-translation.lean
```
-/

namespace Probe854R01

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage

variable {F : TaskFrame}

/-! ## Past- and future-determined L⁺ formulas -/

/-- `φ` is **past-determined** at `F`: its truth at `(τ, t)` depends only on `τ|(-∞, t]`. -/
def PastDet (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeUpTo τ σ t →
    (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)

/-- `φ` is **future-determined** at `F`: its truth at `(τ, t)` depends only on `τ|[t, ∞)`. -/
def FutDet (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeFrom τ σ t →
    (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)

/-- Syntactically pure-past formulas are past-determined (`truth_congr_agreeUpTo`). -/
theorem pastDet_of_isPurePast {φ : PlusFormula} (h : PlusFormula.IsPurePast φ) : PastDet F φ :=
  fun M τ σ t hag => truth_congr_agreeUpTo M h τ σ t hag

/-- Syntactically pure-future formulas are future-determined (`truth_congr_agreeFrom`). -/
theorem futDet_of_isPureFuture {φ : PlusFormula} (h : PlusFormula.IsPureFuture φ) : FutDet F φ :=
  fun M τ σ t hag => truth_congr_agreeFrom M h τ σ t hag

/-! ## `▷` and `◁` read at the L⁺ level -/

/-- `▷φ` for an L⁺ argument: `φ` holds at every world in `|τ⟩_t`. -/
def OfutP (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeUpTo τ σ t → PlusTruthAt M σ t φ

/-- `◁φ` for an L⁺ argument: `φ` holds at every world in `⟨τ|_t`. -/
def OpastP (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeFrom τ σ t → PlusTruthAt M σ t φ

theorem ofutP_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    OpenTruthAt M τ t (.ofut (ofPlus φ)) ↔ OfutP M τ t φ :=
  forall_congr' fun σ => imp_congr_right fun _ => openTruthAt_ofPlus M σ t φ

theorem opastP_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    OpenTruthAt M τ t (.opast (ofPlus φ)) ↔ OpastP M τ t φ :=
  forall_congr' fun σ => imp_congr_right fun _ => openTruthAt_ofPlus M σ t φ

theorem ofutP_and (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : PlusFormula) :
    OfutP M τ t (φ.and ψ) ↔ OfutP M τ t φ ∧ OfutP M τ t ψ := by
  constructor
  · intro h
    exact ⟨fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).1,
      fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).2⟩
  · rintro ⟨h1, h2⟩ σ hs
    exact (PlusTruth.and_iff M σ t φ ψ).mpr ⟨h1 σ hs, h2 σ hs⟩

theorem opastP_and (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : PlusFormula) :
    OpastP M τ t (φ.and ψ) ↔ OpastP M τ t φ ∧ OpastP M τ t ψ := by
  constructor
  · intro h
    exact ⟨fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).1,
      fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).2⟩
  · rintro ⟨h1, h2⟩ σ hs
    exact (PlusTruth.and_iff M σ t φ ψ).mpr ⟨h1 σ hs, h2 σ hs⟩

theorem ofutP_top (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    OfutP M τ t PlusFormula.top :=
  fun σ _ => PlusTruth.top_true M σ t

theorem opastP_top (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    OpastP M τ t PlusFormula.top :=
  fun σ _ => PlusTruth.top_true M σ t

/-! ## The elimination: `▷(α ∨ β) ↔ α ∨ ⊡β` and `◁(α ∨ β) ↔ ⊡α ∨ β` -/

/-- **`▷(α ∨ β) ↔ α ∨ ⊡β`** for `α` past-determined and `β` future-determined, on every regular
task frame. The `→` half pastes `τ`'s past onto each `σ ∈ ⟨τ⟩_t`; the `←` half is
`|τ⟩_t ⊆ ⟨τ⟩_t`. -/
theorem ofutP_or_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OfutP M τ t (α.or β) ↔ PlusTruthAt M τ t (α.or (.stab β)) := by
  rw [PlusTruth.or_iff, PlusTruth.stab_iff]
  constructor
  · intro h
    by_cases hA : PlusTruthAt M τ t α
    · exact Or.inl hA
    · refine Or.inr fun σ hsame => ?_
      have hρτ : AgreeUpTo τ (paste τ σ t hsame) t :=
        (agreeUpTo_equivalence t).symm (paste_agreeUpTo τ σ t hsame)
      rcases (PlusTruth.or_iff M _ t α β).mp (h _ hρτ) with hA' | hB'
      · exact absurd ((hα M τ _ t hρτ).mpr hA') hA
      · exact (hβ M _ σ t (paste_agreeFrom τ σ t hsame)).mp hB'
  · rintro (hA | hB) σ hag
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inl ((hα M τ σ t hag).mp hA))
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inr (hB σ (hag t le_rfl)))

/-- **`◁(α ∨ β) ↔ ⊡α ∨ β`**, the time-reflected elimination: paste `σ`'s past onto `τ`'s
future. -/
theorem opastP_or_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OpastP M τ t (α.or β) ↔ PlusTruthAt M τ t ((PlusFormula.stab α).or β) := by
  rw [PlusTruth.or_iff, PlusTruth.stab_iff]
  constructor
  · intro h
    by_cases hB : PlusTruthAt M τ t β
    · exact Or.inr hB
    · refine Or.inl fun σ hsame => ?_
      have hρτ : AgreeFrom τ (paste σ τ t hsame.symm) t :=
        (agreeFrom_equivalence t).symm (paste_agreeFrom σ τ t hsame.symm)
      rcases (PlusTruth.or_iff M _ t α β).mp (h _ hρτ) with hA' | hB'
      · exact (hα M _ σ t (paste_agreeUpTo σ τ t hsame.symm)).mp hA'
      · exact absurd ((hβ M τ _ t hρτ).mpr hB') hB
  · rintro (hA | hB) σ hag
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inl (hA σ (hag t le_rfl)))
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inr ((hβ M τ σ t hag).mp hB))

/-! ## Separated CNFs and their eliminated forms -/

/-- A separated CNF `⋀ᵢ (αᵢ ∨ βᵢ)`, as a list of clauses. -/
def sepForm : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or c.2).and (sepForm L)

/-- `⋀ᵢ (αᵢ ∨ ⊡βᵢ)`: the `▷`-eliminated form of `sepForm L`. -/
def ofutElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or (.stab c.2)).and (ofutElim L)

/-- `⋀ᵢ (⊡αᵢ ∨ βᵢ)`: the `◁`-eliminated form of `sepForm L`. -/
def opastElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => ((PlusFormula.stab c.1).or c.2).and (opastElim L)

/-- Every clause of `L` is (past-determined, future-determined) at `F`. -/
def SepClauses (F : TaskFrame) (L : List (PlusFormula × PlusFormula)) : Prop :=
  ∀ c ∈ L, PastDet F c.1 ∧ FutDet F c.2

theorem ofutP_sepForm_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) : ∀ L : List (PlusFormula × PlusFormula), SepClauses F L →
      (OfutP M τ t (sepForm L) ↔ PlusTruthAt M τ t (ofutElim L))
  | [], _ => ⟨fun _ => PlusTruth.top_true M τ t, fun _ => ofutP_top M τ t⟩
  | c :: L, hL => by
    have hc : PastDet F c.1 ∧ FutDet F c.2 := hL c (List.mem_cons.mpr (Or.inl rfl))
    have hL' : SepClauses F L := fun d hd => hL d (List.mem_cons.mpr (Or.inr hd))
    show OfutP M τ t ((c.1.or c.2).and (sepForm L)) ↔
      PlusTruthAt M τ t ((c.1.or (.stab c.2)).and (ofutElim L))
    rw [ofutP_and, PlusTruth.and_iff, ofutP_or_iff M τ t hc.1 hc.2,
      ofutP_sepForm_iff M τ t L hL']

theorem opastP_sepForm_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) : ∀ L : List (PlusFormula × PlusFormula), SepClauses F L →
      (OpastP M τ t (sepForm L) ↔ PlusTruthAt M τ t (opastElim L))
  | [], _ => ⟨fun _ => PlusTruth.top_true M τ t, fun _ => opastP_top M τ t⟩
  | c :: L, hL => by
    have hc : PastDet F c.1 ∧ FutDet F c.2 := hL c (List.mem_cons.mpr (Or.inl rfl))
    have hL' : SepClauses F L := fun d hd => hL d (List.mem_cons.mpr (Or.inr hd))
    show OpastP M τ t ((c.1.or c.2).and (sepForm L)) ↔
      PlusTruthAt M τ t (((PlusFormula.stab c.1).or c.2).and (opastElim L))
    rw [opastP_and, PlusTruth.and_iff, opastP_or_iff M τ t hc.1 hc.2,
      opastP_sepForm_iff M τ t L hL']

/-! ## The translation, conditional on separation -/

/-- **The separation hypothesis over a frame predicate `P`**: every L⁺ formula has a separated
CNF equivalent to it on every regular frame satisfying `P`. For `P := TaskFrame.IsZTime` this is
Gabbay's Separation Theorem (GHR vol. 1, Thm 10.2.9) with `□ψ`/`⊡ψ` as leaves; for
`P := TaskFrame.IsRTime` its Dedekind-complete form (ibid., Thm 10.3.20). It is **false** at
`P := fun _ => True` (the Base class), because U/S is not separable over `ℚ`. -/
def SeparationOver (P : TaskFrame → Prop) : Prop :=
  ∀ φ : PlusFormula, ∃ L : List (PlusFormula × PlusFormula),
    ∀ (F : TaskFrame), F.IsRegular → P F → SepClauses F L ∧
      ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (sepForm L)

/-- The translation `L^▷ → L⁺`: homomorphic on the seven shared constructors, and at `▷φ`
(resp. `◁φ`) the `▷`- (resp. `◁`-) eliminated form of a separated CNF of `tr φ`. -/
noncomputable def tr {P : TaskFrame → Prop} (hsep : SeparationOver P) :
    OpenFormula → PlusFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (tr hsep φ) (tr hsep ψ)
  | .box φ => .box (tr hsep φ)
  | .untl ψ φ => .untl (tr hsep ψ) (tr hsep φ)
  | .snce ψ φ => .snce (tr hsep ψ) (tr hsep φ)
  | .stab φ => .stab (tr hsep φ)
  | .ofut φ => ofutElim (Classical.choose (hsep (tr hsep φ)))
  | .opast φ => opastElim (Classical.choose (hsep (tr hsep φ)))

/-- **The translation is truth-preserving** on every regular `P`-frame, at every model, world and
time. Induction on `φ` generalizing the world and the time, exactly as `openTruthAt_ofPlus`; the
two new cases are the CNF eliminations. -/
theorem openTruthAt_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    {F : TaskFrame} [hF : F.IsRegular] (hP : P F) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr hsep φ) := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | ofut φ ih =>
    obtain ⟨hcl, heq⟩ := Classical.choose_spec (hsep (tr hsep φ)) F hF hP
    exact (forall_congr' fun σ => imp_congr_right fun _ => (ih σ t).trans (heq M σ t)).trans
      (ofutP_sepForm_iff M τ t _ hcl)
  | opast φ ih =>
    obtain ⟨hcl, heq⟩ := Classical.choose_spec (hsep (tr hsep φ)) F hF hP
    exact (forall_congr' fun σ => imp_congr_right fun _ => (ih σ t).trans (heq M σ t)).trans
      (opastP_sepForm_iff M τ t _ hcl)

/-- Validity transfers along `tr` over the regular `P`-frames. -/
theorem openValidOnFrames_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    (φ : OpenFormula) :
    OpenValidOnFrames (fun F => F.IsRegular ∧ P F) φ ↔
      PlusValidOnFrames (fun F => F.IsRegular ∧ P F) (tr hsep φ) := by
  constructor
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_tr hsep hF.2 M τ t φ).mp (h F hF M τ t)
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_tr hsep hF.2 M τ t φ).mpr (h F hF M τ t)

/-- **At ZTime**: given separation over ℤ-time frames, L^▷-validity is L⁺-validity of the
translation. `FrameClass.Sat .ZTime F` is `F.IsRegular ∧ F.IsZTime` by definition. -/
theorem openValidIn_ztime_iff_tr (hsep : SeparationOver TaskFrame.IsZTime) (φ : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.ZTime φ ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (tr hsep φ) :=
  openValidOnFrames_iff_tr hsep φ

/-- **At RTime**: the same, given separation over the dense Dedekind-complete frames. -/
theorem openValidIn_rtime_iff_tr (hsep : SeparationOver TaskFrame.IsRTime) (φ : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.RTime φ ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (tr hsep φ) :=
  openValidOnFrames_iff_tr hsep φ

/-! ## A sanity instance: the two pure cases need no separation at all

`▷` of a pure-past formula is the formula, and `▷` of a pure-future formula is `⊡` of it — the
two ends of the elimination, on every regular frame. -/

theorem ofutP_of_pastDet [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α : PlusFormula} (hα : PastDet F α) : OfutP M τ t α ↔ PlusTruthAt M τ t α :=
  ⟨fun h => h τ ((agreeUpTo_equivalence t).refl τ), fun h σ hag => (hα M τ σ t hag).mp h⟩

theorem ofutP_of_futDet [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {β : PlusFormula} (hβ : FutDet F β) : OfutP M τ t β ↔ PlusTruthAt M τ t (.stab β) := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h σ hsame
    have hρτ : AgreeUpTo τ (paste τ σ t hsame) t :=
      (agreeUpTo_equivalence t).symm (paste_agreeUpTo τ σ t hsame)
    exact (hβ M _ σ t (paste_agreeFrom τ σ t hsame)).mp (h _ hρτ)
  · intro h σ hag
    exact h σ (hag t le_rfl)

end Probe854R01

#print axioms Probe854R01.ofutP_or_iff
#print axioms Probe854R01.opastP_or_iff
#print axioms Probe854R01.ofutP_sepForm_iff
#print axioms Probe854R01.opastP_sepForm_iff
#print axioms Probe854R01.openTruthAt_iff_tr
#print axioms Probe854R01.openValidIn_ztime_iff_tr
#print axioms Probe854R01.openValidIn_rtime_iff_tr
#print axioms Probe854R01.ofutP_of_futDet
