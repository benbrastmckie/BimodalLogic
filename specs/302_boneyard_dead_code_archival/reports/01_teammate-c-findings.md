# Teammate C Findings: Comment Quality, Code Hygiene, and Gaps

## Summary

The codebase is **well-annotated overall** with extensive sorry provenance and archival trails.
The main hygiene issues are: (1) a cluster of misleading "reflexive Until/Since" docstrings
in `Bundle/SuccRelation.lean` that contradict the open-guard system actually in effect;
(2) a single stale TODO in a Typst file; (3) a misleading comment in `Axioms.lean` about
BX1 and density; (4) stale task references to abandoned tasks (155, 268) presented as
forward-looking; and (5) dead Boneyard directories (12 empty placeholder dirs) documented
in README.md but physically empty — low priority but creates index noise.

No hidden coupling risk from removing BXCanonical was found. Boneyard files with live imports
are gated by `#exit` or are in the non-default `BoneyardArchive` lake target.

---

## Key Findings

### 1. Misleading "Reflexive Until/Since" Docstrings in SuccRelation.lean (HIGH)

**Confidence**: High

**Files**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:596-634`

The section header comment says:
```
Under the BX axiom system with reflexive Until/Since semantics, the `until_intro` and
`since_intro` rules are derivable...
Key insight: Under reflexive Until, X(α) = (⊥ U α) is equivalent to α...
```
And the individual theorem docstrings say:
- `or_until_in_mcs` (line 609): "This is the reflexive version of `until_intro`. Under reflexive Until semantics..."
- `or_since_in_mcs` (line 625): "Uses BX8' (reflexive Since intro)"

**Problem**: BX8/BX8' and BX9/BX9' were REMOVED (task 113) because they are unsound under open guard `(t,s)` semantics. All four of these theorems (`until_unfold_in_mcs`, `since_unfold_in_mcs`, `or_until_in_mcs`, `or_since_in_mcs`) are in fact sorry'd with TOMBSTONE comments explaining BX9/BX8 removal. The section-level docstring incorrectly frames the sorry'd functions as provable "under reflexive Until semantics" rather than blocked under the current open guard system.

**Specifically**:
- Line 556: `until_unfold_in_mcs` — TOMBSTONE, sorry, says "reflexive Until intro invalid under open guard"
- Line 565: `since_unfold_in_mcs` — TOMBSTONE, sorry, says "reflexive Since intro invalid under open guard"
- Line 618: `or_until_in_mcs` — TOMBSTONE, sorry, says "reflexive Until intro invalid under open guard"
- Line 632: `or_since_in_mcs` — TOMBSTONE, sorry, says "reflexive Since intro invalid under open guard"

The section heading (line 596) introduces these as "derivable" when they are all sorry'd tombstones. The heading should be updated to reflect that these are dead-end infrastructure that cannot be proved under current open guard semantics.

**Also**: `g_content_subset_mcs` (line 641) and `h_content_subset_mcs` (line 651) say "under irreflexive semantics, G(φ) → φ is no longer valid" — correctly sorry'd but the inline comment mixes "irreflexive" and "open guard" terminology inconsistently with the docstring at line 636 which mentions "under BX1 (reflexive G)."

---

### 2. Misleading Density Axiom Comment in Axioms.lean (MEDIUM)

**Confidence**: High

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean:43`

```lean
- The density axiom (GGφ → Gφ) is derivable from BX1 under reflexive G
```

**Problem**: BX1 is now `serial_future` (seriality: ∀t ∃s, t < s), which replaced the old reflexive G axiom. The density axiom `GGφ → Gφ` is NOT derivable from seriality `serial_future` — it requires a different property. This comment is a remnant of the old reflexive semantics system and is now semantically misleading. Under the current BX axiom system with open guard and serial_future as BX1, this derivability claim is false or at best unverified.

---

### 3. Stale TODO in Typst Notes File (LOW)

**Confidence**: High

**File**: `Theories/Bimodal/typst/chapters/06-notes.typ:99`

```typst
// TODO: Rewrite for strict semantics -- reflexive labels are stale (task 83)
```

Task 83 is not in the current `state.json` active_projects (it is archived). The strict semantics transition has long been completed (tasks 93, 113, etc.). This TODO is stale — the section it precedes (line 100: `== Design Choices`) already discusses strict vs reflexive semantics in the content below it. The TODO is orphaned bookkeeping from an earlier semantic overhaul.

---

### 4. Stale Forward-Looking Task References to Abandoned Tasks (MEDIUM)

**Confidence**: High

Several live source comments reference tasks 155 and 268 as if they contain active work, but both are `[abandoned]` in state.json:

- **Task 155** (`reynolds_pipeline_activation`): abandoned
- **Task 268** (`reynolds_pipeline_bridge`): abandoned

**Occurrences**:
- `Transfer.lean:1261`: "the correct path is `countermodel_discrete_reynolds` (task 155)"
- `Transfer.lean:1277`: "**DEPRECATED** (task 225): This uses the dead BX pipeline path. See `countermodel_discrete_reynolds` for the active path (task 155)."
- `Transfer.lean:1296`: "Base completeness pending task 129 (Henkin model approach)."
- `ChronicleToCountermodel.lean:219,375`: "Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155)."
- `Transfer.lean:1263`: "-- ARCHIVED: BX pipeline dead code, see task 268"

The references to task 155 as providing "the active path" are now misleading since the task was abandoned. The "pending task 129" reference is also potentially stale (task 129 is in the archive but its actual completion status should be verified).

**Note**: These are historical provenance comments, not forward-looking TODOs per se, so they are lower urgency than the misleading semantics comments above.

---

### 5. sorry Markers Without WHY Explanations (MEDIUM)

**Confidence**: Medium

Several sorry sites lack sufficient explanation of what blocks them:

**`Metalogic/Algebraic/InteriorOperators.lean:83`**:
```lean
sorry /- temp_k_dist derivable from BX -/
```
This inline justification is too terse. `temp_k_dist` is stated as "derivable from BX" but there is no explanation of why the derivation has not been completed — is it a missing lemma? A structural gap? An unfiled task?

**`Metalogic/WeakCanonical/OrderedSum.lean:56`**:
Contains `sorry` with no inline comment visible from grep. Needs investigation of surrounding context.

**`Bundle/SuccExistence.lean:446, 749, 823`**:
All sorry'd with inline "BX1 removed under irreflexive semantics" — these are adequately marked as tombstones. However, there is no note about whether these will ever be proved (are they permanently dead or pending a proof strategy change?).

**Well-documented sorry sites** (no action needed):
- `Bundle/SuccRelation.lean` TOMBSTONE sorries: well-explained
- `BXCanonical/Frame.lean:205` (`bx_le_refl`): header doc says "sorry'd under irreflexive semantics"
- `WeakCanonical/TruthLemma.lean:431,448,...`: says "does not block completeness"
- `WeakCanonical/Transfer.lean:1291-1297`: extensive DEPRECATED comment
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` sorry sites: documented as dead code

---

### 6. Stale "Research-016" Reference (LOW)

**Confidence**: High

**Files**:
- `Metalogic/DenseSoundness.lean:27`: `- Research-016: Irreflexive semantics feasibility`
- `Metalogic/DiscreteSoundness.lean:26`: `- Research-016: Irreflexive semantics feasibility`

"Research-016" does not correspond to any task in `specs/state.json` or `specs/archive/`. This appears to be a legacy reference to a pre-task-system research document. The irreflexive semantics work was long completed (tasks 83, 93). These references are orphaned.

---

### 7. Boneyard Provenance Quality Assessment (MIXED)

**Confidence**: High

**Good provenance** (exemplary):
- `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean`: Clear header with origin, reason, and archive date (task 202)
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/GapElimination.lean`: Clear provenance comment in first 5 lines
- `Theories/Bimodal/Boneyard/DenseChronicle/CantorIsoCountermodel.lean`: Header with Status, Origin, task reference
- `Boneyard/README.md`: Comprehensive table with file counts, origin files, reasons, task numbers

**Missing provenance** (needs attention):
- Several Boneyard directories are **physically empty** (README.md only, or completely empty): `BX1DependentCode/`, `BundleTemporalCoherence/`, `ClosedGuardLegacy/`, `DeadCanonicalModel/`, `NonBurgessSeed/`, `OpenGuardInvalid/`, `StageInductionGapAnalysis/`, `UltrafilterDeadCode/` (in `Boneyard/`), plus `XuLemma321Legacy/` and `TAxiomDependentCode/`
  - The README.md documents these as "0 files" and "0 sorries" with explanatory notes — this is fine for the index, but the directories exist as empty shells. This is per-convention (README says these are documented absent rather than populated), so it is more of a consistency observation than a bug.

- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean`: Has imports from live modules (`PriorExpressiveness`, `EFGames.Defs`, `BXCanonical.TruthLemma`) but NO `#exit` guard. If `BoneyardArchive` is built, this file will be compiled against live code. The comment at line 27 explains the import choice (to avoid circular dependencies) but doesn't note the lack of `#exit`.

- `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean`: Uses `#exit` after imports — good.
  `HenkinDiscreteChain.lean`: Has live imports, needs to be checked for `#exit`.

---

### 8. Hidden Coupling: BXCanonical and Live Code (LOW RISK)

**Confidence**: High

The concern about whether removing BXCanonical could break test infrastructure or import chains was investigated. Findings:

- `BXCanonical/BXCanonical.lean` is imported only via `Metalogic/Metalogic.lean` (line 4), which is the top-level re-export. No test files directly import `BXCanonical`.
- BXCanonical is **not dead code** — it is the active (if sorry-laden) completeness proof infrastructure. The `Completeness.lean` sorry chain runs through it.
- The chronicle dead code in `ChronicleToCountermodel.lean` (lines 57-80 section on dead declarations) is correctly identified as dead — `chronicle_gap_contradiction` and `succ_cofinal` are not on any live call path. These could be archived.

**Potential coupling issue**: `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean` imports `BXCanonical.CanonicalModel`. If BXCanonical's module structure changes (e.g., CanonicalModel.lean is renamed or split), BoneyardArchive builds would break. This is low risk since BoneyardArchive is not the default target.

---

### 9. NOTE Comments That Are Arguably Safe to Remove (LOW)

**Confidence**: Medium

Multiple `NOTE:` comments in `SoundnessLemmas/DenseValidity.lean` and `SoundnessLemmas/FrameClassVariants.lean` read:
```lean
-- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
-- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
-- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
-- NOTE: temp_k_dist and temp_4 removed as axiom constructors (Task 116)
```

These appear at 10+ locations. They are "removed constructor" notes left after match arm deletion. Since the constructors no longer exist, a reader cannot accidentally try to add them back without understanding the constraint. These notes serve primarily as history. They are not misleading (they accurately describe what happened) but they are redundant once the code change is established. Consider whether a single module-level comment would suffice rather than per-site inline notes.

---

## Recommended Approach

**Priority 1 (semantic correctness)**:
1. Fix the section heading at `Bundle/SuccRelation.lean:596` to accurately say these are sorry'd tombstones, not "derivable under reflexive Until semantics"
2. Fix `Axioms.lean:43` density axiom comment — either remove or restate as "was derivable under old reflexive G semantics; not applicable to current serial_future (BX1)"

**Priority 2 (staleness)**:
3. Remove the stale TODO at `Theories/Bimodal/typst/chapters/06-notes.typ:99` (task 83 is long completed)
4. Update transfer.lean task references: note tasks 155 and 268 are abandoned, and revise "correct path is task 155" language
5. Remove or note "Research-016" is a legacy pre-system reference in DenseSoundness.lean and DiscreteSoundness.lean

**Priority 3 (sorry documentation)**:
6. Add a WHY explanation to `InteriorOperators.lean:83` sorry (`temp_k_dist derivable from BX` — expand on what's actually blocking it)
7. Audit `OrderedSum.lean:56` sorry context for missing explanation

**Deprioritize**:
- Empty Boneyard directories: per-convention and documented in README.md
- NOTE removal comments: historically useful, not misleading
- BoneyardArchive coupling: non-default build target, low risk

---

## Evidence Summary

| Issue | File | Lines | Type |
|-------|------|-------|------|
| Misleading reflexive Until/Since section heading | `Bundle/SuccRelation.lean` | 596-634 | Semantically misleading |
| Density axiom comment (BX1 = serial, not reflexive G) | `ProofSystem/Axioms.lean` | 43 | Semantically misleading |
| Stale TODO (task 83, long completed) | `typst/chapters/06-notes.typ` | 99 | Stale TODO |
| References to abandoned tasks 155/268 as active | `WeakCanonical/Transfer.lean` | 1261,1277,1296 | Stale task ref |
| References to abandoned tasks at sorry sites | `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 219,375 | Stale task ref |
| `Research-016` orphaned reference | `DenseSoundness.lean:27`, `DiscreteSoundness.lean:26` | - | Orphaned ref |
| Terse sorry explanation | `Algebraic/InteriorOperators.lean` | 83 | Underdocumented sorry |
| BoneyardArchive files without `#exit` | `Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` | 1-5 | Missing guard |

---

## Confidence Level

**High** for items 1, 2, 3, 6, 7 (directly verified against source).
**High** for items 4, 5 (task status verified in state.json: tasks 155 and 268 both `[abandoned]`).
**Medium** for item 8 (OrderedSum.lean sorry context not fully read).
