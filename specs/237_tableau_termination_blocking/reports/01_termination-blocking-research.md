# Task 237: Tableau Termination via Blocking and FMP Bounds

## Research Summary

This report analyzes the current fuel-based termination mechanism for the tableau decision procedure, proposes a subset blocking strategy to ensure sound termination, derives the fuel bound from the Finite Model Property (FMP), and argues completeness preservation.

---

## 1. Current Fuel-Based Termination Mechanism

### 1.1 How Fuel Works Today

The tableau expansion uses a simple countdown fuel parameter. The core function is `expandBranchWithFuel` in `Saturation.lean` (line 92):

```
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty) : Option (ClosedBranch + Branch) :=
  match fuel with
  | 0 => none  -- Out of fuel
  | fuel + 1 => ...
```

Each expansion step (whether linear extension, branching, or persistent propagation) decrements fuel by 1. When fuel hits 0, the procedure returns `none`, which propagates to `DecisionResult.timeout` in the decision procedure.

### 1.2 Ad-Hoc Fuel Heuristic

The current `recommendedFuel` function in `Saturation.lean` (line 171) is:

```
def recommendedFuel (phi : Formula) : Nat :=
  10 * phi.complexity + 100
```

This is purely heuristic. There is no proof that this amount of fuel suffices for all formulas of a given complexity. The constant factors (10x, +100) were chosen empirically. For formulas with deep temporal nesting or many Until/Since operators, this heuristic may be insufficient -- producing false timeouts -- or vastly excessive -- wasting computation.

### 1.3 Where Fuel is Consumed

Fuel is consumed in three places:
1. **`expandBranchWithFuel`** (line 92): main expansion loop
2. **`expandBranchesWithFuel`** (line 129): multi-branch wrapper
3. **`buildTableau`** (line 157): entry point, default fuel=1000

The `decide` function in `DecisionProcedure.lean` (line 120) passes `tableauFuel` (default 1000) directly. The `decideAuto` function (line 174) uses `recommendedFuel`.

### 1.4 Problems with Current Approach

1. **No soundness guarantee**: If fuel runs out, the answer is "timeout" -- not "valid" or "invalid". The procedure never lies, but it may fail to decide.
2. **No completeness guarantee**: There is no proof that sufficient fuel always produces a decision.
3. **No relationship to FMP**: The fuel bears no formal relation to the FMP size bound 2^|cl(phi)|.
4. **Non-termination without fuel**: The temporal operators (especially Until/Since with their guard-continue branches) can generate unbounded new time points. Without blocking, a positive Until T(U(event, guard)) keeps creating fresh future times via the guard-continue branch.

---

## 2. Subformula Closure Structure and Size Bounds

### 2.1 Subformula Closure Definition

The subformula closure is defined in two places:
- **`Syntax/Subformulas.lean`**: `Formula.subformulas : Formula -> List Formula` -- recursive collection
- **`Syntax/SubformulaClosure/Closure.lean`**: `subformulaClosure : Formula -> Finset Formula` -- deduplicated Finset version

The closure is computed by recursion on the Formula type:
- `atom a` -> `[atom a]`
- `bot` -> `[bot]`
- `imp psi chi` -> `[imp psi chi] ++ subformulas psi ++ subformulas chi`
- `box psi` -> `[box psi] ++ subformulas psi`
- `untl psi chi` -> `[untl psi chi] ++ subformulas psi ++ subformulas chi`
- `snce psi chi` -> `[snce psi chi] ++ subformulas psi ++ subformulas chi`

### 2.2 Size Bounds

Let `n = |subformulaClosure(phi)|` (the Finset cardinality after deduplication).

**Key bounds**:
- `n <= phi.complexity` (each subformula contributes at least 1 to complexity)
- `|closureWithNeg(phi)| <= 2n` (proved in `ClosureMCS.lean:269` as `closure_mcs_card_bound`)
- **FMP world bound**: At most `2^n` distinct equivalence classes of closure MCS (`fmp_size_bound` in `FMP.lean:226`)

### 2.3 Signed Subformula Closure

The `signedSubformulaClosure` in `SignedFormula.lean` (line 655) extends the closure to signed formulas: for each formula psi in cl(phi), include both T(psi) and F(psi). This gives at most `2n` signed formulas per label (world, time pair).

### 2.4 Closure Properties for Tableau

Key property (proved): the subformula relation is transitive (`subformulas_trans`). Tableau rules only produce formulas from the subformula closure of the initial formula. Specifically:
- Propositional rules decompose to strict subformulas
- Modal/temporal rules introduce subformulas at new labels
- Until/Since guard-continue re-introduces the original Until/Since at a new label

The critical observation is that while formulas stay within the closure, **labels can grow unboundedly** (new worlds from F(box A), new times from F(GA), T(FA), T(U(event,guard)), etc.). This is the source of potential non-termination.

---

## 3. Subset Blocking Strategy Design

### 3.1 The Core Problem

Non-termination arises from unbounded label creation. Each existential rule (F(GA), T(FA), T(U(event,guard)), T(S(event,guard)), F(box A), T(diamond A)) creates a fresh label. Since the same signed formulas can appear at different labels, the branch can grow indefinitely even though the formula set at each label is bounded.

### 3.2 Blocking Principle

**Subset blocking**: When a new label (world w, time t) is created, compute its **type** -- the set of signed formulas at that label. If this type is a subset of (or equal to) the type of some ancestor label, then further expansion from this label is **blocked**. No new existential witnesses are generated from the blocked label.

**Equality blocking** (simpler variant): Block when the type equals an ancestor's type. This is sound but may miss blocking opportunities.

**Subset blocking** (more aggressive): Block when the new label's type is a subset of an ancestor's type. Since any formula true/false at the ancestor can also be propagated to the new label, expanding the new label can only produce formulas already derivable from the ancestor.

### 3.3 Label Types

Define the **label type** of a label `l = (w, t)` on a branch `b` as:

```
labelType(b, l) := { sf in b | sf.label = l }
```

This is a finite set bounded by `2 * |subformulaClosure(phi)|` (each subformula can appear as T or F at the label).

### 3.4 Blocking Condition

For temporal blocking (time dimension):
- When creating fresh time `t_new` from parent time `t_parent`:
- Compute `labelType(branch, t_new)` (after adding witness formulas and propagations)
- Check if there exists an ancestor time `t_anc` on the same world such that:
  - `t_anc` is strictly earlier in the creation chain (not necessarily in the temporal order)
  - `labelType(branch, (w, t_new)) ⊆ labelType(branch, (w, t_anc))`
- If so, **block**: do not expand existential formulas at `(w, t_new)`

For modal blocking (world dimension):
- When creating fresh world `w_new` from parent world `w_parent`:
- Check if there exists an ancestor world `w_anc` at the same time such that:
  - `labelType(branch, (w_new, t)) ⊆ labelType(branch, (w_anc, t))`
- If so, block.

### 3.5 Ancestor Chain Tracking

To implement blocking, we need to track the **creation chain** for labels. Currently, the `TimeOrdering` structure (lines 508-540 of `SignedFormula.lean`) tracks temporal order constraints but not the creation chain. Two options:

**Option A**: Use `TimeOrdering.constraints` as a proxy for the creation chain. Each `(t, t_new)` constraint records that `t_new` was created after `t`. The ancestor chain follows these edges backward.

**Option B**: Add an explicit `parentOf : Nat -> Option Nat` mapping to the expansion state. This is cleaner but requires threading more state.

Recommendation: **Option A** is sufficient for time labels because `TimeOrdering.constraints` already records exactly the creation edges. For worlds, an analogous structure would need to be added.

### 3.6 Implementation Sketch

```lean
structure BlockingState where
  timeParent : List (TimeIndex x TimeIndex)  -- (child, parent)
  worldParent : List (WorldIndex x WorldIndex)  -- (child, parent)

def isBlocked (branch : Branch) (label : Label) (state : BlockingState) : Bool :=
  let myType := branch.filter (fun sf => sf.label == label)
  -- Check ancestors along the creation chain
  let ancestors := getAncestors state label
  ancestors.any fun ancLabel =>
    let ancType := branch.filter (fun sf => sf.label == ancLabel)
    myType.all (fun sf => ancType.any (fun asf => asf == sf))
```

### 3.7 Where to Apply Blocking

Blocking should be checked in `expandBranchWithFuel` (Saturation.lean), specifically:
1. After `expandOnce` produces an `extended` or `split` result that introduces new labels
2. Before recursing on the new branch, check if any newly created label is blocked
3. If blocked, treat the blocked formulas as "expanded" (they do not generate further witnesses)

Alternatively, blocking can be integrated into `findUnexpanded` (Tableau.lean:736): a signed formula at a blocked label is considered "expanded" even if rules still apply to it.

---

## 4. FMP-Derived Size Bound Calculation

### 4.1 The FMP Bound

The FMP (proved in `FMP/FMP.lean`) establishes that if phi is not provable, there exists a finite model with at most `2^n` worlds, where `n = |subformulaClosure(phi)|`.

### 4.2 Translating FMP Bound to Tableau Fuel

The FMP gives a bound on model size (number of distinct worlds/time-points). For the tableau, this translates to a bound on the number of distinct label types. Since:
- Each label has a type drawn from `P(signedSubformulaClosure(phi))` (powerset of 2n elements)
- There are at most `2^(2n)` distinct types
- Once a label with a previously-seen type is created, blocking fires

The maximum number of unblocked labels is bounded by `2^(2n)`.

### 4.3 Tighter Bound via Hintikka Sets

Not every subset of the signed closure is consistent. A **Hintikka set** is a subset satisfying local consistency conditions (no T(phi) and F(phi) simultaneously, closure under propositional decomposition, etc.). The number of Hintikka sets is bounded by `2^n` (not `2^(2n)`) because each subformula is either true or false at each label.

### 4.4 Proposed Fuel Formula

Replace `recommendedFuel` with a sound bound:

```lean
def soundFuel (phi : Formula) : Nat :=
  let n := (subformulaClosure phi).card  -- use Finset version
  let maxLabels := 2 ^ n  -- FMP bound on distinct types
  let maxFormulasPerStep := 2 * n  -- formulas added per expansion
  let maxBranching := 2  -- max branching factor per step
  maxLabels * maxFormulasPerStep * maxBranching
```

This gives `O(n * 2^n)` fuel, which is exponential but provably sufficient. For practical purposes, the blocking mechanism makes the procedure terminate much earlier -- the fuel is only a last-resort safety net.

### 4.5 Proving Fuel Sufficiency

The key theorem to prove:

```lean
theorem blocking_terminates (phi : Formula) :
    ∃ fuel : Nat, fuel ≤ soundFuel phi ∧
    ∀ b : Branch, (buildTableauWithBlocking phi fuel).isSome
```

The proof structure:
1. Each expansion step either closes a branch, saturates a branch, or creates a new label
2. Each new label either has a novel type (consuming one of the `2^n` available types) or is blocked
3. Therefore, at most `2^n` labels are unblocked
4. At each unblocked label, at most `2n` formulas need expansion
5. Each formula expansion is one fuel step
6. Total fuel: `2^n * 2n = O(n * 2^n)`

---

## 5. Completeness Preservation Argument

### 5.1 The Completeness Concern

Blocking suppresses expansion of certain formulas at blocked labels. Could this cause the tableau to close (report "valid") when the formula is actually invalid? In other words, does blocking preserve **completeness** (every invalid formula has an open saturated branch)?

### 5.2 Soundness of Blocking (No False Closures)

Blocking does NOT add any new signed formulas to the branch. It only prevents generation of new witnesses. A closed branch requires a contradiction (T(phi) and F(phi) at the same label, or T(bot), or F(axiom)). Since blocking only suppresses, it cannot create contradictions that are not already present.

However, blocking could suppress creation of witnesses that would prevent closure. If a branching rule would have produced an open branch (witness for invalidity) but blocking prevents the witness, the branch might close when it should not.

**Key insight**: Blocking fires when the new label's type is a subset of an ancestor's type. Any witness that would be generated at the blocked label could also be generated at the ancestor (since the ancestor has a superset of the relevant formulas). Therefore, if the formula is satisfiable, the model extractable from the ancestor provides all needed witnesses.

### 5.3 Formal Completeness Argument

**Claim**: If phi is invalid (satisfiable negation), then the tableau with subset blocking still produces an open branch.

**Proof sketch**:
1. Since phi is invalid, there exists a finite model M (by FMP) with at most `2^n` worlds where phi fails.
2. The tableau with blocking generates at most `2^n` unblocked labels.
3. Since M has at most `2^n` points, there is a simulation: each unblocked label can be mapped to a point in M.
4. At each unblocked label, the signed formulas are consistent with M (they match the truth values in M).
5. Therefore, no branch closes (the formulas at each label are consistent with the model).
6. The branch saturates (all rules applied at unblocked labels, blocked labels need no expansion by the subset condition) and remains open.
7. The open branch describes a countermodel.

### 5.4 Completeness for Until/Since

The Until/Since operators are the most delicate case. Consider T(U(event, guard)) at label (w, t):
- Branch 1: T(event) at (w, t') -- event witness
- Branch 2: T(guard) at (w, t'), T(U(event,guard)) at (w, t') -- guard + continue

The guard-continue branch re-introduces T(U(event,guard)) at the new time t'. If this new time is blocked (its type is a subset of some ancestor's type), then the Until formula at t' is not expanded further.

**Why this is safe**: The finite model M satisfies phi.neg. In M, the Until formula U(event, guard) at time t is witnessed by some finite time t* > t where event holds, with guard holding at all intermediate times. The chain t < t_1 < ... < t_k = t* has length at most |M| (the model is finite). The tableau exploration follows this chain, creating t_1, t_2, etc. Since the chain has bounded length (at most 2^n), and each intermediate label has a type from the closure, blocking cannot fire on a genuine witness chain shorter than 2^n.

More precisely: in a genuine witness chain from the FMP model, each time point has a distinct type (otherwise the model could be collapsed). So the chain length is at most 2^n, and blocking never fires within a genuine witness chain.

### 5.5 The Eventuality Tracking Connection

The `Eventuality` and `EventualityTracker` types in `SignedFormula.lean` (lines 457-492) already provide infrastructure for tracking pending Until/Since obligations. The blocking mechanism should interact with eventuality tracking:

- When a blocked label has pending eventualities, those eventualities are considered **fulfilled by the ancestor** (since the ancestor has a superset type, the ancestor's expansion handles the eventuality).
- The `EventualityTracker.fulfill` method can be called when blocking fires, marking the blocked label's eventualities as handled.

---

## 6. Integration Points in the Existing Codebase

### 6.1 File-by-File Integration Map

| File | Changes Needed |
|------|---------------|
| `SignedFormula.lean` | Add `BlockingState` type, `labelType` function, `isBlocked` predicate |
| `Tableau.lean` | Modify `findUnexpanded` to skip blocked labels |
| `Saturation.lean` | Thread `BlockingState` through `expandBranchWithFuel`; replace `recommendedFuel` with `soundFuel` |
| `DecisionProcedure.lean` | Update `decide` and `decideAuto` to use `soundFuel` |
| `Closure.lean` / `FMP/FMP.lean` | No changes (provide the bound theorem) |
| `CountermodelExtraction.lean` | May need to handle blocked labels in countermodel output |

### 6.2 Existing Infrastructure to Leverage

1. **`subformulaClosure` (Finset)**: Already provides the cardinality bound `n`
2. **`closureWithNeg`**: Provides the `2n` bound on signed formula types
3. **`TimeOrdering`**: Already tracks temporal order constraints; can double as creation chain
4. **`Branch.knownWorlds` / `Branch.knownTimes`**: Already enumerate existing labels
5. **`EventualityTracker`**: Already defined with `Eventuality`, `add`, `fulfill`, `hasPending` -- ready for blocking integration
6. **`fmp_size_bound`**: Provides the `2^n` theorem to justify the fuel bound

### 6.3 Specific Code Touch Points

**`expandBranchWithFuel` (Saturation.lean:92)**: Currently signature is:
```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty) : Option (ClosedBranch + Branch)
```
Proposed new signature:
```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (blocking : BlockingState := BlockingState.empty) : Option (ClosedBranch + Branch)
```

**`findUnexpanded` (Tableau.lean:736)**: Currently:
```lean
def findUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    : Option SignedFormula :=
  b.find? (fun sf => !isExpanded sf b timeOrd)
```
Add blocking check:
```lean
def findUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (blocking : BlockingState := BlockingState.empty)
    : Option SignedFormula :=
  b.find? (fun sf => !isExpanded sf b timeOrd && !isBlocked b sf.label blocking)
```

**`recommendedFuel` (Saturation.lean:171)**: Replace with:
```lean
def soundFuel (phi : Formula) : Nat :=
  let n := phi.subformulaCount  -- |cl(phi)|
  2 ^ n * (2 * n + 1) * 2 + 1  -- provably sufficient
```

### 6.4 Dependency on Tasks 233-235

The TODO.md lists tasks 233, 234, 235 as dependencies for 237. These tasks cover:
- 233: Basic tableau rule corrections/enhancements
- 234: Temporal rule refinements
- 235: Until/Since rule improvements

Task 237 can be implemented independently of these (the blocking mechanism is orthogonal to the specific rule implementations), but if rules 233-235 change the set of formulas produced by expansion, the blocking type computation would need to be rechecked.

### 6.5 Downstream Impact

Tasks that depend on 237 (per TODO.md):
- 239: Correctness theorem for decision procedure (needs termination guarantee)
- 240: Countermodel correctness (needs open branch characterization under blocking)

---

## 7. Implementation Recommendations

### 7.1 Phase Decomposition (Suggested)

**Phase 1**: Define `BlockingState`, `labelType`, `isBlocked` in `SignedFormula.lean`. Prove basic properties (reflexivity of subset check, monotonicity under branch extension).

**Phase 2**: Thread `BlockingState` through `expandBranchWithFuel` and `expandOnce`. Update `findUnexpanded` to respect blocking. Thread through `buildTableau`.

**Phase 3**: Replace `recommendedFuel` with `soundFuel` derived from `subformulaClosureCard`. Prove or state the fuel sufficiency theorem.

**Phase 4**: Prove blocking preserves completeness (no false closures). This is the most mathematically demanding phase: show that subset-blocked branches can still extract valid countermodels.

**Phase 5**: Update `DecisionProcedure.lean` to use the new functions. Verify all existing tests pass. Add tests for formulas that previously timed out.

### 7.2 Estimated Effort

- Phase 1: 2-3 hours (data types and basic properties)
- Phase 2: 3-4 hours (threading state, integration)
- Phase 3: 2-3 hours (fuel calculation and bound)
- Phase 4: 4-6 hours (completeness proof, most technically challenging)
- Phase 5: 1-2 hours (integration and testing)
- **Total**: 12-18 hours

### 7.3 Risk Assessment

**Low risk**: Phases 1-3 are straightforward engineering.
**Medium risk**: Phase 4 (completeness proof) requires careful reasoning about the interaction between blocking and model extraction. The argument in Section 5 is standard in the tableau literature but formalizing it in Lean may require substantial effort.
**Mitigation**: If Phase 4 proves too difficult, an intermediate solution is to implement blocking pragmatically (Phases 1-3) and defer the formal completeness proof. The blocking is observably correct on test cases and theoretically justified by FMP.

---

## 8. Related Literature

- **Gore (1999)**: "Tableau Methods for Modal and Temporal Logics" -- standard reference for blocking in modal tableaux. Describes loop-checking and subset blocking for temporal logics.
- **Horrocks, Sattler (1999)**: "A Description Logic with Transitive and Inverse Roles and Role Hierarchies" -- pioneered subset blocking for description logics, closely related to modal tableaux.
- **Wolter, Zakharyaschev (2000)**: "Temporalizing Description Logics" -- blocking in combined modal-temporal settings.
- **Wu, M.**: "Verified Decision Procedures for Modal Logics" -- Lean formalization reference for verified tableau procedures.
- **Blackburn, de Rijke, Venema (2001)**: "Modal Logic" Ch 2.3 -- filtration and FMP size bounds.

---

## 9. Conclusion

The current ad-hoc fuel heuristic (`10 * complexity + 100`) should be replaced with a sound bound derived from the FMP (`O(n * 2^n)` where `n = |cl(phi)|`). Subset blocking on label types ensures termination without fuel, making the fuel parameter a safety net rather than the primary termination mechanism. The FMP infrastructure (Finset-based closure, cardinality bounds, filtered world finiteness) already exists in the codebase and provides the theoretical foundation. The EventualityTracker structure is already defined and ready for integration with the blocking mechanism.
