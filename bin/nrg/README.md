
nrg - Next Remote Git
=====================

This is a command-line tool for interacting with hosted Git repositories,
designed to be highly modular such that components can be easily modified or
swapped to meet the requirements of different IT setups.


Dependencies
------------

At the bottom of the stack, the most fundamental dependency is a
POSIX-compliant operating system.
The component shell scripts aim to avoid using shell-specific features, instead
using only the
[shell command language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
and
[utilities](://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html)
specified by POSIX (IEEE Std 1003.1-2017).
By sticking to POSIX (as closely as possible), nrg relies on the operating
system to schedule resources efficiently, such as threads, processes, network
buffers, and file buffers.

Some non-standard utilities are required which must be installed separately:
- `mktemp`: Create temporary files.
  - Developed with GNU/coreutils version `8.22`.
  - Intended to work without modification on FreeBSD and OpenBSD
    implementations.
- `curl`: Make REST API calls over the network.
  - Minimum version unknown, developed with `7.65.3`.
- `jq`: Process JSON data.
  - Minimum version unknown, developed with `1.6`.

Currently, nrg is tested on Linux (CentOS 7).
TODO: Test on FreeBSD and OpenBSD VMs.


Installation
------------

1. Clone this repository, and prepend (or otherwise modify) your `$PATH`
  environment variable to include `bin/`.
  You may wish to add a line in your shell configuration script,
  e.g. `~/.bashrc`, or create an
  [Environment Modules](i://modules.readthedocs.io/en/latest/)
  modulefile.
2. Read the section (below) on environment variables, and configure them.
  Again, you may wish to make these changes permanently in your shell
  configuration or a modulefile.
  At a minimum, you'll need to setup your credentials for authentication.
3. Test the installation by running `_nrg_test.sh` which should exit with code
   `0` on success and non-zero on failure.


Structure
---------

There is one user-facing executable `nrg`, which is the only one which should
(normally) be used from outside this project.
Naturally, enterprising users should be able to use nrg's component scripts,
so all executable components are in placed the same directory as the main
executable, but with their name prefixed by `_` (an underscore).

To clarify exactly what each component should do, each component has the
prefix `_nrg` followed by either `_query` or `_modify`, then the hosting
provider's name, then the component's name.
Component names which contain two consecutive underscores `__` are never used
directly by the user-facing `nrg` wrapper.
Components with the `_nrg_query` prefix should not update any visible state on
the host, i.e. only perform read operation, not write.
Components with the `_nrg_modify` prefix may update visible state on the host,
for example creating repositories or opening pull requests.

The intention is to support multiple hosting providers, but only BitBucket is
currently supported.
To add support for another provider, e.g. GitLab, GitHub, etc., 5 components
must be implemented, each supporting a minimal set of options:

1. `_nrg_query<Provider>_list_projects.sh`
  Print all available project keys which match a given ERE, one per line.
  - `-1`: Exit with code 0 iff exactly one project matches the ERE.
2. `_nrg_query<Provider>_list_repos.sh`
  Print all available repository slugs, for a given project, which match a
  given ERE, one per line.
  - `-1`: Exit with code 0 iff exactly one repository matches the ERE.
  - `-p`: Specify project to override the `${<PROVIDER>_PROJECTKEY}`
          environment variable.
  - `-r`: Print the SSH address on the same line immediately after the
          repository slug, separated by a tab character.
3. `_nrg_query<Provider>_list_branches.sh`
  Print all available git branches, for a given repository slug, which match a
  given ERE, one per line.
  - `-1`: Exit with code 0 iff exactly one branch (or tag) matches the ERE.
  - `-p`: Specify project to override the `${<PROVIDER>_PROJECTKEY}`
          environment variable.
  - `-c`: Print the latest commit hash on the same line immediately after the
          branch (or tag) name, separated by a tab character.
  - `-t`: Work on tags instead of branch names.
4. `_nrg_query<Provider>_list_files.sh`
  Print all available file paths, for a given branch of a repository, which
  match a given ERE, one per line.
  - `-1`: Exit with code 0 iff exactly one file path matches the ERE.
  - `-p`: Specify project to override the `${<PROVIDER>_PROJECTKEY}`
          environment variable.
  - `-c`: Specify a commit, branch, or tag to override the
          `${<PROVIDER>_DEFAULTREF}` environment variable.
5. `_nrg_query<Provider>_concatenate_files.sh`
  Print the contents of all file paths which match a given ERE.
  - `-1`: Exit with code 0 iff exactly one file path matches the ERE.
  - `-p`: Specify project to override the `${<PROVIDER>_PROJECTKEY}`
          environment variable.
  - `-c`: Specify a commit, branch, or tag to override the
          `${<PROVIDER>_DEFAULTREF}` environment variable.

Although not absolutely required, all components should support the `-d` option
to work in debug mode, i.e. provide verbose information.
Similarly, no component should support an explicit `-h` option so that the
usage message is displayed correctly - the `-h` commonly requests help in
interfaces based on GNU guidelines, Python's argparse, and Rust's `clap`.

Some care has been taken to define these components and their arguments with
consistency and flexibility, but they do not provide a command-line interface
meeting modern user-friendly requirements.
The role of the user-facing `nrg` is to wrap the component scripts with the
following provisions:
- access to *all* of their technical facilities,
- simpler ways to perform the most common actions,
- intuitive ways of finding help and possible actions,
- and an abstraction over the details of each hosting provider.

TODO: user-facing component should be replaceable.
TODO: user-facing component can use Rust's `clap` to produce completion
scripts, provide robust argument parsing, and give nicely formatted help.


Environment Variables
---------------------

Each environment variable is prefixed by the hosting provider's name so that
migrations between providers can be performed and tested at an organization
level.

- `BITBUCKET_CREDENTIALS`
  - Purpose: Username and personal access token for authentication.
  - Default: None (every user must set this).
  - Example: `jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`
    The username `jdoe` is used to sign into the BitBucket web interface.
    The PAT (Personal Access Token) is created in the BitBucket web interface
    by navigating to `Manage account > Personal access tokens > Create token`
    and keeping note of the random string of characters.
- `BITBUCKET_BASEURI`
  - Purpose: Sets the prefix of the REST API requests.
    If you are setting up nrg without support from your organization, this
    should be set once and left alone.
    If nrg is used throughout your organization, normal users should not
    normally override this.
    This is useful for smooth migration (dev/IT only) between domains hosting
    BitBucket servers.
  - Default: `https://projecttools.nordicsemi.no/bitbucket/rest/api/latest/`
- `BITBUCKET_PROJECTKEY`
  - Purpose: Convenience for users working mostly on one project.
    If you are usually working on the same project, you can use this to avoid
    specifying it on every invocation.
  - Default: `SIG-DOGIT`
- `BITBUCKET_DEFAULTREF`
  - Purpose: Convenience for repositories with a default branch name.
    If you are usually working on the same branch, you can use this to avoid
    specifying it on every invocation.
  - Default: `master`
- `BITBUCKET_PAGELIMIT`
  - Purpose: Useful for network performance tuning (dev/IT only) by changing
    how many objects are requested in each "page" from BitBucket.
    The underlying REST API uses pagination to conserve server resources.
    Normal users should not override this.
  - Default: `1000`
