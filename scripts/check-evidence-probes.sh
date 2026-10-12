#!/usr/bin/env bash
# Compile-check the tracked evidence probes under `specs/evidence/`.
#
# WHAT A PROBE IS.  Each file under the evidence directory below is a machine-checked record of a
# design obstruction: a `sorry`-free Lean file whose theorems REFUTE something the plan for the
# decision layer once proposed.  They are not tests of the layer's behaviour; they are the reasons
# the layer has the shape it has.
#
# WHY THEY NEED A GUARD.  A probe lives under `specs/`, so no Lake target root reaches it and
# `lake build` never compiles it.  Left alone it rots: the definitions it cites drift, and the
# record silently stops meaning what it says.  Worse, a probe that has quietly stopped compiling
# is no longer an obstacle to anyone, so a future change can undo the very decision it records.
# This script is what keeps that from happening -- it is the analogue, for probes, of the C6 rot
# guard in `check-module-invariants.sh`, and uses the same mechanism (`lake env lean` on a file
# outside the build graph).
#
# WHY THE PROBES DO NOT LIVE IN A TASK DIRECTORY.  They used to, under
# `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`.  When `/todo` archived that task the
# whole directory moved to `specs/archive/`, which `.gitignore` excludes -- so the four probes left
# version control entirely (absent from a fresh clone) and this guard failed on every run against a
# path that no longer existed.  Nothing announced either fact, because this script is not wired into
# CI.  A probe outlives the task that produced it by construction: it records a design obstruction,
# not a unit of work.  It therefore lives in `specs/evidence/`, which is task-independent and
# tracked, exactly as `specs/reviews/` is.  Do not move a probe back under a task directory.
#
# WHAT EACH PROBE HOLDS IN PLACE.  See the tables in the WIRED and WIRED_REPO lists below.
#
# TWO ENTRY FORMS.  `WIRED` entries are paths under `specs/evidence/`, which is where a probe
# belongs.  `WIRED_REPO` entries are full repository-relative paths, for the case where a probe
# cannot yet be moved into the collection because other files cite its current path verbatim.
# Both forms are checked identically by `check_probe` below; the second exists only so that a
# probe stranded outside the collection is still guarded rather than left to rot unwatched.
# Prefer `WIRED`: reach for `WIRED_REPO` only with a named blocker recorded beside the entry.
#
# TRACKED, NOT MERELY PRESENT.  A wired probe must be tracked by git, and `check_probe` tests
# this with `git ls-files --error-unmatch` after the presence test.  Presence alone is not a
# guard: `[ -f ]` is satisfied by a gitignored file under `specs/archive/` (see the
# `specs/archive/` line in `.gitignore`), which is exactly what an archival `mv` of a task
# directory produces -- every file under the moved directory leaves version control in that one
# commit while staying on disk for whoever already had it.  A gate testing presence alone then
# stays green on every such machine and fails on every clean checkout (CI included), which is the
# worst combination: the breakage is invisible to the person who caused it.  Consequence for a
# `WIRED_REPO` entry pointing into a task directory: the entry must be re-pointed, or the file
# promoted to `specs/evidence/`, BEFORE that task is archived.  A `FAIL (untracked: ...)` from
# this script means that did not happen.
#
# Usage:
#   bash scripts/check-evidence-probes.sh
#
# Exit status: 0 if every wired probe compiles, 1 otherwise.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# Collection-relative: each WIRED entry below is a path under `specs/evidence/`, so several
# probe collections can be guarded by the one loop.
EVIDENCE="specs/evidence"

# --- WIRED --------------------------------------------------------------------------------
# probe (path under specs/evidence/)                        | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# bi-lasso-decision-layer/phase3-scan-bound-is-false         | no bound computed from the lasso's
#                                                           | segment lengths alone can drive a
#                                                           | semantic scan -- this is why the
#                                                           | layer enumerates annotations instead
#                                                           | of evaluating
# bi-lasso-decision-layer/phase7-filtered-frame-is-universal | the filtered frame's one-step
#                                                           | relation is universal, so it carries
#                                                           | no dynamics -- this is why the layer
#                                                           | presents frames rather than
#                                                           | filtering
# bi-lasso-decision-layer/phase12-check-not-compositional    | the `imp` case admits no
#                                                           | compositional reading -- this is why
#                                                           | `check`'s two existentials sit
#                                                           | OUTSIDE any recursion on the formula
# bi-lasso-decision-layer/phase10-origin-anchoring-obstruction | no recurrence of the type at the
#                                                           | point of interest need exist -- this
#                                                           | is what stops `check` being
#                                                           | re-anchored at position 0.
#                                                           | Load-bearing: it is the probe a
#                                                           | future dispatch is most likely to
#                                                           | try to contradict, since anchoring
#                                                           | looks like a cleanup
# stability-modal-substrate/closure-field-is-necessary   | `SharingSkeleton`'s `lift` field is a
#                                                           | genuine obligation, not a defensive
#                                                           | one.  Give the landed (C5) witness
#                                                           | `stabFamily` the no-hopping
#                                                           | succession bundle, changing nothing
#                                                           | else, and `LiftableRaw` becomes
#                                                           | FALSE: `crossPath` is a `Step`-path
#                                                           | no index-identity path tracks.  This
#                                                           | is why `lift` is a field every
#                                                           | producer discharges rather than a
#                                                           | lemma proved once, and it is the
#                                                           | probe a future dispatch is most
#                                                           | likely to try to eliminate, since
#                                                           | the field looks like boilerplate
# frame-constraints-audit/mixed-sign-composition-obstruction | mixed-sign composition (`TotalComp`)
#                                                           | must NOT be added to `def:frame` --
#                                                           | the drift frame `F°` satisfies all
#                                                           | four constraints and fails it, and
#                                                           | `app:drift` needs `F°` for
#                                                           | `cor:no-characterization`.  It also
#                                                           | carries the positive half:
#                                                           | `Completion -> Saturation` holds
#                                                           | UNDER `TotalComp`, which locates the
#                                                           | obstruction exactly
# seam-gluing-ray-product/stab-fibre-is-ray-product         | the `⊡` quantification domain IS the
#                                                           | fibre product of the past-ray and
#                                                           | future-ray spaces over the seam
#                                                           | state (general task frame, and the
#                                                           | ω-sequence form over ℤ) -- this is
#                                                           | the MECHANISM behind the finite-width
#                                                           | refutation (a product of two path
#                                                           | spaces cannot be a finite fibre), not
#                                                           | an escape from it, and every route in
#                                                           | the omega-sequence-decidability round
#                                                           | assumes it
# seam-gluing-ray-product/stab-depth-stratification         | POSITIVE: the `⊡`-value at a state
#                                                           | is computable from a per-state
#                                                           | labelling stratified by `⊡`-depth
#                                                           | (`stratum`), which is exactly what
#                                                           | the landed `atomize` /
#                                                           | `plusTruthAt_iff_atomize` already
#                                                           | supplies -- this licenses R1's
#                                                           | automaton ALPHABET; it bounds and
#                                                           | decides nothing on its own
# seam-gluing-ray-product/finite-graph-stab-summary         | POSITIVE (forward factor, on the
#                                                           | fixture): `⊡(Fp)` at a seam state
#                                                           | is exactly "every forward root path
#                                                           | from that state meets `p`" -- R1's
#                                                           | route-killer test survives at this
#                                                           | cheapest single-operator shape.
#                                                           | Backward dual not separately proved
#                                                           | (symmetric fixture, no new
#                                                           | machinery); decidable witness: on
#                                                           | the total-graph fixture `⊡(Fp)` is
#                                                           | decidably False everywhere
# seam-gluing-ray-product/mosaic-germ-amalgamation          | POSITIVE: R2's amalgamation
#                                                           | precondition is free -- `paste`
#                                                           | (`app:gluing`'s binary case) glues
#                                                           | two mosaics agreeing at a shared
#                                                           | germ, choice-free, with uniqueness.
#                                                           | The `⊡`-saturation decidability
#                                                           | question is fixed as a `Prop`
#                                                           | (`StabSaturated`), proved only in
#                                                           | the same-state corner -- attacked by
#                                                           | name and found VACUOUS by the
#                                                           | mosaic-stab-saturated entry below
# seam-gluing-ray-product/path-quantifier-alternation       | NECESSITY DEMONSTRATED: on the
#                                                           | Phase-3 fixture the existential
#                                                           | (nondeterministic) summary is True
#                                                           | everywhere while `⊡(Fp)` is False
#                                                           | everywhere -- a universal,
#                                                           | complementation-shaped summary is
#                                                           | genuinely required for this
#                                                           | fragment. Discharges the settled
#                                                           | determinization-funding decision's
#                                                           | evidence condition; funds nothing
#                                                           | by itself and begins no
#                                                           | determinization work
# seam-gluing-ray-product/backward-dual-asymmetric-fixture  | POSITIVE (backward factor, on a
#                                                           | TIME-ASYMMETRIC fixture): the
#                                                           | backward stability operator at a
#                                                           | seam state is exactly "every
#                                                           | backward root path from that state
#                                                           | meets the `p`-set", decided by
#                                                           | backward reachability alone and
#                                                           | STATE-DEPENDENTLY -- True at the
#                                                           | `post` states, False at the `x` and
#                                                           | `pre` states. The dual the
#                                                           | finite-graph probe records as
#                                                           | excluded, now on the fixture whose
#                                                           | relation is NOT symmetric under
#                                                           | time reversal, which is where the
#                                                           | finite-width obstruction lives.
#                                                           | Honest limit, in the probe's own
#                                                           | header: that fixture is backward
#                                                           | DETERMINISTIC, so its backward
#                                                           | factor is a singleton and this is
#                                                           | the dual at its easiest instance;
#                                                           | the hard test is a mirror fixture,
#                                                           | filed as a follow-up and discharged
#                                                           | by the mirror-fixture entry below.
#                                                           | No automata
# seam-gluing-ray-product/backward-dual-mirror-fixture      | POSITIVE (backward factor, on the
#                                                           | MIRROR fixture -- time-asymmetric
#                                                           | AND backward-branching, factor 2 at
#                                                           | every spine state): the backward
#                                                           | stability operator at a seam state
#                                                           | is exactly "every backward root path
#                                                           | from that state meets the `p`-set",
#                                                           | decided by backward reachability
#                                                           | alone and STATE-DEPENDENTLY -- True
#                                                           | at the `aft` states, False at the
#                                                           | `x` and `bef` states; two distinct
#                                                           | backward root paths from the state
#                                                           | under test (`two_bwd_paths`,
#                                                           | axiom-free). Discharges E1's "mirror
#                                                           | fixture filed as a follow-up" note
#                                                           | (the entry above). No automata, no
#                                                           | width bound, no complexity claim
# seam-gluing-ray-product/device-selection-probe            | DEVICE-SELECTION (E3): `⊡(Fp)` /
#                                                           | `⊡(Pp)` are device-inert on finite
#                                                           | fixtures (machine-checked:
#                                                           | `allPathsMeet_iff_lasso`,
#                                                           | `detRun_accepts_iff`,
#                                                           | `stab_will_iff_lasso`); pigeonhole-
#                                                           | tier lasso summaries refuted on
#                                                           | infinite fibres
#                                                           | (`not_lasso_sufficient_on_chain`).
#                                                           | Selection on infrastructure +
#                                                           | literature evidence = time-axis
#                                                           | Ramsey (d) via in-tree
#                                                           | `infinite_ramsey_pairs`, framed by
#                                                           | the HWZ/GKWZ MSO-over-<Z,<> route
#                                                           | (c); (a) Safra/Piterman and (b)
#                                                           | Safraless NOT selected (inert on the
#                                                           | shapes; no formalization anywhere;
#                                                           | (b)'s 2005 source WANTED). No
#                                                           | complexity bound. Begins no
#                                                           | substrate work
# seam-gluing-ray-product/cslib-ramsey-port-feasibility     | PORT FEASIBILITY (736): cslib's
#                                                           | `infinite_graph_ramsey` (Ching-Tsun
#                                                           | Chou, upstream
#                                                           | `leanprover/cslib`) compiles on THIS
#                                                           | pin from Mathlib alone, sorry-free,
#                                                           | with no `Cslib.*` import and no
#                                                           | `module`/`public import` preamble --
#                                                           | so the cslib stack is portable in
#                                                           | principle. And it SUBSUMES this
#                                                           | tree's `ForMathlib`
#                                                           | `Nat.exists_strictMono_const_pair_colour`:
#                                                           | `repo_ramsey_from_cslib_ramsey`
#                                                           | derives the in-tree statement from
#                                                           | the ported one through an
#                                                           | unordered/ordered pair bridge and
#                                                           | `Nat.nth`, and the statement
#                                                           | identity is itself machine-checked
#                                                           | (`RepoRamseyStatement` discharged
#                                                           | twice). This is why the ForMathlib
#                                                           | module is NOT redefined as a
#                                                           | corollary: subsumption holds, but
#                                                           | the port plus glue is a net
#                                                           | ADDITION of lines, and the live
#                                                           | consumers in
#                                                           | `RamseyFactorization.lean` need the
#                                                           | curried ordered form. Also records
#                                                           | measured port friction: cslib's
#                                                           | Mathlib rev is 76 commits ahead and
#                                                           | its HEAD commit is the
#                                                           | `restrict`->`domRestrict` rename,
#                                                           | which breaks the first ported line.
#                                                           | Establishes NO portability for
#                                                           | `BuchiCompl.lean`, whose main
#                                                           | theorems are `proof_wanted`
# seam-gluing-ray-product/ktype-summary-substrate-probe     | SUBSTRATE (probe i): the k-type
#                                                           | summary substrate
#                                                           | (`WeakCanonical/KTypeSummary/`,
#                                                           | Buechi's complementation chain in
#                                                           | the monadic k-type idiom over the
#                                                           | Z time axis) run END TO END on a
#                                                           | concrete infinite fibre: explicit
#                                                           | cutting `W z := 2 * z` of the
#                                                           | even-parity block with its three
#                                                           | segment type equations PROVED by
#                                                           | order isomorphism (never by
#                                                           | evaluating `kTypeOf`), the cover
#                                                           | `family_cover` agreeing with it,
#                                                           | the triple confirmed degenerate,
#                                                           | and the central fact: the DISTINCT
#                                                           | odd-parity block cut at the odd
#                                                           | times lies in the SAME family, so
#                                                           | the two blocks have equal k-type at
#                                                           | every depth
#                                                           | (`zFiber_cPar_eq_cOdd`, via
#                                                           | `kTypeOf_zFiber_eq_of_inFamily`);
#                                                           | `family_saturation` and
#                                                           | `target_eq_union_of_families`
#                                                           | instantiated on the
#                                                           | normal-form target. Establishes NO
#                                                           | decidability, NO complexity bound,
#                                                           | NO reduction of any stab condition
#                                                           | to a k-type target (the seam
#                                                           | interface's `Presents` bundle is
#                                                           | cited, not inhabited), and no
#                                                           | k-type DISTINCTNESS
# seam-gluing-ray-product/stab-depth-two-probe              | E2 (probe ii): the depth-2
#                                                           | stratification probe on the
#                                                           | smallest fixture whose depth-1
#                                                           | stab value is STATE-DEPENDENT
#                                                           | (two states a, b; edges a->a,
#                                                           | a->b, b->b; p at b): `stab (F p)`
#                                                           | holds iff the seam state is b
#                                                           | (`stab_will_iff`); both depth-2
#                                                           | shapes `stab F (stab F p)` and
#                                                           | `stab (F p -> stab F p)` computed
#                                                           | DIRECTLY (`depth2_1_iff`,
#                                                           | `depth2_2_iff`: iff the state is
#                                                           | b) and THROUGH THE STRATA over the
#                                                           | atomized model, reading the inner
#                                                           | stab through its depth-1 stratum
#                                                           | (`depth2_via_strata_1/_2`, with
#                                                           | `plusTruthAt_iff_atomize` cited);
#                                                           | the falsifier check
#                                                           | `value_is_function_of_stratum`
#                                                           | is POSITIVE on this fixture. Not a
#                                                           | proof the falsifier cannot exist:
#                                                           | the real test is a fixture with
#                                                           | two states SHARING a depth-1
#                                                           | stratum, filed as a follow-up
# seam-gluing-ray-product/stab-depth-two-shared-stratum     | E2 (probe iii): the follow-up
#                                                           | above, run. Four states a, b, c,
#                                                           | d (edges a->a, a->b, b->b, b->d,
#                                                           | d->b, c->c; p at b), bi-serial by
#                                                           | `Rg_fwd`/`Rg_bwd`, with two
#                                                           | genuinely SHARED depth-1 classes:
#                                                           | {a, c} (`stab (F p)` False) and
#                                                           | {b, d} (True), certified by
#                                                           | `shared_false_stratum` /
#                                                           | `shared_true_stratum`. Five
#                                                           | depth-2 shapes computed directly
#                                                           | and through the strata. The
#                                                           | one-bit falsifier check is
#                                                           | REFUTED for the landed shape
#                                                           | `stab (F p -> stab F p)` on
#                                                           | {a, c}, the mixed shape
#                                                           | `stab (F p -> stab P p)` on
#                                                           | {b, d}, and the past mirror
#                                                           | `stab P (stab F p)` on {b, d}
#                                                           | (`not_function_of_stratum_*`);
#                                                           | it SURVIVES non-vacuously for
#                                                           | `stab F (stab F p)` on both
#                                                           | classes, `stab (P p -> stab F p)`
#                                                           | everywhere, and the landed shape
#                                                           | on {b, d}. Holds in place: the
#                                                           | time-axis route may assume NO
#                                                           | one-bit-per-depth summary; the
#                                                           | per-state label must carry the
#                                                           | closure-indexed alphabet (one
#                                                           | label per stab-subformula,
#                                                           | backward ones included). The
#                                                           | landed probe's positive on its
#                                                           | own fixture is untouched
# seam-gluing-ray-product/presents-is-seam-decidedness      | OBSTRUCTION (737): the
#                                                           | single-family hypothesis bundle
#                                                           | `RaySummary.Presents` is SEAM
#                                                           | DECIDEDNESS, not the MSO
#                                                           | reduction: on the E2 fixture
#                                                           | (transcribed, never imported)
#                                                           | the seam `(stayA c t, t)` is
#                                                           | undecided on `F p` -- `stayA`
#                                                           | refutes it, `jumpB` satisfies
#                                                           | it, both through `(c, a)`
#                                                           | (`seam_undecided`, against the
#                                                           | library's `SeamDecided`) -- so
#                                                           | NO `Presents` inhabitant exists
#                                                           | there for any `sig`, `k`, `T`,
#                                                           | `S` (`no_presents_on_fixture`,
#                                                           | by the library's
#                                                           | `seamDecided_of_presents`).
#                                                           | Holds in place: no decidability
#                                                           | result may be assembled on
#                                                           | `plusStab_iff_seamSummary` as if
#                                                           | `colours` were the MSO
#                                                           | reduction; the consumer must go
#                                                           | through `Hit` and the
#                                                           | hypothesis-free
#                                                           | `plusStab_iff_forall_hit`
#                                                           | (cited, not re-proved). Forward
#                                                           | only (`F p`); nothing about
#                                                           | `⊡(P p)`; `Hit` not computed
# seam-gluing-ray-product/quasistate-does-not-determine-hit | OBSTRUCTION (742, B2b verdict):
#                                                           | the HWZ-verbatim quasistate
#                                                           | shape -- per-time realized
#                                                           | closure types as bare sets plus
#                                                           | the consecutive-type relation
#                                                           | (HWZ 2000 Defs 10-12 over Z, no
#                                                           | product repair) -- does NOT
#                                                           | determine `Hit`: two regular
#                                                           | three-state fixtures (`a→a,
#                                                           | a→b, b→b, d→d, d→b` vs the same
#                                                           | graph without `a→b`; `p` at
#                                                           | `b`; `cl = {p, Fp}`) have equal
#                                                           | quasistates
#                                                           | (`quasiState_A_eq_B`) and equal
#                                                           | pair relations
#                                                           | (`pairRel_A_eq_B`) at every
#                                                           | time, yet different `⊡¬Fp` at
#                                                           | the seam `(stayA, t)`
#                                                           | (`stab_notFp_A`/`_B`), hence
#                                                           | different `Hit` at `k = 1`
#                                                           | through the library's
#                                                           | `plusStab_iff_forall_hit`
#                                                           | (`hit_ne`; headline
#                                                           | `quasistate_does_not_determine_hit`).
#                                                           | Holds in place: no B2b may be
#                                                           | transcribed in the quasistate
#                                                           | shape and fed to
#                                                           | `plusStab_iff_forall_hit`; the
#                                                           | per-model bridge must carry
#                                                           | joint realization through the
#                                                           | seam. Forward only; nothing
#                                                           | about `⊡(P p)`; `Hit` still not
#                                                           | computed
# seam-gluing-ray-product/presented-not-complete            | OBSTRUCTION (verdict on the
#                                                           | ray-product assembly): the
#                                                           | realization hypothesis
#                                                           | `RaySummary.Presented` (the
#                                                           | seam's closure traces are
#                                                           | exactly a finite presentation's
#                                                           | run traces) is NOT a completeness
#                                                           | carrier: on model A of the B2b
#                                                           | verdict probe (transcribed,
#                                                           | never imported; `a→a, a→b, b→b`,
#                                                           | `p` at `b`, `cl = {p, Fp}`) at
#                                                           | the seam `(t, a)` it fails for
#                                                           | EVERY finite `Q`, `lab`, `step`
#                                                           | (`not_presented`), by pumping a
#                                                           | repeated run state (`pump_isRun`)
#                                                           | against the `untl` run condition
#                                                           | through the library's
#                                                           | `clTrace_localRun`. Holds in
#                                                           | place: `Presented` is a soundness
#                                                           | device (B2b's
#                                                           | `Presented (modelOf P)`), never a
#                                                           | completeness one; no decision
#                                                           | procedure for `PlusValidZTime φ`
#                                                           | may proceed by "every refuting
#                                                           | regular ℤ-model has a `Presented`
#                                                           | presentation", and B2b's
#                                                           | consistency conditions must
#                                                           | exclude pumpable
#                                                           | eventuality-deferring run sets
#                                                           | (`presented_localRun`). The
#                                                           | assembly's three missing theorems,
#                                                           | named and NOT in the tree: (C)
#                                                           | Hit-level completeness with a
#                                                           | computable presentation bound;
#                                                           | (S) Hit-level soundness of
#                                                           | refutation (the unfiled B2b
#                                                           | record restated); (W) a
#                                                           | closure-wide quasimodel over all
#                                                           | seams at once. Forward only;
#                                                           | nothing about `⊡(P p)`;
#                                                           | `HitPresented` left OPEN there
#                                                           | (SETTLED on this fixture by
#                                                           | `hit-presented-model-a` below:
#                                                           | satisfiable, with the size exhibited
#                                                           | as a count; general (C) still open)
# seam-gluing-ray-product/hit-presented-model-a             | POSITIVE (requirement (C)'s
#                                                           | satisfiability half): the HIT-level
#                                                           | realization hypothesis
#                                                           | `RaySummary.HitPresented` -- the seam's
#                                                           | realized FAMILY TRIPLES are exactly a
#                                                           | finite presentation's, the Hit-level
#                                                           | hypothesis named in
#                                                           | `presented-not-complete`'s header and
#                                                           | left OPEN there -- is SATISFIABLE on
#                                                           | that probe's model A (transcribed,
#                                                           | never imported; `a→a, a→b, b→b`, `p`
#                                                           | at `b`, `cl = {p, Fp}`) at the seam
#                                                           | `(t, a)` of `stayA` with `φ := Fp`, at
#                                                           | EVERY depth `k ≥ 1`
#                                                           | (`hitPresented_modelA`), by the
#                                                           | rigidity of `RA` (every step path
#                                                           | through the seam is the constant
#                                                           | `a`-path or an `a`-then-`b` jump,
#                                                           | `path_classify`, `splice_classify`),
#                                                           | the truncation of the seam's infinite
#                                                           | ray index to a finite window
#                                                           | (`hitCl_eq_truncated`) and a
#                                                           | two-gadget presentation whose anchored
#                                                           | runs realize exactly that window
#                                                           | (`runTrace_mem_of_isRun`,
#                                                           | `exists_isRun_runTrace`). Holds in
#                                                           | place: the `Presented` refutation does
#                                                           | NOT transfer to the Hit level, because
#                                                           | what `Probe735.not_presented` refutes
#                                                           | is an equality of TRACE sets and this
#                                                           | is an equality of FAMILY-TRIPLE sets --
#                                                           | the two hold side by side on the SAME
#                                                           | fixture, seam and `φ` -- so the route
#                                                           | through requirement (C) is NOT closed
#                                                           | by that verdict, which stands
#                                                           | unchanged. The presentation size is
#                                                           | EXHIBITED in the statement, as a
#                                                           | COUNT: `presentationSize k =
#                                                           | Nat.card (KType (clSig Fp) k)`, so
#                                                           | `card_QA_presentationSize` reads
#                                                           | `presentationSize k + 6` -- a count of
#                                                           | depth-`k` types and nothing else, not
#                                                           | a complexity bound of any kind (by the
#                                                           | library's pigeonhole periodicity, the
#                                                           | Transport.lean cut surgery and the
#                                                           | fixture's `run_subset_middle`). (C)'s
#                                                           | general every-model half stays OPEN,
#                                                           | the (W) run-layer record's. Forward only;
#                                                           | nothing about `⊡(P p)`;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form, conditional or
#                                                           | otherwise, and no claim that L⁺ is
#                                                           | decidable, qualified or not; one
#                                                           | fixture, one seam, one `φ`
# seam-gluing-ray-product/b2b-frame-constructor-branching   | MIXED (746, requirement (S)'s carried
#                                                           | prerequisite): the 300-500 line
#                                                           | regular-frame constructor for
#                                                           | "finitely many fibre shapes per time"
#                                                           | is DESCOPED from (S), and its load-
#                                                           | bearing core is proved rather than
#                                                           | discarded. POSITIVE:
#                                                           | `ofSlicedStep_fib_finite`'s `[Finite
#                                                           | W]` is replaceable by two-sided finite
#                                                           | branching on the one-step relation with
#                                                           | no carrier hypothesis at all
#                                                           | (`fib_finite_of_finBranch`,
#                                                           | `saturation_of_finBranch`), two-sided
#                                                           | because `TaskFrame.Fib` at NEGATIVE
#                                                           | durations is the step relation's
#                                                           | preimage and finiteness is not
#                                                           | converse-stable; non-vacuous on a
#                                                           | genuinely infinite slice
#                                                           | (`shift_saturation` over `ℤ`,
#                                                           | `shift_slice_infinite`), a shape
#                                                           | `ofSlicedStep_saturation` cannot state.
#                                                           | REFUTED, twice: the named reset-from-
#                                                           | any-level hazard is real (`Rbad_fwd`
#                                                           | finite, `Rbad_bwd_infinite`, and the
#                                                           | `d = -1` fibre itself infinite,
#                                                           | `Rbad_fib_infinite`), AND the obvious
#                                                           | repair of firing the reset only from
#                                                           | level `0` merely swaps the failing side
#                                                           | (`Rok_bwd` finite, `Rok_fwd_infinite`)
#                                                           | -- an unbounded nondeterministic
#                                                           | deadline is infinite-branching wherever
#                                                           | it fires, so no reset PLACEMENT
#                                                           | rescues it. Holds in place: the
#                                                           | constructor is NOT a dependency of
#                                                           | requirement (S) -- in (S) the
#                                                           | presentation is given and liveness
#                                                           | sits in the `Cons` hypothesis, so
#                                                           | `ofSlicedStep` on the presentation's
#                                                           | own finite `Q` suffices unchanged --
#                                                           | and a successor record inheriting this
#                                                           | must finitize the committed deadline
#                                                           | before two-sided finite branching is
#                                                           | available. What it does NOT do: build
#                                                           | the constructor (no
#                                                           | `ofSlicedStepBranch`, no restatement
#                                                           | of the nine `[Finite W]`-carrying
#                                                           | declarations of `SlicedFrame.lean`, no
#                                                           | `FrameOver`/`IsRegular` instance under
#                                                           | the weaker hypothesis); exhibit a
#                                                           | deferring encoding that DOES have two-
#                                                           | sided finite branching (the design
#                                                           | space is bounded, not closed); touch
#                                                           | `RaySummary` or realize any
#                                                           | presentation. No complexity bound;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form
# seam-gluing-ray-product/mosaic-stab-saturated             | VACUOUS, recorded (E4): the landed Probe
#                                                           | 718 StabSaturated predicate is
#                                                           | identically true on EVERY finite mosaic
#                                                           | set, mixed germ states included
#                                                           | (stabSaturated_univ; Smix_mixed +
#                                                           | Smix_stabSaturated on the E2 Bool
#                                                           | fixture), so it is decidable because
#                                                           | constant and the review's literal R2
#                                                           | falsifier is unsatisfiable. The real SH1
#                                                           | content is the witness direction
#                                                           | (StabWitnessedAt): HOLDS on {stayA,
#                                                           | jumpB, stayB}, FAILS on {jumpB, stayB},
#                                                           | both mixed -- finitely checkable only
#                                                           | once the per-mosaic ⊡-value is known,
#                                                           | which on this fixture is R1's
#                                                           | stab_will_iff. Holds in place: R2's
#                                                           | hypothesis is restated as a SYNTACTIC
#                                                           | saturated-set existence theorem with a
#                                                           | bespoke ⊡-fibre interaction condition
#                                                           | (Caleiro 2013 section 4.3: mosaic
#                                                           | decidability does not transfer once the
#                                                           | dimensions interact); R2 neither
#                                                           | promoted nor closed; Handbook ch. 11
#                                                           | sections 5.10-5.11 remain a recorded
#                                                           | residual gap
#                                                           | (specs/literature-index.json,
#                                                           | hodkinson_2006). No complexity claim, no
#                                                           | certificate class, no edit to the Probe
#                                                           | 718 file.
# seam-gluing-ray-product/w-soundness-shape-refuted         | OBSTRUCTION (747, requirement (W)'s
#                                                           | run-layer verdict): requirement (S)'s
#                                                           | construction `modelOf` cannot be the
#                                                           | soundness half of (W) for
#                                                           | `box`/`stab`-bearing L⁺, on two
#                                                           | independent axes. WIDTH: `frameOf` is
#                                                           | `ofSlicedStep` on the presentation's
#                                                           | finite `Q`, so the library's
#                                                           | `no_finite_width_sat` applies verbatim
#                                                           | and EVERY `Cons` model validates
#                                                           | `Φ.neg` (`modelOf_sat_neg_Φ`), a
#                                                           | ℤ-time non-validity
#                                                           | (`not_plusValidZTime_neg_Φ`); the gap
#                                                           | is `modelOf_incomplete`, and no clause
#                                                           | added to `Cons` closes it. COLLAPSE: at
#                                                           | any `Presented` seam whose presentation
#                                                           | marks at most one `now` state (exactly
#                                                           | `Cons.nowUnique`, which (S) needed),
#                                                           | every closure formula satisfies
#                                                           | `ψ ↔ ⊡ψ`
#                                                           | (`stab_iff_of_presented_nowUnique`, via
#                                                           | `exists_spliced_eq` off `seamOmegaEquiv`
#                                                           | and `presented_letter_at_seam`), so no
#                                                           | `⊡`-refutation such as `Fp → ⊡Fp` is
#                                                           | ever witnessed there -- independent of
#                                                           | width. Holds in place: the (W) run
#                                                           | layer is BLOCKED on three named
#                                                           | obligations (RaySummary README, "(W):
#                                                           | what landed and what did not") -- an
#                                                           | infinite-width finitely-branching frame
#                                                           | constructor, a Hit-level per-cell
#                                                           | realization hypothesis (never trace-
#                                                           | level `Presented`), and the bound
#                                                           | `kTypeOf_listSeg_replicate_eventually_
#                                                           | periodic`; the anchor layer
#                                                           | (`RaySummary/AnchorLayer.lean`) does
#                                                           | not depend on any of them. What it does
#                                                           | NOT do: (S) is UNTOUCHED
#                                                           | (`presented_modelOf` is a correct
#                                                           | soundness statement for
#                                                           | `box`/`stab`-free `φ` at one seam);
#                                                           | nothing is a negative decidability
#                                                           | result; nothing about `⊡(Pp)` (forward-
#                                                           | only, no backward Bool-fixture bridge);
#                                                           | nothing about `HitPresented`, which
#                                                           | holds on model A
#                                                           | (`Probe745.hitPresented_modelA`); no
#                                                           | complexity bound; `Decidable
#                                                           | (PlusValidZTime φ)` NOT stated in any
#                                                           | form
# seam-gluing-ray-product/deadline-ladder-branching         | DESIGN VERDICT (requirement (W)'s
#                                                           | run layer, "(W): what landed and what
#                                                           | did not", obligation (i)): the
#                                                           | frame scheme is the DEADLINE LADDER
#                                                           | (thread-indexed unfolding in its
#                                                           | general form: states `(q, c, n)`, the
#                                                           | current deadline counting down
#                                                           | deterministically, the next deadline
#                                                           | drifting by at most one per step, so
#                                                           | no state chooses a deadline), landed
#                                                           | in `RaySummary/RunLayer.lean`. The
#                                                           | probe cites the library and re-proves
#                                                           | nothing: `ladder_fwd`/`ladder_bwd`
#                                                           | (two-sided finite branching for EVERY
#                                                           | finite object, `Rlad_fwd`/`Rlad_bwd`),
#                                                           | `ladder_slice_infinite`
#                                                           | (`Rlad_slice_infinite`), and
#                                                           | `ladder_isRegular`
#                                                           | (`ladderFrame_isRegular`, `Saturation`
#                                                           | from `saturation_of_finBranch`, no
#                                                           | `[Finite W]` on the carrier), so
#                                                           | Probe746's positive half applies to
#                                                           | the ladder unchanged. REFUTES the
#                                                           | capped variant: `capped_carrier_finite`
#                                                           | -- a fixed cap gives the finite slice
#                                                           | `Q × Fin (N+1) × Fin (N+1)`, the
#                                                           | finite-width shape
#                                                           | `not_finite_width_fmp` refutes; a
#                                                           | state-chosen deadline is Probe746's
#                                                           | `Rok`/`Rbad`. Depth `k = 1`. What it
#                                                           | does NOT say: nothing about
#                                                           | realization (phase 2; its first lemma,
#                                                           | the stabilization of realized cells in
#                                                           | the counter pair, is REFUTED by the
#                                                           | twelfth probe
#                                                           | `ladder-cell-refutation.lean`),
#                                                           | nothing about `HitPresented`, nothing
#                                                           | about `⊡(Pp)` (forward-only);
#                                                           | seriality is the object's `fwd`/`bwd`
#                                                           | hypotheses; no complexity bound;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form
# seam-gluing-ray-product/node-cell-stabilization           | POSITIVE VERDICT (requirement (W)'s run
#                                                           | layer, "(W): what landed and what did
#                                                           | not", obligation (ii) item 1, on the
#                                                           | one-region fixture): realized cells on
#                                                           | `Limits/NoFiniteWidth.lean`'s `Node`,
#                                                           | for its own witness `Φ` (fallback `D`
#                                                           | not needed), STABILIZE past pre-index 1
#                                                           | (`preCell_stable`); `pre 0` and `pre 1`
#                                                           | DIFFER (`preCell_zero_ne`: the deadline
#                                                           | index is real); the thread index is
#                                                           | INVISIBLE (`postCell_stable`, its `1 ≤
#                                                           | j` hypotheses vacuous on `Node` --
#                                                           | `postCell_subset` has none; bonus
#                                                           | `xCell_stable`). `cellAt` is
#                                                           | `RaySummary/AnchorLayer.lean`'s. The
#                                                           | probe cites the fixture (`hist_canon`,
#                                                           | `canon_*`, `truth_p/Fp/Pp/Xp`, `Φ_true`,
#                                                           | `box_global`, `mem_cellAt_iff`,
#                                                           | `mem_tpOf_iff`) and re-proves nothing.
#                                                           | MECHANISM (branch-time saturation): on a
#                                                           | canonical history every member of `cl Φ`
#                                                           | is a Boolean combination of `s<t`,
#                                                           | `s=t`, `t<s`, `s+1=t`, never of the
#                                                           | thread index, so types depend on the
#                                                           | relative-position class
#                                                           | `{<0},{0},{1},{≥2}` only
#                                                           | (`truth_transfer`, `tpOf_eq_of`); cells
#                                                           | as SETS: `pre 0 ↦ {tp 1}`, `pre (≥1) ↦
#                                                           | {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦
#                                                           | {tp <0}`. The separator between `pre 0`
#                                                           | and `pre 1` is the non-`⊡` letter `Xp`
#                                                           | as set membership of a second type, NOT
#                                                           | a `⊡`-letter: `⊡Xp ∉ cl Φ` and `⊡¬Xp` is
#                                                           | false at every pre state
#                                                           | (`truth_stabNegXp`), so all four
#                                                           | `⊡`-letters of `cl Φ` agree at `pre 0`
#                                                           | and `pre 1`. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]` (choice
#                                                           | via `hist_canon`). What it does NOT say:
#                                                           | forward-only, nothing about `⊡(Pp)`; no
#                                                           | bound of any kind (the "1" is where THIS
#                                                           | fixture's cells coincide, not a bound
#                                                           | syntactic in `φ`); no finiteness (`Node`
#                                                           | is infinite-width); no claim that
#                                                           | `⊡`-letters discriminate between
#                                                           | devices; nothing about `HitPresented` or
#                                                           | `PlusValidZTime`; nothing about the
#                                                           | general ladder lemma
# seam-gluing-ray-product/hit-presented-node                | POSITIVE (requirement (C)'s Hit-level
#                                                           | hypothesis on a ⊡-bearing alphabet at an
#                                                           | infinite-width seam, on the one-region
#                                                           | fixture): `HitPresented` holds on
#                                                           | `Limits/NoFiniteWidth.lean`'s `M` at
#                                                           | every pre-seam `(t, pre m)` for its own
#                                                           | witness `Φ` (fallbacks `D`, `⊡Xp` not
#                                                           | needed; 28 closure letters plus `now`)
#                                                           | at every depth `k ≥ 1`
#                                                           | (`hitPresented_node`; the dispatch's
#                                                           | single-index shape
#                                                           | `hitPresented_node_canon`), with the
#                                                           | size `windowN m k + 5`, `windowN m k =
#                                                           | min m (Nat.card (KType (clSig Φ) k) +
#                                                           | 1)`, EXHIBITED in the statement and
#                                                           | bounded uniformly over every seam by
#                                                           | `card_QN_le` -- a count of states and
#                                                           | depth-`k` types, not a complexity bound.
#                                                           | ROUTE: seam classification
#                                                           | (`through_pre`: exactly `m + 1`
#                                                           | canonical histories through `(t, pre
#                                                           | m)`); four relative-position letter
#                                                           | classes (`clTrace_canon_apply`);
#                                                           | containment `run_subset_middle` as a
#                                                           | fixture fact; the library's periodicity
#                                                           | (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`)
#                                                           | and `familyTriples_subset_deleteRun`; a
#                                                           | one-gadget presentation `labN`/`stepN`
#                                                           | whose anchored runs are exactly the
#                                                           | window. BY-PRODUCT `presented_node`:
#                                                           | trace-level `Presented` holds at window
#                                                           | `m`, which is why the negative headline
#                                                           | is FALSE here (finite seam fibre). What
#                                                           | it does NOT say: one fixture, every
#                                                           | pre-seam; does not test the truncation's
#                                                           | necessity -- a Hit-level falsifier needs
#                                                           | an infinite seam fibre; forward-only,
#                                                           | nothing about `⊡(Pp)`; no finiteness
#                                                           | added; no claim that `⊡`-letters
#                                                           | discriminate between devices; nothing
#                                                           | about `PlusValidZTime` or the general
#                                                           | row. Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` (`stepN` none).
# seam-gluing-ray-product/ladder-cell-refutation            | NEGATIVE VERDICT (requirement (W)'s
#                                                           | run layer, "(W): what landed and what
#                                                           | did not", obligation (ii) item 1,
#                                                           | over a general finite object):
#                                                           | `ladderFrame`'s `fwd`/`bwd`
#                                                           | hypotheses are unsatisfiable on the
#                                                           | full carrier `Q × ℕ × ℕ` for every
#                                                           | object (`no_fwd`, `no_bwd_of_idle` --
#                                                           | the idle state `(q, 1, 0)` has
#                                                           | neither `Rlad`-successor nor
#                                                           | predecessor), so `Adm` is a CARRIER
#                                                           | restriction (here `{x // x.2.1 ∈ Adm
#                                                           | pend x.1}` with `Adm pend q = {c |
#                                                           | pend q = false → c = 0}`, one of
#                                                           | several equally valid shapes) and
#                                                           | `ladderFrame` has no instances; on
#                                                           | the repaired carrier the
#                                                           | stabilization of realized cells in
#                                                           | the counter pair `(c, n)` is FALSE
#                                                           | for every bound on the two-state
#                                                           | object (`cell_ne`: the cells at `(a,
#                                                           | B, B+1)` and `(a, B, B+2)` differ for
#                                                           | every `B`; `exhibited_form_refuted`,
#                                                           | `exists_form_refuted`). MECHANISM:
#                                                           | the current deadline fixes the
#                                                           | region's end at `z + c`, and
#                                                           | `Count`'s idle clause reads `c' = n`,
#                                                           | so the gap `n - c` is observable
#                                                           | through `p U (r ∧ X(p ∧ X r))`, `X χ
#                                                           | := ⊥ U χ`. What it does NOT say:
#                                                           | forward-only witness for a
#                                                           | direction-neutral statement (the
#                                                           | past-looking twin is paper-level, not
#                                                           | machine-checked); no bound of any
#                                                           | kind; no finiteness; nothing about
#                                                           | `HitPresented` or `PlusValidZTime`;
#                                                           | the successor design not chosen
#                                                           | (in-place repair of `ladderFrame` or
#                                                           | a sigma over `Adm` equally valid);
#                                                           | `anchorCells_finite` and
#                                                           | `anchorCells_ncard_le` untouched.
#                                                           | Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` (`no_bwd_of_idle`
#                                                           | `[propext]`).
# seam-gluing-ray-product/ladder-liveness-forward-only     | FORWARD-ONLY LIVENESS (requirement
#                                                           | (W)'s run layer, "(W): what landed
#                                                           | and what did not", obligation (ii)
#                                                           | item 1, the soundness half, over the
#                                                           | two-state object): the realization
#                                                           | theorem (`LadderCons` with its
#                                                           | `box`/`stab` clause,
#                                                           | `ladderCons_localRun`,
#                                                           | `ladderRealized`) is `[BLOCKED]` on
#                                                           | the open index of which cell a
#                                                           | ladder state has -- every per-cell
#                                                           | soundness statement presupposes it
#                                                           | (`cell_ne`; the `Count` clause makes
#                                                           | the `Q`-projection of a seam fibre a
#                                                           | proper subset of the `Q`-runs; a
#                                                           | per-state labelling collapses `ψ ↔
#                                                           | ⊡ψ`) and so does the acceptance
#                                                           | clause (`stab_mem_tpOf_iff` is per
#                                                           | cell). What IS settled,
#                                                           | machine-checked: an admissible
#                                                           | ladder history can be pending at
#                                                           | every past time (`gPast_isPath`,
#                                                           | `gPast_pending_past`, `gPast_count`
#                                                           | -- backward, `Count true true` grows
#                                                           | the countdown without bound), so
#                                                           | `Cons`'s `ulive` is replaceable by
#                                                           | structural liveness and `slive` is
#                                                           | NOT. What it does NOT say:
#                                                           | forward-only in the sense that the
#                                                           | forward liveness is structural and
#                                                           | the backward one is not -- not a
#                                                           | claim about `⊡(Pp)`; no bound of any
#                                                           | kind; no finiteness; nothing about
#                                                           | `HitPresented` or `PlusValidZTime`;
#                                                           | no library module created; the
#                                                           | successor design -- an index, or the
#                                                           | index-free run-layer half -- not
#                                                           | chosen; `anchorCells_ncard_le`
#                                                           | untouched. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]`
#                                                           | (`gPast_pending_past`, `gPast_count`
#                                                           | `[propext, Quot.sound]`).
# seam-gluing-ray-product/ladder-cell-index-obstructions    | LADDER CELL INDEX OBSTRUCTIONS
#                                                           | (requirement (W)'s run layer,
#                                                           | "(W): what landed and what did
#                                                           | not", obligation (ii) item 1, the
#                                                           | soundness half, and its cell-index
#                                                           | sub-problem): the
#                                                           | clipped-coordinate index family is
#                                                           | REFUTED at a SECOND coordinate --
#                                                           | the countdown's PARITY, observable
#                                                           | at the region end at distance
#                                                           | exactly `c + 1` because `Count
#                                                           | true true` admits no early
#                                                           | discharge, while `step` is
#                                                           | independent of the counters and
#                                                           | may alternate a tag per pending
#                                                           | step and copy it onto the ending
#                                                           | idle state -- uniformly in the
#                                                           | clip bound (`cell_succ_ne` at
#                                                           | every `c` with `n` FIXED,
#                                                           | `index_collide`,
#                                                           | `ladderIndex_not_factoring`,
#                                                           | `exhibited_form_refuted`,
#                                                           | `exists_form_refuted`; the
#                                                           | mechanism is `truth_phiP`). The
#                                                           | witnessing pair carries EQUAL
#                                                           | next-deadlines and both gaps
#                                                           | saturate the clip, so the gap
#                                                           | coordinate is not what fails --
#                                                           | and the gap-coordinate
#                                                           | refutation's own mechanism
#                                                           | (`cell_ne`) is real and NOT
#                                                           | displaced: it killed a SMALL gap
#                                                           | at LARGE counters, which is why
#                                                           | the gap coordinate is RETAINED. A
#                                                           | gate probing one coordinate
#                                                           | certifies one coordinate: the
#                                                           | earlier one-part gate was sound
#                                                           | and non-vacuous (`gate_separates`
#                                                           | for a clip bound of at least two,
#                                                           | `gate_collides_below_two` below
#                                                           | it, so the clip bound comes from
#                                                           | the FORMULA and never from the
#                                                           | counters) and the candidate it
#                                                           | certified is refuted at a
#                                                           | coordinate it never touched. The
#                                                           | bounded-carrier alternative is
#                                                           | CLOSED (`bounded_ladder_finite`,
#                                                           | `finBranch_eq_ofSlicedStep` by
#                                                           | `rfl`,
#                                                           | `bounded_width_validates_Phi_neg`,
#                                                           | `Phi_neg_not_valid`): its premise
#                                                           | fails at the non-validity the
#                                                           | finite-width limitation exhibits.
#                                                           | Narrow carve-out, stated rather
#                                                           | than suppressed: a bounded carrier
#                                                           | remains available for a target
#                                                           | that DOES have a finite-width
#                                                           | countermodel, per that
#                                                           | limitation's own disclaimer --
#                                                           | what is refuted is the route as
#                                                           | the GENERAL route. What IS landed:
#                                                           | a GATED six-coordinate candidate
#                                                           | (`ladderIndexRes`, with
#                                                           | `gate_gap_separates` and
#                                                           | `gate_parity_separates` at a
#                                                           | SYMBOLIC modulus via
#                                                           | `consec_mod_ne`) and an EXHIBITED
#                                                           | threshold and period
#                                                           | (`iterate_eventually_periodic`,
#                                                           | `reachN_eventually_periodic`),
#                                                           | plus a third gate run one region
#                                                           | out and in the past direction
#                                                           | (`second_region_any_length`,
#                                                           | `second_region_end_tag_achievable`,
#                                                           | `second_region_sets_agree`,
#                                                           | `gap_step_le`,
#                                                           | `gap_region_start_le_one`,
#                                                           | `gap_le_region_age`,
#                                                           | `region_start_beyond_depth`,
#                                                           | `clipped_gap_collides`,
#                                                           | `third_region_any_length`) which
#                                                           | found NO refutation on three
#                                                           | enumerated attempts -- three
#                                                           | attempts on one fixture family,
#                                                           | which is not a proof that the
#                                                           | general factorization holds. What
#                                                           | it does NOT say: NO index is
#                                                           | claimed to factor the cells in any
#                                                           | shape, and the positive
#                                                           | factorization lemma is OPEN and
#                                                           | stated nowhere; no seventh
#                                                           | coordinate; no bound of any kind
#                                                           | and no complexity bound (every
#                                                           | quantity named is a COUNT); no
#                                                           | finiteness added, and
#                                                           | `anchorCells_finite` and
#                                                           | `anchorCells_ncard_le` untouched
#                                                           | -- the SET of cells is still
#                                                           | finite and bounded, only the
#                                                           | computable INDEX is absent;
#                                                           | nothing about `HitPresented`, and
#                                                           | `PlusValidZTime` only in the
#                                                           | non-validity cited; no library
#                                                           | module created and no declaration
#                                                           | added under the main library; the
#                                                           | acceptance clause never dropped
#                                                           | (`stab_mem_tpOf_iff` is that
#                                                           | cell's bit); the successor design
#                                                           | not chosen -- if the gated
#                                                           | candidate falls in turn the
#                                                           | direction on record is a different
#                                                           | presentation of a cell, not a
#                                                           | wider tuple. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]`
#                                                           | (`gate_gap_separates`,
#                                                           | `gap_le_region_age`,
#                                                           | `region_start_beyond_depth`,
#                                                           | `gate_separates`,
#                                                           | `gate_collides_below_two`
#                                                           | `[propext, Quot.sound]`).
WIRED=(
  "bi-lasso-decision-layer/phase3-scan-bound-is-false"
  "bi-lasso-decision-layer/phase7-filtered-frame-is-universal"
  "bi-lasso-decision-layer/phase12-check-not-compositional"
  "bi-lasso-decision-layer/phase10-origin-anchoring-obstruction"
  "frame-constraints-audit/mixed-sign-composition-obstruction"
  "stability-modal-substrate/closure-field-is-necessary"
  "seam-gluing-ray-product/stab-fibre-is-ray-product"
  "seam-gluing-ray-product/stab-depth-stratification"
  "seam-gluing-ray-product/finite-graph-stab-summary"
  "seam-gluing-ray-product/mosaic-germ-amalgamation"
  "seam-gluing-ray-product/path-quantifier-alternation"
  "seam-gluing-ray-product/backward-dual-asymmetric-fixture"
  "seam-gluing-ray-product/backward-dual-mirror-fixture"
  "seam-gluing-ray-product/device-selection-probe"
  "seam-gluing-ray-product/cslib-ramsey-port-feasibility"
  "seam-gluing-ray-product/ktype-summary-substrate-probe"
  "seam-gluing-ray-product/stab-depth-two-probe"
  "seam-gluing-ray-product/presents-is-seam-decidedness"
  "seam-gluing-ray-product/quasistate-does-not-determine-hit"
  "seam-gluing-ray-product/presented-not-complete"
  "seam-gluing-ray-product/stab-depth-two-shared-stratum"
  "seam-gluing-ray-product/hit-presented-model-a"
  "seam-gluing-ray-product/b2b-frame-constructor-branching"
  "seam-gluing-ray-product/mosaic-stab-saturated"
  "seam-gluing-ray-product/w-soundness-shape-refuted"
  "seam-gluing-ray-product/deadline-ladder-branching"
  "seam-gluing-ray-product/node-cell-stabilization"
  "seam-gluing-ray-product/hit-presented-node"
  "seam-gluing-ray-product/ladder-cell-refutation"
  "seam-gluing-ray-product/ladder-liveness-forward-only"
  "seam-gluing-ray-product/ladder-cell-index-obstructions"
)

# --- WIRED_REPO ---------------------------------------------------------------------------
# Repository-relative probe paths, for probes that cannot (yet) live under `specs/evidence/`.
#
# probe (repository-relative path)                          | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# specs/archive/476_box_faithful_small_model_theorem/       | the finite model property FAILS at
#   evidence/fmp-hypothesis-is-false.lean                   | ZTime for EVERY candidate list --
#                                                           | `fmp_false` exhibits one formula no
#                                                           | finite `IntPresentation` satisfies
#                                                           | but which is ZTime-satisfiable.  This
#                                                           | is why the decision layer presents
#                                                           | finite GENERATORS of infinite regular
#                                                           | models rather than searching for a
#                                                           | finite model, and why no finite-model
#                                                           | certificate may be assumed available
#
# WHY THIS ONE IS NOT UNDER `specs/evidence/`.  It should be, by the convention in this file's
# header, and this is a DEFERRED MOVE with a named blocker -- not an exemption.  Three files
# outside the current writable scope cite the probe by its archive path verbatim
# (`FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
# `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, and
# `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`), so moving the file would break
# those citations in the same edit.  Move it when those three sites can be updated together.
#
# NOTE ON VERSION CONTROL.  `.gitignore` excludes `specs/archive/`, so this file survives in
# version control only because it was tracked before it was archived; a *new* file at that path
# would not be.  `git add` on it needs `git add -u`, since plain `git add` refuses an
# ignore-matching pathspec.  That fragility is a further reason to complete the move.
WIRED_REPO=(
  "specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean"
)

# --- DEFERRED -----------------------------------------------------------------------------
# `spike-untl-unfolding-and-fwd-obstruction` is deliberately NOT wired.  It no longer compiles:
# it cites `FrameClass.Discrete` and `TaskFrame.trivialFrame`, both gone from the current
# frame-class API.  Its subject is the frame-class mismatch between `FrameClass.Base` and
# `FrameClass.Discrete`, and it asserts results about a `filteredStep_fwd` that the frame-class
# uniformity work is expected to change.  Wiring it now would freeze a question that is still
# open.  When that work lands, repair it under the same no-weakening rule as the wired probes
# (track the API; never delete or restate an obstruction to make it pass), then wire it in.
DEFERRED=("bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction")

failures=0
echo "Evidence probes (compile-checked outside the build graph)"
echo "========================================================="

# One check, both entry forms: $1 is the label printed, $2 the file to compile.
check_probe() {
  local label="$1" file="$2"
  printf '  %-62s ' "$label"
  if [ ! -f "$file" ]; then
    echo "FAIL (missing: $file)"
    failures=$((failures + 1))
    return
  fi
  # Presence is not enough: a gitignored file (e.g. under `specs/archive/`) satisfies `-f` on
  # every machine that has it on disk and is absent from every fresh clone.  See TRACKED, NOT
  # MERELY PRESENT in the header.
  if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
    echo "FAIL (untracked: $file -- present on disk but not in version control; a fresh clone has no such file)"
    failures=$((failures + 1))
    return
  fi
  local out
  if out=$(lake env lean "$file" 2>&1); then
    echo "PASS"
  else
    echo "FAIL (does not compile)"
    printf '%s\n' "$out" | sed 's/^/        /'
    failures=$((failures + 1))
  fi
}

for probe in "${WIRED[@]}"; do
  check_probe "$probe" "$EVIDENCE/$probe.lean"
done

for probe in "${WIRED_REPO[@]}"; do
  check_probe "$probe" "$probe"
done

for probe in "${DEFERRED[@]}"; do
  printf '  %-62s ' "$probe"
  if [ -f "$EVIDENCE/$probe.lean" ]; then
    echo "SKIP (deferred: frame-class uniformity work)"
  else
    echo "SKIP (deferred; file absent)"
  fi
done

wired_total=$(( ${#WIRED[@]} + ${#WIRED_REPO[@]} ))

echo
if [ "$failures" -eq 0 ]; then
  echo "PASS  all $wired_total wired probe(s) compile"
  exit 0
fi
echo "FAIL  $failures of $wired_total wired probe(s) failed"
echo
echo "A probe failing means a recorded design obstruction no longer compiles."
echo "Do NOT delete the probe or weaken its statements to make this pass: repair the"
echo "citation drift, or -- if the obstruction genuinely no longer holds -- say so"
echo "explicitly and revisit the decision the probe was holding in place."
echo "A 'FAIL (untracked: ...)' means the record has left version control (typically an"
echo "archival mv into the gitignored specs/archive/): promote the file into specs/evidence/,"
echo "or delete the entry if the library now carries the result under lake build -- never"
echo "force-track it under specs/archive/."
exit 1
