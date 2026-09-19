# Research Report: Task #628

**Task**: 628 - Investigate expressive extensions that make recurrence and transposition visible: state nominals, state registers, propositional quantifiers, and a Prior-style proof-theoretic identification of world states
**Started**: 2026-09-19T07:43:13Z
**Completed**: 2026-09-19T08:11:15Z
**Effort**: ~70 minutes of agent time; one compiled probe (856 lines, 92 declarations, sorry-free), one report
**Dependencies**: None (624's probe 01 and 559's reports 01-04 are read as established inputs, not redone)
**Sources/Inputs**: - Codebase (read, not modified): `FormalSystem/Semantics/TaskFrame.lean` (`Compositional` with its `0 ≤ x, 0 ≤ y` provisos at 598, `Serial` 556, `FrameOver.reflection` 983, `TaskFrame.reflection` 2180, `trivialFrame` 1846, `exists_pos_of_nontrivial` 1270), `Semantics/PartialHistory.lean` (`WorldHistory` 407, `state`, `respects_task` 440, `ext_state` 454, `ofTotal` 473, `timeShift` 483), `Semantics/Truth.lean` (`TruthAt` 233), `Semantics/PlusLanguage/PlusTruth.lean` (`PlusTruthAt` 83), `Syntax/Formula.lean` (derived operators 136-179), `Semantics/FrameClassValidity.lean` (`FrameClass.Sat` 118), `Semantics/FrameProperty.lean` (`IsDense` 125, `IsZTime` 184, `IsComplete` 207, `IsRTime` 236, `isZTime_of_instances` 279), `Semantics/Frames/Standard.lean` (`permissiveFrame` 117-131), `Semantics/Extension/Extension.lean` (`occurrence` 218), `Semantics/TemporalOrder.lean` (`of` 120, `intOrder` 152). - Established: `specs/624_translation_product_task_semantics_visibility/probes/01_translation-product-live.lean` (`prodFrame`, `liftH`/`projH`, `liftH_through`, `HistMorphism`, `histMorphism_invariance`, `prodProj`, `*_invariance`, `*ValidIn_iff_recurrenceFree`, `prod_no_recurrence`, `prod_no_transposition`) and `reports/01_translation-product-visibility.md`; `specs/559_.../reports/04_semantics-first-task-frames.md` §4.3 (`state_name_sound`, `NOM_q`), `reports/03` §3.1, `reports/01` §2.6 and `02` (535's naming rule unsound). - Manuscript `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, read at: 610-723 (Prior), 921-937 (simulation metasemantics; Cresswell footnote 928-935), 1025-1030, 1153-1162, 1452-1466, 1764, 3056 (`cor:occurrence`), 3070-3080 (`app:gluing`). - Literature, held (global `~/Projects/Literature/` corpus; the repo sub-index lacks all but the last): Blackburn-de Rijke-Venema 2002 `blackburn_2002/ch07_since-until-hybrid.md` §7.3 (unverified scan; NAME/PASTE p. 443, Thm 7.21 p. 439, Lemma 7.24-7.28, Thm 7.29 p. 445, notes on Prior and the Bulgarian school in `ch07_lindstrom-summary.md` 1207-1247); Gabbay-Hodkinson-Reynolds 1994 `gabbay_1994/ch1203_...md` Prop. 12.7.4-12.7.5 (MSO of countable scattered orders decidable via Rabin 1969; MSO of ℚ decidable, citing Burgess-Gurevich 1985 Thm 2.6); Gabbay-Kurucz-Wolter-Zakharyaschev 2003 (Thm 6.64 `PTL × S5` EXPSPACE-complete; Thm 11.76 `PTL × S5 = [PTL, S5]` finitely axiomatisable; §13.2 decidability via MSO of linear orders); Thomas 1997 (held, `no_source_pdf` summary chunks: Büchi 1962 MSO over ω, Shelah 1975 monadic theory of order); Kamp 1968 and Rabinovich 2014 (held; expressive completeness of U/S over complete linear orders); 559/04's `state_name_sound`. - Literature, NOT held (labelled *recalled* wherever used): Prior 1967 *Past, Present and Future* ch. V; Prior 1968 *Papers on Time and Tense* ("Tense logic and the logic of earlier and later"); Prior & Fine 1977 *Worlds, Times and Selves* incl. Fine's postscript; Blackburn 2006 "Arthur Prior and Hybrid Logic"; Blackburn & ten Cate 2006 "Pure extensions, proof rules, and hybrid axiomatics"; Areces-Blackburn-Marx 2000; Franceschet-de Rijke-Schlingloff 2003; Fine 1970 "Propositional quantifiers in modal logic"; Kaminski-Tiomkin 1996; Kremer 1997; Sistla-Vardi-Wolper 1987 (QPTL); Shelah 1975 (undecidability of MSO(ℝ)); ten Cate 2006 (SOPML vs hybrid logic). - Probe written this round (sorry-free, `lake env lean` exit 0, no warnings): `probes/01_nominals-registers-quantifiers.lean`.
**Artifacts**: - `specs/628_expressive_extensions_recurrence_visibility/reports/01_expressive-extensions-recurrence.md` (this report) - `specs/628_expressive_extensions_recurrence_visibility/probes/01_nominals-registers-quantifiers.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Q1 (negative), compiled.** The same-state-at-any-time modality `[≡]` is invisible: truth of
  every formula of L⁺ + `[≡]` is invariant along every history-lifting morphism
  (`regFree_invariance`), for arbitrary register vectors; composed with 624's `prodProj` this
  gives "class validity = validity over recurrence-free members" for L⁺ + `[≡]` at every tag
  (composition not recompiled; both halves are). Propositional quantifiers ranging only over
  lifted (clock-independent) propositions are invisible too (`lifted_invariance`). The
  manuscript's own time *and world* registers (1456-1466) are blind for the same reason
  (paper, UNVERIFIED for world registers; time registers are 624's `star_invariance`).
- **Q2 (positive), compiled.** One state register `i` (a state nominal when free, `↓_i` when
  bound) suffices: `¬(i ∧ (P i ∨ F i))` is valid on a task frame **iff** the frame is
  recurrence-free (`recF_defines`; `bindRec_defines` for the register-closed `↓_i ¬(P i ∨ F i)`).
  The transposition formula `¬(E(i ∧ F j) ∧ E(j ∧ F i))` is valid on every recurrence-free
  frame (`transF_valid`, via a compiled two-history splice `exists_splice`) and refuted on the
  permissive frame with `i`, `j` naming *distinct* states (`transF_refuted_distinct`). At every
  `FrameClass` tag the class validates neither formula while its recurrence-free members
  validate both (`recF_not_validIn`, `transF_not_validIn`, `recF_valid`). **The minimal resource
  is a state-identity test across two times of one history**: every other clause (atoms, `□`,
  `U`/`S`, `⊡`, `[≡]`) tests state identity only up to the kernel of the projection.
- **Q3, compiled.** In the live `Formula`, `A φ := □(Hφ ∧ φ ∧ Gφ)` is the universal modality
  over all (history, time) pairs, using only totality of `WorldHistory` (`formula_univ_iff`).
  Under standard (all state-sets) semantics, `Atom(p) := E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))` holds
  iff `p` is a singleton among occurring states (`isAtom_iff`, via `cor:occurrence`), so
  `∀p (Atom(p) → ¬(p ∧ (Pp ∨ Fp)))` is valid iff the frame is recurrence-free (`qRec_defines`),
  and standard-quantifier truth is not invariant along any history-lifting morphism from a
  recurrence-free frame onto a recurrent one (`standard_not_invariant`).
- **Q4 (cost).** Held results fix the landmarks: basic hybrid logic with nominals and `@` is
  PSPACE-complete and complete for every pure-formula extension via NAME + PASTE (Blackburn et
  al. Thm 7.21, 7.29, held); the abundant *product* semantics `PTL × S5` is decidable,
  EXPSPACE-complete and finitely axiomatisable (GKWZ Thm 6.64, 11.76, held); MSO of ℚ and of
  countable scattered orders is decidable (Rabin 1969 via Gabbay-Hodkinson-Reynolds Prop. 12.7.5,
  held), of ω via Büchi 1962 (Thomas 1997 summary, held-unverified), while MSO(ℝ) is undecidable
  (Shelah 1975, recalled) and second-order propositional modal logics with standard semantics
  over non-linear frames are recursively isomorphic to full second-order logic (Fine 1970,
  Kaminski-Tiomkin 1996, Kremer 1997, all recalled). For the task semantics itself nothing is
  held: state nominals are nominals for the *quotient* (W, ⇒), not for points, so `@_i` splits
  into `A(i → ·)` / `E(i ∧ ·)` and PASTE pastes ⊡-theories only; the cost verdicts for TM⁺ +
  nominals and TM + ∀p over task frames are UNVERIFIED and are scoped precisely in §4.
- **Q5 (Prior).** Prior's instants-as-maximal-propositions, read in the task semantics where
  letters denote *state sets*, identifies world states, not instants: `isAtom_iff` is Prior's
  definition compiled, and it makes visible exactly what Prior's one-dimensional instants cannot
  exhibit (recurrence). A NAME rule for state nominals is sound, and a named canonical model
  builds world states directly as classes of named MCSs, giving the `⊡`-existence lemma for
  free; it does not touch 559's real obstacle (closure of the canonical bundle), and whether any
  naming rule is *needed* for the nominal-free system stays OPEN. Fit with simulation
  metasemantics (921-937): nominals/registers/quantifiers are Cresswell's "selective devices"
  which the manuscript explicitly excludes from `BL` (933-934); adding a *state* register is the
  extension closest to its primitives and the only one that sees them.
- **Recommendations**: (i) port the probe as `Semantics/Extension/HybridState.lean` (one
  language, `NFormula`) and `Semantics/Extension/PropQuant.lean`, ~500 lines, no new axioms;
  (ii) one manuscript remark near 1466: a state register, not the time/world registers, is what
  makes recurrence and transposition expressible; (iii) for 559: adopt state nominals as the
  naming ingredient of record *only* if the engine is redesigned around named MCSs; otherwise
  record that naming cannot help with closure (§5.3).

## Context & Scope

624 compiled that L, L⁺ and L⋆ validate the same sentences over every task frame and its
translation product, which is recurrence-free and transposition-free, so at every `FrameClass`
tag class validity equals validity over recurrence-free members. This round asks which
extensions break that invariance, at what cost, and what a proof-theoretic identification of
world states (Prior, hybrid naming) gives 559's completeness research.

Every invariance or visibility claim below names a compiled, sorry-free declaration of
`probes/01_nominals-registers-quantifiers.lean` (namespace `Probe628`) or carries the label
UNVERIFIED. Manuscript claims cite line numbers of `possible_worlds.tex` as read on 2026-09-19.
Literature claims are marked *held* (with the corpus file) or *recalled*. No completeness
theorem is stated; no file under `FormalSystem/` or `Tests/` is changed; no sorry, no new axiom
(axiom profiles in Appendix A).

The Literature Extraction Protocol is not invoked: the task cites literature for cost and
history (Q4, Q5), not as a proof source to transcribe.

## Findings

### Codebase Patterns

- The live `PlusFormula` is a closed inductive, so both extension languages are standalone
  inductives whose L⁺ clauses copy `PlusTruthAt` verbatim (`NTruthAt`, `QTruthAt`); the probe's
  `Iff.rfl` clause lemmas mirror `PlusTruth.*_iff`.
- `WorldHistory.respects_task s t : TaskRel (τ s) (t - s) (τ t)` is unconditional (no `s ≤ t`),
  which is what makes the splice `exists_splice` a four-case argument: same side from
  `respects_task`, cross from `TaskFrame.comp` (both provisos `0 ≤ t - x`, `0 ≤ y - t`
  discharged by `sub_nonneg`), reversed cross from `TaskFrame.reflection` plus `neg_sub`.
- `PartialHistory.occurrence` (`Extension.lean:218`) is the compiled `cor:occurrence`; it is the
  only frame-theoretic fact `isAtom_iff` needs.
- Class witnesses: `FrameOver.trivialFrame (D := ℤ/ℚ/ℝ)` sits in `.Base`/`.ZTime`, `.Dense`,
  `.RTime` respectively; instance search does **not** see through `TemporalOrder.of ℤ`'s carrier
  (`SuccOrder (trivialFrame …).Duration.carrier` fails), so the ℤ instances are passed
  explicitly to `isZTime_of_instances` and `permissiveFrame` (`zSucc`, `zNoMax`), and
  `Mathlib.Data.Int.SuccPred` must be imported (as `Metalogic/Soundness.lean` does). `IsRTime`
  for ℝ is `⟨DenselyOrdered ℝ, isLUB_csSup⟩`. `simp` likewise cannot match a lemma whose `t`
  binder lives in `permZ.toTaskFrame.Duration` against a goal typed at `ℤ`, so
  `transF_refuted_distinct` chains the `Iff` lemmas by hand.
- 624's `HistMorphism` (forth + history-level lift + onto) is exactly what the two new clauses
  consume: `same` via `lift` at an arbitrary time `s`, `all` via `pullV_update`.

### External Resources

- Manuscript: recurrence/transposition 1025-1030; `⊡` and `⟨τ⟩_x` 1153-1162 (footnote: S5,
  `φ → ⊡φ` for non-temporal `φ`); registers 1452-1466 (1455 "lack the means by which to cross
  reference either times or worlds"; clauses 1458-1463; 1466 "outside the scope"); simulation
  metasemantics 921-937 with the Cresswell footnote 928-935 ("The bimodal language BLK includes
  no such selective devices"); Prior 610-723 (611, 628, 701-702, 721-723); unfolding 1764;
  `cor:occurrence` 3056; `app:gluing` 3070-3080.
- Held literature: Blackburn-de Rijke-Venema §7.3 — nominals "true at exactly one state",
  `@_i`, pure formulas, NAME (`⊢ j → φ ⇒ ⊢ φ`) and PASTE (`⊢ @_i ◇j ∧ @_j φ → ψ ⇒ ⊢ @_i ◇φ → ψ`,
  `j` fresh) p. 443, "close cousins of the IRR rule", Extended Lindenbaum 7.25, Existence Lemma
  7.27, Truth Lemma 7.28, Completeness 7.29 for every set of pure axioms (p. 445), PSPACE 7.21
  (p. 439), PASTE as a disguised sequent rule (p. 447), nominals as bindable variables (p. 452);
  notes: Prior used the global modality ([369, App. B4]), nominals from the Bulgarian school
  (Passy-Tinchev, Gargov, Goranko). GKWZ 2003 Thm 6.64, 11.76, §13.2. Gabbay-Hodkinson-Reynolds
  Prop. 12.7.5 and its Rabin citation. Thomas 1997 summary (Büchi 1962; Shelah 1975). Kamp 1968
  / Rabinovich 2014.
- 559/04 §4.3: `NOM_q(ψ) := (⟐ψ → □(q → ⟐ψ)) ∧ (⊡ψ → □(q → ⊡ψ))`, `state_name_sound`, and the
  UNVERIFIED lead "a state register … makes recurrence expressible".

### 1. Q1 — what stays invisible (negative, compiled)

**1.1 `[≡]` is invisible.** `NFormula.same φ` holds at `(τ, t)` iff `φ` holds at every `(σ, s)`
with `σ(s) = τ(t)`. `regFree_invariance g M : ∀ φ, φ.RegFree → ∀ τ' t r' r, NTruthAt (g.pullM M)
τ' t r' φ ↔ NTruthAt M (g.mapH τ') t r φ` for every `g : HistMorphism F' F`. The `same` case is
the `stab` case with the time freed: given `σ(s) = g(τ'(t))`, `g.lift σ (τ'(t)) s` produces `σ'`
with `σ'(s) = τ'(t)` and `g ∘ σ' = σ`. On the product this is `liftH_through` with the clock
offset read off the state, as the dispatch anticipated. Axioms: `[propext, Quot.sound]`.

Corollary (composition with 624, not recompiled): since `prodProj F` is a `HistMorphism` and
`prodFrame F` is recurrence-free and in every class `F` is in, validity of L⁺ + `[≡]` over any
`FrameClass` tag equals validity over the recurrence-free members — the same three lines as
`plusValidIn_iff_recurrenceFree`. Why `[≡]` fails to see recurrence although it tests state
identity across times: it cannot tell `(τ, s)` from `(σ, s)` for another history `σ` through the
same state at `s`, and on the product the lift of `τ` through `(w, c)` at time `s` is a different
product history. Only a test that keeps the history fixed across times sees recurrence (§2.4).

**1.2 Quantifiers over lifted propositions are invisible.** `pulledBack g := {S | ∃ T, S =
g ⁻¹' T}` and `lifted_invariance g : ∀ φ V τ' t, QTruthAt F' (pulledBack g) (g.pullV V) τ' t φ ↔
QTruthAt F Set.univ V (g.mapH τ') t φ`. The quantifier clause needs only `pullV_update` (pulling
back commutes with `Function.update`). So a quantifier that ranges over clock-independent
propositions on the product is the standard quantifier on `F` in disguise: it sees exactly what
`F` sees — which, by §3, *includes* recurrence in `F`. The point of Q1's second half is therefore
sharper than "invisible": the lifted semantics is not a semantics over a *class* of frames at all
(it is defined relative to a cover), and on the class the standard semantics is what one has;
`standard_not_invariant` (§3.3) shows the standard quantifier is not invariant.

**1.3 The manuscript's registers are blind.** Time registers: 624's `star_invariance`. World
registers (`↑^i`/`↓^i` over histories, 1460-1461): the same induction goes through with the
stored-history vector mapped by `projH`/lifted by `liftH _ 0`, because recall moves the
evaluation history and store records it, neither consulting a state's identity. UNVERIFIED (not
compiled; identical shape to the `timeStore`/`timeRecall` cases). Hence *none* of the
manuscript's own extensions (`⊡`, time registers, world registers) expresses the feature that
motivates its primitives; a **state** register does (§2).

### 2. Q2 — what makes recurrence and transposition visible (positive, compiled)

**2.1 One language for nominals and registers.** `NFormula.reg i` is true at `(τ, t, r)` iff
`τ(t) = r i`; `NFormula.bind i φ` evaluates `φ` with `r i := τ(t)`. A *state nominal* is a free
register: nominal validity is validity under every `r`. A register-closed sentence `↓_i φ` is
insensitive to `r`. This is the L⋆ pattern (`timeStore`/`timeRecall`) for states instead of
times, and it is exactly 559/04's UNVERIFIED lead, now compiled.

**2.2 Recurrence is definable.** `recF i := ¬(i ∧ (P i ∨ F i))`.
- `recF_valid : RecurrenceFree G → ∀ M τ t r, NTruthAt M τ t r (recF i)`.
- `recF_defines G i : (∀ M τ t r, NTruthAt M τ t r (recF i)) ↔ RecurrenceFree G`. The refuting
  assignment is `r := fun _ => τ(s)` at the recurring state; the model is irrelevant.
- `bindRec_defines G i : (∀ M τ t r, NTruthAt M τ t r (↓_i (recF i))) ↔ RecurrenceFree G`.
- At every tag: `recF_not_validIn fc i : ¬ NValidIn fc (recF i)` (witness
  `exists_sat_not_recurrenceFree fc`: `trivialFrame` over ℤ/ℚ/ℝ) and `recF_valid_recurrenceFree`
  (the recurrence-free members validate it). So the extension separates the class from its
  recurrence-free part exactly where 624 showed L⁺ and L⋆ cannot.

**2.3 Transposition is definable, and it is nested inside recurrence.** `transF i j :=
¬(E(i ∧ F j) ∧ E(j ∧ F i))`, with `E φ := ¬□(H¬φ ∧ ¬φ ∧ G¬φ)` (`NTruth.exist_iff`).
- `exists_splice G τ σ t (h : τ(t) = σ(t)) : ∃ η, (∀ x ≤ t, η x = τ x) ∧ (∀ x ≥ t, η x = σ x)` —
  the two-history case of `app:gluing` (3070), compiled from Compositionality and reflection
  alone (no Saturation, no Extension Theorem: both histories are already total).
- `transF_valid : RecurrenceFree G → ∀ M τ t r i j, NTruthAt M τ t r (transF i j)`. Proof: from
  `τ₁(s₁) = r i, τ₁(t₁) = r j, s₁ < t₁` and `τ₂(s₂) = r j, τ₂(t₂) = r i, s₂ < t₂`, time-shift `τ₂`
  by `s₂ - t₁` so that it occupies `r j` at `t₁`, splice at `t₁`, and read `r i` off the result at
  `s₁` and at `t₁ + (t₂ - s₂)` — a recurrence. Consequence worth recording against 1025-1030:
  **any transposition (two histories through two states in opposite orders, the states equal or
  not) forces a recurrence**, so recurrence-free frames are transposition-free. The converse
  fails: `trivialFrame` has recurrence and no two distinct states. 624's `prod_no_transposition`
  shape (`τ s = σ t ∧ τ t = σ s`, `s ≠ t`) is in fact *equivalent* to recurrence (σ := τ one way,
  shift-and-splice the other; paper, UNVERIFIED).
- `transF_refuted_of_recur`: any recurrence refutes `transF 0 1` with `i`, `j` naming the same
  state; `transF_not_validIn fc` at every tag. `transF_refuted_distinct`: on `permZ`
  (`permissiveFrame intOrder`, every `ℤ → Bool` is a history) the histories `true,false` and
  `false,true` refute it with `r 0 = true ≠ false = r 1`. So `transF` is valid on `G` iff `G` is
  recurrence-free (both directions compiled, the packaging into one `Iff` not written), and the
  *strong* property "no two histories visit two **distinct** states in opposite orders" is
  defined by `(E(i ∧ F j) ∧ E(j ∧ F i)) → E(i ∧ j)` (paper, UNVERIFIED: if `r i ≠ r j` the
  antecedent is a strong transposition; if `r i = r j` the consequent holds by occurrence).

**2.4 The minimal resource.** The invariance induction of `regFree_invariance` fails at exactly
one point: the clause `τ(t) = r i`. Every other clause consults either the valuation at the
current state (atoms — preserved because valuations are pulled back), or the history/time
structure (`□`, `U`, `S` — preserved by `onto`/`forth`), or the *same-state* relation
`σ(s) = τ(t)` (`⊡`, `[≡]` — preserved and reflected by `lift`). A history-lifting morphism
preserves the same-state relation but not state identity: its kernel identifies `(w, c)` with
`(w, c')`. So the minimal resource is a construct whose truth set is not a union of kernel
classes — a proposition true at exactly one occurring state. Three equivalent packagings: a free
state register (nominal), the binder `↓` (self-naming, no assignment), or standard propositional
quantification (which manufactures `{τ(s)}`, §3.2). Modal depth 1 and one register suffice
(`recF`); no `□`, no `⊡`. A nameless operator would also do — "the present state again, later on
this history" — but that is `↓x. F x` and needs the same state-identity-across-times test;
`[≡]` is the closest nameless operator that does *not* suffice, and §1.1 says why.

### 3. Q3 — the universal modality, `Atom(p)`, and recurrence under quantification

**3.1 `A` is definable in L** (`formula_univ_iff`): `TruthAt M τ t (□(Hφ ∧ φ ∧ Gφ)) ↔ ∀ σ s,
TruthAt M σ s φ`. The `□` clause ranges over all histories at the same time, `H`/`G` over all
other times of the (total) history `σ`. The only structural input is `WorldHistory` = `H_F` = the
total histories (`def:world-history` 2926; `thm:extension` 3038 supplies them); with partial
histories `A` would range over `(σ, s)` with `s ∈ dom σ` only, and `□` would need every history
to be defined at the present time. `E φ := ¬A¬φ` accordingly. (`WorldHistory.ofTotal` was
checked: no `ofTotal`-style totality *assumption* is needed beyond the subtype itself.)

**3.2 `Atom(p)` names a state** (`isAtom_iff`): under `Adm = Set.univ`,
`QTruthAt G univ V τ t (Atom n) ↔ ∃ w ∈ V n, ∀ ρ s, ρ(s) ∈ V n → ρ(s) = w`. (⇒) instantiate `q :=
{ρ₀(s₀)}` for the `E p` witness; (⇐) `cor:occurrence` gives `E p`, and for each `S` the disjunct
is chosen by `w ∈ S`. Note what is *not* said: `p` may contain non-occurring states — by
`cor:occurrence` there are none, but the lemma is stated so that only occurring states matter.

**3.3 Recurrence under standard quantification.**
- `qRec n := ∀p_n (Atom(p_n) → ¬(p_n ∧ (Pp_n ∨ Fp_n)))`; `qRec_valid` on recurrence-free frames;
  `qRec_defines G n : (∀ V τ t, QTruthAt G univ V τ t (qRec n)) ↔ RecurrenceFree G`.
- `standard_not_invariant g hF' hF`: for `g : HistMorphism F' F` with `F'` recurrence-free and
  `F` not, no truth invariance holds for the standard quantifier. With `g := prodProj F` (624)
  this is the exact failure of 624's invariance pattern for TM + ∀p. Transposition follows the
  same way (`∀p ∀q (Atom p → Atom q → transF)` — paper, immediate from `transF_valid` and
  `isAtom_iff`; UNVERIFIED as a compiled statement).
- With quantifiers `[≡]φ` becomes definable, `[≡]φ ≡ ∀p (Atom(p) ∧ p → A(p → φ))`, and
  `↓x.φ ≡ ∀p (Atom(p) ∧ p → φ[p/x])`; Prior's/Fine's schema `∃p (p ∧ Atom(p))` ("the present is
  namable") is valid under the standard semantics (take `{τ(t)}`) and is exactly what the binder
  asserts (paper).

### 4. Q4 — cost of each extension

What is *held* fixes the landmarks; the task-semantics verdicts themselves are UNVERIFIED and
listed as such.

**4.1 Hybrid state nominals (+ `A`, + `↓`).**
- Basic hybrid logic (nominals, `@`, one modality): satisfiability PSPACE-complete (Thm 7.21,
  held); NAME + PASTE make every pure-formula extension complete over its frame class (Thm 7.29,
  held; Lemma 7.22: pure formulas define first-order frame conditions). Recalled: over *linear*
  frames the tense language with nominals and `@` is decidable (NP-complete for `F`/`P`,
  Areces-Blackburn-Marx 2000; PSPACE with `U`/`S` over ℕ, Franceschet-de Rijke-Schlingloff
  2003), and `↓` is undecidable over arbitrary frames but decidable, non-elementary, over linear
  orders (via translation into MSO/FO of the order, then Büchi/Rabin).
- What differs here: a state nominal is a nominal for the quotient `(H_F × D)/~_state ≅` the
  occurring states, not for points. Consequences (paper, from the compiled clauses): `i → ⊡i` and
  `i ∧ E(i ∧ ⊡ψ) → ⊡ψ` are valid, `E(i ∧ ψ) → A(i → ψ)` is valid only for `⊡`-state formulas
  `ψ` (559/04 §4.3), `@_i` splits into `A(i → ·)` and `E(i ∧ ·)`, which are not dual. NAME
  (`⊢ i → φ ⇒ ⊢ φ`, `i ∉ φ`) is sound over task frames because every point can be named by its
  state — this *is* `state_name_sound` with a genuine nominal in place of a fresh letter. The
  natural PASTE, `⊢ E(i ∧ F j) ∧ A(j → φ) → ψ ⇒ ⊢ E(i ∧ F φ) → ψ`, is sound only when `φ` is a
  `⊡`-state formula (the new name `j` fixes a state, not the point at which `φ` was found): PASTE
  pastes `⊡`-theories. Pasting *points* would need time naming (559/03's clock/IRR rule), which
  the manuscript keeps out of the object language (953, 817 per 559/04).
- Decidability/axiomatisability of TM⁺ + state nominals over each `FrameClass`: UNVERIFIED, and
  not reducible to the held results, because validity is over *bundles* `H_F` of a task frame,
  not over products. The held product results are the right contrast: `PTL × S5` (the abundant
  two-dimensional semantics of 832-937) is decidable, EXPSPACE-complete and finitely
  axiomatisable (GKWZ Thm 6.64, 11.76; §13.2 via MSO of linear orders), and 624 showed the task
  semantics contains that theory as the clock-dependent valuations on the product; TM⁺ at Base
  is already incomplete for its axioms (`plus_incomplete_base`, landed), so the nominal
  extension inherits every open question of 559 and adds none that the held results settle.
  Expected shape (recalled analogy, hybrid + `↓` over ℕ non-elementary): with `↓` the
  register-closed fragment over ZTime should reduce to MSO of the canonical clocked frame, i.e.
  stay decidable but non-elementary; over RTime the reduction target is MSO(ℝ), undecidable.

**4.2 Propositional quantifiers (second-order propositional tense logic).**
- Held: MSO of countable scattered linear orders is decidable, hence any temporal logic with
  first-order-table connectives over scattered flows is decidable (Prop. 12.7.5), via Rabin
  1969's decidability of MSO(ℚ) (Burgess-Gurevich 1985 Thm 2.6 cited there); compactness fails
  for scattered orders (Prop. 12.7.4). Held-unverified summary (Thomas 1997): Büchi 1962 — MSO
  over ω decidable; Shelah 1975 — monadic theory of order. Held: Kamp 1968 / Rabinovich 2014 —
  `U`/`S` are expressively complete for FO(<) over Dedekind-complete orders, so adding set
  quantifiers to `U`/`S` yields full MSO(<) there.
- Recalled: MSO(ℝ, <) is undecidable (Shelah 1975); QPTL over ℕ is decidable and non-elementary
  (Sistla-Vardi-Wolper 1987); `S5π` is decidable and axiomatisable, while `Kπ`, `Tπ`, `S4π`,
  `K4π` with standard semantics are not r.e. (Fine 1970) and are recursively isomorphic to full
  second-order logic (Kaminski-Tiomkin 1996); the intuitionistic case likewise (Kremer 1997);
  SOPML with the global modality subsumes hybrid logic with nominals (ten Cate 2006), which is
  the general form of §3.2.
- Applied to the task semantics (UNVERIFIED throughout): quantifiers range over subsets of `W`,
  histories are fixed by the frame. On the translation frame over `D` (states = `D`, atoms =
  arbitrary subsets), TM + ∀p is QPTL-like over `D`: decidable over ℤ (Büchi) and ℚ (Rabin),
  undecidable over ℝ (Shelah) — frame-by-frame facts, not class validity. For class validity at
  a tag one needs a formula relativising to a translation-like frame; determinism is not
  L⁺-definable (landed `cor:no-characterization`) but with nominals/quantifiers it is
  (`Atom(p) ∧ p → □(X p → …)` patterns; paper), so a relativisation should exist over ZTime. The
  honest cost line: **standard propositional quantification over task frames is at least as
  hard as MSO of the duration order at each tag**, so RTime is the tag at which it is expected
  to be undecidable and non-axiomatisable; ZTime and Dense should stay decidable via Büchi/Rabin
  if the bundle structure `H_F` can be encoded in MSO of the order, which is open (559/03's MSO
  translation is a ZTime device only). Fine's "Henkin" alternative (quantifiers over a
  distinguished algebra of state sets) recovers axiomatisability at the price of §1.2's
  invisibility whenever the algebra is closed under pullback.

**4.3 Comparison.** Nominals/registers add no quantifier alternation and keep the model theory of
first-order shape (pure formulas ↔ FO frame conditions, Lemma 7.22 held); they are the cheap
extension. Standard quantifiers are the expensive one and buy nothing further for the two
features at issue (`qRec` is the nominal formula with the nominal manufactured). The manuscript's
registers are as cheap as nominals in syntax but blind (§1.3).

### 5. Q5 — Prior, hybrid naming, and what it gives 559

**5.1 Prior's construction, transposed.** Recalled (Prior 1967 ch. V, 1968 "Tense logic and the
logic of earlier and later", Prior & Fine 1977): an instant is a *world-proposition* `a` — `◇a`
(or `E a`) together with `∀q (L(a → q) ∨ L(a → ¬q))`, `L` the always/universal operator — and
`T_a(q) := L(a → q)`, `a < b := L(a → F b)`; the U-/Q-calculi then treat instants as defined
objects, and Fine's postscript studies the "world-proposition" schemata and their relation to
standard vs. general semantics. The task's `Atom(p)` is that definition with `A` for `L`.
Compiled in the task semantics (`isAtom_iff`), the definition picks out **a world state**, not an
instant, because the manuscript's propositions are sets of world states (`def:BL-semantics`
3128; 949-953 keep durations exogenous). This is the manuscript's own diagnosis of Prior (721:
"Prior takes the elements in `T` to answer two different questions: *when* … and *what*")
executed on Prior's construction: the construction answers the *what*, and the *when* is
supplied by `D`. And it makes visible precisely what Prior's instants cannot exhibit — an
instant cannot recur, a state can (`qRec_defines`). The hybrid-logic reading (recalled: Blackburn
2006, "Arthur Prior and Hybrid Logic"; held: Blackburn et al.'s notes on Prior's global
modality and the Bulgarian nominals) drops the quantifiers and keeps the names; the same
transposition applies: hybrid *state* nominals are Prior's world-propositions as atoms of the
quotient.

**5.2 A naming rule for state nominals and a canonical model of states.** NAME is sound (§4.1).
With NAME and a `⊡`-PASTE, the Extended Lindenbaum route (Lemma 7.25, held) makes every
consistent set extend to a *named and pasted* MCS in an expanded nominal set; then:
- **World states are classes of named MCSs**: `Γ ~ Δ` iff they share a nominal (transitivity of
  naming from the `nom` axioms, Lemma 7.24 held). This is a semantics-first canonical *frame*
  `(W_c, ⇒_c)`: `⇒_c` must be read off `E(i ∧ F j)`-type facts, and here the language's lack of
  a metric bites — over ZTime the next-step operator (`Formula.next`, landed) gives `⇒_1` and
  the chronicle indices give `D = ℤ`; over Base/Dense there is no canonical `D`, and 559's clocked
  or abstract-duration designs are still needed to *type* `⇒_c`.
- **The `⊡`-existence lemma is free**: `⟐ψ ∈ Γ`, `Γ` named by `i`, gives by `⊡`-PASTE a named
  MCS containing `i ∧ ψ`; same state = same nominal, so the `⟨τ⟩_t` clusters are read off the
  MCSs. This replaces 559/04's `NOM_q` simulation (which fixes only the `⊡`-theory of finitely
  many `ψ`, and by 624's `plus_invariance` can never fix the *history*: a letter with `NOM`
  clauses is not a nominal, compare `plus_invariance` against `recF_defines`).
- **What it does not touch**: the obstacle 559 identified is closure of the canonical bundle
  (`LC_n`, `BLC`, `plus_incomplete_base`) — whether every closure trace of chronicles is the
  state trace of a coherent chronicle. Nominals name states; they do not create the missing
  histories, and the product device shows all nominal-free reasoning is sound on bundles. So a
  nominal-extended system still needs the closure schemata, and Thm 7.29's automatic
  completeness for pure axioms does **not** transfer: its named model is a Kripke frame of MCSs,
  whereas here the frame must be a task frame with total histories over a group, which is the
  engine's whole job. Recurrence-freeness is pure-definable (`recF`), so *if* a nominal engine
  is built, adding `recF` as an axiom targets the recurrence-free (clocked) class at no extra
  cost — and 624 showed that class validates exactly the L⁺-sentences of the full class, so the
  nominal-free fragment is unchanged by the axiom.
- **Is any naming rule needed?** For the nominal-free system, still OPEN (559/04 §4.3). Two
  compiled facts constrain the answer: a naming rule *for letters* (`state_name_sound`) cannot add
  a recurrence-sensitive theorem (624: the product is sound on all translation-closed bundles),
  and a naming rule *for nominals* changes the language. Recalled and hedged: for hybrid logics
  with `@`, Blackburn & ten Cate 2006 show the non-orthodox NAME/PASTE rules can be traded for
  orthodox axioms in the presence of `@`; if that carries over, "needed" would mean "needed
  unless `@`-style operators (`A(i → ·)`, `E(i ∧ ·)`) are primitive". UNVERIFIED for the state
  case.

**5.3 Fit with the simulation metasemantics (921-937).** The manuscript takes intended models
to "simulate what that object language is able to express" (924) and denies that semantics
guides ontological commitment (935-936); its Cresswell footnote (928-935) says `BLK` "includes no
such selective devices" and that "even if `BLK` were enriched with such devices" the stance
stands. Nominals, registers and quantifiers are exactly Cresswell's selective devices. Three
consequences for the paper: (a) 624's gap (motivation by recurrence/transposition at 1025-1030,
inexpressibility in `BL`/`BL⁺`/`BL⋆`) is closed by a *state* register and by nothing the
manuscript currently lists (1456-1466 store times and worlds — both blind, §1.3); (b) the
footnote's "even if enriched" is now backed by a compiled example: with a state register the
language expresses `↓_i ¬(P i ∨ F i)`, whose validity tracks a property of the primitives
(recurrence-freeness), and the simulation stance still applies — the register simulates
re-identification of a configuration, it does not posit one; (c) 1764's "recovered by unfolding"
has a converse: the unfolding (translation product) is invisible to the language *until* a
selective device for states is added, at which point the folded and unfolded models come apart
(`standard_not_invariant`, `recF_not_validIn`). One remark near 1466 would state (a)-(c) in two
sentences (Recommendation 2).

### Recommendations

1. **Port (lean4, ~500 lines, no new axioms).** `FormalSystem/Semantics/Extension/HybridState.lean`:
   `NFormula`, `NTruthAt`, the `NTruth.*_iff` clause lemmas, `RecurrenceFree` (shared with the
   624 port — put it in `Semantics/HistoryMorphism.lean` if that module lands first, else here),
   `regFree_invariance` against the ported `HistMorphism`, `exists_splice` (this belongs in
   `PartialHistory.lean` or `Extension/Gluing`, next to `app:gluing`), `recF_defines`,
   `bindRec_defines`, `transF_valid`, `transF_refuted_distinct`, `NValidIn`,
   `exists_sat_not_recurrenceFree`, `recF_not_validIn`, `transF_not_validIn`.
   `FormalSystem/Semantics/Extension/PropQuant.lean`: `QFormula`, `QTruthAt` with `Adm`,
   `pulledBack`, `lifted_invariance`, `isAtom_iff`, `qRec_defines`, `standard_not_invariant`.
   `formula_univ_iff` goes to `Semantics/Truth.lean`'s `Truth` namespace as `univ_iff` (it is a
   fact about the live language). Docstrings must carry the "nominal for the quotient, not for
   points" caveat and the two blindness results.
2. **Manuscript**: one remark after 1466 (or as a second sentence of 624's remark at 1764): the
   time and world registers of 1456-1463 cannot express that a world state recurs or that two
   histories transpose two states; a register that stores the *world state* can, with
   `↓_i ¬(P i ∨ F i)` valid exactly on recurrence-free frames; this is consistent with the
   Cresswell footnote's stance. Optionally note that Prior's world-propositions, read over state
   sets, name states rather than instants.
3. **For 559**: (a) keep `state_name_sound` as a proof device, not as the naming ingredient of
   record — it cannot see what naming is for; (b) if a named-MCS engine is attempted, adopt state
   nominals with NAME and `⊡`-PASTE, build states as nominal classes, and expect the closure
   problem to be untouched; (c) record that "class validity = validity over recurrence-free
   frames" fails the moment nominals enter, so any WLOG-clocked engine argument must be made
   *before* nominals are added, not after; (d) the open question "is any naming rule needed"
   should be posed for the nominal-free system only.
4. **For 625 (open-future/past modalities)**: the `A`/`E` definability (`formula_univ_iff`) and
   the splice lemma are the two tools it will want; the splice is the compiled `app:gluing` for
   the two-history case.

## Decisions

1. Nominals and registers are one language (`reg`/`bind`) rather than two: a nominal is a free
   register, which is what makes the "nominal vs. register" comparison a theorem about
   assignments (`recF_defines` vs `bindRec_defines`) rather than two parallel developments.
2. Invariance is stated against the abstract `HistMorphism` (restated from 624) and *not*
   against a re-declared product: the composition with `prodProj` is three lines and re-declaring
   the product would duplicate ~250 lines; the corollary is labelled accordingly (§1.1).
3. The transposition witness is built on `permissiveFrame` with distinct states, not only on
   `trivialFrame`, so that the refutation is not an artefact of `i` and `j` naming one state.
4. The propositional-quantifier semantics is parameterised by an admissible family `Adm` so that
   "standard" and "lifted" are the same recursion at two arguments; this is what lets
   `lifted_invariance` and `standard_not_invariant` be stated about the same `QTruthAt`.
5. Q4's task-semantics cost verdicts are left UNVERIFIED and scoped rather than asserted by
   analogy; only the product (`PTL × S5`) and linear-order (MSO) landmarks are cited as held.
6. No `user_decision`: every choice is settled by the artifacts and the dispatch's constraints.

## Risks & Mitigations

- **Risk**: readers take state nominals for hybrid point nominals and import `@`-based results
  (Thm 7.29) wholesale. **Mitigation**: §4.1's quotient caveat, the non-duality of `A(i → ·)` /
  `E(i ∧ ·)`, and the `⊡`-only PASTE are stated in the probe docstring and prescribed for the port.
- **Risk**: the corollary "L⁺ + `[≡]` class validity = recurrence-free validity" is cited as
  compiled. **Mitigation**: §1.1 marks it as a composition of two compiled halves; the port should
  compile it once `HistMorphism` and `prodProj` share a module.
- **Risk**: instance-search opacity of `TemporalOrder.of` carriers recurs in the port (it cost
  two compile rounds here). **Mitigation**: Appendix A records the explicit-instance pattern and
  the `Mathlib.Data.Int.SuccPred` import.
- **Risk**: the recalled literature (Fine 1970, Kaminski-Tiomkin, Kremer, Shelah, Blackburn-ten
  Cate) is cited in the manuscript without verification. **Mitigation**: every such item is
  labelled recalled in §4-5 and listed in Appendix B; `/literature` ingestion of Prior & Fine
  1977 and Blackburn 2006 is the concrete follow-up before any manuscript citation.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The probe was written directly against the live
  structures and compiled with `lake env lean` in three rounds; the only automation used is
  `abel` (clock/duration arithmetic in `exists_splice` and `transF_valid`), `simp only` with
  the probe's own `Iff.rfl` clause lemmas, and `decide`-free `rfl` for the Boolean witness.
  `lean_multi_attempt` and `lean_hammer_premise` were not invoked; no goal called for tactic
  discovery, and the rate-limited search tools were not needed (every lemma used —
  `sub_nonneg`, `neg_sub`, `not_le`, `sub_eq_zero`, `isLUB_csSup`, `Function.update_self`,
  `Function.update_of_ne`, `Nat.ne_of_lt`, `lt_or_gt_of_ne`, `le_add_of_nonneg_right` — is
  standard Mathlib, located by name).

## Context Extension Recommendations

- **Topic**: extension languages over the task semantics (state registers, `A`/`E`, quantifier
  semantics with an admissible family) and the "what a history-lifting morphism preserves" rule
  of thumb (§2.4).
- **Gap**: `context/project/lean4/` has no note on the standalone-inductive pattern for
  extending `PlusFormula`, nor on the instance-opacity of `TemporalOrder.of` carriers
  (`isZTime_of_instances` needs explicit ℤ instances; `simp` cannot match across the carrier).
- **Recommendation**: after the port, add `context/project/lean4/patterns/extension-languages.md`
  naming `NFormula`/`QFormula`, the clause-lemma discipline, `exists_splice`, and the
  explicit-instance workaround; cross-reference 624's translation-product pattern file.

## Appendix

### A. Probe inventory (`probes/01_nominals-registers-quantifiers.lean`, 856 lines, 92 declarations)

`lake env lean` exit 0, no warnings, no `sorry` (the single grep hit is the docstring phrase
"sorry-free"). Imports: `Mathlib.Algebra.Order.Archimedean.Real.Basic`, `Mathlib.Data.Int.SuccPred`,
`FormalSystem.Semantics.{PlusLanguage.PlusValidity, Frames.Standard, Extension.Extension}`.

- Part 0: `HistMap`, `HistMorphism`, `HistMap.mapH`, `mapH_state`, `HistMap.pullM`,
  `RecurrenceFree`.
- Part 1 (`NFormula`, `NTruthAt`, `NTruth.*`): `top/neg/and/or/someFuture/somePast/allFuture/
  allPast/univ/exist/recF/transF/RegFree`; clause lemmas `box_iff, imp_iff, reg_iff, bind_iff,
  neg_iff, and_iff, or_iff, someFuture_iff, somePast_iff, allFuture_iff, allPast_iff, univ_iff,
  exist_iff`; `regFree_invariance`; `recF_valid`, `bindRec_valid`, `recF_defines`,
  `bindRec_defines`, `exists_splice`, `transF_valid`, `constHist`,
  `trivialFrame_not_recurrenceFree`, `NValidIn`, `exists_sat_not_recurrenceFree`,
  `recF_not_validIn`, `recF_valid_recurrenceFree`, `transF_refuted_of_recur`,
  `transF_not_validIn`, `zSucc`, `zNoMax`, `permZ`, `permHist`, `transF_refuted_distinct`.
- Part 2 (`QFormula`, `QTruthAt`, `QTruth.*`): derived operators incl. `isAtom`, `qRec`; clause
  lemmas as above plus `atom_iff`, `all_iff`; `pulledBack`, `HistMap.pullV`, `pullV_update`,
  `lifted_invariance`; `fand_iff`, `fallFuture_iff`, `fallPast_iff`, `formula_univ_iff`;
  `isAtom_iff`, `qRec_valid`, `qRec_defines`, `standard_not_invariant`.
- Axiom profiles (`#print axioms`, checked on a scratch copy): `regFree_invariance`,
  `lifted_invariance` — `[propext, Quot.sound]`; all others listed in §1-3 — `[propext,
  Classical.choice, Quot.sound]` (`Classical.choice` enters through `by_cases`/`by_contra`, the
  `if` in `exists_splice`, `exists_pos_of_nontrivial`, `isLUB_csSup`; no Zorn, no new axiom).
- Compile notes: instance search fails on `SuccOrder (trivialFrame (D := ℤ)).toTaskFrame.Duration.carrier`
  and `SuccOrder intOrder.carrier` — pass `inferInstanceAs (SuccOrder ℤ)` etc. and import
  `Mathlib.Data.Int.SuccPred`; `simp only [NTruth.neg_iff, …]` does not fire on a goal whose
  time is typed `ℤ` against a lemma whose binder is `permZ.toTaskFrame.Duration`, so chain the
  `Iff`s by hand; `Mathlib.Data.Real.Archimedean` is deprecated in favour of
  `Mathlib.Algebra.Order.Archimedean.Real.Basic`.

### B. UNVERIFIED and recalled items, by name

1. Class-level corollary for L⁺ + `[≡]` (composition of `regFree_invariance` with 624's
   `prodProj`/`prodFrame_sat`; both halves compiled). §1.1.
2. World-register invariance (`↑^i`/`↓^i` over histories). §1.3.
3. Equivalence of 624's weak-transposition shape with recurrence; definability of the
   strong-transposition-free class by `(E(i ∧ F j) ∧ E(j ∧ F i)) → E(i ∧ j)`. §2.3.
4. `transF` as a single `Iff` with `RecurrenceFree`; the quantified transposition sentence. §2.3, §3.3.
5. `[≡]` and `↓` definable from standard quantifiers; validity of `∃p (p ∧ Atom(p))`. §3.3.
6. Soundness of `⊡`-PASTE for state nominals; failure of point-PASTE. §4.1.
7. Decidability/axiomatisability of TM⁺ + state nominals and of TM + ∀p over each tag;
   relativisation to translation-like frames. §4.1-4.2.
8. Recalled literature: Prior 1967/1968, Prior & Fine 1977 (Fine's postscript), Blackburn 2006,
   Blackburn & ten Cate 2006, Areces-Blackburn-Marx 2000, Franceschet-de Rijke-Schlingloff 2003,
   Fine 1970, Kaminski-Tiomkin 1996, Kremer 1997, Sistla-Vardi-Wolper 1987, Shelah 1975, ten
   Cate 2006. Held-but-unverified summaries: Thomas 1997 (Büchi 1962, Shelah 1975 entries);
   Blackburn et al. 2002 §7.3 is an unverified scan (page numbers from the scan's running heads).

### C. Manuscript line index used

610-723 (611, 628, 701-702, 721-723 Prior); 817, 949-953, 3128 (propositions as state sets,
durations exogenous — 953/817 via 559/04); 921-937 (924, 928-935, 935-936); 1025-1030;
1153-1162; 1452-1466 (1455, 1458-1463, 1466); 1764; 2926; 3038; 3056; 3070-3080.

### D. Searches

- Corpus: `literature-search.sh` queries "hybrid logic nominal naming rule", "propositional
  quantifiers instants Prior", "monadic second-order theory linear order decidable", "Kaminski
  Tiomkin", "Kremer propositional quantification", "Fine 1970 propositional quantifiers modal",
  "Buchi Shelah monadic" (the SEP temporal-logic and Thomas chunk files are missing on disk;
  Thomas's summary was read from its source directory); `--toc blackburn_2002`, `--toc
  gabbay_1994`; global `index.json` title scan for Prior/hybrid/Fine/MSO. Held hits are listed
  under Sources/Inputs; the recalled list is what the corpus does not hold.
- Mathlib: no rate-limited search tool was needed (see Tactic Survey Results).
