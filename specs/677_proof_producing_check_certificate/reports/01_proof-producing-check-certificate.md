# Research Report: Proof-Producing check_certificate

- **Task**: 677 - Proof producing check certificate
- **Started**: 2026-09-27T00:00:00Z
- **Completed**: 2026-09-27T00:00:00Z
- **Effort**: ~4-6 hours implementation (5 phases, all proof obligations pre-verified)
- **Dependencies**: None
- **Sources/Inputs**:
  - Lean sources: `FormalSystem/Metalogic/Decidability/WitnessFamily/{Agreement,Predicates,Decide,Basic,Examples}.lean`, `BimodalTools/{CertificateImport,CheckCertificateMain}.lean`, `Tests/BimodalToolsTest/CertificateImportTest.lean`
  - In-repo precedent: `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` (`DecisionResult`), `FormalSystem/Metalogic/Decidability/Correctness.lean` (`sound_of_isValid`)
  - Wire contract: `BimodalTools/README.md` ("Certificate re-verification protocol")
  - Consuming repository (read-only): `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/{A2_GAP.md,TRUST_PIPELINE.md}`, `semantic/certificate.py`, `tests/unit/_certificate_model.py`, `tests/integration/test_certificate_lean_agreement.py`, `tests/unit/test_certificate_fixtures.py`
  - lean-lsp MCP `lean_run_code` probes (four; the last one is the full verified skeleton)
- **Artifacts**:
  - `specs/677_proof_producing_check_certificate/reports/01_proof-producing-check-certificate.md`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `WitnessFamily/Agreement.lean` (`joint_countermodel`), `WitnessFamily/Predicates.lean` (the four conditions), `WitnessFamily/Decide.lean` (the four `Decidable` instances)
- **Downstream Dependents**: `BimodalTools/CertificateImport.lean`, `BimodalTools/CheckCertificateMain.lean`, `Tests/BimodalToolsTest/CertificateImportTest.lean`, `BimodalTools/README.md`; consuming repository's `test_certificate_lean_agreement.py` and `_certificate_model.py`
- **Alternative Paths**: per-certificate kernel checking by generated-file re-elaboration (out of scope; see Findings)
- **Potential Extensions**: the canonical-wire/round-trip task, which is the other half of the consuming repository's route (f)

## Executive Summary

- **The whole design is already verified to compile, evaluate and be sorry-free with no new axioms.** A `lean_run_code` probe of the complete skeleton (bundled predicate + decidable instance + composition theorem + dependent outcome + erasure + output-contract soundness theorem) type-checks and `#eval`s to `{"status":"countermodel","time":0,"acceptance":"entailment"}` on the `posRaw` example family, and `#print axioms` reports only `[propext, Classical.choice, Quot.sound]`.
- **The cheapest decisive move is a theorem about the existing code, not a rewrite.** `refutes_of_countermodel`, stating that `checkRaw raw = .countermodel t` implies the joint existence statement, is provable against the *current, unmodified* `checkRaw` by `split`ting the `if ! decide …` chain and applying `of_decide_eq_true`. Verified. This alone machine-checks the composition the task says happens "in the reader's head".
- **Restructure `checkRaw` with nested `dite` rather than a bundled `dite`.** Nested `dite` on the four conditions individually gives exactly today's evaluation order and cost, keeps every localization scan in its own branch, and hands the accepting branch the four hypotheses directly. A single bundled `dite` on `Certifies` would force the rejecting path to re-decide the failing prefix to localize it.
- **The output-contract extension is purely additive and breaks nothing downstream.** Adding `"acceptance":"entailment"` to the `countermodel` line mirrors the tableau bridge's own `"gates"` precedent in `BimodalTools/README.md`. Verified against the consuming repository: every consumer reads named keys (`status`, `time`, `failed[].condition`) and never compares whole verdict dicts, so no consuming-side test breaks. The input wire schema is untouched.
- **The task's own opening claim needs one honest correction, which the report and the wire field should carry.** What this change buys is a *build-time kernel-checked implication* whose per-certificate hypothesis is supplied by compiled decision procedures. It is not a per-certificate kernel check. That is a real improvement (the composition becomes machine-checked and structurally unforgeable) but weaker than "acceptance of a certificate is a kernel-checked entailment" reads.
- **The downstream payoff is gated on the sibling wire/parser task, not on this task alone.** The consuming repository's `A2_GAP.md` route (f) names two halves: a proof-producing accepting branch (this task) *and* a parse echo compared against the bytes sent. The Python re-checker leaves the trust base only when both land.

## Context & Scope

Researched: how to make `lake exe check_certificate`'s accepting branch be the composition of the four decided conditions with `WitnessFamily.joint_countermodel`, what the output-contract extension should be, and what coordination the consuming side needs.

Constraints honored: zero-debt (no `sorry`, no new axiom, no deferral); no file edited (research phase only); the consuming repository read but never written; three sibling tasks dispatched on this same tree, so no build was started.

Current state, for the record:

- `BimodalTools/CertificateImport.lean:600-612` — `checkRaw` evaluates `@Decidable.decide _ (WitnessFamily.decidableLocalCoherentLab W)` and its three siblings behind `!`, discarding the `Decidable` instance's `isTrue h` payload, then returns `.countermodel raw.target.time`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean:228-247` — `joint_countermodel` already takes the four conditions as hypotheses and returns the existence statement. No new mathematics is needed; only the wiring.
- The "not a kernel-checked proof" disclaimer appears in four places on this side (`CertificateImport.lean:24`, `CertificateImport.lean:597`, `CheckCertificateMain.lean:28`, `README.md:160`) and once on the consuming side (`A2_GAP.md` section 9, "The honesty point").

## Findings

### Codebase Patterns

- **`DecisionResult` is the in-repo precedent to mirror.** `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:80-90` declares `inductive DecisionResult (φ : Formula) : Type` whose accepting constructor is `| valid (proof : ⊢ φ)` — a formula-indexed result type whose success case carries the witness. `Correctness.lean:107` then states `sound_of_isValid (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ`. The pair (indexed proof-carrying result + soundness theorem about the erased Boolean view) is exactly the shape this task needs, and `typst/chapters/p2-decidability-practice.typ:94` already documents that pattern as the project's load-bearing correctness guarantee.
- **No bundled four-condition predicate exists.** Greps for `Certifies`/`IsCertificate`/`Certified` across `FormalSystem/`, `BimodalTools/` and `Tests/` return nothing, so the bundle is new naming, not a rename.
- **The four instances compose under `instDecidableAnd` without help.** `dsimp only [Certifies]; infer_instance` discharges `Decidable (Certifies W t)`; `decidableTarget` takes `t` explicitly and is still found by instance resolution.
- **`joint_countermodel`'s two existing call sites tolerate a `def`-wrapped statement.** `Examples.lean:245` ascribes the literal `∃` type and `Examples.lean:264` destructures with `obtain`, so a `Refutes` abbreviation is definitionally transparent at both. Even so, the recommendation below leaves `joint_countermodel`'s signature untouched and adds `Refutes` alongside it, because additive is strictly lower risk and costs nothing.
- **Test blast radius on this side is two lines.** `Tests/BimodalToolsTest/CertificateImportTest.lean:95` and `:97` are the only rows mentioning `CheckResult.countermodel 0`; they become `CheckResult.countermodel 0 .entailment`. Every other row (rejections, error paths, round-trips) is untouched.

### Verified Lean Skeleton

All four probes ran through `lean_run_code` against the project's current oleans. The final probe (`Probe3`) contains the complete skeleton and is green with no warnings beyond style linters:

| Component | Home file | Statement / shape | Status |
|---|---|---|---|
| `WitnessFamily.Refutes Γ Δ` | `Agreement.lean` | the joint existence statement, named once | verified |
| `WitnessFamily.Certifies W t` | `Predicates.lean` | `LocalCoherentLab ∧ FulfillingLab ∧ BoxFaithful ∧ Target t` | verified |
| `decidableCertifies` | `Decide.lean` | `by dsimp only [Certifies]; infer_instance` | verified |
| `refutes_of_certifies` | `Agreement.lean` | `Certifies W t → Refutes Γ Δ`, term-mode from `joint_countermodel` | verified |
| `Acceptance` (`.decided` / `.entailment`) | `CertificateImport.lean` | `deriving Repr, Inhabited, DecidableEq` | verified |
| `CheckOutcome raw` | `CertificateImport.lean` | `\| countermodel (time : Int) (entails : Refutes raw.target.premises raw.target.conclusions)` | verified |
| `checkCertified raw : CheckOutcome raw` | `CertificateImport.lean` | nested `dite` on the four conditions, accepting branch applies `refutes_of_certifies` | verified, computable |
| `CheckOutcome.erase` | `CertificateImport.lean` | to the serializable `CheckResult` | verified |
| `refutes_of_countermodel` | `CertificateImport.lean` | `checkRaw raw = .countermodel t a → Refutes …` | verified (both against the new and the *current* `checkRaw`) |

Two evaluation results worth pinning as acceptance criteria:

- `#eval (checkRaw posRaw).toJson` produced `{"status":"countermodel","time":0,"acceptance":"entailment"}`.
- `#guard checkRaw' posRaw = checkRaw posRaw` held under the intermediate (unextended) probe — the restructure is behavior-preserving before the output field is added.
- `#print axioms` on the restructured `checkRaw` and on `refutes_of_countermodel`: `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no `Lean.ofReduceBool`.

### What the Change Does and Does Not Buy

Three distinct levels of assurance are in play, and the task description's framing conflates the first two:

1. **Today.** `decide` is discarded to `Bool`; the composition with `joint_countermodel` exists only in prose. Nothing prevents a future edit from returning `.countermodel` on three conditions instead of four.
2. **This task's deliverable.** The implication "these four conditions hold ⟹ a ℤ-time countermodel exists" is elaborated and kernel-checked once at build time; the accepting branch is a term of the existence type that cannot be written without the four hypotheses in scope; and `refutes_of_countermodel` states the guarantee at the level of the serialized verdict the consumer actually reads. The per-certificate hypothesis still comes from compiled decision procedures, so the trust base remains Lean's compiler plus this module's decoding. **The binary's runtime behavior and cost are unchanged.**
3. **Per-certificate kernel checking (out of scope).** Only achievable by re-elaborating each certificate: emit a generated `.lean` file with the family as literal data and a `by decide`-driven term, or build the `Expr` in-process and `addDecl` it against an imported environment. Both are honest (no extra axioms) and both are expensive — kernel whnf of the window scans over `Finset Formula`. `native_decide` is **not** an option: it moves the compiler into the trust base via `Lean.ofReduceBool`, a regression rather than an improvement, and would violate the zero-debt stance on axioms.

The report recommends stating level 2 plainly in all five disclaimer sites rather than deleting the disclaimers, and reserving `"acceptance":"kernel"` for level 3 should it ever be built.

### Output Contract and Consuming-Side Coordination

- **Additive, following the `"gates"` precedent.** `BimodalTools/README.md:72` records for the tableau bridge that `"status": "invalid"` and every pre-existing field are unchanged and `"gates"` is purely additive. The same discipline applies here: `{"status":"countermodel","time":0,"acceptance":"entailment"}`; `rejected` and `error` lines unchanged; **the input schema is not touched at all**, so the "field names are a breaking change surface" warning in the task description applies to the input wire and does not bite here.
- **Verified non-breaking downstream.** Consuming-side readers of the verdict, checked by grep: `iterate.py:424` (`verdict.get("status") != "countermodel"`), `tests/_lean_check.py:109` (same), `test_certificate_lean_agreement.py:81,110,125,153` (`verdict["status"]`, plus `failed[].condition` for rejections), `test_certificate_fixtures.py:85-88` (`status`, then `time`). None compares whole dicts, and `expected_verdicts.json` is consulted key-by-key. An added key is invisible to all of them.
- **The enum has two genuine producers, so the field is not a constant.** `"entailment"` is emitted by this binary; `"decided"` is what the consuming repository's pure-Python re-checker (`tests/unit/_certificate_model.py:347`, `semantic/certificate.py`'s `recheck`/`recheck_json`) can ever claim. An absent `acceptance` field must read as `"decided"` — that default-on-absence rule is what makes the change non-breaking for old binaries and stored verdicts, and it is the single most important line to communicate to the consuming side.
- **Consuming-side follow-ups to hand over (not this repo's work).** Add `"acceptance": "decided"` to `_certificate_model.py`'s and `recheck`'s countermodel verdicts; keep `test_certificate_lean_agreement.py`'s status comparison as-is and add an assertion that the Lean side reports `"entailment"` where Python reports `"decided"`; update `A2_GAP.md` section 9's "The honesty point" and route (f), and `TRUST_PIPELINE.md`'s two "What remains" rows, to record the half that has landed.
- **Payoff is jointly gated.** `A2_GAP.md` route (f) reads "Make Lean's accepting branch construct `joint_countermodel` directly from a decided hypothesis, **and** compare a Lean-side echo of the parsed wire against the bytes sent". The re-checker leaves the trust base only when the canonical-wire/round-trip work lands too. The report must say this rather than claiming the payoff outright.

### External Resources

No Mathlib search was required: every lemma used is either in this project (`joint_countermodel`, the four instances) or core (`of_decide_eq_true`, `instDecidableAnd`, `decide_eq_false_iff_not`). `lean_local_search`-level greps confirmed no pre-existing `Certifies`/`Refutes` name collision. The rate-limited search tools were therefore not consumed.

## Decisions

- Add `Refutes` and `refutes_of_certifies` **alongside** `joint_countermodel` rather than restating `joint_countermodel`'s type through `Refutes`. Additive, zero risk to the two existing call sites.
- Use **nested `dite` on the four conditions**, not one `dite` on the bundled `Certifies`. Preserves today's short-circuit order and cost; avoids re-deciding the failing prefix on the rejecting path.
- Keep `CheckResult` non-dependent and serializable (so `Repr`/`Inhabited`/`DecidableEq` deriving and all existing `#guard` rows survive), and introduce the dependent `CheckOutcome raw` as the layer above it, with `checkRaw raw := (checkCertified raw).erase`.
- Keep `checkLine : String → CheckResult` non-dependent. The outcome's index is the parsed `raw`, which does not exist before parsing, so the dependent layer belongs at `checkRaw` where the family exists.
- Extend the output line with an additive `"acceptance"` key on the `countermodel` status only, with `"decided"` as the reading of an absent field. Do not rename or remove anything, and do not touch the input schema.
- State level 2 honestly in every disclaimer site; do not delete the "not a kernel-checked proof" language, correct it.
- Reject `native_decide` outright as a route to per-certificate kernel checking.

## Recommendations

Prioritized, and phase-sized for one agent run each:

1. **Lean library additions** (`Predicates.lean`, `Decide.lean`, `Agreement.lean`): `Certifies`, `decidableCertifies`, `Refutes`, `refutes_of_certifies`, with module-header prose for each. All four verified. Update `WitnessFamily/README.md:50` and `Decidability/README.md:48` inventory rows in the same phase.
2. **`refutes_of_countermodel` against the unmodified `checkRaw`** (`CertificateImport.lean`). Landing this *first*, before any restructure, makes the composition machine-checked at the earliest possible commit and gives the restructure in step 3 a regression guard that fails the build if the accepting branch ever loosens. Proof script verified.
3. **Restructure the accepting branch** (`CertificateImport.lean`): `CheckOutcome raw`, `checkCertified` with nested `dite`, `CheckOutcome.erase`, `checkRaw := erase ∘ checkCertified`; re-prove `refutes_of_countermodel` in its now one-line form. Acceptance criterion: `checkRaw` is byte-identical in behavior to the pre-change version on the whole existing test corpus.
4. **Output contract** (`CertificateImport.lean`, `Tests/BimodalToolsTest/CertificateImportTest.lean`, `BimodalTools/README.md`, `CheckCertificateMain.lean`): `Acceptance`, the extended `CheckResult.countermodel`, `CheckResult.toJson`, the two test rows, and the protocol-section rewrite including the absent-field default rule.
5. **Honesty pass** on the five disclaimer sites listed in Context & Scope, replacing "not a kernel-checked proof" with the level-2 statement plus the named residual (compiled decision procedures, module decoding), and recording the jointly-gated payoff.
6. **Follow-up task to propose, not to do here**: per-certificate kernel checking by generated-file re-elaboration, which is what would make `"acceptance":"kernel"` real. Scope it separately; it needs a feasibility measurement (kernel whnf cost on a real fixture) before it can be costed.

Coordination hand-off for the consuming repository: the four bullets under "Consuming-side follow-ups" above. They are read-only findings here; nothing in `~/Projects/ModelChecker` was modified.

## Risks & Mitigations

- **Risk: the restructure silently changes a verdict.** Mitigation: land `refutes_of_countermodel` before the restructure (step 2 before step 3); keep every localization scan in the branch it already occupies; the existing `#guard` corpus plus `checkRaw' = checkRaw` equality is the acceptance criterion. Verified to hold in the probe.
- **Risk: `deriving` breakage from a `Prop` field.** Mitigation: the `Prop`-carrying constructor lives only on `CheckOutcome raw`, which derives nothing; `CheckResult` keeps `Repr, Inhabited, DecidableEq` and gains only an `Acceptance` field, itself deriving all three. Verified.
- **Risk: overclaiming in the prose.** The task description's first sentence ("acceptance of a certificate is a kernel-checked entailment") does not survive scrutiny as written. Mitigation: the level 1/2/3 framing above, carried into the disclaimer rewrite and the `acceptance` enum's reserved third value. This is a documented correction, not a scope reduction — the code deliverable is exactly what the task asks for.
- **Risk: cost regression on the rejecting path.** Mitigation: nested `dite` rather than bundled; recorded as a Decision.
- **Risk: sibling-task collision on this shared tree.** Tasks 679, 680 and 681 were dispatched in the same cycle with no declared `file_scope`. Mitigation: no file was touched during research; the implementation phase should re-read each target immediately before editing and stage only its own hunks, per `context/contracts/territory.md`.
- **Risk: the consuming side's Python re-checker and the Lean binary disagree on the new field.** Mitigation: the absent-field-means-`"decided"` rule, stated in `BimodalTools/README.md` as part of the protocol, so the two repositories can land in either order.

## Tactic Survey Results

Every proof obligation the plan will contain was discharged in a probe before writing this report. No obligation is left speculative.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Decidable (Certifies W t)` | `dsimp only [Certifies]; infer_instance` | success | the four landed instances via `instDecidableAnd` |
| `Certifies W t → Refutes Γ Δ` | term mode | success | `WitnessFamily.joint_countermodel W h.1 h.2.1 h.2.2.1 h.2.2.2` |
| `checkRaw raw = .countermodel t → Refutes …` (current `checkRaw`) | `unfold; split at h` ×5, `simp only [Bool.not_eq_true', decide_eq_false_iff_not, not_not]`, `of_decide_eq_true` | success | no extra premises |
| `checkRaw raw = .countermodel t a → Refutes …` (restructured) | `unfold; cases hco : checkCertified raw`, `rw [hco] at h; simp [CheckOutcome.erase] at h` | success | no extra premises |
| accepting branch computability | `#eval` on the `posRaw` example family | success | evaluates to `{"status":"countermodel","time":0,"acceptance":"entailment"}` |
| axiom hygiene | `#print axioms` | success | `[propext, Classical.choice, Quot.sound]` only; no `sorryAx`, no `Lean.ofReduceBool` |

## Context Extension Recommendations

- **Topic**: The proof-carrying-result pattern (`DecisionResult`/`sound_of_isValid`, and now `CheckOutcome`/`refutes_of_countermodel`) as a project idiom.
  - **Gap**: `context/project/lean4/` has no note on when to index a result type by its input and carry the witness in the accepting constructor versus stating a separate soundness theorem about an erased Boolean verdict. The distinction recurred three times in this codebase and was re-derived from scratch each time.
  - **Recommendation**: add `context/project/lean4/patterns/proof-carrying-verdicts.md` recording the two shapes, the `dite`-versus-`decide` reason the hypotheses survive in one and not the other, and the level 1/2/3 trust framing from this report.
- **Topic**: What a compiled `Decidable` verdict does and does not certify.
  - **Gap**: `context/project/lean4/tools/comparator-guide.md` covers the Comparator's trust model but nothing covers the `decide` / `by decide` / `native_decide` / re-elaboration ladder, which this task turned on entirely.
  - **Recommendation**: extend that guide, or add a sibling file, with the four-rung ladder and the explicit note that `native_decide` is a trust regression rather than a strengthening.

## Appendix

- **Probes run** (all via `lean_run_code`, against the project's current oleans, no file written): (1) bundled `Certifies` + `Accepted`/`Outcome` + erasure, green; (2) nested-`dite` form with `#eval`/`#guard` against the `posRaw` example family, green; (3) `refutes_of_countermodel` against the **unmodified** `checkRaw`, green; (4) the full skeleton including `Acceptance` and the extended JSON, green with the `#eval` output quoted in Findings.
- **Tooling note**: `lean_run_code` rejected multi-line structure-instance literals in the probes (`unexpected identifier; expected '}'` at the continuation line); single-line literals or `Structure.mk` worked. A probe artifact only — the real source files use multi-line literals throughout without trouble.
- **Line references** used above: `CertificateImport.lean:24,597,600-612`; `CheckCertificateMain.lean:28`; `BimodalTools/README.md:72,157-165`; `Agreement.lean:228-247`; `Predicates.lean` (the four condition definitions); `Decide.lean:865,879,922,926`; `DecisionProcedure.lean:80-90`; `Correctness.lean:107`; `Examples.lean:245,264`; `CertificateImportTest.lean:95,97`.
- **Consuming-repository references** (read-only): `A2_GAP.md` section 9 "The honesty point" and section 10 route (f); `TRUST_PIPELINE.md:263,272-273`; `semantic/certificate.py:361,459`; `tests/unit/_certificate_model.py:337-347`; `tests/integration/test_certificate_lean_agreement.py:60-160`; `tests/unit/test_certificate_fixtures.py:75-100`; `iterate.py:424`; `tests/_lean_check.py:72-109`.
