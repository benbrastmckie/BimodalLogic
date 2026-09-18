# Research Report: Lean 4 Appendix for BimodalReference.typ

- **Task**: 620 — lean_appendix_bimodal_reference
- **Date**: 2026-09-17
- **Scope**: Confirm seed material, inventory what is reusable vs. stale, and document the
  conventions the new `chapters/ax-lean-appendix.typ` must follow.

## 1. Summary / Recommendation

Write a new back-matter appendix `typst/chapters/ax-lean-appendix.typ`, included in
`typst/BimodalReference.typ` immediately before (or after) `chapters/ax-machine-appendix.typ`,
and cross-referenced from `chapters/00-introduction.typ`'s "Outline" section (the paragraph that
already lists the back matter: `@sec:notes` + machine appendix) and optionally its "How to Read
This Book" section.

**Seed material confirmed**: `docs/user-guide/tutorial.md` ("Logos Tutorial") is the intended
primary candidate named in the task description, and it is structurally the right shape (starts
from installation, formula construction, derivation trees, Type-vs-Prop) — but it is **heavily
stale**: wrong project/import name, wrong constructor spellings, wrong claims about sorry status,
and references to `Formula.atom "p"` (a bare string) rather than the current `Atom` structured
type. `docs/user-guide/quickstart.md` is shorter, more current in places, but has its own stale
spots (`.future`/`.past` instead of `.always`/`.sometimes`). `docs/development/LEAN_STYLE_GUIDE.md`
is useful for the "Mathlib conventions" section but its own Namespaces example section is stale
(`Logos.Syntax`/`Logos.Semantics` — the real namespace is `FormalSystem.Syntax` etc.).
`docs/reference/tactic-reference.md` is current and well-maintained (checked against live
`Automation/` call-site counts) and is a good source for the tactic-proofs-vs-term-proofs
section. None of the four should be copied verbatim; every Lean snippet lifted from them must be
re-verified against live source (see §4) before landing in the appendix.

`/home/benjamin/Projects/Logos/Verification/` (`notes/`, `docs/`) was searched and contains **no
Lean-basics primer**. It is a different, unrelated project (a Rust/Aeneas verified-component
platform strategy document set — `lean4_verified_component_platform.md`,
`correct_by_construction_lean4_revised_report.md`); its content is about metaprogramming/DSL
architecture strategy, not a types-vs-Props/dependent-types/inductive-types primer. Nothing there
is reusable seed material for this task; this rules out that directory as a source and the plan
phase should not budget time revisiting it.

`/home/benjamin/Projects/Logos/Theory/typst/manual/LogosManual.typ`'s `sec-lean-implementation`
(chapters/01-introduction.typ:430-437) is a **five-line pointer section**, not a from-scratch
primer: it says the system is implemented in Lean 4 with Mathlib and introduces the `leansrc`
command with one example call. It confirms there is no Lean-basics tutorial anywhere in the
Logos monorepo's typst books either. What *is* reusable from LogosManual is the `leansrc`
convention itself (see §3) — and BimodalLogic's own `typst/template.typ` already ported it.

## 2. Existing Back-Matter and Cross-Reference Conventions

### 2.1 Book structure (`typst/BimodalReference.typ`)

Back matter is two `#include`s at the end, after Part II:
```
#include "chapters/06-notes.typ"
#include "chapters/ax-machine-appendix.typ"
```
followed by the bibliography. The new file should be added as a third `#include` here:
```
#include "chapters/06-notes.typ"
#include "chapters/ax-lean-appendix.typ"
#include "chapters/ax-machine-appendix.typ"
```
(Lean-primer-then-machine-appendix reads better than the reverse, since the machine appendix
assumes the reader already knows what a Lean declaration is; but either order is defensible —
this is a planning-phase call, not a research finding.)

Appendix headings use `#heading(numbering: none)[Appendix: ...]` with an explicit label, e.g.
`ax-machine-appendix.typ`:
```
#pagebreak()
#heading(numbering: none)[Appendix: The Machine-Readable Axiomatization] <machine-appendix>
```
The new appendix should follow the same pattern, e.g.
`#heading(numbering: none)[Appendix: Reading the Lean Formalization] <lean-appendix>` (label name
is a plan-phase decision; `<lean-appendix>` or `<sec:lean-appendix>` are both consistent with
existing label styles — compare `<sec:notes>`, `<machine-appendix>`).

### 2.2 Introduction cross-reference point

`chapters/00-introduction.typ` has no existing "Lean Implementation" section (unlike
LogosManual's `sec-lean-implementation`); the closest analog is its **"Project Structure"**
section at the end (bullet list over `Syntax/`, `ProofSystem/`, `Semantics/`, `Metalogic/`,
`Theorems/`, `Automation/`/`Examples/`) and its **"Outline"** section, which already states:

> Back matter closes the book: design notes and design-choice discussion (`@sec:notes`), and a
> machine-readable appendix cross-referencing every Lean declaration cited in the text.

This sentence needs a clause added for the new appendix (e.g. "...a from-scratch primer on
reading the Lean formalization directly (`@lean-appendix`), and a machine-readable appendix...").
The "How to Read This Book" section's closing sentence ("Formal claims are typeset with their
Lean identifiers in fixed-width font...the machine appendix indexes the full correspondence")
is also a natural place for a one-line pointer to the new appendix for readers who want to go
past the cited identifier into the source itself.

### 2.3 The `leansrc`/`leanref` convention is already live in this book

`typst/template.typ:98-101` already defines (ported from LogosManual's `template.typ:103`):
```
#let leansrc(module, name) = block(above: 1.0em, below: 1.0em, raw(block: true, "> " + (module + "." + name).replace(".", "." + sym.zws) + "."))
#let leanref(name) = raw(name)
```
and it is **already used inside chapters that are `#include`d by `BimodalReference.typ`**:
`chapters/p2-frame-classes.typ` (`#leansrc("FormalSystem.ProofSystem", "FrameClass")`) and
`chapters/p2-decidability-practice.typ` (`#leansrc("FormalSystem.Metalogic.Decidability.FMP",
"FilteredWorld")`, `#leansrc("FormalSystem.Metalogic.Decidability", "decide")`). It is also used
extensively (60+ call sites) in the separate standalone document `typst/FormalFoundations.typ`
(not included in the book, but a useful style reference). The pattern in both chapters is:
````
#leansrc("FormalSystem.ProofSystem", "FrameClass")
```
inductive FrameClass where
  | Base
  | Dense
  | ZTime
  | RTime
```
````
i.e. an unlabeled fenced code block (three backticks, **no `lean` language tag** — checked across
every `.typ` file; the two other fenced-block uses in the book are ` ```json ` and ` ```python `
in the dataset-pipeline and machine-appendix chapters respectively). The new appendix should use
this exact `#leansrc(module, name)` + bare fenced block pattern for every Lean excerpt, rather
than inventing a new code-block convention — it is the established idiom for "here is a literal
excerpt of Lean source" in this book, and it doubles as a citation the reader can follow.

Everywhere else in the book, a bare Lean identifier is just written in single backticks
(`` `perpetuity1` ``, `` `Formula` ``) without `leansrc`/`leanref` wrapping — that remains the
right choice for inline prose references; `leansrc` is reserved for block-level "here is the
actual declaration" excerpts.

## 3. Sync-check contract (`scripts/typst-sync-check.sh`, `typst/SYNC-MAP.md`)

The new appendix is subject to all three mechanical checks and must be written with them in
mind from the start, not fixed up after the fact:

1. **Check 1 (backtick resolution)**: every single-backtick span across `typst/**/*.typ`
   (excluding `generated/`) must resolve either as a literal identifier found via
   `grep -rl --include=*.lean -F <name> FormalSystem --exclude-dir=Boneyard`, or as an existing
   path under `FormalSystem/` (excl. `Boneyard/`) or the repo root, or be listed in
   `typst/sync-check-whitelist.txt`. This means: **every Lean identifier or path named in the
   appendix's prose must be a real, currently-live declaration/file** — no hand-invented example
   names, no citing `Boneyard/`-only code as if it were live. A schematic type-signature
   illustration that cannot literal-match source formatting (e.g. spacing) needs a
   `sync-check-whitelist.txt` entry, following the precedent already there (`DerivationTree fc Γ
   φ`, `Γ ⊢[fc] φ`, `atom a`, etc.).
2. **Check 2 (count freshness)**: any digit the appendix states about axiom/rule/sorry counts
   must be pulled from `typst/generated/status.typ`'s `#let` bindings (`axiom-count`,
   `rule-count`, `sorry-total`, `sorry-total-excl-boneyard`, ...) — **never hand-typed**. Live
   values as of this research (commit `7fdf029e6`, 2026-09-07 stamp; re-verified independently
   below): `axiom-count = 45`, `rule-count = 7`, `sorry-total = 4` (all four in the archived
   `Boneyard/Kamp/` tree), `sorry-total-excl-boneyard = 0`. **The metalogic pipeline is now
   sorry-free outside the archive** — this directly contradicts `docs/user-guide/tutorial.md`'s
   framing (which treats sorries as pedagogical stand-ins over an implied non-sorry-free
   baseline) and *confirms* `docs/reference/tactic-reference.md`'s "42 of the tree's 45 schemata"
   framing is current-generation-correct in spirit (its 45 count matches; the appendix should
   double check the 42-covered figure against `Automation/`'s axiom matcher list if it repeats
   that claim). Independent re-derivation performed during this research:
   `awk '/^inductive Axiom/,/deriving Repr/' FormalSystem/ProofSystem/Axioms.lean | grep -c '^  | '`
   → `45`, matching `status.typ` exactly.
3. **Check 3 (machine appendix)**: not directly relevant to the new file (governs only
   `generated/machine-appendix.*`), but the new appendix must not duplicate or contradict the
   machine appendix's own count claims.

**Never cite `file:line`.** `FormalSystem/README.md`'s "Standing Conventions" section documents
a machine-checked repo convention (its own check C20) that no publication-facing surface —
explicitly including `typst/` — may cite a Lean declaration by `file:line`; cite by declaration
name only (optionally with the containing file name, no line number), exactly as
`p2-decidability-practice.typ` does (`` `getProof?` (`Decidability/DecisionProcedure.lean`) ``).
Every Lean-snippet citation in the new appendix must follow this.

**Every Lean snippet must compile.** The task description's mandate ("Every Lean snippet must
compile against the current toolchain and cite real declarations") is stricter than what
sync-check mechanically verifies (sync-check only checks that a *name* resolves somewhere in
source, not that a *code excerpt* is byte-identical to source or that a *constructed example*
type-checks). The plan/implementation phase should budget a verification step per illustrative
example — either (a) quoting the excerpt directly from a `leansrc` block sourced from real
declarations (verifiable by inspection, same discipline as `p2-frame-classes.typ`), or (b) for
any newly-authored didactic example (e.g. "define a formula `φ` and prove `⊢ φ.box.imp φ`"),
actually running it through `lake env lean` / `lean_run_code` / a scratch file built against the
pinned toolchain (`leanprover/lean4:v4.33.0-rc1`, Mathlib `v4.33.0-rc1`) before it lands in the
book. This is the same discipline `SYNC-MAP.md` Phase 6 used for the whole book ("zero `stale` /
`not-found` names remain") — the appendix earns the same bar since it is now part of `typst/`.

## 4. Concrete staleness inventory in the candidate seed documents

Verified against live source (`FormalSystem/Syntax/Formula.lean`, `Atom.lean`,
`ProofSystem/Derivation.lean`, `ProofSystem/Axioms.lean`, `Syntax/Context.lean`,
`Metalogic/StrongCompleteness.lean`, `lakefile.toml`, `lean-toolchain`):

| Claim in docs/ | Where | Status | Correction |
|---|---|---|---|
| `import Logos`; `open Logos.Syntax`, `open Logos.ProofSystem` | tutorial.md:51-54 | **stale** | Package is `BimodalLogic`; library is `FormalSystem`. `import Bimodal` in quickstart.md is *also* wrong — there is no `Bimodal` root import; the correct import target is `import FormalSystem` (root aggregator `FormalSystem.lean`), with `open FormalSystem.Syntax` / `open FormalSystem.ProofSystem` (quickstart.md's `open` lines ARE correct, matching real namespaces `FormalSystem.Syntax`/`FormalSystem.ProofSystem`) |
| `def my_formula : Formula := (Formula.atom "p").box.imp (Formula.atom "p")` | tutorial.md:57 | **stale** | `Formula.atom` takes an `Atom`, not a `String` (`atom : Atom → Formula`, `Syntax/Formula.lean`). Use `Formula.atomS "p"` (the compatibility helper, `Syntax/Formula.lean` `def atomS (s : String) : Formula := atom (Atom.mkBase s)`) or `Atom.mkBase "p"` directly. quickstart.md's `atom s` table entry has the same gap — doesn't mention `atomS`/`Atom` at all. |
| `.future`/`.past` for △/▽ | quickstart.md:69-70 (Key Operators table) | **stale** | Live names are `Formula.always` (△, `allPast.and (φ.and allFuture)`) and `Formula.sometimes` (▽, De Morgan dual of `always`), `Syntax/Formula.lean:457,580`. `.future`/`.past` are not declarations. |
| `DerivationTree.modusPonens`, `DerivationTree.necessitation` (camelCase) | tutorial.md:201, 91; quickstart.md:60,91,155 | **stale** | Constructor is `modus_ponens` (snake_case, per `ProofSystem/Derivation.lean`'s actual `inductive DerivationTree` — constructors: `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `time_reflection`, `weakening`). `necessitation`/`temporal_necessitation` ARE snake_case-correct as spelled (single words, no case issue) but tutorial.md's `.necessitation _ d` / `.temporalNecessitation _ d` pattern-match arms (tutorial.md:236-237) wrongly camelCase `temporal_necessitation` as `temporalNecessitation`. |
| `DerivationTree Γ φ` (no frame-class parameter) | tutorial.md throughout | **stale** | `DerivationTree` is now `DerivationTree (fc : FrameClass) : Context → Formula → Type`, i.e. `DerivationTree fc Γ φ` with notation `Γ ⊢ φ` defaulting to `FrameClass.Base` and `Γ ⊢[fc] φ` for explicit classes (`ProofSystem/Derivation.lean`). None of tutorial.md's derivation examples show the `FrameClass` parameter or `⊢[fc]` notation. |
| `theorem soundness ... := by sorry`; `weak_completeness`; `consequence_completeness (Γ ⊨ φ → Γ ⊢ φ)` citing `Metalogic/StrongCompleteness.lean` | tutorial.md §7 | **partially stale** | `Metalogic/StrongCompleteness.lean` genuinely exists and is the right file, but its actual top-level theorem names are `consequence_completeness_of_engine`, `strongCompleteness_of_compact`, `compact_iff_modelExistence`, etc. (verified via `grep -n "^theorem\|^def " FormalSystem/Metalogic/StrongCompleteness.lean`) — not a bare `consequence_completeness`. The real completeness entry point is `FormalSystem.Metalogic.BXCanonical.completeness` (`Metalogic/BXCanonical/Completeness.lean`), with `completeness_dense`, `completeness_ztime`, and `completeness_rtime_engine` (`CompletenessDedekind.lean`) as frame-class variants — matching `SYNC-MAP.md`'s D1 finding and `FormalFoundations.typ`'s `leansrc` calls. Soundness is `Metalogic/Soundness.lean`'s `soundness`, `soundness_dense`, `soundness_ztime`, `soundness_rtime` — sorry-free, matching tutorial.md's status footnote in substance if not in exact names. |
| Axiom count / layer count (implicit: no count given, but tutorial.md never mentions 45/9) | tutorial.md, quickstart.md | **absent, not wrong** | Neither doc states a count, so nothing to correct, but the appendix must use the live `45` constructors / `9` layers (`ProofSystem/Axioms.lean`: Layer 1 Propositional (4), Layer 2 S5 Modal (5), Layer 3 BX Temporal (20), Layer 3b Additional BX Temporal (4), Layer 4 Modal-Temporal Interaction (1), Layer 5 Uniformity (5), Layer 6 Prior Axioms for Integers (2), Layer 7 Z1 (1), Layer 8 Density (1), Layer 9 Reynolds Dedekind (3) — sums to 46 by that per-layer breakdown minus one: recount directly from source if used, do not hand-sum layer comments) rather than the book's own historical `SYNC-MAP.md` figure of "42 constructors in 8 layers", which is explicitly marked HISTORICAL in that file and superseded by `generated/status.typ`'s live 45/9. |
| `Logos.Syntax`, `Logos.Semantics.TaskFrame` namespace examples | LEAN_STYLE_GUIDE.md:94-105 (Namespaces subsection) | **stale example, guide otherwise current** | Real namespaces are `FormalSystem.Syntax`, `FormalSystem.Semantics`, etc. (confirmed via every `.lean` file header: `namespace FormalSystem.Syntax`). The rest of LEAN_STYLE_GUIDE.md's naming-convention rules (def/theorem casing split by result type, tactic-token snake_case, the `defsWithUnderscore = 0` linter note) are current and well worth reusing verbatim in the "Mathlib conventions" appendix section — only the Namespaces subsection's two example lines are wrong. |
| Everything in `docs/reference/tactic-reference.md` | — | **current** | Cross-checked against live call-site claims (e.g. "68 call sites" for EF-game tactics, "three call sites all in `Examples/`" for `modal_search`) it already reads as recently audited (references the retirement of `tm_auto`/`temporal_search`/`propositional_search` and the Aesop `TMLogic` rule-set retirement to `Boneyard/RetiredTactics/`, both of which are visible in the live tree). Good source for the tactic-proofs-vs-term-proofs section; no corrections found during this pass (a compile check of its literal snippets is still owed at implementation time per the "must compile" mandate, but no *textual* staleness was found). |
| `docs/user-guide/quickstart.md`'s axiom-name usage (`modal_t`, `modal_4`, `modal_b`, `apply_axiom MT/M4/MB/MK`) | quickstart.md | **mixed** | `modal_t`, `modal_4`, `modal_b` as `Axiom` constructor names are correct (`ProofSystem/Axioms.lean` Layer 2). The `apply_axiom MT/M4/MB/MK/T4/TK/TA/TL` tactic-name table (also duplicated in tactic-reference.md) was not independently re-verified against `Automation/Tactics/` in this pass — flag for implementation-time compile check. |

## 5. Proposed section-to-source mapping (for the plan phase)

Per the task description's required coverage, with source material identified:

| Appendix section | Primary source | Live Lean anchors to cite |
|---|---|---|
| What Lean is | New prose (no seed doc covers this framing) | n/a — general Lean 4 exposition |
| Types vs. Props, dependent types | New prose; tutorial.md §4 "Type vs Prop Distinction" (reusable *framing*, needs rewritten examples) | `DerivationTree` (`Type`), `Derivable`-style `Prop` alternative if one exists (check at plan time — `StrongCompleteness.lean` doesn't define a `Derivable : Prop`; verify whether one exists anywhere before claiming a contrast pair) |
| Propositions-as-types, proof terms | New prose + tutorial.md §3 examples (rewritten with correct constructor names) | `DerivationTree.axiom`/`assumption`/`modus_ponens` term-mode examples |
| Inductive types (Formula, DerivationTree running examples) | tutorial.md §2, §4 (rewritten); live source | `Formula` (`Syntax/Formula.lean`, 6 constructors), `DerivationTree` (`ProofSystem/Derivation.lean`, 7 constructors, `FrameClass`-parameterized) — reuse the `#leansrc` block pattern from `p2-frame-classes.typ` |
| Structures and classes | New prose; `TaskFrame`/`TaskModel` structures (tutorial.md §6, needs correction — current `TaskFrame`/`WorldHistory`/`PartialHistory` API differs from tutorial.md's simplified sketch; compare against `FormalFoundations.typ`'s already-verified `leansrc` calls for `Semantics.TaskFrame`, `Semantics.PartialHistory`, `Semantics.TaskModel`) plus `FrameClass` (`ProofSystem/Axioms.lean`) as the classes/typeclass-adjacent example (`DecidableEq`, `BEq`, `Hashable`, `Countable` derived on `Formula`) | `TaskFrame`, `PartialHistory`, `WorldHistory`, `TaskModel`, `FrameClass` |
| Tactic proofs vs. term proofs | tactic-reference.md (current, reusable) + tutorial.md §5 (rewrite examples) | `modal_search`, `propDecide`, `apply_axiom`, `deduction`/`undischarge` |
| Mathlib conventions | LEAN_STYLE_GUIDE.md §1 (current except Namespaces example) | naming rules only, no single Lean declaration to cite |
| Lake and project layout | quickstart.md prerequisites + `lakefile.toml` + `FormalSystem/README.md` | `lakefile.toml` (package `BimodalLogic`, library `FormalSystem`, test lib `BimodalTest`, Mathlib pinned `v4.33.0-rc1`), `lean-toolchain` (`leanprover/lean4:v4.33.0-rc1`) |
| Reading `FormalSystem/` source for the book's formal claims | New prose tying back to `@sec:formulas`, `@sec:metalogic`, etc.; `FormalSystem/README.md`'s "Cite declaration names, never file:line" convention as a reading-practice note | Directory tour: `Syntax/`, `ProofSystem/`, `Semantics/`, `Metalogic/`, `Theorems/`, `Automation/`, `Examples/` |

## 6. Open items for the plan phase (not decided by this research)

- **Appendix ordering** relative to `ax-machine-appendix.typ` (primer-then-machine-index reads
  more naturally but either order is defensible; §2.1 above).
- **Whether to add a bibliography entry** for a canonical Lean 4 reference (e.g. "Theorem
  Proving in Lean 4" / the Lean 4 manual). `typst/bibliography.bib` currently has no Lean-tooling
  citation at all (checked: no `@online`/`@misc` entry for lean-lang.org or Mathlib); the
  appendix could cite the official docs via a plain `#link(...)` instead of adding a `.bib`
  entry, consistent with how `docs/user-guide/tutorial.md` closes with plain external links
  rather than formal citations.
- **Compile-verification workflow** for newly-authored didactic snippets (not lifted verbatim
  via `#leansrc` from real declarations) — needs a concrete scratch-file-and-`lake env lean`
  (or `lean_run_code`) step budgeted into the implementation plan, per §3's "must compile"
  discussion.
- **Whether a `Derivable : Context → Formula → Prop` counterpart to `DerivationTree` exists**
  anywhere live, to use as the canonical Type-vs-Prop contrast pair for that appendix section —
  not confirmed in this pass; `docs/reference/tactic-reference.md` mentions
  `Derivable.deduction` in passing (§ on `deduction`/`undischarge`), suggesting a `Derivable`
  `Prop` does exist somewhere in `Metalogic/`; the plan/implementation phase should locate its
  exact module before citing it.
