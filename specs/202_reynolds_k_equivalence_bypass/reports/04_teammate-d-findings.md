# Task 202: Teammate D — Strategic Horizons Research

**Artifact**: 04 (Teammate D findings)
**Date**: 2026-05-29
**Focus**: Strategic direction, task ordering, and long-term alignment

---

## Key Findings

### 1. Project Long-Term Goals (ROADMAP Alignment)

The ROADMAP is explicit: the destination is a **sorry-free `bx_completeness`** followed by structural refactoring, a tactics library, documentation, and ultimately a **publication-quality codebase** supporting the paper "The Construction of Possible Worlds" (Brast-McKie 2025).

The ROADMAP specifies this sequencing:
- Phase 1: Sorry-free `bx_completeness` (tasks 155, 202)
- Phase 2: Frame hierarchy + axiom cleanup (tasks 126, 124, 115, 116)
- Phase 3: Expressive extensions (tasks 127, 128)
- Phase 4: Algebraic representation (task 125)
- Phase 5: Publication quality (tasks 95, 8)

Task 202 sits squarely on the Phase 1 critical path. It is NOT optional unless the project accepts publishing with a known sorry in the discrete completeness proof.

### 2. Current State: One Sorry Remaining

The project is in an unusually strong position. The metadata header in TODO.md reports:
- `sorry_count: 1` (the `succ_cofinal` root sorry)
- `publication_path_sorries: 1`
- `axiom_count: 0`
- `build_errors: 0`
- `repository_health.overall_score: 95`
- `status: excellent`

This means the entire codebase — soundness (all three variants), dense completeness, FMP completeness, decidability, the Burgess chronicle construction, the separation theorem, the EF-game expressiveness infrastructure, and the entire Reynolds pipeline — is sorry-free EXCEPT for this one root sorry.

The project is 99%+ complete toward its Phase 1 goal. The question is whether the remaining 1% is tractable.

### 3. How Many Resources Have Been Spent on Task 202?

The effort investment is significant but bounded:
- Task 155: 11+ research agents, 44+ plan versions, multiple implementation cycles (tasks 139, 140, 141, 142, and sub-tasks)
- Task 202: 4+ cycles (orchestration cycles 1-5), 3+ plan versions, multiple blockers documented

The ROADMAP explicitly records `succ_cofinal` as **UNPROVABLE** by the current approach (confirmed by 4+ research agents). This is not a difficult proof that needs more effort — it is a **wrong approach** that has been definitively ruled out.

The current blocker for ALL active approaches:
- Reynolds pipeline (Phases 1-2): Requires US expressive completeness over Prior structures — 8-12 hours of formalization that has not been attempted directly yet
- Reynolds pipeline (Phase 4): Architectural incompatibility between `temporal_truth` (position-dependent) and `truth_at` (position-independent) in the TaskFrame framework
- Henkin direct chain (task 202 latest): F-persistence through Lindenbaum extensions — the same fundamental obstruction documented in dead ends #34-#36 in ROADMAP

### 4. Is Task 202 Worth Continuing?

The strategic answer is **yes, but with the correct scoping**. Here is why:

**For**: Discrete completeness is mathematically indispensable for the project's stated claim. The paper proves TM logic for discrete frames (standard model: ℤ). A published formalization without sorry-free discrete completeness would be significantly weaker. The repository's own README currently says "Discrete completeness: `completeness_discrete` has sorryAx via single root sorry." This is the stated goal of the project.

**Against (weak)**: The effort has been substantial. But examining the blocker history more carefully reveals that the approaches tried have been architectural workarounds (Henkin chains, chronicle surjectivity) rather than directly implementing the Reynolds 1994 proof. The ROADMAP itself identifies the **correct path**: Reynolds' approach never needs `succ_cofinal`. The task description for 202 IS correct — the issue is that Phases 1 and 2 have not yet been implemented, only documented as blockers.

**Strategic verdict**: Do NOT abandon task 202. But the scope must be narrowed to the ONE unimplemented piece: formalizing Reynolds Theorem 5 (US expressive completeness over Prior structures) and Reynolds Theorem 14 (no_gaps_discrete). Phase 4's architectural blocker is secondary — the ROADMAP notes suggest that if `no_gaps_discrete` is proved, it may imply the chronicle IS succ-Archimedean after all, which would also fix the original sorry chain.

### 5. Does Task 129 Exist? What Is Its Relationship?

Searching TODO.md reveals no entry for task 129. The handoff document `phase-1-blocked-20260529.md` mentions "Task 129: Conservative extension from reflexive semantics" as a resolution path. This appears to be a REFERENCED but non-existent task — it was mentioned as a potential approach but never created.

This is relevant because the Henkin chain blocker (F-persistence through Lindenbaum extensions) is the SAME obstruction documented in ROADMAP dead ends #34-#36. The handoff suggests task 129 as an architectural alternative. If task 129 were created and pursued, it would represent a different top-level architecture rather than an incremental fix.

However, given that the Reynolds pipeline's Phase 1 (US expressive completeness) has never actually been implemented — only assessed as difficult — pursuing that path directly is more consistent with the existing architecture. Creating task 129 as a separate effort risks further fragmentation.

### 6. What Is Completeness_dense's Status and Relevance?

`completeness_dense` IS sorry-free (confirmed by `lean_verify`). Dense completeness was achieved via the Burgess chronicle construction + natural inclusion (task 117 replaced the Cantor isomorphism). This demonstrates that the chronicle approach CAN produce sorry-free completeness — the architecture is sound.

The key difference between dense and discrete is exactly `succ_cofinal`: dense completeness uses rational dense ordering (no discrete structure needed), while discrete completeness requires the chronicle domain to have integer-like successor structure.

Could proving completeness for a broader class of frames be more impactful? The answer is **no for Phase 1**. The "broader class" (Continuous/TM^dc) is deferred to Phase 3+ and depends on first completing Phase 1. The paper specifically targets discrete completeness (ℤ-models). Dense completeness is ALREADY done.

### 7. Task Ordering Analysis

The current TODO.md task ordering is well-structured but has one sequencing question: should task 199 (grid tactic) or task 155 (Reynolds pipeline activation) come first?

Current ordering:
1. Task 199 (grid order tactic) — unblocks 155 Phase 3B
2. Task 174 (file splitting) — unblocks 155
3. Task 155 (Reynolds pipeline) — blocked on 174, 199
4. Task 202 — blocked on 155

This ordering puts 3 prerequisites before 202. However, per the current plan state:
- Task 202 Phase 3 is COMPLETED (chronicle_is_good_direct)
- Task 202 Phase 4 is BLOCKED (h_truth_corr architectural issue)
- Task 202 Phase 1 is BLOCKED (needs US expressive completeness over Prior structures)

The dependencies between 155 and 202 are actually more nuanced than the dependency graph suggests: 202 needs the EF-game infrastructure from 155 (specifically `ghr93_forward_to_backward_discrete`), which IS already sorry-free. The remaining work in 202 that is actually blocking sorry-free completeness is:
1. US expressive completeness over Prior structures (8-12 hours, can start NOW)
2. `no_gaps_discrete` (8-12 hours, follows from 1)
3. Either fix Phase 4 architectural issue OR use Option C (6-10 hours)

None of these require tasks 155, 174, or 199 to complete first. The dependency on 155 was from an older version of the plan when the EF-game infrastructure was not yet built.

**Recommended reordering**: Task 202 should be declared partially independent of task 155 for its Phase 1 work. The dependency `202 → 155` can be dropped or changed to `202 depends on the Phase 1 deliverables of 155 which are already done`.

### 8. Could Task 202 Be Scoped Differently?

Yes. The current plan has 5 phases where only Phases 1-3 are truly necessary for the single sorry:

- Phase 1 (US expressive completeness over Prior): NECESSARY, NOT YET IMPLEMENTED
- Phase 2 (no_gaps_discrete): NECESSARY, blocked on Phase 1
- Phase 3 (chronicle_is_good_direct): COMPLETED
- Phase 4 (countermodel_discrete rewiring): BLOCKED with architectural incompatibility — but may become unnecessary if Option C works
- Phase 5 (full verification): NECESSARY after above

**Option C** (mentioned in the implementation summary) offers a significant scope reduction: use the Z-specific BFMCS directly, bypassing the Reynolds monadic structure pipeline entirely. This would:
- Skip Phase 4's architectural incompatibility
- Use the EXISTING `cantor_bfmcs_discrete` (already sorry-free) and `rooted_succ_discrete_fmcs` (sorry-free)
- Replace `succ_embed_surjective` with a Z-specific version that IS trivially true (Z is succ-Archimedean)
- Estimated: 6-10 hours vs 8-12 hours for the full Reynolds pipeline

The risk of Option C: it does not implement the theoretically cleaner Reynolds pipeline. But it achieves sorry-free `completeness_discrete`.

---

## Recommended Approach

### Primary Recommendation: Pursue Task 202 with Scope Reduction to Option C

The project should pursue **Option C** as the primary path to sorry-free `completeness_discrete`:

1. **Do not attempt Phases 1-2 of the Reynolds pipeline** until Option C is attempted and fails
2. **Implement restricted coherence proofs on Z directly** — on ℤ itself (not the chronicle domain), `succ_embed_surjective` is trivially true because ℤ is succ-Archimedean by definition
3. **Build `countermodel_discrete_z` that starts from a discrete MCS** and constructs the BFMCS on ℤ using `rooted_succ_discrete_fmcs`, then proves `restricted_tc` and `restricted_fuc` using the fact that ℤ's `succ_embed` (identity) IS surjective
4. **Wire to `completeness_discrete`** via the existing parametric truth lemma

This approach:
- Requires approximately 6-10 hours
- Uses the existing sorry-free infrastructure maximally
- Avoids both the `succ_cofinal` sorry AND the Phase 4 architectural incompatibility
- Is consistent with Option C described in the implementation summary

### Secondary Recommendation: Task Ordering Update

Update the TODO.md dependency for task 202 to reflect that:
- Phase 1 work (US expressive completeness) does NOT require tasks 155, 174, or 199 to complete first
- Option C work requires NOTHING from other incomplete tasks

The current Phase 1 ordering blocker (task 202 depends on 155) is outdated — the EF-game infrastructure (the actual deliverable from 155 that 202 needs) is already sorry-free.

### Tertiary Recommendation: Explicit Fallback Plan

If Option C fails due to unexpected technical issues, document the following fallback:
1. Create task 129 (Conservative extension approach) explicitly in TODO.md
2. Implement US expressive completeness over Prior structures as a standalone lemma
3. Use that to prove no_gaps_discrete (Reynolds Theorem 14)
4. Address Phase 4 architectural issue via the "weak countermodel" approach (only requires ¬truth_at for the specific formula φ, not full truth correspondence)

---

## Evidence/Examples

### Evidence That Option C Is Viable

From the implementation summary:
> "Option C: Direct completeness on Z (bypasses Reynolds pipeline entirely) — Only requires showing `succ_embed_surjective` on Z (trivial because Z is succ-Archimedean). Estimated: 6-10 hours."

From the report 02_option-c-pivot-research.md:
> "On ℤ itself (not the chronicle domain), `succ_embed_surjective` is trivially true because ℤ is succ-Archimedean by definition."

The sorry chain is:
```
succ_cofinal → limitDomSubtype_isSuccArchimedean → succ_embed_surjective
  → cantor_bfmcs_discrete_restricted_tc + cantor_bfmcs_discrete_restricted_fuc
  → countermodel_discrete_enriched → completeness_discrete
```

The insight: rather than proving `limitDomSubtype_isSuccArchimedean` (which requires the unprovable `succ_cofinal`), build the restricted coherence proofs in a DIFFERENT FMCS — one built directly on ℤ where `IsSuccArchimedean` is trivially satisfied.

### Evidence That Task Sequencing Needs Updating

The current task 202 dependency on task 155 states:
> "Dependencies: 155"

But task 155's plan v43 deliverable (ghr93_forward_to_backward_discrete) is already sorry-free per the implementation summary:
> "`ghr93_forward_to_backward_discrete` (Theorem 6) already proved sorry-free (Transfer.lean:662-769)"

### Evidence That Project Is Near Publication

From TODO.md header:
- `sorry_count: 1`
- `publication_path_sorries: 1`
- `axiom_count: 0`
- `repository_health.overall_score: 95`

This confirms discrete completeness is the SOLE remaining obstacle to a fully sorry-free formalization.

### Evidence That Dense Completeness Is Already Achieved

From the ROADMAP:
> "Dense completeness (`countermodel_dense`): Internally sorry-free"

And from Metalogic.lean:
> "`completeness_dense` | SORRY (chronicle + canonical model open question)"

Wait — there is a discrepancy. The TODO.md header says `sorry_count: 1` but Metalogic.lean documentation says `completeness_dense` has a sorry. Let me clarify: per the sorry chain analysis in report 02, `completeness_dense` shows NO `sorryAx` when verified (the Metalogic.lean entry appears to be stale documentation). The actual verified state is that `completeness_dense` is sorry-free. The single remaining sorry is `succ_cofinal` affecting only `completeness_discrete`.

---

## Confidence Level: High

The strategic assessment that Option C is viable and task 202 should continue is based on:
1. **Explicit documentation** in the implementation summary identifying Option C as "6-10 hours, Requires understanding `cantor_bfmcs_discrete_restricted_tc/buc/fuc` and replacing `succ_embed_surjective` with a Z-specific version"
2. **ROADMAP alignment** confirming discrete completeness is Phase 1 critical path
3. **Mathematical clarity** that ℤ itself IS succ-Archimedean (no proof needed), making the sorry chain solvable by architectural substitution rather than mathematical proof
4. **Existing infrastructure** (cantor_bfmcs_discrete, rooted_succ_discrete_fmcs, parametric truth lemma) being sorry-free and usable
5. **No structural obstacles** — unlike the chronicle domain approach, working directly on ℤ avoids the constant-MCS gap counterexample that makes `succ_cofinal` unprovable

Confidence is not "very high" because:
- Option C has not been actually implemented and tested
- The `restricted_tc` and `restricted_fuc` proofs on ℤ may encounter unexpected type-theoretic issues in Lean 4
- The wiring to `completeness_discrete` may require additional bridge lemmas

Confidence: **High (85%)**. The mathematical case is clear; the engineering may have minor surprises.
