# Research Report: Task #641

**Task**: 641 - Worked example walkthrough for outside readers
**Started**: 2026-09-20T00:00:00Z
**Completed**: 2026-09-20T00:00:00Z
**Effort**: Medium (one implementation round, ~5 phases; every load-bearing Lean step below was
compiled and axiom-audited during research, so the residual risk is prose and wiring, not proof)
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/MainResults.lean`, `FormalSystem/Metalogic/Soundness.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`,
  `FormalSystem/Metalogic/SetConsequence.lean`,
  `FormalSystem/Metalogic/DiscreteNonCompactness.lean`,
  `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`,
  `FormalSystem/Metalogic/Decidability/Correctness.lean`,
  `FormalSystem/ProofSystem/Derivation.lean`, `FormalSystem/ProofSystem/Derivable.lean`,
  `FormalSystem/ProofSystem/Axioms.lean`,
  `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`,
  `FormalSystem/Semantics/FrameProperty.lean`,
  `FormalSystem/Semantics/Correspondence/DurationFrames.lean`,
  `FormalSystem/Semantics/Frames/Standard.lean`,
  `FormalSystem/Automation/Tactics/Commands.lean`,
  `FormalSystem/Examples/BimodalProofs.lean`, `FormalSystem/Examples.lean`)
- Harness (`scripts/check-module-invariants.sh`, `scripts/debug-artifact-allowlist.txt`,
  `scripts/warning-budget.txt`, `scripts/readme-lint.sh`, `lakefile.toml`)
- Eleven compiled probe files run through `lake env lean` against the live build
- No literature source referenced by this task; the Literature Extraction Protocol does not apply
**Artifacts**:
- specs/641_worked_example_walkthrough_for_outside_readers/reports/01_worked-example-walkthrough.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every one of the six required legs compiles today and is axiom-clean.** Each was written as
  a standalone probe and run through `lake env lean` against the current build: the by-hand
  derivation tree, the `modal_search` automation twin, `soundness_validIn`, `completeness_base`,
  the tableau `isValid` verdict plus `isValid_sound`, the `Dense`-derivable / `Base`- and
  `ZTime`-underivable density instance, and the `notStrongCompletenessZTime` restatement.
  `#print axioms` on each reports `[propext]` or `[propext, Classical.choice, Quot.sound]` —
  never more. A sorry-free path exists end to end; no approach in this report defers anything.
- **The single biggest unknown is closed: `isValid φ = true` is provable by plain `by decide`.**
  `isValid ((□p) → p) = true` kernel-reduces in under two seconds and stays at exactly the three
  axioms. `native_decide` is therefore never needed, and must never be used — it would inject
  `Lean.ofReduceBool` and break the acceptance criterion outright.
- **`⊢ φ` is a `Type`, not a `Prop`.** `notation:50 "⊢ " φ => DerivationTree FrameClass.Base [] φ`
  (`ProofSystem/Derivation.lean:361`). Every derivation-tree example must be a `def`, not a
  `theorem`; `theorem` is rejected with "type of theorem is not a proposition". This also means
  the file's derivation examples must carry camelCase names (harness check C26 bans snake_case
  `def`/`abbrev`) and a docstring each (C16's `docBlame`, gated at a zero baseline).
- **Anonymous `example`s cannot be `#print axioms`-audited.** The acceptance criterion forces
  named declarations throughout — a structural departure from `BimodalProofs.lean`, which is
  entirely anonymous `example`s. Recommended: name every declaration, and assert the axiom sets
  in `Tests/BimodalTest/` with `#guard_msgs in #print axioms` (verified working) rather than
  printing them in library code, which would require a `scripts/debug-artifact-allowlist.txt`
  entry under check C27.
- **Recommended approach**: a ~300-line `FormalSystem/Examples/Walkthrough.lean` carrying seven
  named, docstringed declarations in the verified shapes below, plus a companion axiom-assertion
  test file, plus five small wiring edits (aggregator import, two READMEs, root README demo line,
  a stale `docs/` sentence) and one mandatory `--emit-inventory` regeneration.

## Context & Scope

Researched: what a `FormalSystem/Examples/Walkthrough.lean` must contain to satisfy the task's
six content requirements, whether each is reachable sorry-free at the standard three axioms, the
exact type signatures and notation involved, and every harness/wiring obligation that a new file
under `FormalSystem/Examples/` incurs.

Constraints honoured throughout:

- Zero-debt: no `sorry`, no new axiom, no Option-B deferral. Confirmed reachable.
- No Kamp-named declarations may be cited (ADR-011 will rename them). Verified: none of the
  declarations recommended here lives under `Metalogic/WeakCanonical/`, so the file is unaffected
  by that rename. The two names to avoid specifically are
  `Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness` and
  `Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior`.
- No task-number citations anywhere in the new file or in README.md (harness check C9 gates
  `FormalSystem/`, `lakefile.toml`, `README.md` and `scripts/`). The follow-on task that will
  extend this file must not be named inside it.

Out of scope: the larger Examples expansion itself; any change to `BimodalProofs.lean` beyond
leaving it in place.

## Findings

### Codebase Patterns

**What `BimodalProofs.lean` is, and why it does not serve.** 247 lines, every declaration an
anonymous `example`, every body a one-line `perpetuityN _` application. It touches the proof
system only — no semantics, no soundness, no completeness, no decision procedure, no frame
classes. `TemporalStructures.lean` (489 lines) is the sibling. `FormalSystem/Examples.lean` is
the aggregator; both are imported there, and `FormalSystem/FormalSystem.lean:21` imports
`FormalSystem.Examples`, so a new module reaches the build graph the moment the aggregator line
is added.

**Notation and core types (all verified by compilation):**

| Thing | Spelling | Location |
|---|---|---|
| Derivation tree, Base, empty context | `⊢ φ` = `DerivationTree FrameClass.Base [] φ` (a **Type**) | `ProofSystem/Derivation.lean:361` |
| Derivation tree at a class | `⊢[fc] φ` = `DerivationTree fc [] φ` | `ProofSystem/Derivation.lean:351` |
| Prop-valued derivability | `Derivable fc Γ φ := Nonempty (DerivationTree fc Γ φ)` | `ProofSystem/Derivable.lean:69` |
| Validity | `⊨ φ` = `Valid φ` = `ValidIn .Base φ` | `Semantics/Validity.lean:368,374` |
| Class validity | `ValidDense`, `ValidZTime` = `ValidIn .Dense` / `.ZTime` | `Semantics/Validity.lean:473,517` |
| Frame-class interpretation | `FrameClass.Sat`: `.Base ↦ True`, `.Dense ↦ IsDense`, `.ZTime ↦ IsZTime` | `Semantics/FrameClassValidity.lean:118` |

`DerivationTree` has seven constructors: `axiom`, `assumption`, `modus_ponens`, `necessitation`,
`temporal_necessitation`, `time_reflection`, `weakening` (`ProofSystem/Derivation.lean:91-166`).
The `axiom` constructor carries a frame-class gate `h_fc : h.minFrameClass ≤ fc`, which is what
makes frame-class sensitivity structural rather than conventional.

**Automation.** `modal_search` (`Automation/Tactics/Commands.lean:98`) is the tactic that builds
a derivation tree by search; it accepts a bare depth numeral or `(depth := n) (visitLimit := m)`.
It is the right "again with the automation" counterpart to a hand-built tree.

**Soundness / completeness entry points.**

- `soundness_validIn {fc} {φ} (d : DerivationTree fc [] φ) : ValidIn fc φ`
  (`Metalogic/Soundness.lean:1374`) — the class-generic empty-context form. This is the cleanest
  bridge for a walkthrough: one name covers Base and ZTime, and it is what the repository's own
  refutation proofs route through.
- `soundness (Γ) (φ) (d) (F) (M) (τ) (t) (h_ctx) : TruthAt M τ t φ`
  (`Metalogic/Soundness.lean:1436`) — the configuration-level form, if the prose wants to show
  a model, a history and a time explicitly.
- `completeness_base : WeakCompleteness FrameClass.Base`
  (`Metalogic/StrongCompleteness.lean:891`), where
  `WeakCompleteness fc := ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`
  (`Metalogic/SetConsequence.lean:226`). Note the **asymmetry worth a sentence of prose**:
  soundness returns a `DerivationTree`-consuming truth, completeness returns only
  `Derivable` = `Nonempty (DerivationTree …)`. The round trip does not give the tree back.

**Decision procedure.** `DecisionResult φ` has four constructors, one of which (`valid`) carries
a `⊢ φ` witness (`Decidability/DecisionProcedure.lean:80`). `isValid (φ) (fc := .Base) : Bool`
is `(decide φ (fc := fc)).isValid` (`:323`). The soundness bridge is
`sound_of_isValid {φ} (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ`
(`Decidability/Correctness.lean:107`), with the entry-point wrapper
`isValid_sound (φ) (fc) (h : isValid φ fc = true) : ⊨ φ` (`:119`). The converse is open, and the
file's docstring says so — worth quoting to the reader.

**Frame-class sensitivity — the exact materials.** `Axiom.density φ : Axiom (GGφ → Gφ)` has
`minFrameClass = .Dense` (`ProofSystem/Axioms.lean:361,607`), and `¬(Dense ≤ ZTime)` is a
`by decide` fact the axioms file itself records at `:583`. The underivability half is supplied
by `Semantics/Correspondence/DurationFrames.lean`, which exports the public witness frame
`permissiveFrame D so nm`, its reference history `permissiveHist`, its model `permissiveModel`
and the realisation lemma `permissive_realizes`. Over `ℤ` these give a concrete "blip"
countermodel (an atom false at exactly one point) that refutes the density instance at a named
formula — strictly better than the schema-level statement `validOn_dn_iff_denselyOrdered` alone
yields, and the same frame is simultaneously `IsZTime` via `TaskFrame.isZTime_of_instances`,
so **one countermodel discharges both the `Base` and the `ZTime` leg**.

**The refutation to restate.** `notStrongCompletenessZTime : ¬ StrongCompletenessZTime`
(`Metalogic/DiscreteNonCompactness.lean:292`), refuted by the Archimedean witness family
`archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}`: every finite subset is satisfiable over `ℤ`, the whole
set is satisfiable nowhere Archimedean-discrete, so compactness fails and strong completeness
with it. That two-sentence gloss is exactly the "sentence on what it means" the task asks for,
and it is the fact that explains why the completeness table has four weak rows and only two
strong ones.

### Verified Lean shapes

Everything in this subsection was compiled. Axiom audits are the kernel's own output.

**1-2. By hand, and again with the automation** — `[propext]` each:

```lean
/-- atom -/
def pF : Formula := Formula.atomS "p"
/-- Modal T instance -/
def tFml : Formula := pF.box.imp pF

def tByHand : ⊢ tFml := DerivationTree.axiom [] _ (Axiom.modal_t pF) (by decide)
def tByAuto : ⊢ tFml := by modal_search
```

A multi-node hand tree, for prose that wants to show structure rather than a single leaf
(`[propext]`):

```lean
def boxedT : ⊢ (pF.box.imp pF).box :=
  DerivationTree.necessitation _ (DerivationTree.axiom [] _ (Axiom.modal_t pF) (by decide))
```

**3-4. Soundness out, completeness back** — `[propext, Classical.choice, Quot.sound]` each:

```lean
theorem tValid : ⊨ tFml := soundness_validIn tByHand
theorem tDerivable : Derivable FrameClass.Base [] tFml := completeness_base tFml tValid
```

**5. The tableau, and its soundness bridge** — `[propext, Classical.choice, Quot.sound]` each,
total elaboration under two seconds:

```lean
theorem tIsValid : isValid tFml = true := by decide
theorem tValidViaTableau : ⊨ tFml := isValid_sound tFml FrameClass.Base tIsValid
```

**6. The frame-class-sensitive formula.** Derivable at `Dense` (`[propext]`); note `le_refl _`,
not `by decide` — `by decide` fails on a schematic `φ` with "Expected type must not contain free
variables", and `by decide +revert` then fails to synthesize `Decidable` under the binder:

```lean
def ggFml : Formula :=
  (Formula.atom (Atom.mkBase "p")).allFuture.allFuture.imp
    (Formula.atom (Atom.mkBase "p")).allFuture

def ggAtDense : DerivationTree FrameClass.Dense [] ggFml :=
  DerivationTree.axiom [] _ (Axiom.density (Formula.atom (Atom.mkBase "p"))) (le_refl _)
```

The countermodel (compiled; `[propext, Classical.choice, Quot.sound]`):

```lean
abbrev Dz : TemporalOrder := TemporalOrder.of ℤ
noncomputable instance instSuccDz : SuccOrder Dz.carrier := inferInstanceAs (SuccOrder ℤ)
instance instNoMaxDz : NoMaxOrder Dz.carrier := inferInstanceAs (NoMaxOrder ℤ)

noncomputable def blipF : Dz.carrier → Bool := fun t => decide (t ≠ (1 : ℤ))
noncomputable abbrev blipFrame : TaskFrame :=
  (permissiveFrame Dz instSuccDz instNoMaxDz).toTaskFrame

theorem gapStep (s r : ℤ) (hs : 0 < s) (hr : s < r) : r ≠ 1 := by omega

theorem blipFrame_isZTime : blipFrame.IsZTime := TaskFrame.isZTime_of_instances _
theorem blipRefutes : ¬ blipFrame.ValidOn ggFml := by … -- ~16 lines, compiled
theorem notValidGg : ¬ Valid ggFml := fun h => blipRefutes (h _ trivial)
theorem notValidZTimeGg : ¬ ValidZTime ggFml := fun h => blipRefutes (h _ blipFrame_isZTime)
```

and the two underivability conclusions, via the same `soundness_validIn`:

```lean
theorem ggNotBase : ¬ Derivable FrameClass.Base [] ggFml := fun ⟨d⟩ => notValidGg (soundness_validIn d)
theorem ggNotZTime : ¬ Derivable FrameClass.ZTime [] ggFml := fun ⟨d⟩ => notValidZTimeGg (soundness_validIn d)
```

**Two arithmetic traps found and solved.** `omega` does **not** see hypotheses whose `<`/`≤`
lives at `Dz.carrier` even after an `(x : ℤ)` ascription — it silently drops them and reports an
unprovable goal. The fix that worked is to state the arithmetic step as a separate lemma over
plain `ℤ` (`gapStep` above) and discharge the carrier-typed goal by `exact`, letting definitional
equality do the transport. Likewise, time points must be written `((0 : ℤ) : Dz.carrier)` at
application sites, and `(Dz : Type)` is a parse trap — it ascribes the `TemporalOrder` itself;
write `Dz.carrier`.

**7. The refutation restatement** — `[propext, Classical.choice, Quot.sound]`:

```lean
theorem zTimeStrongCompletenessFails : ¬ StrongCompletenessZTime := notStrongCompletenessZTime
```

### Harness and wiring obligations

Read out of `scripts/check-module-invariants.sh`, `lakefile.toml` and `scripts/readme-lint.sh`.
These are the non-obvious ones; a phase that skips any of them will go red.

| Obligation | Source | Note |
|---|---|---|
| **INV inventory regeneration is mandatory** | root `README.md:19` block, `FormalSystem/README.md` | Adding one `.lean` file changes the "Live `.lean` files"/"Live lines" totals. Run `bash scripts/check-module-invariants.sh --emit-inventory`, then `--emit-inventory --check`. |
| C27 debug directives | `scripts/debug-artifact-allowlist.txt` | Any `#check`/`#eval`/`#print`/`#reduce` in `FormalSystem/**` needs an allowlist entry with a reason line and an **exact directive count**, in both directions. `MainResults.lean 54` is the only current entry (54 = its directive count, not its line count). |
| C26 naming | check C26 | snake_case `def`/`abbrev` names are banned. Derivation-tree examples are `def`s ⇒ camelCase. `theorem` names may stay snake_case. |
| C16 `docBlame` | `scripts/nolints.json` | Zero-baseline; every new public `def` needs a docstring. |
| C28 warning budget | `scripts/warning-budget.txt` | Baseline is **0 warnings across 0 files**. `linter.hashCommand` is `blocking` outside the test library. Verified empirically that `#print axioms` does not trip it; `#eval`/`#check` are the risk. |
| C9 task numbers | check C9 | Gates `FormalSystem/`, `README.md`, `scripts/`. No "task N" text in the new file or the README edit. |
| C14 stale literals | check C14 | Scans `.lean` docstrings for stale axiom counts (`14|21|42|44|45` near "axiom"/"schema"). Do not restate the schema count in the walkthrough; if it must be stated, the live figure is 29. Also: do not transcribe expected `#print axioms` output into prose — `MainResults.lean`'s header records that this exact practice drifted before. |
| C24 `Init` import | `lake exe checkInitImports` | Inherited transitively through any `FormalSystem.*` import; satisfied automatically. |
| `autoImplicit = false`, `longFile = 1500` | `lakefile.toml` | All binders explicit; keep the file well under 1500 lines. |
| README listing (ungated) | `scripts/readme-lint.sh` check 2/4 | Add a row to `FormalSystem/Examples/README.md` and bump its `*Last verified: …*` line. |

**Text edits the task implies, located:**

- `README.md:11` — the sole `**Demo**:` link, currently `[BimodalProofs.lean](FormalSystem/Examples/BimodalProofs.lean) — sorry-free demonstration proofs`. This is the line to repoint.
- `FormalSystem/Examples.lean` — aggregator import plus its `## Modules` bullet list.
- `FormalSystem/Examples/README.md` — contents table row.
- `docs/project-info/known-limitations.md:112` — asserts `FormalSystem/Examples/` "contains exactly two files"; goes stale.
- `docs/user-guide/examples.md:5,958` — canonical-import prose and a module list; a walkthrough pointer belongs here.

### External Resources

None consulted. Every fact above is from the repository or from a compiled probe against it;
no Mathlib search tool was needed, because the task is an assembly of existing in-tree results
rather than a hunt for a missing lemma.

### Recommendations

1. **Write the walkthrough with named declarations throughout**, not anonymous `example`s. This
   is forced by the acceptance criterion (`#print axioms` cannot name an anonymous example) and
   is the structural difference from `BimodalProofs.lean` that makes the file auditable.
2. **Assert the axiom sets in the test library, not in the library file.** Add
   `Tests/BimodalTest/WalkthroughAxioms.lean` with one `#guard_msgs in #print axioms` per named
   declaration (verified working: a wrong expected string fails the build), import it from
   `Tests/BimodalTest.lean`, and keep `FormalSystem/Examples/Walkthrough.lean` free of debug
   directives. This satisfies the acceptance criterion *as an assertion* rather than as scrollback,
   needs no `debug-artifact-allowlist.txt` edit, and matches the allowlist header's own stated
   preference ("Executable probes belong in `Tests/BimodalTest/`").
   *Alternative, if the file is wanted to read like `MainResults.lean`*: put the `#print axioms`
   lines in the walkthrough and add one allowlist entry with an exact count. This is admissible
   under the allowlist's bar but is brittle — the count must be updated on every added or removed
   directive, in both directions.
3. **Use `soundness_validIn` as the soundness bridge**, and show `soundness` at a configuration
   only if the prose wants a model/history/time on screen. One name then covers the `Base` leg,
   the `ZTime` leg and the underivability arguments.
4. **Build the frame-class-sensitivity section around one concrete formula and one concrete
   countermodel** — the ℤ blip on `permissiveFrame` — rather than around the schema-level
   `validOn_dn_iff_denselyOrdered`. It names a formula the reader can hold in mind, and the
   single frame discharges both the `Base` and the `ZTime` leg because it is simultaneously
   unconstrained and `IsZTime`.
5. **Never use `native_decide`.** `by decide` suffices for the tableau verdict at the sizes
   involved and keeps the axiom set at three. If a later, larger formula ever makes `by decide`
   slow, shrink the formula — do not reach for `native_decide`, which injects
   `Lean.ofReduceBool` and fails the acceptance criterion.
6. **Suggested phase decomposition** (each sized to one agent run):
   - P1 — file skeleton, header, module docstring, aggregator import, atom/formula definitions,
     the by-hand and `modal_search` derivations. Green build.
   - P2 — soundness and completeness sections, with the `DerivationTree` vs `Derivable`
     asymmetry written out.
   - P3 — tableau section: `isValid`, `by decide`, `isValid_sound`, and the prose noting the
     converse is open.
   - P4 — frame-class sensitivity: `ggAtDense`, the blip countermodel, `ggNotBase`, `ggNotZTime`;
     plus the `notStrongCompletenessZTime` restatement and its gloss.
   - P5 — wiring and harness: test file with `#guard_msgs`, `Tests/BimodalTest.lean` import,
     README/demo/doc edits, `--emit-inventory` regeneration, full
     `bash scripts/check-module-invariants.sh` run.

## Decisions

- **Named declarations over anonymous `example`s** — forced by the audit requirement.
- **`def` not `theorem` for derivation trees** — forced by `DerivationTree : … → Type`.
- **`#guard_msgs` in the test library as the primary audit route** — chosen over an allowlist
  entry, on brittleness grounds; the alternative is recorded above rather than discarded.
- **One concrete countermodel, reused for `Base` and `ZTime`** — chosen over two separate
  arguments, and over the schema-level correspondence theorem.
- **`le_refl _` for the `Dense` axiom gate** — `by decide` and `by decide +revert` were both
  tried and both fail on a schematic formula variable.
- **Arithmetic side conditions stated at `ℤ` in their own lemma** — chosen after `omega` was
  observed to silently drop carrier-typed hypotheses.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| `by decide` on `isValid` is fast for `□p → p` but may not be for a bigger formula | Medium | Keep the tableau example at the size probed (~2 s). If a richer formula is wanted, probe it before committing to it. Never substitute `native_decide`. |
| The INV inventory blocks go stale the moment a file is added, failing the harness in a way that looks unrelated to the change | Medium | Make `--emit-inventory` an explicit, named step in the final phase, not an afterthought. |
| `omega` silently dropping carrier-typed hypotheses produces a confusing "could not prove" with no obvious cause | Medium | Already solved: the `gapStep`-at-`ℤ` pattern above. Documented here so the implementer does not rediscover it. |
| C27 fires on a stray `#eval`/`#check` left in the walkthrough during drafting | Low | Keep all directives in `Tests/`; grep the file for `^#` before the final build. |
| Prose accidentally transcribes `#print axioms` output or a schema count, tripping C14 | Low | Follow `MainResults.lean`'s own rule: describe the contract, never transcribe the output. |
| A cited declaration is renamed by ADR-011 | Low | Verified: nothing recommended here lives under `Metalogic/WeakCanonical/`. |
| `docs/` sentences about "exactly two files" in `Examples/` go stale | Low | `docs/project-info/known-limitations.md:112` located; edit it in the wiring phase. |

## Tactic Survey Results

Tactic candidates were exercised directly against the real goals rather than surveyed
abstractly, since every goal here is a concrete named obligation.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `⊢ □p → p` (derivation tree) | `modal_search` | success | default depth |
| `(Axiom.modal_t pF).minFrameClass ≤ .Base` | `decide` | success | closed term |
| `(Axiom.density φ).minFrameClass ≤ .Dense`, schematic `φ` | `decide` | fail | "Expected type must not contain free variables" |
| same | `decide +revert` | fail | cannot synthesize `Decidable (∀ φ, …)` |
| same | `le_refl _` | success | `minFrameClass (density _)` reduces to `.Dense` |
| `isValid ((□p) → p) = true` | `decide` | success | ~2 s; three axioms |
| `¬(FrameClass.Dense ≤ FrameClass.ZTime)` | `decide` | success | in-tree precedent at `Axioms.lean:583` |
| `r ≠ 1` from carrier-typed `0 < s`, `s < r` | `omega` | fail | drops the carrier-typed `<` hypothesis |
| same, restated at `ℤ` | `omega` | success | via a `gapStep (s r : ℤ)` helper + `exact` |
| `blipFrame.IsZTime` | `TaskFrame.isZTime_of_instances _` | success | needs `blipFrame` `abbrev`, not `def` |
| atom truth through the blip history | `simp only [blipF, decide_eq_true_eq]` | success | plus `permissive_realizes` |
| `#guard_msgs in #print axioms` | — | success | asserts the audit string in `Tests/` |

## Context Extension Recommendations

- **Topic**: harness obligations incurred by adding a file to `FormalSystem/`.
- **Gap**: the INV inventory regeneration, the C27 allowlist, the C26 naming rule and the
  zero-baseline warning budget are each documented inside
  `scripts/check-module-invariants.sh`'s own header comments, and nowhere in the agent context.
  Each is individually easy to miss and each produces a red harness that reads as unrelated to
  the change that caused it.
- **Recommendation**: add `context/project/lean4/operations/adding-a-module.md` — a short
  checklist (aggregator import, sibling README row + `Last verified` bump, `--emit-inventory`,
  no debug directives, camelCase `def`s with docstrings, no task numbers) that any Lean
  implementation agent can load before creating a new `.lean` file in this tree.

## Appendix

**Probe files** (scratchpad, disposable — every one compiled against the live build):
`Probe1`–`Probe9`, `ProbeA`–`ProbeD` under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/224432d2-0d1d-4ac6-baed-30da4ace6f23/scratchpad/`.
`ProbeA` holds the full countermodel; `ProbeB` holds the seven-leg skeleton; `ProbeC` holds the
frame-class-sensitivity composition; `ProbeD` holds the `#guard_msgs` audit check.

**Command used throughout**: `lake env lean <probe>.lean`, plus one run with the package's own
options (`-Dlinter.mathlibStandardSet=true -DautoImplicit=false -Dlinter.style.longFile=1500`)
to confirm no linter fires on `#print axioms`.

**Searches**: repository greps only — `soundness`, `completeness_`, `sound_of_isValid`,
`isValid`, `notStrongCompleteness`, `¬ Derivable`, `permissiveFrame`, `IsZTime`, `FrameClass.Sat`,
`Kamp`, `BimodalProofs`, `BEGIN GENERATED: inventory`, plus targeted reads of
`scripts/check-module-invariants.sh` (checks C1–C30), `scripts/debug-artifact-allowlist.txt`,
`scripts/warning-budget.txt`, `scripts/readme-lint.sh` and `lakefile.toml`. No Mathlib search
tool (leansearch / loogle / leanfinder / state_search) was required, and none was rate-limited.

**References**: `FormalSystem/MainResults.lean` (the page whose contract this file should mirror),
`FormalSystem/Metalogic/Independence/README.md` (surveyed; its eight results are L⁺/L⋆-level and
are *not* the right material for this file — the density/`DurationFrames` route is),
`docs/architecture/ADR-011-Extract-Expressiveness.md` (the rename to stay clear of).
