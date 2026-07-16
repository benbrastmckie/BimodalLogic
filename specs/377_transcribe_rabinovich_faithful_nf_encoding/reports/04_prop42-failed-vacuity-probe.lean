import Bimodal.Metalogic.WeakCanonical.Kamp.Section5Correspondence

/-!
# Failed-vacuity probe for `prop42_contentful_of_attained` (Rabinovich 2014, Prop 4.2, PDF p.6)

Per the extended non-vacuity rule: an over-strong hypothesis passes sorry-free, axiom-clean, and
EXIT 0 exactly as a vacuous conclusion does, so `prop42_contentful_of_attained` being green is
**not** evidence that it says anything. This probe pins the boundary by exhibiting the exact
escape hatch that discharges the vacuous shape and showing it is closed against the contentful
one.

* `prop42_vacuous_shape_control` — the vacuous shape `∀ z₀ z₁, ∃ v', v'.holds z₀ z₁`
  **COMPILES** from no hypotheses at all, for every `v`, via the all-`⊤` block. This is
  `prop42_conclusion_is_vacuous` (`Prop42Vacuity.lean`) in miniature: the shape is a free pass.

* `prop42_topVVec_refutation` — the *same* all-`⊤` term offered against `Prop42Contentful`
  **DOES NOT COMPILE**. Uncomment it to reproduce. `Prop42Contentful` hoists `∃ v'` outside
  `∀ z₀ z₁` and demands a **biconditional**, so a proof that `topVVec` merely *holds* is not of
  the required type. The `⊤` block holds everywhere, so it can never fail wherever `v` holds —
  which is what the `←` direction demands.

Recorded **verbatim** failure for the all-`⊤` witness (Lean v4.27.0-rc1, exit 1):

```
error: Type mismatch
  topVVec_holds M atomMap z0 z1
has type
  VVecEA2.holds M atomMap topVVec z0 z1
but is expected to have type
  VVecEA2.holds M atomMap topVVec z0 z1 ↔ ¬VVecEA2.holds M atomMap v z0 z1
```

The type mismatch **is** the finding, not noise: it is precisely the gap between "some block
holds here" (vacuous, free) and "this block is equivalent to the negation of `v`, uniformly"
(contentful, and what Section 5 exists to supply). The positive half of the same fact is
compiler-checked in the tree by `topVVec_contentful_forces_unsat` (`Prop42Contentful.lean:217`):
offering `topVVec` does not discharge `Prop42Contentful`, it *commits* the offerer to `v` being
unsatisfiable on every ordered pair.

**What this probe does NOT establish.** It shows the *shape* is non-vacuous. It says nothing
about the *carrier*. `prop42_contentful_of_attained` assumes `HasAttainedINF`/`HasAttainedSUP`,
which is strictly stronger than Rabinovich's Dedekind completeness — strictly stronger even than
`HasDefinableINF`, which `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) machine-refutes as
too strong. Carrier exclusion is documented in `Section5Correspondence.lean`'s module docstring
and is a separate obligation from this probe.

This file is a probe artifact, not a library module: it is not imported from `Theories/Bimodal.lean`
and is not built by `lake build`. Reproduce with `lake env lean <this file>`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **CONTROL — compiles.** The vacuous shape is discharged from no hypotheses, for every `v`,
    by the all-`⊤` block. This is why the shape is rejected as Proposition 4.2. -/
theorem prop42_vacuous_shape_control {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (_v : VVecEA2) :
    ∀ z0 z1 : M.carrier, z0 < z1 → ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 :=
  fun z0 z1 _ => ⟨topVVec, topVVec_holds M atomMap z0 z1⟩

-- **REFUTATION — does NOT compile.** The same all-`⊤` witness, offered against
-- `Prop42Contentful`. Uncomment to reproduce the verbatim error recorded in the module
-- docstring above.
--
-- theorem prop42_topVVec_refutation {sig : MonadicSignature}
--     (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
--     (v : VVecEA2) :
--     Prop42Contentful M atomMap v :=
--   ⟨topVVec, fun z0 z1 _ => topVVec_holds M atomMap z0 z1⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
