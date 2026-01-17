# Research Report: Task #257 (Syntactic Time Construction)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Approach 3 - Syntactic Time Construction from Ordered Group Axioms

## Summary

This report investigates **Approach 3** from research-004.md: constructing times syntactically from equivalence classes of formulas, leveraging axioms (explicit or implicit) that characterize a totally ordered commutative group structure.

**Key Finding**: While propositional temporal logic cannot fully express the first-order axioms of ordered abelian groups, the TM logic's **frame constraints** (nullity, compositionality) combined with **temporal axioms** (T4, TA, TL) characterize the *relational structure* arising from such groups. However, **syntactic time construction requires extending the logic with duration terms** - a significant departure from the current propositional approach. The recommended path forward is a **hybrid approach** that constructs a quotient structure from syntactically-definable temporal relations.

## The NOTE from research-004.md

The NOTE at line 114 states:

> "there are axioms (or should be) for totality of the temporal order, reflexivity, transitivity, linearity, that there is an additive identity time, etc., to get all the structure of a totally ordered commutative group"

This raises the question: Can these structures be characterized axiomatically and used to construct times from syntax?

## What Characterizes a Totally Ordered Abelian Group?

A totally ordered abelian group **G = (G, +, -, 0, ≤)** satisfies:

### Group Axioms (AddCommGroup)
1. **Associativity**: (a + b) + c = a + (b + c)
2. **Identity**: a + 0 = a
3. **Inverses**: a + (-a) = 0
4. **Commutativity**: a + b = b + a

### Order Axioms (LinearOrder)
5. **Reflexivity**: a ≤ a
6. **Antisymmetry**: a ≤ b ∧ b ≤ a → a = b
7. **Transitivity**: a ≤ b ∧ b ≤ c → a ≤ c
8. **Totality**: a ≤ b ∨ b ≤ a

### Compatibility (IsOrderedAddMonoid)
9. **Monotonicity**: a ≤ b → a + c ≤ b + c

## How the Current System Encodes These

The TM logic **implicitly** encodes ordered group structure via:

### Frame Constraints (TaskFrame.lean)
| Constraint | Algebraic Property |
|------------|-------------------|
| `nullity : ∀ w, task_rel w 0 w` | Identity element |
| `compositionality : task_rel w x u → task_rel u y v → task_rel w (x+y) v` | Associativity of composition |

### Temporal Axioms (Axioms.lean)
| Axiom | Property | Order Correspondence |
|-------|----------|---------------------|
| **T4**: `Fφ → FFφ` | Future transitivity | Transitivity of `<` |
| **TA**: `φ → F(P¬¬φ)` | Connectedness | No temporal gaps |
| **TL**: `△φ → F(Pφ)` | Temporal closure | Convexity |
| **Duality rule**: `⊢ φ → ⊢ swap(φ)` | Past-future symmetry | Time reversal via `-` |

### What's NOT Axiomatized (but required by semantics)
- **Commutativity**: `task_rel w x u ∧ task_rel w y u' → ???`
- **Inverses**: No direct axiom for "reversing" time
- **Density/Discreteness**: The logic is intentionally agnostic

## The Core Problem with Syntactic Time Construction

### Why It's Difficult

In propositional temporal logic:
- Formulas talk about **truth at times**, not about **times themselves**
- We can quantify over times implicitly (∀t, ∃t) via G, H, F, P
- But we **cannot** quantify over **durations** in the object language

To construct times syntactically, we would need expressions like:
```
"The equivalence class of formulas true at time d + e"
```

But `d + e` is a **meta-level** expression. The formula `Fφ` means "φ at some future time" - it doesn't specify *which* future time or *how far* into the future.

### The Henkin Construction Analogy

In first-order logic completeness (Henkin's method):
1. Add fresh **constants** (Henkin witnesses) to the language
2. Build the domain as **equivalence classes of terms**
3. The quotient by `=` gives the canonical domain

For TM temporal logic, the analogous approach would:
1. Add **duration terms** to the syntax: `0, 1, -1, d + e, ...`
2. Add **equality axioms** for durations
3. Build canonical time as equivalence classes of duration terms

**This would transform TM from propositional to first-order temporal logic.**

## Approach 3: A Hybrid Syntactic Construction

Given the constraints of propositional temporal logic, here's a refined version of Approach 3:

### The Key Insight

While we can't construct duration terms, we CAN construct a structure from the **reachability relation** defined by maximal consistent sets:

```lean
def SyntacticReachability (Γ Δ : CanonicalWorldState) : Type :=
  { chain : List CanonicalWorldState //
    chain.head? = some Γ ∧
    chain.getLast? = some Δ ∧
    ∀ i, consecutive_modal_reach chain[i] chain[i+1] }
```

Where `consecutive_modal_reach` is defined by:
- `□φ ∈ Γ → φ ∈ Δ` (modal accessibility)
- `Fψ ∈ Γ → ψ ∈ Δ` (temporal future step)
- `Pψ ∈ Γ → ψ ∈ Δ` (temporal past step)

### Constructing Syntactic Time

**Step 1**: Define temporal indices syntactically
```lean
-- Syntactic "distance" between MCSs via minimal proof steps
def SyntacticDistance (Γ Δ : CanonicalWorldState) : ℤ∞ :=
  if h : ∃ n : ℕ, FutureReachable n Γ Δ
  then (Nat.find h : ℤ∞)
  else if h : ∃ n : ℕ, PastReachable n Γ Δ
  then -(Nat.find h : ℤ∞)
  else ⊤
```

**Step 2**: Quotient by equivalence
```lean
-- Two MCSs are "temporally equivalent" if they have the same temporal formulas
def TemporalEquiv (Γ Δ : CanonicalWorldState) : Prop :=
  (∀ φ, Fφ ∈ Γ ↔ Fφ ∈ Δ) ∧
  (∀ φ, Pφ ∈ Γ ↔ Pφ ∈ Δ)

def SyntacticTime := Quotient (temporalEquivSetoid)
```

**Step 3**: Define group operations on the quotient
```lean
-- Zero: The equivalence class containing "now" (current time)
def syntacticZero : SyntacticTime := ⟦currentMCS⟧

-- Addition: Concatenation of reachability chains
def syntacticAdd : SyntacticTime → SyntacticTime → SyntacticTime := ...

-- Order: Induced by future reachability
def syntacticLe : SyntacticTime → SyntacticTime → Prop := ...
```

### The Critical Question

**Does the quotient have the required structure?**

For this to work, we need the axioms to **force** the quotient to have:
1. Well-defined addition (from compositionality)
2. An ordered group structure

**Theorem (Sketch)**: Given the TM axioms, the syntactic temporal quotient is:
- A **preorder** (reflexive, transitive) - from T4, nullity
- **Connected** (any two elements comparable) - from TA
- But **NOT necessarily a group** - commutativity of addition is not guaranteed

### Why This Partially Works

The axioms characterize a **preorder with composition**, but:
- **Commutativity** of time addition is a **semantic** property, not syntactic
- The syntactic quotient is "maximally abstract" - it doesn't distinguish discrete from dense time

This is actually **desirable** for agnostic completeness:
- The syntactic time works for ANY frame satisfying the axioms
- It's the "free" structure generated by the relational constraints

## Recommended Implementation Strategy

### Option A: Relativized Completeness (from research-004)
Keep time as a type parameter T. This is simpler and sufficient:
```lean
theorem completeness (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (φ : Formula) : valid_at_T T φ → DerivationTree [] φ
```

**Pros**: Standard approach, well-understood, matches literature
**Cons**: Time not constructed from syntax; feels "less pure"

### Option B: Syntactic Quotient Time (Approach 3)
Construct time from temporal formula equivalence classes:
```lean
def SyntacticTime := Quotient TemporalEquivSetoid

theorem completeness_syntactic (φ : Formula) :
    valid_at_T SyntacticTime φ → DerivationTree [] φ
```

**Pros**: Truly constructs all structure from syntax
**Cons**: Complex; quotient may lack full group structure; may require additional axioms

### Option C: Hybrid Approach (Recommended)

Use **Option A** for the main theorem, but prove that **Option B** embeds into any T:
```lean
-- Main completeness (parameterized)
theorem completeness (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (φ : Formula) : (∀ (F : TaskFrame T) ..., truth_at ...) → DerivationTree [] φ

-- Syntactic time embeds universally
theorem syntactic_time_universal :
    ∀ T [instances], ∃ (embed : SyntacticTime →o T), ...
```

This shows that:
1. Completeness holds for all concrete time types (practical)
2. The syntactic quotient is the "universal" or "free" time structure (theoretical)
3. Any frame's time type receives a canonical map from syntactic time

## What Additional Axioms Would Be Needed for Full Group Structure?

If we wanted the syntactic quotient to be a full ordered abelian group, we would need axioms expressing:

### For Commutativity
An axiom like: "If φ is true after waiting d, then waiting e, the same as waiting e then d"

**Problem**: We can't express "waiting d" in the object language.

Closest approximation:
```
F(Pφ ∧ Fψ) → F(Fψ ∧ Pφ)  -- But this doesn't capture commutativity of durations
```

### For Density/Discreteness
These CAN be axiomatized:
```
-- Density: Between any two times, there's a third
Fφ → F(F φ ∧ P(F φ))  -- "Eventually" implies "eventually after an intermediate point"

-- Discreteness: There's an immediate next time
Fφ → X φ ∨ X X φ ∨ ...  -- Using "next" operator X (not in current TM)
```

### For Unboundedness
```
-- Future unbounded: There's always a further future
F⊤  -- Always eventually true (trivially valid in linear time)

-- Past unbounded: There's always a further past
P⊤  -- Always past true (trivially valid in linear time)
```

## Conclusions and Recommendations

### Answer to the NOTE

The NOTE correctly identifies that axioms characterizing ordered group structure are needed. The current TM axiom system **partially** characterizes this:

| Property | Current Status |
|----------|----------------|
| Reflexivity | ✓ Via nullity |
| Transitivity | ✓ Via T4, compositionality |
| Totality | ✓ Via TA (connectedness) |
| Identity (0) | ✓ Via nullity |
| Associativity | ✓ Via compositionality |
| Commutativity | ✗ Implicit in semantics only |
| Inverses | ✗ Via temporal duality (meta-level) |

### Recommended Path Forward

1. **Primary approach**: Use **Relativized Completeness** (Option A from research-004)
   - Parameterize by time type T
   - Simpler, follows standard practice
   - Sufficient for all practical purposes

2. **Secondary result**: Prove the **syntactic quotient** is the **initial object**
   - Shows that TM axioms uniquely characterize the "most abstract" time structure
   - Valuable for theoretical understanding
   - Not required for main completeness theorem

3. **Future work**: If full syntactic construction desired, extend TM to include:
   - Duration terms in the syntax
   - Equality axioms for durations
   - This would make TM a **first-order temporal logic**

### Connection to Other Research Reports

- **research-003.md**: Proposed `Int` as canonical time - this is an instance of Option A
- **research-004.md**: Introduced relativized completeness - this is the recommended approach
- **This report**: Investigates whether times can be constructed purely syntactically - conclusion: partially, but not necessary for main theorem

## References

- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) - Frame class completeness
- [Linear Temporal Logic (ScienceDirect)](https://www.sciencedirect.com/topics/computer-science/linear-time-temporal-logic)
- [Totally Ordered Abelian Group (Encyclopedia of Mathematics)](https://encyclopediaofmath.org/wiki/Totally_ordered_group)
- Goldblatt, R. "Logics of Time and Computation" - Canonical model methods
- `Theories/Bimodal/ProofSystem/Axioms.lean` - TM axiom definitions
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Frame constraints encoding group structure
- `Theories/Bimodal/Metalogic/Completeness.lean` - Current completeness infrastructure

## Next Steps

1. Proceed with **Option A** (Relativized Completeness) for the implementation plan
2. Optionally add a theorem showing syntactic time is initial/universal
3. Document the relationship between frame constraints and group axioms
4. Consider adding density/discreteness axioms if specialized completeness results are desired
