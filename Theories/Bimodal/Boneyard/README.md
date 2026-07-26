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
| [BXCanonicalQuasimodel](#bxcanonicalquasimodel) | 1 | 166 | BXCanonical/Quasimodel/ | Enriched (Fisher-Ladner) closure — no live downstream consumers | 302 |
| [BXPipelineDeadCode](#bxpipelinedeadcode) | 2 | 576 | WeakCanonical/IntegerModel/ | BX pipeline dead code: deprecated Reynolds model surgery (no_gaps_faithful false) and dead ReynoldsNoGaps definitions (zero references) | 268, 255 |
| [BXPipelineGapAnalysis](#bxpipelinegapanalysis) | 2 | 304 | WeakCanonical/, Chronicle/ | BX pipeline gap analysis: no_gaps_faithful is provably false (Z+Z counterexample), succ_cofinal dead chain. Correct path: Reynolds pipeline via no_gaps_discrete. | 225 |
| [BX1DependentCode](#bx1dependentcode) | 0 | -- | Quasimodel/Realization.lean | BX1-dependent helpers; BX1 removed under irreflexive semantics | 130 |
| BundleSuccessorSeed | 1 | 1,218 | Metalogic/Bundle/ | Deferral-seed successor/predecessor existence construction; zero live consumers of all 72 declarations, and its 3 sorries all reduce to the T-axiom for `G`/`H` (unsound under open-guard semantics) — see subdirectory README | -- |
| [BundleTemporalCoherence](#bundletemporalcoherence) | 0 | -- | UltrafilterChain.lean | Semantically wrong: bundle-level coherence allows temporal witnesses in different world histories | 80 |
| [ChainCompleteness](#chaincompleteness) | 12 | 4,265 | BXCanonical/ | Earlier chain completeness iteration, superseded by SuccChain approach | 93 |
| [ClosedGuardLegacy](#closedguardlegacy) | 0 | -- | Various | Closed guard semantics `[t,s]` replaced by open guard `(t,s)` | 109 |
| [ConservativeExtension](#conservativeextension) | 4 | 1,616 | Metalogic/ConservativeExtension/ | Self-contained conservative-extension development with zero live importers; archived as a directory unit (incl. its README) | -- |
| [DeadCanonicalModel](#deadcanonicalmodel) | 2 | 644 | BXCanonical/, Bundle/, ProofSystem/ | Dead enriched seed approach (README), plus orphaned `CanonicalIrreflexivity.lean` and broken `Substitution.lean` with zero live importers | 113 |
| DeadChronicleGapElimination | 2 | 1,013 | BXCanonical/Chronicle/ | Dead chronicle gap-elimination chain (`chronicle_gap_contradiction` sorry chain); the live `completeness_discrete` uses the Reynolds pipeline — see subdirectory README | -- |
| [DeadConvergenceProof](#deadconvergenceproof) | 2 | 468 | Root Boneyard/ | Dead convergence proof for succ_cofinal; relocated from root Boneyard/ | 202, 302 |
| [DefectDirectedChain](#defectdirectedchain) | 1 | 1,564 | BXCanonical/ | Defect-directed root-scoped chain, abandoned after defect metric failed to decrease | 107 |
| [DenseChronicle](#densechronicle) | 3 | 287 | Chronicle/ | Dense chronicle construction attempts, hit density gap | 105 |
| [DiscreteXY](#discretexy) | 1 | 77 | Various | Discrete x_content/y_content approach, replaced by open guard semantics | 85 |
| [FiltrationOrdering](#filtrationordering) | 1 | 171 | Filtration/SigmaOrdering.lean | Sigma-restricted ordering for filtration; BX1 removed under irreflexive semantics | 130 |
| [FMPVariants](#fmpvariants) | 2 | 237 | Decidability/FMP/ | Dense/Discrete FMP variants with zero live importers; the tableau pipeline uses the Base-variant FMP | -- |
| KampBypassArchive | 13 | 9,383 | WeakCanonical/Kamp/ | Enriched Kamp bypass-formula route (bypass core, per-direction correctness, composition); superseded by the landed live Kamp pipeline | -- |
| [KampNegationClosure](#kampnegationclosure) | 4 | 3,284 | WeakCanonical/Kamp/ | Negation closure chain (Rabinovich 2014 Sec 5) — no live downstream consumers | 302 |
| MergedBracketQuarantine | 1 | 1,036 | WeakCanonical/Kamp/NfMultiAnchorBridge/ | Refuted merged-bracket route — violates no-nesting audit + Rabinovich Lemma 5.1 QF point-type; task-321 fallback | 332 |
| [NonBurgessSeed](#nonburgessseed) | 0 | -- | PointInsertion.lean | Legacy g_content/h_content approach, hit density gap | 107 |
| [OpenGuardInvalid](#openguardinvalid) | 0 | -- | TemporalDerived.lean | BX8/BX9 dependent + reflexivity-dependent theorems invalid under open guard (t,s) | 173 |
| [QuasimodelOracle](#quasimodeloracle) | 3 | 1,477 | BXCanonical/ | Oracle approach abandoned: 25+ sorry gaps, BX11 perpetual deferral obstruction | 107 |
| [RabinovichPath](#rabinovichpath) | 4 | 1,294 | WeakCanonical/Kamp/ | Rabinovich generalized approach — no live downstream consumers | 302 |
| RestrictedMCSDeferral | 1 | 772 | Metalogic/Core/RestrictedMCS/ | Deferral-restricted MCS (deferralClosure) variant of the successor seed construction; no live consumers | -- |
| [RoundRobinChain](#roundrobinchain) | 2 | 2,537 | BXCanonical/ | Round-robin chain: BX11 perpetual deferral makes depth-0 base case unprovable | 107 |
| [ScheduleBasedBFMCS](#scheduledbasedbfmcs) | 1 | 226 | BXCanonical/RootScopedChain.lean | Schedule-based BFMCS chain; Lindenbaum step loses F-obligations, bypassed by Chronicle | 130 |
| [SorriedDeclExcisions](#sorrieddeclexcisions) | 5 | 3,184 | Metalogic/ (various), Bundle/ | Dead-sorry closure excisions: verified-dead declaration closures carrying statement-position sorries; never-built archive files (`#exit` guarded) — see section for inventory | -- |
| [SoundnessVariants](#soundnessvariants) | 2 | 110 | Metalogic/ | Dense/Discrete soundness wrapper modules with zero live importers; the live `soundness_dense`/`soundness_discrete` theorems are proved in `Metalogic/Soundness.lean` | -- |
| [StageInductionGapAnalysis](#stageinductiongapanalysis) | 0 | -- | ChronicleToCountermodel | Dead-end IsSuccArchimedean proof attempts; gap scenario is genuine | 123 |
| [StaviDiscretePath](#stavidiscretepath) | 4 | 4,984 | WeakCanonical/EFGames/ | Discrete Stavi completeness — EF game pipeline with no live consumers, plus the dead expressive-completeness tail excised from the live `StaviCompleteness.lean` | 302 |
| [StrictSemanticsLegacy](#strictsemanticslegacy) | 9 | 14,392 | Metalogic/ | Completeness under strict semantics; architectural incompatibility with current open-guard semantics | 94 |
| [TAxiomDependentCode](#taxiomdependentcode) | 0 | -- | Various | T-axiom dependent (`G(phi)->phi`); unsound under strict temporal semantics | 83 |
| [UltrafilterDeadCode](#ultrafilterdeadcode) | 0 | -- | UltrafilterChain.lean | Dead approaches: F-preserving seed (proven FALSE), bidirectional, Z-chain, coherent Z-chain | 80 |
| [UltrafilterFrame](#ultrafilterframe) | 3 | 1,745 | Algebraic/ | TenseS5Algebra (3 sorries for removed axioms), UltrafilterFrame (2 sorries for temp_4), and AlgebraicCompleteness (completeness via the ultrafilter machinery); Jonsson-Tarski prerequisite | 21 |
| VecEADecomposition | 1 | 334 | WeakCanonical/Kamp/ | Syntactic VBracketFormula negation and Prop 4.3 support; bypassed by the NF-specific Prop 4.3 approach — see subdirectory README | -- |
| [XuLemma321Legacy](#xulemma321legacy) | 0 | -- | RRelation.lean | Blocked proof-by-contradiction for Xu 3.2.1; BX9 unsound under open guard semantics | 115 |
| VacuousKEquiv.lean (root) | 1 | 35 | Theorems/ | Vacuous K-equivalence proof, standalone | -- |
| **Total** | **90** | **57,391** | | | |

Counts are measured from the tree (`find <subdir> -name "*.lean" | wc -l` and `wc -l` over
those files); line counts include the normalized `ARCHIVED (Boneyard)` headers and `#exit`
markers.

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

### FMPVariants
`DenseFMP.lean` and `DiscreteFMP.lean` from `Metalogic/Decidability/FMP/`.
Finite-model-property statements for the Dense and Discrete TM variants. No
live module imported either file; the tableau decision procedure consumes the
Base-variant FMP interface only.

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

### RoundRobinChain
Round-robin chain construction (2 files, 2,522 lines). Confirmed dead after
extensive research: the depth-0 base case of `forward_F` is blocked by the BX11
perpetual deferral obstruction -- an Until obligation can be perpetually deferred
to later chain stages without ever being fulfilled.

### StageInductionGapAnalysis
Dead-end proof attempts for `IsSuccArchimedean` of the chronicle limit domain
Analysis confirmed the gap scenario is genuine: the constant-MCS case
is consistent with all axioms including Z1 and Prior-UZ. Task 129 (weak/reflexive
completeness) bypasses this via a Henkin canonical model.

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
`UntilSinceCoherence.lean` (6 decls). A related 24-decl closure went to
`StaviDiscretePath/` instead (see that section).

### SoundnessVariants
`DenseSoundness.lean` and `DiscreteSoundness.lean` from the top level of
`Metalogic/`. Thin wrapper modules for the Dense and Discrete soundness
variants with zero live importers. The live `soundness_dense` and
`soundness_discrete` theorems are proved in `Metalogic/Soundness.lean`, so
these wrappers were pure orphans.

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
UltrafilterFrame. Both are prerequisites for the Jonsson-Tarski representation
theorem. Recoverable via git history.

### XuLemma321Legacy
Blocked proof-by-contradiction attempt for Xu's Lemma 3.2.1(i)/(ii). The
inconsistent case requires BX9, which was removed as unsound under open guard
semantics. Doubly obsolete: Xu 3.2.1 was later proved via `dcs_neg_union_consistent`.
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
| 225 | BXPipelineGapAnalysis (ChronicleNoGaps + HenkinDiscreteChain, dead BX pipeline) | 2026-05-30 |
| 268 | BXPipelineDeadCode/ReynoldsModelSurgery.lean (deprecated no_gaps_faithful) | 2026-06-02 |
| 255 | BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean (4 dead definitions from ReynoldsNoGaps.lean) | 2026-06-04 |
| 301 | DeadChronicleGapElimination (GapElimination.lean from ChronicleToCountermodel) | 2026-06-15 |
| 302 | KampNegationClosure (4 files), RabinovichPath (4), StaviDiscretePath (3), BXCanonicalQuasimodel (1), DeadConvergenceProof relocate, TransferDead.lean, inline dead blocks | 2026-06-16 |

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

## Boneyard Maintenance Standard

### How to Archive Files

1. **Create a subdirectory** under `Theories/Bimodal/Boneyard/` with a descriptive name
2. **Move the file** using Boneyard-qualified import paths:
   - If the file imports other Boneyard files, use `import Bimodal.Boneyard.<subdir>.<file>`
   - If the file imports active modules, keep those imports as-is
3. **Move imports before doc comments**: In Lean 4, `/-! ... -/` doc comments are commands;
   `import` statements must appear BEFORE any commands
4. **Add `#exit` if needed**: For files with deep API drift (removed axioms, renamed types),
   add `#exit` after imports to prevent compilation errors while preserving code for reference
5. **Create a README.md** in the subdirectory explaining why the code was archived,
   what it contained, and any relationship to active code
6. **Update this README** with a new row in the Directory Inventory table

### Build Policy: Never Compiled

Boneyard code is never compiled. There is no lakefile target covering the Boneyard;
liveness equals reachability: a module is live if and only if it is reachable from
`Theories/Bimodal.lean` or another lakefile root. Nothing under a `Boneyard/`
directory is reachable from any root.

The only build invariant is that the default target stays green after any Boneyard
change:

```bash
# Must stay green after any Boneyard change
lake build
```

Import lines inside archived files are historical text, not build edges. They are
kept coherent with file locations where cheap, but stale imports in never-built
code are cosmetic and need not be repaired.

### Expected File Structure

Each Boneyard subdirectory should contain:
- `README.md` -- Purpose, file inventory, why archived, relationship to active code
- `.lean` files -- Archived code (may use `#exit` for non-compiling reference code)

Doc-only `.lean` files (pure comments, no imports) should be consolidated into the
README as prose or code blocks, then deleted. Code is always recoverable from git.

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
