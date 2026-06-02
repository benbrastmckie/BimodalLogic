# Research Report: Tableau Termination and Blocking Strategies for S5+LTL

- **Task**: 261 - Dataset Quality and Stall Diagnosis (Deep Follow-Up)
- **Started**: 2026-06-02T15:00:00Z
- **Completed**: 2026-06-02T16:30:00Z
- **Effort**: high (16+ hours)
- **Dependencies**: Task 261 Round 1 report (01_dataset-quality-stall.md)
- **Sources/Inputs**: Saturation.lean, Tableau.lean, Closure.lean, SignedFormula.lean, literature survey
- **Artifacts**: specs/261_dataset_quality_and_stall_diagnosis/reports/02_tableau-termination-literature.md
- **Standards**: status-markers.md, artifact-management.md, report-format.md

## Executive Summary

This deep follow-up examines the tableau decision procedure from a logic/theory perspective, complementing the code-level bug analysis in Round 1. The investigation covers:

1. **Standard tableau methods for S5 and LTL** and how they differ from the current implementation
2. **Blocking and loop-checking strategies** from the literature, with analysis of which are appropriate
3. **Known complexity results** for S5+LTL combinations
4. **The boxPos persistent rule loop** analyzed through the lens of standard tableau theory
5. **Recommendations** grounded in production reasoner practice

The core finding is that the current implementation's architecture broadly follows standard labeled tableau design, but has three structural gaps relative to established methods: (a) lack of proper eventuality enforcement in blocking, (b) exponential fuel sharing on branch splits, and (c) the persistent-consumable rule interaction that was partially fixed by the AppliedSet mechanism in Task 261. The literature suggests additional improvements based on global caching, one-pass eventuality checking, and the hypertableau pattern.

---

## 1. Tableau Methods for S5 Modal Logic

### 1.1 Standard S5 Tableau Design

S5 modal logic has the special property that the accessibility relation is an equivalence relation (reflexive, symmetric, transitive). This means every world can access every other world within the same equivalence class. Standard tableau methods exploit this in several ways:

**Fitting's Prefixed Tableau for S5**: In Fitting's approach (Fitting 1983), each formula on a branch carries a "prefix" (world label). The box rule for S5 states: if `sigma T(box phi)` is on the branch, then for every prefix `sigma.n` that appears on the branch, `sigma.n T(phi)` must also appear. The key termination mechanism is the **"not yet on branch" check**: new formulas are added only if they are not already present on the branch. Since the set of possible prefixed formulas is bounded by the subformula closure, this guarantees termination.

**Massacci's Single Step Tableau (SST) for S5**: Massacci (2000) showed that minimal conditions on SST search strategies yield NP-time decision procedures for S5 (matching the known NP-completeness of S5-SAT). The key insight is that for S5, the equivalence relation can be handled "globally" -- box formulas propagate to all worlds simultaneously, eliminating the need for incremental propagation.

**The Critical S5 Design Pattern**: In all standard S5 tableaux, the box rule is handled as follows:
1. `T(box phi)` is **persistent** -- it remains on the branch.
2. When a **new world** is introduced (by an existential rule like `boxNeg` or `diamondPos`), the contents of `T(box phi)` are propagated to the new world at that time.
3. The propagation is guarded by a **membership test**: if `T(phi)` already exists at the target world, no duplicate is added.
4. The box rule is **not re-triggered** by the consumption of propagated formulas. The standard approach is that once `T(phi)` has been derived at world `w` from `T(box phi)`, this derivation is recorded and not repeated even if `T(phi)` is later consumed.

### 1.2 How the Current Implementation Compares

The current Tableau.lean implementation (`applyRule .boxPos`) follows the standard pattern in most respects:
- `T(box phi)` is marked as `persistent` (line 373)
- Propagation targets all `knownWorlds` on the branch
- A `branch.contains newSf` check prevents duplicate additions

**The gap** (identified in Round 1 and partially fixed): The standard approach assumes that once a formula is derived, it stays derived. The current implementation's `expandOnce` function can remove formulas from the branch (via consumable rule application), causing `boxPos` to "see" the derived formula as missing and re-derive it. The `AppliedSet` mechanism added in Task 261 addresses this by tracking formulas that have been produced by persistent rules, preventing re-application when all outputs are already in the applied set.

### 1.3 Comparison with Production S5 Reasoners

Production description logic reasoners like HermiT and FaCT++ handle the analogous problem (universal role restrictions, equivalent to box in S5) using:

- **Completion-based expansion**: Rather than repeatedly scanning the branch for applicable rules, they maintain a worklist of "pending" rule applications. Universal rules are triggered once when a new individual is created, not re-scanned.
- **Anywhere pairwise blocking**: HermiT uses "anywhere pairwise blocking" where an individual s is blocked by another individual t if the labels of s are a subset of the labels of t. This prevents redundant model construction.
- **The "yo-yo" problem**: The interaction between universal rules (forall/box) and existential rules (exists/diamond) creating infinite cycles is called the "yo-yo" problem in description logic. HermiT's hypertableau calculus solves this with pruning rules that prevent merge-create cycles.

---

## 2. Tableau Methods for Linear Temporal Logic (LTL)

### 2.1 Two-Phase vs. One-Pass Approaches

LTL tableau methods fall into two major families:

**Two-Phase (Wolper 1985, Vardi-Wolper 1986)**: Phase 1 constructs a graph of "atoms" (maximal consistent sets of subformulas). Phase 2 checks whether eventualities are fulfilled. The graph is finite (bounded by 2^n atoms for n subformulas), guaranteeing termination. Complexity: PSPACE-complete (matching the known PSPACE-completeness of LTL-SAT).

**One-Pass (Schwendimann 1998, Reynolds 2016)**: These combine both phases into a single tree-shaped construction. Key features:
- Branches are closed with a loop as soon as a label repeats
- Eventuality checking is done on-the-fly
- If a loop satisfies all eventualities, a positive answer is returned; otherwise the branch is discarded

### 2.2 Reynolds' PRUNE Rule

Reynolds (2016) introduced a particularly elegant one-pass approach. The PRUNE rule applies when three "step nodes" u < v < w have the same label (same set of formulas). The rule checks: for every Until-eventuality requested at u, if it is fulfilled between v and w, is it also fulfilled between u and v? If yes, the branch can be pruned (the cycle is productive). If no, the branch is discarded (the cycle is defective -- it defers eventualities forever without fulfilling them).

This is directly relevant to the `U(bot, X)` timeout pattern identified in Round 1: `T(U(bot, X))` at time t branches into either:
- Event witness: `T(bot)` at fresh time t' (immediately closes via `botPos`)
- Guard continue: `T(X)` at t', `T(U(bot, X))` at t'

The guard-continue branch re-introduces the Until at a fresh time, creating an infinite chain. The PRUNE rule would detect that this chain is non-productive (the eventuality `bot` is never fulfilled) and close it.

### 2.3 How the Current Implementation Handles LTL

The current implementation uses:
- **Fuel-based termination** (`expandBranchWithFuel`) rather than structural termination
- **Subset blocking** (`isTemporallyBlocked` in SignedFormula.lean) to detect repeated time-types
- **EventualityTracker** to register and check fulfillment of Until/Since obligations

The subset blocking implementation (lines 596-620 of SignedFormula.lean) compares "time types" -- the set of (sign, formula) pairs at each time point. If `type(t_new) subset type(t_ancestor)`, expansion at `t_new` is blocked.

**Gap 1: Eventuality enforcement in blocking**. The current `isSubsetBlocked` check verifies type inclusion but does NOT verify that all pending eventualities at the blocked time are fulfilled or fulfillable. Standard approaches (Schwendimann, Reynolds) require eventuality checking as part of the blocking/loop condition. Without this, the system can block a time point that has unfulfilled eventualities, potentially leading to unsound results (treating a satisfiable formula as unsatisfiable because the only way to fulfill the eventuality was through the blocked branch).

**Gap 2: No PRUNE-style detection**. The `EventualityTracker` registers and checks eventualities, but this information is not used in the blocking decision. The tracker is updated but its findings do not feed back into the termination condition.

---

## 3. Tableau Methods for Combined S5+LTL (Fusion/Product)

### 3.1 Fusion vs. Product

The TM logic combines S5 modal logic with linear tense logic. The exact nature of the combination matters:

- **Fusion** (independent join): The two sets of operators do not interact. Formulas can contain both box and G/H, but no interaction axioms like `box(phi) -> G(phi)` are imposed. Fusion preserves decidability, the finite model property, and completeness from component logics (Kracht-Wolter transfer theorem, Fine-Schurz).
- **Product**: Operators interact via commutativity/Church-Rosser axioms. Products can have much higher complexity -- `Log(N,<) x S5` is EXPSPACE-hard.
- **Dependent combination**: Custom interaction axioms (like the `boxTemporal` rule: `T(box phi) -> T(G phi), T(H phi)`) create a dependent combination that lies between fusion and product.

The TM logic is a **dependent combination** of S5 and linear tense logic, with the interaction axiom `box(phi) -> G(phi) and H(phi)` (necessitation implies temporal permanence). This is sound because in TM semantics, box quantifies over all worlds at all times, which entails G and H.

### 3.2 Complexity Implications

- **S5 satisfiability**: NP-complete
- **LTL satisfiability**: PSPACE-complete
- **S5 fusion S5**: PSPACE-complete (complexity can jump)
- **Fusion of S5 + LTL**: At least PSPACE-hard (inheriting from LTL), decidable (by transfer theorem)
- **TM (S5 + LTL with interaction)**: Decidable (this project has a formal FMP proof). The interaction axioms do not break decidability because they only add consequences (no new quantifier alternations).

### 3.3 The Finite Model Property for TM

The project has a formal proof of the Finite Model Property (FMP) for TM logic, located in `Theories/Bimodal/Metalogic/Decidability/FMP/`. The FMP guarantees that if a formula is satisfiable, it has a model with a bounded number of worlds and time points. This bound is derived from the subformula closure size, giving a `soundFuel` calculation of `n * 2^n` (capped at 100000).

The FMP is the theoretical foundation for termination. The key chain of reasoning:
1. FMP: satisfiable formulas have models of bounded size
2. Subformula property: tableau rules only produce subformulas
3. Pigeonhole: after enough distinct time types, a repeat must occur
4. Blocking detects the repeat and halts expansion

### 3.4 Interaction Between Modal and Temporal Rules

The `boxTemporal` rule (Tableau.lean line 472) derives `T(G phi)` and `T(H phi)` from `T(box phi)`. This creates a cross-dimensional interaction: a modal formula generates temporal obligations. This is sound but complicates the tableau:
- `T(G phi)` is itself persistent (propagates to all future times)
- New time points created by temporal existential rules trigger propagation of `T(G phi)`
- New worlds created by modal existential rules must inherit temporal obligations

The current implementation handles this correctly in the existential rules (`boxNeg`, `diamondPos`, `allFutureNeg`, etc.) by propagating cross-dimensional formulas when creating fresh labels. For example, `boxNeg` (line 395-413) propagates temporal universals (`allFuturePosAtTime`, `allPastPosAtTime`, etc.) to the fresh world.

---

## 4. Blocking and Loop-Checking Strategies

### 4.1 Taxonomy of Blocking Strategies

From the description logic and modal logic literature:

| Strategy | Description | Applicable When | Complexity |
|----------|-------------|-----------------|------------|
| **Equality blocking** | Block if node labels are identical | Any logic | Conservative |
| **Subset blocking** | Block if node labels are a subset | Transitive logics | More aggressive |
| **Ancestor blocking** | Only compare with ancestors | Trees | Simple but can be exponential |
| **Anywhere blocking** | Compare with any node | DAGs/graphs | Reduces model size |
| **Pattern-based blocking** | Custom conditions per logic | Specialized | Optimal for specific logics |
| **Core blocking** | Block based on "core" label subset | Description logics | Very aggressive |

### 4.2 Current Implementation: Subset + Anywhere Blocking

The current `isTemporallyBlocked` (SignedFormula.lean line 702) uses subset blocking with anywhere comparison:
```
isTemporallyBlocked b t ord =
  let ancestors := ancestorTimes ord t
  ancestors.any fun t_anc => b.isSubsetBlocked t t_anc
```

Note: despite the name `ancestorTimes`, the implementation (line 682-694) collects BOTH predecessors and successors, making this effectively "anywhere" blocking in the temporal dimension.

**Assessment**: This is appropriate for the TM logic. S5 with transitive accessibility benefits from subset blocking (the most aggressive general strategy). The anywhere variant is correct because time types can be compared across the entire branch, not just along ancestor chains.

### 4.3 Missing: Eventuality-Aware Blocking

The critical gap is that blocking does not check eventuality fulfillment. In standard temporal tableaux:

**Schwendimann's condition**: A loop is acceptable only if all eventualities requested along the loop are fulfilled within the loop. An "eventuality" from `T(U(event, guard))` requires that `event` eventually holds at some future time.

**Reynolds' PRUNE condition**: Three-occurrence check -- if three copies of the same label appear, and all eventualities between the second and third are also fulfilled between the first and second, the branch can be pruned. Otherwise it is discarded.

**What the current implementation does**: The `EventualityTracker` registers eventualities from `T(U(event, guard))` and `T(S(event, guard))`, and marks them as fulfilled when `T(event)` appears at a reachable time. However, `findBlockedTime` does not consult the tracker. A time point can be blocked even if it has unfulfilled eventualities.

**Impact**: This could cause unsound results in theory (a satisfiable branch could be blocked prematurely), though in practice the fuel mechanism provides a safety net. The correct fix would be:
```
isTemporallyBlocked b t ord tracker :=
  let ancestors := ancestorTimes ord t
  ancestors.any fun t_anc =>
    b.isSubsetBlocked t t_anc &&
    tracker.allFulfilledBetween t t_anc  -- NEW: check eventualities
```

### 4.4 Global Caching (Gore-Nguyen Pattern)

Gore and Nguyen (2009) developed EXPTIME tableau algorithms using **global caching**: instead of expanding each branch independently, the algorithm maintains an and-or graph of "states" (sets of formulas). States that have been previously explored are looked up in a cache rather than re-expanded.

**Applicability to TM**: Global caching could dramatically reduce the exponential branching problem identified in Round 1. When a branch splits into sub-branches, each sub-branch's state could be checked against the global cache. If the state was previously determined to be closed, the sub-branch can be immediately pruned.

**Implementation cost**: This would require a significant refactor of `expandBranchWithFuel`, replacing the current recursive structure with an iterative worklist + cache pattern.

---

## 5. Analysis of the boxPos Bug Pattern

### 5.1 The Standard Solution

In standard modal tableaux, the box rule interaction with consumable rules is handled by one of two mechanisms:

**Mechanism A: Completion-based expansion (worklist)**
Rather than scanning the branch for applicable rules, maintain a worklist of pending rule applications. When `T(box phi)` is added, enqueue propagation of `T(phi)` to all existing worlds. When a new world is created, enqueue propagation of all existing `T(box psi)` formulas. Consumable rules that process `T(phi)` do not trigger re-queuing of `T(box phi)`.

**Mechanism B: Applied-set tracking (record of derivations)**
Maintain a set of (source, target) pairs recording which formulas have been derived by which persistent rules. Before applying a persistent rule, check if its outputs are already in the applied set. This is exactly the `AppliedSet` mechanism implemented in Task 261.

### 5.2 Assessment of the Task 261 Fix

The `AppliedSet` mechanism (Tableau.lean lines 884-1082) implements Mechanism B. The key functions are:
- `findApplicableRuleWithApplied`: Filters persistent rule outputs against the applied set
- `expandOnceWithApplied`: Uses the filtered version for expansion
- Threading through `expandBranchWithFuel` via the `applied` parameter

**Correctness argument**: If `T(phi)` was derived from `T(box phi)` and recorded in the applied set, then even if `T(phi)` is consumed by a negation rule, the box rule will not re-derive it. This breaks the infinite cycle.

**Potential issue**: The applied set is per-branch. When a branching rule splits the branch, both sub-branches inherit the same applied set (via `applied'`). This is correct for sound reasoning but could be overly conservative -- a formula consumed on one branch should not prevent its derivation on the other branch. However, since the applied set only tracks persistent rule outputs (not consumable rule results), this is unlikely to cause problems in practice.

### 5.3 The Deeper Pattern: Universal-Existential Interaction

The boxPos loop is an instance of a general pattern in tableau calculi:

1. **Universal rule** adds `T(phi)` (persistent -- source stays on branch)
2. **Consumable rule** processes `T(phi)` and removes it
3. Universal rule no longer sees `T(phi)`, re-adds it
4. Repeat forever

This is equivalent to the "yo-yo" problem in description logic. Production reasoners solve it via:
- **Worklist architecture**: Rules fire once; results are cached
- **Hypertableau**: Universal rules are combined with existential rules in "hyper-expansion steps" that apply multiple rules simultaneously, avoiding the interleaving problem
- **Lazy expansion**: Universal rule outputs are not materialized until needed (when checking for contradictions or saturation)

The AppliedSet mechanism is a lightweight version of the worklist approach. For a more robust long-term solution, the hypertableau pattern would be superior.

---

## 6. Exponential Branching Analysis

### 6.1 The Problem

In `expandBranchWithFuel` (Saturation.lean line 181), each sub-branch in a split receives the full remaining fuel:
```lean
match expandBranchWithFuel newBranch fuel newOrd fc tracker applied' with
```

This creates `O(2^fuel)` worst-case work when branching rules fire repeatedly.

### 6.2 Standard Solutions

**Fuel division**: Divide fuel among branches. If fuel = f and there are k branches, each gets f/k. This gives `O(f)` total work but may miss deep proofs on individual branches.

**Adaptive fuel**: Start with low fuel and increase exponentially. This is iterative deepening applied to fuel. Total work is dominated by the last iteration: `O(b * fuel_max)` where b is the average branching factor.

**Global fuel (recommended)**: Maintain a single global fuel counter shared across all branches. Each expansion step decrements the counter regardless of which branch it occurs on. This guarantees `O(fuel)` total work.

**Dependency-directed backtracking (backjumping)**: When a branch closes, analyze the closure reason to determine which branching decisions were relevant. Skip branches that cannot contribute to closure. Wu and Gore (2019) verified backjumping for modal logic K in Lean.

### 6.3 Assessment

The Round 1 report recommended fuel division (`fuel / branches.length`). The global fuel approach would be simpler and equally effective. A shared mutable fuel counter passed through all recursive calls ensures the total work is exactly bounded by the initial fuel value.

---

## 7. Recommended Improvements (Prioritized)

### Priority 1: Global Fuel Counter (fixes exponential branching)

Replace the per-branch fuel parameter with a global (mutable reference) counter. Each expansion step decrements the counter. When it reaches zero, all branches report "out of fuel." This is the simplest fix with the highest impact.

**Estimated complexity**: Low. Change `fuel : Nat` to `fuelRef : IO.Ref Nat` (or use a State monad).

### Priority 2: Eventuality-Aware Blocking (fixes unsound blocking)

Modify `isTemporallyBlocked` to check that all pending eventualities at the blocked time are either fulfilled or duplicated at the blocking ancestor. This prevents premature blocking of branches that still have obligations to fulfill.

**Estimated complexity**: Medium. Requires threading the `EventualityTracker` into the blocking check and defining a `allFulfilledOrDuplicated` predicate.

### Priority 3: Worklist Architecture (replaces scan-based expansion)

Replace the current `findUnexpanded` scan with a priority queue of pending rule applications. When a formula is added to the branch, enqueue all applicable rules. When a formula is consumed, do not re-enqueue persistent rules.

**Estimated complexity**: High. Requires restructuring `expandBranchWithFuel` from a recursive scan into an iterative worklist loop.

### Priority 4: Global Caching (reduces redundant work)

Maintain a cache mapping branch states (as sets of signed formulas) to their outcomes (closed/open). Before expanding a branch, check the cache. This is the Gore-Nguyen pattern and can provide exponential speedups for formulas with repeated sub-structures.

**Estimated complexity**: High. Requires defining a canonical form for branch states and implementing the and-or graph pattern.

### Priority 5: Reynolds PRUNE Rule (improves Until/Since termination)

Implement the three-occurrence PRUNE rule from Reynolds (2016) for Until/Since eventualities. This provides a structural termination criterion that does not depend on fuel.

**Estimated complexity**: Medium. Requires tracking the sequence of labels along each branch path and comparing triplets.

---

## 8. Summary of Literature Sources

| Author(s) | Year | Contribution | Relevance |
|-----------|------|-------------|-----------|
| Fitting | 1983 | Prefixed tableau for modal logics | Foundation for S5 box rule handling |
| Wolper | 1985 | Tableau method for temporal logic | Two-phase LTL approach |
| Vardi & Wolper | 1986 | Automata-theoretic LTL approach | Alternative to tableau for LTL |
| Kracht & Wolter | 1991-97 | Fusion transfer theorems | Decidability transfer for combined logics |
| Schwendimann | 1998 | One-pass tableau for PLTL | Eventuality checking in loops |
| Gore | 1999 | Handbook chapter on modal/temporal tableaux | Comprehensive survey |
| Massacci | 2000 | Single Step Tableau for S5 | NP-optimal decision procedure |
| Horrocks & Sattler | 2005 | FaCT++ reasoner | Production DL blocking |
| Gore & Nguyen | 2009 | Global caching for ALC | EXPTIME optimal with caching |
| Motik, Shearer, Horrocks | 2009 | HermiT hypertableau | Yo-yo problem, core blocking |
| Reynolds | 2016 | New rule for LTL tableaux | PRUNE rule, one-pass tree-shaped |
| Wu & Gore | 2019 | Verified modal tableaux in Lean | Verified backjumping |

---

## 9. Codebase Analysis Details

### 9.1 Files Examined

| File | Lines | Key Content |
|------|-------|-------------|
| `Decidability/Tableau.lean` | 1099 | All 25+ tableau rules, `applyRule`, `expandOnce`, `AppliedSet` |
| `Decidability/Saturation.lean` | 1067 | `expandBranchWithFuel`, `buildTableau`, blocking tests |
| `Decidability/Closure.lean` | 398 | Branch closure detection, monotonicity proofs |
| `Decidability/SignedFormula.lean` | 881 | Labels, signed formulas, subset blocking, time ordering |

### 9.2 Architecture Assessment

The tableau architecture is well-designed for a research formalization:
- Clean separation between rule definitions (Tableau.lean) and expansion strategy (Saturation.lean)
- Proper handling of labels (world + time) for the bimodal setting
- Cross-modal-temporal propagation in existential rules
- Formal proofs of key properties (closure monotonicity, expansion soundness)

The main limitations are performance-oriented:
- List-based branch representation (O(n) lookups instead of O(1) with HashSet)
- Scan-based rule selection (O(rules * branch) per step instead of O(1) with worklist)
- Per-branch fuel (exponential worst case instead of linear with global fuel)

### 9.3 Frame Class Handling

The implementation correctly handles three frame classes:
- **Base**: All frames (no additional axioms)
- **Dense**: Adds density rule and indicator closure
- **Discrete**: Adds Prior's UZ/SZ rules and Z1 backward induction

Frame class gating (via `isApplicable` and `allRulesForFC`) ensures Dense axioms only close under Dense frames and Discrete axioms only close under Discrete frames. The tests in Saturation.lean verify this gating.
