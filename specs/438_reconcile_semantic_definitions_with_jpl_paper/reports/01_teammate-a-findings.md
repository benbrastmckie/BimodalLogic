# Teammate A Findings: Paper/Lean/Prose Reconciliation (Part A, Deliverables 1-3)

Scope: this report covers Part A deliverables 1 (reconciliation table), 2 (target Lean
signatures), and 3 (coupling analysis) only. Deliverable 4 (per-task staleness verdicts for the
six cluster tasks) and deliverable 5 (dependency-cycle resolution) are out of scope for this
slice. Part B (state.json rewrites) is explicitly out of scope for this dispatch.

All paper citations below are by `\label` anchor against
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, quoted verbatim from
the file read on 2026-08-09. No bare line numbers are used as citations (per the cluster's
citation-discipline requirement); where a line number appears it is a parenthetical convenience
alongside the label, never a substitute for it. All Lean claims are file path + declaration name,
re-verified against the current tree by direct `Read`/`grep` on 2026-08-09 (not copied from any
prior report or from the task description's own inventory).

## Key Findings

1. **The four-axiom `def:frame`, as described in the task, is confirmed verbatim** in both the
   appendix restatement (`\label{def:frame}`) and the body original (`sec:Construction`,
   unlabeled enumerate immediately after the `\label{sub:WorldStates}`/`\label{sec:Construction}`
   material) — the two are a character-for-character mirror per the file's own `%% CHANGE
   (sphericity-promote)` comments. Nullity is confirmed demoted to `\label{lem:nullity}`, a
   derived lemma, not a frame axiom.

2. **`FormalSystem/Semantics/TaskFrame.lean`'s `TaskFrame` structure (line 152) has exactly three
   fields beyond `WorldState`/`TaskRel`**: `nullity_identity` (line 163, an axiom — the paper has
   demoted this to a lemma), `forward_comp` (line 177, the **lax** inclusion law, hypotheses
   `0 ≤ x`, `0 ≤ y` — the paper has replaced this with a **biconditional**), and `converse` (line
   191, unchanged, matches). **Seriality, Limit, and Spherical are entirely absent as fields.**
   Segment (`Seg`) and fiber (`Fib`) machinery are entirely absent from the file (confirmed by
   grep: no `Seg`, `Fib`, `Segment`, `Fiber`, `Seriality`, `Spherical`, or `Occurrence` token
   anywhere under `FormalSystem/Semantics/`). `Nonempty WorldState` and `[Nontrivial D]` are
   absent as structure data — the module's own docstring (lines 65-72) already names both as
   "known gaps relative to the paper," predating this task and independently confirming the
   audit.

3. **`FormalSystem/Semantics/WorldHistory.lean`'s `WorldHistory` structure (line 75) has no
   totality predicate and no extension order.** `domain : D → Prop` (line 78) is an arbitrary
   convex predicate with no "is this all of `D`" notion anywhere in the file, and no `Extends`/
   extension-order declaration exists. Grep of the whole `FormalSystem/Semantics/` directory for
   `IsMax`/`isMax`/`maximal`/`Maximal` returns **zero hits** — confirming the task description's
   claim that maximal-history vocabulary is absent from this module (it lives elsewhere, in
   maximal-*consistent-set* vocabulary unrelated to histories).

4. **`FormalSystem/Semantics/Truth.lean` and `Validity.lean` are exactly as the task describes**:
   `TruthAt` (Truth.lean:128) takes an arbitrary `Omega : Set (WorldHistory F)` parameter, the box
   clause (Truth.lean:133) reads `∀ σ, σ ∈ Omega → TruthAt M Omega σ t φ`, and `valid`
   (Validity.lean:79) / `SemanticConsequence` (Validity.lean:103) / `satisfiable`
   (Validity.lean:129) all bind `(Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega) (τ :
   WorldHistory F) (_ : τ ∈ Omega)`. `ShiftClosed` is defined at Truth.lean:333. None of these
   declarations restrict `Omega` to total histories; `Omega` is a free parameter that could be
   `Set.univ`, a proper subset, or anything shift-closed.

5. **Both repo prose documents are stale on both axes, and by different amounts** — this was
   worth re-verifying rather than assuming. `latex/subfiles/02-Semantics.tex` (`\label{def:frame}`
   at its own line 31) states the **three-clause, pre-Seriality/pre-Spherical** frame (Nullity
   iff, Compositionality as a one-directional conditional, Limit Nullity) — this is the
   *second-to-last* generation, one step behind the Lean tree's own (also-stale) three-field
   structure in the *sense that it also omits Seriality/Spherical but additionally still uses
   conditional rather than biconditional Compositionality, matching Lean exactly on this point*.
   `typst/chapters/02-semantics.typ` (`#definition("Task Frame")` at its own line 35) is
   **two generations further behind**: Nullity, Reflection, Compositionality — the pre-refactor
   axiom set that predates even the positive-cone/converse-convention presentation the paper
   currently uses in full (Reflection is stated as an independent postulated axiom in typst,
   whereas the paper and the Lean tree both treat it as *derived* from the converse convention).
   Neither prose document has any notion of totality, extension order, or a total-vs-bounded
   distinction for world histories; both quantify `□` and logical consequence over the full
   (untotaled) `H_F`/histories set with no totality qualifier, consistent with the task
   description's claim.

6. **The paper has no dedicated `\label` for "satisfiability" as a standalone definitional
   clause** — I searched the full document for `satisf` (case-insensitive) and found no `Ddef`
   with a `\label` naming satisfiability as a defined term in the semantics apparatus; the closest
   formal anchor is `\label{def:logical-consequence}`'s validity clause (`\varphi` is *valid* iff
   `\vDash \varphi`, i.e. logical consequence of `\emptyset`), from which satisfiability would be
   the standard dual (`Γ` satisfiable iff `Γ ⊭ ⊥`, or equivalently the existence of a witnessing
   model/possible-world/time). Both repo prose documents (`latex` and `typst`) DO carry an
   explicit `Satisfiability` definition of their own invention (existential witness form), which
   is a reasonable formalization choice but is not itself a verbatim mirror of any single paper
   `\label` — flagged so the re-issued specs do not claim a satisfiability anchor that does not
   exist in the source.

## Reconciliation Table

Columns: **Paper** (verbatim quote + `\label`) | **Current Lean** (declaration + file:line) |
**Current repo prose** (file + section) | **Verdict**.

### `def:frame` and its supporting machinery

| # | Clause | Paper (`\label{def:frame}`, verbatim) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------------------|---------------|---------------------|---------|
| 1 | World States | "A nonempty set of *world states* $W$." | `TaskFrame.WorldState : Type` (`TaskFrame.lean:154`) — carries no nonemptiness witness | latex `Task Frame` def item 1: "$\worldstate$ is a nonempty set" (states nonemptiness in prose, not a formal hypothesis); typst `Task Frame` def: `W` listed with no nonemptiness qualifier at all | **stale** (Lean: absent field; typst: absent even in prose) |
| 2 | Temporal Order | "A **nontrivial** totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$." | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` structure binders (`TaskFrame.lean:152`) — **no `[Nontrivial D]` binder on the structure itself**; `Nontrivial D` is supplied ad hoc downstream (e.g. `Metalogic/Soundness.lean:1066`, `StrongCompleteness.lean:131`) rather than as a structural guarantee | latex: "nontrivial totally ordered abelian group" (matches paper prose); typst: "Temporal durations" with no nontriviality qualifier | **stale** (Lean structural binder; typst prose) — latex prose text matches |
| 3 | Task Relation header (primitive on $D^+$, converse convention, fiber, cone, segment) | "A parameterized task relation $\Rightarrow \subseteq W \times D^+ \times W$ ... extended to negative durations by the *converse convention* $w \Rightarrow_x u \coloneq u \Rightarrow_{-x} w$ ... the *fiber* $\Fib(w, x) \coloneq \{u \in W : w \Rightarrow_x u\}$ ... the *cone* $(w)_x \coloneq \{u \in W : w \Rightarrow_y u \text{ where } |y| < x\}$ ... the *segment* $\Seg(w, v; a, b) \coloneq \Fib(w, a) \cap \Fib(v, -b)$, where the fibers count among the segments as the cases in which one constraint is left vacuous" | `TaskRel` (two-sided, `TaskFrame.lean:156`), `converse` field (`TaskFrame.lean:191`, exact match to the converse convention). **`Fib`, `(w)_x` cone, and `Seg` have no Lean counterpart anywhere in the tree** (confirmed by grep — zero hits for `Seg`/`Fib`/`Segment`/`Fiber` under `FormalSystem/Semantics/`) | latex: states converse convention and cone $\taskcone{w}{x}$ (def item 3) but **no segment/fiber notation at all**; typst: states only the bare `TaskRel` type, **no converse convention formula, no cone, no fiber, no segment** | **match** (converse convention only) / **absent** (fiber, cone-as-named-object beyond the docstring comment, segment) — segments and fibers are needed by Spherical/Seriality/thm:extension and are wholly new machinery for the Lean tree |
| 4 | *Compositionality* | "$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$." | `forward_comp` (`TaskFrame.lean:177`): `∀ w u v x y, 0 ≤ x → 0 ≤ y → TaskRel w x u → TaskRel u y v → TaskRel w (x+y) v` — this is the **one-directional (⊇) inclusion only**, with `u` as a fixed universal argument rather than the paper's existentially-bound witness | latex def item 2 (Compositionality): "if $w \taskto{x} u$ and $u \taskto{y} v$, then $w \taskto{x+y} v$" — same lax one-directional form as Lean, and its own prose (line 56) explicitly states the inclusion "rather than the corresponding equality, which would additionally assert interpolation" — **this is precisely the position the paper has now reversed**; typst def item 3: same one-directional conditional form, no biconditional | **stale** (Lean and both prose documents state the now-superseded lax law; the paper has since adopted the biconditional, absorbing what the cluster's prior task descriptions called "Interpolation... NOT adopted") |
| 5 | *Seriality* (new) | "For every $w \in W$ and $x \in D^+$, $w \Rightarrow_x u$ for some $u \in W$, and $v \Rightarrow_x w$ for some $v \in W$." | **absent** — no field, no lemma, no derived theorem anywhere under `FormalSystem/Semantics/` | **absent** in both latex and typst — neither document has ever carried a Seriality clause (the only "Seriality" grep hit in the whole `FormalSystem/` tree is an unrelated proof-theoretic comment in `Metalogic/BXCanonical/Frame.lean:157` about a derivability fact, not this semantic axiom) | **absent** everywhere |
| 6 | *Limit* | "$\bigcap_{x > 0} (w)_x = \{w\}$." | **absent as a field.** `TaskFrame.lean`'s own docstring (lines 65-72) already documents the intended transcription `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w` and provides two *helper theorems that discharge it against a bare relation* rather than a frame field: `TaskFrame.limit_nullity_of_succOrder` (line 261) and `TaskFrame.limit_nullity_of_shift` (line 289), plus a corollary `TaskFrame.exists_uniform_radius_of_finite` (line 340) | latex def item 3 ("Limit Nullity"): "$\bigcap_{x > 0} \taskcone{w}{x} = \{w\}$" — **prose matches the paper's Limit clause exactly**, but under the old name "Limit Nullity" (the paper has since split Limit and Nullity apart and renamed this clause plain "Limit"); typst: **absent entirely**, no Limit/Limit-Nullity clause of any kind | **stale-by-naming, structurally absent** (Lean: not a field, only discharge helpers for a bare relation; latex: content matches but under the retired compound name "Limit Nullity"; typst: fully absent) |
| 7 | *Spherical* (new) | "Every $\supseteq$-directed family of nonempty segments has a nonempty intersection, where a nonempty family of segments is *$\supseteq$-directed* just in case any two members include a common member of the family." | **absent** — no field, no directedness predicate, no segment type to state it over | **absent** in both latex and typst | **absent** everywhere; this is the axiom whose transcription cost is analyzed below (Coupling Analysis, §3) |
| 8 | "No condition beyond these axioms... the *Occurrence* condition... is derived in `\ref{thm:occurrence}`" | (closing remark to `def:frame`, no separate label) | Confirmed no `Occurrence` token anywhere under `FormalSystem/Semantics/` — consistent with it never having been a Lean-side axiom in this repo's stale three-field structure either (it was never carried even under the old three-field regime) | Neither prose document names "Occurrence" as a condition or theorem | **n/a to reconcile** — the paper's own point is that Occurrence is *not* a frame condition; nothing to add on the axiom side, but `thm:occurrence` itself (a real theorem) is absent from Lean — see row 15 below |

### `lem:nullity` and the demoted status of Nullity

| # | Clause | Paper (`\label{lem:nullity}`, verbatim) | Current Lean | Current repo prose | Verdict |
|---|--------|-------------------------------------------|---------------|---------------------|---------|
| 9 | Nullity (now a derived lemma, not an axiom) | "$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$." Proved from Seriality at $x=0$ together with Limit; the paper's own subsequent remark also over-determines it from *Compositionality* plus *Limit* alone, without Seriality. | `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` is a **structure field / axiom** (`TaskFrame.lean:163`), the strictly stronger **biconditional** form (the paper's version is one-directional reflexivity only, no injectivity-at-zero claim). A derived `TaskFrame.nullity` theorem (`TaskFrame.lean:202`) restates the reflexivity half from the axiom, trivially (`nullity_identity w w |>.mpr rfl`) — this is NOT the paper's proof (paper derives from Seriality+Limit or Compositionality+Limit; Lean derives it from the very axiom that is supposed to disappear) | latex def item 1 ("Nullity"): states the **biconditional** form ("if and only if $w=u$") as an *axiom*, matching Lean's current (stale) axiomatization exactly, not the paper's current demoted-lemma status; typst def item 1: "*Nullity*: For all $w:W$, we have $w \Rightarrow_0 w$" — states only the reflexivity half, as an axiom (also stale relative to demotion, but at least states the correct one-directional content rather than the stronger biconditional) | **stale** everywhere: paper demotes Nullity from axiom to lemma and weakens its content to bare reflexivity (no injectivity-at-zero); Lean and latex both still axiomatize the *biconditional* (net effect: current Lean/latex assert something the paper never asserted and never needs — the injectivity-at-zero direction — while also failing to derive it, since it's now a hypothesis, not a theorem); typst axiomatizes the correct weaker content but still as an axiom, not a lemma |

### `def:world-history` (totality, extension order) and dependent theorems

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 10 | World history (base definition) | `\label{def:world-history}`: "A *world history* over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ where $X \subseteq D$ is a nonempty convex set and $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$." | `WorldHistory` structure (`WorldHistory.lean:75`): `domain : D → Prop` (line 78), `convex` (line 88, matches convexity requirement exactly, phrased as an interval-closure condition rather than a subset-of-D typing, semantically equivalent), `states` (line 94, dependent function `(t : D) → domain t → F.WorldState`, matching $\tau : X \to W$ once $X$ is read as the subtype of `domain`), `respects_task` (line 103, matches $\tau(x) \Rightarrow_{y-x} \tau(y)$ exactly, including the converse-convention handling for $y < x$ implicit in `TaskRel`'s two-sidedness) | latex `World History` def (its own numbered def, no explicit label used in the .tex source): dependent function form, matches; typst `World History` def: same, matches | **match** on the base (non-total) definition, in all three artifacts — this is the one clause of `def:world-history` that nothing has drifted on |
| 11 | Total / possible world | Same `\label{def:world-history}`: "A world history is *total*--- equivalently, a *possible world*--- just in case $X = D$... The set of all total world histories over $\F$ is denoted $H_{\F}$." | **absent.** No `IsTotal`/`total` predicate, no `H_F`-as-total-subset construction anywhere in `WorldHistory.lean` or elsewhere under `Semantics/`. The nearest Lean object literally named `H`-like is `Omega : Set (WorldHistory F)` in `Truth.lean`/`Validity.lean`, which is an arbitrary shift-closed parameter, not the canonical total-history set | latex: no totality notion anywhere in `02-Semantics.tex`; typst: no totality notion anywhere in `02-semantics.typ` — both simply write $H_{\F}$ (or $\histories_{\taskframe}$) as "all world histories over frame", not "all *total* world histories" | **absent** everywhere — this is the central gap driving the totality-based-consequence change |
| 12 | Extension order | Same `\label{def:world-history}`: "a world history $\sigma$ *extends* $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$." | **absent.** No `Extends`/`≤` instance, no `Preorder (WorldHistory F)` anywhere in `WorldHistory.lean`. (The task description's pointer to a prior ~85-line prototype with a `Preorder` instance and `chainSup` refers to prior research/artifact content, not anything currently in `FormalSystem/`; re-verified: no such instance exists in the current tree.) | **absent** in both latex and typst | **absent** everywhere |
| 13 | `app:gluing` (binary gluing corollary) | "For any frame... and world histories $\tau_1, \tau_2$... the function $\tau$ defined on $X_1 \cup X_2$ by restricting to $\tau_1$ on $X_1$ and $\tau_2$ on $X_2$ is the unique world history over $\F$ with domain $X_1 \cup X_2$ that restricts to both." Proof uses only Compositionality (the biconditional's right-to-left direction) and the converse convention; the footnote records that *directed* gluing (as opposed to binary) additionally rests on Spherical via `thm:extension`, not on Compositionality alone. | **absent** — no gluing lemma anywhere in `WorldHistory.lean` | **absent** in both prose documents | **absent** everywhere |
| 14 | `lem:segments` | "If $h : A \cup C \to W$ is task-constrained where $t < z < s$ for all $t \in A$ and $s \in C$, then the segments $\Seg(h(t), h(s); z-t, s-z)$ for $t \in A$ and $s \in C$ form a $\supseteq$-directed family of nonempty segments." | **absent** | **absent** in both prose documents | **absent** everywhere — direct prerequisite of `thm:extension` |
| 15 | `thm:extension` | "For any frame... every task-constrained function $h : S \to W$ on a nonempty set $S \subseteq D$ is extended by some total world history $\sigma \in H_{\F}$." Proof appeals to Zorn's lemma (AC). | **absent** as stated. Task description's pointer to a 414-adjacent ~85-line prototype (`timeShift_mono`, `isMax_timeShift`, `chainSup`, `exists_maximal_extension`) is, per the task description itself, a **maximal-history** result under `IsMax`, a *different* predicate from totality; re-verified there is no such content currently in `FormalSystem/Semantics/` (grep for `IsMax`/`maximal` in `Semantics/` returns nothing), so whatever prototype exists is not merged into this module and cannot be graded "present but wrong-predicate" from this file alone — it is simply absent from the file under audit | **absent** in both prose documents — extension-to-total is asserted informally in `sec:Construction` prose (see `thm:extension` body citation at possible_worlds.tex line 932, "The *Appendix* proves... that every world history extends to a total world history") but the repo's own prose files carry no analogous claim at all | **absent** everywhere in this repo's Lean/prose (the paper-side theorem exists in full; nothing in-repo mirrors it) |
| 16 | `thm:occurrence` | "For every frame... and world state $w \in W$, there are a total world history $\tau \in H_{\F}$ and a time $y \in D$ where $\tau(y) = w$." (Derived from `lem:nullity` + `thm:extension`; needs AC via `thm:extension`.) | **absent** | **absent** in both prose documents | **absent** everywhere |
| 17 | `app:nonempty` ($H_{\F} \neq \emptyset$) | "For any frame... there is a total world history $\tau \in H_{\F}$ with $\tau(x) = w$, and so $H_{\F} \neq \emptyset$." | **absent** as a theorem about a total-history set (there is no `H_F` object to state nonemptiness of); trivially, `Omega.Nonempty` is never established generically for the current `Omega` parameter in `Validity.lean` — nonemptiness of the evaluation-point set is not a theorem anywhere in the tree, it is instead an unproven side-condition folded into every `valid`/`SemanticConsequence` binder as the hypothesis `τ ∈ Omega` | **absent** in both prose documents | **absent** everywhere |

### `def:BL-model`, `def:BL-semantics` (truth clauses)

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 18 | Model | `\label{def:BL-model}`: "A *model* of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$ is a frame and $\vert{p_i} \subseteq W$..." | `TaskModel` (`TaskModel.lean:49`): `valuation : F.WorldState → Atom → Prop`, extending a `TaskFrame` — structural match modulo the frame-content staleness already covered above | latex `Task Model` def (function-valued `I : W → String → Prop`), typst `Task Model` def (`I : W → Atom → Prop`) — both structurally match | **match** (structurally; inherits the frame-level staleness transitively, but the model wrapper itself is not independently stale) |
| 19 | Atom clause | `\label{def:BL-semantics}` item ($p_i$): "$\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in \vert{p_i}\vert$." **No domain-membership conjunct** — the paper explicitly dropped it (see the file's own `%% CHANGE (task 52 total-histories)` comment: "atom clause loses the dom conjunct, matching the total, bivalent body clause") because $\tau$ is now always total, so $\tau(x)$ is always defined. | `TruthAt` atom case (`Truth.lean:130`): `Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` — **carries an explicit existential domain-membership proof**, i.e. atoms are false at any $t$ outside $\tau$'s (possibly-proper) domain | latex atom clause (Truth def, line 101): "$x \in \domain(\tau)$ and $I(\tau(x), p)$" — **carries the domain conjunct**; typst atom clause (line 87): same, "$x \in "dom"(tau)$ and $I(tau(x), p)$" — **carries the domain conjunct** | **stale** everywhere, but note the staleness is *entailed* by the totality gap rather than independent: once `τ` is restricted to total histories, `τ.domain t` is provably always true and the domain conjunct becomes vacuous/removable without changing truth conditions. This is not a clause to patch in isolation; it falls out once totality lands (see Target Lean Signatures, §2) |
| 20 | Falsum clause | `($\bot$)`: "$\M,\tau,x \nvDash \bot$." | `Truth.lean:131`: `Formula.bot => False` | latex/typst: `⊭ ⊥` unconditionally, both match | **match** |
| 21 | Implication clause | `($\shortrightarrow$)`: standard material conditional | `Truth.lean:132`: matches | latex/typst: match | **match** |
| 22 | Box clause (quantifier domain) | `($\Box$)`: "$\M,\tau,x \vDash \Box \varphi$ *iff* $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$" — quantifies over **total** world histories only, by the current `H_F` definition (row 11 above) | `Truth.lean:133`: `Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → TruthAt M Omega σ t φ` — quantifies over an **arbitrary parameter set `Omega`**, which need not be, and generically is not, "the total histories"; the docstring at `Validity.lean:44-45` even states the `ShiftClosed Omega` mechanism is meant to be "equivalent to... `Set.univ`" (i.e. *all* histories, bounded and total alike), which is a different set from $H_{\F}$ under the paper's current totality-restricted reading | latex box clause (line 105-106): "$\model, \sigma, x \vDash \varphi$ for all $\sigma : \histories_{\taskframe}$" — quantifies over *all* world histories (no totality restriction stated); typst box clause (line 91-92): same, all of $H_{\cal(F)}$, no totality restriction | **stale** everywhere — this is the box clause's quantifier-domain divergence named explicitly in the task description, and it is confirmed: none of Lean, latex, or typst restrict $\Box$'s range to total histories specifically; Lean's `Omega` is strictly more general (any shift-closed set) while both prose documents are simply silent on totality (implicitly ranging over all histories, bounded included) |
| 23 | Past/Future clauses | Standard, quantify over all $y \in D$ (not domain-restricted) | `Truth.lean:134-137` (via `TruthAt`'s `untl`/`snce` cases) and the derived `future_iff`/`past_iff` theorems — match, quantify over all `y : D`/`s : D` unconditionally | latex/typst: match, quantify over all $y:D$ | **match** |

### `def:frame-validity`, `def:logical-consequence`, `def:soundness`, satisfiability

| # | Clause | Paper (verbatim + label) | Current Lean | Current repo prose | Verdict |
|---|--------|----------------------------|---------------|---------------------|---------|
| 24 | Frame validity | `\label{def:frame-validity}`: "$\vDash_{\F} \varphi$ if and only if $\M,\tau,x \vDash \varphi$ for every model $\M$..., possible world $\tau \in H_{\F}$, and time $x \in D$." Never vacuous, since $H_{\F} \neq \emptyset$ for every frame by `\ref{app:nonempty}` (a theorem, not an assumption) | No `valid_over_frame`/per-frame validity notion exists in `Validity.lean` at all — the Lean tree only has the fully-universally-quantified `valid` (over all `D`, `F`, `M`, `Omega`, `τ`, `t`, `Validity.lean:79`), never a frame-relative $\vDash_{\F}$ predicate; nonemptiness of the evaluation set is never established as a theorem, only assumed as the hypothesis `τ ∈ Omega` | Neither latex nor typst has a distinct frame-relative validity definition either — both jump straight to the universally-quantified `Validity`/`Logical Consequence` definitions (rows 25-26) | **absent** (no Lean or prose counterpart to the frame-relative notion at all — this is a genuine gap independent of the totality change, though the totality change is what would make `\ref{app:nonempty}`'s never-vacuous guarantee available as a theorem rather than an assumption) |
| 25 | Logical consequence | `\label{def:logical-consequence}`: "A conclusion $\varphi$ is a *logical consequence* of a set of premises $\Gamma$ ... just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$." $\tau$ ranges over **total** world histories ($H_{\F}$) only. | `SemanticConsequence` (`Validity.lean:103`): `∀ D F M (Omega) (_ : ShiftClosed Omega) (τ ∈ Omega) t, (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ` — quantifies over `τ ∈ Omega`, an arbitrary shift-closed parameter, not the total-history set specifically | latex `Logical Consequence` def (line 149): "history $\tau \in \histories_{\taskframe}$" — no totality restriction, ranges over *all* world histories (bounded included); typst `Logical Consequence` def (line 150): same, no totality restriction | **stale** everywhere — the precise clause the task description names as changed. Note also that the paper's quantifier order is "for all models $\M$" (which already packages a frame with it, per `def:BL-model`) with no separate `∀ F` — Lean's `∀ D F M` decomposition is a reasonable and harmless refinement (a model determines its frame), not itself a divergence |
| 26 | Validity (as a special case of consequence) | Same `def:logical-consequence`: "A sentence $\varphi$ is *valid* just in case $\vDash \varphi$" (i.e. $\emptyset \vDash \varphi$) | `valid` (`Validity.lean:79`) is defined **independently** of `SemanticConsequence` (own quantifier block, not `SemanticConsequence [] φ`); `valid_iff_empty_consequence` (`Validity.lean:331`) proves the two coincide, so no substantive divergence beyond the inherited `Omega`-vs-totality staleness above | latex/typst `Validity` defs both explicitly state validity as "$\varphi$ is a logical consequence of the empty set," i.e. the definitional route the paper itself uses — arguably *closer* to the paper's own phrasing than Lean's independently-restated version, modulo the shared `Omega`/totality staleness | **stale** (inherits row 25's staleness; the independent-vs-derived definitional strategy is not itself a divergence worth flagging) |
| 27 | Satisfiability | **No dedicated `\label`'d definition found** in the semantics apparatus (see Key Finding 6) — satisfiability appears only informally, as the dual of $\blacksquare$/validity (line 518) and in worked examples (lines 1390-1394) | `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable` (`Validity.lean:129`, `138`, `154`) — existential-witness definitions, structurally reasonable but with **no paper `\label` to check them against**; they inherit the `Omega`-vs-totality staleness of row 25 by construction (same `τ ∈ Omega` pattern) | latex `Satisfiability` def (line 157), typst `Satisfiability` def (line 158) — both give an existential-witness definition of their own, structurally parallel to Lean's, likewise with no paper `\label` anchor and likewise silent on totality | **no paper anchor to reconcile against** — flag rather than mark stale/absent; the existing Lean/prose definitions are self-consistent extrapolations from validity, not verified drift from a labeled source. Whatever `H_F`/totality fix lands for `valid`/`SemanticConsequence` should be applied here too for consistency, but that is a design decision, not a reconciliation finding |
| 28 | Soundness | `\label{def:soundness}`: "The proof system **TM** is *sound* with respect to the task semantics just in case for every sentence $\varphi$ and set of sentences $\Gamma$ in $\BL$, $\Gamma \vDash \varphi$ whenever $\Gamma \vdash \varphi$." | Not located in the three files this audit was scoped to (`TaskFrame.lean`, `WorldHistory.lean`, `Validity.lean`, `Truth.lean`); `Metalogic/Soundness.lean` exists and is out of this audit's file scope (per the task's KEY FILES list) but was grepped incidentally above for `[Nontrivial D]` binder usage — its soundness statement necessarily inherits whatever `SemanticConsequence` ends up meaning, so it is transitively affected but not independently audited here | Neither prose document states soundness as a labeled definition (both files stop at Monotonicity) | **out of audited scope** — noted for completeness, not verified in depth |

## Target Lean Signatures

These are proposed target signatures only — **not implemented anywhere in this dispatch**, per
the task's hard non-goal. They are meant to give downstream research/planning one unambiguous
target, and are deliberately written to flag open design choices rather than resolve them
silently.

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
  -- Lean cost is analyzed in the Coupling Analysis (§ below); the signature here is a proposal,
  -- not a settled design.
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
  -- new fields (matches the paper's own presentation, which defines "total" and "extends" as
  -- conditions on the base object rather than enriching the object itself)

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

The central structural consequence: **the current generic `Omega : Set (WorldHistory F)` +
`ShiftClosed Omega` + `τ ∈ Omega` pattern is replaced by quantification over the fixed total-history
set**, not by a further-constrained `Omega`. `ShiftClosed` becomes unnecessary as a hypothesis to
carry, because totality is trivially closed under `WorldHistory.timeShift`: shifting
`domain := fun z => σ.domain (z + Δ)` preserves "domain is always true" whenever `σ.domain` was
always true. This is a genuine simplification, not just a rename — the current
`(_ : ShiftClosed Omega)` hypothesis exists *because* `Omega` is otherwise unconstrained; once
`Omega` is pinned to "total histories," the hypothesis it was added to support is no longer needed
to state validity/consequence at all (it might still matter internally to metalogic proofs that
currently rely on being handed an arbitrary matching `Omega`, e.g. completeness — that is exactly
what deliverable 4 (per-task staleness) must assess for 415, out of this report's scope).

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

- **Subtype approach**: `τ : PossibleWorld F` (the `{τ // τ.IsTotal}` subtype) as a single binder,
  vs. **witness-pair approach** shown above (`τ : WorldHistory F` plus a separate `τ_total :
  τ.IsTotal` hypothesis). The subtype approach is more faithful to the paper's "$\tau \in H_{\F}$"
  phrasing as a single object; the witness-pair approach requires fewer changes to call sites that
  already destructure a bare `WorldHistory F`. Either is a routine transcription; this is a style
  choice for the implementer, not a semantic one.
- Whether `ShiftClosed`/`Omega` machinery is deleted outright or retained as a *generalization*
  that `valid`/`SemanticConsequence` specialize (e.g. keep `TruthAt` parametric in `Omega` for
  internal metalogic flexibility, but define `valid`/`SemanticConsequence` by instantiating
  `Omega := {τ | τ.IsTotal}` and proving it shift-closed once, as a lemma, rather than deleting the
  parameter) is exactly the kind of design decision deliverable 4's per-task staleness verdicts
  (specifically for 415, which currently depends on being handed an arbitrary matching `Omega` for
  its canonical-model construction) should settle, not this report.

## Coupling Analysis

**Question**: which frame axioms are load-bearing for the totality restriction — specifically, is
`thm:extension` (and hence `app:nonempty`, i.e. $H_{\F} \neq \emptyset$) derivable in Lean from the
four `def:frame` axioms as stated, and what does `Spherical` cost to state over a Lean `TaskFrame`?

**Answer: all four axioms are load-bearing, none can be dropped, and the dependency chain is
linear and fully traceable in the paper's own proofs** (re-read `lem:nullity`, `lem:segments`,
`thm:extension`, `thm:occurrence`, `app:nonempty` in full above):

1. `thm:extension`'s proof (`\label{thm:extension}`) directly cites three of the four axioms by
   name in its case split:
   - The "$A$ has a maximum, $C$ has a minimum" case uses the **right-to-left direction of
     Compositionality** (the biconditional's new half) to factor the transition through the gap
     point $z$.
   - The "otherwise" case, when both $A, C$ are nonempty, invokes **`lem:segments`**, whose own
     proof (re-read above) uses *both* directions of the biconditional Compositionality (the
     left-to-right direction for directedness, the right-to-left for nonemptiness) — so
     Compositionality's biconditional strength (not just the old lax inclusion) is genuinely used,
     not incidentally present.
   - The one-sided sub-cases (only $A$ or only $C$ nonempty) invoke **Seriality** directly
     ("every forward fiber is nonempty by *Seriality*") to establish nonemptiness of the one-sided
     fiber family before Spherical is applied.
   - **Spherical** itself is invoked in every branch of the "otherwise" case to extract the witness
     $u$ in the directed family's intersection — this is the one non-substitutable step; nothing
     else in `def:frame` produces an intersection witness.
   - The proof's closing step, establishing that the extended function is task-constrained at the
     new point $z$ itself, cites **`lem:nullity`** ("the instance at $z$ itself is the zero loop
     $u \Rightarrow_0 u$ of `\ref{lem:nullity}`") — and `lem:nullity` is *itself* proved from
     Seriality + Limit (or, per the paper's own over-determination remark, from Compositionality +
     Limit alone). So **Limit is load-bearing too, transitively, via `lem:nullity`**, even though
     `thm:extension`'s proof body never cites "Limit" by name directly.
   - The proof also uses **Zorn's lemma** (hence AC) to obtain the maximal task-constrained
     extension in the first place, independent of which frame axioms hold.

   Conclusion: **`thm:extension` depends on all four `def:frame` axioms** — Compositionality
   (biconditional form) and Spherical directly, Seriality directly (one-sided case) and
   indirectly (`lem:segments`' proof also leans on the biconditional, which in turn is what makes
   Seriality's fiber-nonemptiness argument line up with the segment case), and Limit indirectly
   via `lem:nullity` — plus the axiom of choice via Zorn.

2. `thm:occurrence` (`\label{thm:occurrence}`) is a two-line proof directly chaining
   `lem:nullity` (for the zero-loop witness) into `thm:extension` (to extend it to a total
   history), so it inherits `thm:extension`'s full four-axiom + AC dependency and adds nothing new.

3. `app:nonempty` (`\label{app:nonempty}`, the $H_{\F} \neq \emptyset$ result underwriting
   `def:frame-validity`'s "never vacuous" guarantee) is a direct corollary of `thm:occurrence`
   via a time-shift translation argument, so it too inherits the same dependency chain in full.

**Therefore: yes, `thm:extension` is derivable from the four axioms as stated** (this is a fact
about the paper's mathematics, verified by re-reading every step of its proof above, not an
assumption) — but "derivable" here means "derivable in ZFC, using Zorn's lemma," and the Lean
formalization cost is real and multi-layered, not a one-line consequence:

- **Not routine**: `Spherical` itself, because it must first be *stated* against `Seg`, which does
  not exist in the Lean tree at all today. Stating it requires (a) `Fib`/`Seg` as new definitions
  (shown above), (b) a `Set (Set WorldState)`-level quantification over families of segments
  (second-order relative to the base relation), and (c) a directedness predicate over that family.
  None of this is exotic Lean, but it is new *infrastructure*, not a one-line axiom the way
  `nullity_identity`/`forward_comp` currently are.
- **Not routine**: `thm:extension`'s own proof, independent of how `Spherical` is stated, because
  it requires (a) defining "task-constrained function on a subset of `D`" as its own predicate
  (distinct from `WorldHistory`, since the maximal element obtained by Zorn is a raw function on a
  subset before it is packaged back into a `WorldHistory`), (b) a `Preorder`/partial order by
  extension over that predicate's carrier type, (c) a chain-boundedness argument establishing that
  a chain's union is itself task-constrained (a real, nontrivial step — the paper's proof handles
  it in one sentence but it requires reasoning about the union of an arbitrary chain of partial
  functions), (d) applying a Mathlib Zorn variant (`zorn_le`/`zorn_nonempty_partialOrder` or
  similar) to that preorder, and (e) the full four-branch case analysis reconstructing the
  maximality contradiction. This is squarely a multi-lemma development, comparable in shape to (and
  reusing some of the mathematical engine behind) the ~85-line maximal-history prototype the task
  description points to for 414 — except targeting `IsTotal` rather than `IsMax`, per the task
  description's own note that the two predicates are not the same and only the *engine* (Preorder,
  chain-union argument, Zorn application) is reusable, not the target predicate itself.
- **Routine**: `Seriality` and the promoted `limit` field are both direct, first-order
  transcriptions with no new supporting machinery — `Seriality`'s Lean shape is a straightforward
  existential pair, and `limit`'s shape is *already written out* in the current `TaskFrame.lean`
  module docstring (lines 65-72) as the intended transcription for the old "Limit Nullity" name,
  needing only relabeling now that Nullity has been split off.
- **Routine, but requires deleting rather than weakening**: the biconditional `Compositionality`
  field itself is a routine transcription (an `↔` in place of the current one-directional `→`
  chain), but its *consequences* ripple into every existing proof site that currently uses
  `forward_comp`/`backward_comp` as one-directional facts — those call sites are unaffected in
  shape (the biconditional's forward direction still gives them what they had), but every site
  that might have relied on the *absence* of interpolation (none currently identified in this
  file-scoped audit, but not exhaustively checked outside `Semantics/`) would need re-examination.
  This is a downstream-impact concern for deliverable 4/Part B, not a transcription-cost concern.

**Summary judgment**: `Seriality` and `Limit` are cheap (first-order, no new infrastructure).
`Compositionality`'s biconditional is a cheap *field* edit with a potentially non-cheap
*downstream* footprint. `Spherical` is the one axiom whose Lean transcription is genuinely
non-routine, requiring new segment/fiber infrastructure before it can even be stated, and
`thm:extension`'s reconstruction (needed to make totality non-vacuous, i.e. to make `app:nonempty`
a theorem rather than an assumption) is a substantial, multi-lemma Zorn-based development in its
own right, independent of `Spherical`'s statement cost.

## Evidence

**Paper** (`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, read in full
across the relevant ranges on 2026-08-09): `\label{def:frame}`, `\label{def:task-topology}`,
`\label{lem:nullity}`, `\label{app:topology-t1}`, `\label{app:topology-r0}`,
`\label{def:world-history}`, `\label{app:gluing}`, `\label{lem:segments}`,
`\label{thm:extension}`, `\label{thm:occurrence}`, `\label{app:nonempty}`,
`\label{def:BL-model}`, `\label{def:BL-semantics}`, `\label{def:time-shift-histories}`,
`\label{app:auto_existence}`, `\label{lem:history-time-shift-preservation}`,
`\label{def:frame-properties}`, `\label{def:frame-validity}`, `\label{def:logical-consequence}`,
`\label{def:derivability}`, `\label{def:soundness}`. Body mirror confirmed at `sec:Construction`
(unlabeled def:frame restatement) and `\label{sub:WorldStates}`/`\label{sec:Construction}` region.

**Lean** (`/home/benjamin/Projects/BimodalLogic/`, re-read/re-grepped on 2026-08-09, not copied
from prior reports): `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame` (152),
`nullity_identity` (163), `forward_comp` (177), `converse` (191), `TaskFrame.nullity` (202),
`TaskFrame.backward_comp` (212), `TaskFrame.limit_nullity_of_succOrder` (261),
`TaskFrame.limit_nullity_of_shift` (289), `TaskFrame.exists_uniform_radius_of_finite` (340).
`FormalSystem/Semantics/WorldHistory.lean` — `WorldHistory` (75), `domain` (78), `convex` (88),
`states` (94), `respects_task` (103), `WorldHistory.timeShift` (246). `FormalSystem/Semantics/
TaskModel.lean` — `TaskModel` (49), `valuation` (56). `FormalSystem/Semantics/Truth.lean` —
`TruthAt` (128), atom case (130), box case (133), `ShiftClosed` (333). `FormalSystem/Semantics/
Validity.lean` — `valid` (79), `SemanticConsequence` (103), `satisfiable` (129), `SatisfiableAbs`
(138), `FormulaSatisfiable` (154), `valid_iff_empty_consequence` (331). Confirmed via `grep -rn`
(whole-tree, 2026-08-09): zero hits for `Seg`/`Fib`/`Segment`/`Fiber`/`Seriality`/`Spherical`/
`Occurrence` under `FormalSystem/Semantics/`; zero hits for `IsMax`/`isMax`/`maximal`/`Maximal`
under `FormalSystem/Semantics/`.

**Repo prose**: `latex/subfiles/02-Semantics.tex` (165 lines, read in full) — `def:frame` (its own
`\label{def:frame}` at line 31, a *repo-local* label distinct from the paper's own, both
coincidentally named `def:frame`), `World History` def (76), `Truth` def (98), `Logical
Consequence` def (148), `Validity` def (152), `Satisfiability` def (157). `typst/chapters/
02-semantics.typ` (169 lines, read in full) — `Task Frame` def (35), `World History` def (62),
`Truth` def (84), `Logical Consequence` def (149), `Validity` def (153), `Satisfiability` def
(158).

## Confidence Level

- **Reconciliation Table**: **high**. Every row is grounded in a direct `Read` of the cited paper
  range (with `\label` cross-checked against the file's own `\label{...}` grep output) and a
  direct `Read`/`grep` of the cited Lean/prose file on 2026-08-09; no row was carried over from
  the task description's own claims without independent re-verification, and two corrections to
  the task description's framing were found in the process (the `latex` document's Compositionality
  clause is stale in the *same direction* as Lean's, not independently stale in a different way;
  and there is no paper `\label` for satisfiability at all, so "reconcile Lean's satisfiability
  defs against the paper's satisfiability label" is not a well-formed instruction — flagged rather
  than silently worked around).
- **Target Lean Signatures**: **medium-high**. The `TaskFrame`/`WorldHistory` field-level
  transcriptions are direct, low-risk translations of verbatim paper text and are high confidence.
  The `TruthAt`/`valid`/`SemanticConsequence` binder-list redesign (dropping `Omega`/`ShiftClosed`
  in favor of total-history quantification) is a design proposal consistent with the paper and
  with the removal of genericity the totality restriction implies, but it is **not** the only
  defensible shape (see the two named alternatives), and its interaction with 415's canonical-model
  construction is explicitly flagged as unassessed here (deliverable-4 territory).
- **Coupling Analysis**: **high** on the "which axioms are load-bearing" question (this is a
  direct trace through the paper's own proof text, not an inference) and **medium** on the
  quantitative Lean-cost estimates (routine/non-routine judgments are based on comparing the
  required transcription shape against what already exists in the tree and against the general
  difficulty profile of Zorn-lemma developments in Lean/Mathlib, but no attempt was made to
  actually draft the Lean proof, per the task's hard non-goal against implementing anything).
