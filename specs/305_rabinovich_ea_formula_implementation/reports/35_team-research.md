# Research Report: Task #305 — Overcoming the Recurring Kamp/Rabinovich Blocker

**Task**: 305 — rabinovich_ea_formula_implementation
**Date**: 2026-06-24
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Type**: lean4 · literature-grounded (Rabinovich 2014; Gabbay 1994 ch.9)
**Session**: sess_1782320767_188e83

---

## Summary

Four independent investigations **converge on one diagnosis with HIGH confidence**: the blocker
that has consumed 24 research reports and 26 plan versions — the `n=1, k+1` case of
`nf_nvar_exist_all_depths` at `KampPrior.lean:391` — is **self-inflicted, not a real mathematical
obstacle in Kamp's theorem**. It is manufactured by an *induction-on-NF-depth-with-growing-arity*
architecture that **has no counterpart in Rabinovich's proof** (Rabinovich inducts on FO-formula
structure and witness count, and handles inserted points by **interval/zone splitting**, never by a
characteristic formula at a higher depth).

The most-recently-recommended fix (report 18's `nf_succ_char_formula2`, a single `Formula`
characterising the *pair* `(x,t)`) is **provably impossible** — a temporal `Formula` is evaluated at
one point, so it cannot carry a free `x` slot (Teammate A, HIGH). This conclusively kills the entire
Approach-5 family and explains why "helper" and "wiring" were never separable.

There are **two faithful exits**, and the synthesis recommends running a **cheap decision gate to
choose between them before committing hundreds of lines** — because one of them may make the whole
construction unnecessary:

1. **Fix-in-place (bounded zone-split):** replace the impossible pair-formula with a 3-way zone
   disjunction (`x<t / x=t / t<x`), each a one-point formula at `t`, mirroring the *already
   sorry-free* depth-0 machinery and Rabinovich §3/§5. (Teammate A's skeleton ≡ Teammate B's "A1";
   independently derived, hence high confidence.) ~200–550 lines, bounded and **terminating**
   (single `k+1→k` edge — not a tower).
2. **Re-anchor (reuse a finished proof):** the discrete live target `completeness_discrete` may be
   routable through the **already sorry-free** `US_expressively_complete_over_Z` (Teammate C),
   making the n=1 construction moot. This contradicts a prior HIGH-confidence "non-viable" verdict
   (report 24) that Teammate C argues does not survive — exactly the kind of reverted refutation
   that must be settled, not assumed.

Underlying both: only **7 of 15** top-level Kamp files are on the live path; the 8 dormant files
(~4150 lines, 19 sorries) are **not the obstruction** and should be demoted, and `KampPrior` should
be split into a green interface + a ~250-line frontier file (Teammate D).

---

## Key Findings

### Primary Approach — the zone-split lift (Teammate A, corroborated by B)

The depth-0 solution that already works (`nf_2var_exist_depth0_tl`) **never builds a pair formula**.
It splits on the zone of `x` relative to `t` and, per zone, uses Until/Since (Prop 3.5) or an
atom-conjunction (equal zone). The n=1 arm at depth `k+1` should mirror this one depth up:

```
A := zoneEqual (x=t)  ∨  zoneFuture (t<x)  ∨  zonePast (x<t)
```

where the order booleans are fixed by `sub_nf` (so `A` is a `match`, not a literal `or`). Concrete
skeleton, in dependency order (each step keeps the build green):

| Step | New artifact | Built from (all sorry-free) | Risk |
|------|--------------|------------------------------|------|
| H1 | `nfProjSucc : NF (k+1) 2 → Fin 2 → NF (k+1) 1` (+ correctness) | NF surgery only | **LOW** |
| H2 | `mergeNF_succ` (equal zone) + `mergeNF_succ_equal_correct` | reuses existing depth-0 `mergeNF` *inside* the quant layer | **HIGH** (quant-layer commutation — the make-or-break) |
| H3 | `nf_succ_exist_future` / `_past` (+ correctness) | `translateEF1` (Prop 3.5) + the in-scope arity-3 IH `nf_nvar_exist_all_depths k 2` | MEDIUM |
| wire | replace `\| 1 => sorry` at KampPrior.lean:391 | H1–H3 + sorry-free `nf_characterizable_temporal_prior` | — |

**Why it is not a "tower":** all helpers are non-recursive in `k`; the only recursion is the
equation compiler's single decreasing edge `k+1 → k` (verified terminating, non-mutual). The
endpoint characteristic formulas come from the **already sorry-free** `nf_characterizable_temporal_prior`
(at depth `k+1`, whose own dependency is `exist k 1`, strictly below). Estimated 350–550 lines,
risk concentrated in H2. **Drop `nf_succ_char_formula2` entirely.**

### Alternative Approaches (Teammate B)

- **B-A1 (Gabbay 9.3.1 zone-decoupling)** is the *same construction* as Teammate A's skeleton,
  reached independently from Gabbay's separation⇒expressive-completeness proof: induct on quantifier
  depth, replace `x<t/x=t/x>t` by a **finite decidable zone split** (no separation theorem needed in
  Lean), invoke the IH at *one free variable, lower depth*. ~200–350 lines, MEDIUM-HIGH. The
  convergence of A and B on this structure is the strongest signal in the report.
- **B-B1 (`existClosure` over `TemporalPred` brackets)** — a genuine fallback: the binder
  `VecEA_m.existClosure` is **already proved bidirectionally sorry-free** (the unique advantage no
  other route has). Point/segment types are full `TemporalPred`, so depth-`k` content rides opaquely
  and binding `x` adds no depth obligation. Risk: `StrictMono` env + x/t orientation; folds into the
  zone split for orientation. ~250–400 lines, MEDIUM. (Note: `VecEA_m` is currently dormant — using
  it means wiring it onto the live path.)
- **Refuted/avoided:** full separation theorem in Lean (too deep — use the finite zone split);
  Gabbay-1993 gap connectives (irrelevant to Dedekind-complete Prior structures — {U,S} suffices);
  mutual char/exist and k+2 NF-disjunction (rebuild the cycle); `Nat.rec` depth-indexing is a
  *delivery mechanism*, not an independent escape (bottoms out at the depth-0 VecEADecomp case).

### Critic — the framing itself is the problem (Teammate C)

- **F1 (HIGH):** the arity-tower divergence flagged by reports 14/15 was **never corrected, only
  renamed** into `nf_nvar_exist_all_depths`. `nf_eval_nf` literally grows arity `n→n+1` per depth
  step (NormalForm.lean:203-207) with no base case but depth 0 — the "iff-at-N needs iff-at-N+1"
  trap. The faithful structural induction (Prop 4.3) was **archived to Boneyard** as dead code.
- **F2 (HIGH):** a **sorry-free** expressive-completeness proof already exists —
  `US_expressively_complete_over_Z` (ExpressiveCompleteness/Theorem.lean:357, via the Separation
  Theorem) — and the *discrete* top consumer `completeness_discrete` is routed *around* it through
  the sorry-blocked depth-tower. The Prior/Dedekind generalization is **more general than the live
  application requires**, and that surplus generality is what drags in the unsolved construction.
- **F3 (HIGH):** the live hypothesis `semantic_prior_UZ` ("first occurrence satisfying ψ") is
  **stronger/discrete-flavoured** and is *not* Rabinovich's infimum (which may be a limit point,
  `P∨K⁺P`). The faithful version (`HasAttainedINF`/`PriorINF`/Prop 4.2 `neg_2var_vec_ea`) was built
  sorry-free and **left dead**. "Dedekind branding + discrete-only hypothesis + dead INF machinery"
  is incoherent.
- **F4 (HIGH):** one unchallenged assumption recurs in three costumes across all 19 reports — "the
  construction must be a *composable biconditional*, so V-EA negation closure must be solved" —
  which forces the recursion to **climb** instead of descend. Report 19 refuted it (top-level iff is
  free via `Formula.neg` + NF uniqueness; each layer needs only a *forward* construction); report 24
  silently reverted. A **governance failure**, not a math one.

### Strategic Horizons (Teammate D)

- **Live path = 7 files** (`KampPrior, ExistsForallNF, NfToVecEA, NfDepth0Generalized,
  VecEATranslation, Translation, VecEAFormula`). The other **8 are dormant** (0 live importers;
  excluded from the `Bimodal` build by `roots`-without-glob): EANegation (15 sorries), VecEADecomp
  (3), NegationIndep (1), EANegationClosure, VecEA_m, VecEAClosure, PriorINF, RabinovichTranslation.
  Their 19 sorries are **not the obstruction**.
- **Refactor (R1–R3):** banner/demote the dormant cluster; split `KampPrior` into
  `NfCharInterface.lean` (green: depth-0 cases + correctness wrappers + statements) and
  `NfExistFrontier.lean` (the single ~250-line file holding the live hole). The frontier becomes a
  file you can hold in your head with one typed `lean_goal`.
- **The deepest durable win is collapsing to a single live route** — maintaining two parallel
  Rabinovich encodings is the root of the churn.
- **Roadmap:** 305 *is* the math task 303 needs ("SOLE remaining sorry blocking
  `completeness_discrete`"). The final milestone should also emit the 303 closure note and feed the
  task-95 `#print axioms` audit — three roadmap items advanced at once.

---

## Synthesis

### Conflicts Resolved

1. **Fix-in-place (A/B) vs re-anchor (C).** Resolved by **sequencing, not picking a winner**: run a
   cheap *decision gate* before committing construction lines, because Route 2 (Z-route) could make
   the construction unnecessary. If the gate retains the construction, Teammate A's zone-split is the
   faithful, **bounded** route — it *is* Rabinovich §3/§5 and is verified terminating/non-mutual, so
   C's "tower paid in installments" critique does not apply to it (the helpers are non-recursive in
   `k`; it is a single new bounded construction, not a per-depth re-derivation).
2. **A's skeleton vs B's "A1".** Not a conflict — they are the **same zone-split construction**
   derived independently (from the depth-0 template and from Gabbay 9.3.1). This raises confidence.
   B-B1 (`existClosure`) is the designated fallback for the strict zones if H2/H3 telescoping resists.
3. **Report 24 "Z-transfer non-viable (HIGH)" vs C's F2 "does not survive".** Not adjudicated here by
   fiat — promoted to the **#1 gate question** (G1) and subjected to verification, per the
   refutation-ledger discipline C recommends. C's evidence (sorry-free `US_expressively_complete_over_Z`
   feeding the discrete consumer; the `phase-2-arity-growth-blocker.md` "Option D may be simplest"
   note) is strong enough to mandate a re-check, not strong enough to skip it.
4. **Stale sorry locations.** Corrected and agreed by A, B, D: the **only live sorries** are
   `KampPrior.lean:391` (n=1, critical) and `:394` (n≥2, off-path). `NfDepth0Generalized.lean:436`
   is a **stale comment**, not a live sorry; `nf_characterizable_temporal_prior` is **now sorry-free**
   (report 24's ":158" is outdated). Build is green.

### Gaps Identified

- **G1 (gating):** Is `completeness_discrete` routable through the sorry-free
  `US_expressively_complete_over_Z` + a Z→countermodel transfer? Unresolved; decides whether the
  construction is needed at all.
- **G2 (gating, faithfulness):** Is `semantic_prior_UZ`'s "first occurrence" honestly adequate for
  the discrete target, or must the live path use `HasAttainedINF`/infimum? The current incoherent
  state must be resolved explicitly.
- **Technical:** H2 `mergeNF_succ` quant-layer commutation is the make-or-break risk of the
  construction route (Teammate A: MEDIUM; ingredients exist, commutation proof not yet constructed).
- **Scope:** whether the n≥2 arm (`:394`) is genuinely off the live path — settle with `lean_verify`.

### Recommendations (staged plan for the planner)

**Phase 0 — Refactor + discipline (no proof change).** Execute D's R1–R3: demote/banner the 8
dormant files; split `KampPrior` into `NfCharInterface` (green) + `NfExistFrontier` (the hole).
Adopt: always-green trunk, **one hole per dispatch**, sorry-inventory (`lean_verify
completeness_discrete`) at every boundary, a **refutation ledger** (every report states which prior
premise it overturns; the orchestrator forbids silent reversion), and a **three-strikes** rule per
leaf. Acceptance: `lake build` green, live sorry count unchanged.

**Phase 1 — Decision gate (cheap, runs before any construction).** Resolve G1 and G2 with one
focused verification dispatch each:
- **G1:** read the `completeness_discrete` chain + `US_expressively_complete_over_Z`; determine
  whether the discrete target can be routed through the finished Z-proof (re-examining report 24).
- **G2:** decide `semantic_prior_UZ` vs `HasAttainedINF` faithfulness for the live target.
- **Output:** a committed decision — (a) take the Z-route and delete the Prior/Dedekind framing from
  the live path (lowest risk, highest reuse), **or** (b) keep the construction route with the
  hypothesis faithfulness settled.

**Phase 2 — Construction (only if the gate retains it).** Execute Teammate A's zone-split skeleton
(≡ B-A1) leaf-by-leaf: **H1 `nfProjSucc` → H2 `mergeNF_succ` → H3 `nf_succ_exist_future`/`_past` →
wire the `\|1` arm.** One helper per dispatch, build green after each, sorry inventory recorded.
Keep B-B1 (`existClosure`, already bidirectional) as the fallback for the strict zones. Abandon
`nf_succ_char_formula2`.

**Phase 3 — Close-out + roadmap.** Discharge `:394` only if `lean_verify` shows it on the live path.
When `completeness_discrete` goes sorry-free, emit the **task 303 closure note** and run the
**task 95 `#print axioms`** audit in the same milestone.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (lean-research-hard) | Primary: obstacle + proof skeleton | completed | HIGH (diagnosis), MEDIUM (H2 closes first pass) |
| B (lean-research) | Alternatives + prior art | completed | MEDIUM-HIGH (A1), MEDIUM (B1) |
| C (lean-research-hard) | Critic: faithfulness audit | completed | HIGH (F1–F6) |
| D (lean-research) | Horizons: refactor + discipline | completed | HIGH (structural facts) |

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014) — `specs/literature/sources/rabinovich_2014/`
  (Def 3.1; Lemma 3.4 ∃-closure; Prop 3.5 V-EA→U/S; Prop 4.2/4.3; §5 interval splitting; eq 5.2 INF).
- Gabbay et al., *Temporal Logic: Mathematical Foundations* (1994) ch.9 — Thm 9.3.1
  (separation ⇒ expressive completeness, quantifier-depth induction, `R_<,R_=,R_>` decoupling);
  Cor 9.3.3 zone decomposition. ch.12 (Expressive Completeness); GPSS {U,S} adequacy.
- Teammate findings (this round): `35_teammate-a-findings.md`, `35_teammate-b-findings.md`,
  `35_teammate-c-findings.md`, `35_teammate-d-findings.md`.
- Key code anchors: `KampPrior.lean:252-394` (depth-tower def; live sorries 391/394);
  `NormalForm.lean:198-207` (`nf_eval_nf` arity growth); `NfToVecEA.lean:702` (depth-0 zone template);
  `NfDepth0Generalized.lean:157/168` (sorry-free `mergeNF`/`merge_forward`);
  `Translation.lean:243` (`translateEF1`, Prop 3.5);
  `ExpressiveCompleteness/Theorem.lean:357` (sorry-free `US_expressively_complete_over_Z`);
  `EANegationClosure.lean:720` (sorry-free but dead Prop 4.2 `neg_2var_vec_ea`);
  `PriorDefs.lean:22-39` (`semantic_prior_UZ`); `BXCanonical/Completeness.lean:356-357` (live chain).
