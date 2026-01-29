# Research Report: Task #625 (Supplementary)

**Task**: Prove the `decide_complete` theorem
**Date**: 2026-01-29
**Focus**: Full Proof Reconstruction from Closed Branches - Analysis of Non-Goal

## Summary

The implementation plan lists "Full proof reconstruction from closed branches" as a Non-Goal, noting it "would require substantial infrastructure." This supplementary research analyzes exactly what such reconstruction would amount to, what it would provide, and what infrastructure changes would be required. The analysis reveals that full proof reconstruction is a substantial undertaking requiring new data structures, bidirectional type correspondence proofs, and potentially modifications to the tableau algorithm itself.

## Findings

### 1. The Current Gap: Tableau Validity vs. Proof Terms

The core challenge can be understood by examining the types involved:

**What Tableau Closure Provides:**
```lean
-- ClosedBranch from Closure.lean
structure ClosedBranch where
  branch : Branch  -- List SignedFormula
  reason : ClosureReason

inductive ClosureReason : Type where
  | contradiction (phi : Formula)
  | botPos
  | axiomNeg (phi : Formula) (witness : Axiom phi)
```

**What `decide_complete` Needs:**
```lean
-- DerivationTree from Derivation.lean
inductive DerivationTree : Context -> Formula -> Type where
  | axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) : DerivationTree Gamma phi
  | assumption (Gamma : Context) (phi : Formula) (h : phi elem Gamma) : DerivationTree Gamma phi
  | modus_ponens (Gamma : Context) (phi psi : Formula)
      (d1 : DerivationTree Gamma (phi.imp psi))
      (d2 : DerivationTree Gamma phi) : DerivationTree Gamma psi
  | necessitation (phi : Formula)
      (d : DerivationTree [] phi) : DerivationTree [] (Formula.box phi)
  -- ... other rules
```

**The Semantic Gap:**
- Tableau closure tells us: "There is no model satisfying F(phi), therefore phi is valid"
- What we need: A syntactic proof `DerivationTree [] phi` using the TM proof system rules

These are related by completeness, but the current infrastructure only proves one direction indirectly.

### 2. What the Current Implementation Does

From `ProofExtraction.lean`, the current approach is limited:

```lean
def extractFromClosureReason (reason : ClosureReason) : Option (Sigma phi : Formula, DerivationTree [] phi) :=
  match reason with
  | .axiomNeg phi ax =>
      -- Only handles cases where the goal itself is an axiom
      some (phi, proofFromAxiom phi ax)
  | .contradiction _ =>
      -- Cannot extract proof from propositional contradiction
      none
  | .botPos =>
      -- Cannot extract proof from T(bot)
      none
```

**Why This Is Incomplete:**

1. **Axiom closures**: Only work when the negated formula is exactly the goal formula. If the tableau branches and closes via an axiom on a subformula, no proof is extracted.

2. **Contradiction closures**: When T(psi) and F(psi) both appear on a branch, the branch closes, but we don't construct a proof term. The contradiction might be derived through multiple expansion steps.

3. **Bottom closures**: T(bot) is impossible but doesn't give a direct proof of the original formula.

### 3. What Full Proof Reconstruction Would Amount To

Full proof reconstruction would require building a `DerivationTree [] phi` for any formula phi where `buildTableau phi fuel = some (.allClosed branches)`.

**Algorithm Sketch:**

The reconstruction would need to work backwards from closure points to the root:

```
Given: Tableau starting from [F(phi)] with all branches closed

For each closed branch b with closure reason r:
  1. If r = axiomNeg(psi, ax):
     - Start with DerivationTree.axiom [] psi ax
     - Transform backwards through expansion steps

  2. If r = contradiction(psi):
     - We have T(psi) and F(psi) somewhere in the branch
     - Need to construct: psi and (psi -> bot) -> phi
     - Use ex_falso to derive phi from contradiction

  3. If r = botPos:
     - We have T(bot) in the branch
     - Use bot -> phi to derive phi

For branching points:
  - If branch split into [b1, ..., bn] and all close
  - Need to combine proofs: This corresponds to proof by cases
  - For impPos (T(A -> B) splits into F(A) | T(B)):
    Need: proof of phi from A -> B
```

### 4. Required Infrastructure

#### 4.1 Enhanced Closure Tracking

Current `ClosedBranch` only records the final branch contents and reason. We would need:

```lean
-- Enhanced structure tracking the full expansion history
inductive TableauTree (root : SignedFormula) : Type where
  | closed (branch : Branch) (reason : ClosureReason)
           (history : ExpansionHistory)
  | branching (rule : TableauRule) (sf : SignedFormula)
              (children : List (TableauTree ...))

structure ExpansionHistory where
  -- The sequence of rule applications from root to closure
  steps : List (TableauRule times SignedFormula times RuleResult)
```

**Estimated Effort**: Medium (20-40 hours)
- Modify `expandBranchWithFuel` to track history
- Thread history through `buildTableau`
- Design appropriate indexing for efficient lookup

#### 4.2 Correspondence Proofs

We need to prove that tableau rules correspond to proof system rules:

```lean
-- For each tableau rule, we need a lemma like:
theorem impNeg_correspondence (Gamma : Context) (A B phi : Formula)
    (hA : DerivationTree Gamma A) (hB : DerivationTree Gamma (B.imp phi)) :
    DerivationTree Gamma ((A.imp B).imp phi) := by
  -- Construct using modus_ponens and propositional tautologies
  sorry

-- More generally:
theorem rule_soundness (rule : TableauRule) (sf : SignedFormula) (result : RuleResult)
    (h : applyRule rule sf = result) (phi : Formula) :
    match result with
    | .linear formulas =>
        (forall sf' in formulas, ProofObligation sf' phi) -> ProofObligation sf phi
    | .branching branches =>
        (forall branch in branches, (forall sf' in branch, ProofObligation sf' phi) -> ProofObligation sf phi)
    | .notApplicable => True
```

**Estimated Effort**: High (40-80 hours)
- 14 tableau rules, each needing correspondence proofs
- Propositional rules need propositional tautology lemmas
- Modal/temporal rules need derived rules for box/all_future/all_past

#### 4.3 Proof Reconstruction Algorithm

The actual reconstruction algorithm:

```lean
def reconstructProof (phi : Formula) (tree : TableauTree (SignedFormula.neg phi)) :
    DerivationTree [] phi := by
  match tree with
  | .closed branch reason history =>
      -- Use history to trace back and build proof
      sorry
  | .branching rule sf children =>
      -- Recursively reconstruct from children, combine at branching point
      sorry
```

**Key Complexity**: At branching points, we need to show:
- "If phi is provable assuming B1, and phi is provable assuming B2, then phi is provable assuming B1 or B2"
- This requires encoding case analysis in the Hilbert-style proof system

**Estimated Effort**: High (60-100 hours)
- Algorithm design and implementation
- Termination proof (well-founded on tree structure)
- Correctness proof that output has correct type

#### 4.4 Propositional Infrastructure

Many reconstructions need propositional tautologies like:

```lean
-- Needed for contradiction cases
theorem or_elim (Gamma : Context) (A B C : Formula)
    (hAC : DerivationTree Gamma (A.imp C))
    (hBC : DerivationTree Gamma (B.imp C)) :
    DerivationTree Gamma ((A.or B).imp C)

-- Needed for combining branches
theorem case_split (Gamma : Context) (A B phi : Formula)
    (h1 : DerivationTree Gamma (A.imp phi))
    (h2 : DerivationTree Gamma (A.neg.imp phi)) :
    DerivationTree Gamma phi

-- Ex falso for contradiction closures
theorem exfalso_derived (Gamma : Context) (A phi : Formula)
    (hA : DerivationTree Gamma A)
    (hNA : DerivationTree Gamma A.neg) :
    DerivationTree Gamma phi
```

**Note**: Some of these may exist in the codebase; need to audit `Bimodal.Theorems`.

**Estimated Effort**: Medium (20-40 hours)
- Audit existing propositional lemmas
- Implement missing derived rules
- Prove well-typed

### 5. What Full Reconstruction Would Provide

**Benefits:**

1. **Stronger Completeness**: `decide_complete` could return an actual proof term in all cases, not just axiom instances.

2. **Proof Object Extraction**: Users could extract and inspect the proof that the decision procedure found.

3. **Verification Independence**: The proof term can be independently verified without trusting the tableau implementation.

4. **Proof Optimization**: Could potentially simplify the extracted proof to remove redundant steps.

5. **Educational Value**: Understanding the mapping from semantic (tableau) to syntactic (derivation) proofs.

**Current Workarounds Without It:**

- Use `Classical.choice` to assert proof existence (loses constructivity)
- Weaken theorem to `exists fuel, (decide phi 10 fuel).isValid = true` (loses proof term)
- Rely on `bounded_search_with_proof` for proof terms (works for simple cases)

### 6. Complexity Assessment

| Component | Estimated Hours | Difficulty | Dependencies |
|-----------|-----------------|------------|--------------|
| Enhanced Closure Tracking | 20-40 | Medium | Modify Saturation.lean |
| Rule Correspondence Proofs | 40-80 | High | Propositional tautologies |
| Proof Reconstruction Algo | 60-100 | High | All above |
| Propositional Infrastructure | 20-40 | Medium | Axioms.lean |
| Testing & Integration | 10-20 | Low | All above |
| **Total** | **150-280** | **High** | |

This represents approximately 4-8 weeks of focused work.

### 7. Alternative Approaches

**Option A: Selective Reconstruction**
Only reconstruct proofs for specific common patterns (axioms, simple propositional, basic modal). Accept `sorry` for complex cases.
- Effort: 40-80 hours
- Coverage: ~60-80% of practical cases

**Option B: Trusted Computing Base**
Accept that tableau validity implies provability as an axiom:
```lean
axiom tableau_implies_provable (phi : Formula)
    (h : buildTableau phi fuel = some (.allClosed _)) :
    exists proof, DerivationTree [] phi
```
- Effort: 1 hour
- Trade-off: Larger trusted base, no proof extraction

**Option C: External Proof Checker**
Export tableau trace, use external tool to verify and optionally reconstruct proof.
- Effort: 20-40 hours (Lean side)
- Trade-off: Adds external dependency

## Recommendations

### For Task 625 (Current Scope)

1. **Use the existing approach**: `tableau_complete` establishes validity semantically, then attempt proof extraction via existing `tryAxiomProof` and `bounded_search_with_proof`.

2. **Accept partial gaps**: If proof extraction fails for some valid formula, return `.timeout` rather than incorrectly claiming invalidity. Document this limitation.

3. **Consider weaker statement**: If necessary, prove:
   ```lean
   theorem decide_complete_weak (phi : Formula) (hvalid : phi valid) :
       exists fuel, (decide phi 10 fuel).isValid = true
   ```
   This is still meaningful - it shows the decision procedure correctly classifies valid formulas.

### For Future Work

1. **Create dedicated task**: Full proof reconstruction should be a separate multi-phase task (likely 2-4 subtasks).

2. **Start with correspondence proofs**: The propositional rule correspondences are the cleanest starting point and provide immediate value.

3. **Consider type-theoretic approach**: Rather than reconstructing proofs post-hoc, could potentially modify the tableau to carry proof fragments during expansion.

4. **Benchmark first**: Before major investment, benchmark how often the current extraction fails for practical formulas.

## References

- `Theories/Bimodal/ProofSystem/Derivation.lean` - DerivationTree definition
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Closure.lean` - ClosedBranch and ClosureReason
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Saturation.lean` - buildTableau and expansion
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/ProofExtraction.lean` - Current extraction logic
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/DecisionProcedure.lean` - decide function
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Tableau.lean` - TableauRule definitions

## Next Steps

For Task 625:
1. Proceed with implementation using existing infrastructure
2. Document the proof extraction gap in code comments
3. Use appropriate fallbacks (proof search, weaker statement) as needed

For future proof reconstruction:
1. Create separate planning task when ready to pursue
2. Start with correspondence lemmas as first subtask
3. Design enhanced data structures before implementation
