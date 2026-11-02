import FormalSystem.OpenLanguage

/-!
# Probes, round 05: `⊡` is DEFINABLE from the open-future and open-past modals

Unlike probes 01-04, this file is **compiled-live**: it imports `FormalSystem.OpenLanguage` and is
stated against the repository's own `OpenTruthAt`, `WorldHistory` and `paste`, not against a
mirror. It therefore needs no faithfulness audit.

The one result, in two forms plus the time-reflection mirror:

```
⊡φ  ↔  ▷◁φ  ↔  ◁▷φ          on every regular task frame
```

* `stab_to_ofut_opast` — the `→` half. Only the two class inclusions at the point of evaluation:
  if `σ ∈ |τ⟩_t` and `ρ ∈ ⟨σ|_t` then `τ(t) = σ(t) = ρ(t)`, so `ρ ∈ ⟨τ⟩_t`. No frame axiom.
* `ofut_opast_to_stab` — the `←` half, and the only direction that needs structure. Given
  `ρ ∈ ⟨τ⟩_t`, the pasted world `paste τ ρ t` lies in `|τ⟩_t` and has `ρ ∈ ⟨paste τ ρ t|_t`
  (`paste_agreeUpTo`, `paste_agreeFrom`). `[F.IsRegular]` enters here and nowhere else, through
  `paste`.
* `stab_iff_ofut_opast`, `stab_iff_opast_ofut` — the two pointwise biconditionals.
* `openValid_stab_imp_ofut_opast`, `openValid_ofut_opast_imp_stab` — both implications as
  `OpenValid`, i.e. over every regular task frame (`FrameClass.Sat .Base F` is `F.IsRegular`).

## Why this matters for the aim of this task

1. **It is the two-sided decomposition report 03 §4 named as the missing device.** That round
   located the obstruction to a Reynolds-2001-style engine as: no root, `S` in the language, and
   emergent histories arising as limits of splices in BOTH directions, so that "a proof would
   need a two-sided decomposition … and two automata anchored at a named time". `⊡ = ▷◁` is that
   decomposition in the object language: `▷` is one-sided with its root at the present (past
   fixed, future branching) and `◁` is its mirror.
2. **It is `PlusRayFibre.plusStab_iff_rays` promoted from the metatheory to syntax.** That module
   reads the stability clause over pairs (past ray, future ray) agreeing at the seam state. The
   equations above say the same thing with `▷` and `◁` as the two projections.
3. **It means the richer language loses nothing.** Report 04 Decision 1 ruled HN and every
   shared-past proof step out of scope *because* `⊡` is not Ockhamist historical necessity
   (`hnOpen_openValid` vs `hnStab_refuted_sinkFrame`). With `▷` and `◁` primitive the Ockhamist
   modality is present and `⊡` is still there, by definition rather than by assumption, so no
   L⁺ result is given up in exchange.
4. **It discharges the purity side conditions of PS and US in the richer language (ARGUED, not
   compiled here).** `PlusAxiom.paste` and `PlusAxiom.untl_paste` carry `IsPureFuture` /
   `IsPurePast` side conditions whose necessity is itself proved (`PlusNonValidities.lean`), and
   their docstring states their content as "the total histories through a world state are the
   product of its possible pasts and its possible futures" — which is exactly the biconditional
   above, with no side condition and at arbitrary `φ`. With the two rigidity schemata
   `◁φ⁺ ↔ φ⁺` and `▷ψ⁻ ↔ ψ⁻` (semantic halves already landed as
   `PlusLanguage.truth_congr_agreeFrom` and `truth_congr_agreeUpTo`), PS follows from the
   biconditional by one `paste`. The side conditions move out of the structural axiom and into
   two rigidity axioms. UNVERIFIED: one probe.

## What it does NOT do

It says nothing about closure. Report 04 §4.1's diagnosis is untouched: all-histories semantics is
bundled semantics on *topologically closed* bundles, PS/US give paste-closure, MF gives
translation-closure, and nothing in the axioms gives closedness. `blc` stays a non-theorem and an
`LC_n`-style schema is still required, in this language exactly as in L⁺. Adding `▷` and `◁` is
not a substitute for limit closure, and nothing here is a completeness claim.

## Axioms

`#print axioms`, as printed by the compile below: `[propext]` for `stab_to_ofut_opast` and
`[propext, Quot.sound]` for the other four. **Choice-free throughout** — the paste construction is
explicit and no history is chosen.

## Compile

```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean
```

Exit 0, no warnings, against the repository's own oleans (no `lake` process).
-/

namespace Probe559R05

open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage

variable {F : TaskFrame}

/-! ## `⊡φ → ▷◁φ`: the two class inclusions at the point, no frame axiom -/

/-- `⊡φ → ▷◁φ`. If `σ` agrees with `τ` up to `t` and `ρ` agrees with `σ` from `t`, then `ρ`
occupies `τ`'s state at `t`, so `⊡φ` already applies to `ρ`. -/
theorem stab_to_ofut_opast (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) (h : OpenTruthAt M τ t (.stab φ)) :
    OpenTruthAt M τ t (.ofut (.opast φ)) := by
  intro σ hup ρ hfrom
  exact h ρ ((hup t le_rfl).trans (hfrom t le_rfl))

/-! ## `▷◁φ → ⊡φ`: the pasting direction, and the only user of `IsRegular` -/

/-- `▷◁φ → ⊡φ`. For `ρ ∈ ⟨τ⟩_t` the pasted world `paste τ ρ t` lies in `|τ⟩_t` and carries `ρ` in
its open-past class at `t`, so one `▷`-step followed by one `◁`-step reaches every member of
`⟨τ⟩_t`. This is the two-history instance of `app:gluing`; `[F.IsRegular]` enters only here. -/
theorem ofut_opast_to_stab [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) (h : OpenTruthAt M τ t (.ofut (.opast φ))) :
    OpenTruthAt M τ t (.stab φ) := by
  intro ρ hs
  exact h (paste τ ρ t hs) (fun s hst => (paste_agreeUpTo τ ρ t hs s hst).symm)
    ρ (paste_agreeFrom τ ρ t hs)

/-! ## The two biconditionals -/

/-- **`⊡φ ↔ ▷◁φ`**, pointwise, on every regular task frame. -/
theorem stab_iff_ofut_opast [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t (.stab φ) ↔ OpenTruthAt M τ t (.ofut (.opast φ)) :=
  ⟨stab_to_ofut_opast M τ t φ, ofut_opast_to_stab M τ t φ⟩

/-- **`⊡φ ↔ ◁▷φ`**, the mirror, by the same paste with the two histories exchanged. (It is also
one line from `stab_iff_ofut_opast` through `openValid_reflectTime`, since `reflectTime` fixes
`⊡` and exchanges `▷` with `◁`; the direct proof is given here to keep the file independent of
the reversal layer.) -/
theorem stab_iff_opast_ofut [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t (.stab φ) ↔ OpenTruthAt M τ t (.opast (.ofut φ)) := by
  constructor
  · intro h σ hfrom ρ hup
    exact h ρ ((hfrom t le_rfl).trans (hup t le_rfl))
  · intro h ρ hs
    exact h (paste ρ τ t hs.symm) (fun s hts => (paste_agreeFrom ρ τ t hs.symm s hts).symm)
      ρ (paste_agreeUpTo ρ τ t hs.symm)

/-! ## The same two implications as validities over every regular task frame -/

/-- `⊡φ → ▷◁φ` is `OpenValid`. -/
theorem openValid_stab_imp_ofut_opast (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp (.ofut (.opast φ))) :=
  fun _ _ M τ t => stab_to_ofut_opast M τ t φ

/-- `▷◁φ → ⊡φ` is `OpenValid`. The `FrameClass.Sat .Base F` hypothesis IS `F.IsRegular`, so the
`intro` registers the instance `ofut_opast_to_stab` needs. -/
theorem openValid_ofut_opast_imp_stab (φ : OpenFormula) :
    OpenValid ((OpenFormula.ofut (.opast φ)).imp (.stab φ)) :=
  fun _ _ M τ t => ofut_opast_to_stab M τ t φ

/-! ## Axiom audit -/

-- [propext] for the first, [propext, Quot.sound] for the rest. Choice-free throughout.
#print axioms stab_to_ofut_opast
#print axioms ofut_opast_to_stab
#print axioms stab_iff_ofut_opast
#print axioms stab_iff_opast_ofut
#print axioms openValid_ofut_opast_imp_stab

end Probe559R05
