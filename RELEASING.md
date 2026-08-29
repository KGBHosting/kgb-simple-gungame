# Release policy

KGB Simple GunGame uses immutable Semantic Versioning tags and GitHub Actions to
build public assets. A release tag is an input to the build, never a substitute
for qualification.

## Stable release gate

1. Update `VERSION`, `PLUGIN_VERSION`, the example configuration header,
   `CHANGELOG.md`, and README release text together.
2. Run `./scripts/check-release.sh`, `./scripts/check-compatibility.sh`,
   `AMXX_VERSION=1.8.2 ./scripts/build.sh`, and
   `PACKAGE_TEST_VERSION=local ./scripts/test-install.sh` from a clean checkout.
3. Confirm the only Pawn source differences from the qualified candidate are
   intentional. A metadata-only promotion changes only `PLUGIN_VERSION`.
4. Merge through a reviewed pull request only after every required check passes
   for the exact head commit.
5. Create an annotated `vMAJOR.MINOR.PATCH` tag at that exact `main` commit.
   Never move, replace, or reuse a published tag.
6. Let the tag workflow rebuild from source. It rejects a tag that does not
   match `VERSION` and `PLUGIN_VERSION`.
7. Verify every `.sha256` file and `SHA256SUMS` in the downloaded release assets
   before marking the release qualified for downstream catalogs.

Tags beginning with `v0.` are published as prereleases. A matching `v1.0.0`
tag is the first stable release. Creating or pushing a tag is deliberately a
separate, authorized step because it publishes the GitHub release.

## Release assets

The workflow publishes:

- `kgb_simple_gungame.amxx` and its SHA-256 file;
- the MIT license and changelog;
- a reproducible `kgb-simple-gungame-vX.Y.Z.zip` and its SHA-256 file;
- `SHA256SUMS`, covering the binary, license, changelog, and ZIP.

The ZIP contains the compiled plugin, source, example configuration, installer,
license, changelog, security policy, validation record, release policy, README,
and exact `VERSION` file.
