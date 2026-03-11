# Research Report: Temporal T-Axiom vs Seriality Axiom for Phase 5 Blocker

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1741536400_r956logic
**Run**: 024
**Effort**: Medium
**Dependencies**: None (decision point, not implementation)
**Sources/Inputs**: Codebase (Axioms.lean, Truth.lean, Soundness.lean, CanonicalCompleteness.lean, RestrictedFragment.lean), SEP Temporal Logic, Goldblatt 1992, Wikipedia Modal Logic
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- Option 1 (re-add T-axioms with reflexive semantics) is **unsound** for the current irreflexive semantics and would require reverting a deliberate architectural decision
- Option 2 (add seriality axioms `F(neg bot)` / `P(neg bot)`) is **sound, standard, and minimal**; it is the temporal analog of the modal D-axiom
- **Recommendation: Option 2** -- add seriality axioms while keeping irreflexive semantics
- The current codebase is already broken: `temp_t_future`/`temp_t_past` constructors were removed from `Axioms.lean` but ~30 downstream references remain, causing compilation failures
- Option 2 requires less effort AND preserves the density proof architecture that motivated the irreflexive switch

## Context & Scope

### The Phase 5 Blocker

The implementation of the K-Relational pipeline (research-023) requires proving `NoMaxOrder` and `NoMinOrder` for `RestrictedQuotient`. The proof strategy in `RestrictedFragment.lean` (lines 417-434) relies on `mcs_has_F_top` and `mcs_has_P_top` from `CanonicalCompleteness.lean`.

These lemmas prove `F(neg bot) in M` and `P(neg bot) in M` for any MCS M. The proof chain is:
1. `G(bot) -> bot` by T-axiom (`temp_t_future`)
2. Contrapositive: `neg bot -> neg(G(bot))`
3. `neg bot in M` (it is a theorem)
4. Therefore `neg(G(bot)) in M`, i.e., `F(neg bot) in M`

**The problem**: `temp_t_future` and `temp_t_past` have been removed from `Axiom` inductive type in `Axioms.lean`, breaking this chain. The removal was motivated by the switch to irreflexive semantics (Truth.lean header, lines 10-11).

### Current State of the Codebase

**Axioms.lean**: 18 constructors, none named `temp_t_future` or `temp_t_past`

**Downstream breakage**: At least 30 references to `Axiom.temp_t_future` and `Axiom.temp_t_past` across:
- `CanonicalCompleteness.lean` (6 references: lines 186, 216, 629, 653)
- `DovetailingChain.lean` (~20 references: lines 264, 274, 428, 531, 885, 914, 951, 988, 1062, 1101, 1333, 1363, 1417, 1431, 1815, 1833)
- `ChainFMCS.lean` (1 reference: line 194)
- `InteriorOperators.lean` (4 references: lines 67, 98, 123, 150)

**Build verification**: `lake build Bimodal.Metalogic.Bundle.CanonicalCompleteness` fails with:
```
Unknown constant `Bimodal.ProofSystem.Axiom.temp_t_future`
Unknown constant `Bimodal.ProofSystem.Axiom.temp_t_past`
```

## Findings

### Option 1: Re-add Temporal T-Axioms with Reflexive Semantics

**Proposed change**: Add axioms `G(phi) -> phi` and `H(phi) -> phi`, change `truth_at` to use `<=`/`>=`.

#### 1. Soundness

**UNSOUND for current irreflexive semantics.** With strict `<`, `G(phi)` means "phi at all strictly future times." At a maximal time point (one with no strict successors), `G(bot)` is vacuously true, but `bot` is false. So `G(bot) -> bot` fails.

To make these axioms sound, the semantics MUST be changed to reflexive (`<=`/`>=`). With `G(phi)` meaning "phi at all times >= now," `G(phi) -> phi` is trivially valid (take s = t in the universal quantifier).

#### 2. Completeness Impact

Re-adding T-axioms with reflexive semantics would restore the original proof structure. The `mcs_has_F_top` and `mcs_has_P_top` lemmas would work as written. However, this reverses the deliberate decision to use irreflexive semantics.

#### 3. Codebase Changes Required

- **Truth.lean**: Change `s < t` to `s <= t` (line 118) and `t < s` to `t <= s` (line 119) -- 2 lines
- **Axioms.lean**: Re-add `temp_t_future` and `temp_t_past` constructors -- ~20 lines
- **Soundness.lean**: Add soundness proofs for new axioms, add cases in `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` -- ~60 lines
- **Axioms.lean classification**: Update `isDenseCompatible`, `isDiscreteCompatible`, `isBase` -- 6 lines
- **DenseQuotient.lean**: ALL density proofs would break. The entire density proof architecture was built for irreflexive `<`. With reflexive `<=`, the density axiom `F(phi) -> F(F(phi))` means something different and the intermediate-point argument changes fundamentally.
- **TimeShift proofs**: May need adjustment for `<=` vs `<`

**Estimated effort**: HIGH. The density proofs alone could require weeks of rework.

#### 4. Mathematical Tradition

In Prior's original tense logic (1967), G and H are interpreted over reflexive orderings. However, this is the MINORITY position in modern temporal logic. The Stanford Encyclopedia of Philosophy states: "the most common practice in temporal logic is to regard time as an irreflexive ordering, so that 'henceforth' does not refer to the present moment."

Goldblatt (1992) uses strict `<` throughout *Logics of Time and Computation*.

#### 5. Semantic Consequences

**Models ruled IN**: All frames including endpoint frames (single-point frames, frames with maximal/minimal elements).

**Models ruled OUT**: None additionally.

The reflexive interpretation makes G/H weaker (they say less, since they include the trivial case s = t). This means the logic proves fewer things about strict futures, requiring more explicit reasoning about strict ordering.

#### 6. Interaction with Other Axioms

- **Density (DN)**: `F(phi) -> F(F(phi))` with reflexive semantics becomes trivially true (take the same witness). The density axiom would need reformulation for reflexive semantics, likely requiring a completely different axiom.
- **Discreteness (DF)**: Similarly affected.
- **temp_4**: `G(phi) -> G(G(phi))` is redundant with reflexive semantics on transitive frames (it follows from T + transitivity of `<=`).
- **temp_a**: `phi -> G(P(phi))` changes meaning: with reflexive P, P(phi) at t includes phi at t, so G(P(phi)) is trivially implied by G(phi).

### Option 2: Add Seriality Axioms F(neg bot) / P(neg bot)

**Proposed change**: Add axioms stating every time has a strict successor and predecessor. Keep irreflexive `<`/`>` semantics unchanged.

#### 1. Soundness

**SOUND** for irreflexive semantics on any frame without endpoints.

- `F(neg bot)` means `exists s > t, not bot`, i.e., `exists s > t, True`, i.e., "there exists a strictly future time." This is exactly the seriality condition (no maximal elements).
- `P(neg bot)` means `exists s < t, True`, i.e., "there exists a strictly past time." This is the backward seriality condition (no minimal elements).

Both are valid on any linear order without endpoints, which is exactly the class of frames intended for the TM semantics (the temporal domain D is typically Q or Z, both without endpoints).

**Proof of soundness**: For any time t in a frame without maximal elements, there exists s > t. At s, `neg bot = bot -> bot` is true (trivially). So `F(neg bot)` holds at t. Symmetric argument for past.

#### 2. Completeness Impact

This directly provides the key lemma: `F(neg bot) in M` for any MCS M (it is an axiom instance, hence a theorem, hence in every MCS). The `mcs_has_F_top` proof simplifies dramatically:

```lean
lemma mcs_has_F_top (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) in M :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.seriality_future))
```

Similarly for `mcs_has_P_top`. No complex contraposition chains needed.

For the NoMaxOrder/NoMinOrder proofs in `RestrictedFragment.lean`, the argument is:
1. `F(neg bot) in M` (from seriality axiom)
2. By `forward_F_stays_in_restricted_fragment`, there exists a successor MCS in the fragment
3. The successor is strictly greater in the canonical ordering

The "strict separation argument" (noted in the sorry comments) still needs work, but the EXISTENCE of successors is immediate.

#### 3. Codebase Changes Required

**Minimal changes:**
- **Axioms.lean**: Add 2 constructors (~20 lines):
  ```lean
  | seriality_future : Axiom (Formula.some_future (Formula.neg Formula.bot))
  | seriality_past : Axiom (Formula.some_past (Formula.neg Formula.bot))
  ```
- **Axioms.lean classification**: Update `isDenseCompatible`, `isDiscreteCompatible`, `isBase` to include new axioms (6 lines)
- **Soundness.lean**: Add 2 soundness proofs + update 3 case splits (~30 lines). Soundness proof needs `NoMaxOrder D` and `NoMinOrder D` type class constraints on the temporal domain, or the proofs go into the frame-class-specific validators.
- **CanonicalCompleteness.lean**: Rewrite `mcs_has_F_top` and `mcs_has_P_top` (~10 lines, simpler than before)
- **All ~30 downstream references to `temp_t_future`/`temp_t_past`**: Must be rewritten to NOT use T-axioms. These are used for two purposes:
  - (A) Deriving `F(neg bot)` / `P(neg bot)` -- replaced by direct seriality axiom
  - (B) Proving `G(phi) -> phi` as a lemma for coherence arguments -- THIS IS THE HARD PART

**The critical question for Option 2**: Many of the ~30 downstream uses of `temp_t_future` are NOT just for `mcs_has_F_top`. They are used in DovetailingChain and other coherence proofs where the argument pattern is:

```lean
-- "G(phi) in M implies phi in M" (via temp_t_future)
have h_T := DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
```

This derives `G(phi) -> phi` as a theorem. Without the T-axiom, this is NOT derivable. The question is: do these proof sites actually NEED `G(phi) -> phi`, or can the arguments be restructured?

**Analysis of T-axiom usage patterns**:

Pattern 1 (in `mcs_has_F_top`/`mcs_has_P_top`): Uses T-axiom to get `G(bot)->bot`, then contraposes to get `F(top)`. **Replaced by seriality axiom.**

Pattern 2 (in `DovetailingChain` coherence proofs): Uses T-axiom to show `G(phi) in fam.mcs(t) -> phi in fam.mcs(t)`. This is critical for the reflexive case of forward_G coherence: at time t itself, `G(phi) in M(t)` should imply `phi in M(t)`.

**With irreflexive semantics, Pattern 2 is NOT needed for the truth lemma.** The truth lemma says: `G(phi) in fam.mcs(t)` iff `truth_at ... t (all_future phi)` iff `forall s > t, truth_at ... s phi`. The "current time" case (s = t) is not part of the irreflexive quantification. So `G(phi) in M(t)` does NOT need to imply `phi in M(t)` for the truth lemma.

However, the COHERENCE CONDITIONS in the FMCS definition may still use `<=` (reflexive). If so, the coherence condition `forward_G: G(phi) in M(t) and t <= t' -> phi in M(t')` at t = t' gives `G(phi) -> phi`, which requires the T-axiom.

**Resolution**: The FMCS coherence conditions should be changed to use strict `<` instead of `<=`, matching the irreflexive semantics. This is a DESIGN ALIGNMENT issue: the semantics uses `<`, so the coherence conditions should also use `<`.

**Estimated effort**: MEDIUM. The axiom addition is trivial. The downstream ~30 reference fixes require case analysis (which pattern?) and some may need coherence condition redesign.

#### 4. Mathematical Tradition

The seriality axiom is the temporal analog of the **D-axiom** in modal logic: `Box(phi) -> Diamond(phi)`, which corresponds to the frame condition that every world has an accessible successor (seriality).

In temporal logic specifically:
- `F(neg bot)` (equivalently, `G(phi) -> F(phi)` for all phi, equivalently `neg G(bot)`) states "there always exists a strict future."
- This is the STANDARD axiom for "no last moment" in irreflexive temporal logic (Goldblatt 1992, Blackburn et al. 2001).
- The logic Kt + seriality (both directions) is sound and complete for linear orders without endpoints.

This aligns with standard mathematical practice far better than Option 1.

#### 5. Semantic Consequences

**Models ruled OUT**: Frames with endpoints (maximal or minimal elements). This rules out finite linear orders (which have both a first and last point) and half-lines like the natural numbers (which have a first point).

**Models ruled IN**: All dense linear orders without endpoints (like Q, R) and all integer-like orders (like Z) are preserved.

This is exactly the intended model class for TM: the temporal domain D is required to be an ordered additive group (AddCommGroup + LinearOrder + IsOrderedAddMonoid), which automatically has no endpoints (for any t, t+1 > t and t-1 < t). So the seriality axioms are **automatically valid** on any D satisfying the existing type class constraints.

#### 6. Interaction with Other Axioms

- **Density (DN)**: No interaction. `F(phi) -> F(F(phi))` remains unchanged and sound.
- **Discreteness (DF)**: Compatible. DF already assumes `F(top)` as a hypothesis.
- **temp_4**: `G(phi) -> G(G(phi))` -- no change.
- **temp_a**: `phi -> G(P(phi))` -- no change.
- **Seriality + Density together**: `F(neg bot)` + DN gives `F(F(neg bot))`, meaning there are at least 2 distinct future times. More generally, seriality + density + transitivity ensures arbitrarily many future times, consistent with dense orders without endpoints.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Single-History FDSM | Low | Not relevant -- we're modifying axioms, not model construction |
| CanonicalReachable/CanonicalQuotient | Low | The seriality axiom helps NoMaxOrder/NoMinOrder but doesn't affect the countability issue that killed this approach |
| Constant Witness Family | Low | Not relevant |
| Single-Family BFMCS modal_backward | Low | Not relevant |
| Non-Standard Validity | Medium | Reinforces that we must use standard semantics; Option 2 preserves standard irreflexive semantics |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | The strategy notes it uses REFLEXIVE coherence conditions with T-axioms. Option 2 would require updating coherence to strict `<`. This is a significant but necessary alignment change. |
| Representation-First | CONCLUDED | No impact -- seriality axiom doesn't change the representation theorem architecture |

**Key observation**: The Indexed MCS Family strategy description says it "matches REFLEXIVE G/H semantics with T-axioms." But the current semantics is IRREFLEXIVE. The strategy description is outdated relative to the Truth.lean change. Option 2 forces this inconsistency to be resolved by aligning the strategy with the actual semantics.

## Comparative Analysis

| Criterion | Option 1 (T-axiom + reflexive) | Option 2 (Seriality + irreflexive) |
|-----------|-------------------------------|-------------------------------------|
| Soundness | Requires changing semantics to `<=` | Sound as-is for `<` semantics |
| Density proofs | BREAKS all density work | No impact on density |
| Effort estimate | HIGH (weeks) | MEDIUM (days) |
| Mathematical tradition | Prior 1967 (minority) | Goldblatt 1992, BdRV 2001 (standard) |
| Downstream breakage | ~30 refs restored | ~30 refs need rewriting |
| Coherence conditions | Keep reflexive `<=` | Change to strict `<` |
| Frame class | All linear orders | Linear orders without endpoints |
| Type class alignment | Weaker (allows endpoints) | Matches AddCommGroup (no endpoints) |
| Axiom economy | T-axiom subsumes seriality | Seriality is weaker (more economical) |
| Architectural consistency | Contradicts irreflexive switch | Consistent with irreflexive architecture |

## Recommendation

**Option 2: Add seriality axioms `F(neg bot)` and `P(neg bot)`.**

Rationale:
1. The switch to irreflexive semantics was a deliberate architectural decision (Truth.lean header). Reverting it (Option 1) would undo this decision and break density proofs.
2. Option 2 is sound, standard, and minimal.
3. The frame class restriction (no endpoints) matches the existing type class constraints on D (AddCommGroup implies no endpoints).
4. The seriality axiom directly provides `F(neg bot) in M` for NoMaxOrder, which is the immediate blocker.
5. The ~30 downstream T-axiom references need case-by-case analysis, but many can be eliminated by aligning coherence conditions with irreflexive semantics.

### Implementation Plan Sketch

**Phase A (Immediate, unblocks Phase 5):**
1. Add `seriality_future` and `seriality_past` to `Axiom` inductive
2. Update `isBase`, `isDenseCompatible`, `isDiscreteCompatible`
3. Add soundness proofs (with `NoMaxOrder`/`NoMinOrder` frame conditions, or put in base valid since AddCommGroup implies these)
4. Rewrite `mcs_has_F_top` and `mcs_has_P_top` using seriality axiom directly

**Phase B (Downstream fixes):**
5. Audit all ~30 `temp_t_future`/`temp_t_past` references
6. For each: determine if it's Pattern 1 (F(top) derivation) or Pattern 2 (coherence G(phi)->phi)
7. Pattern 1 references: replace with seriality axiom
8. Pattern 2 references: restructure coherence conditions to use strict `<`, or find alternative proof arguments

**Phase C (Architecture alignment):**
9. Update FMCS coherence conditions from `<=` to `<`
10. Update ROAD_MAP strategy description
11. Verify truth lemma still works with strict coherence

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Pattern 2 references may require deep proof restructuring | Medium | Audit first; some may already work with `<` |
| FMCS coherence change may cascade | Medium | Incremental: change one condition at a time |
| Soundness proof needs frame condition | Low | AddCommGroup already implies NoMaxOrder/NoMinOrder |
| `mcs_has_F_top` chain used in proofs beyond RestrictedFragment | Low | Direct seriality axiom is a simpler replacement everywhere |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Seriality axiom (D-axiom for temporal) | Option 2 analysis | No | new_file |
| Irreflexive vs reflexive temporal semantics | Comparative Analysis | Partial (Truth.lean header) | extension |
| Coherence condition alignment | Phase B/C | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `temporal-semantics-design.md` | `domain/` | Document the reflexive/irreflexive choice, seriality axiom, and implications | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Temporal section | Seriality axiom as frame condition, irreflexive vs reflexive | Medium | No |

### Summary

- New files needed: 0 (can fold into existing)
- Extensions needed: 1
- Tasks to create: 0
- High priority gaps: 0

## Decisions

- **D1**: Option 2 (seriality axioms) is recommended over Option 1 (T-axioms with reflexive semantics)
- **D2**: The seriality axioms should be classified as BASE axioms (valid on any frame satisfying AddCommGroup constraints)
- **D3**: Downstream T-axiom references require a systematic audit (Phase B) before they can be resolved

## Appendix

### Search Queries Used

- Codebase: `temp_t_future`, `temp_t_past`, `mcs_has_F_top`, `mcs_has_P_top`, `NoMaxOrder`
- Web: "Goldblatt temporal logic strict irreflexive semantics", "tense logic Kt axiomatization", "modal logic seriality axiom D axiom"
- Lean local: `serial`, `NoMaxOrder`

### Key Codebase Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Current 18-axiom system (no T-axioms)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - Irreflexive `<`/`>` semantics
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean` - Sound for current axioms (no T-axiom cases)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - Broken `mcs_has_F_top`/`mcs_has_P_top`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` - NoMaxOrder/NoMinOrder sorries
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` - Strategy context and dead ends

### References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Prior, A. (1967). *Past, Present and Future*. Oxford University Press.
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Wikipedia: [Modal Logic](https://en.wikipedia.org/wiki/Modal_logic) (D-axiom and seriality)
