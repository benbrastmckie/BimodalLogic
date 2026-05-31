"""
Formula dataclass hierarchy and JSON parser for bimodal TM logic.

Matches the Lean Bimodal.Syntax.Formula constructors exactly.
The 6 primitive constructors are: atom, neg, and, or, box, untl, snce.
Derived constructors (imp, iff, dia, top, bot) are expanded to primitives.

JSON format matches bmlogic-bench.jsonl formula_ast field:
  {"tag": "atom", "name": "p"}
  {"tag": "neg", "inner": {...}}
  {"tag": "and", "left": {...}, "right": {...}}
  {"tag": "or", "left": {...}, "right": {...}}
  {"tag": "box", "child": {...}}
  {"tag": "dia", "inner": {...}}         -- derived: neg(box(neg(phi)))
  {"tag": "imp", "left": {...}, "right": {...}}   -- derived: or(neg(l), r)
  {"tag": "iff", "left": {...}, "right": {...}}   -- derived: and(imp(l,r), imp(r,l))
  {"tag": "untl", "event": {...}, "guard": {...}}  -- Until (Burgess: strict, event=phi=first arg, guard=psi=second arg)
  {"tag": "snce", "event": {...}, "guard": {...}}  -- Since (Burgess: strict, event=phi=first arg, guard=psi=second arg)
  {"tag": "top"}                          -- derived: neg(bot) or and(p, neg(p)) -> True
  {"tag": "bot"}                          -- derived: and(atom(p), neg(atom(p)))
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union


# ---------------------------------------------------------------------------
# Formula abstract base
# ---------------------------------------------------------------------------

@dataclass(frozen=True, eq=True)
class Formula:
    """Abstract base for bimodal TM formulas."""

    def atoms(self) -> set[str]:
        """Return all atom names in this formula."""
        raise NotImplementedError

    def subformulas(self) -> list[Formula]:
        """Return all subformulas (including self) bottom-up."""
        raise NotImplementedError

    def modal_depth(self) -> int:
        """Maximum nesting depth of box/diamond operators."""
        raise NotImplementedError

    def temporal_depth(self) -> int:
        """Maximum nesting depth of until/since operators."""
        raise NotImplementedError


# ---------------------------------------------------------------------------
# Primitive constructors (matching Lean Bimodal.Syntax.Formula)
# ---------------------------------------------------------------------------

@dataclass(frozen=True, eq=True)
class Atom(Formula):
    """Propositional atom: atom(name)."""
    name: str

    def atoms(self) -> set[str]:
        return {self.name}

    def subformulas(self) -> list[Formula]:
        return [self]

    def modal_depth(self) -> int:
        return 0

    def temporal_depth(self) -> int:
        return 0

    def __repr__(self) -> str:
        return f"Atom({self.name!r})"


@dataclass(frozen=True, eq=True)
class Neg(Formula):
    """Negation: neg(phi)."""
    inner: Formula

    def atoms(self) -> set[str]:
        return self.inner.atoms()

    def subformulas(self) -> list[Formula]:
        return self.inner.subformulas() + [self]

    def modal_depth(self) -> int:
        return self.inner.modal_depth()

    def temporal_depth(self) -> int:
        return self.inner.temporal_depth()

    def __repr__(self) -> str:
        return f"Neg({self.inner!r})"


@dataclass(frozen=True, eq=True)
class And(Formula):
    """Conjunction: and(phi, psi)."""
    left: Formula
    right: Formula

    def atoms(self) -> set[str]:
        return self.left.atoms() | self.right.atoms()

    def subformulas(self) -> list[Formula]:
        return self.left.subformulas() + self.right.subformulas() + [self]

    def modal_depth(self) -> int:
        return max(self.left.modal_depth(), self.right.modal_depth())

    def temporal_depth(self) -> int:
        return max(self.left.temporal_depth(), self.right.temporal_depth())

    def __repr__(self) -> str:
        return f"And({self.left!r}, {self.right!r})"


@dataclass(frozen=True, eq=True)
class Or(Formula):
    """Disjunction: or(phi, psi)."""
    left: Formula
    right: Formula

    def atoms(self) -> set[str]:
        return self.left.atoms() | self.right.atoms()

    def subformulas(self) -> list[Formula]:
        return self.left.subformulas() + self.right.subformulas() + [self]

    def modal_depth(self) -> int:
        return max(self.left.modal_depth(), self.right.modal_depth())

    def temporal_depth(self) -> int:
        return max(self.left.temporal_depth(), self.right.temporal_depth())

    def __repr__(self) -> str:
        return f"Or({self.left!r}, {self.right!r})"


@dataclass(frozen=True, eq=True)
class Box(Formula):
    """S5 modal box: box(phi). True at (sigma, t) iff phi holds at (sigma', t) for all histories sigma'."""
    inner: Formula

    def atoms(self) -> set[str]:
        return self.inner.atoms()

    def subformulas(self) -> list[Formula]:
        return self.inner.subformulas() + [self]

    def modal_depth(self) -> int:
        return 1 + self.inner.modal_depth()

    def temporal_depth(self) -> int:
        return self.inner.temporal_depth()

    def __repr__(self) -> str:
        return f"Box({self.inner!r})"


@dataclass(frozen=True, eq=True)
class Until(Formula):
    """
    Temporal until (Burgess strict): untl(event=phi, guard=psi).

    Semantics: ∃ s > t, truth(phi, s) ∧ ∀ r ∈ (t, s), truth(psi, r)
    - phi (left/event): must eventually hold STRICTLY in the future
    - psi (right/guard): must hold on the open interval (t, s) before phi

    JSON format: {"tag": "untl", "event": <phi>, "guard": <psi>}
    """
    left: Formula   # event = phi (the eventual goal)
    right: Formula  # guard = psi (the condition holding until phi)

    def atoms(self) -> set[str]:
        return self.left.atoms() | self.right.atoms()

    def subformulas(self) -> list[Formula]:
        return self.left.subformulas() + self.right.subformulas() + [self]

    def modal_depth(self) -> int:
        return max(self.left.modal_depth(), self.right.modal_depth())

    def temporal_depth(self) -> int:
        return 1 + max(self.left.temporal_depth(), self.right.temporal_depth())

    def __repr__(self) -> str:
        return f"Until({self.left!r}, {self.right!r})"


@dataclass(frozen=True, eq=True)
class Since(Formula):
    """
    Temporal since (Burgess strict): snce(event=phi, guard=psi).

    Semantics: ∃ s < t, truth(phi, s) ∧ ∀ r ∈ (s, t), truth(psi, r)
    - phi (left/event): must have held STRICTLY in the past
    - psi (right/guard): must hold on the open interval (s, t) after phi

    JSON format: {"tag": "snce", "event": <phi>, "guard": <psi>}
    """
    left: Formula   # event = phi (the past goal)
    right: Formula  # guard = psi (the condition holding since phi)

    def atoms(self) -> set[str]:
        return self.left.atoms() | self.right.atoms()

    def subformulas(self) -> list[Formula]:
        return self.left.subformulas() + self.right.subformulas() + [self]

    def modal_depth(self) -> int:
        return max(self.left.modal_depth(), self.right.modal_depth())

    def temporal_depth(self) -> int:
        return 1 + max(self.left.temporal_depth(), self.right.temporal_depth())

    def __repr__(self) -> str:
        return f"Since({self.left!r}, {self.right!r})"


# ---------------------------------------------------------------------------
# Derived constructors (expanded to primitives for Z3 encoding)
# ---------------------------------------------------------------------------

def Top() -> Neg:
    """Top (verum): derived as neg(and(atom('__bot__'), neg(atom('__bot__'))))."""
    # Use a canonical representation: neg(neg(atom('__bot__'))) or simply
    # a formula that is always true. Simplest: neg(and(p, neg(p))) for fresh p.
    # To avoid atom pollution, use neg(neg(atom('__top__'))) at the formula level.
    # Actually: top = neg(bot) where bot = and(atom('__bot__'), neg(atom('__bot__')))
    bot_atom = Atom('__bot__')
    bot = And(bot_atom, Neg(bot_atom))
    return Neg(bot)


def Bot() -> And:
    """Bottom (falsum): derived as and(atom('__bot__'), neg(atom('__bot__')))."""
    bot_atom = Atom('__bot__')
    return And(bot_atom, Neg(bot_atom))


def Imp(left: Formula, right: Formula) -> Or:
    """Implication: derived as or(neg(left), right)."""
    return Or(Neg(left), right)


def Iff(left: Formula, right: Formula) -> And:
    """Biconditional: derived as and(imp(left, right), imp(right, left))."""
    return And(Imp(left, right), Imp(right, left))


def Diamond(inner: Formula) -> Neg:
    """Modal diamond: derived as neg(box(neg(inner)))."""
    return Neg(Box(Neg(inner)))


# Type alias for union of all formula types
FormulaNode = Union[Atom, Neg, And, Or, Box, Until, Since]


# ---------------------------------------------------------------------------
# JSON parser
# ---------------------------------------------------------------------------

def parse_formula_json(ast: dict) -> Formula:
    """
    Parse a formula AST dictionary (from bmlogic-bench.jsonl formula_ast field)
    into a Formula dataclass tree.

    Supported tags:
        Primitives: atom, neg, and, or, box, untl, snce
        Derived (expanded): imp, iff, dia, top, bot

    Args:
        ast: dict with 'tag' key and type-specific fields

    Returns:
        Formula instance

    Raises:
        ValueError: if the tag is unrecognized or required fields are missing
        TypeError: if ast is not a dict
    """
    if not isinstance(ast, dict):
        raise TypeError(f"Expected dict, got {type(ast).__name__}: {ast!r}")

    tag = ast.get("tag")
    if tag is None:
        raise ValueError(f"Formula dict missing 'tag' field: {ast!r}")

    if tag == "atom":
        name = ast.get("name")
        if name is None:
            raise ValueError(f"Atom missing 'name' field: {ast!r}")
        return Atom(str(name))

    elif tag == "neg":
        inner_ast = ast.get("inner")
        if inner_ast is None:
            raise ValueError(f"Neg missing 'inner' field: {ast!r}")
        return Neg(parse_formula_json(inner_ast))

    elif tag == "and":
        left_ast = ast.get("left")
        right_ast = ast.get("right")
        if left_ast is None or right_ast is None:
            raise ValueError(f"And missing 'left'/'right' fields: {ast!r}")
        return And(parse_formula_json(left_ast), parse_formula_json(right_ast))

    elif tag == "or":
        left_ast = ast.get("left")
        right_ast = ast.get("right")
        if left_ast is None or right_ast is None:
            raise ValueError(f"Or missing 'left'/'right' fields: {ast!r}")
        return Or(parse_formula_json(left_ast), parse_formula_json(right_ast))

    elif tag == "box":
        # Lean DataExport format: {"tag": "box", "child": <phi>}
        inner_ast = ast.get("inner") or ast.get("child")
        if inner_ast is None:
            raise ValueError(f"Box missing 'inner'/'child' field: {ast!r}")
        return Box(parse_formula_json(inner_ast))

    elif tag == "untl":
        # Lean DataExport format: {"tag": "untl", "event": <phi>, "guard": <psi>}
        # Semantics: untl(event=phi, guard=psi) = ∃ s > t, truth(phi, s) ∧ ∀ r ∈ (t,s), truth(psi, r)
        # "event" is the first arg (phi) and "guard" is the second arg (psi)
        # Also accept "left"/"right" for internal round-trip serialization
        event_ast = ast.get("event") or ast.get("left")
        guard_ast = ast.get("guard") or ast.get("right")
        if event_ast is None or guard_ast is None:
            raise ValueError(f"Until missing 'event'/'guard' fields: {ast!r}")
        return Until(parse_formula_json(event_ast), parse_formula_json(guard_ast))

    elif tag == "snce":
        # Lean DataExport format: {"tag": "snce", "event": <phi>, "guard": <psi>}
        # Semantics: snce(event=phi, guard=psi) = ∃ s < t, truth(phi, s) ∧ ∀ r ∈ (s,t), truth(psi, r)
        # Also accept "left"/"right" for internal round-trip serialization
        event_ast = ast.get("event") or ast.get("left")
        guard_ast = ast.get("guard") or ast.get("right")
        if event_ast is None or guard_ast is None:
            raise ValueError(f"Since missing 'event'/'guard' fields: {ast!r}")
        return Since(parse_formula_json(event_ast), parse_formula_json(guard_ast))

    # Derived constructors (expand to primitives)
    elif tag == "imp":
        left_ast = ast.get("left")
        right_ast = ast.get("right")
        if left_ast is None or right_ast is None:
            raise ValueError(f"Imp missing 'left'/'right' fields: {ast!r}")
        return Imp(parse_formula_json(left_ast), parse_formula_json(right_ast))

    elif tag == "iff":
        left_ast = ast.get("left")
        right_ast = ast.get("right")
        if left_ast is None or right_ast is None:
            raise ValueError(f"Iff missing 'left'/'right' fields: {ast!r}")
        return Iff(parse_formula_json(left_ast), parse_formula_json(right_ast))

    elif tag == "dia":
        inner_ast = ast.get("inner")
        if inner_ast is None:
            raise ValueError(f"Diamond missing 'inner' field: {ast!r}")
        return Diamond(parse_formula_json(inner_ast))

    elif tag == "top":
        return Top()

    elif tag == "bot":
        return Bot()

    else:
        raise ValueError(f"Unknown formula tag: {tag!r}")


def formula_to_json(formula: Formula) -> dict:
    """
    Convert a Formula dataclass back to AST dict format.
    Note: derived forms (Top, Bot, Imp, Iff, Diamond) will appear as primitives
    after round-trip since parse_formula_json expands them.
    """
    if isinstance(formula, Atom):
        return {"tag": "atom", "name": formula.name}
    elif isinstance(formula, Neg):
        return {"tag": "neg", "inner": formula_to_json(formula.inner)}
    elif isinstance(formula, And):
        return {"tag": "and", "left": formula_to_json(formula.left), "right": formula_to_json(formula.right)}
    elif isinstance(formula, Or):
        return {"tag": "or", "left": formula_to_json(formula.left), "right": formula_to_json(formula.right)}
    elif isinstance(formula, Box):
        return {"tag": "box", "inner": formula_to_json(formula.inner)}
    elif isinstance(formula, Until):
        return {"tag": "untl", "left": formula_to_json(formula.left), "right": formula_to_json(formula.right)}
    elif isinstance(formula, Since):
        return {"tag": "snce", "left": formula_to_json(formula.left), "right": formula_to_json(formula.right)}
    else:
        raise ValueError(f"Unknown formula type: {type(formula).__name__}")
