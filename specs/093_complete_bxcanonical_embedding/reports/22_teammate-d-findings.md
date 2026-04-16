# Teammate D Findings: Round 22 — Strategic Horizons

## Key Findings

### 1. The Architecture Is Sound and BXCanonical Is the Right Approach

After reviewing 21 research rounds, all known alternatives, and the full dependency chain from
`bx_completeness` down to the 6 sorry sites, the conclusion is clear: **BXCanonical is the
correct architecture and should not be abandoned**.

Evidence supporting this conclusion:

- 6,400+ lines of sorry-free infrastructure across 13+ files — not throwaway work
- The Until/Since subproblem (analogous in difficulty) was fully solved in tasks 98+102
- The quasimodel/filtration infrastructure is reusable exactly for the remaining buc/fuc sorries
- All documented alternatives (tree unraveling, quasimodel overlay, BX12 reformulation,
  filtration FMP shortcut, dovetailing at BFMCS level) were correctly ruled out and the
  ruling-out rationale is sound

The project constraint — "only the algebraic/canonical model approach is pursued" — is correct
from a scientific standpoint. The canonical model IS the scientific contribution. Abandoning it
would mean abandoning the theorem, not finding a shortcut to it.

### 2. The Dependency Graph Has Shifted Since Round 21

Round 21 synthesis and Summary 21 conflict on a critical dependency claim. This round's analysis
confirms the Summary 21 position is correct:

**ALL 6 sorries depend on forward_F (directly or transitively).**

The dependency chain:

```
rr_fwd_chain_forward_F (line 1295) — PRIMARY BLOCKER
    |
    +-- dd_fmcs_forward_F (line 1326, t<0 case) — depends on forward_F
    |
    +-- dd_fmcs_backward_P (line 1333) — symmetric primary blocker
    |
    +-- dd_bfmcs_restricted_tc (line 1386) — directly requires forward_F + backward_P
    |
    +-- dd_bfmcs_restricted_fuc (line 1396) — reduces to forward_F via BX10
    |
    +-- dd_bfmcs_restricted_buc (line 1391) — requires step transfer (same gap)
```

**On restricted_fuc**: `(phi U psi) in chain(t)` implies via BX10 that `F(psi) in chain(t)`.
Proving existence of `s >= t` with `psi in chain(s)` IS the forward_F problem for the dd_chain.
The quasimodel `bx_until_eventuality_resolution` gives a BXPoint witness, but there is no bridge
from BXPoint indices to dd_chain integer indices.

**On restricted_buc**: Backward Until coherence requires the step transfer property:
`(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)` implies `(phi U psi) in fam.mcs(r)`.
`UntilSinceCoherence.lean` line 27-28 explicitly states this is NOT derivable from the bare
FMCS structure. The dd_chain's enriched_fwd_step only guarantees h_content propagation backward,
but Until is not an H-formula. BX4' gives only `F(phi U psi) in chain(r)`, not
`(phi U psi) in chain(r)`.

**Confidence**: High (90%) that buc/fuc do NOT close independently of forward_F. The Round 21
synthesis was overly optimistic on this point (85% confidence for independence was wrong).

### 3. The Fundamental Obstruction Is the Non-Deterministic Lindenbaum Extension

The single root cause of all 6 sorries is this:

At a resolving step for formula `chi`, the seed is:
```
{chi} ∪ g_content(M) ∪ (BX11 fold compounds)
```

This seed does NOT include F-formulas for other defects. The Lindenbaum extension `.choose`
is unconstrained and may select a maximal extension containing `G(neg(psi))` for any
`F(psi) in M` with `psi != chi`. Once `G(neg(psi))` enters the chain, `F(psi)` is
permanently lost (G persists via temp_4).

The "correct approach" comment at RootScopedChain.lean:1274-1288 correctly identifies the fix:
prove consistency of `{target} ∪ g_content(M) ∪ f_carry(M)`. The comment acknowledges this
requires a novel argument for F-formula/G-formula seed interaction.

### 4. The Never-Resolved Count Termination Argument Is Correct and Is the Only Sound Path

Plan v18's "never-resolved count" approach is the correct mathematical path. Analysis:

**Why the count is well-founded**:
- Let sigma_list have length N
- Define `never_resolved(n)` = number of formulas in sigma_list that have NEVER appeared
  in any chain step `chain(0),...,chain(n)`
- `never_resolved(0) <= N` (bounded)
- When formula `psi` is first resolved at step `s` (i.e., `psi in chain(s)` but `psi not in
  chain(k)` for all `k < s`): `never_resolved(s) < never_resolved(s-1)` (strictly decreasing)
- `never_resolved(n) >= 0` always (bounded below)
- The count CANNOT increase: once a formula appears in some chain step, it is "resolved" forever

**Why this solves forward_F**:
- If `F(psi) in chain(n)` with `psi in sigma_list`, then either:
  (a) `psi` has already been resolved at some `s <= n` (then `psi in chain(s)`)
  (b) `psi` is in `never_resolved` set — will be resolved at some future visit step
- At psi's next visit step after n, psi is guaranteed to be resolved because:
  - The chain targets psi at that step (round-robin schedule)
  - The seed includes `{psi} ∪ g_content(chain(n))` which is consistent (proved by
    `forward_temporal_witness_seed_consistent`)
  - The Lindenbaum extension CAN choose psi in M' (consistency is sufficient for existence)
  - But we need to CONTROL the choice, not just have existence

**The remaining gap**: The chain must be re-defined to FORCE psi into the seed at its visit
step. Currently `enriched_fwd_step` uses BX11 fold which gives psi OR F(psi). The fix is
`discharge_single_step` which guarantees psi in M', but does NOT preserve other F-obligations.
The two-phase approach (resolve psi, then recover F-obligations at next step via phi_in_mcs_imp_F_phi)
is the standard way around this, but requires the never-resolved count to track which formulas
have been definitively resolved.

### 5. Minimal Change That Could Unblock Progress

The MINIMAL change to unblock `rr_fwd_chain_forward_F` is:

**Replace `enriched_fwd_step` with `target_resolving_fwd_step`** that:
1. Uses `discharge_single_step` to guarantee `target in M'` (not the BX11 fold)
2. Records the first resolution time of each formula in sigma_list
3. At non-target steps, recovers F-obligations via `phi_in_mcs_imp_F_phi`

The key invariant: `for all psi in sigma_list, F(psi) in chain(n) iff F(psi) in chain(0)`
(F-obligation constancy, proved as `rr_fwd_chain_F_obligation_forward/backward`). This is
already proved sorry-free and remains valid for any chain that preserves g_content.

With this change, forward_F follows by: F(psi) in chain(n) → F(psi) in chain(0) (by backward
constancy) → F(psi) held at start → psi is in never-resolved set initially → psi is resolved
at its first visit step `s` → psi in chain(s) → s > n (can be shown by the visit schedule).

The "s > n" part requires showing that psi's first resolution happens strictly after step n.
Since F-obligations are exactly those present in chain(0) (by constancy), and the round-robin
schedule visits psi at step j, 2j, 3j, ... (multiples of its index), the first visit after n
is at `n + (j - n mod j)` which is > n.

**Estimated effort**: 15-20 hours to replace enriched_fwd_step and re-prove ~30 downstream
theorems. This is the lower bound from Report 18, based on mechanical re-proofs with similar
signatures.

### 6. The CanonicalModel.lean Sorries Are Dead Code and Should Be Deleted

CanonicalModel.lean has 5 sorry sites that are NOT on the active completeness path:
- `bx_fmcs_forward_F` (line 518) — DEAD CODE
- `bx_fmcs_backward_P` (line 525) — DEAD CODE
- `bx_bfmcs_buc` (line 614) — DEAD CODE
- `bx_bfmcs_fuc` (line 619) — DEAD CODE
- `bx_bfmcs_restricted_buc/fuc` (lines 649, 655) — DEAD CODE

The `Completeness.lean` calls `dd_countermodel` from `RootScopedChain.lean`, which calls
`dd_bfmcs`, not `bx_bfmcs`. The `bx_countermodel` in CanonicalModel.lean is parallel dead code.

**Strategic recommendation**: Delete `bx_bfmcs` and its sorry-laden coherence theorems from
CanonicalModel.lean, or mark them with explicit `-- DEAD CODE` comments and `sorry` without
guilt. This reduces the apparent sorry count by 5 and clarifies the true scope of the problem.

### 7. The Architecture Cannot Be Simplified Further

Several "creative" alternatives were considered and dismissed:

**Could we reduce bimodal to separate modal + temporal?**: No. The TM logic combines S5
(reflexive, symmetric, transitive, euclidean) modal with LTL temporal. They interact through
the task-world structure (diamond/box operate over world histories). The bimodal interaction is
essential to the semantics.

**Could completeness be proved via detour through another logic?**: No. The project's constraint
is the canonical model approach via the parametric algebraic representation theorem. Any detour
through another logic would bypass this theorem and defeat the scientific purpose.

**Could we use a different chain construction (e.g., quasimodel directly)?**: Not without a
bridge from HintikkaPoints to BXPoints. `Realization.lean` provides this bridge only for
Until/Since witnesses (BXPoint-level), not for the F/P forward_F obligation (which needs
integer chain indices).

**Could we avoid the integer chain entirely?**: The parametric representation theorem
(`ParametricRepresentation.lean`) requires an FMCS over an ordered group, and BFMCS requires
families of these. The integer chain IS the FMCS. Replacing it would require a different FMCS
construction with the same properties.

## Recommended Approach

**Phase 0 (1-2 hours): Clean up dead code in CanonicalModel.lean**

Mark `bx_bfmcs` and its sorry-laden coherence theorems as dead code. This clarifies that the
true problem is 6 sorries in RootScopedChain.lean, not 11 sorries across two files. Reduces
cognitive load.

**Phase 1 (15-25 hours): Plan v18 — Replace enriched_fwd_step with target_resolving_fwd_step**

This is the only sound path. Steps:

1. Define `target_resolving_fwd_step` using `discharge_single_step` (guarantees target in M')
2. Define `never_resolved_count` as a measure on chain steps
3. Prove `never_resolved_count` is a valid well-founded decreasing measure
4. Replace `rr_fwd_chain` with a new chain parameterized by target-resolving steps
5. Re-prove the ~30 downstream theorems (g_content, F-preservation, etc.)
6. Prove `rr_fwd_chain_forward_F` via well-founded induction on never_resolved_count
7. Close dd_fmcs_forward_F (t>=0 case follows directly; t<0 case via G-preservation bridge)
8. Close dd_fmcs_backward_P (symmetric construction)
9. Close dd_bfmcs_restricted_tc (follows from forward_F + backward_P)

**Phase 2 (10-15 hours): Close restricted_buc and restricted_fuc**

These require step transfer for backward Until. The step transfer IS provable if the chain seed
includes defective Until formulas from sigma_list. After Phase 1's chain replacement, the new
chain construction can be further enriched:

- At each step, include `{(alpha U beta) in sigma_list | (alpha U beta) in chain(r), beta not in chain(r)}`
  in the seed
- Consistency of this enriched seed: all included Until formulas are in `chain(r)` (a consistent
  MCS), and the target is consistent with `g_content(chain(r))` by `forward_temporal_witness_seed_consistent`
- The inconsistency only arises from the TARGET interacting with the Until formulas; but Until
  formulas are in `chain(r)` and the seed only contains the subset of `chain(r)` that is safe
- With Until formulas in the seed, step transfer follows: `(phi U psi) in chain(r+1)` means
  `(phi U psi)` was included in the seed for step `r+1` because it was a defect at step `r`
  (or psi was resolved at step r+1, which also gives the backward Until property via BX8)

**Total estimate**: 25-40 hours.

## Evidence and Examples

**Evidence for buc/fuc dependency on forward_F** (Summary 21, p. 1-2):
> "restricted_fuc (line 1396): Forward Until/Since coherence requires, given (phi U psi) in fam.mcs t,
> finding s >= t with psi in fam.mcs s. By BX10, (phi U psi) -> F(psi), so this reduces directly
> to the forward_F problem for psi along the chain."

**Evidence for step transfer non-derivability** (UntilSinceCoherence.lean:27-28):
> "The step transfer is NOT derivable from the bare FMCS structure (forward_G, backward_H)."

**Evidence for never-resolved count well-foundedness** (RootScopedChain.lean:1265-1272):
> "F-obligation set {chi ∈ sigma_list | F(chi) ∈ chain(m)} is STABLE: it never grows
> (by no_new_f_defects) and never shrinks (because chi ∈ M → F(chi) ∈ M for any MCS M)"

The F-obligation constancy property (already proved sorry-free) is the key: the set of sigma_list
formulas with F-obligations is EXACTLY the same at every chain step. This means:
- Every formula that ever gains an F-obligation has it from step 0
- "Never-resolved" just means "not yet appeared in any chain step"
- First resolution is guaranteed by the round-robin schedule + discharge_single_step

**The key infrastructure already proved sorry-free**:
- `discharge_single_step`: guarantees target ∈ M' (RootScopedChain.lean:~975)
- `rr_fwd_chain_F_obligation_forward`: F(psi) ∈ chain(n) implies F(psi) ∈ chain(m) for m≥n
- `rr_fwd_chain_F_obligation_backward`: F(psi) ∈ chain(m) implies F(psi) ∈ chain(n) for n≤m
- `enriched_resolving_seed_consistent`: {psi, alpha} ∪ g_content(M) consistent when F(psi ∧ alpha) ∈ M
- `forward_temporal_witness_seed_consistent`: {psi} ∪ g_content(M) consistent when F(psi) ∈ M

## Confidence Level

**High (90%)** on the diagnosis: the fundamental obstruction is the non-deterministic Lindenbaum
extension, and all 6 sorries depend on it directly or transitively.

**High (90%)** on the recommended approach: Plan v18 (target-resolving chain with never-resolved
count) is the correct mathematical path. The well-foundedness argument is sound; the formalization
is hard but tractable.

**Medium-Low (40%)** on buc/fuc closing independently of forward_F. The Round 21 synthesis was
optimistic; the Summary 21 correctly revised this downward. Independent closure requires step
transfer, which in turn requires enriched seeds that include Until formulas — this is an
additional complexity that must be stacked on top of the Phase 1 chain replacement.

**Medium (55%)** on the 25-40 hour estimate. The re-proof cost is the main uncertainty. Each
replaced definition cascades to ~30 theorems with similar-but-not-identical proofs. The
sorry-free infrastructure is extensive and well-organized, which reduces (but does not eliminate)
the re-proof burden.

**Low (15%)** that any architectural alternative is viable. The BXCanonical approach is correct.
The chain-based FMCS is necessary. The only open question is which chain construction to use.
