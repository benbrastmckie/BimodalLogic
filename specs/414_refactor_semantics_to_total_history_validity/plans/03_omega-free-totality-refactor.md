# Implementation Plan: Total-History Validity Refactor (Omega-Free Semantics Core)

- **Task**: 414 - refactor_semantics_to_total_history_validity
- **Status**: [IMPLEMENTING]
- **Effort**: 36 hours
- **Dependencies**: 420 (phase 10 only, and only for the one item marked out of scope below), 438, 439
- **Research Inputs**: `specs/414_refactor_semantics_to_total_history_validity/reports/03_total-history-validity-refactor.md` (round 3, authoritative); `reports/01_maximal-history-validity-refactor.md` and `reports/02_group-c-reconciliation.md` (superseded where round 3 corrects them; retained as history)
- **Artifacts**: plans/03_omega-free-totality-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Make totality-based validity THE validity of the repository and eliminate the `Omega` parameter
from the semantics core, so that `def:BL-semantics`'s box clause quantifies over `H_F` (the total
world histories of the frame) rather than over a designated shift-closed set. The work has three
strands that must interleave in a specific order: (a) build the `PartialHistory` layer and
transcribe the paper's extension-machinery chain lemma-for-lemma, in *hypothesis-parameterized*
form so it lands now rather than waiting on task 420's blocked phase 10; (b) make each live
`Omega` provably equal to its frame's `H_F`, which requires a genuine deterministic re-host of
`regionFrame` on the decidability side; (c) collapse the `Omega`/`ShiftClosed`/`τ ∈ Omega` triple
into a single `τ.IsTotal` hypothesis across the tree. Definition of done: one uniform Omega-free
API, no shims or parallel validity notions, every phase sorry-free and axiom-free with
`lake build` green, and `Spherical` demonstrably threaded through `lem:step`'s proof.

### Research Integration

The round-3 report is the authoritative input and is machine-verified against the live tree. Four
findings shape this plan directly:

1. **`lem:step` and the whole chain through `cor:occurrence` are statable and landable now**, in
   hypothesis form, using the `Fib` / `Seg` / `DirectedFamily` / `IsFiber` / `IsSegment` apparatus
   that task 420's phase 7 already landed. Only *frame-intrinsic* `cor:occurrence` is blocked.
2. **`ShiftClosed` is genuinely unnecessary and shift-preservation is strictly easier under
   totality** — `isTotal_timeShift` is `fun t => h (t + Δ)`, and the box case of
   `time_shift_preserves_truth` needs no `ShiftClosed` hypothesis at all.
3. **`multiFamOmegaGen D FamIdx = {σ | ∀ t, σ.domain t}` is provable and sorry-free** — the
   completeness side's Omega already *is* `H_F`, so its Omega-elimination is a rewrite.
4. **`regionOmega ⊊ H_F` strictly** — `regionFrame.TaskRel = fun s d s' => d = 0 → s = s'` admits
   arbitrary total junk histories, so totality fixes the empty-history problem but not the
   junk-history problem. The decidability side needs a real carrier re-host, not a rewrite.

### Prior Plan Reference

No prior plan exists for this task (`plans/` was empty at planning time). Task 420's
`plans/02_four-axiom-frame-alignment.md` was consulted for dependency state only: phases 1-9 are
`[COMPLETED]`, phase 10 is `[BLOCKED]`.

### Roadmap Alignment

No ROADMAP.md found; no roadmap phases scheduled.

## Charter/Report Reconciliation

The dispatch is explicit that where the round-3 report and the charter conflict, the report wins
on matters it machine-verified. Five conflicts are load-bearing here, and this plan resolves each
in the report's favour, stated openly rather than silently:

| Point | Charter (`state.json` description) | Round-3 report | This plan follows |
|---|---|---|---|
| Order machinery (`exists_maximal_extension`, `isMax_of_total`, `chainSup`, `timeShift_mono`) | §5 lists them under SURVIVES, phrasing that reads as "already in the tree" | §8.1: **0 grep matches repo-wide**, boneyards included; they exist only as a prototype inside report 01 | **Report.** Phase 5 *lands* them, ported from `WorldHistory` to `PartialHistory`. They are not assumed to exist. |
| Group C bucketing counts | §5 carries 88 dead / 16 live-portable / 8 live-unportable | §8.2: `ParametricCompleteness.lean` and `ParametricCanonical.lean` are **deleted**; the 8-declaration excision list was already discharged by task 415 | **Report.** The bucketing *concept* survives; the numbers are **CARRIED FORWARD UNVERIFIED and known stale**, and are never used to size a phase here. |
| Dependency on 420 | §9: "the four-axiom TaskFrame must land first so the validity refactor lands once" | §2/§3: only frame-intrinsic `cor:occurrence` is gated on 420 phase 10; everything else is independently landable, verified by compilation | **Report.** Phases 6-10 land the chain in hypothesis form now. Frame-intrinsic `cor:occurrence` is an explicit non-goal. |
| §7 cross-task acceptance criterion | §7 reads as a criterion to be checked once 420 lands `Spherical` | §2: landing `Spherical` here as a hypothesis that `step`'s proof genuinely consumes is *safer*, and forecloses 420's inert-field failure mode | **Report.** Phase 9 discharges §7 rather than deferring it; see "The §7 mechanism" below. |
| `untl`/`snce` clause shape | §2: "τ-local and unchanged in shape", mirroring `def:BLplus-semantics` | §6.2: the paper's `def:BLplus-semantics` footnote describes the repo **backwards** (guard-first); `Formula.lean:85-90` and `Truth.lean:134-135` are event-first, and `Axiom.dense_indicator` plus `K⁺` depend on the event-first reading | **Report.** The Lean convention is **not** flipped. The divergence is recorded and escalated (Phase 2). |

## The §7 mechanism (how the cross-task criterion is satisfied, not deferred)

Charter §7 requires that *Spherical*'s Lean statement be literally the hypothesis `lem:step`'s
proof consumes — not an inert structure field. This plan discharges it as follows:

- Phase 6 introduces `Spherical`, `Serial`, and `Interpolates` as `Prop`-valued predicates over a
  bare task relation, built on 420 phase 7's landed apparatus.
- Phase 9 proves `lem:step` **consuming `hSph : Spherical F.TaskRel` in its proof body**, at the
  sole application site the paper names.
- **Invariant a future 420 phase-10 implementer MUST preserve**: when phase 10 adds the axiom
  fields, `TaskFrame.spherical` must be *definitionally* `Spherical TaskRel`, `TaskFrame.serial`
  definitionally `Serial TaskRel`, and the interpolation half of Compositionality definitionally
  `Interpolates TaskRel`, all as defined by this task. Phase 10 then discharges `step`'s
  hypotheses by `F.spherical` / `F.serial` / `F.interpolates` — a mechanical substitution with
  zero restatement. **If phase 10 lands a field whose statement differs, `step` stops
  typechecking.** That compilation failure *is* the acceptance test; it is why landing the
  hypothesis form first is safer than waiting. Phase 2 writes this invariant into 420's plan.

## Decisions made at plan time (each made ONCE)

These are recorded here and written to a durable decision record in Phase 2, so that neither this
task nor task 420 makes any of them a second time.

### Decision A — `H_F` encoding (charter §3, joint with task 420)

**Hybrid, as the round-3 report §5 recommends.**

- **Predicate-hypothesis form** — `(τ : WorldHistory F) (hτ : τ.IsTotal)` — in `TruthAt`, `valid`,
  `SemanticConsequence`, the satisfiable family, and the four variant validity predicates. This is
  exactly the charter's own "two moves" delta and keeps the diff at its stated size.
- **Subtype form** — `def TaskFrame.HF (F : TaskFrame D) : Type := {τ : WorldHistory F // τ.IsTotal}` —
  only where `H_F` appears as an object in its own right: `thm:extension`'s conclusion,
  `cor:occurrence`, and the optional `⊨_F`.

**Why this is not a §9 violation.** §9 forbids compatibility shims, aliases, and *parallel
validity notions*. There is exactly one validity predicate here. `HF` is a bundled name for the
same `IsTotal` predicate, bridged only by `.val` / `.property`; no second `valid`, no alias, no
alternate box clause. The paper uses a name for this set (`H_F`), and giving it one where it is
quantified over as an object is fidelity, not duplication.

### Decision B — `PartialHistory` layering (charter §3, decided BEFORE the consequence refactor)

**`WorldHistory extends PartialHistory`, with `PartialHistory` carrying the unconditional
task-respect condition.**

```lean
structure PartialHistory (F : TaskFrame D) where
  domain : D → Prop
  nonempty_domain : ∃ t, domain t
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)

structure WorldHistory (F : TaskFrame D) extends PartialHistory F where
  convex : ∀ s t u, domain s → domain u → s ≤ t → t ≤ u → domain t
```

Three sub-decisions inside this, each with its reason:

1. **Nonemptiness is a field, not a side hypothesis.** `def:world-history` requires a nonempty
   domain for a *partial* history; carrying it as data is what makes `thm:extension`'s hypothesis
   a faithful transcription rather than an empty-case argument the paper never makes.
2. **`respects_task` is stated unconditionally** (`for all times x, y in X`, no `s ≤ t` guard), per
   the report §5 nuance: this is what `lem:fibers` and `lem:admissible` consume, both stated with
   no sign proviso. The existing guarded form is *derived* as `respects_task_le`, and a smart
   constructor `PartialHistory.ofLe` lets an existing site keep its guarded proof — the
   unconditional form follows from the guarded form plus `TaskFrame.converse`. A proof-convenience
   constructor is not a §9 shim: it introduces no second history type, no second validity, and no
   alias of any API surface.
3. **`extends` rather than a standalone structure or an `IsConvex` mixin.** Lean 4's flat field
   syntax means every existing `WorldHistory ... where` block keeps its shape and gains exactly one
   line (`nonempty_domain := ...`). The migration cost is bounded by the construction-site count,
   which is small (see Phase 4's Scope Hypothesis).

### Decision C — Omega: delete outright, in this task, without spawning

The round-3 report §7.5 leaves this open three ways and names it the highest-value item to settle
before phase sequencing. **Recommendation: delete Omega outright, and do the `regionFrame`
deterministic re-host inside this task (Phases 12-13). Do not spawn, and do not generalize.**

Rationale, in the order the alternatives fail:

- **Retain-as-generalization is out.** It violates §9's "one uniform Omega-free API" directly, and
  it leaves live exactly the hedge the paper's own `cor:tm-completeness` footnote describes —
  which landing this task is supposed to make obsolete.
- **The report's split-scope option, as the report frames it (land the Omega-free API here, spawn
  the `regionFrame` re-host as a follow-up), is not executable.** Verified during planning:
  `Bridge/DenseTruth.lean`, `Bridge/RegionLabel.lean`, `Bridge/IntTruth.lean`,
  `Bridge/TruthLemma.lean`, and `Bridge/Omega.lean` all call the **core** `TruthAt` with
  `regionOmega` as its `Omega` argument (e.g. `TruthAt (normModel b ord f) (regionOmega f) …`).
  Retargeting `TruthAt`'s box clause therefore breaks the decidability bridge *immediately* — and
  not merely syntactically: with `regionFrame`'s permissive `TaskRel`, `H_F` is the full function
  space, so `truthAt_box_iff_region`'s reduction to `∀ w y, …` becomes false. There is no green
  intermediate state in which the core API is Omega-free and `regionOmega` still functions. A
  follow-up split would leave the tree red between two tasks.
- **Doing the re-host here is templated, not novel.** Task 415 already made exactly this move on
  the completeness side: `multiFamTaskFrameGen` is deterministic-shift, so `multiFamGen_total_eq`
  holds and `multiFamOmegaGen` *is* `H_F`. Phase 12 applies the same pattern to `regionFrame`.

**Contingency, with precise ownership.** If Phase 12 or Phase 13's Scope Hypothesis fails at
implementation time — i.e. the re-host is materially larger than sized — spawn one task owning
**exactly**: `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean` (the `regionFrame`
definition, `regionHistory`, `regionOmega`, and their five declarations) plus the consumer repairs
in `Bridge/Valuation.lean`, `Bridge/IntTruth.lean`, `Bridge/DenseTruth.lean`,
`Bridge/TruthLemma.lean`, `Bridge/RegionLabel.lean`, and whatever in
`Decidability/Verified/Decidable.lean` those break — **entirely within the current Omega
architecture**, delivering `regionOmega_eq_total` as its acceptance criterion. That task changes
no API and is green standalone; this task's Phase 14 then blocks on it. The spawned task owns the
*prerequisite*, never the follow-up — that ordering is what keeps the tree green and §9 intact.

### Decision D — the Omega collapse is ordered reverse-topologically, not atomically

Removing an `Omega` binder from a declaration breaks every declaration that mentions it. The
sweeps (Phases 19-22) therefore proceed in **reverse dependency order**: a declaration may drop
its `Omega` binder only once every declaration that mentions it has already dropped its own.
Leaves first (`Tests/**`, `Examples/**`, `Automation/**`, `FrameConditions/**`), then
`Decidability/**`, then the canonical/algebraic completeness stack, and `Semantics/Truth.lean`'s
own parameter absolutely last. Each sweep therefore ends green rather than relying on one
tree-wide atomic edit that would exceed a single agent run.

## Definition anchors used (cite by `\label`, with verbatim text)

Every anchor below is quoted from `specs/paper-definitions-of-record.md`, which is what specs in
this repository cite — never the paper directly, and never by a bare `possible_worlds.tex:NNNN`
locator. The mandated lint was run at planning time: `bash scripts/check-paper-definitions.sh`
reported **case (b) — notice, all 23 recorded definitions unchanged, pass**.

| Anchor | Verbatim text (abridged where noted) |
|---|---|
| `def:world-history` | `A \textit{partial history} over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$. … A \textit{world history} is any partial history whose domain $X$ is \textit{convex} … A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$. … The set of all total world histories over $\F$ is denoted $H_{\F}$.` |
| `def:BL-semantics` (box) | `\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.` |
| `def:BL-semantics` (atom) | `\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in \vert p_i\vert$.` |
| `def:logical-consequence` | `A conclusion $\varphi$ is a \textit{logical consequence} of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, … A sentence $\varphi$ is \textit{valid} just in case $\vDash \varphi$.` |
| `def:frame#Compositionality` | `\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` |
| `def:frame#Seriality` | `\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` |
| `def:frame#Limit` | `\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.` |
| `def:frame#Spherical` | `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.` |
| `def:directed` | `A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.` |
| `def:task-relation` (Segment) | `\item[\it Segment:] $[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$.` |
| `lem:nullity` | `$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$.` |
| `def:constraints` | for a partial history `$\tau : X \to W$` and duration `$z \in D \setminus X$`, the constraints imposed on `$z$` are the segments `$[\tau(t), \tau(s)]_{z-t}^{s-z}$` for `$t < z < s$`, and the fibers `$\Fib(\tau(t), z-t)$` for `$t \in X$` otherwise. |
| `lem:constraint` | `… the constraints imposed on $z$ form a directed family of nonempty sets.` |
| `lem:fibers` | `… a world state $u \in W$ belongs to every member of the constraints imposed on $z$ just in case $\tau(t) \Rightarrow_{z-t} u$ for every $t \in X$.` |
| `lem:admissible` | `… the function $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs to every member of the constraints imposed on $z$.` |
| `lem:step` | `Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration $z \in D$.` |
| `thm:extension` | `Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some total world history $\sigma \in H_{\F}$.` |
| `cor:occurrence` | `For any frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$.` |
| `def:frame-validity` | `A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a frame} $\F$ … if and only if $\M,\tau,x \vDash \varphi$ for every model $\M$ …, possible world $\tau \in H_{\F}$, and time $x \in D$.` |
| `def:BLplus-semantics` | **NOT IN RECORD at plan time.** Phase 1 adds it. Until Phase 1 lands, no phase may cite it. |

**Notation (binding).** Any explicit converse operation on the task relation is written
`⇒^{-1}` (and `R^{-1}` for abstract relations) — never the relation-algebra breve or smile. New
Lean declarations introduced by this task use `inv` / `^-1` vocabulary, consistent with Mathlib's
`Inv`. Segments are written `[w, v]_x^y` with `[w, v]_x^y := Fib(w, x) ∩ Fib(v, -y)` for
`x, y ≥ 0`; the retired function-application segment notation must not appear. Renaming the
existing `TaskFrame.converse` field is **out of scope** — it is not an explicit converse operation
but the statement of the converse convention, and renaming it would be gratuitous churn.

## Goals & Non-Goals

**Goals**:
- Totality (`IsTotal τ := ∀ t, τ.domain t`) is the target predicate for `TruthAt`'s box clause,
  `valid`, `SemanticConsequence`, the satisfiable family, and `H_F` — never Mathlib's `IsMax` or
  any order-theoretic maximality predicate.
- One uniform Omega-free API: `Omega`, `ShiftClosed`, and every `τ ∈ Omega` hypothesis are gone
  from live code (boneyards excluded).
- The paper's extension chain transcribed lemma-for-lemma: `def:constraints` → `lem:constraint` →
  `lem:fibers` → `lem:admissible` → `lem:step` → Zorn wrapper → `thm:extension`.
- `Spherical` demonstrably consumed by `lem:step`'s proof (charter §7), with the 420-phase-10
  invariant recorded in both plans.
- `specs/paper-definitions-of-record.md` extended with `def:BLplus-semantics` before anything
  cites it.
- Every phase ends sorry-free, axiom-free, with `lake build` green.

**Non-Goals**:
- **Frame-intrinsic `cor:occurrence` is OUT OF SCOPE.** It requires *Seriality* and *Spherical* as
  `TaskFrame` structure data plus a `Nonempty WorldState` field to produce the seed world state.
  Those arrive only with **task 420 phase 10 ("Add the four axiom fields and discharge all 16 live
  sites"), which is `[BLOCKED]`** in `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`.
  This plan lands the hypothesis-parameterized form only; the frame-intrinsic corollary is a
  one-line consequence once that gate clears.
- No edits under `/home/benjamin/Philosophy/Papers/` — the paper is read-only ground truth.
- No compatibility shims, aliases, or parallel validity notions in the delivered API.
- **Do not flip the Lean `untl`/`snce` argument order.** The repository is event-first
  (`Formula.lean:85-90`, `Truth.lean:134-135`) and is internally consistent and load-bearing on
  that convention; the paper's `def:BLplus-semantics` footnote misdescribes it. Editing the paper
  is a charter non-goal, so this plan records and escalates rather than resolves.
- No re-derivation of the Group C 88/16/8 counts. They are stale and are not used to size any
  phase.
- Charter §8 (frame-relative validity `⊨_F`) is **OPTIONAL** — Phase 23, explicitly marked, safe
  to skip.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `regionFrame` re-host is materially larger than sized (Phases 12-13) | H | M | Declared Scope Hypotheses on both phases; named spawn contingency with exact file ownership (Decision C). Keep the five `Bridge/Omega.lean` interface lemma *statements* stable so consumers see no change. |
| The Omega-binder sweep breaks green-ness mid-phase | H | M | Decision D's reverse-topological ordering: each sweep owns a set closed under "callers of", so each ends green. Sweep D (Phase 22) is the only atomic-batch terminus. |
| `WorldHistory extends PartialHistory` churns more construction sites than expected | M | L | Phase 4 Scope Hypothesis pins the site count and the confirmation command; Lean 4 flat field syntax means each site gains one line. `PartialHistory.ofLe` keeps existing guarded `respects_task` proofs usable. |
| `ZOmegaV2` / `multiFamOmega` behave like `regionOmega` rather than `multiFamOmegaGen` | M | M | Phase 11 classifies both **before** any collapse phase runs, so a second re-host is discovered at sizing time, not mid-implementation. |
| 420 phase 10 later lands `Spherical` with a different statement | H | L | The §7 mechanism above makes this a compilation failure, not a silent divergence; Phase 2 writes the invariant into 420's plan. |
| `lem:step`'s Zorn/Spherical proof is harder than the paper's decomposition suggests | M | M | Charter §6 records that the paper now supplies the decomposition round 1 said Lean would have to invent; Phases 7-9 mirror it lemma-for-lemma so each step is small. The report verified the *statements* typecheck; the bodies were not attempted and are the genuine unknown. |
| Atom-clause fidelity gap (`∃ (ht : τ.domain t)` vs `$\tau(x) \in \vert p_i\vert$`) | L | H | Accepted and documented: harmless for total `τ` (the `∃` is trivially inhabited) and required for `TruthAt` to stay total on arbitrary `WorldHistory F` under Decision A's predicate form. Recorded in Phase 2's decision record. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 11, 12 | -- |
| 2 | 4, 5, 6, 13 | 3, 12 |
| 3 | 7 | 6 |
| 4 | 8 | 7 |
| 5 | 9 | 8 |
| 6 | 10 | 5, 9 |
| 7 | 14 | 4, 11, 13 |
| 8 | 15, 16, 17, 18 | 14 |
| 9 | 19 | 15, 18 |
| 10 | 20 | 17, 19 |
| 11 | 21 | 16, 20 |
| 12 | 22 | 21 |
| 13 | 23 | 22 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extend the definitions of record with `def:BLplus-semantics` [COMPLETED]

**Goal**: Make `def:BLplus-semantics` a tracked, drift-linted anchor so that later phases citing
it are grounded. At plan time `grep -c BLplus specs/paper-definitions-of-record.md` returns 0
while the anchor exists in the live paper, so per charter §10's own rule any spec citing it today
is ungrounded and unprotected by the lint.

**Tasks**:
- [x] Run `bash scripts/check-paper-definitions.sh` and confirm case (a) or (b). Stop on case (c).
      *(completed — case (b): paper checksum moved to `f07441eb…`, all 23 recorded definitions unchanged, exit 0)*
- [x] Run `bash scripts/check-paper-definitions.sh --resolve "def:BLplus-semantics|env|-|-"` to
      print the resolved text and its sha256. *(completed — sha256 `3f56a996…`)*
- [x] Add a `### \`def:BLplus-semantics\`` entry to `specs/paper-definitions-of-record.md` quoting
      that text verbatim (including any `%%` editorial comments inside the block).
      *(completed — extracted byte-faithfully, verified by re-hashing the extracted text to the
      script's own sha256; the block carries no `%%` comments)*
- [x] Attempt the same for `def:BLplus-language` and `def:BLplus-defined`; add them if they
      resolve. If either does not resolve, record it as a gap in the entry prose rather than
      fabricating one. *(completed — both resolved cleanly; no gap recorded)*
- [x] Add one manifest row per added anchor to the `MANIFEST:BEGIN`/`MANIFEST:END` fenced block,
      columns `anchor_id|kind|enclosing|locator|sha256`. *(completed — 3 rows; manifest 23 → 26)*
- [x] Re-run `bash scripts/check-paper-definitions.sh` with no arguments and confirm the quiet
      case-(a) pass. *(completed — required re-pinning `FILE_CHECKSUM`/`LINE_COUNT`/`PINNED_COMMIT`
      to the live paper state the new hashes were derived from, following the record's own
      established coverage-extension re-pin practice; exits 0 silently)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 1 anchor is required (`def:BLplus-semantics`) and up to 2 more are
plausible (`def:BLplus-language`, `def:BLplus-defined`), taking the record from 23 to between 24
and 26 tracked definitions. Confirm at implementation time by the `--resolve` exit status per
anchor and by the post-edit no-argument lint reporting a clean pass; if a sibling anchor does not
resolve, record the gap rather than inventing an entry.

**Files to modify**:
- `specs/paper-definitions-of-record.md` — new entries plus manifest rows

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits 0 with a case-(a) quiet pass. **PASSED** (silent, exit 0).
- `grep -c BLplus specs/paper-definitions-of-record.md` returns a nonzero count. **PASSED** (25).
- The manifest row count matches the prose entry count. **PASSED with a recorded caveat**: the
  manifest carries 26 rows against 21 `### \`anchor\`` prose headings, because four
  `def:frame#…` item anchors are recorded inside the single `def:frame` entry and `CO`/`TMP-CO`
  share one worked-example heading. This 26-vs-21 relationship is pre-existing (it held before
  this phase at 23-vs-18) and is not introduced here; the invariant this phase actually
  preserved is **3 rows added, 3 prose entries added**.

**Outcome**: record extended from 23 to 26 tracked definitions
(`def:BLplus-language` `a43b3df2…`, `def:BLplus-semantics` `3f56a996…`, `def:BLplus-defined`
`2ac6361a…`). The `def:BLplus-semantics` entry carries an argument-order caveat recording that the
paper's footnote describes the repo's `snce`/`untl` constructors as guard-first while the Lean tree
is event-first — verified in-tree against `Formula.lean:83-90` (`untl`/`snce` docstrings naming the
first argument the event) and `Truth.lean:134-137` (both clauses witness the *first* argument at the
existential time and quantify the *second* over the open interval).

---

### Phase 2: Decision record and cross-task handoff [COMPLETED]

**Goal**: Write the plan-time decisions to a durable record so neither this task nor task 420
makes any of them twice, and escalate the `untl`/`snce` contradiction to the user.

**Tasks**:
- [x] Create `specs/decisions/total-history-validity-decisions.md` recording Decisions A-D above
      verbatim, each with its rationale and its §9 justification. *(completed)*
- [x] Record the accepted atom-clause fidelity gap (`∃ (ht : τ.domain t)` retained under the
      predicate encoding; literal only under the subtype encoding) as a known, reasoned deviation.
      *(completed — Decision A subsection "Accepted fidelity gap")*
- [x] Record the **420 phase-10 invariant** (see "The §7 mechanism" above) in the decision record.
      *(completed — section "THE INVARIANT")*
- [x] Append a cross-reference note to
      `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`
      under phase 10, stating that the four axiom fields must be definitionally the Props this task
      defines, and naming the compilation failure as the acceptance test. *(completed — inserted
      directly under phase 10's Goal, above the `[BLOCKED]` mechanism note, and explicitly
      subordinating the pre-existing per-axiom target table's `Spherical`/`serial` rows to this
      task's Props)*
- [x] Write an escalation record `specs/decisions/untl-snce-argument-order.md`: quote the live
      `def:BLplus-semantics` footnote (marked **UNVERIFIED-BY-RECORD** until Phase 1 lands, then
      cite the record), quote `Formula.lean:85-90` and `Truth.lean:134-135`, name
      `Axiom.dense_indicator` (`Validity.lean:229-231`) and `K⁺` (`Formula.lean:164-166`) as the
      two load-bearing dependents of the event-first reading, and state the decision requested of
      the user: correct the paper's footnote, or accept the divergence as documented. State
      explicitly that the Lean convention is **not** being changed either way.
      *(completed, with two corrections to the plan's own framing — see the deviation note below:
      Phase 1 landed first, so the footnote is cited **against the record** rather than marked
      UNVERIFIED-BY-RECORD; and the dependent list is **four**, not two — `someFuture`
      (`Formula.lean:131`) and `somePast` (`Formula.lean:141`) are equally load-bearing and were
      found during verification)*
- [x] Surface the escalation in the implementation summary so it reaches the user, not only the
      file. *(completed — carried in the dispatch wrap-up)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `specs/decisions/total-history-validity-decisions.md` (new)
- `specs/decisions/untl-snce-argument-order.md` (new)
- `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`

**Verification**:
- Both decision files exist and are non-empty. **PASSED**.
- 420's plan contains the invariant note under phase 10. **PASSED**.
- No Lean file is modified by this phase. **PASSED** (the phase's diff touches only `specs/**`).

**Deviations from the plan's task text** (both are corrections in the direction of accuracy):
1. The plan told this phase to mark the footnote **UNVERIFIED-BY-RECORD**. Phase 1 landed first in
   the same dispatch, so `def:BLplus-semantics` is a tracked anchor with a pinned sha256; the
   escalation cites the record, as the plan's own fallback clause directs.
2. The plan named **two** load-bearing dependents of the event-first reading
   (`Axiom.dense_indicator`, `K⁺`). Verification in-tree found **four**: `someFuture`
   (`Formula.lean:131`, `untl φ ⊤`) and `somePast` (`Formula.lean:141`, `snce φ ⊤`) also invert
   their meaning under a guard-first reading, becoming `K⁺`-shaped rather than `F`/`P`. All four
   are tabulated in the escalation record. `kMinus` (`Formula.lean:193`) is noted as carrying the
   same dependency as `kPlus`.

**Additional finding worth carrying forward.** The paper's footnote is an accurate description of
**the paper's own** infix notation — corroborated inside the paper by `def:BLplus-defined`'s
`$\past\varphi \coloneq \top\since\varphi$` — and its only error is **attributing that
convention to this repository's constructors**. The divergence is therefore purely notational: every
paper formula has a Lean counterpart obtained by swapping the two arguments. This is a narrower and
more tractable finding than "the paper is wrong", and it is what makes option (B) (accept the
divergence as documented) a reasonable outcome rather than a capitulation.

---

### Phase 3: `PartialHistory` module [COMPLETED]

**Goal**: Land the `PartialHistory` layer as new, self-contained material (Decision B), with the
extension order and the totality predicate, without yet touching `WorldHistory`.

**Tasks**:
- [x] Create `FormalSystem/Semantics/PartialHistory.lean` with `structure PartialHistory` exactly
      as in Decision B (`domain`, `nonempty_domain`, `states`, unconditional `respects_task`),
      docstring citing `def:world-history` with its verbatim text. *(completed)*
- [x] Add `PartialHistory.respects_task_le` — the guarded form, derived. *(completed)*
- [x] Add `PartialHistory.ofLe` — smart constructor taking a guarded proof, discharging the
      unconditional field via `TaskFrame.converse`. Docstring must state it is a proof-convenience
      constructor, not a compatibility shim. *(completed — proof is `le_total` split, then
      `F.converse … |>.mp` plus `neg_sub`)*
- [x] Add `PartialHistory.IsTotal (τ) : Prop := ∀ t : D, τ.domain t`, citing `def:world-history`'s
      totality clause verbatim. *(completed — docstring also records the standing constraint that
      this is never Mathlib's `IsMax`)*
- [x] Add `PartialHistory.Extends σ τ : Prop` — domain inclusion plus state agreement on the
      smaller domain, citing `def:world-history`'s extension clause. *(completed — landed as a
      `structure … : Prop` with fields `subset`/`agree`, so `agree` can refer to `subset`'s
      coercion directly; this avoids an `∃`-over-a-proof encoding that later phases would have to
      destructure at every use)*
- [x] Add `PartialHistory.total_nonempty` — totality implies the nonemptiness field is derivable
      (witness `0 : D`). *(completed — plus `nonempty_of_total`, the standalone form over a bare
      domain predicate, which is the one usable at a **construction** site where the structure
      does not yet exist; the τ-level form alone cannot discharge a `nonempty_domain` field)*
- [x] Register the new module in the appropriate import aggregator. *(completed —
      `FormalSystem/Semantics.lean`, imported after `TaskFrame` and before `WorldHistory`, with a
      submodule-list entry)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean` (new)
- the `FormalSystem/Semantics` import aggregator — confirmed to be `FormalSystem/Semantics.lean`

**Verification**:
- `lake build` green; the new module compiles sorry-free. **PASSED** (2325 jobs, exit 0; no
  `sorry`/`admit`/`axiom` token in the file).
- `#print axioms` on each new declaration shows no additional axioms beyond the Mathlib baseline.
  **PASSED** — `respects_task_le`, `ofLe`, `total_nonempty`, and `nonempty_of_total` each depend
  on `[propext]` only. No `Classical.choice`, no `sorryAx`.
- No existing file's behavior changes (nothing imports the new module yet). **PASSED** — the only
  edit outside the new file is the aggregator import line and its submodule-list entry.

---

### Phase 4: Re-base `WorldHistory` onto `PartialHistory` [COMPLETED]

**Goal**: Make `WorldHistory` the convex special case of `PartialHistory`, per `def:world-history`
("A *world history* is any partial history whose domain X is *convex*"), so the paper's layering
holds in Lean.

**Tasks**:
- [x] Change `structure WorldHistory (F) extends PartialHistory F` keeping only `convex` as its own
      field; remove the duplicated `domain` / `states` / guarded `respects_task` fields. *(completed)*
- [x] Add `nonempty_domain := …` at every `WorldHistory … where` construction site; for sites with
      `domain := fun _ => True` this is `⟨0, trivial⟩`. *(completed at all 11 sites. Inside
      `namespace WorldHistory` the term must be spelled `⟨0, True.intro⟩` — the local
      `WorldHistory.trivial` history shadows the `trivial` tactic/term and the elaborator picks the
      history, giving a `Type` vs `Prop` mismatch. Outside that namespace `⟨0, trivial⟩` is fine.)*
- [x] For `WorldHistory.timeShift` (`domain := fun z => σ.domain (z + Δ)`) derive nonemptiness from
      `σ.nonempty_domain`. *(completed — witness `t - Δ`, closed by `sub_add_cancel`)*
- [x] Convert each site's guarded `respects_task` proof via `PartialHistory.ofLe` where it is not
      already unconditional. *(completed — **`ofLe` was needed at zero sites**: all 11 existing
      proofs ignore their `s ≤ t` argument, so each converted by deleting one binder. The single
      site that consumed the guard, `timeShift`, consumed it only to build the *shifted*
      inequality needed to invoke `σ.respects_task`; that invocation is now unconditional too, so
      the proof got shorter rather than longer. `ofLe` remains landed API for future sites — the
      one-point extension construction in a later phase is its intended consumer.)*
- [x] Add `WorldHistory.IsTotal` (delegating to the `PartialHistory` field) and
      `isTotal_timeShift : IsTotal σ → IsTotal (σ.timeShift Δ)`, whose proof is
      `fun t => h (t + Δ)` — machine-verified as a one-liner by the round-3 report. *(completed —
      landed verbatim as `fun t => h (t + Δ)`; also added `isTotal_iff` (`Iff.rfl`) and
      `WorldHistory.total_nonempty`)*
- [x] Add `def TaskFrame.HF (F : TaskFrame D) : Type := {τ : WorldHistory F // τ.IsTotal}` per
      Decision A, docstring citing `def:world-history`'s `H_F` sentence verbatim. *(completed —
      universe-polymorphic as `Type _`, since `WorldState` is `Type*`)*
- [x] Add `TaskFrame.HF.timeShift` lifted through `isTotal_timeShift`. *(completed, plus a
      `@[simp]` projection lemma `timeShift_val`)*

**Timing**: 2.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: approximately 11 `WorldHistory … where` construction sites require a
`nonempty_domain` line — `FlowFrame.lean:150`, `ReynoldsBridge.lean:461` and `:684`,
`Bridge/Omega.lean:181`, `WorldHistory.lean:165`/`:184`/`:205`/`:226`/`:270`, and
`Examples/TemporalStructures.lean:138`/`:216`. (`Bridge/Interpolate.lean:441`'s `RegionConstant` is
a `Prop` structure *about* a history, not a construction site.) Confirm at implementation time
with `grep -rn "WorldHistory .*where$" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard`
and by the build error list after the structure change; if the count differs, record the actual
set before proceeding.

**Files to modify**:
- `FormalSystem/Semantics/WorldHistory.lean`
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean`
- `FormalSystem/Examples/TemporalStructures.lean`

**Verification**:
- `lake build` green, sorry-free, axiom-free. **PASSED** (2325 jobs, exit 0). Every new
  declaration (`IsTotal`, `isTotal_timeShift`, `total_nonempty`, `TaskFrame.HF`,
  `TaskFrame.HF.timeShift`) depends on `[propext]` only. The live tree carries exactly one
  `sorry`, at `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1085`; it is **pre-existing and
  untouched** (present at `HEAD` before this dispatch, in a file this phase does not modify), not
  introduced here.
- `isTotal_timeShift` typechecks with the one-line proof. **PASSED** — landed exactly as
  `fun t => h (t + Δ)`, no coercion or `simp` needed, because the shifted domain at `t` *is* the
  original domain at `t + Δ` definitionally.
- Every prior `WorldHistory` consumer still compiles unchanged (flat field syntax preserved).
  **PASSED for field-syntax sites; 5 non-field-syntax sites needed repair**, all mechanical and
  all recorded here rather than absorbed silently:
  - 4 `change WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _` sites (`FlowFrame.lean` ×2,
    `ReynoldsBridge.lean` ×2). `WorldHistory.mk` now takes 2 arguments (`toPartialHistory`,
    `convex`), so each became
    `change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ = WorldHistory.mk (PartialHistory.mk _ _ _ _) _`
    with the following `congr 1` promoted to `congr 2` (one extra layer to descend).
  - 2 `obtain ⟨d, c, s, t⟩ := σ` destructurings (`Omega.lean`'s `worldHistory_ext`,
    `FlowFrame.lean`'s `multiFamGen_total_eq`) became nested: `⟨⟨d, n, s, t⟩, c⟩`.
  - 2 consuming call sites of the guarded `respects_task` (`FlowFrame.lean:311,314`) dropped their
    `≤` argument; the surrounding `rcases le_total 0 t` became vacuous and its binders were
    renamed to `_h0t | _ht0` rather than deleting the split.

**Scope Hypothesis — CONFIRMED exactly.** `grep -rn "WorldHistory .*where$" --include=*.lean
FormalSystem/ Tests/ | grep -v Boneyard` returns the predicted 11 construction sites and no
others: `FlowFrame.lean:150`, `ReynoldsBridge.lean:461`/`:684`, `Bridge/Omega.lean:181`,
`WorldHistory.lean` ×5 (`universal`, `trivial`, `universalTrivialFrame`, `universalNatFrame`,
`timeShift`), `TemporalStructures.lean:138`/`:216`. `Bridge/Interpolate.lean:441`'s
`RegionConstant` was correctly predicted to be a `Prop` structure *about* a history, not a
construction site. 10 of the 11 have `domain := fun _ => True`; the exception is `timeShift`, as
predicted.

---

### Phase 5: Order machinery on `PartialHistory` (Zorn prototype port) [COMPLETED]

**Goal**: Land the extension-order machinery. Per the round-3 report §8.1 this material is **not
in the tree** — `exists_maximal_extension`, `isMax_of_total`, `chainSup`, and `timeShift_mono`
have zero grep matches repo-wide including boneyards, existing only as a verified prototype inside
report 01. It must be landed here, and **ported** from `WorldHistory` to `PartialHistory`, not
copied.

**Tasks**:
- [x] Instantiate `Preorder (PartialHistory F)` from `PartialHistory.Extends` (reflexive,
      transitive), or provide the two lemmas directly if the instance causes elaboration trouble.
      *(completed — the instance elaborates cleanly with `le τ σ := Extends σ τ`. One
      proof-engineering consequence worth recording: because the head symbol of `τ ≤ σ` is
      `LE.le`, dot notation `h.subset` on an order hypothesis resolves to Mathlib's deprecated
      `LE.le.subset` (a set lemma) rather than `Extends.subset`. Every use outside the instance
      body therefore goes through the `le_def : τ ≤ σ ↔ Extends σ τ := Iff.rfl` bridge as
      `(le_def.mp h).subset`. This is a naming collision, not a defeq problem.)*
- [x] Port `timeShift_mono` — the extension order is preserved by time shift. *(completed)*
- [x] Port the shift/unshift lemma pair. *(completed — `le_timeShift_timeShift_neg` and
      `timeShift_timeShift_neg_le`, on top of `timeShift_timeShift_neg_domain_iff` and
      `timeShift_timeShift_neg_states`)*
- [x] Port `chainSup` — the chain union of partial histories is a partial history (domain union,
      states by choice of a chain member, `respects_task` from the chain's directedness,
      `nonempty_domain` from any member). *(completed — see the nonemptiness note below)*
- [x] Port `exists_maximal_extension` — Zorn's lemma over `PartialHistory` ordered by extension,
      closed via `chainSup`. Note in the docstring that this is an **internal lemma en route to
      `thm:extension`**, demoted from round 1's "target existence theorem" per charter §5.
      *(completed, docstring note included, via `zorn_le_nonempty_Ici₀`)*
- [x] Port `isMax_of_total` — total implies maximal under the extension order. Docstring: this is
      the load-bearing direction per charter §5. *(completed, docstring note included)*

**Two porting consequences of the `PartialHistory` layer, recorded rather than absorbed silently**
(neither is a skipped, altered, or deferred plan step — both are supporting material the listed
tasks require, which the round-1 `WorldHistory` prototype did not need):

1. **`chainSup` takes the chain's nonemptiness as an explicit argument.** In the prototype,
   `WorldHistory` had no `nonempty_domain` field, so the union of the *empty* chain was a legal
   history. `PartialHistory` carries nonemptiness as data (Decision B), so the empty chain's union
   is not a partial history at all. `zorn_le_nonempty_Ici₀`'s upper-bound obligation supplies
   `∀ y ∈ c` precisely, so the extra argument costs nothing at the only call site.
2. **`PartialHistory.timeShift` had to be defined here.** The prototype's `timeShift_mono` and
   shift/unshift pair are stated about `WorldHistory.timeShift`; porting them to `PartialHistory`
   requires the operation to exist at that layer. It is landed alongside, with
   `timeShift_domain` (`Iff.rfl`) and the transport lemma `states_eq_of_time_eq` that any
   dependent `states` rewrite needs.

`isMax_timeShift` and `le_timeShift_timeShift_of_neg` from the round-1 prototype are **not**
ported: neither appears in this phase's task list, and neither is reachable from the
`exists_maximal_extension` + Step Lemma route to `thm:extension`.

**Timing**: 2.5 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/PartialHistoryOrder.lean` (new) — the sibling option was taken, to keep
  the `Mathlib.Order.Zorn` import off `PartialHistory.lean` and therefore off `WorldHistory.lean`
- `FormalSystem/Semantics.lean` — aggregator import

**Verification**:
- `lake build` green, sorry-free. **PASSED** (2326 jobs, exit 0).
- `#print axioms exists_maximal_extension` shows `Classical.choice` (Zorn) and nothing unexpected.
  **PASSED** — `[propext, Classical.choice, Quot.sound]`, the standard Mathlib baseline, and the
  same triple for `chainSup`/`le_chainSup` (which use `Classical.choose`). Everything that does
  **not** go through Zorn or choice — `isMax_of_total`, `timeShift_mono`, and both halves of the
  shift/unshift pair — is `[propext]` only.
- `grep -rn "exists_maximal_extension\|isMax_of_total\|chainSup\|timeShift_mono" --include=*.lean FormalSystem/`
  now returns matches (it returned none before this phase). **PASSED** — 18 matches, all in
  `PartialHistoryOrder.lean`, confirming the round-3 report's finding that this material was
  genuinely absent from the tree rather than merely un-located.

---

### Phase 6: Frame-axiom Props in hypothesis form, and `def:constraints` [COMPLETED]

**Goal**: State *Spherical*, *Seriality*, and Compositionality's interpolation half as `Prop`s over
a bare task relation, using the `Fib` / `Seg` / `DirectedFamily` / `IsFiber` / `IsSegment`
apparatus task 420's phase 7 already landed; and transcribe `def:constraints`. These typecheck
against the live tree (round-3 report §2, verified by `lean_run_code`).

**Tasks**:
- [x] `def Spherical {W} (R : W → D → W → Prop) : Prop` — `∀ S : Set (Set W), DirectedFamily S →
      (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty`. Docstring cites
      `def:frame#Spherical` verbatim, and notes that fibers and segments are two **separate**
      classes (the retired device by which one-sided fibers counted among segments must not
      reappear), with directedness its own definition per `def:directed`. *(completed — landed as
      `TaskFrame.Spherical`, statement exactly as specified)*
- [x] `def Serial {W} (R : W → D → W → Prop) : Prop` — `∀ (w : W) (x : D), 0 ≤ x →
      (∃ u, R w x u) ∧ (∃ v, R v x w)`. Docstring cites `def:frame#Seriality` verbatim.
      *(completed — `TaskFrame.Serial`)*
- [x] `def Interpolates {W} (R : W → D → W → Prop) : Prop` — `∀ w v x y, 0 ≤ x → 0 ≤ y →
      R w (x + y) v → ∃ u, R w x u ∧ R u y v`. Docstring cites `def:frame#Compositionality`
      verbatim and states that the `←` half is the existing `TaskFrame.forward_comp` field, so the
      biconditional is `forward_comp ∧ Interpolates`. *(completed — `TaskFrame.Interpolates`)*
- [x] `theorem nullity_of_serial_limit` — `lem:nullity` (`w ⇒₀ w`) derived from *Seriality* at
      `x = 0` plus *Limit*, in hypothesis form, choice-free. Docstring: Nullity is DERIVED, not an
      axiom. *(completed — choice-freeness machine-checked, see Verification below)*
- [x] `def Constraints (τ : PartialHistory F) (z : D) : Set (Set F.WorldState)` — the segments
      `[τ(t), τ(s)]_{z-t}^{s-z}` for `t, s ∈ dom τ` with `t < z < s`, and the fibers
      `Fib(τ(t), z - t)` for `t ∈ dom τ` otherwise. Docstring cites `def:constraints` verbatim and
      writes segments in the bracket form only. *(completed — `PartialHistory.Constraints`; see
      the "otherwise" note below)*
- [x] Record in the module docstring that these are hypothesis-form Props today and become
      `TaskFrame` fields when the four-axiom frame alignment lands, with the invariant from
      "The §7 mechanism" restated. *(completed — the module docstring's "Why hypothesis form"
      section carries the invariant and cites the durable decision record
      `specs/decisions/total-history-validity-decisions.md` rather than a task number, per
      `.claude/rules/no-task-references-in-deliverables.md`)*

**Two transcription decisions this phase had to make, recorded rather than absorbed silently**
(neither is a skipped, altered, or deferred plan step — both are forced readings the listed tasks
did not pin down):

1. **`def:constraints`'s "otherwise" is transcribed per-time, as `¬ PartialHistory.IsPaired τ z t`.**
   The paper's clause — fibers "for $t \in X$ otherwise" — does not say what `t` is otherwise
   *to*. The reading taken is: `t` contributes a fiber exactly when it is not half of a
   sandwiching pair, since when it is, the constraint it imposes is already carried by a segment
   (`[τ(t), τ(s)]_{z-t}^{s-z}` is definitionally the intersection of the fiber conditions at `t`
   and at `s`). `IsPaired` is landed as a named definition so Phases 7-8 consume one fixed
   reading rather than re-deciding. Recorded observation, noted in its docstring but not needed
   this phase: the condition collapses globally — if `dom τ` has times on both sides of `z` then
   every `t` is paired and the family is all segments; if `dom τ` lies entirely on one side then
   no `t` is paired and the family is all fibers.
2. **`Limit` is deliberately NOT given a name.** It is not in this phase's task list, and the one
   place it is needed (`nullity_of_serial_limit`) takes it as a hypothesis in the literal
   transcribed shape `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` — which is exactly
   the *conclusion* of the two existing discharge helpers `TaskFrame.limit_of_succOrder` and
   `TaskFrame.limit_of_shift`, so either can be passed directly with no unfolding. Naming it
   would have introduced a fourth predicate the plan did not authorize and would have put a
   definitional barrier between the axiom and its two existing discharge routes.

Three small supporting lemmas are landed alongside `Constraints`, since Phase 7's directedness
and nonemptiness proofs cannot address the family without them: `mem_Constraints` (the
`Iff.rfl` unfolding), `isSegment_of_mem_Constraints_left` (the segment clause meets
`IsSegment`'s `x, y ≥ 0` proviso, because `t < z < s`), and
`isFiber_or_isSegment_of_mem_Constraints` (every member is a fiber **or** a segment — the exact
disjunction *Spherical* ranges over, with the two classes kept separate).

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/FrameAxioms.lean` (new) — the sibling-file option was taken, keeping
  `TaskFrame.lean` untouched
- `FormalSystem/Semantics.lean` — aggregator import and submodule docstring entry

**Verification**:
- `lake build` green, sorry-free. **PASSED** — full-project `lake build` exit 0 (2327 jobs);
  `grep -c sorry FormalSystem/Semantics/FrameAxioms.lean` returns 0.
- Each Prop's statement is quotable side-by-side with its `\label` anchor's verbatim text.
  **PASSED** — every definition's docstring carries a "Recorded source (`anchor`, verbatim)"
  line quoting `specs/paper-definitions-of-record.md`: `Spherical` ← `def:frame#Spherical`,
  `Serial` ← `def:frame#Seriality`, `Interpolates` ← `def:frame#Compositionality`,
  `nullity_of_serial_limit` ← `lem:nullity`, `Constraints` ← `def:constraints`, with
  `def:directed` and `def:frame#Limit` quoted in the module docstring.
- No `TaskFrame` structure field is added or changed by this phase. **PASSED** —
  `TaskFrame.lean` is not in this phase's diff at all.
- Additional check, since the plan calls `lem:nullity` choice-free:
  `#print axioms TaskFrame.nullity_of_serial_limit` reports `[propext]` only — no
  `Classical.choice`, matching the paper's contrast between the choice-free zero loops and the
  Zorn-dependent Extension Theorem.

---

### Phase 7: `lem:constraint` — the constraint family is directed and nonempty [COMPLETED]

**Goal**: Prove the Constraint Lemma in its **restructured** form: directedness plus nonemptiness
only. The admissibility clause its earlier merged statement carried is split out into
`lem:admissible` (Phase 8) and must not be folded back in here.

**Tasks**:
- [x] State `theorem constraint (F) (hSer : Serial F.TaskRel) (hInt : Interpolates F.TaskRel)
      (τ : PartialHistory F) (z : D) : DirectedFamily (Constraints τ z) ∧ ∀ s ∈ Constraints τ z, s.Nonempty`,
      docstring citing `lem:constraint` verbatim. *(completed — `PartialHistory.constraint`,
      statement exactly as specified, `lem:constraint` quoted verbatim from
      `specs/paper-definitions-of-record.md`)*
- [x] Prove nonemptiness of each fiber from *Seriality*. *(completed —
      `nonempty_fib_of_serial`: successor half of *Seriality* at `z - t ≥ 0` when `t ≤ z`,
      predecessor half at `t - z ≥ 0` plus the converse convention when `t ≥ z`)*
- [x] Prove nonemptiness of each segment from *Seriality* plus Compositionality. *(completed —
      `nonempty_seg_of_interpolates`; see the recorded reading below: the segment case needs the
      interpolation half of Compositionality and does **not** additionally need *Seriality*)*
- [x] Prove directedness per `def:directed`: for any two members, exhibit a member contained in
      their intersection. The proof consumes Compositionality in **both** directions —
      `TaskFrame.forward_comp` for the composition half and `hInt` for the interpolation half.
      *(completed — `exists_mem_subset_inter`, over the two fiber-monotonicity lemmas
      `fib_subset_fib_of_le_of_le` / `fib_subset_fib_of_le_of_le'`, both built on
      `TaskFrame.forward_comp`)*
- [x] Assert in the docstring exactly which axioms the proof consumes, so a later reader can check
      the §7-style threading for this lemma too. *(completed — both the module docstring's "Which
      axioms this consumes" section and `constraint`'s own docstring enumerate the three
      consumed items and state explicitly that *Spherical* and *Limit* are **not** consumed
      here, *Spherical* being reserved for `lem:step`'s sole application site)*

**Two transcription decisions this phase had to make, recorded rather than absorbed silently**
(neither is a skipped, altered, or deferred plan step — both are forced readings the listed tasks
did not pin down):

1. **The `z ∉ dom τ` proviso is not assumed, and the lemma is proved without it.**
   `lem:constraint` and `def:constraints` both say `z ∈ D \ X`, and Phase 6 deliberately left
   that proviso out of `Constraints`' type ("carried at use sites that need it"). This use site
   does not need it: when `z` *is* a domain time, `z` is unpaired (both `IsPaired` disjuncts
   demand a strict inequality), so `Fib(τ(z), 0)` is itself a constraint, and by fiber
   monotonicity it is contained in every other constraint — directedness then holds a fortiori.
   Adding the proviso would have weakened the lemma for no gain and would have forced Phase 8 to
   carry a hypothesis it can now omit. The `fib_zero_subset_of_mem_Constraints` branch is exactly
   this case.
2. **Segment nonemptiness consumes the interpolation half of *Compositionality* alone, not
   *Seriality* as well.** The plan's third task says "from *Seriality* plus Compositionality";
   the actual proof obligation is discharged by `hInt` on its own, because the witness the
   segment needs is produced by interpolating the history's *own* task-respect step
   `τ(t) ⇒_{s-t} τ(s)` at the split `s - t = (z - t) + (s - z)` — there is no residual
   existential for *Seriality* to supply. `hSer` remains genuinely load-bearing for the lemma as
   a whole (it is what makes the fiber members nonempty), and the deletion probe below confirms
   it; it is simply not used in the segment branch. This is a narrowing of a plan task's stated
   means, not of its stated end, and the phase's stated verification criterion ("the proof body
   genuinely mentions `hSer`, `hInt`, and `forward_comp`") is met unchanged.

Six supporting lemmas are landed alongside `constraint`, since neither the directedness nor the
nonemptiness argument is expressible without them: `seg_eq_inter_fib` (a constraint segment is
the intersection of its two endpoint fiber conditions, with `-(s - z)` normalized to `z - s` so
that segment endpoints and fibers are handled by one monotonicity lemma each),
`fib_subset_fib_of_le_of_le` and `fib_subset_fib_of_le_of_le'` (fiber monotonicity below and
above `z` — the constraint imposed by the domain time *nearer* `z` is the tighter one),
`fib_zero_subset` and `fib_zero_subset_of_mem_Constraints` (the `z ∈ dom τ` case of decision 1),
and `seg_subset_seg` (segment monotonicity in both endpoints).

**Timing**: 2.5 hours

**Depends on**: 6

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Constraint.lean` (new)
- `FormalSystem/Semantics.lean` — aggregator import and submodule docstring entry

**Verification**:
- `lake build` green, sorry-free, axiom-free. **PASSED** — full-project `lake build` exit 0
  (2328 jobs); `grep -c sorry FormalSystem/Semantics/Extension/Constraint.lean` returns 0;
  `grep -rn "^axiom " FormalSystem/` matches only docstring prose, no `axiom` declaration
  anywhere in the tree (unchanged from the phase's baseline); `#print axioms
  PartialHistory.constraint` reports the three standard Lean axioms
  `[propext, Classical.choice, Quot.sound]` and nothing else. Classical reasoning enters through
  the `by_cases` on `IsPaired` (an existential over `D`, not decidable); this is not the
  choice-free régime `lem:nullity` was held to, and no claim of choice-freeness is made for this
  lemma.
- The proof body genuinely mentions `hSer`, `hInt`, and `forward_comp` (grep the proof term or
  check by deleting a hypothesis and observing failure). **PASSED** — both checks run:
  (a) deletion probe — re-elaborating the verbatim bodies of `nonempty_fib_of_serial` and
  `nonempty_seg_of_interpolates` with `hSer` / `hInt` deleted from the binder list fails with
  `unknown identifier 'hSer'` / `unknown identifier 'hInt'`, so neither hypothesis is inferable
  from context; (b) proof-term grep — `#print` of `fib_subset_fib_of_le_of_le` and
  `fib_subset_fib_of_le_of_le'` mentions `TaskFrame.forward_comp` in both, and directedness
  routes through those two lemmas exclusively.
- Additional check, since the phase feeds the section-7 threading criterion:
  *Spherical* is **not** consumed by this lemma, and its docstring says so explicitly. That is
  the intended shape — `lem:constraint` *supplies* the directed-family-of-nonempty-sets
  hypothesis that `lem:step` (Phase 9) will feed to *Spherical* at the paper's sole application
  site, so *Spherical* staying a consumable hypothesis-form `Prop` is preserved, not spent.

---

### Phase 8: `lem:fibers` and `lem:admissible` [COMPLETED]

**Goal**: Transcribe the two lemmas that turn membership in all constraints into a one-point
extension, mirroring the paper's decomposition exactly.

**Tasks**:
- [x] `theorem fibers` — `u` belongs to every member of `Constraints τ z` iff
      `F.TaskRel (τ.states t ht) (z - t) u` for every `t ∈ dom τ`. Docstring cites `lem:fibers`
      verbatim. Note that the statement carries **no sign proviso**, which is why
      `PartialHistory.respects_task` is unconditional (Decision B). *(completed —
      `PartialHistory.fibers`, statement exactly as specified, `lem:fibers` quoted verbatim from
      `specs/paper-definitions-of-record.md`; the docstring states the no-sign-proviso point and
      its link to the unconditional `respects_task` field)*
- [x] `theorem admissible` — the function `τ ∪ {⟨z, u⟩}` is a partial history on `dom τ ∪ {z}`
      iff `u` belongs to every member of `Constraints τ z`. Docstring cites `lem:admissible`
      verbatim and records the proof recipe: `lem:nullity` (the zero loop at `z` itself) plus
      `lem:fibers`. *(completed — `PartialHistory.admissible`, an iff between
      `AdjoinRespects τ z u` and `∀ c ∈ Constraints τ z, u ∈ c`; the recipe is recorded and the
      four pair-cases are annotated inline with which half discharges each)*
- [x] Provide the concrete one-point extension construction
      `PartialHistory.adjoin τ z u (h : …) : PartialHistory F` with `Extends (adjoin …) τ`.
      *(completed — `PartialHistory.adjoin` over `adjoinDomain` / `adjoinFun`, with
      `adjoin_extends`, plus `adjoin_domain_self` and `adjoin_states_self` so Phase 9 can read off
      that the extension actually covers `z` and takes the new value there)*
- [x] Discharge `lem:nullity`'s reflexivity half via Phase 6's `nullity_of_serial_limit`. Record
      that `nullity_identity` is strictly stronger than `lem:nullity` and that its open design
      question — demote, keep the iff, or drop injectivity-at-zero — is joint with the four-axiom
      frame-alignment work and **not decided here**; `lem:admissible` consumes only the
      reflexivity half, so the choice does not obstruct this phase. *(completed — the `⟨z, z⟩`
      pair-case is closed by `TaskFrame.nullity_of_serial_limit hSer hLim u`; the module docstring
      records that `TaskFrame.nullity_identity` is an iff, strictly stronger than the paper's
      derived `lem:nullity`, that nothing in this module depends on the field, and that all three
      options therefore stay open. Note the plan's `TaskFrame.lean:198` line locator was not
      carried into the Lean docstring, per the durable-anchor rule)*

**Two transcription decisions this phase had to make, recorded rather than absorbed silently**
(neither is a skipped, altered, or deferred plan step):

1. **The `z ∉ dom τ` proviso *is* assumed here, unlike in Phase 7.** `admissible` carries
   `hz : ¬ τ.domain z`, and it is load bearing in the left-to-right direction: when `z ∈ dom τ`
   the paper's `τ ∪ {⟨z, u⟩}` is not a well-defined extension at all, `adjoinFun` keeps `τ`'s own
   value at `z` and discards `u`, and the task-respect condition then holds for *every* `u` while
   constraint membership does not. `fibers` needs no such proviso and does not assume one. This is
   the exact complement of Phase 7's decision 1, and the contrast is recorded in the module
   docstring so a reader does not conclude the two phases disagree.
2. **The extended state function is total on `D` (`adjoinFun : D → WorldState`), not a dependent
   function of a domain proof.** `adjoin` restricts it to `adjoinDomain τ z`, so nothing reads its
   value off the domain and the paper's `τ ∪ {⟨z, u⟩}` is unchanged. The proof-free form is what
   keeps the two rewriting lemmas (`adjoinFun_of_domain` / `adjoinFun_of_not_domain`) free of
   proof-argument metavariables; the dependent form was tried first and made every `rw` in
   `admissible` fail to find its pattern.

**Timing**: 2.5 hours

**Depends on**: 7

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Admissible.lean` (new)
- `FormalSystem/Semantics.lean` — aggregator import and submodule docstring entry *(deviation:
  added — the new module is unreachable from the aggregator without it, exactly as Phase 7
  needed)*

**Verification**:
- `lake build` green, sorry-free, axiom-free. **PASSED** — full-project `lake build` exit 0
  (2329 jobs, one more than Phase 7's 2328); `grep -c sorry
  FormalSystem/Semantics/Extension/Admissible.lean` returns 0; no `axiom` declaration anywhere in
  `FormalSystem/` (the five `^axiom ` grep hits are all docstring prose, unchanged from the
  phase's baseline); `#print axioms` for `fibers`, `admissible`, `adjoin`, and `adjoin_extends`
  reports the three standard Lean axioms `[propext, Classical.choice, Quot.sound]` and nothing
  else. `Classical.choice` enters through `adjoinFun`'s case distinction on the domain predicate
  and through `by_cases`; this is a property of the *construction*, and no claim of
  choice-freeness is made for it. `lem:nullity` itself remains choice-free as
  `nullity_of_serial_limit` proves it.
- `adjoin`'s `nonempty_domain` and unconditional `respects_task` fields are both discharged.
  **PASSED** — `nonempty_domain` from `τ.nonempty_domain` (the old domain injects into the new
  one via `Or.inl`), and `respects_task` from the `AdjoinRespects` hypothesis directly, with no
  `ofLe` detour and no guarded restatement.
- Additional check, since the phase feeds the section-7 threading criterion: *Spherical* is
  **not** consumed by either lemma, and the module docstring says so explicitly. `lem:step`
  (Phase 9) remains its sole application site; this module supplies that application its *other*
  input, the certificate that a state common to all constraints yields a genuine extension.

---

### Phase 9: `lem:step` — the Step Lemma, sole *Spherical* application site [COMPLETED]

**Goal**: Prove the Step Lemma, and thereby discharge the charter's §7 cross-task acceptance
criterion. This is the phase the §7 mechanism turns on.

**Tasks**:
- [x] State `theorem step (F : TaskFrame D) (hSph : Spherical F.TaskRel) (hSer : Serial F.TaskRel)
      (hInt : Interpolates F.TaskRel) (τ : PartialHistory F) (z : D) :
      ∃ σ : PartialHistory F, PartialHistory.Extends σ τ ∧ σ.domain z`. Docstring cites `lem:step`
      verbatim. *(deviation: altered — one additional binder `hLim : ∀ w v, (∀ x, 0 < x → ∃ y,
      |y| < x ∧ F.TaskRel w y v) → v = w` sits between `hInt` and `τ`. Forced by the inherited
      Phase 8 interface: `PartialHistory.admissible` takes `hLim` explicitly, because `TaskFrame`
      deliberately does not carry *Limit* as a structure field and `lem:admissible` needs
      `lem:nullity` at `z` itself. No other binder, the conclusion, or the proof strategy changed.
      The forthcoming frame-axiom-field refactor discharges `hLim` the same mechanical way it
      discharges `hSph`/`hSer`/`hInt`.)*
- [x] Prove it as `lem:constraint` + *Spherical* + `lem:admissible`: the constraints form a
      directed family of nonempty fibers and segments (Phase 7), *Spherical* yields a point in
      their intersection, `lem:fibers` converts that to the fiber condition, `lem:admissible`
      converts that to the one-point extension.
- [x] Handle the `z ∈ dom τ` case trivially (`σ := τ`).
- [x] Transcribe the paper's closing remark in the docstring, verbatim: `When the family has a
      subset-least member, that member already contains a candidate and *Spherical* is not
      needed.`
- [x] Add a module-level comment naming this as **the sole *Spherical* application site**, and
      restating the 420-phase-10 invariant from "The §7 mechanism" above.

**Timing**: 2.5 hours

**Depends on**: 8

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Step.lean` (new)

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- **§7 acceptance check**: deleting `hSph` from `step`'s binder list makes the proof fail. Record
  the failure message in the phase's commit or the implementation summary as evidence that
  *Spherical* is genuinely consumed and not inert.
- `grep -rn "Spherical" --include=*.lean FormalSystem/` shows exactly one consuming proof site.

**Verification results (recorded)**:
- `lake build` green over the whole project (2330 jobs). `FormalSystem/Semantics/` is sorry-free
  (`grep -c sorry` = 0); the 161 census sorries are all pre-existing (160 under `Boneyard/`, one
  at `Metalogic/WeakCanonical/Transfer.lean:1085`), none introduced here.
- `#print axioms FormalSystem.Semantics.PartialHistory.step` →
  `[propext, Classical.choice, Quot.sound]` — Lean's three standard axioms only, no `sorryAx`,
  no project axiom.
- **§7 deletion probe** — re-elaborating `step`'s body verbatim with the `hSph` binder removed
  fails:
  `error(lean.unknownIdentifier): Unknown identifier 'hSph'` at the `obtain` line, followed by
  `error: Tactic 'rcases' failed: 'x✝ : ?m.124' is not an inductive datatype`.
- **§7 proof-term inspection** — `#print FormalSystem.Semantics.PartialHistory.step` shows `hSph`
  twice: once bound (`hSph hSer hInt hLim τ z =>`) and once **applied as a function head**
  (`hSph (τ.Constraints z) hdir fun c hc`). *Spherical* is literally the hypothesis the proof
  consumes, not an inert binder.
- **Sole application site** — the only code occurrences of `Spherical` in `FormalSystem/` are its
  definition (`Semantics/FrameAxioms.lean:122`) and `step`'s binder + application
  (`Semantics/Extension/Step.lean:116,127`). Every other hit is docstring prose.
- Registered in the aggregator `FormalSystem/Semantics.lean` (import + submodule note).

---

### Phase 10: `thm:extension` and hypothesis-form `cor:occurrence` [COMPLETED]

**Goal**: Close the chain: every partial history is extended by some total world history, and
every world state occurs at any prescribed time in some total world history — both with the frame
axioms carried as explicit hypotheses.

**Tasks**:
- [x] `theorem extension (F) (hSph) (hSer) (hInt) (τ : PartialHistory F) :
      ∃ σ : F.HF, PartialHistory.Extends σ.val.toPartialHistory τ`. Docstring cites `thm:extension`
      verbatim. Proof = `exists_maximal_extension` (Phase 5) + `step` (Phase 9) only: a maximal
      partial history must be total, else `step` would extend it; a total partial history is
      convex, hence a `WorldHistory`, hence an `F.HF` element. *(deviation: altered — the same
      extra `hLim` binder Phase 9 introduced sits between `hInt` and `τ`, inherited unchanged from
      `step`'s signature and forwarded to it verbatim. No other binder, the conclusion, or the
      proof strategy changed.)*
- [x] Prove the maximal-to-total step explicitly and name it (`isTotal_of_isMax`), as the converse
      companion to Phase 5's `isMax_of_total`.
- [x] Prove `total_isConvex` — a total domain is convex — so the promotion to `WorldHistory` is
      immediate.
- [x] `theorem occurrence (F) (hSph) (hSer) (hInt) (w : F.WorldState) (x : D) :
      ∃ τ : F.HF, τ.val.states x (τ.property x) = w`. Docstring cites `cor:occurrence` verbatim.
      Proof extends the one-point partial history `{⟨x, w⟩}` directly via `extension` — the old
      translation argument is gone from this chain and must not be reintroduced. *(same inherited
      `hLim` binder as above.)*
- [x] Add a module comment stating that the **frame-intrinsic** form of `cor:occurrence` (which
      would need `Nonempty WorldState` plus *Seriality*/*Spherical* as `TaskFrame` data) is
      deliberately **not** provided here and is gated on the frame-axiom-field refactor.

**Additive items** (not plan steps skipped or rerouted — every plan step above landed as named;
these are the supporting definitions those steps required, plus the recorded anchor's own closing
clause):
- `PartialHistory.toWorldHistory` / `isTotal_toWorldHistory` — the promotion `total_isConvex`
  exists to enable, needed to write `extension`'s `F.HF` witness at all.
- `PartialHistory.point` (+ `point_states`) — the one-point partial history `{⟨x, w⟩}` named in
  `occurrence`'s own task bullet; its `respects_task` obligation reduces to `TaskRel w 0 w`,
  discharged by the existing `TaskFrame.nullity_identity` field (no new axiom hypothesis).
- `PartialHistory.hF_nonempty` — the closing clause of `cor:occurrence`'s verbatim statement
  ("…and so $H_{\F} \neq \emptyset$"), which would otherwise be the one recorded clause of the
  anchor left untranscribed. Takes the starting world state `w` as an explicit argument, since
  `TaskFrame` carries no `Nonempty WorldState`.

**Timing**: 2 hours

**Depends on**: 5, 9

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Extension.lean` (new)

**Verification**:
- `lake build` green, sorry-free.
- `#print axioms extension` shows `Classical.choice` (via Zorn) and nothing beyond the Mathlib
  baseline.
- `extension`'s proof mentions only `exists_maximal_extension` and `step` — no other axiom use.

**Verification results (recorded)**:
- `lake build` green over the whole project (2331 jobs, one more than Phase 9's 2330 — the new
  module). `FormalSystem/Semantics/` remains sorry-free (`grep -c sorry` = 0).
- `#print axioms` → `[propext, Classical.choice, Quot.sound]` for `extension`, `occurrence`,
  `isTotal_of_isMax`, and `hF_nonempty`; `total_isConvex` needs only `[propext]`. Lean's standard
  axioms only — no `sorryAx`, no project axiom. `Classical.choice` enters exactly where the
  recorded footnote says it does (Zorn), consistent with `lem:nullity` remaining choice-free.
- **"Zorn plus `lem:step` and nothing else"** — verified by inspecting the printed proof terms
  rather than by reading the source. The project constants occurring in `extension` /
  `isTotal_of_isMax` / `occurrence` are exactly: `exists_maximal_extension`, `step`,
  `isTotal_of_isMax`, `isTotal_toWorldHistory`, `point`, `le_def.mp`, `le_def.mpr`. No other
  extension-chain lemma appears.
- **`Spherical`'s sole application site is preserved.** `Spherical` / `Serial` / `Interpolates`
  occur in the new module's proof terms only as *binder types*, never as applied function heads —
  the four axiom binders are forwarded to `step` unchanged and are not applied to anything here.
  `step` remains the only consuming proof, so Phase 9's discharge of the charter's §7 criterion is
  intact and no second application site was added.
- **The former translation argument is not present.** `occurrence` reaches an arbitrary time `x`
  by extending `point F w x` directly; no `timeShift` lemma appears anywhere in the new module's
  proofs (time-shift machinery survives untouched elsewhere and plays no role in this chain).
- Registered in the aggregator `FormalSystem/Semantics.lean` (import + submodule note).

---

### Phase 11: Completeness-side Omega is `H_F` [NOT STARTED]

**Goal**: Land the provable set equation that turns the completeness side's Omega-elimination into
a rewrite, and classify the two Omega-valued definitions the round-3 report left UNVERIFIED before
any collapse phase depends on them.

**Tasks**:
- [ ] Land `multiFamOmegaGen_eq_total : multiFamOmegaGen D FamIdx = {σ | ∀ t, σ.domain t}`, proved
      from `multiFamHistoryGen`'s `domain := fun _ => True` (`⊆`) and `multiFamGen_total_eq` (`⊇`),
      both already in the tree from task 415. The round-3 report verified this proof sorry-free
      against the live tree.
- [ ] Derive the corollary for `bundleFlowOmega` (`FlowFrame.lean:432-433`), which is
      `multiFamOmegaGen` at the bundle index.
- [ ] **Classify `multiFamOmega`** (`ReynoldsBridge.lean:694`): prove it equal to its frame's
      `H_F`, or prove it a strict subset. The report flags it as likely behaving like
      `multiFamOmegaGen` (it is the `ℤ` specialization) but did **not** confirm this.
- [ ] **Classify `ZOmegaV2`** (`ReynoldsBridge.lean:468`) the same way.
- [ ] If either classification comes out strict-subset, record it immediately: it means a second
      carrier re-host in the mould of Phase 12, and the plan must be revised before Phase 14 runs.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the round-3 report identifies exactly **5** Omega-valued definitions in the
live tree — `regionOmega`, `ZOmegaV2`, `multiFamOmega`, `multiFamOmegaGen`, `bundleFlowOmega`. Two
are already classified (`multiFamOmegaGen`/`bundleFlowOmega` = `H_F`; `regionOmega` ⊊ `H_F`), so
this phase classifies the remaining 2. Confirm the population at implementation time with
`grep -rn "Set (WorldHistory" --include=*.lean FormalSystem/ | grep -v Boneyard`; if a sixth
definition exists, classify it here too and record the correction.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`

**Verification**:
- `lake build` green, sorry-free.
- Each of the 5 Omega-valued definitions has a recorded verdict (equal to `H_F`, or strictly
  smaller with the witness named).

---

### Phase 12: `regionFrame` deterministic re-host [NOT STARTED]

**Goal**: Replace `regionFrame`'s permissive task relation with a deterministic carrier whose total
histories are exactly the intended `regionHistory` family, so that `regionOmega = H_F` becomes
provable. This is the move task 415 already made on the completeness side.

The problem being fixed, precisely: `regionFrame.TaskRel = fun s d s' => d = 0 → s = s'`
(`Bridge/Omega.lean:138`) is maximally permissive above zero, so **any** assignment of states to
all of `D` is a legal total history — `regionFrame`'s `H_F` is the full function space
`D → W × (Set ι × Set ι)`, whereas `regionOmega` is the range of a two-parameter `W × D` family.
The module docstring (`Bridge/Omega.lean:20-32`) already explains that a too-big Omega breaks the
construction: a single adversarial history falsifies `□p` outright and no branch carrying `T(□p)`
could ever be satisfied. **Totality fixes the empty-history problem but not the junk-history
problem.**

**Tasks**:
- [ ] Redefine `regionFrame`'s `TaskRel` as a deterministic-shift relation, so that
      `TaskRel s d s'` holds iff `s'` is the shift of `s` by `d` under the region structure — the
      structural analogue of `multiFamTaskFrameGen`.
- [ ] Re-prove the `TaskFrame` fields for the new relation: `nullity_identity`, `forward_comp`,
      `converse`.
- [ ] Prove `regionFrame_total_eq` — every total history of the new `regionFrame` is a
      `regionHistory f w Δ` — the direct analogue of `multiFamGen_total_eq`.
- [ ] Prove `regionOmega_eq_total : regionOmega f = {σ | ∀ r, σ.domain r}`.
- [ ] Re-prove the five `Bridge/Omega.lean` declarations against the new relation, **keeping their
      statements unchanged**: `regionHistory_mem_regionOmega`, `mem_regionOmega_iff`,
      `shiftClosed_regionOmega`, `regionOmega_total`, and the box-reduction lemma at `:322`.
- [ ] Update the module docstring's explanation of why `Set.univ` is rejected, since the reason
      changes: under the new relation the frame's `H_F` no longer contains junk histories.

**Timing**: 3 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: the re-host proper is contained in `Bridge/Omega.lean` — one `TaskFrame`
definition plus 5 declarations about `regionOmega`. The report's larger figure ("~70+ declarations
downstream") counts consumers of the *Omega parameter*, which are rewritten in Phases 19-22
regardless and are not this phase's work. Confirm at implementation time by keeping the five
interface lemma statements byte-identical and observing which files still break; if consumers
break beyond the five named in Phase 13, that is the signal to invoke Decision C's spawn
contingency.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean`

**Verification**:
- `lake build` green, sorry-free.
- `regionOmega_eq_total` proved.
- The five interface lemma statements are unchanged (diff shows proof-body changes only).

---

### Phase 13: `regionFrame` consumer repair [NOT STARTED]

**Goal**: Repair whatever the new `regionFrame` relation breaks in the bridge consumers, still
entirely within the current Omega architecture, so the tree returns to green before any API change.

**Tasks**:
- [ ] Repair `Bridge/Valuation.lean`.
- [ ] Repair `Bridge/IntTruth.lean`.
- [ ] Repair `Bridge/DenseTruth.lean`.
- [ ] Repair `Bridge/TruthLemma.lean`.
- [ ] Repair `Bridge/RegionLabel.lean`.
- [ ] Repair whatever `Decidability/Verified/Decidable.lean` surfaces.
- [ ] Update the `IntTruth.lean:41-66` prose describing `regionOmega` as the range of a
      two-parameter family, and the genuine certificate gap it names, to match the new relation.

**Timing**: 3 hours

**Depends on**: 12

**Verification Tier**: full

**Scope Hypothesis**: the report's reference inventory gives `Valuation.lean` 19 code refs,
`IntTruth.lean` 12, `DenseTruth.lean` 5, `TruthLemma.lean` 3, `RegionLabel.lean` 2, plus the 42
declarations of `Decidable.lean` sitting above them. Most of those refs pass `regionOmega`
opaquely through the five stable interface lemmas and should need **no** edit at all under
Phase 12's statement-stability constraint. Confirm at implementation time by building and
enumerating the actual error set; if the actual repair set materially exceeds the five files named
here, invoke Decision C's spawn contingency rather than absorbing the overrun silently.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Valuation.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/DenseTruth.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionLabel.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` (as needed)

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- Full test suite passes.

---

### Phase 14: Retarget `TruthAt`'s box clause to totality [NOT STARTED]

**Goal**: The semantic heart of the refactor. Change the box clause from `∀ σ ∈ Omega` to
`∀ σ, σ.IsTotal →`, per `def:BL-semantics`'s box clause (`for all $\sigma \in H_{\F}$`), and
rebuild shift-preservation without `ShiftClosed`. The `Omega` parameter stays in the signature at
this phase — inert — so that Decision D's reverse-topological sweep can remove it later while
keeping every intermediate green.

**Tasks**:
- [ ] Rewrite `TruthAt`'s `Formula.box` clause as `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M _Omega σ t φ`.
- [ ] Rename the now-inert parameter `_Omega` and document, in the definition's docstring, that it
      is a transient carrier removed in the terminal sweep — never a shipped shim.
- [ ] Leave the `untl` / `snce` clauses' shape untouched (they are τ-local). Add a docstring note
      recording the **event-first / guard-second** convention and the divergence from the paper's
      `def:BLplus-semantics` footnote, cross-referencing `specs/decisions/untl-snce-argument-order.md`.
      Do **not** change the argument order.
- [ ] Retain the atom clause's `∃ (ht : τ.domain t)` and document why (Decision A, accepted gap).
- [ ] Rewrite `truthAt_box_iff` against totality.
- [ ] Rewrite `truth'_double_shift_cancel`; its box case becomes `simp only [TruthAt]` with no
      residual goal, because both sides now quantify over the same `IsTotal` predicate.
- [ ] Rewrite `TimeShift.time_shift_preserves_truth` **with no `ShiftClosed` hypothesis in the
      statement**; the box case's `h_sc ρ h_rho_mem (y - x)` is replaced by
      `isTotal_timeShift hρ _`, definitionally `fun t => hρ (t + Δ)`.
- [ ] Drop the now-absent `h_sc` argument at its live call sites (`Soundness.lean:265`,
      `DenseValidity.lean:206`/`:858`, `Decidable.lean:655`/`:666`/`:1509`, plus doc references).

**Timing**: 3 hours

**Depends on**: 4, 11, 13

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 8 live call sites pass `h_sc` to `time_shift_preserves_truth` and each loses
one argument. Confirm at implementation time with
`grep -rn "time_shift_preserves_truth" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard`
and by the post-edit error list.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean`
- `FormalSystem/Semantics/TimeShift.lean`

**Verification**:
- `lake build` green after this phase's batch completes, sorry-free.
- `ShiftClosed` no longer appears in any statement in `Semantics/**` (the definition itself is
  deleted in Phase 22).
- The box clause reads as `def:BL-semantics`'s box clause modulo the `IsTotal` predicate encoding.

---

### Phase 15: Box-clause repair — soundness, frame conditions, automation, tests [NOT STARTED]

**Goal**: Repair every proof whose reasoning depended on the old `σ ∈ Omega` box clause in the
soundness and support layers. Per charter §5, soundness consumes shift-preservation, not Zorn
extension, and the totality-based version is strictly easier — this phase should be lighter than
its declaration count suggests.

**Tasks**:
- [ ] Repair `FormalSystem/Metalogic/Soundness.lean`'s modal-axiom cases.
- [ ] Repair `FormalSystem/FrameConditions/Validity.lean` and `FrameConditions/Soundness.lean`.
- [ ] Repair `FormalSystem/Automation/PrefilterSoundness.lean` and `Automation/DatasetGenerator.lean`.
- [ ] Repair `Tests/BimodalTest/Integration/Helpers.lean` and any test breakage.
- [ ] Replace `Set.univ` box-clause arguments where they appear in a semantics position
      (`Chronicle/RRelation.lean`, `Decidability/Propositional/Decidable.lean`, `Soundness.lean`)
      with the totality form.

**Timing**: 3 hours

**Depends on**: 14

**Verification Tier**: full

**Scope Hypothesis**: the report's group inventory puts `Soundness.lean` at 70 declarations in the
Omega/validity blast radius and group (C) at 21 (`FrameConditions/Validity.lean` 9,
`FrameConditions/Soundness.lean` 5, `Automation/PrefilterSoundness.lean` 4, `Tests/.../Helpers.lean` 2,
`Automation/DatasetGenerator.lean` 1). **Most of those are signature-only and are not this phase's
work** — this phase repairs only proofs whose *reasoning* used `σ ∈ Omega`. Confirm the actual
repair set from the build error list after Phase 14.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean`
- `FormalSystem/FrameConditions/Validity.lean`, `FormalSystem/FrameConditions/Soundness.lean`
- `FormalSystem/Automation/PrefilterSoundness.lean`, `FormalSystem/Automation/DatasetGenerator.lean`
- `Tests/BimodalTest/Integration/Helpers.lean`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- Soundness theorems retain their statements modulo the totality binder.

---

### Phase 16: Box-clause repair — completeness side [NOT STARTED]

**Goal**: Repair the canonical/algebraic completeness stack, rewriting along Phase 11's set
equations rather than re-proving anything. Per the round-3 report this is a rewrite, not a
re-proof: the live completeness-side Omega *is* `H_F`.

**Tasks**:
- [ ] Repair `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`.
- [ ] Repair `BXCanonical/Completeness.lean` — in particular `countermodel_dense_enriched`
      (`:134`), the live witness for both `completeness` and `completeness_dense`, whose docstring
      already anticipates this task by recording that its admissible-history set is extensionally
      the frame's total-history set.
- [ ] Repair `CompletenessDedekind.lean`, `ChronicleMonadicBridge.lean`,
      `ChronicleToCountermodelBasic.lean`, `Bundle/LimitMCS.lean`.
- [ ] Repair `WeakCanonical/IntegerModel/ReynoldsBridge.lean` per Phase 11's classification of
      `ZOmegaV2` and `multiFamOmega`.
- [ ] Rewrite the countermodel existentials of the shape `∃ Omega, ShiftClosed Omega ∧ τ ∈ Omega`
      to their totality form.

**Timing**: 3 hours

**Depends on**: 14

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean`
- `FormalSystem/Metalogic/CompletenessDedekind.lean`
- `FormalSystem/Metalogic/WeakCanonical/ChronicleMonadicBridge.lean`
- `FormalSystem/Metalogic/WeakCanonical/ChronicleToCountermodelBasic.lean`
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- `completeness` and `completeness_dense` retain their statements modulo the totality binder.

---

### Phase 17: Box-clause repair — decidability side [NOT STARTED]

**Goal**: Repair the decidability bridge and certificate stack against the retargeted box clause,
rewriting along Phase 12's `regionOmega_eq_total`.

**Tasks**:
- [ ] Repair the box-reduction lemma in `Bridge/Omega.lean` (`truthAt_box_iff_region` at `:322`)
      so it reduces against `H_F` rather than `regionOmega`.
- [ ] Repair `Bridge/TruthLemma.lean`'s `InterpInvariant` / `InterpInvariantAt` box reasoning
      (`:15`, `:27`, `:35`, `:71-77`, `:318-319`).
- [ ] Repair `Bridge/DenseTruth.lean`, `Bridge/IntTruth.lean`, `Bridge/RegionLabel.lean`.
- [ ] Repair `Bridge/Interpolate.lean` (note the section-`variable` Omega at `:459`, which means
      the whole enclosing section is affected even where a per-declaration scan sees one hit).
- [ ] Repair `Decidability/Verified/Decidable.lean`.

**Timing**: 3 hours

**Depends on**: 14

**Verification Tier**: full

**Scope Hypothesis**: the report puts `Decidable.lean` at 42 declarations in the blast radius, and
flags `Bridge/TruthLemma.lean:79` and `Bridge/Interpolate.lean:459` as taking Omega from a section
`variable`, so those two sections are **undercounted** by a per-declaration scan. Confirm at
implementation time from the build error list, not from the count.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/DenseTruth.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionLabel.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- The decidability certificate theorems retain their statements.

---

### Phase 18: Validity-layer binder delta [NOT STARTED]

**Goal**: Apply the charter §2 two-move delta to every definition that binds the
`Omega + ShiftClosed + τ ∈ Omega` triple in its **body**: drop the triple, add the totality
constraint. These are definitions whose Omega is internal, so their callers are unaffected and the
binder can be removed here rather than in a later sweep.

**Tasks**:
- [ ] `valid` (`Validity.lean:80`) and `SemanticConsequence` (`:104`) — drop `Omega`/`ShiftClosed`/
      `τ ∈ Omega`, add `(_ : τ.IsTotal)`. Both **already carry `[Nontrivial D]`** (verified), so no
      binder is added there. Docstrings cite `def:BL-semantics` and `def:logical-consequence`
      verbatim.
- [ ] The four variant validity predicates — `ValidDense` (`:169`), `ValidDiscrete` (`:187`),
      `ValidDedekind` (`:241`), `ValidDedekindDense` (`:276`) — identical delta; all four already
      carry `[Nontrivial D]`.
- [ ] The satisfiable family — `satisfiable` (`:129`), `SatisfiableAbs` (`:138`),
      `FormulaSatisfiable` (`:154`) — same delta, **plus add `[Nontrivial D]`**, which these three
      lack. Docstring must record that satisfiability has **no paper anchor**: this is a design
      decision inherited from `valid`, not a reconciliation finding.
- [ ] `ValidOver`, `IsValid`, `SemanticConsequenceDedekindDense` — same delta.
- [ ] Check `unsatisfiable_implies_all` (`:372`), whose statement quantifies without `Nontrivial`,
      and align it.

**Timing**: 2.5 hours

**Depends on**: 14

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the report identifies **11** definitional anchors binding the triple in their
body (`valid`, `SemanticConsequence`, `ValidDense`, `ValidDiscrete`, `ValidDedekind`,
`ValidDedekindDense`, `satisfiable`, `FormulaSatisfiable`, `ValidOver`, `IsValid`,
`SemanticConsequenceDedekindDense`), plus `SatisfiableAbs` named separately at `:138`. Confirm at
implementation time by grepping `Validity.lean` for `Set (WorldHistory` and `ShiftClosed` and
enumerating the definitions that survive.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`

**Verification**:
- `lake build` green, sorry-free.
- `grep -n "Omega\|ShiftClosed" FormalSystem/Semantics/Validity.lean` returns nothing.
- Each of `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable` now carries `[Nontrivial D]`.

---

### Phase 19: Omega-binder sweep A — leaves [NOT STARTED]

**Goal**: Begin Decision D's reverse-topological removal at the leaves, where no other declaration
depends on the affected signatures, so the phase ends green.

**Tasks**:
- [ ] Remove `Omega` parameters and `ShiftClosed` hypotheses from `Tests/BimodalTest/**`.
- [ ] Same for `FormalSystem/Examples/**`.
- [ ] Same for `FormalSystem/Automation/**`.
- [ ] Same for `FormalSystem/FrameConditions/**`.
- [ ] Confirm the reverse-topological precondition before each file: every declaration mentioning
      the one being changed has already dropped its own binder, or is in this same phase.

**Timing**: 2 hours

**Depends on**: 15, 18

**Verification Tier**: full

**Files to modify**:
- `Tests/BimodalTest/**`, `FormalSystem/Examples/**`, `FormalSystem/Automation/**`,
  `FormalSystem/FrameConditions/**`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- `grep -rn "Omega\|ShiftClosed" Tests/ FormalSystem/Examples/ FormalSystem/Automation/ FormalSystem/FrameConditions/ --include=*.lean`
  returns nothing.

---

### Phase 20: Omega-binder sweep B — decidability [NOT STARTED]

**Goal**: Remove the Omega binders across the decidability stack, still reverse-topologically.

**Tasks**:
- [ ] Remove binders from `Decidability/Verified/Decidable.lean` and the `Bridge/**` modules,
      innermost consumers first.
- [ ] Delete `regionOmega` and its `ShiftClosed` proof (`shiftClosed_regionOmega`) once nothing
      references them; keep `regionOmega_eq_total`'s content by folding it into whatever lemma
      still needs the characterization, without leaving a dangling Omega-valued definition.
- [ ] Remove binders from `Decidability/Propositional/Decidable.lean`.

**Timing**: 2.5 hours

**Depends on**: 17, 19

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/**`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- `grep -rn "Omega\|ShiftClosed" FormalSystem/Metalogic/Decidability/ --include=*.lean` returns
  nothing.

---

### Phase 21: Omega-binder sweep C — canonical and algebraic [NOT STARTED]

**Goal**: Remove the Omega binders across the completeness stack, and delete the remaining
Omega-valued definitions.

**Tasks**:
- [ ] Remove binders from `Metalogic/WeakCanonical/**`, `Metalogic/Algebraic/**`,
      `Metalogic/BXCanonical/**`, `Metalogic/Bundle/**`, `Metalogic/CompletenessDedekind.lean`,
      `Metalogic/Chronicle/**`.
- [ ] Delete the remaining Omega-valued definitions — `ZOmegaV2`, `multiFamOmega`,
      `multiFamOmegaGen`, `bundleFlowOmega` — and their `ShiftClosed` proofs, folding any needed
      characterization into the theorems that consumed them.
- [ ] Delete the corresponding `ShiftClosed` proofs about them.

**Timing**: 2.5 hours

**Depends on**: 16, 20

**Verification Tier**: full

**Scope Hypothesis**: the report puts the deletions at **12** — the 5 Omega-valued definitions plus
7 `ShiftClosed` proofs about them; Phase 20 deletes `regionOmega` and its proof, leaving 4
definitions plus the remaining proofs here. Confirm at implementation time with
`grep -rn "Set (WorldHistory\|ShiftClosed" --include=*.lean FormalSystem/ | grep -v Boneyard`; if
Phase 11 discovered a sixth Omega-valued definition, it is deleted here too.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/**`, `FormalSystem/Metalogic/Algebraic/**`,
  `FormalSystem/Metalogic/BXCanonical/**`, `FormalSystem/Metalogic/Bundle/**`,
  `FormalSystem/Metalogic/CompletenessDedekind.lean`, `FormalSystem/Metalogic/Chronicle/**`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- No Omega-valued definition remains outside `FormalSystem/Boneyard/**`.

---

### Phase 22: Omega-binder sweep D and terminus [NOT STARTED]

**Goal**: Remove the last binders at the root of the dependency graph and delete `ShiftClosed`
itself, then run the task-level gates.

**Tasks**:
- [ ] Remove the remaining binders from `FormalSystem/Metalogic/Soundness.lean`.
- [ ] Delete the `_Omega` parameter from `TruthAt` in `FormalSystem/Semantics/Truth.lean` (the
      transient carrier introduced in Phase 14), and from `FormalSystem/Semantics/TimeShift.lean`.
- [ ] Delete `ShiftClosed` (`Truth.lean:333-334`) and `Set.univ_shift_closed` (`:339`).
- [ ] Update every module docstring that describes the Omega architecture, including
      `Bridge/Omega.lean:20-32`'s rationale and `Truth.lean`'s header.
- [ ] Run the task-level gates listed under Testing & Validation.

**Timing**: 2.5 hours

**Depends on**: 21

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics/TimeShift.lean`,
  `FormalSystem/Metalogic/Soundness.lean`

**Verification**:
- `lake build` green, sorry-free, axiom-free.
- `grep -rn "ShiftClosed" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard` returns
  nothing.
- `grep -rn "Omega" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard` returns nothing
  outside prose that explicitly describes the retired architecture as historical.
- Full test suite passes.

---

### Phase 23: Frame-relative validity `⊨_F` — OPTIONAL [NOT STARTED]

**Goal**: Charter §8's optional deliverable. `def:frame-validity`'s `⊨_F` has no Lean counterpart
at all. **This phase is OPTIONAL and may be skipped without affecting task completion.**

**Tasks**:
- [ ] Add `TaskFrame.ValidOn (F : TaskFrame D) (φ : Formula) : Prop` quantifying over every model,
      every `τ : F.HF`, and every time. Docstring cites `def:frame-validity` verbatim.
- [ ] Add the never-vacuous statement as a **hypothesis-parameterized** theorem (it needs
      `cor:occurrence`, hence *Seriality*/*Spherical* as hypotheses): `¬ F.ValidOn ⊥` given the
      frame-axiom hypotheses. Record that the frame-intrinsic form arrives with task 420 phase 10.
- [ ] Relate `ValidOn` to `valid` (validity is validity on every frame) — as a theorem, not as an
      alias, so no parallel validity notion is created.

**Timing**: 1.5 hours

**Depends on**: 22

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`

**Verification**:
- `lake build` green, sorry-free.
- `valid φ ↔ ∀ F, F.ValidOn φ` proved, establishing that `ValidOn` is a specialization and not a
  competing notion.

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase, with no `sorry` and no new axioms.
- [ ] `bash scripts/check-paper-definitions.sh` passes (case (a) or (b)) after Phase 1 and again at
      task end.
- [ ] `grep -rn "ShiftClosed" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard` returns
      nothing.
- [ ] `grep -rn "Set (WorldHistory" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard`
      returns nothing.
- [ ] `#print axioms` on `valid`, `SemanticConsequence`, `soundness`, `completeness`,
      `completeness_dense`, `extension`, and `occurrence` shows no axiom beyond the Mathlib
      baseline (`Classical.choice`, `propext`, `Quot.sound`).
- [ ] **§7 acceptance check**: deleting `hSph` from `step`'s binders breaks the build; the failure
      is recorded as evidence.
- [ ] The full test suite under `Tests/BimodalTest/` passes.
- [ ] No file under `/home/benjamin/Philosophy/Papers/` is modified (`git status` in that
      repository is untouched by this work).
- [ ] No `\breve` / `\smallsmile` converse notation is introduced; new converse-mentioning Lean
      declarations use `inv` / `^-1`.

## Artifacts & Outputs

- `specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md` (this file)
- `specs/414_refactor_semantics_to_total_history_validity/summaries/03_omega-free-totality-refactor-summary.md`
- `specs/paper-definitions-of-record.md` — extended with `def:BLplus-semantics` (+ siblings)
- `specs/decisions/total-history-validity-decisions.md` — Decisions A-D and the 420 invariant
- `specs/decisions/untl-snce-argument-order.md` — the escalation record
- `FormalSystem/Semantics/PartialHistory.lean` — new
- `FormalSystem/Semantics/FrameAxioms.lean` — new
- `FormalSystem/Semantics/Extension/Constraint.lean`, `Admissible.lean`, `Step.lean`,
  `Extension.lean` — new
- Modified: `Semantics/WorldHistory.lean`, `Semantics/Truth.lean`, `Semantics/TimeShift.lean`,
  `Semantics/Validity.lean`, and the `Metalogic/**`, `FrameConditions/**`, `Automation/**`,
  `Examples/**`, `Tests/**` trees per phases 13-22
- Cross-task edit: `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`

## Rollback/Contingency

- **Per-phase**: every phase is committed only when green, so `git revert` of a phase commit
  restores a green tree. The two atomic-batch phases (4, 14, 18, 22) commit once at batch
  completion; their intermediate states are expected red and are never committed.
- **Phase 12/13 overrun**: invoke Decision C's spawn contingency — a task owning exactly
  `Bridge/Omega.lean` plus the five named consumer files, delivering `regionOmega_eq_total` inside
  the current Omega architecture. This task's Phase 14 then blocks on it. This is the only
  sanctioned scope split.
- **Phase 11 discovers a strict-subset `ZOmegaV2` or `multiFamOmega`**: stop and revise this plan
  before Phase 14 — a second carrier re-host is required and must be sized, not absorbed.
- **Chain phases 7-10 stall**: the extension chain is independent of the Omega collapse. Phases
  11-22 can proceed without it; the chain would then be the residual scope. Do not let a stalled
  `lem:step` block the Omega elimination, and do not weaken `lem:step`'s statement to make it pass.
- **Whole-task rollback**: the semantics core changes are confined to `Semantics/**` plus
  mechanical binder edits elsewhere; reverting phases 14-22 in reverse order restores the Omega
  architecture, with phases 1-10 (new material) harmless if left in place.
