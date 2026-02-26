# Strategies Section Audit - Teammate A Findings

**Task**: 934 - Audit ROAD_MAP.md Strategies Section
**Date**: 2026-02-26
**Auditor**: Teammate A (Primary Research)

## Summary

The Strategies section of `specs/ROAD_MAP.md` (lines 127-249) contains four strategies.
The most significant inaccuracy is in the **Indexed MCS Family Approach**, which describes
the semantics and coherence conditions as irreflexive (strict `<`) when the code has been
reflexive (`≤`) since Task #658. The **CoherentConstruction Two-Chain Design** description
also has inaccuracies: the referenced file does not exist at the stated path; it is archived
in the Boneyard. The other two strategies (**Representation-First Architecture** and
**Algebraic Verification Path**) are broadly accurate but have file path issues.

---

## Strategy-by-Strategy Analysis

### Strategy: Indexed MCS Family Approach

**Claimed** (lines 174-195):
> "TM's G/H operators are irreflexive (strictly future/past, excluding present)"
> "These conditions match the irreflexive semantics without requiring T-axioms"
> "Using a family of MCS indexed by time (mcs : D -> Set Formula) with temporal coherence
> conditions matches irreflexive G/H semantics without requiring T-axioms"
> References: `IndexedMCSFamily.lean`, `CanonicalHistory.lean`, `TruthLemma.lean` in
> `Theories/Bimodal/Metalogic/Representation/`

**Actual**:

1. **Semantics are REFLEXIVE, not irreflexive.** The `Truth.lean` file is explicit:
   - Module header (line 10): "temporal operators G (all_future) and H (all_past) use
     REFLEXIVE semantics (≤ instead of <), meaning 'now and future/past' rather than
     'strictly future/past'. This change enables coherence proofs via T-axioms."
   - Definitions (lines 118-119): `all_past` uses `s ≤ t`, `all_future` uses `t ≤ s`
   - Comments confirm: "Past: ∀ (s : D), s ≤ t → ...", "Future: ∀ (s : D), t ≤ s → ..."

2. **T-axioms ARE required.** The switch from irreflexive to reflexive semantics was
   explicitly made to enable T-axiom proofs. From `SoundnessLemmas.lean` (lines 712-728):
   "With reflexive semantics (Task #658), `all_future` quantifies over `t <= s`...
   The T-axiom `Gφ -> φ` is therefore trivially [valid via le_refl]."
   From `FMCSDef.lean` (line 23): "TM logic uses REFLEXIVE temporal operators with T-axioms
   (`G phi -> phi`, `H phi -> phi`) to enable coherence proofs."

3. **Coherence conditions use `≤` not `<`.** From `FMCSDef.lean` (lines 91, 98):
   - `forward_G`: `t ≤ t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'`
   - `backward_H`: `t' ≤ t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'`
   These use `≤` (reflexive/non-strict inequalities), not `<` (strict inequalities).

4. **The `IndexedMCSFamily` structure is ARCHIVED.** The referenced files
   `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`,
   `CanonicalHistory.lean`, and `TruthLemma.lean` do NOT exist at those paths.
   They were archived to `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/`
   (per `Theories/Bimodal/Metalogic/Representation/README.md`, archived on 2026-02-02,
   Task 809). The `Theories/Bimodal/Metalogic/Representation/` directory contains
   only a `README.md` explaining the archival.

   Notably, the Boneyard `IndexedMCSFamily.lean` itself describes this history
   accurately (lines 18-20): "Originally, TM logic used irreflexive temporal operators...
   As of Task #658, we switched to REFLEXIVE temporal operators with T-axioms."
   The coherence conditions there DO use strict `<` (lines 95, 102, 109, 116), but that
   is the old archived version, not the current `FMCS` structure in `Bundle/FMCSDef.lean`.

5. **The current active implementation** is the BFMCS approach in
   `Theories/Bimodal/Metalogic/Bundle/`, using `FMCS` (not `IndexedMCSFamily`).

**Inaccurate?**: YES - multiple significant errors

**Evidence**:
- `Theories/Bimodal/Semantics/Truth.lean` lines 10-11, 118-119: Reflexive semantics with `≤`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` lines 22-23, 91, 98: Reflexive `≤` coherence, T-axioms required
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` lines 712-728: T-axioms valid via reflexivity
- `Theories/Bimodal/Metalogic/Representation/README.md` lines 1-3: "Status: ARCHIVED to Boneyard/Metalogic_v5/ (Task 809, 2026-02-02)"
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/IndexedMCSFamily.lean` lines 69-77: Strict `<` conditions (ARCHIVED code)

---

### Strategy: CoherentConstruction Two-Chain Design

**Claimed** (lines 198-221):
> Status: ACTIVE
> "A two-chain design (forward chain for times > 0, backward chain for times < 0) from a
> central origin simplifies coherence proofs by making coherence conditions definitional."
> References: `CoherentConstruction.lean` at `Theories/Bimodal/Metalogic/Representation/`
> "Cross-origin coherence: Cases 2,3 have documented gaps, but only Cases 1,4 needed
> for completeness"

**Actual**:

1. **The referenced file does not exist at the stated path.** The file
   `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` does not exist.
   The Representation/ directory was archived to Boneyard (see above). The two-chain
   CoherentConstruction is in `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean`.

2. **The two-chain design description is broadly accurate** as a description of the
   ARCHIVED boneyard implementation. The archived `CoherentConstruction.lean` (lines 380-434)
   does implement:
   - Forward chain: `mcs_forward_chain` for times ≥ 0
   - Backward chain: `mcs_backward_chain` for times < 0
   - Unified function combining both

3. **The "Cases 2,3 gap" description partially applies to the boneyard version.** The
   archived `CoherentConstruction.lean` (lines 49-65) documents cases (forward_G Case 3,
   backward_H Cases 1-2, forward_H Cases 1-3, backward_G Cases 3-4) as sorry. However,
   the case numbering differs: the roadmap says "Cases 2,3" but the boneyard file shows
   the sorry patterns under a different case numbering.

4. **The ACTIVE current approach** is not CoherentConstruction but the BFMCS Bundle approach
   using `DovetailingChain.lean` for temporal coherence. The Dovetailing approach replaced
   the two-chain design. From `DovetailingChain.lean` (lines 59-70): this replaces the
   AXIOM `temporal_coherent_family_exists` with a theorem (with remaining sorry debt of 2).

5. **Status should be CONCLUDED/ARCHIVED, not ACTIVE.** The CoherentConstruction two-chain
   approach was archived along with the entire `Representation/` module (Task 809, 2026-02-02).
   The current ACTIVE approach is the BFMCS Bundle with `DovetailingChain`.

**Inaccurate?**: YES - file path is wrong, status is wrong (ACTIVE but archived), current approach is different

**Evidence**:
- `Theories/Bimodal/Metalogic/Representation/README.md` lines 1-3, 28-31: Archived includes CoherentConstruction.lean
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean` lines 380-434: Two-chain construction (ARCHIVED)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` lines 1-78: Current active replacement

---

### Strategy: Representation-First Architecture

**Claimed** (lines 150-171):
> Status: CONCLUDED
> Hypothesis: placing canonical model construction as foundation provides cleaner structure
> References: `Bimodal/Metalogic/Representation/` (Core implementation),
> `Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` (Main theorem)
> Outcomes: "Representation theorem proven sorry-free (Task 654)", weak/finite strong/
> infinitary completeness proven, compactness proven.

**Actual**:

1. **The reference paths are outdated/wrong.** `Bimodal/Metalogic/Representation/` is now
   only a README file (archived on 2026-02-02, Task 809). `UniversalCanonicalModel.lean`
   does not exist at the stated path; it was archived to Boneyard.
   The CURRENT `Representation.lean` (at `Theories/Bimodal/Metalogic/Representation.lean`)
   is a different file implementing "Standard Representation and Completeness via BFMCS"
   and is the actual entry point.

2. **The claimed outcomes are partially inaccurate.** The Representation/README.md states
   the approach had 30 sorries and was NOT sorry-free. The "sorry-free representation
   theorem" claim in the outcomes requires clarification: the current sorry-free result
   is via the FMP approach (`FMP/SemanticCanonicalModel.lean`), not via the archived
   Representation approach.

3. **The CONCLUDED status is appropriate** - this approach was explicitly superseded.

4. **The architecture description** (completeness as corollary of representation) is
   accurate for both the archived and current approaches.

**Inaccurate?**: Partially - reference paths are wrong; "sorry-free" outcome claim
is misleading (the Representation approach had 30 sorries; sorry-free completeness
came from FMP).

**Evidence**:
- `Theories/Bimodal/Metalogic/Representation/README.md` lines 1-16: Archived, 30 sorries
- `Theories/Bimodal/Metalogic/Representation.lean` lines 16-30: Current BFMCS-based representation file
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`: Current sorry-free approach

---

### Strategy: Algebraic Verification Path

**Claimed** (lines 224-248):
> Status: PAUSED
> "Boolean algebra with modal operators provides alternative verification path via Stone duality"
> References: `Algebraic/` module at `Theories/Bimodal/Metalogic/Algebraic/`
> Outcomes: Quotient algebra defined, Boolean structure proven, Interior operators and
> ultrafilter correspondence partially implemented.

**Actual**:

1. **The file path is correct.** `Theories/Bimodal/Metalogic/Algebraic/` exists and
   contains: `LindenbaumQuotient.lean`, `BooleanStructure.lean`, `InteriorOperators.lean`,
   `UltrafilterMCS.lean`, `AlgebraicRepresentation.lean`.

2. **The description is broadly accurate.** The `Algebraic.lean` module doc (lines 28-61)
   confirms: quotient via provable equivalence, Boolean algebra structure, interior operators
   G/H (using T-axioms explicitly - confirming the reflexive semantics observation above),
   ultrafilter-MCS correspondence, representation theorem.

3. **The "interior operators using T-axioms" detail is notable.** `Algebraic.lean` line 35:
   "Interior Operators: Show G and H are interior operators using reflexive semantics:
   Deflationary: G[φ] ≤ [φ] (from T-axiom Gφ → φ)". This further confirms the T-axiom
   dependency that the Indexed MCS Family strategy denies.

4. **The PAUSED status and "partially implemented" claim** appear consistent with the code
   structure (all submodules exist but the main AlgebraicRepresentation.lean is partial).

**Inaccurate?**: No major inaccuracies. Status and description appear accurate.

**Evidence**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` lines 15-61: Module structure confirmed
- All referenced subfiles exist at their stated paths

---

## Recommended Corrections

### Correction 1: Indexed MCS Family Approach - Semantics Description

**Lines 178-183 of ROAD_MAP.md** - Replace:

> "TM's G/H operators are irreflexive (strictly future/past, excluding present). A family-based approach naturally captures this structure, with each time point having its own MCS connected via temporal coherence conditions."
> "These conditions match the irreflexive semantics without requiring T-axioms."

With:

> "TM's G/H operators use REFLEXIVE semantics (present + future/past, inclusive). A family-based approach captures this structure, with each time point having its own MCS connected via temporal coherence conditions (using ≤, not <)."
> "These conditions match the reflexive semantics; T-axioms (Gφ → φ, Hφ → φ) are valid and used in coherence proofs."

### Correction 2: Indexed MCS Family Approach - References

**Lines 192-195** - Replace references pointing to `Theories/Bimodal/Metalogic/Representation/`:

> - [IndexedMCSFamily.lean](Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean)
> - [CanonicalHistory.lean](Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean)
> - [TruthLemma.lean](Theories/Bimodal/Metalogic/Representation/TruthLemma.lean)

With current paths:

> - [FMCSDef.lean](Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean) - Current FMCS structure (reflexive `≤` coherence)
> - [TruthLemma.lean](Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean) - Current truth lemma
> - [Boneyard/IndexedMCSFamily.lean](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/IndexedMCSFamily.lean) - Archived original (strict `<`)

### Correction 3: CoherentConstruction Two-Chain Design - Status and References

**Line 200** - Change status from `ACTIVE` to `CONCLUDED` or `SUPERSEDED`.

**Lines 217-220** - Replace references:

> - [CoherentConstruction.lean](Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean)

With:

> - [Boneyard/CoherentConstruction.lean](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean) - Archived two-chain implementation
> - [DovetailingChain.lean](Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean) - Current replacement (dovetailing approach)

### Correction 4: Representation-First Architecture - References

**Line 170** - Replace:

> - [Bundle/Representation.lean](Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean)

With:

> - [Representation.lean](Theories/Bimodal/Metalogic/Representation.lean) - Current BFMCS-based entry point
> - [Boneyard archive](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/) - Archived original files

### Correction 5: Representation-First Architecture - Outcomes

**Lines 162-165** - Clarify the sorry-free outcome claim. The original Representation approach had 30 sorries. The sorry-free completeness is via FMP, not the archived representation approach. Either add a note about this or adjust the "sorry-free" claim to refer to the current BFMCS path.

---

## Confidence Level

**High** for the following findings:
- G/H semantics are reflexive (≤), not irreflexive (<): directly readable in `Truth.lean` lines 118-119
- T-axioms ARE required (not "without requiring T-axioms"): `FMCSDef.lean` line 23, `SoundnessLemmas.lean` lines 712-728
- `Representation/` directory is archived: `Representation/README.md` is definitive
- CoherentConstruction.lean does not exist at the stated path: filesystem check confirms

**Medium** for:
- Whether the Algebraic module is truly "PAUSED" vs partially complete (status depends on non-code context)
- The exact "sorry-free" history of the Representation-First approach (requires deeper archive reading)
