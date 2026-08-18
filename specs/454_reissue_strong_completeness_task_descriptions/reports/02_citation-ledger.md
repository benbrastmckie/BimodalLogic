# Verified Citation Ledger

Task 454, Phase 1. Every file:line/symbol citation extracted from the six original descriptions
(`scratch/{N}-desc.orig.txt`), verified against the live tree by symbol grep (declaration
keyword), 2026-08-18. Line numbers in "cited" are what the original description text said; "live"
is what a symbol grep confirms today. Status: `ACCURATE` (line still correct), `DRIFTED` (symbol
exists, line moved), `DELETED` (symbol/text no longer exists), `NO-LINE` (no line was cited).

Scope-hypothesis check: research named 11 drifted anchors. This sweep found **34 total citations**
across the six descriptions (169: 8, 362: 18, 421: 5, 422: 7 [including the shared Transfer.lean
sorry], 423: 5, 424: 5 counted distinctly, some overlap in shared anchors), of which **14 are
DRIFTED**, **19 ACCURATE**, **1 stale-count** (362's LaTeX occurrence count, not a line drift), and
**0 DELETED** (no cited symbol itself no longer exists in Lean/tex source — see the one
stale-count row for the sole exception, which is a count/occurrence issue, not a missing symbol).
This exceeds the plan's Phase-1 scope hypothesis of "~45 references... materially higher than 11";
actual total citation surface is smaller than the ~45 estimate but the drift rate (14/34, ~41%) is
materially higher than the original 11-row table implied.

## Task 423

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `Validity.lean:79` | `valid` | `FormalSystem/Semantics/Validity.lean:94` | DRIFTED |
| 2 | `Validity.lean:169` | `ValidDense` | `FormalSystem/Semantics/Validity.lean:206` | DRIFTED |
| 3 | `Validity.lean:187` | `ValidDiscrete` | `FormalSystem/Semantics/Validity.lean:222` | DRIFTED |
| 4 | `Validity.lean:276` | `ValidDedekindDense` | `FormalSystem/Semantics/Validity.lean:310` | DRIFTED |
| 5 | `Validity.lean:77` | "uses Type not Type*" note | `FormalSystem/Semantics/Validity.lean:92` | DRIFTED |

Replacement (symbol-primary): `` `valid` (`FormalSystem/Semantics/Validity.lean`; currently near
:94, hint only) ``, `` `ValidDense` (same file; currently near :206) ``, `` `ValidDiscrete` (same
file; currently near :222) ``, `` `ValidDedekindDense` (same file; currently near :310) ``, and the
"deliberate `Type` not `Type*`" doc-comment (same file; currently near :92).

## Task 421

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `Transfer.lean:1239-1241` (route guidance comment, deliverable a) | comment block opening "(i) a Base-MCS ... (ii) a Henkin-style ..." | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1081-1083` | DRIFTED |
| 2 | `Transfer.lean:1239-1241` (same comment, acceptance clause) | same | same, `:1081-1083` | DRIFTED |
| 3 | `Transfer.lean:1242` (sorry, "do not touch") | `sorry` token inside `WeakCanonical.countermodel_discrete` | declaration `:1068`, `sorry` token `:1084` | DRIFTED |
| 4 | `CompletenessDedekind.lean:61-100` (CarrierProbe) | `section CarrierProbe ... end CarrierProbe` | `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:69-105` | DRIFTED — claim itself confirmed ACCURATE, anchor-only change |
| 5 | `Mathlib/Algebra/Order/Monoid/Prod.lean:52-59` | `Lex.isOrderedMonoid` (`@[to_additive]`) | same file, `:52-53` (attribute+instance head; body continues) | ACCURATE (symbol resolves at cited location) |

CarrierProbe note: confirmed `ACCURATE — DO NOT CHANGE THE CLAIM` per plan instruction; only the
anchor form changes (line range to symbol-primary block reference).

## Task 422

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `ChronicleToCountermodelBasic.lean:435` | `box_dense_gives_density` | `:430` | DRIFTED |
| 2 | `ChronicleToCountermodelBasic.lean:629` | `cantor_bfmcs_dense_restricted_tc` | `:624` | DRIFTED |
| 3 | `ChronicleToCountermodelBasic.lean:680` | `cantor_bfmcs_dense_restricted_buc` | `:675` | DRIFTED |
| 4 | `ChronicleToCountermodelBasic.lean:755` | `cantor_bfmcs_dense_restricted_fuc` | `:750` | DRIFTED |
| 5 | (no line) | `cantorIsoDense` | `:231` | NO-LINE (now has a location; add as hint) |
| 6 | `Validity.lean:79` | `valid` | `:94` | DRIFTED (same row as 423 #1) |
| 7 | `Transfer.lean:1242` (acceptance clause, "does NOT close") | `WeakCanonical.countermodel_discrete`'s `sorry` | declaration `:1068`, sorry `:1084` | DRIFTED (same anchor as 421 #3) |

## Task 169

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `Completeness.lean:196` | `theorem completeness` (Base terminus, `valid φ → Derivable FrameClass.Base [] φ`) | `FormalSystem/Metalogic/BXCanonical/Completeness.lean:191` | DRIFTED — **disambiguation required**: a second `theorem completeness` exists at `:26` (a different, superseded/duplicate declaration in the same file); the terminus is the one at `:191` whose signature is `valid φ → Derivable FrameClass.Base [] φ`. |
| 2 | `Transfer.lean:1242` (occurrence 1, CORRECTED SCOPE paragraph) | `WeakCanonical.countermodel_discrete`'s `sorry` | decl `:1068`, sorry `:1084` | DRIFTED |
| 3 | `Transfer.lean:1242` (occurrence 2, ROUTE (ii) paragraph is actually route (iii)/(ii) prose — see below) | same | same | DRIFTED |
| 4 | `Completeness.lean:133` (`countermodel_dense_enriched` decl) | `theorem countermodel_dense_enriched` | `:135` | DRIFTED |
| 5 | `Completeness.lean:221` (called at) | call site inside `theorem completeness` (`:191`) | `:216` | DRIFTED |
| 6 | `Completeness.lean:231` (`mcs_mixed_case_absurd` called from) | call site inside `theorem completeness` | `:226-227` | DRIFTED |
| 7 | `ChronicleToCountermodelBasic.lean:435` (route iii, `box_dense_gives_density`) | same symbol as 422 #1 | `:430` | DRIFTED |
| 8 | `Validity.lean:79` (route ii, `valid`) | same symbol as 423 #1 | `:94` | DRIFTED |

`Chronicle.mcs_mixed_case_absurd` itself (no line cited in original — described only as "called
from Completeness.lean:231") lives in `MCSMixedCase.lean`; no change needed to the file-only
reference, only to the call-site line hint.

## Task 362

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `Completeness.lean:196` | `completeness` | `:191` | DRIFTED (same as 169 #1) |
| 2 | `Completeness.lean:255` | `completeness_dense` | `:250` | DRIFTED |
| 3 | `Completeness.lean:296` | `completeness_discrete` | `:291` | DRIFTED |
| 4 | `Validity.lean:79` | `valid` | `:94` | DRIFTED |
| 5 | `Validity.lean:169` | `ValidDense` | `:206` | DRIFTED |
| 6 | `Validity.lean:187` | `ValidDiscrete` | `:222` | DRIFTED |
| 7 | `Derivable.lean:69` | `Derivable` | `FormalSystem/ProofSystem/Derivable.lean:69` | ACCURATE |
| 8 | `DeductionTheorem.lean:467` | `Derivable.deduction` (full name `FormalSystem.ProofSystem.Derivable.deduction`) | `:467` | ACCURATE |
| 9 | `DeductionTheorem.lean:325` | `deductionTheorem` | `:325` | ACCURATE |
| 10 | `DeductionTheorem.lean:447` | `deductionConverse` | `:447` | ACCURATE |
| 11 | `MaximalConsistent.lean:96` | `SetConsistent` | `:96` | ACCURATE |
| 12 | `MaximalConsistent.lean:103` | `SetMaximalConsistent` | `:103` | ACCURATE |
| 13 | `MaximalConsistent.lean:303` | `set_lindenbaum` | `:303` | ACCURATE |
| 14 | `Validity.lean:103` | `SemanticConsequence` | `:125` | DRIFTED |
| 15 | `Validity.lean:114` (notation `Γ ⊨ φ`) | `notation:50 Γ:50 " ⊨ " φ:50 => SemanticConsequence Γ φ` | `:135` | DRIFTED |
| 16 | `FormalSystem/Metalogic.lean` (root tracking table file, disambiguation note) | file exists, no `Metalogic/Metalogic.lean` duplicate | confirmed as described | ACCURATE (no change needed) |
| 17 | `latex/subfiles/04-Metalogic.tex:266` (`main_strong_completeness` heading) | `\subsubsection{Strong Completeness and Compactness}` | `:267` | DRIFTED |
| 18 | `latex/subfiles/04-Metalogic.tex:211, :490` ("identifier also at") | same phrase, second occurrence | **only one other live occurrence, at `:543`** (`(see \emph{Strong Completeness and Compactness})`); the phrase is absent from both cited lines today | STALE-COUNT — not a broken clause (the section itself is fully present and editable as leg D requires), but the original "also at :211, :490" locator is no longer accurate. Re-anchored to: heading `:267`, backreference `:543` (2 occurrences, not 3). Also note: `main_strong_completeness` was never a Lean/LaTeX identifier — it is the *retired task title* (see description line 1); the parenthetical gloss is dropped in the re-issued text to avoid implying it is a symbol. |

`StrongCompleteness.lean:274,308` (`consequence_completeness_dedekind_of_engine`,
`completeness_dedekind_of_engine`) — confirmed ACCURATE at both lines; no change.

## Task 424

| # | Cited | Symbol | Live location | Status |
|---|-------|--------|----------------|--------|
| 1 | `Truth.lean:128` (`Formula.box φ => ∀ σ ∈ Omega, ...`) | box clause of `TruthAt` | now `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` at `:164`; the `Omega`-taking form quoted in the old text **no longer exists** | DELETED (the quoted clause text itself, not merely its line, is gone — this is the exposure audit's own predicted outcome, now realized) |
| 2 | `Truth.lean:128-137` | `def TruthAt` (whole definition block) | `:159-167` | DRIFTED |
| 3 | `Validity.lean:77-139` (`valid`, `SemanticConsequence`, `satisfiable`, bundled range) | `valid` `:94`, `SemanticConsequence` `:125`, `satisfiable` `:157` | re-anchor each by symbol individually; the single bundled range is stale and imprecise | DRIFTED (re-anchor as three separate symbol citations, not one range) |
| 4 | `Truth.lean:446` (`time_shift_preserves_truth`) | `theorem time_shift_preserves_truth (M) (σ) (x y : D) (φ)` | `:457` | DRIFTED — signature confirmed to have **no `h_sc`/`ShiftClosed` hypothesis** |
| 5 | `Truth.lean:333` (`ShiftClosed`) | — | **zero occurrences of `ShiftClosed` in `Truth.lean`** (confirmed via grep) | DELETED — per plan, delete this citation outright and record `ShiftClosed` as retired, not renamed |
| 6 | (implicit, not cited by line) | `WorldHistory.isTotal_timeShift` | `FormalSystem/Semantics/WorldHistory.lean:486`, signature `{σ : WorldHistory F} (h : σ.IsTotal) (Δ : D)` — no side condition beyond totality | ACCURATE (existence + no-side-condition claim both confirmed) |

Design-doc path: `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md`
confirmed to exist; the un-archived path confirmed **not** to exist. No change needed — the
current description already uses the corrected archive path.

Task 414/420 landed-and-archived claim: confirmed — `specs/archive/` contains
`414_refactor_semantics_to_total_history_validity/` and
`420_align_task_frame_with_positive_cone_axioms/`; neither remains in `active_projects`.

Dependency-edge count: TODO.md and one review artifact independently repeat "41 declared
dependency edges" — that string does **not** appear in any of the six task descriptions
themselves today, so no in-description occurrence needs removal, but Phase 7/8 must not
introduce it. Live measurement (re-confirmed): 102 raw dependency references, 44 unique edges
(`jq '[.active_projects[].dependencies[]?] | length'` = 102; `... | unique | length` = 44).

## Appendix: verification commands used

```
grep -n "^theorem completeness_dense\|^theorem completeness_discrete" FormalSystem/Metalogic/BXCanonical/Completeness.lean
grep -n "^def valid\|^def ValidDense\|^def ValidDiscrete\|^def ValidDedekindDense\|Type \*\|Type\*" FormalSystem/Semantics/Validity.lean
grep -n "Base-MCS\|Henkin-style" FormalSystem/Metalogic/WeakCanonical/Transfer.lean
grep -n "countermodel_discrete\b" FormalSystem/Metalogic/WeakCanonical/Transfer.lean
grep -n "CarrierProbe" FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean
grep -n "Lex.isOrderedMonoid\|isOrderedMonoid" .lake/packages/mathlib/Mathlib/Algebra/Order/Monoid/Prod.lean
grep -n "^theorem box_dense_gives_density\|cantor_bfmcs_dense_restricted_\(tc\|buc\|fuc\)\|cantorIsoDense" FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean
grep -n "^def Derivable\b" FormalSystem/ProofSystem/Derivable.lean
grep -n "deductionTheorem\|deductionConverse\|Derivable.deduction" FormalSystem/Metalogic/Core/DeductionTheorem.lean
grep -n "^def SetConsistent\|^def SetMaximalConsistent\|^theorem set_lindenbaum" FormalSystem/Metalogic/Core/MaximalConsistent.lean
grep -n "SemanticConsequence\|⊨" FormalSystem/Semantics/Validity.lean
grep -n "Strong Completeness\b" latex/subfiles/04-Metalogic.tex
grep -n "^def TruthAt\|ShiftClosed\|Formula.box φ =>" FormalSystem/Semantics/Truth.lean
grep -n "time_shift_preserves_truth" FormalSystem/Semantics/Truth.lean
grep -rn "isTotal_timeShift" FormalSystem/Semantics/WorldHistory.lean
ls specs/archive/361_.../design/02_compactness-route.md
jq -r '[.active_projects[].dependencies[]?] | length' specs/state.json
jq -r '[.active_projects[].dependencies[]?] | unique | length' specs/state.json
```
