# Blocker Analysis: Task #309

**Parent Task**: #309 - offdiag_two_anchor_fi_chain
**Generated**: 2026-07-06
**Blocker**: The R2 k=1 decision-gate probe (commit 8fd4340b1) NO-GOed: the arity-4 quant-layer
residual that blocked plan-v2 Phase 8 is inherent in the `nf_eval_nf` ENCODING (arity grows n→n+1 at
every depth descent), not in any carrier choice. Rabinovich 2014 never grows arity with depth (Def
4.1 folds each depth into a fixed-arity monadic E[Σ]-atom); the fix must be encoding-level.

## Root Cause

Task 309 plan v3 (`plans/03_offdiag-fi-chain-plan.md`) Phase 10 (R2, the decision gate) probed the
most faithful `k=1` carrier — `bracketEndChar_k1 qnf := nf_3var_bracket_xyt atomMap h_surj qnf.1`,
mirroring the sorry-free depth-0 collapse on the atom part `qnf.1` — against its
`BracketCarrierCorrect`-at-`k=1` obligation (`NfMultiAnchorBridge.lean:1546-1552`):

```
(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 [w,x,t] qnf
```

After `nf_3var_bracket_xyt_correct` discharges the atom layer and `refine ⟨w, h_atom, ?_⟩` splits off
the depth-1 quant conjunct, the residual (captured via `lean_goal` + `lean_multi_attempt`,
`NfMultiAnchorBridge.lean` ~:1632, per the Phase 10 `[BLOCKED]` record) is:

```
h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x fun _ ↦ t)) qnf.1
⊢ ∀ (sub_nf : NormalForm sig 0 (3 + 1)),
    (∃ x_1, nf_eval_nf M 0 (3 + 1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) sub_nf)
      ↔ qnf.2 sub_nf = true
```

This is an **irreducible arity-4 residual**: the env `[x_1,w,x,t]` couples the bracket witness `w` to
BOTH fixed endpoints `x,t` (plus a fresh existential `x_1`), and the atom-only carrier discarded
`qnf.2`. No `VecEA2 1` monadic component (`endpointLeft`@x / `endpointRight`@t / interval@w, each
reading a single point) can supply this coupling — discharging it requires a **navigated arity-3
characteristic**, exactly what G6 bars and exactly the plan-v2 Phase-8 obstruction, now falsified at
`k=1` in one bounded dispatch instead of a ~500-line brick attempt.

Two independent routes hit this identical wall: plan-v2 Phase 8 (`endChar` arity-4→3 re-bounding,
`NfMultiAnchorBridge.lean:1029`) and plan-v3 R2 (the `VecEA2` bracket carrier at `k=1`,
`NfMultiAnchorBridge.lean:1586-1618`). Report 03's H3 mapping table
(`reports/03_rabinovich-faithful-path-research.md` §2) already established the mismatch against
Rabinovich 2014 (PDF at `~/Projects/Literature/sources/rabinovich_2014/`): Def 3.1 (PDF p.4) keeps
endpoint/interval types `α_j,β_j` quantifier-free and one-variable; Lemma 3.2(2) (PDF p.4) caps free
variables at ≤2 by construction; Prop 3.5 (PDF p.5) collapses each existential witness into an
Until/Since bracket witness evaluated at FIXED endpoints; Def 4.1 (PDF p.5) folds each processed
quantifier depth into a **monadic** (arity-1) `E[Σ]`-atom before the next level is decomposed —
`nf_eval_nf`'s `n → n+1` arity growth per depth (`NormalForm.lean:198-207`) has no counterpart in the
paper. Report 03 anticipated exactly this outcome as candidate path (iii) ("Adjustment to the
NormalForm encoding itself"), flagged as "not recommended as the primary fix" for 309 in-task but
explicitly reserved as "the R2 no-go fallback ... the ONLY circumstance under which an encoding-level
task is spawned" (plan `plans/03_offdiag-fi-chain-plan.md` "Do NOT" list). That circumstance has now
occurred.

This is a genuine encoding-level gap, not a carrier-shape problem: the two-anchor `VecEA2` bracket
carrier shape from task 309 Phase 9 (`BracketEndCharCarrier`/`BracketCarrierCorrect`/
`bracketEndChar_k0`/`_correct`, `NfMultiAnchorBridge.lean:1536-1584`) remains the CORRECT shape per
G6 and stays valid once the underlying `nf_eval_nf` quant-layer discharge is replaced by a fixed-arity
fold — it is not being abandoned, only re-grounded on a different recursion mechanism underneath it.

## Proposed New Tasks

### New Task 1: Define NormalForm E[Σ]-fold encoding (Rabinovich Def 4.1)
- **Effort**: 5-8 hours (~150-280 lines, hard-mode H8 phase sizing)
- **Task Type**: lean4
- **Rationale**: This is the load-bearing new object task 309's R2 gate needs: a fixed-arity monadic
  fold evaluation, defined alongside `nf_eval_nf` (not replacing it), whose quant-layer clause folds
  each processed depth into a monadic E[Σ]-atom (Def 4.1) evaluated at the *same* arity-n env, instead
  of recursing into an arity-(n+1) sub-evaluation. Scoped deliberately narrow (report 03 §3 explicitly
  rejects a project-scale rewrite of `nf_eval_nf`'s global definition, which "would orphan the
  sorry-free depth-0/arity-1 assets"): the new fold is a parallel object, proved equivalent to
  `nf_eval_nf` for the arity-3 two-anchor shape `[w,x,t]` that task 309 needs, not a global migration.
- **Depends on**: None

### New Task 2: Close k=1 BracketCarrierCorrect gate under the E[Σ]-fold encoding
- **Effort**: 6-9 hours (~150-300 lines, hard-mode H8 phase sizing)
- **Task Type**: lean4
- **Rationale**: Redoes task 309's Phase 10 (R2) probe using New Task 1's fold encoding instead of
  raw `nf_eval_nf` recursion, targeting the exact `BracketCarrierCorrect`-at-`k=1` goal that NO-GOed
  (`NfMultiAnchorBridge.lean:1546-1552` restricted to `k=1`) as its acceptance probe. This is the
  concrete falsification/validation of the encoding fix before task 309 attempts the full depth-`k`
  lift (its own future R3/R4 phases).
- **Depends on**: New Task 1, because the exact bridge/equivalence lemma shape, the fold's monadic
  atom type, and its recursion equation are all New Task 1's implementation choices — New Task 2
  cannot construct the k=1 re-probe (which quant-layer term it folds through, which lemma it invokes
  to discharge `qnf.2`) without knowing precisely how New Task 1 defined and proved the fold. This is
  an implementation-detail dependency, not merely a completion-order one.

## Dependency Reasoning

- **New Task 2 depends on New Task 1**: New Task 1 decides the *type* of the monadic E[Σ]-atom (e.g.
  whether it is `char_k1`-shaped, a bespoke `TemporalPred` wrapper, or something else), the exact name
  and statement of the fold-to-`nf_eval_nf` bridge/equivalence lemma, and which arity-3 shape variables
  it is proved for. New Task 2's k=1 re-probe must invoke that specific lemma at the specific point
  where the old proof produced the arity-4 residual (`qnf.2`'s discharge). A different choice in New
  Task 1 (e.g. a different fold recursion equation, or restricting the bridge lemma to a narrower
  shape than `[w,x,t]`) changes exactly how New Task 2's probe is constructed — this is a genuine
  implementation-detail dependency (Sequentiality), not just "must complete first."
- No independent-task pair exists in this decomposition: with only two tasks and one dependency edge,
  there is no free ordering choice to justify separately.

## After Completion

Once both spawned tasks (New Task 1, New Task 2) are complete, resume task 309. Per the plan's
Postmortem Constraints, task 309 does not auto-resume from `[BLOCKED]` — the next step is `/revise
309` to fold the new encoding + the GO-verdict k=1 lemma into a plan v4 (replacing plan-v3 Phase
10/R2 with the GO outcome and re-scoping R3/R4 against the fold-backed carrier), then `/implement
309`.

The blocker will be resolved because: the arity-4 residual arises specifically from `nf_eval_nf`'s
per-depth arity growth; New Task 1 supplies a fixed-arity alternative fold matching Rabinovich Def
4.1, and New Task 2 demonstrates (by closing the exact k=1 goal that NO-GOed) that the fold eliminates
the residual for the two-anchor bracket shape task 309 needs. Task 309's Phase 9 carrier shape
(`BracketEndCharCarrier`/`VecEA2 1`, G6) is preserved throughout — only its underlying quant-layer
discharge mechanism changes.
