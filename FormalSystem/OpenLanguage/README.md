# OpenLanguage — the language L^▷ (L⁺ plus the open-future and open-past modals)

This directory is a self-contained component at the library root. It defines a **fifth object
language** for the tree, **L^▷**, obtained from L⁺ (`FormalSystem/PlusLanguage/`) by adding the
two restricted modals that the manuscript's subsection *Restricted Modalities*
(`sub:RestrictedModalities`) introduces beside the stability modal `⊡`:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | ▷φ | ◁φ
```

`▷` (`ofut`) is the *open future* operator: it quantifies over `|τ⟩_x`, the possible worlds that
agree with the world of evaluation at every time up to and including the time of evaluation.
`◁` (`opast`) is the *open past* operator over `⟨τ|_x`, the worlds that agree from the time of
evaluation onward. `⊡` quantifies over `⟨τ⟩_x`, the worlds through the present world **state**.

L^▷ is **semantic only**: it has no proof system, and no axiomatization, soundness or completeness
claim is made for `▷` or `◁`.

## Why the component exists

Branching-time (Ockhamist) historical necessity quantifies over the histories that share the
*past* of the moment of evaluation. On a tree, "same moment" and "same past" coincide. On a task
frame they do not: the present world state fixes the alternatives of `⊡`, and two possible worlds
through one state need share neither past nor future. The operator of this semantics that
corresponds to historical necessity is therefore `▷`, **not** `⊡`. The component states that
distinction as library theorems, so that an argument which relies on shared pasts is not
transferred to `⊡` by mistake.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/OpenLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `Formula.lean` | 302 | `OpenFormula`, the derived operators (with `PlusFormula`'s right-hand sides), the duals `dofut` and `dopast`, `reflectTime` with `reflect_time_involution` and the `reflect_time_*` push-through lemmas, and the embedding `ofPlus` with `ofPlus_injective`, `ofPlus_reflectTime` and its `rfl` commutation pins |
| `OpenClasses.lean` | 166 | The three history classes `stabClass`, `openFutureClass`, `openPastClass` (the stability, open-future and open-past classes of a world at a time); the membership lemmas `mem_stabClass_iff`, `mem_openFutureClass_iff`, `mem_openPastClass_iff`; `sameState_equivalence`, `agreeUpTo_equivalence`, `agreeFrom_equivalence`; the inclusions, `openFutureClass_inter_openPastClass`, `openFutureClass_anti`, `openPastClass_mono`, and `paste_mem_openFutureClass_inter_openPastClass` |
| `OpenOckhamist.lean` | 400 | The Ockhamist separating pair: `hnOpen`, `hnOpenMixed`, `hnStab` with `hnStab_eq_ofPlus`; `hnOpen_openValid` and `hnOpenMixed_openValid` over every task frame; the countermodel `SinkState`, `sinkFrame`, `sinkFunA`, `sinkFunB`, `sinkFunA_isStepPath`, `sinkFunB_isStepPath`, `sinkHistA`, `sinkHistB`, `sinkModel`; `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`, `not_plusValid_hnStab`; the mirror `hnOpenMirror`, `hnStabMirror`, `hnOpenMirror_eq`, `hnStabMirror_eq`, `hnOpenMirror_openValid`, `openValid_hnOpenPast`, `not_openValid_hnStabMirror`; the five converse failures `not_openValid_box_of_stab`, `not_openValid_stab_of_ofut`, `not_openValid_stab_of_opast`, `not_openValid_opast_of_ofut`, `not_openValid_ofut_of_opast`; and the five transferred refutations `not_openValid_stab_box`, `not_openValid_allFuture_stab`, `not_openValid_stab_allFuture_past`, `not_openValid_determined`, `not_openValid_somePast_stab` |
| `OpenReversal.lean` | 317 | The converse frame of `lem:time-reflection`: `FrameOver.rev` (all four frame axioms), `TaskFrame.rev`, `TaskModel.rev`, `WorldHistory.rev`, with `rev_taskRel`, `rev_taskRel_neg`, the three `rev_rev` by `rfl`, `rev_state`, `rev_rev_hist` and `rev_surjective`; the class swaps `sameState_rev_iff`, `agreeUpTo_rev_iff`, `agreeFrom_rev_iff`; the transport theorem `openTruthAt_rev`; `openValidOn_rev_iff` and `openValid_reflectTime` |
| `OpenTruth.lean` | 288 | `OpenTruthAt` — the nine-clause truth recursion, the last two clauses the manuscript's for the open-future and open-past operators; the `TruthEnv` and `StabClauses` instances; the `OpenTruth.*` clause lemmas (`ofut_iff`, `opast_iff`, `dofut_iff`, `dopast_iff`); `openTruthAt_ofPlus`; pointwise S5 (`ofut_k`, `of_ofut`, `ofut_four`, `ofut_five` and the `opast` mirrors) and the ordering `stab_of_box`, `ofut_of_stab`, `opast_of_stab` |
| `OpenValidity.lean` | 229 | `TaskFrame.OpenValidOn`, `OpenValidOnFrames`, `OpenValidIn`, `OpenValid` with `mono`, `of_forall`, `apply`, `of_not`; conservativity over L⁺ (`openValidOn_ofPlus_iff`, `openValidOnFrames_ofPlus_iff`, `openValidIn_ofPlus_iff`, `openValid_ofPlus_iff`); S5 as validities (`openValid_ofut_k`, `openValid_ofut_t`, `openValid_ofut_four`, `openValid_ofut_five` and the `opast` mirrors); the ordering `openValid_stab_of_box`, `openValid_ofut_of_stab`, `openValid_opast_of_stab` |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/OpenLanguage.lean`. The library root, the repository-root
`FormalSystem.lean`, is generated by `lake exe mk_all --lib FormalSystem` and imports that
aggregator and every module in this directory directly.

## Paper-label correspondence

Every manuscript `\label` this component touches, mapped to a Lean declaration or to an explicit
exclusion. Anchors are cited by `\label` or by a quotable phrase, never by line number.

| Paper anchor | Claim | Lean |
|---|---|---|
| `sub:RestrictedModalities`, the open-future and open-past operators | two primitive unary operators beside `⊡`, with duals | `OpenFormula.ofut`, `OpenFormula.opast`, `dofut`, `dopast` (`Formula.lean`); `reflectTime` exchanges the two |
| `sub:RestrictedModalities`, the clauses for the open-future and open-past operators | `M,τ,x ⊨ ▷φ` iff `M,σ,x ⊨ φ` for all `σ` in the open-future class of `τ` at `x`; likewise `◁` over the open-past class | the `ofut` and `opast` clauses of `OpenTruthAt`, with `OpenTruth.ofut_iff` / `OpenTruth.opast_iff` (`OpenTruth.lean`) |
| `def:BLstar-semantics` (`⟨τ⟩_x`) | `⟨τ⟩_x := {σ ∈ H_F \| σ(x) = τ(x)}`, "an equivalence class under the relation `σ ∼_x τ`" | `stabClass`, `sameState_equivalence` (`OpenClasses.lean`) |
| `sub:RestrictedModalities`, item *Open Futures* | `\|τ⟩_x := {σ ∈ H_F \| σ(y) = τ(y) for all y ≤ x}` | `openFutureClass`, `agreeUpTo_equivalence` (`OpenClasses.lean`) |
| `sub:RestrictedModalities`, item *Open Pasts* | `⟨τ\|_x := {σ ∈ H_F \| σ(y) = τ(y) for all y ≥ x}` | `openPastClass`, `agreeFrom_equivalence` (`OpenClasses.lean`) |
| `sub:RestrictedModalities`, "we may then prove that …" | `\|τ⟩_x ⊆ ⟨τ⟩_x` and `⟨τ\|_x ⊆ ⟨τ⟩_x`, where `\|τ⟩_x ∩ ⟨τ\|_x = {τ}` | `openFutureClass_subset_stabClass`, `openPastClass_subset_stabClass`, `openFutureClass_inter_openPastClass`; `⟨τ⟩_x ⊆ H_F` is `stabClass_subset_univ` |
| `sub:RestrictedModalities`, "moving forward in time narrows the open futures and widens the open pasts" | `\|τ⟩_y ⊆ \|τ⟩_x` and `⟨τ\|_x ⊆ ⟨τ\|_y` for `x ≤ y` | `openFutureClass_anti`, `openPastClass_mono` |
| footnote to the stability clause, "an equivalence class … the monomodal logic of `⊡` is also S5" | the same argument for the open-future and open-past classes: K, T, 4 and 5 for each of `▷` and `◁` | `openValid_ofut_k`, `openValid_ofut_t`, `openValid_ofut_four`, `openValid_ofut_five`, `openValid_opast_k`, `openValid_opast_t`, `openValid_opast_four`, `openValid_opast_five` (`OpenValidity.lean`) — **not stated in the manuscript**, which asserts S5 for `⊡` only |
| footnote to the stability clause, "`⊡` is strictly weaker than `□`" | the strength ordering `□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁`, from the three inclusions | `openValid_stab_of_box`, `openValid_ofut_of_stab`, `openValid_opast_of_stab` (`OpenValidity.lean`) |
| conservativity over L⁺ (no paper anchor) | an L⁺ formula is L^▷-valid iff it is L⁺-valid, at every frame class | `openTruthAt_ofPlus` (`OpenTruth.lean`), `openValidIn_ofPlus_iff`, `openValid_ofPlus_iff` (`OpenValidity.lean`) — **formalization-native** |
| `lem:time-reflection` (the converse frame) | the converse relation, with the world `τ⁻(x) = τ(-x)` over the converse frame, a bijection between the worlds of the two frames | `FrameOver.rev`, `FrameOver.rev_taskRel_neg`, `TaskFrame.rev`, `WorldHistory.rev`, `WorldHistory.rev_rev_hist`, `WorldHistory.rev_surjective` (`OpenReversal.lean`) — built semantically for an arbitrary task frame, with all four axioms of `def:frame` discharged |
| `lem:time-reflection` (truth and validity) | truth at a point is truth of the time reflection at the reflected point; validity is closed under time reflection | `openTruthAt_rev`, `openValidOn_rev_iff`, `openValid_reflectTime` (`OpenReversal.lean`) — the manuscript states the lemma for its base language; the extension to `⊡`, `▷` and `◁` through the class swaps `sameState_rev_iff`, `agreeUpTo_rev_iff`, `agreeFrom_rev_iff` is **formalization-native** |
| the Ockhamist principle HN for the open-future operator (no paper anchor) | `Pα → ▷P▷̂α` and the mixed `Pα → ▷P⟐α` are valid over every task frame | `hnOpen_openValid`, `hnOpenMixed_openValid` (`OpenOckhamist.lean`) — **not a manuscript result** |
| HN transposed to the stability operator (no paper anchor) | `Pp → ⊡P⟐p` is refuted on a finite integer-time frame satisfying all four axioms of `def:frame` | `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`, `not_plusValid_hnStab` over `sinkFrame` (`OpenOckhamist.lean`) — **not a manuscript result**; it is what separates `⊡` from historical necessity |
| the mirrored pair, through `lem:time-reflection` (no paper anchor) | `Fα → ◁F◁̂α` is valid at every `α`; its stability transposition `Fp → ⊡F⟐p` is not valid | `hnOpenMirror_openValid`, `openValid_hnOpenPast`, `not_openValid_hnStabMirror` (`OpenOckhamist.lean`), each one line from `openValid_reflectTime` — **not a manuscript result** |
| footnote to the stability clause, "`⊡` is strictly weaker than `□`" | the ordering is strict at every link: `⊡p → □p`, `▷Pp → ⊡Pp` and `◁Fp → ⊡Fp` each fail | `not_openValid_box_of_stab`, `not_openValid_stab_of_ofut`, `not_openValid_stab_of_opast` (`OpenOckhamist.lean`), each on the permissive frame `NF` over `ℤ` |
| `▷` and `◁` are incomparable (no paper anchor) | `▷Pp → ◁Pp` and `◁Fp → ▷Fp` both fail — the manuscript records only that the two classes meet in `{τ}` | `not_openValid_opast_of_ofut`, `not_openValid_ofut_of_opast` (`OpenOckhamist.lean`) — **not a manuscript result** |
| the L⁺ refutations (no paper anchor) | the five formulas refuted for L⁺ stay invalid in L^▷ | `not_openValid_stab_box`, `not_openValid_allFuture_stab`, `not_openValid_stab_allFuture_past`, `not_openValid_determined`, `not_openValid_somePast_stab` (`OpenOckhamist.lean`), each through `openValid_ofPlus_iff` |
| `app:gluing` (two histories) | a world whose past is `τ`'s and whose future is `σ`'s, for `σ ∈ ⟨τ⟩_x` | `paste_mem_openFutureClass_inter_openPastClass`, over `paste` of `PlusLanguage/PlusPasting.lean` |

## Manuscript operators without a formalization

| Manuscript item | Status |
|---|---|
| An axiomatization, soundness or completeness result for `▷` and `◁` | **Excluded.** The manuscript gives none — "I will omit further consideration of the restricted modals" — and none is claimed here. The S5 laws and the ordering above are validities, not axioms of a proof system |
| The nomic operator of `sub:RestrictedModalities`, over a four-place task relation indexed by world states | **Excluded.** No formalization in this tree |
| The world registers `↑_M`, `↓_M` of `sub:Extension` | **Excluded.** `FormalSystem/StarLanguage/` formalizes the time registers only. **State** registers, which the manuscript does not have, are formalized in `FormalSystem/HybridLanguage/`; the world registers stay excluded |

## Module Invariants

**Syntax before semantics within this directory**, exactly as in the sibling language components.
Every file here has a layer in the `LANGUAGE_FILE_LAYERS` table of
`scripts/measure-refactor-partitions.py` — 0 for a syntax file, 1 for a semantic module — and
`bash scripts/check-metalogic-cycles.sh` fails if a layer-0 file of any language directory imports
a layer-1 file of any of them, or anything under `FormalSystem/Semantics/`. **A new file in this
directory needs a row in that table.**

## References

* JPL paper — `sub:RestrictedModalities`, `def:BLstar-semantics`, `def:world-history`,
  `def:frame`, `def:frame-validity`, `lem:time-reflection`, `app:gluing`
* [M. Reynolds, *An Axiomatization of Prior's Ockhamist Logic of Historical
  Necessity*][reynolds2003] — the HN axiom
* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4 — Kamp's AK12
* `FormalSystem/PlusLanguage/README.md` — L⁺, the language this one extends
* `FormalSystem/StarLanguage/README.md` — the sibling extension of L⁺ by the time registers

---

*Last verified: 2026-09-21*
