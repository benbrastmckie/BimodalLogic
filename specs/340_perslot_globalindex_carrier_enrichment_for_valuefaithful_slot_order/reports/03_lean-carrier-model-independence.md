# Report 03 — Lean Carrier Architecture & the Phase-5 Model-Independence Obstruction

**Agent role**: Agent B (Lean carrier architecture). Territory:
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(2912 lines). Sibling agents own Rabinovich faithfulness (A) and the 337 builder engine
`SubBracket2V.lean` (C). This report does not re-derive either.

**Reference grounding tier**: Tier 3 (implementation-backed). Every claim below is grounded in
a read signature at a cited SharedWitness.lean line. No literature transcription is claimed;
Rabinovich md-references are quoted only as they appear in the code docstrings.

**Method note (H2)**: All claims are cited to a read line/signature. The file is currently
`sorry`-free in the Phase-2 order-type cluster (grep for `sorry` over lines 700-1920 returns
only prose occurrences in comments, e.g. SW:1572, SW:2606, none in tactic position). Phase 5 is
**not yet present in the file** — there is no open `sorry` goal to `lean_goal`, because the
value-faithful obligation has not been written as a theorem yet. The obligation is instead
*latent* in the right-hand side of `kvE2_sepBody_holds_iff` (SW:1112). This is the single most
important structural fact in this report and is developed below.

---

## Findings

### Q1 — What EXACTLY does the completeness witness have to discharge?

There are **two distinct obligations** in the file, and the blocker conflates them:

**(1a) Non-vacuity / membership** — already discharged, `sorry`-free.
`kvE2_sepBody_complete` (SW:1830-1873) has conclusion:

```
kvE2_sepArr' qnf ≠ []
```

Its proof (SW:1839-1873) exhibits `kvE2_sepCoincidentOrder qnf` as a member of
`kvE2_sepArr' qnf` via `List.ne_nil_of_mem`, discharging the three `kvE2_sepDisjValid`
conjuncts: (i) per-owner closed-self-zone validity (`kvE2_sepCoincidentOwner_valid_left/right`,
SW:1853-1854), (ii) per-owner tuple consistency `i₀<i₁<i₂` by `omega` on the placeholder tuple
`(k, n+k, 2n+k)` (SW:1862-1863), (iii) `Nodup` of anchor bases `= List.range'` (SW:1873). This
theorem is complete and needs **nothing further** — it only asserts the carrier is non-empty.
`kvE2_sepCoincidentOrder_mem_arr'` (SW:1881-1919) is the same content factored as a membership
fact for the 337 builder to plug in.

**(1b) Value-faithful holds** — NOT discharged; this is the real Phase-5 gap.
The genuine completeness content is the `.mpr` of `kvE2_sepBody_holds_iff` (SW:1104-1122).
Quoting the biconditional's RHS verbatim (SW:1111-1113):

```
(kvE2_sepBody charBase charK qnf).holds M atomMap x t ↔
  ∃ wo ∈ kvE2_sepArr' qnf,
    (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
      M atomMap x t
```

So to prove the body **holds** in an honest model `M` (the ⇐ direction), one must supply an
**existential**: a `wo ∈ kvE2_sepArr' qnf` such that the disjunct built over
`kvE2_sepSlotsLOf wo`/`kvE2_sepSlotsROf wo` — the mergeSort of the slot multiset **by the
per-slot global index** — actually **`.holds` in M**. It is NOT enough to name a specific `wo`;
the chosen `wo`'s mergeSorted slot order must coincide with `M`'s honest value order, or the
bracket's point/segment content is realized at the wrong model points and `.holds` fails.

**Why the placeholder witness cannot discharge (1b).** `kvE2_sepSlotsLOf wo` (SW:949-951) is
`(owners.flatMap slotsLFor).mergeSort (kvE2_sepSlotMergeLe wo)`, and the merge key
`kvE2_sepSlotGIdx wo s` (SW:921-928) reads the owner tuple at the slot's region rank
(`0→i₀, 1→i₁, 2→i₂`). For `kvE2_sepCoincidentOrder qnf` the tuple is the placeholder
`kvE2_sepPlaceholderTuple n k = (k, n+k, 2n+k)` (SW:728), whose induced global order is
`giOf = regionRank·n + k` — **region-primary**. That reproduces the OLD 339 region-primary
order, which by design (SW:930-935) canNOT express the honest cross-region `a < u' < b`
interleaving where one owner's region-2 slot precedes another's region-0 slot. Hence the
disjunct over the placeholder order does not `.holds` in a model whose honest value order
interleaves owners. **This is the precise, real content of the Phase-5 gap.**

### Q2 — Is the model-independence obstruction genuine?

**Partly. The obstruction is real for the literal claim the blocker states, but false for the
task goal.** Adversarial split:

- **Real** (narrow): `kvE2_sepCoincidentOrder : qnf → KvE2SepWeakOrder` (SW:1682) is a fixed
  function of `qnf` only. Distinct models `M₁, M₂` realize the same `qnf` with **different**
  honest interleavings of the `3n` slots. No single `qnf`-indexed function can return tuples
  matching every model's value order simultaneously. So `kvE2_sepCoincidentOrder` can NEVER
  itself be value-faithful, and "make `kvE2_sepCoincidentOrder` model-dependent without changing
  its signature" is genuinely impossible. The blocker is correct on this point.

- **False** (the actual goal): value-faithful completeness does NOT require making
  `kvE2_sepCoincidentOrder` model-dependent. It requires a model-dependent **selection** of a
  `wo` from the **model-independent** enumeration `kvE2_sepArr' qnf`. The statement
  `∃ wo ∈ kvE2_sepArr' qnf, P(M, wo)` is a perfectly ordinary model-dependent proposition over a
  model-independent carrier — `M` appears in the predicate, not in the type. The carrier stays
  `List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × (ℕ×ℕ×ℕ))` (SW:701-702), unchanged.

**Is the enumeration rich enough to contain the honest `wo`?** Yes, provably.
`kvE2_sepIdxTuples n` (SW:734-737) is `(range 3n).flatMap a => (range 3n).flatMap b =>
(range 3n).map c => (a,b,c)` — i.e. **all** `(a,b,c) ∈ [0,3n)³`. `kvE2_sepOrderTypes`
(SW:756-763) ranges the tuple component over this full set for every owner. Any honest model
value order over the `3n` slots is a bijection into `{0,…,3n-1}`, so every component is `< 3n`
and the honest tuple assignment lies in the enumeration.

**Does validity admit the honest order?** Yes. `kvE2_sepDisjValid` (SW:828-832) requires:
(i) per-owner zone validity — satisfied by the coincident tag exactly as in the current proof
(the honest owners are interior, `kvE2_sepCoincidentOwner_valid_left/right`, SW:1703/1777);
(ii) `kvE2_sepConsistentTuple`, i.e. `i₀<i₁<i₂` per owner (SW:817) — satisfied because `M`'s
total order **refines each owner's region order** (region-0 slot `<` fresh anchor `<` region-2
slot at that owner's realized points, exactly the bounds extracted at SW:1721-1728 /
SW:1795-1802); (iii) `Nodup` of the anchor bases `i₀` (SW:832) — satisfied because distinct
owners realize distinct fresh anchors `x1` in `M`, hence distinct global positions. So the
honest order is a **valid** member. **Verdict: the resolution side wins — the obstruction the
implementer states ("carrier change or vacuous placeholder") is not genuine; a third path
exists and is exactly the `∃ wo ∈ kvE2_sepArr'` lemma the implementer already sketched.**

### Q3 — Where must Phase 5 live?

**Option (a), over the EXISTING carrier — with a 337 input dependency.** Not (c) (no carrier
type change), and not (b) in the sense of the `wo` being *constructed* inside 337 (the `wo` is a
340 carrier value). Decomposition:

- **(A) Define the honest order** `kvE2_sepHonestOrder qnf M w x t : KvE2SepWeakOrder sig`:
  each interior owner tagged `.coincident`, tuple = the owner's three slots' **actual global
  positions in M's honest value order**. Model-dependent definition; the *tuple data* is the
  per-slot realized position, which is what 337's realization engine
  (`k1v_sorted_realizationK` / the monotone-witness machinery in `SubBracket2V.lean`, Agent C's
  territory) produces. **This is the one genuine 337 input.**
- **(B) Membership** `kvE2_sepHonestOrder … ∈ kvE2_sepArr' qnf`: pure 340, mirrors
  `kvE2_sepCoincidentOrder_mem_arr'` (SW:1881) with (ii)/(iii) re-proved for the model tuples
  (needs the "honest tuple ∈ enumeration" lemma of Q4). No 337.
- **(C) Monotonicity** `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` reproduce M's value order:
  pure 340, follows from the tuple definition + `kvE2_sepSlotGIdx` (SW:921) + `mergeSort` sorted
  spec. No 337.
- **(D) The disjunct `.holds M`**: builds the bracket's point/segment content at the now-correct
  model points from the honest bundles — the **337 builder** job
  (`kvE_subBracket2V_sound_of_parts`, `SubBracket2V.lean:1025`, referenced at SW:1927). 337.

So Phase 5's *carrier/selection* content (A structural, B, C) is **340 / SharedWitness**; the
*value realization* content (A's data, D) is **337**. The two meet at the interface below.

**Minimal Lean interface that unblocks `kvE2_sepBody_holds_iff.mpr` (and hence the body's
`.holds`)** — this existential is literally the RHS of SW:1112, so proving it + the gate closes
completeness:

```lean
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK   : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h  : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
             nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    -- 337 input: the per-slot honest realized global order (monotone-in-M witness / builder)
    (hreal : Kv337RealizedSlotOrder charBase charK qnf M atomMap w x t) :
    ∃ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
        M atomMap x t
```

The witness supplied is `wo := kvE2_sepHonestOrder qnf M w x t`, membership by (B), and the
`.holds` by (D) consuming `hreal`. The three purely-340 sub-lemmas (A-structural, B, C) belong
in SharedWitness; `hreal`/(D) is the 337 boundary object.

### Q4 — Enumeration completeness: available or to-be-proven?

**To be proven — but it is a one-lemma gap, not a carrier limitation.** What exists today only
covers the **placeholder** tuple: `kvE2_sepPlaceholderTuple_mem` (SW:740, `k < n → (k,n+k,2n+k)
∈ kvE2_sepIdxTuples n`), `kvE2_sepModelOrder_mem_orderTypes` (SW:877), and
`kvE2_sepCoincidentOrder_mem_orderTypes` (SW:1691) — all specialized to the placeholder tuple.
There is **no** lemma stating that an arbitrary order-consistent tuple is in the enumeration.
The needed generalization is trivial and pure-340:

```lean
theorem kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ)
    (ha : a < 3*n) (hb : b < 3*n) (hc : c < 3*n) :
    (a, b, c) ∈ kvE2_sepIdxTuples n
```

proved by the same three `List.mem_flatMap`/`List.mem_range` steps as
`kvE2_sepPlaceholderTuple_mem` (SW:742-747). With it, "the honest model tuple is a member" is
immediate (honest global indices are a subset of `[0,3n)`). So the enumeration **provably
enumerates a tuple for every order-consistent global interleaving** whose indices fit `[0,3n)`;
the honest-tuple-membership fact is simply **not yet materialized**, not absent-in-principle.

---

## Adversarial Self-Verification

I applied the Claim Verification Bar to every load-bearing claim, and specifically tried to
prove the obstruction IS real (that no model-independent-signature solution exists).

| Claim | Source / Counterexample tested | Verification Method | Confidence |
|-------|-------------------------------|---------------------|------------|
| `kvE2_sepBody_complete` concludes only `kvE2_sepArr' qnf ≠ []`, not `.holds` | SW:1838 conclusion line read directly | read signature (SW:1830-1838) | High |
| The value-faithful obligation is the RHS of `kvE2_sepBody_holds_iff` | SW:1111-1113 verbatim | read signature (SW:1104-1122) | High |
| Placeholder order is region-primary, cannot express cross-region interleave | `kvE2_sepPlaceholderTuple=(k,n+k,2n+k)`, `giOf=rank·n+k`; docstring SW:930-935 disclaims region-primary | read defn (SW:728, SW:921-928) + docstring | High |
| Enumeration = full `[0,3n)³` (rich enough) | `kvE2_sepIdxTuples` triple flatMap over `range (3*n)` | read defn (SW:734-737) | High |
| Validity admits the honest order (i₀<i₁<i₂ + Nodup i₀) | region bounds extracted at SW:1721-1728/1795-1802; distinct anchors → distinct i₀ | read `kvE2_sepDisjValid` (SW:828-832) + Q2 argument | Medium |
| Carrier type unchanged suffices; no type change (refutes option c) | `∃ wo ∈ kvE2_sepArr', P(M,wo)` is model-dep predicate over model-indep type | read carrier type (SW:701-702) + logical argument | High |
| Honest-tuple membership NOT yet proven; needs `kvE2_sepIdxTuple_mem_of_lt` | grep: only placeholder-specialized mem lemmas exist (SW:740, 877, 1691) | grep + read | High |
| `.holds` construction (D) needs 337 builder | SW:1927 references `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025) | read docstring reference | Medium (C owns the engine; interface inferred, not the proof) |

**Adversarial obstruction test (H4).** Strongest case that the obstruction is real: a fixed
`qnf → KvE2SepWeakOrder` function provably cannot be value-faithful across models (Q2 "Real"
bullet) — **this holds and I concede it**. But it does not entail the task is blocked, because
the task never required such a fixed function; it required a value-faithful *witness supply*,
which `∃ wo ∈ kvE2_sepArr' qnf, monotone-in-M` provides over the unchanged carrier. The
implementer's own "What is needed" sentence names exactly this lemma, then mislabels the two
alternatives (carrier change / vacuous placeholder) as the only options. **Resolution side
wins.**

**Contradiction Log.** One partial contradiction with the blocker text, resolved:
the blocker says a value-faithful witness "would require a carrier type change (out of scope) or
a vacuous placeholder (prohibited)." Precedence resolution: a *read signature* (`kvE2_sepArr'`
is `qnf`-indexed but the completeness statement quantifies `∃ wo ∈ …` with `M` free, SW:1112)
outranks a prose blocker claim. Resolved in favor of "no carrier change needed." No UNRESOLVED
contradictions.

**Recommendations modified after verification.** Initially I considered claiming Phase 5 is
"entirely 340-internal." Verification of SW:1927 (the builder reference) and the `.holds`
content of `kvE2_sepDisjunct` forced the split: structural selection (A/B/C) is 340; the
`.holds` realization (A's tuple data + D) crosses into 337. Recommendation corrected to the
interface-with-`hreal` form above.

---

## VERDICT

**Exact unblocking lemma** (the RHS of `kvE2_sepBody_holds_iff`, SW:1112, made a theorem):

```lean
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
             nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (hreal : Kv337RealizedSlotOrder charBase charK qnf M atomMap w x t) :
    ∃ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
        M atomMap x t
```

**Belongs in 340 (SharedWitness)** — the theorem statement, the model-dependent selection
`kvE2_sepHonestOrder`, its membership, its monotonicity, and the enumeration-richness lemma
`kvE2_sepIdxTuple_mem_of_lt` are all pure-carrier work over the **existing** type. The ONE
boundary object it imports from **337** is `hreal` — the per-slot honest realized global order
plus the `.holds` construction from honest bundles (`kvE_subBracket2V_sound_of_parts`,
SubBracket2V.lean:1025). No carrier type change; no vacuous placeholder; `kvE2_sepCoincidentOrder`
stays as-is for non-vacuity. Phase 5 is unblocked as a 340 lemma consuming a 337 interface.
