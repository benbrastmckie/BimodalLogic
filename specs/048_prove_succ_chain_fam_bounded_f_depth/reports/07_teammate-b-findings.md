# Teammate B Research Findings: Lean 4 Implementation Patterns

**Task**: 48 - Prove succ_chain_fam bounded F depth
**Focus**: Lean 4 patterns for complex termination proofs
**Session**: sess_1774298996_dd353b

---

## Key Findings

1. **The sorry is in a persistence case** within `restricted_forward_chain_iter_F_witness` at line 2261 of `SuccChainFMCS.lean`. The depth-decrease case (inl) is already proven; only the persistence case (inr) needs work.

2. **Mathlib provides `WellFounded.prod_lex`** for lexicographic termination: `WellFounded ra -> WellFounded rb -> WellFounded (Prod.Lex ra rb)`. This is the canonical way to express (d, k) termination measures.

3. **`Finset.strongInduction`** provides strong induction over finite sets using cardinality as the measure, with `termination_by s => #s`. This pattern directly applies to bounded iteration over `deferralClosure`.

4. **`InvImage.wf`** allows projecting any termination measure through a function: `f : alpha -> beta` with `WellFounded r` on `beta` gives `WellFounded (InvImage r f)`.

5. **The deferralClosure is finite** (`Finset Formula`) with computable cardinality. The `deferral_restricted_mcs_F_bounded` theorem already establishes that F-iterations are bounded by closure depth.

6. **Key insight from codebase**: The persistence case tracks "how many persistence steps" can occur. Since each persistence step keeps `F(chi)` in the chain at the same depth, and `deferralClosure(phi).card` bounds distinct formulas, persistence is finite.

---

## Mathlib Patterns Found

### Pattern 1: Lexicographic Product (Prod.Lex)

```lean
-- From Mathlib.Order.RelClasses
theorem WellFounded.prod_lex {ra : alpha -> alpha -> Prop} {rb : beta -> beta -> Prop}
    (ha : WellFounded ra) (hb : WellFounded rb) : WellFounded (Prod.Lex ra rb)

-- Usage for (d, k) termination:
instance : WellFoundedRelation (Lex (Nat * Nat)) :=
  Prod.Lex.instWellFoundedRelationLexOfWellFoundedLT
```

**Application**: Define measure as `(d, max_persistence - current_persistence)` where both components decrease lexicographically.

### Pattern 2: Finset Strong Induction

```lean
-- From Mathlib.Data.Finset.Basic
def Finset.strongInduction {p : Finset alpha -> Sort*}
    (H : forall s, (forall t, t < s -> p t) -> p s) : forall s, p s
  termination_by s => #s
```

**Application**: Track "remaining formulas that can persist" as a Finset, show it decreases.

### Pattern 3: InvImage Well-Founded

```lean
-- From Init.WF
theorem InvImage.wf {r : beta -> beta -> Prop} (f : alpha -> beta)
    (h : WellFounded r) : WellFounded (InvImage r f)
```

**Application**: Define custom measure function, use `InvImage.wf` with `Nat.lt_wfRel`.

### Pattern 4: Subrelation for Custom Measures

```lean
-- From Init.WF
theorem Subrelation.wf {r q : alpha -> alpha -> Prop}
    (h1 : Subrelation q r) (h2 : WellFounded r) : WellFounded q
```

**Application**: Show custom termination relation is subrelation of standard well-founded one.

---

## Recommended Implementation Approach

### Option A: Lexicographic Measure (Recommended)

**Measure**: `(d, max_F_depth_in_closure phi - f_nesting_depth (iter_F d psi))`

**Why it works**:
- First component `d` strictly decreases in the `inl` case (depth-decrease)
- In the `inr` case (persistence), `d` stays same but the F-nesting depth of the persisting formula increases, so the second component decreases
- The second component is bounded below by 0, so persistence terminates

**Implementation sketch**:
```lean
theorem restricted_forward_chain_iter_F_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi in restricted_forward_chain phi M0 k) :
    exists m, k < m /\ psi in restricted_forward_chain phi M0 m := by
  -- Use WellFounded.fix with lexicographic measure
  have h_wf : WellFounded (Prod.Lex Nat.lt Nat.lt) := WellFounded.prod_lex Nat.lt_wf Nat.lt_wf
  -- Define measure: (d, max_depth - current_depth)
  let measure := fun (d, k) => (d, max_F_depth_in_closure phi - f_nesting_depth (iter_F d psi))
  -- ... well-founded recursion on measure
```

### Option B: Fuel Pattern (Simpler but less elegant)

**Approach**: Add fuel parameter bounded by `deferralClosure.card`

```lean
private theorem iter_F_witness_fuel (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d fuel : Nat) (psi : Formula)
    (h_fuel : fuel <= (deferralClosure phi).card)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi in restricted_forward_chain phi M0 k) :
    exists m, k < m /\ psi in restricted_forward_chain phi M0 m := by
  induction fuel generalizing k with
  | zero =>
    -- Contradiction: fuel exhaustion contradicts finite closure
    sorry -- Prove this cannot happen
  | succ n ih =>
    -- ... same logic as current proof ...
```

**Caveat**: Requires proving fuel doesn't run out before success.

### Option C: Direct WellFounded.fix (Most Principled)

**Approach**: Use `WellFounded.fix` directly with explicit termination proof

```lean
noncomputable def iter_F_witness_wf (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) :
    (k : Nat) -> (d : Nat) -> (psi : Formula) ->
    d >= 1 -> iter_F d psi in restricted_forward_chain phi M0 k ->
    { m // k < m /\ psi in restricted_forward_chain phi M0 m } :=
  WellFounded.fix (WellFounded.prod_lex Nat.lt_wf Nat.lt_wf) fun (d, k) rec h_d_ge h_iter =>
    -- ... pattern match on F_step_witness result
    -- inl: recurse with (d-1, k+1) - lexicographically smaller
    -- inr: recurse with (d, k+1) + prove second component decreases
```

---

## Code Snippets

### Expressing Lexicographic Order

```lean
import Mathlib.Data.Prod.Lex
import Mathlib.Order.RelClasses

-- The termination measure type
abbrev TermMeasure := Lex (Nat * Nat)

-- Well-founded instance is automatic
#check (inferInstance : WellFoundedRelation TermMeasure)

-- Showing decrease in lexicographic order
example (d k : Nat) : toLex (d - 1, k + 1) < toLex (d, k) := by
  simp only [Prod.Lex.toLex_lt_toLex]
  left
  omega
```

### Using termination_by Clause

```lean
def myRec (d k : Nat) (bound : Nat) : Result :=
  if h : d = 0 then baseCase
  else if decreasing_case then
    myRec (d - 1) (k + 1) bound
  else
    myRec d (k + 1) bound  -- needs proof k+1 bound decreases
termination_by (d, bound - k)  -- lexicographic on (d, remaining_steps)
```

### Finset Cardinality for Bounds

```lean
-- The closure has finite cardinality
#check @Finset.card Formula (deferralClosure phi)

-- Cardinality provides termination bound
theorem persistence_bounded (phi : Formula) :
    forall chi in deferralClosure phi, persistence_steps chi <= (deferralClosure phi).card := by
  -- Each persistence step "uses" a formula position
  -- Finset.card bounds total possible uses
```

---

## Confidence Level

**High confidence** in the recommended approach.

The mathematical argument is sound: persistence cannot continue forever because:
1. `deferralClosure(phi)` is finite
2. Each persistence step keeps `F(chi)` at same depth but advances chain position
3. By negation completeness, eventually the Lindenbaum extension must choose `chi` over `neg chi`
4. The finite closure bounds the number of "persistence opportunities"

The Lean infrastructure (`Prod.Lex`, `WellFounded.fix`, `Finset.card`) is mature and well-suited to this pattern.

---

## Implementation Notes

1. **Prefer Option A** (lexicographic measure) - it's idiomatic Lean 4 and the Mathlib support is excellent.

2. **Key lemma needed**: Show that in the persistence case, either the depth decreases OR we've "used up" one persistence opportunity bounded by closure size.

3. **Alternative formulation**: Instead of tracking `(d, remaining_persistence)`, track the set of formulas that have persisted. Show this set strictly grows (or depth decreases). Termination follows from `Finset.lt_wf`.

4. **Watch for**: The proof may need to track which specific formula is persisting at each step. This might require refactoring to make the persistence tracking explicit in the recursion.
