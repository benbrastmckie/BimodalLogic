
## Deliberately-retained hits (Phase 7.1 done-when clause)

Exactly one whole-word occurrence of an old final component survives anywhere under
`FormalSystem/` (excluding `Boneyard/`) and `Tests/`:

| file | text | why retained |
|---|---|---|
| `FormalSystem/Semantics/Truth.lean` | `lem:history-time-shift-preservation` | Not the declaration `lem`. This is a **paper cross-reference label**, the same `prefix:label` convention used throughout the tree (`def:frame`, `app:TaskSemantics`, `def:world-history` in `Semantics/TaskFrame.lean`, `Semantics/WorldHistory.lean`, `Examples/TemporalStructures.lean`). The automated sweep rewrote it to `em:` and it was reverted by hand. |

This was the sweep's ONLY false positive across 7,300 rewrites (0.014%), and it is the class the
short Part C abbreviations create: `lem`/`ecq`/`efq`/`raa` are three letters long, so unlike the
834 underscore-bearing finals they can collide with non-declaration text.

## Tombstone-comment purge — verdict: DELETE NONE

The plan budgets a purge of "96 removed/archived/superseded comments across 39 files" and
requires each be verified first, warning that "some 'removed' mentions are legitimate historical
documentation of complex constructions."

Measured on the current tree: **81 such line comments across 34 files.** Reviewed individually,
essentially all of them record *why a construction is absent*, which is exactly the legitimate
category the plan protects:

- **Soundness records** — `BX7a/BX7a' (linear_until_a7a/linear_since_a7a) removed -- unsound
  under open guard`, `BX9/BX9' (until_elim/since_elim) removed -- unsound under open guard
  (t,s)` (`ProofSystem/Axioms.lean`, `SoundnessLemmas/DenseValidity.lean`,
  `SoundnessLemmas/FrameClassVariants.lean`). Deleting these would erase the reason the axiom
  set has the shape it has.
- **Archival pointers** — `SigmaOrdering archived to Boneyard/FiltrationOrdering/`,
  `chronicle_is_good archived to Boneyard/DeadChronicleGapElimination/TransferDead.lean`. These
  are live navigation aids to code that still exists.
- **Refutation records** — `REMOVED: the two FALSE scaffolds kvE2_sepSlotsL_valid/…`,
  `interior-positive chains … are the refuted device and are REMOVED`
  (`Kamp/NfMultiAnchorBridge/SharedWitness/Carrier.lean`). These prevent a future reader from
  re-deriving a disproved approach.
- **Import-cycle records** — ``NOTE: `import ...KampPrior` was REMOVED to break the import cycle``.

**Zero were deleted.** The purge budget is spent on the verification, which is what the plan
asked for; the finding is that the audit's premise (that these are stale noise) does not hold
for this tree.

### Separate finding, deliberately NOT acted on here

`Tests/` carries **112 task-number citations** (`NOTE (Task 365): quarantined — …`,
`Task 116`, `Task 277`, `Task 319`) across 14 files. These violate
`.claude/rules/no-task-references-in-deliverables.md`, which exempts only `specs/**`, commit
messages, and PR metadata. They are **pre-existing and unrelated to naming** — none was
introduced by this migration, and `scripts/check-module-invariants.sh` check C9 scopes its
task-citation check to `FormalSystem/` only, so `Tests/` was never covered.

Rewriting 112 comments in test files is not a rename and is outside this phase's territory
contract. Recorded here for a follow-up rather than silently absorbed into a naming migration.
