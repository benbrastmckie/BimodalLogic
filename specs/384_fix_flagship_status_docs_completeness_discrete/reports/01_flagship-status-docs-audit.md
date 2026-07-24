# Research Report: Flagship Status Docs Audit (`completeness_discrete` and friends)

- **Task**: 384 `fix_flagship_status_docs_completeness_discrete`
- **Session**: sess_1784886673_059c3f_384
- **Date**: 2026-07-24
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active)
- **Reference grounding tier**: Tier 3 (implementation-backed — evidence source is
  `specs/reviews/review-2026-07-24-metalogic-cleanup.md` Dimension 3 + direct machine
  verification via `lean_verify`)
- **H5 divergence audit**: NOT activated (no `focus_prompt` in delegation context; the word
  "audit" appears only in the report filename, not as a mode trigger)

## Executive Summary

The library's front door misdocuments its headline result in **9 primary edit sites across 3
files** (the task description's "~6" undercounts by 3). Machine verification (`lean_verify`,
2026-07-24, this session) confirms:

- `completeness_discrete` — **sorryAx-FREE**, axioms `[propext, Classical.choice,
  Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
- `completeness_dense` — **sorryAx-FREE**, same axiom list
- `nf_nvar_exist_all_depths` — **sorryAx-FREE**, axioms `[propext, Classical.choice,
  Quot.sound]` only (the ":361/:364 open sorry arms" claims are definitively retired)
- `completeness` (Base) — still carries `sorryAx`, and its **sole** sorry source is
  `WeakCanonical.countermodel_discrete` (Transfer.lean, deprecated dead-BX-pipeline theorem
  with a literal `sorry`); the dense branch (`Chronicle.countermodel_dense`) and mixed branch
  (`Chronicle.dd_countermodel_chronicle_mixed_sorry` — sorryAx-free despite its name) are
  both clean.

All fixes are comment/docstring-only. No `.lean` proof code changes. Anchor every corrected
reference by DECLARATION NAME (line anchors in this zone have rotted: the cited
"`KampPrior.lean:361/:364`" positions now hold different content — the `| 1 =>` outer arm no
longer exists; the recursion is `| 0` / `| k + 1` starting at the declaration
`nf_nvar_exist_all_depths`).

## Machine-Verified Axiom Baseline (ground truth for all corrected wording)

| Declaration (fully qualified) | `lean_verify` axioms | sorryAx? |
|---|---|---|
| `Bimodal.Metalogic.BXCanonical.completeness_discrete` | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound | **NO** |
| `Bimodal.Metalogic.BXCanonical.completeness_dense` | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound | **NO** |
| `Bimodal.Metalogic.BXCanonical.completeness` | propext, **sorryAx**, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound | **YES** |
| `Bimodal.Metalogic.BXCanonical.Chronicle.countermodel_dense` | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound | NO |
| `Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_mixed_sorry` | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound | NO (name is misleading) |
| `Bimodal.Metalogic.WeakCanonical.Kamp.nf_nvar_exist_all_depths` | propext, Classical.choice, Quot.sound | NO |
| `Bimodal.Metalogic.soundness` | propext, Classical.choice, Quot.sound | NO (spot check of unchanged table rows) |

`Lean.ofReduceBool` / `Lean.trustCompiler` come from `native_decide` in the Syntax layer
(per the current, correct in-file Axiom Audit block at the bottom of
`BXCanonical/Completeness.lean` — that block matches `lean_verify` exactly and must NOT be
touched).

Corroborating source scan: the only literal `sorry` token in the three target files is
`Transfer.lean` inside `countermodel_discrete` (the deprecated theorem, its own docstring
already says "DEPRECATED (sorry)"). `KampPrior.lean` contains zero literal `sorry` tokens.

## Site-by-Site Fix Specification

Conventions for ALL sites: (a) anchor by declaration name or section heading, never `:NNN`;
(b) scrub any `(task N)` references inside edited regions (repo rule
`no-task-references-in-deliverables.md`; the task description reiterates it); (c) do not
introduce new line-number anchors.

### File A — `Theories/Bimodal/Metalogic/Metalogic.lean` (live aggregator)

**A1. "Publication-Ready Results" table** (section heading `## Publication-Ready Results`,
currently lines 25-33). Three rows change:

| Row | Current (stale) | Corrected |
|---|---|---|
| `completeness` | `SORRY (chronicle construction)` | `SORRY (sole source: the deprecated Base-frame discrete branch WeakCanonical.countermodel_discrete; the dense and mixed branches are sorryAx-free — see completeness_discrete for the sorry-free discrete result)` |
| `completeness_dense` | `SORRY (chronicle + canonical model open question)` | `SORRY-FREE (sorryAx-free; axioms: propext, Classical.choice, Quot.sound + Lean.ofReduceBool/Lean.trustCompiler from native_decide)` |
| `completeness_discrete` | `SORRY (nf_nvar_exist_all_depths, KampPrior.lean:361/364 — Kamp/Prior arity converter, not chronicle)` | `SORRY-FREE (sorryAx-free; axioms: propext, Classical.choice, Quot.sound + Lean.ofReduceBool/Lean.trustCompiler from native_decide)` |

Rows `soundness`/`soundness_dense`/`soundness_discrete`/`decide` stay as-is (`soundness`
spot-verified clean).

**A2. "Axiom Dependencies" section** (heading `## Axiom Dependencies`, currently lines
52-55). Current text: "Standard Lean axioms only on publication path: propext,
Classical.choice, Quot.sound". Stale — the flagship completeness theorems also depend on
`Lean.ofReduceBool` and `Lean.trustCompiler`. Corrected text (suggested):

> Soundness and decidability use standard Lean axioms only: `propext`, `Classical.choice`,
> `Quot.sound`. The completeness theorems (`completeness_dense`, `completeness_discrete`)
> additionally use `Lean.ofReduceBool` and `Lean.trustCompiler` (from `native_decide` in the
> Syntax layer; not sorry-related). No `sorryAx` on any of these paths. The general
> Base-frame `completeness` still carries `sorryAx` via the deprecated
> `WeakCanonical.countermodel_discrete` branch.

**A3. Task-number reference scrubs in edited file**: "(task 93)" in the Irreflexive Temporal
Semantics paragraph and "(task 142)" in the Completeness Architecture list item 3 — delete
the parentheticals (the surrounding factual text stands on its own; `mcs_mixed_case_absurd`
is the durable anchor).

*Coordinate-with-385 note*: the `## Module Structure` tree lists `DenseSoundness.lean` /
`DiscreteSoundness.lean`, which are outside the import closure (the live `soundness_dense`/
`soundness_discrete` are in `Soundness.lean`). Task 385's triage owns those files' fate — do
not restructure the tree in this task; at most leave it untouched.

### File B — `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

**B1. Module docstring `## Status` section** (in the header block under `# BX Completeness`,
currently lines 32-40). Stale claims: "Remaining leaf sorries are in the Chronicle/ modules
(FMCS G/H coherence, chronicle construction C5/C5' satisfaction, counterexample
enumeration)." Machine-verified reality: `Chronicle.countermodel_dense` is sorryAx-free, so
the Chronicle sorries are NOT on any axiom path of this file's theorems. Corrected text
(suggested):

> `completeness_dense` and `completeness_discrete` are sorryAx-free (see the Axiom Audit
> section at the end of this file; axioms: propext, Classical.choice, Quot.sound, plus
> Lean.ofReduceBool/Lean.trustCompiler from native_decide). The general Base-frame
> `completeness` still carries sorryAx, with a single source: the deprecated
> `WeakCanonical.countermodel_discrete` (dead BX pipeline, WeakCanonical/Transfer.lean) used
> in its discrete branch. Its dense branch (`Chronicle.countermodel_dense`) and mixed branch
> (`Chronicle.dd_countermodel_chronicle_mixed_sorry`) are sorryAx-free.

**B2. `completeness` docstring `**Status**` paragraph — DEFERRED to the re-point task.**
The docstring/code mismatch (docstring says the mixed case uses `mcs_mixed_case_absurd`;
the code's mixed branch actually calls `dd_countermodel_chronicle_mixed_sorry`) and the
"Remaining leaf sorries are in the Chronicle/ modules / RootScopedChain" narrative are
explicitly assigned by the review (§4.2) and by task 386's description to the Base-completeness
re-point task, which will change this very branch. Editing it here invites churn. Only if the
implementer prefers a defensive minimal fix: replace the last two sentences with "The
remaining sorryAx source is the deprecated `WeakCanonical.countermodel_discrete` discrete
branch." — and leave the mixed-case sentence for the re-point task.

**B3. `completeness_dense` docstring `**Sorry Status**` paragraph** (anchor: docstring
immediately above `theorem completeness_dense`, currently lines 228-231). Current: "Inherits
sorries from `countermodel_dense` (dense case). ..." — FALSE (theorem verified sorryAx-free).
Corrected text (suggested):

> **Sorry Status**: sorryAx-free (machine-verified; axioms: propext, Classical.choice,
> Quot.sound, plus Lean.ofReduceBool/Lean.trustCompiler from native_decide). The non-dense
> branch closes via the `dense_indicator` axiom: `¬U(⊤,⊥)` is a Dense theorem, so
> `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.

Also scrub "(task 198)" from this docstring's Proof Strategy bullet.

**B4. `completeness_discrete` docstring** (anchor: docstring immediately above
`theorem completeness_discrete`, currently lines 256-274). Three defects:
1. Proof Strategy names `countermodel_discrete_reynolds`; the code calls
   `countermodel_discrete_reynolds_v2` — update the name.
2. "The mixed-case sorry is eliminated via `dd_countermodel_chronicle_mixed_sorry`" — wrong
   declaration: this theorem's mixed branch uses `mcs_mixed_case_absurd` (see the final
   `rcases` branch of the proof). Correct to: "Mixed case: eliminated by
   `mcs_mixed_case_absurd`."
3. `**Sorry Status**` paragraph — replace with a sorryAx-free statement mirroring B3:

> **Sorry Status**: sorryAx-free (machine-verified; axioms: propext, Classical.choice,
> Quot.sound, plus Lean.ofReduceBool/Lean.trustCompiler from native_decide — see the Axiom
> Audit section below). The dense-case branch closes by deriving `U(⊤,⊥)` as a Discrete
> theorem; the mixed case is eliminated by `mcs_mixed_case_absurd`.

Also scrub "(task 198)" here. Do NOT touch the `/-! ## Axiom Audit ... -/` block at the end
of the file — it is current and correct (verified this session; it matches `lean_verify`
exactly).

### File C — `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**C1. `kampPrior_site_rungK_gate_match` docstring, "Obligation discipline" paragraph**
(anchor: the docstring of declaration `kampPrior_site_rungK_gate_match`, currently lines
944-948). Stale claim: "discharging `hreal`/`hexcl` requires the un-landed realization
recursion (the `:361`/`:364` sorry arms), the fenced-out escalation boundary (task 357 Phase
7 / task-309 Phase-14 successor)". Reality: the arms are retired (ζ wire `kampArm_zeta`,
`ZetaUniformExtract.lean`); `nf_nvar_exist_all_depths` is sorry-free. Corrected text
(suggested):

> **Obligation discipline (carry, do NOT discharge).** `hreal`/`hexcl`/`hslice*`/
> `hexclSlice*` are threaded outward; the realization recursion that discharges
> `hreal`/`hexcl` is the (now fully landed, sorry-free) `nf_nvar_exist_all_depths`; the
> slice obligations are discharged at m = 0 by the supply theorems. No `sorry`, no vacuous
> def is introduced here.

(Scrubs the two task references in the same edit.)

**C2. Phase-16 shim module docstring, "Axiom cleanliness" and "Line-citation stability"
items** (anchor: the `/-! ## ... provider instantiation shim: ExistProviders from the
recursion ... -/` module comment above declaration `kampPrior_existProviders_of_ih`,
currently lines 1240-1262). Two stale claims:
1. "any top-level reference to `nf_nvar_exist_all_depths` inherits `sorryAx` from the open
   `:361`/`:364` arms" — FALSE now (`lean_verify`: `[propext, Classical.choice,
   Quot.sound]`).
2. "editing the `| 1 =>` arm body now would shift the `:361`/`:364` citations" — moot (arms
   rewritten; those line anchors no longer point at arms).

Fix: convert both items to past-tense historical rationale with a present-state correction,
e.g.:

> 1. **Axiom cleanliness (historical rationale)**: at the time of this phase, a top-level
>    reference to `nf_nvar_exist_all_depths` inherited `sorryAx` from its then-open
>    recursion arms. Those arms have since been retired (ζ wire `kampArm_zeta`,
>    `ZetaUniformExtract.lean`); `nf_nvar_exist_all_depths` is now sorry-free with axioms
>    exactly `[propext, Classical.choice, Quot.sound]`. The of-`ih` shim form is retained
>    as landed.
> 2. **Anchor stability (historical rationale)**: the phase sequencing avoided shifting
>    line-keyed citations; anchors in this file are now by declaration name.

**C3 (secondary). Historical VERDICT RECORD and HOIST NOTE `:361` anchors** (anchors: the
`/-! ## ... Phase 15 — site/coverage probe ... VERDICT ... -/` module comment; the
`/-! **HOIST NOTE ...** -/` comment above `kampPrior_site_perQnf_seam`; and the mirrored
hoist-note text near the end of the file). These are explicitly dated verdict records
(historical narrative, weaker urgency than C1/C2 because they don't assert a *currently*
open sorry) — but their "`KampPrior.lean:361`, the `| 1 =>` arm" citations have rotted: the
current recursion has outer arms `| 0` / `| k + 1` (no `| 1 =>` outer arm), and content at
those line numbers has moved. Light-touch fix: replace each `:361`/`:364` line anchor with
"the `nf_nvar_exist_all_depths` recursion arms (since retired — see `kampArm_zeta`)"; do not
rewrite the records' narrative.

**C4 (secondary). File header `## Status` section** (module docstring under
`# Kamp's Theorem for Prior Structures`). Currently lists per-depth statuses ending with
"k>=2 (depth >= 2): uses Prop 4.3 structural induction (v30 plan)" — not false, but the file
front door should state the headline: all arms landed, declaration sorry-free. Suggested
addition/replacement for the k>=2 bullet:

> - k>=2 (depth >= 2): sorry-free via the ζ wire (`kampArm_zeta`, `ZetaUniformExtract.lean`
>   — Rabinovich Def 4.1 / Prop 4.3 / Thm 4.4). `nf_nvar_exist_all_depths` and the full
>   chain up to `kamp_prior_expressive_completeness` are sorry-free
>   (`[propext, Classical.choice, Quot.sound]`).

### File D (secondary) — `Theories/Bimodal/Metalogic/README.md`

**D1. "Sorry Status" / "Key Point"** (section heading `## Sorry Status`): "The main
completeness, soundness, and decidability theorems are sorry-free" — inaccurate for the
general Base `completeness`. Qualify:

> **Key Point**: The flagship theorems — `soundness`, `soundness_dense`,
> `soundness_discrete`, `completeness_dense`, `completeness_discrete`, `decide` — are
> sorryAx-free. The general Base-frame `completeness` still carries one sorry, isolated in
> the deprecated `WeakCanonical.countermodel_discrete` branch.

### Out of scope (explicit)

- **Dead orphan `Theories/Bimodal/Metalogic.lean`** (duplicate aggregator with the same
  stale table): owned by task 385 (DELETE) — do not edit it here; editing a file scheduled
  for deletion is wasted churn.
- **Base-`completeness` docstring/code mixed-branch mismatch and branch re-pointing**: owned
  by task 386 (see B2).
- **Mass `.lean:NNN` → decl-name conversion** across the ~568 remaining line anchors: rides
  with the task-380 sweep per the review; this task fixes only the actively-false sites plus
  the specific rotted anchors in edited regions.

## Site Count Reconciliation

Task description said "~6". Verified: **9 primary sites** (A1, A2, A3, B1, B3, B4, C1, C2,
C4) + **2 secondary** (C3, D1) + 1 deferred (B2 → task 386). All comment/docstring-only;
estimated diff ~60-90 changed lines across 3 `.lean` files + 1 README.

## Literature Relevance Statement

Literature mode was active; the per-repo briefing resolved 12 documents (Kamp 1968,
Rabinovich 2014, Gabbay-Hodkinson-Reynolds, Burgess, Thomas — coverage not sparse). **This
task is documentation hygiene; no literature chunk was needed or read.** The only touch
point: corrected KampPrior wording must preserve the existing Rabinovich citations (Def 4.1
/ Prop 4.3 / Thm 4.4, PDF pp.5-6) verbatim — the fix specifications above do so.

## Tactic Survey Results

Not applicable — no proof code is written or modified in this task; no tactics surveyed.

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `completeness_discrete` is sorryAx-free with axioms [propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound] | This session, not just the task description | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` returned exactly that list, no sorryAx | High |
| `completeness_dense` is sorryAx-free (same axiom list) | This session | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_dense` | High |
| `completeness` (Base) still carries sorryAx | This session | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness` — sorryAx present | High |
| The SOLE sorryAx source of `completeness` is `WeakCanonical.countermodel_discrete` | Its three branch suppliers verified: `Chronicle.countermodel_dense` clean, `Chronicle.dd_countermodel_chronicle_mixed_sorry` clean (both `lean_verify`); `countermodel_discrete` contains the only literal `sorry` in Transfer.lean (grep) and its docstring says "DEPRECATED (sorry)". Shared MCS infrastructure is clean because the sorryAx-free `completeness_dense`/`completeness_discrete` use it | `lean_verify` x2 + grep source scan + inference over the proof's three `rcases` branches (read in full) | High |
| `nf_nvar_exist_all_depths` is sorry-free, axioms exactly [propext, Classical.choice, Quot.sound] | This session | `lean_verify` on `Bimodal.Metalogic.WeakCanonical.Kamp.nf_nvar_exist_all_depths` (namespace confirmed by reading the file's `namespace` line) | High |
| KampPrior.lean contains no literal `sorry` token | grep `^\s*sorry\b|:= sorry|by sorry|exact sorry` over the file — zero hits (all "sorry" matches are inside comments/docstrings) | grep source scan | High |
| Stale site (2) exists: `kampPrior_site_rungK_gate_match` docstring asserts ":361/:364 sorry arms" un-landed | Read at current lines 944-948; text quoted in Findings | Read (bounded) | High |
| Stale site (3) exists: Phase-16 shim module docstring asserts `nf_nvar_exist_all_depths` "inherits sorryAx from the open :361/:364 arms" | Read at current lines 1252-1253; contradicted by the `lean_verify` row above | Read + `lean_verify` cross-check | High |
| Stale site (1) exists: live aggregator tables `completeness_discrete` as SORRY citing KampPrior.lean:361/364 | Read `Metalogic/Metalogic.lean` in full; row at current line 32 quoted in A1 | Read | High |
| `completeness_dense` docstring "Inherits sorries from countermodel_dense" is at current line 228-231 (task said :228) | Read `BXCanonical/Completeness.lean` in full; the `**Sorry Status**` paragraph starts at line 228 | Read | High |
| The cited ":361/:364" line anchors have rotted: no `| 1 =>` outer arm exists there now | Read current lines 358-366: arms are `| 0, n, _hn, sub_nf =>` (line 359) and `| k + 1, n, hn, sub_nf =>` (line 363-364) | Read (bounded) | High |
| `completeness_discrete` docstring misnames its own branches (`countermodel_discrete_reynolds` vs code's `_v2`; `dd_countermodel_chronicle_mixed_sorry` vs code's `mcs_mixed_case_absurd`) | Docstring lines 262/273 vs proof body lines 335/339, both read this session | Read + grep for the declaration definitions | High |
| `dd_countermodel_chronicle_mixed_sorry` is itself sorryAx-free (so B1's corrected wording may say the mixed branch is clean) | This session; counter-intuitive given the name | `lean_verify` on `Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_mixed_sorry` | High |
| Unchanged table rows (soundness family, decide) are safe to leave as SORRY-FREE | `soundness` spot-verified clean [propext, Classical.choice, Quot.sound]; `soundness_dense`/`soundness_discrete`/`decide` NOT individually lean_verify'd this session | `lean_verify` (soundness only) + review's Dimension-1 findings | Medium (spot check; rows are unchanged by this task, so risk is pre-existing, not introduced) |
| Orphan `Theories/Bimodal/Metalogic.lean` exists but is task 385's to delete | `ls` confirms existence; task 385 description in state.json explicitly bucket-1 DELETEs it | Bash ls + state.json read | High |
| The in-file Axiom Audit block in Completeness.lean is current and must not be edited | Its stated axiom list for completeness_discrete matches this session's `lean_verify` output verbatim | Read + `lean_verify` cross-check | High |

### Contradiction Log

- `dd_countermodel_chronicle_mixed_sorry` (name implies sorry) vs `lean_verify` (no
  sorryAx). Resolution per precedence: machine verification outranks naming convention —
  the declaration is clean; only its name is misleading. Downstream effect: B1's corrected
  wording states the mixed branch is sorryAx-free; a possible rename is task 386's or a
  later sweep's business, not this task's.
- Review §4.2 row for "Completeness.lean:129 vs :169" assigns the fix to the §3.5 re-point
  (task 386), while this task's description says "correct ALL stale status
  tables/docstrings". Resolution: task 386's description explicitly claims that site
  ("Also fix the docstring/code mismatch at Completeness.lean :129 vs :169") — more specific
  ownership wins; deferred here as B2 with a defensive-minimal option documented.

### Recommendations modified after verification

- Initial draft scoped `completeness` row A1 as "keep as-is"; verification that both the
  dense and mixed branch suppliers are clean upgraded it to a precise "sole source"
  parenthetical (a strictly stronger, machine-backed statement).
- Initial site list (~6, from the task description) expanded to 9+2 after full-file reads
  (added A2 Axiom Dependencies, B4 branch-name mismatches, C4 header, D1 README).

## Contract Compliance Notes

- **H2**: first verification action (grep + file reads establishing the stale sites) landed
  within the first 3 tool calls; first `lean_verify`-confirmed result by call ~7 of ~15.
  No rate-limited search tools were needed (all targets are local declarations).
- **H3**: Tier 3 (implementation-backed). Source-coverage minimum met: every load-bearing
  claim has >= 2 sources (review document + independent machine verification, or file read +
  lean_verify cross-check).
- **Zero-debt**: no sorry-deferral or axiom-introduction recommendation appears anywhere in
  the fix spec (the task is doc-only).

## Suggested Next Step

`/plan 384` — the plan can be a single phase (comment-only edits, one `lake build
Bimodal.Metalogic` + `lake build` verification at the end; the edits are docstrings, so the
build should be a no-op semantically, but rebuilding guards against docstring syntax errors
in `/-! ... -/` blocks). Implementer needs no re-research: every site above carries its
anchor, current line locus, defect, and corrected wording.
