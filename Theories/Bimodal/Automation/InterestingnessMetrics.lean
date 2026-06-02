import Bimodal.Syntax
import Bimodal.Automation.DataExport

/-!
# Interestingness Metrics for Theorems and Derivations

This module implements deterministic interestingness metrics for theorems and
derivations in bimodal logic TM, organized as a three-tier scoring architecture:

- **Tier 1 (Syntactic)**: Fast formula-level metrics requiring no proof trace
  (SNT gate, Operator Diversity, Statement Simplicity, Modal-Temporal Interaction)
- **Tier 2 (Proof-Structural)**: Metrics that operate on `ProofData` and `RuleProfile`
  (Proof Depth Ratio, Proof Rule Diversity, Axiom Layer Diversity, Proof Richness,
  Interaction Axiom Dependency)
- **Tier 3 (Composite)**: Weighted combination with multiplicative SNT gate and
  7-tier classification

The composite score serves as a reward signal for neural networks discovering
interesting results. The multiplicative SNT gate ensures trivial formulas
(ex_falso, identity, weakening) receive zero reward.

## References

- Report 01: 8-dimension taxonomy (SNT, OD, PDR, PRD, SN, IC, LU, CC)
- Report 02: Three-tier architecture with domain-specific bonuses (36+ sources)
- Schmidhuber compression progress theory
- SPEED-RL difficulty-based curriculum
-/

set_option autoImplicit false

namespace Bimodal.Automation.InterestingnessMetrics

open Bimodal.Syntax
open Bimodal.Automation.DataExport

/--
Lightweight proof data for interestingness metrics.

This mirrors the fields of `ProofData` (defined in DatasetGenerator.lean)
without creating an import dependency. The `DatasetGenerator` module constructs
`ProofData` from `ProofData` when computing interestingness scores.
-/
structure ProofData where
  /-- Maximum depth of the proof tree. -/
  height : Nat
  /-- Names of axiom schemata used (e.g., "modal_t", "prop_k"). -/
  axioms_used : List String
  /-- Names of inference rules applied (e.g., "modus_ponens", "necessitation"). -/
  rules_applied : List String
  deriving Repr, Inhabited

/-!
## Tier 1: Syntactic Metrics

Pure formula-level metrics that require no proof trace.
-/

/--
Operator profile recording which operator types appear in a formula.

Each field indicates presence of a specific operator type (primitive or derived).
-/
structure OperatorProfile where
  /-- Contains □ (box) operator. -/
  hasBox : Bool
  /-- Contains ◇ (diamond = ¬□¬) operator. -/
  hasDiamond : Bool
  /-- Contains U (until) with non-top guard (not derived F/G). -/
  hasUntil : Bool
  /-- Contains S (since) with non-top guard (not derived P/H). -/
  hasSince : Bool
  /-- Contains G (all_future = ¬F¬ = ¬U(¬φ,⊤)) operator. -/
  hasAllFuture : Bool
  /-- Contains H (all_past = ¬P¬ = ¬S(¬φ,⊤)) operator. -/
  hasAllPast : Bool
  /-- Contains F (some_future = U(φ,⊤)) operator. -/
  hasSomeFuture : Bool
  /-- Contains P (some_past = S(φ,⊤)) operator. -/
  hasSomePast : Bool
  deriving Repr, Inhabited

/-- The empty operator profile (no operators detected). -/
def OperatorProfile.empty : OperatorProfile :=
  { hasBox := false
  , hasDiamond := false
  , hasUntil := false
  , hasSince := false
  , hasAllFuture := false
  , hasAllPast := false
  , hasSomeFuture := false
  , hasSomePast := false }

/-- Merge two operator profiles (union of detected operators). -/
def OperatorProfile.merge (p1 p2 : OperatorProfile) : OperatorProfile :=
  { hasBox := p1.hasBox || p2.hasBox
  , hasDiamond := p1.hasDiamond || p2.hasDiamond
  , hasUntil := p1.hasUntil || p2.hasUntil
  , hasSince := p1.hasSince || p2.hasSince
  , hasAllFuture := p1.hasAllFuture || p2.hasAllFuture
  , hasAllPast := p1.hasAllPast || p2.hasAllPast
  , hasSomeFuture := p1.hasSomeFuture || p2.hasSomeFuture
  , hasSomePast := p1.hasSomePast || p2.hasSomePast }

/-- Check if top (⊤ = ⊥ → ⊥) pattern at AST level. -/
private def isTop : Formula → Bool
  | .imp .bot .bot => true
  | _ => false

/-- Check if negation (¬φ = φ → ⊥) pattern at AST level. -/
private def isNeg : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/--
Extract the operator profile from a formula by recursive AST traversal.

Detects both primitive operators and derived operator patterns:
- `box φ` → hasBox
- `imp (box (imp φ bot)) bot` → hasDiamond (diamond = ¬□¬φ)
- `untl φ (imp bot bot)` → hasSomeFuture (F = U(φ, ⊤))
- `snce φ (imp bot bot)` → hasSomePast (P = S(φ, ⊤))
- `imp (untl (imp φ bot) (imp bot bot)) bot` → hasAllFuture (G = ¬F(¬φ))
- `imp (snce (imp φ bot) (imp bot bot)) bot` → hasAllPast (H = ¬P(¬φ))
- `untl φ ψ` (non-top guard) → hasUntil
- `snce φ ψ` (non-top guard) → hasSince
-/
def extractOperatorProfile : Formula → OperatorProfile
  -- G pattern: ¬F(¬φ) = imp (untl (imp φ bot) (imp bot bot)) bot
  | .imp (.untl (.imp _φ .bot) (.imp .bot .bot)) .bot =>
    let inner := extractOperatorProfile _φ
    { inner with hasAllFuture := true }
  -- H pattern: ¬P(¬φ) = imp (snce (imp φ bot) (imp bot bot)) bot
  | .imp (.snce (.imp _φ .bot) (.imp .bot .bot)) .bot =>
    let inner := extractOperatorProfile _φ
    { inner with hasAllPast := true }
  -- Diamond pattern: ¬□¬φ = imp (box (imp φ bot)) bot
  | .imp (.box (.imp _φ .bot)) .bot =>
    let inner := extractOperatorProfile _φ
    { inner with hasDiamond := true }
  -- F pattern: U(φ, ⊤) = untl φ (imp bot bot)
  | .untl _φ (.imp .bot .bot) =>
    let inner := extractOperatorProfile _φ
    { inner with hasSomeFuture := true }
  -- P pattern: S(φ, ⊤) = snce φ (imp bot bot)
  | .snce _φ (.imp .bot .bot) =>
    let inner := extractOperatorProfile _φ
    { inner with hasSomePast := true }
  -- Primitive box
  | .box φ =>
    let inner := extractOperatorProfile φ
    { inner with hasBox := true }
  -- Primitive until (non-top guard)
  | .untl φ ψ =>
    let p1 := extractOperatorProfile φ
    let p2 := extractOperatorProfile ψ
    { p1.merge p2 with hasUntil := true }
  -- Primitive since (non-top guard)
  | .snce φ ψ =>
    let p1 := extractOperatorProfile φ
    let p2 := extractOperatorProfile ψ
    { p1.merge p2 with hasSince := true }
  -- Implication: recurse into both sides
  | .imp φ ψ =>
    (extractOperatorProfile φ).merge (extractOperatorProfile ψ)
  -- Atoms and bot have no operators
  | .atom _ => OperatorProfile.empty
  | .bot => OperatorProfile.empty

/-- Count how many distinct operator types are present in a profile. -/
def OperatorProfile.distinctCount (p : OperatorProfile) : Nat :=
  (if p.hasBox then 1 else 0) +
  (if p.hasDiamond then 1 else 0) +
  (if p.hasUntil then 1 else 0) +
  (if p.hasSince then 1 else 0) +
  (if p.hasAllFuture then 1 else 0) +
  (if p.hasAllPast then 1 else 0) +
  (if p.hasSomeFuture then 1 else 0) +
  (if p.hasSomePast then 1 else 0)

/-- Whether the profile includes any modal operator (box or diamond). -/
def OperatorProfile.hasModal (p : OperatorProfile) : Bool :=
  p.hasBox || p.hasDiamond

/-- Whether the profile includes any temporal operator. -/
def OperatorProfile.hasTemporal (p : OperatorProfile) : Bool :=
  p.hasUntil || p.hasSince || p.hasAllFuture || p.hasAllPast ||
  p.hasSomeFuture || p.hasSomePast

/-- Whether the profile includes any future temporal operator. -/
def OperatorProfile.hasFuture (p : OperatorProfile) : Bool :=
  p.hasUntil || p.hasAllFuture || p.hasSomeFuture

/-- Whether the profile includes any past temporal operator. -/
def OperatorProfile.hasPast (p : OperatorProfile) : Bool :=
  p.hasSince || p.hasAllPast || p.hasSomePast

/--
Operator diversity score for a formula.

Counts distinct operator types with bonuses:
- Base count: number of distinct operators (0-8)
- Cross-modal bonus (+2): if both modal (□/◇) and temporal operators present
- Bidirectional bonus (+1): if both future and past temporal operators present

Returns a Nat score.
-/
def operatorDiversity (φ : Formula) : Nat :=
  let profile := extractOperatorProfile φ
  let baseCount := profile.distinctCount
  let crossModalBonus := if profile.hasModal && profile.hasTemporal then 2 else 0
  let bidirectionalBonus := if profile.hasFuture && profile.hasPast then 1 else 0
  baseCount + crossModalBonus + bidirectionalBonus

/--
Semantic non-triviality score for a formula.

Returns:
- 0: Trivially valid patterns (ex_falso: ⊥ → φ, identity: φ → φ,
     weakening: φ → (ψ → φ), top-implication: φ → ⊤)
- 1: Purely propositional (modalDepth = 0 and temporalDepth = 0)
- 2: Modal-only or temporal-only (uses one modality type)
- 3: Genuinely bimodal (uses both modal and temporal operators)
-/
def semanticNonTriviality (φ : Formula) : Nat :=
  -- Check for trivially valid patterns
  match φ with
  -- ex_falso: ⊥ → anything
  | .imp .bot _ => 0
  -- implications: check for identity, weakening, top-implication
  | .imp a b =>
    -- identity: φ → φ
    if a == b then 0
    -- top-implication: φ → ⊤ (= φ → (⊥ → ⊥))
    else if isTop b then 0
    else match b with
    -- weakening: φ → (ψ → φ)
    | .imp _ c => if a == c then 0 else classifyByOperators φ
    | _ => classifyByOperators φ
  | _ => classifyByOperators φ
where
  /-- Classify non-trivial formula by operator usage. -/
  classifyByOperators (φ : Formula) : Nat :=
    let profile := extractOperatorProfile φ
    if profile.hasModal && profile.hasTemporal then 3
    else if profile.hasModal || profile.hasTemporal then 2
    else if φ.modalDepth == 0 && φ.temporalDepth == 0 then 1
    else 2  -- fallback for edge cases

/--
Statement simplicity score: ratio of atom count to complexity.

Higher values indicate a simpler statement relative to its size
(more atoms vs. structural complexity). Formulas with many nested
operators but few atoms are structurally complex; formulas with
many atoms but simple structure are compositionally simple.

Returns atomCount * 100 / complexity (scaled to avoid Float).
Returns 0 if complexity is 0.
-/
def statementSimplicity (φ : Formula) : Nat :=
  let c := φ.complexity
  if c == 0 then 0
  else φ.atoms.card * 100 / c

/--
Detect whether a formula uses both modal (□/◇) and temporal
(U/S or derived G/H/F/P) operators.

This is a key indicator of genuine bimodal interaction.
-/
def modalTemporalInteraction (φ : Formula) : Bool :=
  let profile := extractOperatorProfile φ
  profile.hasModal && profile.hasTemporal

/-!
## Tier 2: Proof-Structural Metrics

Metrics that operate on existing `ProofData` and `RuleProfile` structures.
-/

/--
Proof depth ratio: height / complexity.

A high ratio indicates the proof is deep relative to formula size,
suggesting non-trivial reasoning. Returns height * 100 / complexity
(scaled to avoid Float). Returns 0 if complexity is 0.
-/
def proofDepthRatio (pt : ProofData) (φ : Formula) : Nat :=
  let c := φ.complexity
  if c == 0 then 0
  else pt.height * 100 / c

/--
Proof rule diversity: count of distinct inference rules applied.
-/
def proofRuleDiversity (pt : ProofData) : Nat :=
  pt.rules_applied.eraseDups.length

/--
Classify an axiom name into one of 4 layers.

Layer classification follows the axiom organization in `extractAxiomName`:
- "propositional": prop_k, prop_s, ex_falso, peirce
- "modal": modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
- "temporal": serial_*, left_mono_*, right_mono_*, connect_*, enrichment_*,
  self_accum_*, absorb_*, linear_*, until_F, since_P, temp_linearity*,
  F_until_equiv, P_since_equiv, discrete_*, prior_*, z1, density, dense_indicator
- "interaction": modal_future
-/
def classifyAxiomLayer (name : String) : String :=
  if name == "prop_k" || name == "prop_s" || name == "ex_falso" || name == "peirce" then
    "propositional"
  else if name == "modal_t" || name == "modal_4" || name == "modal_b" ||
          name == "modal_5_collapse" || name == "modal_k_dist" then
    "modal"
  else if name == "modal_future" then
    "interaction"
  else
    -- All remaining axioms are temporal (BX, uniformity, Prior, Z1, density, discrete)
    "temporal"

/--
Axiom layer diversity: count of distinct axiom layers used in a proof trace.

Maximum possible value is 4 (propositional, modal, temporal, interaction).
-/
def axiomLayerDiversity (pt : ProofData) : Nat :=
  let layers := pt.axioms_used.map classifyAxiomLayer |>.eraseDups
  layers.length

/--
Proof richness: ratio of non-axiom rule applications to formula complexity.

Measures how much inferential work is done relative to formula size.
High values indicate dense proofs with many rule applications.

Returns total non-axiom rules * 100 / complexity (scaled to avoid Float).
Returns 0 if complexity is 0.
-/
def proofRichness (rp : RuleProfile) (φ : Formula) : Nat :=
  let c := φ.complexity
  if c == 0 then 0
  else
    let totalNonAxiom := rp.mpCount + rp.necessitationCount +
      rp.temporalNecessitationCount + rp.temporalDualityCount +
      rp.weakeningCount + rp.assumptionCount
    totalNonAxiom * 100 / c

/--
Interaction axiom dependency: whether the proof uses the modal_future axiom,
the sole bridge principle connecting modal and temporal reasoning in TM.

Proofs requiring this axiom exhibit genuine cross-modal interaction.
-/
def interactionAxiomDependency (pt : ProofData) : Bool :=
  pt.axioms_used.any (· == "modal_future")

/-!
## Tier 3: Composite Score and Tier Classification
-/

/--
Configurable weights for each interestingness dimension.

Default weights are calibrated based on research recommendations:
- SNT gate weight is implicit (multiplicative, not additive)
- Higher weights for cross-modal metrics (OD, ALD) since genuine
  bimodal interaction is the most interesting feature
-/
structure InterestingnessWeights where
  /-- Weight for Operator Diversity (normalized to 0-11 scale). -/
  w_OD : Nat := 25
  /-- Weight for Proof Depth Ratio. -/
  w_PDR : Nat := 15
  /-- Weight for Proof Rule Diversity. -/
  w_PRD : Nat := 10
  /-- Weight for Axiom Layer Diversity (max 4). -/
  w_ALD : Nat := 20
  /-- Weight for Interaction Axiom Dependency (0 or 1). -/
  w_IAD : Nat := 15
  /-- Weight for Statement Simplicity. -/
  w_SS : Nat := 5
  /-- Weight for Proof Richness. -/
  w_PR : Nat := 10
  deriving Repr, Inhabited

/-- Default interestingness weights. -/
def InterestingnessWeights.default : InterestingnessWeights := {}

/--
Interestingness tier classification.

7 tiers from trivial (score 0.00-0.05) to remarkable (score 0.85-1.00).
-/
inductive InterestingnessTier where
  | trivial     -- 0.00 - 0.05
  | routine     -- 0.05 - 0.15
  | basic       -- 0.15 - 0.30
  | moderate    -- 0.30 - 0.50
  | notable     -- 0.50 - 0.70
  | interesting -- 0.70 - 0.85
  | remarkable  -- 0.85 - 1.00
  deriving Repr, DecidableEq, BEq, Inhabited

/--
Classify a score (0-1000 scale, i.e. score * 1000) into a tier.

Score boundaries (on 1000 scale):
- trivial:     0 - 50
- routine:     50 - 150
- basic:       150 - 300
- moderate:    300 - 500
- notable:     500 - 700
- interesting: 700 - 850
- remarkable:  850 - 1000
-/
def InterestingnessTier.fromScore (score1000 : Nat) : InterestingnessTier :=
  if score1000 < 50 then .trivial
  else if score1000 < 150 then .routine
  else if score1000 < 300 then .basic
  else if score1000 < 500 then .moderate
  else if score1000 < 700 then .notable
  else if score1000 < 850 then .interesting
  else .remarkable

/-- Convert an interestingness tier to a human-readable string. -/
def InterestingnessTier.toString : InterestingnessTier → String
  | .trivial => "trivial"
  | .routine => "routine"
  | .basic => "basic"
  | .moderate => "moderate"
  | .notable => "notable"
  | .interesting => "interesting"
  | .remarkable => "remarkable"

instance : ToString InterestingnessTier := ⟨InterestingnessTier.toString⟩

/--
Complete interestingness result holding the composite score, tier classification,
individual dimension scores, and the SNT gate value.
-/
structure InterestingnessResult where
  /-- Composite interestingness score on 0-1000 scale. -/
  compositeScore : Nat
  /-- Tier classification derived from composite score. -/
  tier : InterestingnessTier
  /-- Semantic non-triviality gate value (0, 1, 2, or 3). -/
  sntGate : Nat
  /-- Operator diversity raw score. -/
  operatorDiversity : Nat
  /-- Proof depth ratio (scaled by 100). -/
  proofDepthRatio : Nat
  /-- Proof rule diversity count. -/
  proofRuleDiversity : Nat
  /-- Axiom layer diversity count (0-4). -/
  axiomLayerDiversity : Nat
  /-- Whether proof uses interaction axiom (modal_future). -/
  interactionAxiomDep : Bool
  /-- Statement simplicity (scaled by 100). -/
  statementSimplicity : Nat
  /-- Proof richness (scaled by 100). -/
  proofRichness : Nat
  deriving Repr, Inhabited

/--
Compute the composite interestingness score for a formula with optional proof data.

The composite score uses multiplicative SNT gating:
- If SNT = 0: score = 0 (trivial formula, zero reward)
- If SNT = 1: gate = 500 (half credit for propositional-only)
- If SNT >= 2: gate = 1000 (full credit for modal/temporal/bimodal)

The gated score is: gate * weightedSum / (1000 * totalWeight)

Each dimension is normalized to roughly 0-1000 scale before weighting:
- OD: raw score * 91 (max ~11 → 1000)
- PDR: raw score * 10 (already scaled by 100, cap at 1000)
- PRD: raw score * 167 (max ~6 → 1000)
- ALD: raw score * 250 (max 4 → 1000)
- IAD: 1000 if true, 0 if false
- SS: raw score * 10 (already scaled by 100, cap at 1000)
- PR: raw score * 10 (already scaled by 100, cap at 1000)
-/
def computeInterestingness (φ : Formula)
    (pt : Option ProofData) (rp : Option RuleProfile)
    (weights : InterestingnessWeights := InterestingnessWeights.default)
    : InterestingnessResult :=
  -- Tier 1: Syntactic metrics
  let snt := semanticNonTriviality φ
  let od := operatorDiversity φ
  let ss := statementSimplicity φ

  -- Tier 2: Proof-structural metrics (0 if no proof data)
  let pdr := match pt with
    | some trace => proofDepthRatio trace φ
    | none => 0
  let prd := match pt with
    | some trace => proofRuleDiversity trace
    | none => 0
  let ald := match pt with
    | some trace => axiomLayerDiversity trace
    | none => 0
  let iad := match pt with
    | some trace => interactionAxiomDependency trace
    | none => false
  let pr := match rp with
    | some profile => proofRichness profile φ
    | none => 0

  -- SNT gate (multiplicative)
  let gate : Nat := if snt == 0 then 0
    else if snt == 1 then 500
    else 1000

  -- Normalize dimensions to 0-1000 scale
  let odNorm := min (od * 91) 1000
  let pdrNorm := min (pdr * 10) 1000
  let prdNorm := min (prd * 167) 1000
  let aldNorm := min (ald * 250) 1000
  let iadNorm : Nat := if iad then 1000 else 0
  let ssNorm := min (ss * 10) 1000
  let prNorm := min (pr * 10) 1000

  -- Weighted sum
  let weightedSum := odNorm * weights.w_OD + pdrNorm * weights.w_PDR +
    prdNorm * weights.w_PRD + aldNorm * weights.w_ALD +
    iadNorm * weights.w_IAD + ssNorm * weights.w_SS +
    prNorm * weights.w_PR
  let totalWeight := weights.w_OD + weights.w_PDR + weights.w_PRD +
    weights.w_ALD + weights.w_IAD + weights.w_SS + weights.w_PR

  -- Composite score = gate * weightedSum / (1000 * totalWeight)
  let compositeScore := if totalWeight == 0 then 0
    else gate * weightedSum / (1000 * totalWeight)

  let tier := InterestingnessTier.fromScore compositeScore

  { compositeScore := compositeScore
  , tier := tier
  , sntGate := snt
  , operatorDiversity := od
  , proofDepthRatio := pdr
  , proofRuleDiversity := prd
  , axiomLayerDiversity := ald
  , interactionAxiomDep := iad
  , statementSimplicity := ss
  , proofRichness := pr }

/-!
## JSON Serialization
-/

/--
Serialize an `InterestingnessResult` to a JSON object string.

Example output:
```json
{"composite_score": 450, "tier": "moderate", "snt_gate": 3,
 "operator_diversity": 5, "proof_depth_ratio": 200, "proof_rule_diversity": 3,
 "axiom_layer_diversity": 2, "interaction_axiom_dep": false,
 "statement_simplicity": 33, "proof_richness": 150}
```
-/
def InterestingnessResult.toJson (r : InterestingnessResult) : String :=
  "{\"composite_score\": " ++ toString r.compositeScore
  ++ ", \"tier\": \"" ++ r.tier.toString ++ "\""
  ++ ", \"snt_gate\": " ++ toString r.sntGate
  ++ ", \"operator_diversity\": " ++ toString r.operatorDiversity
  ++ ", \"proof_depth_ratio\": " ++ toString r.proofDepthRatio
  ++ ", \"proof_rule_diversity\": " ++ toString r.proofRuleDiversity
  ++ ", \"axiom_layer_diversity\": " ++ toString r.axiomLayerDiversity
  ++ ", \"interaction_axiom_dep\": " ++ (if r.interactionAxiomDep then "true" else "false")
  ++ ", \"statement_simplicity\": " ++ toString r.statementSimplicity
  ++ ", \"proof_richness\": " ++ toString r.proofRichness
  ++ "}"

end Bimodal.Automation.InterestingnessMetrics
