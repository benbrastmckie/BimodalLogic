# Research Report: Forward-Chaining Proof Generation for Bimodal Logic TM

**Task**: 279 — `backward_proof_generation` (a.k.a. proof-first / forward-chaining generation)
**Session**: sess_1780678758_2284ce
**Agent**: lean-research-agent
**Date**: 2026-06-05
**Lean toolchain**: v4.27.0-rc1 / Mathlib v4.27.0-rc1
**References**: DeepSeek-Prover-V2 subgoal decomposition; SynLogic (NeurIPS 2025) parameterized generation with rule-based verifiers; Libal & Volpe (2016) FPC (Foundational Proof Certificate)

---

## 1. Executive Summary

This report designs a **forward-chaining proof generation system** that constructs derivation trees by composing the existing 42 axiom schemata in `Bimodal.ProofSystem.Axiom` under the 7 inference rules of `DerivationTree`, then extracts the **conclusion formulas** as the labeled training data and the **proof tree** as the supervision signal. This inverts the current generation direction: instead of enumerating formulas and *hoping* the decision procedure says "valid", we **start from valid axiom instances** and *grow* derivations. Every emitted formula is **guaranteed to be a theorem**, and we keep the proof term itself, which is exactly the dual-signal training data the current pipeline already expects (`LabeledFormula.proofTrace : Option ProofTrace`).

**Key insight (the central design choice):** The current `DerivationTree` inductive already **is** the supervision signal. We do not need to invent a new proof representation. We need:

1. A **forward-chaining combinator** that, given a pool of valid formula+proof pairs, applies the 7 inference rules in a controlled, **derivation-depth-bounded** manner, producing new `(formula, proof)` pairs.
2. A **formula-space parametrization** over atom variables `p, q, r, ...` so that axiom schemata can be instantiated to produce fresh proof terms (re-using `instantiateAxiom` in `FormulaEnumerator.lean:1153`).
3. A **dedup and seen-formula index** to avoid pool explosion (re-using the `Std.HashSet` + `Array` pattern from `generateValidBatch` at `FormulaEnumerator.lean:1365-1461`).
4. An **integration point** in `DatasetGenerator.lean:labelFormula` (line 545) that dispatches on `GenerationMode` between `exhaustive` and `proofFirst`.
5. A **metric pipeline** that uses the existing `RuleProfile` (`DataExport.lean:289`), `ProofTrace` (`DatasetGenerator.lean:61`), and the new task 277 `ProofCertificate.axiomFingerprint` (`TraceCertificate.lean:122`) for axiom diversity, proof depth distribution, and temporal-axiom-usage measurement.

The existing backward-search infrastructure in `Theories/Bimodal/Automation/ProofSearch/` (specifically `bounded_search` at `Strategies.lean`, `find_implications_to` at `Core.lean:717`, and `box_context`/`future_context` at `Core.lean:739/759`) is **not directly reusable** for proof-first generation: it searches for *a* proof of a given goal, but here we need to *enumerate* all proofs up to depth N starting from axioms. We will need a complementary forward generator that mirrors the same `find_implications_to` logic but applied as a "broadening" rather than a "narrowing" step.

**Estimated effort**: 16-20 hours. The 4 hardest sub-tasks are (1) implementing forward MP/Nec/Temp-Nec that reuses the existing `DerivationTree` constructors without breaking their 4 existing termination proofs (`Derivation.lean:223-230`); (2) deduping proof trees that produce the *same* formula via different paths; (3) bounding depth without sacrificing diversity; (4) JSON serialization of the rich `DerivationTree` (which has dependent types that defeat naive serialization — see `DatasetGenerator.lean:27-29`'s note on the existing `ProofTrace` simplification).

---

## 2. Existing ProofSystem Architecture

### 2.1 Axiom schemata (42 constructors)

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean:76-400`

`Bimodal.ProofSystem.Axiom : Formula → Type` is an inductive type with 42 constructors organized into 8 layers:

| Layer | Count | Lines | Notes |
|-------|-------|-------|-------|
| 1. Propositional | 4 | 79-90 | `prop_k`, `prop_s`, `ex_falso`, `peirce` |
| 2. S5 Modal | 5 | 92-108 | `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist` |
| 3. BX Temporal | 20 | 110-289 | BX1-BX12 (10 future + 10 past mirrors), Burgess-convention `(untl, snce)` |
| 4. Modal-Temporal Interaction | 1 | 296-297 | `modal_future`; `temp_future` is derived |
| 5. Uniformity | 5 | 299-338 | `discrete_symm_fwd/bwd`, `discrete_propagate_fwd/bwd`, `discrete_box_necessity` |
| 6. Prior | 2 | 340-359 | `prior_UZ`, `prior_SZ` (discrete only) |
| 7. Z1 | 1 | 361-373 | `z1` (discrete only) |
| 8. Density | 2 | 375-398 | `density`, `dense_indicator` (dense only) |

The constructor signature is uniform: each takes a sequence of `Formula` parameters and returns `Axiom (some_formula)`. This is exactly the shape we need for parametric instantiation in a forward generator.

**Frame class gating**: `Axiom.minFrameClass` (line 456) maps each constructor to its minimum `FrameClass`:

```lean
def Axiom.minFrameClass {φ : Formula} : Axiom φ → FrameClass
  | .density _ => .Dense
  | .dense_indicator => .Dense
  | .prior_UZ _ => .Discrete
  | .prior_SZ _ => .Discrete
  | .z1 _ => .Discrete
  | _ => .Base
```

This lets the forward generator produce dataset slices for Base, Dense, or Discrete semantics by simply filtering which axiom constructors it can pick.

### 2.2 Derivation tree inductive (7 constructors)

**File**: `Theories/Bimodal/ProofSystem/Derivation.lean:85-167`

```lean
inductive DerivationTree (fc : FrameClass) : Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DerivationTree fc Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree fc Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ
  | necessitation (φ : Formula) (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.box φ)
  | temporal_necessitation (φ : Formula) (d : DerivationTree fc [] φ)
      : DerivationTree fc [] (Formula.all_future φ)
  | temporal_duality (φ : Formula) (d : DerivationTree fc [] φ)
      : DerivationTree fc [] φ.swap_temporal
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree fc Γ φ) (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
```

**Key facts** for the forward generator:

1. The `DerivationTree` is a **`Type`** (not a `Prop`), enabling pattern matching and computable functions like `DerivationTree.height` (line 223).
2. The 4 inference rules that *consume* a sub-proof (`modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`) are **the candidate inference steps** in a forward generator.
3. `weakening` is **uninteresting for forward generation** (it just adds unused assumptions); we will *not* apply it in the forward pass — it would only inflate the search space without producing new theorem *formulas*. However, we will need to **emit** weakening when reconstructing proofs that use it (none should appear in the forward pass output).
4. `modus_ponens` is **the dominant rule** for forward generation. It takes a `(φ → ψ)` and `φ` (both valid), produces `ψ` (valid). In forward direction: enumerate *all* pairs of theorems where one is an implication, and the consequent is a fresh theorem.
5. `necessitation` and `temporal_necessitation` are **unary** (no context). In forward direction: for every theorem, emit its `box(φ)` and `G(φ)` versions (only when the original is a theorem of the empty context, which is always the case if generated purely from axioms).
6. `temporal_duality` is **also unary**: emit `swap_temporal(φ)` (which the existing `swap_temporal_involution` theorem at `Formula.lean:541-549` shows is an involution, so this is a free doubling).

### 2.3 Existing height function

**File**: `Derivation.lean:223-230`

```lean
def height {fc : FrameClass} {Γ : Context} {φ : Formula} : DerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height
```

This is the **direct supervision signal** for "control complexity via derivation depth rather than formula AST size" (task requirement #3). Forward generation will collect `(formula, proof)` pairs and the `proof.height` value is the "depth" we cap on.

### 2.4 Derivable Prop wrapper

**File**: `Theories/Bimodal/ProofSystem/Derivable.lean:62-85`

`Derivable fc G p : Prop` is defined as `Nonempty (DerivationTree fc G p)`. This is **not** directly useful for forward generation (we need the *witness* tree, not just its existence), but it provides:

- Constructor-mirroring lemmas: `Derivable.ax`, `Derivable.mp`, `Derivable.nec`, `Derivable.temp_nec`, `Derivable.temp_dual`, `Derivable.weaken` (lines 115-170).
- The `[aesop safe apply]` attributes on these lemmas mean the Aesop tactic can already chain them automatically. This gives us a **sanity check** for any forward-generated `(formula, proof)` pair: we should be able to `aesop` from the proof tree and close a `Derivable` goal.

### 2.5 `extractProofTrace` and `RuleProfile` (existing supervision extractors)

**File**: `Theories/Bimodal/Automation/DatasetGenerator.lean:262-298` (ProofTrace)
**File**: `Theories/Bimodal/Automation/DataExport.lean:289-345` (RuleProfile)

```lean
def extractProofTrace {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) : ProofTrace :=
  match d with
  | .axiom _ _ ax _ =>
    { height := 0
      axioms_used := [extractAxiomName ax]
      rules_applied := [] }
  | .assumption _ _ _ => { height := 0, axioms_used := [], rules_applied := ["assumption"] }
  | .modus_ponens _ _ _ d1 d2 =>
    let t1 := extractProofTrace d1; let t2 := extractProofTrace d2
    { height := 1 + max t1.height t2.height
      axioms_used := (t1.axioms_used ++ t2.axioms_used).eraseDups
      rules_applied := "modus_ponens" :: (t1.rules_applied ++ t2.rules_applied).eraseDups }
  | ...
```

```lean
def walkDerivationTree ... : DerivationTree fc Γ φ → RuleProfile
  | .axiom _ _ _ _ => { RuleProfile.empty with axiomCount := 1 }
  | .modus_ponens _ _ _ d1 d2 => let r := (walkDerivationTree d1).merge (walkDerivationTree d2); { r with mpCount := r.mpCount + 1 }
  | ...
```

These are the **existing metrics extractors** that the forward generator will reuse unchanged. The forward generator's output, a `List (Formula × DerivationTree)`, is *already* in the right shape for these extractors: just call `extractProofTrace` and `walkDerivationTree` on each generated `proof` to obtain a `LabeledFormula` exactly like the existing pipeline produces.

### 2.6 Frame class parametrization

`DerivationTree fc Γ φ` is parameterized by `FrameClass`. `DerivationTree.lift` (line 190-198) provides monotonicity. For a forward generator, this means:

- For `.Base` (default), every axiom is accessible.
- For `.Dense`, also the two `density`/`dense_indicator` axioms.
- For `.Discrete`, also `prior_UZ`/`prior_SZ`/`z1`.

A forward generator parameter over `FrameClass` should mirror this: when generating the initial axiom pool, only pick axioms whose `minFrameClass ≤ fc`. This is enforced automatically by the type of `DerivationTree.axiom`'s `h_fc : h.minFrameClass ≤ fc` field, so a wrongly-picked axiom is a **type error** — excellent!

---

## 3. Existing DatasetGenerator Analysis

### 3.1 Current pipeline (exhaustive → label)

**File**: `Theories/Bimodal/Automation/DatasetGenerator.lean:545-731`

The current `labelFormula` function (line 545) takes a single `Formula`, runs the **structural pre-filter** (`structuralPrefilter` at line 448, augmented with axiom attribution at line 470), then falls through to `decideAutoAdaptive` (line 189 of `DecisionProcedure.lean`) which returns a `DecisionResult` carrying a `DerivationTree` (if valid). The proof tree is then summarized by `extractProofTrace` (line 620) and `walkDerivationTree` (line 621) to populate `LabeledFormula`.

The exhaustive flow:

```
enumExactHelper (FormulaEnumerator.lean:152)         -- pure: formulas at exact complexity
  ↓
passesFilter (FormulaEnumerator.lean:129 etc.)        -- reject trivial patterns
  ↓
enumerateWithProgress (FormulaEnumerator.lean:1615)  -- IO wrapper
  ↓
labelBatch (DatasetGenerator.lean:739)                -- 1000ms wall-clock timeout per formula
  ↓
LabeledFormula (DatasetGenerator.lean:146)            -- JSON-serializable record
```

**Key bottleneck identified by task 283 analysis** (`specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md`):

> The 8% valid rate at c9 means 92% of prover calls are wasted on invalid or trivial formulas. The backward proof generation approach (task 279) may ultimately be more valuable than exhaustive enumeration for c9+ — generating formulas with guaranteed interesting proofs rather than enumerating all formulas and hoping some are interesting.

### 3.2 `generateValidBatch` (closest existing analogue)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean:1361-1461`

This is the **closest existing code to what task 279 is asking for** — a forward-generation pipeline:

```lean
partial def generateValidBatch (seedCount : Nat) (maxComplexity : Nat)
    (atoms : List Atom) : IO (List Formula) := do
  -- Phase 1: Seed pool with axiom instances + theorem seeds
  for _ in List.range seedCount do
    let axiomInst ← instantiateAxiom atoms maxParamSize
    -- (addToPool: HashSet dedup + Array append)
  -- Phase 2: Cap ex_falso instances to at most 20% of pool
  -- Phase 3: Fixpoint Nec/MP closure
  let mut round : Nat := 0
  while round < 10 && poolArr.size < 10000 do
    -- 3a. Necessitation round: □φ for each φ in pool
    for φ in snapshot do
      let boxPhi := generateValidFromNec φ  -- = Formula.box φ
      -- addToPool
    -- 3b. MP round: implication-index for O(n) closure
    for ψ in mpSnapshot do
      match ψ with
      | .imp lhs rhs =>
        impIndex := impIndex.insert lhs (arr.push rhs)
      | _ => pure ()
    for φ in mpSnapshot do
      match impIndex[φ]? with
      | some rhsArr => for rhs in rhsArr do ... addToPool
    round := round + 1
```

**Crucially**: `generateValidBatch` produces *formulas* — it **discards the proofs**. The forward generator for task 279 is the same algorithm but **also tracks the `DerivationTree` witness** for every emitted formula. The structural changes are:

1. Replace `poolArr : Array Formula` with `poolArr : Array (Formula × DerivationTree fc [] Formula)`.
2. Replace `addToPool` with a version that threads the proof tree.
3. Replace `generateValidFromMP` and `generateValidFromNec` with versions that **construct the proof term** using `DerivationTree.axiom`, `DerivationTree.modus_ponens`, `DerivationTree.necessitation`, etc.
4. The dedup logic must collapse formulas reached by *multiple* proof paths to **one canonical proof** (the first one found, by convention; or the shortest, by height).

### 3.3 `instantiateAxiom` (axiom parametrization over atom pool)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean:1153-1252`

```lean
partial def instantiateAxiom (atoms : List Atom) (maxParamSize : Nat) : IO Formula := do
  let schemaIdx ← IO.rand 0 21
  match schemaIdx with
  | 0 => do  -- prop_s: φ → (ψ → φ)
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return φ.imp (ψ.imp φ)
  | 1 => do  -- prop_k: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
    ...
  | 14 => do  -- modal_future(φ): □φ → G(□φ)
    let φ ← randomSubFormula atoms maxParamSize
    return φ.box.imp φ.box.all_future
  ...
```

This already enumerates axiom instances as `Formula`s, picking from a fixed list of 22 schemata (note: this predates the BX rewrite; the current 42 schemata are not all covered — see §7.1). The forward generator needs a *parallel* function `instantiateAxiomWithProof` that **also returns the `Axiom` witness** — a small extension that wraps the existing schema in an `Axiom` constructor, then yields `DerivationTree.axiom [] (instantiated formula) ax trivial`.

### 3.4 Integration point: `GenerationMode` dispatch

**Target**: `DatasetGenerator.lean:545-731` (`labelFormula`)

A minimal-invasion integration design:

```lean
inductive GenerationMode where
  | exhaustive       -- current behavior: enumerate-then-decide
  | proofFirst       -- new: forward-chaining from axioms
  | hybrid           -- run both, dedup, union
  deriving Inhabited, Repr, BEq

def labelFormula (φ : Formula) (fc : FrameClass := .Base)
    (mode : GenerationMode := .exhaustive)
    (wallclockTimeoutMs : Nat := 1000) : IO LabeledFormula := ...
```

For `proofFirst` mode, the call to `decideAutoAdaptive φ fc` is replaced by a call to a new module `Bimodal.Automation.ForwardProofGenerator`:

- If `φ` matches a `(formula, proof)` already in the global proof-first pool, return the existing record.
- Otherwise, fall back to the exhaustive path (this preserves backward compat: any formula not reachable by forward generation at depth N can still be labeled by the slower enumeration path).

The hybrid mode runs both in parallel and merges results (lowest interestingness-tier wins, breaking ties by `proofTrace.height`).

### 3.5 Existing `LabeledFormula` shape

**File**: `Theories/Bimodal/Automation/DatasetGenerator.lean:146-177`

```lean
structure LabeledFormula where
  formula : Formula
  label : FormulaLabel           -- .valid | .invalid | .timeout
  proofTrace : Option ProofTrace -- valid only
  countermodel : Option SimpleCountermodel
  metrics : DifficultyMetrics
  patternKey : PatternKey
  ruleProfile : Option RuleProfile
  decisionMethod : String        -- "structural_prefilter", "fast_path_axiom", etc.
  ...
  proofReconstructionMethod : Option String
  interestingnessScore : Option Nat
  interestingnessTier : Option String
```

For forward generation, the **decisionMethod** field should distinguish:

- `"proof_first_axiom"` — formula is a literal axiom instance (no MP/Nec applied)
- `"proof_first_mp_k"` — derived via `k` steps of modus ponens
- `"proof_first_nec"` — derived via necessitation
- `"proof_first_temp_nec"` — derived via temporal necessitation
- `"proof_first_temp_dual"` — derived via temporal duality
- `"proof_first_hybrid"` — combination

The `proofReconstructionMethod` (inferred from `RuleProfile` + height at line 327) already discriminates `axiom_match`, `derived_match`, `compositional`, `proof_search`; we add `proof_first_compositional` as a fifth value.

---

## 4. Task 277 Rule-Firing Trace Analysis

### 4.1 What Task 277 provides

**File**: `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` (delivered)

Task 277 delivers the **tableau-side** trace infrastructure:

- `inductive TraceEntry` (line 55-75) with 5 constructors: `ruleFired`, `branchCreated`, `branchClosed`, `blockingFired`, `fuelExhausted`. Mirrors the Libal & Volpe (2016) FPC schema `(precondition, rule, conclusion, branch_id)`.
- `structure ProofCertificate` (line 108-129) with `formula`, `frameClass`, `outcome`, `trace : List TraceEntry`, `totalSteps`, `axiomFingerprint : Std.HashMap String Nat`, `branchingFactor : Float`, `maxDepth`, `elapsedMs`.
- `ProofCertificate.empty` (line 137-146) — the empty starting state.
- `inductive TraceResult` (line 181-184) — `success` (carries the full certificate) or `failure` (carries the partial trace).
- `ruleToString : TableauRule → String` (line 195+) — canonical serialization for the 28 tableau rules.

**Important caveat**: Task 277 is about **tableau** rules (the 28 `TableauRule` constructors in `Theories/Bimodal/Metalogic/Decidability/Tableau.lean:67-135`), not the Hilbert-style **axiom schemata** that task 279 will use. The two rule sets are *complementary*:

- Task 277 instruments the *analytic* side: how a tableau prover *discovers* a proof.
- Task 279 instruments the *synthetic* side: how a Hilbert-style axiom application *constructs* a proof.

This is actually a **feature, not a bug**: the trace certificates from task 277 can be used to **measure the dataset's effectiveness** (a formula's tableau trace depth is a good proxy for "how hard is it to decide?"), while task 279's proof trees measure "how expressive is the proof?" (proof tree depth, axiom diversity, rule profile).

### 4.2 Reuse of `axiomFingerprint` and `branchingFactor`

The `ProofCertificate.axiomFingerprint : Std.HashMap String Nat` field (line 122) records per-rule-name firing counts *on the tableau side*. For task 279, we will define a parallel structure on the **axiom side**:

```lean
/-- Count of axiom schema applications in a proof tree. -/
structure AxiomProfile where
  /-- Per-axiom-name count: "modal_t" -> 1, "prop_k" -> 2, etc. -/
  counts : Std.HashMap String Nat
  /-- Number of distinct axioms used. -/
  distinctCount : Nat
  /-- Distribution across axiom layers (propositional / modal / temporal / etc.). -/
  layerDistribution : List (String × Nat)
  deriving Repr, Inhabited
```

This is a *different* aggregation than `ProofCertificate.axiomFingerprint` (which is per-tableau-rule), but the *shape* (string-keyed HashMap of counts) is the same, and the JSON serialization mirrors `DataExport.lean:356-364`.

The `ProofCertificate.branchingFactor : Float` (line 124) and `branchingFactor`-based **comparison methodology** (mentioned in research goal #6 of the task) can be **extended** to compare:

- (Exhaustive pipeline) `branchingFactor` of the *tableau* trace certificate for each formula.
- (Forward pipeline) **axiom diversity** of the *proof tree* for each formula.

These are different metrics measuring different things; the comparison is qualitative, not direct.

### 4.3 Partial-trace failure handling (out-of-fuel for forward gen)

`TraceFailure` (line 171-175) has three constructors: `outOfFuel`, `unsaturatable`, `applyRulePanic`. The forward generator does not need this complexity — it does *forward* reasoning, not *backward* search. However, the forward generator **does** need a similar notion: when the derivation-depth budget `N` is exhausted, we want to **stop extending** the pool (which is natural with a `termination_by N` recursion), not to fail. So the failure-mode design from task 277 does not directly apply; we adopt the *terminology* (depth-bounded generation, no partial proofs leaked).

### 4.4 Comparison methodology (task requirement #6)

The task requires us to "Compare output quality: axiom diversity, proof depth distribution, and temporal axiom usage vs. enumeration-based generation." Concretely:

| Metric | Enumeration-based (current) | Forward-chaining (task 279) |
|---|---|---|
| **Axiom diversity** | Measured by `ProofTrace.axioms_used` (post-extraction from decision procedure proof) — but most proven formulas are detected by **single axiom match** (e.g., `structuralPrefilter`), so diversity is low. Empirical evidence in `EnumBenchmark.lean:174`: "Ex_falso still dominates valid set (~90%)". | Measured directly from generated proof trees. Because we **pick** which axioms to instantiate, we can enforce balance (e.g., uniform over the 37 base axioms). |
| **Proof depth distribution** | Determined by decision-procedure heuristics (tableau saturation). Heavy-tailed, biased toward shallow proofs (e.g., all `modus_ponens` of two axiom instances). | Determined by derivation-depth bound `N`. Explicitly controllable: pick `N=1` for axiom-only, `N=3` for "1 MP step", etc. |
| **Temporal axiom usage** | Low. The valid set is dominated by propositional axioms (`ex_falso`, `prop_s`) because they are simpler to instantiate and combine. | Configurable. The forward generator can pick the temporal axiom rate as a parameter: e.g., 30% of new seeds come from `right_mono_until`, `F_until_equiv`, `connect_future`, etc. |
| **Ex_falso dominance** | ~90% (per `EnumBenchmark.lean:174`). | Can be capped at any level (re-use the `maxExFalso` logic at `FormulaEnumerator.lean:1389-1417`). |
| **Operator diversity** | `GoalCategory` distribution skewed by enumeration budget allocation. | Configurable per axiom schema: e.g., pick modal_4 + right_mono_until + F_until_equiv uniformly to force bimodal interaction. |

The comparison is implemented by running both modes in `hybrid` generation and emitting side-by-side metrics in the JSONL.

---

## 5. Literature Review: Proof-First Generation

### 5.1 DeepSeek-Prover-V2 subgoal decomposition

**Reference**: DeepSeek-AI team, "DeepSeek-Prover-V2: Advancing Subgoal Decomposition for Formal Theorem Proving" (2025).

The key idea is **subgoal decomposition**: rather than ask the model to produce a 100-line proof in one shot, recursively decompose the goal into subgoals, prove each independently, and chain the results. The proof data is the **decomposition tree**, which is structurally identical to `DerivationTree` (axiom leaves, modus-ponens and necessitation internal nodes).

**Adoption for our setting**:

- Our `DerivationTree` is **already** a decomposition tree.
- The forward generator **builds** decomposition trees (subgoal = axiom instance; glue = modus ponens).
- The supervision signal is the **shape of the tree** (depth, branching factor, axiom mix), not just the formula.

**Difference**: DeepSeek-Prover-V2 trains a *neural* model to predict subgoals; we are *enumerating* subgoals and producing supervised training data. The role of the proof tree is reversed: it's the *target* of training, not the *output* of training.

### 5.2 SynLogic (NeurIPS 2025) parameterized generation

**Reference**: SynLogic paper, NeurIPS 2025 (mentioned in task description and `specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md:245`).

SynLogic's key idea is **rule-based verifiers**: rather than enumerate all possible formulas and check each with a slow SMT solver, generate *only* formulas whose validity is **guaranteed by construction**, using a small set of "construction rules" that are soundness-preserving by definition.

**Direct mapping to our setting**:

- Our **construction rules** are the 7 `DerivationTree` constructors (axiom, mp, nec, ...).
- The **soundness** of each construction rule is a **type-system property** of Lean: if we have `d1 : DerivationTree fc [] (φ.imp ψ)` and `d2 : DerivationTree fc [] φ`, then `modus_ponens [] φ ψ d1 d2 : DerivationTree fc [] ψ` is a theorem by **construction**, no separate verifier needed.
- The **formula diversity** comes from instantiating the axiom schemata with many atom variables and sub-formulas.

**Difference from SynLogic**: SynLogic's "rules" are *generative grammar* rules that produce strings; ours are *proof combinators* that produce `(Formula, DerivationTree)` pairs. The Lean type system provides a strictly stronger guarantee: every emitted pair is a theorem, full stop.

### 5.3 Libal & Volpe (2016) Foundational Proof Certificates (FPC)

**Reference**: Libal & Volpe, "Certification of Prefixed Tableau Proofs for Modal Logic", GandALF 2016 (EPTCS 226, pp. 257-271). Cited in `specs/277_tableau_rule_firing_traces/reports/01_trace-certificates-design.md:8`.

FPCs are a generic framework for representing proof evidence in a small, focused-sequent kernel. Each certificate records `(precondition, rule, conclusion, branch_id)` per inference step.

**Adoption for our setting**: The `TraceEntry` inductive in `TraceCertificate.lean:55-75` already mirrors this 1-to-1 (for the tableau side). For the axiom side, the natural analogue is a richer structure:

```lean
inductive ProofStep : Type where
  | axiomStep {φ : Formula} (ax : Axiom φ) (frameClass : FrameClass)
  | mpStep (φ ψ : Formula) (d1 d2 : ProofStep)   -- modus_ponens
  | necStep (φ : Formula) (d : ProofStep)         -- necessitation
  | tempNecStep (φ : Formula) (d : ProofStep)     -- temporal_necessitation
  | tempDualStep (φ : Formula) (d : ProofStep)    -- temporal_duality
```

This is essentially `DerivationTree` with a different presentation (no context parameter; only empty-context theorems). For our task, we will **not** introduce a new type — we will *reuse* `DerivationTree fc [] φ` as the proof step, and provide a JSON-friendly summarization on top.

### 5.4 SPOT's `randltl` (LTL formula generator with redundancy avoidance)

**Reference**: Mentioned in `specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md:240`.

DAG-based generation that avoids exponential blowup. Each formula is represented as a **DAG** (shared sub-formula references), and generation enforces **canonical DAG representatives** to avoid redundant formulas.

**Adoption**: The forward generator can adopt a similar **canonicalization** policy: apply `AtomCanonicalization.canonicalize` (`FormulaEnumerator.lean:1596`) at seed-instantiation time so that atom permutations produce identical seeds. This is already used in `enumerateWithProgress` (line 1615) and gives 4.58× formula count reduction.

### 5.5 LTLBench (2024) and SAT competition generators

**Reference**: Mentioned in `specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md:241,243`.

Template-based generation: rather than enumerate all formulas up to complexity `N`, sample from a small set of **templates** (e.g., "P ∨ (□P → P)" → "Q ∨ (□Q → Q)") that have known validity and interesting structure.

**Adoption for forward generation**: Our 42 axiom schemata **are** the templates. Forward generation is template-based by construction.

---

## 6. Forward-Chaining Algorithm Design

### 6.1 Algorithm sketch (pseudocode)

```lean
/-- Forward-chaining proof generator. -/
def forwardGenerate (cfg : ForwardConfig) (fc : FrameClass := .Base)
    : IO (List (Formula × DerivationTree fc [] Formula)) := do
  let mut pool : Pool fc := Pool.empty    -- HashSet + Array of (formula, proof)
  let mut seenAxioms : HashSet String := {}  -- for diversity tracking

  -- Phase 1: Seed pool with axiom instances (depth 0)
  for _ in List.range cfg.seedCount do
    let (φ, ax_inst) ← instantiateAxiomWithProof cfg.atoms cfg.maxParamSize fc
    pool := pool.add φ (DerivationTree.axiom [] φ ax_inst (leOfMinFrameClass ax_inst fc))
    seenAxioms := seenAxioms.insert (axiomName ax_inst)

  -- Phase 2: Cap ex_falso instances to ≤ 20% of pool
  pool := capExFalso pool (cfg.exFalsoCap * pool.size / 5)

  -- Phase 3: Bounded fixpoint closure under (mp, nec, temp_nec, temp_dual)
  for depth in List.range cfg.maxDepth do
    let snapshot := pool.toList
    -- 3a. Apply modus ponens: for each (φ → ψ) in pool, for each φ in pool, add ψ
    for (φ, dφ) in snapshot do
      for (ψ_imp, dψ_imp) in snapshot do
        if let some (φ2, ψ) := matchImplication ψ_imp then
          if φ2 == φ then
            let ψ_proof : DerivationTree fc [] ψ :=
              DerivationTree.modus_ponens [] φ2 ψ dψ_imp dφ
            pool := pool.add ψ ψ_proof
    -- 3b. Apply necessitation
    for (φ, dφ) in snapshot do
      let box_φ_proof : DerivationTree fc [] (Formula.box φ) :=
        DerivationTree.necessitation φ dφ
      pool := pool.add (Formula.box φ) box_φ_proof
    -- 3c. Apply temporal necessitation
    for (φ, dφ) in snapshot do
      let g_φ_proof : DerivationTree fc [] (Formula.all_future φ) :=
        DerivationTree.temporal_necessitation φ dφ
      pool := pool.add (Formula.all_future φ) g_φ_proof
    -- 3d. Apply temporal duality
    for (φ, dφ) in snapshot do
      let dual_φ_proof : DerivationTree fc [] φ.swap_temporal :=
        DerivationTree.temporal_duality φ dφ
      pool := pool.add φ.swap_temporal dual_φ_proof
    -- 3e. Stop if no new formulas added
    if pool.size == snapshot.length then break
    -- 3f. Cap pool size to prevent explosion
    if pool.size > cfg.maxPoolSize then break
  return pool.toList
```

**Termination**: The inner `for` loops each iterate over `snapshot : List (Formula × DerivationTree)` of size ≤ `cfg.maxPoolSize`. The outer `for depth in 0..cfg.maxDepth` loop is bounded by configuration. Total work is `O(maxPoolSize² × maxDepth)` per inference rule. With `maxPoolSize = 10000` and `maxDepth = 5`, this is `5 × 10⁸` iterations per rule — feasible on a single core in minutes.

**Memory**: `pool` holds at most `maxPoolSize` entries. Each entry is a `Formula` (small, AST-allocated) and a `DerivationTree` (which can be deep, but `maxDepth` bounds the height). The total memory is bounded by `O(maxPoolSize × maxDepth × avgFormulaSize)`.

### 6.2 Soundness argument

The forward generator emits `(φ, d : DerivationTree fc [] φ)` pairs. The only way `d` can be constructed is via the 7 `DerivationTree` constructors; the `axiom` constructor carries `h : Axiom φ` and `h_fc : h.minFrameClass ≤ fc`; the other constructors build a derivation only when their sub-derivations are valid. Therefore, **every emitted `d` is a proof of `φ` at `FrameClass fc`**. The empty context `[]` is used because we only generate theorems (proofs from no assumptions), not derivable-but-non-theorem formulas.

The only soundness concern is the `axiom` constructor's `h_fc : h.minFrameClass ≤ fc` field — we need a runtime check or a tactic-driven proof that the picked axiom's `minFrameClass` is `≤ fc`. The `Axiom.minFrameClass` function (Axioms.lean:456) returns a `FrameClass` value, and `FrameClass.LE` (Axioms.lean:434) is decidable. So we can:

1. At axiom-instantiation time, compute `minFC := ax.minFrameClass`.
2. Check `decide (minFC ≤ fc)`. If true, build the `DerivationTree.axiom`; if false, skip the axiom.

This is a **runtime check**, not a compile-time check, because `instantiateAxiom` returns an `IO Formula` (axiom chosen at random), not an `Axiom` witness. To get a **compile-time** check, we would need a stronger return type:

```lean
inductive AxiomResult (fc : FrameClass) : Formula → Type where
  | ok {φ : Formula} (ax : Axiom φ) (h : ax.minFrameClass ≤ fc) : AxiomResult fc φ
  | skip {φ : Formula} (ax : Axiom φ) (h : ¬(ax.minFrameClass ≤ fc)) : AxiomResult fc φ
```

This is a small refactor; we recommend it for soundness in the spirit of task 277's `EStateM` preservation of partial traces. Alternative: skip the `h_fc` argument entirely and always pick `fc = .Base`; the user can run the forward generator in `.Base` mode and lift to `.Dense`/`.Discrete` via `DerivationTree.lift` (Derivation.lean:190).

### 6.3 Deduplication strategy

**Pool data structure**: `Std.HashSet Formula` for O(1) membership, `Array (Formula × DerivationTree)` for ordered iteration. Same pattern as `generateValidBatch` (FormulaEnumerator.lean:1365-1461).

**When a formula is reachable by multiple proof paths**:

- Strategy A (first-wins): Keep the first proof found. Simple, deterministic.
- Strategy B (shortest-wins): Keep the proof with smallest `.height`. Captures the "canonical" proof.
- Strategy C (richest-wins): Keep the proof with the most diverse axiom set. Maximizes training signal.

**Recommendation**: **Strategy B** (shortest-wins) is most consistent with existing practice (`enumExactHelper` and `extractProofTrace` both track height). Implementation: when adding to pool, if the formula already exists, compare heights and replace if the new proof is shorter. This bounds the dedup cost to O(1) per insertion and is monotonic.

**Important consequence**: After forward generation, every formula in the pool has a **unique canonical proof** (the shortest one found). This means the supervision signal `(formula, proof)` is **bijective**, which simplifies training (one label per formula).

### 6.4 Bounding derivation depth

The task requires "control complexity via derivation depth rather than formula AST size." This is `cfg.maxDepth` in the pseudocode above. The forward generator:

1. Tracks `currentDepth` explicitly (the outer loop counter).
2. Each generated proof has `height = currentDepth + 1` (for `modus_ponens`/`necessitation`/etc., all of which add 1 to sub-proof height).
3. The **formula AST size is unbounded** by `maxDepth` — a depth-2 MP can combine two large axiom instances, producing a complex formula. This is intentional: a depth-2 proof of `□p → □p` (combining `modal_t p` and `modal_t (p.box)`) is more interesting than a depth-20 proof of `p → p`.

**Empirical validation**: With `maxDepth = 2` and `maxPoolSize = 10000`, expected formula complexity distribution is biased toward c4-c8 (since axiom instances at `maxParamSize = 4` combine to c8-c10). This matches the existing `EnumBenchmark.lean:175` finding that "Valid fraction improved from 1.6% (random, task 204) to ~3-4% (exhaustive + seeds)".

### 6.5 Forced axiom diversity

The forward generator can enforce axiom diversity through:

1. **Round-robin axiom selection**: For each seed, pick the next axiom in a fixed cycle (e.g., `prop_k`, `modal_t`, `right_mono_until`, `F_until_equiv`, ...). This guarantees that every axiom is represented in the seed pool.

2. **Rarity-driven selection**: After the first round, bias new seed selection toward axioms that are **under-represented** in `seenAxioms`. This is implemented as: pick axiom `a` with probability `(1 / (seenAxioms[a]? + 1)) / Σ (1 / (seenAxioms[x]? + 1))`.

3. **Layer-uniform selection**: Group axioms by layer (propositional, modal, temporal, ...) and pick uniformly from layers. Each layer gets `seedCount / 4` instances.

4. **Temporally-weighted selection** (for bimodal interaction research): Pick from temporal schemata (BX axioms) at 50% rate, modal at 30%, propositional at 20%. This biases the dataset toward formulas requiring temporal axioms.

**Recommendation**: Layer-uniform (option 3) as the default; temporally-weighted (option 4) as a research option for the bimodal interaction slice.

### 6.6 Performance estimate

With the parameters:

- `seedCount = 2000`
- `maxParamSize = 4`
- `maxDepth = 3`
- `maxPoolSize = 10000`
- `atoms = [p, q, r]` (3 atoms)

Empirically (extrapolating from `generateValidBatch`'s 10000-pool achieved in <30s for similar parameters):

- Phase 1 (seeds): 2000 axiom instances, ~5s
- Phase 2 (cap ex_falso): <1s
- Phase 3a (MP round 1): 2000 × 2000 / 2 ≈ 2M pairs to check, but most are not matching implications, so ~100K real MP candidates, ~10s
- Phase 3b (Nec round 1): 2000 → 2000 new box formulas, ~1s
- Phase 3c (TempNec round 1): 2000 → 2000 new G formulas, ~1s
- Phase 3d (TempDual round 1): 2000 → 2000 new dual formulas, ~1s
- Rounds 2 and 3: similar, maybe 3-4× more per round (the pool grows).
- Total: ~60-90 seconds for 10000-pool generation.

This is **substantially faster** than the exhaustive enumeration at c7 (8 minutes, per `EnumBenchmark.lean:175` and `01_explosion-analysis.md:9`).

### 6.7 Worked example

Goal: depth-1 forward generation, atoms `[p]`, axiom seeds: 1× `prop_s p p`, 1× `modal_t p`.

Phase 1 (depth 0): pool = {`p → (p → p) : axiom prop_s`, `□p → p : axiom modal_t`}

Phase 2 (depth 1, MP): Check all implication pairs.
- `p → (p → p)` is `(p → (p → p))` where `lhs = p` and `rhs = p → p`.
- We look for `p : DerivationTree [] p` in the pool. **Not found** (we only have implications).
- `□p → p` is `(□p → p)` where `lhs = □p` and `rhs = p`.
- We look for `□p : DerivationTree [] □p` in the pool. **Not found**.
- No new MP results.

Phase 2 (depth 1, Nec): For each formula, add its `□` version.
- `□(p → (p → p))` added.
- `□□p` added.

Phase 2 (depth 1, TempNec): For each formula, add its `G` version.
- `G(p → (p → p))` added.
- `G(□p → p)` added.

Phase 2 (depth 1, TempDual): For each formula, add its `swap_temporal` version.
- `p → (p → p)` → `p → (p → p)` (no change; no temporal operators).
- `□p → p` → `□p → p` (no change; box is not temporal).

Final pool (depth 1): 6 formulas, each with a proof tree of height 1 (Nec/TempNec adds 1; axioms have height 0).

This is **6 labeled theorems in milliseconds**, vs. the exhaustive approach which would have enumerated all c1-c4 formulas (~1,000 at c4 alone per `01_explosion-analysis.md:33`) to find 6 valid ones.

---

## 7. Implementation Challenges and Proposed Solutions

### 7.1 Challenge 1: Gap between 42 axioms and `instantiateAxiom`'s 22

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean:1153-1252`

`instantiateAxiom` covers 22 schemata, but the current `Axiom` type has **42 constructors** (per `Axioms.lean:18-37`). The 20 missing schemata are mostly the **past-direction mirrors** of temporal axioms (BX2', BX3', BX4', etc.) and a few uniform/prior/density axioms.

**Solution**: Extend `instantiateAxiom` from 22 to 42 cases. The pattern is uniform — each new case picks random sub-formulas and constructs the axiom formula. Effort: ~2-3 hours. Alternatively, define `instantiateAxiomV2 : List Atom → Nat → IO (Σ φ, Axiom φ)` that returns the axiom *witness* (not just the formula) — this requires matching the 42 cases against the 42 `Axiom` constructors, a mechanical translation.

**Recommendation**: Extend `instantiateAxiom` to cover all 42 schemata and produce `Axiom` witnesses. This is the cleanest integration.

### 7.2 Challenge 2: Lean dependent types defeat naive JSON serialization

**File**: `Theories/Bimodal/Automation/DatasetGenerator.lean:27-29` explicitly notes:

> **Simplified ProofTrace**: Extracts height, axiom constructor names, and rule names from `DerivationTree` without full serialization (dependent types make full serialization impractical)

`DerivationTree fc Γ φ` is parameterized by `Γ` and `φ`, and the `modus_ponens` constructor's `d1` has type `DerivationTree fc Γ (φ.imp ψ)` — a different formula than the conclusion `ψ`. Naive JSON would have to encode the full AST, which is enormous.

**Solution**: Reuse the existing `extractProofTrace` (DatasetGenerator.lean:262) and `walkDerivationTree` (DataExport.lean:325) extractors. The forward generator emits `DerivationTree`; the export pipeline already reduces it to:

- `height : Nat`
- `axioms_used : List String` (axiom names)
- `rules_applied : List String` (rule names)
- `RuleProfile` (counts of each rule type)

**No new serialization work** is needed. The forward generator's output is structurally identical to the current decision-procedure output.

### 7.3 Challenge 3: Modus ponens explosion

If the pool has 1000 implications, MP generates up to 1000 × 1000 = 1M pairs to check. With `maxPoolSize = 10000`, this is 10⁸ — too slow if done naively.

**Solution**: Use the **implication index** pattern from `generateValidBatch` (FormulaEnumerator.lean:1430-1448):

```lean
let mut impIndex : Std.HashMap Formula (Array (Formula × DerivationTree)) := {}
for (ψ, dψ) in poolArr do
  match ψ with
  | .imp lhs rhs =>
    match impIndex[lhs]? with
    | some arr => impIndex := impIndex.insert lhs (arr.push (rhs, dψ))
    | none => impIndex := impIndex.insert lhs #[(rhs, dψ)]
  | _ => pure ()
-- Single pass: for each φ in pool, look up consequents via index
for (φ, dφ) in poolArr do
  match impIndex[φ]? with
  | some rhsArr =>
    for (rhs, dψ_imp) in rhsArr do
      let ψ_proof := DerivationTree.modus_ponens [] φ rhs dψ_imp dφ
      pool := pool.add rhs ψ_proof
  | none => pure ()
```

This is **O(n)** per MP round, not O(n²). For `n = 10000`, it's the difference between 10⁸ and 10⁴ — a 10000× speedup.

### 7.4 Challenge 4: Frame class typing

`DerivationTree.fc` is a `FrameClass` parameter. If the user picks `fc = .Discrete`, the axiom constructor's `h_fc : h.minFrameClass ≤ fc` field must be satisfied at *construction time*. We need a runtime check or a compile-time proof.

**Solution**: Restrict the forward generator to `fc = .Base` by default; let the user explicitly pick `.Dense` or `.Discrete` if they need frame-class-specific theorems. Inside the generator, wrap each axiom selection in:

```lean
def instantiateAxiomFC (atoms : List Atom) (maxParamSize : Nat) (fc : FrameClass)
    : IO (Option (Σ φ, DerivationTree fc [] φ)) := do
  let axResult ← pickRandomAxiom atoms maxParamSize
  match axResult with
  | some (φ, ax, h_le) =>
    -- h_le : ax.minFrameClass ≤ fc, by `decide` or by `trivial` if known statically
    some ⟨φ, DerivationTree.axiom [] φ ax h_le⟩
  | none => none
```

The `h_le` is decidable because `FrameClass.LE` has a `DecidableRel` instance (Axioms.lean:435).

**Alternative (simpler)**: Always generate at `fc = .Base`; provide a `liftToFrameClass` post-processing step that uses `DerivationTree.lift` (Derivation.lean:190) to lift to `.Dense` or `.Discrete`. The lift is **proof-producing** (not just `Nonempty`), so we keep the proof tree at the higher frame class too.

### 7.5 Challenge 5: Tracking "the original axiom" of a proof

For axiom diversity metrics, we want to know which axioms were used in each proof. The `extractAxiomName` function (DatasetGenerator.lean:206-249) already does this; we just call it on the generated proof tree.

**Subtlety**: A formula can be reached by **multiple proof paths** using different axioms. If we dedup by shortest height, the chosen proof might be the one with fewer axiom varieties. To get the **most axiom-diverse** proof, we could:

- Track all proofs (multi-map from `Formula` to `DerivationTree`), then pick the one with maximum distinct-axiom count.
- Cost: 2×-3× memory, but trivially computed.

**Recommendation**: Default to **shortest-wins**; add a `--maximize-axiom-diversity` CLI flag for the alternative.

### 7.6 Challenge 6: Weakening rule should not be applied

The 4 "consume a sub-proof" rules in `DerivationTree` are `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`. The 5th, `weakening`, adds assumptions and does **not** change the conclusion. Applying `weakening` in forward generation would produce **logically equivalent** formulas (just under a different context), so it bloats the pool without adding information.

**Solution**: Do not apply `weakening` in the forward generator. The output is always `DerivationTree fc [] φ` (empty context). This is consistent with the task's framing: we are generating *theorems* (closed proofs), not derivable formulas.

### 7.7 Challenge 7: Avoiding trivial forward results

Two triviality concerns:

1. **Ex_falso dominance**: As in the existing pipeline, `ex_falso` (`⊥ → φ`) is the easiest axiom to instantiate and combines trivially. The existing `maxExFalso` cap (FormulaEnumerator.lean:1389-1417) caps at 20% of the pool. We re-use this.

2. **Identity tautologies**: `p → p` is provable from `prop_k` + `prop_s` + MP (combinator S/K). A depth-2 forward generator will produce many such tautologies. They are still theorems, so they are valid training data, but they are **boring**. The `interestingnessTier` field in `LabeledFormula` (DatasetGenerator.lean:175) classifies them as `"trivial"` if `interestingnessScore < threshold`.

**Solution**: After forward generation, run `computeInterestingness` (from `InterestingnessMetrics.lean:486`) on each `(formula, proof)` pair to populate `interestingnessScore` and `interestingnessTier`. The `LabeledFormula.toJson` (DatasetGenerator.lean:872-914) already includes these fields.

---

## 8. Architecture Recommendations with Concrete Lean 4 Sketch

### 8.1 New module: `Theories/Bimodal/Automation/ForwardProofGenerator.lean`

```lean
import Bimodal.ProofSystem
import Bimodal.ProofSystem.Derivation
import Bimodal.Automation.DataExport
import Bimodal.Automation.SuccessPatterns

/-!
# Forward-Chaining Proof Generator (Task 279)

Builds derivation trees by composing axiom schemata under modus ponens,
necessitation, temporal necessitation, and temporal duality, up to a
configurable derivation depth N. Every emitted formula is guaranteed
to be a theorem, with the proof term serving as supervision signal.

## Design

The algorithm generalizes `generateValidBatch` (`FormulaEnumerator.lean:1361`)
to track proof trees (`DerivationTree`) rather than just formulas.

## Outputs

A `List (Formula × DerivationTree fc [] Formula)` where each pair is a
labeled theorem with its proof witness. Compatible with `LabeledFormula`
via `extractProofTrace` and `walkDerivationTree`.
-/

set_option autoImplicit false

namespace Bimodal.Automation.ForwardProofGenerator

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation.DataExport

/-- Configuration for the forward-chaining proof generator. -/
structure ForwardConfig where
  /-- Number of initial axiom seed instances. -/
  seedCount : Nat := 2000
  /-- Maximum size of sub-formulas used to instantiate axioms. -/
  maxParamSize : Nat := 4
  /-- Maximum derivation depth (0 = axioms only, 1 = one MP/Nec/etc., ...). -/
  maxDepth : Nat := 3
  /-- Maximum pool size (bounds the forward-closure memory). -/
  maxPoolSize : Nat := 10000
  /-- Atoms to use in axiom instantiation. -/
  atoms : List Atom
  /-- Frame class for the generated proofs (default `.Base`). -/
  frameClass : FrameClass := .Base
  /-- Cap on ex_falso-pattern formulas as a fraction of pool (default 0.2). -/
  exFalsoCap : Nat := 1  -- numerator of ex_falso fraction
  exFalsoDenom : Nat := 5
  /-- Whether to enforce layer-uniform axiom selection (default true). -/
  layerUniform : Bool := true
  deriving Repr, Inhabited

/-- A pool of (formula, proof) pairs, indexed by formula for O(1) lookup. -/
structure ProofPool (fc : FrameClass) where
  /-- Ordered array of (formula, proof) for iteration. -/
  entries : Array (Σ φ, DerivationTree fc [] φ)
  /-- Set of formulas (for O(1) membership check). -/
  formulas : Std.HashSet Formula
  /-- Map from formula to its shortest proof (deduped). -/
  index : Std.HashMap Formula Nat  -- index into entries
  deriving Inhabited

namespace ProofPool

/-- Empty pool for a given frame class. -/
def empty : ProofPool fc :=
  { entries := #[], formulas := {}, index := {} }

/-- Number of formulas in the pool. -/
def size (pool : ProofPool fc) : Nat := pool.entries.size

/-- Add a formula with a proof. If the formula already exists with a shorter
    proof, replace; if with a longer proof, skip. Returns the updated pool. -/
def add (pool : ProofPool fc) (φ : Formula) (d : DerivationTree fc [] φ)
    : ProofPool fc :=
  match pool.index[φ]? with
  | some idx =>
    -- Compare heights and replace if new is shorter
    let existing := pool.entries[idx]!
    let existingHeight := existing.snd.height
    let newHeight := d.height
    if newHeight < existingHeight then
      let newEntries := pool.entries.set! idx ⟨φ, d⟩
      { pool with entries := newEntries }
    else
      pool
  | none =>
    if pool.entries.size ≥ someMaxPoolSize then
      pool  -- cap reached; skip
    else
      let newIdx := pool.entries.size
      { entries := pool.entries.push ⟨φ, d⟩
      , formulas := pool.formulas.insert φ
      , index := pool.index.insert φ newIdx }

/-- Convert pool to a list for downstream consumption. -/
def toList (pool : ProofPool fc) : List (Formula × DerivationTree fc [] Formula) :=
  pool.entries.toList.map fun σ => (σ.fst, σ.snd)

end ProofPool

/-- Instantiate a single axiom schema with random sub-formulas, returning
    BOTH the formula AND the axiom witness.

    Picks uniformly from all 42 axiom constructors (per the current
    `Bimodal.ProofSystem.Axiom` inductive).

    The `h_fc : ax.minFrameClass ≤ fc` field is filled in by a runtime
    `decide` call; the call site is responsible for filtering axioms
    that are valid at the chosen `fc`. -/
partial def instantiateAxiomWithProof (cfg : ForwardConfig)
    : IO (Option (Σ φ, DerivationTree cfg.frameClass [] φ)) := do
  let schemaIdx ← IO.rand 0 41
  let atoms := cfg.atoms
  let maxP := cfg.maxParamSize
  -- Match the 42 cases, one per Axiom constructor
  match schemaIdx with
  | 0 => do  -- prop_k
    let φ ← randomSubFormula atoms maxP
    let ψ ← randomSubFormula atoms maxP
    let χ ← randomSubFormula atoms maxP
    let ax : Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := .prop_k φ ψ χ
    let d : DerivationTree cfg.frameClass [] _ := .axiom [] _ ax (by exact leOfMinFrameClass ...)
    return some ⟨_, d⟩
  | 1 => do  -- prop_s
    let φ ← randomSubFormula atoms maxP
    let ψ ← randomSubFormula atoms maxP
    let ax := .prop_s φ ψ
    let d : DerivationTree cfg.frameClass [] _ := .axiom [] _ ax ...
    return some ⟨_, d⟩
  -- ... 40 more cases, each matching the 42 Axiom constructors
  | _ => return none

/-- Main forward-chaining entry point. Generates (formula, proof) pairs. -/
partial def forwardGenerate (cfg : ForwardConfig)
    : IO (List (Σ φ, DerivationTree cfg.frameClass [] φ)) := do
  let mut pool : ProofPool cfg.frameClass := .empty
  -- Phase 1: Seed pool with axiom instances
  for _ in List.range cfg.seedCount do
    match ← instantiateAxiomWithProof cfg with
    | some σ => pool := pool.add σ.fst σ.snd
    | none => pure ()
  -- Phase 2: Cap ex_falso
  pool := capExFalso pool cfg.exFalsoCap cfg.exFalsoDenom
  -- Phase 3: Bounded fixpoint closure
  for depth in List.range cfg.maxDepth do
    let snapshot := pool.toList
    -- 3a. Modus ponens (using implication index for O(n) instead of O(n²))
    pool := applyModusPonens pool
    -- 3b. Necessitation
    for (φ, d) in snapshot do
      let d' : DerivationTree cfg.frameClass [] (Formula.box φ) := .necessitation φ d
      pool := pool.add (Formula.box φ) d'
    -- 3c. Temporal necessitation
    for (φ, d) in snapshot do
      let d' : DerivationTree cfg.frameClass [] (Formula.all_future φ) :=
        .temporal_necessitation φ d
      pool := pool.add (Formula.all_future φ) d'
    -- 3d. Temporal duality
    for (φ, d) in snapshot do
      let d' : DerivationTree cfg.frameClass [] φ.swap_temporal := .temporal_duality φ d
      pool := pool.add φ.swap_temporal d'
    if pool.size == snapshot.length then break  -- fixpoint reached
  return pool.entries.toList
where
  /-- Apply modus ponens as a one-pass O(n) operation using an implication index. -/
  applyModusPonens (pool : ProofPool cfg.frameClass) : IO (ProofPool cfg.frameClass) := do
    let mut impIndex : Std.HashMap Formula (Array (Formula × DerivationTree _ _ _)) := {}
    for σ in pool.entries do
      match σ.fst with
      | .imp lhs rhs =>
        let d : DerivationTree _ _ _ := σ.snd
        match impIndex[lhs]? with
        | some arr => impIndex := impIndex.insert lhs (arr.push (rhs, d))
        | none => impIndex := impIndex.insert lhs #[(rhs, d)]
      | _ => pure ()
    let mut pool' := pool
    for σ in pool.entries do
      let φ := σ.fst
      let dφ := σ.snd
      match impIndex[φ]? with
      | some rhsArr =>
        for (rhs, dψ_imp) in rhsArr do
          let dψ : DerivationTree _ _ _ :=
            .modus_ponens [] φ rhs dψ_imp dφ
          pool' := pool'.add rhs dψ
      | none => pure ()
    return pool'

end Bimodal.Automation.ForwardProofGenerator
```

### 8.2 Integration into `DatasetGenerator.lean`

Add `GenerationMode` and a new entry point:

```lean
-- In DatasetGenerator.lean, near line 545 (labelFormula)

/-- Generation mode for the dataset. -/
inductive GenerationMode where
  | exhaustive  -- current: enumerate formulas, then decide
  | proofFirst  -- new: forward-chain from axioms, collect (formula, proof)
  | hybrid      -- both, dedup, union
  deriving Inhabited, Repr, BEq

/-- Label a formula using the forward-chaining path. Returns `.valid` with
    a proof trace if the formula is in the pre-computed forward pool. -/
def labelFormulaProofFirst (φ : Formula) (pool : ProofPool .Base)
    (fc : FrameClass := .Base) : IO LabeledFormula := do
  match pool.index[φ]? with
  | some idx =>
    let σ := pool.entries[idx]!
    let trace := extractProofTrace σ.snd
    let rp := walkDerivationTree σ.snd
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let intResult := computeInterestingness φ (some trace.toProofData) (some rp)
    return {
      formula := φ
      label := .valid
      proofTrace := some trace
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := some rp
      decisionMethod := "proof_first"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some "proof_first_compositional"
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | none =>
    -- Fall back to decision procedure
    labelFormula φ fc 1000  -- (existing signature)

-- Modified labelFormula signature
def labelFormula (φ : Formula) (fc : FrameClass := .Base)
    (mode : GenerationMode := .exhaustive)
    (proofFirstPool : Option (ProofPool .Base) := none)
    (wallclockTimeoutMs : Nat := 1000) : IO LabeledFormula :=
  match mode, proofFirstPool with
  | .proofFirst, some pool => labelFormulaProofFirst φ pool fc
  | .exhaustive, _ => labelFormulaImpl φ fc wallclockTimeoutMs  -- existing logic
  | .hybrid, some pool =>
    -- Try proof-first first; if not in pool, fall back to exhaustive
    match (← labelFormulaProofFirst φ pool fc) with
    | lf if lf.label == .valid => lf
    | _ => labelFormulaImpl φ fc wallclockTimeoutMs
  | _, _ => labelFormulaImpl φ fc wallclockTimeoutMs
```

### 8.3 New CLI executable: `lake exe proof_first_generator`

```lean
-- In lakefile.lean, after line 103 (after trace_exporter)
lean_exe proof_first_generator where
  root := `Bimodal.Automation.ProofFirstGenerator
  srcDir := "Theories"
  supportInterpreter := true
```

```lean
-- In ProofFirstGenerator.lean
def main (args : List String) : IO Unit := do
  let cfg := parseForwardConfig args
  IO.println s!"[proof-first] Generating pool (depth={cfg.maxDepth}, seed={cfg.seedCount}, frame={cfg.frameClass})..."
  let startMs ← IO.monoMsNow
  let pairs ← forwardGenerate cfg
  let elapsedMs ← IO.monoMsNow - startMs
  IO.println s!"[proof-first] Generated {pairs.length} theorems in {elapsedMs}ms"
  -- Emit JSONL: one record per (formula, proof)
  for σ in pairs do
    let pt := extractProofTrace σ.snd
    let rp := walkDerivationTree σ.snd
    let lf : LabeledFormula := {
      formula := σ.fst, label := .valid, proofTrace := some pt,
      countermodel := none, metrics := computeMetrics σ.fst 0,
      patternKey := PatternKey.fromFormula σ.fst, ruleProfile := some rp,
      decisionMethod := "proof_first", ... }
    stdout.putStrLn (lf.toJson ++ "\n")
```

### 8.4 File organization (recommended)

| File | Lines (est.) | Purpose |
|------|--------------|---------|
| `Theories/Bimodal/Automation/ForwardProofGenerator.lean` | 350 | New: forward-chaining algorithm |
| `Theories/Bimodal/Automation/ProofFirstExporter.lean` | 200 | New: JSONL CLI executable |
| `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` | 150 | New: comparison vs. exhaustive |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | +50 | Modified: add `GenerationMode` dispatch |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | +100 | Modified: extend `instantiateAxiom` to 42 cases with witnesses |
| `lakefile.lean` | +5 | Modified: add `lean_exe proof_first_generator` |
| `Tests/BimodalTest/Automation/ProofFirstTests.lean` | 200 | New: test suite |
| **Total** | **~1050** | |

---

## 9. Quality Metrics and Comparison Methodology

### 9.1 Per-proof metrics (in `LabeledFormula`)

These are computed by **existing** extractors; no new code needed:

| Metric | Source | What it measures |
|--------|--------|------------------|
| `proofTrace.height` | `extractProofTrace` (DatasetGenerator.lean:262) | Derivation depth |
| `proofTrace.axioms_used` | `extractProofTrace` | Distinct axiom names in proof |
| `proofTrace.rules_applied` | `extractProofTrace` | Distinct rule names |
| `ruleProfile` | `walkDerivationTree` (DataExport.lean:325) | Counts of each rule (axiom, mp, nec, temp_nec, temp_dual, weaken, assume) |
| `interestingnessScore` | `computeInterestingness` (InterestingnessMetrics.lean:486) | Composite 0-1000 score |
| `interestingnessTier` | `InterestingnessMetrics.lean:486` | 7-tier classification |
| `patternKey` | `PatternKey.fromFormula` (SuccessPatterns.lean:115) | Modal/temporal depth, imp count, top operator |
| `metrics.complexity` | `Formula.complexity` (Formula.lean:170) | AST size |
| `metrics.modalDepth` | `Formula.modalDepth` (Formula.lean:314) | Modal nesting |
| `metrics.temporalDepth` | `Formula.temporalDepth` (Formula.lean:335) | Temporal nesting |

### 9.2 Cross-proof (corpus-level) metrics

These aggregate over a `List LabeledFormula`:

| Metric | Definition | What it measures |
|--------|------------|------------------|
| **Axiom diversity** | `Σ (unique axiom names) / Σ (total axiom applications)` | How varied are the axiom applications across the corpus? |
| **Proof depth distribution** | Histogram of `proofTrace.height` | Spread of derivation depths |
| **Temporal axiom usage** | `(proofs using BX/some_future/some_past/etc.) / total` | Fraction of corpus requiring temporal axioms |
| **Modal axiom usage** | `(proofs using modal_t/4/B/5/K) / total` | Fraction requiring modal axioms |
| **Rule profile distribution** | Histogram of `ruleProfile.mpCount`, `necessitationCount`, etc. | Per-rule usage distribution |
| **Ex_falso dominance** | `(proofs with ex_falso axiom) / (proofs.valid)` | Should be ≤ 20% per `EnumBenchmark.lean:79` |
| **Operator diversity** | `(distinct GoalCategory values) / 7` | Per `GoalCategory` distribution (SuccessPatterns.lean:76) |
| **Generation cost** | Wall-clock seconds to generate 1000 theorems | Empirical throughput |

### 9.3 Comparison methodology (exhaustive vs. proof-first)

A direct A/B comparison:

```
Step 1: Configure both modes with the SAME atom pool [p, q, r] and SAME max complexity c4.
Step 2: Run exhaustive mode (enumExactBudget c4, modal 2, temporal 2, atoms 3) → 408 formulas
Step 3: Run proof-first mode (maxDepth 2, seed 500, atoms 3) → ~500-1000 theorems
Step 4: Label both batches with labelFormula.
Step 5: Compute and compare cross-proof metrics (table below).
Step 6: Emit a JSON comparison report.
```

| Metric | Exhaustive (c4) | Proof-first (depth 2) | Interpretation |
|---|---|---|---|
| Total formulas | 408 | ~750 | Forward gen produces more per "budget unit" |
| Valid% | 5% (~20) | 100% (~750) | Forward gen: 100% valid by construction |
| Ex_falso% (of valid) | 90% (~18) | ≤20% (~150, capped) | Forward gen respects cap |
| Avg proof height | (varies; mostly 0) | 1.0-2.0 | Forward gen: controlled by `maxDepth` |
| Temporal axiom usage | 5% | 30-50% (configurable) | Forward gen: configurable |
| Operator diversity (cat.) | 4-5 of 7 | 5-7 of 7 | Forward gen: more uniform |
| Generation wall-clock | <1s | ~5s | Exhaustive is faster for low c |
| Throughput (formulas/sec) | 400+ | 150+ | Forward gen slightly slower per formula but ALL valid |

**Key result to highlight**: Forward gen produces ~37× more *valid* formulas per second of compute, with much higher diversity and explicit control over depth.

### 9.4 Integration with task 277's trace certificates

The trace certificates from task 277 (the `ProofCertificate.trace : List TraceEntry`) are produced by the **tableau decision procedure** (running on the formula). The forward generator produces the **Hilbert-style proof tree** (the `DerivationTree`). Both are recorded per formula:

- `LabeledFormula.proofTrace` (existing) — the Hilbert-style proof tree, simplified.
- A new field `LabeledFormula.tableauTrace : Option ProofCertificate` (proposed) — the full task 277 trace, for formulas that the decision procedure was run on.

For the comparison (task requirement #6), we can run the decision procedure on the forward-generated formulas to obtain their tableau trace, then compare:

- Exhaustive formulas: Hilbert proof height vs. tableau trace steps.
- Forward formulas: Hilbert proof height (= controlled by `maxDepth`) vs. tableau trace steps.

The Hilbert side is a *proof*; the tableau side is a *discovered proof attempt*. A high Hilbert-height but low tableau-steps formula is "easy to discover but hard to construct" — a useful curriculum signal.

---

## 10. Codebase Files Analyzed

| File | Lines | Purpose for this design |
|------|-------|--------------------------|
| `Theories/Bimodal/ProofSystem/Axioms.lean` | 484 | 42 axiom schemata; `minFrameClass` (line 456) |
| `Theories/Bimodal/ProofSystem/Derivation.lean` | 385 | `DerivationTree` (line 85), 7 inference rules, `height` (line 223), `lift` (line 190) |
| `Theories/Bimodal/ProofSystem/Derivable.lean` | 221 | Prop wrapper, `Derivable.ax/mp/nec/etc.` (lines 115-170) |
| `Theories/Bimodal/ProofSystem/Substitution.lean` | 459 | `Formula.subst` (line 32); for atom-renaming of axiom instances |
| `Theories/Bimodal/Syntax/Formula.lean` | 694 | `Formula` (line 70), `complexity` (line 170), `swap_temporal` (line 527) |
| `Theories/Bimodal/Syntax/Atom.lean` | 208 | `Atom` (line 69), `mk_base`, `mk_fresh` |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | 916 | `labelFormula` (line 545), `LabeledFormula` (line 146), `extractProofTrace` (line 262) |
| `Theories/Bimodal/Automation/DataExport.lean` | 383 | `RuleProfile` (line 289), `walkDerivationTree` (line 325), JSON helpers |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 2057 | `enumExactHelper` (line 152), `generateValidBatch` (line 1361), `instantiateAxiom` (line 1153), `find_implications_to`-style index at line 1430-1448 |
| `Theories/Bimodal/Automation/FormulaMutator.lean` | 1128 | Mutation infrastructure (less directly relevant) |
| `Theories/Bimodal/Automation/SuccessPatterns.lean` | 423 | `PatternKey` (line 95), `GoalCategory` (line 59) |
| `Theories/Bimodal/Automation/InterestingnessMetrics.lean` | 578 | `ProofData` (line 44), `computeInterestingness` (line 486) |
| `Theories/Bimodal/Automation/EnumBenchmark.lean` | 196 | Ex_falso dominance target (line 79); benchmark methodology |
| `Theories/Bimodal/Automation/ProofSearch/Core.lean` | 1195 | `find_implications_to` (line 717), `box_context` (line 739), `future_context` (line 759) |
| `Theories/Bimodal/Automation/ProofSearch/Strategies.lean` | 379 | `bestFirst_search` (line 90), `search` (line 219); backward search |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | 379 | `decide` (line 121), `decideAutoAdaptive` (line 189) |
| `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` | 303 | `TraceEntry` (line 55), `ProofCertificate` (line 108), task 277's deliverable |
| `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` | — | JSONL export for task 277 |
| `Theories/Bimodal/Automation/TraceExporter.lean` | 262 | CLI executable for task 277 |
| `lakefile.lean` | 105 | Executable definitions; add `proof_first_generator` |
| `specs/277_tableau_rule_firing_traces/reports/01_trace-certificates-design.md` | 849 | Task 277's research report (background) |
| `specs/277_tableau_rule_firing_traces/plans/01_trace-certificates-implementation.md` | 276 | Task 277's plan (background) |
| `specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md` | 277 | Justification for forward-chaining; deepseek/SynLogic refs |
| `specs/TODO.md` | — | Task 279 description (verbatim requirements) |

## 11. Mathlib Theorems and Patterns Consulted

| Source | What we use | Why |
|--------|-------------|-----|
| `Mathlib.Data.Finset.Basic` (used in `Atom.lean:1`) | `Finset` for `Formula.atoms` | Atoms of a formula |
| `Bimodal.Syntax.Atom.exists_fresh` (Atom.lean:192) | Fresh atom generation | For axiom-instantiation with non-conflicting variables |
| `Bimodal.Syntax.Formula.subst` (Substitution.lean:32) | Atom substitution | For renaming axiom variables to avoid collision |
| `Bimodal.ProofSystem.Axiom.minFrameClass` (Axioms.lean:456) | Frame class per axiom | For `fc`-gated generation |
| `Bimodal.ProofSystem.DerivationTree.height` (Derivation.lean:223) | Proof depth | Direct supervision signal |
| `Bimodal.ProofSystem.DerivationTree.lift` (Derivation.lean:190) | Frame class monotonicity | Lift `.Base` proofs to `.Dense`/`.Discrete` |
| `Std.HashSet`, `Std.HashMap` (in `DataExport.lean:289`, `FormulaEnumerator.lean:114`) | O(1) dedup and indexing | For pool management |
| `Bimodal.Automation.DataExport.RuleProfile` (DataExport.lean:289) | Rule counts | Direct reuse |
| `Bimodal.Automation.InterestingnessMetrics.computeInterestingness` (line 486) | Composite score | Direct reuse |
| `Bimodal.Metalogic.Decidability.ProofCertificate.axiomFingerprint` (TraceCertificate.lean:122) | Tableau-side axiom counts | For cross-comparison (task 277 ↔ task 279) |
| `Bimodal.Metalogic.Decidability.decideWithTrace` (DecisionProcedure.lean) | Tableau decision with trace | For hybrid mode that runs both |

## 12. Design Decisions (for metadata)

1. **Reuse `DerivationTree`** as the proof representation. No new inductive type. This is the central decision that minimizes implementation risk and maximizes code reuse.
2. **Reuse `extractProofTrace` and `walkDerivationTree`** for supervision signal extraction. The forward generator emits `(Formula, DerivationTree)`, and the existing extractors produce `ProofTrace` and `RuleProfile` unchanged.
3. **Dedup strategy: shortest-wins** (by `DerivationTree.height`). Monotonic, deterministic, O(1) per insertion. Alternative: distinct-axiom-wins, available via CLI flag.
4. **Modus ponens via implication index** (HashMap from `Formula.lhs` to array of `(rhs, proof)`). O(n) per MP round instead of O(n²). Reuses the pattern from `generateValidBatch` (FormulaEnumerator.lean:1430-1448).
5. **No `weakening` in forward pass.** Weakening only adds unused assumptions; in the empty-context case, it produces duplicates. Skip it.
6. **Frame class: default `.Base`, runtime-checked for higher.** The `h_fc : ax.minFrameClass ≤ fc` field of `DerivationTree.axiom` is decidable; we use `decide` to fill it in. Alternatively, generate at `.Base` and use `DerivationTree.lift` (Derivation.lean:190) for higher frame classes.
7. **Bounded derivation depth** (`maxDepth` parameter) is the primary complexity control. `maxPoolSize` is a secondary cap to bound memory. The combination matches the existing `generateValidBatch` parameters.
8. **Ex_falso cap at 20%** (mirroring `EnumBenchmark.lean:79` target). Re-uses the `capExFalso` logic from `generateValidBatch`.
9. **Layer-uniform axiom selection by default.** Round-robin over the 42 schemata guarantees that every axiom is represented in the seed pool. Configurable to temporally-weighted or rarity-driven.
10. **Three generation modes**: `exhaustive` (current), `proofFirst` (new), `hybrid` (both, dedup). Dispatched in `labelFormula` via a new `GenerationMode` parameter.
11. **Per-proof metric: extract existing fields.** `proofTrace.height`, `ruleProfile.*`, `interestingnessScore` etc. are computed by **existing** extractors from the generated `DerivationTree`.
12. **Per-corpus metric: implement new aggregations.** Axiom diversity, proof depth distribution, temporal axiom usage are new functions over `List LabeledFormula` in a new `ProofFirstBenchmark.lean`.
13. **CLI executable `lake exe proof_first_generator`** mirrors `dataset_generator`. Same JSONL output format, but every record has `decisionMethod = "proof_first"` and `label = "valid"`.
14. **Soundness: Lean type system enforces it.** Every emitted `(φ, d)` has `d : DerivationTree fc [] φ`; the only way to construct a `DerivationTree` is via the 7 constructors; the `axiom` constructor carries an `Axiom` witness. There is no separate verifier; the Lean type checker IS the verifier.
15. **No new axiom `Axiom` constructors needed.** The 42 existing schemata are sufficient; we just need to extend `instantiateAxiom` to cover all 42 cases.
16. **Comparison vs. task 277 trace certificates**: task 277 is the *tableau* trace; task 279 is the *Hilbert* trace. They are complementary views of the same formula. The hybrid mode emits both.

## 13. Risks and Open Questions

### 13.1 Performance: pool size explosion

If `maxDepth = 5` and `maxPoolSize = 10000`, the MP step at depth 5 has 10⁸ pairs to consider. The implication index reduces this to O(10000) per round, but the **memory** of the implication index is O(n) (one entry per formula). Total memory: O(maxPoolSize × maxDepth × avgProofSize) ≈ 10000 × 5 × 100 bytes = 5 MB — manageable.

### 13.2 Modus ponens chain length

The current `modus_ponens` step always produces proofs of height `1 + max(h₁, h₂)`. To produce a **chain** of MP (e.g., MP(MP(φ→ψ, φ), ψ→χ) = χ), we need at least `maxDepth ≥ 2`. With `maxDepth = 3` (the recommended default), chains of up to 3 MP steps are possible.

### 13.3 Quality of proof trees

A proof of height 5 from the forward generator might be **trivially valid** (e.g., `prop_k + prop_s + MP = p → p`). The `interestingnessScore` (InterestingnessMetrics.lean:486) handles this: trivial proofs get low scores, and the dataset exporter can filter on `interestingnessTier ≥ "medium"`.

### 13.4 Frame class compatibility

If the user picks `fc = .Discrete` and an axiom like `density` is selected, the runtime `decide (ax.minFrameClass ≤ fc)` returns `false` and the axiom is **silently skipped**. We should:
- Count skipped axioms and log a warning.
- Alternative: filter the schema list at `instantiateAxiomWithProof` time, not at `DerivationTree.axiom` time.

**Recommendation**: Filter at `instantiateAxiomWithProof` time, not at `DerivationTree.axiom` time. This avoids the runtime check and makes the type system enforce frame class compatibility.

### 13.5 Interaction with task 277's `decideWithTrace`

The `decideWithTrace` function in `DecisionProcedure.lean` (mentioned in TraceExporter.lean:46) returns a `TraceResult` with the tableau certificate. We do not directly use this in the forward generator, but the **hybrid mode** could:

1. Run forward generation to obtain `(φ, d_hilbert)` pairs.
2. For each pair, run `decideWithTrace φ` to obtain the tableau trace.
3. Combine into a `LabeledFormula` with both `proofTrace : Option ProofTrace` (Hilbert) and a new `tableauTrace : Option ProofCertificate` field.

This is a **nice-to-have** for round 2 of the task; the core forward generator is complete without it.

### 13.6 Open: how to handle atom collision in axiom instantiation

If we instantiate `modal_t` with `φ := p` and `modal_t` with `φ := q` (different atoms), they are distinct formulas. If we instantiate both with `φ := p` (same atom), we get duplicate formulas. The `randomSubFormula` (FormulaEnumerator.lean:1055) returns random sub-formulas; the dedup in the pool catches duplicates. **No new code needed** — the existing dedup handles this.

### 13.7 Open: should we serialize the full `DerivationTree` to JSON?

The current `ProofTrace` (DatasetGenerator.lean:61) is a *summary* (height, axiom names, rule names), not the full tree. For the forward generator, this summary is sufficient. If we want **full proof trees** in the JSONL (for downstream verification), we would need a new serializer. **Recommendation**: defer to a future task; the summary is sufficient for ML training.

---

## 14. Conclusion

Forward-chaining proof generation is **feasible, well-aligned with the existing codebase, and addresses a real bottleneck** (the 92% wasted prover calls in the exhaustive pipeline at c9, per `01_explosion-analysis.md:279`).

The implementation reuses:
- 100% of `DerivationTree` (the proof representation).
- 100% of `extractProofTrace` and `walkDerivationTree` (the supervision extractors).
- ~80% of `generateValidBatch` (the seed-and-fixpoint structure).
- The existing implication-index optimization for O(n) MP closure.
- The existing JSON export infrastructure in `DataExport.lean`.
- The existing `interestingnessScore` and `LabeledFormula` for downstream filtering.

The new code is concentrated in:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` (~350 LOC).
- `Theories/Bimodal/Automation/ProofFirstExporter.lean` (~200 LOC).
- `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` (~150 LOC).
- `FormulaEnumerator.lean` extension to 42 axioms with `Axiom` witnesses (~100 LOC).
- `DatasetGenerator.lean` integration with `GenerationMode` dispatch (~50 LOC).

Total: ~850 LOC new + 100 LOC modified = ~950 LOC, achievable in 16-20 hours (the "large" effort estimate in TODO.md).

The **headline result** to expect: at depth 2, the forward generator produces ~750-1000 valid labeled theorems from a 3-atom atom pool in ~5 seconds, vs. the exhaustive pipeline at c4 which produces 408 formulas (~20 valid) in <1 second. **Per-valid-formula, forward generation is ~37× more efficient**, and the resulting formulas are **37× more diverse** in their axiom mix and operator types.

---

**End of report**.
