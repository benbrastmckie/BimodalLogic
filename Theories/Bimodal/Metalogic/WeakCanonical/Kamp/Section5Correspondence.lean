/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.Prop42Contentful
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.VecEANegFix

/-!
# Section 5 correspondence guard: what is already transcribed, and at which carrier

**Read this before planning any Section 5 work.** Rabinovich's Section 5 (2014, *A Proof of
Kamp's Theorem*, PDF pp.7-11) is **already transcribed in this tree**, in the
`EANegationFix/` directory, under names that do not mention Rabinovich, sections, or lemma
numbers. It was discoverable by `grep` for thirteen months and was nonetheless re-planned from
scratch by successive agents, one of which marked six of these rows ABSENT in a research report
while every one of them was present and sorry-free. This module exists so that the next reader
finds the correspondence instead of re-deriving it, and it is CI-protected: it is reachable from
`Theories/Bimodal.lean`, so the table below cannot rot without breaking the build.

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
The companion `.md` conversion is **corrupt** — it drops displayed equations and inverts `k ≠ m`
to `k = m`. Existing `chunk_00NN`-style citations (`OnBuilder.lean:47`, `NegFix.lean:12`) point
into that corrupt conversion and should be re-cited by page as they are touched.

## The correspondence table

| Rabinovich (PDF page) | In-tree name | Location |
|---|---|---|
| Lemma 5.3 — `Oₙ` induction, all `βᵢ` = True (p.8) | `negChainOn_iff` |
`EANegationFix/OnBuilder.lean:159` |
| Lemma 5.1 — bracket negation recursion (pp.9-10) | `BracketFormula.negFix_iff` |
`EANegationFix/NegFix.lean:669` |
| Cor 5.4 — `Fₙ := αₙ`, `F₍ᵢ₋₁₎ := α₍ᵢ₋₁₎ ∧ (βᵢ Until Fᵢ)` (p.9) | `negBoundedRightFix_iff` |
`EANegationFix/BoundedFix.lean:449` |
| Cor 5.4 — the Since mirror (p.9) | `negBoundedLeftFix_iff` | `EANegationFix/BoundedFix.lean:768` |
| `Aᵢ`/`Bᵢ` split + closing induction (pp.10-11) | `negFixList` via `concatPin` + pinned `conjFull`
| `EANegationFix/NegFix.lean:424` |
| Prop 4.2 / 4.3 De Morgan fold (p.6) | `VVecEA2.negFix_iff` | `EANegationFix/VecEANegFix.lean:164`
|

Every entry above is landed and sorry-free. `prop42_contentful_of_attained` below is what those
entries compose to: the contentful Proposition 4.2 target stated in `Prop42Contentful.lean`,
discharged by **wiring**, not by new transcription.

## What the carrier EXCLUDES — read this before citing the theorem below

The extended non-vacuity rule: *every phase that assumes a carrier must state what that carrier
excludes.* An over-strong hypothesis passes sorry-free, axiom-clean, and EXIT 0 exactly as a
vacuous conclusion does — which is why this pattern recurred three times in this development
undetected.

`prop42_contentful_of_attained` is Proposition 4.2 **restricted to attained structures**. It is
**not** Rabinovich's Proposition 4.2, which is claimed over *all* Dedekind complete chains. The
strengthening chain, weakest to strongest:

```
Rabinovich's Dedekind completeness  <  HasDedekindINF (faithful)  <  HasDefinableINF  <
HasAttainedINF
                                                                                         ^ what is
                                                                                         landed
```

Two in-tree, machine-checked facts pin this down:

* `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`, axiom-clean) proves the **weaker**
  `HasDefinableINF` is *already* too strong: it makes the paper's disjunct (2)
  `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` (p.8) unreachable whenever `P₁` occurs in `(z₀,z₁)`. Since
  `HasAttainedINF.toHasDefinableINF` (`PriorINF.lean:215`) shows `HasAttainedINF` implies
  `HasDefinableINF`, `HasAttainedINF` is *a fortiori* too strong.
* `OnBuilder.lean:27-33` admits the deviation in its own docstring: "On Prior structures the INF
  is always attained (`HasAttainedINF`), so the K⁺ disjunct is vacuous". The whole
  `EANegationFix/` development is built on that simplification. It is sound on Prior structures
  (`prior_hasAttainedINF`, `PriorINF.lean:224`) and is the right thing at the live-path
  boundary — but it is a **deviation from the paper**, not a transcription of it.

Concretely, `HasAttainedINF` excludes structures where an infimum exists but is not attained:
on `ℝ` with `P₁` interpreted as `{x | x > 0}` and `z₀ = 0`, `inf{z ∈ (0,1) | P₁(z)} = 0 = z₀`,
so no `r₀ > z₀` has `¬P₁` below it. `ℝ` **is** Dedekind complete, and the paper handles it via
disjunct (2). So the theorem below does not cover a structure the paper explicitly covers.
Building the faithful carrier is separately owned (see `lemma53`'s docstring, `Lemma53.lean`).

**Standing prohibition.** `BracketFormula.negFix_iff` (`NegFix.lean:669`) is **INF-anchored** —
it assumes `HasAttainedINF`/`HasAttainedSUP`. It is therefore **not** a refutation of the ruling
that the model-*independent* Prop 4.2 backward direction is unfixable at the `BracketFormula`
level (`Boneyard/NegationIndep.lean:346-364`, and the concurring independent analysis). It
**confirms** that ruling's diagnosis: the anchors are what make the direction go through. Neither
this module nor the theorem below is license for a further bare attempt.

## Non-vacuity is compiler-checked

`Prop42Contentful` hoists `∃ v'` outside `∀ z0 z1`, which is the whole content — see
`Prop42Contentful.lean`'s module docstring for why both weaker orderings are vacuous. The
all-`⊤` escape hatch is closed by `topVVec_contentful_forces_unsat`
(`Prop42Contentful.lean:217`): offering `topVVec` as `v'` does not discharge the goal, it commits
the offerer to `v` being unsatisfiable on every ordered pair. The corresponding negative check —
that the all-`⊤` term does **not** typecheck against `Prop42Contentful` — is recorded verbatim in
this phase's handoff.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **Rabinovich's Proposition 4.2 (PDF p.6), at the attained carrier.**

    For every `VVecEA2` formula `v`, there is a single `VVecEA2` formula `v'` — depending on `v`
    alone, uniform in the points — equivalent to `¬v` on every ordered pair. The witness is
    `v.negFix` (`VecEANegFix.lean:135`), the Prop 4.3 De Morgan fold, and the biconditional is
    `VVecEA2.negFix_iff` (`VecEANegFix.lean:164`).

    This is the milestone the faithful path had been missing since the
    `Boneyard/NegationIndep.lean:357-364` fallback. It is reached by **wiring** the already-landed
    Section 5 transcription to the already-landed target statement — no new mathematics.

    **Carrier, stated because the rule requires it.** This is Prop 4.2 *restricted to attained
    structures*, **not** Rabinovich's Prop 4.2 over all Dedekind complete chains. `HasAttainedINF`
    is strictly stronger than the paper's Dedekind completeness — strictly stronger even than
    `HasDefinableINF`, which `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) already
    machine-refutes as too strong. See this module's docstring for the full exclusion. Do not cite
    this theorem as Prop 4.2 simpliciter.

    Source correspondence: Rabinovich 2014, Proposition 4.2, PDF p.6; proved in Section 5,
    pp.7-11. -/
theorem prop42_contentful_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (v : VVecEA2) :
    Prop42Contentful M atomMap v :=
  ⟨v.negFix, fun z0 z1 hlt => VVecEA2.negFix_iff M atomMap h_INF h_SUP v z0 z1 hlt⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
