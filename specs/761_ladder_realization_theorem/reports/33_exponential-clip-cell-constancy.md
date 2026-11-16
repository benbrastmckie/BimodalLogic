# Research Report: Task #761

**Task**: 761 - ladder_realization_theorem
**Started**: 2026-11-16T15:00:00-08:00
**Completed**: 2026-11-16T15:12:26-08:00
**Effort**: one research dispatch; one scratch probe (521 lines) compiled against the tree
**Dependencies**: `reports/32_laddermodel-construction-falsifier.md` (overturn condition 3, the target); `reports/29_row-link-route-viability.md` (refutations taken as standing); `reports/31_gkwz-ptl-s5-quasimodels.md`; decision 25 in `.decisions.json`
**Sources/Inputs**: - Codebase (`RaySummary/CounterQuotient.lean`, `LadderModel.lean`, `RunLayer.lean`, `LadderAgree.lean`, `AnchorLayer.lean`, `LadderRealize.lean`), the wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` (the `dblC` section), the task record in `specs/state.json`, `grep` over `FormalSystem/`, `Tests/`, `specs/evidence/`, and `lake env lean` on one scratch file outside the repository. No Mathlib search tool and no literature source was needed or used.
**Artifacts**: - specs/761_ladder_realization_theorem/reports/33_exponential-clip-cell-constancy.md
**Standards**: report-format.md, subagent-return.md

**Marking convention.** **[VERIFIED]** = compiled this round or found by a `grep` this round, with the evidence named; **[INFERRED]** = follows from something verified, inference stated; **[UNSOURCED]** = neither. Every declaration name asserted to exist in the tree was checked with `grep -rnE '(theorem|lemma|def) +<name>\b'` over `FormalSystem/`, `Tests/`, `specs/evidence/` (Ruling 25). The names introduced by this round's scratch probe (`Probe761G.*`) exist ONLY in the Appendix and in the scratch file; they are in no file of the tree, and a grep of the tree for them returns nothing.

## Executive Summary

- **Verdict: REFUTED, at and above the exponential clip — and at every other clip that is a function of the formula alone.** [VERIFIED: compiled, exit 0, axioms `[propext, Classical.choice, Quot.sound]`]
- **The separating coordinate is still the clipped gap `n - c` (`kappa`'s fifth coordinate), but the mechanism is new: the gap threshold a formula reads scales with the OBJECT, not only with the formula's depth.** On an object whose idle stretch between two regions is forced to last exactly `m + 1` steps (no idle self-loop), the ONE fixed formula `chainC := ◇ (p U (¬p ∧ (¬p U (p ∧ X ¬p))))` — `dBack = 0`, `dFwd = 3`, no `snce` at all — separates gap `m + 1` from every larger gap. The register must fall to `0` across the remaining countdown plus the forced chain, which is possible iff `n - c ≤ m + 1`.
- **So for EVERY clip `B`** (no upper bound on it) and every `Tc`, `Tn`, `P`, the chain object with `m := B` carries two counter pairs of one `kappa`-class with different cells at `chainC` (`Probe761G.gap_clip_refuted_at_every_clip`). The instance at the filed `ParamsOk` tuple with the clip raised to `max (E chainC) 7` for an ARBITRARY `E : PlusFormula → ℕ` is `Probe761G.no_formula_only_clip`; the instance the question names, `E φ := 2 ^ (dBack φ + 1)`, is `Probe761G.exponential_clip_refuted`.
- **Why the `dblC` family could never have shown this.** Every prior fixture lives on the two-state object `Qc`, where an idle state may loop. The filed `Bof` reads the formula alone (`CounterQuotient.lean:854`; its own comment says "(K4) is the one parameter source that quantifies the FORMULA alone"), and `2 ^ (dBack φ + 1)` does too. The doubling (`dblC`) and the chain are independent lower bounds on the same coordinate: one grows with `dBack`, the other with `card Q`.
- **What is NOT refuted, stated precisely.** A clip that depends on the OBJECT as well as the formula — `B (Q, φ)` — is untouched: the chain family at `m` is silent at `B ≥ m + 2`, and `card Q = m + 3`, so any `B ≥ card Q` escapes it. Whether cells are constant at some `B (Q, φ)` is OPEN; this round neither proves nor refutes it, and names what a decisive probe would be (Findings F4).
- **Recommended approach**: record the exponential-clip rescue as failed with this compiled reason and proceed to the read-off / construction re-statement. Do not adopt an object-dependent clip untested; if it is to be considered at all, it is a separate attack-first round, and its cost is a signature change to `paramsOkK4`/`Bof`, not a change in the order of `K` (Findings F5).

## Context & Scope

Decision 25 obliges "a compiled verdict on whether `cellAt` is constant on `kappa`-classes at a clip of at least `2 ^ (dBack φ + 1)`, stated at the filed `ParamsOk` tuple". This round delivers the second of its two admissible outcomes. Read-only: no `.lean` source, plan or record was edited. One scratch file was compiled outside the repository; its complete source is in the Appendix. Reports 29 and 32 were read and not re-derived; none of their probes was recompiled, and nothing below depends on them.

One correction to the dispatch's orientation [VERIFIED by grep]: the `dblC` family, `dblC_cell_ne` (`:3254`) and `gap_clip_below_exponential_refuted` (`:3295`) are in `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`, not in `ladder-row-link-residue-obstruction.lean`. `no_keyed_cell_map_below_exponential` (report 32) is in no file of the tree; it exists only in report 32's appendix, as that report says.

## Findings

### Codebase Patterns

#### F1. What `dblC` needs at an exponential clip — and why that question was the wrong lever

`dblC j` reads the gap at `Kc j + 1 = 2 ^ (j + 1) - 1` with `dBack = j`, `dFwd = 3` (`Kc_eq`, `dBack_dblC`, `dFwd_dblC`; wired probe) [VERIFIED by grep; not recompiled]. At a clip `B ≥ 2 ^ (j + 1)` the pair it separates is no longer a `kappa`-collision, exactly as the probe's own header says. To beat an exponential clip on `Qc` one would need a formula reading the gap faster than `2 ^ dBack`.

On `Qc` that looks unobtainable [INFERRED, not compiled]: an idle state's only datum is its register; one backward region jump at most doubles a register ceiling (`nxt_le_double`, wired probe `:3018`), one forward region jump at most halves a register floor, and a guarded multi-region jump whose guard and target are definable one level down reaches no further than the larger of their thresholds doubled once. Each operator level therefore buys one doubling, never an iteration count. This is an argument about a search, not a proof of constancy, and it is recorded only to explain why the round did not pursue a tower family on `Qc`.

The lever that works is the other quantifier in the filed statement: the OBJECT. `ParamsOk` is stated for every finite `(Q, step, pend, lab)` (`CounterQuotient.lean:929`) [VERIFIED], while its fourth conjunct `paramsOkK4 φ B` (`:920`) and the witness `Bof` (`:854`) take no object argument that they read [VERIFIED: the definition of `Bof` is `max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`; the three object binders are documented there as unused]. Any clip of the form "at least `2 ^ (dBack φ + 1)`" inherits that. So it suffices to exhibit, for a fixed formula, objects on which the gap threshold is unbounded.

#### F2. The chain object and the fixed formula [VERIFIED, compiled]

Scratch probe, namespace `Probe761G` (Appendix). For each `m : ℕ`:

- **Object** `Qm m := Fin (m + 3)`: state `0` pending; states `1 … m + 1` an idle chain; state `m + 2` an idle sink. `stepM m`: the pending state steps to itself, to chain state `1`, or to the sink; chain state `k` steps ONLY to `k + 1`, and the last chain state ONLY to the pending state; the sink loops. `pendM m q := decide (q.val = 0)`, and the pending bit is the atom `pM` (`labM`), as on `Qc`.
- **Seriality** `fwdM`, `bwdM` are proved, so `ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)` and `MM m := ladderModel …` are the library's own frame and model at this object — no new frame, no new semantics.
- **Formula** `chainC := diaF coreC`, `coreC := p U (¬p ∧ oneC)`, `oneC := ¬p U (p ∧ X ¬p)`, in the primitive connectives. It does not mention `m`. `dBack_chainC : dBack chainC = 0` and `dFwd_chainC : dFwd chainC = 3` hold by `rfl`; `Bof_chainC : Bof … chainC = 7`.
- **Reading** (`truth_coreC`): `coreC` holds on a path at `t` iff the current region ends at an idle position `s`, and from `s` the path stays idle until a pending position `u` that is immediately followed by an idle one — i.e. the region entered next is a single position, i.e. the register at `u - 1` is `0` (the pin `c' = n` of `Count`).
- **Negative half** `coreC_false (m c n) (hgap : c + m + 2 ≤ n)`: on EVERY ladder path through `(0, c, n)`, `coreC` fails. The region ends exactly at `c + 1` (`cntAt_sub_of_pend`, `not_pend_of_count`); the chain invariant forces the last idle position `u - 1` to be chain state `m + 1`, at most `m` steps after `c + 1`; the register is `1`-Lipschitz (`nxtAt_lipschitz`), so at `u - 1 ≤ c + m + 1` it is at least `n - c - m - 1 ≥ 1`, not `0`.
- **Positive half**: the explicit path `gM m c` (count down, let the register fall at every step from position `0`, walk the chain, enter a single-position region, fall into the sink) is a ladder path (`gM_isPath`), passes through `(0, c, c + m + 1)` at `0` (`gM_zero`), and satisfies `coreC` there.
- **`chainC_cell_ne (m c n') (hgap : c + m + 2 ≤ n')`**: `cellAt (MM m) chainC (0, stM m c (c + m + 1)) 0 ≠ cellAt (MM m) chainC (0, stM m c n') 0`.

Non-vacuity [VERIFIED]: neither half is a statement about an empty set. The positive half exhibits a history; the negative half quantifies over every history through a state that has histories (seriality). The two cells are compared through `mem_cellAt_ladder_iff` (`LadderAgree.lean:2664`), the library's own characterisation.

#### F3. The refutation at every clip, and at the filed tuple [VERIFIED, compiled]

- `gap_clip_refuted_at_every_clip (B Tc Tn P : ℕ)`: there are `c n n'` with `n = c + (B + 1)`, `kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n')`, and `cellAt (MM B) chainC (0, stM B c n) 0 ≠ cellAt (MM B) chainC (0, stM B c n') 0`. No hypothesis on `B`: this is `gap_clip_below_exponential_refuted` with the bound `B + 1 ≤ 2 ^ (j + 1)` REMOVED, paid for by letting the object, not the formula, vary. Witness: `c := Tn`, `n := Tn + B + 1`, `n' := n + (P + 1)`.
- `no_formula_only_clip (E : PlusFormula → ℕ)`: with `B := max (E chainC) 7`: `E chainC ≤ B`; `Bof … chainC ≤ B`; `ParamsOk (stepM B) (pendM B) (labM B) chainC Tcof Tnof Pof B` holds (K1–K3 from `paramsOk_params`, `CounterQuotient.lean:938`; K4 because `7 ≤ B`); and a `kappa`-collision at exactly those four parameters has different cells. `E` is arbitrary: exponential, tower, anything computed from the formula.
- `exponential_clip_refuted`: the instance `E φ := 2 ^ (dBack φ + 1)`, the clip decision 25 names.

**The coordinate, named as the obligation asks.** Two states of one class: `(0, Tn, Tn + B + 1)` and `(0, Tn, Tn + B + 1 + (P + 1))` at the chain object with `B + 1` chain states. They agree on all five `kappa` coordinates — `min c Tc`, `c mod (P + 1)`, `min n Tn`, `n mod (P + 1)`, and `clipIdx B c n` (both gaps are `> B`, so both clip to `B`). They differ in the cell, and what the cell reads is the UNCLIPPED gap against the threshold `m + 1 = B + 1`: the same fifth coordinate as in reports 29 and 32, separated at a threshold set by the object's forced idle length rather than by `dBack`.

Scope of the theorem, stated plainly [VERIFIED for what is quantified]: for each clip the refuting OBJECT changes (`m := B`); the formula does not. This refutes every statement of the form "for all finite objects and all `φ`, cells are `kappa`-constant at `ParamsOk` with clip `E φ`". It does not refute a statement whose clip is allowed to read the object.

#### F4. The residual: an object-dependent clip is open, with the missing piece named

What survives is a clip `B (Q, φ)` with `B ≥ card Q` (at least) and `B ≥ 2 ^ (dBack φ + 1)` (at least). Status: **open** [nothing compiled either way].

- **The two lower bounds compose** [INFERRED, not compiled]: run `dblC`'s level reader on the chain object. An idle exit state with register `r` is followed by a forced chain of `m + 1` idle steps, so the next region has between `r - m` and `r + m + 1` positions, and one backward region jump takes a register ceiling `K` to about `2 K + 2 m`. Level `j` then reads about `2 ^ j · (m + 2)`. The honest lower bound on any surviving clip is therefore of order `card Q · 2 ^ dBack`, not the maximum of the two. This is one more scratch probe (the `lvlC` induction re-proved over `Qm m`, roughly the size of the wired `dblC` section) and was not built this round.
- **What a proof of constancy at `B (Q, φ)` would need** [INFERRED]: (i) a statement of which sets of idle registers are definable at each operator depth on an ARBITRARY finite object — the natural conjecture is "eventually periodic with period dividing `P + 1` and threshold `≤ T (Q, depth)`"; (ii) closure of that class under the four jump moves (forward/backward, step/region) and under `⊡`'s re-selection, with `T` solving the jump recurrences of report 29 F6; (iii) the same for pending states, where the gap is converted to an exit register. I found no statement of (i)–(iii) in the tree [INFERRED from reading the module headers and the probe index, not from an exhaustive search; the nearest compiled objects are probe-level: `stepFrag_gap_depth_exact` (`ladder-step-fragment-gap-depth.lean:1160`, step fragment only) and `nxt_le_double` (`ladder-cell-agreement-refutation.lean:3018`, on `Qc` only)]. This is the content of the closed-with-exclusions Phase 11.7, at a larger clip; it is a theorem-sized programme, not a missing lemma.
- **What a decisive refutation would look like**: an object and a formula whose cell is NOT eventually constant in the gap along a residue class — for instance a second, independent periodicity of the gap whose period is not forced into `P + 1` by (K1), or a threshold that depends on a quantity no finite parameter bounds. The chain family is not that: for each fixed `(Q, φ)` it has a finite threshold. An attack-first round should try objects with two chains of different lengths joined at the pending state, and objects whose pending region must traverse a cycle, before any proof attempt.

#### F5. Cost, whichever way the residual goes

- **The order of `K` would not change.** `K = card (CK Tc Tn P B) = (Tc + 1) · (P + 1)² · (Tn + 1) · (2 B + 1)` [VERIFIED: the definition of `CK`, `CounterQuotient.lean:156`]. `Tcof` already contains the factor `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Pof + 1) * (stabDepth sup + 1)` (`:820-825`) [VERIFIED], and `Tnof = Tcof + 2 * ell0`. So `K` is ALREADY exponential in the size of the formula and linear-or-worse in `card Q`, through `Tc` and `Tn`. A clip of order `card Q · 2 ^ dBack φ` multiplies `K` by one more factor of the same kind as two it already has [INFERRED: `dBack φ` is at most the number of `snce` subformulas, hence below the closure's cardinality — not compiled]. The worry "an exponential clip makes `K` exponential" is moot: it is exponential today.
- **What would change is the signature, and that is the real cost.** `paramsOkK4 (φ) (B)` and `Bof`'s body read the formula alone. An object-dependent clip makes (K4) quantify the object, which edits a pinned predicate (`ParamsOk`'s fourth conjunct), its discharge lemma `paramsOk_params`, and every statement carrying `ParamsOk` as a hypothesis. Under Statement Fidelity that is a user decision, not an implementation detail.
- **Downstream counts.** The task record's guardrail (c) says "no upper bound — `B` and the presentation size are counts". A larger `B` breaks no claimed bound, because none is claimed. It does enlarge `R_K`'s representative range `Tc + Tn + 3 * P + 2 * B + 5` (`CounterQuotient.lean`, the `repsCnt` docstring) and `Dmax`'s ambient set `Q × ClType φ × CK`, both of which are counts and neither of which is evaluated by `decide` at the fixpoint's parameters in the library [INFERRED from the parameters being `noncomputable`].
- **Usability.** Even if constancy at `B (Q, φ)` were proved, report 32's Step 1 stands: the construction half over `Dmax` is unwritten and `certStabK`/`certBoxK` of `Dmax` are unproved. The rescue would reopen the `(q, κ)`-keyed architecture; it would not supply it.

### External Resources

None consulted. The refutation is compiled against the library's own definitions.

### Recommendations

1. **Record the exponential-clip rescue as failed, with the compiled reason "the gap threshold scales with the object; no clip that reads the formula alone is constant on `kappa`-classes", and proceed to the read-off / construction re-statement.** Cite `gap_clip_refuted_at_every_clip`, `no_formula_only_clip`, `exponential_clip_refuted` (Appendix). [VERIFIED: PASS -- `lake env lean` on the scratch file from the repository root against the built tree, exit 0, no `sorry`, no `native_decide`, `#print axioms` on the four headline theorems gives `[propext, Classical.choice, Quot.sound]`. NOT run: `scripts/check-evidence-probes.sh`, which needs the file inside `specs/evidence/`; out of scope for a read-only round.]
2. **Wire the Appendix as a self-contained evidence probe** `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean`. It imports only `RaySummary.LadderAgree` and depends on no other probe (it re-proves the eight-line `kappa_collision_pos` locally). [VERIFIED: PASS -- the scratch file IS that standalone form and compiles, exit 0. NOT run: `check-evidence-probes.sh` on an in-tree copy.]
3. **Correct the scope sentence wherever the sub-exponential refutations are cited as "leaving the exponential clip open".** After this round the accurate sentence is: below `2 ^ (dBack + 1)` refuted on `Qc` (`gap_clip_below_exponential_refuted`); at every formula-only clip refuted on the chain family; an object-dependent clip open. [No compiled gate applicable]
4. **Do not adopt an object-dependent clip untested.** If the user wants the fibre EQUATION kept, the next step is one attack-first round on `B (Q, φ)`: first compile the composed lower bound (chain × doubling, F4), then attack with two-chain and cycle-in-region objects. Only a survived attack licenses a proof attempt, and that attempt is Phase 11.7 at a larger clip. [No compiled gate applicable]
5. **In any re-statement, do not carry a formula-only gap parameter as if it were an invariant of the model.** The same chain objects show that any certificate coordinate meant to be COMPLETE for the gap must read the object; the read-off / construction pair avoids the issue because it never asks for completeness (report 29 Q4, report 31). [No compiled gate applicable]

## Decisions

- Took the obligation's second branch (compiled refutation) once the object-dependence was seen; did not attempt a proof of constancy.
- Varied the OBJECT at a fixed formula rather than searching for a faster-growing formula family on `Qc`; F1 records why, as an inference.
- Stated the main theorem with no hypothesis on `B`, and the filed-tuple instance against an arbitrary `E : PlusFormula → ℕ`, so that no formula-only re-sizing re-opens it.
- Did not compile the composed (chain × doubling) lower bound; marked INFERRED.
- Did not recompile reports 29's or 32's probes; nothing here uses them.
- Reproduced the probe in the Appendix rather than writing into `specs/evidence/`.

## Risks & Mitigations

- **The probe is scratch-only and unwired.** `check-evidence-probes.sh` was NOT run. Mitigation: the Appendix is the complete file; it is self-contained; wiring is a copy.
- **The refutation changes the object with the clip.** A reader wanting "one object, every clip" will not find it here, and should not expect it: for a fixed `(Q, φ)` this family has a finite threshold. The verdict says so and F4 names the residual.
- **"The filed statement quantifies over all finite objects" is the load-bearing reading.** [VERIFIED for `ParamsOk` and `ladderModel`, which take arbitrary `Q`.] If the intended theorem restricts the object class so that idle states always loop, the chain family is excluded — but no such restriction is in `ParamsOk`, `LadderCons` or the task record, and (K3)'s `tIdle` exists precisely because idle runs are object-dependent.
- **F1's "no tower on `Qc`" and F4/F5's inferences are not compiled.** Nothing in the verdict depends on them.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `stepM` membership with one `Fin` literal endpoint | `simp only [stepM, decide_eq_true_eq]; omega` | fail | `simp` reduces a conjunct to `True`, which `omega` does not read; use `exact decide_eq_true (Or.inr (Or.inl ⟨by omega, hm, rfl⟩))` |
| `stepM` on two abstract path positions (hypothesis) | `simp only [stepM, decide_eq_true_eq] at h; omega` | success | N/A |
| `objN m c v = 0 ↔ …` (nested `if` on integers) | `unfold objN; split_ifs <;> constructor <;> intro h <;> first \| omega \| exact h.elim` | success | plain `omega` fails on the branch whose hypothesis is `False` |
| `Drift` / `Count` side conditions of the explicit path | `unfold …; split_ifs <;> omega` | success | after `simp only [pendM, decide_eq_true_eq]`, with the two `objN_eq_zero_iff` instances in context |
| `t + 1 < s` from the strict-`untl` witness | `omega` | fail | the order hypothesis is `<` only up to unfolding the frame's order; pass it to a helper lemma stated on `ℤ` (`int_succ_lt_of_ne`), as the wired probe does |
| chain invariant along an idle stretch | induction on the offset, `omega` after unfolding `stepM` at the step hypothesis | success | invariant `val = m + 2 ∨ k + 1 ≤ val` |

## Context Extension Recommendations

- **Topic**: which quantifier of a parametrised statement to attack.
- **Gap**: four rounds varied the formula on one fixed two-state object and scoped their refutations by formula depth; nothing in the Lean or logic context says to vary the object when a parameter is claimed to depend on the formula alone.
- **Recommendation**: a short pattern note under the logic context (edited at its source store, not in the deployed tree): "for a parameter claimed to be a function of X alone, hold X fixed and vary everything else the statement quantifies over, before growing X".

## Verdict

**Is `cellAt` constant on `κ`-classes at a clip of at least `2 ^ (dBack φ + 1)`? REFUTED.**

- At the filed `ParamsOk` tuple with the clip raised to `max (2 ^ (dBack φ + 1)) 7` — and to `max (E φ) 7` for any `E` of the formula alone — there is a finite object, a formula with `dBack = 0` and `dFwd = 3`, and two counter pairs of one `kappa`-class with different cells. [VERIFIED, compiled: `exponential_clip_refuted`, `no_formula_only_clip`]
- **Separating coordinate: the gap `n - c`**, read at the threshold "length of the object's forced idle stretch", which no function of the formula bounds.
- The filed fibre equation is therefore not rescued by any re-sizing of `Bof`. The task goes to the read-off / construction re-statement with a compiled reason.
- **Residual, open, with the missing piece named**: constancy at an OBJECT-dependent clip `B (Q, φ)` of order at least `card Q · 2 ^ dBack φ`. Missing: a closure theorem for definable register sets on arbitrary finite objects (F4). Decisive probe: the composed chain × doubling lower bound, then two-chain and cycle-in-region attack objects.

**Cost note.** An object-dependent exponential clip would not change the order of `K`, which is already exponential in the formula through `Tc`; it would change the SIGNATURE of (K4) and `Bof`, which today read the formula alone, and it would still leave the construction half over `Dmax` unwritten. No claimed bound is broken, because the task claims none.

**What would overturn this verdict.**
1. The scratch probe failing to compile when wired — re-run it; it uses only library declarations.
2. A showing that the filed theorem's object class excludes forced idle chains. Nothing in `ParamsOk`, `LadderCons` or the task record does; it would be a new hypothesis and a re-statement in its own right.
3. A showing that "a clip of at least `2 ^ (dBack φ + 1)`" was meant to allow the clip to read the object. Then this round refutes only the formula-only reading and the question is F4's open residual — with every clip up to `card Q - 2` refuted by compilation here and a lower bound of order `card Q · 2 ^ dBack` inferred.
4. A showing that `ParamsOk` at `Tcof/Tnof/Pof` is not "the filed parameter conditions"; as in report 32, that would be a finding about `paramsOk_params`, not about this probe.

## Appendix

### Method

- Greps (over `FormalSystem/`, `Tests/`, `specs/evidence/`): present — `gap_clip_below_exponential_refuted`, `dblC_cell_ne`, `kappa_collision_pos`, `no_fibre_equation_over_kappa` (all in `ladder-cell-agreement-refutation.lean`), `paramsOk_params`, `mem_cellAt_ladder_iff`, `cellAt_eq_cellAt`, `cntAt_sub_of_pend`, `not_pend_of_count`, `nxtAt_lipschitz`, `cntAt_eq_nxtAt_of_idle_pend`, `isLadderPath_components`, `objAt_step`, `exists_hist_of_isLadderPath`, `exists_isLadderPath_of_hist`, `short_idle_threshold_refuted` (`counter-lift-gates.lean:1959`); absent — `no_keyed_cell_map_below_exponential`, `chainC`, `gap_clip_refuted_at_every_clip`, `no_formula_only_clip`, any `Probe761G`.
- Compile: `lake env lean <scratch>/chain_clip_probe.lean` from the repository root, about 10 s, exit 0, no `error`, no warning, no `sorry`, no `native_decide`.
- Scratch location (not durable): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d795962e-60ab-47a6-9397-2d3f4a621ce2/scratchpad/chain_clip_probe.lean`, sha256 prefix `1211ed8e579d9ded`. The text below is that file verbatim.
- `scripts/check-evidence-probes.sh` was NOT run on the probe (scratch-only, unwired).

### Axiom output

```
'Probe761G.chainC_cell_ne' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761G.gap_clip_refuted_at_every_clip' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761G.no_formula_only_clip' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761G.exponential_clip_refuted' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Probe source (complete, self-contained)

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761G

/-! ### The chain object: one pending state, a FORCED idle chain of `m + 1` states, one sink -/

/-- States: `0` pending; `1 … m + 1` the idle chain; `m + 2` an idle sink. -/
abbrev Qm (m : ℕ) : Type := Fin (m + 3)

def pendM (m : ℕ) : Qm m → Bool := fun q => decide (q.val = 0)

/-- The pending state loops, exits into the chain's first state or into the sink; a chain state
has exactly ONE successor (the next chain state, and the pending state from the last one); the
sink loops. No idle chain state has a self-loop: the idle stretch between two regions is forced
to last exactly `m + 1` steps. -/
def stepM (m : ℕ) : Qm m → Qm m → Bool := fun i j =>
  decide ((i.val = 0 ∧ (j.val = 0 ∨ j.val = 1 ∨ j.val = m + 2)) ∨
    (1 ≤ i.val ∧ i.val ≤ m ∧ j.val = i.val + 1) ∨
    (i.val = m + 1 ∧ j.val = 0) ∨
    (i.val = m + 2 ∧ j.val = m + 2))

def pM : Atom := ⟨"p", none⟩

def labM (m : ℕ) : Qm m → Atom → Bool := fun q at_ => decide (at_ = pM ∧ q.val = 0)

theorem labM_pM (m : ℕ) (q : Qm m) : labM m q pM = pendM m q := by
  simp [labM, pendM]

theorem pendM_iff (m : ℕ) (q : Qm m) : pendM m q = true ↔ q.val = 0 := by
  simp [pendM]

theorem pendM_false_iff (m : ℕ) (q : Qm m) : pendM m q = false ↔ q.val ≠ 0 := by
  simp [pendM]

/-! ### Seriality -/

theorem fwdM (m : ℕ) : ∀ (t : ℤ) (x : LadderState (Qm m) (pendM m)),
    ∃ y, RladAdm (stepM m) (pendM m) t x y := by
  rintro t ⟨⟨q, c, n⟩, h⟩
  have h' : q.val ≠ 0 → c = 0 := fun hq => h ((pendM_false_iff m q).mpr hq)
  have hq := q.isLt
  by_cases h0 : q.val = 0
  · rcases Nat.eq_zero_or_pos c with hc | hc
    · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m q ⟨m + 2, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨m + 2, _⟩) c n 0
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · simp [stepM, h0]
      · simp [Count, pendM, hc]
    · refine ⟨⟨(⟨0, by omega⟩, c - 1, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
      show stepM m q ⟨0, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨0, _⟩) c n (c - 1)
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · simp [stepM, h0]
      · simp [Count, pendM, h0]; omega
  · by_cases hm : q.val ≤ m
    · refine ⟨⟨(⟨q.val + 1, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m q ⟨q.val + 1, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨q.val + 1, _⟩) c n 0
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · exact decide_eq_true (Or.inr (Or.inl ⟨by omega, hm, rfl⟩))
      · simp [Count, pendM, h0]
    · by_cases hm1 : q.val = m + 1
      · refine ⟨⟨(⟨0, by omega⟩, n, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
        show stepM m q ⟨0, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
          Count (pendM m q) (pendM m ⟨0, _⟩) c n n
        refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
        · exact decide_eq_true (Or.inr (Or.inr (Or.inl ⟨hm1, rfl⟩)))
        · simp [Count, pendM, h0]
      · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
        show stepM m q ⟨m + 2, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
          Count (pendM m q) (pendM m ⟨m + 2, _⟩) c n 0
        refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
        · exact decide_eq_true (Or.inr (Or.inr (Or.inr ⟨by omega, rfl⟩)))
        · simp [Count, pendM, h0]

theorem bwdM (m : ℕ) : ∀ (t : ℤ) (x : LadderState (Qm m) (pendM m)),
    ∃ y, RladAdm (stepM m) (pendM m) (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, h⟩
  have h' : q.val ≠ 0 → c = 0 := fun hq => h ((pendM_false_iff m q).mpr hq)
  have hq := q.isLt
  by_cases h0 : q.val = 0
  · refine ⟨⟨(⟨0, by omega⟩, c + 1, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
    show stepM m ⟨0, _⟩ q = true ∧ (pendM m ⟨0, _⟩ = false → c + 1 = 0) ∧ Drift n n ∧
      Count (pendM m ⟨0, _⟩) (pendM m q) (c + 1) n c
    refine ⟨?_, fun hp => absurd hp (by simp [pendM]), Or.inl rfl, ?_⟩
    · simp [stepM, h0]
    · simp [Count, pendM, h0]
  · have hc : c = 0 := h' h0
    subst hc
    by_cases h1 : q.val = m + 2
    · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m ⟨m + 2, _⟩ q = true ∧ (pendM m ⟨m + 2, _⟩ = false → 0 = 0) ∧ Drift n n ∧
        Count (pendM m ⟨m + 2, _⟩) (pendM m q) 0 n 0
      refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
      · exact decide_eq_true (Or.inr (Or.inr (Or.inr ⟨rfl, h1⟩)))
      · simp [Count, pendM, h0]
    · refine ⟨⟨(⟨q.val - 1, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m ⟨q.val - 1, _⟩ q = true ∧ (pendM m ⟨q.val - 1, _⟩ = false → 0 = 0) ∧
        Drift n n ∧ Count (pendM m ⟨q.val - 1, _⟩) (pendM m q) 0 n 0
      refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
      · simp only [stepM, decide_eq_true_eq]; omega
      · simp [Count, pendM, h0]

/-- The ladder model of the chain object. -/
noncomputable abbrev MM (m : ℕ) :
    TaskModel (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame :=
  ladderModel (stepM m) (pendM m) (fwdM m) (bwdM m) (labM m)

/-- The pending ladder state `⟨(0, c, n), _⟩`. -/
def stM (m c n : ℕ) : LadderState (Qm m) (pendM m) :=
  ⟨((⟨0, by omega⟩ : Qm m), c, n), fun hp => absurd hp (by simp [pendM])⟩

/-! ### The formula: FIXED, independent of `m` -/

def nxtF (ψ : PlusFormula) : PlusFormula := .untl .bot ψ
def andF (a b : PlusFormula) : PlusFormula := PlusFormula.neg (.imp a (PlusFormula.neg b))
def diaF (ψ : PlusFormula) : PlusFormula := PlusFormula.neg (.stab (PlusFormula.neg ψ))

/-- "The region entered next is a single position": `¬p U (p ∧ X ¬p)`. -/
def oneC : PlusFormula :=
  .untl (PlusFormula.neg (.atom pM)) (andF (.atom pM) (nxtF (PlusFormula.neg (.atom pM))))

/-- `p U (¬p ∧ oneC)`: at the end of the current region, the region entered next is a single
position. -/
def coreC : PlusFormula := .untl (.atom pM) (andF (PlusFormula.neg (.atom pM)) oneC)

/-- **THE SEPARATING FORMULA**, one formula for every object of the family: `◇ coreC`. -/
def chainC : PlusFormula := diaF coreC

theorem dBack_chainC : dBack chainC = 0 := rfl
theorem dFwd_chainC : dFwd chainC = 3 := rfl

theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

section truth
variable {m : ℕ}

theorem truth_andF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (a b : PlusFormula) :
    PlusTruthAt (MM m) τ t (andF a b) ↔ PlusTruthAt (MM m) τ t a ∧ PlusTruthAt (MM m) τ t b := by
  show ((PlusTruthAt (MM m) τ t a → (PlusTruthAt (MM m) τ t b → False)) → False) ↔ _
  tauto

theorem truth_nxtF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (MM m) τ t (nxtF ψ) ↔ PlusTruthAt (MM m) τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

theorem truth_diaF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (MM m) τ t (diaF ψ) ↔
      ∃ σ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame,
        τ.state t = σ.state t ∧ PlusTruthAt (MM m) σ t ψ := by
  show ((∀ σ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame,
    τ.state t = σ.state t → (PlusTruthAt (MM m) σ t ψ → False)) → False) ↔ _
  constructor
  · intro h
    by_contra hn
    exact h (fun σ e hψ => hn ⟨σ, e, hψ⟩)
  · rintro ⟨σ, e, hψ⟩ h
    exact h σ e hψ

theorem truth_p (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (s : ℤ) :
    PlusTruthAt (MM m) τ s (.atom pM) ↔ pendM m (objAt g s) = true := by
  show labM m (τ.state s).2.1.1 pM = true ↔ _
  rw [hτ s]
  show labM m (objAt g s) pM = true ↔ _
  rw [labM_pM]

theorem truth_np (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (s : ℤ) :
    PlusTruthAt (MM m) τ s (PlusFormula.neg (.atom pM)) ↔ pendM m (objAt g s) = false := by
  show (PlusTruthAt (MM m) τ s (.atom pM) → False) ↔ _
  rw [truth_p τ g hτ s]
  cases pendM m (objAt g s) <;> simp

/-- The semantic content of `coreC` on a history read as a ladder path. -/
theorem truth_coreC (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt (MM m) τ t coreC ↔
      ∃ s : ℤ, t < s ∧ pendM m (objAt g s) = false ∧
        (∃ u : ℤ, s < u ∧ pendM m (objAt g u) = true ∧ pendM m (objAt g (u + 1)) = false ∧
          ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false) ∧
        ∀ r : ℤ, t < r → r < s → pendM m (objAt g r) = true := by
  show (∃ s : ℤ, t < s ∧ PlusTruthAt (MM m) τ s (andF (PlusFormula.neg (.atom pM)) oneC) ∧
      ∀ r : ℤ, t < r → r < s → PlusTruthAt (MM m) τ r (.atom pM)) ↔ _
  have hone : ∀ s : ℤ, PlusTruthAt (MM m) τ s oneC ↔
      ∃ u : ℤ, s < u ∧ pendM m (objAt g u) = true ∧ pendM m (objAt g (u + 1)) = false ∧
          ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false := by
    intro s
    show (∃ u : ℤ, s < u ∧
        PlusTruthAt (MM m) τ u (andF (.atom pM) (nxtF (PlusFormula.neg (.atom pM)))) ∧
        ∀ r : ℤ, s < r → r < u → PlusTruthAt (MM m) τ r (PlusFormula.neg (.atom pM))) ↔ _
    constructor
    · rintro ⟨u, h1, h2, h3⟩
      rw [truth_andF, truth_nxtF, truth_p τ g hτ, truth_np τ g hτ] at h2
      exact ⟨u, h1, h2.1, h2.2, fun r a b => (truth_np τ g hτ r).mp (h3 r a b)⟩
    · rintro ⟨u, h1, h2, h3, h4⟩
      refine ⟨u, h1, ?_, fun r a b => (truth_np τ g hτ r).mpr (h4 r a b)⟩
      rw [truth_andF, truth_nxtF, truth_p τ g hτ, truth_np τ g hτ]
      exact ⟨h2, h3⟩
  constructor
  · rintro ⟨s, h1, h2, h3⟩
    rw [truth_andF, truth_np τ g hτ, hone] at h2
    exact ⟨s, h1, h2.1, h2.2, fun r a b => (truth_p τ g hτ r).mp (h3 r a b)⟩
  · rintro ⟨s, h1, h2, h3, h4⟩
    refine ⟨s, h1, ?_, fun r a b => (truth_p τ g hτ r).mpr (h4 r a b)⟩
    rw [truth_andF, truth_np τ g hτ, hone]
    exact ⟨h2, h3⟩

end truth

/-! ### Negative half: gap above `m + 1` -/

/-- On EVERY ladder path through `(0, c, n)` with `n ≥ c + m + 2`, `coreC` fails: the region ends
at `c + 1`, the forced chain reaches the next pending state at most `m + 1` steps later, and the
register cannot fall to `0` by then. -/
theorem coreC_false (m c n : ℕ) (hgap : c + m + 2 ≤ n)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hg : IsLadderPath (stepM m) (pendM m) g)
    (h0 : g 0 = stM m c n)
    (s : ℤ) (hs0 : 0 < s) (hsidle : pendM m (objAt g s) = false)
    (u : ℤ) (hsu : s < u) (hup : pendM m (objAt g u) = true)
    (hu1 : pendM m (objAt g (u + 1)) = false)
    (hmid : ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false)
    (hguard : ∀ r : ℤ, 0 < r → r < s → pendM m (objAt g r) = true) : False := by
  have hobj : objAt g 0 = (⟨0, by omega⟩ : Qm m) := by rw [objAt, h0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, h0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, h0]; rfl
  have hp0 : pendM m (objAt g 0) = true := by rw [hobj]; simp [pendM]
  have hend := not_pend_of_count g hg 0 hp0
  -- the region ends exactly at `c + 1`
  have hs' : s = (c : ℤ) + 1 := by
    rcases lt_trichotomy s (0 + (cntAt g 0 : ℤ) + 1) with hlt | heq | hgt
    · have := (cntAt_sub_of_pend g hg 0 hp0 s.toNat (by omega)).1
      rw [show (0 : ℤ) + ((s.toNat : ℕ) : ℤ) = s by omega] at this
      exact absurd (this.symm.trans hsidle) (by simp)
    · rw [heq, hcnt]; ring
    · exact absurd ((hguard _ (by omega) hgt).symm.trans hend) (by simp)
  -- the chain invariant
  have hchain : ∀ k : ℕ, s + (k : ℤ) < u →
      (objAt g (s + (k : ℤ))).val = m + 2 ∨ k + 1 ≤ (objAt g (s + (k : ℤ))).val := by
    intro k
    induction k with
    | zero =>
      intro _
      right
      have := (pendM_false_iff m _).mp hsidle
      simp only [Nat.cast_zero, add_zero]
      omega
    | succ k ih =>
      intro hk
      have hprev := ih (by push_cast at hk; omega)
      have hstep := objAt_step g hg (s + (k : ℤ))
      have hidle := (pendM_false_iff m _).mp (hmid (s + ((k + 1 : ℕ) : ℤ)) (by push_cast; omega) hk)
      rw [show s + ((k + 1 : ℕ) : ℤ) = s + (k : ℤ) + 1 by push_cast; ring] at hidle ⊢
      simp only [stepM, decide_eq_true_eq] at hstep
      omega
  -- the last idle position before `u`
  have hlast : (objAt g (u - 1)).val = m + 1 := by
    have hstep := objAt_step g hg (u - 1)
    rw [show u - 1 + 1 = u by ring] at hstep
    have hupz := (pendM_iff m _).mp hup
    have hidle : (objAt g (u - 1)).val ≠ 0 := by
      apply (pendM_false_iff m _).mp
      by_cases he : u - 1 = s
      · rw [he]; exact hsidle
      · exact hmid (u - 1) (by omega) (by omega)
    simp only [stepM, decide_eq_true_eq] at hstep
    omega
  have hk := hchain (u - 1 - s).toNat (by omega)
  rw [show s + (((u - 1 - s).toNat : ℕ) : ℤ) = u - 1 by omega] at hk
  have hbound : u - 1 ≤ (c : ℤ) + m + 1 := by omega
  -- the register at `u - 1` is `0`
  have hidle' : pendM m (objAt g (u - 1)) = false := by
    rw [pendM_false_iff]; omega
  have hup' : pendM m (objAt g (u - 1 + 1)) = true := by
    rw [show u - 1 + 1 = u by ring]; exact hup
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (u - 1) hidle' hup'
  rw [show u - 1 + 1 = u by ring] at hpin
  have hcu : cntAt g u = 0 := by
    have h := (isLadderPath_components g hg u).2.2.2
    simp only [Count, hup, hu1] at h
    simpa using h.2
  have hlip := nxtAt_lipschitz g hg 0 (u - 1).toNat
  rw [show (0 : ℤ) + (((u - 1).toNat : ℕ) : ℤ) = u - 1 by omega] at hlip
  omega

/-! ### Positive half: gap exactly `m + 1` -/

def objN (m c : ℕ) (v : ℤ) : ℕ :=
  if v ≤ (c : ℤ) then 0 else if v ≤ (c : ℤ) + m + 1 then (v - c).toNat
  else if v = (c : ℤ) + m + 2 then 0 else m + 2

def cntN (c : ℕ) (v : ℤ) : ℕ := ((c : ℤ) - v).toNat

def regN (m c : ℕ) (v : ℤ) : ℕ := if v ≤ 0 then c + m + 1 else ((c : ℤ) + m + 1 - v).toNat

theorem objN_lt (m c : ℕ) (v : ℤ) : objN m c v < m + 3 := by
  unfold objN; split_ifs <;> omega

theorem objN_eq_zero_iff (m c : ℕ) (v : ℤ) :
    objN m c v = 0 ↔ v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2 := by
  unfold objN; split_ifs with h1 h2 h3 <;> constructor <;> intro h <;> first | omega | exact h.elim

/-- The witnessing path: count down, let the register fall at every step from `0` on, walk the
chain, enter a single-position region, fall into the sink. -/
def gM (m c : ℕ) : ℤ → LadderState (Qm m) (pendM m) := fun v =>
  ⟨((⟨objN m c v, objN_lt m c v⟩ : Qm m), cntN c v, regN m c v), by
    intro hp
    have hne : objN m c v ≠ 0 := (pendM_false_iff m _).mp hp
    have := objN_eq_zero_iff m c v
    show cntN c v = 0
    unfold cntN
    omega⟩

theorem gM_pend_iff (m c : ℕ) (v : ℤ) :
    pendM m (objAt (gM m c) v) = true ↔ v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2 := by
  rw [pendM_iff]; exact objN_eq_zero_iff m c v

theorem gM_idle_iff (m c : ℕ) (v : ℤ) :
    pendM m (objAt (gM m c) v) = false ↔ ¬ (v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2) := by
  rw [← gM_pend_iff]; cases pendM m (objAt (gM m c) v) <;> simp

theorem gM_isPath (m c : ℕ) : IsLadderPath (stepM m) (pendM m) (gM m c) := by
  intro u
  show stepM m ⟨objN m c u, _⟩ ⟨objN m c (u + 1), _⟩ = true ∧
    (pendM m ⟨objN m c u, _⟩ = false → cntN c u = 0) ∧
    Drift (regN m c u) (regN m c (u + 1)) ∧
    Count (pendM m ⟨objN m c u, _⟩) (pendM m ⟨objN m c (u + 1), _⟩) (cntN c u) (regN m c u)
      (cntN c (u + 1))
  have e0 := objN_eq_zero_iff m c u
  have e1 := objN_eq_zero_iff m c (u + 1)
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp only [stepM, decide_eq_true_eq]
    unfold objN
    split_ifs <;> omega
  · intro hp
    have hne : objN m c u ≠ 0 := (pendM_false_iff m _).mp hp
    unfold cntN
    omega
  · unfold Drift regN
    split_ifs <;> omega
  · unfold Count
    simp only [pendM, decide_eq_true_eq]
    unfold cntN regN
    split_ifs <;> omega

theorem gM_zero (m c : ℕ) : gM m c 0 = stM m c (c + m + 1) := by
  apply Subtype.ext
  show ((⟨objN m c 0, _⟩ : Qm m), cntN c 0, regN m c 0) = ((⟨0, _⟩ : Qm m), c, c + m + 1)
  have h1 : objN m c 0 = 0 := (objN_eq_zero_iff m c 0).mpr (Or.inl (by omega))
  have h2 : cntN c 0 = c := by unfold cntN; omega
  have h3 : regN m c 0 = c + m + 1 := by unfold regN; simp
  simp only [h1, h2, h3]

/-! ### The cells differ -/

/-- **THE CELLS DIFFER AT THE CHAIN LENGTH.** At the pending state of the chain object, the gap
`m + 1` and every gap above it have different cells at the FIXED formula `chainC`. -/
theorem chainC_cell_ne (m c n' : ℕ) (hgap : c + m + 2 ≤ n') :
    cellAt (MM m) chainC
        ((0, stM m c (c + m + 1)) :
          (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0
      ≠ cellAt (MM m) chainC
          ((0, stM m c n') :
            (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0 := by
  intro heq
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath (fwdM m) (bwdM m) (gM m c) (gM_isPath m c)
  -- a realized type at gap `m + 1` containing `chainC`
  have hT : tpOf (MM m) chainC σ 0 ∈ cellAt (MM m) chainC
      ((0, stM m c (c + m + 1)) :
        (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0 :=
    (mem_cellAt_ladder_iff (fwdM m) (bwdM m) (labM m) chainC _ 0 _).mpr
      ⟨gM m c, σ, gM_isPath m c, gM_zero m c, hσ, rfl⟩
  have hin : chainC ∈ tpOf (MM m) chainC σ 0 := by
    rw [mem_tpOf_iff]
    refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
    show PlusTruthAt (MM m) σ 0 (diaF coreC)
    refine (truth_diaF σ 0 coreC).mpr ⟨σ, rfl, ?_⟩
    rw [truth_coreC σ (gM m c) hσ 0]
    refine ⟨(c : ℤ) + 1, by omega, ?_, ⟨(c : ℤ) + m + 2, by omega, ?_, ?_, ?_⟩, ?_⟩
    · rw [gM_idle_iff]; omega
    · rw [gM_pend_iff]; omega
    · rw [gM_idle_iff]; omega
    · intro r h1 h2; rw [gM_idle_iff]; omega
    · intro r h1 h2; rw [gM_pend_iff]; omega
  -- transport to the other cell and contradict
  rw [heq] at hT
  obtain ⟨g, τ, hg, hg0, hτ, hTeq⟩ :=
    (mem_cellAt_ladder_iff (fwdM m) (bwdM m) (labM m) chainC _ 0 _).mp hT
  rw [← hTeq, mem_tpOf_iff] at hin
  obtain ⟨σ', he, hcore⟩ := (truth_diaF τ 0 coreC).mp hin.2
  obtain ⟨k, g', hg', hp'⟩ := exists_isLadderPath_of_hist (fwdM m) (bwdM m) σ'
  have h0 : ((0, g 0) : (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState)
      = (0 + k, g' 0) := (hτ 0).symm.trans (he.trans (hp' 0))
  have hk : (0 : ℤ) = 0 + k := congrArg Prod.fst h0
  have hk0 : k = 0 := by omega
  subst hk0
  have hp'' : ∀ v : ℤ, σ'.state v = (v, g' v) := fun v => by rw [hp' v, add_zero]
  have hg'0 : g' 0 = stM m c n' := ((congrArg Prod.snd h0).symm).trans hg0
  rw [truth_coreC σ' g' hp'' 0] at hcore
  obtain ⟨s, hs0, hsidle, ⟨u, hsu, hup, hu1, hmid⟩, hguard⟩ := hcore
  exact coreC_false m c n' hgap g' hg' hg'0 s hs0 hsidle u hsu hup hu1 hmid hguard

/-! ### The collision, at every clip -/

theorem kappa_collision_pos (Tc Tn P B c n : ℕ) (hn : Tn ≤ n) (hB : c + B ≤ n) :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n + (P + 1)) := by
  unfold kappa
  refine Prod.ext rfl (Prod.ext rfl (Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Fin.ext ?_))))
  · show min n Tn = min (n + (P + 1)) Tn
    omega
  · show n % (P + 1) = (n + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · show clipIdx B c n = clipIdx B c (n + (P + 1))
    unfold clipIdx
    split_ifs <;> omega

/-- **NO CLIP SURVIVES THE CHAIN FAMILY.** For EVERY gap clip `B` — no upper bound on it — and
every threshold pair and modulus, the chain object with `B + 1` idle chain states carries a
`kappa`-collision whose cells differ at the one fixed formula `chainC` (`dBack = 0`,
`dFwd = 3`). The separated gaps are `B + 1` and `B + 1 + (P + 1)`. -/
theorem gap_clip_refuted_at_every_clip (B Tc Tn P : ℕ) :
    ∃ c n n' : ℕ, n = c + (B + 1) ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') ∧
      cellAt (MM B) chainC
          ((0, stM B c n) :
            (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
        ≠ cellAt (MM B) chainC
          ((0, stM B c n') :
            (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 := by
  refine ⟨Tn, Tn + (B + 1), Tn + (B + 1) + (P + 1), rfl, ?_, ?_⟩
  · exact kappa_collision_pos Tc Tn P B Tn _ (by omega) (by omega)
  · rw [show Tn + (B + 1) = Tn + B + 1 by omega]
    exact chainC_cell_ne B Tn _ (by omega)

/-- The filed (K4) at `chainC` is `7 ≤ B`. -/
theorem Bof_chainC (m : ℕ) : Bof (stepM m) (pendM m) (labM m) chainC = 7 := by
  unfold Bof
  rw [dBack_chainC, dFwd_chainC]
  rfl

/-- **AT THE FILED `ParamsOk`, WITH THE CLIP RAISED TO ANY FORMULA-ONLY VALUE.** Let `E` be ANY
function of the formula alone (for instance `fun φ => 2 ^ (dBack φ + 1)`, or a tower). Put
`B := max (E chainC) 7`. Then at the chain object with `B + 1` chain states: `ParamsOk` holds at
the periodicity fixpoint's own `Tcof`, `Tnof`, `Pof` with the clip `B`; `B` dominates `E chainC`
and the filed `Bof`; and two counter pairs of one `kappa`-class have different cells. -/
theorem no_formula_only_clip (E : PlusFormula → ℕ) :
    ∃ B : ℕ, E chainC ≤ B ∧ Bof (stepM B) (pendM B) (labM B) chainC ≤ B ∧
      ParamsOk (stepM B) (pendM B) (labM B) chainC
        (Tcof (stepM B) (pendM B) (labM B) chainC) (Tnof (stepM B) (pendM B) (labM B) chainC)
        (Pof (stepM B) (pendM B) (labM B) chainC) B ∧
      ∃ c n n' : ℕ,
        kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n)
          = kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n') ∧
        cellAt (MM B) chainC
            ((0, stM B c n) :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
          ≠ cellAt (MM B) chainC
            ((0, stM B c n') :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 := by
  refine ⟨max (E chainC) 7, le_max_left _ _, ?_, ?_, ?_⟩
  · rw [Bof_chainC]; exact le_max_right _ _
  · obtain ⟨h1, h2, h3, -⟩ := paramsOk_params (stepM (max (E chainC) 7))
      (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC
    refine ⟨h1, h2, h3, ?_⟩
    have h7 : 7 ≤ max (E chainC) 7 := le_max_right _ _
    unfold paramsOkK4
    rw [dBack_chainC, dFwd_chainC]
    omega
  · obtain ⟨c, n, n', -, hk, hne⟩ := gap_clip_refuted_at_every_clip (max (E chainC) 7)
      (Tcof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
      (Tnof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
      (Pof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
    exact ⟨c, n, n', hk, hne⟩

/-- **THE INSTANCE THE QUESTION NAMES**: the clip `max (2 ^ (dBack φ + 1)) (Bof φ)`-or-larger. -/
theorem exponential_clip_refuted :
    ∃ B : ℕ, 2 ^ (dBack chainC + 1) ≤ B ∧ Bof (stepM B) (pendM B) (labM B) chainC ≤ B ∧
      ParamsOk (stepM B) (pendM B) (labM B) chainC
        (Tcof (stepM B) (pendM B) (labM B) chainC) (Tnof (stepM B) (pendM B) (labM B) chainC)
        (Pof (stepM B) (pendM B) (labM B) chainC) B ∧
      ∃ c n n' : ℕ,
        kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n)
          = kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n') ∧
        cellAt (MM B) chainC
            ((0, stM B c n) :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
          ≠ cellAt (MM B) chainC
            ((0, stM B c n') :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 :=
  no_formula_only_clip (fun φ => 2 ^ (dBack φ + 1))

end Probe761G

#print axioms Probe761G.chainC_cell_ne
#print axioms Probe761G.gap_clip_refuted_at_every_clip
#print axioms Probe761G.no_formula_only_clip
#print axioms Probe761G.exponential_clip_refuted
```
