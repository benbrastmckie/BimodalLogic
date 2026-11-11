# Semantics/Presheaf

The interval site `Int(D)` and the behavior presheaf `Beh(F)` on it: a task frame's convex
histories, packaged as a presheaf on the durations rather than treated one domain at a time.

The objects of `Int(D)` are the durations — the positive cone of a temporal order — and its
morphisms `l' → l` are the **translations** `Tr p`, one for each offset `p` with `p + l' ≤ l`.
`Beh(F)(l)` is the set of partial histories whose domain is exactly `[0, l]`, and restriction
along `Tr p` is `τ ↦ (z ↦ τ(p + z))`. Five of the ten modules are built on
`Semantics/PartialHistory.lean` alone (`Presheaf/Reflection.lean` adding only the tactic import
`Mathlib.Tactic.Abel`), and `Presheaf/Duration.lean` on `Presheaf/Site.lean` alone;
`Presheaf/Path.lean` builds on `Presheaf/Sheaf.lean`, `Presheaf/Duration.lean` and
`Semantics/IntNormalFormEffective.lean`, and is the one module of the cluster — and of the live
library — importing `Mathlib.CategoryTheory` (`Mathlib.CategoryTheory.Functor.Basic`, together
with `Mathlib.Combinatorics.Quiver.Path`), synonym-scoped as the sixth recorded verdict below
explains; `Presheaf/Directed.lean` and `Presheaf/Worlds.lean`
additionally import the `Semantics/Extension/` cluster — the former because the two clauses it
discharges are wrappers on `thm:extension`, the latter for `PartialHistory.hF_nonempty` alone,
which only its nonemptiness tail consumes — and `Presheaf/Determinism.lean` additionally imports
`Semantics/FrameProperty.lean` for `TaskFrame.Deterministic` alone. The cluster sits strictly
**below** `Semantics/Truth.lean` regardless: all ten modules close with `assert_not_exists` on the
proof system, so the layering is locked rather than merely observed.

`Presheaf/Duration.lean` is the categorical description of the site itself rather than of the
presheaf on it: the **duration monoid** `BD⁺` (`Dur`, the one-object category whose morphisms are
the durations, composing by addition), the **factorization category** of each duration
(`Factorization`, `Factorization.Hom`) with **factorization-linearity** in its two halves
(`Factorization.hom_unique`, `Factorization.hom_total`), and the **twisted-arrow category**
`Tw(BD⁺)` (`Tw`) with the identity-on-objects, bijective-on-homs isomorphism `Tw(BD⁺) ≅ Int(D)`
(`Tw.toTr`/`Tw.ofTr`, functorial by `Tw.toTr_comp`/`Tw.toTr_id`) that carries the Johnstone
coverage of the one onto that of the other (`Tw.toTr_coverLeft`/`Tw.toTr_coverRight`, both `rfl`
because both coverages are indexed by the cut point). That is the paper's `lem:interval-twisted-arrow`,
whose anchors — `def:twisted-arrow`, `lem:factorization-linear`, `lem:interval-twisted-arrow` —
resolve as `DANGLING` rows of the definitions of record exactly as the site's own do. The
encoding decision for the whole cluster — concrete structures, no `Mathlib.CategoryTheory` — is
reconciled with `Site.lean`'s note in `Duration.lean`'s Implementation Notes, which state the
trade-off and name the path-category work as the point at which it should be weighed again. That
weighing is done in `Presheaf/Path.lean`, and comes out the other way there — minimally and
synonym-scoped, as the sixth recorded verdict below records; `Site.lean` and `Duration.lean`
themselves stay concrete.

Six clauses of the presheaf dictionary are discharged here. *Germs* identifies the sections over
the zero duration with the world states (`Beh.germEquiv`), and *Sheaf* glues two sections
agreeing at a seam into a unique section over the joined interval (`sheaf_clause`, and
`sheaf_clause_site` in the site's own vocabulary). The gluing argument itself is not local to this
cluster: it is `PartialHistory.rel_across_seam`, shared with history pasting. *Totality* makes
every restriction map surjective (`totality_clause`, `totality_clause_site`) and *Directed Gluing*
extends a directed compatible family to the whole interval (`directed_gluing_clause`); both are
wrappers on `thm:extension`, and `Presheaf/Directed.lean` is where that is made visible. *Total
Histories* — the clause the definitions of record list as *Possible Worlds* — identifies the
possible worlds with the limit of the presheaf along the central restrictions `Tr (x' − x) :
2x → 2x'`: a world **is** a compatible family of centred sections (`worldsEquiv`, with the
compatibility in the site's vocabulary as `Lim.compat_site`), and the limit is nonempty
(`lim_nonempty`); `Presheaf/Worlds.lean` presents the limit concretely as the families `Lim F`,
and the fourth recorded verdict below is that the isomorphism is choice-free.

*Reflection* is the one clause that says something about the **logic** rather than restating the
semantics. It states that reflection is a natural isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref` between the
behavior presheaf of a frame and that of its **converse frame** `F⁻`, precomposed with the
reflection automorphism `ref` of the site (`Tr p : l' → l ↦ Tr (l − p − l') : l' → l`, an
involution fixing objects and identities, preserving composition covariantly, and interchanging
`lres` with `rres`). A section is reflected pointwise, `τʳ(z) = τ(l − z)` (`Beh.reflectSec`),
reflecting commutes with restriction along a reflected translation (`Beh.reflect_natural`), and
every component is a bijection (`Beh.reflectEquiv`, from the involution `Beh.reflect_reflect` and
`(F⁻)⁻ = F` by `rfl`). `Presheaf/Reflection.lean` is **constraint-free** — every one of its twelve
declarations reads `Constraints consumed: None` and measures `[propext, Quot.sound]` — because the
reflection convention on the task relation supplies the involution by definition: the converse
frame is `FrameOver.rev` / `TaskFrame.rev` of `Semantics/TaskFrame.lean`, **consumed rather than
rebuilt**, and its task relation is the converse of the original's by `Iff.rfl`. This natural
isomorphism is the categorical packaging of the involution behind the time reflection metarule
`TR`: `thm:TR-valid` is `validOn_rev_iff` (`Semantics/Validity.lean`) over `truthAt_rev`
(`Semantics/Reversal.lean`), the same involution one level down, on truth values rather than on
sections.

`Presheaf/Path.lean` is the cluster's capstone: the paper's `cor:path-fibration`, built as the
**instance** of Johnstone's sheaf/Conduché correspondence at `X = Beh F`. The **path category**
`Path(F)` has the world states as objects and, as morphisms `w → u` of length `l`, the sections
`τ ∈ Beh F l` with `τ(0) = w` and `τ(l) = u` (`PathHom`, with the length carried in the hom);
identities are the germs and composition is the *Sheaf* clause in sum form (`glueSum`, which is
`glue` under a val-preserving cast), with the three category laws proved through uniqueness of
gluing (`PathCat.instCategory`). The **length functor** `PathCat.len : Path(F) ⥤ BD⁺` is a
**discrete Conduché fibration** (`PathCat.len_isDiscreteConduche`): every morphism and every
factorization of its length admit a unique factorization through the cut state, the two factors
being the two restrictions (`PathHom.factorLeft`/`factorRight`, `factor_comp`, `factor_unique`).
And the **associated presheaf** of `len` is `Beh F` **as an equality**, not merely up to natural
isomorphism: restriction along `Tr p` is the middle factor of the three-fold factorization, which
is *defined* as `Beh.restrictTr` (`PathHom.assocRestrict_sec` closes by `rfl`), unique by
`assocRestrict_unique`, and functorial by `Beh.restrictTr_id`/`restrictTr_comp`. What is **not**
there, by the task's hard scope limit, is Johnstone's general equivalence
`fact:conduche-equivalence` between sheaves on `Int(D)` and discrete Conduché fibrations over
`BD⁺` (Johnstone, Prop. 3.6; Schultz-Spivak-Vasilakopoulou, Thm. A.2.1): it is cited and
external, the "associated category of a sheaf" and "associated presheaf of a fibration" of
`def:conduche` are instantiated at `Beh F` and `len` rather than defined in general, and the
module docstring says so, so that a reader does not mistake the instance for the theorem.

Over `D = ℤ` the package becomes the paper's **free category on the one-step task graph**
`(W, ⇒₁)`. Layer 1: a function on `[0, n]` is the state function of a section iff it respects
adjacency at every step (`beh_int_iff_adjacent_window`, from "iterating *Compositionality*" —
`FrameOver.taskRel_natCast_iff_iter` — with `⇒₀` the identity and the reflection convention for
negative differences, through the choice-free `FrameOver.reflection_int`). Layer 2: the morphisms
`w → u` are in bijection with the `Quiver.Path`s of the one-step quiver on the synonym
`StepGraph F` (`PathHom.pathEquiv`), with lengths preserved (`toPath_length`), identities to the
empty path (`toPath_id`) and gluing to concatenation (`toPath_comp`) — the data of Mathlib's
`CategoryTheory.Paths.categoryPaths`, matched without importing it. This is the "root paths of a
finite class graph" presentation the decidability route's sliced finite-model-property
refutation record asks of any successor class, now read off the categorical packaging; the
seventh recorded verdict below reconciles the earlier statement that it had not landed. The
constraint footprint is the cluster's: *Compositionality* alone, as an explicit hypothesis, for
`glueSum`, `comp`, `comp_assoc`, the two factorization theorems and `assocRestrict_unique`; the
`[F.IsRegular]` bundle wherever the germs enter (`id`, the `Category` instance, `len`) and
throughout the `D = ℤ` layer; and `#print axioms` reports `[propext, Quot.sound]` or less on all
fifty-five declarations — the module is choice-free in both of the senses measured below.

*Germs* and *Sheaf* are choice-free in two measured senses — they use *Compositionality* alone,
taken as an explicit hypothesis rather than a frame bundle, and `#print axioms` reports no
`Classical.choice` on either. **That is no longer a cluster-wide claim**, and it was one before
`Presheaf/Directed.lean` landed: `totality_clause`, `directedSup` and `directed_gluing_clause` all
measure `Classical.choice`. The split, and what each clause's choice is attributable to, is the
third recorded verdict below.

`Presheaf/Ray.lean` adds the **ray layer**, the half-line counterpart of the bounded sections. A
section `Beh F l` has domain exactly `[0, l]`; a possible world does not, and what a seam-local
construction quantifies over is the pair of rays at a seam time — `(-∞, t]` backward and
`[t, ∞)` forward. Those are `PastRay F t` and `FutRay F t`, presented as dependent functions on
the time subtypes so that ray equality is `funext`, with `toPH` reading the same ray as a
`PartialHistory` on a half-line domain and `FutRay.toBeh` cutting a bounded section out of a
forward ray. No new structure is introduced for either: `PartialHistory`'s `domain` field is an
arbitrary predicate, so a half-line is already expressible. The colimit-of-bounded-sections
presentation of a ray is deliberately not taken, because it is the route that incurs *Saturation*.

One asymmetry with the two clauses above is worth stating rather than leaving to be noticed. The
*Germs* and *Sheaf* declarations take *Compositionality* as an **explicit hypothesis**; the ray
layer's gluing operator and keystone instead carry the bracketed `[F.IsRegular]` bundle, which
supplies more than they consume. That is deliberate and not an oversight: the keystone is a
promoted probe result and its statements are kept hypothesis for hypothesis, so a reader checking
them against the probe finds them unchanged. The binder-free form of the content they actually
use is `PartialHistory.rel_across_seam`'s own signature, which the seam step delegates to. The
second measured sense of choice-freedom is unaffected and holds across the whole cluster: every
one of `Ray.lean`'s declarations measures `[propext]` or `[propext, Quot.sound]`.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Presheaf -->
| File | Lines | Description |
|------|------:|-------------|
| `Behavior.lean` | 305 | The behavior presheaf `Beh F`: the sections over a duration, the restriction action at raw data and at a site morphism, presheaf functoriality, and the *Germs* clause `Beh F 0 ≃ F.WorldState` |
| `Determinism.lean` | 254 | The *Determinism* clause below the layering lock: `Separated` as injectivity of every restriction map, the choice-free (⇒) half, the world-to-section bridge `secOf`, and the converse's frame-side conclusion with `SingletonClasses` unfolded |
| `Directed.lean` | 521 | The *Totality* and *Directed Gluing* clauses as wrappers on `thm:extension`: the translate `place`, the cut `ofWorld`, the directed union `directedSup`, both clauses in binder-free engine form with their instantiations, and the choice record |
| `Duration.lean` | 425 | The categorical description of the site: the duration monoid `BD⁺` as `Dur`, the factorization category `Factorization`/`Factorization.Hom` with both halves of factorization-linearity, the twisted-arrow category `Tw` with its three category laws, the hom-set bijection `Tw.toTr`/`Tw.ofTr` with `Int(D)` and its functoriality, and the coverage transport `Tw.toTr_coverLeft`/`Tw.toTr_coverRight` that makes `Tw(BD⁺) ≅ Int(D)` an isomorphism of sites |
| `Path.lean` | 1,554 | The path category `Path(F)` and `cor:path-fibration` at the instance `Beh F`: the morphisms `PathHom` (a section with its length and endpoints), the `Category` instance on the synonym `PathCat F`, the length functor `PathCat.len : Path(F) ⥤ BD⁺`, its discrete Conduché fibration property `PathCat.len_isDiscreteConduche`, the associated presheaf of `len` as `Beh F` on the nose (`PathHom.assocRestrict_sec`), and the `D = ℤ` clause — `beh_int_iff_adjacent_window` and the free-category bijection `PathHom.pathEquiv` with `PathHom.toPath_comp`; the one `Mathlib.CategoryTheory` import of the live library, synonym-scoped; choice-free throughout; `fact:conduche-equivalence` cited, not proved |
| `Ray.lean` | 444 | The ray layer: the half-line sections `PastRay`/`FutRay` at a seam, their seam projections and bridges, and the ray-layer gluing operator with its reading equations, restriction identities, uniqueness and totality |
| `Reflection.lean` | 283 | The *Reflection* clause: the reflection automorphism `Tr.ref` of `Int(D)` with its five laws, the section reflection `Beh.reflectSec` landing in the converse frame's presheaf, naturality `Beh.reflect_natural`, the involution `Beh.reflect_reflect`, and the component bijection `Beh.reflectEquiv : Beh F l ≃ Beh F.rev l`; constraint-free and measured `[propext, Quot.sound]` throughout |
| `Sheaf.lean` | 440 | <!-- TODO: add description --> |
| `Site.lean` | 193 | The interval site `Int(D)`: the translations `Tr p`, the three category laws, and the Johnstone coverage |
| `Worlds.lean` | 392 | The *Total Histories* clause (the record's *Possible Worlds*): the limit `Lim F` of the behavior presheaf along the central restrictions `centralTr`, presented as compatible families of centred sections, the canonical-window reading `Lim.readAt` with its keystone `Lim.read_eq`, the two maps `Lim.toWorld`/`Lim.ofWorld`, the choice-free isomorphism `worldsEquiv : WorldHistory F ≃ Lim F` at no frame constraint, and the nonemptiness tail `lim_nonempty` at `[F.IsRegular]` |
<!-- END GENERATED -->

## Key Definitions

- `Obj D`, `Tr l' l` — the objects and morphisms of the interval site `Int(D)`
- `Tr.id`, `Tr.comp` — the identity `Tr 0` and composition, which adds offsets
- `coverLeft`, `coverRight` — the two members of the Johnstone covering family of `l` at a cut
  point `p ≤ l`
- `Dur D`, `Dur.comp`, `Dur.id` — the morphisms of the duration monoid `BD⁺` (equal to `Obj D` by
  design; the alias names the role in play), composing by addition with identity `0`
- `Factorization l`, `Factorization.Hom a b` — the objects and morphisms of the factorization
  category `Fact(l)` of a duration: a factorization `l = fst + snd`, and the duration `z` with
  `z + a.fst = b.fst` and `a.snd = z + b.snd`. Named `Factorization`, not `Fact`, because `Fact` is
  Mathlib's typeclass-carried-proposition class; `Hom` is its own declaration because the morphism
  identification is the load-bearing step of factorization-linearity
- `Factorization.homOfLe`, `Factorization.ofCut` — the comparison morphism when `a.fst ≤ b.fst`,
  and the factorization `l = p + (l - p)` determined by a cut point `p ∈ [0, l]`
- `Tw l' l`, `Tw.id`, `Tw.comp` — the morphisms `l' → l` of the twisted-arrow category `Tw(BD⁺)`:
  the paper's pairs `(p, q)` with `p + l' + q = l`, as `pre`/`post`, composing
  `(p, q) ∘ (p', q') = (p + p', q' + q)` with identity `(0, 0)`
- `Tw.toTr`, `Tw.ofTr` — the hom-set maps `(p, q) ↦ Tr p` and `Tr p ↦ (p, l - p - l')` between
  `Tw(BD⁺)` and `Int(D)`
- `Tw.coverLeft`, `Tw.coverRight` — the Johnstone covering family of `l` in `Tw(BD⁺)`, indexed by
  the cut point `p` with `q := l - p` so that its source objects are definitionally the site's
- `Beh F l` — the sections of the behavior presheaf over `l`: the partial histories whose domain
  is exactly `[0, l]`
- `Beh.restrict`, `Beh.restrictTr` — the presheaf action, at raw data and indexed by a morphism of
  the site
- `Beh.germ`, `Beh.ofGerm`, `Beh.germEquiv` — a section over `0` and its single world state, and
  the bijection between them
- `Tr.ref` — the reflection automorphism of `Int(D)` on morphisms, `Tr p ↦ Tr (l − p − l')`;
  objects are fixed, so no object-level map is declared
- `Beh.reflectSec` — the reflection of a section, `τʳ(z) = τ(l − z)`, landing in `Beh F.rev l`:
  a section of the **converse** frame, which is `TaskFrame.rev` of `Semantics/TaskFrame.lean`
  consumed as it stands
- `Beh.reflectEquiv` — the *Reflection* clause's component bijection `Beh F l ≃ Beh F.rev l`
- `glue` — the glued section: `τ₁` over `p` and `τ₂` over `l - p`, agreeing at the seam, read as
  one section over `l`
- `PastRay F t`, `FutRay F t` — the ray layer: the half-line sections at a seam time `t`, as
  dependent functions on the time subtypes `{x // x ≤ t}` and `{x // t ≤ x}` carrying the
  unconditional all-pairs task constraint
- `PastRay.seam`, `FutRay.seam` — a ray's state at the seam: the right endpoint of a past ray, the
  left endpoint of a future ray
- `pastOf`, `futOf` — the two restrictions of a possible world to its rays at a time
- `PastRay.toPH`, `FutRay.toPH` — the same rays read as `PartialHistory F` on a half-line domain,
  the form that reaches the shared `PartialHistory` API
- `FutRay.toBeh` — the ray-layer-to-`Beh` restriction: a forward ray at `0` cut down to the
  bounded section over `l`
- `StabFibre F t s`, `RayPair F t s` — the `⊡` quantification domain at `(t, s)`, and the fibre
  product of the past-ray and future-ray spaces over the seam state
- `Separated F` — separatedness of `Beh F`: every restriction map is injective. At `l' = 0` this
  is injectivity of the germ maps, the form every consumer uses
- `secOf` — the world-to-section bridge: a possible world cut down to the section over `[0, l]`
  based at a time `m`, through which the `Beh`-level clause meets the total-history statement
  `PlusLanguage.states_eq_of_deterministic`
- `place` — the translate: a section over `m` placed at offset `p`, as a partial history with
  domain `Interval p (p + m)`. Written against the interval rather than through
  `PartialHistory.timeShift`, which keeps the arithmetic negation-free
- `ofWorld` — the cut: a possible world restricted to `[0, l]`, as a section of `Beh F l`. Its
  section condition is `fun _ => Iff.rfl`, which is what `Beh`'s pointwise-`Iff` design buys
- `directedSup` — the union of a **directed** family of partial histories, `noncomputable` as
  `PartialHistory.chainSup` is. The one piece of genuinely new machinery either new clause needs,
  since `thm:extension` consumes a single history. Its natural home is beside `chainSup` in
  `Semantics/PartialHistoryOrder.lean`, from which `chainSup` could then be derived; that
  consolidation is recorded as a follow-up in `Presheaf/Directed.lean`'s Implementation Notes
- `twice`, `centralTr` — the object `2x` of the site (written `x.val + x.val`, there being no
  `OfNat` literal `2` on an abstract temporal order) and the central morphism
  `Tr (x' − x) : 2x → 2x'`
- `Lim F` — a point of the limit `lim_{x ∈ D⁺} Beh(F)(2x)`: a compatible family of centred
  sections, one over each `[0, 2x]`, each restricting to the next along the central translation.
  Presented concretely, as `glue` presents the sheaf condition, with no `Mathlib.CategoryTheory`
- `absObj`, `Lim.readAt`, `Lim.toWorld` — the canonical window index `|t|` of a time, the state
  read out of that window, and the possible world `WorldHistory.ofTotal` glues from it: the
  backward map. Totality is structural — the centred chain covers the order — so no extension
  step and nothing from `Presheaf/Directed.lean` is consumed
- `Lim.ofWorld` — the forward map: a possible world cut to each of its centred windows
  `[−x, x]` through `secOf`
- `Beh.castLen`, `glueSum` — the val-preserving cast of a section along an equation of lengths,
  and the *Sheaf* clause in sum form: `glue` at the cut `l₁` applied to the cast second section
- `PathHom F w u` — a morphism of `Path(F)`: a length `len : Dur F.Duration`, a section
  `sec : Beh F len` and the two endpoint equations; `PathHom.id` is the germ, `PathHom.comp` is
  `glueSum`
- `BObj D`, `PathCat F`, `StepGraph F` — the three synonyms carrying the module's instances: the
  one object of `BD⁺` with its `Category` instance (`Hom := Dur D`), the path category on the
  world states (`Hom := PathHom`), and the one-step quiver (`Hom a b := PLift (a ⇒₁ b)`). No
  instance is placed on `Obj D`, `Dur D`, `Tr` or `F.WorldState`
- `PathCat.len` — the length functor `Path(F) ⥤ BD⁺`, `map f := f.len`, functorial by `rfl`
- `IsDiscreteConduche P` — the discrete Conduché fibration predicate of `def:conduche` for a
  functor `P : E ⥤ BObj D`: every morphism and every `Factorization` of its image admit a unique
  factorization. Stated in general so that `len` can be shown to satisfy it; no construction from a
  general fibration is built
- `PathHom.cutState`, `PathHom.factorLeft`, `PathHom.factorRight` — the unique factorization of a
  morphism along a factorization of its length: the state at the cut, and the two restrictions
- `PathHom.assocRestrict` — the associated presheaf of `len`: restriction along `f : Tr l' l` as
  the middle factor of the three-fold factorization, whose section is `Beh.restrictTr f` by
  definition
- `Beh.ofAdjacentWindow` — over `D = ℤ`, the section over `[0, n]` built from a function that
  respects adjacency at every step
- `PathHom.toPath`, `PathHom.ofPath`, `PathHom.pathEquiv` — the bijection between the morphisms of
  `Path(F)` and the `Quiver.Path`s of `(W, ⇒₁)` over `D = ℤ`, with `PathHom.ofStep` the one-step
  morphism

## Key Results

- `Tr.id_comp`, `Tr.comp_id`, `Tr.comp_assoc` — the three category laws of `Int(D)`
- `Tr.le_of_hom` — a morphism `l' → l` witnesses `l' ≤ l`
- `cover_germ_composites` — the two covering morphisms have equal composite shift with the germ,
  which is what makes the sheaf condition on this coverage a two-section gluing statement
- `Dur.id_comp`, `Dur.comp_id`, `Dur.comp_assoc`, `Dur.comp_comm` — `BD⁺` is a commutative monoid
- `Factorization.ext` — a factorization is determined by its first summand alone
- `Factorization.hom_unique`, `Factorization.hom_total` — **factorization-linearity** of `BD⁺`:
  at most one morphism between any two factorizations (cancellation alone), and at least one in
  one direction or the other (totality of the order). Every `Fact(l)` is a linear preorder
- `Factorization.fst_le`, `Factorization.ofCut_fst`, `Factorization.ofCut_fst_self` — the
  factorizations of `l` correspond bijectively to the cut points `p ∈ [0, l]`
- `Tw.id_comp`, `Tw.comp_id`, `Tw.comp_assoc` — the three category laws of `Tw(BD⁺)`
- `Tw.toTr_ofTr`, `Tw.ofTr_toTr`, `Tw.toTr_comp`, `Tw.toTr_id` — the hom-set map is a bijection
  and functorial: identity on objects plus bijective on homs, `Tw(BD⁺) ≅ Int(D)` as categories
- `Tw.toTr_coverLeft`, `Tw.toTr_coverRight` — **coverage transport**: the isomorphism carries the
  Johnstone covering family of `Tw(BD⁺)` at a cut point to that of `Int(D)` at the same cut point,
  both by `rfl`. With the cut-point bijection, the correspondence of covering families is itself a
  bijection, so `Tw(BD⁺) ≅ Int(D)` as **sites** — the paper's `lem:interval-twisted-arrow`
- `Beh.restrict_id`, `Beh.restrict_comp` — presheaf functoriality at raw data
- `Beh.restrictTr_id`, `Beh.restrictTr_comp` — the same at the site, where the contravariance is
  visible: `restrictTr (Tr.comp f g) = restrictTr g ∘ restrictTr f`
- `Beh.germ_ofGerm`, `Beh.ofGerm_germ` — the two round trips of `Beh.germEquiv`, the *Germs*
  clause. The only results here that reach a frame constraint, through `[F.IsRegular]`
- `Beh.isConvex`, `Beh.domain_eq_interval` — a section is convex, and its domain is `Interval 0 l`
- `Tr.ref_ref`, `Tr.ref_id`, `Tr.ref_comp` — `ref` is an involution, fixes identities, and
  preserves composition **covariantly**: an automorphism of `Int(D)`, not a duality
- `Tr.ref_lres`, `Tr.ref_rres` — `ref` interchanges the left and right restrictions
- `Beh.reflect_natural` — **naturality** of reflection in the translations: reflecting a
  restriction is restricting the reflection along the reflected translation
- `Beh.reflect_reflect` — reflection is an involution on sections, `(τʳ)ʳ = τ`, stated at
  `F.rev.rev` with no cast because `TaskFrame.rev_rev` is `rfl`
- `sheaf_clause` — the *Sheaf* clause: two sections agreeing at the seam glue to a **unique**
  section over the joined interval, stated in cut form as an `∃!`
- `restrict_glue_left`, `restrict_glue_right` — the two restriction identities of `glue`. The
  right one is where the seam hypothesis is consumed, because the branch test is true at the
  right interval's own origin
- `glue_states_le`, `glue_states_not_le` — the two reading equations of `glue`, one per branch of
  its dependent `if`; every proof about `glue` goes through these rather than unfolding it
- `glue_unique` — any section restricting to `τ₁` and `τ₂` is `glue`
- `Ray.seamGlue` — the ray-layer gluing operator: a past ray and a future ray agreeing at the seam,
  read as one possible world. The paper's own seam operator in the case its pasting passage
  applies it in, with `PlusLanguage.PlusPasting.paste` as its total-history instance
- `Ray.seamGlue_states_le`, `Ray.seamGlue_states_not_le` — the two reading equations of
  `Ray.seamGlue`, one per branch of its dependent `if`
- `Ray.seamGlue_rel_le_lt`, `Ray.seamGlue_rel` — task-respect for the glued state function; the
  seam step is delegated to `PartialHistory.rel_across_seam`, and the mixed-orientation case
  goes through the off-zero `TaskFrame.reflection_of_ne`, which is what keeps the whole
  ray-layer path clear of `Classical.choice`
- `Ray.pastOf_seamGlue`, `Ray.futOf_seamGlue` — the two restriction identities of
  `Ray.seamGlue`. The second is where the seam hypothesis is consumed, the branch test being
  true at the seam point itself
- `Ray.seamGlue_unique`, `Ray.seamGlue_clause` — uniqueness, and the `∃!` the restriction identities
  and uniqueness package
- `Ray.seamGlue_isTotal` — totality: the glued object is total on all of `F.Duration`
- `seamFibreEquiv` — **the keystone**: the `⊡` fibre over a seam state **is** the fibre product
  of the past-ray and future-ray spaces over that state. Forward: restrict. Backward: glue. The
  two round trips are `WorldHistory.ext_state` and funext, at any duration, and the whole path
  measures `[propext, Quot.sound]`. Its `⊡`-clause readings — over ray pairs and over pairs of
  ω-indexed step sequences — are `PlusLanguage/PlusRayFibre.lean`'s, which sits above
  `Semantics/Truth.lean` and so cannot live in this cluster
- `states_eq_of_eq` — reading a state out of an equality of sections, for either domain witness
- `sheaf_clause_site` — the *Sheaf* clause in the site's own vocabulary, along `coverLeft` and
  `coverRight`. Derived from `sheaf_clause` with no transport and no cast
- `restrictTr_coverLeft`, `restrictTr_coverRight` — restriction along either member of the
  covering family **is** the raw-data restriction the clause is stated with. Both `rfl`, which is
  what makes the site-level clause free
- `compat_iff_match` — the coverage's compatible-family condition, as an equality of germ
  sections in `Beh F 0`, is the raw seam hypothesis
- `separated_of_deterministic` — the (⇒) half of the *Determinism* clause: a deterministic frame
  has separated behavior. Choice-free (`[propext, Quot.sound]`), and it consumes only the germ at
  the offset
- `states_eq_of_deterministic_sec` — the section-level singleton bridge, `[propext]`: the
  `Beh`-layer counterpart of `PlusLanguage.states_eq_of_deterministic` by the same three-step
  proof, not an instance of it
- `states_eq_of_separated` — the (⇐) half's frame-side conclusion with `TaskFrame.SingletonClasses`
  unfolded, because that name sits above this cluster's lock. The biconditional itself is
  `Semantics/DeterministicBridge.lean`'s `deterministic_iff_separated`
- `restrict_ofWorld` — the bridge both new clauses share: if a possible world extends
  `place p hm σ`, restricting its cut over `[0, l]` along the translation by `p` returns `σ`
- `totality_of_isRestriction` — the *Totality* clause's **engine**: every restriction map of the
  behavior presheaf is surjective, with the extension property taken as an explicit hypothesis and
  therefore no frame constraint at all. Measures `[propext, Quot.sound]`, which is what makes the
  choice in `totality_clause` attributable rather than merely co-present
- `totality_clause`, `totality_clause_site` — the *Totality* clause at `[F.IsRegular]`, at raw
  offsets and along a site morphism `f : Tr l' l`
- `totality_of_isZTime`, `totality_of_completion` — the two **Saturation-free** forms, over
  discrete ℤ-time and at bare *Completion*. Saturation-free is not choice-free: both still route
  through Zorn
- `directed_states_agree` — two members of a directed family agree wherever both are defined; the
  directed analogue of `PartialHistory.chain_states_agree`, with a common upper bound in place of
  `IsChain.total`
- `le_directedSup` — every member of a directed family is below its union
- `place_le_place` — the paper's "any two restrict a third" bridge, from its two hypotheses
  (directedness of the windows, compatibility on overlaps) to the single `Directed (· ≤ ·)` the
  gluing proof consumes
- `directed_gluing_of_isRestriction` — the *Directed Gluing* clause's existence half in engine
  form: union the translates, extend, cut. Unlike *Totality*'s engine this one **still** measures
  `Classical.choice`, because `directedSup` is independently non-constructive
- `directed_gluing_unique` — the uniqueness half, under a covering hypothesis. Needs neither
  directedness nor any frame constraint; sections are functions on points
- `directed_gluing_clause` — the *Directed Gluing* clause itself, as the `∃!` the two halves
  package
- `restrictTr_central` — restriction along the central morphism **is** the raw-data restriction
  by `x' − x` onto `[0, 2x]`, by `rfl`, as `restrictTr_coverLeft` is for the covering family
- `Lim.compat_site` — the *Total Histories* compatibility in the site's own vocabulary, with no
  transport and no cast
- `Lim.read_eq` — **the keystone** of the clause: every window at least `|t|` reads the same
  state at `t`. Every later proof goes through it rather than through `compat` directly
- `Lim.respects` — task-respect for the glued state function, read out of the common window
  `max |s| |t|`
- `Lim.toWorld_ofWorld`, `Lim.ofWorld_toWorld` — the two round trips, the second through the
  componentwise `Lim.ofWorld_toWorld_sec` and the recentring bound `abs_sub_le_of_mem`
- `worldsEquiv` — **the *Total Histories* clause**: `WorldHistory F ≃ Lim F`, at **no** frame
  constraint, measured `[propext, Quot.sound]`
- `lim_nonempty` — the clause's closing tail at `[F.IsRegular]`: the limit is nonempty, through
  `PartialHistory.hF_nonempty`. The one declaration of `Presheaf/Worlds.lean` that reaches
  `Classical.choice`
- `glueSum_restrict_left`, `glueSum_restrict_right`, `glueSum_states_zero`, `glueSum_states_end` —
  the two restriction identities and the two endpoint readings of sum-form gluing, by delegation to
  `restrict_glue_left`/`restrict_glue_right`
- `PathHom.ext'`, `PathHom.id_comp`, `PathHom.comp_id`, `PathHom.comp_assoc` — extensionality of
  morphisms (equal lengths and equal underlying partial histories), and the three category laws of
  `Path(F)`, each through `glue_unique`
- `PathHom.factor_comp`, `PathHom.factor_unique`, `PathCat.len_isDiscreteConduche` — **the first
  half of `cor:path-fibration`**: the length functor is a discrete Conduché fibration
- `PathHom.assocRestrict_sec` (by `rfl`), `PathHom.assocRestrict_unique`,
  `PathHom.assocRestrict_id`, `PathHom.assocRestrict_comp` — **the second half**: the associated
  presheaf of `len` is `Beh F` as an equality — same sections, same restriction, same
  functoriality
- `iter_of_adjacent_window`, `beh_int_iff_adjacent_window` — **the `D = ℤ` clause, layer 1**: a
  function on `[0, n]` is a section's state function iff it steps along `⇒₁`
- `PathHom.toPath_length`, `PathHom.toPath_id`, `PathHom.toPath_comp`, `PathHom.ofPath_toPath`,
  `PathHom.toPath_ofPath` — **layer 2**: sections are paths of their own length, identities are
  the empty paths, gluing is concatenation, and the two readings are mutually inverse — `Path(F)`
  is the free category on `(W, ⇒₁)`

## Recorded verdicts

### The ray gluing stands in for a Zorn argument without subsuming the Extension Theorem

`Ray.seamGlue` produces a **total** world history from a pair of agreeing half-line rays, with no
Zorn argument and no choice: `Ray.seamGlue`, its two reading equations, its two restriction
identities, `Ray.seamGlue_unique`, `Ray.seamGlue_clause` and `Ray.seamGlue_isTotal` all measure
`[propext, Quot.sound]`.

The **positive** half of the verdict. That is the role the bi-lasso Tier A effective extension
theorem plays — `Metalogic/Decidability/BiLasso/Orbit.lean`'s `IntPresentation.extend_periodic`
and `IntPresentation.extend_periodic_of_icc`, whose *no Zorn* property `BiLasso/Agreement.lean`
exists in part to preserve — an effective total-history construction standing in for a Zorn
argument. `Ray.seamGlue` supplies such a construction for **every** pair of agreeing half-line
rays at a regular frame, not only for the bi-lasso case the orbit construction was built for.

The two properties are distinct, and the bi-lasso modules distinguish them explicitly:
`BiLasso/Agreement.lean` preserves the paper's "without appeal to Zorn's lemma" *exactly and only
as **no Zorn***, and records that it is **not** preserved as choice-freedom in Lean's sense —
`IntPresentation.extend_periodic` itself measures `Classical.choice`, for a reason internal to the
decoding module. The ray gluing has both properties at once: no Zorn, **and**
`[propext, Quot.sound]`.

The **limit**, stated as the verdict's other half and not as full subsumption. The general
Extension Theorem (`Semantics/Extension/Extension.lean`'s `extension`, routed through
`Semantics/PartialHistoryOrder.lean`'s `PartialHistory.exists_maximal_extension`, which is Zorn's
lemma over the extension order) handles a strictly wider class of inputs, and it is not
displaced. The gap is precisely locatable. A pair of half-line rays at `t` has two properties that
an arbitrary partial history does not: its domain **covers** all of `F.Duration`, and the two
halves **meet in exactly one point**. `Ray.seamGlueFun`'s total case split on `s ≤ t` is available
only because of those two facts. A `PartialHistory`'s `domain` is an arbitrary predicate on
`F.Duration` — neither total nor convex nor meeting any other domain in one point — so there is no
analogue of that case split there, and the maximal-extension route remains the only general one.
Deliverable 4 therefore closes **affirmatively with an explicit gap statement**, not by reasoned
exclusion.

### The choice record splits, and the split is the honest form

The ray layer is choice-free, as measured above. The ℤ/ω presentation in
`PlusLanguage/PlusRayFibre.lean` is **not**: `seamOmegaEquiv` and `plusStab_iff_omega` measure
`Classical.choice`, and the cause is upstream and named — `FrameOver.worldHistoryOfStepPath`,
reached through `pathFibreEquiv` to build a possible world out of a bare bi-infinite step path.
Rerouting that declaration is out of scope here: it is a core `Semantics/IntNormalForm.lean`
declaration with consumers on several independent fronts. A uniform claim in either direction
would be false; the split is the record.

### The dictionary's four clauses split on choice, and the split is attributable

The two clauses `Presheaf/Directed.lean` discharges are **wrappers** on `thm:extension`, and
stating them as a binder-free engine plus instantiations is what turns the choice measurement from
an observation into an attribution. Every row below was measured with `lean_verify` or
`#print axioms`; the module's own docstring carries the same table.

| Declaration | Measured axioms |
|---|---|
| `sheaf_clause` (binary *Sheaf*) | `[propext, Quot.sound]` |
| `ofWorld`, `directed_states_agree` | `[propext]` |
| `place`, `place_le_place`, `restrict_ofWorld` | `[propext, Quot.sound]` |
| `totality_of_isRestriction` (engine) | `[propext, Quot.sound]` |
| `PartialHistory.extension` | `[propext, Classical.choice, Quot.sound]` |
| `totality_clause`, `totality_clause_site` | `[propext, Classical.choice, Quot.sound]` |
| `totality_of_isZTime`, `totality_of_completion` | `[propext, Classical.choice, Quot.sound]` |
| `directedSup`, `le_directedSup` | `[propext, Classical.choice]` |
| `directed_gluing_unique` | `[propext, Quot.sound]` |
| `directed_gluing_of_isRestriction` (engine) | `[propext, Classical.choice, Quot.sound]` |
| `directed_gluing_clause` | `[propext, Classical.choice, Quot.sound]` |

Reading the four values: `[propext]` and `[propext, Quot.sound]` are **choice-free**;
`[propext, Classical.choice]` is the directed union's own non-constructivity; and
`[propext, Classical.choice, Quot.sound]` is everything that reaches Zorn's lemma, directly or
through the union.

*Totality*'s engine is measured choice-free *with the extension property as an explicit
hypothesis*, so the `Classical.choice` in `totality_clause` is **attributable** — exactly to
`thm:extension` and to nothing in the geometry of translating and cutting. *Directed Gluing* admits
no such attribution, and the contrast between the two engine rows is the evidence:
`directed_gluing_of_isRestriction` measures `Classical.choice` *even with the extension property
hypothesized away*, because the directed union `directedSup` is independently non-constructive.
Its choice is **doubly** sourced.

The non-constructivity of the directed case is a mathematical obstruction, not a Lean artifact.
`app:gluing`'s footnote supplies a counterexample proving *Saturation* is genuinely required there:
over `D = ℚ` with `W = {q ∈ ℚ : q > 0}` and `r ⇒ₓ r'` iff `|r' − r| ≤ x`, the restrictions of
`τ(t) = 1 − t` to `(0, b]` for `b < 1` form an increasing chain whose union admits no value at time
`1`. This is why the paper writes "in ZFC" at *Directed Gluing* and "choice-free" at *Sheaf*, and
why the binary case's choice-freeness **must not** be imported into the directed case.

`app:gluing` itself, in **full generality** — two arbitrary convex domains with a nonempty
overlap, rather than a closed-interval or ray seam — lives at the convex-history layer, in
`FormalSystem/Semantics/Gluing.lean` (`convexGlue`, `gluing_clause`), measured choice-free and
pinned so by `C14`. The two seam gluings in this cluster, `sheaf_clause` and `Ray.seamGlue`, are
**instances** of it, witnessed there by `convexGlue_rays_isTotal` and
`convexGlue_rays_states_past` rather than re-derived: their own `dif_pos`/`dif_neg` reading
lemmas are load-bearing downstream. `directed_gluing_clause` is not an instance at all, for the
mathematical reason recorded above.

`totality_of_isZTime` and `totality_of_completion` are **Saturation-free** — a statement about
`def:frame`'s fourth constraint, not a claim of choice-freedom. Both still route through Zorn's
lemma and both measure `[propext, Classical.choice, Quot.sound]`.

### The *Total Histories* clause is choice-free; only its nonemptiness tail is not

`worldsEquiv : WorldHistory F ≃ Lim F` holds at **no** frame constraint and measures
`[propext, Quot.sound]`, as does every declaration on the path to it; `lim_nonempty` alone
measures `Classical.choice`, attributably — through `PartialHistory.hF_nonempty` and hence Zorn's
lemma, which is where `cor:occurrence` places the paper's own use of choice. Every row below was
measured with `lean_verify` and a `#print axioms` sweep over every declaration of
`Presheaf/Worlds.lean`; the module's own docstring carries the same table.

| Declaration | Measured axioms |
|---|---|
| `twice` | `[propext]` |
| `central_fit`, `centralTr`, `restrictTr_central`, `Lim`, `Lim.ext`, `Lim.compat_site` | `[propext, Quot.sound]` |
| `window_lo`, `window_hi`, `absObj`, `absObj_val` | `[propext, Quot.sound]` |
| `Lim.readAt`, `Lim.readAt_def`, `Lim.read_eq`, `Lim.respects`, `Lim.toWorld`, `Lim.ofWorld` | `[propext, Quot.sound]` |
| `Lim.toWorld_ofWorld`, `abs_sub_le_of_mem`, `Lim.ofWorld_toWorld_sec`, `Lim.ofWorld_toWorld` | `[propext, Quot.sound]` |
| `worldsEquiv` | `[propext, Quot.sound]` |
| `lim_nonempty` | `[propext, Classical.choice, Quot.sound]` |

Two things earn the choice-free row and would lose it if rewritten, both recorded in the
module's Implementation Notes: the window arithmetic (`window_lo`, `abs_sub_le_of_mem`) is
written with explicit `rwa` rewrites rather than `simpa`, which was measured to pull
`Classical.choice`; and the backward map reads each time out of its canonical window `|t|`
rather than through `directedSup`, which is independently non-constructive. The clause does not
consume *Totality* at all — the centred chain already covers the order — so it joins *Germs*,
*Sheaf* and the ray layer on the choice-free side of the split recorded above, while its tail
joins *Totality* and *Directed Gluing*. Over `D = ℤ` the same identification of `H_F` is
`FrameOver.mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean`), a consequence of this clause's
shape rather than an input to it.

### The twisted-arrow site is choice-free, at the site's own baseline

Every declaration of `Presheaf/Duration.lean` measures `[propext]` or `[propext, Quot.sound]`;
none reaches `Classical.choice`. Every row below was measured with `lean_verify` or `#print axioms`.

| Declaration | Measured axioms |
|---|---|
| `Factorization.ext`, `Factorization.hom_unique`, `Factorization.fst_le`, `Dur.comp_assoc` | `[propext]` |
| `Tw.ext`, `Tw.id_comp`, `Tw.comp_id`, `Tw.comp_assoc`, `Tw.toTr`, `Tw.toTr_id` | `[propext]` |
| `Factorization.homOfLe`, `Factorization.ofCut`, `Factorization.hom_total`, `Factorization.ofCut_fst_self` | `[propext, Quot.sound]` |
| `Tw.ofTr`, `Tw.toTr_ofTr`, `Tw.ofTr_toTr`, `Tw.toTr_comp` | `[propext, Quot.sound]` |
| `Tw.coverLeft`, `Tw.coverRight`, `Tw.toTr_coverLeft`, `Tw.toTr_coverRight` | `[propext, Quot.sound]` |

Two things in the table were deliberate. `Factorization.hom_unique` cancels on the **left**: both
`left` fields read `z + a.fst = b.fst`, so the natural lemma is `add_right_cancel`, which at `↑D`
was measured to drag `Classical.choice` into the footprint; the commuted `add_left_cancel` form
stays at `[propext]`. And the `Quot.sound` rows all enter through one Mathlib lemma, `sub_nonneg`,
used wherever `l - p` is shown to be a duration — the same route by which `Site.lean`'s own
`coverRight` and `Tr.comp_assoc` measure the identical `[propext, Quot.sound]`. The module is
therefore at the site's own baseline, not above it.

### What a decidable stability check on the path-space presentation requires

`plusStab_iff_rays` and `plusStab_iff_omega` present `⊡` as a quantifier over a **product of two
path spaces**, one factor running backward from the seam and one forward. Three things follow
about any device that would summarise that quantification finitely, and they are stated here as a
**requirement** and not as a design: nothing below is built, selected or funded by this cluster.

- The device must be **universal over both factors**, hence complementation-shaped. A
  nondeterministic per-path summary does not supply it, and the divergence is elementary and
  finite rather than automata-theoretic: on a total, hence genuinely branching, step graph on
  `Bool`, `Probe718PathQuantifier.exists_ne_stab` and
  `Probe718PathQuantifier.exists_ne_universal` show the existential per-path summary to be `True`
  everywhere while the real value of the stability-of-eventually formula is `False` everywhere
  (`Probe718PathQuantifier.decide_will`).
- Its **backward** factor must be summarised on its own terms rather than obtained by
  time-reversing the forward one. The forward finite-graph summary
  (`Probe718FiniteGraph.will_iff_allPathsMeet`, `Probe718FiniteGraph.decide_will`) is proved on a
  fixture whose relation is symmetric under time reversal, and the finite-width obstruction lives
  in the backward factor, so that fixture cannot see it. `Probe719Backward` supplies the backward
  dual on a time-asymmetric fixture and records its own limit: that fixture is backward
  *deterministic*, so its backward factor is a singleton.
- **No complexity claim is committed here.** The CTL\* 2EXPTIME lower bound (argued, not formalized) is the sanity check
  on any bound a future device might carry; this cluster asserts none.

Which candidate device supplies the requirement is settled nowhere and is **not** asserted here —
not determinization, not a Safraless procedure, not an MSO-over-ℤ route, not a Ramsey-coloured
summary.

The path-category reading of the forward structure — the identification of `Path(F)` as the free
category on the one-step graph when the duration is ℤ, which is the "root paths of a finite
class graph" presentation a decidable check is usually stated over — **has since landed**, in
`Presheaf/Path.lean` (`PathHom.pathEquiv` with `PathHom.toPath_comp` and `PathHom.toPath_id`; see
the seventh recorded verdict below). Its paper labels (`def:conduche`, `def:path-category`,
`cor:path-fibration`, and the cited `fact:conduche-equivalence`) now carry `DANGLING` rows in
`docs/reference/paper-definitions-of-record.md`, as the rest of the cut appendix's anchors do.
What the landing supplies is the **presentation** and nothing more: it settles no device and
commits no bound, and the requirement stated above is unchanged by it.

### This presentation bounds nothing

`PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` stands exactly as proved. The
ray-product presentation is the **mechanism behind** that refutation rather than an escape from
it: a product of two path spaces cannot be a finite fibre. No width, tail-period or complexity
bound is committed anywhere in this cluster, and soundness is untouched.

### Sum-form gluing is cut-form gluing under a val-preserving cast

`Sheaf.lean`'s Implementation Notes record that a *sum* form of gluing — two independent lengths
`l₁`, `l₂`, gluing to `l₁ + l₂` — "buys nothing" for the *Sheaf* clause, since `l := l₁ + l₂`,
`p := l₁` recovers it. That verdict stands for the clause and is reconciled, not reversed, by
`Presheaf/Path.lean`: composition in `Path(F)` consumes exactly the sum form, and it costs one
line. `Beh.castLen h τ` is `⟨τ.val, _⟩` — the same partial history with the interval condition
re-read along `h` — so `castLen_val` is `rfl`, `glueSum` is `glue` at the cut `l₁` applied to the
cast second section, and its four reading lemmas delegate to `restrict_glue_left` and
`restrict_glue_right`. The idiom that makes the whole module mechanical is the same one: cast on
the length index, compare at `.val`, where the order proofs `Beh.restrict` carries are irrelevant.
`glue`'s seam `dite` is never unfolded outside `Sheaf.lean`.

### `Mathlib.CategoryTheory` enters the cluster synonym-scoped, in `Path.lean` only

`Site.lean`, `Duration.lean` and `Reflection.lean` record the concrete-structures decision and
`Duration.lean` defers its re-weighing to the path-category work. `Path.lean` is that re-weighing
and it comes out the other way, for one reason: the first deliverable of `cor:path-fibration` — a
discrete Conduché fibration `P : E ⥤ BD⁺` *in general* — quantifies over a functor from an
arbitrary category and is unstatable without `Category` and `Functor`. The import is
`Mathlib.CategoryTheory.Functor.Basic`, and nothing heavier (`PathCategory/Basic.lean` is matched,
not imported). Every instance sits on a synonym introduced in `Path.lean` — `BObj D`, `PathCat F`,
`StepGraph F` — and none on `Obj D`, `Dur D`, `Tr` or `F.WorldState`, so `Site.lean` and
`Duration.lean` are byte-for-byte unchanged in their declarations, their concrete laws are what the
instances are built from, and the cluster's `assert_not_exists` lock is untouched. The three
earlier notes carry one-sentence forward pointers to this verdict so the decision is neither
re-litigated nor misread as violated.

### The free-category reading is landed, and it is choice-free

The sixth verdict's companion. `PathHom.pathEquiv : PathHom F.toTaskFrame w u ≃ StepPath F w u`
with `toPath_id` and `toPath_comp` is the free-category identification; `#print axioms` on it, on
`PathCat.len_isDiscreteConduche`, on `PathHom.assocRestrict_unique`, on `PathHom.comp_assoc` and
on `beh_int_iff_adjacent_window` reports `[propext, Quot.sound]`, and no declaration of
`Path.lean` reaches `Classical.choice`. Two routing decisions keep it so: the `D = ℤ` layer's sign
split goes through `FrameOver.taskRel_natCast_iff_iter` and the choice-free
`FrameOver.reflection_int`, never through `FrameOver.reflection` or `taskRel_eq_iter`; and the
one-step morphism's endpoint facts are decided computably on `ℤ` (`decide`, `omega`, the core
`Int.not_le`), because Mathlib's order-theoretic `not_le`/`le_of_add_le_add_right` on `ℤ` measure
`Classical.choice` on this pin.

## Dependencies

- **Imports from**: `Semantics/TemporalOrder.lean`, `Semantics/PartialHistory.lean`, and —
  `Presheaf/Directed.lean` and `Presheaf/Worlds.lean` — `Semantics/Extension/Extension.lean`,
  with `Semantics/Extension/Completion.lean` imported by `Presheaf/Directed.lean` alone;
  `Presheaf/Duration.lean` imports `Presheaf/Site.lean` and nothing else; `Presheaf/Path.lean`
  imports `Presheaf/Sheaf.lean`, `Presheaf/Duration.lean`,
  `Semantics/IntNormalFormEffective.lean`, `Mathlib.CategoryTheory.Functor.Basic` and
  `Mathlib.Combinatorics.Quiver.Path`
- **Imported by**: `Semantics/Presheaf.lean` (the cluster aggregator), and
  `PlusLanguage/PlusRayFibre.lean`, which imports `Presheaf/Ray.lean` directly to read the `⊡`
  clause through `seamFibreEquiv`

## Related Documentation

- [Semantics README](../README.md)
- [`PartialHistory.lean`](../PartialHistory.lean) — the partial histories the sections are drawn
  from, their convexity predicate, and `PartialHistory.rel_across_seam`, the seam argument the
  gluing clause instantiates
- [`TemporalOrder.lean`](../TemporalOrder.lean) — `PositiveCone`, the objects of the site
- [`PlusLanguage/PlusRayFibre.lean`](../../PlusLanguage/PlusRayFibre.lean) — the `⊡`-clause
  readings of `seamFibreEquiv`, over ray pairs and over pairs of ω-indexed step sequences. It
  sits above `Semantics/Truth.lean` and so cannot live in this cluster
- [`docs/reference/paper-definitions-of-record.md`](../../../docs/reference/paper-definitions-of-record.md)
  — where `def:interval-site`, `def:behavior-presheaf`, `def:twisted-arrow`,
  `lem:factorization-linear` and `lem:interval-twisted-arrow` resolve, all `DANGLING`: the paper
  cut the containing appendix `app:Structure` in full, and its surviving commented block carries a
  bare `% CHECK`

---

*Last verified: 2026-10-18*
