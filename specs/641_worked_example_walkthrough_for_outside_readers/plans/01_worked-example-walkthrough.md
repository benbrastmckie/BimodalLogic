# Implementation Plan: Task #641

- **Task**: 641 - Worked example walkthrough for outside readers
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/641_worked_example_walkthrough_for_outside_readers/reports/01_worked-example-walkthrough.md
- **Artifacts**: plans/01_worked-example-walkthrough.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`FormalSystem/Examples/BimodalProofs.lean` is what the root README currently advertises as the
demo, and it is 247 lines of anonymous one-line `example := perpetuityN _` applications: it
exercises the proof system alone and shows an outside reader none of the metatheory the
repository exists for. This plan adds `FormalSystem/Examples/Walkthrough.lean`, one page a reader
who knows modal logic but not this codebase can open and follow end to end, carrying six legs on
two concrete formulas — a derivation tree built by hand and again by `modal_search`, `soundness`
out to validity, `completeness` back to derivability, the tableau `isValid` verdict with its
`sound_of_isValid` bridge, one frame-class-sensitive formula derivable at `Dense` but refuted at
`Base` and `ZTime` by a single concrete countermodel, and a restatement of
`notStrongCompletenessZTime` with prose saying what it means. Research compiled and
axiom-audited every one of those legs against the live build, so the residual work here is
prose, assembly and wiring rather than proof discovery. Done means: the file exists and is
sorry-free, `lake build` and `bash scripts/check-module-invariants.sh` are green, every named
declaration's axiom set is asserted (not merely observed) at exactly `propext`,
`Classical.choice`, `Quot.sound` or fewer, and the README demo line points here.

### Research Integration

From `reports/01_worked-example-walkthrough.md`, integrated as binding constraints rather than
suggestions:

- **Every leg is already compiled.** The report carries verified Lean shapes for all seven
  declaration groups, each with its observed `#print axioms` result. Phases 1-5 transcribe and
  document those shapes; they do not re-derive them.
- **`⊢ φ` is a `Type`, not a `Prop`** (`ProofSystem/Derivation.lean:361`). Derivation-tree
  declarations must be `def`, not `theorem`, which in turn forces camelCase names (harness check
  C26 bans snake_case `def`/`abbrev`) and a docstring each (C16 `docBlame`, zero baseline).
- **Anonymous `example`s cannot be `#print axioms`-audited**, so the acceptance criterion forces
  named declarations throughout. This is the structural break from `BimodalProofs.lean`.
- **The audit lands in the test library, not the library file.** `Tests/BimodalTest/` gets
  `#guard_msgs in #print axioms` assertions (verified working during research: a wrong expected
  string fails the build), keeping `Walkthrough.lean` free of debug directives and needing no
  `scripts/debug-artifact-allowlist.txt` edit.
- **`by decide` settles `isValid tFml = true`** in about two seconds at exactly three axioms.
  `native_decide` is forbidden outright — it injects `Lean.ofReduceBool` and fails the
  acceptance criterion.
- **One countermodel discharges two legs.** The ℤ "blip" over `permissiveFrame` is
  simultaneously unconstrained and `IsZTime`, so it refutes the density instance at `Base` and
  at `ZTime` from a single construction.
- **Two arithmetic traps are pre-solved**: `le_refl _` (not `by decide`) for the `Dense` axiom
  gate on a schematic formula, and a `gapStep`-at-`ℤ` helper lemma because `omega` silently
  drops carrier-typed hypotheses.
- **The harness obligations are enumerated** and become explicit Phase 6 steps rather than an
  afterthought: `--emit-inventory` regeneration, C9/C14/C26/C27/C28 avoidance, the
  `Examples/README.md` row plus its `Last verified` bump.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only (no `roadmap_path` was supplied in the dispatch
context, and the file is not modified by this plan). The item advanced is **Phase 5: Publication
and Documentation** — specifically the `publication_examples_and_demo` entry, which this task
deliberately precedes: the task description states that the follow-on examples expansion extends
`Walkthrough.lean` rather than starting from `BimodalProofs.lean`. Completing this plan therefore
converts that roadmap item's starting point from a one-note perpetuity file into a metatheory
walkthrough.

## Goals & Non-Goals

**Goals**:

- Create `FormalSystem/Examples/Walkthrough.lean`: one sorry-free, docstringed module carrying
  all six required legs on concrete formulas, readable top to bottom by a modal logician who has
  never opened this repository.
- Name every declaration so the kernel's axiom audit can address it, and **assert** each audit in
  the test library rather than leaving it to scrollback.
- Wire the module into the build graph (`FormalSystem/Examples.lean`) and into the reader's path
  (root `README.md` demo line, `FormalSystem/Examples/README.md`, `docs/user-guide/examples.md`),
  and repair the `docs/project-info/known-limitations.md` sentence that goes stale.
- Keep `lake build`, `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`
  green at every phase boundary.
- Lean identifiers introduced (exactly these, all in namespace
  `FormalSystem.Examples.Walkthrough`): `pF`, `tFml`, `ggFml`, `Dz`, `instSuccDz`, `instNoMaxDz`,
  `blipF`, `blipFrame`, `gapStep`, `tByHand`, `tByAuto`, `boxedT`, `tValid`, `tDerivable`,
  `tIsValid`, `tValidViaTableau`, `ggAtDense`, `blipFrame_isZTime`, `blipRefutes`, `notValidGg`,
  `notValidZTimeGg`, `ggNotBase`, `ggNotZTime`, `zTimeStrongCompletenessFails`.

**Non-Goals**:

- The larger Examples expansion. This plan lands one file; the follow-on task extends it.
- Any change to `BimodalProofs.lean` or `TemporalStructures.lean` beyond leaving them in place
  and reclassifying the demo pointer. Neither file is edited.
- Any new metatheory. Every result cited already exists and is proved elsewhere in the tree;
  this module composes and explains, it does not extend.
- Citing any Kamp-named declaration. Nothing under `Metalogic/WeakCanonical/` is referenced, so
  the ADR-011 Expressiveness rename cannot touch this file.
- Using `native_decide`, adding an axiom, or introducing a `sorry` anywhere — including a
  strategic one. This plan has no division points.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `by decide` on `isValid` is fast for `□p → p` but a later, richer formula makes it slow or blows the elaborator | M | L | Keep the tableau leg at exactly the formula research probed (~2 s). If a richer formula is wanted, probe it standalone with `lake env lean` before committing. Never substitute `native_decide` (Phase 3 verification explicitly re-checks the axiom set) |
| The generated INV inventory blocks in `README.md` / `FormalSystem/README.md` go stale the moment a `.lean` file is added, producing a red harness that reads as unrelated to the change | M | H | `--emit-inventory` regeneration is a named, checklisted step in Phase 6, followed by `--emit-inventory --check` |
| `omega` silently drops carrier-typed `<`/`≤` hypotheses, yielding a confusing "could not prove" | M | M | Pre-solved: state the arithmetic step as `gapStep (s r : ℤ)` over plain `ℤ` and discharge the carrier-typed goal by `exact`, letting definitional equality transport it (Phase 4) |
| A stray `#check`/`#eval`/`#print` left in `Walkthrough.lean` during drafting trips C27 (allowlist) or C28 (warning budget, zero baseline, `linter.hashCommand` blocking outside `Tests/`) | M | M | All directives live in `Tests/BimodalTest/WalkthroughAxioms.lean`. Phase 6 greps `^#` in the new library file before the final build |
| Prose transcribes `#print axioms` output or an axiom-schema count, tripping C14's stale-literal scan | L | M | Follow `MainResults.lean`'s own rule: describe the contract, never transcribe the output. Do not restate the schema count |
| Snake_case `def`/`abbrev` name trips C26, or a missing docstring trips C16 | L | M | Declaration inventory is fixed in the Goals list above and is camelCase for every `def`/`abbrev`; every phase's verification includes the module build that surfaces both |
| A task-number citation leaks into the new file or the README edit (C9 gates `FormalSystem/`, `README.md`, `scripts/`) | L | L | The follow-on task is referred to by nature ("the examples expansion"), never by number. Phase 6 runs the full harness, which includes C9 |
| `docs/` sentences asserting `FormalSystem/Examples/` "contains exactly two files" go stale | L | H | `docs/project-info/known-limitations.md:112` located; edited in Phase 6 |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential by
construction: Phases 1-5 all append to the same file (`FormalSystem/Examples/Walkthrough.lean`),
so parallel dispatch would conflict on a single target rather than saving time. Phases 2, 3 and
4 are logically independent of each other and depend only on Phase 1's skeleton; the serial
chain here is a write-contention constraint, not a proof-order one, and an implementer resuming
mid-plan may reorder 2/3/4 freely.

---

### Phase 1: Module skeleton, formulas, and the two derivations [COMPLETED]

**Goal**: `FormalSystem/Examples/Walkthrough.lean` exists, is in the build graph, and carries the
first leg: a derivation tree built by hand and the same theorem found by the automation.

**Tasks**:
- [ ] Create `FormalSystem/Examples/Walkthrough.lean` with the standard copyright header
      (2026, Apache 2.0, Benjamin Brast-McKie) matching `FormalSystem/Examples.lean`
- [ ] Imports: `FormalSystem.Metalogic`, `FormalSystem.Semantics`, `FormalSystem.Automation`
      (mirroring `MainResults.lean` plus the tactic module). Add nothing not actually used
- [ ] Write the `/-! # ... -/` module docstring: what TM is in two sentences, who the file is
      for, and a "How to read this page" roadmap naming the six legs in order. State the axiom
      contract by description (never transcribe `#print axioms` output — C14)
- [ ] Open `namespace FormalSystem.Examples.Walkthrough`
- [ ] Define `pF : Formula` (the atom) and `tFml : Formula` (the modal-T instance
      `pF.box.imp pF`), each with a docstring naming the formula in ordinary modal notation
- [ ] Define `tByHand : ⊢ tFml` via `DerivationTree.axiom [] _ (Axiom.modal_t pF) (by decide)`,
      with a docstring walking the reader through the `axiom` constructor's frame-class gate
      `h_fc : h.minFrameClass ≤ fc` and why it is `by decide` here
- [ ] Define `boxedT : ⊢ (pF.box.imp pF).box` via `DerivationTree.necessitation`, so the reader
      sees a tree with structure rather than a single leaf
- [ ] Define `tByAuto : ⊢ tFml := by modal_search`, with a docstring contrasting the two routes
- [ ] Write the prose note that `⊢ φ` is a `Type` (a tree), not a `Prop` — which is why these
      are `def`s — and that `Derivable` is its `Nonempty` shadow. This is the single most
      load-bearing orientation sentence in the file
- [ ] Add `import FormalSystem.Examples.Walkthrough` to `FormalSystem/Examples.lean` and a
      matching bullet to its `## Modules` list and its `Or import specific example modules`
      code block

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Examples/Walkthrough.lean` - created; header, module docstring, `pF`, `tFml`,
  `tByHand`, `boxedT`, `tByAuto`
- `FormalSystem/Examples.lean` - one import line plus two docstring list entries

**Verification**:
- `lake build FormalSystem.Examples.Walkthrough` green, zero warnings
- `lake build FormalSystem.Examples` green (the one-hop dependent touched by the aggregator edit)
- `grep -n '^#' FormalSystem/Examples/Walkthrough.lean` returns nothing
- No `sorry` in the file

---

### Phase 2: Soundness out, completeness back [NOT STARTED]

**Goal**: The reader sees the tree turned into semantic validity and validity turned back into
derivability, with the asymmetry between the two directions spelled out.

**Tasks**:
- [ ] Add `theorem tValid : ⊨ tFml := soundness_validIn tByHand`, with a docstring saying what
      `⊨` unfolds to (`ValidIn .Base`) and what `soundness_validIn` consumes and produces
- [ ] Add `theorem tDerivable : Derivable FrameClass.Base [] tFml := completeness_base tFml tValid`,
      with a docstring naming `WeakCompleteness fc := ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`
- [ ] Write the asymmetry paragraph: soundness takes a `DerivationTree` and returns a truth;
      completeness returns only `Derivable` = `Nonempty (DerivationTree …)`, so the round trip
      does **not** hand the tree back. Say explicitly that this is a fact about the completeness
      proof being non-constructive, not an oversight in the statement
- [ ] Optionally mention (prose only, no declaration) the configuration-level `soundness` form
      with its explicit model, history and time, and point at `Metalogic/Soundness.lean` for a
      reader who wants to see truth evaluated at a point

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Examples/Walkthrough.lean` - `tValid`, `tDerivable`, plus the asymmetry prose

**Verification**:
- `lake build FormalSystem.Examples.Walkthrough` green, zero warnings
- Both new declarations are `theorem` (they are `Prop`-valued), so C26 does not apply to them
- No `sorry`, no `#` directive in the file

---

### Phase 3: The tableau and its soundness bridge [NOT STARTED]

**Goal**: The reader sees the decision procedure produce a verdict on the same formula, and sees
the verdict converted into the same validity the hand derivation reached.

**Tasks**:
- [ ] Add `theorem tIsValid : isValid tFml = true := by decide`, with a docstring explaining
      that `isValid φ fc = (decide φ (fc := fc)).isValid` and that the kernel is evaluating the
      tableau itself — the proof term is the computation
- [ ] Add `theorem tValidViaTableau : ⊨ tFml := isValid_sound tFml FrameClass.Base tIsValid`
- [ ] Write the prose noting that this reaches the *same* conclusion as `tValid` by a completely
      different route, and that **the converse is open**: a `false` verdict is not in general a
      proof of non-validity. Quote the direction the correctness file itself states rather than
      overclaiming
- [ ] Add an explicit in-file comment that `native_decide` must never replace `by decide` here,
      with the one-line reason (it injects `Lean.ofReduceBool` and breaks the axiom contract)

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Research measured `isValid tFml = true` elaborating by plain `by decide` in
roughly two seconds at exactly three axioms. Confirm at implementation time by timing
`lake build FormalSystem.Examples.Walkthrough` before and after this phase's edit; if the delta
exceeds ~10 seconds, shrink the formula rather than reaching for `native_decide`, and record the
substitution in the phase notes.

**Files to modify**:
- `FormalSystem/Examples/Walkthrough.lean` - `tIsValid`, `tValidViaTableau`, plus the
  converse-is-open prose

**Verification**:
- `lake build FormalSystem.Examples.Walkthrough` green, zero warnings, no timeout
- `grep -n 'native_decide' FormalSystem/Examples/Walkthrough.lean` matches only the prohibition
  comment, never a tactic invocation
- No `sorry` in the file

---

### Phase 4: Frame-class sensitivity, by one concrete countermodel [NOT STARTED]

**Goal**: The reader sees one formula that is derivable at `Dense` and refuted at both `Base` and
`ZTime`, with the refutation carried by a countermodel concrete enough to picture.

**Tasks**:
- [ ] Define `ggFml : Formula` — the density instance `GGp → Gp` at a concrete atom — with a
      docstring giving the formula in ordinary tense notation and saying what density means
- [ ] Define `ggAtDense : DerivationTree FrameClass.Dense [] ggFml` via
      `DerivationTree.axiom [] _ (Axiom.density _) (le_refl _)`. Use `le_refl _`, **not**
      `by decide`: research confirmed `by decide` fails on a schematic formula variable
      ("Expected type must not contain free variables") and `by decide +revert` then fails to
      synthesize `Decidable` under the binder
- [ ] Write the paragraph explaining that the frame-class gate on the `axiom` constructor is
      what makes this structural: `Axiom.density` has `minFrameClass = .Dense`, so the same
      constructor call is simply not type-correct at `Base` or `ZTime`
- [ ] Build the countermodel: `abbrev Dz : TemporalOrder := TemporalOrder.of ℤ`,
      `noncomputable instance instSuccDz`, `instance instNoMaxDz`,
      `noncomputable def blipF : Dz.carrier → Bool := fun t => decide (t ≠ (1 : ℤ))`, and
      `noncomputable abbrev blipFrame : TaskFrame := (permissiveFrame Dz instSuccDz instNoMaxDz).toTaskFrame`.
      `blipFrame` must be an `abbrev`, not a `def`, for `isZTime_of_instances` to apply
- [ ] Add `theorem gapStep (s r : ℤ) (hs : 0 < s) (hr : s < r) : r ≠ 1 := by omega` as a
      standalone `ℤ`-typed helper, with a comment recording *why* it is separate: `omega`
      silently drops hypotheses whose `<` lives at `Dz.carrier`, even under an `(x : ℤ)`
      ascription, so the arithmetic is stated at `ℤ` and transported by definitional equality
- [ ] Add `theorem blipFrame_isZTime : blipFrame.IsZTime := TaskFrame.isZTime_of_instances _`
- [ ] Add `theorem blipRefutes : ¬ blipFrame.ValidOn ggFml`, using `permissive_realizes`,
      `permissiveHist`/`permissiveModel` and `simp only [blipF, decide_eq_true_eq]`. Write time
      points as `((0 : ℤ) : Dz.carrier)`; never write `(Dz : Type)`, which ascribes the
      `TemporalOrder` itself
- [ ] Add `theorem notValidGg : ¬ Valid ggFml := fun h => blipRefutes (h _ trivial)` and
      `theorem notValidZTimeGg : ¬ ValidZTime ggFml := fun h => blipRefutes (h _ blipFrame_isZTime)`,
      with the prose point that **one** frame discharges both because it is simultaneously
      unconstrained (`FrameClass.Sat .Base = True`) and `IsZTime`
- [ ] Add `theorem ggNotBase : ¬ Derivable FrameClass.Base [] ggFml` and
      `theorem ggNotZTime : ¬ Derivable FrameClass.ZTime [] ggFml`, both
      `fun ⟨d⟩ => … (soundness_validIn d)`, and write the paragraph naming this as the standard
      use of soundness: to prove something is *not* derivable, exhibit a model
- [ ] Prose: describe the blip informally ("an atom false at exactly one instant of ℤ") so the
      reader can picture the refutation without reading the proof term

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a fourteen-declaration inventory (`ggFml`, `ggAtDense`,
`Dz`, `instSuccDz`, `instNoMaxDz`, `blipF`, `blipFrame`, `gapStep`, `blipFrame_isZTime`,
`blipRefutes`, `notValidGg`, `notValidZTimeGg`, `ggNotBase`, `ggNotZTime`) and a `blipRefutes`
body of roughly sixteen lines, both taken from the research probe `ProbeA`. Confirm at
implementation time by compiling the section and counting the declarations actually needed; if
the real countermodel needs a helper the probe did not, add it and record the deviation rather
than forcing the shape.

**Files to modify**:
- `FormalSystem/Examples/Walkthrough.lean` - the frame-class-sensitivity section

**Verification**:
- `lake build FormalSystem.Examples.Walkthrough` green, zero warnings
- Every new `def`/`abbrev`/`instance` name is camelCase (C26) and carries a docstring (C16)
- `grep -n 'sorry' FormalSystem/Examples/Walkthrough.lean` returns nothing

---

### Phase 5: The strong-completeness refutation, and a reader-continuity pass [NOT STARTED]

**Goal**: The file closes on a genuine negative result with prose that says what it means, and
reads as one continuous page rather than six stitched sections.

**Tasks**:
- [ ] Add `theorem zTimeStrongCompletenessFails : ¬ StrongCompletenessZTime := notStrongCompletenessZTime`,
      with a docstring restating the result in words
- [ ] Write the two-sentence gloss: the witness family is `{Fp} ∪ {¬Xⁿ p : n ∈ ℕ}`; every finite
      subset is satisfiable over ℤ, the whole set is satisfiable nowhere Archimedean-discrete, so
      compactness fails at `ZTime` and strong completeness with it. Say plainly that this is a
      *result*, not an open gap — weak completeness still holds at `ZTime`; it is the infinite-
      context form that fails
- [ ] Do not cite any declaration under `Metalogic/WeakCanonical/` (the ADR-011 Expressiveness
      rename); verify by grepping the finished file for `Kamp` and for `WeakCanonical`
- [ ] Reader-continuity pass over the whole module: check the "How to read this page" roadmap in
      the module docstring still matches the section order; add one-sentence transitions between
      the six legs; confirm every declaration has a docstring that a newcomer can use; confirm no
      sentence assumes repository-specific vocabulary it has not introduced
- [ ] Re-read the file against C14: no transcribed `#print axioms` output, no restated axiom or
      schema count anywhere in the prose

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Examples/Walkthrough.lean` - `zTimeStrongCompletenessFails`, its gloss, and the
  continuity edits across the module docstring and section transitions

**Verification**:
- `lake build FormalSystem.Examples.Walkthrough` green, zero warnings
- `grep -niE 'kamp|WeakCanonical' FormalSystem/Examples/Walkthrough.lean` returns nothing
- `grep -nE '\b(14|21|29|42|44|45)\b' FormalSystem/Examples/Walkthrough.lean` shows no
  occurrence adjacent to "axiom" or "schema"
- File is comfortably under the 1500-line `longFile` limit

---

### Phase 6: Axiom assertions, wiring, inventory, and the full harness [NOT STARTED]

**Goal**: The acceptance criterion is asserted rather than observed, the module is reachable from
every place a reader would look, and the whole repository harness is green.

**Tasks**:
- [ ] Create `Tests/BimodalTest/WalkthroughAxioms.lean`: import
      `FormalSystem.Examples.Walkthrough`, and for each named declaration write
      `#guard_msgs in #print axioms FormalSystem.Examples.Walkthrough.<name>` with the expected
      string. This makes a drift a build failure, not a scrollback diff
- [ ] Add `import BimodalTest.WalkthroughAxioms` to `Tests/BimodalTest.lean`
- [ ] Confirm every asserted axiom set is `[propext]` or
      `[propext, Classical.choice, Quot.sound]` and nothing more. Any other axiom — in
      particular `Lean.ofReduceBool` — is a hard stop, not a new baseline
- [ ] Repoint the root `README.md` `**Demo**:` link (line 11) from `BimodalProofs.lean` to
      `[Walkthrough.lean](FormalSystem/Examples/Walkthrough.lean)` with a one-clause description
      ("a worked end-to-end walkthrough: derivation, soundness, completeness, decision procedure,
      frame-class sensitivity"). No task numbers anywhere in this edit (C9)
- [ ] Add a `Walkthrough.lean` row to `FormalSystem/Examples/README.md`'s Contents table,
      extend its Purpose bullets, and bump its `*Last verified: …*` line to today
- [ ] Update `docs/project-info/known-limitations.md:112` — the "contains exactly two files"
      sentence — to reflect three files, keeping the resolved-limitation framing intact
- [ ] Update `docs/user-guide/examples.md`: add `Walkthrough.lean` to the Additional Resources
      Lean-source list (~line 958) and mention it in the canonical-import prose (~line 5) as the
      recommended starting point
- [ ] `grep -n '^#' FormalSystem/Examples/Walkthrough.lean` — must return nothing, so no
      `scripts/debug-artifact-allowlist.txt` entry is needed (C27)
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate the INV
      blocks in `README.md` and `FormalSystem/README.md`, then
      `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm a second
      rewrite would change nothing
- [ ] Run the full `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a six-file wiring set beyond the new test file
(`Tests/BimodalTest.lean`, `README.md`, `FormalSystem/Examples/README.md`,
`docs/project-info/known-limitations.md`, `docs/user-guide/examples.md`, plus the
`--emit-inventory`-regenerated `FormalSystem/README.md`), and a twenty-four-declaration audit
inventory. Confirm both at implementation time: run
`grep -rn 'BimodalProofs' README.md docs/ FormalSystem/ --include='*.md' --include='*.lean'` to
find any additional demo-pointer site the research sweep missed, and count the actual named
declarations in the finished `Walkthrough.lean` rather than trusting the plan-time figure. Record
any additional site found.

**Files to modify**:
- `Tests/BimodalTest/WalkthroughAxioms.lean` - created; one `#guard_msgs in #print axioms` per
  named walkthrough declaration
- `Tests/BimodalTest.lean` - one import line
- `README.md` - the `**Demo**:` link on line 11, plus regenerated INV inventory block
- `FormalSystem/README.md` - regenerated INV inventory block
- `FormalSystem/Examples/README.md` - Contents row, Purpose bullets, `Last verified` bump
- `docs/project-info/known-limitations.md` - the "exactly two files" sentence near line 112
- `docs/user-guide/examples.md` - module list (~958) and canonical-import prose (~5)

**Verification**:
- `lake build` green across the whole package including the test library, zero warnings
  (C28 baseline is 0 warnings across 0 files)
- `bash scripts/check-module-invariants.sh` exits 0 — all of C9, C14, C16, C24, C26, C27, C28
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `grep -rn 'sorry' FormalSystem/Examples/Walkthrough.lean Tests/BimodalTest/WalkthroughAxioms.lean`
  returns nothing
- The `#guard_msgs` assertions pass, which *is* the `#print axioms` acceptance criterion

---

## Lean Challenge Statements

All declarations live in `namespace FormalSystem.Examples.Walkthrough`. The identifier set below
is exactly the identifier set named in the `- **Goals**:` Lean-identifier bullet. Derivation-tree
declarations are `def`/`abbrev` rather than `theorem` because `DerivationTree` is `Type`-valued
(`⊢ φ` notation, `ProofSystem/Derivation.lean:361`); `theorem` is rejected there with "type of
theorem is not a proposition".

```lean
import FormalSystem.Metalogic
import FormalSystem.Semantics
import FormalSystem.Automation

namespace FormalSystem.Examples.Walkthrough

/-- The atom the modal leg is stated at. -/
def pF : Formula := sorry

/-- The modal-T instance `□p → p`. -/
def tFml : Formula := sorry

/-- The density instance `GGp → Gp`. -/
def ggFml : Formula := sorry

/-- The integers as a temporal order. -/
abbrev Dz : TemporalOrder := sorry

/-- Successor structure on the integer carrier. -/
noncomputable instance instSuccDz : SuccOrder Dz.carrier := sorry

/-- The integer carrier has no maximum. -/
instance instNoMaxDz : NoMaxOrder Dz.carrier := sorry

/-- The blip valuation: the atom is false at exactly one instant. -/
noncomputable def blipF : Dz.carrier → Bool := sorry

/-- The permissive integer frame carrying the blip. -/
noncomputable abbrev blipFrame : TaskFrame := sorry

/-- Arithmetic side condition, stated at `Int` so that `omega` sees it. -/
theorem gapStep (s r : ℤ) (hs : 0 < s) (hr : s < r) : r ≠ 1 := sorry

/-- `□p → p`, derived by hand from the modal-T axiom. -/
def tByHand : DerivationTree FrameClass.Base [] tFml := sorry

/-- `□p → p`, found by the proof-search automation. -/
def tByAuto : DerivationTree FrameClass.Base [] tFml := sorry

/-- A two-node tree: necessitation applied to the modal-T leaf. -/
def boxedT : DerivationTree FrameClass.Base [] tFml.box := sorry

/-- Soundness carries the tree to semantic validity. -/
theorem tValid : Valid tFml := sorry

/-- Completeness carries validity back to derivability (but not to a tree). -/
theorem tDerivable : Derivable FrameClass.Base [] tFml := sorry

/-- The tableau decision procedure returns a valid verdict, by kernel computation. -/
theorem tIsValid : isValid tFml FrameClass.Base = true := sorry

/-- The verdict, converted to validity by the decision procedure's soundness bridge. -/
theorem tValidViaTableau : Valid tFml := sorry

/-- The density instance is derivable at the Dense frame class. -/
def ggAtDense : DerivationTree FrameClass.Dense [] ggFml := sorry

/-- The blip frame is an integer-time frame. -/
theorem blipFrame_isZTime : blipFrame.IsZTime := sorry

/-- The blip frame refutes the density instance. -/
theorem blipRefutes : ¬ blipFrame.ValidOn ggFml := sorry

/-- The density instance is not valid at the Base frame class. -/
theorem notValidGg : ¬ Valid ggFml := sorry

/-- The density instance is not valid at the ZTime frame class. -/
theorem notValidZTimeGg : ¬ ValidZTime ggFml := sorry

/-- Hence the density instance is not derivable at Base. -/
theorem ggNotBase : ¬ Derivable FrameClass.Base [] ggFml := sorry

/-- Hence the density instance is not derivable at ZTime either. -/
theorem ggNotZTime : ¬ Derivable FrameClass.ZTime [] ggFml := sorry

/-- Strong completeness fails at ZTime: a proved refutation, not an open gap. -/
theorem zTimeStrongCompletenessFails : ¬ StrongCompletenessZTime := sorry

end FormalSystem.Examples.Walkthrough
```

## Decisions

- **Named declarations throughout, not anonymous `example`s.** Forced by the acceptance
  criterion: `#print axioms` cannot address an anonymous example. This is the structural break
  from `BimodalProofs.lean` and is deliberate.
- **The axiom audit lives in `Tests/BimodalTest/`, asserted with `#guard_msgs`, not printed in
  library code.** Chosen over the alternative (`#print axioms` in the walkthrough plus a
  `debug-artifact-allowlist.txt` entry with an exact directive count) on brittleness grounds:
  the allowlist count must be maintained in both directions on every added or removed directive.
  The alternative remains admissible if a later reader wants the file to read like
  `MainResults.lean`.
- **One concrete countermodel, reused for `Base` and `ZTime`**, rather than two separate
  arguments or the schema-level `validOn_dn_iff_denselyOrdered`. It gives the reader a formula
  and a picture instead of a correspondence theorem.
- **`soundness_validIn` as the single soundness bridge**, with the configuration-level
  `soundness` mentioned in prose only. One name then covers the positive leg, the `ZTime` leg
  and both underivability arguments.
- **`le_refl _` for the `Dense` axiom gate**, not `by decide`: both `by decide` and
  `by decide +revert` were tried during research and both fail on a schematic formula variable.
- **`by decide` for the tableau verdict; `native_decide` is prohibited.** The prohibition is
  written into the file as a comment so a later editor does not "optimize" it away.
- **Sequential phases despite logical independence.** Phases 2, 3 and 4 depend only on Phase 1,
  but all write the same file; the serial chain avoids write contention, not a proof-order
  hazard.

## Testing & Validation

- [ ] `lake build` green across the whole package, including the test library
- [ ] Zero new warnings (`scripts/warning-budget.txt` baseline is 0 across 0 files;
      `linter.hashCommand` is blocking outside `Tests/`)
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (C9 task numbers, C14 stale literals,
      C16 docstring coverage, C24 `Init` imports, C26 naming, C27 debug directives, C28 warnings)
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 after
      regeneration
- [ ] `bash scripts/readme-lint.sh` exits 0
- [ ] `#guard_msgs in #print axioms` passes for every named walkthrough declaration, each at
      `[propext]` or `[propext, Classical.choice, Quot.sound]` and nothing more
- [ ] No `sorry` in `FormalSystem/Examples/Walkthrough.lean` or
      `Tests/BimodalTest/WalkthroughAxioms.lean`
- [ ] No `Kamp`/`WeakCanonical` citation in the new file
- [ ] `import FormalSystem.Examples.Walkthrough` resolves from a scratch file, confirming the
      module is genuinely reachable by a reader following the README

## Artifacts & Outputs

- `FormalSystem/Examples/Walkthrough.lean` — the walkthrough module (new; expected ~300 lines)
- `Tests/BimodalTest/WalkthroughAxioms.lean` — the axiom-set assertions (new)
- `FormalSystem/Examples.lean` — aggregator import and module list
- `Tests/BimodalTest.lean` — test aggregator import
- `README.md` — repointed `**Demo**:` link; regenerated INV inventory block
- `FormalSystem/README.md` — regenerated INV inventory block
- `FormalSystem/Examples/README.md` — Contents row, Purpose bullets, `Last verified` bump
- `docs/project-info/known-limitations.md` — the "exactly two files" sentence
- `docs/user-guide/examples.md` — module list and canonical-import prose
- `specs/641_worked_example_walkthrough_for_outside_readers/summaries/01_*-summary.md` — written
  at implementation completion

## Rollback/Contingency

This plan is almost entirely additive: two new files plus small, localized edits to seven
existing ones. Every phase boundary is a green build, and every green sub-step is committed
(`Commit Mode: per-substep` throughout), so the ordinary recovery move is `git revert` of the
last phase commit rather than any working-tree surgery.

- **A phase goes red mid-work**: fix forward. Every leg was compiled during research, so a red
  build here means a transcription slip, not an unreachable goal. The report's Appendix names
  the probe files (`ProbeA` holds the countermodel, `ProbeC` the frame-class composition) whose
  shapes can be re-derived from the report body if the scratchpad has been cleared.
- **The tableau leg proves too slow**: shrink the formula, re-run the phase, and record the
  substitution. Do not reach for `native_decide` — that fails the acceptance criterion.
- **The whole change must be backed out**: `git revert` the phase commits in reverse order, then
  re-run `bash scripts/check-module-invariants.sh --emit-inventory` to restore the inventory
  blocks to their pre-change totals.
- **A genuine working-tree rollback is needed** (uncommitted work must be discarded): take a
  snapshot first per `context/contracts/recovery.md`'s rollback rung, including its
  out-of-scope override flag for the deliberate whole-tree case, and only then run the
  destructive command. Do not emit a bare precautionary snapshot at the start of a phase; a
  defensive checkpoint before risky work uses the non-reverting `--no-revert` form instead.
