# Research Report: Task #906

**Task**: 906 - Settle whether LCU is derivable from TM-plus + LC_n at ZTime via a non-ZTime separating model
**Started**: 2026-11-12T02:02:30Z
**Completed**: 2026-11-12T02:41:00Z
**Effort**: ~40 min, one research dispatch
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` (read in full; `lcN`, `lcU`, `lcAnte`, `lcCons`, `gle`, `bigAnd` and the four validity theorems)
- `FormalSystem/Metalogic/LCExtension.lean` (read in full; `ExtDerivation`, `IsLCAxiom`, `IsLCUAxiom`, `ext_sound_ztime`, `ext_sound_validIn`, `LCComplete`/`LCRulesComplete`/`LCURulesComplete`)
- `FormalSystem/PlusLanguage/PlusDeterminism.lean`, `FormalSystem/Semantics/FrameProperty.lean` (`Deterministic`, `deterministic_iff`, `deterministic_rev`, `stab_iff_of_deterministic`)
- `FormalSystem/Semantics/Frames/Standard.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean` (`translationFrame`, `translationHist`, `translationModel`, `translationFrame_deterministic`)
- `FormalSystem/Metalogic/Deterministic/Validity.lean` (`DetSat`, `PlusValidDetIn`, `PlusValidIn.toDet`, `plusValidDetIn_reflectTime`, `detSat_rev`)
- `FormalSystem/Semantics/{TemporalOrder,TaskFrame,PartialHistory,TaskModel,FrameClassValidity}.lean`, `FormalSystem/PlusLanguage/{PlusTruth,PlusValidity,PlusReversal,Axioms}.lean`, `FormalSystem/Metalogic/NamingRules.lean`, `FormalSystem/Semantics/Frames/TranslationProduct.lean`
- Mathlib lookup MCP: **gate resolved to skip** — see Domain Analysis
**Artifacts**:
- `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md` (this report)
- `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` (compiled, `sorry`-free probe; 5 named results + the headline)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (modal/temporal: stability modal, until-form limit closure), math (order theory: cofinality in linearly ordered abelian groups)

## Executive Summary

- **The separating model exists, and it is machine-checked.** `lcU α β` is **not** a theorem of
  TM⁺ + `LC_n` + mirror `LC_n` at `FrameClass.Base`. The witness is the **translation frame over
  ℚ** (`translationFrame (TemporalOrder.of ℚ)`), which is regular and **deterministic**; the atom
  truth set is `{q : ℚ | q < 1}` and the refuting point is the identity history at time `0`. The
  headline theorem
  `¬ ExtDerivation .Base IsLCAxiom RuleSet.none (lcU (atom pa) (atom pa))`
  compiles `sorry`-free with axioms `[propext, Classical.choice, Quot.sound]`.
- **The separation needs no progress on `LC_n`'s open `.Base` validity.** On a *deterministic*
  frame `⊡φ ↔ φ`, so `lcAnte n α` and `lcCons n α` become the *same* condition and `lcN n α` is
  valid for the trivial reason `X → X` — at every arity, for all parameters, mirror included. The
  open `.Base` question is therefore sidestepped entirely: validity on one frame is all soundness
  needs.
- **The operative asymmetry is not the until, it is the missing guard.** `lcN`'s consequent body
  is an *implication* guarded by `⟐αᵢ`, so a chain of markers that **converges** discharges it;
  `lcU`'s consequent body is an *unguarded disjunction* `⟐α ∨ (⟐β U ⟐α)`, which forces the
  `⟐α`-points on the witness history to be **cofinal** above `t`. Over ℤ a strictly increasing
  marker chain is automatically cofinal; over ℚ it need not be. The refuting instance takes
  `β := α`, so the until's segment guard carries nothing extra — the `PlusLCSchema.lean` docstring's
  until-vs-`F` reading is *not* what blocks derivability.
- **The `.ZTime` question cannot be settled by any separating model, and this result is the
  strongest such argument available.** Both `lcN_plusValidZTime` and `lcU_plusValidZTime` are
  compiled, so every `.ZTime` model validates both; the deliverable's "separating model" branch is
  now **exhausted**, at its sharpest form. What remains is the derivation branch, and it is now
  constrained: any derivation of `lcU` from `LC_n` must essentially use a `.ZTime`-only principle
  (`UZ`/`Z1`, or a naming rule), because every frame-class-neutral derivation is ruled out.
- **Design consequence for the completeness programme.** The *guarded* until-form
  `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))` **survives** this countermodel (it too collapses to
  `X → X` under determinism). If an until-form schema is wanted at a frame class below `.ZTime`,
  that is the shape with a chance; `lcU`'s disjunctive consequent is strictly `.ZTime`.

## Context & Scope

`PlusLCSchema.lean`'s module docstring records that `.Base` validity of both `lcN` and `lcU` is
"open and unclaimed", and that "no derivability or completeness claim is made … nothing here says
that `lcU` is a TM⁺ theorem … or that it follows from `lcN`". `LCExtension.lean` turns the
derivability question into a precise object: `ExtDerivation fc Ax R φ`, with `IsLCAxiom` (every
`lcN n α` at `0 < n`, plus its `reflectTime` mirror) and `IsLCUAxiom` (`lcU α β` plus its mirror),
and with three completeness targets stated and deliberately unproved (`LCComplete`,
`LCRulesComplete`, `LCURulesComplete`).

The dispatch's deliverable is one of two things: a derivation of `lcU α β` in TM⁺ + `LC_n` + mirror
`LC_n` for state-local `β`, or a non-`.ZTime` separating model. The dispatch's own framing is
correct and is confirmed here: a `.ZTime` countermodel is structurally impossible, because both
schemata are `.ZTime`-valid by compiled theorems, so the two extensions have exactly the same
`.ZTime` models.

In scope: a separating frame, and the soundness argument that converts it into a non-derivability
statement. Out of scope, by the dispatch: any completeness claim, and any Lean work beyond stating
the model. The probe went past that floor only because the pieces already existed (see Findings
5); the library under `FormalSystem/` was **not** touched, and the probe lives under
`specs/evidence/`.

## Domain Analysis

Two domains, with logic primary.

- **Logic (primary)**: the question is about a modal/temporal proof system — the stability modal
  `⊡` of L⁺, the until-form limit-closure schema, and soundness of a theoremhood closure over a
  frame subclass. The decisive move is modal: the *deterministic collapse* `⊡φ ↔ φ`.
- **Math, order theory (secondary)**: the countermodel's content is order-theoretic. A
  `TemporalOrder` is a nontrivial linearly ordered abelian group, hence unbounded above; the
  separating property is whether a strictly increasing ω-chain must be **cofinal**. Over ℤ it must
  (`intOrder_omega_cofinal`); over ℚ it need not.
- **Physics**: not engaged. No dynamical-systems, orbit or ergodicity content arises; the
  "flow"-shaped `translationFrame` is a group translation, not a dynamical-systems question.

**Mathlib-lookup gate: resolved to SKIP.** The gate (`context/patterns/mathlib-lookup-gate.md`)
asks whether the task needs a Mathlib declaration found by search. It does not: every ingredient
was already named inside this repository (`stab_iff_of_deterministic`, `translationFrame`,
`PlusValidDetIn`, `plusValidDetIn_reflectTime`), and the only external facts used are `ℚ`'s ordered
field instances, which `linarith`/`norm_num` discharge without a lemma name. `lean_local_search`
was likewise not needed: the relevant declarations were located by `Grep` and read verbatim, which
is a strictly stronger evidence tier than a search hit. No search-tool result is reported as a
negative finding anywhere in this report.

## Findings

### Logic Findings

**Finding 1 — `lcU`'s consequent demands cofinal `⟐α`-points; `lcN`'s does not.** VERIFIED (High).

The two formulas, read off `PlusLCSchema.lean:205-226` (`lcAnte`/`lcCons`/`lcN`) and `:248-256` (`lcU`) verbatim:

```
lcN n α := ⊡G≤ ⋀_{i<n}(⟐αᵢ → ⟐F⟐α_{i+1})  →  ⟐G≤ ⋀_{i<n}(⟐αᵢ → F⟐α_{i+1})
lcU α β := ⊡G≤(⟐α → ⟐(⟐β U ⟐α))           →  (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))
```

`gle_iff` (`PlusLCSchema.lean:158`) gives `G≤ φ` at `t` iff `φ` holds at every `s ≥ t`. So:

- `lcN`'s consequent asks, on one history `ρ` through the state at `t`: at every `s ≥ t`, **if**
  `⟐αᵢ` holds at `s`, then some later point carries `⟐α_{i+1}`. The body is an implication, so
  every `s` at which no `⟐αᵢ` holds is **vacuous**. A marker chain `t = c₀ < c₁ < …` that converges
  to some `L` discharges the whole consequent: above `L` the history can sit at states carrying no
  `⟐αᵢ`, or simply carry no obligation.
- `lcU`'s consequent body `⟐α ∨ (⟐β U ⟐α)` has **no guard**. At every `s ≥ t` it asserts either
  `⟐α` at `s` or a later `⟐α`-point. Either way there is an `⟐α`-point at or above `s` — for
  *every* `s ≥ t`. Since a `TemporalOrder` is a nontrivial ordered abelian group and hence
  unbounded above (`TemporalOrder.lean:83-93`), the `⟐α`-points on `ρ` must be **cofinal** in `D`.

This is the separating property, and it is an order-theoretic one, not an until-vs-`F` one. It is
precisely the hypothesis `omega_chain` discharges only through `intOrder_omega_cofinal`, which the
`lcU_plusValidZTime` docstring already names as the single discharge available in this tree — the
present finding identifies **where in the formula** that hypothesis is forced, and shows it is
forced on `lcU` alone.

**Finding 2 — On a deterministic frame, `lcN` and its mirror are valid for the trivial reason
`X → X`.** VERIFIED (High), compiled.

`stab_iff_of_deterministic` (`PlusDeterminism.lean:123-131`) gives `⊡φ ↔ φ` at every point of a
deterministic frame, for arbitrary `φ`; the probe adds the one-screen `dstab` sibling
`⟐φ ↔ φ` (the `(⇒)` direction is `truth_congr_ext` along `states_eq_of_deterministic`, the `(⇐)`
direction is `⟨τ, rfl, h⟩`). Under that collapse:

- `lcAnte n α = ⊡ (G≤ ⋀ (⟐αᵢ → ⟐F⟐α_{i+1}))` becomes `G≤ ⋀ (αᵢ → F α_{i+1})`;
- `lcCons n α = ⟐ (G≤ ⋀ (⟐αᵢ → F⟐α_{i+1}))` becomes the **same** condition.

The compiled statement is `lcAnte_iff_lcCons_of_deterministic`, and
`lcN_plusValidOn_of_deterministic` is its one-line corollary. The mirror comes free from
`plusValidDetIn_reflectTime` (`Deterministic/Validity.lean:281-283`), whose rev-closure argument
`detSat_rev` already supplies `deterministic_rev`'s regularity hypothesis.

**This is why the separation does not wait on `LC_n`'s `.Base` validity.** Soundness over a
*subclass* of `.Base` needs `LC_n` valid on the frames of that subclass only. On the deterministic
frames, `LC_n` contributes **no strength at all**: all of its content sits in the gap between
`⊡`/`⟐` and between `⟐F⟐`/`F⟐`, and that gap closes under determinism.

**Finding 3 — the separating model.** VERIFIED (High), compiled.

Frame: `translationFrame (TemporalOrder.of ℚ)` (`Semantics/Frames/Standard.lean:73-100`) — world
states are the durations, `w ⇒_x u ↔ u = w + x`. It is regular by `translationFrame_isRegular`
(so it is a `.Base` frame: `Sat .Base F` *is* `TaskFrame.IsRegular F`,
`FrameClassValidity.lean:173`) and deterministic by `translationFrame_deterministic`
(`Correspondence/DurationFrames.lean:522-525`). Its world histories are exactly the translations
`t ↦ t + c`.

Model: `translationModel QOrd {q | q < 1}` — every atom is true exactly at the states `< 1`.
History: `translationHist QOrd`, the identity `t ↦ t`. Point: `t = 0`. Parameters: `α = β = atom "a"`.

- **Antecedent holds.** At any `s ≥ 0` with `s < 1`, the witness `s' = (s+1)/2` satisfies
  `s < s' < 1`, so `⟐α` holds at `s'` and `⟐β` holds throughout `(s, s')` (everything below `1` is
  both an `α`- and a `β`-point). *Density of ℚ is what supplies the witness*, and it supplies one
  for every `s < 1` without ever escaping `[0,1)`.
- **Trigger holds**: `0 < 1`.
- **Consequent fails at `s = 1`**: `1 < 1` is false, so the left disjunct fails; and there is no
  `s' > 1` with `s' < 1`, so the until fails. The `⟐α`-points are confined to `(-∞, 1)` and are
  therefore *not* cofinal — exactly Finding 1's obstruction.

Compiled as `lcU_refuted`.

**Finding 4 — the non-derivability conclusion.** VERIFIED (High), compiled.

`ext_sound_validIn` (`LCExtension.lean:260-277`) is soundness of `ExtDerivation` at an arbitrary
frame class for a rule set with both Auxiliary-Atoms flags off. The probe transcribes it at the
narrower class `DetSat fc` (`ext_sound_detIn`): the `tm` case goes through
`PlusValidIn.toDet ∘ plus_soundness_validIn`, `refl` through `plusValidDetIn_reflectTime`, `mp`,
`nec` and `tnec` verbatim (they are frame-local), and the three naming-rule cases by contradiction
against the flags. With `IsLCAxiom` discharged over `DetSat .Base` by Finding 2
(`isLCAxiom_plusValidDetIn_base`), the headline follows from Finding 3:

```lean
theorem lcU_not_extDerivable_base :
    ¬ ExtDerivation .Base IsLCAxiom RuleSet.none
        (lcU (PlusFormula.atom pa) (PlusFormula.atom pa))
```

`#print axioms` on all five probe results reports `[propext, Classical.choice, Quot.sound]` — no
`sorryAx`, and `grep -c sorry` on the probe is `0`.

**Finding 5 — nearly all of the machinery already existed.** VERIFIED (High).

`translationFrame`/`translationHist`/`translationModel` exist precisely to "realize an arbitrary
`A ⊆ D` as the truth set of an atom" (`Frames/Standard.lean:33-37`,
`Correspondence/DurationFrames.lean:135-156`); `stab_iff_of_deterministic` exists as
`app:deterministic`'s positive half; `PlusValidDetIn` and `plusValidDetIn_reflectTime` exist as the
validity notion and reflection law over exactly this subclass, the pair the docstring says "the
paper's completeness result over the deterministic frames is stated about". The only new content is
the `dstab` collapse, the `lcAnte ↔ lcCons` computation, and a 10-line soundness transcription.

**Finding 6 — the guarded until-form is NOT separated by this model.** VERIFIED (High), by the
same computation as Finding 2.

Replace `lcU`'s consequent by the `lcN`-shaped guarded form:

```
lcU_guarded α β := ⊡G≤(⟐α → ⟐(⟐β U ⟐α))  →  ⟐G≤(⟐α → (⟐β U ⟐α))
```

Under the determinism collapse both sides become `G≤(α → (β U α))`, so `lcU_guarded` is valid on
every deterministic frame and this countermodel says nothing against it. The separation is
therefore sharply located: it is the **unguarded disjunction** in `lcU`'s consequent, not the until,
and not the two-parameter shape.

**Finding 7 — "state-local `β`" does not weaken the result.** VERIFIED (High).

The dispatch's derivation target was restricted to state-local `β`. The refuting instance takes `β`
to be an **atom** — the maximally state-local case, and the one `PlusAxiom.atom_stab`
(`p → ⊡p`, `PlusLanguage/Axioms.lean`) treats as primitive. Indeed `β := α`, so the until's segment
guard is satisfied by the same set that satisfies `⟐α`. The restricted target is thus refuted along
with the general one.

### Math Findings

**Finding 8 — density is not the operative property; Archimedean ω-cofinality is.** VERIFIED
(Medium — the ℚ instance is compiled; the discrete instance below is argued, not compiled).

`PlusLCSchema.lean`'s docstring attributes the obstruction to density: cofinality "holds over ℤ
(`intOrder_omega_cofinal`) and fails over a dense order, where a strictly increasing sequence may
converge". Density is *sufficient* but not *necessary*. The real condition on a `TemporalOrder` `D`
is: **every strictly increasing ω-chain above a point is cofinal**, i.e. `D` is Archimedean-like.
A **discrete** counterexample: `D = ℤ ×ₗ ℤ` (lexicographic), a nontrivial linearly ordered abelian
group in which every element `(a,b)` has an immediate successor `(a,b+1)` — yet `(0,k)_{k∈ℕ}` is
strictly increasing and bounded above by `(1,0)`. Taking the translation frame over it with atom
truth set `{(a,b) | a < 1}` reproduces Findings 1–4 verbatim, with `(1,0)` playing the role of `1`.
This matches, from the other side, `FrameProperty.lean:40-44`'s own note that `UZ` and `Z1` "fail
over every non-Archimedean discrete order" — which is exactly why `FrameClass.ZTime` is interpreted
by the narrowed `IsZTime` rather than by bare `IsDiscrete`.

Consequence for the derivation branch: a derivation of `lcU` from `LC_n` cannot rest on discreteness
or on a successor axiom alone. It must use a principle that fails over `ℤ ×ₗ ℤ` — i.e. the
Archimedean `.ZTime` axioms, or a naming rule whose soundness is `.ZTime`-only.

**Finding 9 — the result extends up the frame-class order, for free.** VERIFIED (Medium —
one-line extensions, not compiled).

`Sat` is antitone (`FrameClass.Sat.anti`), so a countermodel at a *larger* tag is a stronger
non-derivability statement. The same ℚ frame is a `.Dense` frame (`Sat .Dense = IsRegular ∧ IsDense`,
and ℚ is densely ordered), and the identical construction over ℝ — `linarith`/`norm_num` are
field-generic, so the probe's proof text is unchanged — gives a `.RTime` frame (dense + complete).
So `lcU` is non-derivable from TM⁺ + `LC_n` + mirror at `.Base`, `.Dense` and `.RTime` alike. Only
`.ZTime` escapes.

### Cross-Domain Synthesis

The logic side and the order-theory side meet at one point, and it is worth stating plainly.

`LC_n`'s **entire** strength, at any frame class, lives in the `⊡`→`⟐` and `⟐F⟐`→`F⟐` gap: it says
"one history realizes all the recurrences that each history realizes separately". That is a
*splicing* principle, and it is pure modal content — which is why it evaporates on a deterministic
frame, where there is nothing to splice.

`lcU`'s strength is **two** things glued together: the same splicing content, **plus** an
order-theoretic demand (cofinal `⟐α`-points) smuggled in by the missing guard on its consequent.
The splicing half is exactly what `LC_n` supplies; the order-theoretic half is exactly what
`intOrder_omega_cofinal` supplies, and nothing else in this tree does. An axiom set whose semantic
content is purely modal cannot entail a formula whose content is partly order-theoretic, over a
frame class that contains an order where the demand fails. That is the whole proof, and the
deterministic frames are simply the cheapest place to make the modal half vanish so the
order-theoretic half stands alone.

This also explains why the `.ZTime` question is immune to models: at `.ZTime` the order-theoretic
half is *free* (every strictly increasing ℤ-chain is cofinal), so the two extensions have the same
models, and only a proof-theoretic argument can separate or connect them.

## Decisions

1. **Answer the deliverable's second branch, not the first.** No derivation was attempted beyond
   checking that the obvious routes fail (`LC_1` at `α₀ := α` is implied by `lcU`'s antecedent but
   yields only the guarded `F`-form consequent; `LC_2` at `α₀ := α, α₁ := β` yields alternation, not
   a segment guard). The separating model settles the frame-class-neutral case outright, which is
   strictly more informative than another failed derivation attempt.
2. **Separate on the deterministic frames rather than hunt for a frame validating `LC_n`
   non-trivially.** This was the pivotal decision. Validating `LC_n` on a general `.Base` frame is
   the *open problem* the dispatch flagged; validating it on a deterministic frame is a tautology
   check. Soundness only needs the latter.
3. **Take `β := α` (an atom) rather than `β := ⊤`.** It keeps the instance inside the dispatch's
   "state-local `β`" restriction, reuses `translationModel`'s single-set valuation unchanged, and
   makes the point that the until's segment guard is not what is at issue.
4. **Use `{q | q < 1}` rather than `{1 - 2⁻ᵏ}` as the truth set.** Both exhibit a bounded
   increasing chain; the half-line needs only `linarith` where the geometric chain would need
   induction on `k`. The convergent-chain intuition is unchanged — density supplies the chain.
5. **Compile the probe despite the dispatch's report-level floor.** The pieces already existed
   (Finding 5), the build cache was warm, and the claim being made is a *negative* one, where an
   argued-only separation is exactly the kind of claim that quietly fails. Recorded as a win in
   `issues.jsonl`. No file under `FormalSystem/` was touched.
6. **State the `.ZTime` verdict as "not settled, and not settleable this way"** rather than
   stretching the `.Base` result into a `.ZTime` claim. The `tm` constructor at `.ZTime` quotes
   `PlusDerivable .ZTime []`, which includes `UZ`/`Z1`; those are not valid on the ℚ frame, so the
   soundness argument does not reach `.ZTime` — by design, since `lcU` *is* `.ZTime`-valid.

## Recommendations

1. **Record the result in `PlusLCSchema.lean`'s docstring** where `.Base` validity and
   non-derivability are currently both listed as unclaimed. The module says "nothing here says …
   that `lcU` … follows from `lcN`"; it can now say more: `lcU` demonstrably does **not** follow
   from `lcN` + mirror at `.Base`/`.Dense`/`.RTime`, with the separating frame named. Similarly
   `LCExtension.lean`'s target block can record that `LCComplete`'s `lcU` instance is unreachable
   from `IsLCAxiom` without a `.ZTime`-only principle.
2. **Promote the probe's Part I into the library.** `dstab_iff_of_deterministic` is the missing
   `⟐` sibling of `stab_iff_of_deterministic` and belongs beside it in `PlusDeterminism.lean`
   (its docstring already lists four results as "the stable import surface"; this is a natural
   fifth). `lcN_plusValidOn_of_deterministic` and `ext_sound_detIn` belong near `LCExtension.lean`'s
   soundness arms — `ext_sound_detIn` is the deterministic-class arm that module currently lacks,
   and it is independently useful for `Metalogic/Deterministic/`'s own completeness work.
3. **If an until-form schema is wanted below `.ZTime`, use the guarded form** (Finding 6):
   `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))`. It is the `lcN`-shaped until-form, it survives
   this countermodel, and its `.Base` validity is open on the same Zorn-plus-Extension-Theorem
   footing as `lcN`'s — i.e. it is a *candidate*, where `lcU` is now a *non-candidate*.
4. **For the `.ZTime` derivation question, target the naming rules, not the axiom set.** Finding 8
   says the missing ingredient must fail over `ℤ ×ₗ ℤ`. The Auxiliary-Atoms rules are exactly the
   `.ZTime`-only ingredients in `ExtDerivation` (`aa_sound_ztime` is proved "at `FrameClass.ZTime`
   only, by a cone construction over `intOrder`"). So the live question is whether
   `ExtDerivation .ZTime IsLCAxiom RuleSet.all` derives `lcU` — and the honest prior is that it is
   no cheaper than `LCRulesComplete` itself, since `lcU` is `.ZTime`-valid and would follow from
   completeness immediately. A cheap follow-up is the converse direction instead: does
   `IsLCUAxiom` derive `lcN`? That one *may* admit a separating model, and no model-theoretic
   obstruction to looking has been established here.
5. **Do not spend further effort looking for a `.ZTime` separating model** for this pair, in any
   form — general frame, algebra, or ultraproduct. `lcN_plusValidZTime` and `lcU_plusValidZTime`
   are compiled, so the two extensions are `.ZTime`-model-equivalent by construction; any apparent
   `.ZTime` separation would be an error in the attempt.

## Risks & Mitigations

- **Risk: the `.Base` result is mistaken for a `.ZTime` result.** The task title asks about
  `.ZTime`. *Mitigation*: stated explicitly in the Executive Summary, Decision 6 and
  Recommendation 5. The compiled theorem's name carries the tag — `lcU_not_extDerivable_base`.
- **Risk: "deterministic frames are degenerate, so the separation is cheap."** *Mitigation*: it is
  cheap, and that is the finding, not a defect. Determinism is **not** axiomatised in TM⁺ —
  `PlusLanguage/Axioms.lean` records that *Determined* "must never be added here: it is refuted at
  `.Base`, so adding it would falsify TM⁺ soundness" — so the deterministic frames are a genuine
  subclass of `.Base` and soundness over them is a genuine soundness fact. Adding axioms only
  shrinks the frame class, so the countermodel is robust to any strengthening of TM⁺ that stays
  `.Base`-sound.
- **Risk: the clock rule might repair the derivation at `.Base`.** The compiled result is at
  `RuleSet.none`, so the clock rule is off. *Mitigation / assessment*: it would not. `clock_irr_sound`
  (`NamingRules.lean:364`) evaluates on `F.translationProduct`, and
  `FrameOver.translationProduct_taskRel` gives `TaskRel a x b ↔ F.TaskRel a.1 x b.1 ∧ b.2 = a.2 + x`
  — so the product of a deterministic frame is deterministic (first component unique by `F`'s
  determinism, second determined outright). A `DetSat`-level restatement of `clock_irr_sound` is
  therefore a one-line generalization, and `ext_sound_detIn` would then admit `R.clock = true`.
  UNVERIFIED (High confidence, uncompiled) — flagged rather than assumed, and it does not affect
  the compiled claim.
- **Risk: the discrete strengthening (Finding 8) is argued, not compiled.** *Mitigation*: tagged
  Medium confidence and kept out of the headline. It needs `TemporalOrder.of (ℤ ×ₗ ℤ)`'s four
  instances (`IsOrderedAddMonoid` for a lex product is the only non-trivial one) and the same proof
  text with `(1,0)` for `1`; a follow-up probe would settle it. Nothing in the report's main
  conclusion depends on it.
- **Risk: the probe rots.** It lives under `specs/evidence/` and is not in the Lake build, so a
  future refactor of `lcU`, `ExtDerivation` or `translationFrame` will not break the build visibly.
  *Mitigation*: Recommendation 2 — promoting Parts I and III into `FormalSystem/` puts the
  load-bearing half under CI, where it belongs.

## Context Extension Recommendations

One method lesson is worth filing in the source store (per `rules/source-store-deploy-boundary.md`,
authored under the resolved `source_dir`, never under `.claude/**`):

**Separate on a degenerate subclass before trying to validate the axiom on the whole class.** The
dispatch framed the obstacle as "`LC_n`'s `.Base` validity is open", which reads as a prerequisite:
settle the open problem, then separate. It is not a prerequisite. A non-derivability result needs the
axiom set valid on **one** frame, so the right first move is to look for a subclass on which the
axiom set is valid *trivially* — here, the frames whose modal operator collapses, making a
splicing axiom a tautology — and then ask whether the target formula still fails there. Residual
content that survives the collapse (here: an order-theoretic cofinality demand) is precisely the
content the axiom set cannot supply. This generalizes beyond this repository: for any modal axiom
whose content is a "one witness realizes all" splicing principle, the frames where the modality
collapses are the first place to look for independence.

A natural home is a new pattern file under the `formal` extension's context (alongside
`context/patterns/mathlib-lookup-gate.md`), titled for the technique rather than for this task.
