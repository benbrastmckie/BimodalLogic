# Research Report: Task #740

**Task**: 740 - Restate three KTypeSummary declarations over [Finite sig.preds] and retire their linter suppressions
**Started**: 2026-10-08T20:07:32Z
**Completed**: 2026-10-08T20:41:00Z
**Effort**: ~35 minutes research; implementation estimated at one short phase (under 60 lines of diff across five files)
**Dependencies**: None
**Sources/Inputs**: - Codebase, Mathlib search tools (leansearch/loogle/leanfinder/state_search), lean-lsp MCP, literature source (if applicable)
**Artifacts**: - specs/740_ktype_summary_finite_preds_restatement/reports/01_finite-preds-restatement.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All three declarations can be restated over `[Finite sig.preds]`, and all three should be.** A scratch probe (`Probe740.lean`, see Appendix) containing the three restated theorems compiled on the first attempt under the project's own linter set (`-Dweak.linter.mathlibStandardSet=true`), produced **zero linter output**, and reported the axiom profile `[propext, Classical.choice, Quot.sound]` for each. A control probe of the old `[Fintype][DecidableEq]` form without its suppression confirmed that both linters fire under identical flags, so the silence is a genuine negative.
- **The statement-fidelity constraint does not bind.** The `[Fintype sig.preds] [DecidableEq sig.preds]` binders on `kType_finite` and `exists_matching_factorization` were pinned in the substrate plan's `## Lean Challenge Statements` because they were "that site's" existing interface (the Ramsey chain's), not because the instance form was content under verification: the same pinned block states the two Phase-5 theorems over `[Finite sig.preds]`; the plan's own risk row (line 204) directs every new theorem toward `[Finite sig.preds]` with the `Fintype.ofFinite`/`Classical.decEq` preamble; `finite_family_triples` was never pinned at all (Phase 6 specifies it binder-free); the substrate summary's own `## Follow-ups` entry records the `[Finite]` form as "strictly stronger"; and no challenge snapshot (`specs/711_.../challenge/manifest.json`) exists for any `--check` to drift against. Decisively, the old pinned statement is an *instance* of the new one — the probe proves each old form as `example := new_theorem sig k …`. **Verdict: restate all three; none needs to stay pinned.**
- **The project's own warning policy already mandates this change.** `scripts/warning-budget.txt` lines 41-42 carry a `blocking` disposition for both linters — "drop the unused instance from the statement and supply it in the proof" — and `docs/development/LEAN_STYLE_GUIDE.md` lines 941-950 prescribe exactly `[Fintype X]` -> `[Finite X]`, drop `[DecidableEq X]`, `haveI := Fintype.ofFinite X` / `haveI := Classical.decEq X` in the proof, and say explicitly that `set_option … false in` "hides" the finding rather than fixing it.
- **Downstream propagation is zero consumer-code edits.** Both call sites of `finite_family_triples` (`RaySummary/Closure.lean:258-263` `hitSig_finite`, `RaySummary/SeamMulti.lean:236-240` `hit_finite`) invoke it under a local `[Fintype sig.preds]` (or the `twoLetter` `Fintype` instance at `SeamMulti.lean:182`), where `Finite sig.preds` is found by Mathlib's priority-900 instance `Finite.of_fintype` (`Mathlib/Data/Fintype/EquivFin.lean:170`); both shapes are verified in the probe. `kType_finite` has one in-tree caller (`finite_family_triples` itself). `exists_matching_factorization` has no in-tree caller. The axiom-pin test pins `#print axioms` output only — no signature appears in it — so it is unchanged (note: it now holds **33** pins, not the eleven the task description names; `finite_family_triples` is not among them). The aggregator, the seam interface, `docs/`, `typst/`, and the evidence probes mention the names in prose only or not at all.
- **Recommended file scope**: the three declaration files (declaration + its C29 reason-comment block + docstring prose), the cluster `README.md` (hand-maintained line-count rows), and one out-of-cluster comment in `RaySummary/Compose.lean:270` whose C29 reason cites `exists_matching_factorization`'s suppression as its precedent and would otherwise dangle. The test module is verify-only.

## Context & Scope

The task asks whether each of three headline theorems in `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` — `kType_finite` (`Basic.lean:117`), `exists_matching_factorization` (`Family.lean:224`), `finite_family_triples` (`Universal.lean:133`) — can be restated over `[Finite sig.preds]` with its paired `set_option linter.unusedFintypeInType false in` / `set_option linter.unusedDecidableInType false in` suppressions removed, **without** breaking statement fidelity against the substrate plan's pinned Challenge signatures; and what the signature change propagates to. Research was first-principles (no literature source governs a binder choice; the Thomas 1997 / Doets 1987 references in the cluster are background for the chain, not for this restatement). Line references were verified against the working tree at research time, which was clean under `FormalSystem/` and `Tests/` with no build in flight (`lake-build-guard.sh result`: `state=complete exit_status=0`).

Constraints honoured: no mathematics changed; no axiom introduced; the `k`-type kernel is not relocated; `InFamily`/`SegmentFactorization`/`Presents`/the seam bridge are not touched (see Decisions for why their `[Fintype]` binders are correctly out of scope).

## Findings

### Codebase Patterns

**The statements are already instance-free.** `KType sig k` is `abbrev KType … : Type := NormalForm sig k 0 → Bool` (`NEquivalence.lean:62`) with no instance binders; `kTypeOf` (`NEquivalence.lean:73`) is classical (`Classical.dec`); `segZ` (`Segment.lean:56`) and `zFiber` (`BlockDecomposition.lean:382`) carry none. So the *types* of all three theorems mention `sig.preds`'s instances nowhere — which is precisely the linters' finding, and why the `[Finite]` form type-checks unchanged.

**Only the proofs consume the instances**, through one gate: `normalFormFintype` (`Expressiveness/NormalForm.lean:199`) is `[Fintype sig.preds] [DecidableEq sig.preds] -> Fintype (NormalForm sig k n)`, built jointly with `DecidableEq` by one induction. Both are obtainable in-proof from `[Finite sig.preds]` by `Fintype.ofFinite` and `Classical.decEq`. The cluster already uses exactly this preamble: `Saturation.lean:133-139` (`kTypeOf_zFiber_eq_of_inFamily`) derives `Finite` from `Fintype` in the opposite direction with `haveI : Finite sig.preds := Finite.of_fintype _`, and `Segment.lean:74` (`kEquiv_zFiber_segSum`) is stated over `[Finite sig.preds]` already.

**The pinned-form landscape is already mixed.** Within the same cluster: `[Finite sig.preds]` on `kEquiv_zFiber_segSum`, `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple`, `inflate_left/right`; `[Fintype][DecidableEq]` on the three targets plus every declaration whose *type* mentions `InFamily` or `SegmentFactorization` (`family_cover`, `family_saturation`, `target_eq_union_of_families`, `kTypeOf_zFiber_eq_of_inFamily`, `HitSig`, `Hit`, `familyTriples`, …). The latter group is **not** linted — the instances are used in the type via `InFamily`'s own binders — which is why only the three targets (and `Compose.lean:277`'s `kTypeOf_listSeg_append_congr`) carry suppressions tree-wide.

**The Ramsey ingredient needs only `Finite`.** `Nat.exists_strictMono_const_pair_colour` (`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean:134`) is proved from `Finite.exists_infinite_fiber`, and `exists_zFactorization` (`Family.lean:104`) supplies the colour type's finiteness inline by `haveI : Finite (KType sig k) := by unfold KType; infer_instance`. Nothing in the cover chain is computational in `Fintype`.

**The linter's exact rule** (`.lake/packages/mathlib/Mathlib/Tactic/Linter/UnusedInstancesInType.lean:20-30, 306-366`): fires only on theorems (incl. `lemma` and `Prop`-class `instance`s), only for `Fintype` and `Decidable*` instance binders absent from the type. A `[Finite X]` binder is never linted, and the linter's own suggestion for `Fintype` is "replace with `Finite` and use `Fintype.ofFinite` in the proof". Both linters are enabled by `lakefile.toml:31` (`weak.linter.mathlibStandardSet = true`; set membership at `Mathlib/Init.lean:108-109`).

**Harness and gate surfaces that the change touches** (`scripts/check-module-invariants.sh`):
- C29 (every live `set_option linter.* false` carries a site reason naming the linter) and C30 (declaration-scoped only): both have **anti-silence guards that exit 2 on zero matched suppressions anywhere**. Tree-wide count today is **50** scoped `set_option linter.* false in` lines; removing six leaves 44 (34 `hashCommand`, 2 `unusedTactic`, the `Compose.lean` `unusedFintypeInType`, …), so the guard cannot trip.
- C28 (`scripts/warning-budget.txt`, baseline 0 warnings across 0 files): the restatements emit zero warnings (probe-verified), so the budget stays at zero.
- C16 (Batteries `unusedArguments`): the `[Finite sig.preds]` binder is used by the proof, so no finding.
- C14/C2/C21 (axiom pins, documented counts): profiles unchanged (probe-verified); no documented count moves.
- C9 (zero task-number citations under `FormalSystem/`): the new comment/docstring text must cite no task number — cite the style guide or the warning-budget disposition instead.
- `scripts/check-evidence-probes.sh` and `scripts/check-phantom-citations.sh`: no probe and no citation sweep target names any of the three; the names themselves are unchanged.

**Hand-maintained README counts.** `KTypeSummary/README.md` `## Modules` rows record `Basic.lean | 122`, `Family.lean | 238`, `Universal.lean | 162` (current `wc -l` agrees: 122/238/162). The table has no generator marker and the most recent correction in the tree was a docs commit by hand, so the implementation must re-measure after editing and update the three rows.

**Cross-references that become stale on removal** (prose only, but C29 requires reason comments to stay accurate):
- `Basic.lean:94-98` comment block and docstring lines `110-115` ("`[Finite sig.preds]` alone would suffice … binders kept as the interface every caller in the Ramsey chain already carries") — rewrite the docstring to state the `[Finite]` interface and the in-proof preamble; delete the comment block with the suppressions.
- `Family.lean:213-219` comment block says "Declaration-scoped, as for `kType_finite`" — delete with the suppressions.
- `Universal.lean:123-129` comment block says "`kType_finite` carries them, and `InFamily`/`SegmentFactorization` require them … as for `kType_finite` and `exists_matching_factorization`" — delete with the suppressions.
- `RaySummary/Compose.lean:264-272` reason comment ends "Declaration-scoped, as for `exists_matching_factorization` in `KTypeSummary/Family.lean`" — out of cluster, must be reworded (drop the precedent clause) so its C29 reason does not cite a suppression that no longer exists. Its own suppression is out of this task's scope (see Context Extension Recommendations).

### External Resources

- Mathlib `Finite.of_fintype`: `instance (priority := 900) Finite.of_fintype (α : Type*) [Fintype α] : Finite α` (`Mathlib/Data/Fintype/EquivFin.lean:170`) — the instance that makes every existing `[Fintype]`-context caller of a `[Finite]`-binder theorem elaborate unchanged.
- Mathlib `Fintype.ofFinite` / `Classical.decEq` — the noncomputable in-proof constructors; appropriate here because all three declarations are theorems.
- Mathlib linter source as cited above; the linter's docstring (`UnusedInstancesInType.lean:350-352`) is the authority that `[Finite]` + `Fintype.ofFinite` is the intended fix.
- `docs/development/LEAN_STYLE_GUIDE.md:941-950` and `scripts/warning-budget.txt:41-42` — the project's binding dispositions, both of which prescribe the restatement and reject suppression.

### Recommendations

**Restate all three; a sorry-free path exists and is verified.** Minimal, probe-verified diffs:

1. `Basic.lean` — delete lines 94-100 (comment block + two `set_option … in`); change the binder list to `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ)`; proof body becomes
   ```lean
   haveI := Fintype.ofFinite sig.preds
   haveI := Classical.decEq sig.preds
   unfold KType
   infer_instance
   ```
   Rewrite docstring lines 110-115 to say the statement is over `[Finite sig.preds]` and that `Fintype`/`DecidableEq` are supplied in the proof for `normalFormFintype`.
2. `Family.lean` — delete lines 213-219; binders `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ) (c : …)`; prepend the same two `haveI` lines to the existing body (which then calls `family_cover` at the local instances; the extracted segment-type equations are instance-free, so the conclusion is unchanged).
3. `Universal.lean` — delete lines 123-129; binders `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ)`; body unchanged (`haveI := kType_finite sig k; infer_instance`).
4. `KTypeSummary/README.md` — update the three `## Modules` line counts after `wc -l`.
5. `RaySummary/Compose.lean:270-271` — reword the precedent clause.
6. Verify: guarded scoped build of `FormalSystem.Metalogic.WeakCanonical.KTypeSummary`, `FormalSystem.Metalogic.Decidability.RaySummary`, `FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti`, and `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (then the full project for the final gate); `lean_verify` on the three fully-qualified names; `bash scripts/check-module-invariants.sh`; `bash scripts/check-evidence-probes.sh`; `bash scripts/check-phantom-citations.sh`; and `grep -rn "unusedFintypeInType\|unusedDecidableInType" FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` must return nothing.

Keep the `[Finite sig.preds]` binder rather than dropping it entirely (the linter's other suggestion): `KType sig k = NormalForm sig k 0 → Bool` is finite only through `normalFormFintype`, which needs `sig.preds` finite.

## Decisions

- **No declaration stays pinned.** Fidelity is a constraint against *weakening*; each restatement is strictly stronger and proves the old statement as an instance (probe `example`s). The pin's own record (plan risk row line 204; Phase 2/4/6 deviation notes at lines 397, 613, 787; summary `## Follow-ups` line 85) describes the `[Fintype]` form as retained for plan-compliance during the substrate task's life, not as verified content.
- **`InFamily` and `SegmentFactorization` keep `[Fintype][DecidableEq]`.** They are a `def` and a `structure` (never linted), and generalising them would ripple through `family_cover`, `family_saturation`, `target_eq_union_of_families`, `HitSig`, `Hit`, `familyTriples` and the seam bridge — the exact propagation the task forbids beyond what the three restatements force (which is nothing).
- **The axiom-pin test is verify-only.** It pins `#print axioms` text, which carries no binders; profiles are probe-verified unchanged.
- **The comment text replacing the suppressions cites durable anchors** (the style guide section, the warning-budget disposition), never a task number (C9, `no-task-references-in-deliverables.md`).

## Risks & Mitigations

- *Instance diamond in `exists_matching_factorization`'s proof*: `family_cover` is applied at the locally constructed `Fintype.ofFinite`/`Classical.decEq` instances, but every projected equation (`F.pos_type`, `F.neg_type`, `F.zero_type`) has an instance-free type, so the goal matches syntactically. Mitigation: verified by compile; no `convert` needed.
- *C29/C30 anti-silence guard*: 44 scoped suppressions remain tree-wide after removal; cannot trip. Mitigation: run the harness after the edit as the acceptance check.
- *Stale README line counts*: hand-maintained; the harness's inventory audit may flag drift. Mitigation: re-measure with `wc -l` after editing and update the three rows in the same commit.
- *Dangling precedent in `Compose.lean:270`*: its C29 reason would cite a vanished suppression. Mitigation: reword in the same commit; do not touch its own suppression.
- *Concurrent sibling task on the same tree* (dispatch territory note): re-read each of the five files immediately before editing; stage only the explicit file list; treat an unexpected build failure outside the file scope as possibly a sibling's in-flight edit.
- *Description's stale "eleven pins"*: the test has 33 `#print axioms` rows. Mitigation: the acceptance check is "all pins still match", independent of count.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Finite (KType sig k)` under `[Finite sig.preds]` | `haveI := Fintype.ofFinite sig.preds; haveI := Classical.decEq sig.preds; unfold KType; infer_instance` | success | `normalFormFintype`, `Pi.finite`/`Finite.of_fintype` via instance search |
| `∃ W τneg τzero τpos, …` (unbundled cover) under `[Finite sig.preds]` | same two `haveI` then existing `obtain … := family_cover sig k c; exact ⟨…⟩` | success | `family_cover` at local instances |
| `Finite (KType sig k × KType sig k × KType sig k)` under `[Finite sig.preds]` | `haveI := kType_finite' sig k; infer_instance` | success | `Finite.instProd` via instance search |
| old pinned `kType_finite` form | `exact kType_finite' sig k` | success | `Finite.of_fintype` (priority 900) |
| old pinned `exists_matching_factorization` form | `exact exists_matching_factorization' sig k c` | success | `Finite.of_fintype` |
| `hitSig_finite` / `hit_finite` call shapes (`[Fintype]` ctx, `twoLetter`) | `exact finite_family_triples' …` | success | `Finite.of_fintype`, `SeamMulti.lean:182` instance |
| control: old form without suppression | (elaboration) | both linters fire | `-Dweak.linter.mathlibStandardSet=true` |

## Context Extension Recommendations

- **Topic**: the same unused-`Fintype` pattern outside this task's scope.
- **Gap**: `RaySummary/Compose.lean:277` `kTypeOf_listSeg_append_congr` carries the identical declaration-scoped `unusedFintypeInType` suppression (its proof needs `Finite` via `k_equiv_of_iso`), and `warning-budget.txt`'s `blocking` disposition applies to it equally.
- **Recommendation**: record it as a one-declaration follow-up task (restate over `[Finite sig.preds]`; its callers `kTypeOfFin`/`kTypeOfFin_listSeg` sit in `[Fintype]` context and would elaborate unchanged by `Finite.of_fintype`), not as scope creep here.

## Appendix

- Scratch probes (session scratchpad, not committed): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/20e4b647-0c46-4812-b8c8-3b2978d42f6b/scratchpad/probe740/Probe740.lean` (three restatements, five derivability/call-shape `example`s, three `#print axioms`) and `Control740.lean` (old form unsuppressed). Command: `timeout 300 lake env lean -Dweak.linter.mathlibStandardSet=true -DautoImplicit=false <file>`; results: exit 0, no warnings, `[propext, Classical.choice, Quot.sound]` x3; control: both linters fire.
- Searches: repository `grep` sweeps for the three names across `FormalSystem/`, `Tests/`, `docs/`, `typst/`, `specs/evidence/`, `scripts/`, `.claude/`; binder landscape sweep for `[Finite sig.preds]`/`[Fintype sig.preds]`; tree-wide count of `set_option linter.* false in`; Mathlib source reads for the linter and `Finite.of_fintype`. No rate-limited search tool was needed — every name was resolved by direct source reads with the symbol index unused, so no `lean_local_search` evidence-tier caveat applies.
- References: `specs/711_universal_summary_substrate_stab_fibre/plans/02_buechi-chain-ktype-substrate.md` (lines 204, 234-240, 395-400, 611-616, 775-790, 1078-1130); `.../summaries/02_buechi-chain-ktype-substrate-summary.md` (lines 46, 54, 85); `.claude/rules/plan-compliance.md` ("Statement Fidelity"); `docs/development/LEAN_STYLE_GUIDE.md:935-952`; `scripts/warning-budget.txt:28-45`; `scripts/check-module-invariants.sh` header (C9, C14, C16, C28, C29, C30).
