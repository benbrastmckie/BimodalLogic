# Task 41: Eliminate D=CanonicalMCS Pattern - Teammate B Research Findings

## Key Findings

### 1. The D=CanonicalMCS Pattern Is Intentional and Mathematically Valid (But Misarchitectured)

The `CanonicalFMCS.lean` file explicitly documents the pattern with a table (lines 22-27):

| Aspect | Standard FMCS | FMCS CanonicalMCS |
|--------|---------------|-------------------|
| Indexing Type | `Int`, `TimelineQuot`, `Rat` | `CanonicalMCS` |
| Structure | AddCommGroup + LinearOrder | Preorder only |
| mcs Function | Maps time points to worlds | Identity: mcs(w) = w.world |
| F/P Witnesses | Must be constructed | Trivial (every MCS is in domain) |
| Purpose | Semantic model | TruthLemma proof |

The key insight documented there: "every MCS is in the domain" makes `forward_F` and `backward_P` trivially satisfied. The witness from `canonical_forward_F` is already a `CanonicalMCS` element, so no reachability argument is needed. **This is mathematically legitimate.**

The pattern was adopted because the `CanonicalReachable` approach (original plan v5) **fails for `backward_P`**: a backward witness W satisfies `h_content(w) ⊆ W`, but there is no TM axiom that makes W future-reachable from M₀. The all-MCS domain sidesteps this entirely.

### 2. DovetailedTimelineQuot Provides a Proper D≠CanonicalMCS Construction

`DovetailedTimelineQuot` is a dense linear order constructed via a Cantor isomorphism. The `dovetailedFMCS` over it (`DovetailedFMCS.lean`) uses `D = DovetailedTimelineQuot root_mcs root_mcs_proof` as a genuine temporal domain with `LinearOrder`.

Crucially, `dovetailedTimelineQuotFMCS_forward_F` and `dovetailedTimelineQuotFMCS_backward_P` are **proven without sorry** in `DovetailedTimelineQuot.lean` (lines 1315 and 1471). The proof works via a staged/dovetailed construction where at step `pair(point_index, k)`, the witness for formula with encoding k is explicitly added to the timeline. This is the **correct D≠CanonicalMCS pattern for dense time**.

### 3. SuccChainFMCS Provides the D=Int Pattern But Has F/P Blockers

`SuccChainFMCS.lean` constructs an `FMCS Int` using forward/backward Lindenbaum chains from a root `SerialMCS`. The chain elements satisfy `Succ` (CanonicalR + f-step conditions). However, the file explicitly documents:

> **FUNDAMENTAL LIMITATION**: F/P witness proofs CANNOT be proven for ANY linear chain construction. Linear chains use Lindenbaum extension at each step, which can introduce `G(~phi)` into the extension, killing `F(phi) = ~G(~phi)`. (IntBFMCS.lean lines 22-37)

The `IntBFMCS.lean` has 4 sorry-backed F/P witness positions as a result. **D=Int with linear chains does not escape the trivialization problem - it just replaces it with a different sorry.**

### 4. What "Trivializes F/P Witness Obligations" Means Mathematically

In `FMCS CanonicalMCS`:
- `forward_F` asks: given `F(phi) ∈ mcs(w)`, find `s : CanonicalMCS` with `w ≤ s` and `phi ∈ mcs(s)`
- `mcs(s) = s.world` by definition, so this becomes: find `s : CanonicalMCS` with `CanonicalR w.world s.world` and `phi ∈ s.world`
- `canonical_forward_F` gives exactly this, and the result `W` IS a `CanonicalMCS` by construction

In `FMCS Int`:
- `forward_F` asks: given `F(phi) ∈ mcs(t)`, find `s : Int` with `t < s` and `phi ∈ mcs(s)`
- This requires phi to survive all the Lindenbaum extensions from t to s - not guaranteed

In `FMCS DovetailedTimelineQuot`:
- `forward_F` asks: given `F(phi) ∈ mcs(t)`, find `s : DovetailedTimelineQuot` with `t < s` and `phi ∈ mcs(s)`
- The dovetailed construction guarantees that at stage `pair(p.point_index, k)` where `k = encode(phi)`, a witness point is added with phi. This works because the domain IS the set of all such witness points by construction.

### 5. The Dual-Domain Architecture Already Separates Temporal and Modal Domains

`TimelineQuotBFMCS.lean` and `DovetailedTimelineQuotBFMCS.lean` already implement a **dual-domain architecture** (lines 30-38 of TimelineQuotBFMCS.lean):

- **Temporal domain**: TimelineQuot/DovetailedTimelineQuot (dense linear order)
- **Modal domain**: CanonicalMCS (all maximal consistent sets)
- **BFMCS**: Over CanonicalMCS with modal saturation via closedFlags

This is explicitly the correct separation, but these BFMCSs are still built over `CanonicalMCS` (not the temporal domain) for the modal coherence. The `dovetailedTimelineQuotBFMCS` (Phase 5 in `DovetailedTimelineQuotBFMCS.lean`) IS built over `DovetailedTimelineQuot`, but has a sorry in `modal_backward` (lines 422-426).

### 6. ChainFMCS Provides D=CanonicalMCS Infrastructure for Modal Structure

`ChainFMCS.lean` defines `MCSBoxContent`, `Boxg_content`, and the key theorem `MCSBoxContent_subset_of_CanonicalR`. These are foundational for any approach where MCS Box-content needs to propagate through the temporal ordering. This file does not itself use D=CanonicalMCS but provides the modal content machinery that witnesses need to preserve.

### 7. Risks of Eliminating D=CanonicalMCS

**Critical risk**: The theorem `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean:325) is sorry-free and load-bearing for 13+ downstream files. Replacing it requires a sorry-free `temporal_coherent_family_exists_DovetailedTimelineQuot` (or similar). The dovetailed FMCS over DovetailedTimelineQuot HAS proven forward_F/backward_P (no sorry), making it the best replacement candidate.

**Modal coherence risk**: The `modal_backward` property for a singleton BFMCS (DovetailedTimelineQuotBFMCS.lean:265-426) has a sorry because `phi → Box phi` is not generally provable. The canonical FMCS-based BFMCS avoids this by using closedFlags for modal saturation - but that BFMCS is over CanonicalMCS. Any D=DovetailedTimelineQuot replacement must handle this.

**Secondary risk**: The Zero instance for CanonicalMCS (CanonicalFMCS.lean:235) is used by `TemporalCoherentFamily` which requires `[Zero D]`. Switching to DovetailedTimelineQuot needs a Zero instance on that type (the dovetailed construction already provides a root element, but the instance may need wiring).

## Recommended Approach

The refactoring should follow a **staged separation strategy** rather than a wholesale replacement:

1. **Keep `FMCS CanonicalMCS` for the TruthLemma** (it is sorry-free and mathematically valid as a proof technique)
2. **Introduce `temporal_coherent_family_exists_DovetailedTimelineQuot`** as the replacement for the semantic model portion. This theorem already exists in pieces: `dovetailedTimelineQuotFMCS_forward_F` and `dovetailedTimelineQuotFMCS_backward_P` are proven.
3. **Bridge via the `parametric_to_history` mechanism** in `ParametricHistory.lean`, which converts any `FMCS D` to a `WorldHistory` over `ParametricCanonicalTaskFrame D`. This is the correct place to instantiate D=DovetailedTimelineQuot for the semantic completeness argument.
4. **Fix modal_backward sorry** in `dovetailedTimelineQuotBFMCS` using the ClosedFlagBundle pattern already present in DovetailedTimelineQuotBFMCS.lean Phases 4.1-4.5.
5. **DO NOT attempt D=Int** - the fundamental linear chain limitation (sorry-backed in IntBFMCS.lean) means this adds sorry rather than removing it.

The correct D type for the proper semantic model is `DovetailedTimelineQuot`, which already has:
- LinearOrder (via Cantor quotient construction)
- Sorry-free forward_F and backward_P
- A root element connecting to any given MCS

## Evidence/Examples

**Evidence for DovetailedTimelineQuot being the right D type:**
- `dovetailedTimelineQuotFMCS_forward_F` at DovetailedTimelineQuot.lean:1315 - fully proven
- `dovetailedTimelineQuotFMCS_backward_P` at DovetailedTimelineQuot.lean:1471 - fully proven
- The staged construction's witness addition at `witness_at_large_step` ensures phi appears at stage `pair(point_index, encode(phi))`

**Evidence for D=Int being blocked:**
- `IntBFMCS.lean` header (lines 14-49): explicit documentation of the fundamental limitation
- 4 sorries in IntBFMCS.lean for F/P witnesses
- Task 1004 research confirms the limitation

**Evidence for D=CanonicalMCS trivialization:**
- `canonicalMCS_forward_F` (CanonicalFMCS.lean:253): The witness `W` from `canonical_forward_F` is wrapped directly as a CanonicalMCS (lines 258-259: `let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }`)
- No actual witnessing work is done - it's structurally trivial

**Evidence for dual-domain architecture as the correct path:**
- TimelineQuotBFMCS.lean lines 28-38: explicit documentation of the dual-domain separation
- DovetailedTimelineQuotBFMCS.lean lines 180-184: `dovetailedTimelineQuotTemporalFMCS` with D=DovetailedTimelineQuot is already constructed

## Confidence Level

**High** on:
- DovetailedTimelineQuot being the correct D type for dense time (already works)
- D=Int having fundamental blockers (documented, 4 sorries)
- The dual-domain architecture being the right design pattern
- The staging approach (keep CanonicalMCS for TruthLemma, use DovetailedTimelineQuot for semantic model)

**Medium** on:
- Whether `modal_backward` sorry in the singleton BFMCS can be closed (the ClosedFlagBundle approach in Phases 4.1-4.5 suggests yes, but the wiring hasn't been fully completed)
- Exact scope of changes needed across the 13+ load-bearing files
- Whether the Zero instance for DovetailedTimelineQuot can be constructed without sorry

**Low** on:
- Whether eliminating D=CanonicalMCS completely (including in TruthLemma proofs) is feasible without introducing new sorries - the all-MCS domain's triviality was the solution to a genuine backward_P blocker that may recur
