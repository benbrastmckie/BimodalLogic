# Research Report: Contrastive Pair Generation for Dual-Verification Training Signal

**Task**: 206 - contrastive_pair_generation
**Session**: sess_1780086634_3ce58a
**Date**: 2026-05-29

## 1. Formula AST Structure

### 1.1 The `Formula` Inductive Type

**File**: `Theories/Bimodal/Syntax/Formula.lean` (lines 70-85)

The formula type has 6 primitive constructors:

```lean
inductive Formula : Type where
  | atom : Atom → Formula          -- Propositional atom
  | bot : Formula                   -- Bottom (falsity)
  | imp : Formula → Formula → Formula  -- Implication
  | box : Formula → Formula         -- Modal necessity (□)
  | untl : Formula → Formula → Formula -- Until U(event, guard)
  | snce : Formula → Formula → Formula -- Since S(event, guard)
  deriving Repr, DecidableEq, BEq, Hashable, Countable
```

All other connectives are derived:
- **Negation**: `neg φ = φ.imp bot`
- **Conjunction**: `and φ ψ = (φ.imp ψ.neg).neg`
- **Disjunction**: `or φ ψ = φ.neg.imp ψ`
- **Diamond**: `diamond φ = φ.neg.box.neg`
- **Top**: `top = bot.imp bot`
- **G (all_future)**: `all_future φ = (some_future φ.neg).neg` where `some_future φ = untl φ top`
- **H (all_past)**: `all_past φ = (some_past φ.neg).neg` where `some_past φ = snce φ top`
- **F (some_future)**: `some_future φ = untl φ top`
- **P (some_past)**: `some_past φ = snce φ top`
- **Next**: `next φ = untl φ bot`
- **Prev**: `prev φ = snce φ bot`
- **Always**: `always φ = φ.all_past.and (φ.and φ.all_future)`
- **Sometimes**: `sometimes φ = φ.neg.always.neg`

### 1.2 The `Atom` Type

**File**: `Theories/Bimodal/Syntax/Atom.lean` (lines 69-74)

```lean
structure Atom where
  base : String
  fresh_index : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable
```

Atoms support freshness via the optional index. Typical atoms: `Atom.mk_base "p"`, `Atom.mk_base "q"`, etc. The `Formula.atoms` function returns a `Finset Atom` of all atoms in a formula.

### 1.3 Key Structural Functions

Already available in `Formula.lean`:
- `complexity : Formula -> Nat` -- connective count + 1
- `modalDepth : Formula -> Nat` -- max box nesting
- `temporalDepth : Formula -> Nat` -- max untl/snce nesting
- `countImplications : Formula -> Nat` -- implication count
- `atoms : Formula -> Finset Atom` -- set of atoms
- `subformulas : Formula -> List Formula` -- all subformulas (in `Subformulas.lean`)
- `swap_temporal : Formula -> Formula` -- temporal duality (untl <-> snce)
- `swap_temporal_involution` -- swap is its own inverse

### 1.4 Implications for Mutation Implementation

Since all operators are derived from 6 primitives, mutations must operate at the primitive level. For example:
- "Weaken box to diamond" = replace `box φ` with `(neg (box (neg φ)))`
- "Weaken G to F" = replace `neg (imp (untl (imp φ bot) top) bot)` with `untl φ top`

**Recommendation**: Define mutations by pattern-matching on the 6 constructors, not on derived forms. The derived forms (G, H, F, P) are just syntactic sugar over `imp`, `bot`, `untl`, `snce`.

## 2. Existing Mutation Infrastructure

### 2.1 `swap_temporal` (Already Exists)

**File**: `Theories/Bimodal/Syntax/Formula.lean` (lines 409-416)

```lean
def swap_temporal : Formula → Formula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swap_temporal ψ.swap_temporal
  | box φ => box φ.swap_temporal
  | untl φ ψ => snce φ.swap_temporal ψ.swap_temporal
  | snce φ ψ => untl φ.swap_temporal ψ.swap_temporal
```

This swaps `untl <-> snce` recursively. It is an involution (swap . swap = id). Proved properties:
- `swap_temporal_involution`: swap is self-inverse
- `swap_temporal_diamond`: distributes over diamond
- `swap_temporal_neg`: distributes over negation
- `swap_temporal_some_future`/`some_past`: exchanges F <-> P
- `swap_temporal_all_future`/`all_past`: exchanges G <-> H
- `swap_temporal_next`/`prev`: exchanges X <-> Y
- `atoms_swap_temporal`: preserves atom set

**Important semantic note**: `swap_temporal` preserves validity in the Base frame class (proved in `Separation/Duality.lean`). Invalid formulas may or may not produce invalid duals.

### 2.2 `subst_formula` (Already Exists)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` (lines 30-40)

```lean
def subst_formula (phi : Formula) (target : Atom) (replacement : Formula) : Formula
```

Substitutes a formula for an atom throughout a formula. Has a correctness theorem (`subst_correctness`). This can be directly used for the "atom substitution with bot" mutation.

### 2.3 `enrichWithDuals` (Already Exists)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean` (lines 617-621)

```lean
def enrichWithDuals (formulas : List Formula) : List Formula :=
  let withDuals := formulas.flatMap fun φ =>
    let dual := φ.swap_temporal
    if dual == φ then [φ] else [φ, dual]
  withDuals.eraseDups
```

This already produces temporal duality pairs for formulas with temporal content.

### 2.4 No Existing `FormulaMutator` Module

There is no dedicated mutation module in `Automation/`. The task requires creating a new `FormulaMutator.lean` file.

## 3. Decision Procedure

### 3.1 Architecture

**File**: `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`

The decision procedure is structured as:

```lean
inductive DecisionResult (φ : Formula) : Type where
  | valid (proof : ⊢ φ)
  | invalid (counter : SimpleCountermodel)
  | timeout
```

Three entry points:
1. **`decide φ searchDepth tableauFuel`**: Main procedure (axiom check -> proof search -> tableau)
2. **`decideAuto φ`**: Auto-fuel based on complexity
3. **`decideOptimized φ`**: IDDFS first, then full decision

### 3.2 Programmatic Invocation

The existing `labelFormula` function in `DatasetGenerator.lean` (lines 258-316) shows the pattern:

```lean
def labelFormula (φ : Formula) : IO LabeledFormula := do
  let startTime ← IO.monoMsNow
  let result := decideAuto φ
  ...
  match result with
  | .valid proof => ...   -- extract ProofTrace
  | .invalid cm => ...    -- SimpleCountermodel available
  | .timeout => ...       -- retry with decideOptimized
```

This pattern is directly reusable for contrastive pair generation.

### 3.3 Countermodel Extraction

**File**: `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`

```lean
structure SimpleCountermodel where
  trueAtoms : List Atom
  falseAtoms : List Atom
  formula : Formula
```

Simple countermodels capture atom-level truth assignments. For richer countermodels:

**File**: `Theories/Bimodal/Automation/EnrichedCountermodel.lean`

```lean
structure EnrichedCountermodel where
  simple : SimpleCountermodel
  branchFormulas : List SignedFormula
  modalFormulas : List SignedFormula
  temporalFormulas : List SignedFormula
  branchLength : Nat
```

Enriched countermodels additionally capture modal and temporal formulas from the saturated tableau branch, providing richer corrective signal.

### 3.4 Performance Considerations

- `decideAuto` uses `recommendedFuel φ` based on formula complexity
- Typical formulas at complexity <= 12 decide in milliseconds
- Wall-clock timing is already built into `labelFormula`
- For batch mutations of thousands of formulas, the existing `labelBatch` pattern with progress reporting works well
- Timeout rate at complexity <= 5 is typically < 20%

## 4. Dataset Export Pipeline

### 4.1 Existing JSONL Format

**File**: `Theories/Bimodal/Automation/DatasetExport.lean`

The `DatasetRecord` structure (lines 157-179) includes:
- `id`, `split`, `formula_str`, `formula_ast`, `frame_class`
- `label` (valid/invalid/timeout)
- `proof_trace` (Option ProofTrace)
- `countermodel` (Option SimpleCountermodel)
- `pattern_key`, `metrics`
- `augmentation` (Option AugmentationInfo)

### 4.2 `AugmentationInfo` (Already Exists)

```lean
structure AugmentationInfo where
  source : String
  originalFormulaStr : Option String
```

This can be extended or a parallel structure created for contrastive pairs.

### 4.3 JSON Serialization Primitives

All necessary serialization is in `DataExport.lean`:
- `Formula.toJson` -- recursive JSON AST
- `Formula.prettyPrint` -- human-readable string
- `SimpleCountermodel.toJson`
- `escapeJsonString`, `listToJsonArray`

And in `EnrichedCountermodel.lean`:
- `EnrichedCountermodel.toJson`
- `SignedFormula.toJson`

### 4.4 Integration Strategy for Contrastive Pairs

The contrastive pair output should extend the existing pipeline. Two approaches:

**Option A: Extend DatasetRecord** -- Add fields for contrastive data:
```lean
structure ContrastiveRecord where
  original : DatasetRecord
  mutation : DatasetRecord
  mutationType : String
  countermodel : Option EnrichedCountermodel
```

**Option B: Standalone JSONL** -- New JSONL format alongside existing:
```json
{
  "original_formula": "...",
  "mutated_formula": "...",
  "mutation_type": "atom_sub_bot",
  "original_label": "valid",
  "mutated_label": "invalid",
  "countermodel": {...},
  "enriched_countermodel": {...}
}
```

**Recommendation**: Option B is cleaner -- separate JSONL file for contrastive pairs, avoiding schema changes to the existing pipeline. The `FormulaMutator` module produces `ContrastivePair` records that get serialized independently.

## 5. Mutation Strategies

### 5.1 Atom Substitution with Bot

Replace a propositional atom with `Formula.bot` (falsity).

**Implementation**: Use the existing `subst_formula` from `FormulaOps.lean`:
```lean
def mutate_atom_to_bot (φ : Formula) (target : Atom) : Formula :=
  Separation.subst_formula φ target Formula.bot
```

For each atom `a` in `φ.atoms`, generate one mutation. This produces `|φ.atoms|` mutations per formula.

**Validity impact**: Almost always breaks validity for non-trivial formulas. If `φ` mentions atom `p` essentially (not vacuously), replacing `p` with `bot` collapses the formula.

**Note**: The `subst_formula` function lives in the `Bimodal.Metalogic.WeakCanonical.Separation` namespace. The new `FormulaMutator` module should either import it or re-implement a simpler version to avoid pulling in the full Separation dependency chain.

### 5.2 Operator Weakening: Box to Diamond

Replace `box φ` with `diamond φ` (i.e., `φ.neg.box.neg`).

**Implementation**:
```lean
def weaken_box_to_diamond : Formula → Formula
  | .box φ => φ.diamond
  | .imp φ ψ => .imp (weaken_box_to_diamond φ) (weaken_box_to_diamond ψ)
  | .untl φ ψ => .untl (weaken_box_to_diamond φ) (weaken_box_to_diamond ψ)
  | .snce φ ψ => .snce (weaken_box_to_diamond φ) (weaken_box_to_diamond ψ)
  | φ => φ
```

**Validity impact**: Weakens necessity to possibility. For modal axioms like T (□p -> p), replacing □ with ◇ gives (◇p -> p), which is not valid.

### 5.3 Operator Weakening: G to F / H to P

Since G and H are derived operators:
- `all_future φ = (some_future φ.neg).neg`
- `all_past φ = (some_past φ.neg).neg`

The weakening G->F means replacing "for all future times" with "for some future time". At the primitive level, this involves recognizing the encoding pattern.

**Implementation approach**: Pattern-match on the primitive encoding:
```lean
-- G(φ) = neg(F(neg(φ))) = imp (untl (imp φ bot) top) bot
-- F(φ) = untl φ top
-- So weakening G to F replaces the double negation pattern
def weaken_all_to_some : Formula → Formula
  | .imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot =>
    -- This is G(inner) = neg(F(neg(inner))), weaken to F(inner)
    Formula.some_future inner
  | .imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot =>
    -- This is H(inner), weaken to P(inner)
    Formula.some_past inner
  | .imp φ ψ => .imp (weaken_all_to_some φ) (weaken_all_to_some ψ)
  | .box φ => .box (weaken_all_to_some φ)
  | .untl φ ψ => .untl (weaken_all_to_some φ) (weaken_all_to_some ψ)
  | .snce φ ψ => .snce (weaken_all_to_some φ) (weaken_all_to_some ψ)
  | φ => φ
```

**Alternative approach** (simpler): Rather than recognizing derived patterns, just define a general "weaken temporal universal" that replaces `untl` with `snce` in targeted subformulas. But this is essentially `swap_temporal` which preserves validity. The key insight is that G->F weakening requires recognizing the derived operator encoding.

**Recommendation**: Implement a helper `isAllFuture : Formula -> Option Formula` that checks if a formula matches the G encoding pattern, and similarly `isAllPast`. Then apply targeted replacement.

### 5.4 Subformula Deletion

Replace subformulas with `top` (for positive positions) or `bot` (for negative positions).

**Implementation**: Use the existing `subformulas` function to enumerate targets:
```lean
def delete_subformula (φ : Formula) (target : Formula) (replacement : Formula) : Formula :=
  if φ == target then replacement
  else match φ with
  | .imp a b => .imp (delete_subformula a target replacement) (delete_subformula b target replacement)
  | .box a => .box (delete_subformula a target replacement)
  | .untl a b => .untl (delete_subformula a target replacement) (delete_subformula b target replacement)
  | .snce a b => .snce (delete_subformula a target replacement) (delete_subformula b target replacement)
  | φ => φ
```

For each proper subformula of `φ`, generate a mutation. Replace with `top` (vacuous truth) or `bot` (falsity). Both are interesting:
- Replacing with `top` simplifies the formula
- Replacing with `bot` makes parts trivially false

### 5.5 Depth Reduction

Reduce nesting depth of modal/temporal operators by stripping one layer.

**Implementation**:
```lean
-- Strip outermost box: □φ -> φ
def reduce_modal_depth : Formula → Formula
  | .box φ => φ
  | .imp φ ψ => .imp (reduce_modal_depth φ) (reduce_modal_depth ψ)
  | .untl φ ψ => .untl (reduce_modal_depth φ) (reduce_modal_depth ψ)
  | .snce φ ψ => .snce (reduce_modal_depth φ) (reduce_modal_depth ψ)
  | φ => φ

-- Strip outermost temporal: U(φ,ψ) -> φ, S(φ,ψ) -> φ
def reduce_temporal_depth : Formula → Formula
  | .untl φ _ => φ
  | .snce φ _ => φ
  | .imp φ ψ => .imp (reduce_temporal_depth φ) (reduce_temporal_depth ψ)
  | .box φ => .box (reduce_temporal_depth φ)
  | φ => φ
```

**Validity impact**: Removing modal/temporal operators generally breaks validity for non-propositional theorems.

### 5.6 Temporal Duality via `swap_temporal`

Already implemented. Key consideration: `swap_temporal` **preserves** validity for theorems of the Base frame class. So:
- Valid formula phi -> swap_temporal phi is also valid (not a contrastive pair in the usual sense)
- Invalid formula phi -> swap_temporal phi may be valid or invalid (interesting contrastive case)

For the contrastive training signal, the task description says "temporal duality contrastive pairs via swap_temporal where the dual has different validity." This means:
1. Take invalid formulas
2. Apply swap_temporal
3. Re-run decision procedure
4. Keep pairs where `label(phi) != label(swap_temporal(phi))`

These are genuinely interesting because they show that temporal direction matters for validity.

## 6. Countermodel Representation and Serialization

### 6.1 SimpleCountermodel

- Captures atom-level truth values (which atoms true, which false)
- Already has `toJson` serialization
- Already has `display` for human-readable output
- Has `isConsistent` check

### 6.2 EnrichedCountermodel

- Extends SimpleCountermodel with full branch information
- Captures modal and temporal formulas from saturated tableau
- Already has `toJson` serialization
- Provides richer corrective signal for training

### 6.3 Recommendations for Contrastive Pairs

Use `EnrichedCountermodel` for the `countermodel` field in contrastive pair records. The enriched data tells the model *why* the mutation broke validity, not just *what* atoms flip.

For the enriched countermodel extraction, use `findEnrichedCountermodel` from `EnrichedCountermodel.lean`:
```lean
def findEnrichedCountermodel (φ : Formula) (fuel : Nat := 1000)
    : EnrichedCountermodelResult φ
```

## 7. Recommended Architecture

### 7.1 Module Structure

Create a single new file: `Theories/Bimodal/Automation/FormulaMutator.lean`

```
Theories/Bimodal/Automation/FormulaMutator.lean
  imports:
    - Bimodal.Syntax
    - Bimodal.Automation.DatasetGenerator  (for labelFormula, LabeledFormula)
    - Bimodal.Automation.EnrichedCountermodel  (for enriched countermodels)
    - Bimodal.Automation.DataExport  (for JSON serialization)
```

### 7.2 Core Types

```lean
/-- Type of mutation applied to a formula. -/
inductive MutationType where
  | atomSubBot (atom : Atom)        -- Replace atom with bot
  | boxToDiamond                     -- Weaken □ to ◇
  | allFutureToSomeFuture           -- Weaken G to F
  | allPastToSomePast               -- Weaken H to P
  | subformulaDeletion (target : Formula) (replacement : Formula)
  | modalDepthReduction             -- Strip outermost box
  | temporalDepthReduction          -- Strip outermost untl/snce
  | temporalDuality                 -- swap_temporal

/-- A contrastive pair: (original valid formula, mutated formula, decision result). -/
structure ContrastivePair where
  original : Formula
  originalLabel : FormulaLabel
  mutated : Formula
  mutatedLabel : FormulaLabel
  mutationType : MutationType
  countermodel : Option SimpleCountermodel
  enrichedCountermodel : Option EnrichedCountermodel  -- optional
  originalProofTrace : Option ProofTrace
```

### 7.3 Pipeline Design

```
1. Input: List of LabeledFormula (from existing pipeline)
2. Filter to valid formulas only (or configurable)
3. For each valid formula:
   a. Generate all applicable mutations
   b. Run decideAuto on each mutation
   c. Filter for contrastive pairs (valid->invalid transitions)
   d. Extract countermodel for invalid mutations
4. Optionally: also try swap_temporal on invalid formulas
5. Export as JSONL
```

### 7.4 JSON Output Schema

```json
{
  "id": "contrastive-00001",
  "original": {
    "formula_str": "(□p → p)",
    "formula_ast": {...},
    "label": "valid",
    "proof_trace": {...}
  },
  "mutation": {
    "formula_str": "(◇p → p)",
    "formula_ast": {...},
    "label": "invalid",
    "countermodel": {...},
    "enriched_countermodel": {...}
  },
  "mutation_type": "box_to_diamond",
  "mutation_detail": null
}
```

### 7.5 Integration with Existing Pipeline

The `FormulaMutator` should be usable both:
1. **Standalone**: As a separate executable (add to `lakefile.lean`)
2. **Integrated**: Called from `DatasetExport.main` with a `--contrastive` flag

### 7.6 Dependency Considerations

The `subst_formula` function lives in `Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps`. Importing this pulls in the full Separation module chain. Two options:
1. **Import it**: Accept the dependency (compile time cost, but code reuse)
2. **Reimplement**: Define a local `substAtom` in `FormulaMutator.lean` (trivial 10-line function)

**Recommendation**: Reimplement a local version. The substitution is simple (replace atom with formula recursively), and avoiding the heavy Separation import keeps compile times reasonable.

## 8. Key Implementation Considerations

### 8.1 Recognizing Derived Operators

The G/H operators are encoded as nested imp/untl/snce/bot patterns. Pattern matching must be precise:

```lean
-- G(φ) encodes as:
-- Formula.imp (Formula.untl (Formula.imp φ Formula.bot) (Formula.imp Formula.bot Formula.bot)) Formula.bot
-- Which is: neg(F(neg(φ))) = neg(untl(neg(φ), top)) = imp(untl(imp(φ,bot), imp(bot,bot)), bot)

-- H(φ) encodes as:
-- Formula.imp (Formula.snce (Formula.imp φ Formula.bot) (Formula.imp Formula.bot Formula.bot)) Formula.bot
```

A helper function to detect these patterns would be valuable:
```lean
def matchAllFuture : Formula -> Option Formula
  | .imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot => some inner
  | _ => none

def matchAllPast : Formula -> Option Formula
  | .imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot => some inner
  | _ => none
```

### 8.2 Mutation Yield Estimates

For a formula with:
- `n` atoms: `n` atom-to-bot mutations
- `m` box operators: 1 box-to-diamond mutation (recursive)
- `k` G/H patterns: 1 all-to-some mutation (recursive)
- `s` proper subformulas: `s` deletion mutations (x2 for top/bot replacement)
- 1 modal depth reduction
- 1 temporal depth reduction
- 1 temporal duality (swap_temporal)

Total per formula: roughly `n + s*2 + 5` mutations. For a typical formula with 3 atoms and 5 subformulas, that is about 18 mutations.

### 8.3 Performance Budget

- Decision procedure: ~1ms per formula at complexity <= 5
- 1000 valid formulas * 18 mutations = 18000 decisions = ~18 seconds
- This is very feasible for batch processing

### 8.4 Quality Filtering

Not all mutations produce interesting contrastive pairs:
- Atom-to-bot on a vacuously-mentioned atom may not change validity
- Subformula deletion with top may preserve validity
- Depth reduction on shallow formulas may produce trivial results

**Recommendation**: Filter contrastive pairs by:
1. `original_label != mutated_label` (the pair is actually contrastive)
2. `mutated.complexity >= 3` (the mutation is non-trivial)
3. Exclude timeout results

### 8.5 Zero-Debt Compliance

The implementation is straightforward Lean 4 programming (no proofs needed). The module defines:
- Pure functions for mutations (no sorry risk)
- IO functions for running the decision procedure (wrapping existing infrastructure)
- JSON serialization (string manipulation)

No sorry should be needed anywhere in this module.

## 9. Potential Challenges

### 9.1 Pattern Matching Fragility

The derived operator recognition (G, H, F, P patterns) depends on the exact encoding in `Formula.lean`. If the encoding changes (e.g., `top` is defined differently), the pattern match breaks. Mitigation: Use the existing `top` definition (`imp bot bot`) and add tests.

### 9.2 Mutation-Induced Timeouts

Some mutations may create formulas that are harder for the decision procedure (e.g., removing a box may create a formula the tableau struggles with). Mitigation: Use `decideAuto` with reasonable fuel, accept timeouts as "unknown" and exclude from contrastive pairs.

### 9.3 Uninteresting Mutations

Many mutations of valid formulas will also be valid (e.g., weakening within a valid formula may still be valid if the formula is "robust"). The yield of truly contrastive pairs may be 30-50% of mutations. This is acceptable for training data generation.

### 9.4 Import Chain Weight

The module needs `DecisionProcedure` (via `DatasetGenerator`), `EnrichedCountermodel`, and `DataExport`. These are already compiled for the existing pipeline, so incremental build time should be minimal. But the total import chain includes Mathlib, so initial builds are slow.

## 10. Summary of Findings

| Area | Key Finding |
|------|-------------|
| Formula AST | 6 primitive constructors, all other operators derived. Mutations operate on primitives. |
| Existing infrastructure | `swap_temporal` and `subst_formula` already exist. No dedicated mutator module. |
| Decision procedure | `decideAuto`/`decideOptimized` with `DecisionResult` type. Extracts proofs and countermodels. |
| Countermodels | `SimpleCountermodel` (atom-level) and `EnrichedCountermodel` (full branch) available. |
| Dataset pipeline | JSONL export with `DatasetRecord`. `AugmentationInfo` for tracking provenance. |
| Serialization | All JSON primitives available in `DataExport.lean`. |
| Performance | ~1ms per formula at complexity <= 5. Batch of 18K mutations feasible in ~18 seconds. |
| Key challenge | Pattern-matching derived operators (G, H, F, P) requires precise encoding recognition. |

## 11. Recommended Implementation Plan

### Phase 1: Core Mutation Functions
- Define `MutationType` inductive
- Implement 7 mutation functions (atom_sub_bot, box_to_diamond, all_to_some, subformula_delete, modal_depth_reduce, temporal_depth_reduce, temporal_duality)
- Add derived-operator recognition helpers (matchAllFuture, matchAllPast)

### Phase 2: Contrastive Pair Generation Pipeline
- Define `ContrastivePair` structure
- Implement `generateContrastivePairs : LabeledFormula -> IO (List ContrastivePair)`
- Implement `filterContrastive` (only keep truly contrastive pairs)
- Implement batch processing with progress reporting

### Phase 3: JSON Serialization and Export
- Define `MutationType.toJson`, `ContrastivePair.toJson`
- Implement `writeContrastiveJSONL`
- Add CLI flags to existing `dataset_generator` or create standalone executable

### Phase 4: Integration and Validation
- Add to `lakefile.lean` if standalone executable
- Run on existing dataset to validate yield
- Verify countermodel quality
- Add conformance tests (known valid formulas that should produce known mutations)
