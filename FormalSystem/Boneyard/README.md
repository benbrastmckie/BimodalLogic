# Boneyard -- the Archive

## What this is, and why it ships

This directory is the project's **archive**: the approaches that were tried and abandoned, kept
with the reason each one failed written down beside the code that failed. It is about a quarter
of the repository by line count, and it contains every `sorry` in the tree. Both of those facts
are deliberate, and both are neutralized by properties a reader can check rather than take on
trust.

**It is not built.** `lakefile.lean`'s `lean_lib FormalSystem` roots only `FormalSystem`, nothing
under a `Boneyard` directory is reachable from any Lake root, and a full `lake build` produces
**zero** `.olean` files under any `Boneyard` path. Every archived file additionally carries `#exit`
after its import block, so its inertness is visible in the file itself and does not depend on
reading the import graph.

**The live tree is sorry-free.** Check **C3** asserts, by content and never by line number, that
the structural `sorry` count across `FormalSystem/` with the archive excluded is **zero**. The
archive carries every `sorry` in the repository precisely *because* the live tree carries none:
unfinished proofs were moved here rather than left in place.

Neither claim is prose. Both are gate-enforced, together with **B0** (exactly one archive
directory, and the exclusion removes a non-zero count) and **C11** (every archived import line
resolves or is waived with a recorded reason):

```bash
lake build && find .lake -path '*Boneyard*' -name '*.olean' | wc -l   # 0
bash scripts/check-module-invariants.sh                              # B0, C1, C3, C11, INV
```

**Why keep it at all.** A formalization's record of what was tried and shown impossible is
frequently the most useful thing in it for a subsequent researcher -- it is the part that cannot
be reconstructed from the finished proof, and the part that stops the next person spending months
on a route that has already been closed. The largest provenance class in the classification below
is *Refuted*: recorded negative results, each with its obstruction named. The decision to ship
this tree rather than delete it is recorded in
[`docs/architecture/ADR-009-Boneyard-Retention.md`](../../docs/architecture/ADR-009-Boneyard-Retention.md);
the decision that there is exactly one archive, filtered by directory name, is
[`ADR-005`](../../docs/architecture/ADR-005-Single-Boneyard.md).

**Who should read further.** If you are looking for working code to import, stop here -- nothing
in this tree compiles reliably and its identifiers predate the Mathlib naming migration. If you
want to know whether an approach has been tried, or why a particular axiom or semantic choice was
made, the classification table and the per-subtree READMEs below are what you are looking for.

## CONVENTION WARNING: this tree is EVENT-FIRST and predates the guard-first migration

**`Formula.untl` and `Formula.snce` in the live tree take the GUARD first and the EVENT
second.** Every file in this directory predates that change and reads them the **other way
round** — event first, guard second, with two named exceptions below.

Nothing here was migrated, deliberately. This tree is not compiled: no built `.olean` lies under
any `Boneyard` path, no live module imports one, and `lakefile.lean`'s `lean_lib FormalSystem`
roots only `FormalSystem`. Rewriting ~1,900 occurrences that no compiler would ever check is pure
added risk with no verification available, so the migration excluded both Boneyard trees and left
this banner instead.

**If you resurrect a file from here, swap the two arguments of every `untl` and `snce` — in
constructor applications, in `match`/`induction` patterns, and in docstrings — before doing
anything else.** The swap is meaning-preserving only when it is uniform; a half-swapped file
compiles and silently means something different. Cross-check the result against
`FormalSystem/Syntax/Formula.lean`'s constructor docstrings and
`FormalSystem/Semantics/Truth.lean`'s clauses, and note that the prefix rendering `U(event, guard)`
emitted by `Formula.prettyPrint` is still event-first and is *not* the constructor order.

### The first exception: `BundleDeadHalf/`

[`BundleDeadHalf/`](BundleDeadHalf/README.md) is **guard-first**, like the live tree, and needs
**no** argument swap on resurrection. Its six modules were live-tree files at the moment they were
archived, long after the migration, so they already read the current way round. They carry 14
`untl`/`snce` occurrences across 12 lines in 2 files — `SuccRelation.lean` 12, `CanonicalFrame.lean`
2. Applying the banner's swap to them would silently invert their meaning while still compiling,
which is exactly the failure the banner exists to prevent. Check a directory's own README before
swapping anything.

### The second exception: `RetiredTactics/`

[`RetiredTactics/`](RetiredTactics/README.md) is **guard-first** for the same reason
`BundleDeadHalf/` is: its contents were live-tree files at the moment they were archived, long
after the migration. No argument swap on resurrection.

Both files there are **excerpts** rather than whole archived modules — the tactic declarations
lifted out of `Automation/Normalization.lean` and `Automation/Tactics/Helpers.lean`, whose
surviving halves are still live — plus the two Aesop modules, which were moved whole.

See `docs/architecture/untl-snce-argument-order.md` for the full record.

## One Archive, and the Counts That Describe It

There is exactly **one** archive directory in this repository, and this is it. There used to be
two -- a second one nested inside the live tree at
`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/` -- and the split was a standing trap: any
`find` or `grep` filter naming only this directory silently counted ~29,000 archived lines as
live code. Several past descriptions of this repository's size were wrong for exactly that
reason. That archive has been merged into [`Kamp/KampWeakCanonical/`](Kamp/KampWeakCanonical/README.md),
and the four Kamp-facing approach directories that used to sit at this level joined it under
[`Kamp/`](Kamp/README.md).

**This section is the single source for the archive's counts. Every other file that needs them
links here rather than restating them.**

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Boneyard rows=totals desc=no -->
| Quantity | Value |
|----------|------:|
| Archived `.lean` files | 169 |
| Archived lines | 91,983 |
| Top-level subdirectories | 40 |
| Archive directories in the repository | 1 |
<!-- END GENERATED -->

Those four rows are **generated, not typed**. `--emit-inventory` rewrites them from the tree and
`INV` fails the gate if a single digit has drifted, so they cannot go stale the way the three
mutually disagreeing hand-typed counts they replaced did. Regenerate and re-check with:

```bash
bash scripts/check-module-invariants.sh --emit-inventory          # rewrite the block above
bash scripts/check-module-invariants.sh --emit-inventory --check  # fail if a byte has drifted
bash scripts/check-module-invariants.sh                           # B0 self-test + C7 live inventory
```

B0 asserts that the count of `Boneyard` directories is exactly **1** and reports how many `.lean`
files the exclusion removes; C7 reports the live inventory. Do not hand-roll a count. If you must,
the filter is a name glob, never a path prefix -- that is what makes a second archive reappearing
anywhere under `FormalSystem/` a gate failure rather than a silent miscount:

```bash
find FormalSystem -name '*.lean' -not -path '*/Boneyard/*'
```

## Identifiers Here Predate the Mathlib Naming Migration

**The declaration names in this directory were deliberately left untouched** when the rest of the
library was migrated to Mathlib naming conventions. Expect `snake_case` `def`s here
(`truth_at`, `all_future`, `nf_eval_nf`) that no longer exist anywhere in live code — roughly
**8,718 stale references across 93 files**. This is a recorded, accepted cost, not an oversight.

The reason is mechanical. The migration rewrote identifiers by position, driven by the resolved
references the elaborator records in `.ilean` artifacts, which is what made it safe: 47.2% of the
old final components are a proper prefix of another project identifier, so a textual pass would
have corrupted nearly half the sites it touched. This directory has **zero** `.ilean` artifacts
and **zero** imports from active code — nothing here is built — so the resolved-reference
mechanism structurally cannot cover it, and the textual fallback would face the full prefix
hazard with no build to catch the errors.

Consequences for anyone reading or reviving a file from here:

- A name found here will generally not resolve against live code. Translate it first; the
  rule is in [`docs/development/NAMING_CONVENTION_DEVIATION.md`](../../docs/development/NAMING_CONVENTION_DEVIATION.md).
- Do **not** grep this directory when auditing live identifier usage. It will produce thousands
  of false positives.
- Reviving a file means renaming its identifiers as part of the revival, exactly as the
  "still compiled when archived" caveat below already implies for its build state.

## Archival Criterion

A file belongs here when it is **unreachable from every Lake target root** — the
`FormalSystem` and `BimodalTest` libraries and every `lean_exe` root — and is not intended
to become reachable. Unreachability alone is not sufficient: a module that is merely
not-yet-wired belongs in `scripts/module-invariants-manifest.txt`, which compile-checks
it so it cannot rot. Archiving is for code that is deliberately out of the development
path.

Archival does **not** require that a file be broken. Some entries here still compiled
when archived; where that is true it is recorded in the subdirectory README, because
once a file is inert nothing re-checks it and that fact survives nowhere else.

## Purpose

The Boneyard serves three roles:

1. **Dead-end documentation**: Approaches that hit fundamental mathematical or
   architectural barriers. Understanding *why* they failed prevents repeating
   the same mistakes.

2. **Superseded implementations**: Working code replaced by better approaches.
   May contain useful techniques or lemmas that could be adapted.

3. **Architectural incompatibility**: Code written for a different semantic
   foundation (e.g., reflexive vs strict temporal semantics) that cannot be
   directly ported to the current system.

## Important Notes

- **No Boneyard file is imported** by any active module. The entire directory is
  inert with respect to `lake build`.
- **Code may not compile**. Many files reference removed imports, deleted
  definitions, or use outdated API conventions.
- **Sorry counts are not bugs**. Boneyard sorries represent archived dead ends,
  not open proof obligations.

## Directory Inventory

Every top-level entry of the archive has exactly one row, and every row names something that
exists. The **Directory**, **Files** and **Lines** columns are generated from the tree by
`--emit-inventory` and gated by `INV`; only the trailing column is written by hand. There is no
total row: the totals are generated once, above, in One Archive.

Rows are ordered largest-first. A row with a zero count is a **tombstone** -- the code was
deleted after doc-only consolidation and the README retained as the historical record; see
Tombstones at the end of this file.

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Boneyard rows=both cols=files-lines link=yes empty=include sort=lines-desc -->
| Directory | Files | Lines | Why Archived |
|-----------|------:|------:|--------------|
| [`Kamp/`](Kamp/README.md) | 85 | 43,551 | **Region index for the whole Kamp separation / expressive-completeness pipeline**, in five subdirectories: `KampWeakCanonical/` (the former nested second archive, 63 files), `KampBypassArchive/`, `KampNegationClosure/`, `RabinovichPath/`, `VecEADecomposition/`. Superseded, in stages, by the landed zeta route. See its own README for which subtree is authoritative for what |
| [`StrictSemanticsLegacy/`](StrictSemanticsLegacy/README.md) | 9 | 14,392 | From `Metalogic/`. Complete completeness infrastructure written under **strict** temporal semantics — algebraic chains, bundle constructions, frame-condition completeness, top-level wiring. Architecturally incompatible with the current open-guard semantics |
| [`StaviDiscretePath/`](StaviDiscretePath/README.md) | 4 | 4,981 | From `WeakCanonical/EFGames/`. The discrete Stavi completeness route (EF game pipeline) with no live consumers, plus `StaviExpressiveCompletenessTail.lean`, the dead 24-declaration expressive-completeness tail excised from the live `StaviCompleteness.lean` |
| [`ChainCompleteness/`](ChainCompleteness/README.md) | 12 | 4,265 | From `BXCanonical/`. An earlier chain-based completeness iteration — deterministic, resolving, targeted and witness chains — superseded by the SuccChain approach, itself later superseded by the chronicle construction |
| [`SorriedDeclExcisions/`](SorriedDeclExcisions/README.md) | 6 | 3,351 | From `Metalogic/` (various) and `Bundle/`. Verified-dead declaration closures carrying statement-position sorries, moved out of live code as units. Every archived declaration was confirmed dead by word-boundary grep before excision |
| [`RoundRobinChain/`](RoundRobinChain/README.md) | 2 | 2,537 | From `BXCanonical/`. Round-robin chain construction, confirmed dead: the depth-0 base case of `forward_F` is blocked by the BX11 perpetual-deferral obstruction — an Until obligation can be deferred to later stages forever without being fulfilled |
| [`BundleDeadHalf/`](BundleDeadHalf/README.md) | 6 | 2,302 | From `Metalogic/Bundle/`. Six modules retired together as a mechanical cascade after breaking the `Core -> Bundle` directory import cycle removed the first module's only live importer. **Guard-first** — no argument swap on resurrection |
| [`DeadChronicleGapElimination/`](DeadChronicleGapElimination/README.md) | 3 | 1,939 | From `BXCanonical/Chronicle/` and `WeakCanonical/`. The full 10-declaration `chronicle_gap_contradiction` `sorryAx` closure, excised as one unit spanning `ChronicleToCountermodel.lean` and `Transfer.lean`. The live `completeness_discrete` uses the Reynolds pipeline instead |
| [`UltrafilterFrame/`](UltrafilterFrame/README.md) | 3 | 1,745 | From `Algebraic/`. `AlgebraicCompleteness.lean` plus `TenseS5Algebra.lean` (3 sorries for the removed `temp_a`/`temp_l` axioms) and `UltrafilterFrame.lean` (2 sorries for `temp_4`). Both are Jonsson-Tarski prerequisites; the elaboration-interference attribution that retired them remains untested and so remains in force for these two files |
| [`ConservativeExtension/`](ConservativeExtension/README.md) | 4 | 1,616 | The complete `Metalogic/ConservativeExtension/` directory archived as a unit, README included: `ExtFormula.lean`, `ExtDerivation.lean`, `Substitution.lean`, `Lifting.lean`. Self-contained, with zero live importers — reachable only from the deleted top-level `Metalogic.lean` aggregator |
| [`DefectDirectedChain/`](DefectDirectedChain/README.md) | 1 | 1,564 | From `BXCanonical/`. A root-scoped chain built by directing construction toward reducing a "defect" metric. Abandoned once the metric was shown not to decrease monotonically through chain extension steps |
| [`QuasimodelOracle/`](QuasimodelOracle/README.md) | 3 | 1,477 | From `BXCanonical/`. Oracle-based forward/backward MCS chain construction. Abandoned: the backward step transfer is semantically invalid, and the round-robin variant hits the BX11 perpetual-deferral obstruction |
| [`BundleSuccessorSeed/`](BundleSuccessorSeed/README.md) | 1 | 1,218 | From `Metalogic/Bundle/`. A deferral-seed successor/predecessor existence construction. Zero live consumers across all 72 declarations, and its 3 sorries all reduce to the T-axiom for `G`/`H`, which is unsound under open-guard semantics |
| [`MergedBracketQuarantine/`](MergedBracketQuarantine/README.md) | 1 | 1,036 | From `WeakCanonical/Kamp/NfMultiAnchorBridge/`. A **refuted** merged-bracket route: it violates the no-nesting audit and Rabinovich Lemma 5.1's QF point-type. Deliberately kept outside `Kamp/` — its subject is bracket quarantine, not the Kamp pipeline |
| [`RestrictedMCSDeferral/`](RestrictedMCSDeferral/README.md) | 1 | 772 | From `Metalogic/Core/RestrictedMCS/`. A deferral-restricted MCS (`deferralClosure`) variant of the successor-seed construction, fully developed through Lindenbaum and boundedness. No live consumers; the construction it served is archived under `BundleSuccessorSeed/` |
| [`RetiredTactics/`](RetiredTactics/README.md) | 4 | 677 | From `Automation/`. Fourteen tactic declarations and two whole modules retired on a **measurement**, not a design change: every artefact had zero real invocations in the live library and in `Tests/`. **Guard-first** — no argument swap on resurrection. Two files are excerpts, not whole modules |
| [`DeadCanonicalModel/`](DeadCanonicalModel/README.md) | 2 | 644 | From `BXCanonical/`, `Bundle/` and `ProofSystem/`. The enriched-seed canonical-model approach, structurally unfixable — the enrichment step cannot maintain consistency of the extended seed — plus two orphans from the triage pass |
| [`BXPipelineDeadCode/`](BXPipelineDeadCode/README.md) | 2 | 574 | From `WeakCanonical/IntegerModel/`. BX pipeline dead code: the deprecated Reynolds model surgery (`no_gaps_faithful`, mathematically false as stated) and four dead `ReynoldsNoGaps` definitions with zero external references |
| [`SupersededCompleteness/`](SupersededCompleteness/README.md) | 1 | 541 | From `Metalogic/Completeness.lean`. Zero live importers: the only `import FormalSystem.Metalogic.Completeness` in the repository came from another archived file, so it sat outside every Lake target's closure while the docs still described it as live |
| [`DeadConvergenceProof/`](DeadConvergenceProof/README.md) | 2 | 468 | Relocated from the former root-level `Boneyard/`. The dead convergence proof for `succ_cofinal` and its single-consumer helper. Fails in the constant-MCS case, where no discriminating formula exists and the temporal axioms are trivially satisfied |
| [`SemanticBenchmarkToyEvaluator/`](SemanticBenchmarkToyEvaluator/README.md) | 1 | 365 | From `Tests/BimodalTest/Semantics/`. A benchmark that advertised `TruthAt` evaluation but timed a hand-written six-case `Bool` function instead, never calling `TruthAt`. Retired on a **measurement** (zero real invocations in the library and in `Tests/`) rather than repaired: a mechanical repair compiled but scored 14/16, because its invented branches have no correct value |
| [`BXPipelineGapAnalysis/`](BXPipelineGapAnalysis/README.md) | 2 | 303 | From `WeakCanonical/` and `Chronicle/`. Chronicle-level gap elimination via Reynolds Theorem 14, and Henkin discrete-chain analysis. Both blocked by the falsity of `no_gaps_faithful` (a Z+Z counterexample); the correct path is the Reynolds pipeline via `no_gaps_discrete` |
| [`DenseChronicle/`](DenseChronicle/README.md) | 3 | 287 | From `Chronicle/`. Attempts to adapt the Burgess chronicle construction to dense orders. Hit the density gap: `G(phi)` and `untl(phi.neg, gamma)` are semantically contradictory on dense orders, but BX has no density axiom to derive the contradiction formally |
| [`RestrictedMCSBoundedness/`](RestrictedMCSBoundedness/README.md) | 1 | 262 | From `Metalogic/Core/RestrictedMCS/`. `iterF`/`iterP` boundedness for `RestrictedMCS`: zero live references, and its advertised consumer `succ_chain_fam` is itself archived under `StrictSemanticsLegacy/` |
| [`FMPVariants/`](FMPVariants/README.md) | 2 | 237 | From `Decidability/FMP/`. Dense and Discrete finite-model-property statements with zero live importers; the tableau decision procedure consumes the Base-variant FMP interface only |
| [`ScheduleBasedBFMCS/`](ScheduleBasedBFMCS/README.md) | 1 | 226 | From `BXCanonical/RootScopedChain.lean`. A schedule-based BFMCS chain: the Lindenbaum step loses F-obligations. Bypassed by the Chronicle construction |
| [`FiltrationOrdering/`](FiltrationOrdering/README.md) | 1 | 170 | From `Filtration/SigmaOrdering.lean`. Sigma-restricted ordering for filtration; BX1 was removed under irreflexive semantics |
| [`BXCanonicalQuasimodel/`](BXCanonicalQuasimodel/README.md) | 1 | 166 | From `BXCanonical/Quasimodel/`. The enriched (Fisher-Ladner) closure — Phase 1 scaffolding for a migration whose Phase 2 never ran. No live downstream consumers |
| [`SoundnessVariants/`](SoundnessVariants/README.md) | 2 | 110 | From `Metalogic/`. Dense and Discrete soundness **wrapper** modules with zero live importers; the live `soundness_dense` and `soundness_discrete` are proved directly in `Metalogic/Soundness.lean` |
| [`LimitMCSCoherenceDeadCases/`](LimitMCSCoherenceDeadCases/README.md) | 1 | 95 | From `Metalogic/Bundle/LimitMCSCoherence.lean`. Five theorems retired during the `TemporalSide` parameterization of `Bundle/LimitMCS.lean`, each referenced only by its own declaration and by docstring prose. **Guard-first** |
| [`DiscreteXY/`](DiscreteXY/README.md) | 1 | 77 | From various. The discrete `x_content`/`y_content` approach to BurgessR3Maximal splitting, replaced by direct open-guard semantics |
| `VacuousKEquiv.lean` | 1 | 35 | From `Theorems/`. The archive's one root-level file: two theorems whose names promised Z-interval k-equivalence and whose proofs were `⟨M, rfl⟩` — reflexivity and nothing more. Admitted at the root by the Expected File Structure policy below |
| [`BX1DependentCode/`](BX1DependentCode/README.md) | 0 | 0 | **Tombstone.** From `Quasimodel/Realization.lean`. BX1-dependent helpers; BX1 was removed under irreflexive semantics |
| [`BundleTemporalCoherence/`](BundleTemporalCoherence/README.md) | 0 | 0 | **Tombstone.** From `UltrafilterChain.lean`. Semantically wrong for TM: bundle-level coherence permits temporal witnesses in a *different* world history, but TM requires witnesses within the same history |
| [`ClosedGuardLegacy/`](ClosedGuardLegacy/README.md) | 0 | 0 | **Tombstone.** From various. Closed-guard interval semantics `[t,s]`, replaced by the open guard `(t,s)` that correctly handles the irreflexive temporal order |
| [`NonBurgessSeed/`](NonBurgessSeed/README.md) | 0 | 0 | **Tombstone.** From `PointInsertion.lean`. The legacy `g_content`/`h_content` approach: the consistent case was proved, but the inconsistent case hits the same density gap as `DenseChronicle/` |
| [`OpenGuardInvalid/`](OpenGuardInvalid/README.md) | 0 | 0 | **Tombstone.** From `TemporalDerived.lean`. 27 sorry-tainted definitions relying on BX8, BX9, a reflexive temporal order, seriality or density — all invalid or unavailable under open-guard semantics |
| [`StageInductionGapAnalysis/`](StageInductionGapAnalysis/README.md) | 0 | 0 | **Tombstone.** From `ChronicleToCountermodel`. Dead-end `IsSuccArchimedean` proof attempts; the analysis confirmed the gap scenario is **genuine** — the constant-MCS case is consistent with all axioms including Z1 and Prior-UZ |
| [`TAxiomDependentCode/`](TAxiomDependentCode/README.md) | 0 | 0 | **Tombstone.** From various. Code depending on the T-axiom (`G(phi)->phi` / `H(phi)->phi`), which is not valid under strict temporal semantics |
| [`UltrafilterDeadCode/`](UltrafilterDeadCode/README.md) | 0 | 0 | **Tombstone.** From `UltrafilterChain.lean`. Four dead approaches removed during a sorry-elimination cleanup: F-preserving seed (proven FALSE), bidirectional seed, Z-chain (circular dependencies), CoherentZChain |
| [`XuLemma321Legacy/`](XuLemma321Legacy/README.md) | 0 | 0 | **Tombstone.** From `RRelation.lean`. A blocked proof-by-contradiction for Xu's Lemma 3.2.1(i)/(ii): the inconsistent case needs BX9, removed as unsound under open guard. Doubly obsolete — Xu 3.2.1 was later proved via `dcs_neg_union_consistent` |
<!-- END GENERATED -->

## Archival Reason Taxonomy

Two independent classifications are given for every top-level entry, because they answer
different questions. The **archival reason** says what kind of thing went wrong; the
**provenance class** says what the material is worth to a later reader. They are not the same
axis: a subtree can be architecturally incompatible *and* a superseded route, or unsound *and* a
refutation worth keeping.

### The four archival reasons

**Unsound Axioms / Semantics.** Code that relied on axioms later found unsound under the
project's semantic foundation -- BX9 under open guard, the T-axiom `G(phi)->phi` under strict
temporal semantics, closed-guard interval semantics.

**Superseded Approaches.** Working code replaced by a fundamentally different, usually simpler or
more general, approach. It may compile and even be correct; a better solution exists.

**Structural Dead Ends.** Approaches that hit an irreparable mathematical barrier: a false lemma,
a non-decreasing defect metric, a perpetual-deferral obstruction, a circular dependency.

**Architectural Incompatibility.** Code written for a semantic foundation the project has since
departed from. The proof strategies may be sound under their original semantics but cannot be
adapted without fundamental restructuring.

**Orphaned, Not Refuted.** *Added because a substantial part of this archive fits none of the
four above.* Code that was correct, frequently still compiled at archival, and was retired only
because nothing imported it -- or because the one thing that did was itself archived first.
Calling these "dead ends" would misdescribe them, and calling them "superseded" would imply a
replacement that does not exist.

### The three provenance classes

- **Superseded** -- a working route that a better route replaced. Read it to see what the
  alternative looked like.
- **Refuted** -- an approach shown to be impossible, false, or unsound. **This is the class with
  the most value to a subsequent researcher**: it is a recorded negative result, and the reason
  is written down next to the code that failed.
- **Orphaned / Unfinished** -- neither replaced nor refuted. Either nothing consumed it, or the
  proof was never completed. Cheapest to revive, least informative to read.

### Every top-level entry, classified

| Entry | Archival reason | Provenance class | Why |
|-------|-----------------|------------------|-----|
| `Kamp/` | Superseded Approaches | Superseded | Five approaches to Kamp separation and expressive completeness; the zeta route landed instead. `MergedBracketQuarantine/`-style refutations live inside it too — see its own README |
| `StrictSemanticsLegacy/` | Architectural Incompatibility | Superseded | Sound under strict temporal semantics; unadaptable to open guard without restructuring |
| `StaviDiscretePath/` | Superseded Approaches | Superseded | The EF-game route works; `PriorExpressiveness.lean` reaches the result through Kamp/Rabinovich instead |
| `ChainCompleteness/` | Superseded Approaches | Superseded | Superseded by SuccChain, itself superseded by the chronicle construction |
| `SorriedDeclExcisions/` | Orphaned, Not Refuted | Unfinished | Verified-dead closures carrying statement-position sorries — unfinished proofs with no consumers |
| `SupersededCompleteness/` | Orphaned, Not Refuted | Orphaned | Compiled at archival; zero live importers |
| `RoundRobinChain/` | Structural Dead Ends | Refuted | The BX11 perpetual-deferral obstruction blocks the depth-0 base case of `forward_F` |
| `BundleDeadHalf/` | Orphaned, Not Refuted | Orphaned | A mechanical cascade after the `Core -> Bundle` cycle break removed the first module's only importer. **Guard-first** |
| `UltrafilterFrame/` | Orphaned, Not Refuted | Unfinished | 5 sorries for removed axioms; a Jonsson-Tarski prerequisite that was never completed |
| `DeadChronicleGapElimination/` | Structural Dead Ends | Refuted | The `chronicle_gap_contradiction` `sorryAx` closure; the Reynolds pipeline is the live route |
| `ConservativeExtension/` | Orphaned, Not Refuted | Orphaned | Self-contained and correct; reachable only from a deleted aggregator |
| `DefectDirectedChain/` | Structural Dead Ends | Refuted | The defect metric was shown not to decrease monotonically |
| `QuasimodelOracle/` | Structural Dead Ends | Refuted | Backward step transfer is semantically invalid; BX11 blocks the round-robin variant |
| `BundleSuccessorSeed/` | Unsound Axioms / Semantics | Refuted | Its 3 sorries all reduce to the T-axiom for `G`/`H`, unsound under open guard |
| `MergedBracketQuarantine/` | Structural Dead Ends | Refuted | Violates the no-nesting audit and Rabinovich Lemma 5.1's QF point-type |
| `RestrictedMCSDeferral/` | Orphaned, Not Refuted | Orphaned | A fully developed MCS variant whose only intended consumer was archived first |
| `RetiredTactics/` | Orphaned, Not Refuted | Orphaned | Retired on a measurement: zero real invocations in the library or in `Tests/`. **Guard-first** |
| `SemanticBenchmarkToyEvaluator/` | Orphaned, Not Refuted | Orphaned | A `TruthAt` benchmark that never called `TruthAt`; retired on the same zero-invocation measurement as `RetiredTactics/` |
| `DeadCanonicalModel/` | Structural Dead Ends | Refuted | The enrichment step cannot maintain consistency of the extended seed |
| `BXPipelineDeadCode/` | Structural Dead Ends | Refuted | `no_gaps_faithful` is mathematically false as stated (Z+Z counterexample) |
| `DenseChronicle/` | Structural Dead Ends | Refuted | The density gap: BX has no density axiom to derive the needed contradiction |
| `BXPipelineGapAnalysis/` | Structural Dead Ends | Refuted | Blocked by the same falsity of `no_gaps_faithful` |
| `RestrictedMCSBoundedness/` | Orphaned, Not Refuted | Orphaned | Zero live references; its advertised consumer is itself archived |
| `DeadConvergenceProof/` | Structural Dead Ends | Refuted | Fails in the constant-MCS case, where no discriminating formula exists |
| `SoundnessVariants/` | Orphaned, Not Refuted | Orphaned | Thin wrappers duplicating live theorems, with no importers |
| `FMPVariants/` | Orphaned, Not Refuted | Orphaned | Frame-class FMP restatements the tableau pipeline never consumed |
| `ScheduleBasedBFMCS/` | Structural Dead Ends | Refuted | The Lindenbaum step loses F-obligations |
| `FiltrationOrdering/` | Unsound Axioms / Semantics | Refuted | Depends on BX1, removed under irreflexive semantics |
| `BXCanonicalQuasimodel/` | Superseded Approaches | Unfinished | Phase 1 scaffolding for a migration whose Phase 2 never ran |
| `LimitMCSCoherenceDeadCases/` | Orphaned, Not Refuted | Orphaned | Five theorems with zero live consumers after the `TemporalSide` parameterization. **Guard-first** |
| `DiscreteXY/` | Superseded Approaches | Superseded | Replaced by the direct open-guard semantics approach |
| `VacuousKEquiv.lean` | Structural Dead Ends | Refuted | The theorems proved reflexivity, not the Z-interval equivalence their names claimed |
| `BX1DependentCode/` | Unsound Axioms / Semantics | Refuted | BX1 was removed under irreflexive semantics |
| `BundleTemporalCoherence/` | Structural Dead Ends | Refuted | Permits temporal witnesses in a different world history; TM requires the same history |
| `ClosedGuardLegacy/` | Unsound Axioms / Semantics | Superseded | Closed guard `[t,s]` replaced by the open guard `(t,s)` |
| `NonBurgessSeed/` | Structural Dead Ends | Refuted | The inconsistent case hits the same density gap as `DenseChronicle/` |
| `OpenGuardInvalid/` | Unsound Axioms / Semantics | Refuted | Relies on BX8, BX9, reflexivity, seriality or density — none available under open guard |
| `StageInductionGapAnalysis/` | Structural Dead Ends | Refuted | The gap scenario is genuine: the constant-MCS case is consistent with Z1 and Prior-UZ |
| `TAxiomDependentCode/` | Unsound Axioms / Semantics | Refuted | The T-axiom is not valid under strict temporal semantics |
| `UltrafilterDeadCode/` | Structural Dead Ends | Refuted | F-preserving seed proven FALSE; the others circular or underivable |
| `XuLemma321Legacy/` | Unsound Axioms / Semantics | Refuted | Needs BX9, removed as unsound; and Xu 3.2.1 was later proved another way |

The distribution is itself informative: the largest class is **Refuted**, which is precisely the
material a formalization is least able to reconstruct after the fact and most useful to ship.
## Subdirectory Details

One entry per top-level subtree of the archive, in alphabetical order, plus the root-level file.
Each subtree also has its own README with a file-level inventory; this section is the
single-page overview.

### BundleDeadHalf
Six modules from `Metalogic/Bundle/`, retired together rather than one at a
time: breaking the `Core -> Bundle` directory import cycle removed the first module's only live
importer, and the rest followed as a mechanical cascade down the import graph.

**This directory is guard-first** — its files were live-tree modules at the moment they were
archived, long after the `untl`/`snce` migration, so they already read the current way round.
Applying the archive-wide argument swap to them would silently invert their meaning while still
compiling. It carries 14 `untl`/`snce` occurrences across 12 lines in 2 files. See the first
exception under the CONVENTION WARNING at the top of this file.

### BundleSuccessorSeed
`SuccExistence.lean` from `Metalogic/Bundle/`: a deferral-seed
successor/predecessor existence construction, 72 declarations with zero live consumers. Its 3
sorries are not incidental — all three reduce to the T-axiom for `G`/`H`, which is unsound under
open-guard semantics, so the construction cannot be completed as written. `RestrictedMCSDeferral/`
imports it and was archived for that reason.

### BundleTemporalCoherence
Bundle-level temporal coherence code from UltrafilterChain.lean. Semantically
wrong for TM task semantics: F(phi) witnesses may come from a different world
history, but TM requires witnesses within the same history. See subdirectory
README for detailed semantic analysis.

### BX1DependentCode
**Tombstone** (README only). BX1-dependent helper lemmas from
`Quasimodel/Realization.lean`. BX1 was removed when the temporal order became irreflexive, so
every hypothesis these helpers took no longer exists. The `.lean` files were consolidated into
the subdirectory README and deleted; git history holds the code.

### BXCanonicalQuasimodel
`EnrichedClosure.lean` from `BXCanonical/Quasimodel/`. The
Fisher-Ladner style enriched Sigma-closure: for every subset `T` of the base `SubformulaClosure`
it adds `G(¬ (bigconj T.toList))` and `H(¬ (bigconj T.toList))`, closing the chain-step seed
consistency gap. It was written to build standalone *alongside* `SubformulaClosure` so a later
migration could be done surgically — that migration never ran, and the file has no live
consumers. Unfinished rather than refuted: nothing here was shown to be wrong.

### BXPipelineDeadCode
Two files containing dead code from the BX pipeline after Reynolds model surgery
completion. `ReynoldsModelSurgery.lean` (407 lines) contains the
deprecated `no_gaps_faithful` proof and `prior_model_is_succ_archimedean`
corollary, which are mathematically false as stated (Z+Z counterexample with
constant predicates). `ReynoldsNoGapsDeprecated.lean` (161 lines)
contains 4 dead definitions extracted from `ReynoldsNoGaps.lean`:
`no_gaps_discrete_archimedean`, `no_gaps_prior`, `prior_implies_succ_archimedean`,
and `one_class_implies_succ_archimedean` -- all had zero external references.
The completeness pipeline uses `chronicle_no_gaps` (ChronicleNoGaps.lean) and
the Reynolds pipeline via `no_gaps_discrete` instead.

### BXPipelineGapAnalysis
Two files from the dead BX pipeline gap analysis path. `ChronicleNoGaps.lean`
(165 lines) attempted chronicle-level gap elimination using Reynolds Theorem 14
adapted to the chronicle construction. `HenkinDiscreteChain.lean` (121 lines)
documented analysis of Henkin chain approaches to sorry-free `completeness_discrete`.
Both were blocked by the fundamental falsity of `no_gaps_faithful` (Z+Z
counterexample: two copies of Z with constant MCS satisfy all `PriorModelData`
hypotheses yet have a Dedekind gap). The correct path is the Reynolds pipeline
via `no_gaps_discrete`.

### ChainCompleteness
Earlier chain-based completeness attempt (12 files across Algebraic/, Bundle/,
Completeness/ subdirectories). Superseded by the SuccChain approach, which was
itself superseded by the chronicle construction. Contains deterministic chains,
resolving chains, targeted chains, and witness chains.

### ClosedGuardLegacy
Four files implementing closed guard interval semantics `[t,s]` for Until/Since.
Replaced by open guard semantics `(t,s)` which correctly handles the irreflexive
temporal order. Includes axiom definitions, soundness proofs, and derived
theorems for the closed-guard system.

### ConservativeExtension
The complete `Metalogic/ConservativeExtension/` directory (4 files + its own
README), archived as a unit: `ExtFormula.lean`, `ExtDerivation.lean`,
`Substitution.lean`, and `Lifting.lean`. A self-contained development of
conservative-extension results over the base proof system. No live module
imported any of it; it was reachable only from the deleted top-level
`Metalogic.lean` aggregator. See its own README for the mathematical content.

### DeadCanonicalModel
Originally an enriched seed approach to canonical model construction (README
only). The approach is structurally unfixable: the enrichment step cannot
maintain consistency of the extended seed. The orphan-triage pass added two
archived files: `CanonicalIrreflexivity.lean` (from `Metalogic/Bundle/`, an
irreflexivity result for the dead canonical-model route with zero live
importers) and `Substitution.lean` (from `ProofSystem/`, a broken substitution
development whose sole importer was `CanonicalIrreflexivity.lean`).

### DeadChronicleGapElimination
The full 10-declaration `chronicle_gap_contradiction` `sorryAx`
closure, excised as one unit spanning `BXCanonical/Chronicle/ChronicleToCountermodel.lean` and
`WeakCanonical/Transfer.lean`. Chronicle-level gap elimination is a dead route; the live
`completeness_discrete` reaches its result through the Reynolds pipeline
(`countermodel_discrete_reynolds_v2`) instead.

### DeadConvergenceProof
Two files, relocated from the former root-level `Boneyard/`.
`succ_cofinal_convergence.lean` is the convergence proof once inlined in the `succ_cofinal`
theorem body: it shows the successor orbit `{s^[n](a)}` converges to a limit in `ℝ` and tries to
derive a contradiction from Z1, Prior-UZ and `c5_strong`. It fails in the constant-MCS case,
where no discriminating formula exists and the temporal axioms are trivially satisfied. Three gap
elimination routes were evaluated and none closed it. `limit_dom_succ_iterates.lean` is its
single-consumer helper and died with it. The live `succ_cofinal` is derived from `one_class`.

### DefectDirectedChain
Root-scoped chain construction (1,556 lines) that attempted to build MCS chains
by directing construction toward reducing a "defect" metric. Abandoned when the
defect metric was shown to not decrease monotonically through chain extension
steps.

### DenseChronicle
Three files attempting to adapt the Burgess chronicle construction to dense
orders. Hit the density gap: `G(phi)` and `untl(phi.neg, gamma)` are
semantically contradictory on dense orders but BX lacks a density axiom to derive
the contradiction formally.

### DiscreteXY
Single file with the discrete x_content/y_content approach to BurgessR3Maximal
splitting. Replaced by the direct open guard semantics approach.

### FiltrationOrdering
`SigmaOrdering.lean` from `Filtration/`: a Sigma-restricted ordering for
the filtration construction. It depends on BX1, which was removed under irreflexive semantics, so
the ordering it defines has no axiom to justify it.

### FMPVariants
`DenseFMP.lean` and `DiscreteFMP.lean` from `Metalogic/Decidability/FMP/`.
Finite-model-property statements for the Dense and Discrete TM variants. No
live module imported either file; the tableau decision procedure consumes the
Base-variant FMP interface only.

### Kamp
The region index for the entire Kamp separation and expressive-completeness pipeline,
holding five subdirectories and 47.6% of the archive's lines. `KampWeakCanonical/` is the former
*second* archive — the one that used to sit nested inside the live tree at
`Metalogic/WeakCanonical/Kamp/Boneyard/` and silently counted as live code — merged here in its
entirety. `KampBypassArchive/`, `KampNegationClosure/`, `RabinovichPath/` and
`VecEADecomposition/` are the four Kamp-facing approach directories that used to sit at this
archive's top level.

[`Kamp/README.md`](Kamp/README.md) carries a generated per-subtree inventory and, more usefully,
a statement of which subtree is authoritative for what: `KampBypassArchive/` for the bypass-formula
route, `KampWeakCanonical/TranslationEra/` as the shared dependency floor beneath it and
`RabinovichPath/`, `VecEADecomposition/` standing alone. `MergedBracketQuarantine/` deliberately
stays outside this umbrella.

### LimitMCSCoherenceDeadCases
Five theorems retired from
`Metalogic/Bundle/LimitMCSCoherence.lean` during the `TemporalSide` parameterization of
`Bundle/LimitMCS.lean`. Each was referenced only by its own declaration and by module-docstring
prose, with zero live consumers repository-wide, re-verified at retirement time. Like
`BundleDeadHalf/` and `RetiredTactics/`, this snippet is **guard-first**: no argument swap on
resurrection.

### MergedBracketQuarantine
`MergedBracket.lean` from `WeakCanonical/Kamp/NfMultiAnchorBridge/`.
A **refuted** route, and one of the more valuable records here: the merged-bracket construction
violates the no-nesting audit and Rabinovich Lemma 5.1's QF point-type, so it cannot be repaired
by adjusting the construction. It is deliberately kept as a sibling of `Kamp/` rather than folded
into it — it has two borderline Kamp edges, but its subject is bracket quarantine, and folding it
in would make the region boundary a judgement call rather than a fact.

### NonBurgessSeed
Legacy g_content/h_content functions from PointInsertion.lean.
The consistent case was proved, but the inconsistent case hits the same density
gap as DenseChronicle. All code is commented out and non-compilable.

### OpenGuardInvalid
27 sorry-tainted definitions from TemporalDerived.lean (1 file, 215 lines). These
relied on BX8 (reflexive Until/Since intro), BX9 (Until/Since elimination to
disjunction), reflexive temporal order (alpha -> F(alpha)), seriality, or density
axioms -- all invalid or unavailable under the current open guard (t,s) semantics.
5 definitions with proof content or downstream users are archived with full bodies;
22 are documented as type signatures only. Net active sorry reduction: 19.

### QuasimodelOracle
Oracle-based approach to constructing forward/backward MCS chains (3 files, 44
sorries). Abandoned due to backward step transfer being semantically invalid and
BX11 perpetual deferral obstruction in the round-robin variant.

### RestrictedMCSBoundedness
`Boundedness.lean` from `Metalogic/Core/RestrictedMCS/`: four
lemmas establishing that `iterF`/`iterP` iterations eventually leave any `RestrictedMCS`, and
locating the boundary index. Zero references outside their own declaration sites, and the
consumer they were written for — `succ_chain_fam`'s nesting-bound obligations — is itself
archived, under `StrictSemanticsLegacy/`. Its own README records a validated alternative to
verbatim resurrection (139 proof lines collapse to 44 via a `Nat.find` boundary lemma).

### RestrictedMCSDeferral
`Deferral.lean` from `Metalogic/Core/RestrictedMCS/`: an MCS
restricted to `deferralClosure(φ)` rather than `closureWithNeg(φ)`, carrying the extra deferral
disjunctions the successor-seed construction wanted while preserving the same F/P-depth bounds.
It is a complete development — Lindenbaum, negation-completeness, double-negation elimination,
the `iterF`/`iterP` bounds and the `drm_*` closure properties, 19 declarations. It has no live
consumers, and the construction it existed for is archived under `BundleSuccessorSeed/`, which it
imports directly.

### RetiredTactics
Fourteen tactic declarations and two whole modules from `Automation/`,
retired on a **measurement** rather than a design change: every artefact had zero real
invocations in the live library and zero in `Tests/`, counting only genuine invocations and not
docstring mentions or a defining file's own round-trip examples.

`Helpers.lean` and `Normalization.lean` here are **excerpts** — the tactic declarations lifted out
of `Automation/Tactics/Helpers.lean` and `Automation/Normalization.lean`, whose surviving halves
are still live — while the two Aesop modules were moved whole. **This directory is guard-first**;
see the second exception under the CONVENTION WARNING at the top of this file.

### RoundRobinChain
Round-robin chain construction (2 files, 2,522 lines). Confirmed dead after
extensive research: the depth-0 base case of `forward_F` is blocked by the BX11
perpetual deferral obstruction -- an Until obligation can be perpetually deferred
to later chain stages without ever being fulfilled.

### ScheduleBasedBFMCS
A schedule-based BFMCS chain from `BXCanonical/RootScopedChain.lean`. The
schedule fixes in advance which obligation is discharged at which stage; the Lindenbaum step then
loses F-obligations, so the schedule cannot be honoured. Bypassed by the Chronicle
construction.

### SemanticBenchmarkToyEvaluator
One whole test-tree module, `Tests/BimodalTest/Semantics/SemanticBenchmark.lean`, retired on the
same **measurement** as `RetiredTactics/` -- zero real invocations in the live library and in
`Tests/` -- and on a finding about what it measured. It advertised a `TruthAt` evaluation
benchmark but never called `TruthAt`: it timed a hand-written six-case `Bool` function that
hard-codes box and the tense operators as true, and its "correctness" column compared that function
against hand-typed constants. A mechanical repair compiled but scored 14/16, because the invented
`untl`/`snce` branches have no correct value. No `untl`/`snce` occurrences, so the archive
banner's argument swap has nothing to act on. Its derivation-tree sibling was repaired instead.

### SorriedDeclExcisions
Dead-sorry closure excisions: verified-dead declaration closures (each carrying
statement-position sorries) moved out of live code. Every archived declaration was
confirmed dead by word-boundary grep — zero external consumers; where consumers
exist they fall entirely inside the moved closure. Archive files follow the
never-built policy: source-file import blocks verbatim, an
`ARCHIVED (Boneyard) — never compiled.` docstring naming the moved declarations and
ending `Do not import from live code.`, `#exit` before the first declaration, then
the excised code verbatim. Stale imports are never repaired and no path here is a
lakefile target. File inventory (see subdirectory README for details):
`Ghr93ForwardToBackwardChain.lean` (7 decls), `AlgebraicGQuotChain.lean` (5 decls),
`WeakTruthLemmaCluster.lean` (12 decls), `SingletonSorriedDecls.lean` (3 decls),
`UntilSinceCoherence.lean` (6 decls), `BundleUntilSinceStep.lean` (7 decls, from the
`## Until/Since Step Properties` section of `Bundle/SuccRelation.lean`). A related 24-decl
closure went to `StaviDiscretePath/` instead (see that section).

### SoundnessVariants
`DenseSoundness.lean` and `DiscreteSoundness.lean` from the top level of
`Metalogic/`. Thin wrapper modules for the Dense and Discrete soundness
variants with zero live importers. The live `soundness_dense` and
`soundness_discrete` theorems are proved in `Metalogic/Soundness.lean`, so
these wrappers were pure orphans.

### StageInductionGapAnalysis
Dead-end proof attempts for `IsSuccArchimedean` of the chronicle limit domain.
Analysis confirmed the gap scenario is genuine: the constant-MCS case
is consistent with all axioms including Z1 and Prior-UZ. The weak/reflexive completeness
route bypasses this via a Henkin canonical model instead -- see
`Metalogic/WeakCanonical/README.md`.

### StaviDiscretePath
Discrete Stavi completeness path (EF game pipeline) with no live consumers:
`DiscreteGameTransfer.lean`, `DiscreteStaviCompleteness.lean`, `NFGameBridge.lean`.
Also holds `StaviExpressiveCompletenessTail.lean` (24 decls, 3 sorries) — the
dead expressive-completeness tail of `WeakCanonical/EFGames/StaviCompleteness.lean`,
archived under the SorriedDeclExcisions never-built conventions (imports verbatim,
ARCHIVED docstring, `#exit`, code verbatim) but placed here thematically alongside
the rest of the discrete Stavi pipeline. The tail closure was enlarged from the
originally-audited 16 declarations to its verified 24-decl fixpoint during excision
(8 pre-tail helpers whose only consumers sat inside the tail — see the
SorriedDeclExcisions subdirectory README for the list).

### StrictSemanticsLegacy
Largest archive (9 files, 14,330 lines, 107 sorries). Complete completeness
proof infrastructure written under strict temporal semantics. Includes algebraic
chains (UltrafilterChain, DovetailedChain), bundle constructions (SuccChainFMCS,
CanonicalConstruction), frame condition completeness, and top-level wiring.
Architecturally incompatible with current open-guard semantics. See subdirectory
README for file breakdown.

### SupersededCompleteness
`Completeness.lean` from `Metalogic/`, which **compiled at
archival** — this is one of the entries the Archival Criterion above is about. It had zero live
importers: the only `import FormalSystem.Metalogic.Completeness` line anywhere in the repository
came from another archived file, so the module sat outside every Lake target's import closure and
`lake build` never touched it, while both `Metalogic/README.md` and the `Metalogic.lean` module
docstring went on describing it as live. Archived to make the documentation and the build graph
agree.

### TAxiomDependentCode
Three files depending on the T-axiom (`G(phi)->phi` / `H(phi)->phi`), which is
NOT valid under strict temporal semantics. Contains archived functions from
TargetedChain, CanonicalConstruction, and FMP TruthPreservation. Archived during
the reflexive-to-strict semantics migration.

### UltrafilterDeadCode
Four files documenting dead approaches removed from UltrafilterChain.lean during
a sorry-elimination cleanup (23 sorries removed). Includes F-preserving seed
(proven FALSE), bidirectional seed (H(a)->G(H(a)) not derivable), Z-chain (circular
dependencies), and CoherentZChain. Files contain documentation headers only, not
compilable code. See subdirectory README for detailed removal summary.

### UltrafilterFrame
Three files from Algebraic/: AlgebraicCompleteness.lean (the algebraic
completeness theorem built on the ultrafilter machinery), plus
TenseS5Algebra.lean (365 lines, 3 sorries for removed
axioms temp_a and temp_l) and UltrafilterFrame.lean (1,182 lines, 2 sorries for
temp_4). TenseS5Algebra defines the STSA typeclass and proves the Lindenbaum algebra
instance. UltrafilterFrame defines R_G/R_H/R_Box accessibility relations,
UltrafilterChain structure, and F/P resolution theorems. UltrafilterFrame was
commented out from Algebraic.lean due to elaboration interference with
BXCanonical/Completeness.lean rfl proofs; TenseS5Algebra's only consumer was
UltrafilterFrame. That elaboration-interference attribution has since been tested and did
not reproduce for the four `Algebraic/` modules that remain live -- which are now wired into
the build graph -- but it remains untested, and so remains in force, for these two archived
files; see the subdirectory README for the scoped adjudication. Both are prerequisites for
the Jonsson-Tarski representation theorem. Recoverable via git history.

### XuLemma321Legacy
Blocked proof-by-contradiction attempt for Xu's Lemma 3.2.1(i)/(ii). The
inconsistent case requires BX9, which was removed as unsound under open guard
semantics. Doubly obsolete: Xu 3.2.1 was later proved via `dcs_neg_union_consistent`.
See subdirectory README for recovery options.

## When to Consult the Archive

**Consult it** when:

- You are about to try an approach and want to know whether it has already been attempted and
  closed. Start from the classification table above: anything in the **Refuted** provenance class
  has its obstruction named, and the subtree's own README states what would have to change for
  the route to reopen.
- You want to understand why a particular axiom or semantic choice was made. The archived code
  shows what breaks under the alternatives -- the T-axiom under strict temporal semantics, BX9
  and BX1 under the irreflexive order, closed-guard `[t,s]` intervals -- rather than asserting
  that they break.
- You are reading the paper and have reached a passage that cites an archived route.
  `latex/subfiles/04-Metalogic.tex` points here for the completeness approach that is a matter of
  historical record rather than a current development.
- You are writing about this project's development history.

**Do not consult it** when:

- You want working code to import or adapt. Nothing here compiles reliably; every file is
  `#exit`-guarded and many reference removed imports and deleted definitions.
- You are trying to understand the current proof architecture. Use the live `Metalogic/` tree and
  its README.
- You are auditing live identifier usage. This tree's identifiers predate the Mathlib naming
  migration and will produce thousands of false positives -- see Identifiers Here Predate the
  Mathlib Naming Migration above, which carries the measurement.
- You have found a `sorry` here and think it needs fixing. It does not. That is what this tree is
  for, and C3 is the check that says so.

## Provenance: When Each Subtree Was Archived

Every row below is keyed on a **date and a commit SHA**, which an external reader of this
formalization can follow with `git show`. This table used to be keyed on repository-internal
task numbers instead -- integers that resolve only against `specs/`, are renumbered by archive
operations, and mean nothing to anyone outside this working copy. Date and SHA are deliberately
paired: the pair is redundant enough that the date still locates the event if the history is
ever rewritten.

Recovering these needed one non-obvious step, recorded here so it does not have to be
rediscovered. `git log --follow` against a *current* path stops at `5359fef7d`, the tree-wide
rename `Theories/Bimodal -> FormalSystem`; the per-event history survives under the pre-rename
path. Query all three prefixes at once:

```bash
git log --format='%h %ad' --date=short --reverse -- \
  "Theories/Bimodal/Boneyard/<name>" "Boneyard/<name>" "FormalSystem/Boneyard/<name>" | head -1
```

| Archived | Commit | What arrived |
|----------|--------|--------------|
| 2026-03-31 | `6cd694b36` | `UltrafilterDeadCode/` -- 23 sorries removed from `UltrafilterChain.lean` |
| 2026-03-31 | `2c1d9d6b3` | `BundleTemporalCoherence/` -- bundle-level coherence, semantically wrong for TM |
| 2026-04-03 | `d518abe8a` | `TAxiomDependentCode/` -- the strict-semantics migration |
| 2026-04-07 | `8c3cddb33` | `ChainCompleteness/` -- the earlier chain completeness iteration |
| 2026-04-08 | `8a0c51a58` | `DiscreteXY/` -- `x_content`/`y_content` removal |
| 2026-04-12 | `b75a264ff` | `StrictSemanticsLegacy/` -- 9 files moved as a unit |
| 2026-04-16 | `d06951f1e` | `RoundRobinChain/` -- blocked by the BX11 perpetual-deferral obstruction |
| 2026-04-20 | `0527ce5a4` | `DefectDirectedChain/` -- the defect metric failed to decrease |
| 2026-04-20 | `e76e2d332` | `DeadCanonicalModel/` -- the enriched seed approach |
| 2026-04-20 | `c5aee214a` | `QuasimodelOracle/` -- oracle chains, backward transfer invalid |
| 2026-04-27 | `9226a59ae` | `ClosedGuardLegacy/` -- closed-guard `[t,s]` interval semantics |
| 2026-05-01 | `2e85aa64f` | `NonBurgessSeed/` -- legacy `g_content`/`h_content` |
| 2026-05-08 | `11220eb1c` | `DenseChronicle/` -- dense chronicle attempts, hit the density gap |
| 2026-05-13 | `10555237c` | `XuLemma321Legacy/` -- made doubly obsolete by `dcs_neg_union_consistent` |
| 2026-05-13 | `658283450` | `StageInductionGapAnalysis/` -- the gap scenario confirmed genuine |
| 2026-05-15 | `ed0910179` | `VacuousKEquiv.lean` -- two theorems whose proofs were reflexivity |
| 2026-05-20 | `2dbbd43c8` | `BX1DependentCode/` -- BX1 removed under irreflexive semantics |
| 2026-05-20 | `b1f63cf4e` | `FiltrationOrdering/` -- Sigma-restricted ordering for filtration |
| 2026-05-20 | `eded6388a` | `OpenGuardInvalid/` -- 27 sorry-tainted definitions from `TemporalDerived.lean` |
| 2026-05-20 | `07c38c6a0` | `UltrafilterFrame/` and `ScheduleBasedBFMCS/` |
| 2026-05-29 | `bcb2b36f9` | `DeadConvergenceProof/` -- the dead convergence proof for `succ_cofinal` |
| 2026-05-30 | `654270043` | `BXPipelineGapAnalysis/` -- blocked by the falsity of `no_gaps_faithful` |
| 2026-06-03 | `6afa16e18` | `BXPipelineDeadCode/` -- deprecated Reynolds model surgery and dead definitions |
| 2026-06-16 | `95c67593f` | `DeadChronicleGapElimination/` -- the 10-declaration `sorryAx` closure |
| 2026-06-16 | `82d7bf6f2` | `KampNegationClosure/` and `RabinovichPath/` (now under `Kamp/`) |
| 2026-06-16 | `e94c38ca7` | `StaviDiscretePath/` and `BXCanonicalQuasimodel/` |
| 2026-07-08 | `8845f0623` | `MergedBracketQuarantine/` -- the refuted merged-bracket route |
| 2026-07-14 | `c29fa7465` | `RestrictedMCSDeferral/` -- the deferral-restricted MCS variant |
| 2026-07-24 | `56e9f62ff` | `ConservativeExtension/`, `FMPVariants/`, `SoundnessVariants/` -- the orphan sweep |
| 2026-07-24 | `95dd182e1` | `SorriedDeclExcisions/` -- the first dead-sorry closure excisions |
| 2026-07-26 | `29d49f42d` | `BundleSuccessorSeed/` -- 72 declarations with zero live consumers |
| 2026-07-26 | `4fa3f7912` | `SupersededCompleteness/` -- `Metalogic/Completeness.lean`, zero live importers |
| 2026-08-24 | `94da79d88` | `Kamp/` -- the two archives consolidated and the flat Kamp files regrouped |
| 2026-09-02 | `ab24de633` | `BundleDeadHalf/` -- the cascade after breaking the `Core -> Bundle` cycle |
| 2026-09-03 | `cabe89a9e` | `LimitMCSCoherenceDeadCases/` -- five theorems from the `TemporalSide` parameterization |
| 2026-09-03 | `4bebf5796` | `RestrictedMCSBoundedness/` -- retired alongside its already-archived consumer |
| 2026-09-07 | `1ff119610` | `RetiredTactics/` -- fourteen tactic declarations with zero real invocations |
| 2026-09-16 | `b9c49b560` | `SemanticBenchmarkToyEvaluator/` -- a `TruthAt` benchmark that never called `TruthAt` |

### A note on task-number citations inside this tree

At the start of this repair the archive carried 90 task-number citations across 34 of its files.
**Two** of them were in this file; both are gone. That leaves **88 across 33 files** -- 24
subdirectory READMEs and 9 archived `.lean` docstrings -- each sitting next to the code it
describes.

Check **C9** (zero task-number citations under `FormalSystem/`) therefore keeps its
`grep -v '/Boneyard/'` exclusion, and this is a recorded decision rather than an oversight.
Narrowing the exclusion today would turn a green gate red over those 88 occurrences, and clearing
them would mean rewriting the provenance prose of 33 archived files -- work with a real cost and
little reader benefit. A red gate is a
worse publication state than a documented exclusion. The measurement is reproducible:

```bash
grep -rniE --include='*.lean' --include='*.md' \
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_[A-Za-z0-9_]+' \
  FormalSystem/Boneyard | wc -l
```

If that count is ever driven to zero, drop the `grep -v '/Boneyard/'` filter from C9 and the rule
becomes gate-enforced across the whole of `FormalSystem/`.

## Git Retrieval

To browse a file's history before archival:

```bash
# Follow renames to see original location
git log --follow --oneline FormalSystem/Boneyard/<subdir>/<file>.lean

# View file at a specific commit
git show <commit>:FormalSystem/<original-path>/<file>.lean

# Diff between archival and current
git diff <pre-archival-commit> HEAD -- FormalSystem/Boneyard/<subdir>/<file>.lean
```

To find when a file was archived:

```bash
# Check the commit that moved the file
git log --diff-filter=A --oneline -- FormalSystem/Boneyard/<subdir>/<file>.lean
```

## Boneyard Maintenance Standard

### How to Archive Files

1. **Create a subdirectory** under `FormalSystem/Boneyard/` with a descriptive name
2. **Move the file** using Boneyard-qualified import paths:
   - If the file imports other Boneyard files, use `import FormalSystem.Boneyard.<subdir>.<file>`
   - If the file imports active modules, keep those imports as-is
3. **Move imports before doc comments**: In Lean 4, `/-! ... -/` doc comments are commands;
   `import` statements must appear BEFORE any commands
4. **Add `#exit`**: after the import block, before the first declaration. This is mandatory, not
   conditional -- see the `#exit` policy under Build Policy below
5. **Create a README.md** in the subdirectory explaining why the code was archived,
   what it contained, and any relationship to active code
6. **Update this README** with a new row in the Directory Inventory table

### Build Policy: Never Compiled

Boneyard code is never compiled. There is no lakefile target covering the Boneyard;
liveness equals reachability: a module is live if and only if it is reachable from
`FormalSystem.lean` or another lakefile root. Nothing under a `Boneyard/`
directory is reachable from any root.

Import lines inside archived files are historical text, not build edges -- but they are **not**
optional. **This README used to say that stale imports in never-built code "are cosmetic and need
not be repaired". That policy is retired.** It was written before the archive had a gate, and
under it the archive rotted: 65 archived import lines named modules that no longer existed on
disk by the time the two archives were consolidated.

Check **C11** in `scripts/check-module-invariants.sh` now enforces the opposite rule. Every
`import FormalSystem.*` / `import BimodalTest.*` line under `FormalSystem/Boneyard/` must resolve
to a file on disk, or be named in `scripts/boneyard-import-waivers.txt` with a recorded reason.
C11 ships enforced, with no opt-out flag, and reports waiver entries that no longer occur so the
waiver file cannot become a backlog. A README must not carry a rule its own gate contradicts, so
the old sentence is retired here rather than quietly deleted.

The build invariants after any Boneyard change are therefore:

```bash
lake build                                    # default target stays green
bash scripts/check-module-invariants.sh       # ALL CHECKS PASSED, including C11
```

#### The `#exit` policy: mandatory, and why

**Every archived `.lean` file carries `#exit` after its import block, before its first
declaration.** This section and Expected File Structure below used to disagree -- one said `#exit`
was for files "with deep API drift", the other that archived files "may use `#exit`" -- and under
the permissive reading twelve archived files carried no `#exit` and, in eleven cases, no archival
marker of any kind. A reader who opened one of those files saw a copyright header, an import
block and an ordinary module docstring, with nothing on the page to say it was archived.

`#exit` is redundant against the build, and that is not the point. Reachability is what keeps the
archive inert, and reachability is a *global* property: to check it you must know the lakefile
roots and the whole import graph. `#exit` makes inertness a *local* property instead -- visible in
the first twenty lines of any single file, greppable in one command, and immune to a future
lakefile edit that accidentally roots something under this tree:

```bash
# every archived file is guarded; this prints nothing
for f in $(find FormalSystem/Boneyard -name '*.lean'); do grep -q '^#exit' "$f" || echo "$f"; done
```

Alongside it, each file carries the archival banner

```lean
/-!
ARCHIVED (Boneyard) -- never compiled. Archived material; see the Boneyard README inventory.
Do not import from live code.
-/
```

so that the file states its own status without reference to this README.

### Expected File Structure

Each Boneyard subdirectory contains:
- `README.md` -- purpose, file inventory, why archived, relationship to active code. Every
  subdirectory has one; the nine README-only tombstones below are the case where it is the
  *only* thing the subdirectory contains.
- `.lean` files -- archived code, each carrying the archival banner and `#exit` after its import
  block (mandatory -- see the `#exit` policy above).

Doc-only `.lean` files (pure comments, no imports) should be consolidated into the
README as prose or code blocks, then deleted. Code is always recoverable from git.

**One documented file sits at the archive root rather than in a subdirectory.**
`VacuousKEquiv.lean` is a single 35-line excision from
`Metalogic/WeakCanonical/OrderedSum.lean` -- two theorems whose names promised Z-interval
k-equivalence and whose proofs were `⟨M, rfl⟩`, reflexivity and nothing more. It is small enough
that a directory-plus-README around it would be more ceremony than content, and it is cited by
path from a live comment in `Metalogic/WeakCanonical/OrderedSum.lean` (search that file for
`finite_structures_k_equiv_to_Z_interval`), so moving it would change live code to no benefit. The Directory Inventory below gives it a row like any other entry, and the generator
picks it up automatically as a loose file; a root-level file is admitted here precisely because
it is documented in both places rather than merely tolerated.

### Tombstones (README Only, No .lean Files)

After doc-only consolidation, these nine subdirectories contain only a README —
the code was deleted and the README is retained as the historical record:

- `BundleTemporalCoherence/`
- `BX1DependentCode/`
- `ClosedGuardLegacy/`
- `NonBurgessSeed/`
- `OpenGuardInvalid/`
- `StageInductionGapAnalysis/`
- `TAxiomDependentCode/`
- `UltrafilterDeadCode/`
- `XuLemma321Legacy/`

Each such README carries the first-line marker
`TOMBSTONE — code deleted; README retained as historical record.` Tombstone
READMEs are never deleted. The original `.lean` files are recoverable from git
history (commits before the doc-only consolidation).
(DeadCanonicalModel was formerly on this list; it now holds two archived files
from the orphan-triage pass — see its inventory row above.)
