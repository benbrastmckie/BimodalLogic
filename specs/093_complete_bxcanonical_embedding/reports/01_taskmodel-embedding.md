# Research Report: TaskModel Embedding for BXCanonical Completeness

## Task 93 | Session: sess_1776063182_1c639d

## 1. The Sorry

**Location**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:154`

**Context**: The `bx_completeness` theorem proves `valid phi -> Nonempty (DerivationTree [] phi)` by contrapositive. The proof:

1. Assumes `phi` is not derivable (line 131)
2. Shows `{neg phi}` is consistent (line 133, proved)
3. Extends to MCS `M` containing `neg phi` (line 135, proved)
4. Shows `phi not_in M` (line 139, proved)
5. **sorry**: Needs to derive contradiction from `valid phi` and `phi not_in M`

The sorry must show that `valid phi` implies `phi in M` for any MCS `M`, which requires constructing a concrete `TaskModel` where the MCS truth properties translate to semantic truth via `truth_at`.

## 2. Architecture Overview

### 2.1 Two Parallel Approaches

The codebase contains two partially overlapping completeness architectures:

| Component | BXCanonical (target) | Algebraic/Parametric (existing) |
|-----------|---------------------|-------------------------------|
| World points | `BXPoint` (MCS wrapper) | `ParametricCanonicalWorldState` (MCS subtype) |
| Temporal order | `bx_le` (g_content subset) | `parametric_canonical_task_rel` (sign-based) |
| Modal equiv | `bx_modal_equiv` (Box agreement) | BFMCS modal coherence |
| Frame | Not yet constructed | `ParametricCanonicalTaskFrame D` |
| Model | Not yet constructed | `ParametricCanonicalTaskModel D` |
| Truth lemma (MCS level) | atom/bot/imp/box/G/H/Until-fwd/Since-fwd proved | Full bidirectional proved |
| Truth lemma (semantic) | Not yet connected | `parametric_canonical_truth_lemma` proved |
| BFMCS | Not used | Requires `construct_bfmcs` (conditional) |

### 2.2 Key Equivalences

- `bx_le w v` = `g_content w.formulas ⊆ v.formulas` = `ExistsTask w.formulas v.formulas`
- `BXPoint` is structurally identical to `ParametricCanonicalWorldState` (both wrap MCS)
- `bx_modal_equiv` corresponds to Box-agreement, which is what BFMCS modal coherence captures

## 3. The Constant-History Anti-Pattern

**Anti-patterns #8 and #12** (ROAD_MAP.md): On a constant history (all times map to the same world state), `G(alpha)` is semantically identical to `alpha` because `truth_at` for `all_future` quantifies over all times `s >= t`, but they all map to the same state. This makes it impossible to distinguish `G(alpha)` from `alpha`, blocking the backward truth lemma for G.

**Implication**: The `TaskModel` must use non-constant histories where different times map to different BXPoints.

## 4. Proof Strategy Analysis

### 4.1 Strategy A: Direct BXCanonical TaskModel Construction

Build a `TaskFrame` and `TaskModel` directly from `BXPoint` infrastructure, without going through BFMCS.

**Key construction**:
- Choose `D = Int` (or any ordered abelian group)
- `WorldState = BXPoint`
- `task_rel w d v`: For `d > 0`, `bx_le w v`; for `d = 0`, `w = v`; for `d < 0`, `bx_le v w`
- Histories: For each BXPoint `w`, construct a non-constant history by using `bx_forward_witness`/`bx_backward_witness` to build chains of distinct BXPoints
- Omega: All time-shifts of constructed histories (for shift-closure)
- Valuation: `atom p` is true at BXPoint `w` iff `atom p in w.formulas`

**Truth lemma bridge**: Connect `truth_at M Omega tau t phi` to `phi in w.formulas` where `w` is the BXPoint at time `t` in history `tau`.

**Challenges**:
1. **TaskFrame axioms**: `nullity_identity` requires `task_rel w 0 v <-> w = v`. Since `bx_le w v` is a preorder (not antisymmetric in general), using `bx_le` for `d > 0` means `task_rel w 1 v` and `task_rel v 1 w` (i.e., `bx_le w v` and `bx_le v w`) don't imply `w = v` unless we quotient by mutual `bx_le`. But the existing `ParametricCanonicalTaskFrame` handles this with sign-based cases.
2. **Forward composition**: Needs `bx_le_trans` which exists.
3. **Converse**: Needs backward direction, relates to `h_content`. The `bx_le` ordering already has this infrastructure via `h_content_subset_implies_g_content_reverse`.
4. **Non-constant histories**: Must construct FMCS-like families from BXPoints. The `bx_forward_witness` and `bx_backward_witness` provide witnesses but constructing a coherent Int-indexed family requires a dovetailing or chain construction.
5. **Truth lemma**: The MCS-level truth properties (G_iff_mcs, H_iff_mcs, box_iff_mcs) are proved. Need to bridge to `truth_at` which quantifies over all times in D and all histories in Omega.

**Assessment**: This requires significant new construction (TaskFrame, histories, Omega, truth lemma bridge). Estimated 500-800 lines.

### 4.2 Strategy B: Bridge to Parametric Infrastructure

Reuse the existing `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`, and `parametric_canonical_truth_lemma` by constructing a BFMCS from the MCS `M` obtained in the completeness proof.

**Key construction**:
- Given MCS `M` (containing `neg phi`), construct a temporally coherent BFMCS over `D` with `M` at time 0
- Use `parametric_algebraic_representation_relative` to get `not truth_at ... phi`
- This gives a concrete `TaskModel` (the parametric canonical one) and Omega (shift-closed) where `phi` is false

**What's needed**:
1. A function `construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' (B : BFMCS D) ...` that builds a temporally coherent, modally saturated, Until/Since-coherent BFMCS
2. This is the `construct_bfmcs` parameter in `parametric_algebraic_representation_conditional`

**The BFMCS construction gap**: This is the hardest part. To build a BFMCS from a single MCS requires:
- Building FMCS families (Int-indexed MCS chains with forward_G and backward_H)
- Modal saturation (adding witness families for Diamond formulas)
- Temporal coherence (forward_F and backward_P within families)
- Until/Since coherence

The BXCanonical Frame.lean provides the *witnesses* for all these steps (bx_forward_witness, bx_backward_witness, bx_modal_witness, bx_until_eventuality_resolution, bx_since_eventuality_resolution). The challenge is packaging them into the BFMCS structure.

**Assessment**: Reuses ~2000 lines of existing infrastructure. New code needed: BFMCS construction from BXPoint witnesses (~300-500 lines). This is the preferred strategy.

### 4.3 Strategy C: Direct Proof Without Explicit TaskModel

Instead of constructing a full TaskModel, prove the contradiction directly at `Completeness.lean:154`. The sorry needs to derive `False` from:
- `h_valid : valid phi` (true in ALL models)
- `h_not_in : phi not_in M` (phi not in some MCS)

The `valid phi` gives us `truth_at M_model Omega tau t phi` for ANY model/history/time. If we can exhibit a specific model where `truth_at` at some point corresponds to MCS membership, we have `phi in M`, contradicting `h_not_in`.

This is essentially Strategy B but we don't need the full conditional representation theorem. We just need:
1. Any `TaskFrame D` (parametric canonical works)
2. Any `TaskModel` with MCS-based valuation
3. Any `ShiftClosed Omega`
4. A specific history `tau in Omega` and time `t` such that `truth_at ... tau t psi <-> psi in M` for the relevant formulas

**The minimal path**: Use `ParametricCanonicalTaskFrame Int` with `ParametricCanonicalTaskModel Int`. Build a single FMCS containing `M` at time 0, extend to a BFMCS, use the parametric truth lemma.

**Assessment**: This is the most focused version of Strategy B. Still needs BFMCS construction.

## 5. The BFMCS Construction: Core Challenge

All strategies ultimately require building an FMCS (family of MCS indexed by Int) from a single starting MCS. Here is the proposed construction:

### 5.1 Constant Family (Reflexive Semantics)

Under reflexive semantics (BX1: `G phi -> phi`), a **constant family** `t -> M` satisfies `forward_G`:
- If `G phi in M` and `t <= t'`, then `phi in M` (by BX1 via `bx_le_refl`)

This is valid because the FMCS `forward_G` field requires: `G phi in mcs t` and `t <= t'` implies `phi in mcs t'`. For a constant family, `mcs t = mcs t' = M`, so this reduces to `G phi in M -> phi in M`, which is exactly BX1 (temp_t_future).

Similarly for `backward_H`: `H phi in M` and `t' <= t` implies `phi in M` (by BX1' / temp_t_past).

**But this is constant-history!** On a constant family, all times map to the same MCS, so `G(alpha)` and `alpha` are semantically indistinguishable.

### 5.2 Why Constant Families Work with Bundle Infrastructure

The anti-pattern applies to *constant histories* in the semantic model (WorldHistory where all times map to the same WorldState). But in the BFMCS/parametric approach, truth is defined as MCS membership, NOT as `truth_at` on a constant history. The truth lemma bridges between the two:

```
phi in fam.mcs t  <->  truth_at Model Omega (parametric_to_history fam) t phi
```

For the **backward G case** of the truth lemma, we need: if `truth_at ... (parametric_to_history fam) s phi` for all `s >= t`, then `G phi in fam.mcs t`. The proof goes by contraposition:
1. Assume `G phi not_in fam.mcs t`
2. Then `F(neg phi) in fam.mcs t` (temporal duality)
3. By `forward_F` (temporal coherence): exists `s > t` with `neg phi in fam.mcs s`
4. By forward IH: `truth_at ... s (neg phi)`, contradicting hypothesis

**Step 3 requires `forward_F`**: For a constant family, `F(neg phi) in M` means there should exist `s > t` with `neg phi in M`. But `neg phi in M` is already true if `F(neg phi) in M` and BX1 gives us `F(neg phi) -> neg phi` (since `F phi = neg G (neg phi)` and `G (neg phi) -> neg phi`... wait, that's `G(neg phi) -> neg phi`, not `F(neg phi) -> neg phi`).

Actually: `F(neg phi) = neg(G(neg(neg phi)))`. From BX1: `G(neg(neg phi)) -> neg(neg phi)`. By contraposition: `neg(neg(neg phi)) -> neg(G(neg(neg phi))) = F(neg phi)`. This is the wrong direction.

Let me reconsider. Does `F(psi) in M` imply `psi in M` for MCS under reflexive semantics?

`F(psi) = neg(G(neg psi))`. In MCS M: `F(psi) in M` iff `G(neg psi) not_in M`. This does NOT imply `psi in M`. It only says `neg psi` is not guaranteed at all future/present times.

So for a constant family, `F(neg phi) in M` does NOT give us `neg phi in M`. This means the temporal coherence `forward_F` fails for constant families:
- `forward_F` requires: `F(psi) in fam.mcs t -> exists s >= t, psi in fam.mcs s`
- For constant family: `fam.mcs s = M` for all `s`, so this reduces to `F(psi) in M -> psi in M`
- This is NOT a theorem of TM logic

**Therefore constant families do NOT satisfy temporal coherence (`forward_F`).** This is a different issue from the constant-history anti-pattern, but it has the same root cause.

### 5.3 Non-Constant Family Construction

The standard approach in tense logic (Burgess 1984, Goldblatt 1992) builds chains of MCS:

**Dovetailed chain construction** (already implemented in Boneyard but for strict semantics):
1. Start with MCS M_0 at time 0
2. For each time n+1: collect all F-obligations from M_n, resolve them one by one via Lindenbaum
3. For each time -(n+1): collect all P-obligations from M_{-n}, resolve similarly
4. Interleave (dovetail) the F/P obligation resolution

The BXCanonical infrastructure provides exactly the witnesses needed:
- `bx_forward_witness`: `F(psi) in w -> exists v, bx_le w v, psi in v`
- `bx_backward_witness`: `P(psi) in w -> exists v, bx_le v w, psi in v`

**But** the existing `bx_forward_witness`/`bx_backward_witness` produce BXPoints with `bx_le` relation, which is `g_content` inclusion. To build an FMCS, we need the MCS at time `s > t` to satisfy `forward_G`: `G phi in mcs t -> phi in mcs s`. This is exactly `bx_le (mcs t) (mcs s)`.

So the construction is:
- `fam.mcs 0 = M_0.formulas`
- `fam.mcs (n+1)`: resolve one F-obligation from `fam.mcs n` via `bx_forward_witness`, ensuring `bx_le (fam.mcs n) (fam.mcs (n+1))`
- `fam.mcs (-(n+1))`: resolve one P-obligation from `fam.mcs (-n)` via `bx_backward_witness`, ensuring `bx_le (fam.mcs (-(n+1))) (fam.mcs (-n))`
- `forward_G`: follows from transitivity of `bx_le` along the chain

### 5.4 Handling Multiple Obligations

The dovetailed chain must eventually resolve ALL F/P obligations, not just one. Since there are countably many formulas, this is achievable by dovetailing (interleaving resolution of different obligations).

However, the BXCanonical Frame.lean already handles this differently: the witnesses are independent Lindenbaum extensions. The chain only needs to be monotone in `bx_le`, and each step resolves one obligation.

For the **truth lemma**, we need:
- Forward G: `G phi in fam.mcs t` and `t <= t'` implies `phi in fam.mcs t'`. This follows from `bx_le` transitivity along the chain.
- Backward G (for temporal coherence): `F(psi) in fam.mcs t` implies `exists s >= t, psi in fam.mcs s`. This requires the chain to eventually visit a point containing `psi`.

The dovetailed enumeration ensures every obligation is eventually resolved.

## 6. Recommended Approach

### 6.1 The Concrete Plan

**Strategy B (Bridge to Parametric)** with the following specific steps:

1. **Build an FMCS from BXPoints** using a dovetailed chain construction:
   - Enumerate all formulas as `phi_0, phi_1, phi_2, ...`
   - At each step, resolve the next pending F-obligation (for positive times) or P-obligation (for negative times)
   - Use `bx_forward_witness` / `bx_backward_witness` for witnesses
   - The chain is monotone in `bx_le` (forward) and reverse-monotone (backward)

2. **Build a BFMCS** by modal saturation:
   - Start with the single FMCS from step 1
   - For each Diamond obligation `Diamond psi in fam.mcs t`, add a witness family using `bx_modal_witness` and chain extension
   - The `box_preserved_along_bx_le` theorem ensures Box formulas are preserved, giving modal coherence

3. **Verify temporal and Until/Since coherence** using the existing BXCanonical infrastructure

4. **Apply `parametric_algebraic_representation_relative`** to get the countermodel

5. **Instantiate `valid phi`** at the parametric canonical frame to get `truth_at ... phi` at the evaluation point, contradicting the countermodel

### 6.2 Critical Dependencies

| What's Needed | Where It Comes From | Status |
|---------------|---------------------|--------|
| `bx_le_refl` | Frame.lean:140 | Proved |
| `bx_le_trans` | Frame.lean:153 | Proved |
| `bx_forward_witness` | Frame.lean:164 | Proved |
| `bx_backward_witness` | Frame.lean:176 | Proved |
| `bx_modal_witness` | Frame.lean:358 | Proved |
| `box_preserved_along_bx_le` | Frame.lean:538 | Proved |
| `bx_until_eventuality_resolution` | Frame.lean:623 | Proved |
| `bx_since_eventuality_resolution` | Frame.lean:650 | Proved |
| `G_iff_mcs` | TruthLemma.lean:125 | Proved |
| `H_iff_mcs` | TruthLemma.lean:138 | Proved |
| `box_iff_mcs` | TruthLemma.lean:151 | Proved |
| `parametric_canonical_truth_lemma` | ParametricTruthLemma.lean | Proved |
| `ParametricCanonicalTaskFrame` | ParametricCanonical.lean | Proved |
| `ShiftClosedParametricCanonicalOmega` | ParametricHistory.lean | Proved |
| Formula enumeration for dovetailing | Not yet implemented | **NEEDED** |
| FMCS chain construction from BXPoints | Not yet implemented | **NEEDED** |
| BFMCS construction with modal saturation | Not yet implemented | **NEEDED** |
| Until/Since coherence for BFMCS | Not yet implemented | **NEEDED** |
| Bridge from `valid phi` to parametric model | Not yet implemented | **NEEDED** |

### 6.3 Alternative: Simplify with BXPoint-to-FMCS Direct Mapping

The `bx_le` ordering on BXPoints is essentially the same as the `ExistsTask` relation in `CanonicalFrame.lean`. A BXPoint IS a `ParametricCanonicalWorldState`:

```lean
def bxpoint_to_pcws (w : BXPoint) : ParametricCanonicalWorldState :=
  ⟨w.formulas, w.is_mcs⟩
```

And `bx_le w v` is equivalent to `parametric_canonical_task_rel (bxpoint_to_pcws w) d (bxpoint_to_pcws v)` for `d > 0`.

This means we can directly build the `ParametricCanonicalTaskFrame` world states from BXPoints, with the task relation defined identically. The FMCS construction then maps each time `t : Int` to a BXPoint.

### 6.4 Estimated Complexity

- **FMCS chain construction**: ~200-300 lines (dovetailed chain with formula enumeration)
- **BFMCS packaging**: ~100-150 lines (modal saturation, temporal coherence verification)
- **Bridge proof**: ~100-200 lines (connecting `valid phi` to parametric model, deriving contradiction)
- **Total**: ~400-650 lines in a new file (e.g., `BXCanonical/CanonicalModel.lean`)

## 7. Key Risks and Mitigations

### Risk 1: Formula Enumeration
Lean 4 formulas are countable (built from finite constructors). An enumeration `Formula -> Nat` is needed for dovetailing. This may require proving `Countable Formula` or constructing an explicit bijection.

**Mitigation**: Use `Encodable Formula` from Mathlib if available, or construct a simple encoding.

### Risk 2: Chain Construction Requires Choice
The dovetailed chain construction uses `bx_forward_witness`/`bx_backward_witness` which are noncomputable (use Lindenbaum/Zorn). The entire chain construction will be noncomputable, which is fine for a completeness proof.

### Risk 3: Until/Since Coherence in BFMCS
The BFMCS coherence conditions for Until/Since (`backward_until_since_coherent`, `forward_until_since_coherent`) require that the chain handles Until/Since obligations properly. The dovetailed chain must also resolve Until obligations.

**Mitigation**: The existing `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` provide the witnesses. Dovetail Until/Since obligations alongside F/P obligations.

### Risk 4: Bridge Between BXCanonical and Algebraic Namespaces
The proof needs to connect BXCanonical's `BXPoint`-based infrastructure with the Algebraic's `ParametricCanonicalWorldState`-based infrastructure.

**Mitigation**: The two are structurally identical. A simple coercion/transport suffices.

## 8. Concrete Implementation Recommendation

### Phase 1: FMCS Construction from BXPoint (~250 lines)

Create `BXCanonical/CanonicalModel.lean`:
1. Define formula enumeration (or import from existing infrastructure)
2. Define dovetailed chain step function
3. Construct `FMCS Int` from starting BXPoint `w0`
4. Prove `forward_G` and `backward_H` for the constructed family
5. Prove `forward_F` and `backward_P` (temporal coherence) by showing the chain resolves all F/P obligations

### Phase 2: BFMCS and Modal Saturation (~150 lines)

1. Construct initial BFMCS from single family + modal witnesses
2. Prove modal saturation
3. Package as `BFMCS Int` with all coherence conditions

### Phase 3: Bridge and Close Sorry (~200 lines)

1. Apply `parametric_algebraic_representation_relative` to get countermodel
2. In `Completeness.lean:154`:
   - Construct the BFMCS from MCS `M`
   - Get `not truth_at ... phi` at the evaluation point
   - Instantiate `valid phi` at the parametric canonical frame
   - Derive contradiction

## 9. Resolved Questions

1. **Formula enumeration**: `Denumerable Formula` is available (derived instance at `Formula.lean:101`). This provides `Denumerable.ofNat : Nat -> Formula` for dovetailing.

2. **Parametric truth lemma covers Until/Since**: Yes. `parametric_canonical_truth_lemma` at `ParametricTruthLemma.lean:219` handles all cases including `untl` and `snce`. It requires three coherence hypotheses: `h_tc : B.temporally_coherent`, `h_buc : B.backward_until_since_coherent`, and `h_fuc : B.forward_until_since_coherent`.

3. **Until/Since coherence definitions**:
   - `backward_until_since_coherent` (TemporalCoherence.lean:503): Given a witness pattern (psi at s, phi on guard interval), derive phi U psi membership. This is provable using the BX8 reflexive intro axiom and the BX Until induction axiom.
   - `forward_until_since_coherent` (TemporalCoherence.lean:518): Given phi U psi in fam.mcs t, produce a witness s >= t with psi in fam.mcs s and phi on the guard. This is the harder direction and requires the chain to resolve Until eventualities.

4. **Shift-closure**: The `ShiftClosedParametricCanonicalOmega` is already proved shift-closed in `ParametricHistory.lean`. The `valid` definition quantifies over all shift-closed Omega, so we can instantiate it with this specific Omega.

## 10. Open Questions Remaining

1. **Can we avoid the full dovetailed chain?** For the completeness proof, we only need to falsify ONE formula (phi). A simpler construction might suffice if we can show that the truth lemma for phi specifically only requires resolving finitely many obligations. However, the parametric truth lemma requires full coherence (not restricted to subformulas of phi), though `restricted_forward_until_since_coherent` exists as a weaker alternative.

2. **Dovetailing Until obligations**: The forward_until_since_coherent condition requires that for `phi U psi in fam.mcs t`, there exists `s >= t` with `psi in fam.mcs s` AND `phi in fam.mcs r` for all `r in [t, s)`. The chain must place psi at some concrete time AND ensure phi holds at all intermediate times. This is the hardest part of the construction, as intermediate chain positions must all contain phi. The BXCanonical `bx_until_eventuality_resolution` provides `phi in w` (the starting point) and `psi in v` (the witness), but does NOT guarantee phi at all intermediate BXPoints in the chain.

3. **Guard interval population**: The until forward coherence needs `phi in fam.mcs r` for `t <= r < s`. If the chain only has BXPoints at integer times, and `t` and `s` are both integers with `s = t + 1`, then there are no intermediate integers, so the guard is vacuously satisfied. This suggests using `D = Int` and placing the Until witness at `t + 1` would trivially satisfy the guard condition. This is a key simplification.
