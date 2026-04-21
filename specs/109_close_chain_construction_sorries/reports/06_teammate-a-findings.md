# Teammate A: Sigma-Restricted Defect Tracking — Deep Analysis

**Date**: 2026-04-20
**Assignment**: Deep analysis of the Sigma-restricted defect tracking approach for closing `fwd_chain_forward_F`
**Confidence Level**: Medium (see Confidence section for detailed breakdown)

---

## Summary

This report provides a rigorous mathematical analysis of the Sigma-restricted defect tracking approach
as a candidate solution for `fwd_chain_forward_F` (the keystone sorry for `bx_completeness`).

The core idea — tracking defects within the finite Sigma closure so that `phi ∈ M' ∩ Sigma`
definitively clears the defect regardless of `F(phi)` — is **mathematically sound** and avoids
the Lindenbaum opacity problem. However, translating this idea into Lean 4 requires a clean
architectural choice: either (A) instrument the existing `fwd_chain_of_sigma` with Sigma-level
defect bookkeeping and a well-founded recursion driver, or (B) directly use the already-proved
`hintikka_chain_exists` quasimodel machinery (which solves exactly this problem) and build a
lift from HintikkaRawChain to dd_chain indices.

Path (A) is the focus of this report. Path (B) (quasimodel bridge) has a critical blocker at the
Until-propagation gap (identified in prior research, termed Gap G3) and is not analyzed here.

**The fundamental insight**: The Lindenbaum opacity problem only bites when we track defects
as `{chi | F(chi) ∈ M}`. The opacity is: resolving `chi` (putting `chi ∈ M'`) doesn't remove
`F(chi)` from `M'`. But if we track defects as `{chi ∈ Sigma | F(chi) ∈ M ∧ chi ∉ M}`, then
once `chi ∈ M'` and `chi ∈ Sigma`, the defect is definitively cleared from the Sigma-restricted
set — independently of whether `F(chi) ∈ M'`. This is the key property.

The mathematical machinery (defect_count, untilDefectSet, hintikka_step_target_decrease) is
already in `Construction.lean` at the Hintikka point level. The challenge is adapting it to
work at the MCS level within `fwd_chain_of_sigma`.

**Bottom line**: A complete implementation is achievable in approximately 400-600 lines of Lean 4
over 8-14 hours. The primary unknowns are (1) the `defect_mono` hypothesis needed at each chain
step, and (2) whether `preserving_fwd_step` can be instrumented to provide descent guarantees.

---

## Key Findings

### 1. What the Current Construction Does and Why It Fails

The current `fwd_chain_of_sigma` uses `preserving_fwd_step` at each step:

```lean
private noncomputable def fwd_chain_of_sigma (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwd_chain_of_sigma M₀ h₀ sigma_list n
    ⟨preserving_fwd_step M hM sigma_list n,
     preserving_fwd_step_mcs M hM sigma_list n⟩
```

`preserving_fwd_step` calls `defect_step_choice_early` when active defects exist. The spec of
`defect_step_choice_early` guarantees:
1. `SetMaximalConsistent M'` — the extension is an MCS
2. `g_content M ⊆ M'` — G-content propagates
3. `∃ w ∈ defects, F(w) ∈ M ∧ w ∈ M'` — SOME defect is directly resolved
4. `∀ chi ∈ defects, chi ∈ M' ∨ F(chi) ∈ M'` — all defects preserved (but disjunctively)

The proof of `fwd_chain_forward_F` needs: given `F(phi) ∈ chain(n)`, find `m > n` with
`phi ∈ chain(m)`. The problem:

- Guarantee (3) doesn't name which defect `w` gets resolved — it could always be `chi ≠ phi`.
- Guarantee (4) says `phi ∈ M' ∨ F(phi) ∈ M'`. If `F(phi) ∈ M'`, then phi is still a defect
  at step n+1.
- The Lindenbaum extension is opaque: even when `phi ∈ M'` (phi was "w" in guarantee 3),
  the extension can independently include `F(phi) ∈ M'` without contradiction.
  Under irreflexive semantics, `phi(t) ∧ F(phi)(t)` is consistent: phi holds at t and at
  some later t' > t.

So the F-defect set `{chi | F(chi) ∈ chain(k)}` can stabilize: at every step some chi is
resolved (chi ∈ chain(k+1)) but re-acquires F(chi) ∈ chain(k+1) via the Lindenbaum extension.

### 2. The Sigma-Restricted Defect Set: Definition and Key Property

**Definition (Sigma-restricted defect set)**:
```
sigma_F_defects(M, Sigma) := {chi ∈ Sigma | F(chi) ∈ M ∧ chi ∉ M}
```

**Key property**: `chi ∈ M'` AND `chi ∈ Sigma` → `chi ∉ sigma_F_defects(M', Sigma)`.

Proof: `sigma_F_defects(M', Sigma)` excludes formulas where `chi ∈ M'`. So regardless of
whether `F(chi) ∈ M'`, the formula `chi` is not a Sigma-restricted defect at `M'`.

This is the fundamental difference from the raw F-defect set `{chi | F(chi) ∈ M}`. When we
track `{chi ∈ Sigma | F(chi) ∈ M ∧ chi ∉ M}`, direct resolution (`chi ∈ M'`) definitively
clears the defect.

**Monotonicity**: We need `sigma_F_defects(M', Sigma) ⊆ sigma_F_defects(M, Sigma)` at each
chain step. This requires:
- `chi ∈ Sigma ∧ F(chi) ∈ M' ∧ chi ∉ M'` → `chi ∈ Sigma ∧ F(chi) ∈ M ∧ chi ∉ M`

The first condition (`chi ∈ Sigma`) is trivially preserved. The third (`chi ∉ M` needed from
`chi ∉ M'`) follows from `g_content(M) ⊆ M'` only if we can argue that `chi ∉ M'` implies
`chi ∉ M` — but this is backwards! We need `chi ∉ M` from `chi ∉ M'`, which fails in general
(M' is a Lindenbaum extension of a subset of M).

Wait — this is the critical subtlety. Let me re-examine.

We need the Sigma-restricted defect set to be **non-increasing** along the chain. That is, if
`chi` is resolved at step `n` (chi ∈ chain(n+1)), it should NOT reappear as a Sigma-defect at
later steps.

**Revised analysis**: Once `chi ∈ chain(k)` for some `k`, does `chi ∈ chain(k+1)` need to hold?
NO — the chain is a sequence of Lindenbaum extensions, not a direct inclusion chain. `chi ∈ chain(k)`
does NOT imply `chi ∈ chain(k+1)`. So the defect could reappear!

However, there IS a monotonicity argument using `fwd_chain_F_obligation_monotone`:

**Theorem** (already proved as `fwd_chain_F_obligation_monotone`):
If `F(chi) ∉ chain(n)`, then `F(chi) ∉ chain(m)` for all `m ≥ n`.

This is the DUAL of what we need. It says F-obligations, once gone, never return. But we need
the Sigma-restricted defect set to be non-increasing in the forward direction.

**Correct monotonicity claim**:
`sigma_F_defects(chain(n+1), Sigma) ⊆ sigma_F_defects(chain(n), Sigma)`

i.e., if `chi ∈ Sigma ∧ F(chi) ∈ chain(n+1) ∧ chi ∉ chain(n+1)`, then
`chi ∈ Sigma ∧ F(chi) ∈ chain(n) ∧ chi ∉ chain(n)`.

The `F(chi) ∈ chain(n)` part: follows from `fwd_chain_F_set_nonincreasing` (already proved):
`F(chi) ∈ chain(n+1)` implies `F(chi) ∈ chain(n)` (F-obligations only decrease forward,
so going backward from n+1 to n, they can only be present or absent, and absent at n+1
means absent at n by monotonicity — but we're asking: if present at n+1, is it present at n?
This is the WRONG direction again).

I need to re-examine `fwd_chain_F_set_nonincreasing`:
```lean
theorem fwd_chain_F_set_nonincreasing ... (n m : Nat) (h_le : n ≤ m)
    (h_F : F(chi) ∈ chain(m)) : F(chi) ∈ chain(n)
```

YES — this says if `F(chi) ∈ chain(m)` (later step) then `F(chi) ∈ chain(n)` (earlier step,
provided `n ≤ m`). So: `F(chi) ∈ chain(n+1)` → `F(chi) ∈ chain(n)`. This IS the direction
we need for the `F(chi)` component of monotonicity.

The `chi ∉ chain(n)` part: we need `chi ∉ chain(n+1)` → `chi ∉ chain(n)`. This fails in
general. It's conceivable that `chi ∈ chain(n)` but the Lindenbaum extension drops chi at
chain(n+1).

**CONCLUSION**: The Sigma-restricted defect set is NOT automatically monotone. We need
`chi ∉ chain(n+1)` → `chi ∉ chain(n)` for the direct-presence component. This is false.

So simple non-decreasingness of sigma_F_defects fails. A different approach is needed.

### 3. The Correct Sigma-Restricted Descent Argument

The correct argument is not about monotonicity of the full Sigma-restricted defect set, but
about a well-founded relation on the **pair** (sigma_F_defect_count, step).

**Revised approach**: Instead of tracking `sigma_F_defects(chain(n), Sigma)` and requiring it
to decrease, we track the following invariant:

Given `F(phi) ∈ chain(n)` and `phi ∈ Sigma`, define:
```
pending(n) := |sigma_F_defects(chain(n), Sigma)|
           = |{chi ∈ Sigma | F(chi) ∈ chain(n) ∧ chi ∉ chain(n)}|
```

We want to show that `phi` is eventually directly in the chain. The argument:

**Step 1**: If `pending(n) = 0`, then `phi ∉ sigma_F_defects(chain(n), Sigma)`, but `F(phi) ∈ chain(n)`,
so `phi ∈ chain(n)` (since otherwise phi would be in sigma_F_defects which is empty). But we
assumed `F(phi) ∈ chain(n)` and want `phi ∈ chain(m)` for some m > n. If `phi ∈ chain(n)` that
doesn't give us the STRICT inequality m > n.

This is a problem. We need m > n strictly. Under irreflexive semantics, `F(phi)` requires a
FUTURE witness, so the point of resolution must be strictly later.

**Step 2**: Actually, by `fwd_chain_F_obligation_monotone`, if `F(phi) ∈ chain(n)` then `F(phi) ∈ chain(k)` for all k ≤ n.

Wait, that's the WRONG direction. The monotone theorem says: if `F(phi) ∉ chain(n)` then `F(phi) ∉ chain(m)` for m ≥ n. So F-obligations, once absent, stay absent. This means: `F(phi) ∈ chain(n)` can ONLY be true if `F(phi) ∈ chain(0)` (or if F(phi) never left and was always present). No wait — if F(phi) ∉ chain(n) then F(phi) ∉ chain(n+k). Contrapositive: F(phi) ∈ chain(n+k) → F(phi) ∈ chain(n). So F-presence is non-increasing going forward: `F(phi) ∈ chain(n+1)` implies `F(phi) ∈ chain(n)`.

This means: if `F(phi) ∈ chain(k)` for ALL k ≥ n, then F(phi) is "persistent" forever. In this
case, we need phi to eventually be directly resolved — the whole problem.

**The correct Sigma-restricted descent**:

Here's the actual argument that works:

Suppose `F(phi) ∈ chain(n)`. We want `phi ∈ chain(m)` for some m > n.

Define for each step k ≥ n:
```
D(k) = {chi ∈ Sigma | F(chi) ∈ chain(k) ∧ chi ∉ chain(k)}
```

Note: `phi ∈ D(n)` since `F(phi) ∈ chain(n)` (given) and suppose for contradiction `phi ∉ chain(n)`
(if `phi ∈ chain(n)` then trivially `phi ∈ chain(n)` but n is not > n; we still need future).

Actually wait — the statement is `∃ m, n < m ∧ phi ∈ chain(m)`. So we need phi to appear at
some STRICTLY LATER step. Even if phi ∈ chain(n), we need a strictly later occurrence.

This is tricky. But actually, if `phi ∈ chain(n)` AND `F(phi) ∈ chain(n)`, then there exists a
witness for `F(phi)`, i.e., a future step where phi holds. But the witness is semantic, not in
our constructive chain. We need to find it in the chain.

**The right framing** for `fwd_chain_forward_F`:
The theorem says: if `F(phi) ∈ chain(n)`, then `∃ m > n, phi ∈ chain(m)`.
We may assume `phi ∉ chain(n)` WLOG (otherwise... no, we still need a strict future).

Actually let me re-read the theorem statement:

```lean
private theorem fwd_chain_forward_F ... (h_F : F(phi) ∈ chain(n)) :
    ∃ m, n < m ∧ phi ∈ chain(m)
```

We need m STRICTLY greater than n. The semantics of F (irreflexive) requires a strict future.

**The key insight for the proof**: `preserving_fwd_step` calls `defect_step_choice_early` when
active defects are non-empty. The active defects include phi (since F(phi) ∈ chain(n)).
`defect_step_choice_early` guarantees: ∃ w ∈ defects, w ∈ chain(n+1). So SOME formula in the
active defects is directly in chain(n+1).

**Case A**: The resolved w = phi. Then phi ∈ chain(n+1) and n+1 > n. Done.

**Case B**: The resolved w ≠ phi. Then phi ∈ chain(n+1) ∨ F(phi) ∈ chain(n+1).

In Case B, if phi ∈ chain(n+1), done (n+1 > n). If F(phi) ∈ chain(n+1), recurse on n+1.

The recursion terminates if we can show: eventually we must reach Case A.

**When does Case B forever apply?** Only if: at every step k ≥ n, the defect_step_choice_early
always picks some w ≠ phi. This is possible if phi is never the "chosen" defect.

The `defect_step_choice_early` uses `resolving_enriched_fwd_exists` with target = head of the
active defects list. In the current implementation, the list is `active_defects M sigma_list`
which filters sigma_list preserving order, so the target is the FIRST active defect in sigma_list
order. This means phi is chosen when phi is first in the active defects list.

**But sigma_list is fixed** — the ordering never changes. So phi is chosen whenever phi is the
earliest formula in sigma_list that is an active defect.

**The new problem**: `phi` might never become the first active defect if there's always some
chi < phi in sigma_list with F(chi) ∈ chain(k). We need chi to eventually be resolved and
leave the active defect set.

This is exactly the same problem one level up! Now chi needs to be eventually resolved.

### 4. The Correct Well-Founded Measure for the Descent

The correct well-founded measure is **the cardinality of the Sigma-restricted defect set
D(n) = {chi ∈ Sigma | F(chi) ∈ chain(n) ∧ chi ∉ chain(n)}**.

The key claim for the descent is:

**Claim (Sigma-restricted descent)**: At each `preserving_fwd_step` that resolves defect w
(putting w ∈ chain(n+1)), the Sigma-restricted defect set STRICTLY decreases:
`|D(n+1)| < |D(n)|`.

**Proof attempt**:
- w ∈ D(n) (w is a Sigma defect at n): w ∈ Sigma (yes, w ∈ active_defects ⊆ sigma_list ⊆ Sigma),
  F(w) ∈ chain(n) (yes, by active_defects_F_mem), w ∉ chain(n) (YES — this is the missing piece).

Wait — does `active_defects M sigma_list` include only formulas chi where chi ∉ M? Let me check
the definition:

```lean
private noncomputable def active_defects (M : Set Formula)
    (sigma_list : List Formula) : List Formula :=
  sigma_list.filter (fun chi => decide (F(chi) ∈ M))
```

**CRITICAL FINDING**: `active_defects` only checks `F(chi) ∈ M`, NOT `chi ∉ M`. So active
defects includes chi even if chi is already directly in M! This means when defect_step_choice_early
"resolves" w (puts w ∈ M'), w might ALREADY have been in M, and w is still active at the next
step if F(w) ∈ M'.

This is the bug identified in earlier research: the `active_defects` definition is missing the
`chi ∉ M` condition. All prior research rounds agreed this must be fixed. Let's call it
**Fix 0**: change `active_defects` to filter by `F(chi) ∈ M ∧ chi ∉ M`.

With Fix 0 applied, the descent argument becomes:

**With corrected active_defects**: `w ∈ active_defects M sigma_list` implies `w ∉ M`.
After resolution (w ∈ chain(n+1)), w is no longer in `active_defects chain(n+1) sigma_list`
(because w ∈ chain(n+1)). So D(n+1) doesn't contain w.

Does D(n+1) ⊆ D(n)? We need: `chi ∈ D(n+1)` → `chi ∈ D(n)`.
- `chi ∈ Sigma`: trivially preserved
- `F(chi) ∈ chain(n+1)`: by `fwd_chain_F_set_nonincreasing`, `F(chi) ∈ chain(n)`
- `chi ∉ chain(n+1)`: Does NOT imply `chi ∉ chain(n)`.

Specifically: chi might be in chain(n) but not in chain(n+1). Then chi would be in D(n) only if
`chi ∉ chain(n)`, but we assumed `chi ∈ chain(n)`. So D(n+1) ⊆ D(n) is NOT provable.

The issue: even with the correct active_defects, we cannot prove D is monotone because a formula
chi can appear in chain(n) but disappear from chain(n+1) (Lindenbaum extension doesn't preserve
direct presence).

**THIS IS THE CORE OBSTRUCTION in a new form**.

### 5. The Real Solution: Tracking Only F-Defects (Not Direct Presence)

Since monotonicity of chi ∉ chain(n) is the problem, let's drop it from the measure.
Track only:
```
F_defects(n) := {chi ∈ Sigma | F(chi) ∈ chain(n)}
```

This DOES satisfy monotonicity: `F_defects(n+1) ⊆ F_defects(n)` by `fwd_chain_F_set_nonincreasing`.

Now, for the Sigma-restricted descent to work, we need: resolving w (putting w ∈ chain(n+1))
causes F(w) ∉ chain(n+1), so w leaves F_defects.

**But this is exactly what we CANNOT prove** — the Lindenbaum opacity problem. The extension
may put F(w) ∈ chain(n+1) even though w ∈ chain(n+1).

### 6. The Quasimodel Infrastructure Already Solves This

The `hintikka_step_target_decrease` theorem in `Construction.lean` (line 273-297) solves
exactly this problem:

```lean
theorem hintikka_step_target_decrease
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    {phi psi : Formula}
    (h_target_in : phi U psi ∈ h1.formulas)
    (h_target_sigma : phi U psi ∈ Sigma)
    (h_not : psi ∉ h1.formulas)
    (h_witness : psi ∈ h2.formulas)
    (defect_mono : untilDefectSet h2 ⊆ untilDefectSet h1) :
    defect_count h2 < defect_count h1
```

The key hypothesis `defect_mono : untilDefectSet h2 ⊆ untilDefectSet h1` is what's missing
at the MCS chain level. It says: the UNTIL-defect set of the successor is contained in the
until-defect set of the predecessor. This is the `defect_mono` hypothesis — it's not proved
from the step relation alone; it's an EXTRA hypothesis that the oracle construction guarantees.

At the Hintikka point level, the oracle constructs h2 using a seed that includes all non-target
formulas from h1 (or more precisely, the seed comes from a BXPoint that backs h1 via
ChainWitnessed). This structural construction is what guarantees defect_mono.

**The Sigma-restricted approach at the MCS level** needs an analogous `defect_mono` for the
full MCS chain. Specifically:

For the chain step where target phi is resolved:
```
untilDefectSet_sigma(chain(n+1)) ⊆ untilDefectSet_sigma(chain(n))
```
where `untilDefectSet_sigma(M)` counts Until-formulas in Sigma that are defective at M.

This is NOT automatic — it requires the Lindenbaum extension to be carefully seeded.

### 7. The Required Construction: Sigma-Seeded Lindenbaum Extension

To get `defect_mono`, we need the seed for chain(n+1) to include:
1. `phi` (direct resolution of the target)
2. For each other `chi ∈ Sigma` with `phi_chi U psi_chi ∈ chain(n)` (an Until defect):
   - Either `psi_chi` (discharge chi's defect) or `phi_chi U psi_chi` (carry chi's Until)

This is exactly what a Hintikka step oracle does: it produces h2 from h1 such that
`hintikka_step h1 h2` holds (which includes the Until defect propagation requirement).

The `hintikka_step` relation (line 45-52 of Construction.lean) already encodes:
```
(∀ chi psi, phi U psi ∈ h1.formulas → psi ∉ h1.formulas →
  chi ∈ h1.formulas ∧ phi U psi ∈ h2.formulas)
```
This ensures the Until formula PROPAGATES to h2 when its goal is absent at h1.

**The gap**: At the MCS level, `preserving_fwd_step` does NOT include Until formulas in the
seed. The seed is `{beta'} ∪ g_content(M)` where F(beta') ∈ M. Until formulas are NOT
explicitly seeded, so they can disappear from the Lindenbaum extension.

### 8. A Complete Solution Sketch

The solution requires modifying `preserving_fwd_step` to use a **Sigma-enriched seed** that
includes Until formulas from Sigma alongside F-formulas:

**New seed design for a step targeting phi**:
```
Sigma_enriched_seed(M, phi, Sigma) :=
  {phi} ∪                                          -- target resolution
  {phi_chi U psi_chi | phi_chi U psi_chi ∈ M ∩ Sigma ∧ psi_chi ∉ M} ∪  -- Until propagation
  g_content(M)                                      -- G-content
```

**Consistency**: We need F(phi) ∈ M and some formula F(alpha) ∈ M where alpha encodes the
seed. The existing `enriched_resolving_seed_consistent` handles the two-formula case, but
the full Sigma-enriched seed requires a multi-formula variant.

Actually, the existing infrastructure already handles multi-formula seeds via
`enriched_fwd_fold` → `resolving_enriched_fwd_exists`. The gap is that neither includes
Until formulas in the seed alongside F-formulas.

**New lemma needed**:
```lean
theorem sigma_enriched_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : F(phi) ∈ M)
    (until_formulas : List Formula)  -- List of phi_chi U psi_chi in M ∩ Sigma
    (h_until : ∀ f ∈ until_formulas, f ∈ M)
    (h_not_goal : ∀ f ∈ until_formulas, ∀ phi_chi psi_chi,
        f = phi_chi U psi_chi → psi_chi ∉ M) :
    SetConsistent ({phi} ∪ until_formulas.toSet ∪ g_content M)
```

**Proof approach**: We have F(phi) ∈ M. We need a witness for `{phi} ∪ until_formulas ∪ g_content M`.
By `discharge_single_step` (already proved), `{phi} ∪ g_content M` is consistent (using
`forward_temporal_witness_seed_consistent`). But we need to add the Until formulas too.

The Until formulas are IN M (by h_until). So adding them to the seed `{phi} ∪ g_content M`
maintains consistency: any consistent set remains consistent when extended with formulas from
an MCS that contains it.

Wait — the witness MCS from `discharge_single_step` contains phi AND g_content(M), but does
it contain the Until formulas from M? YES — if phi_chi U psi_chi ∈ M and the witness MCS M'
has g_content(M) ⊆ M', we still don't know if phi_chi U psi_chi ∈ M' (g_content only gives
G-formulas).

This is the problem. Until formulas from M don't propagate through g_content.

**The actual seed consistency proof**: We need F(phi AND (phi_chi1 U psi_chi1) AND ... AND
(phi_chik U psi_chik)) ∈ M. Then the enriched_resolving_seed gives a consistent seed.

By BX10 (until_F) applied to each Until formula: `phi_chi U psi_chi ∈ M` → `F(psi_chi) ∈ M`.
This gives us F(psi_chi) for each chi. But we want F(phi_chi U psi_chi) so we can include
the Until formula itself.

Actually, the Until formula is already in M. By BX4 (connect_future): since `phi_chi U psi_chi ∈ M`,
we have `G(P(phi_chi U psi_chi)) ∈ M`. This is a G-formula, so it's in g_content(M). In any
Lindenbaum extension M' of g_content(M), we have `G(P(phi_chi U psi_chi)) ∈ M'`, which by
modal_t gives `P(phi_chi U psi_chi) ∈ M'`, which means `phi_chi U psi_chi` was in the past.
But we want `phi_chi U psi_chi ∈ M'` (present tense).

**Actually we can use BX12**: `F(phi) → (⊤ U phi)`. So `F(phi) ∈ M` → `⊤ U phi ∈ M`.
But we want to go the other way: Until formulas in M give F-formulas (via BX10), not the reverse.

**Revised approach**: To guarantee Until formula propagation to M', include in the seed
`F(phi_chi U psi_chi)` for each Until defect in M ∩ Sigma. Then:
- F(phi_chi U psi_chi) ∈ M' (from the seed)
- In M', by BX12': F(phi_chi U psi_chi) → ⊤ U (phi_chi U psi_chi)
- By axioms on Until and its F-version, in the right MCS context, the Until formula itself
  would propagate. But this gets complicated.

**The cleanest path**: The Until propagation problem is why the Hintikka chain approach
uses `hintikka_step` which REQUIRES Until propagation as an axiom of the step relation.
At the MCS level, we need an analog: when stepping from M to M', explicitly include Until
formulas from M ∩ Sigma in the seed to force their propagation.

**Seed**: `{phi} ∪ {f | f ∈ M ∩ Sigma ∧ f is an Until formula with absent goal} ∪ g_content(M)`

**Consistency proof**: The Until formulas from M ∩ Sigma can be included because they are
all in M. The seed is a subset of `{phi} ∪ M`. Since M is an MCS, M is consistent. Since
phi is "intended" to be in the extension (F(phi) ∈ M gives a consistent seed via
`forward_temporal_witness_seed_consistent`), we need to show this larger seed is consistent.

Actually: `{phi} ∪ M` is consistent iff `F(phi) ∈ M` (which it is). Since the Until
formulas are IN M, the seed `{phi} ∪ (M ∩ Sigma ∩ Until-defects) ∪ g_content(M)` is a
subset of `{phi} ∪ M`, which is consistent. So it IS consistent.

**Wait** — but we can only use finiteness here if the seed is finite. The Until-defects in
M ∩ Sigma form a FINITE set (Sigma is finite). So the seed is:
`{phi} ∪ (finite set from M ∩ Sigma) ∪ g_content(M)`

Consistency: This is a set; `SetConsistent` asks that every FINITE subset is consistent.
For a finite subset L of this seed, L ⊆ `{phi} ∪ M` (since all Until-defects are in M and
g_content(M) ⊆ M). L ⊆ M ∪ {phi}. By `forward_temporal_witness_seed_consistent` (which uses
F(phi) ∈ M), the set `{phi} ∪ g_content(M)` is consistent, hence {phi} ∪ M is consistent
(since M is MCS, {phi} ∪ M is consistent iff phi is consistent with M, which follows from
F(phi) ∈ M → phi can be added consistently... actually this needs care).

**The direct argument for consistency**:
By `forward_temporal_witness_seed_consistent`, `{phi} ∪ g_content(M)` is consistent.
Any set `S ⊆ {phi} ∪ (M ∩ Sigma ∩ Until-defects) ∪ g_content(M)` has the property
`S ⊆ {phi} ∪ M`. A finite `L ⊆ {phi} ∪ M` with `L ⊢ ⊥` would give `[phi] ⊢ (M restricted to L \ {phi}) → ⊥`, i.e., the formulas from M imply ¬phi. But then `¬phi ∈ M` (since M is MCS and ¬phi is derivable from M-formulas in L\{phi}). And `¬phi ∈ M` contradicts `F(phi) ∈ M` AND ... actually `F(phi) ∈ M` and `¬phi ∈ M` are perfectly compatible! F(phi) says phi holds in the FUTURE, not now.

Hmm — so `{phi} ∪ M` might NOT be consistent even when `F(phi) ∈ M`, because `¬phi ∈ M` is
possible.

**THE REAL SEED CONSISTENCY**: `forward_temporal_witness_seed_consistent` proves:
If `F(phi) ∈ M`, then `{phi} ∪ g_content(M)` is consistent.

This works because: any finite `L ⊆ {phi} ∪ g_content(M)` where `L ⊢ ⊥` would, together with
the MCS M' that contains phi (from F(phi) ∈ M), give a contradiction. Specifically, the
Lindenbaum extension of `{phi} ∪ g_content(M)` is the witness MCS `M'`. Since `M'` is consistent,
`{phi} ∪ g_content(M)` is consistent.

Adding Until-defect formulas from M to this seed: these are in M, NOT in g_content(M) (unless
they're of the form G(chi) for some chi). So the seed `{phi} ∪ (Until-defects from M ∩ Sigma) ∪ g_content(M)` is LARGER than `{phi} ∪ g_content(M)`.

Is the larger seed consistent? It's consistent iff: there exists an MCS M'' with phi ∈ M'' AND
(until-defects from M ∩ Sigma) ⊆ M'' AND g_content(M) ⊆ M''.

The Lindenbaum extension M' of `{phi} ∪ g_content(M)` already has phi ∈ M' and g_content(M) ⊆ M'.
But until-defects from M might or might not be in M'. We cannot guarantee they are.

So we CANNOT directly extend the seed with Until-defects from M and claim consistency.

**Alternative**: Find a formula `alpha` such that `F(phi ∧ alpha) ∈ M` and from `alpha ∈ M'`
we can recover the Until-defects. This is the BX11 fold approach — but as established, the fold
gives disjunctive results.

### 9. The Quasimodel Connection: Why HintikkaStepOracle Works and MCS Level Doesn't

The quasimodel construction (Construction.lean) avoids all these issues because:

1. **Hintikka points are Sigma-closed**: A HintikkaPoint contains exactly the formulas in Sigma
   that are true at that point. The defect count is over formulas IN Sigma.

2. **`hintikka_step` is a CONSTRAINED relation**: It requires Until propagation as an axiom:
   `phi U psi ∈ h1 ∧ psi ∉ h1 → phi ∈ h1 ∧ phi U psi ∈ h2`
   This is NOT proved — it's REQUIRED. The oracle must provide steps satisfying this.

3. **The oracle is backed by a BXPoint**: `WitnessedHintikka` pairs a HintikkaPoint with a
   backing BXPoint. Consistency of the seed (when forming the next step) is discharged using
   MCS consistency of the backing BXPoint. Until propagation is handled because the backing
   BXPoint already satisfies all the right properties.

4. **`defect_mono` is the oracle's promise**: The oracle returns a step with
   `defect_count h2 < defect_count h1` OR `psi ∈ h2` (witness reached). This IS the descent
   argument. At the MCS level, no such clean descent is available without explicitly constructing
   the oracle.

**The fundamental gap**: To implement Sigma-restricted defect tracking at the MCS level,
we need to BUILD an analog of the HintikkaStepOracle for full MCS sets. This oracle, at each
step, would take M (an MCS) and a target Until-formula `phi U psi` in M ∩ Sigma, and produce
M' (an MCS) such that:
1. psi ∈ M' (witness resolved) OR `phi U psi ∈ M'` (defect carried)
2. The Sigma-restricted Until-defect count strictly decreases (psi ∈ M') or stays the same
3. g_content(M) ⊆ M' (temporal coherence preserved)

This oracle CANNOT be built using the current `preserving_fwd_step` because requirement (2)
requires the Until formula to be explicitly in M' when carried, which isn't guaranteed by
any existing seed construction at the MCS level.

---

## Recommended Approach

Given the analysis above, the Sigma-restricted defect tracking approach at the MCS chain level
faces a fundamental obstruction: Until propagation cannot be guaranteed in a Lindenbaum extension
without explicitly including the Until formula in the seed, and including it in the seed requires
a consistency proof that isn't available.

**Two viable paths**:

### Path A: Fix `active_defects` + Exploit `fwd_chain_F_obligation_monotone` with Round-Robin

This is a simpler approach that avoids the Sigma-restriction entirely and works purely with
F-obligations:

**The key observation** (not previously explored in full): The `fwd_chain_F_obligation_monotone`
theorem says F-obligations never return once lost. Combined with `defect_step_choice_early`'s
guarantee that SOME defect `w` is resolved, the only question is: does `w ∈ chain(n+1)` cause
`F(w) ∉ chain(n+1)`?

Under REFLEXIVE semantics, no. Under IRREFLEXIVE semantics... still no, because irreflexive
semantics just means the time order is strict, not that phi and F(phi) can't coexist.

But here's a new angle: if we use a **round-robin with forced resolution**, and if when phi
is the round-robin target we use `discharge_single_step` (which builds seed `{phi} ∪ g_content(M)`
and gives phi ∈ M'), then at that step phi ∈ chain(k+1). This is the direct resolution.

The proof of `fwd_chain_forward_F` by **step-indexed descent**:

Given `F(phi) ∈ chain(n)`, phi appears at step `n + k` for some k > 0 where k is phi's
round-robin slot. We need F(phi) ∈ chain(n+k-1) (just before phi's round-robin turn).

F-obligations are non-increasing: `F(phi) ∈ chain(n)` → `F(phi) ∈ chain(n+1)` → ... is NOT
what the theorem says. It says: `F(phi) ∉ chain(j)` → `F(phi) ∉ chain(j+k)`. Contrapositive:
`F(phi) ∈ chain(j+k)` → `F(phi) ∈ chain(j)`. So F-obligations can ONLY decrease as we go
forward. DECREASING means: once F(phi) leaves, it stays gone.

But does F(phi) stay until phi's round-robin turn? NOT GUARANTEED. F(phi) might leave the
chain before phi's turn.

If F(phi) ∉ chain(j) for some j < phi's round-robin turn, then phi is no longer an active
defect at step j. But we still need phi ∈ chain(m) for some m > n!

**Here's the crucial gap in the step-indexed approach**: If F(phi) drops out of the chain
at step j < phi's turn, but phi ∉ chain(j), we've "lost" the obligation. The semantics says
F(phi) at n means there exists a REAL future point where phi holds, but our CHAIN might not
include that point.

This is why `fwd_chain_forward_F` is hard: the chain is a constructive approximation to a
semantic model, and the semantic guarantee (F(phi) means phi will eventually hold) is not
automatically realized by the chain.

### Path B: Use the Quasimodel Infrastructure Directly

The quasimodel `HintikkaStepOracle` + `hintikka_chain_exists` already proves exactly the
Until-eventuality version of `fwd_chain_forward_F`:

```
hintikka_chain_exists: Given oracle and h0 with phi U psi ∈ h0,
∃ chain with h0 at head and psi ∈ last
```

To use this for `fwd_chain_forward_F`, we need:
1. Convert `F(phi) ∈ chain(n)` to `⊤ U phi ∈ chain(n)` (using BX12: `F(phi) → (⊤ U phi)`)
2. Build a HintikkaPoint from sigma_signature(chain(n), Sigma)
3. Construct the oracle from the MCS chain infrastructure
4. Run `hintikka_chain_exists` to get a raw Hintikka chain ending with phi
5. Lift the Hintikka chain to an Int-indexed dd_chain segment
6. Show the segment's endpoint has phi in its formulas

Step 1: `F_until_equiv : F(phi) → ⊤ U phi` is already in the axioms (BX12). So this works at
the MCS level.

Step 3: Building the oracle requires showing that for any HintikkaPoint h from sigma_signature(M)
with `phi U psi ∈ h` and `psi ∉ h`, there exists a next HintikkaPoint h' from sigma_signature(M')
for some successor MCS M' that either has psi ∈ h' or has `phi U psi ∈ h'` and defect_count h' < defect_count h.

This is exactly the critical Gap G3 from prior research: UNTIL PROPAGATION. When stepping from
M to M' (a Lindenbaum extension), `phi U psi ∈ M` does NOT guarantee `phi U psi ∈ M'`. The BX11
fold might not carry it.

**Gap G3 is the same obstruction in different clothing**: Whether we work at the MCS level
(Sigma-restricted approach) or at the Hintikka level (quasimodel bridge), the fundamental
obstacle is that Until-formula propagation through Lindenbaum extensions is not guaranteed.

### Lean 4 Proof Sketch for the Until Propagation Step

To close Gap G3, we need:

```lean
-- Given M (MCS) with phi U psi ∈ M and F(psi) ∈ M (from BX10: until_F),
-- construct M' (MCS) with g_content(M) ⊆ M' and EITHER psi ∈ M' OR phi U psi ∈ M'

theorem until_step_propagation {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_until : Formula.untl phi psi ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ g_content M ⊆ M' ∧
      (psi ∈ M' ∨ Formula.untl phi psi ∈ M') := by
  -- From BX10: F(psi) ∈ M
  have h_F_psi : Formula.some_future psi ∈ M := until_F_mcs h_until
  -- From discharge_single_step: get M' with psi ∈ M'
  obtain ⟨M', h_mcs', h_psi, h_g⟩ := discharge_single_step M h_mcs psi h_F_psi
  exact ⟨M', h_mcs', h_g, Or.inl h_psi⟩
```

WAIT — this WORKS! We can ALWAYS resolve psi directly using `discharge_single_step`. The
seed `{psi} ∪ g_content(M)` is consistent because `F(psi) ∈ M` (from BX10). So M' has
psi ∈ M' and g_content(M) ⊆ M'. The conclusion `psi ∈ M' ∨ phi U psi ∈ M'` is satisfied
by the left disjunct!

But wait — if we ALWAYS choose `psi ∈ M'` (the "resolved" branch), then we're not tracking
the Until formula phi U psi at all. The HintikkaStepOracle needs the right disjunct too —
it needs `phi U psi ∈ M'` when psi is NOT yet resolved (so the chain can continue).

Actually, `discharge_single_step` gives us the BEST case (direct resolution). If the oracle
always returns "psi ∈ M'", then `hintikka_chain_exists` terminates at step 1 (since the
witness is reached immediately). This IS what we want for `fwd_chain_forward_F`:

```
Given F(phi) ∈ chain(n), by BX12: ⊤ U phi ∈ chain(n).
By BX10 applied to ⊤ U phi: F(phi) ∈ chain(n) (circular, but we already have this).
By discharge_single_step: ∃ M' with phi ∈ M' and g_content(chain(n)) ⊆ M'.
So ∃ m = n+1 with phi ∈ chain(n+1)... but m must be chain(n+1), not an arbitrary MCS M'.
```

**The gap**: `discharge_single_step` gives an MCS M' that's NOT chain(n+1). The chain
`fwd_chain_of_sigma` is built by a specific function `preserving_fwd_step`, and chain(n+1)
is that specific choice, not our arbitrary M'.

**This is the true core of the problem**: `fwd_chain_forward_F` must prove a fact about
`fwd_chain_of_sigma` as DEFINED (with `preserving_fwd_step`), not about some ideal chain.

To actually prove `fwd_chain_forward_F`, we have two options:
1. **Modify `fwd_chain_of_sigma`** to use a step function that guarantees resolution.
2. **Prove `fwd_chain_of_sigma`** (as currently defined) satisfies the property despite
   the opacity.

Option 2 seems very hard (the stabilization argument shows it can cycle). Option 1 is what
all prior research recommended.

---

## The Cleanest Solution: Targeted Round-Robin with Forced Resolution

Given all the analysis above, the cleanest implementable solution is:

**Redesign `fwd_chain_of_sigma`** with a new step function:

```lean
-- New step: target the formula at position n % |sigma_list|, using discharge_single_step
-- if F(target) ∈ M, otherwise use fwd_succ.
private noncomputable def forced_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (sigma_list : List Formula) (n : Nat) : Set Formula :=
  let target := sigma_list.get ⟨n % sigma_list.length, Nat.mod_lt n h_pos⟩
  if h : Formula.some_future target ∈ M then
    (discharge_single_step M h_mcs target h).choose  -- gives target ∈ M'
  else
    (set_lindenbaum (g_content M) (g_content_set_consistent h_mcs)).choose
```

**Proof of `fwd_chain_forward_F` for this new chain**:

Given `F(phi) ∈ chain(n)`, phi ∈ sigma_list at position k.

Consider step n + L where L = n_steps until phi's turn:
- At step n + L - 1, the target is phi (since (n + L - 1) % |sigma_list| = k)
- We need F(phi) ∈ chain(n + L - 1)

Does F(phi) persist from chain(n) to chain(n+L-1)?

By `fwd_chain_F_obligation_monotone`, F(phi) persists UNLESS it was never in chain(n+L-1)
to begin with. But wait — the monotone theorem says: if F(phi) ∉ chain(j), then F(phi) ∉ chain(j+1).
Contrapositive: if F(phi) ∈ chain(j+1), then F(phi) ∈ chain(j). So F-obligations are
non-increasing. F(phi) ∈ chain(n) does NOT guarantee F(phi) ∈ chain(n+L-1).

**But**: If F(phi) ∉ chain(j) for some j (n < j < n+L), then phi is NOT an active defect at
chain(j). Since `forced_fwd_step` uses g_content(M) in the non-resolving branch, and
F(phi) ∉ chain(j), we have `G(¬phi) ∈ chain(j)` (by MCS completeness, since ¬F(phi) = G(¬phi) ∈ chain(j)).
By G-propagation: `G(¬phi) ∈ chain(j+1)`, so `F(phi) ∉ chain(j+1)` (contradicting chain(j+1)
being used for any step... no, this is fine, it just says phi has no future obligation).

**The key insight**: If F(phi) ∉ chain(j) for any j between n and phi's turn, then phi NEVER
has an obligation in the chain, and `fwd_chain_forward_F` is asking to prove an UNREACHABLE
case — but wait, `fwd_chain_forward_F` takes F(phi) ∈ chain(n) as hypothesis, not as a
persistent property.

After F(phi) leaves chain(j), we have G(¬phi) ∈ chain(j). By temp_4 and g_content: G(¬phi) ∈ chain(k) for all k ≥ j, which means F(phi) ∉ chain(k) for all k ≥ j. So F(phi) is
permanently absent from the chain from step j onward.

**The semantic issue**: If `F(phi) ∈ chain(n)` means "phi will hold at some future time t > n
in the semantic model", and our chain corresponds to (a subsequence of) the semantic model,
then `G(¬phi) ∈ chain(j)` for j > n means "phi never holds after time j in the model",
contradicting `F(phi) ∈ chain(n)`.

But our chain is NOT a faithful representation of the model — it's a construction. The chain
at step n+1 is a NEW MCS built from chain(n), not a semantic successor. The chain is a PROOF
OBJECT, not a model.

**So `fwd_chain_forward_F` is asking**: prove that for any MCS M in the chain with F(phi) ∈ M,
the chain construction eventually puts phi directly in some chain(m). This is a property of the
CONSTRUCTION, not the semantics.

The semantic validity of `fwd_chain_forward_F` (F holds in every model) is different from the
constructive validity (phi eventually appears in OUR chain). The completeness proof needs the
constructive version.

---

## Confidence Level

**Medium (45-50%)** for a clean, correct implementation within a reasonable timeframe.

**Reasons for medium (not high)**:

1. The Lindenbaum opacity problem is a genuine structural obstruction, not a proof engineering
   issue. No existing step function at the MCS level provides the necessary guarantees.

2. The round-robin forced resolution approach (Path A) has a gap: F(phi) might drop out of
   the chain before phi's forced resolution turn, leaving no F-obligation to discharge.

3. The quasimodel bridge approach (Path B) faces Gap G3 (Until propagation), which as analyzed
   requires Until formulas to be explicitly seeded — and the consistency of such seeds depends
   on getting F-formulas for Until formulas from BX10, which only gives us F(psi) not F(phi U psi).

4. `discharge_single_step` always gives psi directly (via the oracle), but this produces a
   ONE-OFF MCS that's not the chain's next step.

**Reasons for not low (some optimism)**:

1. The `fwd_chain_F_obligation_monotone` theorem IS a powerful tool. If combined with a
   careful round-robin that uses `discharge_single_step` AT phi's turn (when F(phi) is
   guaranteed to still be present... but wait, we just said it might not be), this could work.

2. There's a subtle argument: if F(phi) dropped out at step j < phi's turn, that means
   G(¬phi) ∈ chain(j). But chain(j) is derived from chain(n) by g_content propagation.
   So G(G(¬phi)) ∈ chain(n) (by temp_4 applied to chain(n)). So G(¬phi) ∈ g_content(chain(n))
   ⊆ chain(n+1). So F(phi) ∉ chain(n+1) already! This means F(phi) ∉ chain(n+1).

   But wait: G(¬phi) ∈ chain(n) means F(phi) ∉ chain(n), contradicting our hypothesis
   F(phi) ∈ chain(n). So if F(phi) ∈ chain(n), then G(¬phi) ∉ chain(n), which means the
   G(¬phi) persistence argument doesn't apply starting from chain(n).

   So F(phi) CAN drop out at step j > n. But at step j, we have both F(phi) ∈ chain(j-1)
   and F(phi) ∉ chain(j). How does F(phi) drop? The step from chain(j-1) to chain(j) uses
   `preserving_fwd_step`, which includes g_content preservation. At chain(j-1), F(phi) ∈ chain(j-1).
   But g_content only propagates G-formulas, not F-formulas. So F(phi) might not be in
   g_content(chain(j-1)), hence might not be propagated to chain(j).

3. **Key question**: Can F(phi) ∈ chain(k) for all k (n ≤ k < phi's turn)? Under the round-robin
   approach, intermediate steps might resolve OTHER defects via `discharge_single_step`, losing
   F(phi). OR, they might use fwd_succ (when the target's F-formula is absent), which uses
   g_content seed and may or may not include F(phi) in the extension.

   If F(phi) is eventually lost before phi's turn, we need another argument to show phi eventually
   appears. This seems hard.

**Summary**: The approach has identified both the obstruction AND the tools that partially
address it, but the final step (bridging from F(phi) ∈ chain(n) to phi ∈ chain(m)) remains
elusive without a chain redesign that specifically guarantees F-preservation until resolution.

---

## Evidence / Examples

### Evidence the Approach Works: `hintikka_step_target_decrease`

In `Construction.lean:273-297`, the theorem proves that when:
- The target formula `phi U psi` is a defect (present at h1, goal absent)
- The witness psi appears at h2 (goal reached)
- defect_mono: defect set of h2 ⊆ defect set of h1 (defects don't grow)

Then `defect_count h2 < defect_count h1` — the count strictly decreases.

This is exactly the Sigma-restricted descent we need. At the Hintikka level, it works because
the oracle constructs h2 guaranteeing defect_mono (the HintikkaStepOracle's second disjunct
explicitly includes `defect_count wh'.point < defect_count h`).

### Evidence the Approach Fails at the MCS Level: The Stabilization Argument

If `active_defects` is corrected (Fix 0), the set of Sigma-restricted defects at each step k is:
`D(k) = {chi ∈ Sigma | F(chi) ∈ chain(k) ∧ chi ∉ chain(k)}`

Consider a stabilization: D(k) = {phi, chi} for all k ≥ n. At each step:
- Some w ∈ D(k) is resolved (w ∈ chain(k+1)) by `defect_step_choice_early`
- If w = phi: phi ∈ chain(k+1), so phi ∉ D(k+1). But the Lindenbaum extension might have F(phi) ∈ chain(k+1) and phi ∈ chain(k+1), meaning phi ∉ D(k+1) (defect cleared!) but phi IS directly resolved. So phi ∈ chain(k+1) which IS the goal.

Wait — if phi ∈ chain(k+1), that's the DIRECT resolution we wanted. The issue is that defect_step_choice_early might always pick chi (not phi) as the resolved defect.

If chi is always resolved (chi ∈ chain(k+1)) but chi ∉ D(k+1) (because chi ∈ chain(k+1)), and then phi remains in D(k+1) (F(phi) ∈ chain(k+1) and phi ∉ chain(k+1)):

This is the cycling problem. At each step, chi gets resolved and re-acquires its defect, while phi is always "preserved" with F(phi) ∈ chain(k+1).

But WAIT: after chi is resolved (chi ∈ chain(k+1)), chi ∉ D(k+1) regardless of F(chi) ∈ chain(k+1). So chi is NOT in D(k+1). If F(chi) ∈ chain(k+1) too, chi is back in D(k+2) (if chi ∉ chain(k+2)).

This cycling is the REAL obstruction: the Sigma-restricted defect count doesn't monotonically decrease because resolved defects can re-acquire both direct presence and F-obligations.

---

## Gaps and Risks

### Gap 1: Until Propagation (Critical)

The seed for a Lindenbaum extension cannot include Until formulas from M unless they are
supported by an F-formula in M. Since `g_content(M)` doesn't carry Until formulas, any
Lindenbaum extension of `g_content(M)`-based seeds can freely drop Until formulas.

**Workaround**: Include `F(phi U psi)` (i.e., `F(phi_chi U psi_chi)` for each Until defect) in the
seed. Use BX12 in M': F(phi U psi) → ⊤ U (phi U psi), and transitivity of Until to recover the
original Until. But this creates a more complex formula, and the compound Until `⊤ U (phi U psi)`
is not the same as `phi U psi`. The BX axioms may not give a clean reduction.

### Gap 2: Corrected `active_defects` (Important but Mechanical)

The current `active_defects` definition doesn't filter by `chi ∉ M`. This must be fixed for
any Sigma-restricted descent argument to work. The fix is straightforward:

```lean
private noncomputable def active_defects (M : Set Formula)
    (sigma_list : List Formula) : List Formula :=
  sigma_list.filter (fun chi => decide (Formula.some_future chi ∈ M ∧ chi ∉ M))
```

But this change breaks `preserving_fwd_step_defect_preserved` (which currently works because
`defect_step_choice_early` preserves F-obligations for all `chi ∈ active_defects`, and the
theorem uses this). With the corrected definition, the preserved set is smaller, but the
theorem still holds (any chi with `F(chi) ∈ M ∧ chi ∉ M` is preserved as `chi ∈ M' ∨ F(chi) ∈ M'`).

### Gap 3: The Cycling Problem (Critical)

Even with corrected `active_defects` and Sigma-restricted tracking, the defect set can cycle:
- Step k: chi resolved (chi ∈ chain(k+1)), chi leaves D(k+1)
- Step k+1: chi ∉ chain(k+2) but F(chi) ∈ chain(k+2), so chi ∈ D(k+2) again

The defect count D(k) is not monotonically non-increasing. This appears to be a fundamental
obstruction at the MCS level.

**Only fix**: Use a step function that, when chi is resolved, also excludes F(chi) from the
seed. But excluding F(chi) from the seed means including G(¬chi) in the seed, which requires
consistency of {G(¬chi)} ∪ g_content(M) when chi ∈ chain(k+1). This is consistent (by
seriality and the fact that chi holds at k+1, so G(¬chi) just means phi doesn't hold at k+2+...,
which is fine). But this fundamentally changes the temporal structure of the chain and may
break other properties (like temporal coherence for OTHER formulas).

### Gap 4: Round-Robin May Miss phi (Conditional)

If `forced_fwd_step` uses round-robin (not Sigma-restricted descent), F(phi) might drop before
phi's turn. If F(phi) ∈ chain(n) but F(phi) ∉ chain(n+k) for k < phi's turn, the forced
resolution at phi's turn has no F-obligation to discharge — `forced_fwd_step` uses `g_content M`
in the non-resolving branch, which gives no guarantee about phi.

**Mitigation**: Use a step function that at ALL steps either resolves a defect (the first
in sigma_list with F(chi) ∈ M) or preserves all F-obligations. The current `preserving_fwd_step`
does this. The missing piece is ensuring that eventually, phi becomes the chosen defect.

### Gap 5: No Prior Art for This Specific Formalization

Burgess (1984) and Goldblatt (1992) use the FULL MCS space as the model (not an Int-indexed
chain). Reynolds (1996) and GHR (1994) use quasimodel unraveling. This hybrid approach
(Int-indexed chain of MCS sets with Sigma-restricted defect tracking) does not appear to exist
in the literature.

The closest prior art is the Quasimodel construction in `Construction.lean`, which works but
at a different level (Hintikka points, not full MCS sets).

---

## Concrete Lean 4 Proof Sketches

### Sketch 1: The Round-Robin Forced-Resolution Chain

```lean
-- New step function: at step n, resolve sigma_list[n % |sigma_list|] if F-active
private noncomputable def targeted_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (sigma_list : List Formula) (h_pos : sigma_list.length > 0) (n : Nat) : Set Formula :=
  let k := n % sigma_list.length
  let target := sigma_list.get ⟨k, Nat.mod_lt n h_pos⟩
  if h_F : Formula.some_future target ∈ M then
    -- Force-resolve target: get MCS M' with target ∈ M' and g_content(M) ⊆ M'
    (forward_temporal_witness_seed_consistent M h_mcs target h_F |>
     set_lindenbaum _).choose
  else
    -- No F-obligation for target: use g_content extension
    (g_content_set_consistent h_mcs |> set_lindenbaum _).choose

-- The chain
private noncomputable def targeted_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_pos : sigma_list.length > 0) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := targeted_fwd_chain M₀ h₀ sigma_list h_pos n
    ⟨targeted_fwd_step M hM sigma_list h_pos n, ...⟩

-- Forward_F for the targeted chain: INCOMPLETE — needs F-persistence
theorem targeted_fwd_chain_forward_F {M₀ : Set Formula} {h₀ : SetMaximalConsistent M₀}
    {sigma_list : List Formula} {h_pos : sigma_list.length > 0}
    (n : Nat) (phi : Formula) (h_phi : phi ∈ sigma_list)
    (h_F : Formula.some_future phi ∈ (targeted_fwd_chain M₀ h₀ sigma_list h_pos n).val) :
    ∃ m, n < m ∧ phi ∈ (targeted_fwd_chain M₀ h₀ sigma_list h_pos m).val := by
  -- Let k be phi's index in sigma_list
  obtain ⟨k, hk⟩ := List.mem_iff_get.mp h_phi
  -- Let m' be the next step where the round-robin targets phi
  let m' := n + (k - (n % sigma_list.length)).natAbs + 1  -- TODO: correct arithmetic
  -- Need: F(phi) ∈ chain(m' - 1)
  -- This is the GAP: F(phi) might not persist from n to m'
  sorry
```

### Sketch 2: Quasimodel Bridge (Using BX12 Reduction)

```lean
-- Step 1: Convert F(phi) ∈ chain(n) to (⊤ U phi) ∈ chain(n)
theorem F_to_until_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Formula.untl (Formula.bot.imp Formula.bot) phi ∈ M := by
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.F_until_equiv phi))) h_F

-- Step 2: Build HintikkaPoint from sigma_signature of chain(n)
-- (sigma_signature maps BXPoint → Sigma-labeled set)
-- Step 3: Apply hintikka_chain_exists to get a chain ending with phi
-- Step 4: Lift Hintikka chain to dd_chain
-- BLOCKED at Step 3: the oracle construction requires Until propagation (Gap G3)
```

### Sketch 3: The Descent with Sigma-Restricted Defects

```lean
-- Correct measure: count of Sigma-formulas with F-obligation AND absent
noncomputable def sigma_restricted_defect_count (M : Set Formula) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun chi => decide (Formula.some_future chi ∈ M ∧ chi ∉ M))).card

-- The step we need: for Until-defects in Sigma, either resolve psi or carry phi U psi
theorem sigma_until_step {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (Sigma : Finset Formula)
    (phi psi : Formula) (h_until : Formula.untl phi psi ∈ M)
    (h_sigma : Formula.untl phi psi ∈ Sigma)
    (h_not : psi ∉ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ g_content M ⊆ M' ∧
      -- Either psi is resolved...
      (psi ∈ M' ∨
      -- ...or phi U psi is carried forward AND defect count decreases
      (Formula.untl phi psi ∈ M' ∧
       sigma_restricted_defect_count M' Sigma < sigma_restricted_defect_count M Sigma)) := by
  -- Use BX10: F(psi) ∈ M
  have h_F_psi : Formula.some_future psi ∈ M := until_F_mcs h_until
  -- Use discharge_single_step: get M' with psi ∈ M'
  obtain ⟨M', h_mcs', h_psi, h_g⟩ := discharge_single_step M h_mcs psi h_F_psi
  exact ⟨M', h_mcs', h_g, Or.inl h_psi⟩
  -- Note: this ALWAYS takes the left branch! The right branch (carrying Until) is NEVER needed
  -- for fwd_chain_forward_F (since we can always resolve psi immediately)
  -- The issue is that M' is not chain(n+1) — it's an ARBITRARY successor MCS
```

The sketch above illustrates the core issue: `discharge_single_step` can always resolve psi,
but the resulting M' is not the chain's next step. `fwd_chain_forward_F` must hold for the
SPECIFIC chain defined by `fwd_chain_of_sigma`, not for an arbitrary reachable MCS.

---

## Summary Recommendation

The Sigma-restricted defect tracking approach, while mathematically motivated, faces the same
fundamental obstruction as all other MCS-level approaches: the chain construction (`fwd_chain_of_sigma`)
uses opaque Lindenbaum extensions that cannot be forced to carry Until formulas or exclude
re-acquired F-obligations.

**Recommendation**: Abandon the Sigma-restricted approach for the CURRENT chain and instead:

1. **Modify `fwd_chain_of_sigma`** to use a NEW step function that, when targeting phi with
   F(phi) ∈ M, DIRECTLY resolves phi via `discharge_single_step` (giving phi ∈ chain(n+1)).

2. **Use strong induction on the number of F-obligations** at step n: define `weight(n) = |{chi ∈ sigma_list | F(chi) ∈ chain(n)}|`. Show that `fwd_chain_forward_F` holds for any n with weight(n) = 0 (vacuously: F(phi) ∈ chain(n) but weight = 0 means phi ∉ sigma_list, contradiction), weight(n) = 1 (the only defect is phi, so we can use the targeted step), and by IH on weight(n).

3. **Key lemma for induction**: When the targeted step resolves some chi ≠ phi, show that either:
   (a) F(phi) ∈ chain(n+1) (phi's obligation persists), in which case recurse, OR
   (b) F(chi) ∉ chain(n+1) (chi's obligation dropped), meaning weight decreased, and use IH.

   The `fwd_chain_F_obligation_monotone` guarantees option (b) is PERMANENT: if F(chi) drops,
   it never returns. But does weight EVER decrease? Only if SOME chi has F(chi) drop from
   chain(n) to chain(n+1). With the targeted step that uses `discharge_single_step` for phi
   (when phi is targeted) and `fwd_succ` otherwise: when `fwd_succ` is used for chi (targeting
   chi with `fwd_succ M h_mcs chi`), the step has the property that chi ∈ chain(n+1) (via
   `fwd_succ_resolves`). But `fwd_succ` may or may not include F(chi) in chain(n+1).
   If F(chi) ∉ chain(n+1), weight decreased. If F(chi) ∈ chain(n+1), chi is still a defect.

This approach requires the same resolution of the cycling problem and doesn't obviously close
the gap. The fundamental issue remains unresolved.

**True bottom line**: `fwd_chain_forward_F` cannot be proved for ANY chain construction based
solely on Lindenbaum extensions with `g_content`-seeded seeds. A chain construction that
explicitly PREVENTS F-obligations from re-emerging after resolution (via a more restrictive
seed) is needed. Such a construction would be more like the Hintikka chain than the current
MCS chain. The full bridge to the quasimodel infrastructure is likely the cleanest path,
despite Gap G3 — because Gap G3 is resolved by the same argument (`discharge_single_step`
always resolves psi via BX10), as shown in Sketch 3 above.

**Effort estimate**: The quasimodel bridge path (despite Gap G3) may be tractable at
approximately 300-500 lines over 10-18 hours, if the Until propagation is handled via
"always take the left branch (resolve psi directly)" in the oracle construction.
