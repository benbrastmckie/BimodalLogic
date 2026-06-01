# Research Report: Proof Term Extraction from Closed Tableaux

**Task**: 239 -- Replace stub proof extraction with complete backward-chaining algorithm
**Session**: sess_1780346170_32beea
**Date**: 2026-06-01

## 1. Current State of the Codebase

### 1.1 The Stub (ProofExtraction.lean)

The file `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` contains the stub at line 162:

```lean
.incomplete "Full proof extraction not yet implemented"
```

The current `extractProof` function handles only two cases:
1. **Direct axiom match**: Uses `tryAxiomProof` which calls `matchAxiom` to pattern-match the top-level formula against one of the 42 axiom schemata.
2. **Axiom-closure branch match**: Checks if any closed branch's `axiomNeg` closure reason matches the goal formula directly.

Everything else falls through to the "not yet implemented" stub. The `DecisionProcedure.lean` also has a workaround: when tableau proves validity but proof extraction fails, it falls back to `bounded_search_with_proof` with doubled depth, and if that also fails, returns `.timeout` ("Better than lying about invalidity").

### 1.2 DerivationTree Type (Derivation.lean)

The `DerivationTree` inductive has 7 constructors:

| Constructor | Signature | Context |
|-------------|-----------|---------|
| `axiom` | `Axiom phi -> h_fc -> DerivationTree fc Gamma phi` | Any context |
| `assumption` | `phi in Gamma -> DerivationTree fc Gamma phi` | Needs membership |
| `modus_ponens` | `DT fc Gamma (phi.imp psi) -> DT fc Gamma phi -> DT fc Gamma psi` | Same context |
| `necessitation` | `DT fc [] phi -> DT fc [] (box phi)` | Empty context only |
| `temporal_necessitation` | `DT fc [] phi -> DT fc [] (all_future phi)` | Empty context only |
| `temporal_duality` | `DT fc [] phi -> DT fc [] (swap_temporal phi)` | Empty context only |
| `weakening` | `DT fc Gamma phi -> Gamma subseteq Delta -> DT fc Delta phi` | Subset relation |

Key observations:
- Frame class `fc` is a parameter (Base, Dense, Discrete) gating which axioms are available.
- Necessitation rules require **empty context** (theorems only).
- The notation `_ ⊢ phi` defaults to `FrameClass.Base`.

### 1.3 Tableau System

**Tableau starting point**: `buildTableau` begins with a single branch `[SignedFormula.neg phi Label.initial]` (i.e., `F(phi)` at world 0, time 0).

**Expansion**: `expandBranchWithFuel` iteratively applies rules from `allRulesForFC`. Rules are categorized as:
- **Linear** (non-branching): Add formulas, remove source
- **Branching**: Split into multiple sub-branches
- **Persistent**: Add formulas, keep source (for universal modal/temporal rules)

**Closure detection** (`findClosure`): Checks three conditions in order:
1. `checkBotPos`: T(bot) present
2. `checkContradiction`: Both T(phi) and F(phi) at the same label
3. `checkAxiomNeg`: F(phi) where phi is an axiom instance (via `matchAxiom`)

**Result types**:
- `ExpandedTableau.allClosed closedBranches`: All branches closed, formula is valid
- `ExpandedTableau.hasOpen openBranch _`: At least one open branch, formula is invalid

### 1.4 Available Proof Infrastructure

Key tools already in the codebase:
- `matchAxiom : Formula -> Option (Sigma Axiom)` -- Pattern-match all 42 axiom schemata
- `bounded_search_with_proof` -- Proof-constructing DFS search
- `identity : |- A -> A` -- SKK combinator construction
- `imp_trans` -- Transitivity of implication
- `mp` -- Modus ponens combinator
- `b_combinator` -- Function composition
- `theorem_flip` -- Argument flip (C combinator)
- `deduction_theorem` -- If `A :: Gamma |- B` then `Gamma |- A -> B`
- `proofFromBot : |- bot -> phi` -- Ex falso via axiom
- `proofFromAxiom` -- Direct axiom instantiation
- `matchDerived` -- Match derived theorems (currently only temp_future_derived)

### 1.5 Axiom System (42 axioms)

Organized into layers:
1. **Propositional (4)**: prop_k, prop_s, ex_falso, peirce
2. **S5 Modal (5)**: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
3. **BX Temporal (22)**: serial_future/past, left_mono_until_G/since_H, right_mono_until/since, connect_future/past, enrichment_until/since, self_accum_until/since, absorb_until/since, linear_until/since, until_F/since_P, temp_linearity/past, F_until_equiv/P_since_equiv
4. **Interaction (1)**: modal_future
5. **Uniformity (5)**: discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity
6. **Prior (2)**: prior_UZ, prior_SZ
7. **Z1 (1)**: z1
8. **Density (2)**: density, dense_indicator

## 2. Analysis: Why Current Extraction Fails

The current extraction only handles the trivial case where the *entire formula* is an axiom instance. But most valid formulas require combining multiple axiom applications and inference rules. For example:

- `p -> p` is valid (identity), but is NOT a single axiom instance
- `box(p) -> box(box(p))` IS an axiom instance (modal_4)
- `(p -> q) -> (p -> q)` requires SKK identity construction
- `box(p -> q) -> (box(p) -> box(q))` IS an axiom instance (modal_k_dist)

The fundamental gap: **the tableau proves validity by finding contradictions, but extracting a proof term requires reconstructing WHY the contradiction implies the formula**.

## 3. Backward-Chaining Algorithm Design

### 3.1 Core Insight

When the tableau starts with F(phi) and all branches close, we know phi is valid. The proof extraction must invert the tableau process:

1. **Tableau goes forward**: Start with F(phi), expand rules, find contradictions
2. **Proof extraction goes backward**: From the closed branches, reconstruct a DerivationTree for phi

The key principle: each tableau rule application corresponds to a proof-theoretic step, but **in reverse**.

### 3.2 Proof Reconstruction by Closure Reason

Each closure reason maps to a proof fragment:

#### Case 1: `axiomNeg phi witness label`
- Meaning: F(phi) is on the branch, and phi is an axiom instance
- Proof: `DerivationTree.axiom [] phi witness h_fc`
- This is the simplest case (already handled)

#### Case 2: `contradiction phi label`
- Meaning: Both T(phi) and F(phi) are on the branch at the same label
- Proof strategy: The contradiction means the initial assumption F(goal) led to both T(phi) and F(phi). We need to trace how these arose and construct a proof by contradiction using Peirce's law.
- For propositional tautologies: This typically involves the identity or more complex propositional reasoning.

#### Case 3: `botPos label`
- Meaning: T(bot) appeared on the branch
- Proof strategy: The expansion from F(goal) produced T(bot), meaning the negation of goal implies bot. Use ex_falso.

### 3.3 Tableau Rule Inversion Table

Each tableau rule that was applied forward must be inverted to a DerivationTree construction:

| Tableau Rule | Forward Direction | Proof-Theoretic Inverse |
|-------------|-------------------|------------------------|
| `impNeg` | F(A -> B) => T(A), F(B) | If proof of B from {A, not(A->B)}, then proof of A->B |
| `impPos` | T(A -> B) => F(A) \| T(B) | Branch: need proofs for both sub-branches |
| `andPos` | T(A and B) => T(A), T(B) | Conjunction elimination |
| `andNeg` | F(A and B) => F(A) \| F(B) | Branch: disjunction reasoning |
| `negPos` | T(neg A) => F(A) | Double negation / Peirce |
| `negNeg` | F(neg A) => T(A) | Negation elimination |
| `boxPos` | T(box A) => propagate T(A) | necessitation + modal_k_dist |
| `boxNeg` | F(box A) => F(A) at fresh world | Requires modal reasoning chain |
| `allFuturePos` | T(GA) => propagate T(A) | temporal_necessitation + temp_k_dist |
| `allFutureNeg` | F(GA) => F(A) at fresh time | Requires temporal reasoning chain |

### 3.4 Proposed Architecture

#### Phase 1: Augmented Tableau (Record Expansion History)

The current tableau does NOT record which rules were applied or the expansion sequence. The key change: **augment the tableau expansion to record a trace**.

```
structure ExpansionStep where
  rule : TableauRule
  source : SignedFormula
  branch_id : Nat  -- which branch this step belongs to
  produced : List SignedFormula
  branching : Bool  -- did this step cause branching?
```

The `expandBranchWithFuel` function needs to be modified (or a parallel version created) that returns the expansion trace alongside the closed/open result.

#### Phase 2: Backward-Chaining Proof Builder

Given a closed tableau with expansion trace, build the proof bottom-up:

```
def buildProofFromTrace (phi : Formula) (trace : ExpansionTrace)
    (closedBranches : List ClosedBranch) : ProofExtractionResult phi
```

The algorithm:
1. Start from each closed branch's closure reason
2. Walk backward through the expansion trace
3. At each step, map the tableau rule to a DerivationTree constructor
4. At branching points, combine sub-proofs using propositional reasoning
5. At the root, assemble the final `|- phi` term

#### Phase 3: Propositional Proof Fragments

For handling propositional branching (case analysis), the core technique is **Peirce's law**:

```
peirce : ((phi -> psi) -> phi) -> phi
```

When a tableau branches on `T(A -> B)` into F(A) | T(B):
- Branch 1 closes under assumption F(A), giving a proof of A (by contradiction)
- Branch 2 closes under assumption T(B), giving a proof of B
- Combined: proof of A -> B (deduction theorem), then modus ponens

The `identity` combinator and `deduction_theorem` are essential building blocks.

#### Phase 4: Modal Proof Fragments

For modal rules:
- `boxNeg` (F(box A) => F(A) at fresh world): Requires constructing `|- box phi` from `|- phi` via necessitation, then using modal_k_dist for distribution.
- `boxPos` (T(box A) => T(A) at all worlds): Uses modal_t (box phi -> phi) for the initial world, and modal_k_dist for propagation.

#### Phase 5: Temporal Proof Fragments

For temporal rules:
- `allFutureNeg` (F(GA) => F(A) at fresh time): Uses temporal_necessitation to promote theorems to G-theorems.
- `allFuturePos` (T(GA) => T(A) at all future times): Uses BX axioms for temporal distribution.
- `someFuturePos`/`somePastPos`: Uses BX10 (until_F / since_P) axioms.

### 3.5 Handling Branching

When the tableau branches, both sub-branches must close. In proof terms, this corresponds to case analysis. The standard technique for Hilbert-style systems:

1. **Implication branching** (`impPos`: T(A -> B) => F(A) | T(B)):
   - Left branch: Under assumption F(A), derive contradiction => get proof of A
   - Right branch: Under assumption T(B), derive the goal
   - Combine using Peirce's law or deduction theorem

2. **Disjunction branching** (`orPos`: T(A or B) => T(A) | T(B)):
   - Similar: two proofs by case analysis
   - Combine using propositional reasoning (or-elimination)

3. **Conjunction branching** (`andNeg`: F(A and B) => F(A) | F(B)):
   - Two sub-proofs, one for each disjunct of not(A and B)
   - Combine using disjunction reasoning

### 3.6 Complexity Considerations

The main challenge is not algorithmic but **term construction**:
- Lean's type system requires every DerivationTree to be well-typed
- Frame class constraints (`h_fc : ax.minFrameClass <= fc`) must be provided
- Context subset proofs (`h : Gamma subseteq Delta`) must be constructed
- Formula equality proofs may be needed when matching

The deduction theorem proof in the codebase uses well-founded recursion on tree height, which is already proven to work.

## 4. Implementation Strategy

### 4.1 Recommended Approach: Augmented Tableau + Backward Walk

**Option A (Recommended)**: Create a new parallel tableau function that records the expansion trace, then walk backward through the trace to build the proof.

Advantages:
- Clean separation: existing tableau logic unchanged
- Full information available for proof reconstruction
- Can be developed incrementally (handle simple cases first)

**Option B (Not Recommended)**: Try to reconstruct the proof from just the closed branches and closure reasons, without an expansion trace.

This is much harder because the closed branches only tell you WHAT closed, not HOW the formulas got there.

### 4.2 Phase Decomposition

**Phase 1: Expansion Trace Infrastructure**
- Define `ExpansionStep` and `ExpansionTrace` types
- Create `expandBranchWithTrace` that mirrors `expandBranchWithFuel` but records steps
- Create `buildTableauWithTrace` that returns trace alongside tableau result

**Phase 2: Propositional Proof Extraction**
- Handle `contradiction` closure for propositional formulas
- Handle `botPos` closure via ex_falso
- Handle branching via Peirce's law / deduction theorem
- Test with simple tautologies: `p -> p`, `p -> (q -> p)`, `((p -> q) -> p) -> p`

**Phase 3: Modal Proof Extraction**
- Handle `boxNeg`/`boxPos` rules via necessitation + modal_k_dist
- Handle `diamondPos`/`diamondNeg` rules
- Handle `boxTemporal` rule via modal_future axiom
- Test with modal tautologies: `box p -> p`, `box p -> box(box p)`

**Phase 4: Temporal Proof Extraction**
- Handle `allFuturePos`/`allFutureNeg` rules
- Handle `someFuturePos`/`someFutureNeg` rules
- Handle `untlPos`/`untlNeg` rules via BX axioms
- Test with temporal tautologies

**Phase 5: Integration and Testing**
- Wire into `extractProof` replacing the stub
- Wire into `DecisionProcedure.decide` replacing the timeout fallback
- Run against existing test battery
- Verify with `lake build`

### 4.3 Key Files to Modify

| File | Changes |
|------|---------|
| `ProofExtraction.lean` | Replace stub with backward-chaining algorithm |
| `Saturation.lean` | Add `expandBranchWithTrace` parallel to `expandBranchWithFuel` |
| `Tableau.lean` | Add `ExpansionStep` type (non-breaking addition) |
| `DecisionProcedure.lean` | Update `decide` to use improved extraction |

### 4.4 Key Dependencies to Leverage

- `Theorems/Combinators.lean`: `identity`, `imp_trans`, `mp`, `b_combinator`, `theorem_flip`
- `Metalogic/Core/DeductionTheorem.lean`: `deduction_theorem` for converting context-based proofs to theorems
- `Automation/ProofSearch/Core.lean`: `matchAxiom`, `bounded_search_with_proof` as fallback
- `ProofSystem/Derivation.lean`: All 7 `DerivationTree` constructors

### 4.5 Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Propositional case analysis via Peirce is complex | High | Start with identity/simple tautologies, build up |
| Modal proof fragments require careful world tracking | Medium | Use existing necessitation + modal_k_dist patterns |
| Temporal proof fragments with BX axioms are numerous | Medium | Handle one axiom class at a time |
| Term construction may hit Lean type-checking edge cases | Medium | Use existing combinator patterns as templates |
| Expansion trace may increase memory usage | Low | Trace is proportional to expansion steps (bounded by fuel) |
| Frame class threading adds complexity | Low | Default to Base frame class initially |

## 5. Alternative Approaches Considered

### 5.1 Direct Proof Search Enhancement

Instead of extracting from tableau, enhance `bounded_search_with_proof` to handle more cases. This is partially what the current fallback does. However:
- Proof search is depth-limited and incomplete for complex formulas
- Tableau has already proven validity; re-deriving is wasteful
- The search space for modal/temporal proofs is much larger than for propositional

### 5.2 Interpolation-Based Approach

Use Craig interpolation to decompose the proof. Not practical because:
- Interpolation theorem for TM logic would need to be proven first
- The implementation would be more complex than direct trace extraction

### 5.3 Hybrid Approach

Use tableau trace for the structural skeleton but delegate leaf proofs to `bounded_search_with_proof`. This could work as a middle ground:
- Tableau trace handles branching structure
- Proof search handles individual proof obligations at leaves
- Reduces complexity of trace-to-proof mapping

This is worth considering for the implementation plan.

## 6. Conclusions and Recommendations

1. **The expansion trace approach is the correct design**. The current code lacks the information needed for proof reconstruction because it discards the expansion history.

2. **Phase decomposition is essential**. Tackling all 30+ tableau rules at once is too complex. Start with propositional, add modal, then temporal.

3. **The existing combinator infrastructure is sufficient** for the propositional fragment. The `identity`, `imp_trans`, `deduction_theorem`, and `peirce` axiom provide all needed tools.

4. **Modal proof extraction is well-understood**. The pattern of necessitation + modal_k_dist is standard and already used in the codebase.

5. **Temporal proof extraction is the hardest part** due to the 22 BX axioms and complex Until/Since interaction. A hybrid approach (trace + search) may be pragmatic for this layer.

6. **The zero-sorry constraint is achievable** for this task, since the proof extraction algorithm is purely computational (def, not theorem). The core challenge is constructing well-typed DerivationTree terms, which Lean's type-checker enforces.

7. **Estimated complexity**: 4-5 phases, each requiring careful implementation and testing. The propositional phase alone is non-trivial due to Peirce's law case analysis.
