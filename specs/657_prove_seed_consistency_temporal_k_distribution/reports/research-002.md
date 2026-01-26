# Research Report: Temporal T Axiom Blocking Issue and Convex Time Domain Solutions

**Task**: 657 - prove_seed_consistency_temporal_k_distribution
**Started**: 2026-01-26T16:00:00Z
**Completed**: 2026-01-26T17:45:00Z
**Effort**: 3 hours
**Priority**: High
**Dependencies**: research-001.md, implementation-summary-20260126.md
**Sources/Inputs**:
- Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean
- Theories/Bimodal/Semantics/WorldHistory.lean
- Theories/Bimodal/ProofSystem/Axioms.lean
- specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-004.md
- Theories/Bimodal/Syntax/Formula.lean
**Artifacts**: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-002.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- **The Fundamental Problem**: TM logic uses IRREFLEXIVE temporal operators (G/H look at strictly future/past times, excluding present), so `G bot → bot` is NOT derivable syntactically
- **Why This Matters**: The seed consistency proof needs to derive contradiction from `G bot ∈ Gamma`, but `G bot` is actually SATISFIABLE in models with bounded future (vacuously true when no future times exist)
- **The Convex Domain Connection**: World histories use convex subsets of ordered additive groups as time domains, so some histories have first/last times and bounded domains
- **The Complete Dialectic**: Four viable approaches exist, ranging from semantic bridges to axiom additions to alternative proof strategies
- **Recommended Solution**: Use semantic satisfiability argument via completeness for inconsistent contexts, avoiding the syntactic derivation problem entirely

## Context & Scope

### The Blocking Issue (from implementation-summary-20260126.md)

The implementation of task 657 reached Step 4 in both `future_seed_consistent` and `past_seed_consistent` proofs:

```lean
-- Step 3: By MCS deductive closure, G bot ∈ Gamma
have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma := ...

-- Step 4: Now we need to derive a contradiction from G bot ∈ Gamma
-- BLOCKED: Cannot derive bot from G bot syntactically in TM logic
```

**Why Syntactic Derivation Fails**:

```lean
-- TM temporal semantics (from Truth.lean)
| Formula.all_future phi => forall (s : D), t < s -> truth_at M tau s phi
```

Key observations:
1. `G phi` means "phi holds at ALL STRICTLY FUTURE times" (s > t, excludes s = t)
2. `G bot` means "bot holds at all strictly future times"
3. This is **vacuously true** when there are no future times (last moment of finite history)
4. Therefore `G bot` is SATISFIABLE, not contradictory

### Convex Time Domains (from WorldHistory.lean)

World histories have explicit convexity constraints:

```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**Key properties**:
- Domain is a convex subset of the temporal order (no gaps)
- Some domains are bounded: `domain = {t | a ≤ t ≤ b}` has first time a and last time b
- Some domains are unbounded: `domain = {t | t ≥ 0}` or `domain = (t : D) → True`
- Convexity means: if x and z are in domain, all times between them are too

**Examples**:
- **Bounded**: `{t : Int | 0 ≤ t ≤ 100}` - has first (0) and last (100) times
- **Forward unbounded**: `{t : Int | t ≥ 0}` - has first time (0) but no last time
- **Fully unbounded**: All times in domain - no first or last time

### The Temporal T Axiom (What TM Does NOT Have)

**Modal T axiom** (TM DOES have this - Axioms.lean:92):
```lean
| modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)  -- □φ → φ
```

**Temporal T axiom** (TM does NOT have this):
```
G φ → φ   (what holds at all future times holds now)
H φ → φ   (what held at all past times holds now)
```

**Why TM Lacks Temporal T**:
- G and H are IRREFLEXIVE operators (strict inequalities s > t and s < t)
- Modal □ is REFLEXIVE (includes current world in "all accessible worlds")
- Temporal T would require REFLEXIVE temporal operators G' and H' where:
  - `G' φ` means "φ now AND at all future times" (s ≥ t, includes present)
  - `H' φ` means "φ now AND at all past times" (s ≤ t, includes present)

## Findings

### 1. Why G bot is Satisfiable (Not Contradictory)

**Semantic Analysis**:

```
G bot is true at (M, τ, t) ⟺ ∀s > t, s ∈ τ.domain → M,τ,s ⊨ bot
                          ⟺ ∀s > t, s ∈ τ.domain → False
                          ⟺ ¬∃s, (s > t ∧ s ∈ τ.domain)
                          ⟺ "No times exist strictly after t in this history"
```

**When G bot is true**:
1. **Last moment of bounded history**: τ.domain = {s | 0 ≤ s ≤ 100}, at time t = 100
   - No s exists with s > 100 in domain
   - G bot is vacuously true

2. **Isolated point domain**: τ.domain = {t}, domain has only one time
   - No s exists with s > t in domain
   - G bot is vacuously true

**When G bot is false**:
1. **Unbounded forward domain**: τ.domain = {s | s ≥ 0}, at any time t
   - For any t, there exists s = t + 1 > t in domain
   - Need bot to hold at s, but bot is always false
   - G bot is false

2. **Interior point of bounded domain**: τ.domain = {s | 0 ≤ s ≤ 100}, at time t = 50
   - s = 51 exists with 51 > 50 in domain
   - Need bot to hold at 51, but bot is false
   - G bot is false

**Critical Insight**: `G bot` is NOT a tautological contradiction. Its truth depends on the domain structure of the history.

### 2. Syntactic vs Semantic Approaches to Deriving Contradiction

**What We CANNOT Do (Syntactic)**:
```lean
-- Goal: [] ⊢ G bot → bot
-- This is NOT derivable without temporal T axiom
-- G bot does not syntactically imply bot in TM logic
```

**What We CAN Do (Semantic)**:

Given that TM logic is intended to be sound and complete for the class of ALL temporal models (including unbounded ones):

```lean
-- If G bot is in an MCS Gamma, then:
-- 1. Gamma is satisfiable (by MCS definition)
-- 2. There exists a model M, history τ, time t where all formulas in Gamma are true
-- 3. In particular, G bot is true at (M,τ,t)
-- 4. This means τ has no future times after t (bounded forward domain)
```

**The Key Question**: Does TM logic's validity quantify over ALL temporal models, or only UNBOUNDED ones?

From Validity.lean:
```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ
```

This quantifies over ALL world histories τ, including those with bounded domains.

### 3. The Complete Dialectic: Four Viable Approaches

#### Approach A: Semantic Bridge via Completeness (Recommended)

**Motivation**: Avoid syntactic derivation of `G bot → bot` by using semantic properties of MCS.

**Core Idea**: An MCS containing `G bot` is satisfiable, but only in models with bounded forward domains. If we can show that seed consistency requires unbounded domains, we get a contradiction.

**Strategy**:
```lean
lemma future_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (0 : D) < t) : SetConsistent (future_seed D Gamma t) := by
  by_contra h_incons
  -- Get G bot ∈ Gamma via generalized temporal K
  have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma := ...

  -- Key semantic argument:
  -- If Gamma is satisfiable with G bot, then only in bounded-forward models
  -- But seed construction at time t > 0 requires unbounded forward domain
  -- (because we need to propagate to all future times from 0)

  have h_unbounded : ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t₀ : D),
      (∀ φ ∈ Gamma, truth_at M τ t₀ φ) →
      ∀ s > t₀, ∃ s' > s, s' ∈ τ.domain := by
    -- Proof: The indexed family construction requires propagating formulas
    -- from time 0 to time t > 0, which requires t ∈ τ.domain
    -- This pattern continues: if we can go from 0 to t, we can go beyond
    sorry

  -- But G bot ∈ Gamma implies bounded forward domain
  have h_bounded : ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t₀ : D),
      (∀ φ ∈ Gamma, truth_at M τ t₀ φ) →
      ¬∃ s > t₀, s ∈ τ.domain := by
    intro F M τ t₀ h_all
    -- G bot true means no future times exist
    have : truth_at M τ t₀ (Formula.all_future Formula.bot) := h_all _ h_G_bot_in
    unfold truth_at at this
    intro ⟨s, hs, hmem⟩
    exact this s hs hmem

  -- Contradiction between h_unbounded and h_bounded
  sorry
```

**Pros**:
- Avoids need for temporal T axiom
- Uses semantic properties of TM logic
- Respects the irreflexive nature of G/H operators
- Maintains compatibility with convex bounded domains

**Cons**:
- Requires proving that seed construction implies unbounded domains
- More complex than pure syntactic derivation
- Mixes syntactic (derivation trees) with semantic (model properties)

**Complexity**: High - requires deep integration of syntactic and semantic reasoning

#### Approach B: Add `sometime_future top` Axiom (Unbounded Time Axiom)

**Motivation**: Make unbounded time a syntactic property of the logic.

**New Axiom**:
```lean
| unbounded_future : Axiom (Formula.sometime_future Formula.top)
-- F top: "There exists a future time" (equivalently: ¬G bot)
```

where `sometime_future φ = ¬(all_future (¬φ))` (existential future).

**How This Helps**:
```lean
-- Now we can derive G bot → bot syntactically:
-- 1. Assume G bot
-- 2. F top is an axiom (sometime_future top)
-- 3. F top = ¬G bot (by definition and temporal duality)
-- 4. G bot ∧ ¬G bot is contradiction
-- 5. Therefore G bot → bot
```

**Semantic Consequence**: This axiom restricts validity to ONLY unbounded-forward temporal models.

**Impact on World Histories**:
- Bounded forward histories would no longer satisfy all axioms
- Only unbounded forward or bi-infinite histories would be valid models
- This is a **semantic restriction** on the model class

**Pros**:
- Simple syntactic solution
- Clear semantic meaning (unbounded forward time)
- Makes temporal logic more similar to standard LTL

**Cons**:
- **MAJOR**: Restricts model class, excluding bounded time structures
- Philosophically questionable: why should time be necessarily unbounded forward?
- Breaks compatibility with scenarios modeling "final moments" or "end of time"
- Asymmetric: what about past? Need `sometime_past top` too?

**Complexity**: Low implementation, HIGH semantic impact

**Verdict**: Not recommended unless unbounded time is a core intended property of TM logic.

#### Approach C: Add Reflexive Temporal Operators G' and H' (Temporal T)

**Motivation**: Make temporal operators reflexive like modal □.

**Syntax Change**:
```lean
inductive Formula where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past_ref : Formula → Formula   -- H' (reflexive, includes present)
  | all_future_ref : Formula → Formula -- G' (reflexive, includes present)
```

**New Semantics**:
```lean
| Formula.all_past_ref phi => forall (s : D), s ≤ t -> truth_at M tau s phi
| Formula.all_future_ref phi => forall (s : D), t ≤ s -> truth_at M tau s phi
```

**New Axioms**:
```lean
| temp_t_past (φ : Formula) : Axiom (Formula.all_past_ref φ |>.imp φ)
| temp_t_future (φ : Formula) : Axiom (Formula.all_future_ref φ |>.imp φ)
```

**Define Irreflexive Operators**:
```lean
-- G φ = "future but not present" = G' φ ∧ ¬φ
def Formula.all_future (φ : Formula) : Formula :=
  (Formula.all_future_ref φ).and φ.neg

-- H φ = "past but not present" = H' φ ∧ ¬φ
def Formula.all_past (φ : Formula) : Formula :=
  (Formula.all_past_ref φ).and φ.neg
```

**How This Helps**:
```lean
-- Now G' bot → bot is an axiom (temp_t_future)
-- For G bot to imply bot:
-- G bot = G' bot ∧ ¬bot (by definition)
-- G' bot → bot (axiom temp_t_future)
-- So G bot → bot
```

**Pros**:
- Clean correspondence with modal T axiom
- Makes temporal logic more uniform with modal logic
- Seed consistency proofs become trivial

**Cons**:
- **MAJOR**: Fundamentally changes the primitive operators of TM logic
- G and H become DEFINED operators, not primitive
- Violates the "conceptual elegance" mentioned in user preference
- Requires rewriting ALL existing temporal theorems and semantics
- Changes the character of the logic significantly

**Complexity**: Very High - requires major refactoring

**Verdict**: Not recommended unless willing to fundamentally redesign TM logic.

#### Approach D: Alternative Proof Strategy (Filtration or Henkin Construction)

**Motivation**: Use a different canonical model construction that doesn't require seed consistency.

**Core Idea**: Instead of indexed MCS families with seed sets, use:

1. **Filtration Construction** (from modal logic):
   - Start with finite set of formulas (closure under subformulas)
   - Build quotient of canonical model that preserves truth of these formulas
   - Finite quotient avoids issues with unbounded domain requirements

2. **Henkin-Style Construction**:
   - Build witnesses for existential temporal formulas directly
   - Use choice functions to select specific future/past times for F/P formulas
   - Construct history by explicitly satisfying witness requirements

3. **Semantic Canonical Model** (already partially done in Boneyard):
   - Use semantic definition of satisfiability directly
   - Construct model that satisfies consistent contexts
   - Bypass purely syntactic consistency proofs

**How This Helps**:
- Avoids needing to prove seed consistency syntactically
- Semantic constructions can use completeness results directly
- May be more compatible with bounded domains

**Pros**:
- Preserves G/H as irreflexive primitives
- No axiom changes needed
- May be more robust to bounded domains
- Semantic approach aligns with convexity properties

**Cons**:
- Requires redesigning canonical model construction (substantial work)
- May not simplify overall proof complexity
- Less standard than indexed MCS approach
- Semantic constructions may be harder to formalize in Lean

**Complexity**: Very High - requires new proof strategy

**Verdict**: Consider as fallback if syntactic approach proves untenable.

### 4. Analysis of Bounded vs Unbounded Time in TM Logic Design

**Question**: What is the intended scope of TM logic? Should it handle bounded time structures?

**Evidence for Unbounded Time Intent**:

From WorldHistory.lean (lines 13-14):
```
where `X ⊆ D` is a **convex** subset of the time group `D`
```

Time group D is typically:
- `Int` (unbounded bi-infinite)
- `Rat` (unbounded dense)
- `Real` (unbounded continuous)

**Evidence for Bounded Time Compatibility**:

From WorldHistory.lean examples:
- Convexity explicitly allows bounded domains: `{t | a ≤ t ≤ b}`
- No axioms or definitions restrict to unbounded domains
- Validity.lean quantifies over ALL world histories, not just unbounded ones

**Task Semantics Context** (from paper references in comments):

JPL paper §app:TaskSemantics defines world histories with convex time domains without requiring unboundedness.

**Critical Observation**: The current semantics ALLOWS both bounded and unbounded histories. Adding unbounded-time axioms would be a semantic restriction.

### 5. Recommended Solution: Approach A with Refinement

**Strategy**: Use semantic argument that MCS containing `G bot` cannot participate in valid seed construction.

**Key Lemma Needed**:
```lean
lemma mcs_with_G_bot_not_at_origin
    {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (h_G_bot : Formula.all_future Formula.bot ∈ Gamma) :
    ¬∃ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
      -- Gamma true at origin time 0
      (∀ φ ∈ Gamma, truth_at M τ 0 φ) ∧
      -- Domain extends beyond 0 (needed for seed construction at t > 0)
      (∃ t : D, 0 < t ∧ τ.domain t)
```

**Proof Sketch**:
```
Assume ∃ model satisfying both conditions.
1. G bot true at time 0 means: ∀s > 0, s ∈ domain → bot true at s
2. But t > 0 exists in domain (second condition)
3. So bot must be true at t
4. But bot is always false (by semantics)
5. Contradiction.
```

**How This Resolves the Blocking Issue**:
```lean
lemma future_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (0 : D) < t) : SetConsistent (future_seed D Gamma t) := by
  by_contra h_incons

  -- Steps 1-3: Get G bot ∈ Gamma (as before, via generalized temporal K)
  have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma := ...

  -- Step 4: Semantic contradiction
  -- The indexed family construction requires domain extending to time t > 0
  -- But G bot in Gamma implies no domain past 0
  -- This contradicts the premise that we're constructing family at time t > 0

  have h_domain_requirement : ∃ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
      (∀ φ ∈ Gamma, truth_at M τ 0 φ) ∧ τ.domain t := by
    -- Indexed MCS family construction guarantees this
    -- (because we're building family from root MCS at time 0 to time t)
    sorry

  -- But this contradicts mcs_with_G_bot_not_at_origin
  exact mcs_with_G_bot_not_at_origin h_mcs h_G_bot_in h_domain_requirement
```

**Advantages of This Approach**:
- Preserves irreflexive G/H operators
- No axiom changes needed
- Compatible with bounded domains (just not those with G bot at construction origin)
- Uses semantic properties properly
- Maintains convexity requirement

**Implementation Complexity**: Medium-High
- Need to prove mcs_with_G_bot_not_at_origin (should be straightforward)
- Need to formalize connection between indexed family construction and domain requirements
- Integration with existing infrastructure clean

## Decisions

1. **Reject Approach B** (unbounded time axiom): Too restrictive semantically, excludes bounded time structures
2. **Reject Approach C** (reflexive temporal operators): Too invasive, changes fundamental character of TM logic
3. **Defer Approach D** (alternative construction): Keep as fallback if semantic approach fails
4. **Adopt Approach A** (semantic bridge): Best balance of preserving TM logic design while solving blocking issue

## Recommendations

### Immediate: Refine Semantic Bridge Approach

**Goal**: Formalize the connection between `G bot` in MCS and domain constraints.

**Tasks**:
1. Prove `mcs_with_G_bot_not_at_origin` lemma
2. Formalize indexed family domain requirements
3. Connect these to resolve seed consistency

**Effort**: 6-8 hours

**Files to Modify**:
- `IndexedMCSFamily.lean` - add semantic bridge lemmas
- Possibly new file: `Theories/Bimodal/Metalogic/Representation/SemanticBridge.lean`

### Alternative: Investigate Completeness Results

**Goal**: Check if existing completeness theorems provide shortcuts.

**Question**: Does `SetMaximalConsistent Gamma → satisfiable D Gamma` already give us what we need?

**Investigation**:
- Review Completeness.lean for relevant theorems
- Check if semantic satisfiability of MCS has been proven
- Look for bridges between syntactic consistency and semantic models

**Effort**: 2-3 hours research

**Value**: May discover that semantic argument is already formalized elsewhere

### Longer-term: Consider Axiom Design Philosophy

**Question**: Should TM logic ultimately commit to unbounded or bounded time?

**Options**:
1. **Stay agnostic** (current): Support both, handle via semantic reasoning
2. **Commit to unbounded**: Add axiom, simplify proofs but restrict models
3. **Parametric logic**: Make boundedness a parameter, have two versions

**Recommendation**: Stay agnostic for now. The philosophical question of whether time is necessarily unbounded is beyond the scope of proof system design.

**Future work**: If bounded time structures prove consistently problematic, revisit this decision.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Semantic bridge requires circular reasoning | High - blocks proof | Medium | Carefully separate syntactic (derivation) from semantic (satisfiability) reasoning |
| Domain requirement formalization is complex | Medium - adds complexity | High | Build incrementally, use examples to guide formalization |
| Existing completeness results insufficient | High - may need alternative approach | Low | Research existing semantic bridges first |
| User may prefer different approach | Low - can adapt | Medium | Present complete dialectic with trade-offs |

## Appendix

### Mathematical Background: Reflexive vs Irreflexive Operators

**Modal Logic Analogy**:
- **S5 Box (□)**: Reflexive - quantifies over ALL accessible worlds (including current)
  - `□φ → φ` is axiom (T axiom)
- **S4 Box**: Reflexive and transitive
  - `□φ → φ` is axiom
  - `□φ → □□φ` is axiom

**Standard LTL (Linear Temporal Logic)**:
- **Always (□)**: Often REFLEXIVE in LTL: `□φ` means "φ now and always in future"
  - This allows `□φ → φ`
- **Eventually (◇)**: Reflexive dual: "φ now or at some future time"
  - This allows `φ → ◇φ`

**TM Logic Design Choice**:
- G and H are IRREFLEXIVE (strictly future/past)
- This matches "will be" vs "is and will be" English intuition
- But creates technical complications for canonical models

### Convexity and Boundedness Properties

**Convex Bounded Domain Example** (Int):
```lean
domain = {t : Int | 0 ≤ t ≤ 100}

Properties:
- Convex: if 0 ∈ domain and 100 ∈ domain, then all t with 0 ≤ t ≤ 100 in domain ✓
- Bounded forward: last time is 100
- Bounded backward: first time is 0
- G bot true at t=100: ∀s > 100, ... (no such s exists in domain) ✓
```

**Convex Unbounded Domain Example** (Int):
```lean
domain = {t : Int | t ≥ 0}

Properties:
- Convex: if t₁ ∈ domain and t₂ ∈ domain, all t with t₁ ≤ t ≤ t₂ in domain ✓
- Unbounded forward: no last time
- Bounded backward: first time is 0
- G bot false everywhere: for any t, s = t+1 > t exists in domain ✗
```

**Key Insight**: Convexity ALLOWS bounded domains but doesn't REQUIRE them. The semantic approach must handle both cases correctly.

### Implementation Roadmap

**Phase 1: Semantic Bridge Lemmas** (6-8 hours)
- Prove `mcs_with_G_bot_not_at_origin`
- Formalize domain requirements for indexed families
- Test on simple examples

**Phase 2: Integration with Seed Consistency** (4-6 hours)
- Modify future_seed_consistent proof
- Modify past_seed_consistent proof
- Verify compilation and coherence

**Phase 3: Documentation and Testing** (2-3 hours)
- Document the semantic reasoning
- Add comments explaining why G bot creates issues
- Test on full representation theorem

**Total Estimated Effort**: 12-17 hours

### References

- **TM Axiom System**: Theories/Bimodal/ProofSystem/Axioms.lean
- **World History Semantics**: Theories/Bimodal/Semantics/WorldHistory.lean
- **Validity and Satisfiability**: Theories/Bimodal/Semantics/Validity.lean
- **Previous Research**: specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-004.md
- **Implementation Attempt**: specs/657_prove_seed_consistency_temporal_k_distribution/summaries/implementation-summary-20260126.md
- **Modal Logic Reference**: Blackburn et al., "Modal Logic" (Cambridge University Press)
- **Temporal Logic Reference**: Goldblatt, "Logics of Time and Computation" (CSLI Publications)
