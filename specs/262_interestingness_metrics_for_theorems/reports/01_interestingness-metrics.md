# Research Report: Interestingness Metrics for Theorems in Bimodal Logic TM

- **Task**: 262 - Interestingness Metrics for Theorems
- **Started**: 2026-06-02T12:00:00Z
- **Completed**: 2026-06-02T12:30:00Z
- **Effort**: medium (8-12 hours)
- **Dependencies**: None
- **Sources/Inputs**: Colton/Bundy HR system, IsaCoSy, FERMAT (NeurIPS 2025), BMLogic codebase
- **Artifacts**: specs/262_interestingness_metrics_for_theorems/reports/01_interestingness-metrics.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## 1. Executive Summary

The current BMLogic dataset records formulas with validity labels, structural complexity, modal/temporal depth, implication counts, and difficulty tiers -- but these metrics say nothing about whether a theorem is trivial, surprising, useful, or mathematically significant. All 1,959 valid formulas across the training datasets (c5, c7, c9) have proof height 0 and are direct axiom instances (predominantly `ex_falso` and `prop_s`), making every valid example maximally uninteresting by proof-structure criteria. The proof_steps.jsonl file contains 310 named theorems with richer proof traces (up to 327 steps, 5 distinct rule types), but these are not cross-referenced into the training JSONL records.

This report surveys the literature on automated interestingness measures, analyzes the existing codebase infrastructure, defines a taxonomy of eight interestingness dimensions with concrete computable metrics, and proposes a composite scoring system suitable as a filtering criterion or reward signal for training networks to discover non-trivial derivations.

---

## 2. Literature Survey

### 2.1 Colton and Bundy: HR System (1999-2007)

Simon Colton's HR system (named after Hardy and Ramanujan) is the foundational work on automated theory formation with interestingness measures. The system uses MACE for model generation, performs concept formation and conjecture making, and employs Otter for proof/counterexample finding.

**Colton's Interestingness Dimensions** (from "On the Notion of Interestingness in Automated Mathematical Discovery"):

1. **Plausibility** -- empirical evidence supporting a conjecture (counterexample count)
2. **Novelty** -- how different a result is from known results
3. **Surprisingness** -- deviation from expected behavior based on related concepts
4. **Comprehensibility** -- syntactic complexity and human readability
5. **Applicability** -- how broadly a concept/theorem can be applied

HR uses these measures as heuristic weights in best-first search, prioritizing concept formation steps that maximize a weighted combination of interestingness scores.

### 2.2 IsaCoSy and Theory Exploration (Johansson et al., 2009-2014)

IsaCoSy synthesizes conjectures bottom-up from available constants and free variables. Its key interestingness criterion is **irreducibility**: only generating terms that cannot be simplified by equational reasoning. This ensures conjectures are non-trivial. The Hipster system extends this approach to Isabelle/HOL with automated theory exploration.

**Relevant filtering criteria from IsaCoSy**:
- Irreducibility (cannot be simplified by existing equational lemmas)
- Non-redundancy (not an instance of a more general known theorem)
- Inductive necessity (requires induction to prove, not just simplification)

### 2.3 FERMAT: Learning Interestingness (NeurIPS 2025 Spotlight)

The most recent and directly relevant work. FERMAT introduces an RL environment for concept discovery and theorem proving with an LLM-based evolutionary algorithm for synthesizing interestingness measures. Key insights:

- Ground truth evaluation against 67 curated "interesting" entities spanning reflexive properties to the Goldbach conjecture
- Function abstraction in evolutionary search for interestingness measures
- Demonstrated that learned interestingness measures outperform hand-coded baselines

### 2.4 Information-Theoretic Approaches

Shannon entropy provides a principled framework for measuring "surprise":
- **Information content**: I(x) = -log P(x), where lower probability means higher surprise
- **Formula entropy**: Distribution of constructor types relative to a baseline distribution
- For theorem interestingness: A formula with low probability under a null model (random formula generation) that is nonetheless valid is "surprising"

### 2.5 Proof Complexity Literature

The proof complexity community provides measures focused on proof structure:
- **Proof length** (number of inference steps)
- **Proof depth** (longest path from root to leaf)
- **Proof width** (maximum number of formulas in working memory)
- **Proof speed-up**: Ratio of shortest proof to formula size (theorems with high speed-up are more interesting)

---

## 3. Analysis of Current Dataset and Infrastructure

### 3.1 Current Dataset Fields

Each JSONL record contains:

| Field | Type | Description |
|-------|------|-------------|
| `formula_str` | String | Unicode formula representation |
| `formula_ast` | JSON | Abstract syntax tree |
| `label` | String | "valid", "invalid", "timeout" |
| `proof_trace` | Object | `{height, axioms_used, rules_applied}` |
| `metrics.complexity` | Nat | Connective count + 1 |
| `metrics.modalDepth` | Nat | Maximum modal nesting |
| `metrics.temporalDepth` | Nat | Maximum temporal nesting |
| `metrics.impCount` | Nat | Implication operator count |
| `metrics.atomCount` | Nat | Distinct atom count |
| `metrics.difficultyTier` | String | "easy", "medium", "hard", "very_hard" |
| `pattern_key` | Object | Structural indexing key |
| `pattern_features` | Array | Numeric feature vector |

### 3.2 Critical Gap: All Valid Formulas Are Trivial

Across bmlogic-c5 (64 valid), bmlogic-c7, and bmlogic-c9 datasets:
- **ALL** valid formulas have `proof_trace.height = 0`
- **ALL** are direct axiom instances (single axiom match, no inference rules)
- Most common axioms: `ex_falso` (1,754 of 1,959), `prop_s` (173), `modal_t` (20), `modal_4` (8), `peirce` (4)
- No modus ponens, no necessitation, no temporal duality in any valid training record

This means the current dataset contains **zero examples of non-trivial theorems** -- every valid formula is either "bottom implies anything" (`ex_falso`) or "anything implies itself" patterns (`prop_s`). This is the core problem interestingness metrics must address.

### 3.3 Proof Steps Dataset

The `proof_steps.jsonl` file contains 10,063 steps across 310 named theorems with much richer structure:
- Theorems with up to 327 steps (e.g., `H_perpetuity_4`)
- Up to 8 distinct axioms used in a single proof (e.g., `s4_diamond_box_diamond`)
- All 5 inference rule types represented: modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening
- 109 theorems use more than 2 distinct rule types

### 3.4 Existing Computable Functions in Lean

The codebase already provides these formula-level measures:

| Function | Location | Description |
|----------|----------|-------------|
| `Formula.complexity` | Syntax/Formula.lean:162 | Connective count + 1 |
| `Formula.modalDepth` | Syntax/Formula.lean:262 | Max modal nesting |
| `Formula.temporalDepth` | Syntax/Formula.lean:283 | Max temporal nesting |
| `Formula.countImplications` | Syntax/Formula.lean:303 | Implication count |
| `Formula.atoms` | Syntax/Formula.lean:529 | Set of propositional atoms |
| `Formula.subformulas` | Syntax/Subformulas.lean:38 | All subformulas |
| `Formula.subformulaCount` | Syntax/Subformulas.lean:47 | Distinct subformula count |
| `Formula.predFormulas` | Syntax/Formula.lean:556 | Predicate symbols for FO translation |
| `subformulaClosure` | SubformulaClosure/Closure.lean:30 | Subformula closure set |
| `closureWithNeg` | SubformulaClosure/Closure.lean:65 | Closure with negations |
| `diamondCount` | SubformulaClosure/Closure.lean:224 | Diamond subformula count |
| `f_nesting_depth` | SubformulaClosure/NestingDepth.lean:33 | F-operator nesting |
| `p_nesting_depth` | SubformulaClosure/NestingDepth.lean:116 | P-operator nesting |
| `DerivationTree.height` | ProofSystem/Derivation.lean:223 | Proof tree height |
| `walkDerivationTree` | Automation/DataExport.lean:325 | Rule application profile |
| `extractProofTrace` | Automation/DatasetGenerator.lean:248 | Simplified proof trace |
| `PatternKey.fromFormula` | Automation/SuccessPatterns.lean:115 | Structural feature extraction |
| `goalCategory` | Automation/SuccessPatterns.lean:76 | Top-level operator category |

---

## 4. Taxonomy of Interestingness Dimensions

We propose eight dimensions, each with a deterministic computable metric. These dimensions are ordered from cheapest to compute (pure syntax) to most expensive (requires proof search or cross-referencing).

### Dimension 1: Semantic Non-Triviality (SNT)

**Intuition**: Filter out formulas that are trivially valid regardless of their logical content.

**Definition**: A formula is semantically trivial if it matches one of these patterns:
- `bot.imp phi` for any phi (ex falso quodlibet)
- `phi.imp phi` for any phi (identity)
- `phi.imp (psi.imp phi)` for any phi, psi (weakening)
- `phi.imp top` for any phi
- Any formula whose validity follows from propositional logic alone (no modal/temporal content)

**Computation**:
```
def semanticNonTriviality (phi : Formula) : Nat :=
  -- Returns 0 for trivially valid patterns, 1-3 for increasing non-triviality
  if isExFalsoPattern phi then 0
  else if isIdentityPattern phi then 0
  else if isWeakeningPattern phi then 0
  else if isPropositionalTautology phi then 1  -- valid but purely propositional
  else if usesOnlyModalOps phi then 2          -- modal but no temporal
  else 3                                        -- genuinely bimodal
```

**Pattern detection**: Implement recursive pattern matching on the Formula AST. The `isPropositionalTautology` check requires a lightweight propositional satisfiability test (strip all modal/temporal operators, treating subformulas as atoms, check if the resulting propositional skeleton is a tautology).

**Cost**: O(n) for pattern matching, O(2^k) for propositional skeleton check where k = distinct subformula atoms (typically small).

### Dimension 2: Operator Diversity (OD)

**Intuition**: Formulas that meaningfully combine modal and temporal operators are more interesting than those using only one type.

**Definition**: Count the distinct operator types used in the formula, weighted by cross-modal interaction.

**Computation**:
```
structure OperatorProfile where
  hasBox : Bool        -- modal necessity
  hasDiamond : Bool    -- modal possibility (derived)
  hasUntil : Bool      -- temporal Until
  hasSince : Bool      -- temporal Since
  hasAllFuture : Bool  -- G operator (derived from Until)
  hasAllPast : Bool    -- H operator (derived from Since)
  hasSomeFuture : Bool -- F operator (derived)
  hasSomePast : Bool   -- P operator (derived)

def operatorDiversity (phi : Formula) : Float :=
  let prof := extractOperatorProfile phi
  let modalCount := [prof.hasBox, prof.hasDiamond].countTrue
  let temporalCount := [prof.hasUntil, prof.hasSince, prof.hasAllFuture,
                         prof.hasAllPast, prof.hasSomeFuture, prof.hasSomePast].countTrue
  let rawDiversity := modalCount + temporalCount
  let crossModalBonus := if modalCount > 0 && temporalCount > 0 then 2 else 0
  let bidirectionalBonus := if (prof.hasUntil || prof.hasAllFuture || prof.hasSomeFuture) &&
                               (prof.hasSince || prof.hasAllPast || prof.hasSomePast) then 1 else 0
  (rawDiversity + crossModalBonus + bidirectionalBonus : Nat)
```

**Note**: Derived operators (G, H, F, P, diamond, always, sometimes) are encoded as combinations of primitive constructors in the AST (e.g., `some_future phi = untl phi top`, `all_future phi = neg (some_future (neg phi))`). The operator profile extractor must recognize these patterns to correctly identify derived operator usage.

**Cost**: O(n) single pass over formula AST.

### Dimension 3: Proof Depth Ratio (PDR)

**Intuition**: A valid formula with a deep, non-obvious proof is more interesting than one closed by a single axiom application.

**Definition**: Ratio of proof tree height to formula complexity, normalized.

**Computation**:
```
def proofDepthRatio (trace : ProofTrace) (phi : Formula) : Float :=
  let h := trace.height
  let c := phi.complexity
  if c == 0 then 0.0
  else (h.toFloat / c.toFloat)
```

**Extended version using RuleProfile**:
```
def proofRichness (rp : RuleProfile) (phi : Formula) : Float :=
  let totalRules := rp.mpCount + rp.necessitationCount + rp.temporalNecessitationCount +
                    rp.temporalDualityCount
  let c := phi.complexity
  if c == 0 then 0.0
  else (totalRules.toFloat / c.toFloat)
```

**Current limitation**: All training data valid formulas have height 0. This metric becomes useful only when the proof search pipeline produces non-trivial proofs (or when cross-referencing with proof_steps.jsonl).

**Cost**: O(1) given pre-computed proof trace.

### Dimension 4: Proof Rule Diversity (PRD)

**Intuition**: Proofs that use multiple inference rules (modus ponens AND necessitation AND temporal duality) demonstrate deeper logical interaction than proofs using only one rule type.

**Definition**: Count of distinct inference rule types used in the proof.

**Computation**:
```
def proofRuleDiversity (trace : ProofTrace) : Nat :=
  trace.rules_applied.eraseDups.length

-- Extended: axiom layer diversity
def axiomLayerDiversity (trace : ProofTrace) : Nat :=
  let layers := trace.axioms_used.map classifyAxiomLayer |>.eraseDups
  layers.length
where
  classifyAxiomLayer (name : String) : String :=
    if name ∈ ["prop_k", "prop_s", "ex_falso", "peirce"] then "propositional"
    else if name ∈ ["modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist"] then "modal"
    else if name ∈ ["modal_future"] then "interaction"
    else "temporal"
```

**Scoring**: A proof using axioms from all 4 layers (propositional + modal + temporal + interaction) scores highest.

**Cost**: O(|rules|) given pre-computed trace.

### Dimension 5: Structural Novelty (SN)

**Intuition**: A formula is structurally novel if it is not a simple substitution instance of a known axiom or previously seen theorem.

**Definition**: Distance from nearest axiom schema instance, measured by structural edit distance.

**Computation** (two-stage):

**Stage A -- Axiom instance detection**:
```
def isDirectAxiomInstance (phi : Formula) : Bool :=
  -- Check if phi exactly matches any axiom schema instantiation
  -- This is already done by the axiom_match reconstruction method
  phi matches some Axiom.* pattern

def axiomDistance (phi : Formula) : Nat :=
  -- Minimum tree-edit distance to any axiom schema instance
  -- For each axiom schema, find the closest instantiation
  -- Return minimum across all schemas
  allAxiomSchemas.map (fun schema => minInstanceDistance schema phi) |>.minimum
```

**Stage B -- Cross-reference novelty**:
```
def crossReferenceNovelty (phi : Formula) (knownTheorems : List Formula) : Float :=
  -- How different is phi from all known theorems?
  -- Use subformula overlap as a similarity measure
  let selfSubs := phi.subformulas.eraseDups.toFinset
  let maxOverlap := knownTheorems.map (fun thm =>
    let thmSubs := thm.subformulas.eraseDups.toFinset
    (selfSubs ∩ thmSubs).card.toFloat / (selfSubs ∪ thmSubs).card.toFloat
  ) |>.maximum |>.getD 0.0
  1.0 - maxOverlap
```

**Cost**: O(|axiom_schemas| * n) for axiom detection, O(|known| * n^2) for cross-reference.

### Dimension 6: Information Content (IC)

**Intuition**: Formulas with high information content (low probability under a null model) that are valid are more surprising and thus more interesting.

**Definition**: Negative log-probability of the formula under a uniform random formula generation model.

**Computation**:
```
def informationContent (phi : Formula) : Float :=
  -- Under a uniform random generation model at complexity c,
  -- what fraction of formulas at complexity c are valid?
  -- Approximated by: -log2(validRate(complexity))
  -- where validRate is pre-computed from dataset statistics
  let c := phi.complexity
  let validRate := lookupValidRate c  -- from dataset metadata
  if validRate <= 0.0 then 0.0
  else -Float.log2 validRate

-- Formula-specific information content based on constructor distribution
def formulaEntropy (phi : Formula) : Float :=
  let constructorCounts := countConstructors phi
  let total := constructorCounts.values.sum.toFloat
  constructorCounts.values.foldl (fun acc count =>
    let p := count.toFloat / total
    if p > 0.0 then acc - p * Float.log2 p else acc
  ) 0.0
```

**Rationale**: At complexity 5, only 64 of 1,513 formulas (4.2%) are valid. A valid formula is inherently more "informative" than an invalid one. But among valid formulas, those with unusual constructor distributions are more surprising.

**Pre-computation**: Valid rates by complexity tier can be cached from dataset metadata files.

**Cost**: O(n) for constructor counting, O(1) for lookup.

### Dimension 7: Lemma Utility (LU)

**Intuition**: A formula that frequently appears as a subgoal in other proofs is more useful (and thus more interesting) than an isolated result.

**Definition**: Frequency of the formula (or its subformulas) appearing in the proof_steps dataset.

**Computation**:
```
def lemmaUtility (phi : Formula) (proofSteps : ProofStepDB) : Float :=
  -- Count how many distinct theorem proofs use phi as a subgoal
  let appearances := proofSteps.countGoalAppearances phi
  let totalTheorems := proofSteps.theoremCount
  appearances.toFloat / totalTheorems.toFloat

-- Generalized: subformula utility
def subformulaUtility (phi : Formula) (proofSteps : ProofStepDB) : Float :=
  let subs := phi.subformulas.eraseDups
  subs.map (fun sub => lemmaUtility sub proofSteps) |>.sum / subs.length.toFloat
```

**Implementation**: Build an index from proof_steps.jsonl mapping formula ASTs to the set of theorems where they appear as goals. This index can be pre-computed once.

**Cost**: O(1) lookup after pre-computation, O(|proof_steps| * n) for index building.

### Dimension 8: Countermodel Complexity (CC)

**Intuition**: For invalid formulas, a formula requiring a complex countermodel (many worlds, many time points, complex temporal ordering) is more "almost valid" and thus more interesting than one refuted by a trivial one-world model.

**Definition**: Size and structure of the minimal countermodel.

**Computation**:
```
def countermodelComplexity (cm : SemanticCountermodelSummary) : Nat :=
  cm.worldCount + cm.timeCount + cm.timeConstraints.length

-- For valid formulas, use the decision time as a proxy
def decisionDifficulty (metrics : DifficultyMetrics) : Float :=
  metrics.decisionTimeMs.toFloat
```

**Rationale**: A formula that is invalid but requires 5 worlds and 8 time points to refute is "closer to being a theorem" than one refuted by a single world with one time point. For valid formulas, longer decision times indicate harder-to-discover proofs.

**Cost**: O(1) from pre-computed countermodel data.

---

## 5. Composite Interestingness Score

### 5.1 Weighted Linear Combination

For valid formulas:

```
interestingness(phi) = w_SNT * normalize(semanticNonTriviality(phi))
                     + w_OD  * normalize(operatorDiversity(phi))
                     + w_PDR * normalize(proofDepthRatio(phi))
                     + w_PRD * normalize(proofRuleDiversity(phi))
                     + w_SN  * normalize(structuralNovelty(phi))
                     + w_IC  * normalize(informationContent(phi))
                     + w_LU  * normalize(lemmaUtility(phi))
```

**Recommended initial weights** (tunable via configuration):

| Dimension | Weight | Rationale |
|-----------|--------|-----------|
| SNT (Semantic Non-Triviality) | 0.25 | Strongest signal; trivial formulas should score near 0 |
| OD (Operator Diversity) | 0.15 | Bimodal interaction is central to the logic |
| PDR (Proof Depth Ratio) | 0.15 | Deeper proofs indicate harder/more interesting results |
| PRD (Proof Rule Diversity) | 0.10 | Multi-rule proofs show cross-layer reasoning |
| SN (Structural Novelty) | 0.15 | Novel formulas more valuable for training |
| IC (Information Content) | 0.10 | Surprise factor |
| LU (Lemma Utility) | 0.10 | Practical value for theorem proving |

### 5.2 Normalization

Each dimension is normalized to [0, 1] using the dataset distribution:

```
normalize(x, dimension) = (x - min_d) / (max_d - min_d)
```

where `min_d` and `max_d` are computed from the full dataset for each dimension. Alternatively, use percentile-based normalization for robustness to outliers.

### 5.3 Tier Classification

Map composite scores to human-readable tiers:

| Score Range | Tier | Description |
|-------------|------|-------------|
| 0.0 - 0.1 | trivial | Ex falso, identity, weakening instances |
| 0.1 - 0.3 | routine | Simple substitution instances of axioms |
| 0.3 - 0.5 | modest | Single-step derived results |
| 0.5 - 0.7 | notable | Multi-step proofs with some operator diversity |
| 0.7 - 0.9 | interesting | Novel interactions between modal and temporal operators |
| 0.9 - 1.0 | remarkable | Deep proofs, cross-layer axiom use, high novelty |

### 5.4 Alternative: Multiplicative Gating

For use as a training reward signal, a multiplicative approach may be more effective:

```
reward(phi) = SNT_gate * (w_OD * OD + w_PDR * PDR + w_PRD * PRD + w_SN * SN + w_IC * IC + w_LU * LU)
```

where `SNT_gate` is 0 for trivially valid formulas and 1 otherwise. This ensures trivial theorems receive exactly zero reward regardless of other scores.

---

## 6. The Triviality Spectrum

The task description highlights the spectrum from trivially valid to genuinely interesting. Here is a concrete classification applied to this logic:

### Level 0: Trivially Valid (Score ~ 0.0)
- `bot -> phi` (ex falso): 1,754 of 1,959 valid formulas
- `phi -> (psi -> phi)` (weakening/prop_s): 173 instances
- SNT = 0, OD = 0, PDR = 0

### Level 1: Routine Axiom Instances (Score ~ 0.1-0.2)
- `box phi -> phi` (modal T): 20 instances
- `box phi -> box (box phi)` (modal 4): 8 instances
- SNT = 1, OD = 1, PDR = 0

### Level 2: Simple Derived Results (Score ~ 0.3-0.4)
- `phi -> phi` (identity, SKK construction): Height 4, 2 axioms
- `(A -> B) -> (B -> C) -> (A -> C)` (transitivity): Height ~6
- SNT = 2, OD = 0-1, PDR > 0

### Level 3: Non-Trivial Modal Results (Score ~ 0.5-0.6)
- `diamond (box phi) -> box phi` (S5 collapse): Height ~30
- `box phi -> diamond phi` (T consequence): Uses modal_t + contraposition
- SNT = 2, OD = 2, PRD >= 2

### Level 4: Cross-Modal Theorems (Score ~ 0.7-0.8)
- `box phi -> always phi` (P1 perpetuity): 254 steps, 4 axioms, 3 rule types
- `sometimes phi -> diamond phi` (P2 perpetuity): Similar complexity
- SNT = 3, OD >= 4, PDR > 0.5, PRD >= 3

### Level 5: Deep Bimodal Results (Score ~ 0.9-1.0)
- `diamond (sometimes phi) -> always (diamond phi)` (P5 perpetuity): 327 steps, 8 axioms, 5 rule types
- Theorems mixing Until/Since with Box/Diamond: Novel operator combinations
- SNT = 3, OD >= 5, PDR > 1.0, PRD >= 4, SN > 0.7

---

## 7. Implementation Plan

### Phase 1: Syntactic Metrics (No New Dependencies)

Add to `Theories/Bimodal/Automation/InterestingnessMetrics.lean`:

1. **`semanticNonTriviality`**: Pattern match against known trivial templates
2. **`operatorDiversity`**: Single-pass AST traversal counting operator types
3. **`formulaEntropy`**: Constructor distribution entropy
4. **`operatorProfile`**: Extract which operators appear in a formula

These are pure `Formula -> Nat` or `Formula -> Float` functions requiring no proof infrastructure.

**Estimated effort**: 1-2 implementation phases.

### Phase 2: Proof-Aware Metrics (Extend Existing Infrastructure)

Extend `DatasetGenerator.lean` and `DataExport.lean`:

1. **`proofDepthRatio`**: Already computable from existing `ProofTrace`
2. **`proofRuleDiversity`**: Already computable from existing `ProofTrace`
3. **`axiomLayerDiversity`**: Classify axioms into layers, count distinct layers
4. **`proofRichness`**: Total rule applications normalized by complexity

**Estimated effort**: 1 implementation phase (mostly wiring existing data).

### Phase 3: Cross-Reference Metrics (Requires Index Building)

Build an index from proof_steps.jsonl:

1. **`lemmaUtility`**: Pre-compute formula appearance frequency
2. **`structuralNovelty`**: Subformula overlap with known theorem corpus
3. **`axiomDistance`**: Minimum edit distance to nearest axiom instance

**Estimated effort**: 2 implementation phases (index building + metric computation).

### Phase 4: Composite Score and Dataset Integration

1. Implement `compositeInterestingness` combining all dimensions
2. Add `interestingness_score` and `interestingness_tier` fields to JSONL schema
3. Update dataset generation pipeline to compute metrics for each labeled formula
4. Validate scoring distribution and calibrate weights

**Estimated effort**: 1-2 implementation phases.

### Integration Points

| Component | File | Change |
|-----------|------|--------|
| Metric definitions | `Automation/InterestingnessMetrics.lean` (NEW) | All metric functions |
| LabeledFormula extension | `Automation/DatasetGenerator.lean` | Add `interestingnessScore`, `interestingnessTier` fields |
| JSONL schema | `Automation/DatasetExporter.lean` | Export new fields |
| Proof step index | `Automation/ProofStepIndex.lean` (NEW) | Cross-reference index for lemma utility |
| Dataset metadata | `data/*_metadata.json` | Document new fields |
| Croissant schema | `data/croissant.json` | Add field definitions |

---

## 8. Interaction with Proof Traces

The proof trace is the richest source of interestingness signal. Here is how each trace component contributes:

### 8.1 Proof Height

Currently all training valid formulas have height 0. When proof search produces non-trivial proofs:
- Height 0 = direct axiom match (routine)
- Height 1-5 = simple derived results
- Height 6-20 = moderate reasoning chains
- Height 20-100 = substantial proofs (e.g., propositional combinators)
- Height 100+ = deep theorems (perpetuity principles, S5 collapse)

### 8.2 Axiom Usage Profile

The axiom set spans 4 conceptual layers:
1. **Propositional** (prop_k, prop_s, ex_falso, peirce)
2. **Modal S5** (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
3. **BX Temporal** (20 axiom schemas for Until/Since)
4. **Modal-Temporal Interaction** (modal_future)

A proof using axioms from multiple layers demonstrates genuine cross-system reasoning. The number of layers used correlates strongly with human-perceived interestingness of the named theorems in the codebase.

### 8.3 Rule Application Profile

The `RuleProfile` structure already captures counts of each rule type:
- `axiomCount`: Base cases
- `mpCount`: Logical deduction steps
- `necessitationCount`: Modal reasoning
- `temporalNecessitationCount`: Temporal reasoning
- `temporalDualityCount`: Past-future symmetry exploitation
- `weakeningCount`: Context manipulation

A rich rule profile (high counts across multiple rule types) indicates a proof that exercises many aspects of the logic.

### 8.4 Reconstruction Method

The `proofReconstructionMethod` field already distinguishes:
- `axiom_match` (trivial)
- `derived_match` (slightly less trivial)
- `compositional` (genuine multi-step reasoning)
- `proof_search` (non-obvious proof)
- `tableau_extraction` (decision procedure to proof)

This provides a coarse-grained interestingness signal that can be used as a fast filter.

---

## 9. Addressing the Training Signal Use Case

### 9.1 As a Filtering Criterion

The simplest use: filter training data to exclude trivial examples.

```
-- Minimum threshold for inclusion in training set
def isTrainingWorthy (lf : LabeledFormula) : Bool :=
  lf.interestingnessScore >= 0.2  -- exclude trivially valid
```

This would reduce the current 1,959 valid formulas to a much smaller set (likely ~0 with current data, which underscores the need for richer proof reconstruction).

### 9.2 As a Reward Signal

For reinforcement learning on theorem discovery:

```
reward(action, formula) =
  if formula.label != valid then -0.1          -- penalty for invalid attempts
  else if formula.interestingnessScore < 0.1 then 0.0  -- no reward for trivial
  else formula.interestingnessScore * 10.0      -- scaled reward for interesting
```

### 9.3 As a Curriculum Signal

Sort formulas by interestingness score to create a curriculum:
1. Train on Level 0-1 (learn basic validity)
2. Graduate to Level 2-3 (learn derived reasoning)
3. Finally Level 4-5 (learn deep cross-modal reasoning)

### 9.4 Bootstrapping: Enriching the Dataset

The most impactful intervention is not just scoring existing formulas but generating new interesting ones. The proof_steps.jsonl contains 310 named theorems that can be:
1. Cross-referenced into the training JSONL with their full proof traces
2. Used as seeds for formula mutation (see `FormulaMutator.lean`)
3. Used to define "interesting neighborhoods" in formula space

---

## 10. Recommendations

### Immediate Actions (No New Lean Code)

1. **Cross-reference proof_steps into training data**: The 310 named theorems with rich proof traces are the most interesting examples and are not in the training JSONL. Adding them (with proper interestingness scores) would dramatically improve data quality.

2. **Add interestingness fields to existing JSONL records**: Even with current trivial proofs, the syntactic metrics (SNT, OD, IC) can distinguish between "bot -> box phi" (SNT=0) and "self_accum_until" instances (SNT=2, OD=3).

### Short-Term (1-2 Implementation Tasks)

3. **Implement `InterestingnessMetrics.lean`**: Pure syntactic metrics (Dimensions 1, 2, 6) as Lean functions. These require no proof infrastructure changes.

4. **Extend proof reconstruction**: The current pipeline produces only height-0 proofs for training data. Extending it to produce compositional proofs (using the combinator infrastructure in Theorems/Combinators.lean) for derived results would unlock the proof-aware metrics.

### Medium-Term (2-4 Implementation Tasks)

5. **Build proof-step cross-reference index**: Enable lemma utility computation.

6. **Implement composite scoring and JSONL integration**: Add scores to the dataset pipeline.

7. **Calibrate weights**: Use the 310 named theorems as ground truth for calibrating the composite score (rank correlation between human-assessed importance and computed score).

### Long-Term (Research Direction)

8. **Learn interestingness measures**: Following FERMAT (NeurIPS 2025), use evolutionary or RL methods to discover better interestingness functions, validated against human expert ratings of bimodal logic theorems.

---

## 11. References

1. Colton, S. "Automated Theory Formation in Pure Mathematics." PhD thesis, University of Edinburgh, 2001.
2. Colton, S. "The HR Program for Theorem Generation." In: CADE-18, 2001.
3. Colton, S. & Bundy, A. "On the Notion of Interestingness in Automated Mathematical Discovery." International Journal of Human-Computer Studies, 2000.
4. Johansson, M. et al. "Conjecture Synthesis for Inductive Theories." Journal of Automated Reasoning, 2010.
5. Johansson, M. "Hipster: Integrating Theory Exploration in a Proof Assistant." arXiv:1405.3426, 2014.
6. FERMAT Team. "Learning Interestingness in Automated Mathematical Theory Formation." NeurIPS 2025 Spotlight. arXiv:2511.14778.
7. Jiang, A.Q. et al. "Thor: Wielding Hammers to Integrate Language Models and Automated Theorem Provers." NeurIPS 2022.
8. Kaliszyk, C. et al. "Reinforcement Learning of Theorem Proving." NeurIPS 2018.
9. Kovacs, P. et al. "Considerations on Approaches and Metrics in Automated Theorem Generation/Finding in Geometry." arXiv:2401.11905, 2024.
