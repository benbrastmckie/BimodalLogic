# Research Report: Task #668

**Task**: 668 - Clear the C34b residual and enforce ENFORCE_C34B
**Started**: 2026-09-24T00:00:00Z
**Completed**: 2026-09-24T00:00:00Z
**Effort**: medium
**Dependencies**: None (direct follow-up to the completed hypothesis-honesty-lint work)
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` (the C34 block, lines 5441-5806) — read in full
- `scripts/lib/lean_citations.py` (`decl_spans`, `DECL`), `scripts/lib/lean_debug_artifacts.py` (`mask`, `comments_only`)
- `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/Correspondence/Rigidity.lean`, `FormalSystem/Semantics/Correspondence/RigidityReal.lean`, `FormalSystem/Semantics/Extension/Constraint.lean`
- `docs/development/MODULE_INVARIANTS.md` (the C34 row), `docs/development/REFERENCE_NORMAL_FORM.md` (section 3)
- Re-measurement: the C34 census extracted verbatim and re-run; two purpose-built prototypes of the candidate discharge rule
**Artifacts**:
- `specs/668_clear_c34b_residual_enforce_c34b/reports/01_clear-c34b-residual-enforce.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Re-measured census (not quoted): 212 binder-carrying declarations in 46 files, 29 markers (22 omitting *Saturation*, 18 binder-carrying and discharged by delegation), 194 binder-carrying and unmarked, C34b residual 8, 630 live `.lean` files, 11988 declaration spans, 12 fixtures green.** Identical to the prior task's closing figures; `check-module-invariants.sh --no-build` exits 0 today with zero `FAIL` lines, and the C34 block alone exits 1 under `ENFORCE_C34B=1`. The tree has not drifted since the last close.
- **The route question has a decisive answer, and it is not the cost comparison the task description frames.** Two of the eight rows — `FrameOver.saturation` and `TaskFrame.saturation` — are **field re-exports**, and route (a) cannot reach them *even in principle*: any restatement of "the class supplies this field" must name `IsRegular`, and `delegates()` requires the twin to mention no bundling class at all. A second discharge rule is therefore **necessary**, not merely cheaper. Recommended shape: the narrowest possible one (a re-export rule), not a general projection rule.
- **The other six rows are all reachable by route (a), and the prior work's premise that "none has a binder-free declaration to delegate to" is wrong for two of them.** `FrameOver.reflection` already has `FrameOver.reflection_of_limit`, and `FrameOver.nullity` already has `TaskFrame.nullity_of_serial_limit` — both binder-free, both already cited in the docstrings of the rows that need them, both needing only a marker line. Route (a) therefore costs **three new declarations**, not eight restatements.
- **Cost is not the discriminator; genuine API value is.** The binder-free twin is usable at a non-regular frame, so route (a) adds real content wherever a twin is meaningful. A re-export twin would be a tautology, so only there does the gate rule earn its place. Recommended split: route (a) for six rows, the re-export rule for two.
- **Measured widening**: the broad projection rule the task description floats would make 41 of the 212 binder-carrying declarations auto-dischargeable; the narrow re-export rule makes 8. On the 11 declarations where the existing delegation rule and the projection rule both apply today, **they agree 11/11** — so the widening is consistent, but it is a widening, and the narrow form is available at no extra Lean cost.
- **One precondition found by measurement**: `example` blocks bleed into the preceding declaration's span (`example` is absent from both `DECL` and the C34 `TOPLEVEL` truncation), which pollutes `FrameOver.saturation`'s projection set with `F.serial` from the two trailing `example` lines and would make either new rule fail on it. Adding `example` (and `omit`, for robustness) to `TOPLEVEL` is **verdict-neutral on today's tree** (census and both verdicts unchanged, measured) and is required before either rule can be exact.

## Context & Scope

Researched: which remedy clears each of the eight C34b rows so that `ENFORCE_C34B=1` can be committed with both halves of C34 enforced, under the task's hard constraints (no blanket unbundling, no change to `IsRegular`'s fields, every original signature line byte-identical, the 194 untouched, the six genuine *Saturation* consumers untouched).

Out of scope and explicitly not investigated beyond confirming they are separate: `check-paper-definitions.sh` and `typst-sync-check.sh` Check 2.

Not researched: full `lake build` timing/greenness (the `--no-build` gate was run; C2's flagship axiom baselines require a build and are an implementation-time verification, see Risks).

## Findings

### Codebase Patterns

**The gate's two discharge facts (read from the source, not from the docs).** `c34a_violation` exempts a marked, binder-carrying declaration in exactly three circumstances: the marker omits nothing; the marker is `None`/`MALFORMED`; or `delegates(row, index)` holds. `delegates` holds when the declaration's **code** names an identifier that resolves (by full name **or bare last component**) to a marked declaration whose marker frozenset is **identical** and whose code mentions no bundling class anywhere in its span. Two consequences the plan must rely on:

1. The twin does not need to be a semantic twin — identity of the marker list plus absence of the class is the whole test. This is looser than the prose in `REFERENCE_NORMAL_FORM.md` section 3, which does not mention delegation at all.
2. A re-export of a class field can never delegate: its content *is* the class, so every candidate twin mentions `IsRegular` and fails `not cand_mentions`.

**The established restatement pattern, with nine worked instances.** `FormalSystem/Semantics/Extension/Constraint.lean` is the reference: `{name}_of_{constraints}` binder-free, then `{name} [F.IsRegular]` as a one-line corollary, **both carrying the same marker line**, with the corollary's statement and implicit-argument order unchanged. `nonempty_seg_of_compositional_limit` / `nonempty_seg_of_interpolates` (lines 456-491) is the closest analogue to the hardest of the eight rows: the twin takes `hcomp : TaskFrame.Compositional F.TaskRel` (full, not `Interpolates`) and reaches interpolation through `TaskFrame.interpolates_of_comp hcomp`, while the corollary passes `F.comp F.limit`. `TaskFrame.lean` already carries two pairs in the same shape: `eq_of_taskRel_zero_of_limit` / `eq_of_taskRel_zero` and `reflection_of_limit` / `reflection`.

**Per-row disposition.** Honest marker lists derived by reading each proof term:

| # | Row | Honest marker | Remedy | New decls |
|---|-----|---------------|--------|-----------|
| 1 | `Rigidity.lean: static_iff_uniformDwell` | Compositionality, Seriality, Limit | (a) new twin + body rewrite | 1 |
| 2 | `RigidityReal.lean: levels_closed` | Limit | (a) new twin, row becomes its corollary | 1 |
| 3 | `RigidityReal.lean: constant_of_countable_range` | Limit | (a) reuses row 2's twin; body routes through it | 0 |
| 4 | `TaskFrame.lean: FrameOver.saturation` | Saturation | **re-export rule only** | 0 |
| 5 | `TaskFrame.lean: FrameOver.nullity` | Seriality, Limit | (a) **existing** `TaskFrame.nullity_of_serial_limit` (line 939) + marker | 0 |
| 6 | `TaskFrame.lean: FrameOver.nullity_identity` | Seriality, Limit | (a) new twin | 1 |
| 7 | `TaskFrame.lean: FrameOver.reflection` | Limit | (a) **existing** `FrameOver.reflection_of_limit` (line 1335) + marker | 0 |
| 8 | `TaskFrame.lean: TaskFrame.saturation` | Saturation | **re-export rule only** | 0 |

Three new binder-free declarations in total, named per the established convention:
`FrameOver.static_of_uniformDwell_of_compositional_serial_limit` (Rigidity.lean),
`FrameOver.levels_closed_of_limit` (RigidityReal.lean),
`FrameOver.nullity_identity_of_serial_limit` (TaskFrame.lean).

**Row 1 is the only one with real proof work, and it is mechanical substitution.** `static_of_uniformDwell` (Rigidity.lean line 192) reaches exactly three projections: `F.interpolates` (→ *Compositionality*), `F.serial` (→ *Seriality*), `F.reflection` (→ *Limit*, itself `reflection_of_limit F F.limit`). The twin takes `hcomp`/`hser`/`hlim` and substitutes `TaskFrame.interpolates_of_comp hcomp`, `hser`, and `F.reflection_of_limit hlim` respectively — the same three substitutions `nonempty_seg_of_compositional_limit` already makes. `uniformDwell_of_static`, the other half of the biconditional, carries no binder and consumes nothing.

**Rows 5 and 7 need only a docstring line on a declaration that already exists**, and both rows' own docstrings already *name* that declaration ("via `TaskFrame.nullity_of_serial_limit`"; "this is `reflection_of_limit F F.limit`"). Verified: neither twin's span mentions a bundling class, so both satisfy `delegates`'s `not cand_mentions`; and marking a binder-free declaration can never itself trigger C34a (no binder) or C34b (no binder).

**Rows 4 and 8 are irreducible.** `FrameOver.saturation` is `theorem saturation (F : FrameOver D) [h : F.IsRegular] : TaskFrame.Saturation F.TaskRel := h.saturation`; `TaskFrame.saturation` is `F.toFibre.saturation`. Both docstrings trigger C34b by talking about what the Step Lemma **consumes** — a statement about *another* declaration, which is why the trigger is a false positive in substance while the honest marker (`Saturation`) is still the right record. `IsRegular`'s field set may not change (hard constraint), so the re-export cannot be dissolved.

### External Resources

No Mathlib search was needed: every declaration involved is local, the remedies are restatements of local hypotheses, and no new Mathlib lemma is required. `TaskFrame.interpolates_of_comp` (TaskFrame.lean line 911) and `Sierpinski.const_of_countable_range` are the only non-trivial callees and both already exist and are already used at the sites concerned.

### Recommendations

**1. Adopt both routes, split by whether a twin is meaningful — and implement the second rule in its narrowest form.**

The new C34a discharge should be a **field re-export rule**, stated as: *a declaration whose bound frame's own field projection is its entire proof term, and whose marker names exactly that one field, discharges C34a — a re-export of a field is not a claim about consumption.* Implementable predicate: parse the binder's subject from `\[\s*(?:(h)\s*:\s*)?(F)\.IsRegular\s*\]`, then require the body's `:=` tail to be a single term matching `<F|h>(\.[ident])*\.(comp|serial|limit|saturation)` and the marker to equal that one field's constraint. Surface: 8 declarations tree-wide (the four re-exports at `FrameOver`, the four at `TaskFrame`).

Do **not** adopt the broader "names exactly the class fields its marker lists" rule in this task. Measured, it would make 41 of the 212 binder-carrying declarations auto-dischargeable, and it introduces a distinct blind spot the delegation rule does not have: transitive consumption through a *called* declaration that carries its own `[F.IsRegular]` binder is invisible to a projection scan. Record it in `REFERENCE_NORMAL_FORM.md` as a considered-and-deferred option with those two measurements attached, so the next audit does not have to re-derive them.

**2. Add `example` (and `omit`) to the C34 `TOPLEVEL` truncation before adding the rule.** `example` is absent from `lean_citations.DECL`, so an `example` block always falls inside the preceding declaration's span. The two `example` lines at `TaskFrame.lean` 1239-1240 put `F.serial` inside `FrameOver.saturation`'s scanned body; without the truncation the re-export/projection scan sees `{Saturation, Seriality}` there and row 4 fails to discharge. Measured: adding `example`, or `example|omit`, leaves the census and both verdicts **byte-identical** on today's tree (212/46, 29, 22, 194, 18, C34b 8, `PASS C34a`), and no declaration today is binder-carrying *only* because of `example` bleed (measured: 0), so the census figure is not inflated and there is no live false positive to fix — only a latent one to close.

**3. Sequence the work so the gate stays green at every commit.** The gate is red the moment `ENFORCE_C34B=1` lands with a non-empty hit list, so the flag flip must be last. A safe order: (i) `TOPLEVEL` truncation + the re-export rule + its fixtures, verifying the census/verdicts are unchanged and `ENFORCE_C34B=1` still reports exactly 8; (ii) markers on rows 4 and 8 (residual 8 → 6, both discharged by the new rule); (iii) markers on rows 5 and 7 plus their existing twins (→ 4); (iv) the three new twins with rows 1, 2, 3, 6 rewritten as corollaries (→ 0); (v) `ENFORCE_C34B=1` plus the two doc updates. Each of (ii)-(iv) is an independently green, independently committable milestone whose acceptance is a census number, not a narrative.

**4. Extend the fixture self-test with must-fail cases for the new rule, not just must-pass.** The existing `_FIXTURES` list is the gate's own regression suite and the plan should treat additions to it as acceptance criteria. Minimum: a re-export whose marker names the projected field (must pass); a re-export whose marker names a *different* field (must fail); a declaration projecting two fields with a marker naming one (must fail); a declaration projecting one field with marker `None` (must fail); a re-export whose body applies a further lemma rather than being the bare projection (must fail — this is what keeps the rule narrow).

**5. Doc updates are corrections, not just additions.** `REFERENCE_NORMAL_FORM.md` section 3's C34a bullet currently reads "a marker whose list omits a constraint must sit over a declaration whose code does not carry the bundling class at all" — which omits the delegation escape that eighteen declarations already rely on. Both the delegation escape and the new re-export rule belong there, plus the deferred broad-projection option. `MODULE_INVARIANTS.md`'s C34 row needs its title changed from `C34a (enforced) / C34b (soft)` to both-enforced, the "C34b ships soft because…" and "Flip `ENFORCE_C34B=1` once the printed list is clear" sentences replaced with what was actually done, and the discharge vocabulary sentence extended.

**6. Check the signature-identity constraint mechanically, not by eye.** For each of the eight rows, diff the keyword line against the base blob:
`git show HEAD:FormalSystem/Semantics/TaskFrame.lean | sed -n '1234p'` against the working-tree line. Rows 1, 3 and 6 have *body* rewrites, which is where an accidental signature drift would hide.

**7. Keep the other six field re-exports out of scope.** Marking `FrameOver.comp`/`serial`/`limit` and their `TaskFrame` counterparts would make the re-export population uniformly marked and would exercise the new rule on all 8 of its surface, but none of them triggers C34b, none is required by DONE, and each is a declaration the hard constraints tell this task to leave alone. Record as a follow-up.

## Decisions

- **The first question is decided by necessity, not cost.** A second discharge rule is required, because rows 4 and 8 have no route-(a) remedy in principle. Recorded with the reason: `delegates()` requires the twin to mention no bundling class, and a re-export's every possible twin must name `IsRegular`.
- **Route (a) for the other six**, because the binder-free twin is usable at a non-regular frame and so adds API rather than only satisfying a gate — and because, measured, it costs three new declarations rather than the "eight restatements" the task description assumed.
- **The second rule ships in its narrow re-export form**, with the broad projection form documented as deferred and its widening measured (41 vs 8).
- **`ENFORCE_C34B=1` lands last**, in its own commit with the two doc updates.
- **No docstring will be reworded to duck the trigger.** Rows 4 and 8 are trigger false positives in substance (their sentences are about the Step Lemma's consumption, not their own), but the sanctioned remedy is still the marker line, and the marker is honest and informative there.
- **Recorded and rejected: marking rows 4 and 8 `Compositionality, Seriality, Limit, Saturation`.** This is a two-line change that needs no gate work at all — an all-four marker omits nothing and so is C34a-exempt — and it is the single most tempting wrong answer available. It is rejected because the marker's defined meaning is that the listed constraints are *the whole of what the elaborated term reaches*: `h.saturation` reaches one field, so an all-four marker on it is a false statement, and it would destroy exactly the audit value the form exists for. Flagged here so the plan can decline it explicitly rather than rediscover it under time pressure.

## Risks & Mitigations

- **A rule that silently admits what it was not meant to.** Mitigated by the narrow re-export form (surface 8, not 41), by exact marker/field matching (which fails closed under any incidental `.comp`/`.limit` in the body), and by must-fail fixtures. Residual, documented rather than fixed: transitive consumption through a binder-carrying callee is invisible to any code-scanning rule, including the delegation rule already in place.
- **C2's flagship axiom baselines require a build, so `--no-build` cannot clear them.** Rows 1, 3 and 6 change proof terms in `Semantics/`, upstream of the flagship theorems. Restating a hypothesis cannot introduce an axiom, so the expected delta is nil — but it must be *measured* with a full `lake build` plus the full gate before close, not assumed. Run the build detached under the bounded-waiter contract (`context/patterns/bounded-build-waiter.md`).
- **Span bleed defeating the new rule in a way that looks like the rule being wrong.** Mitigated by making the `TOPLEVEL` truncation its own first step with a verdict-neutrality check (measured above) before any marker lands.
- **`delegates` matching on a bare last component.** `nullity_of_serial_limit` and `reflection_of_limit` are unique in the tree, but the marker-identity requirement means a future same-named declaration with a different list would simply fail to discharge (fail-closed). No mitigation needed; worth one sentence in the plan so it is not mistaken for a bug later.
- **Scope creep into the 194.** Two of the recommended marker additions land on declarations outside the eight rows (`nullity_of_serial_limit`, `reflection_of_limit`). Both are binder-free, so neither is one of the 194 and neither is an unbundling; the plan should say so explicitly so the diff review does not read them as violations.
- **The two out-of-scope red gates being read as regressions.** `check-paper-definitions.sh` and `typst-sync-check.sh` Check 2 fail on the base commit. Confirmed: `check-module-invariants.sh --no-build` — the gate this task is judged by — exits 0 today with zero `FAIL` lines, so the two are cleanly separable and no waiver is needed.

## Tactic Survey Results

- Not applicable (no tactic survey performed). No goal in this task is closed by tactic search: the three new declarations are hypothesis-for-projection substitutions into proofs that already compile, and the four rewritten rows become one-line corollaries. The verification instruments here are the C34 census, the fixture self-test and `lake build`, not a tactic portfolio.

## Context Extension Recommendations

- **Topic**: the C34 discharge vocabulary as an extensible contract
- **Gap**: `REFERENCE_NORMAL_FORM.md` section 3 documents the marker's *meaning* but not the gate's *discharge rules* — it omits delegation entirely, which eighteen declarations already depend on. Any future third rule will hit the same gap.
- **Recommendation**: section 3 should carry a short enumerated list of the discharge rules with the measured surface of each, updated whenever a rule is added; the "considered and deferred" broad-projection option belongs in that list with its 41-row measurement, so the next audit starts from a number.

## Appendix

**Re-measurement method.** The C34 python block was extracted verbatim from `scripts/check-module-invariants.sh` and run standalone from the repository root, so every figure in this report is the gate's own output rather than a quotation. Two further prototypes were written against the same `scripts/lib` helpers: one computing, per declaration, the set of bundling-class fields projected out of the binder's own frame/instance name; one counting the widening surface of that rule across all binder-carrying declarations.

**Measurements recorded (all re-runnable).**
- Census: 212 binder-carrying declarations / 46 files; 29 markers, 22 omitting *Saturation*, 18 binder-carrying and delegating; 194 unmarked; 630 live `.lean` files; 11988 declaration spans; 12 fixtures green.
- `check-module-invariants.sh --no-build`: `ALL CHECKS PASSED`, exit 0, zero `FAIL` lines.
- C34 block with `ENFORCE_C34B=1`: exit 1 (the residual is the only thing standing between the flag and green).
- Projection sets of the eight rows: `levels_closed` {Limit}; `FrameOver.saturation` {Saturation}; `FrameOver.nullity` {Seriality, Limit}; `FrameOver.reflection` {Limit}; `TaskFrame.saturation` {Saturation}; `static_iff_uniformDwell`, `constant_of_countable_range`, `FrameOver.nullity_identity` project nothing.
- Marker-vs-projection over the 18 binder-carrying markers: 11 agree; the 7 that differ all carry all-four markers and are C34a-exempt regardless — so on every declaration where a discharge is actually needed, the two rules agree.
- Widening surface of the broad projection rule: 41 of 212 project a proper non-empty subset of the fields; 169 project none; 2 project all four.
- `example` bleed: 0 declarations are binder-carrying only because of it; adding `example` or `example|omit` to `TOPLEVEL` leaves every census figure and both verdicts unchanged.
- `omit` lines in `FormalSystem/`: 503, none mentioning `IsRegular`.

**Key source locations.**
- C34 block: `scripts/check-module-invariants.sh` 5441-5806 (`delegates` 5567, `c34a_violation` 5594, `c34b_trigger` 5612, `_FIXTURES` 5625, `TOPLEVEL` 5488, flags 744-746)
- The eight rows: `Rigidity.lean` 243; `RigidityReal.lean` 94, 144; `TaskFrame.lean` 1234, 1248, 1287, 1363, 2646
- Existing twins to mark: `TaskFrame.lean` 939 (`nullity_of_serial_limit`), 1335 (`reflection_of_limit`)
- The reference pattern: `Extension/Constraint.lean` 456-491 and 686-749
- Docs to update: `MODULE_INVARIANTS.md` line 51; `REFERENCE_NORMAL_FORM.md` 120-196
