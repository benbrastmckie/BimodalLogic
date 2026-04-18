# Teammate B: Alternative Proof Systems and Literature Survey (Round 38)

**Session**: sess_1776441600_b38alt
**Date**: 2026-04-17
**Artifact**: 38
**Focus**: Alternative proof systems, literature analysis, and strategic recommendations
for closing the remaining sorry sites in the BX completeness proof.

---

## Key Findings

### Finding 1: The Codebase Already Implements the Standard Temporal Logic Approach Correctly

Reading the axiom system in `Axioms.lean` confirms the BX system is a proper implementation
of the Burgess-Xu (1984) / Xu (1988) axiomatization for Until-Since temporal logic over
linear orders. The 37 axioms cover:
- **BX1-BX12 (and mirrors)**: The standard temporal axioms for reflexive Until/Since on
  linear orders including self-accumulation (BX5), absorption (BX6), linearity (BX11), and
  the critical F-Until bridge (BX12).
- **S5 modal layer**: Full S5 (T, 4, B, 5-collapse, K).
- **Interaction axioms**: modal_future and temp_future connecting Box with G.

This is the correct axiom system for the semantics. The proof strategy (canonical model
via MCS, parametric algebraic representation) is standard.

**Implication**: No alternative proof system would be simpler. The current architecture is
the state-of-the-art approach for this logic class. The remaining sorries are implementation
gaps, not design flaws.

### Finding 2: The Eight Sorry Sites Have Two Independent Root Causes

From reading `RootScopedChain.lean` (lines 1413, 1457, 1464, 1517, 1522, 1527, 2196, 2289):

**Root Cause A (5 sorries): Eventuality Resolution**
- `rr_fwd_chain_forward_F` depth-0 base case (line 1413): The core obstruction.
- `dd_fmcs_forward_F` backward branch (line 1457): Downstream of 1413.
- `dd_fmcs_backward_P` (line 1464): The symmetric past analog.
- `defect_fwd_chain_forward_F` (line 2196): Multi-defect forward case.
- `defect_bwd_chain_backward_P` (line 2289): Multi-defect backward case.

**Root Cause B (3 sorries): BFMCS Coherence**
- `dd_bfmcs_restricted_tc` (line 1517): Temporal G/H coherence.
- `dd_bfmcs_restricted_buc` (line 1522): Backward Until/Since coherence.
- `dd_bfmcs_restricted_fuc` (line 1527): Forward Until/Since coherence.

These roots are **independent**: solving Root Cause A does not close Root Cause B and vice
versa. However, both roots share a common infrastructure need: a chain construction that
provably resolves eventualities.

### Finding 3: The Key Infrastructure Is Already Proved -- The Chain Strategy Is Wrong

The most important discovery from the codebase:

**What is proved** (fully sorry-free):
- `self_resolving_fwd_step` (lines 1961-1996): Given `F(psi) in M`, constructs M' with
  `psi in M'`, `F(psi) in M'`, `g_content(M) subset M'`.
- `self_resolving_fwd_step_target` (line 1981): `psi in M'` directly.
- `self_resolving_fwd_step_F_target` (line 1987): `F(psi) in M'` also.
- `self_resolving_fwd_step_g_content` (line 1993): g_content propagated.
- `F_and_self_F_mcs`: `F(psi) in M => F(psi ∧ F(psi)) in M`.

**What is proved for backward** (fully sorry-free):
- `defect_bwd_step` (lines 1717-1764): Given `P(target ∧ guard) in M`, constructs M' with
  `target in M'`, `guard in M'`, `h_content(M) subset M'`.
- `defect_bwd_step_target`, `defect_bwd_step_guard`, `defect_bwd_step_h_content`: All proved.
- `P_and_self_P_mcs`: `P(psi) in M => P(psi ∧ P(psi)) in M` (line 2020 area).

**The problem**: The current `defect_fwd_chain` and `rr_fwd_chain` use `enriched_fwd_step`
(BX11 fold) which only guarantees "some formula resolves at each step" -- not that any
specific formula is ever resolved. The backward chain (`defect_bwd_chain`) uses
`bwd_pred ... Formula.bot` which is ALWAYS non-resolving (P(bot) never in MCS).

**The fix**: Both chains need to switch to deterministic round-robin resolution:
- Forward: Use `self_resolving_fwd_step` cycling through sigma_list.
- Backward: Use `defect_bwd_step` cycling through sigma_list.

### Finding 4: The Literature Supports a Clean Round-Robin Chain Fix

**Burgess (1984), Reynolds (1996), Gabbay-Hodkinson-Reynolds "Temporal Logic: Mathematical
Foundations and Computational Aspects"** all use the same technique for completeness proofs
in temporal logics with Until/Since:

1. Enumerate eventualities using a fixed list (sigma).
2. Build a chain that visits each eventuality in a cyclic round-robin schedule.
3. At step k, resolve eventuality sigma[k mod |sigma|] IF it has an active obligation.
4. Prove that each obligation is resolved within |sigma| steps of becoming active.

This maps exactly to the `self_resolving_fwd_step` infrastructure already proved in the
codebase. The depth-0 base case obstruction (sorry at line 1413) is an artifact of the
WRONG chain construction (BX11 fold) being used.

**Key literature insight**: The perpetual deferral problem (one formula blocking another)
only arises when using existential choice (BX11 fold). Round-robin scheduling deterministically
resolves each formula at its turn, eliminating the deferral cycle entirely.

### Finding 5: Systems WITHOUT Until/Since Would Be Simpler (But Inapplicable Here)

Research question: "Is completeness for G/F/H/P (without U/S) significantly simpler?"

**Answer: Yes, but it's not applicable.**

For tense logic without Until/Since (just G, F, H, P operators), the standard completeness
proof uses simple canonical model + Lindenbaum lemma without any eventuality machinery. The
canonical model is an integer chain where G(phi) propagates forward and H(phi) propagates
backward. No quasimodel, no BX11 fold, no defect-discharge mechanism is needed.

The reason: F(psi) ∈ M at the MCS level directly gives (via the completeness argument) a
"forward successor witness" with psi in it. The chain construction only needs to weave these
witnesses together, which is routine.

For logics with Until/Since, the eventuality resolution step is fundamentally harder because:
- `phi U psi ∈ M` does NOT directly give an MCS chain with `psi` at some point.
- The BX system axioms (BX5-BX12) handle this, but the chain must use resolving steps.

**Strict vs weak temporal operators**: The system uses reflexive semantics (BX1: G(phi) → phi,
BX8: psi → phi U psi). This is the natural choice for Burgess-Xu completeness and simplifies
several axiom interactions. Switching to strict (irreflexive) semantics would complicate BX5,
BX6, BX8 and make the canonical model slightly harder to construct, not easier.

**Combined modal + temporal**: The Box/Diamond modal component is orthogonal to the
Until/Since difficulty. The modal completeness (S5 canonical model) is standard and the
`box_stable_in_int_chain` theorem (CanonicalModel.lean:421) shows Box stability is already
proved. The modal component does NOT contribute to the sorry sites.

### Finding 6: The dd_bfmcs_restricted_tc Sorry (Line 1517) May Be Easiest to Close

`restricted_temporally_coherent root` requires only:
- Forward: `G(phi) in fam.mcs t → phi in fam.mcs t'` for t ≤ t'.
- Backward: `H(phi) in fam.mcs t → phi in fam.mcs t'` for t' ≤ t.

Both follow from the already-proved:
- `dd_chain_g_content` / `dd_bfmcs_fmcs_g_content` (proved)
- `dd_chain_backward_H_helper` (proved)

The sorry at line 1517 may be closable by simply wiring these lemmas together (~50-100 LOC).
This would close one of the three coherence sorries without any new chain construction.

### Finding 7: The Quasimodel Infrastructure Is Not the Primary Bottleneck

From reading `Quasimodel/Construction.lean` and `Quasimodel/HintikkaPoint.lean`:
The quasimodel framework (HintikkaPoint, hintikka_step, SubformulaClosure) provides the
FINITE signature projection needed for the BFMCS coherence proofs. This infrastructure is
largely proved. The bottleneck is the CHAIN level (RootScopedChain.lean), not the quasimodel
level.

**Specifically**: `hintikka_step` (line 45-52 of Construction.lean) correctly captures G/H
propagation and Until-defect tracking. The 3 conjuncts are all necessary. The framework
cannot be simplified without losing coherence.

---

## Literature Analysis

### Burgess (1984) "Basic Tense Logic"

The key completeness technique for tense logic with Since (S) and Until (U) uses:
1. Canonical model via MCS.
2. **Saturated sequences**: The chain is built to be "saturated" -- every F-formula in M
   is eventually witnessed. Burgess achieves this by a careful construction where at step k,
   the k-th formula in the enumeration is resolved IF it has a pending obligation.
3. The "perpetual deferral" problem is blocked by the specific seed construction: the step
   builds an MCS extending `{psi} ∪ g_content(M)` (or symmetric past version), which
   directly places psi in the new MCS.

**Mapping to codebase**: Burgess's step maps to `self_resolving_fwd_step`. The `enriched_fwd_step`
(BX11 fold) is an incorrect adaptation that allows perpetual deferral.

### Reynolds (1996, 2003)

Reynolds uses an explicit **Hintikka-set quasimodel** construction, where:
1. A finite closure set (Sigma) is computed.
2. A chain of Sigma-satisfying states is built with defect discharge.
3. The proof that defects are eventually discharged uses a measure (defect count decreasing).

**Mapping to codebase**: The `Quasimodel/` directory implements exactly this approach.
The `defect_count` measure (Construction.lean:76) is the right measure. The proof would
work IF the chain steps use resolving seeds rather than the BX11 fold.

### Gabbay-Hodkinson-Reynolds "Temporal Logic" (Textbook)

Chapter on tense logic completeness confirms the standard technique:
- **Canonical model construction** for logics without Until/Since: straightforward.
- **For Until/Since**: requires "eventuality satisfaction" which is proved by showing each
  F-formula obligation is witnessed within a bounded number of steps.
- **The bound**: |Sigma| steps (where Sigma is the subformula closure). This corresponds
  exactly to the cycle length of a round-robin schedule over sigma_list.

**No alternative proof system** is identified for this class of logics. Filtration and
mosaic/quasimodel are the only known techniques, and mosaic/quasimodel reduces to the
current approach.

### Venema (1993) "Many-Dimensional Modal Logic"

Notes that for **combined modal + temporal logics**, the completeness proof typically
proceeds by:
1. Proving the modal component first (S5 canonical model).
2. Extending to the temporal component by building a chain PER modal equivalence class.

This is exactly the structure of `BXCanonical`: each FMCS is indexed by a modal class (a
`BXPoint` with its `bx_modal_equiv` relation). The `dd_bfmcs` construction correctly uses
`shifted_dd_fmcs` for each modal class. This confirms the architecture is correct.

**No simplification is available** from the Venema approach: the modal component adds
complexity only in the BFMCS families structure, which is already handled.

---

## Recommended Approach

### Priority 1: Replace Chains With Round-Robin Resolving Chains (Closes 5 Sorries)

**Replace `defect_fwd_chain`** (line 2208 area): Use `self_resolving_fwd_step` cycling
through `sigma_list` instead of `bwd_pred ... Formula.bot`:

```
round_robin_fwd_chain M₀ h₀ sigma_list (n : Nat) :=
  if n = 0 then ⟨M₀, h₀⟩
  else
    let ⟨M, hM⟩ := round_robin_fwd_chain M₀ h₀ sigma_list (n-1)
    let psi := sigma_list.get ⟨(n-1) % sigma_list.length, by omega⟩
    if h_F : Formula.some_future psi ∈ M then
      ⟨self_resolving_fwd_step M hM psi h_F, self_resolving_fwd_step_mcs ...⟩
    else
      ⟨fwd_succ M hM psi, fwd_succ_mcs M hM psi⟩
```

Key properties to prove (all straightforward from proved infrastructure):
- `round_robin_fwd_chain_forward_F`: Given `F(psi) in chain(n)` and `psi in sigma_list`,
  there exists `s > n` with `psi in chain(s)`. **Proof**: F-persistence (`self_resolving_fwd_step_F_target`
  carries `F(psi)` to `psi`'s scheduled visit; at that visit, `self_resolving_fwd_step_target`
  directly gives `psi in chain(s)`). No depth induction or BX11 fold needed.

**Replace `defect_bwd_chain`**: Use symmetric round-robin with `defect_bwd_step`. The
`defect_bwd_step` infrastructure is fully proved (lines 1717-1764).

### Priority 2: Close dd_bfmcs_restricted_tc Directly (Closes 1 Sorry)

The sorry at line 1517 should be closable using only:
- `dd_chain_g_content` (proved)
- The backward H propagation (proved)

Attempt this first as it is the smallest and most isolated sorry.

### Priority 3: Replace dd_bfmcs With a Round-Robin BFMCS (Closes 2 Sorries)

With round-robin chains (Priority 1), the three coherence sorries become:
- `restricted_temporally_coherent`: G/H propagation, already shown closable (Priority 2).
- `restricted_backward_until_since_coherent`: For `phi U psi in chain(t)` with `psi notin t`,
  use forward_F (now proved via round-robin chain) to get `s > t` with `psi in chain(s)`.
  The guard `phi` at intermediate steps follows from Until-propagation via BX5/BX9.
- `restricted_forward_until_since_coherent`: Symmetric for Since.

These close once the round-robin chain is in place.

---

## Confidence Level

| Approach | Confidence | Closes Sorries |
|----------|------------|----------------|
| Round-robin fwd chain replacing `defect_fwd_chain` | HIGH | 1413, 2196 |
| Round-robin fwd chain for dd_fmcs backward branch | HIGH | 1457 |
| Self-resolving backward chain | MEDIUM-HIGH | 1464, 2289 |
| Direct closure of dd_bfmcs_restricted_tc | HIGH | 1517 |
| Coherence proofs using round-robin BFMCS | MEDIUM | 1522, 1527 |

The overall confidence that all 8 sorries can be closed with the round-robin approach is
**MEDIUM-HIGH**. The main risk is the backwards P case (1464, 2289) where the symmetric
`defect_bwd_step` infrastructure exists but has not been exercised in a round-robin chain.

**No alternative proof system** (without U/S, strict semantics, quasimodel-free) would be
simpler or applicable. The current architecture is correct and the remaining work is
implementation: replacing the flawed BX11-fold chain with a deterministic round-robin chain.

---

## Summary for Team Synthesis

The central diagnosis from round 38 is:

1. **The sorry sites are NOT due to missing axioms or wrong architecture.** The BX axiom
   system is correct (Burgess-Xu 1984/Xu 1988). The semantic framework is correct.
   The quasimodel approach is correct.

2. **The sorry sites are due to the wrong chain construction.** The `enriched_fwd_step`
   (BX11 fold) and `defect_bwd_chain` (non-resolving bwd_pred) do not guarantee eventuality
   resolution. The literature-standard fix is a deterministic round-robin resolving chain.

3. **All infrastructure for the fix is already proved.** `self_resolving_fwd_step` (forward)
   and `defect_bwd_step` (backward) are fully proved. Building the round-robin chains from
   these steps is the remaining work.

4. **The modal component (Box/Diamond) does NOT contribute to the remaining sorries** and
   requires no special treatment beyond what is already proved.

5. **The easiest sorry to close independently** is `dd_bfmcs_restricted_tc` (line 1517)
   using only already-proved G/H propagation lemmas.
