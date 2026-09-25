# Research Report: Task #674

**Task**: 674 - Document the countermodel-construction kit and the frame-level refutation criterion in `FormalSystem/Metalogic/Independence/README.md`
**Started**: 2026-09-25T00:00:00Z
**Completed**: 2026-09-25T00:00:00Z
**Effort**: Small (documentation-only; two new Markdown sections, no Lean edit, no rebuild)
**Dependencies**: Task 671 (the remaining-rows sharpness work that reconciled this README) — already landed; the reconciled file was read as it now stands
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Independence/` (README, `ZTimeSharpness.lean`, `DenseRTimeSharpness.lean`, `CoNotPriorU.lean`, `StaticFrame.lean`, `LoopingDuration.lean`, `ClockFrame.lean`), `FormalSystem/Semantics/Frames/Standard.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`, `FormalSystem/Metalogic/Conservativity.lean`
- Gate sources: `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`
- lean-lsp MCP `lean_run_code` — three verification probes, all elaborated end to end against the built tree
- Prior-round artifacts: `specs/670_minframeclass_sharpness_prior_uz_z1/reports/01_ztime-sharpness-countermodels.md`
**Artifacts**:
- `specs/674_document_countermodel_kit_and_refutation_criterion/reports/01_countermodel-kit-refutation-criterion.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The dispatch's "name line numbers" instruction and its "gates green" deliverable are in direct
  conflict, and the gate wins.** Check C20 tier 2 of `scripts/check-module-invariants.sh` is
  **gated by default** (`ENFORCE_C20=${ENFORCE_C20:-1}`) and its `publication_scope` predicate
  returns true for *every* `README.md` under `FormalSystem/`. The repository is currently at
  `PASS C20 tier 2: zero file.lean:NNN citations in publication-facing scope`. A single
  `Foo.lean:NNN` token in `Independence/README.md` — including a range like `CoNotPriorU.lean:13-45`,
  which the `CITE` regex reads as `CoNotPriorU.lean:13` — turns that check **red**. The two new
  sections must cite **declaration names plus bare file names**, never line numbers. That is also
  the README's existing house style throughout, and C20's own header states it as the standing
  convention.
- **The dispatch's GATE COUPLING paragraph is wrong about which gate is at risk.** The INV
  generated-inventory blocks count `.lean` files only (`scan()`/`live_files(directory, ".lean")`),
  so Markdown-only edits to this README cannot change a single count. Verified:
  `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 today and will still
  exit 0 after the edit. Regenerating is harmless but is not the gate that needs watching; C20 is.
- **One of the two "attractive dead end" frames is only half a dead end, and the README would
  install a false warning if it repeated the dispatch verbatim.** Machine-checked this round:
  the periodic clock frame **validates** `Axiom.z1` (probe `clock_validates_z1`, 9 lines, zero
  errors), but it **refutes** `Axiom.prior_UZ` — using `CoNotPriorU.lean`'s own `clockModel` arc
  valuation at time `0` (probe `clock_refutes_prior_UZ`, zero errors). The static frame is a
  genuine, already-landed validating dead end for `z1` (`static_validates_z1`).
- **One cited path does not exist.** `Metalogic/Conservativity/MinusLanguageSoundness.lean` is
  named by the dispatch and by `FormalSystem/Metalogic/Conservativity.lean`, but there is no such
  file. `minus_soundness_ztime_succ` is declared in `FormalSystem/MinusLanguage/Soundness.lean`.
  Writing the non-existent path into the README as a **dotted** module name would additionally
  fail check C5, which scans every non-`specs` Markdown file in the repository.
- **Everything else the dispatch asserts checks out.** All declaration names, both shape pins, the
  `by decide` / `<` fact, the translation-frame realisation layer, and the frame-versus-model
  criterion were verified against the tree. Recommended approach: two new `##` sections placed
  between `## Key Results` and `## Dependencies`, name-cited only, followed by
  `--emit-inventory` and the two gate runs. No `lake build` is required and none should be run.

## Context & Scope

Researched: whether every declaration, path and claim the dispatch asks the README to carry still
resolves against the tree; which repository gates the edit actually couples to and in which
direction; and what the two sections must say to be actionable without opening any originating
task's artifacts.

Out of scope and honoured: no `.lean` file is to be edited, no theorem added or restated, no root
`.context/` directory, and no write into the agent-system source store. Nothing below recommends
any of those. This report also does not write the README; it supplies the verified material and
the gate procedure for the implementation round.

## Findings

### Codebase Patterns

**1. The construction kit: verified declaration inventory.**

Every name below was resolved against the tree this round. Line numbers are given **here, for the
plan's convenience only** — see Finding 6 for why none of them may appear in the README.

| Declaration | Declared in | Line | Role in the kit |
|---|---|---|---|
| `translationFrame` | `FormalSystem/Semantics/Frames/Standard.lean` | 73 | `W = ↑D`, `w ⇒_x u ↔ u = w + x`; the default countermodel carrier |
| `translationFrame_isRegular` | `FormalSystem/Semantics/Frames/Standard.lean` | 103 | global instance ⇒ the `Sat .Base` side condition is `inferInstance` |
| `translationFrame_taskRel` | `FormalSystem/Semantics/Frames/Standard.lean` | 106 | `@[simp]` unfolding of the task relation |
| `translationHist` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 117 | the reference history, the identity `t ↦ t`, total |
| `translationModel` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 124 | values *every* atom by membership in an arbitrary `A ⊆ ↑D` |
| `translationModel_atom` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 129 | `@[simp]`, `Iff.rfl` |
| `translation_realizes` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 141 | atom truth at `t` ⟺ `t ∈ A` |
| `translation_realizes_allPast` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 146 | `Hp` at `u` ⟺ `∀ r < u, r ∈ A` |
| `translation_realizes_allFuture` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 153 | `Gp` at `u` ⟺ `∀ r, u < r → r ∈ A` |
| `noMaxOrder_of_duration` | `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 86 | plain lemma, **not** an instance; both refutations open with `haveI := noMaxOrder_of_duration D` |
| `not_validOn_prior_UZ_dense` | `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` | 179 | frame-level refutation at arbitrary `[DenselyOrdered ↑D]` |
| `not_validOn_z1_dense` | `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` | 208 | same, for `z1` |
| `ztimeSharpOrder` | `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` | 252 | `TemporalOrder.of ℚ`; the name avoids `qD`, already taken in `FormalSystem.Metalogic` |
| `eq_base_of_lt_ztime` | `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` | 160 | `.Base` is the unique class strictly below `.ZTime` |
| `eq_base_of_lt_dense` | `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` | 132 | the `.Dense` analogue |
| `base_or_dense_of_lt_rtime` | `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` | 142 | the `.RTime` analogue |
| `static_validates_z1` | `FormalSystem/Metalogic/Independence/StaticFrame.lean` | 312 | the landed proof that the static frame is a **validating** dead end for `z1` |
| `clockFrame` | `FormalSystem/Metalogic/Independence/ClockFrame.lean` | 171 | `W = ℚ ⧸ ℤ` under translation |
| `clockFrame_looping`, `truthAt_add_period`, `truthAt_add_nsmul` | `FormalSystem/Metalogic/Independence/LoopingDuration.lean` | 215, 123, 130 | the periodicity engine behind the clock-frame dead end |
| `clockModel`, `clock_atom_truth`, `ArcTime` | `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` | 113, 121, 118 | the arc valuation the `prior_UZ` probe reuses |

Semantic anchors, all confirmed: `TaskFrame.ValidOn` (`Semantics/Validity.lean`, 255),
`ValidOnFrames` (337), `ValidIn` (348), and the atom clause `M.valuation (τ.state t) p`
(`Semantics/Truth.lean`, 234). `FrameClass.Sat` reads `.Base ↦ IsRegular`,
`.Dense ↦ IsRegular ∧ IsDense`, `.ZTime ↦ IsRegular ∧ IsZTime`, `.RTime ↦ IsRegular ∧ IsRTime`
(`Semantics/FrameClassValidity.lean`). That is what makes the side conditions one-liners at each
class, exactly as `ZTimeSharpness.lean` spells them: `inferInstance` at `.Base`,
`⟨inferInstance, inferInstance⟩` at `.Dense`, and
`⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩` at `.RTime`.

**2. The kit really does bypass the machinery it was expected to need — confirmed from the import
list, not from prose.** `ZTimeSharpness.lean`'s entire import list is
`Semantics.Correspondence.DurationFrames`, `Metalogic.Soundness` and
`Semantics.Correspondence.RigidityReal`. `Metalogic/Conservativity/Z1Countermodel.lean`,
`Semantics/LexCarrier.lean` and the L⁻ soundness family are absent from it. The file additionally
carries a live import-ordering hazard worth documenting in the kit: importing
`FormalSystem.Metalogic.DedekindNonCompactness` reintroduces an `Ambiguous term realOrder` error,
because that module declares a second `realOrder` in a namespace `ZTimeSharpness.lean` also opens
(recorded in its own import block).

**3. The `tr_ne_untl` obstruction is real, and the fallback route's paths need correcting.**
`MinusLanguage.tr_ne_untl` is declared in `FormalSystem/MinusLanguage/Translation.lean` (112) and
is a `@[simp]` theorem. The paragraph documenting the obstruction is in
`FormalSystem/Metalogic/Conservativity.lean` at lines **135-138**, not 139-143 as the dispatch
states. `not_minus_derivable_z1` is in `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean`
(172) over the carrier `ℚ ×ₗ ℤ` from `FormalSystem/Semantics/LexCarrier.lean`.
**`Metalogic/Conservativity/MinusLanguageSoundness.lean` does not exist**; the theorem it is
credited with, `minus_soundness_ztime_succ`, is declared in
`FormalSystem/MinusLanguage/Soundness.lean` (503), with the empty-context form at 535. Two live
docstrings already carry the bad path (`Metalogic/Conservativity.lean` 127 and
`Metalogic.lean` 100); repeating it in the README would propagate it into a third, gated surface.

**4. The frame-versus-model criterion, located exactly.** `CoNotPriorU.lean`'s module docstring
runs lines 13-57; the obstruction is its `## Why this is a statement about a model, not a frame`
section, lines **30-38** (the dispatch's "13-45" spans the docstring start and overshoots the
section). Its content, verbatim in substance: `def:frame-validity` quantifies over **all**
valuations, so on a densely ordered flow rich enough to realize an arbitrary set of times,
frame-validity of `CO` already forces gap-freeness and hence forces Prior-U valid too; no
frame-level countermodel can exist for any frame whatever, and the theorem is therefore stated
over a fixed `TaskModel`, matching Reynolds' printed caveat (1992, p.169).

The criterion that dissolves the over-generalization is already written down once, in
`ZTimeSharpness.lean`'s own `## The frame-versus-model obstruction does not bite here` section
(lines 58-66): *the obstruction arises only because that statement must simultaneously **validate**
something while refuting something else; a bare non-validity claim validates nothing.* The README's
`## Key Results` entry for `prior_UZ_minFrameClass_sharp` already carries a one-clause version of
it. Section 2's job is to promote that from a per-module aside to a stated criterion, with the
consequence spelled out: the unobstructed statement form is the frame-level
`¬ F.ValidOn φ` / `¬ ValidIn fc φ`, which is **strictly stronger** than the model-fixed form, and
it should be chosen before the proof starts rather than discovered mid-proof.

**5. The two "hard-won specifics" beyond the frames, both verified.**

- *Non-discreteness, not non-Archimedean-ness.* `not_validOn_prior_UZ_dense` and
  `not_validOn_z1_dense` are stated at `(D : TemporalOrder) [DenselyOrdered (D : Type)]`, so one
  lemma per axiom yields `.Base`, `.Dense` and `.RTime` by three instantiations (`ztimeSharpOrder`
  twice, `realOrder` once). The README's result 10 already says "discreteness, not the Archimedean
  property"; the kit section should say *why that pays*: genericity in `D` is what converts one
  construction into several frame classes. The non-Archimedean discrete carriers are the different
  story told by `LexIntWitness.lean`.
- *Schematic `∀ φ` non-validity can be outright false, so pin the shape.* `Axiom.prior_UZ ⊥` has an
  unsatisfiable antecedent and **is** `.Base`-valid, which falsifies the `∀ φ` form of both the
  `.Base` results and both biconditionals — hence every statement is at `Formula.atom p`.
  `ZTimeSharpness.lean` carries two anonymous shape pins (144, 147-149) and
  `DenseRTimeSharpness.lean` three (114, 117-118, 121-123), each of the form
  `example (φ : Formula) : Axiom (...) := Axiom.<ctor> φ`. Worth carrying into the section: the
  `prior_UZ` pin also settles a genuine reading trap — `Axioms.lean`'s prose renders the axiom
  `F(φ) → U(φ, ¬φ)`, argument-reversed relative to the constructor's `Formula.untl φ.neg φ`,
  because the prefix `U(e, g)` rendering is deliberately event-first while the constructor and the
  infix `φ U ψ` are guard-first.
- *`by decide` fails on `FrameClass` `<`.* Verified by probe: `by decide` on
  `¬ (FrameClass.Dense < FrameClass.ZTime)` errors with
  `failed to synthesize Decidable ¬FrameClass.Dense < FrameClass.ZTime`, while the `≤` form
  decides. Cause: `Axioms.lean` registers `DecidableRel (LE.le : FrameClass → FrameClass → Prop)`
  (566) and no counterpart for `<`, which comes from `PartialOrder`'s default
  `lt a b := a ≤ b ∧ ¬ b ≤ a` and is not reached by instance search. The workaround in the tree is
  `absurd h.le (by decide)`, used in all three order facts. **This is already documented** in
  `DenseRTimeSharpness.lean`'s `## Order facts` section comment; the README section should cite
  that as the written-down place rather than restating it as new.

**6. Gate analysis — the actual coupling, measured.**

Baseline, captured this round on the current tree:

| Command | Result | Wall time |
|---|---|---|
| `bash scripts/check-module-invariants.sh` | `ALL CHECKS PASSED` (exit 0) | 1m41s |
| `bash scripts/check-module-invariants.sh --emit-inventory --check` | `PASS INV` (exit 0) | ~1s |
| `bash scripts/readme-lint.sh` | `RESULT: PASS` (exit 0) | ~2s |

`C1 lake build exits 0` passed inside that 1m41s, i.e. the tree is already built and the full gate
needs no rebuild. The dispatch's BUILD COST paragraph is correct.

Checks the edit couples to, in priority order:

- **C20 tier 2 — BLOCKING, and the one real risk.** `ENFORCE_C20` defaults to `1`.
  `publication_scope(p)` returns `True` when `os.path.basename(p) == "README.md"` and
  `p.startswith("FormalSystem/")`, with only `FormalSystem/Metalogic/WeakCanonical/**` excluded.
  The current count in that scope is **zero**. `CITE` is
  `\b((?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):(\d+)\b`, so `ZTimeSharpness.lean:179`,
  `CoNotPriorU.lean:30-38` and `Conservativity.lean:135` all match. **No line numbers in the new
  sections.**
- **C20 tier 1 and the declaration-span assertion** — moot once tier 2 is respected, since neither
  reads a citation that carries no `:NNN`.
- **C5 — module-shaped Markdown paths.** Scans every `.md` file outside `.git`, `.lake`, `specs`,
  `Boneyard`, `build`; every dotted `FormalSystem.*` name must resolve to a real file or directory.
  Slash paths are *not* read by C5, so `FormalSystem/Semantics/Frames/Standard.lean` is safe while
  `FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness` would fail.
- **C9 — zero task-number citations under `FormalSystem/`**, `.md` included. The new sections must
  cite durable anchors (declaration names, file names, section headings) and never a task number,
  a report path or a `specs/` path.
- **INV — not at risk.** `scan()` collects `live_files(directory, ".lean")` only; descriptions are
  carried over from the existing block. A Markdown-section addition changes nothing it measures.
  Run `--emit-inventory` anyway as belt-and-braces; it is idempotent and takes about a second.
- **`readme-lint.sh` — only two gated checks.** Check 1 (directory has a README) is unaffected.
  Check 3 resolves `[text](path)` links relative to the README's directory; the existing
  `[Metalogic README](../README.md)` and `[Theorems README](../../Theorems/README.md)` pass, and
  any new link must too. Checks 2 and 4 are reported, never gated — `STALE DATE` for this README
  is already present on the clean baseline.

**7. Present state of the README, read as it now stands.** 214 lines. Structure: untitled preamble
with the reconciled **eleven**-result numbered list (1-71), four explanatory paragraphs on results
2/3, 6, 9 and 7/8, the shared four-step recipe paragraph (103-107), `## Modules` wrapping the sole
generated inventory block (111-139), `## Key Results` (141-193), `## Dependencies`,
`## Related Documentation`, then **two** trailing verification stamps — `**Last verified**:
2026-09-24` at 210 and `*Last verified: 2026-09-24*` at 214. The duplication is pre-existing.

### External Resources

No external search was needed or performed: both sections are anchored entirely to this
repository's declarations, which is the dispatch's own stated reason for siting them here. The one
literature anchor involved — Reynolds 1992, p.169 — is already quoted inside `CoNotPriorU.lean`'s
docstring and should be cited from there rather than re-fetched. No Mathlib lemma is needed.

### Recommendations

**R1 — Cite names, never lines.** Use the README's existing house style throughout:
`` `not_validOn_prior_UZ_dense` (`ZTimeSharpness.lean`) ``. Where a *section* of a docstring is the
target, name the section heading — e.g. "`CoNotPriorU.lean`'s *Why this is a statement about a
model, not a frame*" — which is both C20-safe and more durable than a line range. This satisfies
the dispatch's real requirement (a reader can act without opening any task artifact) while keeping
C20 green; the dispatch's literal "line numbers" instruction cannot be honoured and should not be.

**R2 — Section 1 outline (the kit), as two graded routes plus three specifics.**

1. *Default route.* `translationFrame D` + `translationHist D` + `translationModel D A`, with
   `translation_realizes` / `translation_realizes_allPast` / `translation_realizes_allFuture` as
   the ready-made atom-realisation bridges. Why it is the default: atoms are valued on world
   *states*, so a time-varying atom needs a history whose state varies with time, and the identity
   reference history is exactly that; `translationFrame_isRegular` is a global instance, so the
   `Sat` side condition is `inferInstance` at `.Base` and a pair/triple of them at the other
   classes. State the four-line recipe: pick `A`, take `h (translationModel D A) (translationHist D) 0`,
   rewrite with the realisation lemma, derive the contradiction. Note the
   `haveI := noMaxOrder_of_duration D` opener (a plain lemma, deliberately not an instance) and the
   `DedekindNonCompactness` / `realOrder` import hazard.
2. *Fallback route, named as such.* The L⁻ transfer — `Z1Countermodel.lean`,
   `minus_soundness_ztime_succ` (in `MinusLanguage/Soundness.lean`), the `ℚ ×ₗ ℤ` carrier from
   `LexCarrier.lean` — is a real and landed result, but it is the fallback, because anything
   transferred across `MinusLanguage.tr` meets the `tr_ne_untl` obstruction
   (`Formula.someFuture` is a top-level `untl`; nothing in the range of `tr` is). Because the
   default route never leaves the native language, that obstruction never arises at all.
3. *Dead ends, stated accurately* — see R3.
4. *Non-discreteness is the property doing the work*, and genericity in `D` is what turns one
   construction into several frame classes.
5. *Pin the shape*: the `∀ φ` form can be false (`Axiom.prior_UZ ⊥`), so state results at
   `Formula.atom p` and add anonymous `example` pins; two to copy in `ZTimeSharpness.lean`, three
   in `DenseRTimeSharpness.lean`. Mention the guard-first/event-first rendering trap.
6. *`by decide` fails on `FrameClass` `<`*, with `absurd h.le (by decide)` the idiom, citing
   `DenseRTimeSharpness.lean`'s `## Order facts` note as the written-down place.

**R3 — State the dead ends as they actually are, not as a symmetric pair.** Recommended wording,
grounded in this round's probes:

- The **static frame** (`FrameOver.staticFrame`, `StaticFrame.lean`) has time-invariant truth and
  **validates `Axiom.z1` outright** — that is the landed theorem `static_validates_z1`, and
  `LexIntWitness.lean` depends on it. An agent reaching for it to refute `z1` will prove a true
  theorem about a different question. The trap is live because `LexIntWitness.lean`'s presence
  makes the non-Archimedean carrier look like the obvious starting point.
- The **clock frame** (`clockFrame`, `ClockFrame.lean`) is a dead end for **`z1` only**. Its
  period-1 truth (`clockFrame_looping`, `truthAt_add_period`, `truthAt_add_nsmul`) makes `Gφ`
  time-independent over the Archimedean `ℚ`, so `FGφ → Gφ` holds and `z1` is validated — probed
  and machine-checked this round in about nine lines, though no such theorem is currently in the
  tree. It is **not** a dead end for `prior_UZ`: the arc valuation `clockModel` already in
  `CoNotPriorU.lean` refutes `Axiom.prior_UZ`'s atomic instance at time `0`, also machine-checked
  this round. What rules the clock frame out for `prior_UZ` is cost, not validity — it is pinned to
  `ℚ` and a quotient carrier, where the translation frame delivers both axioms from one generic
  lemma each at arbitrary dense `D`.

  If the implementation round prefers not to assert an unformalized validity claim, the
  conservative alternative is to state the *mechanism* ("periodicity makes `Gφ` time-independent,
  so `z1` cannot be refuted here") and cite `clock_allPast_imp_allFuture` and `truthAt_add_nsmul`,
  without claiming a theorem name that does not exist. Either way the section must not say the
  clock frame validates both targets, which is false.

**R4 — Section 2 outline (the criterion).** Three beats: (i) what `CoNotPriorU.lean` records and
why — all-valuations quantification, gap-freeness forced, Reynolds' own caveat, hence a fixed
`TaskModel`; (ii) the criterion — *the obstruction bites only when a statement must simultaneously
**validate** something on a valuation-rich flow; a bare non-validity claim validates nothing and is
unobstructed*; (iii) the operational consequence — choose the statement form before starting the
proof; frame-level `¬ F.ValidOn φ` is available and strictly stronger than the model-fixed form,
and that is exactly the form all four `.ZTime` and all four `.Dense`/`.RTime` non-validity results
take. Close by naming the failure mode being prevented: reading the `CoNotPriorU` docstring
narrowly as a general prohibition on frame-level refutation.

**R5 — Placement and mechanics.** Insert both sections as `##` headings between `## Key Results`
and `## Dependencies`; this leaves the generated inventory block and the numbered result list
untouched. Suggested headings: `## Building a countermodel: what to reach for first` and
`## When frame-level refutation is obstructed, and when it is not`. Bump both trailing
`Last verified` stamps to the edit date; consider collapsing the duplicate pair into one while
there, and if in doubt leave both (the duplication is pre-existing and neither gate reads it).

**R6 — Verification order for the implementation round.** (1) Write the sections. (2)
`bash scripts/check-module-invariants.sh --emit-inventory` — about a second, expected to be a
no-op. (3) `bash scripts/readme-lint.sh` — expect `RESULT: PASS`. (4)
`bash scripts/check-module-invariants.sh` — about 1m41s, expect `ALL CHECKS PASSED`; if C20 tier 2
reports a nonzero count, a line number slipped in. (5) Do **not** run `lake build`; if a rebuild
looks necessary, something has left this task's scope. A detached, guarded waiter
(`context/patterns/bounded-build-waiter.md`) is unnecessary at these runtimes, but the full
invariants run is the one command worth backgrounding if the session is tight.

## Decisions

- **D1**: Line numbers are excluded from the README deliverable, against the dispatch's literal
  wording, because C20 tier 2 is gated and the same dispatch requires the gate green. Resolvable
  from the artifacts without user input: the dispatch's own stated purpose for line numbers —
  actionability without opening task artifacts — is fully served by declaration names, and C20's
  header states that a name survives every edit a line number does not. The line numbers are
  preserved in Finding 1 of this report for the plan's use.
- **D2**: The clock-frame dead-end claim is narrowed to `z1` and the `prior_UZ` half is corrected,
  on the strength of two machine-checked probes rather than on either the dispatch's or the prior
  round's prose.
- **D3**: `Metalogic/Conservativity/MinusLanguageSoundness.lean` is not to be cited. The fallback
  route cites `FormalSystem/MinusLanguage/Soundness.lean` for `minus_soundness_ztime_succ`.
- **D4**: The dispatch's INV warning is recorded as a non-risk and the `--emit-inventory` step is
  kept anyway, as a cheap no-op that costs a second and removes the question.
- **D5**: The `by decide` / `<` fact is cited to `DenseRTimeSharpness.lean`'s existing `## Order
  facts` note rather than restated as a discovery, so the README points at the durable place.
- **D6**: No new theorem is proposed. The two probes written this round stay in this report; the
  task is documentation-only and landing `clock_validates_z1` would be a Lean edit outside scope.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| A line number slips into the README and C20 tier 2 fails | R1; the full invariants run in R6 step 4 catches it, and the fix is mechanical (drop the `:NNN`, keep the name) |
| The section repeats the dispatch's clock-frame claim verbatim and installs a false warning | R3 supplies corrected wording backed by two probes |
| A dotted `FormalSystem.*` module name for a non-existent file breaks C5 | Prefer slash paths and bare file names; never write `...MinusLanguageSoundness` in dotted form |
| A task number or `specs/` path is cited for provenance and breaks C9 | Cite declaration names and section headings only; the origin round is not a durable anchor |
| The two sections drift into restating theorems, breaching SCOPE | Both sections are navigational: what to reach for, what to avoid, which statement form to choose. No theorem statement is reproduced beyond naming it |
| The reconciled README is assumed to have its pre-reconciliation shape | Finding 7 records the file as it now stands: eleven results, one inventory block, two trailing stamps |
| An implementer runs `lake build` "to be safe" and burns a full rebuild | R6 step 5; the gate's own C1 already passed inside the 1m41s baseline with no rebuild |

## Tactic Survey Results

Three `lean_run_code` probes were run against the built tree; the survey protocol was invoked only
to settle factual claims the README will carry, not to search for a proof.

| Goal | Tactic / route | Result | Premises / Config |
|---|---|---|---|
| `¬ (FrameClass.Dense ≤ FrameClass.ZTime)` | `decide` | success | `Axioms.lean`'s `DecidableRel (LE.le ...)` |
| `¬ (FrameClass.Dense < FrameClass.ZTime)` | `decide` | **fail** — `failed to synthesize Decidable ¬FrameClass.Dense < FrameClass.ZTime` | no `DecidableRel (· < ·)` instance; use `absurd h.le (by decide)` |
| clock frame validates `Axiom.z1` (`clock_validates_z1`) | `intro` / `Truth.some_future_iff` / `Truth.future_iff` / `truthAt_add_nsmul` / `exists_nat_gt` / `simp only [nsmul_eq_mul, mul_one]` / `linarith` | success, zero errors | `clockFrame_looping`; Archimedean `ℚ` |
| clock frame refutes `Axiom.prior_UZ` at `0` (`clock_refutes_prior_UZ`) | `Truth.imp_iff` / `Truth.some_future_iff` / `Truth.neg_iff` / `clock_atom_truth` / `arcTime_of_abs_lt` / `quarter_lt_arcRadius` / `lt_min` / `linarith` | success, zero errors | `clockModel` arc valuation, witness time `1/8`, guard-breaker `min s (1/8) / 2` |

No MCP tool failed and no rate limit was reached; `lean_local_search`, `lean_leansearch`,
`lean_loogle` and `lean_state_search` were not needed, since every name in scope is local and was
resolved by direct file reads.

## Context Extension Recommendations

- **Topic**: The C20 tier-2 constraint on `FormalSystem/**/README.md`.
  **Gap**: The rule that no `file.lean:NNN` citation may appear in any README under `FormalSystem/`
  is enforced mechanically and by default, but is written down only inside
  `scripts/check-module-invariants.sh`'s C20 header. A dispatch asked for line numbers in exactly
  such a README this round, and nothing short of reading the gate script would have caught it.
  **Recommendation**: add a short "cite names, not lines, in publication-facing surfaces" note to
  the Lean extension's documentation-conventions context, listing the publication scope
  (`README.md`, `docs/`, `typst/`, every `FormalSystem/**/README.md`, and the three named
  aggregators) and the `absurd`-style repair. This one is genuinely repository-independent enough
  to be worth the extension, unlike the two sections this task delivers.
- **Topic**: The two stale `Metalogic/Conservativity/MinusLanguageSoundness.lean` docstring
  citations (`Metalogic/Conservativity.lean` and `Metalogic.lean`).
  **Gap**: A path that resolves to nothing, currently invisible to C4 (imports only), C5 (dotted
  names only) and C20 (needs a `:NNN`).
  **Recommendation**: not part of this task — it would require editing `.lean` files, which SCOPE
  forbids. Worth a separate small task to repoint both at
  `FormalSystem/MinusLanguage/Soundness.lean`.

## Appendix

**Searches and probes used**

- File reads: `FormalSystem/Metalogic/Independence/README.md` (full), `ZTimeSharpness.lean` (full),
  `CoNotPriorU.lean` (docstring + valuation layer + declaration index), `StaticFrame.lean`
  (docstring + `static_validates_z1`), `LoopingDuration.lean` (docstring + declaration index +
  clock instances), `DenseRTimeSharpness.lean` (shape pins + order-facts note),
  `Semantics/Frames/Standard.lean` (full), `Semantics/Correspondence/DurationFrames.lean`
  (docstring + realisation layer), `ProofSystem/Axioms.lean` (`FrameClass`, `LE`, `DecidableRel`,
  `PartialOrder`, order-shape pins), `Semantics/FrameClassValidity.lean` (`Sat` anchors),
  `Metalogic/Conservativity.lean` (the `tr_ne_untl` paragraph).
- `grep` sweeps for `prior_UZ` / `Axiom.z1` / `static_validates_z1` / `minus_soundness_ztime_succ`
  / `tr_ne_untl` across `FormalSystem/`.
- Gate sources read: `scripts/check-module-invariants.sh` (check catalogue, `scan()`,
  `render_block()`, the full C20 block, `publication_scope`), `scripts/readme-lint.sh` (all four
  checks and their gating).
- Gate runs: `--emit-inventory --check`, `readme-lint.sh`, and the full invariants suite; all three
  green, timings in Finding 6.
- `lean_run_code` probes: the `decide` pair, `clock_validates_z1`, `clock_refutes_prior_UZ`.

**Probe source, `clock_validates_z1`** (elaborated with zero errors; recorded here, not landed)

```lean
theorem clock_validates_z1 (M : TaskModel clockFrame) (φ : Formula)
    (τ : WorldHistory clockFrame) (t : ℚ) :
    TruthAt M τ t ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  intro _hstep hbase
  rw [Truth.some_future_iff] at hbase
  obtain ⟨s, _hts, hGs⟩ := hbase
  rw [Truth.future_iff] at hGs ⊢
  intro u hu
  obtain ⟨n, hn⟩ := exists_nat_gt (s - u)
  refine (truthAt_add_nsmul M clockFrame_looping φ τ u n).mpr (hGs _ ?_)
  simp only [nsmul_eq_mul, mul_one]
  linarith
```

**Probe source, `clock_refutes_prior_UZ`** (elaborated with zero errors; recorded here, not landed)

```lean
theorem clock_refutes_prior_UZ (a : Atom) :
    ¬ TruthAt clockModel clockHistory (0 : ℚ)
        ((Formula.atom a).someFuture.imp
          (Formula.untl (Formula.atom a).neg (Formula.atom a))) := by
  intro h
  have harc : ∀ r : ℚ, 0 < r → r ≤ 1/8 → ArcTime r := by
    intro r hr1 hr2
    refine arcTime_of_abs_lt r ?_
    have hq := quarter_lt_arcRadius
    have hc : ((r : ℚ) : ℝ) ≤ ((1/8 : ℚ) : ℝ) := by exact_mod_cast hr2
    push_cast at hc
    have h0 : (0 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr1.le
    rw [abs_of_nonneg h0]; linarith
  have hant : TruthAt clockModel clockHistory (0 : ℚ) (Formula.atom a).someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨1/8, by norm_num, (clock_atom_truth a _).mpr (harc _ (by norm_num) le_rfl)⟩
  rw [Truth.imp_iff] at h
  obtain ⟨s, h0s, _hps, hguard⟩ := h hant
  set r : ℚ := min s (1/8) / 2 with hr
  have hm : 0 < min s (1/8) := lt_min h0s (by norm_num)
  have h1 : min s (1/8) ≤ s := min_le_left _ _
  have h2 : min s (1/8) ≤ 1/8 := min_le_right _ _
  have hrpos : 0 < r := by simp only [hr]; linarith
  have hrs : r < s := by simp only [hr]; linarith
  have hr8 : r ≤ 1/8 := by simp only [hr]; linarith
  have hne := hguard r hrpos hrs
  rw [Truth.neg_iff] at hne
  exact hne ((clock_atom_truth a r).mpr (harc r hrpos hr8))
```

**Documentation references**

- `scripts/check-module-invariants.sh` — C5, C9, C20 (both tiers plus the declaration-span
  assertion), and the `--emit-inventory` generator
- `scripts/readme-lint.sh` — Checks 1 and 3 are gated; 2 and 4 are reported
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — module docstring sections
  *What is refuted is discreteness, not the Archimedean property*, *The `z1` half has an antecedent
  in the neighbouring L-minus language*, *The frame-versus-model obstruction does not bite here*,
  and *Scope*; together these are the closest existing prose to both new sections and the best
  source to compress from
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` — *Why this is a statement about a model,
  not a frame*, including the Reynolds 1992 p.169 quotation
- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — *Shape pins* and *Order facts*
