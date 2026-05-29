# Teammate C (Critic) Findings: ModelChecker as Corrective Training Signal

**Task**: 201 — AlphaZero-style proof search harness
**Focus**: Risks and gaps in using the ModelChecker's bimodal theory as a corrective training signal
**Date**: 2026-05-29

---

## Key Findings

### 1. CRITICAL: Language Mismatch — ModelChecker Lacks Until/Since

The Lean ProofChecker's formula type has **6 constructors** (atom, bot, imp, box, untl, snce) where `untl` (Until) and `snce` (Since) are **primitive operators** central to the logic. The entire BX axiom system (42 axiom constructors) is built around Until/Since — 22 of the 42 axioms are BX temporal axioms defined in terms of Until/Since.

The ModelChecker's `operators.py` defines only **15 operators** across 3 categories:
- **Extensional**: neg, and, or, conditional, biconditional (5)
- **Extremal**: bot, top (2)
- **Modal**: Box, Diamond (2)
- **Temporal**: Future (G), Past (H), DefFuture (F), DefPast (P) (4)
- **Until/Since: NOT PRESENT**

In the Lean formalization, G (all_future), H (all_past), F (some_future), P (some_past) are **derived** abbreviations:
- `G(φ) = ¬F(¬φ)` where `F(φ) = U(φ, ⊤)` (all_future derived from Until)
- `H(φ) = ¬P(¬φ)` where `P(φ) = S(φ, ⊤)` (all_past derived from Since)

The ModelChecker treats Future/Past as primitive operators with direct truth conditions, rather than deriving them from Until/Since. This means:

**Impact**: Any formula involving Until or Since (which includes the majority of BX axioms and non-trivial temporal reasoning) **cannot be checked by the ModelChecker at all**. The corrective training signal covers only a fragment of the logic.

**Confidence**: HIGH — verified by code inspection of `operators.py` (no Until/Since class exists) and `Formula.lean:70-84` (6-constructor inductive type).

---

### 2. CRITICAL: Semantic Architecture Divergence — Discrete Integer Time vs. General Ordered Groups

**Lean ProofChecker** (`TaskFrame.lean:93`):
```
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```
The temporal domain `D` is parametric — it can be `Int` (discrete), `Rat` (dense), or `Real` (continuous). The ProofChecker supports **3 frame classes** via typeclasses:
- `SerialFrame D` — base (all linear temporal orders)
- `DenseTemporalFrame D` — densely ordered (e.g., rationals)
- `DiscreteTemporalFrame D` — discrete with successors/predecessors (e.g., integers)

Different axioms are valid in different frame classes. The 42 BX axiom constructors include:
- 37 base axioms (valid on all linear temporal orders)
- 3 Prior/Z1 axioms (valid only on discrete orders)
- 2 density axioms (valid only on dense orders)

**ModelChecker** (`semantic.py:62-77`):
```python
self.M = settings.get('M', 2)  # Number of time points
# ...
self.TimeSort = z3.IntSort()  # Time points as integers
```
Time is **always discrete integers** in the range `[-M+1, M-1]`. There is **no support for dense or continuous temporal orders**. There is no frame class concept.

**Impact**: 
1. The ModelChecker can only generate countermodels for the discrete fragment. It cannot produce countermodels that require dense/continuous models.
2. A formula valid in discrete frames but invalid in dense frames would be **incorrectly labeled as valid** by the ModelChecker (no countermodel found in discrete search, but one exists in dense models).
3. The 2 density axioms cannot be tested.

**Confidence**: HIGH — verified from `semantic.py:131` (IntSort) and `FrameClass.lean:82-196` (3-class hierarchy).

---

### 3. CRITICAL: Temporal Quantification Scope Mismatch

**Lean ProofChecker** (`Truth.lean:252-266`):
```lean
@[simp] theorem future_iff ... :
    truth_at M Omega τ t φ.all_future ↔ ∀ (s : D), t < s → truth_at M Omega τ s φ
```
G (all_future) quantifies over **ALL times `s` in the entire domain `D` with `t < s`** — not restricted to the history's domain. Atoms outside the domain are **false** (line 186-196: `atom_false_of_not_domain`). The quantification uses **strict inequality** (`t < s`, excluding present).

**ModelChecker** (`operators.py:529-547`):
```python
def true_at(self, argument, eval_point):
    future_time = z3.Int('future_true_time')
    return semantics.ForAllTime(
        eval_world, future_time,
        z3.Implies(eval_time < future_time,
                   semantics.true_at(argument, {"world": eval_world, "time": future_time})))
```
`ForAllTime` restricts to `is_valid_time_for_world(eval_world, time)` — only times **within the world's interval** (`semantic.py:209-226`). This means the ModelChecker's Future operator quantifies over a **bounded, finite interval**, not the entire temporal domain.

**The semantics are NOT equivalent**: In the Lean version, atoms at times outside the domain are false, so `G(p)` for atom `p` requires `p` to hold at all future times, with `p` being false outside the domain. In the ModelChecker, `G(p)` only requires `p` at times within the world's interval. For non-atomic formulas (e.g., `G(¬⊥)`), the difference is:
- Lean: `¬⊥` is true at all times (including outside domain), so `G(¬⊥)` is true
- ModelChecker: `¬⊥` is true at all times within the interval, so `G(¬⊥)` is true
- For `G(p)` with atom `p`: Lean requires truth at ALL future times (atoms false outside domain). ModelChecker only checks the finite interval.

This divergence means the ModelChecker could generate **spurious countermodels** for formulas involving atoms under temporal operators, because the model boundary effects differ.

**Confidence**: HIGH — verified from Truth.lean `future_iff` theorem and operators.py `ForAllTime`.

---

### 4. HIGH: Box Quantification Architecture Difference

**Lean ProofChecker** (`Truth.lean:122-128`):
```lean
| Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```
Box quantifies over an **admissible set `Omega`** of world histories. The set must be `ShiftClosed` (line 295-296) — shifting any history in Omega by any amount keeps it in Omega.

**ModelChecker** (`operators.py:384-406`):
```python
def true_at(self, argument, eval_point):
    other_world = z3.Int('nec_true_world')
    return z3.ForAll(other_world,
        z3.Implies(z3.And(
            semantics.is_world(other_world),
            semantics.is_valid_time_for_world(other_world, eval_time)),
            semantics.true_at(argument, {"world": other_world, "time": eval_time})))
```
Box quantifies over **all valid world IDs** at the evaluation time, with an additional `is_valid_time_for_world` guard — it only considers worlds where `eval_time` is in the world's interval.

**Divergence**: The Lean version quantifies over ALL histories in Omega (which is shift-closed, hence all of them "see" every time). The ModelChecker restricts to worlds where the evaluation time falls within their interval. This means:
- A world history in the Lean model always participates in Box evaluation at any time
- In the ModelChecker, a world history only participates at times within its interval

For Box at times near interval boundaries, the ModelChecker could exclude relevant worlds, producing spurious countermodels.

**Confidence**: MEDIUM — the practical impact depends on how Z3 constructs models and whether the Skolem abundance constraint compensates for this.

---

### 5. HIGH: Task Relation Representation Difference

**Lean ProofChecker** (`TaskFrame.lean:93-122`):
```lean
task_rel : WorldState → D → WorldState → Prop
nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```
The task relation is a **ternary** relation: `task_rel w d u` means "world state `u` is reachable from `w` by task of duration `d`". It's parameterized by duration. It satisfies three axioms: nullity identity, forward compositionality, and converse.

**ModelChecker** (`semantic.py:152-158`):
```python
self.task = z3.Function("Task", self.WorldStateSort, self.WorldStateSort, z3.BoolSort())
```
The task relation is **binary**: `task(w, u)` means "there is a valid transition from state `w` to state `u`" — with **no duration parameter**. This is a single-step transition relation.

The ModelChecker's `lawful` constraint (`semantic.py:351-373`) only requires that consecutive states in a world history satisfy the binary task relation, effectively treating all transitions as unit-duration.

**Impact**: The Lean task relation captures richer temporal structure (duration-dependent transitions, compositionality, converse). The ModelChecker's binary relation is a significant simplification. While this may not affect the operators that were implemented (Box, G, H), it represents a fundamental architectural divergence in the underlying frame structure.

**Confidence**: HIGH — verified by comparing TaskFrame.lean `task_rel` signature with semantic.py `self.task` signature.

---

### 6. MEDIUM: Bounded Model Space and Completeness Guarantees

The ModelChecker uses finite models with at most `max_world_id = M * (2^(M*N))` world histories (`semantic.py:175`). For N=2, M=2 this is 2 * 16 = 32 world histories. For N=3, M=3 this is 3 * 134,217,728 — but Z3 won't actually explore all of them.

**Key question**: Does TM logic have the **finite model property**?

The Lean codebase has a `FiniteTaskFrame` structure (`TaskFrame.lean:284-287`) and the decidability proof (`Metalogic/Decidability/`) constructs finite countermodels via tableau methods. This suggests TM does have the finite model property for the base fragment.

However:
- For **dense** frame class formulas, no finite countermodel may exist (dense orders are inherently infinite)
- The ModelChecker's fixed integer time domain cannot represent dense models at all
- For **discrete** frame class formulas, finite countermodels exist but may require larger N/M than the configured bounds

**Impact**: "No countermodel found" from the ModelChecker means "no countermodel found within the N×M search bounds," not "the formula is valid." This is a false-negative risk for the corrective signal — invalid formulas could be incorrectly labeled as valid.

**Confidence**: MEDIUM — the finite model property likely holds for the discrete fragment, but the bounds may be insufficient for complex formulas.

---

### 7. MEDIUM: Abundance Constraint Approximation

The Lean formalization requires a `ShiftClosed` property — every time-shifted copy of a history remains in the model. This is an exact mathematical requirement: for all histories σ and shifts Δ, `time_shift σ Δ ∈ Omega`.

The ModelChecker approximates this with the `skolem_abundance_constraint` (`semantic.py:745-792`), which only requires forward and backward shifts by **exactly 1 unit**. It does not require arbitrary shifts. The abundance constraint creates `forward_of` and `backward_of` Skolem functions but only for single-step shifts.

For models where multi-step shifts are needed (e.g., a formula requiring `G□φ` to hold, which needs histories shifted by arbitrary amounts), the ModelChecker's abundance constraint may be insufficient.

**Confidence**: MEDIUM — single-step shifts may be adequate for small models where iterated single-step shifts cover the needed range, but this is not guaranteed.

---

### 8. LOW-MEDIUM: No Shared Formula Representation

The formula enumerator (task 203) produces Lean-format formulas with 6 constructors (atom, bot, imp, box, untl, snce). The ModelChecker parses formulas as Python strings with backslash-prefixed operators (e.g., `\\Box`, `\\Future`).

A translation layer would need to:
1. Map Lean formula constructors to ModelChecker string syntax
2. Handle Until/Since, which **don't exist** in the ModelChecker
3. Convert Lean atom names to ModelChecker sentence letter format

**Impact**: Until the ModelChecker supports Until/Since, formula translation is impossible for the full language. Even for the Box/G/H fragment, a bidirectional translation layer must be built and validated.

**Confidence**: HIGH that translation is needed; LOW that it's a blocking issue for the fragment that both support.

---

## Recommended Mitigations

### Priority 1: Update the ModelChecker (REQUIRED before integration)

The semantic divergences documented above make the current ModelChecker unsuitable as a corrective training signal without updates:

1. **Add Until/Since operators** to `operators.py` — these are the primitive temporal connectives in TM
2. **Align temporal quantification** — ensure G/H quantify over the same scope as the Lean ProofChecker
3. **Add frame class support** — at minimum, distinguish Base/Dense/Discrete
4. **Update task relation to ternary** — add duration parameter to match Lean's `task_rel`

### Priority 2: Build a Conformance Test Suite

Before using ModelChecker output as training data:
1. Run the ModelChecker on all 42 BX axiom instances — verify they're classified as valid
2. Run on known non-theorems — verify countermodels are found
3. Cross-validate against Lean's decidability procedure on 1000+ randomly generated formulas
4. Flag any disagreements as potential semantic bugs

### Priority 3: Document the Corrective Signal's Limitations

Even after updates, the corrective signal has inherent limitations:
- Bounded model search (false negatives possible)
- Z3 timeout handling (should be labeled "unknown," not "valid")
- Dense frame class formulas may not be checkable
- Formulaic complexity limits practical throughput

### Priority 4: Consider Alternative Corrective Signal Sources

Given the significant update effort, consider:
- Using the Lean **decidability procedure** (already in the ProofChecker) as the corrective signal instead of the ModelChecker
- This avoids all semantic divergence risks — the same Lean codebase provides both positive and negative signals
- The decidability procedure already labels formulas as provable/unprovable with formal correctness guarantees

---

## Summary of Divergences

| Feature | Lean ProofChecker | ModelChecker | Impact |
|---------|-------------------|--------------|--------|
| Formula constructors | 6 (atom, bot, imp, box, untl, snce) | 15 operators (no untl/snce) | CRITICAL: Can't check Until/Since formulas |
| Temporal domain | Parametric ordered group (Int, Rat, Real) | Fixed integer [-M+1, M-1] | CRITICAL: No dense/continuous support |
| Temporal quantification | All times in D (strict <) | Times in world's interval only | CRITICAL: Different truth conditions |
| Box quantification | ∀ σ ∈ Omega (shift-closed set) | ∀ valid world IDs with time guard | HIGH: May exclude relevant worlds |
| Task relation | Ternary (w, duration, u) with 3 axioms | Binary (w, u) unit transitions | HIGH: Lost duration structure |
| Abundance | ShiftClosed for all Δ | Skolem forward/backward by ±1 | MEDIUM: May miss multi-step shifts |
| Frame classes | 3 (Base, Dense, Discrete) | 1 (implicit discrete only) | CRITICAL: Can't distinguish validity classes |

**Bottom line**: The ModelChecker in its current state would produce training signals that are **semantically incorrect** relative to the Lean ProofChecker's logic. Integration requires either substantial updates to the ModelChecker or using the Lean decidability procedure as the corrective signal instead.
