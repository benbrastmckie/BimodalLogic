# Research Report: Task #438

**Task**: reconcile_semantic_definitions_with_jpl_paper
**Date**: 2026-08-09
**Mode**: Team Research (4 teammates)
**Completed**: 2026-08-09

Authoritative source for all paper claims below:
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (read-only). All paper
citations are by `\label` anchor with verbatim quotation; a bare line number, where it appears,
is a parenthetical locator for the label only, never a citation in itself. All Lean claims are
file path + declaration name, re-verified independently by at least two teammates against the
current tree on 2026-08-09.

This report is the complete Part A deliverable for task 438 and is written to be directly
executable by a later `/plan`/`/implement` dispatch rewriting the six paper-refactor cluster task
descriptions (Part B). Nothing here edits `FormalSystem/`, `latex/`, `typst/`, the paper,
`ROADMAP.md`, or `specs/state.json` — those are all downstream consumers of this report.

## Summary

- **The paper's `def:frame` now has four axioms** (Compositionality — now a **biconditional** —
  Seriality, Limit, Spherical), with Nullity demoted to a derived lemma (`lem:nullity`) and
  Occurrence demoted to a derived theorem (`thm:occurrence`). Confirmed independently by all four
  teammates against the paper's `\label{def:frame}` (`possible_worlds.tex:2412-2465`).
- **Logical consequence now quantifies over TOTAL world histories** (`X = D`, i.e. possible
  worlds, `H_F`), per `\label{def:world-history}` (`:2570-2579`) — not maximal histories under
  Mathlib `IsMax`, which is what task 414's existing research targets. This is confirmed as a
  genuine, not merely cosmetic, predicate mismatch (Teammate C, Starting-Fact row 11).
- **All four `def:frame` axioms are load-bearing for `thm:extension`** (Compositionality via
  `lem:segments`, Seriality for one-sided fibers, Limit via `lem:nullity`, Spherical for the
  two-sided/directed case) — this corrects a narrower reading in the task description that risked
  attributing totality's non-vacuousness to Spherical alone. See Conflict 1 below.
- **Task 419's proposed countermodel sketch is at serious risk of not being a legitimate
  `TaskFrame` at all under the new axioms, not merely in need of a conformance re-check.** The
  paper's own worked non-example for Spherical (`possible_worlds.tex:926`, a ℚ-carrier flow
  construction, quoted in full below) is structurally near-identical to 419's proposed Q-flow
  CO/Reynolds countermodel sketch — and the paper uses that exact construction to demonstrate a
  structure that **violates Spherical**. Since Spherical is now a hard `def:frame` requirement,
  419's sketch may need an entirely different carrier/frame choice, not just a proof update. See
  Deliverable 4's Task 419 section for the full analysis.
- **The current repo state is stale on both axes in `FormalSystem/Semantics/`, and stale by
  different amounts in `latex/` vs. `typst/`** (latex is one generation behind: matches Lean's lax
  Compositionality but not Seriality/Spherical; typst is two generations behind: still has an
  independently-axiomatized Reflection and no Limit clause at all).
- **The six-task `paper-refactor` cluster (414/415/417/419/420/427) is confirmed unchanged** by
  re-query, and is the correct scope for Part B's rewrite — but it is **not** the full blast
  radius of the definitional change itself. Task 424 (`strong_completeness`, gates the entire
  ultraproduct branch) hard-codes the current Omega-parameterized semantics via an archived design
  doc and will silently break once 414 lands; `ROADMAP.md`'s own "Paper Alignment Programme"
  section is a fourth stale artifact untouched by Part B. See Conflict 2 and the Blast Radius
  section below.
- **The dependency cycle in `specs/state.json` is a strict 2-cycle** (`420 ↔ 415`), not merely the
  3-cycle the task description names; it resolves by dropping `415` from `420.dependencies` while
  preserving the phase-6-level wait as descriptive `blockers` text rather than a graph edge.
- **The paper is under continuous, task-numbered, diff-tracked revision** (59 commits to
  `possible_worlds.tex` in the last 14 days, 288 total; 139 machine-parseable `%% CHANGE`/`%% OLD`
  comment pairs already in the file) — this is the paper's steady operating mode, not a spike to
  wait out. Recurrence prevention (a generated definitions-of-record file plus a lint script) is
  a first-class recommendation for Part B's follow-up, not an optional nicety.

## Deliverable 1 — Three-Way Reconciliation Table (from A, corrected by C)

Columns: **Paper** (verbatim quote + `\label`) | **Current Lean** (declaration + file:line) |
**Current repo prose** (file + section) | **Verdict**. Produced by Teammate A via direct `Read`
of the paper and `Read`/`grep` of the current Lean/prose tree on 2026-08-09; independently
cross-checked (not merely trusted) by Teammate C's Starting-Fact Audit, which confirmed all
eleven of the task description's own starting claims and found the reconciliation table itself
accurate except for one correction (satisfiability row, applied below). Confidence: **high**
(Teammate A) / **high** (Teammate C cross-check).

### `def:frame` and its supporting machinery

| # | Clause | Paper (`\label{def:frame}`, verbatim) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------------------|---------------|---------------------|---------|
| 1 | World States | "A nonempty set of *world states* $W$." | `TaskFrame.WorldState : Type` (`TaskFrame.lean:154`) — carries no nonemptiness witness | latex `Task Frame` def item 1: "$\worldstate$ is a nonempty set" (states nonemptiness in prose, not a formal hypothesis); typst `Task Frame` def: `W` listed with no nonemptiness qualifier at all | **stale** (Lean: absent field; typst: absent even in prose) |
| 2 | Temporal Order | "A **nontrivial** totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$." | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` structure binders (`TaskFrame.lean:152`) — **no `[Nontrivial D]` binder on the structure itself**; `Nontrivial D` is supplied ad hoc downstream (e.g. `Metalogic/Soundness.lean:1066`, `StrongCompleteness.lean:131`) rather than as a structural guarantee | latex: "nontrivial totally ordered abelian group" (matches paper prose); typst: "Temporal durations" with no nontriviality qualifier | **stale** (Lean structural binder; typst prose) — latex prose text matches |
| 3 | Task Relation header (primitive on $D^+$, converse convention, fiber, cone, segment) | "A parameterized task relation $\Rightarrow \subseteq W \times D^+ \times W$ ... extended to negative durations by the *converse convention* $w \Rightarrow_x u \coloneq u \Rightarrow_{-x} w$ ... the *fiber* $\Fib(w, x) \coloneq \{u \in W : w \Rightarrow_x u\}$ ... the *cone* $(w)_x \coloneq \{u \in W : w \Rightarrow_y u \text{ where } |y| < x\}$ ... the *segment* $\Seg(w, v; a, b) \coloneq \Fib(w, a) \cap \Fib(v, -b)$, where the fibers count among the segments as the cases in which one constraint is left vacuous" | `TaskRel` (two-sided, `TaskFrame.lean:156`), `converse` field (`TaskFrame.lean:191`, exact match to the converse convention). **`Fib`, `(w)_x` cone, and `Seg` have no Lean counterpart anywhere in the tree** (confirmed by grep: no `Seg`, `Fib`, `Segment`, `Fiber`, `Seriality`, `Spherical`, or `Occurrence` token anywhere under `FormalSystem/Semantics/`) | latex: states converse convention and cone $\taskcone{w}{x}$ (def item 3) but **no segment/fiber notation at all**; typst: states only the bare `TaskRel` type, **no converse convention formula, no cone, no fiber, no segment** | **match** (converse convention only) / **absent** (fiber, cone-as-named-object beyond the docstring comment, segment) — segments and fibers are needed by Spherical/Seriality/thm:extension and are wholly new machinery for the Lean tree |
| 4 | *Compositionality* | "$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$." | `forward_comp` (`TaskFrame.lean:177`): `∀ w u v x y, 0 ≤ x → 0 ≤ y → TaskRel w x u → TaskRel u y v → TaskRel w (x+y) v` — this is the **one-directional (⊇) inclusion only**, with `u` as a fixed universal argument rather than the paper's existentially-bound witness | latex def item 2 (Compositionality): "if $w \taskto{x} u$ and $u \taskto{y} v$, then $w \taskto{x+y} v$" — same lax one-directional form as Lean, and its own prose (line 56) explicitly states the inclusion "rather than the corresponding equality, which would additionally assert interpolation" — **this is precisely the position the paper has now reversed**; typst def item 3: same one-directional conditional form, no biconditional | **stale** (Lean and both prose documents state the now-superseded lax law; the paper has since adopted the biconditional, absorbing what the cluster's prior task descriptions called "Interpolation... NOT adopted") |
| 5 | *Seriality* (new) | "For every $w \in W$ and $x \in D^+$, $w \Rightarrow_x u$ for some $u \in W$, and $v \Rightarrow_x w$ for some $v \in W$." | **absent** — no field, no lemma, no derived theorem anywhere under `FormalSystem/Semantics/` | **absent** in both latex and typst (the only "Seriality" grep hit in the whole `FormalSystem/` tree is an unrelated proof-theoretic comment in `Metalogic/BXCanonical/Frame.lean:157`, not this semantic axiom) | **absent** everywhere |
| 6 | *Limit* | "$\bigcap_{x > 0} (w)_x = \{w\}$." | **absent as a field.** `TaskFrame.lean`'s own docstring (lines 65-72) already documents the intended transcription `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w` and provides two *helper theorems that discharge it against a bare relation* rather than a frame field: `TaskFrame.limit_nullity_of_succOrder` (line 261) and `TaskFrame.limit_nullity_of_shift` (line 289), plus a corollary `TaskFrame.exists_uniform_radius_of_finite` (line 340) | latex def item 3 ("Limit Nullity"): "$\bigcap_{x > 0} \taskcone{w}{x} = \{w\}$" — **prose matches the paper's Limit clause exactly**, but under the retired compound name "Limit Nullity"; typst: **absent entirely** | **stale-by-naming, structurally absent** (Lean: not a field, only discharge helpers for a bare relation; latex: content matches but under the retired name; typst: fully absent) |
| 7 | *Spherical* (new) | "Every $\supseteq$-directed family of nonempty segments has a nonempty intersection, where a nonempty family of segments is *$\supseteq$-directed* just in case any two members include a common member of the family." | **absent** — no field, no directedness predicate, no segment type to state it over | **absent** in both latex and typst | **absent** everywhere; this is the axiom whose transcription cost is analyzed below (Deliverable 3) |
| 8 | "No condition beyond these axioms... the *Occurrence* condition... is derived in `\ref{thm:occurrence}`" | (closing remark to `def:frame`, no separate label) | Confirmed no `Occurrence` token anywhere under `FormalSystem/Semantics/` — never a Lean-side axiom in this repo's stale three-field structure either | Neither prose document names "Occurrence" as a condition or theorem | **n/a to reconcile** on the axiom side; `thm:occurrence` itself (a real theorem) is absent from Lean — see row 15 below |

### `lem:nullity` and the demoted status of Nullity

| # | Clause | Paper (`\label{lem:nullity}`, verbatim) | Current Lean | Current repo prose | Verdict |
|---|--------|-------------------------------------------|---------------|---------------------|---------|
| 9 | Nullity (now a derived lemma, not an axiom) | "$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$." Proved from Seriality at $x=0$ together with Limit; also over-determined from Compositionality + Limit alone. | `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` is a **structure field / axiom** (`TaskFrame.lean:163`), the strictly stronger **biconditional** form (paper's version is reflexivity only, no injectivity-at-zero). Derived `TaskFrame.nullity` theorem (`TaskFrame.lean:202`) restates the reflexivity half from the axiom, trivially — NOT the paper's proof | latex def item 1 ("Nullity"): states the **biconditional** form as an *axiom*, matching Lean's current (stale) axiomatization, not the paper's demoted status; typst def item 1: states only the reflexivity half, as an axiom (stale relative to demotion, but at least states the correct one-directional content) | **stale everywhere**: paper demotes Nullity from axiom to lemma and weakens its content to bare reflexivity; Lean and latex both still axiomatize the biconditional (asserting an unneeded injectivity-at-zero direction while failing to derive it); typst axiomatizes the correct weaker content but still as an axiom, not a lemma |

### `def:world-history` (totality, extension order) and dependent theorems

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 10 | World history (base definition) | `\label{def:world-history}`: "A *world history* over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ where $X \subseteq D$ is a nonempty convex set and $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$." | `WorldHistory` structure (`WorldHistory.lean:75`): `domain : D → Prop` (78), `convex` (88, matches), `states` (94, dependent function, matches once $X$ is read as the subtype of `domain`), `respects_task` (103, matches exactly) | latex `World History` def: dependent function form, matches; typst `World History` def: same, matches | **match** on the base (non-total) definition, in all three artifacts |
| 11 | Total / possible world | Same `\label{def:world-history}`: "A world history is *total*--- equivalently, a *possible world*--- just in case $X = D$... The set of all total world histories over $\F$ is denoted $H_{\F}$." | **absent.** No `IsTotal`/`total` predicate, no `H_F`-as-total-subset construction. The nearest Lean object is `Omega : Set (WorldHistory F)` (`Truth.lean`/`Validity.lean`), an arbitrary shift-closed parameter, not the canonical total-history set | latex/typst: no totality notion anywhere; both simply write $H_{\F}$/$\histories_{\taskframe}$ as "all world histories over frame" | **absent** everywhere — this is the central gap driving the totality-based-consequence change |
| 12 | Extension order | Same `\label{def:world-history}`: "$\sigma$ *extends* $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$." | **absent.** No `Extends`/`≤` instance, no `Preorder (WorldHistory F)` in the current tree (a prior ~85-line 414-adjacent prototype with a `Preorder`/`chainSup` exists only in research artifacts, not in `FormalSystem/`) | **absent** in both latex and typst | **absent** everywhere |
| 13 | `app:gluing` (binary gluing corollary) | "For any frame... world histories $\tau_1, \tau_2$... the function $\tau$ on $X_1 \cup X_2$... is the unique world history over $\F$ ... that restricts to both." Proof uses Compositionality (right-to-left) and the converse convention; **footnote**: *directed* gluing additionally rests on Spherical via `thm:extension`, not on Compositionality alone. | **absent** — no gluing lemma anywhere in `WorldHistory.lean` | **absent** in both prose documents | **absent** everywhere |
| 14 | `lem:segments` | "If $h : A \cup C \to W$ is task-constrained where $t < z < s$ for all $t \in A$, $s \in C$, then the segments $\Seg(h(t), h(s); z-t, s-z)$ for $t \in A$, $s \in C$ form a $\supseteq$-directed family of nonempty segments." | **absent** | **absent** in both prose documents | **absent** everywhere — direct prerequisite of `thm:extension` |
| 15 | `thm:extension` | "For any frame... every task-constrained function $h : S \to W$ on a nonempty $S \subseteq D$ is extended by some total world history $\sigma \in H_{\F}$." Proof appeals to Zorn's lemma (AC). | **absent** as stated. A prior 414-adjacent prototype (`timeShift_mono`, `isMax_timeShift`, `chainSup`, `exists_maximal_extension`) targets **maximal-history** (`IsMax`), a *different* predicate from totality, and is not merged into `FormalSystem/Semantics/` at all (grep for `IsMax`/`maximal` returns nothing there) | **absent** in both prose documents (extension-to-total is asserted informally in the paper's `sec:Construction` prose, but neither repo file mirrors it) | **absent** everywhere in this repo's Lean/prose |
| 16 | `thm:occurrence` | "For every frame... and world state $w \in W$, there are a total world history $\tau \in H_{\F}$ and a time $y \in D$ where $\tau(y) = w$." (Derived from `lem:nullity` + `thm:extension`; needs AC.) | **absent** | **absent** in both prose documents | **absent** everywhere |
| 17 | `app:nonempty` ($H_{\F} \neq \emptyset$) | "For any frame... there is a total world history $\tau \in H_{\F}$ with $\tau(x) = w$, and so $H_{\F} \neq \emptyset$." | **absent** as a theorem about a total-history set; `Omega.Nonempty` is never established generically — instead folded into every `valid`/`SemanticConsequence` binder as the unproven hypothesis `τ ∈ Omega` | **absent** in both prose documents | **absent** everywhere |

### `def:BL-model`, `def:BL-semantics` (truth clauses)

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 18 | Model | `\label{def:BL-model}`: "A *model* of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$ is a frame and $\vert{p_i} \subseteq W$..." | `TaskModel` (`TaskModel.lean:49`): `valuation : F.WorldState → Atom → Prop`, extending a `TaskFrame` — structural match | latex/typst `Task Model` defs both structurally match | **match** (structurally; inherits frame-level staleness transitively, but the wrapper itself is not independently stale) |
| 19 | Atom clause | `\label{def:BL-semantics}` ($p_i$): "$\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in \vert{p_i}\vert$." **No domain-membership conjunct** (paper's own `%% CHANGE (task 52 total-histories)` comment: "atom clause loses the dom conjunct, matching the total, bivalent body clause") | `TruthAt` atom case (`Truth.lean:130`): `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` — **carries an explicit existential domain-membership proof** | latex/typst atom clauses both **carry the domain conjunct** | **stale everywhere**, but entailed by the totality gap rather than independent — once `τ` is total, `τ.domain t` is provably always true and the conjunct becomes vacuous. Not a clause to patch in isolation; falls out once totality lands (see Deliverable 2) |
| 20 | Falsum clause | "$\M,\tau,x \nvDash \bot$." | `Truth.lean:131` | latex/typst match | **match** |
| 21 | Implication clause | Standard material conditional | `Truth.lean:132` | latex/typst match | **match** |
| 22 | Box clause (quantifier domain) | "$\M,\tau,x \vDash \Box \varphi$ *iff* $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$" — **total** histories only | `Truth.lean:133`: `∀ (σ : WorldHistory F), σ ∈ Omega → TruthAt M Omega σ t φ` — quantifies over an **arbitrary parameter set `Omega`**, generically not "the total histories" (`Validity.lean:44-45`'s own docstring frames `ShiftClosed Omega` as meant to be "equivalent to... `Set.univ`", i.e. all histories, not just total ones) | latex/typst box clauses quantify over *all* world histories (no totality restriction) | **stale everywhere** — this is the box clause's quantifier-domain divergence named explicitly by the task description, confirmed |
| 23 | Past/Future clauses | Standard, quantify over all $y \in D$ | `Truth.lean:134-137`, `future_iff`/`past_iff` — match | latex/typst match | **match** |

### `def:frame-validity`, `def:logical-consequence`, `def:soundness`, satisfiability

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 24 | Frame validity | `\label{def:frame-validity}`: "$\vDash_{\F} \varphi$ iff $\M,\tau,x \vDash \varphi$ for every model $\M$..., possible world $\tau \in H_{\F}$, and time $x \in D$." Never vacuous since $H_{\F} \neq \emptyset$ per `\ref{app:nonempty}` (a theorem, not an assumption) | No `valid_over_frame`/frame-relative $\vDash_{\F}$ predicate exists in `Validity.lean` at all — only the fully-universally-quantified `valid`; nonemptiness of the evaluation set is never a theorem, only assumed as `τ ∈ Omega` | Neither latex nor typst has a distinct frame-relative validity definition either | **absent** (no Lean or prose counterpart at all — a genuine gap independent of the totality change, though the totality change is what would make `\ref{app:nonempty}`'s guarantee available as a theorem) |
| 25 | Logical consequence | `\label{def:logical-consequence}`: "$\varphi$ is a *logical consequence* of $\Gamma$... iff for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$." $\tau$ ranges over **total** histories ($H_{\F}$) only. | `SemanticConsequence` (`Validity.lean:103`): quantifies over `τ ∈ Omega`, an arbitrary shift-closed parameter, not the total-history set specifically | latex/typst `Logical Consequence` defs: "history $\tau \in \histories_{\taskframe}$" — no totality restriction, ranges over *all* world histories | **stale everywhere** — the precise clause the task description names as changed. Lean's `∀ D F M` decomposition (vs. paper's "for all models $\M$", which already packages a frame) is a harmless refinement, not itself a divergence |
| 26 | Validity (as special case of consequence) | Same `def:logical-consequence`: "$\varphi$ is *valid* just in case $\vDash \varphi$" ($\emptyset \vDash \varphi$) | `valid` (`Validity.lean:79`) defined independently; `valid_iff_empty_consequence` (`:331`) proves the two coincide — no substantive divergence beyond row 25's staleness | latex/typst both state validity as consequence of the empty set — arguably closer to the paper's own phrasing than Lean's independently-restated version | **stale** (inherits row 25's staleness; the definitional strategy difference is not itself a divergence) |
| 27 | Satisfiability | **No paper `\label`'d definition exists.** `\label{def:logical-consequence}`'s validity clause is the closest formal anchor; satisfiability appears only informally (footnote at line 518, worked examples at 1390-1394). Confirmed independently by Teammate C (`grep -in satisfiab` finds only informal prose, no `Ddef`). | `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable` (`Validity.lean:129,138,154`) — existential-witness definitions, structurally reasonable, inherit row 25's `Omega`-vs-totality staleness by construction | latex `Satisfiability` def (157), typst `Satisfiability` def (158) — both give an existential-witness definition of their own invention | **N/A — no paper definition exists to reconcile against.** This is an agreed correction to the task's own deliverable-1 spec (Conflict 3, below): the reconciliation table's satisfiability row must not be populated from repo prose alone, since that would silently substitute the very kind of non-authoritative source this task exists to correct. The existing Lean/prose satisfiability definitions are self-consistent extrapolations from validity and should inherit whatever `H_F`/totality fix lands for validity/consequence, as a design decision, not a reconciliation finding. |
| 28 | Soundness | `\label{def:soundness}`: "**TM** is *sound*... iff $\Gamma \vDash \varphi$ whenever $\Gamma \vdash \varphi$." | Not located within this audit's file scope (`TaskFrame.lean`, `WorldHistory.lean`, `Validity.lean`, `Truth.lean`); `Metalogic/Soundness.lean` exists but is out of scope here and necessarily inherits whatever `SemanticConsequence` ends up meaning | Neither prose document states soundness as a labeled definition | **out of audited scope** — noted for completeness, not verified in depth |

## Deliverable 2 — Target Lean Signatures (from A; proposal, not settled)

These are **proposed target signatures only — not implemented anywhere in this research
dispatch**, per the task's hard non-goal against touching `FormalSystem/`. They give downstream
research one unambiguous target and deliberately flag open design choices rather than resolve
them silently.

### `TaskFrame` structure

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] where                              -- NEW: nontriviality now a structure binder
  WorldState : Type
  world_nonempty : Nonempty WorldState                 -- NEW: paper's "nonempty set of world states"
  TaskRel : WorldState → D → WorldState → Prop
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w  -- UNCHANGED

  -- Compositionality, now a BICONDITIONAL (was: one-directional `forward_comp`).
  -- `u` is existentially bound on the right, not a universal argument of the whole clause.
  compositionality : ∀ w v x y, 0 ≤ x → 0 ≤ y →
    (TaskRel w (x + y) v ↔ ∃ u, TaskRel w x u ∧ TaskRel u y v)

  -- Seriality (NEW).
  seriality : ∀ w x, 0 ≤ x → (∃ u, TaskRel w x u) ∧ (∃ v, TaskRel v x w)

  -- Limit (renamed from the retired compound "Limit Nullity"; same content as the module's
  -- existing docstring-only transcription, now promoted to a required field).
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w

  -- Spherical (NEW). Needs `Fib`/`Seg` as prerequisite defs — see below. This is the field whose
  -- Lean cost is analyzed in Deliverable 3; the signature here is a proposal, not settled design.
  spherical : ∀ S : Set (Set WorldState),
    (∀ s ∈ S, ∃ w v a b, 0 ≤ a ∧ 0 ≤ b ∧ s = Seg w v a b) →   -- every member is a segment
    S.Nonempty →
    (∀ s ∈ S, s.Nonempty) →                                    -- every member nonempty
    (∀ s₁ ∈ S, ∀ s₂ ∈ S, ∃ s₃ ∈ S, s₃ ⊆ s₁ ∧ s₃ ⊆ s₂) →         -- ⊇-directed
    (⋂₀ S).Nonempty

-- `nullity_identity` is REMOVED as a field entirely (not weakened — the paper demotes Nullity to
-- a lemma with strictly weaker content, reflexivity only). It becomes a derived theorem:
theorem TaskFrame.nullity (F : TaskFrame D) (w : F.WorldState) : F.TaskRel w 0 w := by
  sorry  -- derive from `seriality` at x = 0 together with `limit`, per lem:nullity's proof; OR
         -- from `compositionality` + `limit` alone per the paper's over-determination remark
```

Prerequisite definitions needed before `Seg` can appear in the structure (or immediately after,
if defined against a bare relation the way `limit_nullity_of_succOrder` currently is):

```lean
/-- Fiber: world states reachable from `w` over duration `x`. -/
def Fib {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} (R : W → D → W → Prop) (w : W) (x : D) : Set W :=
  {u | R w x u}

/-- Segment: candidates constrained from the past by `w` over `a` and from the future by `v`
    over `b`, per `Seg(w, v; a, b) := Fib(w, a) ∩ Fib(v, -b)`. -/
def Seg {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} (R : W → D → W → Prop) (w v : W) (a b : D) : Set W :=
  Fib R w a ∩ Fib R v (-b)
```

### `WorldHistory` structure (unchanged base fields; new totality + extension order)

```lean
structure WorldHistory {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t), s ≤ t →
    F.TaskRel (states s hs) (t - s) (states t ht)
  -- structure itself is UNCHANGED; totality and extension are predicates/relations over it, not
  -- new fields (matches the paper's own presentation)

namespace WorldHistory

/-- A world history is total iff its domain is all of `D` — equivalently, a *possible world*. -/
def IsTotal (τ : WorldHistory F) : Prop := ∀ x, τ.domain x

/-- σ extends τ iff τ's domain is contained in σ's and they agree on τ's domain. -/
def Extends (σ τ : WorldHistory F) : Prop :=
  (∀ x, τ.domain x → σ.domain x) ∧
    ∀ x (hτ : τ.domain x) (hσ : σ.domain x), τ.states x hτ = σ.states x hσ

end WorldHistory

/-- H_F: the set of all total world histories over `F` — the paper's possible worlds. -/
def PossibleWorld (F : TaskFrame D) : Type := {τ : WorldHistory F // τ.IsTotal}
-- or: `def H_F (F : TaskFrame D) : Set (WorldHistory F) := {τ | τ.IsTotal}`, whichever downstream
-- (TruthAt/valid/SemanticConsequence) design prefers — see note below.
```

### `TruthAt` / `valid` / `SemanticConsequence` binder lists

The central structural consequence: the current generic `Omega : Set (WorldHistory F)` +
`ShiftClosed Omega` + `τ ∈ Omega` pattern is replaced by quantification over the fixed
total-history set, not by a further-constrained `Omega`. `ShiftClosed` becomes unnecessary as a
hypothesis to carry, because totality is trivially closed under `WorldHistory.timeShift`:
shifting `domain := fun z => σ.domain (z + Δ)` preserves "domain is always true" whenever
`σ.domain` was always true. This is a genuine simplification, not just a rename — the current
`(_ : ShiftClosed Omega)` hypothesis exists *because* `Omega` is otherwise unconstrained; once
`Omega` is pinned to "total histories," the hypothesis it was added to support is no longer
needed to state validity/consequence at all (it might still matter internally to metalogic
proofs that currently rely on being handed an arbitrary matching `Omega`, e.g. completeness —
this is exactly what Deliverable 4's per-task staleness verdicts assess for task 415).

```lean
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (τ_total : τ.IsTotal) (t : D) : Formula → Prop
  | Formula.atom p    => M.valuation (τ.states t (τ_total t)) p    -- NEW: no existential; domain
                                                                     -- membership is now a total
                                                                     -- fact `τ_total t`, not a proof
                                                                     -- obligation
  | Formula.bot        => False
  | Formula.imp φ ψ    => TruthAt M τ τ_total t φ → TruthAt M τ τ_total t ψ
  | Formula.box φ      => ∀ (σ : WorldHistory F) (hσ : σ.IsTotal), TruthAt M σ hσ t φ
  | Formula.untl φ ψ   => ∃ s : D, t < s ∧ TruthAt M τ τ_total s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ τ_total r ψ
  | Formula.snce φ ψ   => ∃ s : D, s < t ∧ TruthAt M τ τ_total s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ τ_total r ψ

def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (τ_total : τ.IsTotal) (t : D),
    TruthAt M τ τ_total t φ

def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (τ_total : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ τ_total t ψ) → TruthAt M τ τ_total t φ
```

Two binder-shape alternatives are viable and this report does not adjudicate between them (a
planning-stage decision, not a research one):

- **Subtype approach**: `τ : PossibleWorld F` (the `{τ // τ.IsTotal}` subtype) as a single
  binder, vs. **witness-pair approach** shown above (`τ : WorldHistory F` plus a separate
  `τ_total : τ.IsTotal` hypothesis). The subtype approach is more faithful to the paper's
  "$\tau \in H_{\F}$" phrasing as a single object; the witness-pair approach requires fewer
  changes to call sites that already destructure a bare `WorldHistory F`. Either is a routine
  transcription; a style choice for the implementer, not a semantic one.
- Whether `ShiftClosed`/`Omega` machinery is deleted outright or retained as a *generalization*
  that `valid`/`SemanticConsequence` specialize (keeping `TruthAt` parametric in `Omega` for
  internal metalogic flexibility, instantiating `Omega := {τ | τ.IsTotal}` and proving it
  shift-closed once as a lemma) is exactly the kind of design decision Deliverable 4's per-task
  verdicts (specifically for 415, which currently depends on being handed an arbitrary matching
  `Omega`) should settle, not this report.

**Confidence**: `TaskFrame`/`WorldHistory` field-level transcriptions — **medium-high** (direct,
low-risk translations of verbatim paper text). `TruthAt`/`valid`/`SemanticConsequence`
binder-list redesign — **medium** (consistent with the paper and with the totality restriction,
but not the only defensible shape; interaction with 415's canonical-model construction is
explicitly flagged as unassessed here, Deliverable 4 territory).

## Deliverable 3 — Coupling Analysis of (A) and (B) (from A, with C's precision correction)

**Question**: which frame axioms are load-bearing for the totality restriction — specifically, is
`thm:extension` (and hence `app:nonempty`, i.e. $H_{\F} \neq \emptyset$) derivable in Lean from
the four `def:frame` axioms as stated, and what does Spherical cost to state over a Lean
`TaskFrame`?

**Answer: all four axioms are load-bearing, none can be dropped, and the dependency chain is
linear and fully traceable in the paper's own proofs.** This is the corrected framing per
Conflict 1 below — do not read this as "only Spherical matters for totality."

1. `thm:extension`'s proof directly cites three of the four axioms by name in its case split:
   - The "$A$ has a maximum, $C$ has a minimum" case uses the **right-to-left direction of
     Compositionality** (the biconditional's new half) to factor the transition through the gap
     point $z$.
   - The "otherwise" case, when both $A, C$ are nonempty, invokes **`lem:segments`**, whose own
     proof uses *both* directions of the biconditional Compositionality (left-to-right for
     directedness, right-to-left for nonemptiness) — Compositionality's biconditional strength is
     genuinely used, not incidentally present.
   - The one-sided sub-cases (only $A$ or only $C$ nonempty) invoke **Seriality** directly
     ("every forward fiber is nonempty by *Seriality*") to establish nonemptiness of the
     one-sided fiber family before Spherical is applied.
   - **Spherical** itself is invoked in every branch of the "otherwise" case to extract the
     witness $u$ in the directed family's intersection — this is the one non-substitutable step;
     nothing else in `def:frame` produces an intersection witness.
   - The proof's closing step cites **`lem:nullity`** for the zero-loop instance at the new
     point $z$ — and `lem:nullity` is itself proved from Seriality + Limit (or, per the paper's
     over-determination remark, from Compositionality + Limit alone). So **Limit is load-bearing
     too, transitively, via `lem:nullity`**, even though `thm:extension`'s proof body never cites
     "Limit" by name directly.
   - The proof also uses Zorn's lemma (hence AC) to obtain the maximal task-constrained extension
     in the first place, independent of which frame axioms hold.

   Conclusion: **`thm:extension` depends on all four `def:frame` axioms** — Compositionality
   (biconditional form) and Spherical directly, Seriality directly (one-sided case) and
   indirectly (via `lem:segments`), and Limit indirectly via `lem:nullity` — plus the axiom of
   choice via Zorn.

2. `thm:occurrence` chains `lem:nullity` into `thm:extension`, inheriting its full four-axiom +
   AC dependency and adding nothing new.

3. `app:nonempty` (the $H_{\F} \neq \emptyset$ result underwriting `def:frame-validity`'s
   "never vacuous" guarantee) is a direct corollary of `thm:occurrence` via a time-shift
   translation argument, so it too inherits the same dependency chain in full.

**Precision correction (Teammate C)**: the `app:gluing` footnote's own claim — "the directed case
of gluing rests on Spherical rather than on composition alone" — is correctly scoped to
`app:gluing` specifically (binary vs. directed gluing), and remains accurate as scoped. It should
not be generalized to a claim that `thm:extension` itself needs only Spherical: `thm:extension`
needs **all four axioms**, with Spherical specifically necessary for the two-sided/directed
segment case. Both teammates independently derived this by tracing the paper's own proof text,
not by inference from each other.

**Therefore: yes, `thm:extension` is derivable from the four axioms as stated** — but
"derivable" here means "derivable in ZFC, using Zorn's lemma," and the Lean formalization cost
is real and multi-layered:

- **Not routine**: `Spherical`, because it must first be *stated* against `Seg`, which does not
  exist in the Lean tree at all today. Stating it requires (a) `Fib`/`Seg` as new definitions,
  (b) a `Set (Set WorldState)`-level quantification over families of segments (second-order
  relative to the base relation), and (c) a directedness predicate over that family. None of
  this is exotic Lean, but it is new *infrastructure*, not a one-line axiom the way
  `nullity_identity`/`forward_comp` currently are.
- **Not routine**: `thm:extension`'s own proof, independent of how `Spherical` is stated, because
  it requires (a) defining "task-constrained function on a subset of `D`" as its own predicate
  (distinct from `WorldHistory`), (b) a `Preorder`/partial order by extension over that
  predicate's carrier type, (c) a chain-boundedness argument establishing that a chain's union is
  itself task-constrained, (d) applying a Mathlib Zorn variant (`zorn_le`/
  `zorn_nonempty_partialOrder` or similar), and (e) the full four-branch case analysis
  reconstructing the maximality contradiction. This is a multi-lemma development, comparable in
  shape to (and reusing some of the mathematical engine behind) the ~85-line maximal-history
  prototype 414's research points to — except targeting `IsTotal` rather than `IsMax`; only the
  *engine* (Preorder, chain-union argument, Zorn application) is reusable, not the target
  predicate.
- **Routine**: `Seriality` and the promoted `limit` field are both direct, first-order
  transcriptions with no new supporting machinery — `limit`'s shape is already written out in the
  current `TaskFrame.lean` module docstring, needing only relabeling now that Nullity has been
  split off.
- **Routine, but requires deleting rather than weakening**: the biconditional `Compositionality`
  field itself is a routine transcription (`↔` in place of the current one-directional `→`
  chain), but its *consequences* ripple into every existing proof site that currently uses
  `forward_comp`/`backward_comp` as one-directional facts. This is a downstream-impact concern
  for Deliverable 4/Part B, not a transcription-cost concern.

**Summary judgment**: Seriality and Limit are cheap (first-order, no new infrastructure).
Compositionality's biconditional is a cheap field edit with a potentially non-cheap downstream
footprint. Spherical is the one axiom whose Lean transcription is genuinely non-routine,
requiring new segment/fiber infrastructure before it can even be stated, and `thm:extension`'s
reconstruction (needed to make totality non-vacuous) is a substantial, multi-lemma Zorn-based
development in its own right, independent of Spherical's statement cost.

**Confidence**: "which axioms are load-bearing" — **high** (a direct trace through the paper's
proof text, independently corroborated by two teammates). Quantitative Lean-cost estimates —
**medium** (routine/non-routine judgments compare required transcription shape against what
already exists and against general Zorn-development difficulty; no Lean proof was actually
drafted, per the hard non-goal against implementing anything).

## Deliverable 4 — Per-Task Staleness Verdicts (from B, with C's confirmations)

Cluster inventory re-confirmed by both Teammate B (direct `jq` re-query) and Teammate C
(independent check): exactly the six tasks named in the 438 description — 414, 415, 417, 419,
420, 427 — with no additions or removals since 438 was written.

```
420 align_task_frame_with_positive_cone_limit_nullity   blocked
419 machine_check_co_reynolds_independence               not_started
414 refactor_semantics_to_maximal_history_validity       researched
415 completeness_over_maximal_history_semantics          researched
417 semantic_fmp_finite_worldstate_over_z                researched
427 sync_typst_book_with_refactored_paper                not_started
```

### Task 414 — `refactor_semantics_to_maximal_history_validity`

**Survives** (from `specs/414_.../reports/01_maximal-history-validity-refactor.md` and
`02_group-c-reconciliation.md`):
- The extension `Preorder` on `WorldHistory` (`τ ≤ σ` iff domain-inclusion + state-agreement on
  the smaller domain) — predicate-agnostic scaffolding; totality trivially implies maximality
  under this order (a total history admits no proper extension).
- `timeShift_mono`, the shift/unshift lemma pair, and `chainSup` (the chain-union construction) —
  pure order-theoretic machinery, axiom-content-free.
- `exists_maximal_extension` (Zorn) — still true and useful, but demoted from "the target
  existence theorem" to "an internal lemma en route to" `thm:extension`. Totality is *stronger*
  than maximality in general; proving a Zorn-maximal extension is in fact total requires
  Seriality and Spherical (per `possible_worlds.tex:912-913`: "Spherical provides a common
  way-station in the limit, so that jointly tightening constraints from the past and future
  never close in on an empty gap"), which do not exist in the Lean `TaskFrame` structure yet
  (420 territory).
- `isMax_of_total` (`τ` total ⇒ `IsMax τ`) survives and becomes the *load-bearing* direction
  post-refactor: it is exactly the fact that lets a totality-based `H_F` sit inside the
  maximal-extension machinery.
- Finding 6/7's soundness-survival analysis (soundness needs only shift-preservation, not Zorn
  extension) is a claim about *which* lemma soundness consumes, not about *what predicate* that
  lemma is stated for. A totality-based `time_shift_preserves_truth` is strictly easier than the
  `IsMax`-based one already verified (no Zorn, no chain argument), so this finding survives a
  fortiori.
- **The Group C dead/live/portable bucketing and the 88/16/8 counts — CONFIRMED.** Teammate B
  verified these EXACTLY against `specs/414_.../reports/02_group-c-reconciliation.md` Finding 7
  (88 dead + 9 LIVE-P + 7 LIVE-P+lemma = 16 + 8 LIVE-UNPORT). This bucketing (a kernel-level
  reachability fact about which Omega-touching declarations are dead/live/portable) is orthogonal
  to the totality-vs-maximality predicate choice — dead code stays dead and live code stays live
  no matter which predicate replaces `Omega`/`IsMax`. Teammate C did not independently re-derive
  these counts from the underlying reachability analysis (out of critic-scope), so this stands as
  B's verification specifically, not a triangulated fact from two independent primary-source
  reads — but it is a confirmed check against the source report, not merely an inherited,
  unverified claim. **Scope of that confirmation (see Conflict 5 and Gap 1):** what is confirmed
  is that the counts are an internally-consistent, correctly-cited transcription of 414's report
  02. Nobody re-ran the reachability analysis against the *current* Lean tree this round, and that
  report predates task 415's landing, so the cardinalities may have drifted. The bucketing is
  orthogonal to the totality change and survives regardless; the numbers are the open item. Part
  B's re-issued 414 description must carry both halves and must not present the counts as freshly
  re-derived by this research round.
  The specific replacement *text* for each LIVE-P/LIVE-P+lemma declaration
  (`IsMax`-flavored) does not survive and must be re-derived against totality — plausibly a
  *simplification* in most cases (e.g. `multiFamOmega`/`multiFamHistory` are already described as
  "total-domain flow line", so the deterministic-flow lead frame construction is plausibly
  Omega-free totality-native already).

**Refuted**:
- The task description's own "make maximal-history validity THE validity of the repo" charter is
  refuted at the root — `IsMax` is not the paper's predicate.
- The existing research's target Lean signatures (`TruthAt`'s box clause `∀ σ, IsMax σ → ...`;
  `valid`/`SemanticConsequence`/`satisfiable`'s `IsMax τ` binders) are refuted verbatim and must
  be re-issued with a totality predicate (paper: `X = D`).
- The existing research's naming discussion (`IsMax` directly vs. a `WorldHistory.IsMaximal`
  alias) is moot — whichever predicate name is chosen, it must denote totality, not `IsMax`.
- 414's own current description's "charter is mathematically unaffected" framing is now doubly
  wrong: not only does the frame-axiom change not leave the charter untouched, the charter itself
  (maximal-history validity) is the thing that must change to totality-history validity.

**Re-issued description must say**: the target predicate for `TruthAt`'s box clause, `valid`,
`SemanticConsequence`, `satisfiable`, and `H_F` generally is **totality** (`∀ t, τ.domain t`),
not Mathlib `IsMax`; the `Preorder`/Zorn/`chainSup`/`isMax_timeShift`/`isMax_of_total` prototype
is preserved as reusable *engine* material for `thm:extension` but is not itself the destination
API; that proving a Zorn-maximal extension is total requires Seriality and Spherical, which do
not yet exist in `TaskFrame` (blocks on 420's still-open Spherical/Seriality transcription, a NEW
dependency not currently declared); that the Group C reachability bucketing survives as a fact
but every quoted replacement lemma name in it is maximality-flavored and must be re-targeted at
totality during implementation; and that `\label{def:frame}`, `\label{def:world-history}`
(`possible_worlds.tex:2570`), and the `H_F`/possible-worlds restatement at `:949-960` are the
live anchors (superseding any prior "def:world-history at line 1833" citation, which predates the
Seg/fiber/Spherical package and the totality-vs-maximality wording split).

**Proposed status**: `not_started`. The existing research's engineering substantially survives,
but its target signature — the single most consequential fact a re-dispatch needs — is wrong, and
re-running research against the correct target is cheap relative to the cost of an implementer
building the wrong API.

**Proposed rename**: yes. `refactor_semantics_to_maximal_history_validity` names the wrong
predicate. Proposed: `refactor_semantics_to_total_history_validity`. Rename surface is low: the
two existing report files' internal cross-references to "maximal" become historically-accurate-
but-superseded prose (acceptable, superseded reports are never deleted); no plan/summary exists
yet for 414 itself. Per Teammate C's rename-cost caveat (see Recommendations), run `grep -rl` for
the old slug across `specs/**/*.md` before committing to the rename.

### Task 415 — `completeness_over_maximal_history_semantics`

**Survives**:
- The overall staging plan (Discrete → Dense → Base → Dedekind) and the decision to internalize
  realization into the constructions rather than bridge — a proof-architecture decision
  independent of the target predicate.
- The identification of the deterministic lead frame (`bundleFlowFrame`, `WorldState := FamIdx ×
  D`) as the right countermodel engine — plausibly already closer to a totality-native
  countermodel than a maximality-native one, per 414's report-02 Finding 4c ("total-domain flow
  line" reasoning already underlies `multiFamHistory`/`isMax_of_total`).
- The NEW obligation already anticipated in 415's current description ("must additionally
  discharge Seriality and Spherical, not just Limit") is correctly anticipated content, even
  though it currently cites the superseded three-axiom framing elsewhere in the same
  description — kept and strengthened, not discarded.

**Refuted**:
- "Completeness over Omega-free, maximal-history semantics" — wrong target predicate, inherited
  transitively from 414 per the description's own admission.
- "the FULL maximal-history set is the required countermodel family" — must become "the full
  total-history set (`H_F`) is the required countermodel family."
- The description's Limit-Nullity-obligation paragraph still calls the axiom "Limit Nullity"
  (superseded name; current name "Limit", same math) and under-scopes the new obligations to
  Limit alone — it must now also name Seriality and Spherical as first-class per-class proof
  obligations.

**Re-issued description must say**: target totality, not maximality, for the countermodel
family; the deterministic lead-frame strategy is retained and plausibly favorable for totality
(not merely tolerant of it); each canonical/chronicle construction must discharge Seriality,
Limit, and Spherical (beyond Compositionality), with Spherical flagged as the least routine (per
`possible_worlds.tex:912-913`'s own warning that the directed form is calibrated and a weaker
chain form "no longer supports the extension theorem" over orders with mismatched cofinalities);
and that biconditional Compositionality (interpolation direction) is a new proof obligation for
any construction that previously relied only on the lax inclusion direction.

**Proposed status**: `not_started`. Same target-predicate rule as 414; 415 is explicitly
"written explicitly against 414's maximal-history semantics" per its own current description and
cannot safely resume from `researched`.

**Proposed rename**: yes. `completeness_over_maximal_history_semantics` →
`completeness_over_total_history_semantics`. Rename surface: one report file, referenced by
414's report 02 by relative path (would need updating, or the report left with a note that its
path is historical). No plan/summary exists yet.

### Task 417 — `semantic_fmp_finite_worldstate_over_z`

**Survives**: the "Limit Nullity note" in 417's description is correct as pure mathematics and
needs only a renaming pass, not a re-derivation — "over D = Z the new Limit Nullity frame axiom
is automatic (|y| < 1 forces y = 0, then nullity_identity)" is exactly what
`TaskFrame.limit_nullity_of_succOrder` proves, and the axiom (renamed "Limit") is unchanged in
content.

**Refuted**: 417 states it is "against the refactored Omega-free maximal-history semantics of
task 414," inheriting 414's now-refuted target predicate transitively, exactly like 415. Every
place 417's eventual Lean target would have named `IsMax` must instead name totality.

**Re-issued description must say**: target totality (not maximality) per 414's corrected
charter; that the "Limit Nullity... automatic over Z" claim survives verbatim under the renamed
"Limit" axiom; and — a genuine new gap, not a survives/refutes call — whether Seriality and
Spherical are ALSO automatic over `D = ℤ` needs to be checked during 417's next research pass
(Seriality is plausible-automatic for a no-genuine-dead-ends frame, likely true of the
finite-WorldState-over-ℤ construction by design; Spherical is exactly the axiom whose failure
mode the paper illustrates on a ℚ-flow at `:926` — a finite-WorldState-over-ℤ frame is a much
smaller structure than that counterexample and Spherical's directed-intersection condition over a
discrete order is far more likely to degenerate to a finite/eventually-constant intersection, but
this is a claim to verify, not assume). Teammate D independently offers a stronger version of
this same lead (see Recurrence Prevention section's roadmap-leverage note): over a finite
`WorldState`, a strictly-descending chain of nonempty subsets of a finite set must stabilize
(pigeonhole), so Spherical is a plausible finite-set corollary of Seriality rather than a fresh
proof burden — flagged as a research lead, not a proven result.

**Proposed status**: `not_started`, same target-predicate rule as 414/415.

**Proposed rename**: not required. `semantic_fmp_finite_worldstate_over_z` does not name the
maximal/total predicate at all and remains accurate.

### Task 419 — `machine_check_co_reynolds_independence`

**Survives**: the CONVERSE direction (`co_derived` in `FormalSystem/Theorems/
DedekindDerived.lean`, `co_valid` in `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`) is
unaffected — a proof-system derivability fact that does not depend on `def:frame`'s axiom count
at all; 419's description already correctly marks it "done and sorry-free... do not redo." The
overall goal (build a Lean countermodel showing CO does not derive `prior_U_gap`) is unaffected
in kind — the paper itself never mentions "Prior-U," "Reynolds," or "Stavi" anywhere (confirmed:
zero grep hits), so this independence result is, and remains, an entirely repo/Lean-side concern
layered on top of the paper's CO axiom.

#### Spherical Risk to the Countermodel Sketch — Headline Finding (Refuted / At Risk)

This is the most consequential finding in this deliverable, and materially more damaging to 419
than "re-check for conformance" implies — the re-issued 419 description must say so explicitly,
not soften it to a routine conformance check. 419's proposed countermodel sketch (a
rational-flow construction with isolated `¬φ` points accumulating at an irrational from above) is
shadowed by the paper's OWN worked non-example for Spherical (`possible_worlds.tex:926`, footnote
to `def:world-history`, verbatim):

> "Convexity alone does not guarantee extendability: taking $D = \mathbb{Q}$ and
> $W = \{q \in \mathbb{Q} : q > 0\}$ with $r \Rightarrow_x r'$ *iff* $|r' - r| \leq x$ yields a
> structure satisfying every axiom but *Spherical*, in which the task-constrained function
> $\tau(t) = 1 - t$ defined for $0 < t < 1$ admits no value $u$ at the time $1$... *Spherical* is
> exactly what excludes this structure."

This is structurally the same family of construction 419's sketch proposes: a ℚ-carrier flow
engineered around a point not reachable within ℚ. Since Spherical is now a hard requirement of
`def:frame` and of `H_F`'s nonemptiness/`thm:extension` machinery that any legitimate
countermodel frame must respect, **419's sketch is at serious risk of not being a legitimate
`TaskFrame` at all under the new four-axiom `def:frame`** — potentially requiring an entirely
different carrier/frame choice if it cannot be repaired to satisfy Spherical. This is a genuine
open mathematical question, the single highest-priority item for 419's re-issued research phase.
Compositionality's interpolation direction and Seriality are comparatively low-risk for a
deterministic/near-deterministic flow construction; Spherical specifically targets "gaps," which
is the entire mechanism 419's sketch is trying to exploit.

**Citation correction**: 419's description cites "CO source formula: `possible_worlds.tex:3250`"
— stale/wrong (line 3250 falls inside unrelated CO+/CO- discussion prose; this exact error
already exists in `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md:158`, so 419
inherited a stale citation rather than introducing a new one). Confirmed independently by
Teammate C via the `\aitem`/`\aref` macro definitions (`possible_worlds.tex:366-374`, which write
the label directly from the axiom's short name). The correct anchors:
- `\label{CO}` at `possible_worlds.tex:1217` — the base **TM** axiom, verbatim:
  `\aitem{CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.`
- `\label{TMP-CO}` at `possible_worlds.tex:3709` — the **TM$^+$** restatement inside
  `def:TMplus-c` (`\label{def:TMplus-c}` at `:3706`), which the Lean tree's `Formula.co`
  actually mirrors (per `FormalSystem/ProofSystem/Axioms.lean:367-369`), verbatim:
  `\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.`
  with the paper's own footnote: "This axiom coincides with **`\ref{CO}`** in **TM**, though it
  is expressed in $\BL^+$" (`:3711`). `\label{TMP-CO}` is the more precise anchor for 419's
  purposes since it sits inside `def:TMplus-c`, the exact definition `fix.md` C4 amends, and is
  the anchor the re-issued 419 description should cite for the Lean-facing claim (`\label{CO}`
  remains useful as the base-TM cross-reference, per the footnote above, but `Formula.co` mirrors
  the `TMP-CO` restatement specifically).

The stale `:3250` citation did not originate with 419 — it propagated from
`/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md:158`'s own stale citation into
419's task description. This is a concrete instance of the bare-line-number failure mode
crossing between artifacts (paper comments → task description) rather than staying confined to
one place, which is exactly the failure mode the Recurrence Prevention section's
`\label`-anchored, definitions-of-record-file recommendation is designed to close off.

**Re-issued description must say**: replace `possible_worlds.tex:3250` with `\label{TMP-CO}`
(and/or `\label{CO}` for the base-TM form) as above; flag the Spherical risk to the Q-flow
sketch as the primary open question for 419's next research pass, quoting `possible_worlds.tex
:926`'s worked non-example directly so the next agent does not have to rediscover it; and note
that the converse-direction proof (`co_derived`/`co_valid`) and the overall goal statement are
unaffected and should not be redone.

**Proposed status**: `not_started` stands (already `not_started`; no research artifacts exist to
preserve or invalidate). No status change needed, only a description rewrite.

**Proposed rename**: not required. `machine_check_co_reynolds_independence` remains accurate.

### Task 420 — `align_task_frame_with_positive_cone_limit_nullity`

**Survives** (verified against `specs/420_.../summaries/01_taskframe-limit-nullity-alignment-
summary.md` and `FormalSystem/Semantics/TaskFrame.lean`):
- Phases 1-5, landed and green across 5 commits (`334371dfb`, `4fc1307a3`, `cd6856c00`,
  `5b22bb957`, `322bcd6af`), are NOT invalidated by the axiom-set expansion in the sense of
  needing to be reverted — they remain true, sorry-free, zero-new-axiom results. The re-anchored
  `def:frame` citations (phase 1) point at `possible_worlds.tex:2423-2451` / `908-926`, still the
  live `def:frame` region (now larger, four-axiom); the three helper theorems (phase 3-4) survive
  (see below); the LaTeX restatement (phase 5) is textually present and compiling, though now
  itself STALE CONTENT again (see Refuted) — the phase's mechanical work (`\label{def:frame}`,
  the `\poscone`/`\taskcone` macros, the primitives table) survives as reusable scaffolding even
  though the definition text must be rewritten again.
- The phase-2 docstring recast from "divergence" to "agreement" framing is directionally still
  correct and should not be re-inverted.
- The blocker mechanism (phase 6 needs 415's `bundleFlowFrame` to discharge Limit for
  `ParametricCanonicalTaskFrame`) is unaffected in its *reasoning* by the new axioms — the same
  duration-blind dense frame will need the same deterministic-shift repair, now for Limit,
  Seriality, and Spherical together rather than for Limit alone.
- **420's three helper theorems** (`limit_nullity_of_succOrder`, `limit_nullity_of_shift`,
  `exists_uniform_radius_of_finite`) — Teammate B's "plausibly survive verbatim" is **upgraded to
  VERIFIED** by Teammate C's independent direct read of `FormalSystem/Semantics/TaskFrame.lean`
  (lines 261-269, 289-316, 340-368): each is stated against a bare `R : W → D → W → Prop`
  parameter with hypotheses (`hnull`, `hzero`, `hlim`) passed in explicitly, never against a
  `TaskFrame` structure field. They survive verbatim as theorems. The one thing that changes is
  how `hnull` gets discharged: Nullity is no longer a frame axiom to cite directly but a derived
  lemma `lem:nullity` (from Seriality + Limit), so `limit_nullity_of_succOrder`'s hypothesis must
  now be proved via that derived lemma rather than read off a structure field.

**Refuted**: the entire description is written against the superseded three-axiom frame
(iff-Nullity as a real axiom + lax positive-cone Compositionality + "Limit Nullity", with
Reflection derived and Occurrence unaddressed) and explicitly states "equality would additionally
assert interpolation, **NOT adopted**" — now backwards; interpolation IS adopted. Concretely:
- "nullity_identity matches iff-Nullity" as a *primitive axiom* match — Nullity is now DERIVED
  (`lem:nullity`), so `nullity_identity` as an axiom-field is itself now a divergence from the
  paper (keeping it as an axiom in Lean is a legitimate simplifying choice to flag, not something
  that must change — Deliverable 2's target-signature proposal should rule on whether Lean should
  also demote it).
- "forward_comp... is exactly the official lax positive-cone law" — refuted; the paper's law is
  now biconditional, so `forward_comp`'s current one-directional statement under-specifies the
  axiom, missing the interpolation direction entirely.
- The title itself, "align...with...limit_nullity," names only one of what is now four axioms,
  and "Limit Nullity" is itself a superseded name.
- Absent entirely from the current description and from `TaskFrame.lean`: Seriality, Spherical,
  the segment/fiber machinery, and the biconditional's interpolation direction — all now required
  `def:frame` content, not optional extensions.

**Re-issued description must say**: the CURRENT four-axiom `def:frame` (Compositionality as
biconditional, Seriality, Limit, Spherical) with `possible_worlds.tex:2412` (`\label{def:frame}`)
as the formal anchor and `:905-914` as the body-prose anchor; that phases 1-5's landed work
(citations, docstrings, the three Limit-only helper theorems, the LaTeX restatement) is preserved
but the LaTeX restatement itself is now stale a second time and needs a further rewrite pass to
add interpolation, Seriality, Spherical, and the segment/fiber apparatus; that `nullity_identity`
as a structure field vs. a derived lemma is an open design question for the target-signature
deliverable rather than settled; and that phase 6 (the `limit_nullity` field) must be redesigned
as a larger phase adding Seriality, Spherical, and interpolation fields/proof obligations
together, still gated on 415 per the dependency analysis in Deliverable 5, but on a corrected
dependency edge.

**Cross-task acceptance criterion (Teammate D, folded in here)**: 420 owns landing Spherical as a
Lean field, but `thm:extension` needs Spherical as a *hypothesis its proof consumes*, not merely
a same-named field typed into the structure. If 420's phase 6 lands Spherical as an inert
structure field while 414 separately rebuilds totality machinery without threading Spherical
through, the two tasks can each go green while jointly failing to reconstruct `thm:extension`.
**Recommendation**: add an explicit cross-task acceptance criterion to both 414 and 420's
re-issued descriptions — 420 phase 6 is not done until 414 (or a shared research artifact)
confirms Spherical's statement is literally the hypothesis `thm:extension`'s proof consumes. This
is a stronger dependency-content constraint than the Kahn-graph edge alone can express and
belongs in the task text, not just the edge list. It is a discovery that feeds Deliverable 5/9's
dependency-edge work, not a call to alter the six-task count (see Cluster Shape note below).

**Proposed status**: `blocked` stands (do not reset) — task 438's own explicit exception. 420's
phases 1-5 are landed, green, and committed, so no status transition may present that work as
undone. Recommend keeping `blocked` with a revised `blockers` field that (a) preserves the
existing 415-blocking explanation for whatever remains of the original Limit-field obligation,
and (b) adds that the description itself is now stale a second time and the next research pass
must first re-scope phase 6 (and probably add new phases) against the four-axiom target before
resuming implementation. `partial` was considered and rejected: `partial` connotes an
interrupted/incomplete implementation attempt, whereas 420's phases 1-5 are each fully complete
and green in their own right — `blocked` more accurately signals "cannot proceed until an
external dependency and a description rewrite are both resolved." (See "Recommendations for
Part B" below for Teammate C's independent input to this same status choice, which agrees with
`blocked`.)

**Proposed rename**: yes. `align_task_frame_with_positive_cone_limit_nullity` names one axiom
out of four, and that axiom's own name is superseded. Proposed:
`align_task_frame_with_positive_cone_axioms` (keeps "positive-cone", drops the now-inaccurate
single-axiom qualifier). Rename surface: 420 has the most artifacts of any cluster task (plan,
report, summary, `.return-meta.json`, `.orchestrator-handoff.json`) plus three other tasks'
descriptions reference it by number (414, 415, 417 all say "task 420" internally; 427's
description says "420 fixes the frame definition itself"). These are all under `specs/`, the
carved-out exception to the no-task-references-in-deliverables rule, so referencing 420 by number
inside other tasks' `state.json` descriptions is fine and does not need to change — but a
directory rename would require updating the `artifacts[].path` entries inside 420's own
`state.json` record (3 paths) and confirming no other task's artifact path field points into
`specs/420_.../`. Record this cost for Part B's implementer rather than resolving it here.

### Task 427 — `sync_typst_book_with_refactored_paper`

**Survives**: the overall charter (typst book is stale, must be resynced last, after the whole
chain lands) and the audit scope (not just `02-semantics.typ` — also `04-metalogic.typ`,
`p2-frame-classes.typ`, `p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`) are unaffected — process/scope
statements, not definitional content. The stale-line-anchor discipline it already calls for
(re-derive `TaskFrame.lean` line numbers and paper line numbers rather than trusting either)
remains exactly right and is, if anything, more urgent now.

**Refuted**: the description's explicit instruction "The corrected LaTeX wording is in
`latex/subfiles/02-Semantics.tex` and should be the model for the typst restatement" is WRONG as
of this re-issue: `latex/subfiles/02-Semantics.tex` was rewritten by 420 phase 5 against the
THREE-axiom frame, itself now superseded by the four-axiom frame. Using it as the typst model
today would write the same superseded definition into the typst book that 420 phase 5 just wrote
into the LaTeX subfile — the exact failure mode task 438's own description already calls out. The
"KNOWN STALE SITE" enumeration in 427's description (one-way Nullity, substantive Reflection,
unrestricted mixed-sign Compositionality, missing "Limit Nullity") is itself now incomplete — it
is missing Seriality, Spherical, the biconditional/interpolation direction of Compositionality,
and the segment/fiber apparatus as ALSO-stale content relative to typst's current (pre-420-
phase-5-even) state. **This matters more than a symmetric statement suggests: Teammate A's
independent audit found `latex/` and `typst/` are stale by DIFFERENT amounts** — `latex/subfiles/
02-Semantics.tex` is one generation behind (matches Lean's lax Compositionality, omits
Seriality/Spherical), while `typst/chapters/02-semantics.typ` is two generations further behind
(still independently axiomatizes Reflection, has no Limit clause at all, predates even the
positive-cone/converse-convention presentation the paper currently uses in full). 427's spec
currently instructs the implementer to copy from the LaTeX subfile precisely because that
generational gap was not accounted for; the corrected instruction below closes it.

**Re-issued description must say**: do NOT use `latex/subfiles/02-Semantics.tex` as the model
until/unless it is itself re-corrected to the four-axiom frame (not this task's job — that is
420's remaining work); instead model the typst restatement directly on `possible_worlds.tex`
`\label{def:frame}` (`:2412`, four axioms) the same way 420 phase 5 originally modeled the LaTeX
subfile on the paper, with an explicit note that the LaTeX subfile is a fellow downstream
consumer, not a second source of truth, and may itself still be mid-sync when 427 runs; and that
the stale-site enumeration must be re-audited against the current four-axiom paper rather than
trusted from the current description.

**Proposed status**: `not_started` stands. No research has been done; nothing to reset.

**Proposed rename**: not required.

## Deliverable 5 — Dependency Cycle Resolution (from B)

### Current edges (re-verified 2026-08-09)

```
414.dependencies = [420, 438]
415.dependencies = [414, 420, 438]
417.dependencies = [414, 420, 438]
419.dependencies = [438]
420.dependencies = [415, 438]
427.dependencies = [414, 415, 417, 419, 420, 438]
```

(438 appears in every cluster task's dependency list because each was revised to depend on 438
while 438 is in flight; expected, not part of the cycle.)

### Cycle proof

Two overlapping cycles exist, both through the `420 ↔ 415` edge pair:

1. **Direct 2-cycle**: `420 → 415` (420 depends on 415) AND `415 → 420` (415 depends on 420).
   This alone is already a cycle — 420 cannot start until 415 finishes, and 415 cannot start
   until 420 finishes.
2. **3-cycle** (the one named in the task description): `420 → 415 → 414 → 420` (415 also
   depends on 414, and 414 depends on 420).

Both cycles share the `420 → 415` edge. Removing that single edge breaks both simultaneously.

### Root cause (confirmed against artifacts, not assumed)

- 420's `blocked`-status `blockers` field and its `.orchestrator-handoff.json` state that only
  420's **phase 6** — not the whole task — genuinely waits on 415: "Phase 6 is blocked on task
  415... Resolution: task 415's `bundleFlowFrame`... discharges the obligation via
  `TaskFrame.limit_nullity_of_shift`, already landed and verified by phases 1-5. Phase 6 is then
  a mechanical drop-in." Phases 1-5 (the bulk of 420's actual work) landed without ever needing
  415.
- Meanwhile 415's dependency on 420 is real and task-level: 415's countermodel constructions need
  the frame axioms 420 owns (biconditional Compositionality, Seriality, Limit, Spherical) to
  exist in `TaskFrame` before 415 can even state what its canonical frames must discharge. 414
  similarly needs 420's frame-axiom work before its own semantics refactor can target the final
  `TaskFrame` signature.
- So the TRUE shape is a chain `420 → 414 → 415 → 417 → 427` (each downstream of the frame-axiom
  work), with one exception: a narrow, phase-level backward wait where 420's own phase 6 needs a
  construction (`bundleFlowFrame`) that only exists once 415 has done its own work. Task-level
  dependency edges cannot express "all of 420 except phase 6 comes before 415, but 420's phase 6
  comes after 415" — encoding the phase-level fact as a task-level edge in either direction
  either creates the cycle (current state) or hides the real intra-task wait entirely (dropping
  the edge with no compensating record).

### Confirmed `generate-task-order.sh` symptom

```
$ bash .claude/scripts/generate-task-order.sh --print
...
| 1 | 125,127,128,193,231,257,298,413,415,421,423,424,437,438 | -- | ... |
```

415 is present in wave 1 with `Blocked by: --`, despite `415.dependencies = [414, 420, 438]`
(three declared, unmet dependencies). Kahn's algorithm cannot place cycle members in a normal
wave and the script's fallback surfaces 415 as if unblocked. The topic-grouped "Paper Refactor"
tree independently corroborates the cycle shape by DISPLAY (nesting `420` as a child of `415`,
then `414` as a child of `420`, `417` as a child of `414`, `427` as a child of `417`) — the
grouped-view code walks forward edges without cycle detection either; the numeric wave table and
the topic tree are two symptoms of the same underlying unresolved cycle.

### Proposed corrected edge set (acyclic, keeps 427 last)

**Remove exactly one edge: drop `415` from `420.dependencies`.** All other edges are correct as
declared and should be kept as-is:

```
414.dependencies = [420, 438]                    (unchanged)
415.dependencies = [414, 420, 438]                (unchanged)
417.dependencies = [414, 420, 438]                (unchanged)
419.dependencies = [438]                          (unchanged)
420.dependencies = [438]                          (415 REMOVED)
427.dependencies = [414, 415, 417, 419, 420, 438] (unchanged)
```

**Acyclicity check**: with `420 → 415` removed, the remaining graph is a strict DAG: `420` has no
cluster-internal prerequisite (only 438); `414` depends only on `420`; `415` depends on `414` and
`420`; `417` depends on `414` and `420`; `419` depends only on 438; `427` depends on all five
others. Topological order: `420, 414, {415, 417 in either order, or parallel}, 419 (independent,
parallel-eligible), 427` — 427 lands last as required, no task appears in its own dependency
closure.

**Compensating record for the dropped edge** (so the real phase-level wait is not silently
lost): 420's re-issued description and `blockers` field must state explicitly that although the
task-level graph no longer shows 420 blocked by 415, 420's own phase 6 (the discharge of
Limit/Seriality/Spherical via `bundleFlowFrame`) is still phase-blocked on 415 landing, and that
420 should remain in `blocked` status until either 415 lands or a phase-6-only alternative
construction is found. This preserves the true constraint as descriptive/status information
rather than as a graph edge — exactly what Deliverable 8/Part B's status treatment of 420 already
asks for independently.

**Alternative considered and rejected**: dropping `420` from `415.dependencies` instead (keeping
`420 → 415`). Rejected because 415's dependency on 420 is the task-level-correct one — 415's
countermodel constructions substantively need 420's completed frame-axiom set (all four axioms,
not just the phase-6 field) before 415's own definitions can be stated, whereas 420's need for
415 is narrow, phase-scoped, and already independently documented as such. Removing the
wrong-direction edge would let 415 start with an incomplete `TaskFrame`, a real correctness
problem, not just a graph-hygiene one.

**Post-Part-B verification step**: re-run `bash .claude/scripts/generate-task-order.sh --print`
after editing `specs/state.json` and confirm (a) 415 no longer appears in wave 1 with
`Blocked by: --`, (b) 415 appears in a wave whose blockers list includes 414 and 420, (c) 420
appears in an earlier wave than 414/415/417, and (d) 427 is in the final wave of the Paper
Refactor group.

## Blast Radius Beyond the Cluster (from C and D)

**The six-task `paper-refactor` cluster is the full blast radius OF PART B'S REWRITE SCOPE, but
it is NOT the full blast radius of the definitional change itself.** This report states this
plainly rather than silently confirming completeness, per Conflict 2 below.

**Scope note — B and C answered different questions, and both answers stand.** Teammate B
re-queried `topic == "paper-refactor"` in `specs/state.json` and confirmed exactly the six named
tasks, no additions — this answers "which tasks belong to the cluster Part B rewrites?" and that
answer is correct and unchanged. Teammate C separately asked "which tasks, in or out of that
topic, consume the semantics 414 is about to change?" and found task 424 as a real, uncounted
consumer outside the topic filter. These are not in tension: B's cluster-membership finding and
C's cross-topic consumer finding are orthogonal facts, both true simultaneously, and both are
carried forward below.

1. **Task 424** (`prove_shift_set_representation_theorem_compactness_feasibility_gate`, topic
   `strong_completeness`, status `not_started`) is a real, unflagged second-order consumer
   outside `topic == "paper-refactor"`. Its description cites its governing design doc,
   `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/
   02_compactness-route.md`, which hard-codes the *current*, pre-refactor Omega-parameterized
   semantics as the mathematical foundation of its "shift sets ⟨Ω, D, sh, A⟩" representation
   theorem — explicitly gated as **"THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH"** of strong
   completeness. Verbatim from the design doc (lines 98-103):
   ```
   def TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F))
       (τ : WorldHistory F) (t : D) : Formula → Prop
     | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → TruthAt M Omega σ t φ
   ```
   with its representation-theorem construction explicitly setting `Omega := Set.range (fun σ =>
   h_σ)` / `Ω := Omega` (design doc lines 152-177), citing `Truth.lean:128-137`, `ShiftClosed`
   (`:333`), `WorldHistory.lean:75-104`, `TaskFrame.lean:99-128` (lines 245-248) as its
   read-and-verified basis. Once 414 rewrites `TruthAt`/`valid`/`SemanticConsequence` to
   quantify over total histories `H_F` instead of an arbitrary `Omega : Set (WorldHistory F)`,
   424's entire representation theorem rests on a semantics that will no longer exist in that
   form.
   - **Not a scope-creep claim**: 424 should NOT be added to the six-task cluster now, and 438's
     NON-GOALS forbid touching `FormalSystem/` — this is a name-and-flag finding, not a
     call to rewrite 424 as part of Part B.
2. **`ROADMAP.md`'s own "Paper Alignment Programme" section (lines 1599-1641) is itself a fourth
   stale artifact that Part B's deliverable 6 does not touch.** It states "same-sign frame axioms
   with identity Nullity ... official validity = maximal-history validity" — the *previous*
   superseded generation. Part B's deliverable 6 only rewrites the six cluster tasks'
   `description` fields; it does not mention `ROADMAP.md`. Left as-is, the roadmap will keep
   telling the next reader the wrong axiom count and the wrong validity predicate even after
   Part B completes. This is out of task 438's stated non-goals (touches neither `specs/
   state.json` nor the six task descriptions) but should be recorded as a named follow-up rather
   than silently absorbed or silently dropped.
3. **Tasks 421-423 and 425** (also topic `strong_completeness`, referencing the same design-doc
   lineage as 424 by number) were checked by grep for direct textual dependence on
   `Omega|IsMaximal|maximal.history|WorldHistory|TaskFrame|H_F|possible.world|def:frame|def:world-
   history` in their `state.json` descriptions — none hit. But their own descriptions don't cite
   the semantics directly, and their design docs were not opened. **This is UNCHECKED, not
   CLEARED** — flagged explicitly as an open item for a follow-up spawn if in scope, not a
   negative finding to rely on.
4. **Adjacent roadmap tasks confirmed orthogonal** (Teammate D): task 362 (completeness capstone)
   — the weak/strong completeness distinction (`\label{cor:tm-completeness}`,
   `possible_worlds.tex:3750-3754`) is unchanged by this reconciliation and predates it; 438's
   re-issue does not newly block or unblock 362, it only changes the semantic substrate 415's
   constructions build on. Task 413 (conservativity bridge) concerns TM's proof system/language
   embedding, orthogonal to TaskFrame/WorldHistory semantics, and stays unblocked. Tasks 410-412
   (tableau decidability) sit downstream of `def:frame-properties` (Discrete/Dense/Complete/
   Deterministic), which is unchanged by the axiom-count and totality revisions — no action
   needed, but the re-issued cluster descriptions should say so explicitly rather than leaving
   the "does this ripple further" question to be silently re-asked later.

## Recurrence Prevention (from D)

**The paper is under continuous, task-numbered, diff-tracked revision at high velocity, not
occasional revision.** `git log --since="14 days ago" -- possible_worlds.tex` in the paper's own
repository returns 59 commits; the file has 288 commits total spanning 2025-03-05 to 2026-08-09.
The single most recent commit, `38840a40 task 64 phase 4: appendix mirror and gluing-footnote
symbol fix`, landed the same day this task was created. This is at least the third or fourth
`%% CHANGE` wave visible in the paper's own diff history (`sphericity-promote`,
`sphericity-hoist`, `sphericity-formal`, `two-tier`, `task 56 package3`, `nullity-limit`,
`convex-domains`, `interpolation`, `task 51 A1-refactor`, `task 52 total-histories`, `task 53
presheaf-alignment`). The definitional churn this task reconciles is the file's steady state, not
an anomaly to mop up once.

**The paper already carries its own machine-parseable revision ledger, unused by this repo.**
Every substantive edit is wrapped in matched `%% CHANGE (<tag>): <rationale>` / `%% OLD:
<superseded text>` comment pairs — 139 such markers currently in the file, e.g. at
`possible_worlds.tex:2435-2437`:
```
%% CHANGE (task 56 package3): Compositionality restated as a biconditional, absorbing
Interpolation as its right-to-left direction; ...
%% OLD: \item[\it Compositionality:] If $w \Rightarrow_x u$ and $u \Rightarrow_y v$, then
$w \Rightarrow_{x + y} v$.
\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$
and $u \Rightarrow_y v$ for some $u \in W$.
```
Nothing in this repo's tooling reads this ledger. This repo's own Lean source already has an
informal, unchecked citation convention pointing at the paper (`TaskFrame.lean:47-48`'s
docstring), independently corroborating that a citation mechanism is the right shape of fix, not
a novel invention — but bare, untagged, unchecked prose is exactly the failure mode that has now
let two consecutive rounds of drift through undetected until an agent happened to re-read the
paper by hand.

**Recommended mechanism (Option A + C together, evaluated against three rejected alternatives):**

| Option | Mechanism | Verdict |
|---|---|---|
| A. Generated definitions-of-record file | A script extracts the fixed set of `\label`-anchored environments this cluster depends on (def:frame, lem:nullity, def:world-history, app:gluing, lem:segments, thm:extension, thm:occurrence, def:frame-properties, def:frame-validity, def:BL-semantics, cor:tm-completeness, thm:ConservativeExtension) into `specs/paper-definitions-of-record.md`, cited instead of re-quoting the paper freehand six separate times | **Recommended, combined with C** |
| B. `\label`-anchored citation convention alone (no automation) | Just enforce "cite by `\label` + verbatim quote, never bare line number" as a written norm | Necessary floor, insufficient alone — a norm with no checker is exactly what let 420/427/419's line-number anchors go stale twice already; `\label`s survive line-shift but not *content*-shift |
| C. Checked-in hash/SHA of the paper's definition environments + a lint script | Store, per cluster task, the paper's git SHA at the time its description was last verified — a `paper_anchor_commit` field alongside each task in `state.json`. A new `.claude/scripts/check-paper-definitions.sh`, structurally parallel to `check-task-references.sh`, diffs the stored SHA/hash against the paper repo's current `HEAD` and exits non-zero / prints a loud banner (same family as `[SPARSE COVERAGE ...]`/`[UNVERIFIED ...]`) when they diverge | **Recommended, combined with A** |
| D. Invert authority (Lean as source of truth, paper checked against Lean) | — | **Rejected as stated** — contradicts the explicit user decision recorded in this task's description that the paper is authoritative; revisit only if that ruling changes |
| E. Reverse sync (paper's build pulls from this repo) | — | **Rejected** — requires write access into `/home/benjamin/Philosophy/Papers/...`, out of this task's non-goals, and conflates "prevent this repo's drift" with "control the paper" |

Concretely for Part B: the six rewritten descriptions should cite `specs/paper-definitions-of-
record.md` line-items rather than re-quoting the paper inline six separate times, since inline
re-quoting is exactly the mechanism that produced today's re-issue (three independent paraphrases
of `def:frame`'s Compositionality clause, each frozen at a different paper commit). Building the
extractor script/lint itself is out of task 438's Part A/B scope (creates new `.claude/` tooling,
a `meta`-type change) — record it as a recommended follow-up `meta` task rather than implementing
it here.

**Sequencing advice**: given the paper's revision cadence, there is no visible stabilization
signal to wait for — the commit messages show the paper's own author running a phased,
task-by-task revision process structurally identical to this repo's own. What is safe to land now
(invariant under the plausible revision surface): the converse convention (no CHANGE marker
touching its substance anywhere in the file's history, already correctly landed in Lean) and
`[Nontrivial D]` (the *oldest* surviving CHANGE marker in the current `def:frame` block, `%%
CHANGE (fix.md A2)` at `:2416-2418`, predating the Seriality/Spherical/totality package by many
commits). What should wait or be scoped defensively: anything quoting Spherical or the
totality-quantification clause verbatim outside the recommended definitions-of-record file — both
carry the freshest CHANGE markers (`sphericity-promote`, `sphericity-hoist`, `sphericity-formal`,
`sphericity-wording`) and are the least battle-tested parts of the current generation.

**This is the second time in this cluster's history that a mid-flight paper revision has
invalidated already-completed research** (task 438's own description: "changed AGAIN"). A third
occurrence during the re-issued research window is likely, not merely possible, given the commit
cadence. **Recommend the re-issued descriptions for 414/415/417/419 (the four tasks whose
research must re-run) explicitly instruct the next research dispatch to check the paper's git log
for commits since a stated date/SHA as its literal first research step, before re-reading any
definition** — one `git log --since` call, directly foreclosing a third silent-drift cycle.

## Synthesis

### Conflicts Resolved

**Conflict 1 — Coupling scope (Spherical vs. all four axioms).** Teammate D's summary phrasing
suggested `thm:extension`/directed gluing "rests on Spherical rather than composition alone."
Teammates A and C independently derived (by tracing the paper's own proof text, not by inference
from each other) that `thm:extension` is load-bearing on **all four** axioms: Compositionality
(via `lem:segments`, both directions of the biconditional), Seriality (one-sided fiber cases),
Limit (via `lem:nullity`, for the zero-loop closure at the new point), and Spherical (the
directed/two-sided segment case, the one non-substitutable witness-extraction step). The paper's
"rests on Spherical" wording is correctly scoped to `app:gluing`'s footnote specifically (binary
vs. directed gluing), not to `thm:extension` as a whole. **Resolved in favor of A+C**: two
independent derivations from primary-source proof text outrank a summary characterization.
Deliverable 3 states "all four, with Spherical specifically necessary for the two-sided/directed
case," not "Spherical."

**Conflict 2 — Blast radius: the premise is false as stated.** The task description's own
"Scope Completeness" framing implicitly asks whether the six-task cluster is the full blast
radius. Teammate C found task 424 (not_started, gates the entire ultraproduct branch) hard-codes
the current Omega-parameterized semantics via its governing archived design doc and will break
silently once 414 lands. Teammate D independently found `ROADMAP.md`'s own "Paper Alignment
Programme" section is a fourth stale artifact untouched by Part B's deliverable 6. **Resolved**:
this report states plainly that the six-task cluster is the full blast radius of **Part B's
rewrite scope** but not of the **definitional change** itself, and names 424 and `ROADMAP.md` as
out-of-scope-but-affected follow-ups (see Blast Radius section above), rather than silently
confirming completeness. C's "unchecked, not cleared" caveat for tasks 421-423 and 425 is carried
forward as a Gap, not resolved as a negative finding.

**Conflict 3 — Satisfiability row.** A and C independently found the paper has no `\label`'d
definition of satisfiability, only informal prose (a footnote gloss and two worked-example
mentions). **Resolved**: the reconciliation table's satisfiability row (row 27, Deliverable 1)
reads "N/A — no paper definition exists," never populated from repo prose alone, which would
silently reintroduce the non-authoritative-source problem this task exists to correct. Recorded
as an agreed correction to the task's own deliverable-1 spec, which had asked the table to
"cover... satisfiability" without anticipating that no anchor exists.

**Conflict 4 — 420's three helper theorems.** The task description said they "plausibly survive."
Teammate C independently verified directly against `FormalSystem/Semantics/TaskFrame.lean`
(`limit_nullity_of_succOrder` :261-269, `limit_nullity_of_shift` :289-316,
`exists_uniform_radius_of_finite` :340-368 — all stated against a bare relation `R`, never a
`TaskFrame` field). Teammate B reached the same conclusion independently by the same direct read.
**Resolved**: upgraded from "plausibly survive" to **VERIFIED** in Deliverable 4's Task 420
section — two independent direct reads of the same primary source, in agreement.

**Conflict 5 — 414's Omega-excision counts (~110 declarations: 88 dead / 16 live-portable / 8
live-unportable).** Teammate C explicitly did not re-derive these (out of critic-scope). Teammate
B did more than restate them: B confirmed the counts EXACTLY against
`specs/414_.../reports/02_group-c-reconciliation.md` Finding 7, checking the internal arithmetic
(88 dead + 9 LIVE-P + 7 LIVE-P+lemma = 16 live-portable, + 8 LIVE-UNPORT) and reading that
report's own methodology section, which documents kernel-level verification. What B did NOT do —
and what nobody in this round did — is re-run the reachability analysis against the *current*
Lean tree.

**Resolved with that distinction preserved, because the two halves have different force.** The
counts are **VERIFIED as an internally-consistent, correctly-cited transcription** of 414's
report 02; they are **NOT re-derived against the current tree**. The distinction is load-bearing
here: the task description explicitly warns that "the counts in this description predate this
task" and instructs re-verification, and 414's report 02 predates task 415's landing. So the
right characterization is neither "confirmed" flat (which would let Part B present a possibly-drifted
number as fresh) nor "inherited-not-reconfirmed" flat (which understates B's arithmetic and
methodology check and would send a future agent to redo work already done). B's own orthogonality
argument stands independently of the arithmetic: dead code stays dead and live code stays live
whichever predicate replaces `Omega`/`IsMax`, so the *bucketing* survives the totality change even
if the *cardinalities* have since drifted. The re-issued 414 description must carry both halves,
and must repeat B's separate finding that the bucketing survives while every replacement lemma
quoted in that report (all `IsMax`-flavored) still needs re-targeting to totality.

**Conflict 6 — Task 420 status choice (blocked vs. partial).** The task description requires a
justified choice. Teammate B recommends `blocked`, reasoning that 420's Lean work needed no
rework (only phase 6's target and the stale LaTeX rewrite are stale) and that `partial` connotes
an interrupted/incomplete attempt, which phases 1-5 are not. Teammate C independently supplies
the same supporting fact (paper's axiom-mirror is now complete and matches 420's own landed axiom
set; only the phase-6 target and the LaTeX rewrite are stale) without overriding B's framing as
the decision-owner. **Resolved**: both teammates converge on `blocked` from independent angles.
This report recommends `blocked` for Part B, flagged as a recommendation for Part B to adopt
(per B's own status field revision) rather than a decision already taken by this research round.

**Conflict 7 — Cluster shape.** Teammate D stress-tested the six-task decomposition and found it
still defensible (420's five landed phases make a "collapse 414+420" alternative either revert
green work or achieve no real collapse), but flagged a real coupling gap: 420 could land Spherical
as an inert struct field while 414 separately rebuilds totality machinery, leaving both green but
jointly non-reconstructive of `thm:extension`. **Resolved**: fold this in as a cross-task
acceptance criterion recommendation for Part B (see Deliverable 4's Task 420 section and
Recommendations below) rather than as a call to re-scope the cluster — the six-task count stands.

### Gaps Identified

1. **414's Omega-excision counts (~110 declarations: 88 dead / 16 live-portable / 8
   live-unportable) are verified-as-transcribed but not re-derived against the current tree.**
   Teammate B checked the internal arithmetic and the methodology section of 414's
   `02_group-c-reconciliation.md` Finding 7 (see Conflict 5); nobody re-ran the reachability
   analysis this round, and that report predates task 415's landing, so the cardinalities may
   have drifted. The *bucketing* is orthogonal to the totality change and survives regardless;
   the *numbers* are the open item. Part B's re-issued 414 description must state both halves
   and must not present the counts as freshly re-derived by task 438.
2. **Tasks 421-423 and 425 (topic `strong_completeness`) are unchecked, not cleared, for
   second-order exposure to the definitional change.** A description-level grep found no direct
   textual hits, but their design docs (the likely locus of exposure, per the 424 finding) were
   not opened. Left as an open item for a follow-up spawn if in scope.
3. **Whether Seriality and Spherical are automatic over `D = ℤ` for task 417's finite-carrier
   construction is unverified.** Both teammates flag this as a plausible-but-unproven research
   lead (Seriality: likely automatic for a no-dead-ends frame; Spherical: plausible finite-set
   pigeonhole corollary per Teammate D) rather than a settled fact — 417's next research pass
   must verify it, not assume it.
4. **The rename-cost preflight (deliverable 7) has not been run.** Teammate C's recommended
   `grep -rl` for each old slug (`414_refactor_semantics_to_maximal_history_validity`,
   `415_completeness_over_maximal_history_semantics`,
   `420_align_task_frame_with_positive_cone_limit_nullity`) across `specs/**/*.md` before
   committing to any rename has not been executed by this research round — it is Part B
   execution, out of Part A's scope, but is a concrete precondition Part B must not skip.
5. **`ROADMAP.md`'s "Paper Alignment Programme" section and task 424's design-doc dependency are
   named but not remediated** — both are explicitly out of task 438's non-goals (neither touches
   `specs/state.json`'s cluster-task descriptions) and are recorded here as follow-ups for the
   task's completion summary, not resolved by this report.
6. **No standing convention exists for marking a superseded report file** (Teammate C's
   recommendation: a one-line `> **SUPERSEDED**` banner at the top of each superseded report, since
   a description-level statement alone leaves a future agent opening the report file directly with
   no warning). This is a process gap broader than task 438 — Teammate C notes it may be worth a
   `.claude/rules/` or `.claude/context/patterns/` note if this pattern recurs, which the paper's
   own revision cadence suggests it will.
7. **The definitions-of-record file and lint script (Recurrence Prevention, Option A+C) are
   recommended but not built.** Building them is out of task 438's Part A/B scope (new `.claude/`
   tooling is a `meta`-type change) — recorded as a recommended follow-up `meta` task.

### Recommendations for Part B

1. **Rewrite all six cluster task descriptions** per Deliverable 4's per-task verdicts above,
   each carrying: the current four-axiom `def:frame` and totality-based consequence as settled
   inputs; `\label`-based paper anchors (never bare line numbers); an explicit survives/refuted
   breakdown so the next agent does not silently re-consume a refuted finding; and all still-valid
   scope/non-goal/notation content preserved verbatim (nothing shortened merely to be tidy).
2. **Status changes**: 414 → `not_started`; 415 → `not_started`; 417 → `not_started`; 419 stays
   `not_started` (description rewrite only, citation fix + Spherical-risk flag); 420 stays
   `blocked` (revised `blockers` field per Conflict 6's resolution and the compensating-record
   requirement from Deliverable 5); 427 stays `not_started` (description rewrite only).
3. **Renames**: 414 → `refactor_semantics_to_total_history_validity`; 415 →
   `completeness_over_total_history_semantics`; 420 → `align_task_frame_with_positive_cone_axioms`.
   417, 419, 427 need no rename. Run the `grep -rl` rename-cost preflight (Gap 4 above) for each
   before committing.
4. **Apply the corrected dependency edges** from Deliverable 5: drop `415` from
   `420.dependencies`; all other edges unchanged. Add the cross-task acceptance-criterion text
   (Conflict 7 / Deliverable 4's Task 420 section) to both 414 and 420's descriptions as
   descriptive content, not a graph edge. Verify with `.claude/scripts/generate-task-order.sh
   --print` per Deliverable 5's post-verification checklist.
5. **Add a one-line `> **SUPERSEDED**` banner** to the top of each existing report file whose
   content predates the four-axiom/totality generation (at minimum: 420's phase-1/phase-5
   reports and summary sections describing the three-axiom frame; 414's and 415's existing
   research reports), per Teammate C's recommendation — cheap, and closes the "reader opens the
   report file directly with no warning" gap even though the description-level statement
   technically satisfies the letter of the task's requirement.
6. **Name, but do not remediate, the two out-of-cluster follow-ups**: task 424's dependency on
   the current Omega-parameterized semantics (via its archived design doc), and `ROADMAP.md`'s
   stale "Paper Alignment Programme" section. Record both in task 438's completion summary as
   named follow-ups.
7. **Instruct the four re-run research dispatches (414, 415, 417, 419)** to check the paper's git
   log for commits since a stated date/SHA as their literal first research step, before
   re-reading any definition (Recurrence Prevention section above).
8. **Regenerate `specs/TODO.md`** via `.claude/scripts/generate-todo.sh` after all `state.json`
   edits, and commit `state.json` + `TODO.md` + this report together.
9. **Record the definitions-of-record-file + lint-script recommendation** (Recurrence Prevention,
   Option A+C) as a named follow-up `meta` task in the completion summary, rather than building it
   inside task 438.
10. **After Part B, re-read all six descriptions end to end** and grep them for the superseded
    vocabulary ("Limit Nullity", "lax", "maximal-history", "IsMaximal", "NOT adopted"),
    justifying every remaining hit — per the task's own verification requirement.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary — reconciliation table, target Lean signatures, coupling analysis (Deliverables 1-3) | completed | High (reconciliation table); medium-high (target signatures); high on axiom-load-bearing / medium on Lean-cost estimates (coupling analysis) |
| B | Alternatives — per-task staleness verdicts, dependency-cycle resolution (Deliverables 4-5) | completed | High (cluster inventory, 420 helper-theorem genericity, Omega-excision count *citation* accuracy, dependency-cycle existence/shape, CO-axiom citation correction, 419 Spherical-risk flag); medium (414 prototype reusability percentage for `thm:extension`; Seriality/Spherical automaticity over ℤ for 417); lower/exploratory (exact rename target strings) |
| C | Critic — starting-fact audit, missed changes, blast-radius gaps | completed | High (starting-fact audit, all 11 rows independently re-derived; task-424 blast-radius finding); medium (blast-radius gap item 2 — negative grep result across 20 task descriptions, design docs for 421-423/425/428-437/410-413/95 not opened); low/none (dependency-cycle resolution and 414 Omega-excision count, both explicitly out of critic scope) |
| D | Horizons — recurrence prevention, cluster shape, adjacent roadmap leverage, sequencing/risk | completed | High (paper commit velocity and CHANGE-marker mechanism; six-task dependency edges and adjacent-task statuses; quoted paper text; current Lean `TaskFrame` field state); medium (Spherical-over-finite-`W` "free corollary" claim for 417 — a plausible mathematical lead, not Lean-verified); speculative and marked as such (the "recurrence as deliverable" reframing and the bidirectional-authority observation under Unconventional Angles) |

## References

**Paper** (`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, read in full
across relevant ranges by two or more teammates on 2026-08-09): `\label{def:frame}` (`:2412-2465`,
body mirror at `sec:Construction`/`:905-927`), `\label{lem:nullity}` (`:2489-2504`),
`\label{def:world-history}` (`:2570-2579`), `\label{app:gluing}` (`:2584-2607`, Spherical-coupling
footnote `:2590`), `\label{lem:segments}` (`:2611-2622`), `\label{thm:extension}` (`:2625-2648`,
Zorn/AC footnote `:2628-2629`), `\label{thm:occurrence}` (`:2651-2658`), `\label{app:nonempty}`,
`\label{def:BL-model}` (`:2673-2675`), `\label{def:BL-semantics}` (`:2677-2701`, box clause
`:2696`), `\label{def:frame-properties}` (`:2841-2849`), `\label{def:frame-validity}`
(`:2851-2869`), `\label{def:logical-consequence}` (`:3331-3336`), `\label{def:derivability}`,
`\label{def:soundness}` (`:3331-3344` region), `\label{CO}` (`:1217`), `\label{def:TMplus-c}`
(`:3706`), `\label{TMP-CO}` (`:3709-3711`), `\label{cor:tm-completeness}` (`:3750-3764`),
`\label{thm:ConservativeExtension}` (`:3729-3748`); Spherical non-example footnote (`:926`);
`\aitem`/`\aref` macro definitions (`:366-374`); `%% CHANGE` provenance comments throughout
(139 total, `grep -c "%% CHANGE"`), including `sphericity-promote`, `sphericity-hoist`,
`sphericity-formal`, `task 56 package3`, `nullity-limit` (`:3392`), `fix.md A2` (`:2416-2418`).

**Lean** (`/home/benjamin/Projects/BimodalLogic/`, re-read/re-grepped independently by two or more
teammates on 2026-08-09): `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame` (152),
`nullity_identity` (163), `forward_comp` (177), `converse` (191), `TaskFrame.nullity` (202),
`TaskFrame.backward_comp` (212), `TaskFrame.limit_nullity_of_succOrder` (261),
`TaskFrame.limit_nullity_of_shift` (289), `TaskFrame.exists_uniform_radius_of_finite` (340),
module docstring known-gaps note (65-72), paper-citation docstring (47-48). `FormalSystem/
Semantics/WorldHistory.lean` — `WorldHistory` (75), `domain` (78), `convex` (88), `states` (94),
`respects_task` (103), `WorldHistory.timeShift` (246). `FormalSystem/Semantics/TaskModel.lean` —
`TaskModel` (49), `valuation` (56). `FormalSystem/Semantics/Truth.lean` — `TruthAt` (128), atom
case (130), box case (133), `ShiftClosed` (333). `FormalSystem/Semantics/Validity.lean` — `valid`
(79), `SemanticConsequence` (103), `satisfiable` (129), `SatisfiableAbs` (138),
`FormulaSatisfiable` (154), `valid_iff_empty_consequence` (331). `FormalSystem/Theorems/
DedekindDerived.lean` — `co_derived`. `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` —
`co_valid`. `FormalSystem/ProofSystem/Axioms.lean` (360-399, `Formula.co`, `:367-369`).

**Repo prose**: `latex/subfiles/02-Semantics.tex` (165 lines, read in full) — `def:frame` (line
31), `World History` (76), `Truth` (98), `Logical Consequence` (148), `Validity` (152),
`Satisfiability` (157). `typst/chapters/02-semantics.typ` (169 lines, read in full) — `Task Frame`
(35), `World History` (62), `Truth` (84), `Logical Consequence` (149), `Validity` (153),
`Satisfiability` (158).

**Prior task artifacts**: `specs/414_refactor_semantics_to_maximal_history_validity/reports/
01_maximal-history-validity-refactor.md`, `02_group-c-reconciliation.md`;
`specs/415_completeness_over_maximal_history_semantics/reports/01_completeness-maximal-history-
rebase.md`; `specs/417_semantic_fmp_finite_worldstate_over_z/reports/01_semantic-fmp-finite-
worldstate.md`; `specs/419_machine_check_co_reynolds_independence/` (description only, no
artifacts); `specs/420_align_task_frame_with_positive_cone_limit_nullity/summaries/
01_taskframe-limit-nullity-alignment-summary.md`, plan, report, `.orchestrator-handoff.json`;
`specs/427_sync_typst_book_with_refactored_paper/` (description only); `specs/archive/
361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/
02_compactness-route.md` (lines 98-103, 152-177, 245-248); `specs/ROADMAP.md:1599-1641`.

**Repo tooling**: `.claude/scripts/generate-task-order.sh --print` (dependency-graph wave output,
re-run live); `.claude/scripts/check-task-references.sh`, `literature-briefing.sh`'s
`<!-- lit-coverage ... -->` marker (cited as precedent for the recommended
`check-paper-definitions.sh`).

**External**: Cmiel, "Ball spaces" (2021) — cited by the paper's `\label{def:frame}` footnote as
the source of the Spherical/Sd1 directed-intersection condition.
