# Disposition Table: C17's post-filter survivors

Every one of the **771** declarations C17 reports after the six filters landed carries a
disposition here. The rows below partition that set: each survivor appears in exactly one
cluster, and the member counts sum to 771 -- verified mechanically against the regenerated
census, not asserted.

The census this table was built from is `tools/c17_census.tsv`, regenerated from the
post-filter script. **That file is a snapshot, never an input to a later deletion batch.** Line
numbers go stale on the first edit, so every deletion phase regenerates the census first and
works from the fresh run.

## Disposition vocabulary

| Disposition | Meaning |
|---|---|
| `delete-in-this-task` | Executed here, in a verified batch. Nothing indirect can reach it and nothing reads it as documentation. |
| `retire-to-Boneyard` | Its only remaining consumer is archived. Moving it is an archive decision with its own C11 waiver consequences, not a deletion, and it is not executed here. |
| `keep-with-reason` | Reached by a mechanism no textual scan can see, or already covered by another instrument. Stays, with the reason recorded. |
| `follow-up` | Needs a judgement this task did not own. Carried into `followups.md` with its evidence. |

## Summary

| Cluster | Members | Kind | Disposition |
|---|---:|---|---|
| A. `def` survivors with no live or archived consumer | 80 | `def` | `delete-in-this-task` |
| B. Referenced only from `FormalSystem/Boneyard/` | 47 | 46 `theorem`, 1 `def` | `retire-to-Boneyard` + `follow-up` |
| C. `structure` survivors | 6 | `structure` | `keep-with-reason` |
| D. `abbrev` survivor | 1 | `abbrev` | `follow-up` |
| E. `theorem` survivors in manifested import-orphan modules | 6 | `theorem` | `keep-with-reason` |
| F. Remaining `theorem` survivors | 631 | `theorem` | `follow-up` |
| **Total** | **771** | | |

**This table is the pre-execution snapshot.** It is retained as the historical record of what
was decided and on what evidence. For the post-execution partition -- which clusters were
executed, which rows moved, and the four declarations that entered Cluster C during execution --
see [Execution Outcome](#execution-outcome) at the end of this file. No row is left undecided in
either view.

---

## Cluster A -- `def` survivors: `delete-in-this-task`

**80 members.** The one unambiguous cluster, and the only one this task executes.

Evidence, per member and re-confirmed against a freshly regenerated census immediately before
each batch runs: the base identifier occurs on no other line in any `.lean` file under
`FormalSystem/` or `Tests/`, any non-`specs/` `.md` file, any `typst/**/*.typ`, any
`scripts/*.sh`, or any file under `FormalSystem/Boneyard/`. A `def` carries none of the
indirect-reachability stories that keep the other clusters alive: it is not an `instance`
found by typeclass resolution, it carries no simp-set attribute, it is not under
`FormalSystem/Examples/` where being uncalled is the point, and unlike a `structure` it has no
constructor or projection reachable by pattern matching. Nothing reaches it except by name,
and nothing names it.

Split into three directory-scoped batches so each is verifiable on its own:

### Batch A -- `Metalogic/Decidability/` (35 rows)

| File | Rows |
|---|---:|
| `FormalSystem/Metalogic/Decidability/Closure.lean` | 3 |
| `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean` | 5 |
| `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` | 3 |
| `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` | 1 |
| `FormalSystem/Metalogic/Decidability/IntPresentation.lean` | 1 |
| `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` | 3 |
| `FormalSystem/Metalogic/Decidability/Saturation.lean` | 3 |
| `FormalSystem/Metalogic/Decidability/SignedFormula.lean` | 13 |
| `FormalSystem/Metalogic/Decidability/Tableau.lean` | 2 |
| `FormalSystem/Metalogic/Decidability/TraceCertificate.lean` | 1 |

### Batch B -- `Metalogic/{WeakCanonical,BXCanonical,Independence,Algebraic}/` (26 rows)

| File | Rows |
|---|---:|
| `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` | 5 |
| `FormalSystem/Metalogic/BXCanonical/Filtration/DefectChain.lean` | 2 |
| `FormalSystem/Metalogic/BXCanonical/Quasimodel/Construction.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/TruthLemma.lean` | 1 |
| `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/ChronicleExtraction.lean` | 3 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/Defs.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` | 4 |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness/Slots.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/Translation.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` | 1 |

### Batch C -- outside `Metalogic/` (19 rows)

| File | Rows |
|---|---:|
| `FormalSystem/Automation/AtomCanonicalization.lean` | 1 |
| `FormalSystem/Automation/ContrastiveGeneratorMain.lean` | 2 |
| `FormalSystem/Automation/DatasetGenerator.lean` | 1 |
| `FormalSystem/Automation/FormulaEnumerator.lean` | 3 |
| `FormalSystem/Automation/ForwardProofGenerator.lean` | 2 |
| `FormalSystem/Automation/ProofSearch/Core.lean` | 1 |
| `FormalSystem/Automation/ProofSearch/Strategies.lean` | 1 |
| `FormalSystem/Automation/SuccessPatterns.lean` | 1 |
| `FormalSystem/Automation/Tactics/Search.lean` | 1 |
| `FormalSystem/ProofSystem/LinearityDerivedFacts.lean` | 1 |
| `FormalSystem/Semantics/TaskModel.lean` | 1 |
| `FormalSystem/Syntax/SubformulaClosure/Closure.lean` | 3 |
| `FormalSystem/Theorems/Propositional/Reasoning.lean` | 1 |

Every batch additionally diffs its name list against `scripts/check-module-invariants.sh` and
`typst/chapters/*.typ` and aborts on any hit, and is gated on `lake build`,
`lake build BimodalTest` and the full invariant harness before it is accepted.

---

## Cluster B -- referenced only from `Boneyard/`: `retire-to-Boneyard` + `follow-up`

**47 members** (46 `theorem`, 1 `def`: `freshBase` in `FormalSystem/Syntax/Atom.lean`).

These are **not** deleted here, and the distinction is the reason the census now reports them
as a separate sub-count. "No consumer" and "the only consumer is archived" are different
facts with different remedies. Deleting one of these breaks an archived file's imports, which
is C11's territory: the archive is never compiled, so `lake build` cannot see the breakage,
and the repair is either a matching archive edit or a new entry in
`scripts/boneyard-import-waivers.txt`. That is a retirement decision about what the archive is
for, and it is handed off rather than taken here.

The evidence is per member and mechanical: the base identifier occurs on at least one
comment-stripped line under `FormalSystem/Boneyard/` and nowhere in live scope. Comment-
stripping matters -- an archived file that merely mentions a name in prose is not its consumer,
and those rows are not in this cluster.

| File | Rows |
|---|---:|
| `FormalSystem/Syntax/SubformulaClosure/TemporalFormulas.lean` | 10 |
| `FormalSystem/Metalogic/WeakCanonical/Separation/Defs.lean` | 5 |
| `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean` | 4 |
| `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean` | 3 |
| `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` | 3 |
| `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` | 2 |
| `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` | 2 |
| `FormalSystem/Metalogic/WeakCanonical/ChronicleExtraction.lean` | 2 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/GapDetection.lean` | 2 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` | 2 |
| `FormalSystem/Syntax/Atom.lean` | 2 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/OrderedSeedConsistency.lean` | 1 |
| `FormalSystem/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` | 1 |
| `FormalSystem/Metalogic/Soundness.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/Defs.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | 1 |

The largest single cluster, `Syntax/SubformulaClosure/TemporalFormulas.lean`, is the natural
first unit for the follow-up: ten deferral-closure theorems whose only consumer is archived is
a coherent retirement question, in a way that ten scattered singletons is not.

---

## Cluster C -- `structure` survivors: `keep-with-reason`

**6 members.**

| Declaration | File |
|---|---|
| `CheckpointState` | `FormalSystem/Automation/FormulaEnumerator.lean`:1761 |
| `ValidChronicle` | `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`:680 |
| `OpenBranch` | `FormalSystem/Metalogic/Decidability/Closure.lean`:154 |
| `BundledFilteredFrame` | `FormalSystem/Metalogic/Decidability/FMP/FMP.lean`:168 |
| `ProofExtractionStats` | `FormalSystem/Metalogic/Decidability/ProofExtraction.lean`:363 |
| `TableauStats` | `FormalSystem/Metalogic/Decidability/Saturation.lean`:1268 |

A `structure` is reached by mechanisms a base-identifier token scan structurally cannot see.
Its constructor is reached by anonymous-constructor notation and by pattern matching, neither
of which spells the type's name; its fields are reached by dot notation on a value whose type
is inferred. A zero-occurrence count on a `structure` name is therefore weak evidence of
anything -- it says the type is not written out, not that it is unused. These stay, and the
reason is recorded here rather than being rediscovered.

---

## Cluster D -- the `abbrev` survivor: `follow-up`

**1 member:** `FiniteTaskModel` in `FormalSystem/Semantics/TaskModel.lean`:101.

An `abbrev` is a reducible alias: it exists to be a convenient spelling, so being unused is a
statement about the convenience, not about correctness. This one sits immediately beside a
sibling alias (`FiniteTaskFrame.Model`, "the bundled spelling") that IS used, which makes it a
plausible leftover from a naming change rather than an oversight -- but deciding that is an API
question about which spelling the library wants to offer, not a dead-code question. It is
outside this task's `def`-only deletion scope and is carried forward.

---

## Cluster E -- `theorem` survivors in import-orphan modules: `keep-with-reason`

**6 members**, all inside modules already listed in
`scripts/module-invariants-manifest.txt`:

| Declaration | File |
|---|---|
| `unroll_mid` | `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean`:111 |
| `iterSucc_add` | `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`:149 |
| `iterPred_add` | `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`:156 |
| `fwdCycle_length_le` | `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`:273 |
| `bwdCycle_length_le` | `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`:278 |
| `bracketEndChar_kvE2_correct_two_prior_frag_faithful_covers_prior` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGateFaithful.lean`:200 |

These are already covered by an existing instrument, which is why they are kept rather than
dispositioned again here. C6 walks import reachability from every Lake target root, fails when
an unreachable live module is not manifested, and compile-checks each manifested module in
isolation -- and it now also reports how many declarations and lines those modules carry
outside the build graph, which is the one thing it did not say before. Acting on these six
rows individually would be treating a symptom: the real question is what to do with the
modules, and that is a build-graph decision carried into the follow-ups as a subtree.

---

## Cluster F -- remaining `theorem` survivors: `follow-up`

**631 members**, the bulk of the census and the part no mechanical filter can resolve.

A plain, unattributed `theorem` has no indirect-reachability story at all: Lean offers no
mechanism that reaches it without naming it. So unlike every other cluster here, a
zero-occurrence count on one of these is not obviously a false positive -- it is genuinely
either a stepping stone whose consumer was refactored away, a result kept deliberately as
documentation of what the development proves, or an artifact of a proof that was later
restructured. Telling those three apart requires reading the surrounding development, one
cluster at a time. That is real work, and pretending a scan can do it is exactly how a census
stops being informative.

They are therefore grouped by file, largest first, so the follow-up work has natural units --
a file with a dozen unreferenced theorems is one coherent question, and the 356 rows in the
tail are 158 separate small ones.

| File | Rows |
|---|---:|
| `FormalSystem/Metalogic/BXCanonical/Chronicle/RRelation.lean` | 16 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` | 15 |
| `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` | 12 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` | 11 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` | 11 |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 11 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` | 11 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` | 11 |
| `FormalSystem/Metalogic/Decidability/Correctness.lean` | 10 |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/OrientedGate.lean` | 10 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/CustomGame.lean` | 10 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean` | 10 |
| `FormalSystem/Semantics/TaskFrame.lean` | 10 |
| `FormalSystem/Semantics/Validity.lean` | 10 |
| `FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean` | 9 |
| `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` | 8 |
| `FormalSystem/Syntax/StarLanguage/Formula.lean` | 8 |
| `FormalSystem/Syntax/SubformulaClosure/TemporalFormulas.lean` | 8 |
| `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean` | 7 |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` | 7 |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/MintPotential.lean` | 7 |
| `FormalSystem/Metalogic/Soundness.lean` | 7 |
| `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance.lean` | 7 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness/EngineInputs.lean` | 7 |
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 6 |
| `FormalSystem/Metalogic/BXCanonical/Quasimodel/Construction.lean` | 6 |
| `FormalSystem/Metalogic/Decidability/Closure.lean` | 6 |
| `FormalSystem/Metalogic/Decidability/FMP/ClosureMCS.lean` | 6 |
| `FormalSystem/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` | 6 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean` | 6 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` | 6 |
| *(158 further files with fewer than 6 rows each)* | 356 |

By subtree: Metalogic/WeakCanonical 249, Metalogic/Decidability 126, Metalogic/BXCanonical 105, Syntax 37, Semantics 33, Metalogic/Conservativity 30.

---

## Execution outcomes

Filled in as the deletion batches land. A row whose probe contradicts the census -- a
reference the scan missed, or a build that breaks -- is reclassified to `keep-with-reason`
with the failure recorded as its evidence, never forced through and never silently skipped.

| Batch | Planned | Executed | Reclassified | Notes |
|---|---:|---:|---:|---|
| A -- `Metalogic/Decidability/` | 35 | -- | -- | not yet run |
| B -- other `Metalogic/` subtrees | 26 | -- | -- | not yet run |
| C -- outside `Metalogic/` | 19 | -- | -- | not yet run |

---

## Execution Outcome

Recorded at the close of Phase 11, against the tree at commit `e462cf3e2`. Every count here was
regenerated, not carried forward.

### What executed

**Cluster A executed in full: all 80 members deleted.** Verified by set difference between this
file's source snapshot (`tools/c17_census.tsv`, 771 survivor rows) and a freshly regenerated
census: 80 survivor rows are gone, every one of them a `def`, which is exactly Cluster A's
membership. Nothing else in the snapshot was touched.

Three batches, each committed per file with `lake build`, `lake build BimodalTest` and the full
invariant harness green: Phase 8 (`Metalogic/Decidability/`, 35 rows), Phase 9 (the remaining
`Metalogic/` subtrees, 26 rows), Phase 10 (everything outside `Metalogic/`, 20 rows) -- 81 rows
planned, 80 executed, the one exclusion being `freshBase`.

### The one deliberate exclusion

`freshBase` in `FormalSystem/Syntax/Atom.lean` was the single `def` member of Cluster B, not
Cluster A: it carries 14 `Boneyard/` references, so its only consumer is archived. Retiring it
is a C11-waiver decision about the archive rather than a deletion, and it is carried into
`followups.md` as F1. It is now C17's only remaining `def` survivor, which is the intended
end state rather than an unfinished one.

### Rows that moved during execution

Deleting a declaration removes occurrences of everything it referenced, so the deletion batches
exposed declarations that had not been flagged when this table was written. Seven such
declarations survive and are now in the census; twelve more were themselves dead and were
deleted in the same task, so they appear in no census.

| Cluster | Snapshot | Now | What changed |
|---|---:|---:|---|
| A. `def`, no consumer | 80 | 0 | All 80 deleted. Cluster closed. |
| B. Boneyard-only | 47 | 47 | Unchanged. Still 46 `theorem` + `freshBase`. |
| C. `structure` | 6 | 8 | `BatchDecisionResult` and `EFPosition` entered during execution. |
| C'. `inductive` (new) | 0 | 2 | `BranchStatus` and `SemanticCountermodelResult` entered during execution. The snapshot had no `inductive` survivors, so this cluster did not exist; it inherits Cluster C's `keep-with-reason` rationale and its audit proposal. |
| D. `abbrev` | 1 | 1 | Unchanged. `FiniteTaskModel`. |
| E. import-orphan `theorem` | 6 | 6 | Unchanged. |
| F. remaining `theorem` | 631 | 634 | `mcs_filtration_equiv_equivalence`, `densePriorAtomMap_surj` and `densePrior_target_hypotheses_inhabited` entered during execution. |
| **Total** | **771** | **698** | |

Two declarations that entered during execution were deleted rather than kept, against Cluster
C's standing `keep-with-reason` disposition: `ParallelEnumConfig` and `LevelComplete` in
`FormalSystem/Automation/FormulaEnumerator.lean`. **This is a considered departure, not an
oversight.** Cluster C's rationale is that a zero-occurrence count on a `structure` is *weak
evidence* because the type name need never be written. Here the evidence was direct and did not
depend on the token count: their only consumer, `enumerateLevelParallel`, had just been deleted,
and the `/-! ## Two-Phase Parallel Enumeration and Pipeline Overlap` section header they lived
under described a subsystem with no remaining members. The whole section was removed as a unit
(commit `99ce8d32d`). The four declarations that newly entered Clusters C and C' were *not*
treated this way, because for those the direct evidence is absent; they are carried into
`followups.md` as F6, which records this precedent so the distinction is available rather than
rediscovered.

### Final partition

C17's headline is **698**, partitioned with no residue: 47 Boneyard-only + 8 `structure` + 2
`inductive` + 1 `abbrev` + 6 import-orphan `theorem` + 634 remaining `theorem` = 698. Every one
of the six clusters is either executed (A) or carries a follow-up proposal in `followups.md`
(B -> F1, F -> F2, E -> F3, D -> F5, C and C' -> F6).
