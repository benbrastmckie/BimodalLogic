# Research Report: Logical-Consequence Discrepancy Audit Against the Finalized Paper

- **Task**: 438 - reconcile_semantic_definitions_with_jpl_paper
- **Started**: 2026-08-10T15:27:33-07:00
- **Completed**: 2026-08-10T16:05:00-07:00
- **Effort**: ~1 hour (single-agent re-verification round)
- **Dependencies**: reports/01_team-research.md (the earlier team research this report re-verifies)
- **Sources/Inputs**:
  - Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (READ-ONLY;
    see "Paper snapshot" below — the file was edited live *during* this dispatch)
  - Paper git history: `git log` of the paper repo since 2026-08-08 (tasks 64, 65, 66 + uncommitted edits)
  - Lean: `FormalSystem/Semantics/TaskFrame.lean`, `WorldHistory.lean`, `Truth.lean`, `Validity.lean`
    (all read in full or in relevant part; `git log` confirms no commits to `FormalSystem/Semantics/`
    since 2026-07-28)
  - Prior artifacts: `reports/01_team-research.md`, `plans/01_reissue-paper-refactor-cluster.md`
  - Live `specs/state.json` re-query of the paper-refactor cluster
- **Artifacts**: this report (`reports/02_logical-consequence-discrepancy-audit.md`)
- **Standards**: report-format.md, status-markers.md, artifact-management.md

## Paper Snapshot (load-bearing for every quote below)

The paper is under **active edit during this dispatch**. Between two reads minutes apart, the file
went from 3968 to 3975 lines, `\label{def:frame}` moved from :2420 to :2427, and two new labeled
definitions (`def:temporal-order`, `def:directed`) appeared. All quotes below were taken from and
re-verified against this snapshot:

- Working tree of paper repo at HEAD `98b52b41` ("task 66: complete implementation",
  2026-08-10 14:57 -0700) **plus uncommitted edits**; file md5 `aa0488c1fe6134e59256803ae891a5f2`,
  3975 lines, read 2026-08-10T15:31 -0700.
- The uncommitted edits observed are: `%% CHANGE`/`%% OLD` comment pruning (139 → 121 markers), a
  cone-subscript typo fix (`|x| < y` → `|y| < x`), wording polish, removal of a justification
  sentence after the body consequence definition, and the mid-session split of the preliminary
  definitions into `def:temporal-order` / `def:task-relation` / `def:directed`. No *content* change
  to any axiom or to the consequence chain was observed within the session.
- Any bare line number below is a parenthetical locator for this snapshot only, never a citation.
  Labels are the only durable anchors, and even the label *inventory* changed mid-session.

## Executive Summary

- **The consequence chain itself is STABLE.** `def:logical-consequence`, `def:frame-validity`,
  `def:BL-semantics` (atom clause without the dom conjunct; `\Box` over `H_F`), and the
  totality/possible-world identification in `def:world-history` are all verbatim-unchanged in
  substance since the 2026-08-09 team research. The Lean target is unchanged: quantify
  `TruthAt`/`valid`/`SemanticConsequence` over **total world histories** (`H_F`), replacing the
  `Omega`/`ShiftClosed` parameterization.
- **The supporting machinery UNDER the consequence chain was refactored by the paper's tasks 64-66
  and live edits** (a third drift wave, exactly as report 01's recurrence-prevention section
  predicted): `lem:segments` is deleted and replaced by `lem:constraint` (Constraint Lemma) +
  `lem:step` (Step Lemma); `def:world-history` is restated with **partial history** primary
  (nonempty domain, *no* convexity) and world history = partial history with convex domain; the
  `\Seg(w,v;a,b)` notation is retired for brackets `[w,v]_x^y` (the `\Seg` macro itself is deleted);
  Spherical is restated over "any directed family of nonempty **fibers and segments**" (fibers no
  longer "count among" segments); `thm:extension` is restated for partial histories with its proof
  compressed to Zorn + Step Lemma; and the preliminaries now carry their own labels
  (`def:temporal-order`, `def:task-relation`, `def:directed`).
- **Report 01's conclusions survive; several of its quotes, anchors, and its proof-architecture
  trace are superseded.** The three-way audit below itemizes exactly which claims still hold,
  which are superseded, and two items the earlier research missed (Lean `WorldHistory` lacks the
  paper's nonempty-domain requirement; `valid`/`SemanticConsequence` already carry `[Nontrivial D]`).
- **The Lean tree is confirmed unchanged** since the team research (no commits to
  `FormalSystem/Semantics/` since 2026-07-28): still Omega-parameterized `TruthAt`/`valid`/
  `SemanticConsequence`, still the three-field `TaskFrame` (iff-Nullity axiom, lax `forward_comp`,
  `converse`), still no totality predicate, no extension order, no Fib/Seg/Seriality/Spherical.
- **Coupling verdict re-verified against the NEW proof architecture**: all four `def:frame` axioms
  remain load-bearing for `thm:extension` (hence for a nonempty `H_F`), but the map is now
  lemma-shaped: Compositionality (both directions) + Seriality + `lem:nullity` → `lem:constraint`;
  Spherical → `lem:step`; Zorn → `thm:extension`. This decomposition is *good news* for Lean: the
  paper now hands over exactly the lemma granularity a Lean development needs.
- **Plan-validity verdict: PARTIALLY VALID — revision required before implementation.** Plan 01's
  phase structure, renames, status decisions, dependency-edge fix, and banner scheme all stand.
  But Phases 3-4 compose the six re-issued descriptions from report 01's "must say" texts, and
  those texts now carry superseded machinery (Seg notation, `lem:segments`, the pre-restatement
  `def:world-history` wording, the old Spherical statement, the stale `:926` locator). The plan
  must be revised to source that content from THIS report where superseded. See the unambiguous
  verdict in Findings §4.

## Context & Scope

This dispatch re-verifies the earlier team research (report 01, 2026-08-09) against the current,
"more or less finalized" paper, with logical consequence as the primary tracking target. It is
research-only: no file under `FormalSystem/`, `latex/`, `typst/`, or the paper was modified; Part B
(cluster re-issue) was not performed. The only files written are this report and the task's
metadata/state bookkeeping.

## Findings

### 1. Discrepancy Audit — Three-Way List

#### (a) Claims from report 01 that STILL HOLD (each positively re-checked, not assumed)

| # | Claim (report 01) | Re-verification against current paper/tree |
|---|---|---|
| a1 | `def:frame` has exactly four axioms: Compositionality (biconditional), Seriality, Limit, Spherical; Nullity is NOT among them | Confirmed verbatim. `\label{def:frame}`: "*Compositionality:* $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$. *Seriality:* $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$. *Limit:* $\bigcap_{x > 0} (w)_x = \set{w}$. *Spherical:* $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments." (Seriality's wording is compressed relative to 01's quote; content identical, governed by the preamble "for positive durations $x, y \geq 0$".) |
| a2 | Nullity demoted to derived `lem:nullity`, proved choice-free from Seriality at $x=0$ + Limit; over-determination remark (Compositionality + Limit suffice) | Confirmed. `\label{lem:nullity}`: "$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame" with exactly that proof, and the over-determination remark now in live text after the proof. |
| a3 | Occurrence derived, not axiomatic; `thm:occurrence` from `lem:nullity` + `thm:extension`; ZFC/Zorn | Confirmed. `def:frame` closing remark: "No condition beyond these axioms on the primitive task relation is imposed: the *Occurrence* condition, formerly required of every frame, is derived in **thm:occurrence**..."; `thm:extension` footnote: "The proof appeals to Zorn's lemma and hence to the axiom of choice..." |
| a4 | Totality = possible world; `H_F` = set of all total world histories; extension order defined in `def:world-history` | Confirmed. `\label{def:world-history}`: "a world history is *total*--- equivalently, a *possible world*--- just in case $X = D$. A partial history $\sigma$ *extends* $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$. The set of all total world histories over $\F$ is denoted $H_{\F}$." (Note: extension is now defined on *partial* histories — see (b) below.) |
| a5 | **Logical consequence quantifies over possible worlds $\tau \in H_F$** | Confirmed verbatim, unchanged. `\label{def:logical-consequence}`: "A conclusion $\varphi$ is a *logical consequence* of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$. A sentence $\varphi$ is *valid* just in case $\vDash \varphi$." Body mirror agrees. |
| a6 | Box clause quantifies over $H_F$; atom clause has NO dom conjunct; Past/Future over all $y \in D$ | Confirmed verbatim. `\label{def:BL-semantics}`: "($p_i$) $\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in \vert{p_i}\vert$. ... ($\Box$) $\M,\tau,x \vDash \Box \varphi$ *iff* $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$." Preamble: "Truth in a model at a possible world $\tau \in H_{\F}$ and time is defined recursively". |
| a7 | Frame validity never vacuous, theorem-backed via `app:nonempty` | Confirmed. `\label{def:frame-validity}` + following text: "Since $H_{\F} \neq \emptyset$ for every frame by **app:nonempty**, frame validity is never vacuous... $\nvDash_{\F} \bot$ for every frame $\F$." |
| a8 | No labeled paper definition of satisfiability exists | Re-confirmed (no `def:` label; only informal mentions). Report 01's row-27 "N/A" ruling stands. |
| a9 | Lean current state: three-field `TaskFrame` (`nullity_identity` iff-axiom, lax `forward_comp` with `0 ≤ x`, `0 ≤ y`, `converse`); no `Nonempty WorldState` field; no `[Nontrivial D]` structure binder; no Limit/Seriality/Spherical/Fib/Seg | Confirmed by direct read of `TaskFrame.lean` (structure at :152, fields :163/:177/:191) and grep: zero hits for `Fib`/`Seg`/`Seriality`/`Spherical`/`Occurrence` under `FormalSystem/Semantics/`. No commits to `FormalSystem/Semantics/` since 2026-07-28. |
| a10 | Lean `WorldHistory`: `domain`/`convex`/`states`/`respects_task`; no totality predicate, no extension order | Confirmed by direct read (`WorldHistory.lean:75-104`). Repo-wide `IsTotal`/`.Extends`/`PossibleWorld` grep: zero semantic hits; `IsMax` hits are order-theoretic facts about `D` in Metalogic files, not history maximality. |
| a11 | Lean `TruthAt`/`valid`/`SemanticConsequence` are Omega-parameterized with `ShiftClosed` and `τ ∈ Omega` binders | Confirmed by direct read (`Truth.lean:128-137`; `Validity.lean:79-84` `valid`, `:103-109` `SemanticConsequence`, `:129-158` satisfiability family). Blast radius re-measured: `Omega` appears in **45 files** (unchanged; raw occurrence count is grep-method-dependent, ~1.2-1.3k), `ShiftClosed` in **32 files** (unchanged). |
| a12 | 420's three helper theorems survive verbatim (stated against a bare relation `R`) | Confirmed: `limit_nullity_of_succOrder` (:261), `limit_nullity_of_shift` (:289), `exists_uniform_radius_of_finite` (:340), all against bare `R : W → D → W → Prop`. |
| a13 | The 419 Spherical-risk finding (paper's own ℚ-flow worked non-example) | Confirmed — the non-example survives, now in partial-history vocabulary with an added forcing computation (see (b7) for the current verbatim text and its new location). The risk verdict for 419's Q-flow sketch stands in full force. |
| a14 | Cluster inventory and statuses | Re-queried live: exactly {414 researched, 415 researched, 417 researched, 419 not_started, 420 blocked deps [415, 438], 427 not_started} — matches report 01 and Plan 01 Phase 1's expectations. The dependency cycle (420 ↔ 415) is still present in state.json. |
| a15 | latex/ and typst/ prose staleness (different generations behind) | No commits touched `latex/` or `typst/` since 2026-08-08; both remain as report 01 audited them, now a further generation behind (partial-history restatement, notation changes). |
| a16 | Paper churn is the steady state; recurrence prevention needed | Vindicated *during this very dispatch*: paper tasks 64-66 landed after the team research, and the file changed under this agent mid-read (label inventory changed between two greps minutes apart). |

#### (b) Claims from report 01 now SUPERSEDED by the finalized text

| # | Report 01 said (old) | Paper now says (current verbatim) |
|---|---|---|
| b1 | **`lem:segments`** existed and was quoted: "If $h : A \cup C \to W$ is task-constrained where $t < z < s$..., then the segments $\Seg(h(t), h(s); z - t, s - z)$ ... form a $\supseteq$-directed family of nonempty segments." | **Deleted** (survives only as `%% OLD` comments). Replaced by `\label{lem:constraint}` (Constraint Lemma): "For any partial history $\tau : X \to W$ over a frame $\F$ and duration $z \in D \setminus X$, the *constraints imposed on $z$*--- the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t < z < s$ in $X$ if assignments flank $z$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise--- form a $\supseteq$-directed family of nonempty sets, where $\tau \cup \set{\tuple{z, u}}$ is a partial history just in case $u$ belongs to every member of the family." |
| b2 | (no counterpart) | **NEW `\label{lem:step}`** (Step Lemma): "Every partial history $\tau : X \to W$ over a frame $\F$ extends to a partial history on $X \cup \set{z}$ for any duration $z \in D$." Its proof is where Spherical is applied, and it closes: "Where the family has a $\subseteq$-least member--- as when nearest assignments flank $z$--- that member already contains a candidate and *Spherical* is not needed." |
| b3 | `def:world-history` quoted as: "A *world history* over a frame ... is a function $\tau : X \to W$ where $X \subseteq D$ is a nonempty convex set and $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$." | Restated with **partial history primary**: "A *partial history* over a frame $\F$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$. ... A *world history* is any partial history whose domain $X$ is *convex*..." The "task-constrained function" vocabulary is **retired everywhere** (thm:extension, thm:occurrence, app:gluing footnote all recast). |
| b4 | `thm:extension` quoted as: "every task-constrained function $h : S \to W$ on a nonempty $S \subseteq D$ is extended by some total world history"; report 01's Deliverable 3 traced its four-branch inline proof (max/min case, two-sided via lem:segments, one-sided fiber cases, closing admissibility check) | Restated: "Every partial history $\tau : X \to W$ over a frame $\F$ is extended by some total world history $\sigma \in H_{\F}$." Proof **compressed to Zorn + Step Lemma**: "By Zorn's lemma, there is a maximal partial history $\sigma : T \to W$ extending $\tau$. If $T \neq D$, then $\sigma$ extends ... by **lem:step**, contradicting maximality." The four-branch case analysis now lives in `lem:constraint`'s proof; the Spherical application lives in `lem:step`. Deliverable 3's *conclusion* survives (see Findings §3); its *proof-architecture trace* is superseded. |
| b5 | Spherical quoted as: "Every $\supseteq$-directed family of nonempty segments has a nonempty intersection, where a nonempty family of segments is *$\supseteq$-directed* just in case any two members include a common member of the family", with fibers "count[ing] among the segments as the cases in which one constraint is left vacuous" | Restated: "*Spherical:* $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty **fibers and segments**." Fibers are a separate class (the fibers-count-among-segments device is retired; the paper's `sigma-elim` change note: "Spherical now quantifies over families of fibers and segments alike"). Directedness is its own definition, `\label{def:directed}`: "A nonempty family of sets $\mathcal{S}$ is *directed* just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$." |
| b6 | Segment notation `\Seg(w, v; a, b)` with fibers included among segments; machinery defined inside `def:frame`'s header | Notation retired — the `\Seg` macro is **deleted** from the preamble ("segment notation unified on the bracket form"). Current: `\label{def:task-relation}` defines "*Fiber:* $\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}$. *Cone:* $(w)_x \coloneq \bigcup_{\vert{y} < x} \Fib(w, y)$ where $x > 0$. *Segment:* $[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$." The preliminaries now carry their own labels: `\label{def:temporal-order}` ("A *temporal order* is any nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ with *positive cone* $D^+ \coloneq \set{x \in D : x \geq 0}$"), `def:task-relation` (which also carries the converse convention "$w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x \geq 0$" and requires $W$ nonempty), and `def:directed`. **These labels appeared mid-session** — a plan quoting the label inventory should re-check it at execution time. |
| b7 | The ℚ non-example cited at locator `:926`, quoted with "the task-constrained function $\tau(t) = 1 - t$..." | Locator stale and wording updated. Current text (footnote to the world-history sentence in the `sec:Construction` body; anchor via `def:world-history`'s body counterpart — the footnote itself carries no label): "Convexity alone does not guarantee extendability: taking $D = \mathbb{Q}$ and $W = \set{q \in \mathbb{Q} : q > 0}$ with $r \Rightarrow_x r'$ *iff* $\vert{r' - r} \leq x$ yields a structure satisfying every axiom but *Spherical*, in which the **partial history** $\tau(t) = 1 - t$ defined for $0 < t < 1$ admits no value $u$ at the time $1$, **since $\vert{u - (1 - s)} \leq 1 - s$ for every $s < 1$ forces $u \leq 0$**, and so $\tau$ restricts no total world history. *Spherical* is exactly what excludes this structure." (Bolded portions are new relative to 01's quote.) |
| b8 | The "directed form is calibrated" warning cited at locator `:912-913` | Now lives in `def:frame`'s Spherical footnote, expanded: "The directed form is calibrated: past and future constraints may tighten at different rates, and over temporal orders admitting mismatched cofinalities the weaker chain form of the condition no longer supports the extension theorem of **thm:extension**~[Kubis2019], while the stronger finite-intersection form excludes frames whose world histories already extend to total ones." Same footnote also states the useful identity: "$w \Rightarrow_{x+y} v$ *iff* $[w, v]_x^y \neq \emptyset$" (the factoring direction of Compositionality restated segment-wise). |
| b9 | `app:gluing` proof "uses Compositionality (right-to-left) and the converse convention", routed through total extensions | Proof **rewritten** (the totals detour removed): now a direct argument composing through any $z$ in the overlap "using only Compositionality and the converse convention". The footnote's directed-gluing claim survives, recast: "gluing along a *directed* family of domains rests on *Spherical* rather than on composition alone: the union of a directed family of world histories agreeing on their overlaps is a partial history, and so restricts a total world history by **thm:extension**..." |
| b10 | Report 01's References section anchors (`def:frame :2412-2465`, `def:world-history :2570-2579`, `lem:segments :2611-2622`, etc.) | All parenthetical locators stale (labels moved ≥ 7 lines within this session alone); `lem:segments` no longer exists as a label. Only the `\label` names remain valid anchors, and the inventory now additionally contains `def:temporal-order`, `def:task-relation`, `def:directed`, `lem:constraint`, `lem:step`. |

#### (c) What the earlier research MISSED (present in the paper generation it audited too)

| # | Missed item | Detail |
|---|---|---|
| c1 | **Lean `WorldHistory` has no nonempty-domain requirement.** | The paper requires a partial history's domain to be a **nonempty** set (`def:world-history`: "on a nonempty set $X \subseteq D$"; the requirement was present, as "nonempty convex set", in the generation report 01 audited). Lean's `WorldHistory` (`WorldHistory.lean:75-104`) has `domain : D → Prop` with **no nonemptiness field** — the empty history is a legal Lean `WorldHistory` but is not a world history in the paper. Report 01's row 10 called the base definition a "**match**"; it is a match on four of five conjuncts. Impact: nil for the consequence chain (total histories have domain `D`, nonempty since a nontrivial group is), but real for `thm:extension` fidelity — the paper's theorem starts from a *nonempty* partial history, and a Lean transcription must either carry the nonemptiness field/hypothesis or handle the empty case separately (the empty function extends trivially via `thm:occurrence`-style seeding, but that is an argument the paper does not make and the transcription should not silently need). |
| c2 | **`valid`/`SemanticConsequence` already carry `[Nontrivial D]`.** | Report 01's Deliverable 2 presents `[Nontrivial D]` in the target binder lists as if new at every level. In fact `Validity.lean:80` and `:104` **already include `[Nontrivial D]`** in `valid` and `SemanticConsequence`. The genuine gap is only at the `TaskFrame` *structure* level (no `[Nontrivial D]` binder, no `Nonempty WorldState` field), exactly as row 2 of report 01's table said. Downstream implication: the consequence-level binder lists change less than Deliverable 2's presentation suggests — the delta there is precisely (i) drop `Omega`/`ShiftClosed`/`τ ∈ Omega`, (ii) add the totality constraint on `τ`. |
| c3 | (caveat, not an error) **Primitive-clause mismatch in the truth definition.** | Report 01's row 23 recorded "Past/Future clauses ... match" via `future_iff`/`past_iff`. Accurate in content, but worth stating plainly for the re-issued 414: Lean's `Formula` takes **Until/Since** (`untl`/`snce`) as primitive with G/H/F/P as derived abbreviations, mirroring the paper's extended language (`def:BLplus-semantics`), while `def:BL-semantics` has primitive `\Past`/`\Future` only. The totality refactor must rewrite the `untl`/`snce` clauses' binders too (they are `τ`-local and untouched in shape by the Omega excision, but they sit inside `TruthAt`'s binder list). |

### 2. Logical-Consequence Reconciliation (paper → Lean, the full chain)

The chain, clause by clause, against the current tree. Every Lean claim below was verified against
the working tree on 2026-08-10 (no `FormalSystem/Semantics/` commits since 2026-07-28).

| Paper (label) | Content (current) | Current Lean | Verdict |
|---|---|---|---|
| `def:temporal-order` | nontrivial totally ordered abelian group; positive cone $D^+$ | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`; `[Nontrivial D]` present on `valid`/`SemanticConsequence` (`Validity.lean:80,104`) but **absent from the `TaskFrame` structure binders** (`TaskFrame.lean:152`) | stale (structure binder) |
| `def:task-relation` | relation on $W \times D^+ \times W$, $W$ nonempty; converse convention; Fib/Cone/Segment | two-sided `TaskRel` + `converse` field (`TaskFrame.lean:156,191`) = the extended relation (match); **no `Nonempty WorldState`**; **no `Fib`/cone-as-object/`Seg` definitions anywhere** | partial: converse matches; carriers absent |
| `def:directed` | nonempty family $\mathcal{S}$ directed iff some member $\subseteq S_1 \cap S_2$ | absent | absent |
| `def:frame` — Compositionality | biconditional with existential witness | `forward_comp` = one-directional inclusion only (`TaskFrame.lean:177`); docstring still says the equality "is **not** adopted" (`:50-52,138-140`) — now backwards | stale |
| `def:frame` — Seriality | forward and backward fibers nonempty for every $x \geq 0$ | absent | absent |
| `def:frame` — Limit | $\bigcap_{x > 0} (w)_x = \set{w}$ | absent as a field; intended transcription + 3 bare-relation discharge helpers present (`TaskFrame.lean:69-72, 261, 289, 340`) | absent (field) |
| `def:frame` — Spherical | $\bigcap \mathcal{S} \neq \emptyset$ for directed families of nonempty fibers and segments | absent (and unstatable until Fib/Seg exist) | absent |
| (former axiom) Nullity | now derived `lem:nullity` (reflexivity only) | `nullity_identity` still an **axiom field**, and in the strictly stronger iff form (`TaskFrame.lean:163`) | stale (design question: demote vs. keep-as-strengthening — flagged, not settled) |
| `def:world-history` — partial history | function on **nonempty** $X \subseteq D$, respects task | `WorldHistory` bundles convexity; **no partial-history structure**; **no nonemptiness** (missed item c1) | absent/partial |
| `def:world-history` — world history | partial history with convex domain | `WorldHistory` fields match modulo the missing nonemptiness | match (4/5 conjuncts) |
| `def:world-history` — total / possible world / $H_F$ | $X = D$; $H_F$ = all total world histories | no totality predicate, no $H_F$ | absent |
| `def:world-history` — extension order | on partial histories: domain inclusion + agreement | absent | absent |
| `lem:constraint`, `lem:step`, `thm:extension`, `thm:occurrence`, `app:nonempty` | the machinery making totality-quantification non-vacuous | all absent; nearest prior art is 414's IsMax-targeted prototype (research artifacts only, not in tree) | absent |
| `def:BL-semantics` — atom | $\tau(x) \in \vert{p_i}\vert$, no dom conjunct | `Truth.lean:130`: `∃ (ht : τ.domain t), ...` — carries the existential dom proof | stale (falls out once totality lands) |
| `def:BL-semantics` — $\Box$ | for all $\sigma \in H_F$ | `Truth.lean:133`: `∀ σ, σ ∈ Omega → ...` | stale (the central divergence) |
| `def:BL-semantics` — tenses | all $y \in D$ | `Truth.lean:134-137` (via untl/snce primitives; see c3) | match |
| `def:frame-validity` | $\vDash_{\F}$; never vacuous via `app:nonempty` | no frame-relative validity predicate at all | absent |
| `def:logical-consequence` | over models, possible worlds $\tau \in H_F$, times $x \in D$; valid = $\emptyset \vDash$ | `SemanticConsequence`/`valid` quantify over `Omega`/`ShiftClosed`/`τ ∈ Omega` (`Validity.lean:79-109`) | stale (the tracked target) |
| satisfiability | no paper definition | `satisfiable`/`SatisfiableAbs`/`FormulaSatisfiable` (`Validity.lean:129-158`) | N/A — inherit the totality fix by design decision (report 01 Conflict 3 ruling stands) |

#### Target Lean signatures (the one unambiguous downstream target — DO NOT implement here)

These update report 01's Deliverable 2 to the finalized paper. Differences from Deliverable 2 are
flagged inline. Naming follows the paper's current vocabulary (partial history; fibers *and*
segments; `def:directed`).

```lean
-- ①  Fibers and segments (def:task-relation). Defined against a bare relation so 420's
--    helper-theorem pattern is preserved. Fib admits ANY duration (negative via converse);
--    segments carry the x, y ≥ 0 side conditions from the paper.
def Fib {W : Type} (R : W → D → W → Prop) (w : W) (x : D) : Set W := {u | R w x u}

/-- Segment `[w, v]_x^y := Fib(w, x) ∩ Fib(v, -y)`, `x, y ≥ 0` (def:task-relation). -/
def Seg {W : Type} (R : W → D → W → Prop) (w v : W) (x y : D) : Set W :=
  Fib R w x ∩ Fib R v (-y)

-- ②  Directedness (def:directed) — CHANGED from Deliverable 2's inline ⊇-directed condition:
--    now the paper's own standalone definition, "some member below any two".
def DirectedFamily {W : Type} (S : Set (Set W)) : Prop :=
  S.Nonempty ∧ ∀ s₁ ∈ S, ∀ s₂ ∈ S, ∃ s₃ ∈ S, s₃ ⊆ s₁ ∩ s₂

-- ③  TaskFrame (def:temporal-order + def:task-relation + def:frame).
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] where                       -- NEW binder (def:temporal-order)
  WorldState : Type
  world_nonempty : Nonempty WorldState          -- NEW field (def:task-relation)
  TaskRel : WorldState → D → WorldState → Prop
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w   -- UNCHANGED
  /-- Compositionality, biconditional (def:frame). -/
  compositionality : ∀ w v x y, 0 ≤ x → 0 ≤ y →
    (TaskRel w (x + y) v ↔ ∃ u, TaskRel w x u ∧ TaskRel u y v)
  /-- Seriality (def:frame). -/
  seriality : ∀ w x, 0 ≤ x → (∃ u, TaskRel w x u) ∧ (∃ v, TaskRel v x w)
  /-- Limit (def:frame), in the module docstring's established transcription. -/
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  /-- Spherical (def:frame) — CHANGED from Deliverable 2: the family ranges over
      FIBERS AND SEGMENTS as separate classes (no fibers-as-degenerate-segments device),
      and directedness is the def:directed condition. -/
  spherical : ∀ S : Set (Set WorldState),
    (∀ s ∈ S, (∃ w x, s = Fib TaskRel w x) ∨
              (∃ w v x y, 0 ≤ x ∧ 0 ≤ y ∧ s = Seg TaskRel w v x y)) →
    DirectedFamily S → (∀ s ∈ S, s.Nonempty) → (⋂₀ S).Nonempty

-- nullity_identity is REMOVED as a field; reflexivity is derived (lem:nullity):
theorem TaskFrame.nullity (F : TaskFrame D) (w : F.WorldState) : F.TaskRel w 0 w := ...
-- (whether Lean also keeps the iff-strengthening as a *derived* fact or drops the
--  injectivity-at-zero direction entirely remains the open design question from report 01;
--  the paper asserts only reflexivity)

-- ④  Histories (def:world-history). NEW relative to Deliverable 2: the paper's primary
--    object is the PARTIAL history (nonempty domain, NO convexity); WorldHistory is the
--    convex special case; nonemptiness is a required field (missed item c1).
structure PartialHistory (F : TaskFrame D) where
  domain : D → Prop
  nonempty : ∃ t, domain t                              -- paper: "on a nonempty set X ⊆ D"
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t), s ≤ t →
    F.TaskRel (states s hs) (t - s) (states t ht)
-- WorldHistory := PartialHistory + convexity (whether by `extends`, a mixin predicate
--    `IsConvex`, or keeping the existing standalone structure with a nonempty field added,
--    is an implementation-plan choice; the paper's layering is partial ⊃ world ⊃ total).

def PartialHistory.Extends (σ τ : PartialHistory F) : Prop :=          -- def:world-history
  (∀ x, τ.domain x → σ.domain x) ∧
    ∀ x (hτ : τ.domain x) (hσ : σ.domain x), τ.states x hτ = σ.states x hσ

def WorldHistory.IsTotal (τ : WorldHistory F) : Prop := ∀ x, τ.domain x
-- H_F, either as subtype or set — the subtype-vs-witness-pair choice from report 01
-- remains open and is a planning decision:
def PossibleWorld (F : TaskFrame D) : Type := {τ : WorldHistory F // τ.IsTotal}

-- ⑤  Truth and consequence (def:BL-semantics, def:logical-consequence). UNCHANGED from
--    Deliverable 2 in substance — re-affirmed against the current paper. Shown in the
--    witness-pair shape; the subtype shape is equally faithful.
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D) : Formula → Prop
  | Formula.atom p  => M.valuation (τ.states t (hτ t)) p       -- no dom existential
  | Formula.bot     => False
  | Formula.imp φ ψ => TruthAt M τ hτ t φ → TruthAt M τ hτ t ψ
  | Formula.box φ   => ∀ (σ : WorldHistory F) (hσ : σ.IsTotal), TruthAt M σ hσ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M τ hτ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ hτ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M τ hτ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ hτ r ψ

def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D),
    TruthAt M τ hτ t φ

def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ hτ t ψ) → TruthAt M τ hτ t φ
```

Notes carried forward unchanged from report 01 (re-affirmed): `ShiftClosed` becomes unnecessary in
the statement of validity/consequence (totality is trivially preserved by `timeShift`); whether the
Omega machinery is deleted or retained as a generalization that `valid` specializes is 415-coupled
and remains a planning decision; the `∀ D F M` decomposition vs. the paper's "for all models" is a
harmless refinement. New note: a **frame-relative validity** predicate (`def:frame-validity`'s
$\vDash_{\F}$) still has no Lean counterpart and is the natural home for the `app:nonempty`
never-vacuous theorem — worth naming in the re-issued 414 as an explicit optional deliverable.

### 3. Frame-Axiom Coupling (re-verified against the NEW proof architecture)

**Conclusion unchanged: all four `def:frame` axioms are load-bearing for `thm:extension` and hence
for a nonempty `H_F` and non-vacuous totality quantification.** What changed is the map from
axioms to proof sites — the paper now factors the argument into exactly the lemma granularity a
Lean development would want:

- **`lem:constraint`** consumes: Compositionality **right-to-left** (nonemptiness of each flanking
  segment), Compositionality **left-to-right** (directedness/nesting of the family), **Seriality**
  (nonemptiness of one-sided fibers, both temporal directions), and **`lem:nullity`** (the zero
  loop $u \Rightarrow_0 u$ in the admissibility check) — which itself rests on Seriality at 0 +
  **Limit** (or Compositionality + Limit, per the over-determination remark). So Limit remains
  load-bearing transitively, exactly as report 01 concluded.
- **`lem:step`** consumes: `lem:constraint` + **Spherical** (the sole intersection-witness step —
  still the one non-substitutable use). Its closing remark is new and Lean-relevant: when the
  constraint family has a $\subseteq$-least member (e.g. nearest assignments flank $z$), Spherical
  is not needed. Over a discrete order like $\mathbb{Z}$, any nonempty set of integers bounded
  above/below has a max/min, so the step extension is **Spherical-free over $\mathbb{Z}$** — a
  concrete strengthening of report 01's research lead for task 417 (the *axiom* must still be
  discharged for any frame instance; but the extension machinery over $\mathbb{Z}$ will not need to
  invoke it).
- **`thm:extension`** consumes: Zorn (AC) + `lem:step`, nothing else. The chain-union boundedness
  argument ("every chain among them is bounded above by its union, which restricts on any pair of
  times to a single member of the chain") is stated for partial histories.
- **`thm:occurrence`** = `lem:nullity` + `thm:extension`; **`app:nonempty`** = `thm:occurrence` +
  the translation argument. Unchanged.

**Transcription-cost update** (revising report 01's Deliverable 3 judgments):

- *Spherical*: still the one axiom that is non-routine to **state** — it needs `Fib`/`Seg`/
  `DirectedFamily` first — but its statement is now cleaner than the old fibers-as-segments
  version (no degenerate-case encoding; the family predicate is a plain disjunction).
- *`thm:extension`*: **cheaper than report 01 estimated**, because the paper now supplies the
  lemma decomposition (`lem:constraint` → `lem:step` → Zorn wrapper) that report 01 said the Lean
  side would have to invent. The Lean development should mirror it lemma-for-lemma per the
  literature-fidelity policy. The Zorn engine from 414's prototype (`Preorder` by extension,
  `chainSup`, `exists_maximal_extension`) remains reusable, now targeting `PartialHistory` with
  the final step "maximal ⇒ total" going through `lem:step` — this resolves cleanly what report
  01 could only describe as "maximal-to-total requires Seriality and Spherical."
- *Seriality, Limit*: unchanged — routine first-order fields.
- *Compositionality*: unchanged — routine field edit (`↔` with existential witness), non-cheap
  downstream footprint at existing `forward_comp` call sites.
- *New cost not in report 01*: the `PartialHistory`/`WorldHistory` layering (b3) plus the
  nonemptiness field (c1). Modest, but it touches the same `WorldHistory` structure 414 refactors,
  so it belongs in 414/420's re-issued scope — decide the layering once, before the consequence
  refactor, not after.
- *Cross-task acceptance criterion* (report 01, Conflict 7): stands verbatim, now sharper —
  Spherical's Lean statement must be literally the hypothesis **`lem:step`'s** proof consumes
  (not `thm:extension`'s directly, under the new architecture).

### 4. Plan-Validity Verdict (unambiguous)

**Verdict: `plans/01_reissue-paper-refactor-cluster.md` is PARTIALLY VALID and MUST BE REVISED
before `/implement 438` runs.** It is not valid as written; it is also not invalidated
wholesale.

**Valid as written (no change needed)**:
- Phase 1 (preflight, rename-cost grep) — expectations re-verified against live state.json this
  round: cluster = {414, 415, 417, 419, 420, 427}, statuses and edges exactly as the plan states,
  cycle still present.
- Phase 2 (renames: 414 → `refactor_semantics_to_total_history_validity`, 415 →
  `completeness_over_total_history_semantics`, 420 → `align_task_frame_with_positive_cone_axioms`)
  — the rename targets name totality and the four-axiom frame, both of which the finalized paper
  confirms.
- Phase 5 (SUPERSEDED banners), Phase 6 (drop `415` from `420.dependencies`; four-point
  acyclicity check), Phase 7 (final verification greps) — all unaffected by the paper's latest
  changes.
- All status decisions (414/415/417 → `not_started`; 419/427 stay `not_started`; 420 stays
  `blocked`) — the rationale (target predicate is totality, not `IsMax`) is *strengthened*, not
  weakened, by the current paper.

**Requires revision (Phases 3-4 content spec)** — these phases compose the six rewritten
descriptions "directly from Deliverable 4's 'Re-issued description must say' text with the report
open" (report 01). That content source is now partially superseded; composing from it verbatim
would write the *fourth* stale generation into the cluster specs. The revised plan must direct
Phases 3-4 to source the following items from THIS report (02), overriding report 01 where they
conflict:

1. **Anchor set** (all six descriptions): add `def:temporal-order`, `def:task-relation`,
   `def:directed`; replace every `lem:segments` reference with `lem:constraint` + `lem:step`;
   note that `thm:extension` is now stated for partial histories and proved via Zorn + Step
   Lemma. Purge all parenthetical line locators inherited from report 01 (`:2412`, `:2570`,
   `:926`, `:912-913`, `:949-960` are all stale at the current snapshot).
2. **Notation** (414, 415, 420, 427): segments are `[w, v]_x^y` (the `\Seg` macro is deleted from
   the paper); Spherical ranges over directed families of nonempty **fibers and segments** with
   directedness per `def:directed`; the fibers-count-among-segments device is retired.
3. **Vocabulary** (414, 415, 420, 427): "partial history" replaces "task-constrained function"
   throughout; world history = partial history with convex domain; partial histories require
   nonempty domains (and the Lean `WorldHistory` nonemptiness gap, item c1, joins 414/420's
   scope).
4. **419's quoted non-example** (Phase 4): quote the CURRENT footnote text given in (b7) above —
   partial-history wording plus the forcing computation — anchored as the footnote to the
   world-history definition in the `sec:Construction` body (no label exists on the footnote;
   `def:world-history` is the durable formal anchor). Do not quote report 01's version or cite
   `:926`.
5. **417's research lead** (Phase 3): strengthen with `lem:step`'s closing remark — over discrete
   orders the step extension has a $\subseteq$-least constraint member and is Spherical-free,
   while the Spherical *axiom* must still be discharged for the frame instance (the pigeonhole
   lead for finite $W$ stands separately).
6. **Cross-task acceptance criterion** (414/420 texts, Phases 3-4): re-point from
   "`thm:extension`'s proof" to "`lem:step`'s proof" as the consumer Spherical's statement must
   literally serve.
7. **Recurrence instruction** (all four re-run research tasks): the paper-git-log-first
   instruction should ALSO record the snapshot data this report pinned (HEAD `98b52b41` +
   uncommitted working tree, md5 `aa0488c1...`, 2026-08-10) as the "since" baseline, and warn
   that the file changes intra-day — a fourth drift wave before the cluster re-runs is likely
   (one occurred *during this dispatch*).

**Mechanism**: a plan revision (`/revise 438` producing plan v02), or an equivalent targeted
update of Phases 3-4's content-source instruction, is required. No phase added or removed; no
status/rename/edge decision changes. Downstream tooling should treat plan 01 as **not executable
as-is** solely on account of the Phases 3-4 content source.

## Decisions

- **Consequence target re-affirmed**: totality-based quantification (`τ ∈ H_F`, i.e.
  `τ.IsTotal`) is the confirmed, stable Lean target for `TruthAt`/`valid`/`SemanticConsequence`.
  Nothing in the paper's latest wave moved it.
- **Report 01 is superseded only where §1(b) says so**; its verdicts, staleness calls, status
  recommendations, and cycle resolution are re-affirmed. This report does not replace report 01 —
  it overlays it. Part B implementers must read both, with 02 winning conflicts.
- **Satisfiability ruling from report 01 (Conflict 3) stands**: no paper anchor exists; Lean's
  satisfiability family inherits the totality fix as a design decision, not a reconciliation
  finding.

## Recommendations

1. **Revise plan 01 → v02** per Findings §4 (the seven itemized content-source corrections for
   Phases 3-4). Everything else in the plan proceeds unchanged.
2. **Pin the paper snapshot in Part B's rewritten descriptions**: cite `\label`s only, plus the
   snapshot SHA/md5/date from this report's "Paper Snapshot" section as the verification
   baseline for the next research dispatches.
3. **Escalate the recurrence-prevention follow-up** (report 01's Option A+C: definitions-of-record
   file + `check-paper-definitions.sh`): three drift waves have now invalidated or partially
   invalidated task-438 artifacts, the third landing mid-dispatch. This is the highest-leverage
   `meta` follow-up in the cluster's orbit.
4. **Fold items c1 (WorldHistory nonemptiness) and the PartialHistory layering into 414/420's
   re-issued scopes** — they touch the same structures those tasks already refactor.
5. **Name the frame-relative validity gap** (`def:frame-validity`, `app:nonempty` as a theorem) in
   414's re-issued description as an explicit optional deliverable, so the never-vacuous guarantee
   has a Lean home when totality lands.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| The paper changes again before Part B or the cluster re-runs (observed cadence: intra-day) | Re-issued descriptions stale on arrival | Snapshot pinning (Recommendation 2) + paper-git-log-first instruction + recurrence-prevention meta task (Recommendation 3) |
| Part B implementer composes descriptions from report 01's Deliverable 4 verbatim | Fourth stale generation written into the specs | Plan revision (Recommendation 1) makes report 02 the overriding content source; Phase 7's superseded-vocabulary grep should ADD "task-constrained", "lem:segments", "Seg(" to its term list |
| The mid-session label split (`def:temporal-order`/`def:task-relation`/`def:directed`) is itself reverted or renamed by the author | Anchors in re-issued descriptions dangle | Descriptions should quote definition TEXT verbatim alongside each label, so a renamed label is detectable by text search; the definitions-of-record file automates this |
| The `[w,v]_x^y` bracket notation is hard to render in plain-text task descriptions | Ambiguous specs | Use the ASCII form `[w, v]_x^y` with the defining equation `Fib(w,x) ∩ Fib(v,-y)` spelled out once per description |

## Appendix

### Paper git activity since the team research (2026-08-09 → snapshot)

Commits touching `JPL/possible_worlds.tex`: task 64 (phases 1-4: "body O8 block and Spherical
footnote", "appendix mirror and gluing-footnote symbol fix"), task 65 (gloss closing), task 66
(phases 1-6: "Restate def:world-history with partial history primary", "Replace lem:segments with
the Constraint Lemma", "Step Lemma, compressed thm:extension, occurrence and gluing vocabulary",
"Unify segment notation outside the refactored block", "Lighten the body paragraph and downstream
flow", "Full-document consistency pass and build verification"), plus three untitled "update"
commits, plus uncommitted working-tree edits still accumulating at read time.

### Current label inventory for the semantic core (snapshot locators, informational only)

`def:BL-language` (:2405), `def:temporal-order` (:2409), `def:task-relation` (:2413),
`def:directed` (:2423), `def:frame` (:2427), `def:task-topology`, `lem:nullity`,
`app:topology-t1`, `app:topology-r0`, `def:world-history` (:2546), `app:gluing`,
`lem:constraint` (:2599), `lem:step` (:2617), `thm:extension` (:2630), `thm:occurrence`,
`app:nonempty`, `def:BL-model`, `def:BL-semantics` (:2690), `def:time-shift-histories`,
`def:frame-properties`, `def:frame-validity` (:2864), `def:logical-consequence` (:3350),
`def:derivability`, `def:soundness` (:3361). `lem:segments` **no longer exists**.

### Lean verification inventory (all confirmed 2026-08-10 against the working tree)

- `FormalSystem/Semantics/TaskFrame.lean`: `TaskFrame` (:152), `nullity_identity` (:163),
  `forward_comp` (:177), `converse` (:191), `nullity` (:202), `backward_comp` (:212),
  `limit_nullity_of_succOrder` (:261), `limit_nullity_of_shift` (:289),
  `exists_uniform_radius_of_finite` (:340); known-gaps docstring (:65-72); "not adopted"
  interpolation remarks (:50-52, :138-140, :173-174).
- `FormalSystem/Semantics/WorldHistory.lean`: `WorldHistory` (:75), fields (:78-104) — no
  nonemptiness, no totality, no extension order; `timeShift` (:246).
- `FormalSystem/Semantics/Truth.lean`: `TruthAt` (:128-137) — Omega-parameterized; atom
  existential (:130); box over `Omega` (:133).
- `FormalSystem/Semantics/Validity.lean`: `valid` (:79-84), `SemanticConsequence` (:103-109) —
  both with `[Nontrivial D]` + `Omega`/`ShiftClosed`/`τ ∈ Omega`; `satisfiable` (:129),
  `SatisfiableAbs` (:138), `FormulaSatisfiable` (:154).
- Greps: `Omega` in 45 files; `ShiftClosed` in 32 files; zero `Fib`/`Seg`/`Seriality`/
  `Spherical`/`Occurrence`/`IsTotal`/`Extends` hits under `FormalSystem/Semantics/`; `IsMax`
  hits confined to order facts about `D` in `Metalogic/` (not history maximality); the stale
  `possible_worlds.tex:3250` locator persists in `FormalSystem/Theorems/DedekindDerived.lean:359`
  and `FormalSystem/Syntax/Formula.lean:467` (419-relevant, out of this task's write scope).
- `git log` — last commit touching `FormalSystem/Semantics/`: 2026-07-28 (`236a973f1`).
