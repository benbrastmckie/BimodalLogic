import FormalSystem.Metalogic.WeakCanonical.Kamp.ESigmaCapture

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Option B locality-ceiling probe — OFF-PATH RED decision gate (architecture spike A vs B)

**Purpose.** This module is the machine-checked evidence for the **Option B** verdict in the
A-vs-B architecture spike (report `19_architecture-spike-A-vs-B.md`). Option B proposes to replace
the syntactic `A ∈ F` capture (`esigmaCapture_canonExpand`, `ESigmaCapture.lean:207`) with a
**semantic** capture: a total `capFn : Formula → IntervalType sig F` discharging the ζ consumer
obligation

```
∀ (A : Formula) (y : N.carrier), intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A
```

(`ZetaUniformExtract.lean:124-129`) directly for the readback formulas `(translateProp35 … ξ).neg`,
bypassing `∈ F`.

**Verdict: RED — the semantic capture is IMPOSSIBLE for genuine-temporal-reach readbacks under the
current `IntervalType`.** The obstruction is definitional, not a proof gap:

`IntervalType sig F := Finset (UnaryType sig F)` and
`intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` (`ExistsForallFormula.lean:87-95`). Because
`unaryHolds N τ y` is atom-wise agreement at the *single* point `y` (`unaryHolds_iff`), the value
of `intervalHolds N S y` is a function of the E[Σ]-1-type of `y` **alone** — it is a union of
complete-1-type cells (Rabinovich's local, quantifier-free unary types, Def 3.1 p.4). The three
lemmas below machine-check that ceiling and its consequence:

- `unaryHolds_local` / `intervalHolds_local`: `intervalHolds` cannot distinguish two points that
  share the same E[Σ]-1-type.
- `capFn_forces_local`: therefore ANY `IntervalType` capturing a formula `A` forces
  `temporal_truth · A` to be 1-type-local. Contrapositive: a readback whose truth distinguishes two
  1-type-equal points (an `Until`/`Since` chain with genuine temporal reach — provably NOT a
  subformula of the input, `ZetaEngineClosure.lean:49`) is **not capturable by any `IntervalType
  sig F`, for any `F`.** This is the "report R1" wall (`ESigmaCapture.lean:203-205`) as a theorem.

**Consequence for the spike.** Option B does not preserve the finite spine "for free": to capture a
temporal-reach readback it must change `IntervalType` itself to carry order/temporal structure —
which is the same infinite/temporal machinery Option A introduces, i.e. novel machinery, a NO-GO
under the exact-faithfulness / no-novel-math binding. Nothing here is imported by `KampPrior.lean`
or the completeness spine; it is a pure off-path probe. `KampPrior.lean:562` is untouched.

## References
- `ExistsForallFormula.lean:57,87,93` (`UnaryType`, `IntervalType`, `intervalHolds`, `unaryHolds`).
- `ESigmaCapture.lean:81-114` (`intervalCapture_of_atomNamed`: capture REQUIRES `∈ F` naming),
  `:203-205` (R1 note).
- `ZetaReadbackClosure.lean:178` (`not_readbackClosed`: the syntactic `∈ F` escape is unbounded).
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Def 4.1 + collapse note (p.5-6).
  Cited by PDF page; the companion markdown transcription is corrupt.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-- **1-type locality of `unaryHolds`.** A complete unary type is realized identically at two points
that agree on every E[Σ] atom (over `Fin 1` these are exactly the predicate atoms at the point). -/
theorem unaryHolds_local
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryType sig F) (y1 y2 : N.carrier)
    (hagree : ∀ a : AtomKind (sigE sig F) 1,
        atom_eval N (fun _ => y1) a ↔ atom_eval N (fun _ => y2) a) :
    unaryHolds N τ y1 ↔ unaryHolds N τ y2 := by
  rw [unaryHolds_iff, unaryHolds_iff]
  constructor
  · intro h a; rw [← hagree a]; exact h a
  · intro h a; rw [hagree a]; exact h a

/-- **The ceiling.** `intervalHolds N S y` factors through the E[Σ]-1-type of `y`: two points with
the same 1-type are indistinguishable by every `IntervalType`. An `IntervalType` is therefore a
union of complete-1-type cells and can only express point-local truth sets. -/
theorem intervalHolds_local
    (N : OrderedMonadicStructure (sigE sig F)) (S : IntervalType sig F) (y1 y2 : N.carrier)
    (hagree : ∀ a : AtomKind (sigE sig F) 1,
        atom_eval N (fun _ => y1) a ↔ atom_eval N (fun _ => y2) a) :
    intervalHolds N S y1 ↔ intervalHolds N S y2 := by
  unfold intervalHolds
  constructor
  · rintro ⟨τ, hτ, hu⟩; exact ⟨τ, hτ, (unaryHolds_local N τ y1 y2 hagree).mp hu⟩
  · rintro ⟨τ, hτ, hu⟩; exact ⟨τ, hτ, (unaryHolds_local N τ y1 y2 hagree).mpr hu⟩

/-- **Option B NO-GO, made precise (the RED core).** If a semantic `capFn` value `S` discharges the
ζ consumer obligation for a formula `A` (`intervalHolds N S y ↔ temporal_truth N atomMap y A` for
all `y`), then `temporal_truth · A` is forced 1-type-local. Contrapositive: any `A` whose truth
distinguishes two E[Σ]-1-type-equal points — every genuine-temporal-reach `Until`/`Since` readback —
is capturable by NO `IntervalType sig F`, independent of `F`. The semantic capture Option B needs is
thus not merely unproven but false under the current `IntervalType`; discharging it requires
redesigning `IntervalType` to carry temporal structure (novel machinery). -/
theorem capFn_forces_local
    (N : OrderedMonadicStructure (sigE sig F)) (atomMap : Formula → (sigE sig F).preds)
    (A : Formula) (S : IntervalType sig F)
    (hCap : ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (y1 y2 : N.carrier)
    (hagree : ∀ a : AtomKind (sigE sig F) 1,
        atom_eval N (fun _ => y1) a ↔ atom_eval N (fun _ => y2) a) :
    temporal_truth N atomMap y1 A ↔ temporal_truth N atomMap y2 A := by
  rw [← hCap y1, ← hCap y2]
  exact intervalHolds_local N S y1 y2 hagree

end Bimodal.Metalogic.WeakCanonical.Kamp
