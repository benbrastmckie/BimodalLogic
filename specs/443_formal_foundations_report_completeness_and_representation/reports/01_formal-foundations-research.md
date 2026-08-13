# Research Report: Formal Foundations Report — Completeness and Representation

**Scope**: research only, for `typst/FormalFoundations.typ` (new standalone report, NOT a book
chapter). No `typst/**` writes were made. Every claim below was verified directly against the
live paper (`possible_worlds.tex`), the live Lean tree (`FormalSystem/Metalogic/`), and the
repository's own gate scripts at authoring time (2026-08-13, commit `f231a8775`), per the task's
STATUS DISCIPLINE requirement. Predecessor task 442's findings note and sync audit were read and
are treated as settled input for the book's own corrected state; anchors it flagged as exposed to
in-flight Lean work are re-verified below rather than inherited.

---

## 0. Headline finding the planner must act on

**Two of the three "early representation work" items the task description names in §3.7 are
NOT live Lean work**, and the report must say so precisely rather than repeat the description's
framing verbatim:

| Item (task description §3.7) | Measured status |
|---|---|
| (a) Algebraic layer (`BooleanStructure`, `LindenbaumQuotient`, `UltrafilterMCS`, `InteriorOperators`, `FlowFrame`) | **Live**, real Lean code, `sorry_algebraic = 0` (measured, §5 below). |
| (b) Shift-set representation programme | **NOT started.** Task 424 (`strong_completeness` topic) is `status: not_started` in `specs/state.json`, dependencies `[361, 414, 439]`. No `ShiftSet`/`shiftSet` identifier exists anywhere under `FormalSystem/` (`grep -rln` empty). What exists is a *design document* — `specs/archive/361_.../design/02_compactness-route.md`, "Representation theorem (shift sets)" section — stating the target Lean signature in both directions, not a proof. |
| (c) Jönsson–Tarski programme (`Cm(F)`, `Uf(A)`, embedding `η`) | **Archived to `Boneyard/`, not future-planned as active work yet.** `FormalSystem/Boneyard/UltrafilterFrame/{TenseS5Algebra,UltrafilterFrame}.lean`, archived 2026-05-20 (task 21) "due to elaboration interference with `BXCanonical/Completeness.lean`", 5 sorries at archive time. Its own README names task 125 as the (unstarted, not currently in `state.json`'s active set) revival task. |

This does not mean §3.7 loses content — it means (b) and (c) belong in the **way-forward**
material as *targets with a stated design and a stated obstruction*, not narrated as "early steps
… that actually exist here" alongside the algebraic layer. Conflating a `not_started` task and an
archived module with live Lean work would violate the task's own acceptance criterion 5 ("every
open is marked open and every target marked target"). Task 414 (the total-history/`Omega`
refactor) is itself now `status: completed` — confirming predecessor task 442's finding 1c — so
the design document's literal Lean snippets (which cite the pre-refactor `Omega`-parameterized
`TruthAt`) are themselves now stale relative to the current `Truth.lean` and would need
restatement before task 424 executes; this is a second, independent staleness worth one sentence
in the report, not a blocker to describing the route.

---

## 1. Predecessor input (task 442) — what is settled, what must be re-verified

Consumed as settled: the completeness reversal (TM sound, provably incomplete; completeness
carried by BL⁺), the four frame classes (Base < {Dense, Discrete}, Dedekind strictly above
Dense), the deleted conservativity theorem, the open decidability status, the live `Metalogic/`
module structure (post-rebuild), and the corrected Since/Until event-first/guard-second
convention. `specs/442.../reports/02_revision-findings.md` finding 1b — whether the BX-level
`completeness_dense`/`completeness_discrete`/`completeness_dedekind` theorems (a different,
*more* fine-grained proof system than TM's own BL-level axiomatization) resolve, contradict, or
are simply orthogonal to `cor:tm-completeness`'s TM_d/TM_f status — is explicitly **left open** by
442 and must stay open here too; this report does not adjudicate it, and neither should
`FormalFoundations.typ`. Section 3.6 below states the Lean architecture in BX-system terms
throughout (never silently substituting TM/TM_d/TM_f) to avoid smuggling in an unearned
identification.

Re-verified rather than inherited (per the task's explicit instruction, since these sit in
territory the in-flight Lean chain touches): the sorry/axiom counts (§5), the `mcs_mixed_case_absurd`
architecture (§5), and the shift-set/Jönsson-Tarski status (§0) — none of which 442 needed to
check, since 442's scope was the book, not this new report's §3.6/3.7 territory.

---

## 2. Gate state, reproduced at authoring time

```
$ bash scripts/check-paper-definitions.sh
[paper-definitions] notice: possible_worlds.tex changed (new checksum d22d5347...,
last-touching commit f56cdea0...) but all 26 recorded definitions are unchanged -- pass.
```
Case (b) — proceed. Re-run this immediately before the report's final citation pass per the
task's §7/§5(3) instruction; do not reuse this run's checksum as a substitute.

```
$ bash scripts/typst-status-counts.sh --json
axiom_count=45, rule_count=7, base_count=37, dense_only_count=2, discrete_only_count=3,
dedekind_only_count=3, sorry_total=5, sorry_total_excl_boneyard=1,
sorry_algebraic=0, sorry_bxcanonical=0, sorry_bundle=0,
sorry_weakcanonical=5, sorry_weakcanonical_excl_boneyard=1, sorry_other=0
stamp_commit=f231a8775, stamp_date=2026-08-13
```
This is the authority for every sorry-count claim in the report per the task's explicit
instruction; a naive `grep -rn sorry FormalSystem/` overcounts (catches prose like "the sorry-free
Reynolds pipeline" and Boneyard content) — do not use it as a substitute. Re-run immediately
before the report's final pass; the count is a live measurement, not a fact to carry forward from
this research report.

---

## 3. Citation package — every anchor the task description's §7 list requires

All quoted below verbatim from `possible_worlds.tex` as read at authoring time (line numbers
given for this research pass only — **cite by `\label`/`\aitem` key in the report itself, never
by line number**, per repo-wide citation discipline). Anchors already tracked in
`specs/paper-definitions-of-record.md` are marked **[tracked]**; the rest are **[untracked —
re-verify directly at plan/implement time, or extend the record file per its own protocol]**.

### 3.1 System / language layer — all **[tracked]**, already in `paper-definitions-of-record.md`

`def:temporal-order`, `def:task-relation`, `def:directed`, `def:frame` (+ 4 sub-anchors:
`#Compositionality`, `#Seriality`, `#Limit`, `#Spherical`), `lem:nullity`, `def:world-history`,
`thm:extension`, `cor:occurrence`, `def:constraints`, `lem:constraint`, `lem:fibers`,
`lem:admissible`, `lem:step`, `def:BL-model`, `def:BL-semantics`, `def:BLplus-language`,
`def:BLplus-semantics`, `def:BLplus-defined`, `def:frame-validity`, `def:logical-consequence`.
Quote these from the record file directly — do not re-derive.

### 3.2 Proof-theory / soundness layer — **[untracked]**, verified live at possible_worlds.tex:

- `def:S5` (:3897) — the five S5 rule/axiom schemata (`TMP-MK`/`TMP-MT`/`TMP-M5`/`TMP-MP`/`TMP-MN`).
- `def:BX` (:3912) — Base Burgess–Xu tense logic: `TN`/`TD` rules, `TB`/`TL`/`CN` (seriality,
  linearity, connectedness), `TA`/`UE`/`UT`/`UI`/`UC`/`UF`/`UG`/`SU` (primary since/until axioms),
  `NP`/`NF`/`NA`/`NB` (uniformity axioms, vacuous unless discrete).
- `def:TMplus-f` (:3958) — `BX_f` (`UZ`, `Z1`); Hölder-derived Z-time identification for `BX_f`/
  `TM^+_f`; **explicit note that `TM_f` itself is sound over the FULL discrete class** (not just
  Z-time) with completeness there left open — do not conflate the two systems (task description
  §3.4 makes the same demand).
- `def:TMplus-d` (:3980) — `BX_d` (`DN`, `NN`).
- `def:TMplus-c` (:3993) — `BX_c`, re-based on the **Reynolds triple** (`Prior-U`, `Sep`; `Prior-S`
  is `TD`'s past mirror of `Prior-U`), with `CO`/`TMP-CO` now a **derived theorem** (not a further
  axiom) using only `Prior-U` and BX's base axioms — `Sep` is not needed for that specific
  derivation. Whether `TMP-CO` alone axiomatizes the same BL⁺-logic as the full triple is **open**
  (conjectured to fail via an unformalized Q-flow sketch — not established).
- `def:TMplus` (:4020) — `TM^+` = smallest extension of S5 + BX + `MF`(`TMP-MF`); the four-part
  conservativity footnote (backward unconditional; forward fails for base via (DD) and for
  discrete via `TMP-Z1`/ℤ×_lex ℤ; open for dense/complete) — **verbatim already reproduced** in
  task 442's report §4, safe to reuse without a fresh paper read.
- `thm:M5-valid` (:3618) — `⊨ ◇□φ → □φ`, one-paragraph semantic proof (Diamond-Box witness IS
  the point of evaluation once Box quantifies over the full evaluation set H_F).
- `thm:TM-soundness` (:3784) — the Soundness theorem; references `thm:M5-valid`, `thm:TD-valid`,
  `thm:TA-valid`, `thm:TL-valid`, `thm:MF-valid` as representative axiom-group proofs.
- `app:discrete` (:3091), `app:dense` (:3184), `app:complete` (:3275) — the three correspondence
  theorems, each a full biconditional proof with a tikz countermodel diagram in the paper (the
  discrete/dense proofs both use a translation-flow frame `W = D`, `w ⇒_d u ⟺ u = w + d`; the
  complete proof uses the same frame with `|p| = L` for a Dedekind cut `(L, U)`). Compressible to
  statement + one-line proof idea per the task's compression mandate; these are NOT the "give in
  full" exceptions (those are (DD) and the discrete/dense dichotomy, §4 below).
- `def:frame-properties` (:3063) — Discrete/Dense/Complete/Deterministic frame-class predicates
  (Deterministic is present but not needed for this report's scope).
- `cor:spherical-finite` (:2846) — "Every frame … with finite W satisfies *Spherical*,
  choice-free," 4-line proof (finite directed family → ⊆-least member by iterated pairwise
  intersection). **Also untracked** in the record file (a known, previously-flagged gap — see
  record file's "Known residual gap" note); needed for `thm:extension`'s footnote AND for §3.2's
  Zorn/choice-free discussion.

### 3.3 Perpetuity and collapse theorems — **[untracked]**, verified live

- `P1`–`P6` (:1183, :1201, :1213) derived at `sub:Logic` from `MF` + `MT` by classical reasoning
  (exactly as the task description states) — one-paragraph derivation chain, quotable near-verbatim.
- `TF` (:1192) — `□φ → F□φ`, derived from `MF`/`MT`/`TD` composition.
- `P9`/`P10` (:4118) — stated without proof (`¬△φ ↔ ▽¬φ`, `¬▽φ ↔ △¬φ`).
- The four modal-temporal collapses the task description names: **`Pthm:13`** (:4155,
  `▽□φ ↔ □φ`), **`Pthm:14`** (:4168, `△□φ ↔ □φ`), **`Pthm:18`** (:4219, `□△φ ↔ □φ`), **`Pthm:20`**
  (:4242, `◇φ ↔ ◇▽φ`). All four are short (≤6-line) proofs chaining `P1`–`P6`/`TF`/`MN`/`MK`/`M5`.
  Also present but not named by the task description: `Pthm:11` (`▽◇φ → ◇φ`), `Pthm:12`
  (`△◇φ → ◇φ`), `Pthm:16` (`◇▽φ ↔ ▽◇φ`), `Pthm:17`/`21`/`22` (composed from the others).

### 3.4 Hölder / order-theoretic facts — **[untracked]**, verified live

Two separate footnote sources, both already usable near-verbatim: `def:TMplus-f`'s footnote
(:3970-3977, discrete-Archimedean-⇒-ℤ, stated as the warrant for `BX_f`/`TM^+_f`'s ℤ-time scope)
and `def:TMplus-c`'s footnote (:4010-4017, Dedekind-complete-⇒-Archimedean-⇒-{ℤ,ℝ}, stated as the
warrant for the complete class being exactly {ℤ, ℝ} up to isomorphism, dense-and-complete exactly
ℝ). Per task 442's report §5, the paper names Hölder's theorem without a bibliography entry
(standard-result convention); the book currently doesn't cite it either — match the paper's own
practice unless the user wants a formal reference (style call, not a fact-finding gap).

### 3.5 Objective modality (`app:ObjectiveModality`, :1717–2084) — **[untracked]**, verified live

`def:id` (:1735, `Ref`/`Imp`/`LL`), `def:strongest` (:1904, `Str^O_L(Q)` — clause (1) `⊢O(Q)`,
clause (2) `⊢∀P[O(P)→(Q⪯P)]`, with an explicit remark that objectivity/normality follow from
clause (1) alone so need not be stated separately), `thm:exist` (:1919, `Str^O_L(Bm)`, i.e. `L`
has a strongest objective normal modal operator — proof by detaching `O-Meet`/`O-Fac`/`O-Ax`/
`O-Nec` at `Bm`), `lem:uniq` (:1933, uniqueness up to `⊢∀p(Qp↔Pp)`), `thm:s4` (:1954, S4 via
`O-Comp`), `thm:sym` (:1972, B/Symmetry via `O-Conv`, a long ~15-line proof — compress to the
result and cite, do not reproduce the full chain). `cor:exists` (:2016) is explicitly the
*weaker*, Rule-of-Equivalence-gated route the task description warns not to present as the
paper's existence result — `thm:exist` is that result now.

**The orthogonality point** (task description's foregrounded claim) is drawn from the **Restricted
Modalities** section (`sub:RestrictedModalities`, :1070–1138), specifically the `Stability`
operator footnote at :1080-1082: "the monomodal logic of Stability is also S5 … for non-temporal
φ, the truth-value … depends only on τ(x), so φ→Stability φ is valid, collapsing Stability to the
trivial modality on this fragment." The exact sentence stating the *general* lesson ("an S5 logic
alone cannot single out Box … it is ⪯-leastness rather than S5-hood that picks Box out") is
**currently a commented-out footnote** at `sub:Extension` (possible_worlds.tex:1276-1278, inside a
`%`-block) — it is not live paper text at present. **Do not cite it as a live paper quotation.**
The report should draw the same conclusion in its own voice, from the live `Stability` footnote
plus `def:strongest`/`thm:exist`, rather than quoting the commented sentence as if it were current
paper prose. This is a citation-discipline nuance the planner needs flagged explicitly.

### 3.6 Contingency / irregular worlds (`sub:Extension`, :1225–1360) — **[untracked]**, verified live

The three frame constraints (Discrete/Dense/Complete, :1230-1236), `DF`/`DN`/`CO` (:1245-1249),
the "no order both discrete and dense" sentence (:1251), the necessity-if-true-of-density
paragraph with the Kripke-B/symmetry precedent (:1283-1285), and — the load-bearing footnote —
the **irregular-worlds footnote** at :1286-1293, quoted here in full since the task description
demands the price be stated *exactly*:

> "Dorr and Goodman [p. 656] express sympathy for an account of metaphysical modality able to
> express theses about the contingency of the structure of time. Within the present framework one
> might give voice to such contingency by relaxing totality, admitting *irregular worlds* —
> functions τ : X → W where X ⊊ D is a *coset domain*, a translate G + c of a nontrivial subgroup
> G ≤ 𝒟, and τ(x) ⇒_{y−x} τ(y) for all x, y ∈ X — and defining consequence over the irregular and
> possible worlds alike. Cosets rather than subgroups, since a family of translates is closed
> under ambient translation and so preserves MF and the perpetuity principles, which the subgroup
> formulation loses. The price is exact: every nontrivial ordered abelian group contains a
> discrete cyclic subgroup, so DN is then valid over no frame whatever, and DF fails over discrete
> orders possessing a subgroup that is itself dense, such as ℚ ×_lex ℤ, so the correspondence
> results of app:discrete, app:dense, and app:complete collapse together. These considerations
> recommend possible over irregular worlds."

Note the **sentence immediately after this** in the source ("The broadened operator also
satisfies factivity, normality, and necessitation … displacing Box from its standing as
Str^O_L(Box)") is **also commented out** (:1292, a `%` line) — again, not live paper text. The task
description's own §3.3 bullet asserting this displacement is therefore drawing an inference the
report should make in its own voice (it follows straightforwardly: broadening consequence changes
which operator is ⪯-least), not something to cite as a paper sentence. Flag both commented-out
lines (§3.5 and §3.6) together — same pattern, same fix (state as the report's own analysis,
cross-referenced to `def:strongest`/`thm:exist`, not quoted as paper prose).

The defense paragraph (:1294-1302, S4-vs-S5/converse-closure precedent, correspondence
methodology, "no modality quantifies across frames") and the closing "disjoint union" pointer
(:4083-4084, in `cor:tm-completeness`'s own proof — "a semantic class closed under disjoint union
… is a natural target for future semantics work") are both live and quotable directly.

### 3.7 Completeness / decidability corollaries — **[untracked]**, verified live, verbatim-quotable

`cor:tm-completeness` (:4036) and its proof (:4051-4091) and `cor:tm-decidability` (:4093) and its
proof (:4102-4111) — **task 442's own report already transcribed the key derivation steps
verbatim** (its §4): the dichotomy proof, the exact (DD) derivation via `TMP-NB`+`M5`, the
Halldén-incompleteness clarification, the TM_c/Reynolds-triple caveat, the Lean-status footnote,
and the two decidability witnesses (`DF` over D=ℤ, `CO` over ℤ×_lex ℤ). **Do not re-derive this by
re-reading the paper** — reuse task 442's report §4 verbatim quotes, which this research pass
independently re-confirmed still match the live text at :4036-4111 (no drift since 442's own
research pass).

---

## 4. The (DD) split-validity proof — give in full, per the task's own instruction

This is one of the two arguments the task explicitly wants "in full, briefly" (the other is the
discrete-or-dense dichotomy, which is the same proof, embedded). Both live inside
`cor:tm-completeness`'s proof (possible_worlds.tex:4059-4073), already transcribed in task 442's
report §4 "Halldén-incompleteness clarification" quote — reuse verbatim:

1. **Dichotomy** (2-line proof, verbatim already quoted in task 442's report §4): no least
   positive element ⟹ dense (translation-invariance produces an interpolant); least positive
   element ⟹ discrete (forbids anything strictly between `x` and `x+e`). Depends essentially on
   the *group* structure — fails for a bare linear order (paper's own example: a copy of ℤ
   followed by a copy of ℚ).
2. **Consequence**: `Log(all task frames) = Log(Discrete) ∩ Log(Dense)`; the class of all task
   frames is not closed under disjoint union.
3. **(DD)** names the schema `□φ_DF ∨ □ψ_DN` (no variable-disjointness restriction; `TD` supplies
   past mirrors), valid over every task frame, refuted on the **two-fibre structure** — one fibre
   over ℤ, one over ℝ, `Box` read globally over both — which is TM-sound because no TM axiom or
   rule constrains cross-fibre `Box` behavior. **Diagram target #1** (§7 below).
4. **Taxonomy** (the report must not blur, per the task's explicit demand): TM is *semantically*
   incomplete (valid-but-unprovable formula), not Halldén-incomplete. `TM + (DD)` would *create*
   Halldén-incompleteness (provable variable-disjoint disjunction, neither disjunct provable).
   Halldén-incompleteness of `Log(all task frames)` itself is a *theorem* — signature of a
   union-of-incompatible-classes logic, not a defect.
5. **BL⁺ already proves (DD)**, no added axiom: `TMP-NB` + `M5` give `⊢_TM+ □Next⊤ ∨ □¬Next⊤`;
   since `Next⊤→φ_DF` and `¬Next⊤→ψ_DN` are BL⁺-valid, TM⁺'s weak completeness supplies both
   conditionals as theorems — **which is exactly where TM⁺'s own outstanding base-case obligation
   enters**; carry this hedge explicitly, do not drop it.
6. **TM_c fails identically over {ℤ,ℝ}**; **TM_f's status differs and must not be lumped in** — TM_f
   is sound over the *entire* discrete class (`DF` valid everywhere discrete), but its
   completeness over that broader class is open; the machine-checked discrete result is for the
   strictly stronger `BX_f` over ℤ-time specifically.

---

## 5. The completeness construction as implemented — measured Lean facts

### 5.1 Architecture (matches task description exactly, independently confirmed)

`FormalSystem/Metalogic/BXCanonical/Completeness.lean`: contrapositive + Lindenbaum
(`set_lindenbaum`, `Metalogic/Core/MaximalConsistent.lean`) → **three-way case split** on the
discreteness indicator `Chronicle.nextTop.neg` (`U(⊤,⊥)` in the paper's `def:TMplus-d` notation,
i.e. `¬Next⊤`), via `SetMaximalConsistent.negation_complete` producing
`□(¬Next⊤) ∈ M ∨ ¬□(¬Next⊤) ∈ M`:
- **Dense branch** (`□¬Next⊤ ∈ M`): `countermodel_dense_enriched`, countermodel on `ℚ`.
- **Discrete branch** (in `completeness_discrete`; dense-MCS branch of `completeness_dense` closes
  the other way by deriving `U(⊤,⊥)` as a Discrete theorem): `countermodel_discrete_reynolds_v2`
  (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`), sorry-free.
- **Mixed case eliminated outright**: `mcs_mixed_case_absurd`
  (`BXCanonical/Chronicle/MCSMixedCase.lean:42`) — "an MCS cannot be undecided about
  discreteness." **Diagram target #2** (§7 below).

**The single most illuminating connection the task wants foregrounded**: this three-way split is
the *same* discrete/dense dichotomy that breaks TM at the BL level (§4 above) — the difference is
that BL⁺ has a sentence (`¬Next⊤`) *naming* discreteness and BL does not, so the same fact that
produces (DD)'s unprovable-but-valid disjunction at the BL level is exactly what the BL⁺
completeness architecture case-splits on to make the canonical-model construction go through.
State this explicitly; it is the report's single strongest structural insight.

**Terminology precision, load-bearing**: this architecture is stated throughout in `Metalogic/`'s
own vocabulary — the **BX-system** (`FrameClass.Dense`/`FrameClass.Discrete`/`FrameClass.Base`),
not TM/TM_d/TM_f. Per §1 above, whether/how these connect to the paper's TM-family systems is
explicitly unresolved (task 442 finding 1b) — the report must describe the Lean architecture in
its own terms and not silently rename `completeness_dense` as "TM_d's completeness" or similar.

### 5.2 Module inventory, measured via `find`

```
Metalogic/Algebraic/       (5 files: BooleanStructure, FlowFrame, InteriorOperators,
                             LindenbaumQuotient, UltrafilterMCS)
Metalogic/Bundle/          (13 files: BFMCS, CanonicalFrame, CanonicalTaskRelation,
                             Construction, FMCSDef, LimitMCS(+Coherence), ModalSaturation,
                             RealExtension(+Bundle), SuccRelation, TemporalCoherence,
                             TemporalContent, UntilSinceCoherence, WitnessSeed)
Metalogic/BXCanonical/     (Chronicle/ [13 files], Filtration/ [1], Quasimodel/ [5],
                             CanonicalChain, CanonicalModel, Completeness,
                             CompletenessDedekind, Frame, OrderedSeedConsistency, TruthLemma)
Metalogic/Core/            (DeductionTheorem, MaximalConsistent, MCSProperties,
                             RestrictedMCS/Basic)
Metalogic/Decidability/    (FMP/ [5], Propositional/ [3], Verified/ [Bridge: 14, Termination: 4,
                             Decidable, RuleSpec], Closure, Correctness, CountermodelExtraction,
                             DecisionProcedure, ProofExtraction, Saturation, SignedFormula,
                             Tableau, TraceCertificate, TraceExport, CancellableExpansion)
Metalogic/Soundness.lean, SoundnessLemmas/ (Core, CoValidity, DenseValidity,
                             FrameClassVariants, Separability)
Metalogic/StrongCompleteness.lean
Metalogic/WeakCanonical/   (Kamp/ [huge — "larger than every other directory in Metalogic/
                             combined" per Metalogic/README.md — including a large Boneyard/
                             subtree], DenseModelSurgery/ [8], EFGames/ [7], Expressiveness/ [4],
                             IntegerModel/ [5], RealModel/ [6], Separation/ [3], plus
                             BackAndForth, ChronicleExtraction, ColourOrders, EFGameTactics,
                             FrameProperties, MixedSum, MonadicFO, NEquivalence, NormalForm,
                             OrderedSum, PriorDefs(+Dense), PriorExpressiveness(+Dense),
                             ReflexiveCanonical, StaviConnectives, Table, Transfer, TruthLemma)
```

This module table differs from what a fresh `04-metalogic.typ` rebuild (task 442, already landed)
now shows in the book — reuse the book's rebuilt table as a starting point rather than
re-deriving it, but note this report's own directory list above independently reconfirms it.

### 5.3 Sorry/axiom status — measured, not assumed

`sorry_algebraic = 0` (measured via `typst-status-counts.sh`, §2 above). **This contradicts
`UltrafilterMCS.lean`'s own module docstring**, which reads "Contains sorries pending MCS helper
lemmas" (Phase 5 note) — a literal `grep -n sorry` of that file returns **zero matches**. This is
a stale docstring, not a live obligation; report the measured fact (sorry-free) and do not repeat
the stale prose. Flag it as a documentation-staleness finding for the record, not as an open Lean
obligation — this task's non-goals forbid Lean edits, so the docstring itself is not to be
touched here.

The repository's single live (non-Boneyard) `sorry` is `WeakCanonical/Transfer.lean`, inside
`theorem countermodel_discrete` — **dead code**, per that file's own docstring: the *live* discrete
path is `countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`,
sorry-free), which `completeness_discrete` actually calls. `Metalogic/README.md`'s own
"four-flagship-axiom-set" invariant (`completeness`/`completeness_dense`/`completeness_discrete`/
`countermodel_dense`) records this precisely: `completeness` alone carries `sorryAx` (via that one
dead-code dependency), the other three are exactly `[propext, Classical.choice, Quot.sound]`.

### 5.4 The Dedekind path — live, and correctly the book's current omission per task description

`BXCanonical/CompletenessDedekind.lean` (`completeness_dedekind_engine`, sorry-free per its own
docstring at line 585-600: exactly `[propext, Classical.choice, Quot.sound]`),
`Metalogic/StrongCompleteness.lean` (`completeness_dedekind`, `consequence_completeness_dedekind`,
`consequence_completeness_dedekind_of_engine`, `completeness_dedekind_of_engine`). This file's own
extensive module docstring is directly quotable for the report's terminology-discipline paragraph
(§5.5 below) — it is the in-tree authority the task description names.

### 5.5 Terminology discipline — settled, in-tree authority

`StrongCompleteness.lean`'s docstring is unambiguous and should be paraphrased closely: "strong
completeness" is reserved for consequence from a possibly-infinite `Set Formula`; because
`Context := List Formula` is finite, every finite-context consequence result is inter-derivable
with weak (single-formula) completeness via the deduction theorem, and is called **consequence
completeness**, never strong. Per-class programme status, quoted closely from the same docstring:
Base and Dense — genuine strong completeness is the intended terminus, no known compactness
obstruction, the missing piece is a **model-existence theorem** (every `SetConsistent` set
satisfiable in a class frame) which the single-formula countermodel engines do not supply; Discrete
— strong completeness is **provably false** (non-compact: `{Fp} ∪ {¬Xⁿp : n∈ℕ}` finitely
satisfiable over ℤ, unsatisfiable over any Archimedean discrete carrier); Dedekind — likewise
provably out of reach (Reynolds 1992 Thm 7 is weak completeness for the real-line axiomatization;
compactness fails there too).

### 5.6 Shared infrastructure — confirmed live, matches task description

`Bundle/BFMCS.lean` — a BFMCS is "a bundle of indexed MCS families (FMCS instances) with modal
coherence conditions," enabling a Henkin-style construction where `Box` quantifies over bundled
histories rather than all histories; `modal_forward`/`modal_backward` coherence conditions make
the truth lemma's box case provable. `Algebraic/FlowFrame.lean` hosts the **D-parametric**
algebraic truth lemma (`multiFamTaskFrameGen` proved, once and D-generically, to satisfy all four
`def:frame` axioms — the deterministic-fiber argument discharges *Spherical* via
`sInter_nonempty_of_directed_subsingleton`, a different discharge pattern than the finite-W one).
`BXCanonical/Chronicle/ChronicleConstruction.lean` implements the Burgess 1982 §2 omega-chain
construction over ℚ (`singletonChronicle` → `omegaChain` → `limit_chronicle`), matching the task
description's "Burgess-style chronicle construction" language precisely.

---

## 6. `metalogic.tex`'s superseded "Representation Theorem" section — defects, for the historical-waypoint citation

Read in full at `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex:1-379`
(`\subsection{Representation Theorem}`, `\label{sub:CanonicalModel}`, through `\subsection{Extensions}`
at :337). Confirmed: **not** `\input`-ed by `possible_worlds.tex` (no `\input{metalogic}` anywhere
in the live paper), consistent with the task description's characterization. Concrete defects,
verified by direct read rather than taken on the task description's word alone:

1. **Fixed canonical temporal order.** `def:canonical-temporal-order` (:42-44) hard-codes
   `T^c = ⟨ℤ, +, ≤⟩` — not D-parametric, unlike the live `FlowFrame.lean` construction (§5.6).
2. **`thm:representation` (:148-156) claims TM is representable over a single fixed ℤ-carrier
   frame**, and its corollary `cor:frame-characterization` (:171-178) asserts outright: "**TM is
   sound and complete** with respect to the class of all task semantic frames … T is a totally
   ordered abelian group (typically ℤ or ℝ)." This directly **contradicts `cor:tm-completeness`**,
   which establishes TM is sound but *provably incomplete* via the (DD) two-fibre countermodel
   (§4 above). Do not restate this claim in any form (task's own non-goal).
3. **The Box case of the Truth Lemma (:227-243) is genuinely circular/hand-waved**, exactly as
   the task description says: the (⇒) direction states "we need to show that φ ∈ τ_Δ(t) for all
   Δ ∈ W^c" then proves it by assuming `Box φ ∈ τ_Γ(t)` implies agreement across *every* canonical
   history directly from the S5 axioms — i.e., it assumes what a genuine canonical-model Box case
   must derive from an accessibility/modal-saturation construction, rather than routing through
   one. The live Lean architecture's actual Box case is the BFMCS `modal_forward`/`modal_backward`
   coherence machinery (§5.6) — a materially different (and actually discharged) argument.
4. **`thm:weak-completeness` and an unlabeled companion strong-completeness claim** (:271, "this
   section makes the derivation explicit, establishing both weak completeness … and strong
   completeness") assert exactly the blanket strong-completeness-for-TM claim `cor:tm-completeness`
   and `StrongCompleteness.lean`'s own docstring (§5.5) both explicitly refute (strong completeness
   provably fails for the discrete and Dedekind-complete classes).
5. **Compositionality is asserted, not proved**, per the task description — confirmed structurally:
   `thm:representation`'s proof (:158-167) cites `thm:canonical-nullity`/`thm:canonical-compositionality`
   by label without their content appearing in the section as read; this pattern ("we can construct
   a history…") is consistent with the task description's characterization even though this
   research pass did not chase every forward-referenced lemma into the file's remainder.

**Disposition for the report**: cite this section only as a historical waypoint, name defects
1-4 above explicitly if cited at all, and do not lift any definition, theorem statement, or proof
step from it. If any individual claim is worth salvaging (e.g., the general shape of a Truth Lemma
by induction), it must be re-derived against the current `def:frame`/`cor:tm-completeness`, not
quoted.

---

## 7. Diagram targets — content sketches against the book's existing cetz idiom

The book's `00-introduction.typ` (light-cone diagram) and task 442's newly-added `04-metalogic.typ`
diagrams (two-fibre Z/R countermodel, three-way case-split — already built and compiled in the
book) establish the idiom: single-canvas, geometric, `cetz.draw.line`/labeled math strings,
`#align(center)`. Since `FormalFoundations.typ` is standalone and NOT `#include`d by the book, it
needs its own diagram code (cannot reference the book's canvas), but should visually rhyme with
it for a reader moving between the two documents.

1. **Two-fibre Z/R countermodel for (DD)** (task's diagram target, §4 point 3 above) — two
   parallel strips, one labeled ℤ with discrete tick marks, one labeled ℝ continuous; a global
   `Box` operator symbol spanning both; `Next⊤` true only on the ℤ fibre, `¬Next⊤` true only on
   the ℝ fibre, visualizing why `□φ_DF ∨ □ψ_DN` is valid-everywhere-but-unprovable.
2. **Three-way discreteness-indicator case split** (§5.1) — a decision node on
   `□(¬Next⊤)`/`¬□(¬Next⊤)` branching to {Dense: `countermodel_dense_enriched` on ℚ}, {Discrete:
   `countermodel_discrete_reynolds_v2` on ℤ}, with the Mixed branch struck through/marked
   `mcs_mixed_case_absurd`. Consider annotating this diagram with the "same dichotomy that breaks
   BL, makes BL⁺ go through" callout (§5.1's headline connection) directly on the figure.
3. **Representation-theorem landscape** (task's diagram target #3) — two parallel routes from
   "task-model class" toward "representation theorem": (i) the algebraic route (live: Lindenbaum-
   Tarski algebra → ultrafilters → interior operators → Jönsson-Tarski target, marked ARCHIVED/
   task 125 at its terminus per §0); (ii) the shift-set route (NOT STARTED: design doc → task 424
   gate → S2-S5 ultraproduct pipeline, per §8 below). Label each stage's live/target/archived
   status explicitly on the diagram — this is the one diagram where getting the status-marking
   right matters more than the geometry, per the task's acceptance criterion 5.

Additional candidates (task lists as "if space allows"): fiber/cone/segment apparatus (reuses
`def:task-relation`'s own notation, could extend the light-cone drawing primitives conceptually
but needs fresh cetz code since this doc is standalone); the frame-class lattice Base/Dense/
Discrete/Dedekind (task 442 already built this one in `p2-frame-classes.typ` — the ASCII art in
`ProofSystem/Axioms.lean:~425-440` gives the exact non-diamond shape, Dedekind strictly above
Dense; if included here, replicate the shape, don't re-derive it as a naive 4-leaf diamond).

---

## 8. The way-forward material — grounded in the actual design document

Per §0, items (b)/(c) of the task description's §3.7 are targets, not existing work — the
way-forward section (task description §3.7's six-point outline, (a)-(f)) should be written from
this basis, and can draw directly and accurately on the archived design document at
`specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md`,
which is exactly the "GATING RULE" / "Representation theorem (shift sets)" / "Route B four steps"
/ "Risks R1-R4" material the task's own outline (d)/(e)/(f) points ask for:

- **Shift-set statement** (both directions), quoted in the design doc's "Representation theorem
  (shift sets)" section (verified present at that file's lines 132-178): forward direction — a
  shift set `⟨Ω, D, sh, A⟩` (D an ordered abelian group, Ω nonempty, `sh : Ω → D → Ω` a D-action,
  `A : Atom → Ω → Prop`) induces a task model by construction; reverse direction — any
  `(F, M, Omega, ShiftClosed Omega)` induces a shift set via `WorldHistory.timeShift` and
  `FormalSystem.Semantics.TimeShift.time_shift_preserves_truth` (`Truth.lean:446`). **Caveat for
  the planner, not to smooth over**: this statement is written against the pre-task-414
  `Omega`-parameterized `TruthAt` signature; task 414 has since landed (§0), eliminating that
  parameter, so the literal Lean snippet needs restatement (not re-derivation of the underlying
  argument, which the design doc itself argues survives — "Omega := H_F is the totality-fixed
  special case of the general argument") before task 424 executes. State this precisely rather
  than either ignoring it or treating it as invalidating the route.
- **Route B, four steps** (S1 gate → S2 ultraproduct → S3 Łoś lemma for `TruthAt` → S4 model
  existence/compactness → S5-Dense/S5-Base strong completeness), with the **rejected alternative**
  recorded (Mathlib's `FirstOrder.Language` is single-sorted; the signature here is genuinely
  two-sorted `⟨Ω, D⟩`, so a bespoke ultraproduct was chosen over an encoding).
- **Four named risks** (R1 dependent-ultraproduct-of-carriers — "the single largest unknown in the
  whole estimate"; R2 the `box` case of Łoś needing a choice-function argument; R3 `Type` vs
  `Type*` universe constraint on `valid` — must be asserted early; R4 honest uncertainty — "no
  compactness proof here, only an argument from elementarity … Verdict: promising, not certain").
- **The GATING RULE itself**: task 424 is a cheap feasibility gate for the entire
  ultraproduct/strong-completeness branch; S2-S5 are explicitly NOT authorized and have
  deliberately not been created as tasks; the acceptance standard is sorry-free Lean in BOTH
  directions with clean `#print axioms` on each — a type-checking-with-sorry statement does not
  pass, one direction does not pass, a prose argument does not pass. This is precisely the
  acceptance standard the task description's §3.7(e) asks the report to be explicit about, and it
  already exists verbatim in-tree; quote it rather than inventing a paraphrase.

For task description point (b) (the group-structure abstraction: dropping D from an ordered
abelian group to a bare linear order dissolves the discrete-or-dense dichotomy, per §4's proof
depending essentially on the group structure) and point (a) (which of `def:frame`'s four axioms
are genuinely needed, *Spherical* as prime suspect): these are the report's own synthesis, not
something already written down in the codebase — the task description is correct that this is
"the single most valuable analysis it can contain," and it is squarely the planner/implementer's
job to write it (this research report's job is to hand over the grounding facts, which §4-§6
above do). One grounding fact worth flagging for that synthesis: `FlowFrame.lean`'s *Spherical*
discharge (§5.6, deterministic-fiber/subsingleton argument) is a *third* discharge pattern beyond
the paper's own two (`cor:spherical-finite` for finite W; the general Zorn-based `thm:extension`
route) — useful concrete evidence for what stays available if *Spherical* is weakened rather than
dropped outright.

---

## 9. Typst conventions confirmed for the new file

`typst/template.typ` exports `#let definition/theorem/lemma/axiom/remark/proposition/corollary/
example` via `thmbox` (imported `@preview/thmbox:0.3.0`) plus `fletcher` for diagrams (imported
but the book's existing diagrams use raw `cetz` canvases, per `00-introduction.typ` and task 442's
new `04-metalogic.typ` diagrams — confirm which the new report should use; `fletcher` is imported
in `template.typ` already so either is available). `typst/notation/bimodal-notation.typ` exports
the notation this report needs directly usable: `#allpast`/`#allfuture`/`#somepast`/`#somefuture`
(H/G/P/F), `#always`/`#sometimes` (△/▽), `#taskframe`/`#Dur`/`#worldstate`/`#taskrel`, `#taskto(x)`
(⇒_x), `#history`/`#althistory`/`#domain`/`#histories` (τ/σ/dom/H), `#satisfies`/`#notsatisfies`,
`#truthat(m,t,x,phi)`, `#derivable(gamma,phi)`, `#valid(phi)`, `#framevalid(f,phi)`, plus a family
of `#leanTaskRel`/`#leanTimeShift`/etc. raw-identifier helpers for citing Lean names inline. Import
both `typst/notation/bimodal-notation.typ` and `typst/template.typ` per the task's own §1
instruction — this notation set already covers essentially every symbol the report's §3.1-3.2
content needs without inventing new `#let`s.

`typst/bibliography.bib` already carries every citation key this report needs (confirmed by
direct grep, all landed by task 442): `burgess1982axioms`, `reynolds1992`, `doets1987`,
`kamp1971formalproperties`, `prior1967pastpresentfuture`, `dorr2020diamonds`,
`rumberg2019firstorder`, `bacon2022necessities`, `walsh2016predicativity`. No new bibliography
entries are needed for this report. `vlach1973nowandthen` is cited elsewhere in the book, not
obviously needed here (the report doesn't touch the store/recall operators).

`typst/README.md` currently documents `BimodalReference.typ`'s build target only; the task's §1
and acceptance criterion 6 require adding this report's own build command
(`cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf`) as a **new,
separate** entry — do not fold it into the existing book-build section, since this is explicitly
not a book chapter.

---

## 10. Punch list for the planner

1. **Section 3.1-3.2** (system compressed, key theorems): almost entirely citation-and-compress
   work against §3 above's citation package; no open questions.
2. **Section 3.3** (contingency pain point): use the irregular-worlds footnote verbatim (§3.6
   above quote); explicitly do NOT quote the two commented-out paper sentences (§3.5/§3.6's
   "orthogonality"/"displacement" claims) as paper text — state them as the report's own analysis.
3. **Section 3.4** ((DD)/incompleteness pain point): reuse task 442's report §4 verbatim quotes
   directly (already independently re-confirmed current, §3.7 above); build diagram #1 (§7).
4. **Section 3.5** (objective modality pain point): citation package in §3.5 above is complete;
   the orthogonality point's grounding is the live `Stability` footnote, not the commented-out
   `sub:Extension` footnote — use the former.
5. **Section 3.6** (completeness construction): use §5 above's measured architecture; state the
   BX/TM cross-reference question (task 442 finding 1b) as explicitly open, do not resolve it;
   build diagram #2 (§7); correct the `UltrafilterMCS.lean` stale-docstring point rather than
   repeating "contains sorries."
6. **Section 3.7** (representation + way forward): **the most consequential correction this
   report makes** — write (b)/(c) as targets (not_started task 424; archived-to-Boneyard task 125),
   not as existing work; ground the way-forward outline in the actual design document (§8 above);
   build diagram #3 (§7) with explicit live/target/archived status labels.
7. **metalogic.tex citation**: if cited at all, name defects 1-4 from §6 above explicitly; do not
   lift any statement.
8. **Build/gate acceptance**: re-run `check-paper-definitions.sh` and `typst-status-counts.sh`
   immediately before the final citation pass (both may have drifted again by execution time,
   same dynamic task 442 encountered repeatedly); `typst-sync-check.sh` Check 1 will need every
   backticked Lean identifier in the new file to resolve or be whitelisted — the identifiers named
   in §5 above (`mcs_mixed_case_absurd`, `completeness_dense`, `completeness_discrete`,
   `countermodel_dense_enriched`, `countermodel_discrete_reynolds_v2`, `completeness_dedekind`,
   `consequence_completeness_dedekind`, module paths under `Metalogic/Algebraic/`, `Bundle/`,
   `BXCanonical/Chronicle/`) were all confirmed to exist at their stated locations in this
   research pass and should resolve cleanly; the design-doc-only shift-set names (`ShiftSet`,
   `sh`, etc.) do NOT exist in Lean and must not be backticked as if they were live identifiers —
   render them as ordinary math/prose instead.
9. **`typst/README.md`**: add the new build command as its own entry (§9 above), not folded into
   the book's build section.
