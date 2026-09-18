# Follow-Up Proposals: C17's Remaining 698 Survivors

Every cluster this task deliberately did not execute carries a ready-to-run `/task` proposal
below, with the evidence that makes it decidable. The `def` cluster is the only one that was
executed; nothing else here was left undecided by oversight.

Regenerate the evidence for any proposal with:

```
python3 specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py --summary
python3 specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py > /tmp/census.tsv
```

## Where the 698 sit

| Cluster | Members | Kind | Disposition | Proposal |
|---|---:|---|---|---|
| B. Referenced only from `Boneyard/` | 47 | 46 `theorem`, 1 `def` | `retire-to-Boneyard` | F1 |
| C. `structure` survivors | 8 | `structure` | `keep-with-reason` | F6 (audit only) |
| C'. `inductive` survivors | 2 | `inductive` | `keep-with-reason` | F6 (audit only) |
| D. `abbrev` survivor | 1 | `abbrev` | `follow-up` | F5 |
| E. `theorem` survivors in import-orphan modules | 6 | `theorem` | `keep-with-reason` | F3 |
| F. Remaining `theorem` survivors | 634 | `theorem` | `follow-up` | F2 |
| **Total** | **698** | | | |

Two populations below the headline, excluded by filter rather than surviving it, also need
owners: the 145 `@[simp]`-attributed declarations (F4) and the 48 `instance` declarations
(F4, same instrument).

---

## F1 -- Retire the 47 Boneyard-only declarations

```
/task "Decide the retirement of the 47 live declarations whose only remaining consumer is under FormalSystem/Boneyard/. C17 reports these beneath its headline rather than inside it, because 'the only consumer is archived' is a different case from 'no consumer': moving one is a C11-waiver decision about the archive, not a deletion. Produce a per-declaration disposition (retire to Boneyard alongside its consumer / keep because the archived reference is incidental / delete because the archived consumer is itself dead) and execute the unambiguous ones. 46 theorems plus one def, freshBase in FormalSystem/Syntax/Atom.lean, which has 14 Boneyard references and was the single def survivor this task's deletion batches deliberately left in place."
```

**Evidence**: the full list is C17's own sub-count block (run the harness and read the lines
under `of those 698, 47 ARE referenced from FormalSystem/Boneyard/`), or
`awk -F'\t' '$1=="SURVIVOR" && $7+0>0' census.tsv`. `boneyard_refs` gives each one's archived
reference count. `freshBase` is the highest at 14.

**Why not here**: this task's deletion scope was declarations with no consumer at all, live or
archived. Retiring a declaration into the archive requires a C11 waiver decision the deletion
batches did not own.

---

## F2 -- Triage the 634 remaining `theorem` survivors, by file

```
/task "Triage the 634 theorem declarations C17 reports with zero occurrences outside their own declaring line, excluding the Boneyard-only and import-orphan populations already owned elsewhere. Work by FILE, not by line: a plain unattributed theorem has no indirect-reachability story -- Lean offers no mechanism that reaches it without naming it -- so each row is genuinely one of three things, and telling them apart requires reading the surrounding development. Classify each as (a) a stepping stone whose consumer was refactored away, (b) a result kept deliberately as documentation of what the development proves, or (c) an artifact of a proof that was later restructured. Start with the 18 files carrying 8 or more rows, which are coherent single questions; the 97 files carrying 1-2 rows are a separate, lower-value tail."
```

**Evidence**: 634 rows across 195 files. Largest units:

| File | Rows |
|---|---:|
| `FormalSystem/Syntax/SubformulaClosure/TemporalFormulas.lean` | 18 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/RRelation.lean` | 16 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` | 16 |
| `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` | 12 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` | 11 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` | 11 |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 11 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` | 11 |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` | 11 |

18 files carry >= 8 rows; 97 files carry 1-2.

**Sizing warning, measured here**: budget for iteration, not one pass. Deleting a declaration
removes occurrences of the declarations it referenced, so a deletion batch exposes new
zero-occurrence declarations. This task's 80 planned deletions exposed 19 further declarations,
12 of which were themselves dead and deleted. Any batch must re-run the census after every
sub-batch and stop on convergence, never on having finished the original list.

---

## F3 -- Decide the BiLasso import-orphan subtree

```
/task "Decide what to do with the four import-orphan BiLasso modules -- FormalSystem/Metalogic/Decidability/BiLasso/{Extend,Successor,Orbit,Agreement}.lean -- which sit outside the build graph of every Lake target root while remaining live, compiling, and manifested. They carry 75 declarations across 1,348 lines, 84 percent of the 89 declarations C6 reports for all ten manifested FormalSystem modules. The question is the subtree's status, not the status of individual declarations: either the development they belong to gets finished and imported, or they are archived as a unit. Five of C17's theorem survivors are inside them and acting on those rows individually would be treating a symptom."
```

**Evidence**: `scripts/module-invariants-manifest.txt` lists all four. C6's INFO line reports the
aggregate (`15 manifested module(s) carry 128 declaration(s) across 3104 line(s) outside the
build graph (10 FormalSystem module(s): 89 declaration(s), 2018 line(s))`). Comment-aware
per-module counts measured here: `Orbit.lean` 51 decls / 916 lines, `Successor.lean` 12 / 137,
`Extend.lean` 10 / 120, `Agreement.lean` 2 / 175.

The five in-subtree C17 rows: `unroll_mid` (`Extend.lean`), and `iterSucc_add`, `iterPred_add`,
`fwdCycle_length_le`, `bwdCycle_length_le` (`Orbit.lean`). A sixth import-orphan row,
`bracketEndChar_kvE2_correct_two_prior_frag_faithful_covers_prior` in
`WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGateFaithful.lean`, is outside BiLasso and rides
along with whatever that module's own disposition turns out to be.

**Why not here**: a build-graph decision about a 1,348-line subtree is not a dead-declaration
decision, and C6 already owns the instrument.

---

## F4 -- Burn down the unused-simp-lemma and unused-instance populations

```
/task "Audit the 145 @[simp]-attributed and 48 instance declarations that C17 excludes from its headline, using an instrument that reads the simp set and the instance table rather than counting identifier tokens. C17 excludes them because both are reached by mechanisms a textual scan structurally cannot observe -- a simp lemma through the default or a registered simp set, an instance through typeclass resolution -- so a zero-occurrence count on either says nothing. That exclusion is an accepted blind spot recorded in the C17 header, not a claim that the population is clean: an unused simp lemma still costs simp time on every call. Report how many of the 145 never fire on any goal in the library or test suite, and how many of the 48 are never selected by typeclass resolution."
```

**Evidence**: current tier counts, stable since baseline, from
`c17_triage.py --summary`: `T1_instance` 48, `T2_simp` 145, `T3_custom_simp` 12. The handoff is
already recorded in `scripts/check-module-invariants.sh`'s C17 header under
`ACCEPTED BLIND SPOT` and in `docs/development/MODULE_INVARIANTS.md`'s C17 row, precisely so
neither effort assumes the other covers it. This proposal is that handoff's other half.

**Instrument note**: `set_option trace.Meta.Tactic.simp` over the test suite, or a `simp?`-style
sweep, sees firing; token counting does not. Do not approach this with a grep.

---

## F5 -- Decide the `FiniteTaskModel` abbrev

```
/task "Decide whether FormalSystem/Semantics/TaskModel.lean should keep the abbrev FiniteTaskModel. It is C17's only abbrev survivor. An abbrev is a reducible alias whose entire purpose is to be a convenient spelling, so being unused is a statement about the convenience rather than about correctness. It sits immediately beside a sibling alias, FiniteTaskFrame.Model -- the bundled spelling -- which IS used, making it a plausible leftover from a naming change. This is an API question about which spelling the library offers, not a dead-code question."
```

**Evidence**: one row, `FiniteTaskModel` in `FormalSystem/Semantics/TaskModel.lean`. Note that
this task's Phase 10 already deleted unreferenced `def`s from this same file, so line numbers
from the snapshot census are stale; regenerate before acting.

---

## F6 -- Audit the 8 `structure` and 2 `inductive` survivors

```
/task "Audit the 8 structure and 2 inductive declarations C17 reports with zero occurrences, and record a reason per declaration rather than a blanket one. The standing disposition is keep-with-reason: a structure's constructor is reached by anonymous-constructor notation and by pattern matching, neither of which spells the type's name, and its fields are reached by dot notation on a value whose type is inferred, so a zero-occurrence count on the type name is weak evidence of anything. But weak evidence is not no evidence -- two structures in this population were confirmed genuinely dead during the C17 deletion batches and removed, by the direct evidence that their sole consumer had just been deleted. Distinguish the two situations declaration by declaration."
```

**Evidence**: `awk -F'\t' '$1=="SURVIVOR" && ($4=="structure" || $4=="inductive")' census.tsv`.
Current members: `CheckpointState` (`Automation/FormulaEnumerator.lean`), `ValidChronicle`
(`BXCanonical/Chronicle/ChronicleTypes.lean`), `OpenBranch` and `BranchStatus`
(`Decidability/Closure.lean`), `SemanticCountermodelResult`
(`Decidability/CountermodelExtraction.lean`), `BatchDecisionResult`
(`Decidability/DecisionProcedure.lean`), `BundledFilteredFrame` (`Decidability/FMP/FMP.lean`),
`ProofExtractionStats` (`Decidability/ProofExtraction.lean`), `TableauStats`
(`Decidability/Saturation.lean`), `EFPosition` (`WeakCanonical/EFGames/Defs.lean`).

Four of these ten were not in the Phase 7 snapshot: `BranchStatus`,
`SemanticCountermodelResult`, `BatchDecisionResult` and `EFPosition` became zero-occurrence when
the `def`s that used them were deleted. That provenance is itself evidence and should be read
before defaulting to `keep`.

**Precedent from this task**: `ParallelEnumConfig` and `LevelComplete` in
`Automation/FormulaEnumerator.lean` were deleted rather than kept, because their only consumer
(`enumerateLevelParallel`) had just been deleted and the section header they lived under
described a subsystem with no remaining members. Commit `99ce8d32d`.

---

## F7 -- Write the `indirect-reachability.md` agent-context note

```
/task "Write an agent-context note enumerating the mechanisms by which a Lean declaration is reached without its name being written: typeclass resolution for instances, the default and registered simp sets for @[simp] and register_simp_attr attributes, aesop rule sets, label attributes such as @[tmLemma], anonymous-constructor notation and pattern matching for structure and inductive constructors, dot notation on inferred types for fields, deriving handlers, and lean_exe main entry points. The audience is any future effort tempted to act on a textual occurrence scan. C17's six filters encode this knowledge inside one script's header comment, where only a reader of that script finds it."
```

**Placement question to resolve first**: this repository has no `agent-system/extensions/`
source store, so the correct target is genuinely ambiguous. `.claude/` here is a gitignored,
regenerated deploy artifact (see `.claude/rules/source-store-deploy-boundary.md`), so a file
hand-authored there is wiped on the next regeneration. Candidate targets:
`docs/development/` alongside `MODULE_INVARIANTS.md`, or `.claude/context/project/lean4/` via
whatever source store feeds this deploy. Resolve the target before writing, not after.

**Why not here**: named in this plan's explicit out-of-scope list for exactly this reason.

---

## F8 -- Teach C17 that its own count is not stable under deletion

```
/task "Record in scripts/check-module-invariants.sh's C17 header that the census is not a fixed worklist: because the scan counts occurrences, deleting a flagged declaration removes occurrences of everything it referenced, so a deletion batch exposes new flagged declarations. Measured during the C17 deletion batches: 80 planned deletions exposed 19 further zero-occurrence declarations, of which 12 were themselves dead and deleted, three were theorems, two structures and two inductives. Any future effort acting on C17 must re-run the census after each sub-batch and stop on convergence rather than on having exhausted the original list. State the counting consequence too: a batch's headline drop will not equal its deletion count, and that is correct rather than a reconciliation error."
```

**Evidence**: this task's own reconciliation. Post-filter headline 771, minus 80 snapshot
survivors deleted, plus 7 newly exposed survivors, equals the final headline 698 -- a drop of 73
against 92 declarations actually deleted. The 19-point gap between 92 and 73 is the cascade, and
an accounting that does not model it cannot be made to reconcile.

**Why it matters more than it looks**: the task description's most durable-deliverable
suggestion was extending C17's filters so the number it reports is the number that matters. The
filters landed. This is the other half: the number that matters is also a moving target while
anyone is acting on it.
