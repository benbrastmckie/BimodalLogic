# Convention Migration Research: untl/snce Argument Order

## Summary

This report maps the scope and risk of migrating from the current `untl(guard, event)` convention to Burgess's `U(event, guard)` convention.

**Bottom line**: This is a large but mostly mechanical refactor affecting 33 active files and ~2,141 references (1,164 untl + 977 snce). It should be done AFTER closing the 2 remaining sorry sites, not before.

---

## 1. Current Convention Analysis

### Formula Constructor (Formula.lean:80-82)

```lean
| untl : Formula → Formula → Formula   -- untl(arg1, arg2)
| snce : Formula → Formula → Formula   -- snce(arg1, arg2)
```

The docstring says: `Until (phi U psi, "phi holds until psi becomes true")` -- this reads as if arg1=guard, arg2=event, but the docstring notation "phi U psi" is actually ambiguous.

### Semantics (Truth.lean:127-130)

```lean
| Formula.untl phi psi => exists s : D, t < s /\ truth_at ... s psi /\
    forall r : D, t < r -> r < s -> truth_at ... r phi
| Formula.snce phi psi => exists s : D, s < t /\ truth_at ... s psi /\
    forall r : D, s < r -> r < t -> truth_at ... r phi
```

**Current mapping**:
- `untl phi psi`: phi = guard (intermediate points r), psi = event (endpoint s)
- `snce phi psi`: phi = guard (intermediate points r), psi = event (endpoint s)

### Burgess Convention (Section 1.2)

```
V(U(alpha, beta)) = {x : exists y(x < y /\ y in V(alpha) /\ forall z(x < z < y => z in V(beta)))}
```

**Burgess mapping**: U(alpha, beta): alpha = event (endpoint y), beta = guard (intermediate z)

### The Swap

| Position | Current (codebase) | Burgess |
|----------|--------------------|---------|
| 1st arg  | guard (phi)        | event (alpha) |
| 2nd arg  | event (psi)        | guard (beta)  |

The swap is **exactly reversed**: our 1st arg is Burgess's 2nd arg, and vice versa.

### Derived Operators Confirm the Convention

```lean
-- Formula.lean:330
def next (phi : Formula) : Formula := Formula.untl Formula.bot phi
-- X(phi) = bot U phi --> arg1=bot=guard, arg2=phi=event
```

Burgess: F(alpha) = U(alpha, top) -- arg1=event, arg2=guard

Our `next` uses `untl bot phi` meaning guard=bot, event=phi. Under Burgess convention this would be `untl phi bot` (event=phi, guard=bot). This confirms the swap.

---

## 2. Files Affected

### Active Files (33 total, non-Boneyard)

| File | untl+snce refs | Category |
|------|---------------|----------|
| `Chronicle/PointInsertion.lean` | 1068 | Chronicle construction (largest) |
| `Chronicle/RRelation.lean` | 209 | Burgess r-relation lemmas |
| `Chronicle/CounterexampleElimination.lean` | 144 | CE elimination |
| `Theorems/TemporalDerived.lean` | 67 | Derived temporal theorems |
| `Metalogic/Soundness.lean` | 45 | Soundness proof |
| `Syntax/Formula.lean` | 46 | Formula definition + theorems |
| `BXCanonical/Quasimodel/Construction.lean` | 40 | Quasimodel |
| `ProofSystem/Axioms.lean` | 38 | Axiom definitions |
| `Chronicle/ChronicleConstruction.lean` | 35 | Chronicle omega-chain |
| `BXCanonical/Quasimodel/Realization.lean` | 35 | Quasimodel realization |
| `ProofSystem/Substitution.lean` | 32 | Substitution lemmas |
| `Metalogic/SoundnessLemmas.lean` | 32 | Soundness lemmas |
| `Syntax/Subformulas.lean` | 28 | Subformula enumeration |
| `Syntax/SubformulaClosure.lean` | 20 | Subformula closure |
| `BXCanonical/CanonicalChain.lean` | 20 | Canonical chain |
| `Bundle/UntilSinceCoherence.lean` | 18 | Until/Since coherence |
| `Chronicle/ChronicleTypes.lean` | 18 | Chronicle type definitions |
| `Bundle/TemporalCoherence.lean` | 16 | Temporal coherence |
| `Bundle/SuccRelation.lean` | 14 | Successor relation |
| `BXCanonical/Filtration/DefectChain.lean` | 13 | Defect chain |
| Remaining 13 files | ~118 total | Various |

### Boneyard Files (12 total)

These are dead code and could be migrated at lower priority or left as-is.

### Non-Theories Files (2)

Test files and root-level imports.

### Total Active References: ~2,141 (1,164 untl + 977 snce)

---

## 3. Mechanicality Assessment

### Is this a simple swap?

**Mostly yes, with important caveats.** The refactor has three layers:

#### Layer 1: Constructor swap (MECHANICAL)

Everywhere `Formula.untl A B` appears, swap to `Formula.untl B A`. Same for `snce`. This covers:
- Pattern matches: `| untl phi psi =>` becomes `| untl psi phi =>` (or rename variables)
- Constructor calls: `Formula.untl guard event` becomes `Formula.untl event guard`

**However**, the best approach is to NOT swap argument positions in the code at all. Instead:
1. Swap the semantics definition (Truth.lean lines 127-130)
2. Swap the axiom definitions (Axioms.lean)
3. Then everything else is already correct, because the variable names bound in pattern matches just get new meaning

**This is the critical insight**: If you swap the SEMANTICS, the proof terms don't need to change. The constructor `untl` is just a data constructor -- its arguments have no inherent meaning until the semantics assigns one. The swap only needs to happen at:
- The `truth_at` definition (2 lines)
- The axiom definitions (which reference Burgess notation)
- The docstrings/comments

#### Layer 2: Parameter naming (COSMETIC but confusing)

Throughout the codebase, variables are named following the current convention:
```lean
(h_until : Formula.untl gamma delta in A)  -- gamma=guard, delta=event
```

After the semantics swap, gamma would mean event and delta would mean guard. This is cosmetically wrong but doesn't break anything. However, it creates exactly the kind of confusion the migration aims to eliminate.

**Cost of full renaming**: Every variable name `gamma`/`delta` in the context of untl/snce would need review. This is ~hundreds of variable names across 33 files.

#### Layer 3: Docstrings and comments (MANUAL)

All comments referencing "guard-first convention" or "our untl(guard, event)" need updating. Key locations:
- `Formula.lean:79` ("phi holds until psi becomes true")
- `Truth.lean:10-17` (A2 Guard Convention header)
- `Axioms.lean:170-185` (enrichment axiom comments)
- `RRelation.lean:1398-1399` (Convention note: Xu's "U(gamma, beta)" = our untl(beta, gamma))
- `ChronicleTypes.lean:39-48` (open guard semantics description)
- Many scattered docstrings

---

## 4. The Elegant Approach: Semantics-Only Swap

The cleanest migration is:

### Step 1: Swap the truth_at definition (2 lines changed)

```lean
-- BEFORE (current):
| Formula.untl phi psi => exists s, t < s /\ truth_at ... s psi /\
    forall r, t < r -> r < s -> truth_at ... r phi

-- AFTER (Burgess):
| Formula.untl phi psi => exists s, t < s /\ truth_at ... s phi /\
    forall r, t < r -> r < s -> truth_at ... r psi
```

### Step 2: Swap the axiom definitions

Each axiom that references `Formula.untl A B` or `Formula.snce A B` needs A and B swapped to maintain the same logical content.

For example, BX5 (self_accum_until) currently says:
```lean
| self_accum_until (phi psi : Formula) :
    Axiom ((Formula.untl phi psi).imp
      (Formula.untl (Formula.and phi (Formula.untl phi psi)) psi))
```

After swap, this should become:
```lean
| self_accum_until (phi psi : Formula) :
    Axiom ((Formula.untl psi phi).imp
      (Formula.untl psi (Formula.and phi (Formula.untl psi phi))))
```

### Step 3: Swap derived operators

```lean
-- next: currently untl bot phi, should become untl phi bot
def next (phi : Formula) : Formula := Formula.untl phi Formula.bot
-- prev: currently snce bot phi, should become snce phi bot  
def prev (phi : Formula) : Formula := Formula.snce phi Formula.bot
```

Wait -- but this is WRONG under Burgess! Burgess says F(alpha) = U(alpha, top), not U(alpha, bot).

Actually let me re-examine. Next is NOT the same as F. X(phi) = "phi at the next instant" = bot U phi under the current convention (guard=bot means no intermediate points, event=phi). Under Burgess convention, X(phi) = U(phi, bot). This is correct: event=phi at endpoint, guard=bot (vacuous at intermediate).

### Step 4: Fix the Soundness proof

The Soundness proof (Soundness.lean, SoundnessLemmas.lean) verifies that axioms are valid under the semantics. After swapping BOTH the semantics and the axioms, the Soundness proof should still go through, but the intermediate steps may need adjustment in variable naming.

### Step 5: Fix everything else

All the completeness machinery (RRelation, Chronicle, etc.) operates at the syntactic level -- it reasons about `Formula.untl gamma delta in A` membership. After the semantics swap, these formulas have different meaning, so the constructions need to be checked.

**Key risk**: The burgessR definition:
```lean
def burgessR (A : Set Formula) (beta : Formula) (C : Set Formula) : Prop :=
  forall gamma in C, Formula.untl beta gamma in A
```

Currently this means: for all gamma in C, `untl(beta=guard, gamma=event) in A`.
After semantics swap: `untl(beta=event, gamma=guard)` -- which is WRONG for Burgess's content-based r-relation.

**This means burgessR needs its argument order swapped too**: `Formula.untl gamma beta in A` (event=gamma from C serves as event, beta serves as guard).

This cascades through ALL of the Chronicle construction code. The variable naming throughout RRelation.lean, PointInsertion.lean, CounterexampleElimination.lean, etc. would become confusing because beta/gamma switch roles.

---

## 5. Risk Assessment

### Risks

1. **Silent semantic change**: Both arguments to `untl` have type `Formula`. Swapping arguments at the constructor level compiles without error but changes meaning. Any missed swap site silently corrupts the logic.

2. **Variable name confusion cascade**: The entire Chronicle construction uses `beta` for guard and `gamma` for event (matching our convention). After the swap, every `beta`/`gamma` usage becomes misleading. This is ~1,200+ lines in PointInsertion.lean alone.

3. **Burgess relation inversion**: The `burgessR A beta C = forall gamma in C, untl beta gamma in A` definition would need argument swap, and ALL uses of burgessR would need updating.

4. **swap_temporal breaks**: Currently `untl phi psi` swaps to `snce phi psi` preserving argument positions. This is correct because both untl and snce use the same arg1=guard, arg2=event convention. After the Burgess migration, this still works (both would use arg1=event, arg2=guard), so `swap_temporal` itself is fine.

5. **Axiom docstrings reference Burgess notation**: The axiom docstrings already try to bridge between conventions (e.g., "in our guard-first convention: untl(phi, psi)"). These all need rewriting.

6. **The 2 sorry sites**: Both remaining sorry sites in ChronicleConstruction.lean (lines 1301, 1313) deal with guard propagation through the limit construction. Changing the convention mid-proof would add confusion. The sorry sites reference `Formula.untl xi eta` where xi=guard, eta=event -- renaming while trying to close them would be counterproductive.

### What Could Go Wrong

- A missed swap in one axiom: axiom system becomes unsound
- A missed swap in one proof: proof term is wrong (Lean may catch this, but only if the types don't accidentally line up)
- Variable name confusion leads to wrong proof strategy during sorry-closing work

---

## 6. Timing Recommendation

**Strongly recommend: AFTER closing the 2 remaining sorry sites.**

Reasons:

1. **The sorry sites are in ChronicleConstruction.lean** (lines 1301, 1313) which deal with guard propagation through the limit construction. These are the most convention-sensitive code in the project. Changing the convention while working on them would add unnecessary confusion.

2. **The convention swap does NOT help close the sorries.** The sorry sites need to prove that `xi in limit_g A h_mcs h_nubr3 x y` -- this is about showing that the guard formula xi propagates through splitting steps. Whether xi is called "arg1" or "arg2" doesn't change the mathematical content of what needs to be proved.

3. **The migration is self-contained and mechanical.** It can be done as a single coherent pass after the proof is complete. There's no technical debt that accumulates from waiting.

4. **Risk of introducing bugs during sorry-closing.** If the convention changes and some variable names are wrong, it could lead to attempting proof strategies based on the wrong reading of a formula -- exactly the confusion the migration aims to eliminate, but at the worst possible time (during the hardest remaining proofs).

### Recommended Approach

1. Close the 2 sorry sites with the current convention
2. Create a dedicated branch for the convention migration
3. Do the migration in a single pass:
   a. Swap semantics (Truth.lean: 2 lines)
   b. Swap axiom definitions (Axioms.lean: ~30 sites)
   c. Swap derived operators (Formula.lean: next, prev)
   d. Fix burgessR and related definitions (ChronicleTypes.lean: 4 definitions)
   e. Fix all code that constructs `Formula.untl`/`Formula.snce` terms
   f. Rename variables where beta/gamma convention is misleading
   g. Update all docstrings
4. Run `lake build` to verify -- type checker will catch any structural mismatches
5. Run test suite

### Estimated Effort

| Component | Lines to Change | Difficulty |
|-----------|----------------|------------|
| Semantics (Truth.lean) | 2 | Trivial |
| Axioms (Axioms.lean) | ~30 | Mechanical |
| Formula.lean (derived ops, swap_temporal) | ~10 | Mechanical |
| ChronicleTypes.lean (burgessR defs) | ~20 | Careful |
| RRelation.lean | ~100 | Careful (variable renaming) |
| PointInsertion.lean | ~500+ | Mechanical but large |
| CounterexampleElimination.lean | ~70 | Mechanical |
| ChronicleConstruction.lean | ~20 | Mechanical |
| Soundness/SoundnessLemmas | ~40 | Careful |
| All other files | ~200 | Mechanical |
| Docstrings/comments | ~100 | Manual |
| **Total** | **~1,100** | **1-2 days** |

### Alternative: Rename-Only (No Swap)

A lighter-weight option: keep the argument order as-is but rename the constructor fields and add type aliases:

```lean
| untl (guard : Formula) (event : Formula) : Formula  -- explicit field names
```

This adds documentation without any semantic change. However, it doesn't solve the fundamental problem of reading Burgess's paper and needing to mentally swap every U(alpha, beta) occurrence.
