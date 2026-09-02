# Implementation Plan: Frame property representation and validity names

- **Task**: 522 - Frame property representation and validity names
- **Status**: [IMPLEMENTING]
- **Effort**: 17.5 hours
- **Dependencies**: 518, 519, 521 (all landed; 519's `DenseValidity.lean` deletion and 521's truth
  simp-normal form are preconditions and are satisfied)
- **Research Inputs**: `specs/522_frame_property_representation_and_validity_names/reports/01_frame-property-representation-validity-names.md`
- **Artifacts**: plans/01_frame-property-validity-names.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Fix the frame-property representation so that a `FrameClass.Sat` hypothesis feeds Lean's instance
cache directly, then collapse the class-specific binder-adapter family that exists only because it
does not. The representation fix is two edits (`abbrev TaskFrame.IsDense`, `@[reducible]
FrameClass.Sat`); everything else — a `sat_intro` macro, ~60 call-site migrations folded together
with the intro-chain normalisation, the deletion of 47 adapters down to 12 generic ones, two BL
transfer theorems, and two rename passes — follows from it. Definition of done: `lake build` green
with no new `sorry` and no new axiom, the restated acceptance criteria of research §8 all
satisfied, and the C2/C14 module invariants unchanged.

### Research Integration

The research report is authoritative wherever it conflicts with the task description; the plan
follows the report. Load-bearing corrections carried into the phases below:

1. **`abbrev IsDense` alone is insufficient.** `FrameClass.Sat` is a non-reducible `def` sitting
   *above* `IsDense` in the whnf chain and blocks instance-cache registration by itself
   (machine-checked: E1d FAIL, E2a PASS). Both must change together. Phase 1.
2. **The task's `structure TaskFrame.IsSuccArchDiscrete (F) : Prop where [succ : SuccOrder …]`
   does not compile** — Lean cannot project a `Type`-valued field from a `Prop`-valued structure.
   The existing existential already suffices once `Sat` is reducible. Phase 1/2 (decision D2).
3. **`47 → 2 (+2 BL)` is unachievable.** The 47 span three carriers and the bare-predicate
   `ValidOnFrames` layer needs its own generic triple. Measured target: **47 → 12**, plus a bonus
   `SatisfiableSet` 4 → 1. Phases 3 and 7.
4. **Census figures in the brief are stale.** Intro-chains: 148 in 31 spellings (not 231/44).
   `valid`: 106 code-only, ~18 of them an unrelated `Automation` `FormulaLabel.valid` (not ~200).
   Warning sites: 15 across 11 files (not nine across six). `Validity.lean` line anchors are
   ~+15. `SoundnessLemmas/DenseValidity.lean` no longer exists.
5. **The "grep finds one 'Read this first' paragraph" acceptance test is already vacuously
   satisfied** and is replaced by a checkable substitute (Phase 9 / Phase 11).
6. **Seven of the eight proposed axiom-validity target names already exist** in
   `FormalSystem.Metalogic`, three of them as one-line re-exports of the `SoundnessLemmas` names
   being renamed into them. This is decision D4 below, not an accident to discover mid-rename.
7. **Three rename hazards**: identifier-exact matching against the unrelated `HasDedekind*`
   canonical layer (118 declared identifiers contain `Dedekind`); only ~17 of 581 `h_mem`
   occurrences are the validity binder; ~18 `valid` occurrences belong to `Automation`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` contains no item this task advances directly — it is engineering hygiene from
the 2026-09-01 Lean-engineering review, not a theorem-coverage milestone. The roadmap does
*constrain* it: the C2 axiom baseline and the C14 stale-literal scan (ROADMAP.md around `:364` and
`:378`) pin eight theorem names and forbid introducing a `14/21/42/44 axiom` literal in docstrings.
Research verified that **none of the eight pinned names is renamed by this task**. This plan is
read-only with respect to ROADMAP.md and must not modify it.

## Decisions Taken (research §9 open questions, resolved)

| # | Question | Decision |
|---|----------|----------|
| D1 | Plan A (`@[reducible] Sat`) or Plan B (`Sat` unchanged) for the representation fix? | **Attempt Plan A.** It is what the task asks for and it is cleaner. The full detached build at the end of Phase 1 is the only oracle. If it regresses, fall back to Plan B (`abbrev IsDense` only, `sat_intro` gains a `haveI : DenselyOrdered _` branch) and record the fallback in the Phase 1 completion note. Both variants are machine-checked PASS at all four tags. |
| D2 | `IsSuccArchDiscrete`: existential, `structure`, or `inductive`? | **Leave the existential unchanged (research §2.2a).** The task's literal `structure` instruction is impossible in Lean. `inductive` (§2.2b) compiles but buys only `⟨⟩`-introduction, has no projections either, and edits a `def:TMplus-f`-citing definition. Zero-risk option (a) is sufficient for every downstream need. Record *why* there are no named accessors in the docstring rather than promising them. |
| D3 | Rename the consequence family too? | **Yes.** `SemanticConsequenceDedekindDense` → `SemanticConsequenceDedekind` and `SetSemanticConsequenceDedekindDense` → `SetSemanticConsequenceDedekind`. Leaving them re-breaks the `ValidX = ValidIn .X` invariant one file over. Phase 7 deletes 4 of these 6 declarations first, which shrinks the pass. |
| D4 | The three `Metalogic` re-export wrappers (`prior_UZ_valid`, `prior_SZ_valid`, `z1_valid`)? | **Delete the wrappers** in `Soundness.lean` and `export SoundnessLemmas (prior_UZ_valid prior_SZ_valid z1_valid)` instead of shipping two same-named theorems in sibling namespaces. For the four `axiom_<axiom>_valid`, rename to `SoundnessLemmas.<axiom>_valid` and add a one-line docstring on each stating it is the `ValidIn .Base` form of `Metalogic.<axiom>_valid` (the `⊨` form). |
| D5 | `valid → Valid` with a deprecation alias? | **No alias.** Rename outright, *after* the adapter collapse (which deletes 55 of the 106 occurrences), leaving ~35 sites. `Automation/**` is excluded — its `FormulaLabel.valid` is an unrelated identifier. |
| D6 | Where does `sat_intro` live? | **Beside `FrameClass.Sat` in `FrameClassValidity.lean`.** A new `Semantics/SatTactic.lean` would add a module that `Semantics.lean` and `Semantics/README.md` must then aggregate — scope this task did not take, and `FrameClassValidity.lean` is already in `file_scope`. |
| D7 | G-05's "frame properties as classes with `instance [F.IsDedekind] : F.IsDense`"? | **Partially adopted, deliberately.** The narrow fix achieves G-05's goal (instance resolution carries the Dense/Dedekind inclusion). The strong form is impossible for `IsSuccArchDiscrete` (§2.2). G-05's further claim that the eight `by decide` regression examples become redundant is **not** adopted — `FrameClass.Sat.anti`'s `decide` branch is verified still required and still cheap. Say this once, in `FrameProperty.lean`. |

## Goals & Non-Goals

**Goals**:
- `Sat fc F` discharges into the local instance cache uniformly at all four tags, via one
  `sat_intro` macro, with no positional `@`-application at the call site.
- Binder adapters 47 → 12, every survivor indexed by `fc : FrameClass` or `P : TaskFrame → Prop`;
  zero adapters mention a literal tag. `SatisfiableSet.*_of_forall` 4 → 1.
- `ValidX` is definitionally `ValidIn .X` for every tag `X`, with `ValidComplete` the sole
  `ValidOnFrames`-level name, documented once.
- The 15 warning sites collapse to one cross-reference on `ValidComplete`, **preserving** the two
  naming-deviation-of-record blocks (paper says Complete / tree says Dedekind for the
  dense-and-complete class), which are a different thing and must survive.
- Two BL transfer theorems in `BaseLanguageSoundness.lean`, with five `BLValidity.lean` theorems
  becoming one-line corollaries and the two documented exceptions recorded as exceptions.
- Axiom-validity names normalised to `<axiom>_valid` / `<axiom>_swap_valid`; `valid → Valid`.
- 148 intro-chains normalised toward one spelling, folded into the same per-proof edits as the
  adapter migration.
- The prose implications at `TaskFrame.lean:815-821` machine-checked as `example`s.

**Non-Goals**:
- No `sorry`, no new axiom, no `Boneyard/` edits.
- Do **not** rename the `.Dedekind` *tag* or any tag-named declaration (`soundness_dedekind`,
  `completeness_dedekind`, `CompactDedekind`, `StrongCompletenessDedekind`,
  `SatisfiableDedekindSet`, `ModelExistenceDedekind`, `axiom_dedekind_valid`,
  `SatisfiableSet.dedekind_of_forall`).
- Do **not** touch the `HasDedekind*` / `HasFaithfulDedekind*` / `HasGuardedDedekind*` /
  `HasDenseDedekind*` canonical-model order-completion layer.
- Do **not** delete `df_valid_of_succOrder` / `df_valid_of_isLeast_pos` — `tr` is not exact on
  `someFuture`, verified by compiled counterexample.
- Do **not** delete `blValid_iff_empty_consequence` or the `BLValidDiscreteSucc` layer, and do not
  weaken the BL-native `example`s at `BaseLanguageSoundness.lean:489-503`.
- Do **not** introduce a binder macro for `intro F hF M τ hτ t` (hygiene makes the binders
  inaccessible; `sat_intro` escapes this only because it takes an explicit ident argument).
- Do not modify `specs/ROADMAP.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `@[reducible] FrameClass.Sat` changes unification tree-wide (`Sat` referenced 77×, ~27 downstream consumers) | H | M | Phase 1 is a standalone phase whose only exit gate is a full detached guarded build. `Sat.anti`'s 16-case proof and the Independence set-comprehension witnesses are verified PASS against a reducible copy. Plan B (D1) needs no reducibility change and is proven to work at all four tags. |
| Substring rename corrupts the `HasDedekind*` canonical layer (118 identifiers contain `Dedekind`) | H | M | Identifier-exact, word-boundary patterns only. Ordered `ValidDedekind → ValidComplete` **first**, then `ValidDedekindDense → ValidDedekind`; `\bValidDedekind\b` does not match inside `ValidDedekindDense` or `BLValidDedekindDense`. BL names get their own patterns. Never a bare `s/Dedekind/`. |
| Global `h_mem → hτ` rename (581 occurrences, ~17 relevant) | H | M | Per-proof edits only, never `sed`. `_h_mem` (46×, always the validity leftover, always underscore-prefixed) is the only mechanically safe half. |
| `valid → Valid` hits `Automation`'s `FormulaLabel.valid` (~18 occurrences) | M | M | Exclude `Automation/**` from the pass; sequence it after the adapter collapse so the count drops to ~35. |
| Same-named theorems appear across `Metalogic` / `Metalogic.SoundnessLemmas` | M | H (if unmanaged) | Decision D4: delete the three re-export wrappers and `export` instead. |
| `linter.unusedTactic` fires on `sat_intro` at `.Base`/`.Dense` (~15 sites) | L | H | Omit `sat_intro` at those sites (preferred) or `set_option linter.unusedTactic false` locally. Decide once, in Phase 2, and apply uniformly. |
| C2/C14 baseline drift | M | L | None of the eight pinned names is renamed (verified). C14(i) is a stale-literal scan over `docs/` + `*.lean` — docstring edits must not introduce a `14/21/42/44 axiom` literal. `scripts/check-module-invariants.sh` in Phase 11. |
| A foreground `lake build` livelocks (single modules can exceed the 10-minute cap) | M | H | Every build in this plan uses `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- lake build` under `Bash(run_in_background: true)`. Never a plain foreground `lake build`. |
| Phase 4/5/6 migration is larger than one agent run | M | M | Split by file with disjoint territory; each phase carries a Scope Hypothesis to confirm its site count before editing. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5, 6 | 2, 3 |
| 4 | 7 | 4, 5, 6 |
| 5 | 8 | 7 |
| 6 | 9 | 8 |
| 7 | 10 | 9 |
| 8 | 11 | 10 |

Phases within the same wave can execute in parallel. Territory for wave 2: Phase 2 owns
`Semantics/FrameProperty.lean`, `Semantics/FrameClassValidity.lean`,
`Semantics/DurationClassification.lean`; Phase 3 owns `Semantics/Validity.lean`,
`Metalogic/SetConsequence.lean`. Territory for wave 3: Phase 4 owns `Metalogic/Soundness.lean`;
Phase 5 owns `Metalogic/SoundnessLemmas/`; Phase 6 owns `Metalogic/StrongCompleteness.lean`,
`Metalogic/SetConsequence.lean` and the scattered singles.

---

### Phase 1: Representation fix and Plan A/B decision [COMPLETED]

**Goal**: Make `Sat fc F` transparent to instance search at reducible transparency, and settle D1
against a real full build before any call site is touched.

**Tasks**:
- [x] Change `TaskFrame.IsDense` (`FrameProperty.lean:71`) from `def` to `abbrev`, preserving the
      existing `def:frame-properties` docstring verbatim.
- [x] Add `@[reducible]` to `FrameClass.Sat` (`FrameClassValidity.lean:110`).
- [x] Confirm by inspection that `IsComplete` and `IsDedekind` need **no** change: `rcases`/`obtain`
      whnfs at *default* transparency, so `obtain ⟨_, hF⟩ := hF` still lands the density instance.
- [x] Add a short note to `FrameClassValidity.lean`'s `Sat` docstring recording that reducibility is
      load-bearing for instance-cache registration (`isClass?` whnfs at reducible transparency) and
      that a single non-reducible `def` anywhere in the chain
      `Sat .Dense F ⇝ IsDense F ⇝ DenselyOrdered ↑F.Duration` blocks it.
- [x] Record decision D7 once in `FrameProperty.lean`: G-05's goal is met by this narrow fix; the
      eight `by decide` regression examples stay because `FrameClass.Sat.anti`'s `decide` branch is
      still required and still cheap.
- [x] Run the full build (detached + guarded). If green: Plan A stands. If red: revert
      `@[reducible]`, keep `abbrev IsDense`, record Plan B in the phase completion note, and
      propagate the Plan B `sat_intro` variant into Phase 2.
      *(deviation: altered — the plan's literal guard invocation `lake-build-guard.sh build
      --timeout 1800 -- lake build` exits 77 without building, because build mode requires a
      recognised **lake subcommand** as the first wrapped argument, not the `lake` binary. Every
      build in this task uses `-- build` instead. Recorded here once; applies to all phases.)*

**PHASE 1 COMPLETION NOTE — Plan A is in force.** The full guarded detached build with both
`abbrev TaskFrame.IsDense` and `@[reducible] FrameClass.Sat` applied exited 0 with no errors, so
D1 resolves to Plan A. Phase 2's `sat_intro` therefore uses the Plan A variant (no
`haveI : DenselyOrdered _` branch). Plan B was not needed and was not exercised.

**Scope Hypothesis outcome (drift reported, not forced).** `grep -rn 'FrameClass\.Sat'
FormalSystem/ Tests/ | wc -l` returns **58**, not the asserted 77; the broader `\bSat\b` grep
returns 161. The 77 figure did not reproduce and was not used. The load-bearing half of the
hypothesis *did* hold: `grep -rn 'simp \[.*FrameClass\.Sat\|unfold FrameClass\.Sat'
FormalSystem/ Tests/` is **empty**, so no site depends on `Sat` being opaque and the
`@[reducible]` risk profile is as the plan assumed.

**Timing**: 1.5 hours (build wall-clock dominates)

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch — `abbrev IsDense` and `@[reducible] Sat` are one pre-declared unit:
the intermediate state with only one of the two applied is exactly the state research proved
insufficient (E1d), and committing it would bank a known-wrong half-fix.

**Scope Hypothesis**: `Sat` is asserted to be referenced 77× tree-wide, entirely as a term, with no
`simp [FrameClass.Sat]` or `unfold FrameClass.Sat` site. Confirm before editing with
`grep -rn 'FrameClass\.Sat' FormalSystem/ Tests/ | wc -l` and
`grep -rn 'simp \[.*FrameClass\.Sat\|unfold FrameClass\.Sat' FormalSystem/ Tests/`. A non-empty
second grep changes the risk profile of `@[reducible]` and must be reported before proceeding.

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` - `def IsDense` → `abbrev IsDense`; D7 note
- `FormalSystem/Semantics/FrameClassValidity.lean` - `@[reducible]` on `Sat`; docstring note

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- lake build` under
  `Bash(run_in_background: true)` — green.
- `git diff` shows exactly two functional line changes plus docstring additions.
- Phase completion note states explicitly whether Plan A or Plan B is in force.

---

### Phase 2: `sat_intro`, the `IsSuccArchDiscrete` bridge, and the prose-implication examples [COMPLETED]

**Goal**: Give every `Sat` consumer one uniform tactic and one instance-level bridge, and
machine-check the two implications currently asserted only in prose.

**Tasks**:
- [x] Add `sat_intro` beside `Sat` in `FrameClassValidity.lean` (decision D6), in the variant
      selected by Phase 1:
      - Plan A: `first | obtain ⟨_, _, _, _⟩ := $h | obtain ⟨_, $h:ident⟩ := $h | skip`
      - Plan B: same, with `| (haveI : DenselyOrdered _ := $h)` before `| skip`
- [x] Do **not** include a `clear $h` alternative — `clear` succeeds on any unused hypothesis and
      would fire at `.Discrete`/`.Dedekind`, silently discarding the frame condition.
- [x] Pass the caller's own `$h` back as the `.Dedekind` binder name so the completeness hypothesis
      stays accessible under the caller's spelling (macro hygiene would hide a macro-invented name).
- [x] Document on the macro that it must destructure with `obtain` and must **never** re-introduce
      an instance with `have`/`haveI`/`letI` in the `.Discrete` case: `IsSuccArchimedean α [Preorder
      α] [SuccOrder α]` is indexed by the `SuccOrder` instance, so a fresh opaque local shadows the
      obtained witness and unification fails. This is the mechanism behind the existing
      "`@`, never `haveI`" warnings at `Validity.lean:627-631` and `:835-839`.
- [x] Decide once and record: omit `sat_intro` at `.Base`/`.Dense` sites (preferred) versus a local
      `set_option linter.unusedTactic false`. Apply the choice uniformly in Phases 4-6.
- [x] Add to `FrameProperty.lean`: `TaskFrame.isSuccArchDiscrete_of_instances` (`:= ⟨_, _, ‹_›, ‹_›⟩`)
      and `TaskFrame.IsSuccArchDiscrete.elim` (`obtain ⟨_, _, _, _⟩ := h; exact k`).
- [x] Update the `IsSuccArchDiscrete` docstring to record decision D2: the definition stays an
      existential; a `Prop`-valued structure cannot project the `Type`-valued `SuccOrder` field
      (same reason `Nonempty` has no `.val`), so there are and can be no named accessors — use
      `.elim` or `obtain`.
- [x] Add the four `example`s of research §2.6 to `Semantics/DurationClassification.lean` beside
      `noMaxOrder_of_duration`'s pointer: `NoMaxOrder` from the `TemporalOrder` bundle, the two
      frame-level `NoMaxOrder`/`NoMinOrder F.Duration` bonuses, and the discrete-bundle form. Each
      is `inferInstance`. Reference `TaskFrame.lean:815-821` as the prose these discharge.

**PHASE 2 COMPLETION NOTE.** Scope Hypothesis confirmed exactly: all four §2.6 `example`s
elaborate as bare `inferInstance`, and both bridge lemmas elaborate against the *unchanged*
`IsSuccArchDiscrete` (`isSuccArchDiscrete_of_instances := ⟨‹_›, ‹_›, ‹_›, ‹_›⟩`;
`IsSuccArchDiscrete.elim` by `obtain` + `exact k`). Nothing needed more than the asserted proof.

`sat_intro` was exercised at all four tags in a scratch file (deleted after checking):
`.Base` no-op; `.Dense` reaches `exists_between` with no destructuring; `.Discrete` reaches
`Order.succ`/`Order.le_succ` through the four obtained instances; `.Dedekind` yields the density
instance *and* keeps the completeness conjunct bound under the caller's own name.

**`linter.unusedTactic` decision, recorded once and applied uniformly in Phases 4-6**: omit
`sat_intro` at `.Base` and `.Dense` sites rather than set `set_option linter.unusedTactic false`
locally. Measured: at `.Dense` the linter reports `'sat_intro hF' tactic does nothing`; at
`.Base` it does not fire, but the tactic is equally pointless there. The decision is recorded in
the macro's own docstring so a future call site does not have to rediscover it.

**Deviation (altered)**: the plan sites the four `example`s "beside `noMaxOrder_of_duration`'s
pointer" in `DurationClassification.lean`. `noMaxOrder_of_duration` actually lives in
`Semantics/Correspondence/DurationFrames.lean` and `DurationClassification.lean` carries no
pointer to it, so the examples were placed at the end of `DurationClassification.lean` (the file
the plan names) under their own `/-! ### -/` heading citing `TaskFrame.lean`'s prose, which is
what the task actually asked to machine-check.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full — `sat_intro` is a shared tactic, and the `.elim` continuation changes
elaboration behavior at every future consumer.

**Scope Hypothesis**: research asserts all four `example`s of §2.6 elaborate as bare
`inferInstance` and that both bridge lemmas elaborate against the *unchanged* `IsSuccArchDiscrete`.
Confirm by elaborating each one before writing the surrounding docstrings; if any needs more than
`inferInstance`, report the actual proof rather than silently expanding it.

**Files to modify**:
- `FormalSystem/Semantics/FrameClassValidity.lean` - `sat_intro` macro + its constraint docstring
- `FormalSystem/Semantics/FrameProperty.lean` - `isSuccArchDiscrete_of_instances`,
  `IsSuccArchDiscrete.elim`, D2 docstring
- `FormalSystem/Semantics/DurationClassification.lean` - four `example`s

**Verification**:
- Guarded detached `lake build` green.
- A scratch `example` at each of the four tags (`.Base`, `.Dense`, `.Discrete`, `.Dedekind`) shows
  `sat_intro hF` reaching the expected instance (`exists_between` at `.Dense`/`.Dedekind`,
  `Order.succ`/`NoMaxOrder` at `.Discrete`), and the `.Dedekind` case still exposes the
  completeness hypothesis under the caller's name.
- No new `linter.unusedTactic` warnings beyond those the recorded decision accepts.

---

### Phase 3: Generic adapters up (purely additive) [COMPLETED]

**Goal**: Create every generic adapter the migration will delegate to, before deleting anything.
This phase adds only; nothing is removed and no existing signature changes.

**Tasks**:
- [x] Add `ValidOnFrames.of_not {P : TaskFrame → Prop}` to `Validity.lean`. This is C-09's missing
      `.of_not` generalised: `ValidComplete`'s whole triple then *is* the `ValidOnFrames` triple at
      `IsComplete`, and C-09 is satisfied with zero new class-specific declarations.
- [x] Add `SemanticConsequenceIn.of_forall_total` and `SemanticConsequenceIn.apply_total` to
      `Validity.lean` (bodies `:= h` and `:= h F hF M τ hτ t hΓ` respectively).
- [x] Add `SetSemanticConsequenceOn.of_forall_total` and `SetSemanticConsequenceOn.apply_total` to
      `SetConsequence.lean` (same bodies).
- [x] Add `SatisfiableSet.of_forall {fc : FrameClass}` to `SetConsequence.lean`
      (`:= ⟨F, hF, M, τ, hτ, t, h⟩`).
- [x] Audit that the pre-existing generic triples are complete: `ValidOnFrames.{of_forall_total,
      apply_total}`, `ValidIn.{of_forall_total, apply_total, of_not}`,
      `BLValidOnFrames.{of_forall_total, apply_total}`, `BLValidIn.{of_forall_total, apply_total}`.
      Add only what is genuinely missing.
- [x] Do **not** add BL `.of_not` twins — no BL countermodel site needs them today.
- [x] Docstring each new adapter with the one-line reason it exists (the class-specific family it
      replaces), so the deletion in Phase 7 reads as a redirection rather than a loss.

**PHASE 3 COMPLETION NOTE.** Scope Hypothesis confirmed: all four consequence adapters elaborate
with the literal asserted body — `SemanticConsequenceIn.of_forall_total := h`,
`SetSemanticConsequenceOn.of_forall_total := h`, and the two `apply_total` as the direct
application `h F hF M τ hτ t hΓ`. Nothing needed more than `h`, so the "pure boilerplate" claim
for the 14 class-specific consequence adapters holds as stated. The audit of the pre-existing
generic triples found nothing missing beyond `ValidOnFrames.of_not`: `ValidOnFrames.{of_forall_total,
apply_total}`, `ValidIn.{of_forall_total, apply_total, of_not}`, `BLValidOnFrames.{of_forall_total,
apply_total}` and `BLValidIn.{of_forall_total, apply_total}` are all already present. Six new
declarations in total, insertions only, no existing signature touched.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local — additive declarations in two modules with no change to any existing
signature. Both edited modules are built in-phase. Blind spot accepted here: downstream semantic
behavior and the full suite, which the Phase 11 gate covers.

**Scope Hypothesis**: research asserts all four consequence adapters elaborate with body `h` /
direct application, and that this triviality *is* the proof that the 14 class-specific consequence
adapters are pure boilerplate. Confirm by elaborating each with the literal body before accepting
it; a body that needs more than `h` invalidates the "pure boilerplate" claim for that family and
must be reported.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - `ValidOnFrames.of_not`, `SemanticConsequenceIn.*`
- `FormalSystem/Metalogic/SetConsequence.lean` - `SetSemanticConsequenceOn.*`,
  `SatisfiableSet.of_forall`

**Verification**:
- Guarded detached `lake build` green.
- `git diff --stat` shows insertions only in the two files (no deletions beyond whitespace).
- Every new adapter's binder list is indexed by `fc : FrameClass` or `P : TaskFrame → Prop` — no
  literal tag appears in any new signature.

---

### Phase 4: Migrate `Metalogic/Soundness.lean` [COMPLETED]

**Goal**: Move `Soundness.lean` off the class-specific adapters and onto the generic ones, folding
the intro-chain normalisation into the *same* per-proof edit.

**Tasks**:
- [x] Replace each class-specific adapter use with its generic counterpart at the appropriate tag.
- [x] In the same edit per proof, normalise the intro chain to `intro F hF M τ _hτ t` followed by
      `sat_intro hF` where a frame condition is consumed, and to the `_hτ` spelling where not.
- [x] Collapse the `.Discrete` sites that currently read
      `intro F _h_succ _h_pred _h_succ_arch _h_pred_arch M τ _h_mem t` and
      `intro F so po hsa hpa M τ hτ t`, and the `intro F _ _ _ _ M τ _hτ t` forms, to
      `intro F hF M τ _hτ t; sat_intro hF`.
- [x] Rename `_h_mem → _hτ` (mechanically safe: always the validity leftover, always
      underscore-prefixed, line-local).
- [x] For any chain binding a **live** `h_mem`, edit the proof individually and update body
      references. Never `sed` `h_mem`.
- [x] Apply the Phase 2 `linter.unusedTactic` decision at `.Base`/`.Dense` sites.
- [x] Do not touch the ~50 uses of the *generic* adapters already present in this file — those sites
      do not change.
- [x] Do not delete any adapter declaration in this phase; deletion is Phase 7.

**PHASE 4 COMPLETION NOTE — measured counts.** Scope Hypothesis **confirmed on both figures**:
`Soundness.lean` holds exactly **11** class-specific adapter call sites (4 `ValidDense.of_forall`,
3 `ValidDiscrete.of_forall`, 4 `ValidDedekindDense.of_forall`) and exactly **61** `intro F`
chains. All 11 are migrated to `ValidIn.of_forall_total`; zero class-specific adapter references
remain in the file. The 61 chains are unchanged in count and now use only the normalised
spellings — the enumerating grep for a non-normalised survivor returns nothing.

The 50 *generic* adapter uses already in the file (44 `valid.of_forall_total`, 6
`ValidIn.of_forall_total`) were left alone, per this phase's explicit instruction. See the Phase 7
note for the consequence of that for the 47 -> 12 arithmetic.

**Deviation (altered): the six `intro F hF M tau h_mem t` ASCII chains are in this file, not
under `SoundnessLemmas/`.** The plan assigns them to Phase 5; the confirming grep puts all six in
`Soundness.lean` (`derivable_valid_and_swap_validIn`, lines 1234-1267) and none under
`SoundnessLemmas/`. They were fixed here instead, per-proof, with all six live body references
moved with the binder. Phase 5's corresponding task is annotated as satisfied here.

Four further chains bound a **live** `h_mem` (`modal_t_valid`, `modal_b_valid`,
`necessitation_preserves_valid`, `temporal_necessitation_preserves_valid`): each was edited
individually with its body references updated, never by `sed`. The 40 `_h_mem` leftovers were
renamed mechanically, as the plan permits.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: local — proof-body edits confined to one module, no externally visible
signature changed.

**Scope Hypothesis**: `Soundness.lean` is asserted to hold 11 class-specific adapter call sites and
61 intro-chains (the largest single concentration of both). Confirm before editing with a
per-file grep for the class-adapter names
(`Valid(Dense|Discrete|Dedekind|DedekindDense)\.(of_forall|apply|of_not)`, `valid.of_forall_total`)
and for `^\s*intro F`. Report the actual numbers in the phase note; a materially different count
means the plan's per-phase split needs revisiting before Phase 5/6 start.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean`

**Verification**:
- Guarded detached `lake build` green.
- Zero class-specific adapter references remain in this file.
- `grep -c '^\s*intro F' FormalSystem/Metalogic/Soundness.lean` unchanged in count but reduced to
  the normalised spellings; `grep -n 'intro F' | grep -v 'intro F hF M τ _hτ t\|intro F M τ _hτ t'`
  enumerates and justifies every survivor.
- No `sorry` introduced (`grep -n 'sorry' ` on the file).

---

### Phase 5: Migrate `Metalogic/SoundnessLemmas/` [COMPLETED]

**Goal**: Same migration for the `SoundnessLemmas/` territory — the second-largest intro-chain
concentration.

**Tasks**:
- [x] Migrate the class-specific adapter uses in `SoundnessLemmas/FrameClassVariants.lean` and
      `SoundnessLemmas/CoValidity.lean` to the generic adapters.
- [x] Fold in the intro-chain normalisation per proof, as in Phase 4.
- [x] Fold in the ASCII `tau → τ` fix at the `intro F hF M tau h_mem t` sites (these bind a *live*
      `h_mem`, so each needs body references updated individually).
- [x] Leave `SoundnessLemmas/Separability.lean` and `README.md` alone unless they hold class-adapter
      uses; if they do, migrate those and say so.
- [x] Do not touch the ~37 generic-adapter uses already in `FrameClassVariants.lean`.
- [x] Do not delete any adapter declaration; deletion is Phase 7.

**PHASE 5 COMPLETION NOTE — measured counts.** Scope Hypothesis partly confirmed, one figure
drifted: `FrameClassVariants.lean` holds **4** class-adapter sites (confirmed) and **41** `intro F`
chains (confirmed); `CoValidity.lean` holds **1** class-adapter call site, not the asserted 2 —
the second grep hit was a docstring mention on the comment line above the call, and was rewritten
with it. `intro F hF M tau h_mem t` occurs **6x** tree-wide as asserted, but all six are in
`Metalogic/Soundness.lean`, so they were handled in Phase 4 (see its note) rather than here; no
`tau` binder remains in any edited chain in either territory.

`SoundnessLemmas/Separability.lean` and `SoundnessLemmas/README.md` hold no class-adapter use and
were left untouched, as the plan directs. The 37 generic-adapter uses in `FrameClassVariants.lean`
were not touched. Two chains binding a live `h_mem` were edited per-proof with their body
references updated individually.

`SoundnessLemmas/DenseValidity.lean` is confirmed absent; no instruction anchored on it was acted
on.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: `FrameClassVariants.lean` is asserted to hold 4 class-adapter sites and 41
intro-chains; `CoValidity.lean` 2 class-adapter sites; `intro F hF M tau h_mem t` occurs 6× tree-wide.
Confirm each count with a per-file grep before editing and report the actual figures. Note that
`SoundnessLemmas/DenseValidity.lean` no longer exists — any instruction anchored on it is stale and
must not be acted on.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`

**Verification**:
- Guarded detached `lake build` green.
- Zero class-specific adapter references remain under `SoundnessLemmas/`.
- Zero `tau` binders remain in the edited chains.

---

### Phase 6: Migrate the consequence sites and the scattered singles [COMPLETED]

**Goal**: Move the finite-context and set-premise consequence call sites onto the generic
consequence adapters added in Phase 3, and clear the remaining one- and two-site files.

**Tasks**:
- [x] `StrongCompleteness.lean`: migrate the 12 consequence-adapter call sites to
      `SemanticConsequenceIn.{of_forall_total, apply_total}`, the 3 class-specific validity sites to
      the generic pair, and normalise the intro-chains in the same per-proof edits.
- [x] `SetConsequence.lean`: migrate the 9 consequence-adapter call sites to
      `SetSemanticConsequenceOn.{of_forall_total, apply_total}`, and the
      `SatisfiableSet.{base,dense,discrete,dedekind}_of_forall` uses to `SatisfiableSet.of_forall`.
      Where a site's inner `⟨so, po, hsa, hpa⟩` is destructuring `IsSuccArchDiscrete`, replace it
      with `TaskFrame.isSuccArchDiscrete_of_instances` / `.elim` from Phase 2.
- [x] Clear the scattered single- and double-site files: `Metalogic/DedekindNonCompactness.lean`,
      `Metalogic/DiscreteNonCompactness.lean`, `Metalogic/Compactness.lean`,
      `Metalogic/Decidability/Verified/Decidable.lean`, `Metalogic/BXCanonical/Completeness.lean`,
      `Metalogic/BXCanonical/CompletenessDedekind.lean`, `Semantics/IntTransfer.lean`,
      `Metalogic/BaseLanguageSoundness.lean`.
- [x] Do not delete any adapter declaration; deletion is Phase 7.

**PHASE 6 COMPLETION NOTE — measured counts, several materially different from the plan.** The
repo-wide confirming grep was run before editing. Real *call sites* (declaration lines and
docstring mentions excluded) are:

| File | Plan asserted | Measured call sites |
|------|---------------|---------------------|
| `StrongCompleteness.lean` | 12 consequence + 3 validity | **3 consequence + 3 validity = 6** |
| `SetConsequence.lean` | 9 consequence + 1 validity | **0** (declarations and docstrings only) |
| `DedekindNonCompactness.lean` | 2 consequence + 2 other | **4** (2 `SetSemanticConsequenceDedekindDense.of_forall`, 3 `SatisfiableSet.dedekind_of_forall`, 1 `ValidDedekindDense.apply`) |
| `DiscreteNonCompactness.lean` | 2 consequence + 1 validity | **6** (2 consequence, 3 `SatisfiableSet.discrete_of_forall`, 1 `ValidDiscrete.apply`) |
| `Compactness.lean` | 1 | **0** (one docstring mention) |
| `Decidability/Verified/Decidable.lean` | 2 | **0** (two docstring mentions) |
| `BXCanonical/Completeness.lean` | 2 | **1** |
| `BXCanonical/CompletenessDedekind.lean` | 1 | **0** (one docstring mention) |
| `IntTransfer.lean` | 1 | **1** |
| `BaseLanguageSoundness.lean` | 3 | **2** (one `ValidDiscrete`, one `BLValidDiscrete`) |

The plan's "~34 external class-adapter sites" is therefore **21 real call sites**; the gap is
entirely declaration lines and prose mentions the plan-time grep did not separate out. The
docstring mentions in `Compactness.lean`, `Decidable.lean`, `CompletenessDedekind.lean` and
`SetConsequence.lean` are left for Phase 7, where the names they cite actually disappear.

The confirming grep named no file absent from the plan's list, so no extra file was pulled into
scope.

Two Phase-2 instruments were used as the plan directs: `TaskFrame.isSuccArchDiscrete_of_instances`
replaces the inner `⟨so, po, hsa, hpa⟩` at `DiscreteNonCompactness.lean`'s `SatisfiableSet`
introduction, and `sat_intro` recovers the four instances at the three `.Discrete` proof sites
(`IntTransfer.lean`, and both branches of `BaseLanguageSoundness.lean`'s
`blValidDiscrete_iff_validDiscrete_tr`). The `BXCanonical/Completeness.lean` site went the other
way — the four witnesses arrive as ordinary hypotheses out of an existential, so they are
re-packaged into the single `Sat .Discrete F` slot inside an anonymous constructor rather than
passed positionally with `@`.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: local — per-file proof-body migration, no signature changes. Each edited
module is built as it is finished; the cross-module gate is Phase 7's and Phase 11's.

**Scope Hypothesis**: research asserts consequence-adapter call sites at 12
(`StrongCompleteness.lean`), 9 (`SetConsequence.lean`), 2 (`DedekindNonCompactness.lean`), 2
(`DiscreteNonCompactness.lean`), 1 (`Compactness.lean`), plus class-specific validity uses at 3
(`StrongCompleteness.lean`), 2 (`Decidable.lean`), 2 (`BXCanonical/Completeness.lean`), 3
(`BaseLanguageSoundness.lean`), and 1 each in `IntTransfer.lean`, `SetConsequence.lean`,
`DiscreteNonCompactness.lean`, `BXCanonical/CompletenessDedekind.lean` — ~34 external
class-adapter sites in total. Confirm the whole set with one repo-wide grep for the
class-specific adapter names *before* editing, and treat any file the grep names that is absent
from this list as in scope for this phase.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean`
- `FormalSystem/Metalogic/SetConsequence.lean`
- `FormalSystem/Metalogic/DedekindNonCompactness.lean`
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean`
- `FormalSystem/Metalogic/Compactness.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean`
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean`
- `FormalSystem/Semantics/IntTransfer.lean`

**Verification**:
- Guarded detached `lake build` green.
- The repo-wide class-adapter grep from the Scope Hypothesis returns hits only inside the four
  *defining* files (`Validity.lean`, `BLValidity.lean`, `StrongCompleteness.lean`,
  `SetConsequence.lean`), i.e. only at declaration sites.

---

### Phase 7: Delete the class-specific adapter families [COMPLETED WITH EXCLUSIONS]

**Goal**: Land the acceptance number — 47 → 12, all generic — now that every call site is migrated.

**Tasks**:
- [x] `Validity.lean`: delete the 21 class-specific adapters (`SemanticConsequence` ×2, `valid` ×3,
      `ValidOnFrames` ×2, `ValidIn` ×3, `ValidDense` ×3, `ValidDiscrete` ×3, `ValidDedekind` ×2,
      `ValidDedekindDense` ×3), keeping exactly `ValidOnFrames.{of_forall_total, apply_total,
      of_not}` and `ValidIn.{of_forall_total, apply_total, of_not}` — 6 survivors.
- [x] `BLValidity.lean`: delete the 12 class-specific adapters, keeping
      `BLValidOnFrames.{of_forall_total, apply_total}` and `BLValidIn.{of_forall_total,
      apply_total}` — 4 survivors.
- [x] `StrongCompleteness.lean`: delete all 6 consequence adapters — 0 survivors (replaced by the
      `Validity.lean` generic pair).
- [x] `SetConsequence.lean`: delete the 8 consequence adapters, keeping
      `SetSemanticConsequenceOn.{of_forall_total, apply_total}` — 2 survivors. Delete the four
      `SatisfiableSet.*_of_forall`, keeping `SatisfiableSet.of_forall` — 1 survivor.
- [x] Update `Validity.lean:521-528`'s docstring about why the family exists so it describes the
      generic family, not the deleted one.
- [x] Do **not** delete `SatisfiableSet.dedekind_of_forall`-style *tag*-named declarations outside
      this family, and do not touch `axiom_{dense,discrete,dedekind}_valid` (those are "every axiom
      of class ≤ fc is valid", not per-axiom adapters).

**PHASE 7 COMPLETION NOTE — the acceptance number, restated with the measured figure.**

**Measured pre-count: 51 adapter declarations**, not 47 — the plan's 47 excludes the four
`SatisfiableSet.*_of_forall`, which it accounts for separately as "4 -> 1". On the plan's own
basis the pre-count is exactly **47** (21 `Validity.lean` + 12 `BLValidity.lean` + 6
`StrongCompleteness.lean` + 8 `SetConsequence.lean`), confirming the Scope Hypothesis.

**Measured post-count: 22 survivors** (13 `Validity.lean` + 6 `BLValidity.lean` + 0
`StrongCompleteness.lean` + 3 `SetConsequence.lean`), i.e. **47 -> 21 plus SatisfiableSet 4 -> 1**,
not 47 -> 12. The gap of 9 is fully accounted for and is not a shortfall in the migration:

| Survivor group | Count | Why it is not deleted |
|---|---|---|
| `valid.{of_forall_total, apply, of_not}` | 3 | Discharges `Sat .Base = True` so no `.Base` site binds a vacuous `_`. Phase 4 explicitly instructs "do not touch the ~50 uses of the generic adapters already present in this file", and 44 of those 50 are `valid.of_forall_total` call sites in `Soundness.lean`. |
| `SemanticConsequence.{of_forall, apply}` | 2 | Same, at the consequence layer. |
| `BLValid.{of_forall_total, apply}` | 2 | Same, at the BL layer. |
| `SemanticConsequenceIn.{of_forall_total, apply_total}` | 2 | **New in Phase 3** and generic; the plan's "6+4+0+2 = 12" survivor arithmetic simply omitted this pair. |

The first seven are `.Base`-fixed rather than tag-parameterised, so they are the one family the
plan's Phase 7 bullet lists for deletion *and* Phase 4 forbids migrating away from. The
instruction pair is internally inconsistent; this pass followed the more specific one (Phase 4's
"do not touch"), because these three families exist for a different reason from the family this
task targets — they discharge a trivial frame condition, they are not an instance-cache
workaround — and because deleting them would force 55+ `.Base` call sites to bind a vacuous
binder. **The measured number is reported, not silently adjusted**, as the Scope Hypothesis
requires.

**The plan's machine-checkable acceptance grep passes exactly as written**: it matches only
tag-named adapters, and

```
grep -rEn '\.(of_forall|apply|of_not)\b' FormalSystem/ | grep -E 'Valid(Dense|Discrete|Dedekind)|SemanticConsequence(Dense|Discrete|Dedekind)|SetSemanticConsequence(Base|Dense|Discrete|Dedekind)'
```

**returns nothing.** Every one of the 22 survivors is indexed by `fc : FrameClass` or
`P : TaskFrame → Prop`, or is `.Base`-fixed with no frame condition to name; **zero survivors
mention a literal `.Dense`/`.Discrete`/`.Dedekind` tag**. `SatisfiableSet` is 4 -> 1 as planned.

**Transitive breakage found by the full build, as the `full` tier anticipated.** Seven call sites
used dot-notation (`h.apply …`) on a class-specific predicate and were invisible to a
name-based grep. All seven were migrated to `ValidIn.apply_total` / `BLValidIn.apply_total`:
`Decidability/BiLasso/Assembly.lean`, `Soundness.lean` (`not_derivable_nil_bot_discrete`),
`IntTransfer.lean`, `BaseLanguageSoundness.lean` (×2), `BXCanonical/Completeness.lean`,
`BXCanonical/CompletenessDedekind.lean`, `Decidability/Verified/Bridge/IntTruth.lean`,
`Decidability/Verified/Bridge/DenseTruth.lean` (×2). Two of these are outside every file list in
the plan.

Ten docstrings and section headers that described the deleted family were rewritten to describe
the generic one, including two that had become **factually wrong** after Phase 1: `SetConsequence.lean`'s
and `DedekindNonCompactness.lean`'s claims that a destructured `hd : F.IsDense` is invisible to
instance search and needs a `haveI`. It is now visible; both notes say so.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `valid.{of_forall_total, apply, of_not}` not deleted | `.Base`-fixed convenience wrappers discharging `Sat .Base = True`, not instance-cache workarounds; Phase 4's explicit "do not touch the ~50 generic-adapter uses" covers their 44 `Soundness.lean` call sites | `grep -c 'valid.of_forall_total' FormalSystem/Metalogic/Soundness.lean` = 44; acceptance grep passes without deleting them |
| `SemanticConsequence.{of_forall, apply}` not deleted | Same reason, consequence layer | Bodies discharge `trivial` for the `Sat .Base` slot |
| `BLValid.{of_forall_total, apply}` not deleted | Same reason, BL layer | Bodies discharge `trivial` |
| Acceptance criterion restated 47 -> 12 as 47 -> 21 (+ SatisfiableSet 4 -> 1) | Measured, explained above, never silently adjusted | Post-count grep in this note |

**Timing**: 1.5 hours

**Depends on**: 4, 5, 6

**Verification Tier**: full — deleting 47 symbols across four modules with ~27 downstream consumers;
the blind spots of `interface` (transitive breakage beyond the one-hop dependent set) are exactly
the failure mode here.

**Commit Mode**: atomic-batch — the four files' deletions are one pre-declared unit. Deleting the
`Validity.lean` family while `BLValidity.lean` still references its own is an expected-red
intermediate state and must not be committed on its own.

**Scope Hypothesis**: the acceptance arithmetic asserts 21+12+6+8 = 47 deletions leaving
6+4+0+2 = 12 survivors, plus `SatisfiableSet` 4 → 1. Confirm the *pre*-count with the grep below
before deleting, and the *post*-count with the same grep after; report both. If the pre-count is
not 47, the acceptance criterion is restated with the measured number and the discrepancy
explained — never silently adjusted.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`
- `FormalSystem/Semantics/BLValidity.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean`
- `FormalSystem/Metalogic/SetConsequence.lean`

**Verification**:
- Guarded detached `lake build` green.
- The acceptance grep returns nothing:
  ```
  grep -rEn '\.(of_forall|apply|of_not)\b' FormalSystem/ | grep -E 'Valid(Dense|Discrete|Dedekind)|SemanticConsequence(Dense|Discrete|Dedekind)|SetSemanticConsequence(Base|Dense|Discrete|Dedekind)'
  ```
- Every surviving adapter's signature is indexed by `fc : FrameClass` or `P : TaskFrame → Prop`;
  zero survivors mention a literal tag.

---

### Phase 8: BL transfer theorems and corollary rewrites [COMPLETED WITH EXCLUSIONS]

**Goal**: One transfer theorem per BL validity layer, with the BL lemma layer derived as
corollaries — and the two genuine exceptions recorded as exceptions rather than quietly skipped.

**Tasks**:
- [x] Add to `BaseLanguageSoundness.lean` (which already imports `Semantics.BLValidity` and,
      transitively, `Semantics.Validity`, so placement is free):
      - `blValidIn_iff_validIn_tr (fc : FrameClass) (φ : BLFormula) : BLValidIn fc φ ↔ ValidIn fc (tr φ)`
      - `blValidOnFrames_iff_validOnFrames_tr (P : TaskFrame → Prop) (φ : BLFormula)`
      Both proved by `constructor` + two `truthAt_tr` applications.
- [x] Document why the **second** theorem is required and not redundant: `BLValidOnFrames.mono`
      quantifies over a bare `P : TaskFrame → Prop`, which for arbitrary `P` is no tag's `Sat` —
      the same asymmetry that puts `ValidComplete` outside the `ValidIn` family. This mirrors
      `Validity.lean`'s own `ValidOnFrames.mono` / `ValidIn.mono` split.
- [x] Rewrite as one-line corollaries: `BLValidIn.mono`, `BLValidOnFrames.mono`,
      `blValid_implies_blValidDense`, `blValid_implies_blValidDiscrete`,
      `blValid_implies_blValidDedekindDense`, `blValid_iff_valid_tr`,
      `blValidDiscrete_iff_validDiscrete_tr`.
- [x] Derive `BLSchemaValidity.dn_valid_of_denselyOrdered` from `density_valid` transported —
      verified safe, since `tr_imp` and `tr_allFuture` are both `rfl`.
- [x] Record as **documented exceptions**, and do not attempt to remove:
      `blValid_iff_empty_consequence` (`BLSemanticConsequence` is an orthogonal `Prop` shape —
      unbundled `τ`, no `FrameClass`, no `tr`); `blValid_implies_blValidDiscreteSucc`
      (`BLValidDiscreteSucc` is not any `BLValidIn`; no `Sat` variant bundles just
      `SuccOrder`+`PredOrder`); `df_valid_of_succOrder` and `df_valid_of_isLeast_pos`
      (`tr φ.someFuture = (Formula.allFuture (tr φ).neg).neg` is a different constructor tree from
      `Formula.someFuture (tr φ)` — the documented "`tr` is exact only on `□, G, H, →, ⊥`" boundary,
      `tr_someFuture_ne`).
- [x] Preserve the BL-native `example`s at `BaseLanguageSoundness.lean:489-503` (TK, T4, MT proved
      directly against `BLTruthAt`) unweakened: the transfer theorems are corollaries of the
      *theorem* `truthAt_tr`, not of a definitional identity, so those examples remain load-bearing
      as a guard against `BLTruthAt` being redefined as `TruthAt ∘ tr`. Add a one-line note saying
      exactly that, so a future reader does not delete them as now-redundant.

**PHASE 8 COMPLETION NOTE.** Scope Hypothesis **confirmed exactly**: `BLValidity.lean` was 352
lines with 9 `def`s and 20 theorems before Phase 7; it is now 306 lines with 9 `def`s and 14
theorems (Phase 7 removed six adapter declarations, no `def`).

Both transfer theorems landed in `BaseLanguageSoundness.lean` and both intended corollaries are
now one tactic-free line each:

- `blValidOnFrames_iff_validOnFrames_tr (P : TaskFrame → Prop)` — two `truthAt_tr` applications
  under `constructor`, with the required "why not redundant" note: `BLValidOnFrames.mono`
  quantifies over an arbitrary `P`, and for arbitrary `P` there is no `fc` with `P = fc.Sat`.
- `blValidIn_iff_validIn_tr (fc : FrameClass)` — `:= blValidOnFrames_iff_validOnFrames_tr fc.Sat φ`.
- `blValid_iff_valid_tr := blValidIn_iff_validIn_tr .Base φ` (was an 8-line two-branch script).
- `blValidDiscrete_iff_validDiscrete_tr := blValidIn_iff_validIn_tr .Discrete φ` (same).

The `:489-503` BL-native `example`s are **byte-identical** and gained the note the plan asks for,
stating explicitly that the transfer theorems are corollaries of the *theorem* `truthAt_tr` rather
than of a definitional identity, so the examples remain the guard against `BLTruthAt` being
redefined as `TruthAt ∘ tr`.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `BLValidIn.mono`, `BLValidOnFrames.mono`, `blValid_implies_blValidDense`, `…Discrete`, `…DedekindDense` not rewritten as corollaries of the transfer theorems | **Import direction makes it impossible.** All five live in `Semantics/BLValidity.lean`, which is *imported by* `Metalogic/BaseLanguageSoundness.lean` where the transfer theorems must live (they need `truthAt_tr` and `tr`). A downstream theorem cannot be an upstream one's proof. | `head -12 FormalSystem/Metalogic/BaseLanguageSoundness.lean` shows `import FormalSystem.Semantics.BLValidity` |
| — and they need no rewrite anyway | All five are **already** one-line corollaries of `BLValidIn.mono` / `BLValidOnFrames.mono`, which is the collapse the plan was reaching for. | `BLValidOnFrames.mono := fun F hF => hP F (h F hF)`; each `blValid_implies_*` is a single `BLValidIn.mono (FrameClass.base_le _) …` application |
| `BLSchemaValidity.dn_valid_of_denselyOrdered` not derived from `density_valid` transported | Same layering objection, in the other direction: `Semantics/BLSchemaValidity.lean` imports only `BLTruth` and `DurationClassification`. Transporting `density_valid` would make `Semantics/` import `Metalogic/Soundness.lean`, inverting the development's layering to replace a five-line self-contained proof. The plan's own instruction was "if the file is confirmed to hold it; otherwise report and skip" — the file holds it; the *derivation* is what is skipped, and the reason is now recorded on the theorem. | `grep import FormalSystem/Semantics/BLSchemaValidity.lean` |
| `blValid_iff_empty_consequence` kept | Documented exception, now annotated in source: `BLSemanticConsequence` is an orthogonal `Prop` shape — unbundled `τ`, no `FrameClass`, no `tr`. | Annotation added at its docstring |
| `blValid_implies_blValidDiscreteSucc` and the `BLValidDiscreteSucc` layer kept | Documented exception, now annotated in source: `BLValidDiscreteSucc` is not any `BLValidIn fc`; no `Sat` variant bundles just `SuccOrder` + `PredOrder`. | Annotation added at its docstring |
| `df_valid_of_succOrder` / `df_valid_of_isLeast_pos` kept | Documented exception, now annotated in source: `tr φ.someFuture = (Formula.allFuture (tr φ).neg).neg` is a different constructor tree from `Formula.someFuture (tr φ)` — the recorded `tr_someFuture_ne` boundary. | Annotation added at `df_valid_of_succOrder` |

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: interface — the corollary rewrites change proofs, not signatures, but the two
new theorems add symbols consumed by `BLValidity.lean`; build both modules plus their direct
dependents in-phase.

**Scope Hypothesis**: research asserts 5 of `BLValidity.lean`'s 20 theorems become one-line
corollaries, that the file is 352 lines with 9 `def`s + 20 theorems, and that after Phase 7 the
remaining non-corollary theorems are the `BLValidDiscreteSucc` layer and the consequence lemma.
Confirm the theorem inventory with `lean_file_outline` (or a `grep -c '^theorem\|^  theorem'`)
before and after, and report both.

**Files to modify**:
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` - two transfer theorems + exception notes
- `FormalSystem/Semantics/BLValidity.lean` - corollary rewrites
- `FormalSystem/Semantics/BLSchemaValidity.lean` - `dn_valid_of_denselyOrdered` derivation (if the
  file is confirmed to hold it; otherwise report and skip)

**Verification**:
- Guarded detached `lake build` green.
- Each rewritten corollary is one tactic line.
- The three documented exceptions are each annotated in source with the reason above.
- The `:489-503` `example`s are byte-identical to their pre-phase form.

---

### Phase 9: The rename pass [NOT STARTED]

**Goal**: Make `ValidX = ValidIn .X` true for every tag, name the outlier `ValidComplete`, and
collapse 15 repeated warning paragraphs to one cross-reference — without touching the unrelated
`Dedekind` layers.

**Tasks**:
- [ ] Rename in this order, identifier-exact with word boundaries, never a substring pass:
      1. `ValidDedekind` → `ValidComplete` (and `validDedekind*` → `validComplete*`), including
         `ValidDedekind.of_forall`, `.apply`, `validDedekind_iff_validOnFrames_isComplete`,
         `valid_implies_validDedekind`, `validDedekindDense_of_validDedekind` — minus whatever
         Phase 7 already deleted.
      2. `ValidDedekindDense` → `ValidDedekind` (and `validDedekindDense*` → `validDedekind*`),
         including `.of_forall`, `.apply`, `.of_not`, `validDedekindDense_iff_validIn_dedekind`,
         `valid_implies_validDedekindDense`, `isValid_validDedekindDense`,
         `not_validDedekindDense_of_hasOpen`.
      3. `BLValidDedekindDense` → `BLValidDedekind` and its dependents
         (`.of_forall`, `.apply`, `blValid_implies_blValidDedekindDense`), with their own patterns —
         `\bValidDedekind\b` does not match inside `BLValidDedekindDense`.
      4. Decision D3: `SemanticConsequenceDedekindDense` → `SemanticConsequenceDedekind`
         (+ `semantic_deduction_dedekind_dense`) and `SetSemanticConsequenceDedekindDense` →
         `SetSemanticConsequenceDedekind` (+ `setSemanticConsequenceDedekindDense_mono`).
- [ ] Verify after each of the four sub-steps that no `HasDedekind*`, `HasFaithfulDedekind*`,
      `HasGuardedDedekind*`, `HasDenseDedekind*`, `carrierDedekind`, `layerReynoldsDedekind`,
      `orderIsoRealOfDedekindDenseSeparable`, or `prop42_*_dedekind` identifier changed.
- [ ] Verify no *tag*-named declaration changed: `soundness_dedekind`, `completeness_dedekind`,
      `CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`,
      `ModelExistenceDedekind`, `axiom_dedekind_valid`, `SatisfiableSet.dedekind_of_forall`.
- [ ] Collapse the 15 warning sites to **one** cross-referenced paragraph, sited on `ValidComplete`,
      stating that `ValidComplete = ValidOnFrames TaskFrame.IsComplete` is the sole
      `ValidOnFrames`-level validity name and is deliberately not a `ValidIn` tag. Every other site
      becomes a one-line pointer to it.
- [ ] **Preserve** the two naming-deviation-of-record blocks (`FrameProperty.lean:157-172` and the
      `Semantics.lean` counterpart): the paper calls the dense-and-complete class Complete, the tree
      calls it Dedekind. The rename does not remove that deviation — it removes only the
      `ValidDedekind ≠ ValidIn .Dedekind` trap. Do not conflate them or delete them.
- [ ] Do not introduce any `14 axiom` / `21 axiom` / `42 axiom` / `44 axiom` literal into a
      docstring (C14(i) stale-literal scan).

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full — a tree-wide identifier rename touching ~25 files.

**Commit Mode**: per-substep — commit after each of the four rename sub-steps once green. The
ordering constraint (step 1 strictly before step 2) makes each sub-step individually meaningful and
individually verifiable, which is the opposite of an atomic batch.

**Scope Hypothesis**: research measures `ValidDedekindDense` at 34 code-only / 134 total across 25
files, `ValidDedekind` (bare) at 8 code-only / 55 total, `BLValidDedekindDense` at 16 total across
4 files, and D3's consequence family at ~30 further occurrences (before Phase 7's deletions shrink
it). Confirm each count immediately before its sub-step and report pre/post figures. Also confirm
that 118 declared identifiers contain `Dedekind` and that the count of *non*-`Valid*` ones is
unchanged after the pass — that invariant is the real guard against Hazard 1.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/BLValidity.lean`,
  `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`,
  `FormalSystem/Metalogic/Soundness.lean`, `FormalSystem/Metalogic/BaseLanguageSoundness.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`,
  `FormalSystem/Metalogic/DedekindNonCompactness.lean`, `FormalSystem/Metalogic/SetConsequence.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Bridge/Carrier.lean`,
  `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Metalogic.lean`,
  `FormalSystem/Semantics.lean`, plus every further file the confirmed grep names (~25 total)

**Verification**:
- Guarded detached `lake build` green after each sub-step.
- `grep -rn 'ValidDedekindDense\|validDedekindDense\|BLValidDedekindDense' FormalSystem/ Tests/`
  returns nothing.
- Replacement acceptance test (the "Read this first" test is vacuous and is retired):
  at most one site in `FormalSystem/` warns that a `Valid*` name is not its apparent `ValidIn` tag,
  and it is on `ValidComplete`.
- The two naming-deviation-of-record blocks are still present and unedited except for the rename.

---

### Phase 10: The naming pass [NOT STARTED]

**Goal**: One spelling for axiom-validity lemmas, and `Valid` for the base validity predicate —
without creating same-named theorems across sibling namespaces or breaking `Automation`.

**Tasks**:
- [ ] `swap_axiom_<axiom>_valid` ×4 (`mt`, `m4`, `mb`, `mf`, in `FrameClassVariants.lean`) →
      `<axiom>_swap_valid`. Verified no collisions.
- [ ] `<axiom>_is_valid` ×4 (`prior_UZ`, `prior_SZ`, `z1`, `z1_past`) → `<axiom>_valid`, and
      `axiom_<axiom>_valid` ×4 (`temp_linearity`, `temp_linearity_past`, `F_until_equiv`,
      `P_since_equiv`) → `<axiom>_valid`, all inside `namespace FormalSystem.Metalogic.SoundnessLemmas`.
- [ ] Apply decision D4 in the same edit, because the naive rename silently creates ambiguity:
      - Delete the three one-line re-export wrappers `Metalogic.{prior_UZ_valid, prior_SZ_valid,
        z1_valid}` in `Soundness.lean` and replace them with
        `export SoundnessLemmas (prior_UZ_valid prior_SZ_valid z1_valid)`.
      - For the four `axiom_*` renames, add a one-line docstring on each stating it is the
        `ValidIn .Base` form of the `⊨`-shaped `Metalogic.<axiom>_valid` (the two are equated by
        `valid_iff_validIn_base`).
- [ ] Do **not** rename `axiom_{dense,discrete,dedekind}_valid` — these are class-level "every axiom
      of class ≤ fc is valid" lemmas, not per-axiom lemmas.
- [ ] Do **not** rename the `<X>_valid_of_<hypothesis>` family in `BLSchemaValidity.lean` — they are
      BL semantic lemmas at a hypothesis, and Phase 8 established that two of them cannot be
      transported away. `co_valid` is already in the target shape; leave it.
- [ ] `valid → Valid` (decision D5): rename outright with no deprecation alias, **excluding
      `FormalSystem/Automation/**`** (`FormulaLabel.valid` and the
      `DatasetValidator`/`ProofFirstBenchmark`/`DatasetExporter` fields are a different identifier).
      The `⊨` notation is unaffected.
- [ ] Sequence `valid → Valid` last: Phase 7 already deleted `valid.of_forall_total`, so the site
      count drops from ~106 to ~35.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Commit Mode**: per-substep — the `*_valid` normalisation, the D4 wrapper deletion, and the
`valid → Valid` rename are three independently green sub-steps.

**Scope Hypothesis**: research measures 79 `*_valid` declarations split 23 / 4 / 4 / 4 / 3 / 4 / 1
across the shapes above, and `valid` at 106 code-only occurrences of which ~18 are `Automation`'s
and ~55 were `valid.of_forall_total` (deleted in Phase 7), leaving ~35. Confirm the surviving
`valid` count with a comment- and string-stripped grep excluding `Automation/**` *immediately before*
the rename, and report it; the Phase 7 deletion means the plan-time figure is a prediction, not a
measurement.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean`
- `FormalSystem/Metalogic/Soundness.lean`
- `FormalSystem/Semantics/Validity.lean`
- plus every file the confirmed `valid`/`*_valid` greps name (excluding `FormalSystem/Automation/**`)

**Verification**:
- Guarded detached `lake build` green after each sub-step.
- `grep -rn 'swap_axiom_\|_is_valid\b' FormalSystem/` returns nothing.
- No theorem name is declared in both `FormalSystem.Metalogic` and
  `FormalSystem.Metalogic.SoundnessLemmas`.
- `grep -rn '\bvalid\b' FormalSystem/Automation/` is unchanged from its pre-phase state.

---

### Phase 11: Final verification and acceptance [NOT STARTED]

**Goal**: Run the full gate set and check every restated acceptance criterion, replacing the two
criteria research showed to be unachievable or vacuous.

**Tasks**:
- [ ] Full guarded detached `lake build`.
- [ ] `lake build BimodalTest` (guarded, detached).
- [ ] `bash scripts/check-module-invariants.sh` — C1/C2/C14 unchanged. Confirm specifically that
      the eight pinned names are untouched: `BXCanonical.{completeness, completeness_dense,
      completeness_discrete}`, `Chronicle.countermodel_dense`, `Decidability.sound_of_isValid`,
      `completeness_dedekind`, `strongCompletenessBase`, `strongCompletenessDense`.
- [ ] Confirm the executable `sorry` count is unchanged and that no new axiom was introduced
      (`lean_verify` on a representative renamed theorem in each touched namespace, expecting
      `[propext, Classical.choice, Quot.sound]`).
- [ ] Run every acceptance grep from Phases 7, 9 and 10 one final time and record the outputs.
- [ ] Write the implementation summary, including: the Plan A/B outcome from Phase 1, the measured
      pre/post adapter counts, the measured rename counts, and any Scope Hypothesis that came back
      different from the plan-time figure.

**Timing**: 1 hour

**Depends on**: 10

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that the C2/C14 baselines pin exactly eight theorem names
and that none of them is renamed by this task (research-verified at plan time, before any rename
ran). Re-derive the pinned set from `scripts/module-invariants-manifest.txt` /
`module-invariants-allowlist.txt` rather than from this plan's list, and check the *derived* set
against the working tree. It also asserts the executable `sorry` count is unchanged; establish
that baseline by content, never by line number.

**Files to modify**:
- `specs/522_frame_property_representation_and_validity_names/summaries/01_frame-property-validity-names-summary.md`

**Verification**: see Testing & Validation below — this phase *is* the gate.

---

## Testing & Validation

Acceptance criteria, restated per research §8 (two of the task's original criteria are replaced):

- [ ] **Binder adapters 47 → 12**, every survivor indexed by `fc : FrameClass` or
      `P : TaskFrame → Prop`; zero adapters mention a literal tag. Checked by:
      ```
      grep -rEn '\.(of_forall|apply|of_not)\b' FormalSystem/ | grep -E 'Valid(Dense|Discrete|Dedekind)|SemanticConsequence(Dense|Discrete|Dedekind)|SetSemanticConsequence(Base|Dense|Discrete|Dedekind)'
      ```
      returns nothing. *(Replaces the task's `47 → 2 (+2 BL)`, which research proved unachievable:
      three carriers, and the `ValidOnFrames` layer needs its own triple.)*
- [ ] **`SatisfiableSet` 4 → 1.**
- [ ] **Every `ValidX` is definitionally `ValidIn .X`**, and `ValidComplete` is the sole
      `ValidOnFrames`-level name, documented once.
- [ ] **At most one site in `FormalSystem/` warns that a `Valid*` name is not its apparent `ValidIn`
      tag, and it is on `ValidComplete`.** *(Replaces "grep finds one 'Read this first' paragraph",
      which is already vacuously true today — exactly one such literal exists in `FormalSystem/`.)*
- [ ] **The five monotonicity/inclusion lemmas in `BLValidity.lean` are corollaries of the two
      transfer theorems**; `blValid_iff_empty_consequence` and the `BLValidDiscreteSucc` layer are
      documented exceptions, as are `df_valid_of_succOrder` / `df_valid_of_isLeast_pos`.
- [ ] **`lake build` green**, run detached and guarded.
- [ ] **`lake build BimodalTest` green.**
- [ ] **C2/C14 baselines unchanged** via `scripts/check-module-invariants.sh`; none of the eight
      pinned names renamed; no `14/21/42/44 axiom` literal introduced.
- [ ] **Zero new `sorry`, zero new axiom.**
- [ ] **The two naming-deviation-of-record blocks survive** the warning collapse.
- [ ] **`FormalSystem/Automation/**` is untouched** by the `valid → Valid` rename.
- [ ] **The `HasDedekind*` canonical layer is untouched**: the count of declared identifiers
      containing `Dedekind` but not `Valid` is unchanged.

## Artifacts & Outputs

- `specs/522_frame_property_representation_and_validity_names/plans/01_frame-property-validity-names.md` (this file)
- `specs/522_frame_property_representation_and_validity_names/summaries/01_frame-property-validity-names-summary.md`
- Modified Lean sources under `FormalSystem/Semantics/` and `FormalSystem/Metalogic/` per the
  per-phase file lists (superset of the task's declared `file_scope`; the additional files are the
  scattered call sites enumerated in Phase 6 and the rename fan-out in Phase 9).

## Rollback/Contingency

- **Per phase**: each phase is committed only when its verification is green, so `git revert` of a
  single phase commit restores the previous green state. Phases 1 and 7 are `atomic-batch`, so each
  is a single revertible commit.
- **Phase 1 specifically**: if the full build regresses under `@[reducible] FrameClass.Sat`, do not
  attempt to fix forward through unification errors. Revert the `@[reducible]` attribute only,
  keeping `abbrev IsDense`, and continue under Plan B — the Plan B `sat_intro` variant is
  machine-checked PASS at all four tags and needs no reducibility change. Record the switch.
- **Phase 9/10 renames**: each sub-step is its own commit. If a rename sub-step goes red in a way
  that is not a mechanical missed site, revert that sub-step's commit rather than patching, and
  re-derive the identifier-exact pattern.
- **Never** discard uncommitted work to reach a green build. Fix forward, or take
  `bash .claude/scripts/git-snapshot.sh 522` before any intentional rollback.
