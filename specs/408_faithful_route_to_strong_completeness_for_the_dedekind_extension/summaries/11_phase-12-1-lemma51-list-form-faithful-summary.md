# Phase 12.1 — Rabinovich Lemma 5.1, list form, re-based onto `HasFaithfulDedekindINF`

**Status**: COMPLETED. Full `lake build` green (1920 jobs), sorry-free, axiom-clean, all three
regression canaries unchanged, `EANegationFix/` byte-identical.

## What landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean` now runs
on `HasFaithfulDedekindINF` (`KPlusFaithful.lean:320`) rather than `HasDedekindINF`.

**The second hard site held, and more cheaply than the first.** The plan's banner predicted
`negFixListFaithful_iff` would be "by-cases-reached with the same case structure and the same
absence of a slot for an endpoint case." Correct on both counts — and the consequence was that
**not one proof step changed**. The entire code-bearing delta inside the theorem is:

- the binder type (`HasDedekindINF` → `HasFaithfulDedekindINF`);
- four `.toHasFaithfulDedekindINF` suffixes dropped at the
  `negBoundedLeftFixAnchoredFaithful_iff` call sites (the build enforced this);
- two `kplusLeftBlock_holds` → `kplusOpenLeftBlock_holds` rewrites.

The `rcases h_INF.first_occ_tp s.neg … with hk | ⟨r0, …⟩` remains a **two-arm** split with no third
disjunct and no endpoint branch; the carrier-free `by_cases hsev` that wraps it is untouched; the
`Aᵢ`/`Bᵢ` split, the `vecPinnedConjAll` DNF, and the `x ≤ r` / `x = r` / `x < r` peel are textually
unchanged. Scoped build green on the **first** attempt; zero failed proof attempts; no proof-search
tool invoked at any point.

Beyond the theorem, one definition and two artifacts moved to the source's `K⁺`:

| declaration | change | why |
|---|---|---|
| `negFixListFaithful` (Case 1 disjunct) | `kplusLeftBlock s.neg` → `kplusOpenLeftBlock s.neg` | Case 1's gate is the source's conjunct-free `K⁺` |
| `witness_absurd_of_kplusLeft` | hypothesis `kplus` → `kplusOpen` (**re-pointed**) | its proof already discarded the extra conjunct; the two are comparable, so retaining both would duplicate rather than preserve |
| `negFixListFaithful_case1_is_indispensable` | hypothesis `kplus` → `kplusOpen` (**re-pointed**) | its job is to certify *the disjunct the definition actually has*; left at `kplus` it would still compile while certifying a gate the definition no longer carries |
| `negFixListFaithful_iff_of_attained` | routing `HasAttainedINF.toHasDedekindINF` → `.toHasFaithfulDedekindINF` | keeps the attained/discrete pipeline supplying this module |

## Literature grounding (read verbatim from the PDF, pp.10-11)

The re-base rests on Rabinovich's own parenthetical in the Case 3 paragraph, PDF p.10:

> *"(If ¬**K**⁺(¬β₁) holds at z₀ and there is x ∈ (z₀,z₁) such that ¬β₁(x), then such r₀ exists
> because we deal with Dedekind complete chains.)"*

Contrapositively, an occurrence of `¬β₁` inside `(z₀,z₁)` yields `K⁺(¬β₁)(z₀)` **or** the eq (5.3)
pin — a **dichotomy at his conjunct-free `K⁺`**, which is character-for-character
`HasFaithfulDedekindINF.first_occ_tp`. That is why Cases 1 and 3 together cover everything Case 2
does not, with no endpoint case left over. Under the tree's `kplus` the same enumeration is *not*
exhaustive. This is now transcribed into the module docstring rather than asserted.

Also transcribed: eq (5.3) itself; the `Aᵢ`/`Bᵢ` definitions (with the `Bᵢ⁺` spelling cross-checked
against Figure 1's caption on p.10, which the pre-existing docstring had already read correctly);
p.11's displayed reduction `(∃z)φ(z) ∧ ¬[…] ⇔ (∃z)(φ(z) ∧ ⋀¬Aᵢ ∧ ⋀¬Bᵢ)`, which is exactly the
shape of `vecPinnedListToV (vecPinnedConjAll …) s (infPinPoint s)`; and p.11 clause **(d)**,
*"because if INF^{¬β₁}(z), then for no x > z, β₁ holds along [z,x)"*, which is
`bracketOne_witness_le_infPin`'s content.

The `.md` conversion in the corpus is corrupt and was not used; all reads were from the PDF.

## Deviations

### D7 — the plan's "remove `kplusOpen_of_kplus` at `:468`" item is not executable; its premise is false

The plan recorded this coercion as a D4 artifact of the mixed carrier and predicted the build would
not enforce its removal. In fact **it is structurally required under either carrier**, and removing
it makes the build RED.

Reason: `HasFaithfulDedekindINF.first_occ` (`KPlusFaithful.lean:325`) weakens only its **left**
disjunct. Its **right** disjunct deliberately retains the tree's `kplus` at `r₀` — the structure's
own docstring at `:302` records this as intentional, so that "the two carriers' right disjuncts
stay syntactically identical for the re-base." Since `infPinPoint` carries the source's `kplusOpen`,
the one-token weakening is needed at the pin regardless of which carrier is bound. Phase 12 kept the
identical coercion at the identical spot (`NegFixOneFaithful.lean:583`) for the identical reason.

Action taken: the coercion is retained and the `SCHEDULED FOR REMOVAL` comment is replaced by one
explaining, with citations, why it is permanent. **Not silently skipped** — this is reported to the
orchestrator, since a plan item resting on a false premise about a frozen asset is plan-revision
material for Phase 13's identical checklist item, if it has one.

### D8 — one plan item is vacuous

The item asks to decide re-point-vs-retain for "`negFixList_gate_probe`-adjacent statements". No
such declaration exists anywhere in the tree, and this module contains no gate probe at all. The
two gate probes that exist are `NegFixGateProbe` (`EANegationFix/NegFixOne.lean:402`, frozen
read-only) and `NegFixOneFaithfulGateProbe` (`NegFixOneFaithful.lean:695`, handled in Phase 12).
The only `kplus`-binding statements this module had were the two re-pointed above. Recorded rather
than silently doing nothing, following Phase 12's D6 precedent.

### D9 — transitive cascade into Phase 13's territory (2 sites, one per edge)

Phase 12's generalized two-edge warning is confirmed by a second independent instance, and this
time **both** edges fired, both in `VecEANegFixFaithful.lean`:

- **Binder edge**, `:109`: `h_INF` → `h_INF.toHasFaithfulDedekindINF`. Marked `SCHEDULED FOR
  REMOVAL`; the build **will** delete it when Phase 13 swaps `:105`'s binder.
- **Definition edge**, `:295`: `kplusLeftBlock_holds` → `kplusOpenLeftBlock_holds` plus
  `kplusOpen_of_kplus hk`. Unlike D4's, the build **did** enforce this one — because the block
  *identifier* changed, not merely an argument's type.

Two code-bearing lines total; declaration inventory byte-identical. A docstring at `:272` naming
`kplusLeftBlock` was corrected to `kplusOpenLeftBlock`, since leaving it would have made the prose
false about the definition it describes.

`VecEA2.negFixFaithful_carries_limit_gate`'s `hk : kplus` was **deliberately not** re-pointed: it
is outside this phase's territory and a statement change is more than a cascade repair. It remains
true and load-bearing (`kplus → kplusOpen`), but it now certifies the limit gate at a hypothesis one
conjunct stronger than the gate the definition carries. An in-file note records this and flags the
re-point for Phase 13.

## Declaration preservation

Mechanically diffed, both modules: **0 additions, 0 removals, 0 renames**. No hypothesis was
strengthened anywhere; three were weakened (one binder, two `kplus` → `kplusOpen`). No conclusion
was weakened.

Honest statement about what the definition move costs: `negFixListFaithful`'s Case 1 disjunct is now
a formally **weaker** left-endpoint condition, which taken singly weakens the cover direction and
strengthens the soundness direction. But `negFixListFaithful_iff` is preserved **as an iff**, with
its right-hand side `¬(bracketOf s ps).holds` textually unchanged and now proved from a strictly
weaker carrier — so the deliverable is strictly stronger than before. Stated this way rather than
glossed as "no conclusion changed", which would be false at the definition level.

## Verification

| check | result |
|---|---|
| scoped build (`…NegFixListFaithful`) | green, 1125 jobs, **first attempt** |
| full `lake build` | green, 1920 jobs, 0 errors |
| sorries in touched modules | 0 |
| new axioms | 0 (repo total unchanged at 2) |
| vacuous definitions introduced | 0 (the single repo-wide pattern hit is pre-existing in `Examples/TemporalStructures.lean`) |
| `#print axioms`, 12 re-based/adjacent declarations | all ⊆ `[propext, Classical.choice, Quot.sound]`; `witness_absurd_of_kplusLeft` is `[propext]` alone |
| canary `completeness_discrete` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| canary `completeness_dense` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| canary `countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| frozen `EANegationFix/` (incl. `NegFixList.lean`) | byte-identical, untouched |
