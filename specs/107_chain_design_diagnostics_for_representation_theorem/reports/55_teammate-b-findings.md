# Research Report: Task #107 — Teammate B Findings

**Task**: 107 - chain_design_diagnostics_for_representation_theorem
**Focus**: Clean-break refactor vs incremental patching (structural question)
**Artifact**: 55_teammate-b-findings.md
**Date**: 2026-05-05

---

## Key Findings

### 1. Current State: 9 Sorries with Clear Structural Clustering

The 9 remaining sorries divide into two structurally distinct groups:

**Group A — c2' co-construction (5 sorries, CounterexampleElimination.lean:758, 796, 836, 874, 920)**

All five are the `c2' := by sorry` sites in `eliminate_potential_counterexample`. They share an identical root cause: when a point insertion adds z to the domain, new adjacent pairs form (z with its neighbors), but `BurgessR3Maximal` proofs for those new pairs are not constructed. The current `EliminationResult.c2'` field carries the invariant but each construction branch just defers it.

**Group B — C4 hard cases (2 sorries, CounterexampleElimination.lean:412 and 510)**

These are the sub-case 1a bodies in `eliminate_C4_counterexample` and `eliminate_C4'_counterexample`: when γ ∈ f(x) AND γ ∈ f(y), the proof needs BurgessR3Maximal bridging from the c2' invariant at the adjacent pair (w, w_next). The comments already identify this as blocked by c2' not being threaded through the omega_chain invariant.

**Key observation**: Groups A and B are directly coupled. The 5 c2' sorries (Group A) must be resolved before the 2 C4 hard cases (Group B) can be addressed, since Group B proofs consume the BurgessR3Maximal guarantees that Group A must produce. The 2 sorries in ChronicleToCountermodel.lean (forward Until/Since guard at intermediate points) depend on the limit_g/C3 machinery, which is already sorry-free.

### 2. Which Files Are Correct and Burgess-Aligned

**Correct and should be KEPT as-is**:

- `ChronicleTypes.lean` — Definitions of ClosedUnderDerivation, SetDeductivelyClosed, rRelation, burgessR3, BurgessR3Maximal, Chronicle, C0-C5 conditions, ChronicleInvariant. All match Burgess §2 precisely. The recent ClosedUnderDerivation cascade (replacing SetDeductivelyClosed with ClosedUnderDerivation in the maximality clause of BurgessR3Maximal) is Burgess-correct.

- `RRelation.lean` — Core r-relation lemmas, Zorn construction (`burgessR3Maximal_exists_from_seed`). All sorry-free and Burgess-aligned.

- `PointInsertion.lean` — All 3 critical-path sorries now closed (Phases 1-3). Lemma 2.4, 2.6, 2.7 proofs are complete and Burgess-aligned.

- `ChronicleConstruction.lean` — Omega-chain construction, limit domain/point function, C0/C4/C5 satisfaction at the limit, Cantor isomorphism. Completely sorry-free.

- `CounterexampleElimination.lean` (partial) — The easy sub-cases (γ ∉ f(x), or γ ∈ f(x) but ¬γ ∈ f(y)) are fully proved. The rightmost-witness search in the C4 hard case (lines 361-407) is correctly structured. Only the two hard-case bodies (sorry at lines 412 and 510) and the five c2' fields are missing.

- `ChronicleToCountermodel.lean` (partial) — The Cantor isomorphism, cantor_fmcs, BFMCS construction, modal coherence, restricted temporal coherence, and backward Until/Since coherence are all sorry-free. Only `cantor_bfmcs_restricted_fuc` (lines 611, 615) is incomplete.

**Files that diverge from Burgess or need work**:

- `CounterexampleElimination.lean` — The c2' field is carried in `EliminationResult` but never constructed. This is an architectural gap, not a conceptual error. The structure is Burgess-aligned; the proof obligations are just deferred.

- `ChronicleToCountermodel.lean` (lines 611-615) — The forward Until/Since guard proof is blocked by the absence of a connection between C5 elimination (which checks the guard in the `C5Counterexample.no_witness` structure) and the result type (which only carries the endpoint witness).

### 3. What a Clean-Break Refactor Would Look Like

A clean-break refactor would create a new directory, e.g., `Chronicle2/` or `BurgessChronicle/`, and rewrite only the files with sorry sites from scratch. The correctly implemented files would be kept verbatim. Concretely:

**Keep unchanged (7 files)**:
- `ChronicleTypes.lean` (all 701 lines, no sorries)
- `RRelation.lean` (all non-sorry content, already sorry-free)
- `PointInsertion.lean` (already sorry-free after Phases 1-3)
- `ChronicleConstruction.lean` (entirely sorry-free)
- `ChronicleToCountermodel.lean` lines 1-600 (modal coherence, BFMCS, BUC)

**Rewrite in clean-break**:
- `CounterexampleElimination.lean` — The c2' co-construction is the core issue. A clean rewrite would redesign `EliminationResult` to carry explicit `BurgessR3Maximal` proofs for each new adjacent pair, passing the c2' invariant through properly. This is not a conceptual change; it is an architectural change to the return type.
- `ChronicleToCountermodel.lean` lines 601-616 — The FUC/FSC sorries. A clean rewrite would strengthen `EliminationResult.c5_forward_witness` to include the guard condition from the start.

**Verdict**: The "rewrite candidates" are small — effectively 200-300 lines of the 9000+ line codebase. The conceptual content does not need to be rediscovered; only the plumbing of BurgessR3Maximal through the elimination infrastructure needs to be restructured.

### 4. Could a Chronicle2/ or BurgessChronicle/ Approach Work?

A parallel-directory approach is feasible but would be wasteful. The correct definitions (C0-C5, burgessR3, BurgessR3Maximal, limit construction) are already in the current files and are correct. Creating Chronicle2/ would simply copy those definitions to a new location, adding maintenance overhead with no mathematical benefit.

A better structural option is the **Boneyard/ pattern** already used in this codebase: archive the stale sorry stubs (the ClosedGuardLegacy files are already there) and patch in place. This is exactly what Phases 4-6 of plan v62 specify.

### 5. Effort Comparison: Clean-Break vs Incremental Patching

**Incremental patching (Phases 4-6 of plan v62)**:

Phase 4 (c2' co-construction for all 5 elimination types):
- For C5/C5' eliminations: `lemma_2_4` already produces B (the BurgessR3Maximal seed). Need to show B from Lemma 2.4 satisfies BurgessR3Maximal for the new pair (x, y). This is a 10-20 line proof using `burgessR3Maximal_exists_from_seed` from RRelation.lean.
- For C4/C4' and density eliminations: Need `lemma_2_6_splitting` output (B', D, B'') from PointInsertion.lean (already proved in Phase 2). Thread through EliminationResult.
- The 5 c2' sorries share a single pattern: "use the splitter outputs already available in the same branch". Total estimated effort: 10-16 hours.

Phase 5 (C4/C4' hard cases, 2 sorries):
- Once c2' is available, lines 409-412 and 507-510 can be completed by extracting BurgessR3Maximal for the (w, w_next) pair and applying `burgessR3_gamma_not_in_B` (which exists in PointInsertion.lean or can be derived from Lemma 2.6). Total estimated effort: 4-8 hours.

Phase 6 (FUC/FSC, 2 sorries in ChronicleToCountermodel.lean):
- These require strengthening the C5 witness to include the guard. Two options: (a) strengthen EliminationResult.c5_forward_witness to carry guard info (cascades to ChronicleConstruction.lean), or (b) derive the guard from limit_g's C3 property (limit_g(x,y) ⊆ limit_f(z) for x < z < y). Option (b) is more self-contained. Total estimated effort: 5-8 hours.

**Total incremental: 19-32 hours** (matching plan v62's 25-41h estimate, corrected for the smaller remaining scope after Phases 1-3 completion).

**Clean-break refactor**:
A Chronicle2/ rewrite of CounterexampleElimination.lean and ChronicleToCountermodel.lean lines 601-616 would require:
- Redesigning EliminationResult to carry BurgessR3Maximal from the start (1-2 hours)
- Rewriting all 5 c2' case branches with the new return type (6-10 hours)
- Rewriting the 2 C4 hard cases (4-6 hours)
- Rewriting FUC/FSC using the now-available c2' (3-5 hours)
- Threading the new EliminationResult type into ChronicleConstruction.lean (2-4 hours) — this is the hidden cost
- Rebuilding and verifying the entire chain (2-4 hours)

**Total clean-break: 18-31 hours**

The effort estimates converge. The clean-break approach has slightly lower upside (the structural redesign is cleaner) but has significant hidden cost in the ChronicleConstruction.lean threading (lines 253-946 all use `EliminationResult`). Any change to `EliminationResult`'s type signature cascades into `omega_chain`, `omega_chain_c5_witness`, `omega_chain_c4_witness`, etc.

### 6. Specific Structural Question: Is c2' Removable From the Invariant?

The current omega_chain tracks `c0 ∧ c2'` as its invariant (line 255 of ChronicleConstruction.lean). The comments indicate c2' was "removed from omega_chain invariant per Phase 7" and then "re-established". This oscillation is the root architectural tension.

**Resolution**: c2' IS needed at finite stages. Burgess's Lemma 2.9 (C4 counterexample elimination, hard case) requires BurgessR3Maximal for the adjacent pair (w, w_next). Without c2' at finite stages, Lemma 2.9 cannot be proved. The current sorries at lines 412 and 510 are exactly this gap made manifest.

The omega_chain type `{ χ : Chronicle // χ.c0 ∧ χ.c2' }` is the correct invariant. The 5 c2' sorries are not a sign of a wrong architecture — they are proof obligations that were deferred while getting the rest of the chain working.

---

## Recommended Approach

**Incremental patching is the correct choice.** The reasons:

1. **Conceptual correctness is already established.** ChronicleTypes.lean, RRelation.lean, PointInsertion.lean, and ChronicleConstruction.lean are all Burgess-correct and sorry-free. The mathematics is sound. Only the proof plumbing of BurgessR3Maximal through CounterexampleElimination.lean remains.

2. **The clean-break cost is dominated by ChronicleConstruction.lean threading.** Any redesign of `EliminationResult` requires touching ~700 lines of ChronicleConstruction.lean. This is the largest file in the Chronicle/ directory and is entirely sorry-free. Risking regressions there for architectural cleanliness is not justified.

3. **The 9 sorries have a natural resolution order that incremental patching follows.** Group A (c2' co-construction) unblocks Group B (C4 hard cases), which together unblock Group C (FUC/FSC). This is the plan v62 Phase 4-5-6 sequence.

4. **Boneyard/ is already the established pattern.** Stale/wrong code is archived to Boneyard/ClosedGuardLegacy/ rather than rewritten in parallel directories. This keeps the import graph clean.

**Specific incremental steps**:
1. Phase 4: Extend `EliminationResult` with `BurgessR3Maximal` witnesses for new adjacent pairs. Thread `lemma_2_4` output B into the C5/C5' branches. Use `lemma_2_6_splitting` output for C4/C4' and density branches.
2. Phase 5: Close the C4/C4' hard cases (lines 412, 510) using the now-available BurgessR3Maximal from the adjacent pair (w, w_next) and `burgessR3_gamma_not_in_B` application.
3. Phase 6: Close FUC/FSC (ChronicleToCountermodel.lean 611, 615) using limit_g C3 property: limit_g(x,y) ⊆ limit_f(z) for any z strictly between x and y in limit_dom.

---

## Evidence and Examples

**Evidence that incremental is viable (not requiring full rewrite)**:

The C5 forward elimination branch (CounterexampleElimination.lean lines 748-778) already calls `eliminate_C5_counterexample`, which internally calls `lemma_2_4`. The output of `lemma_2_4` includes `B` (a BurgessR3Maximal set). The proof at line 183 destructures this as `⟨_B, C, h_C_mcs, h_η_C, _, _, _⟩`. The `_B` (the interval set) is discarded! Passing it through would close sorry #6 (line 758) directly.

For the C4 hard case (line 412), the surrounding code (lines 361-411) already correctly finds the rightmost w with neg-until and its successor w_next. The only missing piece is: given that `omega_chain_c2'` holds (already in scope as `h_c2'`), derive `BurgessR3Maximal (χ.f w) (χ.g w w_next) (χ.f w_next)` and apply the appropriate lemma. This is exactly what the comment at lines 409-411 describes: "requires BurgessR3Maximal for (f(w), g(w,w_next), f(w_next))".

**Burgess paper alignment check**:

Burgess Lemma 2.9, Case n=0 (p.373): "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Let z = (x + y)/2. Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and let C3 determine the other values."

The Lean code structure matches exactly:
- R(f(x), g(x,y), f(y)) = h_c2' applied to adjacent pair
- Apply Lemma 2.6 = call lemma_2_6_splitting (proved in PointInsertion.lean)
- f'(z) = D, g'(x,z) = B', g'(z,y) = B'' = construction in EliminationResult

The only gap: the `g'(x,z) = B'` and `g'(z,y) = B''` values need to be stored in the chronicle's g function and reflected in the c2' field. Currently g is left unchanged (all branches return `val.g = χ.g`) and the new adjacent pairs have no BurgessR3Maximal proof.

**FUC/FSC blocker analysis**:

The `cantor_bfmcs_restricted_fuc` sorry (line 611) comments explain: "C5_weak gives the endpoint ψ ∈ f(y), but the guard φ ∈ f(r) for intermediate r requires the real interval function g with C3."

`limit_c3_interval_subset_point` is already proved in ChronicleConstruction.lean (line 868): `limit_g A h_mcs x z ⊆ limit_f A h_mcs y` for any y strictly between x and z. The `limit_g` function (line 827) defines `g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y}`.

What is missing: connecting the C5 elimination result ("η ∈ g(x,y) at some finite stage" per Burgess 2.10 Case n=0: "Set y = x+1, f'(y) = C, g'(x,y) = B") to limit_g. Since B from lemma_2_4 satisfies g_content(f(x)) ⊆ B, and by C3 limit_g(x,y) ⊆ f(z) for all intermediate z, the guard carries. This connection just needs to be made explicit in the proof.

---

## Confidence Level

**HIGH** — The 9 sorries are well-understood mathematically. The incremental approach is lower-risk than a clean-break refactor because the correctly-proved files (ChronicleConstruction.lean in particular) are large and complex. The specific proof obligations are deferred BurgessR3Maximal constructions that follow directly from lemmas already proved in Phases 1-3. The effort comparison shows no material advantage for the clean-break approach.
