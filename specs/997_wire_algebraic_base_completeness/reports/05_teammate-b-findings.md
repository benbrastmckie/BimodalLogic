# Mathematical Foundations for Succ-Chain Completeness

**Date**: 2026-03-22
**Task**: 997 - wire_algebraic_base_completeness
**Role**: Teammate B - Mathematical Foundations & Alternative Patterns
**Session**: sess_1774238975_1de1fa

---

## Executive Summary

The current BFMCS (Bundle of FMCS) approach to completeness has **architecturally unprovable sorries** due to the W=D conflation problem. The mathematical foundations research reveals that:

1. **Task Semantics** differs from standard Kripke semantics in critical ways
2. The **BFMCS modal coherence conditions** require cross-family S5 transfer that TM logic cannot provide
3. The **Succ-chain bypass** offers a cleaner mathematical foundation for debt-free completeness
4. **Reflexive temporal semantics** (as of Task 29) simplifies the proof structure

---

## 1. Task Semantics vs Kripke Semantics

### 1.1 Task Semantics Structure

Task frames (from `TaskFrame.lean`) differ from standard Kripke frames:

| Component | Standard Kripke | Task Semantics |
|-----------|----------------|----------------|
| Worlds | W (set) | WorldState (type) |
| Accessibility | R : W -> W -> Prop | task_rel : W -> D -> W -> Prop |
| Modal quantification | Over R-accessible worlds | Over all histories in Omega at time t |
| Temporal quantification | N/A | Over all times in D |

**Key distinction**: The task relation is **three-place** `task_rel w d u`, parameterized by duration `d : D` from an ordered abelian group.

### 1.2 Satisfaction in Task Semantics

From `Truth.lean`, the satisfaction relation has these critical properties:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Critical observations**:
1. **Box quantifies over histories in Omega**, not directly over MCS
2. **Temporal operators quantify over ALL times in D**, not just domain times
3. **Atoms are false outside domain** (not undefined)
4. **Reflexive temporal semantics**: G and H use `<=` (including now)

### 1.3 WorldHistory Constraints

From `WorldHistory.lean`:
- Histories must have **convex domains** (no temporal gaps)
- Histories must **respect the task relation**: `task_rel (states s hs) (t - s) (states t ht)`
- Time-shift is a well-defined automorphism

---

## 2. Why BFMCS Modal Coherence Is Problematic

### 2.1 The BFMCS Modal Coherence Conditions

From `BFMCS.lean`:

```lean
structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Formula.box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Formula.box phi in fam.mcs t
```

### 2.2 The W=D Conflation Problem

From `DirectMultiFamilyBFMCS.lean` (lines 14-52):

> The BFMCS structure conflates two distinct concepts:
> - **W** (modal accessibility): Which MCS are modally accessible from which
> - **D** (temporal domain): Time points with AddCommGroup structure

The `modal_forward` condition requires **cross-MCS transfer**:
```
Box phi in fam.mcs t -> phi in fam'.mcs t (for ALL families fam, fam')
```

This is a **semantic property** requiring modal accessibility between different families. TM logic includes S5 axioms (T, 4, B, modal_5_collapse) but these operate **within individual MCS**, not across families.

### 2.3 Why TM Cannot Prove Cross-Family Transfer

The S5 axioms provide:
- **T**: `Box phi -> phi` (within same MCS)
- **4**: `Box phi -> Box Box phi` (internal modal collapse)
- **B**: `phi -> Box Diamond phi`
- **modal_5_collapse**: `Diamond Box phi -> Box phi`

**None of these transfer formulas between different MCS**. The 5-collapse axiom gives internal modal collapse, not cross-MCS transfer.

Cross-MCS transfer requires **modal saturation**: every Diamond formula in any family must have a witness in some other family. At t=0, `discreteClosedMCS` provides this via `closedFlags_union_modally_saturated`. At t != 0, chain positions may leave the closed set, breaking saturation.

### 2.4 Architectural Unprovability

From `specs/997_wire_algebraic_base_completeness/reports/04_mid-implementation-review.md`:

| Sorry Location | Nature | Resolvable? |
|----------------|--------|-------------|
| `directFamilies_modal_forward` at t=0 | Cross-family modal transfer requires S5 | **NO** - TM lacks full S5 |
| `directFamilies_modal_forward` at t != 0 | Chains may be disjoint at non-root times | **NO** - architectural |
| `directFamilies_modal_backward` at t != 0 | Coverage at chain positions | **NO** - architectural |

---

## 3. Alternative Mathematical Structures

### 3.1 The Succ-Chain Approach

The Succ relation (from `SuccRelation.lean`) provides a cleaner foundation:

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u <= v                        -- (1) G-persistence
  && f_content u <= v \cup f_content v    -- (2) F-step
```

**Key insight**: Rather than proving "no intermediates exist" (covering lemma), Succ **defines immediate succession syntactically**.

### 3.2 Content Extractors

| Extractor | Definition | Captures |
|-----------|------------|----------|
| `g_content(M)` | `{phi \| G phi in M}` | Universal future commitments |
| `h_content(M)` | `{phi \| H phi in M}` | Universal past commitments |
| `f_content(M)` | `{phi \| F phi in M}` | Existential future obligations |
| `p_content(M)` | `{phi \| P phi in M}` | Existential past obligations |

### 3.3 CanonicalTask: The Three-Place Relation

From `CanonicalTaskRelation.lean`:

```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  if n > 0 then exists chain, Succ-chain from u to v of length n
  else if n < 0 then CanonicalTask v (-n) u  -- converse
  else u = v                                  -- nullity
```

### 3.4 Why This Works Without BFMCS

The CanonicalTask approach bypasses BFMCS by:

1. **Single FMCS + TaskFrame**: No cross-family modal coherence needed
2. **Direct TaskFrame from CanonicalTask**: Satisfies nullity, compositionality, converse
3. **WorldHistory from Succ-chains**: Respects task relation by construction

From `SuccChainTaskFrame.lean`:

```lean
def CanonicalTaskTaskFrame : TaskFrame Int where
  WorldState := Set Formula
  task_rel := CanonicalTask
  nullity_identity := CanonicalTask_nullity_for_frame
  forward_comp := CanonicalTask_forward_comp_for_frame
  converse := CanonicalTask_converse_for_frame
```

---

## 4. Reflexive vs Non-Reflexive Semantics

### 4.1 Current State (Reflexive)

As of Task 29, temporal operators G and H use **reflexive semantics** (`<=` instead of `<`):

```lean
| Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

### 4.2 Benefits of Reflexive Semantics

1. **T-axioms are valid**: `G phi -> phi` and `H phi -> phi` hold semantically
2. **No irreflexivity/antisymmetry concerns**: The canonical task relation doesn't need to exclude `t = t`
3. **Simpler truth lemma**: No edge cases for the current time
4. **Alignment with modal logic literature**: G and H are standardly reflexive

### 4.3 Impact on Completeness Proof

With reflexive semantics:
- The truth lemma for G is: `G phi in fam.mcs t <-> forall s >= t, phi in fam.mcs s`
- No need for `canonicalR_irreflexive_axiom` (removed by Task 26)
- CanonicalTask at distance 0 is just identity (no self-loops with positive duration)

---

## 5. Single-Step Forcing Theorem

### 5.1 The Key Mathematical Result

From `SuccRelation.lean`:

**Theorem** (single_step_forcing): Let u be an MCS with `F phi in u` and `FF phi not in u`. Then for any MCS v with `Succ(u, v)`, we have `phi in v`.

**Proof outline**:
1. `FF phi not in u` -> `neg FF phi in u` (negation completeness)
2. `neg FF phi = GG(neg phi)` (definition expansion)
3. `G(neg phi) in g_content(u)` (by G-persistence)
4. `G(neg phi) in v` (by Succ condition 1)
5. `F phi not in v` (since `F phi = neg G neg phi`)
6. By F-step: `phi in f_content(u)` implies `phi in v or phi in f_content(v)`
7. Since `F phi not in v`, we have `phi not in f_content(v)`
8. Therefore `phi in v`

### 5.2 Bounded Witness Distance

**Corollary**: If `F^n phi in u` but `F^{n+1} phi not in u`, then following a Succ-chain from u, phi is reached within at most n steps.

This provides the key mechanism for the truth lemma: F-obligations are resolved within bounded chain distance.

---

## 6. Critical Dependencies for Succ-Chain Completeness

### 6.1 What Must Be True

| Property | Status | Source |
|----------|--------|--------|
| Succ relation well-defined | Proven | `SuccRelation.lean` |
| Successor existence (forward) | Axiom + structure | `SuccExistence.lean` |
| Predecessor existence (backward) | Axiom + structure | `SuccExistence.lean` |
| CanonicalTask satisfies TaskFrame axioms | Proven | `SuccChainTaskFrame.lean` |
| FMCS from Succ-chain is temporally coherent | Partial (some axioms) | `SuccChainFMCS.lean` |
| Truth lemma for Succ-chain construction | Partial | Need to verify |

### 6.2 Remaining Axioms in Succ Infrastructure

From `SuccExistence.lean`:

```lean
axiom successor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) in u) :
    SetConsistent (successor_deferral_seed u)

axiom predecessor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) in u) :
    SetConsistent (predecessor_deferral_seed u)

axiom predecessor_f_step_axiom (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) in u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) <= u \cup f_content u
```

These axioms are **semantically justified** by frame conditions (NoMaxOrder, NoMinOrder) and the DF/DB discrete axioms.

---

## 7. Comparison: BFMCS vs Succ-Chain

| Aspect | BFMCS Approach | Succ-Chain Approach |
|--------|---------------|---------------------|
| Modal coherence | Cross-family (unprovable) | Not needed (single family) |
| Temporal coherence | FMCS structure | Succ-chain construction |
| F/P witnesses | Dovetailing (complex) | Deferral seeds (simpler) |
| TaskFrame construction | Via parametric canonical | Direct from CanonicalTask |
| Sorries | 5 architectural | 3 semantically justified axioms |
| Mathematical cleanness | W=D conflation | Clean separation |

---

## 8. Recommendations

### 8.1 For Task 997 Completion

**Option A: Mark Complete with Documentation**
- The `algebraic_base_completeness` theorem is structurally complete
- Sorries are inherited from BFMCS, which is architecturally constrained
- Document as "completeness modulo BFMCS modal coherence"

**Option B: Pivot to Succ-Chain Approach**
- Use `CanonicalTaskTaskFrame` from `SuccChainTaskFrame.lean`
- Build `succ_chain_history` from `SuccChainWorldHistory.lean`
- Avoid BFMCS entirely

### 8.2 Mathematical Foundation for Option B

The Succ-chain approach requires:
1. **Proving seed consistency axioms** (currently axiomatized, semantically sound)
2. **Truth lemma for CanonicalTask-based models**
3. **Validity quantification over Succ-chain models**

The key insight is that validity over **all TaskModels** can be witnessed by **one specific TaskModel** (the canonical one built from Succ-chains).

---

## 9. Confidence Assessment

| Finding | Confidence | Evidence |
|---------|------------|----------|
| BFMCS modal coherence is architecturally blocked | **HIGH** | DirectMultiFamilyBFMCS.lean documentation, Task 28 analysis |
| Succ-chain bypasses BFMCS limitations | **HIGH** | Report 20, SuccChainTaskFrame.lean working code |
| Reflexive semantics simplifies proof | **HIGH** | Task 29 completed, no irreflexivity axioms needed |
| Seed consistency is semantically sound | **MEDIUM** | Semantic justification in SuccExistence.lean, but axiomatized |
| Full sorry-free completeness achievable via Succ | **MEDIUM** | Depends on filling 3 Succ-existence axioms |

---

## References

- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - BFMCS structure and modal coherence
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - W=D conflation analysis
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - Succ definition and single-step forcing
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Successor/predecessor existence
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Succ-chain FMCS construction
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` - CanonicalTaskTaskFrame
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame structure
- `Theories/Bimodal/Semantics/Truth.lean` - Truth definition (reflexive semantics)
- `specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md` - Key bypass report
- `specs/997_wire_algebraic_base_completeness/reports/04_mid-implementation-review.md` - Current status analysis
