/*
 * testTrifocal.cpp
 * @brief trifocal tensor estimation
 * Created on: Feb 9, 2010
 * @author: Frank Dellaert
 */

#include <iostream>
#include <boost/foreach.hpp>
#include <boost/assign/std/list.hpp> // for operator +=
using namespace boost::assign;

#include <CppUnitLite/TestHarness.h>

#include "tensors.h"
#include "tensorInterface.h"
#include "projectiveGeometry.h"

using namespace std;
using namespace gtsam;
using namespace tensors;

/* ************************************************************************* */
// Indices

Index<3, 'a'> a, _a;
Index<3, 'b'> b, _b;
Index<3, 'c'> c, _c;
Index<3, 'd'> d, _d;
Index<3, 'e'> e, _e;
Index<3, 'f'> f, _f;
Index<3, 'g'> g, _g;

Index<4, 'A'> A;

/* ************************************************************************* */
// 3 Camera setup in trifocal stereo setup, -1,0,1
/* ************************************************************************* */
double left__[4][3] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { -1, 0, 0 } };
double middle[4][3] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { +0, 0, 0 } };
double right_[4][3] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { +1, 0, 0 } };
ProjectiveCamera ML(left__), MM(middle), MR(right_);

// Cube
Point3h P1 = point3h(-1, -1, 3 - 1, 1);
Point3h P2 = point3h(-1, -1, 3 + 1, 1);
Point3h P3 = point3h(-1, +1, 3 - 1, 1);
Point3h P4 = point3h(-1, +1, 3 + 1, 1);
Point3h P5 = point3h(+1, -1, 3 - 1, 1);
Point3h P6 = point3h(+1, -1, 3 + 1, 1);
Point3h P7 = point3h(+1, +1, 3 - 1, 1);
Point3h P8 = point3h(+1, +1, 3 + 1, 1);

/* ************************************************************************* */
// Manohar's homework
TEST(Tensors, TrifocalTensor)
{
	// Checked with MATLAB !
	double t[3][3][3] = {
		{ { -0.301511, 0, 0 }, { 0, -0.603023, 0 }, { 0, 0,-0.603023 } },
		{ {  0, 0.301511, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
		{ {  0, 0, 0.301511 }, { 0, 0, 0 }, { 0, 0, 0 } }
	};
	TrifocalTensor T(t);

	list<Point3h> points;
	points += P1, P2, P3, P4, P5, P6, P7, P8;

	Eta3 eta;

	list<Triplet> triplets;
	double data[3][3] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } };
	Tensor2<3,3> zero(data);
	BOOST_FOREACH(const Point3h& P, points) {
		// form triplet
		Triplet p(ML(a,A)*P(A), MM(b,A)*P(A), MR(c,A)*P(A));
		// check trifocal constraint
		Tensor2<3,3> T1 = T(_a,b,c) * p.first(a);
		Tensor2<3,3> T2 = eta(_d,_b,_e) * p.second(d);
		Tensor2<3,3> T3 = eta(_f,_c,_g) * p.third(f);
		CHECK(assert_equality(zero(_e,_g), (T1(b,c) * T2(_b,_e)) * T3(_c,_g),1e-4));
		triplets += p;
	}

	// We will form the rank 5 tensor by multiplying a rank 3 and rank 2
	// Let's check the answer for the first point:
	Triplet p = triplets.front();

	// This checks the rank 3 (with answer checked in MATLAB);
	double matlab3[3][3][3] = {
		{	{	-0, -0, 0}, { 4, 2, -4}, { 2, 1, -2}},
		{	{	-4, -2, 4}, {-0, -0, 0}, {-2, -1, 2}},
		{	{	-2, -1, 2}, { 2, 1, -2}, {-0, -0, 0}}
	};
	Tensor3<3,3,3> expected3(matlab3);
	CHECK(assert_equality(expected3(a,_b,_e), p.first(a)* (eta(_d,_b,_e) * p.second(d))));

	// This checks the rank 2 (with answer checked in MATLAB);
	double matlab2[3][3] = { {0, -2, -1}, {2, 0, 0}, {1, 0, 0}};
	Tensor2<3,3> expected2(matlab2);
	CHECK(assert_equality(expected2(_c,_g), eta(_f,_c,_g) * p.third(f)));

	TrifocalTensor actual = estimateTrifocalTensor(triplets);
	CHECK(assert_equality(T(_a,b,c),actual(_a,b,c),1e-6));
}

/* ************************************************************************* */
int main() {
	TestResult tr;
	return TestRegistry::runAllTests(tr);
}
/* ************************************************************************* */

