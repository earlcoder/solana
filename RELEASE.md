# Solana Release process

## Branches and Tags

```
========================= master branch (edge channel) =======================>
         \                      \                     \
          \___v0.7.0 tag         \                     \
           \                      \         v0.9.0 tag__\
            \          v0.8.0 tag__\                     \
 v0.7.1 tag__\                      \                 v0.9 branch (beta channel)
              \___v0.7.2 tag         \___v0.8.1 tag
               \                      \
                \                      \
           v0.7 branch         v0.8 branch (stable channel)

```

### master branch
All new development occurs on the `master` branch.

Bug fixes that affect a `vX.Y` branch are first made on `master`.  This is to
allow a fix some soak time on `master` before it is applied to one or more
stabilization branches.

Merging to `master` first also helps ensure that fixes applied to one release
are present for future releases.  (Sometimes the joy of landing a critical
release blocker in a branch causes you to forget to propagate back to
`master`!)"

Once the bug fix lands on `master` it is cherry-picked into the `vX.Y` branch
and potentially the `vX.Y-1` branch.  The exception to this rule is when a bug
fix for `vX.Y` doesn't apply to `master` or `vX.Y-1`.

Immediately after a new stabilization branch is forged, the `Cargo.toml` minor
version (*Y*) in the `master` branch is incremented by the release engineer.
Incrementing the major version of the `master` branch is outside the scope of
this document.

### v*X.Y* stabilization branches
These are stabilization branches for a given milestone.  They are created off
the `master` branch as late as possible prior to the milestone release.

### v*X.Y.Z* release tag
The release tags are created as desired by the owner of the given stabilization
branch, and cause that *X.Y.Z* release to be shipped to https://crates.io,
https://snapcraft.io/, and elsewhere.

Immediately after a new v*X.Y.Z* branch tag has been created, the `Cargo.toml`
patch version number (*Z*) of the stabilization branch is incremented by the
release engineer.

## Channels
Channels are used by end-users (humans and bots) to consume the branches
described in the previous section, so they may automatically update to the most
recent version matching their desired stability.

There are three release channels that map to branches as follows:
* edge - tracks the `master` branch, least stable.
* beta - tracks the largest (and latest) `vX.Y` stabilization branch, more stable.
* stable - tracks the second largest `vX.Y` stabilization branch, most stable.

## Release Steps

### Changing channels

When cutting a new channel branch these pre-steps are required:

1. Pick your branch point for release on master.
2. Create the branch.  The name should be "v" + the first 2 "version" fields from Cargo.toml.  For example, a Cargo.toml with version = "0.9.0" implies the next branch name is "v0.9".
4. Push the new branch to the solana repository
3. Update Cargo.toml on master to the next semantic version (e.g. 0.9.0 -> 0.10.0) by running `./scripts/increment-cargo-version.sh`.
5. Land your Cargo.toml change as a master PR.

At this point, ci/channel-info.sh should show your freshly cut release branch as "BETA_CHANNEL" and the previous release branch as "STABLE_CHANNEL".

### Updating channels (i.e. "making a release")

We use [github's Releases UI](https://github.com/solana-labs/solana/releases) for tagging a release.

1. Go [there ;)](https://github.com/solana-labs/solana/releases).
2. Click "Draft new release".  The release tag must exactly match the `version` field in `/Cargo.toml` prefixed by `v` (ie, `<branchname>.X`).
3. If the first major release on the branch (e.g. v0.8.0), paste in [this template](https://raw.githubusercontent.com/solana-labs/solana/master/.github/RELEASE_TEMPLATE.md) and fill it in.
4. Test the release by generating a tag using semver's rules.  First try at a release should be `<branchname>.X-rc.0`.
5. Verify release automation:
   1. [Crates.io](https://crates.io/crates/solana) should have an updated Solana version.
   2. ...
6. After testnet deployment, verify that testnets are running correct software.  http://metrics.solana.com should show testnet running on a hash from your newly created branch.
7. Once the release has been made, update Cargo.toml on release to the next semantic version (e.g. 0.9.0 -> 0.9.1) by running `./scripts/increment-cargo-version.sh patch`.

