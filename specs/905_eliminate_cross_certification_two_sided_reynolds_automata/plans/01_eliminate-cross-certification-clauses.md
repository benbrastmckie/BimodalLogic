# Implementation Plan: Task #905

- **Task**: 905 - Eliminate the cross-certification clauses of the two-sided Reynolds automata, or show them load-bearing
- **Status**: [IMPLEMENTING]
- **Effort**: 4.0 hours
- **Dependencies**: None blocking. Task 901 is `completed`; its report is the architecture of record and is the sole edit target of this plan.
- **Research Inputs**: `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md`
- **Artifacts**: plans/01_eliminate-cross-certification-clauses.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The research dispatch answered (Q3) in the affirmative and delivered the argument: both clause
(a)s of the two-sided Reynolds automata are eliminable (Theorem 1), the one fact clause (b)
cannot supply by itself is seeded from chronicle clause K1 alone (Lemma 2), and Step 3 of the
truth lemma's emergent-walk case is replaced by a four-link bootstrap (Step 3'). The question
asked of this task is therefore *answered*; what remains is the intake the research report's own
Recommendations 1-5 and 7 name — transcribing the adopted design into
`specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`,
the architecture of record, so that the next reader of the engine reads the eliminated form
rather than the superseded one.

Every edit in this plan is markdown prose inside one `specs/**` artifact. No Lean source is
written or run, no `lake` invocation is made, nothing under `FormalSystem/` or `Tests/` is
touched, no `require` is added, and no completeness claim is made — the dispatch's "report only,
no Lean work" constraint is honoured throughout, and the research report's Recommendations 6 and
8 (do not file any Lean item) are carried as explicit non-goals rather than as omissions.

One planning judgment is recorded rather than escalated. The research report's Decision 8 left
"whether to amend the source report, and in which of the two records" as a routine intake matter.
This plan amends the **source report** (901's), not the architecture report (879's): every one of
the research report's amendment recommendations names the source report by that term, 901's
report is where the two clause (a)s, Step 3, Claim 1+ and the (Q3) ledger physically live, and
879's report is reached only through the house `**Amended by**` note convention, which Phase 5
uses.

### Research Integration

The five substantive results of the research report map onto phases as follows. Theorem 1 (clause
(a) is subsumed by clause (b) of the same automaton, on the strength of the bar-translation's
purity) licenses Phase 2's deletions. Lemma 2 (every chronicle letter certifies a type of each
polarity, from K1 and `stab_t`) and Step 3' (the four-link bootstrap) are Phase 3's content.
Defect (D1) — `PastLits`/`FutLits` are not subformula-closed where Lemma 5.1's transducer needs
them to be — is Phase 1, placed first because the research report calls it the higher-priority
repair and because clause (b), the clause that survives, is the clause that consumes it. Defect
(D2) — Claim 1+'s consequent is the real-word bad-word formula while clause (b) delivers only a
hypothetical-word violation — is Phase 4, together with the re-pointing of Claim 2+ to Lemma
7.3's conditional form and the forward trace to Lemma 7+ that the research report explicitly
hands to whoever applies its Recommendation 4. Finding 5's honest cost accounting — the gain is
one omega-regularity argument and one first-transition obligation per automaton, and the alphabet
does **not** shrink — governs Phase 5's ledger wording, including the strike of the
"shrink the alphabet's enlargement" clause from 901's Recommendation 5.

Finding 4's verdict on the bi-infinite alternative (closed, on the rule-inventory argument that
no `ExtDerivation` constructor names a bi-infinite run) is recorded in Phase 5 at the place the
rule inventory is documented, per Recommendation 7.

### Prior Plan Reference

No prior plan. This is artifact round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context, so no roadmap consultation
was performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Amend 901's report so that `Viol+` and `Viol-` are stated in their clause-(b)-only form, and
  the clause-(a) obligation is gone from the first transition (Recommendation 1).
- Land Lemma 2 as a named chronicle lemma in 901's section 8, beside Lemma 8.1, and replace
  Finding 14.4's Step 3 with Step 3' (Recommendation 2).
- Apply the (D1) repair to Finding 1.1 and Lemma 5.1's formulation (Recommendation 3).
- Apply the (D2) repair to Claim 1+ and Claim 2+, and trace its effect through to Lemma 7+
  (Recommendation 4).
- Close the ledger: (Q3) answered at Finding 16.3, the alphabet expectation struck from
  Recommendation 5, Decision 5 superseded in form and reinforced in substance, Finding 4(i)
  recorded where the rule inventory lives, and a dated `**Amended by**` note at the header
  (Recommendations 5 and 7).

**Non-Goals**:
- No Lean work of any kind: no Lean file written or read for edit, no `lake` invocation, no
  `require`, no Lean task filed (research Recommendations 6 and 8).
- No edit to the architecture report (879's) or to any other repository record; the
  `**Amended by**` note in 901's report is the only cross-record pointer this plan creates.
- No completeness or decidability claim, and no re-opening of (O1)/(O3)/(O4) or of (Q1)/(Q2).
- No change to 905's own research report, which is final as delivered.
- No ingest of a held source on bi-infinite recognizability (research Recommendation 8 marks this
  optional; Finding 4(ii) stays at the *recalled* tier with its corpus sweep reported inline).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Theorem 1's step (4) is the single point of failure of the whole elimination, and Phase 1 edits the very formulation (Lemma 5.1's `Pi_0` determinacy) it depends on | H | M | Phase 1 must leave Lemma 5.1's determinacy claim *weaker or equal* in what it consults: it may not be reformulated so that a pure-future `gamma-bar` consults `Pi_0`. Phase 1's verification carries this as an explicit read-back check, and Phase 2 re-reads Lemma 5.1 as its first task before relying on it. |
| The (D2) repair does not carry through to Lemma 7+ as the research report predicts, so Claim 2+ no longer yields `|- theta_f -> not chi_1+` | H | L | Phase 4 traces the repaired statement forward explicitly rather than asserting the trace. If the trace fails, the phase stops, is marked `[PARTIAL]`, and the failure is reported with the exact step that breaks — the research report already flags that it asserted rather than re-derived this, so a break here is a finding, not a defect to paper over. |
| All five phases edit one file, so line numbers drift as earlier phases land | M | H | Every phase locates its sites by section heading and quoted text, never by line number. The line anchors in this plan are provenance for the planning dispatch's reads, explicitly not edit addresses. |
| Sibling task 906 is dispatched this same cycle with an undeclared `file_scope`, so it may touch any file | M | L | Each phase's first task is to re-read its target region immediately before editing. Commits stage the one target file by explicit path, never a directory or glob. If a foreign commit or foreign uncommitted modification to the target file is observed, stop and report after checking `git log`, per the dispatch's concurrency note. |
| 901 is a `completed` task, so amending its report rewrites a closed record | L | H | The house convention for exactly this case is the dated `**Amended by** <path>, <date>:` note (as 879's report carries three of them); Phase 5 adds one. `specs/**` is the primary exemption zone of both the no-record-versioning and no-task-reference rules, so amendment and task-number language are permitted there. |
| The elimination strictly shrinks both recognized languages, and a consumer not yet in the architecture might want the larger one | L | L | Phase 5 preserves the research report's general classification rule (antecedent-consuming sites are safe for free; hypothesis-consuming sites need a seed, and Lemma 2 supplies one at every chronicle node) in 901's own text, so a future consumer can be classified on sight. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. Every wave here holds exactly one phase:
all five phases edit the same single file, so they are deliberately serialized rather than
presented as parallelizable.

---

### Phase 1: Repair the pure-literal closure, defect (D1) [COMPLETED]

**Goal**: Make `PastLits`/`FutLits` closed under the same-polarity subformulas of the
translations, so that Lemma 5.1's running-past-type transducer has a well-defined initial state.
This is independent of (Q3) and is required by clause (b), which survives the elimination.

**Tasks**:
- [x] Re-read the target file at section 1.1 ("The pure-literal sets") and at Lemma 5.1
      immediately before editing; sibling 906 carries an undeclared `file_scope` this cycle. *(completed)*
- [x] In section 1.1's definition block, replace `PastLits(X)` by its closure under the pure-past
      subformulas of its members, and `FutLits(X)` dually under pure-future subformulas. *(completed)*
- [x] Extend the finiteness remark that follows the block to cover the closure: a finite set's
      subformula closure is finite, so both sets stay finite and the alphabet stays finite. *(completed)*
- [x] Add one sentence recording *why* the closure is needed: `pt` is a subset of `PastLits` and
      so records only which top-level `alpha-bar` hold at the cut, whereas Lemma 5.1's `Lambda-`
      is explicitly subformula-closed; `sepZ`'s past components are S-only abstract formulas with
      L+ leaves resubstituted, and their own pure-past subformulas need not be clause components
      of anything in the closure. *(completed)*
- [x] At Lemma 5.1, leave the `Pi_0`-determinacy claim in force but make it cite the repaired
      `PastLits` explicitly, so the claim is true as stated rather than true only under the
      repair. *(completed)*
- [x] Add the formulation guard the research report's first Risk asks for: the determinacy claim
      must not be read as making the violation condition consult `Pi_0` for a `gamma-bar` that is
      pure in the automaton's own reading direction, since Theorem 1 (landed in Phase 2) depends
      on exactly that blindness. *(completed)*
- [x] Confirm the four downstream quantifiers are unaffected: Lemma 4.1's
      `PT(c_0) = {a and PastLits : a in c_0}`, Lemma 4.2's full product, Lemma 4.3's hue recovery,
      and Finding 4.4's letter content all quantify over whatever `PastLits` is. Grep each and
      confirm no text needs changing. *(completed: grep confirmed all four sites textually unchanged)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` is the covering check, because `suite_selection_select` returns `__FULL_SWEEP__` for that path (run in the planning dispatch) and every touched path lies under `specs/**`.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - section 1.1's `PastLits`/`FutLits` definitions, their finiteness remark, and Lemma 5.1's `Pi_0` sentence (provenance anchors from the planning dispatch, not edit addresses: section 1.1 near line 118, Lemma 5.1 near line 294)

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` exits 0 with `[PASS]` (baseline was `[PASS]` with 0 warnings before any edit, so a regression is attributable).
- Diff read-through confirming every changed hunk is prose or a fenced definition block inside section 1.1 or Lemma 5.1, and that no other section was touched.
- Read-back check: Lemma 5.1 as amended does not state or imply that a pure-future `gamma-bar`'s truth at position 0 consults `Pi_0`.
- `grep -n 'PastLits' <target>` shows the repaired definition and leaves the Lemma 4.1/4.2/4.3 and Finding 4.4 occurrences textually unchanged.

---

### Phase 2: Drop both clause (a)s and the clause-(a) first-transition obligation [COMPLETED]

**Goal**: State `Viol+` and `Viol-` in their clause-(b)-only form, delete the clause-(a)
omega-regularity parenthetical and its mirror, and remove the clause-(a) obligation from
`rho+(s_0+, c-hat)` — recording Theorem 1 as the licence for all of it.

**Tasks**:
- [x] Re-read sections 5.1-5.4 immediately before editing, including Lemma 5.1 as Phase 1 left
      it. *(completed)*
- [x] Reconcile the clause-(a) hit list before editing: `grep -n 'clause (a)' <target>` and
      `grep -n -i 'cross-certif' <target>`, and confirm the hits fall into the four sites this
      phase owns (the `Viol+` definition block, the clause-(a) parenthetical after it, the
      `Viol-` mirror sentence, the 5.4 first-transition parenthetical) plus the five sites owned
      by Phases 4 and 5 (Claim 1+'s proof; and the Executive Summary bullet, Finding 14.4's Step
      3, Finding 16.3, Decision 5, Recommendation 5, Finding 17's mention, and the evidence-tier
      row). Any hit outside those two groups is a new site: record it in the issue log and bring
      it into this phase rather than editing silently. *(completed: `grep -n 'clause (a)'`
      returned 5 distinct lines, not the Scope Hypothesis's estimated 6 -- lines 335 and 826 each
      contain the substring twice, which is the likely source of the planning-dispatch's count.
      All 5 lines mapped cleanly into the two expected ownership groups (335/347/351 this phase,
      415 Phase 4, 826 Phase 3); no unowned site was found. Logged as a minor issue, not a scope
      escalation.)*
- [x] Rewrite section 5.2's `Viol+` definition block to the clause-(b)-only form
      `Viol+ := {v : there is pt with diamond-dot delta_pt in v_0 and v in Viol+_pt}`. *(completed)*
- [x] Keep the `ft_lin(v)` definition and its well-definedness remark: Theorem 1 instantiates
      `gamma` at `delta_{ft_lin}`, so the notion is still consumed, now from inside clause (b).
      *(completed: left textually unchanged)*
- [x] Delete the sentence naming clause (a) the cross-certification clause and the parenthetical
      omega-regularity argument for it, and restate the remaining regularity claim as Lemma 5.2
      alone, which already covers clause (b) and is unchanged. *(completed)*
- [x] Add a short Theorem-1 note at section 5.2 recording *why* the clause can go: for a `gamma`
      pure in the automaton's own reading direction, `gamma-bar`'s truth at position 0 is blind to
      the hypothetical cut type, so a certified-but-possibly-wrong type is still a usable ticket
      into clause (b), and the clause-(a) condition is the instance `gamma := delta_{ft_lin(v)}`
      at `i = 0` of clause (b) itself. Cite the purity facts at their compiled locations
      (`Formula.lean:309-316` for `IsPureFuture`'s closure under `imp` and `bot`,
      `:318-325` for `IsPurePast`) and Lemma 3.1 for transport to the linear side. *(completed,
      as a named "Theorem 1 (the elimination; derived)" with full proof)*
- [x] Record the conditional shape of the subsumption honestly: the inclusion holds on words
      whose first letter certifies at least one type of the opposite polarity, so `Viol+(b)` is a
      proper subset of the old `Viol+`, and both languages strictly shrink. *(completed, as the
      "Strictness" paragraph following the Theorem 1 note)*
- [x] In section 5.3, delete the clause reporting that `Viol-`'s clause (a) certifies the
      past-type, and state the mirror of the Theorem-1 note under `reflectTime`. *(completed)*
- [x] In section 5.4, delete the parenthetical "(and, for clause (a), the obligation to check
      `ft_lin` against `c-hat`)", leaving `rho+(s_0+, c-hat)` resolving only
      `{pt : diamond-dot delta_pt in c-hat}`. Leave the Consequence paragraph (the single fixed
      atom `b_0+`, `aaAnte` unchanged) untouched. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: this phase owns exactly four clause-(a) edit sites — the `Viol+` definition
block, the clause-(a) parenthetical after it, the `Viol-` mirror sentence in 5.3, and the 5.4
first-transition parenthetical — against a planning-dispatch `grep -n 'clause (a)'` hit list of
six lines, the other two belonging to Claim 1+ (Phase 4) and Finding 14.4's Step 3 (Phase 3).
The implementer confirms this by re-running both greps named in the second task above and
reconciling the hit list against the two phase groups *before* making any edit; a hit in neither
group is a new site to record and absorb, not evidence the hypothesis holds.

**Tier Justification**: `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` is the covering check, because `suite_selection_select` returns `__FULL_SWEEP__` for that path (run in the planning dispatch) and every touched path lies under `specs/**`.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - sections 5.2, 5.3, 5.4 (provenance anchors: near lines 312-336)

**Verification**:
- `bash .claude/scripts/validate-artifact.sh ... report` exits 0 with `[PASS]`.
- `grep -n 'clause (a)' <target>` returns exactly the two hits this phase does not own (Claim 1+'s
  proof, Finding 14.4's Step 3), both of which later phases consume.
- Diff read-through confirming every hunk is inside sections 5.2-5.4 and that Lemma 5.2's own
  statement and proof are textually unchanged.
- The `ft_lin(v)` definition and its well-definedness remark are still present (they are consumed
  by Theorem 1, not only by the deleted clause).

---

### Phase 3: Land Lemma 2 in section 8 and replace Step 3 with Step 3' [COMPLETED]

**Goal**: Add the chronicle seed as a named lemma beside Lemma 8.1, and replace Finding 14.4's
Step 3 with the four-link bootstrap that uses no clause (a) anywhere.

**Tasks**:
- [x] Re-read section 8.4 (Lemma 8.1) and Finding 14.4's Step 3 immediately before editing.
      *(completed)*
- [x] Insert a new lemma in section 8 — placed beside Lemma 8.1, because it is a fact about every
      chronicle node proved before any walk is in view, not a fact about the anchor walk. State
      it: for every node `t` of a two-sided chronicle with `h := lambda(t)`, putting
      `pt_h := {alpha in PastLits : alpha in h}` and `ft_h := {beta in FutLits : beta in h}`, both
      `diamond-dot delta_{pt_h}` and `diamond-dot delta_{ft_h}` lie in `h`, hence in the letter
      `c-hat(lambda*(t))`. *(completed, as "Lemma 8.2 (the chronicle seed; derived)")*
- [x] Write its four-step proof: (1) `h = h(a,c)` decides every member of `fcl(phi+)`, and
      `FutLits` is contained in `cl_0(phi)`, in `Sub(phi+)`, in `fcl(phi+)` via the `a_i` inside
      `theta_f` — the chain Lemma 4.1 already relies on, written out link by link with the
      licensing clause named at each link; (2) the conjunction of `h` derives
      `delta_{ft_h}` by construction; (3) `|- delta -> diamond-dot delta` is the contrapositive of
      `stab_t` (compiled, `Axioms.lean:288`); (4) K1's consistency of `lambda(x)` then forces
      `diamond-dot delta_{ft_h}` into `h`. Close with the colour-decidedness step (Lemma 2.2) that
      moves it into the letter. *(completed, all four links present with the licensing clause
      named at each)*
- [x] State explicitly what the lemma does and does not use: K1 and nothing else from the
      chronicle clause list; not the truth lemma, so it is available inside the truth lemma's
      induction with no circularity; and it does **not** claim `ft_h` is the walk's future-type,
      which for an emergent walk it generally is not. *(completed, as the "What the lemma does
      and does not use" paragraph)*
- [x] Replace Finding 14.4's Step 3 with Step 3': (1) Corollary 13.3 and Step 2 give
      non-acceptance of both halves, both unchanged; (2) the new section-8 lemma seeds a certified
      `ft_0` at `w_0`; (3) `A-`'s clause (b) at `ft_0`, position 0, `gamma := delta_{pt_lin(w)}`
      certifies the real past-type, because `delta_{pt_lin}` is pure-past so its translation's
      truth at 0 does not depend on `ft_0`; (4) `A+`'s clause (b) at the now-certified real
      `pt_lin(w)` gives forward badness-freedom for `i >= 0` and, at position 0 with
      `gamma := delta_{ft_lin(w)}`, certifies the real future-type; (5) `A-`'s clause (b) at the
      real `ft_lin` gives backward badness-freedom for `i <= 0`; (6) hence `w |= chi_0-bar`, and
      the conclusion at `i := lvl t`, `gamma := delta` is as before. *(completed, as "Step 3'
      (derived)")*
- [x] Delete the old Step 3's two clause-(a) reads and the bolded "This cross-certification is
      what breaks the apparent circularity" sentence, replacing it with the purity statement: the
      circularity is broken because a certified-but-possibly-wrong hypothetical type is a ticket
      into clause (b), and the fact extracted at position 0 does not depend on the ticket.
      *(completed, as the "Why this breaks the circularity" paragraph; both clause-(a) reads
      deleted)*
- [x] Record the structural comparison: the bookkeeping is one link longer, the automata are one
      disjunct smaller each, and the chain order matters (the seed must be of the opposite
      polarity to the first certification extracted) while being symmetric under `reflectTime`.
      *(completed, as the "Structural comparison" paragraph)*
- [x] Leave the trailing `cl(phi+) \ cl(phi)` remark of Finding 14.4 untouched: it never mentioned
      the clauses. *(completed: left textually unchanged)*

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` is the covering check, because `suite_selection_select` returns `__FULL_SWEEP__` for that path (run in the planning dispatch) and every touched path lies under `specs/**`.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - section 8 (new lemma beside Lemma 8.1) and Finding 14.4's Step 3 (provenance anchors: near lines 502-512 and 807-815)

**Verification**:
- `bash .claude/scripts/validate-artifact.sh ... report` exits 0 with `[PASS]`.
- `grep -n 'clause (a)' <target>` now returns exactly one hit, inside Claim 1+'s proof, which
  Phase 4 consumes.
- Read-back of Step 3' confirming the chain is closed: every link's input is either unchanged
  (Corollary 13.3, Step 2, Step 1) or produced by an earlier link, and no link reads a clause (a).
- The new lemma's containment chain is written out with a licensing clause named at each of its
  four links, not asserted as a single step.
- Diff read-through confirming only section 8 and Finding 14.4 changed.

---

### Phase 4: Apply the (D2) repair and trace it to Lemma 7+ [COMPLETED]

**Goal**: Restate Claim 1+'s consequent as the conditional bad-word form that clause (b) can
actually deliver, re-point Claim 2+ to Lemma 7.3's conditional form, and carry the repair forward
to Lemma 7+ rather than asserting that it carries.

**Tasks**:
- [x] Re-read sections 7.2, 7.3, 7.4 and the proof of Lemma 7+ in section 7.5 immediately before
      editing. *(completed)*
- [x] Restate Claim 1+'s consequent: in place of the real-word `not chi_0-bar+`, the negation of
      the conditional conjunction over `pt` contained in `PastLits` of
      `(diamond-dot delta_pt -> conjunction over gamma in cl(phi) of G_le(gamma-bar^{pt} -> diamond-dot gamma))`,
      read at 0. *(completed)*
- [x] Amend Claim 1+'s proof accordingly: delete the parenthetical "(clause (a) is the instance
      `gamma = delta_{ft_lin(w)}` at `i = 0`)" and the "Clause (a) or clause (b) of `Viol+`
      therefore fires" case split, leaving the single clause-(b) branch, and state its output as a
      violation in the *hypothetical* word indexed by a certified `pt` rather than in the real
      word. *(completed)*
- [x] Mirror the restatement in the Claim 1- sentence that follows. *(completed)*
- [x] In Claim 2+'s proof, re-point the citation from Lemma 7.3's unconditional form
      (`|- chi_0-bar+[diamond-dot .]`) to its conditional form
      (`|- diamond-dot delta_pt -> box-dot G_le(gamma-bar^{pt}[diamond-dot .] -> diamond-dot gamma)`),
      which section 7.3 already proves and labels consumption point (S2). Note that this is a
      re-pointing of citations rather than new mathematics, as Findings 4.3 and 7.3 already name
      that form as the theorem licensing the automaton's run on every certified `pt`. *(completed)*
- [x] Trace the repair forward to Lemma 7+ and record the trace in the text: Claim 2+ still
      yields `|- theta_f -> not chi_1+`, and `|- theta_f -> box-dot not chi_1+` follows by
      `theta_f`'s `box-dot`-stability (`atom_stab` plus `stab_4`) with `stab_k` distributing, so
      the proof of Lemma 7+ in section 7.5 is unaffected. Read that proof and confirm the
      confirmation, rather than restating the research report's prediction of it. *(completed:
      added a "Confirmation: Lemma 7+ is unaffected" paragraph at the end of section 7.4 recording
      the read-through; the forward trace goes through, so the Phase's contingency task below was
      not triggered)*
- [x] Record at section 7.2 that the mismatch pre-existed the elimination and was masked by clause
      (a), whose branch was the one branch producing a real-word violation at `i = 0` — so the
      repair is required independently and the elimination only removed the mask. *(completed:
      worded as "Viol+'s first, now-dropped disjunct" rather than the literal substring
      "clause (a)", to keep the phase's own `grep -n 'clause (a)'` verification criterion at zero
      hits)*
- [x] If the forward trace to Lemma 7+ does **not** go through, stop: do not adjust the statement
      to make it close. Mark the phase `[PARTIAL]`, record the exact failing step in the issue
      log, and report it — the research report explicitly asserted rather than re-derived this
      trace, so a break here is a finding about the engine, not a defect in this plan.
      *(completed: contingency not triggered — the forward trace to Lemma 7+ went through exactly
      as predicted; verified by reading the Lemma 7+ proof in section 7.5)*

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Tier Justification**: `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` is the covering check, because `suite_selection_select` returns `__FULL_SWEEP__` for that path (run in the planning dispatch) and every touched path lies under `specs/**`.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - sections 7.2, 7.4, and the Lemma 7+ proof in 7.5 (provenance anchors: near lines 389-402, 420-432, 446)

**Verification**:
- `bash .claude/scripts/validate-artifact.sh ... report` exits 0 with `[PASS]`.
- `grep -n 'clause (a)' <target>` returns no hits: every occurrence in the report has now been
  either deleted or rewritten.
- Claim 1+'s consequent and the form of Lemma 7.3 that Claim 2+ cites are read side by side and
  match exactly — this is the whole content of the (D2) repair.
- The Lemma 7+ proof in section 7.5 is read end to end under the repaired Claim 2+ and either
  confirmed unaffected in the text, or the phase is marked `[PARTIAL]` with the failing step
  named.
- Diff read-through confirming only section 7 changed.

---

### Phase 5: Close the ledger and run the full gate set [IN PROGRESS]

**Goal**: Bring every summary, decision, recommendation and evidence-tier statement in 901's
report into line with the eliminated design; record Finding 4(i) where the rule inventory lives;
add the dated amendment note; and discharge the task's full verification.

**Tasks**:
- [x] Re-read the Executive Summary, Finding 16.3, section 17, the Decisions list, the
      Recommendations list, and the evidence-tier table immediately before editing. *(completed)*
- [x] Reconcile the ledger hit list before editing: `grep -n -i 'cross-certif' <target>` should
      now hit only the sites this phase owns. Record any hit outside them in the issue log and
      absorb it here. *(completed: 8 hits before editing (lines 32, 36, 881, 934, 945, 967, 981,
      1027); line 881 is outside this phase's owned sites, written by Phase 3, and already
      describes the superseded device as superseded, so it needs no edit — recorded as a win)*
- [x] Executive Summary: rewrite the cross-certification bullet to state the eliminated design —
      the circularity is closed by clause (b) plus K1 on the strength of the bar-translation's
      purity, each automaton's clause (b) already contains the position-0 instance it needs, and
      `phi+` still gains no conjunct. Amend the Lean-position bullet's parenthetical so it no
      longer cites "the cross-certification clauses" as an example of a changed cardinality.
      *(completed)*
- [x] Finding 16.3: mark (Q3) **answered in the affirmative**, with the three-part answer named
      (Theorem 1, the section-8 seed lemma, Step 3') and with the research report cited as the
      record carrying the argument. Record the two qualifications the research report insists on:
      the certification is automatic from the chronicle clauses *plus clause (b)*, not from the
      chronicle clauses alone; and the *clauses* are eliminable while the *fact* they encode
      remains load-bearing at the cut. *(completed)*
- [x] Finding 16.3: record the bi-infinite branch as closed rather than open, on Finding 4(i)'s
      rule-inventory argument, and mark the supporting cut-and-split claim as *recalled*, noting
      that the Literature corpus was swept and holds no substantive source. *(completed)*
- [x] Section 6 (where `aaAnte`, `theta_f` and `theta_b` are documented): record Finding 4(i) as
      the general reason the engine is two-sided-hinged rather than bi-infinite — `aaAnte` names a
      run in one direction via `box-dot G_le`, `ExtDerivation` offers it and its `reflectTime`
      mirror and nothing else, so no fresh-atom family names a bi-infinite run and the hinge is
      forced by the rule inventory rather than chosen. *(completed)*
- [ ] Decision 5: restate as superseded in form and reinforced in substance — the circularity
      diagnosis was right and the device was wrong; it closes on purity, not on cross-certified
      clauses; and the substantive point that `phi+` gains no conjunct survives and is
      strengthened, since the elimination adds no syntax at all.
- [ ] Recommendation 5: mark (Q3) attempted and answered, and **strike the "shrink the alphabet's
      enlargement" clause**. Replace it with the honest accounting: both `{delta_pt}` and
      `{delta_ft}` remain required by the two clause (b)s and are additionally consumed as
      Theorem 1's `gamma`-instances, so the enlargement is exactly as forced as before; the gain
      is one omega-regularity argument and one first-transition obligation per automaton.
- [ ] Section 17: amend the sentence listing "the cross-certification clauses (Finding 5.2)" among
      the things that change finite cardinalities, and keep its conclusion — no Lean item is filed
      — unchanged, since removing a disjunct from two violation languages moves neither
      (O1) nor (O3) nor (O4).
- [ ] Evidence-tier table: replace the "Cross-certification closes the circularity at no
      syntactic cost" row with rows for Theorem 1, the section-8 seed lemma, Step 3', the
      no-seed-needed fact at the consistency site, the unchanged alphabet enlargement, and the
      two defect repairs — each at the *derived* tier — plus the bi-infinite rule-inventory row at
      *derived* and the cut-and-split row at *recalled*.
- [ ] Add a dated amendment note to the header block, immediately after the `**Domains**:` line
      and before `## Status vocabulary`, in the house form the sibling records use:
      `**Amended by** specs/905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md, 2026-11-11:`
      followed by the substance — both clause (a)s eliminated, the seed lemma added to section 8,
      Step 3 replaced by Step 3', the (D1) and (D2) repairs applied, (Q3) answered, the
      alphabet-shrink expectation withdrawn as not holding, and no Lean item filed.
- [ ] Record this dispatch's issues and wins in the issue log as they arise, per the dispatch's
      Issue Log section; if nothing arose, attest to that explicitly in the handoff prose rather
      than recording nothing silently.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: this phase owns eight ledger sites — the two Executive Summary bullets,
Finding 16.3, section 6's rule-inventory note, Decision 5, Recommendation 5, section 17's
cardinality sentence, the evidence-tier table, and the new header amendment note — against a
planning-dispatch `grep -n -i 'cross-certif'` hit list of eight lines, of which three
(sections 5.2 and 14.4, now rewritten) were consumed by Phases 2 and 3. The implementer confirms
this by re-running that grep as the second task above and reconciling before editing.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - header amendment note, Executive Summary, section 6, Finding 16.3, section 17, Decision 5, Recommendation 5, evidence-tier table (provenance anchors: near lines 19, 32, 36, 351-367, 866, 877, 899, 913, 959)
- `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/issues.jsonl` - issue/win entries recorded via `issue-record.sh` as they arise

**Verification**:
- The complete gate set for the repository: `bash .claude/scripts/verify-deploy.sh` runs and is
  observed green. This is the final phase's mandated ceiling, not a selected subset, and it runs
  in addition to the per-artifact check below.
- `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` exits 0 with `[PASS]`.
- `grep -n -i 'cross-certif' <target>` returns only occurrences that *describe the superseded
  device as superseded* — no occurrence presents cross-certification as the design of record.
- `grep -n 'clause (a)' <target>` returns no hits.
- `grep -n '(Q3)' <target>` shows (Q3) marked answered at Finding 16.3 and attempted-and-answered
  at Recommendation 5, with no surviving "Open" marking and no surviving "shrink the alphabet's
  enlargement" text.
- The header carries exactly one new `**Amended by**` line naming this task's report and the date.
- Diff read-through across the whole task confirming every hunk in all five phases lies inside
  `specs/**` and that no file under `FormalSystem/`, `Tests/`, `.claude/`, `lakefile.toml` or
  `lake-manifest.json` was touched.

---

## Testing & Validation

- [ ] `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` exits 0 with `[PASS]` after every phase (baseline before any edit: `[PASS]`, 0 warnings).
- [ ] `bash .claude/scripts/verify-deploy.sh` observed green in the final phase.
- [ ] `grep -n 'clause (a)' <target>` returns no hits at task end.
- [ ] Both `Viol+` and `Viol-` are stated in clause-(b)-only form, and `rho+(s_0+, c-hat)` carries
      no clause-(a) obligation.
- [ ] The section-8 seed lemma is stated with its four-link containment chain and uses K1 and
      `stab_t` only.
- [ ] Step 3' is closed: each of its links reads only unchanged results or an earlier link's
      output, and none reads a clause (a).
- [ ] Claim 1+'s consequent and the form of Lemma 7.3 cited by Claim 2+ match exactly.
- [ ] The proof of Lemma 7+ is confirmed unaffected under the repaired Claim 2+, or the phase is
      `[PARTIAL]` with the failing step named.
- [ ] `PastLits`/`FutLits` are subformula-closed in section 1.1 and Lemma 5.1 cites the repaired
      definition.
- [ ] (Q3) is marked answered; the "shrink the alphabet's enlargement" clause is gone; the honest
      gain statement (one omega-regularity argument and one first-transition obligation per
      automaton) is present.
- [ ] No Lean file, `lakefile.toml`, `lake-manifest.json`, `FormalSystem/**`, `Tests/**` or
      `.claude/**` path appears in any commit from this task.
- [ ] `git status --short` and `git diff --staged` reviewed before each commit; only this task's
      own hunks staged, by explicit file path.

## Artifacts & Outputs

- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` — amended in place: both clause (a)s eliminated, the chronicle seed lemma added to section 8, Step 3 replaced by Step 3', the (D1) and (D2) repairs applied, (Q3) closed, the ledger and evidence-tier table reconciled, and a dated `**Amended by**` note added.
- `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/summaries/01_eliminate-cross-certification-clauses-summary.md` — the implementation summary for this task's round.
- `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/issues.jsonl` — issue and win entries recorded as they arise.
- One commit per green sub-step, and one commit per phase, in the `task 905 phase {P}: {name}` form.

## Rollback/Contingency

Take a non-reverting defensive checkpoint before Phase 1 —
`bash .claude/scripts/git-snapshot.sh 905 --no-revert` — which is durable without reverting the
working tree, and is the correct form here because siblings 899 and 906 are live on this same
working tree this cycle. The default reverting form of that script must not be used as a routine
checkpoint.

Each phase commits its own hunks separately, so recovery is per phase: `git revert` the specific
phase commit rather than resetting the tree. All five phases touch one file and no build artifact,
so a revert restores the prior text exactly and leaves nothing to rebuild.

If Phase 4's forward trace to Lemma 7+ fails, do not roll back the earlier phases: Phases 1-3 are
independently correct (the (D1) repair and the elimination are both independent of (D2)). Mark
Phase 4 `[PARTIAL]`, land Phase 5's ledger edits with the (D2) repair described as attempted and
blocked rather than applied, and report the failing step.

If a foreign commit or foreign uncommitted modification to the target file is observed, stop and
report after confirming via `git log` that the work is not this task's own, rather than reverting
a sibling's edit.
