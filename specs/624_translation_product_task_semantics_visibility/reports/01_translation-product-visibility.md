# Research Report: Task #624

**Task**: 624 - Translation product: what it shows about the task semantics (visibility of frame features to L, L⁺, L⋆)
**Started**: 2026-09-19T03:26:31Z
**Completed**: 2026-09-19T04:05:00Z
**Effort**: ~40 minutes of agent time; two compiled probes (929 lines), one report
**Dependencies**: None (deliberately; inputs are 559's reports and probes, read as established)
**Sources/Inputs**: - Manuscript `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4554 lines, read on 2026-09-19): Primitive Worlds 557-942, Possible Worlds 943-1216, Extensions 1352-1471, Tense and Modality 1472-1660, Dynamical Systems and Conclusion 1659-1860, appendix Task Semantics 2811-3904 (incl. the commented-out `app:Structure` block 3905-4085). All line numbers below are to that file as read. - Established (read, not redone): `specs/559_.../reports/03_axiomatizability-rules-engine.md` §3.2, `reports/04_semantics-first-task-frames.md` §3.3 and §4, `probes/04_semantics-native-general-duration.lean` Parts R and S; `reports/02_review-base-incompleteness.md` §2-3. - Codebase: `FormalSystem/Semantics/TaskFrame.lean` (`FrameOver`, the four bare-relation axioms, `limit_of_shift`, `saturation_of_finite`, `saturation_of_fib_subsingleton`, `ofReflective`), `Semantics/PartialHistory.lean` (`WorldHistory`, `ofTotal`, `timeShift`), `Semantics/{Truth,PlusLanguage/PlusTruth,StarLanguage/StarTruth}.lean`, `Semantics/{Validity,PlusLanguage/PlusValidity,StarLanguage/StarValidity,FrameClassValidity,FrameProperty}.lean`, `Semantics/Frames/Standard.lean` (`translationFrame`), `Semantics/ShiftSet.lean`, `Metalogic/Independence/{CoarsenedModels,PastedCoarseModels,LimitClosureFrame,LimitClosureCountermodel,PlusIncompleteness,ClockFrame,RealTranslationFrame,README}.lean|md`, `Semantics/Extension/Extension.lean` (`occurrence`). - Probes written this round (both sorry-free, compiled with `lake env lean` against the repository's oleans): `probes/01_translation-product-live.lean`, `probes/02_limit-idle-mirror.lean`. - No web or literature search was needed; no literature claim below goes beyond held sources already cited by 559's reports.
**Artifacts**: - `specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md` (this report) - `specs/624_translation_product_task_semantics_visibility/probes/01_translation-product-live.lean` - `specs/624_translation_product_task_semantics_visibility/probes/02_limit-idle-mirror.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Verdict (Q1): the translation product of any live task frame IS a task frame over the same
  temporal order, at every one of the six `FrameOver` fields, hence at Base, Dense, ZTime and RTime
  alike** (`prodFrame`, `prodFrame_sat`, compiled against `FormalSystem/Semantics/TaskFrame.lean`).
  Each field uses exactly one hypothesis on `F`: reflection from `F.reflection`, Compositionality
  from `F.comp`, Seriality from `F.serial`, *Saturation* from `F.saturation` (the paper argument of
  report 03 §3.2, now compiled: `prodRel_saturation`, and its converse `saturation_of_prodRel`),
  and *Limit* from `⇒₀ ⊆ id` alone (`prodRel_limit`). Nothing downstream needs restating.
- **Verdict (Q3): recurrence and transposition are invisible to L, L⁺ AND L⋆** — the L⋆ case that
  report 04 left UNVERIFIED is settled (`star_invariance`: the two register clauses are inert
  under the projection). At every `FrameClass` tag and for all three languages, **validity over
  the class equals validity over its recurrence-free members** (`validIn_iff_recurrenceFree`,
  `plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`). Frame-by-frame the product
  validates strictly fewer formulas (`frame_validity_not_reflected`): its extra valuations are the
  manuscript's abundant two-dimensional models (lines 832-937) rebuilt inside the task semantics.
- **Limit contributes no validity beyond reflexivity of the zero task** (probe 02,
  `TD_zeroFix` + `zeroFix_limit_clocked`): sharper than report 04's "beyond Nullity". Saturation
  and determinism are untouched by the device (it preserves and reflects both:
  `saturation_of_prodRel`, `prodFrame_deterministic_iff`); their visibility stays as it was (OPEN,
  resp. invisible to L⁺ / visible to L⋆, landed).
- **The right general notion (Q2)** is a *history-lifting morphism* (`HistMorphism`: relation-level
  forth, history-level lift through every preimage state, onto histories); truth is invariant
  along any such morphism (`histMorphism_invariance`) and the projection is one (`prodProj`). The
  product is terminal among **clocked** covers as history-lifting *maps* (`clockedFactor`) but not
  as onto morphisms (`stateClock_not_joint`), and a recurrence-free cover need not carry a clock at
  all (paper counterexample, §2.3). The pullback reading of `len : Path(F) → BD⁺` along `D` is
  recorded as a question for 618, not settled.
- **Uses (Q4)**: coarse refutations and paste-closure transfer to the product both ways
  (`liftK`, `c_invariance`, `pasteClosed_liftK`, `pasteClosed_of_liftK`, `c_refuted_lift`); any
  finite reflective serial compositional colour relation with `⇒₀ ⊆ id` clocks to a task frame
  over ANY `D` with no Limit or Saturation obligation left (`colourClock`). For the dense BLC
  countermodel the device removes Limit and reduces Saturation to the colour structure; the
  ordinal-budget colour structure's own Saturation and the Dense soundness of paste-closed coarse
  validity remain UNVERIFIED (§4.1).
- **Limits (Q5)**: the device never refutes anything `F` does not, so it is silent on every
  question about the stability modal beyond state-locality: closure schemata (BLC, `LC_n`),
  Saturation's contribution, naming rules, L⋆ axiomatizability. It is a proof device that shows what
  the languages cannot see; it is never a model of anything.
- **Recommendations**: (i) port probe 01 into `FormalSystem` as `FrameOver.translationProduct` with
  the invariances and `plusValidIn_iff_recurrenceFree` (~450 lines, no new axioms); (ii) the
  manuscript merits one remark (near 1025-1030 or 1764) that its object languages cannot express
  recurrence — it strengthens the simulation-metasemantics stance rather than weakening the paper;
  (iii) 559 may build clocked canonical frames without loss of generality and treat the truth
  lemma as the whole problem.

## Context & Scope

The object of study is the manuscript's task semantics (`def:frame` at 2834, histories `def:world-history`
at 2926, `H_F` = all total histories, the stability modal `⊡` at 1153-1155 and 3544-3554). The
translation product is a proof device only: the synchronous product of a task frame `F = (W, D, ⇒)`
with the translation frame on `D` — states `W × D`, the SAME duration group, `(w,s) ⇒_x (v,t)` iff
`w ⇒_x v` and `t = s + x`. Written `F × D` in earlier reports; called the translation product here.

**Standing caveat, kept explicit in every conclusion below.** A state carrying a clock reading is
not a world state in the manuscript's sense: world states are instantaneous configurations meant to
recur (646-648, 1025-1028) and to leave time outside the state (949-951, 1043-1050). The product
plays the role that tree-unravelling plays in modal logic: the manuscript itself says (1764) that
"the branching tree of states is not posited but may be recovered by unfolding the transitions" —
the product is the *time*-unfolding, and it shows what the languages cannot express. Nothing here
proposes the product as an intended model.

Constraints honoured: no completeness theorem is stated; every invariance and frame-axiom fact
below carries a compiled, sorry-free probe or the label UNVERIFIED; every manuscript claim cites a
line and a label or phrase; no changes to `FormalSystem/` or `Tests/`.

## Findings

### Codebase Patterns

- The live structure is `FrameOver D` (`TaskFrame.lean:767-849`): six fields — `WorldState`,
  `[worldNonempty]`, `PosRel` on the positive cone, `comp` (biconditional Compositionality by
  citation), `serial`, `limit` (literal cone shape), `saturation` (literal `TaskFrame.Saturation`).
  The two-sided relation is `TaskRel := reflect PosRel`; a two-sided presentation enters through
  `FrameOver.ofReflective` (1042-1052), which is the constructor the probe uses.
- `WorldHistory F` (`PartialHistory.lean:407`) is the subtype of total partial histories;
  `WorldHistory.ofTotal` builds one from a state function and the task-respect law; `ext_state`
  is the extensionality used throughout the probe.
- Class tags are properties of `Duration` only (`FrameClassValidity.lean`, `FrameProperty.lean`):
  `.Dense ↦ DenselyOrdered`, `.ZTime ↦ IsZTime`, `.RTime ↦ IsDense ∧ IsComplete`. That is why
  `prodFrame_sat` is `Iff.rfl` at every tag.
- Existing clocked frames in the tree: `translationFrame D` (`Frames/Standard.lean:73`), `F¹`
  (`RealTranslationFrame.lean`), the periodic clock `ℚ ⧸ ℤ` (`ClockFrame.lean`), the deterministic
  `ℤ`-shift family (`ReynoldsBridge.lean`, `FlowFrame.lean`), `ShiftSet.fibre`. All are
  *deterministic* clocked frames; none is the product of an arbitrary `F`. `TaskFrame.limit_of_shift`
  (1158) is already the discharge route for "carriers of the form `Index × D`", and it is exactly
  what `prodRel_limit` invokes.
- The coarsened-state vehicle: `CoarseModel`, `CTruthAt`, `CoarseModel.PasteClosed`, `PCValid`,
  `not_plusDerivable_of_pcRefuted` (`.Base` only), and the landed countermodel `eK` on `EF` over `ℤ`
  (`LimitClosureCountermodel.lean`), whose π-image bundle is `evFalse`.

### External Resources

- Manuscript passages relied on (line, label or phrase): recurrence motivation 646-648 ("systems
  which we may wish to study that admit loops"), 699-704, 722-725, 1025-1030 ("nothing prevents a
  world state from occurring at many times"; transposition at 1028); world states vs durations
  949-951; `[τ]_F` possible-world classes 1043-1050; abundant models and time-shift 832-937;
  simulation metasemantics 921-937; Limit's gloss 991 ("distinct world states are instantaneously
  separated"); LTS remark 1005; `⊡` clause 1153-1155 and footnote 1158-1162; "omit further
  consideration" 1210; registers 1456-1466 and 1455 ("lack the means by which to cross reference
  either times or worlds"); Determined 1517, Deterministic 1523, drift remark 1530-1534;
  `sent:det` 1577-1583; Nullity/dynamical systems 1663-1671; unfolding remark 1764; bundle remark
  1775; `def:frame` 2834-2846 with the ball-space footnote 2838-2843; `lem:nullity` 2852;
  `cor:saturation-finite` 2866; topology 2881-2920; `thm:extension` 3038; `cor:occurrence` 3056;
  `app:gluing` 3070 with the `ℚ` example 3074; `def:BL-semantics` 3128; time-shift 3171-3220;
  class validity 3232; the static-frame footnote to `app:discrete` 3256-3260 ("correspondence
  holds over the fibre rather than frame by frame"); `def:deterministic` 3537;
  `def:BLstar-semantics` 3544; `lem:deterministic-singleton` 3559; `app:drift` 3720-3748;
  `cor:no-characterization` 3755-3770; the commented-out engine states `⟨i, y⟩` at 3823 and the
  open remark at 3832; `def:path-category` 4047, `cor:path-fibration` 4063 (commented out).
- Landed repository results cited: `deterministic_not_plusDefinable`, `star_discriminates_where_plus_cannot`,
  `deterministic_starDefinable`, `plus_incomplete_base`, `eK_pasteClosed`, `blc_cRefuted`,
  `PartialHistory.occurrence`, `stab_state_only`, `plusTruthAt_timeShift`, `starTruthAt_timeShift`.
- From 559: `clock_hist_iff`, `clock_no_recurrence`, `clock_comp`, `clock_serial`, `clock_limit`,
  `clock_invariance` (probe 04 Part R), `repar_invariance` (Part S), `tw_invariance` and the bundle
  form of the clock product (probe 03, `ℤ` mirror).

### 1. Q1 — Is the product a task frame? YES, at every field and every class

**1.1 Field-by-field, with the hypothesis on `F` each one uses** (probe 01, section `Bare`, stated
over a bare relation `R : W → D → W → Prop` so that the dependency is exact).

| `FrameOver` field | Product discharge | Hypothesis on `F` used | Status |
|---|---|---|---|
| `WorldState`, `[worldNonempty]` | `W × D`, `⟨(w, 0)⟩` | `F.worldNonempty` | compiled (`prodFrame`) |
| `PosRel` (two-sided presentation via `ofReflective`) | `prodRel_reflection` | reflection law `F.reflection` | compiled |
| `comp` (biconditional) | `prodRel_comp` | `F.comp` | compiled |
| `serial` | `prodRel_serial` | `F.serial` | compiled |
| `limit` | `prodRel_limit` via `limit_of_shift` | **only** `R w 0 u → u = w` (`F.eq_of_taskRel_zero`) | compiled |
| `saturation` | `prodRel_saturation` | `F.saturation`; converse `saturation_of_prodRel` | compiled (both directions) |

The Saturation argument (report 03 §3.2, on paper until now): every fibre and every segment of the
product has a constant clock coordinate (`prodRel_const_clock`); a `⊇`-directed family of nonempty
members therefore shares one clock value; the state-projections of the members are exactly the
corresponding fibres and (for nonempty members) segments of `R` (`prodRel_fib_image`,
`prodRel_seg_image`), and form a directed family; Saturation of `R` supplies a common state `u`,
and `(u, c)` lies in every member. Axioms: `[propext, Quot.sound]` — no choice, no Zorn.

**1.2 Classes.** `prodFrame_sat fc : fc.Sat (prodFrame F) ↔ fc.Sat F` is `Iff.rfl` for each of
`.Base, .Dense, .ZTime, .RTime`, because the product keeps `D` and every tag is a condition on
`D`. So the device works uniformly at all four classes with no per-class argument.

**1.3 What the product needs of `F` that it does not use.** *Limit* of `F` is used only through
its consequence `⇒₀ ⊆ id`; the cone condition proper is never consulted (`prodRel_limit` is stated
with the bare `h0` hypothesis). This is the compiled backbone of the Q3 verdict on Limit.
`colourClock` records the consequence: any finite reflective serial compositional relation with
`⇒₀ ⊆ id` — no Limit, no Saturation hypothesis — clocks to a live `FrameOver D` over ANY `D`.

**1.4 Neutrality.** Determinism transfers both ways (`prodFrame_deterministic_iff`); Saturation
transfers both ways (1.1). The product changes exactly two things: it forbids recurrence and
transposition (§3), and it supplies Limit.

**1.5 Histories.** `liftH ρ c` (state `(ρ t, c + t)`) and `projH` are mutually inverse up to the
clock offset (`projH_liftH`, `liftH_projH`, `clock_eq`): histories of the product are exactly
history-plus-offset pairs, so lifts are unique and no Extension Theorem is needed — the live form
of `clock_hist_iff`. `prod_no_recurrence` and `prod_no_transposition` follow (the latter because
`x - y = y - x` forces `x = y` in an ordered abelian group).

### 2. Q2 — The right general notion

**2.1 History-lifting morphisms.** What the invariance induction consumes, stated against
`PlusTruthAt` (probe 01, section `Morphism`):

- `HistMap F' F`: a state map `f` with **forth** (`TaskRel' a x b → TaskRel (f a) x (f b)`) and
  **lift** (every history `τ` of `F` through `f a` at `t` lifts to a history of `F'` through `a`
  at `t` whose image is `τ`);
- `HistMorphism F' F extends HistMap` with **onto** (every history of `F` is an image).

`histMorphism_invariance`: for the pulled-back model, `PlusTruthAt (g.pullM M) τ' t φ ↔
PlusTruthAt M (g.mapH τ') t φ`, every `φ`. Forth serves the projection, onto serves `□`, lift
serves `⊡` (through the given state). `prodProj F : HistMorphism (prodFrame F) F` is the instance
(lift = `liftH` with the clock read off the state; onto = `liftH _ 0`). Surjectivity on states is
not assumed; it follows from `onto` plus `cor:occurrence` (`HistMorphism.surj_of_occurs`).

**2.2 Relation-level bounded morphisms are not enough on their own.** The classical "back"
clause (`TaskRel (f a) x u → ∃ b, TaskRel' a x b ∧ f b = u`) lifts one task; a total history is
lifted only by an extension argument in `F'` — for finite `F'` a compactness/König step, in
general Zorn plus Saturation of `F'` (paper; UNVERIFIED whether relation-back + Saturation of `F'`
implies `lift`). The history-level `lift` is the honest primitive. Conversely `lift` implies
relation-back given `thm:extension` in `F` (paper, routine: extend `{(0,f a),(x,u)}` and lift).

**2.3 Universality among recurrence-free covers: NO in general; YES among clocked covers, as
maps.** A `Clock` on `G` is `c : G.WorldState → D` with `c b = c a + x` along every task.
- `clockedFactor g k : HistMap F' (prodFrame F)`, `a ↦ (g a, c a)`, with both projections
  recovered (`clockedFactor_fst/snd`); uniqueness is `Prod.ext`. So the product is terminal among
  clocked covers in the category of history-lifting maps.
- It is onto histories exactly when `g` and `c` are jointly surjective
  (`clockedFactorMorphism`), and that can fail: on the product of the translation frame the clock
  `c(u, e) := u` is a valid clock and `(fst, c)` misses `(0, x)` (`stateClock_not_joint`). So
  clocked covers factor *through* the product, not necessarily *onto* it.
- A recurrence-free cover need not carry any clock (paper, precise): over `ℤ`, states
  `ℤ ⊔ {u, b}`, one-step edges `a_i → a_{i+1}`, `a_0 → b → a_2`, `a_0 → u → b`; `⇒_n` the `n`-fold
  composite, `⇒_0 = id`. Every edge strictly raises the level `a_i ↦ i, u ↦ 1/2, b ↦ 3/2`, so no
  history revisits a state; Seriality, Compositionality, Limit (`limit_of_succOrder`) and
  Saturation (`saturation_of_fib_finite`) hold; it is an onto history-lifting cover of the trivial
  one-state frame. But `a_0 ⇒_2 a_2` and `a_0 ⇒_3 a_2`, so no clock exists. Hence "recurrence-free
  cover" is strictly broader than "clocked cover", and the product is universal only for the
  latter. UNVERIFIED in Lean (the level argument is elementary; ~80 lines if wanted).

**2.4 Categorical reading — posed, not settled** (for 618, `def:path-category` 4047,
`cor:path-fibration` 4063). The morphisms of `Path(prodFrame F)` from `(w, d)` to `(v, e)` of
length `ℓ` are the sections `τ ∈ Beh(F)(ℓ)` from `w` to `v` with `e = d + ℓ`. That is the
description of the pullback of `len : Path(F) → BD⁺` along the functor `D → BD⁺` sending the
poset arrow `d ≤ e` to the duration `e - d`. Questions to pose: (a) is `Path(prodFrame F)` the
pullback of `len` along `(D, ≤) → BD⁺` on the nose (objects `W × D`, arrows as above), with the
projection `Path(prodFrame F) → Path(F)` the pullback leg? (b) is `len` restricted to the pullback
the "height" functor to `(D, ≤)`, and does `cor:path-fibration`'s discrete Conduché property
transfer to it? (c) do `liftH`/`projH` (unique lifts of total histories) express that the pullback
along a *poset* is a discrete fibration over `D`? None of these is needed for anything in this
report; they belong to 618 once `Path(F)` exists.

### 3. Q3 — What the device shows about the semantics

**3.1 Feature-by-language table.** "Invisible" means: validity over any class of task frames
closed under the product is unchanged by adding or removing the feature, because `F` and
`prodFrame F` validate the same sentences over the class (§3.2) and the product lacks the feature.
Evidence names are probe 01 theorems unless marked.

| Frame feature | L | L⁺ | L⋆ (time registers) | With a state register or state nominals | Evidence |
|---|---|---|---|---|---|
| Recurrence (a history revisits a state) | invisible | invisible | invisible | visible (paper) | `truth_invariance`, `plus_invariance`, `star_invariance` + `prod_no_recurrence`; L⋆ settles report 04 §3.3.3 |
| Transposition (two histories through the same states in opposite order) | invisible | invisible | invisible | weak form visible (paper) | same invariances + `prod_no_transposition` |
| Limit beyond Nullity | invisible | invisible | invisible (same argument, not compiled for `StarTruthAt` in the mirror) | invisible | probe 02 `TD_zeroFix`, `zeroFix_limit_clocked`; probe 01 `prodRel_limit`; sharper: nothing beyond reflexivity of `⇒₀` |
| Saturation (vs. Comp+Serial+Limit) | not settled by the device | not settled (OPEN, report 04 §4.1) | not settled | not settled | `saturation_of_prodRel` (device is neutral) |
| Determinism | invisible (landed `cor:no-characterization`, 3755) | invisible (landed) | visible (landed `Det±`, `deterministic_starDefinable`) | visible | `prodFrame_deterministic_iff` (device is neutral); `F°`, `F¹` are themselves recurrence-free |
| Duration-metric facts (a rate, a distance) | invisible (`repar_invariance`, 559/04 Part S) | invisible (same) | clock reading invisible (`star_invariance`); synchrony visible (landed `StarDiscrimination`) | as L⋆ | see §3.4 |
| Clock reading / absolute time of a state | invisible | invisible | invisible | invisible | `star_invariance`: registers store *evaluation* times, never a state's clock |

**3.2 Validity over a class equals validity over its recurrence-free members** — compiled at every
`FrameClass` tag and for all three languages (`validIn_iff_recurrenceFree`,
`plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`). Proof shape: the
recurrence-free frames of the class are a subclass; conversely every frame of the class is covered
by its product, which is recurrence-free (`prodFrame_recurrenceFree`) and in the class
(`prodFrame_sat`), so a formula valid on the product is valid on `F` (`*ValidOn_of_prod`).

**Frame-by-frame the picture is different and the difference is instructive.**
`frame_validity_not_reflected`: `p → Gp` is valid on the one-state frame and refuted on its product
(the translation frame) by the clock-dependent valuation `V(u, e) p := e ≤ 0`. The product validates
strictly fewer sentences than `F`, because sentence letters on the product may depend on the clock.
Those valuations are exactly the manuscript's abundant two-dimensional models (832-937): the
product is where the task semantics contains the theory it was built to replace, and the
projection is a bounded morphism for *lifted* valuations only. The manuscript already records a
parallel phenomenon in the footnote to `app:discrete` (3257-3260): correspondence "holds over the
fibre rather than frame by frame".

**3.3 Manuscript comparison — where motivation outruns expression.**

1. *Recurrence and transposition.* The manuscript motivates world states as primitives by
   recurrence and transposition (646-648: "there are systems which we may wish to study that admit
   loops"; 699-704; 722-725; 1025-1030: "nothing prevents a world state from occurring at many
   times in a single history … nothing prevents two histories … from passing through the same
   world states in a different order"; Conclusion 1764). The compiled verdict is that L, L⁺ and
   L⋆ validate exactly the same sentences over frames with and without these features. **This is
   not an error**: the manuscript never claims expressibility, and its simulation metasemantics
   (921-937) explicitly denies that the object language reads off the semantic primitives. It is,
   however, a gap between what motivates the primitives and what the logic answers to, and it is
   worth one remark (Recommendation (ii)); 1764's own "recovered by unfolding" is the natural hook,
   since the product is the time-unfolding.
2. *Limit.* Motivated at 991 ("distinct world states are instantaneously separated") and given
   topological content at 2881-2920 (T1, R0). Its logical content for the three languages is nil
   beyond reflexivity of `⇒₀` (probe 02): a structure with a reflexive but non-injective, non-Limit
   zero task has the same histories, hence the same truths, as its zero-fixed version, whose
   product satisfies Limit. The topology is a frame-level fact the languages cannot see; the
   manuscript does not claim otherwise, but 1671 ("Every task frame satisfies the conditions above,
   where `lem:nullity` derives the zero loops and Limit entails the converse") reads as if the
   converse mattered to the semantics of `BL`; it matters to the *dynamical-systems* identification
   only.
3. *Saturation.* Motivated at 991 ("no world state is missing wherever compatible constraints
   converge") and by the `ℚ` example at 3074, which is a closed bundle (report 04 §4.1) that is the
   bundle of no saturated frame (paper: the frame read off it is itself, and a saturated frame
   with the same bundle would have to equal it). Whether L⁺ separates such bundles is OPEN, and
   the device cannot help (neutral). The manuscript's own ball-space footnote (2838-2843) frames
   Saturation as strictly frame-level; consistent.
4. *Determinism and registers.* The manuscript's claims (1530-1534, 3755-3770, 1626 footnote) are
   exactly right and landed; the product adds nothing, and both `F°` and `F¹` are already
   recurrence-free, so the indistinguishable pair lives inside the clocked class.
5. *Dynamical systems (1663-1671).* The identification "every task frame is a non-deterministic
   dynamical system" is at the frame level; the languages see only `H_F`, and `H_F` is preserved
   by any change to `⇒₀` that keeps it reflexive (probe 02 `hist_zeroFix_iff`). Again a
   motivation about primitives, not a claim about the logic.

**3.4 Duration-metric facts, sharpened.** L⁺ sees each history only up to order-preserving
re-timing (559/04 `repar_invariance`). For L⋆: independent re-timing of histories fails (registers
express synchrony, 3743-3747, landed), but a state's clock reading is still invisible
(`star_invariance`), which is consistent with 1455 ("lack the means by which to cross reference
either times or worlds" — the registers add cross-reference of *evaluation* times, never of the
state's own time). Whether L⋆ is invariant under a *uniform* non-additive order automorphism is
ill-posed at the frame level (the re-timed structure is not a task frame) and is not pursued.

### 4. Q4 — What the device can be used for

**4.1 (a) Countermodels over dense and real time, Limit for free.** Compiled: the product of any
`FrameOver D` is a `FrameOver D` (§1); `colourClock` builds one from a finite colour relation
with no Limit hypothesis; coarse models lift with truth preserved (`liftK`, `c_invariance`) and
paste-closure transfers both ways (`pasteClosed_liftK`, `pasteClosed_of_liftK`); refutations
transfer (`c_refuted_lift`). So the Limit obligation of report 02 §3's dense BLC sketch is gone.

What remains, precisely, for the dense/real BLC countermodel:
- The colour structure over dense `D` must be `eR`-like with `⇒_x = eR` for all `x > 0`
  (`eR_trans` and `eR_dense` give Compositionality both ways; `eR_succ`/`eR_from_hub` give
  Seriality; `⇒₀ := id`). With **natural** budgets the π-image bundle is not paste-closed over
  dense `D`: a future whose `p`-times accumulate downward needs budgets increasing without bound
  going backwards, so no non-hub state can precede the accumulation point, and a past with `p`-times
  cannot be pasted on. Report 02's diagnosis stands: budgets must be ordinals (the state before the
  accumulation carries a limit ordinal). With ordinal budgets every ascending chain of `p`-times is
  still finite (no infinite descending ordinal sequence), so BLC's consequent is still refuted.
- **Saturation of the ordinal-budget colour structure is the one open obligation.** The product
  reduces it to the colour structure (`prodRel_saturation`), but it is not `saturation_of_finite`
  (infinite carrier) nor `saturation_of_fib_finite` (forward fibres of the hub are infinite, and
  with ordinal budgets non-hub forward fibres are infinite too). The landed `ℤ` route
  (`sInter_nonempty_of_directed_of_finite_mem` plus "every infinite member contains the hub") needs
  re-argument. UNVERIFIED.
- Non-derivability at `.Dense`/`.RTime` additionally needs a class-restricted version of
  `plus_pcValid_and_reflect_time` (currently `.Base` only). Routine: the dense axioms are conditions
  on `D`, `CTruthAt` shares the `U/S` clauses, and `cValid_of_tm` already goes through
  `axiom_validIn` at the frame's own class. UNVERIFIED.
- The coarse model must be defined directly on the product (the colour structure is not a
  `TaskFrame`, so `pasteClosed_liftK` cannot be applied to it); its paste-closure is the walk-splice
  of `eK_pasteClosed_aux` with the clock carried along, which `liftH` makes trivial once the walk
  splice exists.

**4.2 (b) Completeness engines with states (colour, clock).** Two compiled facts license the
design at every class: (1) class validity equals validity over clocked frames (§3.2), so an engine
may WLOG target clocked canonical frames — as the manuscript's own engines do (3823: states
`⟨i, y⟩`); (2) `colourClock` discharges every `FrameOver` field for a finite colour relation over
any `D`. Report 04 §4.2's "frame axioms are not the obstacle" is therefore compiled: the only
obligation left to an engine is the truth lemma (every closure trace of the canonical bundle is the
state trace of a coherent chronicle). Over dense `D` the colour relation must be idempotent
(`R₁ ∘ R₁ = R₁`), which is what `eR_dense` provides for `eR`.

**4.3 (c) Compatibility with the coarsened-state vehicle.** Fully compatible and compiled:
`liftK K` is a coarse model on the product with π ignoring the clock; `c_invariance`;
`pasteClosed_liftK` and its converse; `c_refuted_lift`. The landed countermodel `eK` on `EF`
therefore transfers verbatim to `prodFrame EF.toFibre` (a ℤ-frame with Limit already automatic,
so nothing new is gained there; the value is at dense `D`, §4.1).

### 5. Q5 — What the device cannot do

- **It never refutes anything `F` does not.** `plus_invariance` is a biconditional; the product
  is sound on every translation-closed bundle (559/03 `tw_invariance` in the `ℤ` mirror; the live
  bundle form is the same induction with `liftH`/`projH` restricted to `B × D` — UNVERIFIED live,
  identical proof). Hence it cannot yield the limit-closure schemata: the product of a paste-closed
  non-closed bundle is paste-closed and non-closed (`pasteClosed_liftK`; closedness is a condition
  on pairs of times and transfers the same way).
- **It cannot settle Saturation's contribution** (neutral, `saturation_of_prodRel`) nor
  **determinism's** (neutral, `prodFrame_deterministic_iff`).
- **It leaves the structure of the stability classes untouched.** The projection restricts to a
  bijection `⟨τ'⟩_t → ⟨projH τ'⟩_t` (lifts through a given state have a fixed clock,
  `liftH_through`), so branching degree, the failure of Ockhamist HN (559/04 Part T), the pasting
  axioms, `LC_n`/BLC, and whether a naming rule is needed are exactly as they were.
- **Precisely the questions about `⊡` it leaves untouched**: (i) completeness of TM⁺ plus any
  closure schemata at any class; (ii) whether Saturation adds L⁺-validities (report 04 §4.1);
  (iii) whether any naming rule is needed for completeness; (iv) axiomatizability of L⋆ with `⊡`;
  (v) whether L⁺ separates the `ℚ` bundle of 3074 from saturated bundles. What it *does* settle
  about `⊡` is only state-locality's consequence: `⊡` cannot see whether the present state has
  occurred before or will occur again on any history through it.
- **It cannot be used frame-by-frame** (`frame_validity_not_reflected`): any argument that needs
  frame validity of a *specific* frame to transfer to its product is invalid.

### Recommendations

1. **Port (i): yes, into `FormalSystem`**, in two modules, no new axioms, ~450 lines transcribed
   from probe 01:
   - `FormalSystem/Semantics/Frames/TranslationProduct.lean`: `prodRel`, the six transfer
     theorems (`prodRel_reflection/_comp/_serial/_limit/_saturation`, `saturation_of_prodRel`),
     `FrameOver.translationProduct` (the name; not `× D`), `translationProduct_taskRel`,
     `translationProduct_sat`, `translationProduct_deterministic_iff`, `colourClock`, `liftH`,
     `projH`, `projH_liftH`, `liftH_projH`, `clock_eq`, `no_recurrence`, `no_transposition`, the
     three invariances, `*ValidOn_of_prod`, and `*ValidIn_iff_recurrenceFree`. Docstring must carry
     the standing caveat (proof device; time-unfolding; cite 1764 and 832-937) and the
     frame-level non-reflection example.
   - `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` (or an addendum to
     `PastedCoarseModels.lean`): `liftK`, `c_invariance`, `pasteClosed_liftK`,
     `pasteClosed_of_liftK`, `c_refuted_lift`.
   - Optional third module `Semantics/HistoryMorphism.lean`: `HistMap`, `HistMorphism`,
     `histMorphism_invariance`, `prodProj`, `Clock`, `clockedFactor`, `clockedFactorMorphism`,
     `stateClock_not_joint`. Defer the categorical reading to 618.
   - Probe 02's `zeroFix` results have no live home (no non-Limit frame type exists); keep them
     as the mirror record and cite from the module docstring.
2. **Manuscript (ii): yes, one remark**, placed either after 1030 or at 1764 in the Conclusion:
   the languages `BL`, `BL⁺` and `BL⋆` validate the same sentences over a task frame and over its
   translation product, in which no world history revisits a world state and no two histories
   transpose states; recurrence and transposition are features of the intended models secured by
   the choice of primitives (simulation metasemantics, 921-937), not commitments of the logic;
   the product is the time-unfolding of 1764. This reinforces the paper's stance against the
   abundance theorist (832-937): the abundant models are recovered as *clock-dependent valuations
   on the product*, and the task semantics validates the perpetuity principles precisely because
   its valuations are clock-independent. A second, optional sentence: Limit's contribution to
   validity is nil beyond the zero loops of `lem:nullity`. Cite the repository once the port lands.
3. **For 559 (iii)**: (a) build canonical frames clocked, WLOG at every class and for L⁺ and L⋆;
   (b) treat the truth lemma as the entire problem — no frame axiom is an obstacle for a
   finite-colour engine at any `D`; (c) for the dense BLC countermodel, adopt ordinal budgets and
   attack Saturation of the colour structure directly, then clock; add the `.Dense` form of
   paste-closed soundness; (d) record report 04 §3.3.3 as settled (L⋆ invariance holds);
   (e) use `HistMorphism` as the morphism notion in any future transfer argument, and do not rely
   on relation-level bounded morphisms without an extension step.
4. **For 618**: take §2.4's three questions as an appendix item once `Path(F)` exists; the
   product's path category is the natural test case for the pullback reading.

## Decisions

1. All frame-level results are stated over a **bare relation** first (`section Bare`) so that the
   hypothesis each `FrameOver` field consumes is recorded by the theorem signature, then
   instantiated at `F.TaskRel`; this is what makes the "exactly which hypotheses" answer to Q1
   machine-checked rather than narrated.
2. The morphism notion is split into `HistMap` and `HistMorphism` after the first draft's claim
   "clocked covers factor as morphisms" was found false (`stateClock_not_joint`); the factorization
   is stated at the level it is true.
3. The recurrence-free-but-clockless cover (§2.3) is left on paper: elementary, but ~80 lines of
   `ℤ`-walk bookkeeping that would not change any verdict.
4. The dense BLC countermodel is not attempted: the device removes only Limit, and report 02's
   ordinal-budget Saturation is the genuine remaining work; it is scoped precisely instead.
5. No `user_decision` is raised: every choice above is settled by the artifacts and conventions.

## Risks & Mitigations

- **Risk**: readers take the product for an intended model. **Mitigation**: the standing caveat is
  in the report's scope section, in every conclusion, and prescribed for the port's docstrings.
- **Risk**: the frame-level non-reflection (`frame_validity_not_reflected`) is overlooked and a
  later argument transfers validity of a specific frame to its product. **Mitigation**: named
  theorem in the port with the counterexample; §5 lists it as a prohibition.
- **Risk**: `Classical.choice` in the port's axiom profile is read as Zorn. **Mitigation**: the
  provenance is `limit_of_shift`'s `exists_ne`; the Saturation transfer and the general invariance
  are `[propext, Quot.sound]` only; record in docstrings as `TaskFrame.lean` does.
- **Risk**: the dense countermodel is assumed done because Limit is. **Mitigation**: §4.1 lists the
  three UNVERIFIED items by name.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The probes were written directly against the live
  structures and compiled with `lake env lean`; the only automation used is `abel` for clock
  arithmetic and `simp [zeroFix]` in the mirror, both closing on first try. `lean_multi_attempt`
  and `lean_hammer_premise` were not invoked; no goal in this round called for tactic discovery.

## Context Extension Recommendations

- **Topic**: translation-product / clock-frame device as a standing proof pattern.
- **Gap**: `context/project/lean4/` has no note on "class validity = validity over clocked frames"
  or on the history-lifting-morphism notion; future transfer arguments will re-derive them.
- **Recommendation**: after the port, add a short pattern file under
  `context/project/lean4/patterns/` naming `translationProduct`, `HistMorphism`, the invariance
  theorems, and the two prohibitions (not an intended model; not frame-by-frame).

## Appendix

### A. Probe inventory (both sorry-free; `lake env lean` exit 0, no warnings)

`probes/01_translation-product-live.lean` (777 lines, 53 declarations), imports
`FormalSystem.Semantics.{StarLanguage.StarValidity, PlusLanguage.PlusValidity, Frames.Standard}`,
`FormalSystem.Metalogic.Independence.PastedCoarseModels`:
- Q1: `prodRel`, `prodRel_reflection`, `prodRel_comp`, `prodRel_serial`, `prodRel_limit`,
  `prodRel_const_clock`, `prodRel_fib_image`, `prodRel_seg_image`, `prodRel_saturation`,
  `saturation_of_prodRel`, `colourClock`, `prodFrame`, `prodFrame_taskRel`, `prodFrame_sat`,
  `prodFrame_deterministic_iff`.
- Histories: `liftH`, `projH`, `liftH_state`, `projH_state`, `projH_liftH`, `clock_eq`,
  `liftH_projH`, `prod_no_recurrence`, `prod_no_transposition`, `liftH_through`.
- Q3: `liftM`, `truth_invariance`, `plus_invariance`, `star_invariance`, `RecurrenceFree`,
  `prodFrame_recurrenceFree`, `plusValidOn_of_prod`, `starValidOn_of_prod`, `validOn_of_prod`,
  `plusValidIn_iff_recurrenceFree`, `validIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`,
  `p₀`, `frame_validity_not_reflected`.
- Q2: `HistMap`, `HistMorphism`, `HistMap.mapH`, `HistMap.pullM`, `HistMorphism.surj_of_occurs`,
  `histMorphism_invariance`, `prodProj`, `Clock`, `prodClock`, `clockedFactor`,
  `clockedFactor_fst`, `clockedFactor_snd`, `clockedFactorMorphism`, `stateClock`,
  `stateClock_not_joint`.
- Q4(c): `liftK`, `c_invariance`, `pasteClosed_liftK`, `pasteClosed_of_liftK`, `c_refuted_lift`.
- Axiom profiles (`#print axioms`): `prodRel_saturation`, `saturation_of_prodRel`,
  `histMorphism_invariance` — `[propext, Quot.sound]`; all others — `[propext, Classical.choice,
  Quot.sound]` via `limit_of_shift` (no Zorn anywhere).

`probes/02_limit-idle-mirror.lean` (152 lines, Mathlib only): `Hist`, `zeroFix`, `zeroFix_zero`,
`zeroFix_ne`, `hist_zeroFix_iff`, `Fm`, `TD`, `TD_zeroFix`, `clockP`, `RrD`, `LimitD`,
`clock_limit` (reproduced from 559/04), `zeroFix_limit_clocked`.

### B. UNVERIFIED items, by name

1. Relation-level back clause plus Saturation of `F'` implies history-level `lift` (§2.2).
2. `lift` implies relation-level back given `thm:extension` (§2.2; routine).
3. The recurrence-free clockless cover of §2.3 (elementary; not needed for any verdict).
4. Live bundle form of the invariance (translation-closed `B ⊆ H_F`), §5.
5. Saturation of the ordinal-budget colour structure over dense `D` (§4.1).
6. `.Dense`/`.RTime` form of `plus_pcValid_and_reflect_time` (§4.1).
7. Paste-closure of the ordinal-budget product coarse model over dense `D` (§4.1).
8. The `StarTruthAt` analogue of probe 02 (Limit idle for L⋆; same induction).
9. The `ℚ` bundle of 3074 is the bundle of no saturated frame (§3.3.3; paper).

### C. Manuscript line index used in this report

557-942 Primitive Worlds (646-648, 699-704, 722-725 recurrence/transposition motivation; 832-937
abundant models; 921-937 simulation metasemantics); 943-1216 Possible Worlds (949-951, 991, 1005,
1025-1030, 1039-1050, 1153-1162, 1210); 1352-1471 Extensions (1455, 1456-1466); 1472-1660 (1517,
1523, 1530-1534, 1577-1583, 1626); 1659-1860 (1663-1671, 1764, 1775); 2811-3904 appendix (2821,
2834-2846, 2852, 2866, 2881-2920, 2926, 3038, 3056, 3070-3074, 3128, 3171-3220, 3232, 3254-3262,
3537, 3544, 3559, 3720-3748, 3755-3770, 3823, 3832); 4047, 4063 (commented out).

### D. Searches

No Mathlib search tools were needed: every lemma used (`limit_of_shift`, `saturation_of_finite`,
`ofReflective`, `ofTotal`, `ext_state`, `mem_Fib`, `sub_add_cancel`, `add_left_cancel`,
`lt_trichotomy`, `add_lt_add`, `exists_pos_of_nontrivial`) was located by `grep` in the repository
or is standard Mathlib.
