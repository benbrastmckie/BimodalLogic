# Research Report: Prior-UZ Requires IsSuccArchimedean — Implications for Modular Logic Hierarchy

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Date**: 2026-05-12
- **Session**: sess_1778628049_e6d2c8
- **Type**: Research findings and architectural recommendation

## Executive Summary

The sorry in `succ_cofinal` exists because `IsSuccArchimedean` is required throughout the discrete completeness path. Extensive research (5 agents, literature review of Doets 1987, Reynolds 1994, Burgess 1982/1984, Verbrugge 2004, plus codebase analysis) reveals that this requirement is **inherent to Prior-UZ**, not an artifact of the proof. Prior-UZ is invalid on ℤ+ℤ, making it an "integer logic" axiom, not a "discrete logic" axiom. The recommended resolution is to split the discrete level into two tiers, matching the published literature.

## Finding 1: Z1 Is Not Derivable from the Current Axiom System

Z1 (`G(Gφ→φ) → (FGφ→Gφ)`) cannot be derived from Prior-UZ + BX axioms because Z1 is not valid on all frames where those axioms are valid. Counterexample: ω+ω* (or ℤ+ℤ) satisfies all BX axioms and Prior-UZ (for constant valuations) but Z1 fails.

More precisely: Z1 characterizes the IsSuccArchimedean frame condition. It is valid exactly on discrete linear orders where succ-iterates connect all points (i.e., ℤ and its intervals). It fails on ℤ+ℤ where the two copies are disconnected by succ-iteration.

**Confirmed by**: Implementation agent attempted exhaustive derivation (74 tool uses, 28 minutes). All derivation paths fail because the critical step `¬Gφ → G(¬Gφ)` (the 4-axiom for ¬G) is not available — G is strict-future, not reflexive.

## Finding 2: Prior-UZ Is Invalid on ℤ+ℤ

Prior-UZ: `F(φ) → U(φ, ¬φ)` — "if φ holds in the future, the nearest future φ-point exists."

**Counterexample on ℤ+ℤ**: Let ℤ+ℤ be two copies of the integers (first copy below second). Set p true on the second copy, false on the first. At point 0 in the first copy:

- F(p) holds: p is true at every second-copy point, all above 0.
- U(p, ¬p) fails: any witness s in the second copy has another second-copy point s−1 between 0 and s where p is true, violating the ¬p guard. The second copy has no minimum, so there is no "nearest" p-point.

**Conclusion**: Prior-UZ requires that the order above every point is well-ordered (every non-empty definable subset has a minimum). On discrete linear orders, this is equivalent to IsSuccArchimedean. Prior-UZ is a **ℤ-specific axiom**, not a general discrete axiom.

**Verification**: The soundness proof `prior_UZ_is_valid` (SoundnessLemmas.lean:2338) uses `exists_succ_iterate` at line 2346, which requires `[IsSuccArchimedean D]`. This is not a proof artifact — it reflects the genuine frame condition.

## Finding 3: Published Proofs Use Different Architectures

No published completeness proof faces the "omega-chain limit preservation" problem because they all use different strategies:

| Author | Architecture | Gap handling |
|--------|-------------|-------------|
| **Burgess 1982** | Chronicles over ℚ | Proves completeness for class of ALL discrete orders (not ℤ specifically); gaps allowed |
| **Burgess 1984** | S-relation freezing | Explicit invariant: once S(x,y) declared, no insertions between x and y |
| **Doets 1987** | Henkin model + Ehrenfeucht games | Z1 already valid in model → maximum principle → extract ℤ-submodel |
| **Reynolds 1994** | Prior axioms + contemporaneous equivalence | Prior-UZ/SZ → no definable gaps → k-equivalence to ℤ |
| **Verbrugge 2004** | Finite adequate sets + cyclic extension | Build ℤ directly; finite middle part + periodic tails |

Key insight from Verbrugge 2004: the discrete logic D (without Prior-UZ or Z1) is complete for ℤ×ℤ (Theorem 7). D does NOT distinguish ℤ from ℤ+ℤ. The axiom Z1 (called "R" by Verbrugge) is what forces a single copy of ℤ.

## Finding 4: The Frozen Succ-Links Invariant Is Already Fully Exploited

The construction maintains a "frozen succ-links" invariant (Burgess 1984 S-relation):

- When U(⊤,⊥) is resolved at x, ⊥ ∈ g(x, succ(x)) via `g_sub_f_insert` (CounterexampleElimination.lean:597)
- Any future insertion between x and succ(x) would put ⊥ in the new point's MCS, contradicting consistency
- This is **already used** by `limit_dom_has_succ` (ChronicleToCountermodel.lean:858) to establish `SuccOrder`
- It gives local successor structure but **cannot bridge to global connectivity** (IsSuccArchimedean)

## Finding 5: Stage-Induction Boundary Cases Are Fundamentally Hard

The sorry sites at lines 1295 and 1448 in `succ_reaches_dom_N` fail because succ in the full limit_dom can "jump across stages" — `succ(max_N)` might be a point added at stage M ≫ N+1, making the induction hypothesis useless. The boundary cases cannot be closed with the current induction structure.

## Finding 6: The Current "Discrete Logic" Is Actually the "Integer Logic"

The codebase's `DiscreteTemporalFrame` (FrameClass.lean:147) includes `IsSuccArchimedean` in its definition. The `valid_discrete` predicate (Validity.lean:182) quantifies over `IsSuccArchimedean` frames. All discrete soundness lemmas carry `[IsSuccArchimedean D]`.

This means the codebase's "discrete logic" is actually the **integer logic** — it includes Prior-UZ (which requires IsSuccArchimedean for soundness) and targets ℤ specifically.

The dependency chain that forces IsSuccArchimedean:
```
Prior-UZ soundness → requires [IsSuccArchimedean D]
    ↓
DiscreteTemporalFrame includes IsSuccArchimedean
    ↓
valid_discrete quantifies over IsSuccArchimedean frames
    ↓
soundness_discrete requires [IsSuccArchimedean D]
    ↓
succ_embed_surjective uses IsSuccArchimedean
    ↓
dd_countermodel_chronicle_discrete needs it for the final BFMCS
```

## Recommendation: Split the Discrete Level

### Architecture

Introduce a three-tier temporal hierarchy matching the published literature:

| Level | New axioms (over base) | Frame class | IsSuccArchimedean? | Completeness target |
|-------|----------------------|-------------|-------------------|-------------------|
| **Base** (linear) | linearity, seriality, BX1-BX11, U/S axioms | all linear orders | no | all linear orders |
| **Discrete** | U(⊤,⊥), S(⊤,⊥), DF/DP | all discrete linear orders | no | ℤ+ℤ, ℤ×A, etc. |
| **Integer** | Prior-UZ, Prior-SZ (and optionally Z1) | ℤ (and intervals) | **yes** | ℤ |

### Concrete Changes

#### Step A: Define `DiscreteTemporalFrame` without IsSuccArchimedean

```lean
class DiscreteTemporalFrame (D : Type) [...] [SuccOrder D] [PredOrder D] : Prop where
  toSerialFrame : SerialFrame D := {}
```

#### Step B: Define `IntegerTemporalFrame` with IsSuccArchimedean

```lean
class IntegerTemporalFrame (D : Type) [...] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] : Prop where
  toDiscreteTemporalFrame : DiscreteTemporalFrame D := {}
```

#### Step C: Split `valid_discrete` and `soundness_discrete`

- `valid_discrete`: quantifies over `DiscreteTemporalFrame` (no IsSuccArchimedean)
- `valid_integer`: quantifies over `IntegerTemporalFrame` (with IsSuccArchimedean)
- Prior-UZ soundness moves to `valid_integer` only

#### Step D: Split the completeness proof

- `dd_countermodel_chronicle_discrete`: builds a model for the discrete frame class. Does NOT need IsSuccArchimedean. The limit model is a valid discrete linear order (possibly ℤ+ℤ-like). The sorry disappears.
- `dd_countermodel_chronicle_integer`: builds a model for the integer frame class. Adds Z1 as an axiom with soundness proof (`[IsSuccArchimedean D]` on abstract frames — no circularity). Uses Z1 in every MCS to prove the limit model is IsSuccArchimedean via the Doets maximum principle.

#### Step E: Z1 soundness (no circularity)

```lean
theorem z1_is_valid [SuccOrder D] [IsSuccArchimedean D] (φ : Formula) :
    is_valid D (z1_formula φ)
```

This proves Z1 sound for abstract IsSuccArchimedean frames (including ℤ). The proof uses backward induction: from the FGφ witness n₀, step backward n₀, n₀−1, ..., 1, each time applying G(Gφ→φ). This terminates because IsSuccArchimedean guarantees n₀ is finitely many succ-steps from the evaluation point.

The limit model then:
1. Has Z1 in every MCS (because Z1 is an axiom → derivable → `theorem_in_mcs`)
2. Satisfies Z1 semantically (the construction respects MCS content)
3. IsSuccArchimedean follows from Z1 via Doets Claim 10

No circularity: soundness uses IsSuccArchimedean of the abstract frame class; completeness constructs a specific model and proves it belongs to the frame class using Z1.

### Impact Assessment

| Component | Change needed |
|-----------|--------------|
| FrameClass.lean | Split `DiscreteTemporalFrame` into two classes |
| Validity.lean | Add `valid_integer`, relax `valid_discrete` |
| SoundnessLemmas.lean | Move Prior-UZ/SZ soundness to integer level |
| Soundness.lean | Split `soundness_discrete` into discrete + integer |
| Axioms.lean | Add Z1 axiom (for integer level) |
| ChronicleToCountermodel.lean | Remove IsSuccArchimedean from discrete path; add integer completeness theorem with Z1 |

### Estimated Effort

- **Discrete completeness (removing IsSuccArchimedean)**: 2-4 hours. Mostly removing/relaxing constraints. The sorry disappears because it's no longer needed.
- **Integer completeness (adding Z1 + proving IsSuccArchimedean)**: 4-8 hours. Add Z1 axiom, prove soundness, implement Doets maximum principle, prove IsSuccArchimedean from Z1.
- **Total**: 6-12 hours, split across two tasks.

### Alternative: Minimal Change

If the full split is too disruptive, a minimal approach:

1. Add Z1 as an axiom at the current discrete level (which is really the integer level)
2. Prove `z1_is_valid` with `[IsSuccArchimedean D]`
3. Use Z1 in `succ_cofinal` to close the sorry
4. Defer the discrete/integer split to a later task

This closes the sorry with ~4-6 hours of work and ~80-120 lines of new code, without restructuring the frame hierarchy.

## Sources

- Burgess 1982, "Axioms for tense logic I: Since and Until"
- Burgess 1984, "Basic Tense Logic" (S-relation for discrete orders)
- Doets 1987, "Completeness and Definability" (Chapter 7, Claims 8-11)
- Reynolds 1994, "Axiomatising U and S over integer time" (Theorems 5, 14, 18)
- Verbrugge/de Jongh/Veltman 2004, "Completeness by construction" (Theorems 6-8)
- Codebase analysis: SoundnessLemmas.lean, FrameClass.lean, Validity.lean, ChronicleToCountermodel.lean, CounterexampleElimination.lean
