# Research Report: Task #1003 (Team Research)

**Task**: 1003 - Implement Sorry-Free Multi-Family Modal Coherence
**Date**: 2026-03-19
**Mode**: Team Research (2 teammates + synthesis)
**Session**: sess_1773960371_e0d0e2
**Focus**: Deep mathematical analysis of the BFMCS modal coherence blocker

---

## Summary

This team research resolves the architectural deadlock blocking task 1003. The core finding
is that the problem is more fundamental than originally diagnosed: achieving modal saturation
in BFMCS requires families with genuinely different `mcs` functions, but the temporal
coherence constraints (forward_G, backward_H) and the absence of temporal T-axioms in the
proof system together make this impossible with any shared common domain D. The only
mathematically sound path is **BFMCS defined directly over a Flag-indexed structure
(FlagBFMCS)**, abandoning the fixed-domain BFMCS framework for modal completeness.

---

## Key Findings

### Finding 1: Why Singleton BFMCS Fails (Structural Root Cause)

The singleton BFMCS conflates **modal accessibility with identity**. In standard modal
logic (Hughes & Cresswell, Chellas), the canonical model has:

- **Worlds** = all maximal consistent sets (MCSes)
- **Accessibility** R(M, M') := BoxContent(M) ⊆ M'
- **Valuation** = world membership

The accessibility relation is **non-trivial**: M' can contain φ without M containing φ.
This is why `Diamond(φ) ∈ M` does NOT imply `φ ∈ M`.

In the singleton BFMCS with `mcs(t) = t.world`, accessibility is effectively set to
**identity** at each time t. The modal saturation condition reduces to:

```
Diamond(ψ) ∈ t.world → ψ ∈ t.world     [MATHEMATICALLY FALSE]
```

The counterexample `{Diamond(p), ¬p}` is consistent (by Lindenbaum) and extends to an MCS
containing `Diamond(p)` but not `p`. This is definitive and requires no further analysis.

---

### Finding 2: Temporal T-Axioms Are NOT in the Proof System (Critical New Finding)

Investigation of `Theories/Bimodal/ProofSystem/Axioms.lean` reveals:

> **Task 991 Note**: Under strict temporal semantics (G/H quantify over s > t / s < t),
> the T-axioms (Gφ → φ, Hφ → φ) are NOT valid and NOT included.

The FMCS definition uses **strictly irreflexive** coherence:
```lean
forward_G : ∀ t t' φ, t < t' → G φ ∈ mcs t → φ ∈ mcs t'
backward_H : ∀ t t' φ, t' < t → H φ ∈ mcs t → φ ∈ mcs t'
```

**Consequence**: **Constant families** (where `mcs_W(t) = W.world` for all t) CANNOT
satisfy `forward_G`. The condition becomes:

```
G(φ) ∈ W.world → φ ∈ W.world
```

which is exactly the G-T axiom `G(φ) → φ`, which is NOT a theorem. This eliminates the
most natural "witness injection" approach and is a critical finding not present in prior
research reports.

---

### Finding 3: All Same-Domain Multi-Family Approaches Fail

The existing `MultiFamilyBFMCS.lean` (lines 326-327) reveals the fundamental problem:

```lean
noncomputable def flagFMCS_over_CanonicalMCS (flag : Flag CanonicalMCS) : FMCS CanonicalMCS :=
  canonicalMCSBFMCS
```

When "embedding" a flag's `chainFMCS` into a common `CanonicalMCS` domain, the only
natural definition returns the **identity family**. This happens because:

- `chainFMCS(flag).mcs(x) = x.val.world`
- For any element t : CanonicalMCS, the "corresponding" chain element has the same world
- So the embedded FMCS still maps t → t.world

**Every same-domain approach with CanonicalMCS leads to identical families.**

If all families in the BFMCS have the same `mcs` function, then:
- Modal saturation: `Diamond(ψ) ∈ t.world → ∃ fam', ψ ∈ fam'.mcs(t) = t.world`
  → `Diamond(ψ) ∈ t.world → ψ ∈ t.world` [SAME FALSE CONDITION]

**No choice of "extra families" over CanonicalMCS with identity-like mcs can achieve
modal saturation.**

---

### Finding 4: The Domain Type Is the Structural Blocker

The BFMCS design requires `BFMCS D` for a fixed type D, where all families share domain
D. This constraint, combined with Finding 2 and 3, creates an inescapable deadlock:

| Approach | Common Domain | Non-identity mcs | Temporal Coherence | Result |
|----------|---------------|------------------|--------------------|--------|
| Singleton | CanonicalMCS | No | ✓ | Modal saturation fails |
| Same-domain multi-family | CanonicalMCS | No | ✓ | Same as singleton |
| Constant witness family | CanonicalMCS | Yes | ✗ | Needs G-T axiom |
| Flag-per-family | Different per flag | Yes | ✓ | Type mismatch with BFMCS |

The only approach that simultaneously achieves all three requirements (non-identity mcs,
temporal coherence, modal saturation) is **flag-per-family**, which inherently requires
different domain types per family — but BFMCS requires a single shared domain.

**This is not an implementation difficulty; it is a structural impossibility.**

---

### Finding 5: The Correct Semantic Architecture

The mathematical reason the current approach fails is a **semantic mismatch** between:

1. **Bimodal semantics** (intended): A bimodal world is a (temporal timeline, time-position)
   pair. Box quantifies over alternative timelines at the same temporal position. Diamond
   witnesses exist in alternative timelines, not at the same world.

2. **Current BFMCS encoding**: Families are FMCS instances over a fixed domain D. Modal
   accessibility at time t is across ALL families at the SAME t value in D.

The intended semantics is:
- A **Flag** = a maximal temporal timeline (a complete temporal scenario)
- A **bimodal world** = an element of a Flag (MCS at a specific temporal position)
- **Box**: at (F, x), Box(φ) holds iff φ holds at ALL (F', x') accessible from (F, x)
- **Accessibility**: (F, x) R (F', x') iff x and x' represent "the same temporal position"
  across different timelines AND BoxContent(x.world) ⊆ x'.world

This is a **Kripke bundle** structure where each Flag is a "copy" of the temporal axis,
and modal accessibility connects corresponding time positions across copies.

The `chainFMCS(flag)` infrastructure already provides temporal coherence WITHIN each
Flag. The missing piece is connecting Flags through modal accessibility.

---

## Competing Approaches Evaluated

### Approach A: Witness Family Construction (Teammate A, PATH 1)
**Idea**: For each Diamond obligation (t₀, φ), create a family where `mcs` places the
witness at t₀.

**Fatal Flaw**: temporal coherence at t₀ boundary requires G-T/H-T axioms. Without them,
the witness family has a temporal discontinuity at t₀ that cannot be justified syntactically.

**Verdict**: NOT VIABLE without adding temporal T-axioms to the logic.

---

### Approach B: Heterogeneous BFMCS (Teammate B, APPROACH D)
**Idea**: Define a new `HeterogeneousBFMCS` structure where families can have different
domain types.

```lean
structure HeterogeneousBFMCS where
  flags : Set (Flag CanonicalMCS)
  flags_nonempty : flags.Nonempty
  modal_coherent : ∀ f₁ f₂ ∈ flags, ∀ M ∈ f₁, ∀ φ,
    Box(φ) ∈ M.world → ∀ M' ∈ f₂, Box(φ) ∈ M'.world
```

**Strengths**:
- Directly captures the intended bimodal semantics
- `closedFlags` immediately provides the flags set
- Modal saturation follows from `closedFlags_closed_under_witnesses`
- No temporal T-axiom needed (coherence is per-Flag via chainFMCS)

**Challenge**: Requires refactoring the truth lemma from `BFMCS D` to `FlagBFMCS`-based
semantics. This is non-trivial but mathematically well-motivated.

**Verdict**: VIABLE — the correct architectural direction.

---

### Approach C: Sigma-Type Domain
**Idea**: Use `D = Σ (flag : Flag CanonicalMCS), ChainFMCSDomain flag` as the common
domain, allowing one family per flag with temporal coherence within-flag.

**Analysis**:
- Temporal coherence: For (F, x) < (F, x') (same flag, strict), chainFMCS provides it ✓
- Cross-flag elements are incomparable, so forward_G is vacuous across flags ✓
- Modal saturation: With ONE family where mcs(F, x) = x.val.world:
  - Diamond(ψ) ∈ x.val.world → need ψ ∈ fam'.mcs(F, x) at SAME sigma element
  - Cannot find another family with different value at (F, x) unless families differ ✗

**Verdict**: VIABLE as domain type if combined with MULTIPLE distinct families. However,
defining families with genuinely different mcs values over the sigma domain leads back to
the same constant-family problem (needs G-T axioms for temporal coherence of non-identity
families). The sigma domain alone does not solve the problem.

---

## Synthesis and Recommendation

### The Fundamental Insight

The blocker is not about finding the right `mcs` function — it is about the **wrong level
of abstraction**. The current `BFMCS D` framework was designed for temporal completeness
(where the domain D is a timeline). Extending it to modal completeness requires a
fundamentally different structure.

The mathematically correct construction is:

> **FlagBFMCS**: A bundle of Flags (temporal timelines) with modal accessibility defined
> via BoxContent propagation across Flags at corresponding temporal positions.

This is the structure that naturally supports:
1. **Temporal coherence**: Each Flag provides a chainFMCS (sorry-free)
2. **Modal saturation**: The closedFlags construction ensures Diamond witnesses exist as
   elements of other Flags in the bundle
3. **Truth lemma**: Evaluated at a (Flag, element) pair, using chainFMCS for temporal
   operators and FlagBFMCS-level modal saturation for Box/Diamond

### Recommended Implementation Path

**Phase 1**: Define `FlagBFMCS` structure

```lean
/-- A bundle of maximal chains (Flags) with modal coherence conditions. -/
structure FlagBFMCS where
  root : CanonicalMCS
  flags : Set (Flag CanonicalMCS)
  flags_nonempty : flags.Nonempty
  /-- Box content propagates uniformly across all flags. -/
  modal_coherent : ∀ f ∈ flags, ∀ M ∈ f.asSet, ∀ φ,
    Formula.box φ ∈ M.world →
    ∀ f' ∈ flags, ∀ M' ∈ f'.asSet,
    BoxContent M.world ⊆ BoxContent M'.world →
    Formula.box φ ∈ M'.world
  /-- Diamond witnesses are within the flag set. -/
  modally_saturated : ∀ f ∈ flags, ∀ M ∈ f.asSet, ∀ ψ,
    ψ.diamond ∈ M.world →
    ∃ f' ∈ flags, ∃ M' ∈ f'.asSet, ψ ∈ M'.world
  /-- Evaluation flag for completeness. -/
  eval_flag : Flag CanonicalMCS
  eval_flag_mem : eval_flag ∈ flags
  eval_element : ChainFMCSDomain eval_flag
```

**Phase 2**: Construct `canonicalFlagBFMCS` using `closedFlags`

```lean
noncomputable def canonicalFlagBFMCS (M0 : CanonicalMCS) : FlagBFMCS where
  root := M0
  flags := closedFlags M0
  flags_nonempty := closedFlags_nonempty M0
  modal_coherent := by
    -- BoxContent preservation follows from MCSBoxContent_subset_of_CanonicalR
    -- and S5 axiom structure
    sorry  -- Proof by BoxContent propagation
  modally_saturated := closedFlags_closed_under_witnesses M0
  eval_flag := canonicalMCS_in_some_flag M0 |>.choose
  eval_flag_mem := by
    -- The eval flag is in closedFlags because all flags containing M0 are
    -- This requires showing canonicalMCS_in_some_flag produces a flag in closedFlags
    sorry  -- Follow-up task for Phase 3
  eval_element := ⟨M0, ...⟩
```

**Phase 3**: Adapt Truth Lemma for FlagBFMCS

The truth lemma needs a new base case for Box/Diamond:

```lean
theorem truth_lemma_flag (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula) :
    satisfies_at B F x φ ↔ φ ∈ chainFMCS(F).mcs x := by
  induction φ with
  | box ψ =>
    constructor
    · intro h
      -- Truth of Box ψ at (F, x) means ψ true at all accessible (F', x')
      -- "Accessible" in FlagBFMCS = (F', x') where x'.world is BoxContent-compatible
      -- Since B.modal_coherent ensures BoxContent propagation:
      -- Box ψ in chainFMCS(F).mcs(x) = x.val.world
      -- By MCS maximality, if Box ψ not in x.val.world, then Diamond(¬ψ) in x.val.world
      -- By B.modally_saturated, ∃ F', x' with ¬ψ ∈ x'.val.world
      -- But ψ true at (F', x') by assumption → ψ ∈ x'.val.world [contradiction]
      sorry
  | diamond ψ => ...
```

**Phase 4**: Connect to existing completeness infrastructure

The existing `saturated_modal_backward` theorem in ModalSaturation.lean needs adaptation:
- Currently works for `BFMCS D`
- Need analogous theorem for `FlagBFMCS`
- The mathematical content is the same; only the type structure changes

---

## Confidence Assessment

| Claim | Confidence | Evidence |
|-------|------------|---------|
| Singleton BFMCS approach is impossible | **VERY HIGH** | Mathematical counterexample, code comments |
| Temporal T-axioms absent from proof system | **VERY HIGH** | Axioms.lean, FMCSDef.lean comments |
| Constant witness families don't work | **VERY HIGH** | Forward_G requires G-T axiom |
| Same-domain multi-family approaches fail | **HIGH** | flagFMCS_over_CanonicalMCS = identity |
| FlagBFMCS is the correct architecture | **HIGH** | Mathematical semantics alignment |
| closedFlags provides the right content | **VERY HIGH** | closedFlags_closed_under_witnesses proven |
| Truth lemma adaptation is feasible | **MEDIUM** | Requires careful analysis of proof structure |

---

## What the Existing Infrastructure Provides

| Component | File | Status | FlagBFMCS Role |
|-----------|------|--------|----------------|
| `chainFMCS` | ChainFMCS.lean | Sorry-free | Temporal FMCS per Flag |
| `closedFlags_closed_under_witnesses` | ClosedFlagBundle.lean | Sorry-free | `modally_saturated` field |
| `closedFlags_nonempty` | ClosedFlagBundle.lean | Sorry-free | `flags_nonempty` field |
| `canonicalMCS_in_some_flag` | ChainFMCS.lean | Sorry-free | `eval_flag` construction |
| `MCSBoxContent_subset_of_CanonicalR` | ChainFMCS.lean | Sorry-free | `modal_coherent` field |
| `closedFlags_union_modally_saturated` | SaturatedBFMCSConstruction.lean | Sorry-free | Background theorem |
| `saturated_modal_backward` | ModalSaturation.lean | Sorry-free | Template for FlagBFMCS analog |

The mathematical content is **almost entirely present**. The remaining work is:
1. Defining the `FlagBFMCS` structure (new type)
2. Proving `modal_coherent` using BoxContent propagation (~20 lines)
3. Wiring `eval_flag_mem` (showing the chosen eval flag is in closedFlags, ~10 lines)
4. Adapting the truth lemma Box/Diamond cases for FlagBFMCS semantics (main effort)

---

## Conflicts Between Teammates

| Topic | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Primary approach | Witness Family Construction | HeterogeneousBFMCS | **Resolved in favor of B** (Approach A fails due to temporal T-axiom absence) |
| Feasibility of Approach E (enriched chains) | Not analyzed | "Promising but consistency proof needed" | **Deprioritized** — even if enriched chains exist, they don't address the fundamental domain type issue |
| Effort estimate | ~Engineering challenge | ~Medium-high | **Medium** — main effort is truth lemma adaptation |

---

## References

- **Blocker analysis**: `specs/1003_implement_modal_coherence/reports/03_blocker-analysis.md`
- **Teammate A findings**: `specs/1003_implement_modal_coherence/reports/04_teammate-a-findings.md`
- **Teammate B findings**: `specs/1003_implement_modal_coherence/reports/04_teammate-b-findings.md`
- **Modal saturation**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- **BFMCS definition**: `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- **FMCS definition**: `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- **Flag closure**: `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean`
- **ChainFMCS**: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`
- **Hughes & Cresswell**: "A New Introduction to Modal Logic", Ch. 4 (canonical model construction)

---

## Next Steps

1. **Create task 1005**: Define `FlagBFMCS` structure and prove `canonicalFlagBFMCS`
2. **Create task 1006**: Adapt truth lemma for `FlagBFMCS` Box/Diamond cases
3. **Update task 988**: The dense completeness proof can use `FlagBFMCS` once available
4. **Consider**: Whether `FlagBFMCS` should replace `BFMCS D` throughout or be a separate
   structure used only for the canonical model construction

---

## Teammate Contributions

| Teammate | Angle | Key Contribution | Confidence |
|----------|-------|-----------------|------------|
| A | Mathematical Foundations | Identified canonical model R relation, showed multi-family necessity | High |
| B | Alternative Approaches | Boneyard analysis, HeterogeneousBFMCS proposal, sigma-type evaluation | High |
| Synthesis | Integration | Discovered G-T axiom absence, definitive failure of constant families, recommended FlagBFMCS | Very High |
