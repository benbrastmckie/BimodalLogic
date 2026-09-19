import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.PlusLanguage.PlusPasting

/-!
# Probe 01 (research for the Base incompleteness theorem): Base validity of `blc`, LIVE semantics

Compiled against the repository's own `PlusTruthAt`, `WorldHistory`, `PartialHistory`,
`PartialHistory.extension` and `paste` (NOT the integer-time mirror of the earlier probes).
Sorry-free. Compile: bare `lean` with `LEAN_PATH` = `.lake/build/lib/lean` plus every
`.lake/packages/*/.lake/build/lib/lean` (no `lake` process). Not part of any Lake library.
Axioms of `blc_plusValid`: `propext`, `Classical.choice`, `Quot.sound`.
-/

namespace Probe560
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics FormalSystem.Semantics.PartialHistory
open PlusTruth

variable {F : TaskFrame}

/-- General lemma: a chain-closed property of partial histories has maximal members above any
member, and each extends to a world history. -/
theorem exists_maximal_of_chainClosed (Q : PartialHistory F → Prop)
    (hQ : ∀ (c : Set (PartialHistory F)) (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty),
      (∀ μ ∈ c, Q μ) → Q (chainSup c hc hne))
    {μ₀ : PartialHistory F} (h₀ : Q μ₀) :
    ∃ μ, μ₀ ≤ μ ∧ Q μ ∧ (∀ ν, Q ν → μ ≤ ν → ν ≤ μ) ∧
      ∃ τ : WorldHistory F, Extends τ.val μ := by
  obtain ⟨m, hle, hmax⟩ := zorn_le_nonempty₀ {μ | Q μ}
    (fun c hcs hc y hy => ⟨chainSup c hc ⟨y, hy⟩, hQ c hc ⟨y, hy⟩ hcs,
      fun z hz => le_chainSup hc ⟨y, hy⟩ hz⟩) μ₀ h₀
  obtain ⟨τ, hτ⟩ := extension F m
  exact ⟨m, hle, hmax.1, fun ν hν h => hmax.2 hν h, τ, hτ⟩

/-- Restriction of a world history to `(-∞, s]`. -/
def restrictIic (τ : WorldHistory F) (s : F.Duration) : PartialHistory F where
  domain x := x ≤ s
  nonempty_domain := ⟨s, le_rfl⟩
  states x _ := τ.state x
  respects_task a b _ _ := τ.respects_task a b

structure LCProp (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (μ : PartialHistory F) : Prop where
  down : ∀ x y, μ.domain x → y ≤ x → μ.domain y
  anchor : ∃ ht : μ.domain t, μ.states t ht = w
  some_p : ∃ s, t < s ∧ ∃ hs : μ.domain s, P (μ.states s hs)
  recur : ∀ x, t < x → ∀ hx : μ.domain x, P (μ.states x hx) →
      (∃ y, x < y ∧ ∃ hy : μ.domain y, P (μ.states y hy)) ∨ (∀ y, μ.domain y → y ≤ x)

theorem lcProp_restrictIic (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (τ : WorldHistory F) (hw : τ.state t = w) (s : F.Duration) (hts : t < s) (hp : P (τ.state s)) :
    LCProp P t w (restrictIic τ s) where
  down := fun x y hx hy => le_trans hy hx
  anchor := ⟨le_of_lt hts, hw⟩
  some_p := ⟨s, hts, le_rfl, hp⟩
  recur := by
    intro x _ hx _
    rcases lt_or_eq_of_le (show x ≤ s from hx) with h | h
    · exact Or.inl ⟨s, h, le_rfl, hp⟩
    · exact Or.inr fun y hy => h ▸ (show y ≤ s from hy)

theorem lcProp_chainSup (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (c : Set (PartialHistory F)) (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty)
    (hall : ∀ μ ∈ c, LCProp P t w μ) : LCProp P t w (chainSup c hc hne) := by
  have agree : ∀ {ν} (hν : ν ∈ c) (x) (hx : ν.domain x),
      (chainSup c hc hne).states x ⟨ν, hν, hx⟩ = ν.states x hx :=
    fun hν x hx => (le_def.mp (le_chainSup hc hne hν)).agree x hx
  refine ⟨?_, ?_, ?_, ?_⟩
  · rintro x y ⟨ν, hν, hx⟩ hy
    exact ⟨ν, hν, (hall ν hν).down x y hx hy⟩
  · obtain ⟨ν, hν⟩ := hne
    obtain ⟨ht, e⟩ := (hall ν hν).anchor
    exact ⟨⟨ν, hν, ht⟩, (agree hν t ht).trans e⟩
  · obtain ⟨ν, hν⟩ := hne
    obtain ⟨s, hts, hs, hp⟩ := (hall ν hν).some_p
    exact ⟨s, hts, ⟨ν, hν, hs⟩, by rw [agree hν s hs]; exact hp⟩
  · rintro x htx ⟨ν, hν, hxν⟩ hp
    rw [agree hν x hxν] at hp
    rcases (hall ν hν).recur x htx hxν hp with ⟨y, hxy, hy, hpy⟩ | hmax
    · exact Or.inl ⟨y, hxy, ⟨ν, hν, hy⟩, by rw [agree hν y hy]; exact hpy⟩
    · by_cases hU : ∀ y, (chainSup c hc hne).domain y → y ≤ x
      · exact Or.inr hU
      · push Not at hU
        obtain ⟨y, ⟨ν', hν', hy'⟩, hxy⟩ := hU
        rcases hc.total hν hν' with h | h
        · have hx' : ν'.domain x := (le_def.mp h).subset x hxν
          have hp' : P (ν'.states x hx') := by rw [(le_def.mp h).agree x hxν]; exact hp
          rcases (hall ν' hν').recur x htx hx' hp' with ⟨z, hxz, hz, hpz⟩ | hmax'
          · exact Or.inl ⟨z, hxz, ⟨ν', hν', hz⟩, by rw [agree hν' z hz]; exact hpz⟩
          · exact absurd (hmax' y hy') (not_le.mpr hxy)
        · exact absurd (hmax y ((le_def.mp h).subset y hy')) (not_le.mpr hxy)

/-- The X-free limit-closure lemma at every temporal order. -/
theorem limit_history (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (h1 : ∃ τ₀ : WorldHistory F, τ₀.state t = w ∧ ∃ s, t < s ∧ P (τ₀.state s))
    (h2 : ∀ ρ : WorldHistory F, ρ.state t = w → ∀ s, t < s → P (ρ.state s) →
        ∃ η : WorldHistory F, η.state s = ρ.state s ∧ ∃ s', s < s' ∧ P (η.state s')) :
    ∃ τ : WorldHistory F, τ.state t = w ∧ (∃ s, t < s ∧ P (τ.state s)) ∧
      ∀ s, t < s → P (τ.state s) → ∃ s', s < s' ∧ P (τ.state s') := by
  obtain ⟨τ₀, hw₀, s₀, hs₀, hp₀⟩ := h1
  obtain ⟨μ, _, hQ, hmax, τ, hτ⟩ := exists_maximal_of_chainClosed (LCProp P t w)
    (lcProp_chainSup P t w) (lcProp_restrictIic P t w τ₀ hw₀ s₀ hs₀ hp₀)
  have agree : ∀ x (hx : μ.domain x), τ.state x = μ.states x hx := fun x hx => hτ.agree x hx
  obtain ⟨ht, hw⟩ := hQ.anchor
  have hτw : τ.state t = w := (agree t ht).trans hw
  refine ⟨τ, hτw, ?_, ?_⟩
  · obtain ⟨s, hts, hs, hp⟩ := hQ.some_p
    exact ⟨s, hts, by rw [agree s hs]; exact hp⟩
  · intro f htf hpf
    by_contra hno
    push Not at hno
    have hdom : ∀ y, μ.domain y → y ≤ f := by
      intro y hy
      by_contra hfy
      have hfy := not_le.mp hfy
      have hf : μ.domain f := hQ.down y f hy hfy.le
      rcases hQ.recur f htf hf (by rw [← agree f hf]; exact hpf) with ⟨z, hfz, hz, hpz⟩ | hm
      · exact hno z hfz (by rw [agree z hz]; exact hpz)
      · exact absurd (hm y hy) (not_le.mpr hfy)
    obtain ⟨η, hη, s', hfs', hps'⟩ := h2 τ hτw f htf hpf
    have hsame : τ.state f = η.state f := hη.symm
    have hπ' : (paste τ η f hsame).state s' = η.state s' :=
      paste_agreeFrom τ η f hsame s' hfs'.le
    have hν : LCProp P t w (restrictIic (paste τ η f hsame) s') :=
      lcProp_restrictIic P t w _ ((paste_agreeUpTo τ η f hsame t htf.le).trans hτw) s'
        (htf.trans hfs') (by rw [hπ']; exact hps')
    have hle : μ ≤ restrictIic (paste τ η f hsame) s' :=
      le_def.mpr ⟨fun y hy => le_trans (hdom y hy) hfs'.le, fun y hy =>
        (paste_agreeUpTo τ η f hsame y (hdom y hy)).trans (agree y hy)⟩
    have := (le_def.mp (hmax _ hν hle)).subset s' (le_refl s')
    exact absurd (hdom s' this) (not_le.mpr hfs')

def blc (p : Atom) : PlusFormula :=
  ((dstab (someFuture (.atom p))).and
      (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))).imp
    (dstab ((someFuture (.atom p)).and
      (allFuture ((PlusFormula.atom p).imp (someFuture (.atom p))))))

theorem blc_plusValid (p : Atom) : PlusValid (blc p) := by
  refine PlusValid.of_forall fun F M σ t => ?_
  intro h
  rw [and_iff] at h
  obtain ⟨hA, hB⟩ := h
  rw [dstab_iff] at hA
  obtain ⟨τ₀, he₀, hF₀⟩ := hA
  rw [someFuture_iff] at hF₀
  obtain ⟨s₀, hs₀, hp₀⟩ := hF₀
  obtain ⟨τ, hτ, ⟨s, hs, hp⟩, hrec⟩ := limit_history (fun u => M.valuation u p) t (σ.state t)
    ⟨τ₀, he₀.symm, s₀, hs₀, hp₀⟩
    (fun ρ hρ s hs hps => by
      have := hB ρ hρ.symm
      rw [allFuture_iff] at this
      have := this s hs hps
      rw [dstab_iff] at this
      obtain ⟨η, heη, hFη⟩ := this
      rw [someFuture_iff] at hFη
      obtain ⟨s', hs', hp'⟩ := hFη
      exact ⟨η, heη.symm, s', hs', hp'⟩)
  rw [dstab_iff]
  refine ⟨τ, hτ.symm, ?_⟩
  rw [and_iff]
  refine ⟨(someFuture_iff M τ t _).mpr ⟨s, hs, hp⟩, ?_⟩
  rw [allFuture_iff]
  intro x hx hpx
  obtain ⟨s', hs', hp'⟩ := hrec x hx hpx
  exact (someFuture_iff M τ x _).mpr ⟨s', hs', hp'⟩

#print axioms blc_plusValid
end Probe560
