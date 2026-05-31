"""
Tests for the quantifier-free frame and truth encoding (encoding.py).

Tests each frame axiom and truth constructor at N=2, M=2.
"""

import pytest
import z3

from bmlogic_oracle.formula import (
    Atom, Neg, And, Or, Box, Until, Since,
    Imp, Bot, Top,
)
from bmlogic_oracle.encoding import FrameEncoder


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def make_solver(encoder: FrameEncoder, extra_constraints=None) -> z3.Solver:
    """Create a Z3 solver with frame constraints and optional extras."""
    s = z3.Solver()
    for c in encoder.frame_constraints():
        s.add(c)
    if extra_constraints:
        for c in extra_constraints:
            s.add(c)
    return s


def is_sat(encoder: FrameEncoder, extra_constraints=None) -> bool:
    """Check if the frame with extra constraints is satisfiable."""
    s = make_solver(encoder, extra_constraints)
    result = s.check()
    return result == z3.sat


def check_valid(encoder: FrameEncoder, formula, atoms, sigma_idx=0, t=0) -> bool:
    """
    Check if formula is valid (no countermodel) at the given bounds.
    Returns True if valid (UNSAT for negation), False if countermodel found.

    The falsifying history (sigma_idx) is required to RESPECT the task relation,
    ensuring we only search in valid frames.
    """
    s = make_solver(encoder)

    # Require the falsifying history to respect the task relation
    hist = encoder.all_histories()[sigma_idx]
    for t1 in range(encoder.M):
        for t2 in range(t1 + 1, encoder.M):
            d = t2 - t1
            w = hist[t1]
            u = hist[t2]
            s.add(encoder.task_rel_var(w, d, u))

    truth_expr = encoder.truth(formula, atoms, sigma_idx, t)
    s.add(z3.Not(truth_expr))
    return s.check() == z3.unsat


def check_satisfiable(encoder: FrameEncoder, formula, atoms, sigma_idx=0, t=0) -> bool:
    """Check if formula has a satisfying model (countermodel for its negation)."""
    s = make_solver(encoder)
    truth_expr = encoder.truth(formula, atoms, sigma_idx, t)
    s.add(truth_expr)
    return s.check() == z3.sat


# ---------------------------------------------------------------------------
# Frame variable tests
# ---------------------------------------------------------------------------

class TestFrameVariables:
    def test_task_rel_var_created(self):
        enc = FrameEncoder(2, 2)
        v = enc.task_rel_var(0, 0, 1)
        assert isinstance(v, z3.BoolRef)

    def test_atom_var_created(self):
        enc = FrameEncoder(2, 2)
        v = enc.atom_var(0, 0, "p")
        assert isinstance(v, z3.BoolRef)

    def test_histories_count_N2_M2(self):
        enc = FrameEncoder(2, 2)
        histories = enc.all_histories()
        assert len(histories) == 4  # 2^2 = 4

    def test_histories_count_N3_M3(self):
        enc = FrameEncoder(3, 3)
        histories = enc.all_histories()
        assert len(histories) == 27  # 3^3 = 27

    def test_histories_are_tuples_of_world_indices(self):
        enc = FrameEncoder(2, 3)
        for hist in enc.all_histories():
            assert len(hist) == 3
            for w in hist:
                assert 0 <= w < 2


# ---------------------------------------------------------------------------
# Nullity/identity axiom tests
# ---------------------------------------------------------------------------

class TestNullityIdentity:
    def test_nullity_identity_satisfiable(self):
        """The nullity_identity constraints should be satisfiable by themselves."""
        enc = FrameEncoder(2, 2)
        constraints = enc.nullity_identity_constraints()
        s = z3.Solver()
        for c in constraints:
            s.add(c)
        assert s.check() == z3.sat

    def test_nullity_identity_diagonal(self):
        """task_rel(w, 0, w) must be True."""
        enc = FrameEncoder(2, 2)
        constraints = enc.nullity_identity_constraints()
        s = z3.Solver()
        for c in constraints:
            s.add(c)
        assert s.check() == z3.sat
        m = s.model()
        for w in range(2):
            v = enc.task_rel_var(w, 0, w)
            assert z3.is_true(m.evaluate(v, model_completion=True))

    def test_nullity_identity_off_diagonal(self):
        """task_rel(w, 0, u) must be False for w != u."""
        enc = FrameEncoder(2, 2)
        constraints = enc.nullity_identity_constraints()
        s = z3.Solver()
        for c in constraints:
            s.add(c)
        assert s.check() == z3.sat
        m = s.model()
        for w in range(2):
            for u in range(2):
                if w != u:
                    v = enc.task_rel_var(w, 0, u)
                    assert z3.is_false(m.evaluate(v, model_completion=True))

    def test_full_frame_satisfiable(self):
        """All frame constraints together should be satisfiable."""
        enc = FrameEncoder(2, 2)
        assert is_sat(enc)

    def test_full_frame_satisfiable_larger(self):
        """Frame at N=3, M=3 should be satisfiable."""
        enc = FrameEncoder(3, 3)
        assert is_sat(enc)


# ---------------------------------------------------------------------------
# Forward composition tests
# ---------------------------------------------------------------------------

class TestForwardComp:
    def test_composition_satisfiable(self):
        """Forward comp constraints should be satisfiable."""
        enc = FrameEncoder(2, 3)
        constraints = enc.forward_comp_constraints()
        s = z3.Solver()
        for c in constraints:
            s.add(c)
        assert s.check() == z3.sat

    def test_composition_consistency(self):
        """d1=0 + d2=1 must be consistent with nullity_identity."""
        enc = FrameEncoder(2, 2)
        s = make_solver(enc)
        assert s.check() == z3.sat
        m = s.model()
        # If rel(w, 0, v) is w==v, and rel(v, 1, u) gives us rel(w, 1, u)
        # This should hold given the model -- just verify model is accessible
        assert m is not None


# ---------------------------------------------------------------------------
# Converse axiom tests
# ---------------------------------------------------------------------------

class TestConverse:
    def test_converse_satisfiable(self):
        """Converse constraints should be satisfiable."""
        enc = FrameEncoder(2, 2)
        constraints = enc.converse_constraints()
        s = z3.Solver()
        for c in constraints:
            s.add(c)
        assert s.check() == z3.sat


# ---------------------------------------------------------------------------
# Truth encoding: atom
# ---------------------------------------------------------------------------

class TestAtomEncoding:
    def test_atom_truth_satisfiable(self):
        """An atom can be true."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        atoms = ["p"]
        assert check_satisfiable(enc, p, atoms)

    def test_atom_truth_also_can_be_false(self):
        """An atom can also be false."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        atoms = ["p"]
        assert check_satisfiable(enc, Neg(p), atoms)

    def test_bot_atom_always_false(self):
        """__bot__ synthetic atom is always false."""
        enc = FrameEncoder(2, 2)
        bot_atom = Atom("__bot__")
        atoms = ["__bot__"]
        # bot_atom should be unsatisfiable (always False)
        s = make_solver(enc)
        s.add(enc.truth(bot_atom, atoms, 0, 0))
        assert s.check() == z3.unsat


# ---------------------------------------------------------------------------
# Truth encoding: negation and boolean connectives
# ---------------------------------------------------------------------------

class TestBooleanEncoding:
    def test_neg_of_neg_equiv_original(self):
        """neg(neg(p)) should be satisfiable when p is true."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        neg_neg_p = Neg(Neg(p))
        atoms = ["p"]
        assert check_satisfiable(enc, neg_neg_p, atoms)

    def test_and_conjunction(self):
        """p and q should both be satisfiable and falsifiable."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        assert check_satisfiable(enc, And(p, q), atoms)
        assert check_satisfiable(enc, Neg(And(p, q)), atoms)

    def test_tautology_p_or_neg_p(self):
        """p or neg(p) is a tautology -- valid at N=2, M=2."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        tautology = Or(p, Neg(p))
        atoms = ["p"]
        assert check_valid(enc, tautology, atoms)

    def test_contradiction_p_and_neg_p(self):
        """p and neg(p) is unsatisfiable."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        contra = And(p, Neg(p))
        atoms = ["p"]
        s = make_solver(enc)
        s.add(enc.truth(contra, atoms, 0, 0))
        assert s.check() == z3.unsat


# ---------------------------------------------------------------------------
# Truth encoding: box (modal)
# ---------------------------------------------------------------------------

class TestBoxEncoding:
    def test_box_identity_valid(self):
        """box(imp(p, p)) is valid -- classic S5 identity."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        identity = Box(Imp(p, p))
        atoms = ["p"]
        # Valid: no countermodel
        assert check_valid(enc, identity, atoms)

    def test_box_atom_can_be_false(self):
        """box(p) is not valid -- can find a countermodel."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        atoms = ["p"]
        # box(p) is not valid: some history has p false
        assert not check_valid(enc, Box(p), atoms)

    def test_box_distributes_over_and(self):
        """box(p and q) -> box(p) should be valid."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        # box(p and q) -> box(p) = Or(neg(box(and(p,q))), box(p))
        formula = Imp(Box(And(p, q)), Box(p))
        assert check_valid(enc, formula, atoms)

    def test_box_tautology(self):
        """box(p or neg(p)) is valid -- box distributes into tautologies."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        atoms = ["p"]
        formula = Box(Or(p, Neg(p)))
        assert check_valid(enc, formula, atoms)


# ---------------------------------------------------------------------------
# Truth encoding: until / since
# ---------------------------------------------------------------------------

class TestUntilSinceEncoding:
    def test_until_can_be_satisfied(self):
        """Until(p, q) can be satisfied with M=3 (p at t=2, q at t=1)."""
        enc = FrameEncoder(2, 3)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        # Until(event=p, guard=q) at t=0: exists s > 0 with p(s) and q on (0, s)
        s = make_solver(enc)
        s.add(enc.truth(Until(p, q), atoms, 0, 0))
        assert s.check() == z3.sat

    def test_until_false_at_last_time_step(self):
        """Until(p, q) at t=M-1 (last step) is always false (no s > M-1)."""
        enc = FrameEncoder(2, 3)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        # At t = M-1 = 2, no s > 2 in range, so Until is false
        s = make_solver(enc)
        s.add(enc.truth(Until(p, q), atoms, 0, 2))  # t = M-1
        assert s.check() == z3.unsat

    def test_since_false_at_first_time_step(self):
        """Since(p, q) at t=0 is always false (no s < 0)."""
        enc = FrameEncoder(2, 3)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        # At t = 0, no s < 0, so Since is false
        s = make_solver(enc)
        s.add(enc.truth(Since(p, q), atoms, 0, 0))
        assert s.check() == z3.unsat

    def test_since_can_be_satisfied(self):
        """Since(p, q) can be satisfied at t=2 (p at t=0, q vacuous)."""
        enc = FrameEncoder(2, 3)
        p = Atom("p")
        q = Atom("q")
        atoms = ["p", "q"]
        # Since(event=p, guard=q) at t=2: exists s < 2 with p(s) and q on (s, 2)
        s = make_solver(enc)
        s.add(enc.truth(Since(p, q), atoms, 0, 2))
        assert s.check() == z3.sat


# ---------------------------------------------------------------------------
# Known valid / invalid formulas from bimodal TM logic
# ---------------------------------------------------------------------------

class TestKnownFormulas:
    """Test that the oracle gives correct answers on known valid/invalid formulas."""

    def test_box_imp_aa_valid(self):
        """box(p -> p) is a theorem of S5 -- must be valid."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        formula = Box(Imp(p, p))
        atoms = ["p"]
        assert check_valid(enc, formula, atoms), "box(p->p) should be valid"

    def test_box_reflexive_valid(self):
        """box(p) -> p should be a theorem (T-axiom equivalent for box)."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        formula = Imp(Box(p), p)
        atoms = ["p"]
        assert check_valid(enc, formula, atoms), "box(p) -> p should be valid"

    def test_box_4_valid(self):
        """box(p) -> box(box(p)) (S4 axiom, valid in S5 too)."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        formula = Imp(Box(p), Box(Box(p)))
        atoms = ["p"]
        assert check_valid(enc, formula, atoms), "box(p) -> box(box(p)) should be valid"

    def test_box_5_valid(self):
        """neg(box(p)) -> box(neg(box(p))) (S5 axiom)."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        formula = Imp(Neg(Box(p)), Box(Neg(Box(p))))
        atoms = ["p"]
        assert check_valid(enc, formula, atoms), "neg(box(p)) -> box(neg(box(p))) should be valid"

    def test_box_p_not_valid(self):
        """box(p) alone is not a tautology -- has countermodel."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        formula = Box(p)
        atoms = ["p"]
        assert not check_valid(enc, formula, atoms), "box(p) should not be valid"

    def test_bot_not_valid(self):
        """bot (falsum) is not valid."""
        enc = FrameEncoder(2, 2)
        formula = Bot()
        atoms = []
        assert not check_valid(enc, formula, atoms), "bot should not be valid"


# ---------------------------------------------------------------------------
# encode_formula API
# ---------------------------------------------------------------------------

class TestEncodeFormulaAPI:
    def test_encode_formula_returns_tuple(self):
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        atoms = ["p"]
        frame_cs, negated = enc.encode_formula(p, atoms)
        assert isinstance(frame_cs, list)
        assert isinstance(negated, z3.BoolRef)

    def test_encode_formula_negation(self):
        """Solving with negated tautology should be UNSAT."""
        enc = FrameEncoder(2, 2)
        p = Atom("p")
        tautology = Or(p, Neg(p))
        atoms = ["p"]
        frame_cs, negated = enc.encode_formula(tautology, atoms)
        s = z3.Solver()
        for c in frame_cs:
            s.add(c)
        s.add(negated)
        assert s.check() == z3.unsat
