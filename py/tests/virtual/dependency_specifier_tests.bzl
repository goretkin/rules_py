"""Tests for parsing dependency specifiers."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//py/private:py_library.bzl", "extract_distribution_name")

def _test_basic_name_extraction_impl(ctx):
    """Test extraction of basic package names."""
    env = unittest.begin(ctx)
    asserts.equals(env, "numpy", extract_distribution_name("numpy"))
    return unittest.end(env)

def _test_with_version_spec_impl(ctx):
    """Test extraction of package names with version specs."""
    env = unittest.begin(ctx)
    asserts.equals(env, "numpy", extract_distribution_name("numpy>=1.2"))
    asserts.equals(env, "numpy", extract_distribution_name("numpy >= 1.2"))
    asserts.equals(env, "numpy", extract_distribution_name("numpy==1.2.3"))
    asserts.equals(env, "numpy", extract_distribution_name("numpy>1.0,<2.0"))
    return unittest.end(env)

def _test_with_extras_impl(ctx):
    """Test extraction of package names with extras."""
    env = unittest.begin(ctx)
    asserts.equals(env, "requests", extract_distribution_name("requests[security]"))
    asserts.equals(env, "requests", extract_distribution_name("requests[security,tests]"))
    return unittest.end(env)

def _test_with_markers_impl(ctx):
    """Test extraction of package names with markers."""
    env = unittest.begin(ctx)
    asserts.equals(env, "numpy", extract_distribution_name("numpy ; python_version=='3.8'"))
    asserts.equals(env, "numpy", extract_distribution_name("numpy>=1.2 ; python_version<'3.8'"))
    return unittest.end(env)

def _test_complex_cases_impl(ctx):
    """Test extraction of package names from complex dependency specs."""
    env = unittest.begin(ctx)
    asserts.equals(env, "requests", extract_distribution_name("requests[security]>=2.0 ; python_version<'3.8'"))
    asserts.equals(env, "django", extract_distribution_name("django[all] >= 3.0, < 4.0 ; sys_platform == 'linux'"))
    return unittest.end(env)

def _test_edge_cases_impl(ctx):
    """Test extraction of package names from more cases."""
    env = unittest.begin(ctx)
    asserts.equals(env, "", extract_distribution_name(""))
    asserts.equals(env, "package-name", extract_distribution_name("package-name"))
    asserts.equals(env, "package_name", extract_distribution_name("package_name"))
    asserts.equals(env, "package.name", extract_distribution_name("package.name"))
    return unittest.end(env)

# Create the test rules
basic_name_extraction_test = unittest.make(_test_basic_name_extraction_impl)
with_version_spec_test = unittest.make(_test_with_version_spec_impl)
with_extras_test = unittest.make(_test_with_extras_impl)
with_markers_test = unittest.make(_test_with_markers_impl)
complex_cases_test = unittest.make(_test_complex_cases_impl)
edge_cases_test = unittest.make(_test_edge_cases_impl)

# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def extract_distribution_name_test_suite(name):
    """Creates the test suite for extract_distribution_name tests."""
    unittest.suite(
        name,
        basic_name_extraction_test,
        with_version_spec_test,
        with_extras_test,
        with_markers_test,
        complex_cases_test,
        edge_cases_test,
    )
