# Implementation Plan: Weak + Finite-Context Consequence Completeness for FrameClass.Dedekind (v6)

> **REFRAMING NOTE (carried forward from v1, applies to the whole plan)**: "Strong completeness"
> is reserved, project-wide, for the genuine infinite-premise statement (`Γ : Set Formula` with
> finitary set-derivability), which is **provably unavailable** for the Dedekind class — its
> consequence relation is not compact (Reynolds 1992 Theorem 7 is *weak* completeness, and the
> restriction is genuine). The headline result for this class is **weak completeness**
> `completeness_dedekind`; the arbitrary-finite-`Γ` form, inter-derivable with it through the
> deduction theorem, is `consequence_completeness_dedekind`. No proof obligation, phase
> boundary, or route decision changes under this renaming. See
> `FormalSystem/Metalogic/StrongCompleteness.lean`'s module docstring for the per-class
> programme. **This rename landed concurrently with the v1 → v2 revision**; v2 uses the new
> names throughout, and the Phase 2 signature pinned by commit `bd9ae0ac1` is renamed but not
> restructured.

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: 78 hours (v5's 55 + the R3d decomposition: Phase 7.5 at 4h, 7.6 at 5h, 7.7 at 6h,
  7.8 at 5h, 7.9 at 3h. R3d was `[USER GATED]` and unbudgeted in v5; it is **authorized** in v6
  and is budgeted here as five agent-run-sized sub-phases)
- **Dependencies**: None (coordinates with, but is not blocked by, the strong-completeness
  architecture and finite-context strong-completeness efforts — neither has artifacts on disk)
- **Research Inputs**:
  - reports/05_forward-guard-r3-research.md (primary for **this revision as well as v5** —
    v6 applies its §8.2 Amendments 2-4 verbatim and decomposes its §6 Phase-7.5 sketch; its §5
    family `Q` is carried into the risk register as the R3d falsification candidate)
  - summaries/05_phase-7-3-guard-gap-above-summary.md, summaries/05_phase-7-4-forward-transport-summary.md
    (the landed 7.3/7.4 outcomes; **the landed signatures in these summaries and in the plan's
    Phase 7.4 DEVIATION block are ground truth for v6, not the v5 drafts**)
    (its full v5 characterization, retained: adversarially verified,
    Tier 1 literature-backed — Burgess 1984 printed pp.109-110, Burgess 1982 I printed
    pp.369/372-373, Reynolds 1992 printed pp.175-178, all re-read verbatim in that dispatch.
    Supplies: the necessity theorem `r3_invariant_necessary`; the sorry-free
    `boundedWitness_of_limitGuardBelow`; the elaborated statement of `limitGuardAbove_of_priorU`;
    the order-theoretic characterization settling that `cantorIsoDense` is not a lever; the
    **charter gap** — forward `snce` at an unselected target; and the verdict that R3d has **no
    source in the corpus**)
  - reports/04_backward-transport-blocker.md (primary for v4; adversarially verified,
    Tier 1 literature-backed — Reynolds 1992 printed pp.175-176, Burgess 1982 I printed
    pp.369/372/373, Burgess 1984 printed pp.109-110)
  - reports/03_limit-future-witness-blocker.md (primary for v3; adversarially verified, Tier 1
    literature-backed — Reynolds 1992 printed p.176, Burgess 1984 printed pp.109-110. Its
    Reynolds page-offset parenthetical is corrected by report 04: PDF page `i` ↔ printed
    `164 + i`, not `165 + i`. Every *printed*-page attribution it made is nevertheless correct,
    so no citation in this plan or in any landed docstring changes)
  - reports/01_faithful-route-strong-completeness.md (route selection, adversarially verified)
  - reports/02_literature-coverage-audit.md (literature infrastructure, citation discipline)
  - plans/04_strong-completeness-dedekind-v4.md (superseded predecessor; its Phase 7.2 dispatch
    supplied the forward-case-B probe outcome that triggered this revision)
  - plans/03_strong-completeness-dedekind-v3.md (superseded predecessor of v4)
  - plans/02_strong-completeness-dedekind-v2.md (superseded predecessor of v3)
  - plans/01_strong-completeness-dedekind.md (superseded predecessor of v2)
  - handoffs/phase-7.1-handoff-20260727165057.md (the Phase 7.1 refutation and its
    bounded-witness residual proposal, which report 04 corrects)
  - summaries/04_phase-7-2-forward-case-b-probe-summary.md (the probe outcome: R2 dead on
    verbatim Reynolds evidence; Refutation 3; the four landed declarations)
  - summaries/04_phase-6-3-guard-gap-lemma-summary.md
  - summaries/04_phase-7-1-backward-transport-summary.md
  - summaries/02_phase-6-1-real-bundle-summary.md
- **Artifacts**: plans/06_strong-completeness-dedekind-v6.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Phases**: **19 total** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4, **7.5, 7.6, 7.7,
  7.8, 7.9**, 8) — **13 `[COMPLETED]`** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4),
  **6 `[NOT STARTED]`** (7.5, 7.6, 7.7, 7.8, 7.9, 8). Next dispatch target: **Phase 7.5**.
  **Counting convention (v6)**: `phases_total = 19`, `phases_completed = 13`,
  `phases_dispatchable = 6`, `phases_user_gated = 0`. **`[USER GATED]` no longer exists in this
  plan** — the R3d gate was resolved by explicit user authorization at this revision, so every
  remaining phase is `[NOT STARTED]` and dispatchable in heading order. `19 = 13 completed +
  6 dispatchable`. Phase 8 remains **hard-gated by its stated precondition** (the discharge of
  `BFMCS.LimitGuardEventual`) — it is dispatchable *in the marker sense* but the orchestrator's
  heading scan reaches it only after 7.5-7.9 are `[COMPLETED]`, which is exactly the gate.
- **reports_integrated**: 01_faithful-route-strong-completeness.md,
  02_literature-coverage-audit.md, 03_limit-future-witness-blocker.md,
  04_backward-transport-blocker.md, 05_forward-guard-r3-research.md

---

## Revision Rationale (v5 → v6)

**One trigger, and it is a decision rather than a discovery: the user has granted fresh explicit
authorization for R3d.** Phases 7.3 and 7.4 landed sorry-free exactly as v5 chartered them, the
entire remaining forward obligation is now the single named predicate `BFMCS.LimitGuardEventual`,
and v5 recorded that its discharge required "fresh explicit user authorization" plus Amendments
2-4 plus its own decomposition. All three are supplied here.

**The authorization, quoted verbatim as the record of what was granted:**

> **R3d AUTHORIZED. Amendments 2-4 may now be applied. Phase 7.5 to be decomposed into
> agent-run-sized sub-phases and implemented as an original construction held to the same rigor
> (counterexample checks, adversarial verification, literature-honest docstrings stating the
> construction has no source). Phase 8 remains gated until LimitGuardEventual is discharged.**

Nothing else about the route changes. The completion route, the rational-selection extension
shape, the real-shift closure, the pinned terminus signature, and every asset landed by Phases
1-7.4 stand unamended. **No Postmortem Constraint is touched except the three that Amendments 2, 3
and 4 amend, and each of those is amended by exactly the drafted text, no more.**

**What v6 does, item by item.**

1. **Amendments 2, 3 and 4 are APPLIED, verbatim from report 05 §8.2**, under the fresh explicit
   user authorization quoted above, dated **2026-07-27** (the `{DATE}` placeholder in Amendment 2's
   drafted text is resolved to that date and nothing else in the drafted text is altered). The
   "Drafted, NOT applied" block in the Postmortem Constraints is replaced by an **APPLIED** block
   that carries the same three texts, and each amendment is *also* appended in place to the
   constraint it amends, so a reader of that constraint cannot miss it. Amendment 1 remains applied
   as in v5. **Every other Postmortem Constraint stands in full force**, including — and this is
   worth naming because the R3d work runs closest to it — the no-witness-aware-**selection** rule
   (R3d changes the *construction*, never the choice of `Ultrafilter.of`), the
   no-`cantorIsoDense`-edit rule (proved not a lever, report 05 §4.2), the
   no-expressive-completeness / no-EF-games rules, the no-closure-enlargement rule (Amendment 3
   clarifies that indexing an invariant *by* a closure is not enlarging it, and explicitly restates
   that **no closure may grow**), and the no-conditional-terminus rule.
2. **Phase 7.5 is decomposed into five agent-run-sized sub-phases**, numbered **7.5, 7.6, 7.7, 7.8,
   7.9** — flat, not three-level. **Numbering decision, verified against the scan, not assumed**:
   the orchestrator's phase scan is
   `grep -E '^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]' … | head -1`
   (`.claude/skills/skill-orchestrate-hard/SKILL.md:422-424`). The group `(\.[0-9]+)?` admits **at
   most one** dot-segment, so a heading `### Phase 7.5.1: …` would **not** match and the sub-phase
   would be invisible to dispatch. Three-level numbering is therefore rejected and flat numbering
   is used. `head -1` means the scan selects the **first** matching heading in file order, so the
   sub-phases appear in dispatch order and all remain below Phase 8; numbering stays monotone.
   The umbrella charter for R3d is carried in a heading that deliberately does **not** begin
   `### Phase`, so it is never itself a dispatch target.
3. **Each sub-phase is chartered as determined work with a stated deliverable, not as a probe** —
   territory (exact files), declarations with signatures, line estimate, `Done when`, and its own
   prohibitions. Sizing is H8: each is bounded to one agent run, ~150-500 lines of output.
4. **The family-`Q` realizability question is carried as a first-class, two-outcome risk register
   entry, not as a caveat.** Report 05 §5 exhibits an ultrafilter-**independent** candidate
   refutation and states plainly that settling its realizability at `fc = FrameClass.Dedekind`
   needs the EF / expressive-completeness machinery the Postmortem Constraints forbid. **The
   construction must either defeat family `Q` or discover that it is realizable, and both outcomes
   are planned for here.** If a sub-phase discovers the pattern is realizable inside
   `cantorBfmcsDense` — i.e. exhibits a branch of `eliminatePotentialCounterexample` that provably
   cannot preserve the invariant — that is a **successful falsification**, the sub-phase is marked
   `[BLOCKED]` with the exact obstruction, the task's honest floor is `[PARTIAL]`, and Phase 8 is
   not dispatched. That floor is stated in every sub-phase, not only here.
5. **Honesty charter for docstrings (binding user directive, chartered explicitly).** Every
   declaration introduced by Phases 7.5-7.9 must carry a docstring that states, in its own words
   and without hedging, that **this construction has no source in the corpus and is original
   work**. Where it adapts a neighbouring discipline, the citation form is **ADAPTED-FROM with
   printed pages** — never "following", never "transcribed from", never a bare citation that a
   later reader could mistake for transcription. The two permitted ADAPTED-FROM anchors are
   **Burgess 1982 I §2.10, printed pp.372-373** (fresh-point witness placement: `y = x + 1` beyond
   the maximum, `z = (x + x')/2` at the midpoint) and **Burgess 1984 §2.7, printed pp.109-110**
   (the A7a-licensed far-side gap witness). A docstring that cites either source without the
   ADAPTED-FROM qualifier is a defect, and so is one that omits the no-source statement.
6. **Phase 8: charter unchanged, `[NOT STARTED]`, precondition updated but not weakened.** It
   becomes dispatchable exactly when Phase 7.9 lands
   **`Chronicle.cantor_bfmcs_dense_limit_guard_eventual`** — the cantor-side discharge of
   `BFMCS.LimitGuardEventual` — together with `cantor_bfmcs_dense_real_restricted_fuc`. The
   terminus `consequence_completeness_dedekind_of_engine` and its pinned signature (commit
   `bd9ae0ac1`) carry forward **unchanged**. **There is still no conditional terminus**, and the
   v3 constraint forbidding one is not amended by anything in v6.
7. **Preserved-assets accounting extended** with Phase 7.3's and Phase 7.4's landed declarations:
   `limitGuardAbove_of_priorU`, `cantor_bfmcs_dense_limit_guard_above`,
   `BFMCS.LimitGuardEventual`, `boundedWitness_of_limitGuardBelow`,
   `toRealBundle_forward_until_unselected`, `toRealBundle_forward_since_unselected`, and
   `BFMCS.toRealBundle_restricted_forward_until_since`. Phase 7.4's `[COMPLETED]` marker is
   **carried from v5** (the implement dispatch set it; v6 does not re-adjudicate it), as is
   Phase 7.3's.
8. **The landed signatures are ground truth, not the v5 drafts.** v5's Phase 7.4 Statement 5 drafted
   the binder list `(B) (root) (h_rfuc) (h_rbuc) (h_lgb) (h_lge)`; that is **not provable as
   written** and the dispatch recorded a DEVIATION. The landed signature — carried forward verbatim
   in the Phase 7.4 section and in the Preserved Assets table — is
   `(hfc) (B) (root) (h_rfuc) (hSf) (hSb) (h_lga) (h_lge)`: `h_rbuc` and `h_lgb` are **dropped** as
   unused, and `hfc`/`hSf`/`hSb`/`h_lga` are **added**. Any phase of v6 that composes against this
   theorem must use the landed binder list. `h_lga` in particular is Phase 7.3's *conclusion written
   out as a binder*, not a `BFMCS.LimitGuardAbove` predicate — no such predicate exists and none is
   to be created.
9. **`[USER GATED]` is retired from this plan.** v5 used it as a deliberate single format deviation
   for a phase awaiting a user decision. The decision has been made, so the marker has no referent
   and every phase heading in v6 uses the standard vocabulary from
   `.claude/rules/plan-format-enforcement.md`. **v6 contains no format deviations.**
10. **Phase counts.** v6 has **19 phases**, of which **13 are `[COMPLETED]`** (1, 2, 3, 4, 5, 6,
    6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4) and **6 are `[NOT STARTED]`** (7.5, 7.6, 7.7, 7.8, 7.9, 8).

**What v6 does NOT change, stated so no dispatch reads authorization as a general relaxation.**
R3d is authorized; nothing else is. The statements of `cantor_bfmcs_dense_restricted_tc` / `_buc` /
`_fuc` and of `limit_F_resolution` / `limit_satisfies_c4` / `limit_satisfies_c5_strong` remain
**unchanged** — that is a proviso *of* Amendment 2, not an obstacle to it. Every currently
sorry-free consumer must remain sorry-free. No closure may grow. `cantorIsoDense` is not edited.
No expressive completeness, no EF games, no `≡_k`, no Stavi connectives, no monadic-FO layer. The
single live sorry outside `Boneyard/` stays at exactly `WeakCanonical/Transfer.lean:1242`.

**What remains honestly unsettled.** Report 05 §5.4's verdict stands verbatim and is not softened
by the authorization: **R3 is neither proved live nor proved dead.** The invariant is consistent
with every formula-level demand (the closure is a `Finset`, so only finitely many guards matter;
no formula can force accumulation at a gap), and the chronicle already retains Burgess's interval
datum `g(x,y)` needed to state it — but the candidate refutation is ultrafilter-independent and the
existing construction demonstrably lacks the invariant. Authorization is a decision to **attempt**
an original construction with the base rate stated, not a prediction that it closes. Every prior
unsourced escalation on this task (`limitMCS_no_oscillation`, the `fc`-generic backward transport,
the bounded-witness detour *as a route*, R2) was subsequently refuted or killed; that base rate was
put to the user and the authorization was granted against it.

---

## Revision Rationale (v4 → v5, retained for history)

One trigger, established by `reports/05_forward-guard-r3-research.md`: Phase 7.2's two-outcome
probe fired **outcome (ii)**, and the blocker research that followed settled three things v4 could
not have known. **This is not a route change.** The completion route, the rational-selection
extension shape, the real-shift closure, the pinned terminus signature, and every asset landed by
Phases 1-7.2 stand unamended. What changes is the decomposition of the remaining *forward* work,
one prohibition that was justified by a factually false clause, and one charter defect.

**Three independent reasons v4 had to be revised** (report 05 §8.1), only one of which is about R3:

1. **The CHARTER GAP.** `fully_restricted_parametric_completeness_from_neg_membership`
   (`Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417-422`) consumes three coherence
   hypotheses, `h_rtc` / `h_buc` / `h_fuc`. The `h_fuc` side needs **forward `snce` at an
   unselected target**. That obligation is landed **nowhere** and is chartered in **no phase of
   v4**: Phase 7.2's charter names only the `untl` half ("obtain the real Until witness from a
   membership at an unselected `t`"), and Phase 7.1′ chartered only the three *backward* cases.
   **Even under the most optimistic reading of v4, Phase 8 was never reachable**, because a
   required case was assigned to no phase. This is a v4 defect independent of the R3 decision. v5
   charters it in **Phase 7.4**, where report 05 §3 shows the same invariant discharges it *more
   cheaply* than the `untl` half — it needs no Prior-U step at all, because the obligation "∃ `s`
   < `t` with `φ` at `s` and `ψ` on `(s,t)`" is literally `ψ ∈ limitSetBelow m (t+δ)` plus a
   cofinal descent.
2. **Phase 8's heading marker was a live inconsistency.** v4's own Revision Rationale item 7
   states the marker was corrected from `[IN PROGRESS]` to `[NOT STARTED]`, but the heading at
   `plans/04_strong-completeness-dedekind-v4.md:2320` still read `[IN PROGRESS]`. The
   orchestrator's phase scan reads that heading, not the rationale. **Corrected in v5**: Phase 8
   is `[NOT STARTED]`. No charter change; none of its tasks is checked and no dispatch has run
   against it.
3. **The R3 decomposition.** Report 05 proves the decomposition is *forced*, not chosen — see
   below.

**The load-bearing new mathematics: R3's invariant is NECESSARY.** Report 05 §3 proves,
sorry-free against the real tree (`lean_run_code`, `success: true`, zero errors, no `sorry`):

```lean
theorem r3_invariant_necessary
    (m : Rat → Set Formula) (δ t : ℝ) (ψ : Formula)
    (hgb : ∀ (c : Rat), t + δ < (c : ℝ) →
      (∀ q : Rat, t + δ < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q) → ψ ∈ limitSetBelow m (t + δ))
    (s : ℝ) (hts : t < s)
    (hguard : ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS m δ r) :
    ψ ∈ limitSetBelow m (t + δ)
```

Read: the conclusion of forward case B **entails its own R3 hypothesis**. The guard clause of the
conclusion is quantified over *all* reals of `(t, s)`, and the selected ones among them are
exactly the rationals of `(t + δ, s + δ)`; the conclusion therefore hands back a rational guard
interval abutting the gap from above, and the **landed** `limitGuardBelow_of_priorS` converts it
to one abutting from below. Consequently:

> **`BFMCS.LimitGuardEventual` is necessary and sufficient for the whole remaining forward
> obligation, both halves.** There is no third route, no weaker sufficient condition, and no way
> to sidestep it. A future dispatch proposing one has not read this.

This is why Phases 7.3/7.4 are **determined work, not probes**: the target is unique, the
statements are written out, one is already proved, and the third is verified to elaborate.

**What v5 adds as determined work.**

1. **New Phase 7.3 — `limitGuardAbove_of_priorU` (R3a).** One agent run, ~180-220 lines, new file
   `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean`, plus the
   chronicle discharge. It is the **exact Prior-U mirror** of the landed
   `limitGuardBelow_of_priorS` (`ChronicleLimitGuardWitness.lean:105-207`) with `snce → untl`,
   `prior_S_gap → prior_U_gap`, `kMinus → kPlus`, `.2 → .1`, and every inequality reversed.
   Statement verified to elaborate against the tree. **No amendment required.**
2. **New Phase 7.4 — the bounded witness (R3b) + the conditional forward transport (R3c), and
   the charter-gap repair.** One agent run, ~200-240 lines.
   `boundedWitness_of_limitGuardBelow` is **already proved sorry-free** (12 lines, report 05 §3)
   and is to be *transcribed*, not re-derived; `BFMCS.LimitGuardEventual` is the named,
   phase-internal predicate; **both** unselected forward cases land — the `untl` half and the
   newly-chartered `snce` half; then the composition. Conditional on the named predicate with a
   stated discharge phase — the identical shape Phase 6.1 used for `LimitFutureWitness`, which
   this plan explicitly permits. **Requires Amendment 1 only.**
3. **Amendment 1, applied verbatim (report 05 §8.2).** The v4 bounded-witness prohibition is
   **narrowed in place**. Its clause (iii) — "**no case of the transport needs it**" — was
   **proved false** for forward case B: `boundedWitness_of_limitGuardBelow` is exactly what case
   B needs at step 5, and its `hcof` hypothesis is *literally the right disjunct* of the landed
   `toRealBundle_forward_until_unselected_dichotomy` (`ChronicleRealExtension.lean:732`).
   **This amendment corrects a factually false justification clause**, on the authority of
   report 05 §3 (the twelve-line sorry-free proof) and §9.2 item 1 (the verification that changed
   the recommendation). The prohibition's *original target* — the bounded witness **as a route**,
   derived from `LimitFutureWitness` — is retained in full. This is the same narrowing-in-place
   move v3 and v4 each performed once on this plan.
4. **Phase 7.2 → `[COMPLETED]`, its BLOCKER retired into a RESOLUTION/OUTCOME record.** Its
   charter was a **two-outcome probe** ("Settle forward case B … either by proving it or by
   exhibiting a refuting family"; "Done when: … case (a) is landed sorry-free and the refuting
   family is delivered with the three elements above"). It completed with outcome (ii) plus four
   landed sorry-free declarations. **Convention applied**: the phase's own `Done when` clause is
   the completion criterion, and it was met; the `[BLOCKED]` marker v4 carried was the marker the
   *phase text* instructed the dispatch to set for outcome (ii), which is why this revision — the
   escalation that outcome demanded — is the point at which it is retired. The findings are
   preserved verbatim as an OUTCOME record, exactly as v3 retired Phase 6.1's BLOCKER and v4
   retired Phase 7.1's.
5. **Phase 7.5 (R3d) is recorded as `[USER GATED]`, with Amendments 2-4 DRAFTED but NOT
   APPLIED.** See the phase and the "Drafted, NOT applied" block in the Postmortem Constraints.
   The user's decision on this revision was **"v5 + defer R3d"**: v5 does the determined work
   only; after 7.3/7.4 land, the R3d decision is re-presented. **R3d must not be elected without
   fresh explicit user authorization.**
6. **Phase 8: charter unchanged, `[NOT STARTED]`, with an explicit precondition.** Not
   dispatchable until `BFMCS.LimitGuardEventual` is discharged (Phase 7.5 or an accepted
   alternative). The terminus `consequence_completeness_dedekind_of_engine` and its pinned
   signature carry forward **unchanged** — no conditional terminus, no undischarged predicate
   threaded onto it. That prohibition is not amended by anything in v5.
7. **Refuted premises purged from every task list.** Report 05 §4.1 refutes the 6.2/6.3-mirror
   route for the *forward* guard, and no task, table row, or docstring instruction in v5 asks for
   it: `prior_U_gap`'s antecedent `U(⊤,χ)` **is** the below-gap interval, so it can never
   *produce* one; `prior_S_gap` produces one only *from* an above-gap interval — that is the
   landed `limitGuardBelow_of_priorS`, and §3 shows it yields the **necessity** direction, i.e.
   it consumes the conclusion rather than supplying the hypothesis; and `Axiom.sep`
   (`Axioms.lean:398`) is entirely inside `K⁺`/`K⁻` (arbitrarily-soon), the *negation* of "holds
   on an interval", so it cannot produce an interval either. These survive **only** as
   prohibitions and as OUTCOME record. Likewise the intuition that `cantorIsoDense` is the lever
   is **refuted** (§4.2, order-theoretic characterization, both directions written out) and
   survives only as a prohibition.
8. **Literature fidelity, stated honestly and asymmetrically.** Phases 7.3/7.4 are
   **transcription-grade** work: 7.3 is Reynolds' Theorem 3 move (printed p.176) mirrored onto a
   landed file, 7.4's bounded witness is a Phase-6.3 corollary, and 7.4's predicate is Reynolds'
   `γ⁺` / left-gap condition (printed p.175). **Phase 7.5 has NO literature source.** Burgess
   1984's completion runs in `F`/`G`, which has no guard, and takes its one gap conversion from
   axiom **A7a**, never from selection (printed pp.109-110); Burgess 1982 I has `U`/`S` but **no
   Dedekind variant** (variants table, printed p.369) and never reaches a gap — every witness is
   a **fresh** point, `y = x + 1` or `z = (x + x')/2` (printed pp.372-373), the discipline
   `CounterexampleElimination.lean` already transcribes verbatim; Reynolds obtains every
   gap-facing formula "by expressive completeness" (printed pp.176-178), which is forbidden and
   already fatal to R2. **R3d would be an original construction, not a transcription.** That is
   precisely why it is user-gated, and it is recorded as such rather than softened.
9. **Preserved-assets accounting extended** with Phase 6.3's, Phase 7.1′'s and Phase 7.2's landed
   declarations.
10. **Phase counts.** v5 has **15 phases** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4,
    7.5, 8), of which **11 are `[COMPLETED]`** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2),
    **3 are `[NOT STARTED]`** (7.3, 7.4, 8) and **1 is `[USER GATED]`** (7.5).

**Format note (deliberate, single deviation).** `[USER GATED]` is not one of the five markers in
`.claude/rules/plan-format-enforcement.md`. It is used here **on binding instruction**, because
the requirement is a marker the orchestrator's phase scan will **not** dispatch *and* which does
not misrepresent the phase's state: `[NOT STARTED]` would invite dispatch, `[BLOCKED]` would
assert a technical obstruction where the actual gate is a **pending user authorization decision**,
and `[PARTIAL]` would assert work landed. Every other heading in this plan uses the standard
vocabulary and the scannable format `### Phase N[.M]: title [STATUS]`, and the numbering is
monotone.

**What is honestly unsettled, and stays unsettled.** Report 05 §5 exhibits a candidate refutation
strictly stronger than Refutation 3 — **ultrafilter-independent** family `Q` — and states plainly
that settling its realizability at `fc = FrameClass.Dedekind` needs the EF / expressive-
completeness machinery the Postmortem Constraints forbid and that killed R2. **R3 is neither
proved live nor proved dead.** The honest floor if R3d is declined is `[PARTIAL]` — but a
materially better `[PARTIAL]` than the current one, because 7.3/7.4 reduce the entire remaining
forward obligation, **both halves**, to one named predicate with a stated discharge phase.

Everything binding in v4 is carried through unchanged: the pinned
`consequence_completeness_dedekind_of_engine` signature (commit `bd9ae0ac1`), the Reframing Note,
risk-first ordering, the single-permitted-strategic-sorry rule, the no-conditional-terminus rule,
and every Postmortem Constraint other than the one narrowed by Amendment 1.

---

## Revision Rationale (v3 → v4, retained for history)

One trigger, established by `reports/04_backward-transport-blocker.md`: v3's Phase 7.1 asked for
an `fc`-**generic** backward Until/Since transport whose only hypothesis on the rational bundle is
restricted backward coherence. The Phase 7.1 dispatch **refuted** that statement with two explicit
counterexample families and marked itself `[BLOCKED]`. The blocker research then established that
the obligation is not merely repairable but *already solved in the literature*, by a step v3's own
Phase 6.2 had already transcribed for the sibling obligation and did not reapply here.

**This is not a route change.** The completion route, the rational-selection extension shape, the
real-shift closure, the pinned terminus signature, and every asset landed by Phases 1-6.2 and by
the Phase 7.1 dispatch stand unamended. What changes is the decomposition of the remaining
backward work, and one docstring correction.

**The missing ingredient, exactly.** Not the bounded witness the Phase 7.1 handoff named. It is
the **Prior-S mirror of Phase 6.2's gap lemma, applied to the guard formula `ψ` rather than to a
witness**:

> **(G)** at an unselected real `r`, if `ψ ∈ m q` for every rational `q ∈ (r, c)` for some
> rational `c > r`, then `ψ ∈ limitSetBelow m r` — i.e. `ψ` also holds on a whole interval of
> rationals abutting `r` **from below**.

(G) is `Axiom.prior_S_gap` (`ProofSystem/Axioms.lean:387`, `minFrameClass = .Dedekind`, already
proved sound at `Metalogic/Soundness.lean:1531`, and **consumed nowhere on the completeness
route** — verified by grep over `Bundle/` and `BXCanonical/`). Semantically it says the `ψ`-region
has no definable **right** gap at `r` — Reynolds' `γ⁻` / "right gap", **printed p.175**.

**Why this is the faithful mechanism, not an approximation.** Reynolds' witness-placement
discipline at a gap is uniform across all seven Prior-U/Prior-S appeals in his §6: *find the
formula that is uninterruptedly true on an interval ending at the gap, and apply the gap axiom to
it* — never to the witness (printed pp.176, 178). In this obligation that formula is the guard
`ψ`, and the hypothesis of the backward transport literally hands us `ψ` true throughout an
interval abutting the gap, so Prior-S's antecedent `S(⊤, ψ)` is free — exactly as Phase 6.2's
`U(⊤, χ)` was free for `χ = Fφ`. Burgess 1982 I, the paper this tree's chronicle layer transcribes,
has **no Dedekind/continuity variant at all** (its variants table, printed p.369, lists only
Density, Discreteness, First/Last Element, No First/No Last Element) and never places a witness at
a gap — every placement is strictly between two existing rational points (`z = x + y/2`,
`y = x + 1`, `z = x + x'/2`; printed pp.372-373). Burgess 1984 §2.7 runs the completion route only
in the `F`/`G` fragment and reaches for the continuity axiom `A7a` at the analogous step (printed
pp.109-110). So the step v3 classified as "mechanical" appears in neither Burgess paper, and the
one source that performs it does so with a gap axiom in hand.

**Why the two refutations die.**

- *Refutation 1* (backward `snce`, selected target `5`, gap witness `g`; `V(φ) = (0,g)`,
  `V(ψ) = (g,5)`) violates (G): `ψ` is true on all rationals of `(g,5)` and on **no** rational
  below `g` — a `ψ`-right gap at `g`. With (G) the guard extends below `g` and the `snce` witness
  is placed **below** the gap, where `limitMCSBelow_cofinal_below` already supplies it. The
  handoff's diagnosis ("descending from the witness leaves the guarded interval") is true only
  because the guarded interval was taken to stop at `g`; Prior-S extends it past `g` and the
  descent lands inside. (This family independently violates Phase 6.2's **already-landed**
  `LimitFutureWitness`.)
- *Refutation 2* (backward `untl`, unselected target `g`; `V(ψ)` oscillating below `g`, equal to
  `(g,3)` above) violates (G) at `g` — verbatim Reynolds' `γ⁻` pattern. Once `ψ` holds on an
  interval `(a,g)`, rational backward coherence puts `untl φ ψ` in `m q` for every rational
  `q ∈ (a,g)`, hence in `limitSetBelow m g ⊆ limitMCSBelow m g`.

Both families remain **findings**: they refute the `fc`-generic transport *as v3 stated it*, and
that prohibition is now permanent. What they do not refute is the chronicle instance, which is
reachable and whose four cases all close.

What changes in v4:

1. **New Phase 6.3** — "The guard gap lemma". One agent run (~180-220 lines): the general
   `fc`-conditional lemma `limitGuardBelow_of_priorS`, the bundle predicate
   `BFMCS.LimitGuardBelow` (stated with **no** closure hypothesis — see the phase), and the
   chronicle discharge `cantor_bfmcs_dense_limit_guard_below`. This is an exact structural clone
   of Phase 6.2's settled `fc`-conditional / chronicle-discharged shape, with `.1 → .2`,
   `untl → snce`, `prior_U_gap → prior_S_gap`, `kPlus → kMinus`.
2. **Phase 7.1 rewritten as 7.1′.** Its BLOCKER block is retired into a RESOLUTION block that
   retains both counterexample families as findings. Its charter is now exactly the three
   **unlanded** backward cases (`untl` at an unselected target; `snce` with a gap witness; `snce`
   with a gap target) plus the chronicle instance `cantor_bfmcs_dense_real_restricted_buc` and one
   docstring correction. The 7 declarations already landed in `ChronicleRealExtension.lean` are
   **preserved assets**: consumed, not rewritten. One agent run (~140-180 lines). Depends on 6.3.
3. **Phase 7.2 is not widened, and 7.1′ is not a probe.** The route for 7.1′ is determined: the
   axiom is identified, the four cases are enumerated, and the discharge template is a landed
   file. Framing determined work as a probe is what invites an analysis-only dispatch. Phase 7.2
   keeps its two-outcome probe framing and its fallback ladder **verbatim** — report 04 explicitly
   does **not** clear forward case B (there the guard is the *conclusion*, so nothing supplies
   `S(⊤,ψ)` or `U(⊤,ψ)`, and v3's interval-failure family stands unrefuted). Only 7.2's dependency
   line is re-pointed at 7.1′.
4. **The refuted premise is purged from every task list.** No task, mapping-table row, or
   docstring instruction in v4 says "the witness-pattern direction is the easier of the two", and
   none asks for a **bounded** witness as a corollary of `LimitFutureWitness`. That derivation is
   not available (`limitFutureWitness_of_priorU`'s `by_contra` hypothesis is the *unbounded* one,
   so it has no purchase on a family whose `φ`-region is cofinal above `r` but starts late); the
   bounded statement *is* provable, but from `prior_S_gap` at `χ := φ.neg` via Phase 6.3's lemma —
   and **no case needs it**. Both survive only as prohibitions and as OUTCOME/RESOLUTION record,
   exactly as v3 handled `limitMCS_no_oscillation`. A dispatch that took the handoff's residual at
   face value would have looked for a bound via Prior-U, correctly found none, and reported the
   phase blocked a second time.
5. **Postmortem Constraints extended, not amended.** Report 04 checked the proposed route
   line-by-line against every existing prohibition and found **no amendment is required**: the
   one-sided limit, the no-chronicle-edits rule, the no-closure-enlargement rule, the
   no-witness-aware-selection rule, and the no-conditional-terminus rule all stand and are all
   respected. Two new prohibitions are added (no `fc`-generic backward transport on restricted
   backward coherence alone; no bounded-witness detour), and the settled `fc`-conditionality
   decision is widened in place to govern **every** gap-facing obligation on this route.
6. **One docstring defect is scheduled for correction.**
   `ChronicleRealExtension.lean`'s claim that Refutation 2's family fails unrestricted rational
   **forward** Until coherence is unsupported as written. It fails unrestricted rational
   **backward** Until coherence, via the separating formula `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ`. Neither claim
   is load-bearing — the operative exclusion is the guard-side gap discharge — but the docstring
   is corrected rather than defended, as a task item in 7.1′.
7. **Phase counts.** v4 has **12 phases** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2, 8), of which
   **8 are `[COMPLETED]`** (1, 2, 3, 4, 5, 6, 6.1, 6.2). Phase 8's heading marker is corrected
   from `[IN PROGRESS]` to `[NOT STARTED]` — none of its tasks is checked and no dispatch has run
   against it; this is a marker correction with no charter change.

Everything binding in v3 is carried through unchanged: the pinned
`consequence_completeness_dedekind_of_engine` signature (commit `bd9ae0ac1`), the Reframing Note,
the Preserved Assets accounting (extended with Phase 6.2's and Phase 7.1's landed declarations),
risk-first ordering, the single-permitted-strategic-sorry rule, and the plan-heading format
`### Phase N[.M]: title [STATUS]`, on which the orchestrator's phase scan depends.

---

## Revision Rationale (v2 → v3, retained for history)

Two triggers, both established by `reports/03_limit-future-witness-blocker.md`. Neither is a
route change: the completion route, the rational-selection extension shape, and every asset
landed by Phases 1-6.1 stand unamended.

**Trigger 1 — the `LimitFutureWitness` counterexample.** Phase 6.1 landed
`BFMCS.toRealBundle_restricted_temporally_coherent` under a named extra hypothesis
`B.LimitFutureWitness root` and marked itself `[BLOCKED]` on discharging it. The blocker research
found that the predicate **as written is false**, and not for a subtle reason: it quantifies over
*all* `r : ℝ`, including rationals. At a rational `r = (p : ℝ)` where `S_φ := {q | φ ∈ m q}` has a
maximum `p`, the hypothesis `Fφ ∈ limitMCSBelow m r` holds and the conclusion "some rational
`s > r` carries `φ`" fails. The only consumer
(`BFMCS.toRealBundle_restricted_temporally_coherent`, `RealExtensionBundle.lean:306`) calls it
strictly inside the `hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ` branch and therefore already has the
missing hypothesis in scope. The repair is one line at the definition and one argument at the
call site. This is a defect in the *statement* of an isolated obligation, not in the extension.

**Trigger 2 — Prior-U applies at the `Fφ` level, and the route was never using the Dedekind
axioms.** `Axiom.prior_U_gap` (`ProofSystem/Axioms.lean:377`, `minFrameClass = .Dedekind` at
`Axioms.lean:524`) appears nowhere in `Bundle/`, nowhere in `BXCanonical/Chronicle/`, and nowhere
in v2's Phases 3-8. The obstruction the counterexample exhibits is exactly a **definable gap**,
which is precisely what Prior-U excludes (Reynolds 1992, printed p.176, Theorem 3's proof: "By
Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction"). Phase 4's
refutation of Prior-U is **not** contradicted: Phase 4 applied Prior-U to `φ` itself, whose truth
region below a gap need not be an interval, so the axiom's antecedent `U(⊤, φ)` was unavailable.
Applied instead to `χ := Formula.someFuture φ`, whose truth region below the gap **is** the
interval `(-∞, sup S_φ)`, the antecedent is free. The two statements are different and both
verdicts stand; v2's blanket "no further attempt is warranted" is narrowed in place to "no
further attempt **at the `φ` level** is warranted".

**The enabling discovery.** `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc`
(`ChronicleToCountermodelBasic.lean:629,680,755`) each **discard** the closure-membership
argument of the restricted predicate (`intro t φ _ h_F`, `intro t φ ψ _ ⟨u, …⟩`,
`intro t φ ψ _ h_until`), because the underlying `limit_F_resolution`
(`ChronicleConstruction.lean:722`), `limit_satisfies_c4` (`:776`) and `limit_satisfies_c5_strong`
(`:1482`) are unrestricted in the formula. The Cantor dense chronicle therefore satisfies **full,
unrestricted** Until/Since coherence for every formula, and the auxiliary Prior-U formulas
(`U(⊤, Fφ)`, `U(¬Fφ ∨ K⁺¬Fφ, Fφ)`) are obtained at zero cost by instantiating those theorems at
*self-roots*, discharging the membership side condition with `self_mem_subformulaClosure`. **No
chronicle declaration is modified.**

What changes in v3:

1. **New Phase 6.2** — "The definable-gap discharge of `LimitFutureWitness`". One agent run:
   the predicate repair plus call-site line, the general `fc`-conditional gap lemma
   `limitFutureWitness_of_priorU`, and the chronicle instantiation
   `cantor_bfmcs_dense_limit_future_witness`. The discharge is **`fc`-conditional**
   (`FrameClass.Dedekind ≤ fc`), not `fc`-generic — this is the first place in the plan where the
   Dedekind axiom layer is actually consumed.
2. **Phase 6.1 → `[COMPLETED]`.** Its landed content (334 lines, 7 declarations, sorry-free,
   full `lake build` green) stands byte-identical; its one conditional task is discharged by
   Phase 6.2 rather than reopened. The inline BLOCKER block is retired into a RESOLUTION block
   pointing at Phase 6.2.
3. **Phase 7 is split.** 7.1′ collects the mechanical work (backward transport, the shared guard
   lemma, forward case A, the `snce` mirrors, and the two chronicle real instances that become
   available). 7.2 is a **two-outcome probe** for forward case B, whose acceptable outcomes are a
   proof *or* a refuting family — the research constructed a candidate family in which Prior-U at
   `untl α β` is satisfied locally with no contradiction, so refutation is live and is not a
   phase failure. The fallback ladder for the refutation outcome is fixed in advance in 7.2 so the
   orchestrator never improvises.
4. **`limitMCS_no_oscillation` is purged.** Phase 4's OUTCOME refuted it; v2's Phase 7 still
   instructed the implementer to re-invoke it. No task list, mapping-table row, or docstring
   instruction in v3 names that lemma. Phase 4's historical bullets are retained as record only
   and are explicitly not live instructions.
5. **Phase 8 acquires one prerequisite and one signature change.**
   `countermodel_dedekind_dense` gains `(hfc : FrameClass.Dedekind ≤ fc)` and must discharge
   `BFMCS.LimitFutureWitness` for `cantorBfmcsDense` via Phase 6.2's instantiation. Both are
   benign: `completeness_dedekind_engine` instantiates at `FrameClass.Dedekind` and
   `Dedekind ≤ Dedekind` is `by decide` (`Axioms.lean:491`).
6. **Postmortem Constraints extended** with the prohibitions implied by the three rejected
   alternatives: no two-sided/symmetric limit, no witness-aware selection at the unselected
   branch, no chronicle modification, no closure enlargement, and no `φ`-level Prior-U retry.

Everything binding in v2 is carried through unchanged: the pinned
`consequence_completeness_dedekind_of_engine` signature (commit `bd9ae0ac1`), the Reframing Note,
the Preserved Assets accounting, risk-first ordering, and the single-permitted-strategic-sorry
rule.

---

## Revision Rationale (v1 → v2, retained for history)

v1's Phase 3 task 4, `limitSetBelow_of_rat` — "at a rational `q` the limit set agrees with
`m q` on membership" — is **false in both directions**, and the Phase 3 implementation dispatch
produced the counterexample:

> Let `P` be an atom and let `m` be the theory-family of a genuine dense model in which `P`
> holds at every rational `p < 0` and fails at `0`. Every `FMCS` field is satisfied — they are
> semantic consequences — yet `P ∈ limitSetBelow m 0` while `P ∉ m 0`. The mirror construction
> (`P` at `0` only) refutes the other inclusion.

The root cause is structural, not tactical: `FMCS.forward_G` and `FMCS.backward_H`
(`Bundle/FMCSDef.lean:110,118`) are stated with **strict** inequalities, matching TM's strict
temporal operators, so nothing relates membership *at* `q` to membership *strictly below* `q`.
There is no `H φ → φ`, because `allPast` is the strict past operator.

v1's whole Phase 6 rested on that false lemma: it defined `FMCS.toReal` with
`mcs := limitSetBelow f.mcs`, a one-sided limit **at every real point including the rationals**,
and needed rational agreement to make the extension *extend* rather than *replace* the rational
family. What changes in v2:

1. **Phase 3** is rewritten to the four things that actually landed sorry-free (10 declarations,
   `Bundle/LimitMCS.lean`) and marked `[COMPLETED]`. The false task is deleted; the purpose it
   was serving is now discharged structurally in Phase 6, not by a lemma.
2. **Phase 6** adopts *rational selection*: the extension picks `m q` directly at any real that
   is a (shifted) rational, and takes the left limit only elsewhere. Agreement at selected points
   is then definitional. The rational/irrational case split this forces is enumerated explicitly,
   and Phase 6 is split into **Phase 6** (the `FMCS`-level extension) and **Phase 6.1** (the
   `BFMCS`-level bundle plus restricted temporal coherence) to stay inside H8's one-run bound.
3. A **second defect**, found while verifying the unblock path rather than inherited from the
   Phase 3 dispatch: the bundle's `modal_backward` field is **not provable** at an unselected
   real point if the real bundle's family set is `FMCS.toReal '' B.families` as v1 specified.
   Per-family "eventually" thresholds admit no common rational, so the Rat-side `modal_backward`
   can never be applied. v2 therefore closes the real family set under **real** shifts
   (`fam.toRealShift δ`, `δ : ℝ`), which lets the `modal_backward` witness family be positioned
   at the target point exactly as the Rat construction positions it at a rational
   (`ChronicleToCountermodelBasic.lean:576`). This is a Phase 6.1 obligation.
4. **Phase 5's lemma statements were also wrong** — not merely under-specified. The Phase 3
   dispatch asserted Phases 4 and 5 were unaffected and dispatchable; that claim is **verified
   for Phase 4 and refuted for Phase 5**. v1's `limitSet_forward_G` /`limitSet_backward_H`
   express only the limit-to-limit case of a four-case matrix. Phase 5 is restated as six named
   lemmas (each of which was hand-verified during this revision) plus two cases that are
   discharged by the rational family's own fields.
5. Phases 4, 7, 8 ripple is stated explicitly per phase below.
6. **Concurrent terminology reframing absorbed.** While this revision was being written, a
   separate effort reserved the name "strong completeness" for the infinite-premise statement
   and renamed the Phase 2 terminus to `consequence_completeness_dedekind` /
   `consequence_completeness_dedekind_of_engine` (working tree, `StrongCompleteness.lean`). v2
   uses the tree's current names throughout so no phase points at a declaration that does not
   exist. The rename changes no binder, no conclusion, and no phase boundary.

Everything binding in v1 is carried through unchanged: the `consequence_completeness_dedekind_of_engine`
signature pinned by Phase 2 (commit `bd9ae0ac1`), the Postmortem Constraints, the Preserved
Assets accounting, risk-first phase ordering, and the single-permitted-strategic-sorry rule at
`limitMCS_negation_complete`.

---

## Overview

The terminus pair is `consequence_completeness_dedekind : SemanticConsequenceDedekindDense Γ φ →
Derivable FrameClass.Dedekind Γ φ` (finite-context consequence completeness) with
`completeness_dedekind` — the class headline, weak completeness — derived as its `Γ = []`
instance. The two are inter-derivable through the deduction theorem, so they are one theorem in
two shapes; neither is "strong completeness" (see the Reframing Note above). The route is
Route B of the research report: build the countermodel directly on `ℝ`
from a Dedekind-MCS, inside the tree's own parametric canonical architecture, never leaving it.
Reynolds' transfer route (report 390's route) is rejected and no part of it is built.

The single genuinely new mathematical ingredient is a limit-MCS assignment extending a
`BFMCS (fc := fc) Rat` to a `BFMCS (fc := fc) ℝ` along `ℚ ↪ ℝ`. Everything else is either
verbatim reuse of existing frame-class-generic and `D`-generic machinery, or mechanical
transcription. Phases are sequenced risk-first: the `D := ℝ` compile probe is Phase 1, the
terminus statement lands in Phase 2 (fixing the exact engine interface before any engine work
begins), and the crux — negation-completeness of the limit MCS — is reached at Phase 4, before any of the
expensive downstream transport work is paid for.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`consequence_completeness_dedekind` with `completeness_dedekind` as a corollary; `lake build` is
green; `#print axioms consequence_completeness_dedekind` shows exactly `[propext, Classical.choice,
Quot.sound]`.

**Phase inventory (v6)**: **19 phases** — 1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1, 7.2, 7.3, 7.4,
**7.5, 7.6, 7.7, 7.8, 7.9**, 8. **13 are `[COMPLETED]`** (1, 2, 3, 4, 5, 6, 6.1, 6.2, 6.3, 7.1,
7.2, 7.3, 7.4); **6 are `[NOT STARTED]`** (7.5, 7.6, 7.7, 7.8, 7.9, 8). `phases_total = 19`,
`phases_completed = 13`, `phases_dispatchable = 6`, `phases_user_gated = 0`.

**Counting convention (v6, explicit)**: `19 = 13 completed + 6 dispatchable`. **There is no
`[USER GATED]` phase in this plan** — v5's single format deviation is retired, because the gate it
marked was resolved by explicit user authorization at the v5 → v6 revision. Every phase heading
uses the five standard markers of `.claude/rules/plan-format-enforcement.md`. The next dispatch
target is **Phase 7.5**.

**Phase heading format and the numbering decision (v6, verified against the scan)**: headings use
`### Phase N[.M]: title [STATUS]` throughout and the numbering is monotone. The orchestrator's
scan is `grep -E '^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]' … |
head -1` (`.claude/skills/skill-orchestrate-hard/SKILL.md:422-424`). Its `(\.[0-9]+)?` group admits
**at most one** dot-segment, so **three-level numbering (`7.5.1`) would not match and was
rejected**; the R3d sub-phases use **flat numbering 7.5-7.9**. `head -1` selects the first matching
heading in file order, so sub-phases are dispatched in the order they appear.

**Phase 8 precondition (v6, binding, updated but not weakened)**: Phase 8 is **not dispatchable**
until `BFMCS.LimitGuardEventual` is discharged for `cantorBfmcsDense`. **The exact expected
declaration is `Chronicle.cantor_bfmcs_dense_limit_guard_eventual`**, landed by **Phase 7.9**
together with `cantor_bfmcs_dense_real_restricted_fuc`. Landing 7.3-7.8 does **not** unblock it.
Until that declaration exists, threading `LimitGuardEventual` onto the terminus chain remains
prohibited outright and the correct task state is `[PARTIAL]`.

### Research Integration

| Report | Integrated | What it fixes in this plan |
|---|---|---|
| reports/01_faithful-route-strong-completeness.md | v1, 2026-07-27 | Route selection (B over A), phase sequencing, preserved-assets list, bridge prohibitions |
| reports/02_literature-coverage-audit.md | v1, 2026-07-27 | Goldblatt provenance caveat, sub-index gaps, citation discipline (PDF page, never `md:NN`) |
| plans/01_strong-completeness-dedekind.md — Phase 3 dispatch BLOCKER block | v2, 2026-07-27 | The rational-agreement counterexample; the rational-selection unblock path; the corrected Phase 3 task list |
| reports/03_limit-future-witness-blocker.md | v3, 2026-07-27 | The `LimitFutureWitness` predicate repair (unselectedness hypothesis); the Prior-U-at-`Fφ` discharge and its four-step proof; the self-root closure discovery; the Phase 7 split with its two-outcome probe; the Phase 8 `hfc` signature change; the three rejected alternatives now encoded as Postmortem Constraints |
| plans/02_strong-completeness-dedekind-v2.md — Phase 6.1 BLOCKER block | v3, 2026-07-27 | The four-element defect bar isolating `BFMCS.LimitFutureWitness`; the below-only asymmetry note that scopes Phase 7 |
| **reports/04_backward-transport-blocker.md** | **v4, 2026-07-27** | **The guard gap lemma `limitGuardBelow_of_priorS` (Reynolds' `γ⁻` / right gaps, printed p.175) and its full proof sketch; the closure-free `BFMCS.LimitGuardBelow` predicate; the chronicle discharge; the strengthened transport's four-case table; the death of both Phase 7.1 refutations; the correction of the handoff's bounded-witness residual (provable from `prior_S_gap`, not from `LimitFutureWitness`, and needed by no case); Burgess 1982 I's absent Dedekind variant (printed p.369) as the evidence that "mechanical" was unsupported; the new Postmortem Constraints; the `ChronicleRealExtension.lean` docstring defect; the report-03 Reynolds page-offset correction** |
| plans/03_strong-completeness-dedekind-v3.md — Phase 7.1 BLOCKER block + handoffs/phase-7.1-handoff-20260727165057.md | v4, 2026-07-27 | The two counterexample families (retained as findings); the exact structural cause (`exists_rat_witness_of_realLimitMCS` descends from the witness); the seven landed declarations now booked as preserved assets; the bounded-witness residual proposal that report 04 supersedes |
| **reports/05_forward-guard-r3-research.md** | **v5, 2026-07-27** | **The necessity theorem `r3_invariant_necessary` (proved sorry-free), which makes the forward decomposition *forced* rather than chosen; the sorry-free `boundedWitness_of_limitGuardBelow` (12 lines, from the landed `limitGuardBelow_of_priorS`) and with it the proof that Amendment 1's target clause was factually false; the elaborated statement and step-by-step proof plan for `limitGuardAbove_of_priorU` (Phase 7.3); `BFMCS.LimitGuardEventual` as the single residual content of forward coherence at ℝ (Phase 7.4); the **CHARTER GAP** — forward `snce` at an unselected target, required by `h_fuc`, landed nowhere, chartered in no v4 phase, and discharged by the same invariant more cheaply; the order-theoretic characterization of gap-accumulation proving `cantorIsoDense` is not a lever and R3's seam is `Chronicle/`; the refutation of the 6.2/6.3-mirror route for the forward guard (`prior_U_gap`'s antecedent IS the conclusion; `prior_S_gap` yields only necessity; `sep` is `K⁺`/`K⁻` only); the ultrafilter-**independent** candidate family `Q` and the honest statement that its realizability needs forbidden machinery; the verdict that **R3d has no source in the corpus**; and Amendments 1-4 with exact text** |
| **reports/05_forward-guard-r3-research.md §6 + §8.2 (re-integrated)** | **v6, 2026-07-27** | **The R3d decomposition sketch (§6, Phase 7.5) expanded into five agent-run-sized sub-phases 7.5-7.9; Amendments 2, 3 and 4 (§8.2) APPLIED verbatim under fresh explicit user authorization at the R3d gate, with `{DATE}` resolved to 2026-07-27; §5's ultrafilter-independent family `Q` promoted from a caveat to a two-outcome risk-register entry with an explicit falsification protocol; §1.5's no-source verdict converted into the binding ADAPTED-FROM docstring charter for every declaration 7.5-7.9 introduces; §4.3's construction inventory (`Chronicle.dom : Finset Rat`, `LimitDom` as the stage union, `ChronicleInvariant`'s fields, `witness_not_old`, the interval datum `g_sub_f_insert`) used as the territory map for the sub-phase split** |
| **summaries/05_phase-7-3-guard-gap-above-summary.md + summaries/05_phase-7-4-forward-transport-summary.md** | **v6, 2026-07-27** | **The landed 7.3/7.4 declarations, booked as preserved assets; and the LANDED signature of `BFMCS.toRealBundle_restricted_forward_until_since` — `(hfc) (B) (root) (h_rfuc) (hSf) (hSb) (h_lga) (h_lge)` — which supersedes v5's drafted binder list as ground truth for every downstream composition. `h_lga` is Phase 7.3's conclusion written out as a binder; there is no `BFMCS.LimitGuardAbove` predicate and none is to be created** |
| plans/04_strong-completeness-dedekind-v4.md — Phase 7.2 BLOCKER block + summaries/04_phase-7-2-forward-case-b-probe-summary.md | v5, 2026-07-27 | The probe outcome (ii): R2 **dead** on verbatim Reynolds evidence (Theorem 5's "We use expressive completeness here", printed pp.184-185; Doets' theorem by EF games, pp.185-188); Refutation 3 with its explicitly-unsettled realizability; the structural statement of why the guard is unreachable by the 6.2/6.3 route; the four landed sorry-free declarations now booked as preserved assets |

`reports/03_limit-future-witness-blocker.md` is the revision trigger for v3 and is Tier 1
literature-backed: its discharge is Reynolds' own argument (printed p.176) and its rejection of
the two-sided limit is Burgess's own text (printed pp.109-110). Cite both by PDF page in every
docstring; never by chunk-relative `md:NN` line numbers.

`reports/05_forward-guard-r3-research.md` is the revision trigger for v5 and is Tier 1
literature-backed to the same standard, with all quotations re-read verbatim from disk in that
dispatch: Burgess 1984's completion and gap lemma (printed pp.109-110), Burgess 1982 I's variants
table (printed p.369) and witness placement (printed pp.372-373), Reynolds' `γ⁺`/`γ⁻` definition
(printed p.175) and Theorem 3 (printed p.176), and Reynolds' expressive-completeness constructions
(printed pp.176-178). Its single most important literature finding is a **negative** one and is
recorded as such throughout this plan: **no source in the corpus obtains "the Until-guard is
eventually (not merely cofinally) true below the gap", by any means.** Phases 7.3/7.4 remain
faithful because their content is Reynolds' own Prior-U/Prior-S discipline applied to the
**guard**; Phase 7.5 is flagged as an **original construction** wherever it appears.

`reports/04_backward-transport-blocker.md` is the revision trigger for v4 and is Tier 1
literature-backed to the same standard: its lemma is Reynolds' `γ⁻` pattern (printed p.175) proved
by Reynolds' own Theorem 3 move (printed p.176); its evidence that the refuted step is not
mechanical is Burgess 1982 I's variants table (printed p.369) and Burgess 1984's appeal to `A7a`
(printed pp.109-110), both read directly from the PDFs. **Page-offset correction**: for Reynolds
1992 the mapping is PDF page `i` ↔ printed `164 + i` (report 03's parenthetical said `165 + i`).
All citations in this plan and in every landed docstring are by *printed* page and are unaffected.

### Preserved Assets

The following work is complete, verified generic, and must not regress. No phase rewrites,
generalizes, or "cleans up" any row in this table.

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| `deductionTheorem`, `deductionConverse`, `Derivable.deduction` | `Metalogic/Core/DeductionTheorem.lean:325,447,467` | [COMPLETED] `{fc : FrameClass}` implicit, unconstrained | 2026-07-27 |
| `neg_consistent_of_not_derivable` | `Metalogic/BXCanonical/Completeness.lean:72` | [COMPLETED] generic in `fc` | 2026-07-27 |
| `set_lindenbaum`, `SetMaximalConsistent.*`, `theorem_in_mcs` | `Metalogic/Core/MaximalConsistent.lean` (`theorem_in_mcs` at `:491`) | [COMPLETED] generic in `fc` | 2026-07-27 |
| `countermodel_dense_enriched` | `Metalogic/BXCanonical/Completeness.lean:133` | [COMPLETED] `{fc : FrameClass}`; threads `fc` at `:141`,`:157-159`. **Template, not a target** | 2026-07-27 |
| `Chronicle.cantorBfmcsDense` (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:511`), `box_stable_in_rooted_cantor_fmcs_dense` (`:528`), `cantor_bfmcs_dense_restricted_tc/_buc/_fuc` (`:629`,`:680`,`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | [COMPLETED] `(fc : FrameClass)` explicit, carrier `Rat`, all three coherence lemmas fully polymorphic in `root`. `_tc` alone carries an extra closure-containment hypothesis. **Stays at `Rat`** | 2026-07-27 |
| `fully_restricted_parametric_completeness_from_neg_membership` | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417`, vars at `:45` | [COMPLETED] binders `{fc} {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Rat`. **Accepts `D := ℝ` unchanged** | 2026-07-27 |
| `ParametricCanonicalTaskFrame` / `ParametricCanonicalTaskModel` / `parametricToHistory` / `ShiftClosedParametricCanonicalOmega` | `Metalogic/Algebraic/ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean:240,379` | [COMPLETED] generic in `D` and `fc` | 2026-07-27 |
| `BFMCS` / `FMCS` structures | `Metalogic/Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103` | [COMPLETED] carrier binder is only `[Preorder D]` | 2026-07-27 |
| The six coherence predicates | `Metalogic/Bundle/TemporalCoherence.lean:277,308,489,526,541,558,589` | [COMPLETED] generic in `D` | 2026-07-27 |
| `temporalFutureDerived` (`□φ → G(□φ)`) | `Theorems/Combinators.lean:654` | [COMPLETED] `{fc : FrameClass}` implicit, derived from `modal_future` + `modal_t` + `modal_4`. **Newly load-bearing in v2 (Phase 6.1)** | 2026-07-27 |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1910` | [COMPLETED] already strong-form: takes `(Γ : Context)` and `h_ctx : ∀ ψ ∈ Γ, TruthAt …` | 2026-07-27 |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] carries the lub property as an explicit `Prop` hypothesis at `:258` | 2026-07-27 |
| `Axiom.prior_U_gap` / `prior_S_gap` / `sep` and their validity | `ProofSystem/Axioms.lean:377,387,398`; `Metalogic/Soundness.lean` | [COMPLETED] | 2026-07-27 |
| `kplusFormula` | `Metalogic/WeakCanonical/Kamp/PriorINF.lean:93` | [COMPLETED] purely syntactic `Formula`-level "holds arbitrarily soon after". **The only reusable item from the Kamp INF files** | 2026-07-27 |
| `dedekind_box_dense_mem`, `real_lub_of_bddAbove`, the `CarrierProbe` examples | `Metalogic/BXCanonical/CompletenessDedekind.lean` | [COMPLETED] landed by Phase 1 of this plan | 2026-07-27 |
| `SemanticConsequenceDedekindDense`, `truthAt_foldr_imp`, `semantic_deduction_dedekind_dense`, `derivable_foldr_imp_iff`, `consequence_completeness_dedekind_of_engine`, `soundness_dedekind_consequence`, `completeness_dedekind_of_engine` | `Metalogic/StrongCompleteness.lean` | [COMPLETED] landed by Phase 2 of this plan, commit `bd9ae0ac1`; renamed (not restructured) by the concurrent terminology reframing. **The `consequence_completeness_dedekind_of_engine` signature is pinned and may not be restated** | 2026-07-27 |
| `limitSetBelow`, `limitSetAbove`, `limitSetBelow/Above_mono_directed`, `limitSetBelow/Above_finite_subset_mem`, `limitSetBelow/Above_consistent`, `limitSetBelow/Above_of_rat` | `Metalogic/Bundle/LimitMCS.lean` (10 declarations) | [COMPLETED] landed by Phase 3 of this plan, sorry-free | 2026-07-27 |
| `limitMCSBelow`, `limitMCSBelow_is_mcs`, `limitSetBelow_subset_limitMCSBelow`, `limitMCSLindenbaum*`, `fc_theorem_true_in_parametric_model`, and above all **`limitMCSBelow_cofinal_below`** — `(hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) : ∃ q : Rat, z < (q:ℝ) ∧ (q:ℝ) < r ∧ A ∈ m q`, the descent handle every unselected-source case consumes and the reason the ultrafilter limit was chosen over bare Lindenbaum | `Metalogic/Bundle/LimitMCS.lean` (+14 declarations) | [COMPLETED] landed by Phase 4 of this plan, sorry-free. **Load-bearing in Phase 6.2 Step A** | 2026-07-27 |
| The six `limitSetBelow`-source case lemmas plus the four `limitMCSBelow`-source variants | `Metalogic/Bundle/LimitMCSCoherence.lean` (11 declarations) | [COMPLETED] landed by Phases 5-6, sorry-free | 2026-07-27 |
| `realLimitMCS`, `realLimitMCS_of_rat`, `realLimitMCS_of_not_rat`, `realLimitMCS_is_mcs`, `realLimitMCS_forward_G/backward_H`, `FMCS.toRealShift`, `FMCS.toReal`, `FMCS.toReal_at_rat` | `Metalogic/Bundle/RealExtension.lean` (9 declarations) | [COMPLETED] landed by Phase 6, sorry-free | 2026-07-27 |
| `negBoxIntrospection`, `box_forward_in_fmcs`, `box_stable_in_fmcs`, `mem_realLimitMCS_of_forall`, `box_mem_realLimitMCS_iff`, `BFMCS.toRealBundle` (both modal fields), `BFMCS.toRealBundle_restricted_temporally_coherent` (conditional on `LimitFutureWitness`; the `somePast` half unconditional) | `Metalogic/Bundle/RealExtensionBundle.lean` (334 lines, 7 declarations) | [COMPLETED] landed by Phase 6.1, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`. **Phase 6.2 edits exactly two lines in this file** (the `LimitFutureWitness` binder list and the one call site at `:306`) and nothing else | 2026-07-27 |
| **`limitFutureWitness_of_priorU`** — `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m) (hm) (hUf) (hUb) (r : ℝ) (hr : ¬ ∃ q : Rat, (q:ℝ) = r) (φ) (hF : Formula.someFuture φ ∈ limitMCSBelow m r) : ∃ s : Rat, r < (s:ℝ) ∧ φ ∈ m s` — **and** `cantor_bfmcs_dense_limit_future_witness` (`:203`) | `BXCanonical/Chronicle/ChronicleLimitGapWitness.lean` (209 lines, 2 declarations; general lemma at `~:85`, Prior-U consumption at `:151`) | [COMPLETED] landed by Phase 6.2, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`. **The structural template for Phase 6.3** — clone it with `.1 → .2`, `untl → snce`, `prior_U_gap → prior_S_gap`, `kPlus → kMinus`. Do not edit it | 2026-07-27 |
| **`guard_transport_realLimitMCS`** (`:153`), **`exists_rat_witness_of_realLimitMCS`** (`:183`), `toRealBundle_forward_until_selected`, `toRealBundle_forward_since_selected`, **`toRealBundle_backward_until_selected`** (`:270`), **`toRealBundle_backward_since_selected_of_rat_witness`** (`:304`), `cantor_bfmcs_dense_real_restricted_tc` | `BXCanonical/Chronicle/ChronicleRealExtension.lean` (~300 lines, 7 declarations; bundle lemmas in `namespace …Metalogic.Bundle`, chronicle instance in `…BXCanonical.Chronicle`) | [COMPLETED] landed by the Phase 7.1 dispatch, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`, full `lake build` green. **These are assets, not casualties of the refutation** — Phase 7.1′ *consumes* all seven and rewrites none. The module's only permitted edit in 7.1′ is the docstring correction named in its task list, plus the new declarations appended | 2026-07-27 |
| `Axiom.prior_S_gap` — `Axiom ((Formula.and (Formula.snce Formula.top φ) φ.neg.somePast).imp (Formula.snce (Formula.or φ.neg (Formula.kMinus φ.neg)) φ))`, with `minFrameClass = .Dedekind`; `prior_S_gap_valid`; `Formula.kMinus (φ) := (Formula.snce Formula.top φ.neg).neg` | `ProofSystem/Axioms.lean:387` (`minFrameClass` block at `:524`); `Metalogic/Soundness.lean:1531`; `Syntax/Formula.lean:193` (`somePast` at `:141`, `Formula.or a b = a.neg.imp b` at `:438`) | [COMPLETED] present and already proved sound; **consumed nowhere on the completeness route** (grep over `Bundle/` and `BXCanonical/` returns zero hits). Phase 6.3 is its first consumer, which adds **no** soundness obligation | 2026-07-27 |
| **`limitGuardBelow_of_priorS`** — `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m) (hm) (hSf) (hSb) (r : ℝ) (hr : ¬∃ q, (q:ℝ)=r) (ψ) (c : Rat) (hc : r < (c:ℝ)) (hguard : ∀ q:Rat, r<(q:ℝ) → (q:ℝ)<(c:ℝ) → ψ ∈ m q) : ψ ∈ limitSetBelow m r` — **and** `cantor_bfmcs_dense_limit_guard_below`; **and** `BFMCS.LimitGuardBelow` (closure-free, no `root` argument) | `BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean` (207 lines, 2 declarations; general lemma at `:105`), predicate appended in `Bundle/RealExtensionBundle.lean` | [COMPLETED] landed by Phase 6.3, sorry-free on the first build, axioms exactly `[propext, Classical.choice, Quot.sound]`. **The structural template for Phase 7.3** — mirror it with `.2 → .1`, `snce → untl`, `prior_S_gap → prior_U_gap`, `kMinus → kPlus`, all inequalities reversed. **Do not edit it.** Report 05 §3 makes it the *converse* consumer as well: it is what converts forward case B's own conclusion into its R3 hypothesis | 2026-07-27 |
| **`BFMCS.toRealBundle_restricted_backward_until_since`** (at the `LimitGuardBelow`-strengthened signature), `toRealBundle_backward_until_unselected` (case 2), `exists_rat_since_witness_below_of_limitGuardBelow` (the relocation lemma shared by cases 3′ and 4), `toRealBundle_backward_since_selected_of_gap_witness`, `toRealBundle_backward_since_unselected`, **`cantor_bfmcs_dense_real_restricted_buc`** | `BXCanonical/Chronicle/ChronicleRealExtension.lean` (6 declarations appended) | [COMPLETED] landed by Phase 7.1′, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`, full `lake build` green. **The entire backward side of `h_buc` is closed.** Phases 7.3-7.5 consume these and rewrite none. One mechanical deviation recorded: the module gained an `import …Chronicle.ChronicleLimitGuardWitness` line (import sets disjoint, no cycle) | 2026-07-27 |
| **`forward_until_witness_of_straddling_rat`**, **`toRealBundle_forward_until_unselected_dichotomy`** (`:732`), **`limitSetBelow_someFuture_of_cofinal`**, **`forward_until_unselected_eventuality_of_priorU`** (`:876`) | `BXCanonical/Chronicle/ChronicleRealExtension.lean` (4 declarations appended) | [COMPLETED] landed by the Phase 7.2 probe, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`. **These are assets, not casualties of outcome (ii).** Forward case A is *closed* by the first two. The dichotomy's **right disjunct is literally the `hcof` hypothesis** of `boundedWitness_of_limitGuardBelow`, so Phase 7.4 gets it free. `limitSetBelow_someFuture_of_cofinal` is the conversion that makes `F φ`'s truth region below a gap an interval even when `φ`'s is not. Phase 7.4 *consumes* all four and rewrites none | 2026-07-27 |
| **`limitGuardAbove_of_priorU`** — `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m) (hm) (hUf) (hUb) (r : ℝ) (hr : ¬∃ q, (q:ℝ)=r) (ψ) (hev : ψ ∈ limitSetBelow m r) : ∃ c : Rat, r < (c:ℝ) ∧ ∀ q : Rat, r < (q:ℝ) → (q:ℝ) < (c:ℝ) → ψ ∈ m q` — **and** `cantor_bfmcs_dense_limit_guard_above` | `BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean` (new module, 2 declarations) | [COMPLETED] landed by Phase 7.3, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`. The Prior-U mirror of `limitGuardBelow_of_priorS`; unselectedness used exactly once. **Do not edit it.** Phases 7.5-7.9 *consume* the chronicle discharge and rewrite neither declaration; in particular no `BFMCS.LimitGuardAbove` predicate exists and none is to be created — 7.4's composition takes this lemma's conclusion as the written-out binder `h_lga` | 2026-07-27 |
| **`BFMCS.LimitGuardEventual`** — `{fc} (B : BFMCS (fc := fc) Rat) : Prop := ∀ fam ∈ B.families, ∀ r : ℝ, (¬∃ q, (q:ℝ)=r) → ∀ φ ψ, (Formula.untl φ ψ ∈ limitMCSBelow fam.mcs r ∨ Formula.snce φ ψ ∈ limitMCSBelow fam.mcs r) → ψ ∈ limitSetBelow fam.mcs r` — closure-free, no `root` argument | `Bundle/RealExtensionBundle.lean` (+44 lines, appended beside `LimitFutureWitness` and `LimitGuardBelow`) | [COMPLETED] landed by Phase 7.4, sorry-free. **The sole undischarged residual of the whole route, and the exact target of Phases 7.5-7.9.** Its *statement* is frozen: 7.5-7.9 discharge it, they do not restate, weaken, or re-shape it, and no closure hypothesis or `root` argument may be added | 2026-07-27 |
| **`boundedWitness_of_limitGuardBelow`**, **`toRealBundle_forward_until_unselected`**, **`toRealBundle_forward_since_unselected`** (v4's charter gap, closed), **`BFMCS.toRealBundle_restricted_forward_until_since`** at its **LANDED** signature `(hfc) (B) (root) (h_rfuc) (hSf) (hSb) (h_lga) (h_lge)` — `h_rbuc` and `h_lgb` **dropped** as unused; `hfc`/`hSf`/`hSb`/`h_lga` **added** (see the Phase 7.4 DEVIATION block) | `BXCanonical/Chronicle/ChronicleRealExtension.lean` (+~230 lines appended, 4 declarations) | [COMPLETED] landed by Phase 7.4 in one run, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`, full `lake build` green (1903 jobs). **The LANDED binder list is ground truth — the v5 draft is not.** Every added binder is discharged at a chronicle call site from assets that already exist (`h_lga` by `cantor_bfmcs_dense_limit_guard_above`; `hSf`/`hSb` by the self-root instantiation of `_fuc`/`_buc`), so the route gained no obligation. Phases 7.5-7.9 *consume* all four and rewrite none | 2026-07-27 |
| `self_mem_subformulaClosure (phi : Formula) : phi ∈ subformulaClosure phi` | `Syntax/SubformulaClosure/Closure.lean:42` | [COMPLETED] generic | 2026-07-27 |
| `conj_mcs`, `theorem_in_mcs`, `DerivationTree.axiom` (whose `h_fc : h.minFrameClass ≤ fc` field is what `hfc` discharges) | `Chronicle/PointInsertion.lean:227`; `Core/MaximalConsistent.lean:491`; `ProofSystem/Derivation.lean:98` | [COMPLETED] generic in `fc` | 2026-07-27 |

**Closure discovery (v3, load-bearing).** `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc`
bind the restricted predicates' closure-membership argument to `_` and never use it
(`ChronicleToCountermodelBasic.lean:642`, `:691`, `:766`), because `limit_F_resolution`
(`ChronicleConstruction.lean:722`), `limit_satisfies_c4` (`:776`) and `limit_satisfies_c5_strong`
(`:1482`) take their formula arguments unconstrained. The Cantor dense chronicle therefore
satisfies **unrestricted** Until/Since coherence for every formula, recoverable by instantiating
at a self-root and discharging the side condition with `self_mem_subformulaClosure`. This is an
observation *about* preserved assets, not a licence to edit them: the three theorems and their
three underlying resolution lemmas stay byte-identical.

**Explicitly NOT touched by any phase of this plan** (regressing or "generalizing" any of these
is a defect, not progress):

- `Metalogic/WeakCanonical/IntegerModel/**` — the ℤ engine (`good`, `VeryGood`, `ContempEquiv`,
  `subinterval_finite_of_succ_archimedean`, `countermodel_discrete_reynolds_v2`).
- `Metalogic/WeakCanonical/Transfer.lean:1242` — the live discrete-branch sorry. It is on the
  Base/Discrete axis and is not on this route. Do not attempt it.
- `Metalogic/WeakCanonical/EFGames/**`, `Kamp/**`, `MonadicFO.lean` — the monadic-FO / EF-game
  stack. Route B needs none of it.
- `FormalSystem/Boneyard/**`.
- `completeness_dense`, `completeness_discrete` and their proofs. They are read as templates and
  left byte-identical.

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

Cite by **PDF page** in all Lean docstrings. Never cite chunk-relative `md:NN` line numbers.

| Source | Location | Lean identifier | Statement used | Phase |
|---|---|---|---|---|
| Reynolds 1992 | §5, printed p.176 (chunk `reynolds_1992_sec06`, pp.174-179) | `limitMCS_negation_complete` | "Call a linear temporal structure a *Prior structure* if it satisfies all substitution instances of Prior-U and Prior-S. It is easy to see that then there are no definable gaps." | 4 (**refuted at the `φ` level** — see the Phase 4 OUTCOME block) |
| Reynolds 1992 | §5, printed p.176 (same chunk) | `kplusFormula` (reused) | `γ⁺(A)` "holds exactly when `A` remains true for a while after now but only up until a gap after which `A` is arbitrarily soon false" — the definable-gap pattern | 4 |
| **Reynolds 1992** | **Thm 3 proof, printed p.176** | **`limitFutureWitness_of_priorU`** | **"Suppose for contradiction that `M ⊨ U'(A,B)(t)` in some Prior structure `M`. Thus `B` holds for a while up until a gap after which `¬B` is true arbitrarily soon. By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."** Instantiated at `B := χ = Fφ`, whose truth region below the gap is the interval `(-∞, sup S_φ)`, so the antecedent `U(⊤, χ)` is free — the exact step v2's Phase 4 could not take at the `φ` level | **6.2** |
| **Reynolds 1992** | **Prior-U axiom, printed p.168** | **`Axiom.prior_U_gap`** | `U(⊤, φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)`. PRESENT at `Axioms.lean:377`, `minFrameClass = .Dedekind` at `:524` | **6.2 (consumed), 8 (threaded as `hfc`)** |
| **Reynolds 1992** | **`K⁺A = ¬U(⊤,¬A)`, printed p.168** | **`Formula.kPlus`** | `def kPlus (φ) : Formula := (Formula.untl Formula.top φ.neg).neg`, `Syntax/Formula.lean:180`; `Formula.or a b = a.neg.imp b` at `:438` | **6.2 (Step D)** |
| **Reynolds 1992** | **Lemma 3 proof, printed p.178** | *(pattern for Steps C-D)* | "Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of `¬R`" | **6.2** |
| **Reynolds 1992** | **§6 opening, printed p.176** | *(scoping note only)* | "We know that the Prior axioms ensure that there will not be any definable gaps in a model. To show that our model can be made into a model over the reals we actually need a stronger result." Records why gap-freeness alone does **not** settle Phase 7.2, and why Reynolds' own route to ℝ (Doets + `Axiom.sep`, printed pp.177-178, 184-188) is a *different* route from this plan's completion route | **7.2 (scoping), 7.2 fallback R2** |
| **Burgess 1984** | **§2.7 Continuity, printed pp.109-110** | **`BFMCS.LimitFutureWitness`** | "Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`. For if not, then `G¬a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma, `G¬a ∈ T(y)` for some `y ∈ Y`" — the predicate is *literally* Burgess's prophecy-at-a-gap claim, and his proof routes through the continuity axiom `A7a`. This is why the obligation cannot be dissolved by a construction change | **6.1 (statement), 6.2 (discharge)** |
| **Burgess 1984** | **§2.7, printed p.109** | *(rejected alternative)* | `C(Y,Z) = {Pa : ∃y ∈ Y, a ∈ T(y)} ∪ {Fa : ∃z ∈ Z, a ∈ T(z)}` — the two-sided seed at a gap. Burgess adopts it and **still** needs the continuity axiom for the step above, so it removes no obligation. Grounds the Postmortem Constraint against a two-sided limit | **(constraint)** |
| **Reynolds 1992** | **`γ⁻` / right gaps, printed p.175** | **`limitGuardBelow_of_priorS`** | **"Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds exactly when `A` remains true for a while after now but only up until a gap after which `A` is arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` **left gap** and more generally a **definable gap**. Dually there is `γ⁻` and **right gaps**."** The lemma's conclusion is exactly "no `ψ`-right gap at `r`" | **6.3** |
| **Reynolds 1992** | **Thm 3 proof, printed p.176; Lemma 3, printed p.178** | **`limitGuardBelow_of_priorS` (proof shape)** | **"By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction"; "Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of `¬R`". All seven Prior-U/Prior-S appeals in §6 apply the axiom to *the formula uninterruptedly true on an interval ending at the gap*, never to a witness. Here that formula is the guard `ψ`, and the transport's hypothesis supplies the interval, so `S(⊤,ψ)` is free** | **6.3** |
| **Reynolds 1992** | **Prior-S axiom, printed p.168** | **`Axiom.prior_S_gap`, `Formula.kMinus`** | `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)`; `K⁻A = ¬S(⊤,¬A)`. PRESENT at `Axioms.lean:387` / `Formula.lean:193`, sound at `Soundness.lean:1531`, `minFrameClass = .Dedekind` | **6.3 (consumed), 7.1′ (via the discharge), 8 (threaded as `hfc`)** |
| **Reynolds 1992** | **§6 Lemma 2, printed p.177** | *(scoping caveat only)* | **"Now by the expressive completeness of `U` and `S` there is temporal `R` …" — Reynolds obtains his `R` this way, which the Postmortem Constraints forbid building. Phase 6.3 does NOT inherit that dependency: its `ψ` is *given by the hypothesis*, a binder, not a constructed formula. Only the Prior-S appeal is copied, never the machinery around it** | **6.3 (constraint check)** |
| **Burgess 1982 I** | **Variants table, printed p.369** | *(evidence, no identifier)* | **The table lists Density, Discreteness, First Element, Last Element, No First Element, No Last Element — and the paper ends at printed p.374 with no Continuity / Dedekind row. Burgess's `U`/`S` completeness proof never leaves the rationals ("the order being the usual order on the rationals", printed p.373) and every witness placement is strictly between existing rational points (`z = x + y/2`, `y = x + 1`, `z = x + x'/2`; printed pp.372-373). **No witness is ever placed at a gap.** This is the single strongest evidence that v3's "mechanical" classification of the backward transport was unsupported** | **(constraint, 7.1′ scoping)** |
| **Burgess 1982 I** | **C1 / C3 / C5a / C4a, printed p.372; 2.11, printed p.373** | `RestrictedForward/BackwardUntilSinceCoherent` (existing) | **Burgess's Until-guard is an *interval datum* `g(x,y)`, with `C3: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`; the pointwise reading is a *consequence* (2.11: "by C3 we have `g(x,y) ⊆ f(z)`"), not the definition. The tree's predicates are the pointwise forms — faithful to what the truth lemma consumes, but the interval datum that carries guard information across the *addition of new points* has been discarded. That is the structural root of both Phase 7.1 refutations. `C4a` is the tree's backward coherence, contraposed** | **(diagnosis; 7.1′ docstring)** |
| **Burgess 1984** | **§2.7, printed pp.109-110** | *(rejected alternative — the bounded witness)* | **Burgess places the gap witness in `Z`, the far side, with *no bound whatsoever*, licensed by the continuity axiom `A7a` routed through his prophecy Lemma. His obligation has no guard because `F`/`G` has none, so **no bounded witness ever arises in his proof**. The handoff's bounded residual is provable — from `prior_S_gap` at `χ := φ.neg` via Phase 6.3's lemma — but **not** from `LimitFutureWitness` (a Prior-**U** statement whose `by_contra` hypothesis is unbounded by construction) and **not needed by any case**. Grounds the v4 Postmortem Constraint against the bounded-witness detour** | **(constraint)** |
| **Reynolds 1992** | **Thm 3, printed p.176** ("`B` holds for a while up until a gap … By Prior-U applied to `B` … `U(¬B ∨ K⁺(¬B), B)(t)`") | **`limitGuardAbove_of_priorU`** | `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m) (hm) (hUf) (hUb) (r : ℝ) (hr : ¬∃ q, (q:ℝ)=r) (ψ) (hev : ψ ∈ limitSetBelow m r) : ∃ c : Rat, r < (c:ℝ) ∧ ∀ q : Rat, r < (q:ℝ) → (q:ℝ) < (c:ℝ) → ψ ∈ m q`. **Statement verified to elaborate** against the tree in the report-05 dispatch. Exact Prior-U mirror of the landed Prior-S lemma (below → above instead of above → below). **Faithful**: the axiom is applied to the **guard** `ψ` — the formula uninterruptedly true on an interval abutting the gap — which is Reynolds' own uniform discipline | **7.3** |
| **Burgess 1984** | **§2.7, printed pp.109-110** (the far-side witness, unbounded, licensed by `A7a`) | **`boundedWitness_of_limitGuardBelow`** | `… (r : ℝ) (hr) (φ) (hcof : ∀ z:ℝ, z<r → ∃ w:Rat, z<(w:ℝ) ∧ (w:ℝ)<r ∧ φ ∈ m w) (c : Rat) (hc : r<(c:ℝ)) : ∃ w : Rat, r<(w:ℝ) ∧ (w:ℝ)<(c:ℝ) ∧ φ ∈ m w`. **PROVED sorry-free** in the report-05 dispatch, 12 lines, from the landed `limitGuardBelow_of_priorS`. Burgess needs no bound because `F`/`G` has no guard; here the bound is what makes the guard interval finite. **Transcribe, do not re-derive** | **7.4** |
| **Reynolds 1992** | **`γ⁺` / left gaps, printed p.175** ("`A` remains true for a while after now but only up until a gap") | **`BFMCS.LimitGuardEventual`** | `{fc} (B : BFMCS (fc := fc) Rat) : Prop := ∀ fam ∈ B.families, ∀ r : ℝ, (¬∃ q, (q:ℝ)=r) → ∀ φ ψ, (Formula.untl φ ψ ∈ limitMCSBelow fam.mcs r ∨ Formula.snce φ ψ ∈ limitMCSBelow fam.mcs r) → ψ ∈ limitSetBelow fam.mcs r`. Statement shape verified to elaborate. **This is the entire residual content of forward coherence at ℝ**, both halves, and report 05 §3 proves it necessary as well as sufficient | **7.4 (statement + conditional use), 7.5 (discharge)** |
| **Burgess 1982 I** | **§2.10, printed pp.372-373** (`y = x+1`; `z = (x+x')/2`; "add a single point `y` lying after `x`") | `c5_forward_walk`, `C5ForwardWalkResult.witness_not_old` | `CounterexampleElimination.lean:~660-707, 2243`. **LANDED and faithful** — the tree transcribes Burgess's placement exactly and contains **no** accumulation bookkeeping. That bookkeeping is what Phase 7.5 would have to add, and it has **no source** | **(evidence; 7.5 scoping)** |
| **Burgess 1982 I** | **Variants table, printed p.369** | *(evidence, no identifier)* | Density / Discreteness / First / Last / No First / No Last — **no Continuity / Dedekind row**, and the "routine exercise" remark is scoped to those six. Grounds the verdict that R3d is unsourced | **(evidence; 7.5 gating)** |
| **Reynolds 1992** | **§6, printed pp.176-178** ("`B` exists by expressive completeness"; "Using expressive completeness and `ε`, find `B`") | *(constraint check — nothing built)* | **FORBIDDEN.** Any R3d proof that reaches for a formula defining a gap boundary re-enters this dependency and is dead on the same clause that killed R2 | **(constraint; 7.5-7.9)** |
| **NO SOURCE — original work** | — | **`NoGuardAccumulation`** (7.5, name at implementer's discretion) and its payoff lemma; the preservation fields on `C5ForwardWalkResult` / `C5BackwardWalkResult` / `EliminationResult`; the widened `omegaChain` subtype component; the limit transport; **`Chronicle.cantor_bfmcs_dense_limit_guard_eventual`** | **No source in the corpus performs this step, by any means** (report 05 §1.5, all three primary sources re-read verbatim). Every docstring on every one of these declarations must **state that fact** and must cite neighbouring disciplines only as **ADAPTED-FROM** with printed pages. See the "Honesty charter for R3d docstrings" in the Postmortem Constraints | **7.5, 7.6, 7.7, 7.8, 7.9** |
| **Burgess 1982 I** | **§2.10, printed pp.372-373** — *"add a single point `y` lying after `x`"*; *"Set `y = x + 1`"*; *"Set `z = (x + x')/2`"* | **ADAPTED-FROM** anchor for the walk placement constraints (7.6, 7.7) | **ADAPTED-FROM, never transcription.** The tree already transcribes Burgess's placement verbatim (`witness_not_old`, `CounterexampleElimination.lean:678`/`:1282`). What R3d adds — a constraint on where those placements may **accumulate** — is original: Burgess needs no such bookkeeping because he never reaches a gap, and his variants table (printed p.369) has **no Continuity row**. A docstring citing him without the ADAPTED-FROM qualifier is a defect | **7.6, 7.7** |
| **Burgess 1984** | **§2.7, printed pp.109-110** — the completion `(X*,R*)`, the gap point `w(Y,Z)`, *"some MCS extending `C(Y,Z)`"*, the A7a-licensed far-side witness | **ADAPTED-FROM** anchor for the limit transport and the gap discharge (7.9) | **ADAPTED-FROM, never transcription.** His completion runs in `F`/`G`, which has **no guard**, and his one "above ⟹ below" conversion comes from **axiom A7a**, not from any property of the chronicle — he selects nothing and his chronicle is arbitrary. The obligation 7.9 discharges **does not arise in his setting at all**. A docstring implying otherwise is wrong on the record | **7.9** |
| **Reynolds 1992** | **`γ⁺` / left gaps, printed p.175** | `BFMCS.LimitGuardEventual` (**statement only**) | **Accurate for the STATEMENT being discharged, and already landed on the predicate's docstring. NEVER cite it for the DISCHARGE**: Reynolds obtains every gap-facing formula by expressive completeness (printed pp.176-178), which is forbidden and already fatal to R2 | **7.5-7.9 (statement citation only)** |
| Reynolds 1992 | §1, printed p.169 (chunk `reynolds_1992_sec01`, pp.165-172) | docstring of `CompletenessDedekind.lean` | "The Prior axioms enforce a *definably* Dedekind complete model … there may be gaps in the order but … you wouldn't know that just looking at the behaviour of temporal formulas." Scopes what Phase 4 may claim: definable gap-freeness only | 4 |
| Reynolds 1992 | Prior-U / Prior-S / Sep, printed p.168 | `Axiom.prior_U_gap`, `prior_S_gap`, `sep` | PRESENT in the tree at `Axioms.lean:377,387,398` | 4 (consumed) |
| Goldblatt 2023 (arXiv:2310.20069) | Introduction (chunk `goldblatt_2023_strong-completeness-real-time`, `chunk_0002.md`) | docstring of `StrongCompleteness.lean` | "if the flow of time is modelled by the linearly ordered set (R, <) … the resulting temporal logic of valid **propositional** formulas is recursively axiomatisable. This was shown by Robert Bull, using finitely many axioms and inference rules. The situation of first-order temporal logic is quite different." **Resolves the audit's highest-ranked gap in favour of this plan**: Scott's non-axiomatizability obstruction is first-order-specific and does not bear on propositional TM. `[UNVERIFIED — provenance_fidelity: unverified_conversion]`; re-read against the PDF before quoting in a deliverable | 2 |
| Reynolds 1992 | Thm 7, §9, printed p.189 (chunk `reynolds_1992_sec07`) | — | "US/R is sound and **weakly** complete … over structures with real flow." Recorded only to state why it is NOT the terminus | 2 (docstring) |
| Burgess 1984 | §2, pp.108-115 (chunk `burgess_1984_sec05`) | — | Completeness for Dedekind-complete time via a completion construction. **Cross-check only.** Consult if Phase 4 stalls; do not restructure the route around it without a new research dispatch | 4 (contingency) |

---

## Postmortem Constraints

Binding on every implementation dispatch for this task. Derived from the adversarial
verification section of report 01, the literature audit, a direct inventory performed during
planning, and (new in v2) the Phase 3 dispatch's counterexample.

**Do NOT**:

- **Do NOT build any part of the Reynolds transfer route.** No monadic-FO translation layer, no
  Stavi connectives `U'`/`S'`, no expressive-completeness theorem, no EF games, no shuffles, no
  `≡_k`, no order-characterization of `ℝ`. Reynolds' Theorems 4 and 5 invoke expressive
  completeness of `{U,S}` at seven verbatim sites, which reduces to Kamp/Stavi — a result
  Reynolds cites without proof and which is absent from this tree and from Mathlib.
- **Do NOT route the limit-MCS work through `Kamp/PriorINF.lean` or `Kamp/DedekindINF.lean`.**
  Report 01's Limitation 4 flagged these as a *lead*; the lead was checked during planning and
  is **refuted**. Every declaration there is parameterized by `{sig : MonadicSignature}` and
  `(M : OrderedMonadicStructure sig)`: truth at a point is `M.interp (atomMap P) t`, not
  membership in a `Set Formula`. `HasDedekindINF` is a TL-*definability* hypothesis about a
  point that already exists in the carrier — it constructs nothing, and discharging it would
  itself require the limit construction. Neither file mentions `Rat`, `Real`, `sSup`/`sInf`,
  `ConditionallyCompleteLinearOrder`, or `SetMaximalConsistent`. The **one** reusable item is
  `kplusFormula` (`PriorINF.lean:93`), a purely syntactic `Formula`. Note also that no
  `kplus ↔ TemporalTruth (kplusFormula P)` correspondence lemma is proved anywhere — the
  MCS-side analogue must be proved from scratch.
- **Do NOT build the phase-5 gap-freeness bridge** (`IsEmpty (Gap D)` ⟺ conditionally
  complete). `ValidDedekindDense` already carries the lub property as an explicit `Prop`
  hypothesis (`Validity.lean:258`), so there is nothing to bridge *to*. `structure Gap`
  (`EFGames/Defs.lean:248`) belongs to the rejected ℤ/EF route. Route B's notion is *definable*
  gap-freeness, a consequence of Prior-U, not an order-theoretic side condition.
- **Do NOT attempt to lift the Cantor back-and-forth chronicle layer to `ℝ`.** Cantor's theorem
  requires a *countable* dense order without endpoints. `cantorBfmcsDense` stays at `Rat`.
  Only the `D`-generic layer beneath it moves. Any edit to `cantorIsoDense`, `cantorZeroDense`,
  or `CantorFDense` is out of scope and is the wrong seam.
- **Do NOT build a Base-MCS → Dedekind-MCS transfer lemma.** Route B produces a Dedekind-MCS at
  step 1 via `set_lindenbaum (fc := FrameClass.Dedekind)` and feeds it to an `fc`-generic
  construction. No transfer occurs, so no transfer lemma is needed. The trap documented at
  `Completeness.lean:182-193` does not arise on this route.
- **Do NOT use `countermodel_discrete_reynolds_v2` as a template.** It hard-codes
  `fc := FrameClass.Discrete` and emits `SuccOrder`/`PredOrder`/`IsSuccArchimedean` in its
  existential (`IntegerModel/ReynoldsBridge.lean:739`). The correct template is
  `countermodel_dense_enriched`, which is `fc`-generic.
- **Do NOT build a `Γ`-relative analogue of `neg_consistent_of_not_derivable`, and do NOT build
  a "root covering `Γ ∪ {φ}`".** A planning-time inventory confirmed that
  `neg_consistent_of_not_derivable` (`Completeness.lean:72`) is hard-coded to the singleton
  `{Formula.neg φ}` and that its proof case-splits on `L = []` vs `L = [¬φ]`, so it does not
  generalize mechanically; and that a direct `Γ`-countermodel would additionally need a `root`
  whose `subformulaClosure` covers all of `Γ ∪ {φ}` plus a per-formula `h_sub`. **Both are
  artifacts of a route this plan does not take.** Route B reaches `Γ` through the deduction
  theorem — `Γ ⊨ φ ↔ ⊨ (Γ.foldr imp φ)`, then the *single-formula* engine, then iterated
  `deductionConverse` — so the engine only ever sees one formula and `root := ψ` with
  `self_mem_subformulaClosure ψ` suffices exactly as in `countermodel_dense_enriched`. If an
  implementer finds themselves generalizing Lindenbaum or widening `root`, they have left the
  plan; stop and escalate.
- **Do NOT prove `completeness_dedekind` independently and then strengthen it.**
  `completeness_dedekind` is `consequence_completeness_dedekind []` after `simp` discharges
  `∀ ψ ∈ [], _`. Proving it separately duplicates the engine and re-introduces the weak
  terminus this task exists to eliminate.
- **Do NOT weaken the target to `ValidDedekind`.** `FrameClass.Dedekind` sits above
  `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a `.Dedekind`
  derivation and both are false on `ℤ`, which is Dedekind-complete. The target is
  `ValidDedekindDense` and the completeness converse must match it.
- **Do NOT emit a vacuous definition** (`def X := True`, `theorem X := trivial`, etc.) at any
  point. See `.claude/rules/lean4.md`. If a phase cannot be completed, mark it `[BLOCKED]`.
- **Do NOT cite task numbers in any `.lean` file.** Cite the sibling module name, the source's
  printed PDF page, or the declaration name instead.
- **(v2) Do NOT reintroduce any claim that the one-sided limit agrees with `m q` at a rational
  `q`.** It is false in both directions; the counterexample is recorded in
  `Bundle/LimitMCS.lean`'s module docstring and in the Revision Rationale above. Agreement at
  rational points is obtained *by construction* in Phase 6 (rational selection), never by a
  lemma about `limitSetBelow`.
- **(v2) Do NOT define the real bundle's family set as the image of the rational bundle's
  families under a single extension.** `modal_backward` is then unprovable at unselected reals.
  The family set must be closed under **real** shifts. See Phase 6.1 and the corresponding Risk.
- **(v3) Do NOT re-attempt Prior-U at the `φ` level.** Phase 4's OUTCOME refutation stands
  unamended: negation-completeness of `limitSetBelow m r` asserts eventual constancy of *every*
  formula below `r`, a formula whose membership pattern is dense and co-dense in every left
  neighbourhood of `r` refutes it, and Prior-U's antecedent `U(⊤, φ)` is unavailable because
  `φ`'s truth region below the gap need not be an interval. v3's route applies Prior-U to
  `χ := Formula.someFuture φ` **only**, whose truth region below the gap *is* an interval. These
  are different statements; do not merge them, and do not read v3's success as licence to reopen
  the `φ`-level attempt.
- **(v3) Do NOT name, state, or re-derive `limitMCS_no_oscillation`.** It is false as stated
  (Phase 4 OUTCOME) and no phase of v3 needs it. Phase 4's two historical bullets naming it are
  record, not instructions. If an implementer finds a task pointing at it, they are reading v2.
- **(v3) Do NOT adopt a two-sided / symmetric limit at gaps, and do NOT choose the side
  per-point.** Burgess 1984 (printed p.109) defines exactly this two-sided seed and his very next
  paragraph (pp.109-110) still has to *prove* the prophecy claim via the continuity axiom `A7a`,
  so the seed makes the limit MCS coherent without removing this obligation. Cost of adopting it:
  `limitMCSBelow_cofinal_below` (`LimitMCS.lean:379`) has no two-sided analogue usable in both
  temporal directions, and all four `limitMCSBelow`-source coherence variants,
  `box_mem_realLimitMCS_iff`, both modal fields, and the currently-**unconditional** `somePast`
  half route through it — the last of which would acquire a mirror `prior_S_gap` obligation it
  does not have now. A per-point side choice is worse: `forward_G`/`backward_H` quantify over all
  pairs of real points, so a varying side breaks the 2x2 case matrix Phases 5-6 closed. Strictly
  more obligations, no gain.
- **(v3) Do NOT refine the unselected branch by a witness-aware / F-obligation-aware selection.**
  Refining it means abandoning the ultrafilter limit for `limitMCSLindenbaum`-style arbitrary
  extension, which has **no descent path back to `m q`** (`LimitMCS.lean:291`). Every asset
  Phases 5, 6 and 6.1 landed — the four `limitMCSBelow`-source coherence variants,
  `realLimitMCS_is_mcs`, `box_mem_realLimitMCS_iff`, both modal fields, and the unconditional
  `somePast` half — consumes `limitMCSBelow_cofinal_below`. This direction discards all of them
  and reopens Phases 4-6.1, and it is unnecessary: the object already in the tree satisfies the
  property once the frame class is used.
- **(v3) Do NOT modify any `cantorBfmcsDense` chronicle declaration**, in particular
  `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` (`:629`, `:680`, `:755`) or the underlying
  `limit_F_resolution` / `limit_satisfies_c4` / `limit_satisfies_c5_strong`. Phase 6.2 *consumes*
  them at self-roots and writes no chronicle-level proof. Editing them is the wrong seam, exactly
  as the standing constraint against lifting the Cantor layer to `ℝ` says.

  **Amendment 2 (v6), APPLIED verbatim from report 05 §8.2** under the fresh explicit user
  authorization at the R3d gate quoted in the Revision Rationale:

  > "**(v5 exception, user-authorized on 2026-07-27)** Phase 7.5 alone may extend the finite-stage
  > invariant `ChronicleInvariant` (`ChronicleTypes.lean:745`) with a Dedekind-closedness field on
  > the closure's guard-failure classes, and may alter the witness-placement discipline inside
  > `eliminatePotentialCounterexample` (`CounterexampleElimination.lean`), **provided** the
  > statements of `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` and of `limit_F_resolution` /
  > `limit_satisfies_c4` / `limit_satisfies_c5_strong` are **unchanged**, and provided every
  > currently-sorry-free consumer remains sorry-free. This exception is granted on the explicit
  > record that the modification has **no source in the corpus** (Burgess 1982 I places every
  > witness as a fresh point, printed pp.372-373; Burgess 1984's completion has no guard, printed
  > pp.109-110; Reynolds obtains every gap-facing formula by expressive completeness, printed
  > pp.176-178) and is therefore an **original construction**, not a transcription."

  **Scope reading (v6, binding — the amendment is applied verbatim and this note adds no
  permission).** "Phase 7.5 alone" is read as **the R3d sub-phase block, Phases 7.5-7.9**, which is
  the decomposition of the single phase the drafted text named; no other phase gains the exception.
  **The six named statements are unchanged** is a proviso *of* the amendment, not a target of it,
  and it is checked in Testing & Validation. **A factual correction the R3d dispatches must know**:
  the drafted text names `ChronicleInvariant` (`ChronicleTypes.lean:745`) as the finite-stage
  invariant, but a direct survey of the tree performed at this revision found that
  `ChronicleInvariant` — four fields, `hc0`, `hc1`, `hc2'`, `hc3` — is used **only** by
  `singleton_invariant` (`ChronicleConstruction.lean:103`) and is **not** threaded through the
  ω-chain. What the ω-chain actually carries is the subtype property of `omegaChain`
  (`ChronicleConstruction.lean:262`): `{ χ : Chronicle // χ.c0 fc ∧ χ.c2' fc }`, projected by
  `omega_chain_c0` (`:283`) and `omega_chain_c2'` (`:290`). **There is no "the invariant holds at
  every stage" theorem for the full bundle.** The amendment's permission therefore attaches to the
  objects that actually carry stage data — the `omegaChain` subtype, `EliminationResult`
  (`CounterexampleElimination.lean:580`), `C5ForwardWalkResult` (`:646`) and `C5BackwardWalkResult`
  (`:1254`) — and `ChronicleInvariant` itself need not be touched at all. This is a correction of a
  factual premise in the drafted text, made on direct evidence, and it **narrows** rather than
  widens what gets edited.
- **(v3) Do NOT enlarge `deferralClosure`, `extendedDeferralClosure`, or the root** to make the
  auxiliary Prior-U formulas (`U(⊤, Fφ)`, `U(¬Fφ ∨ K⁺¬Fφ, Fφ)`) available. Self-root
  instantiation plus `self_mem_subformulaClosure` makes closure enlargement unnecessary; a
  restricted-closure *finiteness* argument is also not a fix, since the counterexample uses a
  single atom that lies in `deferralClosure root` whenever it occurs in `root`.

  **Amendment 3 (v6), APPLIED verbatim from report 05 §8.2:**

  > "**(v5 clarification)** Phase 7.5's invariant is indexed by the guard formulas of
  > `untl`/`snce` members of `subformulaClosure root`, which is a `Finset`
  > (`SubformulaClosure/Closure.lean:36`). Indexing an invariant *by* the closure is not enlarging
  > it; no closure may grow."

  The final clause — **no closure may grow** — is the operative prohibition and is unweakened.
- **(v3) Do NOT state `BFMCS.LimitFutureWitness` without the unselectedness hypothesis.** The
  all-`r` form is false at any selected `r = (p : ℝ)` where `S_φ` attains a maximum at `p`; a
  phase that "proves" the all-`r` form has proved something wrong or has smuggled in an
  assumption.
- **(v3) Do NOT make `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind`, or `completeness_dedekind` conditional on an undischarged
  bundle-shaped predicate.** The single permitted added hypothesis anywhere on that chain is
  `(hfc : FrameClass.Dedekind ≤ fc)`, which is discharged by `decide` at the instantiation point.
  A terminus carrying an unproven property of the very object it constructs is vacuous-adjacent
  and is not an acceptable outcome of Phase 7.2 — see 7.2's fallback ladder.
- **(v4) Do NOT re-attempt an `fc`-generic backward Until/Since transport whose only
  rational-side hypothesis is restricted backward coherence.** It is **refuted**, not stuck. Two
  counterexample families are written out in full in `ChronicleRealExtension.lean`'s docstring
  (section `Refutations`) and are summarised in Phase 7.1′'s RESOLUTION block. A re-dispatch that
  produces a `sorry`-stubbed `BFMCS.toRealBundle_restricted_backward_until_since` at the v3
  signature would be stubbing a false statement. The **only** admissible statement is the one
  strengthened by `B.LimitGuardBelow`, discharged in the same dispatch by Phase 6.3's chronicle
  instance. Related and equally binding: do **not** weaken by restricting the target to selected
  reals only (Refutation 1 has a selected target — the gap enters through the *witness*), and do
  **not** chase the `snce` mirror through a bare `limitMCSBelow_cofinal_below` descent from the
  witness (that is the move that fails, and it was tried first; with `LimitGuardBelow` in hand the
  descent is legal because the guard has been extended *past* the gap first).
- **(v4, NARROWED IN PLACE BY AMENDMENT 1 — v5) Do NOT pursue the bounded-witness detour *as a
  route*.** The Phase 7.1 handoff proposed, as "the whole probe", a bounded form: from
  `φ ∈ limitMCSBelow m g` produce a rational `u` with `g < u < c` and `φ ∈ m u`. Findings (i) and
  (ii), established in report 04 and not to be re-litigated: (i) it is **not** derivable from
  `BFMCS.LimitFutureWitness` — that is the Prior-**U** statement, and
  `limitFutureWitness_of_priorU`'s `by_contra` hypothesis is `∀ s : Rat, r < s → φ ∉ m s`, vacuous
  for a family whose `φ`-region is cofinal above `r` but starts late, so it can bound nothing;
  (ii) it *is* provable, but only from `Axiom.prior_S_gap` via Phase 6.3's lemma instantiated at
  `ψ := φ.neg` — i.e. it is a **corollary of Phase 6.3, not a prerequisite of it**.

  **Amendment 1 (v5), applied verbatim from report 05 §8.2.** Clause (iii) and the final sentence
  of the v4 text are replaced by:

  > "(iii) **no case of the *backward* transport needs it** — cases 3′ and 4 place the witness
  > *below* the gap and case 2 needs no witness relocation at all. **(iv) Forward case B *does* need
  > it**, as `boundedWitness_of_limitGuardBelow`, and the blocker research proved it sorry-free in
  > twelve lines from the landed `limitGuardBelow_of_priorS`. The prohibition is hereby narrowed in
  > place to its original target: do not pursue the bounded witness **as a route** (i.e. do not
  > attempt to derive it from `BFMCS.LimitFutureWitness`, where finding (i) shows it is not
  > derivable, and do not budget a dispatch against obtaining it). Stating and proving it as a
  > Phase-6.3 corollary at the forward-case-B call site is permitted and required."

  **Why this amendment exists, recorded for audit.** v4's clause (iii) asserted "**no case of the
  transport needs it**". That is a **factually false justification clause**: report 05 §3 proves
  `boundedWitness_of_limitGuardBelow` sorry-free (12 lines) and shows it is step 5 of the *only*
  route through forward case B, with its `hcof` hypothesis supplied free as the right disjunct of
  the landed `toRealBundle_forward_until_unselected_dichotomy` (`ChronicleRealExtension.lean:732`).
  v4's clause was written when only the backward transport was in view and was never re-checked
  against the forward direction (report 05 §9.2 item 1 records the verification that changed the
  recommendation). **This is a correction of a false premise, not a relaxation of a sound
  prohibition**, and it is the only amendment applied in v5. The prohibition's original target —
  the bounded witness **as a route**, derived from `LimitFutureWitness` — is retained in full and
  is not weakened.
- **(v4) Do NOT state `BFMCS.LimitGuardBelow` with a closure hypothesis.** Mirroring
  `LimitFutureWitness`'s `φ ∈ deferralClosure root` here would be **actively wrong**: the guard `ψ`
  of an `untl φ ψ ∈ subformulaClosure root` need not lie in `deferralClosure root`, so the
  hypothesis would be an unprovable side condition at the call site. State it closure-free. (This
  is also the direction the standing no-closure-enlargement constraint points.)
- **(v4) Do NOT defend `ChronicleRealExtension.lean`'s forward-coherence claim about Refutation
  2.** Its docstring says the family fails unrestricted rational **forward** Until coherence; that
  is unsupported as written, and the supported statement is that it fails unrestricted rational
  **backward** Until coherence via `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ`. Correct the docstring (7.1′ task list);
  do not attempt to construct the forward violation. Neither claim is load-bearing: the operative
  exclusion is `LimitGuardBelow`, which both families violate directly and unconditionally.
- **(v5) Do NOT attempt to derive `BFMCS.LimitGuardEventual` (or forward case B's guard) from any
  Dedekind axiom.** Report 05 §4.1 closes this exhaustively, and the three sub-findings are
  **refuted premises**, not open leads: (a) `Axiom.prior_U_gap`'s antecedent `U(⊤, χ)` **is** the
  below-gap interval, so it can never *produce* one — this is the Phase 7.2 finding, restated;
  (b) `Axiom.prior_S_gap` produces an interval only *from* an above-gap interval — that is the
  landed `limitGuardBelow_of_priorS`, and report 05 §3 shows it yields the **necessity**
  direction, i.e. it consumes the conclusion rather than supplying the hypothesis; (c)
  `Axiom.sep` (`Axioms.lean:398`, `minFrameClass = .Dedekind` at `:524`) has shape
  `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)`, entirely inside `K⁺`/`K⁻` (arbitrarily-soon), which
  is the **negation** of "holds on an interval", so it cannot produce an interval either — and
  Reynolds' own use of `sep` is the separability route, which is dead. **There is no fourth
  Dedekind axiom.** A dispatch that proposes a 6.2/6.3-style axiom mirror for the forward guard
  has not read this. It survives only as this prohibition.
- **(v5) Do NOT treat `cantorIsoDense` as the lever for gap-accumulation.** The natural first
  thought — that "accumulation at an irrational" is a metric fact the Cantor isomorphism scrambles
  — is **refuted** by report 05 §4.2's order-theoretic characterization, written out in both
  directions: for `S ⊆ ℚ`, "`S` accumulates at some irrational `T` from below" is equivalent to
  "there is `S₀ ⊆ S` with no maximum, bounded above in `ℚ`, whose set of upper bounds in `ℚ` has
  no minimum" — mentioning only `<`, boundedness, maxima and minima, hence **invariant under any
  order isomorphism**. The property transfers exactly between `(LimitDom, <)` and `(ℚ, <)`. The
  standing no-`cantorIsoDense`-edit constraint therefore costs nothing here and stands unamended.
  The wrong intuition is recorded rather than deleted because it is the natural first thought and
  a future dispatch will have it too.
- **(v5, GATE RESOLVED IN v6 — retained so the resolution is auditable) Do NOT elect R3d without
  fresh, explicit user authorization.** The user's decision on the v4 → v5 revision was **"v5 +
  defer R3d"**, and Amendments 2-4 were drafted and not applied. **That gate is now resolved.**
  Fresh explicit user authorization was granted at the v5 → v6 revision and is quoted verbatim in
  the Revision Rationale; Amendments 2, 3 and 4 are **APPLIED** in place above, dated 2026-07-27.
  Phases 7.5-7.9 may therefore edit `CounterexampleElimination.lean` and
  `ChronicleConstruction.lean` **within the amendments' provisos and within their own stated
  territory, and nowhere else**. The authorization is scoped to R3d: it is **not** a general
  relaxation, and no other prohibition in this list is weakened by it.
- **(v6) Do NOT read the R3d authorization as licence for anything outside its own territory.**
  Specifically and non-negotiably, all of the following remain prohibited during Phases 7.5-7.9:
  editing `cantorIsoDense` (report 05 §4.2 proves it is not a lever); changing the statement of
  `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` or of `limit_F_resolution` /
  `limit_satisfies_c4` / `limit_satisfies_c5_strong` (a proviso of Amendment 2); enlarging any
  closure (Amendment 3's own final clause); witness-aware **selection**, i.e. any change to the
  choice of `Ultrafilter.of` or to any descent asset through `limitMCSBelow_cofinal_below` (report
  05 §8.3 checked this line by line and found it needs **no** amendment — R3d changes the
  *construction*, never the selection); expressive completeness, EF games, `≡_k`, Stavi
  connectives, or any monadic-FO layer; restating, weakening or re-shaping
  `BFMCS.LimitGuardEventual` itself (its statement is frozen — 7.5-7.9 discharge it, they do not
  redefine it); and threading any bundle-shaped predicate onto the terminus chain.
- **(v6) Do NOT let any R3d sub-phase end RED.** Amendment 2's proviso "every currently-sorry-free
  consumer remains sorry-free" is a per-sub-phase obligation, not an end-of-block one. Each of
  Phases 7.5-7.9 must end with full `lake build` green and the live sorry count outside `Boneyard/`
  unchanged at exactly `WeakCanonical/Transfer.lean:1242`. Adding a structure field and discharging
  it with `sorry` "to be filled in by the next sub-phase" is prohibited: the decomposition is
  ordered precisely so that every sub-phase is independently green, and a sub-phase that cannot be
  closed is marked `[BLOCKED]` with the exact goal state rather than stubbed.
- **(v6) Do NOT cite a source without the ADAPTED-FROM qualifier in any declaration introduced by
  Phases 7.5-7.9.** See the "Honesty charter for R3d docstrings" block below. This is a binding
  user directive, not a style preference.
- **(v5, updated by v6) Do NOT dispatch Phase 8 until `BFMCS.LimitGuardEventual` is discharged.**
  Landing 7.3 and 7.4 did not unblock Phase 8, and landing 7.5-7.8 does not either: until the
  cantor-side discharge exists the forward transport is conditional on an undischarged
  bundle-shaped predicate, and threading it onto the terminus is prohibited outright by the
  standing v3 constraint. **The exact expected declaration is
  `Chronicle.cantor_bfmcs_dense_limit_guard_eventual`, landed by Phase 7.9** together with
  `cantor_bfmcs_dense_real_restricted_fuc`. Until both exist, the correct task state is `[PARTIAL]`
  with the whole remaining forward obligation reduced to one named predicate.

**Honesty charter for R3d docstrings (v6, binding user directive).** Every declaration introduced
by Phases 7.5-7.9 — definitions, structure fields, private lemmas, and public theorems alike —
must carry a docstring that satisfies **both** of the following. A declaration failing either is a
defect to be fixed in the same dispatch, not a stylistic nit.

1. **The no-source statement.** It must say plainly that this construction has **no source in the
   corpus** and is **original work**. Report 05 §1.5 established this against all three primary
   sources re-read verbatim, and the task's own name and charter are *faithful route*, so the
   statement is a first-order fact about the deliverable, not a disclaimer. Do not soften it to
   "adapted from the literature", "following Burgess", or "standard".
2. **ADAPTED-FROM citations only, with printed pages.** Where the construction adapts a
   neighbouring discipline, the citation form is literally `ADAPTED-FROM: …` with the printed page
   range. The two permitted anchors:
   - **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373** — fresh-point witness placement
     ("it is possible to **add a single point `y` lying after `x`**"; "Set `y = x + 1`"; "Set
     `z = (x + x')/2`"). The tree transcribes this placement verbatim
     (`CounterexampleElimination.lean` `witness_not_old` `:678`/`:1282`, the midpoint split, the
     three-case walk). R3d **adapts** it by constraining where the placements may accumulate —
     something Burgess never needs, because he never reaches a gap and his variants table
     (printed p.369) has no Continuity row.
   - **ADAPTED-FROM: Burgess 1984 §2.7, printed pp.109-110** — the A7a-licensed far-side gap
     witness, placed with **no bound whatsoever** because `F`/`G` carries no guard. R3d **adapts**
     the shape of that step to a fragment (`U`/`S`) that does carry a guard, which is exactly why
     a bound and an accumulation constraint are needed and Burgess needs neither.

   Reynolds 1992 may be cited for the **statement** being discharged (`γ⁺` / left gaps, printed
   p.175) — that citation is already landed on `BFMCS.LimitGuardEventual` and is accurate — but
   **never** as a source for the discharge: he obtains every gap-facing formula by expressive
   completeness (printed pp.176-178), which is forbidden and already fatal to R2. Any docstring
   suggesting the discharge follows Reynolds is wrong on the record.

**Applied — Amendments 2, 3 and 4 (v6).** All three are recorded verbatim from report 05 §8.2 and
are **APPLIED in place**, each appended to the constraint or settled decision it amends (Amendment
2 above at the no-chronicle-modification constraint, Amendment 3 at the no-closure-enlargement
constraint, Amendment 4 at the `fc`-conditionality settled decision). Amendment 2's `{DATE}`
placeholder is resolved to **2026-07-27**, the date of the fresh explicit user authorization; no
other word of any of the three drafted texts is altered. Amendment 1 remains applied as in v5.
**No fifth amendment is created by this revision**, and no constraint outside those three is
touched.

**What report 05 checked and found needs NO amendment** (§8.3, checked line by line against the
full constraint list): the one-sided limit, the no-two-sided-limit rule, the
no-witness-aware-**selection** rule (R3 changes the *construction*, not the choice of
`Ultrafilter.of`, and every descent asset through `limitMCSBelow_cofinal_below` survives
untouched), the no-`φ`-level-Prior-U rule (Phase 7.3 applies Prior-U to the **guard** `ψ`, which
is Reynolds' own discipline — the formula uninterruptedly true on an interval abutting the gap),
the no-`cantorIsoDense`-edit rule, the no-conditional-terminus rule, and the pinned
`consequence_completeness_dedekind_of_engine` signature. All stand and are all respected by
Phases 7.3-7.9 as decomposed. **(v6)** This list is the reason the R3d authorization is narrow:
the three amendments were the *complete* set report 05 found necessary, they are the complete set
applied, and every other rule on this page is untouched by the authorization.

**MUST preserve**:

- Every row of the Preserved Assets table above, byte-identical unless a phase's Tasks list
  names the file.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense` and `completeness_discrete` sorryAx-free with axioms exactly
  `[propext, Classical.choice, Quot.sound]`.
- The single live sorry count outside `Boneyard/` must not increase. `Transfer.lean:1242`
  remains the only one at the end of this task unless a strategic sorry is explicitly elected
  under the contingency in Risks below.
- **(v2)** The exact signature of `consequence_completeness_dedekind_of_engine` as landed by
  Phase 2 (commit `bd9ae0ac1`, subsequently **renamed but not restructured** by the concurrent
  terminology reframing: same binders, same conclusion). Phase 8 instantiates it; no phase
  restates, reorders, or re-binds it.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Route B, not Reynolds' transfer.** Rejected on two independent grounds: the
  expressive-completeness dependency of D1/D2, and the absence from Mathlib of the
  order-theoretic characterization of `ℝ` (only *field*-theoretic uniqueness exists:
  `LinearOrderedField.uniqueOrderRingIso`, `inducedOrderRingIso`).
- **The terminus is the finite-context consequence form, and weak completeness is its `Γ = []`
  corollary.** `Context` is `List Formula` (`Syntax/Context.lean:60`), i.e. finite, so the two
  are inter-derivable through the deduction theorem — which is exactly why neither may be called
  "strong completeness". `soundness_dedekind` is already stated in arbitrary-`Γ` form, so the
  consequence terminus is its exact converse.
- **Genuine strong completeness is NOT the target and is provably unavailable here.** Changing
  `Context` to `Set Formula` would require compactness of the Dedekind-class consequence
  relation, and that relation is not compact. Out of scope; do not attempt, and do not rename
  any declaration in this plan back to a "strong" form.
- **Goldblatt's obstruction does not apply.** Goldblatt (arXiv:2310.20069, Introduction) states
  that propositional temporal logic over `(ℝ, <)` *is* recursively — indeed finitely —
  axiomatizable (Bull), and that Scott's non-axiomatizability result is about *first-order*
  temporal logic. The "admissible models" restriction in that paper is a first-order device.
  This does not license reopening the target.
- **The Dedekind case is a special case of the per-class completeness architecture**, not a
  parallel construction. `StrongCompleteness.lean` is laid out as a four-class family so the
  Base/Dense/Discrete instances drop in later without restructuring.
- **The chronicle layer stays at `Rat`; only the layer beneath moves to `ℝ`.** This is the seam,
  and it is fixed.
- **(v2, settled by counterexample) The real extension selects `m q` directly at selected
  points and takes the left limit only elsewhere.** Selected points are the reals of the form
  `(q : ℝ) - δ` for `q : Rat` and the family's real offset `δ`. This is the *only* shape under
  which the extension extends rather than replaces the rational family, because rational
  agreement is unavailable as a lemma.
- **(v2, settled by proof obligation) The real bundle's family set is the real-shift closure**
  `{fam.toRealShift δ | fam ∈ B.families, δ : ℝ}`, not an image. Justification in Phase 6.1.
- **(v3, settled by the blocker research; widened in place by v4) Every gap-facing obligation on
  this route is discharged `fc`-conditionally, not `fc`-generically.** `limitFutureWitness_of_priorU`
  and `cantor_bfmcs_dense_limit_future_witness` consume `Axiom.prior_U_gap`, and Phase 6.3's
  `limitGuardBelow_of_priorS` / `cantor_bfmcs_dense_limit_guard_below` consume
  `Axiom.prior_S_gap`; both axioms have `minFrameClass = .Dedekind`, so all four carry
  `(hfc : FrameClass.Dedekind ≤ fc)`. This is not a weakness of the route — it is the route
  finally using the axioms that distinguish the class it is proving completeness for. **The
  widening is the whole content of the v4 revision**: v3 established this shape for
  `LimitFutureWitness`, recorded it as settled, and then did not apply it to the guard obligation,
  budgeting Phase 7.1 at "4 hours, mechanical" on the strength of that omission. Do not attempt an
  `fc`-generic version of any of the four, and treat any *new* gap-facing obligation discovered
  later as `fc`-conditional by default.

  **Amendment 4 (v6), APPLIED verbatim from report 05 §8.2:**

  > "**(v5)** `BFMCS.LimitGuardEventual` is the **first** gap-facing obligation on this route that is
  > *not* discharged by a frame-class axiom. Its discharge is a property of the construction, not of
  > the logic. This is a genuine departure from the settled shape and is the reason Phase 7.5 is
  > quarantined from Phases 7.3-7.4."

  **(v6) The quarantine survives the authorization and is now a territory contract**: Phases
  7.5-7.9 own the construction files and touch **no** declaration owned by Phases 7.3/7.4, and
  Phases 7.3/7.4's landed declarations are consumed as-is. The departure this amendment records is
  the reason the R3d block is a separate, separately-marked, separately-rollback-able block rather
  than an extension of 7.4.
- **(v4, settled by the blocker research) The gap axiom is applied to the formula that is
  uninterruptedly true on an interval abutting the gap — never to a witness.** This is Reynolds'
  uniform discipline across all seven of his §6 appeals (printed pp.176, 178). For the backward
  transport that formula is the **guard** `ψ`, whose interval is handed over by the transport's own
  hypothesis, so Prior-S's antecedent `S(⊤,ψ)` is discharged *from data*. Applying a gap axiom to
  the witness instead is what produces the bounded-witness dead end. Do not re-open the choice of
  formula.
- **(v4, settled) The Phase 7.1 refutations are findings about the generic statement, not about
  the chronicle instance.** `cantor_bfmcs_dense_real_restricted_buc` is **reachable** and all four
  of its cases close; the two families' unrealizability inside `cantorBfmcsDense` follows as a
  corollary of the route, not the other way round. Do not re-derive the families, do not attempt
  to prove them unrealizable directly, and do not treat 7.1′ as a probe — the route is determined:
  the axiom is identified, the four cases are enumerated, and the discharge template is a landed
  file.
- **(v3, settled) The residual obligation is a property of the *rational family*, not of the
  extension.** The Phase 6.1 counterexample uses no field of the real extension. No change to the
  real-shift closure, the selection condition, or the limit branch can repair it, and none should
  be attempted.
- **(v5, settled by proof) `BFMCS.LimitGuardEventual` is necessary AND sufficient for the whole
  remaining forward obligation, both halves. There is no third route.** Sufficiency is report 05
  §3's six-step chain (Phases 7.3 + 7.4); necessity is `r3_invariant_necessary`, proved sorry-free
  against the real tree. The conclusion of forward case B *entails its own* R3 hypothesis: its
  guard clause is quantified over **all** reals of `(t,s)`, the selected ones among them are
  exactly the rationals of `(t+δ, s+δ)`, so the conclusion hands back a rational guard interval
  abutting the gap from above, and the landed `limitGuardBelow_of_priorS` converts it to one
  abutting from below. **Do not propose a weaker sufficient condition, an alternative predicate,
  or a route that sidesteps it** — a dispatch that does has not read this. The forward `snce` half
  needs the invariant and **no Prior-U step at all**: its obligation is `∃ s < t` with `φ` at `s`
  and `ψ` on `(s,t)`, i.e. `ψ` on rationals abutting `t + δ` **from below**, which *is*
  `ψ ∈ limitSetBelow m (t+δ)` verbatim, with `φ` from the same cofinal descent.
- **(v5, settled by the literature verdict) Phases 7.3-7.4 are transcription; Phase 7.5 is an
  original construction. The plan says so in both directions and does not blur them.** 7.3 is
  Reynolds' Theorem 3 move (printed p.176) mirrored onto a landed file; 7.4's bounded witness is
  a Phase-6.3 corollary and its predicate is Reynolds' `γ⁺` condition (printed p.175). 7.5 has
  **no source in the corpus** — report 05 §1.5 establishes this against all three primary sources
  read verbatim. The task's own name and charter are *faithful route*, so this is a first-order
  finding, not a footnote. **(v6)** It was the reason 7.5 was user-gated rather than scheduled; the
  gate has been resolved by explicit authorization granted *with this finding stated*, and the
  finding itself is unchanged. It is now discharged forward as the **honesty charter for R3d
  docstrings** above: the no-source fact must appear on every declaration Phases 7.5-7.9 introduce,
  and neighbouring disciplines are cited **ADAPTED-FROM** with printed pages, never as
  transcription.
- **(v5, settled) Phase 7.2 completed its charter.** It was a two-outcome probe and outcome (ii)
  fired, with four sorry-free declarations landed and the three required refutation elements
  delivered — its own `Done when` clause, met. The `[BLOCKED]` marker it carried was the marker
  the phase text instructed the dispatch to set under outcome (ii); this revision is the
  escalation that outcome demanded, and is therefore the point at which the marker is retired to
  `[COMPLETED]` with the findings preserved as an OUTCOME record. Do not re-derive Refutation 3,
  do not attempt to prove it unrealizable directly, and do not re-litigate R2 — it is dead on
  verbatim source evidence.
- **(v2) Only the *below* limit is load-bearing.** `limitSetAbove` and its Phase 3 duals are
  standing sorry-free assets; the extension uses `limitSetBelow` alone, and both `forward_G`
  and `backward_H` go through it (verified case-by-case in Phase 5). No phase is obliged to
  prove maximality of `limitSetAbove`.

---

## Goals & Non-Goals

- **Goals**:
  - `consequence_completeness_dedekind (Γ : Context) (φ : Formula) : SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free.
  - `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ` as the `Γ = []` corollary.
  - A reusable `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` limit extension with its coherence proofs.
  - **(v3)** `limitFutureWitness_of_priorU` — a reusable, `fc`-conditional statement that a
    Dedekind-MCS family has no definable `Fφ`-gap at an irrational point, and its chronicle
    instantiation `cantor_bfmcs_dense_limit_future_witness`.
  - **(v4)** `limitGuardBelow_of_priorS` — the Prior-S mirror: a reusable, `fc`-conditional
    statement that a Dedekind-MCS family has no definable **right** gap for any formula `ψ` at an
    unselected real (Reynolds' `γ⁻`, printed p.175) — together with the closure-free predicate
    `BFMCS.LimitGuardBelow` and its chronicle discharge
    `cantor_bfmcs_dense_limit_guard_below`.
  - **(v4)** `cantor_bfmcs_dense_real_restricted_buc` — the backward Until/Since coherence of the
    real bundle for the Cantor dense chronicle, via the `LimitGuardBelow`-strengthened transport.
  - **(v5)** `limitGuardAbove_of_priorU` — the Prior-U mirror of the guard gap lemma: at an
    unselected real, a formula eventually true *below* the gap is true on an interval of rationals
    abutting it *from above* (Reynolds Thm 3, printed p.176) — plus its chronicle discharge.
  - **(v5)** `boundedWitness_of_limitGuardBelow` — the bounded witness at the forward-case-B call
    site, transcribed from report 05 §3 (already proved sorry-free there).
  - **(v5)** `BFMCS.LimitGuardEventual` — the closure-free, `root`-free bundle predicate that is
    necessary and sufficient for the whole remaining forward obligation.
  - **(v5)** `toRealBundle_forward_until_unselected` **and**
    `toRealBundle_forward_since_unselected` — the second of which repairs v4's **charter gap** —
    plus their composition `BFMCS.toRealBundle_restricted_forward_until_since`, conditional on
    `B.LimitGuardEventual`.
  - **(v6)** `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` — the cantor-side discharge of
    `BFMCS.LimitGuardEventual`, and with it `cantor_bfmcs_dense_real_restricted_fuc`, delivered by
    the R3d block (Phases 7.5-7.9). **This is an original construction with no source in the
    corpus**, authorized explicitly by the user at the v5 → v6 revision, and it is the last
    obligation between the tree and the unconditional terminus.
  - `FormalSystem/Metalogic.lean` tracking table updated.
- **Non-Goals**:
  - Infinite-premise (`Set Formula`) strong completeness or compactness for this class — the
    Dedekind consequence relation is not compact, so it is unavailable, not merely deferred.
  - `consequence_completeness_base` / `_dense` / `_discrete`, and the genuine strong-completeness
    layer for Base/Dense (owned by the per-class completeness effort; this plan only shapes the
    file so they drop in).
  - Closing `Transfer.lean:1242`.
  - Any Reynolds-transfer artifact (see Postmortem Constraints).
  - Expanding `specs/literature-index.json` (a separate curation concern; the audit's
    recommendations are recorded, not executed here).
  - **(v2)** Maximality of `limitSetAbove`. Not on the route.
  - **(v3, SUPERSEDED by v4 — recorded so the reversal is auditable)** v3 listed "the `prior_S_gap`
    / past mirror of `limitFutureWitness_of_priorU`" as a non-goal, on the ground that the
    `somePast` half of the *temporal* transport is unconditional and the mirror therefore has no
    consumer. That reasoning is correct **about the temporal transport** and remains so; it does
    not extend to the Until/Since transport, whose backward direction acquires a consumer at
    Phase 7.1′. Phase 6.3 is exactly that mirror, and it is now a **goal**. The `somePast` half of
    `BFMCS.toRealBundle_restricted_temporally_coherent` stays unconditional and is not reopened.
  - **(v4, CORRECTED by v5 — recorded so the reversal is auditable)** v4 listed the **bounded**
    witness form (`g < u < c` with `φ ∈ m u`) as a non-goal on the ground that it is "needed by no
    case". That ground is **factually false** for forward case B: report 05 §3 proves
    `boundedWitness_of_limitGuardBelow` sorry-free in twelve lines and shows it is step 5 of the
    only route through that case, with its `hcof` hypothesis supplied free by the landed
    dichotomy. It is a **goal** of Phase 7.4. What remains a non-goal, unchanged, is pursuing it
    **as a route** — deriving it from `LimitFutureWitness`, or budgeting a dispatch against
    obtaining it. See Amendment 1 in the Postmortem Constraints.
  - **(v5, PROMOTED TO A GOAL BY v6 — recorded so the reversal is auditable)** v5 listed
    "discharging `BFMCS.LimitGuardEventual` for `cantorBfmcsDense`" as a non-goal, because Phase
    7.5 was `[USER GATED]` and out of scope for any dispatch under that plan version. **The gate
    was resolved by fresh explicit user authorization at the v5 → v6 revision**, so it is now a
    **goal**, decomposed as Phases 7.5-7.9. Nothing about the underlying mathematics changed; only
    the authorization did.
  - **(v5, RESHAPED BY v6)** Settling, *as a general model-theoretic question*, whether the
    ultrafilter-independent candidate family `Q` (report 05 §5.1) is realizable at
    `fc = FrameClass.Dedekind` remains a **non-goal**: doing so requires the EF / modal-depth
    machinery the Postmortem Constraints forbid and that killed R2, and **R3 is still neither
    proved live nor proved dead**. What v6 *does* pursue is the strictly narrower and permitted
    question — **does `cantorBfmcsDense`'s own construction produce the `Q` pattern?** — answered
    constructively by attempting the invariant. Defeating `Q` inside the construction is a Lean
    proof; discovering the construction forces it is an exhibited obstruction. Neither requires
    the forbidden machinery, and neither settles `Q`'s abstract realizability. See the two-outcome
    risk-register entry below.
  - **(v4)** A *forward* violation for Refutation 2's family. The docstring claim asserting one is
    corrected rather than substantiated (7.1′ task list).
  - **(v3)** Reynolds' separability route to ℝ (Doets' theorem + `Axiom.sep`). It is named in
    Phase 7.2's fallback ladder as the escalation target if the probe refutes; it is **not** built
    by this plan and electing it requires a new research dispatch.

---

## Risks & Mitigations

- **Risk (HIGHEST): the limit MCS is not negation-complete for *all* formulas.** The chronicle
  bundle satisfies only the *Restricted* coherence predicates — scoped to
  `deferralClosure root` / `subformulaClosure root`. If the no-definable-gaps argument is only
  available for root-subformulas, the "eventually true approaching `r` from below" set is
  consistent but may not be maximal, and `FMCS.is_mcs` cannot be discharged directly.
  **Mitigation (decided at plan time, in this order)**: (a) attempt unrestricted
  negation-completeness first, since Prior-U instances are in *every* Dedekind-MCS by
  `theorem_in_mcs` and the argument is syntactic; (b) if that fails, fall back to
  *consistency + `set_lindenbaum`*: the limit set is consistent (each finite subset is
  eventually contained in a single `mcs y`, hence consistent), so Lindenbaum yields a genuine
  MCS, and the no-definable-gaps content is then needed only to show the *chosen* extension
  preserves `forward_G`/`backward_H` and restricted U/S coherence. Phase 4 must state which of
  (a) or (b) it took and why, in the module docstring. (c) If neither closes, mark Phase 4
  `[BLOCKED]` — see the contingency below.
  **(v2 sharpening of fallback (b))**: v1 called (b) "a strictly weaker obligation". That is
  optimistic and the implementer must not rely on it. Under (b) the family value at an
  unselected point is `Lindenbaum (limitSetBelow m r) ⊋ limitSetBelow m r`, so every Phase 5
  lemma whose *hypothesis* is a membership at an unselected point loses its handle: from
  `allFuture φ ∈ Lindenbaum(limitSetBelow m s)` one cannot descend to `allFuture φ ∈ m q` for
  rationals `q` near `s`. Choosing (b) therefore forces Phase 5's six lemmas and Phase 6's
  `forward_G`/`backward_H` to be restated for the chosen extension, not merely reused. Budget
  for that before electing (b).
- **Risk: the `D := ℝ` instantiation claim is second-hand.** Report 01 relied on report 390's
  compile probe rather than re-running it. Route B's entire feasibility rests on it.
  **Mitigation**: Phase 1 is exactly that probe, costs one build, and gates everything.
  **RETIRED** — Phase 1 ran the probe and it passed on the first attempt; the probes are
  landed as permanent `noncomputable example`s in `CompletenessDedekind.lean`'s `CarrierProbe`
  section, so a binder regression fails the build.
- **Risk (v2, NEW — HIGH): `modal_backward` at an unselected real point.** `BFMCS.modal_backward`
  (`BFMCS.lean:112`) demands: if `φ` is in *every* family's MCS at `t`, then `box φ` is in each
  family's MCS at `t`. At an unselected `t` the hypothesis gives, per family, only an
  *eventually* statement with a **family-dependent** threshold `z_fam < t`. An arbitrary bundle
  has no common rational below `t`, so the `Rat`-side `modal_backward` can never be applied and
  the field is unprovable for the image family set that v1 specified.
  **Mitigation (adopted, Phase 6.1)**: close the real family set under real shifts. Then the
  contrapositive runs exactly as at `Rat`: pick any rational `q`; `Rat` `modal_backward`
  contrapositive yields `fam'` with `φ ∉ fam'.mcs q`; the family `fam'.toRealShift ((q:ℝ) - t)`
  is in the real bundle and takes the value `fam'.mcs q` **at `t`** by rational selection,
  contradicting the hypothesis. This mirrors `ChronicleToCountermodelBasic.lean:576`, which
  positions its witness family by choosing the chronicle's rational shift.
- **Risk (v2, NEW — MEDIUM): time-stability of `box` membership is required and is not yet a
  named lemma.** Both `modal_forward` and `modal_backward` for the real bundle need
  `box φ ∈ f.mcs s ↔ box φ ∈ f.mcs t` for a `Rat` family `f`. The future direction is available
  from `temporalFutureDerived` (`Combinators.lean:654`, `fc`-generic: `□φ → G(□φ)`) plus
  `theorem_in_mcs` and `FMCS.forward_G`. The past direction has **no** `□φ → H(□φ)` theorem in
  the tree — `Axioms.lean:540` mentions "modal_past (derived)" in prose only, and
  `Automation/FormulaEnumerator.lean:1239` names it only as an enumerated shape.
  **Mitigation**: obtain the past direction *without* a past-modal axiom, by pushing the
  negation forward instead: from `¬□φ` derive `□¬□φ` (S5 negative introspection, from
  `Axiom.modal_5_collapse` / `Theorems/ModalS5.lean`), then `Axiom.modal_future` gives
  `□¬□φ → □(G ¬□φ)` and `Axiom.modal_t` gives `G ¬□φ`; `forward_G` then propagates `¬□φ`
  forward, and MCS negation-completeness converts this into the backward direction. **Do NOT
  add a `modal_past` axiom** — that would change the proof system. If negative introspection is
  not already a named theorem, land it as an `fc`-generic derived theorem in Phase 6.1's module.
- **Risk: `RestrictedForwardUntilSinceCoherent` at an unselected `t` is the hardest transport.**
  Producing `s > t` with the guard `ψ ∈ mcs r` for *all* `r ∈ (t,s)` — including unselected
  `r` — re-invokes the limit-MCS property rather than merely quoting the `Rat` witness.
  **Mitigation**: it is isolated in its own phase, after the limit MCS is fully
  characterized, so it cannot silently consume the crux phase's budget.
  **(v2 refinement)**: the difficulty is now located precisely. The *guard* side is easy in both
  cases — a `Rat` guard covering all rationals in `(t+δ, s+δ)` automatically covers unselected
  `r`, because `limitSetBelow m (r+δ)` is witnessed by the threshold `t+δ`. The *selected-`t`*
  case is fully mechanical. Only obtaining the real witness `s` from a membership at an
  **unselected** `t` is hard, because the `Rat` witnesses `s_p` for rationals `p ↗ t+δ` may
  shrink to `t+δ`.
  **(v3 relocation)**: this sub-obligation is now Phase 7.2 and nothing else. It is explicitly
  **not** repaired by re-invoking Phase 4 — see the next risk.
  **(v4 correction — the sentence "the *selected-`t`* case is fully mechanical" was the load-bearing
  error)**: v3 read that assessment across to the **backward** direction as well, and it is false
  there. Refutation 1 has a *selected* target and still fails, because the gap enters through the
  **witness**. Nothing about the backward direction was ever mechanical: it needs `prior_S_gap`
  (Phase 6.3) exactly as the forward-`someFuture` obligation needed `prior_U_gap`. Read this risk
  as scoped to the **forward** direction only.
- **Risk (v4, RETIRED at statement level — kept as the record of a refuted design): the
  `fc`-generic backward Until/Since transport.** v3 budgeted it at "4 hours, mechanical". It is
  refuted by two explicit families. **Mitigation (adopted, Phases 6.3 + 7.1′)**: strengthen the
  transport by one hypothesis, `B.LimitGuardBelow`, discharged in the same dispatch by the
  chronicle instance Phase 6.3 lands. The residual risk is **elaboration friction, not
  mathematics**: report 04 hand-derived all four cases against verified signatures, but no
  `lake build` was run, and the likely friction points are the `δ`-shift casts around
  `realLimitMCS_of_rat` / `_of_not_rat` and the `≤` (not `<`) upper bound in
  `exists_rat_witness_of_realLimitMCS`'s conclusion. Budget for casts, not for a new idea. If a
  case genuinely does not close, the correct outcome is `[BLOCKED]` with the exact goal state —
  **not** a widening of the hypothesis set and **not** a bounded-witness attempt.
- **Risk (v4, MEDIUM): Phase 6.3 is a clone, and clones invite drift.** `limitGuardBelow_of_priorS`
  mirrors `limitFutureWitness_of_priorU` step for step, but three things genuinely differ and each
  is a place a mechanical transcription goes wrong: (i) the coherence hypotheses are the `.2`
  (`snce`) projections of `_fuc`/`_buc`, where 6.2 used `.1`; (ii) there is **no outer
  `by_contra`** — the proof is a two-case split on whether `ψ.neg.somePast ∈ m t`, and Case 1 is
  three lines; (iii) the predicate is **closure-free**, unlike its sibling. **Mitigation**: the
  phase's task list states all three explicitly and the estimate (~180-220 lines) is *below* 6.2's
  209 for the general lemma precisely because of (ii). An implementer who finds themselves writing
  a Step-D double-negation dance has drifted into copying 6.2 rather than proving 6.3.
- **Risk (v3, HIGHEST OPEN): the Prior-U technique does not transfer to Phase 7.2, and there is a
  candidate refuting family.** Phase 6.2's Step A works because the truth region of
  `someFuture φ` below a gap is the interval `(-∞, r)`. The truth region of `untl α β` need not
  be. Concretely: a family in which `β` fails at rationals `t_n ↗ r`, `α` holds at a single point
  `α_n ∈ (t_n, t_{n+1})`, and `α` fails everywhere above `r`, has `untl α β` true on `⋃(t_n, α_n)`
  and false on `⋃(α_n, t_{n+1})` — cofinal below `r` in both directions. Prior-U applied to
  `untl α β` at `t_n` is then satisfied *locally*, with its witness `u` landing in
  `[α_n, t_{n+1}]` where `¬(untl α β)` genuinely holds, so **no contradiction arises**. Whether
  such a family is realizable inside `cantorBfmcsDense` at `fc = FrameClass.Dedekind`, and whether
  the below-limit ultrafilter can admit `{q | untl α β ∈ m q}`, are open. Reynolds is explicit
  (§6 opening, printed p.176) that no-definable-gaps is *not by itself enough* for the reals
  construction, and his stronger result routes through contemporaneous equivalence classes,
  Doets' theorem and `Axiom.sep` — **not** through a Dedekind completion of a rational chronicle.
  Burgess runs the completion route but only in the `F`/`G` fragment (printed pp.109-110) and says
  nothing about `U`/`S` at a gap. So Phase 7.2 is doing something neither primary source does
  directly.
  **Mitigation**: Phase 7.2 is a **two-outcome probe**, not proof engineering. A refuting family is
  an acceptable, planned outcome with a fixed fallback ladder (7.2, "If the refutation outcome
  fires"). Do not budget 7.2 as if a proof were assured, and do not let a 7.2 dispatch drift into
  Phase 8 work. Partial structure that is already established and does **not** need re-deriving:
  case (a) — a rational Until-witness strictly above `r + δ` — closes cleanly with 7.1′'s guard
  lemma; case (b) — all rational witnesses squeezing to `r` — is the residual, where Phase 6.2's
  lemma applied to `α` does produce a rational `α`-point above `r` (the eventuality half is fine)
  but supplies **no guard** on the interval between `r` and that point. The guard is the whole
  difficulty.
- **Risk (v5, HIGHEST OPEN — and it is a *decision* risk, not a proof risk): `LimitGuardEventual`
  may be undischargeable, and settling that is forbidden.** After 7.3 and 7.4 land, the entire
  remaining forward obligation is one named predicate. Whether `cantorBfmcsDense` satisfies it is
  **open in both directions** (report 05 §5.4): the invariant is consistent with every
  formula-level demand — the closure is a `Finset` (`SubformulaClosure/Closure.lean:36`) so only
  finitely many guards matter, no formula can *force* accumulation at a gap (a formula can force
  accumulation only at a **point**, via `K⁻(¬ψ)`, and domain points are *selected* and never use
  the limit), and the chronicle already retains Burgess's interval datum `g(x,y)`
  (`CounterexampleElimination.lean:660`) needed to state it — **but** the candidate refutation is
  now ultrafilter-**independent** (family `Q`, §5.1), and `counterexampleEnum` is surjective onto
  all `PotentialCounterexample` records (`ChronicleConstruction.lean:218`), so a single domain
  point is revisited infinitely often and nothing in `ChronicleInvariant`
  (`ChronicleTypes.lean:745-755` — fields `hc0`, `hc1`, `hc2'`, `hc3`, nothing about ordering,
  placement or accumulation) bounds where the insertions converge.
  **Mitigation (v5)**: do not attempt to settle it. Land 7.3 and 7.4, which are unconditionally
  valuable under every outcome, then present the R3d decision to the user. **(v6 disposition: the
  decision was made — R3d is authorized. This risk is superseded by the two-outcome entry
  immediately below, which is its execution form.)**

- **RISK REGISTER ENTRY (v6, HIGHEST OPEN — the R3d falsification risk): the construction must
  either DEFEAT family `Q` or DISCOVER that it is realizable, and both outcomes are planned for.**
  This is the single risk that governs Phases 7.5-7.9. It is stated here in full, and each
  sub-phase restates its own share of it.

  **The candidate.** Report 05 §5.1's family `Q`: one atom `P`, a fixed irrational `T`, rationals
  `t_n ↗ T` and `u_n ↓ T`, `V(P) = {t_n} ∪ {u_n}`, `m q` the theory of `q` in the **ℚ**-structure
  `(ℚ, <, V(P))`, with `φ := P` and `ψ := ¬P`. Then `untl P ¬P` holds at every rational below
  `u_0` (the `P`-set is locally finite away from `T`, so a next `P`-point with a clean gap always
  exists), hence `untl φ ψ ∈ limitSetBelow m T ⊆ limitMCSBelow m T` via `limitFilterBelow_le`
  (`LimitMCS.lean:347`) — **with no ultrafilter choice involved**, which is what makes `Q` strictly
  stronger than Refutation 3. But `ψ = ¬P` fails at every `t_n`, so `ψ ∉ limitSetBelow m T` and the
  obligation is unsatisfiable at `T`. If `cantorBfmcsDense` can produce this pattern,
  `LimitGuardEventual` is **false** for it and R3d is dead.

  **What is and is not being asked.** Whether `Q` is *abstractly* realizable at
  `fc = FrameClass.Dedekind` needs an EF / modal-depth argument that the Postmortem Constraints
  forbid and that killed R2 — that question stays closed and unattempted (see Non-Goals). The
  question Phases 7.5-7.9 actually answer is constructive and permitted: **does the ω-chain's own
  witness-placement discipline force a guard-failure set to accumulate at an unselected real?**

  **Outcome A — `Q` is defeated inside the construction.** The invariant holds of
  `singletonChronicle`, is preserved by every branch of `eliminatePotentialCounterexample`
  (possibly after an authorized change to the placement discipline), transports to `LimitDom` and
  through `cantorIsoDense`, and Phase 7.9 lands
  `Chronicle.cantor_bfmcs_dense_limit_guard_eventual`. Phase 8 unblocks. This is a **proof**, not a
  claim about `Q` in general: it shows the pattern is not realized *here*.

  **Outcome B — the construction is discovered to force the pattern.** A sub-phase exhibits a
  concrete branch (in practice a `c5_forward_walk` / `c5_backward_walk` case) whose placements
  provably accumulate at an unselected real, or a concrete `PotentialCounterexample` enumeration
  order that drives them there. **This is a success of the dispatch, not a failure of it** — it is
  the falsification the authorization was granted to attempt. Required deliverables in that case,
  and a dispatch that reports Outcome B without all three has not established it: (i) the exact
  branch and the exact goal state where preservation fails; (ii) an explicit witness — the
  sequence of insertions and the unselected real they converge to; (iii) a statement of whether the
  obstruction is *intrinsic to Burgess's fresh-point discipline* or an artefact of the enumeration
  order, since only the latter would leave a repair open.

  **The honest floor for Outcome B, stated in advance so no dispatch has to invent it.** Mark that
  sub-phase `[BLOCKED]` with the exhibited obstruction (never `[COMPLETED]`, never a widened
  hypothesis set, never a `sorry`). Mark the **task** `[PARTIAL]`. Do **not** dispatch Phase 8 —
  the no-conditional-terminus constraint is not amended by the R3d authorization. Keep every
  landed asset: Phases 1-7.4 stand, the forward obligation remains reduced to one named predicate,
  and any sub-phase of the R3d block that landed green before the obstruction stays landed. That
  `[PARTIAL]` is strictly better than v5's, because it converts "we do not know whether the
  construction has the invariant" into "the construction provably does not, for this stated
  reason" — which is a genuine route-level finding and the correct input to any future escalation.
  **Do not improvise a substitute predicate**: report 05 §3 proves `LimitGuardEventual` is
  *necessary*, so there is no weaker sufficient condition to retreat to.

  **Mitigation, and it is the shape of the decomposition itself.** Phase 7.5 is deliberately
  risk-first and **touches no construction file**: it states the invariant and proves the payoff
  implication, so an invariant that does not imply the predicate is discovered for the price of one
  agent run rather than after four. Phase 7.5 also lands the family-`Q` check as an explicit
  artefact, so the invariant is demonstrably non-vacuous and demonstrably excludes `Q` **before**
  anyone edits a 3,622-line file.

- **Risk (v5, carried into v6 unchanged — base-rate risk on the R3d block): every prior unsourced
  escalation on this task was subsequently refuted or killed.** `limitMCS_no_oscillation` (Phase
  4), the `fc`-generic backward transport (Phase 7.1), the bounded-witness detour *as a route* (the
  Phase 7.1 handoff), and R2 (Phase 7.2) each lacked a source and each was refuted or killed.
  Phases 7.5-7.9 are the steps with **no source** (report 05 §1.5). **That base rate is a fact
  about this task and belongs in the plan**, not in a footnote. **Mitigation (v6)**: it was stated
  to the user and the authorization was granted against it — which is the mitigation the base rate
  admits. Beyond that: risk-first ordering (7.5 before any file edit), per-sub-phase green builds,
  the Outcome B protocol above, and the standing rule that a blocked sub-phase reports an exact
  goal state rather than widening its hypotheses.
- **Risk (v6, MEDIUM — the drafted amendment named the wrong object): `ChronicleInvariant` is not
  the finite-stage invariant that the ω-chain carries.** Amendment 2's drafted text (and report 05
  §4.3) names `ChronicleInvariant` (`ChronicleTypes.lean:745`) as the object to extend. A direct
  survey at this revision found it is used **only** by `singleton_invariant`
  (`ChronicleConstruction.lean:103`); the ω-chain actually carries the subtype property of
  `omegaChain` (`:262`), `{ χ : Chronicle // χ.c0 fc ∧ χ.c2' fc }`, and there is **no** theorem
  asserting the full bundle invariant at every stage. An implementer who takes the drafted text
  literally will spend a dispatch extending a structure nothing consumes.
  **Mitigation**: the correction is recorded inline under Amendment 2 and the sub-phase territories
  name the real objects — `C5ForwardWalkResult` (`CounterexampleElimination.lean:646`),
  `C5BackwardWalkResult` (`:1254`), `EliminationResult` (`:580`) and the `omegaChain` subtype
  (`ChronicleConstruction.lean:262`). Verify against the file before editing; do not trust this
  paragraph either.
- **Risk (v6, MEDIUM — sizing): `CounterexampleElimination.lean` is 3,622 lines and the two C5
  walks are `private`.** A `private noncomputable def` cannot be given an external preservation
  lemma from another module, so the property must be carried as a **field of the walk's result
  structure** and discharged inside the file. That is a larger edit than an external lemma and it
  is why the forward and backward walks are separate sub-phases rather than one.
  **Mitigation**: 7.6 and 7.7 each own exactly one walk and its result structure; adding a field to
  a *produced* structure leaves every consumer building unchanged, so each ends green
  independently. If either overruns, report the exact remaining case — do not silently re-dispatch
  against the same target (the churn pattern H6 exists to catch).
- **Risk (v5, MEDIUM): Phase 7.3 is a mirror, and mirrors invite drift** — the same risk Phase 6.3
  carried, in the opposite direction. `limitGuardAbove_of_priorU` mirrors
  `limitGuardBelow_of_priorS` (`ChronicleLimitGuardWitness.lean:105-207`) with `snce → untl`,
  `prior_S_gap → prior_U_gap`, `kMinus → kPlus`, `.2 → .1`, and **the direction of every
  inequality reversed**. The last is where a mechanical transcription goes wrong: `hev` is now a
  *hypothesis* (`ψ ∈ limitSetBelow m r`) and the interval is the *conclusion*, which is the
  reverse of 6.3's shape even though the plumbing is identical.
  **Mitigation**: the phase's task list states the substitution table explicitly, the statement is
  **verified to elaborate**, and unselectedness is used **exactly once** (to exclude `(e : ℝ) = r`).
  An implementer who finds unselectedness used twice, or who is writing a `by_contra` around the
  whole proof, has drifted into copying 6.2 rather than mirroring 6.3.
  **Confidence note carried from report 05 §9**: the *statement* is High confidence (elaborated);
  the *proof* is Medium (hand-verified against the landed mirror, not run). Budget accordingly.
- **Risk (v5, LOW-MEDIUM): Phase 7.4 has four deliverables and could overrun one agent run.**
  The bounded witness (12 lines, **transcribe verbatim from report 05 §3 — do not re-derive**),
  the predicate (~10 lines), the two unselected forward cases, and the composition.
  **Mitigation**: the bounded witness is already proved and the `snce` half is the *cheaper* of
  the two cases (no Prior-U step at all — see the settled decision above), so the real work is one
  case. If the run overruns, the correct split is `boundedWitness` + predicate + `snce` half in
  one dispatch and the `untl` half plus composition in a second — **report the split, do not
  silently re-dispatch against the same target** (that is the churn pattern H6 exists to catch).
- **Risk (v5, LOW): the charter gap could recur.** It arose because a phase charter named one half
  of an obligation ("the real **Until** witness") and the other half was never assigned.
  **Mitigation**: Phase 7.4's `Done when` clause enumerates **both** `h_fuc` sub-obligations by
  name and the Testing & Validation section carries an explicit inventory check against
  `RestrictedParametricTruthLemma.lean:417-422`'s three coherence binders.
- **Risk (v3, MEDIUM): module placement of `limitFutureWitness_of_priorU` rests on a
  Medium-confidence import-direction claim.** `conj_mcs` lives in
  `BXCanonical/Chronicle/PointInsertion.lean`, above `Bundle/` in the import graph, while
  `limitMCSBelow_cofinal_below` lives in `Bundle/LimitMCS.lean`. The blocker research inferred the
  direction from Phase 6.1's OUTCOME note rather than from a `lake` dependency dump.
  **Mitigation**: Phase 6.2 places both new theorems in a **new chronicle-level module**, where
  both `conj_mcs` and (transitively) `Bundle/` are in scope, so the claim being wrong costs
  nothing. If the module fails to import, the fallback is `Bundle/LimitGapWitness.lean` with a
  three-line local `and`-introduction — the same move `negBoxIntrospection` made in Phase 6.1.
  Verify the import direction with one `lake build` rather than by reading files.
- **Risk (v3, LOW): the `hfc` thread.** `countermodel_dedekind_dense` becomes conditional on
  `FrameClass.Dedekind ≤ fc`. **Mitigation**: `completeness_dedekind_engine` instantiates at
  `FrameClass.Dedekind` anyway and `Dedekind ≤ Dedekind` is `by decide` (`Axioms.lean:491`).
  `consequence_completeness_dedekind_of_engine`'s pinned signature is stated at `.Dedekind` and is
  unaffected.
- **Risk: analysis paralysis on the crux.** **Mitigation**: Phases 2 and 3 landed real,
  sorry-free Lean before the crux is attempted, so the H2 formal-proof-line bar is already met
  when Phase 4 starts; and Phase 4's done-criterion is a single named lemma, not a survey.
- **Risk: literature over-reach on unverified chunks.** `goldblatt_2023_strong-completeness-real-time`
  is `unverified_conversion`; `venema_1993_since_sec01/02` have absent or null
  `provenance_fidelity`. **Mitigation**: neither may be load-bearing. The Goldblatt claim is
  used only to *close* a question in the plan's favour, never to license a proof step; any
  quotation in a Lean docstring must first be re-read against the PDF at
  `~/Projects/Literature/sources/goldblatt_2023_strong-completeness-real-time/`.
- **Risk: confusable literature ids.** `gabbay_1994_ch10` (integers chapter, `no_source_pdf`)
  ranks high in raw FTS for "Dedekind complete" alongside the correct `verified_conversion`
  `gabbay_1994_ch10_sec02`/`sec05`. **Mitigation**: check `provenance_fidelity` before citing
  any `gabbay_1994*` chunk.

### Contingency: what a documented strategic-sorry skeleton would look like (Phase 4 only)

The research report is explicit that the limit-MCS construction "should not be papered over with
a `sorry`" and that `[BLOCKED]` is the correct outcome if it resists. **This plan therefore
declares no planned strategic sorries and `plan_metadata.skeleton` is `false`.** The following
is stated so that, if the orchestrator nonetheless elects a skeleton rather than a block, the
shape is fixed in advance and an implementer never has to invent it:

- **Permitted division point**: exactly one — `limitMCS_negation_complete` (or, under fallback
  (b), `limitMCS_lindenbaum_preserves_coherence`). No other sorry is permitted anywhere.
- **Required form**: the sorry is the body of that single named lemma, tightly scoped, and
  carries the comment `-- sorry: assumes no formula oscillates arbitrarily close to r from
  below (Reynolds 1992 §5, printed p.176, no-definable-gaps); deferred because the unrestricted
  form is not available from the chronicle bundle's restricted coherence; follow-up: the
  limit-MCS negation-completeness follow-up task`.
- **Required tracking**: `sorry_inventory` entry with `strategic: true`, non-null
  `follow_up_task`, `assumption` and `why_deferred` populated per `wrap-up.md`; the dispatch
  reports `status: "implemented"` with `skeleton: true`, and `lake build` must still be green.
- **Follow-up task boundary**: the follow-up owns *only* the unrestricted no-definable-gaps
  argument for the limit set — i.e. "for every formula `A` and every `r : ℝ`, exactly one of
  `A`, `A.neg` is eventually constant on `ℚ ∩ (z, r)` for some `z < r`, given Prior-U/Prior-S in
  every Dedekind-MCS." It does **not** own the FMCS/BFMCS assembly, the coherence transport, or
  the countermodel, all of which remain in this task's Phases 5-8 and proceed against the
  sorried lemma.
- **A sorry placed anywhere other than that one lemma is a plan-unanticipated deviation** and
  must be flagged as such in the implementation summary, not silently accepted.

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 6.1 | 6 |
| 6 | 6.2 | 6.1 |
| 7 | **6.3** | **6.2** |
| 8 | **7.1′** | **6.3** |
| 9 | 7.2 | 7.1′ |
| 10 | **7.3** | **7.2** |
| 11 | **7.4** | **7.3** |
| 12 | **7.5** | **7.4 + explicit user authorization (GRANTED 2026-07-27)** |
| 13 | **7.6** | **7.5** |
| 14 | **7.7** | **7.5** (independent of 7.6 in principle; serialized — see below) |
| 15 | **7.8** | **7.6 + 7.7** |
| 16 | **7.9** | **7.8** |
| 17 | 8 | 2, 6.2, 6.3, 7.1′, 7.2, 7.3, 7.4, **and `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` + `cantor_bfmcs_dense_real_restricted_fuc` from 7.9** |

Phases within the same wave can execute in parallel. Territory contracts (H7): each phase owns
the files listed under its **Owns** line and MUST NOT edit any file owned by a concurrent phase.
Phases 1 and 2 own disjoint new files. Phases 4 and 5 own disjoint new files and are the only
declared parallel pair in the engine — **verified in v2**: Phase 5's six lemmas are statements
about `limitSetBelow` membership and the `Rat` family's own `forward_G`/`backward_H` fields, and
none of them mentions or requires maximality, so Phase 5 does not depend on Phase 4's crux.

**(v3) Waves 6-10 are deliberately serial and each is a single dispatch.** The original Phase 7.1
could in principle have run beside 6.2, but its two chronicle instances consume 6.2's discharge,
and both phases would touch the same aggregator import line; serializing costs one dispatch and
removes the only H7 conflict in the plan. Phase 7.2 is separated because its deliverable is a
*probe outcome*, not a line count, and mixing it with determined work is exactly how a probe
silently becomes an open-ended proof attempt. Phase 8 is blocked by 7.2 regardless of 7.2's
outcome — see 7.2's fallback ladder for what happens if the outcome is a refutation.

**(v5) Phases 7.3 and 7.4 are a serial pair, in that order, and neither is a probe.** The route is
determined: report 05 §3 proves the target unique (`r3_invariant_necessary`), one of the three
statements is **already proved sorry-free**, and a second is **verified to elaborate**. Framing
determined work as a probe is what invites an analysis-only dispatch, and this task has paid that
cost once already. They are not merged into one phase — 7.3 alone is ~180-220 lines and 7.4 is
~200-240, and H8 bounds each phase to one agent run — and they own different files: 7.3 owns a new
module (`ChronicleLimitGuardAbove.lean`) plus an aggregator import line; 7.4 owns
`ChronicleRealExtension.lean` plus a **predicate-definition-only** append to
`Bundle/RealExtensionBundle.lean`. The H7 territory contract is clean.

**(v6) The R3d block — Phases 7.5, 7.6, 7.7, 7.8, 7.9 — is authorized, decomposed, and
dispatchable in heading order.** v5's `[USER GATED]` quarantine is retired: the gate was resolved
by fresh explicit user authorization, Amendments 2-4 are **applied**, and every sub-phase carries a
standard marker. Five properties of the split, each deliberate:

1. **Risk-first.** 7.5 states the invariant and proves the **payoff** implication (invariant ⟹
   `LimitGuardEventual`) plus the family-`Q` exclusion check, and it **touches no construction
   file**. If the invariant does not deliver the predicate, or turns out to be vacuous, or fails to
   exclude `Q`, that is discovered for one agent run instead of four — and before anything edits a
   3,622-line file. This is the same discipline that put the `D := ℝ` probe at Phase 1 and the
   crux at Phase 4.
2. **One walk per sub-phase.** `c5_forward_walk` (`CounterexampleElimination.lean:690`) and
   `c5_backward_walk` (`:1295`) are each a three-case induction over Burgess's own case split, and
   each is one agent run. They are `private`, so the preservation property must be carried as a
   **field of the walk's result structure** and discharged inside the file — there is no external
   lemma option. 7.6 owns the forward walk and `C5ForwardWalkResult` (`:646`); 7.7 owns the
   backward walk and `C5BackwardWalkResult` (`:1254`).
3. **Every sub-phase ends green.** Adding a field to a structure that a `def` *produces* leaves
   every consumer building unchanged, so 7.6 and 7.7 each end with a full green `lake build` and no
   new sorry. The composition into `EliminationResult` (`:580`) and the ω-chain subtype
   (`ChronicleConstruction.lean:262`) is 7.8's job precisely so that no sub-phase has to stub a
   field it cannot yet discharge. **No sub-phase may end RED and none may `sorry` a field.**
4. **Serial, not parallel.** 7.6 and 7.7 are in principle independent — different structures,
   different line ranges — but they are serialized because they share one file, and an H7 territory
   contract that splits a single 3,622-line file between two concurrent dispatches is a merge
   hazard for no gain. 7.8 needs both.
5. **The seam between logic and construction is at 7.5/7.6.** 7.5 is the last sub-phase that is
   pure `Bundle`-and-limit reasoning; 7.6 onward is construction surgery under Amendment 2. A
   dispatch that finds itself editing `CounterexampleElimination.lean` during 7.5 has crossed a
   territory line.

**(v6) The R3d block is a rollback unit.** If Outcome B fires (see the risk register), the block is
abandoned at whatever sub-phase blocked, the landed sub-phases stay landed, and the task's floor is
`[PARTIAL]`. Phases 1-7.4 are untouched by any R3d rollback.

**(v4) Phases 6.3 and 7.1′ are a serial pair, in that order, and neither is a probe.** 6.3 lands
the guard gap lemma, the predicate and the chronicle discharge; 7.1′ consumes all three plus the
seven declarations the Phase 7.1 dispatch already landed. They are *not* merged into one phase:
6.3 alone is ~180-220 lines and 7.1′ is ~140-180, and H8 bounds each phase to one agent run. They
own different files — 6.3 owns a new module plus the predicate's home in
`Bundle/RealExtensionBundle.lean`; 7.1′ owns `ChronicleRealExtension.lean` — so the H7 territory
contract is clean. **Phase 7.2's charter is not widened by either**, and its dependency is
re-pointed at 7.1′ with no other change.

---

### Phase 1: D := ℝ instantiation probe and the Dedekind box-dense branch lemma [COMPLETED]

- **Goal:** De-risk the entire route with one build, and land the mechanical half of the
  Dedekind completeness branch structure.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (new),
  `FormalSystem/Metalogic/BXCanonical.lean` (import line only).
- **Tasks:**
  - [x] Re-run report 390's probe as a scratch `example`: confirm
        `ParametricCanonicalTaskFrame (fc := fc) ℝ` and
        `ParametricCanonicalTaskModel (fc := fc) ℝ` elaborate with zero errors.
        *(deviation: altered — the probes were landed as permanent `noncomputable example`s in
        the module's `CarrierProbe` section rather than discarded scratch, so a future binder
        regression fails the build. `noncomputable` is required because `Real.linearOrder` is
        noncomputable; this is a codegen annotation, not an elaboration weakening.)*
  - [x] Extend the probe: confirm
        `fully_restricted_parametric_completeness_from_neg_membership` typechecks at `D := ℝ`
        against a hypothesised `(B : BFMCS (fc := fc) ℝ)`. Record the exact goal state if it
        does not. *(PASSED — elaborated on the first attempt with no binder failure.)*
  - [x] Confirm `ℝ` discharges every binder of `ValidDedekindDense` (`Validity.lean:255-262`):
        `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `DenselyOrdered`, `Nontrivial`,
        and the lub hypothesis via `Real.instConditionallyCompleteLinearOrder`. Land this as a
        named sorry-free lemma `real_lub_of_bddAbove`, not as a comment.
  - [x] Create `CompletenessDedekind.lean` and land `dedekind_box_dense_mem`: for any
        `A` with `SetMaximalConsistent (fc := FrameClass.Dedekind) A`,
        `Chronicle.nextTop.neg.box ∈ A`. Transcribe the non-dense branch of `completeness_dense`
        (`Completeness.lean:268-276`) with `.Dense` replaced by `.Dedekind`; admissibility holds
        because `Axiom.dense_indicator.minFrameClass = .Dense` and
        `FrameClass.Dense ≤ FrameClass.Dedekind`.
  - [x] Module docstring cites Reynolds 1992 §1, printed p.169 (definably-Dedekind-complete
        scoping) by PDF page.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.CompletenessDedekind`.
- **Estimated output:** ~120 lines.
- **Done when:** the module builds sorry-free; `dedekind_box_dense_mem` and
  `real_lub_of_bddAbove` are proved; the probe outcome (pass or exact failure) is recorded in the
  handoff. **If the probe fails, stop and mark this phase `[BLOCKED]` — do not proceed to any
  later phase.**
- **Timing:** 2 hours.
- **Depends on:** none
- **v2 ripple:** unaffected. Nothing in this phase mentions the limit set or the extension shape.

### Phase 2: SemanticConsequenceDedekindDense, the semantic deduction lemma, and the terminus statement [COMPLETED]

- **Goal:** Land `consequence_completeness_dedekind` — the task's terminus — **with the
  single-formula engine as an explicit hypothesis**, so the target is fixed and sorry-free
  before any engine work begins.
- **Owns:** `FormalSystem/Metalogic/StrongCompleteness.lean` (new),
  `FormalSystem/Metalogic.lean` (import line only).
- **Tasks:**
  - [x] Define `SemanticConsequenceDedekindDense (Γ : Context) (φ : Formula) : Prop` by taking
        the binder list of `ValidDedekindDense` (`Validity.lean:255-262`) verbatim and adding
        the hypothesis `(∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) →` before the conclusion. This is
        exactly the hypothesis-and-conclusion shape of `soundness_dedekind`
        (`Soundness.lean:1910`) packaged as a definition. Do not reuse `SemanticConsequence`
        (`Validity.lean:103`) — it quantifies over all `D` and cannot express Dedekind-class
        consequence.
  - [x] Prove `semantic_deduction_dedekind_dense (Γ : Context) (φ : Formula) :
        SemanticConsequenceDedekindDense Γ φ ↔ ValidDedekindDense (Γ.foldr Formula.imp φ)`.
        Induction on the list against `Truth.lean:132`
        (`TruthAt … (φ.imp ψ) = (TruthAt … φ → TruthAt … ψ)`). No frame-condition reasoning
        enters. *(deviation: altered — the list induction was factored out into a reusable
        pointwise lemma `truthAt_foldr_imp`, stated at the bare `TaskModel` binder set with no
        Dedekind hypotheses, so the Base/Dense/Discrete sections can reuse it verbatim; the
        named iff is then two transports of it. No frame-condition reasoning enters, as
        specified.)*
  - [x] Prove `consequence_completeness_dedekind_of_engine`: given
        `(engine : ∀ ψ, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)`, conclude
        `SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, via the
        deduction lemma plus iterated `Derivable.deduction` / `deductionConverse`
        (`DeductionTheorem.lean:447,467`), both already generic in `fc`.
        *(deviation: altered — the iteration was factored into the `fc`-generic pair
        `derivable_of_derivable_foldr_imp` / `derivable_foldr_imp_of_derivable` and packaged as
        `derivable_foldr_imp_iff`, so the terminus is a two-line composition. Each
        `deductionConverse` step needs a membership-based `Derivable.weaken` to permute the
        accumulated heads back into order, since the converse pushes formulas onto the front in
        reverse.)*
  - [x] Two additions beyond the phase task list, both anti-drift guards, both sorry-free:
        `soundness_dedekind_consequence` (`Derivable .Dedekind Γ φ → SemanticConsequenceDedekindDense Γ φ`,
        proving the new relation is exactly the conclusion block of `soundness_dedekind`, hence
        that the terminus is non-vacuous) and `completeness_dedekind_of_engine` (weak
        completeness exhibited as the `Γ = []` instance, so the weak form has exactly one proof
        in the tree and it is a corollary — consistent with the Postmortem Constraint against
        proving `completeness_dedekind` independently). These require importing
        `FormalSystem.Metalogic.Soundness` into the new module; no import cycle, since
        `Soundness.lean` does not import `StrongCompleteness`.
  - [x] Structure the file with named sections so the Base / Dense / Discrete instances of the
        same shape drop in later without restructuring. Header comments only — **no `sorry`,
        no vacuous definitions, no placeholder declarations** for those three classes.
  - [x] Module docstring: record (i) that the terminus is the finite-context consequence form
        and weak completeness is its `Γ = []` instance — and, per the concurrent terminology
        reframing, that neither is "strong completeness", which is reserved for infinite premise
        sets and is unavailable for this class; (ii) that Reynolds' Theorem 7 (§9, printed
        p.189) is *weak* and that the restriction is genuine; (iii) the Goldblatt point — propositional
        temporal logic over `(ℝ,<)` is finitely axiomatizable (Bull), and Scott's
        non-axiomatizability result is first-order — marked `[UNVERIFIED - unverified_conversion]`
        and re-read against the PDF before the quotation is committed. *(deviation: altered —
        no quotation was committed. `literature-search.sh` returned `degraded: true` with zero
        results for the Bull/Scott query and an empty TOC for `goldblatt_2023`, so the source
        could not be re-read. The docstring states the point as paraphrase, records that the
        corpus search found nothing to corroborate it, and notes explicitly that no declaration
        in the file depends on it.)*
  - [x] `lake build FormalSystem.Metalogic.StrongCompleteness`.
- **Estimated output:** ~200 lines.
- **Done when:** all three declarations are sorry-free and the module builds. The terminus
  statement exists in the tree from this point on.
- **Timing:** 3 hours.
- **Depends on:** none
- **v2 ripple:** unaffected. `consequence_completeness_dedekind_of_engine` takes the engine as an
  opaque hypothesis and knows nothing about the carrier, the limit set, or the extension shape.
  Its signature is **pinned** (commit `bd9ae0ac1`); Phase 8 instantiates it unchanged.

### Phase 3: The limit set — definition and consistency [COMPLETED]

- **Goal:** Define the limit-MCS candidate at a real point and prove it consistent.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **Status note (v2):** the phase's genuine role in the route — *a defined candidate set at an
  arbitrary real point, plus its consistency* — is fully discharged by what landed. Ten
  declarations are sorry-free and the module builds. v1's fourth task was a **false** step, not
  a missing one: rational agreement is unobtainable as a lemma (see Revision Rationale), and the
  property it was reaching for is now obtained by construction in Phase 6. Nothing real remains
  outstanding in this phase, so it is `[COMPLETED]` rather than `[PARTIAL]`, and v1's inline
  BLOCKER block is retired into the Revision Rationale and the module docstring.
- **Tasks:**
  - [x] Define `limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
        {A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q:ℝ) → (q:ℝ) < r → A ∈ m q}` — "eventually true
        approaching `r` from below". Define the dual `limitSetAbove` for the past side.
        *(Landed verbatim as specified; `limitSetAbove` uses the mirrored witness `r < z`.)*
  - [x] Prove `limitSetBelow_mono_directed` and its dual `limitSetAbove_mono_directed`: the
        defining family of witness intervals is directed, so any finite list of members shares a
        single threshold. List induction taking `max` (resp. `min`) of thresholds at each cons
        step; the empty list is witnessed by `r - 1` (resp. `r + 1`).
  - [x] Prove `limitSetBelow_finite_subset_mem` and its dual `limitSetAbove_finite_subset_mem`:
        every finite list drawn from the limit set is contained in a **single** `m q`.
        Directedness supplies the common threshold and `exists_rat_btwn` supplies the rational.
        *(This was factored out of v1's consistency task as its own named lemma because Phases 6
        and 7 need the common-witness rational itself, not merely the consistency conclusion.)*
  - [x] Prove `limitSetBelow_consistent` and its dual `limitSetAbove_consistent`: given
        `∀ q, SetMaximalConsistent (fc := fc) (m q)`, conclude
        `SetConsistent (fc := fc) (limitSetBelow m r)`. `SetConsistent`
        (`Core/MaximalConsistent.lean`) is a property of finite subsets, so this is one line
        from the previous task.
  - [x] Prove `limitSetBelow_of_rat` and its dual `limitSetAbove_of_rat` — the coherence
        transfer that is actually available at a rational point:
        `allPast A ∈ m q → A ∈ limitSetBelow m (q:ℝ)` (consumes `backward_H`) and
        `allFuture A ∈ m q → A ∈ limitSetAbove m (q:ℝ)` (consumes `forward_G`). The coherence
        field is taken as an **explicit hypothesis**, so the lemma is usable before the
        real-carrier family is assembled.
        *(This replaces v1's false "the limit set agrees with `m q` on membership".
        `limitSetBelow_of_rat` as landed is the `t = (q:ℝ)` special case of Phase 5's
        `limitSetBelow_backward_H_rat_source`; Phase 5 should **generalize** it in place rather
        than duplicate it, and must not delete it.)*
  - [x] Record the counterexample in the module docstring: both inclusions of the agreement
        claim fail, `forward_G`/`backward_H` are strict, and `allPast` is the strict past
        operator, so there is no `H φ → φ` to appeal to. State that consumers needing genuine
        agreement at rational points must select `m q` directly.
  - [x] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~200 lines. *(Actual: 223 lines, 10 declarations, sorry-free.)*
- **Done when:** the definitions, directedness, finite-subset containment, consistency, and the
  available coherence transfers are all sorry-free and the module builds.
- **Timing:** 4 hours.
- **Depends on:** 1

### Phase 4: Negation-completeness of the limit set via Prior-U / Prior-S [COMPLETED]

**This is the crux and the only legitimate `[BLOCKED]` point in the plan. It is new
mathematics, argued from Reynolds' no-definable-gaps lemma rather than transcribed from it.**

> **(v3) COMPLETED — NOT A LIVE PHASE.** v2's two `limitMCS_no_oscillation` bullets have been
> **deleted from the task list below**: the step was refuted during implementation and the
> refutation now lives only in the Phase 4 OUTCOME block, where it remains fully auditable. No
> phase of v3 asks for that lemma and the Postmortem Constraints forbid re-deriving it.
> The refutation is scoped to applying Prior-U **at the `φ` level**; v3's Phase 6.2 applies it at
> the `someFuture φ` level, which is a different statement whose antecedent *is* available. Do
> not read the two verdicts as a contradiction and do not reopen this phase.

- **Goal:** Turn `limitSetBelow m r` into a genuine maximal consistent set.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (extends Phase 3's file).
- **v2 ripple: statements unaffected; one scope reduction.** The crux is a statement about
  `limitSetBelow m r` at a fixed real `r`, with no appeal to rational agreement and no
  dependence on the extension's shape, so rational selection changes nothing here. It does
  **not** narrow the range of `r`: because each family carries its own real offset `δ`, the set
  of unselected points varies with `δ` and their union is all of `ℝ`, so maximality must be
  proved at an arbitrary real. The one genuine reduction is that **the past dual is no longer
  load-bearing** — the extension uses `limitSetBelow` for both `forward_G` and `backward_H`
  (verified case-by-case in Phase 5), so `limitSetAbove_is_mcs` is not required by the route.
- **Tasks:**
  - [x] Re-read Reynolds 1992 §5, printed p.176 (chunk `reynolds_1992_sec06`) verbatim before
        writing anything: the `γ⁺` definition, the Prior-structure definition, and the one-line
        Prior-U contradiction. Cite by PDF page in the docstring.
  - *(v3: two bullets removed from this checklist.* v2 asked here for a lemma named
        `limitMCS_no_oscillation` — "for every `A` and `r` there is `z < r` such that `A`, or
        `A.neg`, belongs to `m q` for all rational `q ∈ (z, r)`" — and for its proof from
        `Axiom.prior_U_gap`. The implementation dispatch **refuted** the statement at the level of
        the cited source and skipped both bullets; the refutation is preserved in full in the
        Phase 4 OUTCOME block below, which is now its only home. They are deleted from the task
        list so that no dispatch can read an unchecked box as pending work. **No phase of v3 asks
        for that lemma**, and the Postmortem Constraints forbid re-deriving it.)*
  - [ ] Prove `limitSetBelow_negation_complete`, then
        `limitSetBelow_is_mcs : SetMaximalConsistent (fc := fc) (limitSetBelow m r)`.
        *(deviation: altered — `limitSetBelow` is not negation-complete, so maximality is
        obtained by extension: `limitMCSBelow_is_mcs` together with
        `limitSetBelow_subset_limitMCSBelow`.)*
  - [x] **Fallback, if and only if the unrestricted form fails**: switch to consistency +
        `set_lindenbaum` (Risks, mitigation (b)) and state in the module docstring which route
        was taken and why. Do not silently switch. **(v2)** Before electing (b), read the v2
        sharpening in Risks: it forces Phase 5's six lemmas and Phase 6's `forward_G`/
        `backward_H` to be restated for the chosen extension. Report that cost in the handoff.
        *(deviation: altered — mitigation (b) elected and landed as `limitMCSLindenbaum` /
        `limitMCSLindenbaum_is_mcs`, plus an additional **coherence-preserving refinement** of
        (b), `limitMCSBelow`, which is the ultrafilter limit of `m` along the
        left-neighbourhood filter of `r`. The refinement is the same move as (b) — extend the
        consistent limit set to an MCS — with a canonical rather than arbitrary extension, and
        it repairs the v2 sharpening's cost: `limitMCSBelow_cofinal_below` restores the descent
        handle that an arbitrary Lindenbaum extension destroys. Route election and the
        refutation of (a) are recorded in the module docstring.)*
  - [x] Add a named corollary `fc_theorem_true_in_parametric_model` — "every `fc`-theorem is
        true at every point of the parametric canonical model" — as the one-line composition of
        `theorem_in_mcs` with `parametric_shifted_truth_lemma.mp`
        (`ParametricTruthLemma.lean:379`). It does not exist today and is load-bearing: it is how
        Prior-U/Prior-S get from MCS membership to model truth.
        *(deviation: altered — composed with `fully_restricted_parametric_shifted_truth_lemma`
        (`RestrictedParametricTruthLemma.lean:286`) instead. `parametric_shifted_truth_lemma`
        is stated at `BFMCS D`, whose `fc` defaults to `FrameClass.Base`, so it is **not**
        `fc`-generic and cannot be used at `FrameClass.Dedekind`; it also demands unrestricted
        Until/Since coherence. The corollary therefore carries the extra hypothesis
        `h_sub : φ ∈ subformulaClosure root`. See the Preserved-Assets correction below.)*
  - [x] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~250 lines. *(Actual: +190 lines, 14 new declarations, sorry-free.)*
- **Done when:** `limitSetBelow_is_mcs` is proved sorry-free at an arbitrary real `r`, **or** the
  phase is marked `[BLOCKED]` with the exact goal state, the tactic attempts made, and which of
  mitigations (a)/(b) were tried. The `limitSetAbove` dual is **not** required; prove it only if
  it falls out for free. Do not report success on a `sorry` unless the contingency in Risks was
  explicitly elected by the orchestrator.

**PHASE 4 OUTCOME (recorded at implementation time)**

Mitigation (b) elected, in its ultrafilter-limit form. No sorry was taken; the contingency in
Risks was **not** exercised, and the live sorry count outside `Boneyard/` is unchanged at
exactly `WeakCanonical/Transfer.lean:1242`.

*Mitigation (a) is refuted, not merely hard.* The refutation is at the level of the cited
source, so no further attempt **at the `φ` level** is warranted *(v3 narrowing: the original text
read "no further attempt is warranted" without qualification. The blocker research established
that the refutation below is a statement about applying Prior-U to `A := φ`, whose truth region
below a gap need not be an interval. Applied to `A := Formula.someFuture φ`, whose region below
the gap is the interval `(-∞, sup S_φ)`, the antecedent the refutation correctly identifies as
missing is supplied — that is Phase 6.2, and it does not disturb anything below)*: 

- Reynolds (1992, §5, printed p.176) defines `γ⁺(A)` to hold "exactly when `A` remains true for
  a while after now but only up until a gap after which `A` is arbitrarily soon false", and a
  definable gap is one where some `γ⁺(A)` holds. The hypothesis already requires `A` to be
  **constantly true on an interval abutting the gap**.
- `Axiom.prior_U_gap` (`ProofSystem/Axioms.lean:377`) encodes exactly that: its antecedent is
  `U(⊤, φ) ∧ F(¬φ)`, and `U(⊤, φ)` asserts `φ` throughout an initial future segment.
- Negation-completeness of `limitSetBelow m r` asserts that **every** formula is eventually
  constant on the rationals below `r`. A formula whose membership pattern is dense and co-dense
  in every left neighbourhood of `r` refutes it while making every Prior-U instance vacuous.
  "No definable gaps" is therefore strictly weaker than what the phase task asked to derive
  from it, and cannot yield it. `limitMCS_no_oscillation` as stated in the task list is false.
- Independently: Prior-U/Prior-S are `untl`/`snce` statements, and converting a Prior instance
  in `m q` into a fact at other rationals needs Until/Since coherence for `m`, which is not a
  hypothesis at this level and which the chronicle supplies only in *Restricted* form.

*Cost of (b), as the v2 sharpening requires reporting.* The bare Lindenbaum form
(`limitMCSLindenbaum`) does carry the predicted cost — a membership at an unselected point has
no descent path back to `m q`. The ultrafilter refinement `limitMCSBelow` removes that cost:
`limitMCSBelow_cofinal_below` states that every member of `limitMCSBelow m r` lies in `m q` for
rationals `q` arbitrarily close below `r`, which is exactly the handle Phase 5's
unselected-source cases need. **Phases 5 and 6 must therefore use `limitMCSBelow`, not
`limitMCSLindenbaum`, and not `limitSetBelow` alone.** Phase 5's six lemmas remain stated about
`limitSetBelow` (they are unchanged, since `limitSetBelow ⊆ limitMCSBelow`), but each
unselected-**source** case now routes through `limitMCSBelow_cofinal_below` rather than
directly unfolding a `limitSetBelow` witness.

*Preserved-Assets correction.* The Preserved Assets table lists
`ParametricCanonical / ParametricHistory / ParametricTruthLemma:240,379` as "generic in `D` and
`fc`". For `parametric_shifted_truth_lemma` (`ParametricTruthLemma.lean:379`) that is
**inaccurate**: it is stated at `BFMCS D` with `fc` at its default `FrameClass.Base`. The
`fc`-generic route is `RestrictedParametricTruthLemma.lean:286`
(`fully_restricted_parametric_shifted_truth_lemma`), which is what
`fc_theorem_true_in_parametric_model` composes with. Nothing was edited in either file.
- **Timing:** 6 hours.
- **Depends on:** 3

### Phase 5: forward_G and backward_H across the rational/limit case matrix [COMPLETED]

- **Goal:** Prove the two temporal-coherence properties as standalone lemmas that do not
  presuppose maximality, so this phase runs in parallel with the crux.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only — coordinate with Phase 3's edit).
- **v2 ripple: AFFECTED — statements restated.** The Phase 3 dispatch asserted this phase was
  unaffected; that is **refuted**. v1's `limitSet_forward_G` / `limitSet_backward_H` state only
  the limit-to-limit case. Under rational selection the extension's value at a point is `m q`
  (selected) or `limitSetBelow m x` (unselected), so `forward_G` and `backward_H` each face a
  2×2 matrix of source/target kinds. v1's prose said "four cases" but its *lemma statements*
  covered one. Below, each of the six non-trivial cases is a separately named lemma. The
  parallelism with Phase 4 is preserved and **verified**: none of the six mentions maximality.
- **Note on the offset `δ`.** Phase 6's families carry a real offset. The offset is absorbed by
  `add_lt_add_right`, so every lemma here is stated **without** `δ`, at bare real arguments.
- **Tasks:**
  - [x] `limitSetBelow_forward_G_rat_source` (case G1, selected → unselected): for `q : Rat`
        and `t : ℝ` with `(q:ℝ) < t`, `Formula.allFuture φ ∈ m q → φ ∈ limitSetBelow m t`.
        Witness threshold `z := (q:ℝ)`; every rational `p ∈ (q, t)` satisfies `q < p`, so the
        rational family's own `forward_G` (`FMCSDef.lean:114`) delivers `φ ∈ m p`.
  - [x] `limitSetBelow_forward_G_rat_target` (case G2, unselected → selected): for `s : ℝ` and
        `p : Rat` with `s < (p:ℝ)`, `Formula.allFuture φ ∈ limitSetBelow m s → φ ∈ m p`.
        Take the membership's threshold `z < s`, pick `q ∈ (z, s)` rational by
        `exists_rat_btwn`, then `q < s < p` and `forward_G` applies.
  - [x] Case G3 (selected → selected) needs **no new lemma**: it is the rational family's
        `forward_G` field verbatim, modulo `Rat.cast_lt`. Record this in the module docstring so
        Phase 6 does not go looking for a lemma that deliberately does not exist.
        *(Recorded in `LimitMCSCoherence.lean`'s "The two cases with no lemma" section, together
        with H3, including the explicit instruction not to search for `..._forward_G_rat_rat`.)*
  - [x] `limitSetBelow_forward_G_limit` (case G4, unselected → unselected): for `s < t` in `ℝ`,
        `Formula.allFuture φ ∈ limitSetBelow m s → φ ∈ limitSetBelow m t`. Pick a rational
        `q₀ ∈ (z, s)`; then `q₀` itself is a valid threshold for `t`, since every rational
        `p ∈ (q₀, t)` satisfies `q₀ < p`. *(This is v1's `limitSet_forward_G`.)*
  - [x] `limitSetBelow_backward_H_rat_source` (case H1, selected → unselected): for `q : Rat`
        and `t : ℝ` with `t < (q:ℝ)`, `Formula.allPast φ ∈ m q → φ ∈ limitSetBelow m t`.
        Threshold `z := t - 1`; every rational `p < t < q` satisfies `p < q`, so `backward_H`
        (`FMCSDef.lean:121`) applies. **Generalize Phase 3's `limitSetBelow_of_rat` into this
        lemma in place** — it is exactly the `t = (q:ℝ)` instance. Do not delete it; re-derive
        it as a one-line corollary if it has other consumers.
        *(deviation: altered — stated with `t ≤ (q:ℝ)` rather than `t < (q:ℝ)`. The two halves of
        this bullet are unsatisfiable together under the strict form: `t = (q:ℝ)` is not an
        instance of `t < (q:ℝ)`, so no strict-form lemma generalizes `limitSetBelow_of_rat` "in
        place". The `≤` form makes both halves literally true — it covers case H1 and has
        `limitSetBelow_of_rat` as its `t = (q:ℝ)` instance. The instantiation is exhibited as
        `limitSetBelow_of_rat_of_backward_H_rat_source`. Phase 3's `limitSetBelow_of_rat` is
        left byte-identical (it has no consumers outside its own module). Downstream cost: none
        — Phase 6 passes `le_of_lt` at case H1. The `forward_G` mirror admits no such widening
        and is stated strictly, as the plan specifies; the asymmetry is recorded in the module
        docstring.)*
  - [x] `limitSetBelow_backward_H_rat_target` (case H2, unselected → selected): for `s : ℝ` and
        `p : Rat` with `(p:ℝ) < s`, `Formula.allPast φ ∈ limitSetBelow m s → φ ∈ m p`. The
        rational must be picked above **both** thresholds: `max z (p:ℝ) < s` because `z < s` and
        `p < s`, so `exists_rat_btwn` on `(max z p, s)` yields `q` with `allPast φ ∈ m q` and
        `p < q`.
  - [x] `limitSetBelow_backward_H_limit` (case H4, unselected → unselected): for `t < s` in `ℝ`,
        `Formula.allPast φ ∈ limitSetBelow m s → φ ∈ limitSetBelow m t`. Pick a rational
        `q₀ ∈ (max z t, s)`; then `t < q₀`, and `t - 1` is a valid threshold for `t` since every
        rational `p < t` satisfies `p < q₀`. *(This is v1's `limitSet_backward_H`.)*
  - [x] Case H3 (selected → selected) needs no new lemma; same note as G3.
  - [x] State every `exists_rat_btwn` interpolation as its own `have` so the case analysis stays
        reviewable, and state each `max`-based bound as its own `have` for the same reason.
  - [x] `limitSetAbove` plays **no role** in this phase. Do not prove above-side duals; the
        extension uses the below-limit for both temporal directions, and the Phase 3 above-side
        lemmas remain standing but unused assets.
        *(Honoured: no above-side lemma was written; recorded in the module docstring.)*
  - [x] `lake build FormalSystem.Metalogic.Bundle.LimitMCSCoherence`.
- **Estimated output:** ~260 lines. *(Actual: 225 lines, 7 declarations, sorry-free.)*
- **Done when:** all six lemmas are proved sorry-free, the two no-lemma cases are documented,
  and the module builds.
- **Timing:** 5 hours.
- **Depends on:** 3

**PHASE 5 OUTCOME (recorded at implementation time)**

All six lemmas landed sorry-free in `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean`; G3
and H3 are documented as deliberately lemma-free. Full `lake build` green (1895 jobs); live
sorries outside `Boneyard/` unchanged at exactly `WeakCanonical/Transfer.lean:1242`; each of the
seven declarations has axioms exactly `[propext, Classical.choice, Quot.sound]`.

*The Phase 4 route election cost this phase nothing.* Phase 4's handoff predicted that
unselected-**source** cases (G2, G4, H2, H4) would have to route through
`limitMCSBelow_cofinal_below` instead of unfolding a `limitSetBelow` witness. That prediction
does not bite at this layer: all six lemmas are stated with `limitSetBelow` on **both** sides,
as the plan specifies, and an unselected-source hypothesis is therefore a `limitSetBelow`
membership, which still unfolds directly to its threshold witness. `limitMCSBelow` is not
mentioned in this module and `limitMCSBelow_cofinal_below` was not needed.

**This does not discharge the Phase 4 correction — it relocates it to Phase 6.** Phase 6's
`realLimitMCS` takes `limitMCSBelow m (x + δ)` at unselected points (so that `FMCS.is_mcs` is
discharged by `limitMCSBelow_is_mcs`), *not* `limitSetBelow m (x + δ)`. The six lemmas below are
therefore **not** directly composable at unselected points: each needs its hypothesis weakened
from `limitSetBelow` to `limitMCSBelow` and its conclusion strengthened likewise. The two
directions are not symmetric and Phase 6 must budget for both:

- **Conclusion side (target unselected: G1, G4, H1, H4)** is free —
  `limitSetBelow_subset_limitMCSBelow` (`Bundle/LimitMCS.lean`) upgrades the conclusion in one
  step.
- **Hypothesis side (source unselected: G2, G4, H2, H4)** is the real obligation, but all four
  transpose, and the transposition was checked against the actual signature rather than inferred.
  `limitMCSBelow_cofinal_below` (`Bundle/LimitMCS.lean`) reads
  `(hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) : ∃ q : Rat, z < (q:ℝ) ∧ (q:ℝ) < r ∧ A ∈ m q`
  — the threshold `z` is a **parameter**, not an output. So the caller chooses it, and each of
  the four proofs below is the corresponding proof here with its `obtain ⟨z, hz, hmem⟩` step
  replaced by one cofinality call at a chosen `z`. The `max`-based bounds disappear entirely,
  because the bound that the `max` was there to clear can simply be passed as `z`:
  - G2 variant: pass `z := s - 1`; get `q < s < p`, then `forward_G`.
  - G4 variant: pass `z := s - 1`; the returned `q₀ < s < t` is the threshold at `t`.
  - H2 variant: pass `z := (p : ℝ)` (legal since `(p:ℝ) < s`); get `p < q < s` directly, then
    `backward_H`. No `max` needed.
  - H4 variant: pass `z := t` (legal since `t < s`); get `t < q₀ < s`, then `t - 1` is the
    threshold at `t`. No `max` needed.
  **Phase 6 should therefore expect four short `limitMCSBelow`-source variants**, each a
  composition of `limitMCSBelow_cofinal_below` with the family's coherence field, rather than a
  reproof — and should add them to `LimitMCSCoherence.lean` rather than inlining them into
  `RealExtension.lean`.

This phase did not write those four variants: the plan's task list for Phase 5 names exactly six
lemmas, all stated about `limitSetBelow`, and this dispatch's mandate was Phase 5 only.

### Phase 6: The FMCS real extension by rational selection [COMPLETED]

- **Goal:** Assemble `FMCS (fc := fc) Rat → FMCS (fc := fc) ℝ` under rational selection, with
  its three fields discharged across the case matrix.
- **Owns:** `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **v2 ripple: REWRITTEN.** v1 defined `mcs := limitSetBelow f.mcs`, a one-sided limit at every
  real point including the rationals, and depended on the false agreement lemma to make the
  extension *extend* rather than *replace*. v2 selects `m q` directly at selected points, which
  makes agreement definitional, and carries a real offset `δ` from the start because Phase 6.1's
  `modal_backward` needs the family set closed under real shifts.
- **Tasks:**
  - [x] Define `realLimitMCS (m : Rat → Set Formula) (δ : ℝ) : ℝ → Set Formula := fun x =>
        if h : ∃ q : Rat, (q:ℝ) = x + δ then m h.choose else limitSetBelow m (x + δ)`.
        This is `noncomputable` and needs `open Classical` (or `by classical`) for the
        `Decidable` instance on the existential. **Do not** attempt a computable variant.
        *(deviation: altered — the unselected branch is `limitMCSBelow m (x + δ)`, the
        ultrafilter limit, not `limitSetBelow m (x + δ)`. Forced: `limitSetBelow` is consistent
        but not negation-complete, so it cannot discharge `FMCS.is_mcs`; `limitMCSBelow_is_mcs`
        can. This is the Phase 4 route election arriving where Phase 5's OUTCOME block said it
        would arrive. `by classical` was used for the `Decidable` instance.)*
  - [x] Prove the selection lemma `realLimitMCS_of_rat (h : (q:ℝ) = x + δ) :
        realLimitMCS m δ x = m q`. `dif_pos` gives `m h'.choose`; `h'.choose_spec` and the
        hypothesis both cast to `x + δ`, so `Rat.cast_injective` identifies `h'.choose = q`.
        **This lemma is the entire point of the revision** — it is the definitional replacement
        for the false `limitSetBelow_of_rat` agreement claim.
  - [x] Prove `realLimitMCS_of_not_rat (h : ¬ ∃ q : Rat, (q:ℝ) = x + δ) :
        realLimitMCS m δ x = limitSetBelow m (x + δ)` (`dif_neg`).
        *(deviation: altered — conclusion is `limitMCSBelow m (x + δ)`, per the definition
        change above.)*
  - [x] Prove `realLimitMCS_is_mcs`: case split on the selection condition. Selected points use
        the rational family's `is_mcs`; unselected points use Phase 4's `limitSetBelow_is_mcs`.
        *(deviation: altered — unselected points use `limitMCSBelow_is_mcs`. There is no
        `limitSetBelow_is_mcs` in the tree and there cannot be: `limitSetBelow` is not
        negation-complete, which is the whole reason Phase 4 built the ultrafilter limit.)*
  - [x] Prove `realLimitMCS_forward_G`: for `x < y` in `ℝ`, `allFuture φ ∈ realLimitMCS m δ x →
        φ ∈ realLimitMCS m δ y`. **Four cases**, on whether `x + δ` and `y + δ` are selected:
        - selected/selected → the rational family's `forward_G` field (Phase 5, case G3);
        - selected/unselected → `limitSetBelow_forward_G_rat_source` (G1);
        - unselected/selected → `limitSetBelow_forward_G_rat_target` (G2);
        - unselected/unselected → `limitSetBelow_forward_G_limit` (G4).
        In every case the order hypothesis transports by `add_lt_add_right … δ`; state that
        transport once as a `have` and reuse it.
        *(deviations: altered ×2. (i) The unselected-source cases G2 and G4 consume the
        `limitMCSBelow`-source variants `limitMCSBelow_forward_G_rat_target` and
        `limitMCSBelow_forward_G_limit`, added to `LimitMCSCoherence.lean` by this phase per
        Phase 5's OUTCOME recipe, not the `limitSetBelow`-source lemmas named here — the
        hypothesis at an unselected source is now an ultrafilter membership. (ii) The transport
        is `by linarith`, not `add_lt_add_right hxy δ`: in this Mathlib `add_lt_add_right`
        resolves to the left-addition form `δ + x < δ + y`, a genuine type mismatch against the
        needed `x + δ < y + δ`.)*
  - [x] Prove `realLimitMCS_backward_H` by the mirrored four-case split, consuming
        `limitSetBelow_backward_H_rat_source` (H1), `_rat_target` (H2), `_limit` (H4), and the
        rational family's `backward_H` field (H3).
        *(deviation: altered — H2 and H4 consume `limitMCSBelow_backward_H_rat_target` and
        `limitMCSBelow_backward_H_limit`, for the same reason as G2/G4. H1 is consumed as
        specified, with `le_of_lt` supplying its non-strict `t ≤ (q:ℝ)` hypothesis exactly as
        Phase 5's deviation note predicted.)*
  - [x] Bundle these into `FMCS.toRealShift (f : FMCS (fc := fc) Rat) (δ : ℝ) :
        FMCS (fc := fc) ℝ` with `mcs := realLimitMCS f.mcs δ` and the three fields above.
  - [x] Define `FMCS.toReal (f : FMCS (fc := fc) Rat) : FMCS (fc := fc) ℝ := f.toRealShift 0`
        and prove `FMCS.toReal_at_rat (q : Rat) : (f.toReal).mcs (q:ℝ) = f.mcs q` — the
        "extends rather than replaces" property, now a one-line corollary of
        `realLimitMCS_of_rat` with `add_zero`.
  - [x] Module docstring: state that rational selection is forced, cite the counterexample by
        naming `Bundle/LimitMCS.lean`'s docstring (**not** a task number), and record that
        `limitSetAbove` is deliberately unused on this route.
  - [x] `lake build FormalSystem.Metalogic.Bundle.RealExtension`.
- **Estimated output:** ~220 lines. *(Actual: 227 lines in `RealExtension.lean`, 9 declarations,
  plus 4 declarations / ~90 lines added to `LimitMCSCoherence.lean`. Sorry-free.)*
- **Done when:** `FMCS.toRealShift`, `FMCS.toReal`, and `FMCS.toReal_at_rat` are sorry-free and
  the module builds. No `sorry`, no vacuous definition; if a case cannot be closed, mark the
  phase `[BLOCKED]` with the exact goal state for that case.
- **Timing:** 4 hours.
- **Depends on:** 4, 5

**PHASE 6 OUTCOME (recorded at implementation time)**

`FMCS.toRealShift`, `FMCS.toReal` and `FMCS.toReal_at_rat` landed sorry-free in
`FormalSystem/Metalogic/Bundle/RealExtension.lean`, with the four `limitMCSBelow`-source
coherence variants added to `LimitMCSCoherence.lean` first. Both modules built green on their
first attempt except for one type mismatch (`add_lt_add_right`, recorded as a deviation above).
Full `lake build` green (1895 jobs); live sorries outside `Boneyard/` unchanged at exactly
`WeakCanonical/Transfer.lean:1242`; all thirteen new declarations have axioms exactly
`[propext, Classical.choice, Quot.sound]`.

*Phase 5's transposition recipe was exact.* All four `limitMCSBelow`-source variants are one
`limitMCSBelow_cofinal_below` call plus the family's coherence field, at exactly the thresholds
Phase 5 predicted (`s - 1` for G2 and G4, `(p:ℝ)` for H2, `t` for H4), and the `max`-based bounds
of the H-side `limitSetBelow` proofs vanished as predicted. The conclusion side was free in one
`limitSetBelow_subset_limitMCSBelow` step, also as predicted. Nothing in the recipe needed
correction.

*The `limitSetBelow` → `limitMCSBelow` swap in the definition is the load-bearing change.* The
plan's Phase 6 bullets place `limitSetBelow` at unselected points and name a
`limitSetBelow_is_mcs` for the maximality field. That lemma does not exist and cannot: the limit
set is consistent (`limitSetBelow_consistent`) but not negation-complete, which is precisely why
Phase 4 built the ultrafilter limit in the first place. The extension therefore takes
`limitMCSBelow` at unselected points and discharges `is_mcs` by `limitMCSBelow_is_mcs`. Nothing
else about the phase's shape changed: the selection branch, the four-case splits, and the
definitional agreement at rationals are all as planned.

*Agreement at rationals is now definitional, as intended.* `FMCS.toReal_at_rat` is
`realLimitMCS_of_rat` at `δ = 0`, and `realLimitMCS_of_rat` is `dif_pos` plus injectivity of the
cast `Rat → ℝ`. No limit-interchange step appears anywhere in the module, which is the whole
point of the v2 revision — the false agreement lemma that sank v1 has no descendant here.

*Note for Phase 6.1.* `FMCS.toRealShift` is already the shift-parameterised form, so the real
family set can be built as `{fam.toRealShift δ | fam ∈ B.families, δ : ℝ}` without any further
construction at the `FMCS` layer. `limitSetAbove` remains unused; confirmed again this phase.

### Phase 6.1: The BFMCS real bundle, box time-stability, and restricted temporal coherence [COMPLETED]

**RESOLUTION (v3).** This phase is `[COMPLETED]`. Its landed content stands byte-identical —
`FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean`, 334 lines, 7 declarations, sorry-free,
full `lake build` green (1895 jobs), axioms exactly `[propext, Classical.choice, Quot.sound]` on
every declaration. Nothing in it is reopened, regenerated, or reproved.

What the phase *delivered* is the real bundle plus a temporal-coherence transport whose future
half is conditional on one named, honestly-raised predicate, `B.LimitFutureWitness root`, and
whose past half is unconditional. What the phase's `[BLOCKED]` marker was tracking is the
discharge of that predicate. **That discharge is Phase 6.2**, which also repairs the predicate's
statement (it is false as written at selected rationals) with a one-line change to its binder
list and one argument at its single call site. Phase 6.1's proof script is otherwise untouched by
6.2. The two phases jointly deliver what one phase would have delivered had the obligation been
foreseen; splitting them is an H8 sizing consequence, not a defect.

The former BLOCKER block is retained verbatim below as the record of the counterexample, because
that counterexample is still live mathematics: it is what forces the `fc`-conditional route and
it is quoted in `BFMCS.LimitFutureWitness`'s docstring. Read it as a **finding**, not as an open
obligation.

**BLOCKER (retained record — discharged by Phase 6.2)**:

- **What failed**: `BFMCS.toRealBundle_restricted_temporally_coherent` cannot be proved from
  `B.RestrictedTemporallyCoherent root` alone. Its `someFuture` half at an **unselected** real
  point is not a consequence of the rational bundle's restricted coherence. The plan's stated
  check — "checking `t < s' - δ` from `p < s'` and `p < t + δ`" — does not go through: `p < s'`
  and `p < t + δ` are jointly satisfied by any `s' ∈ (p, t + δ)`, which yields a witness
  *below* `t`, not above it.
- **Counterexample** (four-element defect bar; recorded in full in the docstring of
  `BFMCS.LimitFutureWitness` in `Bundle/RealExtensionBundle.lean`): let `φ` be an atom, `r`
  irrational, and let a rational family carry `φ` exactly at a strictly increasing sequence of
  rationals converging to `r`, with `¬φ` at every rational above `r`.
  - *Current behaviour*: every rational `q < r` has a `φ`-point in `(q, r)`, so `F φ ∈ m q` is
    consistent for every `q < r` and the family can satisfy `RestrictedTemporallyCoherent` in
    full. `{q | F φ ∈ m q}` then contains every rational below `r`, so it lies in
    `limitFilterBelow r` and hence in the ultrafilter: `F φ ∈ limitMCSBelow m r`.
  - *Required behaviour*: some real `s > r - δ` of the extension must carry `φ`. Selection makes
    that need a rational `u > r` with `φ ∈ m u` (none exists by construction), and the limit
    branch is impossible too, since for `z ∈ (r, s + δ)` the interval `(z, s + δ)` belongs to
    the ultrafilter at `s + δ` and is disjoint from `{u | φ ∈ m u}`.
  - *Isolation*: nothing in the argument uses the extension's own fields. The obstruction is a
    property of the rational family alone — its `φ`-points accumulate at `r` from below and stop
    there — so no strengthening of the real-shift closure, and no change to the extension, can
    repair it.
- **What was tried**: (i) the plan's threshold arithmetic, refuted above; (ii) sharpening the
  descent threshold `z` in `limitMCSBelow_cofinal_below` toward `t + δ` — the witnesses creep up
  but stay below `t + δ`; (iii) landing the witness at a *real* point above `t` via the limit
  branch — refuted by the ultrafilter computation above; (iv) recovering `G ¬φ` at `t` from the
  absence of witnesses via `restricted_temporal_backward_G` — circular, that lemma consumes the
  very `forward_F` being proved.
- **Why stuck**: `RestrictedTemporallyCoherent` for the `Rat` bundle is strictly weaker than what
  the `ℝ` extension needs. The missing content is a *no-left-accumulation* property of
  deferral-closure witnesses, which the plan does not identify anywhere and which does not
  follow from any field of `FMCS` or `BFMCS`.
- **What is needed**: discharge `BFMCS.LimitFutureWitness root` for `cantorBfmcsDense`
  (`ChronicleToCountermodelBasic.lean`), or replace it with a property of the Cantor
  back-and-forth chronicle that implies it. This is a research obligation, not a proof-engineering
  one, and it is a prerequisite for Phase 8's terminus, which consumes the transported coherence.
  *(v3: answered. The research dispatch ran and returned `reports/03_limit-future-witness-blocker.md`.
  The obligation is dischargeable — not by a property of the back-and-forth construction, but by
  the Dedekind axiom layer the route had not yet used, and only after the predicate is restricted
  to unselected points. See Phase 6.2.)*
- **Landed instead** (explicitly hypothesised, never hidden):
  `BFMCS.toRealBundle_restricted_temporally_coherent` takes `B.LimitFutureWitness root` as a
  named extra hypothesis and is otherwise sorry-free. The `somePast` half is proved
  **unconditionally** — the extension limits from below, so a past witness at a rational `p < r`
  lies below `r` automatically. The asymmetry is intrinsic to the below-only limit.
- **Prohibited**: no `sorry`, no `def X := True`, no `modal_past` axiom was introduced. Full
  `lake build` green; live sorries outside `Boneyard/` unchanged at exactly
  `WeakCanonical/Transfer.lean:1242`.

- **Goal:** Assemble `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` with a family set closed under
  real shifts, and transport `RestrictedTemporallyCoherent`.
- **Owns:** `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only — coordinate with Phases 3 and 5).
- **Why this is a separate phase (H8):** the modal fields require a new syntactic ingredient
  (box time-stability, itself resting on an S5 negative-introspection derivation) that Phase 6
  does not need at all, and the combined output exceeds one agent run.
- **Tasks:**
  - [x] Prove `box_stable_in_fmcs {D} [LinearOrder D] (f : FMCS (fc := fc) D) (s t : D)
        (φ : Formula) : Formula.box φ ∈ f.mcs s ↔ Formula.box φ ∈ f.mcs t`.
        Forward-in-time direction: `temporalFutureDerived` (`Combinators.lean:654`, `fc`-generic,
        `□φ → G(□φ)`) + `theorem_in_mcs` + `SetMaximalConsistent.implication_property` +
        `f.forward_G`. Backward-in-time direction: **do not** look for `□φ → H(□φ)` — it is not
        in the tree and adding a `modal_past` axiom is forbidden. Instead push the negation
        forward: derive the `fc`-generic `¬□φ → G(¬□φ)` from S5 negative introspection
        (`¬□φ → □¬□φ`, from `Axiom.modal_5_collapse` / `Theorems/ModalS5.lean`), then
        `Axiom.modal_future` (`Axioms.lean:268`) and `Axiom.modal_t` (`Axioms.lean:98`); apply
        `f.forward_G` and convert with MCS negation-completeness. If negative introspection is
        not already a named theorem, land it here as an `fc`-generic derived theorem.
        Trichotomy on `s` vs `t` needs `LinearOrder`, which both `Rat` and `ℝ` supply.
  - [x] Prove `box_mem_realLimitMCS_iff (hstab : ∀ s t φ, box φ ∈ m s ↔ box φ ∈ m t) :
        Formula.box φ ∈ realLimitMCS m δ x ↔ ∀ q : Rat, Formula.box φ ∈ m q`. Selected points
        are immediate from `realLimitMCS_of_rat`; at unselected points, membership in the limit
        set yields the property at *some* rational, and time-stability spreads it to all.
        This is the lemma that makes both modal fields case-free.
  - [x] Define `BFMCS.toRealBundle (B : BFMCS (fc := fc) Rat) : BFMCS (fc := fc) ℝ` with
        `families := {G | ∃ fam ∈ B.families, ∃ δ : ℝ, G = fam.toRealShift δ}`,
        `evalFamily := B.evalFamily.toRealShift 0`. `nonempty` and `eval_family_mem` are
        immediate (`δ := 0`).
  - [x] Prove `modal_forward`. Via `box_mem_realLimitMCS_iff`, reduce to `box φ ∈ fam.mcs q` for
        every rational `q`; the `Rat` bundle's `modal_forward` then gives `φ ∈ fam'.mcs q` for
        every `q` and every `fam'`, which lands in the target family's value whether that value
        is a selected `m q` or a limit set (the latter with any threshold).
  - [x] Prove `modal_backward`. **This is the field that forces the real-shift closure.**
        Contrapositive: if `box φ` is absent from the target family's value at `t`, then by
        `box_mem_realLimitMCS_iff` it is absent from `fam.mcs q` for every rational `q`; fix any
        rational `q`; the `Rat` bundle's `modal_backward` contrapositive yields `fam' ∈
        B.families` with `φ ∉ fam'.mcs q`; then `fam'.toRealShift ((q:ℝ) - t)` is a member of
        the real bundle whose value **at `t`** is exactly `fam'.mcs q` by `realLimitMCS_of_rat`,
        contradicting the hypothesis. Record in the docstring **why** the image family set fails
        here: per-family "eventually" thresholds below an unselected `t` admit no common
        rational, so the `Rat`-side field can never be applied. Note that this mirrors the
        `Rat` construction at `ChronicleToCountermodelBasic.lean:576`, which positions its
        witness family by choosing the chronicle's rational shift.
  - [x] *(v3: landed conditionally; the residual hypothesis is discharged by Phase 6.2, so this
        task is closed at 6.1 and no work on it remains in this phase.)*
        Prove `BFMCS.toRealBundle_restricted_temporally_coherent`: transport
        `RestrictedTemporallyCoherent root` (`TemporalCoherence.lean:308`) from `Rat` to `ℝ`.
        For `someFuture φ ∈ G.mcs t` with `G = fam.toRealShift δ`: at a selected `t` quote the
        rational witness directly and map it back through `realLimitMCS_of_rat`; at an
        unselected `t` obtain the membership at a rational `p` near `t + δ` from the limit set,
        take the rational witness `s' > p`, and return `s' - δ`, checking `t < s' - δ` from
        `p < s'` and `p < t + δ`. `somePast` is the mirror.
        *(deviation: altered — the `somePast` half landed unconditionally; the `someFuture`
        half is proved only under the added named hypothesis `B.LimitFutureWitness root`,
        because the stated threshold check is refuted by the counterexample in the BLOCKER
        block above. Raised as a blocker, not silently substituted.)*
  - [x] `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`.
- **Estimated output:** ~280 lines. *(Actual: 334 lines, 7 declarations, sorry-free.)*
- **Done when:** `BFMCS.toRealBundle` and the restricted-temporal-coherence transport are
  sorry-free and the module builds. *(v3: met. The transport is sorry-free under one named
  hypothesis, raised as a blocker rather than hidden, per `.claude/rules/plan-compliance.md`;
  the hypothesis is discharged by Phase 6.2.)*
- **Timing:** 4 hours.
- **Depends on:** 6

**PHASE 6.1 OUTCOME (recorded at implementation time)**

`FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (334 lines, 7 declarations) is
sorry-free and builds; full `lake build` green (1895 jobs); all seven declarations have axioms
exactly `[propext, Classical.choice, Quot.sound]` (`negBoxIntrospection` needs only `propext`).

*Box time-stability came in cheaper than budgeted, and the plan's routing was right.* The
backward-in-time direction needs no past-side principle at all: `negBoxIntrospection`
(`fc`-generic, from `Axiom.modal_5_collapse` plus contraposition and double-negation
elimination, built at `Base` and lifted through `FrameClass.base_le`) turns `¬□φ` into `□¬□φ`,
`temporalFutureDerived` and `forward_G` push it forward, and `Axiom.modal_t` recovers `¬□φ`
at the later point. `forward_G` is the only `FMCS` field used in either direction; the shared
step factored out as `box_forward_in_fmcs`. Note for the record: `Axiom.modal_future` is *not*
needed on top of `temporalFutureDerived`, which already packages it. S5 negative introspection
does exist in the tree (`negBoxToBoxNegBox`, `BXCanonical/Frame.lean`) but only at
`FrameClass.Base` and in a module *above* `Bundle/` in the import graph, so the `fc`-generic
form was landed here as the plan's fallback clause allows.

*Both modal fields are case-free, as predicted.* `box_mem_realLimitMCS_iff` reduces each to
`□φ ∈ fam.mcs q` for every rational `q`; at unselected points its forward direction is one
`limitMCSBelow_cofinal_below` call at threshold `x + δ - 1` followed by stability. The
real-shift closure did exactly the work the Revision Rationale predicted: `modal_backward`
positions `fam'.toRealShift ((q:ℝ) - t)`, whose value at `t` is `fam'.mcs q` by
`realLimitMCS_of_rat` at `(q:ℝ) = t + ((q:ℝ) - t)`, and no threshold argument appears anywhere
in the field. The direct (non-contrapositive) form was shorter than the plan's contrapositive
phrasing and is what landed.

*The temporal-coherence transport is where v2 has a defect.* See the BLOCKER block above. The
`somePast` half transports unconditionally; the `someFuture` half at unselected points is
refuted as a consequence of `RestrictedTemporallyCoherent` and now carries the named hypothesis
`BFMCS.LimitFutureWitness`. Discharging that predicate for `cantorBfmcsDense` is a new
prerequisite of Phase 8 and is not covered by any existing phase. *(v3: it is now covered — see
Phase 6.2, which also repairs the predicate's statement.)*

*Ordering note for Phase 7.* Nothing in Phase 7's Until/Since transport depends on the blocked
half, so Phase 7 can proceed; but it should expect the *same* asymmetry, since
`forward_until_since_coherent` also demands a witness strictly **above** the evaluation point
and the extension limits only from below. *(v3: this prediction was correct and is now the
organising principle of the Phase 7 split — 7.1′ is everything that avoids the asymmetry, 7.2 is the
asymmetry itself. Phase 7.1′ is nonetheless ordered after 6.2 because two of its chronicle
instances consume 6.2's discharge.)*

### Phase 6.2: The definable-gap discharge of LimitFutureWitness [COMPLETED]

**This phase is the first place in the plan where the Dedekind axiom layer is used.** Everything
before it is `fc`-generic. `Axiom.prior_U_gap` has `minFrameClass = .Dedekind`
(`Axioms.lean:524`), so both new theorems are `fc`-**conditional** on `FrameClass.Dedekind ≤ fc`.
That is the intended shape, not a compromise.

- **Goal:** Repair `BFMCS.LimitFutureWitness` to its true statement and discharge it for
  `cantorBfmcsDense`, closing Phase 6.1's residual hypothesis.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean` (new),
  `FormalSystem/Metalogic/BXCanonical/Chronicle.lean` (import line only)
  *(deviation: altered — no `Chronicle.lean` aggregator exists in this tree; the actual
  aggregator for the `Chronicle/` directory is `FormalSystem/Metalogic/BXCanonical.lean`, and
  the one import line was added there. Path correction only; the plan's intent — one import
  line in the aggregator that pulls the new module into the default target — is met exactly.)*,
  and **exactly two lines** of `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (the
  `LimitFutureWitness` binder list at `:271-274` and the single call site at `:306`), plus that
  predicate's docstring.
- **Module placement.** A new chronicle-level module is used so that `conj_mcs`
  (`Chronicle/PointInsertion.lean:227`) and the `Bundle/` layer are both in scope, and so that
  Phase 7.1′'s `ChronicleRealExtension.lean` stays a separate territory. If the import fails,
  the fallback is `Bundle/LimitGapWitness.lean` with a three-line local `and`-introduction — the
  same move `negBoxIntrospection` made in Phase 6.1. Decide this with one `lake build`, not by
  reading files. Do **not** put these theorems in `ChronicleRealExtension.lean`.
- **Literature grounding (H3, Tier 1).** Every task below is Reynolds 1992, Theorem 3's proof,
  **printed p.176**: "Suppose for contradiction that `M ⊨ U'(A,B)(t)` in some Prior structure
  `M`. Thus `B` holds for a while up until a gap after which `¬B` is true arbitrarily soon. By
  Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction." The
  shape of Steps C-D additionally follows Reynolds' Lemma 3, **printed p.178**: "Prior-U applied
  to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of
  `¬R`." The obligation being discharged is Burgess 1984's prophecy-at-a-gap claim, **printed
  pp.109-110**. Cite all three by PDF page in the module docstring; never by `md:NN`.
- **Tasks:**
  - [x] **Predicate repair (Statement 1).** In `Bundle/RealExtensionBundle.lean`, replace the
        definition at `:271` with exactly:
        ```lean
        def BFMCS.LimitFutureWitness {fc : FrameClass} (B : BFMCS (fc := fc) Rat) (root : Formula) :
            Prop :=
          ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ φ : Formula,
            φ ∈ deferralClosure root →
            Formula.someFuture φ ∈ limitMCSBelow fam.mcs r → ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ fam.mcs s
        ```
        **Why the repair is forced, not cosmetic**: as written the predicate quantifies over all
        `r : ℝ` including rationals, and at `r = (p : ℝ)` with `p = max {q | φ ∈ m q}` the
        hypothesis holds while the conclusion fails. Irrationality of `r` is used exactly twice in
        the proof of Statement 2 (Step A and Step D's first bullet).
  - [x] **Call-site line.** The predicate's only consumer is
        `BFMCS.toRealBundle_restricted_temporally_coherent` (`RealExtensionBundle.lean:306`),
        already inside the `hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ` branch of its `by_cases`. The call
        becomes `h_lfw fam hfam (t + δ) hx φ hdc hFφ'`. `hx` is already in the exact shape the new
        binder wants; if binder-name or defeq friction appears, `by simpa using hx` — do not
        restructure the proof script, and change **nothing else** in that file.
  - [x] **Docstring amendment.** Retain the existing counterexample paragraph verbatim (it is
        still valid, and it is what makes the `fc`-conditional route necessary). Add one
        paragraph recording (i) that the all-`r` form is refutable at a selected `r` where `S_φ`
        attains a maximum, hence the unselectedness hypothesis; and (ii) that the predicate is
        **discharged** at `fc = FrameClass.Dedekind` because the obstruction is exactly a
        definable gap for `Fφ` and `Axiom.prior_U_gap` excludes those (Reynolds 1992, printed
        p.176). No task-number citations.
  - [x] **Statement 2 — the general gap lemma.** In the new module, prove exactly:
        ```lean
        theorem limitFutureWitness_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
            (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
            (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl α β ∈ m t →
              ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
            (hUb : ∀ (t : Rat) (α β : Formula),
              (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
              Formula.untl α β ∈ m t)
            (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
            (hF : Formula.someFuture φ ∈ limitMCSBelow m r) :
            ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ m s
        ```
        Write `χ := Formula.someFuture φ = untl φ ⊤`. Suppose for contradiction
        `(†) ∀ s : Rat, r < (s:ℝ) → φ ∉ m s`, then follow the four steps:
        - **Step A — `χ ∈ m q` for every rational `q` with `(q:ℝ) < r`.**
          `limitMCSBelow_cofinal_below` (`Bundle/LimitMCS.lean:379`) at `z := (q:ℝ)` yields `q'`
          with `q < q' < r` and `χ ∈ m q'`; `hUf` at `q'` (with `α := φ`, `β := ⊤`) gives `s > q'`
          with `φ ∈ m s`; by `(†)` and irrationality of `r`, `(s:ℝ) < r`; `hUb` at `q` with witness
          `s` (guard trivial since `β = ⊤`) gives `χ ∈ m q`.
        - **Step B — `χ.neg ∈ m u` for every rational `u` with `r < (u:ℝ)`.** If `χ ∈ m u`, `hUf`
          gives `s > u > r` with `φ ∈ m s`, contradicting `(†)`; conclude by negation-completeness.
        - **Step C — the Prior-U antecedent at any rational `t` with `(t:ℝ) < r`.**
          `untl ⊤ χ ∈ m t` by `hUb` at `t` with any rational `s ∈ (t, r)` (`exists_rat_btwn`), its
          guard true by Step A and `⊤ ∈ m s` by `theorem_in_mcs`;
          `χ.neg.someFuture = untl χ.neg ⊤ ∈ m t` by `hUb` at `t` with any rational `u₀ > r`
          (`exists_rat_gt`), using Step B, guard trivial; combine with `conj_mcs`
          (`Chronicle/PointInsertion.lean:227`); then
          `theorem_in_mcs (hm t) (DerivationTree.axiom [] _ (Axiom.prior_U_gap χ) hfc)` plus
          `SetMaximalConsistent.implication_property` yields
          `untl (Formula.or χ.neg (Formula.kPlus χ.neg)) χ ∈ m t`.
        - **Step D — contradiction.** `hUf` at `t` on that formula gives `u > t` with
          `Formula.or χ.neg (kPlus χ.neg) ∈ m u` and `χ ∈ m p` for all rationals `p ∈ (t,u)`.
          First `(u:ℝ) < r`: if `(u:ℝ) > r`, a rational `p ∈ (r,u)` lies in `(t,u)` so `χ ∈ m p`,
          contradicting Step B; `(u:ℝ) = r` is excluded by irrationality. By Step A, `χ ∈ m u`, so
          `χ.neg ∉ m u`, so `χ.neg.neg ∈ m u`; since `Formula.or a b = a.neg.imp b`
          (`Syntax/Formula.lean:438`), `implication_property` gives `kPlus χ.neg ∈ m u`, i.e.
          `untl ⊤ χ.neg.neg ∉ m u` (`Formula.kPlus` at `Syntax/Formula.lean:180`). But `hUb` at `u`
          with any rational `s ∈ (u, r)` gives `untl ⊤ χ.neg.neg ∈ m u`, its guard true by Step A
          plus MCS double-negation. Contradiction.
        Land each of Steps A-D as its own named `have` (or private lemma) so the case analysis
        stays reviewable, exactly as Phase 5 required of its `exists_rat_btwn` interpolations.
  - [x] **Statement 3 — the chronicle instantiation.** In the same module, prove exactly:
        ```lean
        theorem cantor_bfmcs_dense_limit_future_witness (fc : FrameClass)
            (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
            (h_mcs : SetMaximalConsistent (fc := fc) A)
            (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) (root : Formula) :
            (Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).LimitFutureWitness root
        ```
        Proof: `intro fam hfam r hr φ _ hF`, then build the unrestricted coherence hypotheses by
        **self-root instantiation** —
        ```lean
        hUf := fun t α β h =>
          (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
              (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
        hUb := fun t α β h =>
          (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
              (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
        ```
        then `exact limitFutureWitness_of_priorU hfc fam.mcs fam.is_mcs hUf hUb r hr φ hF`.
        This works because `_fuc` and `_buc` are polymorphic in `root` and their proofs discard
        the closure-membership argument (`ChronicleToCountermodelBasic.lean:766`, `:691`), so the
        side condition is `self_mem_subformulaClosure (Formula.untl α β)`
        (`Syntax/SubformulaClosure/Closure.lean:42`). **No chronicle declaration is modified and
        no chronicle-level proof is written.** If the self-root instantiation does not elaborate,
        that is a signature discrepancy to report, not a licence to edit `_fuc`/`_buc`.
  - [x] Module docstring: cite Reynolds 1992 printed p.176 (Theorem 3's Prior-U contradiction) and
        p.178 (Lemma 3's pattern) and Burgess 1984 printed pp.109-110 (the obligation's origin);
        record that the discharge is `fc`-conditional and why; record the self-root discovery in
        one sentence so a future reader does not re-derive it.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGapWitness` and
        `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`, then full `lake build`.
  - [x] `#print axioms limitFutureWitness_of_priorU` and
        `#print axioms cantor_bfmcs_dense_limit_future_witness`; record the results.
- **OUTCOME (2026-07-27): phase closed, both statements landed sorry-free on the first build.**
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean` is 209 lines and
  contains `limitFutureWitness_of_priorU` and `cantor_bfmcs_dense_limit_future_witness`, both in
  namespace `FormalSystem.Metalogic.BXCanonical.Chronicle`. `#print axioms` on each reports
  exactly `[propext, Classical.choice, Quot.sound]`. Full `lake build` green (1900 jobs); live
  sorries outside `Boneyard/` remain exactly one, at `WeakCanonical/Transfer.lean:1242`; no new
  axioms and no vacuous definitions. The four-step decomposition landed as written — Step A
  (`χ` below the gap) and Step B (`¬χ` above it) as named `have`s, Step C assembling the Prior-U
  antecedent through `conj_mcs` + `theorem_in_mcs (DerivationTree.axiom … hfc)` +
  `implication_property`, Step D deriving the `K⁺(¬χ)` contradiction at the Until witness.
  Irrationality of `r` was consumed at exactly the two predicted places. The self-root
  instantiation of `cantor_bfmcs_dense_restricted_fuc`/`_buc` elaborated with no signature
  friction and no chronicle declaration was touched. Two small additions beyond the task list,
  both forced and neither a design change: a local `htop` (`⊤ ∈ m q` via
  `identity (fc := fc) Formula.bot`) since `⊤`-guards are needed at four call sites, and a pair
  of `hSFf`/`hSFb` specialisations of `hUf`/`hUb` to `someFuture`, which is what Steps A-C
  actually use. `push Not` replaced the deprecated `push_neg`.
- **Estimated output:** ~180-220 lines in the new module (Statement 2 ~140-180, Statement 3 ~25,
  docstring the rest), plus ~15 lines of docstring and exactly 2 changed lines in
  `RealExtensionBundle.lean`. **One agent run (H8).**
- **Done when:** both new theorems are sorry-free, the repaired predicate and its single call site
  build, full `lake build` is green, live sorries outside `Boneyard/` are unchanged at exactly
  `WeakCanonical/Transfer.lean:1242`, and `#print axioms` on both new declarations is
  `[propext, Classical.choice, Quot.sound]`. No `sorry`, no vacuous definition; if a step cannot
  be closed, mark the phase `[BLOCKED]` with the exact goal state for that step.
- **Timing:** 3 hours.
- **Depends on:** 6.1

### Phase 6.3: The guard gap lemma — the definable-right-gap discharge of the Until/Since guard [COMPLETED]

**This is the Prior-S mirror of Phase 6.2 and the second place in the plan where the Dedekind
axiom layer is used.** `Axiom.prior_S_gap` has `minFrameClass = .Dedekind` (`Axioms.lean:524`
block), so both new theorems are `fc`-**conditional** on `FrameClass.Dedekind ≤ fc`. That is the
settled shape for every gap-facing obligation on this route, not a compromise.

**This phase is not a probe.** The route is determined, the axiom is identified, the proof is
sketched step by step below against verified signatures, and the structural template is a landed
file. An analysis-only dispatch is a failed dispatch.

- **Goal:** Land the general guard gap lemma, the closure-free bundle predicate it discharges, and
  the chronicle instance — so that Phase 7.1′'s three unlanded backward cases have their one
  missing ingredient in hand.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean` (new),
  `FormalSystem/Metalogic/BXCanonical.lean` (import line only — this is the actual aggregator for
  the `Chronicle/` directory; there is no `Chronicle.lean`, as Phase 6.2's deviation note
  established), and the **new predicate definition only** in
  `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (append `BFMCS.LimitGuardBelow` beside
  `BFMCS.LimitFutureWitness`; change **nothing else** in that file — no proof script in it is
  restructured and `LimitFutureWitness` is not touched).
- **Module placement.** A new chronicle-level module, for exactly the reason Phase 6.2 used one:
  `conj_mcs` (`Chronicle/PointInsertion.lean:227`) and the `Bundle/` layer are both in scope
  there, and `ChronicleRealExtension.lean` stays a separate territory (Phase 7.1′ owns it). Do
  **not** put these theorems in `ChronicleRealExtension.lean` or in
  `ChronicleLimitGapWitness.lean`. Decide any import question with one `lake build`, not by
  reading files.
- **Literature grounding (H3, Tier 1).** The pattern being excluded is Reynolds' `γ⁻` / **right
  gap**, **printed p.175**: "Given a temporal formula `A`, we can define a connective `γ⁺` by
  saying that `γ⁺(A)` holds exactly when `A` remains true for a while after now but only up until
  a gap after which `A` is arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the
  indicated gap an `A` **left gap** and more generally a **definable gap**. Dually there is `γ⁻`
  and **right gaps**." The proof move is Reynolds' Theorem 3, **printed p.176**, and Lemma 3,
  **printed p.178** — and the discipline it instantiates is: *apply the gap axiom to the formula
  that is uninterruptedly true on an interval ending at the gap*. Here that formula is the guard
  `ψ`, and the transport's hypothesis supplies its interval, so the antecedent `S(⊤,ψ)` is free.
  The obligation's provenance is Burgess 1982 I's `U`/`S` chronicle (C1/C3/C5a/C4a, **printed
  p.372**), which has **no** Dedekind variant (variants table, **printed p.369**) and never places
  a witness at a gap — which is why the axiom is needed here at all. Cite all of these by PDF page
  in the module docstring; never by `md:NN`.
  **Scoping caveat to record in the docstring**: Reynolds' §6 Lemma 2 obtains *its* formula "by
  the expressive completeness of `U` and `S`" (**printed p.177**), which the Postmortem
  Constraints forbid building. This phase does **not** inherit that dependency: `ψ` is a
  hypothesis binder, not a constructed formula. Only the Prior-S appeal is copied, never the
  machinery around it.
- **Tasks:**
  - [x] **Statement 1 — the general gap lemma.** In the new module, prove exactly:
        ```lean
        theorem limitGuardBelow_of_priorS {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
            (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
            (hSf : ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ m t →
              ∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p)
            (hSb : ∀ (t : Rat) (α β : Formula),
              (∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p) →
              Formula.snce α β ∈ m t)
            (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
            (c : Rat) (hc : r < (c : ℝ))
            (hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q) :
            ψ ∈ limitSetBelow m r
        ```
        Read: *a formula true on an interval abutting an unselected real from above is true on an
        interval abutting it from below* — the `ψ`-region has no definable **right** gap at `r`.
        **Note the hypothesis shape**: `hSf`/`hSb` are the `.2` (`snce`) projections of
        `_fuc`/`_buc`, where Phase 6.2 used `.1`. Proof, mirroring
        `limitFutureWitness_of_priorU` (`ChronicleLimitGapWitness.lean:96-190`) with the same
        plumbing (`htop`, `conj_mcs`, `theorem_in_mcs (DerivationTree.axiom … hfc)`,
        `implication_property`, `neg_excludes`, `negation_complete`, `exists_rat_btwn`):
        - Fix a rational `t ∈ (r, c)` by `exists_rat_btwn hc`. Let
          `htop q : Formula.top ∈ m q` be the same three-line
          `theorem_in_mcs (hm q) (identity (fc := fc) Formula.bot)` 6.2 already uses.
        - **Case 1 — `ψ.neg.somePast ∉ m t`.** Contrapose `hSb` at `t` with `α := ψ.neg`,
          `β := ⊤` (guard trivial by `htop`): no rational `s < t` has `ψ.neg ∈ m s`. By
          `SetMaximalConsistent.negation_complete`, `ψ ∈ m s` for every rational `s < t`. Take the
          threshold `z := r - 1`; every rational `q ∈ (z, r)` satisfies `q < r < t`, so `ψ ∈ m q`.
          Done — **three lines, no axiom appeal**.
        - **Case 2 — `ψ.neg.somePast ∈ m t`.** Build the Prior-S antecedent:
          `snce ⊤ ψ ∈ m t` by `hSb` at `t` with a rational witness `w₀ ∈ (r, t)`
          (`exists_rat_btwn`), `⊤ ∈ m w₀` by `htop`, and guard `∀ p ∈ (w₀, t) : p ∈ (r, c)` so
          `hguard` applies. `conj_mcs` combines the two;
          `theorem_in_mcs (hm t) (DerivationTree.axiom [] _ (Axiom.prior_S_gap ψ) hfc)` plus
          `SetMaximalConsistent.implication_property` yields
          `snce (Formula.or ψ.neg (Formula.kMinus ψ.neg)) ψ ∈ m t`.
        - `hSf` at `t` gives a rational `w < t` with `Formula.or ψ.neg (kMinus ψ.neg) ∈ m w` and
          `ψ ∈ m p` for every rational `p ∈ (w, t)`.
        - **`(w:ℝ) < r`.** Trichotomy. `(w:ℝ) = r` is excluded by `hr` — **this is the only use of
          unselectedness, exactly as in 6.2** (6.2 used it twice; here, once). If `(w:ℝ) > r` then
          `w ∈ (r,c)`, so `ψ ∈ m w` by `hguard`, so `ψ.neg.neg ∈ m w`, and since
          `Formula.or a b = a.neg.imp b` (`Syntax/Formula.lean:438`), `implication_property` gives
          `kMinus ψ.neg ∈ m w`, i.e. `(snce ⊤ ψ.neg.neg).neg ∈ m w`. But `hSb` at `w` with a
          rational witness in `(r, w)` and guard `ψ.neg.neg` on `(·, w) ⊆ (r,c)` gives
          `snce ⊤ ψ.neg.neg ∈ m w` — `neg_excludes`, contradiction.
        - Conclude `⟨(w:ℝ), _, fun q h₁ h₂ => _⟩`: every rational `q ∈ (w, r)` has `q < r < t`,
          hence `q ∈ (w,t)`, hence `ψ ∈ m q`. ∎
        Land each case and each interpolation as its own named `have` (or private lemma), exactly
        as Phase 6.2 and Phase 5 required. **There is no outer `by_contra` and no Step-D
        double-negation dance** — an implementer writing one has drifted into copying 6.2 rather
        than proving 6.3.
  - [x] **Statement 2 — the bundle predicate.** Append to `Bundle/RealExtensionBundle.lean`,
        beside `BFMCS.LimitFutureWitness`:
        ```lean
        def BFMCS.LimitGuardBelow {fc : FrameClass} (B : BFMCS (fc := fc) Rat) : Prop :=
          ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ ψ : Formula, ∀ c : Rat,
            r < (c : ℝ) → (∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ fam.mcs q) →
            ψ ∈ limitSetBelow fam.mcs r
        ```
        **State it with no closure hypothesis, and do not "fix" the asymmetry with its sibling.**
        `LimitFutureWitness` carries `φ ∈ deferralClosure root` and its chronicle discharge throws
        it away (`intro … φ _ hF`). Here the mirrored hypothesis would be *actively wrong*: the
        guard `ψ` of an `untl φ ψ ∈ subformulaClosure root` need not lie in `deferralClosure root`,
        so it would be an unprovable side condition at the 7.1′ call site. Consequently the
        predicate takes no `root` argument either. Docstring: record the `γ⁻` reading, the
        `fc`-conditionality, and this closure-free decision with its reason, in one paragraph. No
        task-number citations.
  - [x] **Statement 3 — the chronicle discharge.** In the new module, prove exactly:
        ```lean
        theorem cantor_bfmcs_dense_limit_guard_below (fc : FrameClass)
            (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
            (h_mcs : SetMaximalConsistent (fc := fc) A)
            (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
            (Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).LimitGuardBelow
        ```
        Proof: the shape of `cantor_bfmcs_dense_limit_future_witness`
        (`ChronicleLimitGapWitness.lean:203-221`), with `.1` replaced by `.2` and
        `root := Formula.snce α β`:
        ```lean
        hSf := fun t α β h => (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
                 (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
        hSb := fun t α β h => (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
                 (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
        ```
        This works for the reason Phase 6.2 established and this plan's Closure discovery records:
        `_fuc` (`ChronicleToCountermodelBasic.lean:755`) and `_buc` (`:680`) are polymorphic in
        `root` and discard the closure-membership argument, so the side condition is
        `self_mem_subformulaClosure (Formula.snce α β)`. **No chronicle declaration is modified,
        no chronicle-level proof is written, and no closure is enlarged.** If the self-root
        instantiation does not elaborate, that is a signature discrepancy to report, not a licence
        to edit `_fuc`/`_buc`.
  - [x] Module docstring: cite Reynolds 1992 **printed p.175** (`γ⁻` / right gaps), **p.176**
        (Theorem 3's Prior-S/Prior-U contradiction pattern), **p.178** (Lemma 3), Burgess 1982 I
        **printed pp.369, 372** (no Dedekind variant; the `g(x,y)` interval datum whose loss is the
        structural root of the obligation), and Burgess 1984 **printed pp.109-110** (the sibling
        obligation's origin). Record in one sentence that `Axiom.prior_S_gap` was present and sound
        in the tree but consumed nowhere on the completeness route before this module, and record
        the expressive-completeness non-inheritance caveat above.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardWitness` and
        `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`, then full `lake build`.
  - [x] `#print axioms limitGuardBelow_of_priorS` and
        `#print axioms cantor_bfmcs_dense_limit_guard_below`; record the results.
- **Estimated output:** ~180-220 lines in the new module (Statement 1 ~130-170 — *smaller* than
  6.2's 209 because there is no outer `by_contra` and no Step-D dance; Statement 3 ~25; docstring
  the rest), plus ~15 lines appended to `RealExtensionBundle.lean` for Statement 2 and its
  docstring. **One agent run (H8).**
- **Done when:** all three statements are sorry-free, full `lake build` is green, live sorries
  outside `Boneyard/` are unchanged at exactly `WeakCanonical/Transfer.lean:1242`, and
  `#print axioms` on both new theorems is `[propext, Classical.choice, Quot.sound]`. No `sorry`,
  no vacuous definition; if a step cannot be closed, mark the phase `[BLOCKED]` with the exact
  goal state for that step.
- **Timing:** 3 hours.
- **Depends on:** 6.2
- **Outcome:** All three statements landed sorry-free on the first build. `limitGuardBelow_of_priorS` and `cantor_bfmcs_dense_limit_guard_below` in the new module `Chronicle/ChronicleLimitGuardWitness.lean` (207 lines); `BFMCS.LimitGuardBelow` appended to `Bundle/RealExtensionBundle.lean` (closure-free, no `root` argument, as specified); one import line added to `Metalogic/BXCanonical.lean`. Full `lake build` green; live sorries outside `Boneyard/` unchanged at exactly `WeakCanonical/Transfer.lean:1242`; `#print axioms` on both new theorems is `[propext, Classical.choice, Quot.sound]`. No deviations from the specified statements or proof decomposition.

### Phase 7.1: Until/Since transport at ℝ — the three unlanded backward cases (7.1′) [COMPLETED]

**RESOLUTION (v4).** The `[BLOCKED]` marker this phase carried in v3 is retired. The blocker was
real and the refutation stands — **the `fc`-generic backward transport whose only rational-side
hypothesis is restricted backward coherence is false**, permanently, and the two counterexample
families below are retained as *findings*, not as open questions. What the refutation did **not**
settle, and what report 04 has now settled in the positive direction, is the **chronicle
instance**: `cantor_bfmcs_dense_real_restricted_buc` is reachable, and all four of its cases close
once the transport is strengthened by `B.LimitGuardBelow` — which Phase 6.3 lands and discharges.

**The seven declarations the Phase 7.1 dispatch landed are preserved assets.** They are consumed
by this phase, not rewritten, and they keep their value under every outcome. This phase appends to
their module; it does not regenerate it.

**Retained findings — the two refuting families** (written out in full in
`ChronicleRealExtension.lean`'s docstring, section `Refutations`). Both take a genuine model `M`
over `ℝ`, set `m q := {χ | M, q ⊨ χ}` for rational `q` — making every `m q` maximal consistent at
`FrameClass.Dedekind` for free — and exploit that `realLimitMCS` at a gap is a limit **from below**
and so disagrees with `M`'s own theory there.

- *Refutation 1 (backward `snce`, **selected** target)*: `V(φ) = (0, g)`, `V(ψ) = (g, 5)` with `g`
  irrational. Rational restricted backward coherence holds vacuously; the real witness pattern for
  `snce φ ψ` at `t := 5` is met by the gap witness `s := g`, where
  `φ ∈ limitSetBelow m g ⊆ limitMCSBelow m g`; but `snce φ ψ ∉ m 5`.
  **Why it no longer bites**: it violates `LimitGuardBelow` — `ψ` is true on all rationals of
  `(g,5)` and on **no** rational below `g`, a `ψ`-right gap at `g` in Reynolds' sense (printed
  p.175), excluded by `Axiom.prior_S_gap`. With the guard extended below `g`, case 3′ places the
  `snce` witness **below** the gap, where `limitMCSBelow_cofinal_below` already supplies it. The
  v3 diagnosis — "descending from the witness leaves the guarded interval" — was true only because
  the guarded interval was taken to stop at `g`. (Independently, this family also violates Phase
  6.2's already-landed `LimitFutureWitness`: `someFuture φ ∈ m q` for every rational `q < g`, hence
  in `limitSetBelow m g ⊆ limitMCSBelow m g`, yet no rational `s > g` has `φ ∈ m s`.)
- *Refutation 2 (backward `untl`, **unselected** target)*: `V(ψ)` oscillating below the gap `g` and
  equal to `(g, 3)` above it, `V(φ) = (g, 3)`. Rational restricted backward coherence holds; the
  real witness pattern at `t := g` is met by `s := 2`; but no rational below `g` carries
  `untl φ ψ`, and `{q : ℚ | (q : ℝ) < g}` is a `limitFilterBelow g` generator, so
  `untl φ ψ ∉ limitMCSBelow m g`.
  **Why it no longer bites**: `ψ` is uninterruptedly true on `(g,3)` and false arbitrarily recently
  below `g` — verbatim Reynolds' `γ⁻` pattern — so `LimitGuardBelow` at `r := g` excludes it. Once
  `ψ` holds on `(a,g)`, rational backward coherence puts `untl φ ψ` in `m q` for every rational
  `q ∈ (a,g)`, hence in `limitSetBelow m g ⊆ limitMCSBelow m g`.

**What the RESOLUTION does not license.** The prohibition against re-attempting the `fc`-generic
statement is permanent (Postmortem Constraints, v4). The families are not to be re-derived, and no
attempt is to be made to prove them unrealizable directly — their unrealizability inside
`cantorBfmcsDense` follows as a corollary of the route, not the other way round.

- **Goal:** Land the three backward Until/Since cases that the Phase 7.1 dispatch could not close,
  now that Phase 6.3 supplies the guard gap lemma — and with them the chronicle instance
  `cantor_bfmcs_dense_real_restricted_buc`.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (extends
  the Phase 7.1 dispatch's file — **append and correct one docstring paragraph; regenerate
  nothing**). No other file. In particular: do **not** touch
  `Bundle/RealExtensionBundle.lean` (Phase 6.3 owns the predicate),
  `ChronicleLimitGuardWitness.lean`, or any chronicle declaration.
- **Charter and stop rule.** This phase owns the **backward** direction only. Forward case B
  remains Phase 7.2's sole deliverable and its charter is **not** widened by this phase — report
  04 explicitly does not clear it (there the guard is the *conclusion*, so nothing supplies
  `S(⊤,ψ)` or `U(⊤,ψ)`, and v3's interval-failure family stands unrefuted). If an implementer
  finds themselves reasoning about *forward* witnesses shrinking to `t + δ`, they have left this
  phase; stop and let 7.2 own it. Equally: this phase is **not** a probe. The route is determined
  and a written analysis with no landed declarations is a failed dispatch, not an outcome.
- **The four cases, and which three are open.** Notation: `m := fam.mcs`, `T := t + δ` the
  target's shifted coordinate, `S := s + δ` the witness's; selected = `∃ p : Rat, (p:ℝ) = ·`.
  Case analysis opens with `rintro G ⟨fam, hfam, δ, rfl⟩` as at `RealExtensionBundle.lean:311`.

  | # | Case | Status / route |
  |---|---|---|
  | 1 | `untl`, `T` selected | **LANDED** — `toRealBundle_backward_until_selected` (`:270`). Consume it. |
  | 2 | `untl`, `T` unselected | **OPEN.** `exists_rat_witness_of_realLimitMCS` at the witness with threshold `T` gives a rational `u ∈ (T, S]` with `φ ∈ m u`; each rational `q ∈ (T,u)` is a selected real in `(t,s)`, so the real guard reads off `ψ ∈ m q` via `realLimitMCS_of_rat`; `h_lgb` at `r := T`, `c := u` gives `ψ ∈ limitSetBelow m T`, i.e. a threshold `a < T` with `ψ` on all rationals of `(a,T)`; for each rational `q ∈ (a,T)`, `h_rbuc` at `q` with witness `u` (guard on `(q,u)` covered by `(a,T) ∪ (T,u)`, and `T` is not rational) gives `untl φ ψ ∈ m q`; conclude by `limitSetBelow_subset_limitMCSBelow`. |
  | 3 | `snce`, `T` selected, `S` selected | **LANDED** — `toRealBundle_backward_since_selected_of_rat_witness` (`:304`). Consume it. |
  | 3′ | `snce`, `T` selected, `S` unselected | **OPEN.** `h_lgb` at `r := S`, `c := T` (guard from the real guard on `(s,t)`) gives `a < S` with `ψ` on rationals of `(a,S)`; `limitMCSBelow_cofinal_below m S hφ a` gives a rational `u ∈ (a,S)` with `φ ∈ m u`; `h_rbuc` at `T` with witness `u`, guard on `(u,T) ⊆ (a,S) ∪ (S,T)`. **This is where the witness is placed BELOW the gap** — the correction to the v3 diagnosis. |
  | 4 | `snce`, `T` unselected | **OPEN.** First obtain a rational `u < T` with `φ ∈ m u` and `ψ` on all rationals of `(u,T)` — directly if `S` is selected, else by 3′'s two steps; then `h_rbuc` at **every** rational `q ∈ (u,T)` with the same witness `u` gives `snce φ ψ ∈ m q`, so `snce φ ψ ∈ limitSetBelow m T` with threshold `(u:ℝ)`; conclude by `limitSetBelow_subset_limitMCSBelow`. **No gap lemma is needed at the target itself.** |

- **Tasks:**
  - [x] Prove `BFMCS.toRealBundle_restricted_backward_until_since` at the **strengthened**
        signature — the only change from the refuted v3 statement is the added `h_lgb`:
        ```lean
        theorem BFMCS.toRealBundle_restricted_backward_until_since {fc : FrameClass}
            (B : BFMCS (fc := fc) Rat) (root : Formula)
            (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
            (h_lgb : B.LimitGuardBelow) :
            (B.toRealBundle).RestrictedBackwardUntilSinceCoherent root
        ```
        (target predicate at `Bundle/TemporalCoherence.lean:589`). Land cases 2, 3′ and 4 per the
        table above; **consume** the two landed selected-case lemmas for cases 1 and 3 rather than
        inlining or reproving them. Each case gets its own named `have` or private lemma so the
        analysis stays reviewable. Expect friction at the `δ`-shift casts and at
        `exists_rat_witness_of_realLimitMCS`'s `≤` (not `<`) upper bound — that is elaboration
        work, not a mathematical gap.
  - [x] Land `cantor_bfmcs_dense_real_restricted_buc` — the phase's deliverable — exactly as:
        ```lean
        theorem cantor_bfmcs_dense_real_restricted_buc (fc : FrameClass)
            (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
            (h_mcs : SetMaximalConsistent (fc := fc) A)
            (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) (root : Formula) :
            ((Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedBackwardUntilSinceCoherent
              root :=
          BFMCS.toRealBundle_restricted_backward_until_since _ root
            (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense root)
            (Chronicle.cantor_bfmcs_dense_limit_guard_below fc hfc A h_mcs h_box_dense)
        ```
        Signature parity with the landed `cantor_bfmcs_dense_real_restricted_tc`: same `hfc`
        threading, same non-modification of `cantor_bfmcs_dense_restricted_buc` (`:680`). **Do not
        modify that theorem.**
  - [x] **Docstring correction (defect logged by report 04).** The module's "What these do and do
        not settle" paragraph currently claims that *neither* refuting family satisfies the
        unrestricted rational **forward** Until coherence that `cantorBfmcsDense` enjoys, "in
        Refutation 2 the same happens for the definable gap of `φ.neg` at `g`". That claim is
        **unsupported as written** for Refutation 2: no forward violation could be constructed —
        for every candidate `untl α β` at a rational `q < g` in that family a rational witness
        below `g` or in `(g,3)` is available, because `V(φ) = (g,3)` is entered immediately above
        `g` and the `θ`-points `{αₙ}` are themselves rational. The supported statement is that
        Refutation 2's family fails unrestricted rational **backward** Until coherence, via the
        separating formula `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ` (`P' = kMinus`, `F' = kPlus`): `β` is true at
        every rational of `(q,s)` for `q < g < s < 3` — at `αₙ` because `¬F'ψ` holds there, inside
        `(αₙ, tₙ₊₁)` because `¬P'ψ` holds, and above `g` because `ψ` holds — but **false at the
        real `g`**, where `ψ` is false and both `P'ψ` and `F'ψ` are true. **Rewrite the paragraph
        to say the families are excluded by the guard-side gap discharge (`LimitGuardBelow`,
        Reynolds printed p.175), and drop the unsupported forward-coherence claim rather than
        defending it.** Do not attempt to construct a forward violation. Cite by printed PDF page;
        no task-number citations.
  - [x] Update the module docstring's absence note: `cantor_bfmcs_dense_real_restricted_fuc`
        remains deliberately absent and is Phase 7.2's sole deliverable. Record that the backward
        side is now complete and by which lemma, so a reader does not conclude the module is
        half-finished by accident.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension`, then
        full `lake build`.
  - [x] `#print axioms BFMCS.toRealBundle_restricted_backward_until_since` and
        `#print axioms cantor_bfmcs_dense_real_restricted_buc`; record the results.
- **Preserved from the Phase 7.1 dispatch (consumed, never rewritten):**
  `guard_transport_realLimitMCS` (`:153`), `exists_rat_witness_of_realLimitMCS` (`:183`),
  `toRealBundle_forward_until_selected`, `toRealBundle_forward_since_selected`,
  `toRealBundle_backward_until_selected` (`:270`),
  `toRealBundle_backward_since_selected_of_rat_witness` (`:304`),
  `cantor_bfmcs_dense_real_restricted_tc`. All seven are sorry-free with axioms exactly
  `[propext, Classical.choice, Quot.sound]`. A diff that rewrites any of them is a defect.
- **Estimated output:** ~140-180 lines appended, plus the corrected docstring paragraph.
  **One agent run (H8).**
- **Done when:** the strengthened backward transport (all four cases) and
  `cantor_bfmcs_dense_real_restricted_buc` are sorry-free, the docstring correction is in place,
  full `lake build` is green, live sorries outside `Boneyard/` are unchanged at exactly
  `WeakCanonical/Transfer.lean:1242`, and `#print axioms` on both new declarations is
  `[propext, Classical.choice, Quot.sound]`. No `sorry`, no vacuous definition, and **no
  re-attempt of the v3 signature**; if a case cannot be closed, mark the phase `[BLOCKED]` with
  the exact goal state for that case — not with a widened hypothesis set and not with a
  bounded-witness attempt.
- **Timing:** 4 hours.
- **Depends on:** 6.3
- **Outcome (landed).** All six new declarations sorry-free, axioms exactly
  `[propext, Classical.choice, Quot.sound]`, full `lake build` green, live non-`Boneyard/` sorries
  unchanged at exactly `WeakCanonical/Transfer.lean:1242`. Case 2 is
  `toRealBundle_backward_until_unselected`; cases 3′ and 4 share the relocation lemma
  `exists_rat_since_witness_below_of_limitGuardBelow` (which handles selected and unselected
  witnesses uniformly, needing no case split on the target) and land as
  `toRealBundle_backward_since_selected_of_gap_witness` and
  `toRealBundle_backward_since_unselected`. Cases 1 and 3 consume the landed selected-case lemmas
  unmodified. One deviation, mechanical: the module gained an
  `import …Chronicle.ChronicleLimitGuardWitness` line, required to see the Phase 6.3 discharge;
  that module's import set is disjoint from this one's, so no cycle. The docstring correction
  also repaired a dangling reference to the never-existing
  `toRealBundle_backward_since_selected_is_refuted`, now pointing at the relocation lemma.

### Phase 7.2: Forward case B — a two-outcome probe [COMPLETED]

**RESOLUTION (v5).** The `[BLOCKED]` marker this phase carried in v4 is retired. **The phase
completed its charter.** It was chartered as a two-outcome probe — "Settle forward case B … either
by proving it or by exhibiting a refuting family" — with a `Done when` clause that is met in full:
case (a) is landed sorry-free and the refuting family was delivered with all three required
elements. Four sorry-free declarations landed. The `[BLOCKED]` marker was the marker the phase
text itself instructed the dispatch to set under outcome (ii); this revision is the escalation
that outcome demanded, and is therefore the point at which the marker is retired.

**Convention applied, stated explicitly**: the completion criterion used is the phase's own
`Done when` clause, which is what this plan's own convention makes authoritative ("Reporting
neither — an analysis of the difficulty with no landed case (a) and no exhibited family — is a
**failed** dispatch, not a third outcome"). The dispatch reported outcome (ii) *with* landed
declarations, which the phase text names as one of exactly two acceptable outcomes.

**The four declarations the Phase 7.2 dispatch landed are preserved assets** (booked in the
Preserved Assets table). They are consumed by Phase 7.4, not rewritten, and they keep their value
under every outcome — in particular
`toRealBundle_forward_until_unselected_dichotomy`'s right disjunct **is** the `hcof` hypothesis
Phase 7.4's bounded witness needs.

**OUTCOME (ii) — the probe refuted forward case B by the route then available. This was a planned
outcome, not a failure. Retained below verbatim as the findings record.**

- **What was landed first (the H2 bar, sorry-free)**: forward case A, as
  `forward_until_witness_of_straddling_rat` plus
  `toRealBundle_forward_until_unselected_dichotomy`, both in `ChronicleRealExtension.lean`, both
  `[propext, Classical.choice, Quot.sound]`.
- **What failed**: the case (b) guard. The probe reached the eventuality half and no further, and
  that reach is itself now a theorem — `forward_until_unselected_eventuality_of_priorU` proves
  that at an unselected target either the obligation is discharged outright, or there is a
  rational `w > t + δ` with `φ ∈ fam.mcs w` **and no guard whatever** on `(t + δ, w)`.
- **Which formula Prior-U was applied to, and what supplies its antecedent** (the question the
  phase required be answered up front): a `ψ`-guard requires `Axiom.prior_U_gap` at `χ = ψ` or at
  some `χ ⊢ ψ`, because its consequent `U(¬χ ∨ K⁺(¬χ), χ)` guards with `χ` and nothing else. Its
  antecedent `U(⊤, χ)` demands `χ` uninterruptedly on an interval abutting the gap **from below**,
  which under `χ ⊢ ψ` already yields `ψ` uninterruptedly there. **The antecedent is available
  exactly when the below-gap analogue of the conclusion already holds**, and forward case B
  supplies `ψ` only on the descent intervals `(p, s'_p)`, each closing strictly below the gap.
  The antecedent cannot be exhibited, so per this phase's own instruction the attempt stopped
  rather than iterating tactics.
- **Refuting family (Refutation 3)**, delivered with the three required elements in the
  `ChronicleRealExtension.lean` module docstring: (1) the two-sided oscillation at an irrational
  `T` — `V(φ) = {α_n} ∪ {α'_n}`, `V(ψ)` omitting `{t_n} ∪ {u_n}`, interleaved
  `α'_{n+1} < u_{n+1} < α'_n` above `T`; (2) realizability inside `cantorBfmcsDense` is
  **explicitly labelled unsettled** — the weaker outcome the phase permits; (3) the ultrafilter
  computation: `{q | untl φ ψ ∈ m q}` and its complement are both cofinal below `T` and **neither
  lies in `limitFilterBelow (t + δ)`**, so membership in `limitMCSBelow` is decided by
  `Ultrafilter.of` and is not determined by `limitFilterBelow_le`, the only property of that
  choice the development uses. The transport is therefore **not derivable** from rational
  coherence plus `LimitGuardBelow` plus `LimitFutureWitness`; it is not thereby shown false.
- **Why the guard-side exclusion does not rescue it**: `BFMCS.LimitGuardBelow` forces `φ`, `ψ` and
  `untl φ ψ` each to oscillate on **both** sides of `T`, which is why Refutation 3 is built
  two-sided rather than copying Refutation 2's one-sided shape. It then satisfies
  `LimitGuardBelow` vacuously at `T`, leaving that predicate no antecedent to consume.
- **Rung elected: R4 (honest floor), with R2 eliminated on source evidence.** `Axiom.sep`'s own
  route was checked verbatim against the corpus before being ruled on, as directed.
  **R2 is dead by the plan's own stated test.** Reynolds 1992 Theorem 5 (§7, printed pp.184-185),
  the separability step R2 would consume, says at its critical line: "Let the temporal formula `C`
  be true exactly at points who are the left hand end points of their classes. … **We use
  expressive completeness here.**" And Doets' theorem (§8, Theorem 6, printed pp.185-188) is
  stated purely in terms of "monadic first-order sentences of quantifier depth at most `k`" and
  proved by EF-game arguments, lexicographic sums and shuffles (Lemmas 11-13). Both are squarely
  inside the standing Postmortem Constraint against the Reynolds transfer route (monadic-FO,
  Stavi connectives, EF games, expressive completeness), and Phase 7.2's own R2 clause states
  that "if an escalation finds itself needing expressive completeness of `{U,S}` then R2 is also
  dead". It does, so it is.
- **What is needed to unblock — R3, now the only live escalation, and precisely targeted.** The
  probe identified the exact invariant that closes forward case B: **if the guard `ψ` is
  *eventually* true below the gap rather than merely cofinally**, then `U(⊤, ψ)` is free, Prior-U
  at `ψ` yields `U(¬ψ ∨ K⁺(¬ψ), ψ)`, and its endpoint can lie neither below the gap (where `ψ`
  holds) nor at it (unselectedness), so it lies above — delivering the missing guard. That is the
  exact mirror of `limitGuardBelow_of_priorS`. Electing R3 **requires an explicit amendment to
  the Postmortem Constraints** (it modifies `Chronicle/`) **plus a new research dispatch**, and
  this dispatch does neither — flagged, not elected.
- **Prohibited and not done**: no `sorry`, no vacuous definition, no hypothesised
  `LimitUntilWitness` predicate threaded onto the terminus, no narrowing of the target class.
  **Phase 8 must not be dispatched** — under outcome (ii) the correct action is `[PARTIAL]`, not
  a conditional terminus. **(v5: this prohibition stands unamended and is now Phase 8's explicit
  precondition line.)**

**Disposition of the outcome (v5).** The R3 flag was taken up by the new research dispatch the
phase demanded (`reports/05_forward-guard-r3-research.md`), which returned a **split** verdict:
R3a/R3b/R3c are landable now as determined work and become **Phases 7.3 and 7.4**; only the
discharge R3d is a genuine construction modification and became **Phase 7.5, `[USER GATED]`** in v5.
**(v6: the gate was resolved by fresh explicit user authorization on 2026-07-27, Amendments 2-4 are
applied, and R3d is now the five-sub-phase block 7.5-7.9.)**
The dispatch additionally proved (`r3_invariant_necessary`, sorry-free) that R3's invariant is
**necessary**, so this phase's residual has exactly one possible content. Two things this phase
recorded are now sharpened rather than overturned:

- **Refutation 3 is superseded by a strictly stronger candidate**, family `Q` (report 05 §5.1),
  which removes Refutation 3's ultrafilter dependence: `untl P ¬P` is *eventually* true below `T`,
  hence in `limitSetBelow` by `limitFilterBelow_le` (`LimitMCS.lean:347`) with **no
  `Ultrafilter.of` choice involved**. Its realizability at `fc = FrameClass.Dedekind` is
  **[UNVERIFIED]** and settling it needs the forbidden machinery. Both families remain findings;
  neither is to be re-derived and neither is to be proved unrealizable directly.
- **R2 is dead and stays dead**, on the verbatim source evidence recorded above. Do not
  re-litigate it, and do not consult GHR 1994 §10.3 / Venema 2001 for a different answer — those
  are the book-form presentation of the same separability route, and report 05 records them as
  *not consulted, by scope*, not as absent.

**This phase has two acceptable outcomes and a refutation is not a failure.** The blocker research
constructed a candidate family in which Prior-U applied to `untl α β` is satisfied *locally* with
no contradiction; it did not show that family to be realizable inside `cantorBfmcsDense`, and it
did not show it unrealizable. Budget this as a probe, not as proof engineering.

- **Goal:** Settle forward case B — obtain the real Until witness from a membership at an
  **unselected** `t` — either by proving it or by exhibiting a refuting family.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (extends
  Phase 7.1′'s file). No other file.
- **The obligation, stated exactly.** From `untl φ ψ ∈ limitMCSBelow m (t + δ)` at an unselected
  `t`, the membership descends to rationals `p ↗ t + δ` via `limitMCSBelow_cofinal_below`, each
  giving a rational witness `s'_p`. Two cases:
  - **Case (a) — some rational witness lands strictly above `t + δ`.** Closes cleanly with Phase
    7.1′'s guard lemma: the rational guard on `(p, s')` covers `(t + δ, s')`, and every unselected
    real in between inherits `ψ` from a `limitFilterBelow` generator. **No new work; do this
    first and land it.**
  - **Case (b) — all rational witnesses squeeze to `t + δ`.** This is the residual. Phase 6.2's
    `limitFutureWitness_of_priorU` applied to `α := φ` *does* produce a rational `φ`-point above
    `t + δ`, so the **eventuality** half is already available — but it supplies **no guard** on
    the interval between `t + δ` and that point. The guard is the entire difficulty and is what
    this probe must settle.
- **Why Phase 6.2's technique does not simply transfer.** Step A of Phase 6.2 works because the
  truth region of `someFuture φ` below a gap is the interval `(-∞, sup S_φ)`, which supplies
  Prior-U's antecedent `U(⊤, χ)` for free. The truth region of `untl α β` need not be an interval:
  with `β` failing at rationals `t_n ↗ r`, a single `α`-point `α_n ∈ (t_n, t_{n+1})`, and `α`
  failing everywhere above `r`, `untl α β` is true on `⋃(t_n, α_n)` and false on
  `⋃(α_n, t_{n+1})` — cofinal below `r` in both directions — and Prior-U at `t_n` is satisfied by
  a witness `u ∈ [α_n, t_{n+1}]` where `¬(untl α β)` genuinely holds. Reynolds says as much
  directly (§6 opening, **printed p.176**): "We know that the Prior axioms ensure that there will
  not be any definable gaps in a model. To show that our model can be made into a model over the
  reals we actually need a stronger result." Burgess runs the completion route only in the `F`/`G`
  fragment (**printed pp.109-110**) and says nothing about `U`/`S` at a gap.
- **Tasks:**
  - [x] Land case (a) first, as a named lemma, using Phase 7.1′'s guard lemma. This is the H2
        formal-proof-line bar for the dispatch and must exist before any analysis of case (b) is
        written down.
  - [x] **Probe case (b), pursuing outcome (i) first**: attempt
        `limitUntilWitness_of_priorU` — the analogue of Phase 6.2's Statement 2 for `untl α β`,
        with an **explicit guard** on the interval between `t + δ` and the produced witness. Any
        such attempt must state up front which formula Prior-U is being applied to and what
        supplies its `U(⊤, ·)` antecedent; if the antecedent cannot be exhibited, the attempt has
        already failed and the dispatch moves to outcome (ii) rather than iterating tactics.
  - [ ] **If outcome (i) succeeds**: compose it with case (a) into
        `BFMCS.toRealBundle_restricted_forward_until_since`, mirror for `snce`, and land
        `cantor_bfmcs_dense_real_restricted_fuc` against `cantor_bfmcs_dense_restricted_fuc`
        (`ChronicleToCountermodelBasic.lean:755`), which is not modified. Then
        `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension` and mark
        the phase `[COMPLETED]`. *(not applicable — outcome (ii) fired, not outcome (i))*
  - [x] **If outcome (ii) fires — a refuting family**: deliver, as the phase's artifact, (1) the
        family exhibited concretely, (2) an argument that it is realizable inside
        `cantorBfmcsDense` at `fc = FrameClass.Dedekind` (or an explicit statement that
        realizability is itself unsettled, which is a *weaker* outcome and must be labelled as
        such), and (3) the ultrafilter computation showing `{q | untl α β ∈ m q}` does or does not
        belong to `limitFilterBelow (t + δ)`. Mark the phase `[BLOCKED]` with that content. **Do
        not** add a `sorry`, a vacuous definition, or a hypothesised `LimitUntilWitness` predicate
        threaded onto the terminus.
  - [x] Either way, record the outcome in the module docstring by PDF page, not by task number.
- **If the refutation outcome fires, this is what it means for the route.** Fixed in advance so
  the orchestrator does not improvise:
  1. **It does not invalidate anything already landed.** Phases 1-7.1′ stand. The limit MCS, the
     real extension, both modal fields, the temporal transport, the backward Until/Since
     transport, the guard lemma, forward case A and the `_tc`/`_buc` real instances are all
     independently sorry-free and keep their value under every fallback below.
  2. **What it *does* mean**: the completion route (Burgess-style Dedekind completion of a
     rational chronicle) does not deliver full restricted **forward** Until/Since coherence at
     `ℝ`. That is a route-level finding about `U`/`S` at a gap, a step neither primary source
     performs — Burgess runs the completion only in `F`/`G`, and Reynolds reaches `ℝ` by a
     different construction entirely.
  3. **Fallback R2 (preferred escalation) — Reynolds' separability route.** Reach `ℝ` via Doets'
     theorem and `Axiom.sep` (`Axioms.lean:398`, already in the tree and already proved valid)
     with the contemporaneous-equivalence machinery (Reynolds, printed pp.177-178, 184-188),
     instead of by completing a rational chronicle. This replaces Phases 7-8 and **requires a new
     research dispatch before any Lean is written** — it is not a thing to start improvising at
     the end of a 7.2 dispatch. Note that the standing Postmortem Constraint against the Reynolds
     *transfer* route (monadic-FO, Stavi connectives, EF games, expressive completeness) still
     applies in full; R2 is the separability construction, not the transfer argument, and if an
     escalation finds itself needing expressive completeness of `{U,S}` then R2 is also dead.
  4. **Fallback R3 (second choice) — strengthen the rational chronicle.** Add a
     no-left-accumulation invariant on Until-witnesses in the deferral closure to
     `cantorBfmcsDense`'s construction so the refuting family is excluded by construction. This
     **modifies `Chronicle/`, which the Postmortem Constraints currently forbid**, so electing it
     requires an explicit amendment to those constraints plus a new research dispatch. Do not
     elect it silently.
     **(v5 disposition — this is the branch that fired.)** The research dispatch ran and **split**
     R3: its (a)/(b) parts are Phases 7.3/7.4 (determined work, one amendment — Amendment 1,
     applied); its (c) part, the discharge, was Phase 7.5 (`[USER GATED]`, three amendments
     **drafted but NOT applied**, no source in the corpus). "Do not elect it silently" was operative
     as a hard gate: **R3d requires fresh explicit user authorization.**
     **(v6 disposition — the gate was honoured and then resolved.)** The R3d decision was
     re-presented to the user with the no-source verdict and the base rate stated, and fresh
     explicit authorization was granted on 2026-07-27. Amendments 2, 3 and 4 are **applied**, and
     R3d is decomposed into Phases **7.5-7.9**. It was **not** elected silently, which is exactly
     what this clause required.
  5. **Fallback R4 (honest floor) — `[BLOCKED]`.** Mark 7.2 `[BLOCKED]`, mark the task `[PARTIAL]`,
     keep the terminus statement (Phase 2) and everything through 7.1′, and do **not** dispatch
     Phase 8. This is a legitimate terminus for the task and is preferable to any of the
     prohibitions below.
  6. **Explicitly NOT permitted under any outcome**: threading an undischarged
     `LimitUntilWitness`-style predicate onto `countermodel_dedekind_dense`,
     `completeness_dedekind_engine`, `consequence_completeness_dedekind`, or
     `completeness_dedekind`; narrowing the target class to make the obstruction disappear;
     restricting `ValidDedekindDense`; or reporting Phase 8 as complete against a conditional
     engine. Phase 6.1's conditional hypothesis was acceptable only because it was phase-internal
     with a named discharge phase; a hypothesis with no discharge path on the terminus is not the
     same thing.
- **Estimated output:** ~140 lines if outcome (i); ~40 lines (case (a)) plus a written refutation
  if outcome (ii). **One agent run (H8) either way** — if the probe is not settled within one run,
  report the exact goal state and the partial structure rather than requesting a second run
  against the same target (that is the churn pattern H6 exists to catch).
- **Done when:** either `cantor_bfmcs_dense_real_restricted_fuc` is sorry-free and the module
  builds (outcome (i)), or case (a) is landed sorry-free and the refuting family is delivered with
  the three elements above and the phase is marked `[BLOCKED]` (outcome (ii)). Reporting neither —
  an analysis of the difficulty with no landed case (a) and no exhibited family — is a **failed**
  dispatch, not a third outcome.
- **Timing:** 5 hours.
- **Depends on:** 7.1′
- **(v4) Charter note:** this phase is **unchanged** by the v4 revision. Its two-outcome framing,
  its fallback ladder (R2/R3/R4) and its prohibitions stand verbatim, and report 04 explicitly
  does **not** clear forward case B: the Prior-S technique does not transfer, because in the
  forward direction the guard is the *conclusion*, so nothing supplies `S(⊤,ψ)` or `U(⊤,ψ)`, and
  the interval-failure family above stands unrefuted. Only the dependency line moved, from the old
  Phase 7.1 to 7.1′. Do not read Phase 6.3's success as licence to reopen it as determined work.
- **Outcome (landed).** Outcome (ii) fired with four declarations sorry-free, axioms exactly
  `[propext, Classical.choice, Quot.sound]`, `lake build FormalSystem.Metalogic` green (the full
  build's only failure was a concurrent session's uncommitted edits in
  `Automation/DatasetGenerator.lean`, a module with zero imports from and zero mentions of
  `Chronicle/`). Live sorries outside `Boneyard/` unchanged. No `sorry`, no vacuous definition, no
  predicate threaded onto the terminus, no narrowing of the target class, no chronicle declaration
  edited, no closure enlarged, no witness-aware selection. Phase marked `[COMPLETED]` in v5 per
  the RESOLUTION block above.

### Phase 7.3: The guard gap lemma, above — `limitGuardAbove_of_priorU` (R3a) [COMPLETED]

**This is the Prior-U mirror of Phase 6.3 and the third place in the plan where the Dedekind axiom
layer is used.** `Axiom.prior_U_gap` has `minFrameClass = .Dedekind` (`Axioms.lean:524` block), so
both new theorems are `fc`-**conditional** on `FrameClass.Dedekind ≤ fc` — the settled shape for
every gap-facing obligation on this route.

**This phase is NOT a probe.** The route is determined, the axiom is identified, the statement is
**verified to elaborate against the tree**, the proof is written out step by step below against a
landed mirror, and no amendment is required. An analysis-only dispatch is a failed dispatch.

**Why the decomposition is forced rather than chosen.** Report 05 §3 proves `r3_invariant_necessary`
sorry-free: the conclusion of forward case B **entails its own hypothesis**, so
`BFMCS.LimitGuardEventual` is necessary as well as sufficient and forward case B has exactly one
possible content. This phase and 7.4 are the two halves of that single content. There is no third
route; do not look for one.

- **Goal:** Land the general Prior-U guard lemma and its chronicle discharge — the mirror of the
  landed `limitGuardBelow_of_priorS` — so that Phase 7.4's two unselected forward cases have their
  one missing ingredient in hand.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean` (new),
  and `FormalSystem/Metalogic/BXCanonical.lean` (**import line only** — this is the actual
  aggregator for the `Chronicle/` directory; there is no `Chronicle.lean`, as Phase 6.2's
  deviation note established). **No other file.** In particular: do **not** touch
  `ChronicleLimitGuardWitness.lean` (Phase 6.3's module — the template, byte-identical),
  `ChronicleRealExtension.lean` (Phase 7.4 owns it), `Bundle/RealExtensionBundle.lean`, or any
  chronicle declaration.
- **Literature grounding (H3, Tier 1 — this phase is transcription-grade).** The move is Reynolds'
  Theorem 3, **printed p.176**: *"Suppose for contradiction that `M ⊨ U'(A, B)(t)` in some Prior
  structure `M`. **Thus `B` holds for a while up until a gap** after which `¬B` is true arbitrarily
  soon. By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."*
  The discipline it instantiates — **apply the gap axiom to the formula uninterruptedly true on an
  interval abutting the gap, never to a witness** — is Reynolds' uniform practice across all seven
  of his §6 appeals (printed pp.176, 178), and here that formula is the **guard** `ψ`, whose
  interval is handed over by `hev`. Cite by printed PDF page in the module docstring; never by
  `md:NN`.
  **Scoping caveat to record in the docstring, and it is not optional**: Reynolds obtains his own
  gap-facing formulas "by expressive completeness" (**printed pp.176-178**), which the Postmortem
  Constraints forbid building and which is what killed R2. This phase does **not** inherit that
  dependency: `ψ` is a hypothesis binder, not a constructed formula. Only the Prior-U appeal is
  copied, never the machinery around it.
- **Tasks:**
  - [x] **Statement 1 — the general gap lemma.** In the new module, prove exactly (this statement
        was verified to elaborate against the tree in the report-05 dispatch; do not restate it):
        ```lean
        theorem limitGuardAbove_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
            (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
            (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl α β ∈ m t →
              ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
            (hUb : ∀ (t : Rat) (α β : Formula),
              (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
              Formula.untl α β ∈ m t)
            (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
            (hev : ψ ∈ limitSetBelow m r) :
            ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q
        ```
        Read: *a formula eventually true below an unselected real is true on an interval of
        rationals abutting it from above* — the `ψ`-region has no definable **left** gap at `r`.
        **Note the hypothesis shape**: `hUf`/`hUb` are the `.1` (`untl`) projections of
        `_fuc`/`_buc`, where Phase 6.3 used `.2`.
        **The substitution table against the landed mirror** `limitGuardBelow_of_priorS`
        (`ChronicleLimitGuardWitness.lean:105-207`) — this is a mirror, not a copy, and each row is
        a place a mechanical transcription goes wrong:

        | In 6.3 | Here |
        |---|---|
        | `snce` | `untl` |
        | `Axiom.prior_S_gap` | `Axiom.prior_U_gap` |
        | `Formula.kMinus` | `Formula.kPlus` (`Syntax/Formula.lean:180`) |
        | `.2` projections of `_fuc`/`_buc` | `.1` projections |
        | interval **above** the gap is the hypothesis; **below** is the conclusion | **below** is the hypothesis (`hev`); **above** is the conclusion |
        | every `<` between reals/rationals | reversed |

        Same plumbing as 6.3 and 6.2 (`htop`, `conj_mcs`,
        `theorem_in_mcs (DerivationTree.axiom … hfc)`, `implication_property`, `neg_excludes`,
        `negation_complete`, `exists_rat_btwn`). Proof, following report 05 §3 steps 1-4:
        - Fix a rational `x` inside the below-gap guard interval supplied by `hev`.
          `U(⊤, ψ) ∈ m x` from `hUb`, with `⊤ ∈ m ·` by the same three-line
          `theorem_in_mcs (hm ·) (identity (fc := fc) Formula.bot)` 6.2 and 6.3 already use.
        - **Case 1 — `¬ψ` never occurs above `x`.** The guard is free everywhere above, and the
          conclusion holds for any rational `c > x` (`exists_rat_gt`). Short; no axiom appeal.
        - **Case 2 — `F(¬ψ) ∈ m x`.** `Axiom.prior_U_gap` at `ψ` gives
          `untl (ψ.neg ∨ kPlus ψ.neg) ψ ∈ m x`; `hUf` gives an endpoint `e > x` with `ψ` on the
          rationals of `(x, e)`.
        - **`(e : ℝ) > r`.** Trichotomy. `(e : ℝ) < r` forces `ψ ∈ m e` (it is inside the below-gap
          interval), hence `kPlus ψ.neg ∈ m e`, contradicted by `U(⊤, ψ.neg.neg) ∈ m e` built from
          the below-gap interval via `hUb`. `(e : ℝ) = r` is excluded by `hr` — **this is the only
          use of unselectedness, exactly once**, as in 6.3. So `e` is the required `c`.
        Land each case and each interpolation as its own named `have` (or private lemma), exactly
        as Phases 5, 6.2 and 6.3 required. **Unselectedness is used exactly once**; a proof using
        it twice, or wrapping the whole argument in a `by_contra`, has drifted into copying 6.2.
  - [x] **Statement 2 — the chronicle discharge.** In the same new module, a verbatim clone of
        `cantor_bfmcs_dense_limit_guard_below` (`ChronicleLimitGuardWitness.lean`) with `.2 → .1`
        and `root := Formula.untl α β`:
        ```lean
        hUf := fun t α β h => (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
                 (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
        hUb := fun t α β h => (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
                 (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
        ```
        This works for the reason this plan's Closure discovery records: `_fuc`
        (`ChronicleToCountermodelBasic.lean:755`) and `_buc` (`:680`) are polymorphic in `root` and
        discard the closure-membership argument, so the side condition is
        `self_mem_subformulaClosure (Formula.untl α β)`. **No chronicle declaration is modified, no
        chronicle-level proof is written, and no closure is enlarged.** If the self-root
        instantiation does not elaborate, that is a signature discrepancy to report, **not** a
        licence to edit `_fuc`/`_buc`.
  - [x] Module docstring: cite Reynolds 1992 **printed p.176** (Theorem 3 — the Prior-U
        contradiction pattern this lemma is), **printed p.175** (`γ⁺` / left gaps — the pattern
        excluded), **printed p.178** (Lemma 3), and Burgess 1982 I **printed p.369** (no Dedekind
        variant, which is why the axiom is needed here at all). Record the
        expressive-completeness non-inheritance caveat above. **No task-number citations.**
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardAbove`, then
        full `lake build`.
  - [x] `#print axioms limitGuardAbove_of_priorU` and
        `#print axioms cantor_bfmcs_dense_limit_guard_above`; record the results.
- **Estimated output:** ~180-220 lines in the new module. **One agent run (H8).**
- **Done when:** both statements are sorry-free, full `lake build` is green, live sorries outside
  `Boneyard/` are unchanged at exactly `WeakCanonical/Transfer.lean:1242`, and `#print axioms` on
  both new theorems is `[propext, Classical.choice, Quot.sound]`. No `sorry`, no vacuous
  definition; if a step cannot be closed, mark the phase `[BLOCKED]` with the exact goal state for
  that step — **not** with a widened hypothesis set.
- **Amendment required:** **none.**
- **Timing:** 3 hours.
- **Depends on:** 7.2

### Phase 7.4: The bounded witness, `LimitGuardEventual`, and BOTH unselected forward cases (R3b + R3c) [COMPLETED]

**This phase repairs v4's CHARTER GAP.** `fully_restricted_parametric_completeness_from_neg_membership`
(`Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417-422`) consumes three coherence
hypotheses, and the `h_fuc` side needs **forward `snce` at an unselected target** as well as
forward `untl`. The `snce` half is landed nowhere and was chartered in **no phase of v4**. It is
chartered here, and report 05 §3 shows the same invariant discharges it **more cheaply** than the
`untl` half — with **no Prior-U step at all**.

**This phase is NOT a probe.** `boundedWitness_of_limitGuardBelow` is **already proved sorry-free**
(report 05 §3, twelve lines); the predicate's shape is verified to elaborate; the composition is
the identical shape Phase 6.1 used for `LimitFutureWitness`, which this plan explicitly permits
("Phase 6.1's conditional hypothesis was acceptable only because it was phase-internal with a
named discharge phase"). Here the named discharge phase is 7.5.

- **Goal:** Reduce the **entire** remaining forward obligation — both halves — to the single named
  predicate `BFMCS.LimitGuardEventual`, with everything else landed sorry-free.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (extends —
  **append only; regenerate nothing**), and the **new predicate definition only** in
  `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (append `BFMCS.LimitGuardEventual`
  beside `BFMCS.LimitFutureWitness` and `BFMCS.LimitGuardBelow`; change **nothing else** in that
  file — no proof script in it is restructured and neither existing predicate is touched). **No
  other file.** In particular: do **not** touch `ChronicleLimitGuardAbove.lean` (Phase 7.3's
  module), `ChronicleLimitGuardWitness.lean`, `ChronicleLimitGapWitness.lean`, or any chronicle
  declaration.
- **Amendment required:** **Amendment 1 only**, and it is **applied** in this plan version (see
  the Postmortem Constraints). No other amendment is needed, and none of Amendments 2-4 is in
  force — this phase must not touch `ChronicleConstruction.lean` or
  `CounterexampleElimination.lean`.
- **Literature grounding (H3, Tier 1 — transcription-grade).** The predicate is Reynolds' `γ⁺`
  condition, **printed p.175**: *"`γ⁺(A)` holds exactly when `A` **remains true for a while after
  now** but only up until a gap after which `A` is arbitrarily soon false."* "Holds for a while up
  until a gap" is exactly the eventually-true-below condition. The bounded witness's provenance is
  Burgess 1984 §2.7, **printed pp.109-110**, where the gap witness is placed on the far side with
  **no bound whatsoever**, licensed by `A7a` — Burgess needs no bound because `F`/`G` has no
  guard; here the bound is precisely what makes the guard interval finite. Cite by printed page.
- **The six-step chain this phase implements** (report 05 §3, for forward `untl` case B, given
  `ψ ∈ limitSetBelow m (t+δ)`). Recorded so no step is re-derived:
  1. Fix a rational `x` inside the below-gap guard interval; `U(⊤, ψ) ∈ m x` from `hUb`.
  2. If `¬ψ` never occurs above `x`, the guard is free everywhere above and Phase 6.2's
     `limitFutureWitness_of_priorU` (via `untl φ ψ ⊢ someFuture φ`) supplies the witness. Done.
  3. Otherwise `F(¬ψ) ∈ m x`; `Axiom.prior_U_gap` at `ψ` gives `untl (ψ.neg ∨ kPlus ψ.neg) ψ ∈ m x`
     and `hUf` an endpoint `e > x` with `ψ` on `(x, e)`.
  4. `e > t + δ`, with unselectedness used **exactly once** to exclude `e = t+δ`.
     **Steps 1-4 are Phase 7.3's `limitGuardAbove_of_priorU` — consume it, do not inline it.**
  5. `boundedWitness_of_limitGuardBelow` at `c := e`, with the dichotomy's cofinal `φ`, yields a
     rational `w ∈ (t+δ, e)` with `φ ∈ m w`.
  6. `(w : ℝ) - δ` is the real witness; the **landed** `guard_transport_realLimitMCS` (`:283`)
     carries the guard on `(x, e)` to every real strictly between.
- **Tasks:**
  - [x] **Statement 1 — the bounded witness. TRANSCRIBE, do not re-derive.** This proof is already
        verified sorry-free against the real tree; reproduce it as written in report 05 §3:
        ```lean
        theorem boundedWitness_of_limitGuardBelow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
            (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
            (hSf …) (hSb …)
            (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
            (hcof : ∀ z : ℝ, z < r → ∃ w : Rat, z < (w : ℝ) ∧ (w : ℝ) < r ∧ φ ∈ m w)
            (c : Rat) (hc : r < (c : ℝ)) :
            ∃ w : Rat, r < (w : ℝ) ∧ (w : ℝ) < (c : ℝ) ∧ φ ∈ m w := by
          by_contra hcon
          push_neg at hcon
          have hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → φ.neg ∈ m q := by
            intro q h1 h2
            rcases SetMaximalConsistent.negation_complete (hm q) φ with h | h
            · exact absurd h (hcon q h1 h2)
            · exact h
          obtain ⟨z, hz, hall⟩ := limitGuardBelow_of_priorS hfc m hm hSf hSb r hr φ.neg c hc hguard
          obtain ⟨w, hzw, hwr, hphi⟩ := hcof z hz
          exact SetMaximalConsistent.neg_excludes (hm w) φ (hall w hzw hwr) hphi
        ```
        **Its `hcof` hypothesis is available free**: it is *literally the right disjunct* of the
        landed `toRealBundle_forward_until_unselected_dichotomy` (`:732`). This is a **corollary of
        Phase 6.3 at the forward-case-B call site**, which Amendment 1 permits and requires; it is
        **not** the prohibited bounded-witness *route* (do not attempt to derive it from
        `BFMCS.LimitFutureWitness` — finding (i) shows it is not derivable).
  - [x] **Statement 2 — the bundle predicate.** Append to `Bundle/RealExtensionBundle.lean`:
        ```lean
        def BFMCS.LimitGuardEventual {fc : FrameClass} (B : BFMCS (fc := fc) Rat) : Prop :=
          ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ φ ψ : Formula,
            (Formula.untl φ ψ ∈ limitMCSBelow fam.mcs r ∨
             Formula.snce φ ψ ∈ limitMCSBelow fam.mcs r) →
            ψ ∈ limitSetBelow fam.mcs r
        ```
        **State it closure-free and with no `root` argument**, for the identical reason Phase 6.3
        recorded for `LimitGuardBelow`: the guard `ψ` of an `untl φ ψ ∈ subformulaClosure root`
        need not lie in `deferralClosure root`, so a closure hypothesis would be an unprovable side
        condition at the call site. Docstring: record the `γ⁺` reading (Reynolds printed p.175),
        the closure-free decision with its reason, **and — in one sentence — that this predicate is
        necessary as well as sufficient** (report 05 §3), so a later reader does not go looking for
        a weaker one. **No task-number citations.**
  - [x] **Statement 3 — forward `untl` at an unselected target.**
        `toRealBundle_forward_until_unselected`, by the six-step chain above, consuming Phase 7.3's
        `limitGuardAbove_of_priorU` for steps 1-4, Statement 1 for step 5, and the landed
        `guard_transport_realLimitMCS` for step 6. Consume the landed forward case A
        (`forward_until_witness_of_straddling_rat`) and the dichotomy rather than re-deriving them.
  - [x] **Statement 4 — forward `snce` at an unselected target (THE CHARTER GAP).**
        `toRealBundle_forward_since_unselected`. **This half needs no Prior-U step at all**: the
        obligation is `∃ s < t` with `φ` at `s` and `ψ` on `(s, t)`, i.e. `ψ` on rationals abutting
        `t + δ` **from below** — which *is* `ψ ∈ limitSetBelow m (t+δ)`, verbatim, straight from
        the predicate; the `φ` comes from the same cofinal descent
        (`limitMCSBelow_cofinal_below`). It is the **cheaper** of the two cases. Do not mirror
        Statement 3's machinery here — an implementer invoking `limitGuardAbove_of_priorU` in this
        statement has misread the obligation's direction.
  - [x] **Statement 5 — the composition.** *(deviation: altered — the binder list below is not
        provable as written; see the DEVIATION note at the end of this phase for the landed
        signature and why the change is forced.)*
        ```lean
        theorem BFMCS.toRealBundle_restricted_forward_until_since {fc : FrameClass}
            (B : BFMCS (fc := fc) Rat) (root : Formula)
            (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
            (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
            (h_lgb : B.LimitGuardBelow)
            (h_lge : B.LimitGuardEventual) :
            (B.toRealBundle).RestrictedForwardUntilSinceCoherent root
        ```
        (target predicate at `Bundle/TemporalCoherence.lean`; mirror the binder discipline of the
        landed `BFMCS.toRealBundle_restricted_backward_until_since`). Consume the two landed
        selected-target lemmas (`toRealBundle_forward_until_selected` `:334`,
        `toRealBundle_forward_since_selected` `:361`) for the selected cases rather than inlining
        or reproving them. Each case gets its own named `have` or private lemma.
        **Do NOT land `cantor_bfmcs_dense_real_restricted_fuc` in this phase.** It requires
        discharging `LimitGuardEventual`, which is Phase 7.5's deliverable and is user-gated. A
        chronicle instance stated with `LimitGuardEventual` as an *undischarged argument* is
        permitted only as a phase-internal composition, never as a step toward the terminus.
  - [x] Module docstring: record that the forward side is now reduced to exactly one named
        predicate, that the predicate is **necessary as well as sufficient**, and that its
        discharge is deferred to a user-gated phase because it **has no source in the corpus**.
        Cite Reynolds printed pp.175-176 and Burgess 1984 printed pp.109-110 by printed page.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension` and
        `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`, then full `lake build`.
  - [x] `#print axioms` on all five new declarations; record the results.
- **Estimated output:** ~200-240 lines appended to `ChronicleRealExtension.lean`, plus ~15 lines
  appended to `RealExtensionBundle.lean` for Statement 2 and its docstring. **One agent run (H8).**
  If the run overruns, the sanctioned split is Statements 1+2+4 in one dispatch and Statements 3+5
  in a second — **report the split; do not silently re-dispatch against the same target.**
- **Done when:** all five statements are sorry-free; full `lake build` is green; live sorries
  outside `Boneyard/` are unchanged at exactly `WeakCanonical/Transfer.lean:1242`; `#print axioms`
  on each is `[propext, Classical.choice, Quot.sound]`; **and both `h_fuc` sub-obligations are
  landed by name** — `toRealBundle_forward_until_unselected` **and**
  `toRealBundle_forward_since_unselected`. A dispatch that lands only the `untl` half has
  reproduced v4's charter gap and is not done.
- **Prohibited in this phase:** no `sorry`; no vacuous definition; **no** chronicle declaration
  edited; **no** closure enlarged; **no** predicate threaded onto `countermodel_dedekind_dense`,
  `completeness_dedekind_engine`, `consequence_completeness_dedekind` or `completeness_dedekind`;
  **no** attempt at `cantor_bfmcs_dense_real_restricted_fuc`; **no** attempt to discharge
  `LimitGuardEventual` (that is 7.5, and it is gated). If a statement cannot be closed, mark the
  phase `[BLOCKED]` with the exact goal state.
- **Timing:** 4 hours.
- **Depends on:** 7.3

**DEVIATION (Statement 5's binder list, recorded by the 7.4 dispatch).** The signature drafted
above is **not provable as written**, and the reason is structural rather than tactical. The
chartered six-step chain consumes two things that neither `h_rfuc`, `h_rbuc`, `h_lgb` nor `h_lge`
can supply:

- **Steps 1-4** are `limitGuardAbove_of_priorU`, whose hypotheses are `FrameClass.Dedekind ≤ fc`
  plus *unrestricted* Until coherence in both directions. Restricted-at-`root` coherence does not
  give it: the lemma applies Prior-U at `ψ`, `⊤` and `¬ψ ∨ K⁺(¬ψ)`, none of which lie in
  `subformulaClosure root`. Per this dispatch's territory (`ChronicleLimitGuardAbove.lean` is not
  extended, and no `BFMCS.LimitGuardAbove` predicate may be added), its **conclusion is written out
  explicitly** as the binder `h_lga`.
- **Step 5** is Statement 1, transcribed verbatim as the plan requires, and it consumes
  `limitGuardBelow_of_priorS` directly — hence `hfc`, `hSf`, `hSb`. `h_lgb` is the *packaged
  conclusion* of that lemma and cannot stand in for its ingredients without re-deriving Statement 1
  at the bundle level, which "TRANSCRIBE, do not re-derive" forbids.

Landed signature (sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`):

```lean
theorem BFMCS.toRealBundle_restricted_forward_until_since {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc) (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (hSf : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ fam.mcs t → …)
    (hSb : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula), … → Formula.snce α β ∈ fam.mcs t)
    (h_lga : ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ χ : Formula,
      χ ∈ limitSetBelow fam.mcs r →
      ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → χ ∈ fam.mcs q)
    (h_lge : B.LimitGuardEventual) :
    (B.toRealBundle).RestrictedForwardUntilSinceCoherent root
```

`h_rbuc` and `h_lgb` are **dropped**: the forward composition consumes neither. Backward coherence
enters nowhere (the eventuality route through `limitSetBelow_someFuture_of_cofinal` is not needed —
`limitGuardAbove_of_priorU` already absorbs its case internally), and the below-gap guard is
consumed only inside Statement 1, through `hSf`/`hSb`. At a chronicle call site every added binder
is discharged from assets that already exist: `h_lga` by `cantor_bfmcs_dense_limit_guard_above`, and
`hSf`/`hSb` by the same self-root instantiation of `cantor_bfmcs_dense_restricted_fuc`/`_buc` that
`cantor_bfmcs_dense_limit_guard_above` and `cantor_bfmcs_dense_limit_guard_below` already use. So
the deviation adds **no new obligation** to the route; `BFMCS.LimitGuardEventual` remains the sole
undischarged residual, exactly as this phase's Goal states.

### R3d (Phases 7.5-7.9): the chronicle discharge of `LimitGuardEventual` — umbrella charter

> **This heading is deliberately NOT of the form `### Phase N: …`, so the orchestrator's phase scan
> can never select it.** It is the shared charter for the five sub-phases that follow. Dispatch
> targets are `### Phase 7.5` through `### Phase 7.9`, in that order.

> **STATUS: AUTHORIZED.** Fresh explicit user authorization was granted at the v5 → v6 revision and
> is quoted verbatim in the Revision Rationale: *"R3d AUTHORIZED. Amendments 2-4 may now be
> applied. Phase 7.5 to be decomposed into agent-run-sized sub-phases and implemented as an
> original construction held to the same rigor (counterexample checks, adversarial verification,
> literature-honest docstrings stating the construction has no source). Phase 8 remains gated until
> LimitGuardEventual is discharged."* **Amendments 2, 3 and 4 are APPLIED** in the Postmortem
> Constraints, dated 2026-07-27. The authorization is scoped to R3d and relaxes nothing else.

**Honest framing, retained in full and unsoftened. The authorization was granted with all six of
these facts stated; none of them is withdrawn by it.**

1. **It has NO source in the corpus.** This is the finding, not a caveat. Report 05 §1.5, against
   all three primary sources re-read verbatim:
   - **Burgess 1984** does not need it: his completion runs in `F`/`G`, which has **no guard**, and
     his one "above the gap ⟹ below the gap" conversion comes from **axiom A7a**, not from
     selection (printed pp.109-110). His chronicle is arbitrary and his gap MCS is "**some MCS
     extending** `C(Y,Z)`" — there is no scheduling discipline anywhere in his argument.
   - **Burgess 1982 I** has the guard (his interval datum `g(x,y)`) but **never reaches a gap**:
     no Dedekind variant exists in his table (printed p.369) and every witness is a **fresh**
     point, `y = x + 1` or `z = (x + x')/2` (printed pp.372-373). He has no accumulation
     bookkeeping because he needs none — and **the tree transcribes his discipline exactly**
     (`CounterexampleElimination.lean` `witness_not_old` `:677`, the midpoint split `:671,707,2243`,
     the three-case walk docstring `:680-687` with Burgess's own numbering).
   - **Reynolds 1992** has both, and gets every gap-facing formula from **expressive completeness**
     (printed pp.176-178) — forbidden by the Postmortem Constraints and already fatal to R2.

   **R3d would be an original construction, not a transcription.** The task's name and charter are
   *faithful route*. This is a first-order finding.
2. **It modifies the two largest, most invariant-laden files on the route.** It requires a new
   field on the finite-stage invariant `ChronicleInvariant` (`ChronicleTypes.lean:745`) of the
   shape *"for every `ψ` in the (finite) closure, every ascending sequence of `¬ψ`-points in `dom`
   bounded above in `dom` has a least upper bound in `dom`"*, established at stage 0, preserved by
   **every** branch of `eliminatePotentialCounterexample` (`c5_forward_walk`, `c5_backward_walk`,
   `c4_forward`, `c4_backward`), and transported to `LimitDom`. `CounterexampleElimination.lean` is
   >3000 lines and its placement is Burgess's verbatim, so this is a **redesign of the
   witness-placement discipline**, not a patch.
3. **It is the first gap-facing obligation on this route not discharged by a frame-class axiom.**
   Every prior one — `LimitFutureWitness` via `prior_U_gap`, `LimitGuardBelow` via `prior_S_gap` —
   was. Report 05 §4.1 proves no axiom can supply this one: `prior_U_gap`'s antecedent **is** the
   conclusion, `prior_S_gap` yields only the necessity direction, and `sep` is entirely `K⁺`/`K⁻`,
   the negation of "holds on an interval". Its discharge would be a property of the **construction**,
   not of the **logic**. That is a genuine departure from this plan's settled shape (Amendment 4
   exists to record exactly that).
4. **It is NOT one agent run.** The invariant is not local to an insertion — it constrains the
   *limit* of infinitely many insertions, so it needs a scheduling argument over the ω-chain, not a
   per-stage lemma. **(v6: this is why the authorization required a decomposition, and it is
   supplied — Phases 7.5-7.9, each bounded to one agent run per H8, each ending green. The
   scheduling argument itself is step 1 of Phase 7.9 and is budgeted as the bulk of that phase.)**
5. **The base rate is against it.** Every prior escalation on this task that lacked a source —
   `limitMCS_no_oscillation`, the `fc`-generic backward transport, the bounded-witness detour *as
   a route*, R2 — was subsequently refuted or killed. That is a fact about this task and belongs
   in the decision.
6. **It is not proved impossible either.** Report 05 §5.3: the closure is a `Finset`, so only
   finitely many guard formulas matter; no formula can *force* accumulation at a gap; the chronicle
   already retains Burgess's interval datum `g(x,y)` (`CounterexampleElimination.lean:660`) needed
   to state the invariant; and `eliminatePotentialCounterexample`'s existing `h_actual` reuse check
   makes a witness-reusing discipline at least conceivable. **R3 is neither proved live nor proved
   dead.** The candidate refutation is now ultrafilter-**independent** (family `Q`, §5.1), and
   settling *its* realizability needs the forbidden machinery.

#### Umbrella target and territory map

- **Block target:** `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` — i.e.
  `(Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).LimitGuardEventual` — plus
  `cantor_bfmcs_dense_real_restricted_fuc`, both landed by **Phase 7.9**. These two declarations
  are the whole of what Phase 8 waits on.
- **Files the block owns, across all five sub-phases** (each sub-phase owns a strict subset, stated
  on its own **Owns** line; no sub-phase may touch a file outside its own subset):
  - `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean` — **new**, 7.5.
  - `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (3,622 lines) —
    7.6 (forward walk region), 7.7 (backward walk region), 7.8 (`EliminationResult` +
    `eliminatePotentialCounterexample`).
  - `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (1,564 lines) — 7.8
    (ω-chain subtype) and 7.9 (limit transport).
  - `FormalSystem/Metalogic/BXCanonical.lean` — import lines only, 7.5 and 7.9.
- **Verified territory anchors** (surveyed directly at this revision; verify before editing, and
  treat any mismatch as a signature discrepancy to report, not a licence to widen):

  | Object | Anchor | Note |
  |---|---|---|
  | `Chronicle` (fields `f`, `g`, `dom : Finset Rat`) | `ChronicleTypes.lean:551` | field order is `f`, `g`, `dom` |
  | `Adjacent` | `ChronicleTypes.lean:330` | |
  | `ChronicleInvariant` (`hc0`, `hc1`, `hc2'`, `hc3`) | `ChronicleTypes.lean:745` | **only** consumer is `singleton_invariant`; **not** threaded through the ω-chain |
  | `singletonChronicle` / `singleton_invariant` | `ChronicleConstruction.lean:70` / `:103` | stage 0 |
  | `omegaChain` — subtype `{ χ : Chronicle // χ.c0 fc ∧ χ.c2' fc }` | `ChronicleConstruction.lean:262` | **this** is what the ω-chain actually carries |
  | `omegaChainVal`, `omega_chain_c0`, `omega_chain_c2'` | `:275`, `:283`, `:290` | projections that change shape if the subtype widens |
  | `counterexampleEnum`, `counterexample_enum_surjective` | `:209`, `:218` | surjective onto **all** records — a domain point is revisited infinitely often |
  | `LimitDom`, `LimitF`, `LimitG` | `:579`, `:589`, `:867` | |
  | `omega_chain_g_sub_f_insert` | `:1300` | Burgess's interval datum surviving into the chain |
  | `limit_F_resolution`, `limit_satisfies_c4`, `limit_satisfies_c5_strong` | `:722`, `:776`, `:1482` | **statements frozen by Amendment 2's proviso** |
  | `EliminationResult` (incl. `g_sub_f_insert :617`) | `CounterexampleElimination.lean:580` | |
  | `C5ForwardWalkResult` (incl. `witness_not_old :678`) | `:646` | |
  | `c5_forward_walk` — **private noncomputable def** | `:690` | |
  | `C5BackwardWalkResult` (incl. `witness_not_old :1282`) | `:1254` | |
  | `c5_backward_walk` — **private noncomputable def** | `:1295` | |
  | `eliminatePotentialCounterexample` | `:1880` | C4 elimination is **inline here**; there are no `c4_forward` / `c4_backward` lemmas |
  | `lemma_2_4_with_guard`, `lemma_2_4_since_with_guard`, `lemma_2_6/2_7/2_8` | `PointInsertion.lean:3455`, `:3615`, `:318`/`:2267`/`:2570` | the walks' insertion primitives live **here**, not in `CounterexampleElimination.lean` |
  | `cantorIsoDense`, `cantorBfmcsDense` | `ChronicleToCountermodelBasic.lean:236`, `:552` | `cantorIsoDense` is **not** editable |
  | `BFMCS.LimitGuardEventual` | `Bundle/RealExtensionBundle.lean:369` | **statement frozen**; discharge only |

- **Two corrections to the drafted R3d sketch, on direct evidence, that every sub-phase must know.**
  Report 05 §6 and Amendment 2's drafted text were written before the tree was surveyed at this
  level, and two of their premises are wrong in ways that would cost a dispatch each:
  1. **`ChronicleInvariant` is not the finite-stage invariant.** It is used only by
     `singleton_invariant`. The ω-chain carries `{ χ // χ.c0 fc ∧ χ.c2' fc }` (`:262`). Extend
     **that**, and the walk/elimination result structures — not `ChronicleInvariant`.
  2. **There are no `c4_forward` / `c4_backward` lemmas.** Those names are constructors of
     `PotentialCounterexampleKind` and fields of `EliminationResult`; C4 elimination is inline in
     `eliminatePotentialCounterexample`. The only walks are the two C5 ones. The sub-phase split
     reflects the real structure, not the sketch's.
- **Prohibited across the whole block** (in addition to every standing Postmortem Constraint): no
  `sorry` in any sub-phase, including as a placeholder for a later one; no change to the six
  statements frozen by Amendment 2's proviso; no closure enlargement; no `cantorIsoDense` edit; no
  restatement or weakening of `BFMCS.LimitGuardEventual`; no predicate threaded onto the terminus
  chain; no expressive completeness, EF games or `≡_k`; no witness-aware **selection** (the
  `Ultrafilter.of` choice and every descent asset through `limitMCSBelow_cofinal_below` are
  untouched — R3d changes the construction, never the selection); and no docstring that cites a
  source without the ADAPTED-FROM qualifier or omits the no-source statement.
- **Two-outcome protocol.** Every sub-phase inherits the family-`Q` risk-register entry: it either
  advances the invariant (Outcome A) or exhibits the obstruction that defeats it (Outcome B, with
  its three required deliverables). Outcome B is a `[BLOCKED]` sub-phase and a `[PARTIAL]` task,
  never a `sorry` and never a widened hypothesis set.
- **Depends on:** 7.4, and the explicit user authorization granted 2026-07-27.

---

### Phase 7.5: The guard-accumulation invariant and the payoff implication (R3d-1) [NOT STARTED]

**Risk-first, and it touches NO construction file.** This sub-phase answers the question that makes
all the rest worth doing: *does a Dedekind-closedness invariant on the guard-failure classes
actually deliver `BFMCS.LimitGuardEventual`?* If it does not, R3d dies here for the price of one
agent run, before anything edits a 3,622-line file.

**This phase is NOT a probe** — it has three named deliverables and a build criterion. But it is
the phase where the invariant's exact form is **chosen**, and that choice is genuine design work
with no source. The charter therefore fixes the *properties* the invariant must have and leaves the
implementer free to pick the formulation that satisfies them, **reporting the chosen form
verbatim** in the summary so 7.6-7.9 can be held to it.

- **Goal:** State the guard-accumulation invariant at the ℚ level, prove that it implies
  `BFMCS.LimitGuardEventual`, and demonstrate that it excludes report 05 §5.1's family `Q`.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean` (**new**)
  and `FormalSystem/Metalogic/BXCanonical.lean` (**import line only**). **No other file.** In
  particular: do **not** touch `CounterexampleElimination.lean`, `ChronicleConstruction.lean`,
  `ChronicleTypes.lean`, `Bundle/RealExtensionBundle.lean`, or any declaration landed by Phases
  7.3/7.4.
- **Literature grounding (H3) — there is none, and the docstrings must say so.** This is the first
  phase of the plan with **no source**. `BFMCS.LimitGuardEventual`'s own statement may be cited to
  Reynolds' `γ⁺` / left gaps (**printed p.175**) — that citation is accurate and already landed —
  but nothing about its *discharge* may be attributed to anyone. Apply the honesty charter: every
  new declaration states the no-source fact, and the only permitted source citations are
  **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373** and **ADAPTED-FROM: Burgess 1984 §2.7,
  printed pp.109-110**.
- **Tasks:**
  - [ ] **Deliverable 1 — the invariant, stated at the ℚ level.** Define a predicate on a rational
        MCS family and a finite guard set, of the shape

        ```lean
        def NoGuardAccumulation (m : Rat → Set Formula) (G : Finset Formula) : Prop
        ```

        expressing *"for every guard `ψ ∈ G`, the `¬ψ`-points of `ℚ` do not accumulate at an
        unselected real from below"*. The order-theoretic characterization that makes this the
        right shape is report 05 §4.2, written out in both directions: for `S ⊆ ℚ`, *"`S`
        accumulates at some irrational `T` from below"* is equivalent to *"there is `S₀ ⊆ S` with no
        maximum, bounded above in `ℚ`, whose set of upper bounds in `ℚ` has no minimum"* —
        mentioning only `<`, boundedness, maxima and minima, hence **invariant under any order
        isomorphism**, hence transportable through `cantorIsoDense`. That transportability is what
        7.9 will consume; state the invariant so that it is manifestly order-theoretic.
        **Required properties, and the implementer may choose any formulation satisfying all
        three** (report the chosen one verbatim):
        **(P1)** it implies `BFMCS.LimitGuardEventual` for a bundle all of whose families satisfy
        it at the guard set of `subformulaClosure root` — this is Deliverable 2;
        **(P2)** it is satisfiable — `singletonChronicle`'s family satisfies it vacuously, since a
        one-point domain has nothing to accumulate (a cheap check, but do it, and record it: a
        formulation stage 0 fails is the wrong formulation and 7.8 would discover that four
        dispatches later);
        **(P3)** family `Q` violates it — Deliverable 3.
        **Do NOT state it unconditionally over all formulas.** An invariant asserting that every
        `ψ` in the closure is eventually true below every unselected real is **false** — formulas
        genuinely oscillate — and a phase that "proves" it has proved something wrong. The
        invariant must be conditioned on the guard's own `untl`/`snce` obligation being live below
        the point, exactly as `LimitGuardEventual` is. **Do NOT enlarge any closure**: the guard
        set is *indexed by* `subformulaClosure root`, which is a `Finset`
        (`SubformulaClosure/Closure.lean:36`), and indexing is not enlarging (Amendment 3).
  - [ ] **Deliverable 2 — the payoff implication.** Prove
        `limitGuardEventual_of_noGuardAccumulation` (name at the implementer's discretion; report
        it): a bundle whose every family satisfies the invariant at the relevant guard set
        satisfies `BFMCS.LimitGuardEventual`. **This is the load-bearing direction.** The residual
        content is the step from "the `¬ψ`-set is not cofinal below `r`" to
        "`ψ ∈ limitSetBelow m r`", which goes through `SetMaximalConsistent.negation_complete` at
        each rational plus the definition of `limitSetBelow` (`Bundle/LimitMCS.lean:136-137`:
        `{A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < q → q < r → A ∈ m q}`). Consume
        `limitMCSBelow_cofinal_below` for the descent from the `untl`/`snce` antecedent; **do not
        modify it and do not touch the ultrafilter**.
  - [ ] **Deliverable 3 — the family-`Q` counterexample check, landed as an artefact.** Show that
        family `Q` (report 05 §5.1: one atom `P`, irrational `T`, `t_n ↗ T`, `u_n ↓ T`,
        `V(P) = {t_n} ∪ {u_n}`, `φ := P`, `ψ := ¬P`) **violates** the invariant, as a Lean
        statement — at minimum, a lemma that the invariant fails for any family whose `¬ψ`-set is
        cofinal below an unselected real, instantiated at `Q`'s shape. **Why this is required and
        not optional**: it is what distinguishes a real invariant from a vacuous or
        trivially-satisfied one, and it is the falsification target for Phases 7.6-7.8. An
        invariant that `Q` satisfies would be useless and must be rejected and reformulated **in
        this phase**, not discovered in 7.8. **Do NOT attempt to settle whether `Q` is realizable
        at `fc = FrameClass.Dedekind`** — that needs the forbidden EF / modal-depth machinery, it is
        an explicit Non-Goal, and it is not what this deliverable asks. The question here is only
        whether the invariant *excludes the pattern*.
  - [ ] Module docstring: state the no-source fact per the honesty charter; record the chosen
        invariant form and **why** it was chosen over the alternatives considered; record the
        order-theoretic characterization (report 05 §4.2) and the fact that it is what makes the
        invariant transportable through `cantorIsoDense` in 7.9; record that `Q` is excluded and
        that this says nothing about `Q`'s abstract realizability. Cite Reynolds **printed p.175**
        for the `γ⁺` statement being discharged, and nothing else as a source. **No task-number
        citations.**
  - [ ] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleGuardAccumulation`, then
        full `lake build`.
  - [ ] `#print axioms` on each new declaration; record the results.
- **Estimated output:** ~250-350 lines in the new module. **One agent run (H8).**
- **Done when:** the invariant is defined; the payoff implication (P1) is proved sorry-free; (P2)
  and (P3) are recorded as landed Lean, not as prose; full `lake build` is green; live sorries
  outside `Boneyard/` are unchanged at exactly `WeakCanonical/Transfer.lean:1242`; `#print axioms`
  on each new declaration is `[propext, Classical.choice, Quot.sound]`.
- **Outcome B trigger for this phase:** if no formulation satisfying (P1)-(P3) can be found — in
  particular if every formulation strong enough for (P1) already fails (P2) at stage 0 — that is a
  route-level finding about the invariant's shape, not a tactical one. Mark `[BLOCKED]` with the
  formulations tried and the exact goal state each failed at, and do **not** proceed to 7.6.
- **Prohibited in this phase:** no `sorry`; no vacuous definition (`:= True`, `:= trivial`,
  `:= Unit`) — and note that a vacuously-satisfied invariant is exactly what (P3) exists to catch;
  no edit to any construction file; no edit to `Bundle/RealExtensionBundle.lean`; no restatement of
  `BFMCS.LimitGuardEventual`; no attempt at any chronicle-level discharge (that is 7.6-7.9).
- **Timing:** 4 hours.
- **Depends on:** 7.4 + the R3d authorization.

### Phase 7.6: Invariant preservation across `c5_forward_walk` (R3d-2) [NOT STARTED]

**The first construction surgery, and the first place family `Q` can bite.** Burgess's forward
Until-witness walk is transcribed verbatim in the tree; this phase asks whether its placement
discipline preserves 7.5's invariant, and — under Amendment 2 — may alter that placement if it does
not.

- **Goal:** Carry 7.5's invariant through `c5_forward_walk` as a field of its result structure,
  discharged in all three of Burgess's cases.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`,
  **restricted to the forward-walk region** — `C5ForwardWalkResult` (`:646-689`) and
  `c5_forward_walk` (`:690-~1253`). **No other region of that file and no other file.** In
  particular: do **not** touch `C5BackwardWalkResult` / `c5_backward_walk` (7.7 owns them),
  `EliminationResult` or `eliminatePotentialCounterexample` (7.8 owns them),
  `ChronicleConstruction.lean` (7.8/7.9), `PointInsertion.lean` (the insertion primitives are
  consumed as landed, never edited), or `ChronicleGuardAccumulation.lean` (7.5's module — consume
  it).
- **Why a structure field and not an external lemma.** `c5_forward_walk` is a
  **`private noncomputable def`** (`:690`), so no other module can state a preservation lemma about
  it. The property must be a field of `C5ForwardWalkResult` and be discharged inside the file. This
  is the shape Amendment 2 licenses, and it is why the walks are separate sub-phases.
- **Why this ends green.** Adding a field to a structure that a `def` *produces* leaves every
  consumer building unchanged — `eliminatePotentialCounterexample` gains an available field it does
  not yet use. Full `lake build` must be green at the end of this phase.
- **Literature grounding (H3) — ADAPTED-FROM only.** The placement being constrained is Burgess's:
  **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373** — *"it is possible to **add a single
  point `y` lying after `x`**"*; *"Set `y = x + 1`"* (base case, beyond the maximum); *"Set
  `z = (x + x')/2`"* (split case, the midpoint of `(x, x')`). The tree transcribes this exactly
  (`witness_not_old :678`, the three-case walk). **Burgess has no accumulation bookkeeping because
  he never reaches a gap** — his variants table (printed p.369) has no Continuity row. The
  constraint this phase adds is therefore **original work adapting his placement**, and every
  docstring must say so.
- **Tasks:**
  - [ ] **Add the preservation field to `C5ForwardWalkResult`** (`:646`), stating that the walk's
        result satisfies 7.5's invariant given that its input chronicle does. Mirror the binder
        style of the existing fields (`g_sub_f_insert :660`, `dom_new_unique :664`,
        `new_point_after :667`, `domain_guard :673`, `witness_not_old :678`).
  - [ ] **Discharge it in the base case** (`start = max dom`; witness inserted beyond via
        `exists_rat_gt_finset` / `lemma_2_4_with_guard`, `PointInsertion.lean:3455`). A witness
        placed beyond the current maximum cannot contribute to accumulation at a point below it;
        this should be the cheapest case. Land it as its own named `have` or private lemma.
  - [ ] **Discharge it in the condition-(i) recursion case** (both `η ∧ U(ξ,η) ∈ f(x')` and
        `η ∈ g(x,x')`, so the walk reduces to `x'` and composes the guard). No new point is
        inserted in the reduction step itself, so the obligation is compositional; the content is
        threading the invariant through the recursion, which is where an induction-measure mismatch
        will show up if the field is stated wrongly.
  - [ ] **Discharge it in the split case** — the midpoint `z = (x + x')/2`, via
        `lemma_2_7`/`lemma_2_8`/`lemma_2_6` (`PointInsertion.lean:2267`/`:2570`/`:318`). **This is
        the hard case and the one family `Q` targets**: repeated midpoint insertions into a
        shrinking interval are exactly the pattern that accumulates, and `counterexampleEnum` is
        surjective onto **all** records (`ChronicleConstruction.lean:218`), so a single domain point
        is revisited infinitely often. Two admissible routes, and the phase must report which it
        took:
        **(a) Preservation as-is** — show the existing midpoint discipline already preserves the
        invariant, e.g. because each insertion's accumulation target is a *domain* point (which is
        selected, hence never an unselected real, hence harmless — report 05 §5.3's observation
        that a formula can force accumulation only at a **point**, via `K⁻(¬ψ)`).
        **(b) Placement change under Amendment 2** — alter where the split witness goes so that
        accumulation is excluded by construction (for instance by reusing an existing witness when
        one exists, which `eliminatePotentialCounterexample`'s `h_actual` check already
        contemplates, or by a placement rule that keeps the insertion points away from the previous
        stage's guard-failure closure). **This is the authorized original construction.** If taken,
        the docstring must state plainly that the placement now **departs from** Burgess's
        (ADAPTED-FROM, printed pp.372-373) and why, and the departure must be recorded as a
        deviation in the phase summary.
        **Do NOT silently change the placement** — route (b) is permitted, undocumented route (b)
        is a defect.
  - [ ] Docstrings on the new field and every new lemma: the no-source statement, plus
        ADAPTED-FROM citations with printed pages per the honesty charter. Record which route
        (a)/(b) was taken. **No task-number citations.**
  - [ ] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.CounterexampleElimination`, then
        full `lake build`.
- **Estimated output:** ~300-450 lines. **One agent run (H8).** If it overruns, report the exact
  remaining case and its goal state; **do not silently re-dispatch against the same target** (H6).
- **Done when:** `C5ForwardWalkResult` carries the preservation field; all three cases discharge it
  sorry-free; full `lake build` is green; live sorries outside `Boneyard/` unchanged at exactly
  `WeakCanonical/Transfer.lean:1242`; the six statements frozen by Amendment 2's proviso are
  unchanged (`git diff` check); and the route (a)/(b) taken in the split case is reported.
- **Outcome B trigger for this phase:** if the split case provably cannot preserve the invariant
  under **any** admissible placement — i.e. the accumulation is forced by the enumeration order
  rather than by the placement rule — that is the family-`Q` falsification. Deliver the three
  required items from the risk register (exact branch + goal state; the explicit insertion sequence
  and its limit point; whether the obstruction is intrinsic to fresh-point placement or an artefact
  of enumeration order), mark this phase `[BLOCKED]`, mark the task `[PARTIAL]`, and stop. **Do not
  proceed to 7.7, do not widen the field's statement to something provable-but-useless, and do not
  `sorry` it.**
- **Prohibited in this phase:** no `sorry`; no vacuous field; no edit outside the forward-walk
  region; no change to any of the six frozen statements; no closure enlargement; no
  `cantorIsoDense` edit; no edit to `PointInsertion.lean`; no witness-aware selection.
- **Timing:** 5 hours.
- **Depends on:** 7.5

### Phase 7.7: Invariant preservation across `c5_backward_walk` (R3d-3) [NOT STARTED]

**The mirror of 7.6, and it is a mirror, not a copy.** The same three-case structure runs
backwards: `y < pt`, the guard interval is `y ≤ a → b ≤ pt`, and the insertion primitives are the
Since-side ones. Every inequality reverses. That is exactly where a mechanical transcription goes
wrong, as Phase 7.3 already recorded for a different mirror on this route.

- **Goal:** Carry 7.5's invariant through `c5_backward_walk` as a field of its result structure,
  discharged in all three cases.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`,
  **restricted to the backward-walk region** — `C5BackwardWalkResult` (`:1254-1294`) and
  `c5_backward_walk` (`:1295-~1879`). **No other region of that file and no other file.** In
  particular: do **not** touch the forward-walk region (7.6's territory, now landed — consume its
  field's *shape* as the template but do not edit it), `EliminationResult` or
  `eliminatePotentialCounterexample` (7.8), or `PointInsertion.lean`.
- **The substitution table against 7.6** — each row is a place a mechanical transcription goes
  wrong:

  | In 7.6 (forward) | Here (backward) |
  |---|---|
  | `Formula.untl η ξ ∈ χ.f pt` | `Formula.snce η ξ ∈ χ.f pt` |
  | witness `y` with `pt < y` | witness `y` with `y < pt` |
  | guard interval `pt ≤ a → b ≤ y` | guard interval `y ≤ a → b ≤ pt` |
  | `exists_rat_gt_finset` (beyond the max) | `exists_rat_lt_finset` (`:106`, below the min) |
  | `lemma_2_4_with_guard` (`PointInsertion.lean:3455`) | `lemma_2_4_since_with_guard` (`:3615`) |
  | `lemma_2_7` / `lemma_2_8` (`:2267` / `:2570`) | `lemma_2_7_since` / `lemma_2_8_since` (`:2963` / `:3247`) |
  | `new_point_after` (`:667`) | `new_point_before` (`:1275`) |
  | accumulation **from below** at the guard's right end | accumulation **from above** at the guard's left end — **and the invariant is still the below-accumulation one**, because `limitSetBelow` is the only limit this route uses |
  | every `<` between rationals | reversed |

  **The last two rows are the trap.** `LimitGuardEventual`'s conclusion is
  `ψ ∈ limitSetBelow fam.mcs r` in **both** disjuncts — the `snce` case does not switch to
  `limitSetAbove`, and this plan's standing decision is that *only the below limit is
  load-bearing*. An implementer who introduces an above-accumulation invariant here has changed the
  target. `limitSetAbove` and its duals remain standing sorry-free assets that no phase consumes.
- **Literature grounding (H3) — ADAPTED-FROM only**, identically to 7.6: Burgess's placement is
  **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373**, and the constraint added on top is
  original work with no source. Every docstring states the no-source fact.
- **Tasks:**
  - [ ] Add the preservation field to `C5BackwardWalkResult` (`:1254`), stated so that it targets
        the **same** below-accumulation invariant as 7.6 — not an above-accumulation mirror.
  - [ ] Discharge it in the base case (witness below the minimum, `exists_rat_lt_finset` /
        `lemma_2_4_since_with_guard`).
  - [ ] Discharge it in the condition-(i) recursion case.
  - [ ] Discharge it in the split case (midpoint, Since-side `lemma_2_7_since` / `lemma_2_8_since`),
        taking the **same route (a) or (b) that 7.6 took** unless the backward direction genuinely
        forces a different one — and if it does, say so explicitly and justify it, because a
        forward/backward asymmetry in the placement discipline is a design smell that 7.8 will have
        to reconcile.
  - [ ] Docstrings per the honesty charter: no-source statement + ADAPTED-FROM with printed pages;
        record the route taken and any forward/backward asymmetry. **No task-number citations.**
  - [ ] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.CounterexampleElimination`, then
        full `lake build`.
- **Estimated output:** ~250-400 lines. **One agent run (H8).**
- **Done when:** `C5BackwardWalkResult` carries the preservation field targeting the
  below-accumulation invariant; all three cases discharge it sorry-free; full `lake build` green;
  sorry baseline unchanged; the six frozen statements unchanged; 7.6's landed field and proofs are
  byte-identical (`git diff` shows only the backward region changed).
- **Outcome B trigger for this phase:** as in 7.6, with the same three required deliverables. A
  backward-only obstruction is *more* informative than a symmetric one and must be reported as
  such.
- **Prohibited in this phase:** no `sorry`; no vacuous field; no edit outside the backward-walk
  region; **no `limitSetAbove`-based invariant**; no change to the six frozen statements; no
  closure enlargement; no edit to `PointInsertion.lean`.
- **Timing:** 5 hours.
- **Depends on:** 7.5 (and, for the field's shape and the split-case route, 7.6)

### Phase 7.8: `EliminationResult` and the ω-chain stage induction (R3d-4) [NOT STARTED]

**Composition, not new mathematics — but it is where the two walks, the C4 branches and the
no-new-point branches have to agree.** This phase lifts the walk-level preservation to
`eliminatePotentialCounterexample` and then to every stage of the ω-chain.

- **Goal:** Land the invariant as a field of `EliminationResult`, discharged in every branch of
  `eliminatePotentialCounterexample`, and as a component of the `omegaChain` subtype property,
  established at stage 0 and preserved at every successor.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
  **restricted to** `EliminationResult` (`:580-645`) and `eliminatePotentialCounterexample`
  (`:1880`-end); and `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
  **restricted to** `omegaChain` (`:262`), `omegaChainVal` (`:275`) and the projection lemmas
  `omega_chain_c0` (`:283`) / `omega_chain_c2'` (`:290`) plus the new projection this phase adds.
  **No other region and no other file.** In particular: do **not** re-open the two walk regions
  (7.6/7.7 own them and their fields are consumed as landed), and do **not** touch
  `limit_F_resolution` (`:722`), `limit_satisfies_c4` (`:776`), `limit_satisfies_c5_strong`
  (`:1482`), `LimitDom`/`LimitF`/`LimitG` (7.9's territory) or `ChronicleToCountermodelBasic.lean`.
- **The structural facts this phase must work from** (verified; re-verify before editing):
  - `eliminatePotentialCounterexample` (`:1880`) returns an `EliminationResult` (`:580`) with
    fields `val`, `dom_sub`, `c0`, `f_agrees`, `g_agrees`, `c2'`, `c5_forward_witness` (`:591`),
    `c5_backward_witness` (`:597`), `c4_forward_witness` (`:603`), `c4_backward_witness` (`:608`),
    `g_sub_f_insert` (`:617`), `g_sub_g_new` (`:619`), `dom_new_unique` (`:621`),
    `c5_forward_resolved_no_new` (`:626`), `c5_backward_resolved_no_new` (`:633`).
  - **C4 elimination is inline** — there are no `c4_forward`/`c4_backward` lemmas to consume. The
    C4 branches insert points via `eliminate_g_prop_counterexample` (`:452`) /
    `eliminate_h_prop_counterexample` (`:492`) and their placement must be checked directly.
  - **The `resolved_no_new` branches insert nothing**, so preservation there is immediate — do them
    first and land them, so the phase has green output early.
  - The ω-chain subtype is `{ χ : Chronicle // χ.c0 fc ∧ χ.c2' fc }` (`:262`). Widening it to a
    three-way conjunction changes the shape of `.property` projections at `omega_chain_c0` (`:283`)
    and `omega_chain_c2'` (`:290`). That edit is mechanical but it is **not optional** and it is
    the single most likely source of a broken build in this phase.
  - **`ChronicleInvariant` (`ChronicleTypes.lean:745`) is NOT to be extended.** It is consumed only
    by `singleton_invariant` and is not what the chain carries. Amendment 2's drafted text names
    it; that naming is a factual error corrected at this revision.
- **Tasks:**
  - [ ] Add the invariant-preservation field to `EliminationResult` (`:580`).
  - [ ] Discharge it in the **no-new-point** branches (`c5_forward_resolved_no_new`,
        `c5_backward_resolved_no_new`, and any branch returning the input chronicle unchanged) —
        immediate, and the cheapest green in the phase.
  - [ ] Discharge it in the **C5 forward and backward** branches by consuming 7.6's and 7.7's
        result-structure fields. **Consume, do not re-derive**; a dispatch re-proving a walk case
        here has misread the territory.
  - [ ] Discharge it in the **C4 forward and backward inline branches**. These have received no
        prior analysis on this route and are the phase's genuine unknown: check where
        `eliminate_g_prop_counterexample` / `eliminate_h_prop_counterexample` place their points and
        whether that placement can accumulate. If it can, the same route (a)/(b) choice as 7.6
        applies, under Amendment 2, with the same documentation obligation.
  - [ ] **Widen the `omegaChain` subtype** (`ChronicleConstruction.lean:262`) to carry the
        invariant alongside `c0` and `c2'`; repair the `.property` projections in
        `omega_chain_c0` / `omega_chain_c2'`; add the new projection lemma (suggested
        `omega_chain_no_guard_accumulation`, name at the implementer's discretion — report it).
  - [ ] **Establish the base case at stage 0**: `singletonChronicle` (`:70`) has
        `dom = {(0:Rat)}`, so the invariant holds vacuously. Land it as a named lemma beside
        `singleton_invariant` (`:103`) — do **not** modify `singleton_invariant` itself.
  - [ ] Docstrings per the honesty charter on every new declaration. **No task-number citations.**
  - [ ] `lake build` on both modules, then full `lake build`.
- **Estimated output:** ~300-450 lines across the two files. **One agent run (H8).** If it
  overruns, the sanctioned split is (i) `EliminationResult` field + all branches, then (ii) the
  ω-chain widening + stage 0 — **report the split; do not silently re-dispatch**.
- **Done when:** `EliminationResult` carries the field and every branch discharges it sorry-free;
  the `omegaChain` subtype carries the invariant with its projection lemma; stage 0 is established;
  full `lake build` is green; sorry baseline unchanged; the six frozen statements unchanged;
  `ChronicleInvariant` is **untouched**.
- **Outcome B trigger for this phase:** a C4 branch that provably cannot preserve the invariant, or
  an enumeration-order argument showing the stage induction cannot close. Same three required
  deliverables, same `[BLOCKED]` / `[PARTIAL]` protocol. A C4-only obstruction is a *new* finding —
  report 05 analysed only the C5 walks — and must be flagged as such.
- **Prohibited in this phase:** no `sorry`; no re-opening of the walk regions; no extension of
  `ChronicleInvariant`; no change to the six frozen statements; no closure enlargement; no edit to
  the limit-level declarations (7.9 owns them).
- **Timing:** 6 hours.
- **Depends on:** 7.6, 7.7

### Phase 7.9: Limit transport, the cantor-side discharge, and `_fuc` (R3d-5) [NOT STARTED]

**The last obligation on the route.** This phase carries the stage invariant to `LimitDom`,
transports it through `cantorIsoDense`, discharges `BFMCS.LimitGuardEventual` for
`cantorBfmcsDense`, and lands `cantor_bfmcs_dense_real_restricted_fuc`. When it is green, Phase 8's
precondition is met and nothing else stands between the tree and the unconditional terminus.

- **Goal:** Land **`Chronicle.cantor_bfmcs_dense_limit_guard_eventual`** and
  **`cantor_bfmcs_dense_real_restricted_fuc`**, both sorry-free.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean`
  (extends — 7.5's module, appended to) and
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` **restricted to new
  appended limit-level declarations**, plus `FormalSystem/Metalogic/BXCanonical.lean` (import lines
  only). **No other file.** In particular: do **not** touch `ChronicleToCountermodelBasic.lean`
  (`cantorIsoDense :236` and `cantorBfmcsDense :552` are consumed as landed and **may not be
  edited**), the walk or elimination regions of `CounterexampleElimination.lean` (7.6-7.8's, now
  landed), `ChronicleRealExtension.lean` or `Bundle/RealExtensionBundle.lean` (Phase 7.4's, landed).
- **The three steps, and why each is bounded:**
  1. **Stage → limit.** `LimitDom = { x | ∃ n, x ∈ (omegaChainVal … n).dom }` (`:579`) and `LimitF`
     (`:589`) are the union/colimit of the stages. Carry 7.8's stage invariant to the limit. The
     content is that accumulation at an unselected real is a property of the *union*, and a bounded
     ascending sequence in `LimitDom` has all its terms in finitely many... **no** — it need not:
     each stage's `dom` is a `Finset` but the union is infinite, so a sequence accumulating in the
     limit need not lie in any single stage. **This is the step that actually needs the ω-chain
     scheduling argument**, and it is the reason report 05 §6 said R3d "is not one agent run": a
     per-stage lemma does not suffice. Budget it as the bulk of this phase.
  2. **Limit → ℚ through `cantorIsoDense`.** The family the completeness proof sees is
     `CantorFDense q := LimitF fc A h_mcs ((cantorIsoDense fc A h_mcs h_dense).symm q).val`
     (`ChronicleToCountermodelBasic.lean:245`), a pullback along an **order isomorphism**
     `LimitDomSubtype ≃o Rat` (`:236`). Report 05 §4.2 proves the accumulation property is purely
     order-theoretic — for `S ⊆ ℚ`, "`S` accumulates at some irrational from below" ⟺ "there is
     `S₀ ⊆ S` with no maximum, bounded above, whose upper-bound set has no minimum" — hence
     **invariant under any order isomorphism**, hence it transfers exactly. 7.5 was chartered to
     state the invariant in manifestly order-theoretic form precisely so this step is a transport
     and not a re-proof. **Do not edit `cantorIsoDense`** — it is not a lever and the constraint
     against editing it is unamended.
  3. **Discharge and compose.** `cantor_bfmcs_dense_limit_guard_eventual :
     (cantorBfmcsDense fc A h_mcs h_box_dense).LimitGuardEventual`, mirroring the shape of the
     landed `cantor_bfmcs_dense_limit_guard_below` (`ChronicleLimitGuardWitness.lean:198`) and
     `cantor_bfmcs_dense_limit_guard_above` (`ChronicleLimitGuardAbove.lean:203`). Then
     `cantor_bfmcs_dense_real_restricted_fuc`, by instantiating the **landed** signature of
     `BFMCS.toRealBundle_restricted_forward_until_since` (`ChronicleRealExtension.lean:1126`):
     ```lean
     theorem BFMCS.toRealBundle_restricted_forward_until_since {fc : FrameClass}
         (hfc : FrameClass.Dedekind ≤ fc) (B : BFMCS (fc := fc) Rat) (root : Formula)
         (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
         (hSf : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ fam.mcs t → …)
         (hSb : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula), … → Formula.snce α β ∈ fam.mcs t)
         (h_lga : ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ χ : Formula,
           χ ∈ limitSetBelow fam.mcs r →
           ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → χ ∈ fam.mcs q)
         (h_lge : B.LimitGuardEventual) :
         (B.toRealBundle).RestrictedForwardUntilSinceCoherent root
     ```
     **This is the LANDED binder list and it is ground truth — v5's draft
     `(B) (root) (h_rfuc) (h_rbuc) (h_lgb) (h_lge)` is NOT provable and must not be used.**
     Discharge each binder from an existing asset: `hfc` is threaded; `h_rfuc` from
     `cantor_bfmcs_dense_restricted_fuc` (`ChronicleToCountermodelBasic.lean:755`) at a self-root;
     `hSf`/`hSb` by the same self-root instantiation of `_fuc`/`_buc` that
     `cantor_bfmcs_dense_limit_guard_below` and `_above` already use; `h_lga` by the **landed**
     `cantor_bfmcs_dense_limit_guard_above` (`ChronicleLimitGuardAbove.lean:203`), whose conclusion
     is stated unfolded — **there is no `BFMCS.LimitGuardAbove` predicate and none is to be
     created**; and `h_lge` by this phase's own discharge.
- **Literature grounding (H3) — ADAPTED-FROM only.** Steps 1 and 2 are original: no source performs
  a Dedekind-closedness transport on a rational chronicle. **ADAPTED-FROM: Burgess 1984 §2.7,
  printed pp.109-110** for the completion-at-a-gap *shape* — his `w(Y,Z)` and *"some MCS extending
  `C(Y,Z)`"* — with the honest note that his completion runs in `F`/`G`, has **no guard**, and takes
  its one gap conversion from axiom **A7a** rather than from any property of the chronicle, so the
  obligation discharged here does not arise in his setting at all. Reynolds' `γ⁺` (**printed
  p.175**) may be cited for the statement being discharged, **never** for the discharge.
- **Tasks:**
  - [ ] Carry the stage invariant to `LimitDom`/`LimitF` (step 1), as a named limit-level lemma
        appended to `ChronicleConstruction.lean`. **Do not modify `limit_F_resolution` (`:722`),
        `limit_satisfies_c4` (`:776`) or `limit_satisfies_c5_strong` (`:1482`)** — their statements
        are frozen by Amendment 2's proviso. Append; do not restructure.
  - [ ] Transport through `cantorIsoDense` (step 2), consuming its `≃o` structure and
        `.symm.strictMono` (`ChronicleToCountermodelBasic.lean:293` exhibits the pattern). **No edit
        to that file.**
  - [ ] Prove `cantor_bfmcs_dense_limit_guard_eventual` by composing the transport with 7.5's
        payoff implication.
  - [ ] Prove `cantor_bfmcs_dense_real_restricted_fuc` from the landed
        `BFMCS.toRealBundle_restricted_forward_until_since` at the signature quoted above.
  - [ ] Docstrings per the honesty charter on every new declaration: the no-source statement and
        ADAPTED-FROM citations with printed pages. Record, in the module docstring, that this
        closes the last obligation and that the construction it rests on is original. **No
        task-number citations.**
  - [ ] `#print axioms cantor_bfmcs_dense_limit_guard_eventual` and
        `#print axioms cantor_bfmcs_dense_real_restricted_fuc`; record the results.
  - [ ] Full `lake build`.
- **Estimated output:** ~250-400 lines. **One agent run (H8).** Step 1 is the bulk; if the phase
  overruns, the sanctioned split is step 1 alone, then steps 2+3 — **report the split**.
- **Done when:** both `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` and
  `cantor_bfmcs_dense_real_restricted_fuc` are sorry-free; full `lake build` is green; live sorries
  outside `Boneyard/` unchanged at exactly `WeakCanonical/Transfer.lean:1242`; `#print axioms` on
  both is `[propext, Classical.choice, Quot.sound]`; the six frozen statements are unchanged; and
  `ChronicleToCountermodelBasic.lean` is byte-identical.
- **Outcome B trigger for this phase:** step 1 is where a stage-local invariant can fail to give a
  limit-level one — an ascending sequence in `LimitDom` drawn from infinitely many stages. If that
  cannot be closed, the finding is that the invariant needs to be **uniform across stages** in a way
  the stage induction did not establish, which is a route-level finding about the invariant's shape
  and points back at 7.5. Report it with the exact goal state, mark `[BLOCKED]`, mark the task
  `[PARTIAL]`, and do **not** dispatch Phase 8. Do not repair it by weakening
  `BFMCS.LimitGuardEventual`.
- **Prohibited in this phase:** no `sorry`; no edit to `ChronicleToCountermodelBasic.lean`; no edit
  to `cantorIsoDense`; no change to the six frozen statements; no closure enlargement; no
  restatement of `BFMCS.LimitGuardEventual`; no `BFMCS.LimitGuardAbove` predicate; no predicate
  threaded onto `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind` or `completeness_dedekind` — Phase 8 remains a separate
  phase and the no-conditional-terminus rule is unamended.
- **Timing:** 3 hours.
- **Depends on:** 7.8

### Phase 8: The Dedekind countermodel on ℝ and the unconditional terminus [NOT STARTED]

> **PRECONDITION (v6, binding, updated but NOT weakened): this phase is NOT dispatchable until
> `BFMCS.LimitGuardEventual` is discharged for `cantorBfmcsDense`. The exact expected declaration
> is `Chronicle.cantor_bfmcs_dense_limit_guard_eventual`, landed by Phase 7.9**, together with
> `cantor_bfmcs_dense_real_restricted_fuc` (also 7.9). Landing Phases 7.3-7.8 does **not** unblock
> it — only the final R3d sub-phase does. In marker terms the gate is structural rather than
> notational: the orchestrator's heading scan takes the first `[NOT STARTED]` phase in file order,
> so it reaches Phase 8 only after 7.5, 7.6, 7.7, 7.8 and 7.9 are all `[COMPLETED]`. If any R3d
> sub-phase ends `[BLOCKED]` (the family-`Q` Outcome B protocol), the correct task state is
> `[PARTIAL]` and **this phase is not dispatched at all**.
>
> **PRECONDITION (v5, retained): this phase is NOT dispatchable until `BFMCS.LimitGuardEventual` is
> discharged for `cantorBfmcsDense`** — by the R3d block or by an explicitly accepted alternative.
> Landing Phases 7.3 and 7.4 does **not** unblock it: at that point the forward transport is
> conditional on an undischarged bundle-shaped predicate, and threading such a predicate onto
> `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
> `consequence_completeness_dedekind` or `completeness_dedekind` is prohibited outright by the
> standing v3 constraint, which v5 does not amend. **There is no conditional terminus and no
> undischarged predicate on the terminus chain.** The terminus
> `consequence_completeness_dedekind_of_engine` and its pinned signature (commit `bd9ae0ac1`) carry
> forward **unchanged**. Until the discharge exists, the correct task state is `[PARTIAL]`.
>
> **Charter otherwise unchanged from v4.** The eight tasks below, the `hfc` thread, the estimated
> output and the `Done when` clause are as v4 stated them. **Marker corrected**: v4's heading read
> `[IN PROGRESS]` while v4's own Revision Rationale item 7 stated it had been corrected to
> `[NOT STARTED]`; none of its tasks is checked and no dispatch has run against it. This is a
> marker correction with no charter change.
>
> **One task-list addition (v5)**: the three coherence hypotheses of
> `fully_restricted_parametric_completeness_from_neg_membership`
> (`RestrictedParametricTruthLemma.lean:417-422`) are `h_rtc`, `h_buc` **and `h_fuc`**, and
> `h_fuc` needs **both** the `untl` and the `snce` unselected cases. Verify all three instances
> exist and are unconditional before composing — this is the check whose absence produced v4's
> charter gap.

- **Goal:** Discharge the engine hypothesis of Phase 2 and land `consequence_completeness_dedekind`
  unconditionally, with `completeness_dedekind` as its `Γ = []` corollary.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (extends Phase 1),
  `FormalSystem/Metalogic/StrongCompleteness.lean` (extends Phase 2),
  `FormalSystem/Metalogic.lean` (tracking table).
- **v2 ripple: statements unaffected; one added verification task.** `countermodel_dedekind_dense`
  quantifies over an abstract `TaskFrame ℝ` and never mentions the extension's internals, and
  `consequence_completeness_dedekind_of_engine`'s pinned signature is untouched. The one thing
  rational selection changes is the *evaluation point*: the root MCS must still sit at the
  evaluation time, and that now needs an explicit check rather than being assumed.
- **v3 ripple: one new prerequisite and one signature change, both benign.**
  `countermodel_dedekind_dense` acquires `(hfc : FrameClass.Dedekind ≤ fc)` because Phase 6.2's
  discharge is `fc`-conditional, and it must now supply `BFMCS.LimitFutureWitness` explicitly
  when instantiating the temporal-coherence transport. Neither touches
  `consequence_completeness_dedekind_of_engine`, whose pinned signature is stated at `.Dedekind`.
  **(v5 restatement of the dispatch gate)**: Phase 7.2 reported outcome (ii), so the v4 form of
  this gate ("unless Phase 7.2 reported outcome (i)") is superseded by the v5 precondition above —
  **not dispatchable until `BFMCS.LimitGuardEventual` is discharged**. Until then the correct
  action is `[PARTIAL]`, not a conditional terminus.
- **v4 ripple: one prerequisite is now satisfied rather than open, and the `hfc` thread widens by
  one consumer.** `cantor_bfmcs_dense_real_restricted_buc` is delivered by Phase 7.1′ and is
  consumed here **as landed** — this phase does not re-derive it and does not compose the backward
  transport itself. The `hfc : FrameClass.Dedekind ≤ fc` binder this phase already anticipated now
  covers the new `Axiom.prior_S_gap` use as well as `prior_U_gap`; no *additional* hypothesis
  appears anywhere on the terminus chain, and `hfc` is still discharged (not propagated) by
  `decide` at `fc := FrameClass.Dedekind`. The pinned
  `consequence_completeness_dedekind_of_engine` signature is untouched.
- **Tasks:**
  - [ ] **(v3, new)** Discharge `BFMCS.LimitFutureWitness` for the chronicle bundle: pass
        `Chronicle.cantor_bfmcs_dense_limit_future_witness fc hfc A h_mcs h_box_dense root`
        (Phase 6.2) as the `h_lfw` argument wherever
        `BFMCS.toRealBundle_restricted_temporally_coherent` is instantiated — in practice, inside
        Phase 7.1′'s `cantor_bfmcs_dense_real_restricted_tc`, which this phase consumes rather than
        re-derives. Verify that the `root` at which it is instantiated is the same `root` the
        truth lemma is applied at; a mismatch here is silent and is exactly the kind of seam the
        Postmortem Constraints warn about.
  - [ ] **(v3, new)** Add `(hfc : FrameClass.Dedekind ≤ fc)` to `countermodel_dedekind_dense`'s
        binder list (or pin it at `fc := FrameClass.Dedekind`) and thread it through the three
        chronicle coherence instances. At the single call site in `completeness_dedekind_engine`,
        `fc` is `FrameClass.Dedekind` and the hypothesis is `by decide` (`Axioms.lean:491`
        exhibits `FrameClass.Dense ≤ FrameClass.Dedekind` by `decide`, so the reflexive instance
        is at least as cheap). Do **not** add any other hypothesis to this signature.
  - [ ] **(v2, new)** Verify the root placement: `B.evalFamily.toRealShift 0` takes the value
        `B.evalFamily.mcs 0` at `t = 0`, because `0 + 0 = ((0 : Rat) : ℝ)` is selected. Compose
        with `rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:511`) to get
        the root MCS `A` at real time `0`. Land this as a named lemma before the countermodel,
        not as an inline `have`.
  - [ ] Prove `countermodel_dedekind_dense {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
        (A : Set Formula)
        (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) (h_neg_in : φ.neg ∈ A)
        (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega : Set (WorldHistory F))
        (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : ℝ),
        ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133-162`) statement-for-statement, substituting `Rat → ℝ`, the
        `BFMCS.toRealBundle` of `Chronicle.cantorBfmcsDense`, and the three Phase 7 coherence
        instances into `fully_restricted_parametric_completeness_from_neg_membership`.
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive,
        `neg_consistent_of_not_derivable (fc := FrameClass.Dedekind)`, `set_lindenbaum`,
        `dedekind_box_dense_mem` (Phase 1) for the box-dense hypothesis, then
        `countermodel_dedekind_dense` applied at `ℝ` with `real_lub_of_bddAbove` discharging the
        lub binder of `ValidDedekindDense` and `by decide` discharging `hfc` at
        `fc := FrameClass.Dedekind`.
  - [ ] Instantiate Phase 2's `consequence_completeness_dedekind_of_engine` with this engine to
        obtain the unconditional `consequence_completeness_dedekind`. **Do not restate or re-bind
        that signature** — it is pinned by commit `bd9ae0ac1`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `consequence_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] `#print axioms consequence_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record the results.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` (the file at the
        `FormalSystem/` root, not `FormalSystem/Metalogic/Metalogic.lean`, which does not exist)
        with the Dedekind rows, matching the existing `Completeness (dense)` / `(discrete)` row
        format at `:37`,`:39`.
  - [ ] `lake build` (full project).
- **Estimated output:** ~260 lines.
- **Done when:** `consequence_completeness_dedekind` and `completeness_dedekind` are sorry-free; full
  `lake build` is green; `#print axioms` on both shows exactly
  `[propext, Classical.choice, Quot.sound]`; the tracking table is updated.
- **Timing:** 4 hours.
- **Depends on:** 2, 6.2, 6.3, 7.1′, 7.2, 7.3, 7.4, **and Phase 7.9's
  `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` + `cantor_bfmcs_dense_real_restricted_fuc`**
- **(v6) Charter note:** this phase is **unchanged** by the v6 revision apart from the precondition
  restatement above and the naming of the exact expected declaration. Its eight tasks, the `hfc`
  thread, the estimated output and the `Done when` clause stand verbatim. The terminus
  `consequence_completeness_dedekind_of_engine` and its pinned signature (commit `bd9ae0ac1`) carry
  forward **unchanged** — **there is no conditional terminus**, and the R3d authorization does not
  amend the constraint that forbids one. The one v6 consumption note: `_fuc` arrives **as landed by
  7.9**; this phase does not re-derive it, exactly as it does not re-derive `_buc` from 7.1′.

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase (scoped module build per phase; full build at
      Phase 8).
- [ ] `#print axioms consequence_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dense` and `#print axioms completeness_discrete` unchanged —
      regression check that no preserved asset was disturbed.
- [ ] `grep -rn "sorry" FormalSystem/ --include=*.lean | grep -v Boneyard` returns exactly the
      pre-existing `Transfer.lean:1242` entry (plus any strategic sorry explicitly elected under
      the Risks contingency, which must then appear in `sorry_inventory`).
- [ ] `FormalSystem/Metalogic/Soundness.lean` still at zero sorries.
- [ ] **(v2)** No declaration anywhere asserts agreement between `limitSetBelow m (q:ℝ)` and
      `m q`. Agreement is available only through `realLimitMCS_of_rat` / `FMCS.toReal_at_rat`.
- [ ] **(v2)** `Bundle/LimitMCS.lean`'s ten Phase 3 declarations are unchanged except for the
      sanctioned in-place generalization of `limitSetBelow_of_rat` in Phase 5.
- [ ] **(v2)** No `modal_past` axiom was added to `ProofSystem/Axioms.lean`.
- [ ] **(v3)** No declaration anywhere asserts `BFMCS.LimitFutureWitness` (or any statement of its
      shape) at a **selected** real. Grep the predicate's binder list for the unselectedness
      hypothesis: `∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) →`.
- [ ] **(v3)** `#print axioms limitFutureWitness_of_priorU` and
      `#print axioms cantor_bfmcs_dense_limit_future_witness` are exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] **(v3)** `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc`
      (`ChronicleToCountermodelBasic.lean:629,680,755`) and the three underlying resolution
      lemmas (`ChronicleConstruction.lean:722,776,1482`) are byte-identical to their pre-task
      state. `git diff` on those files shows no change.
- [ ] **(v3)** `Bundle/RealExtensionBundle.lean`'s diff from Phase 6.1 consists of exactly the
      `LimitFutureWitness` binder-list line, the one call-site line at `:306`, and docstring
      prose. No proof script in that file is restructured.
- [ ] **(v3)** No `.lean` file introduced by this task names `limitMCS_no_oscillation`.
- [ ] **(v3)** `deferralClosure` and `extendedDeferralClosure` are unchanged; no root was widened
      to make the auxiliary Prior-U formulas available.
- [ ] **(v3)** The only hypothesis added anywhere on the
      `countermodel_dedekind_dense → completeness_dedekind_engine →
      consequence_completeness_dedekind → completeness_dedekind` chain is
      `FrameClass.Dedekind ≤ fc`, and it is discharged (not propagated) at the instantiation
      point.
- [ ] **(v4)** `#print axioms limitGuardBelow_of_priorS`,
      `#print axioms cantor_bfmcs_dense_limit_guard_below`,
      `#print axioms BFMCS.toRealBundle_restricted_backward_until_since` and
      `#print axioms cantor_bfmcs_dense_real_restricted_buc` are exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] **(v4)** `BFMCS.LimitGuardBelow`'s binder list carries the unselectedness hypothesis
      `(¬ ∃ q : Rat, (q : ℝ) = r) →` and carries **no** closure hypothesis and **no** `root`
      argument. Grep the definition.
- [ ] **(v4)** No declaration anywhere states `BFMCS.toRealBundle_restricted_backward_until_since`
      (or any statement of its shape) **without** the `B.LimitGuardBelow` hypothesis. The v3
      signature is refuted and must not appear, sorried or otherwise.
- [ ] **(v4)** No `.lean` file introduced by this task states or proves a **bounded** witness lemma
      (a rational `u` with `g < u < c` and `φ ∈ m u`). It is a corollary of Phase 6.3, is needed by
      no case, and is prohibited as a work item.
- [ ] **(v4)** The seven declarations landed in `ChronicleRealExtension.lean` by the Phase 7.1
      dispatch are unchanged. `git diff` on that file shows appended declarations and the corrected
      docstring paragraph only — no rewritten proof script.
- [ ] **(v4)** `ChronicleRealExtension.lean`'s docstring no longer claims that Refutation 2's family
      fails unrestricted rational **forward** Until coherence.
- [ ] **(v4)** `Bundle/RealExtensionBundle.lean`'s diff from Phase 6.2 consists of exactly the
      appended `BFMCS.LimitGuardBelow` definition and its docstring. `BFMCS.LimitFutureWitness` and
      every proof script in the file are byte-identical.
- [ ] **(v4)** `ChronicleLimitGapWitness.lean` (Phase 6.2) is byte-identical. Phase 6.3 clones its
      shape into a **new** module; it does not edit it.
- [ ] **(v4)** `cantor_bfmcs_dense_restricted_fuc` / `_buc` are consumed at self-roots via their
      `.2` projections only; neither is modified (already covered by the v3 byte-identity check,
      restated here because 6.3 and 7.1′ are new consumers).
- [ ] **(v5, CORRECTS the v4 check above)** The v4 check "No `.lean` file introduced by this task
      states or proves a **bounded** witness lemma" is **retired** by Amendment 1 and replaced by:
      `boundedWitness_of_limitGuardBelow` exists exactly once, in `ChronicleRealExtension.lean`,
      proved from `limitGuardBelow_of_priorS` (Phase 6.3) and **not** from
      `BFMCS.LimitFutureWitness`. Grep its proof for `limitFutureWitness` — zero hits.
- [ ] **(v5)** `#print axioms limitGuardAbove_of_priorU`,
      `#print axioms cantor_bfmcs_dense_limit_guard_above`,
      `#print axioms boundedWitness_of_limitGuardBelow`,
      `#print axioms toRealBundle_forward_until_unselected`,
      `#print axioms toRealBundle_forward_since_unselected` and
      `#print axioms BFMCS.toRealBundle_restricted_forward_until_since` are exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] **(v5, the charter-gap check — this is the check whose absence produced the gap)** Inventory
      the three coherence hypotheses of
      `fully_restricted_parametric_completeness_from_neg_membership`
      (`RestrictedParametricTruthLemma.lean:417-422`): `h_rtc`, `h_buc`, `h_fuc`. For `h_fuc`,
      **both** unselected forward cases must be landed by name —
      `toRealBundle_forward_until_unselected` **and** `toRealBundle_forward_since_unselected`.
      A landed `untl` half with no `snce` half is the v4 defect, reproduced.
- [ ] **(v5)** `BFMCS.LimitGuardEventual`'s binder list carries the unselectedness hypothesis
      `(¬ ∃ q : Rat, (q : ℝ) = r) →`, carries **no** closure hypothesis and **no** `root` argument,
      and covers **both** `untl` and `snce` in its disjunctive antecedent. Grep the definition.
- [ ] **(v5)** No declaration on the chain `countermodel_dedekind_dense →
      completeness_dedekind_engine → consequence_completeness_dedekind → completeness_dedekind`
      mentions `LimitGuardEventual`, `LimitGuardBelow`, `LimitFutureWitness`, or any other
      bundle-shaped predicate. Grep the chain. The only permitted added hypothesis remains
      `FrameClass.Dedekind ≤ fc`.
- [ ] **(v5, SUPERSEDED by v6 — recorded so the reversal is auditable)** v5 required
      `ChronicleConstruction.lean`, `CounterexampleElimination.lean` and `ChronicleTypes.lean` to be
      byte-identical to their pre-task state, because Amendments 2-4 were drafted and NOT applied.
      **Amendments 2-4 are APPLIED in v6**, so `ChronicleConstruction.lean` and
      `CounterexampleElimination.lean` are expected to change — within Phases 7.6-7.9's stated
      territories and within Amendment 2's provisos. The check is replaced by the v6 checks below.
      **`ChronicleTypes.lean` is still expected to be byte-identical**: `ChronicleInvariant`
      (`:745`) is **not** the object being extended (it is consumed only by `singleton_invariant`),
      so a diff there means a dispatch followed Amendment 2's drafted wording past its corrected
      premise. (`git diff --stat FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
      returns empty.)
- [ ] **(v6, Amendment 2 proviso — the single most important R3d check)** The **statements** of
      `cantor_bfmcs_dense_restricted_tc` (`ChronicleToCountermodelBasic.lean:629`), `_buc` (`:680`),
      `_fuc` (`:755`), `limit_F_resolution` (`ChronicleConstruction.lean:722`),
      `limit_satisfies_c4` (`:776`) and `limit_satisfies_c5_strong` (`:1482`) are **unchanged**.
      Diff each signature line-for-line against its pre-R3d form. A changed statement voids the
      amendment's proviso and is a constraint violation, not a deviation.
- [ ] **(v6)** `ChronicleToCountermodelBasic.lean` is byte-identical. `cantorIsoDense` (`:236`) and
      `cantorBfmcsDense` (`:552`) are consumed as landed; the no-`cantorIsoDense`-edit constraint is
      unamended and report 05 §4.2 proves it is not a lever.
- [ ] **(v6)** Every currently-sorry-free consumer remains sorry-free — Amendment 2's second
      proviso. Full `lake build` green **at the end of every R3d sub-phase**, not merely at the end
      of the block, and the live sorry count outside `Boneyard/` unchanged at exactly
      `WeakCanonical/Transfer.lean:1242` throughout. No structure field anywhere is discharged by
      `sorry`, including as a placeholder for a later sub-phase.
- [ ] **(v6, the honesty check — binding user directive)** Every declaration introduced by Phases
      7.5-7.9 carries a docstring that (a) **states this construction has no source in the corpus
      and is original work**, and (b) cites neighbouring disciplines **only** as `ADAPTED-FROM` with
      printed pages (Burgess 1982 I §2.10 pp.372-373; Burgess 1984 §2.7 pp.109-110). Grep the new
      declarations' docstrings for `ADAPTED-FROM` and for the no-source statement. A citation of
      Burgess or Reynolds **without** the qualifier, or a docstring implying the discharge follows
      Reynolds, is a defect. Reynolds printed p.175 may appear only as the source of the
      **statement** `BFMCS.LimitGuardEventual`, never of its discharge.
- [ ] **(v6)** `BFMCS.LimitGuardEventual`'s definition (`Bundle/RealExtensionBundle.lean:369`) is
      **byte-identical**. Phases 7.5-7.9 discharge it; they do not restate, weaken, re-shape, or
      add a closure hypothesis or `root` argument to it. `Bundle/RealExtensionBundle.lean` as a
      whole is untouched by the R3d block.
- [ ] **(v6)** No `BFMCS.LimitGuardAbove` predicate exists anywhere.
      `cantor_bfmcs_dense_limit_guard_above` (`ChronicleLimitGuardAbove.lean:203`) states its
      conclusion unfolded and enters compositions as the written-out binder `h_lga`; creating a
      predicate for it is out of every sub-phase's territory.
- [ ] **(v6)** `BFMCS.toRealBundle_restricted_forward_until_since` is consumed at its **landed**
      signature `(hfc) (B) (root) (h_rfuc) (hSf) (hSb) (h_lga) (h_lge)`
      (`ChronicleRealExtension.lean:1126`). No declaration anywhere uses v5's drafted binder list
      `(B) (root) (h_rfuc) (h_rbuc) (h_lgb) (h_lge)`, which is **not provable as written**.
- [ ] **(v6)** The declarations landed by Phases 7.3 and 7.4 are unchanged.
      `ChronicleLimitGuardAbove.lean` and `ChronicleRealExtension.lean` are byte-identical after the
      R3d block; `git diff` on both shows no change. The R3d block consumes them and rewrites none.
- [ ] **(v6)** No R3d sub-phase introduces an invariant stated over `limitSetAbove`. Only the
      **below** limit is load-bearing on this route, and `LimitGuardEventual`'s conclusion is
      `ψ ∈ limitSetBelow fam.mcs r` in **both** disjuncts, including the `snce` one.
- [ ] **(v6)** The `Ultrafilter.of` selection and every descent asset through
      `limitMCSBelow_cofinal_below` are unchanged. R3d modifies the **construction**, never the
      **selection**; report 05 §8.3 checked this and found the no-witness-aware-selection rule needs
      no amendment.
- [ ] **(v6)** `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` and
      `cantor_bfmcs_dense_real_restricted_fuc` exist and are sorry-free **before** any Phase 8
      dispatch, and `#print axioms` on both is `[propext, Classical.choice, Quot.sound]`. Before
      7.9 lands, `cantor_bfmcs_dense_real_restricted_fuc` must **not** exist — a declaration of that
      name appearing earlier means an undischarged predicate has been smuggled somewhere.
- [ ] **(v6, the family-`Q` non-vacuity check)** Phase 7.5's invariant is demonstrably violated by
      family `Q`'s shape, landed as Lean rather than asserted in prose. An invariant that `Q`
      satisfies is useless and must be rejected in 7.5, not discovered in 7.8.
- [ ] **(v5)** `ChronicleLimitGuardWitness.lean` (Phase 6.3) and `ChronicleLimitGapWitness.lean`
      (Phase 6.2) are byte-identical. Phase 7.3 mirrors 6.3's shape into a **new** module; it does
      not edit it.
- [ ] **(v5)** `Bundle/RealExtensionBundle.lean`'s diff from Phase 6.3 consists of exactly the
      appended `BFMCS.LimitGuardEventual` definition and its docstring. `LimitFutureWitness`,
      `LimitGuardBelow` and every proof script in the file are byte-identical.
- [ ] **(v5)** The four declarations landed in `ChronicleRealExtension.lean` by the Phase 7.2
      dispatch, and the six landed by Phase 7.1′, are unchanged. `git diff` on that file shows
      appended declarations and docstring prose only — no rewritten proof script.
- [ ] **(v5, SUPERSEDED by v6)** v5 required that `cantor_bfmcs_dense_real_restricted_fuc` **not**
      exist, because its discharge was user-gated. The gate is resolved and the declaration is
      **Phase 7.9's deliverable**. The v6 form of the check is above: it must not exist before 7.9,
      and it must exist and be sorry-free before any Phase 8 dispatch.
- [ ] No `.lean` file added or edited by this task contains a task-number citation
      (`.claude/hooks/validate-no-task-references.sh` advisory).
- [ ] No vacuous definitions (`:= True`, `:= trivial`, `:= Unit`) introduced.

## Artifacts & Outputs

- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/06_strong-completeness-dedekind-v6.md` (this file)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/05_strong-completeness-dedekind-v5.md` (superseded predecessor, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/summaries/05_phase-7-3-guard-gap-above-summary.md` and `summaries/05_phase-7-4-forward-transport-summary.md` (the landed 7.3/7.4 outcomes; the landed signatures they record are ground truth for v6)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/04_strong-completeness-dedekind-v4.md` (superseded predecessor, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/reports/05_forward-guard-r3-research.md` (the v5 revision trigger)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/03_strong-completeness-dedekind-v3.md` (superseded predecessor of v4, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/02_strong-completeness-dedekind-v2.md` (superseded predecessor of v3, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/01_strong-completeness-dedekind.md` (superseded predecessor of v2, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/reports/04_backward-transport-blocker.md` (the v4 revision trigger)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/reports/03_limit-future-witness-blocker.md` (the v3 revision trigger)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/handoffs/phase-7.1-handoff-20260727165057.md` (the Phase 7.1 refutation, superseded in its residual diagnosis by report 04)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/summaries/` (per-phase summaries, one per dispatch)
- `FormalSystem/Metalogic/StrongCompleteness.lean` (Phase 2, landed — terminus)
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (Phase 1, landed; Phase 8 extends — countermodel + engine)
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (Phase 3, landed; Phase 4 extends — limit set, consistency, maximality)
- `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new — the six forward_G / backward_H case lemmas)
- `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new — `realLimitMCS`, `FMCS.toRealShift`, `FMCS.toReal`)
- `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (Phase 6.1, landed — box time-stability, `BFMCS.toRealBundle`, restricted temporal coherence; Phase 6.2 changes exactly two lines plus a docstring)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean` (Phase 6.2, landed — `limitFutureWitness_of_priorU`, `cantor_bfmcs_dense_limit_future_witness`; byte-identical from v4 onward)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean` (new, Phase 6.3 — `limitGuardBelow_of_priorS`, `cantor_bfmcs_dense_limit_guard_below`)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (Phase 7.1 dispatch, landed — 7 declarations; Phase 7.1′ appended six more including `cantor_bfmcs_dense_real_restricted_buc`; Phase 7.2 appended four including forward case A and the dichotomy; **Phase 7.4 appends the bounded witness, both unselected forward cases and the composition**)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean` (Phase 7.3, landed — `limitGuardAbove_of_priorU` `:108`, `cantor_bfmcs_dense_limit_guard_above` `:203`; byte-identical from v6 onward)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean` (**new, Phase 7.5** — the guard-accumulation invariant, the payoff implication, the family-`Q` exclusion; **Phase 7.9 extends it** with the limit transport and `cantor_bfmcs_dense_limit_guard_eventual`)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (**Phases 7.6, 7.7, 7.8** — preservation fields on `C5ForwardWalkResult` `:646`, `C5BackwardWalkResult` `:1254` and `EliminationResult` `:580`, discharged in the two C5 walks and in every branch of `eliminatePotentialCounterexample` `:1880`. **Edited under Amendment 2 only**)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (**Phases 7.8, 7.9** — the widened `omegaChain` subtype `:262` with its projection lemma and the stage-0 base case, then the limit transport appended. **The statements of `limit_F_resolution` `:722`, `limit_satisfies_c4` `:776` and `limit_satisfies_c5_strong` `:1482` are frozen and unchanged**)
- Aggregator import updates: `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Bundle.lean`,
  `FormalSystem/Metalogic/BXCanonical.lean`, `FormalSystem/Metalogic/BXCanonical/Chronicle.lean`

## Rollback/Contingency

- Every file created by this plan is **additive**. Rollback of any phase is deletion of its new
  file plus removal of its one-line aggregator import. No existing declaration is modified except
  the `FormalSystem/Metalogic.lean` tracking table (Phase 8, prose only), the sanctioned
  in-place generalization of `limitSetBelow_of_rat` (Phase 5), the two-line
  `BFMCS.LimitFutureWitness` repair (Phase 6.2), and the `hfc` binder added to
  `countermodel_dedekind_dense` (Phase 8).
- **(v3) Rolling back Phase 6.2** means reverting those two lines in
  `Bundle/RealExtensionBundle.lean` and deleting `ChronicleLimitGapWitness.lean`. Phase 6.1's
  module returns to its conditional-but-sorry-free state, which builds; nothing else regresses.
- **(v4) Rolling back Phase 6.3** means deleting `ChronicleLimitGuardWitness.lean`, removing its
  one aggregator import line, and deleting the appended `BFMCS.LimitGuardBelow` definition from
  `Bundle/RealExtensionBundle.lean`. Nothing else in that file is touched by 6.3, so the rollback
  is exact and Phase 6.2's state is restored verbatim.
- **(v4) Rolling back Phase 7.1′** means deleting the declarations it appended to
  `ChronicleRealExtension.lean` and reverting the corrected docstring paragraph. The module
  returns to its Phase 7.1-dispatch state — seven declarations, sorry-free, building — which is a
  standing asset under every outcome. **The Phase 7.1 refutation is not a rollback event and never
  was**: the two families are findings, the seven declarations are assets, and the only thing v3's
  BLOCKER cost was one revision.
- **(v3) Phase 7.2's refutation outcome is not a rollback event.** It is a planned outcome with a
  fixed fallback ladder (R2/R3/R4 in Phase 7.2). Do not delete 7.1′'s module, do not revert 6.2, and
  do not dispatch Phase 8 against a conditional engine. **(v5: the escalation ran; the R3 split it
  produced is Phases 7.3/7.4/7.5. Phase 7.2 is `[COMPLETED]` and its four declarations are
  preserved assets.)**
- **(v5) Rolling back Phase 7.3** means deleting `ChronicleLimitGuardAbove.lean` and removing its
  one aggregator import line from `Metalogic/BXCanonical.lean`. Nothing else is touched by 7.3, so
  the rollback is exact and Phase 7.2's state is restored verbatim.
- **(v5) Rolling back Phase 7.4** means deleting the declarations it appended to
  `ChronicleRealExtension.lean` and deleting the appended `BFMCS.LimitGuardEventual` definition
  from `Bundle/RealExtensionBundle.lean`. The module returns to its Phase 7.2 state — thirteen
  declarations, sorry-free, building — which is a standing asset under every outcome.
- **(v5, SUPERSEDED — retained so the reversal is auditable) Declining R3d is NOT a rollback
  event.** v5's terminus if the user declined was `[PARTIAL]` at 7.4. **The user did not decline**;
  R3d is authorized, so this branch is not taken. Its substance survives as the Outcome B floor
  below.
- **(v6) The R3d block is a rollback unit, and rolling it back is cheap by design.** Every sub-phase
  is additive or field-additive, and each ends green:
  - **Rolling back Phase 7.5** is deleting `ChronicleGuardAccumulation.lean` and removing its one
    aggregator import line. Nothing else is touched; the tree returns to its post-7.4 state.
  - **Rolling back Phase 7.6 / 7.7** is removing the preservation field from `C5ForwardWalkResult`
    (`:646`) / `C5BackwardWalkResult` (`:1254`) and the case discharges inside the corresponding
    walk, plus reverting any placement change made under route (b). Consumers never used the field,
    so the revert is local and the module returns to a building state.
  - **Rolling back Phase 7.8** is removing the `EliminationResult` field (`:580`) and its branch
    discharges, and narrowing the `omegaChain` subtype (`ChronicleConstruction.lean:262`) back to
    `{ χ // χ.c0 fc ∧ χ.c2' fc }` with the two `.property` projections restored.
  - **Rolling back Phase 7.9** is deleting the appended limit-level declarations and the two final
    theorems. Phase 8 becomes non-dispatchable again, which is the correct state.
- **(v6) Outcome B — the construction is discovered to force the family-`Q` pattern — is NOT a
  rollback event, and it is a legitimate terminus.** Mark the blocking sub-phase `[BLOCKED]` with
  the three required deliverables (exact branch and goal state; the explicit insertion sequence and
  its limit point; whether the obstruction is intrinsic to fresh-point placement or an artefact of
  the enumeration order), mark the task `[PARTIAL]`, keep every sub-phase that landed green, and do
  **not** dispatch Phase 8. That `[PARTIAL]` is strictly better than v5's: it converts "we do not
  know whether the construction has the invariant" into "it provably does not, for this stated
  reason", which is a route-level finding and the correct input to any future escalation.
  **Do not improvise a substitute predicate**: report 05 §3 proves `LimitGuardEventual`
  **necessary**, so there is no weaker sufficient condition to fall back to. **Do not** repair an
  Outcome B by weakening `LimitGuardEventual`, by widening a field's statement to something
  provable-but-useless, by a `sorry`, or by a conditional terminus — all four are prohibited.
- **(v6) A blocked R3d sub-phase does not invalidate the earlier ones.** 7.5's invariant and payoff
  implication remain a standing sorry-free asset even if 7.6 blocks; the walk preservation fields
  remain assets even if 7.8 blocks. The R3d block is ordered so that each sub-phase's output has
  standing value under every downstream outcome, exactly as Phases 7.3/7.4 do under every R3d
  outcome.
- **(v5) If Phase 7.3's proof does not close**, that is a tactical finding about a mirror whose
  *statement* is verified to elaborate — mark 7.3 `[BLOCKED]` with the exact goal state and the
  substitution row that broke, and do **not** widen the hypothesis set, re-attempt an
  `fc`-generic form, or reach for `Axiom.sep`. All three are prohibited.
- Commit at every green milestone per `wrap-up.md` incremental-commit discipline, using
  `task 408 phase {P}: {description}`. Never accumulate multiple phases into one commit.
- Phase 1's probe has passed; the carrier question is closed and does not need re-litigating.
- If Phase 4 blocks, Phases 5-8 still have standing value (the coherence case lemmas, the
  transports, and the terminus statement are all independently sorry-free); mark the task
  `[PARTIAL]` rather than discarding them. Note that Phase 5 is genuinely independent of Phase 4
  and should be dispatched even if Phase 4 blocks.
- If Phase 6.1's `modal_backward` resists even under the real-shift closure, that is a
  **route-level** finding, not a tactical one: it would mean the bundle abstraction cannot be
  transported to a non-selected carrier point at all. Escalate to a new research dispatch rather
  than improvising a fourth extension shape.
