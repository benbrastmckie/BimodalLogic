/- Scratch: do the PR's generic derived operators coincide with the per-language ones, and do the
   generic lemmas reach the per-language named operators without massaging? -/
import FormalSystem.Semantics.TemporalRules
import FormalSystem.Semantics.TemporalIntervals
import FormalSystem.SourceLanguage.SentenceTruth
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.StarLanguage.StarTruth
import FormalSystem.MinusLanguage.MinusTruth

namespace Scratch4

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Semantics.TemporalRules FormalSystem.Semantics.TemporalIntervals

/-! ## A. Definitional-coincidence rows of the kind ValidityLayerTest.lean keeps. -/

example (φ : Formula) : Formula.next φ = TemporalRules.next φ := rfl
example (φ : Formula) : Formula.prev φ = TemporalRules.prev φ := rfl
example (φ : PlusLanguage.PlusFormula) :
    PlusLanguage.PlusFormula.next φ = TemporalRules.next φ := rfl
example (φ : PlusLanguage.PlusFormula) :
    PlusLanguage.PlusFormula.prev φ = TemporalRules.prev φ := rfl
example (φ : StarLanguage.StarFormula) :
    StarLanguage.StarFormula.next φ = TemporalRules.next φ := rfl
example (φ : StarLanguage.StarFormula) :
    StarLanguage.StarFormula.prev φ = TemporalRules.prev φ := rfl

/-! ## B. Does the generic `next_iff` reach `Formula.next` / `SentenceTruth.next_iff_covBy`? -/

example {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ ∃ s : F.Duration, t ⋖ s ∧ TruthAt M τ s φ :=
  next_iff (L := Formula) M τ t PUnit.unit φ

/-! ## C. Does the generic `release_iff` reach the existing `Formula.release`? -/

example {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (event guard : Formula) :
    TruthAt M τ t (Formula.release event guard) ↔
      ¬ ∃ s, t < s ∧ ¬ TruthAt M τ s event ∧
        ∀ r, t < r → r < s → ¬ TruthAt M τ r guard :=
  release_iff (L := Formula) M τ t PUnit.unit event guard

/-! ## D. And the existing `Formula.weakUntil`? -/

example {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (event guard : Formula) :
    TruthAt M τ t (Formula.weakUntil event guard) ↔
      (∃ s, t < s ∧ TruthAt M τ s event ∧ ∀ r, t < r → r < s → TruthAt M τ r guard) ∨
      ∀ s, t < s → TruthAt M τ s guard :=
  weakUntil_iff (L := Formula) M τ t PUnit.unit event guard

end Scratch4
