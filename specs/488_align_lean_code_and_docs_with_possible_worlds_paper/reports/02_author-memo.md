# Author Memo: Paper-Side Corrections and Owner Decisions

**Subject**: `possible_worlds.tex` (JPL submission) vs. the Lean 4 tree at
`github.com/benbrastmckie/BimodalLogic`
**Paper file**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
**Paper state verified against**: 4,856 lines, md5 `24d08a9f3f697188d2c6b175ab8f11ff`,
mtime 2026-08-21 10:59 PDT

## Preamble

`possible_worlds.tex` is **read-only from this repository**. Nothing in this memo was edited into
the `.tex`. Every entry below is a **request or a question addressed to the author** — not a
change that has been made, and not a change this repository will make.

The memo collects the alignment items that this repository cannot resolve on its own, for one of
two reasons: either the correct fix belongs in the paper (§1), or the fix is an owner decision
about the Lean tree that a documentation sweep has no standing to make (§2). Every repo-side item
that *could* be fixed here is being fixed in the accompanying implementation phases and does not
appear in this memo.

Every paper line cited below was read in the live `.tex` before being written here, and every Lean
counter-claim was confirmed to name a declaration that exists. §3 records that audit, including the
two places where the source research report's own citations were imprecise.

---

## 1. Paper corrections requested

### D1: TM⁺ strong completeness is attributed to a Lean result that is conditional

**Paper text.** `cor:tm-completeness` (`\label{cor:tm-completeness}`, `:4657`) states at `:4661`:

> `\item[\bf TM$^+$] Strongly complete over all task frames.`

and its footnote at `:4668`:

> `These results, together with the soundness of the corresponding systems, have been established
> in the Lean 4 [repository] for this paper, and so their proofs are not reproduced here.`

**Lean counter-evidence.** No unconditional strong-completeness theorem for the base class exists.
What exists is a *reduction*:

- `Metalogic.strongCompletenessBase_of_compact`
  (`FormalSystem/Metalogic/StrongCompleteness.lean:305`) —
  `(hc : CompactBase) → (engine : ∀ ψ, valid ψ → Derivable FrameClass.Base [] ψ) →
  StrongCompletenessBase`.
- `CompactBase` (`FormalSystem/Metalogic/SetConsequence.lean:219`) and
  `StrongCompletenessBase` (`SetConsequence.lean:211`) are `Prop`-valued **definitions**, not
  theorems. `CompactBase`'s own docstring calls it "An **open obligation**".
- A repository-wide search for any declaration inhabiting `CompactBase` returns nothing outside
  the hypothesis binder of `strongCompletenessBase_of_compact` itself:
  `grep -rn "CompactBase" FormalSystem/ --include=*.lean` hits only
  `StrongCompleteness.lean`, `SetConsequence.lean`, and two prose lines in `Metalogic.lean`
  (`:92`, `:146`), all of which describe it as open.
- `StrongCompleteness.lean:290` states it outright: "**Status of `CompactBase`.** Open — neither
  proved nor refuted."

What *is* proved at the base class is weak completeness — `Metalogic.completeness_base`
(`StrongCompleteness.lean:564`), `valid φ → Derivable FrameClass.Base [] φ` — and
finite-context consequence completeness, `Metalogic.consequence_completeness_base`
(`StrongCompleteness.lean:535`).

**Why the paper's claim is unsupported.** The row at `:4661` asserts *strong* (arbitrary-`Γ`)
completeness and `:4668` attributes it to the repository. The repository proves the weak and
finite-context forms and isolates the infinitary gap as a named, undischarged hypothesis. The
attribution therefore overstates what is machine-checked.

**Correction suggested.** Either (a) weaken `:4661` to "Weakly complete over all task frames"
(optionally adding "strong completeness reduces to compactness of the base consequence relation,
which is open"), or (b) keep the row and narrow `:4668` so the Lean attribution covers soundness
and weak completeness only.

---

### D2: TM⁺_d strong completeness — same defect

**Paper text.** `:4662`:

> `\item[\bf TM$^+_\textsc{d}$] Strongly complete over the dense task frames.`

covered by the same footnote at `:4668`.

**Lean counter-evidence.** Structurally identical to D1:

- `Metalogic.strongCompletenessDense_of_compact` (`StrongCompleteness.lean:331`) is conditional on
  `CompactDense`.
- `CompactDense` (`SetConsequence.lean:263`) and `StrongCompletenessDense` (`:256`) are `Prop`
  definitions; nothing inhabits `CompactDense`.
- `StrongCompleteness.lean:328` states that `CompactDense` "is the whole of the remaining
  obligation for Dense strong completeness"; `:636` records the class as "neither proved nor
  refuted".
- Proved at Dense: `Metalogic.completeness_dense` (`StrongCompleteness.lean:672`, weak) and
  `Metalogic.consequence_completeness_dense` (`:639`, finite context).

**Correction suggested.** Same options as D1, applied to `:4662`.

**A note on `:4666`.** The sentence immediately following the list already reads:

> `Strong completeness provably fails for $\Z$-time as well as for the dense-and-complete class
> $\R$ where compactness fails, and so weak completeness is the appropriate target.`

The paper is thus already alert to compactness as the pivot; the tree's position is that the same
compactness question is *open* (not settled affirmatively) for the base and dense classes, which is
why rows `:4661` and `:4662` cannot yet be attributed. The refutation for Discrete is
machine-checked — `Metalogic.strongCompletenessDiscrete_refuted`
(`FormalSystem/Metalogic/DiscreteNonCompactness.lean:280`) — so `:4666`'s `\Z`-time half is
supported; only its silence about Base and Dense is at issue.

---

### D3: `:1706` contradicts the paper's own `:4683`

**Paper text.** `:1706`:

> `By contrast, the semantics for $\Box$ quantifies over the possible worlds in $H_\F$ without
> binding traces within the object language, making \textbf{TM}$^+$ decidable as implemented in
> the Lean 4 [repository] for this paper.`

**The paper's own contrary statement.** `cor:tm-decidability` is **fully commented out**
(`:4672`-`:4684`). Its commented statement at `:4673` reads "Whether **TM**, **TM**_f, **TM**_d,
**TM**_c, and **TM**_dc are decidable is open", and its commented proof closes at `:4683`:

> `A verified \textit{sound} tableau procedure exists in the Lean 4 [repository], and the semantic,
> truth-connected finite model property for the $\Z$-time discrete case is the target of dedicated
> ongoing formalization; no decidability theorem is machine-checked at present.`

**Lean counter-evidence.** `:4683` is the accurate description.

- Proved, one direction only: `Metalogic.Decidability.sound_of_isValid`
  (`FormalSystem/Metalogic/Decidability/Correctness.lean:100`) and its corollary
  `isValid_sound` (`:111`), both giving `isValid φ fc = true → ⊨ φ`.
- Not proved, and deliberately not stated: the completeness direction. `Correctness.lean:216-222`
  records it explicitly — "The *completeness* direction, `⊨ φ → isValid φ fc = true` — and hence
  the biconditional `isValid φ fc = true ↔ ⊨ φ` and the `Decidable (⊨ φ)` instances for the four
  frame classes — requires `valid_iff_allClosed` … That obligation is open."
- Two earlier theorems that *looked* like decidability were retired for vacuity:
  `Correctness.lean:185-200` records that `validity_decidable` was `Classical.em (⊨ φ)` and
  `validity_has_decision_procedure` was the same with a `Bool` wrapped around it. Neither produced
  a procedure or a `Decidable` instance.

**Why the paper's claim is unsupported.** `:1706` asserts decidability *as implemented*, i.e. as a
machine-checked fact. No such theorem exists, and the paper's own `:4683` says so.

**Correction suggested.** Reconcile `:1706` to the `:4683` wording — e.g. "…without binding traces
within the object language, unlike HyperLTL, whose satisfiability problem is undecidable. Whether
**TM**⁺ is decidable is open; a *sound* tableau procedure is verified in the Lean 4 repository."
The contrast with HyperLTL that `:1706` is drawing survives intact under that weakening: the point
is the absence of trace quantifiers, not a decidability theorem.

---

### D4: "The results throughout are formalized in Lean 4" over-scopes at `:1801`

**Paper text.** `:1801`, sitting at the opening of `\section{Appendix}` (`:1792`,
`\label{sec:Appendix}` at `:1793`), immediately after the paragraph at `:1796`-`:1800` that
enumerates every appendix subsection:

> `The results throughout are formalized in Lean 4 in the repository.`

**Lean counter-evidence.** Three appendix blocks have **no** Lean counterpart at all — not a
partial one, not a differently-named one. Searched by concept rather than by name:

| Paper block | Live line span | Lines | Lean |
|---|---|---|---|
| `app:ObjectiveModality` (`\label` at `:1810`) | 1809-2246 | 438 | none |
| `app:TwoDimensional` (`\label` at `:2248`) | 2247-2758 | 512 | none |
| Task topology (`def:task-topology` `:2872`; `app:topology-t1` `:2904`; `app:topology-r0` `:2923`) | 2872-2888, 2904-2955 | 69 | none |
| Interval site / behavior presheaf / Conduché (`rmk:interval-sheaf` `:3189` through `rmk:shift-finite-type`, ending `:3563`) | 3189-3563 | 375 | none |

**Total: ~1,394 of the paper's 4,856 lines**, about 29%. Confirmed absent by
`grep -rln "presheaf\|Conduche\|Conduché\|twisted arrow\|interval site" FormalSystem/ --include=*.lean`
→ no files, and
`grep -rn "TaskTopology\|task topology\|basic open\|ball space" FormalSystem/ --include=*.lean`
→ no hits.

The source research report gave this figure as "~1,500 lines" and drew the third block as
`2872-3565`. That span is too wide: it sweeps in `lem:nullity` (`:2889`), `def:world-history`
(`:2956`), `def:constraints` (`:3021`), `lem:admissible` (`:3074`), `lem:step` (`:3102`),
`cor:spherical-finite` (`:3116`), `thm:extension` (`:3128`), and `cor:occurrence` (`:3146`) — all
of which **do** have Lean counterparts (`FormalSystem/Semantics/FrameAxioms.lean`,
`FormalSystem/Semantics/WorldHistory.lean`, `FormalSystem/Semantics/Extension/Extension.lean`). The
corrected figure is ~1,394, and the corrected block boundaries are those in the table above. The
substance of the discrepancy is unchanged; only the arithmetic and the boundaries are.

**Why the paper's claim is unsupported.** `:1801` sits at the head of the appendix and scopes over
every subsection the preceding paragraph names, including `app:ObjectiveModality` and
`app:TwoDimensional`, which it names at `:1796` and `:1798`. Roughly three of every ten appendix
lines have no formal counterpart.

**Correction suggested.** Scope the sentence to the material it is true of, e.g. "The task
semantics of **§**`app:TaskSemantics`, the frame correspondence results of
**§**`app:Extensions`, and the soundness and completeness results of **§**`app:Soundness` are
formalized in Lean 4 in the repository." That leaves the objective-modality, two-dimensional, and
categorical material correctly unattributed.

---

### D5: `thm:TM-soundness` has no direct Lean counterpart today

**Paper text.** Three attribution sites, all verified live:

- `:4484` — `\begin{Tthm}[Soundness] \label{thm:TM-soundness}`, stating `If $\vdash \varphi$, then
  $\vDash \varphi$` for **TM** over `BL`.
- `:4494` — its proof's closing footnote: `The repository … implements the soundness theorem for
  \textbf{TM} in Lean 4, providing formal verification for this result.`
- `:4311` — `The full soundness proof, for \textbf{TM} and the \textbf{TM}$^+$ systems below, has
  been formalized in the [Lean 4 repository] for this paper.`
- (A fourth, in the body: `:1661` — `The soundness theorem \textbf{\ref{thm:TM-soundness}} for
  \textbf{TM} and its extension \textbf{TM}$^+$ … implemented in Lean 4 …`. Same claim, same
  status.)

**Lean counter-evidence.** The **TM⁺** half of every one of those sentences is fully supported.
`Metalogic.soundness` (`FormalSystem/Metalogic/Soundness.lean:1080`), `soundness_dense` (`:1254`),
`soundness_discrete` (`:1400`), and `soundness_dedekind` (`:1927`) are all proved and sorry-free.

The **TM** (base-language) half is not. `FormalSystem/BaseLanguage/` contains `Formula.lean`,
`Axioms.lean` (a 16-constructor transcription of the paper's TM), `Derivation.lean`,
`Translation.lean`, and `AxiomDischarge.lean` — and no soundness theorem:
`grep -rn "soundness" FormalSystem/BaseLanguage/*.lean` returns nothing. The result would follow
by composing `Metalogic.Conservativity.translate` with `Metalogic.soundness`, but that composition
is not stated anywhere in the tree.

**Repo-side status.** This one *is* being resolved on the repository side, but not in the present
documentation sweep. It has been split out into a separate follow-on task, "prove BaseLanguage
soundness at FrameClass.Base and extend it to the Dense, Discrete and Dedekind extensions", which
establishes soundness at `FrameClass.Base` first and then extends it — the same Base-then-extensions
shape `Metalogic/Soundness.lean` already uses for TM⁺. The obligation is tracked there. It is a
proof-architecture change, not a docstring correction, which is why it is not bundled here.

**Question for the author.** Do you additionally want a **paper-side hedge** until that task lands
— narrowing `:4311`, `:4494`, and `:1661` to attribute **TM⁺** soundness only, and leaving
`thm:TM-soundness` itself as an unattributed pen-and-paper result? This is the one item in §1 where
the repository is on track to make the paper's claim true rather than asking for it to be weakened,
so the hedge is optional and depends on the submission timeline relative to that task.

---

## 2. Owner decisions required

Each of these states a question and its options. None is decided here.

### D6: `BX_c` has no density axiom, but `FrameClass.Dedekind` admits the density axioms

**The situation.** `def:TMplus-c` (`\label{def:TMplus-c}` at `:4622`) defines the Complete
Burgess–Xu logic `BX_c` as the smallest extension of the base `BX` by exactly two axioms
(`:4625`-`:4626`):

- `TMP-PU` (Prior-U): `(\varphi\until\top) \wedge \future\neg\varphi \rightarrow
  \varphi\until(\neg\varphi \vee K^+\neg\varphi)`
- `TMP-SEP` (Sep): `K^+\varphi \wedge \neg K^+(\varphi \wedge (\neg\varphi\until\varphi))
  \rightarrow K^+(K^+\varphi \wedge K^-\varphi)`

No density axiom. (`TMP-CO` is noted at `:4628`-`:4632` as a derived theorem of `BX_c`, not a
further axiom.) `def:TMplus` (`:4645`) then defines `TM⁺_c` as `TM⁺` plus the axioms distinguishing
`BX_c`.

The Lean side routes axioms by minimum frame class
(`FormalSystem/ProofSystem/Axioms.lean:588-597`), and `FrameClass.Dense ≤ FrameClass.Dedekind`
holds in the `LE FrameClass` instance (`Axioms.lean:526-533`). Consequently a derivation at
`FrameClass.Dedekind` may use **42** of the tree's 45 axiom constructors: the 37 Base ones, plus
`density` (`Axioms.lean:358`) and `dense_indicator` (`:369`) inherited from Dense, plus the three
Reynolds axioms `prior_U_gap` (`:431`), `prior_S_gap` (`:441`), and `sep` (`:452`). Only the three
Discrete constructors are excluded. And `Metalogic.completeness_dedekind`
(`FormalSystem/Metalogic/StrongCompleteness.lean:469`) is stated against `ValidDedekindDense`, i.e.
the dense-and-complete class — matching `:4664`'s "Weakly complete over the dense-and-complete
class", but from a *strictly larger* axiom set than `BX_c` as the paper defines it.

(This 42 is unrelated to the stale "42 axiom constructors" figure in several in-tree docstrings,
which is a separate defect being corrected to 45 elsewhere in this sweep. The coincidence is
arithmetic: 45 − 3 Discrete = 42, and 37 + 2 + 3 = 42.)

**The question.** The paper's `TM⁺_c` as axiomatized is weaker than the system Lean's
`completeness_dedekind` is about, yet `cor:tm-completeness` claims completeness for it over the
dense-and-complete class.

- **Option A — change the paper.** Add `TMP-DN` and `TMP-NN` (the two `BX_d` axioms, `:4610`-`:4611`)
  to `BX_c`, so that `TM⁺_c` and Lean's Dedekind system coincide. Note that `:4664` already
  restricts the target class to *dense*-and-complete, which makes the density axioms natural rather
  than a strengthening of the intended system — this is arguably the paper simply not having stated
  what it meant.
- **Option B — record the mismatch in the tree.** Leave `def:TMplus-c` alone and document at the
  `completeness_dedekind` site that it proves a *stronger-premise* statement than the paper's
  `TM⁺_c` row: completeness of `BX_c + BX_d` over the dense-and-complete class, which does not
  entail the paper's row for `BX_c` alone.

The two options have different mathematical content — B leaves the paper's `TM⁺_c` completeness row
unformalized. A decision is needed before either the paper's row or the Lean docstring can be called
accurate.

---

### D24: two Lean axiom constructors are definitionally vacuous

**The situation.** `Formula.top` is `Formula.bot.imp Formula.bot`
(`FormalSystem/Syntax/Formula.lean:134`) and `Formula.someFuture φ` is `Formula.untl Formula.top φ`
(`:147`). The axiom constructor

```
| F_until_equiv (φ : Formula) :
    Axiom ((Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))
```

(`FormalSystem/ProofSystem/Axioms.lean:270-271`) therefore has the shape `X.imp X` with the two
sides the *same term* — the report verified both this and its past dual `P_since_equiv`
(`Axioms.lean:275-276`, over `somePast`/`snce`, `Formula.lean:157`) by `rfl`. Two of the 37 Base
constructors carry no content.

The paper has the identical degeneracy and is not *wrong* about it: `TMP-UT` is `F\varphi
\rightarrow (\top \until \varphi)` while `def:BLplus-defined` (`:3745`) sets
`\future\varphi \coloneq \top\until\varphi` (`:3751`). Both sides are stating an identity as an
axiom.

**The question.** Should the two Lean constructors be retired?

- Retiring them is a **45 → 43** change. It touches every axiom count in the tree, plus the
  soundness case splits that name them — `Metalogic/Soundness.lean:888-889`, `:948-949`,
  `:1010-1011`, `:1120-1121`, `:1294-1295`, `:1779-1780` and
  `Metalogic/SoundnessLemmas/FrameClassVariants.lean:312-315`, `:600-601` — and the two validity
  lemmas `F_until_equiv_valid` / `P_since_equiv_valid` (`Soundness.lean:367`, `:376`).
- It collides directly with the 42 → 45 docstring correction this sweep is making, which is why it
  is **deliberately not attempted here**. The two changes must never be in the same plan.
- The counter-argument for keeping them: they are harmless, and they preserve a
  constructor-for-axiom correspondence with the paper's `TMP-UT`.

No recommendation is made. If retirement is wanted, it should be its own task, sequenced *after*
the 45 figure has landed everywhere.

---

### D25 (ergonomic half): `nullity_identity` is now known derivable — delete the field or keep it?

**What is settled.** The `TaskFrame.nullity_identity` field
(`FormalSystem/Semantics/TaskFrame.lean:511`, `∀ w u, TaskRel w 0 u ↔ w = u`) currently carries a
docstring at `TaskFrame.lean:501-509` calling itself "**Strictly stronger than the paper — OPEN
DESIGN QUESTION**". **That is false, and the question is closed.** The `↔` is derivable from the
`serial` (`TaskFrame.lean:556`) and `limit` (`:566`) fields already present:

- *Injectivity at zero* follows from `limit` alone, instantiating the cone witness at `y := 0`:
  if `R w 0 u` then for every `x > 0` we have `|0| < x` and `R w 0 u`, so `u` lies in every positive
  cone of `w`, so `limit` gives `u = w`.
- *Reflexivity* is then `TaskFrame.nullity_of_serial_limit`
  (`FormalSystem/Semantics/FrameAxioms.lean:149`) — `serial` at `x = 0` (and `Serial` does admit
  `x = 0`: `TaskFrame.lean:358-359` binds `0 ≤ x`) composed with the same `limit`.

The research report supplies both Lean proofs, typechecked. **The paper already runs exactly this
argument**: `:4090` reads "For if $w \Rightarrow_0 u'$, then $u' \in \fib{w, 0} \subseteq (w)_y$ for
every $y > 0$ since $\vert{0} < y$, and so $u' \in \bigcap_{y > 0} (w)_y = \set{w}$ by
\textit{Limit}, giving $u' = w$; together with \textbf{\ref{lem:nullity}} this makes $\Rightarrow_0$
the identity on $W$." So the Lean frame class is extensionally **exactly** the paper's, not a proper
subclass, and there is no divergence to report to the author here.

The false docstring is being corrected in this sweep regardless of the decision below.

**The question — purely ergonomic, not mathematical.** Should the `nullity_identity` *field* be
deleted and replaced by a derived lemma?

- **Option A — delete the field.** Cleaner: the structure then states only independent content.
  Cost: it is a breaking change for **18 construction sites across 12 files**
  (`grep -rn "nullity_identity :=" FormalSystem/ Tests/ --include=*.lean` → 18 hits), each of which
  currently discharges the field directly and would instead need to be reachable from `serial` +
  `limit`. Several of those sites are `Subsingleton`/trivial frames where the field is discharged
  by `Iff.rfl` (`TaskFrame.lean:1225`) or `Subsingleton.elim` (`:1163`) and the derived route may be
  more work, not less.
- **Option B — keep the field as documented redundancy.** Zero churn, and the field stays available
  as a one-step rewrite in proofs that use it (e.g. `TaskFrame.lean:612-615`). Cost: the structure
  carries a derivable field, which a reader may mistake for independent content unless the docstring
  says otherwise — which, after this sweep's correction, it will.

No recommendation is made.

---

### D27: `▽φ` — no change recommended

**The situation.** `def:BLplus-defined` (`:3745`) defines, at `:3755`:

> `\item[\bf Sometimes:] $\sometimes\varphi \coloneq \past\varphi \vee \varphi \vee
> \future\varphi$.`

an explicit three-way disjunction. Lean defines it as the dual of `always`:

```
def sometimes (φ : Formula) : Formula := φ.neg.always.neg
```

(`FormalSystem/Syntax/Formula.lean:616`), i.e. `▽φ := ¬△¬φ`.

**Assessment.** Classically equivalent — `always φ` is `Past φ ∧ φ ∧ Future φ` on both sides
(`:3754`), so the two definitions differ by De Morgan only, and the Lean docstring
(`Formula.lean:604-615`) already records the equivalence. But they are **term-distinct**: `▽φ`
unfolds to different `Formula` values on the two sides, which matters to any proof or tactic that
matches on syntactic shape.

**Recommendation: no change**, on either side. It is recorded here so it is not rediscovered as a
defect later. If anything is wanted, it would be a one-clause note in the paper that the Lean
formalization takes `▽` as the dual of `△` rather than as the primitive disjunction — cosmetic, and
not requested.

---

## 3. Verification record

### Paper lines checked (live `.tex`, 4,856 lines, md5 `24d08a9f…`)

| Cited | Resolves as claimed? | Live evidence |
|---|---|---|
| `:1706` | **Yes**, exact | "making \textbf{TM}$^+$ decidable as implemented in the Lean 4 …repository… for this paper" |
| `:1801` | **Yes**, exact | "The results throughout are formalized in Lean 4 in the repository." |
| `:4311` | **Yes**, exact | "The full soundness proof, for \textbf{TM} and the \textbf{TM}$^+$ systems below, has been formalized in the …Lean 4 repository…" |
| `:4484` | **Yes**, exact | `\begin{Tthm}[Soundness] \label{thm:TM-soundness}` |
| `:4494` | **Yes**, exact | footnote "…implements the soundness theorem for \textbf{TM} in Lean 4…" |
| `:4622` | **Yes**, exact | `\begin{Ddef} \label{def:TMplus-c}`; the two axioms follow at `:4625`-`:4626` |
| `:4635`-`:4640` | **Substantively yes; range imprecise** | the commented `\{\Z,\R\}` footnote body is `:4635`-`:4638`, opened by the commented `\footnote{%` at the end of `:4634`; `:4639` is `\end{Ddef}` and `:4640` is blank. Content is where claimed; the range overshoots by two lines. |
| `:4661` | **Yes**, exact | `\item[\bf TM$^+$] Strongly complete over all task frames.` |
| `:4662` | **Yes**, exact | `\item[\bf TM$^+_\textsc{d}$] Strongly complete over the dense task frames.` |
| `:4664` | **Yes**, exact | `\item[\bf TM$^+_\textsc{c}$] Weakly complete over the dense-and-complete class.` |
| `:4668` | **Yes**, exact | "These results, together with the soundness of the corresponding systems, have been established in the Lean 4 …repository…" |
| `:4683` | **Yes**, exact | "…no decidability theorem is machine-checked at present." Commented. |

**No cited line had moved.** All twelve resolve at the line given. Additional live lines confirmed
while checking: `:1661` (a fourth TM-soundness attribution, in the body, not previously cited),
`:4666` (the paper's own compactness-failure sentence), `:3745`/`:3751`/`:3755`
(`def:BLplus-defined`), `:2889` (`lem:nullity`), `:4090` (the paper's own injectivity-at-zero
argument), `:1792`-`:1793` (`sec:Appendix`), `:1809`-`:1810`, `:2247`-`:2248`, `:2759`-`:2760`,
`:3689`-`:3690`, `:4305`-`:4306` (appendix subsection boundaries), and `:4672`-`:4684`
(the `cor:tm-decidability` comment block).

### Lean declarations confirmed to exist

| Declaration | Location | Kind |
|---|---|---|
| `Metalogic.strongCompletenessBase_of_compact` | `FormalSystem/Metalogic/StrongCompleteness.lean:305` | theorem, conditional |
| `Metalogic.strongCompletenessDense_of_compact` | `FormalSystem/Metalogic/StrongCompleteness.lean:331` | theorem, conditional |
| `Metalogic.CompactBase` | `FormalSystem/Metalogic/SetConsequence.lean:219` | `Prop` def, undischarged |
| `Metalogic.CompactDense` | `FormalSystem/Metalogic/SetConsequence.lean:263` | `Prop` def, undischarged |
| `Metalogic.StrongCompletenessBase` / `…Dense` | `SetConsequence.lean:211` / `:256` | `Prop` defs |
| `Metalogic.completeness_base` / `_dense` / `_discrete` / `_dedekind` | `StrongCompleteness.lean:564` / `:672` / `:781` / `:469` | theorems, weak |
| `Metalogic.Decidability.sound_of_isValid` / `isValid_sound` | `Decidability/Correctness.lean:100` / `:111` | theorems, one direction |
| `Metalogic.soundness` / `_dense` / `_discrete` / `_dedekind` | `Metalogic/Soundness.lean:1080` / `:1254` / `:1400` / `:1927` | theorems |
| `Axiom.minFrameClass` | `ProofSystem/Axioms.lean:588` | def (routing) |
| `Axiom.density` / `dense_indicator` | `ProofSystem/Axioms.lean:358` / `:369` | constructors → `.Dense` |
| `Axiom.prior_U_gap` / `prior_S_gap` / `sep` | `Axioms.lean:431` / `:441` / `:452` | constructors → `.Dedekind` |
| `Axiom.F_until_equiv` / `P_since_equiv` | `Axioms.lean:270` / `:275` | constructors, vacuous |
| `Formula.top` / `someFuture` / `somePast` / `sometimes` | `Syntax/Formula.lean:134` / `:147` / `:157` / `:616` | defs |
| `TaskFrame.nullity_identity` (field) | `Semantics/TaskFrame.lean:511` | structure field |
| `TaskFrame.Serial` / `.serial` / `.limit` | `Semantics/TaskFrame.lean:358` / `:556` / `:566` | def / fields |
| `TaskFrame.nullity_of_serial_limit` | `Semantics/FrameAxioms.lean:149` | theorem |
| `Metalogic.strongCompletenessDiscrete_refuted` | `Metalogic/DiscreteNonCompactness.lean:280` | theorem (a refutation) |

**Confirmed absent** (searched, not found): any declaration inhabiting `CompactBase` or
`CompactDense`; any `soundness` declaration under `FormalSystem/BaseLanguage/`; any
`valid_iff_allClosed`, `isValid ↔ ⊨` biconditional, or `Decidable (⊨ φ)` instance; any Lean file
mentioning `presheaf`, `Conduche`/`Conduché`, `twisted arrow`, or `interval site`; any task-topology
or ball-space construction.

**Derived counts, independently re-checked**: 45 `Axiom` constructors total (enumerated from
`ProofSystem/Axioms.lean:99`'s `inductive Axiom`); Base 37, Dense 2, Discrete 3, Dedekind 3 by
`minFrameClass`; 42 admissible at `FrameClass.Dedekind`. `nullity_identity :=` appears at 18
construction sites across 12 files.

### Claims from the plan or research report that did **not** check out

1. **D4's block boundaries and line total.** The report's "topology / presheaf / Conduché block
   (2872-3565), roughly 1,500 lines" is too wide and too high. The span `2872-3565` includes
   `lem:nullity`, `def:world-history`, `def:constraints`, `lem:admissible`, `lem:step`,
   `cor:spherical-finite`, `thm:extension`, and `cor:occurrence`, all of which have Lean
   counterparts. Corrected: ~1,394 lines with no Lean counterpart, over the four spans tabulated in
   §1 D4. The discrepancy itself stands; the arithmetic was off by ~100 lines and the boundaries by
   ~300.
2. **The `cor:tm-decidability` comment span.** The report gives `:4672-4688`; the commented block
   actually runs `:4672`-`:4684`, with `:4685` blank and `:4686`-`:4689` a separate editorial
   comment about `rmk:interaction-principles`. The cited content at `:4683` is where claimed.
3. **The `\{\Z,\R\}` footnote range** `:4635-4640` overshoots by two lines (see the table above).
   Content correct.

Everything else in §1 and §2 checked out as stated.

### Paper repository untouched

`git -C /home/benjamin/Philosophy/Papers/PossibleWorlds status --porcelain` reports
` M JPL/possible_worlds.tex` — a **pre-existing** single-line uncommitted edit (`+1` insertion),
mtime 2026-08-21, four days before this memo was written. The file's md5 was
`24d08a9f3f697188d2c6b175ab8f11ff` before and after every operation in this phase; the only access
made to it was `sed -n` and `grep`. No write was performed on `/home/benjamin/Philosophy/` by this
phase.
