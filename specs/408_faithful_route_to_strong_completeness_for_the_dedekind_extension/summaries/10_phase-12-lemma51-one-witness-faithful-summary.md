# Phase 12 — Rabinovich Lemma 5.1 at one witness, re-based onto the faithful carrier

- **Plan**: `plans/08_strong-completeness-dedekind-v8.md`, Phase 12
- **Status**: COMPLETED
- **Territory**: `EANegationFixFaithful/NegFixOneFaithful.lean` (owned);
  `EANegationFixFaithful/NegFixListFaithful.lean` (one argument position, deviation D4)
- **Commit**: `184ff2eb5`

## Hard-site verdict: two-arm shape held

`negFixOneFaithful_cover` was the first of v8's two genuinely hard sites and the place R11's bet
had to survive at a five-arm case structure rather than a two-arm one. **It held.** The
`Case1 / Case2 / Case3a/b/c` split came through the re-base with **no case introduced, merged, or
removed** and with its branch structure textually unchanged:

```
by_cases h_occ            -- carrier-free; the paper's Case 2 against the rest
  case neg => Case 2
  case pos => rcases h_INF.first_occ_tp   -- TWO arms, not three
    arm 1 => Case 1
    arm 2 => by_cases hQ / by_cases hs1r  -- Case 3a / 3b / 3c, unchanged
```

The chartered R11 fallback — fall back to `HasDenseDedekindINF`'s trichotomy and add the endpoint
branches Rabinovich's enumeration has no slot for — is **NOT triggered**.

The whole code-bearing delta inside the cover is four tokens:

| site | change | class |
|---|---|---|
| binder | `HasDedekindINF` → `HasFaithfulDedekindINF` | hypothesis weakening |
| Case 1 arm | `kplusLeftBlock_holds` → `kplusOpenLeftBlock_holds` | rename |
| pin construction | `Or.inr h` → `Or.inr (kplusOpen_of_kplus h)` | weakening insertion |
| (mirror in `_sound`) | `obtain ⟨-, hdense⟩ := h1` → apply `h1` directly | `kplusOpen` has no first conjunct |

**Effort datum, matching Phases 11 and 11.1**: zero failed proof attempts; scoped build green on
the **first** attempt; no proof-search tool (`lean_multi_attempt`, `lean_state_search`,
`lean_hammer_premise`) invoked at any point in the phase.

## Why it held — the transcription, not luck

The plan required transcribing Rabinovich's negation-chain discipline *before* any tactic work,
and that transcription is what explains the outcome. Rabinovich's Lemma 5.1 enumeration (PDF p.9)
is exhaustive **because his `K⁺` is conjunct-free**. He prints the governing implication twice on
PDF p.10 — once as the guard on `r₀`'s existence, once as Case 3's closed form — and both say the
same thing: `¬K⁺(¬β₁)(z₀)` together with an occurrence of `¬β₁` inside the interval yields the
pin. Contrapositively: an occurrence yields `K⁺(¬β₁)(z₀)` **or** the pin. A dichotomy.

The tree's `kplus` carries an extra first conjunct `¬P(t)` that neither Rabinovich (Definition
(3), PDF p.3) nor Reynolds (abbreviation table, printed p.168) writes. Under it the split is
**not** exhaustive: at a point where `¬β₁` holds at `z₀` *and* recurs arbitrarily soon above it,
the source's `K⁺` fires Case 1 while `kplus` fails at its first conjunct and the infimum is not
strictly inside — so neither Case 1 nor Case 3 is available, and a third endpoint disjunct
`¬β₁(z₀)` is forced. That is literally `HasDenseDedekindINF`'s shape
(`DedekindINFDense.lean:222`), and the paper has no case for it.

This argument is now in the module docstring, cited to PDF pages and grounded on three landed
declarations rather than asserted: `kplusOpen_not_implied_by_truth_at` (the pointwise gap),
`HasDenseDedekindINF`'s trichotomy shape, and `hasFaithfulDedekindINF_survives_interval_witness`
(a structure where the faithful carrier holds and the `kplus`-stated one fails).

Both p.10 guard printings were re-read from the corpus (`chunk_0018.md`) and confirmed verbatim
before transcription; the p.9 enumeration was confirmed against `chunk_0017.md`. All citations in
the file are by **PDF page**, never by the corrupt `.md` conversion.

## What changed

**Additive, not a rename.** `HasFaithfulDedekindINF.first_occ_tp` is added;
`HasDedekindINF.first_occ_tp` is **retained unweakened**. The two are **incomparable** — the old
assumes the stronger carrier and concludes the stronger `kplus` at `z₀`, the new assumes the
weaker and concludes the weaker `kplusOpen` — so neither is derivable from the other and a rename
would have deleted a statement. This follows Phase 11's D1 precedent. Dot notation on the
re-based `h_INF` resolves to the faithful wrapper automatically, so no call site needed renaming.

**Definitions moved, as chartered.** `negFixOneCase1` → `kplusOpenLeftBlock`, and eq (5.3)'s pin
type `infPinPoint` → `kplusOpenPred`. `allSeg` and `somePointBlock` — the plan's other two named
eq (5.3) pieces — contain **no `K⁺` occurrence at all**, so the re-point item is vacuous for
them; the v8 survey's three-piece grouping was one piece too wide. Recorded rather than absorbed.

**Binders.** All five hypothesis sites re-based. Deviation D3's `.toHasFaithfulDedekindINF` at
`:253` **removed** as chartered — the build enforced it, exactly as 11.1 predicted.
`negFixOneFaithful_iff_of_attained` additionally needed `h_INF.toHasDedekindINF` →
`h_INF.toHasFaithfulDedekindINF`, one argument position the site list did not count.

## Declaration preservation — stated precisely

Declaration-inventory diff against the prior commit: **exactly one addition**
(`HasFaithfulDedekindINF.first_occ_tp`), zero removals, zero renames. `NegFixListFaithful`'s
inventory is byte-identical. No hypothesis was strengthened anywhere.

The honest complication, not glossed: two **definitions** moved, which makes `negFixOneFaithful`
a formally weaker `VVecEA2`. Taken singly that strengthens `_sound` (weaker hypothesis) and
weakens `_cover` (weaker conclusion). But `_iff` is preserved **as an `iff`, with its right-hand
side `¬(bracketOne s0 p s1).holds` textually unchanged**, now proved from a strictly weaker
carrier. The deliverable — a `∨∃⃗∀` formula equivalent to `¬bracketOne` — is therefore strictly
stronger than before, and moving those two definitions to the source's operator was this phase's
stated goal.

## The transitive cascade fired — deviation D4

11.1's standing warning was **correct that the cascade recurs**, and its prescribed check found
the site: `NegFixListFaithful.lean:463` (now `:468`), fixed with `kplusOpen_of_kplus` at the
argument position only, plus a `SCHEDULED FOR REMOVAL` comment. Nothing else in that module
changed.

But the *shape* 11.1 predicted was not the shape that fired. It expected an argument-position
`.toHasFaithfulDedekindINF` coercion, as in D3. What fired came from the **definition** move, not
the binder move — and D3's four existing coercions at `:368`, `:421`, `:437`, `:500` stayed green
and untouched, because this phase did not re-base `negBoundedLeftFixAnchoredFaithful_iff`.

**Generalized warning for Phases 12.1 and 13**: a re-base cascades along **two independent
edges** — moved binders and moved definitions — and a probe or grep aimed at one will not reveal
the other. Here the binder edge cost nothing downstream and the definition edge cost one site.

One further asymmetry worth carrying: unlike D3's coercions, D4's will **not** be enforced away by
the build, since the weakening stays type-correct under either carrier. Hence the in-file
comment, and hence the explicit checklist item added to Phase 12.1.

## Verification

| gate | result |
|---|---|
| scoped build `NegFixOneFaithful` | green, **first attempt** (1123 jobs) |
| scoped build `NfMultiAnchorBridge` chain | green (1192 jobs) |
| full `lake build` | green, **1919 jobs, 0 errors** — no scoped-aggregator fallback needed |
| live sorries outside `Boneyard/` | exactly `WeakCanonical/Transfer.lean:1242` — **unchanged** |
| new sorries | none |
| vacuous definitions | 0 new (the single tree-wide hit is pre-existing, in `Examples/`) |
| new axioms | 0 (the two `grep '^axiom '` hits are prose inside `Boneyard/` comments) |
| `#print axioms`, 12 re-based/retained declarations | all `[propext, Classical.choice, Quot.sound]` or `[propext]`; no `sorryAx` |
| canary `completeness_dense` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| canary `completeness_discrete` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| canary `countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| pinned terminus `consequence_completeness_dedekind_of_engine` | untouched; `[propext, Classical.choice, Quot.sound]` |
| frozen assets (`EANegationFix/`, `Lemma53Faithful*`, `KPlusFaithful`, `DedekindINF`, `StrongCompleteness`) | zero diff |
| long lines (>100) | 2 in each touched file, identical to prior commit |
| territory | nothing under `Metalogic/Decidability/` or `Automation/` edited or staged (concurrent work) |

## Known stale artifact, not repaired (out of territory)

`Section5Correspondence.lean:71` pins `negFixOneFaithful_iff` at
`EANegationFixFaithful/NegFixOneFaithful.lean:486`. This phase's docstring additions shifted that
declaration, so the pin is now stale. `Section5Correspondence.lean` is outside this phase's
territory and the row's *content* (the Lemma 5.1 ↔ `negFixOneFaithful_iff` correspondence) remains
correct, so the pin was left rather than edited out of scope or re-guessed. Flagged for whichever
phase next owns that file.

`NfMultiAnchorBridge.lean:255`'s inventory comment naming `HasDedekindINF.first_occ_tp` remains
**accurate** — that declaration is retained — merely incomplete, since it does not yet name the
added faithful wrapper. No edit made.
