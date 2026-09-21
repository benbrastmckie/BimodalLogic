# Module Invariants Check

`scripts/check-module-invariants.sh` answers one question mechanically: **did a change
to the module structure break anything?** It exists so that "nothing broke" is a command
with an exit code rather than a judgement call.

```bash
bash scripts/check-module-invariants.sh              # everything (builds; ~1-2 min warm)
bash scripts/check-module-invariants.sh --no-build   # structural checks only (seconds)
```

Exit 0 means every check passed. Any failure names the specific check and the offending
file and line.

## What It Checks

| ID | Check | Why it exists |
|----|-------|---------------|
| B0 | The archive is a single directory at the repository root, found and excluded | Searched from `.` (excluding `.lake/` and `.git/`), which must find exactly one `Boneyard` directory *and* it must be `./Boneyard` — ADR-010 moved the archive out of `FormalSystem/`. Every traversal still filters on the `*/Boneyard/*` name glob, which is what makes the move safe (ADR-005). When the archive was split across two directories a filter naming only the top-level one counted 29k archived lines as live; asserting the count is exactly 1 turns a second archive reappearing into a gate failure rather than a silent miscount. The load-bearing half is now inverted: with the archive gone from `FormalSystem/`, comparing that tree's filtered and unfiltered walks would be a tautology, so B0 asserts instead that `Boneyard/` is non-empty AND the `FormalSystem/` walk finds nothing to exclude |
| B1 | `Boneyard` appears in neither `lakefile.toml` nor the root aggregator `FormalSystem.lean` | B0 asserts the harness's own walks exclude the archive; B1 asserts the property those walks rest on — that Lake is never told about the archive in the first place. A `globs`/`lean_lib` entry or a root-aggregator import would put archived files back in the build graph however carefully every traversal filters them, leaving the `#exit` in each archived file as the only thing between the archive and the build |
| B2 | No live `.lean` under `FormalSystem/`, `Tests/` or `BimodalTools/` carries `import Boneyard.*` | The converse of C11. C11 asks whether archived imports resolve; B2 asks whether anything live has come to depend on the archive — which would make the archive load-bearing and its retirement a breaking change. Matched on the `import` keyword, never the bare name, so the many deliberate docstring citations of archived paths are not failures |
| B3 | No `.lean` under `FormalSystem/` carries `import BimodalTools.*`, and the generated library root `FormalSystem.lean` does not name `BimodalTools` | The library/tooling split is only worth anything while the dependence runs one way. `BimodalTools` is a `lean_lib` outside `defaultTargets`, so `lake build` compiles none of its 25 modules — but a single `import` of one tooling module under `FormalSystem/` would pull all 14,750 lines back into the published library's closure and nothing else would say so. Modelled on B1 + B2: the import-keyword match, so a docstring citing a `BimodalTools/` path is not a failure, plus the bare-name scan of the two root aggregators. The **converse** direction, `BimodalTools -> FormalSystem`, is the sanctioned one and is deliberately ungated — the asymmetry is the invariant, not an oversight |
| C1 | `lake build` and `lake build BimodalTest` exit 0 | Baseline correctness |
| C2 | `#print axioms` for four flagship theorems matches a recorded baseline | Detects a proof silently rerouted through different dependencies — invisible to a green build and an unchanged sorry count |
| C3 | Exactly one structural `sorry`, located **by content** | Asserting a line number breaks on any edit above it; the check finds the enclosing declaration instead |
| C4 | Every `import FormalSystem.*` / `import BimodalTest.*` resolves | Catches a half-finished file move |
| C5 | Every module-shaped `Bimodal.*` path in non-`specs/` markdown resolves | A `.lean`-only rewrite leaves documentation dangling |
| C6 | Known-unreachable live modules still compile, and — reporting-only, alongside the gate — how many declarations and lines those modules carry | Code outside the build graph cannot rot unseen. The added count answers a separate question the gate never did: *how much* code is out there. Nothing else reported it — `lake build` cannot see these modules by construction, C7's rollup counts files rather than declarations, and C17's textual census barely surfaces them, because declarations inside an orphan module reference each other and so almost never reach zero occurrences. A dedicated import-reachability check was considered and rejected: the reachability walk that feeds this check already *is* that check, and a second one would duplicate it and trip this check's own stale-manifest branch. The one genuinely missing thing was the number, so the number is what was added |
| C7 | Live inventory (informational, never asserted) | The correct source for any file count |
| C8 | Every Lean-bearing subdirectory has exactly one sibling aggregator `X.lean` beside `X/` | One convention, checkable |
| C9 | Zero task-number citations under `FormalSystem/` | Task numbers are renumbered by archival and mean nothing to a later reader |
| C10 | Zero references to the pre-relocation `FormalSystem/{docs,latex,typst}` paths | `docs/`, `latex/` and `typst/` live at the project root |
| C11 | Every `import` inside `Boneyard/` resolves, or is waived | The archive is never compiled, so `lake build` cannot see its imports rot. 65 archived import lines were already dangling when the two archives were consolidated. Scanned from `Boneyard/` at the repository root since ADR-010, with C11's **own** import regex admitting `Boneyard` — reusing C4's `FormalSystem|BimodalTest` pattern would match no archived module name and print PASS on an empty denominator. When re-rooting a counting gate, assert the denominator, not just the PASS |
| C12 | Every **slash-shaped** source path in `docs/` + `README.md` resolves | C5 matches only *dotted* module names, so the slash form of `FormalSystem/Metalogic/Bundle/BFMCS.lean` is invisible to it. A table naming six source files, four of which did not exist, survived a green gate on exactly this blind spot |
| C13 | Every relative markdown link in `docs/` + `README.md` resolves | Nothing checked `docs/` links at all; 96 of them had rotted, several pointing outside the repository |
| C14 | Documented axiom and sorry counts match the tree — in `docs/`, `README.md` **and** `FormalSystem/**/*.lean` docstrings — and the two headline theorems C2 does not cover match their axiom baseline | C2 and C3 assert facts about the *tree*; C14 is what asserts the *documentation* agrees with them. `docs/` had documented the axiom count as 21 against an actual 45, and the sorry count as 12 against an actual 0. The `.lean` half was added later: C14's original markdown-only scope is exactly why six docstrings claiming an axiom-constructor count of 42 survived a 42 → 45 change untouched, and widening it immediately surfaced seven further claims of an axiom count of 21, in Lean docstrings that no gate had ever seen |
| C15 | Every `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:` paper-anchor citation in live scope resolves against `docs/reference/paper-definitions-of-record.md` | Nothing asserted that a cited paper anchor exists. Thirty dangling citations accumulated across six paper editing waves; `lem:fibers` alone was cited 17 times after the paper deleted its `\label` |
| C17 (reporting-only) | Declarations whose base identifier — the last dot-segment, which is how dot notation and an `open` namespace actually reference it — occurs on no other line anywhere in the occurrence corpus: every `.lean` file under `FormalSystem/`, `Tests/` and `BimodalTools/`, every non-`specs/` `.md` file, every `typst/**/*.typ` and every `scripts/*.sh`. Six filters shape what it counts, described in full at the check itself | A census nobody can act on is a number, not an instrument. This one had reached four figures and had never been read; when it finally was, only about a fifth of it turned out to be explicable by any known false-positive mechanism. The filters are what came out of that triage. Three exclude declarations reached by a mechanism that never mentions their name — `instance` (typeclass resolution), anything carrying `simp` or an attribute registered via `register_simp_attr` (the attribute names are discovered by scanning for `register_simp_attr`, never hardcoded, so a new simp set is covered the day it lands), and `FormalSystem/Examples/`, whose contract is to be read rather than called. A fourth makes the declaration regex comment-aware, which fixes a mis-parse rather than a mis-classification: a wrapped prose line such as one ending a doc comment mid-sentence is not a declaration, and nearly two hundred such phantoms were being counted — C19 and C16's `dupNamespace` scan share the same helper for the same reason. A fifth widened the occurrence corpus to the Typst manual sources and this harness's own scripts, and that one was load-bearing rather than cosmetic: twelve declarations were reported dead solely because their only reference lived there, and seven of the twelve are the axiom baselines the harness pins in its own C2 and C14 heredocs. The corpus is widened and never narrowed — restricting it to code roughly doubles the census, because several hundred declarations are referenced only from prose. The sixth is a split rather than an exclusion: rows whose only consumer is archived are counted in the headline *and* reported beneath it, because retiring one is a decision about the archive with its own C11 waiver consequences, not a deletion. Two blind spots are accepted in exchange and recorded rather than hidden: a genuinely unused `instance`, and a genuinely unused simp lemma — the latter population is not small, and it is handed off explicitly to the unused-simp-lemma burn-down rather than silently absorbed here. Never gated, in any mode: there is no `ENFORCE_C17` and the check never touches the exit code. A textual census with a known false-positive rate must not be able to fail a build |
| C20 | `file.lean:NNN` line citations, in three assertions. **Tier 1** (gated, repo-wide live scope): every citation lands on a real, non-blank line. **Tier 2** (gated under `ENFORCE_C20`): zero such citations on publication-facing surfaces — `README.md`, `docs/`, `typst/`, the `README.md` files under `FormalSystem/`, and the top-level aggregators. **Declaration span** (gated under `ENFORCE_C20_DECL`): a citation that *names* a declaration — a backticked identifier standing immediately before it, as in a backticked name followed by the parenthesised anchor — must land inside that declaration, and the count of citations carrying **no** name is printed as a `TODO` line at every gate | A line number rots the moment anything above it is edited, and tier 1 only ever detected a citation pointing at *nothing*. It cannot detect one pointing at the *wrong declaration*, which is what a shifted citation almost always does: the re-anchoring tool was once run twice over one batch, every citation into the batch moved by twice its delta, and tier 1 passed, because a doubly shifted citation still lands on some non-blank line. "The declaration at that line" is a **span**, not the keyword line: from the opening line of the declaration's own `/--` doc comment (walking back past `@[...]` attribute lines, as C15's second assertion does) to the line before the next declaration's span. The exact-keyword-line reading was rejected on evidence — `PriorExpressivenessDense.lean` correctly cites the closing line of one theorem's doc comment and a line inside another's, and that pair is pinned inside the check as a regression case. A citation **passes** when any name in its sentence is declared in the target file with a span containing the line; **fails** only when the names immediately before it resolve in the target file and none does; is reported **unverifiable** (never failed, never guessed) when those names are an inductive constructor, a structure field or a binder; and is **residual** when it carries no name at all. The first run found 327 named citations already pointing at the wrong declaration — whole files whose citations sat a constant 12, 27 or 35 lines above their targets, invisible to tier 1 throughout. 315 were re-pointed by name in the change that added the assertion; the rest are recorded in `scripts/c20-declaration-baseline.txt` and everything **not** on that baseline is gated. The reading lives in `scripts/lib/lean_citations.py`, which `scripts/reanchor-lean-citations.py --by-name` imports too, so the gate and its repair tool cannot disagree; it carries its own fixtures, the double-shift shape among them. `Boneyard/` is excluded; a `:NNN` continuation after a citation is read by this assertion only |
| C24 | Every module in the `FormalSystem` root closure transitively imports `FormalSystem.Init`, via `lake exe checkInitImports` | `FormalSystem/Init.lean` exists so that repository-wide linter options and common tactic imports have one place to be inherited from, and that promise is only as strong as its weakest module: a file with no path to the root silently opts out of every option the root sets, and a green build says nothing about it. The check reads the real import graph out of the compiled environment rather than the text of the `import` lines, so it sees inheritance through intermediate modules exactly as Lean does — which is why the invariant is carried by eleven import lines at the minimal elements of the internal DAG, not one per module. It ran reporting-only for one release cycle, over 457 modules with no path to the root |
| C25 | Every `lean_exe` root declared in `lakefile.toml` compiles, with the root list read at run time | `lake build` elaborates only what is reachable from the two library targets, so every `lean_exe` root sits outside both closures: nothing imports it, C24's closure walk never reaches it, and C6 cannot cover it either — C6 seeds its own reachability walk from these same roots, so an exe root is *reachable* by C6's definition and a manifest line for one trips C6's stale-manifest branch rather than covering it. The gap was not hypothetical: `BimodalTools/ProofExtractorMain.lean`, the `proof_extractor` root, failed to elaborate for an extended period with three `Application type mismatch` errors masking a further 873, `lake exe proof_extractor` was simply broken, and the tree was green throughout because no gate anywhere could observe it. Reading the list from `lakefile.toml` (through `scripts/lake_targets.py`) rather than maintaining one means a newly declared executable is covered the day it is added. Module targets only, never exe targets — elaboration coverage without linking a 240-310 MB binary per root, thirteen times over |
| C25N | Every `lean_exe` root module is named for its target: the last component of `root :=` is the target in PascalCase plus `Main` (`dataset_generator` has root `BimodalTools.DatasetGeneratorMain`, `checkInitImports` has `CheckInitImportsMain`), and no live `.lean` file under `FormalSystem/`, `Tests/`, `scripts/` or `BimodalTools/` that is not an exe root has a basename ending in `Main`. Textual, so it runs under `--no-build` too | Before the rule, `Export`, `Exporter`, `Pipeline` and `Bridge` meant "the executable" on some `Automation/` modules and "a library" on others: `DataExport` (a serialization library) sat three characters from the `dataset_generator` root, the `DatasetExporter` library suggested "the thing that exports", and `TraceExport` (library) paired with `TraceExporter` (root). A `Main` suffix tells a reader the module declares a root-namespace `main` and cannot be imported alongside another root, and the name-to-target bijection is mechanically checkable. The convention is written up in `FormalSystem/Automation/README.md` ("Module naming"). |
| C26 | No live `def` or `abbrev` carries an underscore inside its own name component, and every in-source `nolint` attribute is on `scripts/nolint-attribute-allowlist.txt` — both asserted by reading the **source text**, never an imported environment | The env_linter that gates this category has four structural blind spots, and the category reopened through them with every standing gate green: `lake exe runLinter FormalSystem` reporting zero, CI's lint job passing, C16 passing, and `scripts/nolints.json` carrying nothing to grow. A finding-counting gate cannot detect a violation the linter structurally never sees, and adding more such gates would not have helped. Reading the tree instead of an import closure answers three blind spots at once — an out-of-closure module, a `private` declaration, and a name whose last component ends in the shape Mathlib's own test skips as autogenerated are all simply lines of source here. The fourth, an in-source `nolint` attribute, produces *no finding at all* rather than a suppressed one, so the second half turns it back into a line in a reviewable file. `theorem` is out of scope and `instance` is exempt on measured evidence: every live snake_case instance was probed by elaboration and is recorded as a theorem, not a definition, which is exactly why the upstream linter never fires on one. Structure fields are excluded for the same reason one level down and reassigned to C16's widened half, where elaboration can tell a data-valued projection from a `Prop`-valued one |
| C27 | Every live `#check`/`#eval`/`#print`/`#reduce`/`dbg_trace`/`dbgTrace` line under `FormalSystem/` or `BimodalTools/` is on `scripts/debug-artifact-allowlist.txt` with an exact per-file count and a reason, counted **after** masking comments, docstrings, strings and character literals | A debug directive in library code prints at every build and asserts nothing, so a changed value scrolls past with the build green; executable probes belong in `Tests/BimodalTest/`, where `#guard`, `#guard_msgs` or a throwing `IO` test makes the observation an assertion. The scan is comment-aware because docstring usage blocks are documentation, and its masker runs a fixture self-test first (strings holding `/-` and `--`, a `'"'` character literal, nested comments, raw strings) because a masker that loses literal state opens a phantom comment and hides every directive after it. Counts are exact in both directions, so a removal must lower its entry in the same change and a stale entry fails. Not identical to cslib's `pre-pr-check.sh`, whose grep is not comment-aware and omits `#print` |
| C28 (enforced) | No file's compiler-warning count exceeds its `scripts/warning-budget.txt` baseline, keyed `<count> <path> <linter>`, measured build-free by `scripts/warning-budget.py` from Lake's `.lake/build/lib/lean/**/*.trace` store | `lake build` exits 0 while emitting compiler warnings, and C16 (Batteries' `env_linter` via `lake exe runLinter`) is a **declaration** linter that never sees one -- the two sets are disjoint, so before this check a module could accumulate deprecations and dead tactics with every gate green. The acquisition is build-free on purpose: CI runs this harness as `--no-build`, and `CI_CD_PROCESS.md` records that C2/C6/C24 are consequently not run in CI at all, so a C28 that shelled out to `lake` would silently join that list. Lake records each module's diagnostics in its trace store and replays them on a cache hit -- the same replay that makes `lake build --wfail` fail on a warm cache. Counts are a ceiling and may only decrease. The scanner's anti-silence guards (no traces, no `log` key, or a non-zero baseline against a zero observation) and its undispositioned-linter-class guard both exit 2, and exit 2 is **not** suppressed by `ENFORCE_C28=0`: a measurement the harness cannot trust is an error in every mode |
| C29 (enforced) | Every live `set_option linter.* false` under `FormalSystem/`, `Tests/`, `scripts/` and `BimodalTools/` carries a `--` comment block directly above it — above any stacked `set_option … in` — whose text names the linter it disables; matched **after** masking comments, docstrings, strings and character literals, so a suppression quoted in a docstring or commented out is not one | C28 gates the compiler-warning *count*, but a suppression removes the warning before it is ever counted, so a bare `set_option linter.X false` reports a clean zero at every gate while hiding whatever it hides — the two checks are complementary halves of one ratchet, not duplicates. The evidence is `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`'s own history: a `set_option linter.unusedVariables false in` introduced for one declaration was silently **retargeted** when `bcb8e110b` inserted `regionRel_fib_subsingleton` between the option and its target; `e18cd2271` then fixed the original target with a `_`-prefixed binder, and the suppression sat dead across two further commits with every gate green. A comment naming the linter would have made that drift readable in the diff, which is also why naming the linter is required rather than decorative. There is **no companion allow-list**, deliberately, unlike C27's: a reason in a central file goes stale silently when the code it covers moves, whereas a reason at the site moves with it and is re-read by whoever next touches the declaration. The upward walk past stacked `set_option … in` lines is not a refinement but a requirement — the tree really does carry `set_option maxHeartbeats 4000000 in` directly above a linter suppression. `Tests/` is in scope although C27's debug-directive scan excludes it: a probe belongs in the test suite, an unreasoned suppression belongs nowhere. Build-free by construction, so it runs identically under `--no-build`. The anti-silence guards (an empty walk, or zero matched suppressions anywhere) exit 2, and exit 2 is **not** suppressed by `ENFORCE_C29=0`: the tree has always carried suppressions, so a zero means the matcher, the masker or the walk stopped seeing them |
| C30 (enforced) | Zero blanket linter options and zero unscoped heartbeat budgets under `FormalSystem/`, `Tests/`, `scripts/` and `BimodalTools/`: every `set_option linter.X v` and every `set_option <…maxHeartbeats…> N` (including `synthInstance.maxHeartbeats`) ends in `in`, so it covers exactly one declaration. The single exception is the long-file baseline `set_option linter.style.longFile N` with N > 0, which records a length ceiling that the linter itself keeps tight; `longFile 0` disables the linter and is not excepted. Matched on comment-masked text, like C29 | C29 requires every suppression to carry a reason, but a reasoned suppression can still cover a whole file and silence declarations written long after the reason was. A file- or section-wide heartbeat budget likewise hides which declaration is actually expensive. When Mathlib's standard linter set was adopted (`weak.linter.mathlibStandardSet` in `lakefile.toml`), the tree had one blanket `linter.unusedSectionVars` suppression, removed by splitting a `variable` block, and seven unscoped budgets; a per-declaration measurement showed that several covered declarations need no raised budget at all (every declaration in `Verified/Bridge/TemporalSaturation.lean` elaborates in under 5,000 heartbeats). The value of a linter option is not inspected: a file-scoped `true` is as much a file-wide policy decision as `false`, and project-wide linter policy belongs in `lakefile.toml`. The check starts from a **zero** baseline with no allow-list. It carries its own fixture self-test (blanket form fails; scoped form, longFile baseline and commented-out or docstring-quoted forms pass). Build-free, so it runs identically under `--no-build`. The anti-silence guards (an empty walk, or zero matched scoped `set_option … in` anywhere) exit 2, and exit 2 is **not** suppressed by `ENFORCE_C30=0` |
| C31 (enforced) | Every `[key]` cited inside a `## References` or `### References` block of a live `.lean` docstring under `FormalSystem/`, `BimodalTools/` and `Tests/` resolves in the repository-root `references.bib`. Only the block interior is read — from the heading to the next heading of equal or higher level, or the end of the doc comment — in two shapes: the reference-style second bracket, and a bare bracketed key of bibkey shape. Entries of `references.bib` cited by no `.lean` and no `.typ` file are **reported, never gated** | [REFERENCE_NORMAL_FORM.md](REFERENCE_NORMAL_FORM.md) writes a published work with a `references.bib` key, and C15 reads only the `def`/`thm`/`lem`/`cor`/`app`/`rmk` paper anchors, so nothing read the keys: two of them, `stavi1979` and `gabbay1980` in `FormalSystem/Metalogic/Expressiveness.lean`, dangled with every gate green and were found by hand. `Boneyard/` is excluded through the shared `scripts/lib/live_walk.py` walker. Deliberately out of scope: inline-prose bibkey mentions outside a block (the normal form governs the block, and a bracketed year-bearing token in prose is as often an interval as a citation), and the `sub:` paper-anchor prefix, which is C15's subject and ungated there on purpose. The advisory half unions **two** citation syntaxes before taking the difference, because a Lean docstring writes a bracketed key and a Typst document writes `@key`: a Lean-only scan reports 55 of 77 entries unused, the unioned scan 11. Ships enforced with no soft window because the tree was clean the day it landed. It carries its own fixture self-test. An unreadable `references.bib`, an empty walk or zero blocks found exits 2, which `ENFORCE_C31=0` does **not** suppress |
| C32 (enforced) | Every relative markdown link inside a live `.lean` comment (`/--`, `/-!`, plain block and `--` line comments) under `FormalSystem/`, `BimodalTools/` and `Tests/` resolves on disk, **relative to the citing file's own directory**. A target that exists only because it is gitignored counts as broken, as in C13 | C13 covers `docs/` and `README.md`, and `scripts/readme-lint.sh` reads `README.md` files only, so a markdown link in a Lean docstring was read by nothing: 37 were broken when the docstrings were last swept, 16 of them stale pre-rename `Logos` paths, and every target was resolvable — renames nobody propagated. **The path-shaped target filter is load-bearing, not polish**: the bare link pattern matches 82 times in live Lean comments and 71 of those are inline mathematics (a bracketed tuple applied to a parenthesised argument list, almost all under `FormalSystem/Metalogic/Expressiveness/Kamp/`), so without the filter the first run is a wall of false positives and the check is never trusted again. A match is a link only when its target is a conservative path token (ASCII word characters, `.`, `/`, `-`, optional `#fragment`; no whitespace, comma or subscript) **and** contains a `/` or ends in a recognised file extension. The raw, external and path-shaped counts are all printed, so a filter that has drifted too tight or too loose shows in the `PASS` line. Comment text comes from `comments_only` in `scripts/lib/lean_debug_artifacts.py`, the scan C27, C29 and C30 mask with, so a bracket-paren pair in code or a string literal is never a link. `Boneyard/` is excluded; the `sub:` anchor prefix and backticked repository-relative paths (the normal form's module cross-reference) are out of scope. Zero links is a legitimate end state, so there is no anti-silence guard on the count; the fixtures carry the matcher's soundness. An empty walk exits 2 |
| C33 (enforced) | The repository-root `FormalSystem.lean` is byte-for-byte what `lake exe mk_all --lib FormalSystem` generates: one `import` line per `.lean` file under `FormalSystem/`, sorted by dotted module name in code-point order, one trailing newline, and nothing else. Scanned **build-free** by a python3 re-implementation of the generator, so it runs under `--no-build` and therefore in CI | The library root is generated, not hand-maintained, and the empty C6 manifest rests on it: a library module is inside the build closure *because* the root imports it. A module added without regenerating the root is compiled by nothing; one deleted or moved without regenerating it breaks the build. A check that shelled out to `lake exe mk_all --check` would be skipped under `--no-build` and join C2/C6/C24 on the not-in-CI list, which is the failure C28's trace-scan design already avoided once. `lake exe mk_all --lib FormalSystem --check` remains the authoritative cross-check and runs as its own CI step; a disagreement between the two means the scanner has drifted from Mathlib's generator. `--lib FormalSystem` is structural, not a preference: a bare `mk_all` errors on the two `srcDir = "Tests"` libraries and would generate a `BimodalTools.lean` importing twelve `main`s |
| C9D | Task-number citations under `docs/` (computed always, **soft** by default) | C9's rule binds `docs/` too, but `docs/` does not yet satisfy it. Reported at every gate so the debt is visible rather than forgotten |

### Why C5 was not simply extended

C12 is a separate check rather than a widening of C5's regex, and this is deliberate.
Extending C5 to also match `Bimodal.*` would immediately turn the gate red on occurrences in
`FormalSystem/**/README.md` that are a separate piece of work. C12 covers the *slash* form over
a *different scope*, so it can be enforced today without holding the gate hostage to unrelated
files. Do not merge the two.

C12's pattern includes `Logos/` and `Bimodal/` — the two pre-merge tree roots. Neither resolves
to anything in the current tree, so any occurrence is a defect by construction, which is the
point of naming them.

## The Companion Files

### `scripts/module-invariants-manifest.txt` — known-unreachable modules (C6)

`lake build` only compiles what is reachable from a Lake target root. A module that no
target imports is never compiled, so a broken import inside it goes unnoticed
indefinitely. Every such module must be listed here; C6 compile-checks each one with
`lake build <Module>`.

- C6 **fails** if an unreachable live module is missing from the file.
- C6 **fails** if an entry names a module that no longer exists.
- C6 **fails** if an entry names a module that is now *reachable* — `lake build` already
  guards it, so the line is stale and must be deleted.
- A `broken:` prefix marks a module known not to compile. It is still tracked, so it
  cannot be forgotten, but is not compile-checked. Removing the prefix is how a repaired
  module re-enters the gate.

Wiring a module into the build graph means **deleting** its line here.

The file currently holds **no entries**, and that is its intended resting state. The library
root `FormalSystem.lean` is generated by `lake exe mk_all --lib FormalSystem` and imports every
module under `FormalSystem/`, so no library module can be unreachable while the root is
current; the test and tooling modules that used to be listed were wired into their aggregators.
The file's comment blocks record what was listed and why each line went. C6 still runs: it is
what fails when a new module lands outside every closure.

### `scripts/module-invariants-allowlist.txt` — non-module dotted names (C5)

C5 cannot distinguish a module path from a fully-qualified namespace or declaration
name: both are dotted and capitalized. Names verified to be real namespaces or
declarations are listed here with the file and line that defines them.

This is a permanent, documented exemption — **not** a place to park a genuinely stale
module path. Add an entry only after confirming with `grep -rn` that the name is live.
C5 reports allowlist entries that no longer occur, so stale exemptions get pruned.

### `scripts/boneyard-import-waivers.txt` — unrepairable archived imports (C11)

An archived file is outside the import closure, so nothing compiles it and nothing
notices when a module it imports is deleted or moved. C11 closes that hole: every
`import FormalSystem.*` / `import BimodalTest.*` line under `Boneyard/`
must resolve to a file on disk, or appear here.

Entries are permanent records of imports that **cannot** be repaired — the target was
deleted outright, or its name is genuinely ambiguous and choosing a target would
fabricate provenance. Each carries the reason, and a deletion carries the commit that
did it.

This is not a backlog. Before adding an entry, prove there is no unique target file on
disk; if there is one, fix the import instead. C11 reports entries that no longer occur
as stale, on the C5 model, so the file cannot become a dumping ground.

### `docs/reference/paper-definitions-of-record.md` — the paper-anchor resolution source (C15)

C15 resolves every paper-anchor citation against this file, **never against the paper**. That is
deliberate. The paper (`possible_worlds.tex`) lives in a different repository this one cannot see
from CI, and it is edited by its author on his own schedule — it moved through six definitional
waves in ten days, twice while a dispatch against it was in flight. A check that resolved against
the live `.tex` would go red whenever the author edited his own paper, an event this repository
neither controls nor can fix by editing itself. Resolving against the pinned record makes C15
assert something this repository *can* act on: that every anchor it cites is a recorded decision.

A citation resolves if it has **either** a row in the record's `MANIFEST` block (a pinned anchor,
whose verbatim text and hash are tracked) **or** a row in the record's `KNOWN-ANCHORS` block, with
one of two statuses:

- `LIVE-UNPINNED` — resolves to a live `\label{}` in the paper, but the tree cites it by name
  only, so pinning its text would buy nothing. Promote it to the manifest if a docstring starts
  quoting it verbatim.
- `DANGLING` — does **not** resolve: retired, commented out, or never a paper label at all. Every
  citation site for one of these must say so in its own prose; C15 asserts only that the anchor is
  *recorded*, not that the surrounding sentence is honest.

An anchor with no row in either block is a typo or an undocumented citation. Both are defects, and
the fix is to correct the citation or record the anchor — not to widen the check's exclusions.

### `scripts/markdown-link-allowlist.txt` — link-syntax illustrations (C13)

Markdown **files** (not individual links) whose relative links are not resolution-checked. Only
two justifications are admissible, and both are about links that illustrate link *syntax*
rather than links a reader is meant to follow: template snippets showing what a directory
README should look like, and grep patterns inside a fenced code block that happen to parse as
markdown links. Three files qualify today.

"This link is broken and I do not want to fix it" is not an admissible reason. Fix the link, or
delete it and keep the prose.

`scripts/readme-lint.sh` reads the same file, so the two checks cannot disagree about what
counts as an illustration.

### `scripts/markdown-slash-path-allowlist.txt` — hypothetical source paths (C12)

Slash-shaped paths permitted not to resolve. The bar is a path that is deliberately
hypothetical — a "create this file" instruction in a guide. Prefer naming the containing
directory instead, which resolves and needs no entry at all; that is why this file is currently
**empty**.

Both allowlists report entries that no longer match anything as an `INFO` line, so neither can
silently rot.

### `scripts/nolint-attribute-allowlist.txt` — in-source `nolint` attributes (C26)

Every in-source `nolint` attribute in the live tree, one entry per covered declaration, written
`<linter>:<declaration>` with the declaration named exactly as it appears at the attribute site.

This file exists because an in-source `nolint` produces **no linter finding at all**. It is not a
suppressed finding that a baseline diff can show; it is the *absence* of a finding, invisible to
the linter, to CI, to a `scripts/nolints.json` diff and to C16 alike — strictly less visible than
a row in a suppression file, which is at least a line someone can read. Asserting the file
against the tree is what turns each attribute back into such a line.

The admission bar is a **permanent documented exemption whose reason is written at the attribute
site in the source**: an auto-generated declaration with no source position at which a docstring
could be attached, a `Type`-valued structure that a `Prop` could not replace, a tactic token that
`docs/` already references as a user-facing name. "I do not want to rename this" and "the linter
is wrong about this in general" are both inadmissible. A temporary exemption belongs in an
`ENFORCE_` flag, where it is printed at every gate, never here. Entries that no longer match
anything are reported as an `INFO` line, on the same model as the two allowlists above.

### `scripts/debug-artifact-allowlist.txt` — live debug directives (C27)

One entry per library file that keeps live `#check`/`#eval`/`#print`/`#reduce`/`dbg_trace` lines,
written `<path> <exact live line count>` directly beneath a `#` reason line. The audit page
`FormalSystem/MainResults.lean` is the permanent resident: printing the axiom set of each headline
theorem is the page's purpose, and C21 asserts every name on it is pinned by C2 or C14.

The admission bar is a file whose directives exist **to be read by a person**, not to check a
value. A smoke test is inadmissible; move it to the test suite as a `#guard` or `#guard_msgs`.
A temporary entry says what it is pending, so the ratchet is visible at every gate. C27 fails on
an unlisted file, on a count that differs from the tree in either direction, on an entry without
a reason line, and on a stale entry, so the file cannot quietly become a dumping ground.

### `scripts/warning-budget.txt` — compiler-warning baseline (C28)

One entry per `<path> <linter>` pair, written `<count> <path> <linter>`, beneath a header block
of `# disposition <linter> <blocking|advisory|pending> <reason>` rows. The key is deliberately
neither a per-class scalar — which cannot catch one warning fixed and another introduced in the
same class — nor line-number-qualified, so an ordinary edit above a warning does not churn the
baseline.

**The counts are a ceiling and may only decrease.** Never regenerate the file to make a genuine
regression disappear: `--update` rewrites it wholesale from current findings and would bless the
regression along with everything else, the same failure mode C16's header warns about for
`scripts/nolints.json`. To retire a warning, fix it and let the count drop in the same commit as
the fix, with the `--update` diff visible in that commit.

Every linter class observed in the tree must carry a disposition row. A class with no row is
exit 2, not a silent pass — that guard is what stops a newly added linter class being absorbed
into the baseline by a routine `--update` without anyone reading it. `pending` marks a class
nobody has analysed yet and is an explicitly temporary value: the gate may not ship enforced
while any row reads `pending`. That is enforced in the script rather than left to a checklist,
because the textual check that suggests itself — `grep -c pending scripts/warning-budget.txt` —
can never reach 0: the file's own header legend has to explain what `pending` means, so the bare
word is always present and the check would pass vacuously forever. The honest textual form is
`grep -c '^# disposition .* pending '`.

Every **non-zero** entry must additionally carry a `#` reason line directly above it, the same
convention `scripts/debug-artifact-allowlist.txt` uses for C27, and the verifier exits 2 if one
does not. A residual warning nobody explained is indistinguishable from one nobody noticed, and
a baseline that absorbs warnings without saying why is precisely the failure this ratchet exists
to prevent. The tree currently carries 7 such entries, all in `DenseModelSurgery/`; the recorded
reason names the over-broad `variable` blocks behind them.

`advisory` classes are counted and reported but do not fail the gate. `linter.unusedTactic` and
`linter.unreachableTactic` are `blocking`, and for them a declaration-scoped
`set_option linter.unusedTactic false in` carrying a comment that records the deletion
experiment and its outcome is an accepted green resolution. The worked model in this tree is
`applyRule_branchingOrdered_rule`, whose comment names all twelve goals left unsolved when the
flagged tactic was deleted — the tactic is the alternative's *failure* mechanism, not dead code.
"fix" and "document why not" both pass, so gating the class never pressures a contributor into
deleting a load-bearing tactic.

C11 ships enforced, with no `ENFORCE_C11` flag: unlike C8/C9/C10 below, the invariant was
already true at the moment the check landed, so there was never a red phase to gate.

### `scripts/c20-declaration-baseline.txt` — recorded wrong-declaration citations (C20)

One key per line, `citer path | resolved target path | the citation's name chain`, for every
named line citation that lands outside the declaration it names and has not yet been repaired.
C20's declaration-span assertion gates every such citation that is **not** on this list, so a
new mismatch fails the day it appears while the recorded debt stays visible as a `TODO` line.

- A key carries **no line number**, on purpose: a legitimate re-anchoring pass moves a recorded
  citation's number without making it any more wrong.
- The file only ever shrinks. Repair a recorded citation with
  `python3 scripts/reanchor-lean-citations.py --by-name --files <target>`, read the diff, and
  delete its key; C20 reports a key that no longer fails.
- The ten keys that remain are citations whose name chain does not single out one declaration
  per anchor (two names before one anchor, or a name fragment such as `_correct`), which
  `--by-name` reports as `SKIPPED` rather than guess. They need a reader.
- Never add a key to quiet a new failure. Fix the number, name the declaration the line is
  really in, or cite the name with no line number at all.

## Adding a Check

Checks C8, C9, C10 and C9D describe end-state invariants that a tree in mid-reorganization
does not yet satisfy. Each is computed and reported from the outset but gated behind an
`ENFORCE_C<n>` variable near the top of the script; while the flag is 0 the check prints
a `TODO` line and does not affect the exit code. This makes progress visible without a
permanently-red gate.

`ENFORCE_C9_DOCS` (no task-number citations under `docs/`) followed this pattern: it defaulted
to 0 while the tree carried a three-figure citation count, two thirds of it in a single
historical file (`docs/development/PHASED_IMPLEMENTATION.md`, since deleted). It is now
enforced from the outset, the same as C8/C9/C10 above -- clearing the citations is the only
way past the check; the flag must never be flipped back to 0 to quiet a new one.

`ENFORCE_C16_ROOTS` is the live example of the pattern today, and it was added by the same change that added
C26. The env_linter batch had only ever been pointed at the `FormalSystem` library root, which
observes that root's import closure and nothing else — so every `lean_exe` root and the other
library root were unlinted, the same structural gap C25 closes for *compilation*, left open for
*linting*. It is not hypothetical: live `defsWithUnderscore` findings sit in an out-of-closure
module today while `runLinter FormalSystem` reports zero in the same breath. The widening lints
every root declared in `lakefile.toml`, but ships **reporting-only**, because the widened scope
was measured before the decision was taken and is not clean: enforcing it now would hold the gate
hostage to a burndown that change did not own, while abandoning it would leave the
elaboration-only shapes — above all auto-generated structure-field projections, where whether an
underscored name is a violation depends on whether the field's type is a `Prop` — with no
instrument at all. The count is printed at every gate rather than recorded here, for the reason
C14 exists. Flip the default to 1 once it reaches zero.

Both halves of C16 print, and the widened half does not relax the enforced one. Note also that
`lake exe runLinter <Module>` builds the runLinter *executable*, not the module named: the module
is read back from its `.olean`, so any root must be built before it is linted or the sweep
reports on a stale environment. That is why the loop builds each root first, and it is a mistake
the negative test caught rather than one reasoned about in advance.

C12, C13, C14 and C15 ship **enforced**, with no flags, because the work that cleared their debt
landed in the same change that added them. C14 has two halves: a content scan that always runs,
and a `#print axioms` half that skips cleanly under `--no-build` exactly as C2 does.

C24 ships enforced for the same reason, and was accepted only after the same **deliberate
negative test** C15 was: the `import FormalSystem.Init` line was removed from one low-fan-out
leaf, `FAIL C24` and a non-zero script exit were observed, and the line was restored and the
`PASS` re-observed. Re-run that test after any change to C24's scope or to
`scripts/CheckInitImportsMain.lean`'s exit path — the executable originally returned
`diff.length.toUInt32`, and an 8-bit exit status truncates that, so it would have printed a
failure while handing the shell a `0` at any count that happened to be a multiple of 256.

C25 ships enforced on the same precedent and was accepted only after the same negative test, run
deliberately on a module *other* than the one the same change repaired: a one-character break was
introduced in `BimodalTools/TraceExporterMain.lean` — not `ProofExtractorMain.lean`, since a
failure in the module under repair would prove nothing about the gate — `FAIL C25  1 of 13 lean_exe root module(s) do not compile` was observed
**together with a script exit of 1**, and the file was restored and the `PASS` and exit 0
re-observed. The sharpest part of that observation is what did *not* fail: C1 reported
`lake build exits 0` in the very same run, because the broken module is outside the closure
`lake build` walks — which is exactly the invisible-failure condition C25 exists to close. Re-run that test after any change to C25's scope or to its root-scraping regex, and
check the shell's exit status as well as the printed line: C24's history above is exactly a case of
a check that could print a failure while handing the shell a `0`.

C33 ships enforced on the same precedent, and was accepted only after deliberate negative tests
in **both** directions, because a byte comparison can fail two unrelated ways. A stray
module `_Scratch.lean` was added directly under the library directory: `FAIL C33 … 1 module(s) not imported` naming
`FormalSystem._Scratch` **and** a script exit of 1 were observed, with
`lake exe mk_all --lib FormalSystem --check` exiting 1 in the same state; the file was removed and
the `PASS` and exit 0 re-observed. Then one blank line was appended to `FormalSystem.lean` by
hand: `FAIL C33` reported a correct import *set* with differing bytes, again with exit 1 and
again agreeing with `mk_all --check`; `lake exe mk_all --lib FormalSystem` restored the file
byte-identically. Re-run both after any change to C33's `render`, and after any Mathlib bump —
the scanner mirrors `scripts/mk_all.lean` at the pinned tag, and the CI step running the real
`mk_all --check` is what notices if the two part ways.

C26 ships enforced on the same precedent, and was accepted only after **four** deliberate
negative tests, one per blind spot it closes, because a check answering four different routes
proves nothing about three of them if only one is exercised. A snake_case definition was
introduced in turn in an out-of-closure module, as an unlisted in-source `nolint` attribute, as a
name whose last component has the shape Mathlib's own test skips as autogenerated, and as a
`private` declaration; each time the printed `FAIL C26` line **and** a script exit of 1 were
observed together, and each seed was reverted and the `PASS` and exit 0 re-observed. One seed was
deliberately attribute-decorated so the scanner's regex was exercised beyond the plain-line case.
For the two routes exercised *inside* the linted closure, the sharpest observation is again what
did not fail: the env_linter half of C16 reported a clean `FormalSystem` in the very same run,
because neither shape produces a finding for it — which is exactly the invisible-failure
condition C26 exists to close.

That fourth round of testing also earned its keep. The first run of the route-1 test showed the
widened linter sweep reporting an *unchanged* count with the seed in place, while the same
command run by hand a moment later saw it: `lake exe runLinter <Module>` builds the runLinter
executable, not the module it is handed, so an out-of-closure root was being linted from a stale
`.olean` — silently, on precisely the modules the widening exists to cover. Building each root
before linting it fixed it, and the count then moved. Re-run all four tests after any change to
C26's scope, to its naming rule, or to the allow-list's format, and check the shell's exit status
as well as the printed line.

C15 was accepted only after a **deliberate negative test** — a scratch file citing a `thm:` anchor that
appears nowhere in the record was added under `docs/`, the gate was confirmed to fail with
`FAIL C15`, the file was removed, and the gate was confirmed to pass again. A check that
silently passes on everything is worse than no check, so run that test again after any change
to C15's scope or resolution source.

C31, C32 and C20's declaration-span assertion were each accepted only after a **deliberate
negative test** with both the printed `FAIL` line *and* the script's non-zero exit observed, then
reverted with `PASS` and exit 0 observed again:

- **C31** — the key of the Thomason citation in `FormalSystem/PlusLanguage/PlusLimitClosure.lean`
  was changed to one year later, a key `references.bib` does not hold. `FAIL C31` named the citer
  line and the key; exit 1.
- **C32** — the sibling link to `Commands.lean` in `FormalSystem/Automation/Tactics/Search.lean`
  was given a stale pre-rename `Logos` prefix. `FAIL C32` named the line and the target; exit 1.
- **C20 declaration span** — the anchor beside `HasAttainedSUP.toHasFaithfulDedekindSUP` in
  `FormalSystem/Metalogic/Expressiveness/Kamp/KMinusFaithfulRendering.lean` was moved ninety-three
  lines up, into a different declaration: the double-shift shape. Tier 1 stayed green; the
  declaration-span assertion failed, naming the declaration and its span; exit 1.

That last test earned its keep before it passed. Its first target was the pinned
`PriorExpressivenessDense.lean` citation, and retargeting it did **not** fail: that sentence states
its names on the far side of ordinary prose, so the citation has no name chain, and a wrong number
merely turned it from a passing citation into a residual one (the named count fell by one). That is
the design, not a bug — only a name standing *immediately before* a citation can fail it, because a
name elsewhere in the sentence is as often the thing doing the citing as the thing cited — but it
is the assertion's real limit, and it is why the name-less residual is printed at every gate. A
shift smaller than the named declaration's own span is likewise invisible to a span check;
`scripts/reanchor-lean-citations.py --recompute` is the repair for that case, and its `--selftest`
asserts the doubled-pass sequence end to end. Re-run all three tests after any change to a check's
scope, to the path-shaped filter, or to `scripts/lib/lean_citations.py`.

**Never flip an `ENFORCE_` flag back to 0 to make a gate pass.** Preventing exactly that
is why the flags are named and defaulted in the script rather than passed on the command
line.

## When to Run It

- After any file move, rename, or import change
- Before committing a change to the module structure
- Whenever you need a live file count — use C7's output rather than an ad-hoc `find`,
  which will get the Boneyard exclusion wrong

## Sibling scripts, not part of this harness

`scripts/check-metalogic-cycles.sh` is a standalone structural check with its own exit code,
deliberately not wired into `check-module-invariants.sh`. It makes **three assertions behind one
exit code**. A and B are independent of each other; C is implied by B today and is asserted
separately on purpose:

**A — the cycle count.** It enumerates the directory-level import edges inside
`FormalSystem/Metalogic/` — excluding sibling aggregators as edge *sources*, since an aggregator
importing its own directory is a convention artifact rather than a design cycle — and asserts the
cycle count is exactly **1**, the documented `BXCanonical` <-> `WeakCanonical` pair.

**B — the layer order.** It computes the library-wide *upward* import set (an import whose target
sits at a higher layer than its source) through `layer_of` in
`scripts/measure-refactor-partitions.py`, which it loads by path so there is exactly one copy of
the layer tables in the repository, and reads the graph through `scripts/lib/import_graph.py`'s
leading-import parser rather than assertion A's own regex. `layer_of` reads two tables: `LAYERS`,
keyed by top-level directory, and `LANGUAGE_FILE_LAYERS`, which layers the six language
directories (`MinusLanguage/`, `PlusLanguage/`, `StarLanguage/`, `OpenLanguage/`,
`HybridLanguage/`, `QuantLanguage/`) **file by
file**, because each holds syntax and semantics (the first three a proof system as well) and no
single layer fits it. It asserts that set **equals** a
recorded allowlist of 7 lines, all from
`FormalSystem/MinusLanguage/AxiomDischarge.lean` into `Theorems/*`. Sibling aggregators are
excluded as sources here too.

B has two further failure branches, both about the tables rather than the imports. **The lookup
fails loudly**: `layer_of` raises for any module under `FormalSystem/` that matches no row — a new
top-level directory, or a new file in a language directory — and B prints that as a `FAIL` line
naming the module and the table that needs the row. It returns `None` only for the bare root and
for modules outside the library. **A stale row fails**: a `LANGUAGE_FILE_LAYERS` row whose file
was renamed, moved or deleted is printed as a `STALE ROW`. Between them the per-file table cannot
drift from the tree in either direction. A `None` layer used to be the answer for an unmatched
path, and it cost a measurement: the three language directories went unmeasured, and the
allowlist read empty, until they were given rows.

**C — syntax before semantics.** Inside the six language directories, no layer-0 file (syntax
and proof system) imports a layer-1 file of any of the six, nor anything under
`FormalSystem/Semantics/`. Before the directories were merged the `Syntax/` – `Semantics/`
directory boundary enforced this; nothing structural does now. Such an import is already a
surplus line under B; C exists so the failure names the invariant, and so it survives a future
allowlist entry that would otherwise absorb the line. It fails, rather than passing vacuously,
if either set is empty.

```bash
bash scripts/check-metalogic-cycles.sh   # prints all three results; exit 1 if any fails
```

All three were negative-tested by hand on the real tree when they were added: an import of
`PlusLanguage/PlusTruth.lean` into `PlusLanguage/Formula.lean` (a surplus under B and a violation
under C), a deleted `Theorems` import in `MinusLanguage/AxiomDischarge.lean` (a shortfall), an
empty file in `PlusLanguage/` and one in a new top-level directory (both unlayered), and a bogus
per-file row (stale). Each exited 1 with the expected line. Re-run them after any change to the
tables or to `layer_of`.

The assertions exist for the same reason: each claim used to be prose that nothing checked.
The cycle count lived in [`FormalSystem/Metalogic/README.md`](../../FormalSystem/Metalogic/README.md)
and the layer order in [`ORGANISATION.md`](../../ORGANISATION.md); both were re-derived by hand
whenever someone needed to trust them, and both went stale.

**Neither assertion treats a shrinking finding as a pass.** Zero cycles is a failure: the
`BXCanonical` <-> `WeakCanonical` pair is expected to be present, so its disappearance is a
finding. Likewise B fails on a *shortfall* as well as a surplus — a missing allowlist line means
the work that removes it (PUBLICATION_REFACTOR.md Phase 5, the `{Plus,Minus,Star}Language` merges,
which move `AxiomDischarge.lean` out of `Syntax/`) has landed and the allowlist is now stale.

`scripts/measure-refactor-partitions.py` is the second sibling, with the same posture: not wired
into the harness, run directly, its own exit code. It regenerates every structural count the
publication refactor programme ([PUBLICATION_REFACTOR.md](PUBLICATION_REFACTOR.md)) and ADR-011
depend on, so that none of them is ever typed: the upward import edges through the layer table,
the `Metalogic/WeakCanonical/` partition into the proposed `Metalogic/Expressiveness/` set and the
residual, the Automation modules the library actually needs against the dataset tooling, and the
namespace-versus-directory audit. It reads the tree through `scripts/lib/import_graph.py`, which
parses only a file's *leading* `import` block — a naive `grep '^import'` also matches the usage
examples inside module docstrings and manufactures a self-cycle on the root aggregator — and
excludes the archive through `live_walk.py` exactly as the harness does.

```bash
python3 scripts/measure-refactor-partitions.py all          # every table, markdown
python3 scripts/measure-refactor-partitions.py all --json   # the same, machine-readable
python3 scripts/measure-refactor-partitions.py --check      # exit 1 if the Expressiveness set leaks
```

`--check` is the pre-move gate for the Expressiveness extraction: it passes only when the
proposed set has no import edge into the residual `WeakCanonical` modules and none into
`BXCanonical`. Never weaken it to make a move go through; if it fails, the edges it prints are
the work.

## Related Documentation

- [Metalogic architecture map](../../FormalSystem/Metalogic/README.md)
- [Module organization](MODULE_ORGANIZATION.md)
- [Library README](../../FormalSystem/README.md)

## A note on this file

C12, C14 and C15 scan `docs/`, and this file is in `docs/`. Prose here that names a hypothetical
source path, or quotes a stale count in the shape the tripwire matches, will fail the very
checks it documents. That is the checks working, not a false positive: all three were caught on
this page while it was being written. Cite a path that resolves, phrase a historical count so it
does not read as a current claim, and **do not write a literal unresolvable anchor** — describing
C15's negative test cost exactly one `FAIL C15` on this page before the sentence was reworded to
name the anchor's shape rather than spell one out.
