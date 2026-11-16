# Research Report: Task #761

**Task**: 761 - ladder_realization_theorem
**Started**: 2026-11-16T14:06:20-08:00
**Completed**: 2026-11-16T14:20:00-08:00
**Effort**: one research dispatch; two scratch probes compiled against the tree
**Dependencies**: None
**Sources/Inputs**: - Codebase (`LadderStepFrag.lean`, `CounterQuotient.lean`, `LadderAgree.lean`, `LadderModel.lean`, `RunLayer.lean`), the wired probes `ladder-row-link-residue-obstruction.lean` and `ladder-cell-agreement-refutation.lean`, plan v28 (Phases 11.30, 11.31, 11.35, 11.40, 11.49 and the `Depends on` graph), `records/round-28-k1-admissible-refutation.md` sections 10-16, the task description in `specs/state.json`, `lake env lean` on two scratch files outside the repository. Literature: recalled, NOT re-read (the HWZ corpus entry is of unverified-summary provenance by the library's own note).
**Artifacts**: - specs/761_ladder_realization_theorem/reports/29_row-link-route-viability.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The path forth `exists_rowLinked_path` is FALSE at the exact Phase 11.49 signature** (`Mrel` plus the object half of `(K1)`). [VERIFIED MECHANICALLY: scratch probe, `exists_rowLinked_path_K1_refuted`, compiled against the tree with `lake env lean`, exit 0, axioms `[propext, Classical.choice, Quot.sound]`.] The counterexample has EQUAL countdowns of any size, so no residue condition, countdown threshold, `(K1)` conjunct or pigeonhole room (`Fintype.card Q ≤ cntAt g t`, the proposed fifth hypothesis) excludes it.
- **The failing coordinate is the gap, and it has never been repaired.** All four rounds repaired the COUNTDOWN coordinate. `Mrel` inherits `Zrel`'s gap clause unchanged ("both `≥ 2 a`"), and that threshold is the solution of ONE-STEP closure conditions only. One forward jump to the region's exit converts the gap into the exit register, where it is read against the register clause at the budget left; `2 a` is not closed under that.
- **The route's own projected end result is also false.** Phase 11.40 item 3 says full success yields "an agreement of cells over the DERIVED relation `Mrel`". [VERIFIED MECHANICALLY: scratch probe `cell_agreement_over_Mrel_refuted`, built on the tree's own `dblC_cell_ne`.] At every modulus and every budget `(a, b)` with `2 a ≤ 2 ^ (j + 1) - 1` there are `Mrel P a b`-related states whose cells differ at `dblC j`, including at the formula's own depths `(j, 3)`. No polynomial inflation of the budget escapes this.
- **The row-link layer is a leaf.** No module imports `LadderStepFrag` except the umbrella; in the plan graph the subtree 11.37-11.49 plus 11.40 feeds only Phase 18 (records). It gates none of Phases 12.2, 13, 14, 15.1, 15.2, 16, 17. [VERIFIED by grep and by extracting every `Depends on` line.]
- **Recommendation: stop the row-link route at its current statement.** Land the two refutations as wired probes, close 11.49 and 11.40 by exclusion, and take the real open question to the user: the owed fibre equation over `kappa` is already refuted at the filed `(K4)` (`no_fibre_equation_over_kappa`), and the choice is between a jump-closed (at least exponential) threshold programme and a quasistate-level certificate that gives up `kappa`-completeness. Ranked alternatives are in the Recommendations section.

## Context & Scope

Adversarial viability review of the row-link route (plan v28 Phases 11.37-11.49, 11.40), scoped by the orchestrator's five questions. No `.lean` source, plan or record was edited. Two scratch files were compiled outside the repository; their load-bearing source is reproduced in the Appendix because the scratch directory is not durable.

Every claim below carries one of three marks: **[V]** verified mechanically in this round (compiled, or grep/`awk` over the tree), **[I]** inferred by argument from verified facts, **[G]** a guess. Every declaration name asserted to exist was grep-verified with `grep -rnE '(theorem|lemma|def) +<name>'` over `FormalSystem/`, `Tests/` and `specs/evidence/` (Ruling 25); the two names that do NOT exist are stated as absent: `exists_rowLinked_path` (only `exists_rowLinked_path_zero`, `LadderStepFrag.lean:756`) and `no_rowLinked_path_of_Mrel` (no hit anywhere).

## Findings

### Codebase Patterns

#### F1. The new refutation: the path forth fails through the gap coordinate [V]

Scratch file `gap_jump_refutation.lean` (Appendix A). Four results, all compiled:

- `region_exit_zrel` and `region_exit_register` — an OBJECT-INDEPENDENT necessary condition. If `LnkRow a (b + 1) g g' t t'` holds between ladder paths and `g` is pending at `t`, then the two region exits (the first idle positions, `t + cntAt g t + 1` and `t' + cntAt g' t' + 1`) are `Zrel a b`-related, hence their registers are **equal or both `≥ 2 a`**. The answering position is forced: every position the answer passes must be answered by a pending position, and the answer itself is idle.
- `no_rowLinked_path_gap (P a b c) (ha : 1 ≤ a) (hc : 2 * (b + 1) ≤ c)` — on the two-state object (`Bool`, every step allowed, `pend := id`): the states `x = (pending, c, c + 2a)` and `y = (pending, c, c + 2a + 1)` are `Mrel P a (b + 1)`-related at EVERY `P`; the path `ramp c a` through `x` lets the register fall at every step and exits with register `2a - 1`; every ladder path through `y` exits with register `≥ 2a` (`Drift` is one-sided over `c + 1` steps). `2a - 1` against `≥ 2a` is neither equal nor both `≥ 2a`.
- `exists_rowLinked_path_K1_refuted` — the negation of the Phase 11.49 signature verbatim (`[Fintype Q]`, `fwd`, `bwd`, `hK1 : ∀ l ∈ objCycleLens step pend, l ∣ (P + 1)`, `Mrel P a b (h t) y`), instantiated at `P = 1`, `(a, b) = (1, 1)`, with `hK1` discharged on the fixture by `hK1G`.
- `no_rowLinked_path_gap_any_room` — the same with countdowns equal and both `≥ N`, registers both `≥ N`, for every `N`.

Why the four earlier rounds missed it [I]: every earlier attack (`no_rowLinked_path_of_Zrel`, `no_rowLinked_path_of_Srel`, `exists_rowLinked_path_over_Mrel_refuted`, the `R4` and `B5` fixtures) uses pairs with DIFFERENT countdowns and attacks the region-end object state. This pair has equal countdowns and the same object walk, so `LnkRow.region_end_obj` and `LnkRow.first_zero` are satisfied trivially; the only freedom left to the second path is its register walk, and that fails.

The inflation that was lost [V, by reading the module header]: the round-24 goal the header of `LadderStepFrag.lean` quotes hypothesises `Zrel` at an INFLATED budget (`hbig : 2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ …` for a conclusion `LnkRow a (b + 2)`), and the header's fact 1 says outright that `S a b` cannot be `Zrel a b` for a gap reason (`mixC`, "argued, compiled nowhere"). `Mrel P a b` is defined over `Zrel a b` at the SAME budget as the conclusion, so the inflation disappeared between round 24 and `Mrel`. At a hypothesis inflated to `(a + b + 1, a + b)` this particular one-jump pair is no longer related [I]; F2 shows why that does not rescue the route.

#### F2. The projected end result is refuted by a family already in the tree [V]

Scratch file `mrel_cell_refutation.lean` = the wired probe `ladder-cell-agreement-refutation.lean` with its import widened to `LadderStepFrag` and three theorems appended (Appendix B). Compiled, exit 0:

- `Mrel_dblC_pair` — `stC c (c + Kc j + 1)` and `stC c n'` are `Mrel P a b`-related whenever `2 a ≤ Kc j + 1`, `2 (a + b) ≤ c`, `c + Kc j + 2 ≤ n'`.
- `cell_agreement_over_Mrel_refuted (P a b j) (ha : 2 * a ≤ Kc j + 1)` — such a pair exists with `cellAt MC (dblC j)` different at its two states (by the tree's `dblC_cell_ne`).
- `cell_agreement_over_Mrel_refuted_at_depths (P j)` — the same at `(a, b) = (dBack (dblC j), dFwd (dblC j)) = (j, 3)`.

Since `Kc j + 1 = 2 ^ (j + 1) - 1` (`Kc_eq`), any agreement of cells over `Mrel P (A φ) (B φ)` with `A` polynomial in the two depths is false. This is the same exponential lower bound `gap_clip_below_exponential_refuted` records on the `kappa` side, now stated against the relation the row-link route is trying to prove an agreement over.

Consequence for the scaffold instantiation recorded in round 28 section 14 [I]: the natural `S k m s s' := Mrel P k m (h s) (h' s')` cannot satisfy `LnkRow.of_closed`'s `hfw`/`hbw` in general. If it did, the `⊡`/`□` lift would follow by induction on the formula (a re-chosen history at a matched pair needs the HYPOTHESIS relation there, which is exactly what this `S` supplies), giving the agreement F2 refutes. So the stall at the jump clauses is not a missing lemma.

#### F3. Q1 — the `Drift`-seam obstruction: an artifact of a deeper, structural defect

- **The seam claim as recorded is correct only conditionally [I].** `spliceEmb a l v = if v < a then v else v + l` (`LadderAgree.lean:2561`) [V]. The image of the embedding skips the `l` inserted positions, so the two demands on embedded positions are `l + 1` steps apart and a fall of `l` is `Drift`-feasible. The adjacency arises only because the INSERTED cycle positions must be answered back too: with their natural partners `a + i` (the only positions guaranteed the same object state), exact gap preservation needs `reg' = R_i + l` on the first copy and `reg' = R_i` on the second, where `R_i` is the original register at `a + i`. The join at `a + l - 1 → a + l` is feasible iff `R_{l-1} = R_0 - (l - 1)`, i.e. iff the ORIGINAL path's register falls at every step of the cycle. The original path is adversarial, so it need not.
- **Whether `Zrel`'s threshold disjuncts cover the transition: NO in general, and this is now settled by a case with no seam at all [V via F1].** In F1 the second path may copy the first's object walk and countdown exactly (`l = 0`); the register alone fails, at the far end of ONE jump, with every state above every countdown threshold. So the threshold disjuncts do not cover what a jump does to the gap, independently of any splice.
- **`exists_ladderPath_of_walk` concluding only `objAt` and `cntAt`: a fixable weakness that fixing would not help [I].** The register's law is `Drift` plus the pin `c' = n` at each idle-to-pending step [V, `Rlad`/`Count`], so a splice lemma that takes a prescribed register walk satisfying those two is plausibly provable — `exists_ladderPath_of_walk_nxt_at` (`LadderChain.lean:694`) already pins one anchor. But F1 needs no splice lemma, so strengthening it cannot close the path forth at this statement. It is the same obstruction in a different hat: the defect is in what `LnkRow` DEMANDS of the register (a gap threshold not closed under jumps), not in what the splice lemma EXPOSES.
- **The seam in isolation looks repairable by the standard device [I/G]:** pump a cycle of the PRODUCT state (object, clipped register, clipped gap) rather than of the object alone, so the register profile repeats and copies across. That needs the product cycle lengths to divide `P + 1` — which is what `paramsOkK1`'s FIRST conjunct (`prodCycleLens`) and `exists_typeBlock_of_spacing` at spacing `P + 1` exist for, i.e. the full `(K1)` that route (R-1) would have taken. So the seam, taken alone, points back at (R-1) and a sixth hypothesis; it is moot given F1.

#### F4. Q3 — the row-link layer is not on the critical path [V]

- Import graph: `grep -rn 'import.*LadderStepFrag'` finds only `FormalSystem/Metalogic/Decidability/RaySummary.lean:33` (the umbrella).
- Consumers: `LnkRow`, `truth_iff_of_lnkRow`, `exists_rowLinked_path_zero`, `LnkRow.of_closed`, `Mrel`, `Srel`, `exists_lengthened_region` occur in `LadderStepFrag.lean`, the README and `KTypeSummaryAxiomTest.lean` only.
- Plan graph (every `Depends on` line of plan v28 extracted with `awk`): Phase 16 (`ladderRealized`) ← 13, 15.2; 15.2 ← 15.1; 15.1 ← 7, 11.16, 11.7, 12.2; 13 ← 12.2; 12.2 ← 12.1, 11.7, 12.5; 14 ← 10, 13; 17 ← 16; 11.31 ← 11.30 ← 11.33. **Phase 11.40 appears as a dependency of Phase 18 only.**
- So the layer gates 0 of the 9 open non-record phases. What it was FOR is indirect: Phase 11.7 (`cellAt_const_of_kappa_eq`) is closed with exclusions and its schema is refuted (`cellAt_const_of_kappa_eq_schema_refuted`, `no_fibre_equation_over_kappa`); the row-link route was the attempt to DERIVE a clip at which an agreement holds. Phase 11.40 item 3 already concedes that even full success is "NOT an agreement over `kappa`-classes, because the bridge … is what the clip refutations kill". F2 now shows the agreement over `Mrel` is false as well. The `untl` clause therefore gates nothing owed and proves nothing reachable.

#### F5. Q2 — route (N-2) as written is not enterable, and its blocker is the same fact [V for the citations, I for the diagnosis]

- (N-2) = Phases 11.30/11.31, the run-level adequacy pair: SOUNDNESS (every ladder history projects to a class run) and EXISTENTIAL REALIZATION (every accepting class run is realized by some history, at the origin and in acceptance, never positionwise). It does not mention `LnkRow` or `exists_rowLinked_path` [V]; it genuinely avoids the row-link layer.
- It is held closed by Ruling 4: `certStabK_fails_of_contains_realized` compiles that condition (5) fails on every set containing the realized triples at the filed clip. The reason is in `certStabK`'s definition (`CounterQuotient.lean:1221`) [V]: the `⊡` bit at a member is the fibre of `R` over `(q, κ)`. That clause IS a `kappa`-uniformity demand. A set of realized triples satisfies it only if cells are constant on `kappa`-classes — the very completeness (N-2) proposes to stop asking for.
- So (N-2) is coherent only with a re-keyed certificate: members `(q, cell, κ)` with `cell` a SET of types (a quasistate), the `⊡` clause internal to the cell. That edits a landed certificate-side definition and re-opens the 2026-10-18 presentation decision (presentation (a): `Dmax ⊆ Q × ClType φ × K`). Phase 11.30 itself says such a change is "a route finding … not a licence to edit". It is a user decision, and the resulting `ladderRealized` is a different (two-containment) statement — Statement Fidelity routes that to the user too.
- Risk profile [I/G]: the soundness leg is the forward simulation and has landed inputs (`rk_of_count_drift`, `real_certStabK_mpr`). The existential leg is the hard one: with the model FIXED (`ladderModel`, not a model built from the certificate), the `⊡` clause at a realized state quantifies over ALL histories through it, so an adversarial history reappears once per `⊡`-depth level. `(K2)`'s `D + 1` factor was sized for exactly that. The difference from the row-link route is that the realizing state is CHOSEN (it may sit above every threshold) and no syntactic relation on counters has to be closed under jumps. Not costable from here.
- `LnkRow.of_closed` on (N-2): **stranded** [I]. It is a statement about `LnkRow` and nothing in the adequacy pair mentions a row link. It is 25 lines; the loss is negligible. The durable assets (N-2) does reuse are `LadderPump.lean`'s type-preserving surgery, the splice layer, `exists_lengthened_region`, and the countdown/object measurements.

#### F6. Q5 — the repair pattern is diagnostic, and it names the mis-statement

- Four repairs, one coordinate. `Srel` added a countdown residue, `Mrel` a countdown threshold, (R-2) a divisibility condition on the countdown's modulus, and the pending fifth is countdown room. The gap and register clauses are `Zrel`'s from Phase 11.37 throughout [V, definitions of `Srel`/`Mrel`].
- `Zrel`'s thresholds are, by the module header's own property 2, the solution of ONE-STEP closure conditions (`G⁺(a,b) ≥ G⁺(a−1,b) + 2`, `N(a,b) − 1 ≥ G⁺(a−1,b)`, …). A jump crosses unboundedly many positions on one unit of budget. The closure conditions a jump imposes are different [I, with F1 and F2 as the compiled instances]:
  - forward jump to a region exit: `G⁺(a, b) ≥ N(a, b − 1) + 1` (the gap becomes the exit register's lower bound). `Zrel` has `2a` against `2(a + b − 1) + 1`: violated for every `b ≥ 1`. This is F1.
  - backward jump across a region from an idle state, for a relation that must hold again at the matched pair (which the `⊡` lift requires): `N(a, b) ≥ 2 N(a − 1, b) + 2`, the doubling `lvlC` exploits. Linear thresholds violate it as soon as `a + b > 1`. This is F2's mechanism.
- So there is no reason to expect a fifth countdown-side conjunct to succeed: F1's pair survives every one of them. **The target is mis-stated in two places:** (i) the state relation's gap/register thresholds must solve the JUMP closure recurrences, which forces growth at least exponential in the backward budget; (ii) `LnkRow` hard-codes `Zrel` at its matched pairs, so it can neither carry a stronger relation to the `⊡` lift nor be instantiated at a corrected one.
- The right statement, if this route is kept at all [I]: `LnkRow` generalised over a budget-indexed state relation `R` (`LnkRowOver R a b g g' t t'`; `LnkRow.of_closed` and `truth_iff_of_lnkRow` generalise with the soundness clause `R a b → same object state`), and the path forth stated as jump-closure of a relation `Erel` whose thresholds are DERIVED from the two recurrences above. Whether ANY finite solution exists is the open question the header already records ("whether a clip exponential in `dBack` does is OPEN"); nothing in this round settles it. [G]: a solution of order `2 ^ a · (linear in b)` exists — the forward direction does not appear to compound, because an exit register can always be driven to `0` — but a tower-type family combining both jumps has not been ruled out.

### External Resources

#### Q4 — what the literature construction is, and how its hypothesis set differs

Recalled from the standard sources, not re-read this round; treat names of results as pointers to check, not as sourced claims.

- **`LnkRow` is the Ehrenfeucht–Fraïssé game for until/since** (Etessami–Wilke, "An until hierarchy and other applications of an Ehrenfeucht–Fraïssé game for temporal logic", Inf. & Comput. 2000). The until move is exactly `FwdJump`: Spoiler picks a later position, Duplicator answers, Spoiler picks a position strictly before the answer, Duplicator answers back strictly before the pick; rounds are bounded by until/since nesting depth. `truth_iff_of_lnkRow` is that paper's adequacy theorem on `RowFrag`; `LnkRow.of_closed` is "a family of position relations closed under the moves is a winning strategy". The row-link layer is a correct rediscovery of this game.
- **What is non-standard is using it to prove decidability over an infinite-width frame.** In the EF literature Duplicator's strategy on counters carries thresholds that grow with the number of rounds, and they grow geometrically as soon as a move can be re-anchored — the same doubling F2 exhibits. A game-based route therefore has exponential thresholds as its NORMAL form; linear thresholds are the step-fragment special case, which is the one the tree proved (`stepFrag_gap_depth_exact`).
- **The decidability literature the task cites does not go through a game at all.** Hodkinson–Wolter–Zakharyaschev 2000 (Definitions 11-12, Theorem 14, Lemma 17 as the library's README cites them) uses quasimodels: a state candidate (quasistate) is a SET of types, a run selects one type per time point, and the two directions are "read a quasimodel off a model" and "build a model from a quasimodel by choosing runs". Surgery is cut-and-paste between positions with EQUAL TYPES (equal Hintikka sets); it preserves types at the remaining positions by the usual until/since argument and carries no numeric hypothesis. The tree already has this as `LadderPump.lean` (the type-preserving pump layer).
- **The hypothesis set of the known version is therefore: an abstraction that is SOUND and EXISTENTIALLY realizable — never one that is a complete invariant of model points.** The filed fibre equation `cellAt … = {T | (q, S, κ(c, n)) ∈ Dmax}` asserts completeness of `κ`, which has no counterpart in the quasimodel literature, and `certStabK`'s `(q, κ)`-fibre clause encodes the same demand on the certificate side. The four rounds were groping toward a syntactic characterisation of when two counter pairs have equal cells; the literature never needs one. Its nearest analogue here is the quasistate-keyed certificate of F5.

### Recommendations

Ranked. Rank 1 is unconditional; ranks 2-4 are alternatives for what follows it and need a user decision.

1. **Stop the row-link route at its current statement. Do not add a fifth hypothesis.** Wire the two refutations as evidence probes — `exists_rowLinked_path_K1_refuted` with its supporting lemmas (Appendix A, self-contained, 241 lines) and the three `Mrel`/`dblC` theorems (Appendix B, appended to the existing fifth section of `ladder-cell-agreement-refutation.lean`, whose import must then be `LadderStepFrag`, or placed in `ladder-row-link-residue-obstruction.lean` with the `dblC` fixture re-stated) — then close Phase 11.49 and Phase 11.40 `[COMPLETED WITH EXCLUSIONS]` citing them by name. Keep `LnkRow.of_closed`, `exists_lengthened_region`, `exists_spliced_ladderPath_nxt_of_pend_past`, `Zrel.forall_iff_eq` and the coordinate measurements exactly where they are; none is invalidated. [VERIFIED: PASS -- both scratch files compile with `lake env lean` from the repository root against the built tree, exit 0, no `sorryAx`, axioms `[propext, Classical.choice, Quot.sound]` on the six headline theorems printed with `#print axioms`. NOT run: `scripts/check-evidence-probes.sh` on the wired form, which needs the files inside `specs/evidence/` and was out of scope for a read-only round.]
2. **Take the statement question to the user before any further implementation dispatch.** The task owes a fibre equation over `kappa`; it is refuted at the filed `(K4)`, any repaired `(K4)` must dominate `2 ^ (dBack φ + 1)`, and whether one exists is open. The decision is between ranks 3 and 4. [No compiled gate applicable]
3. **(Preferred of the two continuations) Re-key the certificate to quasistates and run (N-2).** Members `(q, cell, κ)`, `⊡` clause internal to the cell, `ladderRealized` re-stated as an honestly named soundness-plus-existential-realization pair. It follows the cited literature, it removes the completeness demand that every refutation in this task has hit, and its soundness leg has landed inputs. Cost: re-opens the presentation decision, edits `certStabK`/`Dmax`, changes the Challenge statement; the existential leg's `⊡`-depth induction is uncosted. [No compiled gate applicable]
4. **(Only if the fibre EQUATION must be kept) One time-boxed, refutation-first round on jump-closed thresholds.** State the two recurrences of F6, define `Erel` at their least solution, generalise `LnkRow` over the state relation, and ATTACK first: look for a family beating `2 ^ (a + 1)` by alternating forward and backward jumps. A tower-type family ends the equation for good; survival licenses one attempt at `hfw`/`hbw` over `Erel`. This is the only continuation in which `LnkRow.of_closed` is live. [No compiled gate applicable]
5. **(Rejected) Continue Phase 11.49 with count moves 2 and 3 and the fifth hypothesis.** The statement those moves serve is false. [VERIFIED: FAIL -- `exists_rowLinked_path_K1_refuted` (scratch, compiled) refutes the signature, and `no_rowLinked_path_gap_any_room` shows the room hypothesis does not exclude the pair; revised to: recommendation 1.]

**What would falsify recommendation 1.** (a) The scratch probes failing to compile when wired — re-run them; they use only library declarations and the two fixtures. (b) A showing that the intended hypothesis was never `Mrel P a b` at the conclusion's budget but an inflated one: that removes F1's one-jump pair, but F2 still refutes the agreement at every polynomial inflation, so the route's end result stays false; only an at-least-exponential relation (rank 4) survives. (c) A showing that some owed phase consumes the row link — the `Depends on` extraction found none.

## Decisions

- Treated "the statement is false" as a finding to compile rather than argue: both refutations were compiled before any recommendation was written.
- Did not attempt the exponential-threshold question; it is a separate round and its answer is not needed to rank stopping first.
- Did not re-read HWZ 2000 or Etessami–Wilke; Q4 is marked as recalled.
- Reproduced the scratch sources in the Appendix rather than writing into `specs/evidence/`, per the round's no-edit rule.

## Risks & Mitigations

- **The scratch probes are not wired.** Until they sit under `specs/evidence/` and pass `check-evidence-probes.sh`, the refutation lives in this report. Mitigation: Appendix A is self-contained; wiring is mechanical.
- **Rank 3 changes the task's statement.** Mitigation: it is routed to the user, not to an implementer; the report does not recommend a same-named weaker restatement.
- **Rank 4 may consume a round and return "open".** Mitigation: time-box it and make the attack the first deliverable, as rounds 25-28 did.
- **F3's seam analysis and F6's recurrences are inferred, not compiled.** Nothing in the ranking depends on them; they explain F1 and F2, which are compiled.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| exit-register dichotomy from `Zrel`'s gap clause at two idle states | `omega` | success | after stating both countdowns as `(g _).1.2.1 = 0` and `show`-ing the goal in projection form; fails if `cntAt` is unfolded inside the position arguments |
| `Mrel` membership of an explicit pair | `refine ⟨⟨⟨rfl, Or.inl rfl, Or.inr ⟨?_, ?_⟩, Or.inr (Or.inl ⟨?_, ?_⟩)⟩, Int.ModEq.refl _⟩, Or.inl rfl⟩` then `show …; omega` | success | `push_cast` before `omega` on the two integer gap goals |
| `Count` side conditions on the fixture | `simp [Count, pnd]` | success | N/A |
| `IsLadderPath` of an `if`-defined path | `by_cases` on the two guards, `simp only [ramp, if_pos, if_neg]`, `show`, `omega` | success | N/A |
| `2 * j ≤ Kc j + 1` | `omega` | success | `Kc_eq j`, `Nat.lt_two_pow_self`, `pow_succ` |

## Context Extension Recommendations

- **Topic**: closure conditions for budget-indexed relations under JUMP moves (until/since games) versus step moves.
- **Gap**: the Lean context documents the step-closure derivation of `Zrel`'s thresholds but nothing says a relation closed under steps must be re-derived for jumps; four rounds inherited step-derived gap thresholds into a jump-indexed link.
- **Recommendation**: a short pattern note under `.claude/context/project/logic/` (edited at its source store, not in the deployed tree): "before proving a back-and-forth for a new move, re-solve the closure recurrences for THAT move on every coordinate, and attack the coordinate nobody has repaired".

## Appendix

### Search and verification commands used

- `grep -rnE '(theorem|lemma|def) +<name>'` over `FormalSystem Tests specs/evidence` for every cited name.
- `grep -rn 'import.*LadderStepFrag' FormalSystem Tests`; word-greps for the row-link declarations' consumers.
- `awk` extraction of every `**Depends on**` line of plan v28.
- `lake env lean <scratch file>` from the repository root, twice, exit 0 each (17 s for the larger file).

Scratch files (session-scoped, not durable): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d795962e-60ab-47a6-9397-2d3f4a621ce2/scratchpad/gap_jump_refutation.lean`, `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d795962e-60ab-47a6-9397-2d3f4a621ce2/scratchpad/mrel_cell_refutation.lean`.

### Appendix A — `gap_jump_refutation.lean`, complete, as compiled

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ProbeGapJump

/-- A row link with one forward jump relates the two region EXITS (first idle positions). -/
theorem region_exit_zrel {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool} {a b : ℕ}
    {g g' : ℤ → LadderState Q pend} {t t' : ℤ} (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (h : LnkRow a (b + 1) g g' t t')
    (hp : pend (objAt g t) = true) :
    Zrel a b (g (t + (cntAt g t : ℤ) + 1)) (g' (t' + (cntAt g' t' : ℤ) + 1)) := by
  have hz := h.zero
  have hp' : pend (objAt g' t') = true := by
    have e : objAt g' t' = objAt g t := hz.1.symm
    rw [e]; exact hp
  rw [LnkRow] at h
  obtain ⟨h1, -⟩ := h.2.1 b rfl
  obtain ⟨s', hs', hR, hbt⟩ := h1 (t + (cntAt g t : ℤ) + 1) (by omega)
  have hidle := not_pend_of_count g hg t hp
  have hidle' := not_pend_of_count g' hg' t' hp'
  have hobj : objAt g' s' = objAt g (t + (cntAt g t : ℤ) + 1) := hR.zero.1.symm
  have hsub := cntAt_sub_of_pend g hg t hp
  have hsub' := cntAt_sub_of_pend g' hg' t' hp'
  have hs'eq : s' = t' + (cntAt g' t' : ℤ) + 1 := by
    rcases lt_trichotomy s' (t' + (cntAt g' t' : ℤ) + 1) with hlt | heq | hgt
    · have := (hsub' (s' - t').toNat (by omega)).1
      rw [show t' + (((s' - t').toNat : ℕ) : ℤ) = s' by omega, hobj, hidle] at this
      exact absurd this (by simp)
    · exact heq
    · obtain ⟨r, hr1, hr2, hRr⟩ := hbt _ (by omega) hgt
      have hq : objAt g' (t' + (cntAt g' t' : ℤ) + 1) = objAt g r := hRr.zero.1.symm
      have := (hsub (r - t).toNat (by omega)).1
      rw [show t + (((r - t).toNat : ℕ) : ℤ) = r by omega, ← hq, hidle'] at this
      exact absurd this (by simp)
  rw [← hs'eq]; exact hR.zero

/-- **NECESSARY CONDITION (object-independent).** A row link with one forward jump at a pending
position forces the registers at the two region exits to be equal or both `≥ 2 a`. -/
theorem region_exit_register {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool} {a b : ℕ}
    {g g' : ℤ → LadderState Q pend} {t t' : ℤ} (hg : IsLadderPath step pend g)
    (hg' : IsLadderPath step pend g') (h : LnkRow a (b + 1) g g' t t')
    (hp : pend (objAt g t) = true) :
    nxtAt g (t + (cntAt g t : ℤ) + 1) = nxtAt g' (t' + (cntAt g' t' : ℤ) + 1) ∨
      (2 * a ≤ nxtAt g (t + (cntAt g t : ℤ) + 1) ∧
        2 * a ≤ nxtAt g' (t' + (cntAt g' t' : ℤ) + 1)) := by
  have hz := h.zero
  have hp' : pend (objAt g' t') = true := by
    have e : objAt g' t' = objAt g t := hz.1.symm
    rw [e]; exact hp
  obtain ⟨-, -, -, h4⟩ := region_exit_zrel hg hg' h hp
  have c0 : (g (t + (cntAt g t : ℤ) + 1)).1.2.1 = 0 :=
    cntAt_eq_zero_of_idle g hg _ (not_pend_of_count g hg t hp)
  have c0' : (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.1 = 0 :=
    cntAt_eq_zero_of_idle g' hg' _ (not_pend_of_count g' hg' t' hp')
  show (g (t + (cntAt g t : ℤ) + 1)).1.2.2 = (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.2 ∨
    (2 * a ≤ (g (t + (cntAt g t : ℤ) + 1)).1.2.2 ∧
      2 * a ≤ (g' (t' + (cntAt g' t' : ℤ) + 1)).1.2.2)
  omega

theorem nxt_ge_sub {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    ∀ i : ℕ, nxtAt g u ≤ nxtAt g (u + (i : ℤ)) + i := by
  intro i
  induction i with
  | zero => simp
  | succ i ih =>
    have hd : Drift (nxtAt g (u + (i : ℤ))) (nxtAt g (u + (i : ℤ) + 1)) :=
      (isLadderPath_components g hg (u + (i : ℤ))).2.2.1
    unfold Drift at hd
    have hcast : u + ((i + 1 : ℕ) : ℤ) = u + (i : ℤ) + 1 := by push_cast; ring
    rw [hcast]
    omega

/-! ### The fixture: the two-state object, everything steps to everything -/

def stp : Bool → Bool → Bool := fun _ _ => true
def pnd : Bool → Bool := id

theorem fwdG : ∀ (t : ℤ) (x : LadderState Bool pnd), ∃ y, RladAdm stp pnd t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun h => absurd h (by simp [pnd]), Or.inl rfl,
        by simp [Count, pnd]⟩
    | succ k =>
      exact ⟨⟨(true, k, n), fun h => absurd h (by simp [pnd])⟩, rfl,
        fun h => absurd h (by simp [pnd]), Or.inl rfl, by simp [Count, pnd]⟩

theorem bwdG : ∀ (t : ℤ) (x : LadderState Bool pnd), ∃ y, RladAdm stp pnd (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩
  | true =>
    exact ⟨⟨(true, c + 1, n), fun h => absurd h (by simp [pnd])⟩, rfl,
      fun h => absurd h (by simp [pnd]), Or.inl rfl, by simp [Count, pnd]⟩

/-- The object half of `(K1)` holds on the fixture at every even modulus. -/
theorem hK1G (P : ℕ) (h2 : 2 ∣ P + 1) : ∀ l ∈ objCycleLens stp pnd, l ∣ (P + 1) := by
  rintro l ⟨h0, hle, -⟩
  have hcard : Fintype.card Bool = 2 := Fintype.card_bool
  rw [hcard] at hle
  have : l = 1 ∨ l = 2 := by omega
  rcases this with rfl | rfl
  · exact one_dvd _
  · exact h2

/-- The first path: pending forever in the past, the register falling at every step; the region
ends at position `c`, and the idle state after it carries the register `2 a - 1`. -/
def ramp (c a : ℕ) : ℤ → LadderState Bool pnd := fun u =>
  if u ≤ (c : ℤ) then
    ⟨(true, ((c : ℤ) - u).toNat, ((c : ℤ) + 2 * a - u).toNat), fun h => absurd h (by simp [pnd])⟩
  else ⟨(false, 0, 2 * a - 1), fun _ => rfl⟩

theorem ramp_isPath (c a : ℕ) (ha : 1 ≤ a) : IsLadderPath stp pnd (ramp c a) := by
  intro u
  show Rlad stp pnd u (ramp c a u).1 (ramp c a (u + 1)).1
  by_cases h1 : u + 1 ≤ (c : ℤ)
  · have h0 : u ≤ (c : ℤ) := by omega
    simp only [ramp, if_pos h0, if_pos h1]
    refine ⟨rfl, fun h => absurd h (by simp [pnd]), Or.inr (Or.inr ?_), ?_⟩
    · show ((c : ℤ) + 2 * a - (u + 1)).toNat + 1 = ((c : ℤ) + 2 * a - u).toNat
      omega
    · show Count (pnd true) (pnd true) _ _ _
      simp only [Count, pnd, id, if_true]
      omega
  · by_cases h0 : u ≤ (c : ℤ)
    · have hu : u = c := by omega
      subst hu
      simp only [ramp, if_pos h0, if_neg h1]
      refine ⟨rfl, fun h => absurd h (by simp [pnd]), Or.inr (Or.inr ?_), ?_⟩
      · show 2 * a - 1 + 1 = ((c : ℤ) + 2 * a - c).toNat
        omega
      · show Count (pnd true) (pnd false) _ _ _
        simp [Count, pnd]
    · simp only [ramp, if_neg h0, if_neg h1]
      exact ⟨rfl, fun _ => rfl, Or.inl rfl, by simp [Count, pnd]⟩

/-- The second state: same object state, SAME countdown, register one higher. -/
def yG (c a : ℕ) : LadderState Bool pnd :=
  ⟨(true, c, c + 2 * a + 1), fun h => absurd h (by simp [pnd])⟩

theorem ramp_zero (c a : ℕ) :
    ramp c a 0 = ⟨(true, c, c + 2 * a), fun h => absurd h (by simp [pnd])⟩ := by
  have h0 : (0 : ℤ) ≤ (c : ℤ) := by omega
  simp only [ramp, if_pos h0]
  apply Subtype.ext
  show ((true, ((c : ℤ) - 0).toNat, ((c : ℤ) + 2 * a - 0).toNat) : Bool × ℕ × ℕ) = (true, c, c + 2 * a)
  have e1 : ((c : ℤ) - 0).toNat = c := by omega
  have e2 : ((c : ℤ) + 2 * a - 0).toNat = c + 2 * a := by omega
  rw [e1, e2]

/-- The two states are `Mrel`-related at EVERY modulus: equal countdowns, registers both above
the register threshold, gaps `2 a` and `2 a + 1` both at the gap threshold `2 a`. -/
theorem Mrel_ramp_yG (P a b c : ℕ) (hc : 2 * (b + 1) ≤ c) :
    Mrel P a (b + 1) (ramp c a 0) (yG c a) := by
  rw [ramp_zero]
  refine ⟨⟨⟨rfl, Or.inl rfl, Or.inr ⟨?_, ?_⟩, Or.inr (Or.inl ⟨?_, ?_⟩)⟩, Int.ModEq.refl _⟩,
    Or.inl rfl⟩
  · show 2 * (a + (b + 1)) ≤ c + 2 * a
    omega
  · show 2 * (a + (b + 1)) ≤ c + 2 * a + 1
    omega
  · show 2 * (a : ℤ) ≤ ((c + 2 * a : ℕ) : ℤ) - (c : ℤ)
    push_cast; omega
  · show 2 * (a : ℤ) ≤ ((c + 2 * a + 1 : ℕ) : ℤ) - (c : ℤ)
    push_cast; omega

/-- **NO ROW-LINKED PATH, THROUGH THE GAP COORDINATE.** -/
theorem no_rowLinked_path_gap (P a b c : ℕ) (ha : 1 ≤ a) (hc : 2 * (b + 1) ≤ c) :
    Mrel P a (b + 1) (ramp c a 0) (yG c a) ∧ cntAt (ramp c a) 0 = c ∧
      IsLadderPath stp pnd (ramp c a) ∧
      ¬ ∃ h' : ℤ → LadderState Bool pnd, IsLadderPath stp pnd h' ∧ h' 0 = yG c a ∧
        LnkRow a (b + 1) (ramp c a) h' 0 0 := by
  have hcnt : cntAt (ramp c a) 0 = c := by rw [cntAt, ramp_zero]
  refine ⟨Mrel_ramp_yG P a b c hc, hcnt, ramp_isPath c a ha, ?_⟩
  rintro ⟨h', hh', h0', hl⟩
  have hp : pnd (objAt (ramp c a) 0) = true := by rw [objAt, ramp_zero]; rfl
  have hreg := region_exit_register (ramp_isPath c a ha) hh' hl hp
  have hcnt' : cntAt h' 0 = c := by rw [cntAt, h0']; rfl
  have hnxt' : nxtAt h' 0 = c + 2 * a + 1 := by rw [nxtAt, h0']; rfl
  rw [hcnt, hcnt'] at hreg
  have hlow := nxt_ge_sub h' hh' 0 (c + 1)
  rw [show (0 : ℤ) + ((c + 1 : ℕ) : ℤ) = 0 + (c : ℤ) + 1 by push_cast; ring, hnxt'] at hlow
  have hexit : nxtAt (ramp c a) (0 + (c : ℤ) + 1) = 2 * a - 1 := by
    have hn : ¬ (0 + (c : ℤ) + 1 ≤ (c : ℤ)) := by omega
    simp only [nxtAt, ramp, if_neg hn]
  rw [hexit] at hreg
  omega

/-- **THE PATH FORTH AT THE PHASE 11.49 SIGNATURE IS FALSE.**  Verbatim the signature recorded in
`round-28-k1-admissible-refutation.md` section 11, object half of `(K1)` included. -/
theorem exists_rowLinked_path_K1_refuted :
    ¬ ∀ (Q : Type) [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool),
        (∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend t x y) →
        (∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend (t - 1) y x) →
        ∀ (P : ℕ), (∀ l ∈ objCycleLens step pend, l ∣ (P + 1)) →
        ∀ (a b : ℕ) (h : ℤ → LadderState Q pend), IsLadderPath step pend h →
          ∀ (t : ℤ) (y : LadderState Q pend), Mrel P a b (h t) y →
            ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧
              LnkRow a b h h' t t := by
  intro hall
  obtain ⟨hM, -, hp, hno⟩ := no_rowLinked_path_gap 1 1 0 2 le_rfl (by norm_num)
  exact hno (hall Bool stp pnd fwdG bwdG 1 (hK1G 1 (by norm_num)) 1 (0 + 1) (ramp 2 1) hp 0
    (yG 2 1) hM)

/-- The same refutation with EVERY magnitude hypothesis a repair could add: the countdowns are
equal and as large as desired, so no countdown threshold, residue condition or pigeonhole room
(`Fintype.card Q ≤ cntAt`) excludes the pair. -/
theorem no_rowLinked_path_gap_any_room (P a b N : ℕ) (ha : 1 ≤ a) :
    ∃ (x y : LadderState Bool pnd) (h : ℤ → LadderState Bool pnd),
      IsLadderPath stp pnd h ∧ h 0 = x ∧ Mrel P a (b + 1) x y ∧
      x.1.2.1 = y.1.2.1 ∧ N ≤ x.1.2.1 ∧ N ≤ x.1.2.2 ∧ N ≤ y.1.2.2 ∧
      ¬ ∃ h' : ℤ → LadderState Bool pnd, IsLadderPath stp pnd h' ∧ h' 0 = y ∧
        LnkRow a (b + 1) h h' 0 0 := by
  obtain ⟨hM, hcnt, hp, hno⟩ :=
    no_rowLinked_path_gap P a b (N + 2 * (b + 1)) ha (by omega)
  refine ⟨ramp (N + 2 * (b + 1)) a 0, yG (N + 2 * (b + 1)) a, ramp (N + 2 * (b + 1)) a, hp, rfl,
    hM, ?_, ?_, ?_, ?_, hno⟩
  · rw [ramp_zero]; rfl
  · rw [ramp_zero]; show N ≤ N + 2 * (b + 1); omega
  · rw [ramp_zero]; show N ≤ N + 2 * (b + 1) + 2 * a; omega
  · show N ≤ N + 2 * (b + 1) + 2 * a + 1; omega

end ProbeGapJump

#print axioms ProbeGapJump.region_exit_register
#print axioms ProbeGapJump.no_rowLinked_path_gap
#print axioms ProbeGapJump.exists_rowLinked_path_K1_refuted
#print axioms ProbeGapJump.no_rowLinked_path_gap_any_room
```

### Appendix B — the theorems appended to a copy of `ladder-cell-agreement-refutation.lean`

The copy differs from the wired probe in one line (`import …LadderAgree` → `import …LadderStepFrag`) and in this appended block.

```lean
namespace Probe761C

/-- The `dblC` pair is `Mrel`-related at EVERY modulus and every budget `(a, b)` whose backward
component satisfies `2 a ≤ 2 ^ (j + 1) - 1`: equal countdowns, large registers, gaps both `≥ 2 a`. -/
theorem Mrel_dblC_pair (P a b j c n' : ℕ) (ha : 2 * a ≤ Kc j + 1) (hc : 2 * (a + b) ≤ c)
    (hgap : c + Kc j + 2 ≤ n') :
    Mrel P a b (stC c (c + Kc j + 1)) (stC c n') := by
  refine ⟨⟨⟨rfl, Or.inl rfl, Or.inr ⟨?_, ?_⟩, Or.inr (Or.inl ⟨?_, ?_⟩)⟩, Int.ModEq.refl _⟩,
    Or.inl rfl⟩
  · show 2 * (a + b) ≤ c + Kc j + 1
    omega
  · show 2 * (a + b) ≤ n'
    omega
  · show 2 * (a : ℤ) ≤ ((c + Kc j + 1 : ℕ) : ℤ) - (c : ℤ)
    push_cast; omega
  · show 2 * (a : ℤ) ≤ ((n' : ℕ) : ℤ) - (c : ℤ)
    omega

/-- **NO AGREEMENT OF CELLS OVER `Mrel`, AT ANY BUDGET BELOW THE EXPONENTIAL.** -/
theorem cell_agreement_over_Mrel_refuted (P a b j : ℕ) (ha : 2 * a ≤ Kc j + 1) :
    ∃ c n' : ℕ, Mrel P a b (stC c (c + Kc j + 1)) (stC c n') ∧
      cellAt MC (dblC j)
          ((0, stC c (c + Kc j + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (dblC j)
            ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 :=
  ⟨2 * (a + b), 2 * (a + b) + Kc j + 2, Mrel_dblC_pair P a b j _ _ ha le_rfl le_rfl,
    dblC_cell_ne j _ _ le_rfl⟩

/-- At the formula's OWN exactness depths. -/
theorem cell_agreement_over_Mrel_refuted_at_depths (P j : ℕ) :
    ∃ c n' : ℕ, Mrel P (dBack (dblC j)) (dFwd (dblC j)) (stC c (c + Kc j + 1)) (stC c n') ∧
      cellAt MC (dblC j)
          ((0, stC c (c + Kc j + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (dblC j)
            ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  refine cell_agreement_over_Mrel_refuted P _ _ j ?_
  rw [dBack_dblC]
  have h1 := Kc_eq j
  have h2 : j < 2 ^ j := Nat.lt_two_pow_self
  rw [pow_succ] at h1
  omega

end Probe761C

#print axioms Probe761C.cell_agreement_over_Mrel_refuted
#print axioms Probe761C.cell_agreement_over_Mrel_refuted_at_depths
```
