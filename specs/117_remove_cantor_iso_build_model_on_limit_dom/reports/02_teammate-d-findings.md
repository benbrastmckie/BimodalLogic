# Teammate D Findings: Parametric Layer Generalization

**Task**: 117 — Remove Cantor isomorphism, build countermodel on limit domain (Round 2)
**Date**: 2026-05-08
**Focus**: Can the parametric layer work with just `[LinearOrder D]`? What's the bypass option?

## Key Findings

### 1. Exact AddCommGroup Usage Points in the Parametric Layer

**ParametricCanonical.lean** (244 lines):
- `parametric_canonical_task_rel` (line 84-88): Uses `d > 0`, `d < 0`, `d = 0` — only needs `LinearOrder D` for comparisons. Uses `0 : D` — needs `Zero D`.
- `parametric_task_rel_forward_comp` (line 114-150): Uses `add_pos`, `add_zero`, `zero_add` — needs `Add D` with `0 + x = x`, `x + 0 = x`, and `0 ≤ x, 0 ≤ y → 0 < x + y`. Does NOT need negation.
- `parametric_task_rel_converse` (line 160-182): Uses `neg_neg_of_pos`, `neg_pos_of_neg`, `neg_zero` — **NEEDS NEGATION**. The converse axiom `task_rel M d N ↔ task_rel N (-d) M` fundamentally requires `-d`.

**ParametricHistory.lean** (173 lines):
- `parametric_to_history` (line 61-82): Uses `t - s` (`sub_pos`, `sub_nonneg`, `sub_eq_zero`) — needs subtraction. This is the `respects_task` proof: duration = `t - s`.
- `ShiftClosedParametricCanonicalOmega` (line 115-118): Uses `WorldHistory.time_shift ... delta` — needs addition for shifts.
- `time_shift_parametric_to_history_compose` (line 124-136): Uses `add_assoc`, `add_comm` — needs associative commutative addition.
- `parametric_to_history_eq_time_shift_zero` (line 138-140): Uses `add_zero` — needs additive identity.

**RestrictedParametricTruthLemma.lean** (475 lines):
- Box case (lines 167-190, 365-388): Uses `t + delta` and `(t + delta) - t = delta` (`add_sub_cancel_left`). **CRITICAL**: The box forward direction shifts fam by delta, evaluates at `t + delta`, then uses `time_shift_preserves_truth` with delta `= (t + delta) - t`. This fundamentally needs `+ : D → D → D` and `- : D → D → D`.

**ParametricRepresentation.lean** (292 lines):
- Just uses the truth lemma. No direct arithmetic beyond what truth lemma needs.

### 2. Where Group Structure Is Actually Essential vs. Incidental

| Usage | Where | Essential? | Needs |
|-------|-------|------------|-------|
| `d > 0` / `d < 0` / `d = 0` | task_rel definition | Incidental | `LinearOrder D` with decidable trichotomy |
| `x + y` (composing durations) | forward_comp | **Essential** for TaskFrame axiom | `Add D`, `OrderedAdd` |
| `-d` (converse direction) | converse axiom | **Essential** for TaskFrame axiom | `Neg D` |
| `t - s` (duration between times) | respects_task | **Essential** for WorldHistory | `Sub D` |
| `t + delta` (box case shift) | truth lemma box case | **Essential** for time_shift | `Add D` |
| `(t + delta) - t = delta` | truth lemma box case | **Essential** | Group cancellation |
| `add_assoc`, `add_comm` | shift composition | **Essential** | Abelian group |
| `neg_add_cancel` | double-shift cancel | **Essential** | Group inverse |

**Conclusion**: AddCommGroup is NOT incidental — it's deeply used in:
1. The `converse` TaskFrame axiom (negation)
2. The `respects_task` WorldHistory proof (subtraction as duration)
3. The Box case of the truth lemma (addition for shifts, cancellation for inverse)
4. Time-shift composition (associativity + commutativity)

### 3. The Box Case Is the Core Obstacle

The Box case in the truth lemma (lines 167-190) is the ONLY case that uses AddCommGroup beyond simple ordering. The proof structure:

**Forward (Box φ ∈ fam.mcs t → truth at Box φ)**:
1. Take any σ ∈ ShiftClosedOmega
2. σ = time_shift(parametric_to_history fam') delta for some fam', delta
3. Box φ ∈ fam.mcs t → Box φ ∈ fam.mcs (t + delta) (by box persistence)
4. By B.modal_forward: φ ∈ fam'.mcs (t + delta)
5. By IH: truth at (parametric_to_history fam', t + delta, φ)
6. By time_shift_preserves_truth: truth at (time_shift fam' delta, t, φ) = truth at (σ, t, φ) ✓

Steps 3-6 all use `t + delta` and `(t + delta) - t = delta`. This is the crux.

**Backward (truth at Box φ → Box φ ∈ fam.mcs t)**:
1. For all fam' ∈ B.families, truth at (parametric_to_history fam', t, φ)
2. By IH: φ ∈ fam'.mcs t for all fam'
3. By B.modal_backward: Box φ ∈ fam.mcs t ✓

The backward direction doesn't need group structure at all.

### 4. The Bypass Option: Direct Truth Evaluation on BFMCS

Instead of going through TaskFrame/WorldHistory/truth_at, we could define truth evaluation directly on a BFMCS, matching Burgess 1982:

```lean
def bfmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => bfmcs_truth_at B fam t φ → bfmcs_truth_at B fam t ψ
  | Formula.box φ => ∀ fam' ∈ B.families, bfmcs_truth_at B fam' t φ
  | Formula.all_future φ => ∀ s : D, t < s → bfmcs_truth_at B fam s φ
  | Formula.all_past φ => ∀ s : D, s < t → bfmcs_truth_at B fam s φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ bfmcs_truth_at B fam s φ ∧
      ∀ r : D, t < r → r < s → bfmcs_truth_at B fam r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ bfmcs_truth_at B fam s φ ∧
      ∀ r : D, s < r → r < t → bfmcs_truth_at B fam r ψ
```

**Critical difference in Box case**: The current `truth_at` Box definition is:
```lean
| Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

This quantifies over WorldHistories (which include shifts), requiring ShiftClosed Omega. The bypass version quantifies over BFMCS families at the SAME time t, which is exactly what box-equivalence gives. **No time_shift needed**.

**The key insight**: The time_shift/ShiftClosed machinery exists to make the Box semantics work within the TaskFrame/WorldHistory framework. But Box φ in the BFMCS is defined directly as φ true in all families at the same time — no shifts needed. The shift-closure is an artifact of encoding the multi-family BFMCS semantics into the single-history WorldHistory framework.

### 5. The Bypass Truth Lemma

With `bfmcs_truth_at`, the truth lemma becomes:

```
φ ∈ fam.mcs t ↔ bfmcs_truth_at B fam t φ
```

This would only need `[LinearOrder D]` (and implicitly `[Preorder D]` for BFMCS). No AddCommGroup anywhere:

- **Atom**: Definitional
- **Bot**: Trivial
- **Imp**: Standard MCS properties
- **Box**: By B.modal_forward / B.modal_backward (already proven)
- **G/H**: By fam.forward_G / fam.backward_H + restricted temporal coherence
- **U/S**: By B.forward/backward_until_since_coherent

**None of these cases use addition, subtraction, negation, or shifts.**

### 6. Connecting the Bypass to Soundness

The completeness theorem currently says:
```lean
valid φ → Nonempty (DerivationTree [] φ)
```

Where `valid φ` quantifies over `∀ D [AddCommGroup D] ... (F : TaskFrame D) ...`.

The bypass countermodel would need to produce a model that witnesses `¬valid φ`. This requires:
1. A type `D` with `AddCommGroup D` etc.
2. A `TaskFrame D`, `TaskModel D`, `WorldHistory F`, etc.
3. Show `¬truth_at ... φ`

**Two options**:

**(A) Keep the `valid` definition as-is, produce a TaskFrame model from the bypass**:
- Construct the bypass truth lemma for `D = LimitDomSubtype` (needs only LinearOrder)
- But then need to produce a TaskFrame/WorldHistory witnessing `¬valid φ`, which requires AddCommGroup D
- This STILL requires mapping to some AddCommGroup type (e.g., Rat) at the final step
- **Net result**: You'd prove the bypass truth lemma cleanly on LimitDomSubtype, then wrap it in a trivial TaskFrame over Rat at the end for the `valid` quantifier

**(B) Weaken the `valid` definition to not require AddCommGroup**:
- Change `valid` to `∀ D [LinearOrder D] ...`
- Need a new semantics (not TaskFrame-based) for the universal quantifier
- **BREAKS SOUNDNESS**: The MF axiom `□φ → □(Fφ)` uses time_shift_preserves_truth in its soundness proof (Soundness.lean:259-265). Without time_shift, this axiom is NOT sound over arbitrary linear orders.

### 7. What MF and TF Axiom Soundness Requires

The MF axiom `□φ → □(Fφ)` is valid because:
1. Box φ true at (σ, t): for all σ' ∈ Omega, φ true at (σ', t)
2. Take any σ' ∈ Omega and any s > t
3. time_shift σ' (s - t) ∈ Omega (by ShiftClosed)
4. φ true at (time_shift σ' (s-t), t) (by step 1)
5. By time_shift_preserves_truth: φ true at (σ', s)
6. So Fφ true at (σ', t), and since σ' arbitrary, Box(Fφ) true at (σ, t) ✓

**Without time_shift**: Step 3-5 fail. The soundness of MF relies on the ability to shift histories to connect truth at different times across histories.

BUT: In the BFMCS bypass semantics, Box already quantifies over ALL families at ALL times simultaneously (via modal_forward/backward which use box-equivalence). The MF property follows from box-persistence in FMCS: `Box φ ∈ fam.mcs t → Box φ ∈ fam.mcs s` (forward_G for Box). This doesn't need time_shift.

**So MF soundness works differently in the two semantics**:
- TaskFrame semantics: MF valid by time_shift invariance (needs AddCommGroup)
- BFMCS semantics: MF valid by box persistence in FMCS (needs only LinearOrder)

### 8. Concrete Assessment: File Changes for Each Approach

**Approach A: Bypass parametric layer for completeness only** (keep soundness as-is):

| File | Change | Lines |
|------|--------|-------|
| New: `DirectTruthLemma.lean` | Define `bfmcs_truth_at`, prove direct truth lemma | ~300 |
| New: `DirectRepresentation.lean` | Bridge between bypass truth and `valid` via trivial TaskFrame | ~100 |
| `ChronicleToCountermodel.lean` | Rewrite to use direct truth lemma + trivial TaskFrame wrapper | ~200 (rewrite) |
| `CounterexampleElimination.lean` | Remove density case | ~200 (deletion) |
| `ChronicleConstruction.lean` | Remove DenselyOrdered instance, limit_dom_dense (optional) | ~50 |
| `Completeness.lean` | Minor: update dd_countermodel_chronicle call | ~5 |
| Total | | ~855 lines changed |

**Problem with Approach A**: You still need to produce a `TaskFrame D` with `AddCommGroup D` to instantiate `¬valid φ`. You'd end up wrapping the direct truth evaluation in a trivial TaskFrame over Rat anyway. This defeats the purpose.

**Approach B: Dual validity + new semantics**:

| File | Change | Lines |
|------|--------|-------|
| New: `LinearOrderSemantics.lean` | Define `lo_valid` over LinearOrder only | ~200 |
| `Validity.lean` | Add `lo_valid` definition alongside `valid` | ~40 |
| New: `LOSoundness.lean` | Prove all axioms valid under lo_valid | ~800+ |
| New: `DirectTruthLemma.lean` | As above | ~300 |
| `ChronicleToCountermodel.lean` | Rewrite for direct truth lemma | ~200 |
| `CounterexampleElimination.lean` | Remove density case | ~200 |
| `Completeness.lean` | Prove `lo_valid φ → ...` | ~30 |
| `bx_completeness` | Change statement to use lo_valid | ~5 |
| Total | | ~1775+ lines changed |

**Problem with Approach B**: Massive scope creep. Re-proving soundness for a new semantics is ~800+ lines of new work.

**Approach C: Weaken valid, keep TaskFrame but with LinearOrder only**:

| File | Change | Lines |
|------|--------|-------|
| `TaskFrame.lean` | Remove AddCommGroup, redesign with LinearOrder | ~200 (rewrite) |
| `WorldHistory.lean` | Remove time_shift, redesign domain/states | ~300 (rewrite) |
| `Truth.lean` | Remove time_shift_preserves_truth, redesign Box | ~400 (rewrite) |
| `Soundness.lean` | Reprove MF/TF without time_shift | ~200 (rewrite) |
| Everything downstream | Cascade changes | ~??? |
| Total | | 1100+ lines + unknown cascade |

**Problem with Approach C**: The TaskFrame semantics IS the AddCommGroup semantics. Removing AddCommGroup from TaskFrame means it's no longer a task frame — it's a different semantic object. This is a fundamental redesign, not a refactoring.

### 9. Recommended Minimum Viable Approach

**The cleanest path that achieves the goal with minimum disruption**:

1. Define `bfmcs_truth_at` and prove the direct truth lemma (needs only `LinearOrder D`)
2. For `dd_countermodel_chronicle`, use the direct truth lemma to show `¬bfmcs_truth_at` for the root formula
3. Then wrap in a trivial "degenerate" TaskFrame over Rat with an embedding from LimitDomSubtype to construct the `¬valid` witness

The trick for step 3: define a trivial TaskFrame over Rat where:
- WorldState = ParametricCanonicalWorldState (same as now)
- task_rel = the three-way sign split on d (same as now)
- Omega = { parametric_to_history(fam) | fam ∈ B.families } ∪ shifts

This is essentially what the current code does, but the proof that `¬truth_at ... φ` would route through `¬bfmcs_truth_at ... φ` (proven on LimitDomSubtype) and then a bridge lemma showing `bfmcs_truth_at B fam t φ ↔ truth_at (TaskFrame Rat) ... φ` for the specific families involved.

**Wait — this is circular**. To prove the bridge lemma, you need the existing truth lemma which requires AddCommGroup on D.

### 10. The Real Minimum: Keep D = Rat, Skip the Cantor Iso

After all this analysis, the minimum viable approach remains:
1. **Keep D = Rat** (satisfies AddCommGroup)
2. **Define `limit_f` extension to all of Rat** without Cantor iso (assign non-domain rationals MCS values directly)
3. **Remove the density case** from CounterexampleElimination
4. **Delete cantor_iso, DenselyOrdered instance**
5. **The sorry at CE:3570 becomes dead code**

For future variant flexibility (discrete logic with D = Int):
- The same approach works: `limit_f` extension to all of Int (or Z)
- Different chronicle constructions for different frame classes
- Each produces FMCS D / BFMCS D for the appropriate D

The direct truth lemma (`bfmcs_truth_at`) is a **nice-to-have** for clarity and future generalization, but it's NOT required to eliminate the sorry. It could be added later as a refactoring step.

## Confidence Level

**HIGH** on the analysis of where AddCommGroup is used and why it's essential for the current architecture.

**HIGH** on the bypass feasibility — `bfmcs_truth_at` can be defined and proven with only `LinearOrder D`.

**HIGH** on the assessment that bypassing the parametric layer for completeness is insufficient alone — you still need to produce a `¬valid φ` witness which requires AddCommGroup D.

**MEDIUM** on the specific bridge lemma approach — connecting bypass truth to TaskFrame truth needs careful design.

**Key insight**: The AddCommGroup requirement is NOT just a convenience — it's structurally essential for the time_shift/ShiftClosed/Box interaction in the TaskFrame semantics. Removing it requires either (a) a fundamentally different semantics, or (b) keeping TaskFrame for soundness while using a bypass for completeness with a bridge lemma.
