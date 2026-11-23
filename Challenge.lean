import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.Metalogic.Conservativity.Star.StarSoundness

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.StarLanguage FormalSystem.Semantics FormalSystem.Metalogic

universe u

class PointedSound (L : Type) [TruthEnv L] (D : FrameClass → List L → L → Sort u) : Prop where
  sound : ∀ {fc : FrameClass} {Γ : List L} {φ : L}, D fc Γ φ →
    ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
      (e : TruthEnv.Env L F), (∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) → TruthEnv.T M τ t e φ

theorem star_soundness_in {fc : FrameClass} (Γ : StarContext) (φ : StarFormula)
    (d : StarDerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (v : ℕ → F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, StarTruthAt M τ t v ψ) :
    StarTruthAt M τ t v φ := sorry


theorem truth_of_derivation {L : Type} [TruthEnv L] {D : FrameClass → List L → L → Sort u}
    [PointedSound L D] {fc : FrameClass} {Γ : List L} {φ : L} (d : D fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (e : TruthEnv.Env L F) (h : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ := sorry

