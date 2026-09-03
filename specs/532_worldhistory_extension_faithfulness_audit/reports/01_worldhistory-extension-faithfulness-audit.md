# WorldHistory Extension Faithfulness Audit

**Task**: 532 — Audit and resolve the partial-vs-total `WorldHistory` faithfulness gap against
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
`thm:extension`.
**Anchor source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(`sec:Construction` l.933; Appendix `app:TaskSemantics` l.2757–3700; `def:frame` l.2831;
`def:world-history` l.2953; `lem:step` l.3129; `cor:saturation-finite` l.3143; `thm:extension`
l.3155; `cor:occurrence` l.3173; `def:BL-semantics` l.3593; `def:time-shift-histories` l.3610;
`app:auto_existence` l.3618; `lem:history-time-shift-preservation` l.3632; `def:frame-properties`
l.3705). Line numbers are given here for the reader's navigation only; the Lean tree's convention
of citing by `\label` is respected in every recommendation below.
**Lean sources audited**: `FormalSystem/Semantics/{PartialHistory,WorldHistory,TaskFrame,Truth,
IntTransfer,PartialHistoryOrder,Validity}.lean`, `FormalSystem/Semantics/Extension/*.lean`.
**Machine evidence**: a compiled experiment, saved verbatim as
`specs/532_worldhistory_extension_faithfulness_audit/reports/TruthCorr-experiment.lean.txt`
(189 lines, zero `sorry`, axioms `propext`/`Quot.sound` only except where Mathlib's `≃+o` API
brings in `Classical.choice`).

---

## 0. Verdict in five lines

1. **The prior dispatch's reasoning is correct as far as it goes**: a partial history's
   `TruthAt` profile is *not* reproduced by any total extension, so `thm:extension` cannot be used
   to reduce the arbitrary-history statements of `timeShift_preserves_truth` and `truthAt_map` to
   the `F.HF`-level `TruthIso`. Concrete counterexample in §2.2.
2. **But the dispatch answered a question the paper never poses.** `def:BL-semantics` defines
   truth *only* at `τ ∈ H_F`; `thm:extension` is a statement about histories, not truth profiles.
   The paper offers no licence for evaluating partial histories, so it neither supports nor
   forbids the Lean generalisation — it is silent.
3. **The paper's own transport mechanism is relational, not bijective.** `def:time-shift-histories`
   is a *relation* `τ ≈ σ` on histories; `app:auto_existence` supplies existence of a related total
   history in each direction; `lem:history-time-shift-preservation`'s `□` case consumes exactly
   (existence forward, existence backward, IH at the related pair). The landed `TruthIso.hist :
   F.HF ≃ F'.HF` is a **stronger-than-paper** packaging of that mechanism.
4. **Decision: neither (a) nor (b) as posed.** Re-package the generic transport *relationally*,
   following the paper: a `Prop`-valued correspondence on arbitrary `WorldHistory`s, atomic
   agreement on related pairs, and totality-surjectivity in both directions. This (i) is the
   literal shape of the paper's proof, (ii) derives `timeShift_preserves_truth` **with its
   statement unchanged** (arbitrary `σ`), (iii) derives `IntTransfer.truthAt_map` unchanged, (iv)
   has the existing `TruthIso` as an instance, and (v) involves no `WorldHistory ≃`, hence no
   `HEq` — the trap `IntTransfer.lean`'s docstring already records. All four facts are
   machine-checked (§4).
5. **Divergence audit** (§5): the partial/total distinction, `H_F`, `Extends`, the extension
   order, `thm:extension` and `cor:occurrence` are all present and faithfully stated. The
   divergences found are (a) Lean is *differently quantified* at four sites (truth and its
   transports defined over all `WorldHistory`s where the paper has `H_F`) — all Lean-stronger, all
   consumed only at total histories; (b) `TruthIso.hist` is an `Equiv` where the paper has a
   relation; (c) `FrameOver` carries two documented-redundant fields; (d) three wording/citation
   hygiene defects; (e) `specs/paper-definitions-of-record.md` has drifted from the live paper on
   10 anchors including `def:frame`, `def:world-history`, `thm:extension` — the lint fails today.

---

## 1. Literature Proof Structure

**Source**: Brast-McKie, *Possible Worlds* (JPL), Appendix `app:TaskSemantics`,
`thm:extension` and supporting apparatus.
**Strategy**: Zorn's lemma over partial histories ordered by extension, with the one-point step
`lem:step` forcing maximal ⇒ total.

### Step map

1. **`def:frame`** — task frame `⟨W, 𝔇, ⇒⟩`: `W` nonempty, `𝔇` a nontrivial totally ordered
   abelian group, `⇒` a task relation on `D⁺` extended to `D` by the converse convention
   (`def:task-relation`), satisfying *Compositionality* (a biconditional), *Seriality*, *Limit*,
   *Saturation* (`⊇`-directed families of nonempty fibers/segments have nonempty intersection).
2. **`lem:nullity`** — `w ⇒₀ w`, from *Seriality* at `x = 0` plus *Limit*. Choice-free.
3. **`def:world-history`** — three-layer vocabulary: *partial history* `τ : X → W`, `X ⊆ D`
   **nonempty**, `τ(x) ⇒_{y−x} τ(y)` for all `x, y ∈ X` (negative differences via converse);
   *world history* = partial history with **convex** domain; *total* (= *possible world*) iff
   `X = D`; *extends* = domain inclusion + agreement; `H_F` = the possible worlds.
4. **`def:constraints`, `lem:nesting`, `lem:nonempty`, `lem:constraint`** — for `z ∉ X` the
   constraints (segments when flanked, fibers otherwise) form a `⊇`-directed family of nonempty
   sets. Uses *Compositionality* and *Seriality* only.
5. **`lem:admissible`** — `τ ∪ {⟨z, u⟩}` is a partial history iff `u` lies in every constraint.
   Uses `lem:nullity` for the zero loop at `z`.
6. **`lem:step`** — every partial history extends to `X ∪ {z}` for any `z ∈ D`. **The sole
   *Saturation* application site.**
7. **`cor:saturation-finite`** — finite `W` satisfies *Saturation* choice-free (side result).
8. **`thm:extension`** — partial histories extending `τ` form a poset under extension; chains are
   bounded by their union; Zorn gives a maximal `σ : T → W`; if `T ≠ D`, `lem:step` contradicts
   maximality; so `T = D` and `σ ∈ H_F`. **ZFC (Zorn).**
9. **`cor:occurrence`** — extend the one-point history `{⟨x, w⟩}` (a partial history by
   `lem:nullity`); so every `w` occurs at every `x` in some `τ ∈ H_F`, and `H_F ≠ ∅`.

Companion results consumed by the transport question:

10. **`def:BL-semantics`** — truth defined at `M`, **`τ ∈ H_F`**, `x ∈ D`; `□` quantifies over
    `σ ∈ H_F`; atom clause `τ(x) ∈ |p|` with no domain conjunct (none needed: `τ` is total).
11. **`def:time-shift-histories`** — `τ ≈ₓʸ σ` iff `τ(z) = σ(z + y − x)` for all `z`. A
    **relation** on `H_F`.
12. **`app:auto_existence`** — for every `τ ∈ H_F` and `x, y` there is `σ ∈ H_F` with `τ ≈ₓʸ σ`.
    Constructed as `σ(z) := τ(z + x − y)`, "total since 𝔇 is a group".
13. **`lem:history-time-shift-preservation`** — for `τ, σ ∈ H_F` with `τ ≈ₓʸ σ`:
    `M,τ,x ⊨ φ ⇔ M,σ,y ⊨ φ`. Induction on `φ`; the `□` case uses `app:auto_existence` **in both
    directions** and the IH at the related pair; `Past`/`Future` cases re-derive `≈` at shifted
    times from the defining equation.

### Dependencies

- 6 ← 4, 5; 8 ← 6 + Zorn; 9 ← 2, 8; 13 ← 12 (both directions) + 10.
- 13 does **not** depend on 8. The paper's time-shift lemma never extends a history; it
  constructs a total one directly.

### Potential formalisation challenges (all already handled in the tree except the last)

- Step 3's "nonempty" is data (`PartialHistory.nonempty_domain`) — Decision B.
- Step 10's atom clause at a non-total history — Decision A's accepted `∃ ht` gap.
- Step 11–13's relational shape vs. the tree's `Equiv`-shaped `TruthIso` — **this report's
  subject**; see §3–4.

---

## 2. The triggering question: is the prior reasoning correct?

### 2.1 What the tree states

- `Truth.lean:598` `TimeShift.timeShift_preserves_truth (M) (σ : WorldHistory F) (x y) (φ) :
  TruthAt M (σ.timeShift (y − x)) x φ ↔ TruthAt M σ y φ` — **no** totality hypothesis. 230
  lines (l.598–827), hand-written six-case induction.
- `IntTransfer.lean` `truthAt_map (e) (M) (φ) : ∀ σ σ', Aligned e σ σ' → ∀ t, TruthAt M σ t φ ↔
  TruthAt (M.map e) σ' (e t) φ` — **no** totality hypothesis. ~72 lines, hand-written induction.
- `Truth.lean:1035` `TruthIso` with `hist : F.HF ≃ F'.HF`, `atom` quantified over `τ : F.HF`;
  `truthAt_of_truthIso` (l.1060) transports `τ : F.HF` only.

### 2.2 The reasoning is correct: extension preserves the history, not the truth profile

Take `F` any frame, `M` with `valuation := fun _ _ => True`, `σ` the partial `WorldHistory` with
`domain := (· = 0)`. Then:

- `TruthAt M σ 1 (atom p)` is **False** (`atom_false_of_not_domain`), but for every total
  extension `σ'` (which `thm:extension` guarantees exists) `TruthAt M σ' 1 (atom p)` is **True**.
- Worse, the profiles differ **even at domain times**: `TruthAt M σ 0 (someFuture (atom p))` is
  False (every witness time `s > 0` is off-domain), while it is True at every total `σ'`.

So `thm:extension` yields `Extends σ' σ`, and `Extends` says nothing about `TruthAt`. No total
history has `σ`'s profile, and the `F.HF`-level `truthAt_of_truthIso` cannot reach the
arbitrary-`σ` statement by extension. The 523 blocker record is right on this point, and the
earlier report's §4.3 "yes" was wrong.

### 2.3 But the question is not one the paper asks

`def:BL-semantics` reads, verbatim: "Relative to a model `𝔐`, **possible world `τ ∈ H_F`**, and
time `x ∈ D`, *truth* is defined recursively". Truth at a partial history is **not a paper
notion**. `sec:Construction` says the same in prose: possible worlds *are* "functions from
durations to world states" — total by construction. `lem:history-time-shift-preservation` is
likewise stated for `τ, σ ∈ H_F`.

Consequently:

- Lean's `TruthAt` on an arbitrary `WorldHistory` is a **Lean-side generalisation** forced by the
  predicate encoding (Decision A: the recursion has to be total on the structure).
- Lean's `timeShift_preserves_truth` and `truthAt_map` at arbitrary histories are **strictly
  stronger** than anything the paper proves, and the paper cannot be cited either for or against
  them. `thm:extension` is simply the wrong tool: it is about *existence of extensions*, and
  neither it nor `cor:occurrence` nor `lem:step` mentions truth.
- Every consumer of `timeShift_preserves_truth` in the live tree passes a **total** history (all
  ten call sites checked: `Soundness.lean:307`, `FrameClassVariants.lean:116`,
  `RegionFrame.lean:435,476` (via `regionHistory_isTotal`), `Decidable.lean:689,701,1557`,
  `BoxOracle.lean:249` (`toHF.val`), `ShiftSet.lean:370` (`τ.val`), `Truth.lean:883,886`
  (`box_const`, `ρ` total)). So a totality-restricted restatement would be paper-faithful and
  would break nothing — but §4 shows it is unnecessary, so the 523 plan's "do not weaken" rule can
  be honoured for free.

### 2.4 What the paper *does* licence: the relational box case

Read `lem:history-time-shift-preservation`'s `□` case (l.3660–3667). It needs, for the related
pair `(τ, σ)`:

1. for every `ρ ∈ H_F` a `ρ' ∈ H_F` with `ρ ≈ ρ'` (`app:auto_existence`, forward);
2. for every `ρ' ∈ H_F` a `ρ ∈ H_F` with `ρ' ≈ ρ` (`app:auto_existence`, backward);
3. the induction hypothesis at *any* related pair.

That is a **relation with two existence clauses**, not a bijection `H_F ≃ H_F`. `app:auto_existence`
happens to be witnessed by an involution-up-to-equality, but the proof never uses injectivity,
functionality, or round-trip cancellation. `TruthIso.hist : F.HF ≃ F'.HF` therefore over-specifies
the paper (it demands a bijection and forces the `Equiv.surjective` round trip that
`IntTransfer.lean`'s docstring identifies as the `HEq` trap when attempted at `WorldHistory`
level).

---

## 3. Decision

| Option | What the paper proves | Lean cost | Verdict |
|---|---|---|---|
| **(a)** widen `TruthIso.hist` to `WorldHistory F ≃ WorldHistory F'` + totality-preservation + domain transport | Not the paper's shape: `≈` is a relation. | Building the `Equiv` needs `timeShift (timeShift σ Δ) (−Δ) = σ` as a **structure equality** with dependent `states` — the `HEq` trap `IntTransfer.lean` documents ("Do not replace `Aligned` with an `Equiv`"). | **Reject as phrased.** |
| **(b)** keep the two hand-written inductions | Consistent with the paper (each is a literal transcription of the six cases). | 230 + 72 lines of duplicated induction; acceptance criterion permanently "at most four". | **Reject** — a strictly better option exists. |
| **(c)** relational generic transport (`TruthCorr` below) | **Is** the paper's shape: `Rel` = `≈`, `total_fwd`/`total_bwd` = `app:auto_existence` both ways, `atom` = the base case. | One 45-line induction (identical body to `truthAt_of_truthIso`). Three instances of 10–25 lines. No `Equiv`, no `HEq`. Statements of both blocked theorems **unchanged**. | **Adopt.** |

**Decision: (c).** Grounded in the paper: `lem:history-time-shift-preservation` is proved with a
relation and two existence lemmas, and (c) transcribes exactly that. It is *also* the convenient
Lean choice, but that is a consequence, not the reason.

A secondary, independent finding for the owner: because every consumer is total (§2.3), the tree
could *additionally* choose to state the paper-faithful `H_F`-only corollary
(`timeShift_preserves_truth_total`) as the documented "`lem:history-time-shift-preservation`"
counterpart, keeping the general theorem as a Lean-stronger lemma. This is a documentation
alignment, not a change to any statement.

---

## 4. The relational transport, machine-checked

Full text in `TruthCorr-experiment.lean.txt` (compiles against the current `.lake` build with
`lake env lean`; zero errors, zero `sorry`). The structure:

```lean
structure TruthCorr {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  dur : F.Duration ≃o F'.Duration
  Rel : WorldHistory F → WorldHistory F' → Prop
  atom : ∀ σ σ', Rel σ σ' → ∀ (t : F.Duration) (p : Atom),
    TruthAt M σ t (Formula.atom p) ↔ TruthAt M' σ' (dur t) (Formula.atom p)
  total_fwd : ∀ σ : WorldHistory F, σ.IsTotal → ∃ σ', σ'.IsTotal ∧ Rel σ σ'
  total_bwd : ∀ σ' : WorldHistory F', σ'.IsTotal → ∃ σ, σ.IsTotal ∧ Rel σ σ'

theorem truthAt_of_truthCorr (I : TruthCorr M M') (φ : Formula) :
    ∀ σ σ', I.Rel σ σ' → ∀ t, TruthAt M σ t φ ↔ TruthAt M' σ' (I.dur t) φ
```

Field-by-field paper correspondence: `dur` = the order automorphism `z ↦ z + (y − x)` (or the
`≃+o` for carrier normalisation); `Rel` = `≈` of `def:time-shift-histories` read on arbitrary
histories (it is stated pointwise, so partiality costs nothing); `total_fwd`/`total_bwd` =
`app:auto_existence` in the two directions the `□` case uses; `atom` = the base case of
`lem:history-time-shift-preservation`, stated as atomic-truth agreement (which absorbs the domain
transport — no separate `dom` field is needed, because `TruthAt`'s atom clause already carries
the domain conjunct).

Results verified (`#print axioms`):

| Derived declaration | Statement | Lines | Axioms |
|---|---|---|---|
| `truthAt_of_truthCorr` | generic, arbitrary histories | 45 | `propext`, `Quot.sound` |
| `timeShift_preserves_truth'` via `shiftCorr` | **identical** to `Truth.lean:598` (arbitrary `σ`) | 12 + 27 (instance) | `propext`, `Quot.sound` |
| `truthAt_map'` via `alignedCorr` | **identical** to `IntTransfer.truthAt_map` (arbitrary aligned pair) | 5 + 24 (instance) | + `Classical.choice` (from `≃+o` API) |
| `truthAt_of_truthIso'` via `TruthIso.toCorr` | **identical** to `Truth.lean:1060` | 4 + 17 (instance) | `propext`, `Quot.sound` |

Net effect if adopted: `timeShift_preserves_truth` 230 → ~40 lines; `truthAt_map` 72 → ~30;
`TruthIso` retained as a derived special case (or retired in favour of `TruthCorr` — owner's
choice; `LoopingDuration.loopingTruthIso` and the planned anti-iso twin instantiate either). The
`induction φ` count in `Semantics/ + Independence/` drops from four to **two** (the generic one plus
`FwdRecPeriodicity.truthAt_add_hist_period`, whose per-history hypothesis is genuinely not a
correspondence — the 523 report's analysis of that one stands).

Two tactic notes recorded from the experiment, so the implementer does not re-hit them:

- `shiftCorr.dur` must be `OrderIso.addRight Δ`, not a hand-built `{ toEquiv := Equiv.addRight Δ, … }`;
  the latter leaves an unreduced `let` in the goal that blocks `rw` on `states`.
- In `shiftRel_timeShift_neg`, the state equation at `z + Δ + −Δ` is closed by
  `WorldHistory.states_eq_of_time_eq` with `(add_neg_cancel_right z Δ).symm` — no `HEq`, no
  structure equality, exactly as `aligned_comap` does it.

### Tactic survey (per protocol)

| Goal | Tactic | Result |
|---|---|---|
| `truthAt_of_truthCorr`, all six cases | `simp only [imp_iff/box_iff/untl_iff/snce_iff]` + structured terms | success — the `truth_norm` lemmas suffice; body is the `truthAt_of_truthIso` body with `I.hist.surjective` replaced by `I.total_bwd`/`I.total_fwd` |
| `shiftCorr.atom` | `show` + `rw [hs …]` | success; `simp` alone does not see through `OrderIso.addRight` |
| `timeShift_preserves_truth'` | `change … at h; rw [add_sub_cancel] at h` | success; `simpa` fails to normalise `(OrderIso.addRight Δ) x` |
| `alignedCorr.atom` | reuse of `truthAt_map`'s own `atom` case verbatim | success |

---

## 5. Divergence audit — Lean vs. paper

Legend: **S** Lean stronger · **W** Lean weaker · **Q** differently quantified · **=** faithful ·
**H** hygiene (wording/citation only).

### 5.1 The partial/total distinction and `H_F`

| # | Paper | Lean | Class | Note |
|---|---|---|---|---|
| 1 | partial history: `τ : X → W`, `X` nonempty, unconditional task-respect | `PartialHistory F` {`domain`, `nonempty_domain`, `states`, `respects_task`} | = | Decision B; the `%` comment on the converse convention is honoured by `respects_task` being unconditional and `ofLe` deriving from `converse`. |
| 2 | world history = partial with convex domain (`x < y < z`) | `WorldHistory extends PartialHistory` + `convex` with `x ≤ y ≤ z` | = / H | Logically equivalent (endpoints are already in `X`). The `WorldHistory` docstring's "matching paper definition exactly" overstates: the quantifier shape differs. Suggest "equivalent to". |
| 3 | total ⇔ `X = D` ⇔ possible world | `PartialHistory.IsTotal := ∀ t, domain t`; `WorldHistory.IsTotal` delegates | = | Docstrings note the "possible world" synonym. |
| 4 | `H_F` | `TaskFrame.HF := {τ // τ.IsTotal}`; `FrameOver.HF` delegates | = | Decision A's hybrid predicate/subtype boundary is respected throughout `Semantics/`. |
| 5 | `σ` extends `τ` | `PartialHistory.Extends σ τ`; `τ ≤ σ ↔ Extends σ τ` in `PartialHistoryOrder` | = | Argument order matches the paper's reading "σ extends τ". |
| 6 | (none — paper has no partial-history time shift) | `PartialHistory.timeShift`, `WorldHistory.timeShift` on **arbitrary** histories | S | `def:time-shift-histories`/`app:auto_existence` are `H_F`-only. Harmless; `isTotal_timeShift` is the paper's "total since 𝔇 is a group". |

### 5.2 `thm:extension` and its apparatus

| # | Paper | Lean | Class | Note |
|---|---|---|---|---|
| 7 | `thm:extension` | `PartialHistory.extension (F) (τ : PartialHistory F) : ∃ σ : F.HF, Extends σ.val.toPartialHistory τ` | = | Statement transcribed on the nose; proof = `exists_maximal_extension` (Zorn) + `isTotal_of_isMax` (`lem:step`) + `total_isConvex`. |
| 8 | `lem:step`, sole *Saturation* site | `PartialHistory.step` (`Extension/Step.lean`), reads `F.saturation` | = | |
| 9 | `lem:nesting`/`lem:nonempty`/`lem:constraint`/`lem:admissible` | `Extension/Constraint.lean`, `Admissible.lean`, `FrameAxioms.lean` | = | `Admissible.lean` still names a retired `lem:fibers` anchor (README acknowledges it as DANGLING). H. |
| 10 | `cor:saturation-finite` | `TaskFrame.saturation_of_finite` (`TaskFrame.lean:1078`) | = | |
| 11 | `cor:occurrence`: `∃ τ ∈ H_F, τ(x) = w`, hence `H_F ≠ ∅` | `PartialHistory.occurrence`, `hF_nonempty (F) (w)` | = / H | `hF_nonempty` takes `w` explicitly although `F.worldNonempty` exists; documented as a choice. |
| 12 | `lem:nullity` `w ⇒₀ w` | `TaskFrame.nullity`, `nullity_of_serial_limit` | = | |
| 13 | Zorn ⇒ ZFC | `Classical.choice` appears in `extension`'s axioms | = | Matches the paper's footnote. |

### 5.3 `def:frame` conventions

| # | Paper | Lean | Class | Note |
|---|---|---|---|---|
| 14 | four axioms + nonempty `W` + converse *convention* | `FrameOver` fields: `worldNonempty`, `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `saturation` | S (redundant) / = (extensional) | `nullity_identity` is derivable from `limit` (+ `serial` for the reflexive half) and its docstring says so; kept for construction ergonomics. `converse` packages the convention as data since a two-sided `TaskRel` cannot carry the stipulation in its type. The frame class is extensionally the paper's (`nullity_iff_of_serial_limit`). |
| 15 | *Compositionality* is a biconditional on `x, y ≥ 0` | `comp : Compositional TaskRel` (both directions); `forward_comp`/`interpolates` projections | = | |
| 16 | *Limit* `⋂_{x>0}(w)_x = {w}` | `limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w` | = | The `⊇` half is `lem:nullity`, supplied by `nullity`. |
| 17 | `def:frame-properties` Discrete/Dense/Complete | `TaskFrame.IsDiscrete/IsDense/IsComplete`, plus `IsSuccArchDiscrete` (`def:TMplus-f`) | = / S | The Hölder narrowing is a deliberate documented split. |
| 18 | axiom name *Saturation* (live paper) | `TaskFrame.Saturation` | = | The tree already tracks the paper's rename from *Spherical*; the **record file** does not (see #26). |

### 5.4 Truth and its transports — the differently-quantified sites

| # | Paper | Lean | Class | Note |
|---|---|---|---|---|
| 19 | truth defined at `τ ∈ H_F` | `TruthAt M (τ : WorldHistory F) t φ` — any history | Q / S | Forced by the predicate encoding (Decision A). Pointwise identical on `H_F`. |
| 20 | atom clause `τ(x) ∈ |p|` | `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` | Q | Decision A's accepted gap; equal on `H_F`. This is the clause that makes §2.2's counterexample bite. |
| 21 | `□` over `σ ∈ H_F` | `∀ σ, σ.IsTotal → …` | = | |
| 22 | `lem:history-time-shift-preservation` for `τ, σ ∈ H_F` | `timeShift_preserves_truth` for arbitrary `σ` | Q / S | Every live consumer is total (§2.3). Derivable unchanged from the relational transport (§4). |
| 23 | `def:time-shift-histories` is a **relation**; `app:auto_existence` is two-directional existence | `TruthIso.hist : F.HF ≃ F'.HF` (bijection) | S | Over-specifies the paper; the `□` case of the paper's proof uses only existence both ways. The relational `TruthCorr` is the faithful shape. |
| 24 | (none) | `IntTransfer.truthAt_map`, `FrameOver.map`, `Aligned` | Lean-only | Carrier normalisation to `ℤ` has no paper counterpart; it is proof infrastructure for `ValidDiscrete ↔ ValidInt`. `Aligned` is already relational — it is a `TruthCorr.Rel` verbatim (§4). |
| 25 | `def:BL-semantics` temporal clauses strict | `untl`/`snce` guard-first, strict, open guard | = | Per `specs/decisions/untl-snce-argument-order.md`. |

### 5.5 Hygiene defects (wording / citation / record drift)

| # | Location | Defect |
|---|---|---|
| 26 | `specs/paper-definitions-of-record.md` | `scripts/check-paper-definitions.sh` **FAILS**: 10 anchors drifted from the live paper, including `def:frame` (record still says *Spherical*, live says *Saturation*; `\bf` → `\it`), `def:world-history` (record: "The set of all total world histories over 𝔉 is denoted `H_F`"; live: "The set of all possible worlds over 𝔉 is denoted `H_F`"), `thm:extension` (footnote wording), `def:time-shift-histories` (record has the *translation* form `ā(z) = z + d`; live has `τ(z) = σ(z + y − x)`). All substantively equivalent; the record needs re-pinning. Every Lean docstring that quotes `def:world-history`'s last sentence quotes the **record's** stale wording. |
| 27 | `Truth.lean:9,16` | Cites `def:BL-semantics` by raw line numbers "lines 1857-1872" and "line 892" — both stale (live: l.3593) and contrary to the tree's cite-by-label convention. |
| 28 | `WorldHistory.lean` (`timeShift` docstring) | "**Paper Reference**: app:auto_existence (line ~2330)" — stale (live: l.3618) and a raw line number. |
| 29 | `WorldHistory.lean` (`convex` docstring) | "matching paper definition exactly" — the paper's convexity is strict `x < y < z`; Lean's is `≤`. Equivalent, not identical; say so. |
| 30 | `Extension/Admissible.lean` | Names the retired `lem:fibers` anchor (already flagged in the directory README). |

---

## 6. Recommendations (for the planner)

1. **Land `TruthCorr` in `Truth.lean`** beside `TruthIso`, with `truthAt_of_truthCorr` as the
   single generic induction. Docstring it against `def:time-shift-histories`,
   `app:auto_existence`, and the `□` case of `lem:history-time-shift-preservation` — that is where
   its shape comes from.
2. **Derive `timeShift_preserves_truth` and `IntTransfer.truthAt_map` from it, statements
   unchanged.** Instances `shiftCorr` (with `ShiftRel`) and `alignedCorr` are in the experiment
   file; port verbatim. Delete the two hand-written inductions.
3. **Make `TruthIso` a derived special case** (`TruthIso.toCorr`) or retire it; if retained,
   re-prove `truthAt_of_truthIso` as the one-liner in the experiment. `LoopingDuration` and the
   planned `TruthAntiIso` twin are unaffected either way (the anti-iso is a `TruthCorr` with
   `dur` an order anti-isomorphism and the temporal cases swapped — the same relational shape).
4. **Restate the 523 acceptance criterion** as "at most two `induction φ` truth-transport
   proofs in `Semantics/ + Independence/`" (generic + `truthAt_add_hist_period`).
5. **Do not narrow `timeShift_preserves_truth` to `H_F`.** It is not required for fidelity (the
   paper is silent on partial-history truth), the general form is free, and the 523 plan
   prohibits it. Optionally add the `H_F`-specialised corollary as the documented
   `lem:history-time-shift-preservation` counterpart.
6. **Re-pin `specs/paper-definitions-of-record.md`** against the live paper (10 anchors) and
   update the Lean docstrings quoting the stale `def:world-history` sentence to "The set of all
   possible worlds over 𝔉 is denoted `H_F`" — this is what the paper now says, and it is
   equivalent to the old wording by the definition's own "equivalently".
7. **Fix the three raw-line-number citations** (#27, #28) and the "exactly" overclaim (#29).
8. Keep `FrameOver.nullity_identity` as is; its redundancy is documented and mathematically
   settled. No action.

None of the above requires a `sorry`, a new axiom, or any statement weakening.
