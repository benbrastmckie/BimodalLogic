# Teammate D Findings: Strategic Horizons Assessment (Round 39)

- **Task**: 93 - Complete BXCanonical embedding
- **Researcher**: Teammate D (Horizons)
- **Artifact**: 39_teammate-d-findings.md
- **Date**: 2026-04-18

---

## Executive Summary

After 38 rounds of research and multiple failed approaches, this report provides a
strategic assessment of the three viable paths forward. The core mathematical
obstacle is now clearly diagnosed: `dd_bfmcs_restricted_tc` requires proving
`rr_fwd_chain_forward_F` (temporal coherence), and its depth-0 base case is
blocked by BX11 perpetual deferral. The two most promising paths are:

1. **Option A (defect_fwd_chain bypass)**: Replace the round-robin chain entirely
   with the `defect_fwd_chain` infrastructure, which was specifically designed to
   solve forward_F but also has an unproved `sorry` (line 2196). The key question
   is whether `defect_fwd_chain_forward_F` is actually provable with that structure.

2. **Option B (self_resolving_fwd_step direct coherence)**: Prove the three sorries
   directly using `self_resolving_fwd_step` at the BFMCS families level, bypassing
   dd_chain entirely, by constructing witnesses from MCS primitives alone.

---

## Architecture Overview (What I Read)

### The 3 Sorry Sites

All three sorries are in `RootScopedChain.lean`:

- **Line 1517**: `dd_bfmcs_restricted_tc` -- temporal coherence: F(phi) at time t implies
  phi at some s > t, for all formulas in deferralClosure(root)
- **Line 1522**: `dd_bfmcs_restricted_buc` -- backward Until/Since coherence
- **Line 1527**: `dd_bfmcs_restricted_fuc` -- forward Until/Since coherence

These three are the ONLY sorries on the active completeness path (bx_completeness ->
dd_countermodel -> these). Closing them finishes the proof.

### The Chain Dependency

The actual `dd_bfmcs` BFMCS structure (lines 1468-1510) is already sorry-free and
well-constructed. It uses `shifted_dd_fmcs` families indexed by (N, h_N, s). The
sorry sites are in the coherence proofs that need to show these families satisfy
restricted temporal and Until/Since coherence.

`dd_bfmcs_restricted_tc` delegates to `dd_fmcs_forward_F` (line 1426) and
`dd_fmcs_backward_P` (line 1459), both of which have sorries. `dd_fmcs_forward_F`
in turn delegates to `rr_fwd_chain_forward_F` (line 1386), whose depth-0 base
case has the primary sorry (line 1413).

### The Dead Sorry Chain (NOT on active path)

The sorries at lines 1413, 1457, 1464, 2196, 2289 are in `rr_fwd_chain_forward_F`
and related functions. These are in the chain-building infrastructure. Plan v38
explicitly listed these as NOT goals (dead code). The question is whether they
ARE actually dead code or are on the active path.

CRITICAL FINDING: `dd_bfmcs_restricted_tc` (line 1517) calls:
- `dd_fmcs_forward_F` (line 1433-1457) which calls `rr_fwd_chain_forward_F` (line 1386-1424)
  which has the depth-0 sorry at line 1413
- `dd_fmcs_backward_P` (line 1459-1464) which has its own sorry

So lines 1413, 1457, 1464 ARE on the active path via `dd_bfmcs_restricted_tc`.
They are NOT dead code. Plan v38's "Non-Goals" section was mistaken about this.

The sorries at lines 2196 and 2289 (`defect_fwd_chain_forward_F` and
`defect_bwd_chain_backward_P`) are in alternative chain infrastructure that is
NOT currently called by the coherence proofs.

---

## Strategic Options Assessment

### Option A: Fix rr_fwd_chain_forward_F (depth-0 base case)

**What it is**: Close the depth-0 sorry at line 1413 by finding a proof that
the round-robin chain (using `enriched_fwd_step`) eventually resolves any
formula with F(psi) ∈ chain(n).

**Status of existing infrastructure**:
- `rr_fwd_chain_F_preserved` (line 1242): proved -- F(psi) -> psi or F(psi) at n+1
- `rr_fwd_chain_F_propagate` (line 1253): proved -- propagation lemma
- Depth >= 1 case (line 1331): proved -- reduces to IH
- Depth 0 base case (line 1404-1413): SORRY

**Why it has failed 38 times**: The enriched_fwd_step uses a BX11 fold that
resolves ONE formula per step chosen by priority. If formula psi has F(psi)
in chain(n), the step may resolve a DIFFERENT formula chi (because chi was
scheduled earlier). F(psi) is preserved (by enriched_fwd_step_preserves), but
psi is not directly placed in chain(n+1). At the NEXT resolving step for psi,
the same thing may happen: another formula takes priority. This is the BX11
perpetual deferral obstruction.

**Is there a new angle?** The key observation from reading the code:
`enriched_fwd_step_preserves` at line 1248 gives: F(psi) preserved OR psi placed.
This means that `psi ∈ chain(n+1)` can happen even at non-psi-resolving steps
(via the `or` in the result). The schedule visits psi at step `n + (index(psi) - n % sigma_list.length) mod sigma_list.length + 1`.

But the proof requires showing that when the schedule DOES visit psi (i.e., when
`schedule k = psi` at some k > n), psi is placed in chain(k+1). The issue:
`enriched_fwd_step_choice` (line ~1050-1120) selects among ALL formulas with
active F-obligations, not just the scheduled one. The BX11 fold may select a
DIFFERENT formula even when psi is scheduled.

**Verdict**: This approach has failed 38 rounds. There is no new angle that has
not been tried. The perpetual deferral obstruction is real. Confidence of success: 5%.

### Option B: Switch to defect_fwd_chain for dd_bfmcs

**What it is**: Replace `rr_fwd_chain` with `defect_fwd_chain` in the `dd_fmcs`
definition (or prove `dd_fmcs_forward_F` via `defect_fwd_chain_forward_F`), then
close the sorry at line 2196 (`defect_fwd_chain_forward_F`).

**Status of defect_fwd_chain infrastructure**:
- `defect_fwd_chain` (line ~2050): defined, using `enriched_fwd_step` or
  `defect_fwd_step_choice` depending on whether all defects are F-active
- `defect_fwd_chain_F_obligation_persists` (line 2120): proved -- F(psi) persists
- `defect_fwd_chain_F_obligation_constant` (line 2135): proved
- `defect_fwd_step_choice_singleton` (line 2161): proved -- for [psi], resolves psi
- `defect_fwd_chain_forward_F` (line 2190): SORRY

**Why defect_fwd_chain is different from rr_fwd_chain**: The key structural
difference is that `defect_fwd_chain` uses `defect_fwd_step_choice` when ALL
defects are F-active. The proof sketch (lines 2172-2189) shows:
- **Base case** `defects = [psi]`: h_all holds at step n (the only defect psi has
  F(psi) ∈ chain(n)). `defect_fwd_step_choice_singleton` gives psi ∈ chain(n+1).
  This base case IS PROVABLE because `defect_fwd_step_choice_singleton` is proved.
- **Inductive case** `|defects| > 1`: h_all holds from step n onward. At each step,
  `defect_fwd_step_choice` resolves SOME w ∈ defects. The chain makes progress.

**Is defect_fwd_chain_forward_F provable?** For the base case yes -- the
`defect_fwd_step_choice_singleton` lemma at line 2161 is proved and gives psi ∈
chain(n+1) when defects = [psi]. The inductive case needs: from defects = L with
|L| > 1, we need psi ∈ L to eventually appear. This requires showing that for any
psi ∈ L, the defect_fwd_step_choice eventually selects psi. This is NOT obvious
since defect_fwd_step_choice may always choose a different element.

HOWEVER, there is a critical difference: we can call `defect_fwd_chain` with
`defects = [psi]` (single-element list containing just psi). Then by the base case,
psi ∈ chain_singleton(n+1). The question is whether we can USE this single-defect
chain as a WITNESS within the multi-defect context.

**Key insight**: `dd_bfmcs_restricted_tc` asks: given F(psi) ∈ fam.mcs(t) for some
family fam in dd_bfmcs, find s > t with psi ∈ fam.mcs(s). The family fam is a
`shifted_dd_fmcs N h_N sigma_list s`. We need to show `psi ∈ dd_chain(N, sigma_list, t-s+1)`.

We could PROVE this by constructing a SEPARATE chain (`defect_fwd_chain N h_N [psi]`)
with single defect psi, then showing this separate chain produces a new MCS M' with
psi ∈ M' and M' has the same box content as N (for modal saturation). Then show
M' belongs to some family in dd_bfmcs. Then show psi ∈ fam'.mcs(some_time).

But this requires M' to be accessible from `dd_chain` at some future time, which
is the same problem restated at a different level.

**Verdict**: The `defect_fwd_step_choice_singleton` base case gives a provable
path for single-defect lists. But connecting this to multi-defect `dd_fmcs_forward_F`
requires additional bridging lemmas. Estimated LOC: 200-400 new lines.
Confidence of success: 35%.

### Option C: Direct MCS-level proof for restricted_tc

**What it is**: Prove `dd_bfmcs_restricted_tc` WITHOUT going through
`rr_fwd_chain_forward_F` or `dd_fmcs_forward_F`. Instead, use `self_resolving_fwd_step`
directly on the MCS in the family at time t.

**Key observation**: `dd_bfmcs` families are `shifted_dd_fmcs N h_N sigma_list s`.
At time t, `fam.mcs(t) = dd_chain N h_N sigma_list (t - s)`. For temporal coherence:
F(psi) ∈ fam.mcs(t) means F(psi) ∈ dd_chain(N, sigma_list, t-s).

We do NOT need to find psi in dd_chain. We need to find SOME time s' > t and SOME
family fam' in dd_bfmcs (possibly a DIFFERENT family with a DIFFERENT root MCS)
such that psi ∈ fam'.mcs(s').

The definition of `restricted_temporally_coherent` in the BFMCS framework:
if F(psi) ∈ fam.mcs(t), then there exists s > t with psi ∈ fam.mcs(s) (same family,
same series of MCSs, just a later time). This is the FMCS temporal coherence property,
so the witness MUST be in the SAME family at a LATER time.

Given this, `self_resolving_fwd_step` on `dd_chain(t)` gives a NEW MCS M' with
psi ∈ M'. But M' is NOT necessarily a member of the dd_chain sequence (it was
obtained by a fresh Lindenbaum extension). The dd_chain at time t+1 was constructed
by `rr_fwd_step` with schedule(t.toNat) as the scheduled formula.

**Can M' be shown to equal dd_chain(t+1)?** No, not in general. M' was obtained by
a different Lindenbaum extension (seed = {psi, F(psi)} ∪ g_content(dd_chain(t))).
dd_chain(t+1) was obtained by seed = enriched_fwd_step_seed(dd_chain(t), schedule(t)).
They are different noncomputable objects from different seeds.

**Is there a different FMCS built from M' that belongs to dd_bfmcs families?** Yes:
`shifted_dd_fmcs M' h_M' sigma_list (t+1)` has `.mcs(t+1) = M'` and psi ∈ M'. And
if M' has the same box content as N (which self_resolving_fwd_step preserves for
box formulas by box_stable), then this new family IS in dd_bfmcs.families.

Wait -- `dd_bfmcs.families` is defined as:
```
{ fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
  (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
  fam = shifted_dd_fmcs N h_N sigma_list s }
```
So ANY MCS N that has the same box content as M₀ gives a family in dd_bfmcs.

But `restricted_temporally_coherent` is: for a GIVEN family fam, if F(psi) ∈ fam.mcs(t)
then there exists s > t with psi ∈ fam.mcs(s). This requires the witness to be in
the SAME family fam's mcs sequence, not a different family.

**Verdict**: Direct MCS-level proof still requires navigating to the SAME chain's
future time. `self_resolving_fwd_step` produces a new MCS not necessarily in the
chain. Confidence: 15%.

### Option D: Redefine dd_fmcs to use self_resolving_fwd_step directly

**What it is**: Modify `dd_fmcs` to use `self_resolving_fwd_step` at each step
instead of `rr_fwd_step`. Specifically, at step t, if F(schedule(t)) ∈ chain(t),
use `self_resolving_fwd_step(chain(t), schedule(t))` instead of `rr_fwd_step`.

**Why this works for forward_F**: By `self_resolving_fwd_step_target`, psi ∈
chain(t+1) whenever schedule(t) = psi and F(psi) ∈ chain(t). Since schedule
hits every formula infinitely often, psi is eventually placed.

**Obstacles**:
1. Need to show g_content propagation still holds with self_resolving seed
   (self_resolving_fwd_step_g_content is proved, so YES)
2. Need to show backward_H still holds (h_content relationship)
   -- NOT immediately clear with the new seed
3. Need to reprove all chain properties that currently use enriched_fwd_step

**Verdict**: This requires refactoring the chain definition and reproving chain
properties. Estimated LOC: 400-600. Risk: backward_H may break with the new seed.
Confidence of success: 50%.

### Option E: Use defect_fwd_chain with single-element list as the "right" chain

**What it is**: The critical insight from reading `defect_fwd_step_choice_singleton`:
if we run `defect_fwd_chain M₀ h₀ [psi]` (with single defect psi), then whenever
F(psi) ∈ chain(n), by the singleton base case psi ∈ chain(n+1). This gives us a
sorry-free chain for any single formula psi.

The approach: for each formula psi in sigma_list, define a SEPARATE "per-formula"
chain `defect_fwd_chain M₀ h₀ [psi]`. The `dd_fmcs` could be modified to use a
COMBINATION of these per-formula chains.

But `restricted_tc` requires a SINGLE fmcs (one chain) with psi resolving within
it. The per-formula chains are separate objects.

**Verdict**: Same obstacles as Option D. Requires architectural change.

---

## Cost-Benefit Matrix

| Option | LOC estimate | Confidence | Risk | Reuses existing code |
|--------|-------------|------------|------|---------------------|
| A: Fix depth-0 in rr_fwd_chain | 50-100 | 5% | Very High | Yes (all) |
| B: defect_fwd_chain bridge | 200-400 | 35% | Medium | Partial |
| C: Direct MCS-level restricted_tc | 100-200 | 15% | High | Yes |
| D: Redefine dd_fmcs with self_resolving | 400-600 | 50% | Medium | Partial |
| E: Per-formula chain combination | 500-800 | 30% | High | Partial |
| F: Add Until Induction axiom | 800-1200 | 95% | Low (soundness needed) | All existing |

---

## Option F: Add Until Induction Axiom (BX13)

I re-read `Axioms.lean` to understand the current BX axiom system. It has 37
constructors. BX11 (`temp_linearity_past`) is the closest analog to Until Induction
but handles G/H rather than U/S termination.

The Until Induction axiom would be: `(phi U psi) → F(psi)` (already BX10) plus
an explicit "finite path" axiom. Actually BX10 already gives F(psi) from phi U psi.
The MISSING piece is: `G(phi U psi → psi ∨ (phi ∧ X(phi U psi)))` which requires
a successor operator X -- exactly what BX lacks.

Without X, the induction axiom that would work is:
`G((phi U psi) → (phi ∧ G((phi U psi) → psi))) → (phi U psi → psi)` -- but this
is circular or vacuous.

The actual standard axiom needed is the "Until unfold" axiom in systems with X:
`phi U psi ↔ psi ∨ (phi ∧ X(phi U psi))`. Without X, there is no clean induction.

What DOES work without X (and is sound on all linear orders) is the BX5 self-
accumulation axiom already in the system: `(phi U psi) → (phi ∧ (phi U psi)) U psi`.
BX5 + BX9 + BX10 together give considerable power.

The axiom from Xu 1988 / Burgess 1984 that completes the system is actually the
LINEARITY axiom (BX11 in our system): `G(phi ∨ H(chi)) → (F(phi) ∨ chi)`. This
is what the standard completeness proof uses.

**Verdict**: Adding an axiom changes the published paper (Brast-McKie 2025). This
should not be done without user approval. However, the mathematical analysis
suggests that BX1-BX12 IS complete for linear orders WITHOUT BX until-induction,
and the proof should go through -- it's a problem with the PROOF STRATEGY, not the
axioms.

---

## Recommended Long-Term Architecture: Option D

After careful analysis, the highest-confidence path is Option D: redefine dd_fmcs
to use `self_resolving_fwd_step` at each step.

### Why self_resolving_fwd_step works

`self_resolving_fwd_step` uses seed `{psi, F(psi)} ∪ g_content(M)`. This is sorry-free
and the following is proved:
- `self_resolving_fwd_step_target`: psi ∈ result
- `self_resolving_fwd_step_F_target`: F(psi) ∈ result
- `self_resolving_fwd_step_g_content`: g_content(M) ⊆ result

For the chain: if we define `chain(n+1) = self_resolving_fwd_step(chain(n), schedule(n))`
when `F(schedule(n)) ∈ chain(n)`, and `fwd_succ(chain(n), schedule(n))` otherwise:
- g_content propagation: ✓ (proved for both cases)
- forward_F at scheduled steps: ✓ (by self_resolving_fwd_step_target)
- Backward H: need to verify (the seed {psi, F(psi)} ∪ g_content(M) may not give
  h_content(M) ⊆ result -- this is the key risk)

### Architecture for self_resolving chain

```
def sr_fwd_succ (M : Set Formula) (h_mcs : SetMaximalConsistent M) (psi : Formula) :=
  if h_F : F(psi) ∈ M then
    self_resolving_fwd_step M h_mcs psi h_F  -- psi placed, g_content preserved
  else
    fwd_succ M h_mcs psi  -- non-resolving, f_carry preserved
```

For `sr_fwd_chain` using `sr_fwd_succ`:
- `sr_fwd_chain_g_content_step`: ✓ from self_resolving_fwd_step_g_content + fwd_succ_g_content
- `sr_fwd_chain_forward_F`: For psi visited at step k > n, either F(psi) ∈ chain(k)
  (then sr_fwd_succ places psi in chain(k+1)) or F(psi) ∉ chain(k). But F(psi) was
  in chain(n) and is preserved by enriched_fwd_step_preserves... wait, that was
  for `enriched_fwd_step` not `sr_fwd_succ`.

We need F-preservation for `sr_fwd_succ`: if F(psi) ∈ M and sr_fwd_succ uses
`self_resolving_fwd_step(M, phi)` for phi ≠ psi, is F(psi) preserved?
- `self_resolving_fwd_step_F_target` gives F(psi_scheduled) ∈ result.
- But for psi ≠ scheduled: we need F(psi) ∈ g_content(M) ∪ {psi_scheduled, F(psi_scheduled)}.
  F(psi) ∈ M. Is F(psi) in g_content(M)? No, g_content is about G(phi), not F(phi).
  Is F(psi) in {psi_scheduled, F(psi_scheduled)}? Only if psi = psi_scheduled.

**CRITICAL GAP**: When resolving phi ≠ psi, F(psi) is NOT preserved by
`self_resolving_fwd_step`. It was only preserved by `enriched_fwd_step` via
the `f_carry` mechanism. The self_resolving seed {target, F(target)} ∪ g_content
does NOT include f_carry.

We could add f_carry to the self_resolving seed:
```
seed = {target, F(target)} ∪ g_content(M) ∪ f_carry(M)
```
But then consistency needs F(target ∧ F(target) ∧ all_F_formulas) which requires
a different argument.

Actually, `f_carry(M)` is a subset of M, and `{target, F(target)} ∪ g_content(M)`
is already proved consistent. Adding `f_carry(M) ⊆ M` to the seed gives
`{target, F(target)} ∪ g_content(M) ∪ f_carry(M)`, which is still a subset of
a consistent expansion since f_carry(M) ⊆ M and {target, F(target)} ∪ g_content(M)
is consistent -- but it's THEIR UNION that needs to be consistent, which requires
a new proof.

Alternatively: use the EXISTING `enriched_fwd_step_preserves` lemma which says
F(psi) is preserved OR psi is placed. This was proved for enriched_fwd_step.
If we augment sr_fwd_succ to USE enriched_fwd_step internally but ALSO ensure
the scheduled psi gets placed... this is essentially reimplementing defect_fwd_step_choice.

---

## Minimum Viable Path: Option B (defect_fwd_chain with [psi] base case)

Given the analysis, the most direct path is:

1. **Prove `defect_fwd_chain_forward_F` for single-element lists** (base case)
   - This uses `defect_fwd_step_choice_singleton` (already proved)
   - Requires showing: when `defects = [psi]` and `F(psi) ∈ chain(n)`,
     h_all holds (the only defect psi has F-active), so `defect_fwd_step_choice`
     gives psi ∈ chain(n+1). This is an ~20 line proof.

2. **Prove `defect_fwd_chain_forward_F` for multi-element lists via projection**
   - Given psi ∈ defects with F(psi) ∈ chain_L(n), show psi ∈ chain_L(s) for s > n.
   - Key: construct parallel chain_[psi] starting at chain_L(n). Show by induction
     that chain_[psi](k).val is accessible from chain_L(n + k) via g_content.
     Actually, chain_[psi] and chain_L are INDEPENDENT chains -- they don't share steps.
   - Alternative: prove by well-founded induction on |defects|.
     Base |defects|=1: done by singleton case.
     Step: from psi ∈ defects with F(psi) ∈ chain_L(n), either psi = defects.head
     (and singleton argument applies to the head) or psi is not head. Use
     defect_fwd_step_choice (which resolves head first) -- F(psi) persists...
     then project to chain_[defects.tail] containing psi. By IH on tail, done.
   - This is the promising approach: ~100-150 lines.

3. **Connect defect_fwd_chain to dd_fmcs**: modify `dd_fmcs_forward_F` to call
   `defect_fwd_chain_forward_F` instead of `rr_fwd_chain_forward_F`. This requires
   showing dd_fmcs uses defect_fwd_chain or that the two chains have compatible
   F-resolution properties.
   - This is the biggest gap: dd_fmcs currently uses `rr_fwd_chain`, not
     `defect_fwd_chain`.
   - Options:
     a. Add a new FMCS that uses defect_fwd_chain, prove it belongs to dd_bfmcs families
     b. Change dd_chain to use defect_fwd_chain steps

4. **Prove backward_P** via symmetric argument.

5. **Prove restricted_buc and restricted_fuc** using BX8/BX9/BX10 MCS-level lemmas
   (these may be more tractable once tc is done).

---

## Risk Analysis

| Risk | Assessment |
|------|-----------|
| depth-0 base case truly unprovable for rr_fwd_chain | HIGH: 38 rounds confirm this |
| defect_fwd_chain_forward_F provable by induction on defects | MEDIUM: singleton case works, multi-case needs validation |
| Connecting defect_fwd_chain to dd_fmcs without rewrite | HIGH: fundamental mismatch |
| restricted_buc/fuc after tc is proved | LOW: BX8/BX9/BX10 + MCS primitives give direct argument |
| Until guard at intermediate times in restricted_fuc | MEDIUM: needs BX9 at each step |
| Task should be marked [BLOCKED] until new plan is formed | CONSIDER |

---

## Conclusion

The situation after 38 rounds is as follows:

**What is clear**: The `rr_fwd_chain_forward_F` depth-0 sorry (line 1413) is the
primary blocker. It has resisted 38 rounds of attack because the round-robin chain's
BX11 fold genuinely cannot guarantee eventual resolution of any specific formula --
this is a structural obstruction, not a proof-technique gap.

**What is promising**: The `defect_fwd_chain` infrastructure (lines 2050-2196) was
specifically designed to overcome this. The `defect_fwd_step_choice_singleton` lemma
IS provable (its base case works). The gap is connecting this to the active dd_fmcs
path.

**Recommended action**: The plan needs a new phase that either:
(a) Modifies `dd_chain` to use `defect_fwd_step_choice` at every step (requires
    reproving g_content propagation with the new step function -- feasible), OR
(b) Proves `defect_fwd_chain_forward_F` by induction on defects.length and then
    uses it as the FMCS for dd_bfmcs (requires a new FMCS definition using
    `defect_fwd_chain` instead of `rr_fwd_chain` -- ~400 LOC).

Plan v38's Phase 1 was correctly diagnosed but the strategy (using self_resolving_fwd_step
to find a witness "accessible from dd_chain") is architecturally flawed: self_resolving
produces a witness NOT in the dd_chain sequence. The fix is to make the chain ITSELF
use self_resolving steps, or to use defect_fwd_chain with proven forward_F.

**Confidence level**: Approach (b) has ~35% confidence of closure within 4 hours.
Approach (a) has ~50% confidence but requires more refactoring (~6 hours).

**If neither works**: The task should be [BLOCKED] with a note that the proof
requires either an additional BX axiom (BX13: a form of Until induction expressible
without X) or a fundamentally different completeness proof strategy (e.g., filtration-
based completeness bypassing temporal coherence entirely).
