# Research Report: WorldHistory Convexity Analysis (Teammate A)

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Session**: sess_1774020213_d32e65
**Role**: Teammate A — Primary Approach Analyst
**Focus**: Mathematical structure of the WorldHistory convexity blocker

---

## Key Findings

1. **The sorry on `convex` is mathematically unjustifiable.** The image of a countable
   discrete chain under an order-embedding into Rat is never convex (as a subset of Rat).
   There is always a rational strictly between any two distinct embedded points, and that
   rational is not in the image. The sorry cannot be resolved with the current domain
   definition.

2. **The sorry on `convex` is architecturally unnecessary.** The current implementation in
   `FlagBFMCSRatBundle.lean` takes a fundamentally different path from the parametric
   pipeline design. The WorldHistory route through `shiftedFlagWorldHistory` was added
   *ad hoc* during Phase 3, bypassing the intended `BFMCS Rat → parametric_to_history`
   pipeline. The `convex` field does not appear anywhere in that pipeline.

3. **The `respects_task` sorry has already been resolved** (lines 370-404 of
   `FlagBFMCSRatBundle.lean`). The `convex` sorry is the only open obligation in
   `shiftedFlagWorldHistory`.

4. **The truth lemma sorry (Phase 4) is independent.** `shifted_truth_lemma` is marked
   sorry separately and is not blocked by `convex`. It would need to be proved regardless
   of which construction is used.

5. **A direct fix exists: replace the domain predicate.** Instead of using the image of
   the discrete embedding as the domain, we should use `Set.univ` (all of Rat) together
   with a state function that is defined everywhere via the retract. This makes the
   domain trivially convex. The `respects_task` proof already handles `s ≤ t` using
   `shifted_flag_retract`, and extending that function to all of Rat is straightforward
   (it already exists as a partial inverse and can be extended by any default).

---

## Semantic Analysis: Why Does Convexity Matter?

### The Paper's Intent (WorldHistory.lean lines 10-29)

The JPL paper requires that a world history `τ: X → W` have a **convex** domain
`X ⊆ D`. The semantic reason is:

- The **past/future operators** (`G`, `H`, `F`, `P`) quantify over times **within
  the same history**. For the truth clause of `Gφ` to be well-behaved, we need: "at
  every future time *in the domain*" to actually cover a connected interval.
- If the domain had gaps, a formula like `Gφ ∧ ¬Fφ` could be trivially satisfiable
  by placing a gap at the right point — the history would "skip over" the future time
  where `φ` fails.
- More precisely, convexity is needed for the **time-shift construction**
  (`WorldHistory.time_shift`): shifting a history by `Δ` must produce another valid
  history with a valid domain. If the domain is non-convex, the shifted domain may
  contain a time `t` without containing `t - ε` for small `ε`, violating the
  semantics of past operators.

### Is Convexity Essential for the Truth Lemma?

For the **canonical completeness** argument (not the general semantic theory), the
answer is nuanced:

- **In the general semantic theory**: convexity is essential because it ensures the
  temporal operators are well-defined and `time_shift` works.
- **For the canonical model**: we only ever evaluate formulas at times *in the domain*
  (i.e., times that correspond to actual chain elements). The `truth_at` definition
  only quantifies over times in the domain for past/future clauses. If we ensure that
  *all* times in the domain that we care about have MCS states, we do not actually
  need the domain to be all of Rat.

The subtlety: `truth_at` for `Gφ` at time `t` requires `φ` to hold at all `t' > t`
**in the domain**. If the domain is the full chain image (all rational images of chain
elements), then `Gφ` is correctly interpreted over all chain successors. A non-convex
discrete domain is semantically coherent for the canonical proof — it just does not
satisfy the `WorldHistory.convex` type constraint as currently formulated.

**Conclusion**: Convexity is a **syntactic constraint** in the Lean type that is
stronger than what the completeness argument actually requires. The argument only
needs that the domain is closed under the temporal operators' quantification range,
which for a discrete chain is just the chain itself.

---

## Structural Analysis: Discrete vs. Continuous Tension

### The Core Incompatibility

The construction uses:
```
ChainFMCSDomain F   →[shifted_flag_embed]→   ℚ
(discrete chain)         (order-preserving)   (dense)
```

The image `ShiftedFlagTimeDomain F center ⊆ ℚ` is:
- **Countable**: inherited from chain countability
- **Discrete** in the sense that between any two consecutive image points, there are
  infinitely many rationals not in the image
- **Not dense** as a subset of Rat (fails density because it is a countable image of
  a discrete order)
- **Not convex** as a subset of Rat (precisely because it is sparse)

This creates a **type-level mismatch**: `WorldHistory` demands convexity in Rat, but
the construction naturally produces a sparse countable subset.

### Why the Tension is Artificial

The `WorldHistory` structure is designed for the *semantic* theory where `D = ℚ` and
histories are continuous-time trajectories. For the *canonical completeness* argument,
we are constructing a *specific* model to falsify a non-provable formula. We have
complete freedom in choosing the domain: we can choose it to be all of Rat.

The discrete chain does not need to be the *domain* — it only needs to determine the
*state function*. If we define:

```
domain := fun _ => True   -- all of Rat is the domain
states q := state at the chain element nearest to q
```

then convexity is trivially satisfied. The `respects_task` obligation then asks for
`task_rel (state s) (t - s) (state t)` for all `s ≤ t` in Rat — not just for
chain-image points.

**Problem**: With a dense domain, `respects_task` for non-chain-image points becomes
non-trivial. Specifically, for `s < t` both not in the chain image but between the
same two consecutive chain elements, `task_rel` requires either `s = t` (impossible)
or `CanonicalR (state s) (state t)`. But `state s = state t` (same chain element), so
`s = t` is required — but `s ≠ t`. This breaks `respects_task` for the case `d > 0`
but both `s, t` map to the same chain element.

**Deeper problem**: The `parametric_canonical_task_rel` requires:
- `d > 0` → `CanonicalR M N` (which implies `M ≠ N` by irreflexivity)
- `d = 0` → `M = N`

A constant state function over a non-degenerate interval violates the `d > 0` case
unless the task relation is made reflexive — but CanonicalR is irreflexive.

### The Real Solution: Use the Parametric Pipeline

The plan (v3, Phase 4) specifies using the pipeline:
```
BFMCS Rat → parametric_to_history → parametric_shifted_truth_lemma
```

The `parametric_to_history` function (in `ParametricRepresentation.lean`) constructs
a `WorldHistory` with domain `Set.univ` *or* with a domain restricted to the BFMCS
timeline — and it handles `convex` internally. The current `shiftedFlagWorldHistory`
bypasses this infrastructure entirely.

The current Phase 3 in `FlagBFMCSRatBundle.lean` is an *alternative* ad-hoc
construction that was intended as a stepping stone but was not connected to the
parametric pipeline. The `convex` sorry signals that this stepping stone leads to a
dead end.

---

## Recommended Approach

### Option A: Abandon the Direct WorldHistory Construction (Recommended)

Do not try to resolve the `convex` sorry in `shiftedFlagWorldHistory`. Instead:

1. **Complete Phase 3** as originally planned in `plans/03_fmcstransfer-rat-plan.md`:
   build `BFMCS Rat` from the FlagBFMCS (not a WorldHistory directly).
2. **Feed into `parametric_to_history`** in `ParametricRepresentation.lean` to get a
   `WorldHistory` with a convex domain (the pipeline handles this).
3. **Apply `parametric_shifted_truth_lemma`** for the truth lemma.

The `shiftedFlagWorldHistory` definition and `shifted_truth_lemma` can be removed or
kept as dead code. The `neg_true_at_canonical_when_not_provable` theorem restructures
around the pipeline.

**Why this works**: The pipeline's `parametric_to_history` constructs histories with
full-domain (`Set.univ`) or interval domains that are provably convex. The MCS state
assignment is extended to all of Rat via the BFMCS family structure, which assigns an
MCS to every rational time (not just chain-image points). This is done via the FMCS
family mechanism, not a single chain embedding.

### Option B: Restrict to Chain-Image Domain with Modified WorldHistory

Create a variant of `WorldHistory` for the completeness proof that:
- Removes the `convex` field (or weakens it to "closed under the accessibility relation")
- Keeps all other fields

This is **not recommended** because it would require modifying core semantic
infrastructure (`WorldHistory.lean`) and would diverge from the paper's definition.

### Option C: Prove Convexity via Universal Domain

For the specific case of the canonical model, define the domain as all of Rat
(`fun _ => True`) and use a state function that maps every rational to the *nearest*
chain element (via some order-complete extension). Then prove `convex` trivially.

**Problem**: As analyzed above, `respects_task` fails for the constant-state interval
regions (between chain elements, `task_rel` requires `M = N` when `d = 0` but
`CanonicalR M N` when `d > 0`). This approach is mathematically inconsistent with
the `parametric_canonical_task_rel` definition.

### Summary Recommendation

**Use Option A.** The `convex` sorry is a symptom of the wrong construction approach.
The v3 plan was correct: go through `BFMCS Rat` and the parametric pipeline. The
current Phase 3 code in `FlagBFMCSRatBundle.lean` has partially implemented a direct
WorldHistory route that diverges from the plan. Redirect Phase 3 to build `BFMCS Rat`
as specified, then use the existing `parametric_to_history` infrastructure for the
WorldHistory, which naturally produces a convex-domain history.

The `shifted_truth_lemma` sorry (Phase 4) would then be replaced by
`parametric_shifted_truth_lemma`, which is already proved in
`ParametricTruthLemma.lean`.

---

## Confidence Level: HIGH

**Justification**:

1. **The non-convexity is provably true**: a countable dense-free subset of Rat is
   never convex (trivially, pick any two points, find a rational between them that's
   not in the image). This is not speculative.

2. **The pipeline solution is concrete**: `parametric_to_history` and
   `parametric_shifted_truth_lemma` are named, located infrastructure that the v3
   plan was already designed to use. The detour through `shiftedFlagWorldHistory` was
   an implementation artifact, not a design requirement.

3. **The Phase 4 pipeline wiring was specified in detail** in
   `plans/03_fmcstransfer-rat-plan.md` Phase 4 — including the exact theorem chain.
   That specification is still valid; only the wrong Phase 3 output needs to be
   replaced.

4. **One remaining sorry** would be the BFMCS Rat construction (Phases 3-4 proper),
   which involves the multi-family coherence. That sorry is well-scoped and aligns
   with the plan.

---

## References

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/Semantics/WorldHistory.lean` | WorldHistory structure, convex field definition |
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean` | Current implementation with `convex sorry` |
| `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` | BoxContent, CanonicalR, chain structure |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` | `parametric_canonical_task_rel` definition |
| `specs/1006_.../plans/03_fmcstransfer-rat-plan.md` | v3 plan specifying BFMCS Rat pipeline |
| `specs/1006_.../reports/05_rat-discrete-compatibility.md` | D=Rat compatibility analysis |
