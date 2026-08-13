# Teammate C (Critic) Findings — Task 444

## Key Findings

1. **The document's Lean-fidelity discipline is genuinely strong, not a defect area.** Cross-checking
   every load-bearing claim in `typst/FormalFoundations.typ` against `FormalSystem/` and against
   `specs/443_.../reports/02_measured-status.md` / `typst/SYNC-MAP.md`, I could not find a single
   theorem stated flatly that rests on a live `sorry`. The repository's *sole* non-`Boneyard`
   structural `sorry` is `countermodel_discrete` at `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1084`,
   confirmed dead code (not on the call path `completeness_discrete` actually uses — that calls the
   sorry-free `countermodel_discrete_reynolds_v2` in `WeakCanonical/IntegerModel/ReynoldsBridge.lean`).
   The document states this correctly, at file:line precision, in `@sec:construction`'s "Status
   discipline" paragraph. All ~209 other `sorry` grep hits are either inside `FormalSystem/Boneyard/**`
   (archived, never cited as live) or are the word "sorry" appearing in prose/docstrings describing
   sorry-*freedom*. This is worth stating plainly to the team: the correctness floor is unusually solid;
   the risk in this task is almost entirely in *scope decomposition* and *rewrite mechanics*, not in
   smuggled-in false theorems. Confidence: high.

2. **One identification is asserted as settled where the document's own discipline elsewhere treats
   the analogous case as open — worth a targeted check before the rewrite locks it in.** In
   `@sec:key-theorems`'s Completeness theorem box, the Lean results `completeness_dense`,
   `completeness_discrete`, `completeness_dedekind_engine` (all sorry-free per
   `FormalSystem/Metalogic/BXCanonical/Completeness.lean` and `CompletenessDedekind.lean`) are
   attributed directly to $op("TM")^+_d$, $op("TM")^+_f$, $op("TM")^+_c$ — i.e., Lean's `FrameClass`-
   parameterized `BX` system is silently identified with the paper's $op("TM")^+$ (= S5 + BX + MF).
   But `@sec:construction`'s own "BX/TM discipline" paragraph explicitly flags the *general*
   BX-vs-paper-system correspondence as open: "Whether these BX-level theorems resolve, contradict,
   or are orthogonal to `cor:tm-completeness`'s $op("TM")_d$/$op("TM")_f$ status is explicitly *open*
   and not adjudicated here." That sentence is about $op("TM")$ (the BL-level system), not
   $op("TM")^+$, and since $op("TM")^+ := "S5" + "BX" + "MF"$ by the document's own definition, treating
   Lean's `BX` axioms as *definitionally* the paper's BX is more defensible than the TM case — but the
   document never states this justification, and the Lean `BX Temporal` layer's 22 constructors use
   different names (BX1–BX13′) than the paper's BX axiom keys (TN, TD, TB, TL, CN, TA, UE, UT, UI, UC,
   UF, UG, SU, NP, NF, NA, NB — 17 keys, not 22). Nobody has stated, anywhere I found, that these two
   axiomatizations are checked to prove the same theorems, only that they are named analogously. The
   rewrite should either (a) add one sentence making the "$op("TM")^+ := "S5"+"BX"+"MF"$, hence Lean's
   BX-parameterized results are $op("TM")^+$ results by definition" argument explicit, or (b) hedge this
   exactly as carefully as the TM case is already hedged. Confidence: medium (the gap is real; whether
   it needs fixing depends on whether the identification is in fact definitional, which I could not
   fully verify from grep alone — a Lean-side check of `FrameClass.Dense`'s axiom set against `def:BX`'s
   axiom list would settle it).

3. **The email's own priority ordering does not match the task's three-part decomposition, and the
   biggest mismatch is undercovered, not overcovered.** I read `other/dana.md` in full. Dana's email
   raises exactly three substantive questions, in this order and with this relative weight:
   - (a) **[most developed, ~40% of the email's content]** Whether identifying partial histories with
     restrictions of total histories (rather than defining partial histories independently and total
     histories in terms of them) is the right foundational choice, grounded in three results: the task
     topology is T1 (paper appendix `app:topology-t1`, `def:task-topology`), every partial history
     extends to a total one (`thm:extension`), and every world state occurs at some time in some total
     history (`cor:occurrence`).
   - (b) **[medium]** Whether the necessity-if-true of temporal structure (density, discreteness, etc.)
     is a real problem or is exactly analogous to ordinary frame-validity-closed-under-necessitation
     phenomena (the Kripke B/symmetry precedent) — Ben states he doesn't see an actual issue here, just
     an expository challenge.
   - (c) **[explicitly flagged by Ben as "the last and furthest from complete issue"]** What it would
     take to get a representation theorem going, including a live open question about whether metric
     tense operators (Prior-style) are needed.
   Mapped onto the task's three deliverables: (b) matches `@sec:contingency` (Pain Point One) well;
   (c) matches `@sec:representation` (Section 7); but **(a) — Dana's first and most detailed question —
   has no target section in the task's decomposition at all.** `thm:extension`/`cor:occurrence` are
   mentioned in passing in `@sec:system` (lines 133–134 of the current file) as background setup, but
   the T1-topology result Dana explicitly cites as his justification (`app:topology-t1`) is never
   mentioned anywhere in `typst/FormalFoundations.typ`, and the *definitional* question Dana is actually
   asking Scott about — partial-histories-as-restrictions vs. partial-histories-defined-independently —
   is not posed as a live question anywhere in the document. Decidability, meanwhile, is not mentioned
   in the email at all; it's an addition from the task description, reasonable as adjacent context but
   not something Dana asked about. **This is the single highest-value correction I can offer the
   primary approach**: either fold a short, precise treatment of the T1/topology/partial-history
   question into the rewrite (as a fourth thread, or worked into `@sec:system`), or explicitly scope it
   out with a one-line acknowledgment that it is out of scope for this document — but the current task
   framing risks producing a document that answers two of Dana's three questions and is silent on the
   one he spent the most words on. Confidence: high (directly evidenced by the email text and by
   grepping the paper for the cited labels).

4. **Scope completeness beyond the three-part payload**: soundness is covered (compressed, one line);
   the correspondence theorems (discreteness/density/completeness ↔ DF/DN/CO) are covered but are
   explicitly slated for demotion/replacement by the FIX tag at line 174 in favor of Henkin-construction
   detail — care is needed not to silently drop the correspondence-theorem *claims* themselves, since
   `@sec:contingency` depends on them (e.g., "a dense frame makes DN necessary" presupposes the DN↔Dense
   correspondence). Not covered anywhere: complexity (as distinct from decidability — the tableau
   procedure's complexity class is never discussed), interpolation, and finite axiomatizability beyond
   the one open CO-vs-Reynolds-triple remark. These are reasonable exclusions for a document this size,
   but if Dana is a logician of Scott's caliber, an absent one-line acknowledgment that these are
   out-of-scope-but-known-open-questions would read as more sophisticated than silence. Confidence:
   medium.

5. **A genuine tension in the task's brief that the primary approach should resolve explicitly, not
   paper over**: the task asks for "the best direction for developing a representation theorem," but
   the document's own `@sec:representation`, "The Way Forward," is structured as six open forks
   (a)–(f) with no single recommended path — and Ben's email calls this "the last and furthest from
   complete issue." Writing this section as if there is one best direction would overclaim relative to
   the actual state of the work and relative to what Ben himself believes; the rewrite should make an
   actual editorial recommendation (or explicitly justify presenting a small number of live candidates
   rather than one) rather than silently smoothing six open questions into false consensus. Confidence:
   high (directly evidenced by `@sec:representation`'s own text and by the email's "furthest from
   complete" framing).

## Recommended Approach

- Before finalizing, resolve Finding 2 with a one-sentence explicit justification (BX-as-Lean-artifact
  is $op("TM")^+$'s axiom system by construction) rather than leaving the identification implicit while
  the analogous TM case is explicitly flagged open elsewhere in the same document — an inconsistent
  hedging posture is worse than either committing or flagging both.
- Add a short thread (a few sentences to a subsection) addressing Dana's actual first question — the
  T1-topology / partial-history-as-restriction justification — even if `@sec:system` is the only place
  it fits; do not let the three-part task decomposition silently drop the question Dana spent the most
  words on. If the team decides this is genuinely out of scope for this document, say so once,
  explicitly, rather than by omission.
- In `@sec:representation`, replace the six-way open-fork listing with an actual recommendation (which
  fork, and why), while preserving the honest "not certain" status Ben himself assigns to this material
  in the email.
- Treat `scripts/typst-sync-check.sh` as a required post-rewrite gate (see Evidence below) — the
  document is inside its scanned tree, not exempt from it.

## Evidence/Examples

- Sole live sorry: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1049-1084` (dead code; comment at
  :1051-1057 names the live replacement `countermodel_discrete_reynolds_v2`). Cross-confirmed by
  `specs/443_.../reports/02_measured-status.md` Check C3: `sorry_total_excl_boneyard: 1`.
- Sorry-free flagship results confirmed via grep and `02_measured-status.md`'s `#print axioms` output:
  `completeness_dense`, `completeness_discrete`, `countermodel_dense`, `completeness_dedekind_engine`,
  `decide_sound` (`Decidability/Correctness.lean:61`), `fmp_completeness`
  (`Decidability/Correctness.lean:176`, delegates to `FMP.fmp_contrapositive`, no `sorry` in its
  dependency chain visible at the site).
- BX layer-count mismatch (Finding 2): document's own table (`typst/FormalFoundations.typ:142`) lists
  paper `def:BX` as 17 named axiom/rule keys (TN, TD, TB, TL, CN, TA, UE, UT, UI, UC, UF, UG, SU, NP,
  NF, NA, NB); `typst/SYNC-MAP.md`'s Ground-Truth Counts table lists Lean's "BX Temporal" layer as 22
  constructors under different names (BX1/BX1′ … BX13/BX13′). No file I found states these axiom sets
  are checked to be inter-derivable.
- Email/document mismatch (Finding 3): `other/dana.md` lines 5, 7, 9 vs.
  `possible_worlds.tex:949,1538,2649-2661` (`app:topology-t1`, `def:task-topology`) — none of these
  labels or the T1 result appear in `typst/FormalFoundations.typ`.
- Sync-check scope (rewrite risk): `typst/sync-check-whitelist.txt:94,113,128` all reference
  `typst/FormalFoundations.typ` by name as the source of whitelisted external-paper-anchor citations —
  confirming the file is inside `scripts/typst-sync-check.sh`'s scanned tree (`TYPST_DIR="${REPO_ROOT}/typst"`,
  globbed as `typst/**/*.typ`), not a document the sync gate skips. Any new backticked Lean identifier
  introduced during the rewrite must resolve under `FormalSystem/` (excluding `Boneyard/`) or be added
  to the whitelist with a reason.
- Cross-reference fragility risk: the FIX tag at `typst/FormalFoundations.typ:231` asks to drop
  `@sec:split-validity` (Pain Point Two) entirely, but `@sec:construction:317` ("the structural rhyme,
  this report's single most illuminating connection") and `@sec:contingency:227` ("@sec:split-validity
  develops exactly why the unrestricted class is *not* such a class") both cross-reference into that
  section by name. Deleting Section 5 wholesale without restating the (DD)/discrete-dense-dichotomy
  point compactly elsewhere will silently break two other sections' own arguments, not just a typst
  `#ref` link.
- Build baseline: `typst/FormalFoundations.pdf` exists alongside the `.typ` source, confirming the
  document compiles today; any post-rewrite compile failure is attributable to the rewrite, not a
  pre-existing issue.

## Confidence Level

Overall: **medium-high**. The Lean-correctness audit (Finding 1) is high confidence — thorough grep
plus cross-validation against two independent prior-task artifacts (`02_measured-status.md`,
`SYNC-MAP.md`) that were themselves produced by mechanical scripts, not hand assertion. The
email/task-scope mismatch (Finding 3) is high confidence — directly evidenced by both source texts.
The BX/TM^+ identification concern (Finding 2) is medium confidence — I could not fully verify from
grep alone whether the two axiom sets are provably inter-derivable or merely analogously named; this
would need a targeted Lean-side check (e.g. `lean_local_search` on `FrameClass.Dense`'s axiom
predicate) that I did not have scope to run as the research-only critic.
