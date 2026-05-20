# Boneyard -- Archived Dead Code

This directory contains archived Lean code that is no longer part of the active
development path. Files are preserved for historical reference, documentation of
dead-end approaches, and potential future consultation.

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

| Directory | Files | Lines | Archived From | Why Archived | Task |
|-----------|------:|------:|---------------|--------------|------|
| [BX1DependentCode](#bx1dependentcode) | 2 | 85 | Quasimodel/Realization.lean | BX1-dependent helpers (F_of_mem, P_of_mem, enriched seed consistency); BX1 removed under irreflexive semantics | 130 |
| [BundleTemporalCoherence](#bundletemporalcoherence) | 1 | 74 | UltrafilterChain.lean | Semantically wrong: bundle-level coherence allows temporal witnesses in different world histories | 80 |
| [ChainCompleteness](#chaincompleteness) | 12 | 4,186 | BXCanonical/ | Earlier chain completeness iteration, superseded by SuccChain approach | 93 |
| [ClosedGuardLegacy](#closedguardlegacy) | 4 | 352 | Various | Closed guard semantics `[t,s]` replaced by open guard `(t,s)` | 109 |
| [DeadCanonicalModel](#deadcanonicalmodel) | 1 | 90 | BXCanonical/ | Dead enriched seed approach, structurally unfixable | 113 |
| [DefectDirectedChain](#defectdirectedchain) | 1 | 1,556 | BXCanonical/ | Defect-directed root-scoped chain, abandoned after defect metric failed to decrease | 107 |
| [DenseChronicle](#densechronicle) | 3 | 281 | Chronicle/ | Dense chronicle construction attempts, hit density gap | 105 |
| [DiscreteXY](#discretexy) | 1 | 72 | Various | Discrete x_content/y_content approach, replaced by open guard semantics | 85 |
| [FiltrationOrdering](#filtrationordering) | 2 | 194 | Filtration/SigmaOrdering.lean | Sigma-restricted ordering for filtration; BX1 removed under irreflexive semantics | 130 |
| [NonBurgessSeed](#nonburgessseed) | 1 | 141 | PointInsertion.lean | Legacy g_content/h_content approach, hit density gap | 107 |
| [OpenGuardInvalid](#openguardinvalid) | 1 | 215 | TemporalDerived.lean | BX8/BX9 dependent + reflexivity-dependent theorems invalid under open guard (t,s); seriality-dependent sorry stubs | 173 |
| [QuasimodelOracle](#quasimodeloracle) | 3 | 1,467 | BXCanonical/ | Oracle approach abandoned: 25+ sorry gaps, BX11 perpetual deferral obstruction | 107 |
| [RoundRobinChain](#roundrobinchain) | 2 | 2,522 | BXCanonical/ | Round-robin chain: BX11 perpetual deferral makes depth-0 base case unprovable | 107 |
| [ScheduleBasedBFMCS](#scheduledbasedbfmcs) | 2 | 257 | BXCanonical/RootScopedChain.lean | Schedule-based BFMCS chain; Lindenbaum step loses F-obligations, bypassed by Chronicle | 130 |
| [StageInductionGapAnalysis](#stageinductiongapanalysis) | 1 | 53 | ChronicleToCountermodel | Dead-end IsSuccArchimedean proof attempts; gap scenario is genuine | 123 |
| [StrictSemanticsLegacy](#strictsemanticslegacy) | 9 | 14,330 | Metalogic/ | Completeness under strict semantics (107 sorries); architectural incompatibility with current open-guard semantics | 94 |
| [TAxiomDependentCode](#taxiomdependentcode) | 3 | 316 | Various | T-axiom dependent (`G(phi)->phi`); unsound under strict temporal semantics | 83 |
| [UltrafilterDeadCode](#ultrafilterdeadcode) | 4 | 1,064 | UltrafilterChain.lean | Dead approaches: F-preserving seed (proven FALSE), bidirectional, Z-chain, coherent Z-chain | 80 |
| [UltrafilterFrame](#ultrafilterframe) | 2 | 1,547 | Algebraic/ | TenseS5Algebra (3 sorries for removed axioms) and UltrafilterFrame (2 sorries for temp_4, elaboration conflicts); Jonsson-Tarski prerequisite | 21 |
| [XuLemma321Legacy](#xulemma321legacy) | 1 | 75 | RRelation.lean | Blocked proof-by-contradiction for Xu 3.2.1; BX9 unsound under open guard semantics; task 115 proved via different method | 115 |
| **Total** | **56** | **28,877** | | | |

## Archival Reason Taxonomy

### Unsound Axioms / Semantics
Code that relied on axioms later found to be unsound under the project's semantic
foundation. Examples: BX9 (unsound under open guard semantics), T-axiom
(`G(phi)->phi`, invalid under strict temporal semantics), closed guard interval
semantics.
- Directories: TAxiomDependentCode, ClosedGuardLegacy, XuLemma321Legacy, OpenGuardInvalid

### Superseded Approaches
Working code replaced by fundamentally different (usually simpler or more
general) approaches. The archived code may compile and even be correct, but a
better solution exists.
- Directories: ChainCompleteness, NonBurgessSeed, StageInductionGapAnalysis

### Structural Dead Ends
Approaches that hit irreparable mathematical barriers: false lemmas,
non-decreasing defect metrics, perpetual deferral obstructions, or circular
dependencies.
- Directories: UltrafilterDeadCode, QuasimodelOracle, RoundRobinChain,
  DefectDirectedChain, DeadCanonicalModel, DenseChronicle, DiscreteXY

### Architectural Incompatibility
Code written for a semantic foundation that the project has since departed from.
The proof strategies may be sound under their original semantics but cannot be
adapted to the current system without fundamental restructuring.
- Directories: StrictSemanticsLegacy, BundleTemporalCoherence

## Subdirectory Details

### BundleTemporalCoherence
Bundle-level temporal coherence code from UltrafilterChain.lean. Semantically
wrong for TM task semantics: F(phi) witnesses may come from a different world
history, but TM requires witnesses within the same history. See subdirectory
README for detailed semantic analysis.

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

### DeadCanonicalModel
Single file containing an enriched seed approach to canonical model construction.
The approach is structurally unfixable: the enrichment step cannot maintain
consistency of the extended seed.

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

### NonBurgessSeed
Legacy g_content/h_content functions from PointInsertion.lean (task 107 Phase 3).
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

### RoundRobinChain
Round-robin chain construction (2 files, 2,522 lines). Confirmed dead after
extensive research: the depth-0 base case of `forward_F` is blocked by the BX11
perpetual deferral obstruction -- an Until obligation can be perpetually deferred
to later chain stages without ever being fulfilled.

### StageInductionGapAnalysis
Dead-end proof attempts for `IsSuccArchimedean` of the chronicle limit domain
(task 123). Analysis confirmed the gap scenario is genuine: the constant-MCS case
is consistent with all axioms including Z1 and Prior-UZ. Task 129 (weak/reflexive
completeness) bypasses this via a Henkin canonical model.

### StrictSemanticsLegacy
Largest archive (9 files, 14,330 lines, 107 sorries). Complete completeness
proof infrastructure written under strict temporal semantics. Includes algebraic
chains (UltrafilterChain, DovetailedChain), bundle constructions (SuccChainFMCS,
CanonicalConstruction), frame condition completeness, and top-level wiring.
Architecturally incompatible with current open-guard semantics. See subdirectory
README for file breakdown.

### TAxiomDependentCode
Three files depending on the T-axiom (`G(phi)->phi` / `H(phi)->phi`), which is
NOT valid under strict temporal semantics. Contains archived functions from
TargetedChain, CanonicalConstruction, and FMP TruthPreservation. Archived during
the reflexive-to-strict semantics migration (task 83).

### UltrafilterDeadCode
Four files documenting dead approaches removed from UltrafilterChain.lean during
task 80 cleanup (23 sorries removed). Includes F-preserving seed (proven FALSE by
task 69), bidirectional seed (H(a)->G(H(a)) not derivable), Z-chain (circular
dependencies), and CoherentZChain. Files contain documentation headers only, not
compilable code. See subdirectory README for detailed removal summary.

### UltrafilterFrame
Two files from Algebraic/: TenseS5Algebra.lean (365 lines, 3 sorries for removed
axioms temp_a and temp_l) and UltrafilterFrame.lean (1,182 lines, 2 sorries for
temp_4). TenseS5Algebra defines the STSA typeclass and proves the Lindenbaum algebra
instance. UltrafilterFrame defines R_G/R_H/R_Box accessibility relations,
UltrafilterChain structure, and F/P resolution theorems. UltrafilterFrame was
commented out from Algebraic.lean due to elaboration interference with
BXCanonical/Completeness.lean rfl proofs; TenseS5Algebra's only consumer was
UltrafilterFrame. Both are prerequisites for the Jonsson-Tarski representation
theorem (task 125). Recoverable via git history.

### XuLemma321Legacy
Blocked proof-by-contradiction attempt for Xu's Lemma 3.2.1(i)/(ii). The
inconsistent case requires BX9, which was removed as unsound under open guard
semantics. Doubly obsolete: task 115 proved Xu 3.2.1 via `dcs_neg_union_consistent`.
See subdirectory README for recovery options.

## When to Consult the Boneyard

**Do consult** when:
- You are about to try an approach and want to check if it was already attempted
  and failed
- You need to understand why a particular axiom or semantic choice was made (the
  archived code shows what breaks under alternatives)
- You are writing documentation about the project's development history

**Do not consult** when:
- You are looking for working code to import or adapt (nothing here compiles
  reliably)
- You are trying to understand the current proof architecture (use the active
  Metalogic/ directory instead)
- You see a sorry in the Boneyard and think it needs fixing (it does not)

## Task Cross-References

| Task | What It Archived | When |
|------|-----------------|------|
| 80 | UltrafilterDeadCode (23 sorries from UltrafilterChain.lean) | 2026-03-31 |
| 83 | TAxiomDependentCode (strict semantics migration) | 2026-04-03 |
| 85 | DiscreteXY (x_content/y_content removal) | 2026-04-05 |
| 93 | ChainCompleteness, additional dead code | 2026-04-10 |
| 94 | StrictSemanticsLegacy (9 files, 107 sorries) | 2026-04-12 |
| 105 | DenseChronicle (dense chronicle attempts) | 2026-04-22 |
| 107 | QuasimodelOracle, NonBurgessSeed, DefectDirectedChain | 2026-04-28 |
| 109 | ClosedGuardLegacy | 2026-04-30 |
| 113 | DeadCanonicalModel (enriched seed) | 2026-05-02 |
| 115 | Made XuLemma321Legacy doubly obsolete | 2026-05-13 |
| 123 | StageInductionGapAnalysis | 2026-05-13 |
| 132 | Consolidated root Boneyard/ into this location | 2026-05-13 |
| 21 | UltrafilterFrame (TenseS5Algebra + UltrafilterFrame from Algebraic/) | 2026-05-20 |
| 173 | OpenGuardInvalid (27 sorry-tainted definitions from TemporalDerived.lean) | 2026-05-20 |

## Git Retrieval

To browse a file's history before archival:

```bash
# Follow renames to see original location
git log --follow --oneline Theories/Bimodal/Boneyard/<subdir>/<file>.lean

# View file at a specific commit
git show <commit>:Theories/Bimodal/<original-path>/<file>.lean

# Diff between archival and current
git diff <pre-archival-commit> HEAD -- Theories/Bimodal/Boneyard/<subdir>/<file>.lean
```

To find when a file was archived:

```bash
# Check the commit that moved the file
git log --diff-filter=A --oneline -- Theories/Bimodal/Boneyard/<subdir>/<file>.lean
```
