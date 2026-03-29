# Task 67: Teammate B Findings — Task Relation Encoding and Alternative Approaches

**Session**: sess_1774755166_b8a317
**Date**: 2026-03-28
**Focus**: Task relation symbolic encoding and canonical frame construction

---

## Key Findings

### 1. The Task Relation IS g_content Containment

The symbolic encoding of the task relation is defined in `ParametricCanonical.lean`:

```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val   -- g_content M ⊆ N
  else if d < 0 then ExistsTask N.val M.val
  else M = N  -- d = 0
```

Where `ExistsTask M N = (g_content M ⊆ N)` = "all G-formulas of M hold in N".

The task relation is **entirely symbolic** — it is determined by which G-formulas are in each MCS world-state, not by any separate geometric structure.

### 2. FMCS Already Satisfies the Task Relation by Construction

A critical observation: the `FMCS.forward_G` condition says exactly:
```
∀ t t' phi, t ≤ t' → G(phi) ∈ mcs t → phi ∈ mcs t'
```

This is precisely `g_content(mcs t) ⊆ mcs t'` for all `t ≤ t'`, which means:
```
ExistsTask(mcs t, mcs t')  for all t ≤ t'
```

So **every FMCS family is already a chain of ExistsTask-connected worlds by construction**. The task relation within a family is automatically satisfied for forward (positive duration) steps.

### 3. The parametric_to_history respects_task Proof Confirms This

In `ParametricHistory.lean:66-89`, the proof of `respects_task` for a single family shows:
- For `t - s > 0`: `ExistsTask(mcs s, mcs t)` follows directly from `fam.forward_G`
- For `t - s = 0`: `mcs s = mcs t` (reflexivity)
- `t - s < 0` is impossible since `s ≤ t`

This is exactly the FMCS structure: **the history `parametric_to_history(fam)` uses g_content containment to build the task relation, and it works because FMCS.forward_G provides it for free**.

### 4. The Critical Architectural Problem: Backward G Uses Truth Along a Specific History

In `ParametricTruthLemma.lean:320-331`, the backward G case:
```lean
-- Backward: ∀ s ≥ t, truth tau s psi → G psi in MCS
intro h_all
-- h_all : ∀ s : D, t ≤ s → truth_at ... (parametric_to_history fam) s psi
-- Need forward_F: F(neg psi) ∈ fam.mcs t → ∃ s > t, neg psi ∈ fam.mcs s
```

The semantic hypothesis `h_all` is typed as: truth along `parametric_to_history(fam)` at all `s ≥ t`. When we need the contrapositive to get `F(neg psi) ∈ fam.mcs t`, we need a witness `s > t` with `neg psi ∈ fam.mcs s` — **in the same family fam**. A witness in a different family `fam'` would not give us `neg psi ∈ fam.mcs s`, only `neg psi ∈ fam'.mcs s`, which doesn't help.

### 5. The Symbolic Key: G semantics can be expressed in terms of ExistsTask

Because the task relation IS g_content containment, the G-semantics statement `G phi ∈ fam.mcs t` is equivalent to:
```
∀ N : ParametricCanonicalWorldState, ExistsTask(fam.mcs t, N) → phi ∈ N.val
```

This is the **symbolic representation**: G phi means "phi holds in every world forward-reachable via the task relation from the current world". The task relation forward-reachability from `fam.mcs t` includes ALL worlds N where `g_content(fam.mcs t) ⊆ N.val`.

The **key algebraic insight**: By the FMCS structure, `g_content(fam.mcs t) ⊆ fam.mcs s` for all `s ≥ t`. So G phi at time t in a family means phi holds at ALL future times in the SAME family — not just in some bundle. **The single family IS the canonical chain for G semantics**.

---

## Alternative Approaches Evaluated

### Approach A: Alternative Task Relation Encoding (REJECTED)

**Idea**: Encode the task relation symbolically as "ExistsTask holds at ANY time point in ANY family with box_class_agree", making the forward_F witnesses from other families valid.

**Why it fails**: The semantic truth evaluation `truth_at` is defined along a fixed history `tau`. The G-semantics `∀ s, domain(s) → respects_task(s, t) → truth_at psi at s` is quantification over time-points OF THE SAME HISTORY. The issue is not the task relation definition, but the semantic evaluation structure — changing the task relation encoding cannot make witnesses from other families count for truth along a given history.

### Approach B: Forward-Only Truth Lemma (REJECTED — confirmed impossible)

**Idea**: Prove only `phi ∈ MCS → truth_at phi`, avoiding the backward direction that needs h_tc.

**Why it fails**: The forward `imp` case requires the backward IH for the antecedent. Since `neg(phi) = phi.imp bot`, proving `neg(phi) ∈ MCS → truth_at neg(phi)` needs `truth_at phi → phi ∈ MCS` (backward). If phi contains G/H, this needs forward_F. There is no escape.

This is thoroughly documented in `ParametricTruthLemma.lean` lines 13-69 and confirmed by both the SuccChainTruth.lean singleton-Omega sorry and the parametric truth lemma structure.

### Approach C: Single-Family Omega with SuccChain (NOVEL INSIGHT)

**Idea**: Use a **single-family Omega** `{parametric_to_history fam}` instead of the bundle Omega. Since Omega is a singleton:
- Box phi = phi (via T-axiom for forward direction)
- The backward box case requires: `phi true at the singleton history → Box phi ∈ MCS`

**The box backward problem**: This still fails for singleton Omega (same issue as SuccChainTruth.lean — see code comment lines 260-277). `phi true at unique history → Box phi ∈ MCS` doesn't hold without modal saturation.

**Verdict**: The BFMCS bundle is needed for box semantics. Single-family Omega is insufficient.

### Approach D: Direct Semantic Proof via ExistsTask Structure (NOVEL FINDING)

**Idea**: Instead of going through the truth lemma, use the symbolic task relation directly.

**Observation**: The completeness argument needs:
1. `neg(phi) ∈ M0` (from non-provability)
2. `phi` is false in the semantic model

If we build a semantic model where **the task relation is the ExistsTask relation on MCSes** (as in `ParametricCanonicalTaskFrame`), then:
- The world states ARE MCSes
- The task relation is g_content containment
- `G phi true at M0 at time 0` means `phi ∈ N.val` for all N with `ExistsTask(M0, N)`
- But `ExistsTask(M0, N)` = `g_content(M0) ⊆ N`, which is not all of M0 itself

**The issue**: The canonical semantic model is `ParametricCanonicalTaskFrame` where worlds are MCSes and the task relation is ExistsTask. But completeness requires showing `phi false` in a model over a **specific temporal domain D = Int**, not over the abstract MCS-world frame. The `valid_over Int phi` hypothesis must be applied to a specific `TaskFrame Int`.

**Key constraint**: `valid_over Int phi` means phi is true in ALL `TaskModel` instances over `TaskFrame Int` instances — with **Int as the duration type**. The parametric canonical frame uses MCSes as world states and ExistsTask as the task relation, but the **duration type D must be Int** for this to apply.

The `parametric_to_history(fam)` construction bridges this: it maps an FMCS (indexed by Int) to a `WorldHistory ParametricCanonicalTaskFrame Int` where the history visits MCS-worlds along the ExistsTask relation.

### Approach E: Restricted Truth Lemma (RECOMMENDED — confirmed correct path)

**The restricted coherence insight from user hint**: The task relation encoding `ExistsTask = g_content containment` means that the backward G proof needs forward_F witnesses **in the same family**. But for a specific target formula `phi`, the F-obligations that arise during the truth lemma proof are formulas in the **subformula closure** of `phi`. The F-nesting is BOUNDED by the complexity of `phi`.

For a fixed target formula `phi`:
- The truth lemma for `neg(phi)` needs forward_F only for formulas in `subformula_closure(neg(phi))`
- These all have F-nesting ≤ max F-depth in `phi`
- SuccChainFMCS satisfies `restricted_forward_chain_forward_F` for these bounded-depth formulas (SORRY-FREE at SuccChainFMCS.lean:2921)

The **symbolic key the user hints at**: The task relation encoding via `g_content` means that:
- `G phi ∈ fam.mcs t` ↔ `phi holds at every ExistsTask-forward world`
- For the completeness contradiction, we only need this for formulas in the **closure** of the target
- The restricted forward_F is provable for closure-bounded formulas

---

## Recommended Path Forward

The restricted coherence path (Plan 02) remains the correct approach. The **symbolic task relation** insight provides clarity on WHY same-family witnesses are required:

1. The task relation is `ExistsTask = g_content containment`
2. A family `fam` maps Int → MCS, where `mcs(t) →(ExistsTask)→ mcs(s)` for `t ≤ s` by FMCS.forward_G
3. The semantic truth along `parametric_to_history(fam)` quantifies over these SAME-FAMILY worlds
4. Backward G needs a forward_F witness in the same family to match the semantic history
5. For bounded F-depth formulas (from the target closure), `restricted_forward_chain_forward_F` provides this

**No simpler alternative path was found.** The symbolic encoding does not enable bypassing the same-family requirement; it explains and confirms why same-family witnesses are necessary.

### Concrete Next Steps (Priority Order)

1. **Fill termination sorries** (4 `decreasing_by sorry`) in `SuccChainFMCS.lean`:
   - Functions: `restricted_bounded_witness`, `restricted_backward_bounded_witness`, etc.
   - Use lexicographic measure `(closure_F_bound phi - current_F_depth, chain_position)`
   - These have sorry-free bodies; only the `decreasing_by` clause is missing

2. **Fill G/H propagation sorries** in `RestrictedTruthLemma.lean:106` and `:135`:
   - `restricted_chain_G_propagates`: Use DRM (Deferral-Restricted MCS) forward_G property
   - `restricted_chain_H_step`: Use Succ h_content for backward direction

3. **Define `RestrictedTemporallyCoherentBFMCS`**: A version of BFMCS that takes `RestrictedTemporalCoherence` over `deferralClosure(phi)` instead of full `B.temporally_coherent`

4. **Adapt `parametric_canonical_truth_lemma`** to accept restricted coherence for target formula

5. **Wire to `bundle_validity_implies_provability`** using restricted truth lemma

---

## Confidence Level

**High** on the architectural analysis. The symbolic task relation encoding via `g_content` containment is definitively established, and the reason same-family witnesses are mandatory is understood.

**Medium** on the termination proofs. The lexicographic measure approach is standard but requires careful formalization of the DRM bound as a well-founded metric on formula complexity.

**High** that the restricted coherence path (Plan 02) is the only viable approach. All alternative paths were evaluated and rejected for substantive reasons.

---

## Code References

| Component | File:Line | Status |
|-----------|-----------|--------|
| `parametric_canonical_task_rel` definition | `ParametricCanonical.lean:84` | Sorry-free |
| `ExistsTask` definition | `CanonicalFrame.lean:66` | Sorry-free |
| `FMCS.forward_G` | `FMCSDef.lean:111` | Sorry-free (structure field) |
| `parametric_to_history.respects_task` | `ParametricHistory.lean:65-89` | Sorry-free |
| `parametric_canonical_truth_lemma` | `ParametricTruthLemma.lean:207` | Has sorry via h_tc |
| `BFMCS.temporally_coherent` | `TemporalCoherence.lean:216` | Definition only |
| `boxClassFamilies_temporally_coherent` | `UltrafilterChain.lean:1816` | HAS SORRY |
| `restricted_forward_chain_forward_F` | `SuccChainFMCS.lean:2921` | SORRY-FREE (body) |
| `restricted_backward_chain_backward_P` | `SuccChainFMCS.lean:4262` | SORRY-FREE (body) |
| `construct_bfmcs_bundle` | `UltrafilterChain.lean:2853` | Sorry-free |
| `bundle_validity_implies_provability` | `FrameConditions/Completeness.lean:176` | HAS SORRY |
