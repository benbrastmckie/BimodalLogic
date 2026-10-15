# Research Report: Task #797

**Task**: 797 - Shift of finite type and eventually periodic possible worlds
**Started**: 2026-10-15T00:00:00Z
**Completed**: 2026-10-15T00:00:00Z
**Effort**: 5 phases (est.); the three deliverables are unequal — (1) and (3) are mostly assembly over existing machinery, (2) is the only one requiring new proof work
**Dependencies**: None declared in `specs/state.json`
**Sources/Inputs**:

In-tree Lean:
- `FormalSystem/Semantics/IntNormalForm.lean` (`iter`, `step`, `IsStepPath`, `taskRel_eq_iter`, `worldHistoryOfStepPath`, `mem_HF_iff_adjacent`)
- `FormalSystem/Semantics/Periodicity.lean` (pigeonhole/splice/bounded-witness toolkit)
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` (`FrameOver.extend_periodic`, `extend_periodic_of_finite_domain`, `exists_filler`)
- `FormalSystem/Semantics/TaskFrame.lean` (`FrameOver.reflection`, `reflection_of_limit`)
- `FormalSystem/Metalogic/Decidability/BiLasso/{Basic,Periodic,Extend,Successor,Orbit,Agreement}.lean` and `BiLasso/README.md`
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean`

Records and paper:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` (lines 1035–1056)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (line 1956, the cut record)
- `docs/reference/paper-definitions-of-record.md` ("Untracked sources", lines 2362–2404)
- `specs/TODO.md` (task 618 entry, lines 1473–1509), `specs/ROADMAP.md` (Stage 1)

External:
- Mathlib `Mathlib/Dynamics/SymbolicDynamics/Basic.lean` (namespace `SymbolicDynamics.FullShift`)

Measurement:
- 9 compiled `#print axioms` probes under the scratchpad, run with `lake env lean`

**Artifacts**:
- `specs/797_shift_finite_type_eventually_periodic_worlds/reports/01_shift-finite-type-periodic-worlds.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Most of the mathematical content of all three deliverables is already in the tree.**
  `FrameOver.extend_periodic` and `FrameOver.extend_periodic_of_finite_domain`
  (`Semantics/Extension/PeriodicExtension.lean`) are the frame-level doubly-ultimately-periodic
  extension for `[Finite WorldState]`; `IntPresentation.extend_periodic`,
  `extend_periodic_of_icc` and `extend_periodic_extends` plus `PlacedBiLasso` are the finite
  certificate (prefix-plus-cycle each way) with soundness; `BiLasso/Agreement.lean` already
  labels one of its theorems "the Deliverable-3 statement". The task's genuinely new content is
  narrower than its description suggests and should be re-scoped around it.
- **The choice-free demand is achievable, but only after a specific scrub and only under a
  different statement shape.** Measured: `FrameOver.reflection` is the single choice carrier on
  the `H_F`-membership path, and its choice comes from `eq_or_ne`. A probe replacing it with
  `Decidable.eq_or_ne` (legitimate at `D = intOrder`, since `ℤ` has `DecidableEq`) makes the whole
  chain — reflection, `taskRel_eq_iter`, `respects_of_isStepPath`, `worldHistoryOfStepPath`,
  `mem_HF_iff_adjacent` — measure `[propext, Quot.sound]`.
- **Two statement-shape constraints are forced, both measured.** (a) `Nat.card` carries
  `Classical.choice` *in the statement*: a theorem whose type merely mentions `Nat.card W` is
  choice-carrying regardless of its proof, so the period bound must be an enumeration length, not
  `Nat.card`. (b) `[Finite W]` alone cannot support a choice-free proof — `Fintype.ofFinite`,
  `Finset.toList` and `Multiset.toList` all carry choice — so the carrier must arrive as data
  (`enum : List W` with `∀ w, w ∈ enum`, plus `DecidableEq` and `DecidableRel F.step`).
- **The two remaining choice sources named in `Orbit.lean`'s ON CHOICE section are avoidable
  without touching the byte-stable `Basic.lean`.** `Metalogic/Decidability/BiLasso/Periodic.lean`
  — the carrier-generic three-segment decoding at `[Inhabited α]` — is entirely choice-free
  (`[propext]` / `[propext, Quot.sound]`), including its `length_pos_int`, which is exactly the
  lemma that makes `BiLasso.Basic`'s copy choice-carrying. Build the new certificate on
  `Periodic.unrollOf`, not on `BiLasso.unrollOf`.
- **Mathlib has an SFT vocabulary, and using it costs choice-freeness.**
  `SymbolicDynamics.FullShift.{Pattern, forbidden, Subshift.ofForbidden}` exists in the pinned
  Mathlib and is importable at `G = ℤ`, but every one of those declarations measures
  `[propext, Classical.choice, Quot.sound]`. Deliverable (1) should therefore be delivered twice:
  a choice-free bespoke forbidden-2-block characterization, and an optional choice-carrying
  dictionary theorem against Mathlib's `forbidden`.
- **Two provenance records are stale and must be repointed as part of this task.**
  `BiLasso/Agreement.lean`'s module docstring and `docs/reference/paper-definitions-of-record.md`'s
  "Untracked sources" entry both locate the footnote in `JPL/possible_worlds.tex`; it is now cut
  to `JPL/appendix_cut_material.tex`, and its text has been re-split into separate sentences, so
  the "verbatim" label on both quotes is currently false. The same record entry also names
  `FormalSystem.Semantics.TaskFrame.extend_periodic`, but the declaration is
  `FormalSystem.Semantics.FrameOver.extend_periodic`.

## Context & Scope

Researched: what the three deliverables of the dispatch (`.dispatch/3.md`, lines 18–26) already
have in the tree, and what the choice-free requirement in deliverable (2) actually costs.

Constraints respected: `lean_diagnostic_messages` and `lean_file_outline` not called; no file in
`FormalSystem/**` or `docs/**` modified (research phase); no `.orchestrator-handoff.json` written;
`lake build` not launched (no source edits were made, and the existing `.olean` set was sufficient
for every probe).

Evidence tier: the lean-lsp index reported `warming` on the one `lean_local_search` call made, so
that call's result is treated as positive evidence only (it returned hits); every negative and
every axiom claim below rests on a compiled `lake env lean` probe, not on an index lookup.

### Project Context

- **Upstream**: `Semantics/IntNormalForm.lean` (the adjacency presentation), `Semantics/Periodicity.lean`
  (pigeonhole), `Metalogic/Decidability/BiLasso/Periodic.lean` (generic decoding),
  `Metalogic/Decidability/IntPresentation.lean` (the presented-frame carrier).
- **Downstream**: the decidability route's Stage 1 (`specs/ROADMAP.md`), which wants a
  "root paths of a finite class graph" presentation; task 618's `D = ℤ` clause.
- **Alternative paths**: state the certificate over `IntPresentation` (existing, choice-carrying)
  versus over a frame carrying its carrier as data (new, choice-free). Both are live; see Decisions.

## Findings

### Codebase Patterns

**Deliverable (1) — the SFT identification.** No declaration in the tree carries an SFT name
(`grep -i "shift of finite type\|ShiftOfFiniteType\|ShiftFinite"` over `--include=*.lean` returns
only prose hits in `specs/`). The mathematical content exists as
`FrameOver.mem_HF_iff_adjacent` (`IntNormalForm.lean:348`), which identifies `∃ σ : WorldHistory F,
σ.path = f` with `IsStepPath F f`, for any `FrameOver intOrder` with `[F.IsRegular]` — no
finiteness. What is missing is the *named* packaging for `[Finite W]`: alphabet = `W`,
forbidden-word set = the non-edges of `(W, ⇒₁)` as a finite set of 2-blocks, `H_F` = the bi-infinite
paths.

**Deliverable (2) — the extension theorem.** `FrameOver.extend_periodic`
(`PeriodicExtension.lean:156`) already proves exactly the informal statement: a partial history
whose domain is `[a, b]` extends to a `WorldHistory F` ultimately periodic in both directions with
both periods `≤ Nat.card F.WorldState`. `extend_periodic_of_finite_domain`
(`PeriodicExtension.lean:403`) drops convexity to a merely finite domain, via `exists_filler`
(`:325`). Both measure `[propext, Classical.choice, Quot.sound]`. The module docstring (lines 37–51)
already argues that no bridge to the effective version exists, and names `Classical.choice` as the
reason.

**Deliverable (3) — the certificate.** `BiLasso` (`BiLasso/Basic.lean`) is the finite certificate:
three lists `back`, `mid`, `fwd`, both cycles non-empty, with a `coherent` field decidable by
`Fintype.decidableForallFintype`. `PlacedBiLasso` (`BiLasso/Extend.lean`) adds an `origin : ℤ`.
`IntPresentation.extend_periodic` (`Orbit.lean:106`) produces one from a window;
`extend_periodic_of_icc` (`Orbit.lean:159`) takes the window as a `PartialHistory` over `[a, b]`;
`PlacedBiLasso.extends_of_agrees` and `IntPresentation.extend_periodic_extends`
(`Agreement.lean:133`) are soundness and completeness respectively. `Agreement.lean:91` calls
`extend_periodic_extends` "the Deliverable-3 statement" in those words.

**Periodicity vocabulary — what to reuse and what not to.** The dispatch's instruction to reuse
`RaySummary/` and `PlusSlicedCertificate` vocabulary resolves as follows:

- `RaySummary/Periodic.lean`'s `periodicColouring` / `fwdPeriodic` / `bwdPeriodic` are
  three-segment decodings of *label words* (`sig.preds → Bool`), not of state paths. Same scheme,
  wrong carrier. Do not instantiate it; do not restate it.
- `Metalogic/Decidability/BiLasso/Periodic.lean`'s `Periodic.cyc` / `Periodic.unrollOf` **is** the
  carrier-generic three-segment decoding at arbitrary `[Inhabited α]`, with both periodicity
  lemmas. It is the correct reuse target at `α := F.WorldState`. Its own docstring records a
  retirement trigger naming "the effective-periodic-extension work" — i.e. this front — as the
  owner of the shared abstraction; note that the trigger describes refactoring `Basic.lean` onto
  it, which is out of scope here (see Risks).
- `PlusSlicedCertificate/Embed.lean`'s `perB` / `perF` / `perM` are period aggregates over a
  `WitnessFamily`'s lassos, for the `⊡` certificate layer. Not applicable.

**Layering constraint.** No file under `FormalSystem/Semantics/` imports `FormalSystem.Metalogic`
(verified by `grep -rln "import FormalSystem.Metalogic" FormalSystem/Semantics/`, empty). Since the
generic decoding lives under `Metalogic/Decidability/BiLasso/`, a certificate module that consumes
it cannot live under `Semantics/`. Deliverable (3) therefore belongs under
`Metalogic/Decidability/`, even though deliverables (1) and (2) belong under `Semantics/`.

**`Basic.lean` is held byte-stable** by an explicit ruling in `BiLasso/README.md` ("`Basic.lean` is
held stable", lines 188–195) and that hold is relied on in both directions. Nothing in this task
should edit it.

### External Resources

**Mathlib's symbolic-dynamics API exists and is usable.** In the pinned Mathlib,
`Mathlib/Dynamics/SymbolicDynamics/Basic.lean` provides, under namespace
`SymbolicDynamics.FullShift`:

- `Pattern A G` (`[Inhabited A]`) — a configuration with finite support
- `forbidden : Set (Pattern A G) → Set (G → A)` (`[Inhabited A] [AddMonoid G]`)
- `Subshift A G` (`[TopologicalSpace A]`) and `Subshift.ofForbidden`
  (`[TopologicalSpace A] [Inhabited A] [AddMonoid G] [IsLeftCancelAdd G] [DiscreteTopology A]`)

`G = ℤ` satisfies `AddMonoid` and `IsLeftCancelAdd`, so the instantiation is available. The file's
own doc list advertises a `subshift_of_finite_type F`; no such declaration exists in the file
(grep finds the name only inside the doc comment), so an SFT bundling must be written here rather
than imported. Note the file uses the new module system (`@[expose] public section`), and the names
resolve only under the full `SymbolicDynamics.FullShift.` prefix — `SymbolicDynamics.forbidden`
does not elaborate.

### Axiom measurements (all compiled this session)

Run via `lake env lean` on probe files under the session scratchpad.

| Declaration | Measured axioms |
|---|---|
| `FrameOver.mem_HF_iff_adjacent` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.worldHistoryOfStepPath` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.respects_of_isStepPath` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.taskRel_eq_iter` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.reflection` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.reflection_of_limit` | `[propext, Classical.choice, Quot.sound]` |
| `eq_or_ne` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.eq_of_taskRel_zero_of_limit` | `[propext]` |
| `TaskFrame.reflect_reflection_of_ne` | `[propext]` |
| `FrameOver.{comp, nullity_identity, serial, TaskRel}`, `intOrder` | `[propext]` |
| `FrameOver.taskRel_natCast_iff_iter` | `[propext]` |
| `FrameOver.iter_of_isStepPath`, `iter_add`, `iter_of_path` | `[propext, Quot.sound]` |
| `WorldHistory.ofTotal`, `PartialHistory.Extends` | `[propext]` |
| `exists_iter_fwd` | none |
| `FrameOver.extend_periodic` | `[propext, Classical.choice, Quot.sound]` |
| `FrameOver.extend_periodic_of_finite_domain` | `[propext, Classical.choice, Quot.sound]` |
| `Semantics.exists_repeat_of_card_le` | `[propext, Classical.choice, Quot.sound]` |
| `IntPresentation.extend_periodic` / `_of_icc` / `_extends` | `[propext, Classical.choice, Quot.sound]` |
| `PlacedBiLasso.extends_of_agrees` | `[propext, Classical.choice, Quot.sound]` |
| `IntPresentation.orbit_repeat`, `exists_dup_lt` | `[propext, Quot.sound]` |
| `BiLasso.length_pos_int`, `BiLasso.unroll_isStepPath` | `[propext, Classical.choice, Quot.sound]` |
| `List.getD_eq_getElem`, `List.getD_append` | `[propext, Classical.choice, Quot.sound]` |
| `Periodic.cyc`, `Periodic.length_pos_int`, `Periodic.unrollOf`, `Periodic.unrollOf_neg`, `Periodic.unrollOf_mid` | `[propext]` |
| `Periodic.unrollOf_fwd`, `Periodic.unrollOf_sub_back_length`, `Periodic.unrollOf_add_fwd_length` | `[propext, Quot.sound]` |
| `Nat.card` | `[propext, Classical.choice, Quot.sound]` |
| `Finset.toList` | `[propext, Classical.choice, Quot.sound]` |
| `Multiset.toList` | `[Classical.choice]` |
| `Fintype.ofFinite` | `[propext, Classical.choice, Quot.sound]` |
| `Finite.exists_equiv_fin`, `List.finRange` | none |
| `SymbolicDynamics.FullShift.{Pattern.occursInAt, forbidden, Subshift.ofForbidden, isClosed_forbidden}` | `[propext, Classical.choice, Quot.sound]` |

Two statement-level measurements, each a one-line probe:

- `theorem probe_statement_only {W : Type} [Finite W] : Nat.card W = Nat.card W := rfl` measures
  `[propext, Classical.choice, Quot.sound]`. The proof is `rfl`; the choice comes from the *type*.
  Any theorem whose statement mentions `Nat.card` is therefore choice-carrying.
- `theorem probe_fintype_enum {W : Type} [Fintype W] : ∀ w : W, w ∈ (Finset.univ : Finset W).toList`
  measures `[propext, Classical.choice, Quot.sound]`. So `Fintype` does not supply a choice-free
  enumeration list either.

### Feasibility probes (compiled, sorry-free)

Three probes establish that the choice-free version of deliverable (2) is reachable. Each was
elaborated by `lake env lean` and its axioms printed; none contains `sorry`.

1. **The reflection scrub.** `reflection'`, a copy of `FrameOver.reflection_of_limit` specialized to
   `D = intOrder` with `eq_or_ne` replaced by `Decidable.eq_or_ne`, measures `[propext]`. Chaining
   it forward: a copy of `taskRel_eq_iter` measures `[propext, Quot.sound]`; a copy of
   `respects_of_isStepPath` measures `[propext, Quot.sound]`; the `WorldHistory` constructor built
   on it measures `[propext, Quot.sound]`; and the full `mem_HF_iff_adjacent` biconditional measures
   `[propext, Quot.sound]`. **This is the key result of this research**: the SFT identification and
   every `H_F`-membership conclusion downstream of it can be choice-free.
2. **Computable successor from a decidable serial step.**
   `succOf R enum w := enum.find? (fun u => decide (R w u))` measures no axioms at all, and the
   totality lemma (`∃ u, succOf R enum w = some u ∧ R w u`, from `∀ v, v ∈ enum` and
   `∀ v, ∃ u, R v u`) measures `[propext, Quot.sound]`. This replaces the `Classical.choose` that
   `FrameOver.extend_periodic` uses at `PeriodicExtension.lean:176–177`.
3. **Choice-free pigeonhole on an enumerated carrier.** For `g : ℕ → W` with `[DecidableEq W]`,
   `enum : List W`, `∀ v, v ∈ enum`, and `enum.length < n`, there are `i < j < n` with `g i = g j`
   — proved by composing `List.idxOf` into `Fin enum.length` and applying the existing choice-free
   `Metalogic.Decidability.exists_dup_lt`. Measures `[propext, Quot.sound]`. This replaces
   `exists_repeat_of_card_le`, which is choice-carrying and whose statement mentions `Nat.card`.

### Paper anchor and provenance

The remark and footnote are in
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`. Precise location
and header, read this session:

- Header as it actually prints: `\section*{Categorical connections (cut from sub:Conclusion)}`
  (line 1035). The dispatch and `specs/TODO.md` both describe it as "under the header
  'moved from sub:Conclusion'", which is the *live paper's* description of it
  (`possible_worlds.tex:1956`), not the header string in the cut file. Docstrings should name the
  file and the printed header, not the paraphrase.
- The SFT sentence is at line 1045; the footnote follows at lines 1046–1052, citing
  `\cite{Lind2021}`.
- `possible_worlds.tex` retains only a `% PARAGRAPH CUT` record at line 1956. `grep -n "shift of
  finite type\|Lind2021" possible_worlds.tex` returns that comment line and nothing else.

Two stale records, both needing correction in this task:

- `BiLasso/Agreement.lean` lines 68–80 say "Verbatim, from the unanchored footnote in
  `JPL/possible_worlds.tex`" and quote a single run-on sentence. The cut file's footnote is now
  five separate sentences ("…without appeal to Zorn's lemma." / "Since $W$ is finite, …" / "Every
  bounded convex history therefore extends…" / "This licenses a finite certificate…" / "See Lind
  and Marcus~\cite{Lind2021}."). The content is unchanged; the quote is no longer verbatim and the
  file reference is wrong.
- `docs/reference/paper-definitions-of-record.md`'s "Untracked sources" §"The finite-case
  effectiveness footnote" (lines 2376–2404) gives **Location** as `JPL/possible_worlds.tex` line
  1648, carries the same run-on quote, and names
  `FormalSystem.Semantics.TaskFrame.extend_periodic` under **Relied on by**. The declaration is
  `FormalSystem.Semantics.FrameOver.extend_periodic` (namespace `FrameOver` opens at
  `PeriodicExtension.lean:133`). That entry is the right place to record the relocation, and the
  file's own rule — "verbatim in this tree's docstrings means verbatim *against this record file*"
  (lines 183–186) — means the record entry must be re-quoted **before** `Agreement.lean` is.

### Cross-references the dispatch asks docstrings to carry

- **Task 618's `D = ℤ` clause.** `specs/TODO.md:1473–1509`. The clause: iterating
  *Compositionality* identifies `⇒ₙ` with the `n`-fold composite of `⇒₁`, `⇒₀` is the identity, so
  a function on `[0, l]` is a convex history exactly when it is a length-`l` path in `(W, ⇒₁)`, and
  `Path(F)` is the free category on that graph. Nothing of `Path(F)` exists in the tree yet (task
  618 is `[NOT STARTED]`), so the docstring must describe the connection, not cite a declaration.
- **"Root paths of a finite class graph".** The exact phrase is **not** in `specs/ROADMAP.md`
  (`grep -n "root path" specs/ROADMAP.md` is empty). It occurs in `specs/TODO.md:1505`, in task
  618's "SEED RESEARCH AVAILABLE" note, forwarded from
  `specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §3. Related
  vocabulary is live in `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`
  ("ultimately periodic (lasso) root paths"). The dispatch's attribution of the phrase to
  `specs/ROADMAP.md` is therefore inexact; cite the durable anchor instead.
- **Authoring hazard.** `.claude/rules/no-task-references-in-deliverables.md` forbids "task 618" /
  "task 797" in any file outside `specs/**`. Every docstring connection above must be phrased by
  durable anchor — `cor:path-fibration`'s `D = ℤ` clause, the `RaySummary` README, the
  `PlusSlicedCertificate/Limits/` refutation record — never by task number.

### Recommendations

Prioritized; each is a candidate phase.

1. **Re-quote and repoint the provenance records first** (cheap, unblocks the "verbatim" label on
   everything downstream): update `docs/reference/paper-definitions-of-record.md`'s "Untracked
   sources" entry to `JPL/appendix_cut_material.tex`, its printed header, the re-split five-sentence
   text, and the corrected declaration name; then re-quote `BiLasso/Agreement.lean`'s module
   docstring against the record file.
2. **Deliver (1) choice-free, in `Semantics/`.** A new named theorem for `[Finite W]`
   (`[Fintype]`/enumeration not required for this one, since the statement need not mention a
   cardinal): the forbidden-2-block characterization `{f : ℤ → W | ∃ σ : WorldHistory F, σ.path = f}
   = {f | ∀ n, ¬ Forbidden (f n, f (n+1))}` with `Forbidden w u := ¬ F.step w u`, plus a
   `DecidablePred` instance for the block test under `[DecidableRel F.step]`. Route it through the
   scrubbed reflection chain (probe 1) so it measures `[propext, Quot.sound]`, and state the
   finiteness of the forbidden-block set separately so the "finite type" half of the name is earned
   rather than asserted.
3. **Deliver the Mathlib dictionary half of (1) as a separate, explicitly choice-carrying
   theorem.** Identify the same set with `SymbolicDynamics.FullShift.forbidden` at `G = ℤ`,
   `A = F.WorldState`, with the forbidden patterns supported on `{0, 1}`. Measure and record
   `[propext, Classical.choice, Quot.sound]` in the docstring, with the reason (Mathlib's
   `Pattern.occursInAt` and `forbidden` both carry it). Keep this strictly separate from (2) so the
   choice-free statement is not contaminated by an import-level dependency.
4. **Deliver (2) choice-free over a carrier-as-data frame.** Statement shape, forced by the
   measurements: `{F : FrameOver intOrder} [F.IsRegular] [DecidableEq F.WorldState]
   [DecidableRel F.step] (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)`, conclusion a
   `WorldHistory F` extending `τ`, ultimately periodic both ways with both periods
   `≤ enum.length`. Proof: probe 2 for the successor and predecessor, probe 3 for the two
   pigeonholes, probe 1's chain for the `H_F` conclusion. Target `[propext, Quot.sound]`, and pin
   it with a `#print axioms` guard test in `Tests/BimodalTest/` alongside the existing
   `PeriodicExtensionAxiomTest.lean`.
5. **Keep `FrameOver.extend_periodic` exactly as it is** and have the new theorem's docstring state
   the relationship: the `[Finite W]` version is the one the paper's hypothesis literally supports
   and is choice-carrying for a *measured* reason (`Nat.card` in its statement, `Classical.choose`
   for the successor); the carrier-as-data version is the choice-free strengthening. Do not
   attempt to derive one from the other — `PeriodicExtension.lean`'s docstring already explains why
   no such bridge exists, and the `Fintype.ofFinite` / `Finset.toList` measurements confirm it.
6. **Deliver (3) as a new module under `Metalogic/Decidability/`,** not under `Semantics/`
   (layering finding above). Build the certificate on `Periodic.unrollOf` at
   `α := F.WorldState` — never on `BiLasso.unrollOf`, which is choice-carrying and byte-stable.
   The decidable check is the conjunction of (a) coherence of the three segments against
   `DecidableRel F.step` over a `Fin`-indexed window, and (b) pointwise agreement with the bounded
   history. Soundness mirrors `PlacedBiLasso.extends_of_agrees`; completeness is recommendation 4's
   theorem returning the certificate as data. Promote `Agreement.lean`'s decidability `example`
   (lines 185–189) to a named instance in the new module rather than leaving the claim as an
   `example`.

## Decisions

- **Treat the dispatch's three deliverables as a re-scoping problem, not a greenfield build.** The
  report does not propose re-deriving `FrameOver.extend_periodic` or `PlacedBiLasso`; it proposes
  the named SFT statement, the choice-free restatement, the frame-level certificate, and the
  provenance repointing.
- **Choice-free means `[propext, Quot.sound]` here**, matching the precedent already set by
  `IntPresentation.orbit_repeat` and `exists_dup_lt`. `Quot.sound` is not treated as a defect.
- **The carrier arrives as data (`enum : List W`), not as `[Fintype W]`.** Forced by measurement:
  `Fintype.ofFinite`, `Finset.toList` and `Multiset.toList` all carry `Classical.choice`.
- **The period bound is `enum.length`, not `Nat.card W`.** Forced by the statement-level
  measurement of `Nat.card`.
- **No edit to `BiLasso/Basic.lean`,** and no attempt to execute `Periodic.lean`'s recorded
  retirement trigger (refactoring `Basic.lean` onto the generic decoding). That refactor is a
  separate, wider change and the hold on `Basic.lean` is relied on by concurrent work.
- **No sorry-deferral anywhere.** Every component of the recommended route has a compiled probe or
  an existing theorem behind it; nothing in this plan requires a placeholder.

## Risks & Mitigations

- **Risk: the scrubbed reflection law duplicates `FrameOver.reflection`.** Two lemmas proving the
  same biconditional, one general and choice-carrying, one `intOrder`-specific and choice-free.
  *Mitigation*: name the new one so the specialization is visible (e.g. `reflection_int`), and
  state in both docstrings that the difference is `eq_or_ne` versus `Decidable.eq_or_ne` and
  nothing else. Do **not** change the general `reflection` — `D` is an arbitrary ordered carrier
  there with no `DecidableEq`, so the substitution is not available in general.
- **Risk: the choice-free chain must be duplicated, not retrofitted.** `taskRel_eq_iter`,
  `respects_of_isStepPath`, `worldHistoryOfStepPath` and `mem_HF_iff_adjacent` are all consumed
  widely; replacing them in place would change the axiom profile of a large part of the tree and
  could break pinned `#print axioms` guard tests. *Mitigation*: add choice-free variants in a new
  module and leave the originals untouched; audit `Tests/BimodalTest/**` for pinned axiom
  expectations before any in-place edit is even considered.
- **Risk: `specs/` paths and task numbers leaking into docstrings.** The dispatch asks for
  connections that are currently recorded only in `specs/TODO.md`. *Mitigation*: cite paper anchors
  (`cor:path-fibration`, `thm:extension`), file paths under `FormalSystem/**` and `docs/**`, and
  the cut file by absolute path — never a task number.
- **Risk: adding `Mathlib.Dynamics.SymbolicDynamics.Basic` to the import set.** It is a new-module-system
  file whose declarations are only reachable under the full `SymbolicDynamics.FullShift.` prefix,
  and everything in it carries choice. *Mitigation*: confine the import to the dictionary module of
  recommendation 3; keep it out of the choice-free modules entirely.
- **Risk: a `Nat.card` sneaks back into a statement.** It is the single easiest way to silently
  lose choice-freeness, because the proof looks innocent. *Mitigation*: the guard test of
  recommendation 4 catches it, and the plan should name that test as a phase deliverable rather
  than an optional extra.
- **Risk: concurrency.** Five sibling research tasks are dispatched this cycle with no declared
  `file_scope`, and task 801 declares `docs/reference/paper-definitions-of-record.md` **in its own
  `file_scope`** (`.dispatch/3.md` Territory block). Recommendation 1 edits that exact file.
  *Mitigation*: this is an implementation-phase collision, not a research-phase one; the plan must
  either sequence recommendation 1 after task 801 lands or route the record-file edit through a
  re-read-immediately-before-editing discipline with single-file staging. Flag it explicitly in the
  plan rather than discovering it at commit time.

## Tactic Survey Results

No tactic survey was performed in the sense of `lean_multi_attempt` against an open goal: this
research produced no new proof obligations to discharge, and the three feasibility probes were
written out in full and compiled rather than searched for. What the probes did exercise, and the
outcome:

| Goal | Tactic / route | Result | Notes |
|---|---|---|---|
| reflection law at `intOrder`, choice-free | `rcases Decidable.eq_or_ne d 0` in place of `eq_or_ne` | success | `[propext]`; the whole scrub turns on this one substitution |
| `List.find?` returns `some` under an existence hypothesis | `List.find?_eq_none` (contrapositive) + `List.find?_some` | success | `[propext, Quot.sound]` |
| `List.idxOf` round-trip | `List.getElem_idxOf (xs := …) (x := …) (h : idxOf x xs < xs.length)` | success after one signature correction | the first attempt passed `(l := …) (a := …)` and the membership proof; the lemma takes `xs`/`x` and the index bound |
| pigeonhole transport `W → Fin enum.length` | `congrArg Fin.val` + `simp` | success | reuses `exists_dup_lt` rather than Mathlib's choice-carrying pigeonhole |

## Context Extension Recommendations

- **Topic**: how to read `#print axioms` when the *statement*, not the proof, carries an axiom.
- **Gap**: `.claude/context/project/lean4/` has `patterns/dependency-tracing.md` and
  `tools/comparator-guide.md`, but nothing states the rule that a constant appearing in a
  declaration's type contributes its axioms. The `Nat.card` measurement above is the cheapest
  possible demonstration and the trap is easy to fall into when a task asks for choice-freeness.
- **Recommendation**: add a short section to
  `.claude/context/project/lean4/patterns/dependency-tracing.md` recording the statement-versus-proof
  distinction, with the `Nat.card`/`rfl` one-liner as the worked case and a pointer to the
  choice-free alternatives measured here (`enum.length`, `Decidable.eq_or_ne`, `List.find?`,
  `exists_dup_lt`).

## Appendix

### Probe files (session scratchpad)

All under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/386211a6-9e8b-4e24-8a1c-ccc3e0dc9734/scratchpad/`:
`axprobe.lean`, `axprobe2.lean` … `axprobe12.lean`. Each was run as
`lake env lean <path>` from the repository root. `axprobe6.lean` holds the reflection-scrub chain;
`axprobe7.lean` holds the successor and pigeonhole probes; `axprobe9.lean` holds the two
statement-level measurements; `axprobe12.lean` holds the Mathlib `SymbolicDynamics` measurements.
These are ephemeral; the plan should relocate the three feasibility probes into
`specs/797_shift_finite_type_eventually_periodic_worlds/evidence/` if they are to be cited later.

### Searches and greps run

- `lean_local_search` for `Subshift` (index state `warming`; returned
  `SymbolicDynamics.FullShift.*` hits, used as positive evidence only)
- `grep -rni "shift of finite type\|shiftoffinitetype\|ShiftFinite\|SFT\b"` over `*.lean`/`*.md`
- `grep -rn "mem_HF_iff_adjacent\|saturation_of_finite\|extend_periodic"` over `*.lean`
- `grep -rn "byte-stable\|Held stable"` over `FormalSystem docs .claude/context`
- `grep -rn "fragment of a possible world"`, `grep -rn "root path"`
- `grep -rln "import FormalSystem.Metalogic" FormalSystem/Semantics/` (empty — the layering fact)
- `git log --oneline -5 --` on `BiLasso/{Agreement,Orbit}.lean`

### Documentation consulted

- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — the `Basic.lean` hold, the three
  recorded design decisions, the `fmp` refutation
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` module docstring — why no bridge from
  the `[Finite W]` theorem to the effective one exists
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` ON CHOICE section — the two residual
  choice sources, both confirmed by measurement and both avoidable via `Periodic.lean`
- `docs/reference/paper-definitions-of-record.md` — the "Untracked sources" convention and the
  "verbatim means verbatim against this record file" rule
