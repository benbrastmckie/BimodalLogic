# Research: Wire the BiLasso Decision Layer into the Live Tree

**Task**: 474 · **Type**: lean4 · **Session**: sess_1787618565_717c84_474 · **Dispatch**: 13
**Date measured**: 2026-08-24 · **Tree at**: `4ba8522dd`
**Classification confirmed**: routine engineering. No mathematics is required, and none is proposed below.

---

## Executive summary

Every claim in the task description was re-measured against the tree as it stands, and every one
holds. Beyond confirming them, four things were established that the task description does not
state and that the plan must carry:

1. **The 15 / 4 / 1 split is exact**, and was verified not by counting lines but by re-running
   the *reachability algorithm `check-module-invariants.sh` itself uses* against a simulated
   post-edit import graph. Unreachable modules go 37 → 22. The 15 that flip are exactly the
   aggregator plus its 14 imports. `Extend`/`Successor`/`Orbit`/`Agreement`,
   `Semantics.Extension.PeriodicExtension`, and everything else stay unreachable.
2. **The three probes merge into one module and compile clean, sorry-free, right now.** The merged
   form was built with `lake env lean` this session: exit 0, no errors, no warnings, and all five
   declarations measure `[propext, Classical.choice, Quot.sound]`. Two duplicate copies of
   `not_validDiscrete_of_satAtState` and one primed variant collapse into a single declaration.
3. **A manifest comment, if obeyed literally, breaks C6.** The
   `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` block says "DELETE this line when the
   bi-lasso re-export lands and the modules above are wired in." Deleting it fails C6, because
   that test module *remains unreachable* after this task's edit. The line must stay and its
   comment must be rewritten. This is a 16th manifest line — a comment edit, not a deletion.
4. **Wiring is inert for every downstream consumer**, verified rather than assumed: all seven
   modules that transitively consume `Decidability.lean` were re-elaborated with the BiLasso
   layer injected into scope. All seven: exit 0, zero errors.

The work is well-defined, fully de-risked, and needs no further research. Estimated: 6 files
touched, one of them new.

---

## 1. Baseline, measured

`bash scripts/check-module-invariants.sh --no-build` on the current tree:

```
PASS  C3   sole structural sorry is in theorem countermodel_discrete (…/WeakCanonical/Transfer.lean)
PASS  C4   all 1393 FormalSystem/BimodalTest import lines resolve
PASS  C5   all module-shaped paths in 1662 markdown files resolve (4 allowlisted)
PASS  C6   all 37 unreachable live module(s) are manifested
INFO  C7   453 live .lean files (399 FormalSystem / 53 Tests); 416 reachable, 37 unreachable
ALL CHECKS PASSED
```

`lake build` is fully up to date: exit 0, 2464 jobs, 1.6 s wall. So the *entire* incremental cost
of this task is the new module plus the aggregators downstream of `Decidability.lean`.

The 37 unreachable modules are exactly the 37 manifest entries (35 plain + 2 `broken:`).

---

## 2. The manifest edit, re-derived from the script's own algorithm

The task description asks for the split to be re-measured. It was, twice — once by grepping
imports, once by replaying `check-module-invariants.sh`'s reachability code (`scripts/check-module-invariants.sh:316-330`)
against a graph with the new import spliced in. Both agree.

### Method

The script builds `graph` from `live_files("FormalSystem") + live_files("Tests") + ["FormalSystem.lean"]`
(note the repo-root `FormalSystem.lean`, easy to miss — omitting it inflates the unreachable count
by 11), walks from `roots = ["FormalSystem", "BimodalTest"] + every lean_exe root in lakefile.lean`,
and calls `set(graph) - seen` unreachable.

The simulation added two edges: `Decidability → Decidability.BiLasso`, and
`BiLasso → BiLasso.Assembly` (the new module, Section 3).

### Result

Unreachable: **37 → 22**. Newly reachable, exactly 15:

```
FormalSystem.Metalogic.Decidability.BiLasso            (the aggregator itself)
FormalSystem.Metalogic.Decidability.BiLasso.Annotation
FormalSystem.Metalogic.Decidability.BiLasso.Basic
FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle
FormalSystem.Metalogic.Decidability.BiLasso.Check
FormalSystem.Metalogic.Decidability.BiLasso.Decide
FormalSystem.Metalogic.Decidability.BiLasso.Enumerate
FormalSystem.Metalogic.Decidability.BiLasso.Examples
FormalSystem.Metalogic.Decidability.BiLasso.Extraction
FormalSystem.Metalogic.Decidability.BiLasso.GoodCycle
FormalSystem.Metalogic.Decidability.BiLasso.Periodic
FormalSystem.Metalogic.Decidability.BiLasso.Realized
FormalSystem.Metalogic.Decidability.BiLasso.SmallModel
FormalSystem.Metalogic.Decidability.BiLasso.TruthLemma
FormalSystem.Metalogic.Decidability.BiLasso.Unfold
```

**These 15 lines, and only these, get deleted from `scripts/module-invariants-manifest.txt`.**

Still unreachable afterwards (22), so all 22 lines stay:

```
BimodalTest.Automation.FormulaMutatorTest          FormalSystem.Metalogic.Bundle
BimodalTest.Automation.ProofFirstTests             FormalSystem.Metalogic.Bundle.Construction
BimodalTest.Metalogic.PeriodicExtensionAxiomTest   FormalSystem.Metalogic.Core
BimodalTest.ProofSystem.DerivationBenchmark    (broken:)  …BiLasso.Agreement
BimodalTest.Semantics.SemanticBenchmark        (broken:)  …BiLasso.Extend
FormalSystem.Automation.ProofFirstBenchmark                …BiLasso.Orbit
FormalSystem.Metalogic.Algebraic                           …BiLasso.Successor
FormalSystem.Metalogic.Algebraic.BooleanStructure  FormalSystem.Metalogic.SoundnessLemmas
FormalSystem.Metalogic.Algebraic.InteriorOperators FormalSystem.Metalogic.SoundnessLemmas.CoValidity
FormalSystem.Metalogic.Algebraic.LindenbaumQuotient  …Kamp.NfMultiAnchorBridge.OuterGateFaithful
FormalSystem.Metalogic.Algebraic.UltrafilterMCS    FormalSystem.Semantics.Extension.PeriodicExtension
```

### Why the four-module cluster is genuinely closed

Independently confirmed by grep over the whole tree:

| Module | Importers found anywhere |
|--------|--------------------------|
| `BiLasso.Agreement` | none |
| `BiLasso.Orbit` | `BiLasso/Agreement.lean:7`, `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean:7` |
| `BiLasso.Extend` | `BiLasso/Orbit.lean:8` |
| `BiLasso.Successor` | `BiLasso/Orbit.lean:9` |

`PeriodicExtensionAxiomTest` is itself unreachable (not imported by `Tests/BimodalTest.lean`), so
it makes nothing reachable. And none of the 14 re-exported modules imports any of the four — the
full import list of all 14 was read; the closure touches only `Decidability.IntPresentation`,
`Decidability.FMP.Periodicity`, `Semantics.Truth`, `Syntax.SubformulaClosure.Closure`, and Mathlib.

`FormalSystem.Semantics.Extension.PeriodicExtension` has **zero importers anywhere** in the live
tree, so it stays unreachable regardless. Its line is untouched — correct, and consistent with the
non-goal.

### The 16th line: a comment that must not be obeyed

`scripts/module-invariants-manifest.txt`, final block:

> Axiom-profile evidence for the effective periodic extension result. Not imported by
> `Tests/BimodalTest.lean`, because doing so would pull the bi-lasso decision layer into the test
> build graph … **DELETE this line when the bi-lasso re-export lands and the modules above are
> wired in.**
> `BimodalTest.Metalogic.PeriodicExtensionAxiomTest`

Following that instruction fails C6 with *"1 unreachable live module(s) absent from
scripts/module-invariants-manifest.txt"*, because this task does not touch
`Tests/BimodalTest.lean` and the module stays unreachable. Worse, it *cannot* be wired in by this
task: it imports `BiLasso.Orbit`, which the non-goals hold unreachable.

**Required action**: keep the line; rewrite the comment to say the module stays unwired because it
imports `BiLasso.Orbit`, which is outside the re-export and outside this task's scope.

The bi-lasso block comment (which currently describes 19 lines and will describe 4) needs the same
treatment: rewrite it to say the layer is now registered, and that the four remaining lines are the
effective-periodic-extension cluster.

---

## 3. Landing the three probes

### The merge, and why it is one module and not three

The three files in `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/`
overlap:

| Probe | Declarations |
|-------|--------------|
| `soundness-half-probe.lean` | `not_validDiscrete_of_satAtState` |
| `decidability-assembly-probe.lean` | `not_validDiscrete_of_satAtState` *(byte-identical duplicate)*, `validDiscrete_iff_check`, `decidableValidDiscrete` |
| `decidability-assembly-family-probe.lean` | `not_validDiscrete_of_satAtState'` *(same statement, primed)*, `validDiscrete_iff_checkFamily`, `decidableValidDiscreteFamily` |

All three carry the same two imports (`…BiLasso.Check`, `FormalSystem.Semantics.Validity`) and the
same namespace `FormalSystem.Metalogic.Decidability`. Landing them as three modules would be three
copies of one lemma. **One module, five declarations.**

### Verified this session, not assumed

The merged form — the unprimed lemma stated once, the primed occurrence in
`validDiscrete_iff_checkFamily`'s proof rewritten to use it — was compiled with
`lake env lean` against the built library. Exit 0. No errors, no warnings. Measured axioms:

```
'…not_validDiscrete_of_satAtState'     depends on axioms: [propext, Classical.choice, Quot.sound]
'…validDiscrete_iff_check'             depends on axioms: [propext, Classical.choice, Quot.sound]
'…decidableValidDiscrete'              depends on axioms: [propext, Classical.choice, Quot.sound]
'…validDiscrete_iff_checkFamily'       depends on axioms: [propext, Classical.choice, Quot.sound]
'…decidableValidDiscreteFamily'        depends on axioms: [propext, Classical.choice, Quot.sound]
```

Exactly as the acceptance criterion requires. **Do not promise choice-freedom** — `BiLasso/README.md`
already records why no finite-carrier route can be choice-free (`wlem_of_spherical`), and
`decidableValidDiscrete` *computes* without carrying `Classical.dec` in its data while still
measuring `Classical.choice` in its proofs. Computability and choice-freedom are different
properties; only the first is claimed.

The verified merged source is at
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/856f36a8-0b87-404f-ace3-8317758a2232/scratchpad/Assemble.lean`
and is drop-in modulo the header and docstring.

### Placement

- **Path**: `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`
  (`Assembly` is what `BiLasso/README.md` already calls it: "Given `fmp`, the rest assembles".
  Avoid `Decidable.lean` — `Decidability/Verified/Decidable.lean` already exists and the near-collision
  is a reader trap.)
- **Namespace**: `FormalSystem.Metalogic.Decidability` — matching `Check.lean` and the probes, *not*
  a `BiLasso` sub-namespace. `check`, `check_correct`, `SatAtState` and `IntPresentation` all live
  there. Verified: none of the five names collides with anything in the tree
  (`grep -rn 'validDiscrete_iff_check\|decidableValidDiscrete\|not_validDiscrete_of_satAtState'`
  over `FormalSystem/` and `Tests/` returns nothing).
- **Aggregator wiring**: one `import …BiLasso.Assembly` line in
  `FormalSystem/Metalogic/Decidability/BiLasso.lean` (after `Check`), plus a `## Submodules` bullet.
  The new module is *reachable*, so it must **not** be added to the manifest.
- **Drop the `#print axioms` lines.** They would emit info diagnostics on every build. Record the
  measured axiom sets in the module docstring instead — the convention `Check.lean` already uses.

### No import cycle

`FormalSystem.Semantics.Validity` imports only `Semantics.Truth`, `Semantics.Extension.Extension`,
`Syntax.Context` and Mathlib. Nothing under `Semantics/` imports `Metalogic/` except
`Semantics/Extension/PeriodicExtension.lean`, which is unreachable and not in this cone.

---

## 4. Risk audit — every identified risk was closed by measurement

| # | Risk | Status |
|---|------|--------|
| R1 | Import-time name collision once the whole library and BiLasso are in one environment | **Closed.** A file importing `FormalSystem` *and* `…Decidability.BiLasso` elaborates clean; `check` and `SatAtState` resolve unambiguously. (The one ambiguity seen was my own probe's `#check @decide` against `Decidable.decide` — pre-existing, unrelated.) |
| R2 | New global instances (esp. `Basic.lean:77 instance instInhabitedFin : Inhabited (Fin P.card)`, and nine `Decidable` instances in `Decide.lean`/`Enumerate.lean`/`Check.lean`) perturb downstream elaboration | **Closed.** All seven downstream consumers of `Decidability.lean` — the six `Tests/BimodalTest/Integration/*.lean` files and `Tests/BimodalTest/CrossWorldPropagationProbe.lean` — were copied to scratch with `import …Decidability.BiLasso` injected and re-elaborated. Seven for seven: exit 0, **zero errors**. |
| R3 | C2 axiom baseline shifts | **No mechanism.** C2 measures four `BXCanonical` theorems; `#print axioms` on an already-elaborated theorem is scope-independent, and nothing in the BiLasso cone is a dependency of them. Still assert it at the gate. |
| R4 | C3 sorry count rises | **No mechanism.** All 15 modules are sorry-free (grep finds `sorry` only inside prose), and the new module is sorry-free as compiled. |
| R5 | Slow `#eval`/`example` blocks enter the main build | **Closed.** The only `#eval`s are in `Successor.lean` (line 141-153), which stays unreachable. `Basic.lean`'s four `by decide` examples are already compiled today by C6's per-module `lake build`. |
| R6 | Build time blows up | **Closed.** Every BiLasso olean already exists and is unchanged, so nothing in the layer recompiles. Only `Assembly.lean` plus four aggregators (`Decidability.lean` → `Metalogic.lean` → `FormalSystem/FormalSystem.lean` → `FormalSystem.lean`) and the seven test consumers rebuild. |
| R7 | C8 aggregator convention breaks | **No mechanism.** `BiLasso/Assembly.lean` sits under an existing directory with an existing sibling aggregator; C8 forbids `X/X.lean`, which this is not. |
| R8 | Concurrent edits to `Decidability.lean` | **Closed.** Task 472's handoff (`scope_collision_note`) flags the overlap and says 474 must re-read the file. It was read as it now stands; its rewritten `## Status` block (Hilbert-system vs. tableau subjects made explicit) is **not to be disturbed** — this task adds one import line and one `## Submodules` bullet, nothing else. |

---

## 5. Documentation claims that become FALSE on this commit

These are not optional polish. Landing (1) without them leaves the tree self-contradictory in
exactly the way the prior audit failure was made of.

**`FormalSystem/Metalogic/Decidability/BiLasso.lean`**, whole section
`## This aggregator is not itself imported`:

> "Nothing in the Lake build graph imports this module, so `lake build` does not compile it or the
> layer beneath it. That is deliberate while the effective-periodic-extension work is in flight…
> The layer is compile-checked in the meantime by the C6 rot guard…"

Every sentence becomes false. Rewrite the section to record that the layer is registered in
`Decidability.lean` and built by `lake build`, and that the four non-re-exported modules remain
manifested.

**`scripts/module-invariants-manifest.txt`**, two block comments — see Section 2.

**`FormalSystem/Metalogic/Decidability/BiLasso/README.md`**: the assembly is described as "retained
under `specs/469_…/evidence/`". After landing it is live; point at `BiLasso/Assembly.lean` and name
the five declarations. (Separate, pre-existing drift noticed while reading, **out of scope**: the
Modules table gives `Check.lean` as 249 lines; it is 299.)

---

## 6. ROADMAP placement and wording

`specs/ROADMAP.md` is 1930 lines and mentions BiLasso **zero** times (re-measured; confirms the
task description). There is no heading literally named "the decidability front". The correct anchor
is `## Other Open Items` (line 1561), whose second subsection is
`### FMP Truth Preservation (task 82, 0 sorries in active tree)` — explicitly tagged
"**Decidability track only** -- not a path to the completeness representation theorem". A new
`### Bi-Lasso Decision Layer` subsection belongs immediately beside it.

Honest wording is already vetted in-tree — `BiLasso/README.md` opens with it, so the ROADMAP entry
should paraphrase rather than invent:

- Landed sorry-free; 19 files, ~6,600 lines; registered in the build graph as of this commit.
- Decides truth of a formula at a state of a **given** `IntPresentation` — a finite graph on
  `Fin card` with a `Bool` valuation. Entry point `check` (`Check.lean`), correctness
  `check_correct`, plus a computing `Decidable` instance.
- **It does not decide the logic.** Nothing in it quantifies over frames; `cor:tm-decidability`
  stays open.
- **It performs no part of the finite-model step.** `exists_annot_of_truth` takes a
  `WorldHistory P.toTaskFrame` as input — it compresses histories *within* a presentation, it does
  not produce a presentation from an arbitrary countermodel.
- What remains is exactly one theorem, `fmp`:
  `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w, SatAtState P w ψ.neg` for computable
  `cands : Formula → List IntPresentation`. Its crux is box-faithfulness, and it is genuinely hard.
- Given `fmp`, the assembly to `Decidable (ValidDiscrete φ)` is **now live and machine-checked** —
  `validDiscrete_iff_checkFamily` / `decidableValidDiscreteFamily` in `BiLasso/Assembly.lean`.
- Axioms: `[propext, Classical.choice, Quot.sound]`. No choice-freedom is claimed or possible here.

Do **not** write that BiLasso covers the semantic finite model property. Do not weaken
line 1731's standing exclusion of decidability-based completeness as a path to the representation
theorem; this entry is orthogonal to it.

ROADMAP.md is under `specs/`, so C5's markdown module-path lint and C9's task-reference lint do not
apply to it. `BiLasso/README.md` **is** linted by C5, so any module path written there must resolve —
`FormalSystem.Metalogic.Decidability.BiLasso.Assembly` will, once the file exists.

---

## 7. Recommended phase decomposition

Sized so each phase is one agent run and ends at a green, committable milestone.

**Phase 1 — Land `Assembly.lean` (new module + aggregator wiring), no registration yet.**
Write `BiLasso/Assembly.lean` (Apache header, module docstring recording the measured axiom sets,
five declarations, no `#print axioms`); add its import + `## Submodules` bullet to `BiLasso.lean`.
Add `FormalSystem.Metalogic.Decidability.BiLasso.Assembly` to the manifest — it is still
unreachable at this point, so C6 demands it. Gate: `bash scripts/check-module-invariants.sh` green
(37 → 38 unreachable). Commit.

*Alternative, if a one-commit landing is preferred: fold Phase 1 into Phase 2 and never add the
Assembly line. Both are C6-clean; two commits is the safer bisect story, one commit avoids a
transient manifest entry. Either is acceptable — decide at plan time, do not leave it to the
implementer mid-run.*

**Phase 2 — Register the layer (the atomic edit).** One import in `Decidability.lean` + one
`## Submodules` bullet; delete the 15 manifest lines (16 with `Assembly` if Phase 1 added it);
rewrite the bi-lasso and `PeriodicExtensionAxiomTest` block comments; rewrite
`BiLasso.lean`'s `## This aggregator is not itself imported` section. **All in one commit** — the
manifest and the import must never be out of step. Gate: `lake build`, `lake build BimodalTest`,
and the full `check-module-invariants.sh` all green, with C6 reporting **22** unreachable modules,
C2 baseline unchanged, C3 still the sole `countermodel_discrete` sorry.

**Phase 3 — Documentation truth.** `BiLasso/README.md` evidence pointer → live module.
`specs/ROADMAP.md` subsection under `## Other Open Items`. Gate: C5 green, full harness green.
Commit.

### Acceptance checklist (verbatim from the task, each now with a check that measures it)

| Criterion | How to measure |
|-----------|----------------|
| `lake build` green | `lake build && lake build BimodalTest`, both exit 0 |
| C1/C2/C3/C6 pass | `bash scripts/check-module-invariants.sh` — expect ALL CHECKS PASSED |
| no manifest entry names a reachable module | C6 prints no "name a REACHABLE module" failure; unreachable count is **22** |
| no unreachable live module unmanifested | C6 prints `all 22 unreachable live module(s) are manifested` |
| sole sorry unchanged | C3 prints `theorem countermodel_discrete (…/WeakCanonical/Transfer.lean)` |
| landed theorems measure `[propext, Classical.choice, Quot.sound]` | scratch file with `#print axioms` on the five names, via `lake env lean` |

---

## 8. File scope

| File | Action |
|------|--------|
| `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` | **new** — five declarations |
| `FormalSystem/Metalogic/Decidability/BiLasso.lean` | +1 import, +1 bullet, rewrite one section |
| `FormalSystem/Metalogic/Decidability.lean` | +1 import, +1 bullet — **nothing else; leave the `## Status` block exactly as task 472 left it** |
| `scripts/module-invariants-manifest.txt` | −15 lines, 2 block comments rewritten |
| `FormalSystem/Metalogic/Decidability/BiLasso/README.md` | evidence pointer → live module |
| `specs/ROADMAP.md` | new subsection under `## Other Open Items` |

**Not touched**: `BiLasso/{Extend,Successor,Orbit,Agreement}.lean` and their four manifest lines;
the `FormalSystem.Semantics.Extension.PeriodicExtension` manifest line;
`Tests/BimodalTest.lean`; anything under `FMP/`; no part of the finite-model theorem.

---

## 9. Zero-debt statement

No `sorry` is introduced, none is deferred, no axiom is added. The one merged module compiles
sorry-free today, measured. The sole structural sorry remains `countermodel_discrete`. Nothing in
this task is blocked and nothing requires user review.
