
# The `make` command must be run from `nrg/`, i.e. the top level of this
# project.

# The first target is also the default, i.e. `make` is equivalent to
# `make test` or, in this case, `make all`.
test: all

# Disable suffix rules and pattern rules.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html>
.SUFFIXES:
MAKEFLAGS += -r

# Disable GNU Make's default behaviour of removing intermediate targets.
# <https://www.gnu.org/software/make/manual/html_node/Special-Targets.html>
# .SECONDARY with no prerequisites causes all targets to be treated as
# secondary (i.e., no target is removed because it is considered intermediate).
.SECONDARY:

# Get the list of test names from the scripts immediately under `tests/`, but
# no further down the filesystem hierarchy.
# The final list of dependencies is built from this to allow parallel
# execution.
# NOTE: Shell-assignment syntax is not part of POSIX (yet), but is supported by
# GNU (> 4.0), FreeBSD, OpenBSD, and NetBSD implementations.
# <https://www.austingroupbugs.net/view.php?id=337>
# <https://www.gnu.org/software/make/manual/html_node/Setting.html>
# <https://man.freebsd.org/cgi/man.cgi?query=make>
# <https://man.openbsd.org/i386/make>
# <https://man.netbsd.org/make.1>
TESTNAME_RE = [A-Za-z0-9_]*
TESTNAMES != ls tests/*.sh | sed 's@.*/\(${TESTNAME_RE}\)\.sh@\1@g'
DEPS != echo '${TESTNAMES}' | sed 's@\([^ ]*\) *@tests/diff/\1.status @g'

# Run each test script.
# It is the responsibility of each script to capture both the STDOUT into
# `observed/%.stdout` and STDERR into `observed/%.stderr`.
tests/observed/%.stdout: tests/%.sh
	mkdir -p $$(dirname $@)
	TESTNAME=$$(echo '$@' | sed 's@.*/\(${TESTNAME_RE}\)\.stdout@\1@'); \
		tests/$${TESTNAME}.sh

# Compare the expected output with the observed output.
# Afterwards the files `tests/diff/%.status` should contain a single line
# `PASS` or any number of lines of different words.
# For clarity, failing test scripts should have `FAIL` as the first line,
# optionally followed by additional information.
# There is no way to append additional information to a passing status.
tests/diff/%.status: tests/observed/%.stdout
	mkdir -p $$(dirname $@)
	echo FAIL > $@
	TESTNAME=$$(echo '$@' | sed 's@.*/\(${TESTNAME_RE}\)\.status@\1@'); \
		diff tests/expected/$${TESTNAME}.stdout tests/observed/$${TESTNAME}.stdout
	TESTNAME=$$(echo '$@' | sed 's@.*/\(${TESTNAME_RE}\)\.status@\1@'); \
		diff tests/expected/$${TESTNAME}.stderr tests/observed/$${TESTNAME}.stderr
	echo PASS > $@

# Report the overall status which depends on the status files from all tests.
all: ${DEPS}
	! grep -v '^PASS$$' tests/diff/*.status

clean:
	rm -rf tests/observed/
	rm -rf tests/diff/

