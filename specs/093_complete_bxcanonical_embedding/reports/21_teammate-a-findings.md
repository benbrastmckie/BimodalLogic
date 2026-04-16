# Teammate A Findings: Primary Approach Analysis

**Task**: 93 - Complete BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Role**: Primary approach — analysis of mathematically correct long-term construction
**Date**: 2026-04-16

## Key Findings

1. **The forward_F problem is a genuine mathematical gap in the chain definition**, not a
   proof strategy failure. The `enriched_fwd_step` construction is provably too weak:
   `.choose` in `set_lindenbaum` is unconstrained and can perpetually select the
   `F(psi)` disjunct over `psi` at every visit step. This is not fixable within the
   existing chain definition.

2. **19 specific approaches have been tried and definitively ruled out** (cataloged in
   Report 17). Three additional approaches from the most recent rounds (fold-order
   trick, BX12/Until reformulation, bilateral pairs) have also been assessed and
   rejected. The failure mode is consistent: every approach either relocates the
   non-determinism problem rather than eliminating it, or requires chain replacement
   with ~30 downstream theorem re-proofs.

3. **The two most recently proposed "low-cost" interventions require deeper analysis**:
   - Fold-order trick (process target LAST in BX11 fold): promising but unvalidated.
     BX11 Case 3 puts the LEFT operand under F; if target is rightmost it cannot be
     displaced. This is the only remaining sub-30-LOC intervention worth attempting.
   - BX12 approach (`F(psi) -> top U psi`): obstacles confirmed (abstract BXPoints
     vs chain indices; `top U psi` not in `deferralClosure(root)`). Ruled out.

4. **The mathematically correct long-term approach is a modified chain construction**
   using `discharge_single_step` at each targeted step, with the F-preservation
   problem handled structurally (not through the Lindenbaum seed). The "never-resolved
   count" termination measure proposed in Report 18 is the most concrete and grounded
   formulation.

5. **Published completeness proofs (Burgess 1984, Goldblatt 1992, GHR 1994) avoid this
   problem entirely** by working semantically on integer models where F-witnesses have
   well-ordered temporal structure. No published proof addresses this syntactic
   obstruction. The codebase's construction is the first Lean 4 formalization of BX
   completeness, and this gap represents a genuine novel difficulty.

6. **The quasimodel bridge remains a viable fallback** with important caveats: the
   `sigma_le` vs `g_content` incompatibility identified in earlier reports may be
   addressable now that `Frame.lean` is sorry-free, but no concrete plan exists.

## Recommended Approach

### Immediate (2 hours): Fold-Order Trick

Attempt to modify `enriched_fwd_fold_with_witness` so that `target` is processed LAST
rather than FIRST among the formula list.

**Mathematical justification**: In `enriched_fwd_fold_with_witness`, BX11 is applied
between the accumulated compound `beta` and each new formula `chi`. Case 3 fires when
`F(F(beta) AND chi) in M`, displacing beta (including target) under F, and making chi
the new direct witness. If target is processed last, it enters as the RIGHT operand
`chi` in the FINAL BX11 application. BX11 Case 3 puts the LEFT operand under F (see
RootScopedChain.lean:338-360: `F(F(beta) AND chi)` makes `beta` the F-wrapped one and
`chi` the direct witness). When target is the right operand (`chi`), Case 3 gives
`F(F(beta) AND target)`, meaning `target` IS the direct witness (right conjunct). So
target would be guaranteed direct regardless of which BX11 case fires.

**Critical check needed**: Verify that `enriched_fwd_fold_with_witness` produces a
compound of the form `F(... AND target)` when target is the last element, and that
the seed `{target, rest-compound} union g_content(M)` remains consistent. The seed
consistency follows from `enriched_resolving_seed_consistent` applied to the inner
formula `F(... AND target) in M`.

**Why this is the highest-priority attempt**: It requires only reordering the argument
list passed to the fold, does not change the chain definition, and if correct would
close `rr_fwd_chain_forward_F` in the existing infrastructure without any downstream
re-proofs.

**Risk**: The fold processes a variable `others` list in whatever order it's provided.
The current call in `enriched_fwd_step` (RootScopedChain.lean:584-586) passes `others`
as `sigma_list.filter (...)` with target excluded. Adding target as the LAST element
(`others ++ [target]`) changes what `resolving_enriched_fwd_exists` receives. The
existing proof of `resolving_enriched_fwd_exists` may not immediately support this
without modification.

### Primary (15-20 hours): Modified Chain with Never-Resolved Count

If the fold-order trick fails, the correct path is to redefine the forward chain so
that at each targeted step, `discharge_single_step` is used for the specific target
(guaranteeing `target in M'`), with a separate mechanism handling F-preservation.

**Mathematical justification**: The core tension is:
- `discharge_single_step`: gives `target in M'` and `g_content(M) subset M'`, but
  F-formulas of other formulas are NOT preserved (Lindenbaum may add `G(neg chi)`)
- `enriched_fwd_step`: preserves all F-formulas disjunctively, but gives only
  `target in M' OR F(target) in M'` for the scheduled target

The "never-resolved count" resolves this tension by accepting that F-formulas may be
killed at resolving steps, but using a well-founded count to guarantee every formula
is eventually directly resolved:

```
never_resolved_count chain n :=
  |{chi in sigma_list | forall m <= n, chi not_in chain(m).val}|
```

This count starts at `sigma_list.length`, decreases by at least 1 at each step where
the target is resolved (which `discharge_single_step` guarantees), and reaches 0 in
at most `sigma_list.length` steps. Well-founded induction on this count provides
the termination argument for forward_F.

**Key obstacles to address**:

1. **F-preservation between steps**: With `discharge_single_step`, `G(neg psi)` may
   enter chain(k+1) at non-psi steps, permanently killing `F(psi)`. This means
   `F(psi) in chain(n)` does NOT imply `F(psi) in chain(n+1)` in the new chain.
   Therefore `rr_fwd_chain_F_propagate` (currently proved) would need to be reproved
   or replaced by a weaker version.

2. **The invariant**: The correctness argument requires proving that if
   `F(psi) in chain(n)` and psi has never been resolved in steps 0..n, then the
   never-resolved count at step n is positive. This needs careful formalization as
   a simultaneous induction with the chain definition.

3. **Downstream re-proofs**: ~30 theorems depend on `rr_fwd_chain`'s step-by-step
   properties. These include `rr_fwd_chain_g_content_step`,
   `rr_fwd_chain_F_obligation_persists`, `rr_fwd_chain_F_obligation_forward`, etc.
   Most are mechanical reproof from the new step specification.

**Why this is mathematically correct**: The key insight is that the existing
construction has TWO conflated responsibilities: (a) guaranteeing F-preservation, and
(b) resolving targets. `enriched_fwd_step` tries to achieve both simultaneously via
the BX11 fold, but the fold cannot guarantee target resolution without a global minimum
(which may not exist due to 3-cycles). The modified construction separates them: target
resolution is guaranteed at EACH step by definition, while F-preservation becomes a
consequence of the chain completing within a finite number of steps.

### Fallback: Quasimodel Bridge

If both above approaches fail, the quasimodel infrastructure (2,289 lines, sorry-free)
should be re-evaluated as a basis for the BFMCS construction. The `sigma_le` vs
`g_content` incompatibility was the primary rejection reason in earlier rounds, but the
correct framing may be: use the quasimodel as a SEMANTIC witness that the BFMCS
property holds, rather than attempting a direct syntactic bridge.

## Evidence and Supporting Analysis

### Why the Fold-Order Trick is Technically Plausible

The BX11 fold in `enriched_fwd_fold_with_witness` (RootScopedChain.lean:280-362)
processes elements left-to-right. The inductive step has three cases based on
`temp_linearity_mcs h_mcs beta chi`:

- Case 1 (`F(beta AND chi) in M`): new compound = `beta AND chi`, BOTH stay direct
- Case 2 (`F(beta AND F(chi)) in M`): new compound = `beta AND F(chi)`, beta stays
  direct, chi becomes F-wrapped
- Case 3 (`F(F(beta) AND chi) in M`): new compound = `F(beta) AND chi`, beta gets
  F-WRAPPED, chi becomes direct

The witness at each step tracks which ORIGINAL formula from the accumulated tracked
list is the direct witness (lines 280-284 show the base case). In Case 3, the witness
CHANGES to `chi` (the element just added). If target is the LAST element added (i.e.,
it plays the role of `chi` in the final step), then Case 3 makes TARGET the direct
witness, not beta. So target would be guaranteed direct after the final fold step.

This is a sound structural observation. The question is whether the resulting compound
`F(beta_accumulated AND target) in M` yields a consistent seed via
`enriched_resolving_seed_consistent`. It does: `enriched_resolving_seed_consistent`
requires `F(psi AND alpha) in M` for some alpha, and the output gives exactly
`F(beta_accumulated AND target) in M` where target plays the role of psi.

### Why the Published Literature Does Not Have This Problem

Burgess (1984) and Goldblatt (1992) construct canonical completeness proofs for linear
tense logics by building a sequence of maximal consistent sets where at each stage, the
next MCS is chosen to witness a specific eventuality. Crucially, they do not need a
"fold" or "compound" construction: they simply assert "there exists an MCS M' with
F(psi)-obligation resolved" and instantiate this via the axiom of choice. The existence
is immediate from the Lindenbaum lemma applied to `{psi} union g_content(M)`.

The difficulty in the present formalization arises from the need to prove a SINGLE
chain satisfies forward_F for ALL formulas simultaneously. The published proofs handle
each formula individually and then combine — but this requires a separate (per-formula)
chain, which cannot be assembled into a single Int-indexed BFMCS without the global
chain construction.

Gabbay-Hodkinson-Reynolds (1994) use "adequate sets" and König's lemma to build a tree
of MCSs and then extract a branch. The tree-based approach avoids the single-chain
problem entirely. However, adapting this to Lean 4 would require implementing König's
lemma for a potentially non-finitely-branching tree, which is a substantial new
formalization effort (estimated 50+ hours).

### Why the 3-Cycle Counterexample Blocks Global BX11 Minimum

Report 16 (Teammate A) established a concrete semantic counterexample showing
`bx11_earlier` is non-transitive. With formulas `a`, `b`, `c` and witnesses at times
1, 2, 3 respectively (but with c's "next" at 4 giving c's BX11 with a):

- `F(a AND F(b)) in M` (a's witness 1 < b's witness 2): `bx11_earlier M a b`
- `F(b AND F(c)) in M` (b's witness 2 < c's witness 3): `bx11_earlier M b c`
- `F(c AND F(a)) in M` (c's witness 3 < a's "next" witness 4): `bx11_earlier M c a`

This 3-cycle means no single formula is `bx11_earlier` than ALL others in the set
{a, b, c}. Therefore `target_stays_direct_in_fold` (which requires `h_earliest : forall
chi in others, bx11_earlier M target chi`) cannot be satisfied when the defect set has
3+ elements in a cycle. This definitively rules out any approach relying on a global
BX11 minimum.

### The F-Obligation Stability Fact

A key structural property established in the codebase:
- `rr_fwd_chain_F_obligation_forward` (proved): `F(psi) in chain(n)` implies
  `F(psi) in chain(m)` for all `m >= n`
- `rr_fwd_chain_F_obligation_backward` (proved): `F(psi) in chain(m)` implies
  `F(psi) in chain(n)` for all `n <= m`

Together: the set `{chi in sigma_list | F(chi) in chain(n)}` is EXACTLY CONSTANT
across all n. This is a strong fact that any approach MUST use. In particular, it
rules out the defect-count argument (every resolved formula immediately re-acquires its
F-obligation).

The never-resolved count `|{chi | forall m <= n, chi not_in chain(m)}|` is distinct
from the F-obligation set and CAN decrease monotonically -- that is the key advantage
of the modified chain approach.

## Confidence Level

**High (90%)** that the fold-order trick and the modified chain with never-resolved
count are the only two remaining viable approaches (for the chain-based strategy).

**Medium (50-60%)** that one of these two approaches can be successfully formalized
within 20 hours.

**Medium (40%)** that the fold-order trick (the 2-hour intervention) will succeed.
The mathematical argument is sound, but the Lean formalization may require modifying
`resolving_enriched_fwd_exists` and reprooving associated lemmas.

**Medium (55-65%)** that the modified chain with never-resolved count will succeed
(consistent with prior team consensus from Report 18).

**Low (15%)** that the quasimodel bridge can be made to work without a major new
formalization effort.

## Precise Next Steps

1. **Try fold-order trick first** (2-hour cap). Modify the call to
   `resolving_enriched_fwd_exists` in `enriched_fwd_step` to pass target as the
   LAST element rather than the first. Verify that:
   a. The compound produced by the fold has the form `F(beta AND target) in M`
   b. `enriched_resolving_seed_consistent` applies to this compound
   c. The Lean elaboration of the modified proof goes through without new sorries

2. **If fold-order trick succeeds**: Close `rr_fwd_chain_forward_F` using the
   existing `rr_fwd_chain_F_propagate` plus the new guarantee that the target is
   directly resolved at each visit step. This should close sorries 1, 2, 3, 4, 6
   in sequence, with sorry 5 (`dd_bfmcs_restricted_buc`) remaining independent.

3. **If fold-order trick fails**: Proceed to modified chain with never-resolved count.
   Budget 15-20 hours and accept ~30 downstream theorem re-proofs. The mathematical
   correctness is high confidence; the formalization cost is real but bounded.

4. **Do not attempt quasimodel bridge** unless both above approaches fail and the
   backward Until coherence (sorry 5) is also resolved by other means.
