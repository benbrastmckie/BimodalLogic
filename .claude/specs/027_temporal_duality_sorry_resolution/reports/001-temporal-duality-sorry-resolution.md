# Research Report: Temporal Duality Soundness Proof Analysis

## Executive Summary

This report provides a comprehensive analysis of the 3 remaining `sorry` cases in the temporal duality soundness proof (`Truth.lean` lines 589, 668, 690). The proof attempts to show that validity is preserved under the `swap_past_future` transformation via structural induction, but fails for three formula constructors: implication, past, and future.

**Key Finding**: The structural induction approach fundamentally fails because it attempts to prove `is_valid φ → truth_at M τ t ht φ.swap` (validity implies truth at a specific triple), but the required property is actually `is_valid φ → is_valid φ.swap` (validity implies validity). The current proof structure creates an impossible mathematical burden for the imp, past, and future cases.

**Recommended Approach**: **Approach B** (proof restructuring to `is_valid φ ↔ is_valid φ.swap`) is mathematically sound, well-aligned with the JPL paper, and has moderate implementation complexity. This approach avoids the fundamental structural problems of the current proof attempt.

## 1. Problem Statement and Context

### 1.1 Current Implementation Status

The temporal duality soundness proof is located in `Truth.lean` (lines 491-717) within the `TemporalDuality` namespace. The main theorem is:

```lean
theorem valid_swap_of_valid (φ : Formula) : is_valid φ → is_valid φ.swap_past_future
```

This theorem is proven by delegating to a helper lemma:

```lean
theorem truth_swap_of_valid_at_triple (φ : Formula) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : Int) (ht : τ.domain t) :
    is_valid φ → truth_at M τ t ht φ.swap_past_future
```

The helper lemma proceeds by structural induction on `φ`, with:
- ✅ **atom case** (line 536-540): Complete
- ✅ **bot case** (line 542-549): Complete
- ✅ **box case** (line 591-607): Complete
- ❌ **imp case** (line 551-589): `sorry` at line 589
- ❌ **past case** (line 609-669): `sorry` at line 668
- ❌ **future case** (line 671-691): `sorry` at line 690

### 1.2 Mathematical Structure of the Problem

**Local Validity Definition** (Truth.lean:509-511):
```lean
private def is_valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
    truth_at M τ t ht φ
```

**Global Validity Definition** (Validity.lean:45-47):
```lean
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
    truth_at M τ t ht φ
```

These definitions are identical, establishing that validity means "true at all model-history-time triples."

**Swap Past/Future Transformation** (Formula.lean:166-172):
```lean
def swap_past_future : Formula → Formula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swap_past_future ψ.swap_past_future
  | box φ => box φ.swap_past_future
  | past φ => future φ.swap_past_future
  | future φ => past φ.swap_past_future
```

The transformation is an involution (Formula.lean:179-187), meaning `φ.swap_past_future.swap_past_future = φ`.

### 1.3 Inference Rule Context

The temporal duality inference rule (Derivation.lean:107-113) states:

```lean
| temporal_duality (φ : Formula)
    (h : Derivable [] φ) : Derivable [] (swap_past_future φ)
```

This rule only applies to **empty context derivations** (theorems), not derivations with assumptions. The soundness theorem must prove:

```lean
Derivable [] φ → semantic_consequence [] φ.swap_past_future
```

Which, by validity equivalence (Validity.lean:84-90), reduces to:

```lean
valid φ → valid φ.swap_past_future
```

## 2. Why the Structural Induction Approach Fails

### 2.1 The Type Mismatch Problem

The helper lemma `truth_swap_of_valid_at_triple` has type:

```lean
is_valid φ → truth_at M τ t ht φ.swap_past_future
```

This states: "If φ is valid (true at ALL triples), then φ.swap is true at THIS SPECIFIC triple (M, τ, t)."

For the completed cases (atom, bot, box), this works because:
- **atom**: Validity at all triples includes this triple; swap is identity on atoms
- **bot**: Validity of bot is vacuously false (no formula satisfies it)
- **box**: Validity of `□ψ` implies validity of `ψ` (modal deduction), then IH applies

But for the remaining cases, we face a fundamental problem:

### 2.2 Implication Case Analysis (Line 551-589)

**Goal at line 551**:
```lean
is_valid (ψ → χ) → truth_at M τ t ht ((ψ → χ).swap_past_future)
```

**After simplification** (line 553-554):
```lean
is_valid (ψ → χ) → (truth_at M τ t ht ψ.swap → truth_at M τ t ht χ.swap)
```

**What we have**:
- `h_valid : is_valid (ψ → χ)` means `∀ F M τ t ht, truth_at M τ t ht ψ → truth_at M τ t ht χ`
- `h_swap_ψ : truth_at M τ t ht ψ.swap` (the antecedent of our goal's implication)

**What we need**: `truth_at M τ t ht χ.swap`

**The Problem**: To apply the induction hypothesis for χ, we need `is_valid χ`. But validity of `ψ → χ` does **not** imply validity of χ. Consider:
- `is_valid (p → p)` is true (tautology)
- `is_valid p` is false (p is an arbitrary atom)

We also cannot derive `truth_at M τ t ht ψ` from `truth_at M τ t ht ψ.swap` without knowing that `is_valid ψ.swap → is_valid ψ`, which is the **reverse direction** of what we're trying to prove!

**Mathematical Root Cause**: The implication constructor creates a dependency between subformulas at the **truth level** (truth of ψ implies truth of χ at the same triple), but validity at the **global level** (validity of ψ → χ) does not decompose into relationships between validities of ψ and χ individually.

### 2.3 Past Case Analysis (Line 609-669)

**Goal at line 609**:
```lean
is_valid (past ψ) → truth_at M τ t ht (past ψ).swap_past_future
```

**After simplification** (line 612):
```lean
is_valid (past ψ) → truth_at M τ t ht (future ψ.swap)
```

**Expanding the goal**:
```lean
is_valid (past ψ) → ∀ (s : Int) (hs : τ.domain s), t < s → truth_at M τ s hs ψ.swap
```

**Attempt to extract subformula validity** (lines 661-668):

The code attempts to prove `is_valid ψ` from `is_valid (past ψ)`:

```lean
have h_ψ_valid : is_valid ψ := by
  intro F' M' τ' r hr
  -- We need to find some t > r in τ'.domain.
  -- ...
  sorry
```

**The Problem**: To show ψ is valid at arbitrary `(F', M', τ', r)`, we need to "extract" ψ from `past ψ`. The validity of `past ψ` gives us:

```lean
∀ F M τ t ht, (∀ s < t, s ∈ τ.domain → truth_at M τ s hs ψ)
```

To instantiate this at time `r` to get `truth_at M' τ' r hr ψ`, we need some time `t > r` where `t ∈ τ'.domain` so that the past quantifier includes `r`.

**Critical Gap**: The WorldHistory domain is **convex** but **not necessarily unbounded**. For an arbitrary `(F', M', τ', r, hr)`, there is **no guarantee** that τ'.domain contains any `t > r`. The domain might be:
- Bounded: `τ'.domain = {s : Int | -100 ≤ s ≤ 100}`
- Right-bounded: `τ'.domain = {s : Int | s ≤ 0}`
- Single point: `τ'.domain = {s : Int | s = 0}`

**Mathematical Root Cause**: The temporal quantifiers (Past/Future) are **domain-dependent**. Their semantics (Truth.lean:90-91) explicitly restrict quantification to `s ∈ τ.domain`:

```lean
| Formula.past φ => ∀ (s : Int) (hs : τ.domain s), s < t → truth_at M τ s hs φ
```

Validity of `past ψ` does not imply validity of `ψ` because the past quantifier might be **vacuously satisfied** at times with no past in the domain.

### 2.4 Future Case Analysis (Line 671-691)

**Symmetric to Past Case**: The future case has the identical problem but in the opposite temporal direction. We cannot extract `is_valid ψ` from `is_valid (future ψ)` because future quantification might be vacuously satisfied at times with no future in the domain.

### 2.5 Fundamental Diagnosis

The root problem is that the proof attempts to prove:

```
is_valid φ → truth_at M τ t ht φ.swap
```

via structural induction. This works for "simple" constructors (atom, bot, box) but fails for constructors that:
1. **Create truth-level dependencies** (implication)
2. **Quantify over domain-restricted sets** (past, future)

The structural induction cannot "penetrate" these constructors to extract the needed properties.

## 3. Solution Approaches: Detailed Analysis

### 3.1 Approach A: Domain Unboundedness Assumption

**Description**: Add an assumption that all histories have unbounded domains:

```lean
def UnboundedDomain (τ : WorldHistory F) : Prop :=
  (∀ t : Int, ∃ s : Int, τ.domain s ∧ t < s) ∧
  (∀ t : Int, ∃ s : Int, τ.domain s ∧ s < t)
```

Then modify the validity definition:

```lean
def is_valid_unbounded (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F),
    UnboundedDomain τ →
    ∀ (t : Int) (ht : τ.domain t), truth_at M τ t ht φ
```

**Advantages**:
- ✅ Mathematically sound: With unbounded domains, we can extract `is_valid ψ` from `is_valid (past ψ)` by finding a time beyond any given time
- ✅ Physically reasonable: Real physical time extends infinitely in both directions
- ✅ Minimal changes: Only affects the past/future cases, not implication

**Disadvantages**:
- ❌ Changes validity semantics: The JPL paper does not assume unbounded domains
- ❌ Doesn't solve implication case: Still cannot extract `is_valid χ` from `is_valid (ψ → χ)`
- ❌ Creates two validity notions: Need to justify which one is "correct"
- ❌ Frame semantics mismatch: Task semantics explicitly allow bounded histories

**Alignment with JPL Paper**:
- ❌ **Poor alignment**: The paper's Definition of world histories (line 1849) states domains are "convex subsets of G", not "unbounded subsets"
- ❌ The paper's temporal operators (lines 1862-1865) use domain-restricted quantification explicitly

**Implementation Complexity**: **Low-Medium** (2-4 hours)
- Add UnboundedDomain definition (30 min)
- Modify validity definition (1 hour)
- Complete past/future cases (1-2 hours)
- Still need to solve implication case separately

**Risk Assessment**: **High**
- Semantic departure from paper specification
- Creates maintenance burden (two validity notions)
- Incomplete solution (implication still unsolved)

### 3.2 Approach B: Proof Restructuring to `is_valid φ ↔ is_valid φ.swap`

**Description**: Abandon the `truth_swap_of_valid_at_triple` approach entirely. Instead, prove the desired property directly:

```lean
theorem valid_swap_of_valid (φ : Formula) :
  is_valid φ ↔ is_valid φ.swap_past_future := by
  constructor
  · intro h_valid F M τ t ht
    -- Show: truth_at M τ t ht φ.swap
    -- Strategy: Construct a "time-reversed view" where φ is evaluated
    <structural induction on φ>
  · intro h_swap_valid
    -- Use swap involution: φ = φ.swap.swap
    rw [← Formula.swap_past_future_involution φ]
    -- Apply forward direction to φ.swap
    exact (valid_swap_of_valid φ.swap_past_future).mp h_swap_valid
```

**Key Insight**: For the forward direction, we prove directly that for any triple `(M, τ, t)`, if `φ` is valid, then `φ.swap` is true at that triple. The proof uses the **symmetry of Int's order structure** rather than trying to extract subformula validities.

**Induction Strategy for Forward Direction**:

1. **atom**: `swap (atom p) = atom p`, validity preserved trivially
2. **bot**: `swap bot = bot`, validity preserved trivially
3. **imp**:
   ```lean
   -- Goal: truth_at M τ t ht (swap(ψ → χ))
   --     = truth_at M τ t ht (swap ψ → swap χ)
   --     = (truth_at M τ t ht (swap ψ) → truth_at M τ t ht (swap χ))
   intro h_swap_ψ
   -- By IH: is_valid ψ → truth_at M τ t ht (swap ψ)
   -- Contrapositive: ¬truth_at M τ t ht (swap ψ) → ¬is_valid ψ
   -- But we have truth_at M τ t ht (swap ψ), so we can't derive contradiction
   --
   -- Alternative: Use that (ψ → χ) valid means:
   -- ∀ triple, truth ψ → truth χ
   -- Apply IH to both sides...
   --
   -- Actually, we need to show:
   -- (truth swap_ψ → truth swap_χ) follows from validity of (ψ → χ)
   --
   -- Key insight: We DON'T have validity of ψ or χ individually,
   -- but we can use the BICONDITIONAL from the IH!
   --
   -- By IH biconditional: truth φ ↔ truth (swap (swap φ)) for valid formulas
   -- Actually, that's not quite right either...
   ```

Wait, this approach **also fails** for implication! Let me reconsider...

**Actually**, the biconditional structure helps! Here's the key:

```lean
theorem valid_swap_iff_valid (φ : Formula) :
  is_valid φ ↔ is_valid φ.swap_past_future := by
  induction φ with
  | imp ψ χ ih_ψ ih_χ =>
    constructor
    · intro h_valid F M τ t ht
      -- Goal: truth_at M τ t ht (swap ψ → swap χ)
      simp only [swap_past_future, truth_at]
      intro h_swap_ψ
      -- Need: truth_at M τ t ht (swap χ)
      -- Strategy: Use IH biconditionals to relate swap to originals
      -- By ih_ψ: is_valid ψ ↔ is_valid (swap ψ)
      -- By ih_χ: is_valid χ ↔ is_valid (swap χ)
      -- We have: is_valid (ψ → χ) [from h_valid]
      -- This means: ∀ triple, (truth ψ → truth χ)
      -- In particular at (M, τ, t):
      have h_imp := h_valid F M τ t ht
      -- h_imp : truth_at M τ t ht ψ → truth_at M τ t ht χ
      -- We have h_swap_ψ : truth_at M τ t ht (swap ψ)
      -- Can we derive truth_at M τ t ht ψ from this?
      -- Only if swap ψ is valid...
```

Hmm, this **still** has the same problem! The biconditional structure doesn't help because we're at a **specific triple**, not talking about validity.

**Wait!** The key insight is that we shouldn't be proving truth at a specific triple from validity. We should prove **validity of swap from validity of original** by showing that the two are equivalent in a deeper sense.

Let me reconsider the mathematical structure:

For **implication**, the correct approach is to use that validity of `ψ → χ` is equivalent to **semantic consequence** `{ψ} ⊨ χ`. Then we need to show:

```
{ψ} ⊨ χ  ↔  {swap ψ} ⊨ swap χ
```

This is true if we can show that the swap transformation preserves semantic consequence. But proving **that** requires... the same induction!

**Fundamental Realization**: The implication case is **impossible to prove** with the current structural induction approach, whether we use the helper lemma or the direct biconditional. The reason is that **implication creates a truth-level dependency that cannot be analyzed by looking at validity alone**.

### 3.3 Approach B (Revised): Semantic Model Transformation

**Description**: Instead of trying to prove via formula induction, transform the **semantic models** directly. Show that for any model M and history τ, there exists a "time-reversed" model M' and history τ' such that:

```
truth_at M τ t ht φ ↔ truth_at M' τ' (-t) h(-t) (swap φ)
```

Then validity preservation follows immediately.

**Time-Reversed History Construction**:

```lean
def time_reverse (τ : WorldHistory F) : WorldHistory F where
  domain := fun t => τ.domain (-t)
  states := fun t ht => τ.states (-t) ht
  respects_task := <proof using task relation properties>
```

**Key Lemma**:

```lean
theorem truth_time_reverse_swap (M : TaskModel F) (τ : WorldHistory F)
    (t : Int) (ht : τ.domain t) (h_neg_t : (time_reverse τ).domain (-t)) (φ : Formula) :
    truth_at M τ t ht φ ↔ truth_at M (time_reverse τ) (-t) h_neg_t (swap φ) := by
  induction φ generalizing t with
  | atom p => rfl  -- states match
  | bot => rfl
  | imp ψ χ ih_ψ ih_χ =>
    constructor
    · intro h h_ψ_swap
      have h_ψ : truth_at M τ t ht ψ := (ih_ψ t ht h_neg_t).mpr h_ψ_swap
      have h_χ : truth_at M τ t ht χ := h h_ψ
      exact (ih_χ t ht h_neg_t).mp h_χ
    · intro h_swap h_ψ
      have h_ψ_swap : truth_at M (time_reverse τ) (-t) h_neg_t (swap ψ) := (ih_ψ t ht h_neg_t).mp h_ψ
      have h_χ_swap : truth_at M (time_reverse τ) (-t) h_neg_t (swap χ) := h_swap h_ψ_swap
      exact (ih_χ t ht h_neg_t).mpr h_χ_swap
  | box ψ ih =>
    constructor
    · intro h_box σ hσ_neg_t
      -- h_box : ∀ σ, truth_at M σ t hσ_t ψ
      -- Need: truth_at M σ (-t) hσ_neg_t (swap ψ)
      -- Apply IH with history σ instead of τ
      have hσ_t : σ.domain t := <from hσ_neg_t>
      have h_ψ : truth_at M σ t hσ_t ψ := h_box σ hσ_t
      exact (ih t hσ_t hσ_neg_t).mp h_ψ
    · -- symmetric
  | past ψ ih =>
    constructor
    · intro h_past s hs_rev h_neg_t_lt_s
      -- h_past : ∀ s < t, s ∈ τ.domain → truth_at M τ s hs ψ
      -- hs_rev : (time_reverse τ).domain s = τ.domain (-s)
      -- h_neg_t_lt_s : -t < s, i.e., -s < t
      -- Need: truth_at M (time_reverse τ) s hs_rev (swap ψ)
      have h_neg_s : τ.domain (-s) := hs_rev
      have h_neg_s_lt_t : -s < t := h_neg_t_lt_s  -- KEY: Order reversal!
      have h_ψ_at_neg_s : truth_at M τ (-s) h_neg_s ψ := h_past (-s) h_neg_s h_neg_s_lt_t
      -- Apply IH at time (-s)
      have h_neg_neg_s : (time_reverse τ).domain (-(-s)) := <-s = -(-s) = s>
      exact (ih (-s) h_neg_s h_neg_neg_s).mp h_ψ_at_neg_s
    · -- symmetric
  | future ψ ih =>
    -- Symmetric to past case, using t < s ↔ -s < -t
```

**Advantages**:
- ✅ **Solves all cases**: The implication case works because we're proving a biconditional at the same triple (τ vs time_reverse τ)
- ✅ **Uses order reversal**: Explicitly leverages `s < t ↔ -t < -s` from WorldHistory.lean
- ✅ **Mathematically principled**: Time reversal is a natural automorphism of (Int, <, +)
- ✅ **Paper-aligned**: The JPL paper's temporal symmetry is exactly about time reversal

**Disadvantages**:
- ⚠️ **Requires task relation property**: The `time_reverse` construction requires proving `respects_task`. For reversed history at times s < t, we need:
  ```
  task_rel (τ.states(-s)) (t - s) (τ.states(-t))
  ```
  But the original history only gives:
  ```
  task_rel (τ.states(s')) ((t' - s')) (τ.states(t'))  where s' = -t, t' = -s
  ```
  So we need:
  ```
  task_rel (τ.states(t')) (t' - s') (τ.states(s'))  [direction reversed!]
  ```

**Critical Question**: Does `respects_task` in the reversed direction hold?

Looking at the task relation (TaskFrame.lean):
- **nullity**: `task_rel w 0 w` - symmetric
- **compositionality**: `task_rel w d₁ u ∧ task_rel u d₂ v → task_rel w (d₁+d₂) v` - directional

For time reversal, we need to show that if we can go forward in time, we can go backward. This is **not** generally true for task relations! Task relations model **causal** or **enabling** relations, which are typically **irreversible**.

**Example**: A task relation might say "state w_initial enables state w_final after 10 time units" but NOT "state w_final enables state w_initial after 10 time units" (you can't unscramble an egg).

**Resolution**: The time-reversed history construction **only works for validity**, not for arbitrary models. When proving validity, we quantify over **all** models and histories. The key insight is:

For any model M and history τ, if φ is valid, then φ is true at (M, τ, t). To show swap φ is valid, we need to show swap φ is true at all (M', τ', t'). We can choose M' = M and τ' = τ (the **same** history, not reversed), and use the order reversal at the **temporal quantifier level**, not the history level.

**Revised Strategy**: Don't reverse the history; reverse the **temporal perspective**:

```lean
theorem truth_swap_same_history (M : TaskModel F) (τ : WorldHistory F)
    (t : Int) (ht : τ.domain t) (φ : Formula) :
    truth_at M τ t ht φ ↔ <something about swap φ at same (M, τ, ...)> := by
```

But this brings us back to the original problem: we can't relate truth of φ at (M, τ, t) to truth of swap φ at the same triple!

**Final Realization**: The time-reversed model approach **requires** that task relations be symmetric, which is **not** derivable from nullity and compositionality. This was the conclusion of the earlier research report (001-temporal-symmetry-analysis.md, Section 4.3-4.4).

### 3.4 Approach C: Constructive History Extension

**Description**: For the past/future cases, construct histories with extended domains that agree with the original on the overlap:

```lean
def extend_forward (τ : WorldHistory F) (t : Int) : WorldHistory F :=
  -- Extend τ to include t+1, t+2, ... using compositionality
```

Then prove that if `past ψ` is valid, we can evaluate it at the extended history to extract ψ at any given time.

**Advantages**:
- ✅ Avoids changing validity definition
- ✅ Works within existing frame semantics

**Disadvantages**:
- ❌ Doesn't solve implication case
- ❌ Extension construction is non-trivial: requires choosing specific states for extended times
- ❌ Extension might not exist for all frames (if compositionality doesn't allow forward extension)
- ❌ Extremely complex implementation

**Implementation Complexity**: **High** (15-20 hours)
- Define extension construction (5-6 hours)
- Prove extension preserves relevant properties (6-8 hours)
- Complete past/future cases (4-6 hours)
- Still need separate solution for implication

**Risk Assessment**: **Very High**
- May be impossible for some frames
- High implementation complexity
- Incomplete solution

### 3.5 Approach D: Restrict to Derivable Formulas

**Description**: Accept that temporal duality soundness holds only for **derivable** formulas, not all valid formulas:

```lean
theorem temporal_duality_sound_derivable (φ : Formula) :
  Derivable [] φ → Derivable [] φ.swap ∧
  (valid φ → valid φ.swap_past_future)
```

Then prove by induction on the **derivation structure**, not the formula structure.

**Proof Sketch**:
- Base cases (axioms): Show each TM axiom remains valid after swap
- Induction cases (rules): Show each inference rule preserves swap-validity

**Advantages**:
- ✅ **Mathematically correct**: The temporal duality **rule** only applies to derivable formulas
- ✅ **Proof by rule induction**: Natural for proving soundness
- ✅ **Matches actual usage**: We only apply TD to formulas we've derived

**Disadvantages**:
- ⚠️ **Weaker theorem**: Only works for derivable formulas, not arbitrary valid formulas
- ⚠️ **Admits incompleteness**: If there are valid-but-underivable formulas, they might not have swap-validity

**Implementation Complexity**: **Medium** (8-12 hours)
- Prove swap-validity for each axiom schema (4-6 hours)
- Prove each rule preserves swap-validity (4-6 hours)
- No changes to existing code structure

**JPL Paper Alignment**: **Good**
- The paper only claims temporal duality as an **inference rule**, not a semantic property
- The rule is part of the **proof system**, not the semantics
- This approach directly proves what the paper claims

**Mathematical Insight**: This approach recognizes that `swap_past_future` is a **syntactic** transformation, and temporal duality is a **proof-theoretic** principle, not necessarily a **semantic** one. The soundness proof shows that the syntactic rule preserves semantic validity for the specific class of formulas that can be derived.

### 3.6 Approach E: Prove Swap Involution at Validity Level

**Description**: Prove that for valid formulas, the swap transformation is not just a syntactic involution but a **semantic** involution. Then use this to complete the proof.

**Key Lemma**:
```lean
theorem swap_valid_iff (φ : Formula) (h : is_valid φ ∨ is_valid φ.swap) :
  is_valid φ ↔ is_valid φ.swap := by
```

This is weaker than the full biconditional but might be provable.

**Problem**: This lemma has the same circular dependency as the original proof - we need to know one direction is valid to prove the biconditional, but that's what we're trying to prove!

**Verdict**: **Not viable**

## 4. Comparative Analysis

| Criterion | Approach A: Unbounded | Approach B: Restructure | Approach C: Extension | Approach D: Derivable-Only |
|-----------|----------------------|-------------------------|----------------------|---------------------------|
| **Solves imp case** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Solves past/future** | ✅ Yes | ⚠️ Requires symmetry | ✅ Yes (complex) | ✅ Yes |
| **JPL alignment** | ❌ Poor | ⚠️ Requires frame property | ✅ Good | ✅ Excellent |
| **Implementation** | Low-Med (2-4h) | High (impossible?) | Very High (15-20h) | Medium (8-12h) |
| **Risk** | High (semantic change) | Very High (may be impossible) | Very High (may not exist) | Low |
| **Completeness** | Incomplete | Incomplete | Incomplete | Complete for derivable |
| **Maintenance** | High (two validity notions) | Unknown | High (complex construction) | Low |

## 5. Recommended Approach: Approach D (Restrict to Derivable Formulas)

**Rationale**:

1. **Mathematical Correctness**: The temporal duality **rule** in TM logic only applies to theorems (empty-context derivations). Proving soundness for this restricted class is exactly what the paper requires.

2. **JPL Paper Alignment**: The paper defines temporal duality as an **inference rule** (Derivation.lean:107-113), not as a semantic property of validity. Our soundness proof should match this scope.

3. **Implementation Viability**: Proving by induction on derivations avoids the fundamental structural problems of formula induction. Each axiom and rule can be handled separately.

4. **Risk Profile**: Low risk because we're proving exactly what's claimed, not overreaching.

5. **Avoids Impossible Cases**: The implication case is impossible to prove via formula induction for arbitrary valid formulas. Restricting to derivable formulas sidesteps this issue.

## 6. Implementation Plan for Approach D

### 6.1 Phase 1: Axiom Preservation (4-6 hours)

Prove that each TM axiom schema remains valid after swap:

```lean
theorem axiom_swap_valid (φ : Formula) (h_ax : Axiom φ) : is_valid φ.swap_past_future := by
  cases h_ax with
  | modal_t ψ =>
    -- □ψ → ψ becomes □(swap ψ) → swap ψ
    -- This is valid by modal T axiom applied to swap ψ
  | modal_4 ψ =>
    -- Similar: M4 applied to swap ψ
  | modal_b ψ =>
    -- Similar: MB applied to swap ψ
  | temp_4 ψ =>
    -- Future ψ → Future Future ψ becomes Past (swap ψ) → Past Past (swap ψ)
    -- Need to prove this is valid using order reversal
  | temp_a ψ =>
    -- Complex: needs order reversal reasoning
  | temp_l ψ =>
    -- Complex: involves both modal and temporal
  | modal_future ψ =>
    -- Swaps to: □ψ → □Past ψ, need to prove valid
  | temp_future ψ =>
    -- Swaps to: □ψ → Past □ψ, need to prove valid
```

**Key Insight**: Some axioms are **self-dual** under swap (MT, M4, MB), while others transform into related valid formulas (T4, TA, TL, MF, TF). We need to prove the transformed versions are valid using the semantics.

### 6.2 Phase 2: Rule Preservation (4-6 hours)

Prove that each inference rule preserves swap-validity:

```lean
theorem derivable_swap_valid (Γ : Context) (φ : Formula) :
  Derivable Γ φ → (∀ ψ ∈ Γ, is_valid ψ) → is_valid φ → is_valid φ.swap := by
  intro h_deriv h_gamma_valid h_phi_valid
  induction h_deriv with
  | axiom Γ φ h_ax =>
    exact axiom_swap_valid φ h_ax
  | assumption Γ φ h_mem =>
    exact h_gamma_valid φ h_mem
  | modus_ponens Γ φ ψ h_imp h_phi ih_imp ih_phi =>
    -- Complex: need to relate swap of MP to MP of swaps
  | modal_k Γ φ h ih =>
    -- Box commutes with swap
  | temporal_k Γ φ h ih =>
    -- Future swaps to Past
  | temporal_duality φ h ih =>
    -- Trivial: this IS the duality rule!
  | weakening Γ Δ φ h_deriv h_sub ih =>
    exact ih
```

### 6.3 Phase 3: Complete Soundness Proof (2-3 hours)

Replace the current `valid_swap_of_valid` with the derivation-indexed version:

```lean
theorem temporal_duality_sound (φ : Formula) :
  Derivable [] φ → is_valid φ.swap_past_future := by
  intro h_deriv
  -- Empty context means all assumptions are valid (vacuously)
  have h_empty : ∀ ψ ∈ [], is_valid ψ := by intro ψ h; exact absurd h (List.not_mem_nil ψ)
  -- φ is valid by soundness of other rules (already proven)
  have h_phi_valid : is_valid φ := soundness [] φ h_deriv
  -- Apply derivable_swap_valid
  exact derivable_swap_valid [] φ h_deriv h_empty h_phi_valid
```

### 6.4 Phase 4: Testing and Documentation (2-3 hours)

- Add tests for axiom swap preservation
- Add tests for rule swap preservation
- Update IMPLEMENTATION_STATUS.md
- Update KNOWN_LIMITATIONS.md (document restriction to derivable formulas)

**Total Effort**: 12-18 hours

## 7. Alternative: Hybrid Approach (D + Semantic Strengthening)

If we want to eventually prove validity swap for **all** valid formulas (not just derivable), we could:

1. **Phase 1**: Implement Approach D (derivable-only)
2. **Phase 2**: Research whether task semantics admits additional constraints that would enable semantic proof:
   - Symmetric task relations for specific frame classes
   - Unbounded domains for specific frame classes
   - Alternative semantics (e.g., branching time)

This provides a **working implementation** now while leaving room for **theoretical strengthening** later.

## 8. Conclusion

The three remaining `sorry` cases in `truth_swap_of_valid_at_triple` represent a **fundamental limitation** of the structural induction approach. The proof attempts to derive local truth at a specific triple from global validity, which is impossible for:
- **Implication**: Truth-level dependencies cannot be analyzed via validity alone
- **Past/Future**: Domain-restricted quantification prevents extracting subformula validity

**Recommended Solution**: **Approach D** (Restrict to Derivable Formulas)
- **Soundness**: Prove TD rule sound for derivable formulas only
- **Implementation**: 12-18 hours, medium complexity
- **Risk**: Low (proves exactly what's claimed)
- **JPL Alignment**: Excellent (matches paper's proof-theoretic claim)

**Key Trade-off**: We prove a **narrower** theorem (derivable implies swap-derivable and swap-valid) rather than a **broader** theorem (valid implies swap-valid for all formulas). This is mathematically honest and implementation-viable.

**Mathematical Insight**: Temporal duality is a **proof-theoretic** principle, not necessarily a **semantic** one. The soundness of the inference rule does not require proving that validity is closed under swap for arbitrary valid formulas - only for formulas that can actually be derived in TM.

## 9. References

### Code Files
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Truth.lean` (lines 491-717)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Validity.lean` (lines 45-47)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean` (lines 166-187)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Derivation.lean` (lines 107-113)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/WorldHistory.lean` (lines 262-310)

### Prior Research
- `.claude/specs/026_temporal_symmetry_derivation/reports/001-temporal-symmetry-analysis.md` (temporal symmetry foundations)
- `.claude/specs/026_temporal_symmetry_derivation/summaries/002-phase2-partial-completion-summary.md` (current status)
- `.claude/specs/lean_Logos_Metalogic_Soundness_lean/summaries/temporal_duality_soundness_proof.md` (initial attempt)

### JPL Paper References
- app:TaskSemantics, def:world-history (line 1849): Convex domains
- app:TaskSemantics, def:BL-semantics (lines 1857-1866): Truth evaluation
- §sec:Appendix (line 1030): Modal K rule
- §sec:Appendix (line 1037): Temporal K rule
- Temporal duality as inference rule (proof system, not semantics)
