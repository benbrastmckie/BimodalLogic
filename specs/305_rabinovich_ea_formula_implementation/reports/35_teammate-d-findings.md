# Task 305 — Teammate D (Horizons): Strategy, Module Organization, Work Decomposition

- **Task**: 305 — rabinovich_ea_formula_implementation
- **Type**: lean4
- **Role**: Teammate D (strategic/structural — long-term, durable structure)
- **Date**: 2026-06-24
- **Scope**: Module organization, work decomposition, working discipline, roadmap alignment. Does NOT duplicate A (proof skeleton), B (alternative proofs), or C (faithfulness audit).

---

## Key Findings

### KF-1 (decisive): The live critical path is only 7 files; the heavy Rabinovich Section-5 cluster is currently DEAD relative to the blocking sorry

The sole sorry blocking `completeness_discrete` is in `KampPrior.lean`
(`nf_nvar_exist_all_depths`, the `n = 1, k+1` case at ~line 391; reported elsewhere as :158/:391 depending on the snapshot). The actual import closure that reaches `completeness_discrete` is:

```
completeness_discrete
  → countermodel_discrete_reynolds_v2 → no_gaps_discrete_model_surgery
    → US_expressively_complete_over_prior  (GoodStructuresModelSurgery imports PriorExpressiveness)
      → kamp_prior_expressive_completeness          (KampPrior.lean)
        → nf_characterizable_temporal_prior         (KampPrior.lean)
          → nf_nvar_exist_all_depths  ← THE SORRY (n=1, k+1)
```

Computing the transitive import closure of `KampPrior.lean` inside `Kamp/` yields exactly **7 files**:

```
KampPrior, ExistsForallNF, NfToVecEA, NfDepth0Generalized,
VecEATranslation, Translation, VecEAFormula
```

The remaining **8 top-level Kamp files are NOT reachable** from `KampPrior` and are not imported by anything live outside their own cluster (verified: 0 live importers each):

```
EANegation (1251 L, 15 sorries), EANegationClosure (731 L), NegationIndep (349 L, 1 sorry),
VecEADecomp (898 L, 3 sorries), VecEA_m (490 L), VecEAClosure (386 L),
PriorINF (245 L), RabinovichTranslation (302 L)
```

This is the single most important structural fact for planning: **the largest, most sorry-laden files (EANegation 15 sorries, VecEADecomp 3) are off the live path.** They encode the literal Rabinovich Section-5 bracket/negation machinery, but the live KampPrior construction reaches the same goal through the `nf_*` / `VecEA*Translation` route instead. Report 24 corroborates this: sorries #2–#4 are all "not imported by KampPrior" / "documented impossibility at BracketFormula level."

Because `lakefile.lean` builds `lean_lib Bimodal` with `roots := [Bimodal]` and **no glob**, only modules transitively imported from `Theories/Bimodal.lean` are compiled. The 8 dead Kamp files are therefore not even contributing to the live build of `completeness_discrete` — their sorries cannot be the obstruction, and they add ~4150 lines of cognitive load to every restructuring attempt.

### KF-2: Churn signature — 24 reports, 26 plans (numbered to 34) for one sorry

The artifact history shows **24 research reports and 26 plan files (sequence numbers up to 34)** for a single remaining sorry. Plan slugs reveal repeated re-approaches to the *same* obstruction: `arity-tower-descent`, `restricted-mutual-induction`, `b2-fix-impossibility`, `nf-strong-induction`, `approach5-arity2-char`, `structural-induction-refactor`. This is the canonical hard-mode trigger (2+ plan versions without convergence; analysis-heavy; literature transcription). The structural countermeasure is to stop producing *whole-construction* plans and instead lock the construction as a fixed skeleton with named obligations (see Recommended Approach).

### KF-3: The obstruction is self-referential bootstrapping, not a missing lemma

The `k+1, n=1` case (KampPrior ~391) is structured as: build `exist_tl_fn_k` (depth-k arity-2 existential) from the `Nat.rec` IH at depth k arity 1, then `char_k1` from `nf_succ_char_formula`, then the `n=1` case needs to combine `char_k1` with a *one-variable existential at depth k+1* — which is the very function being defined one arity up. The committed comments describe a "simultaneous fixed-point on `NormalForm sig (k+1) 2 → Formula`" then "bootstrap to higher depths." The difficulty is an **arity/depth mutual recursion that the current single `Nat.rec` skeleton cannot express cleanly**. This is a *shape-of-recursion* problem, which is exactly why it is structural, not lemma-shaped — and why isolating it (KF-1 refactor) matters more than another lemma hunt.

### KF-4: Boneyard is clean; nothing live imports it

Both `Kamp/Boneyard/` (WitnessCount, FOToVEA, EndpointNegation, Prop43, SeparationBridge, KampComposition, NfExistTL, ZoneBridge, NfComposition, ArityReduction) and `Theories/Bimodal/Boneyard/KampBypassArchive/` (KampBypass, PriorComposition, etc.) have **0 live importers**. The user's archival in step (a) was done correctly. `Bimodal.Boneyard` is built only by the separate `BoneyardArchive` lib (glob), so it does not pollute the main build. **No archived file should be revived** as-is: report 24 confirms KampBypass/PriorComposition/NfCharFormula are deleted, and EndpointNegation's negation lemma is a "documented impossibility at BracketFormula level." Nothing currently archived is on a viable path to the live sorry.

---

## Recommended Approach

### Part 1 — Refactoring / file-splitting plan

**Principle**: separate (a) the sorry-free reusable infrastructure, (b) the single hard frontier, and (c) the dead literal-Rabinovich cluster, so the dependency graph is legible at a glance and the frontier is a small file with a stated interface.

**R1. Make the dead cluster's status explicit (no deletion, no revival).**
Move the 8 unreachable Kamp files into `Kamp/Boneyard/` (joining the existing boneyard) OR add a one-line header banner `-- DORMANT: not on the completeness_discrete path (see report 35)` to each. They contain the faithful Rabinovich Section-5 transcription and have research value, but they are not the live route. Demoting them removes 15+3+1 = 19 sorries and ~4150 lines from the working surface that every implementer currently has to reason about. This directly satisfies the "separate sorry-free reusable infrastructure from the in-progress frontier" goal. *(Coordinate with Teammate C: if C's faithfulness audit concludes the Section-5 cluster is the more faithful route and should become live, then instead the KampPrior route is the candidate for demotion. Either way, exactly one route should be live.)*

**R2. Isolate the hard construction into a focused frontier file with a published interface.**
Split `KampPrior.lean` (608 L) into:
- `Kamp/NfCharInterface.lean` — the *interface*: the statement (signature only) of
  `nf_nvar_exist_all_depths` and `nf_characterizable_temporal_prior`, plus the depth-0
  cases which are already sorry-free, plus all the *correctness wrappers* (`*_fn`,
  `*_fn_correct`) which are sorry-free given the construction. This file compiles green
  and is what `kamp_prior_expressive_completeness` depends on.
- `Kamp/NfExistFrontier.lean` — ONLY the `k+1` recursion body of
  `nf_nvar_exist_all_depths`, containing the single `sorry` (n=1) and the off-path
  `n+2` `sorry`. This is the < ~250-line file the whole effort orbits.

  Benefit: the frontier becomes a file you can hold in your head, with a typed hole and a
  precise `lean_goal`. Every dispatch edits this one file; the rest of the build stays green.

**R3. Keep the supporting infra files as-is** (`ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized`, `VecEATranslation`, `Translation`, `VecEAFormula`) — they are sorry-free except `NfDepth0Generalized` (1 sorry) and `NfToVecEA` (1 sorry). Audit those two: if their single sorry is genuinely on the live path, they are second-priority frontiers; if off-path (like the dead cluster), banner them. *(Quick follow-up for the planner: run `lean_verify` on `completeness_discrete` to get the exact live sorry set — report 24 lists 1 live + 3 dead, suggesting the NfToVecEA/NfDepth0Generalized sorries may be off-path.)*

**Resulting dependency graph (legible target):**
```
PriorExpressiveness
  → KampPrior (kamp_prior_expressive_completeness)
      → NfCharInterface  (green: depth-0 + wrappers + statements)
          → NfExistFrontier  (THE frontier: 1 live sorry)
          → ExistsForallNF, NfToVecEA, VecEATranslation, Translation, VecEAFormula, NfDepth0Generalized  (infra)

[DORMANT cluster, not built into completeness path]
  EANegation, EANegationClosure, NegationIndep, VecEADecomp, VecEA_m, VecEAClosure, PriorINF, RabinovichTranslation
```

### Part 2 — Milestone decomposition (small, independently verifiable, monotone)

Structure the frontier as a sequence where each step compiles and **strictly reduces the live sorry count or strictly grows a green helper**, never both regressing. The mutual-recursion shape (KF-3) suggests decomposing the single `nf_nvar_exist_all_depths` `sorry` into named sub-obligations *as separate green `have`/lemma stubs first*, then filling them one per dispatch:

- **M0 (refactor, zero proof change)**: Execute R1+R2. Acceptance: `lake build` green, live sorry count unchanged, `NfExistFrontier.lean` contains the only edited hole. Commit.
- **M1 (specify the recursion shape)**: In `NfExistFrontier`, replace the single `Nat.rec` with the explicit mutual scheme the construction needs — e.g. a `WellFoundedRecursion` or paired `char(k,n)` / `exist(k,n)` definitions over a lexicographic `(k, arity)` measure — *with every leaf still `sorry`*. Acceptance: file compiles, sorry count may temporarily rise (each leaf), but each leaf has a clear `lean_goal`. Commit. (This converts one opaque hole into several legible holes — measurable progress.)
- **M2…Mk (one leaf per dispatch)**: Discharge leaves in dependency order (depth-0 leaves and the atom layer first, then the coupling step). Acceptance per dispatch: exactly one `sorry` removed, build green, commit immediately. Hard rule: **never start a second leaf in the same dispatch.**
- **M-final**: `n=1` coupling leaf discharged → `nf_nvar_exist_all_depths` sorry-free → `lean_verify completeness_discrete` shows the live chain closed. The `n+2` case stays `sorry` only if the planner confirms (via `lean_verify`) it is provably off the live path; otherwise it is a final milestone.

This converts "prove the construction" (which has failed 26 times as a monolith) into "remove one named typed-hole per dispatch," which is monotone and auditable.

### Part 3 — Working discipline (tuned to the 26-plan churn history)

1. **Always-green trunk.** Never commit a state where `lake build` of the `Bimodal` lib regresses. The dormant cluster (R1) makes this cheap because the build surface shrinks.
2. **One hole per dispatch.** A dispatch that does not remove a `sorry` or add a *named, green* helper stub is a no-op and should be rejected (anti-analysis). This is the direct antidote to the 24-report / 26-plan analysis-paralysis signature (KF-2).
3. **Sorry inventory at every dispatch boundary** (`lean_verify completeness_discrete` + a per-file `grep -c sorry`). Record the count in the handoff. A dispatch that raises the *live* count without a compensating green helper is reverted.
4. **Freeze the skeleton.** After M1, the recursion scheme is contract, not subject to re-litigation. New ideas become "fill leaf X differently," never "redesign the whole construction." This is what 26 plans failed to do.
5. **Incremental commits at every green milestone**, using `task 305 phase N: <leaf name>` messages.
6. **Three-strikes audit.** If the same leaf resists 3 dispatches, do NOT spawn a 4th attempt — open a dedicated divergence-audit dispatch (or escalate to `--hard` / a spawn task) rather than re-churning. The history shows the failure mode is silent re-churn, not lack of ideas.

---

## Adjacent Roadmap Opportunities & Reframing

- **Task 303 is unblocked by exactly this sorry.** ROADMAP and state.json both state 303 (`existPart_succ_n1_bypass` k>0, the "SOLE remaining sorry blocking `completeness_discrete`") is the critical path, and 305's description ends "Blocks: task 303 completion." 305 IS the math that 303 needs. Concrete simultaneous advance: when M-final lands, immediately run `lean_verify completeness_discrete` and the task-95 `#print axioms` audit — that single verification closes the 303 deliverable and feeds task 95. The planner should write the 305 final milestone to *also* produce the 303 closure note, avoiding a separate research round.
- **Creative reframing toward durability.** The deepest long-term win is **collapsing to a single live route.** Right now two parallel encodings of Rabinovich exist (the live `nf_*` route and the dormant Section-5 `EANegation` route). Maintaining both invites exactly the churn seen. The virtuous, durable choice is: pick the route Teammate C judges most faithful, make it the *only* live one, and demote the other to a clearly-labelled archive with a README pointer. A single faithful route with one typed hole is far more publishable and maintainable than two half-built routes with 20 scattered sorries.
- **Publication framing.** ROADMAP's north star is "BX Completeness and Publication." For a paper, the artifact that matters is `completeness_discrete` sorry-free with a clean `#print axioms`. The refactor (R1–R3) produces exactly the legible artifact a referee/reader can follow: one interface file, one frontier file, one dormant-archive note.

---

## Evidence / Examples

**File sizes (live path bolded conceptually):**
| File | Lines | sorries | On live path? |
|------|------:|--------:|:--:|
| KampPrior | 608 | 7* | YES (frontier) |
| NfDepth0Generalized | 1316 | 1 | YES (infra) |
| NfToVecEA | 766 | 1 | YES (infra) |
| VecEAFormula | 769 | 0 | YES (infra) |
| ExistsForallNF | 339 | 0 | YES (infra) |
| VecEATranslation | 297 | 0 | YES (infra) |
| Translation | 337 | 0 | YES (infra) |
| EANegation | 1251 | 15 | NO (dormant) |
| VecEADecomp | 898 | 3 | NO (dormant) |
| EANegationClosure | 731 | 0 | NO (dormant) |
| VecEA_m | 490 | 0 | NO (dormant) |
| VecEAClosure | 386 | 0 | NO (dormant) |
| NegationIndep | 349 | 1 | NO (dormant) |
| RabinovichTranslation | 302 | 0 | NO (dormant) |
| PriorINF | 245 | 0 | NO (dormant) |

*KampPrior's 7 `sorry` tokens include the live n=1 hole, the off-path n+2 hole, and comment/doc mentions; the *live blocking* sorry is the single n=1, k+1 case.

**Dependency observations (verified):**
- Live closure of `KampPrior` = {KampPrior, ExistsForallNF, NfToVecEA, NfDepth0Generalized, VecEATranslation, Translation, VecEAFormula} — 7 of 15 top-level Kamp files.
- 8 Kamp files have 0 live importers outside their own cluster.
- `Kamp/Boneyard/` and `KampBypassArchive/`: 0 live importers (clean archival).
- `lakefile.lean`: `lean_lib Bimodal` has `roots := [Bimodal]`, **no glob** → only transitively-imported modules compile; dormant cluster is excluded from the completeness build.
- Consumers of KampPrior: `WeakCanonical/PriorExpressiveness.lean` (live) and `Boneyard/KampNegationClosure/NegationClosure.lean` (dead).

**Roadmap alignment:**
- ROADMAP (lines 27, 34, 1402–1405): single remaining sorry, task 303 critical path, "Rabinovich Section 5 Lemma 5.1."
- state.json: 305 description "Blocks: task 303 completion"; 303 status `blocked`, "SOLE remaining sorry blocking `completeness_discrete`."
- 305 direction (faithful Rabinovich, single-structure path) aligns with the publication goal; the open risk is route duplication, addressed by the collapse-to-one-route recommendation.

---

## Confidence Level

**High** on the structural facts (live-path = 7 files, dormant cluster, clean boneyard, build-glob behavior, roadmap/303 relationship) — all directly verified from imports, lakefile, and state files. **Medium-high** on the refactor split (R1–R3) being the right shape: it follows mechanically from the live-path analysis, but the exact `NfCharInterface` / `NfExistFrontier` cut should be confirmed against Teammate A's proof skeleton and Teammate C's faithfulness verdict before execution (specifically: which of the two Rabinovich routes becomes the single live one). **Medium** on the mutual-recursion diagnosis (KF-3) being the precise blocker — it is read from the committed construction comments and report 24, and should be confirmed by A. The working-discipline recommendations are method-level and low-risk.
