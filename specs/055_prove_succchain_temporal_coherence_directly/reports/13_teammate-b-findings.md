# Teammate B Findings: Alternative Approaches and Prior Art

**Task**: 55 - Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Researcher**: Teammate B (Alternative Approaches)
**Focus**: Option 3 (Bundle-Level Coherence), Prior Art, deferralDisjunction insight

---

## Key Findings

### Finding 1: Bundle-Level Coherence (Option 3) Is Mathematically Valid

**The weakened requirement**: Instead of `forward_F` requiring phi at some `s > t` in the
**same** family, weaken to: for any `fam ∈ bundle` and `F(phi) ∈ fam.mcs t`, there exists
some family `fam' ∈ bundle` and `s > t` such that `phi ∈ fam'.mcs s`.

**Semantic validity**: This is semantically valid for truth evaluation. The `temporal_backward_G`
and `temporal_backward_H` lemmas (TemporalCoherence.lean:165-204) are the only callers of
`forward_F` / `backward_P`. They prove:
- "If `phi ∈ fam.mcs s` for ALL `s > t`, then `G(phi) ∈ fam.mcs t`"

The proof uses: assume `G(phi) ∉ fam.mcs t`, then `F(neg phi) ∈ fam.mcs t`, then by
`forward_F` get `neg(phi) ∈ fam.mcs s` for some `s > t`, contradicting `phi ∈ fam.mcs s`.

**CRITICAL**: The contradiction requires `neg(phi) ∈ fam.mcs s` AND `phi ∈ fam.mcs s` —
both in the **SAME** family at the **SAME** time. So bundle-level coherence (different
families) does NOT work for `temporal_backward_G` as currently stated.

**Conclusion**: Bundle-level coherence breaks `temporal_backward_G`. Option 3 requires
reformulating the backward lemma to work across families, which is nontrivial and may
not be mathematically valid. Option 3 is NOT recommended.

---

### Finding 2: Prior Art — Standard S5+LTL Completeness Approaches

**Standard technique (Blackburn/de Rijke/Venema style)**: Standard completeness proofs for
temporal logics with `F`/`G` use the **Lindenbaum-Henkin saturation** technique, constructing
a maximally consistent set that is also "saturated" — it contains witnesses for all
existential obligations. Specifically, saturation adds `phi` to the MCS whenever `F(phi)`
is in the MCS, using a systematic enumeration.

**How they avoid f_nesting_is_bounded**: The standard approach does NOT use a single
"successor chain" that must satisfy forward_F at each step. Instead:

1. **Direct canonical model**: The canonical model has ONE world per MCS, and the temporal
   accessibility relation directly uses the existence of witnesses. This is exactly what
   `CanonicalFrame.lean` implements! In `canonical_forward_F` (CanonicalFrame.lean:139-154),
   `forward_F` is trivially proven because EACH F-obligation gets its OWN fresh Lindenbaum
   witness. This is the "canonical model" approach — it works perfectly and has NO sorry.

2. **Fair scheduling / filtration**: For LINEAR temporal logic completeness, Gabbay,
   Pnueli, Shelah, Stavi (1980) and Kamp (1968) construct the canonical model using
   a "fair" enumeration that ensures every F-obligation is eventually satisfied. The
   key insight is that the model is constructed ONCE with obligations scheduled explicitly,
   rather than delegated to a deterministic successor chain.

**The key prior art insight**: This project's BFMCS approach (with CanonicalConstruction.lean)
IS the standard canonical model approach. The problem arose from attempting to use a
**linear successor chain** (SuccChainFMCS) as the temporal structure. Standard proofs
use the canonical model directly — they don't build linear chains with Succ steps.

**Goldblatt (1993), Chapter 6**: For combined modal-temporal logics, the canonical model
construction gives a BFMCS directly where each world is an MCS and the temporal relation
connects each world to the witness for its F-obligations. The `forward_F` property holds
trivially because each witness was explicitly constructed for that obligation.

---

### Finding 3: The deferralDisjunction Insight Does NOT Help

**The insight**: `phi ∨ F(phi)` is in every constrained successor seed (via
`deferralDisjunctions`). So at EVERY step `k -> k+1`, either:
- `phi ∈ chain(k+1)` (resolved), OR
- `F(phi) ∈ chain(k+1)` (deferred)

**Why this doesn't eliminate f_nesting_is_bounded**: The deferralDisjunction only
guarantees that the obligation is either resolved or RE-DEFERRED at each step. It does
NOT prevent infinite deferral. A MCS can consistently contain `{F^n(phi) | n ∈ Nat}` —
at each step, the Lindenbaum extension can ALWAYS choose `F(phi)` over `phi` in the
disjunction. This is precisely why `f_nesting_is_bounded` is false.

**Formalization**: For the canonical completeness proof, deferralDisjunctions are useful
for verifying that the `Succ` relation (G-persistence + F-step) holds between consecutive
chain elements. They are NOT useful for proving forward_F across the chain.

---

### Finding 4: The Correct Resolution Is Already in the Codebase

**Key observation**: The project ALREADY has a working sorry-free construction for
`forward_F`:

1. `CanonicalFrame.lean:canonical_forward_F` (lines 139-154): **Proven, no sorry**.
   Uses `temporal_theory_witness_exists` to build a fresh witness for each phi.

2. `CanonicalConstruction.lean:canonical_truth_lemma` (lines 80-91): **Proven, no sorry**.
   The canonical truth lemma uses `forward_F` through `temporal_backward_G`.

3. `CanonicalConstruction.lean:shifted_truth_lemma`: **Proven, no sorry** (based on
   imports and structure).

The sorry chain (f_nesting_is_bounded → succ_chain_forward_F → SuccChainTemporalCoherent)
is ONLY used in `boxClassFamilies_temporally_coherent` (UltrafilterChain.lean:1787-1798),
which feeds `construct_bfmcs` (lines 1810-1834).

**The architectural question**: Does `construct_bfmcs` NEED to use SuccChainFMCS, or
can it use a different family construction that already has forward_F?

---

### Finding 5: Direct Replacement Architecture — Use Canonical Frame Families

**The key insight**: Instead of building `boxClassFamilies` from shifted SuccChain
families (which require sorry for forward_F), build the bundle families using the
**canonical model** approach where forward_F is trivial.

**Concrete proposal**:

The `boxClassFamilies` currently collects all shifted SuccChain families:
```lean
def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :=
  { fam | ∃ W, box_class_agree M0 W ∧ ∃ k, ... fam = shifted_fmcs(SuccChainFMCS W) k }
```

**Alternative**: Build families using the **per-obligation resolving witness approach**:
- For each MCS W in the box class of M0, construct a `TemporalCoherentFamily Int`
  using a chain where each step is built by `temporal_theory_witness_exists`

**Key insight from CanonicalConstruction.lean**: The canonical construction shows that
`forward_F` can be proven trivially when each family step is built by explicit Lindenbaum
extension for the specific obligation. The SuccChainFMCS uses deterministic successor seeds
(deferralDisjunctions), which allow infinite deferral.

---

### Finding 6: Fair-Scheduling Chain — The Correct Technical Solution

**Standard approach** (as mentioned in SuccChainFMCS.lean:50-52 comments): Build a
"fair-scheduling chain" that enumerates F-obligations and forces each one in turn.

**Concrete implementation**:
```
fair_chain(M0, n) builds a sequence where:
- At steps 3k, 3k+1, ..., 3k+m: service the k-th F-obligation from M0
- More precisely: enumerate obligations F(phi_0), F(phi_1), ..., F(phi_i), ...
  and build chain(n) so that at n = 2i+1, phi_i ∈ chain(n)
```

**Why this works**: By Cantor diagonal / enumeration argument, every F-obligation
`F(phi) ∈ chain(k)` for some `k` gets a dedicated step `n > k` where `phi ∈ chain(n)`.

**Implementation complexity**: This requires:
1. A countable enumeration of all F-obligations (formulas are countable)
2. Building the chain using this enumeration
3. Proving that each enumerated obligation is resolved

**Prior art**: This is the "fair chain" construction of Emerson & Clarke (1982) for
temporal logic model checking, and appears in e.g., Manna & Pnueli "Temporal Logic
of Reactive and Concurrent Systems" (1992), Chapter 5.

---

### Finding 7: The Restricted Chain Approach — Status Assessment

Based on examining SuccChainFMCS.lean (lines 2313-2730), the restricted chain approach
has the following status:

**What works**:
- `restricted_forward_chain_F_bounded` (line 2298): PROVEN — F-nesting is bounded in
  DeferralRestrictedMCS. This IS the correct version of f_nesting_is_bounded.
- `restricted_single_step_forcing` (lines 2355-2730): MOSTLY implemented. The Case 2
  (FF(psi) ∈ deferralClosure) is COMPLETE (lines 2376-2484). The Case 1 (FF(psi) ∉
  deferralClosure) hits a fundamental issue: without FF in deferralClosure, the GG(neg psi)
  argument cannot be made, and F(psi) might end up in v (not psi ∈ v).

**The Case 1 fundamental issue** (lines 2486-2730): The theorem claims `psi ∈ v` but
can only prove `psi ∈ v ∨ F(psi) ∈ v`. When FF(psi) ∉ deferralClosure, the GG blocking
argument fails. This is NOT a sorry — it's a genuine mathematical gap where the theorem
as stated may be FALSE for restricted chains.

**Analysis**: If `F(psi) ∈ v` in Case 1, then at `v`, we have `F(psi) ∈ v` and
`FF(psi) ∉ v` (since FF(psi) ∉ dc ⊇ v). The F-step at the next level will again give
`psi ∈ v+1 ∨ F(psi) ∈ v+1`. This produces an indefinite sequence. Eventually `F(psi)`
must land (because the deferral closure is finite), but this requires a different
induction structure than single_step_forcing provides.

**Implication**: The restricted chain approach requires more than just completing
`restricted_single_step_forcing` — it requires restructuring `bounded_witness` for the
restricted case, or proving a weaker "there exists n > k with psi ∈ restricted_chain(n)"
directly by well-founded induction on the deferral depth.

---

## Recommended Approach

### Option A: Canonical Frame Approach (HIGHEST CONFIDENCE — already proven!)

**The most mathematically sound and practically feasible approach** is to use the
canonical model directly:

1. **Use `CanonicalConstruction.lean` infrastructure** which already has sorry-free
   `forward_F` (via `canonical_forward_F`).

2. **Replace `boxClassFamilies_temporally_coherent`** by constructing the bundle
   families using a different FMCS type — one where each step uses
   `temporal_theory_witness_exists` explicitly rather than the deterministic
   `constrained_successor_from_seed`.

3. **Specifically**: Define a new `ResolvingChainFMCS` where:
   - The chain is NOT deterministic (each step creates a fresh witness for ONE obligation)
   - `forward_F` holds by construction: for obligation `F(phi)` at step `n`, the chain
     includes a step `n+1` where `phi ∈ chain(n+1)` by `temporal_theory_witness_exists`

**This is exactly Plan v4, Phase 3 (ResolvingChainFMCS)**. The blocker was thinking
this needed `phi` to appear in the **SAME** family. But the architecture resolves this:
each `ResolvingChainFMCS(M0)` is a fresh family built to satisfy `forward_F` by
construction, and all these families ARE in `boxClassFamilies`.

### Option B: Use Existing CanonicalFrame + CanonicalConstruction (MOST DIRECT)

**Key finding**: `CanonicalConstruction.lean` already has the sorry-free proof!
The canonical truth lemma uses BFMCS families where `forward_F` holds via
`canonical_forward_F`. If `construct_bfmcs` can be rewritten to use
`CanonicalConstruction`-style families (instead of SuccChainFMCS), all sorries
dissolve.

**Action**: Investigate whether `construct_bfmcs` can delegate to the existing
`CanonicalConstruction` theorem. The `CanonicalConstruction` may already prove
`construct_bfmcs` or an equivalent — this needs verification.

**If yes**: The entire sorry chain is bypassed. Phase 3-4 become trivial.

### Option C: Fair-Scheduling Chain (MEDIUM COMPLEXITY, MEDIUM CONFIDENCE)

Build a `fair_resolving_chain` that enumerates F-obligations in a fixed order and
forces each one in turn. This is the standard approach in temporal logic literature.

**Risk**: Lean 4 implementation is complex (requires countable enumeration, decidable
equality, ordinal-indexed construction). Estimated 5-10 hours.

---

## Evidence

| Source | Location | Relevance |
|--------|----------|-----------|
| `CanonicalFrame.canonical_forward_F` | CanonicalFrame.lean:139-154 | PROVEN sorry-free — each F-obligation gets fresh Lindenbaum witness |
| `CanonicalConstruction.canonical_truth_lemma` | CanonicalConstruction.lean:80-91 | PROVEN sorry-free — truth lemma using canonical forward_F |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:1158-1191 | PROVEN — exists W with phi ∈ W, G-agreement, box_class_agree |
| `BFMCS.temporally_coherent` definition | TemporalCoherence.lean:216-219 | Uses forward_F per family (same family constraint) |
| `temporal_backward_G` proof | TemporalCoherence.lean:165-178 | Requires same family for contradiction |
| `restricted_single_step_forcing` Case 1 gap | SuccChainFMCS.lean:2486-2730 | Mathematical gap — cannot force psi ∈ v when FF ∉ dc |
| Blackburn/de Rijke/Venema (2001) | Modal Logic, Ch. 4 | Standard: saturated canonical model has trivial forward_F |
| Emerson & Clarke (1982) | Fair scheduling | Standard: enumeration-based fair chain for LTL |

---

## Confidence Assessment

| Finding | Confidence |
|---------|------------|
| Bundle-level coherence BREAKS temporal_backward_G | **HIGH** — requires same family for contradiction |
| deferralDisjunction insight does NOT eliminate f_nesting_is_bounded | **HIGH** — proven by counterexample in existing code |
| CanonicalFrame already has sorry-free forward_F | **HIGH** — verified in CanonicalFrame.lean:139-154 |
| Restricted chain Case 1 has genuine mathematical gap | **HIGH** — verified by reading SuccChainFMCS.lean:2486-2730 |
| Fair-scheduling chain is the standard literature approach | **HIGH** — well-documented prior art |
| Option B (use existing CanonicalConstruction) might bypass all sorries | **MEDIUM** — needs verification whether construct_bfmcs can delegate there |
| Fair-scheduling chain (Option C) is implementable in Lean 4 | **MEDIUM** — technically feasible but complex |

---

## Summary for Team Lead

**The core blocker** is that `forward_F` requires phi to appear in the SAME family
at a future time, but bundle-level coherence (phi in ANY family) breaks
`temporal_backward_G`.

**The architecturally correct solution** is:

1. **Short-term**: Investigate whether `CanonicalConstruction.lean`'s sorry-free truth
   lemma can directly replace the `construct_bfmcs` sorry chain. The canonical construction
   already proves forward_F trivially via Lindenbaum witness existence.

2. **If not**: Implement `ResolvingChainFMCS` (Plan v4, Phase 3) where each FMCS family
   is built with explicit forward_F by construction — not via deterministic successor seeds.

3. **NOT recommended**: Fixing `restricted_single_step_forcing` Case 1 — the mathematical
   gap is genuine and the proof structure needs redesign at the `bounded_witness` level.

The key prior art insight: **standard completeness proofs use the canonical model
(each F-obligation gets a fresh Lindenbaum witness) rather than a deterministic
successor chain**. This project's `CanonicalConstruction.lean` IS the standard approach
and is already sorry-free. The SuccChainFMCS approach is an additional complexity
that introduces the sorry, not the core of the proof.
