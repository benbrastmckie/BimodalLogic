# Research Report: Task #653

**Task**: 653 - What sees recurrence and transposition in a task frame: state registers, state nominals, since/until, and the stability modal (verdict-first)
**Started**: 2026-09-22T16:16:08Z
**Completed**: 2026-09-22T16:40:00Z
**Effort**: ~25 minutes of agent time; three compiled probes (568 lines, 26 declarations, sorry-free), one report
**Dependencies**: The translation-product port (`FormalSystem/Semantics/Frames/TranslationProduct.lean`, delivered) and, read as established, the hybrid/quantifier port (`FormalSystem/HybridLanguage/`, `FormalSystem/QuantLanguage/`, `Semantics/HistoryMorphism.lean`, delivered by task 628 after the originating report was written). Task 624 is related, not blocking.
**Sources/Inputs**: - Library (read, not modified): `Semantics/Frames/TranslationProduct.lean` (`prodRel_*`, `liftH`/`projH`, `liftH_through`, `clock_eq`, `liftH_projH`, `no_recurrence`, `no_transposition`, `truth_invariance`, `plus_invariance`, `star_invariance`, `*ValidOn_of_prod`, `*ValidIn_iff_recurrenceFree`, `frame_validity_not_reflected`, `FrameOver.translationProductProj`), `Semantics/HistoryMorphism.lean` (`HistMap`, `HistMorphism`, `TaskFrame.RecurrenceFree`, `exists_sat_not_recurrenceFree`), `HybridLanguage/{Formula,HybridTruth,HybridValidity,HybridInvariance,HybridRecurrence,HybridTransposition}.lean` and `README.md`, `QuantLanguage/QuantRecurrence.lean` and `README.md`, `OpenLanguage/{OpenTruth,OpenValidity,OpenClasses}.lean` and `README.md`, `StarLanguage/StarTruth.lean`, `PlusLanguage/{PlusLimitClosure,PlusPasting}.lean`, `Metalogic/Independence/{README.md,StateSetTruth,OrderTransfer,DeterminismUndefinable,TranslationProductCoarse,LimitClosureCountermodel,LimitClosureFrame}.lean`, `Syntax/Formula.lean`, `Semantics/Truth.lean`. - Prior reports (read as established, not redone): `specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md`; `specs/628_expressive_extensions_recurrence_visibility/reports/01_expressive-extensions-recurrence.md` and `summaries/01_expressive-extensions-recurrence-summary.md`; `specs/559_.../reports/04_semantics-first-task-frames.md` (for `LC_n`, cited by name only) and `probes/03_morphisms-clock-rule-lc-schema.lean` (`lcN`, a ℤ-mirror definition). - Manuscript `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, read at `sub:WorldStates`, `sub:AbsoluteTime`, `sec:Construction`, `sub:RestrictedModalities`, `sub:Extension`, `sub:OpenFuture`, `sub:DynamicalSystems`, `sub:Conclusion`, `app:TaskSemantics` (`def:frame`, `lem:nullity`), `def:BLstar-semantics`, `app:drift`, `cor:no-characterization`. Cited below by label or quotable phrase only. - Literature, held in `~/Projects/Literature/sources/`: Venema 2001 (`venema_2001/sec03_since-and-until.md`, Theorem 4.1 (Kamp)); Venema 1993 (`venema_1993_since/sec01_...md`, verified conversion, the IR-rule discussion); Blackburn-de Rijke-Venema 2002 (`blackburn_2002/ch07_since-until-hybrid.md`, unverified scan, §7.3 p. 437). Not held, labelled *recalled* where used: Areces-Blackburn-Marx 2000, Blackburn & ten Cate 2006, ten Cate 2006, Kamp 1968's original (held as `kamp_1968_tense-logic-linear-order` but not re-read; the Venema statement is used). - Probes written this round (all sorry-free, `lake env lean` exit 0): `probes/01_invariant-languages-blind.lean`, `probes/02_nominals-break-product.lean`, `probes/03_limit-closure-device.lean`.
**Artifacts**: - `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md` (this report) - `specs/653_what_sees_recurrence_language_extensions/probes/01_invariant-languages-blind.lean` - `specs/653_what_sees_recurrence_language_extensions/probes/02_nominals-break-product.lean` - `specs/653_what_sees_recurrence_language_extensions/probes/03_limit-closure-device.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The question is already half-settled in the library, and the settled half is decisive.**
  Between the originating report and this dispatch, task 628 landed `FormalSystem/HybridLanguage/`
  and `FormalSystem/QuantLanguage/`: a single *state* register (a state nominal when free, the
  binder `↓ᵢ` when bound) makes recurrence visible — `¬(i ∧ (P i ∨ F i))` is valid on a frame iff
  the frame is recurrence-free (`recF_defines`, `bindRec_defines`) — and transposition with it
  (`transF_defines`; `recurrenceFree_not_transposed`: any transposition forces a recurrence).
  Standard propositional quantifiers do the same by manufacturing the nominal (`qRec_defines`).
  This report takes those as established and answers what they leave open.
- **Verdict Q1 (stability modal): blind, and provably so for every morphism-invariant language.**
  The one theorem behind all the blindness results is compiled abstractly:
  `classValid_iff_recurrenceFree_of_prodInvariant` — for ANY semantics invariant along the
  translation projection, class validity equals validity over the recurrence-free members. The
  clause of the `⊡` semantics the product respects is exact: the projection restricts to a
  *bijection* `⟨τ'⟩_t → ⟨projH τ'⟩_t` (`stabClass_lift_unique`). New instances compiled: the
  manuscript's open-future/open-past modals (`open_invariance`, `openValidIn_iff_recurrenceFree`)
  and the same-state modality `[≡]` at class level (`regFreeValidIn_iff_recurrenceFree`, the
  corollary 628 left unformalized). No L⋆ sentence, and no sentence of L⁺ + `⊡` + `▷` + `◁` +
  `[≡]` + time registers, is valid on a product yet refuted on its base. World registers: blind
  by the same induction (paper, UNVERIFIED — no world register exists in the tree).
- **Verdict Q2 (state registers/nominals): visible, and the clock breaks the naming both ways.**
  The product of any frame validates the recurrence and transposition formulas
  (`recF_valid_product`, `transF_valid_product`); a frame with recurrence refutes them
  (`recF_separates`, `transF_separates`, concretely `recF_separates_trivial`). The exact failure
  point is the register clause (`reg_not_prodInvariant`: no base register vector makes `reg 0`
  invariant). In the hybrid language, frame-level validity of a frame and its product are
  *incomparable* (`hybridValidOn_incomparable`), whereas in L⁺ the product validates a subset.
  **Cost, sharpened**: state nominals still do not see determinism — `F°` and `F¹` validate the
  same hybrid sentences (`fzero_hybridValidOn_iff_f1`, `deterministic_not_hybridDefinable`),
  by a state-set recursion `hsatSet` extended to `[≡]`, registers and the binder. Only time
  registers separate that pair. So "state nominals" and "time registers" see disjoint features.
- **Verdict Q3 (since/until): blind, more strongly than expected.** The `□`-free fragment is
  invariant along ANY history-lifting *map* — neither `onto` nor `lift` is consulted
  (`boxFree_histMap_invariance`, axioms `[propext]` only): `U`/`S` read one history's monadic
  structure `(D, <, |p| ∘ τ)`, and the projection is an isomorphism of that structure. By Kamp's
  theorem (Venema 2001 Thm 4.1, held) the same holds of every first-order-definable temporal
  operator over ℤ- and ℝ-time (paper).
- **Verdict Q4 (limit closure):** the one limit-closure schema in the live tree is `blc p`
  (`PlusLimitClosure.lean`; `LC_n` exists only as `lcN` in 559's ℤ-mirror probe). The product
  keeps the coarse countermodel and its paste-closure (`blc_cRefuted_product`,
  `liftK_eK_pasteClosed`). A device that could yield `blc` must not be a morphism of bundles at
  all: it must add the limit histories — it must be the Extension Theorem, i.e. a completeness
  construction targeting *closed* bundles.
- **Verdict Q5 (manuscript):** yes, the motivation outruns expression, in `sub:WorldStates`
  ("supposing that history never repeats itself is a substantive assumption which should not be
  built into the semantics"), `sec:Construction` ("nothing prevents a world state from occurring
  at many times in a single history"; "as in chess games which transpose move order") and
  `sub:Conclusion` ("recovered by unfolding the transitions that the task relation permits");
  and none of `BL`, `BL` + `⊡`, `BL⋆`, or the world registers of `sub:Extension` can say so. It
  is not an error: the simulation metasemantics of `sub:AbsoluteTime` and its Cresswell footnote
  ("includes no such selective devices") already take the stance. One remark merits adding, at
  `sub:Conclusion`'s unfolding sentence, with the repository now supplying both halves
  (`plusValidIn_iff_recurrenceFree` and `recF_defines`). Draft text in §5.
- **Recommendations**: (i) no new extension needs study for *visibility* — the hybrid state
  language (`HybridLanguage/`) is the answer and should keep that name; the one worthwhile
  follow-up is a small port of probes 01-02 (~350 lines: the meta-theorem, the stability
  bijection, L^▷ invariance, the `[≡]` class corollary, `hsatSet` and
  `deterministic_not_hybridDefinable`); (ii) yes, the manuscript merits the recurrence remark;
  (iii) the completeness research may WLOG use clocked canonical frames for every language
  *without* state nominals, and must not once they enter; nominals help neither with closure
  nor with determinism.

## Context & Scope

The originating report (624) compiled that L, L⁺ and L⋆ validate exactly the same sentences over a
task frame class and over its recurrence-free members, via the translation product — a proof
device, never an intended model (`TranslationProduct.lean`'s standing caveat, restated here for
every conclusion). Its Q5 recorded the device as silent on the stability modal beyond
state-locality and unable to yield the limit-closure schemata. This dispatch asks for the
complement: which extension, if any, sees recurrence or transposition, and at what cost.

Since that report, task 628 delivered `HybridLanguage/` (L⁺ + `[≡]` + state registers + `↓`),
`QuantLanguage/` (L + `∀p`) and `HistoryMorphism.lean`, and the port of 624 delivered
`translationProductProj : HistMorphism F.translationProduct F`. The two halves of "class validity
= recurrence-free validity for L⁺ + `[≡]`" were both compiled but never composed; the open-future
language `OpenLanguage/` was never tested against the product; the stability-class structure the
product respects was described in prose only; and whether nominals buy *more* than recurrence
(determinism, say) was not asked. Those are the gaps filled here.

Constraints honoured: every invariance or separation below names a compiled, sorry-free
declaration of `probes/0{1,2,3}_*.lean` (namespace `Probe653`) or a landed library theorem, or
carries the label UNVERIFIED; manuscript claims cite a `\label` or a quotable phrase, never a
line number; literature claims are *held* (with the corpus file) or *recalled*; no file under
`FormalSystem/` or `Tests/` is changed; no sorry, no new axiom (profiles in Appendix A). The
Literature Extraction Protocol is not invoked: no source is transcribed as a proof.

Column names, since the dispatch's table lists "L, L⁺, L*, L* with the stability modal, L with
nominals, L with since/until": in the tree L already contains since/until (`Formula.untl`,
`Formula.snce`; `sec:Construction` takes them as primitive), L⁺ = L + `⊡`, and L⋆ = L⁺ + time
registers, so L⋆ already carries the stability modal. The table in §3 therefore uses the tree's
languages — tense-only fragment, L, L⁺, L^▷, L⋆, L⁺ + `[≡]`, L⁺ + state nominals/registers,
L + `∀p` (standard) — and says which dispatch column each answers.

## Findings

### Codebase Patterns

- `TaskFrame` is `⟨Duration, toFibre⟩` with `G.toFibre.toTaskFrame` definitionally `G`; the
  class-level theorems of `TranslationProduct.lean` exploit this by applying a `FrameOver`
  result to `G.toFibre`. The abstract meta-theorem of probe 01 follows the same three lines.
- `translationProductProj F` has `toFun := Prod.fst`, so `g.pullM M` is `liftModel F M` and
  `g.mapH τ'` is `projH F τ'` up to proof irrelevance; `regFree_invariance` instantiates at it
  without any transport (`regFree_prod_invariance`).
- `HistMorphism.lift` fixes one time; it is enough for `⊡` and `[≡]` but not for `▷`/`◁`, whose
  clauses need a lift agreeing on a whole ray. The product supplies that stronger lift
  (`state_eq_lift`: every product history is the lift of its projection at its own offset), so
  `open_invariance` is a fact about the product, not about `HistMorphism` in general.
- `Independence/StateSetTruth.lean`'s recursion extends to `HybridFormula` by threading the
  register vector: `same` and `stab` are the identity on state sets, `reg i` is `{w | w = r i}`,
  `bind i` updates `r` at the present state. The bridge proof is the landed one plus three
  one-line cases; `[propext]` alone.
- No world register (`↑ᵢ`/`↓ᵢ` over histories) exists anywhere in the tree (`OpenLanguage/README`
  and `HybridLanguage/README` both record the exclusion); every claim about them is paper.

### External Resources

- Manuscript passages (label / quotable phrase): `sub:WorldStates` — "supposing that history
  never repeats itself is a substantive assumption which should not be built into the
  semantics"; "there are systems which we may wish to study that admit loops in their
  evolution"; "Since the position-marker and the configuration are one and the same, no
  configuration can occupy two positions". `sec:Construction` — "nothing prevents a world state
  from occurring at many times in a single history"; "as in chess games which transpose move
  order"; "it is by specifying a time x in a history τ that we may determine which world states
  occur before or after x in τ"; "Kamp showed, since and until are expressively complete over
  Z-time and R-time". `sub:AbsoluteTime` — simulation metasemantics: "the intended models of a
  language ... provide an idealization that simulates what that object language is able to
  express"; Cresswell footnote: "The bimodal language BLK includes no such selective devices";
  "even if BLK were enriched with such devices". `sub:RestrictedModalities` — the `⊡` clause and
  its footnote ("the monomodal logic of ⊡ is also S5"); the open-future/open-past clauses;
  "I will omit further consideration of the restricted modals". `sub:Extension` — "lack the means
  by which to cross reference either times or worlds"; the four register clauses; "outside the
  scope of the present paper". `sub:OpenFuture` — `sent:det`, the footnote "the store and recall
  operators discriminate between F° and F¹ where cor:no-characterization shows that no sentence
  without them can". `sub:Conclusion` — "the branching tree of states is not posited but may be
  recovered by unfolding the transitions that the task relation permits"; the footnote
  "Definability is recovered once the store and recall operators are added". `def:frame`,
  `lem:nullity`, `def:BLstar-semantics`, `app:drift`, `cor:no-characterization`.
- Held literature: Venema 2001 §4 (Theorem 4.1 (Kamp): "Over the class of linear, continuous
  orderings, every temporal operator can be defined in L_su", "temporal operator" = any operator
  with a first-order truth definition); Venema 1993 §1 (the IR rule "can be seen as a break with
  the paradigm in modal logic not to use symbols referring to worlds/time points" — the same
  break a state nominal makes, for states); Blackburn-de Rijke-Venema 2002 §7.3 p. 437
  ("Hybrid languages treat states as first class citizens ... use one sort of atom — the
  nominals — to refer to states"; unverified scan). Recalled: Areces-Blackburn-Marx 2000
  (hybrid tense logic over linear frames), Blackburn & ten Cate 2006 (pure extensions and
  proof rules), ten Cate 2006 (SOPML vs hybrid).
- Landed results relied on: `plusValidOn_of_prod`, `frame_validity_not_reflected`,
  `translationProduct_recurrenceFree`, `translationProduct_sat`, `regFree_invariance`,
  `recF_defines`, `transF_defines`, `qRec_defines`, `standard_not_invariant`,
  `plusTruthAt_iff_mem_satSet`, `deterministic_not_plusDefinable`,
  `star_discriminates_where_plus_cannot`, `blc_plusValid`, `blc_cRefuted`, `eK_pasteClosed`,
  `c_refuted_lift`, `pasteClosed_liftK`, `plus_incomplete_base`.

### 1. Q1 — the stability modal and every morphism-invariant language

**1.1 The general theorem (compiled).** `classValid_iff_recurrenceFree_of_prodInvariant`: for any
`S : (G : TaskFrame) → TaskModel G → WorldHistory G → G.Duration → Prop` such that
`S (F.translationProduct) (liftModel F M) τ' t ↔ S F M (projH F τ') t` for every `F`, `M`, `τ'`,
`t`, and every `FrameClass` tag `fc`,
`(∀ G, fc.Sat G → ∀ M τ t, S G M τ t) ↔ (∀ G, fc.Sat G ∧ G.RecurrenceFree → ∀ M τ t, S G M τ t)`.
The proof is the three lines of `plusValidIn_iff_recurrenceFree` with the language abstracted
away. So the answer to "can ANY morphism-invariant language see recurrence" is **no, at the
level of a frame class**, and the single hypothesis that matters is invariance along the
projection for lifted models. The landed L⋆ theorem is re-derived as an instance
(`starValidIn_iff_recurrenceFree'`), as are the two new languages below.

**1.2 Which clause of the stability semantics the product respects (compiled).**
`stabClass_lift_unique`: for a product history `τ'`, a time `t`, and any history `σ` of `F` with
`σ(t) = (projH τ')(t)`, there is exactly one product history `σ'` with `σ'(t) = τ'(t)` and
`projH σ' = σ` — the lift of `σ` at the offset `(τ'(t)).2 - t`; uniqueness is `liftH_projH`
plus `clock_eq`. With `projH_mem_stabClass` (the easy direction), the projection restricts to a
bijection `⟨τ'⟩_t → ⟨projH τ'⟩_t` of `def:BLstar-semantics`'s stability classes. That is the
whole content of the `⊡` case of `plus_invariance`/`star_invariance`: the product respects the
*membership* of the stability class (through the `lift` clause of `HistMorphism`) and even its
cardinality, and leaves its internal structure — branching degree, pasting, closure — untouched.
The originating report's Q5 prose ("the projection restricts to a bijection") is now a theorem.

**1.3 Is there any sentence whose validity separates a frame from its product?** Two answers,
both compiled:
- *In the direction that would detect recurrence — valid on the product, refuted on the base —*
  **no**, for L, L⁺, L⋆ (`validOn_of_prod`, `plusValidOn_of_prod`, `starValidOn_of_prod`), for
  L^▷ (`open_invariance` plus the same three lines), and for L⁺ + `[≡]`
  (`regFree_prod_invariance`).
- *In the reverse direction* **yes**, already landed: `p → Gp` is valid on the one-state frame
  and refuted on its product (`frame_validity_not_reflected`). This does not witness recurrence;
  it witnesses that the product admits clock-dependent valuations (the manuscript's abundant
  two-dimensional models of `sub:AbsoluteTime`). Any language containing L inherits this
  reverse separation; it is why every positive statement is made over a frame *class*.

**1.4 The open-future and open-past modals (compiled, new).** `open_invariance F M φ τ' t :
OpenTruthAt (liftModel F M) τ' t φ ↔ OpenTruthAt M (projH F τ') t φ` for every `OpenFormula`,
and `openValidIn_iff_recurrenceFree fc φ`. The `▷` case: a history `ρ` of `F` agreeing with
`projH τ'` up to `t` lifts at `τ'`'s own offset to a history agreeing with `τ'` up to `t`
(`state_eq_lift`), and conversely agreement of product histories projects. This is *not* an
instance of `HistMorphism` invariance (whose `lift` is at one time); it uses the product's
uniqueness of lifts. So the Ockhamist historical-necessity operator of this semantics
(`OpenLanguage/README`: "the operator of this semantics that corresponds to historical necessity
is therefore ▷") is as blind as `⊡`.

**1.5 The same-state modality at class level (compiled, new).**
`regFreeValidIn_iff_recurrenceFree fc φ (hφ : φ.RegFree)`: `HybridValidIn fc φ ↔
HybridValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ`. This is the row
`HybridLanguage/HybridInvariance.lean` and `README.md` list as "Not formalized — needs, for every
frame of a class, a history-lifting morphism onto it from a recurrence-free frame of the same
class"; `translationProductProj` is that morphism and the composition is now compiled.

**1.6 The manuscript's fuller language.** The manuscript's own extensions of `BL` are `⊡`
(`sub:RestrictedModalities`), `▷`/`◁` (same section), the nomic operator (four-place task
relation; no formalization), and the time and world registers (`sub:Extension`). Verdicts: `⊡`,
`▷`, `◁`, time registers — blind, compiled (1.1-1.5, `star_invariance`). World registers —
blind, **UNVERIFIED**: the induction is the `timeStore`/`timeRecall` one with the stored-history
vector mapped by `projH` and lifted by `liftH _ 0` (628 §1.3); no world register is in the tree
to state it against. Nomic operator — out of scope (no semantics in the tree; on paper, a
four-place relation `⇒^w` products in the same way, so blind). Hence **none of the manuscript's
own operators sees recurrence or transposition**, and the same-state modality, the nearest
nameless operator, does not either.

### 2. Q2 — state registers and nominals against the product

**2.1 Settled by 628 (established).** `recF_defines G i : G.HybridValidOn (recF i) ↔
G.RecurrenceFree`; `bindRec_defines` for the register-closed `↓ᵢ ¬(i ∧ (P i ∨ F i))`;
`transF_defines G : G.HybridValidOn (transF 0 1) ↔ G.RecurrenceFree`, with
`transF_refuted_distinct` showing the two registers need not name one state;
`recF_not_validIn`, `transF_not_validIn` at every tag. The minimal resource is a state-identity
test across two times of one history (`HybridRecurrence.lean`, "The minimal resource").

**2.2 Against the product (compiled, new).** The dispatch asks whether "the product of a frame
with nominals still validates the same nominal sentences, or does the clock reading break the
naming". It breaks:
- `recF_valid_product F i` and `transF_valid_product F`: the product of *any* frame validates
  both formulas at every register vector, because it is recurrence-free
  (`translationProduct_recurrenceFree`).
- `recF_separates F (h : ¬ F.RecurrenceFree) i` and `transF_separates`: the product validates,
  the base refutes. `recF_separates_trivial` instantiates this at the one-state frame over any
  temporal order (single nominal); `transF_separates` is the universal-modality form (`E` inside
  `transF`).
- `reg_not_prodInvariant`: the precise point of failure. On the one-state frame with the product
  register `r' 0 := ((), 0)`, `reg 0` holds at the lifted constant history at time `0` and fails
  at any positive time (the clock reads `x ≠ 0`), while the projected history is constant and
  `reg 0` on the base is `() = r 0`, true or false uniformly in `t`. So no base register vector
  reproduces the product's register clause: a nominal on the product names `(w, e)`, a clocked
  state, and "the state named by `i` again, later" is false there by construction.
- `hybridValidOn_incomparable`: in the hybrid language, frame-level validity of a frame and its
  product are incomparable — the product validates `recF 0` which the one-state frame refutes,
  and the one-state frame validates `ofPlus (p → Gp)` which the product refutes. Contrast L⁺,
  where the product validates a *subset* (`plusValidOn_of_prod` plus
  `frame_validity_not_reflected`). This is the cleanest statement of "the device is unusable
  once nominals enter": neither direction of transfer survives.

**2.3 Cost, sharpened: what state nominals still cannot see (compiled, new).** The drift frame
`F°` (`app:drift`) and the translation flow `F¹` (`cor:no-characterization`) are both
recurrence-free, so the recurrence formulas do not separate them; the question is whether any
hybrid sentence does. **No**: `hsatSet` extends `satSet` to `HybridFormula` with a threaded
register vector; `hybridTruthAt_iff_mem_hsatSet (h1 : OrderFlow F) (h2 : StateOccurs F)` is the
bridge (`[propext]` alone); `hybridValidOn_iff_hsatSet_univ`; `fzero_hybridValidOn_iff_f1 φ :
F0.HybridValidOn φ ↔ F1.HybridValidOn φ`; and `deterministic_not_hybridDefinable`: no set of
hybrid sentences defines the deterministic frames. The reason is the one the manuscript gives
for `⊡` in `sub:OpenFuture` — over a flow, truth depends on the state alone — and the three new
clauses are state-local by their very definition (`reg i` compares the present state with a
stored one; `bind i` stores it; `[≡]` ranges over pairs at it). So:

- state nominals see **recurrence and transposition** (properties of *which* states a history
  visits) and not **determinism** (a property of *how many* successors a state has at a
  duration);
- time registers see **determinism** (`star_discriminates_where_plus_cannot`, `sent:det`) and not
  **recurrence** (`star_invariance`).

The two extensions are orthogonal, and the manuscript's `sub:Conclusion` footnote ("Definability
is recovered once the store and recall operators are added") is exactly right about determinism
and silent about recurrence.

**2.4 Cost to the manuscript's design (paper, from 628 §4-5, unchanged).** A state nominal is
a nominal for the quotient of (history, time) pairs by the same-state relation, not for points:
`A(i → ·)` and `E(i ∧ ·)` are not dual, NAME is sound, PASTE pastes `⊡`-theories only, and
Blackburn-de Rijke-Venema's automatic completeness for pure axioms (§7.3, held-unverified scan)
does not transfer because the target must be a task frame with total histories over a group. It
is Cresswell's "selective device" (`sub:AbsoluteTime` footnote) and, in Venema 1993's words about
IR (held), "a break with the paradigm in modal logic not to use symbols referring to
worlds/time points" — here, to states. Decidability/axiomatizability over each tag remain
UNVERIFIED as 628 scoped them; nothing here changes that.

### 3. Q3 — since and until

**3.1 Verdict: blind, without even `onto` (compiled, new).** `BoxFree : Formula → Prop` is the
since/until fragment (Booleans, `U`, `S`; no `□`). `boxFree_histMap_invariance (g : HistMap F' F)`:
for every box-free `φ`, `TruthAt (g.pullM M) τ' t φ ↔ TruthAt M (g.mapH τ') t φ`, axioms
`[propext]` only. The proof never uses `onto` (needed for `□`) nor `lift` (needed for `⊡`): the
`untl`/`snce` clauses quantify over the times of the one history of evaluation, and `mapH` keeps
the times and pulls back the valuation. `boxFree_prod_invariance` is the instance at the
projection. Hence no since/until sentence — indeed no since/until sentence *combined with* `□`,
by `truth_invariance` — distinguishes a frame from its product, checked against the live
clauses of `Semantics/Truth.lean`.

**3.2 Why, in the manuscript's own terms.** `sec:Construction`: "the semantics for `\since` and
`\until` quantifies over times in `D`" — the clauses see a history only as the monadic structure
`(D, <, z ↦ [τ(z) ∈ |p_i|])`, and the projection is an isomorphism of that structure
(`projH_state` is `rfl`; the valuation ignores the clock, `liftModel`). By Kamp's theorem (Venema
2001 Theorem 4.1, held: over linear continuous orders every first-order-definable temporal
operator is `L_su`-definable; the manuscript's `sec:Construction`: "since and until are
expressively complete over Z-time and R-time") the same blindness holds of *every* first-order
temporal operator over ℤ- and ℝ-time, not only of `U`/`S` (paper, immediate from 3.1's mechanism).
The manuscript's remark that `TM` "owes its strength" to since/until (`sec:Construction`: "greater
expressive power than P and F") concerns the order type of truth sets along a history, which the
product preserves exactly; strength of that kind is orthogonal to recurrence.

**3.3 Relation to the tense-only fragment work.** The dispatch notes the H/G-fragment is finitely
axiomatizable at every class (sibling task 651, in progress; not verified here). 3.1 adds: that
fragment, and its `U`/`S` strengthening, are blind along every history-lifting map, so any
axiomatization of them is automatically an axiomatization over the recurrence-free (clocked)
frames of the class, and conversely.

### 4. Q4 — the limit-closure schemata

**4.1 Which schemata, exactly, in the live tree.** One: `blc p := (⟐Fp ∧ ⊡G(p → ⟐Fp)) →
⟐(Fp ∧ G(p → Fp))` (`PlusLanguage/PlusLimitClosure.lean`), valid over every task frame by Zorn
plus the Extension Theorem (`blc_plusValid`, through `PartialHistory.exists_maximal_of_chainClosed`),
and not a Base theorem of TM⁺ (`blc_not_plusDerivable_base`, `plus_incomplete_base`) by the
paste-closed coarse model `eK` on `EF` (`LimitClosureCountermodel.lean`: `π`-images exactly the
eventually-false sequences, closed under splicing, not under limits). The family `LC_n` of 559's
reports exists only as `lcN` in `specs/559_.../probes/03_morphisms-clock-rule-lc-schema.lean`
(a ℤ-mirror `Fm`, not the live `PlusFormula`) and has no counterpart under `FormalSystem/`. The
vehicle is `CoarsenedModels.lean` (`CoarseModel`, `CTruthAt`, `SameUnder`) with
`PastedCoarseModels.lean`'s `PasteClosed` and `plus_pcValid_and_reflect_time` (soundness of all of
TM⁺ at Base for paste-closed coarse models), lifted to the product by
`TranslationProductCoarse.lean` (`liftK`, `c_invariance`, `pasteClosed_liftK`, `c_refuted_lift`).

**4.2 The product keeps the countermodel (compiled).** `blc_cRefuted_product p τ t :
¬ CTruthAt (liftK EF.toFibre eK) (liftH _ τ 0) t (blc p)` and `liftK_eK_pasteClosed`. So on the
recurrence-free, Limit-for-free product of `EF` the coarse countermodel is intact and still
paste-closed: the device preserves exactly the hypotheses the incompleteness argument needs and
removes none. Since `blc` is *standardly* valid on the product (it is a task frame,
`blc_plusValid`), the gap between coarse and standard truth is untouched by the product.

**4.3 What a device that could yield `blc` would have to break.** Read off `c_invariance`'s
`stab` case: coarse truth transfers along any map of bundles that (a) is onto histories, (b) lifts
a history through a state at the present time, and (c) pulls back the coarsening. Any such device
carries a paste-closed non-closed bundle to a paste-closed non-closed bundle and therefore
preserves `blc`-refutations. A device that yields `blc` must fail one of (a)-(c) — i.e. it must
not be truth-preserving on bundles — or must target only *closed* bundles, which is to say it
must *add* the limit histories the Extension Theorem adds (`exists_maximal_of_chainClosed`). That
is a completeness construction, not a morphism: the closure of the canonical bundle remains the
entire problem, exactly as 624 §5 and 559/04 concluded. Nominals do not help either: they name
states, and (2.3) they see nothing about the branching that closure concerns.

### 5. Q5 — the manuscript

**5.1 Where motivation outruns expression.** The primitives are motivated by recurrence and
transposition in three places: `sub:WorldStates` ("supposing that history never repeats itself is
a substantive assumption which should not be built into the semantics"; "there are systems which
we may wish to study that admit loops in their evolution"; the diagnosis "no configuration can
occupy two positions"), `sec:Construction` ("nothing prevents a world state from occurring at many
times in a single history"; "as in chess games which transpose move order"), and `sub:Conclusion`
("the branching tree of states is not posited but may be recovered by unfolding the transitions
that the task relation permits"). The object languages the manuscript defines — `BL`, `BL` + `⊡`,
`BL` + `▷`/`◁`, `BL⋆` with time and world registers — validate the same sentences over any task
frame class and over its recurrence-free members (§1, `*ValidIn_iff_recurrenceFree`,
`openValidIn_iff_recurrenceFree`; world registers UNVERIFIED). The unfolding of `sub:Conclusion`
is the translation product, and it is invisible.

**5.2 Whether this is a problem.** No. `sub:AbsoluteTime` states the simulation metasemantics
("the intended models ... simulate what that object language is able to express") and its
Cresswell footnote already anticipates the point: "The bimodal language BLK includes no such
selective devices", and "even if BLK were enriched with such devices, I do not follow Cresswell
in taking semantics to be any guide to ontological commitment". Recurrence and transposition are
features the primitives *secure* (the histories exist), not commitments the logic *expresses*.
The repository now supplies the missing half of that stance: the enrichment that does express
them is a *state* register (`recF_defines`), not the time or world registers of `sub:Extension`
("lack the means by which to cross reference either times or worlds" — true, and after adding
them the language still cannot cross-reference *states*).

**5.3 Whether a remark merits adding, where, and with what evidence.** Yes, one remark. Best
location: `sub:Conclusion`, immediately after the unfolding sentence, since the unfolding is what
the languages cannot see; alternative: `sec:Construction` after "it is by specifying a time x in
a history τ that we may determine which world states occur before or after x in τ". Draft:

> Although the possible worlds may revisit a world state and may pass through the same world
> states in different orders, the languages `BL`, `BL` with `⊡`, and `BL⋆` cannot express either:
> over any class of task frames each validates exactly the sentences it validates over the
> frames whose possible worlds never revisit a world state, as the Lean 4 repository shows by
> unfolding each frame along an absolute clock. Recurrence and transposition are secured by the
> choice of primitives rather than asserted by the logic, as the simulation metasemantics of
> §`sub:AbsoluteTime` intends; a register that stores a *world state*, rather than a time or a
> world, is the least addition that expresses them, `↓ᵢ ¬(i ∧ (P i ∨ F i))` being valid exactly
> over the frames free of recurrence.

Evidence to cite from the repository: `validIn_iff_recurrenceFree`,
`plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`
(`Semantics/Frames/TranslationProduct.lean`) for the blindness; `recF_defines`, `bindRec_defines`,
`transF_defines` (`HybridLanguage/`) for the visibility; optionally
`deterministic_not_hybridDefinable` (probe 02, once ported) beside the existing footnote on
`sent:det` to say that state registers and time registers see disjoint features. The remark
touches no theorem and no definition of the paper.

### 6. Table — frame features against languages

"Invisible" = class validity is unchanged by adding or removing the feature (the recurrence-free
members validate the same sentences as the class). "Visible" = some sentence's validity on a
frame tracks the feature. Dispatch columns: "L" = L; "L⁺" = L⁺; "L*" and "L* with the stability
modal" = L⋆ (which contains `⊡`); "L with nominals" = L⁺ + state nominals/registers; "L with
since/until" = the tense-only (`□`-free) fragment of L, and L itself. L^▷, L⁺ + `[≡]` and
L + `∀p` are added because the tree has them.

| Feature | tense-only (U/S, no □) | L | L⁺ (+⊡) | L^▷ (+▷,◁) | L⋆ (+time registers) | L⁺ + [≡] | L⁺ + state nominals / ↓ | L + ∀p (standard) |
|---|---|---|---|---|---|---|---|---|
| Recurrence | invisible (`boxFree_histMap_invariance`) | invisible (`validIn_iff_recurrenceFree`) | invisible (`plusValidIn_iff_recurrenceFree`) | invisible (`openValidIn_iff_recurrenceFree`) | invisible (`starValidIn_iff_recurrenceFree`) | invisible (`regFreeValidIn_iff_recurrenceFree`) | **visible** (`recF_defines`, `bindRec_defines`; `recF_separates`) | **visible** (`qRec_defines`, `standard_not_invariant`) |
| Transposition | invisible (same) | invisible (same + `no_transposition`) | invisible | invisible | invisible | invisible | **visible** (`transF_defines`, `transF_refuted_distinct`) | visible (paper: two quantified atoms; UNVERIFIED) |
| Limit beyond Nullity | invisible | invisible | invisible | invisible | invisible | invisible | invisible | invisible |
| Saturation (vs. Comp+Serial+Limit) | OPEN | OPEN | OPEN | OPEN | OPEN | OPEN | OPEN | OPEN |
| Determinism | invisible | invisible (`cor:no-characterization`) | invisible (`deterministic_not_plusDefinable`) | UNVERIFIED (expected invisible: `▷`/`◁` classes are state-local on a flow) | **visible** (`deterministic_starDefinable`, `star_discriminates_where_plus_cannot`) | invisible (`fzero_hybridValidOn_iff_f1`) | invisible (`deterministic_not_hybridDefinable`) | UNVERIFIED (expected visible via `Atom(p)` plus next-step patterns over ZTime only) |
| Duration-metric facts (rate, distance) | invisible (re-timing, 559/04 `repar_invariance`, mirror) | invisible | invisible | invisible (paper) | clock reading invisible (`star_invariance`); synchrony visible (`StarDiscrimination`) | invisible (paper) | invisible (paper: registers name states, not durations) | invisible (paper) |
| Clock reading of a state | invisible | invisible | invisible | invisible | invisible | invisible | invisible — the product's nominals name clocked states, but no sentence reads the clock off (`reg_not_prodInvariant` shows non-invariance, not visibility of `e`) | invisible |

Row notes. *Limit beyond Nullity*: for the product-invariant languages this is 624's probe 02
(`zeroFix`: a reflexive non-injective zero task has the same histories, hence the same truths,
as its zero-fixed version, whose product satisfies Limit); for the nominal and quantifier columns
the product argument is unavailable but the `zeroFix` step is language-independent (same
`WorldState`, same `H_F`) — paper, UNVERIFIED for those columns, and no non-Limit frame type
exists in the tree to state it. *Saturation*: no device in this or the prior rounds settles it
(the product is neutral, `saturation_of_prodRel`); OPEN at every column. *Determinism, L^▷*: the
open-future/open-past classes on a flow are determined by the state at `t` only when histories
through a state are unique, which fails on `F°`; a `satSet` clause for `▷` is not state-local
in general, so this cell is genuinely UNVERIFIED rather than routine.

### Recommendations

1. **(i) Which extension, and under what name.** No further extension needs to be studied for
   *visibility*: the question is closed by `HybridLanguage/` (state registers = state nominals =
   the binder), and that component's name and README already carry the quotient caveat. Keep the
   name "hybrid state language"; do not open a "state nominal" task separately. The one
   worthwhile follow-up is a **port of probes 01-02** (~350 lines, no new axioms, one round):
   - `Semantics/Frames/TranslationProduct.lean`: `classValid_iff_recurrenceFree_of_prodInvariant`
     (then restate the three `*ValidIn_iff_recurrenceFree` as instances), `stabClass_lift_unique`,
     `projH_mem_stabClass`;
   - new `OpenLanguage/OpenInvariance.lean`: `state_eq_lift`, `open_invariance`,
     `openValidIn_iff_recurrenceFree`;
   - `HybridLanguage/HybridInvariance.lean`: `regFree_prod_invariance`,
     `regFreeValidIn_iff_recurrenceFree` (delete the "Not formalized" row);
   - new `Metalogic/Independence/HybridDeterminismUndefinable.lean`: `hsatSet`,
     `hybridTruthAt_iff_mem_hsatSet`, `hybridValidOn_iff_hsatSet_univ`,
     `fzero_hybridValidOn_iff_f1`, `deterministic_not_hybridDefinable`;
   - `Semantics/Truth.lean` or a small `Semantics/TenseFragment.lean`: `BoxFree`,
     `boxFree_histMap_invariance`;
   - `Metalogic/Independence/TranslationProductCoarse.lean`: `blc_cRefuted_product`,
     `liftK_eK_pasteClosed` as the worked instance.
   Probe 03's two lines can go straight in. Every declaration compiles against the live tree.
2. **(ii) Manuscript.** Yes: the single remark of §5.3, at `sub:Conclusion` after the unfolding
   sentence, citing the repository for both halves. Optionally one clause in `sub:Extension`
   after "cross reference either times or worlds": that storing times and worlds still does not
   re-identify a world state, and that a state register would. Nothing else in the manuscript
   needs to change; `sub:Conclusion`'s footnote on determinism and registers is exactly right.
3. **(iii) For the completeness research.** (a) Clocked canonical frames are WLOG for L, L⁺,
   L⋆, L^▷ and L⁺ + `[≡]` at every tag (the meta-theorem), and NOT for any system with state
   nominals (`hybridValidOn_incomparable`): fix the language before choosing the engine.
   (b) The since/until fragment transfers along any history-lifting *map*; a canonical bundle
   need not be onto histories for the tense part of a truth lemma. (c) Nominals buy nothing for
   closure (`blc_cRefuted_product`) and nothing for determinism (`deterministic_not_hybridDefinable`);
   a nominal engine still needs the closure schemata and still cannot axiomatize the
   deterministic class without time registers. (d) The device that yields `blc` is the Extension
   Theorem; treat "every closure trace is the trace of a coherent chronicle" as the whole problem.

## Decisions

1. The 628 results are treated as established inputs, not redone; this round compiles only what
   628 and 624 left as prose or "not formalized", and one new negative result (determinism under
   nominals) that neither asked.
2. The general blindness theorem is stated over an arbitrary truth predicate `S` rather than over
   a typeclass of languages, so that instantiating it needs no instance and no transport; the
   three landed theorems become one-line instances.
3. `open_invariance` is proved directly on the product rather than through `HistMorphism`,
   because `HistMorphism.lift` is too weak for `▷`/`◁`; the docstring records this so that the
   port does not try to "generalize" it.
4. The hybrid state-set recursion threads the register vector as an argument of the recursion
   rather than fixing it, so that the binder case is one line; this mirrors `HybridTruthAt`.
5. Probe 03 is deliberately two one-line instances: the substantive Q4 answer is a statement
   about what any device must break, which is prose, and the probe only pins that the product
   is not such a device.
6. No `user_decision` is raised: every choice is settled by the artifacts and the dispatch's
   constraints.

## Risks & Mitigations

- **Risk**: the manuscript remark is read as conceding a defect. **Mitigation**: the draft ties
  it to the Cresswell footnote's existing stance and states the positive half (the least
  addition that expresses recurrence) in the same sentence.
- **Risk**: the hybrid determinism result is over-read as "nominals are useless". **Mitigation**:
  §2.3 states the orthogonality (nominals see recurrence/transposition; registers see
  determinism); both cells are compiled.
- **Risk**: the L^▷ determinism cell is guessed. **Mitigation**: marked UNVERIFIED with the
  reason it is not routine.
- **Risk**: the Blackburn §7.3 quotation is from an unverified scan whose text on disk resists
  a plain search (ligatures). **Mitigation**: only one short phrase from its first page is used,
  and every hybrid-logic claim that matters is compiled in the tree rather than cited.
- **Risk**: `LC_n` is cited as if live. **Mitigation**: §4.1 names its only location (a 559
  mirror probe) and says the live tree has `blc` alone.

## Tactic Survey Results

- Not applicable (no tactic survey performed). All three probes were written directly against
  the live structures and compiled with `lake env lean` (probe 02 needed one `haveI` for the
  `Subsingleton Unit` instance through a `let`-bound frame; probes 01 and 03 compiled on the
  first run). The only automation used is `abel` (one clock identity in `stabClass_lift_unique`)
  and `simp only [Set.mem_univ, iff_true]` in the validity corollary; every other step is
  `exact`/`rw` with `Iff.rfl` clause lemmas. `lean_multi_attempt` and `lean_hammer_premise` were
  not invoked and no rate-limited search tool was needed (every lemma used — `zero_add`,
  `Prod.ext`, `congrArg`, `forall_congr'`, `exists_congr`, `imp_congr`, `Subsingleton.elim`,
  `Function.update`, `Set.mem_univ` — is standard).

## Context Extension Recommendations

- **Topic**: the "what a history-lifting map/morphism preserves" rule of thumb as a decision
  table for new operators: clause consults one history's times only → invariant along any
  `HistMap` (since/until); consults histories at the present time → needs `onto` (`□`) or `lift`
  (`⊡`, `[≡]`); consults agreement on a ray → needs the product's unique lift (`▷`, `◁`);
  consults state identity across times of one history → not invariant (registers, `↓`, standard
  `∀p`).
- **Gap**: `context/project/lean4/` has no such table; 624 and 628 each recommended a pattern
  file for their half and neither exists yet.
- **Recommendation**: one file `context/project/lean4/patterns/morphism-invariance-table.md`
  covering the translation product, `HistMorphism`, the meta-theorem, and the table above;
  cross-reference the two earlier recommendations and retire them.

## Appendix

### A. Probe inventory (all sorry-free; `lake env lean` exit 0; the only `sorry` string is the docstring phrase "sorry-free")

`probes/01_invariant-languages-blind.lean` (265 lines): `classValid_iff_recurrenceFree_of_prodInvariant`,
`starValidIn_iff_recurrenceFree'`, `stabClass_lift_unique`, `projH_mem_stabClass`, `state_eq_lift`,
`open_invariance`, `openValidIn_iff_recurrenceFree`, `regFree_prod_invariance`,
`regFreeValidIn_iff_recurrenceFree`, `BoxFree`, `boxFree_histMap_invariance`, `boxFree_prod_invariance`.
Imports `Semantics.Frames.TranslationProduct`, `OpenLanguage.OpenValidity`,
`HybridLanguage.{HybridInvariance,HybridValidity}`.

`probes/02_nominals-break-product.lean` (259 lines): `recF_valid_product`, `transF_valid_product`,
`recF_separates`, `transF_separates`, `constHist` (private), `recF_separates_trivial`,
`reg_not_prodInvariant`, `hybridValidOn_incomparable`, `hsatSet`, `hybridTruthAt_iff_mem_hsatSet`,
`hybridValidOn_iff_hsatSet_univ`, `fzero_hybridValidOn_iff_f1`, `deterministic_not_hybridDefinable`.
Imports `Semantics.Frames.TranslationProduct`, `HybridLanguage.{HybridRecurrence,HybridTransposition}`,
`Metalogic.Independence.DeterminismUndefinable`.

`probes/03_limit-closure-device.lean` (44 lines): `blc_cRefuted_product`, `liftK_eK_pasteClosed`.
Imports `Metalogic.Independence.{TranslationProductCoarse,LimitClosureCountermodel}`.

Axiom profiles (`#print axioms` on scratch copies): `boxFree_histMap_invariance` and
`hybridTruthAt_iff_mem_hsatSet` — `[propext]`; every other theorem listed —
`[propext, Classical.choice, Quot.sound]`, the choice entering through the landed
`limit_of_shift`/`exists_ne` route of `TranslationProduct.lean` and through the real carrier of
`F°`/`F¹`, never through a choice principle of these probes. No `sorryAx`; no new axiom.

### B. UNVERIFIED items, by name

1. World-register invariance along the projection (§1.6; identical induction shape to the time
   registers; no world register in the tree).
2. Nomic-operator invariance (§1.6; no semantics in the tree).
3. Determinism under L^▷ (§6 table; not routine, see the row note).
4. Determinism under standard `∀p` (§6 table; 628 §4.2's relativisation sketch).
5. Limit-beyond-Nullity for the nominal and quantifier columns via `zeroFix` (§6 row note).
6. The quantified transposition sentence (§6; 628 Appendix B item 4, unchanged).
7. Every first-order temporal operator is blind over ℤ/ℝ-time (§3.2; from Kamp's theorem, held
   as Venema 2001 Thm 4.1, plus 3.1's mechanism).
8. Decidability/axiomatizability of TM⁺ + state nominals at each tag (628 §4, unchanged).

### C. Manuscript anchors used

`sub:WorldStates`, `sub:AbsoluteTime` (incl. the Cresswell footnote), `sec:Construction`,
`sub:RestrictedModalities`, `sub:Extension`, `sub:OpenFuture` (`sent:det` and its footnote),
`sub:DynamicalSystems`, `sub:Conclusion` (the unfolding sentence and the determinism footnote),
`def:frame`, `lem:nullity`, `def:BLstar-semantics`, `app:drift`, `cor:no-characterization`.

### D. Searches

- Corpus: `~/Projects/Literature/index.json` title scan for hybrid/nominal/since/until/expressive;
  `sources/` listing for Blackburn, Venema, Areces, ten Cate, Goranko (only Blackburn 2002 and
  the Venema papers are held); `grep` of `blackburn_2002/ch07_since-until-hybrid.md` (the scan's
  text does not match plain `nominal`; the p. 437 passage was read from the file head),
  `venema_2001/sec03_since-and-until.md` (Theorem 4.1), `venema_1993_since/sec01_*.md` (IR rule).
- Mathlib: no rate-limited search tool was needed (Tactic Survey Results).
