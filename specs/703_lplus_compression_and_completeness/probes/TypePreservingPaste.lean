import FormalSystem

/-!
Probe (research round 2): **type-preserving pasting**.

Two histories that share a state at `t` *and* agree at `t` on every formula of a
subformula-closed set `C` can be pasted there, and the pasted history carries the first
history's `C`-type at every time `≤ t` and the second's at every time `≥ t`.

No frame-class assumption, no discreteness, no bound: the statement is about any history `π`
agreeing with `ρ` up to `t` and with `σ` from `t` on. `PlusLanguage.paste` supplies such a `π` on
every regular frame.
-/

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusTruth

namespace Probe703Paste

variable {F : TaskFrame}

theorem truth_of_agree_of_type_eq (M : TaskModel F) (π ρ σ : WorldHistory F) (t : F.Duration)
    (hup : AgreeUpTo π ρ t) (hfrom : AgreeFrom π σ t)
    (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (htype : ∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ PlusTruthAt M σ t ψ)) :
    ∀ ψ ∈ C, (∀ s, s ≤ t → (PlusTruthAt M π s ψ ↔ PlusTruthAt M ρ s ψ)) ∧
      (∀ s, t ≤ s → (PlusTruthAt M π s ψ ↔ PlusTruthAt M σ s ψ)) := by
  intro ψ
  induction ψ with
  | atom p =>
    intro _
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · change M.valuation _ p ↔ M.valuation _ p
      rw [hup s hs]
    · change M.valuation _ p ↔ M.valuation _ p
      rw [hfrom s hs]
  | bot => intro _; exact ⟨fun _ _ => Iff.rfl, fun _ _ => Iff.rfl⟩
  | imp a b iha ihb =>
    intro h
    obtain ⟨ha, hb⟩ := himp a b h
    exact ⟨fun s hs => Iff.imp ((iha ha).1 s hs) ((ihb hb).1 s hs),
      fun s hs => Iff.imp ((iha ha).2 s hs) ((ihb hb).2 s hs)⟩
  | box a _ => intro _; exact ⟨fun _ _ => Iff.rfl, fun _ _ => Iff.rfl⟩
  | stab a _ =>
    intro _
    exact ⟨fun s hs => stab_congr_state M π ρ s (hup s hs) a,
      fun s hs => stab_congr_state M π σ s (hfrom s hs) a⟩
  | untl g e ihg ihe =>
    intro h
    obtain ⟨hg, he⟩ := huntl g e h
    have Eg := ihg hg
    have Ee := ihe he
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · constructor
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : s' ≤ t
        · exact ⟨s', h1, (Ee.1 s' hs').mp hev, fun r hr1 hr2 =>
            (Eg.1 r (le_trans hr2.le hs')).mp (hgd r hr1 hr2)⟩
        · have hts' : t < s' := not_le.mp hs'
          have hσ : PlusTruthAt M σ t (.untl g e) :=
            ⟨s', hts', (Ee.2 s' hts'.le).mp hev, fun r hr1 hr2 =>
              (Eg.2 r hr1.le).mp (hgd r (lt_of_le_of_lt hs hr1) hr2)⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mpr hσ
          refine ⟨s'', lt_of_le_of_lt hs h1'', hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : r ≤ t
          · exact (Eg.1 r hr).mp (hgd r hr1 (lt_of_le_of_lt hr hts'))
          · exact hgd'' r (not_le.mp hr) hr2
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : s' ≤ t
        · exact ⟨s', h1, (Ee.1 s' hs').mpr hev, fun r hr1 hr2 =>
            (Eg.1 r (le_trans hr2.le hs')).mpr (hgd r hr1 hr2)⟩
        · have hts' : t < s' := not_le.mp hs'
          have hρ : PlusTruthAt M ρ t (.untl g e) :=
            ⟨s', hts', hev, fun r hr1 hr2 => hgd r (lt_of_le_of_lt hs hr1) hr2⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mp hρ
          refine ⟨s'', lt_of_le_of_lt hs h1'', (Ee.2 s'' h1''.le).mpr hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : r ≤ t
          · exact (Eg.1 r hr).mpr (hgd r hr1 (lt_of_le_of_lt hr hts'))
          · exact (Eg.2 r (not_le.mp hr).le).mpr (hgd'' r (not_le.mp hr) hr2)
    · exact exists_congr fun s' => and_congr_right fun h1 =>
        and_congr (Ee.2 s' (le_trans hs h1.le))
          (forall_congr' fun r => imp_congr_right fun hr1 => imp_congr_right fun _ =>
            Eg.2 r (le_trans hs hr1.le))
  | snce g e ihg ihe =>
    intro h
    obtain ⟨hg, he⟩ := hsnce g e h
    have Eg := ihg hg
    have Ee := ihe he
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · exact exists_congr fun s' => and_congr_right fun h1 =>
        and_congr (Ee.1 s' (le_trans h1.le hs))
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hr2 =>
            Eg.1 r (le_trans hr2.le hs))
    · constructor
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : t ≤ s'
        · exact ⟨s', h1, (Ee.2 s' hs').mp hev, fun r hr1 hr2 =>
            (Eg.2 r (le_trans hs' hr1.le)).mp (hgd r hr1 hr2)⟩
        · have hts' : s' < t := not_le.mp hs'
          have hρ : PlusTruthAt M ρ t (.snce g e) :=
            ⟨s', hts', (Ee.1 s' hts'.le).mp hev, fun r hr1 hr2 =>
              (Eg.1 r hr2.le).mp (hgd r hr1 (lt_of_lt_of_le hr2 hs))⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mp hρ
          refine ⟨s'', lt_of_lt_of_le h1'' hs, hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : t ≤ r
          · exact (Eg.2 r hr).mp (hgd r (lt_of_lt_of_le hts' hr) hr2)
          · exact hgd'' r hr1 (not_le.mp hr)
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : t ≤ s'
        · exact ⟨s', h1, (Ee.2 s' hs').mpr hev, fun r hr1 hr2 =>
            (Eg.2 r (le_trans hs' hr1.le)).mpr (hgd r hr1 hr2)⟩
        · have hts' : s' < t := not_le.mp hs'
          have hσ : PlusTruthAt M σ t (.snce g e) :=
            ⟨s', hts', hev, fun r hr1 hr2 => hgd r hr1 (lt_of_lt_of_le hr2 hs)⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mpr hσ
          refine ⟨s'', lt_of_lt_of_le h1'' hs, (Ee.1 s'' h1''.le).mpr hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : t ≤ r
          · exact (Eg.2 r hr).mpr (hgd r (lt_of_lt_of_le hts' hr) hr2)
          · exact (Eg.1 r (not_le.mp hr).le).mpr (hgd'' r hr1 (not_le.mp hr))

/-- The same fact at the landed `paste`: on a regular frame, histories sharing a state and a
`C`-type at `t` paste to a history carrying both type rows. -/
theorem truth_paste_of_type_eq [F.IsRegular] (M : TaskModel F) (ρ σ : WorldHistory F)
    (t : F.Duration) (hsame : ρ.state t = σ.state t) (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (htype : ∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ PlusTruthAt M σ t ψ)) :
    ∀ ψ ∈ C, (∀ s, s ≤ t →
        (PlusTruthAt M (paste ρ σ t hsame) s ψ ↔ PlusTruthAt M ρ s ψ)) ∧
      (∀ s, t ≤ s → (PlusTruthAt M (paste ρ σ t hsame) s ψ ↔ PlusTruthAt M σ s ψ)) :=
  truth_of_agree_of_type_eq M _ ρ σ t (paste_agreeUpTo ρ σ t hsame) (paste_agreeFrom ρ σ t hsame)
    C himp huntl hsnce htype

#print axioms truth_paste_of_type_eq

end Probe703Paste
