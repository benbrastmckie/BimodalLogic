# Task 1009: CanonicalMCS Role Audit

## Executive Summary

CanonicalMCS is the **world-state space** (the set of all maximal consistent sets with a CanonicalR-based Preorder). It serves as the type parameter `D` in `FMCS D`, but when used this way, `D` is the **indexing domain** of the family -- NOT the temporal domain `D` in `TaskFrame D`.

The `TaskFrame D` temporal domain requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. CanonicalMCS has only `[Preorder CanonicalMCS]` (a non-linear, non-total preorder). These are fundamentally incompatible.

**The confusion**: In `FMCS D`, the type parameter `D` is called the "time" or "duration" parameter in comments, and when `D = CanonicalMCS`, this makes it sound like CanonicalMCS is a time domain. It is not. When `D = CanonicalMCS` in `FMCS CanonicalMCS`, each "index" is a world state (an MCS), not a time point.

**The correct semantic mapping**:
- `TaskFrame.WorldState` = the space of MCSes (i.e., CanonicalMCS elements)
- `TaskFrame D` temporal domain = Int, Rat, TimelineQuot, etc. (types with ordered group structure)
- `FMCS D` with `D = CanonicalMCS` = family indexed by world states, where `mcs(w) = w.world`

## Correct Roles (Reference)

| Concept | Type | Role | Required Typeclasses |
|---------|------|------|---------------------|
| `TaskFrame D` parameter | `D` | Temporal duration type | `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` |
| `TaskFrame.WorldState` | field | World state space | None (bare `Type`) |
| `FMCS D` parameter | `D` | Indexing domain | `Preorder` |
| `CanonicalMCS` | type | All maximal consistent sets | Has `Preorder` only |
| `FMCS CanonicalMCS` | instance | Family indexed by world states | Works because Preorder suffices |
| `TimelineQuot` | type | Dense temporal domain | Has `LinearOrder`, `DenselyOrdered` |
| `Int` | type | Discrete temporal domain | Has `AddCommGroup`, `LinearOrder`, etc. |

## Findings: Files Requiring Updates

### Category 1: Lean File Comments/Docstrings (Active Code)

#### 1.1 CanonicalFMCS.lean (Critical -- Most Confusing)

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

- **Line 19**: `- The domain is CanonicalMCS (all maximal consistent sets, with CanonicalR Preorder)`
  - Uses "domain" ambiguously. Should clarify this is the FMCS indexing domain (world-state space), not a temporal domain.

- **Line 70**: `A maximal consistent set, used as a domain element for the canonical FMCS.`
  - "domain element" is ambiguous. Should say "indexing element" or "world-state index".

- **Line 177**: `The canonical FMCS on all MCSes: a family of MCS indexed by CanonicalMCS.`
  - This is actually fine -- "indexed by" is correct. But should add clarification that this is NOT a temporal index.

- **Line 280**: `Given a consistent context Gamma, there exists a FMCS CanonicalMCS and a root element`
  - Should clarify that `FMCS CanonicalMCS` means "family indexed by world states" and that CanonicalMCS is not the temporal domain D of TaskFrame.

- **Line 286**: `This eliminates the temporal_coherent_family_exists sorry for D = CanonicalMCS.`
  - `D = CanonicalMCS` suggests CanonicalMCS plays the role of the temporal domain D. Should say "for the FMCS indexing type = CanonicalMCS" or similar.

#### 1.2 FMCSDef.lean (Systemic -- Parameter Name)

**File**: `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`

- **Lines 9-10, 20, 28, 63**: The module docstring consistently calls `D` the "time type", "time point", "time-indexed". For `FMCS CanonicalMCS`, this framing is misleading because CanonicalMCS elements are world states, not time points.
  - Line 9: `assigns a maximal consistent set (MCS) to each time point in D`
  - Line 20: `Build a family of MCS indexed by time`
  - Line 28: `FMCS D: Structure pairing each time t : D with an MCS`
  - Line 63: `D: Duration/time type with preorder structure`
  - **Recommendation**: Add a note that when `D = CanonicalMCS`, the indexing is by world state, not time. The "time" terminology applies when D has temporal algebraic structure.

#### 1.3 DenseCompleteness.lean

**File**: `Theories/Bimodal/Metalogic/DenseCompleteness.lean`

- **Line 39**: `- **CanonicalMCS domain**: Used by BFMCS and truth lemma (all MCSs as times)`
  - "(all MCSs as times)" is the core confusion. MCSes are world states, not times. Should say "(all MCSes as world-state indices)".

- **Line 43**: `The gap is that the truth lemma is proven for D = Int (or CanonicalMCS)`
  - Parenthetical "(or CanonicalMCS)" conflates the two: Int is a temporal domain, CanonicalMCS is a world-state index. They serve different architectural roles.

- **Line 59**: `Blocker 3: CanonicalMCS has Preorder but NOT AddCommGroup/LinearOrder.`
  - This is actually CORRECTLY identifying the issue. Should be kept and potentially expanded as a key clarification.

- **Line 116**: Comment in Completeness section: `1. The BFMCS uses D = CanonicalMCS (the all-MCS domain)`
  - "domain" ambiguous. Should say "the all-MCS indexing type".

- **Line 138**: `The final wiring is blocked by the CanonicalMCS/TimelineQuot domain mismatch.`
  - Should clarify: CanonicalMCS indexes world states; TimelineQuot indexes time points. The "mismatch" is that these are categorically different things, not two competing temporal domains.

#### 1.4 StagedConstruction/Completeness.lean

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`

- **Line 116**: `1. The BFMCS uses D = CanonicalMCS (the all-MCS domain)`
  - Same issue as DenseCompleteness.lean. "domain" is ambiguous.

#### 1.5 StagedConstruction/ClosureSaturation.lean

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`

- **Line 202**: `4. CanonicalMCS provides the MODAL (history) domain`
  - "domain" is somewhat ambiguous, but "MODAL (history) domain" is actually more correct than "temporal domain". Consider clarifying as "world-state space".

- **Line 754**: `3. TimelineQuot provides the time domain; CanonicalMCS provides modal structure`
  - This is CORRECT and is actually a good example of the right distinction. Keep as-is or strengthen.

#### 1.6 Algebraic/MultiFamilyBFMCS.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

- **Line 69**: `we build a single BFMCS over CanonicalMCS where the domain is ALL canonical MCS.`
  - "domain" ambiguous.

- **Line 83**: `The CanonicalMCS domain already provides:`
  - "domain" ambiguous.

- **Line 94**: `This is the FMCS where each time point is a CanonicalMCS element`
  - "time point" is wrong. Each INDEX is a CanonicalMCS element (a world state).

- **Line 313**: `(1) Use a common domain (CanonicalMCS) with Flag membership predicates`
  - "domain" ambiguous.

- **Line 384**: `When all families in the BFMCS share the SAME domain (CanonicalMCS)`
  - "domain" ambiguous.

- **Line 387**: `For any time t : CanonicalMCS, ALL families assign the SAME MCS (t.world)`
  - "time t : CanonicalMCS" is the core confusion. `t` is a world-state index, not a time.

#### 1.7 Algebraic/AlgebraicBaseCompleteness.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`

- **Line 38**: `theorem directly using the CanonicalMCS infrastructure indexed by CanonicalMCS itself.`
  - Correct but should clarify the "indexed by CanonicalMCS" means "indexed by world states".

- **Line 41**: `CanonicalMCS does NOT have AddCommGroup, so we cannot directly use it as D.`
  - This is CORRECTLY identifying the issue. "as D" here means "as the temporal domain D of TaskFrame". Keep and potentially cite as a canonical statement of the distinction.

- **Line 76**: `Since CanonicalMCS has only Preorder (not AddCommGroup), this BFMCS cannot directly serve as the D parameter for TaskFrame.`
  - Correctly identifies the distinction. Good reference.

#### 1.8 Bundle/SaturatedBFMCSConstruction.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean`

- **Line 202**: `1. Use a Sigma type domain: Sigma (flag : Flag CanonicalMCS), ChainFMCSDomain flag`
  - "domain" used for the FMCS indexing type, which is fine in context.

- **Line 227**: `1. Construct a BFMCS over CanonicalMCS (or a suitable domain) that is modally saturated`
  - "domain" ambiguous.

#### 1.9 Algebraic/SeparatedTaskFrame.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean`

- **Line 6**: `# Separated TaskFrame: D = TimelineQuot, W = CanonicalMCS`
  - This is EXACTLY RIGHT. The title correctly separates D (time) from W (world states). This file is a model for the correct distinction.

#### 1.10 Bundle/WitnessFamilyBundle.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean`

- **Line 153**: `All families share the same domain (CanonicalMCS)`
  - "domain" used for the FMCS indexing type.

#### 1.11 Bundle/FMCSTransfer.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

- **Line 11**: `from CanonicalMCS to any target domain D via an embedding/retraction pair.`
  - "target domain D" is the FMCS indexing domain. In context this is clear because FMCSTransfer is about changing the index type.

- **Line 61**: `FMCSTransfer: An embedding/retraction pair from CanonicalMCS to a target domain D.`
  - Same as above.

- **Line 327**: `Main FMCS domain transfer theorem`
  - "FMCS domain" means indexing domain. OK in context.

#### 1.12 Bundle/ChainFMCS.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`

- **Line 24**: `BFMCS (chain-based, embedding-based, or direct CanonicalMCS-based).`
  - Fine.

- **Line 532**: `The domain of a chain-based FMCS is { w : CanonicalMCS // w in flag }`
  - "domain" used for FMCS indexing type.

#### 1.13 Algebraic/IntBFMCS.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

- **Lines 1239-1251**: Comment block "Alternative: Use CanonicalMCS-based Construction"
  - Discusses using CanonicalMCS-indexed FMCS and pulling back along an embedding. The architectural reasoning is sound but would benefit from clarifying that CanonicalMCS is the world-state space, not a temporal domain.

#### 1.14 Algebraic/CanonicalEmbedding.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`

- **Line 30**: `CanonicalMCS has Preorder not LinearOrder`
  - Correctly identifies the typeclass gap.

#### 1.15 LogicVariants.lean

**File**: `Theories/Bimodal/LogicVariants.lean`

- **Lines 142-153**: Re-export of `dense_components_export` uses `FMCS CanonicalMCS` in its type signature without any comment explaining the semantic role. The variable names `t : CanonicalMCS` and `s : CanonicalMCS` suggest temporal variables.

### Category 2: Markdown Documentation (Active)

#### 2.1 ROAD_MAP.md

**File**: `specs/ROAD_MAP.md`

- **Line 170**: `Phase 0 | Canonical Timeline Definition | COMPLETED | CanonicalMCS.lean`
  - "Canonical Timeline" is misleading for CanonicalMCS. CanonicalMCS is the world-state space. The canonical TIMELINE is TimelineQuot. However, this refers to the file name which may have been renamed. Check if the file is now CanonicalFMCS.lean.

- **Line 175**: `Phase 5 | CanonicalMCS BFMCS | COMPLETED`
  - Correct usage.

- **Line 180**: `The gap is connecting the CanonicalMCS-based BFMCS (which has the proven truth lemma) to the TimelineQuot-based TaskFrame`
  - Should clarify: "CanonicalMCS-based BFMCS" means "BFMCS indexed by world states"; "TimelineQuot-based TaskFrame" means "TaskFrame with temporal domain TimelineQuot".

- **Line 182**: `the BFMCS uses D = CanonicalMCS while the TaskFrame semantics uses D = TimelineQuot.`
  - This is the CENTRAL CONFLATION. The `D` in `BFMCS D` (= FMCS indexing type) is NOT the same `D` as in `TaskFrame D` (= temporal domain). Using the same letter `D` for both creates the confusion. Should say: "the BFMCS is indexed by CanonicalMCS (world states), while the TaskFrame's temporal domain is TimelineQuot".

- **Line 209**: `The BFMCS infrastructure uses D = CanonicalMCS (the all-MCS domain), while the TaskFrame/semantics uses D = TimelineQuot (the Cantor domain).`
  - Same conflation. The two `D`s are different type parameters with different requirements.

- **Line 215**: `The domain mismatch (CanonicalMCS vs TimelineQuot) becomes a wiring problem`
  - "domain mismatch" makes it sound like both are competing for the same role. Should say "the type parameter mismatch" or "the indexing domain vs temporal domain gap".

- **Line 957**: `the witness MCS exists as a CanonicalMCS element but is NOT automatically placed at time t in canonicalMCSBFMCS`
  - "at time t" when t : CanonicalMCS is a world-state index. Should say "at index t".

- **Line 1131**: `Superseded By: CanonicalFMCS (domain = all CanonicalMCSes; F/P witnesses trivially available at their own position)`
  - "domain" ambiguous but contextually OK.

- **Line 1258**: `CanonicalFMCS.lean # D=CanonicalMCS families (SORRY-FREE)`
  - "D=CanonicalMCS" reinforces the conflation with TaskFrame's D.

#### 2.2 Bundle/README.md

**File**: `Theories/Bimodal/Metalogic/Bundle/README.md`

- No direct CanonicalMCS confusion found in the first 50 lines read. The README focuses on the BFMCS approach generally.

### Category 3: Boneyard (Low Priority)

Files in `Boneyard/` and `Theories/Bimodal/Boneyard/` contain many references to CanonicalMCS. Since Boneyard is archived/deprecated code, updating these is LOW priority. They should be noted but not changed unless someone is working in those files.

Key Boneyard files with CanonicalMCS references:
- `Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/*.lean` (many files)
- `Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/*.lean`
- `Theories/Bimodal/Boneyard/Task956_IntRat/*.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean`

### Category 4: Spec Reports (Low Priority)

Spec reports (specs/1006_*, specs/1008_*, specs/988_*, etc.) contain extensive CanonicalMCS discussion. These are historical research artifacts and generally should not be updated retroactively. However, the persistent confusion in these reports is what drives the need for task 1009.

## Root Cause Analysis

The confusion stems from two sources:

### Source 1: Overloaded type parameter name `D`

`FMCS D` uses `D` as its type parameter with `[Preorder D]`. `TaskFrame D` also uses `D` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. When reading `FMCS CanonicalMCS`, researchers substitute "CanonicalMCS" for "D" and then incorrectly assume this is the same "D" as in TaskFrame.

**Fix**: Add a prominent note in FMCSDef.lean distinguishing the two uses of D, and consider using different parameter names in documentation (e.g., "I" for index, "D" for temporal domain).

### Source 2: FMCSDef.lean's "time" language

FMCSDef.lean consistently refers to the parameter as "time" and "duration":
- "time-indexed family"
- "each time point"
- "Duration/time type"

This is correct when D = Int or D = Rat or D = TimelineQuot. It is INCORRECT when D = CanonicalMCS. The FMCSDef module predates the CanonicalFMCS construction and was written assuming D would always be a temporal type.

**Fix**: Add qualification: "When D is a temporal type (Int, Rat, TimelineQuot), elements are time points. When D = CanonicalMCS, elements are world-state indices."

## Recommended Changes (Summary)

### High Priority (Active confusion sources)

| File | Lines | Current Text | Issue |
|------|-------|-------------|-------|
| FMCSDef.lean | 9, 20, 28, 63 | "time point", "time-indexed", "Duration/time type" | Add note about D = CanonicalMCS case |
| CanonicalFMCS.lean | 19, 70, 286 | "domain" used ambiguously | Clarify as "FMCS indexing domain (world-state space)" |
| DenseCompleteness.lean | 39 | "all MCSs as times" | Change to "all MCSes as world-state indices" |
| MultiFamilyBFMCS.lean | 94, 387 | "time point is a CanonicalMCS element", "time t : CanonicalMCS" | Change "time" to "index" |
| ROAD_MAP.md | 182, 209, 215 | "D = CanonicalMCS" alongside "D = TimelineQuot" | Clarify these are different type parameters |
| StagedConstruction/Completeness.lean | 116 | "D = CanonicalMCS (the all-MCS domain)" | Clarify as FMCS indexing type, not temporal domain |

### Medium Priority (Ambiguous but not actively misleading)

| File | Lines | Issue |
|------|-------|-------|
| CanonicalFMCS.lean | 177, 280 | "indexed by" is correct but could add temporal/world-state distinction |
| SaturatedBFMCSConstruction.lean | 202, 227 | "domain" used for FMCS indexing type |
| WitnessFamilyBundle.lean | 153 | "domain" used for FMCS indexing type |
| ChainFMCS.lean | 532 | "domain" used for FMCS indexing type |
| LogicVariants.lean | 142-153 | Variable names `t, s : CanonicalMCS` suggest temporal |

### Low Priority (Boneyard, archived specs)

- Boneyard files: Do not update unless working in those files
- Archived spec reports: Do not retroactively update

## Model Clarification Statement

For use in updated comments/docstrings:

> **Semantic Role Clarification**: `CanonicalMCS` is the **world-state space** -- the type of all maximal consistent sets equipped with a CanonicalR-based Preorder. When used as the type parameter in `FMCS CanonicalMCS`, it serves as an **indexing domain** where each index is a world state, NOT a time point. The temporal domain `D` in `TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, which CanonicalMCS does not and cannot have. The correct architectural mapping is: `TaskFrame.WorldState` corresponds to CanonicalMCS elements; the TaskFrame temporal parameter `D` corresponds to Int, Rat, TimelineQuot, or similar algebraically structured types.

## Files Confirmed as Correct

The following files already use the correct distinction:

- **SeparatedTaskFrame.lean** (line 6): `D = TimelineQuot, W = CanonicalMCS` -- perfect separation
- **ClosureSaturation.lean** (line 754): `TimelineQuot provides the time domain; CanonicalMCS provides modal structure` -- correct
- **AlgebraicBaseCompleteness.lean** (line 41): `CanonicalMCS does NOT have AddCommGroup, so we cannot directly use it as D` -- correctly identifies the issue
- **CanonicalConstruction.lean** (lines 47-49): `WorldState and D are fundamentally different types` -- excellent documentation of the distinction
