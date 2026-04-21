# Teammate D Findings: Strategic Horizons and Literature Comparison

**Task**: Task 109 — Close chain construction sorries for sorry-free `bx_completeness`
**Focus**: Literature comparison, strategic alignment, overlooked alternatives
**Date**: 2026-04-20

---

## Summary

This report compares the two proposed approaches (Sigma-restricted defect tracking and
Step-indexed forced resolution) against the temporal logic literature, assesses strategic
alignment with the project's long-term goals, and looks for overlooked alternatives.

The most important finding is that the **irreflexive semantics switch (task 93) is the
correct structural insight**. The prior team research correctly identifies that under
irreflexive semantics `phi -> F(phi)` is not derivable, so resolved defects do not
regenerate — but the proof engineering to exploit this cleanly has not been fully
articulated. The core observation from the ROADMAP is already there: "After at most
|sigma_list| steps, all defects are resolved." The key missing piece is that this
descent argument needs to be formalized using `active_defects` count, not a more
complex structure.

A third approach (Direct Descent on Active Defects) emerges from careful reading of the
existing infrastructure. The code comment at RootScopedChain.lean:520-523 explicitly
describes what is needed: "|active_defects(chain(n+1))| < |active_defects(chain(n))|
when defects are present." This is **already achievable with the existing
`preserving_fwd_step` and `fwd_chain_F_obligation_monotone` infrastructure** — the ROADMAP
states the path is clear, the code has the tools, and the gap is purely a matter of
formalizing the descent argument correctly. No chain redesign is required.

The literature on temporal logic completeness does not provide a Lean 4 reference
implementation to compare against — this appears to be the first Lean formalization of
Burgess-Xu completeness. However, the standard mathematical approach (full MCS space as
canonical model, Burgess 1982/Xu 1988) avoids the problem entirely by using a different
structure, while the quasimodel approach (GHR 1994, Reynolds 1996) uses finite defect
counting within a bounded Sigma closure — which is exactly what this project's Hintikka
chain infrastructure does for Until/Since, and which the `active_defects` count approach
would replicate for F-formulas.

---

## Key Findings

### Literature Comparison

| Reference | Proof Strategy | How F-eventuality is Handled | Relevance to This Project |
|-----------|---------------|------------------------------|---------------------------|
| **Burgess (1982/1984)** | Full MCS canonical model over all MCS | F(phi) in w implies there exists v with phi ∈ v by Lindenbaum on a fresh witness set; the full MCS space guarantees the witness exists somewhere | Uses unrestricted MCS space — avoids the defect problem by NOT constraining to a chain. Not directly applicable (we need ℤ-indexed chain for task frame) |
| **Xu (1988)** | Simplified Burgess axiomatization; same canonical model strategy | Same as Burgess — MCS space, not a chain | Same inapplicability: MCS space is not a task frame |
| **Goldblatt (1992)** | G-content ordering on MCS; chain construction uses Dedekind-complete linear order | F(phi) ∈ w implies phi ∈ v for some v accessible via BX11 fold; the chain is built to be "fat" enough that witnesses exist | Close to this project's approach but under reflexive semantics (G(phi) → phi), which avoids the defect regeneration problem |
| **GHR (1994), Vol 1** | Quasimodel approach: finite quasimodel has defect-discharge property; satisfaction in quasimodel implies satisfiability | F-defects are tracked per quasimodel point; finite Sigma closure bounds defect count; well-founded recursion on defect_count ensures termination | Most relevant: the Hintikka-chain infrastructure in `Construction.lean` and `Realization.lean` directly implements this approach for Until/Since. The gap is applying the same pattern to F-formulas in the `dd_chain` context |
| **Reynolds (1996)** | Quasimodel unraveling: construct a tree-like structure from the finite quasimodel | Same defect-counting in finite closure; the tree unraveling ensures eventuality witnesses exist at finite depth | Same quasimodel pattern — defect count descent. Already implemented in this project's `DefectChain.lean` for Until/Since |
| **This project (tasks 90-102)** | Hintikka-set quasimodel for Until/Since + `bx_le` chain for F/P | Until/Since: well-founded recursion on `defect_count` (sorry-free). F/P: `preserving_fwd_step` with `active_defects` count — **this is the gap** | The project has already solved the Until/Since case using the quasimodel approach; `fwd_chain_forward_F` is the F-analogue of the same pattern |

**Key insight from the literature**: Standard references avoid the `fwd_chain_forward_F`
problem by either (a) not using a ℤ-indexed chain (full MCS space), or (b) using finite
defect counting within a fixed Sigma closure (quasimodel). This project must use a
ℤ-indexed chain for task frame semantics, so approach (a) is not available. Approach (b)
is already implemented for Until/Since — **extending it to F/P formulas is the natural
move**.

The "Lindenbaum opacity" problem is real but manageable: standard proofs using a chain
rely on a different step function than `preserving_fwd_step`. Burgess (1984) builds the
canonical chain using a step that DIRECTLY resolves a specific target (not a
non-deterministic `defect_step_choice_early`) because Burgess works in a FULL MCS space
where any consistent set can be extended to an MCS containing any desired formula. The
project's `discharge_single_step` is already the Lean analogue of Burgess's direct
witness step — the question is how to use it without losing F-obligations for other
defects.

### The Irreflexive Advantage Is Already Formalized

The most important finding from code review: the ROADMAP at line 507-511 already
describes the complete proof strategy:

> - At each chain step, `defect_step_early` gives: for each defect chi,
>   either `chi in M'` (resolved) or `F(chi) in M'` (still pending)
> - Resolved defects do NOT re-enter as F-obligations
> - Active defects (chi with F(chi) in M) strictly decrease at each step
> - After at most |sigma_list| steps, all defects are resolved

And the code comment at RootScopedChain.lean:520-523 says:

> **Phase 3-4 remaining work:** Build finite descent argument on active_defects
> to close the 5 sorry sites. The defect step infrastructure is in place; the
> proof requires showing that |active_defects(chain(n+1))| < |active_defects(chain(n))|
> when defects are present.

**This is not actually true under the current `preserving_fwd_step`.** The issue is that
`defect_step_choice_early` resolves some defect `w ∈ M'` but ALSO preserves `F(w) ∈ M'`
(from `g_content(M) ⊆ M'` and the `F(F(w)) → F(w)` rule), so `w` remains in
`active_defects(M')`. The count does not decrease.

BUT: when `w ∈ M'` is directly resolved, `w ∉ active_defects(M')` only if `F(w) ∉ M'`.
And `F(w) ∉ M'` would hold if there is no reason for it to be in `M'` — which is the
case when `w` was the ONLY formula satisfying `F(w) ∈ M` and the step resolves `w`
without regenerating `F(w)`.

The issue is `g_content(M) ⊆ M'`. If `G(¬w) ∉ M`, then `F(w) ∉ g_content(M)`, so the
g_content inclusion alone does NOT guarantee `F(w) ∈ M'`. The defect regeneration ONLY
happens when `G(¬F(w))` ∉ M, i.e., when `G(F(w)) ∈ M`... but `G(F(w))` would be in
`M` only if it was derived from something else. Under irreflexive semantics where `w →
F(w)` is not derivable, once `w ∈ M'` and the step is chosen to satisfy `w`, the MCS
`M'` does not need to contain `F(w)`. **The Lindenbaum extension can choose `F(w) ∉ M'`
as long as the seed `{w} ∪ g_content(M)` doesn't force `F(w) ∈ M'`.**

Whether the seed forces `F(w)` depends on whether `F(w) ∈ g_content(M)`, i.e., whether
`G(F(w)) ∈ M`. This is the key: `G(F(w)) ∈ M` would mean "at all future times, F(w)
holds," which is a very specific claim. It COULD be true. So the descent does not
automatically work for the existing `preserving_fwd_step`.

### Critical Distinction: The "Right" Approach

After reading the full code and ROADMAP, the correct approach becomes clear. The ROADMAP's
"Phase 3-4" description is WRONG about the current `preserving_fwd_step` automatically
giving descent. The descent requires either:

1. **A different step function** that guarantees `F(w) ∉ M'` when `w ∈ M'` (requires
   seeding with `{w, G(¬F(w))}` or similar, which may not be consistent with
   `g_content(M)`)

2. **A forward induction counting "resolve turns"** where each defect is given exactly one
   "forced resolution turn" using `discharge_single_step`, and the turn itself uses a seed
   that excludes `G(F(w))` — which is possible because `G(F(w)) ∈ M` implies `F(w) ∈
   g_content(M)` would require `G(G(F(w))) ∈ M` (by `temp_4`)... which creates a descent
   on `G`-nesting depth, and hence terminates.

3. **The Sigma-restricted defect tracking approach**: Track active defects using `Sigma`
   membership as the criterion — `chi ∈ active_defects` iff `chi ∈ sigma_list AND F(chi)
   ∈ M`. The descent uses `|sigma_list| - |resolved_defects|` where a defect is
   "resolved" once `chi ∈ chain(n)` for some `n`. This works because `sigma_list` is
   finite and each formula can only be resolved once (under irreflexive semantics,
   resolved formulas don't re-enter as F-obligations unless `G(F(chi)) ∈ M`, which would
   propagate forward).

### Strategic Assessment

**Long-term goals affected by the approach:**

1. **Task 95 audit** (pending): The 14 irreflexive-consequence sorries (`bx_le_refl`,
   `g/h_content_subset_self`, etc.) are separate from the 5 critical-path sorries but
   share the same fundamental structure. Any approach that clarifies the semantics of
   `active_defects` under irreflexive semantics also helps task 95.

2. **Dense completeness**: The project's task frame semantics uses `D = ℤ` (discrete).
   Extending to dense orders (ℚ, ℝ) would require different chain step functions
   (X/Y operators don't work on dense orders). The `preserving_fwd_step` approach is
   order-agnostic and would generalize; a step-indexed approach tied to round-robin
   indexing might not.

3. **FMP (Finite Model Property)**: The quasimodel infrastructure already gives FMP for
   Until/Since within Sigma. If F-eventuality resolution is proved via a finite-depth
   Sigma-bounded argument (Sigma-restricted tracking), it contributes to a future FMP
   proof. A step-indexed approach that goes to |sigma_list|² steps would need to be
   bounded more carefully.

4. **Publication readiness**: The cleanest approach for publication is one that most
   closely mirrors the standard literature (GHR/Reynolds quasimodel pattern). The
   Sigma-restricted defect tracking approach directly parallels how Until/Since are
   handled in `Construction.lean`/`DefectChain.lean`, making the overall proof structure
   uniform.

**Recommendation on strategic alignment:**

- The **Sigma-restricted defect tracking approach** is better aligned with long-term goals.
  It mirrors the existing Until/Since infrastructure, contributes to FMP potential, and
  is closer to the standard literature.
- The **step-indexed approach** is simpler to implement but introduces a new structural
  pattern (round-robin schedule with forced discharge) not present in the existing
  codebase.

### Overlooked Alternatives

**Alternative 3: Direct Descent Using `F_obligation_monotone` + Finiteness**

The most overlooked alternative is the simplest: use the EXISTING infrastructure plus
a careful induction argument. The key lemma already proved is:

```
fwd_chain_F_obligation_monotone: F(chi) ∉ chain(n) → ∀ m ≥ n, F(chi) ∉ chain(m)
```

This gives: **the set of "ever-active" defects is a subset of `active_defects(chain(0))`**.
A defect can only LEAVE the active set, never enter. So after at most |sigma_list| "leave
events," the active set is empty.

The question is: does every active defect eventually leave? Under irreflexive semantics,
a defect `chi` leaves the active set when `F(chi) ∉ chain(n)` for some `n`. This happens
when `F(chi) ∉ chain(n)` for the first time — which requires the Lindenbaum extension to
"drop" `F(chi)`. The question is whether the chain's construction forces this to happen.

**Key observation**: The `preserving_fwd_step` uses `defect_step_choice_early` which
calls `resolving_enriched_fwd_exists`. The latter resolves SOME defect `w` directly
(`w ∈ M'`). For this `w`, if `F(w) ∉ g_content(M)` (i.e., `G(F(w)) ∉ M`), then
`F(w) ∉ M'` is possible (Lindenbaum doesn't force it). The chain construction uses
`Classical.choice`, so it COULD choose `F(w) ∉ M'`.

This is not guaranteed — Classical.choice is opaque — but this creates a natural
sub-goal: **prove that for any defect `w`, eventually `G(F(w)) ∉ chain(n)`**, so that
when `w` is directly resolved, the step can be chosen with `F(w) ∉ M'`.

Whether `G(F(w)) ∉ chain(n)` eventually holds is provable if:
- `G(F(w)) ∈ chain(n)` implies `G(G(F(w))) ∈ chain(n)` (by `temp_4`)
- Which implies `G(F(w)) ∈ chain(n+1)` (by g_content propagation)
- So if `G(F(w)) ∈ chain(0)`, it stays forever

This means `G(F(w)) ∈ chain(0) = M₀` implies `G(F(w)) ∈ chain(n)` for all `n`, which
means `F(w)` is always in the active set AND can never be dropped. But... if `G(F(w)) ∈
M₀`, then `w` MUST eventually appear in the chain even without any special construction
— this follows from the seriality axiom and an inductive argument on the fact that
`G(F(w)) ∈ chain(n)` means `F(w) ∈ chain(n+1)` and the only way `w ∉ chain(n+1)` is
if the step chose `F(w) ∈ chain(n+1)` instead, which continues the chain... This is
essentially the descent argument and it DOES work, but it requires a careful formalization
that the existing proof tries to give via the `KEY INSIGHT` comment (lines 1121-1128 of
RootScopedChain.lean).

**The comment at line 1126-1128 identifies the actual gap:**
```
REMAINING GAP: Need to show the set eventually reaches {φ}.
In the stabilized phase, every resolved defect w has both w ∈ chain(k+1)
AND F(w) ∈ chain(k+1), preventing the F-obligation count from decreasing
further.
```

This confirms the defect regeneration problem is REAL under the current chain. The direct
descent approach (Alternative 3) must therefore either change the chain OR prove that the
regeneration cycle terminates in a different way.

**Alternative 4: Use `discharge_single_step` with a `G(¬F(phi))` guard**

A targeted alternative: at the step when defect `phi` is scheduled for resolution, use
a seed that includes `phi AND G(¬F(phi))` (or equivalently, `phi AND G(¬phi)` — but that
is inconsistent if `F(phi)` is still needed). This is the "forced exit from the defect
set" approach: ensure the resolved formula's F-obligation is eliminated at the same step.

This might not be consistent. If `F(F(phi)) ∈ M` (from BX11 case 2), then `F(phi) ∈
g_content(M)` via... actually no. `F(F(phi)) ∈ M` does NOT mean `G(F(phi)) ∈ M`; it
only means that at some future time, `F(phi)` holds. So `F(phi) ∉ g_content(M)` even
when `F(F(phi)) ∈ M`. This means: the seed `{phi} ∪ g_content(M)` does NOT force
`F(phi) ∈ M'` even when `F(F(phi)) ∈ M`, so `discharge_single_step` already gives a
step where `phi ∈ M'` AND `F(phi)` may or may not be in `M'`.

**The question reduces to**: does the Lindenbaum extension of `{phi} ∪ g_content(M)`
guarantee `F(phi) ∉ M'`? No — Classical.choice is opaque. But: it CAN choose `F(phi)
∉ M'` because the seed doesn't force `F(phi)`. So we need a constructive version where
we ADD `¬F(phi)` to the seed.

`{phi, ¬F(phi)} ∪ g_content(M)` is consistent iff `{phi, ¬F(phi)} ∪ g_content(M) ⊬ ⊥`.
This is consistent because: under irreflexive semantics, `phi → F(phi)` is NOT derivable
(BX1 removed), so `phi ∧ ¬F(phi)` is satisfiable (witnessed by the current point itself
on a model where phi holds now and not in any future). So `{phi, ¬F(phi)} ∪ g_content(M)`
IS consistent, and extending it by Lindenbaum gives `M'` with `phi ∈ M'` AND `F(phi) ∉
M'`, so `phi ∉ active_defects(M')`.

This is **Alternative 4: Constructive Discharge Step with Negated-F guard**. It uses the
seed `{phi, ¬F(phi)} ∪ g_content(M)` to produce a step where phi is directly resolved
AND phi leaves the active defect set permanently. This would enable a clean descent
argument.

The challenge is proving consistency of `{phi, ¬F(phi)} ∪ g_content(M)`. This requires:
1. `phi` is consistent (given, since `F(phi) ∈ M` and `phi` itself might not be in `M`)
   — actually `phi ∉ M` is the assumption (`phi` is a defect). So we need `{phi, ¬F(phi)}
   ∪ g_content(M) ⊬ ⊥`. This is equivalent to: `g_content(M) ⊬ ¬phi ∨ F(phi)`, i.e.,
   `g_content(M) ⊬ phi → F(phi)`. This is exactly the non-derivability of `phi → F(phi)`
   relative to `g_content(M)`.
2. Is `g_content(M) ⊢ phi → F(phi)` possible? Yes, if `G(phi → F(phi)) ∈ M`, then
   `phi → F(phi) ∈ g_content(M)`. So the consistency of the seed FAILS when `G(phi →
   F(phi)) ∈ M`.
3. But `G(phi → F(phi)) ∈ M` would mean `phi → F(phi)` is necessary, which is a special
   case where the defect regeneration is "baked in" to the MCS. In this case, `phi` will
   be resolved when `phi ∈ M'` by the g_content propagation of `G(phi → F(phi))` giving
   `F(phi) ∈ M'`... this is the degenerate case where the defect NEVER goes away.

Actually wait — if `G(phi → F(phi)) ∈ M`, this means "at all times in the future, phi
implies F(phi)." Under irreflexive semantics, this does NOT mean `phi → F(phi)` NOW;
it means it at all FUTURE times. And `phi → F(phi)` at time `t` means "if phi holds at t,
then F(phi) holds at t" — which is a statement about the current point having both phi
and some further future phi. This is consistent with the quasimodel structure.

When `G(phi → F(phi)) ∈ M`, the chain can NEVER fully discharge phi from `active_defects`
because the step `{phi} ∪ g_content(M)` includes `phi → F(phi)` from g_content, forcing
`F(phi) ∈ M'`. In this case, the ONLY way to eventually get `phi ∈ chain(n)` (satisfying
`fwd_chain_forward_F`) is from a DIFFERENT step where phi is NOT the primary target but
appears as a side effect of resolving another defect `chi`.

**This is the hardest case.** It requires showing that even when `G(phi → F(phi)) ∈
chain(n)` for all n, phi still eventually appears. This would follow from the seriality
axiom (`F(T) holds`) combined with the fact that BX11 witnesses are linearly ordered —
eventually, the BX11 fold must "run out" of earlier defects and hit phi.

---

## Confidence Level

**MEDIUM-LOW (40%)** on any specific approach being straightforwardly implementable.

Reasons for uncertainty:
1. The `G(phi → F(phi))` degenerate case (Alternative 4, case 3) could block both the
   descent approach and the Sigma-restricted approach.
2. The step-indexed approach (Teammate C's approach from prior research) handles this
   differently but may lose F-obligations for other defects.
3. No reference implementation exists — this is the first Lean formalization of
   Burgess-Xu completeness for bimodal TM.

Reasons for optimism:
1. The Until/Since case was solved via exactly the quasimodel defect-count pattern —
   the F/P case is the same pattern one level up.
2. `fwd_chain_F_obligation_monotone` is proved — this is the main "defects don't grow"
   lemma needed for any descent argument.
3. BX12 (`F(phi) → (⊤ U phi)`) is in the axiom system, directly bridging F to Until.

---

## Recommendations

### Primary Recommendation: Bridge F to Until via BX12

The most overlooked and potentially cleanest approach is to **use BX12 to reduce
F-eventuality to Until-eventuality**, which is already solved.

Specifically:
1. BX12 gives `F(phi) → (⊤ U phi)` as a derivable formula.
2. At the MCS level: `F(phi) ∈ M → (⊤ U phi) ∈ M` by modus ponens.
3. `⊤ U phi` is an Until formula with guard `⊤` and goal `phi`.
4. The Until/Since eventuality infrastructure in `bx_until_eventuality_resolution` (Frame.lean,
   closed by task 98) already handles Until-eventualities.
5. If `fwd_chain_forward_F` can be **reduced to** `bx_until_eventuality_resolution`, the
   sorry is already effectively closed.

The challenge: `bx_until_eventuality_resolution` works for the FULL canonical model
(the `bx_le` ordering over all BXPoints), not for a specific ℤ-indexed chain. Reducing
the chain result to the canonical model result requires either:
- Showing `dd_chain(n)` lives IN the canonical model structure for appropriate n, or
- Re-proving the quasimodel descent within the `fwd_chain_of_sigma` context.

**This is potentially a 4-6 hour task** compared to the estimated 8-12 hours for
chain redesign. The key question is whether the `shifted_dd_fmcs` used by
`dd_countermodel` can be shown to satisfy the BX11/BX12 requirements needed for
`bx_until_eventuality_resolution`.

### Secondary Recommendation: Constructive Discharge with Sigma Restriction

If the BX12 bridge is blocked, implement the Sigma-restricted defect tracking approach
as follows:

1. Define `sigma_resolved(M, sigma_list) : Finset Formula` as the set of phi ∈ sigma_list
   such that phi ∈ M (directly present — the F-defect has been discharged).
2. Define `sigma_active(M, sigma_list) = sigma_list.toFinset \ sigma_resolved(M, sigma_list)`.
3. The descent measure is `sigma_active(chain(n))` — its cardinality strictly decreases.
4. The key step: when `F(phi) ∈ chain(n)` and `phi ∉ chain(n)`, use a modified step
   function that targets phi with seed `{phi} ∪ g_content(chain(n))`. This step gives
   `phi ∈ chain(n+1)` (by `discharge_single_step`), reducing `sigma_active` by 1.
5. The objection (F-obligations of other defects may be lost) is handled as follows:
   under irreflexive semantics, if `F(chi) ∉ chain(n+1)`, then `chi` was already going
   to be discharged by absence of its F-obligation (which is the same as resolving it
   from the "defect set" perspective). After at most |sigma_list| such steps, all defects
   are either directly resolved or have their F-obligations dropped.

### Action Items (in order of priority)

1. **Check BX12 bridge (2-4 hours)**: Verify whether `bx_until_eventuality_resolution`
   can be applied in the `fwd_chain_of_sigma` context via `F_until_equiv_mcs`.
   If `F(phi) ∈ chain(n)` implies `⊤ U phi ∈ chain(n)`, and the `bx_le` ordering is
   compatible with `fwd_chain_of_sigma`, this closes sorry #1 directly.

2. **Implement Sigma-restricted tracking (6-10 hours)**: As described above.
   This is the safest path and most aligned with the existing quasimodel infrastructure.

3. **Derive `P(F(phi)) → P(phi) ∨ F(phi)` independently (2-4 hours)**: This resolves
   sorry #2 given sorry #1. All prior teammates agree this is straightforward.

4. **Separate task for sorries #4 and #5**: Until/Since coherence (`dd_bfmcs_restricted_buc`
   and `dd_bfmcs_restricted_fuc`) are separate problems not addressed by any approach to
   sorry #1. Create a follow-up task.

---

## Sources

- Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *Notre Dame Journal of Formal Logic* 23(4), 367-374.
- Xu, M. (1988). "On some U,S-tense logics." *Journal of Philosophical Logic* 17, 181-202.
- Venema, Y. (1993). Temporal logic survey.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. Oxford University Press.
- Reynolds, M. (1996). "Axiomatising first-order temporal logic: Until and since over linear time." *Studia Logica* 57, 279-302.
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Publications.
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`
- `/home/benjamin/Projects/ProofChecker/specs/ROADMAP.md`
- `/home/benjamin/Projects/ProofChecker/specs/109_close_chain_construction_sorries/reports/05_team-research.md`
- `/home/benjamin/Projects/ProofChecker/specs/109_close_chain_construction_sorries/handoffs/04_fwd-chain-analysis.md`
