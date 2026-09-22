# Research Report: Task #652

**Task**: 652 - Define time-indexed task frames and prove the Dedekind-completeness rigidity boundary, with a compiled ℚ counterexample
**Started**: 2026-09-22T12:10:00Z
**Completed**: 2026-09-22T12:55:00Z
**Effort**: medium (research); implementation estimated ~350-450 lines across two modules
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/04_dense-correspondent-and-rigidity.md` (§4.5, §4.7, §4.8.1)
- `.../reports/05_lean-verification-and-formalization-program.md` (§R4, Appendix A.4)
- Codebase: `FormalSystem/Semantics/TaskFrame.lean`, `Semantics/TemporalOrder.lean`, `Semantics/DurationClassification.lean`, `Semantics/Correspondence/Rigidity.lean`, `Semantics/Correspondence/RigiditySharpness.lean`, `Metalogic/Independence/RationalWitness.lean`, `scripts/check-module-invariants.sh`, `docs/theorem-index.md`
- lean-lsp `lean_run_code` (5 probe runs), `lake env lean` on the combined probe, `lean_local_search`, `lean_loogle`
**Artifacts**:
- `specs/652_time_indexed_frames_dedekind_rigidity_boundary/reports/01_time-indexed-dedekind-rigidity.md` (this report)
- `specs/652_time_indexed_frames_dedekind_rigidity_boundary/probes/01_positive_theorem.lean` (compiled green)
- `specs/652_time_indexed_frames_dedekind_rigidity_boundary/probes/02_rat_witness.lean` (compiled green)
- `specs/652_time_indexed_frames_dedekind_rigidity_boundary/probes/README.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Both mathematical deliverables are already compiled, sorry-free.** The positive theorem and
  the full ℚ sharpness witness (all four time-indexed frame conditions, `¬ Static`,
  `¬ ConstantHistories`) were written and run against this tree during research. The combined
  204-line probe elaborates with **zero errors and zero warnings**, and every theorem reports
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`. The probes are in
  `specs/652_time_indexed_frames_dedekind_rigidity_boundary/probes/`. Implementation is
  transcription plus wiring, not discovery.
- **One correction to the task statement, reported rather than silently weakened.** The positive
  theorem provably delivers **constant histories**, not relation-level `Static`
  (`R w x y u ↔ w = u`). The task description's gloss "has only constant histories, i.e. is
  static" conflates the two; the `Rigidity.lean` scope note itself says only "force constant
  histories" and is therefore **accurate as written**. Getting from constant histories to
  `R = id` requires `P = R`, which requires transposing the whole `Semantics/Extension/` chain to
  absolute times (report 05 estimates ~1000 lines and explicitly does not recommend it). Detail
  and the failed direct attempt are in *Findings → The `Static` gap*.
- **The proof needs no topology and no `ConditionallyCompleteLinearOrder` instance.** A direct
  least-upper-bound argument replaces report 04's appeal to connectedness of `ℝ`. The hypothesis
  is the repository's own established Prop-valued Dedekind form
  `h_lub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c`
  (`Semantics/DurationClassification.lean`'s binder convention) plus `[DenselyOrdered ↑D]` and
  `[Finite G.W]`. Compositionality, Seriality and Saturation are **not used**.
- **Recommended siting: two modules, not one**, mirroring the existing `Rigidity` /
  `RigiditySharpness` pair — `Semantics/TimeIndexed.lean` (structure + positive theorem) and
  `Semantics/TimeIndexedSharpness.lean` (the ℚ witness). This keeps
  `Mathlib.NumberTheory.Real.Irrational` off the shared-infrastructure module that the MF
  frame-correspondence Theorem A will consume.
- **The comparison is a clean 2×2** once `archimedean_of_lub` is cited: over a duration *group*,
  Dedekind ⟹ Archimedean, so the time-indexed boundary is strictly stronger than the
  duration-indexed one, and ℚ — Archimedean, dense, not Dedekind-complete — is exactly the row
  where the two boundaries separate.

## Context & Scope

Researched: how to define a time-indexed frame structure in this tree at the generality report 05
needs for the MF Theorem A (R4); what hypotheses the time-indexed rigidity theorem actually
consumes; whether the `Rigidity.lean` scope note's claims survive machine checking; and what
wiring the repository's gates demand for a new root-imported module.

Constraints honoured: no edit to `Semantics/ShiftSet.lean`; no attempt at Theorem A; no `sorry`
and no new axiom anywhere in the recommended plan.

Re-verification of report 05 against the current tree (modules have moved since it was written):

| Report 05 claim | Status now |
|---|---|
| `TaskFrame.exists_uniform_radius_of_finite` exists | ✅ `FormalSystem/Semantics/TaskFrame.lean` |
| `FrameOver.static_of_finite`, `static_iff_uniformDwell` exist | ✅ `Semantics/Correspondence/Rigidity.lean`, both C14-pinned |
| `grep -rn "TimeIndexed"` → no hits | ✅ still no hits under `FormalSystem/` |
| `t1Rel` / T1-converse witness | ❌ still absent (R3 not done; irrelevant here) |
| `TemporalOrder` bundles the four duration binders | ✅ `Semantics/TemporalOrder.lean`; `TemporalOrder.of D` is the `@[reducible]` bundler |
| "`Mathlib.Data.Real.Irrational` is not in this checkout's partial Mathlib build" (`ShiftSet.lean`) | ❌ **stale**: the module is now `Mathlib.NumberTheory.Real.Irrational` and `Metalogic/Independence/RationalWitness.lean` imports it successfully. Recorded only — `ShiftSet.lean` is out of scope and must not be touched. |

## Literature Proof Structure

**Source**: `04_dense-correspondent-and-rigidity.md`, §4.7 (Proposition 4.7.1) and §4.5 (the G1/G2/`Q√2` family); structure definition from `05_lean-verification-and-formalization-program.md`, §R4 / Appendix A.4.
**Strategy**: a positive theorem by order-completeness plus a compiled counterexample over a non-complete order.

### Step Map

1. **Define the time-indexed structure** — `W`, a time order, `R : W → T → T → W → Prop`, with
   `Hist`, `Stationary`, `P` — report 05 Appendix A.4.
2. **State the four time-indexed frame conditions** (Compositionality at triples of times,
   Seriality, Limit `⋂_{ε>0} (w)_{x,ε} = {w}`, Saturation) and the converse convention
   `R_{y,x} = R_{x,y}⁻¹` — report 04 §4.8.1.
3. **Limit + finite `W` ⟹ histories locally constant** — report 04 §4.7.1, first half: for each of
   the finitely many `u ≠ τ(x)` Limit supplies a radius; take the minimum.
4. **Locally constant + connected time ⟹ constant** — report 04 §4.7.1, second half.
5. **Over ℚ the dwell is not uniform in time** — report 04 §4.7, "Where time-indexed rigidity
   fails": histories switch at irrational gaps and the dwell at `x` shrinks to `0` as `x`
   approaches a gap.
6. **The `Q√2` frame** — report 04 §4.5 with `Γ = {√2}`: `W = {a,b}`, `R_{x,y} = id ∪ {(a,b)}`
   when `(x,y) ∩ Γ ≠ ∅`, extended by the converse convention; all four conditions hold; not
   static.

### Dependencies

- Step 4 depends on step 3. Step 6 depends on step 2. Steps 3-4 and step 6 are independent of
  each other; they meet only in the comparison docstring.
- Report 04's step 4 additionally routes "constant histories ⟹ `R = id`" through `P = R`
  (Theorem A′ transposition, §4.8.1), which depends on the whole `lem:nesting`–`thm:extension`
  chain. **That dependency is what this task cannot pay** — see *The `Static` gap*.

### Potential Formalization Challenges — and what actually happened

| Step | Anticipated difficulty | Outcome |
|---|---|---|
| 4 | "connectedness of `ℝ`" needs an `OrderTopology` on `↑D`, which would collide with `TemporalOrder`'s instance fields | **Avoided.** Replaced by a direct `IsLUB` argument. No topology, no new instance. |
| 4 | `[ConditionallyCompleteLinearOrder ↑D]` would be a genuine instance diamond against `TemporalOrder.linearOrder` | **Avoided.** The repository already mandates the Prop-valued `h_lub` form for exactly this reason (`DurationClassification.lean`, "The binder convention"). |
| 3 | minimising finitely many radii | Straight transcription of `TaskFrame.exists_uniform_radius_of_finite`. |
| 6 | "`(x,y) ∩ Γ ≠ ∅`" for `Γ = {√2}` needs irrationality | `irrational_sqrt_two` from `Mathlib.NumberTheory.Real.Irrational`; already imported elsewhere in the tree. |
| 6 | Compositionality's case explosion (2 states × 3 cut positions) | One `by_cases`×3 / `cases`×2 / `simp_all` line, given monotonicity of the cut predicate. |
| — | `linarith` on `↑D` | **Real trap.** `↑D` is an ordered abelian *group*, not a field, so `linarith` is unavailable. Every inequality step must be an explicit `sub_lt_comm` / `sub_lt_iff_lt_add'` / `sub_neg` / `abs_sub_lt_iff` invocation. The probe does this throughout; a transcriber who reaches for `linarith` will be stuck. |

## Findings

### Codebase Patterns

**The Dedekind hypothesis has a house form, and it is Prop-valued.**
`Semantics/DurationClassification.lean` states its binder convention explicitly: every lemma takes
`h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x` **rather than** a
`ConditionallyCompleteLinearOrder D` instance, because that "keeps every `[LinearOrder D]`-indexed
lemma applicable with no instance-unification risk". The new theorem must follow it. The same file
supplies `archimedean_of_lub` (Dedekind ⟹ Archimedean), which is what makes the comparison
docstring exact rather than impressionistic.

**`ℚ`'s failure of Dedekind completeness is already a theorem in this tree, proved with the same
cut.** `FormalSystem.Metalogic.Independence.rat_not_complete` refutes
`∀ s : Set ℚ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x` using the witness set
`{q : ℚ | (q:ℝ) < √2}` and `irrational_sqrt_two`. The new ℚ witness is its exact frame-level
companion: same order, same cut, same irrationality lemma. It lives in `Metalogic/`, which imports
`Semantics/`, so a `Semantics/` module **cannot import it** — cite it in prose only. No import is
needed, because the witness never uses the failure of completeness as a hypothesis; it simply is a
frame over ℚ.

**Witness idiom.** `RigiditySharpness.lean` builds `lexRatFrame : FrameOver (TemporalOrder.of LexRat)`
from a named presenting relation with per-condition theorems and a final `..._not_static`. The ℚ
witness should mirror that shape exactly, including `TemporalOrder.of ℚ` rather than a fresh
`⟨ℚ⟩` bundler (the probe confirms `TemporalOrder.of ℚ` elaborates).

**Limit's transcribed shape.** `FrameOver.limit` reads
`∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w`. The time-indexed analogue keeps the shape
and re-centres the radius: `∀ w u t, (∀ ε, 0 < ε → ∃ s, |s - t| < ε ∧ R w t s u) → u = w`.
`|s - t|` needs subtraction on the time carrier, which is exactly why indexing by `TemporalOrder`
(a group) rather than a bare `LinearOrder` is the right call — and ℚ and ℝ are both temporal
orders, so no generality is lost for any of the four deliverables.

### External Resources

Mathlib declarations confirmed present and load-bearing:

| Declaration | Module | Role |
|---|---|---|
| `IsLUB.exists_between_sub_self` | `Mathlib.Algebra.Order.Group.Bounds` | `IsLUB s a → 0 < ε → ∃ b ∈ s, a - ε < b ∧ b ≤ a` — the one lemma the sup argument turns on. **Requires an explicit import**; it is not in `TaskFrame.lean`'s transitive closure. |
| `irrational_sqrt_two` | `Mathlib.NumberTheory.Real.Irrational` | no rational equals `√2` |
| `exists_rat_btwn` | (core order/real) | picks the rational radius below `|x − √2|` |
| `abs_sub_lt_iff`, `sub_lt_comm`, `sub_lt_iff_lt_add'`, `sub_neg` | `Mathlib.Algebra.Order.*` | the `linarith`-free inequality steps on `↑D` |
| `Finset.inf'`, `Finset.lt_inf'_iff`, `Finset.inf'_le` | `Mathlib.Order.Finset.Lattice` | minimising the finitely many radii |
| `Real.sq_sqrt`, `Real.sqrt_nonneg` | analysis | `1 < √2 < 2`, via `nlinarith` |

### Recommendations

#### R1. Siting: two modules

| Module | Contents | Imports |
|---|---|---|
| `FormalSystem/Semantics/TimeIndexed.lean` | `structure TimeIndexed`, `Hist`, `Limit`, `Compositional`, `Serial`, `Converse`, `Static`, `ConstantHistories`, `Stationary`, `P`; `exists_uniform_radius_of_finite`, `locally_constant_of_finite`, `constantHistories_of_lub` | `FormalSystem.Semantics.TaskFrame`, `Mathlib.Algebra.Order.Group.Bounds` |
| `FormalSystem/Semantics/TimeIndexedSharpness.lean` | `belowCut`, `cut_not_rat`, `belowCut_mono`, `exists_radius`, `switchRel`, `qSwitchFrame`, the four condition theorems, `qSwitchFrame_not_static`, `switchHist`, `qSwitchFrame_not_constantHistories`; the ℚ-vs-`ℚ ×ₗ ℚ` comparison docstring | the above, plus `Mathlib.NumberTheory.Real.Irrational` |

Rationale for the split, beyond symmetry with `Rigidity`/`RigiditySharpness`: report 05 names the
MF Theorem A (R4) as the other consumer of `TimeIndexed`, and R4 has no use for `Real.sqrt`.
Keeping the analysis import in the sharpness module leaves the shared-infrastructure module at a
`TaskFrame`-weight dependency set.

Both are flat `Semantics/*.lean` modules with no sibling directory, so C8's aggregator convention
is satisfied the way `Semantics/ShiftSet.lean` satisfies it. Both go into
`FormalSystem/Semantics.lean`'s import list and its `## Modules` prose, and into
`FormalSystem/Semantics/README.md`.

**A single-module alternative is workable** if the planner prefers the task description's literal
`FormalSystem/Semantics/TimeIndexed.lean`; the only cost is the heavier import on R4's future
dependency path. Recorded so the choice is explicit, not implied.

#### R2. The structure, verbatim at report 05's names

```lean
structure TimeIndexed (D : TemporalOrder) where
  W : Type
  [nonempty : Nonempty W]
  R : W → ↑D → ↑D → W → Prop
```

Field names `W` / `nonempty` / `R` are report 05's and are deliberately **not** `FrameOver`'s
`WorldState` / `worldNonempty` / `PosRel`. Two reasons: the task mandates report 05's names so
that R4 consumes the structure unchanged, and the divergence is a useful signal that this is a
different structure, not a second presentation of a task frame. Record that in the docstring.

Predicates (all `def`s on `TimeIndexed D`, none carried as structure fields — matching
`TaskFrame.Compositional`/`Serial`/`Interpolates`, which are bare-relation predicates the bundled
`FrameOver` then cites):

```lean
def Hist       (G) : Set (↑D → G.W) := {τ | ∀ x y, G.R (τ x) x y (τ y)}
def Limit      (G) : Prop := ∀ w u t, (∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u) → u = w
def Compositional (G) : Prop := ∀ w v x y z, x ≤ y → y ≤ z → (G.R w x z v ↔ ∃ u, G.R w x y u ∧ G.R u y z v)
def Serial     (G) : Prop := ∀ w x y, (∃ u, G.R w x y u) ∧ (∃ v, G.R v x y w)
def Converse   (G) : Prop := ∀ w x y u, G.R w x y u ↔ G.R u y x w
def Static     (G) : Prop := ∀ w x y u, G.R w x y u ↔ w = u
def ConstantHistories (G) : Prop := ∀ τ ∈ G.Hist, ∀ x y, τ x = τ y
def Stationary (G) : Prop := ∀ w u x y d, G.R w x y u ↔ G.R w (x + d) (y + d) u
def P          (G) (x y : ↑D) : Set (G.W × G.W) := {p | ∃ τ ∈ G.Hist, p = (τ x, τ y)}
```

`Stationary` and `P` carry no theorem in this task; they are included because report 05's Theorem A
statement is written in terms of them and the task mandates stating the structure at the generality
R4 needs. Saturation is omitted: on a finite carrier it is automatic
(`TaskFrame.saturation_of_finite` is the duration-indexed precedent), no deliverable consumes it,
and stating it would require transposing `IsFiber`/`IsSegment` to absolute times for no use.

#### R3. The positive theorem (compiled)

```lean
theorem constantHistories_of_lub [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit) : G.ConstantHistories
```

Proof shape (full body in `probes/01_positive_theorem.lean`):

1. `exists_uniform_radius_of_finite` — contrapositive of `Limit` per state, then `Finset.inf'`
   over `univ`. Transcribes `TaskFrame.exists_uniform_radius_of_finite`.
2. `locally_constant_of_finite` — instantiate (1) at `w := τ t` and feed it `hτ t s`.
3. Sup argument for `a ≤ b → τ a = τ b`, with `S := {y | a ≤ y ∧ y ≤ b ∧ τ y = τ a}`:
   `IsLUB.exists_between_sub_self` puts `c := sSup S` in `S`; if `c < b`, density picks
   `y ∈ (c, min b (c+ε))`, which lands in `S` above its own supremum. Contradiction, so `c = b`.
4. `le_total` closes the unordered case.

**Hypotheses the proof does not use**: Compositionality, Seriality, Saturation, the converse
convention, unboundedness of the time order, any topology. State it at exactly this and claim
nothing more — the same discipline `Rigidity.lean`'s `eq_of_rel_of_step` already follows.

**Both hypotheses on `D` are load-bearing and each is separately witnessed.** Density fails over ℤ
(where local constancy is vacuous and switching frames exist); Dedekind completeness fails over ℚ
(deliverable 3). See R5 for the optional ℤ witness that closes the square.

#### R4. The ℚ sharpness witness (compiled)

```lean
def belowCut (x : ℚ) : Prop := (x : ℝ) < Real.sqrt 2

def switchRel (w : Bool) (x y : ℚ) (u : Bool) : Prop :=
  w = u ∨ (w = false ∧ u = true ∧ belowCut x ∧ ¬ belowCut y)
        ∨ (w = true ∧ u = false ∧ belowCut y ∧ ¬ belowCut x)

def qSwitchFrame : TimeIndexed (TemporalOrder.of ℚ) where
  W := Bool
  R := switchRel
```

The relation is written in the already-converse-symmetric shape rather than as "forward relation +
reflection convention", so `qSwitchFrame_converse` is a six-line `rintro`/`exact` and no reflection
plumbing is needed. All six results are proved in `probes/02_rat_witness.lean`:
`qSwitchFrame_converse`, `qSwitchFrame_serial`, `qSwitchFrame_limit`, `qSwitchFrame_compositional`,
`qSwitchFrame_not_static`, `qSwitchFrame_not_constantHistories` (via the switching history
`switchHist t = if belowCut t then false else true`, which is in `Hist` and separates `1` from `2`).

The pivot is `exists_radius : ∀ x : ℚ, ∃ ε : ℚ, 0 < ε ∧ ∀ s, |s - x| < ε → (belowCut s ↔ belowCut x)`
— "no rational time is a cut point, so every rational time has a cut-free neighbourhood". That is
what makes `Limit` hold, and it is exactly report 04's observation that the dwell exists at every
time but is not uniform in time: `exists_radius x` returns a radius that shrinks to `0` as `x`
approaches `√2`. Say so in the docstring; it is the whole mechanism.

#### R5. Optional: the ℤ witness that closes the sharpness square (~25 lines)

`ℤ` is Dedekind-complete but not densely ordered. `W = Bool`,
`R w x y u := w = u ∨ (w = false ∧ u = true ∧ x < 0 ∧ 0 ≤ y) ∨ (converse)` over
`TemporalOrder.of ℤ` satisfies `Limit` for the cheap reason that `|s - t| < 1` forces `s = t`, and
its switching history is non-constant. Not a task deliverable; recommended because without it the
`[DenselyOrdered ↑D]` hypothesis of R3 is unwitnessed, whereas `RigiditySharpness.lean` witnesses
both of its theorem's hypotheses. **Planner's call** — it is additive and can be dropped without
affecting acceptance.

#### R6. The comparison docstring (deliverable 4)

Put the table in `TimeIndexedSharpness.lean`'s module docstring, with a two-sentence pointer from
`TimeIndexed.lean` and from `Rigidity.lean`'s replaced scope note.

| time / duration order | dense? | Archimedean? | Dedekind-complete? | duration-indexed, finite `W` | time-indexed, finite `W` |
|---|---|---|---|---|---|
| `ℤ` | no | yes | yes | dynamics — `permissiveFrame_not_static` | dynamics (R5, optional) |
| `ℚ ×ₗ ℚ` | yes | **no** | no | dynamics — `lexRatFrame_not_static` | — |
| `ℚ` | yes | yes | **no** | **static** — `FrameOver.static_of_finite` | **dynamics** — `qSwitchFrame_not_constantHistories` |
| `ℝ` | yes | yes | yes | static | static — `constantHistories_of_lub` |

The ℚ row is the entire point and should be called out as such: it is the one order where the two
boundaries disagree. The reason they disagree is one sentence, and it should be stated with
`archimedean_of_lub` cited: over a duration *group* Dedekind completeness implies the Archimedean
property, so the time-indexed hypothesis is **strictly stronger**; the duration-indexed proof chops
a duration into finitely many sub-durations (Archimedean, plus Compositionality) whereas the
time-indexed proof has no duration to chop and must instead close a gap in the time line
(Dedekind, no Compositionality). Report 04 §4.7 puts it as: "Compositionality and the Archimedean
chop are not used; connectedness replaces both."

Docstrings must cite the manuscript by label or quotable phrase, never by line number, and carry no
task numbers — the `Rigidity.lean` docstring is the model.

#### R7. Wiring checklist (every item is gated)

1. `FormalSystem/Semantics.lean`: add both imports and a `## Modules` bullet for each.
2. `FormalSystem/Semantics/README.md`: add rows; if it carries a
   `<!-- BEGIN GENERATED: inventory ... -->` block, re-emit with
   `bash scripts/check-module-invariants.sh --emit-inventory` (the old `readme-inventory.sh` is a
   deprecated shim that only prints the replacement).
3. `lake exe mk_all --lib FormalSystem` to regenerate the root; **never hand-edit**
   `FormalSystem.lean`. Verify with `lake exe mk_all --lib FormalSystem --check` (exit 0).
4. `docs/theorem-index.md`: two rows, `Paper: —`, `Axioms: pcq pinned:C14`. C15's second assertion
   requires each named declaration's own `/-- -/` block to carry a `Paper: — (reason)` line. Model
   it on `Rigidity.lean`'s: `Paper: — (the manuscript states no rigidity theorem; stated at the
   hypothesis the proof uses)`.
5. `scripts/check-module-invariants.sh`: add matching lines to **both** the `C14LEAN` heredoc
   (`#print axioms FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub`, and the same for
   `FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories`) and the `C14_BASELINE`
   heredoc (`'…' depends on axioms: [propext, Classical.choice, Quot.sound]`). The two are compared
   by **exact string equality** and must stay in the same order.
6. Header linter under `--wfail`: module docstring immediately after the imports, no broad imports.
7. C24: both modules reach `FormalSystem.Init` through `Semantics.TaskFrame`. Nothing to do.

### Decisions

- **`Static` is defined at relation level and `ConstantHistories` at history level, and the
  positive theorem concludes the latter.** Both are defined so the ℚ witness can refute both and
  so the duration-indexed `TaskFrame.Static` has a visible time-indexed twin.
- **Dedekind completeness enters as the Prop-valued `h_lub`, never as an instance.** Follows
  `DurationClassification.lean`'s stated convention and sidesteps a real diamond against
  `TemporalOrder.linearOrder`.
- **Topology is not introduced.** Report 04's connectedness argument is replaced by an equivalent
  `IsLUB` argument. `TaskFrame.exists_uniform_radius_of_finite`'s docstring already records that
  the cone topology is deliberately absent from this library; adding an `OrderTopology` here to
  reach the same conclusion would contradict that standing decision for no gain.
- **Saturation is not transposed.** No deliverable consumes it and it is automatic on a finite
  carrier.
- **`rat_not_complete` is cited in prose, not imported.** It lives above `Semantics/` in the import
  order.
- **The witness relation is written converse-symmetrically** rather than as forward-relation +
  reflection.

### The `Static` gap — reported, not weakened

The task description asks for "a time-indexed frame with finitely many states satisfying Limit has
only constant histories, **i.e. is static**". Those are not the same claim, and only the first is
reachable here.

`Rigidity.lean`'s scope note is accurate as written — it claims only that finitely many states plus
*Limit* "force constant histories". Report 04's Proposition 4.7.1 states the stronger conclusion
too, but its proof gets there in a separate step: "Then `P ⊆ id`; **by `P = R`** (Theorem A′
transposition, §4.8.1) `R ⊆ id`, and nullity gives `R = id`." `P = R` is the statement that every
related pair is realised by some total history, and its proof is the whole
`lem:nesting`–`lem:step`–`thm:extension` chain (Saturation plus Zorn) transposed to absolute times.
Report 05 sizes that transposition at ~1000 lines and says flatly: "**not recommended**; state A′
in the paper as a remark".

I attempted a direct relation-level sup argument to avoid the chain, and it fails at an identifiable
place. Take `B := {y ∈ [x,z] | ∀ v, R w x y v → v = w}` and `c := sSup B`. Showing `c ∈ B` needs, for
`v` with `R w x c v`, a contradiction from the dwell at `c`. Compositionality at `x ≤ s ≤ c` (for
`s ∈ B` near `c`) delivers `R w s c v` — a task *arriving at* time `c` from time `s`. But
`Limit` at `(w, c)` constrains `R w c y v` — the dwell *departing from* `w` at time `c`. The converse
convention turns `R w s c v` into `R v c s w`, which is a statement about `v`'s dwell, not `w`'s.
No field of the structure converts one into the other, and applying `Limit` at `(w, s)` instead is
circular (`s` was chosen using the radius at `c`). The history-level argument has no such problem
precisely because a history satisfies `R (τ x) x y (τ y)` at *every* pair, so local constancy is
available at every point directly.

**Consequence for the plan.** State `constantHistories_of_lub` as the positive theorem. If a
relation-level corollary is wanted, state it conditionally —
`theorem static_of_lub_of_realized (hPR : ∀ x y w u, G.R w x y u → ∃ τ ∈ G.Hist, τ x = w ∧ τ y = u) : …`
— which is a two-line consequence and makes the missing ingredient explicit and named rather than
absent. **Recommended**, as it is cheap and turns a gap into a documented hypothesis.

**Consequence for `Rigidity.lean`'s scope note.** Its replacement cross-reference should keep the
phrase "force constant histories" rather than upgrading it to "static", and should name
`constantHistories_of_lub` and `qSwitchFrame_not_constantHistories`.

## Risks & Mitigations

- **Risk**: a transcriber reaches for `linarith`/`omega` on `↑D` and stalls. **Mitigation**: the
  probe's explicit `sub_lt_comm` / `sub_lt_iff_lt_add'` / `sub_neg` / `abs_sub_lt_iff` steps are
  the body; copy them rather than re-deriving.
- **Risk**: `--wfail` turns style-linter warnings into build failures. Two fire on the natural
  draft: `linter.style.show` (a `show` that *changes* the goal must be `change`) and
  `linter.unusedSimpArgs`. **Mitigation**: the probe already uses `change` and carries no unused
  simp argument; the combined run is warning-free. Do not reintroduce `show`.
- **Risk**: the C14 baseline pair drifts out of order and the exact-string comparison fails with a
  confusing diff. **Mitigation**: add the `#print axioms` lines and the baseline rows at the same
  relative position, next to the existing `static_iff_uniformDwell` / `static_of_finite` rows.
- **Risk**: the planner sites the witness in a module that `Metalogic/` already imports, creating a
  cycle with `rat_not_complete`. **Mitigation**: `Semantics/` never imports `Metalogic/`; keep the
  reference to `rat_not_complete` in prose.
- **Risk**: siting disagreement between the task description (`Semantics/TimeIndexed.lean`, single
  module) and report 05's "scope it to the `Correspondence/` layer". **Mitigation**: R1 recommends
  the `Semantics/` siting the task names, split in two; the trade is stated so the planner can
  overrule with reasons.
- **Risk**: `lake build --wfail` on the whole tree is slow and this task's modules are root-imported.
  **Mitigation**: run detached through the build guard per
  `context/project/lean4/operations/long-builds.md`; do not block on a foreground build.

## Tactic Survey Results

Tactics were exercised against the real goals during the probe runs, not surveyed abstractly.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `qSwitchFrame_compositional`, all 32 cases | `simp_all` | **success** | `[belowCut_mono hxy, belowCut_mono hyz]` after `by_cases`×3 and `cases w <;> cases v`. A third `belowCut_mono (hxy.trans hyz)` is flagged unused by the linter — omit it. |
| `switchHist_mem` | `simp` | success | `[hx, hy]` after `by_cases`×2 |
| `1 < √2`, `√2 < 2` | `nlinarith` | success | `[Real.sq_sqrt (0 ≤ 2), Real.sqrt_nonneg 2]` |
| inequalities on `↑D` (sup argument) | `linarith` | **fail** | `↑D` is an ordered abelian group, not a field — tactic unavailable. Replaced by explicit `sub_lt_comm` / `sub_lt_iff_lt_add'` / `sub_neg` / `abs_sub_lt_iff` / `lt_add_of_pos_right`. |
| `ℚ`→`ℝ` coercion of `|s - x| < ε` | `exact_mod_cast` + `rw [Rat.cast_abs, Rat.cast_sub]` | success | plain `push_cast` does not reach inside `|·|` here |
| negation of `Limit`'s inner `∀∃` | `push Not` | success | the repository's spelling; not `push_neg` |
| `constantHistories_of_lub` overall | `aesop` / `omega` / `decide` | not attempted | the goal is a two-level sup argument, outside their reach; the structured proof was written directly and is green |

## Context Extension Recommendations

- **Topic**: `linarith` is unavailable on `↑D` (`TemporalOrder` carriers are ordered abelian
  groups, not fields).
  **Gap**: no context file records this, and it is the single most likely way a Lean implementer
  loses time on any duration- or time-order proof in this tree.
  **Recommendation**: add a short subsection to `.claude/context/project/lean4/` — a "duration
  arithmetic without `linarith`" cheat-sheet listing `sub_lt_comm`, `sub_lt_iff_lt_add'`,
  `sub_neg`, `sub_nonpos`, `abs_sub_lt_iff`, `lt_add_of_pos_right`, `IsLUB.exists_between_sub_self`.
- **Topic**: the C14 baseline pair's exact-string-equality contract.
  **Gap**: the rule lives only in a comment inside `scripts/check-module-invariants.sh`; every task
  that adds a pinned theorem has to rediscover it.
  **Recommendation**: one paragraph in the Lean extension's operations context naming both heredocs
  and the ordering requirement.

## Appendix

### Search queries and probe runs

- `lean_local_search`: `IsLUB.exists_between`.
- `lean_loogle`: `Irrational (Real.sqrt _)` → `Mathlib.NumberTheory.Real.Irrational`.
- `lean_run_code`: 5 runs — (1) positive theorem, 3 errors; (2) same with `IsLUB.exists_between_sub_self`
  applied as a function, 1 missing-import error; (3) same plus `Mathlib.Algebra.Order.Group.Bounds`,
  **green**, `pcq`; (4) ℚ witness, 3 errors (`show` not unfolding a structure projection,
  `abs_sub_comm` direction); (5) witness fixed, **green**, style warnings only.
- `lake env lean` on the concatenated 204-line probe: **0 errors, 0 warnings**, all five
  `#print axioms` report `[propext, Classical.choice, Quot.sound]`.
- Greps: `TemporalOrder` / `ratOrder` / `realTemporalOrder` under `FormalSystem/`;
  `Dedekind|ConditionallyComplete|IsLUB|sSup`; `Irrational`; `^import Mathlib` roots;
  `Paper: —` in `FormalSystem/` and in `scripts/check-module-invariants.sh`;
  `emit-inventory`; `static_of_finite|static_iff_uniformDwell` in the C14 baselines and
  `docs/theorem-index.md`.

### Documentation consulted

- `FormalSystem/Semantics/TemporalOrder.lean` — structure, `of`, the instance-fields rationale.
- `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver` fields (especially `limit`'s shape),
  `exists_uniform_radius_of_finite`, `exists_pos_of_nontrivial`, `Compositional`/`Serial`/`Interpolates`.
- `FormalSystem/Semantics/DurationClassification.lean` — the `h_lub` binder convention,
  `archimedean_of_lub`.
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` — the scope note being discharged, and the
  "state it at the hypothesis the proof uses" discipline.
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` — witness module shape.
- `FormalSystem/Metalogic/Independence/RationalWitness.lean` — `rat_not_complete`.
- `docs/theorem-index.md` — row format, `Axioms` column semantics.
- `scripts/check-module-invariants.sh` — C8, C14 (both heredocs), C15 (`Paper:` at the declaration),
  C24; `--emit-inventory`.
