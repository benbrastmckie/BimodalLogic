# Teammate B (Round 2) Findings: Re-rooting Operation Design

**Task**: 117 — Remove Cantor isomorphism, generalize parametric infrastructure
**Date**: 2026-05-08
**Focus**: Design a replacement for `time_shift` that only needs `[LinearOrder D]`

## Key Findings

### 1. What `time_shift` Achieves Semantically

`time_shift σ Δ` (WorldHistory.lean:238-260) translates a history's domain by `-Δ`:
- `domain z := σ.domain (z + Δ)` — shift domain
- `states z := σ.states (z + Δ)` — shift states
- `respects_task` — uses `(t + Δ) - (s + Δ) = t - s` (AddCommGroup cancellation)

The time_shift serves TWO distinct roles:
1. **Soundness of MF/TF axioms** (modal-temporal interaction): `□φ → □(Gφ)` and `□φ → G(□φ)`. These require that for any history σ ∈ Ω and any time offset, the shifted history is also in Ω (ShiftClosed).
2. **Completeness truth lemma (Box case)**: The box case at RestrictedParametricTruthLemma.lean:167-190 maps between FMCS families at time `t` and time `t + delta`, using `time_shift_preserves_truth` to transport truth along the shift.

### 2. Precise Group Operations Used

All `AddCommGroup` usage in the semantic pipeline traces to these operations:

**In WorldHistory.lean:**
- `z + Δ` — domain/state translation (time_shift, line 239/248)
- `(t + Δ) - (s + Δ) = t - s` — duration invariance (respects_task, line 258)
- `z + (-Δ) + Δ = z` — shift inverse (lines 278-279)
- `neg_add_cancel`, `add_zero` — cancellation laws

**In TaskFrame.lean:**
- `task_rel w 0 u` — zero element (nullity_identity, line 104)
- `task_rel w (x + y) v` — addition (forward_comp, line 114)
- `task_rel u (-d) w` — negation (converse, line 122)
- `t - s` — duration extraction (WorldHistory.respects_task, line 97)

**In Truth.lean (Soundness of MF/TF):**
- `time_shift σ (s - t)` — shift by duration (line 264, 272)
- `time_shift_preserves_truth` requires ShiftClosed (line 369-372)

**In ParametricHistory.lean:**
- `t + delta` — offset for box case (line 172)
- `(t + delta) - t = delta` — cancellation (line 181)
- `delta + Δ'` — composition of shifts (line 147-149)

### 3. Can "Re-rooting" Replace "Time-shifting"?

**Short answer: Not directly, because `time_shift` operates on ALL of D, while re-rooting only navigates within the existing domain.**

The key asymmetry:
- `time_shift σ Δ` produces a history whose domain is `{z | z + Δ ∈ σ.domain}` — a TRANSLATED copy of σ's domain. If σ has domain [0, 10] and Δ = 5, the shifted domain is [-5, 5].
- "Re-rooting" at a domain point t₀ would keep the same domain but change the reference point. This is fundamentally different — it doesn't produce new histories at new time points.

**However**, in the completeness proof, `time_shift` is used in a constrained way:
- `parametric_to_history` creates histories with `domain = True` (full domain, line 62)
- Shifting a full-domain history gives another full-domain history
- The truth lemma's box case (line 167-184) uses `time_shift_preserves_truth` to map truth at time `t` on `parametric_to_history fam'` to truth at time `t + delta` on the same family

So for the completeness proof specifically, `time_shift` is used to relate `fam'.mcs t` to `fam'.mcs (t + delta)` — which is just evaluating the FMCS at a different time. No domain translation is needed because FMCS has full domain.

### 4. How the Truth Lemma's Box Case Actually Works

From RestrictedParametricTruthLemma.lean:167-190:

```
| box ψ ih =>
  -- Forward: box ψ ∈ fam.mcs t → ∀ σ ∈ ShiftClosedΩ, truth at (σ, t)
  · intro h_box σ h_σ_mem
    obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
    -- h_σ_eq : σ = time_shift (parametric_to_history fam') delta
    -- Need: truth at (σ, t) = truth at (time_shift (p2h fam') delta, t)
    -- By time_shift_preserves_truth: ↔ truth at (p2h fam', t + delta)
    -- By IH: ↔ ψ ∈ fam'.mcs (t + delta)
    -- box ψ ∈ fam.mcs t → box ψ ∈ fam.mcs (t + delta) by box_persistent
    -- box ψ ∈ fam.mcs (t + delta) → ψ ∈ fam'.mcs (t + delta) by modal_forward
```

The critical chain is:
1. σ is `time_shift (p2h fam') delta` for some family fam' and offset delta
2. `time_shift_preserves_truth` converts truth at (shifted σ, t) to truth at (p2h fam', t + delta)
3. IH converts truth at (p2h fam', t + delta) to `ψ ∈ fam'.mcs (t + delta)`
4. `box_persistent` + `modal_forward` gives `ψ ∈ fam'.mcs (t + delta)` from `box ψ ∈ fam.mcs t`

**What's ACTUALLY needed**: A way to say "σ evaluates formula ψ the same way as fam'.mcs at some time point." The `time_shift` + `time_shift_preserves_truth` machinery achieves this, but it's overkill — all we really need is that `truth_at M Ω (p2h fam') (t + delta) ψ ↔ ψ ∈ fam'.mcs (t + delta)`.

### 5. The WorldHistory.respects_task Issue

The `respects_task` field (WorldHistory.lean:96-97) uses `t - s`:
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

Without subtraction, this cannot be expressed. The task relation `task_rel : WorldState → D → WorldState → Prop` takes a DURATION as its middle argument. Durations require subtraction to extract from time pairs.

**Options:**
1. **Binary task relation** (no duration): `task_rel : WorldState → WorldState → Prop` and `temporal_rel : D → D → Prop` (separate temporal ordering from task relation). This loses the connection between tasks and time.

2. **Keep durations as a separate type**: `Duration` could be `D` itself when `AddCommGroup` is available, or `{(s,t) : D × D | s ≤ t}` (ordered pair) when only `LinearOrder`. The respects_task would become: `∀ s t, s ≤ t → task_rel (states s) ⟨s,t⟩ (states t)` — but this changes the entire TaskFrame API.

3. **Existential duration**: `∀ s t, s ≤ t → ∃ d, task_rel (states s) d (states t)` — loses compositionality.

4. **Drop respects_task entirely for the completeness proof**: The parametric construction builds `parametric_to_history` with `domain = True` and a custom `task_rel` that's defined in terms of the FMCS data. The `respects_task` proof uses `forward_G` from FMCS. If we bypass the TaskFrame layer entirely for the completeness proof, we could define a simpler "ValuationHistory" that just maps time points to world states without the task constraint.

### 6. Concrete Proposal: Two-Layer Architecture

**Keep the existing semantics unchanged for soundness** (TaskFrame, WorldHistory, time_shift, ShiftClosed — all with AddCommGroup). Instead, introduce a PARALLEL simpler layer for completeness:

#### Layer 1: Simple Frame (for completeness)

```lean
structure SimpleFrame (D : Type*) [LinearOrder D] where
  WorldState : Type
  
structure SimpleHistory {D : Type*} [LinearOrder D] (F : SimpleFrame D) where
  states : D → F.WorldState

structure SimpleModel {D : Type*} [LinearOrder D] (F : SimpleFrame D) where
  valuation : F.WorldState → Atom → Prop
  
def simple_truth_at [LinearOrder D] (M : SimpleModel F) 
    (Omega : Set (SimpleHistory F)) (τ : SimpleHistory F) (t : D) : Formula → Prop
  | Formula.atom p => M.valuation (τ.states t) p
  | Formula.bot => False
  | Formula.imp φ ψ => simple_truth_at M Omega τ t φ → simple_truth_at M Omega τ t ψ
  | Formula.box φ => ∀ σ ∈ Omega, simple_truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ s, s < t → simple_truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ s, t < s → simple_truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s, t < s ∧ simple_truth_at M Omega τ s φ ∧
      ∀ r, t < r → r < s → simple_truth_at M Omega τ r ψ
  | Formula.snce φ ψ => ∃ s, s < t ∧ simple_truth_at M Omega τ s φ ∧
      ∀ r, s < r → r < t → simple_truth_at M Omega τ r ψ
```

Note: `SimpleHistory` has `states : D → F.WorldState` with no domain predicate (total), no convexity, no respects_task. The truth evaluation has no domain check for atoms (total function = always defined).

#### Bridge Theorem

```lean
theorem simple_validity_implies_validity (φ : Formula)
    (h : ∀ (D : Type) [LinearOrder D] [Nontrivial D]
           (F : SimpleFrame D) (M : SimpleModel F) 
           (Ω : Set (SimpleHistory F)) (τ : SimpleHistory F) (_ : τ ∈ Ω) (t : D),
           simple_truth_at M Ω τ t φ) :
    valid φ
```

**This bridge would show**: any formula valid over SimpleFrames (LinearOrder only) is also valid over TaskFrames (AddCommGroup). The proof would embed each TaskFrame+WorldHistory+TaskModel into a SimpleFrame+SimpleHistory+SimpleModel by forgetting the task structure.

**Completeness would then target SimpleFrame validity**, not TaskFrame validity. Since valid implies simple_valid (by the bridge), and simple_valid is sufficient for completeness, this works.

### 7. Why ShiftClosed Is Not Needed for the Simple Layer

In the simple layer, the Box semantics is `∀ σ ∈ Ω, simple_truth_at M Ω σ t φ`. There is no time_shift, so no ShiftClosed. Instead, the BFMCS construction directly ensures Ω contains all the right histories.

For soundness of MF (`□φ → □Gφ`):
- In the TaskFrame layer: uses time_shift to show that shifted histories are in Ω
- In the SimpleFrame layer: the proof would be different. `□φ` at time t means φ holds at all σ ∈ Ω at time t. `□Gφ` means for all σ ∈ Ω, for all s > t, φ at (σ, s). We need: from "φ at all σ at time t" to "φ at all σ at time s > t". This does NOT follow from SimpleFrame axioms alone — it requires that Ω be "temporally coherent" (if σ ∈ Ω then σ-shifted-to-time-s is also in Ω).

**This means**: The soundness of MF/TF axioms does REQUIRE some form of closure on Ω. Without AddCommGroup, the closure condition would need to be expressed differently:
- Option A: `∀ σ ∈ Ω, ∀ t, ∃ σ' ∈ Ω, ∀ s, truth(σ, s) = truth(σ', s + (t - ?))`  — still needs subtraction
- Option B: `∀ σ ∈ Ω, ∀ t₁ t₂, ∃ σ' ∈ Ω, σ'.states t₁ = σ.states t₂` — existential temporal matching
- Option C: Require Ω to be "evaluation-closed": for all σ ∈ Ω and all t₁ t₂, there exists σ' ∈ Ω such that `∀ φ, truth(σ, t₂, φ) ↔ truth(σ', t₁, φ)` — this is what time_shift_preserves_truth gives

**Option C is the cleanest**: define `EvalClosed Ω` as "for all σ ∈ Ω and t₁ t₂ : D, there exists σ' ∈ Ω such that for all φ, truth at (σ, t₂) = truth at (σ', t₁)." This is what ShiftClosed + time_shift_preserves_truth gives, but stated without group operations.

### 8. Risk Assessment: Does This Weaken the Logic?

**The logic (axioms, rules, formulas) does NOT change.** Only the semantic infrastructure changes. The question is whether validity over SimpleFrames is the SAME class of valid formulas as validity over TaskFrames.

**Claim**: `valid_task φ ↔ valid_simple φ` (same formulas are valid).

**Forward direction** (valid_task → valid_simple): Every SimpleFrame can be embedded into a TaskFrame by choosing an arbitrary AddCommGroup D' ≅ D (e.g., take D = LimitDomSubtype, embed it order-preservingly into Rat, then use Rat's AddCommGroup). So if φ is valid in all TaskFrames, it's valid in all SimpleFrames.

Wait — this direction is actually non-trivial. A SimpleFrame with D = some non-group linear order might not embed into any TaskFrame. But the validity quantifies over ALL D, so if φ fails in some SimpleFrame(D₀), does it also fail in some TaskFrame(D₁)?

**Actually, this is the key question**: Are there formulas valid over all AddCommGroup-equipped linear orders but invalid over some non-group linear order? In temporal logic, the answer is NO for the base operators (G, H, U, S, Box) because they only use the order structure, not the group structure. The task relation is irrelevant to the truth of temporal formulas — it only constrains which WorldHistories are "legitimate," but validity quantifies over ALL frames including frames where task_rel is trivially True.

**Conclusion**: The set of valid formulas is the same. The proof: for any non-group linear order D₀ and any SimpleFrame over D₀, construct a TaskFrame over Rat (or any AddCommGroup) that simulates the same truth values by embedding D₀ order-preservingly into Rat.

## Recommended Approach

### Option A: Two-Layer Architecture (Recommended)

1. Define `SimpleFrame`, `SimpleHistory`, `SimpleModel`, `simple_truth_at` with only `[LinearOrder D]`
2. Prove bridge: `simple_valid → valid` (embedding SimpleFrame into TaskFrame)  
3. Build completeness targeting `simple_valid` (using LimitDomSubtype directly)
4. Keep existing TaskFrame/WorldHistory/Soundness unchanged
5. Derive `¬derivable φ → ¬valid φ` via the bridge

**Pros**: No changes to soundness, no risk of breaking existing proofs, clean separation
**Cons**: Need to prove the bridge theorem, duplicated truth definition

### Option B: Generalize TaskFrame (Higher risk)

1. Replace `AddCommGroup D` with `LinearOrder D` everywhere
2. Replace `time_shift` with `EvalClosed`
3. Re-prove soundness of MF/TF with the new EvalClosed condition
4. Simplify WorldHistory (drop respects_task, convexity)

**Pros**: Conceptually cleaner, no duplication
**Cons**: Touches ~28 files, breaks existing soundness proofs, MF/TF soundness proof becomes harder

### Option C: Hybrid — Generalize Only the Completeness Path

1. Keep TaskFrame/soundness with AddCommGroup
2. For completeness, bypass the parametric layer: build a TaskFrame Rat directly using limit_f extension
3. This is the "keep D=Rat" approach from Round 1

**Pros**: Minimal changes
**Cons**: Locks out non-dense domains (LimitDomSubtype), doesn't solve the variant flexibility goal

## Confidence Level

**High** on the analysis of what AddCommGroup is used for and why.

**Medium** on the two-layer architecture — the bridge theorem (simple_valid → valid) needs careful construction to avoid subtle universe issues.

**Key uncertainty**: Whether `simple_valid φ ↔ valid φ` actually holds. The forward direction (valid → simple_valid) is clear. The backward direction (simple_valid → valid) requires showing that every TaskFrame validity violation can be witnessed in a SimpleFrame. This is plausible but not trivial.
