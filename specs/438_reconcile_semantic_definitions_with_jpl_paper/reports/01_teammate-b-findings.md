# Teammate B Findings: Cluster Staleness Verdicts and Dependency-Cycle Resolution

- **Task**: 438 `reconcile_semantic_definitions_with_jpl_paper`
- **Slice**: Part A deliverables 4 (per-task staleness verdict) and 5 (dependency cycle resolution)
- **Authoritative source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (read-only)
- **Scope note**: this report SPECIFIES what Part B must do to the six cluster tasks and to the
  dependency edges; it does not itself edit `specs/state.json` or rename any directory.

## Key Findings

1. The paper-refactor cluster is confirmed to still be exactly the six tasks named in the task
   438 description — 414, 415, 417, 419, 420, 427 — by re-querying `topic=="paper-refactor"` in
   `specs/state.json`. No task has been added to or removed from the cluster since 438 was
   written.
2. 420's three helper theorems (`limit_nullity_of_succOrder`, `limit_nullity_of_shift`,
   `exists_uniform_radius_of_finite`) are confirmed, by direct reading of
   `FormalSystem/Semantics/TaskFrame.lean:261,289,340`, to be stated against a bare relation
   `R : W → D → W → Prop` with the Nullity/Limit hypotheses passed in as explicit arguments
   (`hnull`, `hzero`, `hlim`), not against any `TaskFrame` structure field. They survive
   verbatim as theorems. The renamed axiom "Limit" (formerly "Limit Nullity") is textually and
   mathematically unchanged (`⋂_{x>0} (w)_x = {w}`, `possible_worlds.tex:911`/`:2454`), so
   `hlim`'s statement still matches exactly. The one thing that changes is how `hnull` gets
   discharged: Nullity is no longer a frame axiom to cite directly but a derived lemma
   `lem:nullity` (from Seriality + Limit); `limit_nullity_of_succOrder`'s hypothesis must now be
   proved via that derived lemma rather than read off a structure field.
3. 414's Omega-excision reachability figures (~110 affected declarations: ≈88 dead, 16
   live-and-portable, 8 live-and-unportable) are confirmed EXACTLY against
   `specs/414_.../reports/02_group-c-reconciliation.md` Finding 7 (88 dead + 9 LIVE-P + 7
   LIVE-P+lemma = 16 + 8 LIVE-UNPORT). This bucketing (a kernel-level reachability fact about
   which Omega-touching declarations are dead/live/portable) is orthogonal to the
   totality-vs-maximality predicate choice — dead code stays dead and live code stays live no
   matter which predicate replaces `Omega`/`IsMax`. **However**, the *content* of what the
   "mechanical rewrite" for each LIVE-P/LIVE-P+lemma declaration must produce is NOT
   orthogonal: every rewrite target quoted in that report (e.g. `IsMax τ` packaging,
   `isMax_timeShift`, `multiFam_isMax_iff`) is phrased against maximality and must be
   re-derived against totality (see 414's verdict below).
4. 414's ~85-line prototype (`Preorder` instance, `timeShift_mono`, `isMax_timeShift`,
   `chainSup`, `exists_maximal_extension`) targets Mathlib `IsMax` under the extension order.
   The paper's target predicate for `H_F`/box/`valid`/`SemanticConsequence` is **totality**
   (`X = D`, `def:world-history`, `possible_worlds.tex:2570` region, restated at `:951`: "I
   will write $H_{\F}$ for the set of all **total** world histories"). These are not the same
   predicate. See the detailed reusability breakdown below.
5. The paper's OWN worked non-example for the *Spherical* axiom
   (`possible_worlds.tex:926`, footnote to the world-history definition) is a ℚ-carrier flow
   construction structurally very close to 419's proposed Q-flow CO/Reynolds countermodel
   sketch, and it is exhibited specifically as a structure that satisfies **every axiom except
   Spherical**. This is a direct, paper-sourced red flag for 419's sketch, detailed below.
6. The dependency cycle is confirmed and is a strict 2-cycle between 420 and 415
   (`420.dependencies ∋ 415` AND `415.dependencies ∋ 414, 420`), not merely a 3-node cycle
   `420→415→414→420` as the task description states — 420 and 415 depend on each other
   directly, and 414 is folded into a second, overlapping 3-cycle. `generate-task-order.sh
   --print` was re-run and confirms the reported symptom exactly: 415 lands in wave 1 with
   "Blocked by: --" despite three declared dependencies.

## Cluster Inventory (re-queried)

```
$ jq -r '.active_projects[] | select(.topic=="paper-refactor") | "\(.project_number) \(.project_name) \(.status)"' specs/state.json
420 align_task_frame_with_positive_cone_limit_nullity   blocked
419 machine_check_co_reynolds_independence               not_started
414 refactor_semantics_to_maximal_history_validity       researched
415 completeness_over_maximal_history_semantics          researched
417 semantic_fmp_finite_worldstate_over_z                researched
427 sync_typst_book_with_refactored_paper                not_started
```

Confirmed: exactly the six named in the 438 description, no additions.

## Per-Task Staleness Verdicts

### Task 414 — `refactor_semantics_to_maximal_history_validity`

**Survives** (from `specs/414_.../reports/01_maximal-history-validity-refactor.md` and
`02_group-c-reconciliation.md`):
- The extension `Preorder` on `WorldHistory` (`τ ≤ σ` iff domain-inclusion + state-agreement on
  the smaller domain) — this order is predicate-agnostic; both "maximal" and "total" are
  properties definable relative to it, and totality trivially implies maximality under this
  order (a total history admits no proper extension), so the order itself is still the right
  scaffolding.
- `timeShift_mono`, the shift/unshift lemma pair, and `chainSup` (the chain-union construction)
  — pure order-theoretic machinery, axiom-content-free.
- `exists_maximal_extension` (Zorn) — still true and still useful, but demoted from "the target
  existence theorem" to "an internal lemma en route to" `thm:extension`. Totality is *stronger*
  than maximality in general; the paper's `thm:extension` ("every task-constrained function on a
  nonempty subset of $D$ is extended by some total world history",
  `possible_worlds.tex` region around `def:frame`/Spherical, invoked at `:1013`, `:1003`) needs a
  proof that a Zorn-maximal extension is in fact *total*, which requires Seriality and
  Spherical (see app:gluing coupling below, and `possible_worlds.tex:912-913`: "Spherical
  provides a common way-station in the limit, so that jointly tightening constraints from the
  past and future never close in on an empty gap"). That additional step is NOT in the 85-line
  prototype and cannot be, since Seriality/Spherical do not exist in the Lean `TaskFrame`
  structure yet (420 territory).
- `isMax_of_total` (`τ` total ⇒ `IsMax τ`) survives and becomes the *load-bearing* direction
  post-refactor (rather than a minor rescue lemma for 415): it is exactly the fact that lets a
  totality-based `H_F` sit inside the maximal-extension machinery.
- Finding 6/7's soundness-survival analysis (soundness needs only shift-preservation, not Zorn
  extension) is a claim about *which* lemma soundness consumes, not about *what predicate* that
  lemma is stated for. A totality-based `time_shift_preserves_truth` needs "totality is
  preserved by time-shift," which is immediate (`domain t` shifted is still `domain (t - Δ)`
  over all `t` iff `domain = D` — no Zorn, no chain argument, trivially simpler than
  `isMax_timeShift`). This soundness-side finding therefore survives a fortiori (the new proof
  obligation is strictly easier than the one already verified).
- The Group C dead/live/portable bucketing and the 88/16/8 counts (Key Finding 3): survives as
  a reachability fact. The specific replacement text for each LIVE-P/LIVE-P+lemma declaration
  (`IsMax`-flavored) does not survive and must be re-derived against totality — in most cases
  this is a *simplification*: e.g. `multiFamOmega` (`ReynoldsBridge.lean:694`) is already
  described as "total-domain flow line" (`multiFamHistory` "total-domain flow line" per Finding
  4c in report 02), so the deterministic-flow lead frame construction is plausibly Omega-free
  totality-native already and may need LESS rework than the maximality framing implied, not
  more.

**Refuted**:
- The task description's own "DEFINITIONAL ALIGNMENT... make maximal-history validity THE
  validity of the repo" charter is refuted at the root — `IsMax` is not the paper's predicate.
- Finding 5's target Lean signatures (`TruthAt`'s box clause `∀ σ, IsMax σ → TruthAt M σ t φ`;
  `valid`/`SemanticConsequence`/`satisfiable`'s `IsMax τ` binders) are refuted verbatim and must
  be re-issued with a totality predicate (paper: `X = D`; Lean target, not to be implemented
  here per 438's NON-GOALS, but to be named for the next research pass: something like
  `WorldHistory.IsTotal σ := ∀ t, σ.domain t`, or reusing `isMax_of_total`'s existing witness
  shape).
- Finding 4's naming discussion ("use `IsMax` directly... `WorldHistory.IsMaximal` alias") is
  moot — whichever predicate name is chosen, it must denote totality, not `IsMax`.
- "414's charter (Omega-free maximal-history validity) is mathematically unaffected" (from
  414's own *current* description, the "FRAME-PRESENTATION COORDINATION" paragraph) is now
  doubly wrong: not only does the frame-axiom change not leave 414's charter untouched (as that
  paragraph already conceded needed revisiting once def:frame changed again), but 414's
  *charter itself* (maximal-history validity) is the thing that must change to
  totality-history validity.

**Re-issued description must say**: the target predicate for `TruthAt`'s box clause, `valid`,
`SemanticConsequence`, `satisfiable`, and `H_F` generally is **totality** (`∀ t, τ.domain t`),
not Mathlib `IsMax`; that the `Preorder`/Zorn/`chainSup`/`isMax_timeShift`/`isMax_of_total`
prototype in `reports/01_...md` is preserved as reusable *engine* material for `thm:extension`
but is not itself the destination API; that proving a Zorn-maximal extension is total requires
Seriality and Spherical, which do not yet exist in `TaskFrame` (blocks on 420's still-open
Spherical/Seriality transcription, a NEW dependency this task does not currently declare); that
the Group C 88/16/8 reachability bucketing from `reports/02_...md` survives as a fact but every
quoted replacement lemma name in it is maximality-flavored and must be re-targeted at totality
during implementation; and that `\label{def:frame}`, `\label{def:world-history}`
(`possible_worlds.tex:2570`), and the `H_F`/possible-worlds restatement at `:949-960` are the
live anchors (superseding the "def:world-history at line 1833" citation in report 01, which
predates the paper's Seg/fiber/Spherical package and the totality-vs-maximality wording split).

**Proposed status**: `not_started`. The existing research (both reports) is extensive and
much of its *engineering* survives, but its *target signature* — the single most
consequential fact a re-dispatch needs — is wrong, and re-running research against the correct
target is cheap relative to the cost of an implementer building the wrong API. Per deliverable
8's rule ("where a task's TARGET definition changed, its existing research was conducted
against the wrong target and the task returns to not_started"), this applies squarely to 414.

**Proposed rename**: yes. `refactor_semantics_to_maximal_history_validity` names the wrong
predicate. Proposed: `refactor_semantics_to_total_history_validity` (mirrors the existing slug
shape, swaps only the predicate word). Directory rename cost: `specs/414_.../` contains 2
reports + no plan/summary yet beyond the phases-1-5-adjacent prototype notes (414 itself has
not been implemented — the summary/commits cited above all belong to 420, not 414). Rename
surface is therefore low: the two report files' own internal cross-references to "maximal" in
prose would become historically-accurate-but-superseded language (acceptable, since deliverable
8 says never delete superseded reports) plus any cross-references FROM 415/417/420's
descriptions TO 414 by directory path. A grep for `414_refactor_semantics_to_maximal_history_validity`
outside `specs/` should be run before the rename to confirm no deliverable-tree reference
exists (expected: none, per the no-task-references-in-deliverables rule already forbidding this
class of citation outside `specs/`).

### Task 415 — `completeness_over_maximal_history_semantics`

**Survives**:
- The overall staging plan (Discrete → Dense → Base → Dedekind) and the decision to internalize
  realization into the constructions rather than bridge — this is a proof-architecture decision
  independent of the target predicate.
- The identification of the deterministic lead frame (`bundleFlowFrame`,
  `WorldState := FamIdx × D`) as the right countermodel engine: per 414's report 02 Finding 4c,
  the discrete `multiFam*` family is already framed around "total-domain flow line" reasoning
  (`multiFamHistory`/`isMax_of_total` gives maximality "in one line" *because* the flow is
  total), so this construction is plausibly ALREADY closer to a totality-native countermodel
  than a maximality-native one — good news for reuse, but the description's own vocabulary
  (`bundleFlowFrame` discharging `limit_nullity` "via `TaskFrame.limit_nullity_of_shift`") is
  still accurate (Finding 2 above: this helper theorem is axiom-content-agnostic and unaffected
  by the totality/maximality swap).
- The NEW obligation already anticipated in 415's current description ("must additionally
  discharge Seriality and Spherical, not just Limit") is *correctly anticipated content*, even
  though it currently cites the SUPERSEDED three-axiom framing elsewhere in the same
  description (see Refuted below) — this specific sentence should be kept and strengthened, not
  discarded.

**Refuted**:
- "Completeness over Omega-free, **maximal-history** semantics" — wrong target predicate,
  inherited transitively from 414 per the task description's own admission ("written explicitly
  against 414's maximal-history semantics; inherits the error transitively").
- "the FULL maximal-history set is the required countermodel family" — must become "the full
  total-history set (`H_F`) is the required countermodel family."
- The description's Limit-Nullity-obligation paragraph still calls the axiom "Limit Nullity"
  (superseded name; current name is "Limit", same math) and says "once TaskFrame carries the
  Limit Nullity field" as if Limit were the only new obligation — it must now also name Seriality
  and Spherical as first-class per-class proof obligations, not just Limit (a claim already
  half-present in the paragraph but under-scoped relative to the current four-axiom set).

**Re-issued description must say**: target totality, not maximality, for the countermodel
family; that the deterministic lead-frame strategy is retained and is plausibly favorable for
totality (not merely tolerant of it); that each canonical/chronicle construction must discharge
all three new/renamed frame conditions relevant beyond Compositionality — Seriality, Limit, and
Spherical — with Spherical flagged as the least routine (per `possible_worlds.tex:912-913`'s own
warning that the "directed form is calibrated" and that a weaker chain form "no longer supports
the extension theorem" over orders with mismatched cofinalities — i.e., Spherical's Lean
transcription is not expected to be mechanical); and that biconditional Compositionality
(interpolation direction) is a new proof obligation for any construction that previously relied
only on the lax inclusion direction.

**Proposed status**: `not_started`. Same target-predicate rule as 414 applies, and 415 is
explicitly "researched... written explicitly against 414's maximal-history semantics" per its
own current description — it cannot safely resume from `researched` because its research
premise (414's now-refuted target) is the thing that changed.

**Proposed rename**: yes. `completeness_over_maximal_history_semantics` →
`completeness_over_total_history_semantics`. Rename surface: one report file
(`reports/01_completeness-maximal-history-rebase.md`), referenced by 414's report 02 by relative
path (`specs/415_completeness_over_maximal_history_semantics/reports/01_...md`) — that
cross-reference would need updating if the rename lands, or the report should be left with a
note that its path is historical. No plan/summary exists yet.

### Task 417 — `semantic_fmp_finite_worldstate_over_z`

**Survives** (from `specs/417_.../reports/01_semantic-fmp-finite-worldstate.md`, not read in
full here since Teammate A owns the Lean-target reconciliation table, but the task-level claim
is checked against 417's own description): the "Limit Nullity note" in 417's description is
CORRECT as pure mathematics and needs only a renaming pass, not a re-derivation — "over D = Z
the new Limit Nullity frame axiom is automatic (|y| < 1 forces y = 0, then nullity_identity)" is
exactly what `TaskFrame.limit_nullity_of_succOrder` (Key Finding 2) proves, and the axiom
(renamed "Limit") is unchanged in content. Seriality and Spherical are NOT flagged as automatic
over Z in 417's current description and were not part of the original three-axiom frame it was
written against, so this is a genuine gap the re-issue must close, not a survives/refutes call —
see below.

**Refuted**: 417 states it is "against the refactored Omega-free maximal-history semantics of
task 414," inheriting 414's now-refuted target predicate transitively, exactly like 415. Every
place 417's eventual Lean target would have named `IsMax` must instead name totality.

**Re-issued description must say**: target totality (not maximality) per 414's corrected
charter; that the "Limit Nullity... automatic over Z" claim survives verbatim under the renamed
"Limit" axiom; and — new gap — whether Seriality and Spherical are ALSO automatic over
`D = ℤ` needs to be checked during 417's next research pass (Seriality is plausible-automatic
for any frame with no genuine dead ends, which is likely true of the finite-`WorldState`-over-ℤ
construction by design, but Spherical is exactly the axiom whose failure mode the paper
illustrates on a ℚ-flow at `possible_worlds.tex:926` — a finite-`WorldState`-over-ℤ frame is a
much smaller structure than that counterexample and Spherical's directed-intersection condition
over a discrete order is far more likely to degenerate to a finite/eventually-constant
intersection, but this is a claim to verify, not to assume).

**Proposed status**: `not_started`, same target-predicate rule as 414/415.

**Proposed rename**: not required. `semantic_fmp_finite_worldstate_over_z` does not name the
maximal/total predicate at all and remains accurate.

### Task 419 — `machine_check_co_reynolds_independence`

**Survives**: the CONVERSE direction (`co_derived` in
`FormalSystem/Theorems/DedekindDerived.lean`, `co_valid` in
`FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`) is unaffected — it is a proof-system
derivability fact (Reynolds ⊢ CO) that does not depend on `def:frame`'s axiom count at all, and
419's description already correctly marks it "done and sorry-free... do not redo." The overall
goal (build a Lean countermodel showing CO does not derive `prior_U_gap`) is unaffected in kind
by the def:frame refactor — the paper itself never mentions "Prior-U," "Reynolds," or "Stavi"
anywhere (confirmed: zero grep hits in `possible_worlds.tex` for all three terms), so this
independence result is, and remains, an entirely repo/Lean-side concern layered on top of the
paper's CO axiom, not a paper claim that changed.

**Refuted / at risk — this is the most consequential finding in this slice**: 419's proposed
countermodel sketch ("a rational (ℚ) flow carrying isolated `¬φ` points that accumulate at an
irrational from above validates every CO instance while refuting Prior-U") is now shadowed by
the paper's OWN worked non-example for the Spherical axiom, `possible_worlds.tex:926`
(footnote to `def:world-history`, verbatim):

> "Convexity alone does not guarantee extendability: taking $D = \mathbb{Q}$ and
> $W = \{q \in \mathbb{Q} : q > 0\}$ with $r \Rightarrow_x r'$ *iff* $|r' - r| \leq x$ yields a
> structure satisfying every axiom but *Spherical*, in which the task-constrained function
> $\tau(t) = 1 - t$ defined for $0 < t < 1$ admits no value $u$ at the time $1$... *Spherical* is
> exactly what excludes this structure."

This is structurally the same family of construction 419's sketch proposes: a ℚ-carrier flow
whose behavior is engineered around a point NOT reachable within ℚ (the paper's example: no
total extension at $t=1$ because the limiting value is forced outside the positive rationals;
419's sketch: isolated `¬φ` points "accumulate at an irrational from above"). The paper is
telling us, in its own worked example, that this exact shape of ℚ-based construction is the
textbook way to violate Spherical. Since Spherical is now a hard requirement of `def:frame`
(`possible_worlds.tex:2454`, appendix formal statement) and of `H_F`'s nonemptiness/`thm:extension`
machinery that any legitimate countermodel frame must respect, **419's sketch is at serious risk
of not being a legitimate `TaskFrame` at all under the new four-axiom `def:frame`** — not merely
requiring an updated proof, but potentially requiring an entirely different carrier/frame choice
if it cannot be repaired to satisfy Spherical. This is a genuine open mathematical question, not
something resolvable from research alone; it is the single highest-priority item for 419's
re-issued research phase. (Compositionality's added interpolation direction and the new
Seriality axiom are comparatively low-risk for a deterministic/near-deterministic flow
construction — interpolation is close to automatic for a metric-style flow relation, and
Seriality just needs every state to have both a forward and backward successor at every positive
duration, which a ℚ- or ℝ-indexed flow typically has for free. Spherical is the one that
specifically targets "gaps," which is the entire mechanism 419's sketch is trying to exploit.)

**Citation correction**: 419's description cites "CO source formula:
PossibleWorlds/JPL/possible_worlds.tex:3250" — this line number is stale/wrong (line 3250 falls
inside unrelated CO+/CO- discussion prose, not the CO axiom) and the SAME error already exists
verbatim in `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md:158` ("paper BX_c
uses the single axiom CO (line 3250)"), so 419 inherited a stale citation from fix.md rather
than introducing a new one. The paper defines the axiom-item macro `\aitem` (`possible_worlds.tex:366`)
to `\refstepcounter{acount}\label{#2}`, so the CORRECT anchors are:
- `\label{CO}` at `possible_worlds.tex:1217` — the base **TM** axiom, verbatim:
  `\aitem{CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.`
- `\label{TMP-CO}` at `possible_worlds.tex:3709` — the **TM$^+$** restatement inside
  `def:TMplus-c` (`\label{def:TMplus-c}` at `:3706`), which the Lean tree's `Formula.co`
  actually mirrors (per `FormalSystem/ProofSystem/Axioms.lean:367-369`), verbatim:
  `\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.`
  with the paper's own footnote: "This axiom coincides with \textbf{\ref{CO}} in \textbf{TM},
  though it is expressed in $\BL^+$" (`:3711`). `\label{TMP-CO}` is the more precise anchor for
  419's purposes since it sits inside `def:TMplus-c`, the exact definition fix.md C4 amends.

**Re-issued description must say**: replace `possible_worlds.tex:3250` with `\label{TMP-CO}`
(and/or `\label{CO}` for the base-TM form) as above; flag the Spherical risk to the Q-flow
sketch as the primary open question for 419's next research pass, quoting
`possible_worlds.tex:926`'s worked non-example directly so the next agent does not have to
rediscover it; and note that the converse-direction proof (`co_derived`/`co_valid`) and the
overall goal statement are unaffected and should not be redone.

**Proposed status**: `not_started` stands (already `not_started`; no research artifacts exist
to preserve or invalidate). No status change needed, only a description rewrite.

**Proposed rename**: not required. `machine_check_co_reynolds_independence` remains accurate.

### Task 420 — `align_task_frame_with_positive_cone_limit_nullity`

**Survives** (verified directly against
`specs/420_.../summaries/01_taskframe-limit-nullity-alignment-summary.md` and
`FormalSystem/Semantics/TaskFrame.lean`):
- Phases 1-5, landed and green across 5 commits (`334371dfb`, `4fc1307a3`, `cd6856c00`,
  `5b22bb957`, `322bcd6af`), are NOT invalidated by the axiom-set expansion in the sense of
  needing to be reverted — they remain true, sorry-free, zero-new-axiom results. Specifically:
  the re-anchored `def:frame` citations (phase 1) point at `possible_worlds.tex:2423-2451` /
  `908-926`, which are still the live `def:frame` region (now a larger, four-axiom region, but
  the anchor itself is still correct as a pointer); the three helper theorems (phase 3-4) survive
  per Key Finding 2 above; and the LaTeX restatement (phase 5) is *textually* still present and
  compiling, though it is now itself STALE CONTENT (see Refuted) — the phase's *mechanical work*
  (adding `\label{def:frame}`, the `\poscone`/`\taskcone` macros, the primitives table) survives
  as reusable scaffolding even though the definition text it currently states must be rewritten
  again.
- The phase-2 docstring recast from "divergence" to "agreement" framing is directionally still
  correct and should not be re-inverted — the paper continues to use the positive-cone
  presentation; only the axiom count and content within that presentation changed further.
- The blocker mechanism (phase 6 needs 415's `bundleFlowFrame` to discharge Limit for
  `ParametricCanonicalTaskFrame`) is unaffected in its *reasoning* by the new axioms — the same
  duration-blind dense frame will need the same deterministic-shift repair, now for Limit,
  Seriality, and Spherical all together rather than for Limit alone.

**Refuted**: the entire description is written against the superseded three-axiom frame
(iff-Nullity as a real axiom + lax positive-cone Compositionality + "Limit Nullity", with
Reflection derived and Occurrence unaddressed) and explicitly states "equality would additionally
assert interpolation, **NOT adopted**" — this is now backwards; interpolation IS adopted (the
biconditional). Concretely refuted claims in the current description:
- "nullity_identity matches iff-Nullity" as a *primitive axiom* match — Nullity is now DERIVED
  (`lem:nullity`), so `nullity_identity` as an axiom-field is itself now a divergence from the
  paper (the Lean structure still has it as a hard axiom field; the paper demotes it to a
  lemma), not an agreement, though keeping it as an axiom in Lean is a legitimate simplifying
  choice to flag rather than something that must change — Teammate A's target-signature
  deliverable should rule on whether Lean should also demote it.
- "forward_comp... is exactly the official lax positive-cone law" — refuted; the paper's law is
  now biconditional (interpolation), so `forward_comp`'s current one-directional (⊇-only)
  statement under-specifies the axiom and is missing the interpolation (⊆) direction entirely.
- The title itself, "align...with...limit_nullity," names only one of what is now four axioms
  (Compositionality, Seriality, Limit, Spherical), and "Limit Nullity" is itself a superseded
  name (now just "Limit," since Nullity is no longer bundled into it).
- Absent entirely from the current description and from `TaskFrame.lean`: Seriality, Spherical,
  the segment/fiber machinery (`Seg(w, v; a, b)`), and the biconditional's interpolation
  direction — all of which are now required `def:frame` content, not optional extensions.

**Re-issued description must say**: the CURRENT four-axiom `def:frame` (Compositionality as
biconditional, Seriality, Limit, Spherical) with `possible_worlds.tex:2412` (`\label{def:frame}`)
as the formal anchor and `:905-914` region as the body-prose anchor; that phases 1-5's landed
work (citations, docstrings, the three Limit-only helper theorems, the LaTeX restatement) is
preserved but the LaTeX restatement itself is now stale a second time and needs a further
rewrite pass to add interpolation, Seriality, Spherical, and the segment/fiber apparatus; that
`nullity_identity` as a structure field vs. a derived lemma is an open design question for the
target-signature deliverable rather than settled; and that phase 6 (the `limit_nullity` field)
must be redesigned as a larger phase adding Seriality, Spherical, and interpolation fields/proof
obligations together, still gated on 415 per the dependency analysis below, but on a corrected
dependency edge.

**Proposed status**: `blocked` stands (do not reset). This is the task 438 description's own
explicit exception: 420's phases 1-5 are landed, green, and committed, so no status transition
may present that work as undone. Recommend keeping `blocked` with a revised `blockers` field
that (a) preserves the existing 415-blocking explanation for whatever remains of the original
Limit-field obligation, and (b) adds that the description itself is now stale a second time and
the next research pass must first re-scope phase 6 (and probably add new phases) against the
four-axiom target before resuming implementation. `partial` was considered and rejected: `partial`
in this codebase's status vocabulary connotes an interrupted/incomplete implementation attempt,
whereas 420's phases 1-5 are each fully complete and green in their own right — `blocked` more
accurately signals "cannot proceed until an external dependency and a description rewrite are
both resolved," matching the existing blockers-field convention already in use for 420.

**Proposed rename**: yes. `align_task_frame_with_positive_cone_limit_nullity` names one axiom
("limit_nullity") out of four and that axiom's own name is superseded ("Limit Nullity" →
"Limit"). Proposed: `align_task_frame_with_positive_cone_axioms` (keeps "positive-cone", drops
the now-inaccurate single-axiom qualifier, matches the pattern of naming the *presentation*
rather than enumerating axioms that may change count again). Rename surface: 420 has the most
artifacts of any cluster task (plan, report, summary, `.return-meta.json`,
`.orchestrator-handoff.json`) plus THREE other tasks' descriptions reference it by number (414,
415, 417 all say "task 420" / "420" internally, and 427's description says "420 fixes the frame
definition itself"). Per the source-store/deliverables rule, none of these are deliverable-tree
files (they're all under `specs/`, the carved-out exception), so referencing 420 by number
inside other tasks' `specs/state.json` descriptions is fine and does not need to change to a
name-based reference — but a directory rename would require updating the `artifacts[].path`
entries inside 420's own `state.json` record (3 paths) and confirming no other task's artifact
path field points into `specs/420_.../`. This is a real but bounded cost; record it for Part B's
implementer rather than resolving it here.

### Task 427 — `sync_typst_book_with_refactored_paper`

**Survives**: the overall charter (typst book is stale, must be resynced last, after the whole
chain lands) and the audit scope (not just `02-semantics.typ` — also `04-metalogic.typ`,
`p2-frame-classes.typ`, `p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`) are unaffected — these are
process/scope statements, not definitional content. The stale-line-anchor discipline it already
calls for (re-derive `TaskFrame.lean` line numbers and paper line numbers rather than trusting
either) remains exactly the right instruction and is, if anything, more urgent now.

**Refuted**: the description's explicit instruction "The corrected LaTeX wording is in
`latex/subfiles/02-Semantics.tex` and should be the model for the typst restatement" is WRONG as
of this task's own re-issue: `latex/subfiles/02-Semantics.tex` was rewritten by 420 phase 5
against the THREE-axiom frame (iff-Nullity + lax Compositionality + Limit Nullity), which is
itself now superseded by the four-axiom frame. Using it as the typst model today would write the
same superseded definition into the typst book that 420 phase 5 just wrote into the LaTeX
subfile — i.e., the exact failure mode task 438's own description already calls out ("that
instruction is now wrong and must be corrected as part of Part B"), now confirmed by direct
reading of both the current LaTeX subfile content (via 420's summary, Phase 5 section) and the
current paper. The "KNOWN STALE SITE" enumeration in 427's description (one-way Nullity,
substantive Reflection, unrestricted mixed-sign Compositionality, missing "Limit Nullity") is
itself now incomplete — it is missing Seriality, Spherical, the biconditional/interpolation
direction of Compositionality, and the segment/fiber apparatus as ALSO-stale content relative to
typst's current (pre-420-phase-5-even) state.

**Re-issued description must say**: do NOT use `latex/subfiles/02-Semantics.tex` as the model
until/unless it is itself re-corrected to the four-axiom frame (which is not this task's job —
that is 420's remaining work); instead model the typst restatement directly on
`possible_worlds.tex` `\label{def:frame}` (`:2412`, four axioms) the same way 420 phase 5
originally modeled the LaTeX subfile on the paper, with an explicit note that the LaTeX subfile
is a fellow downstream consumer, not a second source of truth, and may itself still be mid-sync
when 427 runs; and that the stale-site enumeration must be re-audited against the current
four-axiom paper rather than trusted from the current description.

**Proposed status**: `not_started` stands. No research has been done; nothing to reset.

**Proposed rename**: not required.

## Dependency Graph Analysis

### Current edges (re-verified 2026-08-09)

```
414.dependencies = [420, 438]
415.dependencies = [414, 420, 438]
417.dependencies = [414, 420, 438]
419.dependencies = [438]
420.dependencies = [415, 438]
427.dependencies = [414, 415, 417, 419, 420, 438]
```

(438 appears in every cluster task's dependency list because each was revised to depend on 438
while 438 is in flight; this is expected and not part of the cycle.)

### Cycle proof

Two overlapping cycles exist, both through the `420 ↔ 415` edge pair:

1. **Direct 2-cycle**: `420 → 415` (420 depends on 415) AND `415 → 420` (415 depends on 420).
   This alone is already a cycle — 420 cannot start until 415 finishes, and 415 cannot start
   until 420 finishes.
2. **3-cycle** (the one named in the task description): `420 → 415 → 414 → 420` (415 also
   depends on 414, and 414 depends on 420).

Both cycles share the `420 → 415` edge. Removing that single edge breaks both simultaneously
(verified below).

### Root cause (confirmed against artifacts, not assumed)

- 420's blocked-status `blockers` field and its `.orchestrator-handoff.json` (both read directly
  above) state that only 420's **phase 6** — not the whole task — genuinely waits on 415:
  "Phase 6 is blocked on task 415... Resolution: task 415's `bundleFlowFrame`... discharges the
  obligation via `TaskFrame.limit_nullity_of_shift`, already landed and verified by phases 1-5.
  Phase 6 is then a mechanical drop-in." Phases 1-5 (the bulk of 420's actual work) landed
  without ever needing 415.
- Meanwhile 415's dependency on 420 is real and task-level: 415's countermodel constructions
  need the frame axioms 420 owns (biconditional Compositionality, Seriality, Limit, Spherical)
  to exist in `TaskFrame` before 415 can even state what its canonical frames must discharge.
  414 similarly needs 420's frame-axiom work before its own semantics refactor can target the
  final `TaskFrame` signature (per 414's own description: "task 420, which this task now DEPENDS
  ON so the validity refactor lands once against the final TaskFrame structure").
- So the TRUE shape is a chain `420 → 414 → 415 → 417 → 427` (each downstream of the frame-axiom
  work), with one exception: a narrow, phase-level backward wait where 420's own phase 6 needs
  a construction (`bundleFlowFrame`) that only exists once 415 has done its own work. Task-level
  dependency edges cannot express "all of 420 except phase 6 comes before 415, but 420's phase 6
  comes after 415" — encoding the phase-level fact as a task-level edge in either direction
  either creates the cycle (420→415 direction, current state) or hides the real intra-task wait
  entirely (dropping the edge with no compensating record, which would be a silent information
  loss, not a fix).

### Confirmed generate-task-order.sh symptom

```
$ bash .claude/scripts/generate-task-order.sh --print
...
| 1 | 125,127,128,193,231,257,298,413,415,421,423,424,437,438 | -- | ... |
```

415 is confirmed present in wave 1 with `Blocked by: --`, despite `415.dependencies = [414, 420,
438]` (three declared, unmet dependencies — 414 is `researched` not `completed`-equivalent, 420
is `blocked`, 438 is `researching`). This exactly matches the symptom the task 438 description
predicts: Kahn's algorithm cannot place cycle members in a normal wave and the script's fallback
behavior surfaces 415 as if unblocked. The `### Paper Refactor` topic-grouped section of the same
output independently corroborates the cycle shape by DISPLAY (not by detecting it as a cycle):
it nests `420` as a child of `415` (i.e., under "blocked by 415"), then nests `414` as a child of
`420`, `417` as a child of `414`, and `427` as a child of `417` — a tree that only renders because
the grouped-view code walks forward edges without cycle detection either; the numeric wave table
and the topic tree are two different symptoms of the same underlying unresolved cycle.

### Proposed corrected edge set (acyclic, keeps 427 last)

**Remove exactly one edge: drop `415` from `420.dependencies`.** All other edges are correct as
declared and should be kept as-is:

```
414.dependencies = [420, 438]                    (unchanged)
415.dependencies = [414, 420, 438]                (unchanged)
417.dependencies = [414, 420, 438]                (unchanged)
419.dependencies = [438]                          (unchanged)
420.dependencies = [438]                          (415 REMOVED)
427.dependencies = [414, 415, 417, 419, 420, 438] (unchanged)
```

**Acyclicity check**: with `420 → 415` removed, the remaining graph is a strict DAG:
`420` has no cluster-internal prerequisite (only 438); `414` depends only on `420`; `415`
depends on `414` and `420`; `417` depends on `414` and `420`; `419` depends only on 438; `427`
depends on all five others. Topological order: `420, 414, {415, 417 in either order, or
parallel}, 419 (independent, parallel-eligible), 427` — 427 lands last as required, and no
task appears in its own dependency closure.

**Compensating record for the dropped edge** (so the real phase-level wait is not silently
lost, per the "hides the real intra-task wait entirely" concern above): 420's re-issued
description and `blockers` field must state explicitly that although the task-level graph no
longer shows 420 blocked by 415, 420's own phase 6 (the discharge of Limit/Seriality/Spherical
via `bundleFlowFrame`) is still phase-blocked on 415 landing, and that 420 should remain in
`blocked` status (not transitioned to e.g. `researched`/`implementing`) until either 415 lands
or a phase-6-only alternative construction is found. This preserves the true constraint as
descriptive/status information rather than as a graph edge, which is exactly what deliverable 8
already asks for independently (420 is the one task in the cluster explicitly called out for
a status/description-based treatment rather than a plain reset).

**Alternative considered and rejected**: dropping `420` from `415.dependencies` instead (keeping
`420 → 415`). Rejected because 415's dependency on 420 is the task-level-correct one — 415's
countermodel constructions substantively need 420's completed frame-axiom set (all four axioms,
not just the phase-6 field) before 415's own definitions can be stated, whereas 420's need for
415 is narrow, phase-scoped, and already independently documented as such in 420's own
`blockers` field. Removing the wrong-direction edge (415→420) would let 415 start with an
incomplete `TaskFrame` (missing whichever axioms remain in 420's later phases), which is a real
correctness problem, not just a graph-hygiene one.

**Post-Part-B verification step** (for whoever applies these edges): re-run
`bash .claude/scripts/generate-task-order.sh --print` after editing `specs/state.json` and
confirm (a) 415 no longer appears in wave 1 with `Blocked by: --`, (b) 415 appears in a wave
whose blockers list includes 414 and 420, (c) 420 appears in an earlier wave than 414/415/417,
and (d) 427 is in the final wave of the Paper Refactor group.

## Evidence

- `specs/state.json` — `.active_projects[]` entries for 414, 415, 417, 419, 420, 427, 438
  (description and dependencies fields), read directly via `jq`.
- `specs/414_refactor_semantics_to_maximal_history_validity/reports/01_maximal-history-validity-refactor.md`
  (full read) — Findings 1-10, prototype code, Adversarial Self-Verification table.
- `specs/414_refactor_semantics_to_maximal_history_validity/reports/02_group-c-reconciliation.md`
  (full read) — Findings 1-7, Divergence Audit, 88/16/8 counts.
- `specs/415_completeness_over_maximal_history_semantics/` description (via `jq`); report file
  existence confirmed via `ls`, not read in full (owned mostly by Teammate A's reconciliation
  table; description-level claims here are checked against 415's OWN description text, which is
  primary for the staleness verdict).
- `specs/417_semantic_fmp_finite_worldstate_over_z/` description (via `jq`).
- `specs/419_machine_check_co_reynolds_independence/` description (via `jq`); confirmed no
  report/plan/summary artifacts exist (`find` empty).
- `specs/420_align_task_frame_with_positive_cone_limit_nullity/` full description (via `jq`),
  full summary read
  (`summaries/01_taskframe-limit-nullity-alignment-summary.md`), and grep of
  `limit_nullity_of_succOrder`/`limit_nullity_of_shift`/`exists_uniform_radius_of_finite` against
  both the summary and `FormalSystem/Semantics/TaskFrame.lean` (lines 261, 289, 340) to confirm
  the theorems are stated against a bare relation.
- `specs/427_sync_typst_book_with_refactored_paper/` full description (via `jq`).
- `FormalSystem/ProofSystem/Axioms.lean:360-399` (full read) — the CO/Reynolds independence
  sketch prose, `co_derived`/`co_valid` cross-references, `prior_U_gap` docstring.
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`:
  - `:366-374` — `\aitem`/`\aref` macro definitions (label = second argument).
  - `:1217` — `\label{CO}`, base TM CO axiom, verbatim quoted above.
  - `:3706-3711` — `\label{def:TMplus-c}`, `\label{TMP-CO}`, verbatim quoted above, with the
    "coincides with `\ref{CO}` in TM" footnote.
  - `:905-927` — body prose for Compositionality/Seriality/Limit/Spherical, segment/fiber
    definitions, and the ℚ-carrier Spherical non-example footnote (`:926`, verbatim quoted
    above).
  - `:2412-2461` — `\label{def:frame}`, full formal four-axiom statement including the
    `%% CHANGE` provenance comments confirming Nullity's demotion to `lem:nullity` and
    Occurrence's demotion to `thm:occurrence`.
  - `:949-1013` — `H_F` redefined as the set of TOTAL world histories, box clause quantifying
    over `H_F`, Logical Consequence clause quantifying over "possible world τ ∈ H_F."
  - Confirmed via grep: zero occurrences of "Prior-U", "prior_U", "Reynolds", or "Stavi"
    anywhere in `possible_worlds.tex`.
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md:158` — confirmed as the
  source of the stale `possible_worlds.tex:3250` citation ("paper BX_c uses the single axiom CO
  (line 3250)"), inherited verbatim into 419's task description rather than independently
  introduced.
- `bash .claude/scripts/generate-task-order.sh --print` — full output captured; wave 1 listing
  and the topic-grouped "Paper Refactor" tree both quoted above.
- `git log --oneline --all | grep -i "task 420"` — confirms the 5 phase commits plus an
  orchestration-pause commit, corroborating the summary file's own commit list.

## Confidence Level

**High** for: the cluster inventory (direct `jq` re-query), the 420 helper-theorem
relation-genericity claim (direct source read), the 414 Omega-excision counts (direct read of a
report whose own methodology section documents kernel-level verification), the dependency-cycle
existence and its exact shape (direct `jq` read of all six dependency arrays plus a live
`generate-task-order.sh` run), the CO-axiom citation correction (direct macro-expansion read),
and the Spherical-risk flag for 419 (the paper's own non-example is unambiguous and structurally
close to the proposed sketch).

**Medium** for: the precise reusability percentage of 414's 85-line prototype for `thm:extension`
(the paper confirms Spherical is load-bearing for the extension theorem via the app:gluing-style
footnote at `:912-913`, but I did not independently verify the Lean-level proof obligation size
this creates — that is properly Teammate A's target-signature deliverable, and my claim here is
qualitative: "not zero reuse, not free reuse either").

**Medium** for whether Seriality/Spherical are automatic over `D = ℤ` for 417's finite-carrier
construction — flagged explicitly above as a claim to verify in 417's next research pass, not
asserted as settled.

**Lower/exploratory** for the proposed task renames' exact target strings (e.g.
`refactor_semantics_to_total_history_validity`) — these are reasonable, minimal-edit-distance
proposals consistent with the existing naming convention, but naming is inherently a judgment
call for whoever executes Part B, not a fact to verify.
