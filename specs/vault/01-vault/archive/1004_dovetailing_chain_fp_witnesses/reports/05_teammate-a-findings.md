# Teammate A Findings: Codebase Semantic Structure Analysis

## Key Findings

### 1. Current Architecture Does NOT Properly Separate Modal vs Temporal Dimensions

The BFMCS/FMCS infrastructure conflates what should be distinct theoretical roles:

| Concept | Current Implementation | Thomason's Framework |
|---------|----------------------|---------------------|
| World States | `CanonicalMCS.world : Set Formula` | Primitive modal dimension |
| Durations | `D : Type*` with `[Preorder D]` | Temporal intervals between times |
| Families/Histories | `FMCS D` - indexed by D | World histories = functions from times to states |
| Times | Implicitly = D | RELATIVE TO each world history |

**Critical Gap**: In the current implementation, the domain `D` serves double-duty as both "times" and the indexing structure. There is no separation where times are defined relative to world histories.

### 2. Semantic Role Analysis

#### CanonicalMCS (CanonicalFMCS.lean:78-83)
```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
```
- Represents: A maximal consistent set (a "possible world" in modal logic terms)
- **Issue**: This is a syntactic object (set of formulas), not a semantic world state

#### FMCS (FMCSDef.lean:80-101)
```lean
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```
- Represents: A time-indexed family of MCSes with temporal coherence
- **Analogous to**: A single "world history" in Thomason's sense
- **Issue**: The indexing domain D is treated as absolute time, not history-relative time

#### CanonicalR (CanonicalFrame.lean:63-64)
```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```
- Represents: Temporal accessibility (future direction)
- **Semantic Role**: `M R M'` means M' is temporally accessible from M (M' is "in the future of" M)
- **NOT modal accessibility**: This is purely temporal, not S5 modal

#### BFMCS (BFMCS.lean:88-119)
```lean
structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```
- Represents: A bundle of FMCS families with modal coherence
- **Modal coherence**: Box quantifies over families at the SAME time
- **Analogous to**: The set Omega of world histories in Thomason's framework

### 3. WorldHistory Definition (Semantics Side)

The semantic side DOES have proper history structure (WorldHistory.lean:69-97):
```lean
structure WorldHistory {D : Type*} [...] (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**This IS closer to Thomason's model**:
- `states : (t : D) → domain t → F.WorldState` - histories map times to world states
- `D` is the duration/time group
- `WorldState` is the modal dimension

**Gap**: The metalogic (BFMCS/FMCS) does not connect to this semantic structure properly.

### 4. The Duration Domain D

In FMCS/BFMCS:
- `D` requires only `[Preorder D]` (or `[Preorder D] [Zero D]` for TemporalCoherentFamily)
- Common instantiations: `Int`, `CanonicalMCS` itself, `Rat`
- `AddCommGroup D` is NOT required at the metalogic level

**Semantic mismatch**: TaskFrame requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` for proper temporal structure with durations.

### 5. F/P Witness Status

#### Sorry-Free Path (CanonicalMCS domain):
- `canonical_forward_F` (CanonicalFrame.lean:122-137): PROVEN
- `canonical_backward_P` (CanonicalFrame.lean:151-166): PROVEN
- `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean:293-311): PROVEN

#### Sorry Path (Int domain):
- `intFMCS_forward_F` (IntBFMCS.lean via IntFMCSTransfer.lean): **SORRY**
- `intFMCS_backward_P` (IntBFMCS.lean via IntFMCSTransfer.lean): **SORRY**
- Documented as "dovetailing gap" - chain may not include witnesses

## Semantic Structure Analysis

### Current Model (Implicit):
```
Time Domain D ──────────────────────────────────────────────────────────────────
    │
    │ indexed by
    ▼
FMCS (one family = one "history")
    │
    │ assigns
    ▼
Set Formula (MCS at each time t)
```

### Thomason's Model (Should Be):
```
World States W ◄────── modal dimension
    ▲
    │ τ(t) =
    │
World History τ : X → W ◄────── τ is a function from times to world states
    ▲
    │ domain
    │
Times X ⊆ D ◄────── times RELATIVE TO history τ
    ▲
    │ convex subset of
    │
Duration Group D ◄────── temporal dimension
```

### Key Differences:

1. **Times vs Durations**: Thomason treats times as relative to each history (convex domain X ⊆ D), while current implementation uses D directly as "time points"

2. **World States**: Thomason has primitive world states W with task relation `·: W × D → P(W)`, while current implementation uses MCSes (syntactic objects) as "worlds"

3. **Histories as Functions**: Thomason defines histories as functions τ: X → W respecting task relation, while current FMCS is a function D → Set Formula without the task structure

4. **Modal Accessibility**: Thomason: Box quantifies over all histories in Omega containing time t. Current: Box quantifies over all families at time t (correct conceptually, but families are syntactic)

## Gap Analysis

### Missing Infrastructure for Proper World/Duration/History Separation:

1. **No Semantic World States in Metalogic**
   - Current: MCSes serve as both syntactic proof objects and semantic worlds
   - Need: Separate `WorldState` type with valuation connection

2. **No History-Relative Times**
   - Current: All families share the same absolute time domain D
   - Need: Each history should have its own convex time domain

3. **No Task Relation in Metalogic**
   - Current: CanonicalR is purely syntactic (g_content inclusion)
   - Need: Proper task_rel connection for respects_task constraint

4. **Missing Cantor Embedding for Int**
   - CanonicalMCS is uncountable, Int is countable
   - FMCSTransfer requires bijection (impossible)
   - Dovetailing is the workaround but has sorries

5. **No Shift-Closed Property**
   - WorldHistory.time_shift exists in semantics
   - Not wired into BFMCS construction

## Recommended Approach

### Option A: Enrich Existing Chain Construction (Pragmatic)
- Focus on closing the dovetailing gap for Int
- Accept that CanonicalMCS and Int have different mathematical properties
- Use FMCSTransfer indirectly: build Int chain that mirrors CanonicalMCS structure

### Option B: New Semantic-Syntactic Bridge (Principled)
- Define `CanonicalWorldState := CanonicalMCS` as explicit semantic type
- Define `CanonicalTaskFrame` with proper task_rel
- Build `CanonicalWorldHistory` that connects FMCS to semantic histories
- Derive F/P witnesses from semantic properties

### Option C: Hybrid Approach (Recommended)
1. For CanonicalMCS domain: Already works (sorry-free)
2. For Int domain: Use "enriched chain" that explicitly tracks:
   - Which F-obligations need witnesses
   - Which P-obligations need witnesses
   - Build witnesses during construction (not after)

The key insight is that the current `canonical_forward_F` and `canonical_backward_P` work because CanonicalMCS contains ALL MCSes. For Int, we need to ensure the chain INCLUDES the necessary witnesses, which requires dovetailing or enrichment during construction.

## Confidence Level

**Medium-High** on the analysis, **Medium** on the recommended approach.

The semantic structure analysis is solid - the code clearly shows the conflation of roles. The gap analysis correctly identifies what's missing. The recommended approach requires validation that enriching the chain construction can work without hitting the same obstacles that blocked previous attempts.

Key uncertainty: Whether there's a mathematically elegant way to achieve "times relative to histories" that would make F/P witnesses trivial, or whether the dovetailing approach is fundamentally necessary for any countable (Int/Rat) time domain.
