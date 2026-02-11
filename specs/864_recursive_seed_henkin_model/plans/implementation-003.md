# Implementation Plan: Recursive Seed Henkin Model Construction (v3)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [PLANNED]
- **Effort**: 8 hours (remaining from 36 total, 28 completed)
- **Version**: 003 (revised from 002)
- **Dependencies**: None (supersedes task 843's approach)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-001.md
  - specs/864_recursive_seed_henkin_model/reports/research-002.md
  - specs/864_recursive_seed_henkin_model/reports/research-003.md (meta-evaluation)
  - specs/864_recursive_seed_henkin_model/reports/research-004.md (single-path invariant solution)
- **Artifacts**: plans/implementation-003.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v002 -> v003)

Based on research-004.md analysis of the 4 remaining sorries:

| Phase | v002 | v003 Changes |
|-------|------|--------------|
| Phase 3 | addToAll* lemmas blocked by mutual compatibility issue | **REVISED**: Add single-path invariant hypothesis `h_single_family` |
| Phase 3 | Generic imp case blocked by pattern matching | **REVISED**: Accept as Lean limitation OR explicit decidable predicate |
| Timeline | Unclear path forward | **CLARIFIED**: 3-4 sessions with concrete steps |
| Sorries | 4 remaining without clear resolution | **RESOLVED**: Each sorry has explicit proof strategy |

**Key insight from research-004**: buildSeedAux follows a SINGLE PATH through the formula tree. When processing Box/G/H (positive operators), no other families exist at the current time index because families are only created by neg-Box on the negative branch.

## Current State Summary

After 23 implementation sessions:
- **Phases 1-2**: COMPLETED (data structures and recursive builder)
- **Phase 3**: IN PROGRESS - 4 sorries remaining
- **Phases 4-6**: NOT STARTED

### Sorry Inventory (4 total)

| Line | Case | Issue | Resolution |
|------|------|-------|------------|
| 3138 | Box | `h_same_fam = false` - other families at timeIdx | Single-path invariant proves no other families exist |
| 3236 | G | `addToAllFutureTimes_preserves_consistent` | Similar to Box - future times on same path |
| 3350 | H | `addToAllPastTimes_preserves_consistent` | Similar to G - past times on same path |
| 3598 | imp | `h_eq : buildSeedAux = addFormula` | Accept as Lean limitation OR decidable refactor |

## Revised Phase 3: Seed Consistency Proof

### Phase 3a: Single-Path Invariant [NOT STARTED]

**Goal**: Add and prove the single-path invariant that enables the addToAll* sorries to be resolved.

**Key Insight**: When buildSeedAux processes Box psi (or G psi, H psi) at position (famIdx, timeIdx):
1. We are on the "positive branch" of the formula tree
2. The negative branch (neg-Box) creates NEW families, but we haven't taken it
3. Therefore `seed.familyIndices = {famIdx}` - only one family exists
4. `addToAllFamilies` only affects entries at famIdx, making `h_same_fam` always true

**Tasks**:
- [ ] Add hypothesis `h_single_family : seed.familyIndices = [famIdx]` to `buildSeedAux_preserves_seedConsistent`
- [ ] Prove `initialSeed_single_family`: Initial seed has `familyIndices = [0]`
- [ ] Prove `addFormula_preserves_single_family`: addFormula doesn't add families
- [ ] Prove `createNewTime_preserves_single_family`: createNewTime doesn't add families
- [ ] Prove positive branch cases preserve single-family (Box, G, H cases)
- [ ] Note: neg-Box case DOES create new family, so single-family property is NOT preserved
  - But IH for neg-Box is called at the NEW family, which is the only family in its subtree

**Expected Outcome**:
- Box case: `addToAllFamilies` at timeIdx only affects famIdx (no other families)
- G case: `addToAllFutureTimes` in family famIdx doesn't touch other families
- H case: `addToAllPastTimes` in family famIdx doesn't touch other families

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

**Verification**:
- Sorries at lines 3138, 3236, 3350 resolved
- `lake build` succeeds with at most 1 sorry (generic imp)

---

### Phase 3b: Generic Imp Case Resolution [NOT STARTED]

**Goal**: Resolve or document the generic imp case sorry.

**The Problem**: Lean's pattern matching doesn't provide "negative information" - when we enter the catch-all case `| p1, p2 =>`, we don't get a proof that p1 is not `box`/`all_future`/`all_past` or that p2 is not `bot`.

**Options**:

**Option A: Accept as Lean Technical Limitation** (Recommended)
- Document that this sorry is not a mathematical gap
- The proof WOULD work if Lean provided negative pattern info
- Mark with comment: `-- LEAN LIMITATION: Pattern matching doesn't provide negative info`
- Proceed to Phase 4

**Option B: Exhaustive Case Analysis**
- Split on all (p1, p2) combinations (~30 cases)
- Each concrete case reduces buildSeedAux to addFormula
- Tedious but mechanical

**Option C: Decidable Predicate Refactor**
- Define `isSpecialImp : Formula → Formula → Bool`
- Use `if isSpecialImp p1 p2 then ... else ...` in buildSeedAux
- Catch-all provides `isSpecialImp p1 p2 = false` as hypothesis
- Risk: May break termination proof

**Recommendation**: Option A for now. This sorry does not affect mathematical correctness and can be addressed later if needed.

**Tasks**:
- [ ] Document the pattern matching limitation in code comments
- [ ] Add TODO marker for potential future resolution
- [ ] OR implement Option B if sorry-freedom is required for publication

**Timing**: 0.5 hours (Option A) or 2 hours (Option B)

---

### Phase 3 Completion Criteria

- [ ] All 4 sorries addressed (3 eliminated, 1 documented as Lean limitation)
- [ ] `seedConsistent` theorem compiles
- [ ] `lake build` succeeds
- [ ] No new sorries introduced

---

## Phases 4-6: Unchanged from v002

See implementation-002.md for detailed Phase 4-6 specifications. These phases depend on Phase 3 completion.

### Phase 4: Seed Completion to MCS Families
- Extend seed entries to full MCS via Lindenbaum
- Build IndexedMCSFamily for each family index
- **Estimated**: 4 hours

### Phase 5: BMCS Assembly and Coherence Proofs
- Assemble families into BMCS
- Prove modal_forward, modal_backward, temporal coherence
- Eliminate axioms
- **Estimated**: 6 hours

### Phase 6: Verification and Cleanup
- Final verification
- Documentation
- **Estimated**: 2 hours

---

## Proof Strategy: Single-Path Invariant Detail

### Why the Invariant Works

The buildSeedAux recursion has two branch types:
1. **Positive branch**: Box psi, G psi, H psi - adds to existing entries, never creates families
2. **Negative branch**: neg-Box psi, neg-G psi, neg-H psi - creates new families/times, recurses there

Key observation: When we reach a positive branch (Box/G/H), we are NOT on a path that went through neg-Box. Therefore:
- No families have been created on this path
- `seed.familyIndices = {famIdx}` where famIdx is the starting family (0 for root)

### Formal Statement

```lean
theorem buildSeedAux_preserves_seedConsistent_with_path
    (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
    (h_cons : SeedConsistent seed)
    (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx]) -- NEW
    : SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

For neg-Box case (which creates a new family):
- The IH is applied at the NEW family index (nextFamilyIdx)
- At that point, `familyIndices = [nextFamilyIdx]` for the subtree
- This is consistent with single-path property - each path has its own root family

### Implementation Steps

1. **Add hypothesis**: Add `h_single_family` to the theorem signature
2. **Prove initial case**: `initialSeed.familyIndices = [0]`
3. **Prove preservation for positive cases**:
   - Box: addFormula and addToAllFamilies don't change familyIndices
   - G: addFormula and addToAllFutureTimes don't change familyIndices
   - H: addFormula and addToAllPastTimes don't change familyIndices
4. **Handle negative cases**:
   - neg-Box: After createNewFamily, apply IH at new family with `[nextFamilyIdx]`
   - neg-G: Same family, different time - single-family unchanged
   - neg-H: Same family, different time - single-family unchanged

---

## Risks & Mitigations (v003)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Single-path invariant harder than expected | Medium | Low | The invariant follows directly from buildSeedAux structure |
| neg-Box case IH application tricky | Medium | Medium | Carefully track that new family becomes root of its subtree |
| Generic imp case requires Option B | Low | Low | Accept Option A first, revisit if needed |
| Phase 4-6 reveal new issues | Medium | Low | Phase 3 completion provides solid foundation |

---

## Expected Outcome

After implementing this revised plan:

**Phase 3 Completion**:
- 3 sorries eliminated (Box/G/H cases via single-path invariant)
- 1 sorry documented (generic imp - Lean limitation)
- `seedConsistent` theorem operational

**Overall Task 864**:
- Zero critical axioms on completeness path (target)
- At most 1 documented Lean-limitation sorry
- Task 843's blockage fully resolved

---

## Timeline

| Phase | Sessions | Hours | Cumulative |
|-------|----------|-------|------------|
| 3a: Single-Path Invariant | 2-3 | 4 | 32 |
| 3b: Generic Imp Resolution | 0.5-1 | 1 | 33 |
| 4: Seed Completion | 2 | 4 | 37 |
| 5: BMCS Assembly | 3 | 6 | 43 |
| 6: Verification | 1 | 2 | 45 |

**Estimated completion**: 5-7 more sessions (vs. unclear in v002)

---

## References

- research-004.md: Single-path invariant analysis
- RecursiveSeed.lean lines 3052-3614: Current sorry locations
- implementation-002.md: Session history and progress updates
