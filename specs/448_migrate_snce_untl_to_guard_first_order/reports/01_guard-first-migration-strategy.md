# Research: Migrating `snce`/`untl` to Guard-First Argument Order

- **Task**: 448
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Type**: lean4
- **Session**: sess_1786990544_629448
- **Date**: 2026-08-17
- **Status**: researched

---

## Executive Summary

1. **The paper side is guard-first, and the tracked anchor no longer carries a footnote at all.**
   Both stale artifacts named in the task description quote a *footnote* inside
   `def:BLplus-semantics`. That footnote has been **removed from the live paper**. The currently
   pinned anchor text (sha256 `edde7517…`, re-pinned 2026-08-17) is footnote-free: it is two truth
   clauses and nothing else. Guard-first must therefore be re-derived from the clause bodies plus
   `def:BLplus-defined`, which it is, unambiguously.

2. **The migration is more tractable than the task description assumes, because the type checker
   *can* be made to catch every missed site** — by renaming the constructors at the same time as
   swapping them. Renaming `untl`→`untlG`, `snce`→`snceG` turns every one of the 5,790 unmigrated
   references into a hard `unknown identifier` / `invalid case label` error. This converts "the
   type checker will NOT catch a missed site" into "the type checker catches 100% of missed
   sites". Recommended as the spine of the strategy.

3. **`scripts/swap_untl_snce.py` already exists** (added by the *reverse* migration, commit
   `5197deb74`, "task 107 phase 9: convention migration — untl/snce argument swap"). It is a real
   asset — the precedent proves this migration is doable — but it has **four empirically confirmed
   defects** that together cover ~652 sites, and it must be hardened before reuse. Defects are
   demonstrated with exact inputs/outputs in §5.

4. **A decisive, whole-corpus mechanical oracle is available**: `Automation/DataExport.lean`'s
   `Formula.toJson` already serialises `untl`/`snce` with explicit `"event"`/`"guard"` keys, and
   `Automation/MachineAppendixExport.lean` already dumps all 45 axioms + 7 rules + 21 derived
   operators through it into `typst/generated/machine-appendix.jsonl`. A pre-migration snapshot
   compared byte-for-byte against a post-migration *legacy-view* re-print is an exact audit of
   precisely the class of sites that proofs do **not** pin (axiom schemata, derived operators).

5. **The Typst manual is already fully guard-first and is currently asserting things about Lean
   that are false.** Four `// CONFIRM(lean):` comments in `typst/` claim the Lean constructors are
   guard-first. `scripts/typst-sync-check.sh` passes today because it checks *name resolution*, not
   argument order — it cannot see the divergence. The manual is the migration's target state, not
   a follow-on cleanup.

6. **Dominant cost driver: `Formula.lean` is the DAG root, so every edit triggers a full-tree
   rebuild.** Empirically ~352 oleans rebuilt in ~69 minutes on this 24-core machine today. Plan
   for **60–90 min per full build cycle**, and structure the work to minimise the number of full
   cycles rather than the number of edits.

---

## 1. Current State: Constructor Signatures and Semantic Clauses

### 1.1 The constructors (`FormalSystem/Syntax/Formula.lean:83-90`)

```lean
  /-- Until U(φ, ψ) — Burgess convention: φ = event (eventually true), ψ = guard (holds in between).
      "ψ holds until φ becomes true": ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r). -/
  | untl : Formula → Formula → Formula
  /-- Since S(φ, ψ) — Burgess convention: φ = event (was true), ψ = guard (held in between).
      "ψ has held since φ was true": ∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r). -/
  | snce : Formula → Formula → Formula
```

### 1.2 The binding clauses (`FormalSystem/Semantics/Truth.lean:151-154`)

```lean
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ r ψ
```

**Argument 1 (`φ`) is witnessed at the existential time — it is the EVENT.**
**Argument 2 (`ψ`) is universally quantified over the open interval — it is the GUARD.**

Note that `TruthAt` no longer takes an `Omega` parameter (the total-history refactor removed it);
the task description's line numbers (134-137) are one refactor stale — the clauses now sit at
151-154 and the docstring block at 137-142.

### 1.3 The stale docstring to be replaced (`Truth.lean:137-142`)

```
**Until / Since argument order** (do not "fix" this): `untl`/`snce` are **event-first /
guard-second** here — `untl φ ψ` reads "φ is the event, ψ is the guard". `def:BLplus-semantics`'s
footnote describes this repository's constructors as guard-first/event-second, which is
**backwards**; `Formula.someFuture φ = untl φ ⊤` and the `dense_indicator`/K-plus machinery both
depend on the event-first reading. The divergence is recorded, and the Lean convention is
deliberately preserved, in `specs/decisions/untl-snce-argument-order.md`.
```

Every sentence of this block becomes false after the migration, and its central factual claim
(that the paper's footnote describes the repository as guard-first) is **already** false today —
see §2.3.

---

## 2. The Paper Side, Re-Derived from Tracked Anchors

Anchors re-extracted directly from the live paper at
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (line 3463) and
cross-checked against `specs/paper-definitions-of-record.md`.

### 2.1 `def:BLplus-semantics` — current live text, verbatim

```latex
\begin{Ddef} \label{def:BLplus-semantics}
  The \textit{models} of $\BL^+$ are defined as in \textbf{\ref{def:BL-semantics}}, where \textit{truth in a model} $\M$ at $\tau \in H_{\F}$ and $x \in D$ extends the semantics \textbf{\ref{def:BL-semantics}} with the following clauses:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z < x$ where $\M,\tau,y \vDash \varphi$\\
      \strut\hspace{1.55in}for all $y \in D$ with $z < y < x$.
		\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z > x$ where $\M,\tau,y \vDash \varphi$\\ 
      \strut\hspace{1.55in}for all $y \in D$ with $x < y < z$.
	\end{enumerate}
\end{Ddef}
```
sha256 `edde75176efc0936c96f8d9eb18628929c2dd3bdb1aa1c21d4a88af90276314a` (manifest row confirmed
at `specs/paper-definitions-of-record.md:1141`).

**Reading**: in `φ S ψ`, `ψ` is witnessed at `z < x` (the EVENT) and `φ` holds throughout `(z,x)`
(the GUARD). **First argument = guard. Second argument = event.** Confirmed for `U` by the mirror
clause.

### 2.2 `def:BLplus-defined` — corroboration

sha256 `2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e` (unchanged since first
recording). Relevant items, verbatim:

```latex
	\item[\bf Past:]     $\past\varphi     \coloneq \top\since\varphi$.
	\item[\bf Future:]   $\future\varphi   \coloneq \top\until\varphi$.
	\item[\bf Next:]     $\Next\varphi     \coloneq \bot\until\varphi$.
	\item[\bf Previous:] $\Previous\varphi \coloneq \bot\since\varphi$.
```

Both families put the constant (`⊤` for the tense operators, `⊥` for the one-step operators) in
**first** position and the variable `φ` in **second** position — i.e. guard first, event second,
exactly matching §2.1. This is an independent corroboration internal to the paper and does not
depend on any footnote.

### 2.3 The footnote is gone — both quoted versions are stale

The task description warns that the decision record and the `Truth.lean` docstring quote a
since-corrected footnote. The situation is one step further along than that:

| Artifact | What it quotes | Anchor sha | Live status |
|---|---|---|---|
| `specs/decisions/untl-snce-argument-order.md:20-25` | footnote v1 ("the repository's constructors follow the Pnueli convention…guard first") | `3f56a996…` | superseded 2026-08-12 |
| `specs/paper-definitions-of-record.md:573-600` (prose caveat) | footnote v2 ("paper guard-first, repository event-first/Burgess") | `f40f514e…` | superseded 2026-08-17 |
| **Live paper / current manifest row** | **no footnote at all** | `edde7517…` | **current** |

The 2026-08-17 re-pin re-quoted the `def:BLplus-semantics` block (see
`specs/paper-definitions-of-record.md:52-70`) and the newly quoted block is footnote-free — but
the **prose caveat below it (lines 573-600) was not rewritten** and still describes a footnote
that no longer exists, still asserts the Lean tree is event-first "and did not need to be
changed", and still cites `Formula.lean:85-90` / `Truth.lean:134-135` by stale line numbers.

**Consequence for the plan**: `specs/paper-definitions-of-record.md:573-600` is a *third* stale
artifact, not named in the task description, and must be corrected alongside the two that are.
The correction is not a re-pin (no anchor hash moves); it is a prose repair of a caveat whose
subject has vanished.

### 2.4 What the replacement docstring text should say

The tracked anchor's current text carries **no argument-order commentary whatsoever**. So the
replacement for `Truth.lean:137-142` cannot quote a footnote; it must quote the clause bodies. A
faithful rendering:

> **Until / Since argument order — guard-first, per `def:BLplus-semantics`.** The tracked anchor
> (sha256 `edde7517…`) reads: "M,τ,x ⊨ φ S ψ *iff* M,τ,z ⊨ ψ for some time z < x where M,τ,y ⊨ φ
> for all y ∈ D with z < y < x", and mirror-wise for U. So the **first** argument is the guard
> (universally quantified over the open interval) and the **second** is the event (witnessed at
> the existential time). Corroborated by `def:BLplus-defined`: `P φ := ⊤ S φ`, `F φ := ⊤ U φ`,
> `Next φ := ⊥ U φ`, `Prev φ := ⊥ S φ` — constant guard first, variable event second. The anchor
> carries no argument-order footnote as of the 2026-08-17 re-pin; earlier revisions of this
> docstring quoted one, and those quotations are retired.

---

## 3. Blast Radius

Precise counts, from a Python scan matching `(Formula\.|\.)?(untl|snce)` at identifier boundaries
across `FormalSystem/` and `Tests/`:

| Module tree | Occurrences | Files | Notes |
|---|---:|---:|---|
| `FormalSystem/Metalogic` | 4127 | 133 | 71% of the work; BXCanonical/Chronicle, WeakCanonical/Kamp, Decidability/Verified |
| `FormalSystem/Automation` | 657 | 20 | serialisers, enumerators, tableau, dataset pipeline |
| `FormalSystem/Boneyard` | 476 | 31 | **still compiled** (`lean_lib FormalSystem` roots the whole tree) |
| `FormalSystem/Syntax` | 181 | 5 | `Formula.lean` (100), `Subformulas.lean`, others |
| `Tests/BimodalTest` | 178 | 13 | `UntlSnceCopyProbe`, `TemporalWitnessProbe`, conformance corpora |
| `FormalSystem/ProofSystem` | 82 | 1 | `Axioms.lean` — the definitional core |
| `FormalSystem/Theorems` | 73 | 3 | `TemporalDerived`, `DedekindDerived` |
| `FormalSystem/Semantics` | 16 | 1 | `Truth.lean` only |
| **Total** | **5790** | **207** | raw token count including identifier substrings is 8671 |

The task description's "~7065" sits between the two measures; **5790 is the number of real
constructor references** and is the figure to plan against.

### 3.1 Dependency order

`FormalSystem/Syntax/Formula.lean` is the DAG root — every other module transitively imports it.
There is no "migrate the leaves first" ordering available: the moment the constructor signature
changes, all 425 oleans invalidate. Topological order for *repair* is:

```
Syntax/Formula.lean  →  Syntax/Subformulas.lean, Syntax/*
   →  Semantics/Truth.lean  →  Semantics/Validity.lean, Semantics/*
   →  ProofSystem/Axioms.lean
   →  Theorems/*  and  Automation/*  (Normalization, DataExport, enumerators)
   →  Metalogic/*  (the bulk)
   →  Tests/BimodalTest/*
```

`lake build FormalSystem.Semantics.Truth` etc. lets the repair loop walk this order without
redoing downstream work each iteration; the total compute is one full rebuild plus the
re-compilation of whatever gets touched during repair.

### 3.2 Files where a wrong swap is **not** caught by any proof

These are the definitional sites — the migration's real risk surface, because nothing downstream
constrains their shape:

| File | Why unprotected |
|---|---|
| `ProofSystem/Axioms.lean` (82 occ.) | 45 axiom schemata; a wrongly-swapped schema is still a well-typed `Axiom` |
| `Syntax/Formula.lean` (100 occ.) | 10 derived-operator `def`s (§5) |
| `Automation/DataExport.lean` | `toJson` / `prettyPrint` / `toSExpr` / `tokenize` — pure serialisers |
| `Automation/DatasetExport.lean` | S-expression **parser** (`matchStr "untl "`) must stay in sync with the printer |
| `Automation/Normalization.lean` | `@[simp]` unfold lemmas proven by `rfl` — `rfl` succeeds whatever the order |
| `Automation/BenchmarkAnchors.lean`, `FormulaEnumerator.lean`, `FormulaMutator.lean` | formula corpora, no proof obligations |
| `Tests/BimodalTest/*` conformance rows | expected-value tables |

§6's oracle is designed to cover exactly this list.

---

## 4. Derived Operators

All ten `Formula.lean` definitions that mention the constructors, with their required post-swap
form and a check against `def:BLplus-defined`:

| Def | Line | Current (event-first) | After swap | Paper check |
|---|---:|---|---|---|
| `someFuture` | 131 | `untl φ ⊤` | `untl ⊤ φ` | ✅ `\future φ := ⊤ U φ` |
| `somePast` | 141 | `snce φ ⊤` | `snce ⊤ φ` | ✅ `\past φ := ⊤ S φ` |
| `next` | 494 | `untl φ ⊥` | `untl ⊥ φ` | ✅ `\Next φ := ⊥ U φ` |
| `prev` | 498 | `snce φ ⊥` | `snce ⊥ φ` | ✅ `\Previous φ := ⊥ S φ` |
| `kPlus` | 180 | `(untl ⊤ ¬φ).neg` | `(untl ¬φ ⊤).neg` | Reynolds writes `K⁺A = ¬U(⊤,¬A)` *event-first*; the Lean form is its guard-first transcription |
| `kMinus` | 193 | `(snce ⊤ ¬φ).neg` | `(snce ¬φ ⊤).neg` | as above |
| `release` | 527 | `(untl ¬φ ¬ψ).neg` | `(untl ¬ψ ¬φ).neg` | LTL derived, no paper anchor |
| `weakUntil` | 536 | `(untl φ ψ).or ψ.allFuture` | `(untl ψ φ).or ψ.allFuture` | LTL derived |
| `trigger` | 544 | `(snce ¬φ ¬ψ).neg` | `(snce ¬ψ ¬φ).neg` | LTL derived |
| `weakSince` | 553 | `(snce φ ψ).or ψ.allPast` | `(snce ψ φ).or ψ.allPast` | LTL derived |
| `strongRelease` | 556 | `untl (ψ ∧ φ) ψ` | `untl ψ (ψ ∧ φ)` | LTL derived |
| `strongTrigger` | 559 | `snce (ψ ∧ φ) ψ` | `snce ψ (ψ ∧ φ)` | LTL derived |

`allFuture`/`allPast`/`always`/`sometimes` are defined from `someFuture`/`somePast` and need **no
change at all**.

**Acceptance criterion 4 verdict**: the four named operators (`somePast`, `next`, `Past`,
`Future`) all keep their meanings under a uniform swap, and the four that have paper anchors
(`somePast`/`P`, `someFuture`/`F`, `next`/`Next`, `prev`/`Prev`) come out *literally identical in
shape to `def:BLplus-defined`* after the swap — `⊤ S φ`, `⊤ U φ`, `⊥ U φ`, `⊥ S φ`. That
character-for-character correspondence is itself a strong verification signal and should be
written into the plan as a checkable assertion.

### 4.1 Two functions that are swap-invariant (do not "fix" them)

- `Formula.swapTemporal` (line 649): `| untl φ ψ => snce φ.swapTemporal ψ.swapTemporal`. Swapping
  both sides is a no-op. Leave alone or swap both — either is correct. The involution theorem
  `swap_temporal_involution` holds either way.
- `complexity`, `modalDepth`, `temporalDepth`, `countImplications`, `atoms`, `predFormulas`,
  `subformulas` — all symmetric in the two arguments; correct with or without swap.

These are exactly the sites where a *missed* swap produces **no build error and no wrong
behaviour**, which is fine, and where a *half-applied* swap also produces no build error and no
wrong behaviour. They are noise in the residue count and should be enumerated up front so the
audit does not chase them.

### 4.2 `dense_indicator` — the load-bearing axiom

`ProofSystem/Axioms.lean:354-355`:
```lean
  | dense_indicator :
      Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg
```
i.e. `¬U(⊤, ⊥)` event-first. After swap: `Formula.untl Formula.bot (Formula.bot.imp Formula.bot)`
= `¬(⊥ U ⊤)`.

**The Typst manual already states the post-migration form**: `typst/chapters/p2-frame-classes.typ:134`
reads *"the discreteness indicator $bot #untl top$ ('there is an immediate successor': the guard
interval to the witness is empty)"*. This is independent corroboration that the target form is
`untl ⊥ ⊤` and that the soundness argument at `Semantics/Validity.lean:262-264` survives verbatim
in meaning (its prose says `U(⊤,⊥)` in event-first prefix and will need re-wording to `⊥ U ⊤`).

The decision record's §"Why the event-first reading is load-bearing" argues this dependency makes
the flip a "semantic rewrite". That argument is **wrong** and should be explicitly retracted when
the record is closed: it evaluates each dependent's *current text* under a *guard-first reading*
without swapping the arguments. A uniform swap of definition and every call site is meaning-
preserving by construction; the four "dependents" are not obstacles, they are just four more sites.

---

## 5. Migration Strategy (Recommendation)

### 5.1 Evaluation of the two strategies named in the task description

**Candidate A — "swap the constructor signature and let `lake build` drive site-by-site repair".**
Weak on its own. Most sites *would* error (a swapped guard/event breaks any proof that unfolds
`TruthAt`), but the definitional sites in §3.2 would not, and the swap-invariant functions in §4.1
never error. Errors would also arrive as thousands of confusing unification failures rather than
crisp "you missed this" messages. Cost: one full rebuild per repair round at ~60–90 min each.

**Candidate B — "guard-first smart constructors first, migrate call sites, then flip".**
Blocked by Lean semantics. A smart constructor cannot serve as an `induction`/`cases` **case
label**, and there are 540 bare-token sites (§5.3), overwhelmingly
`| untl φ ψ ih_φ ih_ψ =>` induction arms, that must name the real constructor. `@[match_pattern]`
would cover `match` but not `induction … with | untl …`. So the smart-constructor phase cannot
reach ~10% of the sites, and the "flip" step at the end still lands unguarded.

### 5.2 Recommended strategy — **rename-forced compiler coverage** (a hardened variant of A)

The task's premise "the type checker will NOT catch a missed or half-applied site" is true only
if the *name* stays the same. Change the name at the same time as the order and the checker
becomes a complete miss-detector.

| Stage | Action | Gate |
|---|---|---|
| **0. Baseline** | Snapshot: (a) `typst/generated/machine-appendix.jsonl`; (b) per-file `sorry` counts (`FormalSystem` = 892 today: Metalogic 441, Boneyard 526… recount exactly); (c) `lake build` green (confirmed today, 2457 jobs); (d) `scripts/typst-sync-check.sh` PASS (confirmed today, all 3 checks). Commit the snapshot files. | all four recorded |
| **1. Rename + swap** | In `Formula.lean` only: rename `untl`→`untlG`, `snce`→`snceG`, guard-first, with new role-naming docstrings. | `lake build` now fails at every unmigrated site — that is the point |
| **2. Mechanical rewrite** | Run the **hardened** `swap_untl_snce.py` (§5.3) in rename-and-swap mode over all 207 files. Comments/docstrings handled by a separate, reviewed pass. | `grep -rEn '(^\|[^A-Za-z0-9_])(Formula\.)?(untl\|snce)([^A-Za-z0-9_]\|$)' --include='*.lean' FormalSystem Tests` returns **0** |
| **3. Repair loop** | `lake build` in the §3.1 topological order; fix residual errors module by module. | `lake build` green |
| **4. Definitional audit** | The §6 oracle. | byte-identical legacy-view dump |
| **5. Rename back** | Pure token substitution `untlG`→`untl`, `snceG`→`snce`. No argument movement, no collision possible (zero `untl` tokens exist at this point). | `grep -c 'untlG\|snceG'` = 0 |
| **6. Final verification** | Full `lake build`; `sorry` recount vs. baseline; regenerate `typst/generated/machine-appendix.*`; `scripts/typst-sync-check.sh`. | all green, sorry delta = 0 |
| **7. Documentation** | `Truth.lean` docstring (§2.4), constructor docstrings, decision record → DECIDED, `paper-definitions-of-record.md:573-600` caveat repair, Typst `CONFIRM(lean)` comments (§7). | — |

**Why the rename is worth the extra full build**: it upgrades the guarantee from "most misses
break something" to "every miss is a named compile error". Stage 5 is provably meaning-preserving
(a lexical rename with no collisions), so its rebuild is a formality rather than a risk.

**Residual risk the rename does *not* cover**: a *half-application* — the script renames but fails
to swap. That is a script bug, not a miss, and the compiler cannot see it. §6's oracle is the
mitigation, and it is not optional.

### 5.3 Hardening `scripts/swap_untl_snce.py` — four confirmed defects

The script's own `--test` suite passes, but it was written against a smaller tree. Each defect
below was reproduced by loading the module and calling `swap_in_text` on real in-tree lines:

| # | Defect | Reproduction (actual output) | Incidence |
|---:|---|---|---:|
| 1 | **Bare tokens not matched.** Only `Formula.untl` and `.untl` are recognised; a bare `untl` is skipped. | `'  \| untl φ ψ ih_φ ih_ψ =>'` → **unchanged** | **540** sites / 63 files (mostly `induction … with` arms) |
| 2 | **Receiver dot-notation not handled.** In `γ.untl β` the receiver `γ` *is* argument 1 and sits to the **left**; the script only looks right, finds one argument, and bails. | `'φ.next = φ.untl bot := rfl'` → **unchanged** | **100** sites / 13 files (`Normalization.lean` 21, `EANegationFix/BoundedFix*` 28, `RRelation.lean` 14) |
| 3 | **Underscore-suffixed identifiers corrupted.** `Formula.untl_foo` is parsed as `Formula.untl` applied to `_foo`. | `'exact Formula.untl_inj h'` → `'exact Formula.untlh _inj'` | 12 sites (`.untl_left`, `.snce_left`, `.untl_right`, `.snce_right`) — would break the build, so caught, but must be fixed |
| 4 | **Comments and docstrings deliberately skipped.** `process_file` passes block comments through untouched and splits line comments off before rewriting. | by construction | ~2,880 doc/comment mentions; leaves every role-naming comment stale |

Defect 1 is the dangerous one: those 540 sites are `induction`/`cases` binder lists, and an
unswapped binder list silently re-binds `φ` from event to guard. Most such proofs then fail (good),
but the §4.1 swap-invariant recursors do not.

Defect 4 is a scope decision, not a bug: comments must be migrated, but by review rather than by
regex, because they contain prose like "Burgess: untl(event=φ, guard=ψ)" (`SoundnessLemmas/Core.lean:91`)
and "In Xu's notation U(event, guard), so Xu's 'U(γ, β)' = our untl(β, γ)"
(`Chronicle/RRelation.lean:1527`) whose *correction* is not a swap.

Things the script already gets **right** (verified): `Formula.untl.injEq` correctly skipped;
`| Formula.untl φ ψ =>` pattern binders correctly swapped; `φ@(.untl ψ χ)` correctly swapped;
nested applications correctly recursed.

**Recommendation**: rather than extend the character-scanner further, consider rewriting the
rewriter around a small tokenizer that (i) recognises all four syntactic forms
(`Formula.untl A B`, `.untl A B`, `A.untl B`, bare `untl A B`), (ii) refuses to fire on any token
followed by `_` or `.`, and (iii) **emits a per-site log line** (file:line, form, before, after)
so the diff is reviewable as a table rather than as 5,790 scattered hunks. The per-site log is
what makes the migration auditable; the current script produces no record of what it did.

---

## 6. The Mechanical Verification Oracle

This is the answer to "the type checker cannot catch errors at definitional sites".

### 6.1 The artifact that makes it possible

`FormalSystem/Automation/DataExport.lean:118-121`:
```lean
  | .untl φ ψ =>
    "{\"tag\": \"untl\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
  | .snce φ ψ =>
    "{\"tag\": \"snce\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
```

`Automation/MachineAppendixExport.lean` runs every one of the 45 axioms, 7 inference rules and 21
derived operators through `toJson` (plus `prettyPrint` for `schema_string`) into
`typst/generated/machine-appendix.jsonl`. That file is **committed** and is already gated by
`scripts/typst-sync-check.sh` Check 3.

### 6.2 The oracle

1. **Before** stage 1: copy `typst/generated/machine-appendix.jsonl` to a baseline path.
2. **After** stage 3 (build green), add a *temporary* legacy-view printer that reproduces the
   pre-migration serialisation from the post-migration constructor — i.e. prints argument **2**
   under the `"event"` key and argument **1** under `"guard"`, and prints `prettyPrint` as
   `U(arg2, arg1)`:
   ```lean
   -- temporary, deleted at stage 7
   partial def Formula.toJsonLegacy : Formula → String
     | .untl g e => "{\"tag\": \"untl\", \"event\": " ++ e.toJsonLegacy ++ ", \"guard\": " ++ g.toJsonLegacy ++ "}"
     | .snce g e => "{\"tag\": \"snce\", \"event\": " ++ e.toJsonLegacy ++ ", \"guard\": " ++ g.toJsonLegacy ++ "}"
     | f => /- other cases delegate unchanged -/ f.toJson
   ```
   Re-run the machine-appendix export through the legacy printer.
3. **Gate**: the output must be **byte-identical** to the stage-0 baseline.

If any axiom schema or derived-operator definition was half-swapped, un-swapped, or double-swapped,
this diff is non-empty and names the exact axiom. If everything was swapped uniformly, the diff is
empty *by construction*. This covers 100% of `ProofSystem/Axioms.lean` and 100% of the derived
operators in `Formula.lean` — the two files in §3.2 with the largest unprotected surface.

### 6.3 Complementary gates

| Gate | Catches | Cost |
|---|---|---|
| Zero-residue grep (stage 2) | every missed construction/destruction site | seconds |
| `lake build` green (stage 3) | every meaning-changing miss in a *proved* context | 60–90 min |
| Legacy-view JSONL byte-diff (§6.2) | half-applications in axiom schemata + derived operators | one export run |
| `sorry` count delta = 0, per file | proofs "repaired" by weakening | seconds |
| `next_unfold`/`prev_unfold` still `rfl`, and now read `bot.untl φ` / `bot.snce φ` | the `⊥ U φ` / `⊥ S φ` paper forms | free (in build) |
| Shape assertions vs. `def:BLplus-defined` (§4) | `P`,`F`,`Next`,`Prev` character-for-character match to `⊤ S φ`, `⊤ U φ`, `⊥ U φ`, `⊥ S φ` | manual, 4 lines |
| S-expr printer/parser round-trip (`DatasetExport.lean`) | printer/parser desync | existing test |
| `scripts/typst-sync-check.sh` PASS (stage 6) | manual/Lean drift | ~seconds |
| `Tests/BimodalTest/UntlSnceCopyProbe.lean`, `TemporalWitnessProbe.lean` | tableau-rule semantics of `untl`/`snce` | in build |

**Note on the `sorry` baseline**: the tree currently contains **892** `sorry` tokens under
`FormalSystem/` (441 Metalogic, 526 Boneyard, 19 Theorems, 1 Semantics, 1 ProofSystem — the sum
exceeds 892 because of nested-dir double counting in the quick scan; the plan must take an exact
per-file baseline, not a total). Acceptance criterion 3 is *no new* `sorry`, so a per-file delta
table is the right instrument.

---

## 7. Typst Interaction

The Typst manual has **already moved to guard-first** and currently makes four assertions about
the Lean tree that are false today and become true only after this migration:

| Location | Claim |
|---|---|
| `typst/chapters/01-syntax.typ:25` | `// CONFIRM(lean): Formula.snce and Formula.untl (Syntax/Formula.lean) take arguments guard-first, matching def:BLplus-semantics` |
| `typst/chapters/01-syntax.typ:112` | `// CONFIRM(lean): Formula.prev (bot snce-guard-first) and Formula.next (bot untl-guard-first) exist as def abbreviations` |
| `typst/chapters/p2-frame-classes.typ:171` | `// CONFIRM(lean): the next/prev defs … take the bot guard in guard-first argument position` |
| `typst/chapters/ax-machine-appendix.typ:24` | `// CONFIRM(lean): the machine appendix JSONL's since/until argument fields reflect guard-first constructor order` |

Body text is likewise guard-first throughout: `01-syntax.typ:22-23` states the convention
explicitly ("The two temporal primitives are written infix and are *guard-first*") with a footnote
that names Burgess's event-first prefix form as the *other* convention;
`01-syntax.typ:103-104,117-118` give `P φ := ⊤ S φ`, `F φ := ⊤ U φ`, `Prev φ := ⊥ S φ`,
`Next φ := ⊥ U φ`; `p2-frame-classes.typ:134` gives the discreteness indicator as `⊥ U ⊤`.

**Why `typst-sync-check.sh` passes anyway**: its three checks are (1) backticked-name resolution
against live Lean source, (2) `generated/status.typ` count freshness, (3) machine-appendix JSONL /
`.typ` agreement. None inspects argument order. Confirmed green today
(`TOTAL_VIOLATIONS=0`, `MISMATCH_COUNT=0`, `MA_COUNT_MISMATCHES=0`). The `CONFIRM(lean)` comments
are human-review markers, not machine-checked assertions — which is precisely how the manual came
to assert something false without the lint noticing.

**What the migration must do in `typst/`**:

1. `typst/chapters/ax-machine-appendix.typ:40-41` — the JSON-shape table currently documents
   `{"tag": "untl", "event": <φ>, "guard": <ψ>}`. If `DataExport.toJson` keeps `"event"` first in
   the emitted string while argument 1 becomes the guard, the table must become
   `{"tag": "untl", "guard": <φ>, "event": <ψ>}` (positional order following the constructor).
   **Decision needed in the plan**: whether `toJson` emits `guard` first (positional, matches the
   constructor and the manual's guard-first framing) or keeps `event` first (stable JSON key order
   for any downstream dataset consumers). Recommend **guard first**, consistent with the manual,
   and treat the dataset format as versioned.
2. Regenerate `typst/generated/machine-appendix.jsonl` and re-render `machine-appendix.typ` via
   `scripts/typst-machine-appendix.sh`; re-run `typst-sync-check.sh` Check 3.
3. `typst/SYNC-MAP.md:232` currently records the untl/snce truth clauses as "added from
   Truth.lean:125-130" — stale line numbers, refresh with the rest.
4. No prose changes are expected in the manual body — it is already correct. That is the point:
   **this migration closes a gap the manual opened, rather than opening one.**

`DataExport.prettyPrint` (`U(φ, ψ)` prefix) will change what it prints for every schema string in
the JSONL (`U(⊤,⊥)` → `U(⊥,⊤)` for `dense_indicator`, etc.). Whether to also switch `prettyPrint`
to infix `(φ U ψ)` to match the manual is an optional scope item; recommend **no** — keep it prefix
and positional, so the change is a pure argument reorder that the §6 oracle can verify.

---

## 8. Zero-Debt Compliance

No stage of this migration requires or invites a `sorry`. The migration is meaning-preserving by
construction: it is a uniform renaming of two argument positions, and every proof that was valid
before remains valid after, term for term, once both its statement and its body are swapped
consistently. Any proof that *cannot* be repaired by a consistent swap indicates a **bug in the
rewriter at that site**, not a proof obligation — the correct response is to fix the rewrite, not
to insert a placeholder. The plan should state this explicitly so that a build error during
stage 3 is never triaged as "hard proof".

If stage 3 stalls on a module whose errors are not explicable as swap artifacts, the correct
escalation is `[BLOCKED]` with the module named, not a `sorry`.

---

## 9. Open Questions for the Planner

1. **`toJson` key order** (§7.1) — guard-first positional (recommended) vs. stable `event`-first
   keys for dataset consumers.
2. **Lemma-name hygiene.** ~60 in-tree identifiers encode argument roles: `untl_left_*`,
   `untl_right_*`, `snce_event_congr*`, `untl_args`, `replace_untl_args`, `untl_with_top`,
   `untl_with_bot`. After the swap `*_left` refers to the guard and `*_event_congr` to position 2.
   Renaming them is a second large mechanical pass; **recommend deferring to a follow-on task** and
   recording the drift, so this task's diff stays a pure argument reorder that the oracle can
   verify. (Renaming and reordering in one pass would defeat the zero-residue grep.)
3. **Boneyard scope.** `FormalSystem/Boneyard/` (476 occurrences, 31 files, 526 `sorry`) is inside
   the default build target and therefore must migrate. Confirm it is not to be excluded first.
4. **Comment/docstring migration scope** — how much of the ~2,880 prose mentions to correct in this
   task vs. defer. The role-naming ones (`untl(event=φ, guard=ψ)` etc.) are mandatory; the
   incidental ones (`untl φ ψ ∈ m q`) are cosmetic.
5. **Should the temporary rename be `untlG`/`snceG` or something less collidable?** Grep confirms
   zero existing `untlG`/`snceG` tokens, so those are safe.

---

## Sources

**Lean tree** (all verified live at this repo, 2026-08-17):
- `FormalSystem/Syntax/Formula.lean:83-90` (constructors), `:131,141,180,193,494,498,527,536,544,553,556,559` (derived ops), `:649` (`swapTemporal`)
- `FormalSystem/Semantics/Truth.lean:137-142` (stale docstring), `:151-154` (clauses)
- `FormalSystem/Semantics/Validity.lean:262-264,301,307` (dense_indicator soundness prose)
- `FormalSystem/ProofSystem/Axioms.lean:352-355,473-486` (`dense_indicator`, Reynolds note)
- `FormalSystem/Automation/DataExport.lean:106-181`, `Automation/Normalization.lean:75-78`, `Automation/MachineAppendixExport.lean`, `Automation/DatasetExport.lean:744-797`
- `scripts/swap_untl_snce.py` (314 lines), `scripts/typst-sync-check.sh`
- commit `5197deb74` — "task 107 phase 9: convention migration — untl/snce argument swap" (the reverse migration, 26 files, build green)

**Paper anchors** (re-extracted from `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3463`):
- `def:BLplus-semantics`, sha256 `edde75176efc0936c96f8d9eb18628929c2dd3bdb1aa1c21d4a88af90276314a` — no footnote
- `def:BLplus-defined`, sha256 `2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e`
- `specs/paper-definitions-of-record.md:52-70,151-160,558-600,1141-1143`

**Typst**: `typst/chapters/01-syntax.typ:18-40,95-125`, `p2-frame-classes.typ:134-136,165-175`,
`ax-machine-appendix.typ:15-45`, `p3-ltl-to-tm.typ:54-129`, `typst/generated/machine-appendix.jsonl`,
`typst/SYNC-MAP.md:218-232`

**Decision record**: `specs/decisions/untl-snce-argument-order.md` (OPEN, to be closed)

**Measurements taken**: `lake build` green in 1.07s from cache (2457 jobs); 5,790 constructor
references / 207 files; 540 bare-token sites / 63 files; 100 receiver-dot sites / 13 files;
12 underscore-suffix sites; 892 `sorry` tokens under `FormalSystem/`; ~352 oleans rebuilt in
~69 min in today's build burst on 24 cores.
